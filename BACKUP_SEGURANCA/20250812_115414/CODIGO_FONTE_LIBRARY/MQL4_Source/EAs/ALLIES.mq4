// User-defined input parameters
input double EquityThreshold = 55.0; // Percentage threshold for opening trades
input double EquityCloseThreshold = 120.0; // Percentage threshold for closing all trades
input double TotalMultiplier = 2.2; // Desired multiple of opened trade size
input int TrailingStopPoints = 4000; // Trailing stop distance in points

// Define constants for stop orders if they are not recognized
#define OP_BUY_STOP 4
#define OP_SELL_STOP 5

// Define other variables and flags
bool AlliesClosedByTrailingStop = false;
double lastClosedPrice = 0; // To store the last close price by trailing stop
bool Locked = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
    ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrBlue); // Set chart background to blue
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrWhite); // Reset background color to white
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
    double EquityPercentage = AccountEquity() / AccountBalance() * 100;
    ObjectDelete("EquityLabel");
    ObjectCreate("EquityLabel", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("EquityLabel", StringFormat("Equity Percentage: %.2f%%", EquityPercentage), 10, "Arial", clrWhite);
    ObjectSetInteger(0, "EquityLabel", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, "EquityLabel", OBJPROP_XDISTANCE, 5);
    ObjectSetInteger(0, "EquityLabel", OBJPROP_YDISTANCE, 5);

    // Only open trades based on equity threshold if there are no active stop orders
    if (EquityPercentage < EquityThreshold && !Locked) {
        Locked = true;
        double lotSize = CalculateLots() * TotalMultiplier; // Updated lot size calculation
        Print("Opening trades with total adjusted lot size: ", lotSize);
        ExecuteTrades(OrderDirection(), lotSize);
    }
    else if (EquityPercentage >= EquityCloseThreshold) {
        // Close all trades when the equity close threshold is reached
        CloseAllTrades();
        Locked = false; // Reset Locked flag to allow reopening trades after reaching EquityThreshold
    }

    // Apply trailing stops to "Allies" trades only
    ApplyTrailingStops();
}

//+------------------------------------------------------------------+
//| Calculate the total lots of open trades                          |
//+------------------------------------------------------------------+
double CalculateLots() {
    double totalLots = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol()) {
                totalLots += OrderLots();
            }
        }
    }
    return totalLots; // Sum of all open trades' lots
}

//+------------------------------------------------------------------+
//| Determine trade direction based on existing orders               |
//+------------------------------------------------------------------+
int OrderDirection() {
    int buys = 0, sells = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol()) {
                if (OrderType() == OP_BUY) buys++;
                else if (OrderType() == OP_SELL) sells++;
            }
        }
    }
    return (buys > sells) ? OP_SELL : OP_BUY; // Open opposite order type
}

//+------------------------------------------------------------------+
//| Execute trades based on calculated lot sizes                     |
//+------------------------------------------------------------------+
void ExecuteTrades(int tradeType, double lotSize) {
    string tradeDescriptions[5] = {"Allies 1", "Allies 2", "Allies 3", "Allies 4", "Allies 5"};
    double tradePercentages[5] = {0.26, 0.21, 0.195, 0.174, 0.161};

    double totalTradeSize = lotSize;
    double remainingSize = totalTradeSize;

    for (int i = 0; i < 5; i++) {
        double tradeSize = totalTradeSize * tradePercentages[i];
        if (i == 4) tradeSize = remainingSize; // Allocate remaining lot size to the last trade
        remainingSize -= tradeSize;

        int ticket = OrderSend(Symbol(), tradeType, tradeSize, Ask, 3, 0, 0, tradeDescriptions[i], 0, 0, clrNONE);
        if (ticket < 0) {
            Print("Error opening order ", tradeDescriptions[i], ": ", GetLastError());
        }
    }
}

//+------------------------------------------------------------------+
//| Close all open trades                                            |
//+------------------------------------------------------------------+
void CloseAllTrades() {
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol()) {
                double closePrice = (OrderType() == OP_BUY) ? MarketInfo(OrderSymbol(), MODE_BID) : MarketInfo(OrderSymbol(), MODE_ASK);
                if (OrderClose(OrderTicket(), OrderLots(), closePrice, 3, clrNONE)) {
                    lastClosedPrice = closePrice;
                    AlliesClosedByTrailingStop = true;
                } else {
                    Print("Error closing order ", OrderTicket(), ": ", GetLastError());
                }
            }
        }
    }

    if (AlliesClosedByTrailingStop) {
        Print("Closing trades triggered by trailing stop.");
        PlaceStopOrder();
        AlliesClosedByTrailingStop = false;
    }
}

//+------------------------------------------------------------------+
//| Place stop orders after trailing stop closes trades              |
//+------------------------------------------------------------------+
void PlaceStopOrder() {
    double stopPrice;
    int stopOrderType;

    // Determine stop order type and price
    if (OrderDirection() == OP_SELL) {
        stopPrice = lastClosedPrice - TrailingStopPoints * Point;
        stopOrderType = OP_SELL_STOP;
    } else {
        stopPrice = lastClosedPrice + TrailingStopPoints * Point;
        stopOrderType = OP_BUY_STOP;
    }

    // Place stop order and set trailing stop
    int ticket = OrderSend(Symbol(), stopOrderType, CalculateLots(), stopPrice, 3, 0, 0, "Allies Stop Order", 0, 0, clrNONE);
    if (ticket < 0) {
        Print("Error placing stop order: ", GetLastError());
    } else {
        Print("Stop order successfully placed with ticket: ", ticket);
    }
}

//+------------------------------------------------------------------+
//| Apply trailing stops to open trades                              |
//+------------------------------------------------------------------+
void ApplyTrailingStops() {
    string tradeLabels[5] = {"Allies 1", "Allies 2", "Allies 3", "Allies 4", "Allies 5"};
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol()) {
            for (int j = 0; j < ArraySize(tradeLabels); j++) {
                if (StringFind(OrderComment(), tradeLabels[j]) >= 0) {
                    double stopLossLevel;
                    if (OrderType() == OP_BUY) {
                        stopLossLevel = Ask - TrailingStopPoints * Point;
                        if (OrderStopLoss() < stopLossLevel || OrderStopLoss() == 0) {
                            if (!OrderModify(OrderTicket(), OrderOpenPrice(), stopLossLevel, OrderTakeProfit(), 0, clrNONE)) {
                                Print("Error modifying buy order ", OrderTicket(), ": ", GetLastError());
                            }
                        }
                    } else if (OrderType() == OP_SELL) {
                        stopLossLevel = Bid + TrailingStopPoints * Point;
                        if (OrderStopLoss() > stopLossLevel || OrderStopLoss() == 0) {
                            if (!OrderModify(OrderTicket(), OrderOpenPrice(), stopLossLevel, OrderTakeProfit(), 0, clrNONE)) {
                                Print("Error modifying sell order ", OrderTicket(), ": ", GetLastError());
                            }
                        }
                    }
                }
            }
        }
    }
}
