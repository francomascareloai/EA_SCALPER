//+------------------------------------------------------------------+
//|                                              Daydream by Cothool |
//|                                          Recommended: USD/JPY 1H |
//+------------------------------------------------------------------+
#define MAGIC_NUM  48213657
//----
extern double Lots      =1;
extern int ChannelPeriod=25;
extern int Slippage     =3;
extern int TakeProfit   =15;
//----
double LastOrderTime=0;
double CurrentDirection=0;
double CurrentTakeProfitPrice=0;
//----
void OpenLong()
  {
   if (Time[0]==LastOrderTime)
      return;
   if (CurrentDirection!=0)
      return;
//----
   OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, 0, 0,
             "Daydream", MAGIC_NUM, 0, Blue);
   LastOrderTime=Time[0];
   CurrentDirection=1;
  }
//----
void OpenShort()
  {
   if (Time[0]==LastOrderTime)
      return;
   if (CurrentDirection!=0)
      return;
//----
   OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, 0, 0,
             "Daydream", MAGIC_NUM, 0, Red);
   LastOrderTime=Time[0];
   CurrentDirection=-1;
  }
//----
void CloseLong()
  {
   int i;

   if (Time[0]==LastOrderTime)
      return;
   if (CurrentDirection!=1)
      return;
//----
   for(i=0; i < OrdersTotal(); i++)
     {
      if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol()==Symbol() &&
          OrderMagicNumber()==MAGIC_NUM && OrderType()==OP_BUY)
        {
         OrderClose(OrderTicket(), OrderLots(), Bid, 3, White);
         LastOrderTime=Time[0];
         CurrentDirection=0;
        }
     }
  }
//----
void CloseShort()
  {
   int i;
//----
   if (Time[0]==LastOrderTime)
      return;
   if (CurrentDirection!=-1)
      return;
   for(i=0; i < OrdersTotal(); i++)
     {
      if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol()==Symbol() &&
          OrderMagicNumber()==MAGIC_NUM && OrderType()==OP_SELL)
        {
         OrderClose(OrderTicket(), OrderLots(), Ask, 3, White);
         LastOrderTime=Time[0];
         CurrentDirection=0;
        }
     }
  }
//----
void start()
  {
   double HighestValue;
   double LowestValue;
   //
   HighestValue=High[Highest(NULL, 0, MODE_HIGH, ChannelPeriod, 1)];
   LowestValue=Low[Lowest(NULL, 0, MODE_LOW, ChannelPeriod, 1)];
   // BUY
   if (Close[0] < LowestValue)
     {
      CloseShort();
      OpenLong();
      CurrentTakeProfitPrice=Bid + TakeProfit * Point;
     }
   // SELL
   if (Close[0] > HighestValue)
     {
      CloseLong();
      OpenShort();
      CurrentTakeProfitPrice=Ask - TakeProfit * Point;
     }
   // Trailing Profit Taking for Long Position
   if (CurrentDirection==1)
     {
      if (CurrentTakeProfitPrice > Bid + TakeProfit * Point)
         CurrentTakeProfitPrice=Bid + TakeProfit * Point;
      if (Bid>=CurrentTakeProfitPrice)
         CloseLong();
     }
   // Trailing Profit Taking for Short Position
   if (CurrentDirection==-1)
     {
      if (CurrentTakeProfitPrice < Ask - TakeProfit * Point)
         CurrentTakeProfitPrice=Ask - TakeProfit * Point;
      if (Ask<=CurrentTakeProfitPrice)
         CloseShort();
     }
  }
//+------------------------------------------------------------------+

