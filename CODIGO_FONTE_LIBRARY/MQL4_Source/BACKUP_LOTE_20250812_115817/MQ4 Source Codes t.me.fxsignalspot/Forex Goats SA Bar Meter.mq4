//+------------------------------------------------------------------+
//|                                               FX Multi-Meter v.1 |
//|                                        Copyright © 2009, J.Arent |
//|                                           josharent@yahoo.com.au |
//|             Inspired by !x-meter (Special thanks to Robert Hill) |
//+------------------------------------------------------------------+
#property copyright "©J.Arent 2009"
#property indicator_chart_window

extern string StochsValues = "== Stochastic Oscillators ==";
extern int Stoch_K = 14;
extern int Stoch_D = 3;
extern int Stoch_Slowing = 3;
extern string MAvalues = "== Moving Averages ==";
extern int MA_Period = 14;
extern int MA_Shift = 0;
extern string MACDvalues = "== MACD ==";
extern int MACD_Period1 = 12;
extern int MACD_Period2 = 26;
extern int MACD_Period3 = 9;
extern string MAXvalues = "== MA Xover ==";
extern int FastLWMA = 3;
extern int SlowSMA = 5;
extern string PSARvalues = "== Parabolic SAR ==";
extern double PSAR_Step = 0.02;
extern double PSAR_Max = 0.2;

//+------------------------------------------------------------------+
//     expert initialization function                                |       
//+------------------------------------------------------------------+
int init()
  {
   int   err,lastError;
//----
   initGraph();
   //while (true)                                                             
      {
      if (IsConnected()) main();
      if (!IsConnected()) objectBlank();
      //WindowRedraw();
      //Sleep(50);                                                         
      }
//----
   return(0);                                                              
  }
//+------------------------------------------------------------------+
//     expert deinitialization function                              |       
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectsDeleteAll(0,OBJ_LABEL);
   Print("shutdown error - ",GetLastError());                               
//----
   return(0);                                                             
  }
//+------------------------------------------------------------------+
//     expert start function                                         |       
//+------------------------------------------------------------------+
int start()
  {
    if (Bars<10) return(0);
//----
    if (IsConnected()) main();
    if (!IsConnected()) objectBlank();   
//----
   return(0);                                                               
  }
