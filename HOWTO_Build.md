# How to Build SDRPlusPlus with Visual Studio 2022

This document provides step-by-step instructions for building SDRPlusPlus on Windows using Visual Studio 2022 and vcpkg package manager.

## Prerequisites

### Required Software

1. **Visual Studio 2022** (Community, Professional, or Enterprise)
   - Download from: https://visualstudio.microsoft.com/vs/
   - Make sure to install the "Desktop development with C++" workload
   - Includes CMake and MSVC compiler

2. **Git** (for cloning repositories)
   - Download from: https://git-scm.com/downloads

## Step 1: Install vcpkg Package Manager

1. Open PowerShell as Administrator
2. Clone vcpkg to `C:\vcpkg`:
   ```powershell
   cd C:\
   git clone https://github.com/Microsoft/vcpkg.git
   ```

3. Bootstrap vcpkg:
   ```powershell
   cd C:\vcpkg
   .\bootstrap-vcpkg.bat
   ```

## Step 2: Install Dependencies via vcpkg

Install the required libraries for x64 Windows:

```powershell
cd C:\vcpkg
.\vcpkg.exe install fftw3:x64-windows glfw3:x64-windows zstd:x64-windows rtaudio:x64-windows
```

This will install:
- **fftw3** - Fast Fourier Transform library
- **glfw3** - OpenGL framework for windowing
- **zstd** - Compression library  
- **rtaudio** - Real-time audio I/O library

## Step 3: Install PothosSDR

PothosSDR provides drivers and libraries for most SDR hardware.

1. Visit the downloads page: http://downloads.myriadrf.org/builds/PothosSDR/?C=M;O=D
2. Download the latest Windows installer (e.g., `PothosSDR-2021.07.25-win64.exe`)
3. Run the installer and install to the default location: `C:\Program Files\PothosSDR`

**Important**: PothosSDR must be installed to `C:\Program Files\PothosSDR` as this is what SDRPlusPlus expects.

## Step 4: Clone SDRPlusPlus

```powershell
cd C:\
git clone https://github.com/AlexandreRouma/SDRPlusPlus.git
cd SDRPlusPlus
```

## Step 5: Generate Visual Studio Solution

1. Create and enter build directory:
   ```powershell
   mkdir build -Force
   cd build
   ```

2. Generate Visual Studio 2022 solution using CMake:
   ```powershell
   C:\vcpkg\downloads\tools\cmake-3.30.1-windows\cmake-3.30.1-windows-i386\bin\cmake.exe .. "-DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake" -G "Visual Studio 17 2022" -A x64
   ```

   **Note**: The exact CMake path may vary depending on your vcpkg installation. You can also use Visual Studio's bundled CMake:
   ```powershell
   & "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe" .. "-DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake" -G "Visual Studio 17 2022" -A x64
   ```

## Step 6: Build the Project

Build in Release mode for optimal performance:

```powershell
C:\vcpkg\downloads\tools\cmake-3.30.1-windows\cmake-3.30.1-windows-i386\bin\cmake.exe --build . --config Release
```

## Step 7: Create Runtime Environment

1. Return to the main directory and create the development root:
   ```powershell
   cd ..
   .\create_root.bat
   ```

2. This creates a `root_dev` directory with all necessary resources (themes, bandplans, icons, etc.)

## Step 8: Run SDRPlusPlus

Launch the application:

```powershell
.\build\Release\sdrpp.exe -r root_dev -c
```

Where:
- `-r root_dev` specifies the root directory for configuration and resources
- `-c` starts with center frequency mode

## Build Output

After a successful build, you'll find these files in `build\Release\`:

- **`sdrpp.exe`** - Main SDRPlusPlus executable
- **`sdrpp_core.dll`** - Core SDR++ library
- **Supporting DLLs**: `fftw3f.dll`, `glfw3.dll`, `zstd.dll`, `volk.dll`

## Alternative: Using Visual Studio IDE

You can also open the generated solution in Visual Studio:

1. Open `build\sdrpp.sln` in Visual Studio 2022
2. Set build configuration to **Release** and platform to **x64**
3. Build → Build Solution (Ctrl+Shift+B)

## Troubleshooting

### CMake Generator Error
If you get a generator mismatch error, clean the build directory:
```powershell
cd build
Remove-Item * -Recurse -Force
```
Then regenerate the solution.

### Missing Dependencies
If CMake can't find dependencies, verify:
- vcpkg packages are installed correctly: `C:\vcpkg\vcpkg.exe list`
- PothosSDR is installed to `C:\Program Files\PothosSDR`
- Use the correct vcpkg toolchain file path in the CMake command

### Build Warnings
Some warnings during compilation (especially in libcorrect) are normal and don't affect functionality.

## Supported SDR Hardware

With PothosSDR installed, SDRPlusPlus supports:
- RTL-SDR dongles
- HackRF
- LimeSDR
- PlutoSDR
- AirSpy
- SDRplay
- And many others

## Development

For development work:
- Open `build\sdrpp.sln` in Visual Studio 2022
- The solution contains all projects including modules
- Set startup project to `sdrpp` for debugging
- Use the `-r root_dev -c` command line arguments in project settings

## Package Versions Used

This build was tested with:
- Visual Studio 2022 Professional (v17.14)
- vcpkg (2025-07-16 release)
- CMake 3.30.1
- MSVC 19.44.35213.0

## Specialized Module Builds

For building specific decoder modules with custom integrations:

- **DVB-S/DVB-T Demodulator**: See `HOWTO_Build_DVB_Demodulator.md` for streamlined build process and troubleshooting guide

---

*Last updated: July 21, 2025*
