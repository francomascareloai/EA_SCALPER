//+------------------------------------------------------------------+
//|                                             Trendline Trader.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, tageiger aka fxid10t@yahoo.com"
#property link      "http://www.metaquotes.net"

extern bool    AllowLiveTrade                =false;//true allows orders to be placed
extern bool    Plot.Stop.Order.TrendLines    =false;//true allows stop order trendlines to be plotted
extern bool    Plot.Limit.Order.TrendLines   =false;//true allows limit order trendlines to be plotted

extern bool    Use.Money.Mgt                 =false;//if false, uses Minimum.Lot
extern double  Minimum.Lot                   =1.00; //Smallest lot size to trade, Use.MM true or false
extern double  MaximumRisk                   =0.02; //%account balance to risk per position
extern double  DecreaseFactor                =2;    //lot size divisor(reducer) during loss streak
extern double  Lot.Margin                    =50;   //Margin required to trade 1 lot

string         TradeSymbol;
int            total,cnt;
double         bs,bssl,bstp,ss,sssl,sstp,bl,blsl,bltp,sl,slsl,sltp,Slippage;

int init() {

if(Plot.Stop.Order.TrendLines) {
//######################  STOP ORDER TREND LINES  ##################### 
ObjectCreate("BuyStop", OBJ_TREND, 0, Time[144], Close[0]+30*Point,Time[0],Close[0]+30*Point);
ObjectSet("BuyStop",6,LimeGreen);
ObjectSet("BuyStop",7,STYLE_SOLID);
ObjectSet("BuyStop",10,0);
ObjectSetText("BuyStop","BuyStop");

ObjectCreate("SellStop", OBJ_TREND, 0, Time[144], Close[0]-30*Point,Time[0],Close[0]-30*Point);
ObjectSet("SellStop",6,HotPink);
ObjectSet("SellStop",7,STYLE_SOLID);
ObjectSet("SellStop",10,0);
ObjectSetText("SellStop","SellStop");

ObjectCreate("BuyStopSL", OBJ_TREND, 0, Time[144], Close[0]+15*Point,Time[0],Close[0]+15*Point);
ObjectSet("BuyStopSL",6,Blue);
ObjectSet("BuyStopSL",7,STYLE_SOLID);
ObjectSet("BuyStopSL",10,0);
ObjectSetText("BuyStopSL","BuyStopSL");

ObjectCreate("SellStopSL", OBJ_TREND, 0, Time[144], Close[0]-15*Point,Time[0],Close[0]-15*Point);
ObjectSet("SellStopSL",6,FireBrick);
ObjectSet("SellStopSL",7,STYLE_SOLID);
ObjectSet("SellStopSL",10,0);
ObjectSetText("SellStopSL","SellStopSL");

ObjectCreate("BuyStopTP", OBJ_TREND, 0, Time[144], Close[0]+45*Point,Time[0],Close[0]+45*Point);
ObjectSet("BuyStopTP",6,Aqua);
ObjectSet("BuyStopTP",7,STYLE_SOLID);
ObjectSet("BuyStopTP",10,0);
ObjectSetText("BuyStopTP","BuyStopTP");

ObjectCreate("SellStopTP", OBJ_TREND, 0, Time[144], Close[0]-45*Point,Time[0],Close[0]-45*Point);
ObjectSet("SellStopTP",6,Tomato);
ObjectSet("SellStopTP",7,STYLE_SOLID);
ObjectSet("SellStopTP",10,0);
ObjectSetText("SellStopTP","SellStopTP");
}//end if(Plot.Stop.Order.TrendLines)

if(Plot.Limit.Order.TrendLines) {
//###########################  LIMIT ORDER TRENDLINES ######################

ObjectCreate("BuyLimit", OBJ_TREND, 0, Time[144], Close[0]-30*Point,Time[0],Close[0]-30*Point);
ObjectSet("BuyLimit",6,LightCyan);
ObjectSet("BuyLimit",7,STYLE_SOLID);
ObjectSet("BuyLimit",10,0);
ObjectSetText("BuyLimit","BuyLimit");

ObjectCreate("SellLimit", OBJ_TREND, 0, Time[144], Close[0]+30*Point,Time[0],Close[0]+30*Point);
ObjectSet("SellLimit",6,MistyRose);
ObjectSet("SellLimit",7,STYLE_SOLID);
ObjectSet("SellLimit",10,0);
ObjectSetText("SellLimit","SellLimit");

ObjectCreate("BuyLimitSL", OBJ_TREND, 0, Time[144], Close[0]-45*Point,Time[0],Close[0]-45*Point);
ObjectSet("BuyLimitSL",6,Honeydew);
ObjectSet("BuyLimitSL",7,STYLE_SOLID);
ObjectSet("BuyLimitSL",10,0);
ObjectSetText("BuyLimitSL","BuyLimitSL");

ObjectCreate("SellLimitSL", OBJ_TREND, 0, Time[144], Close[0]+45*Point,Time[0],Close[0]+45*Point);
ObjectSet("SellLimitSL",6,LavenderBlush);
ObjectSet("SellLimitSL",7,STYLE_SOLID);
ObjectSet("SellLimitSL",10,0);
ObjectSetText("SellLimitSL","SellLimitSL");

ObjectCreate("BuyLimitTP", OBJ_TREND, 0, Time[144], Close[0]-15*Point,Time[0],Close[0]-15*Point);
ObjectSet("BuyLimitTP",6,BlanchedAlmond);
ObjectSet("BuyLimitTP",7,STYLE_SOLID);
ObjectSet("BuyLimitTP",10,0);
ObjectSetText("BuyLimitTP","BuyLimitTP");

ObjectCreate("SellLimitTP", OBJ_TREND, 0, Time[144], Close[0]+15*Point,Time[0],Close[0]+15*Point);
ObjectSet("SellLimitTP",6,LemonChiffon);
ObjectSet("SellLimitTP",7,STYLE_SOLID);
ObjectSet("SellLimitTP",10,0);
ObjectSetText("SellLimitTP","SellLimitTP");
}//end if(Plot.Limit.Order.TrendLines)

Print("Initialising");  return(0);  }//end init

