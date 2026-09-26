#!/usr/bin/env python3
import json
import argparse
import sys
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')
if hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8')
import os
import re
import shutil
import subprocess
from datetime import datetime
from pathlib import Path

# manage_db nằm cùng thư mục; thêm tay vào sys.path để import được cả khi file
# này được nạp theo đường dẫn (test) chứ không qua `python tools/...`.
sys.path.insert(0, str(Path(__file__).resolve().parent))
import manage_db
import normalize_images

# Mapping of templates to default card types
TEMPLATE_TYPES = {
    "effect_monster": 0x21,       # Monster + Effect
    "normal_spell": 0x2,          # Spell
    "quick_play_spell": 0x10002,  # Spell + Quick-Play
    "continuous_spell": 0x20002,  # Spell + Continuous
    "normal_trap": 0x4,           # Trap
    "fusion_monster": 0x61,       # Monster + Fusion + Effect
    "synchro_monster": 0x2021,    # Monster + Synchro + Effect
    "xyz_monster": 0x800021,         # Monster + Xyz + Effect
    "link_monster": 0x4000021,    # Monster + Link + Effect
    "pendulum_monster": 0x1000021,# Monster + Pendulum + Effect
    "field_spell": 0x80002,       # Spell + Field
    "hand_trap": 0x21             # Monster + Effect (usually)
}

# Mỗi archetype giữ một block passcode = setcode * PASSCODE_BLOCK, theo quy ước
# đã dùng trong feature_list.json (0x16e -> 36600001-36699999).
PASSCODE_BLOCK = 100000
MAX_PASSCODE = 999999999
# Khóa archetype trùng tên thư mục docs/queues/<archetype>/
ARCHETYPE_KEY_RE = re.compile(r"[A-Za-z][A-Za-z0-9_]*$")
# Archetype fan-made của repo dùng dải 0x780 trở lên (0x780-0x785, 0x789 đã có);
# 'archetype add' không truyền setcode thì chọn setcode trống đầu tiên từ đây.
FANMADE_SETCODE_START = 0x780
# EDOPro so setcode theo 12 bit thấp (archetype gốc) cộng 4 bit cao (archetype con):
# 0x1004 được coi là archetype con của 0x4, nên trùng 12 bit thấp là trùng archetype.
SETCODE_BASE_MASK = 0xFFF
SETCODE_DEF_RE = re.compile(r"^\s*(SET_[A-Z0-9_]+)\s*=\s*0x([0-9a-fA-F]+)", re.M)
SETNAME_RE = re.compile(r"^!setname\s+0x([0-9a-fA-F]+)\s+(.+?)\s*$", re.M)

MONSTER_TEMPLATES = {
    "effect_monster", "fusion_monster", "synchro_monster", "xyz_monster",
    "link_monster", "pendulum_monster", "hand_trap",
}

# Đuôi ảnh chấp nhận trong queue; EDOPro chỉ nạp .jpg/.png
QUEUE_EXTS = (".jpg", ".jpeg", ".png", ".gif")
ARTWORK_EXTS = (".jpg", ".png")

# desc placeholder ghi vào spec JSON khi start; verify chặn nếu chưa thay
PLACEHOLDER_DESC = "Mô tả hiệu ứng..."
# Placeholder dạng <<...>> trong templates (vd <<ATK_VALUE>>) phải được thay hết
PLACEHOLDER_RE = re.compile(r"<<[^<>]*>>")

def get_project_paths():
    script_dir = Path(__file__).resolve().parent
    project_root = script_dir.parent
    return {
        "root": project_root,
        "feature_list": project_root / "feature_list.json",
        "script_dir": project_root / "script",
        "template_dir": project_root / "tools" / "templates",
        "card_data": project_root / "card-data",
        "queues_dir": project_root / "docs" / "queues",
        "pics_dir": project_root / "pics",
        "constants": project_root / "script" / "constants.lua",
        "strings": project_root / "strings.conf",
    }


def load_feature_list(paths):
    """Nội dung feature_list.json, hoặc None (đã báo lỗi) khi thiếu file."""
    if not paths["feature_list"].exists():
        print("Error: feature_list.json not found.", file=sys.stderr)
        return None
    with open(paths["feature_list"], "r", encoding="utf-8") as f:
        return json.load(f)


def save_feature_list(paths, fl_data):
    with open(paths["feature_list"], "w", encoding="utf-8") as f:
        json.dump(fl_data, f, ensure_ascii=False, indent=2)


def iter_cards(fl_data):
    """(archetype, card) của mọi card trong feature_list."""
    for arch_name, arch_info in fl_data.get("archetypes", {}).items():
        for card in arch_info.get("cards", []):
            yield arch_name, card


def find_archetype_by_passcode(fl_data, passcode):
    for name, info in fl_data.get("archetypes", {}).items():
        bounds, _ = parse_passcode_range(info.get("passcode_range", ""))
        if bounds and bounds[0] <= passcode <= bounds[1]:
            return name, info
    return "Common", fl_data.get("archetypes", {}).get("Common", {})

def normalize_archetype_key(name):
    """Khóa so sánh tên archetype: bỏ hoa/thường, '_' và khoảng trắng
    ('White_Forest' = 'White Forest' = 'SET_WHITE_FOREST' bỏ tiền tố)."""
    return re.sub(r"[^a-z0-9]", "", name.lower())


def parse_setcode(raw):
    """'0x16e' hoặc decimal -> int. Trả về (setcode, error)."""
    text = str(raw).strip()
    try:
        value = int(text, 16) if text.lower().startswith("0x") else int(text, 10)
    except ValueError:
        return None, f"setcode không hợp lệ: {raw!r} (dùng dạng hex '0x16e' hoặc decimal)"
    if not 0 < value <= 0xFFFF:
        return None, f"setcode phải trong khoảng 0x1-0xFFFF, nhận {text}"
    return value, None


def parse_passcode_range(raw):
    """'36600001-36699999' -> (start, end). Trả về (range, error)."""
    parts = str(raw).split("-")
    if len(parts) != 2:
        return None, f"range không hợp lệ: {raw!r} (dạng '36600001-36699999')"
    try:
        start, end = (int(part.strip()) for part in parts)
    except ValueError:
        return None, f"range không hợp lệ: {raw!r} (dạng '36600001-36699999')"
    if not 0 < start <= end <= MAX_PASSCODE:
        return None, f"range phải tăng dần và tối đa {MAX_PASSCODE}, nhận {raw!r}"
    return (start, end), None


