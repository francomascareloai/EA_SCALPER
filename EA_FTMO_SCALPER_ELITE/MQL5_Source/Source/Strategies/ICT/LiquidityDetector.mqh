//+------------------------------------------------------------------+
//|                                        LiquidityDetector.mqh    |
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
//| DETECTOR DE LIQUIDITY ZONES (ICT/SMC)                           |
//+------------------------------------------------------------------+

// Estrutura de estatísticas de liquidez
struct SLiquidityStatistics
{
    int     total_zones_detected;
    int     buy_liquidity_zones;
    int     sell_liquidity_zones;
    int     equal_highs_detected;
    int     equal_lows_detected;
    int     liquidity_sweeps;
    int     stop_hunts;
    int     successful_sweeps;
    double  avg_zone_strength;
    double  sweep_success_rate;
    int     zones_respected;
    int     zones_violated;
};

class CLiquidityDetector : public IModule
{
private:
    // Estado do módulo
    bool                m_initialized;
    string              m_module_name;
    string              m_version;
    string              m_symbol;
    int                 m_timeframe;
    
    // Configurações de detecção
    struct SLiquidityConfig
    {
        int     lookback_periods;           // Períodos para análise
        int     swing_detection_bars;       // Barras para detecção de swing
        double  min_liquidity_size_atr;     // Tamanho mínimo em ATR
        double  max_liquidity_age_hours;    // Idade máxima em horas
        bool    detect_equal_highs;         // Detectar equal highs
        bool    detect_equal_lows;          // Detectar equal lows
        bool    detect_liquidity_sweeps;    // Detectar liquidity sweeps
        bool    detect_stop_hunts;          // Detectar stop hunts
        double  equal_level_tolerance;      // Tolerância para níveis iguais (ATR)
        int     min_touches_for_liquidity;  // Mínimo de toques para considerar liquidez
        double  volume_confirmation_ratio;  // Ratio de volume para confirmação
        bool    require_volume_confirmation; // Exigir confirmação por volume
        double  sweep_confirmation_pips;    // Pips para confirmar sweep
        bool    filter_by_session;          // Filtrar por sessão
        int     major_session_start;        // Início da sessão principal
        int     major_session_end;          // Fim da sessão principal
    };
    
    SLiquidityConfig    m_config;
    
    // Zonas de liquidez detectadas
    SLiquidityZone      m_liquidity_zones[];
    int                 m_zone_count;
    int                 m_max_zones;
    
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
    
    // Estruturas auxiliares
    struct SSwingPoint
    {
        datetime time;
        double   price;
        ENUM_LIQUIDITY_TYPE type;
        int      bar_index;
        int      touch_count;
        bool     is_swept;
        datetime sweep_time;
        double   sweep_price;
    };
    
    SSwingPoint         m_swing_highs[];
    SSwingPoint         m_swing_lows[];
    int                 m_swing_high_count;
    int                 m_swing_low_count;
    
    // Cache de cálculos
    struct SLiquidityCache
    {
        datetime last_update;
        int      last_bar_count;
        double   current_atr;
        double   avg_volume;
        bool     in_major_session;
        double   session_high;
        double   session_low;
        int      recent_sweeps;
    };
    
    SLiquidityCache     m_cache;
    
    // Estatísticas
    SLiquidityStatistics m_stats;
    
    // Métodos privados de detecção
    void                DetectSwingPoints();
    void                DetectEqualHighs();
    void                DetectEqualLows();
    void                DetectLiquiditySweeps();
    void                DetectStopHunts();
    
    // Métodos de análise de swing
    bool                IsSwingHigh(int bar_index);
    bool                IsSwingLow(int bar_index);
    void                AddSwingHigh(int bar_index);
    void                AddSwingLow(int bar_index);
    
    // Métodos de detecção de equal levels
    bool                AreEqualLevels(double price1, double price2);
    void                FindEqualHighs();
    void                FindEqualLows();
    
    // Métodos de análise de liquidez
    double              CalculateZoneStrength(SLiquidityZone &zone);
    double              CalculateZoneReliability(SLiquidityZone &zone);
    bool                IsZoneActive(SLiquidityZone &zone);
    bool                IsZoneRespected(SLiquidityZone &zone);
    
    // Métodos de sweep detection
    bool                IsSweepCandidate(double current_price, SSwingPoint &swing);
    bool                ConfirmSweep(SSwingPoint &swing, double sweep_price);
    void                ProcessSweep(SSwingPoint &swing, double sweep_price);
    
    // Métodos de validação
    bool                ValidateLiquidityZone(SLiquidityZone &zone);
    bool                HasVolumeConfirmation(int bar_index);
    bool                IsInMajorSession(datetime time);
    bool                IsValidTimeframe();
    
    // Métodos de análise
    double              GetCurrentATR();
    double              GetAverageVolume(int periods = 20);
    double              GetVolumeRatio(int bar_index);
    double              CalculateDistanceInATR(double price1, double price2);
    
    // Métodos de gerenciamento
    void                AddLiquidityZone(SLiquidityZone &zone);
    void                UpdateLiquidityZones();
    void                RemoveExpiredZones();
    void                RemoveSweptZones();
    int                 FindZoneIndex(double price, ENUM_LIQUIDITY_TYPE type);
    
