//+------------------------------------------------------------------+
//|                                           SilverTrendTrading v5  |
//+------------------------------------------------------------------+
#include <stdlib.mqh>

#property copyright   "fukinagashi"
#property link        "http://www.strategybuilderfx.com/forums/showthread.php?t=15429"
#property stacksize   1024

extern int    MAPeriod=14;

extern double TrailingStop = 0;
extern double TakeProfit = 0;
extern double InitialStopLoss=0;
extern int    Type=1; // 1=EMA / 2=JMA / 3=JTPO

extern double FridayNightHour=16;

double Lots = 1;
int    risk=3;
datetime bartime;
double Slippage=3;
int Signal, OldSignal;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
   {
   int cnt, ticket, err, result, total;
   int has_a_short_trade=0, has_a_long_trade=0;
   int MagicNumber;
   double ts, tp, Min_OrderPrice;
   bool LongSignal, ShortSignal, ExitLong, ExitShort;

   string setup;
   
   static double lastslope= 0.0;
   static int didbreakalert= false;
   
   if (Volume[0]>1) {
      return(0);
   }

   // if(IsTesting() && Bars<100) return(0);  
   
	MagicNumber = 3500 + func_Symbol2Val(Symbol())*100 + func_TimeFrame_Const2Val(Period()); 

   setup="STv5_" + Symbol() + "_" + func_TimeFrame_Val2String(func_TimeFrame_Const2Val(Period()));

   if (bartime == Time[0]) {
      return(0);
   } else {
      bartime = Time[0]; 
   }

   Signal=SilverTrendSignal(1);

   if (Type==1) { // EMA
      double MA=iMA(NULL, 0, MAPeriod, 0, MODE_EMA, PRICE_MEDIAN, 0);
      double MAPrevious=iMA(NULL, 0, MAPeriod, 0, MODE_EMA, PRICE_MEDIAN, 1);
      if (OldSignal!=Signal && Signal>0 && MA>MAPrevious) {
         LongSignal=true;
         ShortSignal=false;
      } else if (OldSignal!=Signal && Signal<0  && MA<MAPrevious) {
         LongSignal=false;
         ShortSignal=true;
      } else {
         LongSignal=false;
         ShortSignal=false;
      }   
      OldSignal=Signal;
   } else if (Type==2) { // JMA
      double JMA=JMA(MAPeriod, 1);
      if (OldSignal!=Signal && Signal>0 && JMA>0) {
         LongSignal=true;
         ShortSignal=false;
      } else if (OldSignal!=Signal && Signal<0  && JMA<0){
         LongSignal=false;
         ShortSignal=true;
      } else {
         LongSignal=false;
         ShortSignal=false;
      }   
      OldSignal=Signal;
   } else if (Type==3) { // J_TPO
      double J_TPO=J_TPO(MAPeriod,1);
      if (OldSignal!=Signal && Signal>0 && J_TPO>0) {
         Print("LongSignal");
         LongSignal=true;
         ShortSignal=false;
      } else if (OldSignal!=Signal && Signal<0  && J_TPO<0){
         Print("ShortSignal");
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

   
   

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////// MODIFICATIONS ON OPEN ORDERS   ////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   total = OrdersTotal();

   for(cnt=total;cnt>=0;cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

      if(OrderType()==OP_BUY && OrderMagicNumber()==MagicNumber) {
         if(ExitLong) {	
            Print("Close Long");
            OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close position
            err = GetLastError();
            
   			if (err>1) {
               Print("Error closing BUY order [" + setup + "]: (" + err + ") " + ErrorDescription(err) + " " + setup); 
				}
            
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
   		if (ExitShort) {
            Print("Close Short");
            OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close position
            err = GetLastError();

   			if (err>1) {
               Print("Error closing SELL order [" + setup + "]: (" + err + ") " + ErrorDescription(err) + " " + setup); 
				}

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
   
 //  if (LongSignal || ShortSignal) {
   
/*      for(cnt=total;cnt>=0;cnt--)
      {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderMagicNumber()==MagicNumber) {
            return(0); // atm only one trade at a time
         }
      }
*/
   
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
//   }
   
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

int OrderSendExtended(string symbol, int cmd, double volume, double price, int slippage, double stoploss, double takeprofit, string comment, int magic, datetime expiration=0, color arrow_color=CLR_NONE) {
   datetime OldCurTime;
   int timeout=30;
   int ticket;

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

double SilverTrendSignal(int shift)
  {   
   int RISK=3;
   int CountBars=350;
   int SSP=9;
   int i;
   int i1,i2,K;
   double Range,AvgRange,smin,smax,SsMax,SsMin,price,val=0;
   bool uptrend,old;
   
   K=33-RISK; 
   
   for (i = CountBars-SSP; i>=shift; i--) { 
	  Range=0;
	  AvgRange=0;
	  for (i1=i; i1<=i+SSP; i1++) {AvgRange=AvgRange+MathAbs(High[i1]-Low[i1]); }
	  Range=AvgRange/(SSP+1);
     SsMax=High[i]; 
     SsMin=Low[i]; 
     for (i2=i;i2<=i+SSP-1;i2++) {
        price=High[i2];
      
        if(SsMax<price) SsMax=price; 
        price=Low[i2];
        if(SsMin>=price)  SsMin=price;
     }
 
     smin = SsMin+(SsMax-SsMin)*K/100; 
     smax = SsMax-(SsMax-SsMin)*K/100; 

	  val=0;
      if (Close[i]<smin) {
         uptrend = false;
      }
      if (Close[i]>smax) {
         uptrend = true;
      }
   
      /*
      if        (uptrend!=old && uptrend==true)  { val=1; 
      } else if (uptrend!=old && uptrend==false) { val=-1; 
      } else {                                     val=0; }
      */
      if        (uptrend==true)  { val=1; 
      } else if (uptrend==false) { val=-1; 
      } else {                     val=0; }
      
      old=uptrend;
      
   }
   return(val);
}

double J_TPO(int Len, int shift)
  {
     double f0, f8, f10, f18, f20, f28, f30, f40, k,
      var14, var18, var1C, var20, var24, value; 
     int f38, f48, var6, var12, varA, varE;
     double arr0[300], arr1[300], arr2[300], arr3[300]; 

   //f38=0;
   for(int i=200-Len-100; i>=shift; i--)
     {
     var14=0; 
     var1C=0; 
     if(f38==0)  
      { 
      f38=1; 
      f40=0; 
      if (Len-1>= 2) f30=Len-1;
      else f30=2; 
      f48=f30+1; 
      f10=Close[i]; 
      arr0[f38] = Close[i]; 
      k=f48;
      f18 = 12 / (k * (k - 1) * (k + 1)); 
      f20 = (f48 + 1) * 0.5; 
      }  
     else  
      { 
      if (f38 <= f48) f38 = f38 + 1;
      else f38 = f48 + 1; 
      f8 = f10; 
      f10 = Close[i]; 
      if (f38 > f48)  
        {
        for (var6 = 2; var6<=f48; var6++) arr0[var6-1] = arr0[var6]; 
        arr0[f48] = Close[i]; 
        }
      else arr0[f38] = Close[i]; 
      if ((f30 >= f38) && (f8 != f10)) f40 = 1;   
      if ((f30 == f38) && (f40 == 0)) f38 = 0;   
     }
   
   if (f38 >= f48)  
      {
      for (varA=1; varA<=f48; varA++) 
         {
         arr2[varA] = varA; 
         arr3[varA] = varA; 
         arr1[varA] = arr0[varA];
         } 
      
      for (varA=1; varA<=(f48-1); varA++) 
         {
         var24 = arr1[varA]; 
         var12 = varA; 
         var6 = varA + 1; 
         for (var6=varA+1; var6<=f48; var6++)
            {
            if (arr1[var6] < var24) 
               {
               var24 = arr1[var6]; 
               var12 = var6;
               }
            } 
         
         var20 = arr1[varA]; 
         arr1[varA] = arr1[var12]; 
         arr1[var12] = var20; 
         var20 = arr2[varA]; 
         arr2[varA] = arr2[var12]; 
         arr2[var12] = var20;
         } 
      
      varA = 1; 
      while (f48 > varA) 
        {
        var6 = varA + 1; 
        var14 = 1; 
        var1C = arr3[varA]; 
        while (var14 != 0) 
          {
          if (arr1[varA] != arr1[var6])  
             {
             if ((var6 - varA) > 1) 
                {
                var1C = var1C / (var6 - varA); 
                varE = varA; 
                for (varE=varA; varE<=(var6-1); varE++)
                   arr3[varE] = var1C;
                
                } 
             var14 = 0; 
             }
          else 
             {
             var1C = var1C + arr3[var6]; 
             var6 = var6 + 1; 
             } 
          } 
        varA = var6; 
        } 
      var1C = 0; 
      for (varA=1; varA<=f48; varA++) 
        var1C = var1C + (arr3[varA] - f20) * (arr2[varA] - f20);
              
      var18 = f18 * var1C;
     }
   else 
     var18 = 0; 

   value = var18; 
   if (value == 0) value = 0.00001;

   //ExtMapBuffer1[i]=value;
   }
//---- done
   return(value);
  }


double JMA(int Len, int phase) {
int       BarCount=300;
int    counted_bars=300;
//---- 
// variable definitions
int AccountedBars=0;
int jj=0;
int ii=0;
int shift=0;
double series=0;

double vv=0;
double v1=0;
double v2=0;
double v3=0;
double v4=0;
double s8=0;
double s10=0;
double s18=0;
double s20=0;
int v5=0;
int v6=0;
double s28=0;
double s30=0;
int s38=0;
int s40=0;
int s48=0;
int s50=0;
int s58=0;
int s60=0;
double s68=0;
double s70=0;
double f8=0;
double f10=0;
double f18=0;
double f20=0;
double f28=0;
double f30=0;
double f38=0;
double f40=0;
double f48=0;
double f50=0;
double f58=0;
double f60=0;
double f68=0; 
double f70=0;
double f78=0;
double f80=0;
double f88=0;
double f90=0;
double f98=0;
double fA0=0;
double fA8=0;
double fB0=0;
double fB8=0;
double fC0=0;
double fC8=0;
double fD0=0;
double f0=0;
double fD8=0;
double fE0=0;
double fE8=0;
int fF0=0;
double fF8=0;
int value2=0;
double JMA=0;
double prevtime=0; 

double list[127];
double ring1[127];
double ring2[10];
double buffer[61]; 

ArrayInitialize(list,0);
ArrayInitialize(ring1,0);
ArrayInitialize(ring2,0);
ArrayInitialize(buffer,0);

AccountedBars = counted_bars;

{
  s28 = 63; 
  s30 = 64; 
  for ( ii = 1 ; ii <= s28 ; ii++)
  { 
    list[ii] = -1000000; 
  } 
  for ( ii = s30 ; ii <= 127  ; ii++ )
  { 
    list[ii] = 1000000; 
  } 
  f0 = 1; 
} 

//{--------------------------------------------------------------------} 
for ( shift=counted_bars ; shift >= 0 ; shift-- )
{ 
  series=Close[shift]; 
  if (fF0 < 61) 
  { 
    fF0= fF0 + 1; 
    buffer[fF0] = series; 
  } 
  //{--------------------------------------------------------------------} 
  // { main cycle } 
  if (fF0 > 30) 
  {
    if (Len < 1.0000000002) 
    {
      f80 = 0.0000000001; //{1.0e-10} 
    }
    else 
    {
      f80 = (Len - 1) / 2.0; 
    }
    
    if (phase < -100) 
    {
      f10 = 0.5;
    } 
    else
    {
      if (phase > 100)
      { 
           f10 = 2.5;
      } 
      else
      {
        f10 = phase / 100 + 1.5; 
      }
    }
  
    v1 = MathLog(MathSqrt(f80)); 
    v2 = v1; 
    if (v1 / MathLog(2.0) + 2.0 < 0.0) 
    {
      v3 = 0;
    }
    else 
    {
      v3 = v2 / MathLog(2.0) + 2.0;
    } 
    f98 = v3; 
  
    if (0.5 <= f98 - 2.0)
    { 
      f88 = f98 - 2.0;
    } 
    else 
    {
      f88 = 0.5;
    } 
  
    f78 = MathSqrt(f80) * f98;
    f90 = f78 / (f78 + 1.0); 
    f80 = f80 * 0.9; 
    f50 = f80 / (f80 + 2.0); 
  
    if (f0 != 0) 
    {
      f0 = 0; 
      v5 = 0; 
      for ( ii = 1 ; ii <=29 ; ii++ ) 
      { 
        if (buffer[ii+1] != buffer[ii])
        {
          v5 = 1.0;
        } 
      } 
      
      fD8 = v5*30.0; 
      if (fD8 == 0)
      { 
        f38 = series;
      } 
      else 
      {
        f38 = buffer[1]; 
      }
      f18 = f38; 
      if (fD8 > 29) 
        fD8 = 29; 
    }
    else 
      fD8 = 0; 
    
    for ( ii = fD8 ; ii >= 0 ; ii-- )
    { //{ another bigcycle...} 
      value2=31-ii; 
      if (ii == 0)
      { 
        f8 = series;
      } 
      else 
      {
        f8 = buffer[value2]; 
      }
      f28 = f8 - f18; 
      f48 = f8 - f38; 
      if (MathAbs(f28) > MathAbs(f48)) 
      {
        v2 = MathAbs(f28);
      } 
      else 
      {
        v2 = MathAbs(f48); 
      }
      fA0 = v2; 
      vv = fA0 + 0.0000000001; //{1.0e-10;} 
      
      if (s48 <= 1)
      { 
        s48 = 127;
      } 
      else
      { 
        s48 = s48 - 1;
      } 
      if (s50 <= 1) 
      {
        s50 = 10;
      } 
      else 
      {
        s50 = s50 - 1;
      } 
      if (s70 < 128) 
        s70 = s70 + 1; 
      s8 = s8 + vv - ring2[s50]; 
      ring2[s50] = vv; 
      if (s70 > 10) 
      {
        s20 = s8 / 10;
      } 
      else 
        s20 = s8 / s70; 
      
      if (s70 > 127) 
      {
        s10 = ring1[s48]; 
        ring1[s48] = s20; 
        s68 = 64; 
        s58 = s68; 
        while (s68 > 1) 
        { 
          if (list[s58] < s10) 
          {
            s68 = s68 *0.5; 
            s58 = s58 + s68; 
          }
          else 
          if (list[s58] <= s10) 
          {
            s68 = 1; 
          }
          else 
          { 
            s68 = s68 *0.5; 
            s58 = s58 - s68; 
          } 
        } 
      }
      else 
      { 
        ring1[s48] = s20; 
        if (s28 + s30 > 127) 
        {
          s30 = s30 - 1; 
          s58 = s30; 
        }
        else 
        { 
          s28 = s28 + 1; 
          s58 = s28; 
        } 
        if (s28 > 96) 
        {
          s38 = 96;
        } 
        else 
          s38 = s28; 
        if (s30 < 32)
        { 
          s40 = 32;
        } 
        else 
          s40 = s30; 
      } 
      
      s68 = 64; 
      s60 = s68; 
      while (s68 > 1) 
      { 
        if (list[s60] >= s20) 
        {
          if (list[s60 - 1] <= s20) 
          {
            s68 = 1; 
          }
          else 
          { 
            s68 = s68 *0.5; 
            s60 = s60 - s68; 
          } 
        }
        else 
        { 
          s68 = s68 *0.5; 
          s60 = s60 + s68; 
        } 
        if ((s60 == 127) && (s20 > list[127])) 
          s60 = 128; 
      } 
      
      if (s70 > 127) 
      {
        if (s58 >= s60) 
        {
          if ((s38 + 1 > s60) && (s40 - 1 < s60)) 
          {
            s18 = s18 + s20;
          }
          else 
          if ((s40 > s60) && (s40 - 1 < s58)) 
            s18 = s18 + list[s40 - 1]; 
        }
        else 
        if (s40 >= s60) 
        {
          if ((s38 + 1 < s60) && (s38 + 1 > s58)) 
            s18 = s18 + list[s38 + 1]; 
        }
        else 
        if (s38 + 2 > s60)
        { 
          s18 = s18 + s20;
        }
        else 
        if ((s38 + 1 < s60) && (s38 + 1 > s58)) 
          s18 = s18 + list[s38 + 1]; 
        
        if (s58 > s60) 
        {
          if ((s40 - 1 < s58) && (s38 + 1 > s58)) 
          {
            s18 = s18 - list[s58];
          }
          else 
          if ((s38 < s58) && (s38 + 1 > s60)) 
            s18 = s18 - list[s38]; 
        }
        else 
        { 
          if ((s38 + 1 > s58) && (s40 - 1 < s58)) 
          {
            s18 = s18 - list[s58];
          } 
          else 
          if ((s40 > s58) && (s40 < s60)) 
            s18 = s18 - list[s40]; 
        } 
      } 
      
      if (s58 <= s60) 
      {
        if (s58 >= s60) 
        {
          list[s60] = s20;
        } 
        else 
        { 
          for ( jj = s58 + 1 ; jj <= s60 - 1 ; jj++ ) 
          { 
            list[jj - 1] = list[jj]; 
          } 
          list[s60 - 1] = s20; 
        } 
      }
      else 
      { 
        for ( jj = s58 - 1 ; jj >= s60 ; jj-- )
        {
          list[jj + 1] = list[jj]; 
        } 
        list[s60] = s20; 
      } 
      
      if (s70 <= 127) 
      {
        s18 = 0; 
        for (jj = s40 ; jj <= s38 ; jj++)
        {
          s18 = s18 + list[jj]; 
        } 
      } 
      f60 = s18 / (s38 - s40 + 1); 
      if (fF8 + 1 > 31)
      { 
        fF8 = 31;
      }
      else
        fF8 = fF8 + 1; 
      
      if (fF8 <= 30) 
      {
        if (f28 > 0)
        { 
          f18 = f8;
        }
        else 
          f18 = f8 - f28 * f90; 
        if (f48 < 0)
        { 
          f38 = f8;
        } 
        else 
          f38 = f8 - f48 * f90; 
        fB8 = series; 
        //{EasyLanguage does not have "continue" statement} 
        if (fF8 != 30)
        { 
          continue; 
        }
        if (fF8 == 30) 
        {
          fC0 = series; 
          if (MathCeil(f78) >= 1)
          { 
            v4 = MathCeil(f78);
          } 
          else 
            v4 = 1; 
          fE8 = MathCeil(v4); 
          if (MathFloor(f78) >= 1)
          { 
            v2 = MathFloor(f78);
          } 
          else 
            v2 = 1; 
          fE0 = MathCeil(v2); 
          if (fE8 == fE0)
          { 
            f68 = 1;
          } 
          else 
          { 
            v4 = fE8 - fE0; 
            f68 = (f78 - fE0) / v4; 
          } 
          if (fE0 <= 29)
          { 
            v5 = fE0;
          }
          else 
            v5 = 29; 
          if (fE8 <= 29) 
          {
            v6 = fE8;
          } 
          else 
            v6 = 29; 
          fA8 = (series - buffer[fF0 - v5]) * (1 - f68) / fE0 + (series - buffer[fF0 - v6]) * f68 / fE8; 
        } 
      }
      else 
      { 
        if (f98 >= MathPow(fA0/f60, f88))
        { 
          v1 = MathPow(fA0/f60, f88);
        } 
        else 
          v1 = f98; 
        if (v1 < 1)
        { 
          v2 = 1;
        }
        else 
        { 
          if (f98 >= MathPow(fA0/f60, f88))
          { 
            v3 = MathPow(fA0/f60, f88);
          } 
          else 
            v3 = f98; 
          v2 = v3; 
        } 
        f58 = v2; 
        f70 = MathPow(f90, MathSqrt(f58)); 
        if (f28 > 0)
        { 
          f18 = f8;
        } 
        else 
        {
          f18 = f8 - f28 * f70; 
        }
        if (f48 < 0)
        { 
          f38 = f8; 
        }
        else 
        {
          f38 = f8 - f48 * f70;
        } 
      }   
    } 
  
    if (fF8 > 30) 
    {
      f30 = MathPow(f50, f58); 
      fC0 = (1 - f30) * series + f30 * fC0; 
      fC8 = (series - fC0) * (1 - f50) + f50 * fC8; 
      fD0 = f10 * fC8 + fC0; 
      f20 = -f30 * 2; 
      f40 = f30 * f30; 
      fB0 = f20 + f40 + 1; 
      fA8 = (fD0 - fB8) * fB0 + f40 * fA8; 
      fB8 = fB8 + fA8; 
    } 
    JMA= fB8; 
  } 
  if (fF0 <= 30)
  { 
    JMA=0;
  } 

  //Print ("JMA is " + JMA + " shift is " + shift); 
 // ExtMapBuffer1[shift]=JMA; 
  
  if (shift>0)
  { 
    AccountedBars=AccountedBars+1;
  }
}
//----
   return(JMA);
  }
//+------------------------------------------------------------------+