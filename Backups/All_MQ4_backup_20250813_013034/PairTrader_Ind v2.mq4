//+------------------------------------------------------------------+
//|                                           PairTrader_Ind v.2.mq4 |
//|                                   Copyright © 2012, Mr.SilverKZ  |
//|                                                silverkz@@mail.kz |
//+------------------------------------------------------------------+
#property indicator_separate_window 
#property indicator_buffers 4       
#property indicator_color1 Blue
#property indicator_color2 Red    
#property indicator_color3 Blue
#property indicator_color4 Red  
//--------------------------------------------------------------------
extern string  Symbol_1  = "EURUSD"; // Финансовый инструмент №1
extern string  Symbol_2  = "GBPUSD"; // Финансовый инструмент №2
extern bool    Revers    = false;     // true  - отрицательная корреляция  
                                     // false - положительная корреляция 
extern int     Fast_MA   = 8;        // Период быстрой МА
extern int     Slow_MA   = 21;       // Период медленной МА
extern int     MA_Method = 2;        // Метод расчета МА
                                     // - MODE_SMA=0 Простое скользящее среднее 
                                     // - MODE_EMA=1 Экспоненциальное скользящее среднее 
                                     // - MODE_SMMA=2 Сглаженное скользящее среднее 
                                     // - MODE_LWMA=3 Линейно-взвешенное скользящее среднее 
extern int     MA_Price  = 6;        // Расчетная цена:
                                     // - PRICE_CLOSE=0 Цена закрытия 
                                     // - PRICE_OPEN=1 Цена открытия 
                                     // - PRICE_HIGH=2 Максимальная цена 
                                     // - PRICE_LOW=3 Минимальная цена 
                                     // - PRICE_MEDIAN=4 Средняя цена, (high+low)/2 
                                     // - PRICE_TYPICAL=5 Типичная цена, (high+low+close)/3 
                                     // - PRICE_WEIGHTED=6 Взвешенная цена закрытия, (high+low+close+close)/4 
extern int     Delta     = 20;       // Размер раздвижки в пунктах
extern double  Lot       = 0.1;      // Базовый лот
extern int     VOL_Mode  = 2;        // Режим расчета объемов для торговли
                                     //   1 - базовый лот по обоим инструментам
                                     //   2 - по ценам открытия
                                     //   3 - по волатильности 
