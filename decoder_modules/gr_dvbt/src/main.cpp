#include <imgui.h>
#include <config.h>
#include <core.h>
#include <gui/style.h>
#include <gui/gui.h>
#include <signal_path/signal_path.h>
#include <module.h>
#include <gui/widgets/folder_select.h>
#include <utils/optionlist.h>
#include <utils/flog.h>
#include "dvbt_decoder.h"

#define CONCAT(a, b) ((std::string(a) + b).c_str())

SDRPP_MOD_INFO{
    /* Name:            */ "gr_dvbt",
    /* Description:     */ "GNU Radio-style DVB-T Decoder",
    /* Author:          */ "SDR++ Community",
    /* Version:         */ 1, 0, 0,
    /* Max instances    */ -1
};

ConfigManager config;

class GRDVBTModule : public ModuleManager::Instance {
public:
    GRDVBTModule(std::string name) {
        this->name = name;
        
        flog::info("[gr_dvbt] Initializing module '{}'", name);

        // Use the generic VFO instead of creating our own
        // DVB-T typically uses 8MHz channels, but we'll adapt to the current VFO
        vfo = sigpath::vfoManager.createVFO(name, ImGui::WaterfallVFO::REF_CENTER, 0, 2000000, 8000000, 2000000, 8000000, false);
        
        flog::info("[gr_dvbt] VFO created for '{}' - BW: {} Hz", name, vfo->getBandwidth());

        // Create the DVB-T decoder
        decoder = new DVBTDecoder();
        flog::info("[gr_dvbt] DVB-T decoder instance created");

        // Connect decoder directly to VFO output (DVB-T needs complex IQ data)
        decoder->init(vfo->output);
        flog::info("[gr_dvbt] Decoder initialized with VFO output stream");
        
        // Set up VFO parameters for DVB-T
        vfo->setBandwidthLimits(1000000, 8000000, true); // 1-8 MHz range for DVB-T channels
        vfo->setSampleRate(2000000, 2000000); // 2 MSPS default
        vfo->setSnapInterval(1000); // 1kHz snap
        
        flog::info("[gr_dvbt] VFO configured - BW: {} Hz", 
                   vfo->getBandwidth());

        // Start processing
        decoder->start();
        flog::info("[gr_dvbt] Decoder processing started");

        gui::menu.registerEntry(name, menuHandler, this, this);
        
        flog::info("[gr_dvbt] GNU Radio DVB-T decoder module '{}' loaded successfully", name);
    }

    ~GRDVBTModule() {
        flog::info("[gr_dvbt] Shutting down module '{}'", name);
        
        gui::menu.removeEntry(name);
        flog::info("[gr_dvbt] Menu entry removed");
        
        if (decoder) {
            flog::info("[gr_dvbt] Stopping decoder...");
            decoder->stop();
            delete decoder;
            decoder = nullptr;
            flog::info("[gr_dvbt] Decoder stopped and destroyed");
        }
        
        if (vfo) {
            flog::info("[gr_dvbt] Destroying VFO...");
            sigpath::vfoManager.deleteVFO(vfo);
            vfo = nullptr;
            flog::info("[gr_dvbt] VFO destroyed");
        }
        
        flog::info("[gr_dvbt] Module '{}' shutdown complete", name);
    }

    void postInit() override {}

    void enable() {
        flog::info("[gr_dvbt] Enabling module '{}'", name);
        enabled = true;
        
        if (vfo) {
            vfo->setReference(ImGui::WaterfallVFO::REF_CENTER);
            flog::info("[gr_dvbt] VFO reference set to center");
        }
        
        if (decoder) {
            decoder->start();
            flog::info("[gr_dvbt] Decoder started");
        }
        
        flog::info("[gr_dvbt] Module '{}' enabled successfully", name);
    }

    void disable() {
        flog::info("[gr_dvbt] Disabling module '{}'", name);
        enabled = false;
        
        if (decoder) {
            decoder->stop();
            flog::info("[gr_dvbt] Decoder stopped");
        }
        
        flog::info("[gr_dvbt] Module '{}' disabled", name);
    }

