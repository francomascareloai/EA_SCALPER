
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 4
extern color color1 =Blue;
extern color color2 =Red;
extern string simbol="EURGBP";//"";
double INFO_OpenBar[];
double INFO_CloseBar[];
double INFO_LowBar[];
double INFO_HighBar[];
//выволит другой инструмент в текущее окно
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0,INFO_OpenBar);
   SetIndexBuffer(1,INFO_CloseBar);
   SetIndexBuffer(2,INFO_LowBar);
   SetIndexBuffer(3,INFO_HighBar);
   SetIndexLabel(0,"OpenBar");
   SetIndexLabel(1,"CloseBar");
   SetIndexLabel(2,"LowBar");
   SetIndexLabel(3,"HighBar");            
   return(0);
  }
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(0,OBJ_TREND);        
   return(0);
  }
//+------------------------------------------------------------------+
int start()
  {
   int BarsWind=WindowFirstVisibleBar();
   int Bar = iHighest(NULL,0,MODE_HIGH,BarsWind,0);
   double High_Win = High[Bar];
   Bar = iLowest(NULL,0,MODE_LOW,BarsWind,0);
   double Low_Win  = Low[Bar];
   Bar = iHighest(simbol,0,MODE_HIGH,BarsWind,0);
   double H=iHigh(simbol,0,Bar);
   Bar = iLowest(simbol,0,MODE_LOW,BarsWind,0);
   double L=iLow(simbol,0,Bar);
   //double K=(High_Win-Low_Win)/(H-L);
   double OpenBar,CloseBar,LowBar,HighBar;
   string nameCandle;
   int Digit = MarketInfo(simbol,MODE_DIGITS);
   for(int i=BarsWind; i>=0; i--)
   {
      OpenBar = iOpen (simbol,0,i);
      CloseBar= iClose(simbol,0,i);
      LowBar  = iLow  (simbol,0,i);
      HighBar = iHigh (simbol,0,i);
   //Comment(OpenBar," ",CloseBar," ",LowBar," ",HighBar," ");
      nameCandle=StringConcatenate(simbol," ",TimeToStr(Time[i],TIME_DATE|TIME_MINUTES));//," O",DoubleToStr(OpenBar,Digit)," H",DoubleToStr(HighBar,Digit)," L",DoubleToStr(LowBar,Digit)," C",DoubleToStr(CloseBar,Digit));
      OpenBar =(OpenBar -L)/(H-L)*(High_Win-Low_Win)+Low_Win;
      CloseBar=(CloseBar-L)/(H-L)*(High_Win-Low_Win)+Low_Win;
      LowBar  =(LowBar  -L)/(H-L)*(High_Win-Low_Win)+Low_Win;
      HighBar =(HighBar -L)/(H-L)*(High_Win-Low_Win)+Low_Win;
      INFO_OpenBar[i]=OpenBar;
      INFO_CloseBar[i]=CloseBar;
      INFO_LowBar[i]=LowBar;
      INFO_HighBar[i]=HighBar;      
      ObjectDelete(nameCandle);
      ObjectCreate(nameCandle, OBJ_TREND,0,Time[i],LowBar,Time[i],HighBar,0,0);
      ObjectSet   (nameCandle, OBJPROP_WIDTH, 1);
      if (OpenBar>CloseBar) ObjectSet   (nameCandle, OBJPROP_COLOR, color1);  
      else ObjectSet   (nameCandle, OBJPROP_COLOR, color2);  
      ObjectSet   (nameCandle, OBJPROP_RAY,   false);
      nameCandle=StringConcatenate(nameCandle," Body");
      ObjectDelete(nameCandle);
      ObjectCreate(nameCandle, OBJ_TREND,0,Time[i],OpenBar,Time[i],CloseBar,0,0);
      ObjectSet   (nameCandle, OBJPROP_WIDTH, 4);
      if (OpenBar>CloseBar) ObjectSet   (nameCandle, OBJPROP_COLOR, color1);  
      else ObjectSet   (nameCandle, OBJPROP_COLOR, color2);  
      ObjectSet   (nameCandle, OBJPROP_RAY,   false);
   }
   return(0);
  }
//+------------------------------------------------------------------+