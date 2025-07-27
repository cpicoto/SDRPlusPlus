# GNU Radio DVB-T Module - Fast Development Workflow

This document describes the fast iteration development workflow for the `gr_dvbt` module using the provided batch scripts.

## Development Scripts Overview

### 🚀 Primary Development Scripts

1. **`fast_deploy.bat`** - Ultra-fast build and deploy for quick iterations
2. **`dev_gr_dvbt.bat`** - Complete development cycle manager with menu
3. **`test_gr_dvbt.bat`** - Quick test launcher for the module
4. **`debug_gr_dvbt.bat`** - Comprehensive diagnostics and troubleshooting

## Quick Start Workflow

### For Quick Code Changes (Recommended)
```batch
# 1. Make your code changes in decoder_modules/gr_dvbt/src/
# 2. Run fast deployment
fast_deploy.bat

# 3. Test immediately
test_gr_dvbt.bat
```

### For New Development Sessions
```batch
# Use the interactive development manager
dev_gr_dvbt.bat
```

## Script Details

### 1. fast_deploy.bat
**Purpose**: Ultra-fast iteration for code changes
- Builds only the gr_dvbt module (not the entire solution)
- Deploys the DLL to `root_dev/modules/`
- Provides detailed success/error feedback
- Optimized for minimal rebuild time

**When to use**: During active coding when making frequent changes

**Output**:
```
=== Ultra-Fast GNU Radio DVB-T Module Iteration ===
Building gr_dvbt module only...
*** SUCCESS! *** gr_dvbt.dll deployed
  File: gr_dvbt.dll
  Size: 234,567 bytes
  Time: 7/27/2025 10:30 AM
Ready for DVB-T signal testing!
```

### 2. dev_gr_dvbt.bat
**Purpose**: Interactive development environment
- Menu-driven development workflow
- Handles clean builds, quick builds, testing, and status checks
- Comprehensive error handling and guidance
- Full development cycle automation

**Menu Options**:
1. Quick build and deploy (fast iteration)
2. Clean build from scratch
3. Build only (no deploy)
4. Deploy only (if already built)
5. Test with SDR++
6. Full cycle (clean + build + deploy + test)
7. Check module status
8. Exit

**When to use**: Start of development session or when you need comprehensive control

### 3. test_gr_dvbt.bat
**Purpose**: Launch SDR++ with DVB-T module for testing
- Validates module deployment
- Provides DVB-T testing guidance
- Launches SDR++ with optimal settings
- Includes parameter reference guide

**Features**:
- Pre-flight checks for module and executable
- DVB-T frequency guidance (470-790 MHz)
- Parameter monitoring instructions
- Debug launch options

### 4. debug_gr_dvbt.bat
**Purpose**: Comprehensive diagnostics and troubleshooting
- Environment validation
- Dependency checking (FFTW3, CMake, vcpkg)
- Build system status
- Deployment verification
- Troubleshooting recommendations

**Use cases**:
- When builds fail unexpectedly
- Setting up new development environment
- Verifying all dependencies are correct
- Understanding why module won't load

## Development Workflow Examples

### Daily Development Cycle
```batch
# Morning setup (first time each day)
dev_gr_dvbt.bat
# Choose option 7: Check module status

# Make code changes in your editor
# Quick iteration (repeat as needed)
fast_deploy.bat
test_gr_dvbt.bat

# When things break
debug_gr_dvbt.bat
```

### First-Time Setup
```batch
# 1. Verify environment
debug_gr_dvbt.bat

# 2. Initial clean build
dev_gr_dvbt.bat
# Choose option 2: Clean build from scratch

# 3. Test the module
test_gr_dvbt.bat
```

### Troubleshooting Failed Builds
```batch
# 1. Run diagnostics
debug_gr_dvbt.bat

# 2. If dependencies missing, install them:
#    vcpkg install fftw3:x64-windows
#    Install PothosSDR

# 3. Clean rebuild
dev_gr_dvbt.bat
# Choose option 2: Clean build from scratch
```

## File Locations

### Source Files
- `decoder_modules/gr_dvbt/src/main.cpp` - Module entry point and GUI
- `decoder_modules/gr_dvbt/src/dvbt_decoder.h` - Core decoder definitions
- `decoder_modules/gr_dvbt/src/dvbt_decoder.cpp` - GNU Radio implementation
- `decoder_modules/gr_dvbt/CMakeLists.txt` - Build configuration

### Build Output
- `build/decoder_modules/gr_dvbt/Release/gr_dvbt.dll` - Compiled module
- `build/decoder_modules/gr_dvbt/gr_dvbt.vcxproj` - Visual Studio project

### Deployment
- `root_dev/modules/gr_dvbt.dll` - Deployed module for testing
- `root_dev/` - SDR++ runtime environment

## Dependencies

### Required for Building
- **Visual Studio 2022** with C++ workload
- **CMake** (bundled with VS or standalone)
- **FFTW3** library:
  - Via vcpkg: `vcpkg install fftw3:x64-windows`
  - Via PothosSDR: Install to `C:\Program Files\PothosSDR`

### Runtime Dependencies
- **FFTW3 DLL**: `fftw3f.dll` must be accessible
- **SDR++ Core**: `sdrpp_core.dll` and supporting libraries
- **SDR Hardware**: RTL-SDR, HackRF, LimeSDR, etc.

## Performance Tips

### For Fastest Iteration
1. Use `fast_deploy.bat` for code changes
2. Keep Visual Studio closed during batch builds
3. Use incremental builds (avoid clean builds unless necessary)
4. Test with simple DVB-T signals first

### For Debugging
1. Add logging to your code changes
2. Use `test_gr_dvbt.bat` with verbose output: `-v` flag
3. Monitor SDR++ console output for module messages
4. Use Visual Studio debugger for complex issues

## Common Issues and Solutions

### Build Fails: FFTW3 Not Found
```batch
# Solution 1: Install via vcpkg
vcpkg install fftw3:x64-windows

# Solution 2: Verify PothosSDR installation
# Check: C:\Program Files\PothosSDR\lib\fftw3f.lib
```

### Module Won't Load in SDR++
```batch
# Check deployment
debug_gr_dvbt.bat

# Verify DLL exists and is recent
dir root_dev\modules\gr_dvbt.dll

# Check for missing dependencies
# Use Dependency Walker or similar tool
```

### CMake Configuration Issues
```batch
# Clean and regenerate
dev_gr_dvbt.bat
# Choose option 2: Clean build from scratch
```

## Integration with IDEs

### Visual Studio 2022
- Open `build/sdrpp.sln`
- Set `gr_dvbt` as startup project for module-only debugging
- Use batch scripts for quick deployment
- Debug with: `sdrpp.exe -r root_dev -c`

### VS Code
- Use batch scripts for building
- Configure tasks.json to call `fast_deploy.bat`
- Use integrated terminal for script execution

## Best Practices

### Code Changes
1. Make small, incremental changes
2. Test frequently with `fast_deploy.bat`
3. Use version control for checkpoints
4. Document significant algorithm changes

### Testing
1. Start with synthetic signals
2. Use known good DVB-T transmissions
3. Monitor TPS parameters for correctness
4. Validate against GNU Radio gr-dtv when possible

### Performance
1. Profile with real signals
2. Monitor CPU usage during OFDM processing
3. Optimize FFTW3 usage for real-time performance
4. Test with different transmission modes (2K/8K)

---

*Fast Development Workflow for GNU Radio DVB-T Module*  
*Updated: July 27, 2025*
