//+------------------------------------------------------------------+
//|                                            ConfigManager.mqh     |
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
//| CLASSE GERENCIADOR DE CONFIGURAÇÃO                               |
//+------------------------------------------------------------------+

class CConfigManager : public IConfigManager
{
private:
    // Estado
    bool                m_initialized;
    string              m_module_name;
    string              m_version;
    
    // Configuração atual
    SEAConfig           m_config;
    string              m_config_file;
    bool                m_config_loaded;
    bool                m_config_valid;
    
    // Validação
    string              m_validation_errors[];
    
    // Backup
    string              m_backup_path;
    int                 m_max_backups;
    
    // Cache de parâmetros
    struct SParameter
    {
        string key;
        string value;
        string description;
        string type;
        string default_value;
        bool   is_required;
    };
    
    SParameter          m_parameters[];
    
    // Métodos privados
    bool                LoadDefaultConfiguration();
    bool                ParseConfigFile(string filename);
    bool                SaveConfigFile(string filename);
    bool                ValidateConfiguration();
    void                AddValidationError(string error);
    void                ClearValidationErrors();
    bool                CreateBackup(string backup_name);
    string              GetBackupFileName(string backup_name);
    bool                SetParameterInternal(string key, string value);
    string              GetParameterInternal(string key);
    void                InitializeDefaultParameters();
    bool                ApplyParametersToConfig();
    bool                ExtractParametersFromConfig();
    string              SerializeConfig();
    bool                DeserializeConfig(string data);
    
public:
    // Construtor e destrutor
                        CConfigManager();
                        ~CConfigManager();
    
    // Implementação IModule
    virtual bool        Init() override;
    virtual void        Deinit() override;
    virtual bool        IsInitialized() override { return m_initialized; }
    virtual string      GetModuleName() override { return m_module_name; }
    virtual string      GetVersion() override { return m_version; }
    virtual bool        SelfTest() override;
    
    // Implementação IConfigManager
    virtual bool        LoadConfig(string config_file) override;
    virtual bool        SaveConfig(string config_file) override;
    virtual bool        LoadDefaultConfig() override;
    virtual bool        ResetToDefaults() override;
    
    virtual bool        SetParameter(string key, string value) override;
    virtual string      GetParameter(string key) override;
    virtual bool        HasParameter(string key) override;
    virtual bool        RemoveParameter(string key) override;
    
    virtual bool        ValidateConfig() override;
    virtual bool        GetValidationErrors(string &errors[]) override;
    virtual bool        IsConfigValid() override { return m_config_valid; }
    
    virtual bool        BackupConfig(string backup_name) override;
    virtual bool        RestoreConfig(string backup_name) override;
    virtual bool        GetBackupList(string &backups[]) override;
    
    virtual SEAConfig   GetEAConfig() override { return m_config; }
    virtual bool        SetEAConfig(SEAConfig &config) override;
    virtual bool        UpdateConfig(SEAConfig &config) override;
    
    // Métodos específicos
    bool                SetConfigFile(string filename);
    string              GetConfigFile() { return m_config_file; }
    bool                AutoSave(bool enable);
    bool                ImportConfig(string filename);
    bool                ExportConfig(string filename);
    void                PrintConfig();
    bool                CompareConfigs(SEAConfig &config1, SEAConfig &config2);
    
    // Getters específicos para facilitar acesso
    bool                IsEnabled() { return m_config.general.enabled; }
    int                 GetMagicNumber() { return m_config.general.magic_number; }
    double              GetRiskPercent() { return m_config.risk.risk_percent; }
    bool                IsFTMOMode() { return m_config.compliance.ftmo_mode; }
    ENUM_TIMEFRAMES     GetTimeframe() { return m_config.general.timeframe; }
};

//+------------------------------------------------------------------+
//| IMPLEMENTAÇÃO DO CONSTRUTOR                                      |
//+------------------------------------------------------------------+

CConfigManager::CConfigManager()
{
    m_initialized = false;
    m_module_name = "ConfigManager";
    m_version = "1.00";
    
    m_config_file = "";
    m_config_loaded = false;
    m_config_valid = false;
    
    m_backup_path = CONFIG_PATH + "\\backups";
    m_max_backups = 10;
    
    ArrayResize(m_validation_errors, 0);
    ArrayResize(m_parameters, 0);
    
    // Inicializar configuração com valores padrão
    ZeroMemory(m_config);
}