extern int     PeriodATR = 144;      // Период усреднения ATR для расчета объемов торговли 
//--------------------------------------------------------------------
double Spread_Buf[],Buf_Up[],Buf_Dw[],Symbol1_Buf[],Symbol2_Buf[]; 
double CurrentPoint1, CurrentPoint2, ZeroClose1, ZeroClose2;
string Text_1,Text_2,Text_3;  
double Lots_1, Lots_2;  
double kVol1, kVol2;        
//--------------------------------------------------------------------
int init()                        
  {
   IndicatorBuffers(5);
   IndicatorDigits(Digits);
//--------------------------------------------------------------------
   SetIndexBuffer(0,Symbol1_Buf);         
   SetIndexStyle (0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexLabel (0,Symbol_1); 
//--------------------------------------------------------------------
   SetIndexBuffer(1,Symbol2_Buf);         
   SetIndexStyle (1,DRAW_LINE,STYLE_SOLID,2);
   SetIndexLabel (1,Symbol_2);
//--------------------------------------------------------------------
   SetIndexBuffer(2,Buf_Up);         
   SetIndexStyle (2,DRAW_HISTOGRAM,STYLE_SOLID,1);
   SetIndexLabel (2,"Spread"); 
//--------------------------------------------------------------------
   SetIndexBuffer(3,Buf_Dw);         
   SetIndexStyle (3,DRAW_HISTOGRAM,STYLE_SOLID,1);
   SetIndexLabel (3,"Spread");
//--------------------------------------------------------------------
   SetIndexBuffer(4,Spread_Buf);         
//--------------------------------------------------------------------
   SetLevelStyle (STYLE_DOT,1,Red);
   SetLevelValue (0,0);
   SetLevelValue (1,Delta);
   SetLevelValue (2,-Delta);
   SetLevelValue (3,Delta*2);
   SetLevelValue (4,-Delta*2);
   SetLevelValue (5,Delta*3);
   SetLevelValue (6,-Delta*3);
//-------------------------------------------------------------------- 
   Create_RSI();
   return;                          
  }
//--------------------------------------------------------------------
double MACD(string symbol, int i) 
  {
   double Vol = (iMA(symbol,0,Fast_MA,0,MA_Method,MA_Price,i)-
                 iMA(symbol,0,Slow_MA,0,MA_Method,MA_Price,i)) / MarketInfo(symbol, MODE_POINT);
   return (Vol);
  }
//--------------------------------------------------------------------
int start()                         
  {
   int i, Counted_bars;  
//--------------------------------------------------------------------
   CurrentPoint1 = 0;
   CurrentPoint2 = 0; 
   kVol1=MarketInfo(Symbol_1, MODE_TICKVALUE)/MarketInfo(Symbol_1, MODE_TICKSIZE);
   kVol2=MarketInfo(Symbol_2, MODE_TICKVALUE)/MarketInfo(Symbol_2, MODE_TICKSIZE);
   Counted_bars=IndicatorCounted(); 
   i=Bars-Counted_bars-1;           
   while(i>=0)                     
     {
      Symbol1_Buf[i] = MACD (Symbol_1, iBarShift(Symbol_1, 0, Time[i], FALSE));
      if(Revers) Symbol2_Buf[i] = -1*MACD (Symbol_2, iBarShift(Symbol_2, 0, Time[i], FALSE));
      else Symbol2_Buf[i] = MACD (Symbol_2, iBarShift(Symbol_2, 0, Time[i], FALSE));
      
      if((Symbol1_Buf[i+1]>Symbol2_Buf[i+1] && Symbol1_Buf[i+2]<=Symbol2_Buf[i+2]) ||
         (Symbol1_Buf[i+1]<Symbol2_Buf[i+1] && Symbol1_Buf[i+2]>=Symbol2_Buf[i+2]))
         {
          CurrentPoint1 = 0;
          CurrentPoint2 = 0;
          ZeroClose1 = iClose(Symbol_1,Period(),iBarShift(Symbol_1,0,Time[i+1]));
          ZeroClose2 = iClose(Symbol_2,Period(),iBarShift(Symbol_2,0,Time[i+1]));         
         }
      
      CurrentPoint1 = iClose(Symbol_1,Period(),iBarShift(Symbol_1,0,Time[i])) - ZeroClose1;
      if(Revers) CurrentPoint2 = -1*(iClose(Symbol_2,Period(),iBarShift(Symbol_2,0,Time[i])) - ZeroClose2);
      else CurrentPoint2 = iClose(Symbol_2,Period(),iBarShift(Symbol_2,0,Time[i])) - ZeroClose2;

      Spread_Buf[i]  = (CurrentPoint1 / MarketInfo(Symbol_1, MODE_POINT) - CurrentPoint2 / MarketInfo(Symbol_2, MODE_POINT));
                              
      Buf_Up[i] = Spread_Buf[i];     
      Buf_Dw[i] = Spread_Buf[i];  
      if(Spread_Buf[i] < Spread_Buf[i+1]) Buf_Up[i] = EMPTY_VALUE;
      if(Spread_Buf[i] > Spread_Buf[i+1]) Buf_Dw[i] = EMPTY_VALUE; 
      i--;                          
     }
   
   CountLots();
   if(Symbol1_Buf[1]>Symbol2_Buf[1]) 
      {
       Text_1 = Symbol_1+" Sell "+DoubleToStr(Lots_1,2);
       if(Revers)Text_2 = Symbol_2+" Sell "+DoubleToStr(Lots_2,2);
       else Text_2 = Symbol_2+" Buy "+DoubleToStr(Lots_2,2);
      }
   if(Symbol1_Buf[1]<Symbol2_Buf[1]) 
      {
       Text_1 = Symbol_1+" Buy "+DoubleToStr(Lots_1,2);
       if(Revers)Text_2 = Symbol_2+" Buy "+DoubleToStr(Lots_2,2);
       else Text_2 = Symbol_2+" Sell "+DoubleToStr(Lots_2,2);
       
       
       
      }
   Text_3 = "Spread = " + DoubleToStr(CurrentPoint1/MarketInfo(Symbol_1, MODE_POINT)- 
                                      CurrentPoint2/MarketInfo(Symbol_2, MODE_POINT),0);  
      
   ObjectSetText(WindowExpertName()+"1",Text_1,11,"Verdana",indicator_color1);
   ObjectSetText(WindowExpertName()+"2",Text_2,11,"Verdana",indicator_color2);
   ObjectSetText(WindowExpertName()+"3",Text_3,11,"Verdana",DarkGreen);
//--------------------------------------------------------------------
   return;                          
  }
//--------------------------------------------------------------------
int deinit()                   
  {
   ObjectDelete("Obj_RSI_1");   
   ObjectDelete("Obj_RSI_2");  
   ObjectDelete("Obj_RSI_3");      
   return;                             
  }
//-------------------------------------------------------------------- 
int Create_RSI()                        
  {                                             
   ObjectCreate(WindowExpertName()+"1",OBJ_LABEL, WindowFind(WindowExpertName()), 0, 0); 
   ObjectSet(WindowExpertName()+"1",   OBJPROP_CORNER, 1);     
   ObjectSet(WindowExpertName()+"1",   OBJPROP_XDISTANCE, 5);  
   ObjectSet(WindowExpertName()+"1",   OBJPROP_YDISTANCE,20);  
   
   ObjectCreate(WindowExpertName()+"2",OBJ_LABEL, WindowFind(WindowExpertName()), 0, 0); 
   ObjectSet(WindowExpertName()+"2",   OBJPROP_CORNER, 1);     
   ObjectSet(WindowExpertName()+"2",   OBJPROP_XDISTANCE, 5);  
   ObjectSet(WindowExpertName()+"2",   OBJPROP_YDISTANCE,40);
   
   ObjectCreate(WindowExpertName()+"3",OBJ_LABEL, WindowFind(WindowExpertName()), 0, 0); 
   ObjectSet(WindowExpertName()+"3",   OBJPROP_CORNER, 1);     
   ObjectSet(WindowExpertName()+"3",   OBJPROP_XDISTANCE, 5);  
   ObjectSet(WindowExpertName()+"3",   OBJPROP_YDISTANCE,60);   
    
   WindowRedraw();
  }
//------------------------------------------------------------------
void CountLots()
  {
   Lots_1 = Lot;
   if(VOL_Mode==1)
     {
      Lots_2 = Lot; 
     }  
   if(VOL_Mode==2) 
     {
      Lots_2 = (Lots_1*kVol1*iOpen(Symbol_1,0,0))/kVol2/iOpen(Symbol_2,0,0);
     } 
   if(VOL_Mode==3)
     {
      Lots_2 = (Lots_1*kVol1*iATR(Symbol_1,0,PeriodATR,1))/kVol2/iATR(Symbol_2,0,PeriodATR,1);
     }
 }
//-------------------------------------------------------------------- 