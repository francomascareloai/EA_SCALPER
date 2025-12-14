//+------------------------------------------------------------------+
//|                                        EA_AGGRESSIVE_SCALPER.mq5 |
//|                                                            Franco |
//|           AGGRESSIVE MODE v2.0 GENIUS - Self-Learning EA         |
//+------------------------------------------------------------------+
//|                                                                  |
//|  AUTO-APRENDIZADO COMPLETO:                                      |
//|  1. Kelly Criterion Real - Calcula fração ótima                  |
//|  2. Learning por Setup - Sabe qual setup funciona melhor         |
//|  3. Learning por Sessão - Sabe qual horário é melhor             |
//|  4. Learning por Regime - Sabe qual regime é lucrativo           |
//|  5. Bayesian Updates - Atualiza probabilidades com resultados    |
//|  6. Persistência - Salva aprendizado entre sessões               |
//|                                                                  |
//|  ANTI-QUEBRA:                                                    |
//|  - Circuit breaker multi-nível                                   |
//|  - Detecta tilting e para                                        |
//|  - Max 10% DD dia = emergência                                   |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Franco - EA_SCALPER_XAUUSD Project"
#property link      "https://github.com/franco/ea-scalper"
#property version   "3.10"
#property strict
#property description "Aggressive Scalper v3.1 GENIUS - Footprint + MTF + Structure Trail + Adaptive Learning"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>

// === FASE 1 & 2: GENIUS MODULES ===
#include <EA_SCALPER\Analysis\CFootprintAnalyzer.mqh>
#include <EA_SCALPER\Analysis\CMTFManager.mqh>
#include <EA_SCALPER\Analysis\CRegimeDetector.mqh>
#include <EA_SCALPER\Analysis\CStructureAnalyzer.mqh>  // FASE 1.3: Structure-Based Trailing

//+------------------------------------------------------------------+
//| EA MODE SELECTION                                                 |
//+------------------------------------------------------------------+
enum ENUM_EA_MODE
{
   MODE_CONSERVATIVE = 0,    // CONSERVATIVE - Poucos trades, alta qualidade
   MODE_AGGRESSIVE = 1,      // AGGRESSIVE - Balanceado (padrao)
   MODE_PURE_SCALPER = 2,    // PURE SCALPER - Muitos trades, TP rapido
   MODE_TURBO = 3            // TURBO - Ultra agressivo, minimos filtros
};

//+------------------------------------------------------------------+
//| INPUT PARAMETERS                                                  |
//+------------------------------------------------------------------+
input group "=== EA MODE ==="
input ENUM_EA_MODE InpEAMode       = MODE_PURE_SCALPER; // Trading Mode (MUDA TUDO!)

input group "=== RISK SETTINGS (AGGRESSIVE MODE) ==="
input double   InpBaseRisk         = 3.0;      // Base Risk % per trade (ERA 2.0)
input double   InpMaxRisk          = 10.0;     // Maximum Risk % hot streak (ERA 5.0)
input double   InpMinRisk          = 1.0;      // Minimum Risk % (ERA 0.3)
input double   InpMaxDailyDD       = 30.0;     // Max Daily DD % - conta pessoal (ERA 10.0)
input double   InpSoftDailyDD      = 15.0;     // Soft Daily DD % (ERA 6.0)
input int      InpMaxConsecLosses  = 5;        // Max Consecutive Losses (ERA 4)

input group "=== TRADE SETTINGS (AGGRESSIVE) ==="
input double   InpSL_ATR_Mult      = 1.2;      // SL = ATR × this (ERA 1.5 - mais tight)
input double   InpTP_RR            = 3.0;      // Target R:R ratio (ERA 2.0 - busca runners)
input double   InpMinRR            = 1.5;      // Minimum R:R (ERA 1.0 - só trades bons)
input int      InpATR_Period       = 14;       // ATR Period
input int      InpMaxTradesDay     = 50;       // Max Trades per Day (ERA 30)
input int      InpMaxSpread        = 50;       // Max Spread points (ERA 100 - filtra lixo)

input group "=== SESSION FILTER ==="
input bool     InpLondonOnly       = false;    // Trade London/Overlap only (learning decides)
input int      InpLondonStart      = 7;        // London Start Hour (GMT)
input int      InpOverlapEnd       = 16;       // Overlap End Hour (GMT)
input int      InpGMT_Offset       = 2;        // Broker GMT Offset

input group "=== SMC SETTINGS ==="
input int      InpOB_Lookback      = 20;       // Order Block Lookback
input double   InpOB_Displacement  = 0.8;      // OB Displacement (ATR mult) - RELAXADO
input int      InpSweep_Lookback   = 20;       // Liquidity Sweep Lookback
input double   InpSweep_Tolerance  = 0.25;     // Sweep Tolerance % - RELAXADO

input group "=== MA/RSI SETTINGS ==="
input bool     InpUseMACross       = true;     // Enable EMA crossover setup
input int      InpFastMA           = 8;        // Fast EMA period
input int      InpSlowMA           = 21;       // Slow EMA period
input bool     InpUseRSI           = false;    // Use RSI filter - DESATIVADO
input int      InpRSI_Period       = 14;       // RSI period
input int      InpRSI_OB           = 75;       // RSI overbought - RELAXADO
input int      InpRSI_OS           = 25;       // RSI oversold - RELAXADO

input group "=== FIBONACCI ==="
input bool     InpUseFibo          = true;     // Use Fibonacci zones
input int      InpFiboLookback     = 30;       // Lookback for swing detection - MENOR
input double   InpFiboZone         = 50.0;     // Tolerance (points) - MUITO RELAXADO

input group "=== REGIME SETTINGS ==="
input int      InpHurst_Window     = 100;      // Hurst Calculation Window
input double   InpHurst_Trending   = 0.55;     // Hurst > this = Trending
input double   InpHurst_Reverting  = 0.45;     // Hurst < this = Reverting
input bool     InpBlockRandomWalk  = false;    // Block Random Walk Regime - DESATIVADO

input group "=== GENIUS LEARNING (FAST) ==="
input bool     InpUseLearning      = true;     // Enable Self-Learning
input int      InpMinTradesLearn   = 5;        // Min trades before Kelly (ERA 10 - mais rápido)
input double   InpLearningRate     = 0.20;     // Learning rate (ERA 0.15 - aprende mais rápido)
input bool     InpPersistStats     = true;     // Save stats between sessions

input group "=== POSITION MANAGEMENT ==="
input bool     InpUseBE_Partial    = true;     // Enable BE + partial + trail
input double   InpBE_TriggerR      = 0.8;      // Move SL to BE at this R
input double   InpPartial_R        = 1.5;      // Take partial at this R
input double   InpPartial_Pct      = 0.5;      // Fraction to close at partial
input double   InpTrail_StartR     = 2.0;      // Start trailing at this R
input double   InpTrail_ATR_Mult   = 1.2;      // ATR(10) multiplier for trailing
input bool     InpUseStructureTrail = true;   // FASE 1.3: Use swing level protection
input double   InpStructureBuffer  = 0.2;     // Structure buffer (ATR mult)
input double   InpMaxExposurePct   = 15.0;     // Max aggregated risk % of equity
input bool     InpUseNewsBlock     = true;     // Block around news file windows
input string   InpNewsFile         = "data/news_block.csv"; // CSV UTC: YYYY-MM-DD HH:MM;window_min

input group "=== MAGIC NUMBER ==="
input ulong    InpMagicNumber      = 202512;   // Magic Number

//+------------------------------------------------------------------+
//| ENUMS (prefixed to avoid collision with module enums)            |
//+------------------------------------------------------------------+
enum ENUM_EA_REGIME { EA_REGIME_TRENDING=0, EA_REGIME_REVERTING=1, EA_REGIME_RANDOM=2, EA_REGIME_UNKNOWN=3 };
enum ENUM_EA_SIGNAL { EA_SIGNAL_NONE=0, EA_SIGNAL_BUY=1, EA_SIGNAL_SELL=-1 };
enum ENUM_CIRCUIT { STATE_NORMAL=0, STATE_CAUTION=1, STATE_BLOCKED=2, STATE_EMERGENCY=3 };
enum ENUM_SETUP { SETUP_NONE=0, SETUP_OB=1, SETUP_SWEEP=2, SETUP_MA_CROSS=3, SETUP_FVG=4, SETUP_FIBO=5, SETUP_COMBO=6 };
enum ENUM_SESSION { SESSION_ASIAN=0, SESSION_LONDON=1, SESSION_OVERLAP=2, SESSION_NY=3, SESSION_DEAD=4 };

//+------------------------------------------------------------------+
//| LEARNING STRUCTS                                                  |
//+------------------------------------------------------------------+
struct SSetupStats
{
   int      trades;
   int      wins;
   double   total_r;
   double   total_loss_r;
   double   win_rate;
   double   expectancy;      // Average R per trade
   double   score;           // Thompson proxy
   double   alpha;           // Bandit posterior alpha (wins)
   double   beta;            // Bandit posterior beta (losses)
   
   void Reset() { trades=0; wins=0; total_r=0; total_loss_r=0; win_rate=0.5; expectancy=0; score=0.5; alpha=1; beta=1; }
   
   void Update(double r_multiple, double learning_rate)
   {
      trades++;
      bool is_win = r_multiple > 0;
      if(is_win) { wins++; total_r += r_multiple; alpha += 1; }
      else { total_loss_r += MathAbs(r_multiple); beta += 1; }
      
      if(trades > 0)
      {
         win_rate = (double)wins / trades;
         expectancy = (total_r - total_loss_r) / trades;
      }

      // Thompson proxy using posterior mean with small noise
      double mean = alpha / MathMax(1.0, alpha + beta);
      double jitter = ((double)MathRand() / 32767.0) * 0.05;
      score = score * (1.0 - learning_rate) + (mean + jitter) * learning_rate;

      // Lightweight decay to cap history influence
      const double DECAY = 0.999;
      total_r *= DECAY;
      total_loss_r *= DECAY;
      alpha = MathMax(1.0, alpha * DECAY);
      beta = MathMax(1.0, beta * DECAY);
   }
};

struct SSessionStats
{
   int      trades;
   int      wins;
   double   total_r;
   double   score;
   double   alpha;     // v3.1: Bayesian posterior for session
   double   beta;
   
   void Reset() { trades=0; wins=0; total_r=0; score=0.5; alpha=1; beta=1; }
   
   void Update(double r_multiple, double learning_rate)
   {
      trades++;
      if(r_multiple > 0) { wins++; alpha += 1; }
      else { beta += 1; }
      total_r += r_multiple;
      
      // v3.1: Thompson-style scoring with decay (consistent with SSetupStats)
      double mean = alpha / MathMax(1.0, alpha + beta);
      double jitter = ((double)MathRand() / 32767.0) * 0.03;
      score = score * (1.0 - learning_rate) + (mean + jitter) * learning_rate;
      
      // v3.1: Decay to adapt to changing conditions
      const double DECAY = 0.998;  // Slower decay for sessions (more stable)
      alpha = MathMax(1.0, alpha * DECAY);
      beta = MathMax(1.0, beta * DECAY);
   }
};

struct SBucketStats
{
   int    trades;
   double alpha;
   double beta;
   double score;
   
   void Reset() { trades=0; alpha=1; beta=1; score=0.5; }
   
   void Update(double r_multiple, double lr)
   {
      trades++;
      bool win = r_multiple > 0;
      if(win) alpha++; else beta++;
      double mean = alpha / MathMax(1.0, alpha + beta);
      double jitter = ((double)MathRand()/32767.0)*0.03;
      score = score*(1-lr) + (mean+jitter)*lr;
      const double DECAY=0.999;
      alpha = MathMax(1.0, alpha*DECAY);
      beta  = MathMax(1.0, beta*DECAY);
   }
};

struct SRegimeStats
{
   int      trades;
   int      wins;
   double   total_r;
   double   score;
   double   alpha;     // v3.1: Bayesian posterior for regime
   double   beta;
   
   void Reset() { trades=0; wins=0; total_r=0; score=0.5; alpha=1; beta=1; }
   
   void Update(double r_multiple, double learning_rate)
   {
      trades++;
      if(r_multiple > 0) { wins++; alpha += 1; }
      else { beta += 1; }
      total_r += r_multiple;
      
      // v3.1: Thompson-style scoring with decay
      double mean = alpha / MathMax(1.0, alpha + beta);
      double jitter = ((double)MathRand() / 32767.0) * 0.03;
      score = score * (1.0 - learning_rate) + (mean + jitter) * learning_rate;
      
      // v3.1: Decay (faster for regimes - market conditions change)
      const double DECAY = 0.995;  // Faster decay for regimes
      alpha = MathMax(1.0, alpha * DECAY);
      beta = MathMax(1.0, beta * DECAY);
   }
};

struct SKellyState
{
   int      total_trades;
   int      wins;
   double   avg_win_r;
   double   avg_loss_r;
   double   kelly_fraction;
   
   void Reset() { total_trades=0; wins=0; avg_win_r=0; avg_loss_r=0; kelly_fraction=0.02; }
   
   void Update(double r_multiple)
   {
      total_trades++;
      if(r_multiple > 0)
      {
         wins++;
         avg_win_r = (avg_win_r * (wins-1) + r_multiple) / wins;
      }
      else
      {
         int losses = total_trades - wins;
         avg_loss_r = (avg_loss_r * (losses-1) + MathAbs(r_multiple)) / losses;
      }
      
      // Calculate Kelly
      if(total_trades >= 10 && avg_loss_r > 0)
      {
         double win_rate = (double)wins / total_trades;
         double loss_rate = 1.0 - win_rate;
         double win_loss_ratio = avg_win_r / avg_loss_r;
         
         // Kelly: f* = (W*R - L) / R
         double kelly = (win_rate * win_loss_ratio - loss_rate) / win_loss_ratio;
         
         // FULL KELLY for aggressive personal account (was 0.5 = half-kelly)
         kelly *= 0.85;  // 85% Kelly - aggressive but controlled
         
         // Clamp [1%, 12%] - AGRESSIVO mas com proteção
         // 12% max previne ruin mesmo em bad streaks
         kelly_fraction = MathMax(0.01, MathMin(0.12, kelly));
      }
   }
};

struct SLearningState
{
   // Per-setup learning
   SSetupStats    setup_ob;
   SSetupStats    setup_sweep;
   SSetupStats    setup_ma;
   SSetupStats    setup_fvg;
   SSetupStats    setup_fibo;
   SSetupStats    setup_combo;  // COMBO: Confluencia de multiplos setups
   
   // Per-session learning
   SSessionStats  session_asian;
   SSessionStats  session_london;
   SSessionStats  session_overlap;
   SSessionStats  session_ny;
   
   // Per-regime learning
   SRegimeStats   regime_trending;
   SRegimeStats   regime_reverting;
   SRegimeStats   regime_random;
   
   // Kelly
   SKellyState    kelly;
   
   // Global
   int            total_trades;
   double         total_pnl;
   
   void Reset()
   {
      setup_ob.Reset(); setup_sweep.Reset(); setup_ma.Reset(); setup_fvg.Reset(); setup_fibo.Reset(); setup_combo.Reset();
      session_asian.Reset(); session_london.Reset(); session_overlap.Reset(); session_ny.Reset();
      regime_trending.Reset(); regime_reverting.Reset(); regime_random.Reset();
      kelly.Reset();
      total_trades = 0;
      total_pnl = 0;
   }
};

