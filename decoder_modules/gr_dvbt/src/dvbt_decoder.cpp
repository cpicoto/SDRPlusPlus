#include "dvbt_decoder.h"
#include <utils/flog.h>
#include <cstring>
#include <cmath>
#include <algorithm>

// TPS carrier positions from GNU Radio gr-dtv (ETSI EN 300 744)
const int ProfessionalTPSDecoder::TPS_CARRIERS_2K[17] = {
    34, 50, 209, 346, 413, 569, 595, 688, 790, 901, 
    1073, 1219, 1262, 1286, 1469, 1594, 1687
};

const int ProfessionalTPSDecoder::TPS_CARRIERS_8K[68] = {
    34, 50, 209, 346, 413, 569, 595, 688, 790, 901, 1073, 1219, 1262, 1286,
    1469, 1594, 1687, 1738, 1754, 1913, 2050, 2117, 2273, 2299, 2392, 2494, 
    2605, 2777, 2923, 2966, 2990, 3173, 3298, 3391, 3442, 3458, 3617, 3754, 
    3821, 3977, 4003, 4096, 4198, 4309, 4481, 4627, 4670, 4694, 4877, 5002, 
    5095, 5146, 5162, 5321, 5458, 5525, 5681, 5707, 5800, 5902, 6013, 6185, 
    6331, 6374, 6398, 6581, 6706, 6799
};

const uint8_t ProfessionalTPSDecoder::TPS_SYNC_EVEN[16] = {
    0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0
};

const uint8_t ProfessionalTPSDecoder::TPS_SYNC_ODD[16] = {
    1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1
};

// Professional TPS Decoder Implementation
ProfessionalTPSDecoder::ProfessionalTPSDecoder() {
    tps_bits.resize(68);
    prev_tps_symbols.resize(68);
    tps_bit_counter = 0;
    first_symbol = true;
}

bool ProfessionalTPSDecoder::isTpsCarrier(int carrier_index, int fft_size) {
    int k = carrier_index - (fft_size / 2);  // Convert to centered index
    
    if (fft_size == 2048) {
        // 2K mode - check positive and negative carriers
        for (int i = 0; i < 17; i++) {
            if (k == TPS_CARRIERS_2K[i] || k == -TPS_CARRIERS_2K[i]) {
                return true;
            }
        }
        return false;
    } else if (fft_size == 8192) {
        // 8K mode - check positive and negative carriers
        for (int i = 0; i < 68; i++) {
            if (k == TPS_CARRIERS_8K[i] || k == -TPS_CARRIERS_8K[i]) {
                return true;
            }
        }
        return false;
    }
    return false;
}

bool ProfessionalTPSDecoder::processTpsSymbols(const dsp::complex_t* symbols, int num_symbols) {
    if (!symbols || num_symbols < 17) return false;
    
    // Skip first symbol for differential reference (GNU Radio approach)
    if (first_symbol) {
        std::copy(symbols, symbols + std::min(num_symbols, 68), prev_tps_symbols.begin());
        first_symbol = false;
        return false;
    }
    
    // GNU Radio-style differential BPSK demodulation with majority voting
    int tps_majority_zero = 0;
    int valid_carriers = 0;
    
    for (int i = 0; i < std::min(num_symbols, 68); i++) {
        // Create non-const copies for computation
        dsp::complex_t curr = symbols[i];
        dsp::complex_t prev = prev_tps_symbols[i];
        
        // Differential demodulation: current * conj(previous)
        dsp::complex_t phdiff = curr * prev.conj();
        
        // Quality check
        float diff_magnitude = phdiff.amplitude();
        if (diff_magnitude > 0.3f) {
            // DBPSK decision: real part >= 0 = bit 0, real part < 0 = bit 1
            if (phdiff.re >= 0.0f) {
                tps_majority_zero++;
            } else {
                tps_majority_zero--;
            }
            valid_carriers++;
        }
    }
    
    // Store current symbols for next differential operation
    std::copy(symbols, symbols + std::min(num_symbols, 68), prev_tps_symbols.begin());
    
    // Need sufficient valid carriers for reliable decision
    if (valid_carriers < 10) return false;
    
    // Add majority-voted bit to TPS buffer
    if (tps_bit_counter < 68) {
        tps_bits[tps_bit_counter++] = (tps_majority_zero >= 0) ? 0 : 1;
    }
    
    // Process complete frame
    if (tps_bit_counter >= 68) {
        bool success = decodeTpsFrame(tps_bits.data());
        tps_bit_counter = 0;  // Reset for next frame
        return success;
    }
    
    return false;
}