int deinit() { Print("Deinitialising"); return(0); }

int start() {
   TradeSymbol=Symbol();Slippage=Ask-Bid;
// trendline point to trading variable assignment
   if(Plot.Stop.Order.TrendLines) {
   double BuyStop    =ObjectGetValueByShift("BuyStop",0);
   double BuyStopSL  =ObjectGetValueByShift("BuyStopSL",0);
   double BuyStopTP  =ObjectGetValueByShift("BuyStopTP",0);
   double SellStop   =ObjectGetValueByShift("SellStop",0);
   double SellStopSL =ObjectGetValueByShift("SellStopSL",0);
   double SellStopTP =ObjectGetValueByShift("SellStopTP",0);
   double bs;     bs    =NormalizeDouble(BuyStop,Digits);
   double bssl;   bssl  =NormalizeDouble(BuyStopSL,Digits);
   double bstp;   bstp  =NormalizeDouble(BuyStopTP,Digits);
   double ss;     ss    =NormalizeDouble(SellStop,Digits);
   double sssl;   sssl  =NormalizeDouble(SellStopSL,Digits);
   double sstp;   sstp  =NormalizeDouble(SellStopTP,Digits);
   }//end if

   if(Plot.Limit.Order.TrendLines) {   
   double BuyLimit   =ObjectGetValueByShift("BuyLimit",0);
   double BuyLimitSL =ObjectGetValueByShift("BuyLimitSL",0);
   double BuyLimitTP =ObjectGetValueByShift("BuyLimitTP",0);
   double SellLimit  =ObjectGetValueByShift("SellLimit",0);
   double SellLimitSL=ObjectGetValueByShift("SellLimitSL",0);
   double SellLimitTP=ObjectGetValueByShift("SellLimitTP",0);
   double bl;     bl    =NormalizeDouble(BuyLimit,Digits);
   double blsl;   blsl  =NormalizeDouble(BuyLimitSL,Digits);
   double bltp;   bltp  =NormalizeDouble(BuyLimitTP,Digits);
   double sl;     sl    =NormalizeDouble(SellLimit,Digits);
   double slsl;   slsl  =NormalizeDouble(SellLimitSL,Digits);
   double sltp;   sltp  =NormalizeDouble(SellLimitTP,Digits);
   }//end if

   PrintComments();
   
   total=OrdersTotal();
   if(TotalTradesThisSymbol(TradeSymbol)==0) {  int BS=0,SS=0,BL=0,SL=0;   }
   if(TotalTradesThisSymbol(TradeSymbol)>0)  {
      for(cnt=0;cnt<total;cnt++) {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==TradeSymbol) {
            if(OrderMagicNumber()==11) { BS=OrderTicket(); }
            if(OrderMagicNumber()==22) { SS=OrderTicket(); }
            if(OrderMagicNumber()==33) { BL=OrderTicket(); }
            if(OrderMagicNumber()==44) { SL=OrderTicket(); }}}}
            
   int ticket=0;
   if(AllowLiveTrade)   {
      if(Plot.Stop.Order.TrendLines)   {
         if(BS==0)   {
            ticket=OrderSend(Symbol(),OP_BUYSTOP,LotsOptimized(),bs,Slippage,bssl,bstp,
                             "TL trader buystop",11,0,Green);
                             if(ticket>0)   {
                              if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))  {
                                 BS=ticket;  Print(ticket); }
                              else Print("Error Opening BuyStop Order: ",GetLastError());
                              return(0);  }}
         if(SS==0)   {
            ticket=OrderSend(Symbol(),OP_SELLSTOP,LotsOptimized(),ss,Slippage,sssl,sstp,
                             "TL trader sellstop",22,0,Red);
                              if(ticket>0)   {
                                 if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))  {
                                    SS=ticket;  Print(ticket); }
                                 else Print("Error Opening SellStop Order: ",GetLastError());
                                 return(0);  }}}
      if(Plot.Limit.Order.TrendLines)  {
         if(BL==0)   {
            ticket=OrderSend(Symbol(),OP_BUYLIMIT,LotsOptimized(),bl,Slippage,blsl,bltp,
                             "TL trader buylimit",33,0,LimeGreen);
                              if(ticket>0)   {
                                 if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))  {
                                    BL=ticket;  Print(ticket); }
                                 else Print("Error Opening BuyLimit Order: ",GetLastError());
                                 return(0);  }}
         if(SL==0)   {
            ticket=OrderSend(Symbol(),OP_SELLLIMIT,LotsOptimized(),sl,Slippage,slsl,sltp,
                             "TL trader selllimit",44,0,HotPink);
                              if(ticket>0)   {
                                 if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))  {
                                    SL=ticket;  Print(ticket); }
                                 else Print("Error Opening SellLimit Order: ",GetLastError());
                                 return(0);  }}}}

   if(Plot.Stop.Order.TrendLines)  {
      OrderSelect(BS,SELECT_BY_TICKET);
      if(OrderType()==OP_BUYSTOP && OrderOpenPrice()!=bs)   {
         OrderModify(OrderTicket(),bs,bssl,bstp,0,Green);}
      OrderSelect(SS,SELECT_BY_TICKET);
      if(OrderType()==OP_SELLSTOP && OrderOpenPrice()!=bs)   {
         OrderModify(OrderTicket(),ss,sssl,sstp,0,Red);  }  }

   if(Plot.Limit.Order.TrendLines)   {
      OrderSelect(BL,SELECT_BY_TICKET);
      if(OrderType()==OP_BUYLIMIT && OrderOpenPrice()!=bl)   {
         OrderModify(OrderTicket(),bl,blsl,bltp,0,LimeGreen);  }
      OrderSelect(SL,SELECT_BY_TICKET);
      if(OrderType()==OP_SELLLIMIT && OrderOpenPrice()!=sl) {
         OrderModify(OrderTicket(),sl,slsl,sltp,0,HotPink); }  }

   for(cnt=0;cnt<OrdersTotal();cnt++) {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
         if(OrderType()==OP_BUY && OrderSymbol()==Symbol())    {
            if(OrderMagicNumber()==11 && (OrderStopLoss()!=bssl ||   OrderTakeProfit()!=bstp))   {
               OrderModify(OrderTicket(),OrderOpenPrice(),bssl,bstp,0,Green);}
            if(OrderMagicNumber()==33 && (OrderStopLoss()!=blsl || OrderTakeProfit()!=bltp))   {
               OrderModify(OrderTicket(),OrderOpenPrice(),blsl,bltp,0,LimeGreen);}}
         if(OrderType()==OP_SELL && OrderSymbol()==Symbol())   {
            if(OrderMagicNumber()==22 && (OrderStopLoss()!=sssl || OrderTakeProfit()!=sstp))   {
               OrderModify(OrderTicket(),OrderOpenPrice(),sssl,sstp,0,Red);}
            if(OrderMagicNumber()==44 &&  (OrderStopLoss()!=slsl || OrderTakeProfit()!=sltp))   {
               OrderModify(OrderTicket(),OrderOpenPrice(),slsl,sltp,0,HotPink);}}}
  
   OrderSelect(BS,SELECT_BY_TICKET);if(OrderCloseTime()>0) {BS=0;}
   OrderSelect(SS,SELECT_BY_TICKET);if(OrderCloseTime()>0) {SS=0;}
   OrderSelect(BL,SELECT_BY_TICKET);if(OrderCloseTime()>0) {BL=0;}
   OrderSelect(SL,SELECT_BY_TICKET);if(OrderCloseTime()>0) {SL=0;}

