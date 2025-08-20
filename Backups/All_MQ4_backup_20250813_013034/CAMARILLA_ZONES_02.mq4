//+------------------------------------------------------------------+
//|                                                  camarilladt.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
//---- input parameters
extern int  GMTshift=0;
extern int  from=0;
extern bool pivots = false;
extern bool camarilla = true;
extern bool midpivots = false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
ObjectDelete("0 R1 Label"); 
ObjectDelete("0 R1 Line");
ObjectDelete("0 R2 Label");
ObjectDelete("0 R2 Line");
ObjectDelete("0 R3 Label");
ObjectDelete("0 R3 Line");
ObjectDelete("0 S1 Label");
ObjectDelete("0 S1 Line");
ObjectDelete("0 S2 Label");
ObjectDelete("0 S2 Line");
ObjectDelete("0 S3 Label");
ObjectDelete("0 S3 Line");
ObjectDelete("0 P Label");
ObjectDelete("0 P Line");
ObjectDelete("0 H5 Label");
ObjectDelete("0 H5 Line");
ObjectDelete("0 H4 Label");
ObjectDelete("0 H4 Line");
ObjectDelete("0 H3 Label");
ObjectDelete("0 H3 Line");
ObjectDelete("0 L3 Label");
ObjectDelete("0 L3 Line");
ObjectDelete("0 L4 Label");
ObjectDelete("0 L4 Line");
ObjectDelete("0 L5 Label");
ObjectDelete("0 L5 Line");
ObjectDelete("0 M5 Label");
ObjectDelete("0 M5 Line");
ObjectDelete("0 M4 Label");
ObjectDelete("0 M4 Line");
ObjectDelete("0 M3 Label");
ObjectDelete("0 M3 Line");
ObjectDelete("0 M2 Label");
ObjectDelete("0 M2 Line");
ObjectDelete("0 M1 Label");
ObjectDelete("0 M1 Line");
ObjectDelete("0 M0 Label");
ObjectDelete("0 M0 Line");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//---- TODO: add your code here
double day_high=0;
double day_low=0;
double yesterday_high=0;
double yesterday_open=0;
double yesterday_low=0;
double yesterday_close=0;
double today_open=0;
double ch1=0;
double ch2=0;
double ch3=0;
double ch4=0;
double cl1=0;
double cl2=0;
double cl3=0;
double cl4=0;

double P=0,Q=0,S=0,R=0,M2=0,M3=0,S1=0,R1=0,M1=0,M4=0,S2=0,R2=0,M0=0,M5=0,S3=0,R3=0,L3=0,L4=0,H3=0,H4=0,nQ=0,nD=0,D=0;
double ch5=0;
double cl5=0;

double D1=0.091667;
double D2=0.183333;
double D3=0.2750;
double D4=0.55;

//double D1=0.083333;
//double D2=0.166666;
//double D3=0.25;
//double D4=0.5;

int cnt=720;
double cur_day=0;
double prev_day=0;

double rates_d1[2][6];

//---- exit if period is greater than daily charts
if(Period() > 1440)
{
Print("Error - Chart period is greater than 1 day.");
return(-1); // then exit
}

//---- Get new daily prices & calculate pivots
datetime time;
int b,b_ = TimeDayOfWeek(Time[from]);

int m;
if(b_==1){
   b = iBarShift(NULL,PERIOD_D1,Time[from])+2;
   time = iTime(NULL,PERIOD_D1,b)-(GMTshift*3600);
   }
else{
   time = Time[from]-(GMTshift*3600);
   b = iBarShift(NULL,PERIOD_D1,Time[from])+1;
   }
   
today_open = NormalizeDouble(iOpen(NULL,PERIOD_D1,b),5);
yesterday_close = NormalizeDouble(iClose(NULL,PERIOD_D1,b),5);
yesterday_high = NormalizeDouble(iHigh(NULL,PERIOD_D1,b),5);
yesterday_low = NormalizeDouble(iLow(NULL,PERIOD_D1,b),5);

day_high = NormalizeDouble(iHigh(NULL,PERIOD_D1,Highest(NULL,PERIOD_D1,MODE_HIGH,3,b)),5);
day_low  = NormalizeDouble(iLow(NULL,PERIOD_D1,Lowest(NULL,PERIOD_D1,MODE_LOW,3,b)),5);


