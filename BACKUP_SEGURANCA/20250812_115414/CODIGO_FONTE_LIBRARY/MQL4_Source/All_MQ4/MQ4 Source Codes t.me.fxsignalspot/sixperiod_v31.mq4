//+------------------------------------------------------------------+
//+ Trade on 6-period HLCC/4 trend NO T/P, keep adjusting S/L        |
//+------------------------------------------------------------------+


#property copyright "Ron Thompson"
#property link      "http://www.lightpatch.com/forex"

// User Input
extern double Lots = 0.1;
extern double Stop_Loss = 15;


//+------------------------------------------------------------------+
//| What to do 1st                                                   |
//+------------------------------------------------------------------+

int init ()
  {
   return(0);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int deinit()
  {
   return(0);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double oTYP0=0, oTYP1=0, oTYP2=0, oTYP3=0, oTYP4=0, oTYP5=0;
   double total;
   int cnt;
   bool foundorder=False;

   double nslB=0,nslS=0,osl=0,ccl=0;
   
   //
   // Error checking
   //
   
   if(Bars<100)
     {
      Print("bars less than 100");
      return(0);
     }
   
   if(AccountFreeMargin()<(1000*Lots))
     {
      Print("We have no money");
      return(0);
     }

   //
   // only one order at a time/per symbol 
   // so see if our symbol has an order open
   //
   total=OrdersTotal();
   for(cnt=0;cnt<OrdersTotal();cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol())
        {

         // An order for this Symbol() is open so check
         // the stoploss, adjust upward as price changes
         // in the favorable direction.

         ccl=Close[1]; // 1 NOT 0 or the swings will kill ya!
         osl=OrderStopLoss();
         nslB=ccl-(Stop_Loss*Point());
         nslS=ccl+(Stop_Loss*Point());

         // Existing BUY orders trailing stop
         if ( OrderType() == 0 )
           {
            Comment("BUY  ",Symbol()," osl=",osl," nslB=",nslB );
            if ( nslB > osl )
              {
               Print("BUY MODIFY! ",Symbol()," osl=",osl," ccl=",ccl," nslB=",nslB);
               OrderModify(OrderTicket(),OrderOpenPrice(),nslB,OrderTakeProfit(),0,Red);
              }
           }

         // Existing SELL orders trailing stop
         if ( OrderType() == 1 )
           {
            Comment("SELL ",Symbol()," osl=",osl," nslS=",nslS );
            if ( nslS < osl )
              {
               Print("SELL MODIFY! ",Symbol()," osl=",osl," ccl=",ccl," nslS=",nslS );
               OrderModify(OrderTicket(),OrderOpenPrice(),nslS,OrderTakeProfit(),0,Red);
              }
           }

         // set the 'found' flag so we don't buy/sell any more
         foundorder=True;
         break;
        }
     }

   if ( foundorder == False )
     {

      Comment(" ");

      // three-period
      oTYP0=(High[0]+Low[0]+Close[0]+Close[0])/4;
      oTYP1=(High[1]+Low[1]+Close[1]+Close[1])/4;
      oTYP2=(High[2]+Low[2]+Close[2]+Close[2])/4;
      oTYP3=(High[3]+Low[3]+Close[3]+Close[3])/4;
      oTYP4=(High[4]+Low[4]+Close[4]+Close[4])/4;
      oTYP5=(High[5]+Low[5]+Close[5]+Close[5])/4;

      // down trend
      if(oTYP5>oTYP4 && oTYP4>oTYP3 && oTYP3>oTYP2 && oTYP2>oTYP1 && oTYP1>oTYP0)
        {
         // no take profit so I can scalp if I want
         Print("SELL Order started  ",Bid,"   ",Bid-(Stop_Loss*Point()) );
         OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+(Stop_Loss*Point()),0,"5P Sell",16789,0,Red);
         if(GetLastError()==0)Comment("SELL Order opened : ",Bid );

        }
      
      // up trend
      if(oTYP5<oTYP4 && oTYP4<oTYP3 && oTYP3<oTYP2 && oTYP2<oTYP1 && oTYP1<oTYP0)
        {
         // no take profit so I can scalp if I want
         Print("BUY  Order started  ",Ask,"   ",Ask-(Stop_Loss*Point()) );
         OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-(Stop_Loss*Point()),0,"5P Buy",16543,0,White);
         if(GetLastError()==0)Comment("BUY Order opened : ",Ask);
        }
     }           
      
   return(0);
  }

