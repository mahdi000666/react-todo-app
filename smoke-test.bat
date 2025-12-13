@echo off
setlocal enabledelayedexpansion

set URL=http://localhost:8080
set MAX_RETRIES=10
set RETRY=0

echo Testing %URL% ...

:RETRY_LOOP
if !RETRY! GEQ %MAX_RETRIES% goto FAILED

curl -sf %URL% >nul 2>&1
if !ERRORLEVEL! EQU 0 goto PASSED

set /A RETRY+=1
ping 127.0.0.1 -n 2 >nul
goto RETRY_LOOP

:PASSED
echo SMOKE PASSED
echo SMOKE PASSED > smoke.log
exit /b 0

:FAILED
echo SMOKE FAILED
echo SMOKE FAILED > smoke.log
exit /b 1