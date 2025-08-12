//+------------------------------------------------------------------+
//|                                                   FiboPiv_v1.mq4 |
//|                                                          Kalenzo |
//|                                      bartlomiej.gorski@gmail.com |
//+------------------------------------------------------------------+
#property copyright "CompassFx"
#property link      "ForexFactory.com"

#property version "1.01"
// v1.01    10 dec 2020    jeanlouie, forexfactory.com/jeanlouie
// - pop, push, email, alerts

#property indicator_chart_window
#property  indicator_buffers 8
extern color   FiboColour=Yellow;
extern bool alert_pop = false;
extern bool alert_push = false;
extern bool alert_email = false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
double         SwingHigh, SwingLow;
double         BreakoutBuyLevel, BreakoutSellLevel, RetraceBuyLevel, RetraceSellLevel, StopTradingHighLevel, StopTradingLowLevel;
double         BreakoutBuyTP, BreakoutSellTP, RetraceBuyTP, RetraceSellTP;

int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("Fibo");
  
   Comment(" ");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+



 void GetSwing()
{

   SwingHigh = iHigh(NULL, PERIOD_D1, 1);
   SwingLow = iLow(NULL, PERIOD_D1, 1);
   

    
   CalculateTradeLevels();
   
   
   
}//void GetSwing()
  
void CalculateTradeLevels()
{
   
   double extent = SwingHigh - SwingLow;

   BreakoutBuyLevel = SwingHigh;
   BreakoutSellLevel = SwingLow;
   RetraceBuyLevel = NormalizeDouble(SwingLow + (extent * 23.6 / 100), Digits); 
   RetraceSellLevel = NormalizeDouble(SwingLow + (extent * 78.6 / 100), Digits); 
   StopTradingHighLevel = NormalizeDouble(SwingHigh + extent, Digits); 
   StopTradingLowLevel = NormalizeDouble(SwingLow - extent, Digits); 
   BreakoutBuyTP = NormalizeDouble(SwingLow + (extent * 138.2 / 100), Digits); 
   RetraceBuyTP = NormalizeDouble(SwingLow + (extent * 50 / 100), Digits); 
   RetraceSellTP = RetraceBuyTP;
   BreakoutSellTP = NormalizeDouble(SwingLow - (extent * 38.2 / 100), Digits); 
   
   
   /*for (int cc = 0; cc < ArraySize(LongFibLevels); cc++)
double         BreakoutBuyTP, BreakoutSellTP, RetraceBuyTP, RetraceSellTP;

   {
      LongTargetLevel[cc] = NormalizeDouble(SwingLow + (extent * LongFibLevels[cc] / 100), Digits);            
   }//for (int cc = 0; cc < ArraySize(LongFibLevels); cc++)
            
   for (cc = 0; cc < ArraySize(ShortFibLevels); cc++)
   {
      ShortTargetLevel[cc] = NormalizeDouble(SwingLow - (extent * ShortFibLevels[cc] / 100), Digits);            
   }//for (cc = 0; cc <= ArraySize(ShortFibLevels); cc++)
   */
   
}//End void CalculateTradeLevels()   
   
double HighPrice, LowPrice;
void DrawFib()
{

      
      datetime OpenTime, CloseTime;
      string tf;
      
      HighPrice = SwingHigh;
      OpenTime = iTime(NULL, PERIOD_D1, 1);
      LowPrice = SwingLow;
      CloseTime = iTime(NULL, PERIOD_D1, 1);
         
      
            
      
            
      ObjectCreate("Fibo",OBJ_FIBO,0,OpenTime,HighPrice,CloseTime,LowPrice);
      ObjectSet("Fibo", OBJPROP_STYLE, STYLE_DASH);
      ObjectSet("Fibo", OBJPROP_COLOR, FiboColour);
      ObjectSet("Fibo", OBJPROP_LEVELCOLOR, FiboColour);
      ObjectSet("Fibo", OBJPROP_WIDTH, 1);
      ObjectSet("Fibo", OBJPROP_FIBOLEVELS, 9);
      ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+0, 0);
      ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+1, 100);
      
      ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+0, 0.236);//Retrace buy
      ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+1, -0.382);//Breakout targer
      ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+2, 0);//Low
      ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+3, 0.786);//Retrace sell
      ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+4, 1.382);//Breakout targer
      ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+5, 0.50);//Pivot/retrace target
      ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+6, 2);//stop trading level
      ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+7, -1);//stop trading level
      ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+8, 1);//High
      
      
      ObjectSetFiboDescription("Fibo", 0, " Retrace buy (23.6)"+ "  %$");
      ObjectSetFiboDescription("Fibo", 1, " TP (-38.2)"+ "  %$");
      ObjectSetFiboDescription("Fibo", 2, " Low. Breakout sell (0)"+ "  %$");
      ObjectSetFiboDescription("Fibo", 3, " Retrace sell (78.6)"+ "  %$");
      ObjectSetFiboDescription("Fibo", 4, " Tp (138.2)"+ "  %$");
      ObjectSetFiboDescription("Fibo", 5, " Pivot/TP (50)"+ "  %$");
      ObjectSetFiboDescription("Fibo", 6, " Stop trading (200)"+ "  %$");
      ObjectSetFiboDescription("Fibo", 7, " Stop trading (-100)"+ "  %$");
      ObjectSetFiboDescription("Fibo", 8, " High. Breakout buy (100)"+ "  %$");
      
      
}//End void DrawFib()
int start()
  { GetSwing();
  CalculateTradeLevels();
  DrawFib();
  CheckAlert();
  }

void CheckAlert()
{
   double levels[9] = {0.236,-0.382,0,0.786,1.382,0.5,2,-1,1};
   string descrip [9] = {"Retrace buy (23.6)","TP (-38.2)","Low. Breakout sell (0)","Retrace sell (78.6)","Tp (138.2)","Pivot/TP (50)","Stop trading (200)","Stop trading (-100)","High. Breakout buy (100)"};
   double range = HighPrice - LowPrice;
   static datetime prev_time;
   static string prev_level;
   for(int x=0; x<9; x++){
      double check_line = LowPrice+range*levels[x];
      if(High[0]>check_line && Low[0]<check_line){
         if(IndicatorCounted()>0 && prev_time!=Time[0] && prev_level!=descrip[x]){
            prev_time=Time[0];
            prev_level=descrip[x];
            alert_func(descrip[x]);
         }
      }
   }
}

void alert_func(string which)
{
   string msg = _Symbol+" "+IntegerToString(_Period)+", Line Alert: "+which+" @ "+TimeToString(TimeCurrent(),TIME_DATE);
   
   if(alert_pop)Alert(msg);
   if(alert_push)SendNotification(msg);
   if(alert_email)SendMail(msg,msg);

}