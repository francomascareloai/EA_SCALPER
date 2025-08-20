//+------------------------------------------------------------------+
//|                                                      { PerfomA } |
//|                                              perfoma@hotmail.com |
//|##################################################################|
//|                              Fx Hesap Yönetimi && Signal Servisi | 
//|                                            Tel : 0 534 443 97 43 |
//|##################################################################|
//|##################################################################|
//|########################### { PerfomA } ##########################|
//+------------------- http://www.fx.gen.tr -------------------------+

#define SIGNAL_NONE 0
#define SIGNAL_BUY   1
#define SIGNAL_SELL  2
#define SIGNAL_CLOSEBUY 3
#define SIGNAL_CLOSESELL 4

#property copyright "ÜMÝT TERZÝ"
#property link      "http://www.fx.gen.tr"

extern int MagicNumber = 0;
extern bool SignalMail = False;
extern bool EachTickMode = True;
extern double Lots = 0.1;
extern int BarSayýsý = 5;
extern int KapaBarSayýsý = 5;
extern int Slippage = 0;
extern bool UseStopLoss = True;
extern int StopLoss = 0;
extern bool UseTakeProfit = True;
extern int TakeProfit = 350;
extern bool UseTrailingStop = True;
extern int TrailingStop = 200; // PARÝTE 4 DIGIT ÝSE 30, EÐER PARITE 5 DIGIT 300 YAZARSANIZ TOPLAM = 30 PÝPS DEMEKTÝR.

