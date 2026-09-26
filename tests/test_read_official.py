import os
import shutil
import sqlite3
import tempfile
import unittest
from pathlib import Path

from tools.read_official import (
    TYPE_COUNTER,
    TYPE_EFFECT,
    TYPE_LINK,
    TYPE_MONSTER,
    TYPE_NORMAL,
    TYPE_QUICKPLAY,
    TYPE_SPELL,
    TYPE_TRAP,
    TYPE_TUNER,
    collect_cdb_paths,
    collect_script_roots,
    find_script_in_roots,
    format_card_stats,
    format_card_type,
    is_normal_monster,
    main,
    parse_targets,
    query_card_info,
    read_single_card,
    resolve_game_dir,
    search_cards_by_name,
    search_cards_by_text,
)


class TestReadOfficial(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.game_dir = Path(self.temp_dir) / "Game"
        self.game_dir.mkdir(parents=True)
        self.dest_dir = Path(self.temp_dir) / "docs" / "official-reference"

    def tearDown(self):
        shutil.rmtree(self.temp_dir, ignore_errors=True)

    def _create_mock_cdb(self, cdb_path, cards_data):
        """Tạo file CDB SQLite giả lập với các bảng datas và texts."""
        cdb_path.parent.mkdir(parents=True, exist_ok=True)
        conn = sqlite3.connect(str(cdb_path))
        cur = conn.cursor()
        cur.execute(
            """
            CREATE TABLE datas (
                id INTEGER PRIMARY KEY,
                ot INTEGER,
                alias INTEGER,
                setcode INTEGER,
                type INTEGER,
                atk INTEGER,
                def INTEGER,
                level INTEGER,
                race INTEGER,
                attribute INTEGER,
                category INTEGER
            )
            """
        )
        cur.execute(
            """
            CREATE TABLE texts (
                id INTEGER PRIMARY KEY,
                name TEXT,
                desc TEXT,
                str1 TEXT, str2 TEXT, str3 TEXT, str4 TEXT, str5 TEXT, str6 TEXT, str7 TEXT, str8 TEXT,
                str9 TEXT, str10 TEXT, str11 TEXT, str12 TEXT, str13 TEXT, str14 TEXT, str15 TEXT, str16 TEXT
            )
            """
        )
        for c in cards_data:
            cur.execute(
                "INSERT INTO datas VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                (
                    c["id"],
                    c.get("ot", 1),
                    c.get("alias", 0),
                    c.get("setcode", 0),
                    c.get("type", 0),
                    c.get("atk", 0),
                    c.get("def", 0),
                    c.get("level", 0),
                    c.get("race", 0),
                    c.get("attribute", 0),
                    c.get("category", 0),
                ),
            )
            str_cols = [c.get(f"str{i}", "") for i in range(1, 17)]
            cur.execute(
                "INSERT INTO texts VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                (c["id"], c.get("name", ""), c.get("desc", ""), *str_cols),
            )
        conn.commit()
        conn.close()

    def test_resolve_game_dir(self):
        # 1. Explicit directory
        self.assertEqual(resolve_game_dir(str(self.game_dir)), self.game_dir.resolve())
        with self.assertRaises(FileNotFoundError):
            resolve_game_dir(str(self.game_dir / "nonexistent"))

        # 2. Environment variable
        old_env = os.environ.get("EDOPRO_DIR")
        try:
            os.environ["EDOPRO_DIR"] = str(self.game_dir)
            self.assertEqual(resolve_game_dir(), self.game_dir.resolve())
        finally:
            if old_env is not None:
                os.environ["EDOPRO_DIR"] = old_env
            else:
                os.environ.pop("EDOPRO_DIR", None)

    def test_collect_script_roots_priority(self):
        # Tạo delta-bagooska script và base script
        delta_script = self.game_dir / "repositories" / "delta-bagooska" / "script"
        delta_script.mkdir(parents=True)
        base_script = self.game_dir / "script"
        base_script.mkdir(parents=True)

        roots = collect_script_roots(self.game_dir)
        self.assertEqual(len(roots), 2)
        # Delta-bagooska phải đứng trước base script
        self.assertEqual(roots[0], delta_script.resolve())
        self.assertEqual(roots[1], base_script.resolve())

    def test_find_script_in_roots(self):
        delta_script = self.game_dir / "repositories" / "delta-bagooska" / "script" / "official"
        delta_script.mkdir(parents=True)
        base_script = self.game_dir / "script" / "official"
        base_script.mkdir(parents=True)

        # Card 123456 có ở cả hai nơi -> delta-bagooska thắng
        (delta_script / "c123456.lua").write_text("-- delta version", encoding="utf-8")
        (base_script / "c123456.lua").write_text("-- base version", encoding="utf-8")

        # Card 789 chỉ có ở base script
        (base_script / "c789.lua").write_text("-- base only", encoding="utf-8")

        roots = collect_script_roots(self.game_dir)

        found_123456 = find_script_in_roots(123456, roots)
        self.assertIsNotNone(found_123456)
        self.assertEqual(found_123456.read_text(encoding="utf-8"), "-- delta version")

        found_789 = find_script_in_roots(789, roots)
        self.assertIsNotNone(found_789)
        self.assertEqual(found_789.read_text(encoding="utf-8"), "-- base only")

        self.assertIsNone(find_script_in_roots(999999, roots))

    def test_collect_cdb_paths(self):
        delta_cdb = self.game_dir / "repositories" / "delta-bagooska" / "cards.delta.cdb"
        exp_cdb = self.game_dir / "expansions" / "cards.cdb"
        custom_cdb = self.game_dir / "repositories" / "custom_cards_zesty" / "custom.cdb"

        self._create_mock_cdb(delta_cdb, [])
        self._create_mock_cdb(exp_cdb, [])
        self._create_mock_cdb(custom_cdb, [])

        cdbs = collect_cdb_paths(self.game_dir)
        self.assertIn(delta_cdb.resolve(), cdbs)
        self.assertIn(exp_cdb.resolve(), cdbs)
        # Không được chứa custom_cards_zesty
        self.assertNotIn(custom_cdb.resolve(), cdbs)

    def test_query_card_info_and_search(self):
        delta_cdb = self.game_dir / "repositories" / "delta-bagooska" / "cards.delta.cdb"
        cards = [
            {
                "id": 14558127,
                "name": "Ash Blossom & Joyous Spring",
                "desc": "When a card or effect is activated...",
                "type": TYPE_MONSTER | TYPE_EFFECT | TYPE_TUNER,
                "atk": 0,
                "def": 1800,
                "level": 3,
                "race": 0x10,  # Zombie
                "attribute": 0x04,  # FIRE
                "str1": "Negate effect",
            },
            {
                "id": 89631139,
                "name": "Blue-Eyes White Dragon",
                "desc": "This legendary dragon is a powerful engine of destruction.",
                "type": TYPE_MONSTER | TYPE_NORMAL,
                "atk": 3000,
                "def": 2500,
                "level": 8,
                "race": 0x2000,  # Dragon
                "attribute": 0x10,  # LIGHT
            },
        ]
        self._create_mock_cdb(delta_cdb, cards)
        cdb_paths = [delta_cdb]

        info = query_card_info(14558127, cdb_paths)
        self.assertIsNotNone(info)
        self.assertEqual(info["name"], "Ash Blossom & Joyous Spring")
        self.assertEqual(info["strings"], ["Negate effect"])
        self.assertEqual(info["atk"], 0)
        self.assertEqual(info["def"], 1800)

        # Search by name
        matches = search_cards_by_name("Blossom", cdb_paths)
        self.assertEqual(len(matches), 1)
        self.assertEqual(matches[0]["id"], 14558127)

        matches_dragon = search_cards_by_name("Dragon", cdb_paths)
        self.assertEqual(len(matches_dragon), 1)
        self.assertEqual(matches_dragon[0]["id"], 89631139)

    def test_search_cards_by_text_requires_every_phrase(self):
        cdb = self.game_dir / "expansions" / "cards.cdb"
        search = 'If this card is Normal or Special Summoned: You can add 1 "X" Spell/Trap from your Deck to your hand.'
        self._create_mock_cdb(cdb, [
            {"id": 1, "name": "Long Searcher", "type": TYPE_MONSTER | TYPE_EFFECT,
             "desc": search + " You can only use this effect of \"Long Searcher\" once per turn. Also more text."},
            {"id": 2, "name": "Short Searcher", "type": TYPE_MONSTER | TYPE_EFFECT, "desc": search},
            {"id": 3, "name": "Short Searcher", "alias": 2, "type": TYPE_MONSTER | TYPE_EFFECT, "desc": search},
            {"id": 4, "name": "Monster Searcher", "type": TYPE_MONSTER | TYPE_EFFECT,
             "desc": "If this card is Normal Summoned: You can add 1 monster from your Deck to your hand."},
        ])
        matches = search_cards_by_text(["if this card is normal or special summoned", "Spell/Trap from your Deck"], [cdb])
        # Không phân biệt hoa thường, bỏ reprint (alias), text ngắn đứng trước.
        self.assertEqual([m["id"] for m in matches], [2, 1])

    def test_format_card_type_and_stats(self):
        # Monster Effect Tuner
        t_tuner = TYPE_MONSTER | TYPE_EFFECT | TYPE_TUNER
        self.assertEqual(format_card_type(t_tuner), "Monster / Effect / Tuner")

        # Quick-Play Spell
        t_qp = TYPE_SPELL | TYPE_QUICKPLAY
        self.assertEqual(format_card_type(t_qp), "Spell / Quick-Play")

        # Counter Trap
        t_counter = TYPE_TRAP | TYPE_COUNTER
        self.assertEqual(format_card_type(t_counter), "Trap / Counter")

        # Stats for Normal Monster
        card_info = {
            "type": TYPE_MONSTER | TYPE_NORMAL,
            "atk": 3000,
            "def": 2500,
            "level": 8,
            "race": 0x2000,
            "attribute": 0x10,
        }
        stats = format_card_stats(card_info)
        self.assertIn("Level 8", stats)
        self.assertIn("LIGHT / Dragon", stats)
        self.assertIn("ATK: 3000 / DEF: 2500", stats)

        # Link Monster
        link_info = {
            "type": TYPE_MONSTER | TYPE_EFFECT | TYPE_LINK,
            "atk": 2300,
            "def": 0xAA,  # Top, Bottom, Left, Right
            "level": 4,
            "race": 0x1000000,
            "attribute": 0x20,
        }
        link_stats = format_card_stats(link_info)
        self.assertIn("Link-4", link_stats)
        self.assertIn("Cyberse", link_stats)
        self.assertIn("Markers: [Bottom, Left, Right, Top]", link_stats)

    def test_is_normal_monster(self):
        self.assertTrue(is_normal_monster(TYPE_MONSTER | TYPE_NORMAL))
        self.assertFalse(is_normal_monster(TYPE_MONSTER | TYPE_EFFECT))
        self.assertFalse(is_normal_monster(TYPE_SPELL))

    def test_read_single_card_and_copy(self):
        # Tạo mock script và mock cdb
        script_dir = self.game_dir / "script" / "official"
        script_dir.mkdir(parents=True)
        (script_dir / "c14558127.lua").write_text("-- ash script", encoding="utf-8")

        delta_cdb = self.game_dir / "repositories" / "delta-bagooska" / "cards.delta.cdb"
        self._create_mock_cdb(
            delta_cdb,
            [
                {
                    "id": 14558127,
                    "name": "Ash Blossom",
                    "desc": "Negate something.",
                    "type": TYPE_MONSTER | TYPE_EFFECT,
                    "atk": 0,
                    "def": 1800,
                    "level": 3,
                    "race": 0x10,
                    "attribute": 0x04,
                }
            ],
        )

        # Đọc và copy vào dest_dir
        read_single_card(14558127, self.game_dir, self.dest_dir, copy_script=True)

        copied_file = self.dest_dir / "c14558127.lua"
        self.assertTrue(copied_file.is_file())
        self.assertEqual(copied_file.read_text(encoding="utf-8"), "-- ash script")

    def test_parse_targets(self):
        self.assertEqual(parse_targets(["123, 456", "789"]), ["123", "456", "789"])
        self.assertEqual(parse_targets(["Ash Blossom"]), ["Ash", "Blossom"])

    def test_cli_execution(self):
        script_dir = self.game_dir / "script" / "official"
        script_dir.mkdir(parents=True)
        (script_dir / "c55144522.lua").write_text("-- pot of greed", encoding="utf-8")

        delta_cdb = self.game_dir / "repositories" / "delta-bagooska" / "cards.delta.cdb"
        self._create_mock_cdb(
            delta_cdb,
            [
                {
                    "id": 55144522,
                    "name": "Pot of Greed",
                    "desc": "Draw 2 cards.",
                    "type": TYPE_SPELL,
                    "atk": 0,
                    "def": 0,
                    "level": 0,
                    "race": 0,
                    "attribute": 0,
                }
            ],
        )

        exit_code = main(
            [
                "55144522",
                "--game-dir",
                str(self.game_dir),
                "--dest-dir",
                str(self.dest_dir),
            ]
        )
        self.assertEqual(exit_code, 0)
        self.assertTrue((self.dest_dir / "c55144522.lua").is_file())


if __name__ == "__main__":
    unittest.main()
