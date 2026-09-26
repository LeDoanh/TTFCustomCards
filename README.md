# TTF Custom Cards

Custom card fan-made cho [EDOPro](https://github.com/ProjectIgnis/edopro) — simulator Yu-Gi-Oh! miễn phí.

Project này chứa các card do nhóm TTF tự thiết kế: script Lua, database, artwork.

---

## Cài đặt

1. Clone repo này về máy
2. Copy các file/thư mục runtime sau vào thư mục `expansions/` của EDOPro:
   ```
   expansions/
   ├── *.cdb            ← mọi file CDB ở gốc repo (card-data.cdb và CDB của các dev khác)
   ├── script/          ← Lua scripts
   ├── pics/            ← artwork
   └── strings.conf     ← tên archetype và counter
   ```
3. Mở EDOPro → bật "Alternate format" để thấy card tùy chỉnh

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
card-data.cdb    — Database sinh từ card-data/
*.cdb            — Dữ liệu CDB khác (legacy & cộng đồng)
strings.conf     — Tên archetype hiển thị trong game
```

---

## Dữ liệu và công cụ

Đọc [quy tắc CDB](docs/agent-rules.md#3-cdb) trước khi cập nhật database. Chỉ copy CDB, `script/`, `pics/` và `strings.conf` vào game; không copy `tools/` hay queue. Thay đồng bộ các file CDB sau lần cập nhật database để tránh trùng ID với bản cũ.

---

## Đóng góp

Nếu bạn muốn thêm card mới hoặc sửa bug, đọc [`AGENTS.md`](AGENTS.md) để biết workflow.

---

## License

MIT
