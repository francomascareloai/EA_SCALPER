 
// #4X 2010 Fibo-Grid X12     \¦/
// Knowledge of the ancients (ò ó)
//______________________o0o___(_)___o0o_____
//___¦Xard777¦_____¦_____¦_____¦_____¦_2010_¦


#property indicator_chart_window
extern bool AutomaticallyAdjustToCurrentweek = false;
extern int TimeToAdjust;
extern int WeeksBackForHigh;
extern int WeeksBackForLow;
extern int WeeksBackForClose;
extern int WeeksBackForOpen;
extern int WeeksBackForPP;
extern int WeeksBackForEH;
extern int WeeksBackForEL;
 
extern color wColourOfLines8 = Orchid;
extern color wColourOfLines1 = Yellow;            ///Levels=high,low,
extern color wColourOfLines2 = Purple;    /// Levels=1,2,6,7,lightseagreen
extern color wColourOfLines3 = Olive;          /// Levels=PP
extern color wColourOfLines4 = DarkGoldenrod;         /// Levels=OPEN
extern color wColourOfLines5 = DeepPink;           ///B1,B8
extern color wColourOfLines6 = DarkGreen;
extern color wColourOfLines7 = Black;    ///3,5,B1,B2.B3,B4,B5,B6,B7,B8
extern color wColourOfLines9 = Red;


double Rates[][6];

double wfib000,
       wfib0625,
       wfib125,
       wfib1875,
       wfib25,
       wfib3125,
       wfib375,
       wfib4375,
       wfib50,
       wPP,
       wfib5625,
       wfib625,
       wfib6875,
       wfib75,
       wfib8125,
       wfib875,
       wfib9375,
       wfib100, 
       wprevRange,
       wclose,
       whigh,
       wlow,
       wrange,
       wpOP,
       
       wEH0625,
       wEH125,
       wEH1875,
       wEH25,
       wEH3125,
       wEH375,
       wEH4375,
       wEH50,
       wEH5625,
       wEH625,
       wEH6875,
       wEH75,
       wEH8125,
       wEH875,
       wEH9375,
       wEH101, 
       
       wEL0625,
       wEL125,
       wEL1875,
       wEL25,
       wEL3125,
       wEL375,
       wEL4375,
       wEL50,
       wEL5625,
       wEL625,
       wEL6875,
       wEL75,
       wEL8125,
       wEL875,
       wEL9375,
       wEL101, 
       objextsExist;
            
        
 bool objectsExist, highFirst;       
 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
wprevRange = 0;
objectsExist = false;

