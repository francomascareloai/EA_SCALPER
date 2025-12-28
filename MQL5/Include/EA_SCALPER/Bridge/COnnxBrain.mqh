//+------------------------------------------------------------------+
//|                                                   COnnxBrain.mqh |
//|                           EA_SCALPER_XAUUSD - Singularity Edition |
//|                        ONNX Model Inference for ML Integration    |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD - Singularity Edition"
#property strict

#include "../Core/Definitions.mqh"

// === ONNX CONFIGURATION CONSTANTS ===
// These replace magic numbers throughout the file for maintainability
#define ONNX_CACHE_SECONDS           60     // Cache predictions for 60 seconds
#define ONNX_DIRECTION_EXTRA_BARS    100    // Extra bars needed for rolling calculations
#define ONNX_ATR_HISTORY_LOOKBACK    500    // ATR percentile calculation lookback
#define ONNX_MIN_HURST_WINDOW        20     // Minimum window for Hurst calculation
#define ONNX_ENTROPY_DEFAULT_BINS    10     // Default bins for Shannon entropy
#define ONNX_RETURNS_ARRAY_SIZE      99     // Size of returns array for entropy calc
#define ONNX_HURST_WINDOW_SIZE       100    // Window size for Hurst exponent
#define ONNX_MIN_ENTROPY_SAMPLES     10     // Minimum samples for entropy calculation

// === MODEL CONFIGURATION ===
// Primary direction model + scaler (files should live in MQL5/Files/Models/ for sandboxed MT5 access)
#define DIRECTION_MODEL_PATH    "Models\\direction_v2.onnx"
#define REGIME_MODEL_PATH       "Models\\regime_v2.onnx"
#define SCALER_PARAMS_PATH      "Models\\scaler_params_v2.json"

// Optional models (not yet delivered) — defined here to prevent compile errors when feature-gated
#ifndef VOLATILITY_MODEL_PATH
   #define VOLATILITY_MODEL_PATH "Models\\volatility_v1.onnx"
#endif
#ifndef VOLATILITY_SEQ_LEN
   #define VOLATILITY_SEQ_LEN    60
#endif
#ifndef VOLATILITY_FEATURES
   #define VOLATILITY_FEATURES   8
#endif

#ifndef FAKEOUT_MODEL_PATH
   #define FAKEOUT_MODEL_PATH    "Models\\fakeout_v1.onnx"
#endif
#ifndef FAKEOUT_SEQ_LEN
   #define FAKEOUT_SEQ_LEN       40
#endif
#ifndef FAKEOUT_FEATURES
   #define FAKEOUT_FEATURES      6
#endif

// Feature configuration - 13 features matching Python pipeline
#define DIRECTION_SEQ_LEN       100   // Sequence length for direction model
#define DIRECTION_FEATURES      13    // Number of features (updated from 15)
// Features: returns, log_returns, range_pct, rsi, atr_norm, ma_dist, bb_pos,
//           hurst, entropy, hour_sin, hour_cos, session, vol_regime

// === PREDICTION RESULT STRUCTURE ===
struct SDirectionPrediction
{
   double   prob_bullish;      // P(bullish)
   double   prob_bearish;      // P(bearish)
   bool     is_valid;          // Valid prediction flag
   datetime timestamp;         // Prediction timestamp
   
   ENUM_SIGNAL_TYPE GetSignal(double threshold = 0.65)
   {
      if(!is_valid) return SIGNAL_NONE;
      if(prob_bullish > threshold) return SIGNAL_BUY;
      if(prob_bearish > threshold) return SIGNAL_SELL;
      return SIGNAL_NONE;
   }
   
   double GetConfidence()
   {
      return MathMax(prob_bullish, prob_bearish);
   }
};

struct SVolatilityPrediction
{
   double   atr_forecast[5];   // ATR forecast for next 5 bars
   double   avg_forecast;      // Average ATR forecast
   bool     is_valid;
   datetime timestamp;
};

struct SFakeoutPrediction
{
   double   prob_fakeout;      // P(fakeout)
   double   prob_real;         // P(real breakout)
   bool     is_valid;
   datetime timestamp;
   
   bool IsFakeout(double threshold = 0.4)
   {
      return is_valid && prob_fakeout > threshold;
   }
};