struct STradeContext
{
   ENUM_SETUP     setup_type;
   ENUM_SESSION   session;
   ENUM_EA_REGIME    regime;
   double         entry_price;
   double         sl;
   double         tp;
   datetime       entry_time;
   double         risk_amount;
   double         risk_pct;
   double         sl_distance;
   int            bucket15;
   double         entry_spread;
   
   // v3.1 GENIUS: Factor presence at entry (for learning)
   double         mtf_mult_at_entry;      // MTF multiplier when trade opened
   double         regime_mult_at_entry;   // Regime multiplier when trade opened
   double         footprint_score_at_entry; // Footprint score when trade opened
   bool           structure_aligned;      // Was structure aligned at entry
};

struct SAdaptiveState
{
   double         current_risk;
   int            consec_wins;
   int            consec_losses;
   bool           is_tilting;
   ENUM_CIRCUIT   circuit;
   string         reason;
};

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES                                                  |
//+------------------------------------------------------------------+
CTrade         g_trade;
CPositionInfo  g_position;
CAccountInfo   g_account;
CSymbolInfo    g_symbol;

// === MODE-BASED CONFIGURATION (set in OnInit based on InpEAMode) ===
struct SModeConfig
{
   double      sl_atr_mult;        // SL multiplier
   double      tp_rr;              // R:R ratio
   double      min_rr;             // Minimum R:R
   int         max_trades_day;     // Max trades per day
   bool        use_mtf_filter;     // Use MTF alignment filter
   bool        use_structure_filter; // Use BOS/CHoCH filter
   bool        use_regime_filter;  // Use regime filter
   bool        use_session_filter; // Use session quality filter
   double      min_footprint_score; // Min footprint score to trade
   double      vol_rank_min;       // Min volatility rank
   bool        use_partial_tp;     // Use partial take profit
   double      be_trigger_r;       // BE trigger R
   double      partial_r;          // Partial TP R
   int         min_combo_setups;   // Min setups for COMBO
   double      base_risk;          // Base risk override
   double      max_risk;           // Max risk override
};

SModeConfig g_mode;  // Active mode configuration

// === v3.0 GENIUS MODULES ===
CFootprintAnalyzer g_footprint;     // Order Flow analysis with Momentum Edge
CMTFManager        g_mtf;           // Multi-Timeframe H1/M15/M5 alignment
CRegimeDetector    g_regime;        // Hurst + Entropy + VR + Transition
CStructureAnalyzer g_structure;     // FASE 1.3: Swing level detection for trailing

// State
double         g_daily_start_equity = 0;
double         g_peak_equity = 0;
int            g_trades_today = 0;
datetime       g_last_bar_time = 0;
datetime       g_current_day = 0;

// Learning
SLearningState g_learn;
SAdaptiveState g_adapt;
STradeContext  g_current_trade;
SBucketStats   g_bucket_stats[96]; // 96 buckets of 15m

// v3.0: Session Weight Profiles (PHASE 2)
double         g_session_weights[5][6]; // [session][setup_type] weights

// Indicators
int            g_atr_handle = INVALID_HANDLE;
int            g_fast_ma_handle = INVALID_HANDLE;
int            g_slow_ma_handle = INVALID_HANDLE;
int            g_rsi_handle = INVALID_HANDLE;
int            g_htf_ema_handle = INVALID_HANDLE;  // H1 EMA200 for HTF filter (backup)

// Fibonacci
double         g_fibo_382=0, g_fibo_500=0, g_fibo_618=0;
double         g_swing_high=0, g_swing_low=0;

// Price buffers
double         g_closes[], g_highs[], g_lows[], g_opens[], g_atr[];
double         g_spread_buffer[20];
int            g_spread_idx=0;

// Persistence keys
string         g_gv_prefix;

//+------------------------------------------------------------------+
//| APPLY MODE SETTINGS                                               |
//| Configura todos os parametros baseado no modo selecionado         |
//+------------------------------------------------------------------+
void ApplyModeSettings()
{
   switch(InpEAMode)
   {
      case MODE_CONSERVATIVE:
         // ELITE MODE - Só trades A+ de alta probabilidade
         g_mode.sl_atr_mult = 1.8;      // SL com espaço para respirar
         g_mode.tp_rr = 4.0;            // Target 4:1 (busca runners)
         g_mode.min_rr = 2.5;           // Só aceita R:R excelente
         g_mode.max_trades_day = 5;     // Max 5 trades ELITE por dia
         g_mode.use_mtf_filter = true;  // H1 deve confirmar
         g_mode.use_structure_filter = true;  // BOS/CHoCH obrigatório
         g_mode.use_regime_filter = true;     // Só em regime favorável
         g_mode.use_session_filter = true;    // Só London/Overlap
         g_mode.min_footprint_score = 20;     // Footprint FORTE
         g_mode.vol_rank_min = 0.35;    // Volatilidade acima da média
         g_mode.use_partial_tp = true;  // Partial TP em 2R
         g_mode.be_trigger_r = 1.2;     // BE após 1.2R
         g_mode.partial_r = 2.0;        // Partial em 2R
         g_mode.min_combo_setups = 6;   // Score 6+ para entrar (MUITO seletivo)
         g_mode.base_risk = 2.0;        // Risk conservador
         g_mode.max_risk = 4.0;         // Max 4% mesmo em streak
         Print("MODE: CONSERVATIVE ELITE - Only A+ setups, 4:1 R:R");
         break;
         
      case MODE_AGGRESSIVE:
         // Balanceado - bom volume com filtros
         g_mode.sl_atr_mult = 1.2;
         g_mode.tp_rr = 2.5;
         g_mode.min_rr = 1.5;
         g_mode.max_trades_day = 30;
         g_mode.use_mtf_filter = true;
         g_mode.use_structure_filter = true;
         g_mode.use_regime_filter = true;
         g_mode.use_session_filter = false;  // Trade all sessions
         g_mode.min_footprint_score = 10;
         g_mode.vol_rank_min = 0.2;
         g_mode.use_partial_tp = true;
         g_mode.be_trigger_r = 0.8;
         g_mode.partial_r = 1.5;
         g_mode.min_combo_setups = 5;  // Score 5+ para entrar
         g_mode.base_risk = 3.0;
         g_mode.max_risk = 10.0;
         Print("MODE: AGGRESSIVE - Score 5+, all sessions");
         break;
         
      case MODE_PURE_SCALPER:
         // MUITOS trades, TP rapido, filtros minimos
         g_mode.sl_atr_mult = 0.8;      // SL tight
         g_mode.tp_rr = 1.5;            // TP rapido
         g_mode.min_rr = 1.0;           // Aceita 1:1
         g_mode.max_trades_day = 100;   // Muitos trades
         g_mode.use_mtf_filter = true;  // Apenas H1 direction
         g_mode.use_structure_filter = false; // SEM structure filter
         g_mode.use_regime_filter = false;    // SEM regime filter
         g_mode.use_session_filter = false;   // SEM session filter
         g_mode.min_footprint_score = -999;   // Qualquer footprint
         g_mode.vol_rank_min = 0.1;     // Low vol ok
         g_mode.use_partial_tp = false; // Full TP (rapido)
         g_mode.be_trigger_r = 0.5;     // BE cedo
         g_mode.partial_r = 1.0;        // N/A
         g_mode.min_combo_setups = 4;   // Score 4+ para entrar
         g_mode.base_risk = 2.0;        // Risk controlado
         g_mode.max_risk = 8.0;
         Print("MODE: PURE SCALPER - Score 4+, quick TP");
         break;
         
      case MODE_TURBO:
         // ULTRA agressivo - minimos filtros, maximo trades
         g_mode.sl_atr_mult = 0.6;      // SL muito tight
         g_mode.tp_rr = 1.2;            // TP muito rapido
         g_mode.min_rr = 0.8;           // Aceita R:R baixo
         g_mode.max_trades_day = 200;   // Maximo trades
         g_mode.use_mtf_filter = false; // SEM MTF filter
         g_mode.use_structure_filter = false;
         g_mode.use_regime_filter = false;
         g_mode.use_session_filter = false;
         g_mode.min_footprint_score = -999;
         g_mode.vol_rank_min = 0.05;
         g_mode.use_partial_tp = false;
         g_mode.be_trigger_r = 0.3;
         g_mode.partial_r = 0.8;
         g_mode.min_combo_setups = 3;   // Score 3+ (mais permissivo)
         g_mode.base_risk = 1.5;        // Risk menor por trade
         g_mode.max_risk = 5.0;
         Print("MODE: TURBO - Score 3+, max aggression");
         break;
   }
   
   Print("Config: SL=", g_mode.sl_atr_mult, "xATR | TP=", g_mode.tp_rr, ":1 | MaxTrades=", g_mode.max_trades_day);
   Print("Filters: MTF=", g_mode.use_mtf_filter, " | Structure=", g_mode.use_structure_filter, 
         " | Regime=", g_mode.use_regime_filter, " | Session=", g_mode.use_session_filter);
}

//+------------------------------------------------------------------+
//| Expert initialization                                             |
//+------------------------------------------------------------------+
int OnInit()
{
   // Apply mode settings FIRST
   ApplyModeSettings();
   
   if(!g_symbol.Name(_Symbol)) { Print("ERROR: Symbol"); return INIT_FAILED; }
   g_symbol.Refresh();
   MathSrand((uint)TimeLocal());
   
   g_trade.SetExpertMagicNumber(InpMagicNumber);
   g_trade.SetDeviationInPoints(50);
   g_trade.SetTypeFilling(ORDER_FILLING_IOC);
   
   // Indicators
   g_atr_handle = iATR(_Symbol, PERIOD_CURRENT, InpATR_Period);
   g_fast_ma_handle = iMA(_Symbol, PERIOD_CURRENT, InpFastMA, 0, MODE_EMA, PRICE_CLOSE);
   g_slow_ma_handle = iMA(_Symbol, PERIOD_CURRENT, InpSlowMA, 0, MODE_EMA, PRICE_CLOSE);
   g_rsi_handle = iRSI(_Symbol, PERIOD_CURRENT, InpRSI_Period, PRICE_CLOSE);
   g_htf_ema_handle = iMA(_Symbol, PERIOD_H1, 200, 0, MODE_EMA, PRICE_CLOSE);  // HTF Filter
   
   if(g_atr_handle==INVALID_HANDLE || g_fast_ma_handle==INVALID_HANDLE || 
      g_slow_ma_handle==INVALID_HANDLE || g_rsi_handle==INVALID_HANDLE ||
      g_htf_ema_handle==INVALID_HANDLE)
   {
      Print("ERROR: Indicators failed");
      return INIT_FAILED;
   }
   
   // Init state
   g_gv_prefix = "AGG_" + _Symbol + "_";
   g_learn.Reset();
   for(int i=0;i<96;i++) g_bucket_stats[i].Reset();
   g_adapt.current_risk = InpBaseRisk;
   g_adapt.circuit = STATE_NORMAL;
   g_adapt.consec_wins = 0;
   g_adapt.consec_losses = 0;
   
   // === v3.0 GENIUS: Initialize Advanced Modules ===
   
   // 1. Footprint Analyzer (Order Flow with Momentum Edge)
   if(!g_footprint.Init(_Symbol, PERIOD_M5, 0.50, 3.0))
   {
      Print("WARNING: Footprint analyzer init failed - basic scoring only");
   }
   else
   {
      g_footprint.EnableDynamicCluster(true, 0.1, 0.25, 2.0);  // ATR-based cluster
      g_footprint.EnableSessionReset(true);  // Reset delta at session changes
      Print("Footprint v3.4 Momentum Edge: ACTIVE");
   }
   
   // 2. MTF Manager (H1/M15/M5 alignment)
   if(!g_mtf.Init(_Symbol))
   {
      Print("WARNING: MTF Manager init failed - using basic HTF filter");
   }
   else
   {
      g_mtf.SetGMTOffset(InpGMT_Offset);
      g_mtf.SetMinTrendStrength(30.0);
      g_mtf.SetMinConfluence(50.0);  // Lower threshold for aggressive mode
      Print("MTF Manager v3.2 GENIUS: ACTIVE (H1/M15/M5)");
   }
   
   // 3. Regime Detector (Hurst + Entropy + VR + Transition)
   g_regime.SetHurstWindow(InpHurst_Window);
   g_regime.SetThresholds(InpHurst_Trending, InpHurst_Reverting, 1.5);
   g_regime.SetTransitionThreshold(0.6);  // Alert when transition prob > 60%
   g_regime.SetCacheSeconds(30);  // Cache for 30 seconds
   Print("Regime Detector v4.0 GENIUS: ACTIVE (Multi-scale Hurst + Transition)");
   
   // 4. Structure Analyzer (FASE 1.3: Swing levels for trailing)
   g_structure.SetSwingStrength(3);        // 3 bars on each side
   g_structure.SetLookback(50);            // 50 bars lookback for swings
   g_structure.SetEqualTolerance(5.0);     // 5 pips for equal highs/lows
   g_structure.SetBreakBuffer(2.0);        // 2 pips buffer for breaks
   Print("Structure Analyzer FASE 1.3: ACTIVE (Swing-based trailing)");
   
   // 5. Initialize Session Weight Profiles (PHASE 2)
   InitSessionWeightProfiles();
   
   // Load persisted learning
   if(InpPersistStats)
      LoadLearningState();
   
   ResetDailyState();
   
   Print("==============================================");
   Print("  EA_AGGRESSIVE_SCALPER v3.1 GENIUS");
   Print("  FASE 1 & 2 COMPLETE - All Modules Active");
   Print("==============================================");
   Print("Base Risk: ", InpBaseRisk, "% | Max: ", InpMaxRisk, "% | Kelly: 85%");
   Print("FASE 1.1: Footprint Momentum (Delta Accel + POC Div)");
   Print("FASE 1.2: MTF Alignment (H1/M15/M5 + Session Quality)");
   Print("FASE 1.3: Structure Trail (", InpUseStructureTrail ? "ENABLED" : "OFF", ")");
   Print("Regime: Multi-scale Hurst + Transition Detection");
   Print("Learning: ", InpUseLearning ? "ENABLED" : "OFF");
   Print("Loaded trades: ", g_learn.total_trades);
   Print("==============================================");
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Release indicator handles
   if(g_atr_handle != INVALID_HANDLE) IndicatorRelease(g_atr_handle);
   if(g_fast_ma_handle != INVALID_HANDLE) IndicatorRelease(g_fast_ma_handle);
   if(g_slow_ma_handle != INVALID_HANDLE) IndicatorRelease(g_slow_ma_handle);
   if(g_rsi_handle != INVALID_HANDLE) IndicatorRelease(g_rsi_handle);
   if(g_htf_ema_handle != INVALID_HANDLE) IndicatorRelease(g_htf_ema_handle);
   
   // v3.0: Release GENIUS modules
   g_footprint.Deinit();
   g_mtf.Deinit();
   
   // Save learning state
   if(InpPersistStats)
      SaveLearningState();
   
   PrintLearningReport();
}

