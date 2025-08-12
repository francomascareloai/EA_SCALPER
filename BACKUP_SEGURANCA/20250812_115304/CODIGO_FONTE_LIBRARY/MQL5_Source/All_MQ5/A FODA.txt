//+------------------------------------------------------------------+
//|                                                     XAUUSD_Scalper_OB_v1.4.mq5 |
//|                                    Scalper baseado em Order Blocks e Volume Flow |
//|                                                                  Baseado em FTMO_Elite_v1.2 |
//|                                                       Versão com Filtros Avançados de Sessão (ICT Killzones) |
//+------------------------------------------------------------------+
#property copyright "Desenvolvido com base em FTMO_Elite_v1.2 e conceitos de Price Action"
#property link      "https://www.mql5.com"
#property version   "1.4" // Versão incrementada
#property strict

#include <Trade\Trade.mqh>
CTrade trade;

//--- Enums para clareza nos inputs ---
enum ENUM_TIMEFRAMES_INPUT { TF_M1=1, TF_M2=2, TF_M3=3, TF_M4=4, TF_M5=5, TF_M6=6, TF_M10=10, TF_M12=12, TF_M15=15, TF_M20=20, TF_M30=30, TF_H1=60, TF_H2=120, TF_H3=180, TF_H4=240, TF_H6=360, TF_H8=480, TF_H12=720, TF_D1=1440, TF_W1=10080, TF_MN=43200 };
enum ENUM_LOT_SIZING { LOT_FIXO, RISCO_PERCENTUAL };
enum ENUM_SESSION { SESSION_ALL, SESSION_ASIAN, SESSION_LONDON, SESSION_NY, SESSION_LONDON_NY, SESSION_CUSTOM, SESSION_ICT_KILLZONES }; // Adicionado Killzones
enum ENUM_PROFIT_PROTECTION { PP_NONE, PP_BREAKEVEN, PP_TRAILING_STOP, PP_BREAKEVEN_THEN_TRAILING };
enum ENUM_OB_STATE { OB_STATE_ACTIVE, OB_STATE_MITIGATED, OB_STATE_TAKEN, OB_STATE_EXPIRED, OB_STATE_DISABLED };
enum ENUM_TREND_FILTER_TYPE { TREND_FILTER_MA, TREND_FILTER_ADX };
enum ENUM_TP_TYPE { TP_FIXED_POINTS, TP_ATR_DYNAMIC, TP_FIBO_DYNAMIC };
enum ENUM_SL_TYPE { SL_FIXED_POINTS, SL_ATR_DYNAMIC };
enum ENUM_TRAILING_METHOD { TRAIL_POINTS, TRAIL_ATR, TRAIL_PSAR, TRAIL_FRACTAL };

//--- Input Parameters ---
input group "=== CONFIGURAÇÕES GERAIS ==="
input int InpMagicNumber = 789012;
input string InpComment = "XAUUSD_Scalper_OB_v1.4";
input ENUM_TIMEFRAMES_INPUT InpTimeframe = TF_M1;

input group "=== ORDER BLOCK SETTINGS ==="
input int InpOB_Lookback = 50;
input double InpOB_MinDisplacementPoints = 150;
input double InpOB_MitigationLevel = 0.7;
input int InpOB_MaxAgeBars = 10;
input bool InpOB_UseBreaker = true;
input double InpOB_MinAreaPoints = 10000;
input double InpOB_MaxOverlapPercent = 50.0;

input group "=== VOLUME FLOW SETTINGS ==="
input int InpVolumeMALength = 14;
input double InpVolumeSpikeMultiplier = 1.5;

input group "=== GERENCIAMENTO DE RISCO E POSIÇÃO ==="
input ENUM_LOT_SIZING InpMoney_LotSizingMethod = RISCO_PERCENTUAL;
input double InpMoney_RiskPercent = 0.4;
input double InpMoney_FixedLot = 0.01;
input double InpMoney_MaxRiskPerTrade = 0.75;

input group "=== STOP LOSS & TAKE PROFIT ==="
input ENUM_SL_TYPE InpSL_Type = SL_ATR_DYNAMIC;
input int InpSL_FixedPoints = 150;
input int InpSL_ATR_Period = 14;
input double InpSL_ATR_Multiplier = 1.4;

input ENUM_TP_TYPE InpTP_Type = TP_FIBO_DYNAMIC;
input int InpTP_FixedPoints = 300;
input int InpTP_ATR_Period = 14;
input double InpTP_ATR_Multiplier = 3.0;
input double InpTP_Fibo_Extension = 2.2;

input double InpRR_Min = 1.9;

//--- Proteção de Lucro ---
input group "=== PROTEÇÃO DE LUCRO ==="
input ENUM_PROFIT_PROTECTION InpProfitProtection_Type = PP_BREAKEVEN_THEN_TRAILING;
input double InpProfitProtection_MultSL = 2.0;
input int InpProfitProtection_TrailingPoints = 50;
input bool InpProfitProtection_UseDynamicBE = true;
input double InpProfitProtection_BE_MultSL = 1.0;
input ENUM_TRAILING_METHOD InpTrailing_Method = TRAIL_POINTS;
input int InpTrailing_ATR_Period = 14;
input double InpTrailing_ATR_Multiplier = 1.2;
input double InpTrailing_PSAR_Step = 0.02;
input double InpTrailing_PSAR_Max = 0.2;

//--- FILTROS DE MERCADO ---
input group "=== FILTROS DE MERCADO ==="
input double InpFilter_MaxSpread = 5.0;
input int InpBrokerGMTOffsetHours = 0; // offset do broker em relação ao GMT

//--- Filtro de Sessão (Aprimorado com ICT Killzones) ---
input ENUM_SESSION InpFilter_Session = SESSION_ICT_KILLZONES; // Default para Killzones
input int InpFilter_CustomStart_Hour = 0;
input int InpFilter_CustomStart_Min = 0;
input int InpFilter_CustomEnd_Hour = 23;
input int InpFilter_CustomEnd_Min = 59;

//--- Novo: Inputs para ICT Killzones ---
input string InpFilter_Killzone_AsiaBegin = "22:00"; // GMT
input string InpFilter_Killzone_AsiaEnd = "01:00";   // GMT
input string InpFilter_Killzone_LondonBegin = "07:00"; // GMT
input string InpFilter_Killzone_LondonEnd = "10:00";   // GMT
input string InpFilter_Killzone_NYAMBegin = "12:00"; // GMT
input string InpFilter_Killzone_NYAMEnd = "15:00";   // GMT
input string InpFilter_Killzone_NYLunchBegin = "15:00"; // GMT
input string InpFilter_Killzone_NYLunchEnd = "16:00";   // GMT
input string InpFilter_Killzone_NYPMBegin = "19:00"; // GMT
input string InpFilter_Killzone_NYPMEnd = "22:00";   // GMT

input bool InpFilter_Killzone_AllowAsia = true;
input bool InpFilter_Killzone_AllowLondon = true;
input bool InpFilter_Killzone_AllowNYAM = true;
input bool InpFilter_Killzone_AllowNYLunch = true;
input bool InpFilter_Killzone_AllowNYPm = true;

//--- Filtros Avançados (Volatilidade, Tendência, RSI, Tempo de Vela) ---
input bool InpFilter_UseATR = true;
input int InpFilter_ATR_Period = 14;
input double InpFilter_ATR_Min = 5.0;
input double InpFilter_ATR_Max = 500.0;

input bool InpFilter_UseTrend = true;
input ENUM_TIMEFRAMES_INPUT InpFilter_Trend_TF = TF_M5;
input ENUM_TREND_FILTER_TYPE InpFilter_Trend_Type = TREND_FILTER_MA;
input int InpFilter_Trend_MA_Period = 50;
input int InpFilter_Trend_ADX_Period = 14;
input int InpFilter_Trend_MinStrength = 20;
input bool InpFilter_UseEMAStack = true;
input int InpEMA1_Period = 8;
input int InpEMA2_Period = 13;
input int InpEMA3_Period = 21;

input bool InpFilter_UseRSI = true;
input int InpFilter_RSI_Period = 14;
input int InpFilter_RSI_Overbought = 65;
input int InpFilter_RSI_Oversold = 35;
input bool InpFilter_UseBBWidth = true;
input int InpFilter_BB_Period = 20;
input double InpFilter_BB_StdDev = 2.0;
input double InpFilter_BBWidth_MinPoints = 120.0;
input double InpFilter_BBWidth_MaxPoints = 4000.0;

