
#define SIGNAL_NONE 0
#define SIGNAL_BUY   1
#define SIGNAL_SELL  2
#define SIGNAL_CLOSEBUY 3
#define SIGNAL_CLOSESELL 4

extern bool SignalMail           = False;
extern string Choose_EachTickMode= "True=Each Tick, False=Complete Bar";
extern bool EachTickMode         = True;
extern double Lots               = 0.1;
extern int Slippage              = 3;
extern bool UseStopLoss          = False;
extern int StopLoss              = 200;
extern bool UseTakeProfit        = False;
extern int TakeProfit            = 200;
extern bool UseTrailingStop      = False;
extern int TrailingStop          = 100;
extern int MagicNumber           = 26784599;


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
double MA0_0         = iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, Current + 0);  
double MA0_1         = iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, Current + 1); 

double MA1_0         = iMA(NULL, 0, 30, 0, MODE_SMA, PRICE_CLOSE, Current + 0);  
double MA1_1         = iMA(NULL, 0, 30, 0, MODE_SMA, PRICE_CLOSE, Current + 1); 
double MA1_5         = iMA(NULL, 0, 30, 0, MODE_SMA, PRICE_CLOSE, Current + 5);
double MA1_6         = iMA(NULL, 0, 30, 0, MODE_SMA, PRICE_CLOSE, Current + 6);

double MA2_0         = iMA(NULL, 0, 50, 0, MODE_SMA, PRICE_CLOSE, Current + 0);  
double MA2_1         = iMA(NULL, 0, 50, 0, MODE_SMA, PRICE_CLOSE, Current + 1);
double MA2_2         = iMA(NULL, 0, 50, 0, MODE_SMA, PRICE_CLOSE, Current + 2); 

double MA3_0         = iMA(NULL, 0, 100, 0, MODE_SMA, PRICE_CLOSE, Current + 0);  

double AO_0          = iAO(NULL, 0, Current + 0);
double AO_1          = iAO(NULL, 0, Current + 1);

double SAR_0         =iSAR(NULL, 0, 0.01, 0.1, Current + 0);
double SAR_1         =iSAR(NULL, 0, 0.01, 0.1, Current + 1);

double ADX_Plus_DI_0 =iADX(NULL, 0, 14, PRICE_CLOSE, MODE_PLUSDI, Current + 0);
double ADX_Minus_DI_0=iADX(NULL, 0, 14, PRICE_CLOSE, MODE_MINUSDI, Current + 0);
double ADX_Plus_DI_1 =iADX(NULL, 0, 14, PRICE_CLOSE, MODE_PLUSDI, Current + 1);
double ADX_Minus_DI_1=iADX(NULL, 0, 14, PRICE_CLOSE, MODE_MINUSDI, Current + 1);

double MA_Buy        = MA1_0 > MA2_0 && MA2_0 > MA3_0 && MA1_0 > MA1_5 && MA1_1 > MA1_6 && MA2_0 > MA2_1 && MA2_1 > MA2_2 && Close[0] > MA3_0 && Close[0] > MA2_0 && MA0_0 > MA1_0 && MA0_1 > MA1_1 && SAR_0 > MA3_0;
//double MA_Buy        = MA1_0 > MA2_0 && MA2_0 > MA3_0 && MA1_0 > MA1_5 && MA1_1 > MA1_6 && MA2_0 > MA2_1 && MA2_1 > MA2_2 && Close[0] > MA3_0 && Close[0] > MA2_0 && MA0_0 > MA1_0 && MA0_1 > MA1_1;
double AO_Buy        = AO_0 > 0.0 && AO_1 > 0.0;
double SAR_Buy       = SAR_0 < Low[0] && SAR_1 < Low[1];
double ADX_Buy       = ADX_Plus_DI_0 > ADX_Minus_DI_0 && ADX_Plus_DI_1 > ADX_Minus_DI_1;

double MA_Sell       = MA1_0 < MA2_0 && MA2_0 < MA3_0 && MA1_0 < MA1_5 && MA1_1 < MA1_6 && MA2_0 < MA2_1 && MA2_1 < MA2_2 && Close[0] < MA3_0 && Close[0] < MA2_0 && MA0_0 < MA1_0 && MA0_1 < MA1_1 && SAR_0 < MA3_0;
//double MA_Sell       = MA1_0 < MA2_0 && MA2_0 < MA3_0 && MA1_0 < MA1_5 && MA1_1 < MA1_6 && MA2_0 < MA2_1 && MA2_1 < MA2_2 && Close[0] < MA3_0 && Close[0] < MA2_0 && MA0_0 < MA1_0 && MA0_1 < MA1_1;
double AO_Sell       = AO_0 < 0.0 && AO_1 < 0.0;
double SAR_Sell      = SAR_0 > High[0] && SAR_1 > High[1];
double ADX_Sell      = ADX_Plus_DI_0 < ADX_Minus_DI_0 && ADX_Plus_DI_1 < ADX_Minus_DI_1;


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

                     if (MA1_0 < MA2_0 || MA0_0 < MA2_0 || Bid < MA3_0) Order = SIGNAL_CLOSEBUY;


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

            //+------------------------------------------------------------------+
            //| Signal Begin(Exit Sell)                                          |
            //+------------------------------------------------------------------+

                     if (MA1_0 > MA2_0 || MA0_0 > MA2_0 || Ask > MA3_0) Order = SIGNAL_CLOSESELL;


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

   //+------------------------------------------------------------------+
   //| Signal Begin(Entry)                                              |
   //+------------------------------------------------------------------+

   if (MA_Buy && AO_Buy && SAR_Buy && ADX_Buy ) Order = SIGNAL_BUY;

   if (MA_Sell && AO_Sell && SAR_Sell && ADX_Sell) Order = SIGNAL_SELL;         
   

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

         if (UseStopLoss) StopLossLevel = Ask - StopLoss * Point; else StopLossLevel = 0.0;
         if (UseTakeProfit) TakeProfitLevel = Ask + TakeProfit * Point; else TakeProfitLevel = 0.0;

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

         if (UseStopLoss) StopLossLevel = Bid + StopLoss * Point; else StopLossLevel = 0.0;
         if (UseTakeProfit) TakeProfitLevel = Bid - TakeProfit * Point; else TakeProfitLevel = 0.0;

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