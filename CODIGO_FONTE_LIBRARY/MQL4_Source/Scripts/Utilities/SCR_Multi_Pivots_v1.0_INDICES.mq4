//+------------------------------------------------------------------+
//|                                                 Multi Pivots.mq4 |
//|                                Converted to MT4 / MQ4 by Flash52 |
//|                MetaTrader_Experts_and_Indicators@yahoogroups.com |
//+------------------------------------------------------------------+
#property copyright "Converted to MT4 / MQ4 by Flash52"
#property link      "MetaTrader_Experts_and_Indicators@yahoogroups.com"
//----
// This indicator allows the user to select which set(s) of pivots they wish to display.
// If your favorite pivot is not included, simply add it in or modify one of the existing pivots
//----
#property indicator_chart_window

extern int Show_Woodies_Pivots = 1;    // 1 = Yes, 0 = No
extern int Show_Camarilla_Pivots = 1;  // 1 = Yes, 0 = No
extern int Show_Demark_Pivots = 1;     // 1 = Yes, 0 = No
extern int Show_Standard_Pivots = 0;   // 1 = Yes, 0 = No

datetime prevtime=0;
datetime prev_day=0;
datetime cur_day=0;
double rates_d1[2][6];
double day_high=0;	
double day_low=0;	
double yesterday_high=0;
double yesterday_open=0;			
double yesterday_low=0;			
double yesterday_close=0;
double today_open=0;

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
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Multi Daily Pivots iteration function                            |
//+------------------------------------------------------------------+
int start()
  {
    int    counted_bars=IndicatorCounted();
//---- initialize local variables

   double r2=0;
   double r1=0;
   double p=0;
   double s1=0;
   double s2=0;
   double sr3=0;
   double sr2=0;
   double sr1=0;
   double sp=0;
   double ss1=0;
   double ss2=0;
   double ss3=0;
   double ch1=0;
   double ch2=0;
   double ch3=0;
   double ch4=0;
   double cl1=0;
   double cl2=0;
   double cl3=0;
   double cl4=0;
   double D1=0.091667;
   double D2=0.183333;
   double D3=0.2750;
   double D4=0.55;
   double dr=0;
   double ds=0;
   double x=0;
   string ch3_text="";

   
//---- exit if period is greater than daily charts  
   if(Period() > 1440)
   {
      Print("Error - Chart period is greater than 1 day.");
      return(-1);   // then exit 
   }
//---- If the day has changed then get new daily rates & recalculate pivots
//---- Check for day change once each new bar
//---- Allow labels & lines to be redrawn each bar

   if(prevtime == Time[0])return(0); // exit unless new bar
   prevtime = Time[0]; // reset to current bar time
  	cur_day = Day();
  	if(prev_day != cur_day) 
  	{
      ArrayCopyRates(rates_d1, Symbol(), PERIOD_D1);
        
      yesterday_close = rates_d1[1][4];
      yesterday_open = rates_d1[1][1];
      today_open = rates_d1[0][1];
      yesterday_high = rates_d1[1][3];
      yesterday_low = rates_d1[1][2];
      prev_day = cur_day;
  	}

//---- Calculate Standard Pivots
   if(Show_Standard_Pivots == 1)   
   {
      sp = (yesterday_high+yesterday_low+yesterday_close+today_open)/4;
		sr1 = (2*sp)-yesterday_low;
		ss1 = (2*sp)-yesterday_high;
		sr2 = sp+(yesterday_high-yesterday_low);
		ss2 = sp-(yesterday_high+yesterday_low);
		sr3 = (2*sp)-yesterday_low-yesterday_low+yesterday_high;
		ss3 = (2*sp)-yesterday_high-yesterday_high+yesterday_low;	

//---- Set standard pivot line labels on chart window 

      if(ObjectFind("SR1 label") != 0)
      {
         ObjectCreate("SR1 label", OBJ_TEXT, 0, Time[20], sr1);
         ObjectSetText("SR1 label", "R1 "+DoubleToStr(sr1,4), 8, "Arial", White);
      }
      else
      {
         ObjectSetText("SR1 label", "R1 "+DoubleToStr(sr1,4), 8, "Arial", White);
         ObjectMove("SR1 label", 0, Time[20], sr1);
      }
   
      if(ObjectFind("SR2 label") != 0)
      {
         ObjectCreate("SR2 label", OBJ_TEXT, 0, Time[20], sr2);
         ObjectSetText("SR2 label", "R2 "+DoubleToStr(sr2,4), 8, "Arial", White);
      }
      else
      {
         ObjectSetText("SR2 label", "R2 "+DoubleToStr(sr2,4), 8, "Arial", White);
         ObjectMove("SR2 label", 0, Time[20], sr2);
      }
      
      if(ObjectFind("SR3 label") != 0)
      {
         ObjectCreate("SR3 label", OBJ_TEXT, 0, Time[20], sr3);
         ObjectSetText("SR3 label", "R3 "+DoubleToStr(sr3,4), 8, "Arial", White);
      }
      else
      {
         ObjectSetText("SR3 label", "R3 "+DoubleToStr(sr3,4), 8, "Arial", White);
         ObjectMove("SR3 label", 0, Time[20], sr3);
      }
      
      if(ObjectFind("SP label") != 0)
      {
         ObjectCreate("SP label", OBJ_TEXT, 0, Time[20], sp);
         ObjectSetText("SP label", "Pivot "+DoubleToStr(sp,4), 8, "Arial", White);
      }
      else
      {
         ObjectSetText("SP label", "Pivot "+DoubleToStr(sp,4), 8, "Arial", White);
         ObjectMove("SP label", 0, Time[20], sp);
      }
   
      if(ObjectFind("SS1 label") != 0)
      {
         ObjectCreate("SS1 label", OBJ_TEXT, 0, Time[20], ss1);
         ObjectSetText("SS1 label", "S1 "+DoubleToStr(ss1,4), 8, "Arial", White);
      }
      else
      {
         ObjectSetText("SS1 label", "S1 "+DoubleToStr(ss1,4), 8, "Arial", White);
         ObjectMove("SS1 label", 0, Time[20], ss1);
      }
   
      if(ObjectFind("SS2 label") != 0)
      {
         ObjectCreate("SS2 label", OBJ_TEXT, 0, Time[20], ss2);
         ObjectSetText("S2 label", "S2 "+DoubleToStr(ss2,4), 8, "Arial", White);
      }
      else
      {
         ObjectSetText("SS2 label", "S2 "+DoubleToStr(ss2,4), 8, "Arial", White);
         ObjectMove("SS2 label", 0, Time[20], ss2);
      }
   
      if(ObjectFind("SS3 label") != 0)
      {
         ObjectCreate("SS3 label", OBJ_TEXT, 0, Time[20], ss3);
         ObjectSetText("SS3 label", "S3 "+DoubleToStr(ss3,4), 8, "Arial", White);
      }
      else
      {
         ObjectSetText("SS3 label", "S3 "+DoubleToStr(ss3,4), 8, "Arial", White);
         ObjectMove("SS3 label", 0, Time[20], ss3);
      }
      
//---- Set standard pivot lines on chart window    
   
      if(ObjectFind("SS1 line") != 0)
      {
         ObjectCreate("SS1 line", OBJ_HLINE, 0, Time[40], ss1);
         ObjectSet("SS1 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
         ObjectSet("SS1 line", OBJPROP_COLOR, LimeGreen);
      }
      else
      {
         ObjectMove("SS1 line", 0, Time[40], ss1);
      }
   
      if(ObjectFind("SS2 line") != 0)
      {
         ObjectCreate("SS2 line", OBJ_HLINE, 0, Time[40], ss2);
         ObjectSet("SS2 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
         ObjectSet("SS2 line", OBJPROP_COLOR, LimeGreen);
      }
      else
      {
         ObjectMove("SS2 line", 0, Time[40], ss2);
      }
   
      if(ObjectFind("SS3 line") != 0)
      {
         ObjectCreate("SS3 line", OBJ_HLINE, 0, Time[40], ss3);
         ObjectSet("SS3 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
         ObjectSet("SS3 line", OBJPROP_COLOR, LimeGreen);
      }
      else
      {
         ObjectMove("SS3 line", 0, Time[40], ss3);
      }
   
      if(ObjectFind("SP line") != 0)
      {
         ObjectCreate("SP line", OBJ_HLINE, 0, Time[40], sp);
         ObjectSet("SP line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
         ObjectSet("SP line", OBJPROP_COLOR, Magenta);
      }
      else
      {
         ObjectMove("SP line", 0, Time[40], sp);
      }
   
      if(ObjectFind("SR1 line") != 0)
      {
         ObjectCreate("SR1 line", OBJ_HLINE, 0, Time[40], sr1);
         ObjectSet("SR1 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
         ObjectSet("SR1 line", OBJPROP_COLOR, OrangeRed);
      }
      else
      {
         ObjectMove("SR1 line", 0, Time[40], sr1);
      }
   
      if(ObjectFind("SR2 line") != 0)
      {
         ObjectCreate("SR2 line", OBJ_HLINE, 0, Time[40], sr2);
         ObjectSet("SR2 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
         ObjectSet("SR2 line", OBJPROP_COLOR, OrangeRed);
      }
      else
      {
         ObjectMove("SR2 line", 0, Time[40], sr2);
      }
      
      if(ObjectFind("SR3 line") != 0)
      {
         ObjectCreate("SR3 line", OBJ_HLINE, 0, Time[40], sr3);
         ObjectSet("SR3 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
         ObjectSet("SR3 line", OBJPROP_COLOR, OrangeRed);
      }
      else
      {
         ObjectMove("SR3 line", 0, Time[40], sr3);
      }
   }
//---- End Of standard pivots      
//----------------------------------------------------------------------------------------------      
//---- Calculate Woody Pivots
   if(Show_Woodies_Pivots == 1)
   {
      p = (yesterday_high + yesterday_low + today_open + today_open) / 4;// Woodies Pivot
   	r1 = (2*p)-yesterday_low;
   	s1 = (2*p)-yesterday_high;
   	r2 = p+(yesterday_high - yesterday_low);
   	s2 = p-(yesterday_high - yesterday_low);
 
//---- Set Woody pivot line labels on chart window 

      if(ObjectFind("R1 label") != 0)
      {
         ObjectCreate("R1 label", OBJ_TEXT, 0, Time[20], r1);
         ObjectSetText("R1 label", "Woodies R1 "+DoubleToStr(r1,4), 8, "Arial", White);
      }
      else
      {
         ObjectSetText("R1 label", "Woodies R1 "+DoubleToStr(r1,4), 8, "Arial", White);
         ObjectMove("R1 label", 0, Time[20], r1);
      }
   
      if(ObjectFind("R2 label") != 0)
      {
         ObjectCreate("R2 label", OBJ_TEXT, 0, Time[20], r2);
         ObjectSetText("R2 label", "Woodies R2 "+DoubleToStr(r2,4), 8, "Arial", White);
      }
      else
      {
         ObjectSetText("R2 label", "Woodies R2 "+DoubleToStr(r2,4), 8, "Arial", White);
         ObjectMove("R2 label", 0, Time[20], r2);
      }
      
      if(ObjectFind("P label") != 0)
      {
         ObjectCreate("P label", OBJ_TEXT, 0, Time[20], p);
         ObjectSetText("P label", "Woodies Pivot "+DoubleToStr(p,4), 8, "Arial", White);
      }
      else
      {
         ObjectSetText("P label", "Woodies Pivot "+DoubleToStr(p,4), 8, "Arial", White);
         ObjectMove("P label", 0, Time[20], p);
      }
   
      if(ObjectFind("S1 label") != 0)
      {
         ObjectCreate("S1 label", OBJ_TEXT, 0, Time[20], s1);
         ObjectSetText("S1 label", "Woodies S1 "+DoubleToStr(s1,4), 8, "Arial", White);
      }
      else
      {
         ObjectSetText("S1 label", "Woodies S1 "+DoubleToStr(s1,4), 8, "Arial", White);
         ObjectMove("S1 label", 0, Time[20], s1);
      }
   
      if(ObjectFind("S2 label") != 0)
      {
         ObjectCreate("S2 label", OBJ_TEXT, 0, Time[20], s2);
         ObjectSetText("S2 label", "Woodies S2 "+DoubleToStr(s2,4), 8, "Arial", White);
      }
      else
      {
         ObjectSetText("S2 label", "Woodies S2 "+DoubleToStr(s2,4), 8, "Arial", White);
         ObjectMove("S2 label", 0, Time[20], s2);
      }     
   
//---- Set Woody pivot lines on chart window    
   
      if(ObjectFind("S1 line") != 0)
      {
         ObjectCreate("S1 line", OBJ_HLINE, 0, Time[40], s1);
         ObjectSet("S1 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
         ObjectSet("S1 line", OBJPROP_COLOR, LimeGreen);
      }
      else
      {
         ObjectMove("S1 line", 0, Time[40], s1);
      }
   
      if(ObjectFind("S2 line") != 0)
      {
         ObjectCreate("S2 line", OBJ_HLINE, 0, Time[40], s2);
         ObjectSet("S2 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
         ObjectSet("S2 line", OBJPROP_COLOR, LimeGreen);
      }
      else
      {
         ObjectMove("S2 line", 0, Time[40], s2);
      }
   
      if(ObjectFind("P line") != 0)
      {
         ObjectCreate("P line", OBJ_HLINE, 0, Time[40], p);
         ObjectSet("P line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
         ObjectSet("P line", OBJPROP_COLOR, Magenta);
      }
      else
      {
         ObjectMove("P line", 0, Time[40], p);
      }
   
      if(ObjectFind("R1 line") != 0)
      {
         ObjectCreate("R1 line", OBJ_HLINE, 0, Time[40], r1);
         ObjectSet("R1 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
         ObjectSet("R1 line", OBJPROP_COLOR, OrangeRed);
      }
      else
      {
         ObjectMove("R1 line", 0, Time[40], r1);
      }
   
      if(ObjectFind("R2 line") != 0)
      {
         ObjectCreate("R2 line", OBJ_HLINE, 0, Time[40], r2);
         ObjectSet("R2 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
         ObjectSet("R2 line", OBJPROP_COLOR, OrangeRed);
      }
      else
      {
         ObjectMove("R2 line", 0, Time[40], r2);
      }
   }
//---- End Of Woodies Pivots
//--------------------------------------------------------------------------------------------- 
//---- Calculate & Display Camarilla Equation Pivots 

   if(Show_Camarilla_Pivots == 1)
   {
//---- To display all 8 Camarilla pivots remove comment symbols and
//     add the appropriate object functions below 
   
   //	ch1 = ((yesterday_high - yesterday_low) * D1) + yesterday_close;
   //	ch2 = ((yesterday_high - yesterday_low) * D2) + yesterday_close;
   	ch3 = ((yesterday_high - yesterday_low)* D3) + yesterday_close;
   	ch4 = ((yesterday_high - yesterday_low)* D4) + yesterday_close;
   //	cl1 = yesterday_close - ((yesterday_high - yesterday_low)*(D1));
   //	cl2 = yesterday_close - ((yesterday_high - yesterday_low)*(D2));
   	cl3 = yesterday_close - ((yesterday_high - yesterday_low)*(D3));
   	cl4 = yesterday_close - ((yesterday_high - yesterday_low)*(D4));
 
//---- Set Camarilla pivots line labels on chart window 

      if(ObjectFind("CH3") != 0)
      {
         ObjectCreate("CH3", OBJ_TEXT, 0, Time[35], ch3);
         ObjectSetText("CH3","Camarilla H3 "+DoubleToStr(ch3,4) , 8, "Arial", White);
      }
      else
      {
         ObjectSetText("CH3","Camarilla H3 "+DoubleToStr(ch3,4) , 8, "Arial", White);
         ObjectMove("CH3", 0, Time[35], ch3);
      }
   
      if(ObjectFind("CH4") != 0)
      {
         ObjectCreate("CH4", OBJ_TEXT, 0, Time[35], ch4);
         ObjectSetText("CH4", "Camarilla H4 "+DoubleToStr(ch4,4), 8, "Arial", White);
      }
      else
      {
         ObjectSetText("CH4", "Camarilla H4 "+DoubleToStr(ch4,4), 8, "Arial", White);
         ObjectMove("CH4", 0, Time[35], ch4);
      }
   
      if(ObjectFind("CL3") != 0)
      {
         ObjectCreate("CL3", OBJ_TEXT, 0, Time[35], cl3);
         ObjectSetText("CL3", "Camarilla L3 "+DoubleToStr(cl3,4), 8, "Arial", White);
      }
      else
      {
         ObjectSetText("CL3", "Camarilla L3 "+DoubleToStr(cl3,4), 8, "Arial", White);
         ObjectMove("CL3", 0, Time[35 ], cl3);
      }
      
      if(ObjectFind("CL4") != 0)
      {
         ObjectCreate("CL4", OBJ_TEXT, 0, Time[ 35], cl4);
         ObjectSetText("CL4", "Camarilla L4 "+DoubleToStr(cl4,4), 8, "Arial", White);
      }
      else
      {
         ObjectSetText("CL4", "Camarilla L4 "+DoubleToStr(cl4,4), 8, "Arial", White);
         ObjectMove("CL4", 0, Time[35], cl4);
      }
   
//---- Set Camarilla pivots lines on chart window    
   
      if(ObjectFind("CH3line") != 0)
      {
         ObjectCreate("CH3line", OBJ_HLINE, 0, Time[40], ch3);
         ObjectSet("CH3line", OBJPROP_STYLE, STYLE_DOT);
         ObjectSet("CH3line", OBJPROP_COLOR, Red);
      }
      else
      {
         ObjectMove("CH3line", 0, Time[40], ch3);
      }
   
      if(ObjectFind("CH4line") != 0)
      {
         ObjectCreate("CH4line", OBJ_HLINE, 0, Time[40], ch4);
         ObjectSet("CH4line", OBJPROP_STYLE, STYLE_DOT);
         ObjectSet("CH4line", OBJPROP_COLOR, DodgerBlue);
      }
      else
      {
         ObjectMove("CH4line", 0, Time[40], ch4);
      }
   
      if(ObjectFind("CL3line") != 0)
      {
         ObjectCreate("CL3line", OBJ_HLINE, 0, Time[40], cl3);
         ObjectSet("CL3line", OBJPROP_STYLE, STYLE_DOT);
         ObjectSet("CL3line", OBJPROP_COLOR, Red);
      }
      else
      {
         ObjectMove("CL3line", 0, Time[40], cl3);
      }
   
      if(ObjectFind("CL4line") != 0)
      {
         ObjectCreate("CL4line", OBJ_HLINE, 0, Time[40], cl4);
         ObjectSet("CL4line", OBJPROP_STYLE, STYLE_DOT);
         ObjectSet("CL4line", OBJPROP_COLOR, DodgerBlue);
      }
      else
      {
         ObjectMove("CL4line", 0, Time[40], cl4);
      }
   }
//---- End Of Camarilla Pivots
//----------------------------------------------------------------------------------------------
//---- Calculate DeMark Pivots (Projected Daily High & Low)
   if(Show_Demark_Pivots == 1)
   {
   	if(yesterday_close < yesterday_open)
   	{
   		x = (yesterday_high + (2* yesterday_low) + yesterday_close);
   	}
   	if(yesterday_close > yesterday_open)
   	{
   		x = ((yesterday_high*2)	+ yesterday_low	+ yesterday_close);
   	}
   	if(yesterday_close == yesterday_open)
   	{
   		x = (yesterday_high + yesterday_low + (2* yesterday_close));
   	}	
	
   	dr = (x/2 - yesterday_low); //projected high
   	ds = (x/2 - yesterday_high); //projected low
 
//---- Set DeMark pivots line labels on chart window 

      if(ObjectFind("DS Label") != 0)
      {
         ObjectCreate("DS Label", OBJ_TEXT, 0, Time[55], ds);
         ObjectSetText("DS Label", "DeMark Projected Low "+DoubleToStr(ds,4), 8, "Arial", White);
      }
      else
      {
         ObjectSetText("DS Label", "DeMark Projected Low "+DoubleToStr(ds,4), 8, "Arial", White);
         ObjectMove("DS Label", 0, Time[55], ds);
      }
   
      if(ObjectFind("DR Label") != 0)
      {
         ObjectCreate("DR Label", OBJ_TEXT, 0, Time[55], dr);
         ObjectSetText("DR Label", "DeMark Projected High "+DoubleToStr(dr,4), 8, "Arial", White);
      }
      else
      {
         ObjectSetText("DR Label", "DeMark Projected High "+DoubleToStr(dr,4), 8, "Arial", White);
         ObjectMove("DR Label", 0, Time[55], dr);
      }
    
//---- Set DeMark pivots lines on chart window    
   
      if(ObjectFind("DS Line") != 0)
      {
         ObjectCreate("DS Line", OBJ_HLINE, 0, Time[50], ds);
         ObjectSet("DS Line", OBJPROP_STYLE, STYLE_DASHDOT);
         ObjectSet("DS Line", OBJPROP_COLOR, Red);
      }
      else
      {
         ObjectMove("DS Line", 0, Time[50], ds);
      }
   
      if(ObjectFind("DR Line") != 0)
      {
         ObjectCreate("DR Line", OBJ_HLINE, 0, Time[50], dr);
         ObjectSet("DR Line", OBJPROP_STYLE, STYLE_DASHDOT);
         ObjectSet("DR Line", OBJPROP_COLOR, Lime);
      }
      else
      {
         ObjectMove("DR Line", 0, Time[50], dr);
      } 
   }
//---- End Of Demark Pivots
//----------------------------------------------------------------------------------------------    
//---- Done
   return(0);
}
//+------------------------------------------------------------------+