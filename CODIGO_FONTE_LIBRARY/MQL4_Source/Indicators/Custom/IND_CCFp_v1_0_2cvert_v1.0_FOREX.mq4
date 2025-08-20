//+------------------------------------------------------------------+
//|                                                  CCFp_v1.0.2.mq4 |
//|                                              SemSemFX@rambler.ru |
//|              http://onix-trade.net/forum/index.php?showtopic=107 |
//|                        Modifed version by Skyline on 09 Oct 2008 |
//+------------------------------------------------------------------+
// Rev. v1.0.1 ** Added +/-/= symbols to show strength of last 2 closed candles
//             ** Added IBFX symbols management
// Rev. v1.0.2 ** Fixed symbols paint issue whenever a new candle starts

#property copyright "SemSemFX@rambler.ru"
#property link      "http://onix-trade.net/forum/index.php?showtopic=107"
//----
extern string Indicator_ID = "CCFpcv:";
int Objs = 0;
//----
#property indicator_separate_window
#property indicator_buffers 8
extern string  m = "--Moving Average Types--";
extern string  m0 = " 0 = SMA";
extern string  m1 = " 1 = EMA";
extern string  m2 = " 2 = SMMA";
extern string  m3 = " 3 = LWMA";
extern string  m4 = " 4 = LSMA";
extern int     MA_Method = 3;
extern string  p = "--Applied Price Types--";
extern string  p0 = " 0 = close";
extern string  p1 = " 1 = open";
extern string  p2 = " 2 = high";
extern string  p3 = " 3 = low";
extern string  p4 = " 4 = median(high+low)/2";
extern string  p5 = " 5 = typical(high+low+close)/3";
extern string  p6 = " 6 = weighted(high+low+close+close)/4";
extern int     Price = 6;//0=close, 1=open, 2=high, 3=low, 4=median(high+low)/2, 5=typical(high+low+close)/3, 6=weighted(high+low+close+close)/4
extern int Fast = 3;
extern int Slow = 5;
extern bool USD = 1;
extern bool EUR = 1;
extern bool GBP = 1;
extern bool CHF = 1;
extern bool JPY = 1;
extern bool AUD = 1;
extern bool CAD = 1;
extern bool NZD = 1;
extern color Color_USD = Green;
extern color Color_EUR = Aqua;
extern color Color_GBP = Red;
extern color Color_CHF = Chocolate;
extern color Color_JPY = Maroon;
extern color Color_AUD = DarkOrange;
extern color Color_CAD = Purple;
extern color Color_NZD = Teal;
extern int Line_Thickness = 2;
extern int All_Bars = 200;
extern int Last_Bars = 0;
extern int Y_Top = 14;
extern int Y_Step = 15;
extern int TxtSize = 10;

//----
double arrUSD[];
double arrEUR[];
double arrGBP[];
double arrCHF[];
double arrJPY[];
double arrAUD[];
double arrCAD[];
double arrNZD[];

double   myPoint;
string Indicator_Name;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

   Indicator_Name = Indicator_ID;

