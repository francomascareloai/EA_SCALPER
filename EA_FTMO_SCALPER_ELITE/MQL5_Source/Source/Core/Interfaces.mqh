//+------------------------------------------------------------------+
//|                                              Interfaces.mqh     |
//|                                    EA FTMO Scalper Elite v1.0    |
//|                                      TradeDev_Master 2024        |
//+------------------------------------------------------------------+
#property copyright "TradeDev_Master 2024"
#property version   "1.00"
#property strict

#include "DataStructures.mqh"

//+------------------------------------------------------------------+
//| INTERFACE BASE                                                   |
//+------------------------------------------------------------------+

// Interface base para todos os módulos
interface IModule
{
    // Métodos virtuais puros
    virtual bool        Init() = 0;                    // Inicialização
    virtual void        Deinit() = 0;                  // Desinicialização
    virtual bool        IsInitialized() = 0;           // Verifica se está inicializado
    virtual string      GetModuleName() = 0;           // Nome do módulo
    virtual string      GetVersion() = 0;              // Versão do módulo
    virtual bool        SelfTest() = 0;                // Auto-teste
};

//+------------------------------------------------------------------+
//| INTERFACE DE ESTRATÉGIA                                          |
//+------------------------------------------------------------------+

// Interface para estratégias de trading
interface IStrategy : public IModule
{
    // Análise e geração de sinais
    virtual STradingSignal  GenerateSignal() = 0;              // Gerar sinal
    virtual bool            ValidateSignal(STradingSignal &signal) = 0;  // Validar sinal
    virtual int             GetConfluenceScore() = 0;          // Score de confluência
    virtual bool            ShouldEnter() = 0;                 // Deve entrar
    virtual bool            ShouldExit(ulong ticket) = 0;      // Deve sair
    
    // Configuração
    virtual bool            SetParameters(string params) = 0;   // Definir parâmetros
    virtual string          GetParameters() = 0;               // Obter parâmetros
    virtual bool            LoadConfig(string config_file) = 0; // Carregar configuração
    virtual bool            SaveConfig(string config_file) = 0; // Salvar configuração
    
    // Estado da estratégia
    virtual ENUM_SIGNAL_STRENGTH GetSignalStrength() = 0;      // Força do sinal
    virtual datetime        GetLastSignalTime() = 0;           // Último sinal
    virtual int             GetActiveSignals() = 0;            // Sinais ativos
    virtual bool            IsStrategyActive() = 0;            // Estratégia ativa
    
    // Análise de mercado
    virtual ENUM_MARKET_STRUCTURE GetMarketStructure() = 0;    // Estrutura de mercado
    virtual double          GetTrendStrength() = 0;            // Força da tendência
    virtual bool            IsMarketConditionGood() = 0;       // Condição de mercado boa
};

//+------------------------------------------------------------------+
//| INTERFACE DE GESTÃO DE RISCO                                     |
//+------------------------------------------------------------------+

// Interface para gestão de risco
interface IRiskManager : public IModule
{
    // Cálculo de risco
    virtual double          CalculatePositionSize(double risk_amount, double stop_loss_points) = 0;
    virtual double          CalculateRiskAmount(double account_balance, double risk_percent) = 0;
    virtual bool            ValidateRisk(STradingSignal &signal) = 0;
    virtual double          GetMaxPositionSize() = 0;
    virtual double          GetCurrentRisk() = 0;
    
    // Monitoramento
    virtual SRiskData       GetRiskData() = 0;                 // Dados de risco
    virtual bool            IsRiskAcceptable() = 0;            // Risco aceitável
    virtual double          GetDrawdown() = 0;                 // Drawdown atual
    virtual double          GetMaxDrawdown() = 0;              // Drawdown máximo
    virtual bool            CheckDailyLoss() = 0;              // Verificar perda diária
    
    // Gestão de posições
    virtual bool            CanOpenPosition() = 0;             // Pode abrir posição
    virtual bool            ShouldClosePosition(ulong ticket) = 0; // Deve fechar posição
    virtual bool            UpdateStopLoss(ulong ticket, double new_sl) = 0; // Atualizar SL
    virtual bool            UpdateTakeProfit(ulong ticket, double new_tp) = 0; // Atualizar TP
    
