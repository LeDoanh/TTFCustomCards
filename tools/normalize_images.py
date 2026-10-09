"""Chuẩn hóa và kiểm tra định dạng hình ảnh trong thư mục pics/.

Hỗ trợ:
- Phát hiện và sửa lỗi mismatch định dạng (file PNG lưu đuôi .jpg hoặc ngược lại).
- Chuyển đổi toàn bộ kho ảnh về chuẩn JPEG (.jpg) đồng nhất theo yêu cầu.

Cách dùng:
  python tools/normalize_images.py                        # Kiểm tra định dạng (check / dry-run)
  python tools/normalize_images.py --apply                # Tự động sửa lỗi mismatch
  python tools/normalize_images.py --to-jpg               # Chuẩn hóa toàn bộ ảnh về .jpg (dry-run)
  python tools/normalize_images.py --to-jpg --apply       # Thực hiện convert toàn bộ ảnh sang .jpg
"""
from __future__ import annotations

import argparse
from pathlib import Path
import subprocess
import sys
from typing import NamedTuple

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")

try:
    from PIL import Image
    HAS_PIL = True
except ImportError:
    HAS_PIL = False

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_PICS_DIR = ROOT / "pics"

MAGIC_PNG = b"\x89PNG\r\n\x1a\n"
MAGIC_JPEG = b"\xff\xd8\xff"
MAGIC_GIF = b"GIF8"
MAGIC_WEBP = b"RIFF"


class ImageIssue(NamedTuple):
    file_path: Path
    detected_format: str
    expected_extension: str
    current_extension: str
    issue_type: str  # 'MISMATCH', 'CORRUPT', 'UNSUPPORTED', 'DUPLICATE', 'NON_JPG'
    details: str


def detect_file_format(file_path: Path) -> tuple[str, str | None]:
    """Xác định format thực tế của file qua magic bytes và Pillow."""
    if not file_path.exists() or file_path.stat().st_size == 0:
        return "EMPTY", "File rỗng (0 bytes)"

    try:
        with open(file_path, "rb") as f:
            header = f.read(16)
    except Exception as e:
        return "UNREADABLE", str(e)

    detected = "UNKNOWN"
    if header.startswith(MAGIC_PNG):
        detected = "PNG"
    elif header.startswith(MAGIC_JPEG):
        detected = "JPEG"
    elif header.startswith(MAGIC_GIF):
        detected = "GIF"
    elif header.startswith(MAGIC_WEBP) and len(header) >= 12 and header[8:12] == b"WEBP":
        detected = "WEBP"

    if HAS_PIL:
        try:
            with Image.open(file_path) as img:
                pil_fmt = img.format.upper() if img.format else detected
                return pil_fmt, None
        except Exception as e:
            if detected != "UNKNOWN":
                return detected, None
            return "CORRUPT", f"Pillow không đọc được file: {e}"

    return detected, None


def remove_file(path: Path) -> None:
    """Xóa file khỏi filesystem và git (nếu đang được git theo dõi)."""
    is_git = False
    try:
        res = subprocess.run(
            ["git", "ls-files", "--error-unmatch", str(path)],
            cwd=path.parent,
            capture_output=True,
            text=True,
        )
        is_git = (res.returncode == 0)
    except Exception:
        is_git = False

    if is_git:
        subprocess.run(["git", "rm", "-f", str(path)], cwd=path.parent, capture_output=True)
    else:
        path.unlink(missing_ok=True)


def convert_image_to_jpeg(
    src_path: Path,
    dst_path: Path,
    quality: int = 100,
    subsampling: int = 0,
    optimize: bool = True,
) -> None:
    """Chuyển đổi bất kỳ ảnh nào sang chuẩn JPEG (.jpg) thực thụ với chất lượng cao nhất."""
    if not HAS_PIL:
        raise RuntimeError("Cần cài đặt Pillow (PIL) để thực hiện convert ảnh sang JPEG!")

    with Image.open(src_path) as img:
        save_kwargs: dict[str, object] = {
            "quality": quality,
            "subsampling": subsampling,
            "optimize": optimize,
        }
        if "dpi" in img.info:
            save_kwargs["dpi"] = img.info["dpi"]

        # Xử lý kênh Alpha (độ trong suốt) nếu có -> chuyển sang nền trắng
        if img.mode in ("RGBA", "LA") or (img.mode == "P" and "transparency" in img.info):
            bg = Image.new("RGB", img.size, (255, 255, 255))
            if img.mode == "P":
                img = img.convert("RGBA")
            bg.paste(img, mask=img.split()[-1])
            bg.save(dst_path, "JPEG", **save_kwargs)
        else:
            rgb_img = img.convert("RGB")
            rgb_img.save(dst_path, "JPEG", **save_kwargs)


