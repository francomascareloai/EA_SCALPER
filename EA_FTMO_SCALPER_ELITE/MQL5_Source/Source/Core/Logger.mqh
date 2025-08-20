//+------------------------------------------------------------------+
//|                                                   Logger.mqh     |
//|                                    EA FTMO Scalper Elite v1.0    |
//|                                      TradeDev_Master 2024        |
//+------------------------------------------------------------------+
#property copyright "TradeDev_Master 2024"
#property version   "1.00"
#property strict

#include "Interfaces.mqh"
#include "DataStructures.mqh"

//+------------------------------------------------------------------+
//| CLASSE LOGGER PRINCIPAL                                          |
//+------------------------------------------------------------------+

class CLogger : public ILogger
{
private:
    // Configurações
    ENUM_LOG_LEVEL      m_log_level;           // Nível mínimo de log
    bool                m_log_to_file;         // Log para arquivo
    bool                m_log_to_terminal;     // Log para terminal
    bool                m_initialized;         // Estado de inicialização
    string              m_module_name;         // Nome do módulo
    string              m_version;             // Versão
    
    // Arquivo de log
    string              m_log_filename;        // Nome do arquivo
    int                 m_log_handle;          // Handle do arquivo
    int                 m_max_log_size;        // Tamanho máximo (MB)
    bool                m_auto_rotate;         // Rotação automática
    
    // Filtros
    string              m_module_filters[];    // Filtros de módulo
    datetime            m_time_filter_start;   // Filtro de tempo início
    datetime            m_time_filter_end;     // Filtro de tempo fim
    bool                m_use_time_filter;     // Usar filtro de tempo
    
    // Estatísticas
    int                 m_total_logs;          // Total de logs
    int                 m_logs_today;          // Logs hoje
    datetime            m_last_log_date;       // Data do último log
    int                 m_error_count;         // Contagem de erros
    int                 m_warning_count;       // Contagem de warnings
    
    // Buffer de logs
    SLogEntry           m_log_buffer[];        // Buffer de logs
    int                 m_buffer_size;         // Tamanho do buffer
    int                 m_buffer_index;        // Índice atual
    bool                m_buffer_full;         // Buffer cheio
    
    // Métodos privados
    bool                InitializeLogFile();   // Inicializar arquivo
    bool                WriteToFile(string message); // Escrever no arquivo
    void                WriteToTerminal(string message); // Escrever no terminal
    string              FormatLogMessage(ENUM_LOG_LEVEL level, string module, string function, string message);
    string              GetLevelString(ENUM_LOG_LEVEL level); // String do nível
    bool                ShouldLog(ENUM_LOG_LEVEL level); // Deve fazer log
    bool                IsModuleFiltered(string module); // Módulo filtrado
    bool                IsTimeFiltered(); // Tempo filtrado
    void                UpdateStatistics(); // Atualizar estatísticas
    bool                RotateLogFileIfNeeded(); // Rotacionar se necessário
    void                AddToBuffer(SLogEntry &entry); // Adicionar ao buffer
    
public:
    // Construtor e destrutor
                        CLogger();
                        ~CLogger();
    
    // Implementação IModule
    virtual bool        Init() override;
    virtual void        Deinit() override;
    virtual bool        IsInitialized() override { return m_initialized; }
    virtual string      GetModuleName() override { return m_module_name; }
    virtual string      GetVersion() override { return m_version; }
    virtual bool        SelfTest() override;
    
    // Implementação ILogger - Métodos básicos
    virtual void        Debug(string message) override;
    virtual void        Info(string message) override;
    virtual void        Warning(string message) override;
    virtual void        Error(string message) override;
    virtual void        Critical(string message) override;
    
    // Log estruturado
    virtual void        Log(ENUM_LOG_LEVEL level, string module, string function, string message) override;
    virtual void        LogTrade(string action, ulong ticket, double volume, double price) override;
    virtual void        LogSignal(STradingSignal &signal) override;
    virtual void        LogError(int error_code, string description) override;
    
