//+-----------------------------------+
//| Use on EURUSD 1hour charts only!! |
//+-----------------------------------+
#property copyright "Jan Vanman  vanman@absamail.co.za"
#property link      "http://www.metaquotes.ru"


//+------------------------------------------------------------------+
//|  External Variables                                              |
//+------------------------------------------------------------------+


extern double TakeProfit = 200;
extern double TrailingStop = 40;
extern int    MAFastPeriod=16;
extern int    MASlowPeriod=60;
extern int    Slippage=2;
extern int    back=15;


int start()
  {
   int cnt=0;
   int mode=0;
   int FastMa=0, FastMa2=0, FastMa5=0;
   int SlowMa=0, SlowMa2=0, SlowMa5=0;

   double mini=0.1;

   int    lot;
   
   double p=Point();

   if (Bars<100)        {Print("Bars less than 100");        return(0); }
   if (TrailingStop<10) {Print("TrailingStop less than 10"); return(0); }
   if (TakeProfit<10)   {Print("TakeProfit less than 10");   return(0); }


   // setup values
   // Ron set these to PRICE_CLOSE, because it was unknown what mt3 used 
   //FastMa =iMA(MAFastPeriod,MODE_EMA,0);
   //FastMa2=iMA(MAFastPeriod,MODE_EMA,2);
   //FastMa5=iMA(MAFastPeriod,MODE_EMA,5);
   FastMa  =iMA(Symbol(), 0, MAFastPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
   FastMa2 =iMA(Symbol(), 0, MAFastPeriod, 0, MODE_EMA, PRICE_CLOSE, 2);
   FastMa5 =iMA(Symbol(), 0, MAFastPeriod, 0, MODE_EMA, PRICE_CLOSE, 5);

   //SlowMa =iMA(MASlowPeriod,MODE_EMA,0);
   //SlowMa2=iMA(MASlowPeriod,MODE_EMA,2);
   //SlowMa5=iMA(MASlowPeriod,MODE_EMA,5);
   SlowMa  =iMA(Symbol(), 0, MASlowPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
   SlowMa2 =iMA(Symbol(), 0, MASlowPeriod, 0, MODE_EMA, PRICE_CLOSE, 2);
   SlowMa5 =iMA(Symbol(), 0, MASlowPeriod, 0, MODE_EMA, PRICE_CLOSE, 5);

   // Error checking
   if(Bars<100)                {Print("Bars less than 100"); return(0);}
   if(AccountFreeMargin()<100) {Print("We have no money");   return(0);}
   
   // if there are no open positions and orders
   if (OrdersTotal()<1)
     {
      if (AccountFreeMargin()>5000)
        {
         lot=MathCeil((AccountFreeMargin()/3000));
        }
         else
        {
         lot=MathCeil((AccountFreeMargin()/300)*mini);
        }

      // there are no open positions - check the BUY option
      // the opening condition:
      // if EMA(16) crosses EMA(60) upwards
      // and the current bar is bullish (Close>Open), we place
      // waiting order BUY LIMIT 15 pips below the execution
      // price for more optimal entering into the market
      //If FastMa>SlowMa and FastMa2<SlowMa2 and FastMa5<SlowMa5 and Close>Open then
      if (FastMa-SlowMa>=p && SlowMa2-FastMa2>=p && SlowMa5-FastMa5>=p && Close[0]>Open[0])
        {
         // try to place a waiting order at the (Ask-15) points price
         // with maximum slippage 2 points,
         // while not setting  Stop Loss and setting Take Profit
         // 200 points above the opening price.
         // at the chart an upward green arrow appears

         //SetOrder(OP_BUYLIMIT,Lot,Ask-back*Point,Slippage,0,Ask+(TakeProfit-back)*Point,RED);
         OrderSend(Symbol(),OP_BUYLIMIT,lot,Ask-(back*p),Slippage,0,Ask+((TakeProfit-back)*p),"4MA Buy",11123,0,White);
         return(0); // now we exit as we are not allowed to operate the account in the nearest 10 sec
        }
        
      // the opening SELL condition:
      // if EMA(16) crosses EMA(60) downwards
      // and the current bar is bearish (Close<Open), than we place
      // a waiting order SELL LIMIT 15 points above
      // the execution price for more optimal entering the market
      if ( SlowMa-FastMa>=p && FastMa2-SlowMa2>=p && FastMa5-SlowMa5>=p && Close[0]<Open[0])
        {
         // try to place 1 lot order at Bid+15 points price
         // with 2 points maximum slippage,
         // when not setting  Stop Loss and setting  Take Profit
         // 200 points below opening price.
         // on the chart the downward red arrow will appear
         //SetOrder(OP_SELLLIMIT,Lot,Bid+back*Point,Slippage,0,Bid-(TakeProfit-back)*Point,RED);
         OrderSend(Symbol(),OP_SELLLIMIT,lot,Bid+(back*p),Slippage,0,Bid-((TakeProfit-back)*p),"4MA SELL",11321,0,Red);
         return(0);
        }
        
   // all we need to check in the empty terminal 
   // we have checked already, now we exit
   return(0);
  }  //if (OrdersTotal()<1)


// here is the code of checking of the positions opened earlier
// (the placed orders will be checked 
// in the other block, now we check the already opened positions)

for (cnt=1; cnt<=OrdersTotal(); cnt++)
  {
   OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
   if(OrderSymbol()==Symbol())
     {
      if (OrderType()==OP_BUY)   // if the already opened position were BUY
        {
         // lets check if EMA(16) has crossed EMA(60) downwards?
         if (FastMa<SlowMa && FastMa2>SlowMa2 && FastMa5>SlowMa5)
           {
            // try to close the position at current Bid price 
            //CloseOrder(OrderValue(cnt,VAL_TICKET),OrderValue(cnt,VAL_LOTS),Bid,Slippage,RED);
            OrderClose(OrderTicket(),OrderLots(),Bid,0,Red);
            return(0);
           }

         // Here we check the trailing stop at open position.
         // Trailing stop ( Stop Loss) of the BUY position is being
         // kept at level 40 points below the market.

         // If the profit (current Bid-OpenPrice) more than TrailingStop (40) pips
         if ( Bid-OrderOpenPrice()>TrailingStop*p )
           {
            // we have won already not less than 'TrailingStop' pips!
            if ( OrderStopLoss()<Bid-(TrailingStop*p) )
              {
               // move the trailing stop (Stop Loss) to the level 'TrailingStop' from the market
               //ModifyOrder(OrderValue(cnt,VAL_TICKET),OrderValue(cnt,VAL_OPENPRICE), Bid-Point*TrailingStop,OrderValue(cnt,VAL_TAKEPROFIT),Red);
               OrderModify(OrderTicket(),OrderOpenPrice(),Bid-(TrailingStop*p),OrderTakeProfit(),0,Red);
               return(0);
              }
           } //If (Bid-OrderValue(cnt,VAL_OPENPRICE))>(TrailingStop*Point)
        } //if(OrderSymbol()==Symbol()) 
     } //If mode=OP_BUY then


   if (mode==OP_SELL)   // if the already opened position were SELL
     {
      // check if EMA(16) has crossed already EMA(60) upwards?

      if (FastMa>SlowMa && FastMa2<SlowMa2 && FastMa5<SlowMa5)
        {
         // try to close the position at current Ask price
         //CloseOrder(OrderValue(cnt,VAL_TICKET),OrderValue(cnt,VAL_LOTS),Ask,Slippage,RED);
         OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Red);
         return(0);
        }

      // Here we check the trailing stop at open position.
      // Trailing stop ( Stop Loss) of the BUY position is being
      // kept at level 40 points below the market.


      // If the profit (current Bid-OpenPrice) more than TrailingStop (40) pips
      if ( OrderOpenPrice()-Ask>(TrailingStop*p) )
        {
         // we have won already not less than 'TrailingStop' pips!
         if ( OrderStopLoss()>(Ask+(TrailingStop*p)) || OrderStopLoss()==0 )
           {
            // move the trailing stop (Stop Loss) to the level 'TrailingStop' from the market
            //ModifyOrder(OrderValue(cnt,VAL_TICKET),OrderValue(cnt,VAL_OPENPRICE), Ask+Point*TrailingStop,OrderValue(cnt,VAL_TAKEPROFIT),Red);
            OrderModify(OrderTicket(),OrderOpenPrice(),Ask+(TrailingStop*p),OrderTakeProfit(),0,Red);
            return(0);
           }
        } //If (OrderValue(cnt,VAL_OPENPRICE)-Ask)>(TrailingStop*Point)
     }  //If mode=OP_SELL


   // there is one very important point - the control
   // over the waiting orders.  An order cannot be valid more than 0.5 hour. 
   // After which It should be canceled  
   // For that purpose we compare current time 
   // and time the order is placed
   if (mode>OP_SELL)  // this is a waiting order!
     {
      // check how long it exists in the trading terminal
      // time is counted in seconds:
      // 10 minutes = 600 seconds, 30 minutes = 1800, 1 hour = 3600, 1 day = 86400
      if ( CurTime()-OrderOpenTime()>1800 )
        {
         //DeleteOrder(OrderValue(cnt,VAL_TICKET),RED);
         OrderDelete(OrderTicket());
         return(0);
        }
     }
  }//for cnt=1 to TotalTrades

return(0);
}

// the end
//Adapted from "Trend Follower" from InterbankFX.com
//by JF van Niekerk



