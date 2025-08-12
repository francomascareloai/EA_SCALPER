//+--------------------------------------------------------------------------------------------+
//|                                                                   Elder_Impulse_System.mq4 |
//| Copyright © 2007, http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/ |
//|                   http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/ |
//+--------------------------------------------------------------------------------------------+
#property copyright ""
#property link      ""
// I used code from Macd_Correct by David W. Thomas and eSignal code supplied by bentleybrian <bentleybrian@yahoo.com>
// to build this indicator . Built by transport_david .
#property indicator_separate_window
//----
#property indicator_minimum 0
#property indicator_maximum 1
#property indicator_buffers 3
#property indicator_color1 Lime
#property indicator_color2 Blue
#property indicator_color3 Red
//----
extern int ShowBars=5000;
//---- buffers
double Impulse_Up[];
double Neutral[];
double Impulse_Down[];
double MACDLineBuffer[];
double SignalLineBuffer[];
double HistogramBuffer[];
//---- variables
double alpha=0;
double alpha_1=0;
/*
var myStudy1=null;
var myStudy2=null;
var myStudy3=null;

function preMain() 
  {
   setStudyTitle("Impulse Indicator");
   setCursorLabelName("Impulse", 0);
   setCursorLabelName("MACDHist",1);
   setPriceStudy(true); 
  }

function main() 
  {

   var myStudy1 = ema(13);
   var myStudy2 = new macdHist(12,26,9);
   var myStudy3 = ema(13);
   //Impulse Up
   if ((myStudy1.getValue(0) > myStudy1.getValue(-1)) &&
(myStudy2.getValue(0) > myStudy2.getValue(-1))) 
   {
       setPriceBarColor(Color.green);
   }
   //Impulse Down
   else if ((myStudy1.getValue(0) < myStudy1.getValue(-1)) &&
(myStudy2.getValue(0) < myStudy2.getValue(-1)) ) 
   {
       setPriceBarColor(Color.red);
   }
   //Neutral
   else 
   {
       setPriceBarColor(Color.blue);
   }
*/
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(6);
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,4);
   SetIndexEmptyValue(0,0.0);
   SetIndexBuffer(0,Impulse_Up);
   //
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,4);
   SetIndexEmptyValue(1,0.0);
   SetIndexBuffer(1,Neutral);
   //
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,4);
   SetIndexEmptyValue(2,0.0);
   SetIndexBuffer(2,Impulse_Down);
   //
   SetIndexEmptyValue(3,0.0);
   SetIndexBuffer(3,MACDLineBuffer);
   SetIndexEmptyValue(4,0.0);
   SetIndexBuffer(4,SignalLineBuffer);
   SetIndexEmptyValue(5,0.0);
   SetIndexBuffer(5,HistogramBuffer);
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
   alpha=2.0/(9 + 1.0);
   alpha_1=1.0 - alpha;
//----
   int shift=ShowBars;
   if (ShowBars > Bars) ShowBars=Bars;
   for( shift=ShowBars; shift>=0; shift-- )
     {
      double myStudy1_value0=iMA(Symbol(),0,13,0,MODE_EMA,PRICE_CLOSE,shift);
      double myStudy1_value1=iMA(Symbol(),0,13,0,MODE_EMA,PRICE_CLOSE,shift+1);
//----
      MACDLineBuffer[shift]  =(iMA(Symbol(),0,12,0,MODE_EMA,PRICE_CLOSE,shift) - iMA(Symbol(),0,26,0,MODE_EMA,PRICE_CLOSE,shift));
      SignalLineBuffer[shift]=(alpha*MACDLineBuffer[shift]) + (alpha_1*SignalLineBuffer[shift+1]);
//----
      double myStudy2_value0=MACDLineBuffer[shift] - SignalLineBuffer[shift];
      double myStudy2_value1=MACDLineBuffer[shift+1] - SignalLineBuffer[shift+1];
//----
      if((myStudy1_value0 > myStudy1_value1) && (myStudy2_value0 > myStudy2_value1)){ Impulse_Up[shift]=1; } else { Impulse_Up[shift]=0.0; }
      if((myStudy1_value0 < myStudy1_value1) && (myStudy2_value0 < myStudy2_value1)){ Impulse_Down[shift]=1; } else { Impulse_Down[shift]=0.0; }
      if((Impulse_Up[shift]==0.0) && (Impulse_Down[shift]==0.0)){ Neutral[shift]=1; } else { Neutral[shift]=0.0; }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+