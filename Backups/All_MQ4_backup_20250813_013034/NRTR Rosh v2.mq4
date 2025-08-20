//+------------------------------------------------------------------+
//|                                                 NRTR Rosh v2.mq4 |
//|                                                             Rosh |
//|                           http://forexsystems.ru/phpBB/index.php |
//+------------------------------------------------------------------+
#property copyright "Rosh"
#property link      "http://forexsystems.ru/phpBB/index.php"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Tomato
#property indicator_color2 DeepSkyBlue
#property indicator_color3 DeepSkyBlue
#property indicator_color4 Tomato
//---- input parameters
extern int       PerATR=40;
extern double    kATR=2.0;
//---- buffers
double SellBuffer[];
double BuyBuffer[];
double Ceil[];
double Floor[];
double Trend[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(5);

   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,251);
   SetIndexBuffer(0,SellBuffer);
   SetIndexEmptyValue(0,0.0);
   SetIndexLabel(0,"SellLimit");
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,251);
   SetIndexBuffer(1,BuyBuffer);
   SetIndexEmptyValue(1,0.0);
   SetIndexLabel(1,"BuyLimit");

   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,159);
   SetIndexBuffer(2,Ceil);
   SetIndexEmptyValue(2,0.0);
   SetIndexLabel(2,"Ceil");

   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,159);
   SetIndexBuffer(3,Floor);
   SetIndexEmptyValue(3,0.0);
   SetIndexLabel(3,"Floor");

   SetIndexBuffer(4,Trend);   
   SetIndexEmptyValue(4,0);
   //----
   return(0);
  }
//+------------------------------------------------------------------+
//| пробитие верха ƒј”Ќтренда                              |
//+------------------------------------------------------------------+
bool BreakDown(int shift)
  {
   bool result=false;
   if (Close[shift]>SellBuffer[shift+1]) result=true;
   return(result);
  }

//+------------------------------------------------------------------+
//| пробитие дна јѕтренда                              |
//+------------------------------------------------------------------+
bool BreakUp(int shift)
  {
   bool result=false;
   if (Close[shift]<BuyBuffer[shift+1]) result=true;
   return(result);
  }

//+------------------------------------------------------------------+
//| вз€тие нового минимума по ƒј”Ќтренду                             |
//+------------------------------------------------------------------+
bool BreakFloor(int shift)
  {
   bool result=false;
   if (High[shift]<Floor[shift+1]) result=true;
   return(result);
  }

//+------------------------------------------------------------------+
//| вз€тие нового максимума по јѕтренду                              |
//+------------------------------------------------------------------+
bool BreakCeil(int shift)
  {
   bool result=false;
   if (Low[shift]>Ceil[shift+1]) result=true;
   return(result);
  }

//+------------------------------------------------------------------+
//| определение предыдущего тренда                                   |
//+------------------------------------------------------------------+
bool Uptrend(int shift)
  {
   //Print("Trend=",Trend[shift+1]);
   bool result=false;
   if (Trend[shift+1]==1) result=true;
   if (Trend[shift+1]==-1) result=false;
   if ((Trend[shift+1]!=1)&&(Trend[shift+1]!=-1)) Print("¬нимание! “ренд не определен, такого быть не может. Ѕар от конца ",(Bars-shift));
   return(result);
  }

//+------------------------------------------------------------------+
//| вычисление волатильности                                         |
//+------------------------------------------------------------------+
double ATR(int iPer,int shift)
  {
   double result;
   //result=iMA(NULL,0,Per,0,MODE_SMA,PRICE_HIGH,shift+1)-iMA(NULL,0,Per,0,MODE_SMA,PRICE_LOW,shift+1);
   result=iATR(NULL,0,iPer,shift);
   //if (result>1.0) Alert("Ѕольшой ј“–=",result);
   //Print("ATR[",shift,"]=",result);
   return(result);
  }