//+------------------------------------------------------------------+
//     expert custom function                                        |       
//+------------------------------------------------------------------+    
void main()                                                             
  {   
   RefreshRates();  
   // Variables -------------------
   double M1stochK,M1stochD,M5stochK,M5stochD,M15stochK,M15stochD,M30stochK,M30stochD,H1stochK,H1stochD,H4stochK,H4stochD,D1stochK,D1stochD,StochK,StochD,StochKprev,StochDprev;
   double MAM1,MAM5,MAM15,MAM30,MAH1,MAH4,MAD1,MAM1prev,MAM5prev,MAM15prev,MAM30prev,MAH1prev,MAH4prev,MAD1prev,MACurrent,MAPrevious;
   double Spread,PSARCurrent,PSARPrev,MACDCurrent,MACDPrev,MACDSignal,MACDSignalPrev,MAXover1,MAXover2,VolumePercent,Vol,VolPrev,WPR,Bar1,Bar2,Bar3,Bar4,Bar5,Bar6,Bar7,Bar8,Bar9,Bar10;
   double Bar1percent,Bar2percent,Bar3percent,Bar4percent,Bar5percent,BarsAverage1,BarsAverage2,BarsAverage3,BarsAverage4,BarsAverage5,BarsAllpercent;
   int trendM1,trendM5,trendM15,trendM30,trendH1,trendH4,trendD1,PSAR,MACD,MAXoverSignal,VolValue,WPRValueUp,WPRValueDown,Bar1Col,Bar2Col,Bar3Col,Bar4Col,Bar5Col,BarReading,Signal;
   
   // Stochs ----------------------------------------------------------------------------------------------  
   M1stochK = iStochastic(Symbol(), PERIOD_M1, Stoch_K,Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_MAIN, 0);
   M1stochD = iStochastic(Symbol(), PERIOD_M1, Stoch_K,Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_SIGNAL, 0);
   M5stochK = iStochastic(Symbol(), PERIOD_M5, Stoch_K,Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_MAIN, 0);
   M5stochD = iStochastic(Symbol(), PERIOD_M5, Stoch_K,Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_SIGNAL, 0);
   M15stochK = iStochastic(Symbol(), PERIOD_M15, Stoch_K,Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_MAIN, 0);
   M15stochD = iStochastic(Symbol(), PERIOD_M15, Stoch_K,Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_SIGNAL, 0);
   M30stochK = iStochastic(Symbol(), PERIOD_M30, Stoch_K,Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_MAIN, 0);
   M30stochD = iStochastic(Symbol(), PERIOD_M30, Stoch_K,Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_SIGNAL, 0);
   H1stochK = iStochastic(Symbol(), PERIOD_H1, Stoch_K,Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_MAIN, 0);
   H1stochD = iStochastic(Symbol(), PERIOD_H1, Stoch_K,Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_SIGNAL, 0);
   H4stochK = iStochastic(Symbol(), PERIOD_H4, Stoch_K,Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_MAIN, 0);
   H4stochD = iStochastic(Symbol(), PERIOD_H4, Stoch_K,Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_SIGNAL, 0);
   D1stochK = iStochastic(Symbol(), PERIOD_D1, Stoch_K,Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_MAIN, 0);
   D1stochD = iStochastic(Symbol(), PERIOD_D1, Stoch_K,Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_SIGNAL, 0);  
   StochK = iStochastic(Symbol(), 0, Stoch_K,Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_MAIN, 0);
   StochD = iStochastic(Symbol(), 0, Stoch_K,Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_SIGNAL, 0);
   StochKprev = iStochastic(Symbol(), 0, Stoch_K,Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_MAIN, 1);
   StochDprev = iStochastic(Symbol(), 0, Stoch_K,Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_SIGNAL, 1);
   
   // MA's ---------------------------------------------------------- 
   MAM1=iMA(NULL,PERIOD_M1,MA_Period,MA_Shift,MODE_EMA,PRICE_CLOSE,0);
   MAM5=iMA(NULL,PERIOD_M5,MA_Period,MA_Shift,MODE_EMA,PRICE_CLOSE,0);
   MAM15=iMA(NULL,PERIOD_M15,MA_Period,MA_Shift,MODE_EMA,PRICE_CLOSE,0);
   MAM30=iMA(NULL,PERIOD_M30,MA_Period,MA_Shift,MODE_EMA,PRICE_CLOSE,0);
   MAH1=iMA(NULL,PERIOD_H1,MA_Period,MA_Shift,MODE_EMA,PRICE_CLOSE,0);
   MAH4=iMA(NULL,PERIOD_H4,MA_Period,MA_Shift,MODE_EMA,PRICE_CLOSE,0);
   MAD1=iMA(NULL,PERIOD_D1,MA_Period,MA_Shift,MODE_EMA,PRICE_CLOSE,0);
   
   MAM1prev=iMA(NULL,PERIOD_M1,MA_Period,MA_Shift,MODE_EMA,PRICE_CLOSE,1);
   MAM5prev=iMA(NULL,PERIOD_M5,MA_Period,MA_Shift,MODE_EMA,PRICE_CLOSE,1);
   MAM15prev=iMA(NULL,PERIOD_M15,MA_Period,MA_Shift,MODE_EMA,PRICE_CLOSE,1);
   MAM30prev=iMA(NULL,PERIOD_M30,MA_Period,MA_Shift,MODE_EMA,PRICE_CLOSE,1);
   MAH1prev=iMA(NULL,PERIOD_H1,MA_Period,MA_Shift,MODE_EMA,PRICE_CLOSE,1);
   MAH4prev=iMA(NULL,PERIOD_H4,MA_Period,MA_Shift,MODE_EMA,PRICE_CLOSE,1);
   MAD1prev=iMA(NULL,PERIOD_D1,MA_Period,MA_Shift,MODE_EMA,PRICE_CLOSE,1);
   
   MACurrent=iMA(NULL,0,MA_Period,MA_Shift,MODE_EMA,PRICE_CLOSE,0);
   MAPrevious=iMA(NULL,0,MA_Period,MA_Shift,MODE_EMA,PRICE_CLOSE,1);   
   
      if(MAM1 > MAM1prev)  
     {
      trendM1=1;
     }   
     if(MAM1 < MAM1prev)  
     {
      trendM1=0;
     }     
     if(MAM5 > MAM5prev)  
     {
      trendM5=1;
     }   
     if(MAM5 < MAM5prev)  
     {
      trendM5=0;
     }    
     if(MAM15 > MAM15prev)  
     {
      trendM15=1;
     } 
     if(MAM15 < MAM15prev)  
     {
      trendM15=0;
     }    
     if(MAM30 > MAM30prev)  
     {
      trendM30=1;
     } 
     if(MAM30 < MAM30prev)  
     {
      trendM30=0;
     }   
     if(MAH1 > MAH1prev)  
     {
      trendH1=1;
     } 
     if(MAH1 < MAH1prev)  
     {
      trendH1=0;
     }  
     if(MAH4 > MAH4prev)  
     {
      trendH4=1;
     } 
     if(MAH4 < MAH4prev)  
     {
      trendH4=0;
     }   
     if(MAD1 > MAD1prev)  
     {
      trendD1=1;
     } 
     if(MAD1 < MAD1prev)  
     {
      trendD1=0;
     } 
   // Spread ---------------
   
   Spread=NormalizeDouble(((Ask-Bid)/Point)/10,1);
   
   // ParabolicSAR -------------------------------
   
   PSARCurrent= iSAR(NULL,0,PSAR_Step,PSAR_Max,0);
   PSARPrev= iSAR(NULL,0,PSAR_Step,PSAR_Max,1);
   
   if (PSARCurrent>PSARPrev)
      {
      PSAR=1;
      }
   if (PSARCurrent<PSARPrev)
      {
      PSAR=0;
      }
   // MACD ---------------------------------------
   
   MACDCurrent = iMACD(NULL,0,MACD_Period1,MACD_Period2,MACD_Period3,PRICE_CLOSE,MODE_MAIN,0);
   MACDPrev = iMACD(NULL,0,MACD_Period1,MACD_Period2,MACD_Period3,PRICE_CLOSE,MODE_MAIN,1);
   MACDSignal = iMACD(NULL,0,MACD_Period1,MACD_Period2,MACD_Period3,PRICE_CLOSE,MODE_SIGNAL,0);
   MACDSignalPrev = iMACD(NULL,0,MACD_Period1,MACD_Period2,MACD_Period3,PRICE_CLOSE,MODE_SIGNAL,1);
   
   if (MACDCurrent>MACDPrev && ((MACDCurrent && MACDPrev)>MACDSignal || (MACDCurrent && MACDPrev)<MACDSignal))
      {
      MACD=3;
      }
   if (MACDCurrent<MACDSignal && MACDPrev>MACDSignalPrev)
      {
      MACD=2;
      }      
   if (MACDCurrent<MACDPrev && ((MACDCurrent && MACDPrev)>MACDSignal || (MACDCurrent && MACDPrev)<MACDSignal))
      {
      MACD=1;
      }   
   if (MACDCurrent>MACDSignal && MACDPrev<MACDSignalPrev)
      {
      MACD=0;
      }   
   if (MACDCurrent>0 && MACDPrev<0)
      {
      MACD=4;
      }         
   if (MACDCurrent<0 && MACDPrev>0)
      {
      MACD=5;
      } 
  // MA XOVER  ---------------------------------------

      MAXover1=iMA(NULL,0,FastLWMA,0,MODE_LWMA,PRICE_CLOSE,0);
      MAXover2=iMA(NULL,0,SlowSMA,0,MODE_SMA,PRICE_CLOSE,0);

   if (MAXover1>MAXover2)
      {
      MAXoverSignal=1;
      }
   if (MAXover1<MAXover2)
      {
      MAXoverSignal=0;
      }
   // Williams%Range ---------------------------------
   
     WPR=iWPR(NULL,0,14,0);
      
   if (WPR<=0 && WPR>=-5)
   {
   WPRValueUp=1;
   }
   if (WPR>=-20 && WPR<-5)
   {
   WPRValueUp=2;
   }   
   if (WPR>=-30 && WPR<-20)
   {
   WPRValueUp=3;
   }   
   if (WPR>=-40 && WPR<-30)
   {
   WPRValueUp=4;
   }   
   if (WPR>-50 && WPR<-40)
   {
   WPRValueUp=5;
   }      
   if (WPR<-50 && WPR>=-60)
   {
   WPRValueDown=6;
   }   
   if (WPR<=-60 && WPR>=-70)
   {
   WPRValueDown=7;
   }
   if (WPR<=-70 && WPR>=-80)
   {
   WPRValueDown=8;
   }   
   if (WPR<=-80 && WPR>=-95)
   {
   WPRValueDown=9;
   }   
   if (WPR<=-95 && WPR>=-100)
   {
   WPRValueDown=10;
   }   
      
   // BarMeter ---------------------------------------------------------
   
   if (Close[0] > Close[1])
   {
   Bar1 = (Close[0] - Close[1])*100000;
   }
   if (Close[0] < Close[1])
   {
   Bar1 = (Close[1] - Close[0])*100000;
   }
  
   if (Close[1] > Close[2])
   {
   Bar2 = (Close[1] - Close[2])*100000;
   }
   if (Close[1] < Close[2])
   {
   Bar2 = (Close[2] - Close[1])*100000;
   }

   if (Close[2] > Close[3])
   {
   Bar3 = (Close[2] - Close[3])*100000;
   }
   if (Close[2] < Close[3])
   {
   Bar3 = (Close[3] - Close[2])*100000;
   }
   
   if (Close[3] > Close[4])
   {
   Bar4 = (Close[3] - Close[4])*100000;
   }
   if (Close[3] < Close[4])
   {
   Bar4 = (Close[4] - Close[3])*100000;
   }
   
   if (Close[4] > Close[5])
   {
   Bar5 = (Close[4] - Close[5])*100000;
   }
   if (Close[4] < Close[5])
   {
   Bar5 = (Close[5] - Close[4])*100000;
   }
       
   if (Close[5] > Close[6])
   {
   Bar6 = (Close[5] - Close[6])*100000;
   }
   if (Close[5] < Close[6])
   {
   Bar6 = (Close[6] - Close[5])*100000;
   }
   
   if (Close[6] > Close[7])
   {
   Bar7 = (Close[6] - Close[7])*100000;
   }
   if (Close[6] < Close[7])
   {
   Bar7 = (Close[7] - Close[6])*100000;
   }
   
   if (Close[7] > Close[8])
   {
   Bar8 = (Close[7] - Close[8])*100000;
   }
   if (Close[7] < Close[8])
   {
   Bar8 = (Close[8] - Close[7])*100000;
   }
   
   if (Close[8] > Close[9])
   {
   Bar9 = (Close[8] - Close[9])*100000;
   }
   if (Close[8] < Close[9])
   {
   Bar9 = (Close[9] - Close[8])*100000;
   }
   
   if (Close[9] > Close[10])
   {
   Bar10 = (Close[9] - Close[10])*100000;
   }
   if (Close[9] < Close[10])
   {
   Bar10 = (Close[10] - Close[9])*100000;
   }            
   //----------------------------------------    
   BarsAverage1 = (Bar2 + Bar3 + Bar4 + Bar5)/4;
   BarsAverage2 = (Bar3 + Bar4 + Bar5 + Bar6)/4;
   BarsAverage3 = (Bar4 + Bar5 + Bar6 + Bar7)/4;
   BarsAverage4 = (Bar5 + Bar6 + Bar7 + Bar8)/4;
   BarsAverage5 = (Bar6 + Bar7 + Bar8 + Bar9)/4;
   
   Bar1percent = NormalizeDouble((Bar1/BarsAverage1)*100,0);
   Bar2percent = NormalizeDouble((Bar2/BarsAverage2)*100,0);
   Bar3percent = NormalizeDouble((Bar3/BarsAverage3)*100,0);
   Bar4percent = NormalizeDouble((Bar4/BarsAverage4)*100,0);
   Bar5percent = NormalizeDouble((Bar5/BarsAverage5)*100,0);
   BarsAllpercent = NormalizeDouble(((Bar2 + Bar3 + Bar4 + Bar5)/4)*100,0);
   
   if (Bar1percent==0) //Stopped
   {
   BarReading = 1;
   }
   if (Bar1percent>Bar2percent && Bar1percent>100 && Bar1percent!=0) //Speeding Up
   {
   BarReading = 2;
   }
   if (Bar1percent<=100 && Bar1percent!=0) //Steady
   {
   BarReading = 3;
   }
   if (Bar1percent<Bar2percent && Bar2percent>100 && Bar1percent>100 && Bar1percent!=0) //Slowing Down
   {
   BarReading = 4;
   }
   //----------------------------------------  
   if (Bar1percent==0 || Close[0] == Close[1])
     {
     Bar1Col = 12;
     } 
   if (Bar1percent<25 && Bar1percent>0)
     {
     Bar1Col = 11;
     }   
   if (Bar1percent>=400)
     {
     if (Close[0] > Close[1])
       {
       Bar1Col = 1;
       }
       else if (Close[0] < Close[1]) Bar1Col = 10;
     }  
   if (Bar1percent>=200 && Bar1percent<400)
     {
     if (Close[0] > Close[1])
       {
       Bar1Col = 2;
       }
       else if (Close[0] < Close[1]) Bar1Col = 9;
     }  
   if (Bar1percent>=100 && Bar1percent<200)
     {
     if (Close[0] > Close[1])
       {
       Bar1Col = 3;
       }
       else if (Close[0] < Close[1]) Bar1Col = 8;
     }  
   if (Bar1percent>=50 && Bar1percent<100)
     {
     if (Close[0] > Close[1])
       {
       Bar1Col = 4;
       }
       else if (Close[0] < Close[1]) Bar1Col = 7;
     }    
   if (Bar1percent>=25 && Bar1percent<50)
     {
     if (Close[0] > Close[1])
       {
       Bar1Col = 5;
       }
       else if (Close[0] < Close[1]) Bar1Col = 6;
     }  
   //--------------------------------------
   if (Bar2percent==0 || Close[1] == Close[2])
     {
     Bar2Col = 12;
     } 
   if (Bar2percent<25 && Bar2percent>0)
     {
     Bar2Col = 11;
     }   
   if (Bar2percent>=400)
     {
     if (Close[1] > Close[2])
       {
       Bar2Col = 1;
       }
       else if (Close[1] < Close[2]) Bar2Col = 10;
     }  
   if (Bar2percent>=200 && Bar2percent<400)
     {
     if (Close[1] > Close[2])
       {
       Bar2Col = 2;
       }
       else if (Close[1] < Close[2]) Bar2Col = 9;
     }  
   if (Bar2percent>=100 && Bar2percent<200)
     {
     if (Close[1] > Close[2])
       {
       Bar2Col = 3;
       }
       else if (Close[1] < Close[2]) Bar2Col = 8;
     }  
   if (Bar2percent>=50 && Bar2percent<100)
     {
     if (Close[1] > Close[2])
       {
       Bar2Col = 4;
       }
       else if (Close[1] < Close[2]) Bar2Col = 7;
     }      
   if (Bar2percent>=25 && Bar2percent<50)
     {
     if (Close[1] > Close[2])
       {
       Bar2Col = 5;
       }
       else if (Close[1] < Close[2]) Bar2Col = 6;
     }    
   //--------------------------------------
   if (Bar3percent==0 || Close[2] == Close[3])
     {
     Bar3Col = 12;
     } 
   if (Bar3percent<25 && Bar3percent>0)
     {
     Bar3Col = 11;
     }   
   if (Bar3percent>=400)
     {
     if (Close[2] > Close[3])
       {
       Bar3Col = 1;
       }
       else if (Close[2] < Close[3]) Bar3Col = 10;
     }  
   if (Bar3percent>=200 && Bar3percent<400)
     {
     if (Close[2] > Close[3])
       {
       Bar3Col = 2;
       }
       else if (Close[2] < Close[3]) Bar3Col = 9;
     }  
   if (Bar3percent>=100 && Bar3percent<200)
     {
     if (Close[2] > Close[3])
       {
       Bar3Col = 3;
       }
       else if (Close[2] < Close[3]) Bar3Col = 8;
     }   
   if (Bar3percent>=50 && Bar3percent<100)
     {
     if (Close[2] > Close[3])
       {
       Bar3Col = 4;
       }
       else if (Close[2] < Close[3]) Bar3Col = 7;
     }        
   if (Bar3percent>=25 && Bar3percent<50)
     {
     if (Close[2] > Close[3])
       {
       Bar3Col = 5;
       }
       else if (Close[2] < Close[3]) Bar3Col = 6;
     }   
   //--------------------------------------
   if (Bar4percent==0 || Close[3] == Close[4])
     {
     Bar4Col = 12;
     } 
   if (Bar4percent<25 && Bar4percent>0)
     {
     Bar4Col = 11;
     }   
   if (Bar4percent>=400)
     {
     if (Close[3] > Close[4])
       {
       Bar4Col = 1;
       }
       else if (Close[3] < Close[4]) Bar4Col = 10;
     }   
   if (Bar4percent>=200 && Bar4percent<400)
     {
     if (Close[3] > Close[4])
       {
       Bar4Col = 2;
       }
       else if (Close[3] < Close[4]) Bar4Col = 9;
     }   
   if (Bar4percent>=100 && Bar4percent<200)
     {
     if (Close[3] > Close[4])
       {
       Bar4Col = 3;
       }
       else if (Close[3] < Close[4]) Bar4Col = 8;
     }    
   if (Bar4percent>=50 && Bar4percent<100)
      {
     if (Close[3] > Close[4])
       {
       Bar4Col = 4;
       }
       else if (Close[3] < Close[4]) Bar4Col = 7;
     }        
   if (Bar4percent>=25 && Bar4percent<50)
     {
     if (Close[3] > Close[4])
       {
       Bar4Col = 5;
       }
       else if (Close[3] < Close[4]) Bar4Col = 6;
     }   
   //--------------------------------------
   if (Bar5percent==0 || Close[4] == Close[5])
     {
     Bar5Col = 12;
     } 
   if (Bar5percent<25 && Bar5percent>0)
     {
     Bar5Col = 11;
     }   
   if (Bar5percent>=400)
     {
     if (Close[4] > Close[5])
       {
       Bar5Col = 1;
       }
       else if (Close[4] < Close[5]) Bar5Col = 10;
     }   
   if (Bar5percent>=200 && Bar5percent<400)
     {
     if (Close[4] > Close[5])
       {
       Bar5Col = 2;
       }
       else if (Close[4] < Close[5]) Bar5Col = 9;
     }    
   if (Bar5percent>=100 && Bar5percent<200)
     {
     if (Close[4] > Close[5])
       {
       Bar5Col = 3;
       }
       else if (Close[4] < Close[5]) Bar5Col = 8;
     }     
   if (Bar5percent>=50 && Bar5percent<100)
     {
     if (Close[4] > Close[5])
       {
       Bar5Col = 4;
       }
       else if (Close[4] < Close[5]) Bar5Col = 7;
     }         
   if (Bar5percent>=25 && Bar5percent<50)
     {
     if (Close[4] > Close[5])
       {
       Bar5Col = 5;
       }
       else if (Close[4] < Close[5]) Bar5Col = 6;
     }    
    
    //Signal Down  ------------------------ 
    if ((MACD==1 || MACD==2) && MAXoverSignal==0 && WPR<-50 && MACurrent<MAPrevious && StochK<StochKprev && Close[0]<Close[1])
     {
     Signal = 1;
     }    
    
    //Signal Up  ------------------------  
    if ((MACD==3 || MACD==0) && MAXoverSignal==1 && WPR>-50 && MACurrent>MAPrevious && StochK>StochKprev && Close[0]>Close[1])
     {
     Signal = 2;
     }    
      
   //--------------------------------------       
   objectBlank(); 
   paintM1(M1stochK);
   paintM5(M5stochK);
   paintM15(M15stochK);
   paintM30(M30stochK);
   paintH1(H1stochK);
   paintH4(H4stochK);
   paintD1(D1stochK);
   paintLine();
   paintMA_M1(trendM1);
   paintMA_M5(trendM5);
   paintMA_M15(trendM15);
   paintMA_M30(trendM30);
   paintMA_H1(trendH1);
   paintMA_H4(trendH4);
   paintMA_D1(trendD1);
   paint2Line();
   paintWPRUp(WPRValueUp);
   paintWPRDown(WPRValueDown);
   paintWPRValue(WPR); 
   paintSpread(Spread);
   paintSpreadLines();
   paintPSAR(PSAR);
   paintMACD(MACD);
   paintMAXover(MAXoverSignal);
   paintBars();
   paintBarValue1(Bar1percent);
   paintBarValue2(Bar2percent);
   paintBarValue3(Bar3percent);
   paintBarValue4(Bar4percent);
   paintBarValue5(Bar5percent);
   paintBar1(Bar1Col);
   paintBar2(Bar2Col);
   paintBar3(Bar3Col);
   paintBar4(Bar4Col);
   paintBar5(Bar5Col);
   paintBarReading(BarReading);
   paintSignal(Signal);
                                                                        
  }
