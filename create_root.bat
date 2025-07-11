echo OFF

REM Create root_dev directory
mkdir root_dev

REM Copy base files from root directory
Xcopy root root_dev /E /H /C /I

REM Copy built executables and core DLLs from build/Release
if exist build\Release\sdrpp.exe (
    copy build\Release\sdrpp.exe root_dev\
)
if exist build\Release\sdrpp_core.dll (
    copy build\Release\sdrpp_core.dll root_dev\
)

REM Copy dependency DLLs from build/Release
if exist build\Release\fftw3f.dll (
    copy build\Release\fftw3f.dll root_dev\
)
if exist build\Release\glfw3.dll (
    copy build\Release\glfw3.dll root_dev\
)
if exist build\Release\volk.dll (
    copy build\Release\volk.dll root_dev\
)
if exist build\Release\zstd.dll (
    copy build\Release\zstd.dll root_dev\
)

REM Copy all source modules
if exist build\source_modules (
    for /d %%d in (build\source_modules\*) do (
        if exist "%%d\Release\*.dll" (
            copy "%%d\Release\*.dll" root_dev\modules\ >nul 2>&1
        )
    )
)

REM Copy all sink modules  
if exist build\sink_modules (
    for /d %%d in (build\sink_modules\*) do (
        if exist "%%d\Release\*.dll" (
            copy "%%d\Release\*.dll" root_dev\modules\ >nul 2>&1
        )
    )
)

REM Copy all decoder modules
if exist build\decoder_modules (
    for /d %%d in (build\decoder_modules\*) do (
        if exist "%%d\Release\*.dll" (
            copy "%%d\Release\*.dll" root_dev\modules\ >nul 2>&1
        )
    )
)

REM Copy all misc modules
if exist build\misc_modules (
    for /d %%d in (build\misc_modules\*) do (
        if exist "%%d\Release\*.dll" (
            copy "%%d\Release\*.dll" root_dev\modules\ >nul 2>&1
        )
    )
)

REM Copy HackRF dependencies from PothosSDR
if exist "C:\Program Files\PothosSDR\bin\hackrf.dll" (
    copy "C:\Program Files\PothosSDR\bin\hackrf.dll" root_dev\
)
if exist "C:\Program Files\PothosSDR\bin\libusb-1.0.dll" (
    copy "C:\Program Files\PothosSDR\bin\libusb-1.0.dll" root_dev\
)
if exist "C:\Program Files\PothosSDR\bin\pthreadVC2.dll" (
    copy "C:\Program Files\PothosSDR\bin\pthreadVC2.dll" root_dev\
)

REM Copy rtaudio.dll from audio_sink to root_dev
if exist build\sink_modules\audio_sink\Release\rtaudio.dll (
    copy build\sink_modules\audio_sink\Release\rtaudio.dll root_dev\
)

echo Root development environment created successfully!