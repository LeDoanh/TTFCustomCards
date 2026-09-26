<#
.SYNOPSIS
    EDOPro Card Script Validator — Kiểm tra Lua script tự động
.DESCRIPTION
    Quét tất cả file .lua trong thư mục script/ và kiểm tra:
    - FAIL: cú pháp Lua (gọi Lua parser)
    - FAIL STRUCT: thiếu initial_effect, GetID() hoặc RegisterEffect
    - FAIL CONST/API: hằng số hoặc hàm không có trong tools/edopro_constants.txt, tools/edopro_apis.txt
    - FAIL DEPEND: dùng định danh của script/constants.lua mà không Duel.LoadScript("constants.lua")
    - WARN STRUCT (heuristic): SetTarget thiếu chk==0, operation dùng GetHandler() không có IsRelateToEffect
.PARAMETER Path
    Đường dẫn file .lua cụ thể để kiểm tra. Nếu không chỉ định, quét toàn bộ script/
.PARAMETER Quiet
    Chỉ hiển thị file bị lỗi, không hiển thị file OK
.EXAMPLE
    .\tools\validate_scripts.ps1
    .\tools\validate_scripts.ps1 -Path script\c12345678.lua
    .\tools\validate_scripts.ps1 -Quiet
#>

param(
    [string]$Path = "",
    [switch]$Quiet = $false
)

$OutputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ScriptDir = Resolve-Path "script"
$ExitCode = 0
$TotalOk = 0
$TotalWarn = 0
$TotalFail = 0

$ErrorActionPreference = "Continue"

function Remove-LuaNoise {
    param([string]$Content)
    # Bo comment va noi dung chuoi: ten hang so/API trong do khong phai loi goi that
    $clean = [regex]::Replace($Content, '(?s)--\[\[.*?\]\]', '')
    $clean = [regex]::Replace($clean, '--.*', '')
    $clean = [regex]::Replace($clean, '"(?:[^"\\]|\\.)*"', '""')
    $clean = [regex]::Replace($clean, "'(?:[^'\\]|\\.)*'", "''")
    return $clean
}

function Get-LuaFunctionBody {
    param([string]$Content, [string]$FuncName)
    # Lua khong co dau ngoac nhon de bam theo; phai dem tu khoa mo/dong block.
    # Mo: function / if / do   Dong: end   (repeat...until la cap rieng)
    $start = [regex]::Match($Content, "function\s+$([regex]::Escape($FuncName))\s*\(")
    if (-not $start.Success) { return $null }
    $tail = $Content.Substring($start.Index)
    $depth = 0
    foreach ($token in [regex]::Matches($tail, '\b(function|if|do|end|repeat|until)\b')) {
        switch ($token.Groups[1].Value) {
            'function' { $depth++ }
            'if'       { $depth++ }
            'do'       { $depth++ }
            'repeat'   { $depth++ }
            'until'    { $depth-- }
            'end'      { $depth-- }
        }
        if ($depth -eq 0) {
            return $tail.Substring(0, $token.Index + $token.Length)
        }
    }
    return $null
}

function Test-LuaSyntax {
    param([string]$FilePath)
    try {
        # Nhung duong dan vao chuoi long-bracket cua Lua: khong can escape, va
        # khong di qua stdin — stdin cua tien trinh con co the bi chen BOM tuy
        # console encoding, lam Lua nhan duong dan rac.
        # loadfile parses without executing EDOPro calls; syntax errors must exit 1.
        $cmd = "local f,e=loadfile([==[$FilePath]==]); if not f then io.stderr:write(e, string.char(10)); os.exit(1) end"
        $result = & lua -e $cmd 2>&1
        if ($LASTEXITCODE -eq 0) {
            return @{ Ok = $true; Message = "" }
        } else {
            $errMsg = if ($result -is [array]) { $result -join '; ' } else { "$result" }
            return @{ Ok = $false; Message = $errMsg }
        }
    } catch {
        return @{ Ok = $false; Message = $_.Exception.Message }
    }
}