// === NORMALIZATION PARAMETERS ===
struct SNormParams
{
   double   means[DIRECTION_FEATURES];
   double   stds[DIRECTION_FEATURES];
   bool     is_loaded;
};

// === ONNX BRAIN CLASS ===
class COnnxBrain
{
private:
   // Model handles
   long                 m_direction_handle;
   long                 m_volatility_handle;
   long                 m_fakeout_handle;
   
   // Model status
   bool                 m_direction_loaded;
   bool                 m_volatility_loaded;
   bool                 m_fakeout_loaded;
   
   // Normalization parameters
   SNormParams          m_norm_params;
   
   // Input/Output buffers
   float                m_direction_input[];
   float                m_direction_output[];
   float                m_volatility_input[];
   float                m_volatility_output[];
   float                m_fakeout_input[];
   float                m_fakeout_output[];
   
   // Cache
   SDirectionPrediction m_last_direction;
   SVolatilityPrediction m_last_volatility;
   SFakeoutPrediction   m_last_fakeout;
   datetime             m_last_update;
   int                  m_cache_seconds;
   
   // Feature calculation handles
   int                  m_rsi_handle_m5;
   int                  m_rsi_handle_m15;
   int                  m_rsi_handle_h1;
   int                  m_atr_handle;
   int                  m_ma_handle;
   int                  m_bb_upper_handle;
   int                  m_bb_mid_handle;
   int                  m_bb_lower_handle;
   
   // Internal methods
   bool                 LoadNormalizationParams(string json_path);
   string               ResolveModelPath(const string relative_path);
   bool                 CollectDirectionFeatures(float &features[]);
   bool                 CollectVolatilityFeatures(float &features[]);
   bool                 CollectFakeoutFeatures(float &features[]);
   double               NormalizeFeature(double value, int feature_idx);
   double               CalculateHurstExponent(const double &prices[], int window);
   double               CalculateShannonEntropy(const double &returns[], int bins);
   bool                 ParseNormArray(const string &content, const string key, double &target[]);

public:
   COnnxBrain();
   ~COnnxBrain();
   
   // Initialization
   bool                 Initialize();
   bool                 LoadDirectionModel(string path = DIRECTION_MODEL_PATH);
   bool                 LoadVolatilityModel(string path = VOLATILITY_MODEL_PATH);
   bool                 LoadFakeoutModel(string path = FAKEOUT_MODEL_PATH);
   void                 SetCacheTime(int seconds) { m_cache_seconds = seconds; }
   
   // Predictions
   SDirectionPrediction PredictDirection();
   SVolatilityPrediction PredictVolatility();
   SFakeoutPrediction   PredictFakeout(bool is_bullish_breakout);
   
   // Quick access methods
   double               GetBullishProbability();
   double               GetBearishProbability();
   ENUM_SIGNAL_TYPE     GetMLSignal(double threshold = 0.65);
   double               GetMLConfidence();
   bool                 IsFakeoutLikely(bool is_bullish_breakout, double threshold = 0.4);
   
   // Status
   bool                 IsDirectionModelLoaded() { return m_direction_loaded; }
   bool                 IsVolatilityModelLoaded() { return m_volatility_loaded; }
   bool                 IsFakeoutModelLoaded() { return m_fakeout_loaded; }
   bool                 HasAnyModel() { return m_direction_loaded || m_volatility_loaded || m_fakeout_loaded; }
   
   // Cleanup
   void                 Deinitialize();
};

// === IMPLEMENTATION ===

