# Configuration Updates for GNU Radio DVB-T Module

## Summary of Changes

Successfully updated configuration files to load the new `gr_dvbt` module instead of the old `dvbs_demodulator`.

## Configuration Files Updated

### 1. Main Configuration (`config.json`)
- **Status**: Updated with gr_dvbt module configuration
- **Key Changes**:
  - Set default frequency to 666 MHz (typical DVB-T frequency)
  - Added "GNU Radio DVB-T" module instance with `gr_dvbt`
  - Added green VFO color for DVB-T (#00FF00)
  - Set DVB-T VFO offset to 0.0
  - Added "GNU Radio DVB-T" to menu elements
  - Enabled essential modules: RTL-SDR, Radio, Audio Sink, File Source

### 2. Runtime Configuration (`root_dev/config.json`)
- **Status**: Updated to use gr_dvbt module
- **Key Changes**:
  - Replaced "DVB Demodulator" (dvbs_demodulator) with "GNU Radio DVB-T" (gr_dvbt)
  - Disabled old dvbs_demodulator module
  - Enabled new gr_dvbt module
  - Updated menu elements to show "GNU Radio DVB-T"
  - Updated VFO offsets for new module name

### 3. Module Configuration (`root_dev/gr_dvbt_config.json`)
- **Status**: Created new default configuration
- **Default Settings**:
  ```json
  {
      "enabled": true,
      "constellation": 0,      // QPSK
      "codeRate": 1,          // 2/3
      "guardInterval": 1,     // 1/16  
      "transmissionMode": 0   // 2K mode
  }
  ```

### 4. Deployment Script (`fast_deploy.bat`)
- **Status**: Updated to handle gr_dvbt configuration
- **Enhancement**: Automatically creates default gr_dvbt_config.json if missing

## Module Loading Configuration

### In SDR++ Configuration
```json
"moduleInstances": {
    "GNU Radio DVB-T": {
        "enabled": true,
        "module": "gr_dvbt"
    }
}
```

### Menu Integration
```json
"menuElements": [
    {
        "name": "GNU Radio DVB-T",
        "open": true
    }
]
```

### VFO Configuration
```json
"vfoColors": {
    "GNU Radio DVB-T": "#00FF00"
},
"vfoOffsets": {
    "GNU Radio DVB-T": 0.0
}
```

## DVB-T Optimized Settings

### Frequency Configuration
- **Default**: 666 MHz (UHF DVB-T band)
- **Range**: 470-790 MHz (typical DVB-T frequencies)
- **Bandwidth**: 8 MHz channels

### Module Parameters
- **Constellation**: QPSK (default), QAM16, QAM64 available
- **Code Rate**: 2/3 (default), others available (1/2, 3/4, 5/6, 7/8)
- **Guard Interval**: 1/16 (default), others available (1/32, 1/8, 1/4)
- **Transmission Mode**: 2K (default), 8K available

## Testing Verification

### Module Loading Check
1. Launch SDR++: `test_gr_dvbt.bat`
2. Verify "GNU Radio DVB-T" appears in module list
3. Check module can be enabled/disabled
4. Confirm VFO creation works

### Configuration Persistence
1. Change DVB-T parameters in GUI
2. Restart SDR++
3. Verify settings are saved and restored
4. Check gr_dvbt_config.json is updated

## Backward Compatibility

### Old Configuration Handling
- **dvbs_demodulator**: Disabled but not removed from root_dev config
- **DVB Demodulator menu**: Replaced with "GNU Radio DVB-T" 
- **VFO offsets**: Updated to use new module names
- **Module files**: Old dvbs_demodulator completely removed

### Migration Notes
- Existing DVB-T settings will use defaults on first run
- Users need to reconfigure DVB-T parameters
- Old dvbs_demodulator config files remain but are unused

## File Locations Summary

```
SDRPlusPlus/
├── config.json                        # Main config with gr_dvbt
├── root_dev/
│   ├── config.json                     # Runtime config with gr_dvbt  
│   ├── gr_dvbt_config.json            # Module-specific settings
│   └── modules/
│       └── gr_dvbt.dll                # Deployed module
└── decoder_modules/gr_dvbt/           # Source code
```

## Ready for Testing

The configuration is now **complete and ready** for:

✅ **Module Loading**: gr_dvbt will load automatically  
✅ **GUI Integration**: "GNU Radio DVB-T" appears in menus  
✅ **Parameter Persistence**: Settings saved/restored correctly  
✅ **VFO Management**: DVB-T VFO with proper color coding  
✅ **Default Settings**: Professional DVB-T parameters pre-configured  

Launch SDR++ and the GNU Radio DVB-T module will be automatically loaded and ready for DVB-T signal decoding!

---

*Configuration Update Complete: July 27, 2025*
