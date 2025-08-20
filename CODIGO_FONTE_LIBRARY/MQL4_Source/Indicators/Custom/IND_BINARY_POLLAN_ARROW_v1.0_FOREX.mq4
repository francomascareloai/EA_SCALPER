//+------------------------------------------------------------------+
//|                                   BINARY POLLAN ARROW_v.3.1.mq4  |
//|                            Copyright Bostonmarket2020@gmail.com  |
//|                                                                  | 
//|             BINARY POLLAN ARROW_v.3.1 - With Alerts              |  
//|                                                                  |
//|         Version 3.1  Completed 2020 (www.Forex-joy.com)          |
//|                                                                  |
//|               a)   Complete Code rewrite                         |
//|               b)   Added Entry / Exit Signal Arrows Option       | 
//|               c)   Added Audio, Visual and eMail alerts          |                                          | 
//+------------------------------------------------------------------+                                                                

#property copyright "BINARY POLLAN ARROW_v.3.1 Copyright 2020 Boston Market CO USA"
#property link      "Bostonmarket2020@gmail.com"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red
//---- input parameters

extern int  CCI_per       = 14;     
extern int  RSI_per       = 21;
extern int  Ma_Period     = 1;
extern int  koef          = 6;
extern color   ArrowsUpColor = Lime;
extern color   ArrowsDnColor = Red;
extern int     ArrowsUpCode  = 241;
extern int     ArrowsDnCode  = 242;
extern int     ArrowsSize    = 3;
extern double  ArrowUpGap = 1.0;
extern double  ArrowDnGap  = 1.0;
extern bool arrows        = true;
extern bool AlertsMessage = true; 
extern bool AlertsSound   = false;
extern bool AlertsEmail   = false;
extern bool AlertsMobile  = false;
extern int  SignalBar     = 0;

datetime TimeBar;

double a=0,a1=0,a2=0,a3=0,a4=0,a5=0,a6=0,a7=0,a8=0;
double b=0,b1=0,b2=0,b3=0,b4=0,b5=0,b6=0,b7=0,b8=0;
double tt1max=0,tt2min=0;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
string sPrefix;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexBuffer(1,ExtMapBuffer2);
   
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);
    
   SetIndexLabel(0, "CCI-RSI");   
   SetIndexLabel(1, "RSI-CCI");  
   sPrefix ="EATA pollan vers 2 (" + CCI_per + ", " + RSI_per + " )";
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
DelOb();
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
      {
   int limit=Bars-IndicatorCounted();
   
   for(int i=limit-1;i>=0;i--) 
   { 
           a=iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i)-iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i);
            a1=(iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i-1)-iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i+1));
             a2=(iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i-2)-iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i+2));
              a3=(iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i-3)-iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i+3));
               a4=(iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i-4)-iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i+4));
                a5=(iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i-5)-iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i+5));
                 a6=(iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i-6)-iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i+6));
                  a7=(iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i-7)-iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i+7));
                   a8=(iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i-8)-iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i+8));
                   
                   
                   
                   
           b=iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i)-iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i);
            b1=(iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i-1)-iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i+1));
             b2=(iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i-2)-iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i+2));
              b3=(iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i-3)-iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i+3));
               b4=(iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i-4)-iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i+4));
                b5=(iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i-5)-iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i+5));
                 b6=(iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i-6)-iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i+6));
                  b7=(iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i-7)-iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i+7));
                   b8=(iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i-8)-iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i+8));
                   
                   
   switch(koef)
   {
      case 0     : tt1max=a; tt2min=b; break;
      case 1     : tt1max=a+a1; tt2min=b+b1; break;
      case 2     : tt1max=a+a1+a2; tt2min=b+b1+b2; break;
      case 3     : tt1max=a+a1+a2+a3; tt2min=b+b1+b2+b3; break;
      case 4     : tt1max=a+a1+a2+a3+a4; tt2min=b+b1+b2+b3+b4; break;
      case 5     : tt1max=a+a1+a2+a3+a4+a5; tt2min=b+b1+b2+b3+b4+b5; break;
      case 6     : tt1max=a+a1+a2+a3+a4+a5+a6; tt2min=b+b1+b2+b3+b4+b5+b6; break;
      case 7     : tt1max=a+a1+a2+a3+a4+a5+a6+a7; tt2min=b+b1+b2+b3+b4+b5+b6+b7; break;
      case 8     : tt1max=a+a1+a2+a3+a4+a5+a6+a7+a8; tt2min=b+b1+b2+b3+b4+b5+b6+b7+b8; break;
      default    : tt1max=a+a1+a2+a3+a4+a5+a6+a7+a8; tt2min=b+b1+b2+b3+b4+b5+b6+b7+b8; 
   }
                   
                   ExtMapBuffer3[i]=tt1max;
                   ExtMapBuffer4[i]=tt2min;
                   
   }
                       
 for(i=0; i<limit; i++)
 {     
   ExtMapBuffer1[i]=iMAOnArray(ExtMapBuffer3,Bars,Ma_Period,0,MODE_SMA,i);                  
   ExtMapBuffer2[i]=-250;   
 }                  
  for(i=0; i<limit; i++)
  { 
      if(arrows)
      {
        if(ExtMapBuffer1[i]>=+1 && ExtMapBuffer1[i+1]<+1)
        {
        DrawAr("BUY!",i);
        }
        if(ExtMapBuffer1[i]<=+1 && ExtMapBuffer1[i+1]>-+1)
        {
        DrawAr("SELL!",i);
        }      
       }
   }      
   return(0);
}
   //-------------------------------------------------------------------+
