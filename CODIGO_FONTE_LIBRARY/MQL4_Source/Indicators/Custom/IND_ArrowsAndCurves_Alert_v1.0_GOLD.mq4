//+------------------------------------------------------------------+
//|                      lukas1 arrows & curves.mq4       v.14       |
//|       Изменения:                                                 | 
//|       1. Убраны ненужные (лишние) коэффициены, не участвующие    |
//|          в расчетах Kmin, Kmax, RISK                             |
//|       2. Математика индикатора все расчеты выполняет             |
//|          внутри одного цикла, это увеличило скорость обсчёта.    |
//|       3. Выключено мерцание стрелок.                             |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, lukas1"
#property link      "http://www.alpari-idc.ru/"
//----
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Green
//---- input parameters
extern int SSP       = 6;     //период линейного разворота индикатора
extern int CountBars = 2250;  //расчетный период 
extern int SkyCh     = 13;    //чувствительность к пробою канала 
extern bool      Alert_Popup=true;          // Popup window & sound on alert
extern bool      Alert_Email=true;         // Send email on alert
int    i;
double high, low, smin, smax;
double val1[];      // буфер для бай
double val2[];      // буфер для селл
double Sky_BufferH[];
double Sky_BufferL[];
bool   uptrend, old;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 233);        // стрелка для бай
   SetIndexBuffer(0, val1);      // индекс буфера для бай
   SetIndexDrawBegin(0, 2*SSP);
   //
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 234);        // стрелка для селл
   SetIndexBuffer(1, val2);      // индекс буфера для селл
   SetIndexDrawBegin(1, 2*SSP);
   //
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Sky_BufferH);
   SetIndexLabel(2, "High");
   SetIndexDrawBegin(2, 2*SSP);
   //
   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, Sky_BufferL);
   SetIndexLabel(3, "Low");
   SetIndexDrawBegin(3, 2*SSP);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Calculation of SilverTrend lines                                 | 
//+------------------------------------------------------------------+
int start()
  {   
   int counted_bars = IndicatorCounted();
//---- последний посчитанный бар будет пересчитан
   if(counted_bars > 0) counted_bars--;
//----
   if(Bars <= SSP + 1)        return(0);
//---- initial zero
   uptrend       =false;
   old           =false;
   GlobalVariableSet("goSELL", 0); // задали существование и обнулили goSELL=0
   GlobalVariableSet("goBUY", 0);  // задали существование и обнулили goBUY =0
   string sAlertMsg;
   
static datetime prevtime=0;
 
 if(prevtime == Time[0]) {
	return(0);
 }
	prevtime = Time[0];

   
   
//----
   for(i = CountBars - SSP; i >= 0; i--) // уменьш значение shift на 1 за проход;
     { 
       high = High[iHighest(Symbol(),0,MODE_HIGH,SSP,i)]; 
       low = Low[iLowest(Symbol(),0,MODE_LOW,SSP,i)]; 
       smax = high - (high - low)*SkyCh / 100; // smax ниже high с учетом коэфф.SkyCh
       smin = low + (high - low)*SkyCh / 100;  // smin выше low с учетом коэфф.SkyCh
	    val1[i] = 0;  
       val2[i] = 0;

if(Close[i] < smin && i!=0 ){
       
       uptrend = false;
       }
if(Close[i] > smax && i!=0 ){
	    
	    uptrend = true;       
       }       

if(uptrend != old && uptrend == false){
           val2[i] = high;
            if(i == 0){
          GlobalVariableSet("goBUY",1);
         }
         }

if(uptrend != old && uptrend == true ){
     val1[i] = low;
           if(i == 0){
           GlobalVariableSet("goSELL",1);
          }
}

old=uptrend;
       Sky_BufferH[i]=high - (high - low)*SkyCh / 100;
       Sky_BufferL[i]=low +  (high - low)*SkyCh / 100;
       
       
       
//Alerts an Email    
if(val1[1] > 0 && i==0){
          sAlertMsg="ArrowsandCurves Alert - "+Symbol()+" "+TF2Str(Period())+": Signal Up";
          if (Alert_Popup) Alert(sAlertMsg);      
          if (Alert_Email) SendMail( sAlertMsg, "MT4 Alert!\n" + TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS )+"\n"+sAlertMsg);
}
if(val2[1] > 0 && i==0){
          sAlertMsg="ArrowsandCurves Alert - "+Symbol()+" "+TF2Str(Period())+": Signal Down";
          if (Alert_Popup) Alert(sAlertMsg);      
          if (Alert_Email) SendMail( sAlertMsg, "MT4 Alert!\n" + TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS )+"\n"+sAlertMsg);
}
//

     }//for
   return(0);
  }
  //-----------------------------------------------------------------------------
// function: TF2Str()
// Description: Convert time-frame to a string
//-----------------------------------------------------------------------------
string TF2Str(int iPeriod) {
  switch(iPeriod) {
    case PERIOD_M1: return("M1");
    case PERIOD_M5: return("M5");
    case PERIOD_M15: return("M15");
    case PERIOD_M30: return("M30");
    case PERIOD_H1: return("H1");
    case PERIOD_H4: return("H4");
    case PERIOD_D1: return("D1");
    case PERIOD_W1: return("W1");
    case PERIOD_MN1: return("MN1");
    default: return("M"+iPeriod);
  }
}


//+------------------------------------------------------------------+