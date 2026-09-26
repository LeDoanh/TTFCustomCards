#!/usr/bin/env python3
"""TTF Card Database CLI Manager.

Compiler/validator cho card-data.cdb, mô phỏng theo chuẩn của
Datacorn (https://github.com/ProjectIgnis/Datacorn) - trình editor CDB chính thức của
ProjectIgnis - về schema, bitfield và cách đóng gói dữ liệu:
  - Schema datas/texts + PRAGMA page_size=4096 giống Datacorn tạo DB mới.
  - setcode: tối đa 4 setcode 16-bit đóng gói trong 1 số 64-bit.
  - level: (level & 0x800000FF) | (lscale << 24) | (rscale << 16).
  - Link monster: cột def chứa bitfield link marker, không phải DEF.
  - ATK/DEF "?" được lưu là -2 (QMARK_ATK_DEF).
Mọi spec JSON đều được validate trước khi ghi; compile là atomic
(ghi ra file tạm, chỉ thay thế CDB cũ khi toàn bộ spec hợp lệ).
"""
import sqlite3
import argparse
import sys
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')
if hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8')
import re
import json
import os
from pathlib import Path

# ============================================================
# Bitfield tables (theo Datacorn: src/gui/database_editor_widget.cpp)
# ============================================================

TYPES = {
    0x1: "Monster", 0x2: "Spell", 0x4: "Trap", 0x10: "Normal", 0x20: "Effect",
    0x40: "Fusion", 0x80: "Ritual", 0x100: "Trap Monster", 0x200: "Spirit",
    0x400: "Union", 0x800: "Dual (Gemini)", 0x1000: "Tuner", 0x2000: "Synchro",
    0x4000: "Token", 0x8000: "Maximum (Rush)",
    0x10000: "Quick-Play", 0x20000: "Continuous", 0x40000: "Equip", 0x80000: "Field",
    0x100000: "Counter", 0x200000: "Flip", 0x400000: "Toon", 0x800000: "Xyz",
    0x1000000: "Pendulum", 0x2000000: "Special Summon", 0x4000000: "Link",
    0x8000000: "Skill", 0x10000000: "Action", 0x20000000: "Plus (Rush)",
    0x40000000: "Minus (Rush)", 0x80000000: "Armor (Rush)",
}

ATTRIBUTES = {
    0x1: "EARTH", 0x2: "WATER", 0x4: "FIRE", 0x8: "WIND", 0x10: "LIGHT",
    0x20: "DARK", 0x40: "DIVINE",
}

RACES = {
    0x1: "Warrior", 0x2: "Spellcaster", 0x4: "Fairy", 0x8: "Fiend", 0x10: "Zombie",
    0x20: "Machine", 0x40: "Aqua", 0x80: "Pyro", 0x100: "Rock", 0x200: "Winged Beast",
    0x400: "Plant", 0x800: "Insect", 0x1000: "Thunder", 0x2000: "Dragon",
    0x4000: "Beast", 0x8000: "Beast-Warrior", 0x10000: "Dinosaur", 0x20000: "Fish",
    0x40000: "Sea Serpent", 0x80000: "Reptile", 0x100000: "Psychic",
    0x200000: "Divine-Beast", 0x400000: "Creator God", 0x800000: "Wyrm",
    0x1000000: "Cyberse", 0x2000000: "Illusion", 0x4000000: "Cyborg (Rush)",
    0x8000000: "Magical Knight (Rush)", 0x10000000: "High Dragon (Rush)",
    0x20000000: "Omega Psychic (Rush)", 0x40000000: "Celestial Warrior (Rush)",
    0x80000000: "Galaxy (Rush)",
}

SCOPES = {
    0x1: "OCG", 0x2: "TCG", 0x4: "Anime", 0x8: "Illegal", 0x10: "Video Game",
    0x20: "Custom", 0x40: "Speed", 0x100: "Pre-Release", 0x200: "Rush",
    0x400: "Legend", 0x1000: "Hidden",
}

CATEGORIES = {
    0x1: "Destroy Monster", 0x2: "Destroy S/T", 0x4: "Destroy Deck",
    0x8: "Destroy Hand", 0x10: "Send to GY", 0x20: "Send to Hand",
    0x40: "Send to Deck", 0x80: "Banish", 0x100: "Draw", 0x200: "Search",
    0x400: "Change ATK/DEF", 0x800: "Change Level/Rank", 0x1000: "Position",
    0x2000: "Piercing", 0x4000: "Direct Attack", 0x8000: "Multi Attack",
    0x10000: "Negate Activation", 0x20000: "Negate Effect", 0x40000: "Damage LP",
    0x80000: "Recover LP", 0x100000: "Special Summon", 0x200000: "Non-effect-related",
    0x400000: "Token-related", 0x800000: "Fusion-related", 0x1000000: "Ritual-related",
    0x2000000: "Synchro-related", 0x4000000: "Xyz-related", 0x8000000: "Link-related",
    0x10000000: "Counter-related", 0x20000000: "Gamble", 0x40000000: "Control",
    0x80000000: "Move Zones",
}

