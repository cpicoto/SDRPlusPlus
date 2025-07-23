@echo off
REM DVB Module Fast Build and Deploy Script
REM Fast iteration for DVB-T debugging

setlocal enabledelayedexpansion

set "SolutionPath=c:\msys64\home\cpico\SDRPlusPlus"
set "CMakePath=C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
set "BuildPath=%SolutionPath%\build"
set "ModuleName=dvbs_demodulator"
set "ModulePath=%BuildPath%\decoder_modules\%ModuleName%\Release\%ModuleName%.dll"
set "RootDevPath=%SolutionPath%\root_dev"

echo === DVB Module Fast Build and Deploy ===
echo Solution: %SolutionPath%
echo Module: %ModuleName%

REM Change to solution directory
cd /d "%SolutionPath%"
echo Changed to solution directory: %CD%

REM Check for skip build parameter
if "%1"=="skip" goto :deploy

echo Building DVB module...
echo Performing incremental build...
"%CMakePath%" --build "%BuildPath%" --config Release --target %ModuleName%

if !errorlevel! neq 0 (
    echo Build failed with exit code !errorlevel!
    exit /b !errorlevel!
)

echo Build completed successfully!

REM Check if module was built
if exist "%ModulePath%" (
    for %%F in ("%ModulePath%") do (
        echo Module built: %%~nxF ^(%%~zF bytes, %%~tF^)
    )
) else (
    echo ERROR: Module not found at %ModulePath%
    exit /b 1
)

:deploy
echo Deploying to root_dev...

REM Create root_dev if it doesn't exist
if not exist "%RootDevPath%" (
    echo Creating root_dev directory...
    mkdir "%RootDevPath%"
)

REM Create modules directory if it doesn't exist
set "ModulesPath=%RootDevPath%\modules"
if not exist "%ModulesPath%" (
    echo Creating modules directory...
    mkdir "%ModulesPath%"
)

REM Fast deployment - copy only the DVB module
if exist "%ModulePath%" (
    copy /Y "%ModulePath%" "%ModulesPath%\" > nul
    if !errorlevel! equ 0 (
        echo DVB module deployed successfully!
        
        REM Verify deployment
        set "DeployedModule=%ModulesPath%\%ModuleName%.dll"
        if exist "!DeployedModule!" (
            for %%F in ("!DeployedModule!") do (
                echo Deployed module: %%~nxF ^(%%~zF bytes, %%~tF^)
            )
        )
    ) else (
        echo ERROR: Failed to deploy module
        exit /b 1
    )
) else (
    echo ERROR: Module not found for deployment: %ModulePath%
    exit /b 1
)

REM Copy base files if this is the first time
if not exist "%RootDevPath%\sdrpp.exe" (
    echo Copying base files...
    
    REM Copy root directory
    if exist "%SolutionPath%\root" (
        Xcopy "%SolutionPath%\root" "%RootDevPath%" /E /H /C /I /Y > nul 2>&1
        echo Base files copied successfully!
    )
    
    REM Copy essential executables and DLLs
    set "BuildRelease=%BuildPath%\Release"
    if exist "!BuildRelease!" (
        for %%F in (sdrpp.exe sdrpp_core.dll fftw3f.dll glfw3.dll volk.dll zstd.dll) do (
            if exist "!BuildRelease!\%%F" (
                copy /Y "!BuildRelease!\%%F" "%RootDevPath%\" > nul 2>&1
                echo Copied: %%F
            )
        )
    )
)

echo === Deployment Complete ===
echo Ready to test DVB-T with debug logging!
echo.
echo Usage examples:
echo   build_and_deploy_dvb.bat          # Incremental build and deploy
echo   build_and_deploy_dvb.bat skip     # Deploy only ^(no build^)
echo.
echo To test: cd root_dev ^&^& sdrpp.exe