def derive_passcode_range(setcode):
    """Block passcode mặc định của một setcode. Trả về (range, error)."""
    start = setcode * PASSCODE_BLOCK + 1
    end = setcode * PASSCODE_BLOCK + PASSCODE_BLOCK - 1
    if end > MAX_PASSCODE:
        return None, (f"setcode {hex(setcode)} cho range {start}-{end} vượt quá {MAX_PASSCODE} "
                      "(passcode tối đa 9 chữ số) — truyền --range để chọn block khác")
    return (start, end), None


def overlapping_archetype(archetypes, start, end):
    """(tên, range) của archetype có passcode range chồng lên start-end, hoặc None.

    Range chồng nhau nghĩa là hai archetype cùng tranh một passcode khi 'scan'
    hoặc 'start' cấp ID.
    """
    for existing_name, info in archetypes.items():
        other, _ = parse_passcode_range(info.get("passcode_range", ""))
        if other and start <= other[1] and other[0] <= end:
            return existing_name, other
    return None


def read_text_file(path):
    """Nội dung file, giữ nguyên kiểu xuống dòng; '' khi file không tồn tại."""
    try:
        with open(path, encoding="utf-8", newline="") as f:
            return f.read()
    except FileNotFoundError:
        return ""


def insert_line(path, line, before):
    """Chèn line trước dòng đầu tiên bắt đầu bằng before (không có thì cuối file)."""
    text = read_text_file(path)
    eol = "\r\n" if "\r\n" in text else "\n"
    lines = text.splitlines()
    index = next((i for i, existing in enumerate(lines) if existing.lower().startswith(before.lower())), len(lines))
    lines.insert(index, line)
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write(eol.join(lines) + eol)


def official_setcodes():
    """{setcode: 'SET_X'} của archetype official trong bản cài game, None khi không đọc được."""
    game_dir = Path(os.environ.get("EDOPRO_DIR") or manage_db.DEFAULT_EDOPRO_DIR)
    text = read_text_file(game_dir / "repositories" / "delta-bagooska" / "script" / "archetype_setcode_constants.lua")
    if not text:
        return None
    return {int(value, 16): const for const, value in SETCODE_DEF_RE.findall(text)}


def repo_setcodes(paths):
    """Setcode fan-made đã khai báo trong repo.

    Trả về (names, constants): names = {setcode: {tên}} gộp script/constants.lua
    (bỏ tiền tố SET_) và strings.conf; constants = {'SET_X': setcode}.
    """
    names, constants = {}, {}
    for const, value in SETCODE_DEF_RE.findall(read_text_file(paths["constants"])):
        constants[const] = int(value, 16)
        names.setdefault(int(value, 16), set()).add(const[len("SET_"):])
    for value, setname in SETNAME_RE.findall(read_text_file(paths["strings"])):
        names.setdefault(int(value, 16), set()).add(setname)
    return names, constants


def fanmade_setcode_conflict(setcode, key, official, repo_names, repo_constants):
    """Lý do setcode không dùng được cho archetype fan-made có khóa key, hoặc None."""
    base = setcode & SETCODE_BASE_MASK
    for code, const in (official or {}).items():
        if code & SETCODE_BASE_MASK == base:
            return (f"setcode {hex(setcode)} trùng archetype official {const} ({hex(code)}) — EDOPro coi card "
                    "mang setcode này là một phần của archetype đó")
    names = repo_names.get(setcode, set())
    if names and key not in {normalize_archetype_key(n) for n in names}:
        return (f"setcode {hex(setcode)} đã được dùng cho {', '.join(sorted(names))} "
                "trong script/constants.lua hoặc strings.conf")
    for const, value in repo_constants.items():
        if normalize_archetype_key(const[len("SET_"):]) == key and value != setcode:
            return f"{const} đã khai báo setcode {hex(value)} trong script/constants.lua"
    return None


def pick_fanmade_setcode(key, official, repo_names, repo_constants, registered, archetypes):
    """Setcode cho archetype fan-made khi 'archetype add' không truyền setcode.

    Tên đã có setcode trong constants.lua/strings.conf (archetype của dev khác
    chưa vào feature_list) thì dùng lại; không thì lấy setcode trống đầu tiên từ
    FANMADE_SETCODE_START có passcode range không chồng archetype nào.
    """
    for code, names in repo_names.items():
        if key in {normalize_archetype_key(n) for n in names}:
            return code
    for setcode in range(FANMADE_SETCODE_START, SETCODE_BASE_MASK + 1):
        if setcode in registered or setcode in repo_names:
            continue
        if fanmade_setcode_conflict(setcode, key, official, repo_names, repo_constants):
            continue
        bounds, error = derive_passcode_range(setcode)
        if error is None and overlapping_archetype(archetypes, *bounds) is None:
            return setcode
    return None


def register_fanmade_setcode(paths, name, setcode, repo_constants):
    """Ghi SET_ vào constants.lua và !setname vào strings.conf nếu còn thiếu.

    Trả về (tên hằng dùng trong Lua, danh sách file đã ghi).
    """
    key = normalize_archetype_key(name)
    const = next((c for c, v in repo_constants.items()
                  if v == setcode and normalize_archetype_key(c[len("SET_"):]) == key), None)
    written = []
    if const is None:
        const = "SET_" + re.sub(r"[^A-Z0-9]+", "_", name.upper()).strip("_")
        insert_line(paths["constants"], f"{const:<34}= 0x{setcode:x}", "-- Custom counter")
        written.append("script/constants.lua")
    if setcode not in {int(v, 16) for v, _ in SETNAME_RE.findall(read_text_file(paths["strings"]))}:
        insert_line(paths["strings"], f"!setname 0x{setcode:x} {name.replace('_', ' ')}", "#Custom Counter")
        written.append("strings.conf")
    return const, written


