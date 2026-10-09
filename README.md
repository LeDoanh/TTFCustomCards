# TTF Custom Cards

Custom card fan-made cho [EDOPro](https://github.com/ProjectIgnis/edopro) — simulator Yu-Gi-Oh! miễn phí.

Project này chứa các card do nhóm TTF tự thiết kế: script Lua, database, artwork.

---

## Cài đặt

Không cần tải hay copy file thủ công: khai báo repo này trong cấu hình EDOPro, game sẽ tự tải về và tự cập nhật mỗi lần mở.

1. Đóng EDOPro, mở file `config/user_configs.json` trong thư mục EDOPro.
2. Thêm mục repo dưới đây vào mảng `"repos"`. Nếu file đang để trống như mặc định thì dán nguyên cả nội dung này:
   ```json
   {
     "repos": [
       {
         "url": "https://github.com/LeDoanh/TTFCustomCards",
         "repo_name": "TTFCustomCards",
         "repo_path": "./repositories/ttf-custom-cards",
         "data_path": "cdb",
         "script_path": "script",
         "should_update": true,
         "should_read": true
       }
     ],
     "urls": [],
     "servers": []
   }
   ```
   Nếu `"repos"` đã có repo khác, chỉ chép khối `{ ... }` của TTFCustomCards vào và nhớ dấu phẩy giữa các khối.
3. Mở EDOPro. Lần đầu game tải repo vào `repositories/ttf-custom-cards/`, sau đó tự cập nhật theo repo trên GitHub. Bật "Alternate format" để thấy card tùy chỉnh.

| Trường | Ý nghĩa |
|---|---|
| `data_path: "cdb"` | **Bắt buộc.** EDOPro chỉ đọc `*.cdb` và `strings.conf` đúng trong thư mục này, không đọc thư mục con. Để `""` thì game không nạp card nào. |
| `repo_path` | Thư mục chứa bản tải về. Giữ đúng tên này để khớp với `tools/pin_game_branch.ps1`. |
| `script_path` | Thư mục Lua script, tương đối so với `repo_path`. |
| `should_update` | `true` để game tự cập nhật repo mỗi lần mở. |

Nếu bạn đang dùng cấu hình cũ (`repo_path` là `./repositories/custom_cards_zesty` hoặc `data_path` là `""`), sửa như mục trên rồi xóa thư mục `repositories/custom_cards_zesty`.

Danh sách card đầy đủ xem trực tiếp trong game sau khi cài. Tra nhanh một card: `python tools/manage_db.py query <tên hoặc ID>`.

---

## Cấu trúc thư mục

```
script/          — Lua script cho mỗi card (tên file = passcode)
pics/            — Artwork (tên file = passcode)
docs/            — Tài liệu nội bộ
tools/           — Công cụ CLI, validator và templates:
  ├── templates/        — Templates để tạo script mới
  ├── manage_harness.py — Quản lý quy trình (Harness CLI)
  ├── manage_db.py      — Quản lý CDB (CDB Compiler)
  └── read_official.py  — Tra cứu card và script official từ game
card-data/       — Card specs định dạng JSON
cdb/             — Mọi database và strings.conf:
  ├── card-data.cdb — Database sinh từ card-data/
  ├── *.cdb         — Dữ liệu CDB khác (legacy & cộng đồng)
  └── strings.conf  — Tên archetype hiển thị trong game
```

---

## Dữ liệu và công cụ

Đọc [quy tắc CDB](docs/agent-rules.md#3-cdb) trước khi cập nhật database. Để test card trong game, push nhánh rồi chọn nhánh đó bằng `tools/pin_game_branch.cmd` (xem [quy trình test](docs/game-testing-workflow.md)): game tự kéo nhánh về, không cần chép file.

---

## Đóng góp

Nếu bạn muốn thêm card mới hoặc sửa bug, đọc [`AGENTS.md`](AGENTS.md) để biết workflow.

---

## License

MIT