D = (day_high - day_low);
Q = (yesterday_high - yesterday_low);
//------ Pivot Points ------

P = (yesterday_high + yesterday_low + yesterday_close)/3;//Pivot
R1 = (2*P)-yesterday_low;
S1 = (2*P)-yesterday_high;
R2 = P-S1+R1;
S2 = P-R1+S1;
R3 = (2*P)+(yesterday_high-(2*yesterday_low));
S3 = (2*P)-((2* yesterday_high)-yesterday_low);
M0 = (S2+S3)/2;
M1 = (S1+S2)/2;
M2 = (P+S1)/2;
M3 = (P+R1)/2;
M4 = (R1+R2)/2;
M5 = (R2+R3)/2;

/*
double RANGE = bh-bl;
Print(RANGE,":",bc);
double H4_ = RANGE*1.1 / 2  + bc;
double H3_ = RANGE*1.1 / 4  + bc;
double L3_ = bc - RANGE*1.1 / 4;
double L4_ = bc - RANGE*1.1 / 2;
*/
//---- To display all 8 Camarilla pivots remove comment symbols below and
// add the appropriate object functions below
ch5 = (yesterday_high/yesterday_low)*yesterday_close;
ch4 = ((yesterday_high - yesterday_low)* D4) + yesterday_close;
ch3 = ((yesterday_high - yesterday_low)* D3) + yesterday_close;
//ch2 = ((yesterday_high - yesterday_low) * D2) + yesterday_close;
//ch1 = ((yesterday_high - yesterday_low) * D1) + yesterday_close;

//cl1 = yesterday_close - ((yesterday_high - yesterday_low)*(D1));
//cl2 = yesterday_close - ((yesterday_high - yesterday_low)*(D2));
cl3 = yesterday_close - ((yesterday_high - yesterday_low)*(D3));
cl4 = yesterday_close - ((yesterday_high - yesterday_low)*(D4));
cl5 = yesterday_close - (ch5 - yesterday_close);


//comment on OHLC and daily range

if (Q > 5) 
{
	nQ = Q;
}
else
{
	nQ = Q*10000;
}

if (D > 5)
{
	nD = D;
}
else
{
	nD = D*10000;
}


//Comment("PLUTO SKI SLOPES - OPEN TO ALL PLUTONIONS");