LINK_MARKERS = {
    0x1: "Bottom-Left", 0x2: "Bottom", 0x4: "Bottom-Right", 0x8: "Left",
    0x20: "Right", 0x40: "Top-Left", 0x80: "Top", 0x100: "Top-Right",
}
LINK_MARKER_NAMES = {v.lower(): k for k, v in LINK_MARKERS.items()}

TYPE_VALID_MASK = sum(TYPES)
RACE_VALID_MASK = sum(RACES)
ATTRIBUTE_VALID_MASK = sum(ATTRIBUTES)
SCOPE_VALID_MASK = sum(SCOPES)
CATEGORY_VALID_MASK = sum(CATEGORIES)
LINK_MARKER_MASK = sum(LINK_MARKERS)

TYPE_MONSTER = 0x1
TYPE_SPELL = 0x2
TYPE_TRAP = 0x4
TYPE_XYZ = 0x800000
TYPE_PENDULUM = 0x1000000
TYPE_LINK = 0x4000000
QMARK_ATK_DEF = -2          # Datacorn: constexpr qint32 QMARK_ATK_DEF = -2
OT_CUSTOM = 0x20            # Quy tắc project: ot luôn = 32 (Custom)
MAX_SETCODES = 4            # Giới hạn schema: 4 x 16-bit trong 1 INTEGER 64-bit
LEVEL_BASE_MASK = 0x800000FF  # Datacorn: dbLevel & 0x800000FF

# Schema chuẩn (giống Datacorn: src/gui/main_window.cpp)
SQL_CREATE_DATAS = """
    CREATE TABLE "datas" (
        "id"        INTEGER,
        "ot"        INTEGER,
        "alias"     INTEGER,
        "setcode"   INTEGER,
        "type"      INTEGER,
        "atk"       INTEGER,
        "def"       INTEGER,
        "level"     INTEGER,
        "race"      INTEGER,
        "attribute" INTEGER,
        "category"  INTEGER,
        PRIMARY KEY("id")
    )
"""
SQL_CREATE_TEXTS = """
    CREATE TABLE "texts" (
        "id"    INTEGER,
        "name"  TEXT,
        "desc"  TEXT,
        "str1"  TEXT, "str2"  TEXT, "str3"  TEXT, "str4"  TEXT,
        "str5"  TEXT, "str6"  TEXT, "str7"  TEXT, "str8"  TEXT,
        "str9"  TEXT, "str10" TEXT, "str11" TEXT, "str12" TEXT,
        "str13" TEXT, "str14" TEXT, "str15" TEXT, "str16" TEXT,
        PRIMARY KEY("id")
    )
"""

# Datacorn xác minh DB mở ra đúng format bằng PRAGMA table_info (name+pk)
DATAS_TABLE_FIELDS = "alias0,atk0,attribute0,category0,def0,id1,level0,ot0,race0,setcode0,type0"
TEXTS_TABLE_FIELDS = ("desc0,id1,name0,str10,str100,str110,str120,str130,str140,str150,"
                      "str160,str20,str30,str40,str50,str60,str70,str80,str90")


def get_db_path() -> Path:
    return Path(__file__).resolve().parent.parent / "card-data.cdb"


# ============================================================
# Passcode uniqueness across every CDB the client loads
# ============================================================

DEFAULT_EDOPRO_DIR = "F:/Game/ProjectIgnis"


def sibling_cdb_paths(root: Path):
    """CDB ở gốc repo thuộc luồng dữ liệu khác (docs/agent-rules.md §3.4).

    Là mọi *.cdb trừ CDB do compiler sinh, để CDB cộng đồng mới thêm vào repo
    tự được đối chiếu passcode mà không phải sửa danh sách.
    """
    return sorted(p for p in root.glob("*.cdb") if p.name != get_db_path().name)


def read_ids(path: Path):
    """Tập passcode trong một CDB bất kỳ.

    Chỉ đọc cột datas.id nên dùng được cho cả CDB của game (schema có thể khác
    bản Datacorn mà compiler sinh ra).
    """
    conn = sqlite3.connect(path.resolve().as_uri() + "?mode=ro", uri=True)
    try:
        return {row[0] for row in conn.execute("SELECT id FROM datas")}
    finally:
        conn.close()


def external_cdb_paths(root: Path):
    """CDB cần đối chiếu passcode và thư mục game nếu không tìm thấy.

    Gồm CDB anh em trong repo và mọi CDB trong bản cài EDOPro ($EDOPRO_DIR).
    CDB trong game trùng tên file với CDB của repo bị bỏ qua: đó là bản phân
    phối của chính repo này, trùng ID với nó là chuyện đương nhiên.
    """
    paths = sibling_cdb_paths(root)
    own_names = {get_db_path().name, *(p.name for p in paths)}
    game_dir = Path(os.environ.get("EDOPRO_DIR") or DEFAULT_EDOPRO_DIR)
    if not game_dir.is_dir():
        return paths, game_dir
    paths.extend(sorted(p for p in game_dir.rglob("*.cdb") if p.name not in own_names))
    return paths, None


