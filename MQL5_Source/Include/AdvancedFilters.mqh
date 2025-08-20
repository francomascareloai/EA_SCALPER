//+------------------------------------------------------------------+
//|                                              AdvancedFilters.mqh |
//|                                    TradeDev_Master - Elite System |
//|                                 https://github.com/tradedev-master |
//+------------------------------------------------------------------+
#property copyright "TradeDev_Master - Elite System"
#property link      "https://github.com/tradedev-master"
#property version   "1.00"
#property strict

#include "RiskManager.mqh"

//+------------------------------------------------------------------+
//| Enumerações para configuração de filtros                         |
//+------------------------------------------------------------------+
enum ENUM_NEWS_IMPACT
{
   NEWS_LOW = 1,      // Baixo impacto
   NEWS_MEDIUM = 2,   // Médio impacto
   NEWS_HIGH = 3      // Alto impacto
};

enum ENUM_TRADING_SESSION
{
   SESSION_LONDON = 1,    // Sessão de Londres
   SESSION_NEW_YORK = 2,  // Sessão de Nova York
   SESSION_ASIAN = 3,     // Sessão Asiática
   SESSION_OVERLAP = 4    // Sobreposição Londres-NY
};

//+------------------------------------------------------------------+
//| Estrutura para eventos de notícias                               |
//+------------------------------------------------------------------+
struct NewsEvent
{
   datetime time;           // Horário do evento
   string currency;         // Moeda afetada
   ENUM_NEWS_IMPACT impact; // Nível de impacto
   string description;      // Descrição do evento
   int minutesBefore;       // Minutos antes para pausar
   int minutesAfter;        // Minutos depois para pausar
};

//+------------------------------------------------------------------+
//| Classe principal para filtros avançados                          |
//+------------------------------------------------------------------+
class CAdvancedFilters
{
private:
   // Configurações de filtro de notícias
   bool m_newsFilterEnabled;
   int m_minutesBeforeNews;
   int m_minutesAfterNews;
   ENUM_NEWS_IMPACT m_minNewsImpact;
   NewsEvent m_newsEvents[];
   
   // Configurações de filtro de sessão
   bool m_sessionFilterEnabled;
   ENUM_TRADING_SESSION m_allowedSessions[];
   
   // Configurações de filtro de volatilidade ATR
   bool m_atrFilterEnabled;
   int m_atrPeriod;
   double m_minATRMultiplier;
   double m_maxATRMultiplier;
   int m_atrHandle;
   
   // Configurações de filtro de spread
   bool m_spreadFilterEnabled;
   double m_maxSpreadPoints;
   
   // Configurações de filtro de horário
   bool m_timeFilterEnabled;
   string m_startTime;
   string m_endTime;
   
   // Métodos auxiliares
   bool IsNewsTime();
   bool IsValidSession();
   bool IsValidATR();
   bool IsValidSpread();
   bool IsValidTime();
   datetime StringToTime(string timeStr);
   
public:
   // Construtor e destrutor
   CAdvancedFilters();
   ~CAdvancedFilters();
   
   // Métodos de inicialização
   bool Initialize();
   void Deinitialize();
   
   // Configuração de filtros
   void SetNewsFilter(bool enabled, int minutesBefore = 15, int minutesAfter = 15, ENUM_NEWS_IMPACT minImpact = NEWS_HIGH);
   void SetSessionFilter(bool enabled, ENUM_TRADING_SESSION sessions[]);
   void SetATRFilter(bool enabled, int period = 14, double minMultiplier = 0.5, double maxMultiplier = 3.0);
   void SetSpreadFilter(bool enabled, double maxSpreadPoints = 30.0);
   void SetTimeFilter(bool enabled, string startTime = "08:00", string endTime = "17:00");
   
   // Adição de eventos de notícias
   void AddNewsEvent(datetime time, string currency, ENUM_NEWS_IMPACT impact, string description = "");
   void LoadNewsFromFile(string filename = "news_events.txt");
   
