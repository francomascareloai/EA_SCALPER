//+------------------------------------------------------------------+
//|                                          SignalScoringModule.mqh |
//|                                                           Franco |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Franco"
#property link      "https://www.mql5.com"
#property strict

#include "../Core/Definitions.mqh"
#include "../Analysis/EliteOrderBlock.mqh"
#include "../Analysis/CFootprintAnalyzer.mqh"
#include "../Bridge/CFundamentalsBridge.mqh"

//+------------------------------------------------------------------+
//| Class: CSignalScoringModule                                      |
//| Purpose: Calculates trade scores based on technical, fundamental,|
//|          and sentiment analysis.                                 |
//+------------------------------------------------------------------+
class CSignalScoringModule
{
private:
   //--- Weights
   double            m_weight_tech;
   double            m_weight_fund;
   double            m_weight_sent;

   //--- Components
   CEliteOrderBlockDetector m_ob_detector;

   //--- External bridges (not owned)
   CFundamentalsBridge*     m_fundamentals_bridge;
   CFootprintAnalyzer*      m_footprint_analyzer;

   //--- State
   int               m_last_score;
   ENUM_ORDER_TYPE   m_last_direction;
   double            m_last_sl;
   double            m_last_tp;
   SAdvancedOrderBlock m_last_ob;
   bool              m_has_ob;

public:
                     CSignalScoringModule();
                    ~CSignalScoringModule();

   //--- Initialization
   bool              Init(double weight_tech, double weight_fund, double weight_sent);

   //--- Core Logic
   int               CalculateScore();
   
   //--- Getters
   int               GetLastScore() const { return m_last_score; }
   ENUM_ORDER_TYPE   GetDirection() const { return m_last_direction; }
   double            GetStopLossPrice() const { return m_last_sl; }
   double            GetTakeProfitPrice() const { return m_last_tp; }
   bool              GetBestOrderBlock(SAdvancedOrderBlock &ob) const { if(!m_has_ob) return false; ob = m_last_ob; return true; }
   CEliteOrderBlockDetector* GetOBDetector() { return &m_ob_detector; }