def check_passcode_collisions(root: Path, owned_ids):
    """Passcode phải là duy nhất trong mọi CDB (docs/agent-rules.md §2.1).

    Trả về (errors, warnings). Trùng ID là error vì EDOPro nạp nhầm card mà
    không báo gì; không đọc được nguồn đối chiếu chỉ là warning.
    """
    errors, warnings = [], []
    if not owned_ids:
        return errors, warnings
    paths, missing_game_dir = external_cdb_paths(root)
    if missing_game_dir is not None:
        warnings.append(f"Không thấy bản cài EDOPro tại {missing_game_dir} — chỉ đối chiếu passcode với CDB "
                        "trong repo. Đặt $EDOPRO_DIR để kiểm tra cả CDB của game.")
    for path in paths:
        try:
            hits = owned_ids & read_ids(path)
        except sqlite3.Error as exc:
            warnings.append(f"Không đọc được passcode từ {path}: {exc}")
            continue
        label = path.name if path.parent == root else str(path)
        for code in sorted(hits):
            errors.append(f"{code}: passcode đã được dùng trong {label} — đổi ID trước khi phát hành")
    return errors, warnings


def external_passcodes(root: Path):
    """Passcode đã dùng ở mọi CDB ngoài card-data, và thư mục game nếu thiếu."""
    used = set()
    paths, missing_game_dir = external_cdb_paths(root)
    for path in paths:
        try:
            used |= read_ids(path)
        except sqlite3.Error as exc:
            print(f"Warning: không đọc được passcode từ {path}: {exc}", file=sys.stderr)
    return used, missing_game_dir


def report_collisions(root: Path, cards):
    """In kết quả đối chiếu passcode, trả về (n_errors, n_warnings)."""
    errors, warnings = check_passcode_collisions(root, {cols["id"] for cols, _ in cards})
    for warning in warnings:
        print(f"  [WARN ] {warning}")
    for error in errors:
        print(f"  [ERROR] {error}", file=sys.stderr)
    return len(errors), len(warnings)


def verify_schema(conn) -> bool:
    """Kiểm tra DB có đúng format YGOPro (logic giống Datacorn openDatabaseWithFile)."""
    def table_fields(table):
        rows = conn.execute(f"PRAGMA table_info('{table}')").fetchall()
        cols = sorted(f"{r[1]}{r[5]}" for r in rows)  # name + pk flag
        return ",".join(cols).lower()
    return (table_fields("datas") == DATAS_TABLE_FIELDS
            and table_fields("texts") == TEXTS_TABLE_FIELDS)


# ============================================================
# Normalization & Validation (spec JSON -> giá trị cột CDB)
# ============================================================

def _to_int(value, field, errors, allow_qmark=False):
    """Chấp nhận int, chuỗi hex '0x..', chuỗi số, hoặc '?' (ATK/DEF) -> int."""
    if value is None:
        return 0
    if isinstance(value, bool):
        errors.append(f"'{field}' không được là boolean")
        return 0
    if isinstance(value, int):
        return value
    if isinstance(value, str):
        v = value.strip()
        if allow_qmark and v == "?":
            return QMARK_ATK_DEF
        try:
            return int(v, 0)  # hỗ trợ "0x128" lẫn "296"
        except ValueError:
            errors.append(f"'{field}' không phải số hợp lệ: {value!r}")
            return 0
    errors.append(f"'{field}' có kiểu không hợp lệ: {type(value).__name__}")
    return 0


def _name_lookup(table):
    """{tên viết thường: bit} của một bảng bitfield.

    Nhận cả tên đầy đủ ("Dual (Gemini)"), phần trước ngoặc ("Dual") và phần
    trong ngoặc khi không trùng dòng khác ("Gemini"; "Rush" thì bỏ vì nhiều dòng).
    """
    lookup, inner = {}, {}
    for bit, name in table.items():
        lookup[name.lower()] = bit
        base, _, rest = name.partition(" (")
        lookup.setdefault(base.lower(), bit)
        if rest:
            inner.setdefault(rest.rstrip(")").lower(), []).append(bit)
    for alias, bits in inner.items():
        if len(bits) == 1:
            lookup.setdefault(alias, bits[0])
    return lookup


def _to_bitfield(value, field, table, table_name, errors):
    """Bitfield từ số, tên trong table, hoặc danh sách tên/số (OR lại)."""
    if not isinstance(value, (str, list)):
        return _to_int(value, field, errors)
    lookup = _name_lookup(table)
    result = 0
    for item in value if isinstance(value, list) else [value]:
        if isinstance(item, str) and item.strip().lower() in lookup:
            result |= lookup[item.strip().lower()]
        elif isinstance(item, str) and not re.fullmatch(r"\s*(0x[0-9a-fA-F]+|\d+)\s*", item):
            errors.append(f"'{field}' không có tên {item!r} (tên hợp lệ ở bảng {table_name} trong tools/manage_db.py)")
        else:
            result |= _to_int(item, field, errors)
    return result


