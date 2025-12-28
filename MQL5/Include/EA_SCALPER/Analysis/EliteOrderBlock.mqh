//+------------------------------------------------------------------+
//|                                              EliteOrderBlock.mqh |
//|                           Autonomous Expert Advisor for XAUUSD Trading |
//|                                     Order Block Detection Component |
//+------------------------------------------------------------------+
#property copyright "Developed by Autonomous AI Agent - FTMO Elite Trading System"
#property strict

#include "../Core/Definitions.mqh"

// === ELITE ORDER BLOCK DETECTOR CLASS ===
class CEliteOrderBlockDetector
{
private:
    // Detection parameters
    double              m_displacement_threshold;   // Minimum displacement for valid OB
    double              m_volume_threshold;         // Volume threshold for validation
    bool                m_require_structure_break;  // Structure break confirmation
    bool                m_use_liquidity_confirmation; // Liquidity confirmation
    bool                m_use_volume_confirmation;  // Volume confirmation

    // Multi-timeframe analysis
    int                 m_analysis_timeframes[4];   // Analysis timeframes (ENUM_TIMEFRAME)
    int                 m_timeframe_count;          // Number of timeframes

    // Cached indicator handles (performance optimization)
    int                 m_atr_handle_h1;            // ATR(14) on H1 for confluence/proximity

    // Data Storage
    SAdvancedOrderBlock m_order_blocks[50];
    int                 m_ob_count;
    
public:
    CEliteOrderBlockDetector();
    ~CEliteOrderBlockDetector();
    
    // Accessors
    int GetCount() { return m_ob_count; }
    SAdvancedOrderBlock GetOrderBlock(int index) { if(index >= 0 && index < 50) return m_order_blocks[index]; SAdvancedOrderBlock empty; ZeroMemory(empty); return empty; }
    // Helper to update OB in array
    void UpdateOrderBlock(int index, const SAdvancedOrderBlock& ob) { if(index >= 0 && index < 50) m_order_blocks[index] = ob; }
    
    // Main detection methods
    bool DetectEliteOrderBlocks();
    bool DetectPremiumOrderBlocks();
    bool DetectDiscountOrderBlocks();
    
    // Validation methods
    bool ValidateWithLiquidity(SAdvancedOrderBlock& ob);
    bool ValidateWithVolume(SAdvancedOrderBlock& ob);
    bool ValidateWithStructure(SAdvancedOrderBlock& ob);
    
    // Calculation methods
    double CalculateOptimalEntry(const SAdvancedOrderBlock& ob);
    double CalculateOrderBlockStrength(const SAdvancedOrderBlock& ob);
    double CalculateProbabilityScore(const SAdvancedOrderBlock& ob);
    ENUM_OB_QUALITY ClassifyOrderBlockQuality(const SAdvancedOrderBlock& ob);
    
    // Helper methods
    bool DetectBullishOrderBlock(const MqlRates& rates[], int index);
    bool DetectBearishOrderBlock(const MqlRates& rates[], int index);
    bool CreateOrderBlockStructure(const MqlRates& rates[], int index, ENUM_ORDER_BLOCK_TYPE type, SAdvancedOrderBlock& ob);
    bool ValidateOrderBlock(const SAdvancedOrderBlock& ob);
    void SortOrderBlocksByQuality();
    
    // Analysis helpers
    double CalculateAverageBodySize(const MqlRates& rates[], int index, int period);
    bool HasVolumeSpike(const MqlRates& rates[], int index);
    double CalculateDisplacementSize(const MqlRates& rates[], int index);
    double CalculateVolumeProfile(const MqlRates& rates[], int index);
    double CalculateReactionQuality(const MqlRates& rates[], int index);
    bool IsInstitutionalOrderBlock(const SAdvancedOrderBlock& ob);
    bool IsInPremiumZone(double price);
    bool IsInDiscountZone(double price);
    
    // Management methods
    void UpdateOrderBlockStatus();
    void RemoveInvalidOrderBlocks();
    int GetActiveOrderBlockCount();
    
