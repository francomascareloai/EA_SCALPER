//+------------------------------------------------------------------+
//|                                           FVG_Trading_Strategy.mq4 |
//|                        Copyright 2025, Fair Value Gap Trading EA |
//|                                                                    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, FVG Trading EA"
#property link      ""
#property version   "1.00"
#property strict

//--- Input parameters
input bool      UseFixedLot = false;        // Use fixed lot size instead of risk %
input double    FixedLotSize = 0.01;        // Fixed lot size
input double    RiskPercent = 1.0;          // Risk percentage per trade (if not using fixed lot)
input double    DailyDrawdownLimit = 100.0; // Daily drawdown limit in account currency
input double    DailyProfitLimit = 200.0;   // Daily profit limit in account currency
input int       MagicNumber = 12345;        // Magic number for trades
input double    MinFVGSize = 10;            // Minimum FVG size in points
input int       MaxTradesPerDay = 3;        // Maximum trades per day
input bool      TradeOnlyLondon = true;     // Trade only during London session
input bool      RequireSameDirection = true; // Require 4H and 15M FVG in same direction
input double    MaxRiskReward = 3.0;        // Maximum Risk:Reward ratio
input double    MinRiskReward = 2.0;        // Minimum Risk:Reward ratio

//--- Global variables
struct FVGLevel {
    double high;
    double low;
    datetime time;
    bool valid;
    int direction; // 1 for bullish, -1 for bearish
};

FVGLevel fvg4H;
FVGLevel fvg15M;
int tradesCount = 0;
datetime lastTradeDate = 0;
double dailyStartBalance = 0;
double dailyProfit = 0;
bool dailyLimitReached = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("FVG Trading Strategy EA initialized");
    
    // Initialize FVG structures
    fvg4H.valid = false;
    fvg15M.valid = false;
    
    // Initialize daily tracking
    dailyStartBalance = AccountBalance();
    dailyProfit = 0;
    dailyLimitReached = false;
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("FVG Trading Strategy EA deinitialized");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Reset daily counters and limits on new day
    if(TimeToStr(TimeCurrent(), TIME_DATE) != TimeToStr(lastTradeDate, TIME_DATE))
    {
        tradesCount = 0;
        dailyStartBalance = AccountBalance();
        dailyProfit = 0;
        dailyLimitReached = false;
        Print("New day started - Daily limits reset");
    }
    
    // Calculate current daily profit/loss
    dailyProfit = AccountBalance() - dailyStartBalance;
    
    // Check daily limits
    if(CheckDailyLimits())
        return;
    
    // Check if maximum trades reached
    if(tradesCount >= MaxTradesPerDay)
        return;
    
    // Check trading session
    if(TradeOnlyLondon && !IsLondonSession())
        return;
    
    // Update FVG levels
    UpdateFVGLevels();
    
    // Check for trade opportunities
    CheckForTrades();
}

