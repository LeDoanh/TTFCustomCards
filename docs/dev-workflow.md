# Quy trình phát triển nhóm

Dành cho mọi người cùng làm trên repo này: mỗi dev phụ trách một engine (archetype), làm trên nhánh riêng, test trên EDOPro của mình, rồi tích hợp và phát hành theo phiên bản. Dev là collaborator có quyền Write; chủ repo (maintainer) duyệt và merge mọi PR. Tạo/sửa từng card theo `docs/agent-workflow.md`; ma trận kịch bản duel theo `docs/game-testing-workflow.md`; lệnh chung và quy tắc commit nằm trong `AGENTS.md`. Dev dùng GitHub Desktop xem `docs/github-desktop-guide.md`.

## 1. Mô hình nhánh

| Nhánh | Vai trò | Ai ghi vào |
| :--- | :--- | :--- |
| `master` | Bản phát hành. EDOPro của người chơi tự kéo nhánh này (`should_update: true`, xem README), nên mọi commit ở đây tới tay họ ngay | Chỉ PR phát hành/hotfix do maintainer merge, mỗi lần kèm tag `vX.Y.Z` |
| `develop` | Nhánh tích hợp: gom mọi thay đổi đã test, chờ phát hành | Chỉ qua PR đã duyệt |
| `feat/<Engine>-<chủ đề>` | Thêm card hoặc đợt card mới | Owner của engine |
| `fix/<Engine>-<chủ đề>` | Sửa lỗi card | Owner, hoặc người khác kèm owner review |
| `chore/<chủ đề>` | Đăng ký engine, tools, docs, cập nhật EDOPro | Maintainer hoặc dev |
| `hotfix/<chủ đề>` | Sửa gấp bản đã phát hành, tách từ `master` | Maintainer |

Nhánh làm việc tách từ `develop` (trừ hotfix) và sống ngắn: một PR là một đợt card đã test xong, không phải cả engine. Merge xong thì xóa nhánh, đợt sau tách lại từ `develop`.

Giữ `master` làm default branch trên GitHub: clone mới của EDOPro nhận nhánh mặc định, đổi sang `develop` thì người chơi mới sẽ nhận bản chưa phát hành.

## 2. Phân bổ engine

Mỗi engine (archetype trong `feature_list.json`) có đúng một owner. Chỉ owner sửa card trong passcode range của engine đó; người khác muốn đổi thì mở PR `fix/` và owner review. Engine có CDB riêng trong `cdb/` (Nightbloom, Madoka...) là dữ liệu của dev khác, không thuộc quy trình này.

Nhận engine mới, trước khi tạo card nào:

1. Mở issue `Engine: <Name>`, gán owner, ghi danh sách effect và nguồn. Issue là sổ phân bổ; không ghi owner vào `feature_list.json` vì tool quản lý file đó. Đổi người phụ trách thì đổi assignee, passcode range giữ nguyên vì gắn vào engine.
2. Owner tách `chore/claim-<Name>` từ `develop` mới nhất, chạy `python tools/manage_harness.py archetype add <Name>` (kèm setcode nếu là archetype official), commit đúng ba file tool đã đổi: `feature_list.json`, `script/constants.lua`, `cdb/strings.conf`.
3. Maintainer merge PR đó vào `develop` **trước** khi người khác nhận engine. Tool chọn setcode và range trống theo working tree của nhánh hiện tại, nên hai người đăng ký song song sẽ nhận cùng setcode; đăng ký tuần tự qua `develop` là cách tránh trùng.
4. Owner tách `feat/<Name>-<chủ đề>` từ `develop` đã có đăng ký rồi mới tạo card.

## 3. Vòng làm việc của owner

```powershell
git fetch origin
git switch -c feat/Labrynth-extra-cards origin/develop
# tạo card, verify, test theo agent-workflow.md và game-testing-workflow.md
git add card-data/c<ID>.json script/c<ID>.lua pics/<ID>.jpg cdb/card-data.cdb feature_list.json
git commit -m "[<Git user>] [Feature]: <English description>"
```

- Add từng file của thay đổi, không `git add -A`.
- Một nhánh chỉ chứa file của một engine (`card-data/c<ID>.json`, `script/c<ID>.lua`, `pics/<ID>` trong range của engine), cùng `cdb/card-data.cdb` và phần engine đó trong `feature_list.json`. Sửa file dùng chung (`tools/`, `docs/`, template, `script/constants.lua`) thì tách sang nhánh `chore/` riêng.
- Không dùng "Add files via upload" hay sửa trên web: bỏ qua `verify` và làm CDB lệch JSON.
- Game chỉ thấy những gì đã push (mục 4): `verify` sinh lại `cdb/card-data.cdb`, rồi commit cả file này và artwork trước khi `git push -u origin HEAD`. Nhánh làm việc ở repo gốc, không cần fork.

