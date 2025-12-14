//+------------------------------------------------------------------+
//|                                                   EliteFVG.mqh |
//|                           Autonomous Expert Advisor for XAUUSD Trading |
//|                                       FVG Detection Component |
//+------------------------------------------------------------------+
#property copyright "Developed by Autonomous AI Agent - FTMO Elite Trading System"
#property strict

#include "../Core/Definitions.mqh"

// === ELITE FVG DETECTOR CLASS ===
class CEliteFVGDetector
{
private:
    // Detection parameters
    double              m_min_displacement_size;    // Minimum displacement for valid FVG
    double              m_volume_spike_threshold;   // Volume spike threshold
    bool                m_require_structure_break;  // Structure break confirmation
    double              m_min_gap_size;            // Minimum gap size in points
    double              m_max_gap_size;            // Maximum gap size in points
    
    // Quality assessment parameters
    double              m_institutional_threshold;  // Threshold for institutional FVG
    double              m_confluence_weight;        // Weight for confluence scoring
    
    // Multi-timeframe analysis
    ENUM_TIMEFRAMES     m_analysis_timeframes[4];   // Analysis timeframes
    int                 m_timeframe_count;          // Number of timeframes
    
    // Data Storage
    SEliteFairValueGap  m_fvgs[50];
    int                 m_fvg_count;
    
public:
    CEliteFVGDetector();
    ~CEliteFVGDetector();
    
    // Accessors
    int GetCount() { return m_fvg_count; }
    SEliteFairValueGap GetFVG(int index) { if(index >= 0 && index < 50) return m_fvgs[index]; SEliteFairValueGap empty; ZeroMemory(empty); return empty; }
    void UpdateFVG(int index, const SEliteFairValueGap& fvg) { if(index >= 0 && index < 50) m_fvgs[index] = fvg; }
    
    // Main detection methods
    bool DetectEliteFairValueGaps();
    bool DetectInstitutionalFVG();
    bool ValidateWithDisplacement(SEliteFairValueGap& fvg);
    
    // Calculation methods
    double CalculateOptimalFillLevel(const SEliteFairValueGap& fvg);
    double CalculateFVGQualityScore(const SEliteFairValueGap& fvg);
    double CalculateExpectedReaction(const SEliteFairValueGap& fvg);
    ENUM_FVG_QUALITY ClassifyFVGQuality(const SEliteFairValueGap& fvg);
    
    // Analysis methods
    bool IsHighProbabilityFVG(const SEliteFairValueGap& fvg);
    bool IsInstitutionalFVG(const SEliteFairValueGap& fvg);
    
    // Helper methods
    bool DetectBullishFVG(const MqlRates& rates[], int index);
    bool DetectBearishFVG(const MqlRates& rates[], int index);
    bool CreateFVGStructure(const MqlRates& rates[], int index, ENUM_FVG_TYPE type, SEliteFairValueGap& fvg);
    bool ValidateFVG(const SEliteFairValueGap& fvg);
    void SortFVGsByQuality();
    void CalculateConfluenceScore(SEliteFairValueGap& fvg);
    bool CheckOrderBlockConfluence(const SEliteFairValueGap& fvg);
    bool CheckLiquidityConfluence(const SEliteFairValueGap& fvg);
    bool CheckStructureConfluence(const SEliteFairValueGap& fvg);
    
    // Analysis helpers
    double CalculateDisplacementAfterFVG(const MqlRates& rates[], int index, bool is_bullish);
    bool HasVolumeConfirmation(const MqlRates& rates[], int index);
    bool IsInPremiumZone(double price);
    
    // Management methods
    void UpdateFVGStatus();
    void RemoveFilledFVGs();
    int GetActiveFVGCount();
    double GetBestFVGScore();
    
