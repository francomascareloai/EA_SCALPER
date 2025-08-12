//+------------------------------------------------------------------+
//|                                                 Ma_Parabolic.mq4 |
//|                                         Copyright © 2007         |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red
//---- input parameters
extern int MA       = 24; // Period MA
extern int MA_Mode  = 2;  // 0=sma, 1=ema, 2=smma, 3=lwma
extern int MA_Price = 0;  // 0-CLOSE,1-OPEN,2-HIGH,3-LOW,4-MEDIAN,5-TYPICAL,6-WEIGHTED
extern double    Step=0.02;
extern double    Maximum=0.08;
extern bool Alert_Sound = true;
//---- buffers
double SarBuffer[];
double MaBuffer[];
//----
int    save_lastreverse;
bool   save_dirlong;
double save_start;
double save_last_high;
double save_last_low;
double save_ep;
double save_sar;

//---- Номер бара, по которому будет искаться сигнал
#define SIGNAL_BAR 1
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexBuffer(0,SarBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,MaBuffer);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SaveLastReverse(int last,int dir,double start,double low,double high,double ep,double sar)
  {
   save_lastreverse=last;
   save_dirlong=dir;
   save_start=start;
   save_last_low=low;
   save_last_high=high;
   save_ep=ep;
   save_sar=sar;
  }
//+------------------------------------------------------------------+
//| Parabolic Sell And Reverse system                                |
//+------------------------------------------------------------------+
int start()
  {
   static bool first=true;
   bool   dirlong;
   double start,last_high,last_low;
   double ep,sar,price_low,price_high,price;
   int    i,counted_bars=IndicatorCounted();
//----
   for(i=0; i<Bars-MA-2; i++)
      MaBuffer[i]=iMA(NULL,0,MA,0,MA_Mode,MA_Price,i);
//---- 
   if(Bars<0) return(0);
//---- initial settings
   i=Bars-2;
   if(counted_bars==0 || first)
     {
      first=true;
      dirlong=true;
      start=Step;//start=0.002
      last_high=-10000000.0;
      last_low=10000000.0;
      while(i>0)
        {
         save_lastreverse=i;
         price_low=MaBuffer[i];
         if(last_low>price_low)   last_low=price_low;
         price_high=MaBuffer[i];
         if(last_high<price_high) last_high=price_high;
         if(price_high>MaBuffer[i+1] && price_low>MaBuffer[i+1]) break;
         if(price_high<MaBuffer[i+1] && price_low<MaBuffer[i+1]) { dirlong=false; break; }
         i--;
        }
      //---- initial zero
      int k=i;
      while(k<Bars)
        {
         SarBuffer[k]=0.0;
         k++;
        }
      //---- check further
      if(dirlong) { SarBuffer[i]=MaBuffer[i+1]; ep=MaBuffer[i]; }
      else        { SarBuffer[i]=MaBuffer[i+1]; ep=MaBuffer[i]; }
      i--;
     }
    else
     {
      i=save_lastreverse;
      start=save_start;
      dirlong=save_dirlong;
      last_high=save_last_high;
      last_low=save_last_low;
      ep=save_ep;
      sar=save_sar;
     }
//----
   while(i>=0)
     {
      price_low=MaBuffer[i];
      price_high=MaBuffer[i];
      //--- check for reverse
      if(dirlong && price_low<SarBuffer[i+1])
        {
         SaveLastReverse(i,true,start,price_low,last_high,ep,sar);
         start=Step; 
         dirlong=false;
         ep=price_low;  
         last_low=price_low;
         SarBuffer[i]=last_high;
         i--;
         continue;
        }
      if(!dirlong && price_high>SarBuffer[i+1])
        {
         SaveLastReverse(i,false,start,last_low,price_high,ep,sar);
         start=Step; 
         dirlong=true;
         ep=price_high; 
         last_high=price_high;
         SarBuffer[i]=last_low;
         i--;
         continue;
        }
      //---
      price=SarBuffer[i+1];
      sar=price+start*(ep-price);
      if(dirlong)
        {
         if(ep<price_high && (start+Step)<=Maximum) start+=Step;
         if(price_high<MaBuffer[i+1] && i==Bars-2)  sar=SarBuffer[i+1];

         price=MaBuffer[i+1];
         if(sar>price) sar=price;
         price=MaBuffer[i+2];
         if(sar>price) sar=price;
         if(sar>price_low)
           {SaveLastReverse(i,true,start,price_low,last_high,ep,sar);
            start=Step; dirlong=false; ep=price_low;
            last_low=price_low;
            SarBuffer[i]=last_high;
            i--;
            continue;
           }
         if(ep<price_high) 
           {last_high=price_high; 
            ep=price_high; 
           }
        }
      else
        {if(ep>price_low && (start+Step)<=Maximum) start+=Step;
         if(price_low<MaBuffer[i+1] && i==Bars-2)  sar=SarBuffer[i+1];

         price=MaBuffer[i+1];
         if(sar<price) sar=price;
         price=MaBuffer[i+2];
         if(sar<price) sar=price;
         if(sar<price_high)
           {
            SaveLastReverse(i,false,start,last_low,price_high,ep,sar);
            start=Step; dirlong=true; ep=price_high;
            last_high=price_high;
            SarBuffer[i]=last_low;
            i--;
            continue;
           }
         if(ep>price_low) { last_low=price_low; ep=price_low; }
        }
      SarBuffer[i]=sar;
      i--;
     }
//----

  
  //---- время последнего бара и направление последнего сигнала
	  static int PrevSignal = 0, PrevTime = 0;
//---- Если баром для анализа выбран не 0-й, нам нет смысла проверять сигнал
//---- несколько раз. Если не начался новый бар, выходим.
	  if(SIGNAL_BAR > 0 && Time[0] <= PrevTime ) 
	      return(0);	
//---- Отмечаем, что этот бар проверен
	  PrevTime = Time[0];
//---- Если предыдущий сигнал был СЕЛЛ или это первый запуск (PrevSignal=0)
	  if(PrevSignal <= 0)
	    {
		     if(Close[SIGNAL_BAR] - SarBuffer[SIGNAL_BAR] > 0)
		       {
			        PrevSignal = 1;
			        if (Alert_Sound)Alert("Ma_Parabolic(", Symbol(), ", ", Period(), ")  -  BUY");
		       }
	    }
   if(PrevSignal >= 0)
     {
       if(SarBuffer[SIGNAL_BAR] - Close[SIGNAL_BAR] > 0)
         {
	          PrevSignal = -1;
	          if (Alert_Sound)Alert("Ma_Parabolic(", Symbol(), ", ", Period(), ")  -  SELL");
         }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+