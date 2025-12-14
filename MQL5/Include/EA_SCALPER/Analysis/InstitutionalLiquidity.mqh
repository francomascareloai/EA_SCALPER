//+------------------------------------------------------------------+
//|                                      InstitutionalLiquidity.mqh |
//|                           Autonomous Expert Advisor for XAUUSD Trading |
//|                                   Liquidity Detection Component |
//+------------------------------------------------------------------+
#property copyright "Developed by Autonomous AI Agent - FTMO Elite Trading System"
#property strict

#include "../Core/Definitions.mqh"

// === INSTITUTIONAL LIQUIDITY DETECTOR CLASS ===
class CInstitutionalLiquidityDetector
{
private:
    // Detection parameters
    double              m_min_accumulation_size;    // Minimum accumulation size
    double              m_institutional_threshold;  // Institutional size threshold
    int                 m_min_touch_count;          // Minimum touches for significance
    double              m_sweep_validation_distance;// Distance to validate sweep
    
    // Counts for different timeframes
    int                 m_weekly_count;
    int                 m_daily_count;
    int                 m_session_count;
    
    // Multi-timeframe analysis
    ENUM_TIMEFRAME      m_analysis_timeframes[5];   // Analysis timeframes
    int                 m_timeframe_count;          // Number of timeframes
    
    // Data Storage
    SInstitutionalLiquidityPool m_liquidity[50];
    int                         m_liq_count;
    
public:
    CInstitutionalLiquidityDetector();
    ~CInstitutionalLiquidityDetector();
    
    // Accessors
    int GetCount() { return m_liq_count; }
    SInstitutionalLiquidityPool GetLiquidity(int index) { if(index >= 0 && index < 50) return m_liquidity[index]; SInstitutionalLiquidityPool empty; ZeroMemory(empty); return empty; }
    void UpdateLiquidity(int index, const SInstitutionalLiquidityPool& pool) { if(index >= 0 && index < 50) m_liquidity[index] = pool; }
    
    // Main detection methods
    bool DetectInstitutionalLiquidity();
    bool DetectWeeklyLiquidity();
    bool DetectDailyLiquidity();
    bool DetectSessionLiquidity();
    
    // Management methods
    void CreateSimpleLiquidityPool(double price_level, ENUM_LIQUIDITY_TYPE type);
    void UpdateLiquidityStatus();
    void RemoveSweptLiquidity();
    int GetActiveLiquidityCount();
    double GetBestLiquidityScore();
};

//+------------------------------------------------------------------+
//| Institutional Liquidity Detector Implementation                  |
//+------------------------------------------------------------------+

// Constructor
CInstitutionalLiquidityDetector::CInstitutionalLiquidityDetector()
{
    // Initialize detection parameters for XAUUSD
    m_min_accumulation_size = 500.0 * _Point;   // 50 pips minimum accumulation
    m_institutional_threshold = 1000.0 * _Point; // 100 pips for institutional
    m_min_touch_count = 2;                      // Minimum 2 touches for significance
    m_sweep_validation_distance = 20.0 * _Point; // 2 pips for valid sweep
    
    // Initialize counts
    m_weekly_count = 0;
    m_daily_count = 0;
    m_session_count = 0;
    
    m_liq_count = 0;
    
    // Set analysis timeframes
    m_analysis_timeframes[0] = PERIOD_W1;
    m_analysis_timeframes[1] = PERIOD_D1;
    m_analysis_timeframes[2] = PERIOD_H4;
    m_analysis_timeframes[3] = PERIOD_H1;
    m_analysis_timeframes[4] = PERIOD_M15;
    m_timeframe_count = 5;
}

// Destructor
CInstitutionalLiquidityDetector::~CInstitutionalLiquidityDetector()
{
    // Cleanup if needed
}

// Main detection method for institutional liquidity
bool CInstitutionalLiquidityDetector::DetectInstitutionalLiquidity()
{
    // Reset current liquidity count
    m_liq_count = 0;
    
    // Detect liquidity across different timeframes
    bool weekly_detected = DetectWeeklyLiquidity();
    bool daily_detected = DetectDailyLiquidity();
    bool session_detected = DetectSessionLiquidity();
    
    return m_liq_count > 0;
}

// Detect weekly liquidity levels
bool CInstitutionalLiquidityDetector::DetectWeeklyLiquidity()
{
    MqlRates weekly_rates[20];
    if(CopyRates(_Symbol, PERIOD_W1, 0, 20, weekly_rates) <= 0)
        return false;
        
    ArraySetAsSeries(weekly_rates, true);
    
    // Simple weekly high/low detection
    for(int i = 1; i < 15; i++)
    {
        if(weekly_rates[i].high > weekly_rates[i-1].high && weekly_rates[i].high > weekly_rates[i+1].high)
        {
            if(m_liq_count < 50)
            {
                CreateSimpleLiquidityPool(weekly_rates[i].high, LIQUIDITY_WEEKLY);
            }
        }
        if(weekly_rates[i].low < weekly_rates[i-1].low && weekly_rates[i].low < weekly_rates[i+1].low)
        {
            if(m_liq_count < 50)
            {
                CreateSimpleLiquidityPool(weekly_rates[i].low, LIQUIDITY_WEEKLY);
            }
        }
    }
    
    return true;
}

