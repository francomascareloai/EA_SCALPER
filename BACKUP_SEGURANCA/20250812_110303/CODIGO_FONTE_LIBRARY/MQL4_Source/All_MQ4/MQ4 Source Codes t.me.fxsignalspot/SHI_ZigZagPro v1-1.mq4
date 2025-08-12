//+------------------------------------------------------------------+
//|                                                SHI_ZigZagPro.mq4 |
//|                                         Copyright © 2005, Shurka |
//|                                                 shforex@narod.ru |
//|                                                                  |
//|                                                                  |
//| Пишу программы на заказ                                          |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Shurka"
#property link      "mailto:shforex@narod.ru?subject=Контакт"

#property indicator_chart_window 
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green

extern int  barn=300;
extern int  Length=6;

int         shift,Swing,Swing_n,zu,zd,N,i,Per; 
double      LL,HH,BH,BL;
double      Now[];
double      Prev1[];
double      Prev2[];
//+------------------------------------------------------------------+ 
//| Инициализация                                                    | 
//+------------------------------------------------------------------+ 
int init()
{
   IndicatorBuffers(3);
   SetIndexStyle(0,DRAW_ARROW,1,2);
   SetIndexArrow(0,108);
   SetIndexBuffer(0,Now);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,159);
   SetIndexBuffer(1,Prev1);
   SetIndexEmptyValue(1,0.0);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,159);
   SetIndexBuffer(2,Prev2);
   SetIndexEmptyValue(2,0.0);
   return(0);
}
//+------------------------------------------------------------------+ 
//| Собсно индикатор                                                 | 
//+------------------------------------------------------------------+ 
int start() 
{
   Swing_n=0; Swing=0;
   BH=High[barn]; BL=Low[barn];  zu=barn; zd=barn; 

   for(i=barn;i>=0;i--)
   {
      Now[i]=0.0; Prev1[i]=0.0; Prev2[i]=0.0;
   }
   // Поиск зигзагов текущего таймфрейма
   for(shift=barn;shift>=0;shift--)
   {
      LL=Low[Lowest(NULL,0,MODE_LOW,Length,shift+1)];
      HH=High[Highest(NULL,0,MODE_HIGH,Length,shift+1)];
      if(Low[shift]<LL && High[shift]>HH)
      {
         Swing=2; 
         if(Swing_n==1) zu=shift+1;
         if(Swing_n==-1) zd=shift+1;
      }
      else
      {
         if(Low[shift]<LL) Swing=-1;
         if(High[shift]>HH) Swing=1;
      }
      if(Swing!=Swing_n && Swing_n!=0)
      {
         if(Swing==2) { Swing=-Swing_n; BH=High[shift]; BL=Low[shift]; }
         if(Swing==1) Now[zd]=BL;
         if(Swing==-1) Now[zu]=BH;
         BH=High[shift]; BL=Low[shift];
      }
      if(Swing==1) { if(High[shift]>=BH) { BH=High[shift]; zu=shift; } }
      if(Swing==-1) { if(Low[shift]<=BL) { BL=Low[shift]; zd=shift; } }
      Swing_n=Swing;
   }
   for(N=0,shift=barn;shift>=0;shift--)
   {
      if(Now[shift]>0)
      {
         if(N!=0)
         {
            for(i=N-1;i>shift;i--) Now[i]=Now[N]+((Now[shift]-Now[N])/(N-shift))*(N-i);
         }
         N=shift;
      }
   }
   // Теперь младшего
   switch(Period())
   {
      case PERIOD_MN1: Per=PERIOD_W1; break;
      case PERIOD_W1: Per=PERIOD_D1; break;
      case PERIOD_D1: Per=PERIOD_H4; break;
      case PERIOD_H4: Per=PERIOD_H1; break;
      case PERIOD_H1: Per=PERIOD_M30; break;
      case PERIOD_M30: Per=PERIOD_M15; break;
      case PERIOD_M15: Per=PERIOD_M5; break;
      case PERIOD_M5: Per=PERIOD_M1; break;
      default: return(0); break;
   }
   for(shift=0;iTime(NULL,Per,shift)>=Time[barn] && shift<Bars-1;shift++) continue;
   for(shift--;shift>=0;shift--)
   {
      LL=iLow(NULL,Per,Lowest(NULL,Per,MODE_LOW,Length,shift+1));
      HH=iHigh(NULL,Per,Highest(NULL,Per,MODE_HIGH,Length,shift+1));
      if(iLow(NULL,Per,shift)<LL && iHigh(NULL,Per,shift)>HH)
      {
         Swing=2; 
         if(Swing_n==1) zu=shift+1;
         if(Swing_n==-1) zd=shift+1;
      }
      else
      {
         if(iLow(NULL,Per,shift)<LL) Swing=-1;
         if(iHigh(NULL,Per,shift)>HH) Swing=1;
      }
      if(Swing!=Swing_n && Swing_n!=0)
      {
         if(Swing==2) { Swing=-Swing_n; BH=iHigh(NULL,Per,shift); BL=iLow(NULL,Per,shift); }
         if(Swing==1)
         {
            for(i=0;Time[i]>iTime(NULL,Per,zd);i++) continue; Prev2[i]=BL;
         }
         if(Swing==-1)
         {
            for(i=0;Time[i]>iTime(NULL,Per,zu);i++) continue; Prev1[i]=BH;
         }
         BH=iHigh(NULL,Per,shift); BL=iLow(NULL,Per,shift);
      }
      if(Swing==1) { if(iHigh(NULL,Per,shift)>=BH) { BH=iHigh(NULL,Per,shift); zu=shift; } }
      if(Swing==-1) { if(iLow(NULL,Per,shift)<=BL) { BL=iLow(NULL,Per,shift); zd=shift; } }
      Swing_n=Swing;
   }
   return(0);
}