//+------------------------------------------------------------------+
//|                                           SilverTrendTrading v3  |
//+------------------------------------------------------------------+
#include <stdlib.mqh>
//----
#property copyright   "fukinagashi"
#property link        "http://www.strategybuilderfx.com/forums/showthread.php?t=15429"
#property stacksize   1024
//----
extern int    MAPeriod=60;
extern double TrailingStop=0;
extern double TakeProfit=0;
extern double InitialStopLoss=0;
extern double FridayNightHour=16;
//----
double Lots=1;
int    risk=3;
datetime bartime=0;
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
   double MA, MAPrevious;
   double ADX;
   double dummy1[], dummy2[];
   bool LongSignal, ShortSignal, ExitLong, ExitShort;
   string setup;
//----
   static double lastslope= 0.0;
   static int didbreakalert= false;
//----
   if(IsTesting() && Bars<100) return(0);
   MagicNumber=40000 + func_Symbol2Val(Symbol())*100 + func_TimeFrame_Const2Val(Period());
   setup="STv3_" + Symbol() + "_" + func_TimeFrame_Val2String(func_TimeFrame_Const2Val(Period()));
     if (bartime==Time[0]) 
     {
      return(0);
      }
       else 
      {
      bartime=Time[0];
     }
   Signal=SilverTrendSignal();
//----
   double J_TPO=J_TPO(14);
     if (OldSignal!=Signal && Signal>0 && J_TPO>0) 
     {
      LongSignal=true;
      ShortSignal=false;
      }
       else if (OldSignal!=Signal && Signal<0  && J_TPO<0)
      {
         LongSignal=false;
         ShortSignal=true;
         }
          else 
         {
      LongSignal=false;
      ShortSignal=false;
     }
   Signal=OldSignal;
     if (Signal>0) 
     {
      ExitLong=false;
      ExitShort=true;
      }
       else if (Signal<0) 
      {
         ExitLong=true;
         ExitShort=false;
         } else {
      ExitLong=false;
      ExitShort=false;
     }
   total=OrdersTotal();
//----
   for(cnt=OrdersTotal();cnt>=0;cnt--)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
        if(OrderType()==OP_BUY && OrderMagicNumber()==MagicNumber) 
        {
           if(ExitLong) 
           {
            OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close position
              if (err>1) 
              {
               Print("Error closing BUY order [" + setup + "]: (" + err + ") " + ErrorDescription(err) + " " + setup);
              }
            }
             else if(TrailingStop>0) 
            {
                 if(Bid-OrderOpenPrice()>Point*TrailingStop) 
                 {
                  ts=Bid-Point*TrailingStop;
                 }
                 if((OrderStopLoss()<ts) || (OrderStopLoss()==0)) 
                 {
                  result=OrderModify(OrderTicket(),OrderOpenPrice(),ts,OrderTakeProfit(),0,White);
                  err=GetLastError();
                    if (err>1) 
                    {
                     Print("Error modifying BUY order [" + setup + "]: (" + err + ") " + ErrorDescription(err) + " " + setup);
                    }
                 }
              }
         } 
         else if (OrderType()==OP_SELL && OrderMagicNumber()==MagicNumber) 
         {
              if (ExitShort) 
              {
               OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close position
                 if (err>1) 
                 {
                  Print("Error closing SELL order [" + setup + "]: (" + err + ") " + ErrorDescription(err) + " " + setup);
                 }
               }
                else if(TrailingStop>0) 
               {
                    if((OrderOpenPrice()-Ask)>(Point*TrailingStop)) 
                    {
                     ts=Ask+Point*TrailingStop;
                    }
                    if((ts!=0) && ((OrderStopLoss()>ts) || (OrderStopLoss()==0))) 
                    {
                     result=OrderModify(OrderTicket(),OrderOpenPrice(),ts,OrderTakeProfit(),0,White);
                     err=GetLastError();
                       if (err>1) 
                       {
                        Print("Error modifying Sell order [" + setup + "]: (" + err + ") " + ErrorDescription(err) + " " + setup);
                       }
                    }
                 }
           }
     }
   if(AccountFreeMargin()<(1000*Lots)) return(0);