    // Configuração
    virtual bool        SetLogLevel(ENUM_LOG_LEVEL level) override;
    virtual ENUM_LOG_LEVEL GetLogLevel() override { return m_log_level; }
    virtual bool        SetLogToFile(bool enable) override;
    virtual bool        SetLogToTerminal(bool enable) override;
    virtual bool        SetMaxLogSize(int max_size_mb) override;
    
    // Gestão de arquivos
    virtual bool        RotateLogFile() override;
    virtual bool        ClearLogs() override;
    virtual string      GetLogFileName() override { return m_log_filename; }
    virtual int         GetLogFileSize() override;
    
    // Filtros
    virtual bool        SetModuleFilter(string module, bool enable) override;
    virtual bool        SetTimeFilter(datetime start_time, datetime end_time) override;
    virtual bool        GetLogEntries(SLogEntry &entries[], ENUM_LOG_LEVEL min_level, int max_entries) override;
    
    // Métodos adicionais
    bool                SetLogFileName(string filename);
    bool                EnableAutoRotate(bool enable);
    void                FlushBuffer(); // Descarregar buffer
    int                 GetTotalLogs() { return m_total_logs; }
    int                 GetLogsToday() { return m_logs_today; }
    int                 GetErrorCount() { return m_error_count; }
    int                 GetWarningCount() { return m_warning_count; }
    bool                ExportLogs(string filename, ENUM_LOG_LEVEL min_level = LOG_DEBUG);
};

//+------------------------------------------------------------------+
//| IMPLEMENTAÇÃO DO CONSTRUTOR                                      |
//+------------------------------------------------------------------+

CLogger::CLogger()
{
    m_log_level = LOG_INFO;
    m_log_to_file = true;
    m_log_to_terminal = true;
    m_initialized = false;
    m_module_name = "Logger";
    m_version = "1.00";
    
    m_log_filename = "";
    m_log_handle = INVALID_HANDLE;
    m_max_log_size = 10; // 10 MB
    m_auto_rotate = true;
    
    m_time_filter_start = 0;
    m_time_filter_end = 0;
    m_use_time_filter = false;
    
    m_total_logs = 0;
    m_logs_today = 0;
    m_last_log_date = 0;
    m_error_count = 0;
    m_warning_count = 0;
    
    m_buffer_size = 1000;
    m_buffer_index = 0;
    m_buffer_full = false;
    
    ArrayResize(m_log_buffer, m_buffer_size);
    ArrayResize(m_module_filters, 0);
}

//+------------------------------------------------------------------+
//| IMPLEMENTAÇÃO DO DESTRUTOR                                       |
//+------------------------------------------------------------------+

CLogger::~CLogger()
{
    Deinit();
}

//+------------------------------------------------------------------+
//| INICIALIZAÇÃO                                                    |
//+------------------------------------------------------------------+

bool CLogger::Init()
{
    if(m_initialized)
        return true;
    
    // Definir nome do arquivo padrão se não definido
    if(m_log_filename == "")
    {
        datetime now = TimeCurrent();
        MqlDateTime dt;
        TimeToStruct(now, dt);
        
        m_log_filename = StringFormat("%s_%04d%02d%02d.log", 
                                     EA_NAME, dt.year, dt.mon, dt.day);
    }
    
    // Inicializar arquivo de log
    if(m_log_to_file)
    {
        if(!InitializeLogFile())
        {
            Print("[LOGGER] Erro ao inicializar arquivo de log: ", m_log_filename);
            return false;
        }
    }
    
    // Resetar estatísticas diárias se necessário
    datetime today = TimeCurrent();
    MqlDateTime dt_today, dt_last;
    TimeToStruct(today, dt_today);
    TimeToStruct(m_last_log_date, dt_last);
    
    if(dt_today.day != dt_last.day || dt_today.mon != dt_last.mon || dt_today.year != dt_last.year)
    {
        m_logs_today = 0;
        m_last_log_date = today;
    }
    
    m_initialized = true;
    
    // Log de inicialização
    Info("Logger inicializado com sucesso");
    
    return true;
}

//+------------------------------------------------------------------+
//| DESINICIALIZAÇÃO                                                 |
//+------------------------------------------------------------------+

