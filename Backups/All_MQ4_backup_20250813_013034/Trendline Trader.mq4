//+------------------------------------------------------------------+
//|                                             Trendline Trader.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//+------------------------------------------------------------------+
//|                        SMC Trader Manual with seperation         |
//+------------------------------------------------------------------+
//|DO NOT ENABLE THIS EA WITHOUT READING THIS FIRST....
//|
//|This EA will put 12 trendlines(TL) on the chart it is attached to.
//|3 TL's for a Simulated Buystop entry, TP & SL, 3 for SellStop, 3 
//|for Buylimit, & 3 for SellLimit.  Use the STOP TLs for pattern breakouts,
//|ie, the ea will buy(sell) on a close above(below) these TLs.  Use the LIMIT
//|TLs for Channels, ie, the ea will buy(sell) when price touches these TLs.
//|Put BuyLimit at the bottom of the channel, triangle or wedge, and
//|SellLimit at the top, to trade inside of the pattern.
//|
//|IF YOU ARE USING EA'S, YOU SHOULD BE AT LEAST FAMILIAR WITH THE CODE.
//|BROWSE THROUGH THE CODE, AND GET FAMILIAR WITH HOW THIS EA IS STRUCTURED,
//|AND HOW IT SHOULD LOGICALLY OPERATE BEFORE APPLYING TO A REAL MONEY ACCOUNT.
//|
//|IT WAS NOT STEVE'S ORIGIONAL INTENT THAT THIS BE A LIVE TRADING EA.
//+------------------------------------------------------------------+

#property copyright  "steve.cartwright@homecall.co.uk"//originator
#property copyright  "tageiger fxid10t@yahoo.com" //modifier
#property link       "http://www.metaquotes.net"
#property link       "http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/"
#property link       "http://www.forexnews.com"

extern bool    AllowLiveTrade    =false;//true allows orders to be placed
extern bool    StopOrderTLs      =false;//true allows stoporder trendlines to be plotted
extern bool    LimitOrderTLs     =false;//true allows limitorder trendlines to be plotted
extern double  Lots              =0.1;
extern double  MaximumRisk       =0.02;
extern double  DecreaseFactor    =3;
extern double  Slippage          =3;


//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot=Lots;
   int    orders=HistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
//---- select lot size
   lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);
//---- calcuulate number of losses orders without a break
   if(DecreaseFactor>0)
     {
      for(int i=orders-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Error in history!"); break; }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL) continue;
         //----
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
        }
      if(losses>1) lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
     }
//---- return lot size
   if(lot<0.1) lot=0.1;
   return(lot);
   }

