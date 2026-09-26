# Quy tắc Lua, passcode và CDB

Bổ sung cho mục "Ràng buộc viết card" trong `AGENTS.md`; không lặp lại các quy tắc đã có ở đó.

## 1. Script Lua (EDOPro)

1. Với effect kích hoạt có target callback, dùng `chk==0` kiểm tra legality; cost/target/operation là ba bước khác nhau. Continuous field target/filter không dùng cùng chữ ký callback.
2. `aux.Stringid(id,N)` dùng chỉ số 0-based vào `strings`; không bắt buộc N bằng số thứ tự effect nếu có nhiều prompt.
3. Kiểm tra zone ở thời điểm thích hợp; Extra Deck summon và zone giải phóng bởi cost/material cần API phù hợp theo reference.
4. Chỉ kiểm tra handler `IsRelateToEffect`/`IsFaceup` khi phần operation đó cần handler còn tại vị trí/trạng thái hợp lệ. Không chặn search/draw chỉ vì handler rời sân nếu luật không yêu cầu. Cảnh báo `STRUCT:` của `validate_scripts.ps1` về `IsRelateToEffect` hay `chk==0` là heuristic, không phải yêu cầu.
5. Với đối tượng được target, kiểm tra quan hệ/trạng thái tại resolution theo reference; card được chọn trong operation không mặc nhiên là target.
6. HOPT/SOPT và giới hạn activation/use phải theo text và reference; không thêm `EFFECT_COUNT_CODE_OATH` cho mọi HOPT.
7. API mới phải có bằng chứng từ official script/helper hoặc source engine. Qua được whitelist của validator chỉ chứng minh tên hàm tồn tại, không chứng minh cách dùng đúng.
8. Gán range/property/reset/category theo loại effect và reference, không áp dụng một công thức cho mọi effect.
9. Spell official chỉ dùng `EFFECT_TYPE_QUICK_O` khi card đang ngửa trên sân (`LOCATION_SZONE`/`LOCATION_FZONE`) hoặc khi cấp hiệu ứng cho monster; không có Spell official nào dùng Quick Effect từ tay hay GY. Hiệu ứng Spell phản ứng từ tay/GY phải dựa trên official card cùng cơ chế, không tự dựng `QUICK_O`.
10. Text nhắc tên card cụ thể thì khai báo `s.listed_names={...}`; searcher dựa trên `Card.ListsCode` không nhận diện được card thiếu khai báo này.

## 2. Passcode và setcode

### 2.1 Passcode

Giữ nguyên passcode hiện hữu. Card mới dùng range đã đăng ký trong `feature_list.json`. `manage_db.py validate`/`compile` tự đối chiếu ID với mọi CDB trong repo và CDB của bản cài EDOPro, trùng là ERROR (`docs/agent-workflow.md` §4). ID và setcode là hai định danh khác nhau: không ghép setcode thành ID rồi coi là bảo đảm không trùng.

### 2.2 Archetype official và fan-made

Cả hai loại phải được đăng ký bằng `python tools/manage_harness.py archetype add` trước khi cấp passcode (`docs/agent-workflow.md` §3).

- **Official** (Dragonmaid, Labrynth, White Forest, Witchcrafter, Branded...): truyền setcode tra trong `repositories/delta-bagooska/script/archetype_setcode_constants.lua` của bản cài game (không có game thì xem file cùng tên trong CardScripts, §5). Dùng hằng `SET_*` official trong Lua; EDOPro đã có sẵn, **không thêm vào `script/constants.lua`**.
- **Fan-made**: bỏ trống setcode để tool chọn setcode trống và ghi `SET_XXX = 0xYYY` vào [script/constants.lua](../script/constants.lua), `!setname 0xYYY TênArchetype` vào [strings.conf](../strings.conf). Script dùng `SET_XXX` phải có `Duel.LoadScript("constants.lua")`.
- EDOPro so setcode theo 12 bit thấp: `0x1004` là archetype con của `0x4` (Amazoness). Setcode fan-made không được trùng 12 bit thấp với archetype official.

## 3. CDB

### 3.1 Schema

`card-data/c<passcode>.json` là nguồn dữ liệu duy nhất; `tools/manage_db.py` biên dịch toàn bộ specs vào `card-data.cdb` theo schema và cách đóng gói của Datacorn (editor CDB của ProjectIgnis).

- **Bảng `datas`:**
  - `id`: passcode, phải khớp tên file.
  - `ot`: luôn là 32; compiler báo lỗi nếu khác.
  - `alias`: ID card gốc nếu là alt-art (0 = không có).
  - `setcode`: tối đa 4 setcode 16-bit trong một số 64-bit: `sc1 | (sc2 << 16) | (sc3 << 32) | (sc4 << 48)`.
  - `type`: bitmask, có **đúng 1** trong 3 bit khung Monster (`0x1`) / Spell (`0x2`) / Trap (`0x4`).
  - `atk`, `def`: -2 nghĩa là `?`.
  - `level`: Level/Rank/Link rating (0–13). Pendulum scale đóng gói vào cột này: `(base_level & 0x800000FF) | (left_scale << 24) | (right_scale << 16)`.
  - `race`, `attribute`: bitmask, monster phải có **đúng 1 bit** mỗi cột.
  - `category`: bitmask bộ lọc database (§4).
  - **Link Monster:** cột `def` là bitfield link marker: `0x1` Bottom-Left, `0x2` Bottom, `0x4` Bottom-Right, `0x8` Left, `0x20` Right, `0x40` Top-Left, `0x80` Top, `0x100` Top-Right (`0x10` không dùng).
  - **Spell/Trap:** `atk`, `def`, `level`, `race`, `attribute` phải bằng 0.
