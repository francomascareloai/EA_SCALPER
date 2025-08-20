//+------------------------------------------------------------------+
//|                                             FVGDetector.mqh     |
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
//| DETECTOR DE FAIR VALUE GAPS (ICT/SMC)                           |
//+------------------------------------------------------------------+

class CFVGDetector : public IModule
{
private:
    // Estado do módulo
    bool                m_initialized;
    string              m_module_name;
    string              m_version;
    string              m_symbol;
    int                 m_timeframe;
    
    // Configurações de detecção
    struct SFVGConfig
    {
        int     lookback_candles;        // Velas para análise
        double  min_gap_size_points;     // Tamanho mínimo do gap em pontos
        double  min_gap_size_atr;        // Tamanho mínimo em ATR
        double  max_gap_size_atr;        // Tamanho máximo em ATR
        int     max_age_bars;            // Idade máxima em barras
        bool    require_volume_spike;    // Exigir spike de volume
        double  volume_spike_ratio;      // Ratio mínimo de volume
        bool    filter_by_structure;     // Filtrar por estrutura de mercado
        bool    allow_partial_fill;      // Permitir preenchimento parcial
        double  partial_fill_ratio;      // % mínimo para considerar preenchido
        int     confirmation_bars;       // Barras para confirmação
        bool    require_momentum;        // Exigir momentum
        double  momentum_threshold;      // Threshold de momentum
    };
    
    SFVGConfig          m_config;
    
    // Fair Value Gaps detectados
    SFairValueGap       m_fvgs[];
    int                 m_fvg_count;
    int                 m_max_fvgs;
    
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
    int                 m_momentum_handle;
    double              m_momentum_buffer[];
    
    // Cache de cálculos
    struct SFVGCache
    {
        datetime last_update;
        int      last_bar_count;
        double   avg_volume;
        double   current_atr;
        double   current_momentum;
        bool     structure_bullish;
        bool     structure_bearish;
        double   last_gap_high;
        double   last_gap_low;
    };
    
    SFVGCache           m_cache;
    
    // Estatísticas
    struct SFVGStatistics
    {
        int     total_detected;
        int     bullish_fvgs;
        int     bearish_fvgs;
        int     filled_fvgs;
        int     partially_filled;
        int     expired_fvgs;
        double  avg_gap_size;
        double  avg_fill_time;
        double  fill_success_rate;
        int     avg_duration;
    };
    
    SFVGStatistics      m_stats;
    
    // Métodos privados de detecção
    bool                DetectBullishFVG(int middle_bar);
    bool                DetectBearishFVG(int middle_bar);
    bool                ValidateFVG(SFairValueGap &fvg);
    bool                IsValidGapPattern(int bar1, int bar2, int bar3);
    bool                HasVolumeSpike(int bar_index);
    bool                HasSufficientMomentum(int bar_index, ENUM_FVG_TYPE type);
    
    // Métodos de análise
    double              CalculateGapSize(double high, double low);
    double              GetGapSizeInATR(double gap_size);
    double              GetVolumeRatio(int bar_index);
    double              GetCurrentATR();
    double              GetCurrentMomentum();
    double              GetAverageVolume(int periods = 20);
    bool                IsStructureBullish();
    bool                IsStructureBearish();
    
    // Métodos de validação
    bool                IsMinimumGapSize(double gap_size);
    bool                IsMaximumGapSize(double gap_size);
    bool                IsWithinMaxAge(datetime fvg_time);
    bool                CheckStructureAlignment(ENUM_FVG_TYPE type);
    
    // Métodos de preenchimento
    void                CheckFVGFills();
    bool                IsFVGFilled(SFairValueGap &fvg, double current_price);
    bool                IsFVGPartiallyFilled(SFairValueGap &fvg, double current_price);
    double              CalculateFillPercentage(SFairValueGap &fvg, double current_price);
    
    // Métodos de gerenciamento
    void                AddFVG(SFairValueGap &fvg);
    void                UpdateFVGs();
    void                RemoveExpiredFVGs();
    void                RemoveFilledFVGs();
    int                 FindFVGIndex(datetime time, ENUM_FVG_TYPE type);
    
    // Métodos de cache
    void                UpdateCache();
    bool                IsCacheValid();
    string              GetCacheKey(string suffix = "");
    
