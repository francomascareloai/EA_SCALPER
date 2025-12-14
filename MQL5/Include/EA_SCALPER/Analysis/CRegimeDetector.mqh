//+------------------------------------------------------------------+
//|                                             CRegimeDetector.mqh |
//|                           EA_SCALPER_XAUUSD - Singularity Edition |
//|     v4.0 GENIUS: Hurst + Entropy + VR + Multiscale + Transition |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD - Singularity Edition"
#property strict

// === REGIME ENUMERATIONS ===
enum ENUM_MARKET_REGIME
{
   REGIME_PRIME_TRENDING = 0,    // H > 0.55, S < 1.5, VR confirms - Full confidence
   REGIME_NOISY_TRENDING = 1,    // H > 0.55, S >= 1.5 - Trending with noise
   REGIME_PRIME_REVERTING = 2,   // H < 0.45, S < 1.5, VR confirms - Full confidence
   REGIME_NOISY_REVERTING = 3,   // H < 0.45, S >= 1.5 - Mean revert with noise
   REGIME_RANDOM_WALK = 4,       // 0.45 <= H <= 0.55 OR VR ≈ 1 - NO TRADE
   REGIME_TRANSITIONING = 5,     // v4.0: High transition probability - CAUTION
   REGIME_UNKNOWN = 6            // Insufficient data
};

enum ENUM_KALMAN_TREND
{
   KALMAN_BULLISH = 0,
   KALMAN_BEARISH = 1,
   KALMAN_NEUTRAL = 2
};

// === v4.0: REGIME ANALYSIS RESULT STRUCTURE (ENHANCED) ===
struct SRegimeAnalysis
{
   ENUM_MARKET_REGIME regime;
   
   // Core metrics
   double             hurst_exponent;       // Primary Hurst (R/S method)
   double             shannon_entropy;
   double             variance_ratio;       // v4.0: Lo-MacKinlay VR test
   
   // v4.0: Multi-scale Hurst (ROBUSTNESS)
   double             hurst_short;          // 50-bar window
   double             hurst_medium;         // 100-bar window  
   double             hurst_long;           // 200-bar window
   double             multiscale_agreement; // 0-100: How well scales agree
   
   // v4.0: Regime Transition Detection (PREDICTIVE)
   double             transition_probability; // 0-1: Likelihood of regime change
   int                bars_in_regime;         // How long in current regime
   double             regime_velocity;        // dH/dt: Rate of Hurst change
   ENUM_MARKET_REGIME previous_regime;        // For transition tracking
   
   // Kalman (unchanged)
   double             kalman_trend_velocity;
   ENUM_KALMAN_TREND  kalman_trend;
   
   // v4.0: ENHANCED outputs
   double             size_multiplier;     // 0.0 to 1.0 (now adaptive)
   int                score_adjustment;    // -50 to +20 (expanded range)
   double             confidence;          // 0-100 (COMPOSITE - 5 factors)
   
   datetime           calculation_time;
   bool               is_valid;
   
   // v4.0: Diagnostic string
   string             diagnosis;           // Human-readable regime explanation
};

// === KALMAN FILTER STATE ===
struct SKalmanState
{
   double x;           // Estimated price
   double P;           // Error covariance
   double velocity;    // Price velocity
};

// === v4.1: ENTRY MODE FOR REGIME-ADAPTIVE STRATEGY ===
enum ENUM_ENTRY_MODE
{
   ENTRY_MODE_BREAKOUT = 0,      // Breakout/momentum entries (trending)
   ENTRY_MODE_PULLBACK = 1,      // Pullback entries (noisy trending)
   ENTRY_MODE_MEAN_REVERT = 2,   // Mean reversion at extremes (reverting)
   ENTRY_MODE_CONFIRMATION = 3,  // Extra confirmation required (transitioning)
   ENTRY_MODE_DISABLED = 4       // No entries allowed (random/unknown)
};

// === v4.1: REGIME-ADAPTIVE STRATEGY PARAMETERS ===
// This struct contains optimal trading parameters for each regime
// Philosophy: Different market conditions require fundamentally different strategies
struct SRegimeStrategy
{
   ENUM_MARKET_REGIME regime;           // Which regime this strategy is for
   ENUM_ENTRY_MODE    entry_mode;       // Preferred entry style
   
   // === ENTRY FILTERS ===
   double             min_confluence;    // Minimum confluence score (65-90)
   int                confirmation_bars; // Extra bars to wait for confirmation
   
   // === RISK PARAMETERS ===
   double             risk_percent;      // Risk per trade (0.25% - 1.0%)
   double             sl_atr_mult;       // Stop loss = ATR × this (1.5 - 2.5)
   double             min_rr;            // Minimum R:R to accept trade
   
   // === TAKE PROFIT LEVELS ===
   double             tp1_r;             // First TP in R-multiple (0.5 - 1.0)
   double             tp2_r;             // Second TP in R-multiple (1.0 - 2.5)
   double             tp3_r;             // Final TP in R-multiple (1.5 - 4.0)
   double             partial1_pct;      // % to close at TP1 (0.33 - 0.70)
   double             partial2_pct;      // % to close at TP2 (0.20 - 0.35)
   
   // === TRADE MANAGEMENT ===
   double             be_trigger_r;      // Move to breakeven at this R (0.3 - 1.0)
   bool               use_trailing;      // Enable trailing stop
   double             trailing_start_r;  // Start trailing at this R (1.0 - 1.5)
   double             trailing_step_atr; // Trailing step in ATR mult (0.5 - 0.7)
   
   // === TIME MANAGEMENT ===
   bool               use_time_exit;     // Exit if trade takes too long
   int                max_bars;          // Maximum bars to hold (10 - 100)
   
   // === STRATEGY DESCRIPTION ===
   string             philosophy;        // One-line description of approach
   