    // Correlação
    virtual double          GetCorrelation(string symbol1, string symbol2) = 0;
    virtual bool            CheckCorrelationRisk() = 0;        // Verificar risco de correlação
    virtual int             GetMaxCorrelatedPositions() = 0;   // Máximo de posições correlacionadas
    
    // Configuração
    virtual bool            SetRiskParameters(ENUM_RISK_TYPE type, double value) = 0;
    virtual ENUM_RISK_TYPE  GetRiskType() = 0;                 // Tipo de risco
    virtual double          GetRiskPercent() = 0;              // Percentual de risco
};

//+------------------------------------------------------------------+
//| INTERFACE DE COMPLIANCE                                          |
//+------------------------------------------------------------------+

// Interface para verificação de compliance
interface IComplianceChecker : public IModule
{
    // Verificações FTMO
    virtual bool            CheckFTMOCompliance() = 0;         // Verificar compliance FTMO
    virtual SFTMOData       GetFTMOData() = 0;                 // Dados FTMO
    virtual ENUM_FTMO_VIOLATION GetViolationType() = 0;        // Tipo de violação
    virtual bool            IsCompliant() = 0;                 // Está em conformidade
    virtual double          GetDailyLossLimit() = 0;           // Limite de perda diária
    virtual double          GetTotalLossLimit() = 0;           // Limite de perda total
    
    // Verificações de trading
    virtual bool            CanTrade() = 0;                    // Pode negociar
    virtual bool            IsNewsTime() = 0;                  // Horário de notícias
    virtual bool            IsWeekendHolding() = 0;            // Segurando no fim de semana
    virtual bool            CheckConsistency() = 0;            // Verificar consistência
    virtual bool            CheckTradingHours() = 0;           // Verificar horário de trading
    
    // Monitoramento
    virtual void            UpdateDailyPnL(double pnl) = 0;    // Atualizar P&L diário
    virtual void            UpdateTotalPnL(double pnl) = 0;    // Atualizar P&L total
    virtual void            ResetDailyCounters() = 0;          // Resetar contadores diários
    virtual bool            LogViolation(ENUM_FTMO_VIOLATION type, string description) = 0;
    
    // Configuração
    virtual bool            SetFTMOParameters(double initial_balance, double daily_limit, double total_limit) = 0;
    virtual bool            EnableNewsFilter(bool enable) = 0;  // Habilitar filtro de notícias
    virtual bool            SetTradingHours(int start_hour, int end_hour) = 0;
};

//+------------------------------------------------------------------+
//| INTERFACE DE ANÁLISE DE VOLUME                                   |
//+------------------------------------------------------------------+

// Interface para análise de volume
interface IVolumeAnalyzer : public IModule
{
    // Análise básica
    virtual SVolumeData     GetVolumeData() = 0;               // Dados de volume
    virtual double          GetCurrentVolume() = 0;            // Volume atual
    virtual double          GetAverageVolume(int period) = 0;  // Volume médio
    virtual double          GetVolumeRatio() = 0;              // Razão de volume
    virtual bool            IsVolumeSpike() = 0;               // Spike de volume
    
    // Volume Profile
    virtual double          GetPOC() = 0;                      // Point of Control
    virtual double          GetValueAreaHigh() = 0;            // Value Area High
    virtual double          GetValueAreaLow() = 0;             // Value Area Low
    virtual bool            IsPriceInValueArea(double price) = 0; // Preço na Value Area
    virtual double          GetVolumeAtPrice(double price) = 0; // Volume no preço
    
    // Análise avançada
    virtual double          GetVolumeDelta() = 0;              // Delta de volume
    virtual double          GetCumulativeVolume() = 0;         // Volume cumulativo
    virtual bool            IsVolumeConfirmation(ENUM_SIGNAL_TYPE signal_type) = 0;
    virtual double          GetVolumeStrength() = 0;           // Força do volume
    
    // Configuração
    virtual bool            SetVolumeType(ENUM_VOLUME_ANALYSIS type) = 0;
    virtual bool            SetVolumePeriod(int period) = 0;   // Período de análise
    virtual bool            SetVolumeThreshold(double threshold) = 0; // Limite de volume
    virtual ENUM_VOLUME_ANALYSIS GetVolumeType() = 0;          // Tipo de volume
};