    // Métodos de cache
    void                UpdateCache();
    bool                IsCacheValid();
    string              GetCacheKey(string suffix = "");
    
    // Métodos auxiliares
    void                InitializeArrays();
    void                UpdateMarketData();
    void                CalculateStatistics();
    void                LogLiquidityZone(SLiquidityZone &zone, string action);
    void                LogSweep(SSwingPoint &swing, string action);
    
public:
    // Construtor e destrutor
                        CLiquidityDetector(string symbol = "", int timeframe = PERIOD_CURRENT);
                        ~CLiquidityDetector();
    
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
    void                SetLookbackPeriods(int periods);
    void                SetSwingDetectionBars(int bars);
    void                SetMinLiquiditySizeATR(double atr_multiplier);
    void                SetMaxLiquidityAge(double hours);
    void                SetDetectEqualHighs(bool detect);
    void                SetDetectEqualLows(bool detect);
    void                SetDetectLiquiditySweeps(bool detect);
    void                SetDetectStopHunts(bool detect);
    void                SetEqualLevelTolerance(double tolerance_atr);
    void                SetMinTouchesForLiquidity(int touches);
    void                SetVolumeConfirmationRatio(double ratio);
    void                SetRequireVolumeConfirmation(bool require);
    void                SetSweepConfirmationPips(double pips);
    void                SetFilterBySession(bool filter);
    void                SetMajorSession(int start_hour, int end_hour);
    void                SetMaxZones(int max_zones);
    
    // Detecção principal
    void                ScanForLiquidity();
    void                UpdateDetection();
    bool                HasNewLiquidityZones();
    
    // Acesso às zonas de liquidez
    int                 GetZoneCount();
    SLiquidityZone      GetZone(int index);
    SLiquidityZone      GetLatestZone(ENUM_LIQUIDITY_TYPE type = LIQUIDITY_TYPE_ANY);
    SLiquidityZone      GetNearestZone(double price, ENUM_LIQUIDITY_TYPE type = LIQUIDITY_TYPE_ANY);
    
    // Consultas específicas
    bool                HasBuyLiquidity(double price_level, double tolerance = 0.0);
    bool                HasSellLiquidity(double price_level, double tolerance = 0.0);
    bool                IsPriceNearLiquidity(double price, double tolerance_atr = 0.5);
    double              GetNearestLiquidityDistance(double price);
    
    // Análise de sweeps
    bool                IsLiquiditySwept(int zone_index);
    bool                HasRecentSweep(int minutes = 60);
    SSwingPoint         GetLastSweptLevel(ENUM_LIQUIDITY_TYPE type = LIQUIDITY_TYPE_ANY);
    
    // Análise de qualidade
    double              GetZoneStrength(int index);
    double              GetZoneReliability(int index);
    bool                IsZoneValid(int index);
    bool                IsZoneActive(int index);
    
    // Filtragem
    void                GetZonesByType(ENUM_LIQUIDITY_TYPE type, SLiquidityZone &zones[]);
    void                GetZonesByTimeframe(int timeframe, SLiquidityZone &zones[]);
    void                GetZonesInRange(double min_price, double max_price, SLiquidityZone &zones[]);
    void                GetActiveZones(SLiquidityZone &zones[]);
    void                GetRecentZones(int max_age_hours, SLiquidityZone &zones[]);
    
    // Estatísticas e análise
    SLiquidityStatistics GetStatistics();
    double              GetSweepSuccessRate(ENUM_LIQUIDITY_TYPE type = LIQUIDITY_TYPE_ANY);
    double              GetAverageZoneStrength();
    int                 GetRecentSweepCount(int hours = 24);
    
    // Alertas e notificações
    bool                CheckLiquidityTouch(double current_price);
    bool                CheckLiquiditySweep(double current_price);
    void                SetupAlerts(bool enable_touch = true, bool enable_sweep = true);
    
