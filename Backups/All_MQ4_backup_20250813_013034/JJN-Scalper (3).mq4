//+------------------------------------------------------------------+
//|                                                  JJN-Scalper.mq4 |
//|                                      Copyright © 2012, JJ Newark |
//|                                            http:/jjnewark.atw.hu |
//|                                             jjnewark@freemail.hu |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, JJ Newark"
#property link      "http:/jjnewark.atw.hu"


//---- indicator settings
#property indicator_chart_window


//---- indicator parameters
extern string     __Copyright__               = "http://jjnewark.atw.hu";
extern int        AtrPeriod                   = 8;
extern double     DojiDiff                    = 0.0002;
extern color      BuyColor                    = YellowGreen;
extern color      SellColor                   = OrangeRed;
extern color      FontColor                   = Black;
extern int        DisplayDecimals             = 4;
extern int        PosX                        = 25;
extern int        PosY                        = 25;
extern bool       SoundAlert                  = false;


//---- indicator buffers

double Atr;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
      
      
//---- 
   IndicatorShortName("JJN-Scalper");
   
   
   ObjectCreate("JJNScalperIndName",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("JJNScalperIndName",OBJPROP_CORNER,0);
   ObjectSet("JJNScalperIndName",OBJPROP_XDISTANCE,PosX+12);
   ObjectSet("JJNScalperIndName",OBJPROP_YDISTANCE,PosY);
   ObjectSetText("JJNScalperIndName","JJN-Scalper",8,"Lucida Sans Unicode",FontColor);
   
   ObjectCreate("JJNScalperLine0",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("JJNScalperLine0",OBJPROP_CORNER,0);
   ObjectSet("JJNScalperLine0",OBJPROP_XDISTANCE,PosX+5);
   ObjectSet("JJNScalperLine0",OBJPROP_YDISTANCE,PosY+8);
   ObjectSetText("JJNScalperLine0","------------------",8,"Tahoma",FontColor);
   
   ObjectCreate("JJNScalperLine1",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("JJNScalperLine1",OBJPROP_CORNER,0);
   ObjectSet("JJNScalperLine1",OBJPROP_XDISTANCE,PosX+5);
   ObjectSet("JJNScalperLine1",OBJPROP_YDISTANCE,PosY+10);
   ObjectSetText("JJNScalperLine1","------------------",8,"Tahoma",FontColor);
   
   ObjectCreate("JJNScalperDirection",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("JJNScalperDirection",OBJPROP_CORNER,0);
   ObjectSet("JJNScalperDirection",OBJPROP_XDISTANCE,PosX);
   ObjectSet("JJNScalperDirection",OBJPROP_YDISTANCE,PosY+12);
   ObjectSetText("JJNScalperDirection","Wait",20,"Lucida Sans Unicode",FontColor);
      
   ObjectCreate("JJNScalperLevel",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("JJNScalperLevel",OBJPROP_CORNER,0);
   ObjectSet("JJNScalperLevel",OBJPROP_XDISTANCE,PosX);
   ObjectSet("JJNScalperLevel",OBJPROP_YDISTANCE,PosY+50);
   ObjectSetText("JJNScalperLevel","",9,"Lucida Sans Unicode",FontColor);
   
   
//---- initialization done
   return(0);
  }

int deinit()
  {
//----
  
   ObjectDelete("JJNScalperLine0");
   ObjectDelete("JJNScalperLine1");
   ObjectDelete("JJNScalperIndName");
   ObjectDelete("JJNScalperDirection");
   ObjectDelete("JJNScalperLevel");   
   
   ObjectDelete("JJNScalperEntry");  
   ObjectDelete("JJNScalperTakeProfit");
   ObjectDelete("JJNScalperStopLoss");   
   ObjectDelete("TPPrice");
   ObjectDelete("EntryPrice");
   ObjectDelete("SLPrice");   
//----
   return(0);
  }

int start()
  {
   
   int lastbullishindex=0; 
   int lastbearishindex=0; 
   double lastbearishopen=0;
   double lastbullishopen=0;
   
   Atr=iATR(NULL,0,AtrPeriod,0);
   
   if(Close[0]>Open[0]) // BUY
      { 
      
      int found=0;
      int w=0;
      
      while(found<1) // search for the last bearish candle
      {
         if(Close[w]<Open[w] && Open[w]-Close[w]>DojiDiff) 
         {
            lastbearishopen=Open[w];
            lastbearishindex=w;
            found++;
         }
         w++;
      }
      }
   else if(Close[0]<Open[0]) // SELL
      {
      
      found=0;
      w=0;
      
      while(found<1) // search for the last bullish candle
      {
         if(Close[w]>Open[w] && Close[w]-Open[w]>DojiDiff) 
         {
            lastbullishopen=Open[w];
            lastbullishindex=w;
            found++;
         }
         w++;
      }
      }
   else // NO TRADE
      {
      lastbullishindex=0; 
      lastbearishindex=0; 
      lastbearishopen=0;
      lastbullishopen=0;
      }
   
  
   ObjectDelete("JJNScalperEntry");  
   ObjectDelete("JJNScalperTakeProfit");
   ObjectDelete("JJNScalperStopLoss");
   ObjectDelete("TPPrice");
   ObjectDelete("EntryPrice");
   ObjectDelete("SLPrice"); 
      
   if(Close[0]>Open[0] && Close[0]<lastbearishopen) // BUY
      { 
      ObjectSet("JJNScalperDirection",OBJPROP_XDISTANCE,PosX+5);
      ObjectSetText("JJNScalperDirection","BUY",28,"Lucida Sans Unicode",BuyColor); 
      ObjectSetText("JJNScalperLevel","above "+DoubleToStr(lastbearishopen,DisplayDecimals),9,"Lucida Sans Unicode",BuyColor);
      
         ObjectCreate("JJNScalperEntry",OBJ_TREND,0,Time[lastbearishindex],lastbearishopen,Time[0],lastbearishopen);
         ObjectSet("JJNScalperEntry",OBJPROP_RAY,False);
         ObjectSet("JJNScalperEntry",OBJPROP_BACK,True); // obj in the background
         ObjectSet("JJNScalperEntry",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("JJNScalperEntry",OBJPROP_WIDTH,1);
         ObjectSet("JJNScalperEntry",OBJPROP_COLOR,FontColor);
         ObjectCreate("JJNScalperTakeProfit",OBJ_TREND,0,Time[lastbearishindex],lastbearishopen+Atr,Time[0],lastbearishopen+Atr);
         ObjectSet("JJNScalperTakeProfit",OBJPROP_RAY,False);
         ObjectSet("JJNScalperTakeProfit",OBJPROP_BACK,True); // obj in the background
         ObjectSet("JJNScalperTakeProfit",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("JJNScalperTakeProfit",OBJPROP_WIDTH,1);
         ObjectSet("JJNScalperTakeProfit",OBJPROP_COLOR,BuyColor);
         ObjectCreate("JJNScalperStopLoss",OBJ_TREND,0,Time[lastbearishindex],lastbearishopen-Atr,Time[0],lastbearishopen-Atr);
         ObjectSet("JJNScalperStopLoss",OBJPROP_RAY,False);
         ObjectSet("JJNScalperStopLoss",OBJPROP_BACK,True); // obj in the background
         ObjectSet("JJNScalperStopLoss",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("JJNScalperStopLoss",OBJPROP_WIDTH,1);
         ObjectSet("JJNScalperStopLoss",OBJPROP_COLOR,SellColor);
         
         ObjectCreate("TPPrice", OBJ_ARROW, 0, Time[0], lastbearishopen+Atr);
         ObjectSet("TPPrice", OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE); 
         ObjectSet("TPPrice", OBJPROP_COLOR, BuyColor);
         ObjectCreate("EntryPrice", OBJ_ARROW, 0, Time[0], lastbearishopen);
         ObjectSet("EntryPrice", OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE); 
         ObjectSet("EntryPrice", OBJPROP_COLOR, FontColor);
         ObjectCreate("SLPrice", OBJ_ARROW, 0, Time[0], lastbearishopen-Atr);
         ObjectSet("SLPrice", OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE); 
         ObjectSet("SLPrice", OBJPROP_COLOR, SellColor);
         
         if(SoundAlert) PlaySound("alert.wav");
      }
   else if(Close[0]<Open[0] && Close[0]>lastbullishopen) // SELL
      {
      ObjectSet("JJNScalperDirection",OBJPROP_XDISTANCE,PosX+2);
      ObjectSetText("JJNScalperDirection","SELL",28,"Lucida Sans Unicode",SellColor); 
      ObjectSetText("JJNScalperLevel","under "+DoubleToStr(lastbullishopen,DisplayDecimals),9,"Lucida Sans Unicode",SellColor); 
      
         ObjectCreate("JJNScalperEntry",OBJ_TREND,0,Time[lastbullishindex],lastbullishopen,Time[0],lastbullishopen);
         ObjectSet("JJNScalperEntry",OBJPROP_RAY,False);
         ObjectSet("JJNScalperEntry",OBJPROP_BACK,True); // obj in the background
         ObjectSet("JJNScalperEntry",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("JJNScalperEntry",OBJPROP_WIDTH,1);
         ObjectSet("JJNScalperEntry",OBJPROP_COLOR,FontColor);
         ObjectCreate("JJNScalperTakeProfit",OBJ_TREND,0,Time[lastbullishindex],lastbullishopen-Atr,Time[0],lastbullishopen-Atr);
         ObjectSet("JJNScalperTakeProfit",OBJPROP_RAY,False);
         ObjectSet("JJNScalperTakeProfit",OBJPROP_BACK,True); // obj in the background
         ObjectSet("JJNScalperTakeProfit",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("JJNScalperTakeProfit",OBJPROP_WIDTH,1);
         ObjectSet("JJNScalperTakeProfit",OBJPROP_COLOR,BuyColor);
         ObjectCreate("JJNScalperStopLoss",OBJ_TREND,0,Time[lastbullishindex],lastbullishopen+Atr,Time[0],lastbullishopen+Atr);
         ObjectSet("JJNScalperStopLoss",OBJPROP_RAY,False);
         ObjectSet("JJNScalperStopLoss",OBJPROP_BACK,True); // obj in the background
         ObjectSet("JJNScalperStopLoss",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("JJNScalperStopLoss",OBJPROP_WIDTH,1);
         ObjectSet("JJNScalperStopLoss",OBJPROP_COLOR,SellColor);
         
         ObjectCreate("TPPrice", OBJ_ARROW, 0, Time[0], lastbullishopen-Atr);
         ObjectSet("TPPrice", OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE); 
         ObjectSet("TPPrice", OBJPROP_COLOR, BuyColor);
         ObjectCreate("EntryPrice", OBJ_ARROW, 0, Time[0], lastbullishopen);
         ObjectSet("EntryPrice", OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE); 
         ObjectSet("EntryPrice", OBJPROP_COLOR, FontColor);
         ObjectCreate("SLPrice", OBJ_ARROW, 0, Time[0], lastbullishopen+Atr);
         ObjectSet("SLPrice", OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE); 
         ObjectSet("SLPrice", OBJPROP_COLOR, SellColor);
         
         if(SoundAlert) PlaySound("alert.wav");
      }
   else 
      {
      ObjectSet("JJNScalperDirection",OBJPROP_XDISTANCE,PosX+8);
      ObjectSetText("JJNScalperDirection","WAIT",20,"Lucida Sans Unicode",FontColor); 
      ObjectSetText("JJNScalperLevel","",9,"Lucida Sans Unicode",FontColor);
      ObjectDelete("JJNScalperEntry");  
      ObjectDelete("JJNScalperTakeProfit");
      ObjectDelete("JJNScalperStopLoss");
      ObjectDelete("TPPrice");
      ObjectDelete("EntryPrice");
      ObjectDelete("SLPrice");
      }
  
   //Comment("");
   
         
    
//---- done
   return(0);
  }
//+------------------------------------------------------------------+