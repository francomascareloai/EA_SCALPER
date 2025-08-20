
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrLime
#property indicator_color2 clrRed

enum onoff {
   NO = 0,
   YES = 1 
};
enum signaltype {
   IntraBar = 0,   // Intrabar
   ClosedCandle = 1       // On new bar
};

// Inputs Parameters            
extern string s0 = "===== SIGNAL SETTINGS ============="; // ======================
extern string IndicatorName = "StochHistogram"; // Indicator File Name
extern int IndiBufferCall = 0;      // Signal Buffer Up ("Call") 
extern int IndiBufferPut = 1;       // Signal Buffer Down ("Put") 

extern string s1 = "===== SIGNAL SETTINGS ============="; // ======================
extern string IndicatorName2 = "Advanced ADX - 2 alerts";
extern int IndiBufferCall2 = 0;      // Signal Buffer Up ("Call") 
extern int IndiBufferPut2 = 1;       // Signal Buffer Down ("Put") 

 
extern string s2 = "===== SIGNAL SETTINGS ============="; // ======================
extern string IndicatorName3 = "Awesome";
extern int IndiBufferCall3 = 1;      // Signal Buffer Up ("Call") 
extern int IndiBufferPut3 = 2;       // Signal Buffer Down ("Put") 


extern int CountedBars=300;
extern bool   UseAlert   = false;

     
// Variables          
string infolabel_name;
string chkenable;
bool infolabel_created;
int lbnum = 0;
bool initgui = false;

datetime sendOnce;   // Candle time stampe of signal for preventing duplicated signals on one candle
string asset;        // Symbol name (e.g. EURUSD)
string signalID;     // Signal ID (unique ID)
bool alerted = false;
int ForegroundColor;
bool active = true;
double ArrowUPbuff[];
double ArrowDNbuff[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int OnInit()
{     
   
   IndicatorBuffers(2);
   IndicatorShortName("Veritech");
   SetIndexStyle (0,DRAW_ARROW,0,1);
   SetIndexArrow (0,233);
   SetIndexBuffer(0,ArrowUPbuff);
   SetIndexStyle (1,DRAW_ARROW,0,1);
   SetIndexArrow (1,234);
   SetIndexBuffer(1,ArrowDNbuff);
   
   ForegroundColor = ChartGetInteger(0, CHART_COLOR_FOREGROUND);
   ChartSetInteger(0,CHART_COLOR_BACKGROUND,clrBlack);
   ChartSetInteger(0,CHART_COLOR_CHART_UP,clrLime);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrRed);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrLime);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrRed);
   
   // Initialize the time flag
   sendOnce = TimeCurrent();
   
   //Comment("Symbol name: ",Symbol());
   //EventSetTimer(1);
   return(INIT_SUCCEEDED);
}

  
void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectDelete(0, infolabel_name); 
   ObjectDelete(0, chkenable); 
}
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
/*/+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---*/ 
int start(){
   if(!active || alerted) return(0);//return(rates_total);
   double up = 0, dn = 0;
   double up2 = 0, dn2 = 0;
   double up3 = 0, dn3 = 0;

   
   //int limit = rates_total-prev_calculated;
   
   int limit,i,counter;
   double Range,AvgRange;
   
   
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+CountedBars;
   
   if(limit>CountedBars) limit = CountedBars;
   
   ResetLastError();
   for(i=limit;i>=0;i--){
      if (IndicatorName != "" && IndicatorName2 != "" && IndicatorName3 != "" && !alerted) {
         up = iCustom(NULL, 0, IndicatorName, IndiBufferCall, i);
         dn = iCustom(NULL, 0, IndicatorName, IndiBufferPut, i);
         if (GetLastError() == 4072){ Alert("Error: '" + IndicatorName+"' indicator is not found!");alerted=true; }
         up2 = iCustom(NULL, 0, IndicatorName2, IndiBufferCall2, i);
         dn2 = iCustom(NULL, 0, IndicatorName2, IndiBufferPut2, i);
         if (GetLastError() == 4072){ Alert("Error: '" + IndicatorName2+"' indicator is not found!");alerted=true; }
         up3 = iCustom(NULL, 0, IndicatorName3, IndiBufferCall3, i);
         dn3 = iCustom(NULL, 0, IndicatorName3, IndiBufferPut3, i);
         if (GetLastError() == 4072){ Alert("Error: '" + IndicatorName3+"' indicator is not found!");alerted=true; }


         
         
         
         
         
      }else {
         if (!alerted) {
            Alert ("Attention: Indicator is not defined."); 
            alerted = false;
         }
      }
      if(alerted) return(1);//rates_total);
      counter=i;
      Range=0;
      AvgRange=0;
      for(counter=i;counter<=i+9;counter++){
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=(AvgRange/10)*1.6;
      
      double gap = 0.02;
      // if signal UP (CALL)
      if (signal(up) && signal(up2)&& signal(up3)) {
         ArrowUPbuff[i] = Low[i]-Range;
         if( UseAlert && i == 0  )
         {
            Alert(Symbol(),"  M",Period()," Posible Compra");
            
         }
   
      }
      // if signal DOWN (PUT)
      if (signal(dn) && signal(dn2)&& signal(dn3)) {
         ArrowDNbuff[i] = High[i]+Range;
         if( UseAlert && i == 0  )
         {
            Alert(Symbol(),"  M",Period()," Posible Venta");
            
         }
        
      }
   }
   //--- return value of prev_calculated for next call
   return(1);//(rates_total);
}
//+------------------------------------------------------------------+


// Function: check indicators signal buffer value 
bool signal (double value) 
{
   if (value != 0 && value != EMPTY_VALUE) return true;
   else return false;
} 



// Function: create info label on the chart
void OnTimer() {
   if (!initgui) {
      ObjectsDeleteAll(0,"Obj_*");      
      initgui = true;
   }
}

void OnChartEvent(const int id,         // Event ID 
                  const long& lparam,   // Parameter of type long event 
                  const double& dparam, // Parameter of type double event 
                  const string& sparam  // Parameter of type string events 
                  ) 
{
//------
//------
}