//+------------------------------------------------------------------+
//|                                           Risk Analyzer Script  |
//|                                  Copyright 2024, Risk Manager   |
//|                                             https://risk.com    |
//+------------------------------------------------------------------+
#property copyright "Risk Manager"
#property link      "https://risk.com"
#property version   "1.2"
#property strict
#property script_show_inputs

// Input parameters
input double AccountRiskPercent = 1.0;  // Account risk per trade (%)
input double MaxDailyRisk = 5.0;        // Maximum daily risk (%)
input int MaxOpenTrades = 3;             // Maximum open trades
input bool ShowDetailedReport = true;    // Show detailed risk report
input bool CheckFTMOCompliance = true;   // Check FTMO compliance

// FTMO Rules
#define FTMO_MAX_DAILY_LOSS 5.0
#define FTMO_MAX_TOTAL_LOSS 10.0
#define FTMO_MIN_TRADING_DAYS 10
#define FTMO_PROFIT_TARGET 10.0

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=== RISK ANALYZER SCRIPT STARTED ===");
   
   // Perform comprehensive risk analysis
   AnalyzeAccountRisk();
   AnalyzeOpenPositions();
   AnalyzeTradingHistory();
   
   if(CheckFTMOCompliance)
      AnalyzeFTMOCompliance();
   
   if(ShowDetailedReport)
      GenerateDetailedReport();
   
   Print("=== RISK ANALYSIS COMPLETED ===");
}

//+------------------------------------------------------------------+
//| Analyze account risk metrics                                     |
//+------------------------------------------------------------------+
void AnalyzeAccountRisk()
{
   double balance = AccountBalance();
   double equity = AccountEquity();
   double margin = AccountMargin();
   double freeMargin = AccountFreeMargin();
   double marginLevel = AccountMarginLevel();
   
   Print("\n--- ACCOUNT RISK ANALYSIS ---");
   Print("Balance: $", DoubleToStr(balance, 2));
   Print("Equity: $", DoubleToStr(equity, 2));
   Print("Free Margin: $", DoubleToStr(freeMargin, 2));
   Print("Margin Level: ", DoubleToStr(marginLevel, 2), "%");
   
   // Calculate drawdown
   double drawdown = (balance - equity) / balance * 100;
   Print("Current Drawdown: ", DoubleToStr(drawdown, 2), "%");
   
   // Risk warnings
   if(marginLevel < 200)
      Print("WARNING: Low margin level - Risk of margin call!");
   
   if(drawdown > 3.0)
      Print("WARNING: High drawdown detected!");
}

//+------------------------------------------------------------------+
//| Analyze open positions                                           |
//+------------------------------------------------------------------+
void AnalyzeOpenPositions()
{
   int totalOrders = OrdersTotal();
   double totalRisk = 0;
   double totalProfit = 0;
   int buyOrders = 0, sellOrders = 0;
   
   Print("\n--- OPEN POSITIONS ANALYSIS ---");
   Print("Total Open Orders: ", totalOrders);
   
   for(int i = 0; i < totalOrders; i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         double orderProfit = OrderProfit() + OrderSwap() + OrderCommission();
         totalProfit += orderProfit;
         
         // Calculate risk per order
         double orderRisk = 0;
         if(OrderStopLoss() > 0)
         {
            if(OrderType() == OP_BUY)
               orderRisk = (OrderOpenPrice() - OrderStopLoss()) * OrderLots() * MarketInfo(OrderSymbol(), MODE_TICKVALUE);
            else if(OrderType() == OP_SELL)
               orderRisk = (OrderStopLoss() - OrderOpenPrice()) * OrderLots() * MarketInfo(OrderSymbol(), MODE_TICKVALUE);
         }
         totalRisk += orderRisk;
         
         if(OrderType() == OP_BUY) buyOrders++;
         if(OrderType() == OP_SELL) sellOrders++;
         
         if(ShowDetailedReport)
         {
            Print("Order #", OrderTicket(), " - ", OrderSymbol(), 
                  " - Lots: ", DoubleToStr(OrderLots(), 2),
                  " - Profit: $", DoubleToStr(orderProfit, 2),
                  " - Risk: $", DoubleToStr(orderRisk, 2));
         }
      }
   }
   
   Print("Buy Orders: ", buyOrders, " | Sell Orders: ", sellOrders);
   Print("Total Unrealized P&L: $", DoubleToStr(totalProfit, 2));
   Print("Total Risk Exposure: $", DoubleToStr(totalRisk, 2));
   
   // Risk percentage
   double riskPercent = totalRisk / AccountBalance() * 100;
   Print("Risk as % of Balance: ", DoubleToStr(riskPercent, 2), "%");
   
   // Warnings
   if(totalOrders > MaxOpenTrades)
      Print("WARNING: Too many open trades! Limit: ", MaxOpenTrades);
   
   if(riskPercent > MaxDailyRisk)
      Print("WARNING: Risk exposure exceeds daily limit!");
}

