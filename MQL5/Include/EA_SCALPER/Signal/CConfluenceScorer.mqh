//+------------------------------------------------------------------+
//|                                            CConfluenceScorer.mqh |
//|                           EA_SCALPER_XAUUSD - Singularity Edition |
//|              Unified Confluence Scoring: Integrates All Detectors |
//|   v4.2 GENIUS: Session Profiles + Adaptive Bayesian Learning     |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD - Singularity Edition"
#property strict

// Include core definitions first (has ENUM_SIGNAL_TYPE)
#include "../Core/Definitions.mqh"

// Include all analyzers
#include "../Analysis/CRegimeDetector.mqh"
#include "../Analysis/CStructureAnalyzer.mqh"
#include "../Analysis/CLiquiditySweepDetector.mqh"
#include "../Analysis/CAMDCycleTracker.mqh"
#include "../Analysis/EliteOrderBlock.mqh"
#include "../Analysis/EliteFVG.mqh"

// v3.31: MTF + Order Flow integration (FORGE genius upgrade)
#include "../Analysis/CMTFManager.mqh"
#include "../Analysis/CFootprintAnalyzer.mqh"

// === SIGNAL QUALITY ENUMERATION ===
enum ENUM_SIGNAL_QUALITY
{
   QUALITY_INVALID = 0,    // Do not trade
   QUALITY_LOW = 1,        // Weak setup
   QUALITY_MEDIUM = 2,     // Average setup
   QUALITY_HIGH = 3,       // Strong setup
   QUALITY_ELITE = 4       // Institutional-grade setup
};

// === CONFLUENCE TIER THRESHOLDS ===
// Based on Blueprint v3.0 scoring system
#define TIER_S_MIN      90    // Elite setups (90-100)
#define TIER_A_MIN      80    // High quality (80-89)
#define TIER_B_MIN      70    // Tradeable (70-79)
#define TIER_C_MIN      60    // Marginal (60-69)
#define TIER_INVALID    60    // Below 60 = no trade

// === CONFLUENCE RESULT STRUCTURE ===
struct SConfluenceResult
{
   // Direction
   ENUM_SIGNAL_TYPE direction;
   ENUM_SIGNAL_QUALITY   quality;
   
   // Main score (0-100)
   double                total_score;
   
   // Component scores (0-100 each)
   double                structure_score;    // Market structure (HH/HL, BOS, CHoCH)
   double                regime_score;       // Hurst/Entropy regime
   double                sweep_score;        // Liquidity sweep detection
   double                amd_score;          // AMD cycle phase
   double                ob_score;           // Order block proximity
   double                fvg_score;          // FVG proximity
   double                premium_discount;   // Premium/Discount zone alignment
   
   // v3.31: NEW component scores (FORGE genius upgrade)
   double                mtf_score;          // MTF alignment (H1/M15/M5)
   double                footprint_score;    // Order Flow (Stacked Imbalance, Absorption)
   
   // Score adjustments
   int                   regime_adjustment;  // From regime detector
   int                   confluence_bonus;   // Multiple confluences bonus
   
   // Counts
   int                   bullish_factors;
   int                   bearish_factors;
   int                   total_confluences;
   
   // Trade setup
   double                entry_price;
   double                stop_loss;
   double                take_profit_1;
   double                take_profit_2;
   double                risk_reward;
   double                position_size_mult; // From regime (0, 0.5, or 1.0)
   
   // Metadata
   string                signal_reason;
   datetime              timestamp;
   bool                  is_valid;
};

// === WEIGHT CONFIGURATION (v3.31: 9 factors) ===
struct SConfluenceWeights
{
   // Original 7 factors (rebalanced)
   double w_structure;      // Structure weight (default 18%)
   double w_regime;         // Regime weight (default 15%)
   double w_sweep;          // Sweep weight (default 12%)
   double w_amd;            // AMD weight (default 10%)
   double w_ob;             // Order Block weight (default 10%)
   double w_fvg;            // FVG weight (default 8%)
   double w_zone;           // Premium/Discount weight (default 5%)
   
   // v3.31: NEW factors (FORGE genius upgrade)
   double w_mtf;            // MTF Alignment weight (default 15%)
   double w_footprint;      // Order Flow weight (default 7%)
   // Total: 18+15+12+10+10+8+5+15+7 = 100%
};

// === BAYESIAN CONFLUENCE PARAMETERS ===
// Calibrated probabilities from backtest analysis
struct SBayesianParams
{
   // P(Factor present | Win) - Likelihood of factor when trade wins
   double p_structure_given_win;   // Default 0.72
   double p_regime_given_win;      // Default 0.68
   double p_sweep_given_win;       // Default 0.65
   double p_amd_given_win;         // Default 0.62
   double p_ob_given_win;          // Default 0.70
   double p_fvg_given_win;         // Default 0.67
   
   // P(Factor present | Loss) - Likelihood of factor when trade loses
   double p_structure_given_loss;  // Default 0.45
   double p_regime_given_loss;     // Default 0.50
   double p_sweep_given_loss;      // Default 0.48
   double p_amd_given_loss;        // Default 0.52
   double p_ob_given_loss;         // Default 0.40
   double p_fvg_given_loss;        // Default 0.42
   
   // v3.31: NEW Bayesian params for MTF and Footprint
   double p_mtf_given_win;         // Default 0.78 (MTF alignment is powerful)
   double p_mtf_given_loss;        // Default 0.35
   double p_footprint_given_win;   // Default 0.73 (Order Flow confirmation)
   double p_footprint_given_loss;  // Default 0.38
   
   // Prior probability of winning
   double prior_win;               // Default 0.52 (slight edge)
   
   void SetDefaults()
   {
      p_structure_given_win = 0.72;
      p_regime_given_win = 0.68;
      p_sweep_given_win = 0.65;
      p_amd_given_win = 0.62;
      p_ob_given_win = 0.70;
      p_fvg_given_win = 0.67;
      
      p_structure_given_loss = 0.45;
      p_regime_given_loss = 0.50;
      p_sweep_given_loss = 0.48;
      p_amd_given_loss = 0.52;
      p_ob_given_loss = 0.40;
      p_fvg_given_loss = 0.42;
      
      // v3.31: MTF and Footprint Bayesian params
      p_mtf_given_win = 0.78;
      p_mtf_given_loss = 0.35;
      p_footprint_given_win = 0.73;
      p_footprint_given_loss = 0.38;
      
      prior_win = 0.52;
   }
};

// === v4.0 GENIUS: SEQUENTIAL CONFIRMATION STATE ===
// Tracks ICT sequence: Regime → HTF → Sweep → BOS → POI → LTF → Flow
struct SSequenceState
{
   bool regime_ok;          // Step 1: Regime favorable (Hurst trending/reverting)
   bool htf_direction_set;  // Step 2: H1 defines clear direction
   bool sweep_occurred;     // Step 3: Liquidity sweep happened (optional but valuable)
   bool structure_broken;   // Step 4: BOS/CHoCH confirmed reversal
   bool at_poi;             // Step 5: Price at OB/FVG (Point of Interest)
   bool ltf_confirmed;      // Step 6: M5 candle confirms entry
   bool flow_confirmed;     // Step 7: Order Flow confirms direction
   
   void Reset()
   {
      regime_ok = false;
      htf_direction_set = false;
      sweep_occurred = false;
      structure_broken = false;
      at_poi = false;
      ltf_confirmed = false;
      flow_confirmed = false;
   }
   
   // Count completed steps in correct ORDER
   int GetSequenceScore()
   {
      int steps = 0;
      bool sequence_valid = true;
      
      // Must follow ICT sequence!
      if(regime_ok) 
         steps++;
      else 
         sequence_valid = false;  // Can't skip regime
      
      if(sequence_valid && htf_direction_set) 
         steps++;
      else if(!htf_direction_set) 
         sequence_valid = false;  // Can't skip HTF
      
      // Sweep is optional but valuable
      if(sweep_occurred) 
         steps++;
      
      if(sequence_valid && structure_broken) 
         steps++;
      else if(!structure_broken) 
         sequence_valid = false;  // Can't skip structure
      
      if(sequence_valid && at_poi) 
         steps++;
      else 
         sequence_valid = false;  // MUST have POI for entry
      
      // LTF and Flow are confirmations (optional but valuable)
      if(ltf_confirmed) steps++;
      if(flow_confirmed) steps++;
      
      return steps;
   }
   
   // Get bonus/penalty based on sequence completeness
   int GetSequenceBonus()
   {
      int steps = GetSequenceScore();
      
      // Full sequence (6-7 steps) = massive bonus
      if(steps >= 6) return 20;   // +20 bonus
      if(steps >= 5) return 10;   // +10 bonus
      if(steps >= 4) return 5;    // +5 bonus
      if(steps >= 3) return 0;    // Neutral
      if(steps == 2) return -10;  // Incomplete sequence
      return -20;  // Very incomplete = penalty
   }
   
   string GetSequenceString()
   {
      string s = "";
      s += regime_ok ? "[REG]" : "[---]";
      s += htf_direction_set ? "[HTF]" : "[---]";
      s += sweep_occurred ? "[SWP]" : "[---]";
      s += structure_broken ? "[BOS]" : "[---]";
      s += at_poi ? "[POI]" : "[---]";
      s += ltf_confirmed ? "[LTF]" : "[---]";
      s += flow_confirmed ? "[FLW]" : "[---]";
      return s;
   }
};

// === v4.1 GENIUS: ALIGNMENT STATE ===
// Tracks directional agreement between factors
struct SAlignmentState
{
   int strong_bullish;    // Factors strongly bullish (score > 70)
   int strong_bearish;    // Factors strongly bearish (score > 70)
   int weak_bullish;      // Factors weakly bullish (score 50-70)
   int weak_bearish;      // Factors weakly bearish (score 50-70)
   int neutral;           // Neutral factors
   
   void Reset()
   {
      strong_bullish = 0;
      strong_bearish = 0;
      weak_bullish = 0;
      weak_bearish = 0;
      neutral = 0;
   }
   
   // Get alignment multiplier (1.0 = no change, >1 = bonus, <1 = penalty)
   double GetAlignmentMultiplier()
   {
      int total_directional = strong_bullish + strong_bearish + weak_bullish + weak_bearish;
      if(total_directional == 0) return 0.5;  // All neutral = very bad
      
      int dominant_strong = MathMax(strong_bullish, strong_bearish);
      int minority_strong = MathMin(strong_bullish, strong_bearish);
      
      // ELITE alignment: 6+ strong factors on one side
      if(dominant_strong >= 6 && minority_strong == 0)
         return 1.35;  // +35% bonus!
      
      // Excellent alignment: 5 strong factors, no opposition
      if(dominant_strong >= 5 && minority_strong == 0)
         return 1.25;  // +25% bonus
      
      // Good alignment: 4 strong factors, minimal opposition
      if(dominant_strong >= 4 && minority_strong <= 1)
         return 1.15;  // +15% bonus
      
      // Acceptable alignment: 3+ strong, few opposition
      if(dominant_strong >= 3 && minority_strong <= 1)
         return 1.05;  // +5% bonus
      
      // CONFLICT detection: significant opposition
      if(strong_bullish >= 2 && strong_bearish >= 2)
         return 0.60;  // -40% PENALTY (mixed signals = danger!)
      
      if(strong_bullish >= 1 && strong_bearish >= 1)
         return 0.80;  // -20% penalty (some conflict)
      
      return 1.0;  // No adjustment
   }
   
   string GetAlignmentString()
   {
      return StringFormat("Bull:%d/%d Bear:%d/%d Neut:%d", 
                          strong_bullish, weak_bullish,
                          strong_bearish, weak_bearish, neutral);
   }
};

// === v4.1 GENIUS: FRESHNESS STATE ===
// Tracks how "fresh" each signal is (recent = better)
struct SFreshnessState
{
   double ob_freshness;      // OB freshness (0-1)
   double fvg_freshness;     // FVG freshness (0-1)
   double sweep_freshness;   // Sweep freshness (0-1)
   double structure_freshness; // BOS/CHoCH freshness (0-1)
   
   void Reset()
   {
      ob_freshness = 1.0;
      fvg_freshness = 1.0;
      sweep_freshness = 1.0;
      structure_freshness = 1.0;
   }
   
