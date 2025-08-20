//+------------------------------------------------------------------+
#define SIGNAL_NONE 0
#define SIGNAL_BUY   1
#define SIGNAL_SELL  2
#define SIGNAL_CLOSEBUY 3
#define SIGNAL_CLOSESELL 4

#property copyright "Big Pippin"

extern string Remark1 = "== Main Settings ==";
extern int MagicNumber = 0;
extern bool SignalsOnly = False;
extern bool Alerts = False;
extern bool SignalMail = False;
extern bool PlaySounds = False;
extern bool EachTickMode = True;
extern bool CloseOnOppositeSignal = True;
extern double Lots = 0;
extern bool MoneyManagement = False;
extern int Risk = 0;
extern int Slippage = 5;
extern  bool UseStopLoss = True;
extern int StopLoss = 150;
extern bool UseTakeProfit = True;
extern int TakeProfit = 60;
extern bool UseTrailingStop = False;
extern int TrailingStop = 30;
extern bool MoveStopOnce = False;
extern int MoveStopWhenPrice = 50;
extern int MoveStopTo = 1;
extern string Remark2 = "";
extern string Remark3 = "== MA Fast Settings ==";
extern int MA1Period = 15;
extern int MA1Shift = 0;
extern int MA1Method = 0;
extern int MA1Price = 0;
extern string Remark4 = "";
extern string Remark5 = "== MA Slow Settings ==";
extern int MA2Period =30;
extern int MA2Shift = 0;
extern int MA2Method = 0;
extern int MA2Price = 0;
extern double Use_ATR_Pct = 0.7;
extern bool Use_ATR_Stop = true;

//Version 2.01

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
double getATR()
{
  double atr=iATR(NULL,0,10,0);
  double atr_val = atr*Use_ATR_Pct;
  return(atr_val);
}

double getATRBuyTakeProfit(double price)
{
 double initTP;

  initTP=price+getATR();
   
 return(initTP);
}

double getATRBuyStopLoss(double price)
{
 double initSL;

  initSL=price-(3*(getATR()));
   
 return(initSL);
}

double getATRSellTakeProfit(double price)
{
 double initTP;

  initTP=price-getATR();
   
 return(initTP);
}

