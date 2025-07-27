@echo off
REM Complete GNU Radio DVB-T development cycle script
REM Handles: clean, build, deploy, test cycle for rapid iteration

setlocal enabledelayedexpansion

set "SolutionPath=c:\msys64\home\cpico\SDRPlusPlus"
set "CMakePath=C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
set "VcpkgToolchain=C:/vcpkg/scripts/buildsystems/vcpkg.cmake"

echo ================================================================
echo         GNU Radio DVB-T Module Development Cycle
echo ================================================================
echo.

cd /d "%SolutionPath%"

:menu
echo Choose development action:
echo   1. Quick build and deploy (fast iteration)
echo   2. Clean build from scratch
echo   3. Build only (no deploy)
echo   4. Deploy only (if already built)
echo   5. Test with SDR++
echo   6. Full cycle (clean + build + deploy + test)
echo   7. Check module status
echo   8. Exit
echo.
set /p choice="Enter choice (1-8): "

if "%choice%"=="1" goto quick_build
if "%choice%"=="2" goto clean_build
if "%choice%"=="3" goto build_only
if "%choice%"=="4" goto deploy_only
if "%choice%"=="5" goto test_module
if "%choice%"=="6" goto full_cycle
if "%choice%"=="7" goto check_status
if "%choice%"=="8" goto exit
goto menu

:quick_build
echo.
echo === Quick Build and Deploy ===
call :build_module
if !errorlevel! equ 0 call :deploy_module
goto menu

:clean_build
echo.
echo === Clean Build ===
echo Cleaning build directory...
if exist build\decoder_modules\gr_dvbt rmdir /s /q build\decoder_modules\gr_dvbt
echo Regenerating build files...
"%CMakePath%" -B build -S . "-DCMAKE_TOOLCHAIN_FILE=%VcpkgToolchain%" -G "Visual Studio 17 2022" -A x64
call :build_module
if !errorlevel! equ 0 call :deploy_module
goto menu

:build_only
echo.
echo === Build Only ===
call :build_module
goto menu

:deploy_only
echo.
echo === Deploy Only ===
call :deploy_module
goto menu

:test_module
echo.
echo === Testing Module ===
call test_gr_dvbt.bat
goto menu

:full_cycle
echo.
echo === Full Development Cycle ===
call :clean_build
if !errorlevel! equ 0 call test_gr_dvbt.bat
goto menu

:check_status
echo.
echo === Module Status ===
echo.
echo Source files:
if exist "decoder_modules\gr_dvbt\src\*.cpp" (
    for %%F in (decoder_modules\gr_dvbt\src\*.cpp) do (
        echo   %%F - %%~zF bytes, %%~tF
    )
) else (
    echo   ERROR: Source files not found!
)
echo.
echo Build output:
if exist "build\decoder_modules\gr_dvbt\Release\gr_dvbt.dll" (
    for %%F in (build\decoder_modules\gr_dvbt\Release\gr_dvbt.dll) do (
        echo   %%F - %%~zF bytes, %%~tF
    )
) else (
    echo   Module not built yet
)
echo.
echo Deployed module:
if exist "root_dev\modules\gr_dvbt.dll" (
    for %%F in (root_dev\modules\gr_dvbt.dll) do (
        echo   %%F - %%~zF bytes, %%~tF
    )
) else (
    echo   Module not deployed yet
)
echo.
echo FFTW3 dependency status:
if exist "C:\vcpkg\installed\x64-windows\bin\fftw3f.dll" (
    echo   FFTW3 found via vcpkg
) else if exist "C:\Program Files\PothosSDR\bin\fftw3f.dll" (
    echo   FFTW3 found via PothosSDR
) else (
    echo   WARNING: FFTW3 may not be available
)
goto menu

:build_module
echo Building gr_dvbt module...
"%CMakePath%" --build build --config Release --target gr_dvbt --parallel
if !errorlevel! neq 0 (
    echo.
    echo *** BUILD FAILED! ***
    echo.
    echo Common issues and solutions:
    echo   1. FFTW3 not found:
    echo      - Install via vcpkg: vcpkg install fftw3:x64-windows
    echo      - Or ensure PothosSDR is installed
    echo   2. Compilation errors:
    echo      - Check syntax in dvbt_decoder.cpp/h
    echo      - Verify include paths
    echo   3. CMake configuration:
    echo      - Try clean build option
    echo.
    pause
    exit /b 1
)
echo Build successful!
exit /b 0

:deploy_module
if not exist "build\decoder_modules\gr_dvbt\Release\gr_dvbt.dll" (
    echo ERROR: gr_dvbt.dll not found! Build first.
    exit /b 1
)

echo Deploying module...
if not exist "root_dev\modules" mkdir "root_dev\modules"
copy /Y "build\decoder_modules\gr_dvbt\Release\gr_dvbt.dll" "root_dev\modules\" > nul

if !errorlevel! equ 0 (
    for %%F in (root_dev\modules\gr_dvbt.dll) do (
        echo *** DEPLOYED! *** gr_dvbt.dll (%%~zF bytes)
    )
) else (
    echo *** DEPLOY FAILED! ***
    exit /b 1
)
exit /b 0

:exit
echo.
echo Development session complete!
echo.
echo Quick reference for manual commands:
echo   Build: "%CMakePath%" --build build --config Release --target gr_dvbt
echo   Deploy: copy build\decoder_modules\gr_dvbt\Release\gr_dvbt.dll root_dev\modules\
echo   Test: cd root_dev ^&^& ..\build\Release\sdrpp.exe -r . -c
echo.
pause
