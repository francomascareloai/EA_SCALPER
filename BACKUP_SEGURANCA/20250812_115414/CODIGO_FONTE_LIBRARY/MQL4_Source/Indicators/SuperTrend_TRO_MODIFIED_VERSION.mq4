//+------------------------------------------------------------------+
//|                                                   SuperTrend.mq4 |
//|                   Copyright © 2008, Jason Robinson (jnrtrading). |
//|                                   http://www.spreadtrade2win.com |
//+------------------------------------------------------------------+
//| SuperTrend_TRO_MODIFIED_VERSION                                  |
//| MODIFIED BY AVERY T. HORTON, JR. AKA THERUMPLEDONE@GMAIL.COM     |
//| I am NOT the ORIGINAL author 
//  and I am not claiming authorship of this indicator. 
//  All I did was modify it. I hope you find my modifications useful.|
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2008, Jason Robinson."
#property link      "http://www.spreadtrade2win.com"

#property indicator_chart_window
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2
#property indicator_buffers 2



//+--------- TRO MODIFICATION ---------------------------------------+ 

extern bool   Sound.Alert    = false ;
extern bool   Show.PriceBox  = true ;
extern int    myBoxWidth     = 3;


extern int Nbr_Periods = 10;
extern double Multiplier = 3.0;



double TrendUp[], TrendDown[];
int changeOfTrend;

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
    
  
  
//---- indicators
   SetIndexBuffer(0, TrendUp);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexLabel(0, "Trend Up");
   SetIndexBuffer(1, TrendDown);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexLabel(1, "Trend Down");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//+--------- TRO MODIFICATION ---------------------------------------+ 
   ObjectDelete(tShortName+"01"); 
   ObjectDelete(tShortName+"02");    
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//+--------- TRO MODIFICATION ---------------------------------------+   
   if( Bars != OldBars ) { Trigger = True ; }
  
   int limit, i, flag, flagh, trend[5000];
   double up[5000], dn[5000], medianPrice, atr;
   int counted_bars = IndicatorCounted();
//---- check for possible errors
   if(counted_bars < 0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars > 0) counted_bars--;
   limit=Bars-counted_bars;
   //Print(limit);
   
//----
   for (i = limit; i >= 0; i--) {
      atr = iATR(NULL, 0, Nbr_Periods, i);
      //Print("atr: "+atr[i]);
      medianPrice = (High[i]+Low[i])/2;
      //Print("medianPrice: "+medianPrice[i]);
      up[i]=medianPrice+(Multiplier*atr);
      //Print("up: "+up[i]);
      dn[i]=medianPrice-(Multiplier*atr);
      //Print("dn: "+dn[i]);
      trend[i]=1;
   
      
      if (Close[i]>up[i+1]) {
         trend[i]=1;
         if (trend[i+1] == -1) changeOfTrend = 1;
         //Print("trend: "+trend[i]);
         
      }
      else if (Close[i]<dn[i+1]) {
         trend[i]=-1;
         if (trend[i+1] == 1) changeOfTrend = 1;
         //Print("trend: "+trend[i]);
      }
      else if (trend[i+1]==1) {
         trend[i]=1;
         changeOfTrend = 0;       
      }
      else if (trend[i+1]==-1) {
         trend[i]=-1;
         changeOfTrend = 0;
      }

      if (trend[i]<0 && trend[i+1]>0) {
         flag=1;
         //Print("flag: "+flag);
      }
      else {
         flag=0;
         //Print("flagh: "+flag);
      }
      
      if (trend[i]>0 && trend[i+1]<0) {
         flagh=1;
         //Print("flagh: "+flagh);
      }
      else {
         flagh=0;
         //Print("flagh: "+flagh);
      }
      
      if (trend[i]>0 && dn[i]<dn[i+1])
         dn[i]=dn[i+1];
      
      if (trend[i]<0 && up[i]>up[i+1])
         up[i]=up[i+1];
      
      if (flag==1)
         up[i]=medianPrice+(Multiplier*atr);
         
      if (flagh==1)
         dn[i]=medianPrice-(Multiplier*atr);
         
      //-- Draw the indicator
      if (trend[i]==1) {
         TrendUp[i]=dn[i];
         if (changeOfTrend == 1) {
            TrendUp[i+1] = TrendDown[i+1];
            changeOfTrend = 0;
         }
      }
      else if (trend[i]==-1) {
         TrendDown[i]=up[i];
         if (changeOfTrend == 1) {
            TrendDown[i+1] = TrendUp[i+1];
            changeOfTrend = 0;
         }
      }
   }
   
//+--------- TRO MODIFICATION ---------------------------------------+  
      
      if ( Trigger &&  Sound.Alert ) 
      {
        if( Close[0] > TrendUp[0] )   { Trigger = False ; Alert(symbol,"  ", tChartPeriod, " Price above Upper Trend "+ DoubleToStr(TrendUp[0]   ,digits)); }
        if( Close[0] < TrendDown[0] ) { Trigger = False ; Alert(symbol,"  ", tChartPeriod, " Price below Lower Trend "+ DoubleToStr(TrendDown[0] ,digits)); }     
        if( changeOfTrend == 1      ) { Trigger = False ; Alert(symbol,"  ", tChartPeriod, " Trend Changed " + changeOfTrend ); }     


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
          ObjectCreate(tShortName+"01",OBJ_ARROW,0,Time[0],TrendUp[0]);
          ObjectSet(tShortName+"01",OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
          ObjectSet(tShortName+"01",OBJPROP_COLOR,indicator_color1);  
          ObjectSet(tShortName+"01",OBJPROP_WIDTH,myBoxWidth);  
      } 
      else
      {
         ObjectMove(tShortName+"01",0,Time[0],TrendUp[0]);
         ObjectSet(tShortName+"01",OBJPROP_COLOR,indicator_color1);  
      }

       if (ObjectFind(tShortName+"02") != 0)
      {
          ObjectCreate(tShortName+"02",OBJ_ARROW,0,Time[0],TrendDown[0]);
          ObjectSet(tShortName+"02",OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
          ObjectSet(tShortName+"02",OBJPROP_COLOR,indicator_color2);  
          ObjectSet(tShortName+"02",OBJPROP_WIDTH,myBoxWidth);  
      } 
      else
      {
         ObjectMove(tShortName+"02",0,Time[0],TrendDown[0]);
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