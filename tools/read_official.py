#!/usr/bin/env python3
"""Đọc thông tin và script card official trực tiếp từ bản cài EDOPro/ProjectIgnis.

Đọc dữ liệu và script đã có sẵn trong thư mục cài EDOPro (thêm --fetch để tải
script từ GitHub khi bản cài không có):
  - Script Lua: tìm trong repositories/delta-bagooska/script/ (ưu tiên) và script/
  - Metadata & Effect text: đọc từ các file CDB của game (cards.delta.cdb, cards.cdb...)
  - Tự động sao chép script vào docs/official-reference/c<ID>.lua để làm mẫu phát triển.

Cách dùng:
  python tools/read_official.py <passcode> [<passcode2> ...]
  python tools/read_official.py "Ash Blossom"
  python tools/read_official.py 14558127 --view
  python tools/read_official.py --search "Dark Magician"
  python tools/read_official.py --text "If this card is Normal or Special Summoned" "Spell/Trap from your Deck"
"""
import argparse
import json
import os
import re
import shutil
import sqlite3
import sys
import urllib.request
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")

DEFAULT_GAME_DIR = "F:/Game/ProjectIgnis"
OFFICIAL_REPO_PREFIX = "https://github.com/ProjectIgnis/"

# manage_db nằm cùng thư mục; thêm vào sys.path để import được cả khi file
# này được nạp theo đường dẫn (test) chứ không qua `python tools/...`.
sys.path.insert(0, str(Path(__file__).resolve().parent))
from manage_db import ATTRIBUTES, LINK_MARKERS, RACES  # noqa: E402

# Type bitmask dùng cho format_card_type
TYPE_MONSTER = 0x1
TYPE_SPELL = 0x2
TYPE_TRAP = 0x4
TYPE_NORMAL = 0x10
TYPE_EFFECT = 0x20
TYPE_FUSION = 0x40
TYPE_RITUAL = 0x80
TYPE_SPIRIT = 0x200
TYPE_UNION = 0x400
TYPE_DUAL = 0x800  # Gemini
TYPE_TUNER = 0x1000
TYPE_SYNCHRO = 0x2000
TYPE_QUICKPLAY = 0x10000
TYPE_CONTINUOUS = 0x20000
TYPE_EQUIP = 0x40000
TYPE_FIELD = 0x80000
TYPE_COUNTER = 0x100000
TYPE_FLIP = 0x200000
TYPE_TOON = 0x400000
TYPE_XYZ = 0x800000
TYPE_PENDULUM = 0x1000000
TYPE_LINK = 0x4000000


def resolve_game_dir(explicit_dir=None):
    """Xác định thư mục cài game EDOPro."""
    if explicit_dir:
        p = Path(explicit_dir).resolve()
        if p.is_dir():
            return p
        raise FileNotFoundError(f"Thư mục game chỉ định không tồn tại: {explicit_dir}")

    env_dir = os.environ.get("EDOPRO_DIR")
    if env_dir:
        p = Path(env_dir).resolve()
        if p.is_dir():
            return p

    default_path = Path(DEFAULT_GAME_DIR).resolve()
    if default_path.is_dir():
        return default_path

    common_fallbacks = [
        Path("C:/ProjectIgnis"),
        Path("D:/ProjectIgnis"),
        Path("E:/ProjectIgnis"),
        Path("C:/EDOPro"),
        Path("D:/EDOPro"),
    ]
    for fb in common_fallbacks:
        if fb.is_dir():
            return fb.resolve()

    return None


def read_repo_config(game_dir):
    """Đọc config/configs.json trong game dir nếu có."""
    if not game_dir:
        return []
    config_path = game_dir / "config" / "configs.json"
    if not config_path.is_file():
        return []
    try:
        data = json.loads(config_path.read_text(encoding="utf-8"))
        return [repo for repo in data.get("repos", []) if isinstance(repo, dict)]
    except (OSError, ValueError):
        return []


