@echo off
REM ========================================================
REM SDR++ Native Windows Build Script (No MSYS2)
REM ========================================================

cd /d "c:\Users\cpico\source\repos\SDRPlusPlus"

REM Set paths - these should be adjusted to match your system
set VCPKG_ROOT=C:\vcpkg
set POTHOS_PATH=C:\Program Files\PothosSDR
set RTAUDIO_PATH=C:\Program Files (x86)\RtAudio

REM Create build directory if it doesn't exist
if not exist "build" mkdir build

REM Configure with CMake
echo Configuring with CMake...
cmake -S . -B build -G "Visual Studio 17 2022" -A x64 ^
    "-DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake" ^
    "-DCMAKE_PREFIX_PATH=%POTHOS_PATH%;%RTAUDIO_PATH%" ^
    -DOPT_BUILD_AIRSPY_SOURCE=ON ^
    -DOPT_BUILD_AIRSPYHF_SOURCE=ON ^
    -DOPT_BUILD_AUDIO_SOURCE=ON ^
    -DOPT_BUILD_FILE_SOURCE=ON ^
    -DOPT_BUILD_HACKRF_SOURCE=ON ^
    -DOPT_BUILD_RTL_SDR_SOURCE=ON ^
    -DOPT_BUILD_AUDIO_SINK=ON ^
    -DOPT_BUILD_DVBS_DEMODULATOR=ON

if %ERRORLEVEL% neq 0 (
    echo CMake configuration failed!
    pause
    exit /b 1
)

REM Build with CMake
echo Building SDR++ (this may take a while)...
cmake --build build --config Release

if %ERRORLEVEL% neq 0 (
    echo Build failed!
    pause
    exit /b 1
)

REM Create development root directory
echo Creating root_dev directory...
call create_root.bat

echo ========================================================
echo Build complete! 
echo To run SDR++, use: .\build\Release\sdrpp.exe -r root_dev -c
echo ========================================================
pause