int init() {

if(StopOrderTLs) {
//######################  STOP ORDER TREND LINES  ##################### 
ObjectCreate("BuyStop", OBJ_TREND, 0, CurTime()-(Period()*60*30), High[Highest(NULL,0,MODE_HIGH,10,1)]+5*Point,CurTime(),High[Highest(NULL,0,MODE_HIGH,10,1)]+5*Point);
ObjectSet("BuyStop",6,LimeGreen);
ObjectSet("BuyStop",7,STYLE_DOT);
ObjectSet("BuyStop",10,0);
ObjectSetText("BuyStop","BuyStop");

ObjectCreate("SellStop", OBJ_TREND, 0, CurTime()-(Period()*60*30), Low[Lowest(NULL,0,MODE_LOW,10,1)]-5*Point,CurTime(),Low[Lowest(NULL,0,MODE_LOW,10,1)]-5*Point);
ObjectSet("SellStop",6,HotPink);
ObjectSet("SellStop",7,STYLE_DOT);
ObjectSet("SellStop",10,0);
ObjectSetText("SellStop","SellStop");

ObjectCreate("BuyStopSL", OBJ_TREND, 0, CurTime()-(Period()*60*30), High[Highest(NULL,0,MODE_HIGH,10,1)],CurTime(),High[Highest(NULL,0,MODE_HIGH,10,1)]);
ObjectSet("BuyStopSL",6,Blue);
ObjectSet("BuyStopSL",7,STYLE_DOT);
ObjectSet("BuyStopSL",10,0);
ObjectSetText("BuyStopSL","BuyStopSL");

ObjectCreate("SellStopSL", OBJ_TREND, 0, CurTime()-(Period()*60*30), Low[Lowest(NULL,0,MODE_LOW,10,1)],CurTime(),Low[Lowest(NULL,0,MODE_LOW,10,1)]);
ObjectSet("SellStopSL",6,FireBrick);
ObjectSet("SellStopSL",7,STYLE_DOT);
ObjectSet("SellStopSL",10,0);
ObjectSetText("SellStopSL","SellStopSL");

ObjectCreate("BuyStopTP", OBJ_TREND, 0, CurTime()-(Period()*60*30), High[Highest(NULL,0,MODE_HIGH,10,1)]+10*Point,CurTime(),High[Highest(NULL,0,MODE_HIGH,10,1)]+10*Point);
ObjectSet("BuyStopTP",6,Aqua);
ObjectSet("BuyStopTP",7,STYLE_DOT);
ObjectSet("BuyStopTP",10,0);
ObjectSetText("BuyStopTP","BuyStopTP");

ObjectCreate("SellStopTP", OBJ_TREND, 0, CurTime()-(Period()*60*30), Low[Lowest(NULL,0,MODE_LOW,10,1)]-10*Point,CurTime(),Low[Lowest(NULL,0,MODE_LOW,10,1)]-10*Point);
ObjectSet("SellStopTP",6,Tomato);
ObjectSet("SellStopTP",7,STYLE_DOT);
ObjectSet("SellStopTP",10,0);
ObjectSetText("SellStopTP","SellStopTP");
}//end if(StopOrderTLs)

if(LimitOrderTLs) {
//###########################  LIMIT ORDER TRENDLINES ######################

ObjectCreate("BuyLimit", OBJ_TREND, 0, CurTime()-(Period()*60*30), Low[Lowest(NULL,0,MODE_LOW,10,1)]-15*Point,CurTime(),Low[Lowest(NULL,0,MODE_LOW,10,1)]-15*Point);
ObjectSet("BuyLimit",6,LightCyan);
ObjectSet("BuyLimit",7,STYLE_SOLID);
ObjectSet("BuyLimit",10,0);
ObjectSetText("BuyLimit","BuyLimit");

ObjectCreate("SellLimit", OBJ_TREND, 0, CurTime()-(Period()*60*30), High[Highest(NULL,0,MODE_HIGH,10,1)]+15*Point,CurTime(),High[Highest(NULL,0,MODE_HIGH,10,1)]+15*Point);
ObjectSet("SellLimit",6,MistyRose);
ObjectSet("SellLimit",7,STYLE_SOLID);
ObjectSet("SellLimit",10,0);
ObjectSetText("SellLimit","SellLimit");

ObjectCreate("BuyLimitSL", OBJ_TREND, 0, CurTime()-(Period()*60*30), Low[Lowest(NULL,0,MODE_LOW,10,1)]-20*Point,CurTime(),Low[Lowest(NULL,0,MODE_LOW,10,1)]-20*Point);
ObjectSet("BuyLimitSL",6,Honeydew);
ObjectSet("BuyLimitSL",7,STYLE_SOLID);
ObjectSet("BuyLimitSL",10,0);
ObjectSetText("BuyLimitSL","BuyLimitSL");

ObjectCreate("SellLimitSL", OBJ_TREND, 0, CurTime()-(Period()*60*30), High[Highest(NULL,0,MODE_HIGH,10,1)]+20*Point,CurTime(),High[Highest(NULL,0,MODE_HIGH,10,1)]+20*Point);
ObjectSet("SellLimitSL",6,LavenderBlush);
ObjectSet("SellLimitSL",7,STYLE_SOLID);
ObjectSet("SellLimitSL",10,0);
ObjectSetText("SellLimitSL","SellLimitSL");

ObjectCreate("BuyLimitTP", OBJ_TREND, 0, CurTime()-(Period()*60*30), High[Highest(NULL,0,MODE_HIGH,10,1)]+25*Point,CurTime(),High[Highest(NULL,0,MODE_HIGH,10,1)]+25*Point);
ObjectSet("BuyLimitTP",6,BlanchedAlmond);
ObjectSet("BuyLimitTP",7,STYLE_SOLID);
ObjectSet("BuyLimitTP",10,0);
ObjectSetText("BuyLimitTP","BuyLimitTP");

ObjectCreate("SellLimitTP", OBJ_TREND, 0, CurTime()-(Period()*60*30), Low[Lowest(NULL,0,MODE_LOW,10,1)]-25*Point,CurTime(),Low[Lowest(NULL,0,MODE_LOW,10,1)]-25*Point);
ObjectSet("SellLimitTP",6,LemonChiffon);
ObjectSet("SellLimitTP",7,STYLE_SOLID);
ObjectSet("SellLimitTP",10,0);
ObjectSetText("SellLimitTP","SellLimitTP");
}//end if(LimitOrderTLs)

Print("Initialising");

return(0);
}//end init

