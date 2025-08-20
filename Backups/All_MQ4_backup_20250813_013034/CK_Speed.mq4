//+------------------------------------------------------------------+
//|                                                   TrendJugde.mq4 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
extern int period=20;
extern double level=50;
//extern int ema1=34;
//extern int ema2=89;
#property indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  Green
#property  indicator_color2  Red
#property  indicator_color3  Yellow


#property indicator_maximum 3

bool uptrend=false;
bool downtrend=false;
double fast[],medium[],slow[],atr[],std[],rsistd[],rsiatr[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
IndicatorBuffers(7);   
//---- drawing settings
      
   SetIndexBuffer(0,fast);//bbMacd line
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,3);
   SetIndexBuffer(1,medium);//Upperband line
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,3);
   SetIndexDrawBegin(0,period);
   SetIndexDrawBegin(1,period);
   
   SetIndexBuffer(2,slow);//overbough
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,3);
    SetIndexDrawBegin(2,period);
 
  SetIndexBuffer(3,atr);//overbough
  SetIndexBuffer(4,std);//overbough
  SetIndexBuffer(5,rsistd);//overbough
  SetIndexBuffer(6,rsiatr);//overbough
  
  IndicatorShortName("CK Speed "+ period);
  SetIndexLabel(0,"Trend");
  SetIndexLabel(1,"Correction");
SetIndexLabel(2,"Sleep");
  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
//----
double prev,current,tmp;
   int limit;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   //uptrend=true;
   //owntrend=true;
   double filterbuy=60;
   double filtersell=40;
//----
for(int k=limit-1;k>=0;k--){
   atr[k]=iATR(Symbol(),0,period,k);
     std[k]=iStdDev(Symbol(),0,period,0,0,PRICE_MEDIAN,k);
}
//for(int t=limit-period;t>=0;t--){
  
//}
for(int i=limit-1; i>=0; i--)
 {
     rsistd[i]=iRSIOnArray(std,0,period,i);
     rsiatr[i]=iRSIOnArray(atr,0,period,i);
     
      if(rsistd[i]>=level&&rsiatr[i]>=level){
         fast[i]=3;
         medium[i]=0;
         slow[i]=0;
         
       }else if(rsistd[i]<level&&rsiatr[i]<level){
         fast[i]=0;
         medium[i]=0;
         slow[i]=1;
      } else{
         fast[i]=0;
         medium[i]=2;
         slow[i]=0;
      }
  }         
   return(0);
  }
//+------------------------------------------------------------------+