//+------------------------------------------------------------------+
//|                                                Schaff Trendy.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link "perky_z@yahoo.com & Darkstonexa@yahoo.com.au"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 LightSeaGreen
#property indicator_color2 Red

//---- input parameters
extern int SigPeriod = 23;
extern int MAShort = 23;
extern int MALong = 50;
extern int Cycle = 10;
extern int BarsCount = 500;

//----
int shift=0;
double MCD=0, LLV=0, HHV=0, i=0, s=0 ,MA_Short=0, MA_Long=0, ST=0;
double smconst=0;
bool check_begin=false;
bool check_begin_MA=false;
int sum=0, n=0, bars_=0;
double MA=0.0, prev=0.0;
double MCD_Arr[500];
//---- buffers
double TrendBuffer[];
double SignalBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

//---- 3 additional buffers are used for counting.
   IndicatorBuffers(2);
//---- indicator buffers
   SetIndexBuffer(0, TrendBuffer);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(1, SignalBuffer);
   SetIndexStyle(1, DRAW_LINE);
   //---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Schaff Trend(" + Cycle + ")");
   SetIndexDrawBegin(0, BarsCount);
   return(0);
  }
//+------------------------------------------------------------------+
//|  Schaff Trendy                                                   |
//+------------------------------------------------------------------+
int start()
  {
   check_begin = false;
   check_begin_MA = false;
   n = 1;
   s = 1;
   double a = 1 + Cycle / 2;
   smconst = 1 / a;
   if(BarsCount > 0)
     {
       if(BarsCount > Bars)
         {
           bars_ = Bars;
         }
       else
         {
           bars_ = BarsCount;
         }
     }
   for(shift = bars_ ; shift >= 0; shift--)
     {
       MA_Short = iMA(NULL, 0, MAShort, 0, MODE_EMA, PRICE_TYPICAL, shift);
       MA_Long = iMA(NULL, 0, MALong, 0, MODE_EMA, PRICE_TYPICAL, shift);
       MCD_Arr[n] = MA_Short - MA_Long;
       MCD = MA_Short - MA_Long;
       //----
       if(n >= Cycle )
         {
           n = 1;
           check_begin = true;
         }
       else 
           n = n + 1;

       if(check_begin)
         {
           for(int i = 1; i <= Cycle; i++)
             {
               if(i == 1) 
                   LLV = MCD_Arr[i];
               else
                   if(LLV > MCD_Arr[i])
                       LLV = MCD_Arr[i];
                   //----
                   if(i == 1 )
                       HHV = MCD_Arr[i];
                   else
                       if(HHV < MCD_Arr[i])
                           HHV = MCD_Arr[i];
             }
           ST = ((MCD - LLV) / (HHV - LLV))*100 + 0.01;
           s = s + 1;
           if(s >= (Cycle) / 2)
             {
               s = 1;
               check_begin_MA = true;
             }
         }
       else ST = 0;
           if(check_begin_MA)
             {
               prev = TrendBuffer[shift+1];
               MA = smconst*(ST - prev) + prev;
               //Comment ("\nMa= ",MA,"\nPrev= ",prev,"\nST=  ",ST,"\nLLV=  ",LLV,"\nHHV=  ",HHV,"\nMCD= ",MCD,"\nTrendBuffer=  ",TrendBuffer[shift-1],"\n smsconst  ",smconst);
               TrendBuffer[shift]=MA;
               
             }
             
     }
     for(shift = bars_ ; shift >= 0; shift--)
     {
     SignalBuffer[shift]=iMAOnArray(TrendBuffer,0,SigPeriod,0,MODE_EMA,shift);
     }
   return(0);
  }
//+------------------------------------------------------------------+