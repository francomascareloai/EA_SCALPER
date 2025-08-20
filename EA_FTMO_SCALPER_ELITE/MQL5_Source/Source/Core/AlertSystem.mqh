//+------------------------------------------------------------------+
//|                                                  AlertSystem.mqh |
//|                                    TradeDev_Master Elite System |
//|                      Advanced Alert System for FTMO Scalping   |
//+------------------------------------------------------------------+
#property copyright "TradeDev_Master"
#property link      "https://github.com/TradeDev_Master"
#property version   "2.10"
#property description "High-Performance Alert System with Multi-Channel Notifications"

#include "DataStructures.mqh"
#include "Interfaces.mqh"
#include "Logger.mqh"
#include "ConfigManager.mqh"

//+------------------------------------------------------------------+
//| Enumerações para sistema de alertas                              |
//+------------------------------------------------------------------+
enum ENUM_ALERT_TYPE
{
   ALERT_TYPE_TRADE = 0,         // Alerta de trade
   ALERT_TYPE_RISK = 1,          // Alerta de risco
   ALERT_TYPE_SIGNAL = 2,        // Alerta de sinal
   ALERT_TYPE_SYSTEM = 3,        // Alerta de sistema
   ALERT_TYPE_FTMO = 4,          // Alerta FTMO
   ALERT_TYPE_PERFORMANCE = 5,   // Alerta de performance
   ALERT_TYPE_ERROR = 6,         // Alerta de erro
   ALERT_TYPE_WARNING = 7,       // Alerta de aviso
   ALERT_TYPE_INFO = 8           // Alerta informativo
};

enum ENUM_ALERT_PRIORITY
{
   ALERT_PRIORITY_LOW = 0,       // Prioridade baixa
   ALERT_PRIORITY_NORMAL = 1,    // Prioridade normal
   ALERT_PRIORITY_HIGH = 2,      // Prioridade alta
   ALERT_PRIORITY_CRITICAL = 3,  // Prioridade crítica
   ALERT_PRIORITY_EMERGENCY = 4  // Emergência
};

enum ENUM_ALERT_CHANNEL
{
   ALERT_CHANNEL_POPUP = 0,      // Popup no terminal
   ALERT_CHANNEL_SOUND = 1,      // Som
   ALERT_CHANNEL_EMAIL = 2,      // Email
   ALERT_CHANNEL_PUSH = 3,       // Notificação push
   ALERT_CHANNEL_LOG = 4,        // Log apenas
   ALERT_CHANNEL_TELEGRAM = 5,   // Telegram (futuro)
   ALERT_CHANNEL_WEBHOOK = 6     // Webhook (futuro)
};

enum ENUM_ALERT_STATUS
{
   ALERT_STATUS_PENDING = 0,     // Pendente
   ALERT_STATUS_SENT = 1,        // Enviado
   ALERT_STATUS_FAILED = 2,      // Falhou
   ALERT_STATUS_ACKNOWLEDGED = 3, // Reconhecido
   ALERT_STATUS_EXPIRED = 4      // Expirado
};

enum ENUM_SOUND_TYPE
{
   SOUND_TYPE_NONE = 0,          // Sem som
   SOUND_TYPE_ALERT = 1,         // Som de alerta
   SOUND_TYPE_SUCCESS = 2,       // Som de sucesso
   SOUND_TYPE_ERROR = 3,         // Som de erro
   SOUND_TYPE_WARNING = 4,       // Som de aviso
   SOUND_TYPE_CUSTOM = 5         // Som customizado
};

//+------------------------------------------------------------------+
//| Estruturas para sistema de alertas                               |
//+------------------------------------------------------------------+
struct SAlertMessage
{
   int id;                       // ID único do alerta
   datetime timestamp;           // Timestamp do alerta
   ENUM_ALERT_TYPE type;         // Tipo do alerta
   ENUM_ALERT_PRIORITY priority; // Prioridade
   string title;                 // Título do alerta
   string message;               // Mensagem do alerta
   string symbol;                // Símbolo relacionado
   double price;                 // Preço relacionado
   string additional_data;       // Dados adicionais
   ENUM_ALERT_STATUS status;     // Status do alerta
   datetime expiry_time;         // Tempo de expiração
   int retry_count;              // Contador de tentativas
   bool is_persistent;           // Se é persistente
};

struct SAlertChannel
{
   ENUM_ALERT_CHANNEL channel;   // Canal de alerta
   bool is_enabled;              // Se está habilitado
   ENUM_ALERT_PRIORITY min_priority; // Prioridade mínima
   string configuration;         // Configuração específica
   datetime last_sent;           // Último envio
   int send_count;               // Contador de envios
   bool rate_limit_enabled;      // Se tem limite de taxa
   int max_per_minute;           // Máximo por minuto
   int current_minute_count;     // Contador do minuto atual
   datetime current_minute;      // Minuto atual
};

struct SAlertRule
{
   int id;                       // ID da regra
   string name;                  // Nome da regra
   ENUM_ALERT_TYPE type;         // Tipo de alerta
   bool is_enabled;              // Se está habilitada
   string condition;             // Condição para disparar
   ENUM_ALERT_PRIORITY priority; // Prioridade do alerta
   ENUM_ALERT_CHANNEL channels[10]; // Canais para envio
   int channel_count;            // Número de canais
   int cooldown_seconds;         // Tempo de cooldown
   datetime last_triggered;      // Último disparo
   int trigger_count;            // Contador de disparos
   bool is_one_time;             // Se é único
   string custom_message;        // Mensagem customizada
};

struct SAlertStatistics
{
   int total_alerts;             // Total de alertas
   int alerts_by_type[9];        // Alertas por tipo
   int alerts_by_priority[5];    // Alertas por prioridade
   int alerts_by_channel[7];     // Alertas por canal
   int successful_sends;         // Envios bem-sucedidos
   int failed_sends;             // Envios falhados
   datetime first_alert;         // Primeiro alerta
   datetime last_alert;          // Último alerta
   double avg_response_time;     // Tempo médio de resposta
   int rate_limit_hits;          // Hits no limite de taxa
};

