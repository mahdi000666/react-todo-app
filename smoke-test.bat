@echo off
setlocal enabledelayedexpansion

:: Check if port argument is provided
IF "%1"=="" (
    ECHO Error: Port number not provided.
    EXIT /b 1
)

set PORT=%1
set URL=http://localhost:%PORT%
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
echo SMOKE PASSED on port %PORT%
echo SMOKE PASSED > smoke.log
exit /b 0

:FAILED
echo SMOKE FAILED on port %PORT%
echo SMOKE FAILED > smoke.log
exit /b 1