   // Método principal de validação
   bool IsTradingAllowed();
   
   // Métodos de status
   string GetFilterStatus();
   void PrintFilterReport();
   
   // Getters
   bool IsNewsFilterActive() { return m_newsFilterEnabled && IsNewsTime(); }
   bool IsSessionFilterActive() { return m_sessionFilterEnabled && !IsValidSession(); }
   bool IsATRFilterActive() { return m_atrFilterEnabled && !IsValidATR(); }
   bool IsSpreadFilterActive() { return m_spreadFilterEnabled && !IsValidSpread(); }
   bool IsTimeFilterActive() { return m_timeFilterEnabled && !IsValidTime(); }
};

//+------------------------------------------------------------------+
//| Construtor                                                        |
//+------------------------------------------------------------------+
CAdvancedFilters::CAdvancedFilters()
{
   // Inicialização padrão
   m_newsFilterEnabled = false;
   m_minutesBeforeNews = 15;
   m_minutesAfterNews = 15;
   m_minNewsImpact = NEWS_HIGH;
   
   m_sessionFilterEnabled = false;
   
   m_atrFilterEnabled = false;
   m_atrPeriod = 14;
   m_minATRMultiplier = 0.5;
   m_maxATRMultiplier = 3.0;
   m_atrHandle = INVALID_HANDLE;
   
   m_spreadFilterEnabled = false;
   m_maxSpreadPoints = 30.0;
   
   m_timeFilterEnabled = false;
   m_startTime = "08:00";
   m_endTime = "17:00";
   
   ArrayResize(m_newsEvents, 0);
   ArrayResize(m_allowedSessions, 0);
}

//+------------------------------------------------------------------+
//| Destrutor                                                         |
//+------------------------------------------------------------------+
CAdvancedFilters::~CAdvancedFilters()
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| Inicialização                                                     |
//+------------------------------------------------------------------+
bool CAdvancedFilters::Initialize()
{
   // Inicializar handle do ATR se necessário
   if(m_atrFilterEnabled)
   {
      m_atrHandle = iATR(_Symbol, PERIOD_CURRENT, m_atrPeriod);
      if(m_atrHandle == INVALID_HANDLE)
      {
         Print("[AdvancedFilters] ERRO: Falha ao criar handle do ATR");
         return false;
      }
   }
   
   // Carregar eventos de notícias padrão para XAUUSD
   if(m_newsFilterEnabled && ArraySize(m_newsEvents) == 0)
   {
      LoadDefaultNewsEvents();
   }
   
   Print("[AdvancedFilters] Sistema de filtros inicializado com sucesso");
   return true;
}

//+------------------------------------------------------------------+
//| Desinicialização                                                  |
//+------------------------------------------------------------------+
void CAdvancedFilters::Deinitialize()
{
   if(m_atrHandle != INVALID_HANDLE)
   {
      IndicatorRelease(m_atrHandle);
      m_atrHandle = INVALID_HANDLE;
   }
}

//+------------------------------------------------------------------+
//| Configurar filtro de notícias                                    |
//+------------------------------------------------------------------+
void CAdvancedFilters::SetNewsFilter(bool enabled, int minutesBefore = 15, int minutesAfter = 15, ENUM_NEWS_IMPACT minImpact = NEWS_HIGH)
{
   m_newsFilterEnabled = enabled;
   m_minutesBeforeNews = minutesBefore;
   m_minutesAfterNews = minutesAfter;
   m_minNewsImpact = minImpact;
   
   Print(StringFormat("[AdvancedFilters] Filtro de notícias: %s | Antes: %d min | Depois: %d min | Impacto mín: %d",
                     enabled ? "ATIVADO" : "DESATIVADO", minutesBefore, minutesAfter, minImpact));
}

