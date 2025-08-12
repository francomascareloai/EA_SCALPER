//+------------------------------------------------------------------+
//|                                                 9 in 20 MA.mq4 |
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
input int startHour = 8;                  // Trading start hour (broker time)
input int endHour = 11;                   // Trading end hour (broker time)
input int endMinute = 30;                 // Trading end minute (broker time)
input int takeProfit = 10;                // Take Profit in pips
input int stopLoss = 20;                  // Stop Loss in pips
input double recoveryMultiplier = 2.0;    // Multiplier for the recovery order volume (default value)

// Define constants
#define MIN_RECOVERY_MULTIPLIER 0.01      // Minimum recovery multiplier
#define MAX_RECOVERY_MULTIPLIER 9.0       // Maximum recovery multiplier

// Define global variables
double fastMA[], slowMA[];
bool recoveryOrderTriggered = false;

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
        Print("Error: Invalid recoveryMultiplier value. It must be between ", MIN_RECOVERY_MULTIPLIER, " and ", MAX_RECOVERY_MULTIPLIER);
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
    // Check if the current time is within the specified trading hours
    if (IsTradingTime())
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
            OrderSend(Symbol(), OP_BUY, NormalizeDouble(tradeVolume, 2), Ask, 3, 0, 0, "MA Crossover Buy", 0, 0, Green);
            OrderSend(Symbol(), OP_BUY, NormalizeDouble(tradeVolume, 2), Ask, 3, 0, 0, "MA Crossover Buy", takeProfit, 0, Green);
            OrderSend(Symbol(), OP_BUY, NormalizeDouble(tradeVolume, 2), Ask, 3, 0, 0, "MA Crossover Buy", 0, stopLoss, Red);
        }

        // Check for a crossunder
        if (fastMA[0] < slowMA[0] && fastMA[1] >= slowMA[1])
        {
            // Reset recovery order trigger
            recoveryOrderTriggered = false;

            // Place a sell order with Take Profit and Stop Loss
            OrderSend(Symbol(), OP_SELL, NormalizeDouble(tradeVolume, 2), Bid, 3, 0, 0, "MA Crossover Sell", 0, 0, Red);
            OrderSend(Symbol(), OP_SELL, NormalizeDouble(tradeVolume, 2), Bid, 3, 0, 0, "MA Crossover Sell", takeProfit, 0, Red);
            OrderSend(Symbol(), OP_SELL, NormalizeDouble(tradeVolume, 2), Bid, 3, 0, 0, "MA Crossover Sell", 0, stopLoss, Green);
        }

        // Check for a stop loss and trigger recovery order
        if (OrderType() == OP_BUY && OrderStopLoss() > 0 && !recoveryOrderTriggered)
        {
            // Place a recovery buy order with larger volume
            OrderSend(Symbol(), OP_BUY, NormalizeDouble(tradeVolume * recoveryMultiplier, 2), Ask, 3, 0, 0, "Recovery Buy", 0, 0, Green);
            recoveryOrderTriggered = true;
        }
        else if (OrderType() == OP_SELL && OrderStopLoss() > 0 && !recoveryOrderTriggered)
        {
            // Place a recovery sell order with larger volume
            OrderSend(Symbol(), OP_SELL, NormalizeDouble(tradeVolume * recoveryMultiplier, 2), Bid, 3, 0, 0, "Recovery Sell", 0, 0, Red);
            recoveryOrderTriggered = true;
        }
    }
}

//+------------------------------------------------------------------+
//| Trading Time Check Function                                      |
//+------------------------------------------------------------------+
bool IsTradingTime()
{
    datetime currentTime = TimeCurrent();
    int currentHour = TimeHour(currentTime);
    int currentMinute = TimeMinute(currentTime);

    // Get broker's time offset in seconds
    int brokerTimeOffset = MarketInfo(Symbol(), MODE_GMT_OFFSET) * 3600;

    // Adjust start and end times based on broker's time offset
    int adjustedStartHour = startHour - brokerTimeOffset / 3600;
    int adjustedEndHour = endHour - brokerTimeOffset / 3600;

    // Check if the current time is within the specified trading hours
    if (currentHour >= adjustedStartHour && currentHour < adjustedEndHour)
    {
        return true;
    }
    else if (currentHour == adjustedEndHour && currentMinute <= endMinute)
    {
        return true;
    }

    return false;
}