    // Proximity methods for confluence scoring
    bool HasActiveOB(ENUM_ORDER_BLOCK_TYPE type);
    bool GetNearestOB(ENUM_ORDER_BLOCK_TYPE type, SAdvancedOrderBlock &ob);
    double GetProximityScore(ENUM_ORDER_BLOCK_TYPE type);
    bool IsPriceInOBZone(ENUM_ORDER_BLOCK_TYPE type);
    
    // Confluence checks (Internal)
    bool CheckFVGConfluence(const SAdvancedOrderBlock& ob);
    bool CheckLiquidityConfluence(const SAdvancedOrderBlock& ob);
    bool CheckStructureConfluence(const SAdvancedOrderBlock& ob);
    double CalculateConfluenceScore(const SAdvancedOrderBlock& ob);
};

// ... (Implementation) ...

// Constructor
CEliteOrderBlockDetector::CEliteOrderBlockDetector()
{
    // Initialize detection parameters for XAUUSD
    m_displacement_threshold = 200.0 * _Point;  // 20 pips displacement minimum
    m_volume_threshold = 1.5;                   // 1.5x average volume
    m_require_structure_break = true;           // Require structure break
    m_use_liquidity_confirmation = true;        // Use liquidity confirmation
    m_use_volume_confirmation = true;           // Use volume confirmation

    // Set analysis timeframes (MTF v3.20: M15 is primary for structure)
    m_analysis_timeframes[0] = PERIOD_H1;       // HTF - Direction
    m_analysis_timeframes[1] = PERIOD_M15;      // MTF - Primary Structure (OBs)
    m_analysis_timeframes[2] = PERIOD_M5;       // LTF - Entry confirmation
    m_analysis_timeframes[3] = PERIOD_M1;       // Micro - Precision entry
    m_timeframe_count = 4;

    m_ob_count = 0;

    // Create cached indicator handle for ATR on H1
    m_atr_handle_h1 = iATR(_Symbol, PERIOD_H1, 14);
    if(m_atr_handle_h1 == INVALID_HANDLE)
        Print("CEliteOrderBlockDetector: Failed to create ATR handle for H1");
}

// Destructor
CEliteOrderBlockDetector::~CEliteOrderBlockDetector()
{
    // Release cached indicator handle
    if(m_atr_handle_h1 != INVALID_HANDLE)
        IndicatorRelease(m_atr_handle_h1);
}

// Main detection method for elite order blocks
bool CEliteOrderBlockDetector::DetectEliteOrderBlocks()
{
    // Reset current order blocks count
    m_ob_count = 0;
    
    // Get market data for analysis (dynamic buffer for MqlRates)
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    if(CopyRates(_Symbol, PERIOD_M15, 0, 100, rates) <= 0)
        return false;
    
    // Analyze each potential order block formation
    for(int i = 5; i < 95; i++)
    {
        // Check for bullish order block pattern
        if(DetectBullishOrderBlock(rates, i))
        {
            SAdvancedOrderBlock ob;
            if(CreateOrderBlockStructure(rates, i, OB_BULLISH, ob))
            {
                if(ValidateOrderBlock(ob))
                {
                    m_order_blocks[m_ob_count] = ob;
                    m_ob_count++;
                    if(m_ob_count >= 50) break;
                }
            }
        }
        
        // Check for bearish order block pattern
        if(DetectBearishOrderBlock(rates, i))
        {
            SAdvancedOrderBlock ob;
            if(CreateOrderBlockStructure(rates, i, OB_BEARISH, ob))
            {
                if(ValidateOrderBlock(ob))
                {
                    m_order_blocks[m_ob_count] = ob;
                    m_ob_count++;
                    if(m_ob_count >= 50) break;
                }
            }
        }
    }
    
    // Sort order blocks by quality and proximity
    SortOrderBlocksByQuality();
    
    return m_ob_count > 0;
}

