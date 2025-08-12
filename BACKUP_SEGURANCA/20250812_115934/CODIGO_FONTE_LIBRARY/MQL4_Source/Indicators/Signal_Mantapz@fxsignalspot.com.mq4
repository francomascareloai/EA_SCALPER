
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1

//+--------- TRO MODIFICATION ---------------------------------------+ 

 bool   Sound.Alert    = false ;
 bool   Show.PriceBox  = false;
 int    myBoxWidth     = 3;



//---- input parameters
extern int     MA_Price   =0; //Applied Price: 0-C,1-O,2-H,3-L,4-Median,5-Typical,6-Weighted
extern int     MA_Length  =4; //MA's Period 
extern int     MA_Mode    =0; //MA's Method:0-SMA,1-EMA,2-SMMA,3-LWMA  
extern int     ATR_Length =11;//ATR's Period
extern double  Kv         =2; //Volatility's Factor or Multiplier
extern double  MoneyRisk  =0.15; //Offset Factor 
 bool    usePrice_HiLoBreak    =true;
 bool    useMA_HiLoEnvelope    =false;
 int     AlertMode  =0; //0-alert off,1-on
 int     VisualMode =0; //0-lines,1-dots 
 string Applied_Price_ ="0-C,1-O,2-H,3-L,4-Median(H+L)/2,5-Typical(H+L+C)/3,6-Weighted(H+L+C+C)/4";
 string MAmethod_mode_ ="0-SMA,1-EMA,2-SMMA,3-LWMA";
 string Visual_Mode___ ="0-lines,1-dots ";
//---- indicator buffers
double UpBuffer[];
double DnBuffer[];
double UpSignal[];
double DnSignal[];
double smin[];
double smax[];
double trend[];
bool   UpTrendAlert=false, DownTrendAlert=false;

//+--------- TRO MODIFICATION ---------------------------------------+ 
string symbol, tChartPeriod,  tShortName ;  
int    digits, period  ; 

bool Trigger ;

int OldBars = -1 ;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  int init()
  {

//+--------- TRO MODIFICATION ---------------------------------------+  
   period       = Period() ;     
   tChartPeriod =  TimeFrameToString(period) ;
   symbol       =  Symbol() ;
   digits       =  Digits ;   

   tShortName = "tbb"+ symbol + tChartPeriod  ;
      
  
   string short_name;
//---- indicator line
   IndicatorBuffers(7);
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DnBuffer);
   SetIndexBuffer(2,UpSignal);
   SetIndexBuffer(3,DnSignal);
   SetIndexBuffer(4,smin);
   SetIndexBuffer(5,smax);
   SetIndexBuffer(6,trend);
//----
   if(VisualMode==0)
     {
      SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexStyle(1,DRAW_HISTOGRAM);
     }
   else
     {
      SetIndexStyle(0,DRAW_ARROW);
      SetIndexStyle(1,DRAW_ARROW);
      SetIndexArrow(0,159);
      SetIndexArrow(1,159);
     }
//----
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(2,108);
   SetIndexArrow(3,108);
//---- name for DataWindow and indicator subwindow label
   short_name="signal_Mantapz";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"UpTrend");
   SetIndexLabel(1,"DnTrend");
   SetIndexLabel(2,"UpSignal");
   SetIndexLabel(3,"DnSignal");
//----
   SetIndexDrawBegin(0,MA_Length+ATR_Length);
   SetIndexDrawBegin(1,MA_Length+ATR_Length);
   SetIndexDrawBegin(2,MA_Length+ATR_Length);
   SetIndexDrawBegin(3,MA_Length+ATR_Length);
//----
   return(0);
  }
  
  
int deinit()
  {
//+--------- TRO MODIFICATION ---------------------------------------+ 
   ObjectDelete(tShortName+"01"); 
   ObjectDelete(tShortName+"02");    
//----
   return(0);
  }


