#pragma once

#include <dsp/processor.h>
#include <dsp/stream.h>
#include <dsp/types.h>
#include <dsp/buffer/packer.h>
#include <dsp/buffer/reshaper.h>
#include <dsp/multirate/polyphase_bank.h>
#include <dsp/routing/splitter.h>
#include <thread>
#include <fftw3.h>
#include <complex>
#include <vector>
#include <mutex>

// DVB-T Status structure
struct DVBTStatus {
    bool locked = false;
    float snr = 0.0f;
    float ber = 0.0f;
    int frameErrors = 0;
    int tpsConstellation = 0;
    int tpsCodeRate = 0;
    int tpsGuardInterval = 0;
    int tpsTransmissionMode = 0;
};

// TPS Information structure
struct TPSInfo {
    bool locked = false;
    int constellation = 0;      // 0=QPSK, 1=QAM16, 2=QAM64
    int code_rate = 0;         // 0=1/2, 1=2/3, 2=3/4, 3=5/6, 4=7/8
    int guard_interval = 0;    // 0=1/32, 1=1/16, 2=1/8, 3=1/4
    int transmission_mode = 0; // 0=2K, 1=8K
    int frame_number = 0;      // Even/odd frame
    int cell_id = 0;
    bool cell_id_valid = false;
    float snr_estimate = 0.0f;
};

// GNU Radio-style TPS Decoder
class ProfessionalTPSDecoder {
private:
    // TPS carrier positions from GNU Radio gr-dtv (ETSI EN 300 744)
    static const int TPS_CARRIERS_2K[17];
    static const int TPS_CARRIERS_8K[68];
    static const uint8_t TPS_SYNC_EVEN[16];
    static const uint8_t TPS_SYNC_ODD[16];
    
    std::vector<uint8_t> tps_bits;
    std::vector<dsp::complex_t> prev_tps_symbols;
    int tps_bit_counter;
    bool first_symbol;
    TPSInfo tps_info;
    
public:
    ProfessionalTPSDecoder();
    
    bool isTpsCarrier(int carrier_index, int fft_size);
    bool processTpsSymbols(const dsp::complex_t* symbols, int num_symbols);
    bool decodeTpsFrame(const uint8_t* bits);
    
    const TPSInfo& getTpsInfo() const { return tps_info; }
    void reset();
};

// Main DVB-T Decoder class
class DVBTDecoder : public dsp::Processor<dsp::complex_t, uint8_t> {
public:
    using base_type = dsp::Processor<dsp::complex_t, uint8_t>;

    DVBTDecoder() {}
    DVBTDecoder(dsp::stream<dsp::complex_t>* in) { init(in); }
    ~DVBTDecoder();

    void init(dsp::stream<dsp::complex_t>* in);
    void start();
    void stop();
    void reset();
    
    int run() override;

    // Configuration
    void setConstellation(int constellation);
    void setCodeRate(int codeRate);
    void setGuardInterval(int guardInterval);
    void setTransmissionMode(int transmissionMode);

    // Status
    DVBTStatus getStatus() const;

private:
    int process(int count, const dsp::complex_t* in, uint8_t* out);
    
    // Fast non-blocking processing
    void processSymbolFast();
    void processOFDMSymbolFast(const dsp::complex_t* symbol);
    void extractPilotsLight(const dsp::complex_t* symbol, int symbol_num);
    
    // OFDM processing
    void processOFDMSymbol(const dsp::complex_t* symbol);
    void extractPilots(const dsp::complex_t* symbol, int symbol_num);
    void extractTPS(const dsp::complex_t* symbol, int symbol_num);
    void extractData(const dsp::complex_t* symbol, int symbol_num);
    
    // Synchronization
    bool detectFrame(const dsp::complex_t* samples, int& frame_start);
    void updateTiming(const dsp::complex_t* symbol);
    
    // Channel estimation and equalization
    void estimateChannel(const dsp::complex_t* pilots, int symbol_num);
    void equalizeSymbol(dsp::complex_t* symbol);
    
    // Demodulation and decoding
    void demodulateQPSK(const dsp::complex_t* symbols, uint8_t* bits, int num_symbols);
    void demodulateQAM16(const dsp::complex_t* symbols, uint8_t* bits, int num_symbols);
    void demodulateQAM64(const dsp::complex_t* symbols, uint8_t* bits, int num_symbols);
    
    // FFTW components
    fftwf_plan fft_plan;
    fftwf_complex* fft_in;
    fftwf_complex* fft_out;
    
    // Configuration parameters
    int fft_size = 2048;           // 2K mode by default
    int guard_size = 128;          // 1/16 guard interval by default
    int symbol_size;               // fft_size + guard_size
    int constellation_mode = 0;    // 0=QPSK, 1=QAM16, 2=QAM64
    int code_rate_mode = 1;       // 0=1/2, 1=2/3, 2=3/4, 3=5/6, 4=7/8
    
    // Processing state
    std::vector<dsp::complex_t> input_buffer;
    std::vector<dsp::complex_t> symbol_buffer;
    std::vector<dsp::complex_t> channel_estimates;
    int buffer_pos = 0;
    int symbol_counter = 0;
    bool frame_locked = false;
    
    // TPS decoder
    ProfessionalTPSDecoder tps_decoder;
    
    // Status
    mutable std::mutex status_mutex;
    DVBTStatus current_status;
    
    // Performance monitoring
    int total_symbols = 0;
    int error_symbols = 0;
    float signal_power = 0.0f;
    float noise_power = 0.0f;
};

// Utility functions
namespace dvbt_utils {
    // Calculate guard interval size from mode
    int getGuardSize(int fft_size, int guard_mode);
    
    // Get number of data carriers
    int getDataCarriers(int fft_size);
    
    // Convert TPS parameters to human-readable strings
    const char* getConstellationName(int constellation);
    const char* getCodeRateName(int code_rate);
    const char* getGuardIntervalName(int guard_interval);
    const char* getTransmissionModeName(int transmission_mode);
}