def _pack_setcodes(setcodes, errors):
    """Đóng gói tối đa 4 setcode 16-bit thành 1 số 64-bit (theo Datacorn)."""
    if len(setcodes) > MAX_SETCODES:
        errors.append(f"'setcodes' chỉ chứa tối đa {MAX_SETCODES} setcode (schema 64-bit), nhận {len(setcodes)}")
        setcodes = setcodes[:MAX_SETCODES]
    packed = 0
    for i, sc in enumerate(setcodes):
        if not (0 < sc <= 0xFFFF):
            errors.append(f"setcode thứ {i+1} phải trong khoảng 0x1-0xFFFF, nhận {hex(sc) if sc >= 0 else sc}")
            continue
        packed |= (sc & 0xFFFF) << (i * 16)
    return packed


def unpack_setcodes(packed):
    """Tách số 64-bit thành danh sách setcode 16-bit khác 0."""
    return [(packed >> (i * 16)) & 0xFFFF for i in range(MAX_SETCODES)
            if (packed >> (i * 16)) & 0xFFFF]


def normalize_card(card_data, errors):
    """Chuyển spec JSON (hỗ trợ cả field thân thiện) thành dict cột CDB.

    Field thân thiện (tùy chọn, ưu tiên hơn giá trị thô):
      - "setcodes": [0x128, ...]        -> đóng gói vào cột setcode
      - "lscale"/"rscale": 0-13         -> đóng gói vào cột level
      - "linkmarkers": ["Top","Bottom"] -> bitfield ghi vào cột def (Link)
      - "atk"/"def": "?"                -> -2
      - "type"/"race"/"attribute"/"category": tên hoặc danh sách tên thay cho số,
        vd "race": "Warrior", "category": ["Search", "Send to Hand"]
    """
    cols = {}
    cols["id"] = _to_int(card_data.get("id"), "id", errors)
    cols["ot"] = _to_int(card_data.get("ot", OT_CUSTOM), "ot", errors)
    cols["alias"] = _to_int(card_data.get("alias", 0), "alias", errors)
    cols["type"] = _to_bitfield(card_data.get("type", 0), "type", TYPES, "TYPES", errors)
    cols["atk"] = _to_int(card_data.get("atk", 0), "atk", errors, allow_qmark=True)
    cols["def"] = _to_int(card_data.get("def", 0), "def", errors, allow_qmark=True)
    cols["level"] = _to_int(card_data.get("level", 0), "level", errors)
    cols["race"] = _to_bitfield(card_data.get("race", 0), "race", RACES, "RACES", errors)
    cols["attribute"] = _to_bitfield(card_data.get("attribute", 0), "attribute", ATTRIBUTES, "ATTRIBUTES", errors)
    cols["category"] = _to_bitfield(card_data.get("category", 0), "category", CATEGORIES, "CATEGORIES", errors)

    # --- setcodes: danh sách -> đóng gói 64-bit ---
    raw_setcode = _to_int(card_data.get("setcode", 0), "setcode", errors)
    if "setcodes" in card_data:
        lst = card_data["setcodes"]
        if not isinstance(lst, list):
            errors.append("'setcodes' phải là danh sách")
            lst = []
        packed = _pack_setcodes([_to_int(s, "setcodes[]", errors) for s in lst], errors)
        if raw_setcode and raw_setcode != packed:
            errors.append(f"'setcode' ({hex(raw_setcode)}) mâu thuẫn với 'setcodes' ({hex(packed)}); chỉ dùng một trong hai")
        cols["setcode"] = packed
    else:
        cols["setcode"] = raw_setcode

    # --- lscale/rscale: đóng gói vào level theo công thức Datacorn ---
    if "lscale" in card_data or "rscale" in card_data:
        ls = _to_int(card_data.get("lscale", card_data.get("rscale", 0)), "lscale", errors)
        rs = _to_int(card_data.get("rscale", card_data.get("lscale", 0)), "rscale", errors)
        packed_lvl = (cols["level"] & LEVEL_BASE_MASK) | ((ls & 0xFF) << 24) | ((rs & 0xFF) << 16)
        if cols["level"] & ~LEVEL_BASE_MASK and cols["level"] != packed_lvl:
            errors.append("'level' đã chứa scale đóng gói nhưng mâu thuẫn với 'lscale'/'rscale'")
        cols["level"] = packed_lvl

    # --- linkmarkers: danh sách tên/bit -> cột def (chỉ Link monster) ---
    if "linkmarkers" in card_data:
        if not cols["type"] & TYPE_LINK:
            errors.append("'linkmarkers' chỉ dùng cho Link monster (type thiếu bit 0x4000000)")
        lst = card_data["linkmarkers"]
        if not isinstance(lst, list):
            errors.append("'linkmarkers' phải là danh sách")
            lst = []
        markers = 0
        for m in lst:
            if isinstance(m, str) and m.strip().lower() in LINK_MARKER_NAMES:
                markers |= LINK_MARKER_NAMES[m.strip().lower()]
            else:
                bit = _to_int(m, "linkmarkers[]", errors)
                if bit in LINK_MARKERS:
                    markers |= bit
                else:
                    errors.append(f"link marker không hợp lệ: {m!r} (dùng tên: {', '.join(LINK_MARKERS.values())})")
        raw_def = cols["def"]
        if raw_def and raw_def != markers:
            errors.append(f"'def' ({raw_def}) mâu thuẫn với 'linkmarkers' ({markers}); chỉ dùng một trong hai")
        cols["def"] = markers

    return cols


