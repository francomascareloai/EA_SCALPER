
//+------------------------------------------------------------------+
//| Test Grid EA                                                     |
//+------------------------------------------------------------------+
#property copyright "Test"
#property version   "1.00"

#include <Trade\Trade.mqh>
CTrade trade;

input double InitialLot = 0.01;
input double Multiplier = 2.0;
input int GridStep = 100;

void OnTick()
{
    // Grid trading logic
    if(PositionsTotal() == 0)
    {
        trade.Buy(InitialLot);
    }
    else
    {
        // Martingale logic
        double lastLot = InitialLot;
        for(int i = 0; i < PositionsTotal(); i++)
        {
            if(PositionGetSymbol(i) == Symbol())
            {
                lastLot = PositionGetDouble(POSITION_VOLUME) * Multiplier;
                break;
            }
        }
        
        if(Bid < PositionGetDouble(POSITION_PRICE_OPEN) - GridStep * Point())
        {
            trade.Buy(lastLot);
        }
    }
}
