<#
.SYNOPSIS
    Ghim nhanh Git cho clone repo TTFCustomCards trong thu muc game EDOPro.
.DESCRIPTION
    Moi lan mo game (should_update: true), EDOPro chay fetch roi reset --hard ve FETCH_HEAD cua clone
    trong repositories/ttf-custom-cards. Khi cau hinh fetch cua clone chi liet ke mot nhanh thi
    FETCH_HEAD la nhanh do, nen game tu keo ban moi cua nhanh sau moi lan dev push.
    Script sua dung dong "fetch =" cua remote origin trong .git/config, khong can git trong PATH.
.PARAMETER Branch
    Ten nhanh can test (da push len origin), vi du engine/Labrynth.
.PARAMETER Unpin
    Bo ghim, tra clone ve theo doi moi nhanh (game cap nhat ve master o lan mo sau).
.PARAMETER GameDir
    Thu muc cai EDOPro. Mac dinh: $env:EDOPRO_DIR hoac F:\Game\ProjectIgnis.
.PARAMETER RepoDir
    Clone repo trong game. Mac dinh: <GameDir>\repositories\ttf-custom-cards.
.EXAMPLE
    powershell -File tools/pin_game_branch.ps1 engine/Labrynth
    powershell -File tools/pin_game_branch.ps1 -Unpin
    powershell -File tools/pin_game_branch.ps1
#>

param(
    [Parameter(Position = 0)]
    [string]$Branch = "",
    [switch]$Unpin,
    [string]$GameDir = "",
    [string]$RepoDir = ""
)

if ($GameDir -eq "") {
    $GameDir = if ($env:EDOPRO_DIR) { $env:EDOPRO_DIR } else { "F:\Game\ProjectIgnis" }
}
if ($RepoDir -eq "") {
    $RepoDir = Join-Path (Join-Path $GameDir "repositories") "ttf-custom-cards"
}

if ($Branch -ne "" -and $Unpin) {
    Write-Error "Chi dung mot trong hai: ten nhanh hoac -Unpin."
    exit 1
}
if ($Branch -ne "" -and (($Branch -notmatch '^[A-Za-z0-9][A-Za-z0-9._/\-]*$') -or $Branch.Contains('..') -or $Branch.EndsWith('/'))) {
    Write-Error "Ten nhanh '$Branch' khong hop le."
    exit 1
}

$configPath = Join-Path (Join-Path $RepoDir ".git") "config"
if (-not (Test-Path $configPath)) {
    Write-Error "Khong thay clone Git tai '$RepoDir'. Mo EDOPro mot lan de game tai repo, hoac truyen -GameDir / -RepoDir."
    exit 1
}

$raw = [System.IO.File]::ReadAllText($configPath)
$newline = if ($raw.Contains("`r`n")) { "`r`n" } else { "`n" }
$lines = [System.Collections.Generic.List[string]]::new()
foreach ($l in ($raw -split "\r?\n")) { $lines.Add($l) }
if ($lines.Count -gt 0 -and $lines[$lines.Count - 1] -eq "") { $lines.RemoveAt($lines.Count - 1) }

# Tim dong "fetch =" trong [remote "origin"]
$header = -1
$fetchIdx = @()
$inOrigin = $false
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^\s*\[(.+)\]\s*$') {
        $inOrigin = ($Matches[1] -eq 'remote "origin"')
        if ($inOrigin -and $header -lt 0) { $header = $i }
    } elseif ($inOrigin -and $lines[$i] -match '^\s*fetch\s*=') {
        $fetchIdx += $i
    }
}
if ($header -lt 0) {
    Write-Error "Khong thay [remote ""origin""] trong $configPath."
    exit 1
}

function Get-PinnedBranch([string[]]$fetchLines) {
    if ($fetchLines.Count -ne 1) { return $null }
    $m = [regex]::Match($fetchLines[0], '=\s*\+refs/heads/(?<b>[^*\s:]+):refs/remotes/origin/(?<b2>[^*\s]+)\s*$')
    if ($m.Success -and $m.Groups['b'].Value -eq $m.Groups['b2'].Value) { return $m.Groups['b'].Value }
    return $null
}

$current = @($fetchIdx | ForEach-Object { $lines[$_] })

if ($Branch -eq "" -and -not $Unpin) {
    $pinned = Get-PinnedBranch $current
    if ($pinned) { Write-Host "Dang ghim nhanh: $pinned" -ForegroundColor Cyan }
    else { Write-Host "Chua ghim nhanh nao (game cap nhat theo nhanh mac dinh cua repo)." -ForegroundColor Cyan }
    Write-Host "Cach dung: tools/pin_game_branch.ps1 <ten-nhanh>   hoac   -Unpin"
    exit 0
}

$refspec = if ($Unpin) { "+refs/heads/*:refs/remotes/origin/*" } else { "+refs/heads/${Branch}:refs/remotes/origin/${Branch}" }
$fetchLine = "`tfetch = $refspec"

if ($fetchIdx.Count -gt 0) {
    $lines[$fetchIdx[0]] = $fetchLine
    for ($k = $fetchIdx.Count - 1; $k -ge 1; $k--) { $lines.RemoveAt($fetchIdx[$k]) }
} else {
    $lines.Insert($header + 1, $fetchLine)
}

$text = ($lines -join $newline) + $newline
[System.IO.File]::WriteAllText($configPath, $text, [System.Text.UTF8Encoding]::new($false))

if ($Unpin) {
    Write-Host "Da bo ghim. Lan mo EDOPro sau, game cap nhat clone ve nhanh mac dinh (master)." -ForegroundColor Green
} else {
    Write-Host "Da ghim nhanh '$Branch'. Dong han EDOPro roi mo lai de game keo ban moi cua nhanh nay." -ForegroundColor Green
    Write-Host "Nhanh phai da push len origin; xoa hoac go sai ten thi game bao loi cap nhat va giu ban cu." -ForegroundColor Gray
}
