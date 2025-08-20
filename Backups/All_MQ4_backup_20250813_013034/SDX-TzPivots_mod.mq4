//+------------------------------------------------------------------+
//|                                                     TZ-Pivot.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright Shimodax"
#property link      "http://www.strategybuilderfx.com"

#property indicator_chart_window

/* Introduction:

   Calculation of pivot and similar levels based on time zones.
   If you want to modify the colors, please scroll down to line
   200 and below (where it says "Calculate Levels") and change
   the colors.  Valid color names can be obtained by placing
   the curor on a color name (e.g. somewhere in the word "Orange"
   and pressing F1).
   
   Time-Zone Inputs:

   LocalTimeZone: TimeZone for which MT4 shows your local time, 
                  e.g. 1 or 2 for Europe (GMT+1 or GMT+2 (daylight 
                  savings time).  Use zero for no adjustment.
                  The MetaQuotes demo server uses GMT +2.
                  
   DestTimeZone:  TimeZone for the session from which to calculate
                  the levels (e.g. 1 or 2 for the European session
                  (without or with daylight savings time).  
                  Use zero for GMT
           
                  
   Example: If your MT server is living in the EST (Eastern Standard Time, 
            GMT-5) zone and want to calculate the levels for the London trading
            session (European time in summer GMT+1), then enter -5 for 
            LocalTimeZone, 1 for Dest TimeZone. 
            
            Please understand that the LocalTimeZone setting depends on the
            time on your MetaTrader charts (for example the demo server 
            from MetaQuotes always lives in CDT (+2) or CET (+1), no matter
            what the clock on your wall says.
           
            If in doubt, leave everything to zero.
*/

extern int LocalTimeZone= 0;
extern int DestTimeZone= 0;

extern bool DailyOpenCalculate = false;
//extern bool ShowComment = false;
extern bool ShowHighLowOpen = false;
//extern bool ShowSweetSpots = false;
extern bool ShowPivots = false;
extern bool ShowMidPitvot = false;
extern bool ShowFibos= false;
extern bool ShowCamarilla = false;
extern bool ShowLevelPrices = true;
extern bool DebugLogger = false;
extern bool Zones = true;

extern color BuyArea = LimeGreen;
extern color SellArea = Red;

extern int BuySellStart = 20;
extern int BuySellEnd = 40;
extern int BarForLabels= 0;     // number of bars from right, where lines labels will be shown
extern int LineStyle= 0;
extern int LineThickness= 1;

//---- ADX
int ADX_period = 14;

//---- FI
int FI_period = 14;

//---- RSI
int RSI_period = 14;

#define BUY1 "BUY1"
#define BUY2 "BUY2"
#define SELL1 "SELL1"
#define SELL2 "SELL2"

/*
   The following doesn't work yet, please leave it to 0/24:
                  
   TradingHoursFrom: First hour of the trading session in the destination
                     time zone.
                     
   TradingHoursTo: Last hour of the trading session in the destination
                   time zone (the hour starting with this value is excluded,
                   i.e. 18 means up to 17:59 o'clock)
                   
   Example: If you are lving in the EST (Eastern Standard Time, GMT-5) 
            zone and want to calculate the levels for the London trading
            session (European time GMT+1, 08:00 - 17:00), then enter
            -5 for LocalTimeZone, 1 for Dest TimeZone, 8 for HourFrom
            and 17 for hour to.
*/

int TradingHoursFrom= 0;
int TradingHoursTo= 24;
int digits; //decimal digits for symbol's price       



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
	deinit();
	if (Ask>10) digits=2; else digits=4;
   Print("Period= ", Period());
   return(0);
}