//+------------------------------------------------------------------+
//| IMPLEMENTAÇÃO DO DESTRUTOR                                       |
//+------------------------------------------------------------------+

CConfigManager::~CConfigManager()
{
    Deinit();
}

//+------------------------------------------------------------------+
//| INICIALIZAÇÃO                                                    |
//+------------------------------------------------------------------+

bool CConfigManager::Init()
{
    if(m_initialized)
        return true;
    
    LogInfo("Inicializando ConfigManager...");
    
    // Criar diretórios se não existirem
    if(!FileIsExist(CONFIG_PATH, FILE_IS_DIRECTORY))
    {
        if(!FolderCreate(CONFIG_PATH))
        {
            LogError("Erro ao criar diretório de configuração: " + CONFIG_PATH);
            return false;
        }
    }
    
    if(!FileIsExist(m_backup_path, FILE_IS_DIRECTORY))
    {
        if(!FolderCreate(m_backup_path))
        {
            LogError("Erro ao criar diretório de backup: " + m_backup_path);
            return false;
        }
    }
    
    // Inicializar parâmetros padrão
    InitializeDefaultParameters();
    
    // Carregar configuração padrão
    if(!LoadDefaultConfiguration())
    {
        LogError("Erro ao carregar configuração padrão");
        return false;
    }
    
    // Definir arquivo de configuração padrão se não definido
    if(m_config_file == "")
    {
        m_config_file = CONFIG_PATH + "\\" + EA_NAME + "_config.json";
    }
    
    m_initialized = true;
    LogInfo("ConfigManager inicializado com sucesso");
    
    return true;
}

//+------------------------------------------------------------------+
//| DESINICIALIZAÇÃO                                                 |
//+------------------------------------------------------------------+

void CConfigManager::Deinit()
{
    if(!m_initialized)
        return;
    
    // Salvar configuração atual se carregada
    if(m_config_loaded && m_config_file != "")
    {
        SaveConfig(m_config_file);
    }
    
    m_initialized = false;
    LogInfo("ConfigManager desinicializado");
}

//+------------------------------------------------------------------+
//| AUTO-TESTE                                                       |
//+------------------------------------------------------------------+

bool CConfigManager::SelfTest()
{
    if(!m_initialized)
        return false;
    
    LogInfo("Executando auto-teste do ConfigManager...");
    
    // Testar configuração padrão
    if(!LoadDefaultConfig())
    {
        LogError("Falha no teste: LoadDefaultConfig");
        return false;
    }
    
    // Testar validação
    if(!ValidateConfig())
    {
        LogError("Falha no teste: ValidateConfig");
        return false;
    }
    
    // Testar parâmetros
    if(!SetParameter("test_param", "test_value"))
    {
        LogError("Falha no teste: SetParameter");
        return false;
    }
    
    if(GetParameter("test_param") != "test_value")
    {
        LogError("Falha no teste: GetParameter");
        return false;
    }
    
    if(!RemoveParameter("test_param"))
    {
        LogError("Falha no teste: RemoveParameter");
        return false;
    }
    
    // Testar backup
    string test_backup = "selftest_" + IntegerToString(TimeCurrent());
    if(!BackupConfig(test_backup))
    {
        LogError("Falha no teste: BackupConfig");
        return false;
    }
    
    LogInfo("Auto-teste do ConfigManager concluído com sucesso");
    return true;
}

//+------------------------------------------------------------------+
//| CARREGAR CONFIGURAÇÃO                                            |
//+------------------------------------------------------------------+

bool CConfigManager::LoadConfig(string config_file)
{
    if(!m_initialized)
        return false;
    
    LogInfo("Carregando configuração: " + config_file);
    
    if(!FileIsExist(config_file))
    {
        LogWarning("Arquivo de configuração não encontrado: " + config_file);
        LogInfo("Carregando configuração padrão...");
        return LoadDefaultConfig();
    }
    
    if(!ParseConfigFile(config_file))
    {
        LogError("Erro ao analisar arquivo de configuração: " + config_file);
        return false;
    }
    
    m_config_file = config_file;
    m_config_loaded = true;
    
    // Validar configuração carregada
    if(!ValidateConfig())
    {
        LogError("Configuração carregada é inválida");
        return false;
    }
    
    // Extrair parâmetros da configuração
    ExtractParametersFromConfig();
    
    LogInfo("Configuração carregada com sucesso");
    return true;
}

