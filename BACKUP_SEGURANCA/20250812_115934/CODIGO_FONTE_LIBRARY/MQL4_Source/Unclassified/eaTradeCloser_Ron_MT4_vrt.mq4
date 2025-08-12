/*
+------------+
|FrameTrader |
+------------+

Theory of operation


TIME FRAME
==========
Close at equity level with a profit :)


PAIRS
=====
ALL

ENTRY LONG
==========


ENTRY SHORT
===========


EXIT
====


MONEY MANAGEMENT
================
-none-


RISK MANAGEMENT
===============
-none-


FAILURE MANAGEMENT
==================
-none-


VERSION HISTORY
===============
00    - initial concept

*/


#property copyright "Ron Thompson"
#property link      "http://www.lightpatch.com/forex"

// user input
extern double Basketloss=50;
extern double Slippage=3;

//+-------------+
//| Custom init |
//|-------------+
// Called ONCE when EA is added to chart or recompiled

int init()
  {
   Print("Init happened ",CurTime());
   Comment(" ");
  }


//+----------------+
//| Custom DE-init |
//+----------------+
// Called ONCE when EA is removed from chart

int deinit()
  {
   Print("DE-Init happened ",CurTime());
   Comment(" ");
  }


//+-----------+
//| Main      |
//+-----------+
// Called EACH TICK and each Bar[]

int start()
  {
   
   int      cnt=0;
   int      gle=0;
   int      OrdersOpenCount=0;

   string mySymbol;
   double myAsk;
   double myBid;   

   double   currBasket=0;

   currBasket=AccountEquity()-AccountBalance();
   Comment("Profit/Loss = ",currBasket);
   
   if(currBasket<Basketloss)
     {
      // CLOSE order if profit target made
      for(cnt=OrdersTotal(); cnt>=0; cnt--)
        {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if( OrderType()==OP_BUY || OrderType()==OP_SELL )
           {
            mySymbol=OrderSymbol();
 
            if(OrderType()==OP_BUY)
              {
               myBid=MarketInfo(mySymbol,MODE_BID);            
               OrderClose(OrderTicket(),OrderLots(),myBid,Slippage,White);
               gle=GetLastError();
               if(gle==0)
                 {
                  Print("CLOSE BUY  Bid=",myBid); 
                 }
                  else 
                 {
                  Print("-----ERROR----- CLOSE BUY  Bid=",myBid," error=",gle);
                 }
              } // if BUY


            if(OrderType()==OP_SELL)
              {
               myAsk=MarketInfo(mySymbol,MODE_ASK);            
               OrderClose(OrderTicket(),OrderLots(),myAsk,Slippage,Red);
               gle=GetLastError();
               if(gle==0)
                 {
                  Print("CLOSE SELL Ask=",myAsk);
                 }
                  else 
                 {
                  Print("-----ERROR----- CLOSE SELL Ask=",myAsk," error=",gle);
                 }
              } //if SELL
           
           } // if(OrderSymbol)
        
        } // for

     } //currBasket

  } // start()