def scan_images(pics_dir: Path, target_jpg_only: bool = False) -> list[ImageIssue]:
    """Quét toàn bộ ảnh trong thư mục và phát hiện các lỗi định dạng."""
    issues: list[ImageIssue] = []
    if not pics_dir.exists():
        return issues

    passcode_map: dict[str, list[Path]] = {}

    for item in sorted(pics_dir.iterdir()):
        if not item.is_file():
            continue

        ext = item.suffix.lower()
        if ext not in [".jpg", ".jpeg", ".png", ".webp", ".gif"]:
            continue

        passcode = item.stem
        passcode_map.setdefault(passcode, []).append(item)

        fmt, err = detect_file_format(item)
        if err and fmt in ["EMPTY", "UNREADABLE", "CORRUPT"]:
            issues.append(ImageIssue(
                file_path=item,
                detected_format=fmt,
                expected_extension=".jpg" if target_jpg_only else ext,
                current_extension=ext,
                issue_type="CORRUPT",
                details=err,
            ))
            continue

        if target_jpg_only:
            # Mục tiêu: toàn bộ phải là đuôi .jpg VÀ định dạng JPEG
            if ext != ".jpg" or fmt != "JPEG":
                issues.append(ImageIssue(
                    file_path=item,
                    detected_format=fmt,
                    expected_extension=".jpg",
                    current_extension=ext,
                    issue_type="NON_JPG",
                    details=f"Định dạng {fmt} (đuôi {ext}) -> cần chuẩn hóa thành JPEG (.jpg)",
                ))
        else:
            # Chế độ kiểm tra tính khớp giữa format và extension
            if fmt == "PNG" and ext in [".jpg", ".jpeg"]:
                issues.append(ImageIssue(
                    file_path=item,
                    detected_format="PNG",
                    expected_extension=".png",
                    current_extension=ext,
                    issue_type="MISMATCH",
                    details=f"File định dạng PNG nhưng đặt đuôi {ext} (gây lỗi JPEG FATAL ERROR)",
                ))
            elif fmt == "JPEG" and ext == ".png":
                issues.append(ImageIssue(
                    file_path=item,
                    detected_format="JPEG",
                    expected_extension=".jpg",
                    current_extension=ext,
                    issue_type="MISMATCH",
                    details="File định dạng JPEG nhưng đặt đuôi .png",
                ))
            elif fmt == "JPEG" and ext == ".jpeg":
                issues.append(ImageIssue(
                    file_path=item,
                    detected_format="JPEG",
                    expected_extension=".jpg",
                    current_extension=ext,
                    issue_type="MISMATCH",
                    details="Đuôi .jpeg cần đổi thành .jpg",
                ))
            elif fmt not in ["PNG", "JPEG"]:
                issues.append(ImageIssue(
                    file_path=item,
                    detected_format=fmt,
                    expected_extension=".jpg",
                    current_extension=ext,
                    issue_type="UNSUPPORTED",
                    details=f"Định dạng {fmt} không phải PNG hoặc JPG",
                ))

    # Kiểm tra trùng passcode
    for passcode, files in passcode_map.items():
        if len(files) > 1:
            names = ", ".join(f.name for f in files)
            for f in files:
                issues.append(ImageIssue(
                    file_path=f,
                    detected_format="DUPLICATE",
                    expected_extension=f.suffix.lower(),
                    current_extension=f.suffix.lower(),
                    issue_type="DUPLICATE",
                    details=f"Passcode {passcode} có nhiều file ảnh: [{names}]",
                ))

    return issues