//+------------------------------------------------------------------+
//| Configurar filtro de sessão                                      |
//+------------------------------------------------------------------+
void CAdvancedFilters::SetSessionFilter(bool enabled, ENUM_TRADING_SESSION sessions[])
{
   m_sessionFilterEnabled = enabled;
   
   if(enabled)
   {
      int size = ArraySize(sessions);
      ArrayResize(m_allowedSessions, size);
      ArrayCopy(m_allowedSessions, sessions);
      
      string sessionNames = "";
      for(int i = 0; i < size; i++)
      {
         switch(sessions[i])
         {
            case SESSION_LONDON: sessionNames += "Londres "; break;
            case SESSION_NEW_YORK: sessionNames += "Nova York "; break;
            case SESSION_ASIAN: sessionNames += "Asiática "; break;
            case SESSION_OVERLAP: sessionNames += "Sobreposição "; break;
         }
      }
      
      Print(StringFormat("[AdvancedFilters] Filtro de sessão ATIVADO: %s", sessionNames));
   }
   else
   {
      Print("[AdvancedFilters] Filtro de sessão DESATIVADO");
   }
}

//+------------------------------------------------------------------+
//| Configurar filtro ATR                                            |
//+------------------------------------------------------------------+
void CAdvancedFilters::SetATRFilter(bool enabled, int period = 14, double minMultiplier = 0.5, double maxMultiplier = 3.0)
{
   m_atrFilterEnabled = enabled;
   m_atrPeriod = period;
   m_minATRMultiplier = minMultiplier;
   m_maxATRMultiplier = maxMultiplier;
   
   if(enabled)
   {
      // Recriar handle se necessário
      if(m_atrHandle != INVALID_HANDLE)
      {
         IndicatorRelease(m_atrHandle);
      }
      
      m_atrHandle = iATR(_Symbol, PERIOD_CURRENT, period);
      
      Print(StringFormat("[AdvancedFilters] Filtro ATR ATIVADO: Período=%d | Min=%.2f | Max=%.2f",
                        period, minMultiplier, maxMultiplier));
   }
   else
   {
      Print("[AdvancedFilters] Filtro ATR DESATIVADO");
   }
}

//+------------------------------------------------------------------+
//| Configurar filtro de spread                                      |
//+------------------------------------------------------------------+
void CAdvancedFilters::SetSpreadFilter(bool enabled, double maxSpreadPoints = 30.0)
{
   m_spreadFilterEnabled = enabled;
   m_maxSpreadPoints = maxSpreadPoints;
   
   Print(StringFormat("[AdvancedFilters] Filtro de spread: %s | Máximo: %.1f pontos",
                     enabled ? "ATIVADO" : "DESATIVADO", maxSpreadPoints));
}

//+------------------------------------------------------------------+
//| Configurar filtro de horário                                     |
//+------------------------------------------------------------------+
void CAdvancedFilters::SetTimeFilter(bool enabled, string startTime = "08:00", string endTime = "17:00")
{
   m_timeFilterEnabled = enabled;
   m_startTime = startTime;
   m_endTime = endTime;
   
   Print(StringFormat("[AdvancedFilters] Filtro de horário: %s | %s às %s",
                     enabled ? "ATIVADO" : "DESATIVADO", startTime, endTime));
}

