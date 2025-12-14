#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para Criação de Bibliotecas ICT/SMC
TradeDev_Master - Sistema de Análise de Estrutura de Mercado
"""

import os
from pathlib import Path

class ICTLibraryGenerator:
    def __init__(self, project_root):
        self.project_root = Path(project_root)
        self.source_dir = self.project_root / "EA_FTMO_SCALPER_ELITE" / "MQL5_Source" / "Source"
        
    def create_order_block_detector(self):
        """Cria OrderBlockDetector.mqh"""
        return '''
//+------------------------------------------------------------------+
//|                                        OrderBlockDetector.mqh |
//|                        TradeDev_Master Elite Trading System     |
//|                                   ICT Order Block Detection     |
//+------------------------------------------------------------------+

#ifndef ORDER_BLOCK_DETECTOR_MQH
#define ORDER_BLOCK_DETECTOR_MQH

#include "../Core/Interfaces.mqh"
#include "../Core/DataStructures.mqh"

class COrderBlockDetector : public IOrderBlockDetector
{
private:
   SOrderBlock m_order_blocks[];
   int m_ob_count;
   int m_lookback_bars;
   double m_min_body_size;
   double m_min_volume_ratio;
   bool m_initialized;
   
public:
   COrderBlockDetector(int lookback = 500, double min_body = 0.0001, double min_volume = 1.5)
   {
      m_lookback_bars = lookback;
      m_min_body_size = min_body;
      m_min_volume_ratio = min_volume;
      m_ob_count = 0;
      m_initialized = false;
      ArrayResize(m_order_blocks, 100);
   }
   
   virtual bool Initialize() override
   {
      m_initialized = true;
      return true;
   }
   
   virtual bool Update() override
   {
      if(!m_initialized) return false;
      
      DetectOrderBlocks();
      ValidateOrderBlocks();
      return true;
   }
   
   virtual void Reset() override
   {
      m_ob_count = 0;
      ArrayResize(m_order_blocks, 100);
   }
   
   virtual bool IsValid() override
   {
      return m_initialized;
   }
   
   virtual string GetStatus() override
   {
      return StringFormat("OrderBlocks: %d detected, Initialized: %s", 
                         m_ob_count, m_initialized ? "Yes" : "No");
   }
   
   virtual SOrderBlock[] GetOrderBlocks() override
   {
      SOrderBlock result[];
      ArrayResize(result, m_ob_count);
      for(int i = 0; i < m_ob_count; i++)
      {
         result[i] = m_order_blocks[i];
      }
      return result;
   }
   
   virtual bool IsOrderBlockValid(SOrderBlock &ob) override
   {
      if(!ob.is_valid) return false;
      if(ob.is_mitigated) return false;
      if(TimeCurrent() - ob.time_start > 86400 * 7) return false; // 7 days max
      return true;
   }
   
   virtual double GetOrderBlockStrength(SOrderBlock &ob) override
   {
      double strength = 0;
      
      // Volume strength (0-30 points)
      if(ob.volume > 0)
      {
         double avg_volume = GetAverageVolume(50);
         if(avg_volume > 0)
         {
            double volume_ratio = ob.volume / avg_volume;
            strength += MathMin(volume_ratio * 10, 30);
         }
      }
      
      // Body size strength (0-25 points)
      double body_size = MathAbs(ob.close - ob.open);
      double atr = GetATR(14);
      if(atr > 0)
      {
         double body_ratio = body_size / atr;
         strength += MathMin(body_ratio * 12.5, 25);
      }
      
      // Time strength (0-20 points)
      int hours_old = (int)((TimeCurrent() - ob.time_start) / 3600);
      if(hours_old < 24)
         strength += 20 - (hours_old * 20 / 24);
      
      // Test count penalty (0-15 points)
      strength += MathMax(15 - (ob.test_count * 3), 0);
      
      // Structure strength (0-10 points)
      if(IsAtStructuralLevel(ob))
         strength += 10;
      
      return MathMin(strength, 100);
   }
   
private:
   void DetectOrderBlocks()
   {
      int bars = MathMin(m_lookback_bars, Bars(_Symbol, PERIOD_CURRENT));
      
      for(int i = 3; i < bars - 1; i++)
      {
         if(IsBullishOrderBlock(i))
         {
            CreateOrderBlock(i, OB_BULLISH);
         }
         
         if(IsBearishOrderBlock(i))
         {
            CreateOrderBlock(i, OB_BEARISH);
         }
      }
   }
   
   bool IsBullishOrderBlock(int index)
   {
      double open1 = iOpen(_Symbol, PERIOD_CURRENT, index);
      double close1 = iClose(_Symbol, PERIOD_CURRENT, index);
      double high1 = iHigh(_Symbol, PERIOD_CURRENT, index);
      double low1 = iLow(_Symbol, PERIOD_CURRENT, index);
      
      double close2 = iClose(_Symbol, PERIOD_CURRENT, index - 1);
      double high2 = iHigh(_Symbol, PERIOD_CURRENT, index - 1);
      
      if(close1 >= open1) return false;
      if(close2 <= high1) return false;
      
      double body_size = MathAbs(close1 - open1);
      if(body_size < m_min_body_size) return false;
      
      return true;
   }
   
   bool IsBearishOrderBlock(int index)
   {
      double open1 = iOpen(_Symbol, PERIOD_CURRENT, index);
      double close1 = iClose(_Symbol, PERIOD_CURRENT, index);
      double low1 = iLow(_Symbol, PERIOD_CURRENT, index);
      
      double close2 = iClose(_Symbol, PERIOD_CURRENT, index - 1);
      double low2 = iLow(_Symbol, PERIOD_CURRENT, index - 1);
      
      if(close1 <= open1) return false;
      if(close2 >= low1) return false;
      
      double body_size = MathAbs(close1 - open1);
      if(body_size < m_min_body_size) return false;
      
      return true;
   }
   
   void CreateOrderBlock(int index, ENUM_ORDER_BLOCK_TYPE type)
   {
      if(m_ob_count >= ArraySize(m_order_blocks))
      {
         ArrayResize(m_order_blocks, ArraySize(m_order_blocks) + 50);
      }
      
      SOrderBlock ob;
      ob.time_start = iTime(_Symbol, PERIOD_CURRENT, index);
      ob.time_end = ob.time_start + PeriodSeconds(PERIOD_CURRENT);
      ob.open = iOpen(_Symbol, PERIOD_CURRENT, index);
      ob.close = iClose(_Symbol, PERIOD_CURRENT, index);
      ob.high = iHigh(_Symbol, PERIOD_CURRENT, index);
      ob.low = iLow(_Symbol, PERIOD_CURRENT, index);
      ob.volume = (double)iVolume(_Symbol, PERIOD_CURRENT, index);
      ob.type = type;
      ob.is_valid = true;
      ob.is_mitigated = false;
      ob.strength = 0;
      ob.mitigation_percentage = 0;
      ob.last_test_time = 0;
      ob.test_count = 0;
      
      m_order_blocks[m_ob_count] = ob;
      m_ob_count++;
   }
   
   void ValidateOrderBlocks()
   {
      double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      for(int i = 0; i < m_ob_count; i++)
      {
         if(!m_order_blocks[i].is_valid) continue;
         
         if(m_order_blocks[i].type == OB_BULLISH)
         {
            if(current_price <= m_order_blocks[i].low)
            {
               m_order_blocks[i].mitigation_percentage = 100;
               m_order_blocks[i].is_mitigated = true;
            }
         }
         else if(m_order_blocks[i].type == OB_BEARISH)
         {
            if(current_price >= m_order_blocks[i].high)
            {
               m_order_blocks[i].mitigation_percentage = 100;
               m_order_blocks[i].is_mitigated = true;
            }
         }
         
         m_order_blocks[i].strength = (int)GetOrderBlockStrength(m_order_blocks[i]);
      }
   }
   
   double GetAverageVolume(int period, int start_index = 1)
   {
      double sum = 0;
      int count = 0;
      
      for(int i = start_index; i < start_index + period; i++)
      {
         long volume = iVolume(_Symbol, PERIOD_CURRENT, i);
         if(volume > 0)
         {
            sum += volume;
            count++;
         }
      }
      
      return count > 0 ? sum / count : 0;
   }
   
   double GetATR(int period)
   {
      int atr_handle = iATR(_Symbol, PERIOD_CURRENT, period);
      if(atr_handle == INVALID_HANDLE) return 0;
      
      double atr_buffer[];
      if(CopyBuffer(atr_handle, 0, 0, 1, atr_buffer) <= 0) return 0;
      
      return atr_buffer[0];
   }
   
   bool IsAtStructuralLevel(SOrderBlock &ob)
   {
      double ob_center = (ob.high + ob.low) / 2;
      
      for(int i = 1; i <= 100; i++)
      {
         double high = iHigh(_Symbol, PERIOD_CURRENT, i);
         double low = iLow(_Symbol, PERIOD_CURRENT, i);
         
         if(MathAbs(ob_center - high) < Point() * 10 || 
            MathAbs(ob_center - low) < Point() * 10)
         {
            return true;
         }
      }
      
      return false;
   }
};

#endif // ORDER_BLOCK_DETECTOR_MQH
'''
        
    def run(self):
        """Executa a criação de todas as bibliotecas ICT/SMC"""
        print("=== TradeDev_Master - Criação de Bibliotecas ICT/SMC ===")
        
        # Criar diretório ICT se não existir
        ict_dir = self.source_dir / "ICT"
        ict_dir.mkdir(parents=True, exist_ok=True)
        
        libraries = {
            "OrderBlockDetector.mqh": self.create_order_block_detector()
        }
        
        created_count = 0
        for filename, content in libraries.items():
            file_path = ict_dir / filename
            try:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"✓ Criado: {filename}")
                created_count += 1
            except Exception as e:
                print(f"✗ Erro ao criar {filename}: {e}")
        
        print(f"\n=== Resumo ===")
        print(f"Bibliotecas ICT/SMC criadas: {created_count}/1")
        print(f"Diretório: {ict_dir}")
        
        return created_count == 1

def main():
    """Função principal"""
    project_root = Path(__file__).parent.parent
    generator = ICTLibraryGenerator(project_root)
    
    success = generator.run()
    
    if success:
        print("\n🎉 Biblioteca OrderBlockDetector criada com sucesso!")
    else:
        print("\n⚠️ Erro ao criar biblioteca.")
    
    return success

if __name__ == "__main__":
    main()