## 4. Test trên nhánh

EDOPro không có tùy chọn chọn nhánh trong config: `repo_manager.cpp` của EDOPro chỉ đọc các key `url`, `repo_name`, `repo_path`, `data_path`, `script_path`, `pics_path`, `lflist_path`, `should_update`, `should_read`, `not_git_repo`. Clone lần đầu lấy nhánh mặc định của GitHub (`master`). Mỗi lần mở game với `should_update: true`, EDOPro chạy `fetch origin` theo `remote.origin.fetch` của clone rồi `reset --hard` về `FETCH_HEAD`. Khi `remote.origin.fetch` chỉ liệt kê một nhánh thì `FETCH_HEAD` chính là nhánh đó. Vì vậy chỉ cần **ghim** nhánh trong git config của clone nằm trong game, bằng `tools/pin_game_branch.ps1`: dev push, mở game, game tự kéo bản mới của nhánh, không clone hay chép thêm gì.

Hành vi này đã chạy thử bằng libgit2 1.9.7 trên repo thử: ghim `feat/x` thì cập nhật cho nội dung `feat/x`; push thêm commit thì lần cập nhật sau nhận commit mới; ghim `feat/y` thì đổi sang `feat/y`; bỏ ghim thì về `master`. Bản libgit2 bên trong EDOPro có thể khác và chưa chạy thử với EDOPro thật.

### 4.1 Thiết lập một lần mỗi máy

1. Khai báo repo trong `config/user_configs.json` đúng theo README (`should_update: true`), mở EDOPro một lần để game clone về `repositories/ttf-custom-cards/`.
2. Đường dẫn game khác `F:/Game/ProjectIgnis` thì đặt biến môi trường `EDOPRO_DIR`: tool Python đọc biến này để tra official script và đối chiếu passcode.

Workspace sửa code đặt ở đâu tùy ý; game không đọc workspace. Không sửa file trong `repositories/ttf-custom-cards`: mỗi lần mở game, EDOPro ghi đè mọi thay đổi cục bộ.

### 4.2 Ghim nhánh cần test

Chạy từ workspace sau khi đã push nhánh (không cần `git` trong PATH):

```powershell
powershell -File tools/pin_game_branch.ps1 feat/Labrynth-extra-cards
```

Đóng hẳn rồi mở lại EDOPro: game kéo đúng đầu nhánh đó. Push thêm commit thì chỉ cần mở lại EDOPro; đổi nhánh khác thì chạy lại script với tên mới. Chạy không tham số để xem đang ghim nhánh nào. Test xong trả về bản người chơi:

```powershell
powershell -File tools/pin_game_branch.ps1 -Unpin
```

Lần mở game sau, EDOPro cập nhật clone về `master`. Script sửa dòng `fetch =` của remote `origin` trong cấu hình Git của clone (tương đương `git remote set-branches origin <nhánh>`); đường dẫn game lấy từ `EDOPRO_DIR`, hoặc truyền `-GameDir`.

- Game chỉ thấy file đã commit và push: `cdb/card-data.cdb` đã compile khớp JSON và artwork phải nằm trong commit, thiếu thì card mới không hiện.
- Nhánh phải còn trên origin. Nhánh đã merge và bị xóa (tự xóa sau merge, mục 9) hoặc gõ sai tên thì `fetch` lỗi: EDOPro báo lỗi và giữ nguyên bản cũ. Bỏ ghim hoặc ghim nhánh khác.
- Không có deck `test_<ID>` dựng sẵn: tự dựng deck trong Deck Edit (3 bản card cần test, card cùng archetype để tìm/tương tác).

### 4.3 Ba cấp test

| Cấp | Nơi | Người chạy | Chạy gì | Đạt khi |
| :--- | :--- | :--- | :--- | :--- |
| 1. Nhánh làm việc | Máy owner | Owner | `manage_harness.py verify <ID>` cho từng card; commit và push; ghim nhánh (4.2); duel theo ma trận kịch bản | `verify` exit 0; ma trận có cột "Thực tế" đầy đủ; `error.log` lần test không có lỗi script |
| 2. Tích hợp | `develop` sau mỗi merge | Maintainer | `python -m unittest discover -s tests -v`; `manage_db.py validate`; `manage_db.py check-sync`; ghim `develop`, mở Deck Edit xem card mới, một duel thử | Mọi lệnh exit 0; game khởi động và duel không sinh lỗi mới |
| 3. Ứng viên phát hành | `develop` lúc đóng băng | Maintainer, cùng owner các engine mới | Như cấp 2 trên đầu `develop` lúc đóng băng, thêm một duel đại diện cho mỗi engine có thay đổi | Như cấp 2 |