def fix_issues_to_jpg(
    issues: list[ImageIssue],
    dry_run: bool = True,
    quality: int = 100,
    subsampling: int = 0,
) -> tuple[int, list[str]]:
    """Convert toàn bộ ảnh chưa chuẩn về file .jpg thật và dọn dẹp các file cũ."""
    converted_count = 0
    logs: list[str] = []

    target_issues = [i for i in issues if i.issue_type in ["NON_JPG", "MISMATCH"]]
    by_stem: dict[str, list[Path]] = {}
    for issue in target_issues:
        by_stem.setdefault(issue.file_path.stem, []).append(issue.file_path)

    for stem, files in sorted(by_stem.items()):
        # Xác định file nguồn chính
        # Nếu có file .jpg (dù format bên trong là PNG), đây là file mới nhất được đặt tên theo card
        jpg_files = [f for f in files if f.suffix.lower() in [".jpg", ".jpeg"]]
        primary_src = jpg_files[0] if jpg_files else files[0]
        dst = primary_src.parent / f"{stem}.jpg"

        # Các file còn lại là file trùng lặp (ví dụ .png cũ) cần xóa
        stale_files = [f for f in files if f != primary_src]

        # Kiểm tra nếu primary_src != dst nhưng dst đã tồn tại và đã là JPEG chuẩn
        if primary_src != dst and dst.exists():
            dst_fmt, _ = detect_file_format(dst)
            if dst_fmt == "JPEG":
                if dry_run:
                    logs.append(f"[DRY-RUN] Dọn dẹp file trùng lặp cũ: {primary_src.name} (đã có {dst.name} chuẩn JPEG)")
                    for stale in stale_files:
                        logs.append(f"[DRY-RUN] Dọn dẹp file trùng lặp cũ: {stale.name}")
                    converted_count += 1
                    continue
                remove_file(primary_src)
                logs.append(f"[CLEANUP] Đã xóa file trùng lặp cũ: {primary_src.name} ({dst.name} đã là JPEG chuẩn)")
                for stale in stale_files:
                    remove_file(stale)
                    logs.append(f"[CLEANUP] Đã xóa file trùng lặp cũ: {stale.name}")
                converted_count += 1
                continue

        if dry_run:
            if primary_src == dst:
                logs.append(f"[DRY-RUN] Re-encode sang JPEG: {primary_src.name} (quality={quality}, subsampling={subsampling})")
            else:
                logs.append(f"[DRY-RUN] Convert sang JPEG: {primary_src.name} -> {dst.name} (quality={quality}, subsampling={subsampling})")
            for stale in stale_files:
                logs.append(f"[DRY-RUN] Dọn dẹp file trùng lặp cũ: {stale.name}")
            converted_count += 1
            continue

        try:
            if primary_src == dst:
                # File đã có tên .jpg nhưng bên trong là định dạng khác (PNG, ...)
                tmp_dst = dst.with_suffix(".tmp.jpg")
                convert_image_to_jpeg(primary_src, tmp_dst, quality=quality, subsampling=subsampling)
                tmp_dst.replace(dst)
                subprocess.run(["git", "add", str(dst)], cwd=dst.parent, capture_output=True)
                logs.append(f"[RE-ENCODE] {primary_src.name} -> chuyển đổi sang JPEG chuẩn (quality={quality}, subsampling={subsampling})")
            else:
                # File nguồn là đuôi khác (ví dụ .png -> .jpg)
                convert_image_to_jpeg(primary_src, dst, quality=quality, subsampling=subsampling)
                remove_file(primary_src)
                subprocess.run(["git", "add", str(dst)], cwd=dst.parent, capture_output=True)
                logs.append(f"[CONVERT] {primary_src.name} -> {dst.name} (đã tạo JPEG chất lượng cao và xóa file cũ)")

            # Xóa các file duplicate cũ nếu có
            for stale in stale_files:
                remove_file(stale)
                logs.append(f"[CLEANUP] Đã xóa file trùng lặp cũ: {stale.name}")

            converted_count += 1

        except Exception as e:
            logs.append(f"[ERROR] Thất bại khi xử lý card {stem}: {e}")

    return converted_count, logs


