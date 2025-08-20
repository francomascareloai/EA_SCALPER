//+------------------------------------------------------------------+
//|                                           DataStructures.mqh    |
//|                                    EA FTMO Scalper Elite v1.0    |
//|                                      TradeDev_Master 2024        |
//+------------------------------------------------------------------+
#property copyright "TradeDev_Master 2024"
#property version   "1.00"
#property strict

// Include MQL5 standard constants
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| CONSTANTES DO SISTEMA                                            |
//+------------------------------------------------------------------+

// EA Identification
#define EA_NAME                 "EA FTMO Scalper Elite"
#define EA_VERSION              "1.0"
#define EA_AUTHOR               "TradeDev_Master"
#define EA_DESCRIPTION          "Advanced ICT/SMC Scalping EA with FTMO Compliance"
#define EA_MAGIC_BASE           20241801
#define EA_MAGIC_NUMBER         20241801

// Risk Management Constants
#define RISK_TYPE_PERCENT       1
#define RISK_TYPE_FIXED         2

// File System Constants
#define FILE_IS_DIRECTORY       0x10

// System Limits
#define MAX_POSITIONS           10
#define MAX_PENDING_ORDERS      20
#define MAX_SYMBOLS             5
#define MAX_TIMEFRAMES          9
#define MAX_ORDER_BLOCKS        50
#define MAX_FVG                 30
#define MAX_LIQUIDITY_LEVELS    20
#define MAX_ALERTS              100
#define MAX_LOG_ENTRIES         1000

// Timeouts and Tolerances
#define EXECUTION_TIMEOUT       5000      // ms
#define SLIPPAGE_TOLERANCE      3         // points
#define PRICE_TOLERANCE         0.00001   // price difference tolerance
#define TIME_TOLERANCE          60        // seconds
#define RETRY_ATTEMPTS          3
#define CACHE_TIMEOUT           300       // seconds

// File Paths
#define LOG_PATH                "EA_FTMO_Scalper\\Logs\\"
#define CONFIG_PATH             "EA_FTMO_Scalper\\Config\\"
#define DATA_PATH               "EA_FTMO_Scalper\\Data\\"
#define BACKUP_PATH             "EA_FTMO_Scalper\\Backup\\"

// Standard Colors
#define COLOR_BUY               clrDodgerBlue
#define COLOR_SELL              clrCrimson
#define COLOR_ORDER_BLOCK       clrGold
#define COLOR_FVG               clrMediumOrchid
#define COLOR_LIQUIDITY         clrOrange
#define COLOR_STRUCTURE         clrLimeGreen
#define COLOR_VOLUME            clrAqua

// Formatting
#define PRICE_FORMAT            "%.5f"
#define PERCENT_FORMAT          "%.2f%%"
#define VOLUME_FORMAT           "%.2f"
#define TIME_FORMAT             "%Y.%m.%d %H:%M:%S"

// Standard Messages
#define MSG_INIT_SUCCESS        "EA initialized successfully"
#define MSG_INIT_FAILED         "EA initialization failed"
#define MSG_DEINIT_SUCCESS      "EA deinitialized successfully"
#define MSG_TRADE_OPENED        "Trade opened successfully"
#define MSG_TRADE_CLOSED        "Trade closed successfully"
#define MSG_RISK_VIOLATION      "Risk management violation detected"
#define MSG_FTMO_VIOLATION      "FTMO compliance violation detected"

// Custom Error Codes
#define ERR_CUSTOM_BASE         65000
#define ERR_INVALID_CONFIG      (ERR_CUSTOM_BASE + 1)
#define ERR_RISK_VIOLATION      (ERR_CUSTOM_BASE + 2)
#define ERR_FTMO_VIOLATION      (ERR_CUSTOM_BASE + 3)
#define ERR_INSUFFICIENT_DATA   (ERR_CUSTOM_BASE + 4)
#define ERR_EXECUTION_FAILED    (ERR_CUSTOM_BASE + 5)
#define ERR_INVALID_SIGNAL      (ERR_CUSTOM_BASE + 6)
#define ERR_MARKET_CLOSED       (ERR_CUSTOM_BASE + 7)
#define ERR_NEWS_FILTER         (ERR_CUSTOM_BASE + 8)

// Log Level Constants (for compatibility)
#define LOG_LEVEL_DEBUG         LOG_DEBUG
#define LOG_LEVEL_INFO          LOG_INFO
#define LOG_LEVEL_WARNING       LOG_WARNING
#define LOG_LEVEL_ERROR         LOG_ERROR
#define LOG_LEVEL_CRITICAL      LOG_CRITICAL

// Type Constants (for compatibility)
#define OB_TYPE_ANY             -1
#define ORDER_BLOCK_BULLISH     OB_TYPE_BULLISH
#define ORDER_BLOCK_BEARISH     OB_TYPE_BEARISH
#define FVG_TYPE_ANY            -1
#define FVG_BULLISH             FVG_TYPE_BULLISH
#define FVG_BEARISH             FVG_TYPE_BEARISH
#define LIQ_TYPE_ANY            -1
#define LIQUIDITY_TYPE_SELL     LIQ_TYPE_SSL
#define LIQUIDITY_TYPE_BUY      LIQ_TYPE_BSL

// Cache Constants
#define CACHE_MAX_ENTRIES       1000
#define CACHE_MAX_MEMORY_MB     50
#define CACHE_DEFAULT_TTL       300

// FTMO Configuration
#define FTMO_MAX_DAILY_LOSS     5.0       // %
#define FTMO_MAX_TOTAL_LOSS     10.0      // %
#define FTMO_MIN_TRADING_DAYS   10
#define FTMO_PROFIT_TARGET      10.0      // %
#define FTMO_CONSISTENCY_RULE   true
#define FTMO_NEWS_FILTER        true