COnnxBrain::COnnxBrain()
{
   m_direction_handle = INVALID_HANDLE;
   m_volatility_handle = INVALID_HANDLE;
   m_fakeout_handle = INVALID_HANDLE;
   
   m_direction_loaded = false;
   m_volatility_loaded = false;
   m_fakeout_loaded = false;
   
   m_norm_params.is_loaded = false;
   m_cache_seconds = ONNX_CACHE_SECONDS; // Use named constant
   m_last_update = 0;
   
   // Initialize indicator handles
   m_rsi_handle_m5 = INVALID_HANDLE;
   m_rsi_handle_m15 = INVALID_HANDLE;
   m_rsi_handle_h1 = INVALID_HANDLE;
   m_atr_handle = INVALID_HANDLE;
   m_ma_handle = INVALID_HANDLE;
   m_bb_upper_handle = INVALID_HANDLE;
   m_bb_mid_handle = INVALID_HANDLE;
   m_bb_lower_handle = INVALID_HANDLE;
   
   // Pre-allocate buffers
   ArrayResize(m_direction_input, DIRECTION_SEQ_LEN * DIRECTION_FEATURES);
   ArrayResize(m_direction_output, 2);
   ArrayResize(m_volatility_input, VOLATILITY_SEQ_LEN * VOLATILITY_FEATURES);
   ArrayResize(m_volatility_output, 5);
   ArrayResize(m_fakeout_input, FAKEOUT_SEQ_LEN * FAKEOUT_FEATURES);
   ArrayResize(m_fakeout_output, 2);
   
   // Initialize default normalization (will be overwritten by LoadNormalizationParams)
   for(int i = 0; i < DIRECTION_FEATURES; i++)
   {
      m_norm_params.means[i] = 0.0;
      m_norm_params.stds[i] = 1.0;
   }
}

COnnxBrain::~COnnxBrain()
{
   Deinitialize();
}

bool COnnxBrain::Initialize()
{
   // Create indicator handles for feature calculation
   m_rsi_handle_m5 = iRSI(_Symbol, PERIOD_M5, 14, PRICE_CLOSE);
   m_rsi_handle_m15 = iRSI(_Symbol, PERIOD_M15, 14, PRICE_CLOSE);
   m_rsi_handle_h1 = iRSI(_Symbol, PERIOD_H1, 14, PRICE_CLOSE);
   m_atr_handle = iATR(_Symbol, PERIOD_M15, 14);
   m_ma_handle = iMA(_Symbol, PERIOD_M15, 20, 0, MODE_SMA, PRICE_CLOSE);
   m_bb_upper_handle = iBands(_Symbol, PERIOD_M15, 20, 0, 2.0, PRICE_CLOSE);
   
   if(m_rsi_handle_m5 == INVALID_HANDLE || m_rsi_handle_m15 == INVALID_HANDLE ||
      m_rsi_handle_h1 == INVALID_HANDLE || m_atr_handle == INVALID_HANDLE ||
      m_ma_handle == INVALID_HANDLE || m_bb_upper_handle == INVALID_HANDLE)
   {
      Print("COnnxBrain: Failed to create indicator handles");
      return false;
   }
   
   // Load normalization parameters
   if(!LoadNormalizationParams(SCALER_PARAMS_PATH))
   {
      Print("COnnxBrain: Warning - Using default normalization parameters");
   }
   
   // Try to load models (non-fatal if missing)
   LoadDirectionModel();
   LoadVolatilityModel();
   LoadFakeoutModel();
   
   Print("COnnxBrain: Initialized. Direction: ", m_direction_loaded ? "OK" : "Not loaded",
         ", Volatility: ", m_volatility_loaded ? "OK" : "Not loaded",
         ", Fakeout: ", m_fakeout_loaded ? "OK" : "Not loaded");
   
   return true;
}

bool COnnxBrain::LoadDirectionModel(string path)
{
   if(m_direction_handle != INVALID_HANDLE)
   {
      OnnxRelease(m_direction_handle);
      m_direction_handle = INVALID_HANDLE;
   }
   
   string resolved = ResolveModelPath(path);
   m_direction_handle = OnnxCreate(resolved, ONNX_DEFAULT);
   if(m_direction_handle == INVALID_HANDLE)
   {
      Print("COnnxBrain: Failed to load direction model from ", resolved);
      m_direction_loaded = false;
      return false;
   }
   
   // Set input shape [batch, sequence, features]
   long input_shape[] = {1, DIRECTION_SEQ_LEN, DIRECTION_FEATURES};
   if(!OnnxSetInputShape(m_direction_handle, 0, input_shape))
   {
      Print("COnnxBrain: Failed to set direction model input shape");
      OnnxRelease(m_direction_handle);
      m_direction_handle = INVALID_HANDLE;
      m_direction_loaded = false;
      return false;
   }
   
   m_direction_loaded = true;
   Print("COnnxBrain: Direction model loaded successfully");
   return true;
}