//----------------------------------------   
void initGraph() 
  {
   ObjectsDeleteAll(0,OBJ_LABEL);

// Stochastic Graphs -------------------
   objectCreate("M_1_90",130,91);
   objectCreate("M_1_80",130,83);
   objectCreate("M_1_70",130,75);
   objectCreate("M_1_60",130,67);
   objectCreate("M_1_50",130,59);  
   objectCreate("M_1_40",130,51);
   objectCreate("M_1_30",130,43);
   objectCreate("M_1_20",130,35);
   objectCreate("M_1_10",130,27);
   objectCreate("M_1_0",130,19);
   objectCreate("M_1",135,20,"M1",7,"Arial Narrow",SkyBlue);
   objectCreate("M_1p",134,29,DoubleToStr(9,1),8,"Arial Narrow",Silver);
   
   objectCreate("M_5_90",110,91);
   objectCreate("M_5_80",110,83);
   objectCreate("M_5_70",110,75);
   objectCreate("M_5_60",110,67);
   objectCreate("M_5_50",110,59);  
   objectCreate("M_5_40",110,51);
   objectCreate("M_5_30",110,43);
   objectCreate("M_5_20",110,35);
   objectCreate("M_5_10",110,27);
   objectCreate("M_5_0",110,19);
   objectCreate("M_5",115,20,"M5",7,"Arial Narrow",SkyBlue);
   objectCreate("M_5p",114,29,DoubleToStr(9,1),8,"Arial Narrow",Silver);
   
   objectCreate("M_15_90",90,91);
   objectCreate("M_15_80",90,83);
   objectCreate("M_15_70",90,75);
   objectCreate("M_15_60",90,67);
   objectCreate("M_15_50",90,59);  
   objectCreate("M_15_40",90,51);
   objectCreate("M_15_30",90,43);
   objectCreate("M_15_20",90,35);
   objectCreate("M_15_10",90,27);
   objectCreate("M_15_0",90,19);
   objectCreate("M_15",93,20,"M15",7,"Arial Narrow",SkyBlue);
   objectCreate("M_15p",94,29,DoubleToStr(9,1),8,"Arial Narrow",Silver);
   
   objectCreate("M_30_90",70,91);
   objectCreate("M_30_80",70,83);
   objectCreate("M_30_70",70,75);
   objectCreate("M_30_60",70,67);
   objectCreate("M_30_50",70,59);  
   objectCreate("M_30_40",70,51);
   objectCreate("M_30_30",70,43);
   objectCreate("M_30_20",70,35);
   objectCreate("M_30_10",70,27);
   objectCreate("M_30_0",70,19);
   objectCreate("M_30",73,20,"M30",7,"Arial Narrow",SkyBlue);
   objectCreate("M_30p",74,29,DoubleToStr(9,1),8,"Arial Narrow",Silver);

   objectCreate("H_1_90",50,91);
   objectCreate("H_1_80",50,83);
   objectCreate("H_1_70",50,75);
   objectCreate("H_1_60",50,67);
   objectCreate("H_1_50",50,59);  
   objectCreate("H_1_40",50,51);
   objectCreate("H_1_30",50,43);
   objectCreate("H_1_20",50,35);
   objectCreate("H_1_10",50,27);
   objectCreate("H_1_0",50,19);
   objectCreate("H_1",54,20,"H1",7,"Arial Narrow",SkyBlue);
   objectCreate("H_1p",54,29,DoubleToStr(9,1),8,"Arial Narrow",Silver);
   
   objectCreate("H_4_90",30,91);
   objectCreate("H_4_80",30,83);
   objectCreate("H_4_70",30,75);
   objectCreate("H_4_60",30,67);
   objectCreate("H_4_50",30,59);  
   objectCreate("H_4_40",30,51);
   objectCreate("H_4_30",30,43);
   objectCreate("H_4_20",30,35);
   objectCreate("H_4_10",30,27);
   objectCreate("H_4_0",30,19);
   objectCreate("H_4",34,20,"H4",7,"Arial Narrow",SkyBlue);
   objectCreate("H_4p",34,29,DoubleToStr(9,1),8,"Arial Narrow",Silver);

   objectCreate("D_1_90",10,91);
   objectCreate("D_1_80",10,83);
   objectCreate("D_1_70",10,75);
   objectCreate("D_1_60",10,67);
   objectCreate("D_1_50",10,59);  
   objectCreate("D_1_40",10,51);
   objectCreate("D_1_30",10,43);
   objectCreate("D_1_20",10,35);
   objectCreate("D_1_10",10,27);
   objectCreate("D_1_0",10,19);
   objectCreate("D_1",15,20,"D1",7,"Arial Narrow",SkyBlue);
   objectCreate("D_1p",14,29,DoubleToStr(9,1),8,"Arial Narrow",Silver);
   
   objectCreate("line",10,14,"-----------------------------------",10,"Arial",DimGray);  
   objectCreate("line1",10,35,"-----------------------------------",10,"Arial",DimGray);  
   objectCreate("line2",10,118,"-----------------------------------",10,"Arial",DimGray);
   objectCreate("sign",11,6,"STOCHASTIC OSCILLATORS",9,"Arial Narrow",DimGray);
   
   // MA Graphs -------------------------------------------------------------------------------
   objectCreate("2M_1_MA",130,137);
   objectCreate("2M_5_MA",110,137);
   objectCreate("2M_15_MA",90,137);
   objectCreate("2M_30_MA",70,137);
   objectCreate("2H_1_MA",50,137);
   objectCreate("2H_4_MA",30,137);
   objectCreate("2D_1_MA",10,137);   
   
   objectCreate("2M_1",135,147,"M1",7,"Arial Narrow",SkyBlue);
   objectCreate("2M_5",115,147,"M5",7,"Arial Narrow",SkyBlue);
   objectCreate("2M_15",93,147,"M15",7,"Arial Narrow",SkyBlue);
   objectCreate("2M_30",73,147,"M30",7,"Arial Narrow",SkyBlue);
   objectCreate("2H_1",54,147,"H1",7,"Arial Narrow",SkyBlue);
   objectCreate("2H_4",34,147,"H4",7,"Arial Narrow",SkyBlue);
   objectCreate("2D_1",15,147,"D1",7,"Arial Narrow",SkyBlue);
   
   objectCreate("2line",10,141,"-----------------------------------",10,"Arial",DimGray);  
   objectCreate("2line1",10,152,"-----------------------------------",10,"Arial",DimGray);  
   objectCreate("2line2",10,164,"-----------------------------------",10,"Arial",DimGray);
   objectCreate("2sign",12,132,"MOVING AVERAGE TREND",9,"Arial Narrow",DimGray);
   
   // MACD Graphs ----------------------------------------------------------------------------- 
   objectCreate("MACD_Value1",118,271,"p",20,"Wingdings 3",Lime);
   objectCreate("MACD_Value2",122,271,"X",20,"Arial",Red);
   objectCreate("MACD_Value3",118,271,"q",20,"Wingdings 3",Red);
   objectCreate("MACD_Value4",122,271,"X",20,"Arial",Lime);  
   objectCreate("MACD_Value5",122,271,"0",20,"Arial",Lime);  
   objectCreate("MACD_Value6",122,271,"0",20,"Arial",Red);  
   objectCreate("MACD_Chart",112,259,"CURRENT",7,"Arial Narrow",SkyBlue);   
   objectCreate("MACD_Line1",113,252,"---------",10,"Arial",DimGray);  
   objectCreate("MACD_Line2",113,265,"---------",10,"Arial",DimGray);  
   objectCreate("MACD_Title",115,243,"MACD",9,"Arial Narrow",DimGray);
   
   // PSAR Graph ----------------------------------------------------------------------------- 
   objectCreate("PSAR_Value1",118,206,"p",20,"Wingdings 3",Lime);
   objectCreate("PSAR_Value2",118,206,"q",20,"Wingdings 3",Red);
   objectCreate("PSAR_Chart",112,194,"CURRENT",7,"Arial Narrow",SkyBlue);  
   objectCreate("PSAR_Line1",113,187,"---------",10,"Arial",DimGray);  
   objectCreate("PSAR_Line2",113,200,"---------",10,"Arial",DimGray);  
   objectCreate("PSAR_Line3",113,229,"---------",10,"Arial",DimGray);
   objectCreate("PSAR_Title",115,178,"P-SAR",9,"Arial Narrow",DimGray);
   
   // WPR Graph -----------------------------------------------------------------------------  
   objectCreate("WPRpercent",12,300,"%",8,"Arial",Silver);
   objectCreate("WPRValue",22,300,DoubleToStr(9,1),9,"Arial",Silver);
  
   object2Create("V+5",12,288); 
   object2Create("V+4",12,280); 
   object2Create("V+3",12,272); 
   object2Create("V+2",12,264); 
   object2Create("V+1",12,256);   
   object2Create("V=0",12,248); 
   object2Create("V-1",12,240); 
   object2Create("V-2",12,232); 
   object2Create("V-3",12,224); 
   object2Create("V-4",12,216); 
   object2Create("V-5",12,208); 
   
   objectCreate("VolumeChart",10,194,"CURRENT",7,"Arial Narrow",SkyBlue);
   objectCreate("WPRLine1",10,187,"---------",10,"Arial",DimGray);  
   objectCreate("WPRLine2",10,200,"---------",10,"Arial",DimGray);  
   objectCreate("WPRLine3",10,292,"---------",10,"Arial",DimGray);
   objectCreate("WPRTitle",10,178,"WPR%",9,"Arial Narrow",DimGray);
   
   // Spread Graph ----------------------------------------------------------------------------- 
   objectCreate("SpreadLine3",60,229,"-----------",10,"Arial",DimGray);
   objectCreate("SpreadLine2",60,200,"-----------",10,"Arial",DimGray);
   objectCreate("SpreadLine1",60,187,"-----------",10,"Arial",DimGray); 
   objectCreate("SpreadPips",72,194,"PIPS",7,"Arial Narrow",SkyBlue); 
   objectCreate("SpreadTitle",61,178,"SPREAD",9,"Arial Narrow",DimGray);
   objectCreate("SpreadValue",68,206,DoubleToStr(9,1),18,"Arial",White);
   
   // MAXover Graph ------------------------------------------------------------------------ 
   objectCreate("MAXoverValue1",69,271,"p",20,"Wingdings 3",Lime);
   objectCreate("MAXoverValue2",69,271,"q",20,"Wingdings 3",Red);  
   objectCreate("MAXoverChart",64,259,"CURRENT",7,"Arial Narrow",SkyBlue);
   objectCreate("MAXoverLine1",60,252,"-----------",10,"Arial",DimGray);  
   objectCreate("MAXoverLine2",60,265,"-----------",10,"Arial",DimGray);  
   objectCreate("MAXoverTitle",70,243,"MA-X",9,"Arial Narrow",DimGray);
   
   // BarMeter Graph ------------------------------------------------------------------------
   objectCreate("BarsLine1",60,314,"----------------------",10,"Arial",DimGray);  
   objectCreate("BarsLine2",60,336,"----------------------",10,"Arial",DimGray);  
   objectCreate("BarsLine3",60,377,"----------------------",10,"Arial",DimGray);
   objectCreate("BarsTitle",67,306,"BAR % METER",9,"Arial Narrow",DimGray);
  
   object3Create("Bar_5",132,335);
   object3Create("Bar_4",114,335);
   object3Create("Bar_3",96,335);
   object3Create("Bar_2",78,335);
   object3Create("Bar_1",60,335);   
   
   objectCreate("B_5",134,320,"B5",7,"Arial Narrow",SkyBlue);
   objectCreate("B_4",116,320,"B4",7,"Arial Narrow",SkyBlue);
   objectCreate("B_3",98,320,"B3",7,"Arial Narrow",SkyBlue);
   objectCreate("B_2",80,320,"B2",7,"Arial Narrow",SkyBlue);
   objectCreate("B_1",62,320,"B1",7,"Arial Narrow",SkyBlue);
   objectCreate("BarsPercent",52,330,"%",7,"Arial Narrow",Silver);
   objectCreate("Bar_Value1",62,330,DoubleToStr(9,1),8,"Arial",White);
   objectCreate("Bar_Value2",80,330,DoubleToStr(9,1),8,"Arial",White);
   objectCreate("Bar_Value3",98,330,DoubleToStr(9,1),8,"Arial",White);
   objectCreate("Bar_Value4",116,330,DoubleToStr(9,1),8,"Arial",White);
   objectCreate("Bar_Value5",134,330,DoubleToStr(9,1),8,"Arial",White);
   objectCreate("BarsSlowing",70,385,"Slowing Down",8,"Arial",Silver);
   objectCreate("BarsSpeeding",70,385,"Speeding Up",8,"Arial",Silver);
   objectCreate("BarsStopped",83,385,"Stopped",8,"Arial",Silver);
   objectCreate("BarsSteady",85,385,"Steady",8,"Arial",Silver);
   
   // Signal Graph ------------------------------------------------------------------------
   objectCreate("SignalLine1",10,336,"---------",10,"Arial",DimGray);   
   objectCreate("SignalLine2",10,377,"---------",10,"Arial",DimGray);
   objectCreate("SignalTitle",9,327,"SIGNAL",9,"Arial Narrow",DimGray);
   objectCreate("SignalUp",10,342,"p",28,"Wingdings 3",Lime);
   objectCreate("SignalDown",10,342,"q",28,"Wingdings 3",Red);
   objectCreate("SignalWait",10,342,"6",28,"Wingdings",Silver);
   //objectCreate("SignalLine3",10,392,"----------------------------------",10,"Arial",DimGray);

   WindowRedraw();
  }
  
