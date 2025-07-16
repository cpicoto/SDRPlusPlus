echo OFF

REM Create root_dev directory
mkdir root_dev

REM Copy base files from root directory
Xcopy root root_dev /E /H /C /I /Y

REM Copy built executables and core DLLs from build/Debug
if exist build\Debug\sdrpp.exe (
    copy build\Debug\sdrpp.exe root_dev\ /Y
)
if exist build\Debug\sdrpp_core.dll (
    copy build\Debug\sdrpp_core.dll root_dev\ /Y
)

REM Copy dependency DLLs from build/Debug
if exist build\Debug\fftw3f.dll (
    copy build\Debug\fftw3f.dll root_dev\ /Y
)
if exist build\Debug\glfw3.dll (
    copy build\Debug\glfw3.dll root_dev\ /Y
)
if exist build\Debug\volk.dll (
    copy build\Debug\volk.dll root_dev\ /Y
)
if exist build\Debug\zstd.dll (
    copy build\Debug\zstd.dll root_dev\ /Y
)

REM Copy all source modules
if exist build\source_modules (
    for /d %%d in (build\source_modules\*) do (
        if exist "%%d\Debug\*.dll" (
            copy "%%d\Debug\*.dll" root_dev\modules\ /Y >nul 2>&1
        )
    )
)

REM Copy all sink modules  
if exist build\sink_modules (
    for /d %%d in (build\sink_modules\*) do (
        if exist "%%d\Debug\*.dll" (
            copy "%%d\Debug\*.dll" root_dev\modules\ /Y >nul 2>&1
        )
    )
)

REM Copy all decoder modules
if exist build\decoder_modules (
    for /d %%d in (build\decoder_modules\*) do (
        if exist "%%d\Debug\*.dll" (
            copy "%%d\Debug\*.dll" root_dev\modules\ /Y >nul 2>&1
        )
    )
)

REM Copy all misc modules
if exist build\misc_modules (
    for /d %%d in (build\misc_modules\*) do (
        if exist "%%d\Debug\*.dll" (
            copy "%%d\Debug\*.dll" root_dev\modules\ /Y >nul 2>&1
        )
    )
)

REM Don't copy dependency DLLs that aren't modules to modules directory
REM These should go in the main directory where needed

echo Root development environment created successfully with DEBUG builds!

REM List all copied modules
echo.
echo Copied modules:
dir root_dev\modules\*.dll /B

echo.
echo Debug executable info:
if exist root_dev\sdrpp.exe (
    dir root_dev\sdrpp.exe
) else (
    echo WARNING: sdrpp.exe not found!
)

echo.
echo Debug core library info:
if exist root_dev\sdrpp_core.dll (
    dir root_dev\sdrpp_core.dll
) else (
    echo WARNING: sdrpp_core.dll not found!
)
