@echo off
REM Ultra-fast GNU Radio DVB-T module iteration - minimal rebuild and deploy
REM For quick code changes during debugging and development

setlocal enabledelayedexpansion

set "SolutionPath=c:\msys64\home\cpico\SDRPlusPlus"
set "CMakePath=C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
set "ModulePath=%SolutionPath%\build\decoder_modules\gr_dvbt\Release\gr_dvbt.dll"
set "DeployPath=%SolutionPath%\root_dev\modules\gr_dvbt.dll"

echo === Ultra-Fast GNU Radio DVB-T Module Iteration ===
echo Module: gr_dvbt (GNU Radio-style DVB-T Decoder)
cd /d "%SolutionPath%"

echo.
echo Building gr_dvbt module only...
"%CMakePath%" --build build --config Release --target gr_dvbt --parallel

if !errorlevel! neq 0 (
    echo.
    echo *** BUILD FAILED! ***
    echo Check the compilation errors above.
    echo Common issues:
    echo - FFTW3 library not found
    echo - Missing include paths
    echo - Syntax errors in DVB-T decoder code
    pause
    exit /b !errorlevel!
)

echo.
echo Deploying gr_dvbt.dll to modules directory...
if not exist "%SolutionPath%\root_dev\modules" (
    echo Creating modules directory...
    mkdir "%SolutionPath%\root_dev\modules"
)

copy /Y "%ModulePath%" "%SolutionPath%\root_dev\modules\" > nul

REM Ensure gr_dvbt config exists
if not exist "%SolutionPath%\root_dev\gr_dvbt_config.json" (
    echo Creating default gr_dvbt configuration...
    echo {"enabled": true, "constellation": 0, "codeRate": 1, "guardInterval": 1, "transmissionMode": 0} > "%SolutionPath%\root_dev\gr_dvbt_config.json"
)

if !errorlevel! equ 0 (
    for %%F in ("%DeployPath%") do (
        echo *** SUCCESS! *** gr_dvbt.dll deployed
        echo   File: %%~nxF
        echo   Size: %%~zF bytes
        echo   Time: %%~tF
    )
    echo.
    echo GNU Radio DVB-T module ready for testing!
    echo.
    echo Quick test commands:
    echo   1. Manual test: cd root_dev ^&^& ..\build\Release\sdrpp.exe -r . -c
    echo   2. With logging: cd root_dev ^&^& ..\build\Release\sdrpp.exe -r . -c -v
    echo.
    echo Module features:
    echo   - Professional TPS decoding with GNU Radio algorithms
    echo   - QPSK/QAM16/QAM64 constellation support
    echo   - Real-time OFDM processing with FFTW3
    echo   - Comprehensive status monitoring
    echo.
) else (
    echo *** DEPLOY FAILED! ***
    echo Could not copy module to deployment directory.
    echo Check file permissions and paths.
    pause
    exit /b 1
)

echo Ready for DVB-T signal testing!
