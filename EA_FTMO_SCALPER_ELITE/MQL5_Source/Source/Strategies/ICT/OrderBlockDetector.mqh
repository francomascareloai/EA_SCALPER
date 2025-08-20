//+------------------------------------------------------------------+
//|                                        OrderBlockDetector.mqh   |
//|                                    EA FTMO Scalper Elite v1.0    |
//|                                      TradeDev_Master 2024        |
//+------------------------------------------------------------------+
#property copyright "TradeDev_Master 2024"
#property version   "1.00"
#property strict

#include "../../Core/Interfaces.mqh"
#include "../../Core/DataStructures.mqh"
#include "../../Core/Logger.mqh"
#include "../../Core/CacheManager.mqh"

//+------------------------------------------------------------------+
//| DETECTOR DE ORDER BLOCKS (ICT/SMC)                              |
//+------------------------------------------------------------------+

class COrderBlockDetector : public IModule
{
private:
    // Estado do módulo
    bool                m_initialized;
    string              m_module_name;
    string              m_version;
    string              m_symbol;
    int                 m_timeframe;
    
    // Configurações de detecção
    struct SDetectionConfig
    {
        int     lookback_candles;        // Velas para análise
        int     min_body_size_points;    // Tamanho mínimo do corpo
        double  min_body_ratio;          // Ratio mínimo corpo/sombra
        int     min_volume_ratio;        // Volume mínimo vs média
        int     max_age_bars;            // Idade máxima em barras
        bool    require_imbalance;       // Exigir imbalance
        bool    require_liquidity_grab;  // Exigir captura de liquidez
        double  min_distance_atr;        // Distância mínima em ATR
        int     confirmation_bars;       // Barras para confirmação
        bool    filter_by_structure;     // Filtrar por estrutura
    };
    
    SDetectionConfig    m_config;
    
    // Order Blocks detectados
    SOrderBlock         m_order_blocks[];
    int                 m_ob_count;
    int                 m_max_order_blocks;
    
    // Dados de mercado
    double              m_high[];
    double              m_low[];
    double              m_open[];
    double              m_close[];
    long                m_volume[];
    datetime            m_time[];
    
    // Indicadores auxiliares
    int                 m_atr_handle;
    double              m_atr_buffer[];
    
    // Cache de cálculos
    struct SCacheData
    {
        datetime last_update;
        int      last_bar_count;
        double   avg_volume;
        double   current_atr;
        bool     structure_bullish;
        bool     structure_bearish;
    };
    
    SCacheData          m_cache;
    
    // Estatísticas
    struct SStatistics
    {
        int     total_detected;
        int     bullish_blocks;
        int     bearish_blocks;
        int     valid_blocks;
        int     expired_blocks;
        int     triggered_blocks;
        double  avg_success_rate;
        double  avg_distance;
        int     avg_duration;
    };
    
    SStatistics         m_stats;
    
    // Métodos privados de detecção
    bool                DetectBullishOrderBlock(int start_bar);
    bool                DetectBearishOrderBlock(int start_bar);
    bool                ValidateOrderBlock(SOrderBlock &block);
    bool                IsValidCandle(int bar_index);
    bool                HasImbalance(int bar_index, ENUM_ORDER_BLOCK_TYPE type);
    bool                HasLiquidityGrab(int bar_index, ENUM_ORDER_BLOCK_TYPE type);
    bool                CheckStructureAlignment(ENUM_ORDER_BLOCK_TYPE type);
    
    // Métodos de análise
    double              CalculateBodySize(int bar_index);
    double              CalculateBodyRatio(int bar_index);
    double              GetVolumeRatio(int bar_index);
    double              GetCurrentATR();
    double              GetAverageVolume(int periods = 20);
    bool                IsStructureBullish();
    bool                IsStructureBearish();
    
    // Métodos de validação
    bool                IsMinimumDistance(double price1, double price2);
    bool                IsWithinMaxAge(datetime block_time);
    bool                HasSufficientConfirmation(SOrderBlock &block);
    