// Detect bullish order block formation
bool CEliteOrderBlockDetector::DetectBullishOrderBlock(const MqlRates& rates[], int index)
{
   if(index < 3 || index >= ArraySize(rates) - 2) return false;
   
   // ICT: bullish OB = last down candle before the up displacement
   double current_body = rates[index].close - rates[index].open;
   if(current_body >= 0) return false; // must be bearish candle
   
   double next_displacement = 0;
   // Array is series, so iterate towards newer bars (lower index) to measure move after the candle
   for(int j = index-1; j >= MathMax(0, index-5); j--)
   {
      if(rates[j].close > rates[index].high)
      {
         next_displacement = rates[j].close - rates[index].high;
         break;
      }
   }
   
   // Require meaningful body size relative to range
   double total_range = rates[index].high - rates[index].low;
   if(total_range <= 0 || MathAbs(current_body) < total_range * 0.5) return false;
   
   double avg_body = CalculateAverageBodySize(rates, index, 10);
   if(MathAbs(current_body) < avg_body * 1.5) return false;
   
   if(next_displacement < m_displacement_threshold) return false;
   
   if(m_use_volume_confirmation && !HasVolumeSpike(rates, index)) return false;
   
   return true;
}

// Detect bearish order block formation  
bool CEliteOrderBlockDetector::DetectBearishOrderBlock(const MqlRates& rates[], int index)
{
   if(index < 3 || index >= ArraySize(rates) - 2) return false;
   
   // ICT: bearish OB = last up candle before the down displacement
   double current_body = rates[index].open - rates[index].close;
   if(current_body >= 0) return false; // must be bullish candle
   
   double next_displacement = 0;
   for(int j = index-1; j >= MathMax(0, index-5); j--)
   {
      if(rates[j].close < rates[index].low)
      {
         next_displacement = rates[index].low - rates[j].close;
         break;
      }
   }
   
   double total_range = rates[index].high - rates[index].low;
   if(total_range <= 0 || MathAbs(current_body) < total_range * 0.5) return false;
   
   double avg_body = CalculateAverageBodySize(rates, index, 10);
   if(MathAbs(current_body) < avg_body * 1.5) return false;
   
   if(next_displacement < m_displacement_threshold) return false;
   
   if(m_use_volume_confirmation && !HasVolumeSpike(rates, index)) return false;
   
   return true;
}

// Create order block structure
bool CEliteOrderBlockDetector::CreateOrderBlockStructure(const MqlRates& rates[], int index, ENUM_ORDER_BLOCK_TYPE type, SAdvancedOrderBlock& ob)
{
    ob.formation_time = rates[index].time;
    ob.high_price = rates[index].high;
    ob.low_price = rates[index].low;
    ob.type = type;
    ob.state = OB_STATE_ACTIVE;
    ob.is_fresh = true;
    ob.touch_count = 0;
    ob.origin_timeframe = PERIOD_M15;
    
    if(type == OB_BULLISH)
    {
        ob.refined_entry = ob.low_price + (ob.high_price - ob.low_price) * 0.5; 
    }
    else
    {
        ob.refined_entry = ob.high_price - (ob.high_price - ob.low_price) * 0.5; 
    }
    
    ob.displacement_size = CalculateDisplacementSize(rates, index);
    ob.volume_profile = CalculateVolumeProfile(rates, index);
    ob.reaction_quality = CalculateReactionQuality(rates, index);
    
    double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    ob.is_premium = IsInPremiumZone(current_price);
    ob.is_institutional = IsInstitutionalOrderBlock(ob);
    
    ob.has_fvg_confluence = CheckFVGConfluence(ob);
    ob.has_liquidity_confluence = CheckLiquidityConfluence(ob);
    ob.has_liquidity = ob.has_liquidity_confluence; // populate required flag for validation
    ob.has_structure_confluence = CheckStructureConfluence(ob);
    ob.confluence_score = CalculateConfluenceScore(ob);
    
    ob.strength = CalculateOrderBlockStrength(ob);
    ob.probability_score = CalculateProbabilityScore(ob);
    ob.quality = ClassifyOrderBlockQuality(ob);
    
    return true;
}

// Validate order block quality and requirements
bool CEliteOrderBlockDetector::ValidateOrderBlock(const SAdvancedOrderBlock& ob)
{
    if(ob.strength < 60.0) return false;
    if(ob.probability_score < 70.0) return false;
    if(ob.quality < OB_QUALITY_MEDIUM) return false;
    if(ob.confluence_score < 65.0) return false;
    if(m_use_liquidity_confirmation && !ob.has_liquidity) return false;
    return true;
}