    // Métodos auxiliares
    void                InitializeArrays();
    void                UpdateMarketData();
    void                CalculateStatistics();
    void                LogFVG(SFairValueGap &fvg, string action);
    
public:
    // Construtor e destrutor
                        CFVGDetector(string symbol = "", int timeframe = PERIOD_CURRENT);
                        ~CFVGDetector();
    
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
    void                SetMinGapSizePoints(double points);
    void                SetMinGapSizeATR(double atr_multiplier);
    void                SetMaxGapSizeATR(double atr_multiplier);
    void                SetMaxAge(int bars);
    void                SetRequireVolumeSpike(bool require);
    void                SetVolumeSpikeRatio(double ratio);
    void                SetFilterByStructure(bool filter);
    void                SetAllowPartialFill(bool allow);
    void                SetPartialFillRatio(double ratio);
    void                SetConfirmationBars(int bars);
    void                SetRequireMomentum(bool require);
    void                SetMomentumThreshold(double threshold);
    void                SetMaxFVGs(int max_fvgs);
    
    // Detecção principal
    void                ScanForFVGs();
    void                UpdateDetection();
    bool                HasNewFVGs();
    
    // Acesso aos FVGs
    int                 GetFVGCount();
    SFairValueGap       GetFVG(int index);
    SFairValueGap       GetLatestFVG(ENUM_FVG_TYPE type = FVG_TYPE_ANY);
    SFairValueGap       GetNearestFVG(double price, ENUM_FVG_TYPE type = FVG_TYPE_ANY);
    
    // Consultas específicas
    bool                HasBullishFVG(double price_level, double tolerance = 0.0);
    bool                HasBearishFVG(double price_level, double tolerance = 0.0);
    bool                IsPriceInFVG(double price, ENUM_FVG_TYPE type = FVG_TYPE_ANY);
    double              GetNearestFVGDistance(double price);
    
    // Análise de preenchimento
    bool                IsFVGUnfilled(int index);
    bool                IsFVGPartiallyFilled(int index);
    bool                IsFVGCompletelyFilled(int index);
    double              GetFVGFillPercentage(int index);
    
    // Análise de qualidade
    double              GetFVGStrength(int index);
    double              GetFVGReliability(int index);
    bool                IsFVGValid(int index);
    bool                IsFVGActive(int index);
    
    // Filtragem
    void                GetFVGsByType(ENUM_FVG_TYPE type, SFairValueGap &fvgs[]);
    void                GetFVGsByTimeframe(int timeframe, SFairValueGap &fvgs[]);
    void                GetFVGsInRange(double min_price, double max_price, SFairValueGap &fvgs[]);
    void                GetUnfilledFVGs(SFairValueGap &fvgs[]);
    void                GetRecentFVGs(int max_age_bars, SFairValueGap &fvgs[]);
    
    // Estatísticas e análise
    SFVGStatistics      GetStatistics();
    double              GetFillSuccessRate(ENUM_FVG_TYPE type = FVG_TYPE_ANY);
    double              GetAverageGapSize();
    double              GetAverageFillTime();
    
    // Alertas e notificações
    bool                CheckFVGTouch(double current_price);
    bool                CheckFVGFill(double current_price);
    void                SetupAlerts(bool enable_touch = true, bool enable_fill = true);
    