    // Métodos de gerenciamento
    void                AddOrderBlock(SOrderBlock &block);
    void                UpdateOrderBlocks();
    void                RemoveExpiredBlocks();
    void                RemoveTriggeredBlocks();
    int                 FindOrderBlockIndex(datetime time, ENUM_ORDER_BLOCK_TYPE type);
    
    // Métodos de cache
    void                UpdateCache();
    bool                IsCacheValid();
    string              GetCacheKey(string suffix = "");
    
    // Métodos auxiliares
    void                InitializeArrays();
    void                UpdateMarketData();
    void                CalculateStatistics();
    void                LogOrderBlock(SOrderBlock &block, string action);
    
public:
    // Construtor e destrutor
                        COrderBlockDetector(string symbol = "", int timeframe = PERIOD_CURRENT);
                        ~COrderBlockDetector();
    
    // Implementação IModule
    virtual bool        Init() override;
    virtual void        Deinit() override;
    virtual bool        IsInitialized() override { return m_initialized; }
    virtual string      GetModuleName() override { return m_module_name; }
    virtual string      GetVersion() override { return m_version; }
    virtual bool        SelfTest() override;
    
    // Configuração
    void                SetSymbol(string symbol);
    void                SetTimeframe(int timeframe);
    void                SetLookbackCandles(int candles);
    void                SetMinBodySize(int points);
    void                SetMinBodyRatio(double ratio);
    void                SetMinVolumeRatio(int ratio);
    void                SetMaxAge(int bars);
    void                SetRequireImbalance(bool require);
    void                SetRequireLiquidityGrab(bool require);
    void                SetMinDistanceATR(double atr_multiplier);
    void                SetConfirmationBars(int bars);
    void                SetFilterByStructure(bool filter);
    void                SetMaxOrderBlocks(int max_blocks);
    
    // Detecção principal
    void                ScanForOrderBlocks();
    void                UpdateDetection();
    bool                HasNewOrderBlocks();
    
    // Acesso aos Order Blocks
    int                 GetOrderBlockCount();
    SOrderBlock         GetOrderBlock(int index);
    SOrderBlock         GetLatestOrderBlock(ENUM_ORDER_BLOCK_TYPE type = OB_TYPE_ANY);
    SOrderBlock         GetNearestOrderBlock(double price, ENUM_ORDER_BLOCK_TYPE type = OB_TYPE_ANY);
    
    // Consultas específicas
    bool                HasBullishOrderBlock(double price_level, double tolerance = 0.0);
    bool                HasBearishOrderBlock(double price_level, double tolerance = 0.0);
    bool                IsPriceInOrderBlock(double price, ENUM_ORDER_BLOCK_TYPE type = OB_TYPE_ANY);
    double              GetNearestOrderBlockDistance(double price);
    
    // Análise de qualidade
    double              GetOrderBlockStrength(int index);
    double              GetOrderBlockReliability(int index);
    bool                IsOrderBlockValid(int index);
    bool                IsOrderBlockActive(int index);
    
    // Filtragem
    void                GetOrderBlocksByType(ENUM_ORDER_BLOCK_TYPE type, SOrderBlock &blocks[]);
    void                GetOrderBlocksByTimeframe(int timeframe, SOrderBlock &blocks[]);
    void                GetOrderBlocksInRange(double min_price, double max_price, SOrderBlock &blocks[]);
    void                GetRecentOrderBlocks(int max_age_bars, SOrderBlock &blocks[]);
    
    // Estatísticas e análise
    SStatistics         GetStatistics();
    double              GetSuccessRate(ENUM_ORDER_BLOCK_TYPE type = OB_TYPE_ANY);
    double              GetAverageDistance();
    int                 GetAverageDuration();
    
    // Alertas e notificações
    bool                CheckOrderBlockTouch(double current_price);
    bool                CheckOrderBlockBreak(double current_price);
    void                SetupAlerts(bool enable_touch = true, bool enable_break = true);
    
    // Exportação e relatórios
    string              GetDetectionReport();
    bool                ExportOrderBlocks(string filename);
    void                DrawOrderBlocksOnChart(bool enable = true);
    
    // Otimização
    void                OptimizeParameters();
    string              GetOptimizationSuggestions();
    
