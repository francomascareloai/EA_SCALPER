//+------------------------------------------------------------------+
//|                                                      Kaufman.mq4 |
//|                             Copyright © -2005, by konKop & wellx |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, by konKop,wellx"
#property link      "http://www.metaquotes.net"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Sienna
#property indicator_color2 Blue
#property indicator_color3 OrangeRed
#property indicator_color4 Red
//---- input parameters
extern int       periodAMA=10;
extern int       nfast=2;
extern int       nslow=5;//30
extern double    G=3.0;
extern double    dK=140;
extern int    Kperiod=14;
extern int    slowing=5;

//---- buffers
double kAMAbuffer[];
double kAMAupsig[];
double kAMAdownsig[];
double NewIndikator[];
double trend[];
//+------------------------------------------------------------------+
int    k=0, cbars=0, prevbars=0, prevtime=0;
double slowSC,fastSC,AMA0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
IndicatorBuffers(5);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,kAMAbuffer);
   SetIndexStyle(1,DRAW_ARROW,0,3);
   SetIndexArrow(1,159);
   SetIndexBuffer(1,kAMAupsig);
   SetIndexStyle(2,DRAW_ARROW,0,3);
   SetIndexArrow(2,159);
   SetIndexBuffer(2,kAMAdownsig);
   
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,NewIndikator);

   SetIndexBuffer(4,trend);
   //SetIndexDrawBegin(0,nslow+nfast);
   
   
   
   
//----
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
   //---------------NewIndikator
  
  
   
  
  
   //---------------
  
   int    i,pos=0;
   double noise=0.000000001,AMA,signal,ER;
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
   
   
   
   int limit=Bars-IndicatorCounted();
            for(pos=limit-1;pos>=0;pos--)
     {NewIndikator[pos]=iStochastic(NULL,0,Kperiod,3,slowing,0,0,0,pos);
      kAMAupsig[pos]  =NULL;
      kAMAdownsig[pos]=NULL;
      if(pos==Bars-periodAMA-2) AMA0=iStochastic(NULL,0,Kperiod,3,slowing,0,0,0,pos+1);
      signal=MathAbs(iStochastic(NULL,0,Kperiod,3,slowing,0,0,0,pos)-iStochastic(NULL,0,Kperiod,3,slowing,0,0,0,pos+periodAMA));
      noise=0.000000001;
      for(i=0;i<periodAMA;i++)
        {
         noise=noise+MathAbs(iStochastic(NULL,0,Kperiod,3,slowing,0,0,0,pos+i)-iStochastic(NULL,0,Kperiod,3,slowing,0,0,0,pos+i+1));
        }
      ER =signal/noise;
      dSC=(fastSC-slowSC);
      ERSC=ER*dSC;
      SSC=ERSC+slowSC;
      AMA=AMA0+(MathPow(SSC,G)*(iStochastic(NULL,0,Kperiod,3,slowing,0,0,0,pos)-AMA0));
      kAMAbuffer[pos]=AMA;
//----
      ddK=(AMA-AMA0);
      while(true){trend[pos]=trend[pos+1];
           if ((MathAbs(ddK) > (dK*Point)) && (ddK > 0))  {kAMAupsig[pos]  =AMA;kAMAdownsig[pos]=EMPTY_VALUE;trend[pos]=1;break;}
           if ((MathAbs(ddK)) > (dK*Point) && (ddK < 0))  {kAMAdownsig[pos]=AMA;kAMAupsig[pos]  =EMPTY_VALUE;trend[pos]=-1;break;}
           kAMAupsig[pos]  =EMPTY_VALUE;
           kAMAdownsig[pos]=EMPTY_VALUE;
           break;
          }
      AMA0=AMA;
      
     }
//----
   prevbars=Bars;
   return(0);
  }
//+------------------------------------------------------------------+