//+------------------------------------------------------------------+
//| v3.0: MTF ALIGNMENT FILTER (GENIUS - Replaces basic HTF filter)  |
//| Uses CMTFManager for H1/M15/M5 confluence                        |
//+------------------------------------------------------------------+
bool PassesMTFFilter(ENUM_EA_SIGNAL signal, double &mtf_multiplier)
{
   mtf_multiplier = 1.0;
   if(signal == EA_SIGNAL_NONE) return false;
   
   // Update MTF analysis
   g_mtf.Update();
   SMTFConfluence conf = g_mtf.GetConfluence();
   
   // 1. Session Quality Check (v3.2 GENIUS)
   if(conf.session_quality < 0.35)
   {
      Print("MTF BLOCKED: Session quality too low (", DoubleToString(conf.session_quality*100,0), "%)");
      return false;
   }
   
   // 2. HTF Trend Alignment (CRITICAL - nunca operar contra H1)
   if(signal == EA_SIGNAL_BUY && conf.htf_trend == MTF_TREND_BEARISH)
   {
      Print("MTF BLOCKED BUY: H1 trend BEARISH");
      return false;
   }
   if(signal == EA_SIGNAL_SELL && conf.htf_trend == MTF_TREND_BULLISH)
   {
      Print("MTF BLOCKED SELL: H1 trend BULLISH");
      return false;
   }
   
   // 3. Momentum Divergence Warning (M15 vs H1)
   if(conf.has_momentum_divergence)
   {
      Print("MTF WARNING: M15/H1 momentum divergence - reducing size");
      mtf_multiplier *= 0.7;  // Reduce size but don't block
   }
   
   // 4. Calculate position size multiplier based on alignment
   mtf_multiplier *= conf.position_size_mult;
   
   // 5. Session quality bonus/penalty
   if(conf.session_quality >= 0.9)      // Overlap session
      mtf_multiplier *= 1.15;
   else if(conf.session_quality < 0.5)  // Asian/Dead
      mtf_multiplier *= 0.6;
   
   // Log alignment
   Print("MTF Alignment: ", EnumToString(conf.alignment), 
         " | Confidence: ", DoubleToString(conf.confidence, 0), "%",
         " | Session: ", g_mtf.SessionTypeToString(conf.session_type),
         " | Mult: ", DoubleToString(mtf_multiplier, 2));
   
   return true;
}

//+------------------------------------------------------------------+
//| v3.2 GENIUS: STRUCTURE FILTER (BOS/CHoCH)                        |
//| Verifica se a estrutura confirma o sinal ANTES de entrar         |
//| BOS = Continuation (trade with trend)                            |
//| CHoCH = Reversal (trade the reversal)                            |
//+------------------------------------------------------------------+
bool PassesStructureFilter(ENUM_EA_SIGNAL signal, double &structure_mult)
{
   structure_mult = 1.0;
   if(signal == EA_SIGNAL_NONE) return false;
   
   // Update structure analysis
   g_structure.AnalyzeStructure(_Symbol, PERIOD_CURRENT);
   SStructureState state = g_structure.GetState();
   SStructureBreak last_break = g_structure.GetLastBreak();
   
   // 1. Check current bias alignment
   ENUM_MARKET_BIAS bias = state.bias;
   
   // BUY deve ter bias BULLISH ou CHoCH bullish recente
   if(signal == EA_SIGNAL_BUY)
   {
      if(bias == BIAS_BULLISH)
      {
         structure_mult = 1.1;  // Aligned with structure
         if(g_structure.HasRecentBOS())
         {
            structure_mult = 1.25;  // BOS confirmation = STRONG
            Print("STRUCTURE BOOST: BOS bullish detected (+25%)");
         }
      }
      else if(bias == BIAS_BEARISH)
      {
         // Contra-trend - precisa de CHoCH para confirmar reversao
         if(g_structure.HasRecentCHoCH())
         {
            structure_mult = 1.15;  // CHoCH = reversal confirmed
            Print("STRUCTURE: CHoCH bullish - reversal confirmed");
         }
         else
         {
            Print("STRUCTURE BLOCKED BUY: Bearish bias, no CHoCH");
            return false;  // Block contra-trend without CHoCH
         }
      }
      // RANGING/TRANSITION = allow but no boost
   }
   // SELL deve ter bias BEARISH ou CHoCH bearish recente
   else if(signal == EA_SIGNAL_SELL)
   {
      if(bias == BIAS_BEARISH)
      {
         structure_mult = 1.1;
         if(g_structure.HasRecentBOS())
         {
            structure_mult = 1.25;
            Print("STRUCTURE BOOST: BOS bearish detected (+25%)");
         }
      }
      else if(bias == BIAS_BULLISH)
      {
         if(g_structure.HasRecentCHoCH())
         {
            structure_mult = 1.15;
            Print("STRUCTURE: CHoCH bearish - reversal confirmed");
         }
         else
         {
            Print("STRUCTURE BLOCKED SELL: Bullish bias, no CHoCH");
            return false;
         }
      }
   }
   
   // 2. Structure quality check
   if(state.structure_quality < 30)
   {
      structure_mult *= 0.7;  // Low quality structure = reduce size
      Print("STRUCTURE WARNING: Low quality (", DoubleToString(state.structure_quality,0), "%)");
   }
   else if(state.structure_quality > 70)
   {
      structure_mult *= 1.1;  // High quality = boost
   }
   
   // 3. Premium/Discount zone check from structure
   if(signal == EA_SIGNAL_BUY && state.in_discount)
      structure_mult *= 1.1;  // Buying in discount zone = good
   if(signal == EA_SIGNAL_SELL && state.in_premium)
      structure_mult *= 1.1;  // Selling in premium zone = good
   
   Print("STRUCTURE: Bias=", g_structure.BiasToString(bias),
         " | Quality=", DoubleToString(state.structure_quality,0), "%",
         " | Mult=", DoubleToString(structure_mult,2));
   
   return true;
}

//+------------------------------------------------------------------+
//| v3.0: FOOTPRINT MOMENTUM SCORING (GENIUS)                        |
//| Adds Delta Acceleration + POC Divergence to confluence           |
//+------------------------------------------------------------------+
int ScoreFootprintMomentum(ENUM_EA_SIGNAL signal)
{
   int score = 0;
   
   // Process current bar's footprint
   g_footprint.ProcessBarTicks(0);
   SFootprintSignal fp = g_footprint.GetSignal();
   
   // 1. Stacked Imbalances (high weight - institutional activity)
   if(signal == EA_SIGNAL_BUY && fp.hasStackedBuyImbalance)
      score += 15;
   if(signal == EA_SIGNAL_SELL && fp.hasStackedSellImbalance)
      score += 15;
   
   // 2. Absorption Detection (medium-high weight - reversal signal)
   if(signal == EA_SIGNAL_BUY && fp.hasBuyAbsorption)
      score += 12;
   if(signal == EA_SIGNAL_SELL && fp.hasSellAbsorption)
      score += 12;
   
   // 3. v3.4 MOMENTUM EDGE: Delta Acceleration (HIGH WEIGHT - momentum before price!)
   if(signal == EA_SIGNAL_BUY && fp.hasBullishDeltaAcceleration)
   {
      score += 18;  // Delta accelerating up = strong momentum building
      Print("FOOTPRINT: Bullish Delta Acceleration detected! (+18)");
   }
   if(signal == EA_SIGNAL_SELL && fp.hasBearishDeltaAcceleration)
   {
      score += 18;  // Delta accelerating down = strong momentum building
      Print("FOOTPRINT: Bearish Delta Acceleration detected! (+18)");
   }
   
   // 4. v3.4 MOMENTUM EDGE: POC Divergence (HIGH WEIGHT - institutional repositioning)
   if(signal == EA_SIGNAL_BUY && fp.hasBullishPOCDivergence)
   {
      score += 16;  // POC rising while price falling = accumulation
      Print("FOOTPRINT: Bullish POC Divergence detected! (+16)");
   }
   if(signal == EA_SIGNAL_SELL && fp.hasBearishPOCDivergence)
   {
      score += 16;  // POC falling while price rising = distribution
      Print("FOOTPRINT: Bearish POC Divergence detected! (+16)");
   }
   
   // 5. Unfinished Auction (medium weight - continuation signal)
   if(signal == EA_SIGNAL_BUY && fp.hasUnfinishedAuctionUp)
      score += 10;
   if(signal == EA_SIGNAL_SELL && fp.hasUnfinishedAuctionDown)
      score += 10;
   
   // 6. Delta Divergence (medium weight - reversal warning)
   if(signal == EA_SIGNAL_BUY && fp.hasBullishDeltaDivergence)
      score += 12;
   if(signal == EA_SIGNAL_SELL && fp.hasBearishDeltaDivergence)
      score += 12;
   
   // 7. Delta Percent confirmation (low weight)
   if(signal == EA_SIGNAL_BUY && fp.deltaPercent > 25)
      score += 5;
   if(signal == EA_SIGNAL_SELL && fp.deltaPercent < -25)
      score += 5;
   
   // 8. Penalty for opposing signals
   if(signal == EA_SIGNAL_BUY && (fp.hasStackedSellImbalance || fp.hasBearishDeltaAcceleration))
      score -= 10;
   if(signal == EA_SIGNAL_SELL && (fp.hasStackedBuyImbalance || fp.hasBullishDeltaAcceleration))
      score -= 10;
   
   return score;
}

//+------------------------------------------------------------------+
//| v3.0: REGIME TRANSITION CHECK (GENIUS v4.0)                      |
//| Warns when regime is changing - high transition probability      |
//+------------------------------------------------------------------+
bool IsRegimeStable(double &regime_mult)
{
   regime_mult = 1.0;
   
   SRegimeAnalysis ra = g_regime.AnalyzeRegime(_Symbol, 0);
   if(!ra.is_valid) return true;  // Allow if can't calculate
   
   // 1. Random Walk = NO TRADE
   if(ra.regime == REGIME_RANDOM_WALK)
   {
      Print("REGIME BLOCKED: Random Walk detected (H=", DoubleToString(ra.hurst_exponent,2), ")");
      return false;
   }
   
   // 2. Transitioning = CAUTION (reduce size)
   if(ra.regime == REGIME_TRANSITIONING || ra.transition_probability > 0.5)
   {
      Print("REGIME WARNING: Transition probability ", DoubleToString(ra.transition_probability*100,0), "%");
      regime_mult = 0.5;  // Half size during transitions
   }
   
   // 3. Multi-scale agreement bonus
   if(ra.multiscale_agreement > 80)
   {
      regime_mult *= 1.1;  // +10% when all scales agree
   }
   else if(ra.multiscale_agreement < 50)
   {
      regime_mult *= 0.8;  // -20% when scales disagree
   }
   
   // 4. Confidence adjustment
   if(ra.confidence > 80)
      regime_mult *= 1.05;
   else if(ra.confidence < 50)
      regime_mult *= 0.85;
   
   Print("REGIME: ", g_regime.RegimeToString(ra.regime),
         " | H=", DoubleToString(ra.hurst_exponent,2),
         " | S=", DoubleToString(ra.shannon_entropy,2),
         " | Trans=", DoubleToString(ra.transition_probability*100,0), "%",
         " | Mult=", DoubleToString(regime_mult,2));
   
   return true;
}

//+------------------------------------------------------------------+
//| v3.0: LEGACY HTF FILTER (Fallback if MTF fails)                  |
//+------------------------------------------------------------------+
bool PassesHTFFilter(ENUM_EA_SIGNAL signal)
{
   if(signal == EA_SIGNAL_NONE) return false;
   if(g_htf_ema_handle == INVALID_HANDLE) return true;
   
   double ema200[];
   ArraySetAsSeries(ema200, true);
   if(CopyBuffer(g_htf_ema_handle, 0, 0, 2, ema200) < 2) return true;
   
   double h1_close[];
   ArraySetAsSeries(h1_close, true);
   if(CopyClose(_Symbol, PERIOD_H1, 0, 2, h1_close) < 2) return true;
   
   bool h1_bullish = h1_close[0] > ema200[0];
   bool h1_bearish = h1_close[0] < ema200[0];
   
   if(signal == EA_SIGNAL_BUY && h1_bearish) return false;
   if(signal == EA_SIGNAL_SELL && h1_bullish) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   CheckNewDay();
   UpdateCircuitBreaker();
   
   if(g_adapt.circuit == STATE_BLOCKED || g_adapt.circuit == STATE_EMERGENCY)
   {
      Comment("CIRCUIT: ", g_adapt.reason);
      return;
   }
   
   ManageOpenPositions();
   
   if(!IsNewBar()) return;
   if(!LoadPriceData()) return;
   
   if(InpUseFibo) CalcFibonacci();
   
   if(HasOpenPosition()) return;
   if(g_trades_today >= g_mode.max_trades_day) return;  // USE MODE CONFIG
   
   // Get context
   ENUM_SESSION session = GetCurrentSession();
   int bucket = GetCurrentBucket();
   ENUM_EA_REGIME regime = DetectRegime();
   
   // v3.1 FIX: Block Dead Session entirely (21:00-00:00 GMT)
   if(session == SESSION_DEAD)
   {
      Comment("Dead session - no trading");
      return;
   }
   
   // === INTELLIGENT FILTERING (MODE-BASED) ===
   // PURE_SCALPER and TURBO skip most learning filters
   if(g_mode.use_session_filter && InpUseLearning && g_learn.total_trades >= InpMinTradesLearn)
   {
      // Skip sessions with bad score
      double session_score = GetSessionScore(session);
      if(session_score < 0.35)
      {
         Comment("Learning: Skipping ", SessionToString(session), " (score: ", DoubleToString(session_score,2), ")");
         return;
      }
   }
   
   if(g_mode.use_regime_filter && InpUseLearning && g_learn.total_trades >= InpMinTradesLearn)
   {
      // Skip regime with bad score
      double regime_score = GetRegimeScore(regime);
      if(regime_score < 0.35)
      {
         Comment("Learning: Skipping ", RegimeToString(regime), " (score: ", DoubleToString(regime_score,2), ")");
         return;
      }
   }
   else
   {
      // Fallback to input filters before learning kicks in
      if(InpLondonOnly && session != SESSION_LONDON && session != SESSION_OVERLAP)
         return;
      if(InpBlockRandomWalk && regime == EA_REGIME_RANDOM)
         return;
   }
   
   // News block (only in conservative mode)
   if(InpEAMode == MODE_CONSERVATIVE && InpUseNewsBlock && IsNewsBlocked()) 
   { 
      Comment("News block window"); 
      return; 
   }
   
   // Spread check (relaxed for scalper modes)
   int max_spread = (InpEAMode == MODE_TURBO) ? 100 : (InpEAMode == MODE_PURE_SCALPER) ? 80 : InpMaxSpread;
   if(GetSpreadPoints() > max_spread) return;
   
   // Exposure cap (higher for aggressive modes)
   double max_exposure = (InpEAMode == MODE_TURBO) ? 30.0 : (InpEAMode == MODE_PURE_SCALPER) ? 25.0 : InpMaxExposurePct;
   if(CurrentExposurePct() >= max_exposure) return;
   
   // Generate signal with best setup
   ENUM_EA_SIGNAL signal = EA_SIGNAL_NONE;
   ENUM_SETUP best_setup = SETUP_NONE;
   
   signal = GenerateSmartSignal(regime, best_setup);
   
   if(signal == EA_SIGNAL_NONE) return;
   
   // === v3.0 GENIUS FILTERS (MODE-BASED) ===
   
   // 1. MTF Alignment (H1/M15/M5) - MODE CONTROLLED
   double mtf_mult = 1.0;
   if(g_mode.use_mtf_filter)
   {
      if(!PassesMTFFilter(signal, mtf_mult))
      {
         // Fallback to basic HTF filter if MTF fails
         if(!PassesHTFFilter(signal)) return;
      }
   }
   
   // 2. Regime Stability Check - MODE CONTROLLED
   double regime_mult = 1.0;
   if(g_mode.use_regime_filter)
   {
      if(!IsRegimeStable(regime_mult)) return;
   }
   
   // 3. Footprint Momentum Scoring (v3.4) - MODE CONTROLLED
   int fp_score = ScoreFootprintMomentum(signal);
   double fp_mult = 1.0;
   
   // PURE_SCALPER/TURBO: Skip footprint filtering
   if(fp_score >= g_mode.min_footprint_score)
   {
      if(fp_score >= 30)
      {
         fp_mult = 1.2;  // Strong footprint confirmation
         Print("FOOTPRINT BONUS: Score ", fp_score, " (+20% size)");
      }
      else if(fp_score >= 15)
      {
         fp_mult = 1.0;  // Normal footprint
      }
   }
   else if(g_mode.min_footprint_score > -100)  // Only check if mode requires
   {
      if(fp_score < -5)
      {
         Print("FOOTPRINT BLOCKED: Strong opposing signals (score ", fp_score, ")");
         return;
      }
      else if(fp_score < 0)
      {
         Print("FOOTPRINT WARNING: Opposing signals (score ", fp_score, ")");
         fp_mult = 0.7;  // Reduce size
      }
   }

   // Volatility rank filter - SKIP for scalper modes (already checked in signal)
   if(InpEAMode == MODE_CONSERVATIVE || InpEAMode == MODE_AGGRESSIVE)
   {
      if(GetVolRank() < g_mode.vol_rank_min) return;
   }

   // Premium/Discount filter - SKIP for TURBO (already in signal generation)
   if(InpEAMode == MODE_CONSERVATIVE)
   {
      if(!InPremiumDiscountFilter(signal)) return;
   }
   
   // Execute with context
   g_current_trade.setup_type = best_setup;
   g_current_trade.session = session;
   g_current_trade.regime = regime;
   g_current_trade.entry_time = TimeCurrent();
   g_current_trade.bucket15 = bucket;
   g_current_trade.entry_spread = GetSpreadPoints();
   
   // v3.2 GENIUS: Structure Filter (BOS/CHoCH confirmation) - MODE CONTROLLED
   double structure_mult = 1.0;
   if(g_mode.use_structure_filter)
   {
      if(!PassesStructureFilter(signal, structure_mult))
      {
         // Fallback: se nao tem CHoCH mas tem footprint FORTE, permite
         if(fp_score >= 25)
         {
            Print("STRUCTURE OVERRIDE: Strong footprint (", fp_score, ") allows trade");
            structure_mult = 0.7;  // Reduced size
         }
         else
         {
            return;  // Block trade
         }
      }
   }
   
   // v3.1: Store GENIUS factor values for learning
   g_current_trade.mtf_mult_at_entry = mtf_mult;
   g_current_trade.regime_mult_at_entry = regime_mult;
   g_current_trade.footprint_score_at_entry = fp_score;
   g_current_trade.structure_aligned = (structure_mult >= 1.0);
   
   // v3.2: Combined multiplier with Structure
   double combined_mult = mtf_mult * regime_mult * fp_mult * structure_mult;
   
   // Cap combined multiplier to prevent over-leverage
   combined_mult = MathMin(combined_mult, 1.8);  // Max 80% boost
   
   ExecuteTradeWithMultiplier(signal, combined_mult);
}