struct SAlertConfiguration
{
   bool global_enabled;          // Sistema globalmente habilitado
   ENUM_ALERT_PRIORITY min_priority; // Prioridade mínima global
   bool enable_sound;            // Habilitar sons
   bool enable_popup;            // Habilitar popups
   bool enable_email;            // Habilitar email
   bool enable_push;             // Habilitar push
   string email_smtp_server;     // Servidor SMTP
   string email_login;           // Login do email
   string email_password;        // Senha do email
   string email_to;              // Email destinatário
   string push_id;               // ID para push
   int max_alerts_per_minute;    // Máximo de alertas por minuto
   int alert_history_days;       // Dias de histórico
   bool auto_acknowledge;        // Auto reconhecimento
   int acknowledgment_timeout;   // Timeout para reconhecimento
   string custom_sound_file;     // Arquivo de som customizado
   bool log_all_alerts;          // Log de todos os alertas
};

//+------------------------------------------------------------------+
//| Classe principal do sistema de alertas                           |
//+------------------------------------------------------------------+
class CAlertSystem : public IManager
{
private:
   // Configuração
   SAlertConfiguration m_config;
   
   // Gerenciamento de alertas
   SAlertMessage m_alert_queue[];
   SAlertMessage m_alert_history[];
   SAlertRule m_alert_rules[];
   SAlertChannel m_channels[7];
   
   // Controle
   int m_next_alert_id;
   int m_queue_size;
   int m_history_size;
   int m_rules_count;
   datetime m_last_cleanup;
   
   // Estatísticas
   SAlertStatistics m_statistics;
   
   // Cache e performance
   datetime m_last_rate_check;
   int m_current_minute_alerts;
   
   // Variáveis de controle
   bool m_is_initialized;
   string m_symbol;
   
public:
   // Construtor e destrutor
   CAlertSystem();
   ~CAlertSystem();
   
   // Implementação da interface IManager
   virtual bool Init(void) override;
   virtual void Deinit(void) override;
   virtual bool SelfTest(void) override;
   virtual void SetConfig(const string config_string) override;
   virtual string GetConfig(void) override;
   virtual string GetStatus(void) override;
   
   // Configuração
   void SetAlertConfiguration(const SAlertConfiguration &config);
   void SetSymbol(const string symbol) { m_symbol = symbol; }
   
   // Gerenciamento de canais
   bool ConfigureChannel(const ENUM_ALERT_CHANNEL channel, const bool enabled, 
                        const ENUM_ALERT_PRIORITY min_priority = ALERT_PRIORITY_LOW);
   bool SetChannelRateLimit(const ENUM_ALERT_CHANNEL channel, const int max_per_minute);
   SAlertChannel GetChannelInfo(const ENUM_ALERT_CHANNEL channel);
   
   // Envio de alertas
   int SendAlert(const ENUM_ALERT_TYPE type, const ENUM_ALERT_PRIORITY priority,
                const string title, const string message, 
                const string symbol = "", const double price = 0.0);
   int SendTradeAlert(const string message, const string symbol, const double price);
   int SendRiskAlert(const string message, const ENUM_ALERT_PRIORITY priority = ALERT_PRIORITY_HIGH);
   int SendFTMOAlert(const string message, const ENUM_ALERT_PRIORITY priority = ALERT_PRIORITY_CRITICAL);
   int SendSystemAlert(const string message, const ENUM_ALERT_PRIORITY priority = ALERT_PRIORITY_NORMAL);
   int SendSignalAlert(const string signal_name, const string symbol, const double price);
   
   // Alertas específicos
   void AlertTradeOpened(const string symbol, const int ticket, const double volume, const double price);
   void AlertTradeClosed(const string symbol, const int ticket, const double profit);
   void AlertStopLossHit(const string symbol, const int ticket, const double price);
   void AlertTakeProfitHit(const string symbol, const int ticket, const double price);
   void AlertDrawdownWarning(const double current_dd, const double max_dd);
   void AlertDailyLimitReached(const double current_loss, const double limit);
   void AlertMarginCall(const double margin_level);
   void AlertConnectionLost(void);
   void AlertHighSpread(const string symbol, const double spread);
   void AlertNewsEvent(const string event_name, const datetime event_time);
   
   // Gerenciamento de regras
   int AddAlertRule(const string name, const ENUM_ALERT_TYPE type, const string condition,
                   const ENUM_ALERT_PRIORITY priority, const ENUM_ALERT_CHANNEL channels[],
                   const int channel_count);
   bool RemoveAlertRule(const int rule_id);
   bool EnableAlertRule(const int rule_id, const bool enabled);
   void ProcessAlertRules(void);
   
   // Processamento da fila
   void ProcessAlertQueue(void);
   bool SendAlertToChannel(const SAlertMessage &alert, const ENUM_ALERT_CHANNEL channel);
   
   // Canais específicos
   bool SendPopupAlert(const SAlertMessage &alert);
   bool SendSoundAlert(const SAlertMessage &alert);
   bool SendEmailAlert(const SAlertMessage &alert);
   bool SendPushAlert(const SAlertMessage &alert);
   
   // Controle de taxa
   bool CheckRateLimit(const ENUM_ALERT_CHANNEL channel);
   void UpdateRateLimits(void);
   
   // Histórico e estatísticas
   SAlertMessage[] GetAlertHistory(const datetime from_time = 0, const datetime to_time = 0);
   SAlertStatistics GetStatistics(void) { return m_statistics; }
   void ClearHistory(const datetime before_time = 0);
   void UpdateStatistics(const SAlertMessage &alert, const bool success);
   
   // Reconhecimento
   bool AcknowledgeAlert(const int alert_id);
   void AutoAcknowledgeExpiredAlerts(void);
   
