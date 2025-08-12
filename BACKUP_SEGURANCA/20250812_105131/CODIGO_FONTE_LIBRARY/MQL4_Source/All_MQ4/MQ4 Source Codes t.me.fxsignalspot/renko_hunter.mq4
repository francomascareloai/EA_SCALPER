//-------------------------------------------------------------
//                                     renko_hunter.mq4    EA |
//-------------------------------------------------------------


#property copyright "Copyright © 2015, Peter Malecki, Roland Malecki"
#property link      "http://www.dicdata.de/"

#include <stdlib.mqh>
#include <WinUser32.mqh>

// exported variables
extern double BuyLots27 = 0.2;
extern int BuyStoploss27 = 100;
extern int BuyTakeprofit27 = 100;
extern double SellLots22 = 0.2;
extern int SellStoploss22 = 100;
extern int SellTakeprofit22 = 100;


// local variables
double PipValue=1;    // this variable is here to support 5-digit brokers
bool Terminated = false;
string LF = "\n";  // use this in custom or utility blocks where you need line feeds
int NDigits = 4;   // used mostly for NormalizeDouble in Flex type blocks
int ObjCount = 0;  // count of all objects created on the chart, allows creation of objects with unique names
int current = 0;


int init()
{
    NDigits = Digits;
    
    if (false) ObjectsDeleteAll();      // clear the chart
    
    
    
    
    Comment("");    // clear the chart
    return (0);
}

// Expert start
int start()
{
    if (Bars < 10)
    {
        Comment("Not enough bars");
        return (0);
    }
    if (Terminated == true)
    {
        Comment("EA Terminated.");
        return (0);
    }
    
    OnEveryTick5();
    return (0);
}

void OnEveryTick5()
{
    PipValue = 1;
    if (NDigits == 3 || NDigits == 5) PipValue = 10;
    
    IfOrderExists28();
    IfOrderExists39();
    CustomCode4();
    
}

void IfOrderExists28()
{
    bool exists = false;
    for (int i=OrdersTotal()-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == 38)
        {
            exists = true;
        }
    }
    else
    {
        Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
    }
    
    if (exists)
    {
        TechnicalAnalysis2x31();
        
    }
}

void TechnicalAnalysis2x31()
{
    if ((Close[2] > Open[2]) && (Close[1] < Open[1]))
    {
        CloseOrder35();
        
    }
}

void CloseOrder35()
{
    int orderstotal = OrdersTotal();
    int orders = 0;
    int ordticket[90][2];
    for (int i = 0; i < orderstotal; i++)
    {
        bool sel = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderType() != OP_BUY || OrderSymbol() != Symbol() || OrderMagicNumber() != 38)
        {
            continue;
        }
        ordticket[orders][0] = OrderOpenTime();
        ordticket[orders][1] = OrderTicket();
        orders++;
    }
    if (orders > 1)
    {
        ArrayResize(ordticket,orders);
        ArraySort(ordticket);
    }
    for (i = 0; i < orders; i++)
    {
        if (OrderSelect(ordticket[i][1], SELECT_BY_TICKET) == true)
        {
            bool ret = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 4, Yellow);
            if (ret == false)
            Print("OrderClose() error - ", ErrorDescription(GetLastError()));
        }
    }
    
}

void IfOrderExists39()
{
    bool exists = false;
    for (int i=OrdersTotal()-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == 39)
        {
            exists = true;
        }
    }
    else
    {
        Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
    }
    
    if (exists)
    {
        TechnicalAnalysis2x34();
        
    }
}

void TechnicalAnalysis2x34()
{
    if ((Close[2] < Open[2]) && (Close[1] > Open[1]))
    {
        CloseOrder36();
        
    }
}

void CloseOrder36()
{
    int orderstotal = OrdersTotal();
    int orders = 0;
    int ordticket[90][2];
    for (int i = 0; i < orderstotal; i++)
    {
        bool sel = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderType() != OP_SELL || OrderSymbol() != Symbol() || OrderMagicNumber() != 39)
        {
            continue;
        }
        ordticket[orders][0] = OrderOpenTime();
        ordticket[orders][1] = OrderTicket();
        orders++;
    }
    if (orders > 1)
    {
        ArrayResize(ordticket,orders);
        ArraySort(ordticket);
    }
    for (i = 0; i < orders; i++)
    {
        if (OrderSelect(ordticket[i][1], SELECT_BY_TICKET) == true)
        {
            bool ret = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 4, Yellow);
            if (ret == false)
            Print("OrderClose() error - ", ErrorDescription(GetLastError()));
        }
    }
    
}

void CustomCode4()
{
    
    TechnicalAnalysis2x25();
    TechnicalAnalysis2x19();
    
}

void TechnicalAnalysis2x25()
{
    if ((iMA(NULL, NULL,21,0,MODE_EMA,PRICE_CLOSE,current) > iMA(NULL, NULL,50,0,MODE_EMA,PRICE_CLOSE,current)) && (Ask > iMA(NULL, NULL,21,0,MODE_EMA,PRICE_CLOSE,current)))
    {
        TechnicalAnalysis3x26();
        
    }
}

void TechnicalAnalysis3x26()
{
    if ((Close[3] > Open[3]) && (Close[2] > Open[2]) && (Close[1] > Open[1]))
    {
        IfOrderDoesNotExist16();
        
    }
}

void IfOrderDoesNotExist16()
{
    bool exists = false;
    for (int i=OrdersTotal()-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == 38)
        {
            exists = true;
        }
    }
    else
    {
        Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
    }
    
    if (exists == false)
    {
        BuyOrder27();
        IfOrderExists17();
        
    }
}

