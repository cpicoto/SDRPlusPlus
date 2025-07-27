# GNU Radio DVB-T Decoder Module (gr-dvbt)

This is a professional DVB-T (Digital Video Broadcasting - Terrestrial) decoder module for SDR++ that implements GNU Radio-style digital signal processing.

## Features

- **GNU Radio compatibility**: Uses the same TPS carrier positions and algorithms as GNU Radio gr-dtv
- **Professional TPS decoding**: Implements differential BPSK demodulation with majority voting
- **Full DVB-T support**: QPSK, QAM16, and QAM64 constellations
- **Multiple code rates**: 1/2, 2/3, 3/4, 5/6, 7/8
- **Flexible guard intervals**: 1/32, 1/16, 1/8, 1/4
- **Transmission modes**: 2K and 8K FFT sizes
- **Real-time status**: SNR estimation, BER monitoring, TPS information
- **ETSI EN 300 744 compliant**: Follows official DVB-T standard

## Technical Implementation

### TPS (Transmission Parameter Signalling)
- Exact GNU Radio TPS carrier positions for 2K and 8K modes
- Differential BPSK demodulation with phase difference calculation
- Majority voting for robust bit decisions
- Sync sequence detection for even/odd frame identification
- Automatic parameter extraction from TPS data

### OFDM Demodulation
- FFTW3-based fast Fourier transforms
- Guard interval removal and cyclic prefix handling
- Channel estimation using scattered pilots
- Symbol synchronization and timing recovery
- Equalization and phase correction

### Signal Processing Chain
1. **Input**: Complex IQ samples from VFO
2. **Frame synchronization**: Autocorrelation-based detection
3. **OFDM symbol extraction**: Guard interval removal
4. **FFT processing**: Frequency domain conversion
5. **Pilot extraction**: Channel estimation and SNR calculation
6. **TPS decoding**: Parameter extraction and validation
7. **Data demodulation**: Constellation-specific bit extraction
8. **Status reporting**: Real-time performance metrics

## Configuration

### DVB-T Parameters
- **Constellation**: QPSK (default), QAM16, QAM64
- **Code Rate**: 1/2, 2/3 (default), 3/4, 5/6, 7/8
- **Guard Interval**: 1/32, 1/16 (default), 1/8, 1/4
- **Transmission Mode**: 2K (default), 8K

### VFO Settings
- **Bandwidth**: 6-8 MHz (typical DVB-T channel)
- **Sample Rate**: 2 MSPS (optimized for real-time processing)
- **Frequency Snap**: 1 kHz steps

## Status Information

The module provides comprehensive status monitoring:

- **Lock Status**: OFDM frame and TPS synchronization
- **Signal Quality**: SNR estimation in dB
- **Error Rates**: Bit Error Rate (BER) calculation
- **TPS Information**: Automatically detected transmission parameters
- **Frame Statistics**: Symbol counting and error tracking

## Dependencies

- **FFTW3**: Fast Fourier Transform library
  - Windows: Provided by PothosSDR or vcpkg
  - Linux: `sudo apt install libfftw3-dev`
- **SDR++ Core**: DSP framework and GUI components

## Usage

1. **Enable the module**: Check the "Enable" checkbox in the decoder panel
2. **Tune to DVB-T signal**: Use VFO to select DVB-T channel frequency
3. **Monitor status**: Watch for "LOCKED" status and good SNR values
4. **Adjust parameters**: Manually set parameters if auto-detection fails
5. **View TPS data**: Check automatically detected transmission parameters

## Technical Notes

### GNU Radio Compatibility
This implementation uses the exact same algorithms and constants as GNU Radio's gr-dtv module:
- TPS carrier positions from ETSI EN 300 744 standard
- Differential BPSK with majority voting
- Professional sync sequence detection
- Compatible parameter encoding

### Performance Optimization
- Efficient FFTW3 implementation for FFT processing
- Threaded design for real-time performance
- Optimized buffer management for low latency
- Smart status updates to minimize GUI overhead

### Standards Compliance
- **ETSI EN 300 744**: DVB-T standard implementation
- **ISO/IEC 13818**: MPEG-2 transport stream compatible
- **GNU Radio**: Algorithm compatibility for validation

## Development

### Code Structure
```
src/
├── main.cpp              # Module entry point and GUI
├── dvbt_decoder.h        # Main decoder class definition
└── dvbt_decoder.cpp      # Implementation with GNU Radio algorithms
```

### Key Classes
- **GRDVBTModule**: Main module class with GUI integration
- **DVBTDecoder**: Core OFDM and TPS processing
- **ProfessionalTPSDecoder**: GNU Radio-style TPS decoder
- **DVBTStatus**: Status and performance monitoring

### Build Integration
The module is integrated into the main SDR++ build system:
- CMake option: `OPT_BUILD_GR_DVBT=ON`
- Automatic FFTW3 detection and linking
- Platform-specific optimizations

## License

This module is part of SDR++ and follows the same licensing terms.

## Contributing

Contributions are welcome! Please ensure:
- GNU Radio algorithm compatibility
- ETSI EN 300 744 standard compliance
- Real-time performance requirements
- Comprehensive testing with various DVB-T signals

---

*GNU Radio DVB-T Decoder Module for SDR++ - Professional digital television decoding*
