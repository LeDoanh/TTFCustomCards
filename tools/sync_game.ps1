param (
    [Parameter(Mandatory=$false)]
    [string]$GameDir = "F:\Game\ProjectIgnis",

    [Parameter(Mandatory=$false)]
    [string]$CardId = ""
)

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Write-Host "=== Dong bo du lieu sang EDOPro Game ===" -ForegroundColor Cyan
Write-Host "Repo Root: $root"
Write-Host "Game Dir : $GameDir"

if (-not (Test-Path $GameDir)) {
    Write-Error "Khong tim thay thu muc game tai '$GameDir'!"
    exit 1
}

$repoDest = Join-Path $GameDir "repositories\custom_cards_zesty"
if (-not (Test-Path $repoDest)) {
    Write-Host "[INFO] Tao thu muc repo custom trong game: $repoDest" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $repoDest -Force | Out-Null
}

# Card can dong bo khi co CardId: chinh no + cac card cung archetype trong feature_list.json
# (tru nhom "Common" gom card roi rac) de deck test co san card de search/tuong tac.
$deckCodes = @()
if ($CardId -ne "") {
    $deckCodes = @($CardId)
    $featureList = Join-Path $root "feature_list.json"
    if (Test-Path $featureList) {
        $fl = Get-Content $featureList -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($arch in $fl.archetypes.PSObject.Properties) {
            $codes = @($arch.Value.cards | ForEach-Object { [string]$_.passcode })
            if ($arch.Name -ne "Common" -and $codes -contains $CardId) {
                $deckCodes += @($codes | Where-Object { $_ -ne $CardId -and (Test-Path (Join-Path $root "script\c$_.lua")) })
            }
        }
    }
}

# 1. Sync Scripts
Write-Host "`n[1/4] Dong bo scripts..." -ForegroundColor Yellow
$scriptDest = Join-Path $repoDest "script"
if (-not (Test-Path $scriptDest)) { New-Item -ItemType Directory -Path $scriptDest -Force | Out-Null }

if ($CardId -ne "") {
    foreach ($code in $deckCodes) {
        $srcFile = Join-Path $root "script\c$code.lua"
        if (Test-Path $srcFile) {
            Copy-Item $srcFile $scriptDest -Force
            Write-Host "  -> Da copy c$code.lua" -ForegroundColor Green
        } else {
            Write-Warning "Khong tim thay script/c$code.lua!"
        }
    }
    # Card goi Duel.LoadScript("constants.lua") doc ban trong game; SET_ moi chua sync
    # thi doc ra nil va crash, nen luon copy kem file nay.
    $constants = Join-Path $root "script\constants.lua"
    if (Test-Path $constants) {
        Copy-Item $constants $scriptDest -Force
        Write-Host "  -> Da copy constants.lua" -ForegroundColor Green
    }
} else {
    Copy-Item (Join-Path $root "script\*.lua") $scriptDest -Force
    Write-Host "  -> Da dong bo toan bo scripts sang game." -ForegroundColor Green
}

# 2. Sync CDBs
Write-Host "`n[2/4] Dong bo database CDB..." -ForegroundColor Yellow
# Moi *.cdb o goc repo deu duoc game nap, ke ca CDB cong dong moi them
foreach ($cdb in Get-ChildItem -Path $root -Filter "*.cdb" -File) {
    Copy-Item $cdb.FullName $repoDest -Force
    Write-Host "  -> Da copy $($cdb.Name)" -ForegroundColor Green
}

# Dong bo strings.conf neu co
$srcStrings = Join-Path $root "strings.conf"
if (Test-Path $srcStrings) {
    Copy-Item $srcStrings $repoDest -Force
    Write-Host "  -> Da copy strings.conf" -ForegroundColor Green
}

# 3. Sync Pics
Write-Host "`n[3/4] Dong bo hinh anh (Pics)..." -ForegroundColor Yellow
$picsDest = Join-Path $repoDest "pics"
if (-not (Test-Path $picsDest)) { New-Item -ItemType Directory -Path $picsDest -Force | Out-Null }

if ($CardId -ne "") {
    foreach ($code in $deckCodes) {
        $picJpg = Join-Path $root "pics\$code.jpg"
        $picPng = Join-Path $root "pics\$code.png"
        if (Test-Path $picJpg) {
            Copy-Item $picJpg $picsDest -Force
            $oldPng = Join-Path $picsDest "$code.png"
            if (Test-Path $oldPng) { Remove-Item $oldPng -Force }
            Write-Host "  -> Da copy $code.jpg (da don .png cu neu co)" -ForegroundColor Green
        } elseif (Test-Path $picPng) {
            Copy-Item $picPng $picsDest -Force
            Write-Host "  -> Da copy $code.png" -ForegroundColor Green
        }
    }
} else {
    Copy-Item (Join-Path $root "pics\*.*") $picsDest -Force
    Write-Host "  -> Da dong bo toan bo hinh anh sang game." -ForegroundColor Green
}

# 4. Tao deck test neu co CardId
if ($CardId -ne "") {
    Write-Host "`n[4/4] Tao test deck cho card $CardId..." -ForegroundColor Yellow
    $deckDir = Join-Path $GameDir "deck"
    if (Test-Path $deckDir) {
        $deckPath = Join-Path $deckDir "test_$CardId.ydk"
        # 3 ban card can test + 1 ban moi card cung archetype; Fusion/Synchro/Xyz/Link vao Extra
        # theo "type" trong card-data (card khong co spec thi xep vao Main).
        $extraMask = 0x40 -bor 0x2000 -bor 0x800000 -bor 0x4000000
        $main = @(); $extra = @()
        foreach ($code in @($CardId, $CardId) + $deckCodes) {
            $spec = Join-Path $root "card-data\c$code.json"
            $isExtra = (Test-Path $spec) -and ((([int64](Get-Content $spec -Raw -Encoding UTF8 | ConvertFrom-Json).type) -band $extraMask) -ne 0)
            if ($isExtra) { $extra += $code } else { $main += $code }
        }
        $deckLines = @("#created by TTF Test Tool", "#main") + $main + @("#extra") + $extra + @("!side")
        [System.IO.File]::WriteAllLines($deckPath, $deckLines)
        Write-Host "  -> Da tao deck test: test_$CardId.ydk" -ForegroundColor Green
    } else {
        Write-Warning "Khong thay thu muc '$deckDir' - bo qua tao deck test."
    }
}

Write-Host "`n=== Hoan tat dong bo! Khoi dong lai EDOPro de test card. ===" -ForegroundColor Cyan
