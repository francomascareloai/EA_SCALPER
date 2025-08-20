//+------------------------------------------------------------------+
//|                                                       icwr.mq4 |
//|                 Copyright © 2006, tageiger aka fxid10t@yahoo.com |
//|                                        http://www.metatrader.org |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, tageiger aka fxid10t@yahoo.com"
#property link      "http://www.metatrader.org"

extern double     Min.Wave.Range    =0;      //if zero, 5m/240m defaults apply
extern int        StopLoss          =0;      //if zero, 5m/240m defaults apply

extern int        RSI.TimeFrame     =1440;   //default daily timeframe
extern int        RSI.Period        =14;     //default 14 periods
extern int        RSI.Applied_Price =0;      /*see below, default PRICE_CLOSE
Applied price constants can be any of the following values:

Constant     Value   Description 
PRICE_CLOSE    0     Close price. 
PRICE_OPEN     1     Open price. 
PRICE_HIGH     2     High price. 
PRICE_LOW      3     Low price. 
PRICE_MEDIAN   4     Median price, (high+low)/2. 
PRICE_TYPICAL  5     Typical price, (high+low+close)/3. 
PRICE_WEIGHTED 6     Weighted close price, (high+low+close+close)/4.  */
extern int        RSI.Shift         =0;      //default zero 


extern double     MaximumRisk       =0.02;   //%account balance to risk per position
extern double     DecreaseFactor    =3;      //lot size divisor(reducer) during loss streak
extern double     Lot.Margin        =50;     //Margin for 1 lot   

extern int        Magic             =69;
extern string     comment           ="m icwr";

double   spread;  spread      =Ask-Bid;
int      slip;    slip        =spread/Point;

double rsi,temp.high,active.high,temp.low,active.low,r,x,SL,awp1,awp2,high.c,high.r,low.r,low.c;
int a.high.shift,a.low.shift,shift,b,s,cnt,b.ticket,s.ticket;
datetime a.high.time,a.low.time,awt1,awt2;
string FiboName;