//+------------------------------------------------------------------+
//| GENIUS SIGNAL GENERATION v5.0                                     |
//| Conceitos que NINGUEM usa: Velocity, Delta Divergence, Session   |
//+------------------------------------------------------------------+
ENUM_EA_SIGNAL GenerateSmartSignal(ENUM_EA_REGIME regime, ENUM_SETUP &best_setup)
{
   ENUM_EA_SIGNAL signal = EA_SIGNAL_NONE;
   best_setup = SETUP_NONE;
   
   if(ArraySize(g_closes) < 50) return EA_SIGNAL_NONE;
   
   double atr = g_atr[0];
   if(atr <= 0) return EA_SIGNAL_NONE;
   
   // === GENIUS #1: VELOCITY OF PRICE ===
   // Movimento rapido = institucional, lento = noise
   double velocity = 0;
   double move_3bars = MathAbs(g_closes[0] - g_closes[3]);
   double avg_move = 0;
   for(int i = 0; i < 20; i++) avg_move += MathAbs(g_closes[i] - g_closes[i+1]);
   avg_move /= 20;
   velocity = (avg_move > 0) ? move_3bars / (avg_move * 3) : 0;  // >1 = fast, <1 = slow
   bool is_institutional_move = velocity > 1.5;  // 50% mais rapido que normal
   
   // === GENIUS #2: DELTA DIVERGENCE (Santo Graal) ===
   // Preco sobe + Delta cai = fraqueza oculta
   // Preco cai + Delta sobe = forca oculta
   g_footprint.ProcessBarTicks(0);
   SFootprintSignal fp = g_footprint.GetSignal();
   double price_change = g_closes[0] - g_closes[1];
   bool delta_divergence_bull = (price_change < -atr*0.3) && (fp.deltaPercent > 5);   // Preco caiu mas delta positivo = FORCA
   bool delta_divergence_bear = (price_change > atr*0.3) && (fp.deltaPercent < -5);   // Preco subiu mas delta negativo = FRAQUEZA
   
   // === GENIUS #3: VOLATILITY COMPRESSION ===
   // ATR diminuindo = explosao iminente
   double atr_now = g_atr[0];
   double atr_5 = g_atr[5];
   double atr_10 = g_atr[10];
   bool vol_compressing = (atr_now < atr_5 * 0.85) && (atr_5 < atr_10 * 0.9);  // ATR caindo
   bool vol_exploding = atr_now > atr_5 * 1.3;  // ATR expandindo rapido
   
   // === GENIUS #4: SESSION CONTEXT ===
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   int gmt_hour = dt.hour;  // Assumindo servidor GMT
   
   // London Fix times (10:30 e 15:00 GMT)
   bool near_am_fix = (gmt_hour == 10 && dt.min >= 15) || (gmt_hour == 10 && dt.min <= 45);
   bool near_pm_fix = (gmt_hour == 14 && dt.min >= 45) || (gmt_hour == 15 && dt.min <= 15);
   bool is_fix_time = near_am_fix || near_pm_fix;
   
   // Session ranges
   bool is_asia = (gmt_hour >= 0 && gmt_hour < 7);
   bool is_london = (gmt_hour >= 7 && gmt_hour < 13);
   bool is_ny_overlap = (gmt_hour >= 13 && gmt_hour < 17);
   
   // === GENIUS #5: LIQUIDITY SWEEP DETECTION ===
   // Detectar se houve sweep recente (ultimas 5 barras)
   double high5 = g_highs[1], low5 = g_lows[1];
   for(int i = 2; i <= 5; i++)
   {
      if(g_highs[i] > high5) high5 = g_highs[i];
      if(g_lows[i] < low5) low5 = g_lows[i];
   }
   bool swept_highs = g_highs[0] > high5 && g_closes[0] < high5;  // Swept e voltou
   bool swept_lows = g_lows[0] < low5 && g_closes[0] > low5;      // Swept e voltou
   
   // === STANDARD FACTORS ===
   double fast[], slow[];
   ArraySetAsSeries(fast, true);
   ArraySetAsSeries(slow, true);
   if(CopyBuffer(g_fast_ma_handle, 0, 0, 5, fast) < 5) return EA_SIGNAL_NONE;
   if(CopyBuffer(g_slow_ma_handle, 0, 0, 5, slow) < 5) return EA_SIGNAL_NONE;
   
   bool ema_bullish = fast[0] > slow[0];
   bool ema_bearish = fast[0] < slow[0];
   bool ema_expanding = MathAbs(fast[0] - slow[0]) > MathAbs(fast[1] - slow[1]);
   
   double body = g_closes[0] - g_opens[0];
   double candle_range = g_highs[0] - g_lows[0];
   bool bullish_candle = body > 0 && body > candle_range * 0.4;
   bool bearish_candle = body < 0 && MathAbs(body) > candle_range * 0.4;
   
   double high20 = g_highs[0], low20 = g_lows[0];
   for(int i = 1; i < 20; i++)
   {
      if(g_highs[i] > high20) high20 = g_highs[i];
      if(g_lows[i] < low20) low20 = g_lows[i];
   }
   double mid20 = (high20 + low20) / 2.0;
   bool in_discount = g_closes[0] < mid20;
   bool in_premium = g_closes[0] > mid20;
   
   bool fp_bullish = fp.deltaPercent > 10 || fp.hasBullishDeltaAcceleration || fp.hasStackedBuyImbalance;
   bool fp_bearish = fp.deltaPercent < -10 || fp.hasBearishDeltaAcceleration || fp.hasStackedSellImbalance;
   
   // === GENIUS SCORING SYSTEM ===
   int buy_score = 0;
   int sell_score = 0;
   
   // GENIUS FACTORS (high value)
   // Delta Divergence (3 points - MUITO IMPORTANTE)
   if(delta_divergence_bull) buy_score += 3;
   if(delta_divergence_bear) sell_score += 3;
   
   // Liquidity Sweep + Reversal (3 points)
   if(swept_lows && bullish_candle) buy_score += 3;
   if(swept_highs && bearish_candle) sell_score += 3;
   
   // Institutional Velocity (2 points)
   if(is_institutional_move && bullish_candle) buy_score += 2;
   if(is_institutional_move && bearish_candle) sell_score += 2;
   
   // Vol Compression Breakout (2 points)
   if(vol_compressing && vol_exploding && bullish_candle) buy_score += 2;
   if(vol_compressing && vol_exploding && bearish_candle) sell_score += 2;
   
   // Session Bonus (1 point para London/NY, 0 para Asia)
   if(is_london || is_ny_overlap)
   {
      if(ema_bullish) buy_score += 1;
      if(ema_bearish) sell_score += 1;
   }
   
   // STANDARD FACTORS
   if(ema_bullish) buy_score += 2;
   if(ema_bearish) sell_score += 2;
   if(ema_expanding && ema_bullish) buy_score += 1;
   if(ema_expanding && ema_bearish) sell_score += 1;
   if(bullish_candle) buy_score += 2;
   if(bearish_candle) sell_score += 2;
   if(in_discount) buy_score += 1;
   if(in_premium) sell_score += 1;
   if(fp_bullish) buy_score += 2;
   if(fp_bearish) sell_score += 2;
   
   // === DECISION (min score varies by mode) ===
   int min_score = (int)g_mode.min_combo_setups;
   
   if(buy_score >= min_score && buy_score > sell_score)
   {
      signal = EA_SIGNAL_BUY;
      best_setup = SETUP_COMBO;
      Print("=== GENIUS BUY Signal ===");
      Print("Score: ", buy_score, "/", min_score, " min");
      Print("GENIUS: DeltaDiv=", delta_divergence_bull, " Sweep=", swept_lows, 
            " Velocity=", DoubleToString(velocity, 2), " VolCompress=", vol_compressing);
      Print("STANDARD: EMA=", ema_bullish, " Candle=", bullish_candle, 
            " Discount=", in_discount, " FP=", fp_bullish);
      if(is_london) Print("SESSION: London (PRIME TIME)");
      if(is_ny_overlap) Print("SESSION: NY Overlap (PRIME TIME)");
   }
   else if(sell_score >= min_score && sell_score > buy_score)
   {
      signal = EA_SIGNAL_SELL;
      best_setup = SETUP_COMBO;
      Print("=== GENIUS SELL Signal ===");
      Print("Score: ", sell_score, "/", min_score, " min");
      Print("GENIUS: DeltaDiv=", delta_divergence_bear, " Sweep=", swept_highs,
            " Velocity=", DoubleToString(velocity, 2), " VolCompress=", vol_compressing);
      Print("STANDARD: EMA=", ema_bearish, " Candle=", bearish_candle,
            " Premium=", in_premium, " FP=", fp_bearish);
      if(is_london) Print("SESSION: London (PRIME TIME)");
      if(is_ny_overlap) Print("SESSION: NY Overlap (PRIME TIME)");
   }
   
   return signal;
}

//+------------------------------------------------------------------+
//| SETUP CHECKS                                                      |
//+------------------------------------------------------------------+
ENUM_EA_SIGNAL CheckOrderBlockSetup()
{
   double atr = g_atr[0];
   if(atr <= 0) return EA_SIGNAL_NONE;
   double price = g_closes[0];
   
   for(int i = 5; i < InpOB_Lookback; i++)
   {
      // Bullish OB
      if(g_closes[i] < g_opens[i])
      {
         double displacement = g_highs[i-1] - g_closes[i];
         if(displacement >= atr * InpOB_Displacement)
         {
            double ob_top = g_opens[i];
            double ob_bottom = g_lows[i];
            if(price <= ob_top && price >= ob_bottom - atr * 0.3)
               return EA_SIGNAL_BUY;
         }
      }
      // Bearish OB
      if(g_closes[i] > g_opens[i])
      {
         double displacement = g_closes[i] - g_lows[i-1];
         if(displacement >= atr * InpOB_Displacement)
         {
            double ob_top = g_highs[i];
            double ob_bottom = g_opens[i];
            if(price >= ob_bottom && price <= ob_top + atr * 0.3)
               return EA_SIGNAL_SELL;
         }
      }
   }
   return EA_SIGNAL_NONE;
}

ENUM_EA_SIGNAL CheckSweepSetup()
{
   double recent_high = g_highs[1];
   double recent_low = g_lows[1];
   
   for(int i = 2; i < InpSweep_Lookback; i++)
   {
      if(g_highs[i] > recent_high) recent_high = g_highs[i];
      if(g_lows[i] < recent_low) recent_low = g_lows[i];
   }
   
   bool swept_high = g_highs[0] > recent_high * (1 - InpSweep_Tolerance/100);
   bool swept_low = g_lows[0] < recent_low * (1 + InpSweep_Tolerance/100);
   
   // Calculate wick ratios for rejection confirmation
   double body = MathAbs(g_closes[0] - g_opens[0]);
   double upper_wick = g_highs[0] - MathMax(g_closes[0], g_opens[0]);
   double lower_wick = MathMin(g_closes[0], g_opens[0]) - g_lows[0];
   double full_range = g_highs[0] - g_lows[0];
   
   if(full_range <= 0) return EA_SIGNAL_NONE;
   
   // MELHORIA: Exigir rejection wick >= 50% do range (confirmacao de retorno)
   double rejection_min = 0.40;  // 40% do range minimo para ser rejection
   
   // Bearish sweep: Swept high + fechou bearish + upper wick significativo
   if(swept_high && g_closes[0] < g_opens[0])
   {
      double wick_ratio = upper_wick / full_range;
      if(wick_ratio >= rejection_min)  // Rejection wick confirmado
         return EA_SIGNAL_SELL;
   }
   
   // Bullish sweep: Swept low + fechou bullish + lower wick significativo
   if(swept_low && g_closes[0] > g_opens[0])
   {
      double wick_ratio = lower_wick / full_range;
      if(wick_ratio >= rejection_min)  // Rejection wick confirmado
         return EA_SIGNAL_BUY;
   }
   
   return EA_SIGNAL_NONE;
}

