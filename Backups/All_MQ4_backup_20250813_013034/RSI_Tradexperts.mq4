//+------------------------------------------------------------------+
//|                                              RSI_Tradexperts.mq4 |
//|                                                      TO StatBars |
//|                                            http://tradexperts.ru |
//+------------------------------------------------------------------+
#property copyright "TO StatBars"
#property link      "http://tradexperts.ru"


extern int RSI_Period = 21;
extern int RSI_Price = 5;
extern double RSI_Hi_Level = 80;
extern double RSI_Lo_Level = 20;

extern int TP = 0;
extern int SL = 500;

extern bool Martin_Flag = true;
extern double Init_Lot = 0.1;
extern double Koef = 2.0;

extern bool Trailinf_Flag = true;
extern int Trailing_Stop = 100;
extern int Trailing_Step = 5;

extern int Magic_Number = 89403;
extern double lot = 0.1;

int init()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
   double temp_tp, temp_sl, temp_lot;
   int ticket=0, i;
    // Трейлинг
   if( Trailinf_Flag )
   {
      // Трал
      if( Orders_Total_by_type( OP_BUY,  Magic_Number, Symbol()) > 0 )
      {
         // для BUY
         for( i = OrdersTotal() ; i >= 0 ; i--)
         {
            OrderSelect( i, SELECT_BY_POS, MODE_TRADES);
            if( OrderType() == OP_BUY && OrderMagicNumber() == Magic_Number && OrderSymbol() == Symbol() )
               Step_Standart_TS(OrderTicket(), Trailing_Stop, Trailing_Step);
         }
      }
      if( Orders_Total_by_type( OP_SELL,  Magic_Number, Symbol()) > 0 )
      {
         // для SELL
         for( i = OrdersTotal() ; i >= 0 ; i--)
         {
            OrderSelect( i, SELECT_BY_POS, MODE_TRADES);
            if( OrderType() == OP_SELL && OrderMagicNumber() == Magic_Number && OrderSymbol() == Symbol() )
               Step_Standart_TS(OrderTicket(), Trailing_Stop, Trailing_Step);
         }
      }
   }
   
   if( IsTesting() || IsOptimization() )
   if(!isNewBar())return(0);
   
   double RSI_1 = iRSI( Symbol(), Period(), RSI_Period, RSI_Price, 1);
   double RSI_2 = iRSI( Symbol(), Period(), RSI_Period, RSI_Price, 2);
   
   if( RSI_1 > RSI_Lo_Level && RSI_2 <= RSI_Lo_Level )
   {
      CloseOrder_by_type( OP_SELL, Magic_Number, Symbol()) ;
      if( Orders_Total_by_type( OP_BUY, Magic_Number, Symbol()) == 0 )
      {
         if( TP > 0 )temp_tp = Bid + TP*Point;
         else temp_tp = 0.0;
         
         if( SL > 0 )temp_sl = Bid - SL*Point;
         else temp_sl = 0.0;
         
         if( Martin_Flag )
            temp_lot = NormalizeLots( Martin_Lot( Init_Lot, Koef, Magic_Number, Symbol()), Symbol());
         else
            temp_lot = NormalizeLots( Init_Lot, Symbol());
         
         ticket = OrderSend( Symbol(), OP_BUY, temp_lot, Ask, 5, temp_sl, temp_tp, "", Magic_Number, 0, Aqua);
      }
   }
   
   if( RSI_1 < RSI_Hi_Level && RSI_2 >= RSI_Hi_Level )
   {
      CloseOrder_by_type( OP_BUY, Magic_Number, Symbol()) ;
      if( Orders_Total_by_type( OP_SELL, Magic_Number, Symbol()) == 0 )
      {
         if( TP > 0 )temp_tp = Ask - TP*Point;
         else temp_tp = 0.0;
         
         if( SL > 0 )temp_sl = Ask + SL*Point;
         else temp_sl = 0.0;
         
         if( Martin_Flag )
            temp_lot = NormalizeLots( Martin_Lot( Init_Lot, Koef, Magic_Number, Symbol()), Symbol());
         else
            temp_lot = NormalizeLots( Init_Lot, Symbol());
         
         ticket = OrderSend( Symbol(), OP_SELL, temp_lot, Bid, 5, temp_sl, temp_tp, "", Magic_Number, 0, Magenta);
      }
   }
   
   return(0);
  }