    // Debug e diagnóstico
    void                EnableDebugMode(bool enable);
    string              GetDebugInfo();
    void                ValidateDetection();
};

//+------------------------------------------------------------------+
//| IMPLEMENTAÇÃO DO CONSTRUTOR                                      |
//+------------------------------------------------------------------+

COrderBlockDetector::COrderBlockDetector(string symbol = "", int timeframe = PERIOD_CURRENT)
{
    m_initialized = false;
    m_module_name = "OrderBlockDetector";
    m_version = "1.00";
    
    // Configurar símbolo e timeframe
    m_symbol = (symbol == "") ? Symbol() : symbol;
    m_timeframe = (timeframe == PERIOD_CURRENT) ? Period() : timeframe;
    
    // Configurações padrão
    m_config.lookback_candles = 500;
    m_config.min_body_size_points = 50;
    m_config.min_body_ratio = 0.6;
    m_config.min_volume_ratio = 150; // 150% da média
    m_config.max_age_bars = 100;
    m_config.require_imbalance = true;
    m_config.require_liquidity_grab = false;
    m_config.min_distance_atr = 0.5;
    m_config.confirmation_bars = 3;
    m_config.filter_by_structure = true;
    
    // Inicializar arrays
    m_ob_count = 0;
    m_max_order_blocks = 50;
    ArrayResize(m_order_blocks, m_max_order_blocks);
    
    // Inicializar cache
    ZeroMemory(m_cache);
    
    // Inicializar estatísticas
    ZeroMemory(m_stats);
    
    // Handles de indicadores
    m_atr_handle = INVALID_HANDLE;
}

//+------------------------------------------------------------------+
//| IMPLEMENTAÇÃO DO DESTRUTOR                                       |
//+------------------------------------------------------------------+

COrderBlockDetector::~COrderBlockDetector()
{
    Deinit();
}

//+------------------------------------------------------------------+
//| INICIALIZAÇÃO                                                    |
//+------------------------------------------------------------------+

bool COrderBlockDetector::Init()
{
    if(m_initialized)
        return true;
    
    LogInfo("Inicializando OrderBlockDetector para " + m_symbol + " " + EnumToString((ENUM_TIMEFRAMES)m_timeframe));
    
    // Inicializar arrays de dados
    InitializeArrays();
    
    // Criar handle do ATR
    m_atr_handle = iATR(m_symbol, (ENUM_TIMEFRAMES)m_timeframe, 14);
    if(m_atr_handle == INVALID_HANDLE)
    {
        LogError("Falha ao criar handle do ATR");
        return false;
    }
    
    // Aguardar dados do indicador
    if(CopyBuffer(m_atr_handle, 0, 0, 1, m_atr_buffer) <= 0)
    {
        LogWarning("Aguardando dados do ATR...");
    }
    
    // Atualizar dados de mercado
    UpdateMarketData();
    
    // Atualizar cache
    UpdateCache();
    
    m_initialized = true;
    LogInfo("OrderBlockDetector inicializado com sucesso");
    
    return true;
}

//+------------------------------------------------------------------+
//| DESINICIALIZAÇÃO                                                 |
//+------------------------------------------------------------------+

void COrderBlockDetector::Deinit()
{
    if(!m_initialized)
        return;
    
    LogInfo("Desinicializando OrderBlockDetector...");
    
    // Liberar handles
    if(m_atr_handle != INVALID_HANDLE)
    {
        IndicatorRelease(m_atr_handle);
        m_atr_handle = INVALID_HANDLE;
    }
    
    // Imprimir estatísticas finais
    LogInfo("Estatísticas finais: " + IntegerToString(m_stats.total_detected) + " Order Blocks detectados");
    
    m_initialized = false;
    LogInfo("OrderBlockDetector desinicializado");
}

//+------------------------------------------------------------------+
//| AUTO-TESTE                                                       |
//+------------------------------------------------------------------+

