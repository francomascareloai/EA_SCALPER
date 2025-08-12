//+------------------------------------------------------------------+
//|                                   Nevalyashka_BreakdownLevel.mq4 |
//|                               Copyright © 2010, Vladimir Hlystov |
//|                                                cmillion@narod.ru |
//|                                         http://cmillion.narod.ru |
//-------------------------------------------------------------------+
#property copyright "Copyright © 2010, http://cmillion.narod.ru"
#property link      "cmillion@narod.ru"
extern string TimeStart    = "04:00";  //Время начала контрольного периода
extern string TimeEnd      = "09:00";  //Время окончания контрольного периода
extern string TimeCloseOrder = "23:30";//Время в которое происходит закрытие всех ордеров
extern double LOT          = 0.1;
extern int    Magic        = 777;
extern double K_martin     = 2;
extern bool   No_Loss      = true;
int slippage = 3;
double marga,Lot,SL,TP;
int tip,Orders,tipOrders,TradeDey;
//-------------------------------------------------------------------+
int init()
{
   if (Digits==5 || Digits==3) slippage = 30;
}
int start()
{
   datetime Time_Start      = StrToTime(StringConcatenate(Day(),".",Month(),".",Year()," ",TimeStart,     ":00"));
   datetime Time_End        = StrToTime(StringConcatenate(Day(),".",Month(),".",Year()," ",TimeEnd,       ":00"));
   datetime Time_CloseOrder = StrToTime(StringConcatenate(Day(),".",Month(),".",Year()," ",TimeCloseOrder,":00"));

   if (Time_CloseOrder>Time_End) if (CurTime()>=Time_CloseOrder) CLOSEORDERS();

   int tip;
   if (Orders>OrdersTotal()) tip=CloseOrder();
   Orders=OrdersTotal();

   if (ORDERS(0)==0 && tip==0 && (CurTime()<Time_CloseOrder || Time_CloseOrder<=Time_End) && TradeDey!=TimeDay(CurTime()))
   {
      int BarStart = iBarShift(NULL,0,Time_Start,false);
      int BarEnd   = iBarShift(NULL,0,Time_End  ,false);
      double Max_Price=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,BarStart-BarEnd,BarEnd));
      double Min_Price=iLow (NULL,0,iLowest (NULL,0,MODE_LOW, BarStart-BarEnd,BarEnd));
   
      if (TimeCurrent()>Time_End && ObjectFind("bar0"+Time_End)==-1)
      {
         ObjectCreate("bar0"+Time_End, OBJ_RECTANGLE, 0, 0,0, 0,0);
         ObjectSet   ("bar0"+Time_End, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSet   ("bar0"+Time_End, OBJPROP_COLOR, Blue);
         ObjectSet   ("bar0"+Time_End, OBJPROP_BACK,  true);
         ObjectSet   ("bar0"+Time_End, OBJPROP_TIME1 ,Time_Start);
         ObjectSet   ("bar0"+Time_End, OBJPROP_PRICE1,Max_Price);
         ObjectSet   ("bar0"+Time_End, OBJPROP_TIME2 ,Time_End);
         ObjectSet   ("bar0"+Time_End, OBJPROP_PRICE2,Min_Price);
      }
      
      if (Bid>Max_Price) OrderSend(Symbol(),OP_BUY,LOT,Bid,slippage,Min_Price,
         NormalizeDouble(Ask + Max_Price-Min_Price,Digits),"BreakdownLevel",Magic,Blue);
      if (Bid<Min_Price) OrderSend(Symbol(),OP_SELL,LOT,Bid,slippage,Max_Price,
         NormalizeDouble(Bid - Max_Price+Min_Price,Digits),"BreakdownLevel",Magic,Blue);
      return;
   }
   if (No_Loss) No_Loss();
   if (tip==1 && TradeDey!=TimeDay(CurTime()))
   {
      Lot=Lot*K_martin;
      if (tipOrders==0) OrderSend(Symbol(),OP_SELL,Lot,Bid,slippage,SL,TP,"Nevalyashka",Magic,Blue);
      if (tipOrders==1) OrderSend(Symbol(),OP_BUY ,Lot,Ask,slippage,SL,TP,"Nevalyashka",Magic,Blue);
   }
   return(0);
}
//-------------------------------------------------------------------+
int CloseOrder()
{
   string txt;
   double loss;
   int i=OrdersHistoryTotal()-1;
   if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true)
   {                                     
      if (OrderSymbol()==Symbol() && Magic==OrderMagicNumber())
      {
         tipOrders=OrderType();
         Lot=OrderLots();
         loss = MathAbs(OrderProfit()/MarketInfo(Symbol(),MODE_TICKVALUE)/Lot/K_martin);
         if (tipOrders==0)
         {
            TP=NormalizeDouble(Bid - loss*Point,Digits);
            SL=NormalizeDouble(Ask + loss*Point,Digits);
         }
         if (tipOrders==1)
         {
            SL=NormalizeDouble(Bid - loss*Point,Digits);
            TP=NormalizeDouble(Ask + loss*Point,Digits);
         }
         if (OrderClosePrice()==OrderTakeProfit() || OrderProfit()>=0) TradeDey=TimeDay(CurTime());
         if (OrderClosePrice()==OrderStopLoss()) return(1);
      }
   }  
   return(0);
}
//+-----------------------------------------------------------------+
int ORDERS(int tip)
{
   int N_Sell,N_Buy;
   for (int i=0; i<OrdersTotal(); i++)
   {                                               
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
      {
         if (OrderSymbol()==Symbol() && Magic==OrderMagicNumber())
         {
            if (OrderType()==OP_BUY ) N_Buy++;
            if (OrderType()==OP_SELL) N_Sell++;
         }
      }   
   }
if (tip== 0) return(N_Buy+N_Sell);
if (tip== 1) return(N_Buy);
if (tip==-1) return(N_Sell);
}                  
//-------------------------------------------------------------------+
void No_Loss()
{
   int tip;
   double TP,OOP;
   for (int i=OrdersTotal()-1; i>=0; i--) 
   {
      if (OrderSelect(i, SELECT_BY_POS)==true)
      {
         tip = OrderType();
         if (tip<2 && OrderSymbol()==Symbol())
         {
            if (OrderMagicNumber()!=Magic) continue;
            TP = OrderTakeProfit();
            OOP = OrderOpenPrice();
            if (tip==0) //Bay               
            {  
               if (OrderStopLoss()>OrderOpenPrice()+Ask-Bid) return;
               if ((TP-OOP)/2+OOP<=Bid)
               OrderModify(OrderTicket(),OOP,NormalizeDouble(OOP+Ask-Bid,Digits),TP,0,White);
            }                                         
            if (tip==1) //Sell               
            {                                         
               if (OrderStopLoss()<OrderOpenPrice()-Ask+Bid) return;
               if (OOP-(OOP-TP)/2>=Ask)
               OrderModify(OrderTicket(),OOP,NormalizeDouble(OOP-Ask+Bid,Digits),TP,0,White);
            } 
         }
      }
   }
}
//------------------------------------------------------------------+
void CLOSEORDERS()
{
   bool error;
   int err;
   while (true)
   {  error=true;
      for (int i=OrdersTotal()-1; i>=0; i--)
      {                                               
         if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
         {
            if (OrderSymbol()!=Symbol()||Magic!=OrderMagicNumber()) continue;
            if (OrderType()==OP_BUY)
               error=OrderClose(OrderTicket(),OrderLots(),Bid,3,CLR_NONE);
            if (OrderType()==OP_SELL)
               error=OrderClose(OrderTicket(),OrderLots(),Ask,3,CLR_NONE);
         }   
      }
      if (!error) {err++;Sleep(2000);RefreshRates();}
      if (error || err >5) return;
   }
}
//-------------------------------------------------------------------+