input bool InpFilter_UseCandleTime = true;
input int InpFilter_CandleTime_MinSecondsLeft = 10;

//--- Parciais e limites de risco ---
input group "=== PARCIAIS E LIMITES ==="
input bool InpUsePartials = true;
input double InpPartial1_R = 1.0;
input double InpPartial1_Percent = 0.4; // 40%
input double InpPartial2_R = 2.0;
input double InpPartial2_Percent = 0.4; // 40%
input double InpPartial_BE_BufferPoints = 5.0;
input int InpMaxTradesPerDay = 5;
input int InpCooldownMinutesAfterLoss = 20;
input int InpMaxConsecutiveLosses = 2;
input double InpDailyLossLimitPercent = 2.0;
input bool InpStopTradingAfterDailyLoss = true;

//--- Saídas e News ---
input group "=== SAÍDAS AVANÇADAS & NEWS ==="
input int InpExit_TimeStop_Bars = 30;
input double InpExit_Compress_BBWidth_Points = 80.0;
input double InpExit_Compress_MinRToHold = 1.0;
input bool InpNewsFilter_Enable = false;
input string InpNews_Currencies = "USD;XAU;GLD";
input int InpNews_MinImportance = 2; // 0 low,1 medium,2 high
input int InpNews_BlockMinutes_Before = 10;
input int InpNews_BlockMinutes_After = 10;
input bool InpNews_UseCSV_Fallback = false;
input string InpNews_CSV_FileName = "news.csv"; // colocar em MQL5/Files

//--- London Breakout (opcional)
input group "=== LONDON BREAKOUT (opcional) ==="
input bool InpUseLondonBreakout = false;
input string InpAsiaRangeBegin = "00:00"; // faixa para range da Ásia (ex.: 00:00-06:00)
input string InpAsiaRangeEnd = "06:00";

//--- Handles de Indicadores ---
// Em MQL5, volume é obtido via CopyRates (tick_volume). Manter variáveis para compatibilidade, porém não usadas como handles
int ExtVolume_Handle = INVALID_HANDLE;
int ExtVolume_MA_Handle = INVALID_HANDLE;
int ExtATR_Handle = INVALID_HANDLE;
int ExtTrend_MA_Handle = INVALID_HANDLE;
int ExtTrend_ADX_Handle = INVALID_HANDLE; // Buffer 0: ADX, 1: +DI, 2: -DI
int ExtTrend_DIPlus_Handle = INVALID_HANDLE;  // Não utilizado em MQL5; manter para compatibilidade
int ExtTrend_DIMinus_Handle = INVALID_HANDLE; // Não utilizado em MQL5; manter para compatibilidade
int ExtRSI_Handle = INVALID_HANDLE;
int ExtEMA1_Handle = INVALID_HANDLE;
int ExtEMA2_Handle = INVALID_HANDLE;
int ExtEMA3_Handle = INVALID_HANDLE;
int ExtBB_Upper_Handle = INVALID_HANDLE;
int ExtBB_Lower_Handle = INVALID_HANDLE;
int ExtPSAR_Handle = INVALID_HANDLE;
int ExtFractals_Handle = INVALID_HANDLE;

//--- Variáveis Globais ---
datetime G_LastTradeTime = 0;
double G_PointValue = 0.0;
double G_Spread = 0.0;
double G_LastTrailingSL = 0.0;
double G_SymbolTickValue = 0.0;
bool G_Partial1_Done = false;
bool G_Partial2_Done = false;
datetime G_LastLossTime = 0;
int G_ConsecutiveLosses = 0;
int G_TradesToday = 0;
datetime G_TodayDate = 0;

//--- Estrutura para Order Blocks Aprimorada ---
struct OrderBlock {
    datetime time;
    double high;
    double low;
    double open;
    double close;
    double formation_volume;
    double formation_volume_ma;
    bool is_bullish;
    ENUM_OB_STATE state;
    bool is_breaker;
    int age_bars;
    datetime break_time;
    double score;
    double area;
};

//--- Arrays para armazenar Order Blocks ---
OrderBlock G_OrderBlocks[50];
int G_OB_Count = 0;

//+------------------------------------------------------------------+
//| Custom init function                                             |
//+------------------------------------------------------------------+
int OnInit()
{
    trade.SetExpertMagicNumber(InpMagicNumber);
    trade.SetDeviationInPoints(5);
    
    G_PointValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    if(G_PointValue <= 0) G_PointValue = 0.01;
    G_SymbolTickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    if(G_SymbolTickValue <= 0) G_SymbolTickValue = 1.0;

    // Volume e sua média serão obtidos de CopyRates (tick_volume) e SMA calculada em tempo real
    ExtVolume_Handle = INVALID_HANDLE;
    ExtVolume_MA_Handle = INVALID_HANDLE;
    
    ExtATR_Handle = iATR(_Symbol, (ENUM_TIMEFRAMES)InpTimeframe, InpFilter_ATR_Period);
    
    if(InpFilter_UseTrend)
    {
        if(InpFilter_Trend_Type == TREND_FILTER_MA)
            ExtTrend_MA_Handle = iMA(_Symbol, (ENUM_TIMEFRAMES)InpFilter_Trend_TF, InpFilter_Trend_MA_Period, 0, MODE_EMA, PRICE_CLOSE);
        else if(InpFilter_Trend_Type == TREND_FILTER_ADX)
        {
            // Em MQL5, iADX retorna um único handle; buffers: 0=ADX, 1=+DI, 2=-DI
            ExtTrend_ADX_Handle = iADX(_Symbol, (ENUM_TIMEFRAMES)InpFilter_Trend_TF, InpFilter_Trend_ADX_Period);
            ExtTrend_DIPlus_Handle = INVALID_HANDLE;
            ExtTrend_DIMinus_Handle = INVALID_HANDLE;
        }
    }
    if(InpFilter_UseEMAStack)
    {
        ExtEMA1_Handle = iMA(_Symbol, (ENUM_TIMEFRAMES)InpFilter_Trend_TF, InpEMA1_Period, 0, MODE_EMA, PRICE_CLOSE);
        ExtEMA2_Handle = iMA(_Symbol, (ENUM_TIMEFRAMES)InpFilter_Trend_TF, InpEMA2_Period, 0, MODE_EMA, PRICE_CLOSE);
        ExtEMA3_Handle = iMA(_Symbol, (ENUM_TIMEFRAMES)InpFilter_Trend_TF, InpEMA3_Period, 0, MODE_EMA, PRICE_CLOSE);
    }
    if(InpFilter_UseBBWidth)
    {
        ExtBB_Upper_Handle = iBands(_Symbol, (ENUM_TIMEFRAMES)InpTimeframe, InpFilter_BB_Period, InpFilter_BB_StdDev, 0, PRICE_CLOSE);
        ExtBB_Lower_Handle = ExtBB_Upper_Handle; // mesmo handle, buffers diferentes
    }
    if(InpTrailing_Method == TRAIL_PSAR)
    {
        ExtPSAR_Handle = iSAR(_Symbol, (ENUM_TIMEFRAMES)InpTimeframe, InpTrailing_PSAR_Step, InpTrailing_PSAR_Max);
    }
    if(InpTrailing_Method == TRAIL_FRACTAL)
    {
        ExtFractals_Handle = iFractals(_Symbol, (ENUM_TIMEFRAMES)InpTimeframe);
    }
    
    if(InpFilter_UseRSI)
        ExtRSI_Handle = iRSI(_Symbol, (ENUM_TIMEFRAMES)InpTimeframe, InpFilter_RSI_Period, PRICE_CLOSE);

    if((InpFilter_UseATR && ExtATR_Handle == INVALID_HANDLE) ||
       (InpFilter_UseTrend && InpFilter_Trend_Type == TREND_FILTER_MA && ExtTrend_MA_Handle == INVALID_HANDLE) ||
       (InpFilter_UseTrend && InpFilter_Trend_Type == TREND_FILTER_ADX && 
        (ExtTrend_ADX_Handle == INVALID_HANDLE)) ||
       (InpFilter_UseRSI && ExtRSI_Handle == INVALID_HANDLE) ||
       (InpFilter_UseEMAStack && (ExtEMA1_Handle == INVALID_HANDLE || ExtEMA2_Handle == INVALID_HANDLE || ExtEMA3_Handle == INVALID_HANDLE)) ||
       (InpFilter_UseBBWidth && ExtBB_Upper_Handle == INVALID_HANDLE) ||
       (InpTrailing_Method == TRAIL_PSAR && ExtPSAR_Handle == INVALID_HANDLE) ||
       (InpTrailing_Method == TRAIL_FRACTAL && ExtFractals_Handle == INVALID_HANDLE))
    {
        Print("Erro fatal ao criar handles de indicadores.");
        return(INIT_FAILED);
    }
    
    for(int i = 0; i < 50; i++)
    {
        G_OrderBlocks[i].time = 0;
        G_OrderBlocks[i].high = 0.0;
        G_OrderBlocks[i].low = 0.0;
        G_OrderBlocks[i].open = 0.0;
        G_OrderBlocks[i].close = 0.0;
        G_OrderBlocks[i].formation_volume = 0.0;
        G_OrderBlocks[i].formation_volume_ma = 0.0;
        G_OrderBlocks[i].is_bullish = false;
        // Inicializar como desabilitado para permitir alocação correta no primeiro uso
        G_OrderBlocks[i].state = OB_STATE_DISABLED;
        G_OrderBlocks[i].is_breaker = false;
        G_OrderBlocks[i].age_bars = 0;
        G_OrderBlocks[i].break_time = 0;
        G_OrderBlocks[i].score = 0.0;
        G_OrderBlocks[i].area = 0.0;
    }
    G_OB_Count = 0;
    G_LastTrailingSL = 0.0;
    
    Print("🏁 XAUUSD_Scalper_OB_v1.4 INICIADO - TF: ", EnumToString((ENUM_TIMEFRAMES)InpTimeframe));
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom deinit function                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Volume não utiliza handles em MQL5
    if(ExtATR_Handle != INVALID_HANDLE) IndicatorRelease(ExtATR_Handle);
    if(ExtTrend_MA_Handle != INVALID_HANDLE) IndicatorRelease(ExtTrend_MA_Handle);
    if(ExtTrend_ADX_Handle != INVALID_HANDLE) IndicatorRelease(ExtTrend_ADX_Handle);
    if(ExtRSI_Handle != INVALID_HANDLE) IndicatorRelease(ExtRSI_Handle);
    if(ExtEMA1_Handle != INVALID_HANDLE) IndicatorRelease(ExtEMA1_Handle);
    if(ExtEMA2_Handle != INVALID_HANDLE) IndicatorRelease(ExtEMA2_Handle);
    if(ExtEMA3_Handle != INVALID_HANDLE) IndicatorRelease(ExtEMA3_Handle);
    // BB usa o mesmo handle iBands
    if(ExtBB_Upper_Handle != INVALID_HANDLE) IndicatorRelease(ExtBB_Upper_Handle);
    if(ExtPSAR_Handle != INVALID_HANDLE) IndicatorRelease(ExtPSAR_Handle);
    if(ExtFractals_Handle != INVALID_HANDLE) IndicatorRelease(ExtFractals_Handle);
    
    Print("🏁 XAUUSD_Scalper_OB_v1.4 FINALIZADO");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    if(!IsTradingAllowed()) return;
    
    // Reset diário simples
    datetime today_date = (datetime)StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
    if(G_TodayDate != today_date)
    {
        G_TodayDate = today_date;
        G_TradesToday = 0;
        G_ConsecutiveLosses = 0;
    }

    ManageOpenPositions();
    
    if(PositionSelect(_Symbol)) return;
    
    datetime current_bar_time = iTime(_Symbol, (ENUM_TIMEFRAMES)InpTimeframe, 0);
    static datetime last_processed_bar = 0;
    if(current_bar_time != last_processed_bar)
    {
        IdentifyOrderBlocks();
        last_processed_bar = current_bar_time;
    }
    
    if(!CheckPrimaryDefenses()) return;
    
    SearchForOBSetups();
}