   // Default constructor - initializes to safe values
   void Reset()
   {
      regime = REGIME_UNKNOWN;
      entry_mode = ENTRY_MODE_DISABLED;
      min_confluence = 100;      // Block all trades by default
      confirmation_bars = 0;
      risk_percent = 0;
      sl_atr_mult = 2.0;
      min_rr = 1.0;
      tp1_r = 1.0;
      tp2_r = 2.0;
      tp3_r = 3.0;
      partial1_pct = 0.33;
      partial2_pct = 0.33;
      be_trigger_r = 1.0;
      use_trailing = false;
      trailing_start_r = 0;
      trailing_step_atr = 0;
      use_time_exit = false;
      max_bars = 50;
      philosophy = "Disabled";
   }
};

// === v4.0: HURST HISTORY FOR TRANSITION DETECTION ===
#define HURST_HISTORY_SIZE 10

// === REGIME DETECTOR CLASS v4.0 - GENIUS EDITION ===
class CRegimeDetector
{
private:
   // Calculation parameters
   int                 m_hurst_window;         // Primary window (default 100)
   int                 m_hurst_short_window;   // v4.0: Short window (50)
   int                 m_hurst_long_window;    // v4.0: Long window (200)
   int                 m_entropy_window;       // Window for Entropy (100)
   int                 m_entropy_bins;         // Number of bins (10)
   int                 m_min_samples;          // Minimum samples (50)
   int                 m_vr_lag;               // v4.0: Variance ratio lag (2)
   
   // Thresholds
   double              m_hurst_trending;       // H > this = trending (0.55)
   double              m_hurst_reverting;      // H < this = mean reverting (0.45)
   double              m_entropy_low;          // S < this = low noise (1.5)
   double              m_vr_trending;          // v4.0: VR > this = trending (1.1)
   double              m_vr_reverting;         // v4.0: VR < this = reverting (0.9)
   double              m_transition_threshold; // v4.0: Prob > this = transitioning (0.6)
   
   // Kalman filter parameters
   double              m_kalman_Q;
   double              m_kalman_R;
   double              m_kalman_velocity_threshold;
   SKalmanState        m_kalman_state;
   
   // Cache
   SRegimeAnalysis     m_last_analysis;
   datetime            m_last_calculation;
   int                 m_cache_seconds;
   
   // v4.0: Hurst history for transition detection
   double              m_hurst_history[HURST_HISTORY_SIZE];
   int                 m_hurst_history_idx;
   int                 m_bars_in_current_regime;
   ENUM_MARKET_REGIME  m_previous_regime;
   
   // Data buffers
   double              m_prices[];
   double              m_returns[];
   
public:
   CRegimeDetector();
   ~CRegimeDetector();
   
   // Configuration
   void SetHurstWindow(int window) { m_hurst_window = MathMax(20, window); }
   void SetEntropyWindow(int window) { m_entropy_window = MathMax(20, window); }
   void SetEntropyBins(int bins) { m_entropy_bins = MathMax(5, bins); }
   void SetThresholds(double trending, double reverting, double low_entropy);
   void SetKalmanParams(double Q, double R, double velocity_threshold);
   void SetCacheSeconds(int seconds) { m_cache_seconds = seconds; }
   void SetVRLag(int lag) { m_vr_lag = MathMax(2, lag); }
   void SetTransitionThreshold(double thresh) { m_transition_threshold = thresh; }
   
   // Main analysis
   SRegimeAnalysis AnalyzeRegime(string symbol = "", int tf = 0);
   SRegimeAnalysis GetLastAnalysis() { return m_last_analysis; }
   
   // Individual calculations
   double CalculateHurst(const double &prices[], int window);
   double CalculateEntropy(const double &returns[]);
   double CalculateVarianceRatio(const double &prices[], int lag);
   SKalmanState UpdateKalman(double measurement);
   ENUM_KALMAN_TREND GetKalmanTrend(const double &prices[], int lookback = 5);
   
   // v4.0: Multi-scale and transition calculations
   double CalculateMultiscaleAgreement(double h_short, double h_medium, double h_long);
   double CalculateTransitionProbability();
   double CalculateRegimeVelocity();
   double CalculateEnhancedConfidence(const SRegimeAnalysis &analysis);
   
   // Regime classification
   ENUM_MARKET_REGIME ClassifyRegime(const SRegimeAnalysis &analysis);
   double GetSizeMultiplier(const SRegimeAnalysis &analysis);
   int GetScoreAdjustment(const SRegimeAnalysis &analysis);
   
   // v4.1: Regime-Adaptive Strategy (GENIUS)
   SRegimeStrategy GetOptimalStrategy(ENUM_MARKET_REGIME regime);
   SRegimeStrategy GetCurrentStrategy() { return GetOptimalStrategy(m_last_analysis.regime); }
   string StrategyToString(const SRegimeStrategy &strategy);
   
   // Utility
   bool IsRandomWalk() { return m_last_analysis.regime == REGIME_RANDOM_WALK; }
   bool IsTransitioning() { return m_last_analysis.regime == REGIME_TRANSITIONING; }
   bool IsTradingAllowed();
   string RegimeToString(ENUM_MARKET_REGIME regime);
   string BuildDiagnosis(const SRegimeAnalysis &analysis);
   void ResetKalman() { m_kalman_state.x = 0; m_kalman_state.P = 1.0; m_kalman_state.velocity = 0; }
   
private:
   bool LoadPriceData(string symbol, int tf, int count);
   void CalculateReturns();
   void UpdateHurstHistory(double hurst);
   int ClassifyHurstZone(double hurst);
};