def add_archetype(name, setcode_raw=None, range_raw=None):
    """Đăng ký archetype mới vào feature_list.json.

    AGENTS.md cấm sửa tay feature_list.json, nên đây là đường duy nhất để mở
    một archetype mới trước khi 'start' cấp passcode cho card của nó. Setcode
    official (có trong bản cài game) chỉ được đăng ký; setcode fan-made được
    kiểm tra trùng rồi ghi luôn vào script/constants.lua và strings.conf.
    """
    paths = get_project_paths()

    if not ARCHETYPE_KEY_RE.match(name):
        print(f"Error: tên archetype '{name}' không hợp lệ — dùng chữ/số/'_' và bắt đầu bằng chữ "
              "(vd Icejade, White_Forest).", file=sys.stderr)
        return False

    fl_data = load_feature_list(paths)
    if fl_data is None:
        return False
    archetypes = fl_data.setdefault("archetypes", {})

    key = normalize_archetype_key(name)
    registered = {}
    for existing_name, info in archetypes.items():
        if normalize_archetype_key(existing_name) == key:
            print(f"Error: archetype '{existing_name}' đã tồn tại trong feature_list.json.", file=sys.stderr)
            return False
        existing_setcode, _ = parse_setcode(info.get("setcode", "0"))
        if existing_setcode:
            registered[existing_setcode] = existing_name

    official = official_setcodes()
    if official is None:
        print("Warning: không đọc được archetype_setcode_constants.lua của bản cài EDOPro ($EDOPRO_DIR) — "
              "không phân biệt được archetype official với fan-made.", file=sys.stderr)
    repo_names, repo_constants = repo_setcodes(paths)

    if setcode_raw is None:
        if official is None:
            print("Error: cần bản cài game để chọn setcode trống; truyền setcode thủ công.", file=sys.stderr)
            return False
        setcode = pick_fanmade_setcode(key, official, repo_names, repo_constants, registered, archetypes)
        if setcode is None:
            print(f"Error: không còn setcode fan-made trống từ {hex(FANMADE_SETCODE_START)}.", file=sys.stderr)
            return False
    else:
        setcode, error = parse_setcode(setcode_raw)
        if error:
            print(f"Error: {error}", file=sys.stderr)
            return False

    if setcode in registered:
        print(f"Error: setcode {hex(setcode)} đã thuộc archetype '{registered[setcode]}'.", file=sys.stderr)
        return False
    official_const = (official or {}).get(setcode)
    if official_const is None:
        error = fanmade_setcode_conflict(setcode, key, official, repo_names, repo_constants)
        if error:
            print(f"Error: {error}.", file=sys.stderr)
            return False

    if range_raw:
        bounds, error = parse_passcode_range(range_raw)
    else:
        bounds, error = derive_passcode_range(setcode)
    if error:
        print(f"Error: {error}", file=sys.stderr)
        return False
    start, end = bounds
    overlap = overlapping_archetype(archetypes, start, end)
    if overlap:
        other_name, other = overlap
        print(f"Error: range {start}-{end} chồng lên '{other_name}' ({other[0]}-{other[1]}).", file=sys.stderr)
        return False

    if official_const is None:
        const, written = register_fanmade_setcode(paths, name, setcode, repo_constants)
    archetypes[name] = {"setcode": f"0x{setcode:x}", "passcode_range": f"{start}-{end}", "cards": []}
    fl_data["last_updated"] = datetime.now().strftime("%Y-%m-%d")
    save_feature_list(paths, fl_data)

    print(f"Registered archetype '{name}': setcode 0x{setcode:x}, passcode range {start}-{end}.")
    if official_const:
        print(f"Archetype official: dùng {official_const} trong Lua; EDOPro đã có tên hiển thị, "
              "không thêm vào script/constants.lua hay strings.conf.")
    else:
        done = f"đã ghi {', '.join(written)}" if written else "script/constants.lua và strings.conf đã có sẵn"
        print(f"Archetype fan-made: dùng {const} trong Lua kèm Duel.LoadScript(\"constants.lua\") ({done}).")
    print(f"Tạo card: đặt ảnh p_<tên>.jpg vào docs/queues/{name}/ rồi chạy 'scan', hoặc")
    print(f"   python tools/manage_harness.py start {start} \"<name>\" <template>")
    return True


def locate_queue_image(queues_dir, card_name, archetype):
    # Try searching under the specific archetype folder, then globally
    normalized_name = card_name.lower().replace(" ", "_").replace("'", "").replace("-", "_")
    search_dirs = []
    if queues_dir.joinpath(archetype).is_dir():
        search_dirs.append(queues_dir / archetype)
    search_dirs.append(queues_dir)
    
    extensions = [f"*{ext}" for ext in QUEUE_EXTS]
    
    for s_dir in search_dirs:
        for ext in extensions:
            for p in s_dir.rglob(ext):
                # Match files starting with p_ and containing card name words
                if p.name.startswith("p_"):
                    # Check if normalized name or keywords match the filename
                    cleaned_filename = p.stem.lower()
                    if normalized_name in cleaned_filename or all(word in cleaned_filename for word in normalized_name.split("_") if len(word) > 2):
                        return p
    return None

def strip_queue_prefix(stem):
    """Bỏ tiền tố trạng thái p_/w_/d_ khỏi tên file queue."""
    return stem[2:] if stem[:2] in ("p_", "w_", "d_") else stem


def queue_key(rel_path):
    """Khóa nhận dạng ảnh queue không phụ thuộc tiền tố trạng thái hay đuôi file,
    để cleanup vẫn khớp khi feature_list còn ghi 'w_' mà đĩa đã là 'd_'."""
    path = Path(rel_path)
    return f"{path.parent.as_posix()}/{strip_queue_prefix(path.stem)}".lower()


def find_artwork(pics_dir, passcode):
    """Artwork đang có trong pics/ cho passcode, hoặc None."""
    for ext in ARTWORK_EXTS:
        candidate = pics_dir / f"{passcode}{ext}"
        if candidate.exists():
            return candidate
    return None