double getATRSellStopLoss(double price)
{
 double initSL;

  initSL=price+(3*(getATR()));
   
 return(initSL);
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
int start() 


{
   int Order = SIGNAL_NONE;
   int Total, Ticket;
   double StopLossLevel, TakeProfitLevel;



   if (EachTickMode && Bars != BarCount) TickCheck = False;
   Total = OrdersTotal();
   Order = SIGNAL_NONE;

//Money Management sequence
 if (MoneyManagement)
   {
      if (Risk<1 || Risk>100)
      {
         Comment("Invalid Risk Value.");
         return(0);
      }
      else
      {
         Lots=MathFloor((AccountFreeMargin()*AccountLeverage()*Risk*Point*100)/(Ask*MarketInfo(Symbol(),MODE_LOTSIZE)*MarketInfo(Symbol(),MODE_MINLOT)))*MarketInfo(Symbol(),MODE_MINLOT);
      }
   }

   //+------------------------------------------------------------------+
   //| Variable Begin                                                   |
   //+------------------------------------------------------------------+

double EURUSDMA1A = iMA("EURUSD", 0, MA1Period, MA1Shift, MA1Method, MA1Price, Current + 0);
double EURUSDMA1B = iMA("EURUSD", 0, MA1Period, MA1Shift, MA1Method, MA1Price, Current + 1);

double EURUSDMA2A = iMA("EURUSD", 0, MA2Period, MA2Shift, MA2Method, MA2Price, Current + 0);
double EURUSDMA2B = iMA("EURUSD", 0, MA2Period, MA2Shift, MA2Method, MA2Price, Current + 1);

double USDCHFMA1A = iMA("USDCHF", 0, MA1Period, MA1Shift, MA1Method, MA1Price, Current + 0);
double USDCHFMA1B = iMA("USDCHF", 0, MA1Period, MA1Shift, MA1Method, MA1Price, Current + 1);

double USDCHFMA2A = iMA("USDCHF", 0, MA2Period, MA2Shift, MA2Method, MA2Price, Current + 0);
double USDCHFMA2B = iMA("USDCHF", 0, MA2Period, MA2Shift, MA2Method, MA2Price, Current + 1);

double EURCHFMA1A = iMA("EURCHF", 0, MA1Period, MA1Shift, MA1Method, MA1Price, Current + 0);
double EURCHFMA1B = iMA("EURCHF", 0, MA1Period, MA1Shift, MA1Method, MA1Price, Current + 1);

double EURCHFMA2A = iMA("EURCHF", 0, MA2Period, MA2Shift, MA2Method, MA2Price, Current + 0);
double EURCHFMA2B = iMA("EURCHF", 0, MA2Period, MA2Shift, MA2Method, MA2Price, Current + 1);


double MA1A = iMA(NULL, 0, MA1Period, MA1Shift, MA1Method, MA1Price, Current + 0);
double MA1B = iMA(NULL, 0, MA1Period, MA1Shift, MA1Method, MA1Price, Current + 1);

double MA2A = iMA(NULL, 0, MA2Period, MA2Shift, MA2Method, MA2Price, Current + 0);
double MA2B = iMA(NULL, 0, MA2Period, MA2Shift, MA2Method, MA2Price, Current + 1);





   
   //+------------------------------------------------------------------+
   //| Variable End                                                     |
   //+------------------------------------------------------------------+

   //Check position
   bool IsTrade = False;

   for (int i = 0; i < Total; i ++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderType() <= OP_SELL &&  OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         IsTrade = True;
         if(OrderType() == OP_BUY) {
         


           
            //Close

            //+------------------------------------------------------------------+
            //| Signal Begin(Exit Buy)                                           |
            //+------------------------------------------------------------------+

if(CloseOnOppositeSignal && EURUSDMA1A < EURUSDMA2A && EURUSDMA1B >= EURUSDMA2B && EURCHFMA1A < EURCHFMA2A && EURCHFMA1B >= EURCHFMA2B && USDCHFMA1A > USDCHFMA2A && USDCHFMA1B <= USDCHFMA2B) Order = SIGNAL_CLOSEBUY;  




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
            //MoveOnce
            if(MoveStopOnce && MoveStopWhenPrice > 0) {
               if(Bid - OrderOpenPrice() >= Point * MoveStopWhenPrice) {
                  if(OrderStopLoss() < OrderOpenPrice() + Point * MoveStopTo) {
                  OrderModify(OrderTicket(),OrderOpenPrice(), OrderOpenPrice() + Point * MoveStopTo, OrderTakeProfit(), 0, Red);
                     if (!EachTickMode) BarCount = Bars;
                     continue;
                  }
               }
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

if(CloseOnOppositeSignal && EURUSDMA1A > EURUSDMA2A && EURUSDMA1B <= EURUSDMA2B && EURCHFMA1A > EURCHFMA2A && EURCHFMA1B <= EURCHFMA2B && USDCHFMA1A < USDCHFMA2A && USDCHFMA1B >= USDCHFMA2B) Order = SIGNAL_CLOSESELL;



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
            //MoveOnce
            if(MoveStopOnce && MoveStopWhenPrice > 0) {
               if(OrderOpenPrice() - Ask >= Point * MoveStopWhenPrice) {
                  if(OrderStopLoss() > OrderOpenPrice() - Point * MoveStopTo) {
                  OrderModify(OrderTicket(),OrderOpenPrice(), OrderOpenPrice() - Point * MoveStopTo, OrderTakeProfit(), 0, Red);
                     if (!EachTickMode) BarCount = Bars;
                     continue;
                  }
               }
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
// BUY MA1A > MA2A && MA1B <= MA2B
// SELL MA1A < MA2A && MA1B >= MA2B


if(EURUSDMA1A > EURUSDMA2A && EURUSDMA1B <= EURUSDMA2B && EURCHFMA1A > EURCHFMA2A && EURCHFMA1B <= EURCHFMA2B && USDCHFMA1A < USDCHFMA2A && USDCHFMA1B >= USDCHFMA2B) Order = SIGNAL_BUY;
if(EURUSDMA1A < EURUSDMA2A && EURUSDMA1B >= EURUSDMA2B && EURCHFMA1A < EURCHFMA2A && EURCHFMA1B >= EURCHFMA2B && USDCHFMA1A > USDCHFMA2A && USDCHFMA1B <= USDCHFMA2B) Order = SIGNAL_SELL;


   //+------------------------------------------------------------------+
   //| Signal End                                                       |
   //+------------------------------------------------------------------+
   

   //Buy
   if (Order == SIGNAL_BUY && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
      if(SignalsOnly) {
         if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + "Buy Signal");
         if (Alerts) Alert("[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + "Buy Signal");
         if (PlaySounds) PlaySound("alert.wav");
     
      }
      
      if(!IsTrade && !SignalsOnly) {
         //Check free margin
         if (AccountFreeMargin() < (1000 * Lots)) {
            Print("We have no money. Free Margin = ", AccountFreeMargin());
            return(0);
         }

         if (UseStopLoss) StopLossLevel = getATRBuyStopLoss(Ask);  //= Ask - StopLoss * Point; else StopLossLevel = 0.0;
         if (UseTakeProfit) TakeProfitLevel = getATRBuyTakeProfit(Bid);  //= Ask + TakeProfit * Point; else TakeProfitLevel = 0.0;

         Ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, StopLossLevel, TakeProfitLevel, "Buy(#" + MagicNumber + ")", MagicNumber, 0, DodgerBlue);
         if(Ticket > 0) {
            if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) {
				Print("BUY order opened : ", OrderOpenPrice());
                if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + "Buy Signal");
			       if (Alerts) Alert("[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + "Buy Signal");
                if (PlaySounds) PlaySound("alert.wav");
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
      if(SignalsOnly) {
          if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + "Sell Signal");
          if (Alerts) Alert("[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + "Sell Signal");
          if (PlaySounds) PlaySound("alert.wav");
         }
      if(!IsTrade && !SignalsOnly) {
         //Check free margin
         if (AccountFreeMargin() < (1000 * Lots)) {
            Print("We have no money. Free Margin = ", AccountFreeMargin());
            return(0);
         }

         if (UseStopLoss) StopLossLevel = getATRSellStopLoss(Ask); //StopLoss * Point; else StopLossLevel = 0.0;
         if (UseTakeProfit) TakeProfitLevel = getATRSellTakeProfit(Bid);//Bid - TakeProfit * Point; else TakeProfitLevel = 0.0;

         Ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, StopLossLevel, TakeProfitLevel, "Sell(#" + MagicNumber + ")", MagicNumber, 0, DeepPink);
         if(Ticket > 0) {
            if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) {
				Print("SELL order opened : ", OrderOpenPrice());
                if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + "Sell Signal");
			       if (Alerts) Alert("[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + "Sell Signal");
                if (PlaySounds) PlaySound("alert.wav");
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