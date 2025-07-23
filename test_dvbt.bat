@echo off
REM Quick test script for DVB-T debugging
REM Changes to root_dev and launches SDR++ with console output

echo === Quick DVB-T Test ===
cd /d "c:\msys64\home\cpico\SDRPlusPlus\root_dev"

if not exist "sdrpp.exe" (
    echo ERROR: sdrpp.exe not found in root_dev
    echo Run build_and_deploy_dvb.bat first to setup the environment
    pause
    exit /b 1
)

if not exist "modules\dvbs_demodulator.dll" (
    echo ERROR: DVB demodulator module not found
    echo Run build_and_deploy_dvb.bat first to deploy the module
    pause
    exit /b 1
)

echo Launching SDR++ with DVB-T debug logging...
echo Look for [DVB-T] CRASH DEBUG messages in the console
echo Press Ctrl+C to stop SDR++
echo.

REM Launch SDR++ and keep console open
sdrpp.exe -c