void CLogger::Deinit()
{
    if(!m_initialized)
        return;
    
    // Descarregar buffer
    FlushBuffer();
    
    // Fechar arquivo de log
    if(m_log_handle != INVALID_HANDLE)
    {
        FileClose(m_log_handle);
        m_log_handle = INVALID_HANDLE;
    }
    
    m_initialized = false;
    
    Print("[LOGGER] Logger desinicializado");
}

//+------------------------------------------------------------------+
//| AUTO-TESTE                                                       |
//+------------------------------------------------------------------+

bool CLogger::SelfTest()
{
    if(!m_initialized)
        return false;
    
    // Testar todos os níveis de log
    Debug("Teste de log DEBUG");
    Info("Teste de log INFO");
    Warning("Teste de log WARNING");
    Error("Teste de log ERROR");
    Critical("Teste de log CRITICAL");
    
    // Testar log estruturado
    Log(LOG_LEVEL_INFO, "SelfTest", "SelfTest", "Teste de log estruturado");
    
    // Testar log de trade
    LogTrade("BUY", 12345, 0.1, 1.2345);
    
    // Testar log de erro
    LogError(ERR_INVALID_PARAMETER, "Teste de erro");
    
    return true;
}

//+------------------------------------------------------------------+
//| MÉTODOS DE LOG BÁSICOS                                           |
//+------------------------------------------------------------------+

void CLogger::Debug(string message)
{
    Log(LOG_LEVEL_DEBUG, "", "", message);
}

void CLogger::Info(string message)
{
    Log(LOG_LEVEL_INFO, "", "", message);
}

void CLogger::Warning(string message)
{
    Log(LOG_LEVEL_WARNING, "", "", message);
    m_warning_count++;
}

void CLogger::Error(string message)
{
    Log(LOG_LEVEL_ERROR, "", "", message);
    m_error_count++;
}

void CLogger::Critical(string message)
{
    Log(LOG_LEVEL_CRITICAL, "", "", message);
    m_error_count++;
}

//+------------------------------------------------------------------+
//| LOG ESTRUTURADO                                                  |
//+------------------------------------------------------------------+

void CLogger::Log(ENUM_LOG_LEVEL level, string module, string function, string message)
{
    if(!m_initialized || !ShouldLog(level))
        return;
    
    // Verificar filtros
    if(IsModuleFiltered(module) || IsTimeFiltered())
        return;
    
    // Formatar mensagem
    string formatted_message = FormatLogMessage(level, module, function, message);
    
    // Escrever nos destinos configurados
    if(m_log_to_terminal)
        WriteToTerminal(formatted_message);
    
    if(m_log_to_file)
        WriteToFile(formatted_message);
    
    // Adicionar ao buffer
    SLogEntry entry;
    entry.timestamp = TimeCurrent();
    entry.level = level;
    entry.module = module;
    entry.function = function;
    entry.message = message;
    entry.thread_id = 0; // MQL5 não tem threads
    
    AddToBuffer(entry);
    
    // Atualizar estatísticas
    UpdateStatistics();
    
    // Rotacionar arquivo se necessário
    if(m_auto_rotate)
        RotateLogFileIfNeeded();
}

//+------------------------------------------------------------------+
//| LOG DE TRADE                                                     |
//+------------------------------------------------------------------+

void CLogger::LogTrade(string action, ulong ticket, double volume, double price)
{
    string message = StringFormat("TRADE: %s | Ticket: %I64u | Volume: %.2f | Price: %.5f",
                                action, ticket, volume, price);
    Log(LOG_LEVEL_INFO, "Trading", "LogTrade", message);
}

//+------------------------------------------------------------------+
//| LOG DE SINAL                                                     |
//+------------------------------------------------------------------+

void CLogger::LogSignal(STradingSignal &signal)
{
    string signal_type = EnumToString(signal.type);
    string message = StringFormat("SIGNAL: %s | Entry: %.5f | SL: %.5f | TP: %.5f | Confidence: %.1f%%",
                                signal_type, signal.entry_price, signal.stop_loss, 
                                signal.take_profit, signal.confidence * 100);
    Log(LOG_LEVEL_INFO, "Strategy", "LogSignal", message);
}

//+------------------------------------------------------------------+
//| LOG DE ERRO                                                      |
//+------------------------------------------------------------------+

