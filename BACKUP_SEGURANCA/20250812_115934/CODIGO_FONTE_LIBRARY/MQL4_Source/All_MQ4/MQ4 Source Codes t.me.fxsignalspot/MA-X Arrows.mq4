//+------------------------------------------------------------------+
//|                                                  MA-X Arrows.mq4 |
//|                                        Copyright © 2012, FXTools |
//|                                                 www.fxtools.info |             
//+------------------------------------------------------------------+
#property copyright "© FXTools"
#property link "http://www.fxtools.info"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Lime

extern int MA1_Period = 50;
extern int MA2_Period = 100;
extern int Method = 3;
extern int PriceType = 4;
extern bool ReverseSignal = true;
extern int Arrow_Size = 2;
extern int Arrow_PointGap = 50;
extern bool Alerts = false;

int Barcount;
string Timeframe; 

//---- buffers
double      b1[],
            b2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

   IndicatorBuffers(2);
   IndicatorShortName("MA-X Arrows");
   
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,Arrow_Size);
   SetIndexArrow(0,234); 
   SetIndexBuffer(0,b1);

   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,Arrow_Size);
   SetIndexArrow(1,233); 
   SetIndexBuffer(1,b2);
   
  if (Period() == PERIOD_M1) Timeframe="M1";
  if (Period() == PERIOD_M5) Timeframe="M5";
  if (Period() == PERIOD_M15) Timeframe="M15";
  if (Period() == PERIOD_M30) Timeframe="M30";
  if (Period() == PERIOD_H1) Timeframe="H1";
  if (Period() == PERIOD_H4) Timeframe="H4";
  if (Period() == PERIOD_D1) Timeframe="D1";
  if (Period() == PERIOD_W1) Timeframe="W1";
  if (Period() == PERIOD_MN1) Timeframe="MN1";

  Barcount = 0;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i, counted_bars=IndicatorCounted();
   double MA1,MA2,MA1prev,MA2prev;
   int limit=Bars-counted_bars;
   if(counted_bars>0) limit++;
       
// Arrows

   for(i=0; i<limit; i++)
   {
      MA1=iMA(NULL,0,MA1_Period,0,Method,PriceType,i+1);
      MA2=iMA(NULL,0,MA2_Period,0,Method,PriceType,i+1);
      MA1prev=iMA(NULL,0,MA1_Period,0,Method,PriceType,i+2);
      MA2prev=iMA(NULL,0,MA2_Period,0,Method,PriceType,i+2);
       if (ReverseSignal)
        { if(MA1 > MA2 && MA1prev < MA2prev)
               b1[i] = High[i]+Arrow_PointGap*Point;      
         if(MA1 < MA2 && MA1prev > MA2prev)
               b2[i] = Low[i]-Arrow_PointGap*Point; 
        }   
       if (!ReverseSignal)
        { if(MA1 > MA2 && MA1prev < MA2prev)
               b2[i] = Low[i]-Arrow_PointGap*Point;      
         if(MA1 < MA2 && MA1prev > MA2prev)
               b1[i] = High[i]+Arrow_PointGap*Point;  
        }            
   }
   
// Alerts
 
 if (Alerts && iBars(Symbol(),0)>Barcount)
  { 
      MA1=iMA(NULL,0,MA1_Period,0,Method,PriceType,1);
      MA2=iMA(NULL,0,MA2_Period,0,Method,PriceType,1);
      MA1prev=iMA(NULL,0,MA1_Period,0,Method,PriceType,2);
      MA2prev=iMA(NULL,0,MA2_Period,0,Method,PriceType,2);
       if (ReverseSignal)
        {
         if(MA1 > MA2 && MA1prev < MA2prev) {Alert("MA-X Arrows "+Timeframe+": Sell "+Symbol()+" @ "+DoubleToStr(Bid,Digits));}     
         if(MA1 < MA2 && MA1prev > MA2prev) {Alert("MA-X Arrows "+Timeframe+": Buy "+Symbol()+" @ "+DoubleToStr(Ask,Digits));}
        }   
       if (!ReverseSignal)
        { 
         if(MA1 > MA2 && MA1prev < MA2prev) {Alert("MA-X Arrows "+Timeframe+": Buy "+Symbol()+" @ "+DoubleToStr(Ask,Digits));}     
         if(MA1 < MA2 && MA1prev > MA2prev) {Alert("MA-X Arrows "+Timeframe+": Sell "+Symbol()+" @ "+DoubleToStr(Bid,Digits));} 
        }            
  }
   
  Barcount = iBars(Symbol(),0);

//----
   return(0);
  }
//+------------------------------------------------------------------+