bool COnnxBrain::LoadVolatilityModel(string path)
{
   if(m_volatility_handle != INVALID_HANDLE)
   {
      OnnxRelease(m_volatility_handle);
      m_volatility_handle = INVALID_HANDLE;
   }
   
   string resolved = ResolveModelPath(path);
   m_volatility_handle = OnnxCreate(resolved, ONNX_DEFAULT);
   if(m_volatility_handle == INVALID_HANDLE)
   {
      m_volatility_loaded = false;
      return false;
   }
   
   long input_shape[] = {1, VOLATILITY_SEQ_LEN, VOLATILITY_FEATURES};
   if(!OnnxSetInputShape(m_volatility_handle, 0, input_shape))
   {
      OnnxRelease(m_volatility_handle);
      m_volatility_handle = INVALID_HANDLE;
      m_volatility_loaded = false;
      return false;
   }
   
   m_volatility_loaded = true;
   Print("COnnxBrain: Volatility model loaded successfully");
   return true;
}

bool COnnxBrain::LoadFakeoutModel(string path)
{
   if(m_fakeout_handle != INVALID_HANDLE)
   {
      OnnxRelease(m_fakeout_handle);
      m_fakeout_handle = INVALID_HANDLE;
   }
   
   string resolved = ResolveModelPath(path);
   m_fakeout_handle = OnnxCreate(resolved, ONNX_DEFAULT);
   if(m_fakeout_handle == INVALID_HANDLE)
   {
      m_fakeout_loaded = false;
      return false;
   }
   
   long input_shape[] = {1, FAKEOUT_SEQ_LEN, FAKEOUT_FEATURES};
   if(!OnnxSetInputShape(m_fakeout_handle, 0, input_shape))
   {
      OnnxRelease(m_fakeout_handle);
      m_fakeout_handle = INVALID_HANDLE;
      m_fakeout_loaded = false;
      return false;
   }
   
   m_fakeout_loaded = true;
   Print("COnnxBrain: Fakeout model loaded successfully");
   return true;
}

bool COnnxBrain::LoadNormalizationParams(string json_path)
{
   // Try to read scaler parameters from JSON file
   // Format: {"means": [...], "stds": [...]}
   
   string resolved = ResolveModelPath(json_path);
   int file = FileOpen(resolved, FILE_READ | FILE_TXT | FILE_ANSI);
   if(file == INVALID_HANDLE)
   {
      Print("COnnxBrain: Scaler params file not found: ", resolved);
      return false;
   }
   
   string content = "";
   while(!FileIsEnding(file))
   {
      string line = FileReadString(file);
      if(content == "")
         content = line;
      else
         content += " " + line; // preserve spacing to allow simple parsing
   }
   FileClose(file);
   
   // Parse means/stds; fall back to defaults if parsing fails
   bool ok_means = ParseNormArray(content, "\"means\"", m_norm_params.means);
   bool ok_stds  = ParseNormArray(content, "\"stds\"",  m_norm_params.stds);
   
   m_norm_params.is_loaded = ok_means && ok_stds;
   if(m_norm_params.is_loaded)
   {
      Print("COnnxBrain: Loaded normalization parameters from ", json_path);
      return true;
   }
   
   Print("COnnxBrain: Using default normalization parameters");
   return false;
}

//+------------------------------------------------------------------+
//| Resolve model/scaler path with fallbacks                         |
//+------------------------------------------------------------------+
string COnnxBrain::ResolveModelPath(const string relative_path)
{
   // 1) Preferred: MQL5/Files/ relative path (Tester/Live safe)
   string files_base = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Files\\";
   string candidate = files_base + relative_path;
   if(FileIsExist(candidate)) return candidate;

   // 2) Fallback: relative to working directory (e.g., MQL5/Models in repo)
   if(FileIsExist(relative_path)) return relative_path;

   // 3) Fallback: Experts folder sibling (common when running from source tree)
   string expert_base = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Experts\\" + relative_path;
   if(FileIsExist(expert_base)) return expert_base;

   // 4) Last resort: return requested path (OnnxCreate may still handle it)
   return relative_path;
}