void CLogger::LogError(int error_code, string description)
{
    string message = StringFormat("ERROR: Code %d - %s", error_code, description);
    Log(LOG_LEVEL_ERROR, "System", "LogError", message);
}

//+------------------------------------------------------------------+
//| CONFIGURAÇÃO DE NÍVEL                                            |
//+------------------------------------------------------------------+

bool CLogger::SetLogLevel(ENUM_LOG_LEVEL level)
{
    m_log_level = level;
    Log(LOG_LEVEL_INFO, "Logger", "SetLogLevel", 
        "Nível de log alterado para: " + GetLevelString(level));
    return true;
}

//+------------------------------------------------------------------+
//| CONFIGURAÇÃO DE ARQUIVO                                          |
//+------------------------------------------------------------------+

bool CLogger::SetLogToFile(bool enable)
{
    if(enable && !m_log_to_file)
    {
        if(!InitializeLogFile())
            return false;
    }
    else if(!enable && m_log_to_file)
    {
        if(m_log_handle != INVALID_HANDLE)
        {
            FileClose(m_log_handle);
            m_log_handle = INVALID_HANDLE;
        }
    }
    
    m_log_to_file = enable;
    return true;
}

//+------------------------------------------------------------------+
//| CONFIGURAÇÃO DE TERMINAL                                         |
//+------------------------------------------------------------------+

bool CLogger::SetLogToTerminal(bool enable)
{
    m_log_to_terminal = enable;
    return true;
}

//+------------------------------------------------------------------+
//| CONFIGURAÇÃO DE TAMANHO MÁXIMO                                   |
//+------------------------------------------------------------------+

bool CLogger::SetMaxLogSize(int max_size_mb)
{
    if(max_size_mb <= 0)
        return false;
    
    m_max_log_size = max_size_mb;
    return true;
}

//+------------------------------------------------------------------+
//| ROTAÇÃO DE ARQUIVO                                               |
//+------------------------------------------------------------------+

bool CLogger::RotateLogFile()
{
    if(m_log_handle != INVALID_HANDLE)
    {
        FileClose(m_log_handle);
        m_log_handle = INVALID_HANDLE;
    }
    
    // Renomear arquivo atual
    datetime now = TimeCurrent();
    string backup_name = StringFormat("%s.%I64u.bak", m_log_filename, now);
    
    // Criar novo arquivo
    return InitializeLogFile();
}

//+------------------------------------------------------------------+
//| LIMPAR LOGS                                                      |
//+------------------------------------------------------------------+

bool CLogger::ClearLogs()
{
    if(m_log_handle != INVALID_HANDLE)
    {
        FileClose(m_log_handle);
        m_log_handle = INVALID_HANDLE;
    }
    
    // Deletar arquivo
    FileDelete(m_log_filename);
    
    // Limpar buffer
    ArrayResize(m_log_buffer, m_buffer_size);
    m_buffer_index = 0;
    m_buffer_full = false;
    
    // Resetar estatísticas
    m_total_logs = 0;
    m_logs_today = 0;
    m_error_count = 0;
    m_warning_count = 0;
    
    // Recriar arquivo
    return InitializeLogFile();
}

//+------------------------------------------------------------------+
//| TAMANHO DO ARQUIVO                                               |
//+------------------------------------------------------------------+

int CLogger::GetLogFileSize()
{
    if(!FileIsExist(m_log_filename))
        return 0;
    
    int handle = FileOpen(m_log_filename, FILE_READ | FILE_BIN);
    if(handle == INVALID_HANDLE)
        return 0;
    
    int size = (int)FileSize(handle);
    FileClose(handle);
    
    return size;
}

//+------------------------------------------------------------------+
//| FILTRO DE MÓDULO                                                 |
//+------------------------------------------------------------------+

