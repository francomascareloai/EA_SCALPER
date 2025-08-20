//+------------------------------------------------------------------+ //| StepReversalEA.mq4 | //| Strategy: pip-step reversals | //+------------------------------------------------------------------+ #property strict

extern double PipStep = 10; extern double LotSize = 0.01; extern double StopLoss = 10; extern double TakeProfit = 10; extern int MagicNumber = 123456; extern int MaxPendingOrders = 100;

int lastStepLevel = 0; double lastBasePrice = 0;

int OnInit() { lastBasePrice = NormalizeDouble(Ask, Digits); return(INIT_SUCCEEDED); }

bool OrderExistsAtPrice(double price, int type) { for (int i = 0; i < OrdersTotal(); i++) { if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == MagicNumber) { if (OrderType() == type && MathAbs(OrderOpenPrice() - price) < (PipStep * Point / 2)) return true; } } return false; }

int CountPendingOrders() { int count = 0; for (int i = 0; i < OrdersTotal(); i++) { if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == MagicNumber) { if (OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP) count++; } } return count; }

void OnTick() { double currentPrice = NormalizeDouble(Ask, Digits); double stepSize = PipStep * Point;

int direction = (currentPrice > lastBasePrice) ? 1 : (currentPrice < lastBasePrice) ? -1 : 0;
int stepsMoved = int(MathAbs(currentPrice - lastBasePrice) / stepSize);

if (stepsMoved > lastStepLevel && direction != 0)
{
    for (int j = lastStepLevel + 1; j <= stepsMoved; j++)
    {
        if (CountPendingOrders() >= MaxPendingOrders) break;

        double orderPrice = lastBasePrice + direction * j * stepSize;
        double entryPrice = NormalizeDouble(orderPrice - direction * stepSize, Digits);

        if (direction > 0 && !OrderExistsAtPrice(entryPrice, OP_SELLSTOP))
        {
            OrderSend(Symbol(), OP_SELLSTOP, LotSize, entryPrice, 3,
                      NormalizeDouble(entryPrice + StopLoss * Point, Digits),
                      NormalizeDouble(entryPrice - TakeProfit * Point, Digits),
                      "Sell Stop", MagicNumber, 0, Red);
        }
        else if (direction < 0 && !OrderExistsAtPrice(entryPrice, OP_BUYSTOP))
        {
            OrderSend(Symbol(), OP_BUYSTOP, LotSize, entryPrice, 3,
                      NormalizeDouble(entryPrice - StopLoss * Point, Digits),
                      NormalizeDouble(entryPrice + TakeProfit * Point, Digits),
                      "Buy Stop", MagicNumber, 0, Blue);
        }
    }

    lastStepLevel = stepsMoved;
}

// Check for reversal trigger
for (int k = OrdersTotal() - 1; k >= 0; k--)
{
    if (OrderSelect(k, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == MagicNumber)
    {
        if ((OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderCloseTime() == 0)
        {
            double reversePrice = (OrderType() == OP_BUY) ? Bid - stepSize : Ask + stepSize;
            int pendingType = (OrderType() == OP_BUY) ? OP_SELLSTOP : OP_BUYSTOP;

            if (!OrderExistsAtPrice(NormalizeDouble(reversePrice, Digits), pendingType) && CountPendingOrders() < MaxPendingOrders)
            {
                double sl = (pendingType == OP_BUYSTOP) ? reversePrice - StopLoss * Point : reversePrice + StopLoss * Point;
                double tp = (pendingType == OP_BUYSTOP) ? reversePrice + TakeProfit * Point : reversePrice - TakeProfit * Point;
                string comment = (pendingType == OP_BUYSTOP) ? "Buy Stop" : "Sell Stop";

                OrderSend(Symbol(), pendingType, LotSize, NormalizeDouble(reversePrice, Digits), 3,
                          NormalizeDouble(sl, Digits), NormalizeDouble(tp, Digits),
                          comment, MagicNumber, 0, Yellow);

                lastBasePrice = currentPrice;
                lastStepLevel = 0;
                break;
            }
        }
    }
}
}