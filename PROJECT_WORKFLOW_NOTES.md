# SDR++ Project Development Workflow

## Development Environment Setup

### Prerequisites
- Visual Studio 2022 Professional with C++ development tools
- CMake (via Visual Studio or standalone)
- vcpkg for dependency management
- PothosSDR for HackRF support

### Initial Project Setup
1. Clone repository to `c:\msys64\home\cpico\SDRPlusPlus`
2. Configure CMake build system
3. Install dependencies via vcpkg
4. Build complete project

## Development Automation Scripts

### Primary Development Tools
The following automation scripts provide rapid iteration for DVB module development:

#### `fast_deploy.bat` - Ultra-Fast Iteration (Primary Tool)
- **Purpose**: Rapid rebuild and deploy of DVB demodulator module only
- **Speed**: ~10-15 seconds
- **Usage**: `.\fast_deploy.bat`
- **When to use**: Quick code changes, debugging, testing fixes
- **Output**: Rebuilds and deploys `dvbs_demodulator.dll` to `root_dev\modules\`

#### `build_and_deploy_dvb.bat` - Complete Module Deployment
- **Purpose**: Full DVB module build with environment setup
- **Speed**: ~30-60 seconds
- **Usage**: 
  - `.\build_and_deploy_dvb.bat` (incremental build and deploy)
  - `.\build_and_deploy_dvb.bat skip` (deploy only, no build)
- **When to use**: First-time setup, major changes, environment refresh
- **Output**: Complete `root_dev` environment with all necessary files

#### `test_dvbt.bat` - Debug Test Launcher
- **Purpose**: Launch SDR++ with console debug output
- **Speed**: ~2-3 seconds
- **Usage**: `.\test_dvbt.bat`
- **When to use**: Testing DVB-T functionality, viewing crash debug output
- **Output**: SDR++ with visible console for debug messages

### Development Workflow

#### Standard Development Cycle
```batch
# 1. Edit source code in Visual Studio
# 2. Ultra-fast rebuild and deploy:
.\fast_deploy.bat
# 3. Test with debug output:
.\test_dvbt.bat
# 4. Repeat steps 1-3 for rapid iteration
```

#### First-Time Setup or Major Changes
```batch
# Complete environment setup:
.\build_and_deploy_dvb.bat
# Test:
.\test_dvbt.bat
```

### DVB-T Debugging Features

The automation scripts work with debug-enhanced DVB module that provides detailed console output:

```
[DVB-T] CRASH DEBUG: Entering setMode() with dvb_mode = 2
[DVB-T] CRASH DEBUG: Setting up DVB-T mode
[DVB-T] CRASH DEBUG: About to call dvbtDemod.setBandwidth()
[DVB-T] CRASH DEBUG: Entering setBandwidth() with 2 MHz
[DVB-T] CRASH DEBUG: About to call reset() from setBandwidth()
[DVB-T] CRASH DEBUG: Entering reset() function
```

This detailed logging helps pinpoint exact crash locations in DVB-T initialization.

## Best Practices

### Development Efficiency
1. **Always use `fast_deploy.bat` for quick iterations** - Optimized for rapid development
2. **Use `test_dvbt.bat` to see debug output** - Essential for debugging crashes
3. **Keep console open during testing** - Debug output is crucial for troubleshooting
4. **Check script output for status** - Scripts provide detailed feedback

### Code Changes and Testing
1. Make small, incremental changes
2. Test each change immediately with `fast_deploy.bat` + `test_dvbt.bat`
3. Use debug output to verify functionality
4. Build incrementally rather than making large changes

### Environment Management
- Use `build_and_deploy_dvb.bat` for clean environment setup
- Use `fast_deploy.bat` for day-to-day development
- Keep `root_dev` directory for testing separate from production builds

## Troubleshooting

### Build Issues
- Ensure Visual Studio 2022 is properly installed
- Check CMake accessibility
- Verify vcpkg dependencies are installed

### Deployment Issues
- Check disk space and write permissions
- Ensure source files exist in build directory
- Verify script output for specific error messages

### Runtime Issues
- Use `test_dvbt.bat` to see console output
- Check that all required DLLs are in `root_dev`
- Verify module exists in `root_dev\modules\`

## Documentation References

- `DEVELOPMENT_SCRIPTS_REFERENCE.md` - Detailed script documentation
- `PACKAGING.md` - Build and packaging workflows
- `readme.md` - General development setup
- DVB-T debugging output - Console messages during testing

## Script Maintenance

When updating or modifying the automation scripts:
1. Test with both incremental and clean builds
2. Verify error handling and status reporting
3. Update documentation if workflow changes
4. Ensure cross-compatibility with different development environments