bool COrderBlockDetector::SelfTest()
{
    if(!m_initialized)
        return false;
    
    LogInfo("Executando auto-teste do OrderBlockDetector...");
    
    // Verificar dados básicos
    if(ArraySize(m_high) < 10)
    {
        LogError("Falha no teste: dados de mercado insuficientes");
        return false;
    }
    
    // Verificar ATR
    if(GetCurrentATR() <= 0)
    {
        LogError("Falha no teste: ATR inválido");
        return false;
    }
    
    // Testar detecção básica
    int initial_count = m_ob_count;
    ScanForOrderBlocks();
    
    if(m_ob_count < 0)
    {
        LogError("Falha no teste: contagem de Order Blocks inválida");
        return false;
    }
    
    // Testar validação
    for(int i = 0; i < m_ob_count; i++)
    {
        if(!ValidateOrderBlock(m_order_blocks[i]))
        {
            LogWarning("Order Block inválido detectado no índice " + IntegerToString(i));
        }
    }
    
    LogInfo("Auto-teste do OrderBlockDetector concluído com sucesso");
    return true;
}

//+------------------------------------------------------------------+
//| SCAN PRINCIPAL PARA ORDER BLOCKS                                 |
//+------------------------------------------------------------------+

void COrderBlockDetector::ScanForOrderBlocks()
{
    if(!m_initialized)
        return;
    
    // Atualizar dados se necessário
    if(!IsCacheValid())
    {
        UpdateMarketData();
        UpdateCache();
    }
    
    int bars_to_scan = MathMin(m_config.lookback_candles, ArraySize(m_high) - 10);
    
    // Scan para Order Blocks bullish
    for(int i = 10; i < bars_to_scan; i++)
    {
        if(DetectBullishOrderBlock(i))
        {
            m_stats.bullish_blocks++;
        }
    }
    
    // Scan para Order Blocks bearish
    for(int i = 10; i < bars_to_scan; i++)
    {
        if(DetectBearishOrderBlock(i))
        {
            m_stats.bearish_blocks++;
        }
    }
    
    // Atualizar Order Blocks existentes
    UpdateOrderBlocks();
    
    // Remover expirados
    RemoveExpiredBlocks();
    
    // Calcular estatísticas
    CalculateStatistics();
    
    LogDebug("Scan concluído: " + IntegerToString(m_ob_count) + " Order Blocks ativos");
}

//+------------------------------------------------------------------+
//| DETECTAR ORDER BLOCK BULLISH                                     |
//+------------------------------------------------------------------+

bool COrderBlockDetector::DetectBullishOrderBlock(int start_bar)
{
    if(start_bar < 5 || start_bar >= ArraySize(m_high) - 5)
        return false;
    
    // Verificar se é uma vela válida para Order Block
    if(!IsValidCandle(start_bar))
        return false;
    
    // Verificar padrão de Order Block bullish
    // 1. Vela bearish forte (Order Block)
    // 2. Seguida por movimento bullish
    // 3. Com possível imbalance
    
    bool is_bearish_candle = m_close[start_bar] < m_open[start_bar];
    if(!is_bearish_candle)
        return false;
    
    // Verificar tamanho do corpo
    double body_size = CalculateBodySize(start_bar);
    if(body_size < m_config.min_body_size_points * SymbolInfoDouble(m_symbol, SYMBOL_POINT))
        return false;
    
    // Verificar ratio do corpo
    double body_ratio = CalculateBodyRatio(start_bar);
    if(body_ratio < m_config.min_body_ratio)
        return false;
    
    // Verificar volume
    double volume_ratio = GetVolumeRatio(start_bar);
    if(volume_ratio < m_config.min_volume_ratio / 100.0)
        return false;
    
    // Verificar movimento subsequente bullish
    bool has_bullish_move = false;
    for(int i = start_bar - 1; i >= MathMax(0, start_bar - 5); i--)
    {
        if(m_close[i] > m_high[start_bar])
        {
            has_bullish_move = true;
            break;
        }
    }
    
    if(!has_bullish_move)
        return false;
    
    // Verificar imbalance se requerido
    if(m_config.require_imbalance && !HasImbalance(start_bar, OB_TYPE_BULLISH))
        return false;
    
    // Verificar captura de liquidez se requerido
    if(m_config.require_liquidity_grab && !HasLiquidityGrab(start_bar, OB_TYPE_BULLISH))
        return false;
    
    // Verificar alinhamento com estrutura
    if(m_config.filter_by_structure && !CheckStructureAlignment(OB_TYPE_BULLISH))
        return false;
    
    // Criar Order Block
    SOrderBlock new_block;
    ZeroMemory(new_block);
    
    new_block.type = OB_TYPE_BULLISH;
    new_block.timeframe = m_timeframe;
    new_block.symbol = m_symbol;
    new_block.time_created = m_time[start_bar];
    new_block.high = m_high[start_bar];
    new_block.low = m_low[start_bar];
    new_block.open = m_open[start_bar];
    new_block.close = m_close[start_bar];
    new_block.volume = m_volume[start_bar];
    new_block.strength = body_ratio * volume_ratio;
    new_block.reliability = (int)(CalculateBodyRatio(start_bar) * 100);
    new_block.is_valid = true;
    new_block.is_active = true;
    new_block.touch_count = 0;
    new_block.last_touch_time = 0;
    new_block.expiry_time = m_time[start_bar] + m_config.max_age_bars * PeriodSeconds((ENUM_TIMEFRAMES)m_timeframe);
    
    // Validar Order Block
    if(!ValidateOrderBlock(new_block))
        return false;
    
    // Adicionar à lista
    AddOrderBlock(new_block);
    
    // Log
    LogOrderBlock(new_block, "DETECTADO");
    
    m_stats.total_detected++;
    
    return true;
}

