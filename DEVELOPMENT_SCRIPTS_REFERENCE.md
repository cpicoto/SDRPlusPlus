# SDR++ Development Automation Reference

## Quick Reference for Development Scripts

This guide provides a quick reference for the automation scripts created for efficient SDR++ development, particularly for DVB demodulator debugging and testing.

## Development Scripts Overview

| Script | Purpose | Speed | Use Case |
|--------|---------|-------|----------|
| `fast_deploy.bat` | Ultra-fast module rebuild/deploy | ~10-15 sec | Quick code iterations |
| `build_and_deploy_dvb.bat` | Full DVB module build/deploy | ~30-60 sec | Complete module deployment |
| `test_dvbt.bat` | Launch SDR++ with debug output | ~2-3 sec | Testing and debugging |
| `create_root.bat` | Legacy full deployment | ~2-3 min | Complete environment setup |

## Primary Development Workflow

### For DVB Module Development:
```batch
# 1. Edit code in Visual Studio
# 2. Ultra-fast rebuild and deploy:
.\fast_deploy.bat

# 3. Test with debug output:
.\test_dvbt.bat

# 4. Repeat steps 1-3 for rapid iteration
```

### For Complete Module Development:
```batch
# Full build and deploy (first time or major changes):
.\build_and_deploy_dvb.bat

# Skip build, deploy only:
.\build_and_deploy_dvb.bat skip
```

## Script Details

### `fast_deploy.bat` - Ultra-Fast Iteration
**Primary development script for quick code changes**
- **Target**: DVB demodulator module only
- **Build time**: ~10-15 seconds
- **Use when**: Making small code changes, debugging, testing fixes
- **Output**: Builds and deploys `dvbs_demodulator.dll` to `root_dev\modules\`

**Features:**
- Parallel building for speed
- Automatic directory handling
- Success/failure status reporting
- File size and timestamp verification

### `build_and_deploy_dvb.bat` - Complete Module Deployment
**Comprehensive build and deployment**
- **Target**: DVB module + base environment setup
- **Build time**: ~30-60 seconds  
- **Use when**: First-time setup, major changes, full environment refresh
- **Parameters**: 
  - No params: Incremental build and deploy
  - `skip`: Deploy only, no build

**Features:**
- Creates `root_dev` directory if needed
- Copies base SDR++ files (sdrpp.exe, dlls)
- Copies root directory resources
- Comprehensive error handling

### `test_dvbt.bat` - Debug Test Launcher
**Quick testing with debug output**
- **Target**: Launch SDR++ for DVB-T testing
- **Launch time**: ~2-3 seconds
- **Use when**: Testing DVB-T functionality, viewing debug output
- **Prerequisites**: `root_dev` environment must exist

**Features:**
- Validates environment before launching
- Changes to correct directory automatically
- Keeps console open for debug output
- Provides clear error messages if setup incomplete

## Debug Output Features

When using these scripts with the debug-enhanced DVB module, you'll see detailed console output for crash debugging:

### DVB-T Mode Selection Debug Output:
```
[DVB-T] CRASH DEBUG: Entering setMode() with dvb_mode = 2
[DVB-T] CRASH DEBUG: Setting up DVB-T mode
[DVB-T] CRASH DEBUG: About to call dvbtDemod.setInput()
[DVB-T] CRASH DEBUG: About to call dvbtDemod.setBandwidth()
[DVB-T] CRASH DEBUG: Entering setBandwidth() with 2 MHz
[DVB-T] CRASH DEBUG: About to call reset() from setBandwidth()
[DVB-T] CRASH DEBUG: Entering reset() function
[DVB-T] CRASH DEBUG: Acquired control mutex
[DVB-T] CRASH DEBUG: About to clear fft_buffer (size: X)
```

This detailed logging helps pinpoint exact crash locations in the DVB-T initialization sequence.

## Common Development Scenarios

### Scenario 1: Quick Bug Fix
```batch
# 1. Edit source code
# 2. Fast deploy (10-15 seconds):
.\fast_deploy.bat
# 3. Test immediately:
.\test_dvbt.bat
```

### Scenario 2: New Feature Development  
```batch
# 1. Complete deployment:
.\build_and_deploy_dvb.bat
# 2. Test:
.\test_dvbt.bat
# 3. Iterate with fast deploy:
.\fast_deploy.bat
.\test_dvbt.bat
```

### Scenario 3: Clean Environment Setup
```batch
# 1. Full environment setup:
.\build_and_deploy_dvb.bat
# 2. Verify with test:
.\test_dvbt.bat
```

### Scenario 4: Deploy Without Building
```batch
# If you need to deploy an existing build:
.\build_and_deploy_dvb.bat skip
```

## Best Practices

1. **Always use `fast_deploy.bat` for quick iterations** - It's optimized for rapid development cycles
2. **Use `test_dvbt.bat` to see debug output** - Essential for debugging crashes and issues
3. **Run full deployment initially** - Use `build_and_deploy_dvb.bat` for first-time setup
4. **Keep console open during testing** - Debug output is crucial for troubleshooting
5. **Check script output** - Scripts provide detailed status and error information

## Troubleshooting

### Build Failures:
- Check Visual Studio 2022 is installed with C++ tools
- Ensure CMake is accessible
- Verify solution directory is correct

### Deployment Failures:
- Ensure sufficient disk space
- Check write permissions to `root_dev` directory
- Verify source files exist in `build` directory

### Test Launch Failures:
- Run `build_and_deploy_dvb.bat` first to setup environment
- Check that `sdrpp.exe` exists in `root_dev`
- Verify DVB module exists in `root_dev\modules\`

## Script Locations
All scripts are located in: `c:\msys64\home\cpico\SDRPlusPlus\`
- Ensure you're in the solution root directory before running
- Scripts automatically handle path resolution and directory changes