// === CONSTRUCTOR ===
CRegimeDetector::CRegimeDetector()
{
   // Default parameters optimized for XAUUSD M15
   m_hurst_window = 100;
   m_hurst_short_window = 50;
   m_hurst_long_window = 200;
   m_entropy_window = 100;
   m_entropy_bins = 10;
   m_min_samples = 50;
   m_vr_lag = 2;
   
   // Thresholds from Blueprint
   m_hurst_trending = 0.55;
   m_hurst_reverting = 0.45;
   m_entropy_low = 1.5;
   m_vr_trending = 1.10;
   m_vr_reverting = 0.90;
   m_transition_threshold = 0.60;
   
   // Kalman parameters
   m_kalman_Q = 0.01;
   m_kalman_R = 1.0;
   m_kalman_velocity_threshold = 0.1;
   m_kalman_state.x = 0;
   m_kalman_state.P = 1.0;
   m_kalman_state.velocity = 0;
   
   // Cache
   m_cache_seconds = 60;
   m_last_calculation = 0;
   
   // v4.0: Transition tracking
   ArrayInitialize(m_hurst_history, 0.5);
   m_hurst_history_idx = 0;
   m_bars_in_current_regime = 0;
   m_previous_regime = REGIME_UNKNOWN;
   
   // Initialize last analysis
   ZeroMemory(m_last_analysis);
   m_last_analysis.regime = REGIME_UNKNOWN;
   m_last_analysis.is_valid = false;
}

CRegimeDetector::~CRegimeDetector()
{
   ArrayFree(m_prices);
   ArrayFree(m_returns);
}

// === CONFIGURATION METHODS ===
void CRegimeDetector::SetThresholds(double trending, double reverting, double low_entropy)
{
   m_hurst_trending = trending;
   m_hurst_reverting = reverting;
   m_entropy_low = low_entropy;
}

void CRegimeDetector::SetKalmanParams(double Q, double R, double velocity_threshold)
{
   m_kalman_Q = Q;
   m_kalman_R = R;
   m_kalman_velocity_threshold = velocity_threshold;
}

// === MAIN ANALYSIS v4.0 ===
SRegimeAnalysis CRegimeDetector::AnalyzeRegime(string symbol, int tf)
{
   // Check cache
   if(TimeCurrent() - m_last_calculation < m_cache_seconds && m_last_analysis.is_valid)
      return m_last_analysis;
   
   SRegimeAnalysis result;
   ZeroMemory(result);
   result.regime = REGIME_UNKNOWN;
   result.is_valid = false;
   result.previous_regime = m_previous_regime;
   
   // Use current symbol if not specified
   if(symbol == "") symbol = _Symbol;
   
   // Load price data (need enough for long window + buffer)
   int required = m_hurst_long_window + 20;
   if(!LoadPriceData(symbol, tf, required))
   {
      Print("CRegimeDetector: Failed to load price data");
      return result;
   }
   
   // Calculate returns for entropy
   CalculateReturns();
   
   // === v4.0: MULTI-SCALE HURST ===
   result.hurst_short = CalculateHurst(m_prices, m_hurst_short_window);
   result.hurst_medium = CalculateHurst(m_prices, m_hurst_window);
   result.hurst_long = CalculateHurst(m_prices, m_hurst_long_window);
   
   // Primary Hurst is medium-scale
   result.hurst_exponent = result.hurst_medium;
   
   if(result.hurst_exponent < 0)
   {
      Print("CRegimeDetector: Hurst calculation failed");
      return result;
   }
   
   // Multi-scale agreement
   result.multiscale_agreement = CalculateMultiscaleAgreement(
      result.hurst_short, result.hurst_medium, result.hurst_long);
   
   // === SHANNON ENTROPY ===
   result.shannon_entropy = CalculateEntropy(m_returns);
   if(result.shannon_entropy < 0)
   {
      Print("CRegimeDetector: Entropy calculation failed");
      return result;
   }
   
   // === v4.0: VARIANCE RATIO TEST ===
   result.variance_ratio = CalculateVarianceRatio(m_prices, m_vr_lag);
   
   // === v4.0: TRANSITION DETECTION ===
   UpdateHurstHistory(result.hurst_exponent);
   result.regime_velocity = CalculateRegimeVelocity();
   result.transition_probability = CalculateTransitionProbability();
   
   // Get Kalman trend
   result.kalman_trend = GetKalmanTrend(m_prices, 5);
   result.kalman_trend_velocity = m_kalman_state.velocity;
   
   // === CLASSIFY REGIME (v4.0: Uses all metrics) ===
   result.regime = ClassifyRegime(result);
   
   // Track regime persistence
   if(result.regime == m_previous_regime)
      m_bars_in_current_regime++;
   else
   {
      m_bars_in_current_regime = 1;
      m_previous_regime = result.regime;
   }
   result.bars_in_regime = m_bars_in_current_regime;
   
   // === v4.0: ENHANCED OUTPUTS ===
   result.confidence = CalculateEnhancedConfidence(result);
   result.size_multiplier = GetSizeMultiplier(result);
   result.score_adjustment = GetScoreAdjustment(result);
   result.diagnosis = BuildDiagnosis(result);
   
   result.calculation_time = TimeCurrent();
   result.is_valid = true;
   
   // Cache result
   m_last_analysis = result;
   m_last_calculation = TimeCurrent();
   
   return result;
}