//+------------------------------------------------------------------+
//| VoltyChannel_Stop_2                                              |
//+------------------------------------------------------------------+
int start()
  {
//+--------- TRO MODIFICATION ---------------------------------------+   
   if( Bars != OldBars ) { Trigger = True ; }  
  
   int shift,limit, counted_bars=IndicatorCounted();
//----
   if(counted_bars > 0) limit=Bars-counted_bars;
   if(counted_bars < 0) return(0);
   if(counted_bars ==0) limit=Bars-MA_Length-1;
   for(shift=limit;shift>=0;shift--)
     {
      if(useMA_HiLoEnvelope)
        {
         double bprice=iMA(NULL,0,MA_Length,0,MA_Mode,2,shift);
         double sprice=iMA(NULL,0,MA_Length,0,MA_Mode,3,shift);
        }
      else
        {
         bprice=iMA(NULL,0,MA_Length,0,MA_Mode,MA_Price,shift);
         sprice=iMA(NULL,0,MA_Length,0,MA_Mode,MA_Price,shift);
        }
      smax[shift]=bprice + Kv*iATR(NULL,0,ATR_Length,shift);
      smin[shift]=sprice - Kv*iATR(NULL,0,ATR_Length,shift);
      trend[shift]=trend[shift+1];
      if(usePrice_HiLoBreak)
        {
         if(High[shift] > smax[shift+1])trend[shift]= 1;
         if(Low[shift]  < smin[shift+1])trend[shift]=-1;
        }
      else
        {
         if(bprice > smax[shift+1])trend[shift]= 1;
         if(sprice < smin[shift+1])trend[shift]=-1;
        }
      if(trend[shift] >0)
        {
         if(smin[shift] < smin[shift+1]) smin[shift]=smin[shift+1];
         UpBuffer[shift]=smin[shift] - (MoneyRisk - 1)*iATR(NULL,0,ATR_Length,shift);
         if(UpBuffer[shift] < UpBuffer[shift+1] && UpBuffer[shift+1]!=EMPTY_VALUE) UpBuffer[shift]=UpBuffer[shift+1];
         if(trend[shift+1]!=trend[shift]) UpSignal[shift]=UpBuffer[shift];
         else UpSignal[shift]=EMPTY_VALUE;
         DnBuffer[shift]=EMPTY_VALUE;
         DnSignal[shift]=EMPTY_VALUE;
        }
      else
         if(trend[shift] <0)
           {
            if(smax[shift]>smax[shift+1]) smax[shift]=smax[shift+1];
            DnBuffer[shift]=smax[shift] + (MoneyRisk - 1)*iATR(NULL,0,ATR_Length,shift);
            if(DnBuffer[shift] > DnBuffer[shift+1]) DnBuffer[shift]=DnBuffer[shift+1];
            if(trend[shift+1]!=trend[shift]) DnSignal[shift]=DnBuffer[shift];
            else DnSignal[shift]=EMPTY_VALUE;
            UpBuffer[shift]=EMPTY_VALUE;
            UpSignal[shift]=EMPTY_VALUE;
           }
     }
//----   
   string Message;
   if(trend[2]<0 && trend[1]>0 && Volume[0]>1 && !UpTrendAlert)
     {
      Message=" "+Symbol()+" M"+Period()+": VCS Signal for BUY";
      if(AlertMode>0)Alert (Message);
      UpTrendAlert=true; DownTrendAlert=false;
     }
   if(trend[2]>0 && trend[1]<0 && Volume[0]>1 && !DownTrendAlert)
     {
      Message=" "+Symbol()+" M"+Period()+": VCS Signal for SELL";
      if(AlertMode>0)Alert (Message);
      DownTrendAlert=true; UpTrendAlert=false;
     }
//----	

  
//+--------- TRO MODIFICATION ---------------------------------------+  
      
      if ( Trigger &&  Sound.Alert ) 
      {
        if( Close[0] > UpBuffer[0] && UpBuffer[0]!= EMPTY_VALUE ) { Trigger = False ; Alert(symbol,"  ", tChartPeriod, " Price above Upper Volty "+ DoubleToStr(UpBuffer[0] ,digits)); }
        if( Close[0] < DnBuffer[0] && DnBuffer[0]!= EMPTY_VALUE ) { Trigger = False ; Alert(symbol,"  ", tChartPeriod, " Price below Lower Volty "+ DoubleToStr(DnBuffer[0] ,digits)); }     

      }

   if(Show.PriceBox) { DoBox() ; }
    
   OldBars = Bars ;   

//+--------- TRO MODIFICATION ---------------------------------------+       
//----
   return(0);
  }
//+------------------------------------------------------------------+


//+--------- TRO MODIFICATION ---------------------------------------+  
void DoBox()    
{


       if (ObjectFind(tShortName+"01") != 0)
      {
          ObjectCreate(tShortName+"01",OBJ_ARROW,0,Time[0],UpBuffer[0]);
          ObjectSet(tShortName+"01",OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
          ObjectSet(tShortName+"01",OBJPROP_COLOR,indicator_color1);  
          ObjectSet(tShortName+"01",OBJPROP_WIDTH,myBoxWidth);  
      } 
      else
      {
         ObjectMove(tShortName+"01",0,Time[0],UpBuffer[0]);
         ObjectSet(tShortName+"01",OBJPROP_COLOR,indicator_color1);  
      }

       if (ObjectFind(tShortName+"02") != 0)
      {
          ObjectCreate(tShortName+"02",OBJ_ARROW,0,Time[0],DnBuffer[0]);
          ObjectSet(tShortName+"02",OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
          ObjectSet(tShortName+"02",OBJPROP_COLOR,indicator_color2);  
          ObjectSet(tShortName+"02",OBJPROP_WIDTH,myBoxWidth);  
      } 
      else
      {
         ObjectMove(tShortName+"02",0,Time[0],DnBuffer[0]);
         ObjectSet(tShortName+"02",OBJPROP_COLOR,indicator_color2);  
      }

 

                
   return(0);
}


//+--------- TRO MODIFICATION ---------------------------------------+  

string TimeFrameToString(int tf)
{
   string tfs;
   switch(tf) {
      case PERIOD_M1:  tfs="M1"  ; break;
      case PERIOD_M5:  tfs="M5"  ; break;
      case PERIOD_M15: tfs="M15" ; break;
      case PERIOD_M30: tfs="M30" ; break;
      case PERIOD_H1:  tfs="H1"  ; break;
      case PERIOD_H4:  tfs="H4"  ; break;
      case PERIOD_D1:  tfs="D1"  ; break;
      case PERIOD_W1:  tfs="W1"  ; break;
      case PERIOD_MN1: tfs="MN";
   }
   return(tfs);
}



//+--------- TRO MODIFICATION ---------------------------------------+  