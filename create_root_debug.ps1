# Create debug development environment for SDR++
Write-Host "Creating debug development environment..." -ForegroundColor Green

# Create root_dev directory if it doesn't exist
if (!(Test-Path "root_dev")) { New-Item -ItemType Directory -Path "root_dev" | Out-Null }
if (!(Test-Path "root_dev\modules")) { New-Item -ItemType Directory -Path "root_dev\modules" | Out-Null }
if (!(Test-Path "root_dev\res")) { New-Item -ItemType Directory -Path "root_dev\res" | Out-Null }

# Copy main executable and core DLLs from debug build
Write-Host "Copying main executable and core DLLs..." -ForegroundColor Yellow
if (Test-Path "build\Debug\sdrpp.exe") {
    Copy-Item "build\Debug\sdrpp.exe" "root_dev\" -Force
}
if (Test-Path "build\Debug\sdrpp_core.dll") {
    Copy-Item "build\Debug\sdrpp_core.dll" "root_dev\" -Force
}
if (Test-Path "build\Debug\*.dll") {
    Copy-Item "build\Debug\*.dll" "root_dev\" -Force
}

# Copy all debug modules
Write-Host "Copying debug modules..." -ForegroundColor Yellow

# Source modules
Get-ChildItem "build\source_modules" -Directory | ForEach-Object {
    $modulePath = $_.FullName + "\Debug\*.dll"
    if (Test-Path $modulePath) {
        Copy-Item $modulePath "root_dev\modules\" -Force
    }
}

# Sink modules
Get-ChildItem "build\sink_modules" -Directory | ForEach-Object {
    $modulePath = $_.FullName + "\Debug\*.dll"
    if (Test-Path $modulePath) {
        Copy-Item $modulePath "root_dev\modules\" -Force
    }
}

# Decoder modules
Get-ChildItem "build\decoder_modules" -Directory | ForEach-Object {
    $modulePath = $_.FullName + "\Debug\*.dll"
    if (Test-Path $modulePath) {
        Copy-Item $modulePath "root_dev\modules\" -Force
    }
}

# Misc modules
Get-ChildItem "build\misc_modules" -Directory | ForEach-Object {
    $modulePath = $_.FullName + "\Debug\*.dll"
    if (Test-Path $modulePath) {
        Copy-Item $modulePath "root_dev\modules\" -Force
    }
}

# Copy resources from root
Write-Host "Copying resources..." -ForegroundColor Yellow
if (Test-Path "root\res") {
    Copy-Item "root\res\*" "root_dev\res\" -Recurse -Force
}

# Copy any additional dependencies that might be needed
Write-Host "Copying additional dependencies..." -ForegroundColor Yellow
if (Test-Path "C:\Program Files\PothosSDR\bin\volk.dll") {
    Copy-Item "C:\Program Files\PothosSDR\bin\volk.dll" "root_dev\" -Force
}

# Copy RtAudio DLLs from vcpkg
if (Test-Path "C:\vcpkg\installed\x64-windows\bin\rtaudio.dll") {
    Copy-Item "C:\vcpkg\installed\x64-windows\bin\rtaudio.dll" "root_dev\" -Force
}
if (Test-Path "C:\vcpkg\installed\x64-windows\debug\bin\rtaudiod.dll") {
    Copy-Item "C:\vcpkg\installed\x64-windows\debug\bin\rtaudiod.dll" "root_dev\" -Force
}

# Create a .gitkeep file in modules directory
"" | Out-File "root_dev\modules\.gitkeep" -Encoding ASCII

Write-Host "Debug development environment created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "To run SDR++ debug version:" -ForegroundColor Cyan
Write-Host "  cd root_dev" -ForegroundColor White
Write-Host "  ..\build\Debug\sdrpp.exe -r . -c" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to continue..." 