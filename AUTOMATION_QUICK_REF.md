# AUTOMATION SCRIPTS QUICK REFERENCE

## ⚡ PRIMARY DEVELOPMENT TOOLS ⚡

### For Fast DVB Module Development:

```batch
# 🚀 FASTEST - Ultra-rapid iteration (10-15 sec)
.\fast_deploy.bat

# 🔧 COMPLETE - Full module build and deploy (30-60 sec)  
.\build_and_deploy_dvb.bat

# 🧪 TEST - Launch with debug output (2-3 sec)
.\test_dvbt.bat
```

## 🎯 WHEN TO USE WHAT

| Scenario | Script | Time | Purpose |
|----------|--------|------|---------|
| **Quick code fix** | `fast_deploy.bat` | ~15s | Rapid iteration |
| **New feature dev** | `build_and_deploy_dvb.bat` | ~45s | Complete setup |
| **Debug/test** | `test_dvbt.bat` | ~3s | See crash output |
| **First time setup** | `build_and_deploy_dvb.bat` | ~60s | Environment init |

## 🔄 STANDARD WORKFLOW

```batch
# 1. Edit code in Visual Studio
# 2. Fast deploy:
.\fast_deploy.bat
# 3. Test immediately:
.\test_dvbt.bat
# 4. Repeat 1-3 for rapid cycles
```

## 🐛 DEBUG OUTPUT TO WATCH FOR

When testing DVB-T, look for these debug messages:
```
[DVB-T] CRASH DEBUG: Entering setMode() with dvb_mode = 2
[DVB-T] CRASH DEBUG: About to call dvbtDemod.setBandwidth()
[DVB-T] CRASH DEBUG: Entering reset() function
[DVB-T] CRASH DEBUG: About to clear fft_buffer
```

## 📁 SCRIPT LOCATIONS
All in solution root: `c:\msys64\home\cpico\SDRPlusPlus\`

## 📖 FULL DOCUMENTATION
- `DEVELOPMENT_SCRIPTS_REFERENCE.md` - Complete guide
- `PACKAGING.md` - Build workflows  
- `PROJECT_WORKFLOW_NOTES.md` - Development practices

---
**💡 TIP**: Always use `fast_deploy.bat` for daily development - it's optimized for speed!
