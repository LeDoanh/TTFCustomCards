# Quy trình tạo và sửa card

Chạy từ gốc repo; cần Python 3, PowerShell và Lua trong PATH. Thiếu parser thật thì không báo kiểm tra cú pháp thành công. Sau khi `verify` đạt, test trong game theo `docs/game-testing-workflow.md`.

## 1. Chốt yêu cầu trước khi viết

Với từng effect, ghi ngắn trong mô tả công việc/PR: vị trí kích hoạt, event/timing, optional hay mandatory, cost, target, operation, count limit và reset. Xác định rõ "and", "then", "if you do"; nếu text mơ hồ thì hỏi, không tự thêm điều kiện. Từ đó lập luôn danh sách tình huống sẽ test (ma trận trong `docs/game-testing-workflow.md` §4).

## 2. Official reference

Tìm official card cùng cơ chế và đọc trực tiếp từ bản cài game. Chưa biết tên card thì tìm theo effect text bằng `--text`: mỗi tham số là một cụm phải có trong text, text ngắn đứng trước:

```powershell
python tools/read_official.py --text "If this card is Normal or Special Summoned" "Spell/Trap from your Deck"
python tools/read_official.py <official-ID>
python tools/read_official.py --search "<tên card>"
```

Tool hiển thị effect/stats và lưu script mẫu vào `docs/official-reference/c<ID>.lua` (thư mục chỉ có trên máy dev, không commit); `--view` in script ra màn hình, `--fetch` tải script từ GitHub khi bản cài không có. Ghi ID và hàm/effect dùng làm mẫu, phần nào khác yêu cầu. Đọc constants/helper mà script đó gọi nếu cần. Không coi template hay custom cũ là bằng chứng engine hỗ trợ.

## 3. Khởi tạo

Archetype chưa có trong `feature_list.json` thì đăng ký trước, đừng sửa tay file đó:

```powershell
python tools/manage_harness.py archetype add <Name>             # fan-made mới: tool chọn setcode trống
python tools/manage_harness.py archetype add <Name> <setcode>   # archetype official hoặc setcode đã chốt
```

Tool đối chiếu setcode với `archetype_setcode_constants.lua` của bản cài game: setcode official chỉ được đăng ký; setcode fan-made được kiểm tra trùng (12 bit thấp với official, tên khác trong `script/constants.lua`/`strings.conf`) rồi tự ghi `SET_*` và `!setname` vào hai file đó. Output ghi rõ hằng `SET_*` dùng trong Lua. Range mặc định là `setcode * 100000 + 1` đến `+ 99999` (vd `0x16e` -> `36600001-36699999`); lệnh từ chối khi trùng tên, trùng setcode hoặc chồng range. `--range <start>-<end>` dùng khi passcode vượt 9 chữ số.

Tạo card theo một trong hai cách:

- Có ảnh card: đặt ảnh tên `p_<tên card>.<ext>` vào `docs/queues/<Archetype>/` (clone mới chưa có thư mục này, tự tạo), chạy `python tools/manage_harness.py scan` để cấp passcode chưa dùng và ghi card `pending`, rồi `start` với passcode đó.
- Tạo trực tiếp: `python tools/manage_harness.py start <ID> "<name>" <template>` với passcode trong range của archetype. Danh sách template: `python tools/manage_harness.py start --help`.

`start` tạo JSON/Lua từ template và cập nhật queue; không ghi đè file cũ. Nó tự thay `<<CARD_NAME>>`, `<<PASSCODE>>`, `<<SETCODE>>`, `<<ARCHETYPE_NAME>>`; mọi `<<...>>` còn lại (`<<ATK_VALUE>>`, `<<RANK>>`...) phải thay tay, `verify` chặn nếu sót. Stats chỉ điền trong JSON; `type`, `race`, `attribute`, `category` ghi bằng tên (`docs/agent-rules.md` §3.2). Extra Deck effect monster phải có bit Effect trong `type`. `aux.Stringid(id,N)` phải có phần tử `strings[N]` (chỉ số bắt đầu từ 0).

Template chỉ là khung: xóa block effect mẫu không dùng cùng các hàm filter/target/operation của nó. Thêm effect thì copy từ `Effect.CreateEffect` đến `c:RegisterEffect(eN)` kèm các hàm liên quan, đổi tên biến và chỉ số `Stringid`. Đổi loại effect thì lấy official card cùng cơ chế làm mẫu, không tự sửa template.

## 4. Kiểm tra tĩnh

```powershell
python tools/manage_db.py validate
python tools/manage_harness.py verify <ID>
```

