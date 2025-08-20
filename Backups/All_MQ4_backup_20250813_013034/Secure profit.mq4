#property copyright "Copyright © 2013, Djezzy"
#property link      "http://www.franskype.com/"

#include <stdlib.mqh>
#include <WinUser32.mqh>

// exported variables
extern double Lot = 0.1;
extern double Envelope_period = 15;
extern double Envelope_deviation = 0.49;
extern int Hours_from = 2;
extern int Hours_to = 23;
extern int Enter_minute = 13;
extern double Exit_level = 26;
extern int Stoploss = 90;
extern int Takeprofit = 50;
extern double Secure_depth = 29;
extern int Secure_stoploss = 15;
extern int Secure_takeprofit = 15;

// local variables
double PipValue=1;    // this variable is here to support 5-digit brokers
bool Terminated = false;
string LF = "\n";  // use this in custom or utility blocks where you need line feeds
int NDigits = 4;   // used mostly for NormalizeDouble in Flex type blocks
int ObjCount = 0;  // count of all objects created on the chart, allows creation of objects with unique names
int current = 0;

int Hour25 = 1;
int Hour30 = 1;
datetime BarTime40 = 0;
datetime BarTime33 = 0;


int init()
{
    NDigits = Digits;
    
    if (false) ObjectsDeleteAll();      // clear the chart
    
    
    Comment("");    // clear the chart
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
    
    OnEveryTick19();
    
}

void OnEveryTick19()
{
    if (true == false && false) PipValue = 10;
    if (true && (NDigits == 3 || NDigits == 5)) PipValue = 10;
    
    TechnicalAnalysis2x38();
    TechnicalAnalysis2x35();
    TechnicalAnalysis3x22();
    TechnicalAnalysis3x27();
    CheckOpenOrders39();
    CheckOpenOrders34();
    
}

void TechnicalAnalysis2x38()
{
    if ((Open[1] < iMA(NULL, NULL,Exit_level,0,MODE_SMA,PRICE_CLOSE,1)) && (High[0] > iMA(NULL, NULL,Exit_level,0,MODE_SMA,PRICE_CLOSE,0)))
    {
        CloseOrder37();
        
    }
}

void CloseOrder37()
{
    int orderstotal = OrdersTotal();
    int orders = 0;
    int ordticket[30][2];
    for (int i = 0; i < orderstotal; i++)
    {
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderType() != OP_SELL || OrderSymbol() != Symbol() || OrderMagicNumber() != 21)
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
            bool ret = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 4, Red);
            if (ret == false)
            Print("OrderClose() error - ", ErrorDescription(GetLastError()));
        }
    }
    
}

void TechnicalAnalysis2x35()
{
    if ((Open[1] > iMA(NULL, NULL,Exit_level,0,MODE_SMA,PRICE_CLOSE,1)) && (Low[0] < iMA(NULL, NULL,Exit_level,0,MODE_SMA,PRICE_CLOSE,0)))
    {
        CloseOrder36();
        
    }
}

void CloseOrder36()
{
    int orderstotal = OrdersTotal();
    int orders = 0;
    int ordticket[30][2];
    for (int i = 0; i < orderstotal; i++)
    {
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderType() != OP_BUY || OrderSymbol() != Symbol() || OrderMagicNumber() != 22)
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
            bool ret = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 4, Red);
            if (ret == false)
            Print("OrderClose() error - ", ErrorDescription(GetLastError()));
        }
    }
    
}

void TechnicalAnalysis3x22()
{
    if ((Close[1] < iEnvelopes(NULL, NULL,Envelope_period,MODE_SMA,0,PRICE_CLOSE,Envelope_deviation,MODE_LOWER,1)) && (Close[1] < iMA(NULL, NULL,2,0,MODE_EMA,PRICE_LOW,1)) && (iMA(NULL, NULL,2,0,MODE_EMA,PRICE_LOW,1) < iEnvelopes(NULL, NULL,Envelope_period,MODE_SMA,0,PRICE_CLOSE,Envelope_deviation,MODE_LOWER,1)))
    {
        LimitOpenOrders23();
        
    }
}

void LimitOpenOrders23()
{
    int count = 0;
    for (int i=OrdersTotal()-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderSymbol() == Symbol())
        if (OrderMagicNumber() == 21)
        {
            count++;
        }
    }
    else
    {
        Print("OrderSend() error - ", ErrorDescription(GetLastError()));
    }
    if (count < 1)
    {
        HoursFilter24();
        
    }
}

void HoursFilter24()
{
    int datetime800 = TimeLocal();
    int hour0 = TimeHour(datetime800);
    
    if ((Hours_from < Hours_to && hour0 >= Hours_from && hour0 < Hours_to) ||
    (Hours_from > Hours_to && (hour0 < Hours_to || hour0 >= Hours_from)))
    {
        OnceAnHour25();
        
    }
}

void OnceAnHour25()
{
    int datetime800 = TimeLocal();
    int hour0 = TimeHour(datetime800);
    int minute0 = TimeMinute(datetime800);
    if (hour0 != Hour25 && minute0 == Enter_minute)
    {
        Hour25 = hour0;
        SellOrder26();
        
    }
}

