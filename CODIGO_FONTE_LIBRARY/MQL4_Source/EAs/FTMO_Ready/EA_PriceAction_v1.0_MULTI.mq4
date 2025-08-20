//|$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//  Price Action V1
//  hodhabi@gmail.com
//|$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#define     NL    "\n" 
 
extern double Lots = 1;
extern double TP = 100;
extern int TrailingStop=0;
extern int TrailingStep=0;
int   TradeType      = 1;          // 0 no trades are opened, 1 to force buy, 2 to force sell
extern int leverage = 5;
extern double MaximumLossinMoney = 1000;
extern int   MagicNumber        = 250346;
extern bool UseAlerts = false;
 
 
void MoveTrailingStop()
{
   int cnt,total=OrdersTotal();
   for(cnt=0;cnt<total;cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL&&OrderSymbol()==Symbol())
      {
         if(OrderType()==OP_BUY)
         {
            if(TrailingStop>0)  
            {                 
               if((NormalizeDouble(OrderStopLoss(),Digits)<NormalizeDouble(Bid-Point*(TrailingStop+TrailingStep),Digits))||(OrderStopLoss()==0))
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-Point*TrailingStop,Digits),OrderTakeProfit(),0,Green);
                  return(0);
               }
            }
         }
         else 
         {
            if(TrailingStop>0)  
            {                 
               if((NormalizeDouble(OrderStopLoss(),Digits)>(NormalizeDouble(Ask+Point*(TrailingStop+TrailingStep),Digits)))||(OrderStopLoss()==0))
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+Point*TrailingStop,Digits),OrderTakeProfit(),0,Red);
                  return(0);
               }
            }
         }
      }
   }
}
 
//+-------------+
//| Custom init |
//|-------------+
int init()
  {
 
  }
 
//+----------------+
//| Custom DE-init |
//+----------------+
int deinit()
  {
 
  }
 
 
//+-----------+
//| Main      |
//+-----------+
int start()
  {
   int      OrdersBUY, ticket;
   int      OrdersSELL;
   double   BuyLots, SellLots, BuyProfit, SellProfit;
 
//+------------------------------------------------------------------+
//  Determine last order price                                       |
//-------------------------------------------------------------------+
 
 
      if(OrdersTotal()==0 && TradeType ==1 )
        {
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-TP*Point,Ask+leverage*TP*Point,"MLTrendETF",MagicNumber,0,Green);
         TradeType=2;
         
         if(ticket>0)
           {
            Comment("New Buy trade is opened");
           }
         else Print("Error opening BUY order : ",GetLastError()); 
         return(0); 
        }
 
      if(OrdersTotal()==0 && TradeType ==2)
        {
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+TP*Point,Bid-TP*leverage*Point,"MLTrendETF",MagicNumber,0,Green);
         TradeType = 1;
         if(ticket>0)
           {
            Comment("New Sell trade is opened");
           }
         else Print("Error opening BUY order : ",GetLastError()); 
         return(0); 
        }
 
 if(TrailingStop>0)MoveTrailingStop();
 
  } // start()