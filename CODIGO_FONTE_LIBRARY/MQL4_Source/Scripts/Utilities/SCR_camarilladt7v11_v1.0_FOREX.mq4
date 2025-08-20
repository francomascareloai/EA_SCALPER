//+------------------------------------------------------------------+
//|                                                  camarilladt.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#include <stdlib.mqh>
#property indicator_chart_window
//---- input parameters
extern bool Alerts = false;
extern double  GMTshiftSun=0;   //sun into mon cams use this corrected value for fri data 
extern double  GMTshift=1;
extern bool Pivot = true;
extern bool CamTargets = true;
extern bool ListCamTargets = true;
extern color PivotColor = LimeGreen;
extern color PivotFontColor = White;
extern int PivotFontSize = 8;
extern int PivotWidth = 1;
extern int PipDistance = 20;
extern color CamFontColor = Gray;
extern int CamFontSize = 10;
extern bool Fibs = true;
extern color FibColorRes = SeaGreen;
extern color FibColorSup = Brown;
extern color FibFontColor = Gray;
extern int FibFontSize = 8;
extern bool DisplayFibLevels_1_3 = false; 
extern double FibLevel1 = 0.236;
extern double FibLevel2 = 0.382;
extern double FibLevel3 = 0.50;
extern bool DisplayFibLevels_4_6 = true;
extern double FibLevel4 = 0.618;
extern double FibLevel5 = 0.764;
extern double FibLevel6 = 0.99;
extern bool DisplayFibLevels_7_16 = true;
extern double FibLevel7 = 1.27;
extern double FibLevel8 = 1.618;
extern double FibLevel9 = 1.99;
extern double FibLevel10 = 2.236;
extern double FibLevel11 = 2.618;
extern double FibLevel12 = 2.99;
extern double FibLevel13 = 3.236;
extern double FibLevel14 = 3.618;
extern double FibLevel15 = 3.99;
extern double FibLevel16 = 4.236;
extern bool StandardPivots = true;
extern bool ListStandardPivots = true;
extern color StandardFontColor = Gray;
extern int StandardFontSize = 8;
extern color SupportColor = Brown;
extern color ResistanceColor = SeaGreen;
extern bool MidPivots = false;
extern color MidPivotColor = White;
extern int MidFontSize = 8;

double P, H3, H4, H5;
double L3, L4, L5;
double LastHigh,LastLow,x;
bool firstL3=true;
bool firstH3=true;

double D1=0.091667;
double D2=0.183333;
double D3=0.2750;
double D4=0.55;


// Fib variables

double yesterday_high=0;
double yesterday_low=0;
double yesterday_close=0;
double p=0;
double r1=0,r2=0,r3=0,r4=0,r5=0,r6=0,r7=0,r8=0,r9=0,r10=0,r11=0,r12=0,r13=0,r14=0,r15=0,r16=0;
double s1=0,s2=0,s3=0,s4=0,s5=0,s6=0,s7=0,s8=0,s9=0,s10=0,s11=0,s12=0,s13=0,s14=0,s15=0,s16=0;
double R;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  
//---- 
   
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
if (Fibs)
{ObjectDelete("FibR1 Label"); 
ObjectDelete("FibR1 Line");
ObjectDelete("FibR2 Label");
ObjectDelete("FibR2 Line");
ObjectDelete("FibR3 Label");
ObjectDelete("FibR3 Line");
ObjectDelete("FibR4 Label");
ObjectDelete("FibR4 Line");
ObjectDelete("FibR5 Label");
ObjectDelete("FibR5 Line");
ObjectDelete("FibR6 Label");
ObjectDelete("FibR6 Line");
ObjectDelete("FibR7 Label");
ObjectDelete("FibR7 Line");
ObjectDelete("FibR8 Label");
ObjectDelete("FibR8 Line");
ObjectDelete("FibR9 Label");
ObjectDelete("FibR9 Line");
ObjectDelete("FibR10 Label");
ObjectDelete("FibR10 Line");
ObjectDelete("FibR11 Label");
ObjectDelete("FibR11 Line");
ObjectDelete("FibR12 Label");
ObjectDelete("FibR12 Line");
ObjectDelete("FibR13 Label");
ObjectDelete("FibR13 Line");
ObjectDelete("FibR14 Label");
ObjectDelete("FibR14 Line");
ObjectDelete("FibR15 Label");
ObjectDelete("FibR15 Line");
ObjectDelete("FibR16 Label");
ObjectDelete("FibR16 Line");
ObjectDelete("FibS1 Label");
ObjectDelete("FibS1 Line");
ObjectDelete("FibS2 Label");
ObjectDelete("FibS2 Line");
ObjectDelete("FibS3 Label");
ObjectDelete("FibS3 Line");
ObjectDelete("FibS4 Label");
ObjectDelete("FibS4 Line");
ObjectDelete("FibS5 Label");
ObjectDelete("FibS5 Line");
ObjectDelete("FibS6 Label");
ObjectDelete("FibS6 Line");
ObjectDelete("FibS7 Label");
ObjectDelete("FibS7 Line");
ObjectDelete("FibS8 Label");
ObjectDelete("FibS8 Line");
ObjectDelete("FibS9 Label");
ObjectDelete("FibS9 Line");
ObjectDelete("FibS10 Label");
ObjectDelete("FibS10 Line");
ObjectDelete("FibS11 Label");
ObjectDelete("FibS11 Line");
ObjectDelete("FibS12 Label");
ObjectDelete("FibS12 Line");
ObjectDelete("FibS13 Label");
ObjectDelete("FibS13 Line");
ObjectDelete("FibS14 Label");
ObjectDelete("FibS14 Line");
ObjectDelete("FibS15 Label");
ObjectDelete("FibS15 Line");
ObjectDelete("FibS16 Label");
ObjectDelete("FibS16 Line");
}
if (Pivot)
{
ObjectDelete("P Label");
ObjectDelete("P Line");
}
if (CamTargets)
{
ObjectDelete("H5 Label");
ObjectDelete("H5 Line");
ObjectDelete("H4 Label");
ObjectDelete("H4 Line");
ObjectDelete("H3 Label");
ObjectDelete("H3 Line");
ObjectDelete("L3 Label");
ObjectDelete("L3 Line");
ObjectDelete("L4 Label");
ObjectDelete("L4 Line");
ObjectDelete("L5 Label");
ObjectDelete("L5 Line");
}
//----
if (StandardPivots)
{
ObjectDelete("R1 Label"); 
ObjectDelete("R1 Line");
ObjectDelete("R2 Label");
ObjectDelete("R2 Line");
ObjectDelete("R3 Label");
ObjectDelete("R3 Line");
ObjectDelete("R4 Label");
ObjectDelete("R4 Line");
ObjectDelete("R5 Label");
ObjectDelete("R5 Line");
ObjectDelete("S1 Label");
ObjectDelete("S1 Line");
ObjectDelete("S2 Label");
ObjectDelete("S2 Line");
ObjectDelete("S3 Label");
ObjectDelete("S3 Line");
ObjectDelete("S4 Label");
ObjectDelete("S4 Line");
ObjectDelete("S5 Label");
ObjectDelete("S5 Line");
}
if (MidPivots)
{
ObjectDelete("M5 Label");
ObjectDelete("M5 Line");
ObjectDelete("M4 Label");
ObjectDelete("M4 Line");
ObjectDelete("M3 Label");
ObjectDelete("M3 Line");
ObjectDelete("M2 Label");
ObjectDelete("M2 Line");
ObjectDelete("M1 Label");
ObjectDelete("M1 Line");
ObjectDelete("M0 Label");
ObjectDelete("M0 Line");

}

   return(0);
  }
  
 