// === HURST EXPONENT CALCULATION (R/S Analysis) ===
double CRegimeDetector::CalculateHurst(const double &prices[], int window)
{
   int size = ArraySize(prices);
   int use_size = MathMin(size, window);
   
   if(use_size < m_min_samples)
      return -1.0;
   
   // Use most recent 'window' prices
   int start_idx = size - use_size;
   
   // Calculate log returns
   double log_returns[];
   ArrayResize(log_returns, use_size - 1);
   for(int i = 1; i < use_size; i++)
   {
      double p_prev = prices[start_idx + i - 1];
      double p_curr = prices[start_idx + i];
      if(p_prev <= 0) { ArrayFree(log_returns); return -1.0; }
      log_returns[i-1] = MathLog(p_curr / p_prev);
   }
   
   // R/S analysis with multiple window sizes
   int min_k = 10;
   int max_k = MathMin(50, (use_size - 1) / 2);
   
   if(max_k <= min_k) { ArrayFree(log_returns); return -1.0; }
   
   double log_n[], log_rs[];
   ArrayResize(log_n, 0);
   ArrayResize(log_rs, 0);
   
   // Pre-allocate subseries outside loop (v4.0: optimization)
   double subseries[];
   ArrayResize(subseries, max_k);
   
   for(int n = min_k; n <= max_k; n++)
   {
      int num_subseries = ArraySize(log_returns) / n;
      if(num_subseries < 1) continue;
      
      double rs_sum = 0;
      int valid_count = 0;
      
      for(int i = 0; i < num_subseries; i++)
      {
         // Extract subseries
         for(int j = 0; j < n; j++)
            subseries[j] = log_returns[i * n + j];
         
         // Calculate mean
         double mean = 0;
         for(int j = 0; j < n; j++)
            mean += subseries[j];
         mean /= n;
         
         // Calculate cumulative deviation and R
         double cumdev = 0;
         double max_cumdev = -DBL_MAX;
         double min_cumdev = DBL_MAX;
         for(int j = 0; j < n; j++)
         {
            cumdev += (subseries[j] - mean);
            if(cumdev > max_cumdev) max_cumdev = cumdev;
            if(cumdev < min_cumdev) min_cumdev = cumdev;
         }
         double R = max_cumdev - min_cumdev;
         
         // Calculate S (standard deviation)
         double variance = 0;
         for(int j = 0; j < n; j++)
            variance += MathPow(subseries[j] - mean, 2);
         variance /= (n - 1);
         double S = MathSqrt(variance);
         
         if(S > 1e-10)
         {
            rs_sum += (R / S);
            valid_count++;
         }
      }
      
      if(valid_count > 0)
      {
         double rs_mean = rs_sum / valid_count;
         int idx = ArraySize(log_n);
         ArrayResize(log_n, idx + 1);
         ArrayResize(log_rs, idx + 1);
         log_n[idx] = MathLog((double)n);
         log_rs[idx] = MathLog(rs_mean);
      }
   }
   
   ArrayFree(log_returns);
   ArrayFree(subseries);
   
   // Linear regression to get Hurst exponent
   int count = ArraySize(log_n);
   if(count < 3) { ArrayFree(log_n); ArrayFree(log_rs); return -1.0; }
   
   double sum_x = 0, sum_y = 0, sum_xy = 0, sum_xx = 0;
   for(int i = 0; i < count; i++)
   {
      sum_x += log_n[i];
      sum_y += log_rs[i];
      sum_xy += log_n[i] * log_rs[i];
      sum_xx += log_n[i] * log_n[i];
   }
   
   double denominator = count * sum_xx - sum_x * sum_x;
   if(MathAbs(denominator) < 1e-10) { ArrayFree(log_n); ArrayFree(log_rs); return -1.0; }
   
   double H = (count * sum_xy - sum_x * sum_y) / denominator;
   
   ArrayFree(log_n);
   ArrayFree(log_rs);
   
   // Clip to valid range [0, 1]
   return MathMax(0.0, MathMin(1.0, H));
}

// === SHANNON ENTROPY CALCULATION ===
double CRegimeDetector::CalculateEntropy(const double &returns[])
{
   int size = ArraySize(returns);
   if(size < m_min_samples)
      return -1.0;
   
   // Find min and max for binning
   double min_val = returns[0];
   double max_val = returns[0];
   for(int i = 1; i < size; i++)
   {
      if(returns[i] < min_val) min_val = returns[i];
      if(returns[i] > max_val) max_val = returns[i];
   }
   
   double range = max_val - min_val;
   if(range < 1e-10) return 0.0; // All same values = zero entropy
   
   // Create histogram
   int bins[];
   ArrayResize(bins, m_entropy_bins);
   ArrayInitialize(bins, 0);
   
   double bin_width = range / m_entropy_bins;
   for(int i = 0; i < size; i++)
   {
      int bin_idx = (int)((returns[i] - min_val) / bin_width);
      if(bin_idx >= m_entropy_bins) bin_idx = m_entropy_bins - 1;
      if(bin_idx < 0) bin_idx = 0;
      bins[bin_idx]++;
   }
   
   // Calculate entropy
   double entropy = 0;
   double log2 = MathLog(2.0);
   for(int i = 0; i < m_entropy_bins; i++)
   {
      if(bins[i] > 0)
      {
         double p = (double)bins[i] / size;
         entropy -= p * MathLog(p) / log2;
      }
   }
   
   ArrayFree(bins);
   return entropy;
}

// === v4.0: VARIANCE RATIO TEST (Lo-MacKinlay) ===
double CRegimeDetector::CalculateVarianceRatio(const double &prices[], int lag)
{
   int size = ArraySize(prices);
   if(size < lag * 10) return 1.0; // Default to random walk if insufficient data
   
   // Calculate 1-period log returns
   double returns_1[];
   ArrayResize(returns_1, size - 1);
   for(int i = 1; i < size; i++)
   {
      if(prices[i-1] <= 0) { ArrayFree(returns_1); return 1.0; }
      returns_1[i-1] = MathLog(prices[i] / prices[i-1]);
   }
   
   // Calculate lag-period log returns
   double returns_q[];
   int q_size = size - lag;
   if(q_size < 10) { ArrayFree(returns_1); return 1.0; }
   ArrayResize(returns_q, q_size);
   for(int i = lag; i < size; i++)
   {
      if(prices[i-lag] <= 0) { ArrayFree(returns_1); ArrayFree(returns_q); return 1.0; }
      returns_q[i-lag] = MathLog(prices[i] / prices[i-lag]);
   }
   
   // Calculate variance of 1-period returns
   double mean_1 = 0;
   for(int i = 0; i < ArraySize(returns_1); i++)
      mean_1 += returns_1[i];
   mean_1 /= ArraySize(returns_1);
   
   double var_1 = 0;
   for(int i = 0; i < ArraySize(returns_1); i++)
      var_1 += MathPow(returns_1[i] - mean_1, 2);
   var_1 /= (ArraySize(returns_1) - 1);
   
   // Calculate variance of lag-period returns
   double mean_q = 0;
   for(int i = 0; i < ArraySize(returns_q); i++)
      mean_q += returns_q[i];
   mean_q /= ArraySize(returns_q);
   
   double var_q = 0;
   for(int i = 0; i < ArraySize(returns_q); i++)
      var_q += MathPow(returns_q[i] - mean_q, 2);
   var_q /= (ArraySize(returns_q) - 1);
   
   ArrayFree(returns_1);
   ArrayFree(returns_q);
   
   // VR = Var(q-period) / (q * Var(1-period))
   if(var_1 < 1e-15) return 1.0; // Avoid division by zero
   
   double vr = var_q / (lag * var_1);
   
   // Clamp to reasonable range
   return MathMax(0.1, MathMin(3.0, vr));
}

