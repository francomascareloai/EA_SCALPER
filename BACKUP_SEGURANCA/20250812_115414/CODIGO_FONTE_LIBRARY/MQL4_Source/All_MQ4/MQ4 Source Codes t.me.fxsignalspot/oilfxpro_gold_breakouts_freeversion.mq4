//+------------------------------------------------------------------+
//|                     oilfxprobreakouts GOLDBREAKOUTS free version  |
//+------------------------------------------------------------------+
#include <stdlib.mqh>

#property copyright   "copyright.oilfxpro.com"
#property link        "http://www.oilfxpro.com"
// programmed by oildaytrader

extern int BeginSession1=13;
extern int EndSession1=14;
extern int BeginSession2=11;
extern int EndSession2=12;
extern double Lots = 0.2;
extern int PipsForEntry= 15;

extern int LocalTimeZone= 1;
extern int DestTimeZone= 1;

extern int ClsOnlUnprTX=1; // 1 = yes / 0 = no
extern int ProtectYourInvestments=0; // 1 = yes / 0 = no
extern int Type_TS_Calc=1; // 1 - classic / 2 - ATR / 3 - HalfVotality
extern double FactorTSCalculation = 0.5;

extern double TrailingStop = 40;
extern double TakeProfit = 70;
extern double InitialStopLoss=40;

