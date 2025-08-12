//+------------------------------------------------------------------+
//|                                           BreakoutRobot.mq5      |
//|                                  Copyright 2025, Your Company    |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\PositionInfo.mqh>

//--- Input parameters
input group "=== Breakout Settings ==="
input int      InpLookbackCandles = 20;        // Number of candles to check for high/low
input int      InpBreakoutBuffer  = 10;        // Buffer in points for breakout level

input group "=== Risk Management ==="
input double   InpLotSize        = 0.1;        // Lot size
input int      InpStopLoss       = 100;        // Stop Loss in points
input int      InpTakeProfit     = 200;        // Take Profit in points
input bool     InpUseTrailingStop = true;      // Use trailing stop
input int      InpTrailingStart  = 50;         // Trailing stop start in points
input int      InpTrailingStep   = 10;         // Trailing stop step in points

input group "=== News Filter ==="
input bool     InpUseNewsFilter  = true;       // Enable news filter
input int      InpNewsMinutesBefore = 30;      // Minutes before news to avoid trading
input int      InpNewsMinutesAfter  = 30;      // Minutes after news to avoid trading
input string   InpNewsCurrencies = "USD,EUR,GBP,JPY,CAD,AUD,NZD,CHF"; // Currencies to monitor

input group "=== Time Filter ==="
input bool     InpUseTimeFilter  = false;      // Enable time filter
input string   InpStartTime      = "08:00";    // Start trading time
input string   InpEndTime        = "18:00";    // End trading time

input group "=== Other Settings ==="
input int      InpMagicNumber    = 12345;      // Magic number
input string   InpComment        = "BreakoutRobot"; // Order comment

//--- Global variables
CTrade         trade;
COrderInfo     orderInfo;
CPositionInfo  positionInfo;

double         g_upperLevel = 0;
double         g_lowerLevel = 0;
datetime       g_lastNewsCheck = 0;
bool           g_newsFilterActive = false;
datetime       g_lastBarTime = 0;
ulong          g_buyOrderTicket = 0;
ulong          g_sellOrderTicket = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    trade.SetExpertMagicNumber(InpMagicNumber);
    trade.SetMarginMode();
    trade.SetTypeFillingBySymbol(Symbol());
    
    // Initialize levels
    CalculateBreakoutLevels();
    
    Print("Breakout Robot EA initialized successfully");
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Delete pending orders on EA removal
    if(reason == REASON_REMOVE)
    {
        DeleteAllPendingOrders();
    }
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check if new bar formed
    if(!IsNewBar()) return;
    
    // Update news filter status
    UpdateNewsFilter();
    
    // Check time filter
    if(InpUseTimeFilter && !IsWithinTradingHours()) return;
    
    // Check if news filter is active
    if(InpUseNewsFilter && g_newsFilterActive)
    {
        DeleteAllPendingOrders();
        return;
    }
    
    // Calculate new breakout levels
    CalculateBreakoutLevels();
    
    // Manage existing positions
    ManagePositions();
    
    // Check if we already have an open position - no stacking
    if(HasOpenPosition()) return;
    
    // Place pending orders if none exist
    if(!HasPendingOrders())
    {
        PlacePendingOrders();
    }
    else
    {
        // Update existing pending orders with new levels
        UpdatePendingOrders();
    }
}