// Calculate order block strength
double CEliteOrderBlockDetector::CalculateOrderBlockStrength(const SAdvancedOrderBlock& ob)
{
    double strength = 0.0;
    strength += MathMin(ob.displacement_size / (100 * _Point), 30.0);
    strength += MathMin(ob.volume_profile * 20.0, 20.0);
    strength += ob.reaction_quality * 25.0;
    if(ob.is_institutional) strength += 15.0;
    if(ob.has_fvg_confluence) strength += 5.0;
    if(ob.has_liquidity_confluence) strength += 5.0;
    if(ob.has_structure_confluence) strength += 5.0;
    return MathMin(strength, 100.0);
}

// Calculate probability score
double CEliteOrderBlockDetector::CalculateProbabilityScore(const SAdvancedOrderBlock& ob)
{
    double probability = 50.0;
    switch(ob.quality)
    {
        case OB_QUALITY_HIGH: probability += 20.0; break;
        case OB_QUALITY_ELITE: probability += 30.0; break;
        case OB_QUALITY_MEDIUM: probability += 10.0; break;
        default: break;
    }
    if(ob.is_institutional) probability += 15.0;
    if(ob.is_fresh) probability += 10.0;
    if((ob.type == OB_BULLISH && !ob.is_premium) || (ob.type == OB_BEARISH && ob.is_premium))
    {
        probability += 15.0;
    }
    probability += ob.confluence_score * 0.2;
    return MathMin(probability, 100.0);
}

// Classify order block quality
ENUM_OB_QUALITY CEliteOrderBlockDetector::ClassifyOrderBlockQuality(const SAdvancedOrderBlock& ob)
{
    double quality_score = 0.0;
    if(ob.displacement_size >= 300 * _Point) quality_score += 25.0;
    else if(ob.displacement_size >= 200 * _Point) quality_score += 15.0;
    else if(ob.displacement_size >= 100 * _Point) quality_score += 10.0;
    
    if(ob.volume_profile > 1.8) quality_score += 25.0;
    else if(ob.volume_profile > 1.5) quality_score += 15.0;
    else if(ob.volume_profile > 1.2) quality_score += 10.0;
    
    quality_score += ob.reaction_quality * 25.0;
    if(ob.is_institutional) quality_score += 15.0;
    quality_score += ob.confluence_score * 0.1;
    
    if(quality_score >= 85.0) return OB_QUALITY_ELITE;
    if(quality_score >= 70.0) return OB_QUALITY_HIGH;
    if(quality_score >= 55.0) return OB_QUALITY_MEDIUM;
    return OB_QUALITY_LOW;
}

// Helper methods implementation
double CEliteOrderBlockDetector::CalculateAverageBodySize(const MqlRates& rates[], int index, int period)
{
    double total_body = 0.0;
    int count = 0;
    for(int i = index; i < index + period && i < ArraySize(rates); i++)
    {
        total_body += MathAbs(rates[i].close - rates[i].open);
        count++;
    }
    return (count > 0) ? total_body / count : 0.0;
}

bool CEliteOrderBlockDetector::HasVolumeSpike(const MqlRates& rates[], int index)
{
    if(index >= ArraySize(rates) - 5) return true;
    long current_volume = rates[index].tick_volume;
    long avg_volume = 0;
    int count = 0;
    for(int i = index + 1; i < index + 11 && i < ArraySize(rates); i++)
    {
        avg_volume += rates[i].tick_volume;
        count++;
    }
    avg_volume = (count > 0) ? avg_volume / count : 0;
    return current_volume > avg_volume * m_volume_threshold;
}

double CEliteOrderBlockDetector::CalculateDisplacementSize(const MqlRates& rates[], int index)
{
    if(index < 5) return 0.0;
    double max_displacement = 0.0;
    for(int i = index - 1; i >= MathMax(0, index - 5); i--)
    {
        double displacement = MathAbs(rates[i].close - rates[index].close);
        if(displacement > max_displacement)
            max_displacement = displacement;
    }
    return max_displacement;
}