/*
   if(USD)
       Indicator_Name = StringConcatenate(Indicator_Name, " USD");
   if(EUR)
       Indicator_Name = StringConcatenate(Indicator_Name, " EUR");
   if(GBP)
       Indicator_Name = StringConcatenate(Indicator_Name, " GBP");
   if(CHF)
       Indicator_Name = StringConcatenate(Indicator_Name, " CHF");
   if(AUD)
       Indicator_Name = StringConcatenate(Indicator_Name, " AUD");
   if(CAD)
       Indicator_Name = StringConcatenate(Indicator_Name, " CAD");
   if(JPY)
       Indicator_Name = StringConcatenate(Indicator_Name, " JPY");
   if(NZD)
       Indicator_Name = StringConcatenate(Indicator_Name, " NZD");
*/
   IndicatorShortName(Indicator_Name);


   int width = 0;
   if(0 > StringFind(Symbol(), "USD", 0))
       width = 1;
   else 
       width = Line_Thickness;
   SetIndexStyle(0, DRAW_LINE, DRAW_LINE, width, Color_USD);
   SetIndexBuffer(0, arrUSD);
   SetIndexLabel(0, "USD"); 
   if(0 > StringFind(Symbol(), "EUR", 0))
       width = 1;
   else 
       width = Line_Thickness;
   SetIndexStyle(1, DRAW_LINE, DRAW_LINE, width, Color_EUR);
   SetIndexBuffer(1, arrEUR);
   SetIndexLabel(1, "EUR"); 
   if(0 > StringFind(Symbol(), "GBP", 0))
       width = 1;
   else 
       width = Line_Thickness;
   SetIndexStyle(2, DRAW_LINE, DRAW_LINE, width, Color_GBP);
   SetIndexBuffer(2, arrGBP);
   SetIndexLabel(2, "GBP"); 
   if(0 > StringFind(Symbol(), "CHF", 0))
       width = 1;
   else 
       width = Line_Thickness;
   SetIndexStyle(3, DRAW_LINE, DRAW_LINE, width, Color_CHF);
   SetIndexBuffer(3, arrCHF);
   SetIndexLabel(3, "CHF"); 
   if(0 > StringFind(Symbol(), "JPY", 0))
       width = 1;
   else 
       width = Line_Thickness;
   SetIndexStyle(4, DRAW_LINE, DRAW_LINE, width, Color_JPY);
   SetIndexBuffer(4, arrJPY);
   SetIndexLabel(4, "JPY"); 
   if(0 > StringFind(Symbol(), "AUD", 0))
       width = 1;
   else 
       width = Line_Thickness;
   SetIndexStyle(5, DRAW_LINE, DRAW_LINE, width, Color_AUD);
   SetIndexBuffer(5, arrAUD);
   SetIndexLabel(5, "AUD"); 
   if(0 > StringFind(Symbol(), "CAD", 0))
       width = 1;
   else 
       width = Line_Thickness;
   SetIndexStyle(6, DRAW_LINE, DRAW_LINE, width, Color_CAD);
   SetIndexBuffer(6, arrCAD);
   SetIndexLabel(6, "CAD"); 
   if(0 > StringFind(Symbol(), "NZD", 0))
       width = 1;
   else 
       width = Line_Thickness;
   SetIndexStyle(7, DRAW_LINE, DRAW_LINE, width, Color_NZD);
   SetIndexBuffer(7, arrNZD);
   SetIndexLabel(7, "NZD"); 