//+------------------------------------------------------------------+
//| INTERFACE DE SISTEMA DE ALERTAS                                  |
//+------------------------------------------------------------------+

// Interface para sistema de alertas
interface IAlertSystem : public IModule
{
    // Envio de alertas
    virtual bool            SendAlert(ENUM_ALERT_TYPE type, string message) = 0;
    virtual bool            SendAlert(SAlert &alert) = 0;      // Enviar alerta estruturado
    virtual bool            SendPushNotification(string message) = 0;
    virtual bool            SendEmail(string subject, string message) = 0;
    virtual bool            PlaySound(string sound_file) = 0;   // Tocar som
    virtual bool            ShowPopup(string message) = 0;     // Mostrar popup
    
    // Configuração de canais
    virtual bool            EnableChannel(ENUM_ALERT_CHANNEL channel, bool enable) = 0;
    virtual bool            IsChannelEnabled(ENUM_ALERT_CHANNEL channel) = 0;
    virtual bool            SetChannelPriority(ENUM_ALERT_CHANNEL channel, int priority) = 0;
    virtual bool            ConfigureEmail(string smtp_server, string username, string password) = 0;
    
    // Gestão de alertas
    virtual int             GetPendingAlerts() = 0;            // Alertas pendentes
    virtual bool            ClearAlerts() = 0;                 // Limpar alertas
    virtual bool            SetAlertLimit(int max_alerts) = 0; // Limite de alertas
    virtual bool            GetAlertHistory(SAlert &alerts[]) = 0; // Histórico de alertas
    
    // Filtros
    virtual bool            SetAlertFilter(ENUM_ALERT_TYPE type, bool enable) = 0;
    virtual bool            SetMinimumPriority(int min_priority) = 0;
    virtual bool            SetAlertInterval(int interval_seconds) = 0; // Intervalo entre alertas
    
    // Estatísticas
    virtual int             GetTotalAlertsSent() = 0;          // Total de alertas enviados
    virtual int             GetAlertsToday() = 0;              // Alertas hoje
    virtual double          GetAlertSuccessRate() = 0;         // Taxa de sucesso
};

//+------------------------------------------------------------------+
//| INTERFACE DE LOGGING                                             |
//+------------------------------------------------------------------+

// Interface para sistema de logging
interface ILogger : public IModule
{
    // Métodos de log
    virtual void            Debug(string message) = 0;         // Log debug
    virtual void            Info(string message) = 0;          // Log info
    virtual void            Warning(string message) = 0;       // Log warning
    virtual void            Error(string message) = 0;         // Log error
    virtual void            Critical(string message) = 0;      // Log critical
    
    // Log estruturado
    virtual void            Log(ENUM_LOG_LEVEL level, string module, string function, string message) = 0;
    virtual void            LogTrade(string action, ulong ticket, double volume, double price) = 0;
    virtual void            LogSignal(STradingSignal &signal) = 0;
    virtual void            LogError(int error_code, string description) = 0;
    
    // Configuração
    virtual bool            SetLogLevel(ENUM_LOG_LEVEL level) = 0;
    virtual ENUM_LOG_LEVEL  GetLogLevel() = 0;                 // Nível de log
    virtual bool            SetLogToFile(bool enable) = 0;     // Log para arquivo
    virtual bool            SetLogToTerminal(bool enable) = 0; // Log para terminal
    virtual bool            SetMaxLogSize(int max_size_mb) = 0; // Tamanho máximo do log
    
    // Gestão de arquivos
    virtual bool            RotateLogFile() = 0;               // Rotacionar arquivo de log
    virtual bool            ClearLogs() = 0;                   // Limpar logs
    virtual string          GetLogFileName() = 0;              // Nome do arquivo de log
    virtual int             GetLogFileSize() = 0;              // Tamanho do arquivo de log
    
    // Filtros
    virtual bool            SetModuleFilter(string module, bool enable) = 0;
    virtual bool            SetTimeFilter(datetime start_time, datetime end_time) = 0;
    virtual bool            GetLogEntries(SLogEntry &entries[], ENUM_LOG_LEVEL min_level, int max_entries) = 0;
};