bool ProfessionalTPSDecoder::decodeTpsFrame(const uint8_t* bits) {
    if (!bits) return false;
    
    // Check sync sequences (bits 1-16)
    bool sync_even_match = true;
    bool sync_odd_match = true;
    
    for (int i = 0; i < 16; i++) {
        if (bits[1 + i] != TPS_SYNC_EVEN[i]) sync_even_match = false;
        if (bits[1 + i] != TPS_SYNC_ODD[i]) sync_odd_match = false;
    }
    
    // At least one sync must match
    if (!sync_even_match && !sync_odd_match) {
        return false;
    }
    
    // Set frame number
    tps_info.frame_number = sync_even_match ? 0 : 1;
    
    // Decode constellation (bits 17-18)
    int const_bits = (bits[17] << 1) | bits[18];
    tps_info.constellation = const_bits;
    
    // Decode code rate (bits 23-25)
    int cr_bits = (bits[23] << 2) | (bits[24] << 1) | bits[25];
    tps_info.code_rate = cr_bits;
    
    // Decode guard interval (bits 36-37)
    int gi_bits = (bits[36] << 1) | bits[37];
    tps_info.guard_interval = gi_bits;
    
    // Decode transmission mode (bits 38-39)
    int mode_bits = (bits[38] << 1) | bits[39];
    tps_info.transmission_mode = mode_bits;
    
    // Decode cell ID for even frames (bits 40-47)
    if (sync_even_match) {
        tps_info.cell_id = 0;
        for (int i = 0; i < 8; i++) {
            tps_info.cell_id |= (bits[40 + i] << (7 - i));
        }
        tps_info.cell_id_valid = true;
    }
    
    // Estimate SNR based on sync quality
    float sync_quality = sync_even_match || sync_odd_match ? 1.0f : 0.0f;
    tps_info.snr_estimate = sync_quality * 20.0f;  // Simple estimate
    
    tps_info.locked = true;
    return true;
}

void ProfessionalTPSDecoder::reset() {
    tps_bit_counter = 0;
    first_symbol = true;
    tps_info.locked = false;
}

// DVB-T Decoder Implementation
void DVBTDecoder::init(dsp::stream<dsp::complex_t>* in) {
    flog::info("[DVBTDecoder] Initializing decoder...");
    base_type::init(in);
    
    // Initialize FFTW
    fft_in = (fftwf_complex*)fftwf_malloc(sizeof(fftwf_complex) * fft_size);
    fft_out = (fftwf_complex*)fftwf_malloc(sizeof(fftwf_complex) * fft_size);
    fft_plan = fftwf_plan_dft_1d(fft_size, fft_in, fft_out, FFTW_FORWARD, FFTW_ESTIMATE);
    
    flog::info("[DVBTDecoder] FFTW plan created for {} point FFT", fft_size);
    
    // Initialize buffers
    symbol_size = fft_size + guard_size;
    input_buffer.resize(symbol_size * 4);  // Buffer for 4 symbols
    symbol_buffer.resize(fft_size);
    channel_estimates.resize(fft_size);
    
    flog::info("[DVBTDecoder] Buffers allocated - Symbol size: {} samples", symbol_size);
    
    // Initialize status
    current_status = DVBTStatus{};
    
    flog::info("[DVBTDecoder] Decoder initialized: FFT size={}, Guard={}, Symbol size={}", 
               fft_size, guard_size, symbol_size);
}

void DVBTDecoder::start() {
    if (base_type::_in == nullptr) {
        flog::error("[DVBTDecoder] Cannot start: input stream is null");
        return;
    }
    
    flog::info("[DVBTDecoder] Starting decoder...");
    base_type::start();
    flog::info("[DVBTDecoder] Decoder started successfully - non-blocking processing");
}

void DVBTDecoder::stop() {
    flog::info("[DVBTDecoder] Stopping decoder...");
    base_type::stop();
    flog::info("[DVBTDecoder] Decoder stopped successfully");
}

void DVBTDecoder::reset() {
    std::lock_guard<std::mutex> lock(status_mutex);
    
    buffer_pos = 0;
    symbol_counter = 0;
    frame_locked = false;
    total_symbols = 0;
    error_symbols = 0;
    signal_power = 0.0f;
    noise_power = 0.0f;
    
    tps_decoder.reset();
    current_status = DVBTStatus{};
    
    flog::info("DVB-T decoder reset");
}