def validate_card(cols, card_data, errors, warnings):
    """Validate giá trị cột theo các ràng buộc Datacorn + quy tắc project."""
    t = cols["type"]

    if cols["id"] <= 0:
        errors.append("'id' (passcode) phải là số nguyên dương")
    if cols["ot"] != OT_CUSTOM:
        errors.append(f"'ot' phải = 32 (Custom) theo quy tắc project, nhận {cols['ot']}")
    if t & ~TYPE_VALID_MASK:
        errors.append(f"'type' chứa bit không hợp lệ: {hex(t & ~TYPE_VALID_MASK)}")
    frame_bits = bin(t & (TYPE_MONSTER | TYPE_SPELL | TYPE_TRAP)).count("1")
    if frame_bits != 1:
        errors.append("'type' phải có đúng 1 trong các bit Monster (0x1) / Spell (0x2) / Trap (0x4)")
    if cols["category"] & ~CATEGORY_VALID_MASK:
        errors.append(f"'category' chứa bit không hợp lệ: {hex(cols['category'] & ~CATEGORY_VALID_MASK)}")
    if cols["setcode"] >= 1 << 64:
        errors.append("'setcode' vượt quá 64-bit")
    if cols["atk"] < QMARK_ATK_DEF:
        errors.append(f"'atk' nhỏ nhất là -2 (ATK '?'), nhận {cols['atk']}")
    if cols["alias"] < 0:
        errors.append("'alias' phải >= 0")

    if t & TYPE_MONSTER:
        race, attr = cols["race"], cols["attribute"]
        if race & ~RACE_VALID_MASK:
            errors.append(f"'race' chứa bit không hợp lệ: {hex(race & ~RACE_VALID_MASK)}")
        elif race == 0:
            errors.append("Monster phải có 'race' (Tộc) khác 0")
        elif bin(race).count("1") > 1:
            errors.append(f"'race' chỉ được có 1 bit, nhận {hex(race)} ({format_bitfield(race, RACES)})")
        if attr & ~ATTRIBUTE_VALID_MASK:
            errors.append(f"'attribute' chứa bit không hợp lệ: {hex(attr & ~ATTRIBUTE_VALID_MASK)}")
        elif attr == 0:
            errors.append("Monster phải có 'attribute' (Hệ) khác 0")
        elif bin(attr).count("1") > 1:
            errors.append(f"'attribute' chỉ được có 1 bit, nhận {hex(attr)} ({format_bitfield(attr, ATTRIBUTES)})")

        base_level = cols["level"] & 0xFF
        lscale = (cols["level"] >> 24) & 0xFF
        rscale = (cols["level"] >> 16) & 0xFF
        if base_level > 13:
            errors.append(f"Level/Rank/Link rating tối đa 13, nhận {base_level}")
        if t & TYPE_PENDULUM:
            if lscale > 13 or rscale > 13:
                errors.append(f"Pendulum Scale tối đa 13, nhận {lscale}/{rscale}")
            if lscale != rscale:
                warnings.append(f"Pendulum Scale trái/phải lệch nhau ({lscale}/{rscale}) — mọi card thực đều có 2 scale bằng nhau")
        elif cols["level"] & ~LEVEL_BASE_MASK:
            errors.append(f"'level' chứa scale đóng gói ({hex(cols['level'])}) nhưng card không phải Pendulum")

        if t & TYPE_LINK:
            d = cols["def"]
            if t & TYPE_PENDULUM:
                errors.append("Card không thể vừa Link vừa Pendulum")
            if d & ~LINK_MARKER_MASK:
                errors.append(f"Link monster: 'def' là bitfield link marker, chứa bit không hợp lệ {hex(d & ~LINK_MARKER_MASK)} "
                              f"(bit hợp lệ: {', '.join(hex(b) for b in LINK_MARKERS)})")
            elif d == 0:
                errors.append("Link monster phải có ít nhất 1 link marker trong cột 'def'")
            elif bin(d).count("1") != base_level:
                warnings.append(f"Số link marker ({bin(d).count('1')}) khác Link rating ({base_level})")
        else:
            if cols["def"] < QMARK_ATK_DEF:
                errors.append(f"'def' nhỏ nhất là -2 (DEF '?'), nhận {cols['def']}")
            if t & TYPE_XYZ and t & TYPE_PENDULUM:
                pass  # Xyz Pendulum hợp lệ (vd: Odd-Eyes Rebellion)
    else:
        # Spell/Trap: các cột chỉ-số phải bằng 0
        for field in ("atk", "def", "level", "race", "attribute"):
            if cols[field] != 0:
                errors.append(f"Spell/Trap phải có '{field}' = 0, nhận {cols[field]}")

    name = card_data.get("name", "")
    if not isinstance(name, str) or not name.strip():
        errors.append("'name' không được rỗng")
    if not isinstance(card_data.get("desc", ""), str):
        errors.append("'desc' phải là chuỗi")
    strings = card_data.get("strings", [])
    if not isinstance(strings, list):
        errors.append("'strings' phải là danh sách")
    else:
        if len(strings) > 16:
            errors.append(f"'strings' tối đa 16 phần tử (str1-str16), nhận {len(strings)}")
        for i, s in enumerate(strings):
            if not isinstance(s, str):
                errors.append(f"strings[{i}] phải là chuỗi")