//+------------------------------------------------------------------+
//| DETECTAR ORDER BLOCK BEARISH                                     |
//+------------------------------------------------------------------+

bool COrderBlockDetector::DetectBearishOrderBlock(int start_bar)
{
    if(start_bar < 5 || start_bar >= ArraySize(m_high) - 5)
        return false;
    
    // Verificar se é uma vela válida para Order Block
    if(!IsValidCandle(start_bar))
        return false;
    
    // Verificar padrão de Order Block bearish
    // 1. Vela bullish forte (Order Block)
    // 2. Seguida por movimento bearish
    // 3. Com possível imbalance
    
    bool is_bullish_candle = m_close[start_bar] > m_open[start_bar];
    if(!is_bullish_candle)
        return false;
    
    // Verificar tamanho do corpo
    double body_size = CalculateBodySize(start_bar);
    if(body_size < m_config.min_body_size_points * SymbolInfoDouble(m_symbol, SYMBOL_POINT))
        return false;
    
    // Verificar ratio do corpo
    double body_ratio = CalculateBodyRatio(start_bar);
    if(body_ratio < m_config.min_body_ratio)
        return false;
    
    // Verificar volume
    double volume_ratio = GetVolumeRatio(start_bar);
    if(volume_ratio < m_config.min_volume_ratio / 100.0)
        return false;
    
    // Verificar movimento subsequente bearish
    bool has_bearish_move = false;
    for(int i = start_bar - 1; i >= MathMax(0, start_bar - 5); i--)
    {
        if(m_close[i] < m_low[start_bar])
        {
            has_bearish_move = true;
            break;
        }
    }
    
    if(!has_bearish_move)
        return false;
    
    // Verificar imbalance se requerido
    if(m_config.require_imbalance && !HasImbalance(start_bar, OB_TYPE_BEARISH))
        return false;
    
    // Verificar captura de liquidez se requerido
    if(m_config.require_liquidity_grab && !HasLiquidityGrab(start_bar, OB_TYPE_BEARISH))
        return false;
    
    // Verificar alinhamento com estrutura
    if(m_config.filter_by_structure && !CheckStructureAlignment(OB_TYPE_BEARISH))
        return false;
    
    // Criar Order Block
    SOrderBlock new_block;
    ZeroMemory(new_block);
    
    new_block.type = OB_TYPE_BEARISH;
    new_block.timeframe = m_timeframe;
    new_block.symbol = m_symbol;
    new_block.time_created = m_time[start_bar];
    new_block.high = m_high[start_bar];
    new_block.low = m_low[start_bar];
    new_block.open = m_open[start_bar];
    new_block.close = m_close[start_bar];
    new_block.volume = m_volume[start_bar];
    new_block.strength = body_ratio * volume_ratio;
    new_block.reliability = CalculateBodyRatio(start_bar) * 100;
    new_block.is_valid = true;
    new_block.is_active = true;
    new_block.touch_count = 0;
    new_block.last_touch_time = 0;
    new_block.expiry_time = m_time[start_bar] + m_config.max_age_bars * PeriodSeconds((ENUM_TIMEFRAMES)m_timeframe);
    
    // Validar Order Block
    if(!ValidateOrderBlock(new_block))
        return false;
    
    // Adicionar à lista
    AddOrderBlock(new_block);
    
    // Log
    LogOrderBlock(new_block, "DETECTADO");
    
    m_stats.total_detected++;
    
    return true;
}

