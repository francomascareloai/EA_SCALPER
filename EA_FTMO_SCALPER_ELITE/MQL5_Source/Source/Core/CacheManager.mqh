//+------------------------------------------------------------------+
//|                                            CacheManager.mqh     |
//|                                    EA FTMO Scalper Elite v1.0    |
//|                                      TradeDev_Master 2024        |
//+------------------------------------------------------------------+
#property copyright "TradeDev_Master 2024"
#property version   "1.00"
#property strict

#include "Interfaces.mqh"
#include "DataStructures.mqh"
#include "Logger.mqh"

//+------------------------------------------------------------------+
//| CLASSE GERENCIADOR DE CACHE                                      |
//+------------------------------------------------------------------+

class CCacheManager : public ICacheManager
{
private:
    // Estado
    bool                m_initialized;
    string              m_module_name;
    string              m_version;
    
    // Configurações de cache
    int                 m_max_entries;
    int                 m_max_memory_mb;
    int                 m_default_ttl;
    bool                m_auto_cleanup;
    int                 m_cleanup_interval;
    
    // Cache principal
    SCacheEntry         m_cache[];
    int                 m_cache_size;
    
    // Estatísticas
    int                 m_hits;
    int                 m_misses;
    int                 m_evictions;
    int                 m_cleanups;
    datetime            m_last_cleanup;
    
    // Índices para acesso rápido
    struct SIndex
    {
        string key;
        int    index;
        datetime last_access;
    };
    
    SIndex              m_index[];
    int                 m_index_size;
    
    // Cache especializado para dados de mercado
    struct SMarketCache
    {
        string   symbol;
        datetime time;
        double   bid;
        double   ask;
        double   spread;
        long     volume;
        datetime cached_at;
    };
    
    SMarketCache        m_market_cache[];
    
    // Cache para indicadores
    struct SIndicatorCache
    {
        string   indicator_name;
        int      timeframe;
        int      period;
        int      shift;
        double   value;
        datetime calculated_at;
        bool     is_valid;
    };
    
    SIndicatorCache     m_indicator_cache[];
    
    // Cache para análise ICT
    struct SICTCache
    {
        ENUM_ICT_STRUCTURE_TYPE type;
        datetime               time;
        double                 price;
        int                    timeframe;
        bool                   is_valid;
        datetime               cached_at;
    };
    
    SICTCache           m_ict_cache[];
    
    // Métodos privados
    int                 FindCacheEntry(string key);
    int                 FindIndexEntry(string key);
    bool                AddCacheEntry(string key, string value, int ttl);
    bool                UpdateCacheEntry(int index, string value, int ttl);
    bool                RemoveCacheEntry(int index);
    void                UpdateIndex(string key, int cache_index);
    void                RemoveFromIndex(string key);
    bool                IsExpired(SCacheEntry &entry);
    void                EvictOldestEntry();
    void                EvictLRUEntry();
    int                 GetMemoryUsage();
    bool                NeedsCleanup();
    void                PerformCleanup();
    string              GenerateKey(string prefix, string data);
    bool                ValidateKey(string key);
    
    // Cache especializado
    int                 FindMarketCache(string symbol);
    int                 FindIndicatorCache(string indicator, int timeframe, int period, int shift);
    int                 FindICTCache(ENUM_ICT_STRUCTURE_TYPE type, datetime time, int timeframe);
    
public:
    // Construtor e destrutor
                        CCacheManager();
                        ~CCacheManager();
    
    // Implementação IModule
    virtual bool        Init() override;
    virtual void        Deinit() override;
    virtual bool        IsInitialized() override { return m_initialized; }
    virtual string      GetModuleName() override { return m_module_name; }
    virtual string      GetVersion() override { return m_version; }
    virtual bool        SelfTest() override;
    
    // Implementação ICacheManager
    virtual bool        Set(string key, string value, int ttl = 0) override;
    virtual string      Get(string key) override;
    virtual bool        Has(string key) override;
    virtual bool        Remove(string key) override;
    virtual bool        Clear() override;
    