function Test-ScriptStructure {
    param([string]$FilePath, [string]$Content)
    $warnings = @()
    $errors = @()

    if ($Content -notmatch 'function\s+s\.initial_effect') {
        $errors += "Missing: initial_effect function"
    }

    if ($Content -notmatch 'GetID\s*\(\s*\)') {
        $errors += "Missing: GetID() call"
    }

    if ($Content -notmatch 'RegisterEffect') {
        $errors += "Missing: RegisterEffect call"
    }

    # Check SetTarget has chk==0 pattern
    $targetFuncs = [regex]::Matches($Content, 'SetTarget\s*\(\s*s\.(\w+)')
    foreach ($match in $targetFuncs) {
        $funcNameClean = $match.Groups[1].Value
        $funcBody = Get-LuaFunctionBody -Content $Content -FuncName "s.$funcNameClean"
        if ($funcBody -and $funcBody -notmatch 'chk\s*==\s*0') {
            $warnings += "SetTarget $funcNameClean may be missing 'if chk==0' check"
        }
    }

    # Check operation functions have IsRelateToEffect
    $opFuncs = [regex]::Matches($Content, 'SetOperation\s*\(\s*s\.(\w+)')
    foreach ($match in $opFuncs) {
        $funcNameClean = $match.Groups[1].Value
        if ($funcNameClean -eq 'initial_effect') { continue }
        $funcBody = Get-LuaFunctionBody -Content $Content -FuncName "s.$funcNameClean"
        if ($funcBody -and $funcBody -match 'e:GetHandler\s*\(\s*\)' -and $funcBody -notmatch 'IsRelateToEffect') {
            $warnings += "Operation $funcNameClean uses GetHandler() but may be missing IsRelateToEffect check"
        }
    }

    # Check for Event+Phase without explicit PHASE constant
    if ($Content -match 'EVENT_PHASE\s*\+') {
        if ($Content -notmatch 'PHASE_DRAW|PHASE_STANDBY|PHASE_MAIN1|PHASE_MAIN2|PHASE_BATTLE|PHASE_END') {
            $warnings += "EVENT_PHASE used without specific PHASE constant"
        }
    }

    return @{ Errors = $errors; Warnings = $warnings }
}

function Test-LuaConstants {
    param([string]$Content)
    # Lua tra ve nil cho ten khong ton tai thay vi bao loi, nen hang so go sai
    # qua duoc buoc kiem tra cu phap roi moi crash trong duel -> bat o day.
    $clean = Remove-LuaNoise $Content

    # Hang so khai bao ngay trong file (local COUNTER_X = 0x1) la hop le
    $localDefs = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($m in [regex]::Matches($clean, '(?m)^\s*(?:local\s+)?([A-Z][A-Z0-9_]{2,})\s*=')) {
        [void]$localDefs.Add($m.Groups[1].Value)
    }

    $errors = @()
    # (?<![.:\w]) bo qua truy cap field: aux.TRUE, c:GetCode
    foreach ($m in [regex]::Matches($clean, '(?<![.:\w])([A-Z][A-Z0-9_]{3,})\b')) {
        $val = $m.Groups[1].Value
        if ($Global:ValidConstants.Contains($val) -or $localDefs.Contains($val)) { continue }
        $errors += "Constant '$val' khong ton tai trong EDOPro - runtime doc ra nil"
    }
    return $errors | Select-Object -Unique
}