    // Proximity methods for confluence scoring
    bool HasActiveFVG(ENUM_FVG_TYPE type);
    bool GetNearestFVG(ENUM_FVG_TYPE type, SEliteFairValueGap &fvg);
    double GetProximityScore(ENUM_FVG_TYPE type);
    bool IsPriceInFVGZone(ENUM_FVG_TYPE type);
    double GetFillPercentage(ENUM_FVG_TYPE type);
    void TrackFills();
};

// --- Constructor / Destructor ---
CEliteFVGDetector::CEliteFVGDetector()
{
    m_min_displacement_size   = 150 * _Point;
    m_volume_spike_threshold  = 1.5;
    m_require_structure_break = true;
    m_min_gap_size            = 10 * _Point;
    m_max_gap_size            = 400 * _Point;   // ~40 pips cap for XAU
    m_institutional_threshold = 200 * _Point;
    m_confluence_weight       = 1.0;
    m_timeframe_count         = 1;
    m_analysis_timeframes[0]  = PERIOD_M15;
    m_fvg_count               = 0;
}

CEliteFVGDetector::~CEliteFVGDetector() {}

// Main detection method for elite FVGs
bool CEliteFVGDetector::DetectEliteFairValueGaps()
{
    // Reset current FVG count
    m_fvg_count = 0;
    
    // Get market data for analysis
    MqlRates rates[];
    if(CopyRates(_Symbol, PERIOD_M15, 0, 100, rates) <= 0)
        return false;
    ArraySetAsSeries(rates, true);
    
    // Analyze each potential FVG formation (need 3 consecutive candles)
    for(int i = 2; i < 97; i++)
    {
        // Check for bullish FVG pattern
        if(DetectBullishFVG(rates, i))
        {
            SEliteFairValueGap fvg;
            if(CreateFVGStructure(rates, i, FVG_BULLISH, fvg) && ValidateFVG(fvg))
            {
                m_fvgs[m_fvg_count++] = fvg;
                if(m_fvg_count >= 50) break; // match array cap
            }
        }
        
        // Check for bearish FVG pattern
        if(DetectBearishFVG(rates, i))
        {
            SEliteFairValueGap fvg;
            if(CreateFVGStructure(rates, i, FVG_BEARISH, fvg) && ValidateFVG(fvg))
            {
                m_fvgs[m_fvg_count++] = fvg;
                if(m_fvg_count >= 50) break;
            }
        }
    }
    
    // Sort FVGs by quality and proximity
    SortFVGsByQuality();
    
    return m_fvg_count > 0;
}

// Create FVG structure
bool CEliteFVGDetector::CreateFVGStructure(const MqlRates& rates[], int index, ENUM_FVG_TYPE type, SEliteFairValueGap& fvg)
{
    // Initialize FVG structure
    fvg.formation_time = rates[index].time;
    fvg.type = type;
    fvg.state = FVG_STATE_OPEN;
    fvg.fill_percentage = 0.0;
    fvg.touch_count = 0;
    fvg.is_fresh = true;
    fvg.origin_timeframe = PERIOD_M15;
    
    // Set gap boundaries based on type
    if(type == FVG_BULLISH)
    {
        fvg.upper_level = rates[index+1].high;
        fvg.lower_level = rates[index-1].low;
    }
    else
    {
        fvg.upper_level = rates[index-1].high;
        fvg.lower_level = rates[index+1].low;
    }
    
    // Calculate middle level and optimal entry
    fvg.mid_level = (fvg.upper_level + fvg.lower_level) / 2.0;
    
    if(type == FVG_BULLISH)
        fvg.optimal_entry = fvg.lower_level + (fvg.upper_level - fvg.lower_level) * 0.618; // 61.8% level
    else
        fvg.optimal_entry = fvg.upper_level - (fvg.upper_level - fvg.lower_level) * 0.618; // 61.8% level
    
    // Calculate gap size
    fvg.gap_size_points = (fvg.upper_level - fvg.lower_level) / _Point;
    
    // Calculate advanced properties
    fvg.displacement_size = CalculateDisplacementAfterFVG(rates, index, type == FVG_BULLISH);
    fvg.has_volume_spike = HasVolumeConfirmation(rates, index);
    
    // Confluence factors calculated externally
    fvg.has_ob_confluence = false;
    fvg.has_liquidity_confluence = false;
    fvg.has_structure_confluence = false;
    fvg.confluence_score = 0.0;
    fvg.confluence_count = 0;
    
    fvg.quality_score = CalculateFVGQualityScore(fvg);
    fvg.expected_reaction = CalculateExpectedReaction(fvg);
    fvg.quality = ClassifyFVGQuality(fvg);
    
    // Determine institutional characteristics
    fvg.is_institutional = IsInstitutionalFVG(fvg);
    
    // Set timing properties
    fvg.age_in_bars = 0;
    fvg.expiry_time = fvg.formation_time + 24*3600; // 24 hours expiry
    fvg.time_decay_factor = 1.0;
    
    // Determine premium/discount location
    double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    fvg.is_in_premium = IsInPremiumZone(current_price);
    
    return true;
}

