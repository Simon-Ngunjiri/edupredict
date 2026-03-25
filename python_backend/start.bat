@echo off
REM ─────────────────────────────────────────────────────────────────────────
REM start.bat  —  Launch EduPredict API on Windows
REM
REM Gunicorn does NOT run on Windows natively.
REM This script uses Waitress as a drop-in WSGI replacement.
REM
REM Install:  pip install waitress
REM Run:      start.bat
REM ─────────────────────────────────────────────────────────────────────────

cd /d "%~dp0"

IF NOT EXIST "logistic_model.joblib" (
    echo.
    echo   [!] logistic_model.joblib not found.
    echo       Run first:  python train_model.py
    echo.
    pause
    exit /b 1
)

WHERE waitress-serve >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo   [!] Waitress not found.
    echo       Run first:  pip install waitress
    echo.
    pause
    exit /b 1
)

echo.
echo   EduPredict API - Waitress (Windows)
echo   Listening on http://0.0.0.0:5000
echo.

waitress-serve --host=0.0.0.0 --port=5000 --threads=4 app:app