   // Calculate freshness from bars ago
   // optimal_bars = peak freshness (not 0, need time to develop)
   // max_bars = cutoff (after this, very stale)
   static double CalculateFreshness(int bars_ago, int optimal_bars, int max_bars)
   {
      if(bars_ago <= 0) return 0.7;  // Too fresh (not developed yet)
      
      if(bars_ago < optimal_bars)
      {
         // Building up to peak
         return 0.7 + 0.3 * ((double)bars_ago / optimal_bars);
      }
      else if(bars_ago <= max_bars)
      {
         // Decay from peak
         // Guard: if max_bars == optimal_bars, no decay range exists
         if(max_bars == optimal_bars) return 1.0;  // Avoid division by zero
         double decay = (double)(bars_ago - optimal_bars) / (max_bars - optimal_bars);
         return 1.0 - (decay * 0.6);  // Decay from 1.0 to 0.4
      }
      
      return 0.3;  // Stale - heavily penalized
   }
   
   // Get overall freshness multiplier
   double GetFreshnessMultiplier()
   {
      // v4.3: Use geometric mean of ALL relevant freshness values (added structure_freshness)
      double product = ob_freshness * fvg_freshness * sweep_freshness * structure_freshness;
      double avg = MathPow(product, 1.0/4.0);  // Fourth root (4 factors now)

      // Clamp to reasonable range
      return MathMax(0.4, MathMin(1.0, avg));
   }
   
   string GetFreshnessString()
   {
      return StringFormat("OB:%.2f FVG:%.2f SWP:%.2f STR:%.2f", 
                          ob_freshness, fvg_freshness, 
                          sweep_freshness, structure_freshness);
   }
};

// === v4.1 GENIUS: DIVERGENCE STATE ===
// Tracks if price action and indicators diverge
struct SDivergenceState
{
   int bullish_signals;     // Count of bullish factor signals
   int bearish_signals;     // Count of bearish factor signals
   int neutral_signals;     // Count of neutral signals
   bool has_divergence;     // True if significant divergence detected
   
   void Reset()
   {
      bullish_signals = 0;
      bearish_signals = 0;
      neutral_signals = 0;
      has_divergence = false;
   }
   
   // Get divergence penalty (1.0 = no penalty, <1 = penalty)
   double GetDivergencePenalty()
   {
      int total = bullish_signals + bearish_signals;
      if(total == 0) return 0.5;  // All neutral = bad
      
      double dominant = (double)MathMax(bullish_signals, bearish_signals);
      double minority = (double)MathMin(bullish_signals, bearish_signals);
      
      // Calculate agreement ratio
      double agreement = dominant / total;
      
      // Update divergence flag
      has_divergence = (agreement < 0.70);
      
      // Apply penalty based on agreement
      if(agreement >= 0.85) return 1.0;   // 85%+ agree = no penalty
      if(agreement >= 0.75) return 0.95;  // 75-85% = 5% penalty
      if(agreement >= 0.65) return 0.85;  // 65-75% = 15% penalty
      if(agreement >= 0.55) return 0.70;  // 55-65% = 30% penalty
      return 0.50;  // < 55% = 50% PENALTY (heavy conflict!)
   }
   
   string GetDivergenceString()
   {
      return StringFormat("Bull:%d Bear:%d Neut:%d Div:%s", 
                          bullish_signals, bearish_signals, neutral_signals,
                          has_divergence ? "YES" : "NO");
   }
};

// === v4.2 GENIUS: SESSION TYPE ENUMERATION ===
enum ENUM_CONFLUENCE_SESSION
{
   CONF_SESSION_ASIAN,      // Tokyo/Sydney (00:00-08:00 GMT) - Ranging, OB/FVG important
   CONF_SESSION_LONDON,     // London (08:00-12:00 GMT) - Breakouts, Structure/Sweep key
   CONF_SESSION_NY_OVERLAP, // London-NY overlap (12:00-16:00 GMT) - BEST: All factors
   CONF_SESSION_NY,         // NY afternoon (16:00-21:00 GMT) - Momentum, Footprint key
   CONF_SESSION_DEAD        // Dead zone (21:00-00:00 GMT) - NO TRADE
};

// === v4.2 GENIUS: SESSION WEIGHT PROFILE ===
// Different factor weights for each session based on market characteristics
struct SSessionWeightProfile
{
   double w_structure;
   double w_regime;
   double w_sweep;
   double w_amd;
   double w_ob;
   double w_fvg;
   double w_zone;
   double w_mtf;
   double w_footprint;
   
   // Set weights for specific session
   void SetForSession(ENUM_CONFLUENCE_SESSION session)
   {
      switch(session)
      {
         case CONF_SESSION_ASIAN:
            // Asian: Range-bound, mean reversion, OB/FVG zones are KEY
            w_structure = 0.12;   // Less breakouts
            w_regime = 0.18;      // Regime detection crucial (mean-revert)
            w_sweep = 0.08;       // Fewer sweeps
            w_amd = 0.08;         // Less pronounced cycles
            w_ob = 0.18;          // OB zones very important!
            w_fvg = 0.15;         // FVG fills common
            w_zone = 0.08;        // Premium/discount matters
            w_mtf = 0.08;         // Less MTF trend
            w_footprint = 0.05;   // Lower volume
            break;
            
         case CONF_SESSION_LONDON:
            // London: Breakout session, structure/sweep dominant
            w_structure = 0.22;   // Breakouts = BOS/CHoCH!
            w_regime = 0.12;      // Trending regime expected
            w_sweep = 0.18;       // Liquidity hunts common!
            w_amd = 0.12;         // Strong AMD cycles
            w_ob = 0.08;          // Less time at zones
            w_fvg = 0.06;         // FVGs get swept
            w_zone = 0.04;        // Less relevant
            w_mtf = 0.12;         // MTF trends develop
            w_footprint = 0.06;   // Building volume
            break;
            
         case CONF_SESSION_NY_OVERLAP:
            // NY Overlap: BEST session - all factors matter, balanced
            w_structure = 0.18;   // Structure confirmed
            w_regime = 0.14;      // Regime established
            w_sweep = 0.14;       // Major sweeps happen!
            w_amd = 0.10;         // Clear cycles
            w_ob = 0.10;          // Institutions active
            w_fvg = 0.08;         // Gaps get tested
            w_zone = 0.05;        // Zones respected
            w_mtf = 0.14;         // Full MTF alignment
            w_footprint = 0.07;   // Peak volume!
            break;
            
         case CONF_SESSION_NY:
            // NY Afternoon: Momentum/continuation, footprint is king
            w_structure = 0.15;   // Continuation patterns
            w_regime = 0.12;      // Trend continuation
            w_sweep = 0.10;       // Less new sweeps
            w_amd = 0.08;         // Distribution phase
            w_ob = 0.08;          // Retests only
            w_fvg = 0.07;         // Fill attempts
            w_zone = 0.05;        // Profit-taking zones
            w_mtf = 0.18;         // Follow H1 trend!
            w_footprint = 0.17;   // Volume tells the story!
            break;
            
         case CONF_SESSION_DEAD:
         default:
            // Dead zone: Use default weights but scoring will block trades anyway
            w_structure = 0.18;
            w_regime = 0.15;
            w_sweep = 0.12;
            w_amd = 0.10;
            w_ob = 0.10;
            w_fvg = 0.08;
            w_zone = 0.05;
            w_mtf = 0.15;
            w_footprint = 0.07;
            break;
      }
   }
   
   string GetSessionName(ENUM_CONFLUENCE_SESSION session)
   {
      switch(session)
      {
         case CONF_SESSION_ASIAN:      return "ASIAN";
         case CONF_SESSION_LONDON:     return "LONDON";
         case CONF_SESSION_NY_OVERLAP: return "NY_OVERLAP";
         case CONF_SESSION_NY:         return "NY";
         case CONF_SESSION_DEAD:       return "DEAD";
         default:                 return "UNKNOWN";
      }
   }
};

// === v4.2 GENIUS: ADAPTIVE BAYESIAN LEARNING STATE ===
// Tracks recent trade outcomes to update Bayesian priors dynamically
struct SBayesianLearningState
{
   // Recent trade tracking (rolling window)
   int    total_trades;           // Total trades recorded
   int    recent_wins;            // Wins in learning window
   int    recent_losses;          // Losses in learning window
   
   // Factor presence tracking when winning/losing
   // Using EMA (exponential moving average) for smooth adaptation
   double ema_structure_win;      // EMA of structure presence on wins
   double ema_structure_loss;     // EMA of structure presence on losses
   double ema_regime_win;
   double ema_regime_loss;
   double ema_sweep_win;
   double ema_sweep_loss;
   double ema_amd_win;
   double ema_amd_loss;
   double ema_ob_win;
   double ema_ob_loss;
   double ema_fvg_win;
   double ema_fvg_loss;
   double ema_mtf_win;
   double ema_mtf_loss;
   double ema_footprint_win;
   double ema_footprint_loss;
   
   // Learning rate (0.1 = slow adaptation, 0.3 = faster)
   double learning_rate;
   
   // Minimum trades before adaptation kicks in
   int    min_trades_for_learning;
   
   void Reset()
   {
      total_trades = 0;
      recent_wins = 0;
      recent_losses = 0;
      
      // Initialize EMAs to default priors
      ema_structure_win = 0.72;  ema_structure_loss = 0.45;
      ema_regime_win = 0.68;     ema_regime_loss = 0.50;
      ema_sweep_win = 0.65;      ema_sweep_loss = 0.48;
      ema_amd_win = 0.62;        ema_amd_loss = 0.52;
      ema_ob_win = 0.70;         ema_ob_loss = 0.40;
      ema_fvg_win = 0.67;        ema_fvg_loss = 0.42;
      ema_mtf_win = 0.78;        ema_mtf_loss = 0.35;
      ema_footprint_win = 0.73;  ema_footprint_loss = 0.38;
      
      learning_rate = 0.15;  // Moderate adaptation speed
      min_trades_for_learning = 20;  // Need 20+ trades before learning
   }
   
   // Update EMAs based on trade outcome
   // factor_present = true if factor score was >= 60 at entry
   void UpdateFactor(double &ema_win, double &ema_loss, bool factor_present, bool was_win)
   {
      double value = factor_present ? 1.0 : 0.0;
      
      if(was_win)
         ema_win = ema_win * (1.0 - learning_rate) + value * learning_rate;
      else
         ema_loss = ema_loss * (1.0 - learning_rate) + value * learning_rate;
   }
   
   // Record a trade outcome and update all factor EMAs
   void RecordTradeOutcome(const SConfluenceResult &entry_result, bool was_win)
   {
      total_trades++;
      if(was_win) recent_wins++;
      else recent_losses++;
      
      // Only adapt after minimum trades
      if(total_trades < min_trades_for_learning)
         return;
      
      // Update each factor's EMA based on presence at entry
      UpdateFactor(ema_structure_win, ema_structure_loss, entry_result.structure_score >= 60, was_win);
      UpdateFactor(ema_regime_win, ema_regime_loss, entry_result.regime_score >= 60, was_win);
      UpdateFactor(ema_sweep_win, ema_sweep_loss, entry_result.sweep_score >= 60, was_win);
      UpdateFactor(ema_amd_win, ema_amd_loss, entry_result.amd_score >= 60, was_win);
      UpdateFactor(ema_ob_win, ema_ob_loss, entry_result.ob_score >= 60, was_win);
      UpdateFactor(ema_fvg_win, ema_fvg_loss, entry_result.fvg_score >= 60, was_win);
      UpdateFactor(ema_mtf_win, ema_mtf_loss, entry_result.mtf_score >= 60, was_win);
      UpdateFactor(ema_footprint_win, ema_footprint_loss, entry_result.footprint_score >= 60, was_win);
   }
   
   // Get adaptive prior win probability based on recent performance
   double GetAdaptivePriorWin()
   {
      if(total_trades < min_trades_for_learning)
         return 0.52;  // Default prior
      
      int recent_total = recent_wins + recent_losses;
      if(recent_total == 0)
         return 0.52;
      
      // Blend default prior with actual win rate (weighted toward actual)
      double actual_winrate = (double)recent_wins / recent_total;
      double blended = 0.52 * 0.3 + actual_winrate * 0.7;  // 70% weight on actual
      
      // Clamp to reasonable range [0.35, 0.75]
      return MathMax(0.35, MathMin(0.75, blended));
   }
   
