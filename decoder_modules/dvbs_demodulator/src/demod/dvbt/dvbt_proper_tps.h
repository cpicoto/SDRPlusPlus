// DVB-T Proper TPS Implementation Header
// Based on GNU Radio gr-dtv reference implementation

#pragma once
#include <dsp/types.h>
#include <dsp/stream.h>
#include <fftw3.h>
#include <vector>
#include <deque>

using namespace dsp;

namespace dsp::dvbt {

struct TPSInfo {
    bool lock;
    int frame_number;          // 0-3 
    int constellation;         // 0=QPSK, 1=16QAM, 2=64QAM
    int hierarchy;             // 0=non-hierarchical
    int code_rate_hp;          // 0=1/2, 1=2/3, 2=3/4, 3=5/6, 4=7/8
    int code_rate_lp;          // Same encoding
    int guard_interval;        // 0=1/32, 1=1/16, 2=1/8, 3=1/4
    int transmission_mode;     // 0=2K, 1=8K
    int cell_id;              // Cell identifier
    
    TPSInfo();
};

class ProperDVBTDemod {
private:
    // OFDM parameters
    int fft_size;
    int guard_samples;
    int symbol_samples;
    double samplerate;
    
    // TPS processing
    TPSInfo tps_info;
    std::deque<int> tps_bit_buffer;
    std::vector<complex_t> tps_prev_symbols;
    int tps_lock_counter;
    int tps_frame_counter;
    int symbol_index;
    bool symbol_sync_found;
    
    // Constellation display
    bool constellation_ready;
    std::vector<complex_t> constellation_points;
    void (*constellation_handler)(complex_t* data, int count, void* ctx);
    void* constellation_ctx;
    
    // FFT processing
    fftwf_complex* fft_in;
    fftwf_complex* fft_out; 
    fftwf_plan fft_plan;
    
    // Channel estimation
    std::vector<complex_t> channel_estimates;
    std::vector<complex_t> pilot_references;
    bool equalizer_ready;
    
    // Debug
    bool debug_output;
    int debug_frame_counter;
    
    // Internal methods
    bool processTPS(const complex_t* ofdm_symbol);
    bool checkTPSSync();
    
public:
    ProperDVBTDemod();
    ~ProperDVBTDemod();
    
    void setConstellationHandler(void (*handler)(complex_t* data, int count, void* ctx), void* ctx);
    bool processSymbol(const complex_t* input_symbol);
    TPSInfo getTPS() const;
    bool isLocked() const;
};

} // namespace dsp::dvbt
