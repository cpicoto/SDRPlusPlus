# ========================================================
# SDR++ Native Windows PowerShell Build Script (No MSYS2)
# ========================================================

# Change to the correct directory
Set-Location "c:\Users\cpico\source\repos\SDRPlusPlus"

# Function to find CMake
function Find-CMake {
    $cmakePaths = @(
        "C:\Program Files\CMake\bin\cmake.exe",
        "C:\Program Files (x86)\CMake\bin\cmake.exe",
        "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe",
        "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe",
        "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
    )
    
    foreach ($path in $cmakePaths) {
        if (Test-Path $path) {
            return $path
        }
    }
    
    # Try to find cmake in PATH
    try {
        $cmake = Get-Command cmake -ErrorAction Stop
        return $cmake.Source
    } catch {
        Write-Host "ERROR: CMake not found. Please install CMake or add it to PATH."
        exit 1
    }
}

# Set paths - these should be adjusted to match your system
$VCPKG_ROOT = "C:\vcpkg"
$POTHOS_PATH = "C:\Program Files\PothosSDR"
$RTAUDIO_PATH = "C:\Program Files (x86)\RtAudio"

# Find CMake
$cmake = Find-CMake
Write-Host "Using CMake: $cmake"

# Create build directory if it doesn't exist
if (!(Test-Path -Path "build")) {
    New-Item -ItemType Directory -Path "build" | Out-Null
}

# Configure with CMake
Write-Host "Configuring with CMake..."
$cmakeConfigArgs = @(
    "-S", ".", 
    "-B", "build", 
    "-G", "Visual Studio 17 2022", 
    "-A", "x64",
    "-DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT\scripts\buildsystems\vcpkg.cmake",
    "-DCMAKE_PREFIX_PATH=$POTHOS_PATH;$RTAUDIO_PATH",
    "-DOPT_BUILD_AIRSPY_SOURCE=ON",
    "-DOPT_BUILD_AIRSPYHF_SOURCE=ON",
    "-DOPT_BUILD_AUDIO_SOURCE=ON",
    "-DOPT_BUILD_FILE_SOURCE=ON",
    "-DOPT_BUILD_HACKRF_SOURCE=ON",
    "-DOPT_BUILD_RTL_SDR_SOURCE=ON",
    "-DOPT_BUILD_AUDIO_SINK=ON",
    "-DOPT_BUILD_DVBS_DEMODULATOR=ON"
)

& $cmake $cmakeConfigArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "CMake configuration failed!"
    Read-Host "Press Enter to continue..."
    exit 1
}

# Build with CMake
Write-Host "Building SDR++ (this may take a while)..."
& $cmake --build build --config Release

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!"
    Read-Host "Press Enter to continue..."
    exit 1
}

# Create development root directory
Write-Host "Creating root_dev directory..."
& .\create_root.bat

Write-Host "======================================================="
Write-Host "Build complete!"
Write-Host "To run SDR++, use: .\build\Release\sdrpp.exe -r root_dev -c"
Write-Host "======================================================="
Read-Host "Press Enter to continue..."