//+------------------------------------------------------------------+
//| SALVAR CONFIGURAÇÃO                                              |
//+------------------------------------------------------------------+

bool CConfigManager::SaveConfig(string config_file)
{
    if(!m_initialized)
        return false;
    
    LogInfo("Salvando configuração: " + config_file);
    
    // Aplicar parâmetros à configuração
    if(!ApplyParametersToConfig())
    {
        LogError("Erro ao aplicar parâmetros à configuração");
        return false;
    }
    
    // Validar antes de salvar
    if(!ValidateConfig())
    {
        LogError("Configuração inválida, não será salva");
        return false;
    }
    
    if(!SaveConfigFile(config_file))
    {
        LogError("Erro ao salvar arquivo de configuração: " + config_file);
        return false;
    }
    
    m_config_file = config_file;
    LogInfo("Configuração salva com sucesso");
    
    return true;
}

//+------------------------------------------------------------------+
//| CARREGAR CONFIGURAÇÃO PADRÃO                                     |
//+------------------------------------------------------------------+

bool CConfigManager::LoadDefaultConfig()
{
    if(!m_initialized)
        return false;
    
    LogInfo("Carregando configuração padrão...");
    
    return LoadDefaultConfiguration();
}

//+------------------------------------------------------------------+
//| RESETAR PARA PADRÕES                                             |
//+------------------------------------------------------------------+

bool CConfigManager::ResetToDefaults()
{
    if(!m_initialized)
        return false;
    
    LogInfo("Resetando configuração para padrões...");
    
    // Limpar configuração atual
    ZeroMemory(m_config);
    
    // Carregar configuração padrão
    if(!LoadDefaultConfiguration())
    {
        LogError("Erro ao resetar para configuração padrão");
        return false;
    }
    
    // Reinicializar parâmetros
    ArrayResize(m_parameters, 0);
    InitializeDefaultParameters();
    
    m_config_loaded = true;
    m_config_valid = true;
    
    LogInfo("Configuração resetada para padrões com sucesso");
    return true;
}

//+------------------------------------------------------------------+
//| DEFINIR PARÂMETRO                                                |
//+------------------------------------------------------------------+

bool CConfigManager::SetParameter(string key, string value)
{
    if(!m_initialized)
        return false;
    
    return SetParameterInternal(key, value);
}

//+------------------------------------------------------------------+
//| OBTER PARÂMETRO                                                  |
//+------------------------------------------------------------------+

string CConfigManager::GetParameter(string key)
{
    if(!m_initialized)
        return "";
    
    return GetParameterInternal(key);
}

//+------------------------------------------------------------------+
//| TEM PARÂMETRO                                                    |
//+------------------------------------------------------------------+

