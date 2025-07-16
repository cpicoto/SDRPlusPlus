# SDR++ AI Change Log

This file documents all changes made to the repository by the AI assistant during the current session.

## 2025-07-12

### Build & Development Environment
- Created `create_root_debug.bat` to copy all debug binaries, modules, and dependencies to `root_dev` for a complete debug development environment.
- Created `create_root_debug.ps1` (PowerShell version) for the same purpose.
- Updated both scripts to automatically copy RtAudio DLLs (`rtaudio.dll`, `rtaudiod.dll`) from vcpkg to `root_dev`.

### Module Loading
- Updated `root_dev/config.json` to only load the `dvbs_demodulator.dll` module by default (others are not loaded unless added to the list).

### Debug Build Process
- Cleaned and rebuilt the project in Debug mode.
- Verified that all required DLLs and modules are present in `root_dev`.
- Ensured that audio modules work by including missing RtAudio DLLs.

### General Improvements
- Provided instructions and scripts to ensure a consistent, portable, and complete development environment for SDR++ debug builds.

---

*This changelog is maintained by the AI assistant to help track and audit automated changes for transparency and reproducibility.* 