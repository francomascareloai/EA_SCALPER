//+------------------------------------------------------------------+
//| RattyFX - Forex Trading Robot                                    |
//| Version: 1.1                                                     |
//| Created: March 27, 2025                                          |
//| Author: Grok 3 (xAI)                                             |
//+------------------------------------------------------------------+

// --- Global Variables ---
input double RiskPercent = 1.0;         // Risk per trade (% of account balance)
input int Slippage = 3;                 // Max slippage in pips
input int MaxRetries = 3;               // Max trade retries on failure
input int SMAFastPeriod = 50;           // Fast SMA period
input int SMASlowPeriod = 200;          // Slow SMA period
input double TakeProfitPips = 20.0;     // Take-profit in pips
input double StopLossPips = 10.0;       // Stop-loss in pips
input string SymbolFilter = "EURUSD";   // Currency pair to trade
input bool EnableTrailingStop = false;  // Enable trailing stop option
input double TrailingStopPips = 5.0;    // Trailing stop distance in pips

double LotSize;                         // Calculated lot size
bool AutoTradingEnabled = true;         // Auto-trading status
int RetryCount = 0;                     // Tracks retry attempts
int MagicNumber = 123456;               // Unique identifier for trades

// --- Initialization Function ---
int OnInit() {
   Print("RattyFX v1.1 Initialized on ", SymbolFilter, " at ", TimeToString(TimeCurrent()));
   if(!CheckSymbol()) return(INIT_PARAMETERS_INCORRECT);
   CheckAutoTradingStatus();
   CalculateLotSize();
   EventSetTimer(60);
   return(INIT_SUCCEEDED);
}

// --- Main Trading Loop ---
void OnTick() {
   if(!AutoTradingEnabled || !IsNewBar(PERIOD_H1)) return;
   
   if(!CheckMargin()) {
      Print("Insufficient margin to trade. Free Margin: ", AccountFreeMargin());
      return;
   }

   if(EnableTrailingStop && OrdersTotal() > 0) {
      ManageTrailingStop();
   }

   double smaFast = iMA(SymbolFilter, PERIOD_H1, SMAFastPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   double smaSlow = iMA(SymbolFilter, PERIOD_H1, SMASlowPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   double smaFastPrev = iMA(SymbolFilter, PERIOD_H1, SMAFastPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
   double smaSlowPrev = iMA(SymbolFilter, PERIOD_H1, SMASlowPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);

   if(OrdersTotal() == 0) {
      if(smaFast > smaSlow && smaFastPrev <= smaSlowPrev) {
         ExecuteTrade(OP_BUY);
      }
      else if(smaFast < smaSlow && smaFastPrev >= smaSlowPrev) {
         ExecuteTrade(OP_SELL);
      }
   }
}

// --- Trade Execution Function ---
void ExecuteTrade(int direction) {
   double price = (direction == OP_BUY) ? Ask : Bid;
   double sl = NormalizeDouble((direction == OP_BUY) ? price - StopLossPips * Point * 10 
                                                    : price + StopLossPips * Point * 10, Digits);
   double tp = NormalizeDouble((direction == OP_BUY) ? price + TakeProfitPips * Point * 10 
                                                    : price - TakeProfitPips * Point * 10, Digits);

   int ticket = OrderSend(SymbolFilter, direction, LotSize, price, Slippage, sl, tp,
                        "RattyFX Trade", MagicNumber, 0, clrGreen);

   if(ticket < 0) {
      Print("Trade failed. Error: ", GetLastError(), " Slippage: ", Slippage);
      RetryTrade(direction, Slippage + 2);
   } else {
      Print((direction == OP_BUY ? "Buy" : "Sell"), " trade opened. Ticket: ", ticket);
      RetryCount = 0;
   }
}

// --- Retry Trade on Failure ---
void RetryTrade(int direction, int newSlippage) {
   if(RetryCount < MaxRetries && newSlippage <= 10) {
      RetryCount++;
      Print("Retrying trade. Attempt ", RetryCount, " with slippage ", newSlippage);
      Sleep(1000); // Wait 1 second before retry
      ExecuteTrade(direction);
   } else {
      Print("Max retries (", MaxRetries, ") reached. Trade aborted.");
      RetryCount = 0;
   }
}

// --- Trailing Stop Management ---
void ManageTrailingStop() {
   for(int i = 0; i < OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == MagicNumber) {
         if(OrderSymbol() == SymbolFilter) {
            double currentPrice = (OrderType() == OP_BUY) ? Bid : Ask;
            double newSL = NormalizeDouble((OrderType() == OP_BUY) 
                           ? currentPrice - TrailingStopPips * Point * 10 
                           : currentPrice + TrailingStopPips * Point * 10, Digits);
                           
            if((OrderType() == OP_BUY && newSL > OrderStopLoss()) || 
               (OrderType() == OP_SELL && newSL < OrderStopLoss())) {
               if(OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrYellow))
                  Print("Trailing stop updated for ticket ", OrderTicket());
               else
                  Print("Trailing stop update failed: ", GetLastError());
            }
         }
      }
   }
}

// --- Lot Size Calculation ---
void CalculateLotSize() {
   double accountBalance = AccountBalance();
   double riskAmount = accountBalance * (RiskPercent / 100.0);
   double tickValue = MarketInfo(SymbolFilter, MODE_TICKVALUE);
   double tickSize = MarketInfo(SymbolFilter, MODE_TICKSIZE);
   double pipValue = tickValue * (Point / tickSize);
   
   LotSize = NormalizeDouble(riskAmount / (StopLossPips * pipValue * 10), 2);
   double minLot = MarketInfo(SymbolFilter, MODE_MINLOT);
   double maxLot = MarketInfo(SymbolFilter, MODE_MAXLOT);
   
   LotSize = MathMax(minLot, MathMin(maxLot, LotSize));
   Print("Lot Size calculated: ", LotSize);
}

// --- Margin Check ---
bool CheckMargin() {
   double marginRequired = MarketInfo(SymbolFilter, MODE_MARGINREQUIRED) * LotSize;
   return (AccountFreeMargin() >= marginRequired * 1.5);
}

// --- Auto-Trading Status Check ---
void CheckAutoTradingStatus() {
   if(!IsTradeAllowed()) {
      AutoTradingEnabled = false;
      Print("Auto-trading disabled. Please enable it in the terminal.");
   } else if(!AutoTradingEnabled) {
      AutoTradingEnabled = true;
      Print("Auto-trading re-enabled.");
   }
}

// --- Symbol Check ---
bool CheckSymbol() {
   if(!SymbolSelect(SymbolFilter, true)) {
      Print("Invalid symbol: ", SymbolFilter);
      return false;
   }
   return true;
}

// --- New Bar Check ---
bool IsNewBar(int timeframe) {
   static datetime lastBar = 0;
   datetime currentBar = iTime(SymbolFilter, timeframe, 0);
   if(currentBar != lastBar) {
      lastBar = currentBar;
      return true;
   }
   return false;
}

// --- Timer Event ---
void OnTimer() {
   CheckAutoTradingStatus();
   CalculateLotSize();
}

// --- Deinitialization ---
void OnDeinit(const int reason) {
   Print("RattyFX stopped. Reason: ", reason);
   EventKillTimer();
}