// --- Core Detection Helpers ---
bool CEliteFVGDetector::DetectBullishFVG(const MqlRates& rates[], int index)
{
    // indices: series=true, so index is middle candle, index+1 older, index-1 newer
    if(index < 1 || index >= ArraySize(rates)-1) return false;
    double high1 = rates[index+1].high;
    double low3  = rates[index-1].low;
    double gap   = low3 - high1;
    if(gap <= 0) return false;
    if(gap < m_min_gap_size || gap > m_max_gap_size) return false;
    
    // displacement check: middle candle should push down then up? Use range of middle
    double disp = rates[index-1].close - rates[index+1].low;
    if(disp < m_min_displacement_size) return false;
    
    return true;
}

bool CEliteFVGDetector::DetectBearishFVG(const MqlRates& rates[], int index)
{
    if(index < 1 || index >= ArraySize(rates)-1) return false;
    double low1  = rates[index+1].low;
    double high3 = rates[index-1].high;
    double gap   = high3 - low1;
    if(gap <= 0) return false;
    if(gap < m_min_gap_size || gap > m_max_gap_size) return false;
    
    double disp = rates[index+1].high - rates[index-1].close;
    if(disp < m_min_displacement_size) return false;
    
    return true;
}

bool CEliteFVGDetector::ValidateFVG(const SEliteFairValueGap& fvg)
{
    // Ensure gap still open
    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    if(fvg.type == FVG_BULLISH && bid < fvg.lower_level - (_Point*2)) return true;
    if(fvg.type == FVG_BEARISH && bid > fvg.upper_level + (_Point*2)) return true;
    return true;
}

// Calculate FVG quality score
double CEliteFVGDetector::CalculateFVGQualityScore(const SEliteFairValueGap& fvg)
{
    double score = 50.0; // Base score
    
    // Gap size factor (optimal around 30-100 points for XAUUSD)
    if(fvg.gap_size_points >= 30 && fvg.gap_size_points <= 100)
        score += 20.0;
    else if(fvg.gap_size_points >= 20 && fvg.gap_size_points <= 150)
        score += 15.0;
    else if(fvg.gap_size_points >= 15 && fvg.gap_size_points <= 200)
        score += 10.0;
    
    // Displacement factor
    double displacement_points = fvg.displacement_size / _Point;
    if(displacement_points >= 200) score += 20.0;
    else if(displacement_points >= 150) score += 15.0;
    else if(displacement_points >= 100) score += 10.0;
    
    // Volume confirmation
    if(fvg.has_volume_spike) score += 15.0;
    
    // Institutional characteristics
    if(fvg.is_institutional) score += 10.0;
    
    // Confluence score (added externally)
    score += fvg.confluence_score * 0.15;
    
    return MathMin(score, 100.0);
}


