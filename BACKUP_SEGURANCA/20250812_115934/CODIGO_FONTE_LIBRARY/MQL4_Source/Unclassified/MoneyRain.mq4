//+------------------------------------------------------------------+
//|                                                    MoneyRain.mq4 |
//|                               Copyright © 2008, Yury V. Reshetov |
//|                               http://bigforex.biz/load/2-1-0-172 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Yury V. Reshetov http://bigforex.biz/load/2-1-0-172"
#property link      "http://bigforex.biz/load/2-1-0-172"

//---- input parameters
extern int       p = 10;
extern double    tp = 50;
extern double    sl = 50;
extern double    lots = 1;
extern int       losseslimit = 1000000;
extern bool      fastoptimize = true;
extern int       mn = 888;
static int       prevtime = 0;
static int       losses = 0;


//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
   if (Time[0] == prevtime) return(0);
   prevtime = Time[0];
   
   if (! IsTradeAllowed()) {
      prevtime = Time[1];
      MathSrand(TimeCurrent());
      Sleep(30000 + MathRand());
   }
//----
   int total = OrdersTotal();
   for (int i = 0; i < total; i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == mn) {
         return(0);
      } 
   }
   
   int ticket = -1;
   
   double lt = getLots();
   if (losses >= losseslimit) {
      SendMail(WindowExpertName() + " Too many losses", "Chart " + Symbol());
      return(0);
   }
   
   if (iDeMarker(Symbol(), 0, p, 0) > 0.5) {
      RefreshRates();
      ticket = OrderSend(Symbol(), OP_BUY, lt, Ask, 1, Bid - sl * Point, Bid + tp * Point, WindowExpertName(), mn, 0, Blue); 
      if (ticket < 0) {
         Sleep(30000);
         prevtime = Time[1];
      }
   } else {
      ticket = OrderSend(Symbol(), OP_SELL, lt, Bid, 1, Ask + sl * Point, Ask - tp * Point, WindowExpertName(), mn, 0, Red); 
      RefreshRates();
      if (ticket < 0) {
         Sleep(30000);
         prevtime = Time[1];
      }
   }
//-- Exit --
   return(0);
}
//+--------------------------- getLots ----------------------------------+

double getLots() {

   if (IsOptimization() && fastoptimize) {
      return(lots);
   }
  
   losses = 0;
   int profits = 0;
   double lossesvolume = 0;
   double minlot = MarketInfo(Symbol(), MODE_MINLOT);
   int round = MathAbs(MathLog(minlot) / MathLog(10.0)) + 0.5;
   double result = lots;
   int total = OrdersHistoryTotal();
   double spread = MarketInfo(Symbol(), MODE_SPREAD);
   for (int i = 0; i < total; i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == mn) {
         if (OrderProfit() > 0) {
            if (lossesvolume > 0.5 && profits < 1) {
               result = lots * lossesvolume * (sl + spread) / (tp - spread);
            } else {
               result = lots;
            }
            losses = 0;
            if (profits > 1) {
               lossesvolume = 0;
            }
            profits++;
         } else {
            result = lots;
            losses++;
            lossesvolume = lossesvolume + OrderLots() / lots;
            profits = 0;
         }
      }
   }
   result = NormalizeDouble(result, round);
   double maxlot = MarketInfo(Symbol(), MODE_MAXLOT);
   if (result > maxlot) {
      result = maxlot;
   }
   if (result < minlot) {
      mn = mn + 1;
   }
   RefreshRates();
   return(result);
}


