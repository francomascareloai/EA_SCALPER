//+------------------------------------------------------------------+
//|                                                    CCI-Alert.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://ForexBaron.net"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 DodgerBlue
#property indicator_color2 LightGray
#property indicator_color3 LightGray
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_DOT
//---- input parameters
extern int CCIPeriode=200;
extern int ApplyTo=0;

bool AlertMode=true;
extern int OverBought=100;
extern int OverSold=-100;

extern string ahi="******* ALERT SETTINGS:";
extern int    AlertCandle            = 0;//0:current, 1:last bar, etc.
extern bool   PopupAlerts            = true;
extern bool   EmailAlerts            = false;
extern bool   PushNotificationAlerts = false;
extern bool   SoundAlerts            = false;
extern string SoundFileLong          = "alert.wav";
extern string SoundFileShort         = "alert2.wav";
int lastAlert=3;

//---- buffers
double CCIBuffer[];
double CCIOBBuffer[];
double CCIOSBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator lines
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,CCIBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,CCIOBBuffer);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,CCIOSBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="CCI-Alert("+CCIPeriode+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,"OverBought");
   SetIndexLabel(2,"OverSold");
//----
   SetIndexDrawBegin(0,CCIPeriode);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Commodity Channel Index                                          |
//+------------------------------------------------------------------+
int start()
  {
   int    i,counted_bars=IndicatorCounted();
//----
   if(Bars<=CCIPeriode) return(0);
//----
   i=Bars-CCIPeriode-1;
   if(counted_bars>=CCIPeriode) i=Bars-counted_bars-1;
   while(i>=0)
   {
      CCIBuffer[i]=iCCI(NULL,0,CCIPeriode,ApplyTo,i);
      CCIOBBuffer[i]=OverBought;
      CCIOSBuffer[i]=OverSold;
      i--;
   }
   
   if(AlertMode)
   {
      if(lastAlert!=2 && CCIBuffer[AlertCandle+1]<OverBought && CCIBuffer[AlertCandle]>=OverBought)
         {lastAlert=2; doAlerts("CCI overbought @ level "+OverBought,SoundFileShort); }//Alert("CCI = "+ CCIBuffer[i]+ ", Sell.");
      else if(lastAlert!=1 && CCIBuffer[AlertCandle+1]>OverSold && CCIBuffer[AlertCandle]<=OverSold)
         {lastAlert=1; doAlerts("CCI oversold @ level "+OverSold,SoundFileLong); }//Alert("CCI = "+ CCIBuffer[i]+ ", Buy.");
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+

void doAlerts(string msg,string SoundFile) {
        msg="CCI Alert on "+Symbol()+", period "+TFtoStr(Period())+": "+msg;
 string emailsubject="MT4 alert on acc. "+AccountNumber()+", "+WindowExpertName()+" - Alert on "+Symbol()+", period "+TFtoStr(Period());
  if (PopupAlerts) Alert(msg);
  if (EmailAlerts) SendMail(emailsubject,msg);
  if (PushNotificationAlerts) SendNotification(msg);
  if (SoundAlerts) PlaySound(SoundFile);

}//void doAlerts(string msg,string SoundFile) {

string TFtoStr(int period) {
 switch(period) {
  case 1     : return("M1");  break;
  case 5     : return("M5");  break;
  case 15    : return("M15"); break;
  case 30    : return("M30"); break;
  case 60    : return("H1");  break;
  case 240   : return("H4");  break;
  case 1440  : return("D1");  break;
  case 10080 : return("W1");  break;
  case 43200 : return("MN1"); break;
  default    : return(DoubleToStr(period,0));
 }
 return("UNKNOWN");
}//string TFtoStr(int period) {