//+------------------------------------------------------------------+
//| Analyze trading history                                          |
//+------------------------------------------------------------------+
void AnalyzeTradingHistory()
{
   int totalTrades = OrdersHistoryTotal();
   double totalProfit = 0;
   int winningTrades = 0;
   int losingTrades = 0;
   double largestWin = 0;
   double largestLoss = 0;
   
   Print("\n--- TRADING HISTORY ANALYSIS ---");
   
   for(int i = 0; i < totalTrades; i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
      {
         double profit = OrderProfit() + OrderSwap() + OrderCommission();
         totalProfit += profit;
         
         if(profit > 0)
         {
            winningTrades++;
            if(profit > largestWin) largestWin = profit;
         }
         else if(profit < 0)
         {
            losingTrades++;
            if(profit < largestLoss) largestLoss = profit;
         }
      }
   }
   
   double winRate = 0;
   if(totalTrades > 0)
      winRate = (double)winningTrades / totalTrades * 100;
   
   Print("Total Historical Trades: ", totalTrades);
   Print("Winning Trades: ", winningTrades, " | Losing Trades: ", losingTrades);
   Print("Win Rate: ", DoubleToStr(winRate, 1), "%");
   Print("Total Profit: $", DoubleToStr(totalProfit, 2));
   Print("Largest Win: $", DoubleToStr(largestWin, 2));
   Print("Largest Loss: $", DoubleToStr(largestLoss, 2));
   
   // Calculate profit factor
   double grossProfit = 0, grossLoss = 0;
   for(int i = 0; i < totalTrades; i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
      {
         double profit = OrderProfit() + OrderSwap() + OrderCommission();
         if(profit > 0) grossProfit += profit;
         else grossLoss += MathAbs(profit);
      }
   }
   
   double profitFactor = 0;
   if(grossLoss > 0) profitFactor = grossProfit / grossLoss;
   Print("Profit Factor: ", DoubleToStr(profitFactor, 2));
}

//+------------------------------------------------------------------+
//| Analyze FTMO compliance                                          |
//+------------------------------------------------------------------+
void AnalyzeFTMOCompliance()
{
   Print("\n--- FTMO COMPLIANCE ANALYSIS ---");
   
   double balance = AccountBalance();
   double equity = AccountEquity();
   double drawdown = (balance - equity) / balance * 100;
   
   // Check daily loss limit
   bool dailyLossOK = drawdown <= FTMO_MAX_DAILY_LOSS;
   Print("Daily Loss Limit (5%): ", dailyLossOK ? "PASS" : "FAIL");
   Print("Current Drawdown: ", DoubleToStr(drawdown, 2), "%");
   
   // Check maximum loss limit
   double maxDrawdown = CalculateMaxDrawdown();
   bool maxLossOK = maxDrawdown <= FTMO_MAX_TOTAL_LOSS;
   Print("Max Loss Limit (10%): ", maxLossOK ? "PASS" : "FAIL");
   Print("Max Drawdown: ", DoubleToStr(maxDrawdown, 2), "%");
   
   // Check profit target
   double totalProfit = equity - balance;
   double profitPercent = totalProfit / balance * 100;
   bool profitTargetOK = profitPercent >= FTMO_PROFIT_TARGET;
   Print("Profit Target (10%): ", profitTargetOK ? "ACHIEVED" : "PENDING");
   Print("Current Profit: ", DoubleToStr(profitPercent, 2), "%");
   
   // Overall compliance
   bool ftmoCompliant = dailyLossOK && maxLossOK;
   Print("\nFTMO COMPLIANCE STATUS: ", ftmoCompliant ? "COMPLIANT" : "NON-COMPLIANT");
}

//+------------------------------------------------------------------+
//| Calculate maximum drawdown                                       |
//+------------------------------------------------------------------+
double CalculateMaxDrawdown()
{
   double maxDrawdown = 0;
   double peak = AccountBalance();
   
   // This is a simplified calculation
   // In real implementation, you would track historical equity curve
   double currentEquity = AccountEquity();
   double currentDrawdown = (peak - currentEquity) / peak * 100;
   
   return MathMax(maxDrawdown, currentDrawdown);
}

//+------------------------------------------------------------------+
//| Generate detailed risk report                                    |
//+------------------------------------------------------------------+
void GenerateDetailedReport()
{
   Print("\n--- DETAILED RISK REPORT ---");
   Print("Report Generated: ", TimeToStr(TimeCurrent()));
   Print("Account Server: ", AccountServer());
   Print("Account Number: ", AccountNumber());
   Print("Account Currency: ", AccountCurrency());
   Print("Leverage: 1:", AccountLeverage());
   
   // Risk recommendations
   Print("\n--- RISK RECOMMENDATIONS ---");
   
   double riskPerTrade = AccountBalance() * AccountRiskPercent / 100;
   Print("Recommended risk per trade: $", DoubleToStr(riskPerTrade, 2));
   
   double maxLotSize = riskPerTrade / (100 * MarketInfo(Symbol(), MODE_TICKVALUE));
   Print("Max lot size for 100 pip SL: ", DoubleToStr(maxLotSize, 2));
   
   Print("Always use stop losses!");
   Print("Never risk more than ", DoubleToStr(AccountRiskPercent, 1), "% per trade");
   Print("Monitor daily drawdown closely");
   Print("Keep detailed trading journal");
}