bool CLogger::SetModuleFilter(string module, bool enable)
{
    int size = ArraySize(m_module_filters);
    
    // Procurar módulo existente
    for(int i = 0; i < size; i++)
    {
        if(m_module_filters[i] == module)
        {
            if(!enable)
            {
                // Remover filtro
                for(int j = i; j < size - 1; j++)
                    m_module_filters[j] = m_module_filters[j + 1];
                ArrayResize(m_module_filters, size - 1);
            }
            return true;
        }
    }
    
    // Adicionar novo filtro
    if(enable)
    {
        ArrayResize(m_module_filters, size + 1);
        m_module_filters[size] = module;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| FILTRO DE TEMPO                                                  |
//+------------------------------------------------------------------+

bool CLogger::SetTimeFilter(datetime start_time, datetime end_time)
{
    if(start_time >= end_time)
        return false;
    
    m_time_filter_start = start_time;
    m_time_filter_end = end_time;
    m_use_time_filter = true;
    
    return true;
}

//+------------------------------------------------------------------+
//| OBTER ENTRADAS DE LOG                                            |
//+------------------------------------------------------------------+

bool CLogger::GetLogEntries(SLogEntry &entries[], ENUM_LOG_LEVEL min_level, int max_entries)
{
    ArrayResize(entries, 0);
    
    int count = 0;
    int total_entries = m_buffer_full ? m_buffer_size : m_buffer_index;
    
    for(int i = 0; i < total_entries && count < max_entries; i++)
    {
        if(m_log_buffer[i].level >= min_level)
        {
            ArrayResize(entries, count + 1);
            entries[count] = m_log_buffer[i];
            count++;
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| MÉTODOS PRIVADOS                                                 |
//+------------------------------------------------------------------+

bool CLogger::InitializeLogFile()
{
    string full_path = LOG_PATH + "\\" + m_log_filename;
    
    m_log_handle = FileOpen(full_path, FILE_WRITE | FILE_READ | FILE_TXT);
    if(m_log_handle == INVALID_HANDLE)
    {
        Print("[LOGGER] Erro ao abrir arquivo: ", full_path, " Error: ", GetLastError());
        return false;
    }
    
    // Ir para o final do arquivo
    FileSeek(m_log_handle, 0, SEEK_END);
    
    // Escrever cabeçalho se arquivo novo
    if(FileSize(m_log_handle) == 0)
    {
        string header = StringFormat("=== %s Log Started at %s ===\n", 
                                   EA_NAME, TimeToString(TimeCurrent()));
        FileWriteString(m_log_handle, header);
        FileFlush(m_log_handle);
    }
    
    return true;
}

bool CLogger::WriteToFile(string message)
{
    if(m_log_handle == INVALID_HANDLE)
        return false;
    
    FileWriteString(m_log_handle, message + "\n");
    FileFlush(m_log_handle);
    
    return true;
}

void CLogger::WriteToTerminal(string message)
{
    Print(message);
}

string CLogger::FormatLogMessage(ENUM_LOG_LEVEL level, string module, string function, string message)
{
    string timestamp = TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
    string level_str = GetLevelString(level);
    
    if(module != "" && function != "")
    {
        return StringFormat("[%s] %s [%s::%s] %s", 
                          timestamp, level_str, module, function, message);
    }
    else if(module != "")
    {
        return StringFormat("[%s] %s [%s] %s", 
                          timestamp, level_str, module, message);
    }
    else
    {
        return StringFormat("[%s] %s %s", 
                          timestamp, level_str, message);
    }
}

string CLogger::GetLevelString(ENUM_LOG_LEVEL level)
{
    switch(level)
    {
        case LOG_LEVEL_DEBUG:    return "DEBUG";
        case LOG_LEVEL_INFO:     return "INFO ";
        case LOG_LEVEL_WARNING:  return "WARN ";
        case LOG_LEVEL_ERROR:    return "ERROR";
        case LOG_LEVEL_CRITICAL: return "CRIT ";
        default:                 return "UNKN ";
    }
}

bool CLogger::ShouldLog(ENUM_LOG_LEVEL level)
{
    return level >= m_log_level;
}

bool CLogger::IsModuleFiltered(string module)
{
    if(module == "")
        return false;
    
    int size = ArraySize(m_module_filters);
    for(int i = 0; i < size; i++)
    {
        if(m_module_filters[i] == module)
            return true;
    }
    
    return false;
}

bool CLogger::IsTimeFiltered()
{
    if(!m_use_time_filter)
        return false;
    
    datetime now = TimeCurrent();
    return now < m_time_filter_start || now > m_time_filter_end;
}

void CLogger::UpdateStatistics()
{
    m_total_logs++;
    
    datetime now = TimeCurrent();
    MqlDateTime dt_now, dt_last;
    TimeToStruct(now, dt_now);
    TimeToStruct(m_last_log_date, dt_last);
    
    if(dt_now.day == dt_last.day && dt_now.mon == dt_last.mon && dt_now.year == dt_last.year)
    {
        m_logs_today++;
    }
    else
    {
        m_logs_today = 1;
        m_last_log_date = now;
    }
}

bool CLogger::RotateLogFileIfNeeded()
{
    int current_size = GetLogFileSize();
    if(current_size > m_max_log_size * 1024 * 1024) // Converter MB para bytes
    {
        return RotateLogFile();
    }
    
    return true;
}

void CLogger::AddToBuffer(SLogEntry &entry)
{
    m_log_buffer[m_buffer_index] = entry;
    m_buffer_index++;
    
    if(m_buffer_index >= m_buffer_size)
    {
        m_buffer_index = 0;
        m_buffer_full = true;
    }
}

void CLogger::FlushBuffer()
{
    // Buffer já é escrito em tempo real, este método é para compatibilidade
}

bool CLogger::SetLogFileName(string filename)
{
    if(filename == "")
        return false;
    
    m_log_filename = filename;
    
    if(m_initialized && m_log_to_file)
    {
        // Fechar arquivo atual
        if(m_log_handle != INVALID_HANDLE)
        {
            FileClose(m_log_handle);
            m_log_handle = INVALID_HANDLE;
        }
        
        // Abrir novo arquivo
        return InitializeLogFile();
    }
    
    return true;
}

bool CLogger::EnableAutoRotate(bool enable)
{
    m_auto_rotate = enable;
    return true;
}

bool CLogger::ExportLogs(string filename, ENUM_LOG_LEVEL min_level = LOG_LEVEL_DEBUG)
{
    int handle = FileOpen(filename, FILE_WRITE | FILE_TXT);
    if(handle == INVALID_HANDLE)
        return false;
    
    // Cabeçalho
    FileWriteString(handle, "=== Log Export ===\n");
    FileWriteString(handle, "Timestamp,Level,Module,Function,Message\n");
    
    // Dados
    int total_entries = m_buffer_full ? m_buffer_size : m_buffer_index;
    for(int i = 0; i < total_entries; i++)
    {
        if(m_log_buffer[i].level >= min_level)
        {
            string line = StringFormat("%s,%s,%s,%s,\"%s\"\n",
                                     TimeToString(m_log_buffer[i].timestamp),
                                     GetLevelString(m_log_buffer[i].level),
                                     m_log_buffer[i].module,
                                     m_log_buffer[i].function,
                                     m_log_buffer[i].message);
            FileWriteString(handle, line);
        }
    }
    
    FileClose(handle);
    return true;
}

//+------------------------------------------------------------------+
//| INSTÂNCIA GLOBAL DO LOGGER                                       |
//+------------------------------------------------------------------+

// Instância global para uso em todo o EA
CLogger* g_logger = NULL;

// Funções de conveniência para acesso global
void LogDebug(string message) { if(g_logger != NULL) g_logger.Debug(message); }
void LogInfo(string message) { if(g_logger != NULL) g_logger.Info(message); }
void LogWarning(string message) { if(g_logger != NULL) g_logger.Warning(message); }
void LogError(string message) { if(g_logger != NULL) g_logger.Error(message); }
void LogCritical(string message) { if(g_logger != NULL) g_logger.Critical(message); }

void LogTrade(string action, ulong ticket, double volume, double price)
{
    if(g_logger != NULL) g_logger.LogTrade(action, ticket, volume, price);
}

void LogSignal(STradingSignal &signal)
{
    if(g_logger != NULL) g_logger.LogSignal(signal);
}

void LogErrorCode(int error_code, string description)
{
    if(g_logger != NULL) g_logger.LogError(error_code, description);
}

//+------------------------------------------------------------------+
//| FIM DO ARQUIVO                                                   |
//+------------------------------------------------------------------+