double COnnxBrain::NormalizeFeature(double value, int feature_idx)
{
   if(feature_idx < 0 || feature_idx >= DIRECTION_FEATURES) return value;
   if(m_norm_params.stds[feature_idx] == 0) return 0;
   
   return (value - m_norm_params.means[feature_idx]) / m_norm_params.stds[feature_idx];
}

bool COnnxBrain::CollectDirectionFeatures(float &features[])
{
   // Get price data (need extra bars for ATR rolling window)
   MqlRates rates[];
   int bars_needed = DIRECTION_SEQ_LEN + ONNX_DIRECTION_EXTRA_BARS; // Extra for rolling calculations
   if(CopyRates(_Symbol, PERIOD_M15, 0, bars_needed, rates) < DIRECTION_SEQ_LEN + ONNX_MIN_HURST_WINDOW)
      return false;
   ArraySetAsSeries(rates, true);

   // Get indicator values
   double rsi[], atr[], ma[];
   double bb_upper[], bb_mid[], bb_lower[];

   if(CopyBuffer(m_rsi_handle_m15, 0, 0, DIRECTION_SEQ_LEN + ONNX_MIN_HURST_WINDOW, rsi) <= 0) return false;
   if(CopyBuffer(m_atr_handle, 0, 0, DIRECTION_SEQ_LEN + ONNX_ATR_HISTORY_LOOKBACK, atr) <= 0) return false;
   if(CopyBuffer(m_ma_handle, 0, 0, DIRECTION_SEQ_LEN + ONNX_MIN_HURST_WINDOW, ma) <= 0) return false;
   if(CopyBuffer(m_bb_upper_handle, 1, 0, DIRECTION_SEQ_LEN + ONNX_MIN_HURST_WINDOW, bb_upper) <= 0) return false;
   if(CopyBuffer(m_bb_upper_handle, 0, 0, DIRECTION_SEQ_LEN + ONNX_MIN_HURST_WINDOW, bb_mid) <= 0) return false;
   if(CopyBuffer(m_bb_upper_handle, 2, 0, DIRECTION_SEQ_LEN + ONNX_MIN_HURST_WINDOW, bb_lower) <= 0) return false;
   
   ArraySetAsSeries(rsi, true);
   ArraySetAsSeries(atr, true);
   ArraySetAsSeries(ma, true);
   ArraySetAsSeries(bb_upper, true);
   ArraySetAsSeries(bb_mid, true);
   ArraySetAsSeries(bb_lower, true);
   
   // Calculate Hurst Exponent (using last ONNX_HURST_WINDOW_SIZE prices)
   double prices[];
   ArrayResize(prices, ONNX_HURST_WINDOW_SIZE);
   for(int i = 0; i < ONNX_HURST_WINDOW_SIZE; i++)
      prices[i] = rates[i].close;
   double hurst = CalculateHurstExponent(prices, ONNX_HURST_WINDOW_SIZE);

   // Calculate Shannon Entropy (using last ONNX_RETURNS_ARRAY_SIZE returns)
   double rets_arr[];
   ArrayResize(rets_arr, ONNX_RETURNS_ARRAY_SIZE);
   for(int i = 0; i < ONNX_RETURNS_ARRAY_SIZE; i++)
   {
      if(rates[i+1].close > 0)
         rets_arr[i] = (rates[i].close - rates[i+1].close) / rates[i+1].close;
      else
         rets_arr[i] = 0;
   }
   double entropy = CalculateShannonEntropy(rets_arr, ONNX_ENTROPY_DEFAULT_BINS);

   // Calculate volatility regime (ATR percentile over last ONNX_ATR_HISTORY_LOOKBACK bars)
   double atr_min = atr[0], atr_max = atr[0];
   int atr_count = MathMin(ONNX_ATR_HISTORY_LOOKBACK, ArraySize(atr));
   for(int i = 1; i < atr_count; i++)
   {
      if(atr[i] < atr_min) atr_min = atr[i];
      if(atr[i] > atr_max) atr_max = atr[i];
   }
   double vol_regime = (atr_max > atr_min) ? (atr[0] - atr_min) / (atr_max - atr_min) : 0.5;
   
   // Fill feature array (oldest to newest) - 13 features per bar
   // Features: returns, log_returns, range_pct, rsi, atr_norm, ma_dist, bb_pos,
   //           hurst, entropy, hour_sin, hour_cos, session, vol_regime
   
   for(int i = DIRECTION_SEQ_LEN - 1; i >= 0; i--)
   {
      int base_idx = (DIRECTION_SEQ_LEN - 1 - i) * DIRECTION_FEATURES;
      
      // Feature 0: returns
      double ret = (i < DIRECTION_SEQ_LEN - 1 && rates[i+1].close > 0) ? 
                   (rates[i].close - rates[i+1].close) / rates[i+1].close : 0;
      
      // Feature 1: log_returns
      double log_ret = (i < DIRECTION_SEQ_LEN - 1 && rates[i+1].close > 0) ? 
                       MathLog(rates[i].close / rates[i+1].close) : 0;
      
      // Feature 2: range_pct
      double range_pct = (rates[i].close > 0) ? 
                         (rates[i].high - rates[i].low) / rates[i].close : 0;
      
      // Feature 3: rsi (normalized to 0-1)
      double rsi_val = (i < ArraySize(rsi)) ? rsi[i] / 100.0 : 0.5;
      
      // Feature 4: atr_norm
      double atr_norm = (i < ArraySize(atr) && rates[i].close > 0) ? 
                        atr[i] / rates[i].close : 0;
      
      // Feature 5: ma_dist
      double ma_dist = (i < ArraySize(ma) && ma[i] > 0) ? 
                       (rates[i].close - ma[i]) / ma[i] : 0;
      
      // Feature 6: bb_pos
      double bb_std = (i < ArraySize(bb_upper)) ? (bb_upper[i] - bb_mid[i]) / 2.0 : 1.0;
      double bb_pos = (bb_std > 0) ? (rates[i].close - bb_mid[i]) / (2.0 * bb_std) : 0;
      
      // Feature 7: hurst (same for all bars in sequence - calculated once)
      double hurst_val = hurst;
      
      // Feature 8: entropy (same for all bars in sequence)
      double entropy_val = entropy;
      
      // Time-based features (use bar time)
      MqlDateTime dt;
      TimeToStruct(rates[i].time, dt);
      
      // Feature 9: hour_sin
      double hour_sin = MathSin(2.0 * M_PI * dt.hour / 24.0);
      
      // Feature 10: hour_cos
      double hour_cos = MathCos(2.0 * M_PI * dt.hour / 24.0);
      
      // Feature 11: session (normalized to 0-1)
      double session = (dt.hour < 7) ? 0.0 : ((dt.hour < 15) ? 0.5 : 1.0);
      
      // Feature 12: vol_regime
      double vol_reg = vol_regime;
      
      // Apply normalization and store (using loaded scaler params)
      features[base_idx + 0] = (float)NormalizeFeature(ret, 0);
      features[base_idx + 1] = (float)NormalizeFeature(log_ret, 1);
      features[base_idx + 2] = (float)NormalizeFeature(range_pct, 2);
      features[base_idx + 3] = (float)NormalizeFeature(rsi_val, 3);
      features[base_idx + 4] = (float)NormalizeFeature(atr_norm, 4);
      features[base_idx + 5] = (float)NormalizeFeature(ma_dist, 5);
      features[base_idx + 6] = (float)NormalizeFeature(bb_pos, 6);
      features[base_idx + 7] = (float)NormalizeFeature(hurst_val, 7);
      features[base_idx + 8] = (float)NormalizeFeature(entropy_val, 8);
      features[base_idx + 9] = (float)NormalizeFeature(hour_sin, 9);
      features[base_idx + 10] = (float)NormalizeFeature(hour_cos, 10);
      features[base_idx + 11] = (float)NormalizeFeature(session, 11);
      features[base_idx + 12] = (float)NormalizeFeature(vol_reg, 12);
   }
   
   return true;
}