int deinit()
{
   int obj_total= ObjectsTotal();
   string gvname;
   
   for (int i= obj_total; i>=0; i--) {
      string name= ObjectName(i);
    
      if (StringSubstr(name,0,7)=="[PIVOT]") 
         ObjectDelete(name);
   }
   	gvname=Symbol()+"st";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"p";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"r1";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"r2";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"r3";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"s1";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"s2";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"s3";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"yh";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"to";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"yl";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"ds1";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"ds2";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"flm618";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"flm382";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"flp382";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"flp5";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"fhm382";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"fhp382";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"fhp618";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"h3";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"h4";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"l3";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"l4";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"mr3";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"mr2";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"mr1";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"ms1";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"ms2";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"ms3";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"bl1";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"bl2";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"bt";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"sl1";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"sl2";
   	GlobalVariableDel(gvname);
   	gvname=Symbol()+"st";
   	GlobalVariableDel(gvname);
   	
   ObjectsDeleteAll(0, OBJ_LABEL);
   ObjectsDeleteAll(0, OBJ_RECTANGLE);
   ObjectDelete("ADX"); ObjectDelete("FI"); ObjectDelete("RSI");
   ObjectDelete("Signal");
   ObjectDelete("Analysis"); ObjectDelete("Strength"); ObjectDelete("Trend");

   return(0);
}
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   static datetime timelastupdate= 0;
   static datetime lasttimeframe= 0;
   
   datetime startofday= 0,
            startofyesterday= 0;

   double today_high= 0,
            today_low= 0,
            today_open= 0,
            yesterday_high= 0,
            yesterday_open= 0,
            yesterday_low= 0,
            yesterday_close= 0;

   int idxfirstbaroftoday= 0,
       idxfirstbarofyesterday= 0,
       idxlastbarofyesterday= 0;

   
   // no need to update these buggers too often   
   if (CurTime()-timelastupdate<60 && Period()==lasttimeframe)
      return (0);
      
   lasttimeframe= Period();
   timelastupdate= CurTime();
   
   //---- exit if period is greater than daily charts
   if(Period() > 1440) {
      Alert("Error - Chart period is greater than 1 day.");
      return(-1); // then exit
   }

   if (DebugLogger) {
      Print("Local time current bar:", TimeToStr(Time[0]));
      Print("Dest  time current bar: ", TimeToStr(Time[0]- (LocalTimeZone - DestTimeZone)*3600), ", tzdiff= ", LocalTimeZone - DestTimeZone);
   }

   string gvname; double gvval;

   // let's find out which hour bars make today and yesterday
   ComputeDayIndices(LocalTimeZone, DestTimeZone, idxfirstbaroftoday, idxfirstbarofyesterday, idxlastbarofyesterday);

   startofday= Time[idxfirstbaroftoday];  // datetime (x-value) for labes on horizontal bars
   gvname=Symbol()+"st";
   gvval=startofday;
   GlobalVariableSet(gvname,gvval);
   startofyesterday= Time[idxfirstbarofyesterday];  // datetime (x-value) for labes on horizontal bars

   

   // 
   // walk forward through yestday's start and collect high/lows within the same day
   //
   yesterday_high= -99999;  // not high enough to remain alltime high
   yesterday_low=  +99999;  // not low enough to remain alltime low
   
   for (int idxbar= idxfirstbarofyesterday; idxbar>=idxlastbarofyesterday; idxbar--) {

      if (yesterday_open==0)  // grab first value for open
         yesterday_open= Open[idxbar];                      
      
      yesterday_high= MathMax(High[idxbar], yesterday_high);
      yesterday_low= MathMin(Low[idxbar], yesterday_low);
      
      // overwrite close in loop until we leave with the last iteration's value
      yesterday_close= Close[idxbar];
   }

   

   // 
   // walk forward through today and collect high/lows within the same day
   //
   today_open= Open[idxfirstbaroftoday];  // should be open of today start trading hour

   today_high= -99999; // not high enough to remain alltime high
   today_low=  +99999; // not low enough to remain alltime low
   for (int j= idxfirstbaroftoday; j>=0; j--) {
      today_high= MathMax(today_high, High[j]);
      today_low= MathMin(today_low, Low[j]);
   }
      
   
   
   // draw the vertical bars that marks the time span
   double level= (yesterday_high + yesterday_low + yesterday_close) / 3;
   SetTimeLine("YesterdayStart", "Yesterday", idxfirstbarofyesterday, White, level+10*Point);
   SetTimeLine("YesterdayEnd", "Today", idxfirstbaroftoday, White, level+10*Point);
   
   
   
   if (DebugLogger) 
      Print("Timezoned values: yo= ", yesterday_open, ", yc =", yesterday_close, ", yhigh= ", yesterday_high, ", ylow= ", yesterday_low, ", to= ", today_open);


   //
   //---- Calculate Levels
   //
   double p,q,d,r1,r2,r3,s1,s2,s3,bl1,bl2,sl1,sl2;
   
   d = (today_high - today_low);
   q = (yesterday_high - yesterday_low);
   p = (yesterday_high + yesterday_low + yesterday_close) / 3;
   p=NormalizeDouble(p,digits);
   gvname=Symbol()+"p";
   gvval=p;
   GlobalVariableSet(gvname,gvval);
   
   r1 = (2*p)-yesterday_low;
   r1=NormalizeDouble(r1,digits);
   gvname=Symbol()+"r1";
   gvval=r1;
   GlobalVariableSet(gvname,gvval);
   r2 = p+(yesterday_high - yesterday_low);              //	r2 = p-s1+r1;
   r2=NormalizeDouble(r2,digits);
   gvname=Symbol()+"r2";
   gvval=r2;
   GlobalVariableSet(gvname,gvval);
	r3 = (2*p)+(yesterday_high-(2*yesterday_low));
   r3=NormalizeDouble(r3,digits);
   gvname=Symbol()+"r3";
   gvval=r3;
   GlobalVariableSet(gvname,gvval);
   s1 = (2*p)-yesterday_high;
   s1=NormalizeDouble(s1,digits);
   gvname=Symbol()+"s1";
   gvval=s1;
   GlobalVariableSet(gvname,gvval);
   s2 = p-(yesterday_high - yesterday_low);              //	s2 = p-r1+s1;
   s2=NormalizeDouble(s2,digits);
   gvname=Symbol()+"s2";
   gvval=s2;
   GlobalVariableSet(gvname,gvval);
	s3 = (2*p)-((2* yesterday_high)-yesterday_low);
   s3=NormalizeDouble(s3,digits);
   gvname=Symbol()+"s3";
   gvval=s3;
   GlobalVariableSet(gvname,gvval);
   
   string Signal ="";
   color col;
   double open;
   if (DailyOpenCalculate == true) { open = today_open; }
   else { open = p; }
    
   bl1 = open+(BuySellStart*Point);
   bl1=NormalizeDouble(bl1,digits);
   gvname=Symbol()+"bl1";
   gvval=bl1;
   GlobalVariableSet(gvname,gvval);
   bl2 = open+(BuySellEnd*Point);
   bl2=NormalizeDouble(bl2,digits);
   gvname=Symbol()+"bl2";
   gvval=bl2;
   GlobalVariableSet(gvname,gvval);
   sl1 = open-(BuySellStart*Point);
   sl1=NormalizeDouble(sl1,digits);
   gvname=Symbol()+"sl1";
   gvval=sl1;
   GlobalVariableSet(gvname,gvval);
   sl2 = open-(BuySellEnd*Point);
   sl2=NormalizeDouble(sl2,digits);
   gvname=Symbol()+"sl2";
   gvval=sl2;
   GlobalVariableSet(gvname,gvval);
   
   //---- Signal
   if(Ask>(bl1-5*Point)&&Ask<(bl1+5*Point)){Signal = "BUY Stop @ "+DoubleToStr(bl1,Digits)+""
                                              +"\n, TP @ "+DoubleToStr(bl2,Digits)+""
                                              +"\n, SL @ "+DoubleToStr(bl1-30*Point,Digits)+"";
                                              col = LimeGreen;
                                             }
   
   if(Ask>(bl2-5*Point)&&Ask<(bl2+5*Point)){Signal = "Breakout BUY Stop @ "+DoubleToStr(bl2,Digits)+""
                                             +"\n, TP @ "+DoubleToStr(bl2+20*Point,Digits)+""
                                             +"\n, SL @ "+DoubleToStr(bl1-10*Point,Digits)+"";
                                             col = LimeGreen;
                                            }
   
   if(Bid<(sl1+5*Point)&&Bid>(sl1-5*Point)){Signal = "SELL Stop @ "+DoubleToStr(sl1,Digits)+""
                                              +"\n, TP @ "+DoubleToStr(sl2,Digits)+""
                                              +"\n, SL @ "+DoubleToStr(sl1+30*Point,Digits)+"";
                                              col = Red;
                                             }
   
   if(Bid<(sl2+5*Point)&&Bid>(sl2-5*Point)){Signal = "Breakout SELL Stop @ "+DoubleToStr(sl2,Digits)+""
                                             +"\n, TP @ "+DoubleToStr(sl2-20*Point,Digits)+""
                                             +"\n, SL @ "+DoubleToStr(sl1+10*Point,Digits)+"";
                                             col = Red;
                                            }
                                            
   else{Signal = "Waiting..."; col = Silver;}
                                            
   ObjectCreate("Signal", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Signal", Signal, 8, "Arial", col);
   ObjectSet("Signal", OBJPROP_CORNER, 0);
   ObjectSet("Signal", OBJPROP_XDISTANCE, 7);
   ObjectSet("Signal", OBJPROP_YDISTANCE, 180);
   
   //---- Buy/Sell Area
   SetLevel("Pivot", p, Silver, LineStyle, LineThickness, startofday);
   SetLevel("BUY Level 1", bl1, BuyArea, LineStyle, LineThickness, startofday);
   SetLevel("BUY Level 2", bl2, BuyArea, LineStyle, LineThickness, startofday);
   SetLevel("SELL Level 1", sl1, SellArea, LineStyle, LineThickness, startofday);
   SetLevel("SELL Level 2", sl2, SellArea, LineStyle, LineThickness, startofday);
   
   if (DailyOpenCalculate == true)
   {
    SetLevel("Open", open, Silver, LineStyle, LineThickness, startofday);
   }
   
   //---- Zones
   Graphics(BUY1, bl1, bl2, BuyArea, startofday);
   Graphics(BUY2, bl2, bl2, BuyArea, startofday);
   Graphics(SELL1, sl1, sl2, SellArea, startofday);
   Graphics(SELL2, sl2, sl2, SellArea, startofday);
   
   

   //---- High/Low, Open
   if (ShowHighLowOpen) {
      SetLevel("Y\'s High", yesterday_high,  Orange, LineStyle, LineThickness, startofyesterday);
      SetLevel("T\'s Open", today_open,      Orange, LineStyle, LineThickness, startofday);
      SetLevel("Y\'s Low", yesterday_low,    Orange, LineStyle, LineThickness, startofyesterday);

   	gvname=Symbol()+"yh";
   	gvval=yesterday_high;
   	GlobalVariableSet(gvname,gvval);
   	gvname=Symbol()+"to";
   	gvval=today_open;
   	GlobalVariableSet(gvname,gvval);
   	gvname=Symbol()+"yl";
   	gvval=yesterday_low;
   	GlobalVariableSet(gvname,gvval);
   }


   //---- High/Low, Open
   /*if (ShowSweetSpots) {
      int ssp1, ssp2;
      double ds1, ds2;
      
      ssp1= Bid / Point;
      ssp1= ssp1 - ssp1%50;
      ssp2= ssp1 + 50;
      
      ds1= ssp1*Point;
      ds2= ssp2*Point;
      
      SetLevel(DoubleToStr(ds1,Digits), ds1,  Gold, LineStyle, LineThickness, Time[10]);
      SetLevel(DoubleToStr(ds2,Digits), ds2,  Gold, LineStyle, LineThickness, Time[10]);

   	gvname=Symbol()+"ds1";
   	gvval=ds1;
   	GlobalVariableSet(gvname,gvval);
   	gvname=Symbol()+"ds2";
   	gvval=ds2;
   	GlobalVariableSet(gvname,gvval);
   }*/
   
   //---- Pivot Lines
   if (ShowPivots==true) {
      SetLevel("R1", r1,      Silver, LineStyle, LineThickness, startofday);
      SetLevel("R2", r2,      Silver, LineStyle, LineThickness, startofday);
      SetLevel("R3", r3,      Silver, LineStyle, LineThickness, startofday);
      SetLevel("S1", s1,      Silver, LineStyle, LineThickness, startofday);
      SetLevel("S2", s2,      Silver, LineStyle, LineThickness, startofday);
      SetLevel("S3", s3,      Silver, LineStyle, LineThickness, startofday);
   }
   
   //---- Fibos of yesterday's range
   if (ShowFibos) {
      // .618, .5 and .382
      SetLevel("Low - 61.8%", yesterday_low - q*0.618,      Yellow, LineStyle, LineThickness, startofday);
      SetLevel("Low - 38.2%", yesterday_low - q*0.382,      Yellow, LineStyle, LineThickness, startofday);
      SetLevel("Low + 38.2%", yesterday_low + q*0.382,      Yellow, LineStyle, LineThickness, startofday);
      SetLevel("LowHigh 50%", yesterday_low + q*0.5,        Yellow, LineStyle, LineThickness, startofday);
      SetLevel("High - 38.2%", yesterday_high - q*0.382,    Yellow, LineStyle, LineThickness, startofday);
      SetLevel("High + 38.2%", yesterday_high + q*0.382,    Yellow, LineStyle, LineThickness, startofday);
      SetLevel("High + 61.8%", yesterday_high +  q*0.618,   Yellow, LineStyle, LineThickness, startofday);

   	gvname=Symbol()+"flm618";
   	gvval=yesterday_low - q*0.618;
   	gvval=NormalizeDouble(gvval,digits);
   	GlobalVariableSet(gvname,gvval);
   	gvname=Symbol()+"flm382";
   	gvval=yesterday_low - q*0.382;
   	gvval=NormalizeDouble(gvval,digits);
   	GlobalVariableSet(gvname,gvval);
   	gvname=Symbol()+"flp382";
   	gvval=yesterday_low + q*0.382;
   	gvval=NormalizeDouble(gvval,digits);
   	GlobalVariableSet(gvname,gvval);
   	gvname=Symbol()+"flp5";
   	gvval=yesterday_low + q*0.5;
   	gvval=NormalizeDouble(gvval,digits);
   	GlobalVariableSet(gvname,gvval);
   	gvname=Symbol()+"fhm382";
   	gvval=yesterday_high - q*0.382;
   	gvval=NormalizeDouble(gvval,digits);
   	GlobalVariableSet(gvname,gvval);
   	gvname=Symbol()+"fhp382";
   	gvval=yesterday_high + q*0.382;
   	gvval=NormalizeDouble(gvval,digits);
   	GlobalVariableSet(gvname,gvval);
   	gvname=Symbol()+"fhp618";
   	gvval=yesterday_high + q*0.618;
   	gvval=NormalizeDouble(gvval,digits);
   	GlobalVariableSet(gvname,gvval);

   }


   //----- Camarilla Lines
   if (ShowCamarilla==true) {
      
      double h4,h3,l4,l3;
	   h4 = (q*0.55)+yesterday_close;
	   h3 = (q*0.27)+yesterday_close;
	   l3 = yesterday_close-(q*0.27);	
	   l4 = yesterday_close-(q*0.55);	
	   
      SetLevel("Reversal HIGH", h3,   LightGreen, LineStyle, LineThickness, startofday);
      SetLevel("Breakout HIGH", h4,   LightGreen, LineStyle, LineThickness, startofday);
      SetLevel("Reversal LOW", l3,   Orange, LineStyle, LineThickness, startofday);
      SetLevel("Breakout LOW", l4,   Orange, LineStyle, LineThickness, startofday);

   	gvname=Symbol()+"h3";
   	gvval=h3;
   	gvval=NormalizeDouble(gvval,digits);
   	GlobalVariableSet(gvname,gvval);
   	gvname=Symbol()+"h4";
   	gvval=h4;
   	gvval=NormalizeDouble(gvval,digits);
   	GlobalVariableSet(gvname,gvval);
   	gvname=Symbol()+"l3";
   	gvval=l3;
   	gvval=NormalizeDouble(gvval,digits);
   	GlobalVariableSet(gvname,gvval);
   	gvname=Symbol()+"l4";
   	gvval=l4;
   	gvval=NormalizeDouble(gvval,digits);
   	GlobalVariableSet(gvname,gvval);
   }


   //------ Midpoints Pivots 
   if (ShowMidPitvot==true) {
      // mid levels between pivots
      SetLevel("MR3", (r2+r3)/2,    Green, LineStyle, LineThickness, startofday);
      SetLevel("MR2", (r1+r2)/2,    Green, LineStyle, LineThickness, startofday);
      SetLevel("MR1", (p+r1)/2,     Green, LineStyle, LineThickness, startofday);
      SetLevel("MS1", (p+s1)/2,     Green, LineStyle, LineThickness, startofday);
      SetLevel("MS2", (s1+s2)/2,    Green, LineStyle, LineThickness, startofday);
      SetLevel("MS3", (s2+s3)/2,    Green, LineStyle, LineThickness, startofday);

   	gvname=Symbol()+"mr3";
   	gvval=(r2+r3)/2;
   	gvval=NormalizeDouble(gvval,digits);
   	GlobalVariableSet(gvname,gvval);
   	gvname=Symbol()+"mr2";
   	gvval=(r1+r2)/2;
   	gvval=NormalizeDouble(gvval,digits);
   	GlobalVariableSet(gvname,gvval);
   	gvname=Symbol()+"mr1";
   	gvval=(p+r1)/2;
   	gvval=NormalizeDouble(gvval,digits);
   	GlobalVariableSet(gvname,gvval);
   	gvname=Symbol()+"ms1";
   	gvval=(p+s1)/2;
   	gvval=NormalizeDouble(gvval,digits);
   	GlobalVariableSet(gvname,gvval);
   	gvname=Symbol()+"ms2";
   	gvval=(p+s2)/2;
   	gvval=NormalizeDouble(gvval,digits);
   	GlobalVariableSet(gvname,gvval);
   	gvname=Symbol()+"ms3";
   	gvval=(p+s3)/2;
   	gvval=NormalizeDouble(gvval,digits);
   	GlobalVariableSet(gvname,gvval);
   	
   }


   //------ Comment for upper left corner
   /*if (ShowComment) {
      string comment= ""; 
      
      comment= comment + "-- Good luck with your trading! ---\n";
      comment= comment + "Range: Yesterday "+DoubleToStr(MathRound(q/Point),0)   +" pips, Today "+DoubleToStr(MathRound(d/Point),0)+" pips" + "\n";
      comment= comment + "Highs: Yesterday "+DoubleToStr(yesterday_high,Digits)  +", Today "+DoubleToStr(today_high,Digits) +"\n";
      comment= comment + "Lows:  Yesterday "+DoubleToStr(yesterday_low,Digits)   +", Today "+DoubleToStr(today_low,Digits)  +"\n";
      comment= comment + "Close: Yesterday "+DoubleToStr(yesterday_close,Digits) + "\n";
   // comment= comment + "Pivot: " + DoubleToStr(p,Digits) + ", S1/2/3: " + DoubleToStr(s1,Digits) + "/" + DoubleToStr(s2,Digits) + "/" + DoubleToStr(s3,Digits) + "\n" ;
   // comment= comment + "Fibos: " + DoubleToStr(yesterday_low + q*0.382, Digits) + ", " + DoubleToStr(yesterday_high - q*0.382,Digits) + "\n";
      
      Comment(comment); 
   }*/
   
   Comment("\n NN \n ------------------------------------------------"
   +"\n "+Symbol()+" Trend Analysis"
   +"\n ------------------------------------------------"
   +"\n 1st Indicator:"
   +"\n 2nd Indicator:"
   +"\n 3rd Indicator:"
   +"\n ------------------------------------------------"
   +"\n Analysis Result:"
   +"\n \n ------------------------------------------------"
   +"\n \n Signal:"
   +"\n \n \n Good Luck with Your Trading :)");
   
   //---- Trend Analysis
   
   //---- ADX
   string ADX_Trend = "";
   color colt1;
   
   double ADXP=iADX(NULL,0,ADX_period,PRICE_CLOSE,MODE_PLUSDI,0);
   double ADXM=iADX(NULL,0,ADX_period,PRICE_CLOSE,MODE_MINUSDI,0);
   
   if ((ADXP > ADXM)) { ADX_Trend = "UP"; colt1 = LimeGreen; }
   if ((ADXP < ADXM)) { ADX_Trend = "DOWN"; colt1 = Red; }
   
   ObjectCreate("ADX", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("ADX",ADX_Trend,8, "Arial", colt1);
   ObjectSet("ADX", OBJPROP_CORNER, 0);
   ObjectSet("ADX", OBJPROP_XDISTANCE, 80);
   ObjectSet("ADX", OBJPROP_YDISTANCE, 72);   
   
   //---- FI
   string FI_Trend ="";
   color colt2;
   
   double FI=iForce(NULL,0,FI_period,1,PRICE_CLOSE,0);
   
   if((FI > 0)) { FI_Trend ="UP"; colt2 = LimeGreen; }
   if((FI < 0)) { FI_Trend ="DOWN"; colt2 = Red; }
   
   ObjectCreate("FI", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("FI",FI_Trend,8, "Arial", colt2);
   ObjectSet("FI", OBJPROP_CORNER, 0);
   ObjectSet("FI", OBJPROP_XDISTANCE, 80);
   ObjectSet("FI", OBJPROP_YDISTANCE, 84);  
   
   //---- RSI
   string RSI_Trend ="";
   color colt3;
   
   double RSI=iRSI(NULL,0,RSI_period,PRICE_CLOSE,0);
   
   if((RSI > 50)) { RSI_Trend ="UP"; colt3 = LimeGreen; }
   if((RSI < 50)) { RSI_Trend ="DOWN"; colt3 = Red; }

   ObjectCreate("RSI", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("RSI",RSI_Trend,8, "Arial", colt3);
   ObjectSet("RSI", OBJPROP_CORNER, 0);
   ObjectSet("RSI", OBJPROP_XDISTANCE, 80);
   ObjectSet("RSI", OBJPROP_YDISTANCE, 96);
   
   string Analysis ="", Strength ="", Trend="";
   color cola1, cola2, cola3;
   
   if(ADX_Trend=="UP"&&FI_Trend=="UP"&&RSI_Trend=="UP")
   {Analysis="UP"; cola1=LimeGreen; Strength="[Strong]"; cola2=LimeGreen; Trend="BULLISH"; cola3=LimeGreen;}
   if(ADX_Trend=="UP"&&FI_Trend=="UP"&&RSI_Trend=="DOWN")
   {Analysis="UP"; cola1=LimeGreen; Strength="[Weak]"; cola2=Lime; Trend="SIDEWAY"; cola3=Silver;}
   if(ADX_Trend=="UP"&&FI_Trend=="DOWN"&&RSI_Trend=="UP")
   {Analysis="UP"; cola1=LimeGreen; Strength="[Weak]"; cola2=Lime; Trend="SIDEWAY"; cola3=Silver;}
   if(ADX_Trend=="UP"&&FI_Trend=="DOWN"&&RSI_Trend=="DOWN")
   {Analysis="DOWN"; cola1=Red; Strength="[Weak]"; cola2=Tomato; Trend="SIDEWAY"; cola3=Silver;}
   if(ADX_Trend=="DOWN"&&FI_Trend=="DOWN"&&RSI_Trend=="DOWN")
   {Analysis="DOWN"; cola1=Red; Strength="[Strong]"; cola2=Red; Trend="BEARISH"; cola3=Red;}
   if(ADX_Trend=="DOWN"&&FI_Trend=="DOWN"&&RSI_Trend=="UP")
   {Analysis="DOWN"; cola1=Red; Strength="[Weak]"; cola2=Tomato; Trend="SIDEWAY"; cola3=Silver;}
   if(ADX_Trend=="DOWN"&&FI_Trend=="UP"&&RSI_Trend=="DOWN")
   {Analysis="DOWN"; cola1=Red; Strength="[Weak]"; cola2=Tomato; Trend="SIDEWAY"; cola3=Silver;}
   if(ADX_Trend=="DOWN"&&FI_Trend=="UP"&&RSI_Trend=="UP")
   {Analysis="UP"; cola1=LimeGreen; Strength="[Weak]"; cola2=Lime; Trend="SIDEWAY"; cola3=Silver;}

   ObjectCreate("Analysis", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Analysis",Analysis,8, "Arial", cola1);
   ObjectSet("Analysis", OBJPROP_CORNER, 0);
   ObjectSet("Analysis", OBJPROP_XDISTANCE, 80);
   ObjectSet("Analysis", OBJPROP_YDISTANCE, 120);
   
   ObjectCreate("Strength", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Strength",Strength,8, "Arial", cola2);
   ObjectSet("Strength", OBJPROP_CORNER, 0);
   ObjectSet("Strength", OBJPROP_XDISTANCE, 113);
   ObjectSet("Strength", OBJPROP_YDISTANCE, 120);
   
   ObjectCreate("Trend", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Trend",Trend,8, "Arial", cola3);
   ObjectSet("Trend", OBJPROP_CORNER, 0);
   ObjectSet("Trend", OBJPROP_XDISTANCE, 80);
   ObjectSet("Trend", OBJPROP_YDISTANCE, 132);

   return(0);
}

 
//+------------------------------------------------------------------+
//| Compute index of first/last bar of yesterday and today           |
//+------------------------------------------------------------------+
void ComputeDayIndices(int tzlocal, int tzdest, int &idxfirstbaroftoday, int &idxfirstbarofyesterday, int &idxlastbarofyesterday)
{     
   int tzdiff= tzlocal - tzdest,
       tzdiffsec= tzdiff*3600,
       dayminutes= 24 * 60,
       barsperday= dayminutes/Period();
   
   int dayofweektoday= TimeDayOfWeek(Time[0] - tzdiffsec),  // what day is today in the dest timezone?
       dayofweektofind= -1; 

   //
   // due to gaps in the data, and shift of time around weekends (due 
   // to time zone) it is not as easy as to just look back for a bar 
   // with 00:00 time
   //
   
   idxfirstbaroftoday= 0;
   idxfirstbarofyesterday= 0;
   idxlastbarofyesterday= 0;
       
   switch (dayofweektoday) {
      case 6: // sat
      case 0: // sun
      case 1: // mon
            dayofweektofind= 5; // yesterday in terms of trading was previous friday
            break;
            
      default:
            dayofweektofind= dayofweektoday -1; 
            break;
   }
   
   if (DebugLogger) {
      Print("Dayofweektoday= ", dayofweektoday);
      Print("Dayofweekyesterday= ", dayofweektofind);
   }
       
       
   // search  backwards for the last occrrence (backwards) of the day today (today's first bar)
   for (int i=1; i<=barsperday+1; i++) {
      datetime timet= Time[i] - tzdiffsec;
      if (TimeDayOfWeek(timet)!=dayofweektoday) {
         idxfirstbaroftoday= i-1;
         break;
      }
   }
   

   // search  backwards for the first occrrence (backwards) of the weekday we are looking for (yesterday's last bar)
   for (int j= 0; j<=2*barsperday+1; j++) {
      datetime timey= Time[i+j] - tzdiffsec;
      if (TimeDayOfWeek(timey)==dayofweektofind) {  // ignore saturdays (a Sa may happen due to TZ conversion)
         idxlastbarofyesterday= i+j;
         break;
      }
   }


   // search  backwards for the first occurrence of weekday before yesterday (to determine yesterday's first bar)
   for (j= 1; j<=barsperday; j++) {
      datetime timey2= Time[idxlastbarofyesterday+j] - tzdiffsec;
      if (TimeDayOfWeek(timey2)!=dayofweektofind) {  // ignore saturdays (a Sa may happen due to TZ conversion)
         idxfirstbarofyesterday= idxlastbarofyesterday+j-1;
         break;
      }
   }


   if (DebugLogger) {
      Print("Dest time zone\'s current day starts:", TimeToStr(Time[idxfirstbaroftoday]), 
                                                      " (local time), idxbar= ", idxfirstbaroftoday);

      Print("Dest time zone\'s previous day starts:", TimeToStr(Time[idxfirstbarofyesterday]), 
                                                      " (local time), idxbar= ", idxfirstbarofyesterday);
      Print("Dest time zone\'s previous day ends:", TimeToStr(Time[idxlastbarofyesterday]), 
                                                      " (local time), idxbar= ", idxlastbarofyesterday);
   }
   
}


//+------------------------------------------------------------------+
//| Helper                                                           |
//+------------------------------------------------------------------+
void SetLevel(string text, double level, color col1, int linestyle, int thickness, datetime startofday)
{
   int digits= Digits;
   string labelname= "[PIVOT] " + text + " Label",
          linename= "[PIVOT] " + text + " Line",
          pricelabel; 

   // create or move the horizontal line   
   if (ObjectFind(linename) != 0) {
      ObjectCreate(linename, OBJ_TREND, 0, startofday, level, Time[0],level);
      ObjectSet(linename, OBJPROP_STYLE, linestyle);
      ObjectSet(linename, OBJPROP_COLOR, col1);
      ObjectSet(linename, OBJPROP_WIDTH, thickness);
      ObjectSet(linename, OBJPROP_BACK, false);
   }
   else {
      ObjectMove(linename, 1, Time[0],level);
      ObjectMove(linename, 0, startofday, level);
   }
   

   // put a label on the line   
   if (ObjectFind(labelname) != 0) {
      ObjectCreate(labelname, OBJ_TEXT, 0, Time[BarForLabels], level);
   }
   else {
      ObjectMove(labelname, 0, Time[BarForLabels], level);
   }

   pricelabel= " " + text;
   if (ShowLevelPrices && StrToInteger(text)==0) 
      pricelabel= pricelabel + ": "+DoubleToStr(level, Digits);
   
   ObjectSetText(labelname, pricelabel, 8, "Arial", White);
}
      

//+------------------------------------------------------------------+
//| Helper                                                           |
//+------------------------------------------------------------------+
void SetTimeLine(string objname, string text, int idx, color col1, double vleveltext) 
{
   string name= "[PIVOT] " + objname;
   int x= Time[idx];

   if (ObjectFind(name) != 0) 
      ObjectCreate(name, OBJ_TREND, 0, x, 0, x, 100);
   else {
      ObjectMove(name, 0, x, 0);
      ObjectMove(name, 1, x, 100);
   }
   
   ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
   ObjectSet(name, OBJPROP_COLOR, DarkGray);
   
   if (ObjectFind(name + " Label") != 0) 
      ObjectCreate(name + " Label", OBJ_TEXT, 0, x, vleveltext);
   else
      ObjectMove(name + " Label", 0, x, vleveltext);
            
   ObjectSetText(name + " Label", text, 8, "Arial", col1);
}

//---- Zones
void Graphics(string GFX, double start, double end, color clr, datetime startofday)
{
 ObjectCreate(GFX, OBJ_RECTANGLE, 0, startofday, start, Time[0],end);
 ObjectSet(GFX, OBJPROP_COLOR, clr);
 ObjectSet(GFX, OBJPROP_BACK, Zones);
 ObjectSet(GFX, OBJPROP_RAY, false);
 ObjectMove(GFX, 1, Time[0]+99999*24,end);
 ObjectMove(GFX, 0, startofday, start);
 
 if(Zones==false)
 {
  ObjectDelete(GFX);
 }
}