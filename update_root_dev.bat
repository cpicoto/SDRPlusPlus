@echo OFF
setlocal

echo ===============================================
echo SDR++ Root Development Environment Updater
echo This script refreshes root_dev with latest build
echo ===============================================

REM Check if build directory exists
if not exist "build" (
    echo ERROR: Build directory not found. Please run CMake and build first.
    pause
    exit /b 1
)

REM Check if main executable was built
if not exist "build\Release\sdrpp.exe" (
    echo ERROR: sdrpp.exe not found in build\Release\. Please build the project first.
    pause
    exit /b 1
)

echo.
echo Cleaning previous root_dev directory...
if exist "root_dev" (
    rmdir /s /q "root_dev"
    if exist "root_dev" (
        echo ERROR: Could not remove existing root_dev directory.
        echo Please close any applications using files in root_dev and try again.
        pause
        exit /b 1
    )
)

echo.
echo Creating fresh root_dev using create_root.bat...
call create_root.bat
if %ERRORLEVEL% neq 0 (
    echo ERROR: create_root.bat failed with error code %ERRORLEVEL%
    pause
    exit /b 1
)

echo.
echo ===============================================
echo SUCCESS: root_dev has been updated!
echo ===============================================
echo.
echo You can now run SDR++ from root_dev:
echo   cd root_dev
echo   sdrpp.exe
echo.
echo Or test with HackRF:
echo   cd root_dev  
echo   sdrpp.exe -t "Custom Title"
echo.
pause