def load_and_validate(json_file):
    """Đọc 1 spec JSON, trả về (cols, card_data, errors, warnings)."""
    errors, warnings = [], []
    try:
        with open(json_file, "r", encoding="utf-8") as f:
            card_data = json.load(f)
    except Exception as e:
        return None, None, [f"JSON không đọc được: {e}"], []
    if not isinstance(card_data, dict):
        return None, None, ["Spec must be a JSON object"], []
    cols = normalize_card(card_data, errors)
    validate_card(cols, card_data, errors, warnings)
    m = re.match(r"c(\d+)$", json_file.stem)
    if m and cols["id"] != int(m.group(1)):
        errors.append(f"'id' ({cols['id']}) không khớp tên file {json_file.name}")
    return cols, card_data, errors, warnings


# ============================================================
# Display helpers
# ============================================================

def format_bitfield(value, table):
    parts = [name for bit, name in table.items() if value & bit]
    return " / ".join(parts) if parts else f"Unknown ({hex(value)})"


def format_type(type_val: int) -> str:
    return format_bitfield(type_val, TYPES)


def format_atk_def(val) -> str:
    return "?" if val == QMARK_ATK_DEF else str(val)


def format_level(level_val: int, type_val: int) -> str:
    lscale = (level_val >> 24) & 0xFF
    rscale = (level_val >> 16) & 0xFF
    level = level_val & 0xFF

    label = "Level"
    if type_val & TYPE_XYZ:
        label = "Rank"
    elif type_val & TYPE_LINK:
        label = "Link"

    parts = [f"{label} {level}"]
    if type_val & TYPE_PENDULUM:
        parts.append(f"Scale {lscale}/{rscale}")
    return ", ".join(parts)


# ============================================================
# Commands
# ============================================================

def query_card(db_path: Path, search: str):
    if not db_path.exists():
        print(f"Error: Database not found at {db_path}", file=sys.stderr)
        return

    conn = sqlite3.connect(str(db_path))
    if not verify_schema(conn):
        print("Warning: CDB schema không khớp format YGOPro chuẩn (datas/texts).", file=sys.stderr)
    cursor = conn.cursor()

    # Determine if searching by ID or name
    if search.isdigit():
        cursor.execute("""
            SELECT d.id, t.name, d.type, d.atk, d.def, d.level, d.race, d.attribute, t.desc, d.ot, d.setcode, d.category, d.alias
            FROM datas d
            LEFT JOIN texts t ON d.id = t.id
            WHERE d.id = ?
        """, (int(search),))
    else:
        cursor.execute("""
            SELECT d.id, t.name, d.type, d.atk, d.def, d.level, d.race, d.attribute, t.desc, d.ot, d.setcode, d.category, d.alias
            FROM datas d
            JOIN texts t ON d.id = t.id
            WHERE t.name LIKE ?
        """, (f"%{search}%",))

    rows = cursor.fetchall()
    conn.close()

    if not rows:
        print(f"No cards found matching '{search}'.")
        return

    for row in rows:
        cid, name, ctype, atk, cdef, level, race, attribute, desc, ot, setcode, category, alias = row
        print("=" * 60)
        print(f"Card Name : {name or 'N/A'}")
        print(f"Passcode  : {cid}")
        print(f"Format (ot): {ot} ({format_bitfield(ot, SCOPES)})")
        if alias:
            print(f"Alias     : {alias}")
        print(f"Card Type : {format_type(ctype)}")
        if setcode:
            chunks = ", ".join(hex(s) for s in unpack_setcodes(setcode))
            print(f"Setcode   : {setcode} ({chunks})")

        # Only show stats if it's a Monster card
        if ctype & TYPE_MONSTER:
            attr_str = ATTRIBUTES.get(attribute, f"Unknown ({hex(attribute)})")
            race_str = RACES.get(race, f"Unknown ({hex(race)})")
            print(f"Attribute : {attr_str} | Race: {race_str}")
            print(f"Level/Rank: {format_level(level, ctype)}")
            if ctype & TYPE_LINK:
                print(f"ATK       : {format_atk_def(atk)}")
                print(f"Markers   : {format_bitfield(cdef, LINK_MARKERS)}")
            else:
                print(f"ATK / DEF : {format_atk_def(atk)} / {format_atk_def(cdef)}")

        if category:
            print(f"Category  : {format_bitfield(category, CATEGORIES)}")
        print("-" * 60)
        print("Effect Description:")
        print(desc or "No description available.")
        print("=" * 60)
        print()