   // Utilitários
   string FormatAlertMessage(const SAlertMessage &alert);
   string GetAlertTypeString(const ENUM_ALERT_TYPE type);
   string GetPriorityString(const ENUM_ALERT_PRIORITY priority);
   ENUM_SOUND_TYPE GetSoundForAlert(const ENUM_ALERT_TYPE type, const ENUM_ALERT_PRIORITY priority);
   
   // Relatórios
   string GenerateAlertReport(void);
   string GenerateChannelReport(void);
   string GenerateStatisticsReport(void);
   
   // Manutenção
   void CleanupExpiredAlerts(void);
   void OptimizeAlertQueue(void);
   
private:
   // Métodos auxiliares
   int GetNextAlertId(void) { return ++m_next_alert_id; }
   void AddToQueue(const SAlertMessage &alert);
   void AddToHistory(const SAlertMessage &alert);
   bool ValidateAlert(const SAlertMessage &alert);
   void InitializeChannels(void);
   void InitializeStatistics(void);
   bool IsChannelAvailable(const ENUM_ALERT_CHANNEL channel);
   string EncodeEmailMessage(const SAlertMessage &alert);
   void LogAlertEvent(const string message, const ENUM_LOG_LEVEL level);
   datetime GetNextMinute(void);
   void ResetMinuteCounters(void);
};

//+------------------------------------------------------------------+
//| Construtor                                                        |
//+------------------------------------------------------------------+
CAlertSystem::CAlertSystem()
{
   // Configuração padrão
   m_config.global_enabled = true;
   m_config.min_priority = ALERT_PRIORITY_LOW;
   m_config.enable_sound = true;
   m_config.enable_popup = true;
   m_config.enable_email = false;
   m_config.enable_push = false;
   m_config.email_smtp_server = "";
   m_config.email_login = "";
   m_config.email_password = "";
   m_config.email_to = "";
   m_config.push_id = "";
   m_config.max_alerts_per_minute = 10;
   m_config.alert_history_days = 7;
   m_config.auto_acknowledge = true;
   m_config.acknowledgment_timeout = 300; // 5 minutos
   m_config.custom_sound_file = "";
   m_config.log_all_alerts = true;
   
   // Inicializar variáveis
   m_next_alert_id = 1;
   m_queue_size = 0;
   m_history_size = 0;
   m_rules_count = 0;
   m_last_cleanup = 0;
   m_last_rate_check = 0;
   m_current_minute_alerts = 0;
   m_is_initialized = false;
   m_symbol = "";
   
   // Inicializar estruturas
   InitializeChannels();
   InitializeStatistics();
}

//+------------------------------------------------------------------+
//| Destrutor                                                         |
//+------------------------------------------------------------------+
CAlertSystem::~CAlertSystem()
{
   ArrayFree(m_alert_queue);
   ArrayFree(m_alert_history);
   ArrayFree(m_alert_rules);
}

//+------------------------------------------------------------------+
//| Inicialização                                                     |
//+------------------------------------------------------------------+
bool CAlertSystem::Init(void)
{
   g_logger.Info("Inicializando Alert System...");
   
   // Configurar símbolo padrão
   if(m_symbol == "")
   {
      m_symbol = _Symbol;
   }
   
   // Redimensionar arrays
   ArrayResize(m_alert_queue, 100);
   ArrayResize(m_alert_history, 1000);
   ArrayResize(m_alert_rules, 50);
   
   // Configurar canais padrão
   ConfigureChannel(ALERT_CHANNEL_POPUP, m_config.enable_popup, ALERT_PRIORITY_NORMAL);
   ConfigureChannel(ALERT_CHANNEL_SOUND, m_config.enable_sound, ALERT_PRIORITY_NORMAL);
   ConfigureChannel(ALERT_CHANNEL_EMAIL, m_config.enable_email, ALERT_PRIORITY_HIGH);
   ConfigureChannel(ALERT_CHANNEL_PUSH, m_config.enable_push, ALERT_PRIORITY_HIGH);
   ConfigureChannel(ALERT_CHANNEL_LOG, m_config.log_all_alerts, ALERT_PRIORITY_LOW);
   
   // Configurar limites de taxa
   SetChannelRateLimit(ALERT_CHANNEL_POPUP, 5);
   SetChannelRateLimit(ALERT_CHANNEL_SOUND, 3);
   SetChannelRateLimit(ALERT_CHANNEL_EMAIL, 2);
   SetChannelRateLimit(ALERT_CHANNEL_PUSH, 5);
   
   m_is_initialized = true;
   g_logger.Info("Alert System inicializado com sucesso");
   
   // Enviar alerta de inicialização
   SendSystemAlert("Alert System inicializado", ALERT_PRIORITY_LOW);
   
   return true;
}

//+------------------------------------------------------------------+
//| Deinicialização                                                   |
//+------------------------------------------------------------------+
void CAlertSystem::Deinit(void)
{
   if(m_is_initialized)
   {
      // Processar alertas pendentes
      ProcessAlertQueue();
      
      // Enviar alerta de finalização
      SendSystemAlert("Alert System finalizado", ALERT_PRIORITY_LOW);
      
      // Processar última vez
      ProcessAlertQueue();
   }
   
   g_logger.Info("Alert System deinicializado");
}

//+------------------------------------------------------------------+
//| Auto-teste                                                        |
//+------------------------------------------------------------------+
bool CAlertSystem::SelfTest(void)
{
   g_logger.Debug("Executando auto-teste do Alert System...");
   
   // Teste 1: Verificar configuração
   if(!m_config.global_enabled)
   {
      g_logger.Warning("Alert System está desabilitado");
   }
   
   // Teste 2: Testar envio de alerta
   int test_id = SendAlert(ALERT_TYPE_SYSTEM, ALERT_PRIORITY_LOW, 
                          "Teste", "Auto-teste do sistema de alertas");
   if(test_id <= 0)
   {
      g_logger.Error("Falha no teste de envio de alerta");
      return false;
   }
   
   // Teste 3: Processar fila
   ProcessAlertQueue();
   
   // Teste 4: Verificar canais
   bool has_active_channel = false;
   for(int i = 0; i < 7; i++)
   {
      if(m_channels[i].is_enabled)
      {
         has_active_channel = true;
         break;
      }
   }
   
   if(!has_active_channel)
   {
      g_logger.Warning("Nenhum canal de alerta ativo");
   }
   
   g_logger.Debug("Auto-teste do Alert System concluído");
   return true;
}