//---- Set line labels on chart window
 if (pivots==true)
   {
if(ObjectFind("0 R1 label") != 0)
      {
      ObjectCreate("0 R1 label", OBJ_TEXT, 0, Time[from+0], R1);
      ObjectSetText("0 R1 label", " R1", 8, "Arial", EMPTY);
      }
      else
      {
      ObjectMove("0 R1 label", 0, Time[from+0], R1);
      }

      if(ObjectFind("0 R2 label") != 0)
      {
      ObjectCreate("0 R2 label", OBJ_TEXT, 0, Time[from+20], R2);
      ObjectSetText("0 R2 label", " R2", 8, "Arial", EMPTY);
      }
      else
      {
      ObjectMove("0 R2 label", 0, Time[from+20], R2);
      }

      if(ObjectFind("0 R3 label") != 0)
      {
      ObjectCreate("0 R3 label", OBJ_TEXT, 0, Time[from+20], R3);
      ObjectSetText("0 R3 label", " R3", 8, "Arial", EMPTY);
      }
      else
      {
      ObjectMove("0 R3 label", 0, Time[from+20], R3);
      }

      if(ObjectFind("0 P label") != 0)
      {
      ObjectCreate("0 P label", OBJ_TEXT, 0, Time[from+0], P);
      ObjectSetText("0 P label", "Pivot  " +DoubleToStr(P,4), 8, "Arial", EMPTY);
      }
      else
      {
      ObjectMove("0 P label", 0, Time[0], P);
      }

      if(ObjectFind("0 S1 label") != 0)
      {
      ObjectCreate("0 S1 label", OBJ_TEXT, 0, Time[from+0], S1);
      ObjectSetText("0 S1 label", "S1", 8, "Arial", EMPTY);
      }
      else
      {
      ObjectMove("0 S1 label", 0, Time[from+0], S1);
      }

      if(ObjectFind("0 S2 label") != 0)
      {
      ObjectCreate("0 S2 label", OBJ_TEXT, 0, Time[from+20], S2);
      ObjectSetText("0 S2 label", "S2", 8, "Arial", EMPTY);
      }
      else
      {
      ObjectMove("0 S2 label", 0, Time[from+20], S2);
      }

      if(ObjectFind("0 S3 label") != 0)
      {
      ObjectCreate("0 S3 label", OBJ_TEXT, 0, Time[from+20], S3);
      ObjectSetText("0 S3 label", "S3", 8, "Arial", EMPTY);
      }
      else
      {
      ObjectMove("0 S3 label", 0, Time[from+20], S3);
      }

//---  Draw  Pivot lines on chart
      if(ObjectFind("0 S1 line") != 0)
      {
      ObjectCreate("0 S1 line", OBJ_HLINE, 0, Time[from+40], S1);
      ObjectSet("0 S1 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("0 S1 line", OBJPROP_COLOR, MidnightBlue);
      }
      else
      {
      ObjectMove("0 S1 line", 0, Time[from+40], S1);
      }

      if(ObjectFind("0 S2 line") != 0)
      {
      ObjectCreate("0 S2 line", OBJ_HLINE, 0, Time[from+40], S2);
      ObjectSet("0 S2 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("0 S2 line", OBJPROP_COLOR, MidnightBlue);
      }
      else
      {
      ObjectMove("0 S2 line", 0, Time[from+40], S2);
      }

      if(ObjectFind("0 S3 line") != 0)
      {
      ObjectCreate("0 S3 line", OBJ_HLINE, 0, Time[from+40], S3);
      ObjectSet("0 S3 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("0 S3 line", OBJPROP_COLOR, MidnightBlue);
      }
      else
      {
      ObjectMove("0 S3 line", 0, Time[from+40], S3);
      }

      if(ObjectFind("0 P line") != 0)
      {
      ObjectCreate("0 P line", OBJ_HLINE, 0, Time[from+40], P);
      ObjectSet("0 P line", OBJPROP_STYLE, STYLE_DOT);
      ObjectSet("0 P line", OBJPROP_COLOR, Lime);
      }
      else
      {
      ObjectMove("0 P line", 0, Time[from+40], P);
      }

      if(ObjectFind("0 R1 line") != 0)
      {
      ObjectCreate("0 R1 line", OBJ_HLINE, 0, Time[from+40], R1);
      ObjectSet("0 R1 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("0 R1 line", OBJPROP_COLOR, FireBrick);
      }
      else
      {
      ObjectMove("0 R1 line", 0, Time[from+40], R1);
      }

      if(ObjectFind("0 R2 line") != 0)
      {
      ObjectCreate("0 R2 line", OBJ_HLINE, 0, Time[from+40], R2);
      ObjectSet("0 R2 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("0 R2 line", OBJPROP_COLOR, FireBrick);
      }
      else
      {
      ObjectMove("0 R2 line", 0, Time[from+40], R2);
      }

      if(ObjectFind("0 R3 line") != 0)
      {
      ObjectCreate("0 R3 line", OBJ_HLINE, 0, Time[from+40], R3);
      ObjectSet("0 R3 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("0 R3 line", OBJPROP_COLOR, FireBrick);
      }
      else
      {
      ObjectMove("0 R3 line", 0, Time[from+40], R3);
      }
}
// --- THE CAMARILLA ---
if (camarilla==true)
   {
   if(ObjectFind("0 H5 label") != 0)
      {
      ObjectCreate("0 H5 label", OBJ_TEXT, 0, Time[from+20], ch5);
      ObjectSetText("0 H5 label", "H5", 10, "Arial", EMPTY);
      ObjectSet("0 H5 label", OBJPROP_COLOR, LimeGreen);
      }
      else
      {
      ObjectMove("0 H5 label", 0, Time[from+20], ch5);
      }
      
      if(ObjectFind("0 H4 label") != 0)
      {
      ObjectCreate("0 H4 label", OBJ_TEXT, 0, Time[from+20], ch4);
      ObjectSetText("0 H4 label", "H4", 10, "Arial", EMPTY);
      ObjectSet("0 H4 label", OBJPROP_COLOR, LimeGreen);
      }
      else
      {
      ObjectMove("0 H4 label", 0, Time[from+20], ch4);
      }

      if(ObjectFind("0 H3 label") != 0)
      {
      ObjectCreate("0 H3 label", OBJ_TEXT, 0, Time[from+20], ch3);
      ObjectSetText("0 H3 label", "H3", 10, "Arial", EMPTY);
      ObjectSet("0 H3 label", OBJPROP_COLOR, LimeGreen);
      }
      else
      {
      ObjectMove("0 H3 label", 0, Time[from+20], ch3);
      }

      if(ObjectFind("0 L3 label") != 0)
      {
      ObjectCreate("0 L3 label", OBJ_TEXT, 0, Time[from+20], cl3);
      ObjectSetText("0 L3 label", "L3", 10, "Arial", EMPTY);
      ObjectSet("0 L3 label", OBJPROP_COLOR, DarkOrange);
      }
      else
      {
      ObjectMove("0 L3 label", 0, Time[from+20], cl3);
      }

      if(ObjectFind("0 L4 label") != 0)
      {
      ObjectCreate("0 L4 label", OBJ_TEXT, 0, Time[from+20], cl4);
      ObjectSetText("0 L4 label", "L4", 10, "Arial", EMPTY);
      ObjectSet("0 L4 label", OBJPROP_COLOR, DarkOrange);
      }
      else
      {
      ObjectMove("0 L4 label", 0, Time[from+20], cl4);
      }
      
      if(ObjectFind("0 L5 label") != 0)
      {
      ObjectCreate("0 L5 label", OBJ_TEXT, 0, Time[from+20], cl5);
      ObjectSetText("0 L5 label", " L5", 10, "Arial", EMPTY);
      ObjectSet("0 L5 label", OBJPROP_COLOR, DarkOrange);
      }
      else
      {
      ObjectMove("0 L5 label", 0, Time[from+20], cl5);
      }

//---- Draw Camarilla lines on Chart
      if(ObjectFind("0 H5 line") != 0)
      {
      ObjectCreate("0 H5 line", OBJ_HLINE, 0, Time[from+40], ch5);
      ObjectSet("0 H5 line", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("0 H5 line", OBJPROP_WIDTH,2);
      ObjectSet("0 H5 line", OBJPROP_COLOR, LimeGreen);
      }
      else
      {
      ObjectMove("0 H5 line", 0, Time[from+40], ch5);
      }
      
      if(ObjectFind("0 H4 line") != 0)
      {
      ObjectCreate("0 H4 line", OBJ_HLINE, 0, Time[from+40], ch4);
      ObjectSet("0 H4 line", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("0 H4 line", OBJPROP_COLOR, LimeGreen);
      }
      else
      {
      ObjectMove("0 H4 line", 0, Time[from+40], ch4);
      }

      if(ObjectFind("0 H3 line") != 0)
      {
      ObjectCreate("0 H3 line", OBJ_HLINE, 0, Time[from+40], ch3);
      ObjectSet("0 H3 line", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("0 H3 line", OBJPROP_COLOR, LimeGreen);
      }
      else
      {
      ObjectMove("0 H3 line", 0, Time[from+40], ch3);
      }

      if(ObjectFind("0 L3 line") != 0)
      {
      ObjectCreate("0 L3 line", OBJ_HLINE, 0, Time[from+40], cl3);
      ObjectSet("0 L3 line", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("0 L3 line", OBJPROP_COLOR, DarkOrange);
      }
      else
      {
      ObjectMove("0 L3 line", 0, Time[from+40], cl3);
      }

      if(ObjectFind("0 L4 line") != 0)
      {
      ObjectCreate("0 L4 line", OBJ_HLINE, 0, Time[from+40], cl4);
      ObjectSet("0 L4 line", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("0 L4 line", OBJPROP_COLOR, DarkOrange);
      }
      else
      {
      ObjectMove("0 L4 line", 0, Time[from+40], cl4);
      }
      
      if(ObjectFind("0 L5 line") != 0)
      {
      ObjectCreate("0 L5 line", OBJ_HLINE, 0, Time[from+40], cl5);
      ObjectSet("0 L5 line", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("0 L5 line", OBJPROP_WIDTH,2);
      ObjectSet("0 L5 line", OBJPROP_COLOR, DarkOrange);
      }
      else
      {
      ObjectMove("0 L5 line", 0, Time[from+40], cl5);
      }
} 
//---- Draw Midpoint Pivots on Chart
 if (midpivots==true)
   {    
      if(ObjectFind("0 M5 label") != 0)
      {
      ObjectCreate("0 M5 label", OBJ_TEXT, 0, Time[from+20], M5);
      ObjectSetText("0 M5 label", " M5", 8, "Arial", EMPTY);
      }
      else
      {
      ObjectMove("0 M5 label", 0, Time[from+20], M5);
      }

      if(ObjectFind("0 M4 label") != 0)
      {
      ObjectCreate("0 M4 label", OBJ_TEXT, 0, Time[from+20], M4);
      ObjectSetText("0 M4 label", " M4", 8, "Arial", EMPTY);
      }
      else
      {
      ObjectMove("0 M4 label", 0, Time[from+20], M4);
      }

      if(ObjectFind("0 M3 label") != 0)
      {
      ObjectCreate("0 M3 label", OBJ_TEXT, 0, Time[from+20], M3);
      ObjectSetText("0 M3 label", " M3", 8, "Arial", EMPTY);
      }
      else
      {
      ObjectMove("0 M3 label", 0, Time[from+20], M3);
      }

      if(ObjectFind("0 M2 label") != 0)
      {
      ObjectCreate("0 M2 label", OBJ_TEXT, 0, Time[from+20], M2);
      ObjectSetText("0 M2 label", " M2", 8, "Arial", EMPTY);
      }
      else
      {
      ObjectMove("0 M2 label", 0, Time[from+20], M2);
      }

      if(ObjectFind("0 M1 label") != 0)
      {
      ObjectCreate("0 M1 label", OBJ_TEXT, 0, Time[from+20], M1);
      ObjectSetText("0 M1 label", " M1", 8, "Arial", EMPTY);
      }
      else
      {
      ObjectMove("0 M1 label", 0, Time[from+20], M1);
      }

      if(ObjectFind("0 M0 label") != 0)
      {
      ObjectCreate("0 M0 label", OBJ_TEXT, 0, Time[from+20], M0);
      ObjectSetText("0 M0 label", " M0", 8, "Arial", EMPTY);
      }
      else
      {
      ObjectMove("0 M0 label", 0, Time[from+20], M0);
      }
     

      if(ObjectFind("0 M5 line") != 0)
      {
      ObjectCreate("0 M5 line", OBJ_HLINE, 0, Time[from+40], M5);
      ObjectSet("0 M5 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("0 M5 line", OBJPROP_COLOR, EMPTY);
      }
      else
      {
      ObjectMove("0 M5 line", 0, Time[from+40], M5);
      }

      if(ObjectFind("0 M4 line") != 0)
      {
      ObjectCreate("0 M4 line", OBJ_HLINE, 0, Time[from+40], M4);
      ObjectSet("0 M4 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("0 M4 line", OBJPROP_COLOR, EMPTY);
      }
      else
      {
      ObjectMove("0 M4 line", 0, Time[from+40], M4);
      }

      if(ObjectFind("0 M3 line") != 0)
      {
      ObjectCreate("0 M3 line", OBJ_HLINE, 0, Time[from+40], M3);
      ObjectSet("0 M3 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("0 M3 line", OBJPROP_COLOR, EMPTY);
      }
      else
      {
      ObjectMove("0 M3 line", 0, Time[from+40], M3);
      }

      if(ObjectFind("0 M2 line") != 0)
      {
      ObjectCreate("0 M2 line", OBJ_HLINE, 0, Time[from+40], M2);
      ObjectSet("0 M2 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("0 M2 line", OBJPROP_COLOR, EMPTY);
      }
      else
      {
      ObjectMove("0 M2 line", 0, Time[from+40], M2);
      }

      if(ObjectFind("0 M1 line") != 0)
      {
      ObjectCreate("0 M1 line", OBJ_HLINE, 0, Time[from+40], M1);
      ObjectSet("0 M1 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("0 M1 line", OBJPROP_COLOR, EMPTY);
      }
      else
      {
      ObjectMove("0 M1 line", 0, Time[from+40], M1);
      }

      if(ObjectFind("0 M0 line") != 0)
      {
      ObjectCreate("0 M0 line", OBJ_HLINE, 0, Time[from+40], M0);
      ObjectSet("0 M0 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("0 M0 line", OBJPROP_COLOR, EMPTY);
      }
      else
      {
      ObjectMove("0 M0 line", 0, Time[from+40], M0);
      }
}
//---- done
   
//----
   return(0);
  }
//+------------------------------------------------------------------+