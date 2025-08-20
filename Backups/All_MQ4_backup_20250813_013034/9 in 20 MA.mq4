//+------------------------------------------------------------------+
//|                                                 9 in 20 EA.mq4 |
//|                             OpenSource, Matthew Todorovski       |
//|                                       Created using ChatGPT     |
//|                                       https://www.youtube.com/watch?v=jH5DCqIY2jg |
//+------------------------------------------------------------------+
#property copyright "OpenSource, Matthew Todorovski"
#property description "Created using ChatGPT"                   // Description (line 2)
#property description "https://www.youtube.com/watch?v=jH5DCqIY2jg" // Description (line 3)
#property strict

//+------------------------------------------------------------------+
//| Expert Data Setup                                                |
//+------------------------------------------------------------------+
// Define input parameters
input int fastMAPeriod = 9;               // Period for the fast moving average
input int slowMAPeriod = 20;              // Period for the slow moving average
input double tradeVolume = 0.01;          // Trading volume
input int startHour = 8;                  // Trading start hour
input int endHour = 11;                   // Trading end hour
input int endMinute = 30;                 // Trading end minute
input int takeProfit = 10;                // Take Profit in pips
input int stopLoss = 20;                  // Stop Loss in pips
input double recoveryMultiplier = 2.0;    // Multiplier for the recovery order volume (default value)

// Define constants
#define MIN_RECOVERY_MULTIPLIER 0.01      // Minimum recovery multiplier
#define MAX_RECOVERY_MULTIPLIER 9.0       // Maximum recovery multiplier

// Define global variables
double fastMA[], slowMA[];
bool recoveryOrderTriggered = false;
bool recovery = false; // Added declaration for 'recovery'
int BuyOrder = 0;      // Added declaration for 'BuyOrder'

//+------------------------------------------------------------------+
//| Expert Initialization Function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Create fast and slow moving averages
    ArraySetAsSeries(fastMA, true);
    ArraySetAsSeries(slowMA, true);

    // Initialize fast and slow moving averages
    ArrayResize(fastMA, 100);
    ArrayResize(slowMA, 100);

    // Validate recovery multiplier input
    if (recoveryMultiplier < MIN_RECOVERY_MULTIPLIER || recoveryMultiplier > MAX_RECOVERY_MULTIPLIER)
    {
        Print("Error: Invalid recoveryMultiplier value. It must be between ", DoubleToStr(MIN_RECOVERY_MULTIPLIER, 2), " and ", DoubleToStr(MAX_RECOVERY_MULTIPLIER, 2));
        return(INIT_FAILED);
    }

    // Return initialization result
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert Tick Function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Calculate fast and slow moving averages
    ArrayCopySeries(fastMA, 0, 0, fastMAPeriod);
    ArrayCopySeries(slowMA, 0, 0, slowMAPeriod);

    // Check for a crossover
    if (fastMA[0] > slowMA[0] && fastMA[1] <= slowMA[1])
    {
        // Reset recovery order trigger
        recoveryOrderTriggered = false;

        // Place a buy order with Take Profit and Stop Loss
        int buyTicket = OrderSend(Symbol(), OP_BUY, NormalizeDouble(tradeVolume, 2), Ask, 3, 0, 0, "MA Crossover Buy", 0, 0, Green);
        if (buyTicket <= 0) {
            Print("Error placing Buy order. Error code: ", GetLastError());
        }

        int takeProfitOrder = OrderSend(Symbol(), OP_BUY, NormalizeDouble(tradeVolume, 2), Ask, 3, 0, 0, "MA Crossover Buy", takeProfit, 0, Green);
        if (takeProfitOrder <= 0) {
            Print("Error placing Take Profit order. Error code: ", GetLastError());
        }

        int stopLossOrder = OrderSend(Symbol(), OP_BUY, NormalizeDouble(tradeVolume, 2), Ask, 3, 0, 0, "MA Crossover Buy", 0, stopLoss, Red);
        if (stopLossOrder <= 0) {
            Print("Error placing Stop Loss order. Error code: ", GetLastError());
        }
    }

    // ... (Repeat similar checks for sell orders)

    // Check for a stop loss and trigger recovery order
    if (OrderType() == OP_BUY && OrderStopLoss() > 0 && !recoveryOrderTriggered)
    {
        // Place a recovery buy order with larger volume
        int recoveryBuyOrder = OrderSend(Symbol(), OP_BUY, NormalizeDouble(tradeVolume * recoveryMultiplier, 2), Ask, 3, 0, 0, "Recovery Buy", 0, 0, Green);
        if (recoveryBuyOrder <= 0) {
            Print("Error placing Recovery Buy order. Error code: ", GetLastError());
        }
        recoveryOrderTriggered = true;
    }
    else if (OrderType() == OP_SELL && OrderStopLoss() > 0 && !recoveryOrderTriggered)
    {
        // Place a recovery sell order with larger volume
        int recoverySellOrder = OrderSend(Symbol(), OP_SELL, NormalizeDouble(tradeVolume * recoveryMultiplier, 2), Bid, 3, 0, 0, "Recovery Sell", 0, 0, Red);
        if (recoverySellOrder <= 0) {
            Print("Error placing Recovery Sell order. Error code: ", GetLastError());
        }
        recoveryOrderTriggered = true;
    }
}