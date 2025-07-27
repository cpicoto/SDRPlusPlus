@echo off
REM Quick test script for GNU Radio DVB-T module
REM Launches SDR++ with optimal settings for DVB-T testing

setlocal

set "SolutionPath=c:\msys64\home\cpico\SDRPlusPlus"
set "SDRPPExe=%SolutionPath%\build\Release\sdrpp.exe"
set "RootPath=%SolutionPath%\root_dev"

echo === GNU Radio DVB-T Module Quick Test ===
echo.

cd /d "%SolutionPath%"

REM Check if the module exists
if not exist "%RootPath%\modules\gr_dvbt.dll" (
    echo ERROR: gr_dvbt.dll not found in modules directory!
    echo Run fast_deploy.bat first to build and deploy the module.
    pause
    exit /b 1
)

REM Check if SDR++ executable exists
if not exist "%SDRPPExe%" (
    echo ERROR: SDR++ executable not found!
    echo Expected: %SDRPPExe%
    echo Run the full build process first.
    pause
    exit /b 1
)

echo DVB-T module found: %RootPath%\modules\gr_dvbt.dll
for %%F in ("%RootPath%\modules\gr_dvbt.dll") do (
    echo   Size: %%~zF bytes
    echo   Modified: %%~tF
)
echo.

echo Launching SDR++ with DVB-T testing configuration...
echo.
echo DVB-T Testing Guide:
echo   1. Select your SDR source (RTL-SDR, HackRF, etc.)
echo   2. Tune to a DVB-T channel (typically 470-790 MHz)
echo   3. Enable the "GNU Radio DVB-T" decoder module
echo   4. Set bandwidth to 8 MHz for DVB-T channels
echo   5. Watch for TPS lock and signal parameters
echo.
echo Key DVB-T Parameters to monitor:
echo   - Lock Status: Should show "LOCKED" for good signals
echo   - SNR: Should be >15 dB for stable decoding
echo   - Constellation: QPSK/QAM16/QAM64 auto-detected
echo   - Code Rate: 1/2, 2/3, 3/4, 5/6, 7/8
echo   - Guard Interval: 1/32, 1/16, 1/8, 1/4
echo   - TX Mode: 2K or 8K
echo.

cd "%RootPath%"
start "" "%SDRPPExe%" -r . -c

echo SDR++ launched with DVB-T module ready!
echo.
echo For debugging output, use:
echo   %SDRPPExe% -r %RootPath% -c -v
echo.
echo Press any key to exit this script...
pause > nul
