# SDR++ Build and Package Workflow

This document describes the complete, repeatable workflow for building and packaging SDR++ for Windows with HackRF support.

## Prerequisites

1. **Visual Studio 2022** with C++ development tools
2. **CMake** (version 3.16 or higher)
3. **vcpkg** for dependency management
4. **PothosSDR** for HackRF and other SDR hardware support
5. **Inno Setup 6** for creating Windows installers

## Required Dependencies

Install these packages using vcpkg:
```bash
vcpkg install fftw3:x64-windows
vcpkg install glfw3:x64-windows
vcpkg install zstd:x64-windows
vcpkg install rtaudio:x64-windows
```

## Build Process

### 1. Configure CMake
```bash
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
```

### 2. Build the Project
```bash
cmake --build build --config Release
```

### 3. Create Development Root (Optional)
To test the build locally:
```bash
.\update_root_dev.bat
```

This creates a `root_dev` directory with all binaries and dependencies for local testing.

## Packaging Workflow

### Complete Build and Package
For a complete, repeatable build and packaging process:

```bash
.\build_and_package.bat
```

This script will:
1. Clean any existing `root_dev` directory
2. Run `create_root.bat` to create a fresh deployment
3. Build the Windows installer using Inno Setup
4. Place the installer in `installer_output\SDRPlusPlus-1.2.2-Setup.exe`

### Manual Steps (Alternative)

If you prefer to run the steps manually:

1. **Create fresh root_dev:**
   ```bash
   .\create_root.bat
   ```

2. **Build installer:**
   ```bash
   "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" sdrpp_installer.iss
   ```

## What Gets Packaged

The installer includes:

### Core Application
- `sdrpp.exe` - Main SDR++ executable
- `sdrpp_core.dll` - Core SDR++ library

### Dependencies
- `fftw3f.dll` - FFT library
- `glfw3.dll` - OpenGL windowing
- `volk.dll` - Vector optimized library
- `zstd.dll` - Compression library
- `rtaudio.dll` - Audio library

### HackRF Support
- `hackrf.dll` - HackRF driver
- `libusb-1.0.dll` - USB library
- `pthreadVC2.dll` - Threading library

### Modules
All built modules are included:
- **Source modules:** HackRF, RTL-SDR, Audio, File, Network, etc.
- **Sink modules:** Audio output, Network output
- **Decoder modules:** Meteor, Pager, etc.
- **Misc modules:** Frequency manager, Recorder, Scanner, etc.

### Resources
- Band plans for various countries
- Color maps and themes
- Icons and fonts
- Configuration templates

## Installation Behavior

The installer:
- Installs SDR++ to `C:\Program Files\SDR++`
- Places config files in `%APPDATA%\SDR++`
- Creates desktop shortcuts with proper config location (`-r` parameter)
- Checks for Visual C++ Redistributable requirements
- Supports upgrade installations

## Version Management

Current version: **1.2.2**

To update the version:
1. Edit `#define MyAppVersion "1.2.2"` in `sdrpp_installer.iss`
2. Optionally update version in other project files

## Command Line Options

SDR++ supports the following custom options:
- `-t "Custom Title"` or `--title "Custom Title"` - Append custom text to window title
- `-r "config_path"` - Specify custom config directory (used by installer)
- `-h` - Help (existing option)

## File Structure

```
SDRPlusPlus/
├── build_and_package.bat      # Complete build and package script
├── update_root_dev.bat         # Update root_dev only
├── create_root.bat             # Create deployment root (called by scripts)
├── sdrpp_installer.iss         # Inno Setup installer script
├── build/                      # CMake build output
├── root_dev/                   # Deployment staging area
├── installer_output/           # Generated installers
└── root/                       # Base resources and templates
```

## Testing

After packaging:
1. Install the generated `.exe` file
2. Verify SDR++ launches from Start Menu or Desktop
3. Check that config files are in `%APPDATA%\SDR++`
4. Test HackRF detection (if hardware available)
5. Test audio functionality
6. Verify custom title option: `sdrpp.exe -t "Test Build"`

## Troubleshooting

### Missing Dependencies
If modules fail to load, ensure all required DLLs are in the main directory or check that PothosSDR is installed.

### Build Errors
- Verify CMake minimum version (3.16+)
- Check that all vcpkg packages are installed
- Ensure Visual Studio 2022 C++ tools are installed

### Installer Issues
- Verify Inno Setup 6 is installed
- Check that `root_dev` contains all required files
- Ensure file paths in `sdrpp_installer.iss` are correct

## Development Notes

- The `-t`/`--title` option was added to append custom text to the window title
- Debug output was reduced for cleaner runtime experience
- Build artifacts are excluded via `.gitignore`
- The workflow uses `create_root.bat` as the single source of truth for deployment

## Repository

This is a fork of SDR++ with Windows packaging improvements:
- Fork: https://github.com/cpicoto/SDRPlusPlus.git
- Original: https://github.com/AlexandreRouma/SDRPlusPlus
