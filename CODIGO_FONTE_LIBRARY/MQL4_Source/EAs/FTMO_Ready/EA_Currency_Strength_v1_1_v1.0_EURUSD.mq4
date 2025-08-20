//+------------------------------------------------------------------+
//|                                       Currency Strength v1.0.mq4 |
//|                                                    Author: Jay_P |
//|                                                      09-Jan-2019 |
//+------------------------------------------------------------------+

#property copyright   "2019, Jaspreet Singh"                                     // copyright
#property version     "1.1"                                                      // Version
#property description "This Expert Advisor is strength of symbols & trade accordingly" // Description
#property strict

//--- input parameters
extern double TradingLots=0.01;
extern int  TakeProfit= 0; //Take Profit (in Pips)
extern int  StopLoss= 0; //StopLoss (in Pips)
extern bool UseSLTP = false;
extern bool TradeOnce=true; // Trade Once (per Day)
extern string prefix="";
extern string postfix="";
extern double diff_val=0.5; // Difference Between Two Currencies Percentage
extern int Magic=1; // Magic Number
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


int start()
{
RefreshRates();
/*
USDCHF, GBPUSD, EURUSD, USDJPY, USDCAD, NZDUSD, AUDUSD, AUDNZD, AUDCAD, AUDCHF, AUDJPY, CHFJPY, EURGBP, EURAUD,

EURCHF, EURJPY, EURNZD, EURCAD, GBPCHF, GBPAUD, GBPCAD, GBPJPY, CADJPY, NZDJPY, GBPNZD, CADCHF
*/

   double USDJPY = perch(prefix+"USDJPY"+postfix);
   double USDCAD = perch(prefix+"USDCAD"+postfix);
   double AUDUSD = perch(prefix+"AUDUSD"+postfix);
   double USDCHF = perch(prefix+"USDCHF"+postfix);
   double GBPUSD = perch(prefix+"GBPUSD"+postfix);
   double EURUSD = perch(prefix+"EURUSD"+postfix);
   double NZDUSD = perch(prefix+"NZDUSD"+postfix);
   double EURJPY = perch(prefix+"EURJPY"+postfix);
   double EURCAD = perch(prefix+"EURCAD"+postfix);
   double EURGBP = perch(prefix+"EURGBP"+postfix);
   double EURCHF = perch(prefix+"EURCHF"+postfix);
   double EURAUD = perch(prefix+"EURAUD"+postfix);
   double EURNZD = perch(prefix+"EURNZD"+postfix);
   double AUDNZD = perch(prefix+"AUDNZD"+postfix);
   double AUDCAD = perch(prefix+"AUDCAD"+postfix);
   double AUDCHF = perch(prefix+"AUDCHF"+postfix);
   double AUDJPY = perch(prefix+"AUDJPY"+postfix);
   double CHFJPY = perch(prefix+"CHFJPY"+postfix);
   double GBPCHF = perch(prefix+"GBPCHF"+postfix);
   double GBPAUD = perch(prefix+"GBPAUD"+postfix);
   double GBPCAD = perch(prefix+"GBPCAD"+postfix);
   double GBPJPY = perch(prefix+"GBPJPY"+postfix);
   double CADJPY = perch(prefix+"CADJPY"+postfix);
   double NZDJPY = perch(prefix+"NZDJPY"+postfix);
   double GBPNZD = perch(prefix+"GBPNZD"+postfix);
   double CADCHF = perch(prefix+"CADCHF"+postfix);


   double eur = (EURJPY+EURCAD+EURGBP+EURCHF+EURAUD+EURUSD+EURNZD)/7;
   double usd = (USDJPY+USDCAD-AUDUSD+USDCHF-GBPUSD-EURUSD-NZDUSD)/7;
   double jpy = (-1*(USDJPY+EURJPY+AUDJPY+CHFJPY+GBPJPY+CADJPY+NZDJPY))/7;
   double cad = (CADCHF+CADJPY-(GBPCAD+AUDCAD+EURCAD+USDCAD))/6;
   double aud = (AUDUSD+AUDNZD+AUDCAD+AUDCHF+AUDJPY-(EURAUD+GBPAUD))/7;
   double nzd = (NZDUSD+NZDJPY-(EURNZD+AUDNZD+GBPNZD))/5;
   double gbp = (GBPUSD-EURGBP+GBPCHF+GBPAUD+GBPCAD+GBPJPY+GBPNZD)/7;
   double chf = (CHFJPY-(USDCHF+EURCHF+AUDCHF+GBPCHF+CADCHF))/6;


   eur = NormalizeDouble(eur,2);
   usd = NormalizeDouble(usd,2);
   jpy = NormalizeDouble(jpy,2);
   cad = NormalizeDouble(cad,2);
   aud = NormalizeDouble(aud,2);
   nzd = NormalizeDouble(nzd,2);
   gbp = NormalizeDouble(gbp,2);
   chf = NormalizeDouble(chf,2);

   Comment("\n\n\n\n\n\n\n\n\n\n\nEUR: "+DoubleToStr(eur,2)+"\nUSD: "+DoubleToStr(usd,2)+"\nJPY: "+DoubleToStr(jpy,2)+"\nCAD: "+DoubleToStr(cad,2)+"\nAUD: "+DoubleToStr(aud,2)+"\nNZD: "+DoubleToStr(nzd,2)+"\nGBP: "+DoubleToStr(gbp,2)+"\nCHF: "+DoubleToStr(chf,2));

   if(MathAbs(usd-jpy)>diff_val)
     {
      if((usd-jpy)>0)
        {
         Trade("Buy",prefix+"USDJPY"+postfix);
        }
      if((usd-jpy)<0)
        {
         Trade("Sell",prefix+"USDJPY"+postfix);
        }
     }

   if(MathAbs(usd-cad)>diff_val)
     {
      if((usd-cad)>0)
        {
         Trade("Buy",prefix+"USDCAD"+postfix);
        }
      if((usd-cad)<0)
        {
         Trade("Sell",prefix+"USDCAD"+postfix);
        }
     }

   if(MathAbs(aud-usd)>diff_val)
     {
      if((aud-usd)>0)
        {
         Trade("Buy",prefix+"AUDUSD"+postfix);
        }
      if((aud-usd)<0)
        {
         Trade("Sell",prefix+"AUDUSD"+postfix);
        }
     }

   if(MathAbs(usd-chf)>diff_val)
     {
      if((usd-chf)>0)
        {
         Trade("Buy",prefix+"USDCHF"+postfix);
        }
      if((usd-chf)<0)
        {
         Trade("Sell",prefix+"USDCHF"+postfix);
        }
     }

   if(MathAbs(gbp-usd)>diff_val)
     {
      if((gbp-usd)>0)
        {
         Trade("Buy",prefix+"GBPUSD"+postfix);
        }
      if((gbp-usd)<0)
        {
         Trade("Sell",prefix+"GBPUSD"+postfix);
        }
     }

   if(MathAbs(eur-usd)>diff_val)
     {
      if((eur-usd)>0)
        {
         Trade("Buy",prefix+"EURUSD"+postfix);
        }
      if((eur-usd)<0)
        {
         Trade("Sell",prefix+"EURUSD"+postfix);
        }
     }

   if(MathAbs(nzd-usd)>diff_val)
     {
      if((nzd-usd)>0)
        {
         Trade("Buy",prefix+"NZDUSD"+postfix);
        }
      if((nzd-usd)<0)
        {
         Trade("Sell",prefix+"NZDUSD"+postfix);
        }
     }

   if(MathAbs(eur-jpy)>diff_val)
     {
      if((eur-jpy)>0)
        {
         Trade("Buy",prefix+"EURJPY"+postfix);
        }
      if((eur-jpy)<0)
        {
         Trade("Sell",prefix+"EURJPY"+postfix);
        }
     }

   if(MathAbs(eur-cad)>diff_val)
     {
      if((eur-cad)>0)
        {
         Trade("Buy",prefix+"EURCAD"+postfix);
        }
      if((eur-cad)<0)
        {
         Trade("Sell",prefix+"EURCAD"+postfix);
        }
     }

   if(MathAbs(eur-gbp)>diff_val)
     {
      if((eur-gbp)>0)
        {
         Trade("Buy",prefix+"EURGBP"+postfix);
        }
      if((eur-gbp)<0)
        {
         Trade("Sell",prefix+"EURGBP"+postfix);
        }
     }

   if(MathAbs(eur-chf)>diff_val)
     {
      if((eur-chf)>0)
        {
         Trade("Buy",prefix+"EURCHF"+postfix);
        }
      if((eur-chf)<0)
        {
         Trade("Sell",prefix+"EURCHF"+postfix);
        }
     }

   if(MathAbs(eur-aud)>diff_val)
     {
      if((eur-aud)>0)
        {
         Trade("Buy",prefix+"EURAUD"+postfix);
        }
      if((eur-aud)<0)
        {
         Trade("Sell",prefix+"EURAUD"+postfix);
        }
     }

   if(MathAbs(eur-nzd)>diff_val)
     {
      if((eur-nzd)>0)
        {
         Trade("Buy",prefix+"EURNZD"+postfix);
        }
      if((eur-nzd)<0)
        {
         Trade("Sell",prefix+"EURNZD"+postfix);
        }
     }

   if(MathAbs(aud-nzd)>diff_val)
     {
      if((aud-nzd)>0)
        {
         Trade("Buy",prefix+"AUDNZD"+postfix);
        }
      if((aud-nzd)<0)
        {
         Trade("Sell",prefix+"AUDNZD"+postfix);
        }
     }

   if(MathAbs(aud-cad)>diff_val)
     {
      if((aud-cad)>0)
        {
         Trade("Buy",prefix+"AUDCAD"+postfix);
        }
      if((aud-cad)<0)
        {
         Trade("Sell",prefix+"AUDCAD"+postfix);
        }
     }

   if(MathAbs(aud-chf)>diff_val)
     {
      if((aud-chf)>0)
        {
         Trade("Buy",prefix+"AUDCHF"+postfix);
        }
      if((aud-chf)<0)
        {
         Trade("Sell",prefix+"AUDCHF"+postfix);
        }
     }

   if(MathAbs(aud-jpy)>diff_val)
     {
      if((aud-jpy)>0)
        {
         Trade("Buy",prefix+"AUDJPY"+postfix);
        }
      if((aud-jpy)<0)
        {
         Trade("Sell",prefix+"AUDJPY"+postfix);
        }
     }

   if(MathAbs(chf-jpy)>diff_val)
     {
      if((chf-jpy)>0)
        {
         Trade("Buy",prefix+"CHFJPY"+postfix);
        }
      if((chf-jpy)<0)
        {
         Trade("Sell",prefix+"CHFJPY"+postfix);
        }
     }

   if(MathAbs(gbp-chf)>diff_val)
     {
      if((gbp-chf)>0)
        {
         Trade("Buy",prefix+"GBPCHF"+postfix);
        }
      if((gbp-chf)<0)
        {
         Trade("Sell",prefix+"GBPCHF"+postfix);
        }
     }

   if(MathAbs(gbp-aud)>diff_val)
     {
      if((gbp-aud)>0)
        {
         Trade("Buy",prefix+"GBPAUD"+postfix);
        }
      if((gbp-aud)<0)
        {
         Trade("Sell",prefix+"GBPAUD"+postfix);
        }
     }

   if(MathAbs(gbp-cad)>diff_val)
     {
      if((gbp-cad)>0)
        {
         Trade("Buy",prefix+"GBPCAD"+postfix);
        }
      if((gbp-cad)<0)
        {
         Trade("Sell",prefix+"GBPCAD"+postfix);
        }
     }

   if(MathAbs(gbp-jpy)>diff_val)
     {
      if((gbp-jpy)>0)
        {
         Trade("Buy",prefix+"GBPJPY"+postfix);
        }
      if((gbp-jpy)<0)
        {
         Trade("Sell",prefix+"GBPJPY"+postfix);
        }
     }

   if(MathAbs(cad-jpy)>diff_val)
     {
      if((cad-jpy)>0)
        {
         Trade("Buy",prefix+"CADJPY"+postfix);
        }
      if((cad-jpy)<0)
        {
         Trade("Sell",prefix+"CADJPY"+postfix);
        }
     }

   if(MathAbs(nzd-jpy)>diff_val)
     {
      if((nzd-jpy)>0)
        {
         Trade("Buy",prefix+"NZDJPY"+postfix);
        }
      if((nzd-jpy)<0)
        {
         Trade("Sell",prefix+"NZDJPY"+postfix);
        }
     }

   if(MathAbs(gbp-nzd)>diff_val)
     {
      if((gbp-nzd)>0)
        {
         Trade("Buy",prefix+"GBPNZD"+postfix);
        }
      if((gbp-nzd)<0)
        {
         Trade("Sell",prefix+"GBPNZD"+postfix);
        }
     }

   if(MathAbs(cad-chf)>diff_val)
     {
      if((cad-chf)>0)
        {
         Trade("Buy",prefix+"CADCHF"+postfix);
        }
      if((cad-chf)<0)
        {
         Trade("Sell",prefix+"CADCHF"+postfix);
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|            CALCULATING PERCENTAGE Of SYMBOLS                                                      |
//+------------------------------------------------------------------+
double perch(string sym)
  {RefreshRates();
   double op = iOpen(sym,PERIOD_D1,0);
   double cl = iClose(sym,PERIOD_D1,0);

   double per=0;
   if(op!=0 && cl!=0) //This solves the problem of Zero Divide
   {
      per = (cl-op)/op*100;
   }

   per=NormalizeDouble(per,2);
   
   return(per);
  }
//+------------------------------------------------------------------+
//|               TRADE EXECUTION FUNCTION
//+------------------------------------------------------------------+
int Trade(string signal,string symbol)
  {
   int Magic2=Magic+1;
   int count,count2=0;
   for(int pos=0; pos<=OrdersTotal(); pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)
         && OrderMagicNumber()==Magic       //When Magic number is correct      
         && OrderSymbol()==symbol) // Only When Its of Chart Symbol
        {              // and my pair.
         count++; // Count the number of Positions in Order List Of Chart Symbol
        } //if ended

      if(OrderSelect(pos,SELECT_BY_POS)
         && OrderMagicNumber()==Magic2
         && OrderSymbol()==symbol)
        {              // and my pair.
         count2++; // Count the number of Positions in Order List Of Chart Symbol
        } //if ended
     }//for ended

   double bid = MarketInfo(symbol,MODE_BID);
   double ask = MarketInfo(symbol,MODE_ASK);
   double point=MarketInfo(symbol,MODE_POINT);
   double digits=MarketInfo(symbol,MODE_DIGITS);

   double op = iOpen(symbol,PERIOD_D1,0);
   double cl = iClose(symbol,PERIOD_D1,0);

   int    Cur_Hour=Hour();             // Server time in hours
   double Cur_Min =Minute();           // Server time in minutes
   double Cur_time=Cur_Hour+(Cur_Min)/100; // Current time

   bool TradeTime=Cur_time>0.10 && Cur_time<23;

   int TodaySeconds=(Hour()*3600)+(Minute()*60)+Seconds();
   int YesterdayEnd=TimeCurrent()-TodaySeconds;
   int YesterdayStart=YesterdayEnd-86400;

   if(TradeOnce==true)
     {
      for(int h=OrdersHistoryTotal()-1;h>=0;h--) // Trade Once per Pair
        {
         if(OrderSelect(h,SELECT_BY_POS,MODE_HISTORY)==true) // select next
           {
            if(OrderCloseTime()>YesterdayEnd && OrderSymbol()==symbol && OrderMagicNumber()==Magic)
              {
               signal="NoTrade";
              }

            if(OrderCloseTime()>YesterdayEnd && OrderSymbol()==symbol && OrderMagicNumber()==Magic2)
              {
               signal="NoTrade";
              }
           }
        }
     }
     
bool result_buy, result_sell=false;

   if(!count && TradeTime)
     {

      if(signal=="Buy" && op<cl && CheckVolumeValue(TradingLots,symbol))
        {
         result_buy=OrderSend(symbol,OP_BUY,TradingLots,ask,0,0,0,"Buy-CSv1",Magic,0,Green);
         if(result_buy==true)
         {
            //Alert(symbol+"-Buy Order CSv1.1");
         }
        }
     }

   if(!count2 && TradeTime)
     {
      if(signal=="Sell" && op>cl && CheckVolumeValue(TradingLots,symbol))
        {
         result_sell=OrderSend(symbol,OP_SELL,TradingLots,bid,0,0,0,"Sell-CSv1",Magic2,0,Red);
         if(result_sell==true)
         {
            //Alert(symbol+"-Buy Order CSv1.1");
         }
        }

     }// If Ended

   if(OrdersTotal()>0)
     {
      for(int i=1; i<=OrdersTotal(); i++) // Cycle searching in orders
        {
         if(OrderSelect(i-1,SELECT_BY_POS)==true && OrderSymbol()==symbol)
           {
            double tpb=NormalizeDouble(OrderOpenPrice()+TakeProfit*point*10,digits);
            double tps=NormalizeDouble(OrderOpenPrice()-TakeProfit*point*10,digits);
            
            double slb=NormalizeDouble(OrderOpenPrice()-StopLoss*point*10,digits);
            double sls=NormalizeDouble(OrderOpenPrice()+StopLoss*point*10,digits);
            
            if(TakeProfit==0)
            {
               tpb = 0;
               tps = 0;
            }
            if(StopLoss==0)
            {
               slb = 0;
               sls = 0;
            }

            if(OrderMagicNumber()==Magic && OrderType()==OP_BUY && (OrderTakeProfit()!=tpb || OrderStopLoss()!=slb) && OrderSymbol()==symbol && UseSLTP==true)
              {
               OrderModify(OrderTicket(),0,slb,tpb,0,CLR_NONE);
               Alert(symbol+"-Buy ==> TP: "+DoubleToStr(tpb,5)+" || SL: "+DoubleToStr(slb,5)+" <==");
              }

            if(OrderMagicNumber()==Magic2 && OrderType()==OP_SELL && (OrderTakeProfit()!=tps || OrderStopLoss()!=sls) && OrderSymbol()==symbol && UseSLTP==true)
              {
               OrderModify(OrderTicket(),0,sls,tps,0,CLR_NONE);
               Alert(symbol+"-Sell ==> TP: "+DoubleToStr(tps,5)+" || SL: "+DoubleToStr(sls,5)+" <==");
              }
           }//Nested-if Ended
        }//for loop ended
     }//if Ended

   return(0);

  }
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string sym)
  {
//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(sym,SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(sym,SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      return(false);
     }

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(sym,SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      return(false);
     }
   return(true);
  }