//Constants
input double StartLot = 0.03;         // Minimum lot size
input double LotStep = 0.01;          // Step for increasing lot size
input double BalanceStep = 200;        // Step for increasing lot size
input int TakeProfitPoints = 10;      // Take profit in points (10 pips)
input int MaxHedges = 1;              // Max hedges allowed for recovery
input int Deviation = 5;              // Slippage (smaller to avoid issues)
input string symbol = "XAUUSDs";      // Corrected trading symbol
input int MaxTrades = 8;              // Max number of trades allowed (8 max)
input double MaxLoss = 100;           // Maximum allowed loss before stopping trading

// Fixed Stop Loss: 0.5% of the current price
double CalculateFixedStopLoss(double price, int direction)
{
    double stopLossDistance = price * 0.005;  // 0.5% of the current price
    return (direction > 0) ? price - stopLossDistance : price + stopLossDistance;
}

// Calculate Lot Size based on account balance
double CalculateLot()
{
    double bal = AccountInfoDouble(ACCOUNT_BALANCE);  // Get the account balance
    int steps = (int)(bal / BalanceStep);  // Calculate the step based on balance
    double lot = StartLot + LotStep * steps;  // Increase lot size based on balance
    return NormalizeDouble(lot, 2);  // Return lot size with 2 decimal places
}

// Function to get the number of currently open positions (MQL5 uses Positions instead of Orders)
int CountOpenPositions(int direction)
{
    int total = 0;

    // Loop through all open positions
    for (long i = 0; i < PositionsTotal(); i++)  // PositionsTotal() returns long, so we use long for i
    {
        // Select position by symbol
        if (PositionSelect(symbol)) // PositionSelect() works with symbol names in MQL5
        {
            // Get the symbol and position type
            string posSymbol = PositionGetString(POSITION_SYMBOL);  // Get symbol for the position
            int posType = PositionGetInteger(POSITION_TYPE);  // Get type (buy/sell)

            // If the symbol matches and the position type is correct (buy/sell direction)
            if (posSymbol == symbol && ((direction > 0 && posType == POSITION_TYPE_BUY) || (direction < 0 && posType == POSITION_TYPE_SELL)))
            {
                total++;
            }
        }
    }
    return total;
}

// Open a trade
void OpenTrade(int direction)
{
    // Check if we've already reached the max number of trades
    int currentOpenTrades = CountOpenPositions(direction);
    if (currentOpenTrades >= MaxTrades)
    {
        Print("Maximum number of trades reached, not opening any more trades.");
        return;  // Stop opening new trades if max trades reached
    }

    double lot = CalculateLot();
    double price = 0;
    double tp_price = 0;
    double stopLoss = 0;

    // Ensure symbol is valid and price is not 0
    if (SymbolInfoDouble(symbol, SYMBOL_BID) == 0.0 || SymbolInfoDouble(symbol, SYMBOL_ASK) == 0.0)
    {
        Print("Error: Symbol price is invalid or not available.");
        return;  // Exit the function if the price is invalid
    }

    // Get the price for buy or sell
    price = (direction > 0) ? SymbolInfoDouble(symbol, SYMBOL_ASK) : SymbolInfoDouble(symbol, SYMBOL_BID);

    // Ensure price is valid before proceeding
    if (price == 0.0)
    {
        Print("Error: Failed to get valid price for symbol ", symbol);
        return;
    }

    // Calculate TakeProfit level (fixed in points)
    tp_price = (direction > 0) ? price + TakeProfitPoints * _Point : price - TakeProfitPoints * _Point;

    // Calculate Fixed StopLoss (0.5% of current price)
    stopLoss = CalculateFixedStopLoss(price, direction);

    // Prepare the trade request
    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);
    ZeroMemory(result);

    request.action = TRADE_ACTION_DEAL;
    request.symbol = symbol;
    request.volume = lot;
    request.type = (direction > 0) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
    request.price = price;
    request.deviation = Deviation;  // Slippage
    request.tp = tp_price;         // Set TP price
    request.sl = stopLoss;         // Set Fixed SL
    request.magic = 123456;        // Magic number to identify trades

    // Print the order parameters for debugging
    Print("Opening trade: Symbol = ", symbol, ", Lot Size = ", lot, ", Price = ", price, ", TP = ", tp_price, ", SL = ", stopLoss);

    // Send the order
    if (!OrderSend(request, result))
    {
        int error_code = GetLastError();
        Print("OrderSend failed with error code: ", error_code);
    }
    else
    {
        Print("Order executed with result code: ", result.retcode, " at price: ", result.price);
    }
}

// Main function called on every tick
void OnTick()
{
    // Check if the current loss exceeds the max allowed loss
    if (AccountInfoDouble(ACCOUNT_BALANCE) - AccountInfoDouble(ACCOUNT_EQUITY) > MaxLoss)
    {
        Print("Max loss reached. Stopping further trades.");
        return;  // Stop trading if maximum loss is exceeded
    }

    // Verify if the symbol is available before trading
    if (!SymbolSelect(symbol, true)) {
        Print("Error: Symbol ", symbol, " is not available.");
        return;  // Exit if the symbol is not available
    }

    double bid_price = SymbolInfoDouble(symbol, SYMBOL_BID);
    double ask_price = SymbolInfoDouble(symbol, SYMBOL_ASK);

    // Check if the symbol prices are valid
    if (bid_price == 0.0 || ask_price == 0.0)
    {
        Print("Error: Symbol price is invalid. Bid: ", bid_price, ", Ask: ", ask_price);
        return;  // Exit if price is invalid
    }
    else
    {
        Print("Bid Price: ", bid_price, " Ask Price: ", ask_price);  // Debug message
    }

    // Open a buy position if the signal is strong (e.g., within the first 30 seconds of the minute)
    if (TimeCurrent() % 60 < 30)
    {
        Print("Strong signal detected, opening buy positions.");
        OpenTrade(1);  // 1 for buy
    }
    else
    {
        Print("Weak signal detected, opening sell positions.");
        OpenTrade(-1);  // -1 for sell
    }
}