    // Exportação e relatórios
    string              GetDetectionReport();
    bool                ExportFVGs(string filename);
    void                DrawFVGsOnChart(bool enable = true);
    
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

CFVGDetector::CFVGDetector(string symbol = "", int timeframe = PERIOD_CURRENT)
{
    m_initialized = false;
    m_module_name = "FVGDetector";
    m_version = "1.00";
    
    // Configurar símbolo e timeframe
    m_symbol = (symbol == "") ? Symbol() : symbol;
    m_timeframe = (timeframe == PERIOD_CURRENT) ? Period() : timeframe;
    
    // Configurações padrão
    m_config.lookback_candles = 500;
    m_config.min_gap_size_points = 20;
    m_config.min_gap_size_atr = 0.3;
    m_config.max_gap_size_atr = 2.0;
    m_config.max_age_bars = 50;
    m_config.require_volume_spike = true;
    m_config.volume_spike_ratio = 1.5; // 150% da média
    m_config.filter_by_structure = true;
    m_config.allow_partial_fill = true;
    m_config.partial_fill_ratio = 0.7; // 70%
    m_config.confirmation_bars = 2;
    m_config.require_momentum = false;
    m_config.momentum_threshold = 0.5;
    
    // Inicializar arrays
    m_fvg_count = 0;
    m_max_fvgs = 30;
    ArrayResize(m_fvgs, m_max_fvgs);
    
    // Inicializar cache
    ZeroMemory(m_cache);
    
    // Inicializar estatísticas
    ZeroMemory(m_stats);
    
    // Handles de indicadores
    m_atr_handle = INVALID_HANDLE;
    m_momentum_handle = INVALID_HANDLE;
}

//+------------------------------------------------------------------+
//| IMPLEMENTAÇÃO DO DESTRUTOR                                       |
//+------------------------------------------------------------------+

CFVGDetector::~CFVGDetector()
{
    Deinit();
}

//+------------------------------------------------------------------+
//| INICIALIZAÇÃO                                                    |
//+------------------------------------------------------------------+

bool CFVGDetector::Init()
{
    if(m_initialized)
        return true;
    
    LogInfo("Inicializando FVGDetector para " + m_symbol + " " + EnumToString((ENUM_TIMEFRAMES)m_timeframe));
    
    // Inicializar arrays de dados
    InitializeArrays();
    
    // Criar handle do ATR
    m_atr_handle = iATR(m_symbol, (ENUM_TIMEFRAMES)m_timeframe, 14);
    if(m_atr_handle == INVALID_HANDLE)
    {
        LogError("Falha ao criar handle do ATR");
        return false;
    }
    
    // Criar handle do momentum (RSI como proxy)
    if(m_config.require_momentum)
    {
        m_momentum_handle = iRSI(m_symbol, (ENUM_TIMEFRAMES)m_timeframe, 14, PRICE_CLOSE);
        if(m_momentum_handle == INVALID_HANDLE)
        {
            LogWarning("Falha ao criar handle do momentum, continuando sem...");
            m_config.require_momentum = false;
        }
    }
    
    // Aguardar dados dos indicadores
    if(CopyBuffer(m_atr_handle, 0, 0, 1, m_atr_buffer) <= 0)
    {
        LogWarning("Aguardando dados do ATR...");
    }
    
    // Atualizar dados de mercado
    UpdateMarketData();
    
    // Atualizar cache
    UpdateCache();
    
    m_initialized = true;
    LogInfo("FVGDetector inicializado com sucesso");
    
    return true;
}

//+------------------------------------------------------------------+
//| DESINICIALIZAÇÃO                                                 |
//+------------------------------------------------------------------+

void CFVGDetector::Deinit()
{
    if(!m_initialized)
        return;
    
    LogInfo("Desinicializando FVGDetector...");
    
    // Liberar handles
    if(m_atr_handle != INVALID_HANDLE)
    {
        IndicatorRelease(m_atr_handle);
        m_atr_handle = INVALID_HANDLE;
    }
    
    if(m_momentum_handle != INVALID_HANDLE)
    {
        IndicatorRelease(m_momentum_handle);
        m_momentum_handle = INVALID_HANDLE;
    }
    
    // Imprimir estatísticas finais
    LogInfo("Estatísticas finais: " + IntegerToString(m_stats.total_detected) + " FVGs detectados");
    
    m_initialized = false;
    LogInfo("FVGDetector desinicializado");
}

//+------------------------------------------------------------------+
//| AUTO-TESTE                                                       |
//+------------------------------------------------------------------+

bool CFVGDetector::SelfTest()
{
    if(!m_initialized)
        return false;
    
    LogInfo("Executando auto-teste do FVGDetector...");
    
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
    int initial_count = m_fvg_count;
    ScanForFVGs();
    
    if(m_fvg_count < 0)
    {
        LogError("Falha no teste: contagem de FVGs inválida");
        return false;
    }
    
    // Testar validação
    for(int i = 0; i < m_fvg_count; i++)
    {
        if(!ValidateFVG(m_fvgs[i]))
        {
            LogWarning("FVG inválido detectado no índice " + IntegerToString(i));
        }
    }
    
    LogInfo("Auto-teste do FVGDetector concluído com sucesso");
    return true;
}

//+------------------------------------------------------------------+
//| SCAN PRINCIPAL PARA FVGS                                         |
//+------------------------------------------------------------------+

void CFVGDetector::ScanForFVGs()
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
    