SDirectionPrediction COnnxBrain::PredictDirection()
{
   SDirectionPrediction result;
   result.is_valid = false;
   result.prob_bullish = 0.5;
   result.prob_bearish = 0.5;
   result.timestamp = TimeCurrent();
   
   // Check cache
   if(TimeCurrent() - m_last_update < m_cache_seconds && m_last_direction.is_valid)
      return m_last_direction;
   
   if(!m_direction_loaded)
   {
      Print("COnnxBrain: Direction model not loaded");
      return result;
   }
   
   // Collect features
   if(!CollectDirectionFeatures(m_direction_input))
   {
      Print("COnnxBrain: Failed to collect features");
      return result;
   }
   
   // Run inference
   if(!OnnxRun(m_direction_handle, ONNX_NO_CONVERSION, m_direction_input, m_direction_output))
   {
      Print("COnnxBrain: Inference failed - ", GetLastError());
      return result;
   }
   
   // Parse output [P(bearish), P(bullish)]
   result.prob_bearish = (double)m_direction_output[0];
   result.prob_bullish = (double)m_direction_output[1];
   result.is_valid = true;
   result.timestamp = TimeCurrent();
   
   // Update cache
   m_last_direction = result;
   m_last_update = TimeCurrent();
   
   return result;
}

double COnnxBrain::GetBullishProbability()
{
   SDirectionPrediction pred = PredictDirection();
   return pred.prob_bullish;
}

