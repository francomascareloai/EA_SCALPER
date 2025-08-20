// Define input parameters
input int fastMAPeriod = 9;       // Period for the fast moving average
input int slowMAPeriod = 20;      // Period for the slow moving average
input int lotSize = 1;            // Trading lot size
input int startHour = 8;          // Trading start hour (EST)
input int endHour = 11;           // Trading end hour (EST)
input int endMinute = 30;         // Trading end minute (EST)
input int takeProfit = 10;        // Take Profit in pips
input int stopLoss = 20;          // Stop Loss in pips
input int recoveryMultiplier = 2; // Multiplier for the recovery order volume

// Define global variables
double fastMA[], slowMA[];
bool recoveryOrderTriggered = false;

// Define the OnInit() function
int OnInit()
{
    // Create fast and slow moving averages
    ArraySetAsSeries(fastMA, true);
    ArraySetAsSeries(slowMA, true);

    // Initialize fast and slow moving averages
    ArrayResize(fastMA, 100);
    ArrayResize(slowMA, 100);

    // Return initialization result
    return(INIT_SUCCEEDED);
}

// Define the OnTick() function
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
            OrderSend(Symbol(), OP_BUY, lotSize, Ask, 3, 0, 0, "MA Crossover Buy", 0, 0, Green);
            OrderSend(Symbol(), OP_BUY, lotSize, Ask, 3, 0, 0, "MA Crossover Buy", takeProfit, 0, Green);
            OrderSend(Symbol(), OP_BUY, lotSize, Ask, 3, 0, 0, "MA Crossover Buy", 0, stopLoss, Red);
        }

        // Check for a crossunder
        if (fastMA[0] < slowMA[0] && fastMA[1] >= slowMA[1])
        {
            // Reset recovery order trigger
            recoveryOrderTriggered = false;

            // Place a sell order with Take Profit and Stop Loss
            OrderSend(Symbol(), OP_SELL, lotSize, Bid, 3, 0, 0, "MA Crossover Sell", 0, 0, Red);
            OrderSend(Symbol(), OP_SELL, lotSize, Bid, 3, 0, 0, "MA Crossover Sell", takeProfit, 0, Red);
            OrderSend(Symbol(), OP_SELL, lotSize, Bid, 3, 0, 0, "MA Crossover Sell", 0, stopLoss, Green);
        }

        // Check for a stop loss and trigger recovery order
        if (OrderType() == OP_BUY && OrderStopLoss() > 0 && !recoveryOrderTriggered)
        {
            // Place a recovery buy order with larger volume
            OrderSend(Symbol(), OP_BUY, lotSize * recoveryMultiplier, Ask, 3, 0, 0, "Recovery Buy", 0, 0, Green);
            recoveryOrderTriggered = true;
        }
        else if (OrderType() == OP_SELL && OrderStopLoss() > 0 && !recoveryOrderTriggered)
        {
            // Place a recovery sell order with larger volume
            OrderSend(Symbol(), OP_SELL, lotSize * recoveryMultiplier, Bid, 3, 0, 0, "Recovery Sell", 0, 0, Red);
            recoveryOrderTriggered = true;
        }
    }
}

// Define the IsTradingTime() function
bool IsTradingTime()
{
    datetime currentTime = TimeCurrent();
    int currentHour = TimeHour(currentTime);
    int currentMinute = TimeMinute(currentTime);

    // Check if the current time is within the specified trading hours
    if (currentHour >= startHour && currentHour < endHour)
    {
        return true;
    }
    else if (currentHour == endHour && currentMinute <= endMinute)
    {
        return true;
    }

    return false;
}