def collect_script_roots(game_dir):
    """Gom các thư mục script của game theo thứ tự ưu tiên: repo update trước, gốc sau."""
    roots = []
    if not game_dir or not game_dir.is_dir():
        return roots

    # 1. Quét theo configs.json cho repo official
    for repo in read_repo_config(game_dir):
        url = repo.get("url", "")
        script_path = repo.get("script_path")
        repo_path = repo.get("repo_path")
        if script_path and repo_path and url.startswith(OFFICIAL_REPO_PREFIX):
            r = (game_dir / repo_path / script_path).resolve()
            if r.is_dir() and r not in roots:
                roots.append(r)

    # 2. Thử đường dẫn delta-bagooska trực tiếp nếu chưa có trong configs
    delta_root = (game_dir / "repositories" / "delta-bagooska" / "script").resolve()
    if delta_root.is_dir() and delta_root not in roots:
        roots.append(delta_root)

    # 3. Thư mục script gốc của game
    base_script = (game_dir / "script").resolve()
    if base_script.is_dir() and base_script not in roots:
        roots.append(base_script)

    return roots


def find_script_in_roots(passcode, script_roots):
    """Tìm file c<passcode>.lua trong danh sách script roots."""
    filename = f"c{passcode}.lua"
    subdirs = ["official", "pre-release", "pre-errata", "rush", "unofficial", "goat", "skill"]

    for root in script_roots:
        if not root.is_dir():
            continue
        # Ưu tiên các thư mục con thường gặp
        for sub in subdirs:
            target = root / sub / filename
            if target.is_file():
                return target

        # Nếu không thấy trong subdirs định sẵn, quét đệ quy trong root
        for found in root.rglob(filename):
            if found.is_file():
                return found

    return None


def collect_cdb_paths(game_dir):
    """Gom danh sách CDB official từ game dir theo thứ tự ưu tiên."""
    if not game_dir or not game_dir.is_dir():
        return []

    cdbs = []
    seen = set()

    def add_cdb(path):
        p = path.resolve()
        if p.is_file() and p not in seen:
            seen.add(p)
            cdbs.append(p)

    # 1. Delta Bagooska CDBs (ưu tiên dữ liệu mới cập nhật)
    delta_dir = game_dir / "repositories" / "delta-bagooska"
    if delta_dir.is_dir():
        add_cdb(delta_dir / "cards.delta.cdb")
        for p in sorted(delta_dir.glob("prerelease-*.cdb")):
            add_cdb(p)
        for p in sorted(delta_dir.glob("*.cdb")):
            add_cdb(p)

    # 2. Expansions CDBs
    exp_dir = game_dir / "expansions"
    if exp_dir.is_dir():
        add_cdb(exp_dir / "cards.cdb")
        add_cdb(exp_dir / "cards-unofficial.cdb")
        add_cdb(exp_dir / "cards-rush.cdb")
        add_cdb(exp_dir / "cards-skills.cdb")
        for p in sorted(exp_dir.glob("*.cdb")):
            add_cdb(p)

    # 3. Base cards.cdb
    add_cdb(game_dir / "cards.cdb")

    # 4. Các CDB khác trong game (loại trừ custom_cards_zesty)
    for p in sorted(game_dir.rglob("*.cdb")):
        if "custom_cards_zesty" not in p.parts:
            add_cdb(p)

    return cdbs


def connect_cdb(cdb_path):
    """Mở kết nối SQLite read-only an toàn."""
    uri = f"file:{cdb_path.resolve().as_posix()}?mode=ro"
    try:
        return sqlite3.connect(uri, uri=True)
    except sqlite3.OperationalError:
        return sqlite3.connect(str(cdb_path.resolve()))


def query_card_info(passcode, cdb_paths):
    """Truy vấn metadata và effect text của card theo passcode từ các CDB."""
    for cdb in cdb_paths:
        try:
            conn = connect_cdb(cdb)
        except Exception:
            continue
        try:
            cur = conn.cursor()
            cur.execute(
                """
                SELECT d.id, d.ot, d.alias, d.setcode, d.type, d.atk, d.def,
                       d.level, d.race, d.attribute, d.category,
                       t.name, t.desc,
                       t.str1, t.str2, t.str3, t.str4, t.str5, t.str6, t.str7, t.str8,
                       t.str9, t.str10, t.str11, t.str12, t.str13, t.str14, t.str15, t.str16
                FROM datas d
                LEFT JOIN texts t ON d.id = t.id
                WHERE d.id = ?
                """,
                (passcode,),
            )
            row = cur.fetchone()
            if row and row[11]:  # Có name
                strings = [s for s in row[13:] if s and s.strip()]
                return {
                    "id": row[0],
                    "ot": row[1],
                    "alias": row[2],
                    "setcode": row[3],
                    "type": row[4] or 0,
                    "atk": row[5],
                    "def": row[6],
                    "level": row[7] or 0,
                    "race": row[8] or 0,
                    "attribute": row[9] or 0,
                    "category": row[10] or 0,
                    "name": row[11],
                    "desc": row[12] or "",
                    "strings": strings,
                    "cdb": cdb,
                }
        except sqlite3.Error:
            pass
        finally:
            conn.close()
    return None