void BuyOrder27()
{
    double SL = Ask - BuyStoploss27*PipValue*Point;
    if (BuyStoploss27 == 0) SL = 0;
    double TP = Ask + BuyTakeprofit27*PipValue*Point;
    if (BuyTakeprofit27 == 0) TP = 0;
    int ticket = -1;
    if (true)
    ticket = OrderSend(Symbol(), OP_BUY, BuyLots27, Ask, 4, 0, 0, "Buy Renko", 38, 0, Blue);
    else
    ticket = OrderSend(Symbol(), OP_BUY, BuyLots27, Ask, 4, SL, TP, "Buy Renko", 38, 0, Blue);
    if (ticket > -1)
    {
        if (true)
        {
            bool sel = OrderSelect(ticket, SELECT_BY_TICKET);
            bool ret = OrderModify(OrderTicket(), OrderOpenPrice(), SL, TP, 0, Blue);
            if (ret == false)
            Print("OrderModify() error - ", ErrorDescription(GetLastError()));
        }
            
    }
    else
    {
        Print("OrderSend() error - ", ErrorDescription(GetLastError()));
    }
}

void IfOrderExists17()
{
    bool exists = false;
    for (int i=OrdersTotal()-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == 39)
        {
            exists = true;
        }
    }
    else
    {
        Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
    }
    
    if (exists)
    {
        CloseOrder18();
        
    }
}

void CloseOrder18()
{
    int orderstotal = OrdersTotal();
    int orders = 0;
    int ordticket[90][2];
    for (int i = 0; i < orderstotal; i++)
    {
        bool sel = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderType() != OP_SELL || OrderSymbol() != Symbol() || OrderMagicNumber() != 39)
        {
            continue;
        }
        ordticket[orders][0] = OrderOpenTime();
        ordticket[orders][1] = OrderTicket();
        orders++;
    }
    if (orders > 1)
    {
        ArrayResize(ordticket,orders);
        ArraySort(ordticket);
    }
    for (i = 0; i < orders; i++)
    {
        if (OrderSelect(ordticket[i][1], SELECT_BY_TICKET) == true)
        {
            bool ret = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 4, Yellow);
            if (ret == false)
            Print("OrderClose() error - ", ErrorDescription(GetLastError()));
        }
    }
    
}

void TechnicalAnalysis2x19()
{
    if ((iMA(NULL, NULL,21,0,MODE_EMA,PRICE_CLOSE,current) < iMA(NULL, NULL,50,0,MODE_EMA,PRICE_CLOSE,current)) && (Bid < iMA(NULL, NULL,21,0,MODE_EMA,PRICE_CLOSE,current)))
    {
        TechnicalAnalysis3x20();
        
    }
}

void TechnicalAnalysis3x20()
{
    if ((Close[3] < Open[3]) && (Close[2] < Open[2]) && (Close[1] < Open[1]))
    {
        IfOrderDoesNotExist21();
        
    }
}

void IfOrderDoesNotExist21()
{
    bool exists = false;
    for (int i=OrdersTotal()-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == 39)
        {
            exists = true;
        }
    }
    else
    {
        Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
    }
    
    if (exists == false)
    {
        SellOrder22();
        IfOrderExists24();
        
    }
}

void SellOrder22()
{
    double SL = Bid + SellStoploss22*PipValue*Point;
    if (SellStoploss22 == 0) SL = 0;
    double TP = Bid - SellTakeprofit22*PipValue*Point;
    if (SellTakeprofit22 == 0) TP = 0;
    int ticket = -1;
    if (true)
    ticket = OrderSend(Symbol(), OP_SELL, SellLots22, Bid, 4, 0, 0, "Sell Renko", 39, 0, Red);
    else
    ticket = OrderSend(Symbol(), OP_SELL, SellLots22, Bid, 4, SL, TP, "Sell Renko", 39, 0, Red);
    if (ticket > -1)
    {
        if (true)
        {
            bool sel = OrderSelect(ticket, SELECT_BY_TICKET);
            bool ret = OrderModify(OrderTicket(), OrderOpenPrice(), SL, TP, 0, Red);
            if (ret == false)
            Print("OrderModify() error - ", ErrorDescription(GetLastError()));
        }
            
    }
    else
    {
        Print("OrderSend() error - ", ErrorDescription(GetLastError()));
    }
}

void IfOrderExists24()
{
    bool exists = false;
    for (int i=OrdersTotal()-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == 38)
        {
            exists = true;
        }
    }
    else
    {
        Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
    }
    
    if (exists)
    {
        CloseOrder23();
        
    }
}

void CloseOrder23()
{
    int orderstotal = OrdersTotal();
    int orders = 0;
    int ordticket[90][2];
    for (int i = 0; i < orderstotal; i++)
    {
        bool sel = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderType() != OP_BUY || OrderSymbol() != Symbol() || OrderMagicNumber() != 38)
        {
            continue;
        }
        ordticket[orders][0] = OrderOpenTime();
        ordticket[orders][1] = OrderTicket();
        orders++;
    }
    if (orders > 1)
    {
        ArrayResize(ordticket,orders);
        ArraySort(ordticket);
    }
    for (i = 0; i < orders; i++)
    {
        if (OrderSelect(ordticket[i][1], SELECT_BY_TICKET) == true)
        {
            bool ret = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 4, Yellow);
            if (ret == false)
            Print("OrderClose() error - ", ErrorDescription(GetLastError()));
        }
    }
    
}



int deinit()
{
    if (false) ObjectsDeleteAll();
    
    
    
    
    return (0);
}