def collect_specs(json_dir: Path):
    """Đọc + validate toàn bộ spec, trả về (cards, total_errors, total_warnings).

    cards: list[(cols, card_data)] sắp xếp theo id để output CDB ổn định.
    """
    cards = []
    total_errors = total_warnings = 0
    for json_file in sorted(json_dir.glob("c*.json"),
                            key=lambda p: int(re.match(r"c(\d+)", p.stem).group(1)) if re.match(r"c(\d+)", p.stem) else 0):
        cols, card_data, errors, warnings = load_and_validate(json_file)
        name = (card_data or {}).get("name", "?")
        for w in warnings:
            print(f"  [WARN ] {json_file.name} ({name}): {w}")
            total_warnings += 1
        if errors:
            for e in errors:
                print(f"  [ERROR] {json_file.name} ({name}): {e}", file=sys.stderr)
            total_errors += len(errors)
            continue
        cards.append((cols, card_data))
    ids = [cols["id"] for cols, _ in cards]
    if len(ids) != len(set(ids)):
        print("ERROR: Duplicate spec IDs", file=sys.stderr)
        total_errors += 1
    if not cards:
        print("ERROR: No valid card specs", file=sys.stderr)
        total_errors += 1
    return cards, total_errors, total_warnings


def validate_specs(db_path: Path) -> bool:
    """Validate toàn bộ card-data/*.json mà không ghi CDB. Trả về True nếu sạch."""
    json_dir = db_path.parent / "card-data"
    if not json_dir.is_dir():
        print(f"Error: card-data directory not found at {json_dir}", file=sys.stderr)
        return False
    print(f"Validating specs in {json_dir}/ ...")
    cards, n_err, n_warn = collect_specs(json_dir)
    col_err, col_warn = report_collisions(db_path.parent, cards)
    n_err += col_err
    n_warn += col_warn
    print("-" * 40)
    print(f"Specs hợp lệ : {len(cards)}")
    print(f"Errors       : {n_err}")
    print(f"Warnings     : {n_warn}")
    if n_err:
        print("FAILED: Sửa toàn bộ lỗi trên rồi chạy lại.", file=sys.stderr)
        return False
    print("OK: Toàn bộ spec đạt chuẩn Datacorn/YGOPro.")
    return True


def compile_db(db_path: Path) -> bool:
    """Biên dịch card-data/*.json -> CDB. Atomic: chỉ thay CDB cũ khi mọi spec hợp lệ."""
    project_root = db_path.parent
    json_dir = project_root / "card-data"

    if not json_dir.is_dir():
        print(f"Error: card-data directory not found at {json_dir}", file=sys.stderr)
        return False

    print("Step 1/2: Validating specs...")
    cards, n_err, n_warn = collect_specs(json_dir)
    col_err, col_warn = report_collisions(project_root, cards)
    n_err += col_err
    n_warn += col_warn
    if n_err:
        print(f"Error: {n_err} lỗi validation. CDB cũ được giữ nguyên, không biên dịch.", file=sys.stderr)
        return False
    if n_warn:
        print(f"({n_warn} warning — nên xử lý nhưng không chặn biên dịch)")

    if db_path.exists():
        try:
            existing = read_rows(db_path)
            owned = {cols["id"] for cols, _ in cards}
            extra = (set(existing["datas"]) | set(existing["texts"])) - owned
            if extra:
                raise ValueError(f"Refusing to drop IDs outside card-data: {sorted(extra)}")
        except (ValueError, sqlite3.Error) as exc:
            print(f"Error: {exc}", file=sys.stderr)
            return False

    print("Step 2/2: Compiling to SQLite...")
    tmp_path = db_path.with_suffix(".cdb.tmp")
    if tmp_path.exists():
        tmp_path.unlink()

    conn = sqlite3.connect(str(tmp_path))
    try:
        cursor = conn.cursor()
        cursor.execute("PRAGMA page_size = 4096")  # giống Datacorn setupCleanDatabase
        cursor.execute(SQL_CREATE_DATAS)
        cursor.execute(SQL_CREATE_TEXTS)

        for cols, card_data in cards:
            cursor.execute("""
                INSERT INTO datas (id, ot, alias, setcode, type, atk, def, level, race, attribute, category)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                cols["id"], cols["ot"], cols["alias"], cols["setcode"], cols["type"],
                cols["atk"], cols["def"], cols["level"], cols["race"], cols["attribute"],
                cols["category"],
            ))

            strings = card_data.get("strings", [])
            padded_strings = [None] * 16
            for i in range(min(len(strings), 16)):
                padded_strings[i] = strings[i]

            cursor.execute("""
                INSERT INTO texts (id, name, desc,
                    str1, str2, str3, str4, str5, str6, str7, str8,
                    str9, str10, str11, str12, str13, str14, str15, str16)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                cols["id"],
                card_data.get("name", ""),
                card_data.get("desc", ""),
                *padded_strings
            ))
        conn.commit()
    except Exception as e:
        conn.close()
        tmp_path.unlink(missing_ok=True)
        print(f"Error: Biên dịch thất bại, CDB cũ được giữ nguyên: {e}", file=sys.stderr)
        return False
    conn.close()

    os.replace(str(tmp_path), str(db_path))  # atomic swap
    print(f"Successfully compiled {len(cards)} card specs into database {db_path.name}")
    return True