void SellOrder26()
{
    double SL = Bid + Stoploss*PipValue*Point;
    if (Stoploss == 0) SL = 0;
    double TP = Bid - Takeprofit*PipValue*Point;
    if (Takeprofit == 0) TP = 0;
    int ticket = -1;
    if (true)
    ticket = OrderSend(Symbol(), OP_SELL, Lot, Bid, 4, 0, 0, "My Expert", 21, 0, Red);
    else
    ticket = OrderSend(Symbol(), OP_SELL, Lot, Bid, 4, SL, TP, "My Expert", 21, 0, Red);
    if (ticket > -1)
    {
        if (true)
        {
            OrderSelect(ticket, SELECT_BY_TICKET);
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

void TechnicalAnalysis3x27()
{
    if ((Close[1] > iEnvelopes(NULL, NULL,Envelope_period,MODE_SMA,0,PRICE_CLOSE,Envelope_deviation,MODE_UPPER,1)) && (Close[1] > iMA(NULL, NULL,2,0,MODE_EMA,PRICE_HIGH,1)) && (iMA(NULL, NULL,2,0,MODE_EMA,PRICE_HIGH,1) > iEnvelopes(NULL, NULL,Envelope_period,MODE_SMA,0,PRICE_CLOSE,Envelope_deviation,MODE_UPPER,1)))
    {
        LimitOpenOrders28();
        
    }
}

void LimitOpenOrders28()
{
    int count = 0;
    for (int i=OrdersTotal()-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderSymbol() == Symbol())
        if (OrderMagicNumber() == 22)
        {
            count++;
        }
    }
    else
    {
        Print("OrderSend() error - ", ErrorDescription(GetLastError()));
    }
    if (count < 1)
    {
        HoursFilter29();
        
    }
}

void HoursFilter29()
{
    int datetime800 = TimeLocal();
    int hour0 = TimeHour(datetime800);
    
    if ((Hours_from < Hours_to && hour0 >= Hours_from && hour0 < Hours_to) ||
    (Hours_from > Hours_to && (hour0 < Hours_to || hour0 >= Hours_from)))
    {
        OnceAnHour30();
        
    }
}

void OnceAnHour30()
{
    int datetime800 = TimeLocal();
    int hour0 = TimeHour(datetime800);
    int minute0 = TimeMinute(datetime800);
    if (hour0 != Hour30 && minute0 == Enter_minute)
    {
        Hour30 = hour0;
        BuyOrder31();
        
    }
}

void BuyOrder31()
{
    double SL = Ask - Stoploss*PipValue*Point;
    if (Stoploss == 0) SL = 0;
    double TP = Ask + Takeprofit*PipValue*Point;
    if (Takeprofit == 0) TP = 0;
    int ticket = -1;
    if (true)
    ticket = OrderSend(Symbol(), OP_BUY, Lot, Ask, 4, 0, 0, "My Expert", 22, 0, Blue);
    else
    ticket = OrderSend(Symbol(), OP_BUY, Lot, Ask, 4, SL, TP, "My Expert", 22, 0, Blue);
    if (ticket > -1)
    {
        if (true)
        {
            OrderSelect(ticket, SELECT_BY_TICKET);
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

void CheckOpenOrders39()
{
    double profit = 0;
    for (int i=OrdersTotal()-1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (true || (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == 21))
            {
                profit += OrderProfit();
            }
        }
        else
        {
            Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
        }
    }
    
    if (profit >= Secure_depth)
    {
        OncePerBar40();
        
    }
}

void OncePerBar40()
{
    
    if (BarTime40 < Time[0])
    {
        // we have a new bar opened
        BarTime40 = Time[0]; // keep the new bar open time
        SellOrderModify41();
        
    }
}

void SellOrderModify41()
{
    for (int i=OrdersTotal()-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == 21)
        {
            double price = Bid;
            if (true == false)
            {
                price = OrderOpenPrice();
            }
            bool ret = OrderModify(OrderTicket(), OrderOpenPrice(), price + Secure_stoploss*PipValue*Point, price - Secure_takeprofit*PipValue*Point, 0, White);
            if (ret == false)
            Print("OrderModify() error - ", ErrorDescription(GetLastError()));
        }
    }
    
}

void CheckOpenOrders34()
{
    double profit = 0;
    for (int i=OrdersTotal()-1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (true || (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == 22))
            {
                profit += OrderProfit();
            }
        }
        else
        {
            Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
        }
    }
    
    if (profit >= Secure_depth)
    {
        OncePerBar33();
        
    }
}

void OncePerBar33()
{
    
    if (BarTime33 < Time[0])
    {
        // we have a new bar opened
        BarTime33 = Time[0]; // keep the new bar open time
        BuyOrderModify32();
        
    }
}

void BuyOrderModify32()
{
    for (int i=OrdersTotal()-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == 22)
        {
            double price = Ask;
            if (true == false)
            {
                price = OrderOpenPrice();
            }
            bool ret = OrderModify(OrderTicket(), OrderOpenPrice(), price - Secure_stoploss*PipValue*Point, price + Secure_takeprofit*PipValue*Point, 0, White);
            if (ret == false)
            Print("OrderModify() error - ", ErrorDescription(GetLastError()));
        }
    }
    
}



int deinit()
{
    if (false) ObjectsDeleteAll();
    
    
}