//+------------------------------------------------------------------+
void objectCreate(string name,int x,int y,string text="-",int size=42,
                  string font="Arial",color colour=CLR_NONE)
  {
   ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_CORNER,3);
   ObjectSet(name,OBJPROP_COLOR,colour);
   ObjectSet(name,OBJPROP_XDISTANCE,x);
   ObjectSet(name,OBJPROP_YDISTANCE,y);
   ObjectSetText(name,text,size,font,colour);
  }

void object2Create(string name,int x,int y,string text="_",int size=42,
                  string font="Arial",color colour=CLR_NONE)
  {
   ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_CORNER,3);
   ObjectSet(name,OBJPROP_COLOR,colour);
   ObjectSet(name,OBJPROP_XDISTANCE,x);
   ObjectSet(name,OBJPROP_YDISTANCE,y);
   ObjectSetText(name,text,size,font,colour);
  }
  
void object3Create(string name,int x,int y,string text="I",int size=36,
                  string font="Arial Bold",color colour=CLR_NONE)
  {
   ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_CORNER,3);
   ObjectSet(name,OBJPROP_COLOR,colour);
   ObjectSet(name,OBJPROP_XDISTANCE,x);
   ObjectSet(name,OBJPROP_YDISTANCE,y);
   ObjectSetText(name,text,size,font,colour);
  }
  