    // Scan para FVGs (precisa de 3 velas consecutivas)
    for(int i = 2; i < bars_to_scan - 2; i++)
    {
        // Verificar padrão de 3 velas para FVG bullish
        if(DetectBullishFVG(i))
        {
            m_stats.bullish_fvgs++;
        }
        
        // Verificar padrão de 3 velas para FVG bearish
        if(DetectBearishFVG(i))
        {
            m_stats.bearish_fvgs++;
        }
    }
    
    // Verificar preenchimentos
    CheckFVGFills();
    
    // Atualizar FVGs existentes
    UpdateFVGs();
    
    // Remover expirados
    RemoveExpiredFVGs();
    
    // Calcular estatísticas
    CalculateStatistics();
    
    LogDebug("Scan FVG concluído: " + IntegerToString(m_fvg_count) + " FVGs ativos");
}

//+------------------------------------------------------------------+
//| DETECTAR FVG BULLISH                                             |
//+------------------------------------------------------------------+

bool CFVGDetector::DetectBullishFVG(int middle_bar)
{
    if(middle_bar < 1 || middle_bar >= ArraySize(m_high) - 1)
        return false;
    
    int bar1 = middle_bar + 1; // Vela anterior
    int bar2 = middle_bar;     // Vela do meio
    int bar3 = middle_bar - 1; // Vela posterior
    
    // Verificar se é um padrão válido de 3 velas
    if(!IsValidGapPattern(bar1, bar2, bar3))
        return false;
    
    // Para FVG bullish:
    // 1. Vela 1 (anterior): bearish ou neutra
    // 2. Vela 2 (meio): bullish forte
    // 3. Vela 3 (posterior): bullish ou neutra
    // 4. Gap: high da vela 1 < low da vela 3
    
    // Verificar se vela do meio é bullish
    if(m_close[bar2] <= m_open[bar2])
        return false;
    
    // Verificar se existe gap
    double gap_high = m_low[bar3];  // Low da vela 3
    double gap_low = m_high[bar1];  // High da vela 1
    
    if(gap_high <= gap_low)
        return false; // Não há gap
    
    double gap_size = gap_high - gap_low;
    
    // Verificar tamanho mínimo do gap
    if(!IsMinimumGapSize(gap_size))
        return false;
    
    // Verificar tamanho máximo do gap
    if(!IsMaximumGapSize(gap_size))
        return false;
    
    // Verificar spike de volume se requerido
    if(m_config.require_volume_spike && !HasVolumeSpike(bar2))
        return false;
    
    // Verificar momentum se requerido
    if(m_config.require_momentum && !HasSufficientMomentum(bar2, FVG_TYPE_BULLISH))
        return false;
    
    // Verificar alinhamento com estrutura
    if(m_config.filter_by_structure && !CheckStructureAlignment(FVG_TYPE_BULLISH))
        return false;
    
    // Criar FVG
    SFairValueGap new_fvg;
    ZeroMemory(new_fvg);
    
    new_fvg.type = FVG_TYPE_BULLISH;
    new_fvg.timeframe = m_timeframe;
    new_fvg.symbol = m_symbol;
    new_fvg.time_created = m_time[bar2];
    new_fvg.high = gap_high;
    new_fvg.low = gap_low;
    new_fvg.size = gap_size;
    new_fvg.volume = m_volume[bar2];
    new_fvg.strength = CalculateGapSize(gap_high, gap_low) / GetCurrentATR();
    new_fvg.reliability = GetVolumeRatio(bar2) * 50;
    new_fvg.is_filled = false;
    new_fvg.fill_percentage = 0.0;
    new_fvg.is_active = true;
    new_fvg.touch_count = 0;
    new_fvg.last_touch_time = 0;
    new_fvg.expiry_time = m_time[bar2] + m_config.max_age_bars * PeriodSeconds((ENUM_TIMEFRAMES)m_timeframe);
    
    // Validar FVG
    if(!ValidateFVG(new_fvg))
        return false;
    
    // Adicionar à lista
    AddFVG(new_fvg);
    
    // Log
    LogFVG(new_fvg, "DETECTADO");
    
    m_stats.total_detected++;
    
    return true;
}

