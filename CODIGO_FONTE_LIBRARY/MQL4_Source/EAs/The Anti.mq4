//+------------------------------------------------------------------+
//|                                                     The Anti.mq4 |
//|                                   OpenSource, Matthew Todorovski |
//|                                            Created using ChatGPT |
//|                      https://www.youtube.com/watch?v=mJqnG6-7kSs |
//+------------------------------------------------------------------+
#property copyright "OpenSource, Matthew Todorovski"
#property description "Created using ChatGPT"                   // Description (line 2)
#property description "https://www.youtube.com/watch?v=mJqnG6-7kSs" // Description (line 3)
#property indicator_chart_window
#property strict

// Input parameters
static const int fast_length = 3;   // Set to 3
static const int slow_length = 10;  // Set to 10
static const ENUM_APPLIED_PRICE src = PRICE_CLOSE;
static const int signal_length = 16; // Set to 16

// Trading parameters
int orderTicket = 0;
datetime entryTime = 0;
bool tradeActive = false;

// Variables
double fast_ma, slow_ma;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Your trading logic goes here
    if (!tradeActive)
    {
        CheckForCross();
    }
    else
    {
        ManageTrade();
    }
}

//+------------------------------------------------------------------+
//| Custom indicator function                                       |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    // Calculate MACD
    ArraySetAsSeries(close, true);
    fast_ma = CalculateMA(fast_length, src);
    slow_ma = CalculateMA(slow_length, src);

    // Alert conditions
    if (IsCrossing(fast_ma, slow_ma) > 0)
    {
        Alert("Rising to falling: The MACD signal switched from a rising to falling state");
        if (!tradeActive)
        {
            entryTime = TimeCurrent();
            tradeActive = true;
        }
    }
    if (IsCrossing(fast_ma, slow_ma) < 0)
    {
        Alert("Falling to rising: The MACD signal switched from a falling to rising state");
        if (!tradeActive)
        {
            entryTime = TimeCurrent();
            tradeActive = true;
        }
    }

    return (rates_total);
}

//+------------------------------------------------------------------+
//| Calculate Moving Average                                         |
//+------------------------------------------------------------------+
double CalculateMA(int length, ENUM_APPLIED_PRICE price_type)
{
    return iMA(NULL, 0, length, 0, MODE_SMA, price_type, 0);
}

//+------------------------------------------------------------------+
//| Check for Cross                                                  |
//+------------------------------------------------------------------+
int IsCrossing(double value1, double value2)
{
    if (value1 > value2)
        return 1; // Crossed up
    else if (value1 < value2)
        return -1; // Crossed down
    else
        return 0; // No cross
}

//+------------------------------------------------------------------+
//| Trading functions                                                |
//+------------------------------------------------------------------+
void CheckForCross()
{
    int crossingResult = IsCrossing(fast_ma, slow_ma);
    if (crossingResult > 0)
    {
        ExecuteOrder(OP_BUY, clrGreen);
    }
    else if (crossingResult < 0)
    {
        ExecuteOrder(OP_SELL, clrRed);
    }
}

void ManageTrade()
{
    int timePassed = TimeCurrent() - entryTime;
    if (timePassed < 30 * 60)
    {
        // Check for a second cross in the same direction
        if (IsCrossing(fast_ma, slow_ma) != 0)
        {
            // Continue with the existing trade
        }
        else
        {
            // Cancel trade and return to step 1
            CloseTrade(clrRed);
        }
    }
    else
    {
        // Maximum waiting time reached, close the trade
        CloseTrade(clrRed);
    }
}

void ExecuteOrder(int orderType, color orderColor)
{
    if (OrderSend(Symbol(), orderType, 1, orderType == OP_BUY ? Ask : Bid, 3, 0, 0, orderType == OP_BUY ? "Buy Order" : "Sell Order", 0, 0, orderColor) > 0)
    {
        orderTicket = OrderSend(Symbol(), orderType, 1, orderType == OP_BUY ? Ask : Bid, 3, 0, 0, orderType == OP_BUY ? "Buy Order" : "Sell Order", 0, 0, orderColor);
        entryTime = TimeCurrent();
        tradeActive = true;
    }
}

void CloseTrade(color orderColor)
{
    OrderClose(orderTicket, OrderLots(), orderTicket > 0 ? orderTicket == OP_BUY ? Bid : Ask : 0, 3, orderColor);
    tradeActive = false;
}