Cấp 1 là điều kiện mở PR. `verify` là kiểm tra tĩnh; chưa duel thì PR ghi "kiểm tra tĩnh đạt, runtime chưa kiểm thử" và maintainer quyết định có merge hay không.

### 4.4 Test nhánh của người khác

Reviewer và owner kiểm tra card đụng tới engine mình ghim nhánh đó như 4.2, không cần clone hay chép gì thêm. Nhánh phải có `cdb/card-data.cdb` đã commit, vì đó là file game đọc.

### 4.5 Thử khi chưa push (tùy chọn)

Muốn thử ngay khi chưa commit thì khai báo workspace là repo `not_git_repo`: EDOPro không clone, không cập nhật, chỉ đọc thư mục. `repo_path` luôn bị EDOPro thêm tiền tố `./` nên workspace phải nằm dưới thư mục game (ví dụ `git clone` vào `F:/Game/ProjectIgnis/repositories/ttf-dev`), không dùng đường dẫn tuyệt đối. Thêm entry này vào `"repos"` và đặt `"should_read": false` cho entry người chơi, vì hai entry cùng đọc sẽ nạp trùng passcode:

```json
{
  "repo_name": "TTFCustomCards-dev",
  "repo_path": "./repositories/ttf-dev",
  "data_path": "cdb",
  "script_path": "script",
  "not_git_repo": true,
  "should_read": true
}
```

Đổi nhánh bằng `git switch` trong `ttf-dev` khi game đã đóng. Không đặt `url` cho entry này: thư mục không phải git repo mà có `url` thì EDOPro xóa thư mục rồi clone lại.

## 5. Đồng bộ và xử lý xung đột

Trước mỗi lần làm việc và trước khi mở PR:

```powershell
git fetch origin
git merge origin/develop
```

Dùng merge, không rebase: nhánh đã push, rebase đổi hash và buộc force-push. Các file dễ xung đột:

| File | Vì sao | Cách xử lý |
| :--- | :--- | :--- |
| `cdb/card-data.cdb` | Nhị phân sinh từ JSON; nhánh nào thêm card cũng ghi lại | Giải xung đột JSON và text trước, rồi `python tools/manage_db.py compile` và `git add cdb/card-data.cdb`. Không chọn cả file ours/theirs (`docs/agent-rules.md` §3.4) |
| `feature_list.json` | Tool ghi `last_updated` bằng ngày chạy, nên hai nhánh chạy tool khác ngày luôn xung đột dòng này; engine khác nhau thì tự merge | Giữ ngày muộn hơn, giữ cả hai phần engine |
| `script/constants.lua`, `cdb/strings.conf` | Archetype mới chèn vào cùng điểm đánh dấu | Chỉ PR `chore/claim-*` (tuần tự, mục 2) chạm hai file này; nếu vẫn gặp, giữ cả hai dòng và kiểm tra không trùng setcode |

Giải xong thì chạy `manage_db.py check-sync` và `verify` lại các card đã đổi. Xung đột chạm hằng số hoặc helper mà card dùng thì test lại bằng duel.

## 6. Pull request vào `develop`

Từ nhánh đã push, mở PR bằng nút "Compare & pull request" trên trang repo, hoặc:

```powershell
gh pr create --base develop --title "[<Git user>] [Feature]: <English description>"
```

**Base phải là `develop`**: GitHub mặc định chọn `master`. PR nhầm base thì bấm "Edit" cạnh tiêu đề để đổi lại.

Mô tả PR gồm: engine, card ID, official reference đã dùng (`docs/agent-workflow.md` §2), lệnh đã chạy kèm kết quả, ma trận duel với kết quả thực tế (`docs/game-testing-workflow.md` §6). Nhánh phải đã merge `origin/develop` mới nhất.

Chủ repo duyệt: tab "Files changed" chỉ có file của một engine (mục 3); test lại nhánh nếu cần (4.4); "Review changes" -> Approve hoặc Request changes. Merge theo thứ tự, mỗi lần một PR:

