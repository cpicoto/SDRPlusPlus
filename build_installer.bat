@echo off
echo Building SDR++ Installer...

REM Check if Inno Setup is installed
if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    set ISCC="C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
) else if exist "C:\Program Files\Inno Setup 6\ISCC.exe" (
    set ISCC="C:\Program Files\Inno Setup 6\ISCC.exe"
) else (
    echo Inno Setup 6 not found in standard locations.
    echo Please install Inno Setup 6 or update the path in this script.
    pause
    exit /b 1
)

REM Create installer output directory
if not exist "installer_output" mkdir installer_output

REM Build the installer
echo Compiling installer with Inno Setup...
%ISCC% sdrpp_installer.iss

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Installer built successfully!
    echo Output: installer_output\SDRPlusPlus-1.2.1-Setup.exe
    echo.
    echo Opening output directory...
    explorer installer_output
) else (
    echo.
    echo Error building installer. Check the log above for details.
    pause
)
