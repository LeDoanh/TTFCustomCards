# Làm việc bằng GitHub Desktop

Dành cho dev làm card trên repo này. Quy tắc nhánh, phân bổ engine và PR nằm trong `docs/dev-workflow.md`; tài liệu này chỉ chỉ ra thao tác tương ứng trong GitHub Desktop. Tạo và test card theo `docs/agent-workflow.md`.

## 1. Cài đặt một lần

1. Chủ repo mời bạn làm collaborator; chấp nhận lời mời qua email hoặc trang GitHub của bạn.
2. Cài GitHub Desktop, đăng nhập. **File -> Clone repository** -> tab GitHub.com -> chọn `LeDoanh/TTFCustomCards` -> chọn thư mục workspace (đặt ở đâu cũng được) -> **Clone**.
3. **File -> Options -> Integrations -> Shell**: chọn PowerShell hoặc Command Prompt. Từ đó **Repository -> Open in Command Prompt** (hoặc PowerShell) mở terminal ngay tại workspace, dùng để chạy các tool Python/PowerShell của repo.
4. Cài Python 3 và Lua theo `docs/agent-workflow.md`, rồi `python -m pip install pillow`.
5. Cấu hình EDOPro theo README (khai báo repo, `should_update: true`) và mở game một lần để game tải repo. Nếu EDOPro không cài ở `F:\Game\ProjectIgnis`, đặt biến môi trường `EDOPRO_DIR` trỏ tới thư mục game.

## 2. Làm việc trên nhánh engine của bạn

1. **Lấy bản mới nhất.** Nhấn **Current Branch** -> chọn `develop`. Nhấn nút **Fetch origin** ở thanh trên; nếu nút đổi thành **Pull origin** thì nhấn tiếp.
2. **Vào nhánh engine của bạn.** Lần đầu: **Current Branch** -> **New Branch** -> Name `engine/<Engine>` (ví dụ `engine/Labrynth`) -> mục **Create branch based on...** chọn `develop`, không chọn `master` -> **Create Branch**. Các lần sau chỉ cần **Current Branch** -> chọn `engine/<Engine>`.
3. **Tạo card, chạy `verify`** bằng terminal mở từ **Repository -> Open in Command Prompt**, theo `docs/agent-workflow.md`.
4. **Commit.** Trở lại GitHub Desktop, tab **Changes**:
   - Chỉ tick file của đợt card này: `card-data/c<ID>.json`, `script/c<ID>.lua`, `pics/<ID>.jpg`, `cdb/card-data.cdb` và `feature_list.json`. Bỏ tick mọi file khác.
   - Ô **Summary** theo định dạng `[Tên bạn] [Feature]: <English description>` (hoặc `[Fix]`), rồi **Commit to engine/...**.
5. **Push.** Nhấn **Publish branch** (lần đầu) hoặc **Push origin** (các lần sau). Game chỉ thấy file đã commit và push, nên không bỏ sót `cdb/card-data.cdb` và artwork.
6. **Test trong game.** Từ terminal ở workspace:

```powershell
powershell -File tools/pin_game_branch.ps1 engine/Labrynth
```

Đóng hẳn EDOPro rồi mở lại: game tự kéo đúng nhánh vừa push. Tự dựng deck trong Deck Edit rồi duel theo ma trận trong `docs/game-testing-workflow.md`. Sửa tiếp thì commit, **Push origin**, mở lại EDOPro; script chỉ cần chạy một lần, nhánh engine có thể để ghim thường trực.

7. **Đồng bộ với develop**, mỗi lần bắt đầu làm việc và trước khi mở PR. **Branch -> Merge into current branch...** -> chọn `develop` -> **Create a merge commit**. Nếu có xung đột:
   - `cdb/card-data.cdb` (file nhị phân): chọn đại một bên để Desktop cho tiếp tục, hoàn tất merge, rồi chạy `python tools/manage_db.py compile` trong terminal, quay lại tab **Changes** commit file CDB vừa sinh và **Push origin**.
   - File văn bản như `feature_list.json`: Desktop nút **Open in ...** mở trình soạn thảo; xóa các dòng `<<<<<<<`, `=======`, `>>>>>>>`, giữ cả hai phần engine và ngày `last_updated` muộn hơn.
   - Sau đó chạy `python tools/manage_db.py check-sync` và `verify` lại các card đã đổi.
8. **Mở PR.** Sau khi push, nhấn **Preview Pull Request** (hoặc **Branch -> Create Pull Request**) rồi **Create Pull Request**: Desktop mở trình duyệt tới trang GitHub.
   - Ở dòng `base:` đổi thành **`develop`**. GitHub mặc định chọn `master`.
   - Điền tiêu đề theo định dạng commit, mô tả gồm engine, card ID, official reference, lệnh đã chạy và ma trận duel kèm kết quả thực tế.
   - Tạo PR thường (không cần PR nháp). CI chạy một lần lúc PR được mở, kết quả hiện ở dấu xanh/đỏ trên PR.
9. **Chờ chủ repo duyệt.** PR chỉ merge được sau khi chủ repo approve. Trong lúc PR mở, chỉ push commit sửa theo góp ý (mọi commit mới đều vào PR); việc mới của đợt sau để dưới máy hoặc đợi PR merge. CI không chạy lại sau lần đầu, chủ repo tự chạy khi cần.
10. **Sau khi PR được merge.** Nhánh engine vẫn dùng tiếp: **Branch -> Merge into current branch...** -> `develop` để lấy bản đã merge, rồi làm đợt card tiếp theo ngay trên nhánh đó. Muốn chơi bản người chơi thì bỏ ghim:

```powershell
powershell -File tools/pin_game_branch.ps1 -Unpin
```

## 3. Lỗi thường gặp

| Hiện tượng | Nguyên nhân và cách xử lý |
| :--- | :--- |
| Card mới không hiện trong game | `cdb/card-data.cdb` chưa compile hoặc chưa commit và push. Chạy `verify`, commit file CDB, **Push origin**, mở lại EDOPro |
| EDOPro báo lỗi cập nhật repo, hiện bản cũ | Gõ sai tên nhánh khi ghim hoặc nhánh đã bị xóa. Chạy `pin_game_branch.ps1 -Unpin` hoặc ghim nhánh khác |
| Game vẫn hiện nội dung nhánh test, không phải bản người chơi | Đang ghim nhánh. Chạy `pin_game_branch.ps1 -Unpin` |
| PR vào nhầm `master` | Trên trang PR bấm **Edit** cạnh tiêu đề, đổi base thành `develop` |
| Thấy file của engine khác trong tab Changes | Bỏ tick, không commit. Sửa card của engine khác phải qua owner (`docs/dev-workflow.md` §2) |
| Desktop báo "branch has conflicts" ở PR | PR khác vừa merge. Làm lại bước 7 rồi **Push origin** |
| Không push được lên `develop` hoặc `master` | Đúng thiết kế: hai nhánh này chỉ nhận PR. Làm việc trên nhánh `engine/` của bạn hoặc nhánh `fix/` |

Không dùng "Add files via upload" hay sửa file trực tiếp trên trang GitHub: cách đó bỏ qua `verify` và làm `cdb/card-data.cdb` lệch với JSON.