//+------------------------------------------------------------------+
//| DETECTAR FVG BEARISH                                             |
//+------------------------------------------------------------------+

bool CFVGDetector::DetectBearishFVG(int middle_bar)
{
    if(middle_bar < 1 || middle_bar >= ArraySize(m_high) - 1)
        return false;
    
    int bar1 = middle_bar + 1; // Vela anterior
    int bar2 = middle_bar;     // Vela do meio
    int bar3 = middle_bar - 1; // Vela posterior
    
    // Verificar se é um padrão válido de 3 velas
    if(!IsValidGapPattern(bar1, bar2, bar3))
        return false;
    
    // Para FVG bearish:
    // 1. Vela 1 (anterior): bullish ou neutra
    // 2. Vela 2 (meio): bearish forte
    // 3. Vela 3 (posterior): bearish ou neutra
    // 4. Gap: low da vela 1 > high da vela 3
    
    // Verificar se vela do meio é bearish
    if(m_close[bar2] >= m_open[bar2])
        return false;
    
    // Verificar se existe gap
    double gap_high = m_low[bar1];  // Low da vela 1
    double gap_low = m_high[bar3];  // High da vela 3
    
    if(gap_high <= gap_low)
        return false; // Não há gap
    
    double gap_size = gap_high - gap_low;
    
    // Verificar tamanho mínimo do gap
    if(!IsMinimumGapSize(gap_size))
        return false;
    
    // Verificar tamanho máximo do gap
    if(!IsMaximumGapSize(gap_size))
        return false;
    
    // Verificar spike de volume se requerido
    if(m_config.require_volume_spike && !HasVolumeSpike(bar2))
        return false;
    
    // Verificar momentum se requerido
    if(m_config.require_momentum && !HasSufficientMomentum(bar2, FVG_TYPE_BEARISH))
        return false;
    
    // Verificar alinhamento com estrutura
    if(m_config.filter_by_structure && !CheckStructureAlignment(FVG_TYPE_BEARISH))
        return false;
    
    // Criar FVG
    SFairValueGap new_fvg;
    ZeroMemory(new_fvg);
    
    new_fvg.type = FVG_TYPE_BEARISH;
    new_fvg.timeframe = m_timeframe;
    new_fvg.symbol = m_symbol;
    new_fvg.time_created = m_time[bar2];
    new_fvg.high = gap_high;
    new_fvg.low = gap_low;
    new_fvg.size = gap_size;
    new_fvg.volume = m_volume[bar2];
    new_fvg.strength = CalculateGapSize(gap_high, gap_low) / GetCurrentATR();
    new_fvg.reliability = GetVolumeRatio(bar2) * 50;
    new_fvg.is_filled = false;
    new_fvg.fill_percentage = 0.0;
    new_fvg.is_active = true;
    new_fvg.touch_count = 0;
    new_fvg.last_touch_time = 0;
    new_fvg.expiry_time = m_time[bar2] + m_config.max_age_bars * PeriodSeconds((ENUM_TIMEFRAMES)m_timeframe);
    
    // Validar FVG
    if(!ValidateFVG(new_fvg))
        return false;
    
    // Adicionar à lista
    AddFVG(new_fvg);
    
    // Log
    LogFVG(new_fvg, "DETECTADO");
    
    m_stats.total_detected++;
    
    return true;
}

//+------------------------------------------------------------------+
//| MÉTODOS AUXILIARES                                               |
//+------------------------------------------------------------------+

void CFVGDetector::InitializeArrays()
{
    int bars_needed = m_config.lookback_candles + 50;
    
    ArraySetAsSeries(m_high, true);
    ArraySetAsSeries(m_low, true);
    ArraySetAsSeries(m_open, true);
    ArraySetAsSeries(m_close, true);
    ArraySetAsSeries(m_volume, true);
    ArraySetAsSeries(m_time, true);
    ArraySetAsSeries(m_atr_buffer, true);
    ArraySetAsSeries(m_momentum_buffer, true);
    
    ArrayResize(m_high, bars_needed);
    ArrayResize(m_low, bars_needed);
    ArrayResize(m_open, bars_needed);
    ArrayResize(m_close, bars_needed);
    ArrayResize(m_volume, bars_needed);
    ArrayResize(m_time, bars_needed);
    ArrayResize(m_atr_buffer, bars_needed);
    ArrayResize(m_momentum_buffer, bars_needed);
}

