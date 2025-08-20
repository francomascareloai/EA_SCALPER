//+------------------------------------------------------------------+
//|              Zone Recovery Strategy with EMA Direction           |
//|          Developed in MQL4 for trading XAUUSD, 1k account        |
//+------------------------------------------------------------------+
#property strict

// Input Parameters
input double InitialLotSize = 0.01;        // Initial Lot Size
input double RecoveryMultiplier = 2.0;     // Recovery Multiplier
input bool   UsePips            = false;   // Use pips for recovery zone and take profit
input double RecoveryDistance = 0.1;       // Recovery Zone in pips or ATR fraction
input double TakeProfit = 0.1;             // Take Profit in pips or ATR fraction
input double RecoveryTakeProfit = 0.05;    // Recovery Take Profit in pips or ATR fraction
input double MaxRecoverySteps = 5;         // Max Recovery Steps (initial trade not counted)
input int ATRPeriod = 14;                  // ATR Period
input double ATRThresholdMultiplier = 3.0; // ATR Threshold
input int ATRReferenceBarOffset = 5;       // ATR Reference Bar Offset
input int EMAFastPeriod = 15;              // Fast EMA Period
input int EMASlowPeriod = 20;              // Slow EMA Period
input ENUM_TIMEFRAMES EMA_TIMEFRAME = PERIOD_M5; // EMA TimeFrame
input int MagicNumber = 12345;             // Magic Number
input bool TradeBarOpen = true;            // Trade at bar open
input bool InversedTradeLogic = false;     // Inversed trade logic

// Variables
double latest_atr;
double TradeLotSize;
double TradeDirection;
int RecoveryStep;
datetime new_bar;

// statistics
double result_initial_balance; // [$]
double result_final_balance; // [$]
double result_max_dd; // [$]
int    result_trades;
double result_lots;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   new_bar = Time[0];
   RecoveryStep = 0;
   TradeLotSize = InitialLotSize;
   Print("Zone Recovery EA Initialized with EMA Direction.");
   if(Period() > EMA_TIMEFRAME) {
      string error = "ERROR: The Chart Period must be lower or equal to the EMA period!";
      Print(error);
      Alert(error);
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   latest_atr = iATR(Symbol(), EMA_TIMEFRAME, ATRPeriod, 1);
   
   // statistics
   result_initial_balance = AccountBalance();
   result_final_balance = AccountBalance();
   result_max_dd = 0.0;
   result_trades = 0;
   result_lots = 0;
   
   return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {

   // update statistics
   result_final_balance = AccountBalance();
   double dd = AccountBalance() - AccountEquity();
   if (dd>result_max_dd) result_max_dd = dd;

   if (OrdersTotal() == 0) {
      if((new_bar != Time[0]) || !TradeBarOpen) {
         new_bar = Time[0];
         if (CheckVolatility() && CheckEMACrossover()) {
            // take a trade in increased volatility, in EMA crossover direction and at new bar open
            OpenInitialTrade();
         } else {
            // Print("No valid signal. Waiting for EMA crossover and volatility.");
         }
      }
   } else {
      ManageTrades();
   }
}

//+------------------------------------------------------------------+
//| Check Market Volatility using ATR                                |
//+------------------------------------------------------------------+
bool CheckVolatility() {
   int offset = 0;
   if(TradeBarOpen) offset = 1;
   double currentATR = iATR(Symbol(), EMA_TIMEFRAME, ATRPeriod, offset);
   double previousATR = iATR(Symbol(), EMA_TIMEFRAME, ATRPeriod, ATRReferenceBarOffset+offset);
   double threshold = previousATR * ATRThresholdMultiplier;
   latest_atr = currentATR;
   if (currentATR > threshold) {
      Print("Volatility Increasing. ATR: ", currentATR);
      return true;
   }
   // Print("Low Volatility. Current ATR: ", currentATR, " | Threshold: ", threshold);
   return false;
}

//+------------------------------------------------------------------+
//| Check EMA Crossover for Trade Direction                         |
//+------------------------------------------------------------------+
bool CheckEMACrossover() {
   int offset = 0;
   if(TradeBarOpen) offset = 1;
   double EMAFast = iMA(Symbol(), EMA_TIMEFRAME, EMAFastPeriod, 0, MODE_EMA, PRICE_CLOSE, offset);
   double EMASlow = iMA(Symbol(), EMA_TIMEFRAME, EMASlowPeriod, 0, MODE_EMA, PRICE_CLOSE, offset);
   if (EMAFast > EMASlow) {
      TradeDirection = 1.0; // Buy
      if(InversedTradeLogic) TradeDirection = -1.0; // Sell
      // Print("EMA Crossover Detected: Buy Signal (EMA15 > EMA20)");
      return true;
   } else if (EMAFast < EMASlow) {
      TradeDirection = -1.0; // Sell
      if(InversedTradeLogic) TradeDirection = 1.0; // Buy
      // Print("EMA Crossover Detected: Sell Signal (EMA15 < EMA20)");
      return true;
   }
   // Print("No EMA Crossover Signal.");
   return false;
}

//+------------------------------------------------------------------+
//| Open Initial Trade                                               |
//+------------------------------------------------------------------+
void OpenInitialTrade() {
   double price = (TradeDirection > 0) ? Ask : Bid;
   if (TradeDirection > 0) {
      int rb = OrderSend(Symbol(), OP_BUY, TradeLotSize, price, 3, 0, 0, "Initial Buy", MagicNumber);
      result_trades++;
      result_lots += TradeLotSize;
   } else {
      int rs = OrderSend(Symbol(), OP_SELL, TradeLotSize, price, 3, 0, 0, "Initial Sell", MagicNumber);
      result_trades++;
      result_lots += TradeLotSize;
   }
   Print("Initial Trade Opened: ", TradeDirection > 0 ? "Buy" : "Sell");
}

//+------------------------------------------------------------------+
//| Manage Trades and Zone Recovery                                  |
//+------------------------------------------------------------------+
void ManageTrades() {
   double totalProfit = 0;
   int orders = OrdersTotal();
   for (int i = 0; i < orders; i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == MagicNumber) {
         totalProfit += OrderProfit();
      }
   }
   double take_profit = RecoveryTakeProfit;
   if(orders == 1) take_profit = TakeProfit;   
   double expected_profit = take_profit * latest_atr;   
   if(UsePips) expected_profit = take_profit * Point;   
   if (totalProfit >= expected_profit) {
      CloseAllTrades();
      Print("Target Reached. All Trades Closed.");
      return;
   }

   CheckRecoveryZone();
}