// === v4.0: MULTI-SCALE AGREEMENT ===
double CRegimeDetector::CalculateMultiscaleAgreement(double h_short, double h_medium, double h_long)
{
   // Classify each into zone: 0=reverting, 1=random, 2=trending
   int zone_short = ClassifyHurstZone(h_short);
   int zone_medium = ClassifyHurstZone(h_medium);
   int zone_long = ClassifyHurstZone(h_long);
   
   double agreement = 0;
   
   // Perfect agreement: all same zone
   if(zone_short == zone_medium && zone_medium == zone_long)
      agreement = 100.0;
   // Good agreement: 2 of 3 same
   else if(zone_short == zone_medium || zone_medium == zone_long || zone_short == zone_long)
      agreement = 66.0;
   // Poor agreement: all different
   else
      agreement = 33.0;
   
   // Adjust by standard deviation of Hurst values
   double mean_h = (h_short + h_medium + h_long) / 3.0;
   double std_h = MathSqrt((MathPow(h_short - mean_h, 2) + 
                           MathPow(h_medium - mean_h, 2) + 
                           MathPow(h_long - mean_h, 2)) / 3.0);
   
   // Lower std = more consistent = bonus points
   double consistency_bonus = MathMax(0, (0.1 - std_h) * 100);
   agreement = MathMin(100, agreement + consistency_bonus);
   
   return agreement;
}

int CRegimeDetector::ClassifyHurstZone(double hurst)
{
   if(hurst > m_hurst_trending) return 2;  // Trending
   if(hurst < m_hurst_reverting) return 0; // Reverting
   return 1; // Random
}

// === v4.0: TRANSITION DETECTION ===
void CRegimeDetector::UpdateHurstHistory(double hurst)
{
   m_hurst_history[m_hurst_history_idx] = hurst;
   m_hurst_history_idx = (m_hurst_history_idx + 1) % HURST_HISTORY_SIZE;
}

double CRegimeDetector::CalculateRegimeVelocity()
{
   // Linear regression on Hurst history to get slope (dH/dt)
   double sum_x = 0, sum_y = 0, sum_xy = 0, sum_xx = 0;
   int n = HURST_HISTORY_SIZE;
   
   for(int i = 0; i < n; i++)
   {
      int idx = (m_hurst_history_idx + i) % n;
      sum_x += i;
      sum_y += m_hurst_history[idx];
      sum_xy += i * m_hurst_history[idx];
      sum_xx += i * i;
   }
   
   double denom = n * sum_xx - sum_x * sum_x;
   if(MathAbs(denom) < 1e-10) return 0;
   
   return (n * sum_xy - sum_x * sum_y) / denom;
}

double CRegimeDetector::CalculateTransitionProbability()
{
   double velocity = CalculateRegimeVelocity();
   double current_h = m_last_analysis.hurst_exponent > 0 ? 
                      m_last_analysis.hurst_exponent : 0.5;
   
   // Distance to nearest boundary (0.45 or 0.55)
   double dist_to_boundary = MathMin(
      MathAbs(current_h - m_hurst_reverting),
      MathAbs(current_h - m_hurst_trending)
   );
   
   double prob = 0;
   
   // Factor 1: Velocity toward boundary
   // If trending (H>0.55) and velocity negative: moving toward random
   // If reverting (H<0.45) and velocity positive: moving toward random
   bool moving_toward_random = false;
   if(current_h > m_hurst_trending && velocity < -0.005)
      moving_toward_random = true;
   else if(current_h < m_hurst_reverting && velocity > 0.005)
      moving_toward_random = true;
   
   if(moving_toward_random)
      prob += MathAbs(velocity) * 20; // Scale velocity contribution
   
   // Factor 2: Proximity to boundary
   if(dist_to_boundary < 0.05)
      prob += (0.05 - dist_to_boundary) * 10; // Max +0.5 if very close
   
   // Factor 3: Already in random walk zone
   if(current_h >= m_hurst_reverting && current_h <= m_hurst_trending)
      prob += 0.3; // Higher chance of transition when in random zone
   
   // Clamp to [0, 1]
   return MathMax(0.0, MathMin(1.0, prob));
}

// === v4.0: ENHANCED CONFIDENCE ===
double CRegimeDetector::CalculateEnhancedConfidence(const SRegimeAnalysis &analysis)
{
   double conf = 0;
   
   // 1. Hurst distance from 0.5 (0-30 points)
   double h_distance = MathAbs(analysis.hurst_exponent - 0.5);
   conf += MathMin(30, h_distance * 60);
   
   // 2. Variance Ratio confirmation (0-20 points)
   bool hurst_trending = (analysis.hurst_exponent > m_hurst_trending);
   bool hurst_reverting = (analysis.hurst_exponent < m_hurst_reverting);
   bool vr_trending = (analysis.variance_ratio > m_vr_trending);
   bool vr_reverting = (analysis.variance_ratio < m_vr_reverting);
   
   if((hurst_trending && vr_trending) || (hurst_reverting && vr_reverting))
      conf += 20; // Perfect agreement
   else if((hurst_trending || hurst_reverting) && 
           MathAbs(analysis.variance_ratio - 1.0) > 0.05)
      conf += 10; // Partial agreement
   
   // 3. Multi-scale agreement (0-20 points)
   conf += analysis.multiscale_agreement * 0.2;
   
   // 4. Regime momentum (0-15 points)
   double momentum = MathMin(analysis.bars_in_regime / 50.0, 1.0);
   conf += momentum * 15;
   
   // 5. Low entropy bonus (0-15 points)
   if(analysis.shannon_entropy < 1.0)
      conf += 15;
   else if(analysis.shannon_entropy < 1.5)
      conf += 10;
   else if(analysis.shannon_entropy < 2.0)
      conf += 5;
   
   // Penalty for high transition probability
   conf -= analysis.transition_probability * 20;
   
   return MathMax(0, MathMin(100, conf));
}