//+------------------------------------------------------------------+
//| Configurar via string                                            |
//+------------------------------------------------------------------+
void CAlertSystem::SetConfig(const string config_string)
{
   string params[];
   int count = StringSplit(config_string, ';', params);
   
   for(int i = 0; i < count; i++)
   {
      string pair[];
      if(StringSplit(params[i], '=', pair) == 2)
      {
         string key = pair[0];
         string value = pair[1];
         
         if(key == "global_enabled")
            m_config.global_enabled = (value == "true");
         else if(key == "enable_sound")
            m_config.enable_sound = (value == "true");
         else if(key == "enable_popup")
            m_config.enable_popup = (value == "true");
         else if(key == "enable_email")
            m_config.enable_email = (value == "true");
         else if(key == "max_alerts_per_minute")
            m_config.max_alerts_per_minute = (int)StringToInteger(value);
         else if(key == "email_to")
            m_config.email_to = value;
         // Adicionar mais parâmetros conforme necessário
      }
   }
   
   g_logger.Info("Configuração do Alert System atualizada");
}

//+------------------------------------------------------------------+
//| Obter configuração atual                                          |
//+------------------------------------------------------------------+
string CAlertSystem::GetConfig(void)
{
   string config = "";
   config += "global_enabled=" + (m_config.global_enabled ? "true" : "false") + ";";
   config += "enable_sound=" + (m_config.enable_sound ? "true" : "false") + ";";
   config += "enable_popup=" + (m_config.enable_popup ? "true" : "false") + ";";
   config += "enable_email=" + (m_config.enable_email ? "true" : "false") + ";";
   config += "max_alerts_per_minute=" + IntegerToString(m_config.max_alerts_per_minute) + ";";
   
   return config;
}

//+------------------------------------------------------------------+
//| Obter status atual                                                |
//+------------------------------------------------------------------+
string CAlertSystem::GetStatus(void)
{
   string status = "Alert System Status:\n";
   status += "Initialized: " + (m_is_initialized ? "YES" : "NO") + "\n";
   status += "Global Enabled: " + (m_config.global_enabled ? "YES" : "NO") + "\n";
   status += "Queue Size: " + IntegerToString(m_queue_size) + "\n";
   status += "History Size: " + IntegerToString(m_history_size) + "\n";
   status += "Total Alerts: " + IntegerToString(m_statistics.total_alerts) + "\n";
   status += "Successful Sends: " + IntegerToString(m_statistics.successful_sends) + "\n";
   status += "Failed Sends: " + IntegerToString(m_statistics.failed_sends) + "\n";
   
   // Status dos canais
   status += "\nChannels:\n";
   for(int i = 0; i < 7; i++)
   {
      if(m_channels[i].is_enabled)
      {
         status += "- " + EnumToString((ENUM_ALERT_CHANNEL)i) + ": Enabled\n";
      }
   }
   
   return status;
}

//+------------------------------------------------------------------+
//| Enviar alerta principal                                          |
//+------------------------------------------------------------------+
int CAlertSystem::SendAlert(const ENUM_ALERT_TYPE type, const ENUM_ALERT_PRIORITY priority,
                           const string title, const string message, 
                           const string symbol = "", const double price = 0.0)
{
   if(!m_config.global_enabled || !m_is_initialized)
   {
      return -1;
   }
   
   // Verificar prioridade mínima
   if(priority < m_config.min_priority)
   {
      return -1;
   }
   
   // Criar alerta
   SAlertMessage alert;
   alert.id = GetNextAlertId();
   alert.timestamp = TimeCurrent();
   alert.type = type;
   alert.priority = priority;
   alert.title = title;
   alert.message = message;
   alert.symbol = (symbol == "") ? m_symbol : symbol;
   alert.price = price;
   alert.additional_data = "";
   alert.status = ALERT_STATUS_PENDING;
   alert.expiry_time = TimeCurrent() + m_config.acknowledgment_timeout;
   alert.retry_count = 0;
   alert.is_persistent = (priority >= ALERT_PRIORITY_HIGH);
   
   // Validar alerta
   if(!ValidateAlert(alert))
   {
      LogAlertEvent("Alerta inválido rejeitado: " + title, LOG_WARNING);
      return -1;
   }
   
   // Adicionar à fila
   AddToQueue(alert);
   
   // Processar imediatamente se for crítico
   if(priority >= ALERT_PRIORITY_CRITICAL)
   {
      ProcessAlertQueue();
   }
   
   LogAlertEvent("Alerta criado: " + title + " (ID: " + IntegerToString(alert.id) + ")", LOG_DEBUG);
   return alert.id;
}