   //--- Bridge setters (for dependency injection)
   void              SetFundamentalsBridge(CFundamentalsBridge* bridge) { m_fundamentals_bridge = bridge; }
   void              SetFootprintAnalyzer(CFootprintAnalyzer* analyzer) { m_footprint_analyzer = analyzer; }

private:
   int               CalculateTechnicalScore();
   int               CalculateFundamentalScore(); // Placeholder for Phase 2
   int               CalculateSentimentScore();   // Placeholder for Phase 2
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalScoringModule::CSignalScoringModule() :
   m_weight_tech(0.6),
   m_weight_fund(0.25),
   m_weight_sent(0.15),
   m_fundamentals_bridge(NULL),
   m_footprint_analyzer(NULL),
   m_last_score(0),
   m_last_direction(WRONG_VALUE),
   m_last_sl(0.0),
   m_last_tp(0.0),
   m_has_ob(false)
{
   ZeroMemory(m_last_ob);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalScoringModule::~CSignalScoringModule()
{
}

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
bool CSignalScoringModule::Init(double weight_tech, double weight_fund, double weight_sent)
{
   // Normalize weights if they don't sum to 1.0 (optional, but good practice)
   double sum = weight_tech + weight_fund + weight_sent;
   if(sum <= 0) return false;

   m_weight_tech = weight_tech / sum;
   m_weight_fund = weight_fund / sum;
   m_weight_sent = weight_sent / sum;

   return true;
}

//+------------------------------------------------------------------+
//| Calculate Total Score                                            |
//+------------------------------------------------------------------+
int CSignalScoringModule::CalculateScore()
{
   // 1. Technical Score (MQL5 Local)
   int tech_score = CalculateTechnicalScore();

   // 2. Fundamental Score (Python - Placeholder)
   int fund_score = CalculateFundamentalScore();

   // 3. Sentiment Score (Python - Placeholder)
   int sent_score = CalculateSentimentScore();

   // Weighted Average
   double total_score = (tech_score * m_weight_tech) + 
                        (fund_score * m_weight_fund) + 
                        (sent_score * m_weight_sent);

   m_last_score = (int)MathRound(total_score);
   return m_last_score;
}

//+------------------------------------------------------------------+
//| Calculate Technical Score (Order Blocks + Confluence)            |
//+------------------------------------------------------------------+
int CSignalScoringModule::CalculateTechnicalScore()
{
   // Detect Order Blocks
   if(!m_ob_detector.DetectEliteOrderBlocks())
   {
      m_has_ob = false;
      return 0;
   }

   // Get the best Order Block (Sorted by quality in detector)
   if(m_ob_detector.GetCount() == 0) { m_has_ob = false; return 0; }

   SAdvancedOrderBlock best_ob = m_ob_detector.GetOrderBlock(0);
   m_last_ob = best_ob;
   m_has_ob = true;
   
   // Basic Validation
   if(best_ob.probability_score < 50) return 0;

   // Set Signal Properties
   if(best_ob.type == OB_BULLISH)
   {
      m_last_direction = ORDER_TYPE_BUY;
      m_last_sl = best_ob.low_price; // SL below OB
      // Simple 1:2 RR for MVP
      double risk = best_ob.refined_entry - m_last_sl;
      m_last_tp = best_ob.refined_entry + (risk * 2.0);
   }
   else if(best_ob.type == OB_BEARISH)
   {
      m_last_direction = ORDER_TYPE_SELL;
      m_last_sl = best_ob.high_price; // SL above OB
      // Simple 1:2 RR for MVP
      double risk = m_last_sl - best_ob.refined_entry;
      m_last_tp = best_ob.refined_entry - (risk * 2.0);
   }
   else
   {
      return 0;
   }

   // Return the Probability Score as the Technical Score
   return (int)MathRound(best_ob.probability_score);
}

//+------------------------------------------------------------------+
//| Calculate Fundamental Score (Placeholder)                        |
//+------------------------------------------------------------------+
int CSignalScoringModule::CalculateFundamentalScore()
{
   return 50; // Neutral
}

//+------------------------------------------------------------------+
//| Calculate Sentiment Score                                        |
//| Sources (priority order):                                        |
//|   1. CFundamentalsBridge sentiment from Python Hub              |
//|   2. Footprint delta as sentiment proxy (order flow bias)       |
//|   3. Neutral fallback (50)                                       |
//+------------------------------------------------------------------+
int CSignalScoringModule::CalculateSentimentScore()
{
   // === SOURCE 1: CFundamentalsBridge (Python Hub) ===
   // Returns sentiment_score from fundamentals API
   // Score range: 0-100 (0=extreme bearish, 50=neutral, 100=extreme bullish)
   if(m_fundamentals_bridge != NULL && m_fundamentals_bridge.IsConnected())
   {
      double sent = m_fundamentals_bridge.GetSentimentScore();
      // Validate: sentiment_score from bridge is 0-100
      // Formula: received_score = bridge.GetSentimentScore()
      // Example: sent=75 -> return 75 (bullish sentiment)
      if(sent > 0.0)
      {
         // Clamp to valid range
         int score = (int)MathRound(MathMax(0, MathMin(100, sent)));
         return score;
      }
   }

   // === SOURCE 2: Footprint Delta as Sentiment Proxy ===
   // Delta = Ask Volume - Bid Volume
   // Positive delta = buyers dominating = bullish sentiment
   // Negative delta = sellers dominating = bearish sentiment
   // Formula: sentiment = 50 + (delta_percent * 0.5)
   // Example: delta_percent=+40% -> sentiment = 50 + 20 = 70 (bullish)
   // Example: delta_percent=-30% -> sentiment = 50 - 15 = 35 (bearish)
   if(m_footprint_analyzer != NULL)
   {
      SFootprintSignal sig = m_footprint_analyzer.GetSignal();
      double delta_pct = sig.deltaPercent;  // -100 to +100

      // Scale delta percentage to sentiment score (0-100)
      // delta_pct of +100 -> sentiment of 100
      // delta_pct of -100 -> sentiment of 0
      // delta_pct of 0 -> sentiment of 50
      double sentiment = 50.0 + (delta_pct * 0.5);
      int score = (int)MathRound(MathMax(0, MathMin(100, sentiment)));
      return score;
   }

   // === SOURCE 3: Neutral fallback ===
   // No data sources available, return neutral
   return 50;
}