//+------------------------------------------------------------------+
//| установка нового уровн€ потолка                                  |
//+------------------------------------------------------------------+
void NewCeil(int shift)
  {
   Ceil[shift]=Close[shift];
   Floor[shift]=0.0;
  }

//+------------------------------------------------------------------+
//| установка нового уровн€ пола                                     |
//+------------------------------------------------------------------+
void NewFloor(int shift)
  {
   Floor[shift]=Close[shift];
   Ceil[shift]=0.0;
  }

//+------------------------------------------------------------------+
//| установка уровн€ поддержки јѕтренда                              |
//+------------------------------------------------------------------+
void SetBuyBuffer(int shift)
  {
   BuyBuffer[shift]=Close[shift]-kATR*ATR(PerATR,shift);
   SellBuffer[shift]=0.0;
  }

//+------------------------------------------------------------------+
//| установка уровн€ поддержки ƒј”Ќтренда                            |
//+------------------------------------------------------------------+
void SetSellBuffer(int shift)
  {
   SellBuffer[shift]=Close[shift]+kATR*ATR(PerATR,shift);
   BuyBuffer[shift]=0.0;
  }

//+------------------------------------------------------------------+
//| реверс тренда и установка новых уровней                          |
//+------------------------------------------------------------------+
void NewTrend(int shift)
  {
   if (Trend[shift+1]==1) 
      {
      Trend[shift]=-1;
      NewFloor(shift);
      SetSellBuffer(shift);
      }
   else 
      {
      Trend[shift]=1;
      NewCeil(shift);
      SetBuyBuffer(shift);
      }
   if ((Trend[shift+1]!=1)&&(Trend[shift+1]!=-1)) Print("¬нимание! “ренд не определен, такого быть не может");
  }

//+------------------------------------------------------------------+
//| продолжение тренда                                               |
//+------------------------------------------------------------------+
void CopyLastValues(int shift)
  {
   SellBuffer[shift]=SellBuffer[shift+1];
   BuyBuffer[shift]=BuyBuffer[shift+1];
   Ceil[shift]=Ceil[shift+1];
   Floor[shift]=Floor[shift+1];
   Trend[shift]=Trend[shift+1];
  }

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int limit;
   if (counted_bars>0) limit=Bars-counted_bars;
   if (counted_bars<0) return(0);
   if (counted_bars==0) 
      {
      limit=Bars-PerATR-1;
      if (Close[limit+1]>Open[limit+1]) {Trend[limit+1]=1;Ceil[limit+1]=Close[limit+1];BuyBuffer[limit+1]=Close[limit+1]-kATR*ATR(PerATR,limit+1);}
      if (Close[limit+1]<Open[limit+1]) {Trend[limit+1]=-1;Floor[limit+1]=Close[limit+1];SellBuffer[limit+1]=Close[limit+1]+kATR*ATR(PerATR,limit+1);}
      if (Close[limit+1]==Open[limit+1]) {Trend[limit+1]=1;Ceil[limit+1]=Close[limit+1];BuyBuffer[limit+1]=Close[limit+1]-kATR*ATR(PerATR,limit+1);}
      }
//----
   for (int cnt=limit;cnt>=0;cnt--)
      {
      if (Uptrend(cnt))
         {
         //Print("UpTrend");
         if (BreakCeil(cnt))
            {
            NewCeil(cnt);
            SetBuyBuffer(cnt);
            Trend[cnt]=1;
            continue;
            }
         if (BreakUp(cnt))
            {
            NewTrend(cnt);
            continue;
            }   
         CopyLastValues(cnt);
         }
      else
         {
         //Print("DownTrend");
         if (BreakFloor(cnt))
            {
            NewFloor(cnt);
            SetSellBuffer(cnt);
            Trend[cnt]=-1;
            continue;
            }
         if (BreakDown(cnt))
            {
            NewTrend(cnt);
            continue;
            }   
         CopyLastValues(cnt);
         }
      } 

//----
   return(0);
  }
//+------------------------------------------------------------------+