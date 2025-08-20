
//+------------------------------------------------------------------+
//|       Breakout Pending Orders EA with Grid & Trailing SL        |
//+------------------------------------------------------------------+
#property strict

// === INPUTS ===
input int    LookbackCandles       = 10;
input int    PendingOffsetPoints   = 20;
input int    StopLossPoints        = 300;
input int    TakeProfitPoints      = 500;
input double LotSize               = 0.1;

input int    TrailingStart         = 100;
input int    TrailingDistance      = 50;

input bool   UseGrid               = true;
input int    GridStepPoints        = 200;
input int    MaxGridOrders         = 5;

input int    StartHour             = 9;
input int    EndHour               = 21;
input int    MaxAllowedSpread      = 30;

input int    MagicNumber           = 123456;

// === GLOBAL VARIABLES ===
datetime lastPendingTime = 0;
bool pendingOrdersPlaced = false;

//+------------------------------------------------------------------+
int OnInit() {
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnTick() {
    DeleteExpiredPendingOrders();
    if (!IsTradeTime() || !IsSpreadOkay()) return;

    if (!HasMarketOrder()) {
        if (!pendingOrdersPlaced || (TimeCurrent() - lastPendingTime >= 3600)) {
            CancelPendingOrders();
            PlacePendingOrders();
            pendingOrdersPlaced = true;
            lastPendingTime = TimeCurrent();
        }
    }

    CheckTriggeredOrders();

    if (UseGrid) HandleGrid();
    ApplyTrailingStop();
}

//+------------------------------------------------------------------+
bool IsTradeTime() {
    int hour = TimeHour(TimeCurrent());
    return (hour >= StartHour && hour < EndHour);
}

bool IsSpreadOkay() {
    int spread = (int)((Ask - Bid) / Point);
    return spread <= MaxAllowedSpread;
}

bool HasMarketOrder() {
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() &&
                (OrderType() == OP_BUY || OrderType() == OP_SELL)) return true;
        }
    }
    return false;
}

void PlacePendingOrders() {
    double high = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, LookbackCandles, 1));
    double low  = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, LookbackCandles, 1));

    double buyPrice  = NormalizeDouble(high + PendingOffsetPoints * Point, Digits);
    double sellPrice = NormalizeDouble(low - PendingOffsetPoints * Point, Digits);

    double slBuy     = buyPrice - StopLossPoints * Point;
    double tpBuy     = buyPrice + TakeProfitPoints * Point;
    double slSell    = sellPrice + StopLossPoints * Point;
    double tpSell    = sellPrice - TakeProfitPoints * Point;

    OrderSend(Symbol(), OP_BUYSTOP, LotSize, buyPrice, 3, slBuy, tpBuy, "Breakout Buy", MagicNumber, 0, clrBlue);
    OrderSend(Symbol(), OP_SELLSTOP, LotSize, sellPrice, 3, slSell, tpSell, "Breakout Sell", MagicNumber, 0, clrRed);
}

void CancelPendingOrders() {
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if ((OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP) &&
                OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
                OrderDelete(OrderTicket());
            }
        }
    }
    pendingOrdersPlaced = false;
}

void CheckTriggeredOrders() {
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if ((OrderType() == OP_BUY || OrderType() == OP_SELL) &&
                OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
                DeleteOppositePending(OrderType());
                break;
            }
        }
    }
}

void DeleteOppositePending(int typeExecuted) {
    int oppositeType = (typeExecuted == OP_BUY) ? OP_SELLSTOP : OP_BUYSTOP;

    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderType() == oppositeType && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
                OrderDelete(OrderTicket());
            }
        }
    }
    pendingOrdersPlaced = false;
}

void HandleGrid() {
    double avgPrice = 0;
    int gridCount = 0;
    int direction = 0;

    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if ((OrderType() == OP_BUY || OrderType() == OP_SELL) &&
                OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
                avgPrice += OrderOpenPrice();
                gridCount++;
                if (OrderType() == OP_BUY) direction = 1;
                else if (OrderType() == OP_SELL) direction = -1;
            }
        }
    }

    if (gridCount == 0 || gridCount >= MaxGridOrders) return;
    avgPrice /= gridCount;

    double price = (direction == 1) ? Ask : Bid;
    double dist = MathAbs(price - avgPrice) / Point;

    if (dist >= GridStepPoints) {
        double sl = (direction == 1) ? price - StopLossPoints * Point : price + StopLossPoints * Point;
        double tp = (direction == 1) ? price + TakeProfitPoints * Point : price - TakeProfitPoints * Point;
        int type = (direction == 1) ? OP_BUY : OP_SELL;
        OrderSend(Symbol(), type, LotSize, price, 3, sl, tp, "Grid", MagicNumber, 0, clrGreen);
    }
}

void ApplyTrailingStop() {
    double avgPrice = 0;
    int totalOrders = 0;

    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if ((OrderType() == OP_BUY || OrderType() == OP_SELL) &&
                OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
                avgPrice += OrderOpenPrice();
                totalOrders++;
            }
        }
    }

    if (totalOrders == 0) return;
    avgPrice /= totalOrders;

    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol()) continue;

            double trailLevel = 0;
            if (OrderType() == OP_BUY) {
                if (Bid - avgPrice >= TrailingStart * Point) {
                    trailLevel = Bid - TrailingDistance * Point;
                    if (OrderStopLoss() < trailLevel)
                        OrderModify(OrderTicket(), OrderOpenPrice(), trailLevel, OrderTakeProfit(), 0, clrBlue);
                }
            } else if (OrderType() == OP_SELL) {
                if (avgPrice - Ask >= TrailingStart * Point) {
                    trailLevel = Ask + TrailingDistance * Point;
                    if (OrderStopLoss() > trailLevel || OrderStopLoss() == 0)
                        OrderModify(OrderTicket(), OrderOpenPrice(), trailLevel, OrderTakeProfit(), 0, clrRed);
                }
            }
        }
    }
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
void DeleteExpiredPendingOrders() {
    if (!pendingOrdersPlaced) return;
    if (TimeCurrent() - lastPendingTime < 3600) return;

    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if ((OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP) &&
                OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
                OrderDelete(OrderTicket());
            }
        }
    }
    pendingOrdersPlaced = false;
}