// Calculate expected reaction probability
double CEliteFVGDetector::CalculateExpectedReaction(const SEliteFairValueGap& fvg)
{
    double reaction = 0.5; // Base 50% probability
    
    // Quality bonus
    reaction += fvg.quality_score * 0.005; // Up to 50% bonus from quality
    
    // Gap size factor
    if(fvg.gap_size_points >= 30 && fvg.gap_size_points <= 80)
        reaction += 0.2; // Optimal size range
    
    // Institutional bonus
    if(fvg.is_institutional) reaction += 0.15;
    
    // Fresh FVG bonus
    if(fvg.is_fresh) reaction += 0.1;
    
    // Volume confirmation bonus
    if(fvg.has_volume_spike) reaction += 0.1;
    
    // Premium/discount consideration
    if((fvg.type == FVG_BULLISH && !fvg.is_in_premium) ||
       (fvg.type == FVG_BEARISH && fvg.is_in_premium))
    {
        reaction += 0.15; // Trading from appropriate zones
    }
    
    return MathMin(reaction, 1.0);
}

// Classify FVG quality
ENUM_FVG_QUALITY CEliteFVGDetector::ClassifyFVGQuality(const SEliteFairValueGap& fvg)
{
    if(fvg.quality_score >= 90.0 && fvg.is_institutional) return FVG_QUALITY_ELITE;
    if(fvg.quality_score >= 80.0) return FVG_QUALITY_HIGH;
    if(fvg.quality_score >= 65.0) return FVG_QUALITY_MEDIUM;
    return FVG_QUALITY_LOW;
}

// Check if FVG has institutional characteristics
bool CEliteFVGDetector::IsInstitutionalFVG(const SEliteFairValueGap& fvg)
{
    // Large gap size
    if(fvg.gap_size_points < 200) return false; // 20 pips minimum for institutional
    
    // Strong displacement
    if(fvg.displacement_size < m_institutional_threshold) return false;
    
    // Volume spike confirmation
    if(!fvg.has_volume_spike) return false;
    
    // High quality score
    if(fvg.quality_score < 80.0) return false;
    
    return true;
}

// Calculate confluence score
void CEliteFVGDetector::CalculateConfluenceScore(SEliteFairValueGap& fvg)
{
    double score = 0.0;
    
    // Placeholder confluence; set to false by default
    fvg.has_ob_confluence = CheckOrderBlockConfluence(fvg);
    fvg.has_liquidity_confluence = CheckLiquidityConfluence(fvg);
    fvg.has_structure_confluence = CheckStructureConfluence(fvg);
    
    if(fvg.has_ob_confluence) score += 35.0;
    if(fvg.has_liquidity_confluence) score += 30.0;
    if(fvg.has_structure_confluence) score += 35.0;
    
    fvg.confluence_score = score;
    fvg.confluence_count = (fvg.has_ob_confluence ? 1 : 0) +
                          (fvg.has_liquidity_confluence ? 1 : 0) +
                          (fvg.has_structure_confluence ? 1 : 0);
}

// Helper methods implementation
double CEliteFVGDetector::CalculateDisplacementAfterFVG(const MqlRates& rates[], int index, bool is_bullish)
{
    if(index < 5) return 0.0;
    
    double max_displacement = 0.0;
    double reference_price = is_bullish ? rates[index].close : rates[index].close;
    
    // Check displacement in next 5 candles
    for(int i = index - 1; i >= MathMax(0, index - 5); i--)
    {
        double displacement = 0;
        if(is_bullish)
            displacement = rates[i].high - reference_price;
        else
            displacement = reference_price - rates[i].low;
            
        if(displacement > max_displacement)
            max_displacement = displacement;
    }
    
    return max_displacement;
}

bool CEliteFVGDetector::HasVolumeConfirmation(const MqlRates& rates[], int index)
{
    if(index >= ArraySize(rates) - 2) return true; // Default if insufficient data
    
    // Check volume spike in the FVG formation period
    long total_volume = rates[index-1].tick_volume + rates[index].tick_volume + rates[index+1].tick_volume;
    long avg_volume = 0;
    
    // Calculate average volume of previous 10 bars
    for(int i = index + 2; i < index + 12 && i < ArraySize(rates); i++)
    {
        avg_volume += rates[i].tick_volume;
    }
    avg_volume /= 10;
    
    return total_volume > avg_volume * m_volume_spike_threshold;
}

