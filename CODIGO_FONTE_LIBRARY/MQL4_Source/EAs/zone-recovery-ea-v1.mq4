//+------------------------------------------------------------------+
//|                   Zone Recovery Strategy with EMA Direction      |
//|                        Developed in MQL4                        |
//+------------------------------------------------------------------+
#property strict

// Input Parameters
input double InitialLotSize = 0.1;
input double RecoveryMultiplier = 2.0;
input double RecoveryDistance = 50; // In pips
input double TakeProfit = 20;       // In pips
input double MaxRecoverySteps = 10;
input int ATRPeriod = 14;
input double ATRThresholdMultiplier = 1.5;
input int EMAFastPeriod = 15;
input int EMASlowPeriod = 20;
input int MagicNumber = 12345;

// Variables
double TradeLotSize;
double TradeDirection;
int RecoveryStep = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    TradeLotSize = InitialLotSize;
    Print("Zone Recovery EA Initialized with EMA Direction.");
    return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    if (OrdersTotal() == 0)
    {
        if (CheckVolatility() && CheckEMACrossover())
        {
            OpenInitialTrade();
        }
        else
        {
            Print("No valid signal. Waiting for EMA crossover and volatility.");
        }
        return;
    }

    ManageTrades();
}

//+------------------------------------------------------------------+
//| Check Market Volatility using ATR                                |
//+------------------------------------------------------------------+
bool CheckVolatility()
{
    double currentATR = iATR(Symbol(), 0, ATRPeriod, 0);
    double previousATR = iATR(Symbol(), 0, ATRPeriod, 1);

    double threshold = previousATR * ATRThresholdMultiplier;

    if (currentATR > threshold)
    {
        Print("Volatility Increasing. ATR: ", currentATR);
        return true;
    }

    Print("Low Volatility. Current ATR: ", currentATR, " | Threshold: ", threshold);
    return false;
}

//+------------------------------------------------------------------+
//| Check EMA Crossover for Trade Direction                         |
//+------------------------------------------------------------------+
bool CheckEMACrossover()
{
    double EMAFast = iMA(Symbol(), 0, EMAFastPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
    double EMASlow = iMA(Symbol(), 0, EMASlowPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);

    if (EMAFast > EMASlow)
    {
        TradeDirection = 1.0; // Buy
        Print("EMA Crossover Detected: Buy Signal (EMA15 > EMA20)");
        return true;
    }
    else if (EMAFast < EMASlow)
    {
        TradeDirection = -1.0; // Sell
        Print("EMA Crossover Detected: Sell Signal (EMA15 < EMA20)");
        return true;
    }

    Print("No EMA Crossover Signal.");
    return false;
}

//+------------------------------------------------------------------+
//| Open Initial Trade                                               |
//+------------------------------------------------------------------+
void OpenInitialTrade()
{
    double price = (TradeDirection > 0) ? Ask : Bid;

    if (TradeDirection > 0)
        OrderSend(Symbol(), OP_BUY, TradeLotSize, price, 3, 0, 0, "Initial Buy", MagicNumber);
    else
        OrderSend(Symbol(), OP_SELL, TradeLotSize, price, 3, 0, 0, "Initial Sell", MagicNumber);

    Print("Initial Trade Opened: ", TradeDirection > 0 ? "Buy" : "Sell");
}

//+------------------------------------------------------------------+
//| Manage Trades and Zone Recovery                                  |
//+------------------------------------------------------------------+
void ManageTrades()
{
    double totalProfit = 0;
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == MagicNumber)
        {
            totalProfit += OrderProfit();
        }
    }

    if (totalProfit >= TakeProfit * Point * 10)
    {
        CloseAllTrades();
        Print("Target Reached. All Trades Closed.");
        return;
    }

    CheckRecoveryZone();
}

//+------------------------------------------------------------------+
//| Check and Apply Recovery Strategy                                |
//+------------------------------------------------------------------+
void CheckRecoveryZone()
{
    if (OrdersTotal() == 0 || RecoveryStep >= MaxRecoverySteps)
        return;

    double entryPrice = 0;
    double currentPrice = (TradeDirection > 0) ? Bid : Ask;

    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == MagicNumber)
        {
            entryPrice = OrderOpenPrice();
            break;
        }
    }

    if (TradeDirection > 0 && currentPrice <= entryPrice - RecoveryDistance * Point * 10)
    {
        RecoveryTrade(OP_SELL);
    }
    else if (TradeDirection < 0 && currentPrice >= entryPrice + RecoveryDistance * Point * 10)
    {
        RecoveryTrade(OP_BUY);
    }
}

//+------------------------------------------------------------------+
//| Open Recovery Trade                                              |
//+------------------------------------------------------------------+
void RecoveryTrade(int orderType)
{
    TradeLotSize *= RecoveryMultiplier;
    double price = (orderType == OP_BUY) ? Ask : Bid;

    if (OrderSend(Symbol(), orderType, TradeLotSize, price, 3, 0, 0, "Recovery Trade", MagicNumber))
    {
        RecoveryStep++;
        Print("Recovery Trade Opened: ", orderType == OP_BUY ? "Buy" : "Sell", " | Step: ", RecoveryStep);
    }
}

//+------------------------------------------------------------------+
//| Close All Trades                                                 |
//+------------------------------------------------------------------+
void CloseAllTrades()
{
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == MagicNumber)
        {
            OrderClose(OrderTicket(), OrderLots(), (OrderType() == OP_BUY ? Bid : Ask), 3);
        }
    }
    RecoveryStep = 0;
    TradeLotSize = InitialLotSize;
}