//+------------------------------------------------------------------+
//| Check daily profit/drawdown limits                              |
//+------------------------------------------------------------------+
bool CheckDailyLimits()
{
    // Check if daily drawdown limit exceeded
    if(dailyProfit <= -DailyDrawdownLimit)
    {
        if(!dailyLimitReached)
        {
            Print("Daily drawdown limit reached: ", dailyProfit, " - Closing all trades and stopping");
            CloseAllTrades();
            dailyLimitReached = true;
        }
        return true;
    }
    
    // Check if daily profit limit reached
    if(dailyProfit >= DailyProfitLimit)
    {
        if(!dailyLimitReached)
        {
            Print("Daily profit limit reached: ", dailyProfit, " - Closing all trades and stopping");
            CloseAllTrades();
            dailyLimitReached = true;
        }
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Close all open trades                                           |
//+------------------------------------------------------------------+
void CloseAllTrades()
{
    for(int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol())
        {
            bool result = false;
            if(OrderType() == OP_BUY)
            {
                result = OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrRed);
            }
            else if(OrderType() == OP_SELL)
            {
                result = OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrRed);
            }
            
            if(!result)
            {
                Print("Failed to close order ", OrderTicket(), " Error: ", GetLastError());
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Update FVG levels on both timeframes                            |
//+------------------------------------------------------------------+
void UpdateFVGLevels()
{
    // Update 4H FVG
    Update4HFVG();
    
    // Update 15M FVG
    Update15MFVG();
}

//+------------------------------------------------------------------+
//| Update 4H FVG levels                                            |
//+------------------------------------------------------------------+
void Update4HFVG()
{
    // Get last 3 bars on 4H
    double high1 = iHigh(Symbol(), PERIOD_H4, 1);
    double low1 = iLow(Symbol(), PERIOD_H4, 1);
    double high2 = iHigh(Symbol(), PERIOD_H4, 2);
    double low2 = iLow(Symbol(), PERIOD_H4, 2);
    double high3 = iHigh(Symbol(), PERIOD_H4, 3);
    double low3 = iLow(Symbol(), PERIOD_H4, 3);
    
    // Check for bullish FVG (gap between bar 3 low and bar 1 high)
    if(low1 > high3)
    {
        double gapSize = (low1 - high3) / Point;
        if(gapSize >= MinFVGSize)
        {
            fvg4H.high = low1;
            fvg4H.low = high3;
            fvg4H.time = iTime(Symbol(), PERIOD_H4, 1);
            fvg4H.valid = true;
            fvg4H.direction = 1; // Bullish
            Print("4H Bullish FVG detected: ", fvg4H.low, " - ", fvg4H.high);
        }
    }
    
    // Check for bearish FVG (gap between bar 3 high and bar 1 low)
    if(high1 < low3)
    {
        double gapSize = (low3 - high1) / Point;
        if(gapSize >= MinFVGSize)
        {
            fvg4H.high = low3;
            fvg4H.low = high1;
            fvg4H.time = iTime(Symbol(), PERIOD_H4, 1);
            fvg4H.valid = true;
            fvg4H.direction = -1; // Bearish
            Print("4H Bearish FVG detected: ", fvg4H.low, " - ", fvg4H.high);
        }
    }
}

//+------------------------------------------------------------------+
//| Update 15M FVG levels                                           |
//+------------------------------------------------------------------+
void Update15MFVG()
{
    // Get last 3 bars on 15M
    double high1 = iHigh(Symbol(), PERIOD_M15, 1);
    double low1 = iLow(Symbol(), PERIOD_M15, 1);
    double high2 = iHigh(Symbol(), PERIOD_M15, 2);
    double low2 = iLow(Symbol(), PERIOD_M15, 2);
    double high3 = iHigh(Symbol(), PERIOD_M15, 3);
    double low3 = iLow(Symbol(), PERIOD_M15, 3);
    
    // Check for bullish FVG
    if(low1 > high3)
    {
        double gapSize = (low1 - high3) / Point;
        if(gapSize >= MinFVGSize)
        {
            fvg15M.high = low1;
            fvg15M.low = high3;
            fvg15M.time = iTime(Symbol(), PERIOD_M15, 1);
            fvg15M.valid = true;
            fvg15M.direction = 1; // Bullish
        }
    }
    
    // Check for bearish FVG
    if(high1 < low3)
    {
        double gapSize = (low3 - high1) / Point;
        if(gapSize >= MinFVGSize)
        {
            fvg15M.high = low3;
            fvg15M.low = high1;
            fvg15M.time = iTime(Symbol(), PERIOD_M15, 1);
            fvg15M.valid = true;
            fvg15M.direction = -1; // Bearish
        }
    }
}

//+------------------------------------------------------------------+
//| Check for trade opportunities                                   |
//+------------------------------------------------------------------+
void CheckForTrades()
{
    if(!fvg4H.valid || !fvg15M.valid)
        return;
    
    // Check if both FVGs are in the same direction (if required)
    if(RequireSameDirection && fvg4H.direction != fvg15M.direction)
        return;
    
    double currentPrice = (Bid + Ask) / 2;
    
    // Check for bullish setup
    if(fvg15M.direction == 1 && currentPrice >= fvg15M.low && currentPrice <= fvg15M.high)
    {
        // Price is within 15M FVG, look for entry
        if(Ask <= fvg15M.high && Bid >= fvg15M.low)
        {
            ExecuteBuyTrade();
        }
    }
    
    // Check for bearish setup
    if(fvg15M.direction == -1 && currentPrice >= fvg15M.low && currentPrice <= fvg15M.high)
    {
        // Price is within 15M FVG, look for entry
        if(Bid >= fvg15M.low && Ask <= fvg15M.high)
        {
            ExecuteSellTrade();
        }
    }
}

//+------------------------------------------------------------------+
//| Execute buy trade                                               |
//+------------------------------------------------------------------+
void ExecuteBuyTrade()
{
    if(IsTradeOpen())
        return;
    
    double entryPrice = Ask;
    double stopLoss = GetSwingLow(); // Get recent swing low
    double takeProfit = 0;
    double lotSize = 0;
    double stopDistance = entryPrice - stopLoss; // Declare stopDistance variable
    
    // Check if stop distance is valid
    if(stopDistance <= 0)
    {
        Print("Invalid stop distance for buy trade: ", stopDistance);
        return;
    }
    
    // Calculate position size based on settings
    if(UseFixedLot)
    {
        lotSize = FixedLotSize;
    }
    else
    {
        // Calculate position size based on risk
        double riskAmount = AccountBalance() * (RiskPercent / 100);
        lotSize = CalculateLotSize(riskAmount, stopDistance);
    }
    
    // Calculate take profit based on risk reward ratio
    double rewardDistance = stopDistance * MinRiskReward;
    takeProfit = entryPrice + rewardDistance;
    
    // Validate risk reward ratio
    if(rewardDistance / stopDistance < MinRiskReward || rewardDistance / stopDistance > MaxRiskReward)
        return;
    
    int ticket = OrderSend(Symbol(), OP_BUY, lotSize, entryPrice, 3, stopLoss, takeProfit, 
                          "FVG Buy Trade", MagicNumber, 0, clrGreen);
    
    if(ticket > 0)
    {
        tradesCount++;
        lastTradeDate = TimeCurrent();
        Print("Buy trade opened: ", ticket, " Entry: ", entryPrice, " SL: ", stopLoss, " TP: ", takeProfit);
        
        // Invalidate FVGs after trade
        fvg15M.valid = false;
        fvg4H.valid = false;
    }
    else
    {
        Print("Failed to open buy trade. Error: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| Execute sell trade                                              |
//+------------------------------------------------------------------+
void ExecuteSellTrade()
{
    if(IsTradeOpen())
        return;
    
    double entryPrice = Bid;
    double stopLoss = GetSwingHigh(); // Get recent swing high
    double takeProfit = 0;
    double lotSize = 0;
    double stopDistance = stopLoss - entryPrice; // Declare stopDistance variable
    
    // Check if stop distance is valid
    if(stopDistance <= 0)
    {
        Print("Invalid stop distance for sell trade: ", stopDistance);
        return;
    }
    
    // Calculate position size based on settings
    if(UseFixedLot)
    {
        lotSize = FixedLotSize;
    }
    else
    {
        // Calculate position size based on risk
        double riskAmount = AccountBalance() * (RiskPercent / 100);
        lotSize = CalculateLotSize(riskAmount, stopDistance);
    }
    
    // Calculate take profit based on risk reward ratio
    double rewardDistance = stopDistance * MinRiskReward;
    takeProfit = entryPrice - rewardDistance;
    
    // Validate risk reward ratio
    if(rewardDistance / stopDistance < MinRiskReward || rewardDistance / stopDistance > MaxRiskReward)
        return;
    
    int ticket = OrderSend(Symbol(), OP_SELL, lotSize, entryPrice, 3, stopLoss, takeProfit, 
                          "FVG Sell Trade", MagicNumber, 0, clrRed);
    
    if(ticket > 0)
    {
        tradesCount++;
        lastTradeDate = TimeCurrent();
        Print("Sell trade opened: ", ticket, " Entry: ", entryPrice, " SL: ", stopLoss, " TP: ", takeProfit);
        
        // Invalidate FVGs after trade
        fvg15M.valid = false;
        fvg4H.valid = false;
    }
    else
    {
        Print("Failed to open sell trade. Error: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| Calculate lot size based on risk                                |
//+------------------------------------------------------------------+
double CalculateLotSize(double riskAmount, double stopDistance)
{
    double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
    double tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
    double lotSize = riskAmount / (stopDistance / tickSize * tickValue);
    
    // Normalize lot size
    double minLot = MarketInfo(Symbol(), MODE_MINLOT);
    double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
    double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
    
    lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
    lotSize = NormalizeDouble(lotSize / lotStep, 0) * lotStep;
    
    return lotSize;
}

//+------------------------------------------------------------------+
//| Get recent swing low                                            |
//+------------------------------------------------------------------+
double GetSwingLow()
{
    double swingLow = Low[1];
    
    // Look for lowest low in last 10 bars
    for(int i = 1; i <= 10; i++)
    {
        if(Low[i] < swingLow)
            swingLow = Low[i];
    }
    
    return swingLow - (10 * Point); // Add small buffer
}

//+------------------------------------------------------------------+
//| Get recent swing high                                           |
//+------------------------------------------------------------------+
double GetSwingHigh()
{
    double swingHigh = High[1];
    
    // Look for highest high in last 10 bars
    for(int i = 1; i <= 10; i++)
    {
        if(High[i] > swingHigh)
            swingHigh = High[i];
    }
    
    return swingHigh + (10 * Point); // Add small buffer
}

//+------------------------------------------------------------------+
//| Check if trade is already open                                  |
//+------------------------------------------------------------------+
bool IsTradeOpen()
{
    for(int i = 0; i < OrdersTotal(); i++)
    {
        if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol())
        {
            return true;
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Check if current time is London session                         |
//+------------------------------------------------------------------+
bool IsLondonSession()
{
    int hour = TimeHour(TimeCurrent());
    // London session: 8:00 - 17:00 GMT
    return (hour >= 8 && hour <= 17);
}

//+------------------------------------------------------------------+
//| Draw FVG rectangles on chart                                    |
//+------------------------------------------------------------------+
void DrawFVGRectangles()
{
    // Draw 4H FVG
    if(fvg4H.valid)
    {
        string name4H = "FVG_4H_" + TimeToStr(fvg4H.time);
        ObjectCreate(name4H, OBJ_RECTANGLE, 0, fvg4H.time, fvg4H.high, fvg4H.time + 4*3600, fvg4H.low);
        ObjectSet(name4H, OBJPROP_COLOR, fvg4H.direction == 1 ? clrLightGreen : clrLightCoral);
        ObjectSet(name4H, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet(name4H, OBJPROP_WIDTH, 1);
    }
    
    // Draw 15M FVG
    if(fvg15M.valid)
    {
        string name15M = "FVG_15M_" + TimeToStr(fvg15M.time);
        ObjectCreate(name15M, OBJ_RECTANGLE, 0, fvg15M.time, fvg15M.high, fvg15M.time + 15*60, fvg15M.low);
        ObjectSet(name15M, OBJPROP_COLOR, fvg15M.direction == 1 ? clrGreen : clrRed);
        ObjectSet(name15M, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet(name15M, OBJPROP_WIDTH, 2);
    }
}