void objectBlank()
  {
// Stochastic Graphs -------------------
   ObjectSet("M_1_90",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_1_80",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_1_70",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_1_60",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_1_50",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_1_40",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_1_30",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_1_20",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_1_10",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_1_0",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_1p",OBJPROP_COLOR,CLR_NONE);

   ObjectSet("M_5_90",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_5_80",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_5_70",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_5_60",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_5_50",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_5_40",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_5_30",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_5_20",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_5_10",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_5_0",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_5p",OBJPROP_COLOR,CLR_NONE);

   ObjectSet("M_15_90",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_15_80",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_15_70",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_15_60",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_15_50",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_15_40",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_15_30",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_15_20",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_15_10",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_15_0",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_15",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_15p",OBJPROP_COLOR,CLR_NONE);

   ObjectSet("M_30_90",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_30_80",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_30_70",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_30_60",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_30_50",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_30_40",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_30_30",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_30_20",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_30_10",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_30_0",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_30",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("M_30p",OBJPROP_COLOR,CLR_NONE);

   ObjectSet("H_1_90",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_1_80",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_1_70",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_1_60",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_1_50",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_1_40",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_1_30",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_1_20",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_1_10",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_1_0",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_1p",OBJPROP_COLOR,CLR_NONE);

   ObjectSet("H_4_90",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_4_80",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_4_70",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_4_60",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_4_50",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_4_40",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_4_30",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_4_20",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_4_10",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_4_0",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("H_4p",OBJPROP_COLOR,CLR_NONE);

   ObjectSet("D_1_90",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("D_1_80",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("D_1_70",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("D_1_60",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("D_1_50",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("D_1_40",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("D_1_30",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("D_1_20",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("D_1_10",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("D_1_0",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("D_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("D_1p",OBJPROP_COLOR,CLR_NONE);
   
   ObjectSet("line",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("line1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("line2",OBJPROP_COLOR,CLR_NONE); 
   ObjectSet("sign",OBJPROP_COLOR,CLR_NONE);
   
   // MA Graphs -------------------
   
   ObjectSet("2M_1_MA",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("2M_5_MA",OBJPROP_COLOR,CLR_NONE); 
   ObjectSet("2M_15_MA",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("2M_30_MA",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("2H_1_MA",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("2H_4_MA",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("2D_1_MA",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("2D_1_MA",OBJPROP_COLOR,CLR_NONE);   
   
   ObjectSet("2M_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("2M_5",OBJPROP_COLOR,CLR_NONE); 
   ObjectSet("2M_15",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("2M_30",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("2H_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("2H_4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("2D_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("2D_1",OBJPROP_COLOR,CLR_NONE);
   
   ObjectSet("2line1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("2line2",OBJPROP_COLOR,CLR_NONE); 
   ObjectSet("2line",OBJPROP_COLOR,CLR_NONE); 
   ObjectSet("2sign",OBJPROP_COLOR,CLR_NONE); 
   
   // WPR Graph -------------------
   
   ObjectSet("V+5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("V+4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("V+3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("V+2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("V+1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("V=0",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("V-1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("V-2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("V-3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("V-4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("V-5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("VolumeChart",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("WPRTitle",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("WPRpercent",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("WPRValue",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("WPRLine1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("WPRLine2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("WPRLine3",OBJPROP_COLOR,CLR_NONE);
   
   // Spread Graph -------------------
   
   ObjectSet("SpreadValue",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("SpreadTitle",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("SpreadPips",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("SpreadLine1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("SpreadLine2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("SpreadLine3",OBJPROP_COLOR,CLR_NONE);
   
   // PSAR Graph -------------------
   
   ObjectSet("PSAR_Value1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("PSAR_Value2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("PSAR_Chart",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("PSAR_Line1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("PSAR_Line2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("PSAR_Line3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("PSAR_Title",OBJPROP_COLOR,CLR_NONE);
   
   // MACD Graph -------------------
   
   ObjectSet("MACD_Value1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("MACD_Value2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("MACD_Value3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("MACD_Value4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("MACD_Value5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("MACD_Value6",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("MACD_Chart",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("MACD_Line1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("MACD_Line2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("MACD_Title",OBJPROP_COLOR,CLR_NONE);
   
   // MA Xover Graph -------------------
   
   ObjectSet("MAXoverValue1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("MAXoverValue2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("MAXoverChart",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("MAXoverLine1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("MAXoverLine2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("MAXoverTitle",OBJPROP_COLOR,CLR_NONE);  
   
   // BarMeter Graph -------------------
   
   ObjectSet("BarsLine1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("BarsLine2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("BarsLine3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("BarsTitle",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("BarsDescription",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("Bar_Value1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("Bar_Value2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("Bar_Value3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("Bar_Value4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("Bar_Value5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("Bar_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("Bar_2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("Bar_3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("Bar_4",OBJPROP_COLOR,CLR_NONE); 
   ObjectSet("Bar_5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("B_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("B_2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("B_3",OBJPROP_COLOR,CLR_NONE); 
   ObjectSet("B_4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("B_5",OBJPROP_COLOR,CLR_NONE); 
   ObjectSet("BarsSpeeding",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("BarsSlowing",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("BarsSteady",OBJPROP_COLOR,CLR_NONE); 
   ObjectSet("BarsStopped",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("BarsPercent",OBJPROP_COLOR,CLR_NONE);
   
   // Signal Graph -------------------
   ObjectSet("SignalLine1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("SignalLine2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("SignalTitle",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("SignalUp",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("SignalDown",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("SignalWait",OBJPROP_COLOR,CLR_NONE); 
  }

   
void paintM1(double value)
  {
   if (value >= 90) ObjectSet("M_1_90",OBJPROP_COLOR,Lime);
   if (value >= 80) ObjectSet("M_1_80",OBJPROP_COLOR,Lime);
   if (value >= 70) ObjectSet("M_1_70",OBJPROP_COLOR,LawnGreen);   
   if (value >= 60) ObjectSet("M_1_60",OBJPROP_COLOR,GreenYellow);
   if (value >= 50) ObjectSet("M_1_50",OBJPROP_COLOR,Yellow);
   if (value >= 40) ObjectSet("M_1_40",OBJPROP_COLOR,Gold);
   if (value >= 30) ObjectSet("M_1_30",OBJPROP_COLOR,Orange);
   if (value >= 20) ObjectSet("M_1_20",OBJPROP_COLOR,DarkOrange);   
   if (value >= 10) ObjectSet("M_1_10",OBJPROP_COLOR,OrangeRed);
   if (value >= 0) ObjectSet("M_1_0",OBJPROP_COLOR,Red);
   ObjectSet("M_1",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("M_1p",DoubleToStr(value,0),8,"Arial Narrow",Silver);
  }

void paintM5(double value)
  {
   if (value > 90) ObjectSet("M_5_90",OBJPROP_COLOR,Lime);
   if (value > 80) ObjectSet("M_5_80",OBJPROP_COLOR,Lime);
   if (value > 70) ObjectSet("M_5_70",OBJPROP_COLOR,LawnGreen);   
   if (value > 60) ObjectSet("M_5_60",OBJPROP_COLOR,GreenYellow);
   if (value > 50) ObjectSet("M_5_50",OBJPROP_COLOR,Yellow);
   if (value > 40) ObjectSet("M_5_40",OBJPROP_COLOR,Gold);
   if (value > 30) ObjectSet("M_5_30",OBJPROP_COLOR,Orange);
   if (value > 20) ObjectSet("M_5_20",OBJPROP_COLOR,DarkOrange);   
   if (value > 10) ObjectSet("M_5_10",OBJPROP_COLOR,OrangeRed);
   if (value > 0) ObjectSet("M_5_0",OBJPROP_COLOR,Red);
   ObjectSet("M_5",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("M_5p",DoubleToStr(value,0),8,"Arial Narrow",Silver);
  }

void paintM15(double value)
  {
   if (value > 90) ObjectSet("M_15_90",OBJPROP_COLOR,Lime);
   if (value > 80) ObjectSet("M_15_80",OBJPROP_COLOR,Lime);
   if (value > 70) ObjectSet("M_15_70",OBJPROP_COLOR,LawnGreen);   
   if (value > 60) ObjectSet("M_15_60",OBJPROP_COLOR,GreenYellow);
   if (value > 50) ObjectSet("M_15_50",OBJPROP_COLOR,Yellow);
   if (value > 40) ObjectSet("M_15_40",OBJPROP_COLOR,Gold);
   if (value > 30) ObjectSet("M_15_30",OBJPROP_COLOR,Orange);
   if (value > 20) ObjectSet("M_15_20",OBJPROP_COLOR,DarkOrange);   
   if (value > 10) ObjectSet("M_15_10",OBJPROP_COLOR,OrangeRed);
   if (value > 0) ObjectSet("M_15_0",OBJPROP_COLOR,Red);
   ObjectSet("M_15",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("M_15p",DoubleToStr(value,0),8,"Arial Narrow",Silver);
  }

void paintM30(double value)
  {
   if (value > 90) ObjectSet("M_30_90",OBJPROP_COLOR,Lime);
   if (value > 80) ObjectSet("M_30_80",OBJPROP_COLOR,Lime);
   if (value > 70) ObjectSet("M_30_70",OBJPROP_COLOR,LawnGreen);   
   if (value > 60) ObjectSet("M_30_60",OBJPROP_COLOR,GreenYellow);
   if (value > 50) ObjectSet("M_30_50",OBJPROP_COLOR,Yellow);
   if (value > 40) ObjectSet("M_30_40",OBJPROP_COLOR,Gold);
   if (value > 30) ObjectSet("M_30_30",OBJPROP_COLOR,Orange);
   if (value > 20) ObjectSet("M_30_20",OBJPROP_COLOR,DarkOrange);   
   if (value > 10) ObjectSet("M_30_10",OBJPROP_COLOR,OrangeRed);
   if (value > 0) ObjectSet("M_30_0",OBJPROP_COLOR,Red);
   ObjectSet("M_30",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("M_30p",DoubleToStr(value,0),8,"Arial Narrow",Silver);
  }

void paintH1(double value)
  {
   if (value > 90) ObjectSet("H_1_90",OBJPROP_COLOR,Lime);
   if (value > 80) ObjectSet("H_1_80",OBJPROP_COLOR,Lime);
   if (value > 70) ObjectSet("H_1_70",OBJPROP_COLOR,LawnGreen);   
   if (value > 60) ObjectSet("H_1_60",OBJPROP_COLOR,GreenYellow);
   if (value > 50) ObjectSet("H_1_50",OBJPROP_COLOR,Yellow);
   if (value > 40) ObjectSet("H_1_40",OBJPROP_COLOR,Gold);
   if (value > 30) ObjectSet("H_1_30",OBJPROP_COLOR,Orange);
   if (value > 20) ObjectSet("H_1_20",OBJPROP_COLOR,DarkOrange);   
   if (value > 10) ObjectSet("H_1_10",OBJPROP_COLOR,OrangeRed);
   if (value > 0) ObjectSet("H_1_0",OBJPROP_COLOR,Red);
   ObjectSet("H_1",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("H_1p",DoubleToStr(value,0),8,"Arial Narrow",Silver);
  }

void paintH4(double value)
  {
   if (value > 90) ObjectSet("H_4_90",OBJPROP_COLOR,Lime);
   if (value > 80) ObjectSet("H_4_80",OBJPROP_COLOR,Lime);
   if (value > 70) ObjectSet("H_4_70",OBJPROP_COLOR,LawnGreen);   
   if (value > 60) ObjectSet("H_4_60",OBJPROP_COLOR,GreenYellow);
   if (value > 50) ObjectSet("H_4_50",OBJPROP_COLOR,Yellow);
   if (value > 40) ObjectSet("H_4_40",OBJPROP_COLOR,Gold);
   if (value > 30) ObjectSet("H_4_30",OBJPROP_COLOR,Orange);
   if (value > 20) ObjectSet("H_4_20",OBJPROP_COLOR,DarkOrange);   
   if (value > 10) ObjectSet("H_4_10",OBJPROP_COLOR,OrangeRed);
   if (value > 0) ObjectSet("H_4_0",OBJPROP_COLOR,Red);
   ObjectSet("H_4",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("H_4p",DoubleToStr(value,0),8,"Arial Narrow",Silver);
  }

void paintD1(double value)
  {
   if (value > 90) ObjectSet("D_1_90",OBJPROP_COLOR,Lime);
   if (value > 80) ObjectSet("D_1_80",OBJPROP_COLOR,Lime);
   if (value > 70) ObjectSet("D_1_70",OBJPROP_COLOR,LawnGreen);   
   if (value > 60) ObjectSet("D_1_60",OBJPROP_COLOR,GreenYellow);
   if (value > 50) ObjectSet("D_1_50",OBJPROP_COLOR,Yellow);
   if (value > 40) ObjectSet("D_1_40",OBJPROP_COLOR,Gold);
   if (value > 30) ObjectSet("D_1_30",OBJPROP_COLOR,Orange);
   if (value > 20) ObjectSet("D_1_20",OBJPROP_COLOR,DarkOrange);   
   if (value > 10) ObjectSet("D_1_10",OBJPROP_COLOR,OrangeRed);
   if (value > 0) ObjectSet("D_1_0",OBJPROP_COLOR,Red);
   ObjectSet("D_1",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("D_1p",DoubleToStr(value,0),8,"Arial Narrow",Silver);
  }
  
void paintLine()
  {
   ObjectSet("line",OBJPROP_COLOR,DimGray);
   ObjectSet("line1",OBJPROP_COLOR,DimGray);
   ObjectSet("line2",OBJPROP_COLOR,DimGray);
   ObjectSet("sign",OBJPROP_COLOR,DimGray);
  }
  
  // MA Graphs -------------------
  
  void paintMA_M1(int value)
  {
   if (value==1) ObjectSet("2M_1_MA",OBJPROP_COLOR,Lime);
   if (value==0) ObjectSet("2M_1_MA",OBJPROP_COLOR,Red);
   ObjectSet("2M_1",OBJPROP_COLOR,SkyBlue);
  }
  
    void paintMA_M5(int value)
  {
   if (value==1) ObjectSet("2M_5_MA",OBJPROP_COLOR,Lime);
   if (value==0) ObjectSet("2M_5_MA",OBJPROP_COLOR,Red);
   ObjectSet("2M_5",OBJPROP_COLOR,SkyBlue);
  }
  
    void paintMA_M15(int value)
  {
   if (value==1) ObjectSet("2M_15_MA",OBJPROP_COLOR,Lime);
   if (value==0) ObjectSet("2M_15_MA",OBJPROP_COLOR,Red);
   ObjectSet("2M_15",OBJPROP_COLOR,SkyBlue);
  }
  
    void paintMA_M30(int value)
  {
   if (value==1) ObjectSet("2M_30_MA",OBJPROP_COLOR,Lime);
   if (value==0) ObjectSet("2M_30_MA",OBJPROP_COLOR,Red);
   ObjectSet("2M_30",OBJPROP_COLOR,SkyBlue);
  }
  
    void paintMA_H1(int value)
  {
   if (value==1) ObjectSet("2H_1_MA",OBJPROP_COLOR,Lime);
   if (value==0) ObjectSet("2H_1_MA",OBJPROP_COLOR,Red);
   ObjectSet("2H_1",OBJPROP_COLOR,SkyBlue);
  }
  
    void paintMA_H4(int value)
  {
   if (value==1) ObjectSet("2H_4_MA",OBJPROP_COLOR,Lime);
   if (value==0) ObjectSet("2H_4_MA",OBJPROP_COLOR,Red);
   ObjectSet("2H_4",OBJPROP_COLOR,SkyBlue);
  }
  
    void paintMA_D1(int value)
  {
   if (value==1) ObjectSet("2D_1_MA",OBJPROP_COLOR,Lime);
   if (value==0) ObjectSet("2D_1_MA",OBJPROP_COLOR,Red);
   ObjectSet("2D_1",OBJPROP_COLOR,SkyBlue);
  }
  
  void paint2Line()
  {
   ObjectSet("2line",OBJPROP_COLOR,DimGray);
   ObjectSet("2line1",OBJPROP_COLOR,DimGray);
   ObjectSet("2line2",OBJPROP_COLOR,DimGray);
   ObjectSet("2sign",OBJPROP_COLOR,DimGray);
  }
  
  // WPR% Graphs -------------------
  
   void paintWPRUp(int value)
  {
   if (value==1 && value>0) ObjectSet("V+5",OBJPROP_COLOR,Lime);
   if (value<=2 && value>0) ObjectSet("V+4",OBJPROP_COLOR,Lime);
   if (value<=3 && value>0) ObjectSet("V+3",OBJPROP_COLOR,LawnGreen);
   if (value<=4 && value>0) ObjectSet("V+2",OBJPROP_COLOR,LawnGreen);
   if (value<=5 && value>0) ObjectSet("V+1",OBJPROP_COLOR,GreenYellow);
  }
   void paintWPRDown(int value)
   {
   ObjectSet("V=0",OBJPROP_COLOR,Yellow);
   if (value>=6) ObjectSet("V-1",OBJPROP_COLOR,Gold);
   if (value>=7) ObjectSet("V-2",OBJPROP_COLOR,Orange);
   if (value>=8) ObjectSet("V-3",OBJPROP_COLOR,DarkOrange); 
   if (value>=9) ObjectSet("V-4",OBJPROP_COLOR,OrangeRed); 
   if (value==10) ObjectSet("V-5",OBJPROP_COLOR,Red);   
   ObjectSet("WPRLine1",OBJPROP_COLOR,DimGray);
   ObjectSet("WPRLine2",OBJPROP_COLOR,DimGray);
   ObjectSet("WPRLine3",OBJPROP_COLOR,DimGray);
   ObjectSet("WPRTitle",OBJPROP_COLOR,DimGray);
   ObjectSet("VolumeChart",OBJPROP_COLOR,SkyBlue);
   ObjectSet("WPRpercent",OBJPROP_COLOR,Silver);  
  }     
  void paintWPRValue(int value)
  {
   ObjectSetText("WPRValue",DoubleToStr(value,0),9,"Arial",White);        
  }   
   
  // Spread Graphs -------------------    
  void paintSpread(double value)
  {
   ObjectSet("SpreadPips",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("SpreadValue",DoubleToStr(value,1),18,"Arial Narrow",White);
  }    
  
    void paintSpreadLines()
  {
   ObjectSet("SpreadLine1",OBJPROP_COLOR,DimGray);
   ObjectSet("SpreadLine2",OBJPROP_COLOR,DimGray);
   ObjectSet("SpreadLine3",OBJPROP_COLOR,DimGray);
   ObjectSet("SpreadTitle",OBJPROP_COLOR,DimGray);
  }
  
  // PSAR Graphs -------------------
    void paintPSAR(int value)
  {
   if (value==1) 
   {
   objectCreate("PSAR_Value1",118,206,"p",20,"Wingdings 3",Lime);
   ObjectDelete("PSAR_Value2");
   ObjectSet("PSAR_Value1",OBJPROP_COLOR,Lime); 
   }
   if (value==0) 
   {
   objectCreate("PSAR_Value2",118,206,"q",20,"Wingdings 3",Red);
   ObjectDelete("PSAR_Value1");
   ObjectSet("PSAR_Value2",OBJPROP_COLOR,Red);
   }
   ObjectSet("PSAR_Title",OBJPROP_COLOR,DimGray);
   ObjectSet("PSAR_Chart",OBJPROP_COLOR,SkyBlue);
   ObjectSet("PSAR_Line1",OBJPROP_COLOR,DimGray);
   ObjectSet("PSAR_Line2",OBJPROP_COLOR,DimGray);
   ObjectSet("PSAR_Line3",OBJPROP_COLOR,DimGray);
  }
  
    // MACD Graphs -------------------
    void paintMACD(int value)
  {
   if (value==3) 
   {
   objectCreate("MACD_Value1",118,271,"p",20,"Wingdings 3",Lime);
   ObjectDelete("MACD_Value2");
   ObjectDelete("MACD_Value3");
   ObjectDelete("MACD_Value4");
   ObjectDelete("MACD_Value5");
   ObjectDelete("MACD_Value6");
   ObjectSet("MACD_Value1",OBJPROP_COLOR,Lime);
   }
   if (value==2) 
   {
   objectCreate("MACD_Value2",122,271,"X",20,"Arial",Red);
   ObjectDelete("MACD_Value4");
   ObjectDelete("MACD_Value3");
   ObjectDelete("MACD_Value1");
   ObjectDelete("MACD_Value5");
   ObjectDelete("MACD_Value6");
   ObjectSet("MACD_Value2",OBJPROP_COLOR,Red);
   }
   if (value==1) 
   {
   objectCreate("MACD_Value3",118,271,"q",20,"Wingdings 3",Red);
   ObjectDelete("MACD_Value2");
   ObjectDelete("MACD_Value4");
   ObjectDelete("MACD_Value1");
   ObjectDelete("MACD_Value5");
   ObjectDelete("MACD_Value6");
   ObjectSet("MACD_Value3",OBJPROP_COLOR,Red); 
   }
   if (value==0) 
   {
   objectCreate("MACD_Value4",122,271,"X",20,"Arial",Lime);   
   ObjectDelete("MACD_Value2");
   ObjectDelete("MACD_Value3");
   ObjectDelete("MACD_Value1");
   ObjectDelete("MACD_Value5");
   ObjectDelete("MACD_Value6");
   ObjectSet("MACD_Value4",OBJPROP_COLOR,Lime);
   }
   if (value==4) 
   {
   objectCreate("MACD_Value5",122,271,"0",20,"Arial",Lime);   
   ObjectDelete("MACD_Value2");
   ObjectDelete("MACD_Value3");
   ObjectDelete("MACD_Value1");
   ObjectDelete("MACD_Value4");
   ObjectDelete("MACD_Value6");
   ObjectSet("MACD_Value5",OBJPROP_COLOR,Lime);
   }
   if (value==5) 
   {
   objectCreate("MACD_Value6",122,271,"0",20,"Arial",Red);   
   ObjectDelete("MACD_Value2");
   ObjectDelete("MACD_Value3");
   ObjectDelete("MACD_Value1");
   ObjectDelete("MACD_Value4");
   ObjectDelete("MACD_Value5");
   ObjectSet("MACD_Value6",OBJPROP_COLOR,Red);
   }      
   ObjectSet("MACD_Title",OBJPROP_COLOR,DimGray);
   ObjectSet("MACD_Chart",OBJPROP_COLOR,SkyBlue);
   ObjectSet("MACD_Line1",OBJPROP_COLOR,DimGray);
   ObjectSet("MACD_Line2",OBJPROP_COLOR,DimGray);
  }
  
    // MAXover Graphs -------------------
    void paintMAXover(int value)
  {
   if (value==1) 
   {
   objectCreate("MAXoverValue1",69,271,"p",20,"Wingdings 3",Lime);
   ObjectDelete("MAXoverValue2");
   ObjectSet("MAXoverValue1",OBJPROP_COLOR,Lime); 
   }
   if (value==0) 
   {
   objectCreate("MAXoverValue2",69,271,"q",20,"Wingdings 3",Red);
   ObjectDelete("MAXoverValue1");
   ObjectSet("MAXoverValue2",OBJPROP_COLOR,Red);
   }
   ObjectSet("MAXoverTitle",OBJPROP_COLOR,DimGray);
   ObjectSet("MAXoverChart",OBJPROP_COLOR,SkyBlue);
   ObjectSet("MAXoverLine1",OBJPROP_COLOR,DimGray);
   ObjectSet("MAXoverLine2",OBJPROP_COLOR,DimGray);
  }
  // BarMeter Graphs -------------------------------
  
  void paintBar1(double value)
  {
   if (value == 11) ObjectSet("Bar_1",OBJPROP_COLOR,C'035,035,035');
   if (value == 12) ObjectSet("Bar_1",OBJPROP_COLOR,C'000,000,000');
   if (value == 1) ObjectSet("Bar_1",OBJPROP_COLOR,C'000,255,000');
   if (value == 2) ObjectSet("Bar_1",OBJPROP_COLOR,C'000,200,000');
   if (value == 3) ObjectSet("Bar_1",OBJPROP_COLOR,C'000,150,000');
   if (value == 4) ObjectSet("Bar_1",OBJPROP_COLOR,C'000,100,000');   
   if (value == 5) ObjectSet("Bar_1",OBJPROP_COLOR,C'000,070,000');
   if (value == 6) ObjectSet("Bar_1",OBJPROP_COLOR,C'070,000,000');
   if (value == 7) ObjectSet("Bar_1",OBJPROP_COLOR,C'100,000,000');
   if (value == 8) ObjectSet("Bar_1",OBJPROP_COLOR,C'150,000,000');   
   if (value == 9) ObjectSet("Bar_1",OBJPROP_COLOR,C'200,000,000');
   if (value == 10) ObjectSet("Bar_1",OBJPROP_COLOR,C'255,000,000');
  }  
    void paintBar2(double value)
  {
   if (value == 11) ObjectSet("Bar_2",OBJPROP_COLOR,C'035,035,035');
   if (value == 12) ObjectSet("Bar_2",OBJPROP_COLOR,C'000,000,000');
   if (value == 1) ObjectSet("Bar_2",OBJPROP_COLOR,C'000,255,000');
   if (value == 2) ObjectSet("Bar_2",OBJPROP_COLOR,C'000,200,000');
   if (value == 3) ObjectSet("Bar_2",OBJPROP_COLOR,C'000,150,000');
   if (value == 4) ObjectSet("Bar_2",OBJPROP_COLOR,C'000,100,000');   
   if (value == 5) ObjectSet("Bar_2",OBJPROP_COLOR,C'000,070,000');
   if (value == 6) ObjectSet("Bar_2",OBJPROP_COLOR,C'070,000,000');
   if (value == 7) ObjectSet("Bar_2",OBJPROP_COLOR,C'100,000,000');
   if (value == 8) ObjectSet("Bar_2",OBJPROP_COLOR,C'150,000,000');   
   if (value == 9) ObjectSet("Bar_2",OBJPROP_COLOR,C'200,000,000');
   if (value == 10) ObjectSet("Bar_2",OBJPROP_COLOR,C'255,000,000');
  }  
    void paintBar3(double value)
  {
   if (value == 11) ObjectSet("Bar_3",OBJPROP_COLOR,C'035,035,035');
   if (value == 12) ObjectSet("Bar_3",OBJPROP_COLOR,C'000,000,000');
   if (value == 1) ObjectSet("Bar_3",OBJPROP_COLOR,C'000,255,000');
   if (value == 2) ObjectSet("Bar_3",OBJPROP_COLOR,C'000,200,000');
   if (value == 3) ObjectSet("Bar_3",OBJPROP_COLOR,C'000,150,000');
   if (value == 4) ObjectSet("Bar_3",OBJPROP_COLOR,C'000,100,000');   
   if (value == 5) ObjectSet("Bar_3",OBJPROP_COLOR,C'000,070,000');
   if (value == 6) ObjectSet("Bar_3",OBJPROP_COLOR,C'070,000,000');
   if (value == 7) ObjectSet("Bar_3",OBJPROP_COLOR,C'100,000,000');
   if (value == 8) ObjectSet("Bar_3",OBJPROP_COLOR,C'150,000,000');   
   if (value == 9) ObjectSet("Bar_3",OBJPROP_COLOR,C'200,000,000');
   if (value == 10) ObjectSet("Bar_3",OBJPROP_COLOR,C'255,000,000');
  }  
    void paintBar4(double value)
  {
   if (value == 11) ObjectSet("Bar_4",OBJPROP_COLOR,C'035,035,035');
   if (value == 12) ObjectSet("Bar_4",OBJPROP_COLOR,C'000,000,000');
   if (value == 1) ObjectSet("Bar_4",OBJPROP_COLOR,C'000,255,000');
   if (value == 2) ObjectSet("Bar_4",OBJPROP_COLOR,C'000,200,000');
   if (value == 3) ObjectSet("Bar_4",OBJPROP_COLOR,C'000,150,000');
   if (value == 4) ObjectSet("Bar_4",OBJPROP_COLOR,C'000,100,000');   
   if (value == 5) ObjectSet("Bar_4",OBJPROP_COLOR,C'000,070,000');
   if (value == 6) ObjectSet("Bar_4",OBJPROP_COLOR,C'070,000,000');
   if (value == 7) ObjectSet("Bar_4",OBJPROP_COLOR,C'100,000,000');
   if (value == 8) ObjectSet("Bar_4",OBJPROP_COLOR,C'150,000,000');   
   if (value == 9) ObjectSet("Bar_4",OBJPROP_COLOR,C'200,000,000');
   if (value == 10) ObjectSet("Bar_4",OBJPROP_COLOR,C'255,000,000');
  }  
    void paintBar5(double value)
  {
   if (value == 11) ObjectSet("Bar_5",OBJPROP_COLOR,C'035,035,035');
   if (value == 12) ObjectSet("Bar_5",OBJPROP_COLOR,C'000,000,000');
   if (value == 1) ObjectSet("Bar_5",OBJPROP_COLOR,C'000,255,000');
   if (value == 2) ObjectSet("Bar_5",OBJPROP_COLOR,C'000,200,000');
   if (value == 3) ObjectSet("Bar_5",OBJPROP_COLOR,C'000,150,000');
   if (value == 4) ObjectSet("Bar_5",OBJPROP_COLOR,C'000,100,000');   
   if (value == 5) ObjectSet("Bar_5",OBJPROP_COLOR,C'000,070,000');
   if (value == 6) ObjectSet("Bar_5",OBJPROP_COLOR,C'070,000,000');
   if (value == 7) ObjectSet("Bar_5",OBJPROP_COLOR,C'100,000,000');
   if (value == 8) ObjectSet("Bar_5",OBJPROP_COLOR,C'150,000,000');   
   if (value == 9) ObjectSet("Bar_5",OBJPROP_COLOR,C'200,000,000');
   if (value == 10) ObjectSet("Bar_5",OBJPROP_COLOR,C'255,000,000');
  }  
   void paintBars()
  {
   ObjectSet("BarsLine1",OBJPROP_COLOR,DimGray);
   ObjectSet("BarsLine2",OBJPROP_COLOR,DimGray);
   ObjectSet("BarsLine3",OBJPROP_COLOR,DimGray);
   ObjectSet("BarsTitle",OBJPROP_COLOR,DimGray);
   ObjectSet("BarsPercent",OBJPROP_COLOR,Silver);
   ObjectSet("BarsDescription",OBJPROP_COLOR,DimGray);
   ObjectSet("B_1",OBJPROP_COLOR,SkyBlue);
   ObjectSet("B_2",OBJPROP_COLOR,SkyBlue);
   ObjectSet("B_3",OBJPROP_COLOR,SkyBlue);
   ObjectSet("B_4",OBJPROP_COLOR,SkyBlue);
   ObjectSet("B_5",OBJPROP_COLOR,SkyBlue);
  }  
   void paintBarValue1(double value)
  {
  ObjectSetText("Bar_Value1",DoubleToStr(value,0),8,"Arial Narrow",White);
  }    
  void paintBarValue2(double value)
  {
  ObjectSetText("Bar_Value2",DoubleToStr(value,0),8,"Arial Narrow",DimGray);
  } 
  void paintBarValue3(double value)
  {
  ObjectSetText("Bar_Value3",DoubleToStr(value,0),8,"Arial Narrow",DimGray);
  } 
  void paintBarValue4(double value)
  {
  ObjectSetText("Bar_Value4",DoubleToStr(value,0),8,"Arial Narrow",DimGray);
  } 
  void paintBarValue5(double value)
  {
  ObjectSetText("Bar_Value5",DoubleToStr(value,0),8,"Arial Narrow",DimGray);
  } 
  void paintBarReading(int value)
  {
   if (value==1) 
   {
   objectCreate("BarsStopped",83,385,"Stopped",8,"Arial",Silver);
   ObjectDelete("BarsSpeeding");
   ObjectDelete("BarsSteady");
   ObjectDelete("BarsSlowing");
   ObjectSet("BarsStopped",OBJPROP_COLOR,Silver); 
   }
   if (value==2) 
   {
   objectCreate("BarsSpeeding",70,385,"Speeding Up",8,"Arial",Silver);
   ObjectDelete("BarsStopped");
   ObjectDelete("BarsSteady");
   ObjectDelete("BarsSlowing");
   ObjectSet("BarsSpeeding",OBJPROP_COLOR,Silver);
   }
   if (value==3) 
   {
   objectCreate("BarsSteady",85,385,"Steady",8,"Arial",Silver);
   ObjectDelete("BarsSpeeding");
   ObjectDelete("BarsStopped");
   ObjectDelete("BarsSlowing");
   ObjectSet("BarsSteady",OBJPROP_COLOR,Silver); 
   }
   if (value==4) 
   {
   objectCreate("BarsSlowing",70,385,"Slowing Down",8,"Arial",Silver);
   ObjectDelete("BarsSpeeding");
   ObjectDelete("BarsSteady");
   ObjectDelete("BarsStopped");
   ObjectSet("BarsSlowing",OBJPROP_COLOR,Silver);
   }
  }
  
   // Signal Graphs -------------------
    void paintSignal(int value)
  {
   if (value==1) 
   {
   objectCreate("SignalDown",10,342,"q",28,"Wingdings 3",Red);
   ObjectDelete("SignalUp");
   ObjectDelete("SignalWait");
   ObjectSet("SignalDown",OBJPROP_COLOR,Red); 
   }
   if (value==2) 
   {
   objectCreate("SignalUp",10,342,"p",28,"Wingdings 3",Lime);
   ObjectDelete("SignalDown");
   ObjectDelete("SignalWait");
   ObjectSet("SignalUp",OBJPROP_COLOR,Lime);
   }
   if (value==0) 
   {
   objectCreate("SignalWait",17,342,"6",28,"Wingdings",Silver);
   ObjectDelete("SignalDown");
   ObjectDelete("SignalUp");
   ObjectSet("SignalWait",OBJPROP_COLOR,DimGray);
   }
   ObjectSet("SignalLine1",OBJPROP_COLOR,DimGray);
   ObjectSet("SignalLine2",OBJPROP_COLOR,DimGray);
   ObjectSet("SignalTitle",OBJPROP_COLOR,DimGray);
  return(0);
    }
   
