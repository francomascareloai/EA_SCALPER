
#define SIGNAL_NONE 0
#define SIGNAL_BUY   1
#define SIGNAL_SELL  2
#define SIGNAL_CLOSEBUY 3
#define SIGNAL_CLOSESELL 4

#property copyright "Matt Edmonds"


extern int MagicNumber = 0;
extern bool SignalMail = False;
extern bool EachTickMode = True;
extern double Lots = 0.1;
extern int Slippage = 3;
extern bool StopLossMode = True;
extern int StopLoss = 60;
extern bool TakeProfitMode = True;
extern int TakeProfit = 200;
extern bool TrailingStopMode = True;
extern int TrailingStop = 50;

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

double Var1 = iStochastic(NULL, 0, 4, 1, 3, MODE_SMA, 0, MODE_MAIN, Current + 0);
double Var2 = iStochastic(NULL, 0, 4, 1, 3, MODE_SMA, 0, MODE_MAIN, Current + 1);
double Var3 = iStochastic(NULL, 0, 20, 1, 3, MODE_SMA, 0, MODE_MAIN, Current + 0);
double Var4 = iStochastic(NULL, 0, 20, 1, 3, MODE_SMA, 0, MODE_MAIN, Current + 1);
double Var5 = iStochastic(NULL, 0, 50, 1, 3, MODE_SMA, 0, MODE_MAIN, Current + 0);

double Buy1_1 =  Var3 ;
double Buy1_2 = 50;
double Buy2_1 =  Var1 ;
double Buy2_2 = 20;
double Buy3_1 =  Var2  -  Var1 ;
double Buy3_2 =  Var4  -  Var3 ;
double Buy4_1 =   Var3 -3;
double Buy4_2 =  Var5 ;
double Buy5_1 = iMA(NULL, PERIOD_D1, 14, 0, MODE_EMA, PRICE_CLOSE, Current + 0);
double Buy5_2 = iMA(NULL, PERIOD_D1, 14, 0, MODE_EMA, PRICE_CLOSE, Current + 1);
double Buy6_1 = iHigh(NULL, 0, Current + 0);
double Buy6_2 = iBands(NULL, 0, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, Current + 0);

double Sell1_1 =  Var1 ;
double Sell1_2 = 80;
double Sell2_1 =  Var3 ;
double Sell2_2 = 50;
double Sell3_1 =  Var2  -  Var1 ;
double Sell3_2 =  Var4  -  Var3 ;
double Sell4_1 =  Var3 +3;
double Sell4_2 =  Var5 ;
double Sell5_1 = iMA(NULL, PERIOD_D1, 14, 0, MODE_EMA, PRICE_CLOSE, Current + 0);
double Sell5_2 = iMA(NULL, PERIOD_D1, 14, 0, MODE_EMA, PRICE_CLOSE, Current + 1);
double Sell6_1 = iLow(NULL, 0, Current + 0);
double Sell6_2 = iBands(NULL, 0, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, Current + 0);

double CloseBuy1_1 =  Var1 ;
double CloseBuy1_2 = 80;
double CloseBuy2_1 = iHigh(NULL, 0, Current + 0);
double CloseBuy2_2 = iBands(NULL, 0, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, Current + 0);

double CloseSell1_1 =  Var1 ;
double CloseSell1_2 = 20;
double CloseSell2_1 = iLow(NULL, 0, Current + 0);
double CloseSell2_2 = iBands(NULL, 0, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, Current + 0);

   
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

            //+------------------------------------------------------------------+
            //| Signal Begin(Exit Buy)                                           |
            //+------------------------------------------------------------------+

                     if (CloseBuy1_1 > CloseBuy1_2 || CloseBuy2_1 > CloseBuy2_2) Order = SIGNAL_CLOSEBUY;


            //+------------------------------------------------------------------+
            //| Signal End(Exit Buy)                                             |
            //+------------------------------------------------------------------+

            if (Order == SIGNAL_CLOSEBUY && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
               OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, MediumSeaGreen);
               if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + " Close Buy");
               if (!EachTickMode) BarCount = Bars;
               IsTrade = False;
               continue;
            }
            //Trailing stop
            if(TrailingStopMode && TrailingStop > 0) {                 
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

            //+------------------------------------------------------------------+
            //| Signal Begin(Exit Sell)                                          |
            //+------------------------------------------------------------------+

                     if (CloseSell1_1 < CloseSell1_2 || CloseSell2_1 < CloseSell2_2) Order = SIGNAL_CLOSESELL;


            //+------------------------------------------------------------------+
            //| Signal End(Exit Sell)                                            |
            //+------------------------------------------------------------------+

            if (Order == SIGNAL_CLOSESELL && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
               OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, DarkOrange);
               if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + " Close Sell");
               if (!EachTickMode) BarCount = Bars;
               IsTrade = False;
               continue;
            }
            //Trailing stop
            if(TrailingStopMode && TrailingStop > 0) {                 
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

   //+------------------------------------------------------------------+
   //| Signal Begin(Entry)                                              |
   //+------------------------------------------------------------------+

   if (Buy1_1 > Buy1_2 && Buy2_1 < Buy2_2 && Buy3_1 > Buy3_2 && Buy4_1 <= Buy4_2 && Buy5_1 > Buy5_2 && Buy6_1 < Buy6_2) Order = SIGNAL_BUY;

   if (Sell1_1 > Sell1_2 && Sell2_1 < Sell2_2 && Sell3_1 < Sell3_2 && Sell4_1 >= Sell4_2 && Sell5_1 < Sell5_2 && Sell6_1 > Sell6_2) Order = SIGNAL_SELL;


   //+------------------------------------------------------------------+
   //| Signal End                                                       |
   //+------------------------------------------------------------------+

   //Buy
   if (Order == SIGNAL_BUY && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
      if(!IsTrade) {
         //Check free margin
         if (AccountFreeMargin() < (1000 * Lots)) {
            Print("We have no money. Free Margin = ", AccountFreeMargin());
            return(0);
         }

         if (StopLossMode) StopLossLevel = Ask - StopLoss * Point; else StopLossLevel = 0.0;
         if (TakeProfitMode) TakeProfitLevel = Ask + TakeProfit * Point; else TakeProfitLevel = 0.0;

         Ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, StopLossLevel, TakeProfitLevel, "Buy(#" + MagicNumber + ")", MagicNumber, 0, DodgerBlue);
         if(Ticket > 0) {
            if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) {
				Print("BUY order opened : ", OrderOpenPrice());
                if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + " Open Buy");
			} else {
				Print("Error opening BUY order : ", GetLastError());
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
            Print("We have no money. Free Margin = ", AccountFreeMargin());
            return(0);
         }

         if (StopLossMode) StopLossLevel = Bid + StopLoss * Point; else StopLossLevel = 0.0;
         if (TakeProfitMode) TakeProfitLevel = Bid - TakeProfit * Point; else TakeProfitLevel = 0.0;

         Ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, StopLossLevel, TakeProfitLevel, "Sell(#" + MagicNumber + ")", MagicNumber, 0, DeepPink);
         if(Ticket > 0) {
            if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) {
				Print("SELL order opened : ", OrderOpenPrice());
                if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + " Open Sell");
			} else {
				Print("Error opening SELL order : ", GetLastError());
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