int DVBTDecoder::run() {
    int count = _in->read();
    if (count < 0) { return -1; }

    // Non-blocking sample processing - process in small chunks
    const int chunk_size = 1024;
    for (int i = 0; i < count; i += chunk_size) {
        int samples_to_process = std::min(chunk_size, count - i);
        process(samples_to_process, &_in->readBuf[i], nullptr);
    }
    
    _in->flush();
    return count;
}

int DVBTDecoder::process(int count, const dsp::complex_t* in, uint8_t* out) {
    // Early exit if no samples
    if (count <= 0) return 0;
    
    // Process samples in small chunks to avoid blocking
    const int max_samples_per_call = 512;
    int samples_processed = 0;
    
    for (int i = 0; i < count && i < max_samples_per_call; i++) {
        input_buffer[buffer_pos++] = in[i];
        samples_processed++;
        
        // Process when we have a complete symbol
        if (buffer_pos >= symbol_size) {
            // Try to detect frame start if not locked
            if (!frame_locked) {
                int frame_start;
                if (detectFrame(input_buffer.data(), frame_start)) {
                    frame_locked = true;
                    buffer_pos = symbol_size - frame_start;
                    // Move remaining data to beginning
                    std::copy(input_buffer.begin() + frame_start, 
                             input_buffer.begin() + symbol_size, 
                             input_buffer.begin());
                    continue;
                }
                // Slide window by smaller amount to reduce processing
                const int slide_amount = std::min(64, buffer_pos - 1);
                std::copy(input_buffer.begin() + slide_amount, input_buffer.end(), input_buffer.begin());
                buffer_pos -= slide_amount;
                continue;
            }
            
            // Quick FFT and symbol processing
            processSymbolFast();
            
            // Reset buffer
            buffer_pos = 0;
            symbol_counter++;
        }
    }
    
    return samples_processed;
}

void DVBTDecoder::processOFDMSymbol(const dsp::complex_t* symbol) {
    // Extract TPS carriers
    extractTPS(symbol, symbol_counter);
    
    // Extract pilots for channel estimation
    extractPilots(symbol, symbol_counter);
    
    // Equalize symbol
    equalizeSymbol(const_cast<dsp::complex_t*>(symbol));
    
    // Extract and demodulate data carriers
    extractData(symbol, symbol_counter);
    
    // Update statistics
    total_symbols++;
    
    // Update status every 100 symbols
    if (symbol_counter % 100 == 0) {
        std::lock_guard<std::mutex> lock(status_mutex);
        current_status.locked = frame_locked && tps_decoder.getTpsInfo().locked;
        current_status.snr = (noise_power > 0) ? 10.0f * log10f(signal_power / noise_power) : 0.0f;
        current_status.ber = (total_symbols > 0) ? (float)error_symbols / total_symbols : 0.0f;
        
        if (tps_decoder.getTpsInfo().locked) {
            const TPSInfo& tps = tps_decoder.getTpsInfo();
            current_status.tpsConstellation = tps.constellation;
            current_status.tpsCodeRate = tps.code_rate;
            current_status.tpsGuardInterval = tps.guard_interval;
            current_status.tpsTransmissionMode = tps.transmission_mode;
        }
    }
}

void DVBTDecoder::processSymbolFast() {
    // Quick FFT processing
    for (int j = 0; j < fft_size; j++) {
        fft_in[j][0] = input_buffer[guard_size + j].re;
        fft_in[j][1] = input_buffer[guard_size + j].im;
    }
    
    // Perform FFT
    fftwf_execute(fft_plan);
    
    // Copy FFT output to symbol buffer
    for (int j = 0; j < fft_size; j++) {
        symbol_buffer[j] = {fft_out[j][0], fft_out[j][1]};
    }
    
    // Lightweight symbol processing
    processOFDMSymbolFast(symbol_buffer.data());
}