   // Apply learned EMAs to Bayesian params
   void ApplyToParams(SBayesianParams &params)
   {
      if(total_trades < min_trades_for_learning)
         return;  // Keep defaults until enough data
      
      // Apply learned values with some dampening toward defaults
      double dampen = 0.7;  // 70% learned, 30% default
      
      params.p_structure_given_win = ema_structure_win * dampen + 0.72 * (1-dampen);
      params.p_structure_given_loss = ema_structure_loss * dampen + 0.45 * (1-dampen);
      params.p_regime_given_win = ema_regime_win * dampen + 0.68 * (1-dampen);
      params.p_regime_given_loss = ema_regime_loss * dampen + 0.50 * (1-dampen);
      params.p_sweep_given_win = ema_sweep_win * dampen + 0.65 * (1-dampen);
      params.p_sweep_given_loss = ema_sweep_loss * dampen + 0.48 * (1-dampen);
      params.p_amd_given_win = ema_amd_win * dampen + 0.62 * (1-dampen);
      params.p_amd_given_loss = ema_amd_loss * dampen + 0.52 * (1-dampen);
      params.p_ob_given_win = ema_ob_win * dampen + 0.70 * (1-dampen);
      params.p_ob_given_loss = ema_ob_loss * dampen + 0.40 * (1-dampen);
      params.p_fvg_given_win = ema_fvg_win * dampen + 0.67 * (1-dampen);
      params.p_fvg_given_loss = ema_fvg_loss * dampen + 0.42 * (1-dampen);
      params.p_mtf_given_win = ema_mtf_win * dampen + 0.78 * (1-dampen);
      params.p_mtf_given_loss = ema_mtf_loss * dampen + 0.35 * (1-dampen);
      params.p_footprint_given_win = ema_footprint_win * dampen + 0.73 * (1-dampen);
      params.p_footprint_given_loss = ema_footprint_loss * dampen + 0.38 * (1-dampen);
      
      params.prior_win = GetAdaptivePriorWin();
   }
   
   string GetLearningString()
   {
      if(total_trades < min_trades_for_learning)
         return StringFormat("Learning: %d/%d trades (waiting)", total_trades, min_trades_for_learning);
      
      double winrate = (recent_wins + recent_losses > 0) ? 
                       100.0 * recent_wins / (recent_wins + recent_losses) : 0;
      return StringFormat("Learning: %d trades | WR:%.1f%% | Prior:%.2f", 
                          total_trades, winrate, GetAdaptivePriorWin());
   }
};

// === CONFLUENCE SCORER CLASS ===
// TODO:FORGE:BAYESIAN - Replace additive scoring with Bayesian probability
//   P(Win|Evidence) = P(HTF|Win) * P(MTF|Win) * P(LTF|Win) * P(Win) / P(Evidence)
// TODO:FORGE:BAYESIAN - Track win/loss stats per confluence factor
// TODO:FORGE:BAYESIAN - Implement adaptive weights based on recent performance
class CConfluenceScorer
{
private:
   // Component analyzers (references, not owned)
   CRegimeDetector*         m_regime;
   CStructureAnalyzer*      m_structure;
   CLiquiditySweepDetector* m_sweep;
   CAMDCycleTracker*        m_amd;
   CEliteOrderBlockDetector* m_ob_detector;
   CEliteFVGDetector*        m_fvg_detector;
   
   // v3.31: NEW analyzers (FORGE genius upgrade)
   CMTFManager*             m_mtf;
   CFootprintAnalyzer*      m_footprint;
   
   // Weights
   SConfluenceWeights       m_weights;
   
   // Bayesian parameters
   SBayesianParams          m_bayes;
   bool                     m_use_bayesian;      // Toggle Bayesian vs additive scoring
   
   // Thresholds
   int                      m_min_score;         // Minimum score to trade
   int                      m_min_confluences;   // Minimum confluences required

   // Direction voting
   int                      m_vote_margin;       // Min vote margin required to set direction
   
   // Last result cache
   SConfluenceResult        m_last_result;
   datetime                 m_last_calculation;
   int                      m_cache_seconds;
   
   // OB/FVG proximity settings
   double                   m_ob_proximity_pips;
   double                   m_fvg_proximity_pips;
   
   // v3.31: Cached ATR handle for performance (FORGE optimization)
   int                      m_atr_handle;
   string                   m_symbol;
   
   // v4.0 GENIUS: Adaptive threshold & sequence state
   int                      m_avg_atr_handle;    // 100-bar ATR for volatility comparison
   SSequenceState           m_sequence;          // Current sequence state
   int                      m_last_sequence_bonus; // Cached sequence bonus
   
   // v4.1 GENIUS: Alignment, Freshness, Divergence
   SAlignmentState          m_alignment;         // Factor alignment state
   SFreshnessState          m_freshness;         // Signal freshness state
   SDivergenceState         m_divergence;        // Signal divergence state
   double                   m_alignment_mult;    // Cached alignment multiplier
   double                   m_freshness_mult;    // Cached freshness multiplier
   double                   m_divergence_mult;   // Cached divergence penalty
   
   // v4.2 GENIUS: Session Profiles + Adaptive Bayesian Learning
   SSessionWeightProfile    m_session_weights;   // Current session weights
   SBayesianLearningState   m_learning;          // Bayesian learning state
   ENUM_CONFLUENCE_SESSION  m_current_session;   // Current trading session
   bool                     m_use_session_weights; // Toggle session-specific weights
   bool                     m_use_adaptive_learning; // Toggle adaptive Bayesian

   // v4.3: VIX/Sentiment Integration (can be fed via Python bridge)
   double                   m_vix_level;         // Current VIX level (from Python bridge)
   bool                     m_vix_available;     // Whether VIX data is available

public:
   CConfluenceScorer();
   ~CConfluenceScorer();
   
   // Attach analyzers
   void AttachRegimeDetector(CRegimeDetector* detector) { m_regime = detector; }
   void AttachStructureAnalyzer(CStructureAnalyzer* analyzer) { m_structure = analyzer; }
   void AttachSweepDetector(CLiquiditySweepDetector* detector) { m_sweep = detector; }
   void AttachAMDTracker(CAMDCycleTracker* tracker) { m_amd = tracker; }
   void AttachOBDetector(CEliteOrderBlockDetector* detector) { m_ob_detector = detector; }
   void AttachFVGDetector(CEliteFVGDetector* detector) { m_fvg_detector = detector; }
   
   // v3.31: NEW attach methods (FORGE genius upgrade)
   void AttachMTFManager(CMTFManager* mtf) { m_mtf = mtf; }
   void AttachFootprint(CFootprintAnalyzer* footprint) { m_footprint = footprint; }
   
   // Configuration
   void SetWeights(double structure, double regime, double sweep, double amd, double ob, double fvg, double zone);
   void SetMinScore(int score) { m_min_score = score; }
   void SetMinConfluences(int count) { m_min_confluences = count; }
   void SetVoteMargin(int margin) { m_vote_margin = MathMax(0, margin); }
   void SetProximityPips(double ob_pips, double fvg_pips);
   void SetCacheSeconds(int seconds) { m_cache_seconds = seconds; }
   void SetUseBayesian(bool use) { m_use_bayesian = use; }
   void SetBayesianParams(const SBayesianParams &params) { m_bayes = params; }

   // v4.3: VIX Integration (fed via Python bridge)
   void   SetVIXLevel(double vix) { m_vix_level = vix; m_vix_available = true; }
   double GetVIXLevel() { return m_vix_level; }
   bool   IsVIXAvailable() { return m_vix_available; }
   int    GetVIXScoreAdjustment(ENUM_SIGNAL_TYPE direction);  // VIX-based bias adjustment

   // Main scoring
   SConfluenceResult CalculateConfluence(string symbol = NULL);
   
   // Bayesian scoring (Phase 1 improvement)
   double CalculateBayesianProbability(const SConfluenceResult &result);
   SConfluenceResult GetLastResult() { return m_last_result; }
   
   // Component scoring (can be called individually)
   double ScoreStructure();
   double ScoreRegime();
   double ScoreSweep();
   double ScoreAMD();
   double ScoreOBProximity(double price);
   double ScoreFVGProximity(double price);
   double ScorePremiumDiscount();
   
   // v3.31: NEW scoring methods (FORGE genius upgrade)
   double ScoreMTFAlignment();
   double ScoreFootprint();
   
   // Direction determination
   ENUM_SIGNAL_TYPE DetermineDirection();
   ENUM_SIGNAL_QUALITY ClassifyQuality(double score);
   
   // Trade setup calculation
   void CalculateTradeSetup(SConfluenceResult &result, double current_price);
   
   // Validation
   bool IsValidSetup(const SConfluenceResult &result);
   bool PassesRegimeFilter();
   bool PassesStructureFilter();
   
   // v4.0 GENIUS: Adaptive Threshold + Sequential Confirmation
   int  GetAdaptiveThreshold();                    // ATR-based dynamic threshold
   void BuildSequenceState(const SConfluenceResult &result); // Build ICT sequence
   int  GetSequenceBonus() { return m_last_sequence_bonus; }
   string GetSequenceString() { return m_sequence.GetSequenceString(); }
   
   // v4.1 GENIUS: Alignment + Freshness + Divergence
   void BuildAlignmentState(const SConfluenceResult &result);   // Build alignment state
   void BuildFreshnessState();                                   // Build freshness state
   void BuildDivergenceState(const SConfluenceResult &result);   // Build divergence state
   double GetAlignmentMult() { return m_alignment_mult; }
   double GetFreshnessMult() { return m_freshness_mult; }
   double GetDivergenceMult() { return m_divergence_mult; }
   string GetAlignmentString() { return m_alignment.GetAlignmentString(); }
   string GetFreshnessString() { return m_freshness.GetFreshnessString(); }
   string GetDivergenceString() { return m_divergence.GetDivergenceString(); }
   
   // v4.2 GENIUS: Session Profiles + Adaptive Bayesian Learning
   ENUM_CONFLUENCE_SESSION GetCurrentSession();                   // Detect current session from GMT
   void ApplySessionWeights();                                    // Apply session-specific weights
   void RecordTradeOutcome(bool was_win);                         // Record trade for learning
   void SetUseSessionWeights(bool use) { m_use_session_weights = use; }
   void SetUseAdaptiveLearning(bool use) { m_use_adaptive_learning = use; }
   string GetSessionName() { return m_session_weights.GetSessionName(m_current_session); }
   string GetLearningString() { return m_learning.GetLearningString(); }
   SBayesianLearningState GetLearningState() { return m_learning; }
   
   // Utility
   string QualityToString(ENUM_SIGNAL_QUALITY quality);
   string DirectionToString(ENUM_SIGNAL_TYPE dir);
   void PrintResult(const SConfluenceResult &result);
   
private:
   double NormalizeScore(double raw_score, double max_value);
   int CountConfluences(const SConfluenceResult &result);
   string BuildSignalReason(const SConfluenceResult &result);
};

// === CONSTRUCTOR ===
CConfluenceScorer::CConfluenceScorer()
{
   // Initialize pointers
   m_regime = NULL;
   m_structure = NULL;
   m_sweep = NULL;
   m_amd = NULL;
   m_ob_detector = NULL;
   m_fvg_detector = NULL;
   
   // v3.31: Initialize new pointers (FORGE genius upgrade)
   m_mtf = NULL;
   m_footprint = NULL;
   m_symbol = _Symbol;
   
   // Default weights (v4.3: 9 factors, total = 100%)
   // v4.3: Rebalanced for scalping - increased footprint, reduced structure/mtf
   m_weights.w_structure = 0.15;   // 15% (was 18% - reduces duplicate influence with voting)
   m_weights.w_regime = 0.15;      // 15% (unchanged)
   m_weights.w_sweep = 0.12;       // 12% (unchanged)
   m_weights.w_amd = 0.10;         // 10% (unchanged)
   m_weights.w_ob = 0.10;          // 10% (unchanged)
   m_weights.w_fvg = 0.08;         // 8% (unchanged)
   m_weights.w_zone = 0.05;        // 5% (unchanged)
   m_weights.w_mtf = 0.12;         // 12% (was 15% - rebalanced)
   m_weights.w_footprint = 0.13;   // 13% (was 7% - critical for scalping)
   // Total: 15+15+12+10+10+8+5+12+13 = 100%
   
   // Bayesian parameters (calibrated defaults)
   m_bayes.SetDefaults();
   m_use_bayesian = true;          // v4.3: Enable Bayesian with fallback in CalculateBayesianProbability
   
   // Thresholds
   m_min_score = 50;               // v4.2.1: lower base minimum score (was 70)
   m_min_confluences = 3;          // At least 3 factors

   // Direction voting
   m_vote_margin = 2;              // v4.2.1: default 2-vote margin (was hardcoded 3)
   
   // Cache (disabled by default in backtest to avoid stale "always valid" signals)
   m_cache_seconds = 0;
   m_last_calculation = 0;
   
   // Proximity settings
   m_ob_proximity_pips = 30.0;
   m_fvg_proximity_pips = 20.0;
   
   // v3.31: Cache ATR handle for performance (FORGE optimization)
   m_atr_handle = iATR(m_symbol, PERIOD_CURRENT, 14);
   
   // v4.0 GENIUS: Initialize avg ATR handle (100-bar for volatility comparison)
   m_avg_atr_handle = iATR(m_symbol, PERIOD_M5, 100);
   m_sequence.Reset();
   m_last_sequence_bonus = 0;
   
   // v4.1 GENIUS: Initialize alignment, freshness, divergence
   m_alignment.Reset();
   m_freshness.Reset();
   m_divergence.Reset();
   m_alignment_mult = 1.0;
   m_freshness_mult = 1.0;
   m_divergence_mult = 1.0;
   
   // v4.2 GENIUS: Initialize session profiles and adaptive learning
   m_session_weights.SetForSession(CONF_SESSION_NY_OVERLAP);  // Default to best session
   m_learning.Reset();
   m_current_session = CONF_SESSION_NY_OVERLAP;
   m_use_session_weights = true;   // Enable by default (GENIUS feature)
   m_use_adaptive_learning = true; // Enable by default (self-improving!)

   // v4.3: VIX Integration (fed via Python bridge)
   m_vix_level = 0.0;
   m_vix_available = false;

   // Initialize last result
   ZeroMemory(m_last_result);
}

