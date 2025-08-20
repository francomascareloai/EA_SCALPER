//+------------------------------------------------------------------+
//|                                              AdvancedClasses.mqh |
//|                                  Copyright 2024, TradeDev_Master |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, TradeDev_Master"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "DataStructures.mqh"
#include "Interfaces.mqh"
#include "Logger.mqh"

//+------------------------------------------------------------------+
//| Classe para confluência de sinais                                |
//+------------------------------------------------------------------+
class CSignalConfluence
{
private:
   double            m_momentum_weight;     // Peso do momentum
   double            m_volume_weight;       // Peso do volume
   double            m_structure_weight;    // Peso da estrutura
   double            m_min_confluence;      // Confluência mínima
   
public:
   // Construtor
   CSignalConfluence()
   {
      m_momentum_weight = 0.3;
      m_volume_weight = 0.3;
      m_structure_weight = 0.4;
      m_min_confluence = 0.7;
   }
   
   // Destrutor
   ~CSignalConfluence() {}
   
   // Inicialização
   bool Init(double momentum_weight = 0.3, double volume_weight = 0.3, 
             double structure_weight = 0.4, double min_confluence = 0.7)
   {
      m_momentum_weight = momentum_weight;
      m_volume_weight = volume_weight;
      m_structure_weight = structure_weight;
      m_min_confluence = min_confluence;
      return true;
   }
   
   // Calcular confluência de sinais
   double CalculateConfluence(double momentum_signal, double volume_signal, double structure_signal)
   {
      double confluence = (momentum_signal * m_momentum_weight) + 
                         (volume_signal * m_volume_weight) + 
                         (structure_signal * m_structure_weight);
      return confluence;
   }
   
   // Verificar se confluência é válida
   bool IsValidConfluence(double confluence)
   {
      return confluence >= m_min_confluence;
   }
   
   // Obter força do sinal
   ENUM_SIGNAL_STRENGTH GetSignalStrength(double confluence)
   {
      if(confluence >= 0.9) return SIGNAL_VERY_STRONG;
      if(confluence >= 0.8) return SIGNAL_STRONG;
      if(confluence >= 0.7) return SIGNAL_MEDIUM;
      if(confluence >= 0.6) return SIGNAL_WEAK;
      return SIGNAL_VERY_WEAK;
   }
};

//+------------------------------------------------------------------+
//| Classe para níveis dinâmicos                                     |
//+------------------------------------------------------------------+
class CDynamicLevels
{
private:
   double            m_support_levels[];    // Níveis de suporte
   double            m_resistance_levels[]; // Níveis de resistência
   datetime          m_last_update;         // Última atualização
   int               m_max_levels;          // Máximo de níveis
   
public:
   // Construtor
   CDynamicLevels()
   {
      m_last_update = 0;
      m_max_levels = 10;
      ArrayResize(m_support_levels, m_max_levels);
      ArrayResize(m_resistance_levels, m_max_levels);
      ArrayInitialize(m_support_levels, 0.0);
      ArrayInitialize(m_resistance_levels, 0.0);
   }
   
   // Destrutor
   ~CDynamicLevels() {}
   
   // Inicialização
   bool Init(int max_levels = 10)
   {
      m_max_levels = max_levels;
      ArrayResize(m_support_levels, m_max_levels);
      ArrayResize(m_resistance_levels, m_max_levels);
      return true;
   }
   
   // Atualizar níveis
   void UpdateLevels()
   {
      if(TimeCurrent() - m_last_update < 300) return; // Atualizar a cada 5 minutos
      
      // Calcular novos níveis baseados em pivots
      CalculatePivotLevels();
      m_last_update = TimeCurrent();
   }
   
   // Calcular níveis de pivot
   void CalculatePivotLevels()
   {
      double high = iHigh(_Symbol, PERIOD_D1, 1);
      double low = iLow(_Symbol, PERIOD_D1, 1);
      double close = iClose(_Symbol, PERIOD_D1, 1);
      
      double pivot = (high + low + close) / 3.0;
      
      // Resistências
      m_resistance_levels[0] = pivot + (high - low) * 0.382;
      m_resistance_levels[1] = pivot + (high - low) * 0.618;
      m_resistance_levels[2] = pivot + (high - low) * 1.0;
      
      // Suportes
      m_support_levels[0] = pivot - (high - low) * 0.382;
      m_support_levels[1] = pivot - (high - low) * 0.618;
      m_support_levels[2] = pivot - (high - low) * 1.0;
   }
   