def copy_artwork_from_queue(pics_dir, passcode, queue_path):
    """Copy ảnh queue vào pics/<passcode>.<ext> rồi đọc lại đối chiếu byte.

    Trả về (pic_path, None) khi ghi và đọc lại khớp, ngược lại (None, lý do).
    .jpeg đổi sang .jpg vì EDOPro không nạp .jpeg.
    """
    ext = queue_path.suffix.lower()
    if ext == ".jpeg":
        ext = ".jpg"
    if ext not in ARTWORK_EXTS:
        return None, f"{queue_path.name} dùng đuôi {queue_path.suffix} — EDOPro chỉ nạp .jpg/.png, đổi thủ công trước"
    pic_path = pics_dir / f"{passcode}{ext}"
    try:
        pics_dir.mkdir(parents=True, exist_ok=True)
        source = queue_path.read_bytes()
        pic_path.write_bytes(source)
        if pic_path.read_bytes() != source:
            return None, f"ghi pics/{pic_path.name} xong nhưng đọc lại không khớp"
    except Exception as e:
        return None, f"copy {queue_path.name} -> pics/{passcode}{ext} thất bại: {e}"
    return pic_path, None


def retire_queue_image(paths, passcode, queue_path):
    """Xác nhận artwork đã nằm trong pics/ rồi mới xóa ảnh queue.

    Thiếu artwork thì copy từ chính ảnh queue và đọc lại để xác nhận. Chỉ xóa
    khi đã cầm chắc bản trong pics/; không xác nhận được thì giữ nguyên ảnh
    queue và trả lý do cho caller xử lý.
    Trả về (deleted: bool, message: str).
    """
    pic_path = find_artwork(paths["pics_dir"], passcode)
    if pic_path is None:
        pic_path, error = copy_artwork_from_queue(paths["pics_dir"], passcode, queue_path)
        if error:
            return False, error
        message = f"Đã copy artwork {queue_path.name} -> pics/{pic_path.name}"
    else:
        try:
            same = pic_path.read_bytes() == queue_path.read_bytes()
        except Exception as e:
            return False, f"không đọc được pics/{pic_path.name} hoặc {queue_path.name} để đối chiếu: {e}"
        message = f"Artwork pics/{pic_path.name} đã có" + ("" if same else " (khác bản queue — giữ bản trong pics/)")
    try:
        queue_path.unlink()
    except Exception as e:
        return False, f"{message}; xóa {queue_path.name} thất bại: {e}"
    return True, f"{message}; đã xóa queue image {queue_path.name}"


def build_spec_skeleton(passcode, card_name, template_type, setcode_val):
    """Tạo skeleton spec JSON theo loại template, ưu tiên field thân thiện
    (setcodes/linkmarkers/lscale/rscale) để compiler tự đóng gói bitfield."""
    t = template_type.lower()
    spec = {
        "id": passcode,
        "ot": 32,
        "alias": 0,
        "type": TEMPLATE_TYPES.get(t, 0x21),
    }
    if setcode_val:
        spec["setcodes"] = [setcode_val]
    else:
        spec["setcode"] = 0
    spec["atk"] = 0
    if t == "link_monster":
        spec["linkmarkers"] = []  # compiler đóng gói vào cột def
    else:
        spec["def"] = 0
    spec["level"] = 0
    if t == "pendulum_monster":
        spec["lscale"] = 0
        spec["rscale"] = 0
    spec["race"] = 0
    spec["attribute"] = 0
    spec["category"] = 0
    spec["name"] = card_name
    spec["desc"] = PLACEHOLDER_DESC
    spec["strings"] = []
    return spec


def print_next_steps(passcode, template_type):
    """In checklist các field bắt buộc phải điền — validator sẽ chặn nếu bỏ sót."""
    t = template_type.lower()
    print("\n=== Việc cần làm tiếp theo (validator sẽ chặn verify nếu bỏ sót) ===")
    print(f"1. card-data/c{passcode}.json — điền:")
    print(f"   - desc: effect text thật (placeholder '{PLACEHOLDER_DESC}' bị chặn)")
    if t in MONSTER_TEMPLATES:
        print("   - race / attribute: ghi tên, vd \"Warrior\", \"LIGHT\" (đúng 1 giá trị)")
        if t == "link_monster":
            print("   - level: Link rating; linkmarkers: tên marker (vd [\"Bottom-Left\",\"Bottom\"])")
            print("   - atk (Link không có def)")
        else:
            print("   - level (Rank nếu Xyz), atk, def (\"?\" nếu ATK/DEF ?)")
        if t == "pendulum_monster":
            print("   - lscale / rscale: Pendulum Scale")
    print("   - category: danh sách tên, vd [\"Search\", \"Send to Hand\"]; strings: prompt cho aux.Stringid")
    print(f"2. script/c{passcode}.lua — thay hết placeholder <<...>>, viết logic effect")
    print("   (tìm official cùng cơ chế: python tools/read_official.py --text \"<cụm trong effect>\")")
    print(f"3. Artwork pics/{passcode}.jpg|.png — verify tự copy từ queue image nếu còn;")
    print("   tự thêm thì KHÔNG dùng .jpeg (EDOPro không nạp)")
    print(f"4. Chạy: python .\\tools\\manage_harness.py verify {passcode}")