void DVBTDecoder::processOFDMSymbolFast(const dsp::complex_t* symbol) {
    // Extract TPS carriers only every 10th symbol to reduce load
    if (symbol_counter % 10 == 0) {
        extractTPS(symbol, symbol_counter);
    }
    
    // Quick pilot extraction for SNR estimate
    if (symbol_counter % 20 == 0) {
        extractPilotsLight(symbol, symbol_counter);
    }
    
    // Update statistics less frequently
    total_symbols++;
    
    // Update status every 200 symbols instead of 100
    if (symbol_counter % 200 == 0) {
        std::lock_guard<std::mutex> lock(status_mutex);
        current_status.locked = frame_locked && tps_decoder.getTpsInfo().locked;
        current_status.snr = (noise_power > 0) ? 10.0f * log10f(signal_power / noise_power) : 0.0f;
        current_status.ber = (total_symbols > 0) ? (float)error_symbols / total_symbols : 0.0f;
        
        if (tps_decoder.getTpsInfo().locked) {
            const TPSInfo& tps = tps_decoder.getTpsInfo();
            current_status.tpsConstellation = tps.constellation;
            current_status.tpsCodeRate = tps.code_rate;
            current_status.tpsGuardInterval = tps.guard_interval;
            current_status.tpsTransmissionMode = tps.transmission_mode;
        }
    }
}

void DVBTDecoder::extractTPS(const dsp::complex_t* symbol, int symbol_num) {
    std::vector<dsp::complex_t> tps_symbols;
    
    // Extract TPS carriers
    for (int i = 0; i < fft_size; i++) {
        if (tps_decoder.isTpsCarrier(i, fft_size)) {
            tps_symbols.push_back(symbol[i]);
        }
    }
    
    // Process TPS symbols
    if (!tps_symbols.empty()) {
        tps_decoder.processTpsSymbols(tps_symbols.data(), tps_symbols.size());
    }
}

void DVBTDecoder::extractPilots(const dsp::complex_t* symbol, int symbol_num) {
    // Simplified pilot extraction - would need full ETSI pilot pattern
    signal_power = 0.0f;
    int pilot_count = 0;
    
    // Use scattered pilots for channel estimation
    for (int i = 0; i < fft_size; i += 12) {  // Simplified pilot spacing
        if (i < fft_size) {
            signal_power += (symbol[i].re * symbol[i].re + symbol[i].im * symbol[i].im);
            pilot_count++;
        }
    }
    
    if (pilot_count > 0) {
        signal_power /= pilot_count;
    }
}

void DVBTDecoder::extractPilotsLight(const dsp::complex_t* symbol, int symbol_num) {
    // Very lightweight pilot extraction for basic SNR estimate
    signal_power = 0.0f;
    int pilot_count = 0;
    
    // Use every 24th carrier as pilot estimate (simplified)
    for (int i = 0; i < fft_size; i += 24) {
        if (i < fft_size) {
            signal_power += (symbol[i].re * symbol[i].re + symbol[i].im * symbol[i].im);
            pilot_count++;
        }
    }
    
    if (pilot_count > 0) {
        signal_power /= pilot_count;
        noise_power = signal_power * 0.1f; // Simple noise estimate
    }
}

void DVBTDecoder::extractData(const dsp::complex_t* symbol, int symbol_num) {
    // Extract data carriers (excluding pilots and TPS)
    std::vector<dsp::complex_t> data_symbols;
    
    for (int i = 0; i < fft_size; i++) {
        // Skip TPS carriers and pilots (simplified)
        if (!tps_decoder.isTpsCarrier(i, fft_size) && (i % 12) != 0) {
            data_symbols.push_back(symbol[i]);
        }
    }
    
    // Demodulate based on constellation
    if (!data_symbols.empty()) {
        std::vector<uint8_t> bits(data_symbols.size() * 6);  // Max 6 bits per symbol for QAM64
        
        switch (constellation_mode) {
            case 0:
                demodulateQPSK(data_symbols.data(), bits.data(), data_symbols.size());
                break;
            case 1:
                demodulateQAM16(data_symbols.data(), bits.data(), data_symbols.size());
                break;
            case 2:
                demodulateQAM64(data_symbols.data(), bits.data(), data_symbols.size());
                break;
        }
    }
}

void DVBTDecoder::demodulateQPSK(const dsp::complex_t* symbols, uint8_t* bits, int num_symbols) {
    for (int i = 0; i < num_symbols; i++) {
        dsp::complex_t sym = symbols[i];
        
        // QPSK constellation mapping
        bits[i * 2] = (sym.re >= 0) ? 0 : 1;
        bits[i * 2 + 1] = (sym.im >= 0) ? 0 : 1;
    }
}