//+------------------------------------------------------------------+

double NormalizeLots( double inlot, string sym)
{
   if( inlot == 0 )Print("!!!!!!");
   double outlot;
   Print("_digits = "+_digits( MarketInfo( sym, MODE_LOTSTEP))+" inlot:"+inlot);
   outlot = NormalizeDouble( inlot, _digits( MarketInfo( sym, MODE_LOTSTEP) ) );
   if( outlot < MarketInfo( sym, MODE_MINLOT) ) outlot = MarketInfo( sym, MODE_MINLOT);
   if( outlot > MarketInfo( sym, MODE_MAXLOT ) ) outlot = MarketInfo( sym, MODE_MAXLOT);
   Print(outlot);
   return( outlot);
}

int _digits( double number)
{
   double temp = number;
   int dig = 0;
   Print("double number : "+number);
   while( true )
   {
      if( temp > 1 )break;
      temp= temp*10;
      dig++;
   }
   return(dig-1);
}

double Martin_Lot( double _init_lot, double coef, int mn, string sym)
{
   datetime time_close = 0;
   int ticket = -1;
   if( OrdersHistoryTotal() == 0 )return(_init_lot);
   for(int i = OrdersHistoryTotal() - 1; i>=0; i--)
   {
      OrderSelect( i, SELECT_BY_POS, MODE_HISTORY);
      if( OrderMagicNumber() == mn && OrderSymbol() == sym)
      {
         if( OrderCloseTime() > time_close )
         {
            time_close = OrderCloseTime();
            ticket = OrderTicket();
         }  
      }
   }
   if( ticket == -1 ) return(_init_lot);
   if( OrderTicket() != ticket )OrderSelect( ticket, SELECT_BY_TICKET);
   if( OrderProfit() <= 0 )
   {
      return(NormalizeDouble( OrderLots()*coef, 2));
   }
   else
      return(_init_lot);
}

void Step_Standart_TS(int iTicket,double TrailingStop, double TrailingStep)
{
      if( OrderTicket() !=  iTicket)OrderSelect(iTicket, SELECT_BY_TICKET, MODE_TRADES);
      if(OrderType()<=OP_SELL &&   // check for opened position 
         OrderSymbol()==Symbol())  // check for symbol
      {
         if(OrderType()==OP_BUY)   // long position is opened
         {
            if(TrailingStop > 0)  
            {                 
               if( Bid - OrderOpenPrice() > Point*TrailingStop )
               {
                  if( OrderStopLoss() + Point*TrailingStep < Bid - Point*TrailingStop )
                  {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
                  }
               }
            }
         }
         else // go to short position
         {
            // check for trailing stop
            if(TrailingStop>0)  
            {                 
               if( ( OrderOpenPrice() - Ask > Point*TrailingStop ) ||  ( NormalizeDouble( OrderStopLoss(), Digits) == 0 ) )
               {
                  if( ( OrderStopLoss() - Point*TrailingStep > Ask + Point*TrailingStop ) || ( NormalizeDouble( OrderStopLoss(), Digits) == 0 ))
                  {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
                  }
               }
            }
         }
      }
}

bool isNewBar()
{
  static datetime BarTime;  
   bool res=false;
    
   if (BarTime!=Time[0]) 
      {
         BarTime=Time[0];  
         res=true;
      } 
   return(res);
}

//---- Возвращает количество ордеров указанного типа ордеров ----//
int Orders_Total_by_type(int type, int mn, string sym)
{
   int num_orders=0;
   for(int i= OrdersTotal()-1;i>=0;i--)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if( OrderMagicNumber() == mn && type == OrderType() && sym==OrderSymbol())
         num_orders++;
   }
   return(num_orders);
}

//---- Закрытие ордера по типу и комментарию ----//
void CloseOrder_by_type(int type, int mn, string sym)
{
   for(int i= OrdersTotal()-1;i>=0;i--)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber() == mn && type == OrderType() && sym==OrderSymbol())
         if(OrderType()<=1)OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3);
         else OrderDelete(OrderTicket());
   }
}