@echo OFF
setlocal

echo =======================================================
echo SDR++ Build and Package Script
echo This script creates a fresh root_dev and builds installer
echo =======================================================

REM Check if build directory exists
if not exist "build" (
    echo ERROR: Build directory not found. Please run CMake and build first.
    echo.
    echo To build SDR++:
    echo   cmake -S . -B build -G "Visual Studio 17 2022" -A x64
    echo   cmake --build build --config Release
    echo.
    pause
    exit /b 1
)

REM Check if main executable was built
if not exist "build\Release\sdrpp.exe" (
    echo ERROR: sdrpp.exe not found in build\Release\. Please build the project first.
    echo.
    echo To build SDR++:
    echo   cmake --build build --config Release
    echo.
    pause
    exit /b 1
)

echo.
echo Step 1: Cleaning previous root_dev directory...
if exist "root_dev" (
    rmdir /s /q "root_dev"
    if exist "root_dev" (
        echo ERROR: Could not remove existing root_dev directory.
        echo Please close any applications using files in root_dev and try again.
        pause
        exit /b 1
    )
)
echo Previous root_dev cleaned successfully.

echo.
echo Step 2: Creating fresh root_dev using create_root.bat...
call create_root.bat
if %ERRORLEVEL% neq 0 (
    echo ERROR: create_root.bat failed with error code %ERRORLEVEL%
    pause
    exit /b 1
)

REM Verify that root_dev was created properly
if not exist "root_dev\sdrpp.exe" (
    echo ERROR: root_dev was not created properly - sdrpp.exe missing
    pause
    exit /b 1
)

if not exist "root_dev\modules" (
    echo ERROR: root_dev was not created properly - modules directory missing
    pause
    exit /b 1
)

echo Root_dev created successfully!

echo.
echo Step 3: Verifying installer script exists...
if not exist "sdrpp_installer.iss" (
    echo ERROR: Inno Setup script sdrpp_installer.iss not found.
    pause
    exit /b 1
)

echo.
echo Step 4: Building installer with Inno Setup...

REM Try different common locations for Inno Setup
set "INNO_SETUP_PATH="
if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    set "INNO_SETUP_PATH=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
) else if exist "C:\Program Files\Inno Setup 6\ISCC.exe" (
    set "INNO_SETUP_PATH=C:\Program Files\Inno Setup 6\ISCC.exe"
) else if exist "C:\Program Files (x86)\Inno Setup 5\ISCC.exe" (
    set "INNO_SETUP_PATH=C:\Program Files (x86)\Inno Setup 5\ISCC.exe"
) else if exist "C:\Program Files\Inno Setup 5\ISCC.exe" (
    set "INNO_SETUP_PATH=C:\Program Files\Inno Setup 5\ISCC.exe"
)

if "%INNO_SETUP_PATH%"=="" (
    echo ERROR: Inno Setup not found. Please install Inno Setup and try again.
    echo Download from: https://jrsoftware.org/isdl.php
    pause
    exit /b 1
)

echo Found Inno Setup at: %INNO_SETUP_PATH%
echo.

REM Create installer output directory if it doesn't exist
if not exist "installer_output" (
    mkdir "installer_output"
)

REM Build the installer
"%INNO_SETUP_PATH%" "sdrpp_installer.iss"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Inno Setup failed with error code %ERRORLEVEL%
    pause
    exit /b 1
)

echo.
echo =======================================================
echo SUCCESS: SDR++ installer has been created!
echo =======================================================
echo.
echo Location: installer_output\SDRPlusPlus-1.2.2-Setup.exe
echo.
echo The installer includes:
echo   - SDR++ executable and core libraries
echo   - All modules (HackRF, audio, etc.)
echo   - HackRF dependencies from PothosSDR
echo   - Resources and configuration templates
echo   - Desktop shortcuts with proper config location
echo.
echo The installer will:
echo   - Install SDR++ to Program Files
echo   - Place config files in %%APPDATA%%\SDR++
echo   - Create shortcuts that use the correct config location
echo   - Check for Visual C++ Redistributable requirements
echo.

REM List the contents of installer_output for verification
echo Installer output directory contents:
dir "installer_output" /b

echo.
echo You can now distribute SDRPlusPlus-1.2.2-Setup.exe
echo =======================================================
pause