int BarCount;
int Current;
bool TickCheck = False;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() {
   BarCount = Bars;

   if (EachTickMode) Current = 0; else Current = 1;

   return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() {
   return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start() {
   int Order = SIGNAL_NONE;
   int Total, Ticket;
   double StopLossLevel, TakeProfitLevel;



   if (EachTickMode && Bars != BarCount) TickCheck = False;
   Total = OrdersTotal();
   Order = SIGNAL_NONE;

   //+------------------------------------------------------------------+
   //| Variable Begin                                                   |
   //+------------------------------------------------------------------+

double Var1 = iEnvelopes(NULL, 1, 120, MODE_EMA, 0, PRICE_MEDIAN, 0.02, MODE_UPPER,0); 
double Var2 = iEnvelopes(NULL, 1, 120, MODE_EMA, 0, PRICE_MEDIAN, 0.02, MODE_LOWER,0); 
double Var3 = iEnvelopes(NULL, 1, 34, MODE_EMA, 0, PRICE_MEDIAN, 0.21, MODE_UPPER,0); 
double Var4 = iEnvelopes(NULL, 1, 34, MODE_EMA, 0, PRICE_MEDIAN, 0.21, MODE_LOWER,0); 

double A1 = Close[0];

double Y1 =  High[iHighest(NULL,1,MODE_HIGH,BarSayýsý,1)];// LONG AÇMA LÝMÝTÝ
double Y2 =  High[iHighest(NULL,1,MODE_HIGH,KapaBarSayýsý,1)]; //SHORT KAPAMA LÝMÝTÝ

double D1 =  Low[iLowest(NULL,1,MODE_LOW,BarSayýsý,1)];// SHORT AÇMA LÝMÝTÝ
double D2 =  Low[iLowest(NULL,1,MODE_LOW,KapaBarSayýsý,1)];// LONG KAPAMA LÝMÝTÝ
  //  if ( A1 > Y1 && A1 > Var1 ) Order=SIGNAL_BUY;
  //  if ( A1 < D1 && A1 < Var2 )Order=SIGNAL_SELL;


   
   //+------------------------------------------------------------------+
   //| Variable End                                                     |
   //+------------------------------------------------------------------+

   //Check position
   bool IsTrade = False;

   for (int i = 0; i < Total; i ++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderType() <= OP_SELL &&  OrderSymbol() == Symbol()) {
         IsTrade = True;
         if(OrderType() == OP_BUY) {
            //Close

            if ( A1 < D1 ) Order = SIGNAL_CLOSEBUY;
            if ( A1 < Var2 )Order=SIGNAL_CLOSEBUY;

            if (Order == SIGNAL_CLOSEBUY && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
               OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, MediumSeaGreen);
               if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + " Close Buy");
               if (!EachTickMode) BarCount = Bars;
               IsTrade = False;
               continue;
            }
            //Trailing stop
            if(UseTrailingStop && TrailingStop > 0) {                 
               if(Bid - OrderOpenPrice() > Point * TrailingStop) {
                  if(OrderStopLoss() < Bid - Point * TrailingStop) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), Bid - Point * TrailingStop, OrderTakeProfit(), 0, MediumSeaGreen);
                     if (!EachTickMode) BarCount = Bars;
                     continue;
                  }
               }
            }
         } else {
            //Close
                     if ( A1 > Y1 )Order=SIGNAL_CLOSESELL;
                     if ( A1 > Var1 )Order=SIGNAL_CLOSESELL;
            if (Order == SIGNAL_CLOSESELL && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
               OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, DarkOrange);
               if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + " Close Sell");
               if (!EachTickMode) BarCount = Bars;
               IsTrade = False;
               continue;
            }
            //Trailing stop
            if(UseTrailingStop && TrailingStop > 0) {                 
               if((OrderOpenPrice() - Ask) > (Point * TrailingStop)) {
                  if((OrderStopLoss() > (Ask + Point * TrailingStop)) || (OrderStopLoss() == 0)) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), Ask + Point * TrailingStop, OrderTakeProfit(), 0, DarkOrange);
                     if (!EachTickMode) BarCount = Bars;
                     continue;
                  }
               }
            }
         }
      }
   }

   if ( A1 > Y1 && A1 > Var1 ) Order=SIGNAL_BUY;
   if ( A1 < D1 && A1 < Var2 )Order=SIGNAL_SELL;
   if (Order == SIGNAL_BUY && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
      if(!IsTrade) {
         //Check free margin
         if (AccountFreeMargin() < (1000 * Lots)) {
            Print("Paranýz Yetersiz = ", AccountFreeMargin());
            return(0);
         }

         if (UseStopLoss) StopLossLevel = Var2 - StopLoss * Point; else StopLossLevel =0;
         if (UseTakeProfit) TakeProfitLevel = Var3 + TakeProfit * Point; else TakeProfitLevel =0;

         Ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, StopLossLevel, TakeProfitLevel, "Buy(#" + MagicNumber + ")", MagicNumber, 0, DodgerBlue);
         if(Ticket > 0) {
            if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) {
				Print("BUY Poz Açýldý: ", OrderOpenPrice());
                if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + " Open Buy");
			} else {
				Print("Pozisyon Açma Hatasý : ", GetLastError());
			}
         }
         if (EachTickMode) TickCheck = True;
         if (!EachTickMode) BarCount = Bars;
         return(0);
      }
   }

   //Sell
   if (Order == SIGNAL_SELL && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
      if(!IsTrade) {
         //Check free margin
         if (AccountFreeMargin() < (1000 * Lots)) {
            Print("Paranýz Yetersiz ", AccountFreeMargin());
            return(0);
         }

         if (UseStopLoss) StopLossLevel = Var1 + StopLoss * Point; else StopLossLevel = 0;
         if (UseTakeProfit) TakeProfitLevel = Var4 - TakeProfit * Point; else TakeProfitLevel =0;

         Ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, StopLossLevel, TakeProfitLevel, "Sell(#" + MagicNumber + ")", MagicNumber, 0, DeepPink);
         if(Ticket > 0) {
            if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) {
				Print("SELL Poz Açýldý: ", OrderOpenPrice());
                if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + " Open Sell");
			} else {
				Print("Pozisyon Açma Hatasý : ", GetLastError());
			}
         }
         if (EachTickMode) TickCheck = True;
         if (!EachTickMode) BarCount = Bars;
         return(0);
      }
   }

   if (!EachTickMode) BarCount = Bars;

   return(0);
}
//+------------------------------------------------------------------+