//+------------------------------------------------------------------+
//| Processar fila de alertas                                        |
//+------------------------------------------------------------------+
void CAlertSystem::ProcessAlertQueue(void)
{
   if(!m_is_initialized || m_queue_size == 0)
   {
      return;
   }
   
   // Atualizar limites de taxa
   UpdateRateLimits();
   
   // Processar alertas na fila
   for(int i = 0; i < m_queue_size; i++)
   {
      if(m_alert_queue[i].status != ALERT_STATUS_PENDING)
      {
         continue;
      }
      
      bool sent_to_any_channel = false;
      
      // Tentar enviar para todos os canais apropriados
      for(int c = 0; c < 7; c++)
      {
         ENUM_ALERT_CHANNEL channel = (ENUM_ALERT_CHANNEL)c;
         
         if(!m_channels[c].is_enabled)
            continue;
            
         if(m_alert_queue[i].priority < m_channels[c].min_priority)
            continue;
            
         if(!CheckRateLimit(channel))
            continue;
         
         if(SendAlertToChannel(m_alert_queue[i], channel))
         {
            sent_to_any_channel = true;
            UpdateStatistics(m_alert_queue[i], true);
         }
         else
         {
            UpdateStatistics(m_alert_queue[i], false);
         }
      }
      
      // Atualizar status do alerta
      if(sent_to_any_channel)
      {
         m_alert_queue[i].status = ALERT_STATUS_SENT;
         AddToHistory(m_alert_queue[i]);
      }
      else
      {
         m_alert_queue[i].retry_count++;
         if(m_alert_queue[i].retry_count >= 3)
         {
            m_alert_queue[i].status = ALERT_STATUS_FAILED;
            AddToHistory(m_alert_queue[i]);
         }
      }
   }
   
   // Limpar alertas processados
   OptimizeAlertQueue();
   
   // Limpeza periódica
   if(TimeCurrent() - m_last_cleanup > 3600) // 1 hora
   {
      CleanupExpiredAlerts();
      m_last_cleanup = TimeCurrent();
   }
}

//+------------------------------------------------------------------+
//| Enviar alerta para canal específico                              |
//+------------------------------------------------------------------+
bool CAlertSystem::SendAlertToChannel(const SAlertMessage &alert, const ENUM_ALERT_CHANNEL channel)
{
   switch(channel)
   {
      case ALERT_CHANNEL_POPUP:
         return SendPopupAlert(alert);
         
      case ALERT_CHANNEL_SOUND:
         return SendSoundAlert(alert);
         
      case ALERT_CHANNEL_EMAIL:
         return SendEmailAlert(alert);
         
      case ALERT_CHANNEL_PUSH:
         return SendPushAlert(alert);
         
      case ALERT_CHANNEL_LOG:
         LogAlertEvent(FormatAlertMessage(alert), LOG_INFO);
         return true;
         
      default:
         return false;
   }
}

//+------------------------------------------------------------------+
//| Implementações dos canais específicos                            |
//+------------------------------------------------------------------+
bool CAlertSystem::SendPopupAlert(const SAlertMessage &alert)
{
   string popup_message = alert.title + "\n" + alert.message;
   if(alert.symbol != "")
   {
      popup_message += "\nSymbol: " + alert.symbol;
   }
   if(alert.price > 0)
   {
      popup_message += "\nPrice: " + DoubleToString(alert.price, 5);
   }
   
   Alert(popup_message);
   return true;
}

bool CAlertSystem::SendSoundAlert(const SAlertMessage &alert)
{
   ENUM_SOUND_TYPE sound_type = GetSoundForAlert(alert.type, alert.priority);
   
   switch(sound_type)
   {
      case SOUND_TYPE_ALERT:
         PlaySound("alert.wav");
         break;
      case SOUND_TYPE_SUCCESS:
         PlaySound("ok.wav");
         break;
      case SOUND_TYPE_ERROR:
         PlaySound("timeout.wav");
         break;
      case SOUND_TYPE_WARNING:
         PlaySound("news.wav");
         break;
      case SOUND_TYPE_CUSTOM:
         if(m_config.custom_sound_file != "")
            PlaySound(m_config.custom_sound_file);
         else
            PlaySound("alert.wav");
         break;
      default:
         return true; // Sem som
   }
   
   return true;
}

bool CAlertSystem::SendEmailAlert(const SAlertMessage &alert)
{
   if(m_config.email_to == "")
   {
      return false;
   }
   
   string subject = "[" + GetPriorityString(alert.priority) + "] " + alert.title;
   string body = EncodeEmailMessage(alert);
   
   return SendMail(subject, body);
}

bool CAlertSystem::SendPushAlert(const SAlertMessage &alert)
{
   string push_message = alert.title + ": " + alert.message;
   if(alert.symbol != "")
   {
      push_message += " (" + alert.symbol + ")";
   }
   
   return SendNotification(push_message);
}

//+------------------------------------------------------------------+
//| Métodos auxiliares simplificados                                 |
//+------------------------------------------------------------------+
void CAlertSystem::InitializeChannels(void)
{
   for(int i = 0; i < 7; i++)
   {
      m_channels[i].channel = (ENUM_ALERT_CHANNEL)i;
      m_channels[i].is_enabled = false;
      m_channels[i].min_priority = ALERT_PRIORITY_LOW;
      m_channels[i].configuration = "";
      m_channels[i].last_sent = 0;
      m_channels[i].send_count = 0;
      m_channels[i].rate_limit_enabled = true;
      m_channels[i].max_per_minute = 5;
      m_channels[i].current_minute_count = 0;
      m_channels[i].current_minute = 0;
   }
}

void CAlertSystem::InitializeStatistics(void)
{
   ZeroMemory(m_statistics);
   m_statistics.first_alert = 0;
   m_statistics.last_alert = 0;
}

void CAlertSystem::AddToQueue(const SAlertMessage &alert)
{
   if(m_queue_size >= ArraySize(m_alert_queue))
   {
      OptimizeAlertQueue();
   }
   
   if(m_queue_size < ArraySize(m_alert_queue))
   {
      m_alert_queue[m_queue_size] = alert;
      m_queue_size++;
   }
}

void CAlertSystem::AddToHistory(const SAlertMessage &alert)
{
   if(m_history_size >= ArraySize(m_alert_history))
   {
      // Remover alertas mais antigos
      for(int i = 0; i < m_history_size - 1; i++)
      {
         m_alert_history[i] = m_alert_history[i + 1];
      }
      m_history_size--;
   }
   
   if(m_history_size < ArraySize(m_alert_history))
   {
      m_alert_history[m_history_size] = alert;
      m_history_size++;
   }
}