DATA_COLUMNS = "id,ot,alias,setcode,type,atk,def,level,race,attribute,category"
TEXT_COLUMNS = "id,name,desc," + ",".join(f"str{i}" for i in range(1, 17))


def read_rows(path):
    """Read canonical columns without creating a missing database."""
    conn = sqlite3.connect(path.resolve().as_uri() + "?mode=ro", uri=True)
    try:
        if not verify_schema(conn):
            raise ValueError(f"Invalid CDB schema: {path}")
        return {table: {row[0]: row for row in conn.execute(f"SELECT {columns} FROM {table}")}
                for table, columns in (("datas", DATA_COLUMNS), ("texts", TEXT_COLUMNS))}
    finally:
        conn.close()


def expected_rows(cards):
    result = {"datas": {}, "texts": {}}
    for cols, card in cards:
        code = cols["id"]
        result["datas"][code] = tuple(cols[key] for key in DATA_COLUMNS.split(","))
        strings = card.get("strings", [])
        result["texts"][code] = (code, card["name"], card.get("desc", ""),
                                  *(strings + [None] * (16 - len(strings))))
    return result


def check_sync(db_path: Path) -> bool:
    root = db_path.parent
    cards, errors, _ = collect_specs(root / "card-data")
    if errors:
        return False
    expected = expected_rows(cards)
    owned = set(expected["datas"])
    try:
        actual = read_rows(db_path)
        features = json.loads((root / "feature_list.json").read_text(encoding="utf-8"))
        registered = {int(card["passcode"]): card.get("status", "")
                      for arch in features.get("archetypes", {}).values()
                      for card in arch.get("cards", []) if card.get("passcode")}
    except (OSError, ValueError, sqlite3.Error) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return False
    scripts = {int(match.group(1)) for path in (root / "script").glob("c*.lua")
               if (match := re.fullmatch(r"c(\d+)", path.stem))}
    issues = []
    for code in sorted(owned):
        if code not in scripts:
            issues.append(f"{code}: missing Lua script")
        if code not in registered:
            issues.append(f"{code}: missing feature_list entry")
    for table in ("datas", "texts"):
        if set(actual[table]) != owned:
            issues.append(f"{table}: missing={sorted(owned-set(actual[table]))}, extra={sorted(set(actual[table])-owned)}")
        for code in sorted(owned & set(actual[table])):
            if actual[table][code] != expected[table][code]:
                issues.append(f"{code}: stale {table} row")
    legacy = (scripts | {code for code, status in registered.items()
                          if status not in ("pending", "skipped", "p", "x")}) - owned
    if legacy:
        print(f"INFO: unrelated legacy cards outside card-data (not blocking): {sorted(legacy)}")
    for issue in issues:
        print(f"ERROR: {issue}")
    print(f"Sync: {len(owned)} owned cards; {len(issues)} issues")
    return not issues


def main():
    parser = argparse.ArgumentParser(description="TTF Card Database CLI Manager Utility")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # Subcommand: query
    query_parser = subparsers.add_parser("query", help="Query card statistics and text")
    query_parser.add_argument("search", type=str, help="Card passcode (ID) or partial name to search")

    # Subcommand: check-sync
    subparsers.add_parser("check-sync", help="Check synchronization status between Lua scripts, JSON specs, and feature_list")

    # Subcommand: validate
    subparsers.add_parser("validate", help="Validate all card-data/*.json specs (Datacorn rules) without writing the CDB")

    # Subcommand: compile
    subparsers.add_parser("compile", help="Validate then compile card-data/*.json specs into CDB SQLite database (atomic)")

    args = parser.parse_args()
    db_path = get_db_path()

    if args.command == "query":
        query_card(db_path, args.search)
    elif args.command == "check-sync":
        sys.exit(0 if check_sync(db_path) else 1)
    elif args.command == "validate":
        sys.exit(0 if validate_specs(db_path) else 1)
    elif args.command == "compile":
        sys.exit(0 if compile_db(db_path) else 1)

if __name__ == "__main__":
    main()