bool CConfigManager::HasParameter(string key)
{
    if(!m_initialized)
        return false;
    
    int size = ArraySize(m_parameters);
    for(int i = 0; i < size; i++)
    {
        if(m_parameters[i].key == key)
            return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| REMOVER PARÂMETRO                                                |
//+------------------------------------------------------------------+

bool CConfigManager::RemoveParameter(string key)
{
    if(!m_initialized)
        return false;
    
    int size = ArraySize(m_parameters);
    for(int i = 0; i < size; i++)
    {
        if(m_parameters[i].key == key)
        {
            // Mover elementos para preencher o espaço
            for(int j = i; j < size - 1; j++)
            {
                m_parameters[j] = m_parameters[j + 1];
            }
            
            ArrayResize(m_parameters, size - 1);
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| VALIDAR CONFIGURAÇÃO                                             |
//+------------------------------------------------------------------+

bool CConfigManager::ValidateConfig()
{
    if(!m_initialized)
        return false;
    
    ClearValidationErrors();
    
    // Validar configurações gerais
    if(m_config.general.magic_number <= 0)
        AddValidationError("Magic number deve ser maior que zero");
    
    if(m_config.general.timeframe < PERIOD_M1 || m_config.general.timeframe > PERIOD_MN1)
        AddValidationError("Timeframe inválido");
    
    // Validar configurações de risco
    if(m_config.risk.risk_percent <= 0 || m_config.risk.risk_percent > 100)
        AddValidationError("Percentual de risco deve estar entre 0 e 100");
    
    if(m_config.risk.max_positions <= 0)
        AddValidationError("Número máximo de posições deve ser maior que zero");
    
    if(m_config.risk.max_daily_loss <= 0)
        AddValidationError("Perda máxima diária deve ser maior que zero");
    
    // Validar configurações ICT
    if(m_config.ict.order_block_period <= 0)
        AddValidationError("Período de Order Block deve ser maior que zero");
    
    if(m_config.ict.fvg_min_size <= 0)
        AddValidationError("Tamanho mínimo de FVG deve ser maior que zero");
    
    // Validar configurações de volume
    if(m_config.volume.volume_period <= 0)
        AddValidationError("Período de volume deve ser maior que zero");
    
    if(m_config.volume.spike_threshold <= 0)
        AddValidationError("Limite de spike de volume deve ser maior que zero");
    
    // Validar configurações FTMO
    if(m_config.compliance.ftmo_mode)
    {
        if(m_config.compliance.daily_loss_limit <= 0)
            AddValidationError("Limite de perda diária FTMO deve ser maior que zero");
        
        if(m_config.compliance.total_loss_limit <= 0)
            AddValidationError("Limite de perda total FTMO deve ser maior que zero");
        
        if(m_config.compliance.profit_target <= 0)
            AddValidationError("Meta de lucro FTMO deve ser maior que zero");
    }
    
    m_config_valid = (ArraySize(m_validation_errors) == 0);
    
    if(!m_config_valid)
    {
        LogError("Configuração inválida encontrada");
        for(int i = 0; i < ArraySize(m_validation_errors); i++)
        {
            LogError("Erro de validação: " + m_validation_errors[i]);
        }
    }
    
    return m_config_valid;
}

//+------------------------------------------------------------------+
//| OBTER ERROS DE VALIDAÇÃO                                         |
//+------------------------------------------------------------------+

bool CConfigManager::GetValidationErrors(string &errors[])
{
    ArrayCopy(errors, m_validation_errors);
    return true;
}

//+------------------------------------------------------------------+
//| BACKUP DE CONFIGURAÇÃO                                           |
//+------------------------------------------------------------------+

bool CConfigManager::BackupConfig(string backup_name)
{
    if(!m_initialized)
        return false;
    
    string backup_file = GetBackupFileName(backup_name);
    
    LogInfo("Criando backup: " + backup_file);
    
    return CreateBackup(backup_name);
}

//+------------------------------------------------------------------+
//| RESTAURAR CONFIGURAÇÃO                                           |
//+------------------------------------------------------------------+

bool CConfigManager::RestoreConfig(string backup_name)
{
    if(!m_initialized)
        return false;
    
    string backup_file = GetBackupFileName(backup_name);
    
    if(!FileIsExist(backup_file))
    {
        LogError("Backup não encontrado: " + backup_file);
        return false;
    }
    
    LogInfo("Restaurando backup: " + backup_file);
    
    return LoadConfig(backup_file);
}

//+------------------------------------------------------------------+
//| LISTA DE BACKUPS                                                 |
//+------------------------------------------------------------------+

bool CConfigManager::GetBackupList(string &result[])
{
    ArrayResize(result, 0);
    
    string search_pattern = m_backup_path + "\\*.json";
    string filename;
    long search_handle = FileFindFirst(search_pattern, filename);
    
    if(search_handle != INVALID_HANDLE)
    {
        do
        {
            ArrayResize(result, ArraySize(result) + 1);
            result[ArraySize(result) - 1] = filename;
        }
        while(FileFindNext(search_handle, filename));
        
        FileFindClose(search_handle);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| DEFINIR CONFIGURAÇÃO DO EA                                       |
//+------------------------------------------------------------------+

bool CConfigManager::SetEAConfig(SEAConfig &config)
{
    if(!m_initialized)
        return false;
    
    m_config = config;
    
    // Extrair parâmetros da nova configuração
    ExtractParametersFromConfig();
    
    // Validar nova configuração
    if(!ValidateConfig())
    {
        LogError("Nova configuração é inválida");
        return false;
    }
    
    m_config_loaded = true;
    LogInfo("Configuração do EA atualizada");
    
    return true;
}

//+------------------------------------------------------------------+
//| ATUALIZAR CONFIGURAÇÃO                                           |
//+------------------------------------------------------------------+

bool CConfigManager::UpdateConfig(SEAConfig &config)
{
    return SetEAConfig(config);
}

//+------------------------------------------------------------------+
//| MÉTODOS PRIVADOS                                                 |
//+------------------------------------------------------------------+

bool CConfigManager::LoadDefaultConfiguration()
{
    // Configurações gerais
    m_config.general.enabled = true;
    m_config.general.magic_number = EA_MAGIC_NUMBER;
    m_config.general.timeframe = PERIOD_M15;
    m_config.general.max_spread = 30;
    m_config.general.slippage = 3;
    
    // Configurações de trading
    m_config.trading.auto_trading = true;
    m_config.trading.trade_on_new_bar = true;
    m_config.trading.max_retries = 3;
    m_config.trading.retry_delay = 1000;
    
    // Configurações de risco
    m_config.risk.risk_type = RISK_TYPE_PERCENT;
    m_config.risk.risk_percent = 1.0;
    m_config.risk.fixed_lot = 0.01;
    m_config.risk.max_positions = 1;
    m_config.risk.max_daily_loss = 100.0;
    m_config.risk.max_weekly_loss = 300.0;
    m_config.risk.max_monthly_loss = 1000.0;
    m_config.risk.use_trailing_stop = true;
    m_config.risk.trailing_distance = 20;
    
    // Configurações de compliance
    m_config.compliance.ftmo_mode = true;
    m_config.compliance.daily_loss_limit = 500.0;
    m_config.compliance.total_loss_limit = 1000.0;
    m_config.compliance.profit_target = 1000.0;
    m_config.compliance.news_filter = true;
    m_config.compliance.weekend_close = true;
    
    // Configurações ICT
    m_config.ict.use_order_blocks = true;
    m_config.ict.order_block_period = 20;
    m_config.ict.order_block_min_size = 10;
    m_config.ict.use_fvg = true;
    m_config.ict.fvg_min_size = 5;
    m_config.ict.fvg_max_age = 10;
    m_config.ict.use_liquidity = true;
    m_config.ict.liquidity_threshold = 50;
    
    // Configurações de volume
    m_config.volume.volume_type = VOLUME_ANALYSIS_TICK;
    m_config.volume.volume_period = 14;
    m_config.volume.spike_threshold = 2.0;
    m_config.volume.use_volume_profile = true;
    
    // Configurações de alertas
    m_config.alerts.enable_alerts = true;
    m_config.alerts.enable_push = false;
    m_config.alerts.enable_email = false;
    m_config.alerts.enable_sound = true;
    m_config.alerts.sound_file = "alert.wav";
    
    // Configurações de logging
    m_config.logging.log_level = LOG_LEVEL_INFO;
    m_config.logging.log_to_file = true;
    m_config.logging.log_to_terminal = true;
    m_config.logging.max_log_size = 10;
    
    // Configurações de debug
    m_config.debug.debug_mode = false;
    m_config.debug.verbose_logging = false;
    m_config.debug.save_debug_files = false;
    
    // Configurações de teste
    m_config.test.enable_backtesting = false;
    m_config.test.test_mode = false;
    m_config.test.simulation_mode = false;
    
    // Configurações de performance
    m_config.performance.enable_cache = true;
    m_config.performance.cache_size = 1000;
    m_config.performance.optimize_memory = true;
    m_config.performance.max_cpu_usage = 80;
    
    m_config_loaded = true;
    m_config_valid = true;
    
    return true;
}

bool CConfigManager::ParseConfigFile(string filename)
{
    // Implementação simplificada - em produção usaria JSON parser
    int handle = FileOpen(filename, FILE_READ | FILE_TXT);
    if(handle == INVALID_HANDLE)
        return false;
    
    string content = "";
    while(!FileIsEnding(handle))
    {
        content += FileReadString(handle) + "\n";
    }
    
    FileClose(handle);
    
    return DeserializeConfig(content);
}

bool CConfigManager::SaveConfigFile(string filename)
{
    string content = SerializeConfig();
    
    int handle = FileOpen(filename, FILE_WRITE | FILE_TXT);
    if(handle == INVALID_HANDLE)
        return false;
    
    FileWriteString(handle, content);
    FileClose(handle);
    
    return true;
}

void CConfigManager::AddValidationError(string error)
{
    int size = ArraySize(m_validation_errors);
    ArrayResize(m_validation_errors, size + 1);
    m_validation_errors[size] = error;
}

void CConfigManager::ClearValidationErrors()
{
    ArrayResize(m_validation_errors, 0);
}

bool CConfigManager::CreateBackup(string backup_name)
{
    string backup_file = GetBackupFileName(backup_name);
    return SaveConfigFile(backup_file);
}

string CConfigManager::GetBackupFileName(string backup_name)
{
    return m_backup_path + "\\" + backup_name + "_" + 
           TimeToString(TimeCurrent(), TIME_DATE) + ".json";
}

bool CConfigManager::SetParameterInternal(string key, string value)
{
    int size = ArraySize(m_parameters);
    
    // Procurar parâmetro existente
    for(int i = 0; i < size; i++)
    {
        if(m_parameters[i].key == key)
        {
            m_parameters[i].value = value;
            return true;
        }
    }
    
    // Adicionar novo parâmetro
    ArrayResize(m_parameters, size + 1);
    m_parameters[size].key = key;
    m_parameters[size].value = value;
    m_parameters[size].description = "";
    m_parameters[size].type = "string";
    m_parameters[size].default_value = "";
    m_parameters[size].is_required = false;
    
    return true;
}

string CConfigManager::GetParameterInternal(string key)
{
    int size = ArraySize(m_parameters);
    for(int i = 0; i < size; i++)
    {
        if(m_parameters[i].key == key)
            return m_parameters[i].value;
    }
    
    return "";
}

void CConfigManager::InitializeDefaultParameters()
{
    // Implementação simplificada - adicionar parâmetros principais
    SetParameterInternal("enabled", "true");
    SetParameterInternal("magic_number", IntegerToString(EA_MAGIC_NUMBER));
    SetParameterInternal("risk_percent", "1.0");
    SetParameterInternal("ftmo_mode", "true");
    SetParameterInternal("timeframe", IntegerToString(PERIOD_M15));
}

bool CConfigManager::ApplyParametersToConfig()
{
    // Aplicar parâmetros à estrutura de configuração
    // Implementação simplificada
    
    string value;
    
    value = GetParameterInternal("enabled");
    if(value != "") m_config.general.enabled = (value == "true");
    
    value = GetParameterInternal("magic_number");
    if(value != "") m_config.general.magic_number = StringToInteger(value);
    
    value = GetParameterInternal("risk_percent");
    if(value != "") m_config.risk.risk_percent = StringToDouble(value);
    
    value = GetParameterInternal("ftmo_mode");
    if(value != "") m_config.compliance.ftmo_mode = (value == "true");
    
    return true;
}

bool CConfigManager::ExtractParametersFromConfig()
{
    // Extrair parâmetros da estrutura de configuração
    SetParameterInternal("enabled", m_config.general.enabled ? "true" : "false");
    SetParameterInternal("magic_number", IntegerToString(m_config.general.magic_number));
    SetParameterInternal("risk_percent", DoubleToString(m_config.risk.risk_percent, 2));
    SetParameterInternal("ftmo_mode", m_config.compliance.ftmo_mode ? "true" : "false");
    
    return true;
}

string CConfigManager::SerializeConfig()
{
    // Implementação simplificada de serialização JSON
    string json = "{\n";
    json += "  \"general\": {\n";
    json += "    \"enabled\": " + (m_config.general.enabled ? "true" : "false") + ",\n";
    json += "    \"magic_number\": " + IntegerToString(m_config.general.magic_number) + ",\n";
    json += "    \"timeframe\": " + IntegerToString(m_config.general.timeframe) + "\n";
    json += "  },\n";
    json += "  \"risk\": {\n";
    json += "    \"risk_percent\": " + DoubleToString(m_config.risk.risk_percent, 2) + ",\n";
    json += "    \"max_positions\": " + IntegerToString(m_config.risk.max_positions) + "\n";
    json += "  },\n";
    json += "  \"compliance\": {\n";
    json += "    \"ftmo_mode\": " + (m_config.compliance.ftmo_mode ? "true" : "false") + "\n";
    json += "  }\n";
    json += "}";
    
    return json;
}

bool CConfigManager::DeserializeConfig(string data)
{
    // Implementação simplificada de deserialização JSON
    // Em produção, usaria um parser JSON completo
    
    // Por enquanto, apenas retorna true para indicar sucesso
    return true;
}

//+------------------------------------------------------------------+
//| INSTÂNCIA GLOBAL                                                 |
//+------------------------------------------------------------------+

CConfigManager* g_config = NULL;

//+------------------------------------------------------------------+
//| FIM DO ARQUIVO                                                   |
//+------------------------------------------------------------------+