double CEliteOrderBlockDetector::CalculateVolumeProfile(const MqlRates& rates[], int index)
{
    if(index >= ArraySize(rates) - 1) return 1.0;
    long current_volume = rates[index].tick_volume;
    long prev_volume = rates[index + 1].tick_volume;
    return (prev_volume > 0) ? (double)current_volume / prev_volume : 1.0;
}

double CEliteOrderBlockDetector::CalculateReactionQuality(const MqlRates& rates[], int index)
{
    if(index < 3) return 0.5;
    double initial_price = rates[index].close;
    double max_move = 0.0;
    for(int i = index - 1; i >= MathMax(0, index - 3); i--)
    {
        double move = MathAbs(rates[i].close - initial_price);
        if(move > max_move) max_move = move;
    }
    return MathMin(max_move / (100 * _Point), 1.0);
}

bool CEliteOrderBlockDetector::IsInstitutionalOrderBlock(const SAdvancedOrderBlock& ob)
{
    if(ob.displacement_size > 250 * _Point) return true;
    if(ob.volume_profile > 2.0) return true;
    if(ob.origin_timeframe >= PERIOD_H4) return true;
    return false;
}

bool CEliteOrderBlockDetector::CheckFVGConfluence(const SAdvancedOrderBlock& ob)
{
    // Check if OB zone overlaps with any FVG zone within 0.5 * ATR tolerance
    // Uses completed bars only (index >= 1) to avoid look-ahead bias

    // Use cached ATR handle for tolerance calculation
    if(m_atr_handle_h1 == INVALID_HANDLE) return false;

    double atr_buf[];
    ArrayResize(atr_buf, 1);
    if(CopyBuffer(m_atr_handle_h1, 0, 1, 1, atr_buf) <= 0)  // Use bar 1 (completed)
        return false;

    double atr = atr_buf[0];
    double tolerance = 0.5 * atr;

    // Get market data on M15 timeframe for FVG detection (use completed bars)
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    if(CopyRates(_Symbol, PERIOD_M15, 0, 100, rates) < 10)
        return false;

    // Scan for FVGs in recent history (bars 2-50, completed bars only)
    // FVG requires 3 consecutive candles: index+1 (oldest), index (middle), index-1 (newest)
    for(int i = 2; i < 50; i++)
    {
        if(i < 1 || i >= ArraySize(rates) - 1) continue;

        // Check for Bullish FVG: gap between candle 1 high and candle 3 low
        double fvg_upper_bull = rates[i-1].low;   // Candle 3 (newest) low
        double fvg_lower_bull = rates[i+1].high;  // Candle 1 (oldest) high
        if(fvg_upper_bull > fvg_lower_bull)  // Valid bullish FVG exists
        {
            // Check if OB zone overlaps with FVG zone (with tolerance)
            double ob_top = ob.high_price + tolerance;
            double ob_bottom = ob.low_price - tolerance;
            if(ob_bottom <= fvg_upper_bull && ob_top >= fvg_lower_bull)
                return true;
        }

        // Check for Bearish FVG: gap between candle 3 high and candle 1 low
        double fvg_upper_bear = rates[i+1].low;   // Candle 1 (oldest) low
        double fvg_lower_bear = rates[i-1].high;  // Candle 3 (newest) high
        if(fvg_upper_bear > fvg_lower_bear)  // Valid bearish FVG exists
        {
            // Check if OB zone overlaps with FVG zone (with tolerance)
            double ob_top = ob.high_price + tolerance;
            double ob_bottom = ob.low_price - tolerance;
            if(ob_bottom <= fvg_upper_bear && ob_top >= fvg_lower_bear)
                return true;
        }
    }

    return false;
}

bool CEliteOrderBlockDetector::CheckLiquidityConfluence(const SAdvancedOrderBlock& ob)
{
    return ob.displacement_size > 150 * _Point;
}

bool CEliteOrderBlockDetector::CheckStructureConfluence(const SAdvancedOrderBlock& ob)
{
    return m_require_structure_break;
}