//+------------------------------------------------------------------+
//| INTERFACE DE MOTOR DE TRADING                                    |
//+------------------------------------------------------------------+

// Interface para motor de execução de trades
interface ITradingEngine : public IModule
{
    // Execução de trades
    virtual ulong           OpenPosition(STradingSignal &signal) = 0;  // Abrir posição
    virtual bool            ClosePosition(ulong ticket) = 0;           // Fechar posição
    virtual bool            CloseAllPositions() = 0;                   // Fechar todas as posições
    virtual bool            ModifyPosition(ulong ticket, double sl, double tp) = 0;
    
    // Gestão de ordens
    virtual ulong           PlacePendingOrder(STradingSignal &signal) = 0;
    virtual bool            DeletePendingOrder(ulong ticket) = 0;      // Deletar ordem pendente
    virtual bool            ModifyPendingOrder(ulong ticket, double price, double sl, double tp) = 0;
    
    // Informações de posições
    virtual int             GetOpenPositions() = 0;                    // Posições abertas
    virtual int             GetPendingOrders() = 0;                    // Ordens pendentes
    virtual double          GetTotalProfit() = 0;                      // Lucro total
    virtual double          GetPositionProfit(ulong ticket) = 0;       // Lucro da posição
    virtual bool            IsPositionOpen(ulong ticket) = 0;          // Posição está aberta
    
    // Trailing Stop
    virtual bool            EnableTrailingStop(ulong ticket, double distance) = 0;
    virtual bool            DisableTrailingStop(ulong ticket) = 0;     // Desabilitar trailing
    virtual bool            UpdateTrailingStop(ulong ticket) = 0;      // Atualizar trailing
    virtual bool            SetTrailingDistance(double distance) = 0;  // Distância do trailing
    
    // Partial Close
    virtual bool            PartialClose(ulong ticket, double volume_percent) = 0;
    virtual bool            ScaleOut(ulong ticket, double &levels[], double &volumes[]) = 0;
    virtual bool            BreakEven(ulong ticket, double trigger_points) = 0;
    
    // Configuração
    virtual bool            SetSlippage(int slippage_points) = 0;       // Definir slippage
    virtual bool            SetMagicNumber(int magic) = 0;              // Número mágico
    virtual bool            SetMaxRetries(int retries) = 0;             // Máximo de tentativas
    virtual bool            SetExecutionTimeout(int timeout_ms) = 0;    // Timeout de execução
    
    // Estatísticas
    virtual SExecutionStats GetExecutionStats() = 0;                   // Estatísticas de execução
    virtual double          GetAverageExecutionTime() = 0;             // Tempo médio de execução
    virtual double          GetSuccessRate() = 0;                      // Taxa de sucesso
    virtual int             GetFailedExecutions() = 0;                 // Execuções falhadas
};

//+------------------------------------------------------------------+
//| INTERFACE DE ANÁLISE DE PERFORMANCE                              |
//+------------------------------------------------------------------+

// Interface para análise de performance
interface IPerformanceAnalyzer : public IModule
{
    // Métricas básicas
    virtual SPerformanceData GetPerformanceData() = 0;                 // Dados de performance
    virtual double          GetProfitFactor() = 0;                     // Fator de lucro
    virtual double          GetSharpeRatio() = 0;                      // Índice Sharpe
    virtual double          GetWinRate() = 0;                          // Taxa de vitória
    virtual double          GetMaxDrawdown() = 0;                      // Drawdown máximo
    
    // Métricas avançadas
    virtual double          GetSortinoRatio() = 0;                     // Índice Sortino
    virtual double          GetCalmarRatio() = 0;                      // Índice Calmar
    virtual double          GetRecoveryFactor() = 0;                   // Fator de recuperação
    virtual double          GetExpectancy() = 0;                       // Expectativa
    virtual double          GetVolatility() = 0;                       // Volatilidade
    
    // Análise temporal
    virtual double          GetMonthlyReturn() = 0;                    // Retorno mensal
    virtual double          GetAnnualizedReturn() = 0;                 // Retorno anualizado
    virtual double          GetBestMonth() = 0;                        // Melhor mês
    virtual double          GetWorstMonth() = 0;                       // Pior mês
    virtual int             GetConsecutiveWins() = 0;                  // Vitórias consecutivas
    virtual int             GetConsecutiveLosses() = 0;                // Perdas consecutivas
    