// ICT/SMC Settings
#define ICT_MIN_OB_SIZE         10        // points
#define ICT_MAX_OB_AGE          24        // hours
#define ICT_MIN_FVG_SIZE        5         // points
#define ICT_MAX_FVG_AGE         12        // hours
#define ICT_LIQUIDITY_BUFFER    2         // points
#define ICT_STRUCTURE_BUFFER    5         // points

// Volume Analysis Settings
#define VOLUME_SPIKE_THRESHOLD  2.0       // multiplier
#define VOLUME_MA_PERIOD        20
#define VOLUME_PROFILE_BARS     100
#define POC_TOLERANCE           0.5       // %
#define VALUE_AREA_PERCENT      70.0      // %

// Performance Targets
#define TARGET_SHARPE_RATIO     1.5
#define TARGET_PROFIT_FACTOR    1.3
#define TARGET_WIN_RATE         60.0      // %
#define TARGET_MAX_DRAWDOWN     5.0       // %
#define TARGET_MONTHLY_RETURN   8.0       // %

//+------------------------------------------------------------------+
//| ENUMERAÇÕES                                                      |
//+------------------------------------------------------------------+

// Estado do EA
enum ENUM_EA_STATE
{
    EA_STATE_INIT,              // Inicializando
    EA_STATE_RUNNING,           // Executando
    EA_STATE_PAUSED,            // Pausado
    EA_STATE_ERROR,             // Erro
    EA_STATE_SHUTDOWN           // Desligando
};

// Tipos de Sinal
enum ENUM_SIGNAL_TYPE
{
    SIGNAL_NONE,                // Nenhum sinal
    SIGNAL_BUY,                 // Sinal de compra
    SIGNAL_SELL,                // Sinal de venda
    SIGNAL_CLOSE_BUY,           // Fechar compra
    SIGNAL_CLOSE_SELL,          // Fechar venda
    SIGNAL_CLOSE_ALL            // Fechar todas
};

// Força do Sinal
enum ENUM_SIGNAL_STRENGTH
{
    SIGNAL_VERY_WEAK,           // Muito fraco
    SIGNAL_WEAK,                // Fraco
    SIGNAL_MEDIUM,              // Médio
    SIGNAL_STRONG,              // Forte
    SIGNAL_VERY_STRONG          // Muito forte
};

// Tipos de Order Block
enum ENUM_ORDER_BLOCK_TYPE
{
    OB_TYPE_BULLISH,            // Order Block de alta
    OB_TYPE_BEARISH,            // Order Block de baixa
    OB_TYPE_NEUTRAL             // Neutro
};

// Status do Order Block
enum ENUM_ORDER_BLOCK_STATUS
{
    OB_STATUS_ACTIVE,           // Ativo
    OB_STATUS_TESTED,           // Testado
    OB_STATUS_BROKEN,           // Quebrado
    OB_STATUS_EXPIRED           // Expirado
};

// Tipos de Fair Value Gap
enum ENUM_FVG_TYPE
{
    FVG_TYPE_BULLISH,           // FVG de alta
    FVG_TYPE_BEARISH,           // FVG de baixa
    FVG_TYPE_BALANCED           // Equilibrado
};

// Status do FVG
enum ENUM_FVG_STATUS
{
    FVG_STATUS_OPEN,            // Aberto
    FVG_STATUS_PARTIAL,         // Parcialmente preenchido
    FVG_STATUS_FILLED,          // Preenchido
    FVG_STATUS_EXPIRED          // Expirado
};

// Tipos de Liquidez
enum ENUM_LIQUIDITY_TYPE
{
    LIQ_TYPE_BSL,               // Buy Side Liquidity
    LIQ_TYPE_SSL,               // Sell Side Liquidity
    LIQ_TYPE_EQL,               // Equal Highs/Lows
    LIQ_TYPE_RELATIVE,          // Liquidez relativa
    LIQUIDITY_TYPE_ANY          // Qualquer tipo (para filtros)
};

// Status da Liquidez
enum ENUM_LIQUIDITY_STATUS
{
    LIQ_STATUS_UNTESTED,        // Não testada
    LIQ_STATUS_SWEPT,           // Varrida
    LIQ_STATUS_HOLDING,         // Segurando
    LIQ_STATUS_BROKEN           // Quebrada
};

// Tipos de Estrutura de Mercado
enum ENUM_MARKET_STRUCTURE
{
    STRUCTURE_BULLISH,          // Estrutura de alta
    STRUCTURE_BEARISH,          // Estrutura de baixa
    STRUCTURE_RANGING,          // Lateral
    STRUCTURE_TRANSITION        // Transição
};

// Tipos de Mudança de Estrutura
enum ENUM_STRUCTURE_CHANGE
{
    CHANGE_NONE,                // Nenhuma mudança
    CHANGE_BOS,                 // Break of Structure
    CHANGE_CHOCH,               // Change of Character
    CHANGE_CONTINUATION         // Continuação
};

// Configurações de Trading
enum ENUM_TRADING_MODE
{
    TRADING_CONSERVATIVE,       // Conservador
    TRADING_MODERATE,           // Moderado
    TRADING_AGGRESSIVE,         // Agressivo
    TRADING_CUSTOM              // Personalizado
};

// Tipos de Gestão de Risco
enum ENUM_RISK_TYPE
{
    RISK_FIXED_PERCENT,         // Percentual fixo
    RISK_FIXED_AMOUNT,          // Valor fixo
    RISK_KELLY_CRITERION,       // Critério de Kelly
    RISK_VOLATILITY_BASED,      // Baseado em volatilidade
    RISK_ADAPTIVE               // Adaptativo
};

