//+------------------------------------------------------------------+
//|                                      CFundamentalsIntegrator.mqh |
//|                                                           Franco |
//|                 EA_SCALPER_XAUUSD - Fundamentals + Technical Fusion|
//+------------------------------------------------------------------+
#property copyright "Franco"
#property link      "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property strict

#include "CConfluenceScorer.mqh"
#include "../Bridge/CFundamentalsBridge.mqh"

//+------------------------------------------------------------------+
//| Estrutura para resultado integrado                                |
//+------------------------------------------------------------------+
struct SIntegratedSignal
{
   // From Technical (CConfluenceScorer)
   ENUM_SIGNAL_TYPE     tech_direction;
   ENUM_SIGNAL_QUALITY  tech_quality;
   double               tech_score;        // 0-100
   
   // From Fundamentals (CFundamentalsBridge)
   string               fund_signal;       // STRONG_BUY, BUY, etc
   double               fund_score;        // -10 to +10
   int                  fund_adjustment;   // Score adjustment
   double               fund_confidence;
   string               fund_bias;
   
   // Integrated Result
   double               final_score;       // Combined score (0-100)
   ENUM_SIGNAL_TYPE     final_direction;
   ENUM_SIGNAL_QUALITY  final_quality;
   double               size_multiplier;   // Combined from regime + fundamentals
   double               confidence;        // Overall confidence
   
   // Alignment check
   bool                 is_aligned;        // Tech and Fund agree?
   int                  alignment_bonus;   // Bonus for alignment
   
   // Trade recommendation
   bool                 should_trade;
   string               reason;
   
   // Metadata
   datetime             timestamp;
   bool                 fund_available;    // Was fundamentals data available?
};

//+------------------------------------------------------------------+
//| Integrator Configuration                                          |
//+------------------------------------------------------------------+
struct SIntegratorConfig
{
   double   tech_weight;          // Technical weight (default 70%)
   double   fund_weight;          // Fundamental weight (default 30%)
   int      alignment_bonus;      // Bonus when aligned (default 10)
   int      conflict_penalty;     // Penalty when conflicting (default -15)
   double   min_fund_confidence;  // Min fund confidence to use (default 0.4)
   int      min_integrated_score; // Min final score to trade (default 65)
   bool     require_fund_confirm; // Require fundamentals confirmation (default false)
};

//+------------------------------------------------------------------+
//| Class: CFundamentalsIntegrator                                    |
//| Purpose: Fuses Technical and Fundamental analysis for decisions   |
//+------------------------------------------------------------------+
class CFundamentalsIntegrator
{
private:
   CConfluenceScorer*     m_scorer;
   CFundamentalsBridge*   m_fund_bridge;
   
   SIntegratorConfig      m_config;
   SIntegratedSignal      m_last_signal;
   
   bool                   m_initialized;
   bool                   m_fund_enabled;
   
public:
                          CFundamentalsIntegrator();
                         ~CFundamentalsIntegrator();
   
   // Initialization
   bool                   Init(CConfluenceScorer* scorer, CFundamentalsBridge* bridge = NULL);
   void                   SetConfig(SIntegratorConfig& config) { m_config = config; }
   
   // Main integration
   SIntegratedSignal      GetIntegratedSignal(string symbol = NULL);
   
   // Convenience methods
   bool                   ShouldTrade() { return m_last_signal.should_trade; }
   ENUM_SIGNAL_TYPE       GetDirection() { return m_last_signal.final_direction; }
   double                 GetSizeMultiplier() { return m_last_signal.size_multiplier; }
   double                 GetFinalScore() { return m_last_signal.final_score; }
   
   // Status
   bool                   IsFundamentalsEnabled() { return m_fund_enabled; }
   bool                   IsFundamentalsAligned() { return m_last_signal.is_aligned; }
   
