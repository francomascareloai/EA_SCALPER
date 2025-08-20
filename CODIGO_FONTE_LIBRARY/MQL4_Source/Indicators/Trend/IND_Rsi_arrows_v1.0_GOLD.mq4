//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-tsd.com"
#property description "modif. by Mobidik"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6

#property indicator_color1 DeepSkyBlue
#property indicator_color2 DarkGray
#property indicator_color3 Orange
#property indicator_color4 LimeGreen
#property indicator_color5 Lime
#property indicator_color6 Magenta

#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_DOT
#property indicator_style4 STYLE_DOT

extern int    RsiLength     = 2;
extern int    RsiPrice      = PRICE_CLOSE;
extern int    HalfLength    = 2;
extern int    DevPeriod     = 100;
extern double Deviations    = 1.2;

extern bool   NoDellArr     = true;
extern int    Arr_otstup    = 0;
extern int    Arr_width     = 1;
extern color  Arr_Up        = DodgerBlue;
extern color  Arr_Dn        = Gold;
extern bool   AlertsMessage = true;
extern bool   AlertsSound   = false;
extern bool   AlertsEmail   = false;
extern bool   AlertsMobile  = false;
extern int    SignalBar     = 0;
extern bool   ShowArrBuf    = true;
extern int    History       = 3000;

int TimeBar;
#define PREFIX "vs1"

double RS[];
double ChMid[];
double ChUp[];
double ChDn[];
double SigUp[];
double SigDn[];
//------------------------------------------------------------------
int init()
{
   HalfLength=MathMax(HalfLength,1);
   
         SetIndexBuffer(0,RS); 
         SetIndexBuffer(1,ChMid);
         SetIndexBuffer(2,ChUp); 
         SetIndexBuffer(3,ChDn);
         SetIndexBuffer(4,SigUp);
         SetIndexArrow (4,233);
         SetIndexBuffer(5,SigDn);
         SetIndexArrow (5,234);
         
      if(ShowArrBuf)
       {
         SetIndexStyle (5,DRAW_ARROW); 
         SetIndexStyle (4,DRAW_ARROW);
       }else{
         SetIndexStyle (5,DRAW_NONE);
         SetIndexStyle (6,DRAW_NONE);
       }
         SetIndexLabel (0,"RSI");
         SetIndexLabel (1,"ChMid");
         SetIndexLabel (2,"ChUp");
         SetIndexLabel (3,"ChDn");
         SetIndexLabel (4,"SigUp");
         SetIndexLabel (5,"SigDn");
         
   return(0);
}
//------------------------------------------------------------------
int deinit() 
{ 
   for (int i = ObjectsTotal()-1; i >= 0; i--)   
   if (StringSubstr(ObjectName(i), 0, StringLen(PREFIX)) == PREFIX)
       ObjectDelete(ObjectName(i));
  return(0); 
}
//------------------------------------------------------------------
int start()
{
   int i,j,k,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
      int limit=MathMin(History,Bars-counted_bars+HalfLength);

   for (i=limit; i>=0; i--) RS[i] = iRSI(NULL,0,RsiLength,RsiPrice,i);
   for (i=limit; i>=0; i--)
   {
      double dev  = iStdDevOnArray(RS,0,DevPeriod,0,MODE_SMA,i);
      double sum  = (HalfLength+1)*RS[i];
      double sumw = (HalfLength+1);
      for(j=1, k=HalfLength; j<=HalfLength; j++, k--)
      {
         sum  += k*RS[i+j];
         sumw += k;
         if (j<=i)
         {
            sum  += k*RS[i-j];
            sumw += k;
         }
      }
      ChMid[i] = sum/sumw;
      ChUp[i] = ChMid[i]+dev*Deviations;
      ChDn[i] = ChMid[i]-dev*Deviations;
  }    
//-----------------------------------------------------------------------+ 
 for (i = limit; i >= 0; i--)
  {   
  if(RS[i]<ChDn[i] && RS[i+1]>ChDn[i+1])
   { 
     SigUp[i] = RS[i]-10;
     arrows_wind(i,"RSI TMA Up",Arr_otstup ,233,Arr_Up,Arr_width,false);
   }else{
     if(!NoDellArr)
      {
        SigUp[i] = EMPTY_VALUE;
        ObjectDelete(PREFIX+"RSI TMA Up"+TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
      }  
   }
   
  if(RS[i]>ChUp[i] && RS[i+1]<ChUp[i+1]) 
   {
     SigDn[i] = RS[i]+10;
     arrows_wind(i,"RSI TMA Dn",Arr_otstup ,234,Arr_Dn,Arr_width,true);
   }else{
     if(!NoDellArr)
      {
        SigDn[i] = EMPTY_VALUE;
        ObjectDelete(PREFIX + "RSI TMA Dn" + TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
      }  
   }  
//-----------------------------------------------------------------------+
 if(AlertsMessage || AlertsEmail || AlertsMobile || AlertsSound)
  { 
   string message1 = ("RSI TMA  - "+Symbol()+" TF("+Period()+") - Signal for BUY"); 
   string message2 = ("RSI TMA  - "+Symbol()+" TF("+Period()+") - Signal for SELL");
       
    if(TimeBar!=Time[0] && RS[SignalBar]<ChDn[SignalBar] && RS[SignalBar+1]>ChDn[SignalBar+1])
     { 
        if (AlertsMessage) Alert(message1);
        if (AlertsEmail)   SendMail(Symbol()+" RSI TMA  ",message1);
        if (AlertsMobile)  SendNotification(message1);
        if (AlertsSound)   PlaySound("alert2.wav");
        TimeBar=Time[0];
     }
    if(TimeBar!=Time[0] && RS[SignalBar]>ChUp[SignalBar] && RS[SignalBar+1]<ChUp[SignalBar+1])
     { 
        if (AlertsMessage) Alert(message2);
        if (AlertsEmail)   SendMail(Symbol()+" RSI TMA  ",message2);
        if (AlertsMobile)  SendNotification(message2);
        if (AlertsSound)   PlaySound("alert2.wav");
        TimeBar=Time[0];
    }
   }
  }
//-----------------------------------------------------------------------+
   return(0);
}
//-----------------------------------------------------------------------+
void arrows_wind(int k, string N,int ots,int Code,color clr, int ArrowSize,bool up)                 
{           
   string objName = PREFIX+N+TimeToStr(Time[k],TIME_DATE|TIME_SECONDS); 
   double gap  = ots*Point;
   
   ObjectCreate(objName, OBJ_ARROW,0,Time[k],0);
   ObjectSet   (objName, OBJPROP_COLOR, clr);  
   ObjectSet   (objName, OBJPROP_ARROWCODE,Code);
   ObjectSet   (objName, OBJPROP_WIDTH,ArrowSize);  
  if (up)
      ObjectSet(objName,OBJPROP_PRICE1,High[k]+gap);
     else  
      ObjectSet(objName,OBJPROP_PRICE1,Low[k]-gap);
}
//-----------------------------------------------------------------------+