// Status de Compliance
enum ENUM_COMPLIANCE_STATUS
{
    COMPLIANCE_OK,              // Conforme
    COMPLIANCE_WARNING,         // Aviso
    COMPLIANCE_VIOLATION,       // Violação
    COMPLIANCE_CRITICAL         // Crítico
};

// Tipos de Violação FTMO
enum ENUM_FTMO_VIOLATION
{
    FTMO_NO_VIOLATION,          // Nenhuma violação
    FTMO_DAILY_LOSS,            // Perda diária
    FTMO_TOTAL_LOSS,            // Perda total
    FTMO_CONSISTENCY,           // Consistência
    FTMO_NEWS_TRADING,          // Trading em notícias
    FTMO_WEEKEND_HOLDING        // Posições no fim de semana
};

// Tipos de Análise de Volume
enum ENUM_VOLUME_ANALYSIS
{
    VOLUME_ANALYSIS_PROFILE,    // Perfil de volume
    VOLUME_ANALYSIS_DELTA,      // Delta de volume
    VOLUME_ANALYSIS_CUMULATIVE  // Volume cumulativo
};

// Tipos de Volume para Análise
enum ENUM_VOLUME_TYPE
{
   VOLUME_TYPE_TICK = 0,         // Volume por tick
   VOLUME_TYPE_REAL = 1,         // Volume real
   VOLUME_TYPE_SPREAD = 2        // Volume por spread
};

// Usar os tipos built-in do MQL5 para volume tick/real:
// VOLUME_TICK e VOLUME_REAL já estão definidos em ENUM_APPLIED_VOLUME

// Tipos de Alerta
enum ENUM_ALERT_TYPE
{
    ALERT_INFO,                 // Informação
    ALERT_WARNING,              // Aviso
    ALERT_ERROR,                // Erro
    ALERT_CRITICAL,             // Crítico
    ALERT_TRADE,                // Trade
    ALERT_SIGNAL,               // Sinal
    ALERT_RISK,                 // Risco
    ALERT_COMPLIANCE            // Compliance
};

// Canais de Alerta
enum ENUM_ALERT_CHANNEL
{
    ALERT_TERMINAL,             // Terminal
    ALERT_PUSH,                 // Push notification
    ALERT_EMAIL,                // Email
    ALERT_SOUND,                // Som
    ALERT_POPUP,                // Popup
    ALERT_FILE                  // Arquivo
};

// Níveis de Log
enum ENUM_LOG_LEVEL
{
    LOG_DEBUG,                  // Debug
    LOG_INFO,                   // Informação
    LOG_WARNING,                // Aviso
    LOG_ERROR,                  // Erro
    LOG_CRITICAL                // Crítico
};

// Tipos de Performance
enum ENUM_PERFORMANCE_METRIC
{
    PERF_PROFIT_FACTOR,         // Fator de lucro
    PERF_SHARPE_RATIO,          // Índice Sharpe
    PERF_WIN_RATE,              // Taxa de acerto
    PERF_DRAWDOWN,              // Drawdown
    PERF_RETURN,                // Retorno
    PERF_VOLATILITY,            // Volatilidade
    PERF_CALMAR_RATIO,          // Índice Calmar
    PERF_SORTINO_RATIO          // Índice Sortino
};

// Enumeração de Tipos de Estrutura ICT
enum ENUM_ICT_STRUCTURE_TYPE
{
    ICT_ORDER_BLOCK,
    ICT_FAIR_VALUE_GAP,
    ICT_LIQUIDITY_VOID,
    ICT_BREAKER_BLOCK,
    ICT_MITIGATION_BLOCK,
    ICT_INSTITUTIONAL_LEVEL,
    ICT_PREMIUM_DISCOUNT,
    ICT_MARKET_STRUCTURE_SHIFT,
    ICT_SWING_HIGH,
    ICT_SWING_LOW,
    ICT_EQUAL_HIGHS,
    ICT_EQUAL_LOWS,
    ICT_LIQUIDITY_SWEEP
};

// Enumeração de Políticas de Eviction do Cache
enum ENUM_CACHE_EVICTION_POLICY
{
    CACHE_EVICT_LRU,        // Least Recently Used
    CACHE_EVICT_LFU,        // Least Frequently Used
    CACHE_EVICT_FIFO,       // First In First Out
    CACHE_EVICT_RANDOM,     // Random eviction
    CACHE_EVICT_TTL_BASED   // Time To Live based
};

//+------------------------------------------------------------------+
//| ESTRUTURAS DE DADOS                                              |
//+------------------------------------------------------------------+

// Estrutura de Order Block
struct SOrderBlock
{
    datetime            timestamp;          // Timestamp de criação
    datetime            time_created;       // Timestamp de criação (alias)
    int                 timeframe;          // Timeframe
    string              symbol;             // Símbolo
    double              high;               // Máxima do bloco
    double              low;                // Mínima do bloco
    double              open;               // Abertura
    double              close;              // Fechamento
    ENUM_ORDER_BLOCK_TYPE type;             // Tipo do order block
    ENUM_ORDER_BLOCK_STATUS status;         // Status atual
    double              volume;             // Volume associado
    int                 strength;           // Força (1-10)
    double              reliability;        // Confiabilidade (0.0-1.0)
    int                 tests;              // Número de testes
    datetime            last_test;          // Último teste
    int                 touch_count;        // Número de toques
    datetime            last_touch_time;    // Último toque
    datetime            expiry_time;        // Tempo de expiração
    bool                is_valid;           // Válido
    bool                is_active;          // Ativo
    