void CFVGDetector::UpdateMarketData()
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
    
    if(m_momentum_handle != INVALID_HANDLE)
    {
        CopyBuffer(m_momentum_handle, 0, 0, m_config.lookback_candles, m_momentum_buffer);
    }
}

double CFVGDetector::CalculateGapSize(double high, double low)
{
    return MathAbs(high - low);
}

double CFVGDetector::GetGapSizeInATR(double gap_size)
{
    double current_atr = GetCurrentATR();
    if(current_atr <= 0)
        return 0.0;
    
    return gap_size / current_atr;
}

double CFVGDetector::GetCurrentATR()
{
    if(m_atr_handle == INVALID_HANDLE || ArraySize(m_atr_buffer) == 0)
        return 0.0;
    
    return m_atr_buffer[0];
}

bool CFVGDetector::IsValidGapPattern(int bar1, int bar2, int bar3)
{
    // Verificar se todas as barras têm dados válidos
    if(bar1 < 0 || bar1 >= ArraySize(m_high) ||
       bar2 < 0 || bar2 >= ArraySize(m_high) ||
       bar3 < 0 || bar3 >= ArraySize(m_high))
        return false;
    
    // Verificar se as velas têm dados válidos
    for(int i = bar3; i <= bar1; i++)
    {
        if(m_high[i] <= m_low[i] || m_open[i] <= 0 || m_close[i] <= 0)
            return false;
    }
    
    return true;
}

bool CFVGDetector::HasVolumeSpike(int bar_index)
{
    if(bar_index < 0 || bar_index >= ArraySize(m_volume))
        return false;
    
    double volume_ratio = GetVolumeRatio(bar_index);
    return volume_ratio >= m_config.volume_spike_ratio;
}

double CFVGDetector::GetVolumeRatio(int bar_index)
{
    if(bar_index < 0 || bar_index >= ArraySize(m_volume))
        return 0.0;
    
    double avg_volume = GetAverageVolume();
    if(avg_volume <= 0)
        return 0.0;
    
    return (double)m_volume[bar_index] / avg_volume;
}

double CFVGDetector::GetAverageVolume(int periods = 20)
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

bool CFVGDetector::IsMinimumGapSize(double gap_size)
{
    // Verificar tamanho em pontos
    double min_points = m_config.min_gap_size_points * SymbolInfoDouble(m_symbol, SYMBOL_POINT);
    if(gap_size < min_points)
        return false;
    
    // Verificar tamanho em ATR
    double gap_atr = GetGapSizeInATR(gap_size);
    if(gap_atr < m_config.min_gap_size_atr)
        return false;
    
    return true;
}

bool CFVGDetector::IsMaximumGapSize(double gap_size)
{
    double gap_atr = GetGapSizeInATR(gap_size);
    return gap_atr <= m_config.max_gap_size_atr;
}

void CFVGDetector::AddFVG(SFairValueGap &fvg)
{
    // Verificar se já existe FVG similar
    for(int i = 0; i < m_fvg_count; i++)
    {
        if(m_fvgs[i].type == fvg.type &&
           MathAbs(m_fvgs[i].time_created - fvg.time_created) < PeriodSeconds((ENUM_TIMEFRAMES)m_timeframe) * 3)
        {
            // FVG similar já existe
            return;
        }
    }
    
    // Adicionar novo FVG
    if(m_fvg_count >= m_max_fvgs)
    {
        // Remover o mais antigo
        for(int i = 0; i < m_fvg_count - 1; i++)
        {
            m_fvgs[i] = m_fvgs[i + 1];
        }
        m_fvg_count--;
    }
    
    m_fvgs[m_fvg_count] = fvg;
    m_fvg_count++;
}

int CFVGDetector::GetFVGCount()
{
    return m_fvg_count;
}

SFairValueGap CFVGDetector::GetFVG(int index)
{
    SFairValueGap empty_fvg;
    ZeroMemory(empty_fvg);
    
    if(index < 0 || index >= m_fvg_count)
        return empty_fvg;
    
    return m_fvgs[index];
}

