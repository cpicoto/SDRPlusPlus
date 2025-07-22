# DVB-S/DVB-T Demodulator Build Guide

This document provides a streamlined process for building the DVB-S/DVB-T demodulator module for SDR++ on Windows.

## Overview

The DVB-S demodulator module (`dvbs_demodulator`) now includes DVB-T terrestrial support alongside the original DVB-S satellite capabilities. This module is located in `decoder_modules/dvbs_demodulator/` and includes your custom DVB-T integration.

## Prerequisites

Ensure you have the main SDR++ build environment set up as documented in `HOWTO_Build.md`:
- Visual Studio 2022 Professional
- vcpkg package manager
- PothosSDR drivers
- CMake 3.30.1+

## Quick Build Process

### Option 1: Build with Main Project (Recommended)

The DVB-S demodulator is automatically built as part of the main SDR++ build:

```powershell
# From project root
cd C:\msys64\home\cpico\SDRPlusPlus

# Clean and rebuild (if needed)
Remove-Item -Recurse -Force .\build -ErrorAction SilentlyContinue
mkdir build
cd build

# Configure with vcpkg
$cmake = "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
& $cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_TOOLCHAIN_FILE="C:/vcpkg/scripts/buildsystems/vcpkg.cmake" -DVCPKG_TARGET_TRIPLET=x64-windows

# Build the entire project (includes DVB demodulator)
& $cmake --build . --config Release
```

### Option 2: Build DVB Demodulator Only

To build just the DVB-S demodulator module after the main project is configured:

```powershell
cd C:\msys64\home\cpico\SDRPlusPlus\build
$cmake = "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
& $cmake --build . --config Release --target dvbs_demodulator
```

## Verification

After building, verify the module was created:

```powershell
# Check if DLL exists
Get-ChildItem C:\msys64\home\cpico\SDRPlusPlus\build\decoder_modules\dvbs_demodulator\Release\dvbs_demodulator.dll

# Check file size (should be ~350KB+)
(Get-Item C:\msys64\home\cpico\SDRPlusPlus\build\decoder_modules\dvbs_demodulator\Release\dvbs_demodulator.dll).Length
```

## Installation

Use the automated root creation script to copy all modules including the DVB demodulator:

```powershell
cd C:\msys64\home\cpico\SDRPlusPlus
.\create_root.bat
```

The script will automatically copy `dvbs_demodulator.dll` to `root_dev\modules\` and provide feedback if the module is missing.

## Troubleshooting

### Common Build Issues

1. **Include Path Errors**: If you see errors about missing DVB-T headers, ensure the include path in `main.cpp` points to `"demod/dvbt/module_dvbt_demod.h"` (not `"dvbt/module_dvbt_demod.h"`).

2. **Complex Type Errors**: The DVB-T code uses SDR++ `complex_t` types. Use these methods:
   - `complex.amplitude()` instead of `std::abs(complex)`
   - `complex.conj()` instead of `std::conj(complex)`
   - `complex.phase()` instead of `std::arg(complex)`
   - `FL_M_PI` instead of `M_PI`

3. **AGC Interface Errors**: Use the correct FastAGC initialization:
   ```cpp
   agc.init(nullptr, 1.0f, 65536, 10.0f, 0.5f);  // 5 parameters
   ```

4. **Module Not Loading**: Ensure the DLL is in the `modules/` directory and all dependencies are available.

### Dependency Issues

If you encounter missing dependency errors:

```powershell
# Check required DLLs are available
Get-ChildItem C:\msys64\home\cpico\SDRPlusPlus\root_dev\*.dll | Select-Object Name
```

Required dependencies for DVB demodulator:
- `fftw3f.dll` (FFT processing)
- `sdrpp_core.dll` (SDR++ core)
- Standard Windows DLLs

## Development Notes

### DVB-T Integration Architecture

- **DVB-S Code**: Located in `src/demod/dvbs/` and `src/demod/dvbs2/`
- **DVB-T Code**: Located in `src/demod/dvbt/` (your integration)
- **Main Interface**: `src/main.cpp` handles UI and module coordination
- **GUI Components**: `src/gui_widgets.h` provides constellation display

### Key Files Modified for DVB-T Integration

1. `src/main.cpp` - Updated include path for DVB-T module
2. `src/demod/dvbt/module_dvbt_demod.cpp` - Fixed complex type compatibility
3. `src/demod/dvbt/module_dvbt_demod.h` - DVB-T demodulator interface

### Performance Considerations

- The DVB-T demodulator uses FFTW for OFDM processing
- Constellation diagrams are updated in real-time
- Channel estimation and correction are performed per OFDM symbol

## Testing

After successful build and installation:

1. Launch SDR++ from `root_dev/`
2. Enable the DVB-S demodulator module in the module manager
3. Configure an appropriate SDR source (RTL-SDR, HackRF, etc.)
4. Tune to DVB-S or DVB-T frequencies
5. Verify constellation display and demodulation performance

## Build Time Estimates

- Full rebuild: ~5-10 minutes
- DVB demodulator only: ~30-60 seconds
- Incremental changes: ~10-30 seconds

## Support

For build issues specific to the DVB-T integration, check:
1. This document first
2. SDR++ core build guide (`HOWTO_Build.md`)
3. CMake configuration logs
4. Visual Studio build output

---

*Last updated: July 21, 2025*
*Verified with: Visual Studio 2022 Professional, CMake 3.31.6, vcpkg*