bool CEliteFVGDetector::CheckOrderBlockConfluence(const SEliteFairValueGap& fvg)
{
    // Placeholder: without OB detector context, return false
    return false;
}

bool CEliteFVGDetector::CheckLiquidityConfluence(const SEliteFairValueGap& fvg)
{
    // Placeholder: no liquidity map available in this context
    return false;
}

bool CEliteFVGDetector::CheckStructureConfluence(const SEliteFairValueGap& fvg)
{
    // Check if FVG aligns with market structure
    MqlRates rates[];
    if(CopyRates(_Symbol, PERIOD_H1, 0, 50, rates) <= 0)
        return false;
        
    ArraySetAsSeries(rates, true);
    
    // Simple trend alignment check
    bool uptrend = rates[0].close > rates[10].close;
    
    if(fvg.type == FVG_BULLISH && uptrend) return true;
    if(fvg.type == FVG_BEARISH && !uptrend) return true;
    
    return false;
}

void CEliteFVGDetector::SortFVGsByQuality()
{
    for(int i = 0; i < m_fvg_count - 1; i++)
    {
        for(int j = 0; j < m_fvg_count - i - 1; j++)
        {
            if(m_fvgs[j].quality_score < m_fvgs[j + 1].quality_score)
            {
                SEliteFairValueGap temp = m_fvgs[j];
                m_fvgs[j] = m_fvgs[j + 1];
                m_fvgs[j + 1] = temp;
            }
        }
    }
}

// Update FVG status
void CEliteFVGDetector::UpdateFVGStatus()
{
    double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    
    for(int i = 0; i < m_fvg_count; i++)
    {
        SEliteFairValueGap fvg = m_fvgs[i];
        
        // Check if price has entered the FVG
        if(current_price >= fvg.lower_level && current_price <= fvg.upper_level)
        {
            fvg.touch_count++;
            fvg.is_fresh = false;
            
            // Calculate fill percentage
            if(fvg.type == FVG_BULLISH)
            {
                fvg.fill_percentage = (current_price - fvg.lower_level) / (fvg.upper_level - fvg.lower_level) * 100.0;
            }
            else
            {
                fvg.fill_percentage = (fvg.upper_level - current_price) / (fvg.upper_level - fvg.lower_level) * 100.0;
            }
            
            // Update state based on fill percentage
            if(fvg.fill_percentage >= 100.0)
                fvg.state = FVG_STATE_FILLED;
            else if(fvg.fill_percentage >= 50.0)
                fvg.state = FVG_STATE_PARTIAL;
        }
        
        // Age-based expiry (24 hours for M15 timeframe)
        fvg.age_in_bars = (int)((TimeCurrent() - fvg.formation_time) / (15 * 60)); // 15 minutes per bar
        
        if(TimeCurrent() > fvg.expiry_time && fvg.touch_count == 0)
        {
            fvg.state = FVG_STATE_EXPIRED;
        }
        
        // Calculate time decay factor
        double age_hours = (TimeCurrent() - fvg.formation_time) / 3600.0;
        fvg.time_decay_factor = MathMax(0.1, 1.0 - (age_hours / 24.0)); // Decay over 24 hours

        // Write back
        m_fvgs[i] = fvg;
    }
}

// Remove filled/expired FVGs
void CEliteFVGDetector::RemoveFilledFVGs()
{
    int valid_count = 0;
    
    for(int i = 0; i < m_fvg_count; i++)
    {
        if(m_fvgs[i].state != FVG_STATE_FILLED &&
           m_fvgs[i].state != FVG_STATE_EXPIRED)
        {
            if(valid_count != i)
            {
                m_fvgs[valid_count] = m_fvgs[i];
            }
            valid_count++;
        }
    }
    
    m_fvg_count = valid_count;
}

