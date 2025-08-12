//+------------------------------------------------------------------+
//|                                        Trendsignal version 2.mq4 |
//|                                                    Pankaj Bhaban |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "pankajbhaban@gmail.com"
#property link      "trendsignal.co.in"


#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 DodgerBlue
#property indicator_color2 Magenta
#property indicator_color3 White

#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 2

//---- input parameters
extern int RISK=3;
extern int SSP=9;
int CountBars=500;
int Alert_Delay_In_Seconds=0;
extern bool Enablemail=false;
string subjectUp="Buy signal";
string subjectDown="Sell signal";
string textUp="Long ";
string textDown="Short ";

int PrevAlertTime=0;

//---- buffers
double val1[];
double val2[];
double alertBar;
double Mainbuffer[];
double UpperBuffer[];
double LowerBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorDigits(Digits);

   string short_name;
//---- indicator line
   IndicatorBuffers(5);

   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexBuffer(0,val1);
   SetIndexBuffer(1,val2);

//---- drawing settings
   SetIndexStyle(2,DRAW_SECTION);
//---- indicator buffers mapping
   SetIndexBuffer(2,Mainbuffer);
   SetIndexBuffer(3,UpperBuffer);
   SetIndexBuffer(4,LowerBuffer);

   SetIndexLabel(0,"UP");
   SetIndexLabel(1,"DOWN");
   SetIndexLabel(2,"Potential targets");

   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);
   SetIndexEmptyValue(2,0);

//----
   return( 0 );
  }
//+------------------------------------------------------------------+
//| 
//+------------------------------------------------------------------+
int start()
  {
   if(CountBars>=Bars) CountBars=Bars;
   SetIndexDrawBegin(0,Bars-CountBars+SSP);
   SetIndexDrawBegin(1,Bars-CountBars+SSP);
   int i,shift;
   int i1,i2,K;
   double Range,AvgRange,smin,smax,SsMax,SsMin,price;
   bool uptrend,old;
//----

   if(Bars<=SSP+1) return(0);
//---- initial zero
/*if( counted_bars < SSP+1 ) {
      for(i=1;i<=SSP;i++) val1[CountBars-i]=0.0;
      for(i=1;i<=SSP;i++) val2[CountBars-i]=0.0;
   }
*/
//----
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+SSP;

   K=33-RISK;
   for(shift=limit; shift>=0; shift--) 
     {
      Range=0;
      AvgRange=0;

      for(i1=shift; i1<=shift+SSP; i1++) 
        {
         AvgRange=AvgRange+MathAbs(High[i1]-Low[i1]);
        }
      Range=AvgRange/(SSP+1);

      SsMax=High[shift]; SsMin=Low[shift];

      for(i2=shift;i2<=shift+SSP-1;i2++) 
        {
         price=High[i2];
         if(SsMax<price) SsMax=price;
         price=Low[i2];
         if(SsMin>=price) SsMin=price;
        }

      smin = SsMin+(SsMax-SsMin)*K/100;
      smax = SsMax-(SsMax-SsMin)*K/100;
      val1[shift]=0;
      val2[shift]=0;

      if(Close[shift]<smin) 
        {
         uptrend=false;
        }
      if(Close[shift]>smax) 
        {
         uptrend=true;
        }

      if(uptrend!=old && uptrend==true) 
        {
         val1[shift]=Low[shift]-Range*0.5;
         Mainbuffer[shift]=val1[shift];
         if(Bars>alertBar && shift==0 && (CurTime()-PrevAlertTime>Period()*Alert_Delay_In_Seconds)) 
           {

            Alert("Trendsignal V2.0 ",Period(),""," Mins Timeframe",Symbol()," BUY @",Ask,"");alertBar=Bars;
            if(Enablemail==true) {SendMail(subjectDown+" "+Symbol(),textDown+" "+Close[1]+" "+Symbol()); }
            PrevAlertTime=CurTime();
           }
        }

      if(uptrend!=old && uptrend==false) 
        {

         val2[shift]=High[shift]+Range*0.5;
         Mainbuffer[shift]=val2[shift];
         if(Bars>alertBar && shift==0 && (CurTime()-PrevAlertTime>Period()*Alert_Delay_In_Seconds)) 
           {

            Alert("Trendsignal V2.0 ",Period(),"","Mins Timeframe ",Symbol()," SELL @",Bid,"");alertBar=Bars;
            if(Enablemail==true) {SendMail(subjectUp+" "+Symbol(),textUp+" "+Close[1]+" "+Symbol());}
            PrevAlertTime=CurTime();
           }
        }

      Comment(shift);
      old=uptrend;
     }

   return(0);
  }
//+------------------------------------------------------------------+