def start_card(passcode, card_name, template_type):
    paths = get_project_paths()

    # ===== Pre-flight: kiểm tra mọi điều kiện TRƯỚC khi thay đổi bất kỳ file nào =====
    # 1. Template phải tồn tại
    template_file = paths["template_dir"] / f"template_{template_type.lower()}.lua"
    if not template_file.exists():
        print(f"Error: Template '{template_type}' not found. Available templates:", file=sys.stderr)
        for t_file in paths["template_dir"].glob("template_*.lua"):
            print(f"  - {t_file.stem.replace('template_', '')}", file=sys.stderr)
        return False

    # 2. Không ghi đè file đã có (card đang code dở hoặc đã xong)
    json_path = paths["card_data"] / f"c{passcode}.json"
    script_path = paths["script_dir"] / f"c{passcode}.lua"
    clobber = [p for p in (json_path, script_path) if p.exists()]
    if clobber:
        for p in clobber:
            print(f"Error: {p.relative_to(paths['root'])} đã tồn tại — 'start' không ghi đè.", file=sys.stderr)
        print("Nếu muốn sửa card này, chỉnh trực tiếp file rồi chạy 'verify'. "
              "Nếu muốn làm lại từ đầu, xóa các file trên trước.", file=sys.stderr)
        return False

    # 3. Passcode chỉ được dùng lại khi entry đang 'pending' (do scan cấp)
    fl_data = load_feature_list(paths)
    if fl_data is None:
        return False

    matches = [(arch_name, card) for arch_name, card in iter_cards(fl_data)
               if card.get("passcode") == str(passcode)]
    for arch_name, card in matches:
        if card.get("status") != "pending":
            print(f"Error: Passcode {passcode} is already registered under '{arch_name}' (Card: '{card['name']}') with status '{card.get('status')}'.", file=sys.stderr)
            return False
    existing_archetype, existing_card = matches[-1] if matches else (None, None)

    if existing_archetype:
        archetype = existing_archetype
        arch_info = fl_data["archetypes"][archetype]
    else:
        archetype, arch_info = find_archetype_by_passcode(fl_data, passcode)
    print(f"Assigning card to Archetype: {archetype}")

    setcode_val, _ = parse_setcode(arch_info.get("setcode", "0"))
    setcode_val = setcode_val or 0

    # ===== Mutations: tạo file trước, đổi tên queue & ghi feature_list sau cùng =====
    # 4. Create specs JSON
    paths["card_data"].mkdir(parents=True, exist_ok=True)
    spec_data = build_spec_skeleton(passcode, card_name, template_type, setcode_val)

    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(spec_data, f, ensure_ascii=False, indent=2)
    print(f"Created spec JSON: {json_path.relative_to(paths['root'])}")

    # 5. Copy template Lua script (lỗi thì dọn JSON vừa tạo để không để lại trạng thái nửa vời)
    try:
        with open(template_file, "r", encoding="utf-8") as f:
            content = f.read()

        # Replace template placeholders
        content = content.replace("<<CARD_NAME>>", card_name)
        content = content.replace("<<PASSCODE>>", str(passcode))
        content = content.replace("<<SETCODE>>", f"{setcode_val:x}" if setcode_val > 0 else "0")
        content = content.replace("<<ARCHETYPE_NAME>>", archetype)

        with open(script_path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"Created Lua script: {script_path.relative_to(paths['root'])}")
    except Exception as e:
        json_path.unlink(missing_ok=True)
        print(f"Error creating Lua script (đã rollback specs JSON): {e}", file=sys.stderr)
        return False

    # 6. Locate & rename queue file (p_ -> w_)
    queue_file = None
    if existing_card and existing_card.get("queue_file"):
        potential_path = paths["root"] / existing_card["queue_file"]
        if potential_path.exists():
            queue_file = potential_path

    if not queue_file:
        queue_file = locate_queue_image(paths["queues_dir"], card_name, archetype)

    new_queue_file_path = None
    if queue_file:
        # Rename from p_ to w_ (working)
        new_name = queue_file.name.replace("p_", "w_", 1)
        new_path = queue_file.parent / new_name
        try:
            shutil.move(str(queue_file), str(new_path))
            new_queue_file_path = str(new_path.relative_to(paths["root"]).as_posix())
            print(f"Located queue image: {queue_file.name} -> Renamed to {new_name}")
        except Exception as e:
            print(f"Warning: Failed to rename queue image: {e}", file=sys.stderr)
            new_queue_file_path = str(queue_file.relative_to(paths["root"]).as_posix())
    else:
        print("No pending queue image found matching card name.")

    # 7. Append or update in feature_list.json
    if existing_card:
        # Tên trong entry pending do scan suy từ tên file queue nên hay sai
        # chính tả; tên truyền vào lệnh start mới là tên chốt của card.
        if existing_card.get("name") != card_name:
            print(f"Renamed pending card {passcode}: '{existing_card.get('name')}' -> '{card_name}'")
        existing_card["name"] = card_name
        existing_card["status"] = "working"
        existing_card["script"] = f"script/c{passcode}.lua"
        if new_queue_file_path:
            existing_card["queue_file"] = new_queue_file_path
        print(f"Updated existing pending card {passcode} to 'working' status.")
    else:
        new_card_entry = {
            "name": card_name,
            "passcode": str(passcode),
            "status": "working",
            "script": f"script/c{passcode}.lua"
        }
        if new_queue_file_path:
            new_card_entry["queue_file"] = new_queue_file_path

        fl_data["archetypes"].setdefault(archetype, {"cards": []})["cards"].append(new_card_entry)

    save_feature_list(paths, fl_data)
    print(f"Added/updated card in feature_list.json under '{archetype}'.")
    print(f"Status set to 'working'. Happy coding!")
    print_next_steps(passcode, template_type)
    return True

def run_command(args, cwd):
    # Dùng sys.executable cho lệnh python để không phụ thuộc PATH/alias
    if args and args[0] == "python":
        args = [sys.executable] + args[1:]
    result = subprocess.run(args, cwd=str(cwd), stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                            encoding='utf-8', errors='replace')
    return result.returncode, result.stdout, result.stderr

def preflight_card(paths, passcode):
    """Kiểm tra nhanh trước pipeline: file tồn tại, hết placeholder, artwork đúng đuôi.

    Trả về (errors, warnings). errors khác rỗng -> chặn verify ngay, đỡ tốn
    thời gian compile/validate cả project chỉ để fail vì thiếu file.
    """
    errors, warnings = [], []
    json_path = paths["card_data"] / f"c{passcode}.json"
    script_path = paths["script_dir"] / f"c{passcode}.lua"

    if not json_path.exists():
        errors.append(f"Thiếu specs JSON: card-data/c{passcode}.json (chạy 'start' trước)")
    else:
        try:
            with open(json_path, "r", encoding="utf-8") as f:
                spec = json.load(f)
            desc = spec.get("desc", "")
            if not isinstance(desc, str) or not desc.strip() or desc.strip() == PLACEHOLDER_DESC:
                errors.append(f"Specs JSON: 'desc' rỗng hoặc vẫn là placeholder '{PLACEHOLDER_DESC}' — điền effect text thật")
        except Exception as e:
            errors.append(f"Specs JSON không đọc được: {e}")

    if not script_path.exists():
        errors.append(f"Thiếu Lua script: script/c{passcode}.lua (chạy 'start' trước)")
    else:
        try:
            content = script_path.read_text(encoding="utf-8")
            leftover = sorted(set(PLACEHOLDER_RE.findall(content)))
            if leftover:
                errors.append(f"Lua script còn placeholder template chưa thay: {', '.join(leftover)}")
            if "XXXXXXXXX" in content:
                errors.append("Lua script còn placeholder passcode 'XXXXXXXXX'")
        except Exception as e:
            errors.append(f"Lua script không đọc được: {e}")

    # Artwork: EDOPro chỉ load .jpg/.png; đuôi .jpeg cho ảnh trống trong game
    pics_dir = paths["pics_dir"]
    wrong_ext = pics_dir / f"{passcode}.jpeg"
    artwork = find_artwork(pics_dir, passcode)
    if wrong_ext.exists():
        errors.append(f"Artwork pics/{passcode}.jpeg dùng đuôi .jpeg — EDOPro không load, đổi tên thành .jpg")
    elif artwork is None:
        warnings.append(f"Chưa có artwork pics/{passcode}.jpg|.png — verify sẽ copy từ queue image nếu còn, "
                        "không thì card hiển thị ảnh trống trong game")
    else:
        # Đuôi phải khớp định dạng thật: PNG mang đuôi .jpg làm EDOPro văng JPEG FATAL ERROR.
        fmt, _ = normalize_images.detect_file_format(artwork)
        expected = {"JPEG": ".jpg", "MPO": ".jpg", "PNG": ".png"}.get(fmt)
        if expected != artwork.suffix.lower():
            errors.append(f"Artwork pics/{artwork.name} thực chất là {fmt} — chạy "
                          "'python tools/normalize_images.py --to-jpg' rồi thêm --apply để chuẩn hóa về JPEG")

    return errors, warnings