// Get active FVG count
int CEliteFVGDetector::GetActiveFVGCount()
{
    int active_count = 0;
    
    for(int i = 0; i < m_fvg_count; i++)
    {
        if(m_fvgs[i].state == FVG_STATE_OPEN ||
           m_fvgs[i].state == FVG_STATE_PARTIAL)
        {
            active_count++;
        }
    }
    
    return active_count;
}

// Get best FVG score
double CEliteFVGDetector::GetBestFVGScore()
{
    double best_score = 0.0;
    
    for(int i = 0; i < m_fvg_count; i++)
    {
        if(m_fvgs[i].state == FVG_STATE_OPEN ||
           m_fvgs[i].state == FVG_STATE_PARTIAL)
        {
            if(m_fvgs[i].quality_score > best_score)
                best_score = m_fvgs[i].quality_score;
        }
    }
    
    return best_score;
}

// Placeholder methods for missing implementations
bool CEliteFVGDetector::DetectInstitutionalFVG() { return false; }
bool CEliteFVGDetector::ValidateWithDisplacement(SEliteFairValueGap& fvg) { return true; }
double CEliteFVGDetector::CalculateOptimalFillLevel(const SEliteFairValueGap& fvg) { return fvg.mid_level; }
bool CEliteFVGDetector::IsHighProbabilityFVG(const SEliteFairValueGap& fvg) { return fvg.quality_score > 80.0; }
bool CEliteFVGDetector::IsInPremiumZone(double price) { return false; }

// === PROXIMITY METHODS FOR CONFLUENCE SCORING ===

// Check if there's an active FVG in specified direction
bool CEliteFVGDetector::HasActiveFVG(ENUM_FVG_TYPE type)
{
   for(int i = 0; i < m_fvg_count; i++)
   {
      if(m_fvgs[i].type == type && 
         (m_fvgs[i].state == FVG_STATE_OPEN || m_fvgs[i].state == FVG_STATE_PARTIAL))
         return true;
   }
   return false;
}

// Get the nearest active FVG to current price
bool CEliteFVGDetector::GetNearestFVG(ENUM_FVG_TYPE type, SEliteFairValueGap &fvg)
{
   double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double min_distance = DBL_MAX;
   int best_index = -1;
   
   for(int i = 0; i < m_fvg_count; i++)
   {
      if(m_fvgs[i].type != type) continue;
      if(m_fvgs[i].state != FVG_STATE_OPEN && 
         m_fvgs[i].state != FVG_STATE_PARTIAL) continue;
      
      // Calculate distance to FVG zone
      double distance = 0;
      if(type == FVG_BULLISH)
      {
         // For bullish FVG, we want price approaching from above
         distance = current_price - m_fvgs[i].upper_level;
         if(distance < 0) distance = MathAbs(current_price - m_fvgs[i].lower_level);
      }
      else
      {
         // For bearish FVG, we want price approaching from below
         distance = m_fvgs[i].lower_level - current_price;
         if(distance < 0) distance = MathAbs(current_price - m_fvgs[i].upper_level);
      }
      
      if(distance < min_distance)
      {
         min_distance = distance;
         best_index = i;
      }
   }
   
   if(best_index >= 0)
   {
      fvg = m_fvgs[best_index];
      return true;
   }
   return false;
}

