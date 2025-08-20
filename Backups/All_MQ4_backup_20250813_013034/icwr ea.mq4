//+------------------------------------------------------------------+
//|                                                       icwr.mq4 |
//|                 Copyright © 2006, tageiger aka fxid10t@yahoo.com |
//|                                        http://www.metatrader.org |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, tageiger aka fxid10t@yahoo.com"
#property link      "http://www.metatrader.org"

extern double     MaximumRisk       =0.02;   //%account balance to risk per position
extern double     DecreaseFactor    =3;      //lot size divisor(reducer) during loss streak
extern double     Lot.Margin        =50;     //Margin for 1 lot   

extern int        Magic             =69;
extern string     comment           ="m icwr ea";

double   spread;  spread      =Ask-Bid;
int      slip;    slip        =spread/Point;

int RequiredWaveHeight,b,s,cnt,b.ticket,s.ticket;
double rsi,SL,ICWR,ICWRv0,awp1,awp2,active.high,active.low,high.c,high.r,low.r,low.c;
datetime awt1,awt2,a.high.shift,a.low.shift,shift;

int init(){return(0);}
int deinit(){return(0);}
int start(){

   PosCounter();  
   rsi=iRSI(Symbol(),1440,14,PRICE_CLOSE,0);
   
   if(Period()==5) {RequiredWaveHeight=40;SL=50*Point;} 
   if(Period()==240) {RequiredWaveHeight=150;SL=100*Point;}
   ICWR=iCustom(Symbol(),Period(),"ICWR",10,5,3,RequiredWaveHeight,0,0);
   ICWRv0=iCustom(Symbol(),Period(),"ICWR v0","ZigZag",10,5,3,"ActiveWave",50,RequiredWaveHeight,0,0);

   awt1=ObjectGet("Activewave",OBJPROP_TIME1);
   awp1=ObjectGet("Activewave",OBJPROP_PRICE1);
   awt2=ObjectGet("Activewave",OBJPROP_TIME2);
   awp2=ObjectGet("Activewave",OBJPROP_PRICE2);
   
   if(awp1>awp2)  {
      active.high=awp1;
      a.high.shift=iBarShift(Symbol(),Period(),awt1);
      active.low=awp2;
      a.low.shift=iBarShift(Symbol(),Period(),awt2);}
   else  {
      active.high=awp2;
      a.high.shift=iBarShift(Symbol(),Period(),awt2);
      active.low=awp1;
      a.low.shift=iBarShift(Symbol(),Period(),awt1);}

   if(a.high.shift<a.low.shift) shift=a.high.shift;
   else shift=a.low.shift;

   high.c=NormalizeDouble(active.low+((active.high-active.low)*0.75),Digits);
   high.r=NormalizeDouble(active.low+((active.high-active.low)*0.618),Digits);
   low.r=NormalizeDouble(active.low+((active.high-active.low)*0.382),Digits);
   low.c=NormalizeDouble(active.low+((active.high-active.low)*0.25),Digits);

   if(rsi>50)  {
      for(int i=0;i<shift;i++)   {
         if(Close[i]<high.r && Close[i]>low.r && Low[1]>high.c && b==0) {
            b.ticket=OrderSend(Symbol(),
                              OP_BUY,
                              LotsOptimized(),
                              Ask,
                              slip,
                              Ask-SL,
                              0,
                              Period()+comment,
                              Magic,0,Blue);
                              if(b.ticket>0)   {
                                 if(OrderSelect(b.ticket,SELECT_BY_TICKET,MODE_TRADES))
                                       {   Print(b.ticket);   }
                                 else Print("Error Opening BuyStop Order: ",GetLastError());
                              return(0);}}}}

   if(rsi<50 && rsi>0)  {
      for(int ii=0;ii<shift;ii++)   {
         if(Close[ii]<high.r && Close[ii]>low.r && High[1]<low.c && s==0)  {
            s.ticket=OrderSend(Symbol(),
                              OP_SELL,
                              LotsOptimized(),
                              Bid,
                              slip,
                              Bid+SL,
                              0,
                              Period()+comment,
                              Magic,0,Orange);
                              if(s.ticket>0)   {
                                 if(OrderSelect(s.ticket,SELECT_BY_TICKET,MODE_TRADES))
                                     {   Print(s.ticket);   }
                                 else Print("Error Opening SellStop Order: ",GetLastError());
                              return(0);}}}}

   if(b>0)  {
      for(int c=0;c<shift;c++)   {
         if(High[1]<low.c) { 
            OrderClose(b.ticket,OrderLots(),Bid,slip,0);}}}

   if(s>0)  {
      for(int cc=0;cc<shift;cc++)   {
         if(Low[1]>high.c) { 
            OrderClose(s.ticket,OrderLots(),Ask,slip,0);}}}

   comments();

return(0);}
//+---------------------------FUNCTIONS------------------------------+
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

void comments()   {

if(MarketInfo(Symbol(),MODE_SWAPLONG)>0) string swap="longs.";
else swap="shorts.";
if(MarketInfo(Symbol(),MODE_SWAPLONG)<0 && MarketInfo(Symbol(),MODE_SWAPSHORT)<0) swap="your broker. :(";

   Comment("Last Tick: ",TimeToStr(CurTime(),TIME_DATE|TIME_SECONDS),"\n",
           "Swap favors ",swap,"\n",
           "Daily RSI= ",rsi,"\n",
           "Active High: ",active.high,"\n",
           "High shift: ",a.high.shift,"\n",
           "High Confirm: ",high.c,"\n",
           "High Retrace: ",high.r,"\n",
           "Low Retrace: ",low.r,"\n",
           "Low Confirm: ",low.c,"\n",
           "Active Low: ",active.low,"\n",
           "Low shift: ",a.low.shift,"\n",
           "Open Ticket #",b.ticket," ",s.ticket);  }

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