    // Construtor
    SOrderBlock()
    {
        timestamp = 0;
        time_created = 0;
        timeframe = 0;
        symbol = "";
        high = 0.0;
        low = 0.0;
        open = 0.0;
        close = 0.0;
        type = OB_TYPE_NEUTRAL;
        status = OB_STATUS_ACTIVE;
        volume = 0.0;
        strength = 0;
        reliability = 0.0;
        tests = 0;
        last_test = 0;
        touch_count = 0;
        last_touch_time = 0;
        expiry_time = 0;
        is_valid = false;
        is_active = true;
    }
};

// Estrutura de Fair Value Gap
struct SFairValueGap
{
    datetime            timestamp;          // Timestamp de criação
    datetime            time_created;       // Timestamp de criação (alias)
    int                 timeframe;          // Timeframe
    string              symbol;             // Símbolo
    double              high;               // Máxima do gap
    double              low;                // Mínima do gap
    double              size;               // Tamanho do gap
    double              volume;             // Volume associado
    int                 strength;           // Força (1-10)
    double              reliability;        // Confiabilidade (0.0-1.0)
    ENUM_FVG_TYPE       type;               // Tipo do FVG
    ENUM_FVG_STATUS     status;             // Status atual
    double              fill_percent;       // Percentual preenchido
    double              fill_percentage;    // Percentual preenchido (alias)
    bool                is_filled;          // Preenchido
    bool                is_active;          // Ativo
    int                 touch_count;        // Número de toques
    datetime            last_touch_time;    // Último toque
    datetime            expiry;             // Data de expiração
    datetime            expiry_time;        // Tempo de expiração (alias)
    datetime            fill_time;          // Tempo de preenchimento
    bool                is_valid;           // Válido
    
    // Construtor
    SFairValueGap()
    {
        timestamp = 0;
        time_created = 0;
        timeframe = 0;
        symbol = "";
        high = 0.0;
        low = 0.0;
        size = 0.0;
        volume = 0.0;
        strength = 0;
        reliability = 0.0;
        type = FVG_TYPE_BALANCED;
        status = FVG_STATUS_OPEN;
        fill_percent = 0.0;
        fill_percentage = 0.0;
        is_filled = false;
        is_active = true;
        touch_count = 0;
        last_touch_time = 0;
        expiry = 0;
        expiry_time = 0;
        fill_time = 0;
        is_valid = false;
    }
};

// Estrutura de Liquidez
struct SLiquidity
{
    datetime            timestamp;          // Timestamp de criação
    double              price;              // Preço da liquidez
    ENUM_LIQUIDITY_TYPE type;               // Tipo de liquidez
    ENUM_LIQUIDITY_STATUS status;           // Status atual
    double              volume;             // Volume associado
    int                 strength;           // Força (1-10)
    datetime            sweep_time;         // Tempo da varredura
    bool                is_valid;           // Válido
    
    // Construtor
    SLiquidity()
    {
        timestamp = 0;
        price = 0.0;
        type = LIQ_TYPE_RELATIVE;
        status = LIQ_STATUS_UNTESTED;
        volume = 0.0;
        strength = 0;
        sweep_time = 0;
        is_valid = false;
    }
};

// Estrutura de Zona de Liquidez
struct SLiquidityZone
{
    datetime            start_time;         // Tempo de início
    datetime            end_time;           // Tempo de fim
    datetime            timestamp;          // Timestamp de criação
    datetime            time_created;       // Timestamp de criação (alias)
    int                 timeframe;          // Timeframe
    string              symbol;             // Símbolo
    double              high_price;         // Preço máximo
    double              low_price;          // Preço mínimo
    double              price_level;        // Nível de preço
    ENUM_LIQUIDITY_TYPE type;               // Tipo de liquidez
    ENUM_LIQUIDITY_STATUS status;           // Status atual
    double              volume;             // Volume total
    int                 strength;           // Força da zona (1-10)
    double              reliability;        // Confiabilidade (0.0-1.0)
    bool                is_active;          // Zona ativa
    int                 touch_count;        // Número de toques
    datetime            last_touch_time;    // Último toque
    datetime            expiry_time;        // Tempo de expiração
    bool                is_valid;           // Válido
    
    // Construtor
    SLiquidityZone()
    {
        start_time = 0;
        end_time = 0;
        timestamp = 0;
        time_created = 0;
        timeframe = 0;
        symbol = "";
        high_price = 0.0;
        low_price = 0.0;
        price_level = 0.0;
        type = LIQ_TYPE_RELATIVE;
        status = LIQ_STATUS_UNTESTED;
        volume = 0.0;
        strength = 0;
        reliability = 0.0;
        is_active = false;
        touch_count = 0;
        last_touch_time = 0;
        expiry_time = 0;
        is_valid = false;
    }
};

// Estrutura de Sinal de Trading
struct STradingSignal
{
    datetime            timestamp;          // Timestamp do sinal
    ENUM_SIGNAL_TYPE    type;               // Tipo do sinal
    ENUM_SIGNAL_STRENGTH strength;          // Força do sinal
    double              entry_price;        // Preço de entrada
    double              stop_loss;          // Stop loss
    double              take_profit;        // Take profit
    double              lot_size;           // Tamanho da posição
    string              comment;            // Comentário
    int                 confluence_score;   // Score de confluência
    double              confidence;         // Confiança do sinal (0.0 - 1.0)
    bool                is_valid;           // Válido
    
    // Construtor
    STradingSignal()
    {
        timestamp = 0;
        type = SIGNAL_NONE;
        strength = SIGNAL_WEAK;
        entry_price = 0.0;
        stop_loss = 0.0;
        take_profit = 0.0;
        lot_size = 0.0;
        comment = "";
        confluence_score = 0;
        is_valid = false;
    }
};