def search_cards_by_name(query, cdb_paths, limit=30):
    """Tìm card trong các CDB theo tên, tự động gom alias/reprint."""
    results = {}
    pattern = f"%{query}%"

    for cdb in cdb_paths:
        try:
            conn = connect_cdb(cdb)
        except Exception:
            continue
        try:
            cur = conn.cursor()
            cur.execute(
                """
                SELECT t.id, t.name, d.type, d.atk, d.def, d.level, d.alias
                FROM texts t
                LEFT JOIN datas d ON t.id = d.id
                WHERE t.name LIKE ?
                ORDER BY length(t.name) ASC, t.id ASC
                LIMIT ?
                """,
                (pattern, limit),
            )
            for row in cur.fetchall():
                cid, name, ctype, atk, cdef, lvl, alias = row
                if cid not in results:
                    results[cid] = {
                        "id": cid,
                        "name": name,
                        "type": ctype or 0,
                        "atk": atk,
                        "def": cdef,
                        "level": lvl or 0,
                        "alias": alias or 0,
                        "cdb": cdb,
                    }
        except sqlite3.Error:
            pass
        finally:
            conn.close()

    # Gom các card trùng tên hoặc alias
    distinct = []
    seen_names = set()
    for item in results.values():
        if item["alias"] and item["alias"] in results:
            continue
        key = item["name"].strip().lower()
        if key in seen_names:
            continue
        seen_names.add(key)
        distinct.append(item)

    return distinct[:limit]


def search_cards_by_text(phrases, cdb_paths, limit=15):
    """Tìm card official có effect text chứa mọi cụm trong phrases.

    Dùng để tìm official reference cùng cơ chế khi chưa biết tên card. Bỏ bản
    reprint (alias) và card trùng tên; text ngắn đứng trước vì thường chỉ làm
    đúng cơ chế cần tìm.
    """
    results = {}
    where = " AND ".join("t.desc LIKE ?" for _ in phrases)
    params = [f"%{phrase}%" for phrase in phrases]

    for cdb in cdb_paths:
        try:
            conn = connect_cdb(cdb)
        except Exception:
            continue
        try:
            rows = conn.execute(
                f"""
                SELECT t.id, t.name, t.desc, d.type
                FROM texts t
                JOIN datas d ON t.id = d.id
                WHERE d.alias = 0 AND {where}
                """,
                params,
            ).fetchall()
            for cid, name, desc, ctype in rows:
                results.setdefault(cid, {"id": cid, "name": name, "desc": desc or "", "type": ctype or 0})
        except sqlite3.Error:
            pass
        finally:
            conn.close()

    distinct = []
    seen_names = set()
    for item in sorted(results.values(), key=lambda item: (len(item["desc"]), item["id"])):
        key = item["name"].strip().lower()
        if key not in seen_names:
            seen_names.add(key)
            distinct.append(item)
    return distinct[:limit]


def text_snippet(desc, phrase, width=160):
    """Đoạn effect text quanh cụm tìm kiếm đầu tiên, gọn trên một dòng."""
    flat = " ".join(desc.split())
    start = max(flat.lower().find(phrase.lower()), 0)
    start = max(start - 40, 0)
    snippet = flat[start:start + width]
    return ("..." if start else "") + snippet + ("..." if start + width < len(flat) else "")