ENUM_EA_SIGNAL CheckMACrossSetup()
{
   double fast[], slow[], rsi[];
   ArraySetAsSeries(fast, true);
   ArraySetAsSeries(slow, true);
   ArraySetAsSeries(rsi, true);
   
   if(CopyBuffer(g_fast_ma_handle, 0, 0, 3, fast) < 3) return EA_SIGNAL_NONE;
   if(CopyBuffer(g_slow_ma_handle, 0, 0, 3, slow) < 3) return EA_SIGNAL_NONE;
   if(CopyBuffer(g_rsi_handle, 0, 0, 3, rsi) < 3) return EA_SIGNAL_NONE;
   
   bool cross_up = fast[1] > slow[1] && fast[2] <= slow[2];
   bool cross_down = fast[1] < slow[1] && fast[2] >= slow[2];
   
   bool rsi_ok_buy = !InpUseRSI || rsi[1] < InpRSI_OB;
   bool rsi_ok_sell = !InpUseRSI || rsi[1] > InpRSI_OS;
   
   if(cross_up && rsi_ok_buy) return EA_SIGNAL_BUY;
   if(cross_down && rsi_ok_sell) return EA_SIGNAL_SELL;
   
   return EA_SIGNAL_NONE;
}

ENUM_EA_SIGNAL CheckFVGSetup()
{
   // 3-candle fair value gap detection on M15 buffers
   if(ArraySize(g_closes) < 5) return EA_SIGNAL_NONE;
   
   double a_high = g_highs[2];
   double a_low  = g_lows[2];
   double b_high = g_highs[1];
   double b_low  = g_lows[1];
   double c_high = g_highs[0];
   double c_low  = g_lows[0];
   
   // Bullish FVG: candle B low > candle A high and price retraces into gap
   bool bull_gap = (b_low > a_high) && (c_low <= a_high);
   // Bearish FVG: candle B high < candle A low and price retraces into gap
   bool bear_gap = (b_high < a_low) && (c_high >= a_low);
   
   double atr = g_atr[0];
   double min_gap = atr * 0.3;
   
   if(bull_gap && (b_low - a_high) >= min_gap)
   {
      // price currently inside gap lower half
      if(g_closes[0] <= b_low && g_closes[0] >= a_high - min_gap*0.2)
         return EA_SIGNAL_BUY;
   }
   if(bear_gap && (a_low - b_high) >= min_gap)
   {
      if(g_closes[0] >= b_high && g_closes[0] <= a_low + min_gap*0.2)
         return EA_SIGNAL_SELL;
   }
   return EA_SIGNAL_NONE;
}

ENUM_EA_SIGNAL CheckFiboSetup()
{
   if(g_fibo_382 == 0) return EA_SIGNAL_NONE;
   
   double price = g_closes[0];
   double tolerance = InpFiboZone * _Point;
   
   // Check if at fibo level
   bool at_382 = MathAbs(price - g_fibo_382) <= tolerance;
   bool at_500 = MathAbs(price - g_fibo_500) <= tolerance;
   bool at_618 = MathAbs(price - g_fibo_618) <= tolerance;
   
   if(!at_382 && !at_500 && !at_618) return EA_SIGNAL_NONE;
   
   // Simples: se preço subiu pra fibo = venda, se caiu pra fibo = compra
   bool price_falling = g_closes[0] < g_closes[1];
   bool price_rising = g_closes[0] > g_closes[1];
   
   // At fibo 618/500 (suporte) + price falling = compra (bounce)
   if((at_618 || at_500) && price_falling)
      return EA_SIGNAL_BUY;
   
   // At fibo 382 (resistencia) + price rising = venda (rejeição)
   if(at_382 && price_rising)
      return EA_SIGNAL_SELL;
   
   return EA_SIGNAL_NONE;
}

//+------------------------------------------------------------------+
//| TRADE EXECUTION                                                   |
//+------------------------------------------------------------------+
void ExecuteTrade(ENUM_EA_SIGNAL signal)
{
   ExecuteTradeWithMultiplier(signal, 1.0);
}

//+------------------------------------------------------------------+
//| v3.0: TRADE EXECUTION WITH MULTIPLIER                            |
//| Accepts combined multiplier from MTF/Regime/Footprint            |
//+------------------------------------------------------------------+
void ExecuteTradeWithMultiplier(ENUM_EA_SIGNAL signal, double size_multiplier)
{
   if(signal == EA_SIGNAL_NONE) return;
   
   // Preço DIRETO (confiável no backtest)
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double price = (signal == EA_SIGNAL_BUY) ? ask : bid;
   if(price <= 0) { Print("ERRO: Price=0"); return; }
   
   double atr = g_atr[0];
   if(atr <= 0) { Print("ERRO: ATR=0"); return; }
   
   // SL/TP - USE MODE CONFIG
   double sl_distance = atr * g_mode.sl_atr_mult;
   double tp_distance = sl_distance * g_mode.tp_rr;
   
   double sl, tp;
   if(signal == EA_SIGNAL_BUY)
   {
      sl = NormalizeDouble(price - sl_distance, _Digits);
      tp = NormalizeDouble(price + tp_distance, _Digits);
   }
   else
   {
      sl = NormalizeDouble(price + sl_distance, _Digits);
      tp = NormalizeDouble(price - tp_distance, _Digits);
   }
   
   // Validate stops
   long stops_level = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double min_stop = stops_level * _Point;
   if(min_stop > 0)
   {
      if(MathAbs(price - sl) < min_stop) sl_distance = min_stop * 1.5;
      if(MathAbs(price - tp) < min_stop) tp_distance = min_stop * 1.5;
      
      if(signal == EA_SIGNAL_BUY)
      {
         sl = NormalizeDouble(price - sl_distance, _Digits);
         tp = NormalizeDouble(price + tp_distance, _Digits);
      }
      else
      {
         sl = NormalizeDouble(price + sl_distance, _Digits);
         tp = NormalizeDouble(price - tp_distance, _Digits);
      }
   }
   
   // R:R check - USE MODE CONFIG
   if(tp_distance / sl_distance < g_mode.min_rr) return;
   
   // Calculate lot (GENIUS adaptive with v3.0 multiplier)
   g_current_trade.sl_distance = sl_distance;
   double lot = CalculateGeniusLot(sl_distance, size_multiplier);
   if(lot < g_symbol.LotsMin()) return;
   
   // Store trade context
   g_current_trade.entry_price = price;
   g_current_trade.sl = sl;
   g_current_trade.tp = tp;
   g_current_trade.entry_spread = GetSpreadPoints();
   
   // Execute
   bool ok = false;
   string comment = SetupToString(g_current_trade.setup_type);
   
   if(signal == EA_SIGNAL_BUY)
      ok = g_trade.Buy(lot, _Symbol, price, sl, tp, comment);
   else
      ok = g_trade.Sell(lot, _Symbol, price, sl, tp, comment);
   
   if(ok)
   {
      g_trades_today++;
      Print("TRADE: ", (signal==EA_SIGNAL_BUY?"BUY":"SELL"), 
            " | Setup: ", comment,
            " | Lot: ", lot,
            " | Risk: ", DoubleToString(g_adapt.current_risk, 2), "%",
            " | Session: ", SessionToString(g_current_trade.session),
            " | Regime: ", RegimeToString(g_current_trade.regime));
   }
   else
   {
      Print("TRADE FAILED: ", g_trade.ResultRetcode(), " - ", g_trade.ResultRetcodeDescription());
   }
}

//+------------------------------------------------------------------+
//| GENIUS LOT CALCULATION (v3.0 with external multiplier)           |
//+------------------------------------------------------------------+
double CalculateGeniusLot(double sl_distance, double external_mult = 1.0)
{
   double equity = g_account.Equity();
   
   // Base: Kelly or fixed
   double risk_pct;
   double p_hat = GetSetupProb(g_current_trade.setup_type);
   double rr = InpTP_RR;
   double edge_boost = 1.5; // aggressiveness factor for small account
   
   if(InpUseLearning && g_learn.total_trades >= InpMinTradesLearn && p_hat > 0)
   {
      double edge = ((p_hat * rr) - (1.0 - p_hat)) / rr;
      risk_pct = edge * 100.0 * edge_boost;
      // fallback to Kelly fraction if edge negative
      if(risk_pct <= 0)
         risk_pct = g_learn.kelly.kelly_fraction * 100.0;
   }
   else if(InpUseLearning && g_learn.total_trades >= InpMinTradesLearn)
   {
      risk_pct = g_learn.kelly.kelly_fraction * 100.0;
   }
   else
   {
      risk_pct = InpBaseRisk;
   }
   
   // AGGRESSIVE streak adjustment - compound wins hard
   if(g_adapt.consec_wins >= 5)
      risk_pct *= 1.50;  // +50% after 5 wins = FULL SEND
   else if(g_adapt.consec_wins >= 3)
      risk_pct *= 1.30;  // +30% after 3 wins (ERA 1.15)
   else if(g_adapt.consec_wins >= 2)
      risk_pct *= 1.15;  // +15% after 2 wins
   else if(g_adapt.consec_losses >= 3)
      risk_pct *= 0.5;   // -50% after 3 losses
   else if(g_adapt.consec_losses >= 2)
      risk_pct *= 0.7;   // -30% after 2 losses (ERA 0.6)
   else if(g_adapt.consec_losses >= 1)
      risk_pct *= 0.85;  // -15% after 1 loss (ERA 0.8)
   
   // Circuit breaker adjustment
   if(g_adapt.circuit == STATE_CAUTION)
      risk_pct *= 0.5;
   
   // Setup score adjustment
   if(InpUseLearning && g_learn.total_trades >= InpMinTradesLearn)
   {
      double setup_score = GetSetupScore(g_current_trade.setup_type);
      if(setup_score > 0.6)
         risk_pct *= 1.1;  // Boost for high-score setup
      else if(setup_score < 0.4)
         risk_pct *= 0.7;  // Reduce for low-score setup
   }
   
   // v3.0: Apply external multiplier (MTF + Regime + Footprint)
   risk_pct *= external_mult;
   
   // Clamp (hard cap absolute to evitar oversize)
   const double MAX_ABS_RISK = 3.0;
   risk_pct = MathMin(risk_pct, MAX_ABS_RISK);
   risk_pct = MathMax(InpMinRisk, MathMin(InpMaxRisk, risk_pct));
   g_adapt.current_risk = risk_pct;
   g_current_trade.risk_pct = risk_pct;
   
   // Calculate lot
   double risk_amount = equity * risk_pct / 100.0;
   g_current_trade.risk_amount = risk_amount;
   double point = g_symbol.Point();
   double sl_points = sl_distance / point;
   
   double value_per_point = 0;
   double calc_profit = 0;
   // Try both BUY and SELL to get robust value_per_point
   double profit_buy = 0, profit_sell = 0;
   bool ok_buy = OrderCalcProfit(ORDER_TYPE_BUY, _Symbol, 1.0, g_symbol.Ask(), g_symbol.Ask() + point, profit_buy);
   bool ok_sell = OrderCalcProfit(ORDER_TYPE_SELL, _Symbol, 1.0, g_symbol.Bid(), g_symbol.Bid() - point, profit_sell);
   if(ok_buy) value_per_point = MathMax(value_per_point, MathAbs(profit_buy / point));
   if(ok_sell) value_per_point = MathMax(value_per_point, MathAbs(profit_sell / point));
   if(value_per_point <= 0)
   {
      double tick_value = g_symbol.TickValue();
      double tick_size = g_symbol.TickSize();
      if(tick_size > 0) value_per_point = tick_value * (point / tick_size);
   }
   
   if(value_per_point <= 0 || sl_points <= 0) return 0;
   
   // Exposure cap
   double projected_exposure = CurrentExposurePct() + risk_pct;
   if(projected_exposure > InpMaxExposurePct)
      return 0;
   
   double lot = risk_amount / (sl_points * value_per_point);
   
   // === SANITY CHECKS ===
   // 1. Max lot based on equity (never more than 0.5 lot per $10k equity)
   double max_lot_equity = equity / 20000.0;
   lot = MathMin(lot, max_lot_equity);
   
   // 2. Check margin requirement BEFORE sending order
   double margin_required = 0;
   if(OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, g_symbol.Ask(), margin_required))
   {
      double free_margin = g_account.FreeMargin();
      // Never use more than 80% of free margin
      if(margin_required > free_margin * 0.8)
      {
         double safe_lot = (free_margin * 0.8) / (margin_required / lot);
         lot = MathMin(lot, safe_lot);
         Print("LOT CAPPED by margin: ", DoubleToString(lot, 2), " (margin: ", DoubleToString(margin_required, 0), ")");
      }
   }
   
   // 3. Absolute max for XAUUSD scalping (safety)
   lot = MathMin(lot, 5.0);  // Hard cap

   // Normalize
   lot = MathMax(g_symbol.LotsMin(), lot);
   lot = MathMin(g_symbol.LotsMax(), lot);
   lot = NormalizeDouble(lot, 2);
   
   // Final sanity: if lot would require > 50% margin, reject
   if(OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, g_symbol.Ask(), margin_required))
   {
      if(margin_required > equity * 0.5)
      {
         Print("LOT REJECTED: Would use ", DoubleToString(margin_required/equity*100, 0), "% of equity");
         return 0;
      }
   }
   
   return lot;
}

