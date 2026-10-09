<#
.SYNOPSIS
    Chon nhanh Git de test trong game EDOPro: menu bam so, hoac chon thang bang tham so.
.DESCRIPTION
    Moi lan mo game (should_update: true), EDOPro chay fetch roi reset --hard ve FETCH_HEAD cua clone
    trong repositories/ttf-custom-cards. Khi cau hinh fetch cua clone chi liet ke mot nhanh ("ghim" nhanh)
    thi FETCH_HEAD la nhanh do, nen game tu keo ban moi cua nhanh sau moi lan dev push.
    Script sua dung dong "fetch =" cua remote origin trong .git/config, khong can git trong PATH.

    Chay khong tham so se mo menu:
      1. Chon nhanh de test: lay danh sach nhanh tu GitHub (API cong khai, khong can dang nhap),
         chon bang so; neu khong lay duoc danh sach thi nhap ten nhanh bang tay
      2. Ve ban nguoi choi (bo chon nhanh)
      3. Doi duong dan game / 4. Xoa duong dan game da luu (luu o %APPDATA%\TTFCustomCards\game-dir.txt)
    Thu tu tim clone: -RepoDir > -GameDir > duong dan da luu > chinh clone chua script nay
    (tester chay repositories/ttf-custom-cards/tools/pin_game_branch.ps1) > EDOPRO_DIR > F:\Game\ProjectIgnis.
.PARAMETER Branch
    Chon thang nhanh nay de test (da push len origin), khong mo menu. Vi du engine/Labrynth.
.PARAMETER Unpin
    Ve ban nguoi choi, khong mo menu: clone theo doi moi nhanh, game cap nhat ve master o lan mo sau.
.PARAMETER GameDir
    Thu muc cai EDOPro. Clone la <GameDir>\repositories\ttf-custom-cards.
.PARAMETER RepoDir
    Duong dan thang toi clone repo trong game.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools/pin_game_branch.ps1
    powershell -File tools/pin_game_branch.ps1 engine/Labrynth
    powershell -File tools/pin_game_branch.ps1 -Unpin
#>

param(
    [Parameter(Position = 0)]
    [string]$Branch = "",
    [switch]$Unpin,
    [string]$GameDir = "",
    [string]$RepoDir = ""
)

$ErrorActionPreference = "Stop"

$cloneName = "ttf-custom-cards"
$allBranchesSpec = "+refs/heads/*:refs/remotes/origin/*"
$fallbackGameDir = "F:\Game\ProjectIgnis"
$settingsBase = if ($env:APPDATA) { $env:APPDATA } else { $HOME }
$settingsDir = Join-Path $settingsBase "TTFCustomCards"
$savedPathFile = Join-Path $settingsDir "game-dir.txt"

# ---------------------------------------------------------------- duong dan game

function Get-CloneOf([string]$gamePath) {
    return Join-Path (Join-Path $gamePath "repositories") $cloneName
}

function Test-Clone([string]$clonePath) {
    return (Test-Path (Join-Path (Join-Path $clonePath ".git") "config"))
}

function Get-SavedGameDir {
    if (Test-Path $savedPathFile) {
        $text = [System.IO.File]::ReadAllText($savedPathFile).Trim()
        if ($text -ne "") { return $text }
    }
    return ""
}

function Save-GameDir([string]$gamePath) {
    if (-not (Test-Path $settingsDir)) { New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null }
    [System.IO.File]::WriteAllText($savedPathFile, $gamePath, [System.Text.UTF8Encoding]::new($false))
}

function Resolve-Clone {
    if ($RepoDir -ne "") { return @{ Path = $RepoDir; Source = "tham so -RepoDir" } }
    if ($GameDir -ne "") { return @{ Path = (Get-CloneOf $GameDir); Source = "tham so -GameDir" } }
    $saved = Get-SavedGameDir
    if ($saved -ne "") { return @{ Path = (Get-CloneOf $saved); Source = "duong dan da luu" } }
    $selfRepo = Split-Path $PSScriptRoot
    if (((Split-Path $selfRepo -Leaf) -eq $cloneName) -and ((Split-Path (Split-Path $selfRepo) -Leaf) -eq "repositories")) {
        return @{ Path = $selfRepo; Source = "script nam trong game" }
    }
    if ($env:EDOPRO_DIR) { return @{ Path = (Get-CloneOf $env:EDOPRO_DIR); Source = "bien EDOPRO_DIR" } }
    $fallbackClone = Get-CloneOf $fallbackGameDir
    if (Test-Clone $fallbackClone) { return @{ Path = $fallbackClone; Source = "mac dinh" } }
    return $null
}