//----

 


   return(0);
 } 
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("wfib0625");
   ObjectDelete("wfib125");
   ObjectDelete("wfib1875");
   ObjectDelete("wfib25");
   ObjectDelete("mfib3125");
   ObjectDelete("wfib375");
   ObjectDelete("wfib4375");
   ObjectDelete("wfib5625");
   ObjectDelete("wfib625");
   ObjectDelete("wfib6875");
   ObjectDelete("wfib75");
   ObjectDelete("wfib8125");
   ObjectDelete("wfib875");
   ObjectDelete("wfib9375");
   ObjectDelete("wfib100");
   
   ObjectDelete("wEH0625");
   ObjectDelete("wEH125");
   ObjectDelete("wEH1875");
   ObjectDelete("wEH25");
   ObjectDelete("wEH3125");
   ObjectDelete("wEH375");
   ObjectDelete("wEH4375");
   ObjectDelete("wEH5625");
   ObjectDelete("wEH625");
   ObjectDelete("wEH6875");
   ObjectDelete("wEH75");
   ObjectDelete("wEH8125");
   ObjectDelete("wEH875");
   ObjectDelete("wEH9375");
   ObjectDelete("wEH101");
  
   ObjectDelete("wEL0625");
   ObjectDelete("wEL125");
   ObjectDelete("wEL1875");
   ObjectDelete("wEL25");
   ObjectDelete("wEL3125");
   ObjectDelete("wEL375");
   ObjectDelete("wEL4375");
   ObjectDelete("wEL5625");
   ObjectDelete("wEL625");
   ObjectDelete("wEL6875");
   ObjectDelete("wEL75");
   ObjectDelete("wEL8125");
   ObjectDelete("wEL875");
   ObjectDelete("wEL9375");
   ObjectDelete("wEL101");
 
    
   Comment(" ");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//---- 
   //Print(prevRange);
   ArrayCopyRates(Rates, Symbol(), PERIOD_W1);   
   
   if (AutomaticallyAdjustToCurrentweek == false) {
      if (Hour() >= 0 && Hour() < TimeToAdjust) {
         WeeksBackForHigh = 1;
         WeeksBackForLow = 1;
         WeeksBackForClose = 0;
         WeeksBackForOpen = 1;
         WeeksBackForPP = 0;
         WeeksBackForEH = 0;
         WeeksBackForEL = 0;
          
          
          
      }
      else if (Hour() >= WeeksBackForLow && Hour() <= 167) {
         WeeksBackForHigh = 1;
         WeeksBackForLow = 1;
         WeeksBackForClose = 0;
         WeeksBackForOpen = 1;
         WeeksBackForPP = 0;
         WeeksBackForEH = 0;
         WeeksBackForEL = 0;
              
          
      }
   }
   whigh = Rates[WeeksBackForHigh][3];
   wlow = Rates[WeeksBackForLow][2];
   wclose = Rates[WeeksBackForClose][1];
   wpOP = Rates[WeeksBackForOpen][1];
   wrange = whigh - wlow;
    
   
 if (wrange == whigh - wlow) {
      wfib000 = wlow;
      wclose = wclose;
      
      wPP = (whigh + wlow + wclose)/3;
      wpOP = wpOP;
      wfib0625 = (wrange * 0.0625) + wlow;
      wfib125 = (wrange * 0.125) + wlow;
      wfib1875 = (wrange * 0.1875) + wlow;
      wfib25 = (wrange * 0.25) + wlow;
      wfib3125 = (wrange * 0.3125) + wlow;
      wfib375 = (wrange * 0.375) + wlow;
      wfib4375 = (wrange * 0.4375) + wlow;
      wfib50 = (whigh + wlow) / 2;
      wPP = (whigh + wlow + wclose) / 3;
      wfib5625 = (wrange * 0.5625) + wlow;
      wfib625 = (wrange * 0.625) + wlow;
      wfib6875 = (wrange * 0.6875) + wlow;
      wfib75 = (wrange * 0.75) + wlow;
      wfib8125 = (wrange * 0.8125) + wlow;
      wfib875 = (wrange * 0.875) + wlow;
      wfib9375 = (wrange * 0.9375) + wlow;
      wfib100 = whigh;
      
      wEL9375 = wlow - (wrange * 0.0625);
      wEL875 = wlow - (wrange * 0.125);
      wEL8125 = wlow - (wrange * 0.1875);
      wEL75 = wlow - (wrange * 0.25);
      wEL6875 = wlow - (wrange * 0.3125);
      wEL625 = wlow - (wrange * 0.375);
      wEL5625 = wlow - (wrange * 0.4375);
      wEL50 = wlow - (wrange * 0.50);
      wEL4375 = wlow - (wrange * 0.5625);
      wEL375 = wlow - (wrange * 0.625);
      wEL3125 = wlow - (wrange * 0.6875);
      wEL25 = wlow - (wrange * 0.75);
      wEL1875 = wlow - (wrange * 0.8125);
      wEL125 = wlow - (wrange * 0.875);
      wEL0625 = wlow - (wrange * 0.9375);
      wEL101 = wlow - (wrange * 1.00);
      
      
      wEH0625 = whigh + (wrange * 0.0625);
      wEH125 = whigh + (wrange * 0.125);
      wEH1875 = whigh + (wrange * 0.1875);
      wEH25 = whigh + (wrange * 0.25);
      wEH3125 = whigh + (wrange * 0.3125);
      wEH375 = whigh + (wrange * 0.375);
      wEH4375 = whigh + (wrange * 0.4375);
      wEH50 = whigh + (wrange * 0.50);
      wEH5625 = whigh + (wrange * 0.5625);
      wEH625 = whigh + (wrange * 0.625);
      wEH6875 = whigh + (wrange * 0.6875);
      wEH75 = whigh + (wrange * 0.75);
      wEH8125 = whigh + (wrange * 0.8125);
      wEH875 = whigh + (wrange * 0.875);
      wEH9375 = whigh + (wrange * 0.9375);
      wEH101 = whigh + (wrange * 1.00);
       
   
wdrawLine(wfib000,"wfib000_wfib000",wColourOfLines1,1);
wdrawLabel("wLOW",wfib000,wColourOfLines1);
wdrawLine(wfib125,"wfib125_wfib125",wColourOfLines2,1);
wdrawLabel("wL1_12.50",wfib125,wColourOfLines6);
wdrawLine(wfib25,"wfib25_wfib25",wColourOfLines2,1);
wdrawLabel("wL2_25.00",wfib25,wColourOfLines6);
wdrawLine(wfib375,"wfib375_wfib375",wColourOfLines3,1);
wdrawLabel("wL3_37.50",wfib375,wColourOfLines6);
wdrawLine(wfib50,"wfib50_wfib50", wColourOfLines1,1);
wdrawLabel("wMID",wfib50,wColourOfLines1);
wdrawLine(wfib625,"wfib625_wfib625",wColourOfLines3,1);
wdrawLabel("wL5_62.50",wfib625,wColourOfLines6); 
wdrawLine(wfib75,"wfib75_wfib75",wColourOfLines2,1);
wdrawLabel("wL6_75.00",wfib75,wColourOfLines6); 
wdrawLine(wfib875,"wfib875_wfib875",wColourOfLines2,1);
wdrawLabel("wL7_87.50",wfib875,wColourOfLines6);
wdrawLine(wfib100,"wfib100_wfib100",wColourOfLines1,1);
wdrawLabel("wHIGH",wfib100,wColourOfLines1); 

wdrawLine(wPP,"wPP_wPP", wColourOfLines4,10);
wdrawLabel("wPP",wPP,wColourOfLines6);
wdrawLine(wclose,"wclose_wclose", wColourOfLines6,10);
wdrawLabel("wOPEN",wclose,wColourOfLines9); 
wdrawLine(wpOP,"wpOP_wpOP", wColourOfLines4,10);
wdrawLabel("wpOP",wpOP,wColourOfLines1); 

wdrawLine(wEH125,"wEH125_wEH125",wColourOfLines2,1);
wdrawLabel("EHL1_12.50",wEH125,wColourOfLines6);
wdrawLine(wEH25,"wEH25_wEH25",wColourOfLines2,1);
wdrawLabel("EHL2_25.00",wEH25,wColourOfLines6);
wdrawLine(wEH375,"wEH375_wEH375",wColourOfLines3,1);
wdrawLabel("EHL3_37.50",wEH375,wColourOfLines6);
wdrawLine(wEH50,"wEH50_wEH50", wColourOfLines1,1);
wdrawLabel("EHMID",wEH50,wColourOfLines1);
wdrawLine(wEH625,"wEH625_wEH625",wColourOfLines3,1);
wdrawLabel("EHL5_62.50",wEH625,wColourOfLines6); 
wdrawLine(wEH75,"wEH75_wEH75",wColourOfLines2,1);
wdrawLabel("EHl6_75.00",wEH75,wColourOfLines6); 
wdrawLine(wEH875,"wEH875_wEH875",wColourOfLines2,1);
wdrawLabel("EHL7_87.50",wEH875,wColourOfLines6);
wdrawLine(wEH101,"wEH101_wEH101",wColourOfLines1,1);
wdrawLabel("EHHIGH",wEH101,wColourOfLines1); 


wdrawLine(wEL125,"wEL125_wEL125",wColourOfLines2,1);
wdrawLabel("ELL1_12.50",wEL125,wColourOfLines6);
wdrawLine(wEL25,"wEL25_wEL25",wColourOfLines2,1);
wdrawLabel("ELL2_25.00",wEL25,wColourOfLines6);
wdrawLine(wEL375,"wEL375_wEL375",wColourOfLines3,1);
wdrawLabel("ELL3_37.50",wEL375,wColourOfLines6);
wdrawLine(wEL50,"wEL50_wEL50", wColourOfLines1,1);
wdrawLabel("ELMID",wEL50,wColourOfLines1);
wdrawLine(wEL625,"wEL625_wEL625",wColourOfLines3,1);
wdrawLabel("ELL5_62.50",wEL625,wColourOfLines6); 
wdrawLine(wEL75,"wEL75_wEL75",wColourOfLines2,1);
wdrawLabel("ELL6_75.00",wEL75,wColourOfLines6); 
wdrawLine(wEL875,"wEL875_wEL875",wColourOfLines2,1);
wdrawLabel("ELL7_87.50",wEL875,wColourOfLines6);
wdrawLine(wEL101,"wEL101_wEL101",wColourOfLines1,1);
wdrawLabel("ELLOW",wEL101,wColourOfLines1); 

 

}


 
//----
   return(0);
  }
