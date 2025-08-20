//+------------------------------------------------------------------+
//|                                                   AMA&AMAsig.mq4 |                                                             
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, by GOODMAN & Mstera è AF "
      
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Sienna
#property indicator_color2 Green
#property indicator_color3 Red
//---- input parameters
extern int       periodAMA=50;
extern int       nfast=15;
extern int       nslow=10;
extern double    G=1.0;
extern double    dK=0.1; 

//---- buffers
double kAMAbuffer[];
double kAMAupsig[];
double kAMAdownsig[];
extern bool UseSound = True;
extern string SoundFile = "expert.wav"; 
//+------------------------------------------------------------------+
int    cbars=0, prevbars=0, prevtime=0;
double slowSC,fastSC;
bool SoundBuy = False;
bool SoundSell = False;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE,0,2);
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID, 2);
   SetIndexArrow(1,159);
   SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID, 2);
   SetIndexArrow(2,159);
   //SetIndexDrawBegin(0,nslow+nfast);
   SetIndexBuffer(0,kAMAbuffer);
   SetIndexBuffer(1,kAMAupsig);
   SetIndexBuffer(2,kAMAdownsig);
   IndicatorDigits(4);
   //slowSC=0.064516;
   //fastSC=0.2;
   //cbars=IndicatorCounted();
//----
   return(0);
  }
int last_dir = 0;
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
   int    i,pos=0;
   double noise=0.000000001,AMA,AMA0,signal,ER;
   double dSC,ERSC,SSC,ddK;
   
   if (prevbars==Bars) return(0);
    
//---- TODO: add your code here
   slowSC=(2.0 /(nslow+1));
   fastSC=(2.0 /(nfast+1));
   cbars=IndicatorCounted();
   if (Bars<=(periodAMA+2)) return(0);
//---- check for possible errors
   if (cbars<0) return(-1);
//---- last counted bar will be recounted
   if (cbars>0) cbars--;
   pos=Bars-periodAMA-2;
   AMA0=Close[pos+1];
   int dir = 0;
   while (pos>=0)
     {
      if(pos==Bars-periodAMA-2) AMA0=Close[pos+1];
      signal=MathAbs(Close[pos]-Close[pos+periodAMA]);
      noise=0.000000001;
      for(i=0;i<periodAMA;i++)
       {
        noise=noise+MathAbs(Close[pos+i]-Close[pos+i+1]);
       }
      ER =signal/noise;
      dSC=(fastSC-slowSC);
      ERSC=ER*dSC;
      SSC=ERSC+slowSC;
      AMA=AMA0+(MathPow(SSC,G)*(Close[pos]-AMA0));
      kAMAbuffer[pos]=AMA;

      ddK=(AMA-AMA0);
      if ((MathAbs(ddK)) > (dK*Point) && (ddK > 0)) kAMAupsig[pos] =AMA; else kAMAupsig[pos]=0;
      if ((MathAbs(ddK)) > (dK*Point) && (ddK < 0)) kAMAdownsig[pos]=AMA; else kAMAdownsig[pos]=0; 

     
      AMA0=AMA;
      pos--;
     }
if (kAMAupsig[0] != EMPTY_VALUE && kAMAupsig[0] != 0 && SoundBuy)
  {
   SoundBuy = False;
   if (UseSound) PlaySound (SoundFile);
   Comment (Symbol()," ",Period(),"hellkkas BUY @ ",Ask);
   Alert (Symbol()," ",Period(),"hellkkas BUY @ ",Ask);
  } 
if (!SoundBuy && (kAMAupsig[0] == EMPTY_VALUE || kAMAupsig[0] == 0)) SoundBuy = True;  
  
if (kAMAdownsig[0] != EMPTY_VALUE && kAMAdownsig[0] != 0 && SoundSell)
  {
   SoundSell = False;
   if (UseSound) PlaySound (SoundFile);
   Comment (Symbol()," ",Period(), "hellkkas Sell @",Bid);
   Alert (Symbol()," ",Period(), "hellkkas Sell @",Bid);
  }
if (!SoundSell && (kAMAdownsig[0] == EMPTY_VALUE || kAMAdownsig[0] == 0)) SoundSell = True;  

   prevbars=Bars;
   return(0);
  }