# ---------------------------------------------------------------- doc / sua .git/config

function Read-Origin([string]$clonePath) {
    $configPath = Join-Path (Join-Path $clonePath ".git") "config"
    $raw = [System.IO.File]::ReadAllText($configPath)
    $eol = if ($raw.Contains("`r`n")) { "`r`n" } else { "`n" }
    $lines = [System.Collections.Generic.List[string]]::new()
    foreach ($l in ($raw -split "\r?\n")) { $lines.Add($l) }
    if ($lines.Count -gt 0 -and $lines[$lines.Count - 1] -eq "") { $lines.RemoveAt($lines.Count - 1) }

    $header = -1
    $fetchIdx = @()
    $originUrl = ""
    $inOrigin = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\s*\[(.+)\]\s*$') {
            $inOrigin = ($Matches[1] -eq 'remote "origin"')
            if ($inOrigin -and $header -lt 0) { $header = $i }
        } elseif ($inOrigin) {
            if ($lines[$i] -match '^\s*fetch\s*=') {
                $fetchIdx += $i
            } elseif ($lines[$i] -match '^\s*url\s*=\s*(.+?)\s*$') {
                $originUrl = $Matches[1]
            }
        }
    }
    return @{ ConfigPath = $configPath; Lines = $lines; Eol = $eol; Header = $header; FetchIdx = $fetchIdx; Url = $originUrl }
}

function Get-PinnedBranch($origin) {
    if ($origin.FetchIdx.Count -ne 1) { return "" }
    $m = [regex]::Match($origin.Lines[$origin.FetchIdx[0]], '=\s*\+refs/heads/(?<b>[^*\s:]+):refs/remotes/origin/(?<b2>[^*\s]+)\s*$')
    if ($m.Success -and $m.Groups['b'].Value -eq $m.Groups['b2'].Value) { return $m.Groups['b'].Value }
    return ""
}

function Set-Refspec($origin, [string]$refspec) {
    if ($origin.Header -lt 0) { throw "Khong thay [remote ""origin""] trong cau hinh cua clone." }
    $fetchLine = "`tfetch = $refspec"
    $cfgLines = $origin.Lines
    if ($origin.FetchIdx.Count -gt 0) {
        $cfgLines[$origin.FetchIdx[0]] = $fetchLine
        for ($k = $origin.FetchIdx.Count - 1; $k -ge 1; $k--) { $cfgLines.RemoveAt($origin.FetchIdx[$k]) }
    } else {
        $cfgLines.Insert($origin.Header + 1, $fetchLine)
    }
    $text = ($cfgLines -join $origin.Eol) + $origin.Eol
    [System.IO.File]::WriteAllText($origin.ConfigPath, $text, [System.Text.UTF8Encoding]::new($false))
}

# ---------------------------------------------------------------- chon nhanh / ve ban nguoi choi

function Test-BranchName([string]$name) {
    return ($name -match '^[A-Za-z0-9][A-Za-z0-9._/\-]*$') -and (-not $name.Contains('..')) -and (-not $name.EndsWith('/'))
}

function Show-GameRunningWarning {
    if (Get-Process -Name "EDOPro" -ErrorAction SilentlyContinue) {
        Write-Host "EDOPro dang chay: dong han game roi mo lai de ap dung." -ForegroundColor Yellow
    }
}

function Invoke-Pin([string]$clonePath, [string]$name) {
    if (-not (Test-BranchName $name)) {
        Write-Host "Ten nhanh '$name' khong hop le." -ForegroundColor Red
        return $false
    }
    $origin = Read-Origin $clonePath
    Set-Refspec $origin ("+refs/heads/${name}:refs/remotes/origin/${name}")
    Write-Host "Da chon nhanh '$name' de test. Dong han EDOPro roi mo lai de game keo ban moi cua nhanh nay." -ForegroundColor Green
    Write-Host "Nhanh phai da push len origin; go sai ten thi game bao loi cap nhat va giu ban cu." -ForegroundColor Gray
    Show-GameRunningWarning
    return $true
}

function Invoke-Unpin([string]$clonePath) {
    $origin = Read-Origin $clonePath
    Set-Refspec $origin $allBranchesSpec
    Write-Host "Da ve ban nguoi choi. Lan mo EDOPro sau, game cap nhat ve nhanh master." -ForegroundColor Green
    Show-GameRunningWarning
}