// === KALMAN FILTER ===
SKalmanState CRegimeDetector::UpdateKalman(double measurement)
{
   if(m_kalman_state.x == 0)
   {
      m_kalman_state.x = measurement;
      m_kalman_state.P = 1.0;
      m_kalman_state.velocity = 0;
      return m_kalman_state;
   }
   
   double x_pred = m_kalman_state.x;
   double P_pred = m_kalman_state.P + m_kalman_Q;
   
   double K = P_pred / (P_pred + m_kalman_R);
   m_kalman_state.x = x_pred + K * (measurement - x_pred);
   m_kalman_state.P = (1 - K) * P_pred;
   
   if(x_pred > 0)
      m_kalman_state.velocity = (measurement - x_pred) / x_pred * 100.0;
   
   return m_kalman_state;
}

ENUM_KALMAN_TREND CRegimeDetector::GetKalmanTrend(const double &prices[], int lookback)
{
   int size = ArraySize(prices);
   if(size < lookback) return KALMAN_NEUTRAL;
   
   ResetKalman();
   
   double velocities[];
   ArrayResize(velocities, size);
   for(int i = 0; i < size; i++)
   {
      UpdateKalman(prices[i]);
      velocities[i] = m_kalman_state.velocity;
   }
   
   double avg_vel = 0;
   for(int i = size - lookback; i < size; i++)
      avg_vel += velocities[i];
   avg_vel /= lookback;
   
   ArrayFree(velocities);
   
   if(avg_vel > m_kalman_velocity_threshold)
      return KALMAN_BULLISH;
   else if(avg_vel < -m_kalman_velocity_threshold)
      return KALMAN_BEARISH;
   else
      return KALMAN_NEUTRAL;
}

// === v4.0: ENHANCED REGIME CLASSIFICATION ===
ENUM_MARKET_REGIME CRegimeDetector::ClassifyRegime(const SRegimeAnalysis &analysis)
{
   double H = analysis.hurst_exponent;
   double S = analysis.shannon_entropy;
   double VR = analysis.variance_ratio;
   double trans_prob = analysis.transition_probability;
   double agreement = analysis.multiscale_agreement;
   
   // v4.0: Check for transitioning regime FIRST
   if(trans_prob > m_transition_threshold)
      return REGIME_TRANSITIONING;
   
   // Random walk detection (highest priority)
   // Now uses BOTH Hurst AND VR confirmation
   bool hurst_random = (H >= m_hurst_reverting && H <= m_hurst_trending);
   bool vr_random = (VR >= m_vr_reverting && VR <= m_vr_trending);
   
   if(hurst_random && vr_random)
      return REGIME_RANDOM_WALK;
   
   // If only one says random but multi-scale disagrees, be cautious
   if((hurst_random || vr_random) && agreement < 50)
      return REGIME_RANDOM_WALK;
   
   // Trending regimes
   if(H > m_hurst_trending)
   {
      // VR confirmation for PRIME status
      bool vr_confirms = (VR > m_vr_trending);
      
      if(S < m_entropy_low && vr_confirms && agreement >= 66)
         return REGIME_PRIME_TRENDING;
      else
         return REGIME_NOISY_TRENDING;
   }
   
   // Mean reverting regimes
   if(H < m_hurst_reverting)
   {
      bool vr_confirms = (VR < m_vr_reverting);
      
      if(S < m_entropy_low && vr_confirms && agreement >= 66)
         return REGIME_PRIME_REVERTING;
      else
         return REGIME_NOISY_REVERTING;
   }
   
   return REGIME_UNKNOWN;
}

// === v4.0: ADAPTIVE SIZE MULTIPLIER ===
double CRegimeDetector::GetSizeMultiplier(const SRegimeAnalysis &analysis)
{
   double base = 0.0;
   
   switch(analysis.regime)
   {
      case REGIME_PRIME_TRENDING:
      case REGIME_PRIME_REVERTING:
         base = 1.0;
         break;
      
      case REGIME_NOISY_TRENDING:
      case REGIME_NOISY_REVERTING:
         base = 0.5;
         break;
      
      case REGIME_TRANSITIONING:
         base = 0.25;  // v4.0: Reduced but not zero
         break;
      
      case REGIME_RANDOM_WALK:
      case REGIME_UNKNOWN:
      default:
         return 0.0;  // No trade
   }
   
   // v4.0: Reduce if transition probability is elevated
   if(analysis.transition_probability > 0.3)
      base *= (1.0 - analysis.transition_probability * 0.3);
   
   // v4.0: Reduce if multi-scale doesn't agree
   if(analysis.multiscale_agreement < 50)
      base *= 0.75;
   
   // v4.0: Confidence-based final adjustment
   if(analysis.confidence < 30)
      base *= 0.5;
   else if(analysis.confidence < 50)
      base *= 0.75;
   
   return MathMax(0, MathMin(1.0, base));
}

// === v4.0: ENHANCED SCORE ADJUSTMENT ===
int CRegimeDetector::GetScoreAdjustment(const SRegimeAnalysis &analysis)
{
   int adj = 0;
   
   switch(analysis.regime)
   {
      case REGIME_PRIME_TRENDING:
      case REGIME_PRIME_REVERTING:
         adj = 10;
         // v4.0: Bonus for very high confidence
         if(analysis.confidence > 80) adj += 10;
         if(analysis.multiscale_agreement > 90) adj += 5;
         break;
      
      case REGIME_NOISY_TRENDING:
      case REGIME_NOISY_REVERTING:
         adj = 0;
         break;
      
      case REGIME_TRANSITIONING:
         adj = -20;  // v4.0: Caution zone
         break;
      
      case REGIME_RANDOM_WALK:
         adj = -30;
         break;
      
      case REGIME_UNKNOWN:
      default:
         adj = -50;
   }
   
   // v4.0: Additional penalty for low confidence
   if(analysis.confidence < 30)
      adj -= 10;
   
   return adj;
}