- Base `develop`: "Squash and merge", tiêu đề theo định dạng commit của `AGENTS.md`. Nhánh tự xóa sau merge (mục 9).
- Mọi PR card đều sửa `cdb/card-data.cdb`, nên sau khi một PR merge, PR kia báo "This branch has conflicts". Dev merge `origin/develop` về nhánh, `compile` lại CDB (mục 5) rồi push. Xung đột này là chốt chặn bảo đảm CDB luôn sinh từ nguồn đã gồm mọi PR trước. Không bật "Require branches to be up to date" và không đặt CI làm status check bắt buộc: tùy chọn đó của GitHub gắn với status check, còn CI chỉ chạy một lần mỗi PR nên một check bắt buộc sẽ treo ở các commit sau.
- CI (mục 10) chạy một lần khi mở PR và một lần sau mỗi merge; xem dấu xanh/đỏ trên PR hoặc tab Actions. Dev đẩy thêm commit sau lần CI đầu thì CI không tự chạy lại: Actions -> CI -> Run workflow, chọn nhánh PR.
- Chạy test cấp 2 sau mỗi merge.

## 7. Phát hành theo phiên bản

Phiên bản `vMAJOR.MINOR.PATCH`, đặt bằng tag có chú thích trên `master`:

| Tăng | Khi |
| :--- | :--- |
| MAJOR | Thay đổi buộc người chơi sửa deck hoặc cấu hình: xóa hoặc đổi passcode card, đổi `data_path`/`repo_path` trong README |
| MINOR | Thêm engine hoặc card mới; đổi hiệu ứng card có sẵn có chủ đích |
| PATCH | Chỉ sửa lỗi script, text, artwork |

Không tạo nhánh riêng cho từng phiên bản (`ver1.0`, `ver1.1`...). EDOPro của người chơi luôn theo `master`, không ai được phục vụ bản cũ, nên nhánh theo phiên bản không có người dùng; mỗi dòng nhánh thêm còn là thêm một chỗ phải giải xung đột `card-data.cdb`. `develop` là dòng phát triển duy nhất, tag đánh dấu từng điểm phát hành để đối chiếu (`git diff v1.0.0 v1.1.0`) và quay lại khi cần. Chỉ khi đóng băng làm dev bị chặn quá lâu mới cắt `release/vX.Y` từ `develop` lúc đóng băng: sửa lỗi ổn định trên đó, các dev vẫn merge vào `develop`, phát hành xong thì merge `release/vX.Y` vào cả `master` lẫn `develop`.

Quy trình, do maintainer thực hiện:

1. Thông báo đóng băng: không merge PR mới vào `develop`.
2. Chạy test cấp 3.
3. Mở PR `develop` -> `master` tên `Release vX.Y.Z`, merge bằng **merge commit** (không squash) để hai nhánh không lệch lịch sử.
4. Gắn tag và tạo release; ghi chú tự sinh từ các PR đã merge, không viết changelog tay (lịch sử thay đổi là Git, xem `AGENTS.md`):

```powershell
git fetch origin
git tag -a vX.Y.Z origin/master -m "Release vX.Y.Z"
git push origin vX.Y.Z
gh release create vX.Y.Z --verify-tag --generate-notes
```

5. Xác nhận với cấu hình người chơi: bỏ ghim (`pin_game_branch.ps1 -Unpin`, mục 4.2), mở EDOPro, kiểm tra game kéo đúng bản mới.
6. Mở băng.

Lỗi nặng trên bản đã phát hành: tách `hotfix/<chủ đề>` từ `origin/master`, sửa, `verify`, đưa nhánh vào game (mục 4.2) và test lại, PR vào `master` (merge commit), tag PATCH, rồi PR `master` -> `develop` để bản sửa không mất ở lần phát hành sau.

## 8. Cập nhật theo phiên bản EDOPro

Khi EDOPro ra bản mới (API hoặc hằng số có thể đổi), một maintainer cập nhật bản cài của mình rồi:

1. Tách `chore/edopro-<phiên bản>` từ `develop`, chạy `python tools/sync_edopro_refs.py --check`.
2. Lệch thì chạy lại không có `--check` và commit `tools/edopro_constants.txt`, `tools/edopro_apis.txt` (`docs/agent-workflow.md` §4). Kiểm tra `lua` trong PATH cùng phiên bản với EDOPro.
3. Chạy test cấp 2, merge vào `develop`.
4. Owner các engine merge `origin/develop` về nhánh đang làm; card nào FAIL vì tên API/hằng số đổi thì owner sửa theo tên thật.

Bản đã phát hành chỉ nhận thay đổi này qua kỳ phát hành kế tiếp, sau test cấp 3.

## 9. Thiết lập trên GitHub (chủ repo, một lần)

Repo đang public nên GitHub Actions trên runner chuẩn miễn phí; chuyển sang private thì gói Free có 2.000 phút mỗi tháng, và CI ở mục 10 đã giữ số lần chạy ở mức thấp.