# ---------------------------------------------------------------- danh sach nhanh tren GitHub

function Get-RemoteBranches([string]$originUrl) {
    $m = [regex]::Match($originUrl, 'github\.com[/:](?<o>[^/]+)/(?<r>[^/]+?)(?:\.git)?/?$')
    if (-not $m.Success) { throw "Khong doc duoc ten repo GitHub tu url '$originUrl'." }
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $found = [System.Collections.Generic.List[string]]::new()
    for ($page = 1; $page -le 10; $page++) {
        $uri = "https://api.github.com/repos/$($m.Groups['o'].Value)/$($m.Groups['r'].Value)/branches?per_page=100&page=$page"
        $response = Invoke-RestMethod -Uri $uri -UserAgent "ttf-pin-game-branch" -TimeoutSec 20
        $pageCount = 0
        # Windows PowerShell 5.1 tra ca mang JSON nhu mot doi tuong; @() tach ra tung phan tu o ca hai ban
        foreach ($entry in @($response)) {
            foreach ($item in @($entry)) {
                if ($item.name) { $found.Add([string]$item.name); $pageCount++ }
            }
        }
        if ($pageCount -lt 100) { break }
    }
    return $found.ToArray()
}

# ---------------------------------------------------------------- menu

function Show-Status($clone) {
    Write-Host ""
    Write-Host "=== Chon nhanh de test trong game EDOPro (TTFCustomCards) ===" -ForegroundColor Cyan
    if ($null -eq $clone) {
        Write-Host "Game : chua biet duong dan (chon 3 de nhap)" -ForegroundColor Yellow
        return
    }
    Write-Host "Clone: $($clone.Path)   [$($clone.Source)]"
    if (-not (Test-Clone $clone.Path)) {
        Write-Host "       Khong thay clone Git o day. Mo EDOPro mot lan de game tai repo, hoac chon 3 de doi duong dan game." -ForegroundColor Red
        return
    }
    try {
        $pinned = Get-PinnedBranch (Read-Origin $clone.Path)
        if ($pinned -ne "") { Write-Host "Dang test: $pinned" -ForegroundColor Green }
        else { Write-Host "Dang test: ban nguoi choi (game theo master)" -ForegroundColor Gray }
    } catch {
        Write-Host "Khong doc duoc cau hinh clone ($($_.Exception.Message))" -ForegroundColor Red
    }
}

function Confirm-Clone($clone) {
    if ($null -ne $clone -and (Test-Clone $clone.Path)) { return $true }
    Write-Host "Chua co clone game hop le. Chon 3 de nhap duong dan thu muc EDOPro (hoac mo EDOPro mot lan de game tai repo)." -ForegroundColor Yellow
    return $false
}

function Read-BranchNameAndPin($clone) {
    $typedName = Read-Host "Nhap ten nhanh (vi du engine/Labrynth, de trong de huy)"
    if ($typedName -and $typedName.Trim() -ne "") { Invoke-Pin $clone.Path $typedName.Trim() | Out-Null }
}

function Select-Branch($clone) {
    $origin = Read-Origin $clone.Path
    Write-Host "Dang lay danh sach nhanh tu GitHub..." -ForegroundColor Gray
    try {
        $names = @(Get-RemoteBranches $origin.Url)
    } catch {
        Write-Host "Khong lay duoc danh sach nhanh: $($_.Exception.Message)" -ForegroundColor Red
        Read-BranchNameAndPin $clone
        return
    }
    if ($names.Count -eq 0) {
        Write-Host "GitHub khong tra ve nhanh nao." -ForegroundColor Yellow
        Read-BranchNameAndPin $clone
        return
    }
    $pinned = Get-PinnedBranch $origin
    $first = @(@('develop', 'master') | Where-Object { $names -contains $_ })
    $rest = @($names | Where-Object { $first -notcontains $_ } | Sort-Object)
    $everything = @($first) + @($rest)
    $common = @($names | Where-Object { $_ -eq 'develop' -or $_ -like 'engine/*' } | Sort-Object)
    $showAll = ($common.Count -eq 0)

    while ($true) {
        if ($showAll) { $list = @($everything) } else { $list = @($common) }
        Write-Host ""
        if ($showAll) { Write-Host "Tat ca nhanh tren GitHub:" -ForegroundColor Cyan }
        else { Write-Host "Nhanh develop va engine/*:" -ForegroundColor Cyan }
        for ($n = 0; $n -lt $list.Count; $n++) {
            $mark = if ($list[$n] -eq $pinned) { "  <- dang test" } else { "" }
            Write-Host ("{0,4}. {1}{2}" -f ($n + 1), $list[$n], $mark)
        }
        Write-Host "   a. Chuyen giua danh sach rut gon / tat ca nhanh"
        Write-Host "   t. Nhap ten nhanh bang tay"
        Write-Host "   0. Quay lai"
        $answer = Read-Host "Chon"
        if ($null -eq $answer) { return }
        $answer = $answer.Trim()
        if ($answer -eq "" -or $answer -eq "0") { return }
        if ($answer -eq "a") { $showAll = -not $showAll; continue }
        if ($answer -eq "t") { Read-BranchNameAndPin $clone; return }
        $num = 0
        if ([int]::TryParse($answer, [ref]$num) -and $num -ge 1 -and $num -le $list.Count) {
            Invoke-Pin $clone.Path $list[$num - 1] | Out-Null
            return
        }
        Write-Host "Lua chon khong hop le." -ForegroundColor Red
    }
}