// Detect daily liquidity levels
bool CInstitutionalLiquidityDetector::DetectDailyLiquidity()
{
    MqlRates daily_rates[30];
    if(CopyRates(_Symbol, PERIOD_D1, 0, 30, daily_rates) <= 0)
        return false;
        
    ArraySetAsSeries(daily_rates, true);
    
    // Simple daily high/low detection
    for(int i = 1; i < 25; i++)
    {
        if(daily_rates[i].high > daily_rates[i-1].high && daily_rates[i].high > daily_rates[i+1].high)
        {
            if(m_liq_count < 50)
            {
                CreateSimpleLiquidityPool(daily_rates[i].high, LIQUIDITY_DAILY);
            }
        }
        if(daily_rates[i].low < daily_rates[i-1].low && daily_rates[i].low < daily_rates[i+1].low)
        {
            if(m_liq_count < 50)
            {
                CreateSimpleLiquidityPool(daily_rates[i].low, LIQUIDITY_DAILY);
            }
        }
    }
    
    return true;
}

// Detect session liquidity levels
bool CInstitutionalLiquidityDetector::DetectSessionLiquidity()
{
    MqlRates h1_rates[50];
    if(CopyRates(_Symbol, PERIOD_H1, 0, 50, h1_rates) <= 0)
        return false;
        
    ArraySetAsSeries(h1_rates, true);
    
    // Session high/low detection
    for(int i = 2; i < 45; i++)
    {
        if(h1_rates[i].high > h1_rates[i-1].high && h1_rates[i].high > h1_rates[i+1].high &&
           h1_rates[i].high > h1_rates[i-2].high && h1_rates[i].high > h1_rates[i+2].high)
        {
            if(m_liq_count < 50)
            {
                CreateSimpleLiquidityPool(h1_rates[i].high, LIQUIDITY_SESSION);
            }
        }
        if(h1_rates[i].low < h1_rates[i-1].low && h1_rates[i].low < h1_rates[i+1].low &&
           h1_rates[i].low < h1_rates[i-2].low && h1_rates[i].low < h1_rates[i+2].low)
        {
            if(m_liq_count < 50)
            {
                CreateSimpleLiquidityPool(h1_rates[i].low, LIQUIDITY_SESSION);
            }
        }
    }
    
    return true;
}

// Create simple liquidity pool
void CInstitutionalLiquidityDetector::CreateSimpleLiquidityPool(double price_level, ENUM_LIQUIDITY_TYPE type)
{
    SInstitutionalLiquidityPool pool;
    
    // Initialize basic properties
    pool.formation_time = TimeCurrent();
    pool.price_level = price_level;
    pool.type = type;
    pool.state = LIQUIDITY_UNTAPPED;
    pool.touch_count = 0;
    pool.is_fresh = true;
    
    // Set quality based on type
    switch(type)
    {
        case LIQUIDITY_WEEKLY: 
            pool.quality = LIQUIDITY_QUALITY_HIGH;
            pool.quality_score = 85.0;
            pool.is_institutional = true;
            break;
        case LIQUIDITY_DAILY:
            pool.quality = LIQUIDITY_QUALITY_MEDIUM;
            pool.quality_score = 70.0;
            pool.is_institutional = true;
            break;
        default:
            pool.quality = LIQUIDITY_QUALITY_MEDIUM;
            pool.quality_score = 60.0;
            pool.is_institutional = false;
            break;
    }
    
    // Set other properties
    pool.sweep_probability = 0.7;
    pool.confluence_score = 0.0;
    pool.time_decay_factor = 1.0;
    
    // Add to array
    m_liquidity[m_liq_count] = pool;
    m_liq_count++;
}

// Update liquidity status
void CInstitutionalLiquidityDetector::UpdateLiquidityStatus()
{
    double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    
    for(int i = 0; i < m_liq_count; i++)
    {
        SInstitutionalLiquidityPool& pool = m_liquidity[i];
        
        // Check if price has approached the liquidity level
        double distance = MathAbs(current_price - pool.price_level);
        
        if(distance <= 30 * _Point) // Within 3 pips
        {
            pool.touch_count++;
            
            // Check if swept
            if(distance <= 10 * _Point) // Within 1 pip
            {
                pool.state = LIQUIDITY_SWEPT;
                pool.is_fresh = false;
            }
        }
        
        // Age-based expiry
        if(TimeCurrent() - pool.formation_time > 7 * 24 * 3600) // 7 days
        {
            if(pool.state == LIQUIDITY_UNTAPPED)
                pool.state = LIQUIDITY_EXPIRED;
        }
    }
}

// Remove swept liquidity
void CInstitutionalLiquidityDetector::RemoveSweptLiquidity()
{
    int valid_count = 0;
    
    for(int i = 0; i < m_liq_count; i++)
    {
        if(m_liquidity[i].state != LIQUIDITY_SWEPT &&
           m_liquidity[i].state != LIQUIDITY_EXPIRED)
        {
            if(valid_count != i)
            {
                m_liquidity[valid_count] = m_liquidity[i];
            }
            valid_count++;
        }
    }
    
    m_liq_count = valid_count;
}

// Get active liquidity count
int CInstitutionalLiquidityDetector::GetActiveLiquidityCount()
{
    int active_count = 0;
    
    for(int i = 0; i < m_liq_count; i++)
    {
        if(m_liquidity[i].state == LIQUIDITY_UNTAPPED)
        {
            active_count++;
        }
    }
    
    return active_count;
}

// Get best liquidity score
double CInstitutionalLiquidityDetector::GetBestLiquidityScore()
{
    double best_score = 0.0;
    
    for(int i = 0; i < m_liq_count; i++)
    {
        if(m_liquidity[i].state == LIQUIDITY_UNTAPPED)
        {
            if(m_liquidity[i].quality_score > best_score)
                best_score = m_liquidity[i].quality_score;
        }
    }
    
    return best_score;
}

