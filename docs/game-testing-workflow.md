# Test card trong EDOPro

Kiểm tra tĩnh (`manage_harness.py verify`) chỉ xác nhận dữ liệu, cú pháp và tên API/hằng số; timing, chain và luật engine chỉ lộ ra khi duel. Chạy các bước dưới đây sau khi `verify <ID>` đạt. Bản cài game mặc định ở `F:\Game\ProjectIgnis`.

## 1. Đồng bộ sang game

Dev trong nhóm test nhánh đã push bằng cách ghim nhánh trong clone repo của game (`tools/pin_game_branch.ps1`, `docs/dev-workflow.md` §4), game tự kéo bản mới mỗi lần mở. Phần dưới là `sync_game.ps1`: cách ghi đè file trực tiếp vào `repositories/ttf-custom-cards`, tự dựng sẵn deck `test_<ID>`. EDOPro với `should_update: true` sẽ `reset --hard` đè lên file vừa chép khi mở game, nên dùng cách này thì đặt `"should_update": false`.

```powershell
powershell -File .\tools\sync_game.ps1 -CardId <ID>
powershell -File .\tools\sync_game.ps1
```

Lệnh đầu dành cho một card, lệnh sau đồng bộ toàn repo. Thêm `-GameDir "<đường dẫn>"` nếu game không ở vị trí mặc định.

Tool ghi vào `repositories/ttf-custom-cards/` trong thư mục game: mọi `*.cdb` và `strings.conf` trong `cdb/` (vào `cdb/` của bản clone; mục repo trong `config/configs.json` của game phải có `"repo_path": "./repositories/ttf-custom-cards"` và `"data_path": "cdb"`, xem README), cùng script và ảnh. Với `-CardId`, tool chỉ copy script/ảnh của card đó và các card cùng archetype trong `feature_list.json` (trừ nhóm `Common`) cùng `script/constants.lua`, rồi tạo `deck/test_<ID>.ydk` gồm 3 bản card cần test và 1 bản mỗi card cùng archetype; Fusion/Synchro/Xyz/Link vào Extra Deck theo `type` trong `card-data/`. Deck chỉ là điểm xuất phát: thêm card đối thủ, hand trap hoặc card tương tác mà kịch bản cần trong Deck Edit. Khởi động lại EDOPro sau khi sync.

> **Git trong thư mục game**: `repositories\ttf-custom-cards` nếu là clone Git thì người chơi thường để ở nhánh `master` đồng bộ với repo chính; dev đang test nhánh khác theo `docs/dev-workflow.md` §4. Nếu EDOPro báo lỗi cập nhật repository qua mạng hoặc bị kẹt ở nhánh `main` cũ, `sync_game.ps1` ghi đè trực tiếp các file mới nhất từ workspace vào game để test ngay.

## 2. Kiểm tra hiển thị

Mở **Deck Edit**, chọn deck `test_<ID>`: đối chiếu tên, artwork, stats, text và tên archetype (`cdb/strings.conf`) với JSON. Ảnh trống hoặc game văng `JPEG FATAL ERROR` thì chuẩn hóa artwork theo `docs/agent-workflow.md` §5.

## 3. Duel

1. **Đấu với AI / WindBot**: **Duel** -> **Test Bot** -> chọn deck `test_<ID>`; đi trước hoặc đi sau tùy kịch bản.
2. **Local Duel hai cửa sổ** để điều khiển cả hai bên, cần khi test hiệu ứng phản ứng của đối thủ và chain:
   - Cửa sổ 1: **Duel** -> **Host Game** (LAN/localhost, IP `127.0.0.1`, cổng `7911`).
   - Cửa sổ 2: **Duel** -> **Join Game** (`127.0.0.1`).

Không giả định EDOPro có console Lua bằng phím backtick.

## 4. Ma trận kịch bản

Lập ma trận trước khi duel, mỗi tình huống một dòng, và điền cột "Thực tế" khi chạy:

| # | Tình huống | Chuẩn bị (tay/sân/mộ) | Hành động | Kỳ vọng | Thực tế |
| :--- | :--- | :--- | :--- | :--- | :--- |

Các tình huống cần phủ (bỏ những dòng không áp dụng cho card):

- Mỗi effect kích hoạt đúng vị trí, đúng timing; effect optional có thể từ chối.
- Thiếu điều kiện: không có mục tiêu hợp lệ, thiếu tài nguyên, zone đầy; zone được giải phóng bởi cost/material.
- Cost chỉ trả ở cost; target chọn đúng; operation xử lý đúng số lượng và vị trí.
- Đối tượng target rời sân hoặc đổi trạng thái trước resolution; handler rời sân có thực sự phải chặn effect hay không.
- HOPT/SOPT với nhiều bản sao; negate activation so với negate effect.
- Hiệu ứng bị vô hiệu hóa; reset cuối lượt hoặc khi rời sân; special summon restriction và summon procedure.
- Card khác tìm hoặc nhận diện được card này (archetype, tên được nhắc trong `s.listed_names`).

## 5. Lỗi runtime

Card không kích hoạt, game crash hoặc báo lỗi script thì mở `F:\Game\ProjectIgnis\error.log`. File ghi nối qua nhiều phiên, nên chỉ đọc các dòng có thời điểm của lần test; traceback Lua chỉ ra script và dòng lỗi (ví dụ `attempt to call a nil value`, tham số sai kiểu).

## 6. Báo kết quả

Gửi ma trận kèm kết quả thực tế và lỗi trong `error.log` nếu có. Chưa chạy duel thì ghi rõ "kiểm tra tĩnh đạt, runtime chưa kiểm thử" và liệt kê tình huống chưa chạy.