return(0);}

//...............Fucntions....................
void PrintComments() {  
   if(Plot.Stop.Order.TrendLines)   {
      Comment("Last Tick: ",TimeToStr(CurTime(),TIME_DATE|TIME_SECONDS),"\n",
              "BuyStop:",bs," BuyStopSL:",bssl," BuyStopTP:",bstp,"\n",
              "SellStop:",ss," SellStopSL:",sssl," SellStopTP:",sstp);  }
   if(Plot.Limit.Order.TrendLines)  {
      Comment("Last Tick: ",TimeToStr(CurTime(),TIME_DATE|TIME_SECONDS),"\n",
              "BuyLimit:",bl," BuyLimitSL:",blsl," BuyLimitTP:",bltp,"\n",
              "SellLimit:",sl," SellLimitSL:",slsl," SellLimitTP:",sltp);  }
   if(Plot.Stop.Order.TrendLines && Plot.Limit.Order.TrendLines)  {
      Comment("Last Tick: ",TimeToStr(CurTime(),TIME_DATE|TIME_SECONDS),"\n",
              "BuyStop:",bs," BuyStopSL:",bssl," BuyStopTP:",bstp,"\n",
              "SellStop:",ss," SellStopSL:",sssl," SellStopTP:",sstp,"\n",
              "BuyLimit:",bl," BuyLimitSL:",blsl," BuyLimitTP:",bltp,"\n",
              "SellLimit:",sl," SellLimitSL:",slsl," SellLimitTP:",sltp);  }
   else Comment("Last Tick: ",TimeToStr(CurTime(),TIME_DATE|TIME_SECONDS));  }
                                
int TotalTradesThisSymbol(string TradeSymbol) {
   int i, TradesThisSymbol=0;
   for(i=0;i<OrdersTotal();i++)  {
      OrderSelect(i,SELECT_BY_POS);
      if(OrderSymbol()==TradeSymbol &&
         OrderMagicNumber()==11 ||
         OrderMagicNumber()==22 || 
         OrderMagicNumber()==33 || 
         OrderMagicNumber()==44)   {  TradesThisSymbol++;  }
   }//end for
return(TradesThisSymbol);
}//end TotalTradesThisSymbol

double LotsOptimized()  {
   double lot;
   int    orders=HistoryTotal();
   int    losses=0;int wins=0;
   lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/Lot.Margin,2);
   if(DecreaseFactor>0) {
      for(int i=orders-1;i>=0;i--)  {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Error in history!"); break; }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL) continue;
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++; }
      if(losses>1) lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,2);}
   if(lot<Minimum.Lot) lot=Minimum.Lot;
   if(Use.Money.Mgt==false)   {lot=Minimum.Lot;}
return(lot);   }//end LotsOptimized


