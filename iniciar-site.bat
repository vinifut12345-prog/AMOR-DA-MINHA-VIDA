@echo off
cd /d "%~dp0"
start "Servidor do site" /min powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0servir-site.ps1"
timeout /t 2 /nobreak >nul
start "" "http://127.0.0.1:8000/index.html"
echo Deixe a janela minimizada do servidor aberta enquanto estiver usando o site.
pause