CConfluenceScorer::~CConfluenceScorer()
{
   // Don't delete analyzers - they're owned by the EA
   
   // v3.31: Release cached ATR handle (FORGE optimization)
   if(m_atr_handle != INVALID_HANDLE)
      IndicatorRelease(m_atr_handle);
   
   // v4.0 GENIUS: Release avg ATR handle
   if(m_avg_atr_handle != INVALID_HANDLE)
      IndicatorRelease(m_avg_atr_handle);
}

// === CONFIGURATION ===
void CConfluenceScorer::SetWeights(double structure, double regime, double sweep, double amd, double ob, double fvg, double zone)
{
   m_weights.w_structure = structure;
   m_weights.w_regime = regime;
   m_weights.w_sweep = sweep;
   m_weights.w_amd = amd;
   m_weights.w_ob = ob;
   m_weights.w_fvg = fvg;
   m_weights.w_zone = zone;
}

void CConfluenceScorer::SetProximityPips(double ob_pips, double fvg_pips)
{
   m_ob_proximity_pips = ob_pips;
   m_fvg_proximity_pips = fvg_pips;
}

// === MAIN SCORING ===
SConfluenceResult CConfluenceScorer::CalculateConfluence(string symbol = NULL)
{
   // IMPORTANT: In MQL5, default parameters must match the declared default.
   // The header uses `string symbol = NULL`, so inside the function we must treat
   // empty/NULL string as "use _Symbol".
   // Otherwise, callers that use the default (or pass "") can end up scoring with
   // an empty symbol and return zeros.

   // Check cache (only if cache horizon > 0)
   if(m_cache_seconds > 0 && TimeCurrent() - m_last_calculation < m_cache_seconds && m_last_result.is_valid)
      return m_last_result;
   
   if(symbol == NULL || symbol == "") symbol = _Symbol;
   m_symbol = symbol;
   
   SConfluenceResult result;
   ZeroMemory(result);
   result.timestamp = TimeCurrent();
   
   double current_price = SymbolInfoDouble(symbol, SYMBOL_BID);
   
   // v4.2 GENIUS: Apply session-specific weights BEFORE scoring
   // This ensures each factor is weighted appropriately for current market conditions
   ApplySessionWeights();
   
   // === SCORE EACH COMPONENT ===
   
   // 1. Structure score
   result.structure_score = ScoreStructure();
   
   // 2. Regime score
   result.regime_score = ScoreRegime();
   
   // Get regime adjustments from detector
   if(m_regime != NULL)
   {
      SRegimeAnalysis regime = m_regime.GetLastAnalysis();
      result.regime_adjustment = regime.score_adjustment;
      result.position_size_mult = regime.size_multiplier;
   }
   else
   {
      result.regime_adjustment = 0;
      result.position_size_mult = 1.0;
   }
   
   // 3. Sweep score
   result.sweep_score = ScoreSweep();
   
   // 4. AMD score
   result.amd_score = ScoreAMD();
   
   // 5. OB proximity score
   result.ob_score = ScoreOBProximity(current_price);
   
   // 6. FVG proximity score
   result.fvg_score = ScoreFVGProximity(current_price);
   
   // 7. Premium/Discount score
   result.premium_discount = ScorePremiumDiscount();
   
   // v3.31: NEW scores (FORGE genius upgrade)
   // 8. MTF Alignment score
   result.mtf_score = ScoreMTFAlignment();
   
   // 9. Footprint/Order Flow score
   result.footprint_score = ScoreFootprint();
   
   // === CALCULATE TOTAL SCORE ===
   if(m_use_bayesian)
   {
      // Bayesian probability-based scoring (Phase 1 improvement)
      double p_win = CalculateBayesianProbability(result);
      result.total_score = p_win * 100.0;  // Convert probability to 0-100 scale
   }
   else
   {
      // Legacy weighted additive scoring (v3.31: 9 factors)
      result.total_score = 
         result.structure_score * m_weights.w_structure +
         result.regime_score * m_weights.w_regime +
         result.sweep_score * m_weights.w_sweep +
         result.amd_score * m_weights.w_amd +
         result.ob_score * m_weights.w_ob +
         result.fvg_score * m_weights.w_fvg +
         result.premium_discount * m_weights.w_zone +
         result.mtf_score * m_weights.w_mtf +           // NEW
         result.footprint_score * m_weights.w_footprint; // NEW
   }
   
   // Apply regime adjustment
   result.total_score += result.regime_adjustment;
   
   // Count confluences and apply bonus (v3.31: adjusted for 9 factors)
   result.total_confluences = CountConfluences(result);
   if(result.total_confluences >= 7)
      result.confluence_bonus = 15;  // 7+ factors = massive confluence
   else if(result.total_confluences >= 5)
      result.confluence_bonus = 10;
   else if(result.total_confluences >= 4)
      result.confluence_bonus = 5;
   else
      result.confluence_bonus = 0;
   
   result.total_score += result.confluence_bonus;
   
   // v4.0 GENIUS: Build sequence state and apply sequence bonus
   // After direction is determined but before validation
   // This rewards setups that follow the correct ICT sequence
   result.direction = DetermineDirection();  // Determine early for sequence check
   BuildSequenceState(result);
   result.total_score += m_last_sequence_bonus;  // Can be negative (penalty)
   
   // v4.1 GENIUS: Apply Phase 1 multipliers (Alignment + Freshness + Divergence)
   // These address the mathematical flaw of treating correlated factors as independent
   BuildAlignmentState(result);    // Factor agreement analysis
   BuildFreshnessState();          // Signal age decay
   BuildDivergenceState(result);   // Direction conflict detection
   
   // Apply multipliers AFTER additive scoring but BEFORE clamping
   // Elite aligned setups get +35% bonus, conflicting get -40% penalty
   double phase1_multiplier = m_alignment_mult * m_freshness_mult * m_divergence_mult;
   result.total_score *= phase1_multiplier;
   
   // Log significant multiplier adjustments (once per 5 min)
   if(phase1_multiplier < 0.85 || phase1_multiplier > 1.15)
   {
      static datetime last_p1_log = 0;
      if(TimeCurrent() - last_p1_log > 300)
      {
         Print("[Confluence v4.1 GENIUS] Phase1 Mult: ", DoubleToString(phase1_multiplier, 3),
               " (Align=", DoubleToString(m_alignment_mult, 2),
               ", Fresh=", DoubleToString(m_freshness_mult, 2),
               ", Div=", DoubleToString(m_divergence_mult, 2), ")");
         last_p1_log = TimeCurrent();
      }
   }
   
   // Clamp score
   result.total_score = MathMax(0, MathMin(100, result.total_score));
   
   // === DETERMINE DIRECTION === (already done for sequence check)
   // result.direction = DetermineDirection();  // v4.0: Moved up for sequence
   
   // === CLASSIFY QUALITY ===
   result.quality = ClassifyQuality(result.total_score);
   
   // === VALIDATE ===
   result.is_valid = IsValidSetup(result);
   
   // === CALCULATE TRADE SETUP ===
   if(result.is_valid)
   {
      CalculateTradeSetup(result, current_price);
      result.signal_reason = BuildSignalReason(result);
   }
   
   // Cache result
   m_last_result = result;
   m_last_calculation = TimeCurrent();
   
   return result;
}

//+------------------------------------------------------------------+
//| Bayesian Probability Calculation (Phase 1 Improvement)           |
//| P(Win|Evidence) using Naive Bayes with calibrated likelihoods   |
//| v4.3: Added fallback to weighted avg when any factor < 40       |
//+------------------------------------------------------------------+
double CConfluenceScorer::CalculateBayesianProbability(const SConfluenceResult &result)
{
   // v4.3 FALLBACK: If any core factor is below 40, Bayesian can collapse to 0.
   // In that case, use weighted average instead for more stable scoring.
   // Core factors: structure, sweep, ob (the directional ones)
   const int WEAK_FACTOR_THRESHOLD = 40;
   bool has_weak_core = (result.structure_score < WEAK_FACTOR_THRESHOLD) ||
                        (result.sweep_score < WEAK_FACTOR_THRESHOLD) ||
                        (result.ob_score < WEAK_FACTOR_THRESHOLD);

   if(has_weak_core)
   {
      // Fallback: weighted average scoring (more stable for weak setups)
      double weighted_sum =
         result.structure_score * m_weights.w_structure +
         result.regime_score * m_weights.w_regime +
         result.sweep_score * m_weights.w_sweep +
         result.amd_score * m_weights.w_amd +
         result.ob_score * m_weights.w_ob +
         result.fvg_score * m_weights.w_fvg +
         result.premium_discount * m_weights.w_zone +
         result.mtf_score * m_weights.w_mtf +
         result.footprint_score * m_weights.w_footprint;

      // Convert 0-100 score to 0-1 probability (scaled)
      // Apply a conservative factor since Bayesian would likely be lower
      return MathMax(0.0, MathMin(1.0, (weighted_sum / 100.0) * 0.85));
   }

   // Naive Bayes formula:
   // P(Win|E) = P(E|Win) * P(Win) / P(E)
   // Where P(E) = P(E|Win)*P(Win) + P(E|Loss)*P(Loss)

   double p_win = m_bayes.prior_win;
   double p_loss = 1.0 - p_win;

   // Initialize likelihoods
   double likelihood_win = 1.0;
   double likelihood_loss = 1.0;

   // Factor 1: Structure (if score >= 60, factor is "present")
   if(result.structure_score >= 60)
   {
      likelihood_win *= m_bayes.p_structure_given_win;
      likelihood_loss *= m_bayes.p_structure_given_loss;
   }
   else
   {
      likelihood_win *= (1.0 - m_bayes.p_structure_given_win);
      likelihood_loss *= (1.0 - m_bayes.p_structure_given_loss);
   }

   // Factor 2: Regime
   if(result.regime_score >= 60)
   {
      likelihood_win *= m_bayes.p_regime_given_win;
      likelihood_loss *= m_bayes.p_regime_given_loss;
   }
   else
   {
      likelihood_win *= (1.0 - m_bayes.p_regime_given_win);
      likelihood_loss *= (1.0 - m_bayes.p_regime_given_loss);
   }

   // Factor 3: Sweep
   if(result.sweep_score >= 60)
   {
      likelihood_win *= m_bayes.p_sweep_given_win;
      likelihood_loss *= m_bayes.p_sweep_given_loss;
   }
   else
   {
      likelihood_win *= (1.0 - m_bayes.p_sweep_given_win);
      likelihood_loss *= (1.0 - m_bayes.p_sweep_given_loss);
   }

   // Factor 4: AMD
   if(result.amd_score >= 60)
   {
      likelihood_win *= m_bayes.p_amd_given_win;
      likelihood_loss *= m_bayes.p_amd_given_loss;
   }
   else
   {
      likelihood_win *= (1.0 - m_bayes.p_amd_given_win);
      likelihood_loss *= (1.0 - m_bayes.p_amd_given_loss);
   }

   // Factor 5: Order Block
   if(result.ob_score >= 60)
   {
      likelihood_win *= m_bayes.p_ob_given_win;
      likelihood_loss *= m_bayes.p_ob_given_loss;
   }
   else
   {
      likelihood_win *= (1.0 - m_bayes.p_ob_given_win);
      likelihood_loss *= (1.0 - m_bayes.p_ob_given_loss);
   }

   // Factor 6: FVG
   if(result.fvg_score >= 60)
   {
      likelihood_win *= m_bayes.p_fvg_given_win;
      likelihood_loss *= m_bayes.p_fvg_given_loss;
   }
   else
   {
      likelihood_win *= (1.0 - m_bayes.p_fvg_given_win);
      likelihood_loss *= (1.0 - m_bayes.p_fvg_given_loss);
   }

   // v3.31: Factor 7: MTF Alignment (FORGE genius upgrade)
   if(result.mtf_score >= 60)
   {
      likelihood_win *= m_bayes.p_mtf_given_win;
      likelihood_loss *= m_bayes.p_mtf_given_loss;
   }
   else
   {
      likelihood_win *= (1.0 - m_bayes.p_mtf_given_win);
      likelihood_loss *= (1.0 - m_bayes.p_mtf_given_loss);
   }

   // v3.31: Factor 8: Footprint/Order Flow (FORGE genius upgrade)
   if(result.footprint_score >= 60)
   {
      likelihood_win *= m_bayes.p_footprint_given_win;
      likelihood_loss *= m_bayes.p_footprint_given_loss;
   }
   else
   {
      likelihood_win *= (1.0 - m_bayes.p_footprint_given_win);
      likelihood_loss *= (1.0 - m_bayes.p_footprint_given_loss);
   }

   // Calculate posterior probability using Bayes' theorem
   double p_evidence = likelihood_win * p_win + likelihood_loss * p_loss;

   if(p_evidence <= 0)
      return m_bayes.prior_win;  // Fallback to prior

   double posterior = (likelihood_win * p_win) / p_evidence;

   // Clamp to valid probability range
   return MathMax(0.0, MathMin(1.0, posterior));
}