def verify_card(passcode):
    paths = get_project_paths()
    print(f"Starting verification pipeline for Card passcode: {passcode}...")

    # 0. Pre-flight: file tồn tại, hết placeholder, artwork hợp lệ
    print("Step 0: Pre-flight checks (files, placeholders, artwork)...")
    pf_errors, pf_warnings = preflight_card(paths, passcode)
    for w in pf_warnings:
        print(f"  [WARN ] {w}")
    if pf_errors:
        for e in pf_errors:
            print(f"  [ERROR] {e}", file=sys.stderr)
        print("Error: Pre-flight failed. Sửa các lỗi trên rồi chạy lại verify.", file=sys.stderr)
        return False
    print("Pre-flight passed.")

    # 1. Validate + Compile Database Specs (atomic, theo chuẩn Datacorn)
    print("Step 1: Validating & compiling JSON specs to database...")
    rc, stdout, stderr = run_command(["python", "tools/manage_db.py", "compile"], paths["root"])
    if rc != 0:
        print("Error: DB Validation/Compilation failed! CDB cũ được giữ nguyên.", file=sys.stderr)
        if stdout and stdout.strip():
            print(stdout.strip(), file=sys.stderr)
        if stderr and stderr.strip():
            print(stderr.strip(), file=sys.stderr)
        return False
    # Hiển thị warning validation (không chặn nhưng nên xử lý)
    for line in (stdout or "").splitlines():
        if "[WARN" in line:
            print(f"  {line.strip()}")
    print("Database validated & compiled successfully.")

    # 2. Run validate_scripts.ps1 (chỉ file của card này — nhanh hơn quét cả project,
    #    và rc!=0 chặn trực tiếp thay vì chỉ soi text output)
    print("Step 2: Validating script structure and syntax...")
    rc, stdout, stderr = run_command(
        ["powershell", "-ExecutionPolicy", "Bypass", "-File", "tools/validate_scripts.ps1",
         "-Path", f"script/c{passcode}.lua"], paths["root"])

    # Validator in dòng trạng thái kèm tên file, các dòng lý do (CONST:, API:...) thụt lề
    # ngay bên dưới; phải in cả hai thì agent mới biết sửa gì.
    file_failed = False
    in_block = False
    for line in (stdout or "").splitlines():
        if f"c{passcode}.lua" in line:
            print(f"  Validator output: {line.strip()}")
            file_failed = file_failed or "FAIL" in line
            in_block = True
        elif in_block and line.startswith(" ") and line.strip():
            print(f"    {line.strip()}")
        else:
            in_block = False

    if rc != 0 or file_failed:
        print("Error: Script validation failed for this passcode. Please fix errors before declaring success.", file=sys.stderr)
        if stderr and stderr.strip():
            print(stderr.strip(), file=sys.stderr)
        return False
    print("Script validation checked out.")

    # 3. Check sync status
    print("Step 3: Running system sync check...")
    rc, stdout, stderr = run_command(["python", "tools/manage_db.py", "check-sync"], paths["root"])
    print(stdout.strip())
    if rc != 0:
        print("Error: System synchronization failed. Cannot declare passing.", file=sys.stderr)
        if stderr and stderr.strip():
            print(stderr.strip(), file=sys.stderr)
        return False
    print("System sync verified successfully.")

    # 4. Update status to done and finalize queue file name
    print("Step 4: Updating state to done...")
    fl_data = load_feature_list(paths)
    if fl_data is None:
        return False

    card = next((card for _, card in iter_cards(fl_data) if card.get("passcode") == str(passcode)), None)
    if card is None:
        print(f"Warning: Card {passcode} not found in feature_list.json. Cannot update status.")
        return False
    card["status"] = "done"

    # Ảnh queue hết vai trò khi artwork đã vào pics/: copy nếu thiếu,
    # xác nhận, rồi xóa để queue không phình ra theo thời gian.
    queue_path_str = card.get("queue_file")
    q_path = paths["root"] / queue_path_str if queue_path_str else None
    if q_path and q_path.exists():
        deleted, message = retire_queue_image(paths, passcode, q_path)
        if deleted:
            card.pop("queue_file", None)
            print(message)
        else:
            print(f"Warning: {message}", file=sys.stderr)
            # Chưa xác nhận được artwork: giữ ảnh, chỉ đánh dấu done
            if q_path.name.startswith("w_"):
                new_path = q_path.parent / q_path.name.replace("w_", "d_", 1)
                try:
                    shutil.move(str(q_path), str(new_path))
                    card["queue_file"] = str(new_path.relative_to(paths["root"]).as_posix())
                    print(f"Giữ queue image, đổi tên sang trạng thái done: {new_path.name}")
                except Exception as e:
                    print(f"Warning: Failed to rename queue image: {e}", file=sys.stderr)

    save_feature_list(paths, fl_data)
    print(f"\nSUCCESS: Card {passcode} passed static validation; legacy status set to 'done'.")
    print("EDOPro runtime behavior is NOT verified. Run in-game scenarios before declaring the card complete.")

    return True