double COnnxBrain::GetBearishProbability()
{
   SDirectionPrediction pred = PredictDirection();
   return pred.prob_bearish;
}

ENUM_SIGNAL_TYPE COnnxBrain::GetMLSignal(double threshold)
{
   SDirectionPrediction pred = PredictDirection();
   return pred.GetSignal(threshold);
}

double COnnxBrain::GetMLConfidence()
{
   SDirectionPrediction pred = PredictDirection();
   return pred.GetConfidence();
}

SVolatilityPrediction COnnxBrain::PredictVolatility()
{
   SVolatilityPrediction result;
   result.is_valid = false;
   result.avg_forecast = 0;
   result.timestamp = TimeCurrent();
   
   if(!m_volatility_loaded) return result;
   
   // Simplified: return current ATR as forecast
   double atr[];
   if(CopyBuffer(m_atr_handle, 0, 0, 1, atr) > 0)
   {
      for(int i = 0; i < 5; i++)
         result.atr_forecast[i] = atr[0];
      result.avg_forecast = atr[0];
      result.is_valid = true;
   }
   
   return result;
}

SFakeoutPrediction COnnxBrain::PredictFakeout(bool is_bullish_breakout)
{
   SFakeoutPrediction result;
   result.is_valid = false;
   result.prob_fakeout = 0.5;
   result.prob_real = 0.5;
   result.timestamp = TimeCurrent();
   
   if(!m_fakeout_loaded) return result;
   
   // Placeholder - would need proper implementation
   result.is_valid = true;
   result.prob_fakeout = 0.3;
   result.prob_real = 0.7;
   
   return result;
}

bool COnnxBrain::IsFakeoutLikely(bool is_bullish_breakout, double threshold)
{
   SFakeoutPrediction pred = PredictFakeout(is_bullish_breakout);
   return pred.IsFakeout(threshold);
}

double COnnxBrain::CalculateHurstExponent(const double &prices[], int window)
{
   if(window < ONNX_MIN_HURST_WINDOW) return 0.5;
   
   // Simplified R/S analysis
   double returns[];
   ArrayResize(returns, window - 1);
   
   for(int i = 0; i < window - 1; i++)
   {
      if(prices[i+1] > 0)
         returns[i] = MathLog(prices[i] / prices[i+1]);
      else
         returns[i] = 0;
   }
   
   // Calculate mean
   double mean = 0;
   for(int i = 0; i < window - 1; i++)
      mean += returns[i];
   mean /= (window - 1);
   
   // Calculate cumulative deviations
   double cumdev[];
   ArrayResize(cumdev, window - 1);
   cumdev[0] = returns[0] - mean;
   for(int i = 1; i < window - 1; i++)
      cumdev[i] = cumdev[i-1] + (returns[i] - mean);
   
   // Calculate R (range)
   double R = cumdev[0];
   double max_cd = cumdev[0], min_cd = cumdev[0];
   for(int i = 1; i < window - 1; i++)
   {
      if(cumdev[i] > max_cd) max_cd = cumdev[i];
      if(cumdev[i] < min_cd) min_cd = cumdev[i];
   }
   R = max_cd - min_cd;
   
   // Calculate S (standard deviation)
   double S = 0;
   for(int i = 0; i < window - 1; i++)
      S += MathPow(returns[i] - mean, 2);
   S = MathSqrt(S / (window - 2));
   
   if(S <= 0) return 0.5;
   
   // R/S ratio and estimate H
   double RS = R / S;
   double H = MathLog(RS) / MathLog(window);
   
   return MathMax(0.0, MathMin(1.0, H));
}