    // Relatórios
    virtual string          GenerateReport() = 0;                      // Gerar relatório
    virtual bool            SaveReport(string filename) = 0;           // Salvar relatório
    virtual bool            ExportToCSV(string filename) = 0;          // Exportar para CSV
    virtual bool            ExportToHTML(string filename) = 0;         // Exportar para HTML
    
    // Configuração
    virtual bool            SetBenchmark(double benchmark_return) = 0; // Definir benchmark
    virtual bool            SetRiskFreeRate(double rate) = 0;          // Taxa livre de risco
    virtual bool            SetAnalysisPeriod(datetime start, datetime end) = 0;
    virtual bool            UpdatePerformance() = 0;                   // Atualizar performance
};

//+------------------------------------------------------------------+
//| INTERFACE DE CONFIGURAÇÃO                                        |
//+------------------------------------------------------------------+

// Interface para gerenciamento de configuração
class IConfigManager : public IModule
{
public:
    // Carregamento e salvamento
    virtual bool            LoadConfig(string config_file) = 0;        // Carregar configuração
    virtual bool            SaveConfig(string config_file) = 0;        // Salvar configuração
    virtual bool            LoadDefaultConfig() = 0;                   // Carregar configuração padrão
    virtual bool            ResetToDefaults() = 0;                     // Resetar para padrões
    
    // Gestão de parâmetros
    virtual bool            SetParameter(string key, string value) = 0; // Definir parâmetro
    virtual string          GetParameter(string key) = 0;              // Obter parâmetro
    virtual bool            HasParameter(string key) = 0;              // Tem parâmetro
    virtual bool            RemoveParameter(string key) = 0;           // Remover parâmetro
    
    // Validação
    virtual bool            ValidateConfig() = 0;                      // Validar configuração
    virtual bool            GetValidationErrors(string &errors[]) = 0; // Erros de validação
    virtual bool            IsConfigValid() = 0;                       // Configuração válida
    
    // Backup e restore
    virtual bool            BackupConfig(string backup_name) = 0;      // Backup da configuração
    virtual bool            RestoreConfig(string backup_name) = 0;     // Restaurar configuração
    virtual bool            GetBackupList(string &backups[]) = 0;      // Lista de backups
    
    // Configuração estruturada
    virtual SEAConfig       GetEAConfig() = 0;                         // Configuração do EA
    virtual bool            SetEAConfig(SEAConfig &config) = 0;        // Definir configuração do EA
    virtual bool            UpdateConfig(SEAConfig &config) = 0;       // Atualizar configuração
};

//+------------------------------------------------------------------+
//| INTERFACE DE CACHE                                               |
//+------------------------------------------------------------------+

// Interface para sistema de cache
interface ICacheManager : public IModule
{
    // Operações básicas
    virtual bool            Set(string key, string value, int ttl_seconds = 0) = 0;
    virtual string          Get(string key) = 0;                       // Obter valor
    virtual bool            Has(string key) = 0;                       // Tem chave
    virtual bool            Remove(string key) = 0;                    // Remover chave
    virtual bool            Clear() = 0;                               // Limpar cache
    
    // Gestão de expiração
    virtual bool            SetTTL(string key, int ttl_seconds) = 0;   // Definir TTL
    virtual int             GetTTL(string key) = 0;                    // Obter TTL
    virtual bool            IsExpired(string key) = 0;                 // Está expirado
    virtual void            CleanupExpired() = 0;                      // Limpar expirados
    
    // Estatísticas
    virtual int             GetCacheSize() = 0;                        // Tamanho do cache
    virtual int             GetHitCount() = 0;                         // Contagem de hits
    virtual int             GetMissCount() = 0;                        // Contagem de misses
    virtual double          GetHitRatio() = 0;                         // Taxa de hit
    
    // Configuração
    virtual bool            SetMaxSize(int max_entries) = 0;           // Tamanho máximo
    virtual bool            SetDefaultTTL(int ttl_seconds) = 0;        // TTL padrão
    virtual bool            EnableCompression(bool enable) = 0;        // Habilitar compressão
};