void CFVGDetector::LogFVG(SFairValueGap &fvg, string action)
{
    string log_msg = action + " FVG " + EnumToString(fvg.type) + 
                    " em " + TimeToString(fvg.time_created) +
                    " | High: " + DoubleToString(fvg.high, 5) +
                    " | Low: " + DoubleToString(fvg.low, 5) +
                    " | Size: " + DoubleToString(fvg.size, 5) +
                    " | Strength: " + DoubleToString(fvg.strength, 2);
    
    LogInfo(log_msg);
}

bool CFVGDetector::ValidateFVG(SFairValueGap &fvg)
{
    // Verificar dados básicos
    if(fvg.high <= fvg.low)
        return false;
    
    if(fvg.time_created <= 0)
        return false;
    
    if(fvg.size <= 0)
        return false;
    
    // Verificar se não está expirado
    if(TimeCurrent() > fvg.expiry_time)
        return false;
    
    return true;
}

void CFVGDetector::CheckFVGFills()
{
    double current_price = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    
    for(int i = 0; i < m_fvg_count; i++)
    {
        if(!m_fvgs[i].is_active || m_fvgs[i].is_filled)
            continue;
        
        // Verificar se FVG foi preenchido
        if(IsFVGFilled(m_fvgs[i], current_price))
        {
            m_fvgs[i].is_filled = true;
            m_fvgs[i].fill_percentage = 100.0;
            m_fvgs[i].fill_time = TimeCurrent();
            m_stats.filled_fvgs++;
            
            LogFVG(m_fvgs[i], "PREENCHIDO");
        }
        else if(IsFVGPartiallyFilled(m_fvgs[i], current_price))
        {
            double fill_pct = CalculateFillPercentage(m_fvgs[i], current_price);
            if(fill_pct > m_fvgs[i].fill_percentage)
            {
                m_fvgs[i].fill_percentage = fill_pct;
                m_fvgs[i].last_touch_time = TimeCurrent();
                m_fvgs[i].touch_count++;
            }
        }
    }
}

bool CFVGDetector::IsFVGFilled(SFairValueGap &fvg, double current_price)
{
    if(fvg.type == FVG_TYPE_BULLISH)
    {
        // FVG bullish é preenchido quando preço toca o low do gap
        return current_price <= fvg.low;
    }
    else if(fvg.type == FVG_TYPE_BEARISH)
    {
        // FVG bearish é preenchido quando preço toca o high do gap
        return current_price >= fvg.high;
    }
    
    return false;
}

bool CFVGDetector::IsFVGPartiallyFilled(SFairValueGap &fvg, double current_price)
{
    // Verificar se preço está dentro do gap
    return (current_price >= fvg.low && current_price <= fvg.high);
}

double CFVGDetector::CalculateFillPercentage(SFairValueGap &fvg, double current_price)
{
    if(!IsFVGPartiallyFilled(fvg, current_price))
        return 0.0;
    
    double gap_size = fvg.high - fvg.low;
    if(gap_size <= 0)
        return 0.0;
    
    double filled_size;
    
    if(fvg.type == FVG_TYPE_BULLISH)
    {
        // Para FVG bullish, preenchimento começa do high
        filled_size = fvg.high - current_price;
    }
    else
    {
        // Para FVG bearish, preenchimento começa do low
        filled_size = current_price - fvg.low;
    }
    
    return (filled_size / gap_size) * 100.0;
}

void CFVGDetector::UpdateCache()
{
    m_cache.last_update = TimeCurrent();
    m_cache.last_bar_count = Bars(m_symbol, (ENUM_TIMEFRAMES)m_timeframe);
    m_cache.avg_volume = GetAverageVolume();
    m_cache.current_atr = GetCurrentATR();
    m_cache.current_momentum = GetCurrentMomentum();
    m_cache.structure_bullish = IsStructureBullish();
    m_cache.structure_bearish = IsStructureBearish();
}