//+------------------------------------------------------------------+
//| MÉTODOS AUXILIARES                                               |
//+------------------------------------------------------------------+

void COrderBlockDetector::InitializeArrays()
{
    int bars_needed = m_config.lookback_candles + 50;
    
    ArraySetAsSeries(m_high, true);
    ArraySetAsSeries(m_low, true);
    ArraySetAsSeries(m_open, true);
    ArraySetAsSeries(m_close, true);
    ArraySetAsSeries(m_volume, true);
    ArraySetAsSeries(m_time, true);
    ArraySetAsSeries(m_atr_buffer, true);
    
    ArrayResize(m_high, bars_needed);
    ArrayResize(m_low, bars_needed);
    ArrayResize(m_open, bars_needed);
    ArrayResize(m_close, bars_needed);
    ArrayResize(m_volume, bars_needed);
    ArrayResize(m_time, bars_needed);
    ArrayResize(m_atr_buffer, bars_needed);
}

void COrderBlockDetector::UpdateMarketData()
{
    int bars_copied = CopyHigh(m_symbol, (ENUM_TIMEFRAMES)m_timeframe, 0, m_config.lookback_candles, m_high);
    if(bars_copied <= 0)
    {
        Print("Erro ao copiar dados High para ", m_symbol);
        return false;
    }
    
    CopyLow(m_symbol, (ENUM_TIMEFRAMES)m_timeframe, 0, m_config.lookback_candles, m_low);
    CopyOpen(m_symbol, (ENUM_TIMEFRAMES)m_timeframe, 0, m_config.lookback_candles, m_open);
    CopyClose(m_symbol, (ENUM_TIMEFRAMES)m_timeframe, 0, m_config.lookback_candles, m_close);
    CopyTickVolume(m_symbol, (ENUM_TIMEFRAMES)m_timeframe, 0, m_config.lookback_candles, m_volume);
    CopyTime(m_symbol, (ENUM_TIMEFRAMES)m_timeframe, 0, m_config.lookback_candles, m_time);
    
    if(m_atr_handle != INVALID_HANDLE)
    {
        CopyBuffer(m_atr_handle, 0, 0, m_config.lookback_candles, m_atr_buffer);
    }
}

double COrderBlockDetector::CalculateBodySize(int bar_index)
{
    if(bar_index < 0 || bar_index >= ArraySize(m_high))
        return 0.0;
    
    return MathAbs(m_close[bar_index] - m_open[bar_index]);
}

double COrderBlockDetector::CalculateBodyRatio(int bar_index)
{
    if(bar_index < 0 || bar_index >= ArraySize(m_high))
        return 0.0;
    
    double total_range = m_high[bar_index] - m_low[bar_index];
    if(total_range <= 0)
        return 0.0;
    
    double body_size = CalculateBodySize(bar_index);
    return body_size / total_range;
}

double COrderBlockDetector::GetCurrentATR()
{
    if(m_atr_handle == INVALID_HANDLE || ArraySize(m_atr_buffer) == 0)
        return 0.0;
    
    return m_atr_buffer[0];
}