bool CAlertSystem::ValidateAlert(const SAlertMessage &alert)
{
   if(alert.title == "" || alert.message == "")
      return false;
      
   if(alert.priority < ALERT_PRIORITY_LOW || alert.priority > ALERT_PRIORITY_EMERGENCY)
      return false;
      
   return true;
}

bool CAlertSystem::CheckRateLimit(const ENUM_ALERT_CHANNEL channel)
{
   int ch_index = (int)channel;
   if(ch_index < 0 || ch_index >= 7)
      return false;
      
   if(!m_channels[ch_index].rate_limit_enabled)
      return true;
      
   datetime current_minute = (TimeCurrent() / 60) * 60;
   
   if(m_channels[ch_index].current_minute != current_minute)
   {
      m_channels[ch_index].current_minute = current_minute;
      m_channels[ch_index].current_minute_count = 0;
   }
   
   return (m_channels[ch_index].current_minute_count < m_channels[ch_index].max_per_minute);
}

void CAlertSystem::UpdateRateLimits(void)
{
   datetime current_minute = (TimeCurrent() / 60) * 60;
   
   for(int i = 0; i < 7; i++)
   {
      if(m_channels[i].current_minute != current_minute)
      {
         m_channels[i].current_minute = current_minute;
         m_channels[i].current_minute_count = 0;
      }
   }
}

void CAlertSystem::UpdateStatistics(const SAlertMessage &alert, const bool success)
{
   m_statistics.total_alerts++;
   m_statistics.alerts_by_type[alert.type]++;
   m_statistics.alerts_by_priority[alert.priority]++;
   
   if(success)
      m_statistics.successful_sends++;
   else
      m_statistics.failed_sends++;
      
   if(m_statistics.first_alert == 0)
      m_statistics.first_alert = alert.timestamp;
      
   m_statistics.last_alert = alert.timestamp;
}

void CAlertSystem::OptimizeAlertQueue(void)
{
   int new_size = 0;
   
   for(int i = 0; i < m_queue_size; i++)
   {
      if(m_alert_queue[i].status == ALERT_STATUS_PENDING)
      {
         if(new_size != i)
         {
            m_alert_queue[new_size] = m_alert_queue[i];
         }
         new_size++;
      }
   }
   
   m_queue_size = new_size;
}

void CAlertSystem::LogAlertEvent(const string message, const ENUM_LOG_LEVEL level)
{
   switch(level)
   {
      case LOG_DEBUG:
         g_logger.Debug("[ALERT] " + message);
         break;
      case LOG_INFO:
         g_logger.Info("[ALERT] " + message);
         break;
      case LOG_WARNING:
         g_logger.Warning("[ALERT] " + message);
         break;
      case LOG_ERROR:
         g_logger.Error("[ALERT] " + message);
         break;
   }
}

string CAlertSystem::FormatAlertMessage(const SAlertMessage &alert)
{
   string formatted = "[" + GetPriorityString(alert.priority) + "] " + alert.title + ": " + alert.message;
   if(alert.symbol != "")
      formatted += " (" + alert.symbol + ")";
   return formatted;
}

string CAlertSystem::GetAlertTypeString(const ENUM_ALERT_TYPE type)
{
   switch(type)
   {
      case ALERT_TYPE_TRADE: return "TRADE";
      case ALERT_TYPE_RISK: return "RISK";
      case ALERT_TYPE_SIGNAL: return "SIGNAL";
      case ALERT_TYPE_SYSTEM: return "SYSTEM";
      case ALERT_TYPE_FTMO: return "FTMO";
      case ALERT_TYPE_PERFORMANCE: return "PERFORMANCE";
      case ALERT_TYPE_ERROR: return "ERROR";
      case ALERT_TYPE_WARNING: return "WARNING";
      case ALERT_TYPE_INFO: return "INFO";
      default: return "UNKNOWN";
   }
}

string CAlertSystem::GetPriorityString(const ENUM_ALERT_PRIORITY priority)
{
   switch(priority)
   {
      case ALERT_PRIORITY_LOW: return "LOW";
      case ALERT_PRIORITY_NORMAL: return "NORMAL";
      case ALERT_PRIORITY_HIGH: return "HIGH";
      case ALERT_PRIORITY_CRITICAL: return "CRITICAL";
      case ALERT_PRIORITY_EMERGENCY: return "EMERGENCY";
      default: return "UNKNOWN";
   }
}

ENUM_SOUND_TYPE CAlertSystem::GetSoundForAlert(const ENUM_ALERT_TYPE type, const ENUM_ALERT_PRIORITY priority)
{
   if(priority >= ALERT_PRIORITY_CRITICAL)
      return SOUND_TYPE_ERROR;
   else if(priority >= ALERT_PRIORITY_HIGH)
      return SOUND_TYPE_WARNING;
   else if(type == ALERT_TYPE_TRADE)
      return SOUND_TYPE_SUCCESS;
   else
      return SOUND_TYPE_ALERT;
}

string CAlertSystem::EncodeEmailMessage(const SAlertMessage &alert)
{
   string body = "Alert Details:\n\n";
   body += "Type: " + GetAlertTypeString(alert.type) + "\n";
   body += "Priority: " + GetPriorityString(alert.priority) + "\n";
   body += "Time: " + TimeToString(alert.timestamp) + "\n";
   body += "Symbol: " + alert.symbol + "\n";
   if(alert.price > 0)
      body += "Price: " + DoubleToString(alert.price, 5) + "\n";
   body += "\nMessage: " + alert.message + "\n";
   
   return body;
}