datetime bartime = 0;
double Slippage=3;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
   {
   int cnt, ticket, err, i, j;
   int MagicNumber;
   double ts, tp, sl, LowestPrice, HighestPrice, Price;
   bool Order[5];
   string setup;
   datetime Validity=0;
   
   int TimeZoneDiff= LocalTimeZone - DestTimeZone;   

	MagicNumber = func_Symbol2Val(Symbol())*100; 

   setup="oilfxpro" + Symbol();

   if (bartime == Time[0]) {
      return(0);
   } else {
      bartime = Time[0]; 
   }



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////// MODIFICATIONS ON OPEN ORDERS   ////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


   for(cnt=OrdersTotal();cnt>=0;cnt--)
   {
      if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) {
      err = GetLastError();
  		if (err>1) { Print("Error selecting order [" + setup + "]: (" + err + ") " + ErrorDescription(err)); }
      
      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && (OrderMagicNumber()==(MagicNumber+1) || OrderMagicNumber()==(MagicNumber+3))) {
      	if(TimeDay(OrderOpenTime())!=TimeDay(Time[0])) {
            if (ClsOnlUnprTX==1) {
               if(Bid-OrderOpenPrice()<Point*TrailingStop) {
                  OrderClose(OrderTicket(), Lots, Bid, 3, Red);
               }  
            } else {
         		 OrderClose(OrderTicket(), Lots, Bid, 3, Red);
         	}
            err = GetLastError();
      		if (err>1) { Print("Error closing buy order [" + setup + "]: (" + err + ") " + ErrorDescription(err)); }
			} else if (TrailingStop>0) {
			   if (ProtectYourInvestments==1 && Bid-OrderOpenPrice()>Point*TrailingStop) {
			      ts = OrderOpenPrice();
			   } else {
			      if (Type_TS_Calc==1) {
                  ts = Bid-(Point*TrailingStop);
               } else if (Type_TS_Calc==2) {
                  ts = Low[0] - FactorTSCalculation * iATR(NULL,0,14,0);
               } else if (Type_TS_Calc==3) {
                  ts = Low[0] - (FactorTSCalculation *(High[0]-Low[0]));
               }
				}
				if (OrderStopLoss()<ts && Bid-OrderOpenPrice()>Point*TrailingStop) OrderModify(OrderTicket(),OrderOpenPrice(),ts,OrderTakeProfit(),0,White);
            err = GetLastError();
      		if (err>1) { Print("Error modifying buy order [" + setup + "]: (" + err + ") " + ErrorDescription(err)); }
			}
      } else if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && (OrderMagicNumber()==(MagicNumber+2) || OrderMagicNumber()==(MagicNumber+4))) {
      	if(TimeDay(OrderOpenTime())!=TimeDay(Time[0])) {
            if (ClsOnlUnprTX==1) {
               if((OrderOpenPrice()-Ask)<(Point*TrailingStop)) {
                  OrderClose(OrderTicket(), Lots, Ask, 3, Red);
               }
            } else {
         		 OrderClose(OrderTicket(), Lots, Ask, 3, Red);
         	}
            err = GetLastError();
      		if (err>1) { Print("Error closing Sell order [" + setup + "]: (" + err + ") " + ErrorDescription(err)); }
			} else if (TrailingStop>0) {	
			   if (ProtectYourInvestments==1 && (OrderOpenPrice()-Ask)>(Point*TrailingStop)) {
			      ts = OrderOpenPrice();
			   } else {
			      if (Type_TS_Calc==1) {
                  ts = Ask+(Point*TrailingStop);
               } else if (Type_TS_Calc==2) {
                  ts = High[0] + FactorTSCalculation * iATR(NULL,0,14,0);
               } else if (Type_TS_Calc==3) {
                  ts = High[0] + (FactorTSCalculation *(High[0]-Low[0]));
               }
				}

				if (OrderStopLoss()>ts && (OrderOpenPrice()-Ask)>(Point*TrailingStop)) OrderModify(OrderTicket(),OrderOpenPrice(),ts,OrderTakeProfit(),0,White);
            err = GetLastError();
      		if (err>1) { Print("Error modifyin sell order [" + setup + "]: (" + err + ") " + ErrorDescription(err)); }
			}
		}
		}
	}
			

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////// SETTING ORDERS                 ////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   if(AccountFreeMargin()<(1000*Lots)) return(0);  
   
	Validity=StrToTime(TimeYear(Time[0]) + "." + TimeMonth(Time[0]) + "." + TimeDay(Time[0]) + " 16:59")+(TimeZoneDiff*3600);

	
	for(i=1;i<5;i++) { Order[i]=false; }
	
   for(cnt=OrdersTotal();cnt>=0;cnt--) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
		
		err = GetLastError();
      
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==(MagicNumber+1)) {
      	Order[1]=true;
      } else if (OrderSymbol()==Symbol() && OrderMagicNumber()==(MagicNumber+2)) {
      	Order[2]=true;
      } else if (OrderSymbol()==Symbol() && OrderMagicNumber()==(MagicNumber+3)) {
      	Order[3]=true;
      } else if (OrderSymbol()==Symbol() && OrderMagicNumber()==(MagicNumber+4)) {
      	Order[4]=true;
      }
	}      	
	
	
	if (TimeHour(Time[0])==EndSession1+TimeZoneDiff && TimeMinute(Time[0])==0) {
		
		LowestPrice=Low[Lowest(NULL, 0, MODE_LOW, 240/Period(), 0)];
		HighestPrice=High[Highest(NULL, 0, MODE_HIGH, 240/Period(), 0)];
		
		Print("Determine Low: " + LowestPrice + " and High: " + HighestPrice + " for timephase " + TimeToStr(Time[240/Period()]) + " - " + TimeToStr(Time[0]));
		
		Price = HighestPrice+PipsForEntry*Point;
		
   	if (TakeProfit>0) {  tp=Price+TakeProfit*Point;
		} else { 				tp=0; }
	
		if (InitialStopLoss>0) { 	
         if((Price-InitialStopLoss*Point)<LowestPrice) { 
            sl = LowestPrice;
         } else {                                        
            sl = Price-InitialStopLoss*Point;
         }
		} else { 						sl=0; }

		if (!Order[1]) ticket=OrderSendExtended(Symbol(),OP_BUYSTOP,Lots,Price,Slippage,sl,tp,setup,(MagicNumber+1),Validity,Green);
      	   
		err = GetLastError();
		
		if (err==130) {
         ticket=OrderSendExtended(Symbol(),OP_BUY,Lots,Bid,Slippage,sl,tp,setup,(MagicNumber+1),0,Green);
      } else if (err>1) { Print("Error setting buy order [" + setup + "]: (" + err + ") " + ErrorDescription(err)); }
      
  		Price = LowestPrice-PipsForEntry*Point;

   	if (TakeProfit>0) {  tp=Price-TakeProfit*Point;
		} else { 				tp=0; }
		if (InitialStopLoss>0) { 	
         if((Price+InitialStopLoss*Point)>HighestPrice) { 
            sl = HighestPrice;
         } else {                                         
            sl = Price+InitialStopLoss*Point;
         }
		} else { 						sl=0; }


		if (!Order[2]) ticket=OrderSendExtended(Symbol(),OP_SELLSTOP,Lots,Price,Slippage,sl,tp,setup,(MagicNumber+2),Validity,Green); 
		err = GetLastError();
		
		if (err==130) {
         ticket=OrderSendExtended(Symbol(),OP_SELL,Lots,Bid,Slippage,sl,tp,setup,(MagicNumber+1),0,Green);
      } else if (err>1) { Print("Error setting sell order [" + setup + "]: (" + err + ") " + ErrorDescription(err)); }
	}
	
	if (TimeHour(Time[0])==EndSession2+TimeZoneDiff && TimeMinute(Time[0])==0) {

		LowestPrice=Low[Lowest(NULL, 0, MODE_LOW, 240/Period(), 0)];
		HighestPrice=High[Highest(NULL, 0, MODE_HIGH, 240/Period(), 0)];
		
		Print("Determine Low: " + LowestPrice + " and High: " + HighestPrice + " for timephase " + TimeToStr(Time[240/Period()]) + " - " + TimeToStr(Time[0]));

		Price = HighestPrice+PipsForEntry*Point;

   	if (TakeProfit>0) {  tp=Price+TakeProfit*Point;
		} else { 				tp=0; }
	
		if (InitialStopLoss>0) { 	
         if((Price-InitialStopLoss*Point)<LowestPrice) { 
            sl = LowestPrice;
         } else {                                        
            sl = Price-InitialStopLoss*Point;
         }
		} else { 						sl=0; }

		if (!Order[3]) ticket=OrderSendExtended(Symbol(),OP_BUYSTOP,Lots,Price,Slippage,sl,tp,setup,(MagicNumber+3),Validity,Green); 

		err = GetLastError();
		
		if (err==130) {
         ticket=OrderSendExtended(Symbol(),OP_BUY,Lots,Ask,Slippage,sl,tp,setup,(MagicNumber+1),0,Green);
      } else if (err>1) { Print("Error setting buy order [" + setup + "]: (" + err + ") " + ErrorDescription(err)); }

  		Price = LowestPrice-PipsForEntry*Point;

   	if (TakeProfit>0) {  tp=Price-TakeProfit*Point;
		} else { 				tp=0; }
		if (InitialStopLoss>0) { 	
         if((Price+InitialStopLoss*Point)>HighestPrice) { 
            sl = HighestPrice;
         } else {                                         
            sl = Price+InitialStopLoss*Point;
         }
		} else { 						sl=0; }

		if (!Order[4]) ticket=OrderSendExtended(Symbol(),OP_SELLSTOP,Lots,Price,Slippage,sl,tp,setup,(MagicNumber+2),Validity,Green); 

		err = GetLastError();
		
		if (err==130) {
         ticket=OrderSendExtended(Symbol(),OP_SELL,Lots,Bid,Slippage,sl,tp,setup,(MagicNumber+1),0,Green);
      } else if (err>1) { Print("Error setting sell order [" + setup + "]: (" + err + ") " + ErrorDescription(err)); }
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////// DIVERSE SUBROUTINES   /////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

int func_Symbol2Val(string symbol) {
	if(symbol=="AUDUSD") {	return(01);

	} else if(symbol=="CHFJPY") {	return(02);

	} else if(symbol=="EURAUD") {	return(10);
	} else if(symbol=="EURCAD") {	return(11);
	} else if(symbol=="EURCHF") {	return(12);
	} else if(symbol=="EURGBP") {	return(13);
	} else if(symbol=="EURJPY") {	return(14);
	} else if(symbol=="EURUSD") {	return(15);

	} else if(symbol=="GBPCHF") {	return(20);
	} else if(symbol=="GBPJPY") {	return(21);
	} else if(symbol=="GBPUSD") { return(22);


	} else if(symbol=="USDCAD") {	return(40);
	} else if(symbol=="USDCHF") {	return(41);
	} else if(symbol=="USDJPY") {	return(42);


	} else if(symbol=="GLD") {	return(90);
	} else if(symbol=="zg") {	return(43);

	} else {	Comment("unexpected Symbol"); return(0);
	}
}

int OrderSendExtended(string symbol, int cmd, double volume, double price, int slippage, double stoploss, double takeprofit, string comment, int magic, datetime expiration=0, color arrow_color=CLR_NONE) {
   datetime OldCurTime;
   int timeout=30;
   int ticket;
   
   if (!IsTesting()) {
      MathSrand(LocalTime());
      Sleep(MathRand());
   }

   OldCurTime=CurTime();
   while (GlobalVariableCheck("InTrade") && !IsTradeAllowed()) {
      if(OldCurTime+timeout<=CurTime()) {
         Print("Error in OrderSendExtended(): Timeout encountered");
         return(0); 
      }
      Sleep(1000);
   }
     
   GlobalVariableSet("InTrade", CurTime());  // set lock indicator
   ticket = OrderSend(symbol, cmd, volume, price, slippage, stoploss, takeprofit, comment, magic, expiration, arrow_color);
   GlobalVariableDel("InTrade");   // clear lock indicator
   return(ticket);
}

