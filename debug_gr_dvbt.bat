@echo off
REM Debug helper for GNU Radio DVB-T module development
REM Provides detailed diagnostics and troubleshooting

setlocal enabledelayedexpansion

set "SolutionPath=c:\msys64\home\cpico\SDRPlusPlus"

echo ================================================================
echo            GNU Radio DVB-T Module Debug Helper
echo ================================================================
echo.

cd /d "%SolutionPath%"

echo === Environment Check ===
echo Solution Path: %SolutionPath%
echo Current Directory: %CD%
echo.

echo === Source Code Status ===
if exist "decoder_modules\gr_dvbt" (
    echo ✓ gr_dvbt module directory exists
    if exist "decoder_modules\gr_dvbt\src\main.cpp" echo ✓ main.cpp found
    if exist "decoder_modules\gr_dvbt\src\dvbt_decoder.h" echo ✓ dvbt_decoder.h found
    if exist "decoder_modules\gr_dvbt\src\dvbt_decoder.cpp" echo ✓ dvbt_decoder.cpp found
    if exist "decoder_modules\gr_dvbt\CMakeLists.txt" echo ✓ CMakeLists.txt found
) else (
    echo ✗ gr_dvbt module directory NOT found!
)
echo.

echo === Build System Status ===
if exist "build" (
    echo ✓ Build directory exists
    if exist "build\sdrpp.sln" (
        echo ✓ Visual Studio solution generated
    ) else (
        echo ✗ Visual Studio solution NOT found - run cmake first
    )
    
    if exist "build\decoder_modules\gr_dvbt" (
        echo ✓ gr_dvbt build directory exists
        if exist "build\decoder_modules\gr_dvbt\gr_dvbt.vcxproj" (
            echo ✓ gr_dvbt project file found
        ) else (
            echo ✗ gr_dvbt project file missing
        )
    ) else (
        echo ✗ gr_dvbt build directory NOT found
    )
) else (
    echo ✗ Build directory NOT found - run cmake first
)
echo.

echo === Dependency Check ===
echo Checking FFTW3 availability:
if exist "C:\vcpkg\installed\x64-windows\lib\fftw3f.lib" (
    echo ✓ FFTW3 library found via vcpkg
    if exist "C:\vcpkg\installed\x64-windows\include\fftw3.h" (
        echo ✓ FFTW3 headers found via vcpkg
    )
) else if exist "C:\Program Files\PothosSDR\lib\fftw3f.lib" (
    echo ✓ FFTW3 library found via PothosSDR
    if exist "C:\Program Files\PothosSDR\include\fftw3.h" (
        echo ✓ FFTW3 headers found via PothosSDR
    )
) else (
    echo ✗ FFTW3 library NOT found!
    echo   Solution: Install via vcpkg or PothosSDR
)

echo Checking CMake:
set "CMakePath=C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
if exist "%CMakePath%" (
    echo ✓ CMake found: %CMakePath%
) else (
    echo ✗ CMake NOT found at expected location
)

echo Checking vcpkg toolchain:
if exist "C:\vcpkg\scripts\buildsystems\vcpkg.cmake" (
    echo ✓ vcpkg toolchain found
) else (
    echo ✗ vcpkg toolchain NOT found
)
echo.

echo === CMake Configuration Status ===
if exist "build\CMakeCache.txt" (
    echo ✓ CMake cache exists
    echo Checking gr_dvbt configuration...
    findstr /C:"OPT_BUILD_GR_DVBT" build\CMakeCache.txt 2>nul
    if !errorlevel! equ 0 (
        echo ✓ gr_dvbt build option found in CMake cache
    ) else (
        echo ✗ gr_dvbt build option NOT found in cache
    )
) else (
    echo ✗ CMake cache NOT found - configuration needed
)
echo.

echo === Build Output Status ===
if exist "build\decoder_modules\gr_dvbt\Release\gr_dvbt.dll" (
    for %%F in (build\decoder_modules\gr_dvbt\Release\gr_dvbt.dll) do (
        echo ✓ gr_dvbt.dll built successfully
        echo   Size: %%~zF bytes
        echo   Date: %%~tF
    )
) else (
    echo ✗ gr_dvbt.dll NOT found - build needed
    if exist "build\decoder_modules\gr_dvbt\Release" (
        echo   Release directory exists but no DLL
        dir /b build\decoder_modules\gr_dvbt\Release\
    ) else (
        echo   Release directory doesn't exist
    )
)
echo.

echo === Deployment Status ===
if exist "root_dev\modules\gr_dvbt.dll" (
    for %%F in (root_dev\modules\gr_dvbt.dll) do (
        echo ✓ gr_dvbt.dll deployed
        echo   Size: %%~zF bytes
        echo   Date: %%~tF
    )
) else (
    echo ✗ gr_dvbt.dll NOT deployed
    if exist "root_dev\modules" (
        echo   Modules directory exists
        echo   Contents:
        dir /b root_dev\modules\ 2>nul
    ) else (
        echo ✗ Modules directory doesn't exist
    )
)
echo.

echo === Git Status ===
git status --porcelain 2>nul | findstr "gr_dvbt" && echo ✓ gr_dvbt changes detected in git
echo.

echo === Troubleshooting Recommendations ===
echo.
if not exist "decoder_modules\gr_dvbt" (
    echo 1. MISSING SOURCE: Create gr_dvbt module first
)
if not exist "build\sdrpp.sln" (
    echo 2. MISSING CMAKE: Run cmake configuration
    echo    Command: cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake -G "Visual Studio 17 2022" -A x64
)
if not exist "C:\vcpkg\installed\x64-windows\lib\fftw3f.lib" if not exist "C:\Program Files\PothosSDR\lib\fftw3f.lib" (
    echo 3. MISSING FFTW3: Install FFTW3 dependency
    echo    Via vcpkg: vcpkg install fftw3:x64-windows
    echo    Via PothosSDR: Download and install PothosSDR
)
if not exist "build\decoder_modules\gr_dvbt\Release\gr_dvbt.dll" (
    echo 4. BUILD NEEDED: Compile the module
    echo    Command: cmake --build build --config Release --target gr_dvbt
)
if not exist "root_dev\modules\gr_dvbt.dll" (
    echo 5. DEPLOY NEEDED: Copy DLL to modules
    echo    Command: copy build\decoder_modules\gr_dvbt\Release\gr_dvbt.dll root_dev\modules\
)
echo.
echo For automated fixes, use: dev_gr_dvbt.bat
pause
