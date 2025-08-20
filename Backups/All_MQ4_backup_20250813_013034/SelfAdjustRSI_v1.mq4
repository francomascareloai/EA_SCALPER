//+------------------------------------------------------------------+
//|                                              SelfAjustRSI_v1.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                       Author IgorAD by idea of David Sepiashvili |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1  30
#property indicator_level2  70
#property indicator_level3  50
#property indicator_buffers 3
#property indicator_color1 DodgerBlue
#property indicator_color2 Lime
#property indicator_color3 Lime
//---- input parameters
extern int Price        = 0; // O-Close; 1-Open; 2-High; 3-Low; 4-Median; 5-Typical; 6-Weighted 
extern int RSIPeriod    =14; // Period of RSI
extern double K         = 1; // Deviation ratio
extern int Mode         = 0; // RSI mode : 0 - typical(smoothed by SMMA); 1- clssic (smoothed by SMA)
//---- buffers
double RSIBuffer[];
double OBBuffer[];
double OSBuffer[];
double PosBuffer[];
double NegBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(5);
   SetIndexBuffer(3,PosBuffer);
   SetIndexBuffer(4,NegBuffer);
//---- indicator lines
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RSIBuffer);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,OBBuffer);
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,OSBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="SelfAjustRSI("+RSIPeriod+","+DoubleToStr(K,2)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,"Overbought");
   SetIndexLabel(2,"OverSold");
//----
   SetIndexDrawBegin(0,RSIPeriod);
   SetIndexDrawBegin(1,RSIPeriod);
   SetIndexDrawBegin(2,RSIPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Self-Adjusting Relative Strength Index by David Sepiashvili      |
//+------------------------------------------------------------------+
int start()
  {
   int    i,limit,counted_bars=IndicatorCounted();
   double rel,negative,positive;
//----
   if(Bars<=RSIPeriod) return(0);
//---- initial zero
   //if(counted_bars<1)
   //   for(i=1;i<=RSIPeriod;i++) RSIBuffer[Bars-i]=0.0;
//----
   if ( counted_bars > 0 )  limit=Bars-counted_bars;
   if ( counted_bars < 0 )  return(0);
   if ( counted_bars ==0 )  limit=Bars-RSIPeriod-1; 
      
   for(i=limit;i>=0;i--) 
   {	
      double sumn=0.0,sump=0.0;
      if(i==Bars-RSIPeriod-1)
       {
         int k=Bars-2;
         //---- initial accumulation
         while(k>=i)
           {
            rel=iMA(NULL,0,1,0,MODE_SMA,Price,k)-iMA(NULL,0,1,0,MODE_SMA,Price,k+1);
            if(rel>0) sump+=rel;
            else      sumn-=rel;
            k--;
           }
         positive=sump/RSIPeriod;
         negative=sumn/RSIPeriod;
        }
      else
        {
         //---- smoothed moving average
         if (Mode == 0)
         {
         rel=iMA(NULL,0,1,0,MODE_SMA,Price,i)-iMA(NULL,0,1,0,MODE_SMA,Price,i+1);
         if(rel>0) sump=rel;
         else      sumn=-rel;
                 
         positive=(PosBuffer[i+1]*(RSIPeriod-1)+sump)/RSIPeriod;
         negative=(NegBuffer[i+1]*(RSIPeriod-1)+sumn)/RSIPeriod;
         }
         else
         if (Mode == 1)
         {
          sumn=0.0;sump=0.0;
          for ( k=RSIPeriod-1;k>=0;k--)
           { 
            rel=iMA(NULL,0,1,0,MODE_SMA,Price,i+k)-iMA(NULL,0,1,0,MODE_SMA,Price,i+k+1);
            if(rel>0) sump+=rel;
            else      sumn-=rel;
           }
         
         
         positive=sump/RSIPeriod;
         negative=sumn/RSIPeriod;
         }
        }
      PosBuffer[i]=positive;
      NegBuffer[i]=negative;
      if(negative==0.0) RSIBuffer[i]=100.0;
      else RSIBuffer[i]=100.0-100.0/(1+positive/negative);
  //  }
  // 
  // for(int j=limit;j>=0;j--) 
  // {	
      double SumRSI = 0; 
	   for ( k=RSIPeriod-1;k>=0;k--) SumRSI += RSIBuffer[i+k];
      double AvgRSI = SumRSI/RSIPeriod;
		
	   double SumSqr = 0;
	   for ( k=RSIPeriod-1;k>=0;k--) SumSqr += (RSIBuffer[i+k] - AvgRSI) * (RSIBuffer[i+k] - AvgRSI);
	   double StdDev = MathPow(SumSqr/RSIPeriod,0.5);
   
      OBBuffer[i] = 50 + K * StdDev;
      OSBuffer[i] = 50 - K * StdDev;
      
   }    
//----
   return(0);
  }
//+------------------------------------------------------------------+