// Estrutura de Gestão de Risco
struct SRiskData
{
    double              account_balance;     // Saldo da conta
    double              account_equity;      // Patrimônio
    double              daily_pnl;           // P&L diário
    double              weekly_pnl;          // P&L semanal
    double              monthly_pnl;         // P&L mensal
    double              max_drawdown;        // Drawdown máximo
    double              current_drawdown;    // Drawdown atual
    double              risk_per_trade;      // Risco por trade
    double              total_risk;          // Risco total
    int                 open_positions;      // Posições abertas
    bool                risk_ok;             // Risco OK
    
    // Construtor
    SRiskData()
    {
        account_balance = 0.0;
        account_equity = 0.0;
        daily_pnl = 0.0;
        weekly_pnl = 0.0;
        monthly_pnl = 0.0;
        max_drawdown = 0.0;
        current_drawdown = 0.0;
        risk_per_trade = 0.0;
        total_risk = 0.0;
        open_positions = 0;
        risk_ok = true;
    }
};

// Estrutura de Compliance FTMO
struct SFTMOData
{
    double              initial_balance;     // Saldo inicial
    double              current_balance;     // Saldo atual
    double              daily_loss_limit;    // Limite de perda diária
    double              total_loss_limit;    // Limite de perda total
    double              daily_pnl;           // P&L diário
    double              total_pnl;           // P&L total
    int                 trading_days;        // Dias de trading
    bool                consistency_ok;      // Consistência OK
    ENUM_FTMO_VIOLATION violation_type;      // Tipo de violação
    datetime            last_violation;      // Última violação
    bool                is_compliant;        // Está em conformidade
    
    // Construtor
    SFTMOData()
    {
        initial_balance = 0.0;
        current_balance = 0.0;
        daily_loss_limit = 0.0;
        total_loss_limit = 0.0;
        daily_pnl = 0.0;
        total_pnl = 0.0;
        trading_days = 0;
        consistency_ok = true;
        violation_type = FTMO_NO_VIOLATION;
        last_violation = 0;
        is_compliant = true;
    }
};

// Estrutura de Análise de Volume
struct SVolumeData
{
    double              current_volume;      // Volume atual
    double              average_volume;      // Volume médio
    double              volume_ratio;        // Razão de volume
    double              tick_volume;         // Volume de tick
    double              real_volume;         // Volume real
    double              poc_price;           // Preço POC
    double              value_area_high;     // VA High
    double              value_area_low;      // VA Low
    bool                volume_spike;        // Spike de volume
    datetime            last_update;         // Última atualização
    
    // Construtor
    SVolumeData()
    {
        current_volume = 0.0;
        average_volume = 0.0;
        volume_ratio = 0.0;
        tick_volume = 0.0;
        real_volume = 0.0;
        poc_price = 0.0;
        value_area_high = 0.0;
        value_area_low = 0.0;
        volume_spike = false;
        last_update = 0;
    }
};

// Estrutura de Alerta
struct SAlert
{
    datetime            timestamp;          // Timestamp do alerta
    ENUM_ALERT_TYPE     type;               // Tipo do alerta
    ENUM_ALERT_CHANNEL  channel;            // Canal do alerta
    string              message;            // Mensagem
    string              symbol;             // Símbolo
    int                 priority;           // Prioridade (1-10)
    bool                sent;               // Enviado
    
    // Construtor
    SAlert()
    {
        timestamp = 0;
        type = ALERT_INFO;
        channel = ALERT_TERMINAL;
        message = "";
        symbol = "";
        priority = 1;
        sent = false;
    }
};

// Estrutura de Log
struct SLogEntry
{
    datetime            timestamp;          // Timestamp
    ENUM_LOG_LEVEL      level;              // Nível do log
    string              module;             // Módulo
    string              function;           // Função
    string              message;            // Mensagem
    int                 error_code;         // Código de erro
    int                 thread_id;          // ID da thread (sempre 0 no MQL5)
    
    // Construtor
    SLogEntry()
    {
        timestamp = 0;
        level = LOG_INFO;
        module = "";
        function = "";
        message = "";
        error_code = 0;
        thread_id = 0;
    }
};

// Estrutura de Performance
struct SPerformanceData
{
    // Dados básicos de performance
    double              total_trades;        // Total de trades
    double              winning_trades;      // Trades vencedores
    double              losing_trades;       // Trades perdedores
    double              win_rate;            // Taxa de acerto
    double              profit_factor;       // Fator de lucro
    double              sharpe_ratio;        // Índice Sharpe
    double              max_drawdown;        // Drawdown máximo
    double              total_profit;        // Lucro total
    double              total_loss;          // Perda total
    double              average_win;         // Ganho médio
    double              average_loss;        // Perda média
    double              largest_win;         // Maior ganho
    double              largest_loss;        // Maior perda
    double              consecutive_wins;    // Vitórias consecutivas
    double              consecutive_losses;  // Perdas consecutivas
    double              trades_per_day;      // Trades por dia
    double              profit_per_trade;    // Lucro por trade
    double              return_on_account;   // Retorno sobre conta
    datetime            first_trade;         // Primeiro trade
    datetime            last_trade;          // Último trade
    datetime            last_update;         // Última atualização
    
