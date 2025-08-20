//+------------------------------------------------------------------+
//|                                           SilverTrendTrading v6  |
//+------------------------------------------------------------------+
#include <stdlib.mqh>

#property copyright   "fukinagashi"
#property link        "http://www.strategybuilderfx.com/forums/showthread.php?t=15429"
#property stacksize   1024

extern int     MAPeriod=120;
extern int     PrimaryType=1;      // 1 = SilverTrend / 2 = 
extern int     SecondaryType=2; // 0 = nothing / 1 = EMAAngle / 2 = CCIAngle
extern int     SignalOfFullCandle=1; // 1 - yes / 0 - no

extern double  AngleTreshold=0.3;

extern int     TrailingStop =0;
extern int     TakeProfit = 10;
extern int     InitialStopLoss=25;

extern double  Lots = 1;

extern double  FridayNightHour=16;

datetime       bartime;
double         Slippage=3;
int            Signal=0, OldSignal=0;

int start()
   {
   int cnt, ticket, err, result, total, shift;
   int has_a_short_trade=0, has_a_long_trade=0;
   int MagicNumber;
   double ts, tp, Min_OrderPrice;
   bool LongSignal, ShortSignal, ExitLong, ExitShort;
   double dummy1[], dummy2[], dummy3[], dummy4[];
   string setup;


	MagicNumber = 3500 + func_Symbol2Val(Symbol())*100 + func_TimeFrame_Const2Val(Period()); 

   setup="STv7_" + Symbol() + "_" + func_TimeFrame_Val2String(func_TimeFrame_Const2Val(Period()));

   if (SignalOfFullCandle==1) {
      shift=1;
   } else {
      shift=0;
   }
   
   if(PrimaryType==1) {
      double Plus=iCustom(NULL, 0, "SilverTrend_Signal", 0, shift);
      double Minus=iCustom(NULL, 0, "SilverTrend_Signal", 1, shift);
      
      if (Plus>0) {
         Signal=1;
      } else if (Minus>0) {
         Signal=-1;
      } else {
         Signal=0;
      }   
   } else if(PrimaryType==2) {
      //Signal=AndropovSignal(0, shift);
   }   

   if (SecondaryType==0) {
      if (OldSignal!=Signal && Signal>0) {
         Print("EnterLong");
         LongSignal=true;
         ShortSignal=false;
      } else if (OldSignal!=Signal && Signal<0) {
         Print("EnterShort");
         LongSignal=false;
         ShortSignal=true;
      } else {
         LongSignal=false;
         ShortSignal=false;
      }   
      OldSignal=Signal;
   } else if (SecondaryType==1) { // EMAAngle
      double EMA_Angle=EMAAngle(MAPeriod, 0, shift);
      if (OldSignal!=Signal && Signal>0 && EMA_Angle>AngleTreshold) {
         Print("EnterLong");
         LongSignal=true;
         ShortSignal=false;
      } else if (OldSignal!=Signal && Signal<0  && EMA_Angle<-AngleTreshold) {
         Print("EnterShort");
         LongSignal=false;
         ShortSignal=true;
      } else {
         LongSignal=false;
         ShortSignal=false;
      }   
      OldSignal=Signal;
   } else if (SecondaryType==2) { // CCIANgle
      double CCI_Angle=CCIAngle(MAPeriod, 0, shift);
      if (OldSignal!=Signal && Signal>0 && CCI_Angle>AngleTreshold) {
         Print("EnterLong");
         LongSignal=true;
         ShortSignal=false;
      } else if (OldSignal!=Signal && Signal<0  && CCI_Angle<-AngleTreshold){
         Print("EnterShort");
         LongSignal=false;
         ShortSignal=true;
      } else {
         LongSignal=false;
         ShortSignal=false;
      }   
      OldSignal=Signal;
   } 
      
   
   if (Signal>0) {
         Print("ExitShort");
      ExitLong=false;
      ExitShort=true;
   } else if (Signal<0) {
         Print("ExitLong");
      ExitLong=true;
      ExitShort=false;
   } else {
      ExitLong=false;
      ExitShort=false;
   }   

   Comment(Signal + " " + OldSignal + " " + CCI_Angle);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////// MODIFICATIONS ON OPEN ORDERS   ////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   total = OrdersTotal();

   for(cnt=total;cnt>=0;cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      OrderPrint();
   
      if(OrderType()==OP_BUY && OrderMagicNumber()==MagicNumber) {
      Print("Identified");
         if(ExitLong) {	
            Print("Close Long");
            OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Violet); // close position
            err = GetLastError();
            
   			if (err>1) {
               Print("Error closing BUY order [" + setup + "]: (" + err + ") " + ErrorDescription(err) + " " + setup); 
				}
				return(0);
            
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
      Print("Identified");
   		if (ExitShort) {
            Print("Close Short");
            OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Violet); // close position
            err = GetLastError();

   			if (err>1) {
               Print("Error closing SELL order [" + setup + "]: (" + err + ") " + ErrorDescription(err) + " " + setup); 
				}
				return(0);

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
   
   total = OrdersTotal();
   
   if (LongSignal || ShortSignal) {
   
   for(cnt=total;cnt>=0;cnt--)
      {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderMagicNumber()==MagicNumber) {
            return(0); // atm only one trade at a time
         }
      }
  
      if(LongSignal) {
            
      if (FridayNightHour>0 && TimeDayOfWeek(Time[0])==5 && TimeHour(Time[0])>FridayNightHour) {
         if (!IsTesting()) Print("Friday: No New Trades: " + TimeToStr(Time[0],TIME_DATE|TIME_MINUTES));
         return(0);   
      }
      
      if(InitialStopLoss>0) { ts = Ask-(InitialStopLoss*Point);
      } else {                ts = 0; }
            
      if(TakeProfit>0) {   tp = Ask+(TakeProfit*Point);
      } else {             tp = 0;}

      ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,ts,tp,setup,MagicNumber,0,Green);

      if (!IsTesting()) PlaySound("expert.wav");

 	   if(ticket>0) { if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) { OrderPrint(); }
		} else {
     		err = GetLastError();
     	   Print("Error opening BUY order [" + setup + "]: (" + err + ") " + ErrorDescription(err) + " " + setup); 
         if (!IsTesting()) PlaySound("alert2.wav");
      }
      }


      if(ShortSignal) { 
    
      if (FridayNightHour>0 &&TimeDayOfWeek(Time[0])==5 && TimeHour(Time[0])>FridayNightHour) {
         if (!IsTesting()) Print("Friday: No New Trades: " + TimeToStr(Time[0],TIME_DATE|TIME_MINUTES));
         return(0);   
      }
      
      if(InitialStopLoss>0) { ts = Bid+(InitialStopLoss*Point);
      } else {                ts = 0;}

      if(TakeProfit>0) {     tp = Bid-(TakeProfit*Point);
      } else {               tp = 0;}
      
  	   ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,ts,tp,setup,MagicNumber,0,Green);
      if (!IsTesting()) PlaySound("expert.wav");

      if(ticket>0) { if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) { OrderPrint(); }
      } else {
         err = GetLastError();
        	Print("Error opening BUY order [" + setup + "]: (" + err + ") " + ErrorDescription(err)  + " " + setup); 
         if (!IsTesting()) PlaySound("alert2.wav");
      }
      }
   }
   
   return(0);
 
}


