import contextlib
import io
import json
from pathlib import Path
import sqlite3
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / "tools"
sys.path.insert(0, str(TOOLS))
import manage_db as db


class DatabaseTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        # Test không được phụ thuộc bản cài EDOPro của máy chạy: trỏ sang thư
        # mục không tồn tại để chỉ còn CDB trong temp root được đối chiếu.
        env = patch.dict("os.environ", {"EDOPRO_DIR": str(self.root / "no-edopro")})
        env.start()
        self.addCleanup(env.stop)
        (self.root / "card-data").mkdir()
        (self.root / "script").mkdir()
        self.spec = {"id": 123, "type": 2, "name": "Owned", "desc": "Draw a card."}
        self.write_spec()
        (self.root / "script/c123.lua").write_text("local s,id=GetID()")
        (self.root / "feature_list.json").write_text(json.dumps({"archetypes": {"A": {"cards": [
            {"passcode": "123", "status": "done"}, {"passcode": "555", "status": "pending"}]}}}))
        self.luna = self.root / "card-data.cdb"

    def write_spec(self):
        (self.root / "card-data/c123.json").write_text(json.dumps(self.spec))

    def test_bitfields_accept_names(self):
        errors = []
        cols = db.normalize_card({"id": 1, "type": ["Monster", "Effect", "Tuner"], "race": "warrior",
                                  "attribute": "LIGHT", "category": ["Search", "Send to Hand", "0x1"]}, errors)
        self.assertEqual(errors, [])
        self.assertEqual((cols["type"], cols["race"], cols["attribute"], cols["category"]),
                         (0x1021, 0x1, 0x10, 0x200 | 0x20 | 0x1))
        # Tên trong ngoặc được nhận khi không trùng dòng khác.
        self.assertEqual(db.normalize_card({"id": 1, "type": ["Monster", "Gemini"]}, errors)["type"], 0x801)
        db.normalize_card({"id": 1, "race": "Dragonn"}, errors)
        self.assertEqual(len(errors), 1)
        self.assertIn("RACES", errors[0])

    def test_invalid_spec_and_unknown_ids_do_not_overwrite(self):
        self.assertTrue(db.compile_db(self.luna))
        before = self.luna.read_bytes()
        self.spec["type"] = 0
        self.write_spec()
        self.assertFalse(db.compile_db(self.luna))
        self.assertEqual(before, self.luna.read_bytes())
        self.spec["type"] = 2
        self.write_spec()
        with contextlib.closing(sqlite3.connect(self.luna)) as conn, conn:
            conn.execute("INSERT INTO texts (id,name) VALUES (999,'Orphan')")
        before = self.luna.read_bytes()
        self.assertFalse(db.compile_db(self.luna))
        self.assertEqual(before, self.luna.read_bytes())

    def test_sync_stale_exit_and_pending_legacy(self):
        self.assertTrue(db.compile_db(self.luna))
        (self.root / "script/c777.lua").write_text("-- legacy")
        self.assertTrue(db.check_sync(self.luna))
        self.spec["name"] = "Changed"
        self.write_spec()
        self.assertFalse(db.check_sync(self.luna))
        command = "import sys; sys.path.insert(0, sys.argv[1]); import manage_db; from pathlib import Path; manage_db.get_db_path=lambda: Path(sys.argv[2]); sys.argv=['manage_db','check-sync']; manage_db.main()"
        result = subprocess.run([sys.executable, "-c", command, str(TOOLS), str(self.luna)], capture_output=True)
        self.assertEqual(result.returncode, 1)
        self.assertTrue(db.compile_db(self.luna))
        with contextlib.closing(sqlite3.connect(self.luna)) as conn, conn:
            conn.execute("DELETE FROM texts")
        self.assertFalse(db.check_sync(self.luna))

    def test_passcode_collision_blocks_validate_and_compile(self):
        # ID trùng ở CDB khác làm EDOPro nạp nhầm card mà không báo gì. Tên CDB
        # tùy ý: mọi *.cdb ở gốc repo đều phải được đối chiếu.
        sibling = self.root / "New Community.cdb"
        with contextlib.closing(sqlite3.connect(sibling)) as conn, conn:
            conn.execute("CREATE TABLE datas (id INTEGER PRIMARY KEY)")
            conn.execute("INSERT INTO datas VALUES (123)")
        with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            self.assertFalse(db.validate_specs(self.luna))
            self.assertFalse(db.compile_db(self.luna))
            self.assertFalse(self.luna.exists(), "CDB không được ghi khi passcode trùng")
            with contextlib.closing(sqlite3.connect(sibling)) as conn, conn:
                conn.execute("DELETE FROM datas WHERE id=123")
            self.assertTrue(db.compile_db(self.luna))


if __name__ == "__main__":
    unittest.main()
