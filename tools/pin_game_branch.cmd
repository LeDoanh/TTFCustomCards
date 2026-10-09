@echo off
rem Bam doi file nay de mo menu chon nhanh test (khong can go lenh PowerShell).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0pin_game_branch.ps1" %*
echo.
pause
