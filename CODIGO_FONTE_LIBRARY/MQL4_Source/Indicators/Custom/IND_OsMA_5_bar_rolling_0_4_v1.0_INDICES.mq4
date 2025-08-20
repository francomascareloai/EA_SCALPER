//+------------------------------------------------------------------+
//|                                                         OsMA.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2004, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 1
#property  indicator_color1  Silver
//---- indicator parameters
extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalSMA=9;
//---- indicator buffers
double     ind_buffer1[];
double     ind_buffer2[];
double     ind_buffer3[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(3);
//---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,3);
   SetIndexDrawBegin(0,SignalSMA);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);
//---- 3 indicator buffers mapping
   if(!SetIndexBuffer(0,ind_buffer1) &&
      !SetIndexBuffer(1,ind_buffer2) &&
      !SetIndexBuffer(2,ind_buffer3))
      Print("cannot set indicator buffers!");
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("OsMA_5_bar_rolling ("+FastEMA+","+SlowEMA+","+SignalSMA+")");
//---- initialization done

   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Average of Oscillator                                     |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- macd counted in the 1-st additional buffer


   for(int i=0; i<limit; i++)
      {

      //------Get close prices 5-bar groups (i.e. close of every 5th bar going back from the bar the indicator is currently working on)
      double ClosePricesArray[];
      ArrayResize(ClosePricesArray,Bars-i);
      
      ClosePricesArray[0] = Close[i];
      int cnt=1;
      for(int CurrBar=i+5; CurrBar<=Bars-i-1; CurrBar=CurrBar+5)
         {
         ClosePricesArray[cnt]=Close[CurrBar];
         cnt++;
         }
      
      ArrayResize(ClosePricesArray,cnt); 
         

      //------Calculate the first of two EMAs the MACD is based on
      double ExtMapBuffer[];
      ArrayResize(ExtMapBuffer,cnt);
      double pr=2.0/(FastEMA+1);
      int    pos=cnt-2;
      while(pos>=0)
        {
         if(pos==cnt-2) ExtMapBuffer[pos+1]=ClosePricesArray[pos+1];
         ExtMapBuffer[pos]=ClosePricesArray[pos]*pr+ExtMapBuffer[pos+1]*(1-pr);
         pos--;
        }
      
      
      //------Calculate the second of two EMAs the MACD is based on
      double ExtMapBuffer2[];
      ArrayResize(ExtMapBuffer2,cnt);
      pr=2.0/(SlowEMA+1);
      pos=cnt-2;
      while(pos>=0)
        {
         if(pos==cnt-2) ExtMapBuffer2[pos+1]=ClosePricesArray[pos+1];
         ExtMapBuffer2[pos]=ClosePricesArray[pos]*pr+ExtMapBuffer2[pos+1]*(1-pr);
         pos--;
        }


      //------Calculate the MACD main line, which is the difference of the two MACD EMAs
      double ExtMapBuffer3[];
      ArrayResize(ExtMapBuffer3,cnt);
      for(int cnt2=0; cnt2<cnt; cnt2++)
         {
         ExtMapBuffer3[cnt2]=ExtMapBuffer[cnt2]-ExtMapBuffer2[cnt2];
         }
      //------Calculate the MACD signal line value for the current bar, which is SMA9 of the MACD main line
      double MACDsignalline=0;
      
      for (cnt2=0;cnt2<SignalSMA;cnt2++)
         {
         MACDsignalline=MACDsignalline+ExtMapBuffer3[cnt2];
         }
      MACDsignalline=MACDsignalline/SignalSMA;
      
      
      
      //Assign the indicator value as the difference between the MACD main and signal lines (OSMA)
      ind_buffer1[i]=ExtMapBuffer3[0]-MACDsignalline;
      }
            

//---- done
   return(0);
  }
//+------------------------------------------------------------------+