int init(){return(0);}
int deinit(){ ObjectsDeleteAll(0,OBJ_FIBO); return(0); }
int start(){

   PosCounter();  
   rsi=iRSI(Symbol(),RSI.TimeFrame,RSI.Period,RSI.Applied_Price,RSI.Shift);
   if(Min.Wave.Range==0)   {
      if(Period()==5)   {Min.Wave.Range=(40*Point);}
      if(Period()==240) {Min.Wave.Range=(150*Point);}}
   if(StopLoss==0)   {
      if(Period()==5)   {SL=(50*Point);}
      if(Period()==240) {SL=(100*Point);}}
   if(StopLoss>0) {SL=(StopLoss*Point);}
   if(a.high.time>0) {a.high.shift=iBarShift(Symbol(),Period(),a.high.time);}
   if(a.low.time>0)  {a.low.shift=iBarShift(Symbol(),Period(),a.low.time);}

//---initial fibo/active wave location
   for(int c=1;r<Min.Wave.Range;c++)  {
      temp.high=High[Highest(Symbol(),Period(),MODE_HIGH,c,0)];
      if(temp.high>active.high)  {  active.high=temp.high;
                                    a.high.time=iTime(Symbol(),Period(),Highest(Symbol(),Period(),MODE_HIGH,c,0));
                                    a.high.shift=iBarShift(Symbol(),Period(),a.high.time);}
      temp.low=Low[Lowest(Symbol(),Period(),MODE_LOW,c,0)];
      if(temp.low<active.low ||
         active.low<=0)          {  active.low=temp.low;
                                    a.low.time=iTime(Symbol(),Period(),Lowest(Symbol(),Period(),MODE_LOW,c,0));
                                    a.low.shift=iBarShift(Symbol(),Period(),a.low.time);}
      r=(active.high-active.low);   }

//---initial fibo, prior highs/lows stretch
   if(a.high.shift<a.low.shift && Low[a.low.shift+1]<Low[a.low.shift])  {
      ObjectDelete(TimeToStr(a.high.time,TIME_DATE|TIME_MINUTES));
      active.low=Low[a.low.shift+1];
      a.low.time=iTime(Symbol(),Period(),Lowest(Symbol(),Period(),MODE_LOW,a.low.shift+1,0));
      a.low.shift=iBarShift(Symbol(),Period(),a.low.time);}

   if(a.low.shift<a.high.shift && High[a.high.shift+1]>High[a.high.shift])   {
      ObjectDelete(TimeToStr(a.low.time,TIME_DATE|TIME_MINUTES));
      active.high=High[a.high.shift+1];
      a.high.time=iTime(Symbol(),Period(),Highest(Symbol(),Period(),MODE_LOW,a.high.shift+1,0));
      a.high.shift=iBarShift(Symbol(),Period(),a.high.time);}            

//---fibo current high/low stretch
   if(a.high.shift<=1 && High[0]>High[1])  {
      ObjectDelete(TimeToStr(a.high.time,TIME_DATE|TIME_MINUTES));
      active.high=High[Highest(Symbol(),Period(),MODE_HIGH,a.low.shift,0)];
      a.high.time=iTime(Symbol(),Period(),Highest(Symbol(),5,MODE_HIGH,a.low.shift,0));
      a.high.shift=iBarShift(Symbol(),Period(),a.high.time);}

   if(a.low.shift<=1 && Low[0]<Low[1])  {
      ObjectDelete(TimeToStr(a.low.time,TIME_DATE|TIME_MINUTES));
      active.low=Low[Lowest(Symbol(),Period(),MODE_LOW,a.high.shift,0)];
      a.low.time=iTime(Symbol(),Period(),Lowest(Symbol(),Period(),MODE_LOW,a.high.shift,0));
      a.low.shift=iBarShift(Symbol(),Period(),a.low.time);}

//---new active wave determination
   if(a.high.shift<a.low.shift) shift=a.high.shift;
   if(a.low.shift<a.high.shift) shift=a.low.shift;

   if(shift>1 &&
      (High[Highest(Symbol(),Period(),MODE_HIGH,shift,0)]-Low[Lowest(Symbol(),Period(),MODE_LOW,shift,0)]>=Min.Wave.Range)) {

      active.high=0;a.high.time=0;a.high.shift=0;  active.low=0;a.low.time=0;a.low.shift=0;

      temp.high=High[Highest(Symbol(),Period(),MODE_HIGH,shift,0)];
      if(temp.high>active.high)  {  active.high=temp.high;
                                    a.high.time=iTime(Symbol(),Period(),Highest(Symbol(),Period(),MODE_HIGH,shift,0));
                                    a.high.shift=iBarShift(Symbol(),Period(),a.high.time);}
      temp.low=Low[Lowest(Symbol(),Period(),MODE_LOW,shift,0)];
      if(temp.low<active.low ||
         active.low<=0)          {  active.low=temp.low;
                                    a.low.time=iTime(Symbol(),Period(),Lowest(Symbol(),Period(),MODE_LOW,shift,0));
                                    a.low.shift=iBarShift(Symbol(),Period(),a.low.time);}  }

//---bullish (uptrend) fibo
   if(a.high.shift<=a.low.shift)  {
      FiboName=TimeToStr(a.high.time,TIME_DATE|TIME_MINUTES);
      ObjectCreate(FiboName,OBJ_FIBO,0,a.low.time,active.low,a.high.time,active.high);
      ObjectSet(FiboName, OBJPROP_STYLE, STYLE_DASH);
      ObjectSet(FiboName, OBJPROP_COLOR, Green);               
      ObjectSet(FiboName, OBJPROP_WIDTH, 0.5);
      ObjectSet(FiboName, OBJPROP_FIBOLEVELS, 4);
      //ObjectSet(FiboName, OBJPROP_FIRSTLEVEL+0, 0);
      ObjectSet(FiboName, OBJPROP_FIRSTLEVEL+0, 0.25);
      ObjectSet(FiboName, OBJPROP_FIRSTLEVEL+1, 0.382);
      ObjectSet(FiboName, OBJPROP_FIRSTLEVEL+2, 0.618);
      ObjectSet(FiboName, OBJPROP_FIRSTLEVEL+3, 0.75);
      //ObjectSet(FiboName, OBJPROP_FIRSTLEVEL+5, 1);
      ObjectSet(FiboName, OBJPROP_RAY, false);  }

//---bearish (downtrend) fibo
   if(a.low.shift<a.high.shift)  {
      FiboName=TimeToStr(a.low.time,TIME_DATE|TIME_MINUTES);
      ObjectCreate(FiboName,OBJ_FIBO,0,a.high.time,active.high,a.low.time,active.low);
      ObjectSet(FiboName, OBJPROP_STYLE, STYLE_DASH);
      ObjectSet(FiboName, OBJPROP_COLOR, Green);               
      ObjectSet(FiboName, OBJPROP_WIDTH, 0.5);
      ObjectSet(FiboName, OBJPROP_FIBOLEVELS, 4);
      //ObjectSet(FiboName, OBJPROP_FIRSTLEVEL+0, 0);
      ObjectSet(FiboName, OBJPROP_FIRSTLEVEL+0, 0.25);
      ObjectSet(FiboName, OBJPROP_FIRSTLEVEL+1, 0.382);
      ObjectSet(FiboName, OBJPROP_FIRSTLEVEL+2, 0.618);
      ObjectSet(FiboName, OBJPROP_FIRSTLEVEL+3, 0.75);
      //ObjectSet(FiboName, OBJPROP_FIRSTLEVEL+5, 1);
      ObjectSet(FiboName, OBJPROP_RAY, false);  }

//---confirmation/retracement levels
   high.c=NormalizeDouble(active.low+((active.high-active.low)*0.75),Digits);
   high.r=NormalizeDouble(active.low+((active.high-active.low)*0.618),Digits);
   low.r=NormalizeDouble(active.low+((active.high-active.low)*0.382),Digits);
   low.c=NormalizeDouble(active.low+((active.high-active.low)*0.25),Digits);

//---buy/sell order parameters, close buy/sell parameters
   if(rsi>50 && b==0)  {
      for(int i=0;i<shift;i++)   {
         if(Close[i]<high.r && Close[i]>low.r && Low[1]>high.c) {
            b.ticket=OrderSend(Symbol(),
                              OP_BUY,
                              LotsOptimized(),
                              Ask,
                              slip,
                              Ask-SL,
                              0,
                              Period()+comment,
                              Magic,0,0);
                              if(b.ticket>0)   {
                                 if(OrderSelect(b.ticket,SELECT_BY_TICKET,MODE_TRADES))
                                       {   Print(b.ticket);   }
                                 else Print("Error Opening BuyStop Order: ",GetLastError());
                              return(0);}}}}

   if(rsi<50 && rsi>0 && s==0)  {
      for(int ii=0;ii<shift;ii++)   {
         if(Close[ii]<high.r && Close[ii]>low.r && High[1]<low.c)  {
            s.ticket=OrderSend(Symbol(),
                              OP_SELL,
                              LotsOptimized(),
                              Bid,
                              slip,
                              Bid+SL,
                              0,
                              Period()+comment,
                              Magic,0,0);
                              if(s.ticket>0)   {
                                 if(OrderSelect(s.ticket,SELECT_BY_TICKET,MODE_TRADES))
                                     {   Print(s.ticket);   }
                                 else Print("Error Opening SellStop Order: ",GetLastError());
                              return(0);}}}}

   if(b>0)  {
      if(High[1]<low.c) {
         OrderSelect(b.ticket,SELECT_BY_TICKET); 
         OrderClose(OrderTicket(),OrderLots(),Bid,slip,0);}}

   if(s>0)  {
      if(Low[1]>high.c) {
         OrderSelect(s.ticket,SELECT_BY_TICKET); 
         OrderClose(OrderTicket(),OrderLots(),Ask,slip,0);}}

//---
   comments();

return(0);}
//+---------------------------FUNCTIONS------------------------------+
void comments()   {
if(MarketInfo(Symbol(),MODE_SWAPLONG)>0) string swap="longs.";
else swap="shorts.";
if(MarketInfo(Symbol(),MODE_SWAPLONG)<0 && MarketInfo(Symbol(),MODE_SWAPSHORT)<0) swap="your broker. :(";

   Comment("Last Tick: ",TimeToStr(CurTime(),TIME_DATE|TIME_SECONDS),"\n",
           "Swap favors ",swap,"\n",
           "Daily RSI= ",rsi,"\n",
           "Active High: ",active.high,"\n",
           "High Confirm: ",high.c,"\n",
           "High Retrace: ",high.r,"\n",
           "Low Retrace: ",low.r,"\n",
           "Low Confirm: ",low.c,"\n",
           "Active Low: ",active.low,"\n",
           "High shift: ",a.high.shift,"\n",
           "Low shift: ",a.low.shift,"\n",
           "Minimum Wave Height: ",Min.Wave.Range,"\n","Active Wave Height: ",active.high-active.low,"\n",
           "Open Long/Short Ticket #","\'","s: ",b.ticket," ",s.ticket);  }

void PosCounter() {
   b=0;s=0;b.ticket=0;s.ticket=0;
   for(cnt=0;cnt<=OrdersTotal();cnt++)   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic) {
         if(OrderType()==OP_SELL)   {
            s.ticket=OrderTicket();
            s++;}
         if(OrderType()==OP_BUY)    {
            b.ticket=OrderTicket();
            b++;} }}}

double LotsOptimized()  {
   double lot;
   int    orders=HistoryTotal();
   int    losses=0;
   lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/Lot.Margin,2);
   if(DecreaseFactor>0) {
      for(int i=orders-1;i>=0;i--)  {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Error in history!"); break; }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL) continue;
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++; }
      if(losses>1) lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,2);   }
   if(lot<0.01) lot=0.01;
return(lot);   }//end LotsOptimized