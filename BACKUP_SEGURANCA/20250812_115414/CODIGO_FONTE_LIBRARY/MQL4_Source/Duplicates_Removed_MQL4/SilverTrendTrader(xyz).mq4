//+------------------------------------------------------------------+
//|                                           SilverTrendTrading.mq4 |
//+------------------------------------------------------------------+
#include <stdlib.mqh>

#property copyright   "fukinagashi"
#property link        "http://www.strategybuilderfx.com/forums/showthread.php?t=15429"
#property stacksize   1024

extern int    MAPeriod=60;

extern double TrailingStop = 0;
extern double TakeProfit = 0;
extern double InitialStopLoss=0;

extern double FridayNightHour=16;

double Lots = 1;
int    risk=3;
double MaxTradesPerType=2;
datetime bartime = 0;
int BarHour=0;
double Slippage=0;
double DeMarkerPeriod=13;

//extern int bartime = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
   {
   int cnt, ticket, err, result, total;
   int has_a_short_trade=0, has_a_long_trade=0;
   int MagicNumber;
   double ts, tp, Min_OrderPrice;
   double MA, MAPrevious;
   int BuySellSignal=0;

   string setup;
   
   static double lastslope= 0.0;
   static int didbreakalert= false;
  
	MagicNumber = 40000; 

   setup="SILVERTREND";

   double BuyST=iCustom(NULL, 0, "SilverTrend", 0, 0);
   double SellST=iCustom(NULL, 0, "SilverTrend", 0, 0);
   
   
   MA=iMA(NULL, 0, 60, 0, MODE_EMA, PRICE_MEDIAN, 0);
   MAPrevious=iMA(NULL, 0, 60, 0, MODE_EMA, PRICE_MEDIAN, 1);


   if (bartime == Time[0]) {
      return(0);
   } else {
      bartime = Time[0]; // a new bar, so record its open time.   
   }

   if(IsTesting() && Bars<100) return(0);  
   

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////// MODIFICATIONS ON OPEN ORDERS   ////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   total = OrdersTotal();

   for(cnt=OrdersTotal();cnt>=0;cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

      if(OrderType()==OP_BUY && OrderMagicNumber()==MagicNumber) {
         if(SellST>0) {	
            OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close position
         } else if(TrailingStop>0) {
            if(Bid-OrderOpenPrice()>Point*TrailingStop) {
               ts = Bid-Point*TrailingStop;
            } 


				if((OrderStopLoss()<ts) || (OrderStopLoss()==0)) {
			      result=OrderModify(OrderTicket(),OrderOpenPrice(),ts,OrderTakeProfit(),0,White);
					err = GetLastError();
						
					if (err>1) {
                  Print("Error modifying BUY order [" + setup + "]: (" + err + ") " + ErrorDescription(err) + " " + setup); 
					}
				} 
			}
      } else if (OrderType()==OP_SELL && OrderMagicNumber()==MagicNumber) {
   		if (BuyST>0) {
            OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close position
         } else if(TrailingStop>0) {                 
            if((OrderOpenPrice()-Ask)>(Point*TrailingStop)) {
               ts=Ask+Point*TrailingStop;
            }

	         if((ts!=0) && ((OrderStopLoss()>ts) || (OrderStopLoss()==0))) {
     	     		result=OrderModify(OrderTicket(),OrderOpenPrice(),ts,OrderTakeProfit(),0,White);
     	     		err = GetLastError();
      	     		
					if (err>1) {
                  Print("Error modifying Sell order [" + setup + "]: (" + err + ") " + ErrorDescription(err) + " " + setup); 
         	  	}
         	}
         }
      }
   }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////// SETTING ORDERS                 ////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   if(AccountFreeMargin()<(1000*Lots)) return(0);  
   
   has_a_short_trade=0;
   has_a_long_trade=0;
      
   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      
      if(OrderType()<=OP_SELL && OrderMagicNumber()==MagicNumber) {
         if(OrderType()==OP_BUY){
            has_a_long_trade++;
         } else if(OrderType()==OP_SELL) {
            has_a_short_trade++;
         }
      } 
   } 

   if(
         (has_a_long_trade<MaxTradesPerType && 
         BuyST>0 &&
         MA>MAPrevious) 
         ) {
         
      if (FridayNightHour>0 &&TimeDayOfWeek(Time[0])==5 && TimeHour(Time[0])>FridayNightHour) {
         if (!IsTesting()) Print("Friday: No New Trades: " + TimeToStr(Time[0],TIME_DATE|TIME_MINUTES));
         return(0);   
      }
      
      if(InitialStopLoss>0) {
         ts = Ask-(InitialStopLoss*Point);
      } else {             ts = 0; 
      }
            
      if(TakeProfit>0) {   tp = Ask+(TakeProfit*Point);
      } else {             tp = 0;}

      ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,ts,tp,setup,MagicNumber,0,Green);

      if (!IsTesting()) PlaySound("expert.wav");

 	   if(ticket>0) {
     	   if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {
        	   OrderPrint();
   		}
		} else {
     		err = GetLastError();
     	   Print("Error opening BUY order [" + setup + "]: (" + err + ") " + ErrorDescription(err) + " " + setup); 
         if (!IsTesting()) PlaySound("alert2.wav");
      }
   }


   if(
   		(has_a_short_trade<MaxTradesPerType && 
         SellST>0 &&
         MA<MAPrevious) 
     ) { 
    
      if (FridayNightHour>0 &&TimeDayOfWeek(Time[0])==5 && TimeHour(Time[0])>FridayNightHour) {
         if (!IsTesting()) Print("Friday: No New Trades: " + TimeToStr(Time[0],TIME_DATE|TIME_MINUTES));
         return(0);   
      }
      
      if(InitialStopLoss>0) {
         ts = Bid+(InitialStopLoss*Point);
      } else {               ts = 0;}

      if(TakeProfit>0) {     tp = Bid-(TakeProfit*Point);
      } else {               tp = 0;}
      
  	   ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,ts,tp,setup,MagicNumber,0,Green);
      if (!IsTesting()) PlaySound("expert.wav");

      if(ticket>0) {
   		if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {
     			OrderPrint();
   		}
      } else {
         err = GetLastError();
        	Print("Error opening BUY order [" + setup + "]: (" + err + ") " + ErrorDescription(err)  + " " + setup); 
         if (!IsTesting()) PlaySound("alert2.wav");
      }
   }
   
   return(0);
 
}