def format_card_type(ctype):
    """Chuyển bitmask type sang chuỗi thân thiện."""
    tags = []
    if ctype & TYPE_MONSTER:
        tags.append("Monster")
        if ctype & TYPE_NORMAL:
            tags.append("Normal")
        if ctype & TYPE_EFFECT:
            tags.append("Effect")
        if ctype & TYPE_FUSION:
            tags.append("Fusion")
        if ctype & TYPE_RITUAL:
            tags.append("Ritual")
        if ctype & TYPE_SYNCHRO:
            tags.append("Synchro")
        if ctype & TYPE_XYZ:
            tags.append("Xyz")
        if ctype & TYPE_LINK:
            tags.append("Link")
        if ctype & TYPE_PENDULUM:
            tags.append("Pendulum")
        if ctype & TYPE_TUNER:
            tags.append("Tuner")
        if ctype & TYPE_FLIP:
            tags.append("Flip")
        if ctype & TYPE_SPIRIT:
            tags.append("Spirit")
        if ctype & TYPE_UNION:
            tags.append("Union")
        if ctype & TYPE_DUAL:
            tags.append("Gemini")
        if ctype & TYPE_TOON:
            tags.append("Toon")
    elif ctype & TYPE_SPELL:
        tags.append("Spell")
        if ctype & TYPE_QUICKPLAY:
            tags.append("Quick-Play")
        elif ctype & TYPE_CONTINUOUS:
            tags.append("Continuous")
        elif ctype & TYPE_EQUIP:
            tags.append("Equip")
        elif ctype & TYPE_FIELD:
            tags.append("Field")
        elif ctype & TYPE_RITUAL:
            tags.append("Ritual")
        else:
            tags.append("Normal")
    elif ctype & TYPE_TRAP:
        tags.append("Trap")
        if ctype & TYPE_COUNTER:
            tags.append("Counter")
        elif ctype & TYPE_CONTINUOUS:
            tags.append("Continuous")
        else:
            tags.append("Normal")

    return " / ".join(tags) if tags else f"Type(0x{ctype:x})"


def format_card_stats(card_info):
    """Định dạng các chỉ số ATK, DEF, Level/Rank/Link rating, Scale, Race, Attribute."""
    ctype = card_info["type"]
    if not (ctype & TYPE_MONSTER):
        return None

    race_name = RACES.get(card_info["race"], f"Race(0x{card_info['race']:x})")
    attr_name = ATTRIBUTES.get(card_info["attribute"], f"Attr(0x{card_info['attribute']:x})")
    raw_level = card_info["level"]
    level_val = raw_level & 0xFF

    stat_parts = []
    if ctype & TYPE_XYZ:
        stat_parts.append(f"Rank {level_val}")
    elif ctype & TYPE_LINK:
        stat_parts.append(f"Link-{level_val}")
    else:
        stat_parts.append(f"Level {level_val}")

    stat_parts.append(f"[{attr_name} / {race_name}]")

    # ATK
    atk_val = "?" if card_info["atk"] == -2 else str(card_info["atk"])

    # DEF or Link Markers
    if ctype & TYPE_LINK:
        marker_bits = card_info["def"]
        active_markers = [name for bit, name in LINK_MARKERS.items() if marker_bits & bit]
        markers_str = ", ".join(active_markers) if active_markers else "None"
        stat_parts.append(f"ATK: {atk_val}  Markers: [{markers_str}]")
    else:
        def_val = "?" if card_info["def"] == -2 else str(card_info["def"])
        stat_parts.append(f"ATK: {atk_val} / DEF: {def_val}")

    # Pendulum Scale
    if ctype & TYPE_PENDULUM:
        lscale = (raw_level >> 24) & 0xFF
        rscale = (raw_level >> 16) & 0xFF
        stat_parts.append(f"Scale: {lscale}/{rscale}")

    return " | ".join(stat_parts)


def is_normal_monster(ctype):
    """Kiểm tra có phải Normal Monster (không có effect script) hay không."""
    return bool((ctype & TYPE_MONSTER) and (ctype & TYPE_NORMAL) and not (ctype & TYPE_EFFECT))


def download_official_script(passcode, dest_path):
    """Tải script từ GitHub của ProjectIgnis khi bản cài game chưa có."""
    filename = f"c{passcode}.lua"
    urls = [
        f"https://raw.githubusercontent.com/ProjectIgnis/CardScripts/master/official/{filename}",
        f"https://raw.githubusercontent.com/ProjectIgnis/CardScripts/master/{filename}",
    ]
    for url in urls:
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "TTFCustomCards/1.0"})
            with urllib.request.urlopen(req, timeout=10) as resp:
                content = resp.read()
                dest_path.parent.mkdir(parents=True, exist_ok=True)
                dest_path.write_bytes(content)
                return True
        except Exception:
            continue
    return False