//+------------------------------------------------------------------+
//| INTERFACE DE DETECTOR                                            |
//+------------------------------------------------------------------+

// Interface para detectores de estruturas de mercado
interface IDetector : public IModule
{
    // Métodos básicos de detecção
    virtual bool            Init(string symbol, ENUM_TIMEFRAMES timeframe) = 0;  // Inicialização com símbolo e timeframe
    virtual void            Deinit() = 0;                          // Desinicialização
    virtual bool            SelfTest() = 0;                        // Auto-teste
    
    // Detecção de estruturas
    virtual bool            DetectStructures() = 0;                // Detectar estruturas
    virtual bool            HasNewStructure() = 0;                 // Tem nova estrutura
    virtual string          GetLastStructureDescription() = 0;     // Descrição da última estrutura
    
    // Configuração
    virtual bool            SetLookbackCandles(int candles) = 0;   // Definir velas de lookback
    virtual bool            SetSwingStrength(int strength) = 0;    // Definir força do swing
    virtual bool            SetMinStructureSize(double size) = 0;  // Tamanho mínimo da estrutura
    virtual bool            SetVolumeConfirmation(bool enable) = 0; // Confirmação por volume
    virtual bool            SetStrictConfirmation(bool enable) = 0; // Confirmação rigorosa
    
    // Estatísticas e análise
    virtual double          GetDetectionAccuracy() = 0;            // Precisão da detecção
    virtual void            ResetStatistics() = 0;                 // Resetar estatísticas
    virtual string          GetDebugInfo() = 0;                    // Informações de debug
    virtual bool            ValidateConfiguration() = 0;           // Validar configuração
};

//+------------------------------------------------------------------+
//| Interface para analisadores genéricos                           |
//+------------------------------------------------------------------+
interface IAnalyzer : public IModule
{
    // Métodos de análise
    virtual bool            Analyze() = 0;                         // Executar análise
    virtual bool            HasNewSignal() = 0;                    // Verificar novo sinal
    virtual string          GetLastSignalDescription() = 0;        // Descrição do último sinal
    
    // Configuração
    virtual bool            SetAnalysisPeriod(int period) = 0;     // Definir período de análise
    virtual bool            SetSensitivity(double sensitivity) = 0; // Definir sensibilidade
    
    // Estatísticas
    virtual double          GetAccuracy() = 0;                     // Obter precisão
    virtual int             GetSignalCount() = 0;                  // Contar sinais
    virtual void            ResetStatistics() = 0;                 // Resetar estatísticas
    
    // Debug e validação
    virtual string          GetDebugInfo() = 0;                    // Informações de debug
    virtual bool            ValidateConfiguration() = 0;           // Validar configuração
};

//+------------------------------------------------------------------+
//| Interface para gerenciadores genéricos                          |
//+------------------------------------------------------------------+
interface IManager : public IModule
{
    // Métodos de gerenciamento
    virtual bool            Start() = 0;                           // Iniciar gerenciamento
    virtual bool            Stop() = 0;                            // Parar gerenciamento
    virtual bool            IsRunning() = 0;                       // Verificar se está rodando
    virtual bool            Update() = 0;                          // Atualizar estado
    
    // Configuração
    virtual bool            LoadConfiguration(string config) = 0;   // Carregar configuração
    virtual string          SaveConfiguration() = 0;               // Salvar configuração
    virtual bool            SetParameter(string key, string value) = 0; // Definir parâmetro
    virtual string          GetParameter(string key) = 0;          // Obter parâmetro
    
    // Status e estatísticas
    virtual string          GetStatus() = 0;                       // Obter status atual
    virtual double          GetPerformanceMetric() = 0;            // Métrica de performance
    virtual void            ResetStatistics() = 0;                 // Resetar estatísticas
    
    // Debug e validação
    virtual string          GetDebugInfo() = 0;                    // Informações de debug
    virtual bool            ValidateConfiguration() = 0;           // Validar configuração
};

//+------------------------------------------------------------------+
//| FIM DO ARQUIVO                                                   |
//+------------------------------------------------------------------+