//+------------------------------------------------------------------+
//| Identifica Order Blocks válidos                                 |
//+------------------------------------------------------------------+
void IdentifyOrderBlocks()
{
    MqlRates rates[];
    int copied = CopyRates(_Symbol, (ENUM_TIMEFRAMES)InpTimeframe, 0, InpOB_Lookback, rates);
    if(copied <= 0 || ArraySize(rates) < 5) return;

    ArraySetAsSeries(rates, true);
    
    // Construir buffers de volume e média de volume (SMA) a partir de rates[].tick_volume
    double volume_buffer[];
    double volume_ma_buffer[];
    int n = ArraySize(rates);
    ArrayResize(volume_buffer, n);
    ArrayResize(volume_ma_buffer, n);
    for(int k = 0; k < n; k++)
        volume_buffer[k] = (double)rates[k].tick_volume;
    // SMA simples para cada índice (série)
    for(int k = 0; k < n; k++)
    {
        double sum = 0.0;
        int count = 0;
        for(int j = k; j < k + InpVolumeMALength && j < n; j++)
        {
            sum += volume_buffer[j];
            count++;
        }
        volume_ma_buffer[k] = (count > 0 ? sum / count : volume_buffer[k]);
    }
    ArraySetAsSeries(volume_buffer, true);
    ArraySetAsSeries(volume_ma_buffer, true);
    
    for(int i = 1; i < ArraySize(rates) - 2 && i < InpOB_Lookback - 2; i++)
    {
        if(rates[i].close < rates[i].open &&
           rates[i+1].close > rates[i+1].open &&
           rates[i+1].close > rates[i].high)
        {
            double displacement = (rates[i+1].close - rates[i].low) / G_PointValue;
            if(displacement >= InpOB_MinDisplacementPoints)
            {
                double body_i_low = MathMin(rates[i].open, rates[i].close);
                double body_i_high = MathMax(rates[i].open, rates[i].close);
                double body_i_size = body_i_high - body_i_low;
                
                if(body_i_size > 0)
                {
                    double mitigation_zone_low = body_i_low;
                    double mitigation_zone_high = body_i_low + (body_i_size * InpOB_MitigationLevel);
                    
                    if(rates[i+1].close > mitigation_zone_high)
                    {
                        AddOrderBlock(rates[i].time, rates[i].high, rates[i].low, rates[i].open, rates[i].close, volume_buffer[i], volume_ma_buffer[i], true, false);
                    }
                }
            }
        }
        
        if(rates[i].close > rates[i].open &&
           rates[i+1].close < rates[i+1].open &&
           rates[i+1].close < rates[i].low)
        {
            double displacement = (rates[i].high - rates[i+1].close) / G_PointValue;
            if(displacement >= InpOB_MinDisplacementPoints)
            {
                double body_i_low = MathMin(rates[i].open, rates[i].close);
                double body_i_high = MathMax(rates[i].open, rates[i].close);
                double body_i_size = body_i_high - body_i_low;
                
                if(body_i_size > 0)
                {
                    double mitigation_zone_low = body_i_high - (body_i_size * InpOB_MitigationLevel);
                    double mitigation_zone_high = body_i_high;
                    
                    if(rates[i+1].close < mitigation_zone_low)
                    {
                        AddOrderBlock(rates[i].time, rates[i].high, rates[i].low, rates[i].open, rates[i].close, volume_buffer[i], volume_ma_buffer[i], false, false);
                    }
                }
            }
        }
    }
    
    for(int i = 0; i < G_OB_Count; i++)
    {
        if(G_OrderBlocks[i].state == OB_STATE_ACTIVE)
        {
            G_OrderBlocks[i].age_bars++;
            if(G_OrderBlocks[i].age_bars > InpOB_MaxAgeBars)
            {
                G_OrderBlocks[i].state = OB_STATE_EXPIRED;
                Print("⏰ Order Block expirado: ", G_OrderBlocks[i].is_bullish ? "Bullish" : "Bearish", " @ ", DoubleToString((G_OrderBlocks[i].high+G_OrderBlocks[i].low)/2, _Digits));
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Adiciona um novo Order Block ao array                           |
//+------------------------------------------------------------------+
void AddOrderBlock(datetime time, double high, double low, double open, double close, double formation_vol, double formation_vol_ma, bool is_bullish, bool is_breaker)
{
    double ob_range_points = (high - low) / G_PointValue;
    double ob_area = ob_range_points * ob_range_points;
    
    double initial_score = 0.0;
    if(ob_area >= InpOB_MinAreaPoints) initial_score += 1.0;
    if(formation_vol > (formation_vol_ma * InpVolumeSpikeMultiplier)) initial_score += 1.0;
    
    for(int i = 0; i < G_OB_Count; i++)
    {
        if(G_OrderBlocks[i].state == OB_STATE_ACTIVE)
        {
            double overlap_percent = CalculateOverlapPercentage(G_OrderBlocks[i], high, low);
            if(overlap_percent > InpOB_MaxOverlapPercent)
            {
                Print("🚫 Order Block não adicionado devido a sobreposição alta (", DoubleToString(overlap_percent, 2), "%).");
                return;
            }
        }
    }
    
    int slot = -1;
    for(int i = 0; i < 50; i++)
    {
        if(G_OrderBlocks[i].state != OB_STATE_ACTIVE)
        {
            slot = i;
            break;
        }
    }
    
    if(slot != -1)
    {
        G_OrderBlocks[slot].time = time;
        G_OrderBlocks[slot].high = high;
        G_OrderBlocks[slot].low = low;
        G_OrderBlocks[slot].open = open;
        G_OrderBlocks[slot].close = close;
        G_OrderBlocks[slot].formation_volume = formation_vol;
        G_OrderBlocks[slot].formation_volume_ma = formation_vol_ma;
        G_OrderBlocks[slot].is_bullish = is_bullish;
        G_OrderBlocks[slot].state = OB_STATE_ACTIVE;
        G_OrderBlocks[slot].is_breaker = is_breaker;
        G_OrderBlocks[slot].age_bars = 0;
        G_OrderBlocks[slot].break_time = 0;
        G_OrderBlocks[slot].score = initial_score;
        G_OrderBlocks[slot].area = ob_area;
        
        if(slot >= G_OB_Count) G_OB_Count = slot + 1;
        
        Print("🔍 Order Block identificado: ", is_bullish ? "Bullish" : "Bearish", 
              " @ ", DoubleToString((high+low)/2, _Digits), 
              " (Área: ", DoubleToString(ob_area, 0), 
              ", Score: ", DoubleToString(initial_score, 2), 
              ", Vol: ", DoubleToString(formation_vol, 0), ")");
    }
}

//+------------------------------------------------------------------+
//| Calcula o percentual de sobreposição entre dois OBs              |
//+------------------------------------------------------------------+
double CalculateOverlapPercentage(const OrderBlock &ob1, double new_ob_high, double new_ob_low)
{
    double intersection_low = MathMax(ob1.low, new_ob_low);
    double intersection_high = MathMin(ob1.high, new_ob_high);
    
    if (intersection_low >= intersection_high) {
        return 0.0;
    }
    
    double intersection_area = (intersection_high - intersection_low) / G_PointValue;
    intersection_area *= intersection_area;
    
    double new_ob_range_points = (new_ob_high - new_ob_low) / G_PointValue;
    double new_ob_area = new_ob_range_points * new_ob_range_points;
    
    if(new_ob_area <= 0) return 0.0;
    
    return (intersection_area / new_ob_area) * 100.0;
}

//+------------------------------------------------------------------+
//| Verifica se o trading está permitido (sessão, horário, etc)      |
//+------------------------------------------------------------------+
bool IsTradingAllowed()
{
    datetime now = TimeCurrent();
    int day_of_week = TimeDayOfWeek(now);
    int hour = TimeHour(now);
    int minute = TimeMinute(now);
    
    if(day_of_week == 0 || day_of_week == 6) return false;
    
    switch(InpFilter_Session)
    {
        case SESSION_ALL:
            return true;
        case SESSION_ASIAN:
            return (hour >= 0 && hour < 9);
        case SESSION_LONDON:
            return (hour >= 8 && hour < 17);
        case SESSION_NY:
            return (hour >= 13 && hour < 22);
        case SESSION_LONDON_NY:
            return ((hour >= 8 && hour < 17) || (hour >= 13 && hour < 22));
        case SESSION_CUSTOM:
            datetime start_time = TimeHourMinuteToTime(now, InpFilter_CustomStart_Hour, InpFilter_CustomStart_Min);
            datetime end_time = TimeHourMinuteToTime(now, InpFilter_CustomEnd_Hour, InpFilter_CustomEnd_Min);
            if(end_time < start_time) end_time += 86400;
            return (now >= start_time && now <= end_time);
        case SESSION_ICT_KILLZONES:
            return IsInICTKillzone(now);
    }
    return true;
}

//+------------------------------------------------------------------+
//| Converte hora e minuto para datetime (do dia atual)              |
//+------------------------------------------------------------------+
datetime TimeHourMinuteToTime(datetime base_time, int hour, int minute)
{
    string date_str = TimeToString(base_time, TIME_DATE);
    string ts = StringFormat("%s %02d:%02d", date_str, hour, minute);
    return StringToTime(ts);
}

// Faz o parse de uma string "HH:MM" em hora/minuto
bool ParseHourMinute(const string hhmm, int &hour, int &minute)
{
    string parts[];
    int n = StringSplit(hhmm, ':', parts);
    if(n < 2) return false;
    hour = (int)StringToInteger(parts[0]);
    minute = (int)StringToInteger(parts[1]);
    if(hour < 0) hour = 0; if(hour > 23) hour = hour % 24;
    if(minute < 0) minute = 0; if(minute > 59) minute = minute % 60;
    return true;
}

//+------------------------------------------------------------------+
//| Verifica se o horário atual está dentro de uma Killzone ICT     |
//+------------------------------------------------------------------+
bool IsInICTKillzone(datetime current_time)
{
    int current_hour = TimeHour(current_time);
    int current_minute = TimeMinute(current_time);
    int current_time_minutes = current_hour * 60 + current_minute;
    // Ajuste de offset do broker vs GMT
    current_time_minutes = (current_time_minutes - InpBrokerGMTOffsetHours * 60) % (24*60);
    if(current_time_minutes < 0) current_time_minutes += 24*60;
    
    //--- Parsear os horários de início e fim das Killzones
    int asia_start_h, asia_start_m, asia_end_h, asia_end_m;
    int london_start_h, london_start_m, london_end_h, london_end_m;
    int nyam_start_h, nyam_start_m, nyam_end_h, nyam_end_m;
    int nylunch_start_h, nylunch_start_m, nylunch_end_h, nylunch_end_m;
    int nypm_start_h, nypm_start_m, nypm_end_h, nypm_end_m;
    
    // Asia
    ParseHourMinute(InpFilter_Killzone_AsiaBegin, asia_start_h, asia_start_m);
    ParseHourMinute(InpFilter_Killzone_AsiaEnd, asia_end_h, asia_end_m);
    int asia_start_minutes = asia_start_h * 60 + asia_start_m;
    int asia_end_minutes = asia_end_h * 60 + asia_end_m;
    if(asia_end_minutes <= asia_start_minutes) asia_end_minutes += 24 * 60; // Se terminar no dia seguinte
    
    // London
    ParseHourMinute(InpFilter_Killzone_LondonBegin, london_start_h, london_start_m);
    ParseHourMinute(InpFilter_Killzone_LondonEnd, london_end_h, london_end_m);
    int london_start_minutes = london_start_h * 60 + london_start_m;
    int london_end_minutes = london_end_h * 60 + london_end_m;
    if(london_end_minutes <= london_start_minutes) london_end_minutes += 24 * 60;
    
    // NY AM
    ParseHourMinute(InpFilter_Killzone_NYAMBegin, nyam_start_h, nyam_start_m);
    ParseHourMinute(InpFilter_Killzone_NYAMEnd, nyam_end_h, nyam_end_m);
    int nyam_start_minutes = nyam_start_h * 60 + nyam_start_m;
    int nyam_end_minutes = nyam_end_h * 60 + nyam_end_m;
    if(nyam_end_minutes <= nyam_start_minutes) nyam_end_minutes += 24 * 60;
    
    // NY Lunch
    ParseHourMinute(InpFilter_Killzone_NYLunchBegin, nylunch_start_h, nylunch_start_m);
    ParseHourMinute(InpFilter_Killzone_NYLunchEnd, nylunch_end_h, nylunch_end_m);
    int nylunch_start_minutes = nylunch_start_h * 60 + nylunch_start_m;
    int nylunch_end_minutes = nylunch_end_h * 60 + nylunch_end_m;
    if(nylunch_end_minutes <= nylunch_start_minutes) nylunch_end_minutes += 24 * 60;
    
    // NY PM
    ParseHourMinute(InpFilter_Killzone_NYPMBegin, nypm_start_h, nypm_start_m);
    ParseHourMinute(InpFilter_Killzone_NYPMEnd, nypm_end_h, nypm_end_m);
    int nypm_start_minutes = nypm_start_h * 60 + nypm_start_m;
    int nypm_end_minutes = nypm_end_h * 60 + nypm_end_m;
    if(nypm_end_minutes <= nypm_start_minutes) nypm_end_minutes += 24 * 60;
    
    //--- Verificar se o horário atual está em alguma Killzone permitida
    bool in_killzone = false;
    
    if(InpFilter_Killzone_AllowAsia)
    {
        if(asia_start_minutes <= current_time_minutes && current_time_minutes < asia_end_minutes)
            in_killzone = true;
        else if(asia_end_minutes > 24*60 && (current_time_minutes < (asia_end_minutes - 24*60)))
            in_killzone = true; // Se a zona termina no dia seguinte
    }
    
    if(!in_killzone && InpFilter_Killzone_AllowLondon)
    {
        if(london_start_minutes <= current_time_minutes && current_time_minutes < london_end_minutes)
            in_killzone = true;
        else if(london_end_minutes > 24*60 && (current_time_minutes < (london_end_minutes - 24*60)))
            in_killzone = true;
    }
    
    if(!in_killzone && InpFilter_Killzone_AllowNYAM)
    {
        if(nyam_start_minutes <= current_time_minutes && current_time_minutes < nyam_end_minutes)
            in_killzone = true;
        else if(nyam_end_minutes > 24*60 && (current_time_minutes < (nyam_end_minutes - 24*60)))
            in_killzone = true;
    }
    
    if(!in_killzone && InpFilter_Killzone_AllowNYLunch)
    {
        if(nylunch_start_minutes <= current_time_minutes && current_time_minutes < nylunch_end_minutes)
            in_killzone = true;
        else if(nylunch_end_minutes > 24*60 && (current_time_minutes < (nylunch_end_minutes - 24*60)))
            in_killzone = true;
    }
    
    if(!in_killzone && InpFilter_Killzone_AllowNYPm)
    {
        if(nypm_start_minutes <= current_time_minutes && current_time_minutes < nypm_end_minutes)
            in_killzone = true;
        else if(nypm_end_minutes > 24*60 && (current_time_minutes < (nypm_end_minutes - 24*60)))
            in_killzone = true;
    }
    
    return in_killzone;
}

//+------------------------------------------------------------------+
//| Verifica defesas primárias (spread, volatilidade, candle time)   |
//+------------------------------------------------------------------+
bool CheckPrimaryDefenses()
{
    datetime now = TimeCurrent();
    datetime current_bar_time = iTime(_Symbol, (ENUM_TIMEFRAMES)InpTimeframe, 0);
    datetime next_bar_time = current_bar_time + (int)InpTimeframe * 60;
    int seconds_until_new_bar = (int)(next_bar_time - now);
    
    if(InpFilter_UseCandleTime && seconds_until_new_bar < InpFilter_CandleTime_MinSecondsLeft)
    {
        return false;
    }

    G_Spread = (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID)) / G_PointValue;
    if(G_Spread > InpFilter_MaxSpread)
    {
        return false;
    }
    
    if(InpFilter_UseATR)
    {
        double atr_buffer[];
        if(CopyBuffer(ExtATR_Handle, 0, 0, 1, atr_buffer) > 0)
        {
            double current_atr = atr_buffer[0] / G_PointValue;
            if(current_atr < InpFilter_ATR_Min || current_atr > InpFilter_ATR_Max)
            {
                return false;
            }
        }
    }

    // Parar por limites diários e cooldown
    if(InpStopTradingAfterDailyLoss)
    {
        double daily_pnl = GetTodayRealizedPnL();
        double balance = AccountInfoDouble(ACCOUNT_BALANCE);
        if(balance > 0 && (-daily_pnl / balance) * 100.0 >= InpDailyLossLimitPercent)
        {
            return false;
        }
    }
    if(G_TradesToday >= InpMaxTradesPerDay) return false;
    if(G_ConsecutiveLosses >= InpMaxConsecutiveLosses) return false;
    if(G_LastLossTime > 0 && (now - G_LastLossTime) < (InpCooldownMinutesAfterLoss * 60)) return false;

    // News filter: funciona em backtest via CSV fallback ou via Calendar (tempo real)
    if(InpNewsFilter_Enable)
    {
        if(IsBlockedByNews(now))
            return false;
    }
    
    return true;
}

// Estrutura para news (CSV fallback)
struct NewsEvent {
    datetime time;
    string currency;
    int importance; // 0 low,1 medium,2 high
};

bool ParseCSVLine(const string line, datetime &t, string &ccy, int &imp)
{
    string parts[];
    int n = StringSplit(line, ';', parts);
    if(n < 3) return false;
    t = (datetime)StringToTime(parts[0]);
    ccy = parts[1];
    imp = (int)StringToInteger(parts[2]);
    return true;
}

bool IsCurrencyWatched(const string ccy)
{
    string watchlist = InpNews_Currencies;
    StringToUpper(watchlist);
    string token;
    int start = 0;
    while(true)
    {
        int pos = StringFind(watchlist, ";", start);
        if(pos == -1)
        {
            token = StringSubstr(watchlist, start);
            if(StringLen(token) > 0 && token == StringToUpper(ccy)) return true;
            break;
        }
        token = StringSubstr(watchlist, start, pos - start);
        if(StringLen(token) > 0 && token == StringToUpper(ccy)) return true;
        start = pos + 1;
    }
    return false;
}

bool IsBlockedByNews(datetime now)
{
    // 1) CSV fallback (funciona em backtest e vida real)
    if(InpNews_UseCSV_Fallback)
    {
        ResetLastError();
        int fh = FileOpen(InpNews_CSV_FileName, FILE_READ|FILE_TXT|FILE_ANSI);
        if(fh != INVALID_HANDLE)
        {
            while(!FileIsEnding(fh))
            {
                string line = FileReadString(fh);
                if(StringLen(line) == 0) continue;
                datetime et; string ccy; int imp;
                if(!ParseCSVLine(line, et, ccy, imp)) continue;
                if(imp < InpNews_MinImportance) continue;
                if(!IsCurrencyWatched(ccy)) continue;
                datetime begin_blk = et - InpNews_BlockMinutes_Before * 60;
                datetime end_blk = et + InpNews_BlockMinutes_After * 60;
                if(now >= begin_blk && now <= end_blk)
                {
                    FileClose(fh);
                    return true;
                }
            }
            FileClose(fh);
        }
    }

    // 2) Calendar API (tempo real e backtest com dados de calendário, se disponíveis)
    MqlCalendarValue values[];
    datetime from_time = now - 24*60*60;
    datetime to_time = now + 24*60*60;
    if(CalendarValueHistory(values, from_time, to_time))
    {
        for(int i=0; i<ArraySize(values); i++)
        {
            MqlCalendarValue v = values[i];
            if(v.importance < InpNews_MinImportance) continue;
            string ccy = v.currency;
            if(!IsCurrencyWatched(ccy)) continue;
            datetime et = v.time;
            datetime begin_blk = et - InpNews_BlockMinutes_Before * 60;
            datetime end_blk = et + InpNews_BlockMinutes_After * 60;
            if(now >= begin_blk && now <= end_blk)
                return true;
        }
    }
    return false;
}

// Calcula PnL realizado hoje (símbolo atual)
double GetTodayRealizedPnL()
{
    datetime day_start = (datetime)StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
    HistorySelect(day_start, TimeCurrent());
    double sum = 0.0;
    uint deals = HistoryDealsTotal();
    for(uint i = 0; i < deals; i++)
    {
        ulong ticket = HistoryDealGetTicket(i);
        if((string)HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol) continue;
        long entry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
        if(entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_INOUT)
        {
            sum += HistoryDealGetDouble(ticket, DEAL_PROFIT);
        }
    }
    return sum;
}

//+------------------------------------------------------------------+
//| Calcula o tamanho do lote com base no risco                      |
//+------------------------------------------------------------------+
double CalculateLotSize(double sl_points)
{
    if(sl_points <= 0) return 0;
    
    double lot_size = 0.0;
    double account_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double risk_amount = 0.0;
    
    if(InpMoney_LotSizingMethod == RISCO_PERCENTUAL)
    {
        risk_amount = account_balance * (InpMoney_RiskPercent / 100.0);
    }
    else
    {
        return InpMoney_FixedLot;
    }
    
    double max_risk_amount = account_balance * (InpMoney_MaxRiskPerTrade / 100.0);
    if(risk_amount > max_risk_amount)
        risk_amount = max_risk_amount;
        
    if(risk_amount <= 0) return 0;
    
    double sl_in_currency = sl_points * G_SymbolTickValue;
    if(sl_in_currency <= 0) return 0;
    
    lot_size = risk_amount / sl_in_currency;
    
    double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lot_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    
    if(lot_size < min_lot) lot_size = min_lot;
    if(lot_size > max_lot) lot_size = max_lot;
    
    lot_size = MathFloor(lot_size / lot_step) * lot_step;
    
    return NormalizeDouble(lot_size, 2);
}

//+------------------------------------------------------------------+
//| Calcula SL e TP                                                  |
//+------------------------------------------------------------------+
void CalculateSLandTP(ENUM_ORDER_TYPE order_type, double entry_price, double &sl, double &tp)
{
    double sl_points = 0;
    double tp_points = 0;
    
    if(InpSL_Type == SL_FIXED_POINTS)
    {
        sl_points = InpSL_FixedPoints;
    }
    else if(InpSL_Type == SL_ATR_DYNAMIC)
    {
        double atr_buffer[];
        if(CopyBuffer(ExtATR_Handle, 0, 0, 1, atr_buffer) > 0)
            sl_points = (atr_buffer[0] / G_PointValue) * InpSL_ATR_Multiplier;
        else
            sl_points = InpSL_FixedPoints;
    }
    
    if(InpTP_Type == TP_FIXED_POINTS)
    {
        tp_points = InpTP_FixedPoints;
    }
    else if(InpTP_Type == TP_ATR_DYNAMIC)
    {
         double atr_buffer[];
         if(CopyBuffer(ExtATR_Handle, 0, 0, 1, atr_buffer) > 0)
             tp_points = (atr_buffer[0] / G_PointValue) * InpTP_ATR_Multiplier;
         else
             tp_points = InpTP_FixedPoints;
    }
    else if(InpTP_Type == TP_FIBO_DYNAMIC)
    {
        tp_points = sl_points * InpTP_Fibo_Extension;
    }
    
    if(order_type == ORDER_TYPE_BUY)
    {
        sl = entry_price - sl_points * G_PointValue;
        tp = entry_price + tp_points * G_PointValue;
    }
    else
    {
        sl = entry_price + sl_points * G_PointValue;
        tp = entry_price - tp_points * G_PointValue;
    }
}

//+------------------------------------------------------------------+
//| Abre uma operação                                                |
//+------------------------------------------------------------------+
bool OpenTrade(ENUM_ORDER_TYPE order_type, double entry_price, double sl, double tp, double lot_size, int ob_index=-1)
{
    if(lot_size <= 0 || sl <= 0 || tp <= 0) return false;
    
    double price = (order_type == ORDER_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
    
    double rr = MathAbs(tp - entry_price) / MathAbs(entry_price - sl);
    if(rr < InpRR_Min)
    {
        return false;
    }
    
    string comment_suffix = (ob_index != -1) ? " OB#" + IntegerToString(ob_index) : "";
    trade.PositionOpen(_Symbol, order_type, lot_size, price, sl, tp, InpComment + comment_suffix);
    
    const uint rc = trade.ResultRetcode();
    if(rc != TRADE_RETCODE_DONE && rc != TRADE_RETCODE_DONE_PARTIAL)
    {
        Print("❌ Erro ao abrir posição: ", trade.ResultRetcodeDescription());
        return false;
    }
    else
    {
        G_LastTradeTime = TimeCurrent();
        G_LastTrailingSL = 0.0;
        G_Partial1_Done = false;
        G_Partial2_Done = false;
        G_TradesToday++;
        if(ob_index != -1)
        {
            G_OrderBlocks[ob_index].state = OB_STATE_TAKEN;
        }
        Print((order_type == ORDER_TYPE_BUY ? "🟢 COMPRA" : "🔴 VENDA"), " aberta. Lote: ", DoubleToString(lot_size, 2),
              ", SL: ", DoubleToString(sl, _Digits), ", TP: ", DoubleToString(tp, _Digits), comment_suffix);
        return true;
    }
}

//+------------------------------------------------------------------+
//| Procura por setups de Order Blocks                               |
//+------------------------------------------------------------------+
void SearchForOBSetups()
{
    if(G_OB_Count <= 0) return;
    
    MqlRates current_rates[];
    if(CopyRates(_Symbol, (ENUM_TIMEFRAMES)InpTimeframe, 0, 2, current_rates) <= 0) return;
    ArraySetAsSeries(current_rates, true);
    double current_price = current_rates[0].close;
    
    if(!PassAdvancedFilters(current_price)) return;
    
    for(int i = 0; i < G_OB_Count; i++)
    {
        if(G_OrderBlocks[i].state != OB_STATE_ACTIVE) continue;
        
        OrderBlock &ob = G_OrderBlocks[i];
        
        if(ob.is_bullish)
        {
            // Entrada buy: retorno à zona do OB (mitigação) + filtros
            bool returned_into_zone = (current_rates[1].low <= ob.high && current_rates[1].high >= ob.low);
            if(returned_into_zone)
            {
                if(ConfirmVolumeFlow(ORDER_TYPE_BUY) && PassTrendDirectionFilter(ORDER_TYPE_BUY) && PassEMAMomentumFilter(ORDER_TYPE_BUY))
                {
                    double sl_price, tp_price;
                    CalculateSLandTP(ORDER_TYPE_BUY, current_price, sl_price, tp_price);
                    double lot_size = CalculateLotSize(MathAbs(current_price - sl_price) / G_PointValue);
                    
                    if(OpenTrade(ORDER_TYPE_BUY, current_price, sl_price, tp_price, lot_size, i))
                    {
                        return;
                    }
                }
            }
        }
        else
        {
            bool returned_into_zone = (current_rates[1].low <= ob.high && current_rates[1].high >= ob.low);
            if(returned_into_zone)
            {
                 if(ConfirmVolumeFlow(ORDER_TYPE_SELL) && PassTrendDirectionFilter(ORDER_TYPE_SELL) && PassEMAMomentumFilter(ORDER_TYPE_SELL))
                 {
                     double sl_price, tp_price;
                     CalculateSLandTP(ORDER_TYPE_SELL, current_price, sl_price, tp_price);
                     double lot_size = CalculateLotSize(MathAbs(current_price - sl_price) / G_PointValue);
                     
                     if(OpenTrade(ORDER_TYPE_SELL, current_price, sl_price, tp_price, lot_size, i))
                     {
                         return;
                     }
                 }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Confirma o fluxo de volume para uma entrada                     |
//+------------------------------------------------------------------+
bool ConfirmVolumeFlow(ENUM_ORDER_TYPE order_type)
{
    // Obter volume do candle atual e média dos últimos N via CopyRates
    MqlRates temp[];
    if(CopyRates(_Symbol, (ENUM_TIMEFRAMES)InpTimeframe, 0, InpVolumeMALength, temp) <= 0) return false;
    ArraySetAsSeries(temp, true);
    double current_volume = (double)temp[0].tick_volume;
    double sum = 0.0;
    int count = MathMin(InpVolumeMALength, ArraySize(temp));
    for(int i = 0; i < count; i++) sum += (double)temp[i].tick_volume;
    double current_volume_ma = (count > 0 ? sum / count : current_volume);
    
    if(current_volume > (current_volume_ma * InpVolumeSpikeMultiplier))
        return true;
    
    return false;
}

//+------------------------------------------------------------------+
//| Aplica filtros avançados antes de procurar setups                |
//+------------------------------------------------------------------+
bool PassAdvancedFilters(double current_price)
{
    if(InpFilter_UseTrend)
    {
        if(InpFilter_Trend_Type == TREND_FILTER_MA)
        {
            double ma_buffer[];
            if(CopyBuffer(ExtTrend_MA_Handle, 0, 0, 1, ma_buffer) <= 0) return false;
            double close_tf_price = iClose(_Symbol, (ENUM_TIMEFRAMES)InpFilter_Trend_TF, 0);
            if(close_tf_price == 0) return false;
            // Não aplicamos direção aqui; direção será verificada em PassTrendDirectionFilter
        }
        else if(InpFilter_Trend_Type == TREND_FILTER_ADX)
        {
            double adx_buffer[], diplus_buffer[], diminus_buffer[];
            if(CopyBuffer(ExtTrend_ADX_Handle, 0, 0, 1, adx_buffer) <= 0) return false; // ADX
            if(CopyBuffer(ExtTrend_ADX_Handle, 1, 0, 1, diplus_buffer) <= 0) return false; // +DI
            if(CopyBuffer(ExtTrend_ADX_Handle, 2, 0, 1, diminus_buffer) <= 0) return false; // -DI
            double adx_value = adx_buffer[0];
            if(adx_value < InpFilter_Trend_MinStrength) return false;
            // Direção (+DI vs -DI) será checada no momento da entrada com base no tipo de ordem.
        }
    }
    
    if(InpFilter_UseRSI)
    {
        double rsi_buffer[];
        if(CopyBuffer(ExtRSI_Handle, 0, 0, 1, rsi_buffer) > 0)
        {
            double rsi_value = rsi_buffer[0];
            if(rsi_value > InpFilter_RSI_Overbought || rsi_value < InpFilter_RSI_Oversold)
            {
                 return false;
            }
        }
        else return false;
    }

    if(InpFilter_UseBBWidth)
    {
        double upper[], lower[];
        if(CopyBuffer(ExtBB_Upper_Handle, 0, 0, 1, upper) <= 0) return false; // upper band
        if(CopyBuffer(ExtBB_Lower_Handle, 1, 0, 1, lower) <= 0) return false; // lower band buffer idx=1
        double width_points = (upper[0] - lower[0]) / G_PointValue;
        if(width_points < InpFilter_BBWidth_MinPoints || width_points > InpFilter_BBWidth_MaxPoints)
            return false;
    }

    // London Breakout (opcional): se ativo, exigir que preço esteja rompendo o range Ásia a favor do filtro de direção
    if(InpUseLondonBreakout)
    {
        datetime now = TimeCurrent();
        // calcular janela Ásia no dia atual (considerando offset GMT do broker)
        int sh, sm, eh, em;
        if(!ParseHourMinute(InpAsiaRangeBegin, sh, sm)) return false;
        if(!ParseHourMinute(InpAsiaRangeEnd, eh, em)) return false;
        datetime day0 = (datetime)StringToTime(TimeToString(now, TIME_DATE));
        datetime asia_start = day0 + (sh*3600 + sm*60) + InpBrokerGMTOffsetHours*3600;
        datetime asia_end = day0 + (eh*3600 + em*60) + InpBrokerGMTOffsetHours*3600;
        if(asia_end <= asia_start) asia_end += 24*3600;

        // obter high/low do período Ásia (intervalo de tempo)
        MqlRates r[];
        int bars = CopyRates(_Symbol, (ENUM_TIMEFRAMES)InpTimeframe, asia_start, asia_end, r);
        if(bars > 0)
        {
            ArraySetAsSeries(r, true);
            double asia_high = -DBL_MAX, asia_low = DBL_MAX;
            for(int i=0; i<bars; i++)
            {
                if(r[i].high > asia_high) asia_high = r[i].high;
                if(r[i].low < asia_low) asia_low = r[i].low;
            }
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            bool breaking_up = (bid > asia_high);
            bool breaking_down = (ask < asia_low);
            // Filtro: exigir ruptura em uma das direções (entrada efetiva checa direção no gatilho)
            if(!breaking_up && !breaking_down) return false;
        }
    }
    
    return true;
}

int barSeconds(int tfMinutes)
{
    return tfMinutes*60;
}

//+------------------------------------------------------------------+
//| Trade transaction handler: atualiza perdas/ganhos e contadores   |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result)
{
    if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
    {
        ulong deal = trans.deal;
        if(HistoryDealSelect(deal))
        {
            string sym = (string)HistoryDealGetString(deal, DEAL_SYMBOL);
            if(sym != _Symbol) return;
            long entry = HistoryDealGetInteger(deal, DEAL_ENTRY);
            if(entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_INOUT)
            {
                double profit = HistoryDealGetDouble(deal, DEAL_PROFIT);
                if(profit < 0)
                {
                    G_LastLossTime = TimeCurrent();
                    G_ConsecutiveLosses++;
                }
                else if(profit > 0)
                {
                    G_ConsecutiveLosses = 0;
                }
            }
        }
    }
}

// Verifica a direção da tendência conforme filtro configurado
bool PassTrendDirectionFilter(ENUM_ORDER_TYPE order_type)
{
    if(!InpFilter_UseTrend) return true;
    if(InpFilter_Trend_Type == TREND_FILTER_MA)
    {
        double ma_buffer[];
        if(CopyBuffer(ExtTrend_MA_Handle, 0, 0, 1, ma_buffer) <= 0) return false;
        double close_tf_price = iClose(_Symbol, (ENUM_TIMEFRAMES)InpFilter_Trend_TF, 0);
        if(close_tf_price == 0) return false;
        if(order_type == ORDER_TYPE_BUY)
            return (close_tf_price >= ma_buffer[0]);
        else
            return (close_tf_price <= ma_buffer[0]);
    }
    else if(InpFilter_Trend_Type == TREND_FILTER_ADX)
    {
        double plusdi[], minusdi[];
        if(CopyBuffer(ExtTrend_ADX_Handle, 1, 0, 1, plusdi) <= 0) return false;
        if(CopyBuffer(ExtTrend_ADX_Handle, 2, 0, 1, minusdi) <= 0) return false;
        if(order_type == ORDER_TYPE_BUY)
            return (plusdi[0] >= minusdi[0]);
        else
            return (minusdi[0] >= plusdi[0]);
    }
    return true;
}

bool PassEMAMomentumFilter(ENUM_ORDER_TYPE order_type)
{
    if(!InpFilter_UseEMAStack) return true;
    double e1[], e2[], e3[];
    if(CopyBuffer(ExtEMA1_Handle, 0, 0, 1, e1) <= 0) return false;
    if(CopyBuffer(ExtEMA2_Handle, 0, 0, 1, e2) <= 0) return false;
    if(CopyBuffer(ExtEMA3_Handle, 0, 0, 1, e3) <= 0) return false;
    if(order_type == ORDER_TYPE_BUY)
        return (e1[0] >= e2[0] && e2[0] >= e3[0]);
    else
        return (e1[0] <= e2[0] && e2[0] <= e3[0]);
}

//+------------------------------------------------------------------+
//| Gerencia posições abertas (Proteção de Lucro)                   |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
    if(!PositionSelect(_Symbol)) return;
    if(InpProfitProtection_Type == PP_NONE && !InpUsePartials) return;
    
    ulong position_ticket = PositionGetInteger(POSITION_TICKET);
    ENUM_ORDER_TYPE position_type = (ENUM_ORDER_TYPE)PositionGetInteger(POSITION_TYPE);
    double position_open_price = PositionGetDouble(POSITION_PRICE_OPEN);
    double position_sl = PositionGetDouble(POSITION_SL);
    double position_tp = PositionGetDouble(POSITION_TP);
    double position_volume = PositionGetDouble(POSITION_VOLUME);
    
    double current_market_price = (position_type == ORDER_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    
    double profit_distance_points = 0;
    if(position_type == ORDER_TYPE_BUY)
        profit_distance_points = (current_market_price - position_open_price) / G_PointValue;
    else
        profit_distance_points = (position_open_price - current_market_price) / G_PointValue;
    
    double required_profit_distance = 0;
    double sl_points = MathAbs(position_open_price - position_sl) / G_PointValue;
    if(sl_points > 0)
        required_profit_distance = sl_points * InpProfitProtection_MultSL;
    
    bool modification_needed = false;
    double new_sl = position_sl;
    double new_tp = position_tp;
    
    if(InpProfitProtection_UseDynamicBE && profit_distance_points >= (sl_points * InpProfitProtection_BE_MultSL))
    {
        double buffer_points = 5;
        if(position_type == ORDER_TYPE_BUY)
        {
            double potential_new_sl = position_open_price + (buffer_points * G_PointValue);
            if(potential_new_sl > position_sl)
            {
                new_sl = potential_new_sl;
                modification_needed = true;
            }
        }
        else
        {
            double potential_new_sl = position_open_price - (buffer_points * G_PointValue);
            if(potential_new_sl < position_sl)
            {
                new_sl = potential_new_sl;
                modification_needed = true;
            }
        }
    }
    
    if(profit_distance_points >= required_profit_distance)
    {
        if((InpProfitProtection_Type == PP_BREAKEVEN || InpProfitProtection_Type == PP_BREAKEVEN_THEN_TRAILING) && !modification_needed)
        {
            double buffer_points = 5;
            if(position_type == ORDER_TYPE_BUY)
            {
                double potential_new_sl = position_open_price + (buffer_points * G_PointValue);
                if(potential_new_sl > position_sl)
                {
                    new_sl = potential_new_sl;
                    modification_needed = true;
                }
            }
            else
            {
                double potential_new_sl = position_open_price - (buffer_points * G_PointValue);
                if(potential_new_sl < position_sl)
                {
                    new_sl = potential_new_sl;
                    modification_needed = true;
                }
            }
        }
        
        if(InpProfitProtection_Type == PP_TRAILING_STOP || InpProfitProtection_Type == PP_BREAKEVEN_THEN_TRAILING)
        {
            if(position_type == ORDER_TYPE_BUY)
            {
                double current_trailing_sl = position_sl;
                if(InpTrailing_Method == TRAIL_POINTS)
                    current_trailing_sl = current_market_price - (InpProfitProtection_TrailingPoints * G_PointValue);
                else if(InpTrailing_Method == TRAIL_ATR)
                {
                    double atrb[];
                    if(CopyBuffer(ExtATR_Handle, 0, 0, 1, atrb) > 0)
                        current_trailing_sl = current_market_price - (InpTrailing_ATR_Multiplier * atrb[0]);
                }
                else if(InpTrailing_Method == TRAIL_PSAR)
                {
                    double psar[];
                    if(CopyBuffer(ExtPSAR_Handle, 0, 0, 1, psar) > 0) current_trailing_sl = psar[0];
                }
                else if(InpTrailing_Method == TRAIL_FRACTAL)
                {
                    double fr_up[], fr_dn[];
                    if(CopyBuffer(ExtFractals_Handle, 0, 0, 1, fr_up) > 0) // upper
                    {
                        // SL abaixo do último fractal down se existir; caso contrário, usar upper como fallback
                        if(CopyBuffer(ExtFractals_Handle, 1, 0, 1, fr_dn) > 0 && fr_dn[0] > 0)
                            current_trailing_sl = fr_dn[0];
                        else if(fr_up[0] > 0)
                            current_trailing_sl = fr_up[0];
                    }
                }
                current_trailing_sl = NormalizeDouble(current_trailing_sl, (int)MathLog10(1/G_PointValue));
                
                if(current_trailing_sl > G_LastTrailingSL)
                {
                    G_LastTrailingSL = current_trailing_sl;
                }
                
                if(G_LastTrailingSL > position_sl)
                {
                    new_sl = G_LastTrailingSL;
                    modification_needed = true;
                }
            }
            else
            {
                 double current_trailing_sl = position_sl;
                 if(InpTrailing_Method == TRAIL_POINTS)
                     current_trailing_sl = current_market_price + (InpProfitProtection_TrailingPoints * G_PointValue);
                 else if(InpTrailing_Method == TRAIL_ATR)
                 {
                     double atrb[];
                     if(CopyBuffer(ExtATR_Handle, 0, 0, 1, atrb) > 0)
                         current_trailing_sl = current_market_price + (InpTrailing_ATR_Multiplier * atrb[0]);
                 }
                 else if(InpTrailing_Method == TRAIL_PSAR)
                 {
                     double psar[];
                     if(CopyBuffer(ExtPSAR_Handle, 0, 0, 1, psar) > 0) current_trailing_sl = psar[0];
                 }
                 else if(InpTrailing_Method == TRAIL_FRACTAL)
                 {
                     double fr_up[], fr_dn[];
                     if(CopyBuffer(ExtFractals_Handle, 1, 0, 1, fr_dn) > 0) // lower
                     {
                         if(fr_up[0] > 0)
                             current_trailing_sl = fr_up[0];
                         if(fr_dn[0] > 0)
                             current_trailing_sl = fr_up[0];
                     }
                 }
                 current_trailing_sl = NormalizeDouble(current_trailing_sl, (int)MathLog10(1/G_PointValue));
                 
                 if(current_trailing_sl < G_LastTrailingSL || G_LastTrailingSL == 0.0)
                 {
                     G_LastTrailingSL = current_trailing_sl;
                 }
                 
                 if(G_LastTrailingSL < position_sl)
                 {
                     new_sl = G_LastTrailingSL;
                     modification_needed = true;
                 }
            }
        }
    }

    // Parciais
    if(InpUsePartials && position_volume > SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
    {
        double risk_points = MathAbs(position_open_price - position_sl) / G_PointValue;
        if(risk_points > 0)
        {
            double r_multiple = profit_distance_points / risk_points;
            double vol_min = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
            double vol_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

            if(!G_Partial1_Done && r_multiple >= InpPartial1_R && InpPartial1_Percent > 0)
            {
                double close_vol = MathMax(vol_min, MathFloor((position_volume * InpPartial1_Percent) / vol_step) * vol_step);
                if(close_vol < position_volume)
                {
                    trade.PositionClosePartial(_Symbol, close_vol);
                    const uint rc1 = trade.ResultRetcode();
                    if(rc1 == TRADE_RETCODE_DONE || rc1 == TRADE_RETCODE_DONE_PARTIAL)
                    {
                        G_Partial1_Done = true;
                        double be_sl = (position_type == ORDER_TYPE_BUY) ? position_open_price + InpPartial_BE_BufferPoints*G_PointValue
                                                                         : position_open_price - InpPartial_BE_BufferPoints*G_PointValue;
                        if((position_type == ORDER_TYPE_BUY && be_sl > new_sl) || (position_type == ORDER_TYPE_SELL && be_sl < new_sl))
                        {
                            new_sl = be_sl;
                            modification_needed = true;
                        }
                    }
                }
            }
            if(!G_Partial2_Done && r_multiple >= InpPartial2_R && InpPartial2_Percent > 0)
            {
                double curr_volume = PositionGetDouble(POSITION_VOLUME);
                double close_vol = MathMax(vol_min, MathFloor((curr_volume * InpPartial2_Percent) / vol_step) * vol_step);
                if(close_vol < curr_volume)
                {
                    trade.PositionClosePartial(_Symbol, close_vol);
                    const uint rc2 = trade.ResultRetcode();
                    if(rc2 == TRADE_RETCODE_DONE || rc2 == TRADE_RETCODE_DONE_PARTIAL)
                    {
                        G_Partial2_Done = true;
                    }
                }
            }
        }
    }
    
    if(modification_needed)
    {
        // Não zerar TP; manter o valor atual a menos que se deseje remover explicitamente
        trade.PositionModify(_Symbol, new_sl, new_tp);
        
        const uint rc = trade.ResultRetcode();
        if(rc != TRADE_RETCODE_DONE && rc != TRADE_RETCODE_DONE_PARTIAL)
        {
            Print("⚠️ Aviso ao modificar posição #", position_ticket, ": ", trade.ResultRetcodeDescription());
        }
        else
        {
            string protection_type_str = "";
            if(InpProfitProtection_Type == PP_BREAKEVEN)
                protection_type_str = "Breakeven";
            else if(InpProfitProtection_Type == PP_TRAILING_STOP)
                protection_type_str = "Trailing Stop";
            else if(InpProfitProtection_Type == PP_BREAKEVEN_THEN_TRAILING)
                protection_type_str = "Breakeven+Trailing";
                
            Print("🛡️ Proteção de Lucro (", protection_type_str, ") aplicada. Novo SL: ", DoubleToString(new_sl, _Digits));
        }
    }

    // Saídas avançadas: time-stop e compressão BB
    if(InpExit_TimeStop_Bars > 0 || InpExit_Compress_BBWidth_Points > 0)
    {
        datetime pos_time = (datetime)PositionGetInteger(POSITION_TIME);
        datetime curr_bar_time = iTime(_Symbol, (ENUM_TIMEFRAMES)InpTimeframe, 0);
        int bar_seconds = ((int)InpTimeframe) * 60;
        int bars_held = (int)((curr_bar_time - pos_time) / bar_seconds);
        double risk_points2 = MathAbs(position_open_price - position_sl) / G_PointValue;
        double r_now = (risk_points2 > 0) ? (profit_distance_points / risk_points2) : 0.0;

        bool exit_now = false;
        if(InpExit_TimeStop_Bars > 0 && bars_held >= InpExit_TimeStop_Bars)
        {
            // Se r_now não for satisfatório, sair
            if(r_now < InpExit_Compress_MinRToHold)
                exit_now = true;
        }

        if(!exit_now && InpExit_Compress_BBWidth_Points > 0 && InpFilter_UseBBWidth)
        {
            double upper[], lower[];
            if(CopyBuffer(ExtBB_Upper_Handle, 0, 0, 1, upper) > 0 && CopyBuffer(ExtBB_Lower_Handle, 1, 0, 1, lower) > 0)
            {
                double width_points = (upper[0] - lower[0]) / G_PointValue;
                if(width_points <= InpExit_Compress_BBWidth_Points && r_now < InpExit_Compress_MinRToHold)
                    exit_now = true;
            }
        }

        if(exit_now)
        {
            double vol = PositionGetDouble(POSITION_VOLUME);
            double vol_min = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
            if(vol > vol_min)
            {
                trade.PositionClosePartial(_Symbol, vol);
            }
            else
            {
                trade.PositionClose(_Symbol);
            }
        }
    }
}