int deinit() { Print("Deinitialising"); return(0); }

int start()
   {

// trendline point to trading variable assignment
   if(StopOrderTLs) {
   double BuyStop   =ObjectGetValueByShift("BuyStop",0);
   double BuyStopSL =ObjectGetValueByShift("BuyStopSL",0);
   double BuyStopTP =ObjectGetValueByShift("BuyStopTP",0);
   double SellStop  =ObjectGetValueByShift("SellStop",0);
   double SellStopSL=ObjectGetValueByShift("SellStopSL",0);
   double SellStopTP=ObjectGetValueByShift("SellStopTP",0);
   double bs;     bs    =NormalizeDouble(BuyStop,4);
   double bssl;   bssl  =NormalizeDouble(BuyStopSL,4);
   double bstp;   bstp  =NormalizeDouble(BuyStopTP,4);
   double ss;     ss    =NormalizeDouble(SellStop,4);
   double sssl;   sssl  =NormalizeDouble(SellStopSL,4);
   double sstp;   sstp  =NormalizeDouble(SellStopTP,4);
   }//end if

   if(LimitOrderTLs) {   
   double BuyLimit   =ObjectGetValueByShift("BuyLimit",0);
   double BuyLimitSL =ObjectGetValueByShift("BuyLimitSL",0);
   double BuyLimitTP =ObjectGetValueByShift("BuyLimitTP",0);
   double SellLimit  =ObjectGetValueByShift("SellLimit",0);
   double SellLimitSL=ObjectGetValueByShift("SellLimitSL",0);
   double SellLimitTP=ObjectGetValueByShift("SellLimitTP",0);
   double bl;     bl    =NormalizeDouble(BuyLimit,4);
   double blsl;   blsl  =NormalizeDouble(BuyLimitSL,4);
   double bltp;   bltp  =NormalizeDouble(BuyLimitTP,4);
   double sl;     sl    =NormalizeDouble(SellLimit,4);
   double slsl;   slsl  =NormalizeDouble(SellLimitSL,4);
   double sltp;   sltp  =NormalizeDouble(SellLimitTP,4);
   }//end if
   
   if(Minute()==0){
      Print(Symbol()," BuyStop:",bs," BuyStopSL:",bssl," BuyStopTP:",bstp,
      " SellStop:",ss," SellStopSL:",sssl," SellStopTP:",sstp);
      Print(" BuyLimit:",bl," BuyLimitSL:",blsl," BuyLimitTP:",bltp,
      " SellLimit:",sl," SellLimitSL:",slsl," SellLimitTP:",sltp);
      }//end if

   if(OrdersTotal()==0) { int BS=0,SS=0,BL=0,SL=0; }
   if(OrdersTotal()>0)  { int cnt,total=OrdersTotal(); 
      for(cnt=0;cnt<total;cnt++) {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
         if(OrderMagicNumber()==11) { BS=OrderTicket(); }
         if(OrderMagicNumber()==22) { SS=OrderTicket(); }
         if(OrderMagicNumber()==33) { BL=OrderTicket(); }
         if(OrderMagicNumber()==44) { SL=OrderTicket(); }
         }//end for
      }//end if

   int ticket;
   if(AllowLiveTrade)   {
      if(StopOrderTLs)     {
         if(BS==0)            {
            ticket=OrderSend(Symbol(),
                              OP_BUYSTOP,
                              LotsOptimized(),
                              bs,
                              Slippage,
                              bssl,
                              bstp,
                              "TL trader buystop",
                              11,
                              0,
                              Green);
                              if(ticket>0)   {
                                 if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))  {
                                    BS=ticket;
                                    Print(ticket); }//end if(OrderSelect
                                 else Print("Error Opening BuyStop Order: ",GetLastError());
                                 return(0);  }//end if(ticket
         }//end if(BS
         if(SS==0)            {
            ticket=OrderSend(Symbol(),
                              OP_SELLSTOP,
                              LotsOptimized(),
                              ss,
                              Slippage,
                              sssl,
                              sstp,
                              "TL trader sellstop",
                              22,
                              0,
                              Red);
                              if(ticket>0)   {
                                 if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))  {
                                    SS=ticket;
                                    Print(ticket); }//end if(OrderSelect
                                 else Print("Error Opening SellStop Order: ",GetLastError());
                                 return(0);  }//end if(ticket
         }//end if(SS
      }//end if(StopOrderTLs)
      if(LimitOrderTLs)    {
         if(BL==0)            {
            ticket=OrderSend(Symbol(),
                              OP_BUYLIMIT,
                              LotsOptimized(),
                              bl,
                              Slippage,
                              blsl,
                              bltp,
                              "TL trader buylimit",
                              33,
                              0,
                              LimeGreen);
                              if(ticket>0)   {
                                 if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))  {
                                    BL=ticket;
                                    Print(ticket); }//end if(OrderSelect
                                 else Print("Error Opening BuyLimit Order: ",GetLastError());
                                 return(0);  }//end if(ticket
         }//end if(BL
         if(SL==0)            {
            ticket=OrderSend(Symbol(),
                              OP_SELLLIMIT,
                              LotsOptimized(),
                              sl,
                              Slippage,
                              slsl,
                              sltp,
                              "TL trader selllimit",
                              44,
                              0,
                              HotPink);
                              if(ticket>0)   {
                                 if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))  {
                                    SL=ticket;
                                    Print(ticket); }//end if(OrderSelect
                                 else Print("Error Opening SellLimit Order: ",GetLastError());
                                 return(0);  }//end if(ticket
         }//end if(SL
      }//end if(LimitOrderTLs)
   }//end if(AllowLiveTrade)

   for(cnt=0;cnt<total;cnt++) {
//      if(Seconds()<=30) {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
         if(StopOrderTLs)  {
         if(OrderType()==OP_BUYSTOP &&
            OrderMagicNumber()==11 &&
            OrderSymbol()==Symbol())   {
            if(OrderOpenPrice()!=bs)   {
               OrderModify(OrderTicket(),
                           bs,
                           bssl,
                           bstp,
                           0,
                           Green);
                           Sleep(10000);
                           return(0);
            }// end if(OrderOpenPrice      
         }//end if(OrderType
         if(OrderType()==OP_SELLSTOP &&
            OrderMagicNumber()==22 &&
            OrderSymbol()==Symbol())  {
            if(OrderOpenPrice()!=ss)   {
               OrderModify(OrderTicket(),
                           ss,
                           sssl,
                           sstp,
                           0,
                           Red);
                           Sleep(10000);
                           return(0);           
            }//end if(OrderOpenPrice
         }//end if(OrderType
         }//end if(StopOrderTLs
         if(LimitOrderTLs)   {
         if(OrderType()==OP_BUYLIMIT &&
            OrderMagicNumber()==33 &&
            OrderSymbol()==Symbol())  {
            if(OrderOpenPrice()!=bl)   {
               OrderModify(OrderTicket(),
                           bl,
                           blsl,
                           bltp,
                           0,
                           LimeGreen);
                           return(0);            
            }//end if(OrderOpenPrice
         }//end if(OrderType
         if(OrderType()==OP_SELLLIMIT &&
            OrderMagicNumber()==44 &&
            OrderSymbol()==Symbol())  {
            if(OrderOpenPrice()!=sl)   {
               OrderModify(OrderTicket(),
                           sl,
                           slsl,
                           sltp,
                           0,
                           HotPink);
                           Sleep(10000);
                           return(0);            
            }//end if(OrderOpenPrice
         }//end if(OrderType
         }//end if(LimitOrderTLs
         if(OrderType()==OP_BUY)    {
            if(OrderMagicNumber()==11 &&
               OrderSymbol()==Symbol())    {
               if(OrderStopLoss()!=bssl ||
                  OrderTakeProfit()!=bstp)   {
                     OrderModify(OrderTicket(),
                                 OrderOpenPrice(),
                                 bssl,
                                 bstp,
                                 0,
                                 Green);
                                 return(0);
                  }//end if(OrderStopLoss
            }//end if(OrderMagicNumber
            if(OrderMagicNumber()==33 &&
               OrderSymbol()==Symbol())    {
               if(OrderStopLoss()!=blsl ||
                  OrderTakeProfit()!=bltp)   {
                     OrderModify(OrderTicket(),
                                 OrderOpenPrice(),
                                 blsl,
                                 bltp,
                                 0,
                                 LimeGreen);
                                 Sleep(10000);
                                 return(0);
                  }//end if(OrderStopLoss
            }//end if(OrderMagicNumber
         }//end if(OrderType
         if(OrderType()==OP_SELL)   {
            if(OrderMagicNumber()==22 &&
               OrderSymbol()==Symbol())    {
               if(OrderStopLoss()!=sssl ||
                  OrderTakeProfit()!=sstp)   {
                     Print(sssl," ",sstp);
                     OrderModify(OrderTicket(),
                                 OrderOpenPrice(),
                                 sssl,
                                 sstp,
                                 0,
                                 Red);
                                 Sleep(10000);
                                 return(0);
                  }//end if(OrderStopLoss
            }//end if(OrderMagicNumber
            if(OrderMagicNumber()==44 &&
               OrderSymbol()==Symbol())    {
               if(OrderStopLoss()!=slsl ||
                  OrderTakeProfit()!=sltp)   {
                     OrderModify(OrderTicket(),
                                 OrderOpenPrice(),
                                 slsl,
                                 sltp,
                                 0,
                                 HotPink);
                                 Sleep(10000);
                                 return(0);
                  }//end if(OrderStopLoss
            }//end if(OrderMagicNumber
         }//end if(OrderType   
      OrderSelect(BS,SELECT_BY_TICKET);
      if(OrderClosePrice()>0) {BS=0;}
      OrderSelect(SS,SELECT_BY_TICKET);
      if(OrderClosePrice()>0) {SS=0;}
      OrderSelect(BL,SELECT_BY_TICKET);
      if(OrderClosePrice()>0) {BL=0;}
      OrderSelect(SL,SELECT_BY_TICKET);
      if(OrderClosePrice()>0) {SL=0;}
//   }//end if(Seconds
   }//end for
return(0);
}//end start


