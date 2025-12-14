#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
TradeDev_Master - Criação das Bibliotecas ICT/SMC Restantes
Cria: FVGDetector.mqh, LiquidityDetector.mqh, MarketStructureAnalyzer.mqh
"""

import os
import sys
from pathlib import Path

def create_fvg_detector():
    """Cria a biblioteca FVGDetector.mqh"""
    content = '''//+------------------------------------------------------------------+
//|                                              FVGDetector.mqh |
//|                        Copyright 2024, TradeDev_Master Team |
//|                                   https://github.com/tradedev |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, TradeDev_Master Team"
#property link      "https://github.com/tradedev"
#property version   "1.00"
#property strict

#include "../Core/DataStructures.mqh"
#include "../Core/Interfaces.mqh"
#include "../Core/Logger.mqh"

//+------------------------------------------------------------------+
//| Fair Value Gap (FVG) Detector Class                             |
//+------------------------------------------------------------------+
class CFVGDetector : public IDetector
{
private:
    // Configurações
    int               m_min_gap_points;     // Mínimo de pontos para FVG válido
    double            m_min_gap_ratio;      // Ratio mínimo do gap
    int               m_max_age_bars;       // Idade máxima em barras
    bool              m_filter_by_volume;   // Filtrar por volume
    
    // Arrays de dados
    SFVG              m_fvgs[];             // Array de FVGs detectados
    int               m_fvg_count;          // Contador de FVGs
    
    // Cache
    datetime          m_last_check_time;
    bool              m_cache_valid;
    
public:
    // Construtor/Destrutor
                     CFVGDetector(void);
                    ~CFVGDetector(void);
    
    // Métodos principais
    virtual bool      Initialize(void) override;
    virtual bool      Update(void) override;
    virtual void      Reset(void) override;
    
    // Configuração
    void              SetMinGapPoints(int points) { m_min_gap_points = points; }
    void              SetMinGapRatio(double ratio) { m_min_gap_ratio = ratio; }
    void              SetMaxAge(int bars) { m_max_age_bars = bars; }
    void              SetVolumeFilter(bool enable) { m_filter_by_volume = enable; }
    
    // Detecção de FVGs
    bool              DetectFVGs(int start_bar = 1, int bars_count = 100);
    bool              IsFVGValid(const SFVG &fvg);
    double            CalculateFVGStrength(const SFVG &fvg);
    
    // Análise de FVGs
    bool              IsFVGFilled(const SFVG &fvg, int current_bar = 0);
    double            GetFVGFillPercentage(const SFVG &fvg, int current_bar = 0);
    ENUM_FVG_STATUS   GetFVGStatus(const SFVG &fvg, int current_bar = 0);
    
    // Getters
    int               GetFVGCount(void) const { return m_fvg_count; }
    SFVG              GetFVG(int index) const;
    SFVG              GetNearestFVG(double price, ENUM_FVG_TYPE type = FVG_TYPE_ANY);
    
    // Filtros
    bool              FilterFVGsByTimeframe(ENUM_TIMEFRAMES tf);
    bool              FilterFVGsByStrength(double min_strength);
    
private:
    // Métodos auxiliares
    bool              IsGapValid(double high1, double low1, double high2, double low2, double high3, double low3);
    ENUM_FVG_TYPE     DetermineFVGType(double high1, double low1, double high2, double low2, double high3, double low3);
    double            CalculateGapSize(const SFVG &fvg);
    bool              CheckVolumeConfirmation(int bar_index);
    void              CleanupOldFVGs(void);
    void              SortFVGsByStrength(void);
};

//+------------------------------------------------------------------+
//| Construtor                                                       |
//+------------------------------------------------------------------+
CFVGDetector::CFVGDetector(void) :
    m_min_gap_points(10),
    m_min_gap_ratio(0.001),
    m_max_age_bars(100),
    m_filter_by_volume(true),
    m_fvg_count(0),
    m_last_check_time(0),
    m_cache_valid(false)
{
    ArrayResize(m_fvgs, 100);
    ArrayInitialize(m_fvgs, 0);
}

//+------------------------------------------------------------------+
//| Destrutor                                                        |
//+------------------------------------------------------------------+
CFVGDetector::~CFVGDetector(void)
{
    ArrayFree(m_fvgs);
}

//+------------------------------------------------------------------+
//| Inicialização                                                    |
//+------------------------------------------------------------------+
bool CFVGDetector::Initialize(void)
{
    CLogger::Log(LOG_INFO, "CFVGDetector", "Inicializando detector de FVG...");
    
    // Verificar dados suficientes
    if(Bars(_Symbol, _Period) < 10)
    {
        CLogger::Log(LOG_ERROR, "CFVGDetector", "Dados insuficientes para análise");
        return false;
    }
    
    Reset();
    
    CLogger::Log(LOG_INFO, "CFVGDetector", "Detector de FVG inicializado com sucesso");
    return true;
}

//+------------------------------------------------------------------+
//| Atualização                                                      |
//+------------------------------------------------------------------+
bool CFVGDetector::Update(void)
{
    datetime current_time = TimeCurrent();
    
    // Verificar se precisa atualizar
    if(m_cache_valid && current_time == m_last_check_time)
        return true;
    
    // Detectar novos FVGs
    bool result = DetectFVGs();
    
    if(result)
    {
        CleanupOldFVGs();
        SortFVGsByStrength();
        
        m_last_check_time = current_time;
        m_cache_valid = true;
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| Reset                                                            |
//+------------------------------------------------------------------+
void CFVGDetector::Reset(void)
{
    m_fvg_count = 0;
    m_last_check_time = 0;
    m_cache_valid = false;
    ArrayInitialize(m_fvgs, 0);
    
    CLogger::Log(LOG_INFO, "CFVGDetector", "Detector resetado");
}

//+------------------------------------------------------------------+
//| Detectar FVGs                                                    |
//+------------------------------------------------------------------+
bool CFVGDetector::DetectFVGs(int start_bar = 1, int bars_count = 100)
{
    int bars_available = Bars(_Symbol, _Period);
    if(bars_available < 3) return false;
    
    int end_bar = MathMin(start_bar + bars_count, bars_available - 2);
    m_fvg_count = 0;
    
    for(int i = start_bar; i < end_bar; i++)
    {
        // Obter dados das 3 barras
        double high1 = iHigh(_Symbol, _Period, i+1);
        double low1 = iLow(_Symbol, _Period, i+1);
        double high2 = iHigh(_Symbol, _Period, i);
        double low2 = iLow(_Symbol, _Period, i);
        double high3 = iHigh(_Symbol, _Period, i-1);
        double low3 = iLow(_Symbol, _Period, i-1);
        
        // Verificar se há gap válido
        if(IsGapValid(high1, low1, high2, low2, high3, low3))
        {
            SFVG fvg;
            fvg.type = DetermineFVGType(high1, low1, high2, low2, high3, low3);
            fvg.time_created = iTime(_Symbol, _Period, i);
            fvg.bar_index = i;
            
            if(fvg.type == FVG_TYPE_BULLISH)
            {
                fvg.upper_level = low3;
                fvg.lower_level = high1;
            }
            else if(fvg.type == FVG_TYPE_BEARISH)
            {
                fvg.upper_level = low1;
                fvg.lower_level = high3;
            }
            
            fvg.strength = CalculateFVGStrength(fvg);
            fvg.status = FVG_STATUS_ACTIVE;
            fvg.fill_percentage = 0.0;
            
            if(IsFVGValid(fvg))
            {
                if(m_fvg_count < ArraySize(m_fvgs))
                {
                    m_fvgs[m_fvg_count] = fvg;
                    m_fvg_count++;
                }
            }
        }
    }
    
    CLogger::Log(LOG_INFO, "CFVGDetector", StringFormat("Detectados %d FVGs", m_fvg_count));
    return true;
}

//+------------------------------------------------------------------+
//| Verificar se gap é válido                                       |
//+------------------------------------------------------------------+
bool CFVGDetector::IsGapValid(double high1, double low1, double high2, double low2, double high3, double low3)
{
    // FVG Bullish: low3 > high1
    if(low3 > high1)
    {
        double gap_size = low3 - high1;
        double gap_points = gap_size / _Point;
        return (gap_points >= m_min_gap_points);
    }
    
    // FVG Bearish: high3 < low1
    if(high3 < low1)
    {
        double gap_size = low1 - high3;
        double gap_points = gap_size / _Point;
        return (gap_points >= m_min_gap_points);
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Determinar tipo de FVG                                          |
//+------------------------------------------------------------------+
ENUM_FVG_TYPE CFVGDetector::DetermineFVGType(double high1, double low1, double high2, double low2, double high3, double low3)
{
    if(low3 > high1) return FVG_TYPE_BULLISH;
    if(high3 < low1) return FVG_TYPE_BEARISH;
    return FVG_TYPE_NONE;
}

//+------------------------------------------------------------------+
//| Calcular força do FVG                                           |
//+------------------------------------------------------------------+
double CFVGDetector::CalculateFVGStrength(const SFVG &fvg)
{
    double gap_size = MathAbs(fvg.upper_level - fvg.lower_level);
    double atr = iATR(_Symbol, _Period, 14, fvg.bar_index);
    
    if(atr > 0)
        return gap_size / atr;
    
    return 1.0;
}

//+------------------------------------------------------------------+
//| Verificar se FVG é válido                                       |
//+------------------------------------------------------------------+
bool CFVGDetector::IsFVGValid(const SFVG &fvg)
{
    // Verificar tamanho mínimo
    double gap_size = MathAbs(fvg.upper_level - fvg.lower_level);
    if(gap_size < m_min_gap_points * _Point)
        return false;
    
    // Verificar força mínima
    if(fvg.strength < m_min_gap_ratio)
        return false;
    
    // Verificar confirmação por volume se habilitado
    if(m_filter_by_volume && !CheckVolumeConfirmation(fvg.bar_index))
        return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| Verificar confirmação por volume                                 |
//+------------------------------------------------------------------+
bool CFVGDetector::CheckVolumeConfirmation(int bar_index)
{
    long volume = iVolume(_Symbol, _Period, bar_index);
    long avg_volume = 0;
    
    // Calcular volume médio das últimas 20 barras
    for(int i = 1; i <= 20; i++)
    {
        avg_volume += iVolume(_Symbol, _Period, bar_index + i);
    }
    avg_volume /= 20;
    
    return (volume > avg_volume * 1.2); // Volume 20% acima da média
}

//+------------------------------------------------------------------+
//| Limpar FVGs antigos                                             |
//+------------------------------------------------------------------+
void CFVGDetector::CleanupOldFVGs(void)
{
    datetime current_time = TimeCurrent();
    int valid_count = 0;
    
    for(int i = 0; i < m_fvg_count; i++)
    {
        // Verificar idade
        int bars_age = iBarShift(_Symbol, _Period, m_fvgs[i].time_created);
        
        if(bars_age <= m_max_age_bars && m_fvgs[i].status != FVG_STATUS_FILLED)
        {
            if(valid_count != i)
                m_fvgs[valid_count] = m_fvgs[i];
            valid_count++;
        }
    }
    
    m_fvg_count = valid_count;
}

//+------------------------------------------------------------------+
//| Ordenar FVGs por força                                          |
//+------------------------------------------------------------------+
void CFVGDetector::SortFVGsByStrength(void)
{
    // Bubble sort simples por força (decrescente)
    for(int i = 0; i < m_fvg_count - 1; i++)
    {
        for(int j = 0; j < m_fvg_count - 1 - i; j++)
        {
            if(m_fvgs[j].strength < m_fvgs[j + 1].strength)
            {
                SFVG temp = m_fvgs[j];
                m_fvgs[j] = m_fvgs[j + 1];
                m_fvgs[j + 1] = temp;
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Obter FVG por índice                                            |
//+------------------------------------------------------------------+
SFVG CFVGDetector::GetFVG(int index) const
{
    SFVG empty_fvg = {0};
    
    if(index >= 0 && index < m_fvg_count)
        return m_fvgs[index];
    
    return empty_fvg;
}

//+------------------------------------------------------------------+
//| Obter FVG mais próximo                                          |
//+------------------------------------------------------------------+
SFVG CFVGDetector::GetNearestFVG(double price, ENUM_FVG_TYPE type = FVG_TYPE_ANY)
{
    SFVG nearest_fvg = {0};
    double min_distance = DBL_MAX;
    
    for(int i = 0; i < m_fvg_count; i++)
    {
        if(type != FVG_TYPE_ANY && m_fvgs[i].type != type)
            continue;
        
        if(m_fvgs[i].status != FVG_STATUS_ACTIVE)
            continue;
        
        double center = (m_fvgs[i].upper_level + m_fvgs[i].lower_level) / 2.0;
        double distance = MathAbs(price - center);
        
        if(distance < min_distance)
        {
            min_distance = distance;
            nearest_fvg = m_fvgs[i];
        }
    }
    
    return nearest_fvg;
}
'''
    return content

def create_liquidity_detector():
    """Cria a biblioteca LiquidityDetector.mqh"""
    content = '''//+------------------------------------------------------------------+
//|                                         LiquidityDetector.mqh |
//|                        Copyright 2024, TradeDev_Master Team |
//|                                   https://github.com/tradedev |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, TradeDev_Master Team"
#property link      "https://github.com/tradedev"
#property version   "1.00"
#property strict

#include "../Core/DataStructures.mqh"
#include "../Core/Interfaces.mqh"
#include "../Core/Logger.mqh"

//+------------------------------------------------------------------+
//| Liquidity Detector Class                                        |
//+------------------------------------------------------------------+
class CLiquidityDetector : public IDetector
{
private:
    // Configurações
    int               m_lookback_bars;       // Barras para análise
    double            m_min_liquidity_size;  // Tamanho mínimo de liquidez
    int               m_min_touches;         // Mínimo de toques no nível
    bool              m_use_volume_filter;   // Usar filtro de volume
    
    // Arrays de dados
    SLiquidityZone    m_liquidity_zones[];   // Zonas de liquidez
    int               m_zone_count;          // Contador de zonas
    
    // Cache
    datetime          m_last_update;
    bool              m_cache_valid;
    
public:
    // Construtor/Destrutor
                     CLiquidityDetector(void);
                    ~CLiquidityDetector(void);
    
    // Métodos principais
    virtual bool      Initialize(void) override;
    virtual bool      Update(void) override;
    virtual void      Reset(void) override;
    
    // Configuração
    void              SetLookbackBars(int bars) { m_lookback_bars = bars; }
    void              SetMinLiquiditySize(double size) { m_min_liquidity_size = size; }
    void              SetMinTouches(int touches) { m_min_touches = touches; }
    void              SetVolumeFilter(bool enable) { m_use_volume_filter = enable; }
    
    // Detecção de liquidez
    bool              DetectLiquidityZones(void);
    bool              DetectBuySideLiquidity(void);
    bool              DetectSellSideLiquidity(void);
    
    // Análise de zonas
    double            CalculateZoneStrength(const SLiquidityZone &zone);
    bool              IsZoneValid(const SLiquidityZone &zone);
    ENUM_LIQUIDITY_STATUS GetZoneStatus(const SLiquidityZone &zone);
    
    // Getters
    int               GetZoneCount(void) const { return m_zone_count; }
    SLiquidityZone    GetZone(int index) const;
    SLiquidityZone    GetNearestZone(double price, ENUM_LIQUIDITY_TYPE type = LIQUIDITY_TYPE_ANY);
    
    // Análise de mercado
    bool              IsLiquidityGrab(double price, ENUM_LIQUIDITY_TYPE type);
    double            GetLiquidityDensity(double price_level, double range);
    
private:
    // Métodos auxiliares
    bool              FindSwingHighs(double &highs[], datetime &times[], int &count);
    bool              FindSwingLows(double &lows[], datetime &times[], int &count);
    int               CountTouches(double level, double tolerance, int start_bar, int end_bar);
    bool              CheckVolumeConfirmation(double level, int bar_index);
    void              CleanupOldZones(void);
    void              SortZonesByStrength(void);
};

//+------------------------------------------------------------------+
//| Construtor                                                       |
//+------------------------------------------------------------------+
CLiquidityDetector::CLiquidityDetector(void) :
    m_lookback_bars(100),
    m_min_liquidity_size(20),
    m_min_touches(2),
    m_use_volume_filter(true),
    m_zone_count(0),
    m_last_update(0),
    m_cache_valid(false)
{
    ArrayResize(m_liquidity_zones, 50);
    ArrayInitialize(m_liquidity_zones, 0);
}

//+------------------------------------------------------------------+
//| Destrutor                                                        |
//+------------------------------------------------------------------+
CLiquidityDetector::~CLiquidityDetector(void)
{
    ArrayFree(m_liquidity_zones);
}

//+------------------------------------------------------------------+
//| Inicialização                                                    |
//+------------------------------------------------------------------+
bool CLiquidityDetector::Initialize(void)
{
    CLogger::Log(LOG_INFO, "CLiquidityDetector", "Inicializando detector de liquidez...");
    
    if(Bars(_Symbol, _Period) < m_lookback_bars)
    {
        CLogger::Log(LOG_ERROR, "CLiquidityDetector", "Dados insuficientes para análise");
        return false;
    }
    
    Reset();
    
    CLogger::Log(LOG_INFO, "CLiquidityDetector", "Detector de liquidez inicializado");
    return true;
}

//+------------------------------------------------------------------+
//| Atualização                                                      |
//+------------------------------------------------------------------+
bool CLiquidityDetector::Update(void)
{
    datetime current_time = TimeCurrent();
    
    if(m_cache_valid && current_time == m_last_update)
        return true;
    
    bool result = DetectLiquidityZones();
    
    if(result)
    {
        CleanupOldZones();
        SortZonesByStrength();
        
        m_last_update = current_time;
        m_cache_valid = true;
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| Reset                                                            |
//+------------------------------------------------------------------+
void CLiquidityDetector::Reset(void)
{
    m_zone_count = 0;
    m_last_update = 0;
    m_cache_valid = false;
    ArrayInitialize(m_liquidity_zones, 0);
    
    CLogger::Log(LOG_INFO, "CLiquidityDetector", "Detector resetado");
}

//+------------------------------------------------------------------+
//| Detectar zonas de liquidez                                      |
//+------------------------------------------------------------------+
bool CLiquidityDetector::DetectLiquidityZones(void)
{
    m_zone_count = 0;
    
    // Detectar liquidez do lado comprador e vendedor
    DetectBuySideLiquidity();
    DetectSellSideLiquidity();
    
    CLogger::Log(LOG_INFO, "CLiquidityDetector", 
                StringFormat("Detectadas %d zonas de liquidez", m_zone_count));
    
    return true;
}

//+------------------------------------------------------------------+
//| Detectar liquidez do lado comprador                             |
//+------------------------------------------------------------------+
bool CLiquidityDetector::DetectBuySideLiquidity(void)
{
    double highs[100];
    datetime times[100];
    int high_count = 0;
    
    if(!FindSwingHighs(highs, times, high_count))
        return false;
    
    for(int i = 0; i < high_count && m_zone_count < ArraySize(m_liquidity_zones); i++)
    {
        double level = highs[i];
        int touches = CountTouches(level, 5 * _Point, 1, m_lookback_bars);
        
        if(touches >= m_min_touches)
        {
            SLiquidityZone zone;
            zone.type = LIQUIDITY_TYPE_BUY_SIDE;
            zone.level = level;
            zone.upper_bound = level + (m_min_liquidity_size * _Point);
            zone.lower_bound = level - (m_min_liquidity_size * _Point);
            zone.time_created = times[i];
            zone.touches = touches;
            zone.strength = CalculateZoneStrength(zone);
            zone.status = LIQUIDITY_STATUS_ACTIVE;
            zone.volume_confirmation = CheckVolumeConfirmation(level, iBarShift(_Symbol, _Period, times[i]));
            
            if(IsZoneValid(zone))
            {
                m_liquidity_zones[m_zone_count] = zone;
                m_zone_count++;
            }
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Detectar liquidez do lado vendedor                              |
//+------------------------------------------------------------------+
bool CLiquidityDetector::DetectSellSideLiquidity(void)
{
    double lows[100];
    datetime times[100];
    int low_count = 0;
    
    if(!FindSwingLows(lows, times, low_count))
        return false;
    
    for(int i = 0; i < low_count && m_zone_count < ArraySize(m_liquidity_zones); i++)
    {
        double level = lows[i];
        int touches = CountTouches(level, 5 * _Point, 1, m_lookback_bars);
        
        if(touches >= m_min_touches)
        {
            SLiquidityZone zone;
            zone.type = LIQUIDITY_TYPE_SELL_SIDE;
            zone.level = level;
            zone.upper_bound = level + (m_min_liquidity_size * _Point);
            zone.lower_bound = level - (m_min_liquidity_size * _Point);
            zone.time_created = times[i];
            zone.touches = touches;
            zone.strength = CalculateZoneStrength(zone);
            zone.status = LIQUIDITY_STATUS_ACTIVE;
            zone.volume_confirmation = CheckVolumeConfirmation(level, iBarShift(_Symbol, _Period, times[i]));
            
            if(IsZoneValid(zone))
            {
                m_liquidity_zones[m_zone_count] = zone;
                m_zone_count++;
            }
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Encontrar swing highs                                           |
//+------------------------------------------------------------------+
bool CLiquidityDetector::FindSwingHighs(double &highs[], datetime &times[], int &count)
{
    count = 0;
    int swing_period = 5;
    
    for(int i = swing_period; i < m_lookback_bars - swing_period; i++)
    {
        double current_high = iHigh(_Symbol, _Period, i);
        bool is_swing_high = true;
        
        // Verificar se é um swing high
        for(int j = 1; j <= swing_period; j++)
        {
            if(iHigh(_Symbol, _Period, i - j) >= current_high ||
               iHigh(_Symbol, _Period, i + j) >= current_high)
            {
                is_swing_high = false;
                break;
            }
        }
        
        if(is_swing_high && count < ArraySize(highs))
        {
            highs[count] = current_high;
            times[count] = iTime(_Symbol, _Period, i);
            count++;
        }
    }
    
    return (count > 0);
}

//+------------------------------------------------------------------+
//| Encontrar swing lows                                            |
//+------------------------------------------------------------------+
bool CLiquidityDetector::FindSwingLows(double &lows[], datetime &times[], int &count)
{
    count = 0;
    int swing_period = 5;
    
    for(int i = swing_period; i < m_lookback_bars - swing_period; i++)
    {
        double current_low = iLow(_Symbol, _Period, i);
        bool is_swing_low = true;
        
        // Verificar se é um swing low
        for(int j = 1; j <= swing_period; j++)
        {
            if(iLow(_Symbol, _Period, i - j) <= current_low ||
               iLow(_Symbol, _Period, i + j) <= current_low)
            {
                is_swing_low = false;
                break;
            }
        }
        
        if(is_swing_low && count < ArraySize(lows))
        {
            lows[count] = current_low;
            times[count] = iTime(_Symbol, _Period, i);
            count++;
        }
    }
    
    return (count > 0);
}

//+------------------------------------------------------------------+
//| Contar toques no nível                                          |
//+------------------------------------------------------------------+
int CLiquidityDetector::CountTouches(double level, double tolerance, int start_bar, int end_bar)
{
    int touches = 0;
    
    for(int i = start_bar; i <= end_bar; i++)
    {
        double high = iHigh(_Symbol, _Period, i);
        double low = iLow(_Symbol, _Period, i);
        
        if((high >= level - tolerance && high <= level + tolerance) ||
           (low >= level - tolerance && low <= level + tolerance))
        {
            touches++;
        }
    }
    
    return touches;
}

//+------------------------------------------------------------------+
//| Calcular força da zona                                          |
//+------------------------------------------------------------------+
double CLiquidityDetector::CalculateZoneStrength(const SLiquidityZone &zone)
{
    double strength = 0.0;
    
    // Fator de toques (peso 40%)
    strength += (zone.touches * 0.4);
    
    // Fator de idade (peso 20%)
    int age_bars = iBarShift(_Symbol, _Period, zone.time_created);
    double age_factor = MathMax(0.1, 1.0 - (age_bars / 100.0));
    strength += (age_factor * 0.2);
    
    // Fator de volume (peso 40%)
    if(zone.volume_confirmation)
        strength += 0.4;
    
    return strength;
}

//+------------------------------------------------------------------+
//| Verificar se zona é válida                                      |
//+------------------------------------------------------------------+
bool CLiquidityDetector::IsZoneValid(const SLiquidityZone &zone)
{
    // Verificar número mínimo de toques
    if(zone.touches < m_min_touches)
        return false;
    
    // Verificar confirmação de volume se habilitado
    if(m_use_volume_filter && !zone.volume_confirmation)
        return false;
    
    // Verificar força mínima
    if(zone.strength < 0.3)
        return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| Verificar confirmação por volume                                 |
//+------------------------------------------------------------------+
bool CLiquidityDetector::CheckVolumeConfirmation(double level, int bar_index)
{
    if(bar_index < 0) return false;
    
    long volume = iVolume(_Symbol, _Period, bar_index);
    long avg_volume = 0;
    
    // Calcular volume médio
    for(int i = 1; i <= 20; i++)
    {
        avg_volume += iVolume(_Symbol, _Period, bar_index + i);
    }
    avg_volume /= 20;
    
    return (volume > avg_volume * 1.5);
}

//+------------------------------------------------------------------+
//| Limpar zonas antigas                                            |
//+------------------------------------------------------------------+
void CLiquidityDetector::CleanupOldZones(void)
{
    int valid_count = 0;
    
    for(int i = 0; i < m_zone_count; i++)
    {
        int age_bars = iBarShift(_Symbol, _Period, m_liquidity_zones[i].time_created);
        
        if(age_bars <= 200 && m_liquidity_zones[i].status == LIQUIDITY_STATUS_ACTIVE)
        {
            if(valid_count != i)
                m_liquidity_zones[valid_count] = m_liquidity_zones[i];
            valid_count++;
        }
    }
    
    m_zone_count = valid_count;
}

//+------------------------------------------------------------------+
//| Ordenar zonas por força                                         |
//+------------------------------------------------------------------+
void CLiquidityDetector::SortZonesByStrength(void)
{
    for(int i = 0; i < m_zone_count - 1; i++)
    {
        for(int j = 0; j < m_zone_count - 1 - i; j++)
        {
            if(m_liquidity_zones[j].strength < m_liquidity_zones[j + 1].strength)
            {
                SLiquidityZone temp = m_liquidity_zones[j];
                m_liquidity_zones[j] = m_liquidity_zones[j + 1];
                m_liquidity_zones[j + 1] = temp;
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Obter zona por índice                                           |
//+------------------------------------------------------------------+
SLiquidityZone CLiquidityDetector::GetZone(int index) const
{
    SLiquidityZone empty_zone = {0};
    
    if(index >= 0 && index < m_zone_count)
        return m_liquidity_zones[index];
    
    return empty_zone;
}

//+------------------------------------------------------------------+
//| Obter zona mais próxima                                         |
//+------------------------------------------------------------------+
SLiquidityZone CLiquidityDetector::GetNearestZone(double price, ENUM_LIQUIDITY_TYPE type = LIQUIDITY_TYPE_ANY)
{
    SLiquidityZone nearest_zone = {0};
    double min_distance = DBL_MAX;
    
    for(int i = 0; i < m_zone_count; i++)
    {
        if(type != LIQUIDITY_TYPE_ANY && m_liquidity_zones[i].type != type)
            continue;
        
        if(m_liquidity_zones[i].status != LIQUIDITY_STATUS_ACTIVE)
            continue;
        
        double distance = MathAbs(price - m_liquidity_zones[i].level);
        
        if(distance < min_distance)
        {
            min_distance = distance;
            nearest_zone = m_liquidity_zones[i];
        }
    }
    
    return nearest_zone;
}
'''
    return content

def create_market_structure_analyzer():
    """Cria a biblioteca MarketStructureAnalyzer.mqh"""
    content = '''//+------------------------------------------------------------------+
//|                                   MarketStructureAnalyzer.mqh |
//|                        Copyright 2024, TradeDev_Master Team |
//|                                   https://github.com/tradedev |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, TradeDev_Master Team"
#property link      "https://github.com/tradedev"
#property version   "1.00"
#property strict

#include "../Core/DataStructures.mqh"
#include "../Core/Interfaces.mqh"
#include "../Core/Logger.mqh"

//+------------------------------------------------------------------+
//| Market Structure Analyzer Class                                 |
//+------------------------------------------------------------------+
class CMarketStructureAnalyzer : public IAnalyzer
{
private:
    // Configurações
    int               m_structure_period;     // Período para análise
    int               m_swing_strength;       // Força dos swings
    bool              m_use_multi_timeframe;  // Usar múltiplos timeframes
    
    // Estado da estrutura
    ENUM_MARKET_STRUCTURE m_current_structure;
    ENUM_TREND_DIRECTION  m_trend_direction;
    datetime              m_last_structure_change;
    
    // Arrays de dados
    SSwingPoint       m_swing_highs[];
    SSwingPoint       m_swing_lows[];
    int               m_highs_count;
    int               m_lows_count;
    
    // Cache
    datetime          m_last_analysis;
    bool              m_cache_valid;
    
public:
    // Construtor/Destrutor
                     CMarketStructureAnalyzer(void);
                    ~CMarketStructureAnalyzer(void);
    
    // Métodos principais
    virtual bool      Initialize(void) override;
    virtual bool      Update(void) override;
    virtual void      Reset(void) override;
    
    // Configuração
    void              SetStructurePeriod(int period) { m_structure_period = period; }
    void              SetSwingStrength(int strength) { m_swing_strength = strength; }
    void              SetMultiTimeframe(bool enable) { m_use_multi_timeframe = enable; }
    
    // Análise de estrutura
    bool              AnalyzeMarketStructure(void);
    bool              DetectStructureBreak(void);
    bool              DetectTrendChange(void);
    
    // Análise de swings
    bool              FindSwingPoints(void);
    bool              ValidateSwingPoint(const SSwingPoint &swing);
    double            CalculateSwingStrength(const SSwingPoint &swing);
    
    // Getters
    ENUM_MARKET_STRUCTURE GetCurrentStructure(void) const { return m_current_structure; }
    ENUM_TREND_DIRECTION  GetTrendDirection(void) const { return m_trend_direction; }
    datetime              GetLastStructureChange(void) const { return m_last_structure_change; }
    
    // Análise de níveis
    double            GetLastHigherHigh(void);
    double            GetLastLowerLow(void);
    double            GetLastHigherLow(void);
    double            GetLastLowerHigh(void);
    
    // Confirmações
    bool              IsUptrend(void);
    bool              IsDowntrend(void);
    bool              IsRanging(void);
    bool              IsStructureIntact(void);
    
private:
    // Métodos auxiliares
    bool              IsSwingHigh(int bar_index);
    bool              IsSwingLow(int bar_index);
    ENUM_MARKET_STRUCTURE DetermineStructure(void);
    ENUM_TREND_DIRECTION  DetermineTrend(void);
    void              UpdateSwingArrays(void);
    void              CleanupOldSwings(void);
};

//+------------------------------------------------------------------+
//| Construtor                                                       |
//+------------------------------------------------------------------+
CMarketStructureAnalyzer::CMarketStructureAnalyzer(void) :
    m_structure_period(50),
    m_swing_strength(3),
    m_use_multi_timeframe(false),
    m_current_structure(MARKET_STRUCTURE_RANGING),
    m_trend_direction(TREND_DIRECTION_SIDEWAYS),
    m_last_structure_change(0),
    m_highs_count(0),
    m_lows_count(0),
    m_last_analysis(0),
    m_cache_valid(false)
{
    ArrayResize(m_swing_highs, 50);
    ArrayResize(m_swing_lows, 50);
    ArrayInitialize(m_swing_highs, 0);
    ArrayInitialize(m_swing_lows, 0);
}

//+------------------------------------------------------------------+
//| Destrutor                                                        |
//+------------------------------------------------------------------+
CMarketStructureAnalyzer::~CMarketStructureAnalyzer(void)
{
    ArrayFree(m_swing_highs);
    ArrayFree(m_swing_lows);
}

//+------------------------------------------------------------------+
//| Inicialização                                                    |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::Initialize(void)
{
    CLogger::Log(LOG_INFO, "CMarketStructureAnalyzer", "Inicializando analisador de estrutura...");
    
    if(Bars(_Symbol, _Period) < m_structure_period)
    {
        CLogger::Log(LOG_ERROR, "CMarketStructureAnalyzer", "Dados insuficientes");
        return false;
    }
    
    Reset();
    
    CLogger::Log(LOG_INFO, "CMarketStructureAnalyzer", "Analisador inicializado");
    return true;
}

//+------------------------------------------------------------------+
//| Atualização                                                      |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::Update(void)
{
    datetime current_time = TimeCurrent();
    
    if(m_cache_valid && current_time == m_last_analysis)
        return true;
    
    bool result = AnalyzeMarketStructure();
    
    if(result)
    {
        m_last_analysis = current_time;
        m_cache_valid = true;
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| Reset                                                            |
//+------------------------------------------------------------------+
void CMarketStructureAnalyzer::Reset(void)
{
    m_current_structure = MARKET_STRUCTURE_RANGING;
    m_trend_direction = TREND_DIRECTION_SIDEWAYS;
    m_last_structure_change = 0;
    m_highs_count = 0;
    m_lows_count = 0;
    m_last_analysis = 0;
    m_cache_valid = false;
    
    ArrayInitialize(m_swing_highs, 0);
    ArrayInitialize(m_swing_lows, 0);
    
    CLogger::Log(LOG_INFO, "CMarketStructureAnalyzer", "Analisador resetado");
}

//+------------------------------------------------------------------+
//| Analisar estrutura do mercado                                   |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::AnalyzeMarketStructure(void)
{
    // Encontrar pontos de swing
    if(!FindSwingPoints())
        return false;
    
    // Determinar estrutura atual
    ENUM_MARKET_STRUCTURE new_structure = DetermineStructure();
    ENUM_TREND_DIRECTION new_trend = DetermineTrend();
    
    // Verificar mudança de estrutura
    if(new_structure != m_current_structure)
    {
        m_current_structure = new_structure;
        m_last_structure_change = TimeCurrent();
        
        CLogger::Log(LOG_INFO, "CMarketStructureAnalyzer", 
                    StringFormat("Mudança de estrutura detectada: %d", (int)new_structure));
    }
    
    m_trend_direction = new_trend;
    
    // Limpar swings antigos
    CleanupOldSwings();
    
    return true;
}

//+------------------------------------------------------------------+
//| Encontrar pontos de swing                                       |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::FindSwingPoints(void)
{
    m_highs_count = 0;
    m_lows_count = 0;
    
    for(int i = m_swing_strength; i < m_structure_period - m_swing_strength; i++)
    {
        // Verificar swing high
        if(IsSwingHigh(i))
        {
            if(m_highs_count < ArraySize(m_swing_highs))
            {
                SSwingPoint swing;
                swing.price = iHigh(_Symbol, _Period, i);
                swing.time = iTime(_Symbol, _Period, i);
                swing.bar_index = i;
                swing.type = SWING_TYPE_HIGH;
                swing.strength = CalculateSwingStrength(swing);
                swing.confirmed = true;
                
                if(ValidateSwingPoint(swing))
                {
                    m_swing_highs[m_highs_count] = swing;
                    m_highs_count++;
                }
            }
        }
        
        // Verificar swing low
        if(IsSwingLow(i))
        {
            if(m_lows_count < ArraySize(m_swing_lows))
            {
                SSwingPoint swing;
                swing.price = iLow(_Symbol, _Period, i);
                swing.time = iTime(_Symbol, _Period, i);
                swing.bar_index = i;
                swing.type = SWING_TYPE_LOW;
                swing.strength = CalculateSwingStrength(swing);
                swing.confirmed = true;
                
                if(ValidateSwingPoint(swing))
                {
                    m_swing_lows[m_lows_count] = swing;
                    m_lows_count++;
                }
            }
        }
    }
    
    return (m_highs_count > 0 || m_lows_count > 0);
}

//+------------------------------------------------------------------+
//| Verificar se é swing high                                       |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::IsSwingHigh(int bar_index)
{
    double current_high = iHigh(_Symbol, _Period, bar_index);
    
    // Verificar barras à esquerda e direita
    for(int i = 1; i <= m_swing_strength; i++)
    {
        if(iHigh(_Symbol, _Period, bar_index - i) >= current_high ||
           iHigh(_Symbol, _Period, bar_index + i) >= current_high)
        {
            return false;
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Verificar se é swing low                                        |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::IsSwingLow(int bar_index)
{
    double current_low = iLow(_Symbol, _Period, bar_index);
    
    // Verificar barras à esquerda e direita
    for(int i = 1; i <= m_swing_strength; i++)
    {
        if(iLow(_Symbol, _Period, bar_index - i) <= current_low ||
           iLow(_Symbol, _Period, bar_index + i) <= current_low)
        {
            return false;
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Determinar estrutura do mercado                                 |
//+------------------------------------------------------------------+
ENUM_MARKET_STRUCTURE CMarketStructureAnalyzer::DetermineStructure(void)
{
    if(m_highs_count < 2 || m_lows_count < 2)
        return MARKET_STRUCTURE_RANGING;
    
    // Analisar últimos 2 highs e lows
    bool higher_highs = (m_swing_highs[0].price > m_swing_highs[1].price);
    bool higher_lows = (m_swing_lows[0].price > m_swing_lows[1].price);
    bool lower_highs = (m_swing_highs[0].price < m_swing_highs[1].price);
    bool lower_lows = (m_swing_lows[0].price < m_swing_lows[1].price);
    
    if(higher_highs && higher_lows)
        return MARKET_STRUCTURE_UPTREND;
    else if(lower_highs && lower_lows)
        return MARKET_STRUCTURE_DOWNTREND;
    else
        return MARKET_STRUCTURE_RANGING;
}

//+------------------------------------------------------------------+
//| Determinar direção da tendência                                 |
//+------------------------------------------------------------------+
ENUM_TREND_DIRECTION CMarketStructureAnalyzer::DetermineTrend(void)
{
    switch(m_current_structure)
    {
        case MARKET_STRUCTURE_UPTREND:
            return TREND_DIRECTION_UP;
        case MARKET_STRUCTURE_DOWNTREND:
            return TREND_DIRECTION_DOWN;
        default:
            return TREND_DIRECTION_SIDEWAYS;
    }
}

//+------------------------------------------------------------------+
//| Validar ponto de swing                                          |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::ValidateSwingPoint(const SSwingPoint &swing)
{
    // Verificar força mínima
    if(swing.strength < 0.5)
        return false;
    
    // Verificar se não é muito próximo de outro swing
    if(swing.type == SWING_TYPE_HIGH)
    {
        for(int i = 0; i < m_highs_count; i++)
        {
            if(MathAbs(swing.price - m_swing_highs[i].price) < 10 * _Point)
                return false;
        }
    }
    else
    {
        for(int i = 0; i < m_lows_count; i++)
        {
            if(MathAbs(swing.price - m_swing_lows[i].price) < 10 * _Point)
                return false;
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Calcular força do swing                                         |
//+------------------------------------------------------------------+
double CMarketStructureAnalyzer::CalculateSwingStrength(const SSwingPoint &swing)
{
    double atr = iATR(_Symbol, _Period, 14, swing.bar_index);
    if(atr <= 0) return 1.0;
    
    double range = 0.0;
    
    if(swing.type == SWING_TYPE_HIGH)
    {
        // Calcular range do swing high
        double lowest = DBL_MAX;
        for(int i = swing.bar_index - m_swing_strength; i <= swing.bar_index + m_swing_strength; i++)
        {
            double low = iLow(_Symbol, _Period, i);
            if(low < lowest) lowest = low;
        }
        range = swing.price - lowest;
    }
    else
    {
        // Calcular range do swing low
        double highest = 0.0;
        for(int i = swing.bar_index - m_swing_strength; i <= swing.bar_index + m_swing_strength; i++)
        {
            double high = iHigh(_Symbol, _Period, i);
            if(high > highest) highest = high;
        }
        range = highest - swing.price;
    }
    
    return range / atr;
}

//+------------------------------------------------------------------+
//| Limpar swings antigos                                           |
//+------------------------------------------------------------------+
void CMarketStructureAnalyzer::CleanupOldSwings(void)
{
    // Manter apenas os últimos 20 swings de cada tipo
    if(m_highs_count > 20)
        m_highs_count = 20;
    
    if(m_lows_count > 20)
        m_lows_count = 20;
}

//+------------------------------------------------------------------+
//| Obter último higher high                                        |
//+------------------------------------------------------------------+
double CMarketStructureAnalyzer::GetLastHigherHigh(void)
{
    if(m_highs_count < 2) return 0.0;
    
    for(int i = 0; i < m_highs_count - 1; i++)
    {
        if(m_swing_highs[i].price > m_swing_highs[i + 1].price)
            return m_swing_highs[i].price;
    }
    
    return 0.0;
}

//+------------------------------------------------------------------+
//| Obter último lower low                                          |
//+------------------------------------------------------------------+
double CMarketStructureAnalyzer::GetLastLowerLow(void)
{
    if(m_lows_count < 2) return 0.0;
    
    for(int i = 0; i < m_lows_count - 1; i++)
    {
        if(m_swing_lows[i].price < m_swing_lows[i + 1].price)
            return m_swing_lows[i].price;
    }
    
    return 0.0;
}

//+------------------------------------------------------------------+
//| Verificar se está em uptrend                                    |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::IsUptrend(void)
{
    return (m_current_structure == MARKET_STRUCTURE_UPTREND);
}

//+------------------------------------------------------------------+
//| Verificar se está em downtrend                                  |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::IsDowntrend(void)
{
    return (m_current_structure == MARKET_STRUCTURE_DOWNTREND);
}

//+------------------------------------------------------------------+
//| Verificar se está em range                                      |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::IsRanging(void)
{
    return (m_current_structure == MARKET_STRUCTURE_RANGING);
}
'''
    return content

def main():
    """Função principal"""
    print("=== TradeDev_Master - Criação das Bibliotecas ICT/SMC Restantes ===")
    
    # Definir caminhos
    project_root = Path(r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD")
    source_dir = project_root / "EA_FTMO_SCALPER_ELITE" / "MQL5_Source" / "Source" / "ICT"
    
    # Criar diretório se não existir
    source_dir.mkdir(parents=True, exist_ok=True)
    
    libraries = {
        "FVGDetector.mqh": create_fvg_detector(),
        "LiquidityDetector.mqh": create_liquidity_detector(),
        "MarketStructureAnalyzer.mqh": create_market_structure_analyzer()
    }
    
    created_count = 0
    
    for filename, content in libraries.items():
        file_path = source_dir / filename
        
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            print(f"✓ Criado: {filename}")
            created_count += 1
            
        except Exception as e:
            print(f"✗ Erro ao criar {filename}: {e}")
    
    print(f"\n=== Resumo ===")
    print(f"Bibliotecas ICT/SMC criadas: {created_count}/{len(libraries)}")
    print(f"Diretório: {source_dir}")
    
    if created_count == len(libraries):
        print("\n🎉 Todas as bibliotecas ICT/SMC foram criadas com sucesso!")
    else:
        print(f"\n⚠️ {len(libraries) - created_count} bibliotecas falharam")

if __name__ == "__main__":
    main()