`validate` kiểm tra specs mà không ghi CDB, dùng trong lúc đang sửa JSON. `verify` là cổng bắt buộc: chạy preflight (file, placeholder, artwork), compile `card-data.cdb`, validate Lua và check-sync rồi cập nhật queue; thứ tự nằm ở `verify_card` trong `tools/manage_harness.py`. Kiểm tra exit code:

- FAIL của validator (`CONST:`, `API:`, `DEPEND:`, cú pháp) chặn verify; sửa theo tên thật trong engine.
- WARN `STRUCT:` không chặn. Đây là heuristic: xem lại theo official reference, không sửa máy móc chỉ để hết cảnh báo (ví dụ `IsRelateToEffect`, xem `docs/agent-rules.md` §1).
- CDB có thể đã compile dù bước sau thất bại: không commit cho đến khi verify đạt.

### Trùng passcode giữa các CDB

`validate` và `compile` đối chiếu mọi ID trong `card-data/` với mọi `*.cdb` khác ở gốc repo và toàn bộ `*.cdb` của bản cài EDOPro; trùng là ERROR và chặn biên dịch (quy tắc tại `docs/agent-rules.md` §2.1). `scan` dùng cùng nguồn đó để không cấp passcode đã có người dùng.

CDB trong game trùng tên file với CDB của repo bị bỏ qua — đó là bản phân phối của chính repo này. Thư mục game đọc từ `$EDOPRO_DIR`, mặc định `F:/Game/ProjectIgnis`; không thấy thì chỉ còn đối chiếu CDB trong repo và tool báo warning, lúc đó phải tự kiểm tra trước khi phát hành.

### Danh sách tham chiếu EDOPro

Lua trả về `nil` cho tên không tồn tại, nên hằng số gõ sai hay hàm bịa vẫn qua được parser rồi mới crash trong duel. `validate_scripts.ps1` chặn bằng hai danh sách trắng sinh từ bản cài game: `tools/edopro_constants.txt` (hằng số) và `tools/edopro_apis.txt` (`Namespace.Function`, gồm cả method `c:Method()`). Sai tên thì sửa theo tên thật; hằng số riêng của card khai báo `local` trong file, hằng số dùng chung thêm vào `script/constants.lua` kèm `Duel.LoadScript("constants.lua")`.

Không sửa tay hai file này. Sau mỗi lần cập nhật EDOPro, chạy `python tools/sync_edopro_refs.py --check` (exit 1 khi lệch); lệch thì chạy lại không có `--check` rồi commit hai file. Thêm `--game-dir "<đường dẫn>"` nếu game không ở `$EDOPRO_DIR`/`F:/Game/ProjectIgnis`.

EDOPro chạy Lua 5.4.7, còn validator gọi `lua` trong PATH: script qua parser máy mình mà EDOPro từ chối thì kiểm tra lệch phiên bản trước tiên.

## 5. Artwork và dọn queue

Chuẩn artwork của repo là JPEG thật với đuôi `.jpg`. EDOPro đọc `.jpg` bằng libjpeg, nên ảnh PNG mang đuôi `.jpg` làm game văng `JPEG FATAL ERROR`; preflight của `verify` chặn trường hợp này. Chuẩn hóa:

```powershell
python tools/normalize_images.py --to-jpg
python tools/normalize_images.py --to-jpg --apply
```

Lệnh đầu chỉ liệt kê; `--apply` mới convert, thêm `--sync-game` để đồng bộ ảnh sang game.

Sau khi các bước tĩnh đạt, `verify` copy ảnh queue thành `pics/<ID>.jpg|.png` nếu chưa có artwork, đọc lại bản copy để xác nhận rồi mới xóa ảnh trong `docs/queues/`. Không xác nhận được (đuôi `.gif`, copy lỗi) thì ảnh queue được giữ lại và chỉ đổi tên `w_` -> `d_`, kèm warning. Tự đặt artwork vào `pics/` trước cũng được: lúc đó `verify` giữ bản của bạn và chỉ xóa ảnh queue.

Ảnh `d_` tồn đọng dọn bằng `python tools/manage_harness.py cleanup` (dry-run), thêm `--apply` để xóa. Chỉ ảnh của card `done` đã có artwork trong `pics/` mới bị xóa. Ảnh chưa được Git theo dõi thì xóa là mất hẳn (cleanup đánh dấu `[CHƯA COMMIT — xóa là mất hẳn]`), nên commit trước nếu còn cần bản gốc.

## 6. Trước khi commit

Review `git diff --check` và `git diff --stat`. Thay đổi CDB theo `docs/agent-rules.md` §3.4. Quy tắc nhánh, commit và PR nằm trong `AGENTS.md`.
