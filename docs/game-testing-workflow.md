# Test card trong EDOPro

Kiểm tra tĩnh (`manage_harness.py verify`) chỉ xác nhận dữ liệu, cú pháp và tên API/hằng số; timing, chain và luật engine chỉ lộ ra khi duel. Chạy các bước dưới đây sau khi `verify <ID>` đạt. Bản cài game mặc định ở `F:\Game\ProjectIgnis`.

## 1. Đưa nhánh vào game

Mọi người push card lên nhánh của mình rồi test đúng nhánh đó trong game; không chép file vào thư mục game.

1. Commit và push nhánh (`docs/dev-workflow.md` §3). `cdb/card-data.cdb` đã compile khớp JSON và artwork phải nằm trong commit, vì game chỉ thấy những gì đã push.
2. Chọn nhánh bằng tool pin: bấm đúp `tools/pin_game_branch.cmd` (trong workspace; tester dùng bản trong `repositories/ttf-custom-cards/tools` của game), bấm `1` rồi chọn nhánh trong danh sách. Menu và tham số xem `docs/dev-workflow.md` §4.2 và §4.6.
3. Đóng hẳn EDOPro rồi mở lại: game tự kéo đầu nhánh vừa chọn. Push thêm commit thì chỉ cần mở lại game.
4. Test xong chọn `2` trong menu để về bản người chơi.

Game cài ở `F:/Game/ProjectIgnis` theo mặc định; chỗ khác thì đặt biến môi trường `EDOPRO_DIR` hoặc nhập đường dẫn ở mục 3 của menu.

**Deck test:** không còn deck dựng sẵn. Vào **Deck Edit** tự dựng deck: 3 bản card cần test, mỗi card cùng archetype để tìm hoặc tương tác (Fusion/Synchro/Xyz/Link vào Extra Deck), cùng card đối thủ, hand trap hay card tương tác mà kịch bản cần. Lưu với tên dễ nhớ, ví dụ `test_<ID>`.

> **Git trong thư mục game**: người chơi để `repositories/ttf-custom-cards` ở nhánh `master`; khi đang test nhánh khác thì clone theo dõi nhánh đó (tool pin lo việc này). Mỗi lần mở game EDOPro ghi đè mọi thay đổi cục bộ trong thư mục này, nên không sửa file ở đó. Nếu EDOPro báo lỗi cập nhật (mất mạng, tên nhánh sai hoặc nhánh đã bị xóa), game giữ bản cũ: về bản người chơi hoặc chọn nhánh khác bằng menu.

## 2. Kiểm tra hiển thị

Mở **Deck Edit**, dùng deck test đã dựng ở mục 1: đối chiếu tên, artwork, stats, text và tên archetype (`cdb/strings.conf`) với JSON. Ảnh trống hoặc game văng `JPEG FATAL ERROR` thì chuẩn hóa artwork theo `docs/agent-workflow.md` §5.

## 3. Duel

1. **Đấu với AI / WindBot**: **Duel** -> **Test Bot** -> chọn deck test; đi trước hoặc đi sau tùy kịch bản.
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