    // Membros adicionais necessários
    datetime            start_time;          // Tempo de início
    double              initial_balance;     // Saldo inicial
    double              initial_equity;      // Equity inicial
    double              current_balance;     // Saldo atual
    double              current_equity;      // Equity atual
    double              peak_balance;        // Pico do saldo
    double              peak_equity;         // Pico do equity
    double              net_profit;          // Lucro líquido
    double              average_trade;       // Trade médio
    double              gross_profit;        // Lucro bruto
    double              gross_loss;          // Perda bruta
    double              current_drawdown;    // Drawdown atual
    
    // Construtor
    SPerformanceData()
    {
        total_trades = 0.0;
        winning_trades = 0.0;
        losing_trades = 0.0;
        win_rate = 0.0;
        profit_factor = 0.0;
        sharpe_ratio = 0.0;
        max_drawdown = 0.0;
        total_profit = 0.0;
        total_loss = 0.0;
        average_win = 0.0;
        average_loss = 0.0;
        largest_win = 0.0;
        largest_loss = 0.0;
        consecutive_wins = 0.0;
        consecutive_losses = 0.0;
        trades_per_day = 0.0;
        profit_per_trade = 0.0;
        return_on_account = 0.0;
        first_trade = 0;
        last_trade = 0;
        last_update = 0;
        
        // Inicializar novos membros
        start_time = 0;
        initial_balance = 0.0;
        initial_equity = 0.0;
        current_balance = 0.0;
        current_equity = 0.0;
        peak_balance = 0.0;
        peak_equity = 0.0;
        net_profit = 0.0;
        average_trade = 0.0;
        gross_profit = 0.0;
        gross_loss = 0.0;
        current_drawdown = 0.0;
    }
};

//+------------------------------------------------------------------+
//| ESTRUTURAS DE CONFIGURAÇÃO                                       |
//+------------------------------------------------------------------+

// Sub-estruturas de configuração
struct SGeneralConfig
{
   bool              enabled;
   int               magic_number;
   ENUM_TIMEFRAMES   timeframe;
   int               max_spread;
   int               slippage;
   
   SGeneralConfig()
   {
      enabled = true;
      magic_number = EA_MAGIC_NUMBER;
      timeframe = PERIOD_M15;
      max_spread = 30;
      slippage = 3;
   }
};

struct STradingConfig
{
   bool              auto_trading;
   bool              trade_on_new_bar;
   int               max_retries;
   int               retry_delay;
   
   STradingConfig()
   {
      auto_trading = true;
      trade_on_new_bar = true;
      max_retries = 3;
      retry_delay = 1000;
   }
};

struct SRiskConfig
{
   int               risk_type;
   double            risk_percent;
   double            fixed_lot;
   int               max_positions;
   double            max_daily_loss;
   double            max_weekly_loss;
   double            max_monthly_loss;
   bool              use_trailing_stop;
   int               trailing_distance;
   
   SRiskConfig()
   {
      risk_type = RISK_TYPE_PERCENT;
      risk_percent = 1.0;
      fixed_lot = 0.01;
      max_positions = 1;
      max_daily_loss = 100.0;
      max_weekly_loss = 300.0;
      max_monthly_loss = 1000.0;
      use_trailing_stop = true;
      trailing_distance = 20;
   }
};

struct SComplianceConfig
{
   bool              ftmo_mode;
   double            daily_loss_limit;
   double            total_loss_limit;
   double            profit_target;
   bool              news_filter;
   bool              weekend_close;
   
   SComplianceConfig()
   {
      ftmo_mode = true;
      daily_loss_limit = 500.0;
      total_loss_limit = 1000.0;
      profit_target = 1000.0;
      news_filter = true;
      weekend_close = true;
   }
};

struct SICTConfig
{
   bool              use_order_blocks;
   int               order_block_period;
   int               order_block_min_size;
   bool              use_fvg;
   int               fvg_min_size;
   int               fvg_max_age;
   bool              use_liquidity;
   int               liquidity_threshold;
   
   SICTConfig()
   {
      use_order_blocks = true;
      order_block_period = 20;
      order_block_min_size = 10;
      use_fvg = true;
      fvg_min_size = 5;
      fvg_max_age = 10;
      use_liquidity = true;
      liquidity_threshold = 50;
   }
};

struct SVolumeConfig
{
   ENUM_APPLIED_VOLUME volume_type;
   int               volume_period;
   double            spike_threshold;
   bool              use_volume_profile;
   
   SVolumeConfig()
   {
      volume_type = VOLUME_TICK;
      volume_period = 14;
      spike_threshold = 2.0;
      use_volume_profile = true;
   }
};

struct SAlertsConfig
{
   bool              enable_alerts;
   bool              enable_push;
   bool              enable_email;
   bool              enable_sound;
   string            sound_file;
   
   SAlertsConfig()
   {
      enable_alerts = true;
      enable_push = false;
      enable_email = false;
      enable_sound = true;
      sound_file = "alert.wav";
   }
};

struct SLoggingConfig
{
   ENUM_LOG_LEVEL    log_level;
   bool              log_to_file;
   bool              log_to_terminal;
   int               max_log_size;
   
   SLoggingConfig()
   {
      log_level = LOG_INFO;
      log_to_file = true;
      log_to_terminal = true;
      max_log_size = 10;
   }
};

struct SDebugConfig
{
   bool              debug_mode;
   bool              verbose_logging;
   bool              save_debug_files;
   
   SDebugConfig()
   {
      debug_mode = false;
      verbose_logging = false;
      save_debug_files = false;
   }
};

struct STestConfig
{
   bool              enable_backtesting;
   bool              test_mode;
   bool              simulation_mode;
   
   STestConfig()
   {
      enable_backtesting = false;
      test_mode = false;
      simulation_mode = false;
   }
};

struct SPerformanceConfig
{
   bool              enable_cache;
   int               cache_size;
   bool              optimize_memory;
   int               max_cpu_usage;
   