void DVBTDecoder::demodulateQAM16(const dsp::complex_t* symbols, uint8_t* bits, int num_symbols) {
    for (int i = 0; i < num_symbols; i++) {
        dsp::complex_t sym = symbols[i];
        
        // QAM16 constellation mapping (simplified)
        float re = sym.re;
        float im = sym.im;
        
        bits[i * 4] = (re >= 0) ? 0 : 1;
        bits[i * 4 + 1] = (fabsf(re) >= 0.6f) ? 0 : 1;
        bits[i * 4 + 2] = (im >= 0) ? 0 : 1;
        bits[i * 4 + 3] = (fabsf(im) >= 0.6f) ? 0 : 1;
    }
}

void DVBTDecoder::demodulateQAM64(const dsp::complex_t* symbols, uint8_t* bits, int num_symbols) {
    for (int i = 0; i < num_symbols; i++) {
        dsp::complex_t sym = symbols[i];
        
        // QAM64 constellation mapping (simplified)
        float re = sym.re;
        float im = sym.im;
        
        bits[i * 6] = (re >= 0) ? 0 : 1;
        bits[i * 6 + 1] = (fabsf(re) >= 0.6f) ? 0 : 1;
        bits[i * 6 + 2] = (fabsf(re) >= 0.3f && fabsf(re) < 0.9f) ? 0 : 1;
        bits[i * 6 + 3] = (im >= 0) ? 0 : 1;
        bits[i * 6 + 4] = (fabsf(im) >= 0.6f) ? 0 : 1;
        bits[i * 6 + 5] = (fabsf(im) >= 0.3f && fabsf(im) < 0.9f) ? 0 : 1;
    }
}

bool DVBTDecoder::detectFrame(const dsp::complex_t* samples, int& frame_start) {
    // Simplified frame detection using autocorrelation
    const int search_window = 1000;
    float max_correlation = 0.0f;
    frame_start = 0;
    
    for (int i = 0; i < search_window; i++) {
        float correlation = 0.0f;
        
        // Correlate guard interval with end of symbol
        for (int j = 0; j < guard_size; j++) {
            if (i + j < search_window && i + j + fft_size < search_window) {
                dsp::complex_t sample1 = samples[i + j];
                dsp::complex_t sample2 = samples[i + j + fft_size];
                dsp::complex_t corr = sample1 * sample2.conj();
                correlation += corr.re;
            }
        }
        
        if (correlation > max_correlation) {
            max_correlation = correlation;
            frame_start = i;
        }
    }
    
    return max_correlation > 0.5f;  // Threshold for detection
}

void DVBTDecoder::equalizeSymbol(dsp::complex_t* symbol) {
    // Simplified equalization - in practice would use channel estimates
    // This just normalizes the symbol power
    float power = 0.0f;
    for (int i = 0; i < fft_size; i++) {
        power += (symbol[i].re * symbol[i].re + symbol[i].im * symbol[i].im);
    }
    
    if (power > 0) {
        float scale = sqrt(fft_size / power);
        for (int i = 0; i < fft_size; i++) {
            symbol[i] *= scale;
        }
    }
}

void DVBTDecoder::setConstellation(int constellation) {
    if (constellation >= 0 && constellation <= 2 && constellation != constellation_mode) {
        const char* constNames[] = {"QPSK", "QAM16", "QAM64"};
        flog::info("[DVBTDecoder] Setting constellation to {} ({})", constellation, constNames[constellation]);
        constellation_mode = constellation;
        reset();
    } else if (constellation < 0 || constellation > 2) {
        flog::warn("[DVBTDecoder] Invalid constellation value: {}", constellation);
    }
}

void DVBTDecoder::setCodeRate(int codeRate) {
    if (codeRate >= 0 && codeRate <= 4 && codeRate != code_rate_mode) {
        const char* codeRateNames[] = {"1/2", "2/3", "3/4", "5/6", "7/8"};
        flog::info("[DVBTDecoder] Setting code rate to {} ({})", codeRate, codeRateNames[codeRate]);
        code_rate_mode = codeRate;
        reset();
    } else {
        flog::warn("[DVBTDecoder] Invalid code rate value: {}", codeRate);
    }
}