//+------------------------------------------------------------------+
//| Check if new bar formed                                          |
//+------------------------------------------------------------------+
bool IsNewBar()
{
    datetime currentBarTime = iTime(Symbol(), PERIOD_CURRENT, 0);
    if(currentBarTime != g_lastBarTime)
    {
        g_lastBarTime = currentBarTime;
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| Calculate breakout levels                                        |
//+------------------------------------------------------------------+
void CalculateBreakoutLevels()
{
    double highest = 0;
    double lowest = DBL_MAX;
    
    // Find highest high and lowest low of last N candles (excluding current)
    for(int i = 1; i <= InpLookbackCandles; i++)
    {
        double high = iHigh(Symbol(), PERIOD_CURRENT, i);
        double low = iLow(Symbol(), PERIOD_CURRENT, i);
        
        if(high > highest) highest = high;
        if(low < lowest) lowest = low;
    }
    
    double point = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
    g_upperLevel = highest + InpBreakoutBuffer * point;
    g_lowerLevel = lowest - InpBreakoutBuffer * point;
    
    // Normalize prices
    int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
    g_upperLevel = NormalizeDouble(g_upperLevel, digits);
    g_lowerLevel = NormalizeDouble(g_lowerLevel, digits);
}

//+------------------------------------------------------------------+
//| Place pending orders                                             |
//+------------------------------------------------------------------+
void PlacePendingOrders()
{
    double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
    double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    double point = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
    
    // Only place orders if levels are away from current price
    if(g_upperLevel > ask + 10 * point)
    {
        // Place Buy Stop order
        double sl = g_upperLevel - InpStopLoss * point;
        double tp = g_upperLevel + InpTakeProfit * point;
        
        if(trade.BuyStop(InpLotSize, g_upperLevel, Symbol(), sl, tp, ORDER_TIME_GTC, 0, InpComment))
        {
            g_buyOrderTicket = trade.ResultOrder();
        }
    }
    
    if(g_lowerLevel < bid - 10 * point)
    {
        // Place Sell Stop order
        double sl = g_lowerLevel + InpStopLoss * point;
        double tp = g_lowerLevel - InpTakeProfit * point;
        
        if(trade.SellStop(InpLotSize, g_lowerLevel, Symbol(), sl, tp, ORDER_TIME_GTC, 0, InpComment))
        {
            g_sellOrderTicket = trade.ResultOrder();
        }
    }
}

//+------------------------------------------------------------------+
//| Update existing pending orders                                   |
//+------------------------------------------------------------------+
void UpdatePendingOrders()
{
    double point = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
    
    // Update Buy Stop order
    if(g_buyOrderTicket > 0 && orderInfo.Select(g_buyOrderTicket))
    {
        if(MathAbs(orderInfo.PriceOpen() - g_upperLevel) > 5 * point)
        {
            double sl = g_upperLevel - InpStopLoss * point;
            double tp = g_upperLevel + InpTakeProfit * point;
            
            if(!trade.OrderModify(g_buyOrderTicket, g_upperLevel, sl, tp, ORDER_TIME_GTC, 0))
            {
                // If modification fails, delete and recreate
                if(trade.OrderDelete(g_buyOrderTicket))
                    g_buyOrderTicket = 0;
            }
        }
    }
    
    // Update Sell Stop order
    if(g_sellOrderTicket > 0 && orderInfo.Select(g_sellOrderTicket))
    {
        if(MathAbs(orderInfo.PriceOpen() - g_lowerLevel) > 5 * point)
        {
            double sl = g_lowerLevel + InpStopLoss * point;
            double tp = g_lowerLevel - InpTakeProfit * point;
            
            if(!trade.OrderModify(g_sellOrderTicket, g_lowerLevel, sl, tp, ORDER_TIME_GTC, 0))
            {
                // If modification fails, delete and recreate
                if(trade.OrderDelete(g_sellOrderTicket))
                    g_sellOrderTicket = 0;
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Check if we have open positions                                  |
//+------------------------------------------------------------------+
bool HasOpenPosition()
{
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(positionInfo.SelectByIndex(i))
        {
            if(positionInfo.Symbol() == Symbol() && positionInfo.Magic() == InpMagicNumber)
            {
                return true;
            }
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Check if we have pending orders                                  |
//+------------------------------------------------------------------+
bool HasPendingOrders()
{
    bool hasBuyOrder = (g_buyOrderTicket > 0 && orderInfo.Select(g_buyOrderTicket));
    bool hasSellOrder = (g_sellOrderTicket > 0 && orderInfo.Select(g_sellOrderTicket));
    
    return (hasBuyOrder || hasSellOrder);
}

//+------------------------------------------------------------------+
//| Delete all pending orders                                        |
//+------------------------------------------------------------------+
void DeleteAllPendingOrders()
{
    for(int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if(orderInfo.SelectByIndex(i))
        {
            if(orderInfo.Symbol() == Symbol() && orderInfo.Magic() == InpMagicNumber)
            {
                if(trade.OrderDelete(orderInfo.Ticket()))
                {
                    if(orderInfo.Ticket() == g_buyOrderTicket)
                        g_buyOrderTicket = 0;
                    if(orderInfo.Ticket() == g_sellOrderTicket)
                        g_sellOrderTicket = 0;
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Manage existing positions (trailing stop)                       |
//+------------------------------------------------------------------+
void ManagePositions()
{
    if(!InpUseTrailingStop) return;
    
    double point = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
    
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(positionInfo.SelectByIndex(i))
        {
            if(positionInfo.Symbol() == Symbol() && positionInfo.Magic() == InpMagicNumber)
            {
                if(positionInfo.PositionType() == POSITION_TYPE_BUY)
                {
                    double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
                    double currentSL = positionInfo.StopLoss();
                    double openPrice = positionInfo.PriceOpen();
                    
                    // Check if position is in profit by trailing start amount
                    if(ask > openPrice + InpTrailingStart * point)
                    {
                        double newSL = ask - InpTrailingStart * point;
                        
                        // Move SL only if it's better than current
                        if(newSL > currentSL + InpTrailingStep * point || currentSL == 0)
                        {
                            trade.PositionModify(positionInfo.Ticket(), newSL, positionInfo.TakeProfit());
                        }
                    }
                }
                else if(positionInfo.PositionType() == POSITION_TYPE_SELL)
                {
                    double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
                    double currentSL = positionInfo.StopLoss();
                    double openPrice = positionInfo.PriceOpen();
                    
                    // Check if position is in profit by trailing start amount
                    if(bid < openPrice - InpTrailingStart * point)
                    {
                        double newSL = bid + InpTrailingStart * point;
                        
                        // Move SL only if it's better than current
                        if(newSL < currentSL - InpTrailingStep * point || currentSL == 0)
                        {
                            trade.PositionModify(positionInfo.Ticket(), newSL, positionInfo.TakeProfit());
                        }
                    }
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Update news filter status                                        |
//+------------------------------------------------------------------+
void UpdateNewsFilter()
{
    if(!InpUseNewsFilter) return;
    
    // Check news filter every minute
    if(TimeCurrent() - g_lastNewsCheck < 60) return;
    
    g_lastNewsCheck = TimeCurrent();
    g_newsFilterActive = IsNewsTime();
}

//+------------------------------------------------------------------+
//| Check if it's news time                                          |
//+------------------------------------------------------------------+
bool IsNewsTime()
{
    // This is a simplified news filter
    // In a real implementation, you would connect to a news feed API
    // or use a news calendar service
    
    MqlDateTime timeStruct;
    TimeToStruct(TimeCurrent(), timeStruct);
    
    // Avoid trading during major news times (simplified example)
    // Major news usually at: 8:30, 10:00, 14:00, 15:30 GMT
    if((timeStruct.hour == 8 && timeStruct.min >= 25 && timeStruct.min <= 35) ||
       (timeStruct.hour == 10 && timeStruct.min >= 0 && timeStruct.min <= 10) ||
       (timeStruct.hour == 14 && timeStruct.min >= 0 && timeStruct.min <= 10) ||
       (timeStruct.hour == 15 && timeStruct.min >= 25 && timeStruct.min <= 35))
    {
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Check if within trading hours                                    |
//+------------------------------------------------------------------+
bool IsWithinTradingHours()
{
    if(!InpUseTimeFilter) return true;
    
    MqlDateTime timeStruct;
    TimeToStruct(TimeCurrent(), timeStruct);
    
    int currentTime = timeStruct.hour * 100 + timeStruct.min;
    
    // Parse start and end times
    string startParts[];
    string endParts[];
    int startCount = StringSplit(InpStartTime, StringGetCharacter(":", 0), startParts);
    int endCount = StringSplit(InpEndTime, StringGetCharacter(":", 0), endParts);
    
    if(startCount < 2 || endCount < 2) return true; // Invalid time format
    
    int startTime = (int)StringToInteger(startParts[0]) * 100 + (int)StringToInteger(startParts[1]);
    int endTime = (int)StringToInteger(endParts[0]) * 100 + (int)StringToInteger(endParts[1]);
    
    if(startTime <= endTime)
    {
        return (currentTime >= startTime && currentTime <= endTime);
    }
    else
    {
        // Overnight session
        return (currentTime >= startTime || currentTime <= endTime);
    }
}

//+------------------------------------------------------------------+
//| Order event handler                                              |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                       const MqlTradeRequest& request,
                       const MqlTradeResult& result)
{
    // Handle order executions and deletions
    if(trans.type == TRADE_TRANSACTION_ORDER_DELETE)
    {
        if(trans.order == g_buyOrderTicket)
            g_buyOrderTicket = 0;
        if(trans.order == g_sellOrderTicket)
            g_sellOrderTicket = 0;
    }
}