   SPerformanceConfig()
   {
      enable_cache = true;
      cache_size = 1000;
      optimize_memory = true;
      max_cpu_usage = 80;
   }
};

// Configuração Principal do EA
struct SEAConfig
{
    // Sub-estruturas de configuração
    SGeneralConfig      general;
    STradingConfig      trading;
    SRiskConfig         risk;
    SComplianceConfig   compliance;
    SICTConfig          ict;
    SVolumeConfig       volume;
    SAlertsConfig       alerts;
    SLoggingConfig      logging;
    SDebugConfig        debug;
    STestConfig         test;
    SPerformanceConfig  performance;
    
    // Configurações legadas (mantidas para compatibilidade)
    string              ea_name;
    string              ea_version;
    int                 magic_number;
    string              symbol;
    ENUM_TIMEFRAMES     timeframe;
    bool                auto_trading;
    ENUM_TRADING_MODE   trading_mode;
    double              lot_size;
    bool                auto_lot;
    double              risk_percent;
    int                 max_positions;
    int                 max_spread;
    bool                allow_hedge;
    ENUM_RISK_TYPE      risk_type;
    double              daily_loss_limit;
    double              total_loss_limit;
    double              max_drawdown;
    bool                use_trailing_stop;
    double              trailing_distance;
    bool                ftmo_mode;
    bool                news_filter;
    bool                weekend_close;
    bool                consistency_check;
    bool                use_order_blocks;
    bool                use_fvg;
    bool                use_liquidity;
    bool                use_structure;
    int                 min_ob_size;
    int                 min_fvg_size;
    bool                use_volume_analysis;
    ENUM_VOLUME_TYPE    volume_type;
    double              volume_threshold;
    int                 volume_ma_period;
    bool                enable_alerts;
    bool                push_notifications;
    bool                email_alerts;
    bool                sound_alerts;
    ENUM_LOG_LEVEL      log_level;
    bool                log_to_file;
    bool                log_trades;
    bool                log_signals;
    bool                debug_mode;
    bool                show_info;
    bool                draw_objects;
    bool                save_data;
    
    // Configurações de Teste
    bool                test_mode;
    datetime            test_start;
    datetime            test_end;
    bool                visual_mode;
    
    // Configurações de Performance
    bool                optimize_performance;
    int                 cache_size;
    int                 max_history;
    bool                async_processing;
    
    // Construtor
    SEAConfig()
    {
        ea_name = EA_NAME;
        ea_version = EA_VERSION;
        magic_number = EA_MAGIC_BASE;
        symbol = _Symbol;
        timeframe = _Period;
        auto_trading = true;
        trading_mode = TRADING_MODERATE;
        
        lot_size = 0.01;
        auto_lot = true;
        risk_percent = 1.0;
        max_positions = 3;
        max_spread = 20;
        allow_hedge = false;
        
        risk_type = RISK_FIXED_PERCENT;
        daily_loss_limit = 5.0;
        total_loss_limit = 10.0;
        max_drawdown = 5.0;
        use_trailing_stop = true;
        trailing_distance = 20.0;
        
        ftmo_mode = true;
        news_filter = true;
        weekend_close = true;
        consistency_check = true;
        
        use_order_blocks = true;
        use_fvg = true;
        use_liquidity = true;
        use_structure = true;
        min_ob_size = ICT_MIN_OB_SIZE;
        min_fvg_size = ICT_MIN_FVG_SIZE;
        
        use_volume_analysis = true;
        volume_type = VOLUME_TYPE_TICK;
        volume_threshold = VOLUME_SPIKE_THRESHOLD;
        volume_ma_period = VOLUME_MA_PERIOD;
        
        enable_alerts = true;
        push_notifications = true;
        email_alerts = false;
        sound_alerts = true;
        
        log_level = LOG_INFO;
        log_to_file = true;
        log_trades = true;
        log_signals = true;
        
        debug_mode = false;
        show_info = true;
        draw_objects = true;
        save_data = true;
        
        test_mode = false;
        test_start = 0;
        test_end = 0;
        visual_mode = false;
        
        optimize_performance = true;
        cache_size = 1000;
        max_history = 10000;
        async_processing = false;
    }
};

//+------------------------------------------------------------------+
//| ESTRUTURAS AUXILIARES                                            |
//+------------------------------------------------------------------+

// Entrada de Cache
struct SCacheEntry
{
    string              key;                // Chave
    string              data;               // Dados
    string              value;              // Valor do cache (alias para data)
    datetime            timestamp;          // Timestamp
    datetime            created_at;         // Timestamp de criação (alias)
    datetime            last_access;        // Último acesso
    datetime            expiry;             // Expiração
    int                 ttl;                // Time to live em segundos
    int                 access_count;       // Contador de acesso
    int                 size;               // Tamanho dos dados
    bool                is_valid;           // Válido
    
    // Construtor
    SCacheEntry()
    {
        key = "";
        data = "";
        value = "";
        timestamp = 0;
        created_at = 0;
        last_access = 0;
        expiry = 0;
        ttl = 0;
        access_count = 0;
        size = 0;
        is_valid = false;
    }
};

// Informações do Símbolo
struct SSymbolInfo
{
    string              symbol;             // Símbolo
    double              bid;                // Bid
    double              ask;                // Ask
    double              spread;             // Spread
    double              point;              // Point
    int                 digits;             // Dígitos
    double              tick_size;          // Tamanho do tick
    double              tick_value;         // Valor do tick
    double              lot_size;           // Tamanho do lote
    double              min_lot;            // Lote mínimo
    double              max_lot;            // Lote máximo
    double              lot_step;           // Passo do lote
    bool                is_valid;           // Válido
    