//+------------------------------------------------------------------+
//| Check and Apply Recovery Strategy                                |
//+------------------------------------------------------------------+
void CheckRecoveryZone() {
   if (OrdersTotal() == 0 || RecoveryStep >= MaxRecoverySteps)
      return;
   double entryPrice = 0;
   double currentPrice = (TradeDirection > 0) ? Bid : Ask;
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == MagicNumber) {
         entryPrice = OrderOpenPrice();
         break;
      }
   }
   double distance = RecoveryDistance * latest_atr;
   if(UsePips) distance = RecoveryDistance * Point;
   if (TradeDirection > 0 && currentPrice <= entryPrice - distance) {
      RecoveryTrade(OP_SELL);
   } else if (TradeDirection < 0 && currentPrice >= entryPrice + distance) {
      RecoveryTrade(OP_BUY);
   }
}

//+------------------------------------------------------------------+
//| Open Recovery Trade                                              |
//+------------------------------------------------------------------+
void RecoveryTrade(int orderType) {
   TradeLotSize *= RecoveryMultiplier;
   double price = (orderType == OP_BUY) ? Ask : Bid;
   if (OrderSend(Symbol(), orderType, TradeLotSize, price, 3, 0, 0, "Recovery Trade", MagicNumber)) {
      RecoveryStep++;
      result_trades++;
      result_lots += TradeLotSize;
      Print("Recovery Trade Opened: ", orderType == OP_BUY ? "Buy" : "Sell", " | Step: ", RecoveryStep);
   }
}

//+------------------------------------------------------------------+
//| Close All Trades                                                 |
//+------------------------------------------------------------------+
void CloseAllTrades() {
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == MagicNumber) {
         int rc = OrderClose(OrderTicket(), OrderLots(), (OrderType() == OP_BUY ? Bid : Ask), 3);
      }
   }
   RecoveryStep = 0;
   TradeLotSize = InitialLotSize;
}

// called at the end of the test
double OnTester() {
   double result;
   result_final_balance = AccountBalance();
   
   // profit / dd
   result = 100*(result_final_balance - result_initial_balance) / result_max_dd;
   
   // lots / tgrades
   //result = 1000 * result_lots / result_trades;
   
   return result;
}