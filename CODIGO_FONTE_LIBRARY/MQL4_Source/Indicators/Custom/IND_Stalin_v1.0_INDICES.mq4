//+-----------------------------------------------------------------------+
//|                                                            Stalin.mq4 |
//+-----------------------------------------------------------------------+
#property copyright "Copyright © 2011, Andrey Vassiliev (MoneyJinn), v1.0"
#property link      "http://www.vassiliev.ru/"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1  LightSkyBlue
#property indicator_width1  2
#property indicator_color2  LightPink
#property indicator_width2  2

extern int    MAMethod=1;
extern int    MAShift=0;
extern int    Fast=14;
extern int    Slow=21;
extern int    RSI=17;
extern double Confirm=0.0;
extern double Flat=0.0;
extern bool   SoundAlert=false;
extern bool   EmailAlert=false;

double B1[],B2[];
double IUP,IDN,E1,E2,Confirm2,Flat2;

int init()
  {
   CLR();
   if(Digits==3||Digits==5){Confirm2=Confirm*10;Flat2=Flat*10;}else{Confirm2=Confirm;Flat2=Flat;}
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,B1);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,B2);
   return(0);
  }

void CLR(){if(ArraySize(B1)>0){ArrayInitialize(B1,0);ArrayInitialize(B2,0);}IUP=0;IDN=0;E1=0;E2=0;}
double MA(int per,int bar){return(iMA(NULL,0,per,MAShift,MAMethod,PRICE_CLOSE,bar));}

int start()
  {
   int IndCounted=IndicatorCounted();
   if(IndCounted<0){return(-1);}
   if(IndCounted==0){CLR();}
   int pos=0;
   if(Bars>IndCounted+1){pos=(Bars-IndCounted)-1;}
   for(int i=pos;i>0;i--)
     {
      if(MA(Fast,i+1)<MA(Slow,i+1)&&MA(Fast,i)>MA(Slow,i)&&(iRSI(NULL,0,RSI,PRICE_CLOSE,i)>50||RSI==0)){if(Confirm2==0){BU(i);}else{IUP=Low[i];IDN=0;}}
      if(MA(Fast,i+1)>MA(Slow,i+1)&&MA(Fast,i)<MA(Slow,i)&&(iRSI(NULL,0,RSI,PRICE_CLOSE,i)<50||RSI==0)){if(Confirm2==0){BD(i);}else{IDN=High[i];IUP=0;}}
      if(IUP!=0){if(((High[i]-IUP)>=(Confirm2*Point))&&(Open[i]<=Close[i])){BU(i);IUP=0;}}
      if(IDN!=0){if(((IDN-Low[i])>=(Confirm2*Point))&&(Open[i]>=Close[i])){BD(i);IDN=0;}}
     }
   return(0);
  }
  
void BU(int i){if(Low[i]>=(E1+Flat2*Point)||Low[i]<=(E1-Flat2*Point)){B1[i]=Low[i];E1=B1[i];Alerts(i,"UP "+Symbol()+" "+TimeToStr(Time[i]));}}
void BD(int i){if(High[i]>=(E2+Flat2*Point)||High[i]<=(E2-Flat2*Point)){B2[i]=High[i];E2=B2[i];Alerts(i,"DN "+Symbol()+" "+TimeToStr(Time[i]));}}

void Alerts(int pos,string txt)
  {  
   if (SoundAlert==true&&pos==1){PlaySound("alert.wav");}
   if (EmailAlert==true&&pos==1){SendMail("Stalin alert signal: "+txt,txt);} 
  }