def name_from_queue_stem(stem):
    """Tên card suy từ tên file queue: 'p_blue_eyes_and_the_dragon' -> 'Blue Eyes & the Dragon'."""
    words = []
    for word in strip_queue_prefix(stem).split("_"):
        lower = word.lower()
        if lower == "and":
            words.append("&")
        elif lower == "the" and words:
            words.append("the")
        elif lower in ("in", "of", "to", "for", "with", "by", "at", "from"):
            words.append(lower)
        else:
            words.append(word.capitalize())
    return " ".join(words)


def next_free_passcode(arch_name, arch_info, taken_codes):
    """Passcode trống đầu tiên trong range của archetype; hết range thì lấy dải chung 799000xx."""
    raw_range = arch_info.get("passcode_range")
    if raw_range:
        bounds, error = parse_passcode_range(raw_range)
        if error:
            print(f"Error calculating passcode range for {arch_name}: {error}")
        else:
            candidate = bounds[0]
            while candidate in taken_codes:
                candidate += 1
            if candidate <= bounds[1]:
                return candidate

    common_candidates = [code for code in taken_codes if str(code).startswith("799000")]
    candidate = max(common_candidates) + 1 if common_candidates else 79900001
    while candidate in taken_codes:
        candidate += 1
    return candidate


def scan_pending_cards():
    paths = get_project_paths()
    fl_data = load_feature_list(paths)
    if fl_data is None:
        return False
    archetypes = fl_data.setdefault("archetypes", {})

    # Ảnh đã đăng ký (bất kể tiền tố trạng thái) và passcode đã cấp thì bỏ qua
    registered_stems = set()
    registered_passcodes = set()
    for _, card in iter_cards(fl_data):
        if "queue_file" in card:
            registered_stems.add(strip_queue_prefix(Path(card["queue_file"]).stem).lower())
        if "passcode" in card:
            registered_passcodes.add(card["passcode"])

    queues_dir = paths["queues_dir"]
    if not queues_dir.is_dir():
        # Git không lưu thư mục rỗng nên clone mới chưa có docs/queues/
        print(f"{queues_dir.relative_to(paths['root']).as_posix()}/ chưa tồn tại — tạo "
              "docs/queues/<Archetype>/ rồi đặt ảnh p_<tên card>.jpg vào đó.")
        return True
    found_pending = [
        p for ext in QUEUE_EXTS for p in queues_dir.rglob(f"*{ext}")
        if p.name.startswith("p_") and strip_queue_prefix(p.stem).lower() not in registered_stems
    ]
    if not found_pending:
        print("No new pending cards found in the queue directory.")
        return True

    print(f"Found {len(found_pending)} new pending queue files. Registering...")

    # Passcode phải chưa dùng trong MỌI CDB, không chỉ trong feature_list
    # (docs/agent-rules.md §2.1) — trùng ID thì EDOPro nạp nhầm card.
    taken_codes, missing_game_dir = manage_db.external_passcodes(paths["root"])
    if missing_game_dir is not None:
        print(f"Warning: không thấy bản cài EDOPro tại {missing_game_dir} — passcode chỉ được đối chiếu với "
              "CDB trong repo. Đặt $EDOPRO_DIR để kiểm tra cả CDB của game.", file=sys.stderr)
    taken_codes |= {int(code) for code in registered_passcodes if str(code).isdigit()}

    for p_path in found_pending:
        # Thư mục chứa ảnh là archetype; ảnh nằm thẳng trong queues/ hoặc thư mục lạ thì vào Common
        folder = "Common" if p_path.parent == queues_dir else p_path.parent.name
        arch_name = next((name for name in archetypes
                          if normalize_archetype_key(name) == normalize_archetype_key(folder)), "Common")
        arch_info = archetypes.setdefault(arch_name, {"cards": []})

        card_name = name_from_queue_stem(p_path.stem)
        passcode = next_free_passcode(arch_name, arch_info, taken_codes)
        taken_codes.add(passcode)

        arch_info["cards"].append({
            "name": card_name,
            "passcode": str(passcode),
            "status": "pending",
            "queue_file": p_path.relative_to(paths["root"]).as_posix(),
        })
        print(f"  [+] Registered: {card_name} (Passcode: {passcode}) under '{arch_name}'")

    fl_data["last_updated"] = datetime.now().strftime("%Y-%m-%d")
    save_feature_list(paths, fl_data)
    print(f"Successfully registered {len(found_pending)} new pending cards in feature_list.json!")
    return True