double CEliteOrderBlockDetector::CalculateConfluenceScore(const SAdvancedOrderBlock& ob)
{
    double score = 0.0;
    if(ob.has_fvg_confluence) score += 30.0;
    if(ob.has_liquidity_confluence) score += 30.0;
    if(ob.has_structure_confluence) score += 40.0;
    return score;
}

bool CEliteOrderBlockDetector::IsInPremiumZone(double price)
{
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    if(CopyRates(_Symbol, PERIOD_H1, 0, 100, rates) <= 0) return false;
    double highest = rates[0].high;
    double lowest = rates[0].low;
    for(int i = 1; i < 100; i++)
    {
        if(rates[i].high > highest) highest = rates[i].high;
        if(rates[i].low < lowest) lowest = rates[i].low;
    }
    double range = highest - lowest;
    if(range <= 0) return false;
    double mid_point = lowest + range * 0.5;
    return price > mid_point;
}

bool CEliteOrderBlockDetector::IsInDiscountZone(double price)
{
    return !IsInPremiumZone(price);
}

void CEliteOrderBlockDetector::UpdateOrderBlockStatus()
{
    double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    for(int i = 0; i < m_ob_count; i++)
    {
        if(m_order_blocks[i].state == OB_STATE_ACTIVE || m_order_blocks[i].state == OB_STATE_TESTED)
        {
            if(m_order_blocks[i].type == OB_BULLISH)
            {
                if(current_price < m_order_blocks[i].low_price) m_order_blocks[i].state = OB_STATE_MITIGATED;
                else if(current_price <= m_order_blocks[i].high_price) { m_order_blocks[i].state = OB_STATE_TESTED; m_order_blocks[i].touch_count++; }
            }
            else
            {
                if(current_price > m_order_blocks[i].high_price) m_order_blocks[i].state = OB_STATE_MITIGATED;
                else if(current_price >= m_order_blocks[i].low_price) { m_order_blocks[i].state = OB_STATE_TESTED; m_order_blocks[i].touch_count++; }
            }
        }
    }
}

void CEliteOrderBlockDetector::RemoveInvalidOrderBlocks()
{
    int valid_count = 0;
    for(int i = 0; i < m_ob_count; i++)
    {
        if(m_order_blocks[i].state != OB_STATE_MITIGATED && m_order_blocks[i].state != OB_STATE_DISABLED)
        {
            if(valid_count != i) m_order_blocks[valid_count] = m_order_blocks[i];
            valid_count++;
        }
    }
    m_ob_count = valid_count;
}

int CEliteOrderBlockDetector::GetActiveOrderBlockCount()
{
    int count = 0;
    for(int i = 0; i < m_ob_count; i++)
    {
        if(m_order_blocks[i].state == OB_STATE_ACTIVE) count++;
    }
    return count;
}

void CEliteOrderBlockDetector::SortOrderBlocksByQuality()
{
    for(int i = 0; i < m_ob_count - 1; i++)
    {
        for(int j = 0; j < m_ob_count - i - 1; j++)
        {
            if(m_order_blocks[j].probability_score < m_order_blocks[j + 1].probability_score)
            {
                SAdvancedOrderBlock temp = m_order_blocks[j];
                m_order_blocks[j] = m_order_blocks[j + 1];
                m_order_blocks[j + 1] = temp;
            }
        }
    }
}

// Placeholder methods
bool CEliteOrderBlockDetector::DetectPremiumOrderBlocks() { return false; }
bool CEliteOrderBlockDetector::DetectDiscountOrderBlocks() { return false; }
bool CEliteOrderBlockDetector::ValidateWithLiquidity(SAdvancedOrderBlock& ob) { return true; }
bool CEliteOrderBlockDetector::ValidateWithVolume(SAdvancedOrderBlock& ob) { return true; }
bool CEliteOrderBlockDetector::ValidateWithStructure(SAdvancedOrderBlock& ob) { return true; }
double CEliteOrderBlockDetector::CalculateOptimalEntry(const SAdvancedOrderBlock& ob) { return ob.refined_entry; }

