#property copyright "Matt Todorovski 2025"
#property link      "https://x.ai"
#property description "Shared as freeware in Free Forex Robots on Telegram"
#property version   "1.02"
#property strict

input int MagicNumber = 202503221;
input double InitialLotSize = 0.01;
input double RecoveryMultiplier = 1.5;

double TradeLotSize;
double TradeDirection;
int RecoveryStep = 0;
double TakeProfit = 20;
int ATRPeriod = 14;
double ATRThresholdMultiplier = 1.5;
int EMAFastPeriod = 15;
int EMASlowPeriod = 20;
int EMALongPeriod = 200;
double ATRMinThreshold = 20.0;
double ATRMultiplier = 2.0;
int MaxRecoverySteps = 50;

int OnInit()
{
    TradeLotSize = InitialLotSize;
    return (INIT_SUCCEEDED);
}

void OnTick()
{
    if (OrdersTotal() == 0)
    {
        if (CheckVolatility() && CheckEMACrossover())
        {
            OpenInitialTrade();
        }
        return;
    }
    ManageTrades();
}

bool CheckVolatility()
{
    double currentATR = iATR(Symbol(), 0, ATRPeriod, 0);
    double previousATR = iATR(Symbol(), 0, ATRPeriod, 1);
    double threshold = previousATR * ATRThresholdMultiplier;
    if (currentATR > threshold && currentATR >= ATRMinThreshold * Point * 10)
    {
        return true;
    }
    return false;
}

bool CheckEMACrossover()
{
    double EMAFast = iMA(Symbol(), 0, EMAFastPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
    double EMASlow = iMA(Symbol(), 0, EMASlowPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
    double EMA200 = iMA(Symbol(), 0, EMALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
    double currentPrice = Close[0];
    if (EMAFast > EMASlow && currentPrice > EMA200)
    {
        TradeDirection = 1.0;
        return true;
    }
    else if (EMAFast < EMASlow && currentPrice < EMA200)
    {
        TradeDirection = -1.0;
        return true;
    }
    return false;
}

void OpenInitialTrade()
{
    double price = (TradeDirection > 0) ? Ask : Bid;
    int ticket;
    if (TradeDirection > 0)
    {
        ticket = OrderSend(Symbol(), OP_BUY, TradeLotSize, price, 3, 0, 0, "", MagicNumber);
        if (ticket < 0)
            Print("Error opening BUY order: ", GetLastError());
    }
    else
    {
        ticket = OrderSend(Symbol(), OP_SELL, TradeLotSize, price, 3, 0, 0, "", MagicNumber);
        if (ticket < 0)
            Print("Error opening SELL order: ", GetLastError());
    }
}

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
        return;
    }
    CheckRecoveryZone();
}

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
    double dynamicRecoveryDistance = iATR(Symbol(), 0, ATRPeriod, 0) * ATRMultiplier / Point / 10;
    if (TradeDirection > 0 && currentPrice <= entryPrice - dynamicRecoveryDistance * Point * 10)
    {
        RecoveryTrade(OP_SELL);
    }
    else if (TradeDirection < 0 && currentPrice >= entryPrice + dynamicRecoveryDistance * Point * 10)
    {
        RecoveryTrade(OP_BUY);
    }
}

void RecoveryTrade(int orderType)
{
    TradeLotSize *= RecoveryMultiplier;
    double price = (orderType == OP_BUY) ? Ask : Bid;
    int ticket = OrderSend(Symbol(), orderType, TradeLotSize, price, 3, 0, 0, "", MagicNumber);
    if (ticket >= 0)
    {
        RecoveryStep++;
    }
    else
    {
        Print("Error opening recovery trade: ", GetLastError());
    }
}

void CloseAllTrades()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == MagicNumber)
        {
            bool success = OrderClose(OrderTicket(), OrderLots(), (OrderType() == OP_BUY ? Bid : Ask), 3);
            if (!success)
                Print("Error closing order #", OrderTicket(), ": ", GetLastError());
        }
    }
    RecoveryStep = 0;
    TradeLotSize = InitialLotSize;
}