def read_single_card(passcode, game_dir, dest_dir, copy_script=True, view_script=False,
                     fetch_fallback=False, force_copy=False):
    """Xử lý đọc và hiển thị 1 card official theo passcode."""
    print("=" * 72)
    script_roots = collect_script_roots(game_dir)
    cdb_paths = collect_cdb_paths(game_dir)

    # 1. Truy vấn metadata từ CDB
    card_info = query_card_info(passcode, cdb_paths) if cdb_paths else None
    card_name = card_info["name"] if card_info else f"Passcode {passcode}"

    print(f"Card: {card_name} (ID: {passcode})")
    if card_info:
        type_str = format_card_type(card_info["type"])
        print(f"Type: {type_str}")
        stats_str = format_card_stats(card_info)
        if stats_str:
            print(f"Stat: {stats_str}")
        print("-" * 72)
        print("Mô tả / Effect Text:")
        for line in card_info["desc"].splitlines():
            print(f"  {line}")
        if card_info["strings"]:
            print("Strings / Option Prompts:")
            for idx, s in enumerate(card_info["strings"]):
                print(f"  [{idx}] {s}")
        print("-" * 72)
    else:
        print("Type: [Không tìm thấy trong CDB của game]")
        print("-" * 72)

    # 2. Tìm script trong game
    found_script = find_script_in_roots(passcode, script_roots)
    if not found_script and card_info and card_info.get("alias"):
        alias_id = card_info["alias"]
        found_script = find_script_in_roots(alias_id, script_roots)
        if found_script:
            print(f"[NOTE] Script được nạp từ base passcode alias: {alias_id}")
            passcode = alias_id
    saved_dest = None

    if found_script:
        print(f"[GAME] Tìm thấy script: {found_script}")
        if copy_script:
            dest_file = dest_dir / f"c{passcode}.lua"
            dest_dir.mkdir(parents=True, exist_ok=True)
            if not dest_file.exists() or force_copy:
                shutil.copy2(found_script, dest_file)
                print(f"[COPY] Đã lưu vào: {dest_file}")
            else:
                print(f"[SKIP] Đã tồn tại tại: {dest_file} (dùng --force để ghi đè)")
            saved_dest = dest_file
    else:
        # Nếu là Normal Monster
        if card_info and is_normal_monster(card_info["type"]):
            print(f"[NOTE] Card là Normal Monster — không có file script Lua riêng trong EDOPro.")
        else:
            print(f"[WARN] Không tìm thấy script c{passcode}.lua trong game.")
            if fetch_fallback:
                print(f"[FETCH] Đang thử tải từ ProjectIgnis CardScripts trên GitHub...")
                dest_file = dest_dir / f"c{passcode}.lua"
                if download_official_script(passcode, dest_file):
                    print(f"[OK] Đã tải và lưu vào: {dest_file}")
                    saved_dest = dest_file
                else:
                    print(f"[FAIL] Không tải được script cho passcode {passcode}.")
            else:
                print("       (Gợi ý: thêm cờ --fetch nếu muốn tự động tải từ GitHub)")

    # 3. In script nếu có cờ --view
    if view_script:
        script_to_view = found_script or saved_dest
        if script_to_view and script_to_view.is_file():
            print("-" * 72)
            print(f"--- NỘI DUNG SCRIPT ({script_to_view.name}) ---")
            print(script_to_view.read_text(encoding="utf-8", errors="replace"))
            print("-" * 72)

    print("=" * 72)
    return True


def parse_targets(raw_targets):
    """Tách danh sách input (passcodes hoặc search text)."""
    cleaned = []
    for item in raw_targets:
        for part in re.split(r"[\s,]+", item):
            t = part.strip()
            if t:
                cleaned.append(t)
    return cleaned


