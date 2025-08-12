//+------------------------------------------------------------------+
//|                                            TrendStrengthTrio.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Orange 
#property indicator_color2 Aqua 
#property indicator_color3 Green  
//---- input parameters
extern bool      Line2Visible=true;
extern bool      Line3Visible=false;
extern int       Step=5;

double TS1[];
double TS2[];
double TS3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(3);  

   IndicatorShortName("TrendStrengthTrio"); 
    
   SetIndexBuffer(0,TS1); 
   SetIndexStyle(0, DRAW_LINE); 
   SetIndexLabel(0,"TS1");     
   SetIndexBuffer(1,TS2); 
   SetIndexStyle(1, DRAW_LINE); 
   SetIndexLabel(1,"TS2");     
   SetIndexBuffer(2,TS3); 
   SetIndexStyle(2, DRAW_LINE); 
   SetIndexLabel(3,"TS3");     
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
int    mode, shift,counted_bars=IndicatorCounted(); 
   //double ma40dbl; 
   double ma0, ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9, ma10, tmp; 
   int tmpstep;
     //---- check for possible errors 
   if(counted_bars<0) return(-1); 
     //---- last counted bar will be recounted 
   if(counted_bars>0) counted_bars--; 
     //limit=Bars-counted_bars; 
   tmpstep=Step;  
   for(int s = 1; s <= 4; s++)
   {
      shift=Bars-1; 
      while(shift>=0) 
      {
         mode=MODE_EMA;
         tmp=iMA(NULL,0,5,0,mode,PRICE_WEIGHTED,shift);     
         ma1=tmp-iMA(NULL,0,tmpstep,0,mode,PRICE_WEIGHTED,shift); 
         ma2=tmp-iMA(NULL,0,tmpstep*2,0,mode,PRICE_WEIGHTED,shift); 
         ma3=tmp-iMA(NULL,0,tmpstep*3,0,mode,PRICE_WEIGHTED,shift); 
         ma4=tmp-iMA(NULL,0,tmpstep*4,0,mode,PRICE_WEIGHTED,shift);  
         ma5=tmp-iMA(NULL,0,tmpstep*5,0,mode,PRICE_WEIGHTED,shift);
         ma6=tmp-iMA(NULL,0,tmpstep*6,0,mode,PRICE_WEIGHTED,shift);
         ma7=tmp-iMA(NULL,0,tmpstep*7,0,mode,PRICE_WEIGHTED,shift);
         ma8=tmp-iMA(NULL,0,tmpstep*8,0,mode,PRICE_WEIGHTED,shift);
         ma9=tmp-iMA(NULL,0,tmpstep*9,0,mode,PRICE_WEIGHTED,shift);   
         ma10=tmp-iMA(NULL,0,tmpstep*10,0,mode,PRICE_WEIGHTED,shift);         
            
         if (s==1) {TS1[shift]=ma1+ma2+ma3+ma4+ma5+ma6+ma7+ma8+ma9+ma10;}
         if ((s==2) && (Line2Visible==true)) {TS2[shift]=ma1+ma2+ma3+ma4+ma5+ma6+ma7+ma8+ma9+ma10;}
         if ((s==3) && (Line3Visible==true)) {TS3[shift]=ma1+ma2+ma3+ma4+ma5+ma6+ma7+ma8+ma9+ma10;}
           
         shift--;// 
      } 
      tmpstep+=Step;
   }      

   return(0);
  }
//+------------------------------------------------------------------+