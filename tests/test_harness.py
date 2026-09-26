"""Regression checks for card scaffolding and fail-closed static validation.

Run from the repository root: python -m unittest discover -s tests -v
"""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / "tools"
_spec = importlib.util.spec_from_file_location("harness_under_test", TOOLS / "manage_harness.py")
harness = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(harness)
POWERSHELL = shutil.which("powershell") or shutil.which("pwsh")


class HarnessRegressionTests(unittest.TestCase):
    def test_extra_deck_effect_templates_preserve_effect_bit(self):
        # EDOPro type flags are independent of the harness mapping under test.
        type_monster, type_effect = 0x1, 0x20
        type_fusion, type_synchro = 0x40, 0x2000
        type_xyz, type_link = 0x800000, 0x4000000
        for template, subtype in {
            "fusion_monster": type_fusion,
            "synchro_monster": type_synchro,
            "xyz_monster": type_xyz,
            "link_monster": type_link,
        }.items():
            expected = type_monster | type_effect | subtype
            with self.subTest(template=template):
                spec = harness.build_spec_skeleton(12345678, "Test", template, 0)
                self.assertEqual(spec["type"], expected)

    def test_spell_templates_carry_their_own_type_bits(self):
        # Spell subtype nằm ở bit riêng; thiếu template thì agent phải sửa type tay sau khi start.
        for template, expected in {
            "normal_spell": 0x2,
            "quick_play_spell": 0x10002,
            "continuous_spell": 0x20002,
            "field_spell": 0x80002,
        }.items():
            with self.subTest(template=template):
                self.assertTrue((TOOLS / "templates" / f"template_{template}.lua").exists())
                spec = harness.build_spec_skeleton(12345678, "Test", template, 0)
                self.assertEqual(spec["type"], expected)

    def archetype_fixture(self, root):
        features = root / "feature_list.json"
        features.write_text(json.dumps({"archetypes": {"Common": {"cards": []}}}), encoding="utf-8")
        constants = root / "constants.lua"
        constants.write_bytes(b"-- Custom Archetype\r\nSET_TTF = 0x789\r\nSET_ATERMIS = 0x780\r\n"
                              b"-- Custom counter\r\nCOUNTER_MANA = 0x177\r\n")
        strings = root / "strings.conf"
        strings.write_bytes(b"#Custom Archetype\r\n!setname 0x789 TTF\r\n!setname 0x781 Cat\r\n"
                            b"#Custom Counter\r\n!counter 0x177 Mana Counter\r\n")
        paths = {"root": root, "feature_list": features, "constants": constants, "strings": strings}
        return paths, features, constants, strings

    def test_archetype_add_derives_range_and_rejects_conflicts(self):
        official = {0x16e: "SET_ICEJADE", 0x4: "SET_AMAZONESS"}
        with tempfile.TemporaryDirectory() as directory:
            paths, features, constants, strings = self.archetype_fixture(Path(directory))
            before = (constants.read_bytes(), strings.read_bytes())
            with patch.object(harness, "get_project_paths", return_value=paths), \
                    patch.object(harness, "official_setcodes", return_value=official), \
                    contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                self.assertTrue(harness.add_archetype("Icejade", "0x16e"))
                self.assertFalse(harness.add_archetype("ice_jade", "0x999"), "trùng tên sau khi chuẩn hóa")
                self.assertFalse(harness.add_archetype("Other", "0x16e"), "trùng setcode")
                self.assertFalse(harness.add_archetype("Other", "0x999", "36600050-36600060"), "chồng range")
                self.assertFalse(harness.add_archetype("TooBig", "0xffff"), "passcode vượt 9 chữ số")
                self.assertFalse(harness.add_archetype("2Bad", "0x999"), "tên không hợp lệ")
                self.assertFalse(harness.add_archetype("Sub", "0x1004"), "cùng 12 bit thấp với SET_AMAZONESS")
                self.assertFalse(harness.add_archetype("Other", "0x789"), "setcode của SET_TTF trong constants.lua")
            archetypes = json.loads(features.read_text(encoding="utf-8"))["archetypes"]
            self.assertEqual(archetypes["Icejade"],
                             {"setcode": "0x16e", "passcode_range": "36600001-36699999", "cards": []})
            self.assertEqual(set(archetypes), {"Common", "Icejade"})
            # Archetype official đã có trong game nên không được ghi vào constants.lua/strings.conf.
            self.assertEqual((constants.read_bytes(), strings.read_bytes()), before)

    def test_archetype_add_picks_and_writes_fanmade_setcode(self):
        with tempfile.TemporaryDirectory() as directory:
            paths, features, constants, strings = self.archetype_fixture(Path(directory))
            with patch.object(harness, "get_project_paths", return_value=paths), \
                    patch.object(harness, "official_setcodes", return_value={0x4: "SET_AMAZONESS"}), \
                    contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                self.assertTrue(harness.add_archetype("Flow_Test"))
                self.assertTrue(harness.add_archetype("TTF"), "archetype đã có trong constants.lua thì dùng lại setcode")
            archetypes = json.loads(features.read_text(encoding="utf-8"))["archetypes"]
            # 0x780 (Atermis) và 0x781 (Cat) đã có người dùng nên setcode trống đầu tiên là 0x782.
            self.assertEqual(archetypes["Flow_Test"]["setcode"], "0x782")
            self.assertEqual(archetypes["TTF"]["setcode"], "0x789")
            self.assertEqual(constants.read_bytes(),
                             b"-- Custom Archetype\r\nSET_TTF = 0x789\r\nSET_ATERMIS = 0x780\r\n"
                             + b"SET_FLOW_TEST".ljust(34) + b"= 0x782\r\n"
                             b"-- Custom counter\r\nCOUNTER_MANA = 0x177\r\n")
            self.assertEqual(strings.read_bytes(),
                             b"#Custom Archetype\r\n!setname 0x789 TTF\r\n!setname 0x781 Cat\r\n"
                             b"!setname 0x782 Flow Test\r\n#Custom Counter\r\n!counter 0x177 Mana Counter\r\n")

    def test_start_rewrites_name_of_pending_card(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name in ("card-data", "script", "pics", "templates", "queues"):
                (root / name).mkdir()
            (root / "templates" / "template_normal_spell.lua").write_text(
                "-- <<CARD_NAME>> <<PASSCODE>> <<SETCODE>> <<ARCHETYPE_NAME>>\nlocal s,id=GetID()\n", encoding="utf-8")
            features = root / "feature_list.json"
            # scan suy tên từ tên file queue nên tên trong entry pending có thể sai chính tả.
            features.write_text(json.dumps({"archetypes": {"Icejade": {
                "setcode": "0x16e", "passcode_range": "36600001-36699999",
                "cards": [{"name": "Icejade Tremore", "passcode": "36600001", "status": "pending"}]}}}),
                encoding="utf-8")
            paths = {"root": root, "feature_list": features, "script_dir": root / "script",
                     "template_dir": root / "templates", "card_data": root / "card-data",
                     "queues_dir": root / "queues", "pics_dir": root / "pics"}
            with patch.object(harness, "get_project_paths", return_value=paths), contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                self.assertTrue(harness.start_card(36600001, "Icejade Tremora", "normal_spell"))
            card = json.loads(features.read_text(encoding="utf-8"))["archetypes"]["Icejade"]["cards"][0]
            self.assertEqual(card["name"], "Icejade Tremora")
            self.assertEqual(card["status"], "working")
            spec = json.loads((root / "card-data" / "c36600001.json").read_text(encoding="utf-8"))
            self.assertEqual(spec["name"], "Icejade Tremora")

    def test_scan_registers_queue_images_with_free_passcodes(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            queues = root / "queues"
            (queues / "ice_jade").mkdir(parents=True)
            (queues / "ice_jade" / "p_icejade_and_the_pillar_of_ice.jpg").write_bytes(b"art")
            (queues / "ice_jade" / "p_already_known.jpg").write_bytes(b"art")
            (queues / "p_lone_card.png").write_bytes(b"art")
            features = root / "feature_list.json"
            features.write_text(json.dumps({"archetypes": {
                "Common": {"cards": []},
                "IceJade": {"setcode": "0x16e", "passcode_range": "36600001-36600003", "cards": [
                    {"name": "Known", "passcode": "36600001", "status": "working",
                     "queue_file": "queues/ice_jade/w_already_known.jpg"}]}}}), encoding="utf-8")
            paths = {"root": root, "feature_list": features, "queues_dir": queues}
            # 36600002 đã có trong CDB khác nên scan phải bỏ qua dù feature_list chưa ghi.
            with patch.object(harness, "get_project_paths", return_value=paths), \
                    patch.object(harness.manage_db, "external_passcodes", return_value=({36600002}, None)), \
                    contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                self.assertTrue(harness.scan_pending_cards())
            archetypes = json.loads(features.read_text(encoding="utf-8"))["archetypes"]
            self.assertEqual(archetypes["IceJade"]["cards"][1:], [
                {"name": "Icejade & the Pillar of Ice", "passcode": "36600003", "status": "pending",
                 "queue_file": "queues/ice_jade/p_icejade_and_the_pillar_of_ice.jpg"}])
            self.assertEqual(archetypes["Common"]["cards"], [
                {"name": "Lone Card", "passcode": "79900001", "status": "pending", "queue_file": "queues/p_lone_card.png"}])

    def test_preflight_rejects_non_uppercase_placeholders(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name in ("card-data", "script", "pics"):
                (root / name).mkdir()
            paths = {"card_data": root / "card-data", "script_dir": root / "script", "pics_dir": root / "pics"}
            (paths["card_data"] / "c12345678.json").write_text(json.dumps({"desc": "Real effect text"}), encoding="utf-8")
            for placeholder in ("<<mixed123>>", "<<text with spaces>>", "<<>>", "<<UPPER_CASE>>"):
                with self.subTest(placeholder=placeholder):
                    (paths["script_dir"] / "c12345678.lua").write_text("-- " + placeholder, encoding="utf-8")
                    errors, _ = harness.preflight_card(paths, 12345678)
                    self.assertTrue(any(placeholder in error for error in errors), errors)

    def test_preflight_rejects_artwork_whose_extension_hides_its_format(self):
        # EDOPro đọc .jpg bằng libjpeg: ảnh PNG đặt đuôi .jpg làm game văng JPEG FATAL ERROR.
        png_bytes = b"\x89PNG\r\n\x1a\n" + b"\x00" * 16
        jpeg_bytes = b"\xff\xd8\xff\xe0" + b"\x00" * 16
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name in ("card-data", "script", "pics"):
                (root / name).mkdir()
            paths = {"card_data": root / "card-data", "script_dir": root / "script", "pics_dir": root / "pics"}
            (paths["card_data"] / "c12345678.json").write_text(json.dumps({"desc": "Real effect text"}), encoding="utf-8")
            (paths["script_dir"] / "c12345678.lua").write_text("local s,id=GetID()", encoding="utf-8")
            artwork = paths["pics_dir"] / "12345678.jpg"
            with patch.object(harness.normalize_images, "HAS_PIL", False):
                artwork.write_bytes(png_bytes)
                errors, _ = harness.preflight_card(paths, 12345678)
                self.assertTrue(any("12345678.jpg" in error and "PNG" in error for error in errors), errors)
                artwork.write_bytes(jpeg_bytes)
                errors, _ = harness.preflight_card(paths, 12345678)
                self.assertEqual(errors, [])

    def test_sync_failure_prevents_status_and_queue_changes(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            queue = root / "w_test.png"
            queue.write_bytes(b"test-artwork")
            features = root / "feature_list.json"
            features.write_text(json.dumps({"archetypes": {"Test": {"cards": [{"passcode": "12345678", "status": "working", "queue_file": queue.name}]}}}), encoding="utf-8")
            original = features.read_bytes()
            # No output text to parse: the nonzero process exit status alone must block.
            responses = [(0, "", ""), (0, "", ""), (1, "", "sync failed")]
            with patch.object(harness, "get_project_paths", return_value={"root": root, "feature_list": features}), patch.object(harness, "preflight_card", return_value=([], [])), patch.object(harness, "run_command", side_effect=responses) as run, contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                self.assertFalse(harness.verify_card(12345678))
                self.assertEqual(run.call_count, 3)
            self.assertEqual(features.read_bytes(), original)
            self.assertTrue(queue.exists())
            self.assertFalse((root / "d_test.png").exists())

    def test_verify_copies_artwork_then_deletes_queue_image(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "pics").mkdir()
            queue = root / "w_test.png"
            queue.write_bytes(b"test-artwork")
            features = root / "feature_list.json"
            features.write_text(json.dumps({"archetypes": {"Test": {"cards": [{"passcode": "12345678", "status": "working", "queue_file": queue.name}]}}}), encoding="utf-8")
            paths = {"root": root, "feature_list": features, "pics_dir": root / "pics"}
            with patch.object(harness, "get_project_paths", return_value=paths), patch.object(harness, "preflight_card", return_value=([], [])), patch.object(harness, "run_command", return_value=(0, "", "")), contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                self.assertTrue(harness.verify_card(12345678))
            # Ảnh queue chỉ được xóa sau khi bản copy trong pics/ đọc lại đúng nội dung.
            self.assertEqual((root / "pics" / "12345678.png").read_bytes(), b"test-artwork")
            self.assertFalse(queue.exists())
            card = json.loads(features.read_text(encoding="utf-8"))["archetypes"]["Test"]["cards"][0]
            self.assertEqual(card["status"], "done")
            self.assertNotIn("queue_file", card)

    def test_queue_image_survives_when_artwork_cannot_be_confirmed(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "pics").mkdir()
            # EDOPro không nạp .gif nên không thể copy sang pics/ — ảnh queue phải được giữ.
            queue = root / "w_test.gif"
            queue.write_bytes(b"test-artwork")
            deleted, _ = harness.retire_queue_image({"root": root, "pics_dir": root / "pics"}, 12345678, queue)
            self.assertFalse(deleted)
            self.assertTrue(queue.exists())
            self.assertEqual(list((root / "pics").iterdir()), [])

    def test_cleanup_requires_artwork_and_apply_flag(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            queues = root / "docs" / "queues" / "Test"
            queues.mkdir(parents=True)
            pics = root / "pics"
            pics.mkdir()
            copied = queues / "d_copied.jpg"
            copied.write_bytes(b"artwork")
            uncopied = queues / "d_uncopied.jpg"
            uncopied.write_bytes(b"artwork")
            (pics / "11111111.jpg").write_bytes(b"artwork")
            features = root / "feature_list.json"
            features.write_text(json.dumps({"archetypes": {"Test": {"cards": [
                # feature_list còn ghi tiền tố 'w_' trong khi đĩa đã đổi sang 'd_'
                {"passcode": "11111111", "status": "done", "queue_file": "docs/queues/Test/w_copied.jpg"},
                {"passcode": "22222222", "status": "done", "queue_file": "docs/queues/Test/d_uncopied.jpg"},
            ]}}}), encoding="utf-8")
            paths = {"root": root, "feature_list": features, "queues_dir": root / "docs" / "queues", "pics_dir": pics}
            with patch.object(harness, "get_project_paths", return_value=paths), contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                self.assertTrue(harness.cleanup_queue())
                self.assertTrue(copied.exists(), "dry-run không được xóa file")
                self.assertTrue(harness.cleanup_queue(apply_changes=True))
            self.assertFalse(copied.exists())
            self.assertTrue(uncopied.exists(), "chưa có artwork trong pics/ thì phải giữ ảnh queue")
            cards = json.loads(features.read_text(encoding="utf-8"))["archetypes"]["Test"]["cards"]
            self.assertNotIn("queue_file", cards[0])
            self.assertIn("queue_file", cards[1])

    def test_cleanup_drops_refs_to_missing_images(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            queues = root / "docs" / "queues" / "Test"
            queues.mkdir(parents=True)
            pics = root / "pics"
            pics.mkdir()
            kept = queues / "w_present.jpg"
            kept.write_bytes(b"artwork")
            features = root / "feature_list.json"
            features.write_text(json.dumps({"archetypes": {"Test": {"cards": [
                # Ảnh đã bị gỡ khỏi repo, ref còn lại chỉ là rác
                {"passcode": "11111111", "status": "done", "queue_file": "docs/queues/Test/d_gone.jpg"},
                {"passcode": "22222222", "status": "pending", "queue_file": "docs/queues/Test/d_present.jpg"},
            ]}}}), encoding="utf-8")
            paths = {"root": root, "feature_list": features, "queues_dir": root / "docs" / "queues", "pics_dir": pics}
            with patch.object(harness, "get_project_paths", return_value=paths), contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                self.assertTrue(harness.cleanup_queue())
                unchanged = json.loads(features.read_text(encoding="utf-8"))["archetypes"]["Test"]["cards"]
                self.assertIn("queue_file", unchanged[0], "dry-run không được sửa feature_list")
                self.assertTrue(harness.cleanup_queue(apply_changes=True))
            cards = json.loads(features.read_text(encoding="utf-8"))["archetypes"]["Test"]["cards"]
            self.assertNotIn("queue_file", cards[0])
            self.assertIn("queue_file", cards[1], "ref chỉ lệch tiền tố trạng thái không phải rác")
            self.assertTrue(kept.exists())


@unittest.skipUnless(shutil.which("git"), "Git is required to tell tracked images apart")
class CleanupGitTrackingTests(unittest.TestCase):
    def git(self, root, *args):
        subprocess.run(["git", "-c", "user.email=test@example.com", "-c", "user.name=Test", *args],
                       cwd=root, capture_output=True, check=True)

    def test_cleanup_marks_images_git_cannot_restore(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            queues = root / "docs" / "queues" / "Test"
            queues.mkdir(parents=True)
            pics = root / "pics"
            pics.mkdir()
            for stem, passcode in (("d_tracked", "11111111"), ("d_untracked", "22222222")):
                (queues / f"{stem}.jpg").write_bytes(b"artwork")
                (pics / f"{passcode}.jpg").write_bytes(b"artwork")
            self.git(root, "init")
            self.git(root, "add", "docs/queues/Test/d_tracked.jpg")
            self.git(root, "commit", "-m", "track one image")
            features = root / "feature_list.json"
            features.write_text(json.dumps({"archetypes": {"Test": {"cards": [
                {"passcode": "11111111", "status": "done", "queue_file": "docs/queues/Test/d_tracked.jpg"},
                {"passcode": "22222222", "status": "done", "queue_file": "docs/queues/Test/d_untracked.jpg"},
            ]}}}), encoding="utf-8")
            paths = {"root": root, "feature_list": features, "queues_dir": root / "docs" / "queues", "pics_dir": pics}
            output = io.StringIO()
            with patch.object(harness, "get_project_paths", return_value=paths), contextlib.redirect_stdout(output), contextlib.redirect_stderr(io.StringIO()):
                self.assertTrue(harness.cleanup_queue())
            # Ảnh chưa commit xóa là mất hẳn; ảnh đã commit vẫn còn trong history.
            lines = {name: [line for line in output.getvalue().splitlines() if name in line]
                     for name in ("d_tracked.jpg", "d_untracked.jpg")}
            self.assertTrue(all("CHƯA COMMIT" in line for line in lines["d_untracked.jpg"]), lines)
            self.assertTrue(all("CHƯA COMMIT" not in line for line in lines["d_tracked.jpg"]), lines)


@unittest.skipUnless(POWERSHELL, "PowerShell is required for validator integration tests")
class LuaParserRegressionTests(unittest.TestCase):
    def run_validator(self, path, env=None):
        return subprocess.run(
            [POWERSHELL, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(TOOLS / "validate_scripts.ps1"), "-Path", str(path)],
            cwd=ROOT, env=env, capture_output=True, text=True, errors="replace", timeout=30,
        )

    @unittest.skipUnless(shutil.which("lua"), "Lua is required for actual syntax checks")
    def test_valid_and_invalid_lua_with_quoted_path(self):
        with tempfile.TemporaryDirectory(prefix="ttf-parser-'") as directory:
            path = Path(directory) / "c12345678.lua"
            valid = "local s,id=GetID()\nfunction s.initial_effect(c)\n c:RegisterEffect(nil)\nend\n"
            for content, expected in ((valid, 0), (valid + "this is invalid lua\n", 1)):
                with self.subTest(expected_exit=expected):
                    path.write_text(content, encoding="utf-8")
                    result = self.run_validator(path)
                    self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
                    if expected:
                        self.assertIn("SYNTAX:", result.stdout)

    def test_missing_lua_cannot_report_success(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "c12345678.lua"
            path.write_text("local s,id=GetID()", encoding="utf-8")
            env = os.environ.copy()
            env["PATH"] = ""
            result = self.run_validator(path, env=env)
            self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
            self.assertIn("Lua parser not found", result.stdout)


@unittest.skipUnless(POWERSHELL, "PowerShell is required for validator integration tests")
class ValidatorReferenceTests(unittest.TestCase):
    """Tên không tồn tại trong EDOPro chỉ là nil lúc chạy, cú pháp Lua vẫn hợp lệ,
    nên validator phải chặn bằng danh sách sinh từ bản cài game."""

    CLEAN = 'local s,id=GetID()\nlocal COUNTER_CUSTOM=0x1\nfunction s.initial_effect(c)\n\tlocal e1=Effect.CreateEffect(c)\n\te1:SetType(EFFECT_TYPE_ACTIVATE)\n\te1:SetCode(EVENT_FREE_CHAIN)\n\te1:SetOperation(s.activate)\n\tc:RegisterEffect(e1)\nend\nfunction s.activate(e,tp,eg,ep,ev,re,r,rp)\n\tDuel.Draw(tp,COUNTER_CUSTOM,REASON_EFFECT)\nend\n'
    BAD_CONST = 'local s,id=GetID()\nfunction s.initial_effect(c)\n\tlocal e1=Effect.CreateEffect(c)\n\te1:SetType(EFFECT_TYPE_ACTIVATE)\n\te1:SetCode(EVENT_FREE_CHAIN)\n\te1:SetCategory(CATEGORY_TOTALLY_NOT_REAL)\n\tc:RegisterEffect(e1)\nend\n'
    BAD_API = 'local s,id=GetID()\nfunction s.initial_effect(c)\n\tlocal e1=Effect.CreateEffect(c)\n\te1:SetType(EFFECT_TYPE_ACTIVATE)\n\te1:SetCode(EVENT_FREE_CHAIN)\n\te1:SetTarget(Card.IsTotallyNotReal)\n\tc:RegisterEffect(e1)\nend\n'
    WARN_ONLY = 'local s,id=GetID()\nfunction s.initial_effect(c)\n\tlocal e1=Effect.CreateEffect(c)\n\te1:SetType(EFFECT_TYPE_ACTIVATE)\n\te1:SetCode(EVENT_FREE_CHAIN)\n\te1:SetTarget(s.target)\n\tc:RegisterEffect(e1)\nend\nfunction s.target(e,tp,eg,ep,ev,re,r,rp,chk)\n\treturn true\nend\n'

    def run_validator(self, content, quiet=False):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "c12345678.lua"
            path.write_text(content, encoding="utf-8")
            command = [POWERSHELL, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
                       str(TOOLS / "validate_scripts.ps1"), "-Path", str(path)]
            if quiet:
                command.append("-Quiet")
            return subprocess.run(command, cwd=ROOT, capture_output=True, text=True,
                                  errors="replace", timeout=60)

    def test_clean_script_passes(self):
        result = self.run_validator(self.CLEAN)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertNotIn("CONST:", result.stdout)
        self.assertNotIn("API:", result.stdout)

    def test_unknown_constant_fails(self):
        result = self.run_validator(self.BAD_CONST)
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertIn("CATEGORY_TOTALLY_NOT_REAL", result.stdout)

    def test_unknown_api_fails(self):
        result = self.run_validator(self.BAD_API)
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertIn("Card.IsTotallyNotReal", result.stdout)

    def test_quiet_does_not_count_warnings_as_ok(self):
        result = self.run_validator(self.WARN_ONLY, quiet=True)
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertIn("1 WARN", result.stdout)
        self.assertIn("0 OK", result.stdout)


if __name__ == "__main__":
    unittest.main()
