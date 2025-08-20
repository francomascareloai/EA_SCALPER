//+------------------------------------------------------------------+
//|                                                          RSI.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 1
#property indicator_color1 DodgerBlue
//---- input parameters
extern int RSIPeriod=14;
extern double UpLevel=70;
extern double DnLevel=30;
//---- buffers
double RSIBuffer[];
double PosBuffer[];
double NegBuffer[];
extern bool UseAlert = true;
extern bool EachBar  = true;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(3);
   SetIndexBuffer(1,PosBuffer);
   SetIndexBuffer(2,NegBuffer);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RSIBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="RSI("+RSIPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//----
   SetIndexDrawBegin(0,RSIPeriod);
   SetLevelValue(0, UpLevel);
   SetLevelValue(1, DnLevel);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
int start()
  {
   int    i,counted_bars=IndicatorCounted();
   double rel,negative,positive;
//----
   if(Bars<=RSIPeriod) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=RSIPeriod;i++) RSIBuffer[Bars-i]=0.0;
//----
   i=Bars-RSIPeriod-1;
   if(counted_bars>=RSIPeriod) i=Bars-counted_bars-1;
   while(i>=0)
     {
      double sumn=0.0,sump=0.0;
      if(i==Bars-RSIPeriod-1)
        {
         int k=Bars-2;
         //---- initial accumulation
         while(k>=i)
           {
            rel=Close[k]-Close[k+1];
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
         rel=Close[i]-Close[i+1];
         if(rel>0) sump=rel;
         else      sumn=-rel;
         positive=(PosBuffer[i+1]*(RSIPeriod-1)+sump)/RSIPeriod;
         negative=(NegBuffer[i+1]*(RSIPeriod-1)+sumn)/RSIPeriod;
        }
      PosBuffer[i]=positive;
      NegBuffer[i]=negative;
      if(negative==0.0) RSIBuffer[i]=0.0;
      else RSIBuffer[i]=100.0-100.0/(1+positive/negative);
      i--;
     }
     //Comment(Bars-counted_bars);
     if( Bars-counted_bars == 2 && UseAlert == true ) 
     {
        if( EachBar == true ){
           if( RSIBuffer[1] > UpLevel ) Alert("RSI on " +  Symbol() + PeriodToStr(Period()) + " In the overbought zone.");
           if( RSIBuffer[1] < DnLevel ) Alert("RSI on " +  Symbol() + PeriodToStr(Period()) + " In the oversold zone.");
        }
        else {
           if( RSIBuffer[1] > UpLevel && RSIBuffer[2] <= UpLevel ) Alert("RSI on " +  Symbol() + PeriodToStr(Period()) + " In the overbought zone.");
           if( RSIBuffer[1] < DnLevel && RSIBuffer[2] >= DnLevel ) Alert("RSI on " +  Symbol() + PeriodToStr(Period()) + " In the oversold zone.");
        }
     }
     
//----
   return(0);
  }
//+------------------------------------------------------------------+
string PeriodToStr(int ai_0) {
   string ls_ret_4;
   switch (ai_0) {
   case 1:
      ls_ret_4 = " M1 ";
      break;
   case 5:
      ls_ret_4 = " M5 ";
      break;
   case 15:
      ls_ret_4 = " M15 ";
      break;
   case 30:
      ls_ret_4 = " M30 ";
      break;
   case 60:
      ls_ret_4 = " H1 ";
      break;
   case 240:
      ls_ret_4 = " H4 ";
      break;
   case 1440:
      ls_ret_4 = " D1 ";
      break;
   case 10080:
      ls_ret_4 = " W1 ";
      break;
   case 43200:
      ls_ret_4 = " MN ";
   }
   return (ls_ret_4);
}