// === TRADING ALLOWED CHECK ===
bool CRegimeDetector::IsTradingAllowed()
{
   ENUM_MARKET_REGIME regime = m_last_analysis.regime;
   
   // Block random walk and unknown
   if(regime == REGIME_RANDOM_WALK || regime == REGIME_UNKNOWN)
      return false;
   
   // v4.0: Allow transitioning with reduced size (handled by multiplier)
   // But block if confidence is very low
   if(regime == REGIME_TRANSITIONING && m_last_analysis.confidence < 20)
      return false;
   
   return true;
}

// === UTILITY METHODS ===
bool CRegimeDetector::LoadPriceData(string symbol, int tf, int count)
{
   ArraySetAsSeries(m_prices, true);
   int timeframe = (tf == 0 ? PERIOD_CURRENT : tf);
   int copied = CopyClose(symbol, (ENUM_TIMEFRAMES)timeframe, 0, count, m_prices);
   if(copied < m_min_samples)
   {
      Print("CRegimeDetector: Only ", copied, " prices available, need ", m_min_samples);
      return false;
   }

   // Reorder to chronological (old → new)
   ArraySetAsSeries(m_prices, false);
   int sz = ArraySize(m_prices);
   for(int i = 0; i < sz / 2; i++)
   {
      double tmp = m_prices[i];
      m_prices[i] = m_prices[sz - 1 - i];
      m_prices[sz - 1 - i] = tmp;
   }
   return true;
}

void CRegimeDetector::CalculateReturns()
{
   int size = ArraySize(m_prices);
   ArrayResize(m_returns, size - 1);
   
   for(int i = 1; i < size; i++)
   {
      if(m_prices[i-1] > 0)
         m_returns[i-1] = (m_prices[i] - m_prices[i-1]) / m_prices[i-1];
      else
         m_returns[i-1] = 0;
   }
}

string CRegimeDetector::RegimeToString(ENUM_MARKET_REGIME regime)
{
   switch(regime)
   {
      case REGIME_PRIME_TRENDING:   return "PRIME_TRENDING";
      case REGIME_NOISY_TRENDING:   return "NOISY_TRENDING";
      case REGIME_PRIME_REVERTING:  return "PRIME_REVERTING";
      case REGIME_NOISY_REVERTING:  return "NOISY_REVERTING";
      case REGIME_RANDOM_WALK:      return "RANDOM_WALK";
      case REGIME_TRANSITIONING:    return "TRANSITIONING";
      case REGIME_UNKNOWN:          return "UNKNOWN";
      default:                      return "INVALID";
   }
}

// === v4.0: HUMAN-READABLE DIAGNOSIS ===
string CRegimeDetector::BuildDiagnosis(const SRegimeAnalysis &analysis)
{
   string diag = "";
   
   diag += RegimeToString(analysis.regime);
   diag += " | H=" + DoubleToString(analysis.hurst_exponent, 3);
   diag += " VR=" + DoubleToString(analysis.variance_ratio, 2);
   diag += " S=" + DoubleToString(analysis.shannon_entropy, 2);
   diag += " | MS=" + DoubleToString(analysis.multiscale_agreement, 0) + "%";
   diag += " Conf=" + DoubleToString(analysis.confidence, 0) + "%";
   
   if(analysis.transition_probability > 0.3)
      diag += " [!TRANS:" + DoubleToString(analysis.transition_probability * 100, 0) + "%]";
   
   diag += " | Size=" + DoubleToString(analysis.size_multiplier, 2);
   
   return diag;
}