// === COMPONENT SCORING ===
double CConfluenceScorer::ScoreStructure()
{
   if(m_structure == NULL) return 50.0;
   
   SStructureState state = m_structure.GetState();
   double score = 50.0; // Base score
   
   // Bias clarity (+20 for clear trend, -10 for transition)
   ENUM_MARKET_BIAS bias = state.bias;
   if(bias == BIAS_BULLISH || bias == BIAS_BEARISH)
      score += 20.0;
   else if(bias == BIAS_TRANSITION)
      score -= 10.0;
   
   // BOS confirmation (+15 for 2+, +10 for 1)
   if(state.bos_count >= 2)
      score += 15.0;
   else if(state.bos_count >= 1)
      score += 10.0;
   
   // CHoCH reduces score (uncertainty) - max penalty 15
   score -= MathMin(state.choch_count * 5.0, 15.0);
   
   // Structure quality bonus (0-100 mapped to 0-15)
   score += state.structure_quality * 0.15;
   
   return MathMax(0, MathMin(100, score));
}

double CConfluenceScorer::ScoreRegime()
{
   if(m_regime == NULL) return 50.0;
   
   SRegimeAnalysis regime = m_regime.GetLastAnalysis();
   if(!regime.is_valid) return 50.0;
   
   double score = 50.0; // Base score
   
   // Hurst exponent scoring (trending vs mean-reverting)
   if(regime.hurst_exponent > 0.60)
      score += 25.0;
   else if(regime.hurst_exponent > 0.55)
      score += 15.0;
   else if(regime.hurst_exponent > 0.50)
      score += 5.0;
   else if(regime.hurst_exponent < 0.45)
      score -= 10.0;
   
   // Entropy scoring (lower = more predictable)
   if(regime.shannon_entropy < 1.0)
      score += 15.0;
   else if(regime.shannon_entropy < 1.5)
      score += 10.0;
   else if(regime.shannon_entropy > 2.0)
      score -= 15.0;
   
   // Apply detector's score adjustment
   score += regime.score_adjustment;
   
   // Confidence bonus (0-10)
   score += regime.confidence * 0.1;
   
   return MathMax(0, MathMin(100, score));
}

double CConfluenceScorer::ScoreSweep()
{
   if(m_sweep == NULL) return 50.0;

   // Granular scoring: recency (bars ago) + magnitude (depth)
   // Recency buckets:
   //  - < 5 bars  -> 85
   //  - < 20 bars -> 70
   //  - stale     -> 55
   // Magnitude bonus: up to +10 based on sweep depth (in points) relative to symbol point.
   // Note: CLiquiditySweepDetector uses PERIOD_M15 for sweep timing.

   if(!m_sweep.HasRecentSweep(20))
      return 55.0;

   double base = 70.0;
   if(m_sweep.HasRecentSweep(5))
      base = 85.0;

   SSweepEvent sweep = m_sweep.GetMostRecentSweep();
   if(!sweep.is_valid_sweep)
      return MathMax(55.0, base);

   double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   if(point <= 0)
      point = _Point;

   double depth_points = (point > 0) ? (sweep.sweep_depth / point) : 0.0;
   double mag_bonus = 0.0;
   if(depth_points > 0)
   {
      // Saturate at 20 points depth => +10
      mag_bonus = MathMin(10.0, (depth_points / 20.0) * 10.0);
   }

   double score = base + mag_bonus;
   return MathMax(0, MathMin(100, score));
}

double CConfluenceScorer::ScoreAMD()
{
   if(m_amd == NULL) return 50.0;

   // Granular AMD scoring based on phase quality/duration.
   // Targets:
   // - Distribution phase after manipulation = 90
   // - Manipulation with sweep               = 75
   // - Accumulation forming                  = 60
   // - Unknown                               = 40

   ENUM_AMD_PHASE phase = m_amd.GetCurrentPhase();
   SAMDCycle cycle = m_amd.GetCurrentCycle();

   if(phase == AMD_PHASE_DISTRIBUTION)
   {
      // Prefer distribution only when preceded by a valid manipulation event.
      if(cycle.manipulation.is_valid)
         return 90.0;
      return 75.0;
   }

   if(phase == AMD_PHASE_MANIPULATION)
   {
      if(cycle.manipulation.is_valid && cycle.manipulation.sweep_depth > 0)
         return 75.0;
      return 40.0;
   }

   if(phase == AMD_PHASE_ACCUMULATION)
   {
      if(cycle.accumulation.is_valid)
         return 60.0;
      return 40.0;
   }

   return 40.0;
}

double CConfluenceScorer::ScoreOBProximity(double price)
{
   if(m_ob_detector == NULL) return 50.0;
   double bull = m_ob_detector.GetProximityScore(OB_BULLISH);
   double bear = m_ob_detector.GetProximityScore(OB_BEARISH);
   return MathMax(bull, bear);
}

double CConfluenceScorer::ScoreFVGProximity(double price)
{
   if(m_fvg_detector == NULL) return 50.0;
   double bull = m_fvg_detector.GetProximityScore(FVG_BULLISH);
   double bear = m_fvg_detector.GetProximityScore(FVG_BEARISH);
   return MathMax(bull, bear);
}

double CConfluenceScorer::ScorePremiumDiscount()
{
   if(m_structure == NULL) return 50.0;
   
   SStructureState state = m_structure.GetState();
   double score = 50.0;
   
   // Check if in premium/discount zone
   bool in_premium = state.in_premium;
   bool in_discount = state.in_discount;
   ENUM_MARKET_BIAS bias = state.bias;
   
   // Optimal: Buy in discount zone during bullish bias
   // Optimal: Sell in premium zone during bearish bias
   if(bias == BIAS_BULLISH && in_discount)
      score += 35.0;  // Perfect alignment for longs
   else if(bias == BIAS_BEARISH && in_premium)
      score += 35.0;  // Perfect alignment for shorts
   else if(bias == BIAS_BULLISH && in_premium)
      score -= 15.0;  // Buying at premium (suboptimal)
   else if(bias == BIAS_BEARISH && in_discount)
      score -= 15.0;  // Selling at discount (suboptimal)
   
   return MathMax(0, MathMin(100, score));
}

//+------------------------------------------------------------------+
//| v3.31: MTF Alignment Score (FORGE genius upgrade)               |
//| Returns 0-100 based on H1/M15/M5 alignment quality              |
//+------------------------------------------------------------------+
double CConfluenceScorer::ScoreMTFAlignment()
{
   if(m_mtf == NULL) return 50.0;  // Neutral if not attached
   
   SMTFConfluence conf = m_mtf.GetConfluence();
   double score = 50.0;  // Base score
   
   // Alignment quality scoring
   switch(conf.alignment)
   {
      case MTF_ALIGN_PERFECT:  // All 3 TFs aligned
         score = 95.0;
         break;
      case MTF_ALIGN_GOOD:     // 2 TFs aligned
         score = 75.0;
         break;
      case MTF_ALIGN_WEAK:     // 1 TF aligned
         score = 55.0;
         break;
      case MTF_ALIGN_NONE:     // No alignment
         score = 30.0;
         break;
   }
   
   // HTF (H1) trend alignment bonus
   if(conf.htf_aligned)
      score += 5.0;  // Critical: never trade against H1
   
   // MTF structure bonus (OB/FVG zone present)
   if(conf.mtf_structure)
      score += 5.0;
   
   // LTF confirmation bonus
   if(conf.ltf_confirmed)
      score += 5.0;
   
   // Apply confidence as a multiplier (0.5 to 1.0)
   double conf_mult = 0.5 + (conf.confidence / 200.0);
   score *= conf_mult;
   
   return MathMax(0, MathMin(100, score));
}

//+------------------------------------------------------------------+
//| v3.4: Footprint/Order Flow Score (Momentum Edge)                |
//| Returns 0-100 based on Order Flow patterns                      |
//| Includes: Delta Acceleration + POC Divergence                   |
//+------------------------------------------------------------------+
double CConfluenceScorer::ScoreFootprint()
{
   if(m_footprint == NULL) return 50.0;  // Neutral if not attached
   
   SFootprintSignal sig = m_footprint.GetSignal();
   double score = 50.0;  // Base score
   
   // Stacked Imbalance is the most powerful signal
   if(sig.hasStackedBuyImbalance || sig.hasStackedSellImbalance)
      score += 25.0;
   
   // Absorption shows institutional activity
   if(sig.hasBuyAbsorption || sig.hasSellAbsorption)
      score += 15.0;
   
   // Unfinished auction suggests continuation
   if(sig.hasUnfinishedAuctionUp || sig.hasUnfinishedAuctionDown)
      score += 10.0;
   
   // Delta divergence is a warning sign
   if(sig.hasBullishDeltaDivergence || sig.hasBearishDeltaDivergence)
      score -= 10.0;  // Potential reversal
   
   // v3.4: Delta Acceleration (momentum before price)
   // Strong signal when delta is accelerating in trade direction
   if(sig.hasBullishDeltaAcceleration || sig.hasBearishDeltaAcceleration)
      score += 12.0;  // Momentum building - high confidence
   
   // v3.4: POC Divergence (institutional positioning)
   // POC rising while price falling = buyers accumulating (bullish reversal)
   // POC falling while price rising = sellers distributing (bearish reversal)
   if(sig.hasBullishPOCDivergence || sig.hasBearishPOCDivergence)
      score += 10.0;  // Institutional reversal signal
   
   // Signal strength affects score
   if(sig.signal == FP_SIGNAL_STRONG_BUY || sig.signal == FP_SIGNAL_STRONG_SELL)
      score += 15.0;
   else if(sig.signal == FP_SIGNAL_BUY || sig.signal == FP_SIGNAL_SELL)
      score += 8.0;
   else if(sig.signal == FP_SIGNAL_WEAK_BUY || sig.signal == FP_SIGNAL_WEAK_SELL)
      score += 3.0;
   
   return MathMax(0, MathMin(100, score));
}

