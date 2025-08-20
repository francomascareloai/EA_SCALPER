//+------------------------------------------------------------------+
//|                                                 SilverTrend .mq4 |
//|                       SilverTrendSignal  rewritten by CrazyChart |
//|                                                 http://viac.ru/  |
//+------------------------------------------------------------------+
#property copyright "SilverTrend  rewritten by CrazyChart"
#property link      "http://viac.ru/ "

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Fuchsia
#property indicator_color2 Aqua
//---- input parameters
extern int       RISK=3;
extern int       CountBars=300;
extern int       SSP=9;
//---- buffers
double ExtSignal1[];
double ExtSignal2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,ExtSignal1);
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexStyle(1,DRAW_SECTION);
   SetIndexBuffer(1,ExtSignal2);
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//---- TODO: add your code here

  bool firstTime=True;
  int i, loopbegin,i1,shift,cnt,deltaBar,deltaPrice,x;
  double SsMax, SsMin, K, val1, val2, smin, smax, Table_value2[500][4]; 
  double MyBars,value3,Range,AvgRange,SSP;
  double topHigh[2],downLow[2],changePrice;
  



K=33-RISK; 
if (firstTime==true)   { 
   loopbegin = Bars-CountBars; 
   MyBars=loopbegin; 
   firstTime=False; 
}; 

for (shift=Bars-SSP;shift>=0;shift--) { 
   Range=0; 
   AvgRange=0; 
   for (i1=shift;i1<=shift+9;i1++) {
      AvgRange=AvgRange+MathAbs(High[i1]-Low[i1]); 
   }; 
   Range=AvgRange/10; 
   
   SsMax = High[Highest(MODE_HIGH,shift+SSP-1,SSP)]; 
   SsMin = Low[Lowest(MODE_LOW,shift+SSP-1,SSP)]; 
   smin = SsMin+(SsMax-SsMin)*K/100; 
   smax = SsMax-(SsMax-SsMin)*K/100; 
   Table_value2[shift][1]=shift; 
   Table_value2[shift][2]=Close[shift]; 
   Table_value2[shift][3]=0; 
   ExtSignal1[shift]=0;//ExtSignal1[shift+1]; 
   ExtSignal2[shift]=0;//ExtSignal2[shift+1]; 
   value3=0;
   
   if (Close[shift]<smin) {
      i1=1; 
      Table_value2[shift][3]=-1; 
      while (Table_value2[shift+i1][3]>-1 && Table_value2[shift+i1][3]<1 && Table_value2[shift+i1][2]>0) {
         i1=i1+1;
      }; 
      if (Table_value2[shift+i1][3]==1) { 
         value3=High[shift]+Range*0.5; 
         ExtSignal1[shift]=value3;
      
       
      }; 
   }; 

   if (Close[shift]>smax) {
      i1=1; 
      Table_value2[shift][3]=1; 
         while (Table_value2[shift+i1][3]>-1 && Table_value2[shift+i1][3]<1 && Table_value2[shift+i1][2]>0) {
            i1=i1+1;
         }; 
         if (Table_value2[shift+i1][3]==-1) {
             value3=Low[shift]-Range*0.5; 
            ExtSignal2[shift]=value3; 
         }; 
   }; 
   
 
   if (shift>0) loopbegin=loopbegin+1; 
   if (MyBars<Bars && shift==0) { 
      for (i1=72;i1==2;i1--) {
         Table_value2[i1][1]=Table_value2[i1-1][1]; 
         Table_value2[i1][2]=Table_value2[i1-1][2]; 
         Table_value2[i1][3]=Table_value2[i1-1][3]; 
      }; 
   MyBars=MyBars+1; 
   }; 





 
};
  

  
   
//----
   return(0);
  }
//+------------------------------------------------------------------+