    // Gestão de expiração
    virtual bool        SetTTL(string key, int ttl_seconds) override;
    virtual int         GetTTL(string key) override;
    virtual bool        IsExpired(string key) override;
    virtual void        CleanupExpired() override;
    
    // Estatísticas
    virtual int         GetCacheSize() override { return m_cache_size; }
    virtual int         GetHitCount() override { return m_hits; }
    virtual int         GetMissCount() override { return m_misses; }
    virtual double      GetHitRatio() override;
    
    // Configuração
    virtual bool        SetMaxSize(int max_entries) override;
    virtual bool        SetDefaultTTL(int ttl_seconds) override;
    virtual bool        EnableCompression(bool enable) override;
    
    // Métodos adicionais sem override
    bool                SetObject(string key, void* object, int size, int ttl = 0);
    void*               GetObject(string key);
    void                Cleanup();
    void                SetMaxEntries(int max_entries);
    void                SetMaxMemory(int max_memory_mb);
    int                 GetMemoryUsageMB();
    
    // Métodos específicos para dados de mercado
    bool                CacheMarketData(string symbol, double bid, double ask, long volume);
    bool                GetMarketData(string symbol, double &bid, double &ask, long &volume);
    bool                IsMarketDataValid(string symbol, int max_age_seconds = 5);
    
    // Métodos específicos para indicadores
    bool                CacheIndicatorValue(string indicator, int timeframe, int period, int shift, double value);
    bool                GetIndicatorValue(string indicator, int timeframe, int period, int shift, double &value);
    bool                IsIndicatorValid(string indicator, int timeframe, int period, int shift, int max_age_seconds = 60);
    
    // Métodos específicos para análise ICT
    bool                CacheICTStructure(ENUM_ICT_STRUCTURE_TYPE type, datetime time, double price, int timeframe);
    bool                GetICTStructure(ENUM_ICT_STRUCTURE_TYPE type, datetime time, int timeframe, double &price);
    bool                IsICTStructureValid(ENUM_ICT_STRUCTURE_TYPE type, datetime time, int timeframe, int max_age_seconds = 300);
    
    // Métodos de configuração
    void                EnableAutoCleanup(bool enable, int interval_seconds = 300);
    void                SetEvictionPolicy(ENUM_CACHE_EVICTION_POLICY policy);
    
    // Métodos de estatísticas
    void                PrintStatistics();
    void                ResetStatistics();
    string              GetStatisticsReport();
    
    // Métodos de manutenção
    void                Optimize();
    bool                Export(string filename);
    bool                Import(string filename);
    void                Defragment();
};

//+------------------------------------------------------------------+
//| IMPLEMENTAÇÃO DO CONSTRUTOR                                      |
//+------------------------------------------------------------------+

CCacheManager::CCacheManager()
{
    m_initialized = false;
    m_module_name = "CacheManager";
    m_version = "1.00";
    
    // Configurações padrão
    m_max_entries = CACHE_MAX_ENTRIES;
    m_max_memory_mb = CACHE_MAX_MEMORY_MB;
    m_default_ttl = CACHE_DEFAULT_TTL;
    m_auto_cleanup = true;
    m_cleanup_interval = 300; // 5 minutos
    
    // Inicializar arrays
    ArrayResize(m_cache, 0);
    ArrayResize(m_index, 0);
    ArrayResize(m_market_cache, 0);
    ArrayResize(m_indicator_cache, 0);
    ArrayResize(m_ict_cache, 0);
    
    m_cache_size = 0;
    m_index_size = 0;
    
    // Estatísticas
    m_hits = 0;
    m_misses = 0;
    m_evictions = 0;
    m_cleanups = 0;
    m_last_cleanup = TimeCurrent();
}

//+------------------------------------------------------------------+
//| IMPLEMENTAÇÃO DO DESTRUTOR                                       |
//+------------------------------------------------------------------+

CCacheManager::~CCacheManager()
{
    Deinit();
}