//+------------------------------------------------------------------+
//| v4.1: GET OPTIMAL STRATEGY FOR REGIME (GENIUS FEATURE)           |
//| Returns trading parameters optimized for specific market regime  |
//| Philosophy: Different regimes require fundamentally different    |
//| approaches to maximize edge and protect capital                  |
//+------------------------------------------------------------------+
SRegimeStrategy CRegimeDetector::GetOptimalStrategy(ENUM_MARKET_REGIME regime)
{
   SRegimeStrategy s;
   s.Reset();
   s.regime = regime;
   
   switch(regime)
   {
      // === PRIME TRENDING: Let profits run ===
      // High confidence trend - aggressive pursuit of runners
      case REGIME_PRIME_TRENDING:
         s.entry_mode = ENTRY_MODE_BREAKOUT;
         s.min_confluence = 65;           // Lower bar - trend is clear
         s.confirmation_bars = 1;
         s.risk_percent = 1.0;            // Full risk - high confidence
         s.sl_atr_mult = 1.5;             // Tight SL - trend protects
         s.min_rr = 1.5;
         s.tp1_r = 1.0;                   // First partial at 1R
         s.tp2_r = 2.5;                   // Second at 2.5R
         s.tp3_r = 4.0;                   // Let runners go to 4R
         s.partial1_pct = 0.33;           // 33% at TP1
         s.partial2_pct = 0.33;           // 33% at TP2, 34% runs
         s.be_trigger_r = 0.7;            // Early breakeven
         s.use_trailing = true;           // ESSENTIAL in trends
         s.trailing_start_r = 1.0;        // Start trailing at 1R
         s.trailing_step_atr = 0.5;       // Tight trailing
         s.use_time_exit = false;         // Trends can last long
         s.max_bars = 100;
         s.philosophy = "TREND IS YOUR FRIEND - LET PROFITS RUN";
         break;
      
      // === NOISY TRENDING: Expect pullbacks ===
      // Trend exists but volatile - balanced approach
      case REGIME_NOISY_TRENDING:
         s.entry_mode = ENTRY_MODE_PULLBACK;
         s.min_confluence = 70;           // Standard requirement
         s.confirmation_bars = 1;
         s.risk_percent = 0.75;           // Reduced risk
         s.sl_atr_mult = 1.8;             // Slightly wider SL
         s.min_rr = 1.5;
         s.tp1_r = 1.0;
         s.tp2_r = 2.0;
         s.tp3_r = 3.0;
         s.partial1_pct = 0.40;           // Take more early
         s.partial2_pct = 0.35;
         s.be_trigger_r = 1.0;            // Standard breakeven
         s.use_trailing = true;
         s.trailing_start_r = 1.5;        // Start later
         s.trailing_step_atr = 0.7;       // Wider step
         s.use_time_exit = false;
         s.max_bars = 60;
         s.philosophy = "FOLLOW TREND BUT EXPECT VOLATILITY";
         break;
      
      // === PRIME REVERTING: Quick scalps at extremes ===
      // High confidence mean reversion - grab profit fast
      case REGIME_PRIME_REVERTING:
         s.entry_mode = ENTRY_MODE_MEAN_REVERT;
         s.min_confluence = 75;           // More selective
         s.confirmation_bars = 2;         // Wait for confirmation
         s.risk_percent = 0.5;            // Reduced risk
         s.sl_atr_mult = 2.0;             // Wider SL - oscillations
         s.min_rr = 1.0;                  // Accept lower R:R
         s.tp1_r = 0.5;                   // QUICK TP - grab profit
         s.tp2_r = 1.0;
         s.tp3_r = 1.5;
         s.partial1_pct = 0.50;           // 50% at first TP!
         s.partial2_pct = 0.30;
         s.be_trigger_r = 0.5;            // Very early BE
         s.use_trailing = false;          // NO trailing in reversions
         s.trailing_start_r = 0;
         s.trailing_step_atr = 0;
         s.use_time_exit = true;          // Exit if takes too long
         s.max_bars = 20;                 // Reversions are quick
         s.philosophy = "QUICK SCALP AT EXTREMES - GRAB AND RUN";
         break;
      
      // === NOISY REVERTING: Very careful ===
      // Reverting but volatile - ultra conservative
      case REGIME_NOISY_REVERTING:
         s.entry_mode = ENTRY_MODE_MEAN_REVERT;
         s.min_confluence = 80;           // High selectivity
         s.confirmation_bars = 2;
         s.risk_percent = 0.4;            // Low risk
         s.sl_atr_mult = 2.2;
         s.min_rr = 1.0;
         s.tp1_r = 0.5;
         s.tp2_r = 0.8;
         s.tp3_r = 1.0;
         s.partial1_pct = 0.60;           // 60% at first TP
         s.partial2_pct = 0.25;
         s.be_trigger_r = 0.4;
         s.use_trailing = false;
         s.trailing_start_r = 0;
         s.trailing_step_atr = 0;
         s.use_time_exit = true;
         s.max_bars = 15;
         s.philosophy = "VERY CAREFUL - GRAB AND RUN FASTER";
         break;
      
      // === TRANSITIONING: Survival mode ===
      // Regime changing - wait for clarity
      case REGIME_TRANSITIONING:
         s.entry_mode = ENTRY_MODE_CONFIRMATION;
         s.min_confluence = 90;           // Ultra selective
         s.confirmation_bars = 3;         // Extra confirmation
         s.risk_percent = 0.25;           // Minimal risk
         s.sl_atr_mult = 2.5;             // Wide SL
         s.min_rr = 1.0;
         s.tp1_r = 0.5;
         s.tp2_r = 0.8;
         s.tp3_r = 1.0;
         s.partial1_pct = 0.70;           // 70% at first TP
         s.partial2_pct = 0.20;
         s.be_trigger_r = 0.3;            // Very early BE
         s.use_trailing = false;
         s.trailing_start_r = 0;
         s.trailing_step_atr = 0;
         s.use_time_exit = true;
         s.max_bars = 10;
         s.philosophy = "SURVIVAL MODE - WAIT FOR CLARITY";
         break;
      
      // === RANDOM WALK / UNKNOWN: No trading ===
      case REGIME_RANDOM_WALK:
      case REGIME_UNKNOWN:
      default:
         s.entry_mode = ENTRY_MODE_DISABLED;
         s.min_confluence = 100;          // Block all trades
         s.risk_percent = 0;
         s.philosophy = "NO EDGE - DO NOT TRADE";
         break;
   }
   
   return s;
}

//+------------------------------------------------------------------+
//| v4.1: Convert strategy to human-readable string                  |
//+------------------------------------------------------------------+
string CRegimeDetector::StrategyToString(const SRegimeStrategy &strategy)
{
   string s = "";
   
   s += RegimeToString(strategy.regime) + " Strategy:\n";
   s += "  Philosophy: " + strategy.philosophy + "\n";
   s += "  Entry Mode: ";
   switch(strategy.entry_mode)
   {
      case ENTRY_MODE_BREAKOUT:     s += "BREAKOUT"; break;
      case ENTRY_MODE_PULLBACK:     s += "PULLBACK"; break;
      case ENTRY_MODE_MEAN_REVERT:  s += "MEAN_REVERT"; break;
      case ENTRY_MODE_CONFIRMATION: s += "CONFIRMATION"; break;
      default:                      s += "DISABLED"; break;
   }
   s += "\n";
   s += "  Min Confluence: " + DoubleToString(strategy.min_confluence, 0) + "\n";
   s += "  Risk: " + DoubleToString(strategy.risk_percent, 2) + "%\n";
   s += "  SL: " + DoubleToString(strategy.sl_atr_mult, 1) + "×ATR\n";
   s += "  TPs (R): " + DoubleToString(strategy.tp1_r, 1) + "/" + 
                        DoubleToString(strategy.tp2_r, 1) + "/" + 
                        DoubleToString(strategy.tp3_r, 1) + "\n";
   s += "  Partials: " + DoubleToString(strategy.partial1_pct * 100, 0) + "%/" +
                         DoubleToString(strategy.partial2_pct * 100, 0) + "%\n";
   s += "  Trailing: " + (strategy.use_trailing ? "YES" : "NO") + "\n";
   s += "  Time Exit: " + (strategy.use_time_exit ? "YES (" + IntegerToString(strategy.max_bars) + " bars)" : "NO") + "\n";
   
   return s;
}
//+------------------------------------------------------------------+