//----
   for(cnt=OrdersTotal();cnt>=0;cnt--)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderMagicNumber()==MagicNumber) return(0); // atm only one trade at a time
     }
     if(LongSignal) 
     {
        if (FridayNightHour>0 &&TimeDayOfWeek(Time[0])==5 && TimeHour(Time[0])>FridayNightHour) 
        {
         if (!IsTesting()) Print("Friday: No New Trades: " + TimeToStr(Time[0],TIME_DATE|TIME_MINUTES));
         return(0);
        }
        if(InitialStopLoss>0) { ts=Ask-(InitialStopLoss*Point);
        } 
        else 
        {
                        ts=0; 
        }
        if(TakeProfit>0) 
        {   
         tp=Ask+(TakeProfit*Point);
        }
         else 
         {
                         tp=0;
         }
      ticket=OrderSendExtended(Symbol(),OP_BUY,Lots,Ask,Slippage,ts,tp,setup,MagicNumber,0,Green);
      if (!IsTesting()) PlaySound("expert.wav");
        if(ticket>0) 
        {
         if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) { OrderPrint(); }
         }
          else 
         {
         err=GetLastError();
         Print("Error opening BUY order [" + setup + "]: (" + err + ") " + ErrorDescription(err) + " " + setup);
         if (!IsTesting()) PlaySound("alert2.wav");
        }
     }
     if(ShortSignal) 
     {
        if (FridayNightHour>0 &&TimeDayOfWeek(Time[0])==5 && TimeHour(Time[0])>FridayNightHour) 
        {
         if (!IsTesting()) Print("Friday: No New Trades: " + TimeToStr(Time[0],TIME_DATE|TIME_MINUTES));
         return(0);
        }
        if(InitialStopLoss>0) 
        {
         ts=Bid+(InitialStopLoss*Point);
        }
         else 
         {                
                        ts=0;
         }
        if(TakeProfit>0) 
        {
             tp=Bid-(TakeProfit*Point);
        }
         else 
         {
                        tp=0;
         }
      ticket=OrderSendExtended(Symbol(),OP_SELL,Lots,Bid,Slippage,ts,tp,setup,MagicNumber,0,Green);
      if (!IsTesting()) PlaySound("expert.wav");
        if(ticket>0) 
        {
           if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) 
           {
            OrderPrint();
           }
         }
          else 
         {
         err=GetLastError();
         Print("Error opening BUY order [" + setup + "]: (" + err + ") " + ErrorDescription(err)  + " " + setup);
         if (!IsTesting()) PlaySound("alert2.wav");
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int func_TimeFrame_Const2Val(int Constant)
  {
     switch(Constant) 
     {
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
//|                                                                  |
//+------------------------------------------------------------------+
           string func_TimeFrame_Val2String(int Value)
           {
              switch(Value) 
              {
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                    int func_Symbol2Val(string symbol) 
                    { if(symbol=="AUDUSD")             {   return(01);
                           } else if(symbol=="CHFJPY") {   return(10);
                           } else if(symbol=="EURAUD") {   return(10);
                           } else if(symbol=="EURCAD") {   return(11);
                           } else if(symbol=="EURCHF") {   return(12);
                           } else if(symbol=="EURGBP") {   return(13);
                           } else if(symbol=="EURJPY") {   return(14);
                           } else if(symbol=="EURUSD") {   return(15);
                           } else if(symbol=="GBPCHF") {   return(20);
                           } else if(symbol=="GBPJPY") {   return(21);
                           } else if(symbol=="GBPUSD") {   return(22);
                           } else if(symbol=="USDCAD") {   return(40);
                           } else if(symbol=="USDCHF") {   return(41);
                           } else if(symbol=="USDJPY") {   return(42);
                           } else if(symbol=="GOLD")   {   return(90);
                           } 
                           else 
                           {   Comment("unexpected Symbol"); return(0);
                       }
                    }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                    int OrderSendExtended(string symbol, int cmd, double volume, double price, int slippage, double stoploss, double takeprofit, string comment, int magic, datetime expiration=0, color arrow_color=CLR_NONE) 
                    {
                     datetime OldCurTime;
                     int timeout=30;
                     int ticket;
//----                     
                     OldCurTime=CurTime();
                       while(GlobalVariableCheck("InTrade") && !IsTradeAllowed()) 
                       {
                          if(OldCurTime+timeout<=CurTime()) 
                          {
                           Print("Error in OrderSendExtended(): Timeout encountered");
                           return(0);
                          }
                        Sleep(1000);
                       }
                     GlobalVariableSet("InTrade", CurTime());  // set lock indicator
                     ticket=OrderSend(symbol, cmd, volume, price, slippage, stoploss, takeprofit, comment, magic, expiration, arrow_color);
                     GlobalVariableDel("InTrade");   // clear lock indicator
                     return(ticket);
                    }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                  double SilverTrendSignal()
                    {
                     int RISK=3;
                     int CountBars=350;
                     int SSP=9;
                     int i;
                     int i1,i2,K;
                     double Range,AvgRange,smin,smax,SsMax,SsMin,price,val=0;
                     bool uptrend,old;
//----
                     K=33-RISK;
                       for(i=CountBars-SSP; i>=0; i--) 
                       {
                        Range=0;
                        AvgRange=0;
                        for(i1=i; i1<=i+SSP; i1++) 
                        {
                        AvgRange=AvgRange+MathAbs(High[i1]-Low[i1]); 
                        }
                        Range=AvgRange/(SSP+1);
                        SsMax=High[i];
                        SsMin=Low[i];
                          for(i2=i;i2<=i+SSP-1;i2++) 
                          {
                           price=High[i2];
                           if(SsMax<price) SsMax=price;
                           price=Low[i2];
                           if(SsMin>=price)  SsMin=price;
                          }
                        smin=SsMin+(SsMax-SsMin)*K/100;
                        smax=SsMax-(SsMax-SsMin)*K/100;
                        val=0;
                          if (Close[i]<smin) 
                          {
                           uptrend=false;
                          }
                          if (Close[i]>smax) 
                          {
                           uptrend=true;
                          }
      /*
      if        (uptrend!=old && uptrend==true)  { val=1; 
      } else if (uptrend!=old && uptrend==false) { val=-1; 
      } else {                                     val=0; }
      */
                          if        (uptrend==true)  
                          {
                           val=1;
                           }
                            else if (uptrend==false) 
                            {
                             val=-1;
                             }
                              else 
                              {
                                                   val=0; 
                              }
                        old=uptrend;
                       }
                     return(val);
                    }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                  double J_TPO(int Len)
                    {
                     double f0, f8, f10, f18, f20, f28, f30, f40, k,
                     var14, var18, var1C, var20, var24, shift, value;
                     int f38, f48, var6, var12, varA, varE;
                     double arr0[300], arr1[300], arr2[300], arr3[300];
                     //f38=0;
                     for(int i=200-Len-100; i>=0; i--)
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
                           arr0[f38]=Close[i];
                           k=f48;
                           f18=12/(k * (k - 1) * (k + 1));
                           f20=(f48 + 1) * 0.5;
                          }
                        else
                          {
                           if (f38<=f48) f38=f38 + 1;
                           else f38=f48 + 1;
                           f8=f10;
                           f10=Close[i];
                           if (f38 > f48)
                             {
                              for(var6=2; var6<=f48; var6++) arr0[var6-1]=arr0[var6];
                              arr0[f48]=Close[i];
                             }
                           else arr0[f38]=Close[i];
                           if ((f30>=f38) && (f8!=f10)) f40=1;
                           if ((f30==f38) && (f40==0)) f38=0;
                          }
                        if (f38>=f48)
                          {
                           for(varA=1; varA<=f48; varA++)
                             {
                              arr2[varA]=varA;
                              arr3[varA]=varA;
                              arr1[varA]=arr0[varA];
                             }
                           for(varA=1; varA<=(f48-1); varA++)
                             {
                              var24=arr1[varA];
                              var12=varA;
                              var6=varA + 1;
                              for(var6=varA+1; var6<=f48; var6++)
                                {
                                 if (arr1[var6] < var24)
                                   {
                                    var24=arr1[var6];
                                    var12=var6;
                                   }
                                }
                              var20=arr1[varA];
                              arr1[varA]=arr1[var12];
                              arr1[var12]=var20;
                              var20=arr2[varA];
                              arr2[varA]=arr2[var12];
                              arr2[var12]=var20;
                             }
                           varA=1;
                           while(f48 > varA)
                             {
                              var6=varA + 1;
                              var14=1;
                              var1C=arr3[varA];
                              while(var14!=0)
                                {
                                 if (arr1[varA]!=arr1[var6])
                                   {
                                    if ((var6 - varA) > 1)
                                      {
                                       var1C=var1C/(var6 - varA);
                                       varE=varA;
                                       for(varE=varA; varE<=(var6-1); varE++)
                                          arr3[varE]=var1C;
                                      }
                                    var14=0;
                                   }
                                 else
                                   {
                                    var1C=var1C + arr3[var6];
                                    var6=var6 + 1;
                                   }
                                }
                              varA=var6;
                             }
                           var1C=0;
                           for(varA=1; varA<=f48; varA++)
                              var1C=var1C + (arr3[varA] - f20) * (arr2[varA] - f20);
                           var18=f18 * var1C;
                          }
                        else
                           var18=0;
                        value=var18;
                        if (value==0) value=0.00001;
                        //ExtMapBuffer1[i]=value;
                       }
                  //---- done
                     return(value);
                    }
//+------------------------------------------------------------------+