- **Bảng `texts`:** `name`, `desc`, `str1`–`str16` (prompt cho `aux.Stringid`).

### 3.2 Field thân thiện trong JSON

Nên dùng khi viết card mới; compiler tự đóng gói và validate. Không khai báo đồng thời field thô và field thân thiện với giá trị mâu thuẫn.

| Field JSON | Ý nghĩa | Ví dụ |
|------------|---------|-------|
| `"setcodes": [...]` | Tối đa 4 setcode (đóng gói vào `setcode`) | `"setcodes": [296, 4444]` |
| `"lscale"` / `"rscale"` | Pendulum Scale (đóng gói vào `level`) | `"lscale": 4, "rscale": 4` |
| `"linkmarkers": [...]` | Tên link marker (đóng gói vào `def`) | `"linkmarkers": ["Top", "Bottom"]` |
| `"atk"` / `"def"`: `"?"` | ATK/DEF `?` (chuyển thành -2) | `"atk": "?"` |
| `"type"`, `"race"`, `"attribute"`, `"category"` | Tên hoặc danh sách tên thay cho số (§4) | `"race": "Warrior"`, `"category": ["Search", "Send to Hand"]` |

### 3.3 Lệnh CDB

```powershell
python tools/manage_db.py validate      # kiểm tra specs, không ghi CDB
python tools/manage_db.py compile       # validate rồi ghi CDB atomic
python tools/manage_db.py check-sync    # mỗi spec có Lua, entry feature_list và row CDB khớp
python tools/manage_db.py query <ID-or-name>
```

`compile` chỉ thay CDB khi 0 lỗi; có lỗi thì CDB cũ giữ nguyên và exit code = 1. Lỗi bị chặn gồm: `ot` ≠ 32, thiếu/thừa bit khung Monster-Spell-Trap, monster thiếu hoặc multi-bit race/attribute, link marker không hợp lệ hoặc rỗng, scale > 13, level > 13, Spell/Trap có chỉ số khác 0, `strings` > 16, `id` không khớp tên file, trùng passcode giữa các CDB. Compiler cũng từ chối ghi đè khi CDB đích chứa ID không có spec, thay vì âm thầm xóa card đó.

### 3.4 Ownership và làm việc nhóm

- Mọi `*.cdb` khác ở gốc repo là dữ liệu của dev khác; compiler không ghi vào đó nhưng đối chiếu passcode với tất cả.
- Commit JSON + Lua/artwork liên quan + `card-data.cdb` sinh từ cùng phiên bản nguồn.
- Conflict ở `card-data.cdb`: giải quyết JSON trước rồi compile lại. Không chọn cả file ours/theirs.
- Chuyển card từ CDB khác vào `card-data/`: thống nhất ownership, viết spec, rồi bỏ ID đó khỏi CDB cũ. Không trông vào thứ tự nạp của client để giải quyết trùng ID.
- Bỏ một card phải xóa rõ ràng ở cả JSON và CDB đích.

## 4. Tên bitfield trong JSON

`type`, `race`, `attribute` và `category` nhận tên (không phân biệt hoa thường), danh sách tên, hoặc số; compiler OR các giá trị lại. Tên sai là lỗi validate. Spec cũ ghi số vẫn hợp lệ; đọc số thành tên bằng `python tools/manage_db.py query <ID>`. Danh sách đầy đủ là các bảng `TYPES`, `RACES`, `ATTRIBUTES`, `CATEGORIES` trong `tools/manage_db.py`.

- `type`: Monster, Spell, Trap, Normal, Effect, Fusion, Ritual, Spirit, Union, Gemini, Tuner, Synchro, Token, Quick-Play, Continuous, Equip, Field, Counter, Flip, Toon, Xyz, Pendulum, Link. Vd Synchro Tuner `["Monster", "Synchro", "Tuner", "Effect"]`, Continuous Trap `["Trap", "Continuous"]`.
- `race`: Warrior, Spellcaster, Fairy, Fiend, Zombie, Machine, Aqua, Pyro, Rock, Winged Beast, Plant, Insect, Thunder, Dragon, Beast, Beast-Warrior, Dinosaur, Fish, Sea Serpent, Reptile, Psychic, Divine-Beast, Wyrm, Cyberse, Illusion.
- `attribute`: EARTH, WATER, FIRE, WIND, LIGHT, DARK, DIVINE.
- `category`: vd Search, Send to Hand, Draw, Special Summon, Destroy Monster, Destroy S/T, Banish, Send to GY, Negate Activation, Negate Effect, Damage LP, Recover LP.

`category` là bộ lọc tìm kiếm của database, **không phải** hằng Lua `CATEGORY_*` truyền cho `SetCategory`/`SetOperationInfo`; hai bộ bit khác nhau, không chuyển thẳng số từ Lua sang JSON.

## 5. Tham khảo API

Bằng chứng ưu tiên là official script cùng cơ chế (`python tools/read_official.py`) và thư viện script trong bản cài game. Tên hằng số/hàm có thật nằm trong `tools/edopro_constants.txt` và `tools/edopro_apis.txt`. Tài liệu online:

- Scrapi-book (API docs): https://projectignis.github.io/scrapi-book/
- CardScripts (`utility.lua`, `constant.lua`, `official/`): https://github.com/ProjectIgnis/CardScripts
- CardScripts wiki: https://github.com/ProjectIgnis/CardScripts/wiki
