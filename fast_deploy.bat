@echo off
REM Ultra-fast DVB module iteration - minimal rebuild and deploy
REM For quick code changes during debugging

setlocal enabledelayedexpansion

set "SolutionPath=c:\msys64\home\cpico\SDRPlusPlus"
set "CMakePath=C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
set "ModulePath=%SolutionPath%\build\decoder_modules\dvbs_demodulator\Release\dvbs_demodulator.dll"
set "DeployPath=%SolutionPath%\root_dev\modules\dvbs_demodulator.dll"

echo === Ultra-Fast DVB Module Iteration ===
cd /d "%SolutionPath%"

echo Building module only...
"%CMakePath%" --build build --config Release --target dvbs_demodulator --parallel

if !errorlevel! neq 0 (
    echo BUILD FAILED!
    pause
    exit /b !errorlevel!
)

echo Deploying...
copy /Y "%ModulePath%" "%SolutionPath%\root_dev\modules\" > nul

if !errorlevel! equ 0 (
    for %%F in ("%DeployPath%") do (
        echo SUCCESS: %%~nxF deployed ^(%%~zF bytes, %%~tF^)
    )
) else (
    echo DEPLOY FAILED!
    pause
    exit /b 1
)

echo.
echo Ready to test! Run: test_dvbt.bat
echo Or manually: cd root_dev ^&^& sdrpp.exe
