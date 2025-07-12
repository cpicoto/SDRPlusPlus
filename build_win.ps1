# SDR++ PowerShell Build Script

Write-Host "======================================================="
Write-Host "SDR++ Windows Build Script (PowerShell)"
Write-Host "======================================================="

# Find CMake installation
$cmakePaths = @(
    "C:\Program Files\CMake\bin\cmake.exe",
    "C:\Program Files (x86)\CMake\bin\cmake.exe",
    "${env:ProgramFiles}\CMake\bin\cmake.exe",
    "${env:ProgramFiles(x86)}\CMake\bin\cmake.exe"
)

$cmake = $null
foreach ($path in $cmakePaths) {
    if (Test-Path $path) {
        $cmake = $path
        Write-Host "Found CMake at: $cmake"
        break
    }
}

if (-not $cmake) {
    # Try to find cmake in PATH
    $cmake = Get-Command cmake -ErrorAction SilentlyContinue
    if ($cmake) {
        $cmake = $cmake.Source
        Write-Host "Found CMake in PATH: $cmake"
    } else {
        Write-Host "ERROR: CMake not found. Please install CMake or add it to PATH."
        exit 1
    }
}

# Set paths - these should be adjusted to match your system
# Using default locations - adjust these paths as needed
$VCPKG_ROOT = "C:\vcpkg"
$POTHOS_PATH = "C:\Program Files\PothosSDR"
$RTAUDIO_PATH = "C:\Program Files (x86)\RtAudio"

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
    "-DOPT_BUILD_AUDIO_SINK=ON"
)
& $cmake $cmakeConfigArgs

# Build with CMake
Write-Host "Building SDR++ (this may take a while)..."
& $cmake --build build --config Release

# Create development root directory
Write-Host "Creating root_dev directory..."
& .\create_root.bat

Write-Host "======================================================="
Write-Host "Build complete!"
Write-Host "To run SDR++, use: .\build\Release\sdrpp.exe -r root_dev -c"
Write-Host "======================================================="