//+------------------------------------------------------------------+
//| INICIALIZAÇÃO                                                    |
//+------------------------------------------------------------------+

bool CCacheManager::Init()
{
    if(m_initialized)
        return true;
    
    LogInfo("Inicializando CacheManager...");
    
    // Redimensionar arrays para capacidade inicial
    ArrayResize(m_cache, m_max_entries);
    ArrayResize(m_index, m_max_entries);
    ArrayResize(m_market_cache, 100); // Cache para 100 símbolos
    ArrayResize(m_indicator_cache, 1000); // Cache para 1000 valores de indicadores
    ArrayResize(m_ict_cache, 500); // Cache para 500 estruturas ICT
    
    // Inicializar entradas
    for(int i = 0; i < m_max_entries; i++)
    {
        ZeroMemory(m_cache[i]);
        ZeroMemory(m_index[i]);
    }
    
    for(int i = 0; i < 100; i++)
        ZeroMemory(m_market_cache[i]);
    
    for(int i = 0; i < 1000; i++)
        ZeroMemory(m_indicator_cache[i]);
    
    for(int i = 0; i < 500; i++)
        ZeroMemory(m_ict_cache[i]);
    
    m_initialized = true;
    LogInfo("CacheManager inicializado com sucesso");
    
    return true;
}

//+------------------------------------------------------------------+
//| DESINICIALIZAÇÃO                                                 |
//+------------------------------------------------------------------+

void CCacheManager::Deinit()
{
    if(!m_initialized)
        return;
    
    LogInfo("Desinicializando CacheManager...");
    
    // Limpar cache
    Clear();
    
    // Imprimir estatísticas finais
    PrintStatistics();
    
    m_initialized = false;
    LogInfo("CacheManager desinicializado");
}

//+------------------------------------------------------------------+
//| AUTO-TESTE                                                       |
//+------------------------------------------------------------------+

bool CCacheManager::SelfTest()
{
    if(!m_initialized)
        return false;
    
    LogInfo("Executando auto-teste do CacheManager...");
    
    // Teste básico de cache
    string test_key = "test_key";
    string test_value = "test_value";
    
    if(!Set(test_key, test_value, 60))
    {
        LogError("Falha no teste: Set");
        return false;
    }
    
    if(!Has(test_key))
    {
        LogError("Falha no teste: Has");
        return false;
    }
    
    string retrieved = Get(test_key);
    if(retrieved != test_value)
    {
        LogError("Falha no teste: Get - valor incorreto");
        return false;
    }
    
    if(!Remove(test_key))
    {
        LogError("Falha no teste: Remove");
        return false;
    }
    
    if(Has(test_key))
    {
        LogError("Falha no teste: chave ainda existe após remoção");
        return false;
    }
    
    // Teste de cache de mercado
    string symbol = "XAUUSD";
    double bid = 1950.50;
    double ask = 1950.70;
    long volume = 1000;
    
    if(!CacheMarketData(symbol, bid, ask, volume))
    {
        LogError("Falha no teste: CacheMarketData");
        return false;
    }
    
    double test_bid, test_ask;
    long test_volume;
    
    if(!GetMarketData(symbol, test_bid, test_ask, test_volume))
    {
        LogError("Falha no teste: GetMarketData");
        return false;
    }
    
    if(test_bid != bid || test_ask != ask || test_volume != volume)
    {
        LogError("Falha no teste: dados de mercado incorretos");
        return false;
    }
    
    // Teste de cache de indicador
    string indicator = "RSI";
    int timeframe = PERIOD_M15;
    int period = 14;
    int shift = 0;
    double value = 65.5;
    
    if(!CacheIndicatorValue(indicator, timeframe, period, shift, value))
    {
        LogError("Falha no teste: CacheIndicatorValue");
        return false;
    }
    
    double indicator_test_value;
    if(!GetIndicatorValue(indicator, timeframe, period, shift, indicator_test_value))
    {
        LogError("Falha no teste: GetIndicatorValue");
        return false;
    }
    
    if(indicator_test_value != value)
    {
        LogError("Falha no teste: valor de indicador incorreto");
        return false;
    }
    
    LogInfo("Auto-teste do CacheManager concluído com sucesso");
    return true;
}

