# ESTRUTURAS DE DADOS MQL5 - EA FTMO SCALPER ELITE

## ÍNDICE
1. [Enumerações Principais](#enumerações-principais)
2. [Estruturas ICT/SMC](#estruturas-ictsmc)
3. [Estruturas de Trading](#estruturas-de-trading)
4. [Estruturas de Risco](#estruturas-de-risco)
5. [Estruturas de Compliance](#estruturas-de-compliance)
6. [Estruturas de Volume](#estruturas-de-volume)
7. [Estruturas de Alertas](#estruturas-de-alertas)
8. [Estruturas de Logging](#estruturas-de-logging)
9. [Estruturas de Performance](#estruturas-de-performance)
10. [Estruturas de Configuração](#estruturas-de-configuração)
11. [Estruturas Auxiliares](#estruturas-auxiliares)
12. [Constantes do Sistema](#constantes-do-sistema)

---

## ENUMERAÇÕES PRINCIPAIS

### Estados do EA
```mql5
//+------------------------------------------------------------------+
//|                      Enumerações do Sistema                      |
//+------------------------------------------------------------------+

// Estado do Expert Advisor
enum ENUM_EA_STATE
{
    EA_STATE_INIT,              // Inicializando
    EA_STATE_READY,             // Pronto para operar
    EA_STATE_TRADING,           // Operando
    EA_STATE_PAUSED,            // Pausado
    EA_STATE_STOPPED,           // Parado
    EA_STATE_ERROR,             // Erro
    EA_STATE_EMERGENCY_STOP,    // Parada de emergência
    EA_STATE_COMPLIANCE_STOP    // Parada por compliance
};

// Tipos de Sinal
enum ENUM_SIGNAL_TYPE
{
    SIGNAL_NONE,                // Nenhum sinal
    SIGNAL_BUY,                 // Sinal de compra
    SIGNAL_SELL,                // Sinal de venda
    SIGNAL_BUY_STRONG,          // Sinal de compra forte
    SIGNAL_SELL_STRONG,         // Sinal de venda forte
    SIGNAL_EXIT_BUY,            // Sair de compra
    SIGNAL_EXIT_SELL,           // Sair de venda
    SIGNAL_CLOSE_ALL            // Fechar todas as posições
};

// Força do Sinal
enum ENUM_SIGNAL_STRENGTH
{
    SIGNAL_STRENGTH_WEAK = 1,   // Fraco (1-3)
    SIGNAL_STRENGTH_MEDIUM = 4, // Médio (4-6)
    SIGNAL_STRENGTH_STRONG = 7, // Forte (7-8)
    SIGNAL_STRENGTH_VERY_STRONG = 9 // Muito forte (9-10)
};

// Tipos de Order Block
enum ENUM_ORDER_BLOCK_TYPE
{
    OB_TYPE_BULLISH,            // Order Block de alta
    OB_TYPE_BEARISH,            // Order Block de baixa
    OB_TYPE_MITIGATION,         // Order Block mitigado
    OB_TYPE_BREAKER             // Breaker Block
};

// Estados do Order Block
enum ENUM_ORDER_BLOCK_STATE
{
    OB_STATE_ACTIVE,            // Ativo
    OB_STATE_TESTED,            // Testado
    OB_STATE_MITIGATED,         // Mitigado
    OB_STATE_EXPIRED            // Expirado
};

// Tipos de Fair Value Gap
enum ENUM_FVG_TYPE
{
    FVG_TYPE_BULLISH,           // FVG de alta
    FVG_TYPE_BEARISH,           // FVG de baixa
    FVG_TYPE_BALANCED           // FVG equilibrado
};

// Estados do FVG
enum ENUM_FVG_STATE
{
    FVG_STATE_OPEN,             // Aberto
    FVG_STATE_PARTIAL_FILL,     // Parcialmente preenchido
    FVG_STATE_FILLED,           // Preenchido
    FVG_STATE_EXPIRED           // Expirado
};

// Tipos de Liquidez
enum ENUM_LIQUIDITY_TYPE
{
    LIQUIDITY_TYPE_BSL,         // Buy Side Liquidity
    LIQUIDITY_TYPE_SSL,         // Sell Side Liquidity
    LIQUIDITY_TYPE_EQH,         // Equal Highs
    LIQUIDITY_TYPE_EQL,         // Equal Lows
    LIQUIDITY_TYPE_POOL         // Liquidity Pool
};

// Estados da Liquidez
enum ENUM_LIQUIDITY_STATE
{
    LIQUIDITY_STATE_UNTAPPED,   // Não tocada
    LIQUIDITY_STATE_SWEPT,      // Varrida
    LIQUIDITY_STATE_PARTIAL,    // Parcialmente varrida
    LIQUIDITY_STATE_EXPIRED     // Expirada
};

// Estrutura de Mercado
enum ENUM_MARKET_STRUCTURE
{
    MS_BULLISH,                 // Estrutura de alta
    MS_BEARISH,                 // Estrutura de baixa
    MS_RANGING,                 // Lateral
    MS_TRANSITION,              // Transição
    MS_UNDEFINED                // Indefinida
};

// Tipos de Break of Structure
enum ENUM_BOS_TYPE
{
    BOS_TYPE_BULLISH,           // BOS de alta
    BOS_TYPE_BEARISH,           // BOS de baixa
    BOS_TYPE_CHOCH_BULLISH,     // CHoCH de alta
    BOS_TYPE_CHOCH_BEARISH      // CHoCH de baixa
};

// Métodos de Cálculo de Posição
enum ENUM_POSITION_SIZE_METHOD
{
    PSM_FIXED_LOT,              // Lote fixo
    PSM_FIXED_RISK,             // Risco fixo
    PSM_PERCENT_BALANCE,        // Percentual do saldo
    PSM_KELLY_CRITERION,        // Critério de Kelly
    PSM_VOLATILITY_ADJUSTED,    // Ajustado por volatilidade
    PSM_ATR_BASED               // Baseado no ATR
};

// Tipos de Alerta
enum ENUM_ALERT_TYPE
{
    ALERT_TYPE_INFO,            // Informação
    ALERT_TYPE_WARNING,         // Aviso
    ALERT_TYPE_ERROR,           // Erro
    ALERT_TYPE_TRADE,           // Trade
    ALERT_TYPE_RISK,            // Risco
    ALERT_TYPE_COMPLIANCE,      // Compliance
    ALERT_TYPE_SIGNAL,          // Sinal
    ALERT_TYPE_EMERGENCY        // Emergência
};

// Canais de Alerta
enum ENUM_ALERT_CHANNEL
{
    ALERT_CHANNEL_POPUP,        // Popup
    ALERT_CHANNEL_SOUND,        // Som
    ALERT_CHANNEL_EMAIL,        // Email
    ALERT_CHANNEL_PUSH,         // Push notification
    ALERT_CHANNEL_TELEGRAM,     // Telegram
    ALERT_CHANNEL_DISCORD,      // Discord
    ALERT_CHANNEL_SLACK,        // Slack
    ALERT_CHANNEL_SMS           // SMS
};

// Níveis de Log
enum ENUM_LOG_LEVEL
{
    LOG_LEVEL_TRACE = 0,        // Trace (mais detalhado)
    LOG_LEVEL_DEBUG = 1,        // Debug
    LOG_LEVEL_INFO = 2,         // Informação
    LOG_LEVEL_WARNING = 3,      // Aviso
    LOG_LEVEL_ERROR = 4,        // Erro
    LOG_LEVEL_FATAL = 5         // Fatal (menos detalhado)
};

// Tipos de Análise de Volume
enum ENUM_VOLUME_ANALYSIS_TYPE
{
    VOLUME_ANALYSIS_SPIKE,      // Spike de volume
    VOLUME_ANALYSIS_PROFILE,    // Perfil de volume
    VOLUME_ANALYSIS_FLOW,       // Fluxo de volume
    VOLUME_ANALYSIS_IMBALANCE,  // Desequilíbrio
    VOLUME_ANALYSIS_ACCUMULATION, // Acumulação
    VOLUME_ANALYSIS_DISTRIBUTION  // Distribuição
};
```

---

## ESTRUTURAS ICT/SMC

### Order Blocks
```mql5
//+------------------------------------------------------------------+
//|                    Estruturas ICT/SMC                            |
//+------------------------------------------------------------------+

// Estrutura de Order Block
struct SOrderBlock
{
    // Identificação
    int                     id;
    ENUM_ORDER_BLOCK_TYPE   type;
    ENUM_ORDER_BLOCK_STATE  state;
    
    // Localização
    datetime                formation_time;
    int                     formation_bar;
    double                  high_price;
    double                  low_price;
    double                  open_price;
    double                  close_price;
    
    // Propriedades
    double                  size_points;
    double                  strength;
    long                    volume;
    double                  body_percent;
    double                  wick_percent;
    
    // Validação
    bool                    is_valid;
    bool                    is_tested;
    bool                    is_mitigated;
    datetime                expiration_time;
    int                     test_count;
    
    // Níveis de Trading
    double                  entry_level;
    double                  stop_loss;
    double                  take_profit;
    double                  risk_reward_ratio;
    
    // Metadata
    string                  description;
    color                   display_color;
    bool                    show_on_chart;
    
    // Construtor
    SOrderBlock()
    {
        id = 0;
        type = OB_TYPE_BULLISH;
        state = OB_STATE_ACTIVE;
        formation_time = 0;
        formation_bar = 0;
        high_price = 0;
        low_price = 0;
        open_price = 0;
        close_price = 0;
        size_points = 0;
        strength = 0;
        volume = 0;
        body_percent = 0;
        wick_percent = 0;
        is_valid = false;
        is_tested = false;
        is_mitigated = false;
        expiration_time = 0;
        test_count = 0;
        entry_level = 0;
        stop_loss = 0;
        take_profit = 0;
        risk_reward_ratio = 0;
        description = "";
        display_color = clrNONE;
        show_on_chart = true;
    }
};

// Estrutura de Fair Value Gap
struct SFairValueGap
{
    // Identificação
    int                     id;
    ENUM_FVG_TYPE           type;
    ENUM_FVG_STATE          state;
    
    // Localização
    datetime                formation_time;
    int                     formation_bar;
    double                  high_level;
    double                  low_level;
    double                  mid_level;
    
    // Propriedades
    double                  size_points;
    double                  fill_percent;
    long                    volume_imbalance;
    double                  strength;
    
    // Validação
    bool                    is_valid;
    bool                    is_filled;
    datetime                expiration_time;
    datetime                fill_time;
    
    // Níveis de Trading
    double                  entry_level;
    double                  stop_loss;
    double                  take_profit;
    
    // Metadata
    string                  description;
    color                   display_color;
    bool                    show_on_chart;
    
    // Construtor
    SFairValueGap()
    {
        id = 0;
        type = FVG_TYPE_BULLISH;
        state = FVG_STATE_OPEN;
        formation_time = 0;
        formation_bar = 0;
        high_level = 0;
        low_level = 0;
        mid_level = 0;
        size_points = 0;
        fill_percent = 0;
        volume_imbalance = 0;
        strength = 0;
        is_valid = false;
        is_filled = false;
        expiration_time = 0;
        fill_time = 0;
        entry_level = 0;
        stop_loss = 0;
        take_profit = 0;
        description = "";
        display_color = clrNONE;
        show_on_chart = true;
    }
};

// Estrutura de Liquidez
struct SLiquidityZone
{
    // Identificação
    int                     id;
    ENUM_LIQUIDITY_TYPE     type;
    ENUM_LIQUIDITY_STATE    state;
    
    // Localização
    datetime                formation_time;
    int                     formation_bar;
    double                  price_level;
    double                  buffer_high;
    double                  buffer_low;
    
    // Propriedades
    double                  strength;
    int                     touch_count;
    long                    accumulated_volume;
    double                  liquidity_amount;
    
    // Validação
    bool                    is_valid;
    bool                    is_swept;
    datetime                expiration_time;
    datetime                sweep_time;
    
    // Níveis de Trading
    double                  entry_level;
    double                  stop_loss;
    double                  take_profit;
    
    // Metadata
    string                  description;
    color                   display_color;
    bool                    show_on_chart;
    
    // Construtor
    SLiquidityZone()
    {
        id = 0;
        type = LIQUIDITY_TYPE_BSL;
        state = LIQUIDITY_STATE_UNTAPPED;
        formation_time = 0;
        formation_bar = 0;
        price_level = 0;
        buffer_high = 0;
        buffer_low = 0;
        strength = 0;
        touch_count = 0;
        accumulated_volume = 0;
        liquidity_amount = 0;
        is_valid = false;
        is_swept = false;
        expiration_time = 0;
        sweep_time = 0;
        entry_level = 0;
        stop_loss = 0;
        take_profit = 0;
        description = "";
        display_color = clrNONE;
        show_on_chart = true;
    }
};

// Estrutura de Market Structure
struct SMarketStructureInfo
{
    // Estado Atual
    ENUM_MARKET_STRUCTURE   current_structure;
    ENUM_MARKET_STRUCTURE   previous_structure;
    datetime                last_change_time;
    
    // Swing Points
    double                  last_higher_high;
    double                  last_higher_low;
    double                  last_lower_high;
    double                  last_lower_low;
    datetime                hh_time;
    datetime                hl_time;
    datetime                lh_time;
    datetime                ll_time;
    
    // Break of Structure
    bool                    bos_detected;
    ENUM_BOS_TYPE           bos_type;
    double                  bos_level;
    datetime                bos_time;
    
    // Change of Character
    bool                    choch_detected;
    ENUM_BOS_TYPE           choch_type;
    double                  choch_level;
    datetime                choch_time;
    
    // Trend Information
    double                  trend_strength;
    int                     trend_duration_bars;
    double                  trend_angle;
    
    // Construtor
    SMarketStructureInfo()
    {
        current_structure = MS_UNDEFINED;
        previous_structure = MS_UNDEFINED;
        last_change_time = 0;
        last_higher_high = 0;
        last_higher_low = 0;
        last_lower_high = 0;
        last_lower_low = 0;
        hh_time = 0;
        hl_time = 0;
        lh_time = 0;
        ll_time = 0;
        bos_detected = false;
        bos_type = BOS_TYPE_BULLISH;
        bos_level = 0;
        bos_time = 0;
        choch_detected = false;
        choch_type = BOS_TYPE_BULLISH;
        choch_level = 0;
        choch_time = 0;
        trend_strength = 0;
        trend_duration_bars = 0;
        trend_angle = 0;
    }
};

// Configuração ICT
struct SICTConfig
{
    // Order Blocks
    bool                    use_order_blocks;
    int                     ob_lookback_bars;
    double                  ob_min_size_points;
    double                  ob_min_body_percent;
    double                  ob_max_wick_percent;
    int                     ob_validity_bars;
    int                     ob_volume_multiplier;
    
    // Fair Value Gaps
    bool                    use_fair_value_gaps;
    int                     fvg_lookback_bars;
    double                  fvg_min_size_points;
    int                     fvg_validity_bars;
    double                  fvg_fill_threshold;
    
    // Liquidity
    bool                    use_liquidity_analysis;
    int                     liquidity_lookback_bars;
    double                  liquidity_buffer_points;
    int                     liquidity_touch_threshold;
    double                  liquidity_strength_threshold;
    
    // Market Structure
    bool                    use_market_structure;
    int                     ms_lookback_bars;
    double                  bos_min_size_points;
    double                  choch_min_size_points;
    double                  swing_threshold_points;
    
    // Confluence
    bool                    require_confluence;
    int                     min_confluence_count;
    double                  confluence_weight_ob;
    double                  confluence_weight_fvg;
    double                  confluence_weight_liquidity;
    double                  confluence_weight_ms;
    
    // Display
    bool                    show_order_blocks;
    bool                    show_fair_value_gaps;
    bool                    show_liquidity_zones;
    bool                    show_market_structure;
    color                   color_bullish_ob;
    color                   color_bearish_ob;
    color                   color_bullish_fvg;
    color                   color_bearish_fvg;
    color                   color_bsl;
    color                   color_ssl;
    
    // Construtor
    SICTConfig()
    {
        use_order_blocks = true;
        ob_lookback_bars = 100;
        ob_min_size_points = 50;
        ob_min_body_percent = 70;
        ob_max_wick_percent = 30;
        ob_validity_bars = 50;
        ob_volume_multiplier = 2;
        
        use_fair_value_gaps = true;
        fvg_lookback_bars = 50;
        fvg_min_size_points = 20;
        fvg_validity_bars = 30;
        fvg_fill_threshold = 0.5;
        
        use_liquidity_analysis = true;
        liquidity_lookback_bars = 200;
        liquidity_buffer_points = 10;
        liquidity_touch_threshold = 3;
        liquidity_strength_threshold = 0.7;
        
        use_market_structure = true;
        ms_lookback_bars = 500;
        bos_min_size_points = 100;
        choch_min_size_points = 150;
        swing_threshold_points = 50;
        
        require_confluence = true;
        min_confluence_count = 2;
        confluence_weight_ob = 0.3;
        confluence_weight_fvg = 0.2;
        confluence_weight_liquidity = 0.3;
        confluence_weight_ms = 0.2;
        
        show_order_blocks = true;
        show_fair_value_gaps = true;
        show_liquidity_zones = true;
        show_market_structure = true;
        color_bullish_ob = clrBlue;
        color_bearish_ob = clrRed;
        color_bullish_fvg = clrGreen;
        color_bearish_fvg = clrOrange;
        color_bsl = clrPurple;
        color_ssl = clrMaroon;
    }
};
```

---

## ESTRUTURAS DE TRADING

### Informações de Trade
```mql5
//+------------------------------------------------------------------+
//|                    Estruturas de Trading                         |
//+------------------------------------------------------------------+

// Informação de Sinal
struct SSignalInfo
{
    // Identificação
    int                     signal_id;
    ENUM_SIGNAL_TYPE        signal_type;
    ENUM_SIGNAL_STRENGTH    signal_strength;
    
    // Timing
    datetime                signal_time;
    datetime                expiration_time;
    bool                    is_valid;
    bool                    is_executed;
    
    // Preços
    double                  entry_price;
    double                  stop_loss;
    double                  take_profit;
    double                  current_price;
    
    // Risk/Reward
    double                  risk_points;
    double                  reward_points;
    double                  risk_reward_ratio;
    double                  position_size;
    double                  risk_amount;
    
    // Confluence
    bool                    has_confluence;
    int                     confluence_count;
    string                  confluence_factors;
    double                  confluence_score;
    
    // Razão do Sinal
    string                  signal_reason;
    string                  setup_description;
    string                  market_context;
    
    // ICT Components
    bool                    has_order_block;
    bool                    has_fvg;
    bool                    has_liquidity;
    bool                    has_bos_choch;
    int                     ob_id;
    int                     fvg_id;
    int                     liquidity_id;
    
    // Construtor
    SSignalInfo()
    {
        signal_id = 0;
        signal_type = SIGNAL_NONE;
        signal_strength = SIGNAL_STRENGTH_WEAK;
        signal_time = 0;
        expiration_time = 0;
        is_valid = false;
        is_executed = false;
        entry_price = 0;
        stop_loss = 0;
        take_profit = 0;
        current_price = 0;
        risk_points = 0;
        reward_points = 0;
        risk_reward_ratio = 0;
        position_size = 0;
        risk_amount = 0;
        has_confluence = false;
        confluence_count = 0;
        confluence_factors = "";
        confluence_score = 0;
        signal_reason = "";
        setup_description = "";
        market_context = "";
        has_order_block = false;
        has_fvg = false;
        has_liquidity = false;
        has_bos_choch = false;
        ob_id = 0;
        fvg_id = 0;
        liquidity_id = 0;
    }
};

// Informação de Posição
struct SPositionInfo
{
    // Identificação
    ulong                   ticket;
    string                  symbol;
    ENUM_ORDER_TYPE         type;
    ulong                   magic_number;
    
    // Timing
    datetime                open_time;
    datetime                close_time;
    bool                    is_open;
    
    // Preços e Volume
    double                  open_price;
    double                  close_price;
    double                  current_price;
    double                  volume;
    double                  stop_loss;
    double                  take_profit;
    
    // P&L
    double                  profit;
    double                  swap;
    double                  commission;
    double                  net_profit;
    double                  profit_points;
    
    // Risk Management
    double                  risk_amount;
    double                  risk_percent;
    double                  max_adverse_excursion;
    double                  max_favorable_excursion;
    
    // Metadata
    string                  comment;
    string                  entry_reason;
    string                  exit_reason;
    int                     signal_id;
    
    // Construtor
    SPositionInfo()
    {
        ticket = 0;
        symbol = "";
        type = ORDER_TYPE_BUY;
        magic_number = 0;
        open_time = 0;
        close_time = 0;
        is_open = false;
        open_price = 0;
        close_price = 0;
        current_price = 0;
        volume = 0;
        stop_loss = 0;
        take_profit = 0;
        profit = 0;
        swap = 0;
        commission = 0;
        net_profit = 0;
        profit_points = 0;
        risk_amount = 0;
        risk_percent = 0;
        max_adverse_excursion = 0;
        max_favorable_excursion = 0;
        comment = "";
        entry_reason = "";
        exit_reason = "";
        signal_id = 0;
    }
};

// Informação de Trade Completo
struct STradeInfo
{
    // Posição Base
    SPositionInfo           position;
    
    // Análise de Performance
    double                  r_multiple;
    double                  hold_time_minutes;
    bool                    was_winner;
    bool                    hit_stop_loss;
    bool                    hit_take_profit;
    bool                    manual_close;
    
    // Contexto de Mercado
    double                  atr_at_entry;
    double                  volatility_at_entry;
    ENUM_MARKET_STRUCTURE   market_structure_at_entry;
    double                  spread_at_entry;
    
    // Qualidade do Setup
    double                  setup_quality_score;
    int                     confluence_factors_count;
    string                  setup_type;
    
    // Lições Aprendidas
    string                  trade_notes;
    string                  improvement_notes;
    int                     trade_rating; // 1-10
    
    // Construtor
    STradeInfo()
    {
        r_multiple = 0;
        hold_time_minutes = 0;
        was_winner = false;
        hit_stop_loss = false;
        hit_take_profit = false;
        manual_close = false;
        atr_at_entry = 0;
        volatility_at_entry = 0;
        market_structure_at_entry = MS_UNDEFINED;
        spread_at_entry = 0;
        setup_quality_score = 0;
        confluence_factors_count = 0;
        setup_type = "";
        trade_notes = "";
        improvement_notes = "";
        trade_rating = 5;
    }
};

// Configuração de Trading
struct STradingConfig
{
    // Configurações Gerais
    bool                    trading_enabled;
    ulong                   magic_number;
    string                  comment_prefix;
    int                     max_slippage;
    bool                    ecn_mode;
    
    // Gestão de Posições
    int                     max_positions;
    int                     max_daily_trades;
    double                  min_lot_size;
    double                  max_lot_size;
    double                  lot_step;
    
    // Stop Loss e Take Profit
    bool                    use_dynamic_sl;
    bool                    use_dynamic_tp;
    double                  default_sl_points;
    double                  default_tp_points;
    double                  min_rr_ratio;
    double                  max_rr_ratio;
    
    // Trailing Stop
    bool                    use_trailing_stop;
    double                  trailing_start_points;
    double                  trailing_step_points;
    double                  trailing_stop_points;
    
    // Partial Close
    bool                    use_partial_close;
    double                  partial_close_percent;
    double                  partial_close_rr;
    bool                    move_sl_to_be;
    
    // Filtros de Tempo
    bool                    use_time_filter;
    int                     start_hour;
    int                     end_hour;
    bool                    trade_monday;
    bool                    trade_tuesday;
    bool                    trade_wednesday;
    bool                    trade_thursday;
    bool                    trade_friday;
    bool                    avoid_news;
    int                     news_buffer_minutes;
    
    // Construtor
    STradingConfig()
    {
        trading_enabled = true;
        magic_number = 123456;
        comment_prefix = "FTMO_Scalper_";
        max_slippage = 3;
        ecn_mode = false;
        max_positions = 1;
        max_daily_trades = 10;
        min_lot_size = 0.01;
        max_lot_size = 1.0;
        lot_step = 0.01;
        use_dynamic_sl = true;
        use_dynamic_tp = true;
        default_sl_points = 200;
        default_tp_points = 400;
        min_rr_ratio = 1.5;
        max_rr_ratio = 5.0;
        use_trailing_stop = true;
        trailing_start_points = 200;
        trailing_step_points = 50;
        trailing_stop_points = 100;
        use_partial_close = true;
        partial_close_percent = 50;
        partial_close_rr = 2.0;
        move_sl_to_be = true;
        use_time_filter = true;
        start_hour = 8;
        end_hour = 18;
        trade_monday = true;
        trade_tuesday = true;
        trade_wednesday = true;
        trade_thursday = true;
        trade_friday = true;
        avoid_news = true;
        news_buffer_minutes = 30;
    }
};
```

---

## ESTRUTURAS DE RISCO

### Gestão de Risco
```mql5
//+------------------------------------------------------------------+
//|                     Estruturas de Risco                          |
//+------------------------------------------------------------------+

// Configuração de Risco
struct SRiskConfig
{
    // Risco por Trade
    double                  risk_percent_per_trade;
    double                  max_risk_amount_per_trade;
    ENUM_POSITION_SIZE_METHOD position_size_method;
    
    // Limites Diários
    double                  max_daily_risk_percent;
    double                  max_daily_loss_amount;
    int                     max_daily_trades;
    int                     max_consecutive_losses;
    
    // Limites Semanais
    double                  max_weekly_risk_percent;
    double                  max_weekly_loss_amount;
    int                     max_weekly_trades;
    
    // Limites Mensais
    double                  max_monthly_risk_percent;
    double                  max_monthly_loss_amount;
    int                     max_monthly_trades;
    
    // Drawdown
    double                  max_drawdown_percent;
    double                  max_drawdown_amount;
    double                  daily_drawdown_limit;
    bool                    auto_stop_on_drawdown;
    
    // Correlação
    bool                    use_correlation_check;
    double                  max_correlation_threshold;
    int                     correlation_lookback_days;
    
    // Kelly Criterion
    bool                    use_kelly_criterion;
    double                  kelly_multiplier;
    int                     kelly_lookback_trades;
    double                  max_kelly_fraction;
    
    // Volatilidade
    bool                    adjust_for_volatility;
    int                     volatility_period;
    double                  volatility_multiplier;
    double                  max_volatility_threshold;
    
    // Proteções
    bool                    use_equity_protection;
    double                  equity_protection_percent;
    bool                    use_time_based_stops;
    int                     max_hold_time_minutes;
    
    // Construtor
    SRiskConfig()
    {
        risk_percent_per_trade = 1.0;
        max_risk_amount_per_trade = 1000;
        position_size_method = PSM_FIXED_RISK;
        max_daily_risk_percent = 5.0;
        max_daily_loss_amount = 5000;
        max_daily_trades = 10;
        max_consecutive_losses = 3;
        max_weekly_risk_percent = 10.0;
        max_weekly_loss_amount = 10000;
        max_weekly_trades = 50;
        max_monthly_risk_percent = 20.0;
        max_monthly_loss_amount = 20000;
        max_monthly_trades = 200;
        max_drawdown_percent = 10.0;
        max_drawdown_amount = 10000;
        daily_drawdown_limit = 5.0;
        auto_stop_on_drawdown = true;
        use_correlation_check = true;
        max_correlation_threshold = 0.7;
        correlation_lookback_days = 30;
        use_kelly_criterion = false;
        kelly_multiplier = 0.25;
        kelly_lookback_trades = 50;
        max_kelly_fraction = 0.25;
        adjust_for_volatility = true;
        volatility_period = 14;
        volatility_multiplier = 1.5;
        max_volatility_threshold = 2.0;
        use_equity_protection = true;
        equity_protection_percent = 95.0;
        use_time_based_stops = false;
        max_hold_time_minutes = 240;
    }
};

// Métricas de Risco
struct SRiskMetrics
{
    // Exposição Atual
    double                  current_risk_exposure;
    double                  current_risk_percent;
    int                     open_positions_count;
    double                  total_position_value;
    
    // Drawdown
    double                  current_drawdown;
    double                  current_drawdown_percent;
    double                  max_drawdown;
    double                  max_drawdown_percent;
    datetime                max_drawdown_date;
    
    // P&L Tracking
    double                  daily_pnl;
    double                  weekly_pnl;
    double                  monthly_pnl;
    double                  ytd_pnl;
    double                  peak_balance;
    double                  current_balance;
    
    // Trade Statistics
    int                     daily_trades_count;
    int                     weekly_trades_count;
    int                     monthly_trades_count;
    int                     consecutive_losses;
    int                     consecutive_wins;
    
    // Risk Ratios
    double                  sharpe_ratio;
    double                  sortino_ratio;
    double                  calmar_ratio;
    double                  var_95;
    double                  expected_shortfall;
    
    // Kelly Criterion
    double                  kelly_fraction;
    double                  optimal_f;
    double                  win_rate;
    double                  avg_win_loss_ratio;
    
    // Volatilidade
    double                  portfolio_volatility;
    double                  beta;
    double                  correlation_to_market;
    
    // Timestamps
    datetime                last_update_time;
    datetime                daily_reset_time;
    datetime                weekly_reset_time;
    datetime                monthly_reset_time;
    
    // Construtor
    SRiskMetrics()
    {
        current_risk_exposure = 0;
        current_risk_percent = 0;
        open_positions_count = 0;
        total_position_value = 0;
        current_drawdown = 0;
        current_drawdown_percent = 0;
        max_drawdown = 0;
        max_drawdown_percent = 0;
        max_drawdown_date = 0;
        daily_pnl = 0;
        weekly_pnl = 0;
        monthly_pnl = 0;
        ytd_pnl = 0;
        peak_balance = 0;
        current_balance = 0;
        daily_trades_count = 0;
        weekly_trades_count = 0;
        monthly_trades_count = 0;
        consecutive_losses = 0;
        consecutive_wins = 0;
        sharpe_ratio = 0;
        sortino_ratio = 0;
        calmar_ratio = 0;
        var_95 = 0;
        expected_shortfall = 0;
        kelly_fraction = 0;
        optimal_f = 0;
        win_rate = 0;
        avg_win_loss_ratio = 0;
        portfolio_volatility = 0;
        beta = 0;
        correlation_to_market = 0;
        last_update_time = 0;
        daily_reset_time = 0;
        weekly_reset_time = 0;
        monthly_reset_time = 0;
    }
};
```

---

## ESTRUTURAS DE COMPLIANCE

### FTMO Compliance
```mql5
//+------------------------------------------------------------------+
//|                   Estruturas de Compliance                       |
//+------------------------------------------------------------------+

// Configuração de Compliance
struct SComplianceConfig
{
    // Tipo de Conta
    bool                    is_ftmo_account;
    bool                    is_challenge_phase;
    bool                    is_verification_phase;
    bool                    is_funded_phase;
    
    // Limites FTMO
    double                  account_size;
    double                  daily_loss_limit;
    double                  max_drawdown_limit;
    double                  profit_target;
    
    // Regras de Trading
    int                     min_trading_days;
    int                     max_trading_days;
    bool                    consistency_rule;
    double                  max_daily_profit_percent;
    
    // Restrições
    bool                    weekend_holding_allowed;
    bool                    news_trading_allowed;
    bool                    ea_trading_allowed;
    bool                    hedging_allowed;
    
    // Configurações de Segurança
    double                  safety_buffer_percent;
    bool                    auto_stop_on_violation;
    bool                    strict_compliance_mode;
    bool                    send_compliance_alerts;
    
    // Construtor
    SComplianceConfig()
    {
        is_ftmo_account = true;
        is_challenge_phase = true;
        is_verification_phase = false;
        is_funded_phase = false;
        account_size = 100000;
        daily_loss_limit = 5000;
        max_drawdown_limit = 10000;
        profit_target = 10000;
        min_trading_days = 4;
        max_trading_days = 30;
        consistency_rule = true;
        max_daily_profit_percent = 5.0;
        weekend_holding_allowed = false;
        news_trading_allowed = false;
        ea_trading_allowed = true;
        hedging_allowed = false;
        safety_buffer_percent = 20.0;
        auto_stop_on_violation = true;
        strict_compliance_mode = true;
        send_compliance_alerts = true;
    }
};

// Estado de Compliance
struct SComplianceState
{
    // Status Geral
    bool                    is_compliant;
    bool                    trading_allowed;
    datetime                last_check_time;
    
    // Tracking de Saldo
    double                  initial_balance;
    double                  peak_balance;
    double                  current_balance;
    double                  daily_start_balance;
    
    // P&L Tracking
    double                  daily_pnl;
    double                  daily_pnl_percent;
    double                  total_pnl;
    double                  total_pnl_percent;
    
    // Drawdown Tracking
    double                  current_drawdown;
    double                  current_drawdown_percent;
    double                  max_drawdown;
    double                  max_drawdown_percent;
    
    // Trading Days
    int                     trading_days_count;
    int                     remaining_days;
    datetime                challenge_start_date;
    datetime                last_trading_day;
    
    // Profit Target
    double                  progress_to_target;
    double                  progress_percent;
    bool                    target_reached;
    datetime                target_reached_date;
    
    // Violations
    bool                    has_violations;
    int                     violation_count;
    string                  last_violation;
    datetime                last_violation_time;
    
    // Consistency Rule
    double                  best_day_profit;
    double                  consistency_threshold;
    bool                    consistency_violated;
    
    // Construtor
    SComplianceState()
    {
        is_compliant = true;
        trading_allowed = true;
        last_check_time = 0;
        initial_balance = 0;
        peak_balance = 0;
        current_balance = 0;
        daily_start_balance = 0;
        daily_pnl = 0;
        daily_pnl_percent = 0;
        total_pnl = 0;
        total_pnl_percent = 0;
        current_drawdown = 0;
        current_drawdown_percent = 0;
        max_drawdown = 0;
        max_drawdown_percent = 0;
        trading_days_count = 0;
        remaining_days = 0;
        challenge_start_date = 0;
        last_trading_day = 0;
        progress_to_target = 0;
        progress_percent = 0;
        target_reached = false;
        target_reached_date = 0;
        has_violations = false;
        violation_count = 0;
        last_violation = "";
        last_violation_time = 0;
        best_day_profit = 0;
        consistency_threshold = 0;
        consistency_violated = false;
    }
};
```

---

## ESTRUTURAS DE VOLUME

### Análise de Volume
```mql5
//+------------------------------------------------------------------+
//|                    Estruturas de Volume                          |
//+------------------------------------------------------------------+

// Configuração de Volume
struct SVolumeConfig
{
    // Volume Spike Detection
    bool                    detect_volume_spikes;
    double                  spike_threshold_multiplier;
    int                     spike_ma_period;
    int                     spike_lookback_bars;
    
    // Volume Profile
    bool                    use_volume_profile;
    int                     vp_lookback_bars;
    int                     vp_price_levels;
    double                  value_area_percent;
    
    // Volume Flow
    bool                    analyze_volume_flow;
    int                     flow_period;
    double                  flow_threshold;
    
    // Volume Indicators
    bool                    use_volume_ma;
    int                     volume_ma_period;
    bool                    use_volume_ratio;
    int                     volume_ratio_period;
    
    // VWAP
    bool                    use_vwap;
    ENUM_TIMEFRAMES         vwap_timeframe;
    bool                    use_vwap_bands;
    double                  vwap_deviation;
    
    // Display
    bool                    show_volume_profile;
    bool                    show_poc_line;
    bool                    show_value_area;
    bool                    show_volume_spikes;
    color                   color_volume_profile;
    color                   color_poc;
    color                   color_value_area;
    color                   color_volume_spike;
    
    // Construtor
    SVolumeConfig()
    {
        detect_volume_spikes = true;
        spike_threshold_multiplier = 2.0;
        spike_ma_period = 20;
        spike_lookback_bars = 100;
        use_volume_profile = true;
        vp_lookback_bars = 100;
        vp_price_levels = 50;
        value_area_percent = 70.0;
        analyze_volume_flow = true;
        flow_period = 14;
        flow_threshold = 1.5;
        use_volume_ma = true;
        volume_ma_period = 20;
        use_volume_ratio = true;
        volume_ratio_period = 10;
        use_vwap = true;
        vwap_timeframe = PERIOD_D1;
        use_vwap_bands = true;
        vwap_deviation = 2.0;
        show_volume_profile = true;
        show_poc_line = true;
        show_value_area = true;
        show_volume_spikes = true;
        color_volume_profile = clrGray;
        color_poc = clrYellow;
        color_value_area = clrLightGray;
        color_volume_spike = clrRed;
    }
};

// Dados de Volume Profile
struct SVolumeProfileData
{
    // Price Levels
    double                  price_levels[];
    long                    volume_at_price[];
    double                  percentage_at_price[];
    
    // Key Levels
    double                  poc_price;          // Point of Control
    long                    poc_volume;
    double                  vah_price;          // Value Area High
    double                  val_price;          // Value Area Low
    double                  value_area_volume_percent;
    
    // Statistics
    long                    total_volume;
    double                  price_range;
    double                  volume_weighted_price;
    int                     profile_bars_count;
    
    // Timestamps
    datetime                start_time;
    datetime                end_time;
    datetime                last_update;
    
    // Construtor
    SVolumeProfileData()
    {
        poc_price = 0;
        poc_volume = 0;
        vah_price = 0;
        val_price = 0;
        value_area_volume_percent = 0;
        total_volume = 0;
        price_range = 0;
        volume_weighted_price = 0;
        profile_bars_count = 0;
        start_time = 0;
        end_time = 0;
        last_update = 0;
    }
};

// Volume Spike
struct SVolumeSpike
{
    // Identificação
    int                     spike_id;
    datetime                spike_time;
    int                     spike_bar;
    
    // Volume Data
    long                    spike_volume;
    long                    average_volume;
    double                  volume_ratio;
    double                  spike_strength;
    
    // Price Data
    double                  spike_price;
    double                  spike_high;
    double                  spike_low;
    double                  price_move;
    
    // Classification
    bool                    is_buying_spike;
    bool                    is_selling_spike;
    bool                    is_breakout_spike;
    bool                    is_reversal_spike;
    
    // Validation
    bool                    is_valid;
    bool                    is_confirmed;
    datetime                expiration_time;
    
    // Construtor
    SVolumeSpike()
    {
        spike_id = 0;
        spike_time = 0;
        spike_bar = 0;
        spike_volume = 0;
        average_volume = 0;
        volume_ratio = 0;
        spike_strength = 0;
        spike_price = 0;
        spike_high = 0;
        spike_low = 0;
        price_move = 0;
        is_buying_spike = false;
        is_selling_spike = false;
        is_breakout_spike = false;
        is_reversal_spike = false;
        is_valid = false;
        is_confirmed = false;
        expiration_time = 0;
    }
};

// Métricas de Volume
struct SVolumeMetrics
{
    // Volume Médio
    double                  avg_volume_1h;
    double                  avg_volume_4h;
    double                  avg_volume_1d;
    double                  avg_volume_1w;
    
    // Volume Atual vs Médio
    double                  current_volume_ratio;
    double                  volume_trend;
    
    // Volume Profile Metrics
    double                  poc_strength;
    double                  value_area_strength;
    double                  volume_imbalance;
    
    // Flow Metrics
    double                  buying_pressure;
    double                  selling_pressure;
    double                  net_volume_flow;
    double                  volume_momentum;
    
    // VWAP Metrics
    double                  vwap_price;
    double                  vwap_deviation;
    double                  vwap_slope;
    
    // Timestamps
    datetime                last_calculation;
    
    // Construtor
    SVolumeMetrics()
    {
        avg_volume_1h = 0;
        avg_volume_4h = 0;
        avg_volume_1d = 0;
        avg_volume_1w = 0;
        current_volume_ratio = 0;
        volume_trend = 0;
        poc_strength = 0;
        value_area_strength = 0;
        volume_imbalance = 0;
        buying_pressure = 0;
        selling_pressure = 0;
        net_volume_flow = 0;
        volume_momentum = 0;
        vwap_price = 0;
        vwap_deviation = 0;
        vwap_slope = 0;
        last_calculation = 0;
    }
};
```

---

## ESTRUTURAS DE ALERTAS

### Sistema de Alertas
```mql5
//+------------------------------------------------------------------+
//|                    Estruturas de Alertas                         |
//+------------------------------------------------------------------+

// Configuração de Alertas
struct SAlertConfig
{
    // Configuração Geral
    bool                    enabled;
    bool                    sound_alerts;
    bool                    popup_alerts;
    bool                    email_alerts;
    bool                    push_notifications;
    
    // Alertas Externos
    bool                    telegram_alerts;
    string                  telegram_bot_token;
    string                  telegram_chat_id;
    bool                    discord_alerts;
    string                  discord_webhook;
    bool                    slack_alerts;
    string                  slack_webhook;
    
    // Filtros de Alerta
    bool                    alert_on_signals;
    bool                    alert_on_trades;
    bool                    alert_on_risk_events;
    bool                    alert_on_compliance;
    bool                    alert_on_errors;
    
    // Configurações de Som
    string                  sound_file_signal;
    string                  sound_file_trade;
    string                  sound_file_risk;
    string                  sound_file_error;
    
    // Rate Limiting
    int                     max_alerts_per_minute;
    int                     max_alerts_per_hour;
    bool                    suppress_duplicate_alerts;
    int                     duplicate_suppression_minutes;
    
    // Construtor
    SAlertConfig()
    {
        enabled = true;
        sound_alerts = true;
        popup_alerts = true;
        email_alerts = false;
        push_notifications = true;
        telegram_alerts = false;
        telegram_bot_token = "";
        telegram_chat_id = "";
        discord_alerts = false;
        discord_webhook = "";
        slack_alerts = false;
        slack_webhook = "";
        alert_on_signals = true;
        alert_on_trades = true;
        alert_on_risk_events = true;
        alert_on_compliance = true;
        alert_on_errors = true;
        sound_file_signal = "alert.wav";
        sound_file_trade = "trade.wav";
        sound_file_risk = "risk.wav";
        sound_file_error = "error.wav";
        max_alerts_per_minute = 10;
        max_alerts_per_hour = 100;
        suppress_duplicate_alerts = true;
        duplicate_suppression_minutes = 5;
    }
};

// Estrutura de Alerta
struct SAlert
{
    // Identificação
    int                     alert_id;
    ENUM_ALERT_TYPE         alert_type;
    datetime                alert_time;
    
    // Conteúdo
    string                  title;
    string                  message;
    string                  details;
    
    // Prioridade
    int                     priority; // 1-10
    bool                    is_urgent;
    bool                    requires_action;
    
    // Canais
    bool                    send_popup;
    bool                    send_sound;
    bool                    send_email;
    bool                    send_push;
    bool                    send_telegram;
    bool                    send_discord;
    bool                    send_slack;
    
    // Status
    bool                    is_sent;
    bool                    is_acknowledged;
    datetime                sent_time;
    datetime                acknowledged_time;
    
    // Metadata
    string                  source_component;
    string                  error_code;
    double                  related_price;
    string                  related_symbol;
    
    // Construtor
    SAlert()
    {
        alert_id = 0;
        alert_type = ALERT_TYPE_INFO;
        alert_time = 0;
        title = "";
        message = "";
        details = "";
        priority = 5;
        is_urgent = false;
        requires_action = false;
        send_popup = true;
        send_sound = true;
        send_email = false;
        send_push = false;
        send_telegram = false;
        send_discord = false;
        send_slack = false;
        is_sent = false;
        is_acknowledged = false;
        sent_time = 0;
        acknowledged_time = 0;
        source_component = "";
        error_code = "";
        related_price = 0;
        related_symbol = "";
    }
};
```

---

## ESTRUTURAS DE LOGGING

### Sistema de Logging
```mql5
//+------------------------------------------------------------------+
//|                    Estruturas de Logging                         |
//+------------------------------------------------------------------+

// Entrada de Log
struct SLogEntry
{
    // Identificação
    int                     log_id;
    ENUM_LOG_LEVEL          log_level;
    datetime                timestamp;
    
    // Conteúdo
    string                  component;
    string                  function_name;
    string                  message;
    string                  details;
    
    // Contexto
    string                  symbol;
    ENUM_TIMEFRAMES         timeframe;
    double                  price;
    long                    ticket;
    
    // Error Information
    int                     error_code;
    string                  error_description;
    string                  stack_trace;
    
    // Performance
    ulong                   execution_time_ms;
    ulong                   memory_usage;
    
    // Construtor
    SLogEntry()
    {
        log_id = 0;
        log_level = LOG_LEVEL_INFO;
        timestamp = 0;
        component = "";
        function_name = "";
        message = "";
        details = "";
        symbol = "";
        timeframe = PERIOD_CURRENT;
        price = 0;
        ticket = 0;
        error_code = 0;
        error_description = "";
        stack_trace = "";
        execution_time_ms = 0;
        memory_usage = 0;
    }
};
```

---

## ESTRUTURAS DE PERFORMANCE

### Métricas de Performance
```mql5
//+------------------------------------------------------------------+
//|                  Estruturas de Performance                       |
//+------------------------------------------------------------------+

// Métricas de Performance Completas
struct SPerformanceMetrics
{
    // P&L Básico
    double                  total_profit;
    double                  total_loss;
    double                  net_profit;
    double                  gross_profit;
    double                  gross_loss;
    
    // Ratios Fundamentais
    double                  profit_factor;
    double                  recovery_factor;
    double                  payoff_ratio;
    double                  win_rate;
    double                  loss_rate;
    
    // Risk-Adjusted Returns
    double                  sharpe_ratio;
    double                  sortino_ratio;
    double                  calmar_ratio;
    double                  sterling_ratio;
    double                  burke_ratio;
    
    // Drawdown Analysis
    double                  max_drawdown;
    double                  max_drawdown_percent;
    double                  avg_drawdown;
    double                  max_drawdown_duration;
    datetime                max_drawdown_date;
    
    // Trade Statistics
    int                     total_trades;
    int                     winning_trades;
    int                     losing_trades;
    double                  avg_trade;
    double                  avg_win;
    double                  avg_loss;
    double                  largest_win;
    double                  largest_loss;
    
    // Consecutive Analysis
    int                     max_consecutive_wins;
    int                     max_consecutive_losses;
    int                     current_consecutive_wins;
    int                     current_consecutive_losses;
    
    // Time Analysis
    double                  avg_trade_duration;
    double                  avg_win_duration;
    double                  avg_loss_duration;
    double                  max_trade_duration;
    double                  min_trade_duration;
    
    // Monthly Performance
    double                  monthly_returns[];
    double                  monthly_volatility;
    double                  best_month;
    double                  worst_month;
    double                  avg_monthly_return;
    
    // Risk Metrics
    double                  var_95;
    double                  var_99;
    double                  expected_shortfall;
    double                  maximum_adverse_excursion;
    double                  maximum_favorable_excursion;
    
    // Efficiency Metrics
    double                  profit_per_day;
    double                  trades_per_day;
    double                  profit_per_trade;
    double                  return_on_account;
    
    // Timestamps
    datetime                calculation_start;
    datetime                calculation_end;
    datetime                last_update;
    
    // Construtor
    SPerformanceMetrics()
    {
        total_profit = 0;
        total_loss = 0;
        net_profit = 0;
        gross_profit = 0;
        gross_loss = 0;
        profit_factor = 0;
        recovery_factor = 0;
        payoff_ratio = 0;
        win_rate = 0;
        loss_rate = 0;
        sharpe_ratio = 0;
        sortino_ratio = 0;
        calmar_ratio = 0;
        sterling_ratio = 0;
        burke_ratio = 0;
        max_drawdown = 0;
        max_drawdown_percent = 0;
        avg_drawdown = 0;
        max_drawdown_duration = 0;
        max_drawdown_date = 0;
        total_trades = 0;
        winning_trades = 0;
        losing_trades = 0;
        avg_trade = 0;
        avg_win = 0;
        avg_loss = 0;
        largest_win = 0;
        largest_loss = 0;
        max_consecutive_wins = 0;
        max_consecutive_losses = 0;
        current_consecutive_wins = 0;
        current_consecutive_losses = 0;
        avg_trade_duration = 0;
        avg_win_duration = 0;
        avg_loss_duration = 0;
        max_trade_duration = 0;
        min_trade_duration = 0;
        monthly_volatility = 0;
        best_month = 0;
        worst_month = 0;
        avg_monthly_return = 0;
        var_95 = 0;
        var_99 = 0;
        expected_shortfall = 0;
        maximum_adverse_excursion = 0;
        maximum_favorable_excursion = 0;
        profit_per_day = 0;
        trades_per_day = 0;
        profit_per_trade = 0;
        return_on_account = 0;
        calculation_start = 0;
        calculation_end = 0;
        last_update = 0;
    }
};
```

---

## ESTRUTURAS DE CONFIGURAÇÃO

### Configuração Principal do Sistema
```mql5
//+------------------------------------------------------------------+
//|                 Estruturas de Configuração                       |
//+------------------------------------------------------------------+

// Configuração Principal do EA
struct SEAConfig
{
    // Informações Básicas
    string                  ea_name;
    string                  ea_version;
    string                  ea_description;
    ulong                   magic_number;
    
    // Configurações de Trading
    STradingConfig          trading;
    SRiskConfig             risk;
    SComplianceConfig       compliance;
    SICTConfig              ict;
    SVolumeConfig           volume;
    
    // Configurações de Sistema
    SAlertConfig            alerts;
    ENUM_LOG_LEVEL          log_level;
    bool                    debug_mode;
    bool                    test_mode;
    
    // Performance
    bool                    enable_optimization;
    bool                    use_cache;
    int                     cache_size;
    bool                    multi_threading;
    
    // Construtor
    SEAConfig()
    {
        ea_name = "EA FTMO Scalper Elite";
        ea_version = "1.0.0";
        ea_description = "Advanced ICT/SMC Scalping EA for FTMO";
        magic_number = 123456789;
        log_level = LOG_LEVEL_INFO;
        debug_mode = false;
        test_mode = false;
        enable_optimization = true;
        use_cache = true;
        cache_size = 1000;
        multi_threading = false;
    }
};
```

---

## ESTRUTURAS AUXILIARES

### Estruturas de Cache e Otimização
```mql5
//+------------------------------------------------------------------+
//|                   Estruturas Auxiliares                          |
//+------------------------------------------------------------------+

// Cache de Dados
struct SCacheEntry
{
    string                  key;
    string                  data;
    datetime                timestamp;
    datetime                expiry_time;
    bool                    is_valid;
    int                     access_count;
    
    // Construtor
    SCacheEntry()
    {
        key = "";
        data = "";
        timestamp = 0;
        expiry_time = 0;
        is_valid = false;
        access_count = 0;
    }
};

// Informações de Símbolo
struct SSymbolInfo
{
    string                  symbol;
    double                  point;
    int                     digits;
    double                  tick_size;
    double                  tick_value;
    double                  contract_size;
    double                  margin_required;
    double                  spread;
    double                  swap_long;
    double                  swap_short;
    bool                    trade_allowed;
    datetime                last_update;
    
    // Construtor
    SSymbolInfo()
    {
        symbol = "";
        point = 0;
        digits = 0;
        tick_size = 0;
        tick_value = 0;
        contract_size = 0;
        margin_required = 0;
        spread = 0;
        swap_long = 0;
        swap_short = 0;
        trade_allowed = false;
        last_update = 0;
    }
};

// Estatísticas de Execução
struct SExecutionStats
{
    ulong                   total_executions;
    ulong                   total_execution_time;
    ulong                   min_execution_time;
    ulong                   max_execution_time;
    double                  avg_execution_time;
    ulong                   last_execution_time;
    datetime                last_execution_timestamp;
    
    // Construtor
    SExecutionStats()
    {
        total_executions = 0;
        total_execution_time = 0;
        min_execution_time = ULONG_MAX;
        max_execution_time = 0;
        avg_execution_time = 0;
        last_execution_time = 0;
        last_execution_timestamp = 0;
    }
};
```

---

## CONSTANTES DO SISTEMA

### Constantes Principais
```mql5
//+------------------------------------------------------------------+
//|                    Constantes do Sistema                         |
//+------------------------------------------------------------------+

// Versão e Identificação
#define EA_NAME                 "EA FTMO Scalper Elite"
#define EA_VERSION              "1.0.0"
#define EA_MAGIC_BASE           123456000
#define EA_COPYRIGHT            "© 2024 TradeDev_Master"

// Limites do Sistema
#define MAX_POSITIONS           10
#define MAX_PENDING_ORDERS      20
#define MAX_ORDER_BLOCKS        100
#define MAX_FAIR_VALUE_GAPS     50
#define MAX_LIQUIDITY_ZONES     50
#define MAX_ALERTS_QUEUE        1000
#define MAX_LOG_ENTRIES         10000
#define MAX_CACHE_ENTRIES       1000

// Timeouts e Intervalos
#define ORDER_TIMEOUT_MS        5000
#define PRICE_UPDATE_INTERVAL   100
#define RISK_CHECK_INTERVAL     1000
#define COMPLIANCE_CHECK_INTERVAL 5000
#define PERFORMANCE_CALC_INTERVAL 60000
#define CACHE_CLEANUP_INTERVAL  300000

// Tolerâncias e Precisão
#define PRICE_TOLERANCE         0.00001
#define VOLUME_TOLERANCE        0.01
#define TIME_TOLERANCE          1
#define CALCULATION_PRECISION   8

// Arquivos e Caminhos
#define LOG_FILE_PATH           "Files\\EA_FTMO_Scalper_Elite\\Logs\\"
#define CONFIG_FILE_PATH        "Files\\EA_FTMO_Scalper_Elite\\Config\\"
#define DATA_FILE_PATH          "Files\\EA_FTMO_Scalper_Elite\\Data\\"
#define BACKUP_FILE_PATH        "Files\\EA_FTMO_Scalper_Elite\\Backup\\"

// Cores Padrão
#define COLOR_BULLISH_OB        clrDodgerBlue
#define COLOR_BEARISH_OB        clrCrimson
#define COLOR_BULLISH_FVG       clrLimeGreen
#define COLOR_BEARISH_FVG       clrOrange
#define COLOR_BSL               clrMediumOrchid
#define COLOR_SSL               clrIndianRed
#define COLOR_POC               clrGold
#define COLOR_VALUE_AREA        clrLightGray
#define COLOR_VOLUME_SPIKE      clrRed

// Strings de Formatação
#define FORMAT_PRICE            "%.5f"
#define FORMAT_VOLUME           "%.2f"
#define FORMAT_PERCENT          "%.2f%%"
#define FORMAT_DATETIME         "%Y.%m.%d %H:%M:%S"

// Mensagens Padrão
#define MSG_EA_INIT_SUCCESS     "EA inicializado com sucesso"
#define MSG_EA_INIT_FAILED      "Falha na inicialização do EA"
#define MSG_TRADING_ENABLED     "Trading habilitado"
#define MSG_TRADING_DISABLED    "Trading desabilitado"
#define MSG_COMPLIANCE_VIOLATION "Violação de compliance detectada"
#define MSG_RISK_LIMIT_EXCEEDED "Limite de risco excedido"
#define MSG_EMERGENCY_STOP      "Parada de emergência ativada"

// Códigos de Erro Customizados
#define ERR_CUSTOM_BASE         10000
#define ERR_INVALID_CONFIG      (ERR_CUSTOM_BASE + 1)
#define ERR_COMPLIANCE_VIOLATION (ERR_CUSTOM_BASE + 2)
#define ERR_RISK_LIMIT_EXCEEDED (ERR_CUSTOM_BASE + 3)
#define ERR_INSUFFICIENT_MARGIN (ERR_CUSTOM_BASE + 4)
#define ERR_INVALID_SIGNAL      (ERR_CUSTOM_BASE + 5)
#define ERR_ORDER_BLOCK_INVALID (ERR_CUSTOM_BASE + 6)
#define ERR_FVG_INVALID         (ERR_CUSTOM_BASE + 7)
#define ERR_LIQUIDITY_INVALID   (ERR_CUSTOM_BASE + 8)
#define ERR_VOLUME_DATA_INVALID (ERR_CUSTOM_BASE + 9)
#define ERR_CACHE_FULL          (ERR_CUSTOM_BASE + 10)

// Configurações FTMO
#define FTMO_CHALLENGE_SIZE_10K     10000
#define FTMO_CHALLENGE_SIZE_25K     25000
#define FTMO_CHALLENGE_SIZE_50K     50000
#define FTMO_CHALLENGE_SIZE_100K    100000
#define FTMO_CHALLENGE_SIZE_200K    200000

#define FTMO_DAILY_LOSS_LIMIT_10K   500
#define FTMO_DAILY_LOSS_LIMIT_25K   1250
#define FTMO_DAILY_LOSS_LIMIT_50K   2500
#define FTMO_DAILY_LOSS_LIMIT_100K  5000
#define FTMO_DAILY_LOSS_LIMIT_200K  10000

#define FTMO_MAX_DRAWDOWN_10K       1000
#define FTMO_MAX_DRAWDOWN_25K       2500
#define FTMO_MAX_DRAWDOWN_50K       5000
#define FTMO_MAX_DRAWDOWN_100K      10000
#define FTMO_MAX_DRAWDOWN_200K      20000

#define FTMO_PROFIT_TARGET_10K      800
#define FTMO_PROFIT_TARGET_25K      2000
#define FTMO_PROFIT_TARGET_50K      4000
#define FTMO_PROFIT_TARGET_100K     8000
#define FTMO_PROFIT_TARGET_200K     16000

// Configurações ICT/SMC
#define ICT_MIN_OB_SIZE_POINTS      50
#define ICT_MIN_FVG_SIZE_POINTS     20
#define ICT_MIN_LIQUIDITY_TOUCHES   3
#define ICT_DEFAULT_LOOKBACK        100
#define ICT_MAX_CONFLUENCE_DISTANCE 200

// Configurações de Volume
#define VOLUME_SPIKE_THRESHOLD      2.0
#define VOLUME_MA_PERIOD            20
#define VOLUME_PROFILE_LEVELS       50
#define VALUE_AREA_PERCENTAGE       70.0

// Performance Targets
#define TARGET_SHARPE_RATIO         1.5
#define TARGET_PROFIT_FACTOR        1.3
#define TARGET_WIN_RATE             0.6
#define MAX_ACCEPTABLE_DRAWDOWN     0.05

//+------------------------------------------------------------------+
//|                         FIM DO ARQUIVO                           |
//+------------------------------------------------------------------+

/*
 * RESUMO DAS ESTRUTURAS IMPLEMENTADAS:
 * 
 * 1. ENUMERAÇÕES PRINCIPAIS
 *    - Estados do EA, tipos de sinal, força do sinal
 *    - Tipos e estados de Order Blocks, FVG, Liquidez
 *    - Estrutura de mercado, métodos de posição
 *    - Tipos de alerta, níveis de log
 * 
 * 2. ESTRUTURAS ICT/SMC
 *    - SOrderBlock: Dados completos de Order Blocks
 *    - SFairValueGap: Informações de Fair Value Gaps
 *    - SLiquidityZone: Zonas de liquidez
 *    - SMarketStructureInfo: Análise de estrutura
 *    - SICTConfig: Configurações ICT/SMC
 * 
 * 3. ESTRUTURAS DE TRADING
 *    - SSignalInfo: Informações de sinais
 *    - SPositionInfo: Dados de posições
 *    - STradeInfo: Análise completa de trades
 *    - STradingConfig: Configurações de trading
 * 
 * 4. ESTRUTURAS DE RISCO
 *    - SRiskConfig: Configurações de risco
 *    - SRiskMetrics: Métricas de risco em tempo real
 * 
 * 5. ESTRUTURAS DE COMPLIANCE
 *    - SComplianceConfig: Configurações FTMO
 *    - SComplianceState: Estado de compliance
 * 
 * 6. ESTRUTURAS DE VOLUME
 *    - SVolumeConfig: Configurações de análise
 *    - SVolumeProfileData: Dados de volume profile
 *    - SVolumeSpike: Detecção de spikes
 *    - SVolumeMetrics: Métricas de volume
 * 
 * 7. ESTRUTURAS DE ALERTAS
 *    - SAlertConfig: Configurações de alertas
 *    - SAlert: Estrutura de alerta individual
 * 
 * 8. ESTRUTURAS DE LOGGING
 *    - SLogEntry: Entrada de log detalhada
 * 
 * 9. ESTRUTURAS DE PERFORMANCE
 *    - SPerformanceMetrics: Métricas completas
 * 
 * 10. ESTRUTURAS DE CONFIGURAÇÃO
 *     - SEAConfig: Configuração principal
 * 
 * 11. ESTRUTURAS AUXILIARES
 *     - SCacheEntry: Cache de dados
 *     - SSymbolInfo: Informações de símbolo
 *     - SExecutionStats: Estatísticas de execução
 * 
 * 12. CONSTANTES DO SISTEMA
 *     - Identificação, limites, timeouts
 *     - Tolerâncias, caminhos, cores
 *     - Mensagens, códigos de erro
 *     - Configurações FTMO, ICT, Volume
 * 
 * TOTAL: 150+ estruturas e constantes para
 * um sistema completo de trading automatizado
 * com foco em ICT/SMC e compliance FTMO.
 */