1. Commit toàn bộ thay đổi hiện có (tài liệu, `.github/workflows/ci.yml`, `.github/CODEOWNERS`, `tools/pin_game_branch.ps1`, `tools/validate_scripts.ps1`) và push thẳng lên `master`. Đây là lần push thẳng cuối, làm **trước** khi bật ruleset ở bước 5. `CODEOWNERS` phải có trên nhánh đích của PR mới có tác dụng, nên tạo `develop` (bước 2) sau bước này. GitHub Desktop: tick các file ở tab Changes -> "Commit to master" -> "Push origin".
2. Tạo `develop` từ `master` và tag mốc đầu:

```powershell
git fetch origin
git push origin origin/master:refs/heads/develop
git tag -a v1.0.0 origin/master -m "Baseline release v1.0.0"
git push origin v1.0.0
```

GitHub Desktop tạo được `develop`: Current Branch -> New Branch -> tên `develop` (based on `master`) -> Create Branch -> Publish branch. Tag làm trên web: Releases -> Draft a new release -> ô "Choose a tag" gõ `v1.0.0` rồi "Create new tag on publish", Target `master` -> Generate release notes -> Publish release.

3. Settings -> Collaborators -> Add people: nhập username dev, quyền Write. Dev phải chấp nhận lời mời.
4. Settings -> General -> Pull Requests: bật "Allow squash merging" và "Allow merge commits", tắt "Allow rebase merging", bật "Automatically delete head branches".
5. Settings -> Rules -> Rulesets -> New ruleset -> New branch ruleset. Tạo hai ruleset, cùng cấu hình trừ tên, nhánh đích và kiểu merge:

| Tên | Nhánh đích (Add target -> Include by pattern) | Allowed merge methods |
| :--- | :--- | :--- |
| `protect-develop` | `develop` | Squash |
| `protect-master` | `master` | Merge |

Cấu hình chung: Enforcement status **Active**; Bypass list -> Add bypass -> Repository admin, rồi bấm dấu ba chấm cạnh "Always allow" chọn **For pull requests only** (chủ repo vẫn phải qua PR nhưng tự merge được PR của mình, không push thẳng được); bật "Restrict deletions", "Block force pushes", "Require a pull request before merging" với Required approvals = 1, **"Require review from Code Owners"** và Allowed merge methods như bảng. Không thêm "Require status checks" (mục 6). File `.github/CODEOWNERS` (`* @LeDoanh`, đã có trong repo từ bước 1) làm cho mọi file thuộc chủ repo, nên PR của dev chỉ merge được sau khi chủ repo approve; approve của collaborator khác không tính. PR của chính chủ repo không tự approve được, đã có quyền bypass "For pull requests only" ở trên lo phần này.

6. Settings -> General -> Default branch: giữ `master` (mục 1).
7. Chạy thử CI trước khi mời dev: Actions -> CI -> Run workflow (nhánh `master`). Phải xanh. Workflow chưa từng chạy trên runner thật, nên bước này là bài kiểm tra đầu tiên; đỏ ở bước "Validate Lua scripts" thì gửi log để sửa.
8. Chạy thử ghim nhánh: tạo nhánh tạm từ `develop`, push, chạy `pin_game_branch.ps1` (mục 4.2), mở EDOPro và xác nhận game kéo đúng nhánh; rồi `-Unpin` và xóa nhánh tạm.

## 10. CI

`.github/workflows/ci.yml` chạy thưa để không tốn phút Actions:

| Khi nào | Script Lua được kiểm tra |
| :--- | :--- |
| Mở PR vào `develop`/`master` (PR nháp được bỏ qua đến khi bấm "Ready for review") | Card trong `card-data/` có thay đổi trong PR |
| Sau mỗi merge vào `develop`/`master` | Card trong `card-data/` có thay đổi trong lần merge |
| Thủ công: Actions -> CI -> Run workflow, chọn nhánh | Toàn bộ card trong `card-data/` |

CI không chạy khi push lên nhánh làm việc, và bỏ qua thay đổi chỉ gồm `*.md` hoặc `docs/`. Mỗi lần chạy: unit test trong `tests/`, `manage_db.py validate`, `manage_db.py check-sync`, và `validate_scripts.ps1` cho từng script của card trong `card-data/` (script của dev khác ngoài `card-data/` không bị quét).

Giới hạn: runner không có EDOPro, nên CI không đối chiếu passcode với CDB official và không duel. `verify` và test cấp 1 trên máy dev vẫn bắt buộc. CI chỉ báo kết quả, không chặn merge.

Muốn giảm thêm thì xóa khối `pull_request` trong `ci.yml`: CI chỉ còn chạy sau merge và khi chạy thủ công.