//+------------------------------------------------------------------+
//| Verificar se é horário de notícias                               |
//+------------------------------------------------------------------+
bool CAdvancedFilters::IsNewsTime()
{
   if(!m_newsFilterEnabled) return false;
   
   datetime currentTime = TimeCurrent();
   
   for(int i = 0; i < ArraySize(m_newsEvents); i++)
   {
      NewsEvent event = m_newsEvents[i];
      
      // Verificar se o impacto é suficiente
      if(event.impact < m_minNewsImpact) continue;
      
      // Calcular janela de pausa
      datetime startPause = event.time - (event.minutesBefore > 0 ? event.minutesBefore : m_minutesBeforeNews) * 60;
      datetime endPause = event.time + (event.minutesAfter > 0 ? event.minutesAfter : m_minutesAfterNews) * 60;
      
      if(currentTime >= startPause && currentTime <= endPause)
      {
         Print(StringFormat("[AdvancedFilters] FILTRO NOTÍCIAS ATIVO: %s às %s (Impacto: %d)",
                           event.description, TimeToString(event.time), event.impact));
         return true;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Verificar se é sessão válida                                     |
//+------------------------------------------------------------------+
bool CAdvancedFilters::IsValidSession()
{
   if(!m_sessionFilterEnabled) return true;
   
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   // Converter para GMT
   int currentHour = dt.hour;
   
   for(int i = 0; i < ArraySize(m_allowedSessions); i++)
   {
      ENUM_TRADING_SESSION session = m_allowedSessions[i];
      
      switch(session)
      {
         case SESSION_LONDON:
            if(currentHour >= 8 && currentHour < 17) return true;
            break;
            
         case SESSION_NEW_YORK:
            if(currentHour >= 13 && currentHour < 22) return true;
            break;
            
         case SESSION_ASIAN:
            if(currentHour >= 23 || currentHour < 8) return true;
            break;
            
         case SESSION_OVERLAP:
            if(currentHour >= 13 && currentHour < 17) return true;
            break;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Verificar se ATR está em faixa válida                            |
//+------------------------------------------------------------------+
bool CAdvancedFilters::IsValidATR()
{
   if(!m_atrFilterEnabled || m_atrHandle == INVALID_HANDLE) return true;
   
   double atrBuffer[1];
   if(CopyBuffer(m_atrHandle, 0, 1, 1, atrBuffer) != 1)
   {
      Print("[AdvancedFilters] ERRO: Não foi possível obter dados do ATR");
      return false;
   }
   
   double currentATR = atrBuffer[0];
   double avgATR = currentATR; // Simplificado - pode ser melhorado com média móvel
   
   double atrRatio = currentATR / avgATR;
   
   bool isValid = (atrRatio >= m_minATRMultiplier && atrRatio <= m_maxATRMultiplier);
   
   if(!isValid)
   {
      Print(StringFormat("[AdvancedFilters] FILTRO ATR ATIVO: Ratio=%.2f (Min=%.2f, Max=%.2f)",
                        atrRatio, m_minATRMultiplier, m_maxATRMultiplier));
   }
   
   return isValid;
}

//+------------------------------------------------------------------+
//| Verificar se spread está válido                                  |
//+------------------------------------------------------------------+
bool CAdvancedFilters::IsValidSpread()
{
   if(!m_spreadFilterEnabled) return true;
   
   double spread = (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID)) / _Point;
   
   bool isValid = (spread <= m_maxSpreadPoints);
   
   if(!isValid)
   {
      Print(StringFormat("[AdvancedFilters] FILTRO SPREAD ATIVO: %.1f pontos (Máx: %.1f)",
                        spread, m_maxSpreadPoints));
   }
   
   return isValid;
}

//+------------------------------------------------------------------+
//| Verificar se horário está válido                                 |
//+------------------------------------------------------------------+
bool CAdvancedFilters::IsValidTime()
{
   if(!m_timeFilterEnabled) return true;
   
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   string currentTime = StringFormat("%02d:%02d", dt.hour, dt.min);
   
   bool isValid = (currentTime >= m_startTime && currentTime <= m_endTime);
   
   if(!isValid)
   {
      Print(StringFormat("[AdvancedFilters] FILTRO HORÁRIO ATIVO: %s (Permitido: %s às %s)",
                        currentTime, m_startTime, m_endTime));
   }
   
   return isValid;
}

//+------------------------------------------------------------------+
//| Método principal - verificar se trading é permitido              |
//+------------------------------------------------------------------+
bool CAdvancedFilters::IsTradingAllowed()
{
   // Verificar cada filtro individualmente
   if(IsNewsTime()) return false;
   if(!IsValidSession()) return false;
   if(!IsValidATR()) return false;
   if(!IsValidSpread()) return false;
   if(!IsValidTime()) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Adicionar evento de notícias                                     |
//+------------------------------------------------------------------+
void CAdvancedFilters::AddNewsEvent(datetime time, string currency, ENUM_NEWS_IMPACT impact, string description = "")
{
   int size = ArraySize(m_newsEvents);
   ArrayResize(m_newsEvents, size + 1);
   
   m_newsEvents[size].time = time;
   m_newsEvents[size].currency = currency;
   m_newsEvents[size].impact = impact;
   m_newsEvents[size].description = description;
   m_newsEvents[size].minutesBefore = 0; // Usar padrão
   m_newsEvents[size].minutesAfter = 0;  // Usar padrão
}

//+------------------------------------------------------------------+
//| Carregar eventos de notícias padrão para XAUUSD                  |
//+------------------------------------------------------------------+
void CAdvancedFilters::LoadDefaultNewsEvents()
{
   // Eventos importantes que afetam XAUUSD (Ouro)
   // Estes são exemplos - em produção, usar feed de notícias real
   
   datetime today = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(today, dt);
   
   // NFP (primeira sexta-feira do mês)
   datetime nfpTime = StringToTime(StringFormat("%04d.%02d.01 13:30:00", dt.year, dt.mon));
   AddNewsEvent(nfpTime, "USD", NEWS_HIGH, "Non-Farm Payrolls");
   
   // FOMC (reuniões programadas)
   datetime fomcTime = StringToTime(StringFormat("%04d.%02d.15 19:00:00", dt.year, dt.mon));
   AddNewsEvent(fomcTime, "USD", NEWS_HIGH, "FOMC Meeting");
   
   // CPI (segunda semana do mês)
   datetime cpiTime = StringToTime(StringFormat("%04d.%02d.10 13:30:00", dt.year, dt.mon));
   AddNewsEvent(cpiTime, "USD", NEWS_HIGH, "Consumer Price Index");
   
   Print(StringFormat("[AdvancedFilters] Carregados %d eventos de notícias padrão", ArraySize(m_newsEvents)));
}

//+------------------------------------------------------------------+
//| Obter status dos filtros                                         |
//+------------------------------------------------------------------+
string CAdvancedFilters::GetFilterStatus()
{
   string status = "=== STATUS DOS FILTROS AVANÇADOS ===\n";
   
   status += StringFormat("Notícias: %s%s\n", 
                         m_newsFilterEnabled ? "ATIVO" : "INATIVO",
                         IsNewsTime() ? " [BLOQUEANDO]" : "");
                         
   status += StringFormat("Sessão: %s%s\n", 
                         m_sessionFilterEnabled ? "ATIVO" : "INATIVO",
                         m_sessionFilterEnabled && !IsValidSession() ? " [BLOQUEANDO]" : "");
                         
   status += StringFormat("ATR: %s%s\n", 
                         m_atrFilterEnabled ? "ATIVO" : "INATIVO",
                         m_atrFilterEnabled && !IsValidATR() ? " [BLOQUEANDO]" : "");
                         
   status += StringFormat("Spread: %s%s\n", 
                         m_spreadFilterEnabled ? "ATIVO" : "INATIVO",
                         m_spreadFilterEnabled && !IsValidSpread() ? " [BLOQUEANDO]" : "");
                         
   status += StringFormat("Horário: %s%s\n", 
                         m_timeFilterEnabled ? "ATIVO" : "INATIVO",
                         m_timeFilterEnabled && !IsValidTime() ? " [BLOQUEANDO]" : "");
                         
   status += StringFormat("\nTRADING PERMITIDO: %s", IsTradingAllowed() ? "SIM" : "NÃO");
   
   return status;
}

//+------------------------------------------------------------------+
//| Imprimir relatório dos filtros                                   |
//+------------------------------------------------------------------+
void CAdvancedFilters::PrintFilterReport()
{
   Print(GetFilterStatus());
}

//+------------------------------------------------------------------+
//| Converter string de tempo para datetime                          |
//+------------------------------------------------------------------+
datetime CAdvancedFilters::StringToTime(string timeStr)
{
   return StringToTime(timeStr);
}

//+------------------------------------------------------------------+