// === DIRECTION DETERMINATION ===
ENUM_SIGNAL_TYPE CConfluenceScorer::DetermineDirection()
{
   int bullish_votes = 0;
   int bearish_votes = 0;

   // 1) Structure bias (weight: 2 votes - v4.3: reduced from 3 to avoid duplicate influence with AMD)
   if(m_structure != NULL)
   {
      ENUM_MARKET_BIAS bias = m_structure.GetCurrentBias();
      if(bias == BIAS_BULLISH) bullish_votes += 2;
      else if(bias == BIAS_BEARISH) bearish_votes += 2;
   }
   
   // 2) Liquidity sweep signal (weight: 2 votes)
   if(m_sweep != NULL)
   {
      ENUM_SIGNAL_TYPE sweep_sig = m_sweep.GetSweepSignal();
      if(sweep_sig == SIGNAL_BUY) bullish_votes += 2;
      else if(sweep_sig == SIGNAL_SELL) bearish_votes += 2;
   }

   // 3) OB proximity (weight: 2 votes)
   double bull_ob = (m_ob_detector == NULL) ? 0 : m_ob_detector.GetProximityScore(OB_BULLISH);
   double bear_ob = (m_ob_detector == NULL) ? 0 : m_ob_detector.GetProximityScore(OB_BEARISH);
   if(bull_ob > 60) bullish_votes += 2;
   if(bear_ob > 60) bearish_votes += 2;

   // 4) FVG proximity (weight: 1 vote)
   double bull_fvg = (m_fvg_detector == NULL) ? 0 : m_fvg_detector.GetProximityScore(FVG_BULLISH);
   double bear_fvg = (m_fvg_detector == NULL) ? 0 : m_fvg_detector.GetProximityScore(FVG_BEARISH);
   if(bull_fvg > 60) bullish_votes += 1;
   if(bear_fvg > 60) bearish_votes += 1;
   
   // 5) AMD phase alignment (weight: 1 vote)
   if(m_amd != NULL)
   {
      ENUM_AMD_PHASE phase = m_amd.GetCurrentPhase();
      if(phase == AMD_PHASE_DISTRIBUTION)
      {
         // Distribution follows accumulation direction
         if(m_structure != NULL && m_structure.GetCurrentBias() == BIAS_BULLISH)
            bullish_votes += 1;
         else if(m_structure != NULL && m_structure.GetCurrentBias() == BIAS_BEARISH)
            bearish_votes += 1;
      }
   }
   
   // v3.31: 6) MTF Alignment (weight: 4 votes - CRITICAL!)
   if(m_mtf != NULL)
   {
      SMTFConfluence mtf_conf = m_mtf.GetConfluence();
      
      // HTF (H1) direction is the strongest signal
      if(mtf_conf.htf_trend == MTF_TREND_BULLISH)
         bullish_votes += 4;
      else if(mtf_conf.htf_trend == MTF_TREND_BEARISH)
         bearish_votes += 4;
      
      // LTF confirmation adds weight
      if(mtf_conf.ltf_confirmed && mtf_conf.signal == SIGNAL_BUY)
         bullish_votes += 1;
      else if(mtf_conf.ltf_confirmed && mtf_conf.signal == SIGNAL_SELL)
         bearish_votes += 1;
   }
   
   // v3.31: 7) Footprint/Order Flow (weight: 2 votes)
   if(m_footprint != NULL)
   {
      SFootprintSignal fp_sig = m_footprint.GetSignal();
      
      // Stacked imbalance is directional
      if(fp_sig.hasStackedBuyImbalance)
         bullish_votes += 2;
      if(fp_sig.hasStackedSellImbalance)
         bearish_votes += 2;
      
      // Strong signal adds vote
      if(fp_sig.signal == FP_SIGNAL_STRONG_BUY || fp_sig.signal == FP_SIGNAL_BUY)
         bullish_votes += 1;
      else if(fp_sig.signal == FP_SIGNAL_STRONG_SELL || fp_sig.signal == FP_SIGNAL_SELL)
         bearish_votes += 1;
   }
   
   // Determine direction by vote majority (configurable margin)
   // v4.3: Total possible votes now: 2+2+2+1+1+4+1+2+1 = 16 per side (structure reduced from 3 to 2)
   // Note: margin=0 means simple majority (ties -> SIGNAL_NONE)
   int margin = (m_vote_margin < 0) ? 0 : m_vote_margin;
   if(bullish_votes >= bearish_votes + margin && bullish_votes > bearish_votes)
      return SIGNAL_BUY;
   else if(bearish_votes >= bullish_votes + margin && bearish_votes > bullish_votes)
      return SIGNAL_SELL;
   
   return SIGNAL_NONE;
}

ENUM_SIGNAL_QUALITY CConfluenceScorer::ClassifyQuality(double score)
{
   if(score >= TIER_S_MIN) return QUALITY_ELITE;
   if(score >= TIER_A_MIN) return QUALITY_HIGH;
   if(score >= TIER_B_MIN) return QUALITY_MEDIUM;

   // v4.2: Align lowest valid tier with configured base minimum score.
   // This prevents the "threshold < 60 but quality invalid" deadlock.
   double low_min = (double)MathMax(50, m_min_score);
   if(score >= low_min) return QUALITY_LOW;

   return QUALITY_INVALID;
}

// === TRADE SETUP ===
void CConfluenceScorer::CalculateTradeSetup(SConfluenceResult &result, double current_price)
{
   double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   double atr_buffer = 200 * point; // ~20 pips default
   
   // v3.31: Use cached ATR handle for performance (FORGE optimization)
   if(m_atr_handle != INVALID_HANDLE)
   {
      double atr[];
      ArraySetAsSeries(atr, true);  // v3.31: Proper array setup
      if(CopyBuffer(m_atr_handle, 0, 0, 1, atr) > 0)
         atr_buffer = atr[0];
   }
   
   result.entry_price = current_price;
   
   if(result.direction == SIGNAL_BUY)
   {
      result.stop_loss = current_price - atr_buffer * 1.5;
      result.take_profit_1 = current_price + atr_buffer * 2.0;
      result.take_profit_2 = current_price + atr_buffer * 3.0;
   }
   else if(result.direction == SIGNAL_SELL)
   {
      result.stop_loss = current_price + atr_buffer * 1.5;
      result.take_profit_1 = current_price - atr_buffer * 2.0;
      result.take_profit_2 = current_price - atr_buffer * 3.0;
   }
   
   // Calculate R:R
   double risk = MathAbs(result.entry_price - result.stop_loss);
   double reward = MathAbs(result.take_profit_1 - result.entry_price);
   result.risk_reward = (risk > 0) ? reward / risk : 0;
}

// === VALIDATION ===
bool CConfluenceScorer::IsValidSetup(const SConfluenceResult &result)
{
   // Must have direction
   if(result.direction == SIGNAL_NONE)
      return false;

   // v3.32 GENIUS: Session Gate - Block trades outside active sessions
   // DEAD sessions (21:00-00:00 GMT) = low liquidity, wide spreads, erratic moves
   // This is ORTHOGONAL to regime detection (Hurst/Entropy check market TYPE, not TIME)
   if(m_mtf != NULL && !m_mtf.IsInActiveSession())
   {
      static datetime last_session_block_log = 0;
      if(TimeCurrent() - last_session_block_log > 300) // Log once per 5 min
      {
         Print("[Confluence v3.32] BLOCKED: Dead/Asian session (quality=",
               DoubleToString(m_mtf.GetSessionQuality() * 100, 0), "%) - No edge");
         last_session_block_log = TimeCurrent();
      }
      return false;
   }

   // v4.0 GENIUS: Use ADAPTIVE threshold (volatility-based)
   // Then apply regime-specific adjustments on top
   int effective_min_score = GetAdaptiveThreshold();  // v4.0: ATR-based threshold
   int effective_min_confluences = m_min_confluences;
   
   if(m_regime != NULL)
   {
      SRegimeStrategy strategy = m_regime.GetCurrentStrategy();
      
      // If entry is disabled for this regime, reject immediately
      if(strategy.entry_mode == ENTRY_MODE_DISABLED)
      {
         Print("[Confluence v4.0] Entry DISABLED for regime: ", strategy.philosophy);
         return false;
      }
      
      // Regime can further INCREASE threshold (never decrease from adaptive)
      int regime_min = (int)strategy.min_confluence;
      if(regime_min > effective_min_score)
      {
         effective_min_score = regime_min;
         
         static datetime last_log = 0;
         if(TimeCurrent() - last_log > 300)
         {
            Print("[Confluence v4.0] Regime raised threshold to ", regime_min, 
                  " | Philosophy: ", strategy.philosophy);
            last_log = TimeCurrent();
         }
      }
   }
   
   // v4.0 GENIUS: Log sequence state for debugging
   if(m_last_sequence_bonus != 0)
   {
      static datetime last_seq_log = 0;
      if(TimeCurrent() - last_seq_log > 300)
      {
         Print("[Confluence v4.0 GENIUS] Sequence: ", m_sequence.GetSequenceString(),
               " | Bonus: ", m_last_sequence_bonus);
         last_seq_log = TimeCurrent();
      }
   }
   
   // Must meet minimum score (adaptive + regime)
   if(result.total_score < effective_min_score)
      return false;
   
   // Must have minimum confluences
   if(result.total_confluences < effective_min_confluences)
      return false;
   
   // Must pass regime filter (not random walk)
   if(!PassesRegimeFilter())
      return false;
   
   // Must have valid quality
   if(result.quality == QUALITY_INVALID)
      return false;
   
   return true;
}

bool CConfluenceScorer::PassesRegimeFilter()
{
   if(m_regime == NULL) return true; // No filter if no detector
   
   // Block trades in random walk regime
   return m_regime.IsTradingAllowed();
}

bool CConfluenceScorer::PassesStructureFilter()
{
   if(m_structure == NULL) return true;
   
   // Require clear bias (not ranging or transition)
   ENUM_MARKET_BIAS bias = m_structure.GetCurrentBias();
   return (bias == BIAS_BULLISH || bias == BIAS_BEARISH);
}

//+------------------------------------------------------------------+
//| v4.0 GENIUS: Adaptive Threshold based on ATR volatility          |
//| Adjusts min_score based on current vs average volatility         |
//| High vol → Higher threshold (only elite setups)                  |
//| Low vol → Lower threshold (capture clean moves)                  |
//+------------------------------------------------------------------+
int CConfluenceScorer::GetAdaptiveThreshold()
{
   int base = m_min_score;  // Default: 70
   
   // Need both ATR handles
   if(m_atr_handle == INVALID_HANDLE || m_avg_atr_handle == INVALID_HANDLE)
      return base;
   
   double current_atr[], avg_atr[];
   ArraySetAsSeries(current_atr, true);
   ArraySetAsSeries(avg_atr, true);
   
   // Get current 14-bar ATR and 100-bar average ATR
   if(CopyBuffer(m_atr_handle, 0, 0, 1, current_atr) <= 0)
      return base;
   if(CopyBuffer(m_avg_atr_handle, 0, 0, 1, avg_atr) <= 0)
      return base;
   
   // Avoid division by zero
   if(avg_atr[0] <= 0)
      return base;
   
   double atr_ratio = current_atr[0] / avg_atr[0];
   
   // Volatility-adaptive adjustments
   int adjustment = 0;
   
   if(atr_ratio > 2.0)
   {
      // NFP/FOMC territory - EXTREME volatility
      adjustment = 15;  // Require 85+ (only elite setups survive chaos)
   }
   else if(atr_ratio > 1.5)
   {
      // High volatility - news or momentum event
      adjustment = 10;  // Require 80+
   }
   else if(atr_ratio > 1.2)
   {
      // Above average - trending conditions
      adjustment = 5;   // Require 75+
   }
   else if(atr_ratio < 0.5)
   {
      // Very quiet - Asian session or pre-news
      adjustment = -15; // Accept 55+ (more opportunities in clean markets)
   }
   else if(atr_ratio < 0.7)
   {
      // Below average - consolidation
      adjustment = -10; // Accept 60+
   }
   else if(atr_ratio < 0.85)
   {
      // Slightly below average
      adjustment = -5;  // Accept 65+
   }
   // else: Normal volatility, use base threshold
   
   int adaptive_threshold = base + adjustment;
   
   // Clamp to reasonable range [20, 95]
   // NOTE: EA input may set lower thresholds for backtest exploration; EA still enforces its own execution threshold.
   adaptive_threshold = MathMax(20, MathMin(95, adaptive_threshold));
   
   // Log significant adjustments (once per 5 min)
   if(adjustment != 0)
   {
      static datetime last_log = 0;
      if(TimeCurrent() - last_log > 300)
      {
         Print("[Confluence v4.0 GENIUS] Adaptive Threshold: ", adaptive_threshold,
               " (base=", base, ", adj=", adjustment, 
               ", ATR_ratio=", DoubleToString(atr_ratio, 2), ")");
         last_log = TimeCurrent();
      }
   }
   
   return adaptive_threshold;
}

