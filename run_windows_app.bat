@echo off
cd /d "%~dp0"
if exist "build\windows\x64\runner\Release\gym_interval_timer.exe" (
    start "" "build\windows\x64\runner\Release\gym_interval_timer.exe"
) else (
    echo Building and launching Windows app...
    flutter run -d windows
)