bool COrderBlockDetector::IsValidCandle(int bar_index)
{
    if(bar_index < 0 || bar_index >= ArraySize(m_high))
        return false;
    
    // Verificar se a vela tem dados válidos
    if(m_high[bar_index] <= m_low[bar_index])
        return false;
    
    if(m_open[bar_index] <= 0 || m_close[bar_index] <= 0)
        return false;
    
    return true;
}

void COrderBlockDetector::AddOrderBlock(SOrderBlock &block)
{
    // Verificar se já existe Order Block similar
    for(int i = 0; i < m_ob_count; i++)
    {
        if(m_order_blocks[i].type == block.type &&
           MathAbs(m_order_blocks[i].time_created - block.time_created) < PeriodSeconds((ENUM_TIMEFRAMES)m_timeframe) * 3)
        {
            // Order Block similar já existe
            return;
        }
    }
    
    // Adicionar novo Order Block
    if(m_ob_count >= m_max_order_blocks)
    {
        // Remover o mais antigo
        for(int i = 0; i < m_ob_count - 1; i++)
        {
            m_order_blocks[i] = m_order_blocks[i + 1];
        }
        m_ob_count--;
    }
    
    m_order_blocks[m_ob_count] = block;
    m_ob_count++;
}

int COrderBlockDetector::GetOrderBlockCount()
{
    return m_ob_count;
}

SOrderBlock COrderBlockDetector::GetOrderBlock(int index)
{
    SOrderBlock empty_block;
    ZeroMemory(empty_block);
    
    if(index < 0 || index >= m_ob_count)
        return empty_block;
    
    return m_order_blocks[index];
}

void COrderBlockDetector::LogOrderBlock(SOrderBlock &block, string action)
{
    string log_msg = action + " Order Block " + EnumToString(block.type) + 
                    " em " + TimeToString(block.time_created) +
                    " | High: " + DoubleToString(block.high, 5) +
                    " | Low: " + DoubleToString(block.low, 5) +
                    " | Strength: " + DoubleToString(block.strength, 2);
    
    LogInfo(log_msg);
}

//+------------------------------------------------------------------+
//| MÉTODOS PÚBLICOS ADICIONAIS                                      |
//+------------------------------------------------------------------+

void COrderBlockDetector::SetSymbol(string symbol)
{
    if(symbol != "" && symbol != m_symbol)
    {
        m_symbol = symbol;
        if(m_initialized)
        {
            // Reinicializar com novo símbolo
            Deinit();
            Init();
        }
    }
}

void COrderBlockDetector::SetTimeframe(int timeframe)
{
    if(timeframe != m_timeframe)
    {
        m_timeframe = timeframe;
        if(m_initialized)
        {
            // Reinicializar com novo timeframe
            Deinit();
            Init();
        }
    }
}

bool COrderBlockDetector::ValidateOrderBlock(SOrderBlock &block)
{
    // Verificar dados básicos
    if(block.high <= block.low)
        return false;
    
    if(block.time_created <= 0)
        return false;
    
    if(block.strength <= 0)
        return false;
    
    // Verificar se não está expirado
    if(TimeCurrent() > block.expiry_time)
        return false;
    
    return true;
}

void COrderBlockDetector::UpdateCache()
{
    m_cache.last_update = TimeCurrent();
    m_cache.last_bar_count = Bars(m_symbol, (ENUM_TIMEFRAMES)m_timeframe);
    m_cache.avg_volume = GetAverageVolume();
    m_cache.current_atr = GetCurrentATR();
    m_cache.structure_bullish = IsStructureBullish();
    m_cache.structure_bearish = IsStructureBearish();
}

bool COrderBlockDetector::IsCacheValid()
{
    // Cache válido por 1 minuto ou até nova barra
    if(TimeCurrent() - m_cache.last_update > 60)
        return false;
    
    if(Bars(m_symbol, (ENUM_TIMEFRAMES)m_timeframe) != m_cache.last_bar_count)
        return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| INSTÂNCIA GLOBAL                                                 |
//+------------------------------------------------------------------+

COrderBlockDetector* g_order_block_detector = NULL;

//+------------------------------------------------------------------+
//| FIM DO ARQUIVO                                                   |
//+------------------------------------------------------------------+