def fix_mismatch_renames(issues: list[ImageIssue], dry_run: bool = True) -> tuple[int, list[str]]:
    """Đổi tên file theo đúng format thực tế (không re-encode)."""
    fixed_count = 0
    logs: list[str] = []

    mismatches = [i for i in issues if i.issue_type == "MISMATCH"]
    for issue in mismatches:
        src = issue.file_path
        dst = src.with_suffix(issue.expected_extension)

        if dst.exists():
            logs.append(f"[SKIP] Không thể đổi tên {src.name} -> {dst.name} vì {dst.name} đã tồn tại.")
            continue

        if dry_run:
            logs.append(f"[DRY-RUN] Sẽ đổi tên: {src.name} -> {dst.name}")
            fixed_count += 1
        else:
            is_git = False
            try:
                res = subprocess.run(
                    ["git", "ls-files", "--error-unmatch", str(src)],
                    cwd=src.parent,
                    capture_output=True,
                    text=True,
                )
                is_git = (res.returncode == 0)
            except Exception:
                is_git = False

            if is_git:
                try:
                    subprocess.run(
                        ["git", "mv", str(src), str(dst)],
                        cwd=src.parent,
                        check=True,
                        capture_output=True,
                    )
                    logs.append(f"[GIT MV] {src.name} -> {dst.name}")
                    fixed_count += 1
                except subprocess.CalledProcessError as e:
                    src.rename(dst)
                    logs.append(f"[RENAME] {src.name} -> {dst.name} (git mv failed: {e})")
                    fixed_count += 1
            else:
                src.rename(dst)
                logs.append(f"[RENAME] {src.name} -> {dst.name}")
                fixed_count += 1

    return fixed_count, logs


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Kiểm tra và chuẩn hóa định dạng ảnh cho card EDOPro.",
    )
    parser.add_argument(
        "--target",
        type=Path,
        default=DEFAULT_PICS_DIR,
        help="Thư mục ảnh cần quét (mặc định: pics/)",
    )
    parser.add_argument(
        "--to-jpg",
        action="store_true",
        help="Chuẩn hóa toàn bộ kho ảnh về file JPEG (.jpg) thực thụ",
    )
    parser.add_argument(
        "--quality",
        type=int,
        default=100,
        help="Chất lượng nén JPEG từ 1-100 (mặc định: 100 cho chất lượng cao nhất)",
    )
    parser.add_argument(
        "--subsampling",
        type=int,
        default=0,
        choices=[0, 1, 2],
        help="Chroma subsampling (0=4:4:4 không nén màu, sắc nét nhất; 1=4:2:2; 2=4:2:0; mặc định: 0)",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Thực hiện đổi tên / convert (mặc định là chỉ kiểm tra/dry-run)",
    )

    args = parser.parse_args()
    target_dir = args.target.resolve()

    print("=" * 60)
    print("=== TTF Image Normalization Tool ===")
    print(f"Thư mục quét: {target_dir}")
    mode_desc = (
        f"Chuẩn hóa toàn bộ sang .jpg (quality={args.quality}, subsampling={args.subsampling})"
        if args.to_jpg
        else "Kiểm tra mismatch định dạng"
    )
    print(f"Mục tiêu    : {mode_desc}")
    print(f"Hành động   : {'Áp dụng sửa đổi (--apply)' if args.apply else 'Kiểm tra (--check / dry-run)'}")
    print("=" * 60)

    if not target_dir.exists():
        print(f"Lỗi: Thư mục '{target_dir}' không tồn tại!")
        return 1

    issues = scan_images(target_dir, target_jpg_only=args.to_jpg)
    mismatches = [i for i in issues if i.issue_type in ["MISMATCH", "NON_JPG"]]
    corrupts = [i for i in issues if i.issue_type == "CORRUPT"]
    unsupported = [i for i in issues if i.issue_type == "UNSUPPORTED"]
    duplicates = [i for i in issues if i.issue_type == "DUPLICATE"]

    errors = [i for i in issues if i.issue_type in ["MISMATCH", "CORRUPT", "NON_JPG"]]

    print(f"\nKết quả quét:")
    label = "Cần convert sang .jpg (NON_JPG)" if args.to_jpg else "Sai định dạng đuôi (MISMATCH)"
    print(f"  - {label:<35}: {len(mismatches)}")
    print(f"  - File lỗi / hỏng (CORRUPT)          : {len(corrupts)}")
    print(f"  - Định dạng lạ (UNSUPPORTED)         : {len(unsupported)}")
    print(f"  - Trùng passcode (DUPLICATE)         : {len(duplicates)}")

    if issues:
        print("\nChi tiết các vấn đề phát hiện:")
        for issue in issues[:30]:
            prefix = "LỖI" if issue.issue_type in ["MISMATCH", "CORRUPT", "NON_JPG"] else "CẢNH BÁO"
            print(f"  [{prefix} - {issue.issue_type}] {issue.file_path.name}: {issue.details}")
        if len(issues) > 30:
            print(f"  ... và còn {len(issues) - 30} vấn đề khác.")

    if mismatches:
        print(f"\n{'Thực hiện xử lý:' if args.apply else 'Kế hoạch xử lý (chạy với --apply để thực hiện):'}")
        if args.to_jpg:
            count, logs = fix_issues_to_jpg(
                issues,
                dry_run=not args.apply,
                quality=args.quality,
                subsampling=args.subsampling,
            )
        else:
            count, logs = fix_mismatch_renames(issues, dry_run=not args.apply)

        for log in logs[:40]:
            print(f"  {log}")
        if len(logs) > 40:
            print(f"  ... và {len(logs) - 40} file khác.")
        print(f"\nTổng số file được xử lý: {count}/{len(mismatches)}")

    if not errors:
        print("\n[OK] Toàn bộ hình ảnh đều đạt chuẩn!")
        return 0

    return 0 if args.apply else 1


if __name__ == "__main__":
    sys.exit(main())