//+------------------------------------------------------------------+
//| LEARNING FUNCTIONS                                                |
//+------------------------------------------------------------------+
void RecordTradeResult(double profit)
{
   if(!InpUseLearning) return;
   
   double lr = InpLearningRate;
   double risk_amount = MathMax(0.01, g_current_trade.risk_amount);
   double r_multiple = profit / risk_amount;
   int bucket = g_current_trade.bucket15;
   
   // === v3.1 ADAPTIVE LEARNING RATE ===
   // Learn FASTER when struggling (adapt to regime changes)
   // Learn SLOWER when doing well (preserve working strategy)
   double adaptive_lr = lr;
   if(g_adapt.consec_losses >= 3)
   {
      adaptive_lr = MathMin(lr * 1.5, 0.35);  // Up to 50% faster learning on losing streak
      Print("ADAPTIVE LEARNING: Faster rate (", DoubleToString(adaptive_lr, 2), ") due to ", g_adapt.consec_losses, " losses");
   }
   else if(g_adapt.consec_wins >= 5)
   {
      adaptive_lr = MathMax(lr * 0.7, 0.05);  // 30% slower learning on winning streak (preserve what works)
   }
   
   // Also adjust based on trade volume - more trades = more confidence = slower learning
   if(g_learn.total_trades > 100)
      adaptive_lr *= 0.9;
   if(g_learn.total_trades > 300)
      adaptive_lr *= 0.9;
   
   lr = adaptive_lr;
   
   // Update Kelly
   g_learn.kelly.Update(r_multiple);
   
   // Update setup stats
   switch(g_current_trade.setup_type)
   {
      case SETUP_OB:      g_learn.setup_ob.Update(r_multiple, lr); break;
      case SETUP_SWEEP:   g_learn.setup_sweep.Update(r_multiple, lr); break;
      case SETUP_MA_CROSS: g_learn.setup_ma.Update(r_multiple, lr); break;
      case SETUP_FVG:     g_learn.setup_fvg.Update(r_multiple, lr); break;
      case SETUP_FIBO:    g_learn.setup_fibo.Update(r_multiple, lr); break;
      case SETUP_COMBO:   g_learn.setup_combo.Update(r_multiple, lr); break;
   }
   
   // Update session stats
   switch(g_current_trade.session)
   {
      case SESSION_ASIAN:   g_learn.session_asian.Update(r_multiple, lr); break;
      case SESSION_LONDON:  g_learn.session_london.Update(r_multiple, lr); break;
      case SESSION_OVERLAP: g_learn.session_overlap.Update(r_multiple, lr); break;
      case SESSION_NY:      g_learn.session_ny.Update(r_multiple, lr); break;
   }
   
   // Update regime stats
   switch(g_current_trade.regime)
   {
      case EA_REGIME_TRENDING:  g_learn.regime_trending.Update(r_multiple, lr); break;
      case EA_REGIME_REVERTING: g_learn.regime_reverting.Update(r_multiple, lr); break;
      case EA_REGIME_RANDOM:    g_learn.regime_random.Update(r_multiple, lr); break;
   }
   
   // Update bucket stats
   if(bucket>=0 && bucket<96)
      g_bucket_stats[bucket].Update(r_multiple, lr);
   
   g_learn.total_trades++;
   g_learn.total_pnl += profit;
   
   // Update streaks
   if(profit > 0)
   {
      g_adapt.consec_wins++;
      g_adapt.consec_losses = 0;
   }
   else
   {
      g_adapt.consec_losses++;
      g_adapt.consec_wins = 0;
   }
   
   // v3.1 GENIUS: Factor Influence Learning
   // Track which GENIUS factors correlate with wins - dynamically adjust session weights
   bool is_win = profit > 0;
   if(is_win)
   {
      // Winning trade - check which factors contributed
      if(g_current_trade.mtf_mult_at_entry >= 1.0)
      {
         // High MTF confidence correlated with win - boost MTF importance for this session/setup combo
         int sess_idx = (int)g_current_trade.session;
         int setup_idx = (int)g_current_trade.setup_type;
         if(sess_idx >= 0 && sess_idx < 5 && setup_idx >= 0 && setup_idx < 6)
            g_session_weights[sess_idx][setup_idx] = MathMin(1.5, g_session_weights[sess_idx][setup_idx] * 1.02);
      }
      
      if(g_current_trade.footprint_score_at_entry >= 20)
      {
         // Strong footprint on winning trade - log for future reference
         Print("FACTOR WIN: High footprint score (", g_current_trade.footprint_score_at_entry, ") contributed to win");
      }
      
      if(g_current_trade.structure_aligned)
      {
         Print("FACTOR WIN: Structure was aligned at entry");
      }
   }
   else
   {
      // Losing trade - reduce weights for factors that were present
      int sess_idx = (int)g_current_trade.session;
      int setup_idx = (int)g_current_trade.setup_type;
      if(sess_idx >= 0 && sess_idx < 5 && setup_idx >= 0 && setup_idx < 6)
         g_session_weights[sess_idx][setup_idx] = MathMax(0.3, g_session_weights[sess_idx][setup_idx] * 0.98);
   }
   
   Print("LEARNING: Trade ", g_learn.total_trades, 
         " | PnL: ", DoubleToString(profit, 2),
         " | R: ", DoubleToString(r_multiple, 2),
         " | Kelly: ", DoubleToString(g_learn.kelly.kelly_fraction * 100, 2), "%",
         " | Setup score: ", DoubleToString(GetSetupScore(g_current_trade.setup_type), 2),
         " | Bucket: ", g_current_trade.bucket15,
         " | MTF@entry: ", DoubleToString(g_current_trade.mtf_mult_at_entry, 2),
         " | FP@entry: ", g_current_trade.footprint_score_at_entry);
   
   LogTradeCSV(profit, r_multiple);
}

double GetSetupScore(ENUM_SETUP setup)
{
   switch(setup)
   {
      case SETUP_OB:       return g_learn.setup_ob.score;
      case SETUP_SWEEP:    return g_learn.setup_sweep.score;
      case SETUP_MA_CROSS: return g_learn.setup_ma.score;
      case SETUP_FVG:      return g_learn.setup_fvg.score;
      case SETUP_FIBO:     return g_learn.setup_fibo.score;
      case SETUP_COMBO:    return g_learn.setup_combo.score;
      default:             return 0.5;
   }
}

double GetSetupProb(ENUM_SETUP setup)
{
   switch(setup)
   {
      case SETUP_OB:       return g_learn.setup_ob.alpha / MathMax(1.0, g_learn.setup_ob.alpha + g_learn.setup_ob.beta);
      case SETUP_SWEEP:    return g_learn.setup_sweep.alpha / MathMax(1.0, g_learn.setup_sweep.alpha + g_learn.setup_sweep.beta);
      case SETUP_MA_CROSS: return g_learn.setup_ma.alpha / MathMax(1.0, g_learn.setup_ma.alpha + g_learn.setup_ma.beta);
      case SETUP_FVG:      return g_learn.setup_fvg.alpha / MathMax(1.0, g_learn.setup_fvg.alpha + g_learn.setup_fvg.beta);
      case SETUP_FIBO:     return g_learn.setup_fibo.alpha / MathMax(1.0, g_learn.setup_fibo.alpha + g_learn.setup_fibo.beta);
      case SETUP_COMBO:    return g_learn.setup_combo.alpha / MathMax(1.0, g_learn.setup_combo.alpha + g_learn.setup_combo.beta);
      default:             return 0.5;
   }
}

double GetSessionScore(ENUM_SESSION session)
{
   switch(session)
   {
      case SESSION_ASIAN:   return g_learn.session_asian.score;
      case SESSION_LONDON:  return g_learn.session_london.score;
      case SESSION_OVERLAP: return g_learn.session_overlap.score;
      case SESSION_NY:      return g_learn.session_ny.score;
      default:              return 0.5;
   }
}

double GetRegimeScore(ENUM_EA_REGIME regime)
{
   switch(regime)
   {
      case EA_REGIME_TRENDING:  return g_learn.regime_trending.score;
      case EA_REGIME_REVERTING: return g_learn.regime_reverting.score;
      case EA_REGIME_RANDOM:    return g_learn.regime_random.score;
      default:               return 0.5;
   }
}

double GetBucketScore(int bucket)
{
   if(bucket < 0 || bucket >= 96) return 0.5;
   return g_bucket_stats[bucket].score;
}

//+------------------------------------------------------------------+
//| PERSISTENCE                                                       |
//+------------------------------------------------------------------+
void SaveLearningState()
{
   GlobalVariableSet(g_gv_prefix + "total_trades", g_learn.total_trades);
   GlobalVariableSet(g_gv_prefix + "total_pnl", g_learn.total_pnl);
   
   // Kelly
   GlobalVariableSet(g_gv_prefix + "kelly_trades", g_learn.kelly.total_trades);
   GlobalVariableSet(g_gv_prefix + "kelly_wins", g_learn.kelly.wins);
   GlobalVariableSet(g_gv_prefix + "kelly_avg_win_r", g_learn.kelly.avg_win_r);
   GlobalVariableSet(g_gv_prefix + "kelly_avg_loss_r", g_learn.kelly.avg_loss_r);
   GlobalVariableSet(g_gv_prefix + "kelly_fraction", g_learn.kelly.kelly_fraction);
   
   // Setup scores
   GlobalVariableSet(g_gv_prefix + "setup_ob_score", g_learn.setup_ob.score);
   GlobalVariableSet(g_gv_prefix + "setup_ob_trades", g_learn.setup_ob.trades);
   GlobalVariableSet(g_gv_prefix + "setup_ob_alpha", g_learn.setup_ob.alpha);
   GlobalVariableSet(g_gv_prefix + "setup_ob_beta", g_learn.setup_ob.beta);
   GlobalVariableSet(g_gv_prefix + "setup_sweep_score", g_learn.setup_sweep.score);
   GlobalVariableSet(g_gv_prefix + "setup_sweep_trades", g_learn.setup_sweep.trades);
   GlobalVariableSet(g_gv_prefix + "setup_sweep_alpha", g_learn.setup_sweep.alpha);
   GlobalVariableSet(g_gv_prefix + "setup_sweep_beta", g_learn.setup_sweep.beta);
   GlobalVariableSet(g_gv_prefix + "setup_ma_score", g_learn.setup_ma.score);
   GlobalVariableSet(g_gv_prefix + "setup_ma_trades", g_learn.setup_ma.trades);
   GlobalVariableSet(g_gv_prefix + "setup_ma_alpha", g_learn.setup_ma.alpha);
   GlobalVariableSet(g_gv_prefix + "setup_ma_beta", g_learn.setup_ma.beta);
   GlobalVariableSet(g_gv_prefix + "setup_fvg_score", g_learn.setup_fvg.score);
   GlobalVariableSet(g_gv_prefix + "setup_fvg_trades", g_learn.setup_fvg.trades);
   GlobalVariableSet(g_gv_prefix + "setup_fvg_alpha", g_learn.setup_fvg.alpha);
   GlobalVariableSet(g_gv_prefix + "setup_fvg_beta", g_learn.setup_fvg.beta);
   GlobalVariableSet(g_gv_prefix + "setup_fibo_score", g_learn.setup_fibo.score);
   GlobalVariableSet(g_gv_prefix + "setup_fibo_trades", g_learn.setup_fibo.trades);
   GlobalVariableSet(g_gv_prefix + "setup_fibo_alpha", g_learn.setup_fibo.alpha);
   GlobalVariableSet(g_gv_prefix + "setup_fibo_beta", g_learn.setup_fibo.beta);
   
   // v3.1 FIX: COMBO setup persistence
   GlobalVariableSet(g_gv_prefix + "setup_combo_score", g_learn.setup_combo.score);
   GlobalVariableSet(g_gv_prefix + "setup_combo_trades", g_learn.setup_combo.trades);
   GlobalVariableSet(g_gv_prefix + "setup_combo_alpha", g_learn.setup_combo.alpha);
   GlobalVariableSet(g_gv_prefix + "setup_combo_beta", g_learn.setup_combo.beta);
   
   // Session scores
   GlobalVariableSet(g_gv_prefix + "session_asian_score", g_learn.session_asian.score);
   GlobalVariableSet(g_gv_prefix + "session_london_score", g_learn.session_london.score);
   GlobalVariableSet(g_gv_prefix + "session_overlap_score", g_learn.session_overlap.score);
   GlobalVariableSet(g_gv_prefix + "session_ny_score", g_learn.session_ny.score);
   
   // Regime scores
   GlobalVariableSet(g_gv_prefix + "regime_trend_score", g_learn.regime_trending.score);
   GlobalVariableSet(g_gv_prefix + "regime_revert_score", g_learn.regime_reverting.score);
   GlobalVariableSet(g_gv_prefix + "regime_random_score", g_learn.regime_random.score);
   
   // Bucket stats
   for(int i=0;i<96;i++)
   {
      string key = g_gv_prefix + "bucket_" + IntegerToString(i);
      GlobalVariableSet(key + "_a", g_bucket_stats[i].alpha);
      GlobalVariableSet(key + "_b", g_bucket_stats[i].beta);
      GlobalVariableSet(key + "_s", g_bucket_stats[i].score);
      GlobalVariableSet(key + "_t", g_bucket_stats[i].trades);
   }
   
   Print("Learning state SAVED: ", g_learn.total_trades, " trades");
}

void LoadLearningState()
{
   if(!GlobalVariableCheck(g_gv_prefix + "total_trades"))
      return;
   
   g_learn.total_trades = (int)GlobalVariableGet(g_gv_prefix + "total_trades");
   g_learn.total_pnl = GlobalVariableGet(g_gv_prefix + "total_pnl");
   
   // Kelly
   g_learn.kelly.total_trades = (int)GlobalVariableGet(g_gv_prefix + "kelly_trades");
   g_learn.kelly.wins = (int)GlobalVariableGet(g_gv_prefix + "kelly_wins");
   g_learn.kelly.avg_win_r = GlobalVariableGet(g_gv_prefix + "kelly_avg_win_r");
   g_learn.kelly.avg_loss_r = GlobalVariableGet(g_gv_prefix + "kelly_avg_loss_r");
   g_learn.kelly.kelly_fraction = GlobalVariableGet(g_gv_prefix + "kelly_fraction");
   
   // Setup scores
   g_learn.setup_ob.score = GlobalVariableGet(g_gv_prefix + "setup_ob_score");
   g_learn.setup_ob.trades = (int)GlobalVariableGet(g_gv_prefix + "setup_ob_trades");
    g_learn.setup_ob.alpha = GlobalVariableGet(g_gv_prefix + "setup_ob_alpha");
    g_learn.setup_ob.beta  = GlobalVariableGet(g_gv_prefix + "setup_ob_beta");
   g_learn.setup_sweep.score = GlobalVariableGet(g_gv_prefix + "setup_sweep_score");
   g_learn.setup_sweep.trades = (int)GlobalVariableGet(g_gv_prefix + "setup_sweep_trades");
    g_learn.setup_sweep.alpha = GlobalVariableGet(g_gv_prefix + "setup_sweep_alpha");
    g_learn.setup_sweep.beta  = GlobalVariableGet(g_gv_prefix + "setup_sweep_beta");
   g_learn.setup_ma.score = GlobalVariableGet(g_gv_prefix + "setup_ma_score");
   g_learn.setup_ma.trades = (int)GlobalVariableGet(g_gv_prefix + "setup_ma_trades");
    g_learn.setup_ma.alpha = GlobalVariableGet(g_gv_prefix + "setup_ma_alpha");
    g_learn.setup_ma.beta  = GlobalVariableGet(g_gv_prefix + "setup_ma_beta");
   g_learn.setup_fvg.score = GlobalVariableGet(g_gv_prefix + "setup_fvg_score");
   g_learn.setup_fvg.trades = (int)GlobalVariableGet(g_gv_prefix + "setup_fvg_trades");
    g_learn.setup_fvg.alpha = GlobalVariableGet(g_gv_prefix + "setup_fvg_alpha");
    g_learn.setup_fvg.beta  = GlobalVariableGet(g_gv_prefix + "setup_fvg_beta");
   g_learn.setup_fibo.score = GlobalVariableGet(g_gv_prefix + "setup_fibo_score");
   g_learn.setup_fibo.trades = (int)GlobalVariableGet(g_gv_prefix + "setup_fibo_trades");
    g_learn.setup_fibo.alpha = GlobalVariableGet(g_gv_prefix + "setup_fibo_alpha");
    g_learn.setup_fibo.beta  = GlobalVariableGet(g_gv_prefix + "setup_fibo_beta");
   
   // v3.1 FIX: COMBO setup persistence
   g_learn.setup_combo.score = GlobalVariableGet(g_gv_prefix + "setup_combo_score");
   g_learn.setup_combo.trades = (int)GlobalVariableGet(g_gv_prefix + "setup_combo_trades");
   g_learn.setup_combo.alpha = GlobalVariableGet(g_gv_prefix + "setup_combo_alpha");
   g_learn.setup_combo.beta  = GlobalVariableGet(g_gv_prefix + "setup_combo_beta");
   
   // Session scores
   g_learn.session_asian.score = GlobalVariableGet(g_gv_prefix + "session_asian_score");
   g_learn.session_london.score = GlobalVariableGet(g_gv_prefix + "session_london_score");
   g_learn.session_overlap.score = GlobalVariableGet(g_gv_prefix + "session_overlap_score");
   g_learn.session_ny.score = GlobalVariableGet(g_gv_prefix + "session_ny_score");
   
   // Regime scores
   g_learn.regime_trending.score = GlobalVariableGet(g_gv_prefix + "regime_trend_score");
   g_learn.regime_reverting.score = GlobalVariableGet(g_gv_prefix + "regime_revert_score");
   g_learn.regime_random.score = GlobalVariableGet(g_gv_prefix + "regime_random_score");
   
   // Bucket stats
   for(int i=0;i<96;i++)
   {
      string key = g_gv_prefix + "bucket_" + IntegerToString(i);
      if(GlobalVariableCheck(key + "_a"))
      {
         g_bucket_stats[i].alpha  = GlobalVariableGet(key + "_a");
         g_bucket_stats[i].beta   = GlobalVariableGet(key + "_b");
         g_bucket_stats[i].score  = GlobalVariableGet(key + "_s");
         g_bucket_stats[i].trades = (int)GlobalVariableGet(key + "_t");
      }
      else
      {
         g_bucket_stats[i].Reset();
      }
   }
   
   Print("Learning state LOADED: ", g_learn.total_trades, " trades");
}

