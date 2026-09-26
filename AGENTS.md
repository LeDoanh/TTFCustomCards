# TTF Custom Cards — Agent Guide

Đọc file này trước, rồi chỉ mở tài liệu của bước đang làm. Repo dùng Lua (EDOPro), Python và PowerShell; chạy lệnh từ thư mục gốc.

## Git

- Nhánh chính của repo là **`master`** (đồng bộ với `upstream/master`). Không tạo feature branch: commit rồi push thẳng lên `origin/master` (đang ở worktree thì `git push origin HEAD:master`). Chỉ mở Pull Request sang repo gốc khi được yêu cầu; PR mở từ `LeDoanh:master`, nên commit mới trên `master` tự vào PR đang mở.
- Chỉ commit/push khi được yêu cầu. Gom JSON, Lua, artwork và `card-data.cdb` của cùng một thay đổi. Format: `[<Git user>] [Fix|Feature|Refactor|Chore]: <English description>`.
- Git diff/log là lịch sử thay đổi; không viết nhật ký phiên.

## Nguồn dữ liệu và ranh giới

- `card-data/c<ID>.json`: nguồn dữ liệu cho card được quản lý bằng specs; compiler sinh **`card-data.cdb`**. Sửa JSON rồi compile, không sửa CDB bằng editor.
- `script/c<ID>.lua`: code chạy trong game. `tools/`: công cụ phát triển và templates, không phải script game.
- Mọi `*.cdb` khác ở gốc repo (`custom_cards_zesty.cdb`, `mycard.cdb` và các CDB cộng đồng) là dữ liệu của dev khác. Không ghi đè hoặc giải quyết conflict bằng chọn cả file ours/theirs.
- Không sửa card của dev khác trừ khi được yêu cầu. Quét toàn bộ `script/` sẽ gặp FAIL ở script của họ; lỗi đó không chặn card đang làm.
- `feature_list.json`: hàng đợi và trạng thái; dùng `tools/manage_harness.py` để thay đổi, không chỉnh thủ công.

## Luồng tạo card và test card

1. Chốt effect text và các tình huống cần test (`docs/agent-workflow.md` §1).
2. Tìm official card cùng cơ chế: `python tools/read_official.py --text "<cụm trong effect>"` rồi `python tools/read_official.py <ID>` để lấy script. Ghi card ID, effect/function tham khảo và phần khác biệt. Không lấy custom card cũ làm bằng chứng API đúng.
3. Archetype chưa đăng ký: `python tools/manage_harness.py archetype add <Name> [<setcode>]`; official thì truyền setcode tra trong `repositories/delta-bagooska/script/archetype_setcode_constants.lua` của bản cài game, fan-made thì bỏ trống để tool chọn setcode và ghi `constants.lua`/`strings.conf`. Tạo card: `python tools/manage_harness.py start <ID> "<name>" <template>`. Template chỉ là khung, xóa hiệu ứng mẫu không thuộc yêu cầu.
4. Sửa JSON và Lua; đối chiếu từng effect với `docs/agent-rules.md`. Không bịa API, không suy ra timing từ tên hàm.
5. `python tools/manage_harness.py verify <ID>`; exit code phải là 0. Đây là kiểm tra **tĩnh**, không chứng minh hiệu ứng chạy đúng.
6. `powershell -File tools/sync_game.ps1 -CardId <ID>`, rồi duel bằng deck `test_<ID>` theo ma trận kịch bản trong `docs/game-testing-workflow.md`.
7. Báo cáo: ID, official reference, lệnh đã chạy và kết quả, kịch bản duel với kết quả thực tế. Chưa duel thì ghi "kiểm tra tĩnh đạt, runtime chưa kiểm thử"; trạng thái queue `done` không phải chứng nhận runtime.

## Ràng buộc viết card

- `local s,id=GetID()` và `s.initial_effect(c)`; header có tên, passcode, loại, các effect.
- Đọc `docs/agent-rules.md` cho cost/target/operation, count limit, reset và bitfields.
- Nếu dùng hằng/helper custom trong `script/constants.lua`, load bằng `Duel.LoadScript("constants.lua")`.
- `ot=32`; không thay ID card hiện hữu. ID cũ có độ dài khác nhau: không đổi ID chỉ để đủ 9 chữ số.
- Không áp đặt `IsRelateToEffect` lên mọi operation: chỉ kiểm tra đối tượng cần còn liên hệ để thực hiện phần hiệu ứng đó, theo official reference.
- Không chỉnh code gameplay ngoài yêu cầu, không coi kiểm tra tĩnh hoặc mock là test duel.

## Điều hướng

- `docs/agent-workflow.md`: tạo card — yêu cầu, official reference, harness, kiểm tra tĩnh, artwork.
- `docs/game-testing-workflow.md`: test card — sync sang game, deck test, duel, error log, ma trận kịch bản.
- `docs/agent-rules.md`: quy tắc Lua, passcode/setcode, schema CDB, bitmask, ownership và conflict CDB.

Kiểm tra công cụ: `python -m unittest discover -s tests -v`.
