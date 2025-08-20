#property copyright "Ex4toMq4Decompiler MT4 Expert Advisors and Indicators Base of Source Codes"
#property link      "https://ex4tomq4decompiler.com/"
#property description "Join Telegram Channel for daily Unlimited Source Codes @ex4tomq4decompilercom"
#property description "Find Fresh Decompiled Source Codes - https://www.ex4tomq4decompiler.com/free-mt4-robots"
//---
#include <stdlib.mqh>

extern string ExpertName        = "Daily Longterm";
extern double Lots              = 1.0;
extern int    TakeProfit        = 50;
extern int    TP_to_Lock        = 50;
extern int    LockProfit        = 50;
extern int    Stoploss          = 250;
extern int    Magic             = 4141;
extern int    CandlePeriod      = 1440;
extern int    MACD_Period       = 240;
extern int    MA_Period         = 60;
extern int    Fast_MA           = 6;
extern int    Slow_MA           = 23;
extern int    TimeToTrade       = 00;
extern int    MinuteToTrade     = 00;
extern bool   Use_close_hour    = true;
extern int    Close_hour        = 23;
extern int    Close_minute      = 59;
extern int    Slippage          = 3;

//--------------
int init()
{

return(0);}
int start()
  {
  
  if(Hour() >= Close_hour &&
     Use_close_hour){
     // we are after closing time
    int totalorders = OrdersTotal();
    for(int j=0;j<totalorders;j++){
      OrderSelect(j, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol() && 
	      OrderMagicNumber() == Magic){
           if(OrderType() == OP_BUY)
	          OrderClose(OrderTicket(), OrderLots(), Bid, 0, Red);
	        if(OrderType() == OP_SELL)
	          OrderClose(OrderTicket(), OrderLots(), Ask, 0, Red);
	        if(OrderType() == OP_BUYSTOP  || OrderType() == OP_SELLSTOP)
	          OrderDelete(OrderTicket());
      }
    }
    return(0);
  }

//-------------
  {   
   for (int i = 0; i < OrdersTotal(); i++) {
     OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
     if ( OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
        {
            if (OrderType() == OP_BUY) {
                if (Bid - OrderOpenPrice() >= TP_to_Lock*Point)   { 
                   OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + LockProfit* Point, OrderTakeProfit(), Red);}
                }
            }               
             if (OrderType() == OP_SELL) {
                if (OrderOpenPrice() - Ask >= TP_to_Lock*Point)   { 
                   OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - LockProfit* Point, OrderTakeProfit(), Red); }
                }
            }
        }                              
//--------------  
   int cnt, ticket, total, OrdersPerSymbol;
   bool OrderBeli = false, OrderJual = false;
   
   bool Beli=false;
   bool Jual=false;
      
   double BarOpen1  = iOpen(Symbol(),CandlePeriod,1);               
   double BarClose1  = iClose(Symbol(),CandlePeriod,1); 
   double MACD_1  = iMACD(NULL, MACD_Period, 14, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
   double MACD_0  = iMACD(NULL, MACD_Period, 14, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
   double MA_6_0  = iMA(NULL,MA_Period,Fast_MA,0,MODE_SMA,PRICE_CLOSE,0);
   double MA_23_0 = iMA(NULL,MA_Period,Slow_MA,0,MODE_SMA,PRICE_CLOSE,0);

  
   
   if (BarOpen1<BarClose1 && MACD_0 > MACD_1 && MA_6_0 > MA_23_0) Beli=true;   
   if (BarOpen1>BarClose1 && MACD_0 < MACD_1 && MA_6_0 < MA_23_0) Jual=true;  

//-------- || --- ||

   OrdersPerSymbol=0;
   for(cnt=OrdersTotal();cnt>=0;cnt--)
     {
        OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
        if(OrderSymbol()==Symbol() && OrderMagicNumber() == Magic)
           OrdersPerSymbol++; 
     }
     
   total = OrdersPerSymbol;
    
   if (Beli && Hour() == TimeToTrade && Minute() == MinuteToTrade)
      { OrderBeli = true; }         
   if (Jual && Hour() == TimeToTrade && Minute() == MinuteToTrade)
      { OrderJual = true; }
     
   if (total < 1) 
     {
       if( OrderBeli == true)
         { sendBuyOrder(); }
       if( OrderJual == true )
         { sendSellOrder(); }
     }
   } 
void sendBuyOrder()
   {     
     int ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Bid-Stoploss*Point,Ask+TakeProfit*Point,ExpertName ,Magic,0,Blue);
     if(ticket>0)
                 {
             return(0);
            }
          }
//+------------------------------------------------------------------+
void sendSellOrder()
   {
      int ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Ask+Stoploss*Point,Bid-TakeProfit*Point,ExpertName ,Magic,0,Red);
      if(ticket>0)
            {
             return(0);
            }
         }
//-----------