//+------------------------------------------------------------------+
//| v4.0 GENIUS: Build ICT Sequential Confirmation State             |
//| Validates that factors appeared in correct ICT order             |
//| Sequence: Regime → HTF → Sweep → BOS → POI → LTF → Flow          |
//+------------------------------------------------------------------+
void CConfluenceScorer::BuildSequenceState(const SConfluenceResult &result)
{
   m_sequence.Reset();
   
   // Step 1: Regime OK (Hurst trending or reverting, not random walk)
   if(m_regime != NULL)
   {
      m_sequence.regime_ok = m_regime.IsTradingAllowed();
   }
   else
   {
      m_sequence.regime_ok = true;  // Default to OK if no detector
   }
   
   // Step 2: HTF (H1) Direction Set
   if(m_mtf != NULL)
   {
      SMTFConfluence mtf_conf = m_mtf.GetConfluence();
      m_sequence.htf_direction_set = (mtf_conf.htf_trend == MTF_TREND_BULLISH || 
                                       mtf_conf.htf_trend == MTF_TREND_BEARISH);
   }
   else if(m_structure != NULL)
   {
      // Fallback to structure bias
      ENUM_MARKET_BIAS bias = m_structure.GetCurrentBias();
      m_sequence.htf_direction_set = (bias == BIAS_BULLISH || bias == BIAS_BEARISH);
   }
   
   // Step 3: Sweep Occurred (optional but valuable)
   if(m_sweep != NULL)
   {
      m_sequence.sweep_occurred = m_sweep.HasRecentSweep(15);  // Last 15 bars
   }
   
   // Step 4: Structure Broken (BOS/CHoCH)
   if(m_structure != NULL)
   {
      SStructureState state = m_structure.GetState();
      m_sequence.structure_broken = (state.bos_count > 0 || state.choch_count > 0);
   }
   
   // Step 5: At POI (Order Block or FVG - CRITICAL!)
   bool at_ob = (result.ob_score >= 60);
   bool at_fvg = (result.fvg_score >= 60);
   m_sequence.at_poi = (at_ob || at_fvg);
   
   // Step 6: LTF (M5) Confirmation
   if(m_mtf != NULL)
   {
      SMTFConfluence mtf_conf = m_mtf.GetConfluence();
      m_sequence.ltf_confirmed = mtf_conf.ltf_confirmed;
   }
   
   // Step 7: Order Flow Confirmation
   if(m_footprint != NULL)
   {
      SFootprintSignal fp_sig = m_footprint.GetSignal();
      // Flow confirms if we have stacked imbalance or absorption in trade direction
      bool buy_flow = (fp_sig.hasStackedBuyImbalance || fp_sig.hasBuyAbsorption);
      bool sell_flow = (fp_sig.hasStackedSellImbalance || fp_sig.hasSellAbsorption);
      
      if(result.direction == SIGNAL_BUY)
         m_sequence.flow_confirmed = buy_flow;
      else if(result.direction == SIGNAL_SELL)
         m_sequence.flow_confirmed = sell_flow;
   }
   
   // Cache the sequence bonus
   m_last_sequence_bonus = m_sequence.GetSequenceBonus();
}

//+------------------------------------------------------------------+
//| v4.1 GENIUS: Build Alignment State from factor scores            |
//| Classifies each factor as bullish/bearish/neutral for multiplier |
//+------------------------------------------------------------------+
void CConfluenceScorer::BuildAlignmentState(const SConfluenceResult &result)
{
   m_alignment.Reset();
   
   // Classify each factor based on score AND direction
   // Strong: score > 70, Weak: 50-70, Neutral: < 50
   
   // Helper lambda-like classification
   // Factor contributes to direction if score > threshold AND aligns with result direction
   
   // 1. Structure - contributes to its bias direction
   if(m_structure != NULL)
   {
      ENUM_MARKET_BIAS bias = m_structure.GetCurrentBias();
      if(result.structure_score > 70)
      {
         if(bias == BIAS_BULLISH) m_alignment.strong_bullish++;
         else if(bias == BIAS_BEARISH) m_alignment.strong_bearish++;
         else m_alignment.neutral++;
      }
      else if(result.structure_score >= 50)
      {
         if(bias == BIAS_BULLISH) m_alignment.weak_bullish++;
         else if(bias == BIAS_BEARISH) m_alignment.weak_bearish++;
         else m_alignment.neutral++;
      }
      else m_alignment.neutral++;
   }
   
   // 2. Regime - generally neutral (doesn't vote direction)
   if(result.regime_score > 70) m_alignment.neutral++;  // Regime is regime, not directional
   else m_alignment.neutral++;
   
   // 3. Sweep - directional based on sweep type
   if(m_sweep != NULL && result.sweep_score > 50)
   {
      ENUM_SIGNAL_TYPE sweep_sig = m_sweep.GetSweepSignal();
      if(result.sweep_score > 70)
      {
         if(sweep_sig == SIGNAL_BUY) m_alignment.strong_bullish++;
         else if(sweep_sig == SIGNAL_SELL) m_alignment.strong_bearish++;
         else m_alignment.neutral++;
      }
      else
      {
         if(sweep_sig == SIGNAL_BUY) m_alignment.weak_bullish++;
         else if(sweep_sig == SIGNAL_SELL) m_alignment.weak_bearish++;
         else m_alignment.neutral++;
      }
   }
   else m_alignment.neutral++;
   
   // 4. AMD - directional in Distribution phase only
   if(m_amd != NULL)
   {
      ENUM_AMD_PHASE phase = m_amd.GetCurrentPhase();
      if(phase == AMD_PHASE_DISTRIBUTION && result.amd_score > 70)
      {
         // Distribution follows accumulation direction (use structure bias)
         if(m_structure != NULL)
         {
            ENUM_MARKET_BIAS bias = m_structure.GetCurrentBias();
            if(bias == BIAS_BULLISH) m_alignment.strong_bullish++;
            else if(bias == BIAS_BEARISH) m_alignment.strong_bearish++;
            else m_alignment.neutral++;
         }
         else m_alignment.neutral++;
      }
      else m_alignment.neutral++;
   }
   
   // 5. OB - Check which OB type is active
   if(m_ob_detector != NULL)
   {
      double bull_ob = m_ob_detector.GetProximityScore(OB_BULLISH);
      double bear_ob = m_ob_detector.GetProximityScore(OB_BEARISH);
      
      if(bull_ob > 70) m_alignment.strong_bullish++;
      else if(bull_ob > 50) m_alignment.weak_bullish++;
      
      if(bear_ob > 70) m_alignment.strong_bearish++;
      else if(bear_ob > 50) m_alignment.weak_bearish++;
      
      if(bull_ob <= 50 && bear_ob <= 50) m_alignment.neutral++;
   }
   
   // 6. FVG - Check which FVG type is active
   if(m_fvg_detector != NULL)
   {
      double bull_fvg = m_fvg_detector.GetProximityScore(FVG_BULLISH);
      double bear_fvg = m_fvg_detector.GetProximityScore(FVG_BEARISH);
      
      if(bull_fvg > 70) m_alignment.strong_bullish++;
      else if(bull_fvg > 50) m_alignment.weak_bullish++;
      
      if(bear_fvg > 70) m_alignment.strong_bearish++;
      else if(bear_fvg > 50) m_alignment.weak_bearish++;
      
      if(bull_fvg <= 50 && bear_fvg <= 50) m_alignment.neutral++;
   }
   
   // 7. MTF - Very directional (H1 trend is key)
   if(m_mtf != NULL)
   {
      SMTFConfluence mtf_conf = m_mtf.GetConfluence();
      if(result.mtf_score > 70)
      {
         if(mtf_conf.htf_trend == MTF_TREND_BULLISH) m_alignment.strong_bullish++;
         else if(mtf_conf.htf_trend == MTF_TREND_BEARISH) m_alignment.strong_bearish++;
         else m_alignment.neutral++;
      }
      else if(result.mtf_score > 50)
      {
         if(mtf_conf.htf_trend == MTF_TREND_BULLISH) m_alignment.weak_bullish++;
         else if(mtf_conf.htf_trend == MTF_TREND_BEARISH) m_alignment.weak_bearish++;
         else m_alignment.neutral++;
      }
      else m_alignment.neutral++;
   }
   
   // 8. Footprint - Directional based on signal
   if(m_footprint != NULL)
   {
      SFootprintSignal fp_sig = m_footprint.GetSignal();
      if(result.footprint_score > 70)
      {
         if(fp_sig.hasStackedBuyImbalance || fp_sig.signal == FP_SIGNAL_STRONG_BUY)
            m_alignment.strong_bullish++;
         else if(fp_sig.hasStackedSellImbalance || fp_sig.signal == FP_SIGNAL_STRONG_SELL)
            m_alignment.strong_bearish++;
         else m_alignment.neutral++;
      }
      else if(result.footprint_score > 50)
      {
         if(fp_sig.signal == FP_SIGNAL_BUY || fp_sig.signal == FP_SIGNAL_WEAK_BUY)
            m_alignment.weak_bullish++;
         else if(fp_sig.signal == FP_SIGNAL_SELL || fp_sig.signal == FP_SIGNAL_WEAK_SELL)
            m_alignment.weak_bearish++;
         else m_alignment.neutral++;
      }
      else m_alignment.neutral++;
   }
   
   // Cache the alignment multiplier
   m_alignment_mult = m_alignment.GetAlignmentMultiplier();
}

//+------------------------------------------------------------------+
//| v4.1 GENIUS: Build Freshness State from signal ages              |
//| Calculates how "fresh" each signal source is (bars ago)          |
//| NOTE: Uses estimated freshness based on score (0.85 default)     |
//| TODO: Add GetBarsAgo() to detector classes for precise tracking  |
//+------------------------------------------------------------------+
void CConfluenceScorer::BuildFreshnessState()
{
   m_freshness.Reset();
   
   // v4.1: Until GetBarsAgo() methods are added to detectors,
   // use score-based freshness estimation:
   // - High score (>70) suggests recent/fresh signal = 0.95
   // - Medium score (50-70) suggests moderate freshness = 0.80
   // - Low score (<50) suggests stale signal = 0.60
   
   // OB Freshness - estimate from proximity score
   if(m_ob_detector != NULL)
   {
      double ob_score = MathMax(m_ob_detector.GetProximityScore(OB_BULLISH),
                                m_ob_detector.GetProximityScore(OB_BEARISH));
      if(ob_score > 70) m_freshness.ob_freshness = 0.95;
      else if(ob_score > 50) m_freshness.ob_freshness = 0.80;
      else m_freshness.ob_freshness = 0.60;
   }
   
   // FVG Freshness - estimate from proximity score
   if(m_fvg_detector != NULL)
   {
      double fvg_score = MathMax(m_fvg_detector.GetProximityScore(FVG_BULLISH),
                                 m_fvg_detector.GetProximityScore(FVG_BEARISH));
      if(fvg_score > 70) m_freshness.fvg_freshness = 0.95;
      else if(fvg_score > 50) m_freshness.fvg_freshness = 0.80;
      else m_freshness.fvg_freshness = 0.60;
   }
   
   // Sweep Freshness - use HasRecentSweep as indicator
   if(m_sweep != NULL)
   {
      if(m_sweep.HasRecentSweep(5)) m_freshness.sweep_freshness = 0.95;
      else if(m_sweep.HasRecentSweep(10)) m_freshness.sweep_freshness = 0.80;
      else if(m_sweep.HasRecentSweep(20)) m_freshness.sweep_freshness = 0.65;
      else m_freshness.sweep_freshness = 0.50;
   }
   
   // Structure Freshness - structure is more persistent, use state quality
   if(m_structure != NULL)
   {
      SStructureState state = m_structure.GetState();
      if(state.structure_quality > 70) m_freshness.structure_freshness = 0.95;
      else if(state.structure_quality > 50) m_freshness.structure_freshness = 0.85;
      else m_freshness.structure_freshness = 0.70;
   }
   
   // Cache the freshness multiplier
   m_freshness_mult = m_freshness.GetFreshnessMultiplier();
}

//+------------------------------------------------------------------+
//| v4.1 GENIUS: Build Divergence State from factor signals          |
//| Counts how many factors agree on direction vs disagree           |
//+------------------------------------------------------------------+
void CConfluenceScorer::BuildDivergenceState(const SConfluenceResult &result)
{
   m_divergence.Reset();
   
   // Count directional signals from each factor
   
   // 1. Structure bias
   if(m_structure != NULL && result.structure_score >= 50)
   {
      ENUM_MARKET_BIAS bias = m_structure.GetCurrentBias();
      if(bias == BIAS_BULLISH) m_divergence.bullish_signals++;
      else if(bias == BIAS_BEARISH) m_divergence.bearish_signals++;
      else m_divergence.neutral_signals++;
   }
   else m_divergence.neutral_signals++;
   
   // 2. Sweep signal
   if(m_sweep != NULL && result.sweep_score >= 50)
   {
      ENUM_SIGNAL_TYPE sig = m_sweep.GetSweepSignal();
      if(sig == SIGNAL_BUY) m_divergence.bullish_signals++;
      else if(sig == SIGNAL_SELL) m_divergence.bearish_signals++;
      else m_divergence.neutral_signals++;
   }
   else m_divergence.neutral_signals++;
   
   // 3. OB proximity (which side is active)
   if(m_ob_detector != NULL)
   {
      double bull_ob = m_ob_detector.GetProximityScore(OB_BULLISH);
      double bear_ob = m_ob_detector.GetProximityScore(OB_BEARISH);
      if(bull_ob > bear_ob && bull_ob >= 50) m_divergence.bullish_signals++;
      else if(bear_ob > bull_ob && bear_ob >= 50) m_divergence.bearish_signals++;
      else m_divergence.neutral_signals++;
   }
   
   // 4. FVG proximity
   if(m_fvg_detector != NULL)
   {
      double bull_fvg = m_fvg_detector.GetProximityScore(FVG_BULLISH);
      double bear_fvg = m_fvg_detector.GetProximityScore(FVG_BEARISH);
      if(bull_fvg > bear_fvg && bull_fvg >= 50) m_divergence.bullish_signals++;
      else if(bear_fvg > bull_fvg && bear_fvg >= 50) m_divergence.bearish_signals++;
      else m_divergence.neutral_signals++;
   }
   
   // 5. MTF alignment
   if(m_mtf != NULL && result.mtf_score >= 50)
   {
      SMTFConfluence conf = m_mtf.GetConfluence();
      if(conf.htf_trend == MTF_TREND_BULLISH) m_divergence.bullish_signals++;
      else if(conf.htf_trend == MTF_TREND_BEARISH) m_divergence.bearish_signals++;
      else m_divergence.neutral_signals++;
   }
   else m_divergence.neutral_signals++;
   
   // 6. Footprint signal
   if(m_footprint != NULL && result.footprint_score >= 50)
   {
      SFootprintSignal sig = m_footprint.GetSignal();
      if(sig.signal == FP_SIGNAL_STRONG_BUY || sig.signal == FP_SIGNAL_BUY)
         m_divergence.bullish_signals++;
      else if(sig.signal == FP_SIGNAL_STRONG_SELL || sig.signal == FP_SIGNAL_SELL)
         m_divergence.bearish_signals++;
      else m_divergence.neutral_signals++;
   }
   else m_divergence.neutral_signals++;
   
   // Cache the divergence penalty
   m_divergence_mult = m_divergence.GetDivergencePenalty();
}