function Test-LuaApis {
    param([string]$Content)
    # Ham bia ra ('Card.IsAbleToHandOrExtra') cung la nil -> 'attempt to call a nil value'
    $clean = Remove-LuaNoise $Content

    $localFns = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($m in [regex]::Matches($clean, 'function\s+\w+[.:]([A-Za-z_]\w*)')) {
        [void]$localFns.Add($m.Groups[1].Value)
    }
    # Bang cuc bo khai bao trong chinh file: local MyTable = {}
    $localTables = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($m in [regex]::Matches($clean, '(?m)^\s*(?:local\s+)?([A-Z][A-Za-z0-9_]*)\s*=')) {
        [void]$localTables.Add($m.Groups[1].Value)
    }

    $errors = @()
    # Ten thuong cung phai xet: 'aux' la namespace duoc dung nhieu nhat trong script card.
    foreach ($m in [regex]::Matches($clean, '(?<![.:\w])([A-Za-z_]\w*)\.([A-Za-z_]\w*)')) {
        $ns = $m.Groups[1].Value
        $fn = $m.Groups[2].Value
        if ($localTables.Contains($ns)) { continue }
        if (-not $Global:ValidNamespaces.Contains($ns)) {
            # Ten thuong khong ro la bang hay bien cuc bo (s, e, tc...) nen bo qua;
            # ten viet hoa dau moi du chac chan de bao bang khong ton tai.
            if ($ns -cmatch '^[A-Z]') {
                $errors += "Bang '$ns' khong ton tai trong EDOPro (goi '$ns.$fn')"
            }
            continue
        }
        if ($Global:ValidApis.Contains("$ns.$fn") -or $localFns.Contains($fn)) { continue }
        $errors += "'$ns.$fn' khong ton tai trong EDOPro - runtime 'attempt to call a nil value'"
    }

    # Method goi qua dau hai cham (c:GetAtk()) khong lo ra bang chu, nen doi chieu
    # ten ham voi moi API da biet. Loi goi co kiem tra truoc (if c.GetName then) duoc bo qua.
    $guarded = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($m in [regex]::Matches($clean, '\.([A-Za-z_]\w*)\s+(?:then|and)\b')) {
        [void]$guarded.Add($m.Groups[1].Value)
    }
    foreach ($m in [regex]::Matches($clean, ':([A-Za-z_]\w*)\s*\(')) {
        $fn = $m.Groups[1].Value
        if ($Global:ValidMethods.Contains($fn) -or $Global:LuaStringMethods.Contains($fn) -or
            $localFns.Contains($fn) -or $guarded.Contains($fn)) { continue }
        $errors += "Method ':$fn()' khong ton tai trong EDOPro - runtime 'attempt to call a nil value'"
    }
    return $errors | Select-Object -Unique
}