    bool isEnabled() override {
        return enabled;
    }

private:
    static void menuHandler(void* ctx) {
        GRDVBTModule* _this = (GRDVBTModule*)ctx;
        
        float menuWidth = ImGui::GetContentRegionAvail().x;
        
        ImGui::BeginGroup();
        
        // Enable/disable controls
        if (ImGui::Checkbox(CONCAT("Enable##_gr_dvbt_", _this->name), &_this->enabled)) {
            if (_this->enabled) {
                _this->enable();
            } else {
                _this->disable();
            }
            core::configManager.acquire();
            core::configManager.conf[_this->name]["enabled"] = _this->enabled;
            core::configManager.release(true);
        }
        
        if (!_this->enabled) { 
            style::beginDisabled(); 
        }
        
        // DVB-T specific controls
        ImGui::Text("DVB-T Parameters:");
        
        // Constellation
        ImGui::SetNextItemWidth(menuWidth);
        if (ImGui::Combo(CONCAT("Constellation##_gr_dvbt_", _this->name), &_this->constellation, "QPSK\0QAM16\0QAM64\0")) {
            const char* constNames[] = {"QPSK", "QAM16", "QAM64"};
            flog::info("[gr_dvbt] Constellation changed to: {} ({})", 
                       _this->constellation, constNames[_this->constellation]);
            
            if (_this->decoder) {
                _this->decoder->setConstellation(_this->constellation);
            }
            core::configManager.acquire();
            core::configManager.conf[_this->name]["constellation"] = _this->constellation;
            core::configManager.release(true);
        }
        
        // Code Rate
        ImGui::SetNextItemWidth(menuWidth);
        if (ImGui::Combo(CONCAT("Code Rate##_gr_dvbt_", _this->name), &_this->codeRate, "1/2\02/3\03/4\05/6\07/8\0")) {
            const char* codeRateNames[] = {"1/2", "2/3", "3/4", "5/6", "7/8"};
            flog::info("[gr_dvbt] Code rate changed to: {} ({})", 
                       _this->codeRate, codeRateNames[_this->codeRate]);
            
            if (_this->decoder) {
                _this->decoder->setCodeRate(_this->codeRate);
            }
            core::configManager.acquire();
            core::configManager.conf[_this->name]["codeRate"] = _this->codeRate;
            core::configManager.release(true);
        }
        
        // Guard Interval
        ImGui::SetNextItemWidth(menuWidth);
        if (ImGui::Combo(CONCAT("Guard Interval##_gr_dvbt_", _this->name), &_this->guardInterval, "1/32\01/16\01/8\01/4\0")) {
            const char* guardNames[] = {"1/32", "1/16", "1/8", "1/4"};
            flog::info("[gr_dvbt] Guard interval changed to: {} ({})", 
                       _this->guardInterval, guardNames[_this->guardInterval]);
            
            if (_this->decoder) {
                _this->decoder->setGuardInterval(_this->guardInterval);
            }
            core::configManager.acquire();
            core::configManager.conf[_this->name]["guardInterval"] = _this->guardInterval;
            core::configManager.release(true);
        }
        
        // Transmission Mode
        ImGui::SetNextItemWidth(menuWidth);
        if (ImGui::Combo(CONCAT("TX Mode##_gr_dvbt_", _this->name), &_this->transmissionMode, "2K\08K\0")) {
            const char* txModeNames[] = {"2K", "8K"};
            flog::info("[gr_dvbt] Transmission mode changed to: {} ({})", 
                       _this->transmissionMode, txModeNames[_this->transmissionMode]);
            
            if (_this->decoder) {
                _this->decoder->setTransmissionMode(_this->transmissionMode);
            }
            core::configManager.acquire();
            core::configManager.conf[_this->name]["transmissionMode"] = _this->transmissionMode;
            core::configManager.release(true);
        }
        
        ImGui::Separator();
        
        // VFO Information
        if (_this->vfo) {
            ImGui::Text("VFO Debug Info:");
            ImGui::Text("  Bandwidth: %.1f MHz", _this->vfo->getBandwidth() / 1e6);
            ImGui::Text("  Center Freq: %.3f MHz", _this->vfo->getOffset() / 1e6);
            ImGui::Text("  Reference: %d", _this->vfo->getReference());
            
            // Only log VFO changes when values actually change
            static double lastBandwidth = 0;
            static double lastOffset = 0;
            static int lastReference = -999;
            
            double currentBW = _this->vfo->getBandwidth();
            double currentOffset = _this->vfo->getOffset();
            int currentRef = _this->vfo->getReference();
            
            if (currentBW != lastBandwidth || currentOffset != lastOffset || currentRef != lastReference) {
                flog::info("[gr_dvbt] VFO Changed - BW: {:.1f}MHz, Offset: {:.3f}MHz, Ref: {}", 
                           currentBW / 1e6, currentOffset / 1e6, currentRef);
                lastBandwidth = currentBW;
                lastOffset = currentOffset;
                lastReference = currentRef;
            }
        }
        
        ImGui::Separator();
        
        // Status information
        if (_this->decoder) {
            DVBTStatus status = _this->decoder->getStatus();
            
            ImGui::Text("DVB-T Status:");
            ImGui::TextColored(status.locked ? ImVec4(0, 1, 0, 1) : ImVec4(1, 0, 0, 1), 
                             status.locked ? "LOCKED" : "UNLOCKED");
            
            // Enhanced status display
            ImGui::Text("SNR: %.1f dB", status.snr);
            ImGui::Text("BER: %.2e", status.ber);
            ImGui::Text("Frame Errors: %d", status.frameErrors);
            
            if (status.locked) {
                ImGui::Text("TPS Info:");
                ImGui::Text("  Constellation: %s", 
                           (status.tpsConstellation == 0) ? "QPSK" :
                           (status.tpsConstellation == 1) ? "QAM16" : "QAM64");
                ImGui::Text("  Code Rate: %s",
                           (status.tpsCodeRate == 0) ? "1/2" :
                           (status.tpsCodeRate == 1) ? "2/3" :
                           (status.tpsCodeRate == 2) ? "3/4" :
                           (status.tpsCodeRate == 3) ? "5/6" : "7/8");
                ImGui::Text("  Guard Interval: %s",
                           (status.tpsGuardInterval == 0) ? "1/32" :
                           (status.tpsGuardInterval == 1) ? "1/16" :
                           (status.tpsGuardInterval == 2) ? "1/8" : "1/4");
                ImGui::Text("  TX Mode: %s",
                           (status.tpsTransmissionMode == 0) ? "2K" : "8K");
                
                // Log status changes
                static bool lastLocked = false;
                if (status.locked != lastLocked) {
                    flog::info("[gr_dvbt] DVB-T Lock status changed: {}", 
                               status.locked ? "LOCKED" : "UNLOCKED");
                    if (status.locked) {
                        flog::info("[gr_dvbt] TPS detected - Constellation: {}, Code Rate: {}, Guard: {}, TX Mode: {}",
                                   status.tpsConstellation, status.tpsCodeRate, 
                                   status.tpsGuardInterval, status.tpsTransmissionMode);
                    }
                    lastLocked = status.locked;
                }
            } else {
                ImGui::Text("Searching for DVB-T signal...");
            }
        }
        
        if (!_this->enabled) { 
            style::endDisabled(); 
        }
        
        ImGui::EndGroup();
    }

    std::string name;
    bool enabled = true;
    
    // DVB-T parameters
    int constellation = 0;        // 0=QPSK, 1=QAM16, 2=QAM64
    int codeRate = 1;            // 0=1/2, 1=2/3, 2=3/4, 3=5/6, 4=7/8
    int guardInterval = 1;       // 0=1/32, 1=1/16, 2=1/8, 3=1/4
    int transmissionMode = 0;    // 0=2K, 1=8K
    
    VFOManager::VFO* vfo;
    DVBTDecoder* decoder = nullptr;
};

MOD_EXPORT void _INIT_() {
    config.setPath(core::args["root"].s() + "/gr_dvbt_config.json");
    config.load(json::object());
    config.enableAutoSave();
}

MOD_EXPORT ModuleManager::Instance* _CREATE_INSTANCE_(std::string name) {
    return new GRDVBTModule(name);
}

MOD_EXPORT void _DELETE_INSTANCE_(ModuleManager::Instance* instance) {
    delete (GRDVBTModule*)instance;
}

MOD_EXPORT void _END_() {
    config.disableAutoSave();
    config.save();
}