// === HELPER METHODS ===
double CConfluenceScorer::NormalizeScore(double raw_score, double max_value)
{
   if(max_value <= 0) return 0;
   return MathMax(0, MathMin(100, (raw_score / max_value) * 100.0));
}

int CConfluenceScorer::CountConfluences(const SConfluenceResult &result)
{
   int count = 0;

   // v4.3: Use a presence threshold aligned with the configured base minimum score.
   // Keeps confluence counting meaningful when min score is set below 60 for backtest exploration.
   int present_threshold = MathMax(50, m_min_score);

   if(result.structure_score >= present_threshold) count++;
   if(result.regime_score >= present_threshold) count++;
   if(result.sweep_score >= present_threshold) count++;
   if(result.amd_score >= present_threshold) count++;
   if(result.ob_score >= present_threshold) count++;
   if(result.fvg_score >= present_threshold) count++;
   // v4.3: Use present_threshold for zone too (was hardcoded 70 causing inconsistency)
   if(result.premium_discount >= present_threshold) count++;

   // v3.31: Count new factors (FORGE genius upgrade)
   if(result.mtf_score >= present_threshold) count++;
   if(result.footprint_score >= present_threshold) count++;

   return count;
}

string CConfluenceScorer::BuildSignalReason(const SConfluenceResult &result)
{
   string reason = "";
   
   reason += DirectionToString(result.direction) + " | ";
   reason += "Score: " + DoubleToString(result.total_score, 1) + " | ";
   reason += "Quality: " + QualityToString(result.quality) + " | ";
   reason += "Confluences: " + IntegerToString(result.total_confluences);
   
   return reason;
}

// === UTILITY ===
string CConfluenceScorer::QualityToString(ENUM_SIGNAL_QUALITY quality)
{
   switch(quality)
   {
      case QUALITY_ELITE:   return "ELITE";
      case QUALITY_HIGH:    return "HIGH";
      case QUALITY_MEDIUM:  return "MEDIUM";
      case QUALITY_LOW:     return "LOW";
      case QUALITY_INVALID: return "INVALID";
      default:              return "UNKNOWN";
   }
}

string CConfluenceScorer::DirectionToString(ENUM_SIGNAL_TYPE dir)
{
   switch(dir)
   {
      case SIGNAL_BUY:  return "BUY";
      case SIGNAL_SELL: return "SELL";
      case SIGNAL_NONE: return "NONE";
      default:          return "UNKNOWN";
   }
}

void CConfluenceScorer::PrintResult(const SConfluenceResult &result)
{
   Print("=== CONFLUENCE RESULT v4.0 GENIUS ===");
   Print("Direction: ", DirectionToString(result.direction));
   Print("Quality: ", QualityToString(result.quality));
   Print("Total Score: ", DoubleToString(result.total_score, 1));
   Print("--- Original Factors ---");
   Print("  Structure: ", DoubleToString(result.structure_score, 1));
   Print("  Regime: ", DoubleToString(result.regime_score, 1));
   Print("  Sweep: ", DoubleToString(result.sweep_score, 1));
   Print("  AMD: ", DoubleToString(result.amd_score, 1));
   Print("  OB: ", DoubleToString(result.ob_score, 1));
   Print("  FVG: ", DoubleToString(result.fvg_score, 1));
   Print("  Zone: ", DoubleToString(result.premium_discount, 1));
   Print("--- v3.31 New Factors ---");
   Print("  MTF: ", DoubleToString(result.mtf_score, 1));
   Print("  Footprint: ", DoubleToString(result.footprint_score, 1));
   Print("--- v4.0 GENIUS ---");
   Print("  Adaptive Threshold: ", GetAdaptiveThreshold());
   Print("  Sequence: ", m_sequence.GetSequenceString());
   Print("  Sequence Bonus: ", m_last_sequence_bonus);
   Print("--- v4.1 GENIUS ---");
   Print("  Alignment: ", m_alignment.GetAlignmentString(), " | Mult: ", DoubleToString(m_alignment_mult, 2));
   Print("  Freshness: ", m_freshness.GetFreshnessString(), " | Mult: ", DoubleToString(m_freshness_mult, 2));
   Print("  Divergence: ", m_divergence.GetDivergenceString(), " | Mult: ", DoubleToString(m_divergence_mult, 2));
   double phase1_combined = m_alignment_mult * m_freshness_mult * m_divergence_mult;
   Print("  Phase1 Combined Mult: ", DoubleToString(phase1_combined, 3));
   Print("--- v4.2 GENIUS ---");
   Print("  Session: ", m_session_weights.GetSessionName(m_current_session), 
         " | Weights: ", m_use_session_weights ? "ON" : "OFF");
   Print("  ", m_learning.GetLearningString());
   Print("-----------------------------");
   Print("Confluences: ", result.total_confluences, "/9");
   Print("Valid: ", result.is_valid ? "YES" : "NO");
   Print("Position Size Mult: ", DoubleToString(result.position_size_mult, 2));
   if(result.is_valid)
   {
      Print("Entry: ", DoubleToString(result.entry_price, 2));
      Print("SL: ", DoubleToString(result.stop_loss, 2));
      Print("TP1: ", DoubleToString(result.take_profit_1, 2));
      Print("R:R: ", DoubleToString(result.risk_reward, 2));
   }
   Print("// FORGE v4.2: GENIUS Session Profiles + Adaptive Bayesian");
   Print("===============================");
}

//+------------------------------------------------------------------+
//| v4.2 GENIUS: Get Current Trading Session from GMT hour           |
//| Returns session type based on time of day                        |
//+------------------------------------------------------------------+
ENUM_CONFLUENCE_SESSION CConfluenceScorer::GetCurrentSession()
{
   // Get current GMT hour
   MqlDateTime dt;
   TimeToStruct(TimeGMT(), dt);
   int hour = dt.hour;
   
   // Session boundaries (GMT):
   // Asian:      00:00 - 08:00 (Tokyo/Sydney)
   // London:     08:00 - 12:00 (London open)
   // NY Overlap: 12:00 - 16:00 (BEST - both markets)
   // NY:         16:00 - 21:00 (NY afternoon)
   // Dead:       21:00 - 00:00 (no liquidity)
   
   if(hour >= 0 && hour < 8)
      return CONF_SESSION_ASIAN;
   else if(hour >= 8 && hour < 12)
      return CONF_SESSION_LONDON;
   else if(hour >= 12 && hour < 16)
      return CONF_SESSION_NY_OVERLAP;
   else if(hour >= 16 && hour < 21)
      return CONF_SESSION_NY;
   else
      return CONF_SESSION_DEAD;
}

//+------------------------------------------------------------------+
//| v4.2 GENIUS: Apply Session-Specific Weights                      |
//| Adjusts factor weights based on current trading session          |
//+------------------------------------------------------------------+
void CConfluenceScorer::ApplySessionWeights()
{
   if(!m_use_session_weights)
      return;  // Feature disabled
   
   ENUM_CONFLUENCE_SESSION new_session = GetCurrentSession();
   
   // Only update if session changed
   if(new_session != m_current_session)
   {
      m_current_session = new_session;
      m_session_weights.SetForSession(new_session);
      
      // Log session change (once per change)
      Print("[Confluence v4.2 GENIUS] Session changed to: ", 
            m_session_weights.GetSessionName(new_session));
   }
   
   // Apply session weights to main weights structure
   m_weights.w_structure = m_session_weights.w_structure;
   m_weights.w_regime = m_session_weights.w_regime;
   m_weights.w_sweep = m_session_weights.w_sweep;
   m_weights.w_amd = m_session_weights.w_amd;
   m_weights.w_ob = m_session_weights.w_ob;
   m_weights.w_fvg = m_session_weights.w_fvg;
   m_weights.w_zone = m_session_weights.w_zone;
   m_weights.w_mtf = m_session_weights.w_mtf;
   m_weights.w_footprint = m_session_weights.w_footprint;
}

//+------------------------------------------------------------------+
//| v4.2 GENIUS: Record Trade Outcome for Bayesian Learning          |
//| Call this after each trade closes to update learning state       |
//+------------------------------------------------------------------+
void CConfluenceScorer::RecordTradeOutcome(bool was_win)
{
   if(!m_use_adaptive_learning)
      return;  // Feature disabled
   
   // Record the outcome with the last cached result
   m_learning.RecordTradeOutcome(m_last_result, was_win);
   
   // Apply learned parameters to Bayesian priors
   m_learning.ApplyToParams(m_bayes);
   
   // Log learning progress periodically
   if(m_learning.total_trades % 10 == 0)  // Every 10 trades
   {
      Print("[Confluence v4.2 GENIUS] Bayesian Learning: ", m_learning.GetLearningString());
   }
}

//+------------------------------------------------------------------+
//| v4.3: Get VIX-based Score Adjustment for Gold Trades             |
//| VIX > 25 = risk-off = gold bullish bias (+5 to +10 for longs)   |
//| VIX < 15 = risk-on = gold bearish bias (-5 to -10 for longs)    |
//| VIX 15-25 = neutral zone = no adjustment                        |
//|                                                                  |
//| Gold as safe haven: high VIX = flight to safety = gold bullish  |
//| Low VIX = risk appetite = gold bearish (capital flows to risk)  |
//+------------------------------------------------------------------+
int CConfluenceScorer::GetVIXScoreAdjustment(ENUM_SIGNAL_TYPE direction)
{
   // No VIX data available - return neutral
   if(!m_vix_available || m_vix_level <= 0.0)
      return 0;

   int adjustment = 0;

   // === HIGH VIX (>25): Risk-off mode = Gold bullish bias ===
   // Formula: adjustment = (VIX - 25) * 0.5, capped at +10
   // Example: VIX=35 -> (35-25)*0.5 = +5 for longs
   // Example: VIX=45 -> (45-25)*0.5 = +10 for longs (capped)
   if(m_vix_level > 25.0)
   {
      double raw_adj = (m_vix_level - 25.0) * 0.5;
      int vix_bonus = (int)MathRound(MathMin(10, raw_adj));

      if(direction == SIGNAL_BUY)
         adjustment = vix_bonus;   // Bonus for gold longs
      else if(direction == SIGNAL_SELL)
         adjustment = -vix_bonus;  // Penalty for gold shorts
   }
   // === LOW VIX (<15): Risk-on mode = Gold bearish bias ===
   // Formula: adjustment = (15 - VIX) * 0.5, capped at +10
   // Example: VIX=10 -> (15-10)*0.5 = +2.5 for shorts
   // Example: VIX=5 -> (15-5)*0.5 = +5 for shorts
   else if(m_vix_level < 15.0)
   {
      double raw_adj = (15.0 - m_vix_level) * 0.5;
      int vix_penalty = (int)MathRound(MathMin(10, raw_adj));

      if(direction == SIGNAL_BUY)
         adjustment = -vix_penalty; // Penalty for gold longs
      else if(direction == SIGNAL_SELL)
         adjustment = vix_penalty;  // Bonus for gold shorts
   }
   // === NEUTRAL VIX (15-25): No adjustment ===
   // This is the normal volatility range

   return adjustment;
}

//+------------------------------------------------------------------+