// === PROXIMITY METHODS FOR CONFLUENCE SCORING ===

// Check if there's an active OB in specified direction
bool CEliteOrderBlockDetector::HasActiveOB(ENUM_ORDER_BLOCK_TYPE type)
{
   for(int i = 0; i < m_ob_count; i++)
   {
      if(m_order_blocks[i].type == type && 
         m_order_blocks[i].state == OB_STATE_ACTIVE)
         return true;
   }
   return false;
}

// Get the nearest active OB to current price
bool CEliteOrderBlockDetector::GetNearestOB(ENUM_ORDER_BLOCK_TYPE type, SAdvancedOrderBlock &ob)
{
   double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double min_distance = DBL_MAX;
   int best_index = -1;
   
   for(int i = 0; i < m_ob_count; i++)
   {
      if(m_order_blocks[i].type != type) continue;
      if(m_order_blocks[i].state != OB_STATE_ACTIVE && 
         m_order_blocks[i].state != OB_STATE_TESTED) continue;
      
      // Calculate distance to OB zone
      double distance = 0;
      if(type == OB_BULLISH)
      {
         // For bullish OB, we want price above the OB zone
         distance = current_price - m_order_blocks[i].high_price;
         if(distance < 0) distance = MathAbs(current_price - m_order_blocks[i].low_price);
      }
      else
      {
         // For bearish OB, we want price below the OB zone
         distance = m_order_blocks[i].low_price - current_price;
         if(distance < 0) distance = MathAbs(current_price - m_order_blocks[i].high_price);
      }
      
      if(distance < min_distance)
      {
         min_distance = distance;
         best_index = i;
      }
   }
   
   if(best_index >= 0)
   {
      ob = m_order_blocks[best_index];
      return true;
   }
   return false;
}

// Calculate proximity score (0-100) based on distance to nearest OB
double CEliteOrderBlockDetector::GetProximityScore(ENUM_ORDER_BLOCK_TYPE type)
{
   SAdvancedOrderBlock ob;
   if(!GetNearestOB(type, ob)) return 0;

   double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double atr[];
   ArrayResize(atr, 1);

   // Use cached ATR handle instead of creating new one each call
   if(m_atr_handle_h1 == INVALID_HANDLE) return 0;
   if(CopyBuffer(m_atr_handle_h1, 0, 0, 1, atr) <= 0)
      return 0;
   
   // Calculate how close price is to OB zone
   double ob_mid = (ob.high_price + ob.low_price) / 2.0;
   double distance = MathAbs(current_price - ob_mid);
   double distance_atr = distance / atr[0];
   
   // Score based on distance (closer = higher score)
   // Within 0.5 ATR = 100, within 1 ATR = 80, within 2 ATR = 50, beyond 3 ATR = 0
   double score = 0;
   if(distance_atr <= 0.5) score = 100;
   else if(distance_atr <= 1.0) score = 80 + (1.0 - distance_atr) * 40;
   else if(distance_atr <= 2.0) score = 50 + (2.0 - distance_atr) * 30;
   else if(distance_atr <= 3.0) score = (3.0 - distance_atr) * 50;
   else score = 0;
   
   // Bonus for OB quality
   score *= (ob.probability_score / 100.0);
   
   // Bonus if price is approaching OB (not already past it)
   bool approaching = false;
   if(type == OB_BULLISH && current_price > ob.high_price) approaching = true;
   if(type == OB_BEARISH && current_price < ob.low_price) approaching = true;
   if(approaching) score *= 1.2;
   
   return MathMin(100, score);
}

// Check if price is currently inside an OB zone
bool CEliteOrderBlockDetector::IsPriceInOBZone(ENUM_ORDER_BLOCK_TYPE type)
{
   double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   for(int i = 0; i < m_ob_count; i++)
   {
      if(m_order_blocks[i].type != type) continue;
      if(m_order_blocks[i].state == OB_STATE_MITIGATED || 
         m_order_blocks[i].state == OB_STATE_DISABLED) continue;
      
      if(current_price >= m_order_blocks[i].low_price && 
         current_price <= m_order_blocks[i].high_price)
         return true;
   }
   return false;
}
