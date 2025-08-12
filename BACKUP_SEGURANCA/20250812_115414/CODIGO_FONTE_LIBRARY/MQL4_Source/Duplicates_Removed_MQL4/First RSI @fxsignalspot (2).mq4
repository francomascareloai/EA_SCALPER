//+------------------------------------------------------------------+
//|                                                    First RSI.mq4 |
//|                                              Copyright 2017, Tor |
//|                                             http://einvestor.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Tor"
#property link      "http://einvestor.ru/"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5
//#property icon      "\\Images\\first-rsi2.ico";
#property description "This indicator is based on the first crossing of the standart RSI"

input int RSIPeriod=14;//RSI Period
input int RSIUp = 70;//RSI maximum level
input int RSIDn = 30;//RSI minimum level
input bool Alerts=true;//Alert
input bool Push=false;//Send Notification
input int shift = 1;//Shift 0-curren bar, 1-first bar
input int width = 1;//Width arrows
input color clrBUY=clrBlue;//Buy color
input color clrSELL= clrRed;//Sell color
input bool Comments = false;//Comments

double FirstCross[],BuyLine[],SellLine[],buy[],sell[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorShortName("First RSI");
   SetIndexBuffer(0,buy);
   SetIndexBuffer(1,sell);
   SetIndexBuffer(2,FirstCross);
   SetIndexBuffer(3,BuyLine);
   SetIndexBuffer(4,SellLine);
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,width,clrBUY);
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,width,clrSELL);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,width,clrBUY);
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,width,clrSELL);
   SetIndexArrow(0,233);
   SetIndexArrow(1,234);
   SetIndexLabel(3,"Buy Level");
   SetIndexLabel(4,"Sell Level");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
//---
   int limit;
   static double LastLevel=0,BeforeLevel=0; static datetime LastSignal=0;
   static int LastSig=0;
//---
   if(rates_total<=1)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit=limit+3;

   for(int x=limit-2; x>=0; x--)
     {
      FirstCross[x]=EMPTY_VALUE; buy[x]=EMPTY_VALUE; sell[x]=EMPTY_VALUE;
      BuyLine[x]=EMPTY_VALUE; SellLine[x]=EMPTY_VALUE;

      double RSI0=iRSI(_Symbol,_Period,RSIPeriod,PRICE_CLOSE,x+shift);
      double RSI1=iRSI(_Symbol,_Period,RSIPeriod,PRICE_CLOSE,x+shift+1);

      if(RSI1>RSIUp && RSI0<=RSIUp && LastSig>-1 && (LastLevel==0 || LastLevel!=Open[x]))
        {
         FirstCross[x]=Open[x];
         BeforeLevel=LastLevel;
         LastLevel=Open[x];
         LastSig=-1;
        }
      if(RSI1<RSIDn && RSI0>=RSIDn && LastSig<1 && (LastLevel==0 || LastLevel!=Open[x]))
        {
         FirstCross[x]=Open[x];
         BeforeLevel=LastLevel;
         LastLevel=Open[x];
         LastSig=1;
        }
      if(FirstCross[x]==EMPTY_VALUE){ FirstCross[x]=LastLevel; }
      if(LastSig==1){ BuyLine[x]=LastLevel; }
      if(LastSig==-1){ SellLine[x]=LastLevel; }
      if(BuyLine[x]!=EMPTY_VALUE && SellLine[x+1]!=EMPTY_VALUE && BuyLine[x]>SellLine[x+1])
        {
         buy[x]=BuyLine[x];
         if((Alerts || Push) && LastSignal<Time[x] && x<=1)
           {
            if(Alerts){ Alert(_Symbol+" RSI impulse BUY at "+(string)BuyLine[x]); }
            if(Push){ SendNotification(_Symbol+" RSI impulse BUY at "+(string)BuyLine[x]); }
            LastSignal=Time[x];
           }
        }
      if(SellLine[x]!=EMPTY_VALUE && BuyLine[x+1]!=EMPTY_VALUE && SellLine[x]<BuyLine[x+1])
        {
         sell[x]=SellLine[x];
         if((Alerts || Push) && LastSignal<Time[x] && x<=1)
           {
            if(Alerts){ Alert(_Symbol+" RSI impulse SELL at "+(string)SellLine[x]); }
            if(Push){ SendNotification(_Symbol+" RSI impulse SELL at "+(string)SellLine[x]); }
            LastSignal=Time[x];
           }
        }

     }
   string lt = "";
   if(LastSig==1){ lt="BUY"; }
   if(LastSig==-1){ lt="SELL"; }
   string txt= "Now level - "+(string)LastLevel+" "+lt+"\n";
   txt=txt+"Last level - "+(string)BeforeLevel+"\n";
   if(Comments){ Comment(txt); }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