//+------------------------------------------------------------------+
void wdrawLabel(string wname,double lvl,color Color)
{
    if(ObjectFind(wname) != 0)
    {
        ObjectCreate(wname, OBJ_TEXT, 0, Time[28], lvl);
        ObjectSetText(wname, wname, 7, "Arial", EMPTY);
        ObjectSet(wname, OBJPROP_COLOR, Color);
         
    }
    else
    {
        ObjectMove(wname, 0, Time[28], lvl);
    }
}

void wdrawLine(double lvl,string wname, color Col,int type)
{
         if(ObjectFind(wname) != 0)
         {
            ObjectCreate(wname, OBJ_TREND, 0, Time[40], lvl,Time[0],lvl);
            ObjectSet(wname, OBJPROP_RAY, false);
            
            if(type == 1)
            ObjectSet(wname, OBJPROP_STYLE, STYLE_SOLID);
            else
            ObjectSet(wname, OBJPROP_STYLE, STYLE_SOLID);
            
            ObjectSet(wname, OBJPROP_COLOR, Col);
            ObjectSet(wname,OBJPROP_WIDTH,2);
            
         }
         else
         {
            ObjectDelete(wname);
            ObjectCreate(wname, OBJ_TREND, 0, Time[40], lvl,Time[0],lvl);
            ObjectSet(wname, OBJPROP_RAY, false);
            
            if(type == 1)
            ObjectSet(wname, OBJPROP_STYLE, STYLE_SOLID);
            else
            ObjectSet(wname, OBJPROP_STYLE, STYLE_SOLID);
            
            ObjectSet(wname, OBJPROP_COLOR, Col);        
            ObjectSet(wname,OBJPROP_WIDTH,2);
          
         }
}