//+------------------------------------------------------------------+
//| DEFINIR VALOR NO CACHE                                           |
//+------------------------------------------------------------------+

bool CCacheManager::Set(string key, string value, int ttl = 0)
{
    if(!m_initialized || !ValidateKey(key))
        return false;
    
    if(ttl == 0)
        ttl = m_default_ttl;
    
    // Verificar se a chave já existe
    int index = FindCacheEntry(key);
    if(index >= 0)
    {
        // Atualizar entrada existente
        if(UpdateCacheEntry(index, value, ttl))
        {
            UpdateIndex(key, index);
            return true;
        }
        return false;
    }
    
    // Verificar se há espaço
    if(m_cache_size >= m_max_entries)
    {
        // Remover entrada mais antiga
        EvictLRUEntry();
    }
    
    // Verificar uso de memória
    if(GetMemoryUsage() >= m_max_memory_mb)
    {
        PerformCleanup();
        if(GetMemoryUsage() >= m_max_memory_mb)
        {
            LogWarning("Cache cheio - não é possível adicionar nova entrada");
            return false;
        }
    }
    
    // Adicionar nova entrada
    if(AddCacheEntry(key, value, ttl))
    {
        UpdateIndex(key, m_cache_size - 1);
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| OBTER VALOR DO CACHE                                             |
//+------------------------------------------------------------------+

string CCacheManager::Get(string key)
{
    if(!m_initialized || !ValidateKey(key))
    {
        m_misses++;
        return "";
    }
    
    int index = FindCacheEntry(key);
    if(index < 0)
    {
        m_misses++;
        return "";
    }
    
    // Verificar se expirou
    if(IsExpired(m_cache[index]))
    {
        RemoveCacheEntry(index);
        RemoveFromIndex(key);
        m_misses++;
        return "";
    }
    
    // Atualizar último acesso
    m_cache[index].last_access = TimeCurrent();
    m_cache[index].access_count++;
    
    // Atualizar índice
    UpdateIndex(key, index);
    
    m_hits++;
    return m_cache[index].value;
}

//+------------------------------------------------------------------+
//| VERIFICAR SE CHAVE EXISTE                                        |
//+------------------------------------------------------------------+

bool CCacheManager::Has(string key)
{
    if(!m_initialized || !ValidateKey(key))
        return false;
    
    int index = FindCacheEntry(key);
    if(index < 0)
        return false;
    
    // Verificar se expirou
    if(IsExpired(m_cache[index]))
    {
        RemoveCacheEntry(index);
        RemoveFromIndex(key);
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| REMOVER ENTRADA DO CACHE                                         |
//+------------------------------------------------------------------+

bool CCacheManager::Remove(string key)
{
    if(!m_initialized || !ValidateKey(key))
        return false;
    
    int index = FindCacheEntry(key);
    if(index < 0)
        return false;
    
    if(RemoveCacheEntry(index))
    {
        RemoveFromIndex(key);
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| LIMPAR CACHE                                                     |
//+------------------------------------------------------------------+

bool CCacheManager::Clear()
{
    if(!m_initialized)
        return false;
    
    LogInfo("Limpando cache...");
    
    // Limpar cache principal
    for(int i = 0; i < m_cache_size; i++)
    {
        ZeroMemory(m_cache[i]);
    }
    
    // Limpar índice
    for(int i = 0; i < m_index_size; i++)
    {
        ZeroMemory(m_index[i]);
    }
    
    // Limpar caches especializados
    for(int i = 0; i < ArraySize(m_market_cache); i++)
    {
        ZeroMemory(m_market_cache[i]);
    }
    
    for(int i = 0; i < ArraySize(m_indicator_cache); i++)
    {
        ZeroMemory(m_indicator_cache[i]);
    }
    
    for(int i = 0; i < ArraySize(m_ict_cache); i++)
    {
        ZeroMemory(m_ict_cache[i]);
    }
    
    m_cache_size = 0;
    m_index_size = 0;
    
    LogInfo("Cache limpo");
    return true;
}

//+------------------------------------------------------------------+
//| DEFINIR OBJETO NO CACHE                                          |
//+------------------------------------------------------------------+

bool CCacheManager::SetObject(string key, void* object, int size, int ttl = 0)
{
    // Implementação simplificada - converter objeto para string
    // Em produção, seria necessário serialização adequada
    
    if(object == NULL || size <= 0)
        return false;
    
    string value = "OBJECT:" + IntegerToString(size) + ":" + IntegerToString(0); // Simplified object storage
    return Set(key, value, ttl);
}

//+------------------------------------------------------------------+
//| OBTER OBJETO DO CACHE                                            |
//+------------------------------------------------------------------+

void* CCacheManager::GetObject(string key)
{
    string value = Get(key);
    if(value == "" || StringFind(value, "OBJECT:") != 0)
        return NULL;
    
    // Extrair ponteiro do objeto (implementação simplificada)
    string parts[];
    int count = StringSplit(value, ':', parts);
    if(count < 3)
        return NULL;
    
    return NULL; // Simplified object retrieval - return NULL for safety
}

//+------------------------------------------------------------------+
//| LIMPEZA AUTOMÁTICA                                               |
//+------------------------------------------------------------------+

void CCacheManager::Cleanup()
{
    if(!m_initialized)
        return;
    
    LogDebug("Executando limpeza do cache...");
    
    datetime current_time = TimeCurrent();
    int removed = 0;
    
    // Remover entradas expiradas do cache principal
    for(int i = m_cache_size - 1; i >= 0; i--)
    {
        if(IsExpired(m_cache[i]))
        {
            RemoveCacheEntry(i);
            removed++;
        }
    }
    
    // Limpar cache de mercado
    for(int i = ArraySize(m_market_cache) - 1; i >= 0; i--)
    {
        if(m_market_cache[i].symbol != "" && 
           (current_time - m_market_cache[i].cached_at) > 60) // 1 minuto
        {
            ZeroMemory(m_market_cache[i]);
            removed++;
        }
    }
    
    // Limpar cache de indicadores
    for(int i = ArraySize(m_indicator_cache) - 1; i >= 0; i--)
    {
        if(m_indicator_cache[i].indicator_name != "" && 
           (current_time - m_indicator_cache[i].calculated_at) > 300) // 5 minutos
        {
            ZeroMemory(m_indicator_cache[i]);
            removed++;
        }
    }
    
    // Limpar cache ICT
    for(int i = ArraySize(m_ict_cache) - 1; i >= 0; i--)
    {
        if(m_ict_cache[i].is_valid && 
           (current_time - m_ict_cache[i].cached_at) > 1800) // 30 minutos
        {
            ZeroMemory(m_ict_cache[i]);
            removed++;
        }
    }
    
    m_last_cleanup = current_time;
    m_cleanups++;
    
    if(removed > 0)
    {
        LogDebug("Limpeza concluída: " + IntegerToString(removed) + " entradas removidas");
    }
}

//+------------------------------------------------------------------+
//| DEFINIR MÁXIMO DE ENTRADAS                                       |
//+------------------------------------------------------------------+

void CCacheManager::SetMaxEntries(int max_entries)
{
    if(max_entries <= 0 || max_entries > 10000)
        return;
    
    m_max_entries = max_entries;
    
    // Redimensionar arrays se necessário
    if(ArraySize(m_cache) < max_entries)
    {
        ArrayResize(m_cache, max_entries);
        ArrayResize(m_index, max_entries);
    }
    
    // Remover entradas excedentes
    while(m_cache_size > max_entries)
    {
        EvictOldestEntry();
    }
}

//+------------------------------------------------------------------+
//| DEFINIR MÁXIMO DE MEMÓRIA                                        |
//+------------------------------------------------------------------+

void CCacheManager::SetMaxMemory(int max_memory_mb)
{
    if(max_memory_mb <= 0)
        return;
    
    m_max_memory_mb = max_memory_mb;
    
    // Limpar se necessário
    while(GetMemoryUsage() > max_memory_mb)
    {
        EvictLRUEntry();
    }
}

//+------------------------------------------------------------------+
//| OBTER TAXA DE ACERTO                                             |
//+------------------------------------------------------------------+

double CCacheManager::GetHitRatio()
{
    int total = m_hits + m_misses;
    if(total == 0)
        return 0.0;
    
    return (double)m_hits / total * 100.0;
}

//+------------------------------------------------------------------+
//| OBTER USO DE MEMÓRIA                                             |
//+------------------------------------------------------------------+

int CCacheManager::GetMemoryUsageMB()
{
    return GetMemoryUsage();
}

//+------------------------------------------------------------------+
//| CACHE DE DADOS DE MERCADO                                        |
//+------------------------------------------------------------------+

bool CCacheManager::CacheMarketData(string symbol, double bid, double ask, long volume)
{
    if(!m_initialized || symbol == "")
        return false;
    
    int index = FindMarketCache(symbol);
    if(index < 0)
    {
        // Encontrar slot vazio
        for(int i = 0; i < ArraySize(m_market_cache); i++)
        {
            if(m_market_cache[i].symbol == "")
            {
                index = i;
                break;
            }
        }
        
        if(index < 0)
        {
            // Substituir entrada mais antiga
            datetime oldest = TimeCurrent();
            for(int i = 0; i < ArraySize(m_market_cache); i++)
            {
                if(m_market_cache[i].cached_at < oldest)
                {
                    oldest = m_market_cache[i].cached_at;
                    index = i;
                }
            }
        }
    }
    
    if(index >= 0)
    {
        m_market_cache[index].symbol = symbol;
        m_market_cache[index].time = TimeCurrent();
        m_market_cache[index].bid = bid;
        m_market_cache[index].ask = ask;
        m_market_cache[index].spread = ask - bid;
        m_market_cache[index].volume = volume;
        m_market_cache[index].cached_at = TimeCurrent();
        
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| OBTER DADOS DE MERCADO                                           |
//+------------------------------------------------------------------+

bool CCacheManager::GetMarketData(string symbol, double &bid, double &ask, long &volume)
{
    if(!m_initialized || symbol == "")
        return false;
    
    int index = FindMarketCache(symbol);
    if(index < 0)
        return false;
    
    if(!IsMarketDataValid(symbol, 5))
        return false;
    
    bid = m_market_cache[index].bid;
    ask = m_market_cache[index].ask;
    volume = m_market_cache[index].volume;
    
    return true;
}

//+------------------------------------------------------------------+
//| VERIFICAR VALIDADE DOS DADOS DE MERCADO                          |
//+------------------------------------------------------------------+

bool CCacheManager::IsMarketDataValid(string symbol, int max_age_seconds = 5)
{
    int index = FindMarketCache(symbol);
    if(index < 0)
        return false;
    
    datetime current_time = TimeCurrent();
    return (current_time - m_market_cache[index].cached_at) <= max_age_seconds;
}

//+------------------------------------------------------------------+
//| MÉTODOS PRIVADOS                                                 |
//+------------------------------------------------------------------+

int CCacheManager::FindCacheEntry(string key)
{
    for(int i = 0; i < m_cache_size; i++)
    {
        if(m_cache[i].key == key)
            return i;
    }
    return -1;
}

int CCacheManager::FindIndexEntry(string key)
{
    for(int i = 0; i < m_index_size; i++)
    {
        if(m_index[i].key == key)
            return i;
    }
    return -1;
}

bool CCacheManager::AddCacheEntry(string key, string value, int ttl)
{
    if(m_cache_size >= ArraySize(m_cache))
        return false;
    
    m_cache[m_cache_size].key = key;
    m_cache[m_cache_size].value = value;
    m_cache[m_cache_size].created_at = TimeCurrent();
    m_cache[m_cache_size].last_access = TimeCurrent();
    m_cache[m_cache_size].ttl = ttl;
    m_cache[m_cache_size].access_count = 1;
    m_cache[m_cache_size].size = StringLen(key) + StringLen(value);
    
    m_cache_size++;
    return true;
}

bool CCacheManager::UpdateCacheEntry(int index, string value, int ttl)
{
    if(index < 0 || index >= m_cache_size)
        return false;
    
    m_cache[index].value = value;
    m_cache[index].last_access = TimeCurrent();
    m_cache[index].ttl = ttl;
    m_cache[index].access_count++;
    m_cache[index].size = StringLen(m_cache[index].key) + StringLen(value);
    
    return true;
}

bool CCacheManager::RemoveCacheEntry(int index)
{
    if(index < 0 || index >= m_cache_size)
        return false;
    
    // Mover entradas para preencher o espaço
    for(int i = index; i < m_cache_size - 1; i++)
    {
        m_cache[i] = m_cache[i + 1];
    }
    
    ZeroMemory(m_cache[m_cache_size - 1]);
    m_cache_size--;
    
    return true;
}

void CCacheManager::UpdateIndex(string key, int cache_index)
{
    int index = FindIndexEntry(key);
    if(index >= 0)
    {
        m_index[index].index = cache_index;
        m_index[index].last_access = TimeCurrent();
    }
    else if(m_index_size < ArraySize(m_index))
    {
        m_index[m_index_size].key = key;
        m_index[m_index_size].index = cache_index;
        m_index[m_index_size].last_access = TimeCurrent();
        m_index_size++;
    }
}

void CCacheManager::RemoveFromIndex(string key)
{
    int index = FindIndexEntry(key);
    if(index >= 0)
    {
        for(int i = index; i < m_index_size - 1; i++)
        {
            m_index[i] = m_index[i + 1];
        }
        
        ZeroMemory(m_index[m_index_size - 1]);
        m_index_size--;
    }
}

bool CCacheManager::IsExpired(SCacheEntry &entry)
{
    if(entry.ttl <= 0)
        return false;
    
    return (TimeCurrent() - entry.created_at) > entry.ttl;
}

void CCacheManager::EvictOldestEntry()
{
    if(m_cache_size == 0)
        return;
    
    datetime oldest = TimeCurrent();
    int oldest_index = 0;
    
    for(int i = 0; i < m_cache_size; i++)
    {
        if(m_cache[i].created_at < oldest)
        {
            oldest = m_cache[i].created_at;
            oldest_index = i;
        }
    }
    
    RemoveFromIndex(m_cache[oldest_index].key);
    RemoveCacheEntry(oldest_index);
    m_evictions++;
}

void CCacheManager::EvictLRUEntry()
{
    if(m_cache_size == 0)
        return;
    
    datetime oldest_access = TimeCurrent();
    int lru_index = 0;
    
    for(int i = 0; i < m_cache_size; i++)
    {
        if(m_cache[i].last_access < oldest_access)
        {
            oldest_access = m_cache[i].last_access;
            lru_index = i;
        }
    }
    
    RemoveFromIndex(m_cache[lru_index].key);
    RemoveCacheEntry(lru_index);
    m_evictions++;
}

int CCacheManager::GetMemoryUsage()
{
    int total_size = 0;
    
    for(int i = 0; i < m_cache_size; i++)
    {
        total_size += m_cache[i].size;
    }
    
    // Adicionar overhead das estruturas
    total_size += m_cache_size * sizeof(SCacheEntry);
    total_size += m_index_size * sizeof(SIndex);
    total_size += ArraySize(m_market_cache) * sizeof(SMarketCache);
    total_size += ArraySize(m_indicator_cache) * sizeof(SIndicatorCache);
    total_size += ArraySize(m_ict_cache) * sizeof(SICTCache);
    
    return total_size / (1024 * 1024); // Converter para MB
}

bool CCacheManager::NeedsCleanup()
{
    if(!m_auto_cleanup)
        return false;
    
    return (TimeCurrent() - m_last_cleanup) >= m_cleanup_interval;
}

void CCacheManager::PerformCleanup()
{
    Cleanup();
}

string CCacheManager::GenerateKey(string prefix, string data)
{
    return prefix + ":" + data;
}

bool CCacheManager::ValidateKey(string key)
{
    return (key != "" && StringLen(key) <= 255);
}

int CCacheManager::FindMarketCache(string symbol)
{
    for(int i = 0; i < ArraySize(m_market_cache); i++)
    {
        if(m_market_cache[i].symbol == symbol)
            return i;
    }
    return -1;
}

//+------------------------------------------------------------------+
//| LIMPAR ENTRADAS EXPIRADAS                                        |
//+------------------------------------------------------------------+

void CCacheManager::CleanupExpired()
{
    if(!m_initialized)
        return;
    
    datetime current_time = TimeCurrent();
    int removed_count = 0;
    
    // Limpar cache principal
    for(int i = m_cache_size - 1; i >= 0; i--)
    {
        if(m_cache[i].ttl > 0 && (current_time - m_cache[i].timestamp) > m_cache[i].ttl)
        {
            // Remover entrada expirada
            for(int j = i; j < m_cache_size - 1; j++)
            {
                m_cache[j] = m_cache[j + 1];
            }
            m_cache_size--;
            removed_count++;
        }
    }
    
    // Limpar cache de mercado
    for(int i = ArraySize(m_market_cache) - 1; i >= 0; i--)
    {
        if((current_time - m_market_cache[i].cached_at) > 300) // 5 minutos
        {
            ArrayRemove(m_market_cache, i, 1);
            removed_count++;
        }
    }
    
    // Limpar cache de indicadores
    for(int i = ArraySize(m_indicator_cache) - 1; i >= 0; i--)
    {
        if((current_time - m_indicator_cache[i].calculated_at) > 3600) // 1 hora
        {
            ArrayRemove(m_indicator_cache, i, 1);
            removed_count++;
        }
    }
    
    // Limpar cache ICT
    for(int i = ArraySize(m_ict_cache) - 1; i >= 0; i--)
    {
        if((current_time - m_ict_cache[i].cached_at) > 1800) // 30 minutos
        {
            ArrayRemove(m_ict_cache, i, 1);
            removed_count++;
        }
    }
    
    m_last_cleanup = current_time;
    m_cleanups++;
    
    if(removed_count > 0)
    {
        LogInfo("Cache cleanup: " + IntegerToString(removed_count) + " entradas expiradas removidas");
    }
}

//+------------------------------------------------------------------+
//| IMPRIMIR ESTATÍSTICAS                                            |
//+------------------------------------------------------------------+

void CCacheManager::PrintStatistics()
{
    LogInfo("=== ESTATÍSTICAS DO CACHE ===");
    LogInfo("Entradas: " + IntegerToString(m_cache_size) + "/" + IntegerToString(m_max_entries));
    LogInfo("Hits: " + IntegerToString(m_hits));
    LogInfo("Misses: " + IntegerToString(m_misses));
    LogInfo("Taxa de acerto: " + DoubleToString(GetHitRatio(), 2) + "%");
    LogInfo("Evictions: " + IntegerToString(m_evictions));
    LogInfo("Cleanups: " + IntegerToString(m_cleanups));
    LogInfo("Uso de memória: " + IntegerToString(GetMemoryUsage()) + " MB");
    LogInfo("=============================");
}

//+------------------------------------------------------------------+
//| INSTÂNCIA GLOBAL                                                 |
//+------------------------------------------------------------------+

CCacheManager* g_cache = NULL;

//+------------------------------------------------------------------+
//| FIM DO ARQUIVO                                                   |
//+------------------------------------------------------------------+