bool CFVGDetector::IsCacheValid()
{
    // Cache válido por 1 minuto ou até nova barra
    if(TimeCurrent() - m_cache.last_update > 60)
        return false;
    
    if(Bars(m_symbol, (ENUM_TIMEFRAMES)m_timeframe) != m_cache.last_bar_count)
        return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| MÉTODOS PÚBLICOS ADICIONAIS                                      |
//+------------------------------------------------------------------+

void CFVGDetector::SetSymbol(string symbol)
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

void CFVGDetector::SetTimeframe(int timeframe)
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

double CFVGDetector::GetCurrentMomentum()
{
    if(m_momentum_handle == INVALID_HANDLE || ArraySize(m_momentum_buffer) == 0)
        return 50.0; // Neutro
    
    return m_momentum_buffer[0];
}

bool CFVGDetector::HasSufficientMomentum(int bar_index, ENUM_FVG_TYPE type)
{
    if(m_momentum_handle == INVALID_HANDLE)
        return true; // Se não temos momentum, assumir que está OK
    
    double momentum = (bar_index < ArraySize(m_momentum_buffer)) ? m_momentum_buffer[bar_index] : 50.0;
    
    if(type == FVG_TYPE_BULLISH)
    {
        return momentum > (50.0 + m_config.momentum_threshold);
    }
    else if(type == FVG_TYPE_BEARISH)
    {
        return momentum < (50.0 - m_config.momentum_threshold);
    }
    
    return true;
}

bool CFVGDetector::IsStructureBullish()
{
    // Implementação simplificada - pode ser expandida
    if(ArraySize(m_close) < 10)
        return false;
    
    // Verificar se preço está acima da média das últimas 10 velas
    double avg_price = 0;
    for(int i = 0; i < 10; i++)
    {
        avg_price += m_close[i];
    }
    avg_price /= 10;
    
    return m_close[0] > avg_price;
}

bool CFVGDetector::IsStructureBearish()
{
    // Implementação simplificada - pode ser expandida
    if(ArraySize(m_close) < 10)
        return false;
    
    // Verificar se preço está abaixo da média das últimas 10 velas
    double avg_price = 0;
    for(int i = 0; i < 10; i++)
    {
        avg_price += m_close[i];
    }
    avg_price /= 10;
    
    return m_close[0] < avg_price;
}

bool CFVGDetector::CheckStructureAlignment(ENUM_FVG_TYPE type)
{
    if(type == FVG_TYPE_BULLISH)
        return IsStructureBullish();
    else if(type == FVG_TYPE_BEARISH)
        return IsStructureBearish();
    
    return true;
}

void CFVGDetector::UpdateFVGs()
{
    // Atualizar status dos FVGs existentes
    for(int i = 0; i < m_fvg_count; i++)
    {
        // Verificar se ainda está ativo
        if(TimeCurrent() > m_fvgs[i].expiry_time)
        {
            m_fvgs[i].is_active = false;
        }
    }
}

void CFVGDetector::RemoveExpiredFVGs()
{
    for(int i = m_fvg_count - 1; i >= 0; i--)
    {
        if(!m_fvgs[i].is_active || TimeCurrent() > m_fvgs[i].expiry_time)
        {
            // Remover FVG expirado
            for(int j = i; j < m_fvg_count - 1; j++)
            {
                m_fvgs[j] = m_fvgs[j + 1];
            }
            m_fvg_count--;
            m_stats.expired_fvgs++;
        }
    }
}

void CFVGDetector::CalculateStatistics()
{
    if(m_fvg_count == 0)
        return;
    
    // Calcular tamanho médio dos gaps
    double total_size = 0;
    int valid_count = 0;
    
    for(int i = 0; i < m_fvg_count; i++)
    {
        if(m_fvgs[i].is_active)
        {
            total_size += m_fvgs[i].size;
            valid_count++;
        }
    }
    
    if(valid_count > 0)
    {
        m_stats.avg_gap_size = total_size / valid_count;
    }
    
    // Calcular taxa de sucesso
    if(m_stats.total_detected > 0)
    {
        m_stats.fill_success_rate = (double)m_stats.filled_fvgs / m_stats.total_detected * 100.0;
    }
}

//+------------------------------------------------------------------+
//| INSTÂNCIA GLOBAL                                                 |
//+------------------------------------------------------------------+

CFVGDetector* g_fvg_detector = NULL;

//+------------------------------------------------------------------+
//| FIM DO ARQUIVO                                                   |
//+------------------------------------------------------------------+