function Test-ConstantsDependency {
    param([string]$Content, [string]$FileName)
    $errors = @()
    if ($FileName -eq "constants.lua") { return $errors }

    $clean = Remove-LuaNoise $Content

    # EDOPro KHONG tu load script/constants.lua — script nao dung dinh danh
    # tu file do bat buoc phai co Duel.LoadScript("constants.lua") o dau file,
    # neu khong se crash runtime: attempt to call/index a nil value.
    $hasLoad = $Content -match 'Duel\.LoadScript\(\s*"constants\.lua"\s*\)'
    foreach ($ident in $Global:CustomIdentifiers) {
        if (-not $hasLoad -and $clean -match "\b$([regex]::Escape($ident))\b") {
            $errors += "Uses '$ident' (defined in script/constants.lua) without Duel.LoadScript(`"constants.lua`") - crashes at runtime with 'attempt to call a nil value'"
        }
    }
    return $errors
}

function Test-ScriptFile {
    param([string]$FilePath)
    $fileName = Split-Path $FilePath -Leaf
    $fileWarnings = @()
    $fileErrors = @()

    # Check filename convention
    if ($fileName -notmatch '^c\d+\.lua$') {
        $fileWarnings += "Filename does not match cXXXXXXXXX.lua convention"
    }

    # Check file encoding (must be UTF-8 or ASCII)
    $bytes = [System.IO.File]::ReadAllBytes((Resolve-Path $FilePath))
    if ($bytes.Length -ge 3) {
        if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            # UTF-8 BOM - ok
        } elseif ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
            $fileWarnings += "UTF-16 LE encoding detected, should be UTF-8"
        }
    }

    return @{ Warnings = $fileWarnings; Errors = $fileErrors }
}

# ============================================================
# MAIN
# ============================================================

function Read-ReferenceList {
    param([string]$FilePath)
    $set = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    if (Test-Path $FilePath) {
        foreach ($line in Get-Content $FilePath) {
            $trimmed = $line.Trim()
            if ($trimmed -and -not $trimmed.StartsWith('#')) { [void]$set.Add($trimmed) }
        }
    }
    # Dau phay bat buoc: 'return $set' se unroll HashSet ra pipeline va nguoi goi
    # nhan lai Object[] co dinh kich thuoc, khien cac lenh Add() sau do nem loi.
    return ,$set
}

# Hang so va API that cua EDOPro, sinh tu ban cai game bang
# tools/sync_edopro_refs.py. Thieu file thi hai kiem tra tuong ung bi tat.
$Global:ValidConstants = Read-ReferenceList (Join-Path $PSScriptRoot "edopro_constants.txt")
$Global:ValidApis = Read-ReferenceList (Join-Path $PSScriptRoot "edopro_apis.txt")
$Global:ValidNamespaces = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$Global:ValidMethods = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($api in $Global:ValidApis) {
    $parts = $api.Split('.', 2)
    [void]$Global:ValidNamespaces.Add($parts[0])
    if ($parts.Count -eq 2) { [void]$Global:ValidMethods.Add($parts[1]) }
}
# Method cua chuoi Lua ((""):format(...)) khong nam trong danh sach API cua EDOPro
$Global:LuaStringMethods = [System.Collections.Generic.HashSet[string]]::new(
    [string[]]@("byte", "char", "find", "format", "gmatch", "gsub", "len", "lower", "match", "rep", "reverse", "sub", "upper"),
    [System.StringComparer]::Ordinal)

# Add custom constants from constants.lua if exists
$RootPath = Split-Path $PSScriptRoot
$CustomPath = Join-Path $RootPath "script\constants.lua"
$Global:CustomIdentifiers = [System.Collections.Generic.List[string]]::new()
if (Test-Path $CustomPath) {
    $constContent = Get-Content $CustomPath -Raw
    $customMatches = [regex]::Matches($constContent, '\b[A-Z_][A-Z0-9_]+\b')
    foreach ($m in $customMatches) {
        [void]$Global:ValidConstants.Add($m.Value)
    }
    # Thu thap dinh danh ma constants.lua dinh nghia: hang so (SET_X = ...)
    # va helper function (function Card.X / Duel.X ...) — dung cho dependency check
    foreach ($m in [regex]::Matches($constContent, '(?m)^\s*([A-Z][A-Z0-9_]+)\s*=')) {
        [void]$Global:CustomIdentifiers.Add($m.Groups[1].Value)
    }
    foreach ($m in [regex]::Matches($constContent, 'function\s+\w+\.(\w+)\s*\(')) {
        [void]$Global:CustomIdentifiers.Add($m.Groups[1].Value)
    }
}

Write-Host ""
Write-Host "=== TTF Card Script Validator ===" -ForegroundColor Cyan
Write-Host ""

$luaAvailable = Get-Command lua -ErrorAction SilentlyContinue
if (-not $luaAvailable) {
    Write-Host "ERROR: Lua parser not found in PATH. Static validation cannot pass without syntax checking." -ForegroundColor Red
    Write-Host "Install Lua 5.3+ and rerun validation. Runtime behavior still requires EDOPro tests."
    exit 1
}

if ($Path -ne "") {
    if (-not (Test-Path $Path)) {
        Write-Host "ERROR: File not found: $Path" -ForegroundColor Red
        exit 1
    }
    $files = @(Get-Item $Path)
} else {
    $files = @(Get-ChildItem -Path $ScriptDir -Filter "*.lua" | Where-Object { $_.Name -ne "constants.lua" })
}

if ($files.Count -eq 0) {
    Write-Host "No .lua files found in script/" -ForegroundColor Yellow
    exit 0
}

Write-Host "Scanning: script/" -ForegroundColor Gray
Write-Host "Found $($files.Count) script(s)`n" -ForegroundColor Gray

foreach ($file in $files) {
    $fileName = $file.Name
    $filePath = $file.FullName
    $hasError = $false
    $hasWarning = $false
    $allMessages = @()

    # 1. Filename check
    $fileCheck = Test-ScriptFile -FilePath $filePath
    foreach ($e in $fileCheck.Errors) { $allMessages += "FILE: $e"; $hasError = $true }
    foreach ($w in $fileCheck.Warnings) { $allMessages += "FILE: $w"; $hasWarning = $true }

    # 2. Read content
    try {
        $content = Get-Content $filePath -Raw -ErrorAction Stop
    } catch {
        $allMessages += "FILE: Cannot read file"
        $hasError = $true
    }

    if (-not $hasError) {
        # 3. Syntax check
        $syntax = Test-LuaSyntax -FilePath $filePath
        if (-not $syntax.Ok) {
            $allMessages += "SYNTAX: $($syntax.Message)"
            $hasError = $true
        }

        # 4. Structure check
        $struct = Test-ScriptStructure -FilePath $filePath -Content $content
        foreach ($e in $struct.Errors) { $allMessages += "STRUCT: $e"; $hasError = $true }
        foreach ($w in $struct.Warnings) { $allMessages += "STRUCT: $w"; $hasWarning = $true }

        # 5. Constants check — ten khong ton tai la nil luc chay, khong phai canh bao
        if ($Global:ValidConstants.Count -gt 0) {
            $constErrors = Test-LuaConstants -Content $content
            foreach ($e in $constErrors) { $allMessages += "CONST: $e"; $hasError = $true }
        }

        # 5b. API check — ham/bang bia ra gay 'attempt to call a nil value'
        if ($Global:ValidApis.Count -gt 0) {
            $apiErrors = Test-LuaApis -Content $content
            foreach ($e in $apiErrors) { $allMessages += "API: $e"; $hasError = $true }
        }

        # 6. constants.lua dependency (FAIL — gay crash runtime)
        $depErrors = Test-ConstantsDependency -Content $content -FileName $fileName
        foreach ($e in $depErrors) { $allMessages += "DEPEND: $e"; $hasError = $true }
    }

    # -Quiet chi giau dong OK; file co canh bao van phai duoc dem dung
    if ($hasError) {
        Write-Host ("[*] FAIL $fileName") -ForegroundColor Red
        foreach ($msg in $allMessages) { Write-Host "     $msg" -ForegroundColor Red }
        $TotalFail++
    } elseif ($hasWarning) {
        if (-not $Quiet) {
            Write-Host ("[!] WARN $fileName") -ForegroundColor Yellow
            foreach ($msg in $allMessages) { Write-Host "     $msg" -ForegroundColor Yellow }
        }
        $TotalWarn++
    } else {
        if (-not $Quiet) { Write-Host ("[ ] OK   $fileName") -ForegroundColor Green }
        $TotalOk++
    }
}

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "Results: " -NoNewline
Write-Host "$TotalOk OK, " -NoNewline -ForegroundColor Green
Write-Host "$TotalWarn WARN, " -NoNewline -ForegroundColor Yellow
Write-Host "$TotalFail FAIL" -ForegroundColor Red
Write-Host "=======================================" -ForegroundColor Cyan

Write-Host "Static validation only; EDOPro runtime behavior is unverified." -ForegroundColor Gray
if ($TotalFail -gt 0) { exit 1 } else { exit 0 }
