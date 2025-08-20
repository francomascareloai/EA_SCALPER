//---- input parameters ---------------------------------------------+
extern int       INCREMENT=35;
extern double    LOTS=0.01;
extern int       LEVELS=1;
extern double    MAX_LOTS=99;
extern int       MAGIC=1803;
extern bool      CONTINUE=true;
extern bool      MONEY_MANAGEMENT=false;
extern int       RISK_RATIO=2;

// Additional config
bool             UseProfitTarget=false;
bool             UsePartialProfitTarget=false;
int              Target_Increment = 50;
int              First_Target = 20;
bool             UseEntryTime=false;
int              EntryTime=0;

bool Enter=true;
int nextTP;

//+------------------------------------------------------------------+
int init() {
   nextTP = First_Target;
   return(0);
}

int deinit() {
   return(0);
}

//+------------------------------------------------------------------+
int start() {
   int ticket, cpt, profit, total=0, BuyGoalProfit, SellGoalProfit, PipsLot=0;
   double ProfitTarget=INCREMENT*2; //Consider making this a parameter
   double BuyGoal=0, SellGoal=0;
   double spread=(Ask-Bid)/Point;
   double InitialPrice=0;

   if(INCREMENT<MarketInfo(Symbol(),MODE_STOPLEVEL)+spread)
      INCREMENT=1+MarketInfo(Symbol(),MODE_STOPLEVEL)+spread;

   if(MONEY_MANAGEMENT)
      LOTS=NormalizeDouble(AccountBalance()*AccountLeverage()/1000000*RISK_RATIO,0)*MarketInfo(Symbol(),MODE_MINLOT);

   if(LOTS<MarketInfo(Symbol(),MODE_MINLOT)) {
      Comment("Not Enough Free Margin to begin");
      return(0);
   }

   for(cpt=1;cpt<LEVELS;cpt++) PipsLot+=cpt*INCREMENT;

   for(cpt=0;cpt<OrdersTotal();cpt++) {
      OrderSelect(cpt,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()==MAGIC && OrderSymbol()==Symbol()) {
         total++;
         if(!InitialPrice) InitialPrice=StrToDouble(OrderComment());
         if(UsePartialProfitTarget && UseProfitTarget && OrderType()<2) {
            double val=getPipValue(OrderOpenPrice(),OrderType());
            takeProfit(val,OrderTicket());
         }
      }
   }

   if(total<1 && Enter && (!UseEntryTime || (UseEntryTime && Hour()==EntryTime))) {
      if(AccountFreeMargin()<(100*LOTS)) { //Consider making 100 a parameter
         Print("Not enough free margin to begin");
         return(0);
      }

      InitialPrice=Ask;
      SellGoal=InitialPrice-(LEVELS+1)*INCREMENT*Point;
      BuyGoal=InitialPrice+(LEVELS+1)*INCREMENT*Point;

      for(cpt=1;cpt<=LEVELS;cpt++) {
         double buyEntry = InitialPrice + cpt * INCREMENT * Point;
         double sellEntry = InitialPrice - cpt * INCREMENT * Point;

         double buySL, buyTP, sellSL, sellTP;
         GetSLTP(buyEntry, OP_BUYSTOP, INCREMENT, buySL, buyTP);
         GetSLTP(sellEntry, OP_SELLSTOP, INCREMENT, sellSL, sellTP);

         OrderSend(Symbol(), OP_BUYSTOP, LOTS, buyEntry, 2, buySL, buyTP, DoubleToStr(InitialPrice,Digits), MAGIC, 0);
         OrderSend(Symbol(), OP_SELLSTOP, LOTS, sellEntry, 2, sellSL, sellTP, DoubleToStr(InitialPrice,Digits), MAGIC, 0);
      }
   }
   else {
      BuyGoal=InitialPrice+INCREMENT*(LEVELS+1)*Point;
      SellGoal=InitialPrice-INCREMENT*(LEVELS+1)*Point;

      int totalHistory = OrdersHistoryTotal();
      for(cpt=0;cpt<totalHistory;cpt++) {
         OrderSelect(cpt,SELECT_BY_POS,MODE_HISTORY);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGIC &&  StrToDouble(OrderComment())==InitialPrice) {
            EndSession();
            return(0);
         }
      }

      if(UseProfitTarget && CheckProfits(LOTS,OP_SELL,true,InitialPrice)>ProfitTarget) {
         deleteAllPendingOrders();
         return(0);
      }

      BuyGoalProfit=CheckProfits(LOTS,OP_BUY,false,InitialPrice);
      SellGoalProfit=CheckProfits(LOTS,OP_SELL,false,InitialPrice);

      // Re-entry BUY
      for(cpt=LEVELS;cpt>=1 && BuyGoalProfit<ProfitTarget;cpt--) {
         double buyEntry2 = InitialPrice + cpt * INCREMENT * Point;
         if(Ask <= (buyEntry2 - MarketInfo(Symbol(),MODE_STOPLEVEL)*Point)) {
            double sl2, tp2;
            GetSLTP(buyEntry2, OP_BUYSTOP, INCREMENT, sl2, tp2);
            ticket = OrderSend(Symbol(), OP_BUYSTOP, cpt*LOTS, buyEntry2, 2, sl2, tp2, DoubleToStr(InitialPrice,Digits), MAGIC, 0);
            if(ticket>0)
               BuyGoalProfit += LOTS * (tp2 - buyEntry2) / Point;
         }
      }

      // Re-entry SELL
      for(cpt=LEVELS;cpt>=1 && SellGoalProfit<ProfitTarget;cpt--) {
         double sellEntry2 = InitialPrice - cpt * INCREMENT * Point;
         if(Bid >= (sellEntry2 + MarketInfo(Symbol(),MODE_STOPLEVEL)*Point)) {
        
            GetSLTP(sellEntry2, OP_SELLSTOP, INCREMENT, sl2, tp2);
            ticket = OrderSend(Symbol(), OP_SELLSTOP, cpt*LOTS, sellEntry2, 2, sl2, tp2, DoubleToStr(InitialPrice,Digits), MAGIC, 0);
            if(ticket>0)
               SellGoalProfit += LOTS * (sellEntry2 - tp2) / Point;
         }
      }
   }

   Comment(
      "mGRID EXPERT ADVISOR\n",
      "Server: ",AccountServer(),"\n",
      "Balance: $",AccountBalance(),"\n",
      "Symbol: ", Symbol(),"\n",
      "Bid: ", NormalizeDouble(Bid,4)," Ask: ",NormalizeDouble(Ask,4),"\n",
      "Spread: ", MarketInfo(Symbol(),MODE_SPREAD),"\n",
      "Increment=", INCREMENT, " | Lots=",LOTS," | Levels=",LEVELS,"\n"
   );

   return(0);
}

