#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
TradeDev_Master - Criação da Biblioteca AdvancedClasses.mqh
Script para gerar a biblioteca com classes avançadas: SignalConfluence, DynamicLevels, AdvancedFilters
"""

import os
import sys
from pathlib import Path

def create_advanced_classes_library():
    """
    Cria a biblioteca AdvancedClasses.mqh com todas as classes avançadas
    """
    
    # Definir caminho de destino
    project_root = Path("C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/EA_FTMO_SCALPER_ELITE/MQL5_Source")
    source_dir = project_root / "Source"
    
    # Criar diretório se não existir
    source_dir.mkdir(parents=True, exist_ok=True)
    
    # Conteúdo da biblioteca AdvancedClasses.mqh
    advanced_classes_content = '''//+------------------------------------------------------------------+
//|                                           AdvancedClasses.mqh |
//|                                  TradeDev_Master Elite System |
//|                     Classes Avançadas para Trading Algorítmico |
//+------------------------------------------------------------------+
#property copyright "TradeDev_Master"
#property version   "1.00"
#property strict

// Includes necessários
#include "Core/DataStructures.mqh"
#include "Core/Interfaces.mqh"
#include "Core/Logger.mqh"

//+------------------------------------------------------------------+
//| Classe para Confluência de Sinais                               |
//+------------------------------------------------------------------+
class CSignalConfluence
{
private:
    struct SSignalWeight
    {
        string signal_name;
        double weight;
        bool is_active;
        datetime last_update;
    };
    
    SSignalWeight m_signals[];
    double m_min_confluence_score;
    double m_current_score;
    bool m_confluence_active;
    
public:
    CSignalConfluence();
    ~CSignalConfluence();
    
    // Métodos principais
    bool Initialize(double min_score = 0.7);
    void AddSignal(string name, double weight, bool active = false);
    void UpdateSignal(string name, bool active);
    double CalculateConfluenceScore();
    bool IsConfluenceActive();
    
    // Getters
    double GetCurrentScore() { return m_current_score; }
    int GetActiveSignalsCount();
    string GetSignalStatus();
    
    // Métodos de análise
    bool ValidateSignalStrength();
    void ResetSignals();
};

//+------------------------------------------------------------------+
//| Construtor                                                       |
//+------------------------------------------------------------------+
CSignalConfluence::CSignalConfluence()
{
    m_min_confluence_score = 0.7;
    m_current_score = 0.0;
    m_confluence_active = false;
    ArrayResize(m_signals, 0);
}

//+------------------------------------------------------------------+
//| Destrutor                                                        |
//+------------------------------------------------------------------+
CSignalConfluence::~CSignalConfluence()
{
    ArrayFree(m_signals);
}

//+------------------------------------------------------------------+
//| Inicialização                                                    |
//+------------------------------------------------------------------+
bool CSignalConfluence::Initialize(double min_score = 0.7)
{
    m_min_confluence_score = MathMax(0.1, MathMin(1.0, min_score));
    
    // Adicionar sinais padrão
    AddSignal("OrderBlock", 0.25);
    AddSignal("FVG", 0.20);
    AddSignal("Liquidity", 0.20);
    AddSignal("MarketStructure", 0.15);
    AddSignal("VolumeConfirmation", 0.10);
    AddSignal("TimeFilter", 0.10);
    
    return true;
}

//+------------------------------------------------------------------+
//| Adicionar sinal                                                  |
//+------------------------------------------------------------------+
void CSignalConfluence::AddSignal(string name, double weight, bool active = false)
{
    int size = ArraySize(m_signals);
    ArrayResize(m_signals, size + 1);
    
    m_signals[size].signal_name = name;
    m_signals[size].weight = MathMax(0.0, MathMin(1.0, weight));
    m_signals[size].is_active = active;
    m_signals[size].last_update = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Atualizar sinal                                                  |
//+------------------------------------------------------------------+
void CSignalConfluence::UpdateSignal(string name, bool active)
{
    for(int i = 0; i < ArraySize(m_signals); i++)
    {
        if(m_signals[i].signal_name == name)
        {
            m_signals[i].is_active = active;
            m_signals[i].last_update = TimeCurrent();
            break;
        }
    }
    
    // Recalcular score
    CalculateConfluenceScore();
}

//+------------------------------------------------------------------+
//| Calcular score de confluência                                    |
//+------------------------------------------------------------------+
double CSignalConfluence::CalculateConfluenceScore()
{
    double total_score = 0.0;
    double total_weight = 0.0;
    
    for(int i = 0; i < ArraySize(m_signals); i++)
    {
        total_weight += m_signals[i].weight;
        if(m_signals[i].is_active)
        {
            total_score += m_signals[i].weight;
        }
    }
    
    m_current_score = (total_weight > 0) ? total_score / total_weight : 0.0;
    m_confluence_active = (m_current_score >= m_min_confluence_score);
    
    return m_current_score;
}

//+------------------------------------------------------------------+
//| Verificar se confluência está ativa                             |
//+------------------------------------------------------------------+
bool CSignalConfluence::IsConfluenceActive()
{
    return m_confluence_active;
}

//+------------------------------------------------------------------+
//| Contar sinais ativos                                             |
//+------------------------------------------------------------------+
int CSignalConfluence::GetActiveSignalsCount()
{
    int count = 0;
    for(int i = 0; i < ArraySize(m_signals); i++)
    {
        if(m_signals[i].is_active) count++;
    }
    return count;
}

//+------------------------------------------------------------------+
//| Classe para Níveis Dinâmicos                                    |
//+------------------------------------------------------------------+
class CDynamicLevels
{
private:
    struct SDynamicLevel
    {
        double price;
        ENUM_TIMEFRAMES timeframe;
        datetime created_time;
        int strength;
        bool is_support;
        bool is_resistance;
        int touch_count;
    };
    
    SDynamicLevel m_levels[];
    double m_min_distance_points;
    int m_max_levels;
    
public:
    CDynamicLevels();
    ~CDynamicLevels();
    
    bool Initialize(int max_levels = 20, double min_distance = 10.0);
    void AddLevel(double price, ENUM_TIMEFRAMES tf, bool is_support, bool is_resistance, int strength = 1);
    void UpdateLevels();
    double GetNearestSupport(double current_price);
    double GetNearestResistance(double current_price);
    bool IsNearLevel(double price, double tolerance_points = 5.0);
    void CleanOldLevels(int max_age_hours = 24);
};

//+------------------------------------------------------------------+
//| Construtor CDynamicLevels                                       |
//+------------------------------------------------------------------+
CDynamicLevels::CDynamicLevels()
{
    m_min_distance_points = 10.0;
    m_max_levels = 20;
    ArrayResize(m_levels, 0);
}

//+------------------------------------------------------------------+
//| Destrutor CDynamicLevels                                        |
//+------------------------------------------------------------------+
CDynamicLevels::~CDynamicLevels()
{
    ArrayFree(m_levels);
}

//+------------------------------------------------------------------+
//| Inicialização CDynamicLevels                                    |
//+------------------------------------------------------------------+
bool CDynamicLevels::Initialize(int max_levels = 20, double min_distance = 10.0)
{
    m_max_levels = MathMax(5, MathMin(100, max_levels));
    m_min_distance_points = MathMax(1.0, min_distance);
    return true;
}

//+------------------------------------------------------------------+
//| Adicionar nível dinâmico                                        |
//+------------------------------------------------------------------+
void CDynamicLevels::AddLevel(double price, ENUM_TIMEFRAMES tf, bool is_support, bool is_resistance, int strength = 1)
{
    // Verificar se já existe nível próximo
    for(int i = 0; i < ArraySize(m_levels); i++)
    {
        if(MathAbs(m_levels[i].price - price) < m_min_distance_points * _Point)
        {
            // Atualizar nível existente
            m_levels[i].strength = MathMax(m_levels[i].strength, strength);
            m_levels[i].touch_count++;
            return;
        }
    }
    
    // Adicionar novo nível
    int size = ArraySize(m_levels);
    if(size >= m_max_levels)
    {
        // Remover nível mais fraco
        int weakest_idx = 0;
        int min_strength = m_levels[0].strength;
        for(int i = 1; i < size; i++)
        {
            if(m_levels[i].strength < min_strength)
            {
                min_strength = m_levels[i].strength;
                weakest_idx = i;
            }
        }
        
        // Substituir nível mais fraco
        m_levels[weakest_idx].price = price;
        m_levels[weakest_idx].timeframe = tf;
        m_levels[weakest_idx].created_time = TimeCurrent();
        m_levels[weakest_idx].strength = strength;
        m_levels[weakest_idx].is_support = is_support;
        m_levels[weakest_idx].is_resistance = is_resistance;
        m_levels[weakest_idx].touch_count = 1;
    }
    else
    {
        ArrayResize(m_levels, size + 1);
        m_levels[size].price = price;
        m_levels[size].timeframe = tf;
        m_levels[size].created_time = TimeCurrent();
        m_levels[size].strength = strength;
        m_levels[size].is_support = is_support;
        m_levels[size].is_resistance = is_resistance;
        m_levels[size].touch_count = 1;
    }
}

//+------------------------------------------------------------------+
//| Obter suporte mais próximo                                      |
//+------------------------------------------------------------------+
double CDynamicLevels::GetNearestSupport(double current_price)
{
    double nearest_support = 0.0;
    double min_distance = DBL_MAX;
    
    for(int i = 0; i < ArraySize(m_levels); i++)
    {
        if(m_levels[i].is_support && m_levels[i].price < current_price)
        {
            double distance = current_price - m_levels[i].price;
            if(distance < min_distance)
            {
                min_distance = distance;
                nearest_support = m_levels[i].price;
            }
        }
    }
    
    return nearest_support;
}

//+------------------------------------------------------------------+
//| Obter resistência mais próxima                                  |
//+------------------------------------------------------------------+
double CDynamicLevels::GetNearestResistance(double current_price)
{
    double nearest_resistance = 0.0;
    double min_distance = DBL_MAX;
    
    for(int i = 0; i < ArraySize(m_levels); i++)
    {
        if(m_levels[i].is_resistance && m_levels[i].price > current_price)
        {
            double distance = m_levels[i].price - current_price;
            if(distance < min_distance)
            {
                min_distance = distance;
                nearest_resistance = m_levels[i].price;
            }
        }
    }
    
    return nearest_resistance;
}

//+------------------------------------------------------------------+
//| Classe para Filtros Avançados                                   |
//+------------------------------------------------------------------+
class CAdvancedFilters
{
private:
    // Filtros de tempo
    bool m_time_filter_enabled;
    int m_start_hour;
    int m_end_hour;
    bool m_avoid_news;
    
    // Filtros de volatilidade
    bool m_volatility_filter_enabled;
    double m_min_volatility;
    double m_max_volatility;
    
    // Filtros de spread
    bool m_spread_filter_enabled;
    double m_max_spread_points;
    
    // Filtros de correlação
    bool m_correlation_filter_enabled;
    string m_correlation_symbols[];
    double m_max_correlation;
    
public:
    CAdvancedFilters();
    ~CAdvancedFilters();
    
    bool Initialize();
    
    // Configuração de filtros
    void SetTimeFilter(bool enabled, int start_hour, int end_hour, bool avoid_news = true);
    void SetVolatilityFilter(bool enabled, double min_vol, double max_vol);
    void SetSpreadFilter(bool enabled, double max_spread);
    void SetCorrelationFilter(bool enabled, string symbols[], double max_corr);
    
    // Verificações
    bool PassTimeFilter();
    bool PassVolatilityFilter();
    bool PassSpreadFilter();
    bool PassCorrelationFilter();
    bool PassAllFilters();
    
    // Utilitários
    double CalculateCurrentVolatility(int periods = 14);
    double GetCurrentSpread();
    string GetFilterStatus();
};

//+------------------------------------------------------------------+
//| Construtor CAdvancedFilters                                     |
//+------------------------------------------------------------------+
CAdvancedFilters::CAdvancedFilters()
{
    m_time_filter_enabled = false;
    m_start_hour = 8;
    m_end_hour = 17;
    m_avoid_news = true;
    
    m_volatility_filter_enabled = false;
    m_min_volatility = 0.0;
    m_max_volatility = 100.0;
    
    m_spread_filter_enabled = true;
    m_max_spread_points = 3.0;
    
    m_correlation_filter_enabled = false;
    m_max_correlation = 0.8;
    
    ArrayResize(m_correlation_symbols, 0);
}

//+------------------------------------------------------------------+
//| Destrutor CAdvancedFilters                                      |
//+------------------------------------------------------------------+
CAdvancedFilters::~CAdvancedFilters()
{
    ArrayFree(m_correlation_symbols);
}

//+------------------------------------------------------------------+
//| Inicialização CAdvancedFilters                                  |
//+------------------------------------------------------------------+
bool CAdvancedFilters::Initialize()
{
    return true;
}

//+------------------------------------------------------------------+
//| Configurar filtro de tempo                                      |
//+------------------------------------------------------------------+
void CAdvancedFilters::SetTimeFilter(bool enabled, int start_hour, int end_hour, bool avoid_news = true)
{
    m_time_filter_enabled = enabled;
    m_start_hour = MathMax(0, MathMin(23, start_hour));
    m_end_hour = MathMax(0, MathMin(23, end_hour));
    m_avoid_news = avoid_news;
}

//+------------------------------------------------------------------+
//| Verificar filtro de tempo                                       |
//+------------------------------------------------------------------+
bool CAdvancedFilters::PassTimeFilter()
{
    if(!m_time_filter_enabled) return true;
    
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    // Verificar horário de trading
    if(m_start_hour <= m_end_hour)
    {
        if(dt.hour < m_start_hour || dt.hour >= m_end_hour)
            return false;
    }
    else
    {
        if(dt.hour < m_start_hour && dt.hour >= m_end_hour)
            return false;
    }
    
    // Evitar fins de semana
    if(dt.day_of_week == 0 || dt.day_of_week == 6)
        return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| Verificar filtro de spread                                      |
//+------------------------------------------------------------------+
bool CAdvancedFilters::PassSpreadFilter()
{
    if(!m_spread_filter_enabled) return true;
    
    double current_spread = GetCurrentSpread();
    return (current_spread <= m_max_spread_points);
}

//+------------------------------------------------------------------+
//| Obter spread atual                                               |
//+------------------------------------------------------------------+
double CAdvancedFilters::GetCurrentSpread()
{
    return (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID)) / _Point;
}

//+------------------------------------------------------------------+
//| Verificar todos os filtros                                      |
//+------------------------------------------------------------------+
bool CAdvancedFilters::PassAllFilters()
{
    return PassTimeFilter() && 
           PassVolatilityFilter() && 
           PassSpreadFilter() && 
           PassCorrelationFilter();
}

//+------------------------------------------------------------------+
//| Calcular volatilidade atual                                     |
//+------------------------------------------------------------------+
double CAdvancedFilters::CalculateCurrentVolatility(int periods = 14)
{
    double atr_values[];
    ArraySetAsSeries(atr_values, true);
    
    int atr_handle = iATR(_Symbol, PERIOD_CURRENT, periods);
    if(atr_handle == INVALID_HANDLE) return 0.0;
    
    if(CopyBuffer(atr_handle, 0, 0, 1, atr_values) <= 0)
    {
        IndicatorRelease(atr_handle);
        return 0.0;
    }
    
    IndicatorRelease(atr_handle);
    return atr_values[0] / _Point;
}

//+------------------------------------------------------------------+
//| Verificar filtro de volatilidade                                |
//+------------------------------------------------------------------+
bool CAdvancedFilters::PassVolatilityFilter()
{
    if(!m_volatility_filter_enabled) return true;
    
    double current_volatility = CalculateCurrentVolatility();
    return (current_volatility >= m_min_volatility && current_volatility <= m_max_volatility);
}

//+------------------------------------------------------------------+
//| Verificar filtro de correlação                                  |
//+------------------------------------------------------------------+
bool CAdvancedFilters::PassCorrelationFilter()
{
    if(!m_correlation_filter_enabled) return true;
    
    // Implementação simplificada - pode ser expandida
    return true;
}

//+------------------------------------------------------------------+
//| Obter status dos filtros                                        |
//+------------------------------------------------------------------+
string CAdvancedFilters::GetFilterStatus()
{
    string status = "Filtros: ";
    status += "Tempo=" + (string)PassTimeFilter() + " ";
    status += "Spread=" + (string)PassSpreadFilter() + " ";
    status += "Volatilidade=" + (string)PassVolatilityFilter() + " ";
    status += "Correlação=" + (string)PassCorrelationFilter();
    return status;
}
'''
    
    # Escrever arquivo
    file_path = source_dir / "AdvancedClasses.mqh"
    
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(advanced_classes_content)
        
        print(f"✓ Criado: AdvancedClasses.mqh")
        return True
        
    except Exception as e:
        print(f"✗ Erro ao criar AdvancedClasses.mqh: {e}")
        return False

def main():
    """
    Função principal
    """
    print("=== TradeDev_Master - Criação da Biblioteca AdvancedClasses ===\n")
    
    success = create_advanced_classes_library()
    
    if success:
        print("\n🎉 Biblioteca AdvancedClasses.mqh criada com sucesso!")
        print("Localização: C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/EA_FTMO_SCALPER_ELITE/MQL5_Source/Source/")
    else:
        print("\n❌ Falha na criação da biblioteca AdvancedClasses.mqh")
        sys.exit(1)

if __name__ == "__main__":
    main()