def tracked_paths(root, subdir):
    """Đường dẫn dưới subdir đang được Git theo dõi; None khi không hỏi được Git.

    Chỉ file đã commit mới khôi phục được sau khi xóa, nên file chưa track phải
    được cảnh báo riêng thay vì gộp chung vào câu "vẫn khôi phục từ history".
    """
    try:
        result = subprocess.run(["git", "ls-files", "-z", "--", subdir],
                                cwd=str(root), stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    except OSError:
        return None
    if result.returncode != 0:
        return None
    return {entry for entry in result.stdout.decode("utf-8", "replace").split("\0") if entry}


def cleanup_queue(apply_changes=False):
    """Dọn ảnh queue đã done, chỉ xóa file đã có artwork tương ứng trong pics/.

    Mặc định chỉ liệt kê. Cần --apply mới xóa thật và gỡ 'queue_file' khỏi
    feature_list. File chưa đăng ký, chưa done hoặc chưa có artwork đều được
    giữ lại và báo lý do, vì lúc đó ảnh queue có thể là bản duy nhất.
    """
    paths = get_project_paths()
    fl_data = load_feature_list(paths)
    if fl_data is None:
        return False

    if not paths["queues_dir"].is_dir():
        print(f"Error: {paths['queues_dir']} không tồn tại.", file=sys.stderr)
        return False

    # Khóa của mọi ảnh còn trên đĩa, kể cả ảnh chưa done: ref chỉ lệch tiền tố
    # trạng thái vẫn khớp được nhờ queue_key.
    existing_keys = {
        queue_key(image.relative_to(paths["root"]).as_posix())
        for image in paths["queues_dir"].rglob("*")
        if image.is_file() and image.suffix.lower() in QUEUE_EXTS
    }

    # Tra ngược từ đường dẫn ảnh về card để biết passcode và trạng thái.
    # Ref không khớp ảnh nào là rác: ảnh đã bị dọn hoặc gỡ khỏi repo từ trước.
    # Giữ lại chỉ làm mọi lệnh đọc queue hiểu sai trạng thái card.
    card_by_queue = {}
    stale_refs = []
    for _, card in iter_cards(fl_data):
        queue_file = card.get("queue_file")
        if not queue_file:
            continue
        key = queue_key(queue_file)
        if key in existing_keys:
            card_by_queue[key] = card
        else:
            stale_refs.append((card, queue_file))

    for card, queue_file in stale_refs:
        print(f"  [GỠ  ] {queue_file} — ảnh không còn, gỡ 'queue_file' của {card.get('passcode')}")
        if apply_changes:
            card.pop("queue_file", None)

    images = sorted(
        p for p in paths["queues_dir"].rglob("d_*")
        if p.is_file() and p.suffix.lower() in QUEUE_EXTS
    )
    if not images:
        print("Queue không còn ảnh done nào để dọn.")

    ready, kept = [], []
    for image in images:
        rel = image.relative_to(paths["root"]).as_posix()
        card = card_by_queue.get(queue_key(rel))
        if card is None:
            kept.append((rel, "chưa đăng ký trong feature_list"))
        elif card.get("status") != "done":
            kept.append((rel, f"status='{card.get('status')}', chưa done"))
        elif not card.get("passcode"):
            kept.append((rel, "card thiếu passcode"))
        elif find_artwork(paths["pics_dir"], card["passcode"]) is None:
            kept.append((rel, f"chưa có artwork pics/{card['passcode']}.jpg|.png — copy artwork trước"))
        else:
            ready.append((rel, image, card))

    for rel, reason in kept:
        print(f"  [GIỮ ] {rel} — {reason}")

    tracked = tracked_paths(paths["root"], paths["queues_dir"].relative_to(paths["root"]).as_posix())
    untracked = 0
    freed = 0
    failed = 0
    for rel, image, card in ready:
        size = image.stat().st_size
        note = ""
        if tracked is not None and rel not in tracked:
            note = " [CHƯA COMMIT — xóa là mất hẳn]"
            untracked += 1
        if not apply_changes:
            print(f"  [XÓA ] {rel} (artwork pics/{card['passcode']} đã có, {size / 1024:.0f} KB){note}")
            freed += size
            continue
        try:
            image.unlink()
        except Exception as e:
            print(f"  [LỖI ] {rel} — xóa thất bại: {e}", file=sys.stderr)
            failed += 1
            continue
        card.pop("queue_file", None)
        freed += size
        print(f"  [XÓA ] {rel}{note}")

    if apply_changes and (ready or stale_refs):
        save_feature_list(paths, fl_data)

    verb = "Đã xóa" if apply_changes else "Sẽ xóa"
    print()
    print(f"{verb} {len(ready) - failed}/{len(images)} ảnh queue (~{freed / 1048576:.1f} MB), giữ lại {len(kept)}.")
    if stale_refs:
        gone = "Đã gỡ" if apply_changes else "Sẽ gỡ"
        print(f"{gone} {len(stale_refs)} tham chiếu 'queue_file' trỏ tới ảnh không còn.")
    if untracked:
        print(f"Cảnh báo: {untracked} ảnh chưa được Git theo dõi — xóa xong KHÔNG khôi phục được từ history. "
              "Commit trước nếu còn cần bản gốc.")
    if not apply_changes and (ready or stale_refs):
        print("Đây là dry-run. Chạy lại với --apply để áp dụng thật (ảnh đã commit vẫn khôi phục được từ Git history).")
    return failed == 0


def main():
    parser = argparse.ArgumentParser(description="TTF Custom Cards Harness Management CLI Tool")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # Subcommand: start
    start_parser = subparsers.add_parser("start", help="Initialize a new custom card development")
    start_parser.add_argument("passcode", type=int, help="Card passcode (9 digits)")
    start_parser.add_argument("name", type=str, help="Card name")
    start_parser.add_argument("template", type=str, choices=list(TEMPLATE_TYPES.keys()), help="Template type to copy")

    # Subcommand: verify
    verify_parser = subparsers.add_parser("verify", help="Run static check-sync and syntax checks (runtime unverified); set legacy done status")
    verify_parser.add_argument("passcode", type=int, help="Card passcode to verify")

    # Subcommand: scan
    subparsers.add_parser("scan", help="Scan queues directory for new pending cards and register them in feature_list.json")

    # Subcommand: archetype
    archetype_parser = subparsers.add_parser("archetype", help="Manage the archetype registry in feature_list.json")
    archetype_sub = archetype_parser.add_subparsers(dest="archetype_command", required=True)
    archetype_add = archetype_sub.add_parser("add", help="Register a new archetype with its setcode and passcode range")
    archetype_add.add_argument("name", type=str, help="Archetype key, e.g. Icejade or White_Forest")
    archetype_add.add_argument("setcode", type=str, nargs="?",
                               help="Setcode in hex (0x16e) or decimal; omit for a new fan-made archetype "
                                    "to pick a free one and write it to script/constants.lua and strings.conf")
    archetype_add.add_argument("--range", dest="passcode_range", type=str,
                               help="Override the derived passcode range, e.g. 36600001-36699999")

    # Subcommand: cleanup
    cleanup_parser = subparsers.add_parser("cleanup", help="Delete done queue images whose artwork is already in pics/ (dry-run by default)")
    cleanup_parser.add_argument("--apply", action="store_true", help="Actually delete the confirmed images instead of listing them")

    args = parser.parse_args()

    # Exit code phản ánh kết quả thật để agent/CI dựa vào được
    if args.command == "start":
        sys.exit(0 if start_card(args.passcode, args.name, args.template) else 1)
    elif args.command == "verify":
        sys.exit(0 if verify_card(args.passcode) else 1)
    elif args.command == "scan":
        sys.exit(0 if scan_pending_cards() else 1)
    elif args.command == "archetype":
        sys.exit(0 if add_archetype(args.name, args.setcode, args.passcode_range) else 1)
    elif args.command == "cleanup":
        sys.exit(0 if cleanup_queue(args.apply) else 1)

if __name__ == "__main__":
    main()