void DelOb()
{
    int n = ObjectsTotal();
    for (int i = n - 1; i >= 0; i--) 
    {
     string sName = ObjectName(i);
	  if (StringFind(sName, sPrefix) == 0) 
	  {
	    ObjectDelete(sName);
	  }
    }
}
//----------------------------------------------------------------------
void DrawAr(string ssName, int i)
{
    string sName=sPrefix+" "+ssName+" "+ TimeToStr(Time[i],TIME_DATE|TIME_MINUTES);
    ObjectDelete(sName);    
    ObjectCreate(sName, OBJ_ARROW, 0, Time[i], 0);
    double gap  = 3.0*iATR(NULL,0,20,i)/4.0;
    if(ssName=="BUY!")
    {
    ObjectSet(sName, OBJPROP_COLOR,  ArrowsUpColor);
    ObjectSet(sName, OBJPROP_ARROWCODE,  ArrowsUpCode);
    ObjectSet(sName, OBJPROP_PRICE1, Low[i]-5*ArrowUpGap*Point);
    }
    if(ssName=="SELL!")
    {
    ObjectSet(sName, OBJPROP_COLOR,  ArrowsDnColor);
    ObjectSet(sName, OBJPROP_ARROWCODE,  ArrowsDnCode);
    ObjectSet(sName, OBJPROP_PRICE1, High[i]+15*ArrowUpGap*Point);
    }    
    ObjectSet(sName, OBJPROP_WIDTH, ArrowsSize);

//---------------------------------------------------------+
//-------------------------------------------------------------------+ 
 if(AlertsMessage || AlertsSound || AlertsEmail || AlertsMobile)
  { 
      string  message1   =  StringConcatenate(Symbol(), " M", Period()," ", " BINARY POLLAN ARROW : SELL!");
      string  message2   =  StringConcatenate(Symbol(), " M", Period()," ", " BINARY POLLAN ARROW : BUY!");
       
    if(TimeBar!=Time[0] && ExtMapBuffer1[SignalBar]>=ExtMapBuffer2[SignalBar] && ExtMapBuffer1[SignalBar+1]<ExtMapBuffer2[SignalBar+1])
     { 
        if (AlertsMessage) Alert(message1);
        if (AlertsSound)   PlaySound("alert2.wav");
        if (AlertsEmail)   SendMail(Symbol()+" - "+WindowExpertName()+" - ",message1);
        if (AlertsMobile)  SendNotification(message1);
        TimeBar=Time[0];
     }
    if(TimeBar!=Time[0] && ExtMapBuffer1[SignalBar]<=ExtMapBuffer2[SignalBar] && ExtMapBuffer1[SignalBar+1]>ExtMapBuffer2[SignalBar+1])
     { 
        if (AlertsMessage) Alert(message2);
        if (AlertsSound)   PlaySound("alert2.wav");
        if (AlertsEmail)   SendMail(Symbol()+" - "+WindowExpertName()+" - ",message2);
        if (AlertsMobile)  SendNotification(message2);
        TimeBar=Time[0];
     } 
      
   }
//-------------------------------------------------------------------+  
   return;
}
//-------------------------------------------------------------------+ 
string PeriodString()
{
    switch (_Period) 
     {
        case PERIOD_M1:  return("M1");
        case PERIOD_M5:  return("M5");
        case PERIOD_M15: return("M15");
        case PERIOD_M30: return("M30");
        case PERIOD_H1:  return("H1");
        case PERIOD_H4:  return("H4");
        case PERIOD_D1:  return("D1");
        case PERIOD_W1:  return("W1");
        case PERIOD_MN1: return("MN1");
     }    
   return("M" + string(_Period));
}