// Implementações simplificadas dos métodos restantes
bool CAlertSystem::ConfigureChannel(const ENUM_ALERT_CHANNEL channel, const bool enabled, const ENUM_ALERT_PRIORITY min_priority) { return true; }
bool CAlertSystem::SetChannelRateLimit(const ENUM_ALERT_CHANNEL channel, const int max_per_minute) { return true; }
SAlertChannel CAlertSystem::GetChannelInfo(const ENUM_ALERT_CHANNEL channel) { SAlertChannel ch; ZeroMemory(ch); return ch; }
int CAlertSystem::SendTradeAlert(const string message, const string symbol, const double price) { return SendAlert(ALERT_TYPE_TRADE, ALERT_PRIORITY_NORMAL, "Trade Alert", message, symbol, price); }
int CAlertSystem::SendRiskAlert(const string message, const ENUM_ALERT_PRIORITY priority) { return SendAlert(ALERT_TYPE_RISK, priority, "Risk Alert", message); }
int CAlertSystem::SendFTMOAlert(const string message, const ENUM_ALERT_PRIORITY priority) { return SendAlert(ALERT_TYPE_FTMO, priority, "FTMO Alert", message); }
int CAlertSystem::SendSystemAlert(const string message, const ENUM_ALERT_PRIORITY priority) { return SendAlert(ALERT_TYPE_SYSTEM, priority, "System Alert", message); }
int CAlertSystem::SendSignalAlert(const string signal_name, const string symbol, const double price) { return SendAlert(ALERT_TYPE_SIGNAL, ALERT_PRIORITY_NORMAL, "Signal: " + signal_name, "Signal detected", symbol, price); }
void CAlertSystem::AlertTradeOpened(const string symbol, const int ticket, const double volume, const double price) { SendTradeAlert("Trade opened #" + IntegerToString(ticket), symbol, price); }
void CAlertSystem::AlertTradeClosed(const string symbol, const int ticket, const double profit) { SendTradeAlert("Trade closed #" + IntegerToString(ticket) + " P/L: " + DoubleToString(profit, 2), symbol, 0); }
void CAlertSystem::AlertStopLossHit(const string symbol, const int ticket, const double price) { SendTradeAlert("Stop Loss hit #" + IntegerToString(ticket), symbol, price); }
void CAlertSystem::AlertTakeProfitHit(const string symbol, const int ticket, const double price) { SendTradeAlert("Take Profit hit #" + IntegerToString(ticket), symbol, price); }
void CAlertSystem::AlertDrawdownWarning(const double current_dd, const double max_dd) { SendRiskAlert("Drawdown warning: " + DoubleToString(current_dd, 2) + "% / " + DoubleToString(max_dd, 2) + "%", ALERT_PRIORITY_HIGH); }
void CAlertSystem::AlertDailyLimitReached(const double current_loss, const double limit) { SendFTMOAlert("Daily limit reached: " + DoubleToString(current_loss, 2) + " / " + DoubleToString(limit, 2), ALERT_PRIORITY_CRITICAL); }
void CAlertSystem::AlertMarginCall(const double margin_level) { SendRiskAlert("Margin call warning: " + DoubleToString(margin_level, 2) + "%", ALERT_PRIORITY_EMERGENCY); }
void CAlertSystem::AlertConnectionLost(void) { SendSystemAlert("Connection lost", ALERT_PRIORITY_HIGH); }
void CAlertSystem::AlertHighSpread(const string symbol, const double spread) { SendSystemAlert("High spread on " + symbol + ": " + DoubleToString(spread, 1) + " pips", ALERT_PRIORITY_NORMAL); }
void CAlertSystem::AlertNewsEvent(const string event_name, const datetime event_time) { SendSystemAlert("News event: " + event_name + " at " + TimeToString(event_time), ALERT_PRIORITY_NORMAL); }
string CAlertSystem::GenerateAlertReport(void) { return "Alert Report"; }
string CAlertSystem::GenerateChannelReport(void) { return "Channel Report"; }
string CAlertSystem::GenerateStatisticsReport(void) { return "Statistics Report"; }
void CAlertSystem::CleanupExpiredAlerts(void) { }

//+------------------------------------------------------------------+
//| Implementações dos métodos da interface IManager                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Inicializar o sistema de alertas                                 |
//+------------------------------------------------------------------+
bool CAlertSystem::Initialize()
{
   if(!Init())
      return false;
      
   // Configurar configuração padrão
   ZeroMemory(m_config);
   m_config.global_enabled = true;
   m_config.min_priority = ALERT_PRIORITY_LOW;
   m_config.enable_sound = true;
   m_config.enable_popup = true;
   m_config.enable_email = false;
   m_config.enable_push = false;
   m_config.max_alerts_per_minute = 10;
   m_config.alert_history_days = 7;
   m_config.auto_acknowledge = true;
   m_config.acknowledgment_timeout = 300; // 5 minutos
   m_config.log_all_alerts = true;
   
   // Inicializar canais
   InitializeChannels();
   
   // Configurar canais padrão
   ConfigureChannel(ALERT_CHANNEL_POPUP, true, ALERT_PRIORITY_NORMAL);
   ConfigureChannel(ALERT_CHANNEL_SOUND, true, ALERT_PRIORITY_HIGH);
   ConfigureChannel(ALERT_CHANNEL_LOG, true, ALERT_PRIORITY_LOW);
   
   // Inicializar estatísticas
   InitializeStatistics();
   
   // Configurar variáveis de controle
   m_next_alert_id = 1;
   m_queue_size = 0;
   m_history_size = 0;
   m_rules_count = 0;
   m_last_cleanup = TimeCurrent();
   m_last_rate_check = TimeCurrent();
   m_current_minute_alerts = 0;
   m_is_initialized = true;
   
   // Redimensionar arrays
   ArrayResize(m_alert_queue, 100);
   ArrayResize(m_alert_history, 1000);
   ArrayResize(m_alert_rules, 50);
   
   LogAlertEvent("Alert System inicializado com sucesso", LOG_INFO);
   
   return true;
}

