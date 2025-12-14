#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script Avançado para Recriação Completa de Bibliotecas do EA
TradeDev_Master - Sistema de Regeneração de Dependências Elite
"""

import os
from pathlib import Path
from datetime import datetime

class LibraryGenerator:
    def __init__(self, project_root):
        self.project_root = Path(project_root)
        self.source_dir = self.project_root / "EA_FTMO_SCALPER_ELITE" / "MQL5_Source" / "Source"
        
    def create_data_structures(self):
        """Cria DataStructures.mqh com todas as estruturas necessárias"""
        content = '''
//+------------------------------------------------------------------+
//|                                           DataStructures.mqh |
//|                        TradeDev_Master Elite Trading System     |
//|                                   Advanced Market Analysis      |
//+------------------------------------------------------------------+

#ifndef DATA_STRUCTURES_MQH
#define DATA_STRUCTURES_MQH

// Enumerações para Log System
enum ENUM_LOG_LEVEL
{
   LOG_DEBUG = 0,
   LOG_INFO = 1,
   LOG_WARNING = 2,
   LOG_ERROR = 3,
   LOG_CRITICAL = 4
};

// Enumerações para SL/TP Calculation
enum ENUM_SL_CALCULATION_METHOD
{
   SL_FIXED = 0,
   SL_ATR = 1,
   SL_STRUCTURE = 2,
   SL_HYBRID = 3,
   SL_DYNAMIC = 4
};

enum ENUM_TP_CALCULATION_METHOD
{
   TP_FIXED = 0,
   TP_ATR = 1,
   TP_STRUCTURE = 2,
   TP_RR_RATIO = 3,
   TP_FIBONACCI = 4
};

// Enumerações para Trailing Stop
enum ENUM_TRAILING_METHOD
{
   TRAILING_NONE = 0,
   TRAILING_FIXED = 1,
   TRAILING_ATR = 2,
   TRAILING_STRUCTURE_BREAKS = 3,
   TRAILING_SMART = 4,
   TRAILING_PARABOLIC = 5
};

// Enumerações ICT/SMC
enum ENUM_ORDER_BLOCK_TYPE
{
   OB_BULLISH = 0,
   OB_BEARISH = 1,
   OB_MITIGATION = 2
};

enum ENUM_FVG_TYPE
{
   FVG_BULLISH = 0,
   FVG_BEARISH = 1,
   FVG_BALANCED = 2
};

enum ENUM_LIQUIDITY_TYPE
{
   LIQ_EQUAL_HIGHS = 0,
   LIQ_EQUAL_LOWS = 1,
   LIQ_SWEEP_HIGH = 2,
   LIQ_SWEEP_LOW = 3,
   LIQ_INSTITUTIONAL = 4
};

// Estruturas ICT/SMC
struct SOrderBlock
{
   datetime time_start;
   datetime time_end;
   double high;
   double low;
   double open;
   double close;
   double volume;
   ENUM_ORDER_BLOCK_TYPE type;
   bool is_valid;
   bool is_mitigated;
   int strength;
   double mitigation_percentage;
   datetime last_test_time;
   int test_count;
};

struct SFVG
{
   datetime time;
   double high;
   double low;
   double gap_size;
   ENUM_FVG_TYPE type;
   bool is_filled;
   double fill_percentage;
   bool is_valid;
   int timeframe;
   double volume_imbalance;
};

struct SLiquidityLevel
{
   double price;
   datetime time_created;
   datetime time_last_test;
   ENUM_LIQUIDITY_TYPE type;
   int touches;
   bool is_broken;
   bool is_swept;
   double volume;
   double strength;
   bool is_institutional;
};

struct SMarketStructure
{
   bool is_bullish_structure;
   bool is_bearish_structure;
   bool is_ranging;
   double structure_high;
   double structure_low;
   datetime last_structure_break;
   bool choch_detected;
   bool bos_detected;
   double momentum_strength;
};

// Estruturas de Performance
struct SPerformanceMetrics
{
   double total_profit;
   double total_loss;
   double profit_factor;
   double sharpe_ratio;
   double max_drawdown;
   double max_drawdown_percent;
   int total_trades;
   int winning_trades;
   int losing_trades;
   double win_rate;
   double avg_win;
   double avg_loss;
   double largest_win;
   double largest_loss;
   double recovery_factor;
   datetime last_update;
};

// Estruturas de Confluência
struct SSignalConfluence
{
   double score;
   bool order_block_confluence;
   bool fvg_confluence;
   bool liquidity_confluence;
   bool structure_confluence;
   bool volume_confluence;
   bool time_confluence;
   bool fibonacci_confluence;
   bool trend_confluence;
   datetime signal_time;
   bool is_valid;
};

// Estruturas de Risk Management
struct SRiskParameters
{
   double max_risk_per_trade;
   double max_daily_risk;
   double max_weekly_risk;
   double max_monthly_risk;
   double current_daily_risk;
   double current_weekly_risk;
   double current_monthly_risk;
   bool risk_limit_reached;
   datetime last_reset_time;
};

// Estruturas de Cache
struct SCacheEntry
{
   string key;
   string value;
   datetime timestamp;
   datetime expiry;
   bool is_valid;
};

// Estruturas de Configuração
struct SConfigData
{
   string section;
   string key;
   string value;
   string description;
   bool is_encrypted;
};

// Estruturas de Estatísticas do EA
struct SEAStatistics
{
   datetime start_time;
   datetime last_update;
   int total_signals;
   int signals_taken;
   int signals_filtered;
   double signal_accuracy;
   double avg_signal_strength;
   SPerformanceMetrics performance;
   SRiskParameters risk_status;
};

#endif // DATA_STRUCTURES_MQH
'''
        return content
        
    def create_interfaces(self):
        """Cria Interfaces.mqh com todas as interfaces necessárias"""
        content = '''
//+------------------------------------------------------------------+
//|                                              Interfaces.mqh |
//|                        TradeDev_Master Elite Trading System     |
//|                                   Advanced Interface Definitions|
//+------------------------------------------------------------------+

#ifndef INTERFACES_MQH
#define INTERFACES_MQH

#include "DataStructures.mqh"

// Interface base para todos os detectores
class IDetector
{
public:
   virtual bool Initialize() = 0;
   virtual bool Update() = 0;
   virtual void Reset() = 0;
   virtual bool IsValid() = 0;
   virtual string GetStatus() = 0;
};

// Interface para análise de confluência
class IConfluenceAnalyzer
{
public:
   virtual double CalculateScore() = 0;
   virtual bool IsValidSignal() = 0;
   virtual SSignalConfluence GetConfluenceData() = 0;
   virtual void UpdateWeights(double &weights[]) = 0;
};

// Interface para gestão de cache
class ICacheManager
{
public:
   virtual bool Set(string key, string value, int expiry_seconds = 3600) = 0;
   virtual string Get(string key) = 0;
   virtual bool Exists(string key) = 0;
   virtual bool Delete(string key) = 0;
   virtual void Clear() = 0;
   virtual int GetSize() = 0;
};

// Interface para análise de performance
class IPerformanceAnalyzer
{
public:
   virtual void UpdateMetrics() = 0;
   virtual SPerformanceMetrics GetMetrics() = 0;
   virtual double GetSharpeRatio() = 0;
   virtual double GetMaxDrawdown() = 0;
   virtual bool IsPerformanceAcceptable() = 0;
   virtual string GenerateReport() = 0;
};

// Interface para gestão de configuração
class IConfigManager
{
public:
   virtual bool LoadConfig(string filename) = 0;
   virtual bool SaveConfig(string filename) = 0;
   virtual string GetValue(string section, string key, string default_value = "") = 0;
   virtual bool SetValue(string section, string key, string value) = 0;
   virtual bool DeleteKey(string section, string key) = 0;
   virtual void Reset() = 0;
};

// Interface para logging
class ILogger
{
public:
   virtual void SetLevel(ENUM_LOG_LEVEL level) = 0;
   virtual void Debug(string message) = 0;
   virtual void Info(string message) = 0;
   virtual void Warning(string message) = 0;
   virtual void Error(string message) = 0;
   virtual void Critical(string message) = 0;
   virtual bool SaveToFile(string filename) = 0;
};

// Interface para detectores ICT/SMC
class IOrderBlockDetector : public IDetector
{
public:
   virtual SOrderBlock[] GetOrderBlocks() = 0;
   virtual bool IsOrderBlockValid(SOrderBlock &ob) = 0;
   virtual double GetOrderBlockStrength(SOrderBlock &ob) = 0;
};

class IFVGDetector : public IDetector
{
public:
   virtual SFVG[] GetFVGs() = 0;
   virtual bool IsFVGValid(SFVG &fvg) = 0;
   virtual double GetFVGStrength(SFVG &fvg) = 0;
};

class ILiquidityDetector : public IDetector
{
public:
   virtual SLiquidityLevel[] GetLiquidityLevels() = 0;
   virtual bool IsLiquidityLevelValid(SLiquidityLevel &level) = 0;
   virtual double GetLiquidityStrength(SLiquidityLevel &level) = 0;
};

class IMarketStructureAnalyzer : public IDetector
{
public:
   virtual SMarketStructure GetMarketStructure() = 0;
   virtual bool IsStructureBullish() = 0;
   virtual bool IsStructureBearish() = 0;
   virtual bool IsCHoCHDetected() = 0;
   virtual bool IsBOSDetected() = 0;
};

#endif // INTERFACES_MQH
'''
        return content
        
    def create_logger(self):
        """Cria Logger.mqh com sistema de logging avançado"""
        content = '''
//+------------------------------------------------------------------+
//|                                                   Logger.mqh |
//|                        TradeDev_Master Elite Trading System     |
//|                                   Advanced Logging System       |
//+------------------------------------------------------------------+

#ifndef LOGGER_MQH
#define LOGGER_MQH

#include "Interfaces.mqh"
#include "DataStructures.mqh"

class CLogger : public ILogger
{
private:
   ENUM_LOG_LEVEL m_log_level;
   bool m_enabled;
   bool m_file_logging;
   string m_log_file;
   string m_log_buffer[];
   int m_buffer_size;
   datetime m_last_flush;
   
public:
   CLogger() : m_log_level(LOG_INFO), m_enabled(true), m_file_logging(false), 
               m_buffer_size(0), m_last_flush(0)
   {
      m_log_file = "EA_FTMO_Scalper_" + TimeToString(TimeCurrent(), TIME_DATE) + ".log";
      ArrayResize(m_log_buffer, 1000);
   }
   
   ~CLogger()
   {
      FlushBuffer();
   }
   
   virtual void SetLevel(ENUM_LOG_LEVEL level) override
   {
      m_log_level = level;
   }
   
   void Enable(bool enable) { m_enabled = enable; }
   void EnableFileLogging(bool enable) { m_file_logging = enable; }
   void SetLogFile(string filename) { m_log_file = filename; }
   
   virtual void Debug(string message) override
   {
      if(m_enabled && m_log_level <= LOG_DEBUG)
         WriteLog("DEBUG", message);
   }
   
   virtual void Info(string message) override
   {
      if(m_enabled && m_log_level <= LOG_INFO)
         WriteLog("INFO", message);
   }
   
   virtual void Warning(string message) override
   {
      if(m_enabled && m_log_level <= LOG_WARNING)
         WriteLog("WARNING", message);
   }
   
   virtual void Error(string message) override
   {
      if(m_enabled && m_log_level <= LOG_ERROR)
         WriteLog("ERROR", message);
   }
   
   virtual void Critical(string message) override
   {
      if(m_enabled && m_log_level <= LOG_CRITICAL)
      {
         WriteLog("CRITICAL", message);
         FlushBuffer(); // Flush immediately for critical messages
      }
   }
   
   virtual bool SaveToFile(string filename) override
   {
      if(m_buffer_size == 0) return true;
      
      int file_handle = FileOpen(filename, FILE_WRITE|FILE_TXT);
      if(file_handle == INVALID_HANDLE)
         return false;
         
      for(int i = 0; i < m_buffer_size; i++)
      {
         FileWrite(file_handle, m_log_buffer[i]);
      }
      
      FileClose(file_handle);
      return true;
   }
   
private:
   void WriteLog(string level, string message)
   {
      string timestamp = TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);
      string log_entry = StringFormat("[%s] [%s] %s", timestamp, level, message);
      
      // Print to terminal
      Print(log_entry);
      
      // Add to buffer
      if(m_buffer_size < ArraySize(m_log_buffer))
      {
         m_log_buffer[m_buffer_size] = log_entry;
         m_buffer_size++;
      }
      
      // Auto-flush every 5 minutes or when buffer is full
      if(TimeCurrent() - m_last_flush > 300 || m_buffer_size >= ArraySize(m_log_buffer))
      {
         FlushBuffer();
      }
   }
   
   void FlushBuffer()
   {
      if(m_file_logging && m_buffer_size > 0)
      {
         SaveToFile(m_log_file);
      }
      m_buffer_size = 0;
      m_last_flush = TimeCurrent();
   }
};

#endif // LOGGER_MQH
'''
        return content
        
    def create_config_manager(self):
        """Cria ConfigManager.mqh"""
        content = '''
//+------------------------------------------------------------------+
//|                                            ConfigManager.mqh |
//|                        TradeDev_Master Elite Trading System     |
//|                                   Advanced Configuration Manager|
//+------------------------------------------------------------------+

#ifndef CONFIG_MANAGER_MQH
#define CONFIG_MANAGER_MQH

#include "Interfaces.mqh"
#include "DataStructures.mqh"

class CConfigManager : public IConfigManager
{
private:
   SConfigData m_config_data[];
   int m_data_count;
   string m_current_file;
   
public:
   CConfigManager() : m_data_count(0), m_current_file("")
   {
      ArrayResize(m_config_data, 100);
   }
   
   virtual bool LoadConfig(string filename) override
   {
      m_current_file = filename;
      
      int file_handle = FileOpen(filename, FILE_READ|FILE_TXT);
      if(file_handle == INVALID_HANDLE)
         return false;
         
      m_data_count = 0;
      string current_section = "";
      
      while(!FileIsEnding(file_handle))
      {
         string line = FileReadString(file_handle);
         line = StringTrimLeft(StringTrimRight(line));
         
         if(StringLen(line) == 0 || StringGetCharacter(line, 0) == ';')
            continue;
            
         if(StringGetCharacter(line, 0) == '[' && StringGetCharacter(line, StringLen(line)-1) == ']')
         {
            current_section = StringSubstr(line, 1, StringLen(line)-2);
            continue;
         }
         
         int pos = StringFind(line, "=");
         if(pos > 0)
         {
            string key = StringTrimRight(StringSubstr(line, 0, pos));
            string value = StringTrimLeft(StringSubstr(line, pos+1));
            
            if(m_data_count < ArraySize(m_config_data))
            {
               m_config_data[m_data_count].section = current_section;
               m_config_data[m_data_count].key = key;
               m_config_data[m_data_count].value = value;
               m_config_data[m_data_count].description = "";
               m_config_data[m_data_count].is_encrypted = false;
               m_data_count++;
            }
         }
      }
      
      FileClose(file_handle);
      return true;
   }
   
   virtual bool SaveConfig(string filename) override
   {
      int file_handle = FileOpen(filename, FILE_WRITE|FILE_TXT);
      if(file_handle == INVALID_HANDLE)
         return false;
         
      string current_section = "";
      
      for(int i = 0; i < m_data_count; i++)
      {
         if(m_config_data[i].section != current_section)
         {
            current_section = m_config_data[i].section;
            if(StringLen(current_section) > 0)
               FileWrite(file_handle, "[" + current_section + "]");
         }
         
         FileWrite(file_handle, m_config_data[i].key + "=" + m_config_data[i].value);
      }
      
      FileClose(file_handle);
      return true;
   }
   
   virtual string GetValue(string section, string key, string default_value = "") override
   {
      for(int i = 0; i < m_data_count; i++)
      {
         if(m_config_data[i].section == section && m_config_data[i].key == key)
            return m_config_data[i].value;
      }
      return default_value;
   }
   
   virtual bool SetValue(string section, string key, string value) override
   {
      // Try to update existing
      for(int i = 0; i < m_data_count; i++)
      {
         if(m_config_data[i].section == section && m_config_data[i].key == key)
         {
            m_config_data[i].value = value;
            return true;
         }
      }
      
      // Add new if not found
      if(m_data_count < ArraySize(m_config_data))
      {
         m_config_data[m_data_count].section = section;
         m_config_data[m_data_count].key = key;
         m_config_data[m_data_count].value = value;
         m_config_data[m_data_count].description = "";
         m_config_data[m_data_count].is_encrypted = false;
         m_data_count++;
         return true;
      }
      
      return false;
   }
   
   virtual bool DeleteKey(string section, string key) override
   {
      for(int i = 0; i < m_data_count; i++)
      {
         if(m_config_data[i].section == section && m_config_data[i].key == key)
         {
            // Shift array elements
            for(int j = i; j < m_data_count - 1; j++)
            {
               m_config_data[j] = m_config_data[j + 1];
            }
            m_data_count--;
            return true;
         }
      }
      return false;
   }
   
   virtual void Reset() override
   {
      m_data_count = 0;
      m_current_file = "";
   }
   
   // Additional utility methods
   double GetDoubleValue(string section, string key, double default_value = 0.0)
   {
      string str_value = GetValue(section, key);
      if(StringLen(str_value) == 0)
         return default_value;
      return StringToDouble(str_value);
   }
   
   int GetIntValue(string section, string key, int default_value = 0)
   {
      string str_value = GetValue(section, key);
      if(StringLen(str_value) == 0)
         return default_value;
      return (int)StringToInteger(str_value);
   }
   
   bool GetBoolValue(string section, string key, bool default_value = false)
   {
      string str_value = GetValue(section, key);
      if(StringLen(str_value) == 0)
         return default_value;
      return (StringToLower(str_value) == "true" || str_value == "1");
   }
};

#endif // CONFIG_MANAGER_MQH
'''
        return content
        
    def create_cache_manager(self):
        """Cria CacheManager.mqh"""
        content = '''
//+------------------------------------------------------------------+
//|                                             CacheManager.mqh |
//|                        TradeDev_Master Elite Trading System     |
//|                                   High-Performance Cache System |
//+------------------------------------------------------------------+

#ifndef CACHE_MANAGER_MQH
#define CACHE_MANAGER_MQH

#include "Interfaces.mqh"
#include "DataStructures.mqh"

class CCacheManager : public ICacheManager
{
private:
   SCacheEntry m_cache_entries[];
   int m_entry_count;
   int m_max_entries;
   datetime m_last_cleanup;
   
public:
   CCacheManager(int max_entries = 1000) : m_entry_count(0), m_max_entries(max_entries), m_last_cleanup(0)
   {
      ArrayResize(m_cache_entries, m_max_entries);
   }
   
   virtual bool Set(string key, string value, int expiry_seconds = 3600) override
   {
      CleanupExpired();
      
      // Try to update existing entry
      for(int i = 0; i < m_entry_count; i++)
      {
         if(m_cache_entries[i].key == key)
         {
            m_cache_entries[i].value = value;
            m_cache_entries[i].timestamp = TimeCurrent();
            m_cache_entries[i].expiry = TimeCurrent() + expiry_seconds;
            m_cache_entries[i].is_valid = true;
            return true;
         }
      }
      
      // Add new entry if space available
      if(m_entry_count < m_max_entries)
      {
         m_cache_entries[m_entry_count].key = key;
         m_cache_entries[m_entry_count].value = value;
         m_cache_entries[m_entry_count].timestamp = TimeCurrent();
         m_cache_entries[m_entry_count].expiry = TimeCurrent() + expiry_seconds;
         m_cache_entries[m_entry_count].is_valid = true;
         m_entry_count++;
         return true;
      }
      
      // Cache is full, remove oldest entry
      RemoveOldestEntry();
      return Set(key, value, expiry_seconds);
   }
   
   virtual string Get(string key) override
   {
      for(int i = 0; i < m_entry_count; i++)
      {
         if(m_cache_entries[i].key == key && m_cache_entries[i].is_valid)
         {
            if(TimeCurrent() <= m_cache_entries[i].expiry)
            {
               return m_cache_entries[i].value;
            }
            else
            {
               m_cache_entries[i].is_valid = false;
            }
         }
      }
      return "";
   }
   
   virtual bool Exists(string key) override
   {
      for(int i = 0; i < m_entry_count; i++)
      {
         if(m_cache_entries[i].key == key && m_cache_entries[i].is_valid)
         {
            if(TimeCurrent() <= m_cache_entries[i].expiry)
            {
               return true;
            }
            else
            {
               m_cache_entries[i].is_valid = false;
            }
         }
      }
      return false;
   }
   
   virtual bool Delete(string key) override
   {
      for(int i = 0; i < m_entry_count; i++)
      {
         if(m_cache_entries[i].key == key)
         {
            // Shift array elements
            for(int j = i; j < m_entry_count - 1; j++)
            {
               m_cache_entries[j] = m_cache_entries[j + 1];
            }
            m_entry_count--;
            return true;
         }
      }
      return false;
   }
   
   virtual void Clear() override
   {
      m_entry_count = 0;
   }
   
   virtual int GetSize() override
   {
      return m_entry_count;
   }
   
   // Additional utility methods
   double GetDouble(string key, double default_value = 0.0)
   {
      string value = Get(key);
      if(StringLen(value) == 0)
         return default_value;
      return StringToDouble(value);
   }
   
   int GetInt(string key, int default_value = 0)
   {
      string value = Get(key);
      if(StringLen(value) == 0)
         return default_value;
      return (int)StringToInteger(value);
   }
   
   bool GetBool(string key, bool default_value = false)
   {
      string value = Get(key);
      if(StringLen(value) == 0)
         return default_value;
      return (StringToLower(value) == "true" || value == "1");
   }
   
   void SetDouble(string key, double value, int expiry_seconds = 3600)
   {
      Set(key, DoubleToString(value, 8), expiry_seconds);
   }
   
   void SetInt(string key, int value, int expiry_seconds = 3600)
   {
      Set(key, IntegerToString(value), expiry_seconds);
   }
   
   void SetBool(string key, bool value, int expiry_seconds = 3600)
   {
      Set(key, value ? "true" : "false", expiry_seconds);
   }
   
private:
   void CleanupExpired()
   {
      if(TimeCurrent() - m_last_cleanup < 60) // Cleanup every minute
         return;
         
      for(int i = m_entry_count - 1; i >= 0; i--)
      {
         if(!m_cache_entries[i].is_valid || TimeCurrent() > m_cache_entries[i].expiry)
         {
            // Shift array elements
            for(int j = i; j < m_entry_count - 1; j++)
            {
               m_cache_entries[j] = m_cache_entries[j + 1];
            }
            m_entry_count--;
         }
      }
      
      m_last_cleanup = TimeCurrent();
   }
   
   void RemoveOldestEntry()
   {
      if(m_entry_count == 0) return;
      
      int oldest_index = 0;
      datetime oldest_time = m_cache_entries[0].timestamp;
      
      for(int i = 1; i < m_entry_count; i++)
      {
         if(m_cache_entries[i].timestamp < oldest_time)
         {
            oldest_time = m_cache_entries[i].timestamp;
            oldest_index = i;
         }
      }
      
      // Shift array elements
      for(int j = oldest_index; j < m_entry_count - 1; j++)
      {
         m_cache_entries[j] = m_cache_entries[j + 1];
      }
      m_entry_count--;
   }
};

#endif // CACHE_MANAGER_MQH
'''
        return content
        
    def create_performance_analyzer(self):
        """Cria PerformanceAnalyzer.mqh"""
        content = '''
//+------------------------------------------------------------------+
//|                                        PerformanceAnalyzer.mqh |
//|                        TradeDev_Master Elite Trading System     |
//|                                   Advanced Performance Analytics|
//+------------------------------------------------------------------+

#ifndef PERFORMANCE_ANALYZER_MQH
#define PERFORMANCE_ANALYZER_MQH

#include "Interfaces.mqh"
#include "DataStructures.mqh"
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>
#include <Trade\DealInfo.mqh>

class CPerformanceAnalyzer : public IPerformanceAnalyzer
{
private:
   SPerformanceMetrics m_metrics;
   double m_equity_curve[];
   datetime m_equity_times[];
   int m_curve_size;
   double m_initial_balance;
   datetime m_start_time;
   
public:
   CPerformanceAnalyzer()
   {
      m_initial_balance = AccountInfoDouble(ACCOUNT_BALANCE);
      m_start_time = TimeCurrent();
      m_curve_size = 0;
      ArrayResize(m_equity_curve, 10000);
      ArrayResize(m_equity_times, 10000);
      ResetMetrics();
   }
   
   virtual void UpdateMetrics() override
   {
      CalculateBasicMetrics();
      CalculateAdvancedMetrics();
      UpdateEquityCurve();
   }
   
   virtual SPerformanceMetrics GetMetrics() override
   {
      return m_metrics;
   }
   
   virtual double GetSharpeRatio() override
   {
      return m_metrics.sharpe_ratio;
   }
   
   virtual double GetMaxDrawdown() override
   {
      return m_metrics.max_drawdown_percent;
   }
   
   virtual bool IsPerformanceAcceptable() override
   {
      // FTMO compliance checks
      if(m_metrics.max_drawdown_percent > 5.0) return false;
      if(m_metrics.profit_factor < 1.1) return false;
      if(m_metrics.win_rate < 40.0) return false;
      return true;
   }
   
   virtual string GenerateReport() override
   {
      string report = "\n=== PERFORMANCE REPORT ===\n";
      report += StringFormat("Total Profit: %.2f\n", m_metrics.total_profit);
      report += StringFormat("Total Loss: %.2f\n", m_metrics.total_loss);
      report += StringFormat("Net Profit: %.2f\n", m_metrics.total_profit + m_metrics.total_loss);
      report += StringFormat("Profit Factor: %.2f\n", m_metrics.profit_factor);
      report += StringFormat("Sharpe Ratio: %.2f\n", m_metrics.sharpe_ratio);
      report += StringFormat("Max Drawdown: %.2f%% (%.2f)\n", m_metrics.max_drawdown_percent, m_metrics.max_drawdown);
      report += StringFormat("Total Trades: %d\n", m_metrics.total_trades);
      report += StringFormat("Win Rate: %.1f%% (%d/%d)\n", m_metrics.win_rate, m_metrics.winning_trades, m_metrics.total_trades);
      report += StringFormat("Avg Win: %.2f\n", m_metrics.avg_win);
      report += StringFormat("Avg Loss: %.2f\n", m_metrics.avg_loss);
      report += StringFormat("Largest Win: %.2f\n", m_metrics.largest_win);
      report += StringFormat("Largest Loss: %.2f\n", m_metrics.largest_loss);
      report += StringFormat("Recovery Factor: %.2f\n", m_metrics.recovery_factor);
      report += "========================\n";
      return report;
   }
   
private:
   void ResetMetrics()
   {
      m_metrics.total_profit = 0;
      m_metrics.total_loss = 0;
      m_metrics.profit_factor = 0;
      m_metrics.sharpe_ratio = 0;
      m_metrics.max_drawdown = 0;
      m_metrics.max_drawdown_percent = 0;
      m_metrics.total_trades = 0;
      m_metrics.winning_trades = 0;
      m_metrics.losing_trades = 0;
      m_metrics.win_rate = 0;
      m_metrics.avg_win = 0;
      m_metrics.avg_loss = 0;
      m_metrics.largest_win = 0;
      m_metrics.largest_loss = 0;
      m_metrics.recovery_factor = 0;
      m_metrics.last_update = TimeCurrent();
   }
   
   void CalculateBasicMetrics()
   {
      HistorySelect(m_start_time, TimeCurrent());
      
      m_metrics.total_profit = 0;
      m_metrics.total_loss = 0;
      m_metrics.total_trades = 0;
      m_metrics.winning_trades = 0;
      m_metrics.losing_trades = 0;
      m_metrics.largest_win = 0;
      m_metrics.largest_loss = 0;
      
      double wins_sum = 0;
      double losses_sum = 0;
      
      for(int i = 0; i < HistoryDealsTotal(); i++)
      {
         ulong ticket = HistoryDealGetTicket(i);
         if(ticket == 0) continue;
         
         if(HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT)
         {
            double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
            double swap = HistoryDealGetDouble(ticket, DEAL_SWAP);
            double commission = HistoryDealGetDouble(ticket, DEAL_COMMISSION);
            double total_result = profit + swap + commission;
            
            m_metrics.total_trades++;
            
            if(total_result > 0)
            {
               m_metrics.total_profit += total_result;
               m_metrics.winning_trades++;
               wins_sum += total_result;
               if(total_result > m_metrics.largest_win)
                  m_metrics.largest_win = total_result;
            }
            else if(total_result < 0)
            {
               m_metrics.total_loss += total_result;
               m_metrics.losing_trades++;
               losses_sum += total_result;
               if(total_result < m_metrics.largest_loss)
                  m_metrics.largest_loss = total_result;
            }
         }
      }
      
      // Calculate derived metrics
      if(m_metrics.total_trades > 0)
      {
         m_metrics.win_rate = (double)m_metrics.winning_trades / m_metrics.total_trades * 100.0;
      }
      
      if(m_metrics.winning_trades > 0)
      {
         m_metrics.avg_win = wins_sum / m_metrics.winning_trades;
      }
      
      if(m_metrics.losing_trades > 0)
      {
         m_metrics.avg_loss = losses_sum / m_metrics.losing_trades;
      }
      
      if(MathAbs(m_metrics.total_loss) > 0)
      {
         m_metrics.profit_factor = m_metrics.total_profit / MathAbs(m_metrics.total_loss);
      }
      
      m_metrics.last_update = TimeCurrent();
   }
   
   void CalculateAdvancedMetrics()
   {
      CalculateMaxDrawdown();
      CalculateSharpeRatio();
      CalculateRecoveryFactor();
   }
   
   void CalculateMaxDrawdown()
   {
      if(m_curve_size < 2) return;
      
      double peak = m_equity_curve[0];
      double max_dd = 0;
      double max_dd_percent = 0;
      
      for(int i = 1; i < m_curve_size; i++)
      {
         if(m_equity_curve[i] > peak)
         {
            peak = m_equity_curve[i];
         }
         else
         {
            double drawdown = peak - m_equity_curve[i];
            double drawdown_percent = (drawdown / peak) * 100.0;
            
            if(drawdown > max_dd)
            {
               max_dd = drawdown;
            }
            
            if(drawdown_percent > max_dd_percent)
            {
               max_dd_percent = drawdown_percent;
            }
         }
      }
      
      m_metrics.max_drawdown = max_dd;
      m_metrics.max_drawdown_percent = max_dd_percent;
   }
   
   void CalculateSharpeRatio()
   {
      if(m_curve_size < 30) return; // Need at least 30 data points
      
      double returns[];
      ArrayResize(returns, m_curve_size - 1);
      
      // Calculate returns
      for(int i = 1; i < m_curve_size; i++)
      {
         if(m_equity_curve[i-1] != 0)
         {
            returns[i-1] = (m_equity_curve[i] - m_equity_curve[i-1]) / m_equity_curve[i-1];
         }
      }
      
      // Calculate mean return
      double mean_return = 0;
      for(int i = 0; i < ArraySize(returns); i++)
      {
         mean_return += returns[i];
      }
      mean_return /= ArraySize(returns);
      
      // Calculate standard deviation
      double variance = 0;
      for(int i = 0; i < ArraySize(returns); i++)
      {
         variance += MathPow(returns[i] - mean_return, 2);
      }
      variance /= ArraySize(returns);
      double std_dev = MathSqrt(variance);
      
      // Calculate Sharpe ratio (assuming risk-free rate = 0)
      if(std_dev != 0)
      {
         m_metrics.sharpe_ratio = mean_return / std_dev * MathSqrt(252); // Annualized
      }
   }
   
   void CalculateRecoveryFactor()
   {
      double net_profit = m_metrics.total_profit + m_metrics.total_loss;
      if(m_metrics.max_drawdown > 0)
      {
         m_metrics.recovery_factor = net_profit / m_metrics.max_drawdown;
      }
   }
   
   void UpdateEquityCurve()
   {
      double current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
      datetime current_time = TimeCurrent();
      
      if(m_curve_size < ArraySize(m_equity_curve))
      {
         m_equity_curve[m_curve_size] = current_equity;
         m_equity_times[m_curve_size] = current_time;
         m_curve_size++;
      }
      else
      {
         // Shift array and add new value
         for(int i = 0; i < ArraySize(m_equity_curve) - 1; i++)
         {
            m_equity_curve[i] = m_equity_curve[i + 1];
            m_equity_times[i] = m_equity_times[i + 1];
         }
         m_equity_curve[ArraySize(m_equity_curve) - 1] = current_equity;
         m_equity_times[ArraySize(m_equity_times) - 1] = current_time;
      }
   }
};

#endif // PERFORMANCE_ANALYZER_MQH
'''
        return content
        
    def create_all_libraries(self):
        """Cria todas as bibliotecas necessárias"""
        libraries = {
            "Source/Core/DataStructures.mqh": self.create_data_structures(),
            "Source/Core/Interfaces.mqh": self.create_interfaces(),
            "Source/Core/Logger.mqh": self.create_logger(),
            "Source/Core/ConfigManager.mqh": self.create_config_manager(),
            "Source/Core/CacheManager.mqh": self.create_cache_manager(),
            "Source/Core/PerformanceAnalyzer.mqh": self.create_performance_analyzer()
        }
        
        created_count = 0
        
        for lib_path, content in libraries.items():
            full_path = self.source_dir / lib_path
            try:
                full_path.parent.mkdir(parents=True, exist_ok=True)
                with open(full_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"✅ Biblioteca criada: {lib_path}")
                created_count += 1
            except Exception as e:
                print(f"❌ Erro ao criar {lib_path}: {e}")
                
        return created_count
        
if __name__ == "__main__":
    project_root = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD"
    generator = LibraryGenerator(project_root)
    
    print("🚀 Iniciando recriação de bibliotecas Core...")
    created = generator.create_all_libraries()
    print(f"✅ Processo concluído: {created}/6 bibliotecas Core criadas")