void DVBTDecoder::setGuardInterval(int guardInterval) {
    if (guardInterval >= 0 && guardInterval <= 3) {
        int old_guard_size = guard_size;
        int new_guard_size = dvbt_utils::getGuardSize(fft_size, guardInterval);
        
        if (new_guard_size != old_guard_size) {
            const char* guardNames[] = {"1/32", "1/16", "1/8", "1/4"};
            flog::info("[DVBTDecoder] Setting guard interval to {} ({})", guardInterval, guardNames[guardInterval]);
            
            guard_size = new_guard_size;
            symbol_size = fft_size + guard_size;
            
            flog::info("[DVBTDecoder] Guard interval changed: {} -> {} samples, symbol size: {}", 
                       old_guard_size, guard_size, symbol_size);
            
            reset();
        }
    } else {
        flog::warn("[DVBTDecoder] Invalid guard interval value: {}", guardInterval);
    }
}

void DVBTDecoder::setTransmissionMode(int transmissionMode) {
    if (transmissionMode == 0 || transmissionMode == 1) {
        int old_fft_size = fft_size;
        int new_fft_size = (transmissionMode == 0) ? 2048 : 8192;
        
        if (new_fft_size != old_fft_size) {
            const char* txModeNames[] = {"2K", "8K"};
            flog::info("[DVBTDecoder] Setting transmission mode to {} ({})", transmissionMode, txModeNames[transmissionMode]);
            
            // Clean up old FFTW plan
            if (fft_plan) {
                flog::info("[DVBTDecoder] Destroying old FFTW plan (size: {})", old_fft_size);
                fftwf_destroy_plan(fft_plan);
                fftwf_free(fft_in);
                fftwf_free(fft_out);
            }
            
            // Set new FFT size
            fft_size = new_fft_size;
            symbol_size = fft_size + guard_size;
            
            flog::info("[DVBTDecoder] FFT size changed: {} -> {}, symbol size: {}", 
                       old_fft_size, fft_size, symbol_size);
            
            // Recreate FFTW plan
            fft_in = (fftwf_complex*)fftwf_malloc(sizeof(fftwf_complex) * fft_size);
            fft_out = (fftwf_complex*)fftwf_malloc(sizeof(fftwf_complex) * fft_size);
            fft_plan = fftwf_plan_dft_1d(fft_size, fft_in, fft_out, FFTW_FORWARD, FFTW_ESTIMATE);
            
            flog::info("[DVBTDecoder] New FFTW plan created for {} points", fft_size);
            
            // Resize buffers
            symbol_buffer.resize(fft_size);
            channel_estimates.resize(fft_size);
            
            reset();
        }
    } else {
        flog::warn("[DVBTDecoder] Invalid transmission mode value: {}", transmissionMode);
    }
}

DVBTStatus DVBTDecoder::getStatus() const {
    std::lock_guard<std::mutex> lock(status_mutex);
    return current_status;
}

DVBTDecoder::~DVBTDecoder() {
    stop();
    
    if (fft_plan) {
        fftwf_destroy_plan(fft_plan);
        fftwf_free(fft_in);
        fftwf_free(fft_out);
    }
}

// Utility functions
namespace dvbt_utils {
    int getGuardSize(int fft_size, int guard_mode) {
        switch (guard_mode) {
            case 0: return fft_size / 32;  // 1/32
            case 1: return fft_size / 16;  // 1/16
            case 2: return fft_size / 8;   // 1/8
            case 3: return fft_size / 4;   // 1/4
            default: return fft_size / 16;
        }
    }
    
    int getDataCarriers(int fft_size) {
        // Approximate number of data carriers (excluding pilots and TPS)
        return (fft_size == 2048) ? 1512 : 6048;
    }
    
    const char* getConstellationName(int constellation) {
        switch (constellation) {
            case 0: return "QPSK";
            case 1: return "QAM16";
            case 2: return "QAM64";
            default: return "Unknown";
        }
    }
    
    const char* getCodeRateName(int code_rate) {
        switch (code_rate) {
            case 0: return "1/2";
            case 1: return "2/3";
            case 2: return "3/4";
            case 3: return "5/6";
            case 4: return "7/8";
            default: return "Unknown";
        }
    }
    
    const char* getGuardIntervalName(int guard_interval) {
        switch (guard_interval) {
            case 0: return "1/32";
            case 1: return "1/16";
            case 2: return "1/8";
            case 3: return "1/4";
            default: return "Unknown";
        }
    }
    
    const char* getTransmissionModeName(int transmission_mode) {
        switch (transmission_mode) {
            case 0: return "2K";
            case 1: return "8K";
            default: return "Unknown";
        }
    }
}