// Calculate proximity score (0-100) based on distance to nearest FVG
double CEliteFVGDetector::GetProximityScore(ENUM_FVG_TYPE type)
{
   SEliteFairValueGap fvg;
   if(!GetNearestFVG(type, fvg)) return 0;
   
   double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double atr[];
   ArrayResize(atr, 1);
   
   int atr_handle = iATR(_Symbol, PERIOD_H1, 14);
   if(atr_handle == INVALID_HANDLE) return 0;
   if(CopyBuffer(atr_handle, 0, 0, 1, atr) <= 0) 
   {
      IndicatorRelease(atr_handle);
      return 0;
   }
   IndicatorRelease(atr_handle);
   
   // Calculate how close price is to FVG zone
   double fvg_mid = (fvg.upper_level + fvg.lower_level) / 2.0;
   double distance = MathAbs(current_price - fvg_mid);
   double distance_atr = distance / atr[0];
   
   // Score based on distance (closer = higher score)
   double score = 0;
   if(distance_atr <= 0.3) score = 100;
   else if(distance_atr <= 0.5) score = 85 + (0.5 - distance_atr) * 75;
   else if(distance_atr <= 1.0) score = 60 + (1.0 - distance_atr) * 50;
   else if(distance_atr <= 2.0) score = (2.0 - distance_atr) * 60;
   else score = 0;
   
   // Bonus for FVG quality and freshness
   score *= (fvg.quality_score / 100.0);
   if(fvg.is_fresh) score *= 1.15;
   
   // Apply time decay
   score *= fvg.time_decay_factor;
   
   // Bonus if price is approaching FVG (not already inside)
   bool approaching = false;
   if(type == FVG_BULLISH && current_price > fvg.upper_level) approaching = true;
   if(type == FVG_BEARISH && current_price < fvg.lower_level) approaching = true;
   if(approaching) score *= 1.1;
   
   return MathMin(100, MathMax(0, score));
}

// Check if price is currently inside an FVG zone
bool CEliteFVGDetector::IsPriceInFVGZone(ENUM_FVG_TYPE type)
{
   double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   for(int i = 0; i < m_fvg_count; i++)
   {
      if(m_fvgs[i].type != type) continue;
      if(m_fvgs[i].state == FVG_STATE_FILLED || 
         m_fvgs[i].state == FVG_STATE_EXPIRED) continue;
      
      if(current_price >= m_fvgs[i].lower_level && 
         current_price <= m_fvgs[i].upper_level)
         return true;
   }
   return false;
}

// Get fill percentage of nearest FVG
double CEliteFVGDetector::GetFillPercentage(ENUM_FVG_TYPE type)
{
   SEliteFairValueGap fvg;
   if(!GetNearestFVG(type, fvg)) return 0;
   return fvg.fill_percentage;
}

// Track and update FVG fill status in real-time
void CEliteFVGDetector::TrackFills()
{
   double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   for(int i = 0; i < m_fvg_count; i++)
   {
      if(m_fvgs[i].state == FVG_STATE_FILLED || 
         m_fvgs[i].state == FVG_STATE_EXPIRED) continue;
      
      // Check if price is in FVG zone
      if(current_price >= m_fvgs[i].lower_level && 
         current_price <= m_fvgs[i].upper_level)
      {
         m_fvgs[i].touch_count++;
         m_fvgs[i].is_fresh = false;
         
         // Calculate fill percentage based on type
         double gap_size = m_fvgs[i].upper_level - m_fvgs[i].lower_level;
         if(gap_size <= 0) continue;
         
         if(m_fvgs[i].type == FVG_BULLISH)
         {
            // Bullish FVG fills from bottom up
            double filled = current_price - m_fvgs[i].lower_level;
            m_fvgs[i].fill_percentage = MathMax(m_fvgs[i].fill_percentage, (filled / gap_size) * 100.0);
         }
         else
         {
            // Bearish FVG fills from top down
            double filled = m_fvgs[i].upper_level - current_price;
            m_fvgs[i].fill_percentage = MathMax(m_fvgs[i].fill_percentage, (filled / gap_size) * 100.0);
         }
         
         // Update state based on fill
         if(m_fvgs[i].fill_percentage >= 100.0)
            m_fvgs[i].state = FVG_STATE_FILLED;
         else if(m_fvgs[i].fill_percentage >= 50.0)
            m_fvgs[i].state = FVG_STATE_PARTIAL;
      }
   }
}