def main(argv=None):
    parser = argparse.ArgumentParser(
        description="Đọc card official trực tiếp từ bản cài EDOPro/ProjectIgnis thay vì phải tải."
    )
    parser.add_argument(
        "targets",
        nargs="*",
        help="Passcode (số) hoặc từ khóa tên card cần tra cứu.",
    )
    parser.add_argument(
        "--game-dir",
        default=None,
        help=f"Thư mục cài game EDOPro (mặc định: $EDOPRO_DIR hoặc {DEFAULT_GAME_DIR})",
    )
    parser.add_argument(
        "--dest-dir",
        default="docs/official-reference",
        help="Thư mục lưu script mẫu tham khảo (mặc định: docs/official-reference)",
    )
    parser.add_argument(
        "--no-copy",
        action="store_true",
        help="Chỉ đọc thông tin/script, không sao chép vào docs/official-reference",
    )
    parser.add_argument(
        "--view", "-v",
        action="store_true",
        help="In trực tiếp nội dung script Lua ra màn hình console",
    )
    parser.add_argument(
        "--search", "-s",
        action="store_true",
        help="Chế độ tìm kiếm card theo tên",
    )
    parser.add_argument(
        "--text", "-t",
        action="store_true",
        help="Tìm card theo effect text: mỗi tham số là một cụm phải có trong text",
    )
    parser.add_argument(
        "--fetch", "-f",
        action="store_true",
        help="Nếu game chưa có script, tự động tải fallback từ GitHub",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Ghi đè file trong docs/official-reference nếu đã tồn tại",
    )

    args = parser.parse_args(argv)

    game_dir = resolve_game_dir(args.game_dir)
    if not game_dir:
        print("[WARN ] Không tìm thấy thư mục cài EDOPro.", file=sys.stderr)
        print("        Đặt biến môi trường $EDOPRO_DIR hoặc truyền --game-dir <path>.", file=sys.stderr)
        if not args.fetch:
            print("        Thêm cờ --fetch nếu muốn tải online.", file=sys.stderr)

    dest_dir = Path(args.dest_dir).resolve()
    targets = parse_targets(args.targets)

    if not targets:
        parser.print_help()
        return 0

    if args.text:
        phrases = [phrase.strip() for phrase in args.targets if phrase.strip()]
        cdb_paths = collect_cdb_paths(game_dir)
        if not cdb_paths:
            print("[ERROR] Không có file CDB nào từ game để tìm kiếm.", file=sys.stderr)
            return 1
        matches = search_cards_by_text(phrases, cdb_paths)
        if not matches:
            print("Không tìm thấy card nào có effect text chứa: " + " + ".join(f"'{p}'" for p in phrases))
            return 1
        print(f"Tìm thấy {len(matches)} card (text ngắn trước):")
        print("-" * 72)
        for idx, m in enumerate(matches, 1):
            print(f"  {idx:2d}. [{m['id']}] {m['name']} ({format_card_type(m['type'])})")
            print(f"      {text_snippet(m['desc'], phrases[0])}")
        print("-" * 72)
        print("Xem script mẫu: python tools/read_official.py <ID>")
        return 0

    # Chế độ tìm kiếm nếu truyền --search hoặc input chứa từ khóa không phải số
    is_all_numeric = bool(targets) and all(t.isdigit() for t in targets)
    if args.search or not is_all_numeric:
        search_query = " ".join(args.targets)
        cdb_paths = collect_cdb_paths(game_dir)
        if not cdb_paths:
            print(f"[ERROR] Không có file CDB nào từ game để tìm kiếm '{search_query}'.", file=sys.stderr)
            return 1

        matches = search_cards_by_name(search_query, cdb_paths)
        if not matches:
            print(f"Không tìm thấy card nào có tên chứa '{search_query}'.")
            return 1

        print(f"Tìm thấy {len(matches)} card phù hợp với '{search_query}':")
        print("-" * 72)
        for idx, m in enumerate(matches, 1):
            type_str = format_card_type(m["type"])
            print(f"  {idx:2d}. [{m['id']}] {m['name']} ({type_str})")
        print("-" * 72)

        # Nếu có 1 kết quả duy nhất hoặc có đúng 1 kết quả khớp chính xác tên card (khi không dùng cờ --search)
        target_to_read = None
        if len(matches) == 1:
            target_to_read = matches[0]
        elif not args.search:
            exact_matches = [m for m in matches if m["name"].strip().lower() == search_query.strip().lower()]
            if len(exact_matches) == 1:
                target_to_read = exact_matches[0]

        if target_to_read:
            exact_id = target_to_read["id"]
            print(f"\n[INFO] Tự động hiển thị chi tiết cho: {target_to_read['name']} (ID: {exact_id})")
            read_single_card(
                exact_id,
                game_dir=game_dir,
                dest_dir=dest_dir,
                copy_script=not args.no_copy,
                view_script=args.view,
                fetch_fallback=args.fetch,
                force_copy=args.force,
            )
        else:
            print("Chạy lại lệnh với passcode cụ thể để xem chi tiết và lấy script mẫu.")
        return 0

    # Xử lý danh sách passcode
    for target in targets:
        if not target.isdigit():
            print(f"[SKIP] Bỏ qua tham số không phải passcode số: '{target}'")
            continue
        code = int(target)
        read_single_card(
            code,
            game_dir=game_dir,
            dest_dir=dest_dir,
            copy_script=not args.no_copy,
            view_script=args.view,
            fetch_fallback=args.fetch,
            force_copy=args.force,
        )

    return 0


if __name__ == "__main__":
    sys.exit(main())
