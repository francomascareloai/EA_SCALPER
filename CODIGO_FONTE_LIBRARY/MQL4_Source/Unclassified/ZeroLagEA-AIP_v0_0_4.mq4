//+------------------------------------------------------------------+
//|                                             ZeroLagEA-AIP v0.0.4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//----
extern int FastEMA = 2;
extern int SlowEMA = 34;
extern int SignalEMA = 2;
extern double UseTimeSlice = 1;
extern int UseFreshMACDSig = 1;
extern double vLots = 2;
extern double Stoploss = 0;
extern double TakeProfit = 0;
extern int StartHour = 9, EndHour = 15, KillDay = 5, KillHour = 21;
//----
double total = 0, TradesThisSymbol = 0, cnt = 0, newbar = 0, mode = 0, rvimain = 0,
rvisignal = 0;
double SaR = 0, BuySig = 0, SellSig = 0, blueline = 0, greenline = 0, redline = 0, 
bluelinePrev = 0, greenlinePrev = 0, redlinePrev = 0, spanA = 0, spanB = 0, 
TimeSlice = 0, Hdirection = 0, LDirection = 0, Slippage = 5, OpenTrades = 0, 
FreshSig = 0, CurrentSig = 0, BuyWait = 0, SellWait = 0;
double Lots = 0, vSL = 30, vTP = 100, LineBuySig = 0, LineSellSig = 0, UpdateTS = 1;
double TradePrice = 0, TradeTime = 0, TradeStop = 0, dir = 0;
double Per = 10, Multi = 200, lastprice = 0, currentstop = 0, atr = 0, BarTime = 0;
int BarCount = 0;
double LookingToSellBreakPIPs = 0, LookingToBuyBreakPIPs = 0, NotSoldYet = 1, 
NotBoughtYet = 1, MACD_Signal = 0, MACD_Main = 0, MACD_Main2 = 0, MACD_Main3 = 0, 
MACD_Main4 = 0, MACD_Main5 = 0, FreshMACDSig = 0, MACD_MainPrev = 0, MACD_SignalPrev = 0;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
   Lots = vLots;
/*   Comment("\n", "Day : ", Day(), " Hour : ", Hour(), " Min ", Minute(), " Seconds ", Seconds(),
		         "\n", "Version 0.0.3",
		         "\n", Symbol(),
		         "\n", "sig:", MACD_Signal, " main:", MACD_Main);*/