//+------------------------------------------------------------------+

int CheckProfits(double LOTS, int Goal, bool Current, double InitialPrice) {
   int profit=0;
   for(int cpt=0;cpt<OrdersTotal();cpt++) {
      OrderSelect(cpt, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol() && StrToDouble(OrderComment())==InitialPrice) {
         if(Current) {
            if(OrderType()==OP_BUY)
               profit+=(Bid-OrderOpenPrice())/Point*OrderLots()/LOTS;
            if(OrderType()==OP_SELL)
               profit+=(OrderOpenPrice()-Ask)/Point*OrderLots()/LOTS;
         } else {
            if(Goal==OP_BUY) {
               if(OrderType()==OP_BUY)
                  profit+=(OrderTakeProfit()-OrderOpenPrice())/Point*OrderLots()/LOTS;
               if(OrderType()==OP_SELL)
                  profit-=(OrderStopLoss()-OrderOpenPrice())/Point*OrderLots()/LOTS;
               if(OrderType()==OP_BUYSTOP)
                  profit+=(OrderTakeProfit()-OrderOpenPrice())/Point*OrderLots()/LOTS;
            } else {
               if(OrderType()==OP_BUY)
                  profit-=(OrderOpenPrice()-OrderStopLoss())/Point*OrderLots()/LOTS;
               if(OrderType()==OP_SELL)
                  profit+=(OrderOpenPrice()-OrderTakeProfit())/Point*OrderLots()/LOTS;
               if(OrderType()==OP_SELLSTOP)
                  profit+=(OrderOpenPrice()-OrderTakeProfit())/Point*OrderLots()/LOTS;
            }
         }
      }
   }
   return(profit);
}

bool EndSession() {
   deleteAllPendingOrders(); 
   if(!CONTINUE) Enter=false;
   return(true);
}

double getPipValue(double ord,int dir) {
   double val;
   RefreshRates();
   if(dir == 1) val = (NormalizeDouble(ord,Digits) - NormalizeDouble(Ask,Digits));
   else val = (NormalizeDouble(Bid,Digits) - NormalizeDouble(ord,Digits));
   return val / Point;
}


void GetSLTP(double entryPrice, int type, int incrementPips, double &sl, double &tp) {
   if (type == OP_BUYSTOP || type == OP_BUY) {
       tp = NormalizeDouble(entryPrice + incrementPips * Point, Digits);
       sl = NormalizeDouble(entryPrice - incrementPips * Point, Digits); 
   } else if (type == OP_SELLSTOP || type == OP_SELL) {
       tp = NormalizeDouble(entryPrice - incrementPips * Point, Digits);
       sl = NormalizeDouble(entryPrice + incrementPips * Point, Digits); 
   } else {
       Print("Error in GetSLTP: Invalid order type:", type);
       sl = 0;
       tp = 0;
   }
}

void takeProfit(int current_pips, int ticket) {
   if(OrderSelect(ticket, SELECT_BY_TICKET)) {
      if(OrderCloseTime() == 0 && current_pips >= nextTP && current_pips < (nextTP + Target_Increment)) { 
         double lotsToClose = (OrderLots() > MAX_LOTS) ? MAX_LOTS : OrderLots(); 
         if(OrderType() == OP_SELL) {
            if (!OrderClose(ticket, lotsToClose, Bid, 3, clrRed)) { 
               Print("Error closing sell order ", ticket, ": ", GetLastError());
            } else {
               nextTP += Target_Increment;
               deleteAllPendingOrders(); 
            }
         } else if(OrderType() == OP_BUY) {
            if (!OrderClose(ticket, lotsToClose, Ask, 3, clrGreen)) { 
               Print("Error closing buy order ", ticket, ": ", GetLastError());
            } else {
               nextTP += Target_Increment;
               deleteAllPendingOrders(); 
            }
         }
      }
   }
}

void deleteAllPendingOrders() {
   for(int cpt=0; cpt<OrdersTotal(); cpt++) {

      OrderSelect(cpt,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderType()>1) { 
         if(!OrderDelete(OrderTicket())) {
            Print("Error deleting order ", OrderTicket(), ": ", GetLastError());
         }
      }
   }
}