int DoAlerts()
{
   double DifAboveL3,PipsLimit;
   double DifBelowH3;

   DifBelowH3 = H3 - Close[0];
   DifAboveL3 = Close[0] - L3;
   PipsLimit = PipDistance*Point;
   
   if (DifBelowH3 > PipsLimit) firstH3 = true;
   if (DifBelowH3 <= PipsLimit && DifBelowH3 > 0)
   {
    if (firstH3)
    {
      Alert("Below Cam H3 Line by ",DifBelowH3, " for ", Symbol(),"-",Period());
      PlaySound("alert.wav");
      firstH3=false;
    }
   }

   if (DifAboveL3 > PipsLimit) firstL3 = true;
   if (DifAboveL3 <= PipsLimit && DifAboveL3 > 0)
   {
    if (firstL3)
    {
      Alert("Above Cam L3 Line by ",DifAboveL3," for ", Symbol(),"-",Period());
      Sleep(2000);
      PlaySound("timeout.wav");
      firstL3=false;
    }
   }
   
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
double yesterday_open=0;
double today_open=0;
double Q=0,S=0,R=0,M2=0,M3=0,S1=0,R1=0,M1=0,M4=0,S2=0,R2=0,M0=0,M5=0,S3=0,R3=0,nQ=0,nD=0,D=0,R4=0,S4=0,R5=0,S5=0;
double shift_corrected;
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
if (DayOfWeek()==1)  shift_corrected=GMTshiftSun;
else if ((DayOfWeek()==2) && (Minute() >= 5)) shift_corrected=GMTshift;
//else if ((DayOfWeek()==2) && (Hour() > GMTshift)) shift_corrected=GMTshift;
else    shift_corrected=GMTshift;

while (cnt!= 0)
{
	cur_day = TimeDay(Time[cnt]- (shift_corrected*3600));
	
	if (prev_day != cur_day)
	{
		yesterday_close = Close[cnt+1];
		today_open = Open[cnt];
		yesterday_high = day_high;
		yesterday_low = day_low;

		day_high = High[cnt];
		day_low  = Low[cnt];

		prev_day = cur_day;
	}
	
   
   if (High[cnt]>day_high)
   {
      day_high = High[cnt];
   }
   if (Low[cnt]<day_low)
   {
      day_low = Low[cnt];
   }
	
	cnt--;

}



D = (day_high - day_low);
Q = (yesterday_high - yesterday_low);
//------ Pivot Points ------

P = (yesterday_high + yesterday_low + yesterday_close)/3;//Pivot
//---- To display all 8 Camarilla pivots remove comment symbols below and
// add the appropriate object functions below
H5 = (yesterday_high/yesterday_low)*yesterday_close;
H4 = ((yesterday_high - yesterday_low)* D4) + yesterday_close;
H3 = ((yesterday_high - yesterday_low)* D3) + yesterday_close;
//H2 = ((yesterday_high - yesterday_low) * D2) + yesterday_close;
//H1 = ((yesterday_high - yesterday_low) * D1) + yesterday_close;

//L1 = yesterday_close - ((yesterday_high - yesterday_low)*(D1));
//L2 = yesterday_close - ((yesterday_high - yesterday_low)*(D2));
L3 = yesterday_close - ((yesterday_high - yesterday_low)*(D3));
L4 = yesterday_close - ((yesterday_high - yesterday_low)*(D4));
L5 = yesterday_close - (H5 - yesterday_close);

if (Fibs)
{
      R = yesterday_high - yesterday_low;//range
      p = (yesterday_high + yesterday_low + yesterday_close)/3;// Standard Pivot
   if (DisplayFibLevels_1_3){
      r1 = p + (R * FibLevel1);
      r2 = p + (R * FibLevel2);
      r3 = p + (R * FibLevel3);
      s1 = p - (R * FibLevel1);
      s2 = p - (R * FibLevel2);
      s3 = p - (R * FibLevel3);}
   if (DisplayFibLevels_4_6){  
      r4 = p + (R * FibLevel4);
      r5 = p + (R * FibLevel5);
      r6 = p + (R * FibLevel6);
      s4 = p - (R * FibLevel4);
      s5 = p - (R * FibLevel5);
      s6 = p - (R * FibLevel6);}
   if (DisplayFibLevels_7_16){ 
      r7 = p + (R * FibLevel7);
      r8 = p + (R * FibLevel8);
      r9 = p + (R * FibLevel9);
      r10 = p + (R * FibLevel10);
      r11 = p + (R * FibLevel11);
      r12 = p + (R * FibLevel12);
      r13 = p + (R * FibLevel13);
      r14 = p + (R * FibLevel14);
      r15 = p + (R * FibLevel15);
      r16 = p + (R * FibLevel16); 
      s7 = p - (R * FibLevel7);
      s8 = p - (R * FibLevel8);
      s9 = p - (R * FibLevel9);
      s10 = p - (R * FibLevel10);
      s11 = p - (R * FibLevel11);
      s12 = p - (R * FibLevel12);
      s13 = p - (R * FibLevel13);
      s14 = p - (R * FibLevel14);
      s15 = p - (R * FibLevel15);
      s16 = p - (R * FibLevel16);}
}

if (StandardPivots)
{
R1 = (2*P)-yesterday_low;
S1 = (2*P)-yesterday_high;
R2 = P-S1+R1;
S2 = P-R1+S1;
R3 = (2*P)+(yesterday_high-(2*yesterday_low));
S3 = (2*P)-((2* yesterday_high)-yesterday_low);
R4 = (3*P)+(yesterday_high-(3*yesterday_low));
S4 = (3*P)-((3* yesterday_high)-yesterday_low);
R5 = (4*P)+(yesterday_high-(4*yesterday_low));
S5 = (4*P)-((4* yesterday_high)-yesterday_low);
}
if (MidPivots)
{
M0 = (S2+S3)/2;
M1 = (S1+S2)/2;
M2 = (P+S1)/2;
M3 = (P+R1)/2;
M4 = (R1+R2)/2;
M5 = (R2+R3)/2;
}

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

 if (StringSubstr(Symbol(),3,3)=="JPY")
      {
      nQ=nQ/100;
      nD=nD/100;
      }
     
if ((CamTargets) && (ListCamTargets) && (StandardPivots) && (ListStandardPivots))     
{
Comment("High= ",yesterday_high,"    Previous Days Range= ",nQ,"\nLow= ",yesterday_low,"    Current Days Range= ",nD,"\nClose= ",yesterday_close,
         "\n\nH5 ",H5,"\nH4 ",H4,"\nH3 ",H3,"\n\nL3 ",L3,"\nL4 ",L4,"\nL5 ",L5,
         "\n\n\n\nR5 ",R5,"\nR4 ", R4,"\nR3 ", R3,"\nR2 ", R2,"\nR1 ", R1,"\nPivot ", P,"\nS1 ", S1,"\nS2 ", S2,"\nS3 ", S3,"\nS4 ", S4,"\nS5 ",S5);
}
else if ((CamTargets) && (ListCamTargets) && (StandardPivots) && !(ListStandardPivots))     
{
Comment("High= ",yesterday_high,"    Previous Days Range= ",nQ,"\nLow= ",yesterday_low,"    Current Days Range= ",nD,"\nClose= ",yesterday_close,
         "\n\nH5 ",H5,"\nH4 ",H4,"\nH3 ",H3,"\n\nL3 ",L3,"\nL4 ",L4,"\nL5 ",L5);
}
else if ((CamTargets) && (ListCamTargets) && !(StandardPivots))     
{
Comment("High= ",yesterday_high,"    Previous Days Range= ",nQ,"\nLow= ",yesterday_low,"    Current Days Range= ",nD,"\nClose= ",yesterday_close,
         "\n\nH5 ",H5,"\nH4 ",H4,"\nH3 ",H3,"\n\nL3 ",L3,"\nL4 ",L4,"\nL5 ",L5);
}
else if (!(CamTargets) && (StandardPivots) && (ListStandardPivots))     
{
Comment("High= ",yesterday_high,"    Previous Days Range= ",nQ,"\nLow= ",yesterday_low,"    Current Days Range= ",nD,"\nClose= ",yesterday_close,
         "\n\nR5 ",R5,"\nR4 ", R4,"\nR3 ", R3,"\nR2 ", R2,"\nR1 ", R1,"\nPivot ", P,"\nS1 ", S1,"\nS2 ", S2,"\nS3 ", S3,"\nS4 ", S4,"\nS5 ",S5);
}
else
{
Comment("High= ",yesterday_high,"    Previous Days Range= ",nQ,"\nLow= ",yesterday_low,"    Current Days Range= ",nD,"\nClose= ",yesterday_close);
}

//---- Set line labels on chart window
 if (Pivot)
   {

      if(ObjectFind("P label") != 0)
      {
      ObjectCreate("P label", OBJ_TEXT, 0, Time[0], P);
      ObjectSetText("P label", "Pivot", PivotFontSize, "Arial", PivotFontColor);
      }
      else
      {
      ObjectMove("P label", 0, Time[0], P);
      }

//---  Draw  Pivot lines on chart

      if(ObjectFind("P line") != 0)
      {
      ObjectCreate("P line", OBJ_HLINE, 0, Time[40], P);
      ObjectSet("P line", OBJPROP_STYLE, STYLE_DASH);
      ObjectSet("P line", OBJPROP_COLOR, PivotColor);
      }
      else
      {
      ObjectMove("P line", 0, Time[40], P);
      }

  }

  if (StandardPivots)
  {
if(ObjectFind("R1 label") != 0)
      {
      ObjectCreate("R1 label", OBJ_TEXT, 0, Time[20], R1);
      ObjectSetText("R1 label", " R1", StandardFontSize, "Arial", StandardFontColor);
      }
      else
      {
      ObjectMove("R1 label", 0, Time[20], R1);
      }

      if(ObjectFind("R2 label") != 0)
      {
      ObjectCreate("R2 label", OBJ_TEXT, 0, Time[20], R2);
      ObjectSetText("R2 label", " R2", StandardFontSize, "Arial", StandardFontColor);
      }
      else
      {
      ObjectMove("R2 label", 0, Time[20], R2);
      }

      if(ObjectFind("R3 label") != 0)
      {
      ObjectCreate("R3 label", OBJ_TEXT, 0, Time[20], R3);
      ObjectSetText("R3 label", " R3", StandardFontSize, "Arial", StandardFontColor);
      }
      else
      {
      ObjectMove("R3 label", 0, Time[20], R3);
      }
      
      if(ObjectFind("R4 label") != 0)
      {
      ObjectCreate("R4 label", OBJ_TEXT, 0, Time[20], R4);
      ObjectSetText("R4 label", " R4", StandardFontSize, "Arial", StandardFontColor);
      }
      else
      {
      ObjectMove("R4 label", 0, Time[20], R4);
      }
      if(ObjectFind("R5 label") != 0)
      {
      ObjectCreate("R5 label", OBJ_TEXT, 0, Time[20], R5);
      ObjectSetText("R5 label", " R5", StandardFontSize, "Arial", StandardFontColor);
      }
      else
      {
      ObjectMove("R5 label", 0, Time[20], R5);
      }

      if(ObjectFind("S1 label") != 0)
      {
      ObjectCreate("S1 label", OBJ_TEXT, 0, Time[20], S1);
      ObjectSetText("S1 label", "S1", StandardFontSize, "Arial", StandardFontColor);
      }
      else
      {
      ObjectMove("S1 label", 0, Time[20], S1);
      }

      if(ObjectFind("S2 label") != 0)
      {
      ObjectCreate("S2 label", OBJ_TEXT, 0, Time[20], S2);
      ObjectSetText("S2 label", "S2", StandardFontSize, "Arial", StandardFontColor);
      }
      else
      {
      ObjectMove("S2 label", 0, Time[20], S2);
      }

      if(ObjectFind("S3 label") != 0)
      {
      ObjectCreate("S3 label", OBJ_TEXT, 0, Time[20], S3);
      ObjectSetText("S3 label", "S3", StandardFontSize, "Arial", StandardFontColor);
      }
      else
      {
      ObjectMove("S3 label", 0, Time[20], S3);
      }
      
      if(ObjectFind("S4 label") != 0)
      {
      ObjectCreate("S4 label", OBJ_TEXT, 0, Time[20], S4);
      ObjectSetText("S4 label", "S4", StandardFontSize, "Arial", StandardFontColor);
      }
      else
      {
      ObjectMove("S4 label", 0, Time[20], S4);
      }
      if(ObjectFind("S5 label") != 0)
      {
      ObjectCreate("S5 label", OBJ_TEXT, 0, Time[20], S5);
      ObjectSetText("S5 label", "S5", StandardFontSize, "Arial", StandardFontColor);
      }
      else
      {
      ObjectMove("S5 label", 0, Time[20], S5);
      }

//---  Draw  Pivot lines on chart
      if(ObjectFind("S1 line") != 0)
      {
      ObjectCreate("S1 line", OBJ_HLINE, 0, Time[40], S1);
      ObjectSet("S1 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("S1 line", OBJPROP_COLOR, SupportColor);
      }
      else
      {
      ObjectMove("S1 line", 0, Time[40], S1);
      }

      if(ObjectFind("S2 line") != 0)
      {
      ObjectCreate("S2 line", OBJ_HLINE, 0, Time[40], S2);
      ObjectSet("S2 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("S2 line", OBJPROP_COLOR, SupportColor);
      }
      else
      {
      ObjectMove("S2 line", 0, Time[40], S2);
      }

      if(ObjectFind("S3 line") != 0)
      {
      ObjectCreate("S3 line", OBJ_HLINE, 0, Time[40], S3);
      ObjectSet("S3 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("S3 line", OBJPROP_COLOR, SupportColor);
      }
      else
      {
      ObjectMove("S3 line", 0, Time[40], S3);
      }
      
      if(ObjectFind("S4 line") != 0)
      {
      ObjectCreate("S4 line", OBJ_HLINE, 0, Time[40], S4);
      ObjectSet("S4 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("S4 line", OBJPROP_COLOR, SupportColor);
      }
      else
      {
      ObjectMove("S4 line", 0, Time[40], S4);
      }
      if(ObjectFind("S5 line") != 0)
      {
      ObjectCreate("S5 line", OBJ_HLINE, 0, Time[40], S5);
      ObjectSet("S5 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("S5 line", OBJPROP_COLOR, SupportColor);
      }
      else
      {
      ObjectMove("S5 line", 0, Time[40], S5);
      }

      if(ObjectFind("R1 line") != 0)
      {
      ObjectCreate("R1 line", OBJ_HLINE, 0, Time[40], R1);
      ObjectSet("R1 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("R1 line", OBJPROP_COLOR, ResistanceColor);
      }
      else
      {
      ObjectMove("R1 line", 0, Time[40], R1);
      }

      if(ObjectFind("R2 line") != 0)
      {
      ObjectCreate("R2 line", OBJ_HLINE, 0, Time[40], R2);
      ObjectSet("R2 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("R2 line", OBJPROP_COLOR, ResistanceColor);
      }
      else
      {
      ObjectMove("R2 line", 0, Time[40], R2);
      }

      if(ObjectFind("R3 line") != 0)
      {
      ObjectCreate("R3 line", OBJ_HLINE, 0, Time[40], R3);
      ObjectSet("R3 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("R3 line", OBJPROP_COLOR, ResistanceColor);
      }
      else
      {
      ObjectMove("R3 line", 0, Time[40], R3);
      }
      
      if(ObjectFind("R4 line") != 0)
      {
      ObjectCreate("R4 line", OBJ_HLINE, 0, Time[40], R4);
      ObjectSet("R4 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("R4 line", OBJPROP_COLOR, ResistanceColor);
      }
      else
      {
      ObjectMove("R4 line", 0, Time[40], R4);
      }
      if(ObjectFind("R5 line") != 0)
      {
      ObjectCreate("R5 line", OBJ_HLINE, 0, Time[40], R5);
      ObjectSet("R5 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("R5 line", OBJPROP_COLOR, ResistanceColor);
      }
      else
      {
      ObjectMove("R5 line", 0, Time[40], R5);
      }
  }
  
  if (MidPivots)
  {
      if(ObjectFind("M5 label") != 0)
      {
      ObjectCreate("M5 label", OBJ_TEXT, 0, Time[20], M5);
      ObjectSetText("M5 label", " M5", MidFontSize, "Arial", MidPivotColor);
      }
      else
      {
      ObjectMove("M5 label", 0, Time[20], M5);
      }

      if(ObjectFind("M4 label") != 0)
      {
      ObjectCreate("M4 label", OBJ_TEXT, 0, Time[20], M4);
      ObjectSetText("M4 label", " M4", MidFontSize, "Arial", MidPivotColor);
      }
      else
      {
      ObjectMove("M4 label", 0, Time[20], M4);
      }

      if(ObjectFind("M3 label") != 0)
      {
      ObjectCreate("M3 label", OBJ_TEXT, 0, Time[20], M3);
      ObjectSetText("M3 label", " M3", MidFontSize, "Arial", MidPivotColor);
      }
      else
      {
      ObjectMove("M3 label", 0, Time[20], M3);
      }

      if(ObjectFind("M2 label") != 0)
      {
      ObjectCreate("M2 label", OBJ_TEXT, 0, Time[20], M2);
      ObjectSetText("M2 label", " M2", MidFontSize, "Arial", MidPivotColor);
      }
      else
      {
      ObjectMove("M2 label", 0, Time[20], M2);
      }

      if(ObjectFind("M1 label") != 0)
      {
      ObjectCreate("M1 label", OBJ_TEXT, 0, Time[20], M1);
      ObjectSetText("M1 label", " M1", MidFontSize, "Arial", MidPivotColor);
      }
      else
      {
      ObjectMove("M1 label", 0, Time[20], M1);
      }

      if(ObjectFind("M0 label") != 0)
      {
      ObjectCreate("M0 label", OBJ_TEXT, 0, Time[20], M0);
      ObjectSetText("M0 label", " M0", MidFontSize, "Arial", MidPivotColor);
      }
      else
      {
      ObjectMove("M0 label", 0, Time[20], M0);
      }
     

      if(ObjectFind("M5 line") != 0)
      {
      ObjectCreate("M5 line", OBJ_HLINE, 0, Time[40], M5);
      ObjectSet("M5 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("M5 line", OBJPROP_COLOR, MidPivotColor);
      }
      else
      {
      ObjectMove("M5 line", 0, Time[40], M5);
      }

      if(ObjectFind("M4 line") != 0)
      {
      ObjectCreate("M4 line", OBJ_HLINE, 0, Time[40], M4);
      ObjectSet("M4 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("M4 line", OBJPROP_COLOR, MidPivotColor);
      }
      else
      {
      ObjectMove("M4 line", 0, Time[40], M4);
      }

      if(ObjectFind("M3 line") != 0)
      {
      ObjectCreate("M3 line", OBJ_HLINE, 0, Time[40], M3);
      ObjectSet("M3 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("M3 line", OBJPROP_COLOR, MidPivotColor);
      }
      else
      {
      ObjectMove("M3 line", 0, Time[40], M3);
      }

      if(ObjectFind("M2 line") != 0)
      {
      ObjectCreate("M2 line", OBJ_HLINE, 0, Time[40], M2);
      ObjectSet("M2 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("M2 line", OBJPROP_COLOR, MidPivotColor);
      }
      else
      {
      ObjectMove("M2 line", 0, Time[40], M2);
      }

      if(ObjectFind("M1 line") != 0)
      {
      ObjectCreate("M1 line", OBJ_HLINE, 0, Time[40], M1);
      ObjectSet("M1 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("M1 line", OBJPROP_COLOR, MidPivotColor);
      }
      else
      {
      ObjectMove("M1 line", 0, Time[40], M1);
      }

      if(ObjectFind("M0 line") != 0)
      {
      ObjectCreate("M0 line", OBJ_HLINE, 0, Time[40], M0);
      ObjectSet("M0 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("M0 line", OBJPROP_COLOR, MidPivotColor);
      }
      else
      {
      ObjectMove("M0 line", 0, Time[40], M0);
      }
  }
  
  if (Fibs) 
  {
// Fibs 1-3    
   if (DisplayFibLevels_1_3)
   {  
      if(ObjectFind("FibR1 label") != 0)
      {
        ObjectCreate("FibR1 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibR1 label", "Fib R1", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibR1 label", 0, Time[0], r1);
      }
      if(ObjectFind("FibR2 label") != 0)
      {
        ObjectCreate("FibR2 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibR2 label", "Fib R2", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibR2 label", 0, Time[0], r2);
      }
      if(ObjectFind("FibR3 label") != 0)
      {
        ObjectCreate("FibR3 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibR3 label", "Fib R3", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibR3 label", 0, Time[0], r3);
      }
      if(ObjectFind("FibS1 label") != 0)
      {
        ObjectCreate("FibS1 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibS1 label", "Fib S1", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibS1 label", 0, Time[0], s1);
      }
      if(ObjectFind("FibS2 label") != 0)
      {
        ObjectCreate("FibS2 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibS2 label", "Fib S2", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibS2 label", 0, Time[0], s2);
      }
      if(ObjectFind("FibS3 label") != 0)
      {
        ObjectCreate("FibS3 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibS3 label", "Fib S3", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibS3 label", 0, Time[0], s3);
      }
   }
// Fibs 4-6      
   if (DisplayFibLevels_4_6)
   {
       if(ObjectFind("FibR4 label") != 0)
      {
        ObjectCreate("FibR4 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibR4 label", "Fib R4", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibR4 label", 0, Time[0], r4);
      }
       if(ObjectFind("FibR5 label") != 0)
      {
        ObjectCreate("FibR5 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibR5 label", "Fib R5", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibR5 label", 0, Time[0], r5);
      }
      if(ObjectFind("FibR6 label") != 0)
      {
        ObjectCreate("FibR6 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibR6 label", "Fib R6", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibR6 label", 0, Time[0], r6);
      }
      if(ObjectFind("FibS4 label") != 0)
      {
        ObjectCreate("FibS4 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibS4 label", "Fib S4", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibS4 label", 0, Time[0], s4);
      }
      if(ObjectFind("FibS5 label") != 0)
      {
        ObjectCreate("FibS5 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibS5 label", "Fib S5", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibS5 label", 0, Time[0], s5);
      }
      if(ObjectFind("FibS6 label") != 0)
      {
        ObjectCreate("FibS6 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibS6 label", "Fib S6", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibS6 label", 0, Time[0], s6);
      }
   }
      
   if (DisplayFibLevels_7_16)
   {
      if(ObjectFind("FibR7 label") != 0)
      {
        ObjectCreate("FibR7 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibR7 label", "Fib R7", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibR7 label", 0, Time[0], r7);
      }
      if(ObjectFind("FibR8 label") != 0)
      {
        ObjectCreate("FibR8 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibR8 label", "Fib R8", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibR8 label", 0, Time[0], r8);
      }
      if(ObjectFind("FibR9 label") != 0)
      {
        ObjectCreate("FibR9 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibR9 label", "Fib R9", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibR9 label", 0, Time[0], r9);
      }
      if(ObjectFind("FibR10 label") != 0)
      {
        ObjectCreate("FibR10 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibR10 label", "Fib R10", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibR10 label", 0, Time[0], r10);
      }
      if(ObjectFind("FibR11 label") != 0)
      {
        ObjectCreate("FibR11 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibR11 label", "Fib R11", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibR11 label", 0, Time[0], r11);
      }
      if(ObjectFind("FibR12 label") != 0)
      {
        ObjectCreate("FibR12 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibR12 label", "Fib R12", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibR12 label", 0, Time[0], r12);
      }
      if(ObjectFind("FibR13 label") != 0)
      {
        ObjectCreate("FibR13 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibR13 label", "Fib R13", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibR13 label", 0, Time[0], r13);
      }
      if(ObjectFind("FibR14 label") != 0)
      {
        ObjectCreate("FibR14 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibR14 label", "Fib R14", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibR14 label", 0, Time[0], r14);
      }
      if(ObjectFind("FibR15 label") != 0)
      {
        ObjectCreate("FibR15 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibR15 label", "Fib R15", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibR15 label", 0, Time[0], r15);
      }
      if(ObjectFind("FibR16 label") != 0)
      {
        ObjectCreate("FibR16 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibR16 label", "Fib R16", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibR16 label", 0, Time[0], r16);
      }
      if(ObjectFind("FibS7 label") != 0)
      {
        ObjectCreate("FibS7 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibS7 label", "Fib S7", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibS7 label", 0, Time[0], s7);
      }
      if(ObjectFind("FibS8 label") != 0)
      {
        ObjectCreate("FibS8 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibS8 label", "Fib S8", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibS8 label", 0, Time[0], s8);
      }
      if(ObjectFind("FibS9 label") != 0)
      {
        ObjectCreate("FibS9 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibS9 label", "Fib S9", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibS9 label", 0, Time[0], s9);
      }
      if(ObjectFind("FibS10 label") != 0)
      {
        ObjectCreate("FibS10 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibS10 label", "Fib S10", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibS10 label", 0, Time[0], s10);
      }
      if(ObjectFind("FibS11 label") != 0)
      {
        ObjectCreate("FibS11 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibS11 label", "Fib S11", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibS11 label", 0, Time[0], s11);
      }
      if(ObjectFind("FibS12 label") != 0)
      {
        ObjectCreate("FibS12 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibS12 label", "Fib S12", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibS12 label", 0, Time[0], s12);
      }
      if(ObjectFind("FibS13 label") != 0)
      {
        ObjectCreate("FibS13 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibS13 label", "Fib S13", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibS13 label", 0, Time[0], s13);
      }
      if(ObjectFind("FibS14 label") != 0)
      {
        ObjectCreate("FibS14 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibS14 label", "Fib S14", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibS14 label", 0, Time[0], s14);
      }
      if(ObjectFind("FibS15 label") != 0)
      {
        ObjectCreate("FibS15 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibS15 label", "Fib S15", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibS15 label", 0, Time[0], s15);
      }
      if(ObjectFind("FibS16 label") != 0)
      {
        ObjectCreate("FibS16 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibS16 label", "Fib S16", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibS16 label", 0, Time[0], s16);
      }
   }   

//---- Set lines on chart window for Fibs
// Fibs 1-3
   if (DisplayFibLevels_1_3)
   {
      if(ObjectFind("FibR1 line") != 0)
      {
        ObjectCreate("FibR1 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibR1 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibR1 line", OBJPROP_COLOR, FibColorRes);
      }
      else
      {
        ObjectMove("FibR1 line", 0, Time[0], r1);
      }
      if(ObjectFind("FibR2 line") != 0)
      {
        ObjectCreate("FibR2 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibR2 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibR2 line", OBJPROP_COLOR, FibColorRes);
      }
      else
      {
        ObjectMove("FibR2 line", 0, Time[0], r2);
      }
      if(ObjectFind("FibR3 line") != 0)
      {
        ObjectCreate("FibR3 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibR3 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibR3 line", OBJPROP_COLOR, FibColorRes);
      }
      else
      {
        ObjectMove("FibR3 line", 0, Time[0], r3);
      }
      if(ObjectFind("FibS1 line") != 0)
      {
        ObjectCreate("FibS1 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibS1 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibS1 line", OBJPROP_COLOR, FibColorSup);
      }
      else
      {
        ObjectMove("FibS1 line", 0, Time[0], s1);
      }
      if(ObjectFind("FibS2 line") != 0)
      {
        ObjectCreate("FibS2 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibS2 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibS2 line", OBJPROP_COLOR, FibColorSup);
      }
      else
      {
        ObjectMove("FibS2 line", 0, Time[0], s2);
      }
      if(ObjectFind("FibS3 line") != 0)
      {
        ObjectCreate("FibS3 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibS3 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibS3 line", OBJPROP_COLOR, FibColorSup);
      }
      else
      {
        ObjectMove("FibS3 line", 0, Time[0], s3);
      }
   }
// Fibs 4-6   
    if (DisplayFibLevels_4_6)
    { 
      if(ObjectFind("FibR4 line") != 0)
      {
        ObjectCreate("FibR4 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibR4 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibR4 line", OBJPROP_COLOR, FibColorRes);
      }
      else
      {
        ObjectMove("FibR4 line", 0, Time[0], r4);
      }
      if(ObjectFind("FibR5 line") != 0)
      {
        ObjectCreate("FibR5 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibR5 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibR5 line", OBJPROP_COLOR, FibColorRes);
      }
      else
      {
        ObjectMove("FibR5 line", 0, Time[0], r5);
      }
      if(ObjectFind("FibR6 line") != 0)
      {
        ObjectCreate("FibR6 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibR6 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibR6 line", OBJPROP_COLOR, FibColorRes);
      }
      else
      {
        ObjectMove("FibR6 line", 0, Time[0], r6);
      }
      if(ObjectFind("FibS4 line") != 0)
      {
        ObjectCreate("FibS4 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibS4 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibS4 line", OBJPROP_COLOR, FibColorSup);
      }
      else
      {
        ObjectMove("FibS4 line", 0, Time[0], s4);
      }
      if(ObjectFind("FibS5 line") != 0)
      {
        ObjectCreate("FibS5 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibS5 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibS5 line", OBJPROP_COLOR, FibColorSup);
      }
      else
      {
        ObjectMove("FibS5 line", 0, Time[0], s5);
      }  
      if(ObjectFind("FibS6 line") != 0)
      {
        ObjectCreate("FibS6 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibS6 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibS6 line", OBJPROP_COLOR, FibColorSup);
      }
      else
      {
        ObjectMove("FibS6 line", 0, Time[0], s6);
      }
   }

// Fibs 7-16
   if (DisplayFibLevels_7_16)
   {    
      if(ObjectFind("FibR7 line") != 0)
      {
        ObjectCreate("FibR7 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibR7 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibR7 line", OBJPROP_COLOR, FibColorRes);
      }
      else
      {
        ObjectMove("FibR7 line", 0, Time[0], r7);
      }
      if(ObjectFind("FibR8 line") != 0)
      {
        ObjectCreate("FibR8 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibR8 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibR8 line", OBJPROP_COLOR, FibColorRes);
      }
      else
      {
        ObjectMove("FibR8 line", 0, Time[0], r8);
      }
      if(ObjectFind("FibR9 line") != 0)
      {
        ObjectCreate("FibR9 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibR9 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibR9 line", OBJPROP_COLOR, FibColorRes);
      }
      else
      {
        ObjectMove("FibR9 line", 0, Time[0], r9);
      }
      if(ObjectFind("FibR10 line") != 0)
      {
        ObjectCreate("FibR10 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibR10 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibR10 line", OBJPROP_COLOR, FibColorRes);
      }
      else
      {
        ObjectMove("FibR10 line", 0, Time[0], r10);
      }
      if(ObjectFind("FibR11 line") != 0)
      {
        ObjectCreate("FibR11 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibR11 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibR11 line", OBJPROP_COLOR, FibColorRes);
      }
      else
      {
        ObjectMove("FibR11 line", 0, Time[0], r11);
      }
      if(ObjectFind("FibR12 line") != 0)
      {
        ObjectCreate("FibR12 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibR12 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibR12 line", OBJPROP_COLOR, FibColorRes);
      }
      else
      {
        ObjectMove("FibR12 line", 0, Time[0], r12);
      }
      if(ObjectFind("FibR13 line") != 0)
      {
        ObjectCreate("FibR13 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibR13 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibR13 line", OBJPROP_COLOR, FibColorRes);
      }
      else
      {
        ObjectMove("FibR13 line", 0, Time[0], r13);
      }
      if(ObjectFind("FibR14 line") != 0)
      {
        ObjectCreate("FibR14 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibR14 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibR14 line", OBJPROP_COLOR, FibColorRes);
      }
      else
      {
        ObjectMove("FibR14 line", 0, Time[0], r14);
      }
      if(ObjectFind("FibR15 line") != 0)
      {
        ObjectCreate("FibR15 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibR15 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibR15 line", OBJPROP_COLOR, FibColorRes);
      }
      else
      {
        ObjectMove("FibR15 line", 0, Time[0], r15);
      }
      if(ObjectFind("FibR16 line") != 0)
      {
        ObjectCreate("FibR16 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibR16 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibR16 line", OBJPROP_COLOR, FibColorRes);
      }
      else
      {
        ObjectMove("FibR16 line", 0, Time[0], r16);
      }
      if(ObjectFind("FibS7 line") != 0)
      {
        ObjectCreate("FibS7 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibS7 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibS7 line", OBJPROP_COLOR, FibColorSup);
      }
      else
      {
        ObjectMove("FibS7 line", 0, Time[0], s7);
      }   
      if(ObjectFind("FibS8 line") != 0)
      {
        ObjectCreate("FibS8 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibS8 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibS8 line", OBJPROP_COLOR, FibColorSup);
      }
      else
      {
        ObjectMove("FibS8 line", 0, Time[0], s8);
      }   
      if(ObjectFind("FibS9 line") != 0)
      {
        ObjectCreate("FibS9 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibS9 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibS9 line", OBJPROP_COLOR, FibColorSup);
      }
      else
      {
        ObjectMove("FibS9 line", 0, Time[0], s9);
      }
      if(ObjectFind("FibS10 line") != 0)
      {
        ObjectCreate("FibS10 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibS10 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibS10 line", OBJPROP_COLOR, FibColorSup);
      }
      else
      {
        ObjectMove("FibS10 line", 0, Time[0], s10);
      }
      if(ObjectFind("FibS11 line") != 0)
      {
        ObjectCreate("FibS11 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibS11 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibS11 line", OBJPROP_COLOR, FibColorSup);
      }
      else
      {
        ObjectMove("FibS11 line", 0, Time[0], s11);
      }            
      if(ObjectFind("FibS12 line") != 0)
      {
        ObjectCreate("FibS12 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibS12 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibS12 line", OBJPROP_COLOR, FibColorSup);
      }
      else
      {
        ObjectMove("FibS12 line", 0, Time[0], s12);
      }            
      if(ObjectFind("FibS13 line") != 0)
      {
        ObjectCreate("FibS13 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibS13 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibS13 line", OBJPROP_COLOR, FibColorSup);
      }
      else
      {
        ObjectMove("FibS13 line", 0, Time[0], s13);
      }            
      if(ObjectFind("FibS13 line") != 0)
      {
        ObjectCreate("FibS13 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibS13 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibS13 line", OBJPROP_COLOR, FibColorSup);
      }
      else
      {
        ObjectMove("FibS14 line", 0, Time[0], s14);
      }            
      if(ObjectFind("FibS15 line") != 0)
      {
        ObjectCreate("FibS15 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibS15 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibS15 line", OBJPROP_COLOR, FibColorSup);
      }
      else
      {
        ObjectMove("FibS15 line", 0, Time[0], s15);
      }            
      if(ObjectFind("FibS16 line") != 0)
      {
        ObjectCreate("FibS16 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibS16 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibS16 line", OBJPROP_COLOR, FibColorSup);
      }
      else
      {
        ObjectMove("FibS16 line", 0, Time[0], s16);
      }                        
   }   
      
}

// --- THE CAMARILLA ---
if (CamTargets)
{
   if(ObjectFind("H5 label") != 0)
      {
      ObjectCreate("H5 label", OBJ_TEXT, 0, Time[20], H5);
      ObjectSetText("H5 label", " H5 LB TARGET", CamFontSize, "Arial", CamFontColor);
      }
      else
      {
      ObjectMove("H5 label", 0, Time[20], H5);
      }
      
      if(ObjectFind("H4 label") != 0)
      {
      ObjectCreate("H4 label", OBJ_TEXT, 0, Time[20], H4);
      ObjectSetText("H4 label", " H4 LONG BREAKOUT", CamFontSize, "Arial", CamFontColor);
      }
      else
      {
      ObjectMove("H4 label", 0, Time[20], H4);
      }

      if(ObjectFind("H3 label") != 0)
      {
      ObjectCreate("H3 label", OBJ_TEXT, 0, Time[20], H3);
      ObjectSetText("H3 label", " H3 SHORT", CamFontSize, "Arial", CamFontColor);
      }
      else
      {
      ObjectMove("H3 label", 0, Time[20], H3);
      }

      if(ObjectFind("L3 label") != 0)
      {
      ObjectCreate("L3 label", OBJ_TEXT, 0, Time[20], L3);
      ObjectSetText("L3 label", " L3 LONG", CamFontSize, "Arial", CamFontColor);
      }
      else
      {
      ObjectMove("L3 label", 0, Time[20], L3);
      }

      if(ObjectFind("L4 label") != 0)
      {
      ObjectCreate("L4 label", OBJ_TEXT, 0, Time[20], L4);
      ObjectSetText("L4 label", " L4 SHORT BREAKOUT", CamFontSize, "Arial", CamFontColor);
      }
      else
      {
      ObjectMove("L4 label", 0, Time[20], L4);
      }
      
      if(ObjectFind("L5 label") != 0)
      {
      ObjectCreate("L5 label", OBJ_TEXT, 0, Time[20], L5);
      ObjectSetText("L5 label", " L5 SB TARGET", CamFontSize, "Arial", CamFontColor);
      }
      else
      {
      ObjectMove("L5 label", 0, Time[20], L5);
      }

//---- Draw Camarilla lines on Chart
      if(ObjectFind("H5 line") != 0)
      {
      ObjectCreate("H5 line", OBJ_HLINE, 0, Time[40], H5);
      ObjectSet("H5 line", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("H5 line", OBJPROP_COLOR, SpringGreen);
      ObjectSet("H5 line", OBJPROP_WIDTH, 1);
      }
      else
      {
      ObjectMove("H5 line", 0, Time[40], H5);
      }
      
      if(ObjectFind("H4 line") != 0)
      {
      ObjectCreate("H4 line", OBJ_HLINE, 0, Time[40], H4);
      ObjectSet("H4 line", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("H4 line", OBJPROP_COLOR, SpringGreen);
      ObjectSet("H4 line", OBJPROP_WIDTH, 1);
      }
      else
      {
      ObjectMove("H4 line", 0, Time[40], H4);
      }

      if(ObjectFind("H3 line") != 0)
      {
      ObjectCreate("H3 line", OBJ_HLINE, 0, Time[40], H3);
      ObjectSet("H3 line", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("H3 line", OBJPROP_COLOR, SpringGreen);
      ObjectSet("H3 line", OBJPROP_WIDTH, 2);
      }
      else
      {
      ObjectMove("H3 line", 0, Time[40], H3);
      }

      if(ObjectFind("L3 line") != 0)
      {
      ObjectCreate("L3 line", OBJ_HLINE, 0, Time[40], L3);
      ObjectSet("L3 line", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("L3 line", OBJPROP_COLOR, Red);
      ObjectSet("L3 line", OBJPROP_WIDTH, 2);
      }
      else
      {
      ObjectMove("L3 line", 0, Time[40], L3);
      }

      if(ObjectFind("L4 line") != 0)
      {
      ObjectCreate("L4 line", OBJ_HLINE, 0, Time[40], L4);
      ObjectSet("L4 line", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("L4 line", OBJPROP_COLOR, Red);
      ObjectSet("L4 line", OBJPROP_WIDTH, 1);
      }
      else
      {
      ObjectMove("L4 line", 0, Time[40], L4);
      }
      
      if(ObjectFind("L5 line") != 0)
      {
      ObjectCreate("L5 line", OBJ_HLINE, 0, Time[40], L5);
      ObjectSet("L5 line", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("L5 line", OBJPROP_COLOR, Red);
      ObjectSet("L5 line", OBJPROP_WIDTH, 1);
      }
      else
      {
      ObjectMove("L5 line", 0, Time[40], L5);
      }
}
//---- done
   // Now check for Alert
   
   if (Alerts) DoAlerts();
   
//----
   return(0);
  }
//+------------------------------------------------------------------+