//+------------------------------------------------------------------+
//| UTILITY FUNCTIONS                                                 |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   datetime current = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(current == g_last_bar_time) return false;
   g_last_bar_time = current;
   return true;
}

bool LoadPriceData()
{
   int count = MathMax(InpHurst_Window + 50, InpOB_Lookback + 20);
   
   ArraySetAsSeries(g_closes, true);
   ArraySetAsSeries(g_highs, true);
   ArraySetAsSeries(g_lows, true);
   ArraySetAsSeries(g_opens, true);
   ArraySetAsSeries(g_atr, true);
   
   if(CopyClose(_Symbol, PERIOD_CURRENT, 0, count, g_closes) < count) return false;
   if(CopyHigh(_Symbol, PERIOD_CURRENT, 0, count, g_highs) < count) return false;
   if(CopyLow(_Symbol, PERIOD_CURRENT, 0, count, g_lows) < count) return false;
   if(CopyOpen(_Symbol, PERIOD_CURRENT, 0, count, g_opens) < count) return false;
   if(CopyBuffer(g_atr_handle, 0, 0, count, g_atr) < count) return false;
   
   return true;
}

double GetVolRank()
{
   // ratio ATR(14)/ATR(100) capped to [0,1]
   if(ArraySize(g_atr) < 120) return 0.5;
   double atr_short = g_atr[0];
   double atr_long = 0;
   for(int i=0;i<100;i++) atr_long += g_atr[i];
   atr_long /= 100.0;
   if(atr_long <= 0) return 0.5;
   double rank = MathMin(1.0, MathMax(0.0, atr_short / (atr_long*2.0)));
   return rank;
}

ENUM_SESSION GetCurrentSession()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   int gmt_hour = (dt.hour - InpGMT_Offset + 24) % 24;
   
   if(gmt_hour >= 0 && gmt_hour < 7) return SESSION_ASIAN;
   if(gmt_hour >= 7 && gmt_hour < 12) return SESSION_LONDON;
   if(gmt_hour >= 12 && gmt_hour < 16) return SESSION_OVERLAP;
   if(gmt_hour >= 16 && gmt_hour < 21) return SESSION_NY;
   return SESSION_DEAD;
}

int GetCurrentBucket()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   int minute_of_day = dt.hour*60 + dt.min;
   int bucket = minute_of_day / 15;
   if(bucket < 0) bucket = 0;
   if(bucket > 95) bucket = 95;
   return bucket;
}

bool InPremiumDiscountFilter(ENUM_EA_SIGNAL signal)
{
   double highs[], lows[];
   ArraySetAsSeries(highs, true);
   ArraySetAsSeries(lows, true);
   if(CopyHigh(_Symbol, PERIOD_H1, 0, 50, highs) < 50) return true;
   if(CopyLow(_Symbol, PERIOD_H1, 0, 50, lows) < 50) return true;
   double h = highs[ArrayMaximum(highs, 0, 50)];
   double l = lows[ArrayMinimum(lows, 0, 50)];
   double mid = (h + l) / 2.0;
   double price = g_closes[0];
   if(signal == EA_SIGNAL_BUY && price > mid) return false;
   if(signal == EA_SIGNAL_SELL && price < mid) return false;
   return true;
}

int GetSpreadPoints()
{
   g_symbol.Refresh();
   int spr = (int)g_symbol.Spread();
   g_spread_buffer[g_spread_idx % 20] = spr;
   g_spread_idx++;
   return spr;
}

double GetMedianSpread()
{
   int count = MathMin(g_spread_idx, 20);
   if(count <= 0) return 0;
   double temp[];
   ArrayResize(temp, count);
   for(int i=0;i<count;i++) temp[i]=g_spread_buffer[i];
   ArraySort(temp); // ascending
   int mid = count/2;
   if((count%2)==0) return (temp[mid-1]+temp[mid])/2.0;
   else return temp[mid];
}

double ValuePerPoint()
{
   double value_per_point = 0;
   double calc_profit = 0;
   double point = g_symbol.Point();
   if(OrderCalcProfit(ORDER_TYPE_BUY, _Symbol, 1.0, g_symbol.Ask(), g_symbol.Ask() + point, calc_profit))
      value_per_point = calc_profit / point;
   else
   {
      double tick_value = g_symbol.TickValue();
      double tick_size = g_symbol.TickSize();
      if(tick_size > 0) value_per_point = tick_value * (point / tick_size);
   }
   return value_per_point;
}

double CurrentExposurePct()
{
   double equity = g_account.Equity();
   double vpp = ValuePerPoint();
   if(vpp <= 0 || equity <= 0) return 0;
   double exposure = 0;
   for(int i=PositionsTotal()-1; i>=0; i--)
   {
      if(g_position.SelectByIndex(i))
      {
         if(g_position.Magic()==InpMagicNumber && g_position.Symbol()==_Symbol)
         {
            double sl = g_position.StopLoss();
            if(sl <= 0) continue;
            double price = g_position.PriceOpen();
            double dist = MathAbs(price - sl);
            double risk = (dist / g_symbol.Point()) * vpp * g_position.Volume();
            exposure += risk;
         }
      }
   }
   return exposure / equity * 100.0;
}

bool IsNewsBlocked()
{
   if(!InpUseNewsBlock) return false;
   int handle = FileOpen(InpNewsFile, FILE_READ|FILE_CSV, ';');
   if(handle == INVALID_HANDLE) return false;
   datetime now = TimeCurrent();
   bool blocked = false;
   while(!FileIsEnding(handle))
   {
      string dt_str = FileReadString(handle);
      int window = (int)FileReadNumber(handle);
      if(StringLen(dt_str) < 10) continue;
      datetime news_time = StringToTime(dt_str);
      if(news_time==0) continue;
      if(MathAbs((int)(now - news_time)) <= window * 60)
      {
         blocked = true;
         break;
      }
   }
   FileClose(handle);
   return blocked;
}

bool ManageOpenPositions()
{
   if(!InpUseBE_Partial) return false;
   bool modified=false;
   double vpp = ValuePerPoint();
   if(vpp<=0) return false;
   double atr10 = 0;
   if(CopyBuffer(g_atr_handle,0,0,10,g_atr)>=10)
      atr10 = g_atr[0];
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      if(!g_position.SelectByIndex(i)) continue;
      if(g_position.Magic()!=InpMagicNumber || g_position.Symbol()!=_Symbol) continue;
      
      double open = g_position.PriceOpen();
      double sl = g_position.StopLoss();
      if(sl<=0) sl = open - (g_position.PositionType()==POSITION_TYPE_BUY ? g_current_trade.sl_distance : -g_current_trade.sl_distance);
      double dist = MathAbs(open - sl);
      double risk_amount = (dist / g_symbol.Point()) * vpp * g_position.Volume();
      if(risk_amount<=0) continue;
      double profit = g_position.Profit() + g_position.Swap() + g_position.Commission();
      double r_now = profit / risk_amount;
      
      // BE move
      if(r_now >= InpBE_TriggerR)
      {
         double new_sl = open;
         if(g_position.PositionType()==POSITION_TYPE_BUY && (sl < new_sl))
         {
            g_trade.PositionModify(g_position.Ticket(), new_sl, g_position.TakeProfit());
            modified=true;
         }
         if(g_position.PositionType()==POSITION_TYPE_SELL && (sl > new_sl))
         {
            g_trade.PositionModify(g_position.Ticket(), new_sl, g_position.TakeProfit());
            modified=true;
         }
      }
      
      // Partial (FIX: Check if already taken via GlobalVariable)
      string partial_key = g_gv_prefix + "PARTIAL_" + IntegerToString(g_position.Ticket());
      bool partial_taken = GlobalVariableCheck(partial_key);
      
      if(r_now >= InpPartial_R && InpPartial_Pct > 0 && InpPartial_Pct < 1.0 && !partial_taken)
      {
         double close_vol = g_position.Volume() * InpPartial_Pct;
         double step = g_symbol.LotsStep();
         close_vol = MathMax(step, NormalizeDouble(close_vol/step,0)*step);
         if(close_vol >= g_symbol.LotsMin() && close_vol < g_position.Volume())
         {
            if(g_trade.PositionClosePartial(g_position.Ticket(), close_vol))
            {
               GlobalVariableSet(partial_key, 1.0);  // Mark partial as taken
               Print("PARTIAL TP: Closed ", DoubleToString(close_vol, 2), " lots @ ", DoubleToString(r_now, 2), "R");
               modified=true;
            }
         }
      }
      
      // Trailing (v3.0 FASE 1.3: Structure-Based)
      if(r_now >= InpTrail_StartR && atr10>0)
      {
         double trail_dist = atr10 * InpTrail_ATR_Mult;
         double new_sl;
         double current_sl = g_position.StopLoss();
         double current_price = (g_position.PositionType()==POSITION_TYPE_BUY) 
            ? SymbolInfoDouble(_Symbol, SYMBOL_BID) 
            : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         
         // ATR-based trailing as baseline
         if(g_position.PositionType()==POSITION_TYPE_BUY)
            new_sl = NormalizeDouble(current_price - trail_dist, _Digits);
         else
            new_sl = NormalizeDouble(current_price + trail_dist, _Digits);
         
         // === FASE 1.3: Structure-Based Trailing ===
         // Never trail THROUGH a valid swing level - respect structure!
         if(InpUseStructureTrail)
         {
            double structure_sl = GetStructureTrailLevel(g_position.PositionType(), current_price, current_sl, atr10);
            
            if(structure_sl > 0)
            {
               if(g_position.PositionType()==POSITION_TYPE_BUY)
               {
                  // For BUY: use higher SL (more protection)
                  if(structure_sl > new_sl)
                  {
                     Print("STRUCTURE TRAIL: Using swing low @ ", structure_sl, " vs ATR @ ", new_sl,
                           " (+", (structure_sl - new_sl) / _Point, " pts protection)");
                     new_sl = structure_sl;
                  }
               }
               else // SELL
               {
                  // For SELL: use lower SL (more protection)
                  if(structure_sl < new_sl)
                  {
                     Print("STRUCTURE TRAIL: Using swing high @ ", structure_sl, " vs ATR @ ", new_sl,
                           " (+", (new_sl - structure_sl) / _Point, " pts protection)");
                     new_sl = structure_sl;
                  }
               }
            }
         }
         
         // Apply the trailing stop
         if(g_position.PositionType()==POSITION_TYPE_BUY)
         {
            if(new_sl > current_sl)
            {
               g_trade.PositionModify(g_position.Ticket(), new_sl, g_position.TakeProfit());
               modified=true;
            }
         }
         else
         {
            if(new_sl < current_sl || current_sl==0)
            {
               g_trade.PositionModify(g_position.Ticket(), new_sl, g_position.TakeProfit());
               modified=true;
            }
         }
      }
   }
   return modified;
}

//+------------------------------------------------------------------+
//| FASE 1.3: Get Structure-Based Trail Level                        |
//| Finds nearest valid swing level for trailing protection          |
//| For BUY: Find swing lows BELOW current price (support)           |
//| For SELL: Find swing highs ABOVE current price (resistance)      |
//+------------------------------------------------------------------+
double GetStructureTrailLevel(ENUM_POSITION_TYPE pos_type, double current_price, double current_sl, double atr)
{
   // Update structure analysis
   g_structure.AnalyzeStructure(_Symbol, PERIOD_CURRENT);
   
   double buffer = atr * InpStructureBuffer;  // Buffer from swing level
   double structure_level = 0;
   
   if(pos_type == POSITION_TYPE_BUY)
   {
      // Find the highest swing low that is:
      // 1. Below current price
      // 2. Not broken
      // 3. Above our current SL (or we'd be giving back protection)
      SSwingPoint last_low = g_structure.GetLastLow();
      SStructureState state = g_structure.GetState();
      SSwingPoint prev_low = state.prev_low;
      
      // Check last swing low
      if(last_low.is_valid && !last_low.is_broken && 
         last_low.price < current_price &&
         last_low.price > current_sl)
      {
         structure_level = last_low.price - buffer;  // Trail BELOW the swing low
      }
      
      // Check previous swing low if it's higher (better protection)
      if(prev_low.is_valid && !prev_low.is_broken &&
         prev_low.price < current_price &&
         prev_low.price > current_sl)
      {
         double prev_level = prev_low.price - buffer;
         if(prev_level > structure_level)
            structure_level = prev_level;
      }
   }
   else // SELL
   {
      // Find the lowest swing high that is:
      // 1. Above current price
      // 2. Not broken
      // 3. Below our current SL
      SSwingPoint last_high = g_structure.GetLastHigh();
      SStructureState state = g_structure.GetState();
      SSwingPoint prev_high = state.prev_high;
      
      // Check last swing high
      if(last_high.is_valid && !last_high.is_broken &&
         last_high.price > current_price &&
         last_high.price < current_sl)
      {
         structure_level = last_high.price + buffer;  // Trail ABOVE the swing high
      }
      
      // Check previous swing high if it's lower (better protection)
      if(prev_high.is_valid && !prev_high.is_broken &&
         prev_high.price > current_price &&
         prev_high.price < current_sl)
      {
         double prev_level = prev_high.price + buffer;
         if(prev_level < structure_level || structure_level == 0)
            structure_level = prev_level;
      }
   }
   
   return NormalizeDouble(structure_level, _Digits);
}

bool HasOpenPosition()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(g_position.SelectByIndex(i))
      {
         if(g_position.Magic() == InpMagicNumber && g_position.Symbol() == _Symbol)
            return true;
      }
   }
   return false;
}

void CheckNewDay()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   datetime today = StringToTime(IntegerToString(dt.year) + "." + 
                                  IntegerToString(dt.mon) + "." + 
                                  IntegerToString(dt.day));
   
   if(today != g_current_day)
   {
      g_current_day = today;
      ResetDailyState();
   }
}