   // Utility
   void                   PrintSignal();
   
private:
   void                   InitDefaultConfig();
   bool                   CheckAlignment(ENUM_SIGNAL_TYPE tech_dir, string fund_signal);
   double                 FundSignalToScore(string signal);
   ENUM_SIGNAL_QUALITY    ScoreToQuality(double score);
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CFundamentalsIntegrator::CFundamentalsIntegrator()
{
   m_scorer = NULL;
   m_fund_bridge = NULL;
   m_initialized = false;
   m_fund_enabled = false;
   
   InitDefaultConfig();
   ZeroMemory(m_last_signal);
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CFundamentalsIntegrator::~CFundamentalsIntegrator()
{
   // Don't delete pointers - they're owned elsewhere
}

//+------------------------------------------------------------------+
//| Initialize default configuration                                  |
//+------------------------------------------------------------------+
void CFundamentalsIntegrator::InitDefaultConfig()
{
   m_config.tech_weight = 0.70;           // 70% technical
   m_config.fund_weight = 0.30;           // 30% fundamental
   m_config.alignment_bonus = 10;         // +10 when aligned
   m_config.conflict_penalty = -15;       // -15 when conflicting
   m_config.min_fund_confidence = 0.4;    // Minimum confidence to use
   m_config.min_integrated_score = 65;    // Minimum score to trade
   m_config.require_fund_confirm = false; // Don't require fundamentals
}

//+------------------------------------------------------------------+
//| Initialization                                                    |
//+------------------------------------------------------------------+
bool CFundamentalsIntegrator::Init(CConfluenceScorer* scorer, CFundamentalsBridge* bridge = NULL)
{
   if(scorer == NULL)
   {
      Print("CFundamentalsIntegrator: CConfluenceScorer is required");
      return false;
   }
   
   m_scorer = scorer;
   m_fund_bridge = bridge;
   
   // Check if fundamentals bridge is available
   if(m_fund_bridge != NULL && m_fund_bridge.IsConnected())
   {
      m_fund_enabled = true;
      Print("CFundamentalsIntegrator: Initialized WITH fundamentals (weight: ", 
            m_config.fund_weight * 100, "%)");
   }
   else
   {
      m_fund_enabled = false;
      Print("CFundamentalsIntegrator: Initialized WITHOUT fundamentals (100% technical)");
   }
   
   m_initialized = true;
   return true;
}

//+------------------------------------------------------------------+
//| Get Integrated Signal                                             |
//+------------------------------------------------------------------+
SIntegratedSignal CFundamentalsIntegrator::GetIntegratedSignal(string symbol = NULL)
{
   if(symbol == NULL) symbol = _Symbol;
   
   SIntegratedSignal result;
   ZeroMemory(result);
   result.timestamp = TimeCurrent();
   
   // === 1. GET TECHNICAL SCORE ===
   SConfluenceResult tech_result = m_scorer.CalculateConfluence(symbol);
   
   result.tech_direction = tech_result.direction;
   result.tech_quality = tech_result.quality;
   result.tech_score = tech_result.total_score;
   
   // === 2. GET FUNDAMENTALS (if available) ===
   SFundamentalsSignal fund_signal;
   fund_signal.Reset();
   result.fund_available = false;
   
   if(m_fund_enabled && m_fund_bridge != NULL)
   {
      if(m_fund_bridge.GetSignal(fund_signal) && fund_signal.is_valid)
      {
         result.fund_available = true;
         result.fund_signal = fund_signal.signal;
         result.fund_score = fund_signal.score;
         result.fund_adjustment = fund_signal.score_adjustment;
         result.fund_confidence = fund_signal.confidence;
         result.fund_bias = fund_signal.bias;
      }
   }
   
   // === 3. CALCULATE INTEGRATED SCORE ===
   double tech_weight = m_config.tech_weight;
   double fund_weight = result.fund_available ? m_config.fund_weight : 0.0;
   
   // Normalize weights
   double total_weight = tech_weight + fund_weight;
   tech_weight /= total_weight;
   fund_weight /= total_weight;
   
   // Convert fund score (-10 to +10) to 0-100 scale
   double fund_normalized = 0;
   if(result.fund_available)
   {
      fund_normalized = 50 + (result.fund_score * 5);  // -10 → 0, 0 → 50, +10 → 100
      fund_normalized = MathMax(0, MathMin(100, fund_normalized));
   }
   
   // Base integrated score
   result.final_score = (result.tech_score * tech_weight) + 
                        (fund_normalized * fund_weight);
   
   // === 4. CHECK ALIGNMENT ===
   result.is_aligned = CheckAlignment(result.tech_direction, result.fund_signal);
   
   if(result.fund_available)
   {
      if(result.is_aligned)
      {
         result.alignment_bonus = m_config.alignment_bonus;
         result.final_score += m_config.alignment_bonus;
      }
      else if(result.tech_direction != SIGNAL_NONE && 
              (result.fund_signal == "STRONG_BUY" || result.fund_signal == "STRONG_SELL" ||
               result.fund_signal == "BUY" || result.fund_signal == "SELL"))
      {
         // Conflict penalty
         result.alignment_bonus = m_config.conflict_penalty;
         result.final_score += m_config.conflict_penalty;
      }
   }
   
   // Clamp score
   result.final_score = MathMax(0, MathMin(100, result.final_score));
   
   // === 5. DETERMINE FINAL DIRECTION ===
   // Technical has priority
   result.final_direction = result.tech_direction;
   result.final_quality = ScoreToQuality(result.final_score);
   
   // === 6. CALCULATE SIZE MULTIPLIER ===
   // From technical (regime-based)
   double tech_size = tech_result.position_size_mult;
   
   // From fundamentals
   double fund_size = result.fund_available ? fund_signal.size_multiplier : 1.0;
   
   // Combined: minimum of both (conservative)
   result.size_multiplier = MathMin(tech_size, fund_size);
   
   // Boost if aligned
   if(result.is_aligned && result.fund_available)
   {
      result.size_multiplier = MathMin(1.0, result.size_multiplier * 1.2);
   }
   
   // === 7. CALCULATE CONFIDENCE ===
   result.confidence = result.final_score / 100.0;
   if(result.is_aligned && result.fund_available)
   {
      result.confidence = MathMin(1.0, result.confidence * 1.1);
   }
   
   // === 8. DETERMINE IF SHOULD TRADE ===
   result.should_trade = false;
   
   // Check minimum score
   if(result.final_score < m_config.min_integrated_score)
   {
      result.reason = StringFormat("Score %.1f below minimum %d", 
                                   result.final_score, m_config.min_integrated_score);
   }
   // Check direction
   else if(result.final_direction == SIGNAL_NONE)
   {
      result.reason = "No clear direction";
   }
   // Check fundamentals requirement
   else if(m_config.require_fund_confirm && !result.is_aligned)
   {
      result.reason = "Fundamentals not aligned (required)";
   }
   // Check fundamentals conflict (if strong)
   else if(result.fund_available && result.fund_confidence > 0.7 && !result.is_aligned &&
           (result.fund_signal == "STRONG_BUY" || result.fund_signal == "STRONG_SELL"))
   {
      result.reason = "Strong fundamental conflict detected";
   }
   else
   {
      result.should_trade = true;
      result.reason = StringFormat("Signal: %s | Score: %.1f | Quality: %s | Aligned: %s",
                                   (result.final_direction == SIGNAL_BUY ? "BUY" : "SELL"),
                                   result.final_score,
                                   (result.final_quality == QUALITY_ELITE ? "ELITE" :
                                    result.final_quality == QUALITY_HIGH ? "HIGH" :
                                    result.final_quality == QUALITY_MEDIUM ? "MEDIUM" : "LOW"),
                                   (result.is_aligned ? "YES" : "NO"));
   }
   
   m_last_signal = result;
   return result;
}

//+------------------------------------------------------------------+
//| Check if technical and fundamental signals are aligned            |
//+------------------------------------------------------------------+
bool CFundamentalsIntegrator::CheckAlignment(ENUM_SIGNAL_TYPE tech_dir, string fund_signal)
{
   if(tech_dir == SIGNAL_NONE)
      return true;  // No conflict if no tech signal
   
   if(fund_signal == "" || fund_signal == "NEUTRAL")
      return true;  // Neutral doesn't conflict
   
   bool tech_bullish = (tech_dir == SIGNAL_BUY);
   bool fund_bullish = (fund_signal == "STRONG_BUY" || fund_signal == "BUY");
   bool fund_bearish = (fund_signal == "STRONG_SELL" || fund_signal == "SELL");
   
   if(tech_bullish && fund_bullish)
      return true;
   
   if(!tech_bullish && fund_bearish)
      return true;
   
   // Conflict
   return false;
}

//+------------------------------------------------------------------+
//| Convert fund signal string to numeric score                       |
//+------------------------------------------------------------------+
double CFundamentalsIntegrator::FundSignalToScore(string signal)
{
   if(signal == "STRONG_BUY") return 8.0;
   if(signal == "BUY") return 5.0;
   if(signal == "NEUTRAL") return 0.0;
   if(signal == "SELL") return -5.0;
   if(signal == "STRONG_SELL") return -8.0;
   return 0.0;
}

//+------------------------------------------------------------------+
//| Convert score to quality                                          |
//+------------------------------------------------------------------+
ENUM_SIGNAL_QUALITY CFundamentalsIntegrator::ScoreToQuality(double score)
{
   if(score >= TIER_S_MIN) return QUALITY_ELITE;
   if(score >= TIER_A_MIN) return QUALITY_HIGH;
   if(score >= TIER_B_MIN) return QUALITY_MEDIUM;
   if(score >= TIER_C_MIN) return QUALITY_LOW;
   return QUALITY_INVALID;
}

//+------------------------------------------------------------------+
//| Print signal for debugging                                        |
//+------------------------------------------------------------------+
void CFundamentalsIntegrator::PrintSignal()
{
   Print("=== INTEGRATED SIGNAL ===");
   Print("Technical: ", EnumToString(m_last_signal.tech_direction), 
         " Score: ", m_last_signal.tech_score);
   
   if(m_last_signal.fund_available)
   {
      Print("Fundamental: ", m_last_signal.fund_signal,
            " Score: ", m_last_signal.fund_score,
            " Bias: ", m_last_signal.fund_bias);
   }
   else
   {
      Print("Fundamental: NOT AVAILABLE");
   }
   
   Print("Final: ", EnumToString(m_last_signal.final_direction),
         " Score: ", m_last_signal.final_score,
         " Quality: ", EnumToString(m_last_signal.final_quality));
   Print("Aligned: ", m_last_signal.is_aligned, 
         " Bonus: ", m_last_signal.alignment_bonus);
   Print("Size Mult: ", m_last_signal.size_multiplier,
         " Confidence: ", m_last_signal.confidence);
   Print("Should Trade: ", m_last_signal.should_trade);
   Print("Reason: ", m_last_signal.reason);
   Print("========================");
}

//+------------------------------------------------------------------+