double COnnxBrain::CalculateShannonEntropy(const double &returns[], int bins)
{
   int n = ArraySize(returns);
   if(n < ONNX_MIN_ENTROPY_SAMPLES) return 0;
   
   // Find min/max for binning
   double min_ret = returns[0], max_ret = returns[0];
   for(int i = 1; i < n; i++)
   {
      if(returns[i] < min_ret) min_ret = returns[i];
      if(returns[i] > max_ret) max_ret = returns[i];
   }
   
   double range = max_ret - min_ret;
   if(range <= 0) return 0;
   
   double bin_width = range / bins;
   
   // Count frequencies
   int counts[];
   ArrayResize(counts, bins);
   ArrayInitialize(counts, 0);
   
   for(int i = 0; i < n; i++)
   {
      int bin = (int)((returns[i] - min_ret) / bin_width);
      if(bin >= bins) bin = bins - 1;
      counts[bin]++;
   }
   
   // Calculate entropy
   double entropy = 0;
   for(int i = 0; i < bins; i++)
   {
      if(counts[i] > 0)
      {
         double p = (double)counts[i] / n;
         entropy -= p * MathLog(p) / MathLog(2);
      }
   }
   
   return entropy;
}

//+------------------------------------------------------------------+
//| Helper: Parse numeric array from simple JSON                     |
//+------------------------------------------------------------------+
bool COnnxBrain::ParseNormArray(const string &content, const string key, double &target[])
{
   // Find key
   int key_pos = StringFind(content, key);
   if(key_pos < 0) return false;
   
   int start = StringFind(content, "[", key_pos);
   int end = StringFind(content, "]", start);
   if(start < 0 || end < 0 || end <= start) return false;
   
   string slice = StringSubstr(content, start + 1, end - start - 1);
   string parts[];
   int count = StringSplit(slice, ',', parts);
   if(count < DIRECTION_FEATURES) return false;
   
   ArrayInitialize(target, 0.0);
   for(int i = 0; i < DIRECTION_FEATURES && i < count; i++)
   {
      string trimmed = parts[i];
      StringTrimLeft(trimmed);
      StringTrimRight(trimmed);
      target[i] = StringToDouble(trimmed);
   }
   return true;
}

bool COnnxBrain::CollectVolatilityFeatures(float &features[])
{
   // Placeholder
   return false;
}

bool COnnxBrain::CollectFakeoutFeatures(float &features[])
{
   // Placeholder
   return false;
}

void COnnxBrain::Deinitialize()
{
   if(m_direction_handle != INVALID_HANDLE)
   {
      OnnxRelease(m_direction_handle);
      m_direction_handle = INVALID_HANDLE;
   }
   
   if(m_volatility_handle != INVALID_HANDLE)
   {
      OnnxRelease(m_volatility_handle);
      m_volatility_handle = INVALID_HANDLE;
   }
   
   if(m_fakeout_handle != INVALID_HANDLE)
   {
      OnnxRelease(m_fakeout_handle);
      m_fakeout_handle = INVALID_HANDLE;
   }
   
   // Release indicator handles
   if(m_rsi_handle_m5 != INVALID_HANDLE) IndicatorRelease(m_rsi_handle_m5);
   if(m_rsi_handle_m15 != INVALID_HANDLE) IndicatorRelease(m_rsi_handle_m15);
   if(m_rsi_handle_h1 != INVALID_HANDLE) IndicatorRelease(m_rsi_handle_h1);
   if(m_atr_handle != INVALID_HANDLE) IndicatorRelease(m_atr_handle);
   if(m_ma_handle != INVALID_HANDLE) IndicatorRelease(m_ma_handle);
   if(m_bb_upper_handle != INVALID_HANDLE) IndicatorRelease(m_bb_upper_handle);
   
   m_direction_loaded = false;
   m_volatility_loaded = false;
   m_fakeout_loaded = false;
   
   Print("COnnxBrain: Deinitialized");
}