//+------------------------------------------------------------------+
//| v3.0 PHASE 2: SESSION WEIGHT PROFILES                            |
//| Different setups work better in different sessions               |
//| Asian: OB/FVG (structure-based, lower vol)                       |
//| London: All setups balanced                                      |
//| Overlap: All setups, slight trend-follow bias                    |
//| NY: MA Cross/Sweep (momentum-based)                              |
//+------------------------------------------------------------------+
void InitSessionWeightProfiles()
{
   // g_session_weights[session][setup] = weight multiplier
   // Setups: 0=OB, 1=SWEEP, 2=MA, 3=FVG, 4=FIBO, 5=COMBO
   
   // ASIAN (low vol, structure-focused)
   g_session_weights[SESSION_ASIAN][0] = 1.2;   // OB - good in low vol
   g_session_weights[SESSION_ASIAN][1] = 0.7;   // SWEEP - needs momentum
   g_session_weights[SESSION_ASIAN][2] = 0.5;   // MA - avoid crossovers
   g_session_weights[SESSION_ASIAN][3] = 1.3;   // FVG - excellent in ranges
   g_session_weights[SESSION_ASIAN][4] = 1.1;   // FIBO - retracements work
   g_session_weights[SESSION_ASIAN][5] = 1.0;   // COMBO - always good
   
   // LONDON (high vol, balanced)
   g_session_weights[SESSION_LONDON][0] = 1.1;
   g_session_weights[SESSION_LONDON][1] = 1.2;
   g_session_weights[SESSION_LONDON][2] = 1.0;
   g_session_weights[SESSION_LONDON][3] = 1.0;
   g_session_weights[SESSION_LONDON][4] = 1.0;
   g_session_weights[SESSION_LONDON][5] = 1.2;
   
   // OVERLAP (best liquidity, trend-follow)
   g_session_weights[SESSION_OVERLAP][0] = 1.0;
   g_session_weights[SESSION_OVERLAP][1] = 1.3;  // Sweeps excellent
   g_session_weights[SESSION_OVERLAP][2] = 1.2;  // MA crosses reliable
   g_session_weights[SESSION_OVERLAP][3] = 0.9;
   g_session_weights[SESSION_OVERLAP][4] = 1.0;
   g_session_weights[SESSION_OVERLAP][5] = 1.3;  // COMBO best session
   
   // NY (momentum, continuation)
   g_session_weights[SESSION_NY][0] = 0.9;
   g_session_weights[SESSION_NY][1] = 1.1;
   g_session_weights[SESSION_NY][2] = 1.2;
   g_session_weights[SESSION_NY][3] = 0.8;
   g_session_weights[SESSION_NY][4] = 1.0;
   g_session_weights[SESSION_NY][5] = 1.1;
   
   // DEAD (minimal trading)
   g_session_weights[SESSION_DEAD][0] = 0.5;
   g_session_weights[SESSION_DEAD][1] = 0.3;
   g_session_weights[SESSION_DEAD][2] = 0.3;
   g_session_weights[SESSION_DEAD][3] = 0.5;
   g_session_weights[SESSION_DEAD][4] = 0.4;
   g_session_weights[SESSION_DEAD][5] = 0.5;
   
   Print("Session Weight Profiles: INITIALIZED");
}

//+------------------------------------------------------------------+
//| v3.0 PHASE 2: GET SESSION WEIGHT FOR SETUP                       |
//+------------------------------------------------------------------+
double GetSessionSetupWeight(ENUM_SESSION session, ENUM_SETUP setup)
{
   int sess_idx = (int)session;
   int setup_idx = (int)setup - 1;  // SETUP_NONE=0, so subtract 1
   
   if(sess_idx < 0 || sess_idx > 4) sess_idx = 4;  // Default to DEAD
   if(setup_idx < 0 || setup_idx > 5) return 1.0;  // Default weight
   
   return g_session_weights[sess_idx][setup_idx];
}

void ResetDailyState()
{
   g_daily_start_equity = g_account.Equity();
   g_peak_equity = g_daily_start_equity;
   g_trades_today = 0;
   g_adapt.consec_wins = 0;
   g_adapt.consec_losses = 0;
   
   if(g_adapt.circuit != STATE_EMERGENCY)
      g_adapt.circuit = STATE_NORMAL;
   
   Print("=== New Day | Equity: ", g_daily_start_equity, " ===");
}

//+------------------------------------------------------------------+
//| REGIME DETECTION                                                  |
//+------------------------------------------------------------------+
ENUM_EA_REGIME DetectRegime()
{
   int window = InpHurst_Window;
   if(ArraySize(g_closes) < window + 10) return EA_REGIME_UNKNOWN;
   
   double hurst = CalculateHurst(window);
   if(hurst < 0) return EA_REGIME_UNKNOWN;
   
   if(hurst > InpHurst_Trending) return EA_REGIME_TRENDING;
   else if(hurst < InpHurst_Reverting) return EA_REGIME_REVERTING;
   else return EA_REGIME_RANDOM;
}

double CalculateHurst(int window)
{
   if(ArraySize(g_closes) < window) return -1;
   
   double returns[];
   ArrayResize(returns, window - 1);
   for(int i = 0; i < window - 1; i++)
   {
      if(g_closes[i+1] <= 0) return -1;
      returns[i] = MathLog(g_closes[i] / g_closes[i+1]);
   }
   
   int min_k = 10, max_k = MathMin(50, window / 2);
   double log_n[], log_rs[];
   ArrayResize(log_n, 0);
   ArrayResize(log_rs, 0);
   
   for(int n = min_k; n <= max_k; n++)
   {
      int num_parts = ArraySize(returns) / n;
      if(num_parts < 1) continue;
      
      double rs_sum = 0;
      int valid = 0;
      
      for(int p = 0; p < num_parts; p++)
      {
         double mean = 0;
         for(int j = 0; j < n; j++) mean += returns[p * n + j];
         mean /= n;
         
         double cumdev = 0, max_dev = -DBL_MAX, min_dev = DBL_MAX;
         for(int j = 0; j < n; j++)
         {
            cumdev += returns[p * n + j] - mean;
            if(cumdev > max_dev) max_dev = cumdev;
            if(cumdev < min_dev) min_dev = cumdev;
         }
         double R = max_dev - min_dev;
         
         double var = 0;
         for(int j = 0; j < n; j++) var += MathPow(returns[p * n + j] - mean, 2);
         double S = MathSqrt(var / (n - 1));
         
         if(S > 1e-10) { rs_sum += R / S; valid++; }
      }
      
      if(valid > 0)
      {
         int idx = ArraySize(log_n);
         ArrayResize(log_n, idx + 1);
         ArrayResize(log_rs, idx + 1);
         log_n[idx] = MathLog((double)n);
         log_rs[idx] = MathLog(rs_sum / valid);
      }
   }
   
   int count = ArraySize(log_n);
   if(count < 3) return -1;
   
   double sum_x = 0, sum_y = 0, sum_xy = 0, sum_xx = 0;
   for(int i = 0; i < count; i++)
   {
      sum_x += log_n[i]; sum_y += log_rs[i];
      sum_xy += log_n[i] * log_rs[i]; sum_xx += log_n[i] * log_n[i];
   }
   
   double denom = count * sum_xx - sum_x * sum_x;
   if(MathAbs(denom) < 1e-10) return -1;
   
   double H = (count * sum_xy - sum_x * sum_y) / denom;
   return MathMax(0.0, MathMin(1.0, H));
}

//+------------------------------------------------------------------+
//| FIBONACCI                                                         |
//+------------------------------------------------------------------+
void CalcFibonacci()
{
   if(ArraySize(g_highs) < InpFiboLookback) return;
   
   g_swing_high = g_highs[0];
   g_swing_low = g_lows[0];
   
   for(int i = 1; i < InpFiboLookback; i++)
   {
      if(g_highs[i] > g_swing_high) g_swing_high = g_highs[i];
      if(g_lows[i] < g_swing_low) g_swing_low = g_lows[i];
   }
   
   double range = g_swing_high - g_swing_low;
   if(range <= 0) return;
   
   g_fibo_382 = g_swing_high - range * 0.382;
   g_fibo_500 = g_swing_high - range * 0.500;
   g_fibo_618 = g_swing_high - range * 0.618;
}

//+------------------------------------------------------------------+
//| CIRCUIT BREAKER                                                   |
//+------------------------------------------------------------------+
void UpdateCircuitBreaker()
{
   double equity = g_account.Equity();
   double daily_dd = 0;
   
   if(g_daily_start_equity > 0)
      daily_dd = (g_daily_start_equity - equity) / g_daily_start_equity * 100;
   
   if(equity > g_peak_equity) g_peak_equity = equity;
   
   // Emergency
   if(daily_dd >= InpMaxDailyDD)
   {
      g_adapt.circuit = STATE_EMERGENCY;
      g_adapt.reason = StringFormat("EMERGENCY: DD %.1f%%", daily_dd);
      CloseAllPositions();
      return;
   }
   
   // Blocked
   if(g_adapt.consec_losses >= InpMaxConsecLosses)
   {
      g_adapt.circuit = STATE_BLOCKED;
      g_adapt.reason = StringFormat("BLOCKED: %d losses", g_adapt.consec_losses);
      return;
   }
   
   // Caution
   if(daily_dd >= InpSoftDailyDD)
   {
      g_adapt.circuit = STATE_CAUTION;
      g_adapt.reason = StringFormat("CAUTION: DD %.1f%%", daily_dd);
      return;
   }
   
   // Tilt detection
   if(g_adapt.consec_losses >= 3)
   {
      g_adapt.circuit = STATE_CAUTION;
      g_adapt.is_tilting = true;
      g_adapt.reason = "CAUTION: Possible tilt";
      return;
   }
   
   g_adapt.circuit = STATE_NORMAL;
   g_adapt.is_tilting = false;
   g_adapt.reason = "Normal";
}

void CloseAllPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(g_position.SelectByIndex(i))
      {
         if(g_position.Magic() == InpMagicNumber && g_position.Symbol() == _Symbol)
            g_trade.PositionClose(g_position.Ticket());
      }
   }
}

//+------------------------------------------------------------------+
//| TRADE EVENTS                                                      |
//+------------------------------------------------------------------+
void OnTrade()
{
   static int prev_deals = 0;
   
   HistorySelect(0, TimeCurrent());
   int total_deals = HistoryDealsTotal();
   
   if(total_deals > prev_deals)
   {
      for(int i = prev_deals; i < total_deals; i++)
      {
         ulong ticket = HistoryDealGetTicket(i);
         if(ticket > 0)
         {
            if(HistoryDealGetInteger(ticket, DEAL_MAGIC) == InpMagicNumber &&
               HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol)
            {
               int entry = (int)HistoryDealGetInteger(ticket, DEAL_ENTRY);
               if(entry == DEAL_ENTRY_OUT)
               {
                  double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT)
                                + HistoryDealGetDouble(ticket, DEAL_SWAP)
                                + HistoryDealGetDouble(ticket, DEAL_COMMISSION);
                  
                  RecordTradeResult(profit);
                  UpdateCircuitBreaker();
               }
            }
         }
      }
   }
   prev_deals = total_deals;
}

//+------------------------------------------------------------------+
//| STRING HELPERS                                                    |
//+------------------------------------------------------------------+
string SetupToString(ENUM_SETUP s)
{
   switch(s)
   {
      case SETUP_OB:       return "OB";
      case SETUP_SWEEP:    return "SWEEP";
      case SETUP_MA_CROSS: return "MA";
      case SETUP_FVG:      return "FVG";
      case SETUP_FIBO:     return "FIBO";
      case SETUP_COMBO:    return "COMBO";
      default:             return "NONE";
   }
}

string SessionToString(ENUM_SESSION s)
{
   switch(s)
   {
      case SESSION_ASIAN:   return "ASIAN";
      case SESSION_LONDON:  return "LONDON";
      case SESSION_OVERLAP: return "OVERLAP";
      case SESSION_NY:      return "NY";
      default:              return "DEAD";
   }
}

string RegimeToString(ENUM_EA_REGIME r)
{
   switch(r)
   {
      case EA_REGIME_TRENDING:  return "TREND";
      case EA_REGIME_REVERTING: return "REVERT";
      case EA_REGIME_RANDOM:    return "RANDOM";
      default:               return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
//| LEARNING REPORT                                                   |
//+------------------------------------------------------------------+
void PrintLearningReport()
{
   Print("==============================================");
   Print("  GENIUS LEARNING REPORT");
   Print("==============================================");
   Print("Total Trades: ", g_learn.total_trades);
   Print("Total PnL: ", DoubleToString(g_learn.total_pnl, 2));
   Print("");
   Print("=== KELLY CRITERION ===");
   Print("Kelly Fraction: ", DoubleToString(g_learn.kelly.kelly_fraction * 100, 2), "%");
   Print("Win Rate: ", DoubleToString((double)g_learn.kelly.wins / MathMax(1, g_learn.kelly.total_trades) * 100, 1), "%");
   Print("Avg Win (R): ", DoubleToString(g_learn.kelly.avg_win_r, 2));
   Print("Avg Loss (R): ", DoubleToString(g_learn.kelly.avg_loss_r, 2));
   Print("");
   Print("=== SETUP SCORES ===");
   Print("Order Block:  ", DoubleToString(g_learn.setup_ob.score, 2), " (", g_learn.setup_ob.trades, " trades)");
   Print("Sweep:        ", DoubleToString(g_learn.setup_sweep.score, 2), " (", g_learn.setup_sweep.trades, " trades)");
   Print("MA Cross:     ", DoubleToString(g_learn.setup_ma.score, 2), " (", g_learn.setup_ma.trades, " trades)");
   Print("FVG:          ", DoubleToString(g_learn.setup_fvg.score, 2), " (", g_learn.setup_fvg.trades, " trades)");
   Print("Fibonacci:    ", DoubleToString(g_learn.setup_fibo.score, 2), " (", g_learn.setup_fibo.trades, " trades)");
   Print("");
   Print("=== SESSION SCORES ===");
   Print("Asian:   ", DoubleToString(g_learn.session_asian.score, 2));
   Print("London:  ", DoubleToString(g_learn.session_london.score, 2));
   Print("Overlap: ", DoubleToString(g_learn.session_overlap.score, 2));
   Print("NY:      ", DoubleToString(g_learn.session_ny.score, 2));
   Print("");
   Print("=== REGIME SCORES ===");
   Print("Trending:  ", DoubleToString(g_learn.regime_trending.score, 2));
   Print("Reverting: ", DoubleToString(g_learn.regime_reverting.score, 2));
   Print("Random:    ", DoubleToString(g_learn.regime_random.score, 2));
   Print("==============================================");
}

//+------------------------------------------------------------------+
//| CSV LOG                                                          |
//+------------------------------------------------------------------+
void LogTradeCSV(double profit, double r_multiple)
{
   string path = "data/trade_log.csv";
   int handle = FileOpen(path, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_READ);
   if(handle == INVALID_HANDLE)
      handle = FileOpen(path, FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_READ);
   if(handle == INVALID_HANDLE) return;
   FileSeek(handle, 0, SEEK_END);
   MqlDateTime dt; TimeToStruct(TimeCurrent(), dt);
   string stamp = StringFormat("%04d-%02d-%02d %02d:%02d:%02d", dt.year, dt.mon, dt.day, dt.hour, dt.min, dt.sec);
   FileWrite(handle,
      stamp,
      SetupToString(g_current_trade.setup_type),
      SessionToString(g_current_trade.session),
      RegimeToString(g_current_trade.regime),
      DoubleToString(GetSetupProb(g_current_trade.setup_type),4),
      DoubleToString(GetSetupScore(g_current_trade.setup_type),4),
      g_current_trade.bucket15,
      DoubleToString(GetBucketScore(g_current_trade.bucket15),4),
      DoubleToString(r_multiple,3),
      DoubleToString(profit,2),
      DoubleToString(g_current_trade.risk_amount,2),
      DoubleToString(g_current_trade.risk_pct,2),
      DoubleToString(g_current_trade.entry_spread,1)
   );
   FileClose(handle);
}
//+------------------------------------------------------------------+