   // Obter nível de suporte mais próximo
   double GetNearestSupport(double price)
   {
      double nearest = 0.0;
      double min_distance = DBL_MAX;
      
      for(int i = 0; i < m_max_levels; i++)
      {
         if(m_support_levels[i] > 0 && m_support_levels[i] < price)
         {
            double distance = price - m_support_levels[i];
            if(distance < min_distance)
            {
               min_distance = distance;
               nearest = m_support_levels[i];
            }
         }
      }
      return nearest;
   }
   
   // Obter nível de resistência mais próximo
   double GetNearestResistance(double price)
   {
      double nearest = 0.0;
      double min_distance = DBL_MAX;
      
      for(int i = 0; i < m_max_levels; i++)
      {
         if(m_resistance_levels[i] > 0 && m_resistance_levels[i] > price)
         {
            double distance = m_resistance_levels[i] - price;
            if(distance < min_distance)
            {
               min_distance = distance;
               nearest = m_resistance_levels[i];
            }
         }
      }
      return nearest;
   }
};

//+------------------------------------------------------------------+
//| Classe para filtros avançados                                    |
//+------------------------------------------------------------------+
class CAdvancedFilters
{
private:
   bool              m_news_filter_enabled;     // Filtro de notícias ativo
   bool              m_spread_filter_enabled;   // Filtro de spread ativo
   bool              m_volatility_filter_enabled; // Filtro de volatilidade ativo
   double            m_max_spread;              // Spread máximo
   double            m_min_volatility;          // Volatilidade mínima
   double            m_max_volatility;          // Volatilidade máxima
   
public:
   // Construtor
   CAdvancedFilters()
   {
      m_news_filter_enabled = true;
      m_spread_filter_enabled = true;
      m_volatility_filter_enabled = true;
      m_max_spread = 30.0;
      m_min_volatility = 0.0001;
      m_max_volatility = 0.01;
   }
   
   // Destrutor
   ~CAdvancedFilters() {}
   
   // Inicialização
   bool Init(bool news_filter = true, bool spread_filter = true, 
             bool volatility_filter = true, double max_spread = 30.0)
   {
      m_news_filter_enabled = news_filter;
      m_spread_filter_enabled = spread_filter;
      m_volatility_filter_enabled = volatility_filter;
      m_max_spread = max_spread;
      return true;
   }
   
   // Verificar se trading é permitido
   bool IsTradingAllowed()
   {
      if(m_spread_filter_enabled && !CheckSpreadFilter()) return false;
      if(m_volatility_filter_enabled && !CheckVolatilityFilter()) return false;
      if(m_news_filter_enabled && !CheckNewsFilter()) return false;
      
      return true;
   }
   
   // Verificar filtro de spread
   bool CheckSpreadFilter()
   {
      double spread = (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - 
                      SymbolInfoDouble(_Symbol, SYMBOL_BID)) / _Point;
      return spread <= m_max_spread;
   }
   
   // Verificar filtro de volatilidade
   bool CheckVolatilityFilter()
   {
      int atr_handle = iATR(_Symbol, PERIOD_H1, 14);
      if(atr_handle == INVALID_HANDLE) return false;
      
      double atr_buffer[1];
      if(CopyBuffer(atr_handle, 0, 0, 1, atr_buffer) <= 0)
      {
         IndicatorRelease(atr_handle);
         return false;
      }
      
      double atr = atr_buffer[0];
      IndicatorRelease(atr_handle);
      return (atr >= m_min_volatility && atr <= m_max_volatility);
   }
   
   // Verificar filtro de notícias
   bool CheckNewsFilter()
   {
      // Implementação básica - verificar horário de notícias
      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);
      
      // Evitar trading 30 minutos antes e depois de notícias importantes
      // (implementação simplificada)
      if(dt.hour == 8 && dt.min >= 30) return false;  // NFP
      if(dt.hour == 9 && dt.min <= 30) return false;  // NFP
      if(dt.hour == 14 && dt.min >= 30) return false; // FOMC
      if(dt.hour == 15 && dt.min <= 30) return false; // FOMC
      
      return true;
   }
   
   // Configurar parâmetros
   void SetSpreadFilter(bool enabled, double max_spread = 30.0)
   {
      m_spread_filter_enabled = enabled;
      m_max_spread = max_spread;
   }
   
   void SetVolatilityFilter(bool enabled, double min_vol = 0.0001, double max_vol = 0.01)
   {
      m_volatility_filter_enabled = enabled;
      m_min_volatility = min_vol;
      m_max_volatility = max_vol;
   }
   
   void SetNewsFilter(bool enabled)
   {
      m_news_filter_enabled = enabled;
   }
};