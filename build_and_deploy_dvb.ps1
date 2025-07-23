# DVB Module Build and Deploy Script
# Fast iteration for DVB-T debugging

param(
    [switch]$FullBuild,
    [switch]$SkipBuild
)

# Set paths
$SolutionPath = "c:\msys64\home\cpico\SDRPlusPlus"
$CMakePath = "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
$BuildPath = "$SolutionPath\build"
$ModuleName = "dvbs_demodulator"
$ModulePath = "$BuildPath\decoder_modules\$ModuleName\Release\$ModuleName.dll"
$RootDevPath = "$SolutionPath\root_dev"

Write-Host "=== DVB Module Fast Build and Deploy ===" -ForegroundColor Green
Write-Host "Solution: $SolutionPath" -ForegroundColor Yellow
Write-Host "Module: $ModuleName" -ForegroundColor Yellow

# Change to solution directory
Set-Location $SolutionPath
Write-Host "Changed to solution directory: $(Get-Location)" -ForegroundColor Cyan

if (-not $SkipBuild) {
    Write-Host "Building DVB module..." -ForegroundColor Yellow
    
    if ($FullBuild) {
        Write-Host "Performing full clean build..." -ForegroundColor Yellow
        & $CMakePath --build $BuildPath --config Release --clean-first --target $ModuleName
    } else {
        Write-Host "Performing incremental build..." -ForegroundColor Yellow
        & $CMakePath --build $BuildPath --config Release --target $ModuleName
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
    
    Write-Host "Build completed successfully!" -ForegroundColor Green
    
    # Check if module was built
    if (Test-Path $ModulePath) {
        $ModuleInfo = Get-Item $ModulePath
        Write-Host "Module built: $($ModuleInfo.Name) ($($ModuleInfo.Length) bytes, $($ModuleInfo.LastWriteTime))" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Module not found at $ModulePath" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Skipping build (using existing module)" -ForegroundColor Yellow
}

Write-Host "Deploying to root_dev..." -ForegroundColor Yellow

# Create root_dev if it doesn't exist
if (-not (Test-Path $RootDevPath)) {
    Write-Host "Creating root_dev directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $RootDevPath -Force | Out-Null
}

# Create modules directory if it doesn't exist
$ModulesPath = "$RootDevPath\modules"
if (-not (Test-Path $ModulesPath)) {
    Write-Host "Creating modules directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $ModulesPath -Force | Out-Null
}

# Fast deployment - copy only the DVB module
if (Test-Path $ModulePath) {
    try {
        Copy-Item $ModulePath $ModulesPath -Force
        Write-Host "DVB module deployed successfully!" -ForegroundColor Green
        
        # Verify deployment
        $DeployedModule = "$ModulesPath\$ModuleName.dll"
        if (Test-Path $DeployedModule) {
            $DeployedInfo = Get-Item $DeployedModule
            Write-Host "Deployed module: $($DeployedInfo.Name) ($($DeployedInfo.Length) bytes, $($DeployedInfo.LastWriteTime))" -ForegroundColor Green
        }
    } catch {
        Write-Host "ERROR: Failed to deploy module: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "ERROR: Module not found for deployment: $ModulePath" -ForegroundColor Red
    exit 1
}

# Optional: Copy base files if this is the first time or if requested
if ($FullBuild -or -not (Test-Path "$RootDevPath\sdrpp.exe")) {
    Write-Host "Copying base files..." -ForegroundColor Yellow
    
    # Copy root directory
    if (Test-Path "$SolutionPath\root") {
        try {
            Copy-Item "$SolutionPath\root\*" $RootDevPath -Recurse -Force
            Write-Host "Base files copied successfully!" -ForegroundColor Green
        } catch {
            Write-Host "WARNING: Failed to copy some base files: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    # Copy essential executables and DLLs
    $BuildRelease = "$BuildPath\Release"
    if (Test-Path $BuildRelease) {
        $EssentialFiles = @("sdrpp.exe", "sdrpp_core.dll", "fftw3f.dll", "glfw3.dll", "volk.dll", "zstd.dll")
        foreach ($File in $EssentialFiles) {
            $SourceFile = "$BuildRelease\$File"
            if (Test-Path $SourceFile) {
                try {
                    Copy-Item $SourceFile $RootDevPath -Force
                    Write-Host "Copied: $File" -ForegroundColor Green
                } catch {
                    Write-Host "WARNING: Failed to copy $File" -ForegroundColor Yellow
                }
            }
        }
    }
}

Write-Host "=== Deployment Complete ===" -ForegroundColor Green
Write-Host "Ready to test DVB-T with debug logging!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Usage examples:" -ForegroundColor Yellow
Write-Host "  .\build_and_deploy_dvb.ps1                    # Incremental build and deploy" -ForegroundColor Gray
Write-Host "  .\build_and_deploy_dvb.ps1 -FullBuild         # Clean build and deploy" -ForegroundColor Gray
Write-Host "  .\build_and_deploy_dvb.ps1 -SkipBuild         # Deploy only (no build)" -ForegroundColor Gray
Write-Host ""
Write-Host "To test: cd root_dev && .\sdrpp.exe" -ForegroundColor Cyan
