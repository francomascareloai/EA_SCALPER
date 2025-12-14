//+------------------------------------------------------------------+
//| OnnxBrain.mqh - ML Brain for EA_SCALPER_XAUUSD                    |
//| Singularity Edition v2.2                                          |
//+------------------------------------------------------------------+
#property copyright "Franco - EA_SCALPER_XAUUSD"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| COnnxBrain Class - ONNX Model Integration                         |
//+------------------------------------------------------------------+
class COnnxBrain {
private:
    long     m_model_handle;
    bool     m_initialized;
    float    m_input[];
    float    m_output[];
    double   m_means[];
    double   m_stds[];
    string   m_model_path;
    string   m_scaler_path;
    
    bool LoadScalerParams();
    bool CollectFeatures(double &features[]);
    
public:
    COnnxBrain();
    ~COnnxBrain();
    
    bool Initialize(string modelPath = "Models\\direction_model.onnx",
                   string scalerPath = "Models\\scaler_params.json");
    void Deinitialize();
    
    double GetBullishProbability();
    double GetConfidence(int signalDirection);
    bool IsReady() { return m_initialized; }
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
COnnxBrain::COnnxBrain() {
    m_model_handle = INVALID_HANDLE;
    m_initialized = false;
    m_model_path = "";
    m_scaler_path = "";
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
COnnxBrain::~COnnxBrain() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize ONNX Model                                             |
//+------------------------------------------------------------------+
bool COnnxBrain::Initialize(string modelPath, string scalerPath) {
    m_model_path = modelPath;
    m_scaler_path = scalerPath;
    
    // Check if model file exists
    if(!FileIsExist(modelPath, FILE_COMMON)) {
        Print("ONNX: Model file not found: ", modelPath);
        Print("ONNX: Running in fallback mode (no ML)");
        return false;
    }
    
    // Create ONNX session
    m_model_handle = OnnxCreate(modelPath, ONNX_DEFAULT);
    if(m_model_handle == INVALID_HANDLE) {
        Print("ONNX: Failed to create model session");
        return false;
    }
    
    // Pre-allocate buffers (100 bars × 15 features)
    ArrayResize(m_input, 1500);
    ArrayResize(m_output, 2);
    ArrayResize(m_means, 15);
    ArrayResize(m_stds, 15);
    
    // Load normalization parameters
    if(!LoadScalerParams()) {
        Print("ONNX: Warning - Scaler params not loaded, using defaults");
        // Set defaults (will be updated when scaler.json exists)
        ArrayInitialize(m_means, 0.0);
        ArrayInitialize(m_stds, 1.0);
    }
    
    m_initialized = true;
    Print("ONNX: Model initialized successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Load Scaler Parameters from JSON                                  |
//+------------------------------------------------------------------+
bool COnnxBrain::LoadScalerParams() {
    // TODO: Implement JSON parsing for scaler_params.json
    // For now, return false to use defaults
    return false;
}

//+------------------------------------------------------------------+
//| Collect Features for Inference                                    |
//+------------------------------------------------------------------+
bool COnnxBrain::CollectFeatures(double &features[]) {
    // TODO: Implement feature collection
    // Should match Python feature engineering exactly
    return false;
}

//+------------------------------------------------------------------+
//| Get Bullish Probability                                           |
//+------------------------------------------------------------------+
double COnnxBrain::GetBullishProbability() {
    if(!m_initialized) return 0.5;  // Neutral
    
    // Collect features
    double features[];
    if(!CollectFeatures(features)) {
        return 0.5;
    }
    
    // Normalize and copy to input buffer
    for(int i = 0; i < ArraySize(features); i++) {
        int feat_idx = i % 15;
        double normalized = (features[i] - m_means[feat_idx]) / m_stds[feat_idx];
        m_input[i] = (float)normalized;
    }
    
    // Run inference
    if(!OnnxRun(m_model_handle, ONNX_NO_CONVERSION, m_input, m_output)) {
        Print("ONNX: Inference failed");
        return 0.5;
    }
    
    return (double)m_output[1];  // P(bullish)
}

//+------------------------------------------------------------------+
//| Get Confidence for Signal Direction                               |
//+------------------------------------------------------------------+
double COnnxBrain::GetConfidence(int signalDirection) {
    double bullProb = GetBullishProbability();
    
    if(signalDirection > 0)  // Buy signal
        return bullProb;
    else if(signalDirection < 0)  // Sell signal
        return 1.0 - bullProb;
    else
        return 0.5;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                      |
//+------------------------------------------------------------------+
void COnnxBrain::Deinitialize() {
    if(m_model_handle != INVALID_HANDLE) {
        OnnxRelease(m_model_handle);
        m_model_handle = INVALID_HANDLE;
    }
    m_initialized = false;
    Print("ONNX: Model released");
}