    // Construtor
    SSymbolInfo()
    {
        symbol = "";
        bid = 0.0;
        ask = 0.0;
        spread = 0.0;
        point = 0.0;
        digits = 0;
        tick_size = 0.0;
        tick_value = 0.0;
        lot_size = 0.0;
        min_lot = 0.0;
        max_lot = 0.0;
        lot_step = 0.0;
        is_valid = false;
    }
};

// Estatísticas de Execução
struct SExecutionStats
{
    int                 total_executions;   // Total de execuções
    double              avg_execution_time; // Tempo médio de execução
    double              max_execution_time; // Tempo máximo de execução
    double              min_execution_time; // Tempo mínimo de execução
    int                 failed_executions;  // Execuções falhadas
    double              success_rate;       // Taxa de sucesso
    datetime            last_execution;     // Última execução
    
    // Construtor
    SExecutionStats()
    {
        total_executions = 0;
        avg_execution_time = 0.0;
        max_execution_time = 0.0;
        min_execution_time = 999999.0;
        failed_executions = 0;
        success_rate = 0.0;
        last_execution = 0;
    }
};

//+------------------------------------------------------------------+
//| MACROS AUXILIARES                                                |
//+------------------------------------------------------------------+

// Macro para validação de ponteiro
#define SAFE_DELETE(ptr) if(CheckPointer(ptr) == POINTER_DYNAMIC) { delete ptr; ptr = NULL; }

// Macro para validação de array
#define SAFE_ARRAY_SIZE(arr) (ArraySize(arr) > 0 ? ArraySize(arr) : 0)

// Macro para normalização de preço
#define NORMALIZE_PRICE(price) NormalizeDouble(price, _Digits)

// Macro para conversão de pontos para preço
#define POINTS_TO_PRICE(points) (points * _Point)

// Macro para conversão de preço para pontos
#define PRICE_TO_POINTS(price) (int)(price / _Point)

// Macro para validação de timeframe
#define IS_VALID_TIMEFRAME(tf) (tf >= PERIOD_M1 && tf <= PERIOD_MN1)

// Macro para validação de volume
#define IS_VALID_VOLUME(vol) (vol >= SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN) && vol <= SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX))

// Macro para validação de preço
#define IS_VALID_PRICE(price) (price > 0 && price < DBL_MAX)

// Macro para cálculo de spread em pontos
#define SPREAD_POINTS() (int)((SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID)) / _Point)

// Macro para verificação de horário de trading
#define IS_TRADING_TIME() (SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL)

// Enumerações para cálculo de Stop Loss
enum ENUM_SL_CALCULATION_METHOD
{
   SL_FIXED_POINTS,        // Pontos fixos
   SL_FIXED_PRICE,         // Preço fixo
   SL_ATR_MULTIPLE,        // Múltiplo do ATR
   SL_PERCENT_BALANCE,     // Porcentagem do saldo
   SL_SUPPORT_RESISTANCE,  // Suporte/Resistência
   SL_PREVIOUS_CANDLE,     // Candle anterior
   SL_BOLLINGER_BANDS,     // Bandas de Bollinger
   SL_MOVING_AVERAGE       // Média móvel
};

// Enumerações para cálculo de Take Profit
enum ENUM_TP_CALCULATION_METHOD
{
   TP_FIXED_POINTS,        // Pontos fixos
   TP_FIXED_PRICE,         // Preço fixo
   TP_RISK_REWARD_RATIO,   // Razão risco/recompensa
   TP_ATR_MULTIPLE,        // Múltiplo do ATR
   TP_PERCENT_BALANCE,     // Porcentagem do saldo
   TP_FIBONACCI_LEVELS,    // Níveis de Fibonacci
   TP_RESISTANCE_SUPPORT,  // Resistência/Suporte
   TP_MOVING_AVERAGE       // Média móvel
};

// Enum para métodos de trailing stop
enum ENUM_TRAILING_METHOD
{
   TRAILING_FIXED_POINTS,      // Trailing stop fixo em pontos
   TRAILING_ORDER_BLOCKS,      // Baseado em Order Blocks
   TRAILING_STRUCTURE_BREAKS,  // Baseado em quebras de estrutura
   TRAILING_FVG_LEVELS,        // Baseado em níveis FVG
   TRAILING_LIQUIDITY_ZONES,   // Baseado em zonas de liquidez
   TRAILING_ATR_DYNAMIC        // Dinâmico baseado em ATR
};

// Constantes faltantes
#define SL_HYBRID SL_ATR_MULTIPLE
#define TP_STRUCTURE TP_FIBONACCI_LEVELS
#define VOLUME_ANALYSIS_TICK VOLUME_TICK

// Aliases para compatibilidade
// Removido alias conflitante TRAIL_STRUCTURE

// Sub-estruturas de configuração (declaradas antes de SEAConfig)
// Estruturas duplicadas removidas - já declaradas antes da SEAConfig

// Estrutura para Trailing Stop
struct TRAILING_CONFIG
{
   bool              enabled;           // Trailing ativado
   double            start_distance;    // Distância inicial em pontos
   double            step_distance;     // Passo do trailing em pontos
   double            min_profit;        // Lucro mínimo para iniciar
   ENUM_SL_CALCULATION_METHOD method;   // Método de cálculo
   
   // Construtor
   TRAILING_CONFIG()
   {
      enabled = false;
      start_distance = 50.0;
      step_distance = 10.0;
      min_profit = 20.0;
      method = SL_FIXED_POINTS;
   }
};

//+------------------------------------------------------------------+
//| FIM DO ARQUIVO                                                   |
//+------------------------------------------------------------------+