//----
   if((TimeHour(CurTime()) < StartHour)  || (TimeHour(CurTime()) >= EndHour) || 
      (DayOfWeek() == KillDay && TimeHour(CurTime()) == KillHour))
     {
       /*Comment("Outside Trading Hours, Exiting...", 
		             "\n", "Version 0.0.4",
		             "\n", Symbol(),
		             "\n", "sig:", MACD_Signal, " main:", MACD_Main);*/
       total = OrdersTotal();
	      //----
       for(cnt = 0; cnt < total; cnt++)
         {// 3 
           OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
	          //----
           if(OrderSymbol() == Symbol())
	            { //4
 	             if(OrderType() == OP_BUY)
 		        	     { //5
						             OrderClose(OrderTicket(),Lots,Bid,Slippage,Green);
						             return(0);
			              } //5     
	              //----
               if(OrderType() == OP_SELL)
	                { //5
				               OrderClose(OrderTicket(), Lots, Ask, Slippage, Green);
				               return(0);
	                } //5
			          } //4
		       } //3
       return(0);
     }		
   if(newbar != Time[0] || SaR == 1)
     { //2
	      newbar = Time[0];
	      SaR = 0;
/*       if(UseTimeSlice == 1)
         { // 2
   	       if(Symbol() == "USDCHF")
   	         {
   	           Sleep(5000);
   	         }
   	       if(Symbol() == "GBPUSD")
   	         {
   	           Sleep(50000);
   	         }
   	       if(Symbol() == "EURUSD")
   	         {
   	           Sleep(9.0000);
   	         }
   	
   	       if(Symbol() == "USDJPY")
   	         {
   	           Sleep(135000);
   	         }
   	       if(Symbol() == "USDCAD")
             {
   	           Sleep(175000);
   	         }
   	       if(Symbol() == "AUDUSD")
   	         {
               Sleep(225000);
             }   
         } // 2*/    
       total = OrdersTotal();
       TradesThisSymbol = 0;
       //----
       for(cnt = 0; cnt < total; cnt++)
         { // 2
           OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
           //----
           if(OrderSymbol() == Symbol())
               TradesThisSymbol++;
         } // 2 // close for for(cnt=0;cnt<total;cnt++)        
	      MACD_Main = iCustom(NULL, 0, "ZeroLag MACD", FastEMA, SlowEMA, SignalEMA, 0, 1);
	      MACD_Signal = iCustom(NULL, 0, "ZeroLag MACD", FastEMA, SlowEMA, SignalEMA, 1, 1);
	      MACD_MainPrev = iCustom(NULL, 0, "ZeroLag MACD", FastEMA, SlowEMA, SignalEMA, 0, 2);
	      MACD_SignalPrev = iCustom(NULL, 0, "ZeroLag MACD", FastEMA, SlowEMA, SignalEMA, 1, 2);
	      FreshMACDSig = 0;
	      //----
       if(UseFreshMACDSig == 1)
	        {
	          if(((MACD_SignalPrev > MACD_MainPrev) && (MACD_Signal < MACD_Main)) || 
	             ((MACD_SignalPrev < MACD_MainPrev) && (MACD_Signal > MACD_Main)))
		             FreshMACDSig = 1;
	          //----
           if(FreshMACDSig != 1)
	              return(0);
	        }
       //----
       if(MACD_Signal > MACD_Main)
         {
           SellSig = 1;
           BuySig = 0;
         }  	 
	      //----
       if(MACD_Signal < MACD_Main)
         {
           SellSig = 0;
           BuySig = 1;
         }    
       total = OrdersTotal();
       TradesThisSymbol = 0;
       //----
       for(cnt = 0; cnt < total; cnt++)
         { // 2
           OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
           if(OrderSymbol() == Symbol())
             { // 3
               TradesThisSymbol++;
             } // 3 // close for if(OrderSymbol()==Symbol())
         } // 2 // 
       //----
       if(TradesThisSymbol != 0)
         { // 2
           total = OrdersTotal();
	          //----
           for(cnt = 0; cnt < total; cnt++)
             {// 3 
               OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
	              if(OrderSymbol() == Symbol())
	                { //4
 		   	            if(OrderType() == OP_BUY)
 		   	              { //5
				                   if(BuySig == 0 && SellSig == 1)
					                    { //7
						                     SaR = 1;
						                     OrderClose(OrderTicket(), Lots, Bid, Slippage, Green);
						                     return(0);
					                    } //7
			                  } //5
			                //----
                   if(OrderType() == OP_SELL)
 			                 { //5
			     	              if(SellSig == 0 && BuySig == 1)
					                    {//7
						                     SaR = 1;
						                     OrderClose(OrderTicket(), Lots, Ask, Slippage, Green);
						                     return(0);
					                    }//7 
				                 }//5
		               }//4
	            }//3
         }//2
       total = OrdersTotal();
       TradesThisSymbol = 0;
       //----
       for(cnt = 0; cnt < total; cnt++)
         { // 2
           OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
           //----
           if(OrderSymbol() == Symbol())
             { // 3
               TradesThisSymbol++;
             } // 3 // close for if(OrderSymbol()==Symbol())
         } // 2 // 
		     //----
       if(TradesThisSymbol == 0)
		       { //4
			        if(BuySig == 1 && SellSig == 0)
			          { //5
				           BuySig = 0;
				           vSL = 0;
				           vTP = 0;
				           OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, vSL, vTP, 
				                     "Buy Order placed at " + TimeToStr(CurTime()), 0, 0, Green);
				           return(0);
			          } //5
			        //----
           if(BuySig == 0 && SellSig == 1)
			          { //5
				           SellSig = 0;
				           vSL = 0;
				           vTP = 0;
				           OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, vSL, vTP, 
				                     "Sell Order placed at " + TimeToStr(CurTime()), 0, 0, Green);
				           return(0);
			          }	//5
		       } //4
     } // close of newbar
  } // close of start 
//+------------------------------------------------------------------+