    // Exportação e relatórios
    string              GetDetectionReport();
    bool                ExportLiquidityZones(string filename);
    void                DrawLiquidityOnChart(bool enable = true);
    
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

CLiquidityDetector::CLiquidityDetector(string symbol = "", int timeframe = PERIOD_CURRENT)
{
    m_initialized = false;
    m_module_name = "LiquidityDetector";
    m_version = "1.00";
    
    // Configurar símbolo e timeframe
    m_symbol = (symbol == "") ? Symbol() : symbol;
    m_timeframe = (timeframe == PERIOD_CURRENT) ? Period() : timeframe;
    
    // Configurações padrão
    m_config.lookback_periods = 200;
    m_config.swing_detection_bars = 5;
    m_config.min_liquidity_size_atr = 0.5;
    m_config.max_liquidity_age_hours = 24.0;
    m_config.detect_equal_highs = true;
    m_config.detect_equal_lows = true;
    m_config.detect_liquidity_sweeps = true;
    m_config.detect_stop_hunts = true;
    m_config.equal_level_tolerance = 0.2; // 20% do ATR
    m_config.min_touches_for_liquidity = 2;
    m_config.volume_confirmation_ratio = 1.3; // 130% da média
    m_config.require_volume_confirmation = false;
    m_config.sweep_confirmation_pips = 5.0;
    m_config.filter_by_session = false;
    m_config.major_session_start = 8;  // 8:00 GMT
    m_config.major_session_end = 17;   // 17:00 GMT
    
    // Inicializar arrays
    m_zone_count = 0;
    m_max_zones = 20;
    ArrayResize(m_liquidity_zones, m_max_zones);
    
    m_swing_high_count = 0;
    m_swing_low_count = 0;
    ArrayResize(m_swing_highs, 50);
    ArrayResize(m_swing_lows, 50);
    
    // Inicializar cache
    ZeroMemory(m_cache);
    
    // Inicializar estatísticas
    ZeroMemory(m_stats);
    
    // Handle de indicador
    m_atr_handle = INVALID_HANDLE;
}

//+------------------------------------------------------------------+
//| IMPLEMENTAÇÃO DO DESTRUTOR                                       |
//+------------------------------------------------------------------+

CLiquidityDetector::~CLiquidityDetector()
{
    Deinit();
}

//+------------------------------------------------------------------+
//| INICIALIZAÇÃO                                                    |
//+------------------------------------------------------------------+

bool CLiquidityDetector::Init()
{
    if(m_initialized)
        return true;
    
    LogInfo("Inicializando LiquidityDetector para " + m_symbol + " " + EnumToString((ENUM_TIMEFRAMES)m_timeframe));
    
    // Inicializar arrays de dados
    InitializeArrays();
    
    // Criar handle do ATR
    m_atr_handle = iATR(m_symbol, (ENUM_TIMEFRAMES)m_timeframe, 14);
    if(m_atr_handle == INVALID_HANDLE)
    {
        LogError("Falha ao criar handle do ATR");
        return false;
    }
    
    // Aguardar dados do ATR
    if(CopyBuffer(m_atr_handle, 0, 0, 1, m_atr_buffer) <= 0)
    {
        LogWarning("Aguardando dados do ATR...");
    }
    
    // Atualizar dados de mercado
    UpdateMarketData();
    
    // Atualizar cache
    UpdateCache();
    
    m_initialized = true;
    LogInfo("LiquidityDetector inicializado com sucesso");
    
    return true;
}

//+------------------------------------------------------------------+
//| DESINICIALIZAÇÃO                                                 |
//+------------------------------------------------------------------+

void CLiquidityDetector::Deinit()
{
    if(!m_initialized)
        return;
    
    LogInfo("Desinicializando LiquidityDetector...");
    
    // Liberar handle
    if(m_atr_handle != INVALID_HANDLE)
    {
        IndicatorRelease(m_atr_handle);
        m_atr_handle = INVALID_HANDLE;
    }
    
    // Imprimir estatísticas finais
    LogInfo("Estatísticas finais: " + IntegerToString(m_stats.total_zones_detected) + " zonas de liquidez detectadas");
    
    m_initialized = false;
    LogInfo("LiquidityDetector desinicializado");
}

//+------------------------------------------------------------------+
//| AUTO-TESTE                                                       |
//+------------------------------------------------------------------+

bool CLiquidityDetector::SelfTest()
{
    if(!m_initialized)
        return false;
    
    LogInfo("Executando auto-teste do LiquidityDetector...");
    
    // Verificar dados básicos
    if(ArraySize(m_high) < 20)
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
    int initial_count = m_zone_count;
    ScanForLiquidity();
    
    if(m_zone_count < 0)
    {
        LogError("Falha no teste: contagem de zonas inválida");
        return false;
    }
    
    // Testar validação
    for(int i = 0; i < m_zone_count; i++)
    {
        if(!ValidateLiquidityZone(m_liquidity_zones[i]))
        {
            LogWarning("Zona de liquidez inválida detectada no índice " + IntegerToString(i));
        }
    }
    
    LogInfo("Auto-teste do LiquidityDetector concluído com sucesso");
    return true;
}

//+------------------------------------------------------------------+
//| SCAN PRINCIPAL PARA LIQUIDEZ                                     |
//+------------------------------------------------------------------+

void CLiquidityDetector::ScanForLiquidity()
{
    if(!m_initialized)
        return;
    
    // Atualizar dados se necessário
    if(!IsCacheValid())
    {
        UpdateMarketData();
        UpdateCache();
    }
    
    // Detectar swing points
    DetectSwingPoints();
    
    // Detectar equal highs e lows
    if(m_config.detect_equal_highs)
        DetectEqualHighs();
    
    if(m_config.detect_equal_lows)
        DetectEqualLows();
    
    // Detectar liquidity sweeps
    if(m_config.detect_liquidity_sweeps)
        DetectLiquiditySweeps();
    
    // Detectar stop hunts
    if(m_config.detect_stop_hunts)
        DetectStopHunts();
    
    // Atualizar zonas existentes
    UpdateLiquidityZones();
    
    // Remover zonas expiradas
    RemoveExpiredZones();
    
    // Calcular estatísticas
    CalculateStatistics();
    
    LogDebug("Scan de liquidez concluído: " + IntegerToString(m_zone_count) + " zonas ativas");
}

//+------------------------------------------------------------------+
//| DETECTAR SWING POINTS                                            |
//+------------------------------------------------------------------+

void CLiquidityDetector::DetectSwingPoints()
{
    int bars_to_scan = MathMin(m_config.lookback_periods, ArraySize(m_high) - m_config.swing_detection_bars * 2);
    
    // Reset contadores
    m_swing_high_count = 0;
    m_swing_low_count = 0;
    
    // Scan para swing highs e lows
    for(int i = m_config.swing_detection_bars; i < bars_to_scan - m_config.swing_detection_bars; i++)
    {
        if(IsSwingHigh(i))
        {
            AddSwingHigh(i);
        }
        
        if(IsSwingLow(i))
        {
            AddSwingLow(i);
        }
    }
    
    LogDebug("Swing points detectados: " + IntegerToString(m_swing_high_count) + " highs, " + 
             IntegerToString(m_swing_low_count) + " lows");
}

//+------------------------------------------------------------------+
//| VERIFICAR SE É SWING HIGH                                        |
//+------------------------------------------------------------------+

bool CLiquidityDetector::IsSwingHigh(int bar_index)
{
    if(bar_index < m_config.swing_detection_bars || 
       bar_index >= ArraySize(m_high) - m_config.swing_detection_bars)
        return false;
    
    double current_high = m_high[bar_index];
    
    // Verificar se é o ponto mais alto nas barras ao redor
    for(int i = 1; i <= m_config.swing_detection_bars; i++)
    {
        // Verificar barras anteriores
        if(m_high[bar_index + i] >= current_high)
            return false;
        
        // Verificar barras posteriores
        if(m_high[bar_index - i] >= current_high)
            return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| VERIFICAR SE É SWING LOW                                         |
//+------------------------------------------------------------------+

bool CLiquidityDetector::IsSwingLow(int bar_index)
{
    if(bar_index < m_config.swing_detection_bars || 
       bar_index >= ArraySize(m_low) - m_config.swing_detection_bars)
        return false;
    
    double current_low = m_low[bar_index];
    
    // Verificar se é o ponto mais baixo nas barras ao redor
    for(int i = 1; i <= m_config.swing_detection_bars; i++)
    {
        // Verificar barras anteriores
        if(m_low[bar_index + i] <= current_low)
            return false;
        
        // Verificar barras posteriores
        if(m_low[bar_index - i] <= current_low)
            return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| ADICIONAR SWING HIGH                                             |
//+------------------------------------------------------------------+

void CLiquidityDetector::AddSwingHigh(int bar_index)
{
    if(m_swing_high_count >= ArraySize(m_swing_highs))
    {
        // Remover o mais antigo
        for(int i = 0; i < m_swing_high_count - 1; i++)
        {
            m_swing_highs[i] = m_swing_highs[i + 1];
        }
        m_swing_high_count--;
    }
    
    SSwingPoint swing;
    ZeroMemory(swing);
    
    swing.time = m_time[bar_index];
    swing.price = m_high[bar_index];
    swing.type = LIQUIDITY_TYPE_SELL; // Swing high = sell liquidity
    swing.bar_index = bar_index;
    swing.touch_count = 1;
    swing.is_swept = false;
    
    m_swing_highs[m_swing_high_count] = swing;
    m_swing_high_count++;
}

//+------------------------------------------------------------------+
//| ADICIONAR SWING LOW                                              |
//+------------------------------------------------------------------+

void CLiquidityDetector::AddSwingLow(int bar_index)
{
    if(m_swing_low_count >= ArraySize(m_swing_lows))
    {
        // Remover o mais antigo
        for(int i = 0; i < m_swing_low_count - 1; i++)
        {
            m_swing_lows[i] = m_swing_lows[i + 1];
        }
        m_swing_low_count--;
    }
    
    SSwingPoint swing;
    ZeroMemory(swing);
    
    swing.time = m_time[bar_index];
    swing.price = m_low[bar_index];
    swing.type = LIQUIDITY_TYPE_BUY; // Swing low = buy liquidity
    swing.bar_index = bar_index;
    swing.touch_count = 1;
    swing.is_swept = false;
    
    m_swing_lows[m_swing_low_count] = swing;
    m_swing_low_count++;
}

//+------------------------------------------------------------------+
//| DETECTAR EQUAL HIGHS                                             |
//+------------------------------------------------------------------+

void CLiquidityDetector::DetectEqualHighs()
{
    for(int i = 0; i < m_swing_high_count - 1; i++)
    {
        for(int j = i + 1; j < m_swing_high_count; j++)
        {
            if(AreEqualLevels(m_swing_highs[i].price, m_swing_highs[j].price))
            {
                // Criar zona de liquidez para equal highs
                SLiquidityZone zone;
                ZeroMemory(zone);
                
                zone.type = LIQUIDITY_TYPE_SELL;
                zone.timeframe = m_timeframe;
                zone.symbol = m_symbol;
                zone.time_created = MathMax(m_swing_highs[i].time, m_swing_highs[j].time);
                zone.price_level = (m_swing_highs[i].price + m_swing_highs[j].price) / 2;
                zone.upper_bound = MathMax(m_swing_highs[i].price, m_swing_highs[j].price);
                zone.lower_bound = MathMin(m_swing_highs[i].price, m_swing_highs[j].price);
                zone.strength = CalculateZoneStrength(zone);
                zone.reliability = CalculateZoneReliability(zone);
                zone.touch_count = 2; // Pelo menos 2 toques
                zone.is_active = true;
                zone.is_swept = false;
                zone.expiry_time = TimeCurrent() + (long)(m_config.max_liquidity_age_hours * 3600);
                
                if(ValidateLiquidityZone(zone))
                {
                    AddLiquidityZone(zone);
                    m_stats.equal_highs_detected++;
                    LogLiquidityZone(zone, "EQUAL HIGHS DETECTADOS");
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| DETECTAR EQUAL LOWS                                              |
//+------------------------------------------------------------------+

void CLiquidityDetector::DetectEqualLows()
{
    for(int i = 0; i < m_swing_low_count - 1; i++)
    {
        for(int j = i + 1; j < m_swing_low_count; j++)
        {
            if(AreEqualLevels(m_swing_lows[i].price, m_swing_lows[j].price))
            {
                // Criar zona de liquidez para equal lows
                SLiquidityZone zone;
                ZeroMemory(zone);
                
                zone.type = LIQUIDITY_TYPE_BUY;
                zone.timeframe = m_timeframe;
                zone.symbol = m_symbol;
                zone.time_created = MathMax(m_swing_lows[i].time, m_swing_lows[j].time);
                zone.price_level = (m_swing_lows[i].price + m_swing_lows[j].price) / 2;
                zone.upper_bound = MathMax(m_swing_lows[i].price, m_swing_lows[j].price);
                zone.lower_bound = MathMin(m_swing_lows[i].price, m_swing_lows[j].price);
                zone.strength = CalculateZoneStrength(zone);
                zone.reliability = CalculateZoneReliability(zone);
                zone.touch_count = 2; // Pelo menos 2 toques
                zone.is_active = true;
                zone.is_swept = false;
                zone.expiry_time = TimeCurrent() + (long)(m_config.max_liquidity_age_hours * 3600);
                
                if(ValidateLiquidityZone(zone))
                {
                    AddLiquidityZone(zone);
                    m_stats.equal_lows_detected++;
                    LogLiquidityZone(zone, "EQUAL LOWS DETECTADOS");
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| VERIFICAR SE SÃO NÍVEIS IGUAIS                                   |
//+------------------------------------------------------------------+

bool CLiquidityDetector::AreEqualLevels(double price1, double price2)
{
    double tolerance = GetCurrentATR() * m_config.equal_level_tolerance;
    return MathAbs(price1 - price2) <= tolerance;
}

//+------------------------------------------------------------------+
//| DETECTAR LIQUIDITY SWEEPS                                        |
//+------------------------------------------------------------------+

void CLiquidityDetector::DetectLiquiditySweeps()
{
    double current_price = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    double sweep_distance = m_config.sweep_confirmation_pips * SymbolInfoDouble(m_symbol, SYMBOL_POINT);
    
    // Verificar sweeps em swing highs
    for(int i = 0; i < m_swing_high_count; i++)
    {
        if(!m_swing_highs[i].is_swept && IsSweepCandidate(current_price, m_swing_highs[i]))
        {
            if(current_price > m_swing_highs[i].price + sweep_distance)
            {
                if(ConfirmSweep(m_swing_highs[i], current_price))
                {
                    ProcessSweep(m_swing_highs[i], current_price);
                    m_stats.liquidity_sweeps++;
                }
            }
        }
    }
    
    // Verificar sweeps em swing lows
    for(int i = 0; i < m_swing_low_count; i++)
    {
        if(!m_swing_lows[i].is_swept && IsSweepCandidate(current_price, m_swing_lows[i]))
        {
            if(current_price < m_swing_lows[i].price - sweep_distance)
            {
                if(ConfirmSweep(m_swing_lows[i], current_price))
                {
                    ProcessSweep(m_swing_lows[i], current_price);
                    m_stats.liquidity_sweeps++;
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| MÉTODOS AUXILIARES                                               |
//+------------------------------------------------------------------+

void CLiquidityDetector::InitializeArrays()
{
    int bars_needed = m_config.lookback_periods + 50;
    
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

void CLiquidityDetector::UpdateMarketData()
{
    int bars_copied = CopyHigh(m_symbol, (ENUM_TIMEFRAMES)m_timeframe, 0, m_config.lookback_periods, m_high);
    if(bars_copied <= 0)
    {
        Print("Erro ao copiar dados High para ", m_symbol);
        return false;
    }
    
    CopyLow(m_symbol, (ENUM_TIMEFRAMES)m_timeframe, 0, m_config.lookback_periods, m_low);
    CopyOpen(m_symbol, (ENUM_TIMEFRAMES)m_timeframe, 0, m_config.lookback_periods, m_open);
    CopyClose(m_symbol, (ENUM_TIMEFRAMES)m_timeframe, 0, m_config.lookback_periods, m_close);
    CopyTickVolume(m_symbol, (ENUM_TIMEFRAMES)m_timeframe, 0, m_config.lookback_periods, m_volume);
    CopyTime(m_symbol, (ENUM_TIMEFRAMES)m_timeframe, 0, m_config.lookback_periods, m_time);
    
    if(m_atr_handle != INVALID_HANDLE)
    {
        CopyBuffer(m_atr_handle, 0, 0, m_config.lookback_periods, m_atr_buffer);
    }
}

double CLiquidityDetector::GetCurrentATR()
{
    if(m_atr_handle == INVALID_HANDLE || ArraySize(m_atr_buffer) == 0)
        return 0.0;
    
    return m_atr_buffer[0];
}

double CLiquidityDetector::CalculateZoneStrength(SLiquidityZone &zone)
{
    double strength = 0.0;
    
    // Força baseada no número de toques
    strength += zone.touch_count * 20.0;
    
    // Força baseada na idade (zonas mais antigas são mais fortes)
    double age_hours = (TimeCurrent() - zone.time_created) / 3600.0;
    if(age_hours > 1.0)
        strength += MathMin(age_hours * 5.0, 50.0);
    
    // Força baseada no tamanho da zona (zonas menores são mais precisas)
    double zone_size = zone.upper_bound - zone.lower_bound;
    double atr = GetCurrentATR();
    if(atr > 0)
    {
        double size_ratio = zone_size / atr;
        if(size_ratio < 0.5)
            strength += 30.0;
        else if(size_ratio < 1.0)
            strength += 20.0;
        else
            strength += 10.0;
    }
    
    return MathMin(strength, 100.0);
}

double CLiquidityDetector::CalculateZoneReliability(SLiquidityZone &zone)
{
    double reliability = 50.0; // Base
    
    // Confiabilidade baseada no tipo de detecção
    if(zone.touch_count >= 3)
        reliability += 20.0;
    
    // Confiabilidade baseada no timeframe
    if(m_timeframe >= PERIOD_H1)
        reliability += 15.0;
    else if(m_timeframe >= PERIOD_M15)
        reliability += 10.0;
    
    // Confiabilidade baseada na sessão
    if(IsInMajorSession(zone.time_created))
        reliability += 15.0;
    
    return MathMin(reliability, 100.0);
}

bool CLiquidityDetector::ValidateLiquidityZone(SLiquidityZone &zone)
{
    // Verificar dados básicos
    if(zone.upper_bound <= zone.lower_bound)
        return false;
    
    if(zone.time_created <= 0)
        return false;
    
    // Verificar tamanho mínimo
    double zone_size = zone.upper_bound - zone.lower_bound;
    double min_size = GetCurrentATR() * m_config.min_liquidity_size_atr;
    if(zone_size < min_size)
        return false;
    
    // Verificar se não está expirado
    if(TimeCurrent() > zone.expiry_time)
        return false;
    
    return true;
}

void CLiquidityDetector::AddLiquidityZone(SLiquidityZone &zone)
{
    // Verificar se já existe zona similar
    for(int i = 0; i < m_zone_count; i++)
    {
        if(m_liquidity_zones[i].type == zone.type &&
           MathAbs(m_liquidity_zones[i].price_level - zone.price_level) < GetCurrentATR() * 0.5)
        {
            // Zona similar já existe, atualizar se necessário
            if(zone.strength > m_liquidity_zones[i].strength)
            {
                m_liquidity_zones[i] = zone;
            }
            return;
        }
    }
    
    // Adicionar nova zona
    if(m_zone_count >= m_max_zones)
    {
        // Remover a mais fraca
        int weakest_index = 0;
        double weakest_strength = m_liquidity_zones[0].strength;
        
        for(int i = 1; i < m_zone_count; i++)
        {
            if(m_liquidity_zones[i].strength < weakest_strength)
            {
                weakest_strength = m_liquidity_zones[i].strength;
                weakest_index = i;
            }
        }
        
        // Remover a mais fraca
        for(int i = weakest_index; i < m_zone_count - 1; i++)
        {
            m_liquidity_zones[i] = m_liquidity_zones[i + 1];
        }
        m_zone_count--;
    }
    
    m_liquidity_zones[m_zone_count] = zone;
    m_zone_count++;
    
    m_stats.total_zones_detected++;
    if(zone.type == LIQUIDITY_TYPE_BUY)
        m_stats.buy_liquidity_zones++;
    else
        m_stats.sell_liquidity_zones++;
}

int CLiquidityDetector::GetZoneCount()
{
    return m_zone_count;
}

SLiquidityZone CLiquidityDetector::GetZone(int index)
{
    SLiquidityZone empty_zone;
    ZeroMemory(empty_zone);
    
    if(index < 0 || index >= m_zone_count)
        return empty_zone;
    
    return m_liquidity_zones[index];
}

void CLiquidityDetector::LogLiquidityZone(SLiquidityZone &zone, string action)
{
    string log_msg = action + " Zona " + EnumToString(zone.type) + 
                    " em " + TimeToString(zone.time_created) +
                    " | Nível: " + DoubleToString(zone.price_level, 5) +
                    " | Força: " + DoubleToString(zone.strength, 1) +
                    " | Toques: " + IntegerToString(zone.touch_count);
    
    LogInfo(log_msg);
}

bool CLiquidityDetector::IsSweepCandidate(double current_price, SSwingPoint &swing)
{
    // Verificar se o preço está próximo do nível
    double distance = MathAbs(current_price - swing.price);
    double atr = GetCurrentATR();
    
    return distance <= atr * 0.5; // Dentro de 0.5 ATR
}

bool CLiquidityDetector::ConfirmSweep(SSwingPoint &swing, double sweep_price)
{
    // Verificar confirmação por volume se requerido
    if(m_config.require_volume_confirmation)
    {
        if(!HasVolumeConfirmation(0)) // Barra atual
            return false;
    }
    
    // Verificar se é um sweep válido
    double sweep_distance = MathAbs(sweep_price - swing.price);
    double min_distance = m_config.sweep_confirmation_pips * SymbolInfoDouble(m_symbol, SYMBOL_POINT);
    
    return sweep_distance >= min_distance;
}

void CLiquidityDetector::ProcessSweep(SSwingPoint &swing, double sweep_price)
{
    swing.is_swept = true;
    swing.sweep_time = TimeCurrent();
    swing.sweep_price = sweep_price;
    
    LogSweep(swing, "SWEEP CONFIRMADO");
    
    // Atualizar zonas relacionadas
    for(int i = 0; i < m_zone_count; i++)
    {
        if(m_liquidity_zones[i].type == swing.type &&
           MathAbs(m_liquidity_zones[i].price_level - swing.price) < GetCurrentATR() * 0.3)
        {
            m_liquidity_zones[i].is_swept = true;
            m_liquidity_zones[i].sweep_time = TimeCurrent();
            m_liquidity_zones[i].sweep_price = sweep_price;
        }
    }
}

void CLiquidityDetector::LogSweep(SSwingPoint &swing, string action)
{
    string log_msg = action + " " + EnumToString(swing.type) + 
                    " em " + TimeToString(swing.time) +
                    " | Preço: " + DoubleToString(swing.price, 5) +
                    " | Sweep: " + DoubleToString(swing.sweep_price, 5);
    
    LogInfo(log_msg);
}

bool CLiquidityDetector::HasVolumeConfirmation(int bar_index)
{
    if(bar_index < 0 || bar_index >= ArraySize(m_volume))
        return false;
    
    double volume_ratio = GetVolumeRatio(bar_index);
    return volume_ratio >= m_config.volume_confirmation_ratio;
}

double CLiquidityDetector::GetVolumeRatio(int bar_index)
{
    if(bar_index < 0 || bar_index >= ArraySize(m_volume))
        return 0.0;
    
    double avg_volume = GetAverageVolume();
    if(avg_volume <= 0)
        return 0.0;
    
    return (double)m_volume[bar_index] / avg_volume;
}

double CLiquidityDetector::GetAverageVolume(int periods = 20)
{
    if(ArraySize(m_volume) < periods)
        return 0.0;
    
    long total_volume = 0;
    for(int i = 0; i < periods; i++)
    {
        total_volume += m_volume[i];
    }
    
    return (double)total_volume / periods;
}

bool CLiquidityDetector::IsInMajorSession(datetime time)
{
    if(!m_config.filter_by_session)
        return true;
    
    MqlDateTime dt;
    TimeToStruct(time, dt);
    
    return (dt.hour >= m_config.major_session_start && dt.hour <= m_config.major_session_end);
}

void CLiquidityDetector::UpdateCache()
{
    m_cache.last_update = TimeCurrent();
    m_cache.last_bar_count = Bars(m_symbol, (ENUM_TIMEFRAMES)m_timeframe);
    m_cache.current_atr = GetCurrentATR();
    m_cache.avg_volume = GetAverageVolume();
    m_cache.in_major_session = IsInMajorSession(TimeCurrent());
    
    // Calcular high/low da sessão
    if(ArraySize(m_high) > 0 && ArraySize(m_low) > 0)
    {
        m_cache.session_high = m_high[0];
        m_cache.session_low = m_low[0];
        
        for(int i = 1; i < MathMin(24, ArraySize(m_high)); i++) // Últimas 24 barras
        {
            if(m_high[i] > m_cache.session_high)
                m_cache.session_high = m_high[i];
            if(m_low[i] < m_cache.session_low)
                m_cache.session_low = m_low[i];
        }
    }
}

bool CLiquidityDetector::IsCacheValid()
{
    // Cache válido por 1 minuto ou até nova barra
    if(TimeCurrent() - m_cache.last_update > 60)
        return false;
    
    if(Bars(m_symbol, (ENUM_TIMEFRAMES)m_timeframe) != m_cache.last_bar_count)
        return false;
    
    return true;
}

void CLiquidityDetector::UpdateLiquidityZones()
{
    double current_price = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    
    for(int i = 0; i < m_zone_count; i++)
    {
        // Verificar se zona foi tocada
        if(current_price >= m_liquidity_zones[i].lower_bound && 
           current_price <= m_liquidity_zones[i].upper_bound)
        {
            m_liquidity_zones[i].touch_count++;
            m_liquidity_zones[i].last_touch_time = TimeCurrent();
        }
        
        // Atualizar força e confiabilidade
        m_liquidity_zones[i].strength = CalculateZoneStrength(m_liquidity_zones[i]);
        m_liquidity_zones[i].reliability = CalculateZoneReliability(m_liquidity_zones[i]);
        
        // Verificar se ainda está ativa
        if(TimeCurrent() > m_liquidity_zones[i].expiry_time)
        {
            m_liquidity_zones[i].is_active = false;
        }
    }
}

void CLiquidityDetector::RemoveExpiredZones()
{
    for(int i = m_zone_count - 1; i >= 0; i--)
    {
        if(!m_liquidity_zones[i].is_active || TimeCurrent() > m_liquidity_zones[i].expiry_time)
        {
            // Remover zona expirada
            for(int j = i; j < m_zone_count - 1; j++)
            {
                m_liquidity_zones[j] = m_liquidity_zones[j + 1];
            }
            m_zone_count--;
        }
    }
}

void CLiquidityDetector::CalculateStatistics()
{
    if(m_zone_count == 0)
        return;
    
    // Calcular força média das zonas
    double total_strength = 0;
    int active_count = 0;
    
    for(int i = 0; i < m_zone_count; i++)
    {
        if(m_liquidity_zones[i].is_active)
        {
            total_strength += m_liquidity_zones[i].strength;
            active_count++;
        }
    }
    
    if(active_count > 0)
    {
        m_stats.avg_zone_strength = total_strength / active_count;
    }
    
    // Calcular taxa de sucesso dos sweeps
    if(m_stats.liquidity_sweeps > 0)
    {
        m_stats.sweep_success_rate = (double)m_stats.successful_sweeps / m_stats.liquidity_sweeps * 100.0;
    }
}

void CLiquidityDetector::DetectStopHunts()
{
    // Implementação simplificada de detecção de stop hunts
    // Pode ser expandida com lógica mais sofisticada
    
    double current_price = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    
    // Verificar se houve movimento rápido além de níveis de liquidez
    for(int i = 0; i < m_zone_count; i++)
    {
        if(m_liquidity_zones[i].is_active && !m_liquidity_zones[i].is_swept)
        {
            bool potential_stop_hunt = false;
            
            if(m_liquidity_zones[i].type == LIQUIDITY_TYPE_SELL)
            {
                // Stop hunt acima de sell liquidity
                if(current_price > m_liquidity_zones[i].upper_bound)
                {
                    potential_stop_hunt = true;
                }
            }
            else if(m_liquidity_zones[i].type == LIQUIDITY_TYPE_BUY)
            {
                // Stop hunt abaixo de buy liquidity
                if(current_price < m_liquidity_zones[i].lower_bound)
                {
                    potential_stop_hunt = true;
                }
            }
            
            if(potential_stop_hunt)
            {
                m_stats.stop_hunts++;
                LogLiquidityZone(m_liquidity_zones[i], "STOP HUNT DETECTADO");
            }
        }
    }
}

//+------------------------------------------------------------------+
//| MÉTODOS PÚBLICOS ADICIONAIS                                      |
//+------------------------------------------------------------------+

void CLiquidityDetector::SetSymbol(string symbol)
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

void CLiquidityDetector::SetTimeframe(int timeframe)
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

bool CLiquidityDetector::HasBuyLiquidity(double price_level, double tolerance = 0.0)
{
    if(tolerance == 0.0)
        tolerance = GetCurrentATR() * 0.2;
    
    for(int i = 0; i < m_zone_count; i++)
    {
        if(m_liquidity_zones[i].type == LIQ_TYPE_BSL && 
           m_liquidity_zones[i].is_active &&
           MathAbs(m_liquidity_zones[i].high_price - price_level) <= tolerance)
        {
            return true;
        }
    }
    
    return false;
}

bool CLiquidityDetector::HasSellLiquidity(double price_level, double tolerance = 0.0)
{
    if(tolerance == 0.0)
        tolerance = GetCurrentATR() * 0.2;
    
    for(int i = 0; i < m_zone_count; i++)
    {
        if(m_liquidity_zones[i].type == LIQ_TYPE_SSL && 
           m_liquidity_zones[i].is_active &&
           MathAbs(m_liquidity_zones[i].low_price - price_level) <= tolerance)
        {
            return true;
        }
    }
    
    return false;
}

SLiquidityZone CLiquidityDetector::GetNearestZone(double price, ENUM_LIQUIDITY_TYPE type = LIQUIDITY_TYPE_ANY)
{
    SLiquidityZone nearest_zone;
    ZeroMemory(nearest_zone);
    
    double min_distance = DBL_MAX;
    int nearest_index = -1;
    
    for(int i = 0; i < m_zone_count; i++)
    {
        if(!m_liquidity_zones[i].is_active)
            continue;
        
        if(type != LIQ_TYPE_ANY && m_liquidity_zones[i].type != type)
            continue;
        
        double zone_price = (m_liquidity_zones[i].high_price + m_liquidity_zones[i].low_price) / 2.0;
        double distance = MathAbs(zone_price - price);
        if(distance < min_distance)
        {
            min_distance = distance;
            nearest_index = i;
        }
    }
    
    if(nearest_index >= 0)
        nearest_zone = m_liquidity_zones[nearest_index];
    
    return nearest_zone;
}

SLiquidityStatistics CLiquidityDetector::GetStatistics()
{
    return m_stats;
}

//+------------------------------------------------------------------+
//| INSTÂNCIA GLOBAL                                                 |
//+------------------------------------------------------------------+

CLiquidityDetector* g_liquidity_detector = NULL;

//+------------------------------------------------------------------+
//| FIM DO ARQUIVO                                                   |
//+------------------------------------------------------------------+