//+------------------------------------------------------------------+
//| Finalizar o sistema de alertas                                   |
//+------------------------------------------------------------------+
void CAlertSystem::Shutdown()
{
   // Processar alertas pendentes na fila
   ProcessAlertQueue();
   
   // Gerar relatório final
   string final_report = GenerateStatisticsReport();
   LogAlertEvent("Relatório final: " + final_report, LOG_INFO);
   
   // Limpar arrays
   ArrayResize(m_alert_queue, 0);
   ArrayResize(m_alert_history, 0);
   ArrayResize(m_alert_rules, 0);
   
   // Reset de variáveis
   m_is_initialized = false;
   m_queue_size = 0;
   m_history_size = 0;
   m_rules_count = 0;
   
   LogAlertEvent("Alert System finalizado", LOG_INFO);
   
   Deinit();
}

//+------------------------------------------------------------------+
//| Processar eventos do sistema de alertas                          |
//+------------------------------------------------------------------+
void CAlertSystem::ProcessEvents()
{
   if(!m_is_initialized || !m_config.global_enabled)
      return;
      
   datetime current_time = TimeCurrent();
   
   // Processar fila de alertas
   ProcessAlertQueue();
   
   // Processar regras de alerta
   ProcessAlertRules();
   
   // Atualizar limites de taxa
   UpdateRateLimits();
   
   // Auto reconhecimento de alertas expirados
   if(m_config.auto_acknowledge)
      AutoAcknowledgeExpiredAlerts();
   
   // Limpeza periódica (a cada 5 minutos)
   if(current_time - m_last_cleanup > 300)
   {
      CleanupExpiredAlerts();
      OptimizeAlertQueue();
      m_last_cleanup = current_time;
   }
   
   // Limpeza de histórico antigo (diariamente)
   static datetime last_history_cleanup = 0;
   if(current_time - last_history_cleanup > 86400) // 24 horas
   {
      datetime cutoff_time = current_time - (m_config.alert_history_days * 86400);
      ClearHistory(cutoff_time);
      last_history_cleanup = current_time;
   }
}

//+------------------------------------------------------------------+
//| Verificar se está ativo                                          |
//+------------------------------------------------------------------+
bool CAlertSystem::IsActive()
{
   return m_is_initialized && m_config.global_enabled;
}

//+------------------------------------------------------------------+
//| Parar o sistema de alertas                                       |
//+------------------------------------------------------------------+
void CAlertSystem::Stop()
{
   m_config.global_enabled = false;
   LogAlertEvent("Alert System parado manualmente", LOG_WARNING);
}

//+------------------------------------------------------------------+
//| Reiniciar o sistema de alertas                                   |
//+------------------------------------------------------------------+
void CAlertSystem::Restart()
{
   Stop();
   
   // Aguardar um momento
   Sleep(1000);
   
   // Reinicializar
   if(Initialize())
   {
      LogAlertEvent("Alert System reiniciado com sucesso", LOG_INFO);
   }
   else
   {
      LogAlertEvent("Falha ao reiniciar Alert System", LOG_ERROR);
   }
}

//+------------------------------------------------------------------+
//| Obter informações de debug                                       |
//+------------------------------------------------------------------+
string CAlertSystem::GetDebugInfo()
{
   string info = "=== Alert System Debug ===\n";
   info += "Initialized: " + (m_is_initialized ? "Yes" : "No") + "\n";
   info += "Global Enabled: " + (m_config.global_enabled ? "Yes" : "No") + "\n";
   info += "Queue Size: " + IntegerToString(m_queue_size) + "\n";
   info += "History Size: " + IntegerToString(m_history_size) + "\n";
   info += "Rules Count: " + IntegerToString(m_rules_count) + "\n";
   info += "Next Alert ID: " + IntegerToString(m_next_alert_id) + "\n";
   info += "Total Alerts: " + IntegerToString(m_statistics.total_alerts) + "\n";
   info += "Successful Sends: " + IntegerToString(m_statistics.successful_sends) + "\n";
   info += "Failed Sends: " + IntegerToString(m_statistics.failed_sends) + "\n";
   info += "Rate Limit Hits: " + IntegerToString(m_statistics.rate_limit_hits) + "\n";
   info += "Min Priority: " + GetPriorityString(m_config.min_priority) + "\n";
   info += "Max Per Minute: " + IntegerToString(m_config.max_alerts_per_minute) + "\n";
   info += "Current Minute Alerts: " + IntegerToString(m_current_minute_alerts) + "\n";
   info += "Sound Enabled: " + (m_config.enable_sound ? "Yes" : "No") + "\n";
   info += "Popup Enabled: " + (m_config.enable_popup ? "Yes" : "No") + "\n";
   info += "Email Enabled: " + (m_config.enable_email ? "Yes" : "No") + "\n";
   info += "Push Enabled: " + (m_config.enable_push ? "Yes" : "No") + "\n";
   info += "Last Cleanup: " + TimeToString(m_last_cleanup) + "\n";
   
   return info;
}

//+------------------------------------------------------------------+
//| Validar configuração                                             |
//+------------------------------------------------------------------+
bool CAlertSystem::ValidateConfiguration()
{
   if(m_config.max_alerts_per_minute <= 0 || m_config.max_alerts_per_minute > 100)
   {
      Print("Erro: Limite de alertas por minuto inválido: ", m_config.max_alerts_per_minute);
      return false;
   }
   
   if(m_config.alert_history_days <= 0 || m_config.alert_history_days > 365)
   {
      Print("Erro: Dias de histórico inválido: ", m_config.alert_history_days);
      return false;
   }
   
   if(m_config.acknowledgment_timeout <= 0 || m_config.acknowledgment_timeout > 3600)
   {
      Print("Erro: Timeout de reconhecimento inválido: ", m_config.acknowledgment_timeout);
      return false;
   }
   
   if(m_config.enable_email)
   {
      if(StringLen(m_config.email_smtp_server) == 0)
      {
         Print("Erro: Servidor SMTP não configurado");
         return false;
      }
      
      if(StringLen(m_config.email_to) == 0)
      {
         Print("Erro: Email destinatário não configurado");
         return false;
      }
   }
   
   if(m_config.enable_push && StringLen(m_config.push_id) == 0)
   {
      Print("Erro: Push ID não configurado");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+