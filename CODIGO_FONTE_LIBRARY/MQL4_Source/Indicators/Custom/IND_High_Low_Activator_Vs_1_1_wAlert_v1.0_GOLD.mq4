//+------------------------------------------------------------------+
//|                                           High-Low Activator.mq4 |
//|                                       Copyright 2012, Peperlizio |
//|                                                            v:1.1 |
//+------------------------------------------------------------------+
//modified 6 aug 2020
// - alert, more tf string options
#property copyright "Copyright 2012, Peperlizio"
#property link      ""

#property indicator_buffers   1
#property indicator_color1    Gold
#property indicator_width1    2
#property indicator_style1    STYLE_SOLID
#property indicator_chart_window

//----Extern Variables
extern int    MAPeriod   = 3;
extern string __________ = "0:Simple, 1:Exponential, 2:Smoothed, 3:Linear";
extern int    MAMethod   = 0;
extern string _________  = "M0:Current TF - M1 - M5 - M15 - M30 - H1 - H4 - D1 - W1 - MN1";
extern string TimeFrame  = "M0";
extern bool alert_pop=false;               //Alert - popup
extern bool alert_push=false;              //Alert - push
extern bool alert_email=false;             //Alert - email
//----Buffers
double MA[];

//----Global Variables
int      TF;
bool     Flag;
double   MABef;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {   
   SetIndexBuffer(0, MA);
   Flag     = false;
   MABef    = 0;
   
   if (TimeFrame == "M0"  || TimeFrame == "m0" || TimeFrame == "0") {TF = Period();   Flag = true;}
   if (TimeFrame == "M1"  || TimeFrame == "m1" || TimeFrame == "1") {TF = PERIOD_M1;  Flag = true;}
   if (TimeFrame == "M5"  || TimeFrame == "m5" || TimeFrame == "5") {TF = PERIOD_M5;  Flag = true;}
   if (TimeFrame == "M15" || TimeFrame == "m15"|| TimeFrame == "15") {TF = PERIOD_M15; Flag = true;}
   if (TimeFrame == "M30" || TimeFrame == "m30"|| TimeFrame == "30") {TF = PERIOD_M30; Flag = true;}
   if (TimeFrame == "H1"  || TimeFrame == "h1" || TimeFrame == "60") {TF = PERIOD_H1;  Flag = true;}
   if (TimeFrame == "H4"  || TimeFrame == "h4" || TimeFrame == "240") {TF = PERIOD_H4;  Flag = true;}
   if (TimeFrame == "D1"  || TimeFrame == "d1" || TimeFrame == "1440") {TF = PERIOD_D1;  Flag = true;}
   if (TimeFrame == "W1"  || TimeFrame == "w1" || TimeFrame == "10080") {TF = PERIOD_W1;  Flag = true;}
   if (TimeFrame == "MN1" || TimeFrame == "mn1"|| TimeFrame == "43200") {TF = PERIOD_MN1; Flag = true;}
   
   if (!Flag) Alert("Timeframe non riconosciuto.");
   
   return(0);
  }
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int Limit, i;                                                            
   
   int counted_bars = IndicatorCounted(); 
   if (counted_bars > 0) counted_bars--;
   Limit = Bars - MAPeriod - counted_bars;
   
   if (TF < Period() || !Flag) return(0);
   
   for (i=Limit; i>0; i--) {Calc(i);} 
   
   if (IsNewBar())
    {
     if (TF!=Period()) {for (i=TF/Period()-1; i>=0; i--) Calc(i);}
     if (TF==Period()) Calc(1);
    }
    
   Calc(0);
   
   return(0);
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| Functions                                                        |
//+------------------------------------------------------------------+

//----Calc
void Calc (int Shift)
 {
  int c;                                                 // c --> "i" higher Timeframe Counterpart
  double OpeN, ClosE, MALow, MAHigh;
  
  if (Shift == 0) {MA[Shift] = MA[Shift+1]; return(0);}
  
  c = iBarShift(NULL,TF,iTime(NULL,0,Shift),false);
  if (TF!=Period() && c==0) c = 1;
     
  OpeN   = iOpen (NULL,TF,c); 
  ClosE  = iClose(NULL,TF,c);
  MALow  = iMA   (NULL,TF,MAPeriod,0,MAMethod,3,c);
  MAHigh = iMA   (NULL,TF,MAPeriod,0,MAMethod,2,c);
     
  if (ClosE > MA[Shift+1]) MA[Shift] = MALow;  
  if (ClosE < MA[Shift+1]) MA[Shift] = MAHigh; 
  if (ClosE == MA[Shift+1] && OpeN > ClosE)  MA[Shift] = MALow;
  if (ClosE == MA[Shift+1] && OpeN < ClosE)  MA[Shift] = MAHigh;
  if (ClosE == MA[Shift+1] && OpeN == ClosE) MA[Shift] = MA[Shift+1];
  
  static bool which;
  if(IndicatorCounted()==0){which=0;}
  if(Close[1]>=MA[Shift+1]&&Close[2]<MA[Shift+2]&&IndicatorCounted()>0&&!which){which=true;alert("HIGH");}
  if(Close[1]< MA[Shift+1]&&Close[2]>MA[Shift+2]&&IndicatorCounted()>0&&which){which=false;alert("LOW");}
  //----X Debug
  /*
  datetime TimE = iTime(NULL,0,i);
  if (TimeToStr(TimE) == "2012.08.31 19:42") Alert(c);  
  */
   
  return(0);
 }
//+------------------------------------------------------------------+
void alert(string which)
{
   string alert_msg = Symbol()+"-"+IntegerToString(Period())+", "+which+" broken! @"+TimeToString(Time[1],TIME_DATE)+" "+TimeToString(Time[1],TIME_SECONDS);
   if(alert_pop){Alert(alert_msg);}
   if(alert_push){SendNotification(alert_msg);}
   if(alert_email){SendMail(alert_msg,alert_msg);}
}
 
//----IsNewBar
bool IsNewBar() 
 {
  datetime PrevTime = 0; 
  if (PrevTime==iTime(NULL,TF,0)) return(false);
  PrevTime=iTime(NULL,TF,0);
  return(true);
 }
//+------------------------------------------------------------------+ 