function Set-GameDirInteractive {
    Write-Host "Nhap thu muc cai EDOPro (vi du F:\Game\ProjectIgnis). De trong de huy."
    $typed = Read-Host "Duong dan"
    if ($null -eq $typed) { return }
    $typed = $typed.Trim().Trim('"')
    if ($typed -eq "") { return }
    $candidate = $typed
    if (-not (Test-Clone (Get-CloneOf $candidate))) {
        if (((Split-Path $candidate -Leaf) -eq $cloneName) -and (Test-Clone $candidate)) {
            $candidate = Split-Path (Split-Path $candidate)
        } else {
            Write-Host "Khong thay clone Git trong '$(Get-CloneOf $typed)'. Mo EDOPro mot lan de game tai repo, hoac kiem tra lai duong dan." -ForegroundColor Red
            return
        }
    }
    Save-GameDir $candidate
    Write-Host "Da luu duong dan game: $candidate" -ForegroundColor Green
}

function Clear-GameDirInteractive {
    if (Test-Path $savedPathFile) {
        Remove-Item $savedPathFile -Force
        Write-Host "Da xoa duong dan game da luu." -ForegroundColor Green
    } else {
        Write-Host "Khong co duong dan nao da luu." -ForegroundColor Gray
    }
}

function Invoke-Interactive {
    if ($null -eq (Resolve-Clone)) {
        Write-Host "Chua biet thu muc game o dau." -ForegroundColor Yellow
        Set-GameDirInteractive
    }
    while ($true) {
        $clone = Resolve-Clone
        Show-Status $clone
        Write-Host ""
        Write-Host " 1. Chon nhanh de test"
        Write-Host " 2. Ve ban nguoi choi (bo chon nhanh)"
        Write-Host " 3. Doi duong dan game"
        Write-Host " 4. Xoa duong dan game da luu"
        Write-Host " 0. Thoat"
        $choice = Read-Host "Chon"
        if ($null -eq $choice) { return }
        switch ($choice.Trim()) {
            "1" { if (Confirm-Clone $clone) { Select-Branch $clone } }
            "2" { if (Confirm-Clone $clone) { Invoke-Unpin $clone.Path } }
            "3" { Set-GameDirInteractive }
            "4" { Clear-GameDirInteractive }
            "0" { return }
            "" { }
            default { Write-Host "Lua chon khong hop le." -ForegroundColor Red }
        }
    }
}

# ---------------------------------------------------------------- diem vao

if ($Branch -ne "" -or $Unpin) {
    if ($Branch -ne "" -and $Unpin) {
        Write-Error "Chi dung mot trong hai: ten nhanh hoac -Unpin."
        exit 1
    }
    $target = Resolve-Clone
    if ($null -eq $target -or -not (Test-Clone $target.Path)) {
        Write-Error "Khong thay clone Git cua game. Mo EDOPro mot lan de game tai repo, hoac truyen -GameDir / -RepoDir, hoac chay khong tham so de chon duong dan."
        exit 1
    }
    if ($Unpin) {
        Invoke-Unpin $target.Path
        exit 0
    }
    if (-not (Invoke-Pin $target.Path $Branch)) { exit 1 }
    exit 0
}

Invoke-Interactive