//----

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   for(int i = 0; i < Objs; i++)
     {
      if(!ObjectDelete(Indicator_Name + i))
          Print("error: code #", GetLastError());
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   string sAUDUSD,sEURUSD,sUSDCHF,sNZDUSD,sGBPUSD,sUSDJPY,sUSDCAD;
   string AddChar;
   int limit;
   int counted_bars = IndicatorCounted();
//---- checking for possible errors
   if(counted_bars < 0) 
       return(-1);
//---- the last bar will be recounted
   if(All_Bars < 1)
       All_Bars = Bars;
   if(counted_bars > 0 && Last_Bars > 0) 
       counted_bars -= Last_Bars;
   limit = All_Bars;

//---- IBFX Changes 

//   if (StringFind(Symbol(),"m") != -1)
   if (StringLen(Symbol()) == 7)
   {
     AddChar = StringSubstr(Symbol(), 6, 1);
     sAUDUSD  = "AUDUSD" + AddChar;
     sEURUSD  = "EURUSD" + AddChar;
     sUSDCHF  = "USDCHF" + AddChar;
     sNZDUSD  = "NZDUSD" + AddChar;
     sGBPUSD  = "GBPUSD" + AddChar;
     sUSDJPY  = "USDJPY" + AddChar;
     sUSDCAD  = "USDCAD" + AddChar;
   } 
   else 
   {
     sAUDUSD  = "AUDUSD";
     sEURUSD  = "EURUSD";
     sUSDCHF  = "USDCHF";
     sNZDUSD  = "NZDUSD";
     sGBPUSD  = "GBPUSD";
     sUSDJPY  = "USDJPY";
     sUSDCAD  = "USDCAD";    
   }  
   
//---- main cycle
   for(int i = 0; i < limit; i++)
     {
       // Preliminary calculation
       if(EUR)
         {
           double EURUSD_Fast = ma(sEURUSD, Fast, MA_Method, Price, i);
           double EURUSD_Slow = ma(sEURUSD, Slow, MA_Method, Price, i);
           if(!EURUSD_Fast || !EURUSD_Slow)
               break;
         }
       if(GBP)
         {
           double GBPUSD_Fast = ma(sGBPUSD, Fast, MA_Method, Price, i);
           double GBPUSD_Slow = ma(sGBPUSD, Slow, MA_Method, Price, i);
           if(!GBPUSD_Fast || !GBPUSD_Slow)
               break;
         }
       if(AUD)
         {
           double AUDUSD_Fast = ma(sAUDUSD, Fast, MA_Method, Price, i);
           double AUDUSD_Slow = ma(sAUDUSD, Slow, MA_Method, Price, i);
           if(!AUDUSD_Fast || !AUDUSD_Slow)
               break;
         }
       if(NZD)
         {
           double NZDUSD_Fast = ma(sNZDUSD, Fast, MA_Method, Price, i);
           double NZDUSD_Slow = ma(sNZDUSD, Slow, MA_Method, Price, i);
           if(!NZDUSD_Fast || !NZDUSD_Slow)
               break;
         }
       if(CAD)
         {
           double USDCAD_Fast = ma(sUSDCAD, Fast, MA_Method, Price, i);
           double USDCAD_Slow = ma(sUSDCAD, Slow, MA_Method, Price, i);
           if(!USDCAD_Fast || !USDCAD_Slow)
               break;
         }
       if(CHF)
         {
           double USDCHF_Fast = ma(sUSDCHF, Fast, MA_Method, Price, i);
           double USDCHF_Slow = ma(sUSDCHF, Slow, MA_Method, Price, i);
           if(!USDCHF_Fast || !USDCHF_Slow)
               break;
         }
       if(JPY)
         {
           double USDJPY_Fast = ma(sUSDJPY, Fast, MA_Method, Price, i);
           double USDJPY_Slow = ma(sUSDJPY, Slow, MA_Method, Price, i);
           if(!USDJPY_Fast || !USDJPY_Slow)
               break;
         }
       // calculation of currencies 
       if(USD)
         {
           arrUSD[i] = 0;
           if(EUR) 
               arrUSD[i] += EURUSD_Slow / EURUSD_Fast - 1;
           if(GBP) 
               arrUSD[i] += GBPUSD_Slow / GBPUSD_Fast - 1;
           if(AUD) 
               arrUSD[i] += AUDUSD_Slow / AUDUSD_Fast - 1;
           if(NZD) 
               arrUSD[i] += NZDUSD_Slow / NZDUSD_Fast - 1;
           if(CHF) 
               arrUSD[i] += USDCHF_Fast / USDCHF_Slow - 1;
           if(CAD) 
               arrUSD[i] += USDCAD_Fast / USDCAD_Slow - 1;
           if(JPY) 
               arrUSD[i] += USDJPY_Fast / USDJPY_Slow - 1;
         }// end if USD
       if(EUR)
         {
           arrEUR[i] = 0;
           if(USD) 
               arrEUR[i] += EURUSD_Fast / EURUSD_Slow - 1;
           if(GBP) 
               arrEUR[i] += (EURUSD_Fast / GBPUSD_Fast) / 
                            (EURUSD_Slow/GBPUSD_Slow) - 1;
           if(AUD) 
               arrEUR[i] += (EURUSD_Fast / AUDUSD_Fast) / 
                            (EURUSD_Slow/AUDUSD_Slow) - 1;
           if(NZD) 
               arrEUR[i] += (EURUSD_Fast / NZDUSD_Fast) / 
                            (EURUSD_Slow/NZDUSD_Slow) - 1;
           if(CHF) 
               arrEUR[i] += (EURUSD_Fast*USDCHF_Fast) / 
                            (EURUSD_Slow*USDCHF_Slow) - 1;
           if(CAD) 
               arrEUR[i] += (EURUSD_Fast*USDCAD_Fast) / 
                            (EURUSD_Slow*USDCAD_Slow) - 1;
           if(JPY) 
               arrEUR[i] += (EURUSD_Fast*USDJPY_Fast) / 
                            (EURUSD_Slow*USDJPY_Slow) - 1;
         }// end if EUR
       if(GBP)
         {
           arrGBP[i] = 0;
           if(USD) 
               arrGBP[i] += GBPUSD_Fast / GBPUSD_Slow - 1;
           if(EUR) 
               arrGBP[i] += (EURUSD_Slow / GBPUSD_Slow) / 
                            (EURUSD_Fast / GBPUSD_Fast) - 1;
           if(AUD) 
               arrGBP[i] += (GBPUSD_Fast / AUDUSD_Fast) / 
                            (GBPUSD_Slow / AUDUSD_Slow) - 1;
           if(NZD) 
               arrGBP[i] += (GBPUSD_Fast / NZDUSD_Fast) / 
                            (GBPUSD_Slow / NZDUSD_Slow) - 1;
           if(CHF) 
               arrGBP[i] += (GBPUSD_Fast*USDCHF_Fast) / 
                            (GBPUSD_Slow*USDCHF_Slow) - 1;
           if(CAD) 
               arrGBP[i] += (GBPUSD_Fast*USDCAD_Fast) / 
                            (GBPUSD_Slow*USDCAD_Slow) - 1;
           if(JPY) 
               arrGBP[i] += (GBPUSD_Fast*USDJPY_Fast) / 
                            (GBPUSD_Slow*USDJPY_Slow) - 1;
          }// end if GBP
       if(AUD)
         {
           arrAUD[i] = 0;
           if(USD) 
               arrAUD[i] += AUDUSD_Fast / AUDUSD_Slow - 1;
           if(EUR) 
               arrAUD[i] += (EURUSD_Slow / AUDUSD_Slow) / 
                            (EURUSD_Fast / AUDUSD_Fast) - 1;
           if(GBP) 
               arrAUD[i] += (GBPUSD_Slow / AUDUSD_Slow) / 
                            (GBPUSD_Fast / AUDUSD_Fast) - 1;
           if(NZD) 
               arrAUD[i] += (AUDUSD_Fast/NZDUSD_Fast) / 
                            (AUDUSD_Slow / NZDUSD_Slow) - 1;
           if(CHF) 
               arrAUD[i] += (AUDUSD_Fast*USDCHF_Fast) / 
                            (AUDUSD_Slow*USDCHF_Slow) - 1;
           if(CAD) 
               arrAUD[i] += (AUDUSD_Fast*USDCAD_Fast) / 
                            (AUDUSD_Slow*USDCAD_Slow) - 1;
           if(JPY) 
               arrAUD[i] += (AUDUSD_Fast*USDJPY_Fast) / 
                            (AUDUSD_Slow*USDJPY_Slow) - 1;
         }// end if AUD
       if(NZD)
         {
           arrNZD[i] = 0;
           if(USD) 
               arrNZD[i] += NZDUSD_Fast / NZDUSD_Slow - 1;
           if(EUR) 
               arrNZD[i] += (EURUSD_Slow / NZDUSD_Slow) / 
                            (EURUSD_Fast/NZDUSD_Fast) - 1;
           if(GBP) 
               arrNZD[i] += (GBPUSD_Slow / NZDUSD_Slow) / 
                            (GBPUSD_Fast / NZDUSD_Fast) - 1;
           if(AUD) 
               arrNZD[i] += (AUDUSD_Slow / NZDUSD_Slow) / 
                            (AUDUSD_Fast / NZDUSD_Fast) - 1;
           if(CHF) 
               arrNZD[i] += (NZDUSD_Fast*USDCHF_Fast) / 
                            (NZDUSD_Slow*USDCHF_Slow) - 1;
           if(CAD) 
               arrNZD[i] += (NZDUSD_Fast*USDCAD_Fast) / 
                            (NZDUSD_Slow*USDCAD_Slow) - 1;
           if(JPY) 
               arrNZD[i] += (NZDUSD_Fast*USDJPY_Fast) / 
                            (NZDUSD_Slow*USDJPY_Slow) - 1;
         }// end if NZD
       if(CAD)
         {
           arrCAD[i] = 0;
           if(USD) 
               arrCAD[i] += USDCAD_Slow / USDCAD_Fast - 1;
           if(EUR) 
               arrCAD[i] += (EURUSD_Slow*USDCAD_Slow) / 
                            (EURUSD_Fast*USDCAD_Fast) - 1;
           if(GBP) 
               arrCAD[i] += (GBPUSD_Slow*USDCAD_Slow) / 
                            (GBPUSD_Fast*USDCAD_Fast) - 1;
           if(AUD) 
               arrCAD[i] += (AUDUSD_Slow*USDCAD_Slow) / 
                            (AUDUSD_Fast*USDCAD_Fast) - 1;
           if(NZD) 
               arrCAD[i] += (NZDUSD_Slow*USDCAD_Slow) / 
                            (NZDUSD_Fast*USDCAD_Fast) - 1;
           if(CHF) 
               arrCAD[i] += (USDCHF_Fast / USDCAD_Fast) / 
                            (USDCHF_Slow / USDCAD_Slow) - 1;
           if(JPY) 
               arrCAD[i] += (USDJPY_Fast / USDCAD_Fast) / 
                            (USDJPY_Slow / USDCAD_Slow) - 1;
         }// end if CAD
       if(CHF)
         {
           arrCHF[i] = 0;
           if(USD) 
               arrCHF[i] += USDCHF_Slow / USDCHF_Fast - 1;
           if(EUR) 
               arrCHF[i] += (EURUSD_Slow*USDCHF_Slow) / 
                            (EURUSD_Fast*USDCHF_Fast) - 1;
           if(GBP) 
               arrCHF[i] += (GBPUSD_Slow*USDCHF_Slow) / 
                            (GBPUSD_Fast*USDCHF_Fast) - 1;
           if(AUD) 
               arrCHF[i] += (AUDUSD_Slow*USDCHF_Slow) / 
                            (AUDUSD_Fast*USDCHF_Fast) - 1;
           if(NZD) 
               arrCHF[i] += (NZDUSD_Slow*USDCHF_Slow) / 
                            (NZDUSD_Fast*USDCHF_Fast) - 1;
           if(CAD) 
               arrCHF[i] += (USDCHF_Slow / USDCAD_Slow) / 
                            (USDCHF_Fast / USDCAD_Fast) - 1;
           if(JPY) 
               arrCHF[i] += (USDJPY_Fast / USDCHF_Fast) / 
                            (USDJPY_Slow / USDCHF_Slow) - 1;
         }// end if CHF
       if(JPY)
         {
           arrJPY[i] = 0;
           if(USD) 
               arrJPY[i] += USDJPY_Slow / USDJPY_Fast - 1;
           if(EUR) 
               arrJPY[i] += (EURUSD_Slow*USDJPY_Slow) / 
                            (EURUSD_Fast*USDJPY_Fast) - 1;
           if(GBP) 
               arrJPY[i] += (GBPUSD_Slow*USDJPY_Slow) / 
                            (GBPUSD_Fast*USDJPY_Fast) - 1;
           if(AUD) 
               arrJPY[i] += (AUDUSD_Slow*USDJPY_Slow) / 
                            (AUDUSD_Fast*USDJPY_Fast) - 1;
           if(NZD) 
               arrJPY[i] += (NZDUSD_Slow*USDJPY_Slow) / 
                            (NZDUSD_Fast*USDJPY_Fast) - 1;
           if(CAD) 
               arrJPY[i] += (USDJPY_Slow/USDCAD_Slow) / 
                            (USDJPY_Fast/USDCAD_Fast) - 1;
           if(CHF) 
               arrJPY[i] += (USDJPY_Slow/USDCHF_Slow) / 
                            (USDJPY_Fast/USDCHF_Fast) - 1;
         }// end if JPY
     }//end block for(int i=0; i<limit; i++)
   int cur = Y_Top; 
//   int st = 23;      
   int st = Y_Step;      
   if(USD)
     {
       if (arrUSD[2]<arrUSD[1])  sl("USD", arrUSD[1] - arrUSD[2], "SymbUSD","+", cur, Color_USD);
       if (arrUSD[2]>arrUSD[1])  sl("USD", arrUSD[1] - arrUSD[2], "SymbUSD","-", cur, Color_USD);       
       if (arrUSD[2]==arrUSD[1]) sl("USD", arrUSD[1] - arrUSD[2], "SymbUSD","=", cur, Color_USD);              
       cur += st;
     }
   if(EUR)
     {
       if (arrEUR[2]<arrEUR[1])  sl("EUR", arrEUR[1] - arrEUR[2], "SymbEUR","+", cur, Color_EUR);
       if (arrEUR[2]>arrEUR[1])  sl("EUR", arrEUR[1] - arrEUR[2], "SymbEUR","-", cur, Color_EUR);       
       if (arrEUR[2]==arrEUR[1]) sl("EUR", arrEUR[1] - arrEUR[2], "SymbEUR","=", cur, Color_EUR);        
       cur += st;
     }
   if(GBP)
     {
       if (arrGBP[2]<arrGBP[1])  sl("GBP", arrGBP[1] - arrGBP[2], "SymbGBP","+", cur, Color_GBP);
       if (arrGBP[2]>arrGBP[1])  sl("GBP", arrGBP[1] - arrGBP[2], "SymbGBP","-", cur, Color_GBP);       
       if (arrGBP[2]==arrGBP[1]) sl("GBP", arrGBP[1] - arrGBP[2], "SymbGBP","=", cur, Color_GBP);     
       cur += st;
     }
   if(CHF)
     {
       if (arrCHF[2]<arrCHF[1])  sl("CHF", arrCHF[1] - arrCHF[2], "SymbCHF","+", cur, Color_CHF);
       if (arrCHF[2]>arrCHF[1])  sl("CHF", arrCHF[1] - arrCHF[2], "SymbCHF","-", cur, Color_CHF);       
       if (arrCHF[2]==arrCHF[1]) sl("CHF", arrCHF[1] - arrCHF[2], "SymbCHF","=", cur, Color_CHF); 
       cur += st;
     }
   if(AUD)
     {
       if (arrAUD[2]<arrAUD[1])  sl("AUD", arrAUD[1] - arrAUD[2], "SymbAUD","+", cur, Color_AUD);
       if (arrAUD[2]>arrAUD[1])  sl("AUD", arrAUD[1] - arrAUD[2], "SymbAUD","-", cur, Color_AUD);       
       if (arrAUD[2]==arrAUD[1]) sl("AUD", arrAUD[1] - arrAUD[2], "SymbAUD","=", cur, Color_AUD); 
       cur += st;
     }
   if(CAD)
     {
       if (arrCAD[2]<arrCAD[1])  sl("CAD", arrCAD[1] - arrCAD[2], "SymbCAD","+", cur, Color_CAD);
       if (arrCAD[2]>arrCAD[1])  sl("CAD", arrCAD[1] - arrCAD[2], "SymbCAD","-", cur, Color_CAD);       
       if (arrCAD[2]==arrCAD[1]) sl("CAD", arrCAD[1] - arrCAD[2], "SymbCAD","=", cur, Color_CAD); 
       cur += st;
     }
   if(JPY)
     {
       if (arrJPY[2]<arrJPY[1])  sl("JPY", arrJPY[1] - arrJPY[2], "SymbJPY","+", cur, Color_JPY);
       if (arrJPY[2]>arrJPY[1])  sl("JPY", arrJPY[1] - arrJPY[2], "SymbJPY","-", cur, Color_JPY);       
       if (arrJPY[2]==arrJPY[1]) sl("JPY", arrJPY[1] - arrJPY[2], "SymbJPY","=", cur, Color_JPY);     
       cur += st;
     }
   if(NZD)
     {
       if (arrNZD[2]<arrNZD[1])  sl("NZD", arrNZD[1] - arrNZD[2], "SymbNZD","+", cur, Color_NZD);
       if (arrNZD[2]>arrNZD[1])  sl("NZD", arrNZD[1] - arrNZD[2], "SymbNZD","-", cur, Color_NZD);       
       if (arrNZD[2]==arrNZD[1]) sl("NZD", arrNZD[1] - arrNZD[2], "SymbNZD","=", cur, Color_NZD);         
       cur += st;
     }     
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|  Subroutines                                                     |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| LSMA with PriceMode                                              |
//| PrMode  0=close, 1=open, 2=high, 3=low, 4=median(high+low)/2,    |
//| 5=typical(high+low+close)/3, 6=weighted(high+low+close+close)/4  |
//+------------------------------------------------------------------+

double LSMA(string symb, int TimeFrame, int Rperiod, int prMode, int shift)
{
   int i, myShift;
   double sum, pr;
   int length;
   double lengthvar;
   double tmp;
   double wt;

   length = Rperiod;
   myPoint = SetPoint(symb);
 
   sum = 0;
   for(i = length; i >= 1  ; i--)
   {
     lengthvar = length + 1;
     lengthvar /= 3;
     tmp = 0;
     myShift = length - i + shift;
     switch (prMode)
     {
     case 0: pr = iClose(symb,TimeFrame,myShift);break;
     case 1: pr = iOpen(symb,TimeFrame,myShift);break;
     case 2: pr = iHigh(symb,TimeFrame,myShift);break;
     case 3: pr = iLow(symb,TimeFrame,myShift);break;
     case 4: pr = (iHigh(symb,TimeFrame,myShift) + iLow(symb,TimeFrame,myShift))/2;break;
     case 5: pr = (iHigh(symb,TimeFrame,myShift) + iLow(symb,TimeFrame,myShift) + iClose(symb,TimeFrame,myShift))/3;break;
     case 6: pr = (iHigh(symb,TimeFrame,myShift) + iLow(symb,TimeFrame,myShift) + iClose(symb,TimeFrame,myShift) + iClose(symb,TimeFrame,myShift))/4;break;
     }
     tmp = ( i - lengthvar)*pr;
     sum+=tmp;
    }
    wt = sum*6/(length*(length+1));
    wt = MathFloor(wt/myPoint)*myPoint;
    
    return(wt);
}

double ma(string sym, int per, int Mode, int Price, int i)
  {
   double res = 0;
   int k = 1;
   int ma_shift = 0;
   int tf = 0;
   
   if (Mode == 4)
   {
   switch(Period())
     {
       case 1:     res += LSMA(sym, tf, per*k, Price,i); 
                   k += 5;
       case 5:     res += LSMA(sym, tf, per*k, Price,i); 
                   k += 3;
       case 15:    res += LSMA(sym, tf, per*k, Price,i); 
                   k += 2;
       case 30:    res += LSMA(sym, tf, per*k, Price,i); 
                   k += 2;
       case 60:    res += LSMA(sym, tf, per*k, Price,i); 
                   k += 4;
       case 240:   res += LSMA(sym, tf, per*k, Price,i); 
                   k += 6;
       case 1440:  res += LSMA(sym, tf, per*k, Price,i); 
                   k += 4;
       case 10080: res += LSMA(sym, tf, per*k, Price,i); 
                   k +=4;
       case 43200: res += LSMA(sym, tf, per*k, Price,i); 
     } 
   }
   else
   {
       
   switch(Period())
     {
       case 1:     res += iMA(sym, tf, per*k, ma_shift, Mode, Price, i); 
                   k += 5;
       case 5:     res += iMA(sym, tf, per*k, ma_shift, Mode, Price, i); 
                   k += 3;
       case 15:    res += iMA(sym, tf, per*k, ma_shift, Mode, Price, i); 
                   k += 2;
       case 30:    res += iMA(sym, tf, per*k, ma_shift, Mode, Price, i); 
                   k += 2;
       case 60:    res += iMA(sym, tf, per*k, ma_shift, Mode, Price, i); 
                   k += 4;
       case 240:   res += iMA(sym, tf, per*k, ma_shift, Mode, Price, i); 
                   k += 6;
       case 1440:  res += iMA(sym, tf, per*k, ma_shift, Mode, Price, i); 
                   k += 4;
       case 10080: res += iMA(sym, tf, per*k, ma_shift, Mode, Price, i); 
                   k +=4;
       case 43200: res += iMA(sym, tf, per*k, ma_shift, Mode, Price, i); 
     } 
   }
   return(res);
  }   
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void sl(string currency, double diff, string IndicatoreName, string sym, int y, color col)
  {
   int window = WindowFind(Indicator_Name);
   string ID = Indicator_Name+Objs;
   string mIndicatoreName, disp;
   mIndicatoreName =  Indicator_ID + IndicatoreName;
   int tmp = 10 + y;
   Objs++;
   disp = currency + " " + sym + "  " + DoubleToStr(diff*100000.0, 2);
   if (ObjectFind(mIndicatoreName)==-1)
   {
    if(ObjectCreate(mIndicatoreName, OBJ_LABEL, window, 0, 0))
     {
       //ObjectDelete(ID);
       ObjectSet(mIndicatoreName, OBJPROP_XDISTANCE, 10);
       ObjectSet(mIndicatoreName, OBJPROP_YDISTANCE, y);
       ObjectSetText(mIndicatoreName, disp, TxtSize, "Arial Black", col);
     }   
   }
   else
   {
     ObjectSet(mIndicatoreName, OBJPROP_XDISTANCE, 10);
     ObjectSet(mIndicatoreName, OBJPROP_YDISTANCE, y);
     ObjectSetText(mIndicatoreName, disp, TxtSize, "Arial Black", col);        
   }
   
/*   if(ObjectCreate(ID, OBJ_LABEL, window, 0, 0))
     {
       //ObjectDelete(ID);
       ObjectSet(ID, OBJPROP_XDISTANCE, y + 35);
       ObjectSet(ID, OBJPROP_YDISTANCE, 10);
       ObjectSetText(ID, sym, 15, "Arial Black", col);
     }
*/     
  }   


double SetPoint(string mySymbol)
{
   double mPoint, myDigits;
   
   myDigits = MarketInfo (mySymbol, MODE_DIGITS);
   if (myDigits < 4)
      mPoint = 0.01;
   else
      mPoint = 0.0001;
   
   return(mPoint);
}

//+------------------------------------------------------------------+