int func_TimeFrame_Const2Val(int Constant ) {
   switch(Constant) {
      case 1:  // M1
         return(1);
      case 5:  // M5
         return(2);
      case 15:
         return(3);
      case 30:
         return(4);
      case 60:
         return(5);
      case 240:
         return(6);
      case 1440:
         return(7);
      case 10080:
         return(8);
      case 43200:
         return(9);
   }
}

//+------------------------------------------------------------------+
//| Time frame string appropriation  function                               |
//+------------------------------------------------------------------+

string func_TimeFrame_Val2String(int Value ) {
   switch(Value) {
      case 1:  // M1
         return("PERIOD_M1");
      case 2:  // M1
         return("PERIOD_M5");
      case 3:
         return("PERIOD_M15");
      case 4:
         return("PERIOD_M30");
      case 5:
         return("PERIOD_H1");
      case 6:
         return("PERIOD_H4");
      case 7:
         return("PERIOD_D1");
      case 8:
         return("PERIOD_W1");
      case 9:
         return("PERIOD_MN1");
   	default: 
   		return("undefined " + Value);
   }
}

int func_Symbol2Val(string symbol) {
	if(symbol=="AUDUSD") {	return(01);

	} else if(symbol=="CHFJPY") {	return(10);

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


	} else if(symbol=="GOLD") {	return(90);
	} else {	Comment("unexpected Symbol"); return(0);
	}
}

double EMAAngle(int EMAPeriod, int period, int shift) {
int StartEMAShift=6;
int EndEMAShift=0;

      double fEndMA=iMA(NULL,period,EMAPeriod,0,MODE_EMA,PRICE_MEDIAN,shift+EndEMAShift);
      double fStartMA=iMA(NULL,period,EMAPeriod,0,MODE_EMA,PRICE_MEDIAN,shift+StartEMAShift);
      // 10000.0 : Multiply by 10000 so that the fAngle is not too small
      // for the indicator Window.
      return(10000.0 * (fEndMA - fStartMA)/(StartEMAShift-EndEMAShift));
}

double CCIAngle(int CCIPeriod, int period, int shift) {
int StartCCIShift=2;
int EndCCIShift=0;

      double fEndCCI=iCCI(NULL, period, CCIPeriod, PRICE_MEDIAN, shift+EndCCIShift);
      double fStartCCI=iCCI(NULL, period, CCIPeriod, PRICE_MEDIAN, shift+StartCCIShift);
      // 10000.0 : Multiply by 10000 so that the fAngle is not too small
      // for the indicator Window.
      return((fEndCCI - fStartCCI)/(StartCCIShift-EndCCIShift));
}

