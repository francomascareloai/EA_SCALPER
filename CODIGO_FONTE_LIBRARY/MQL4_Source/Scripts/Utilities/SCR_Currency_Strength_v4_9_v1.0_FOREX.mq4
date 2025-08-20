//+------------------------------------------------------------------+
//|                                     Currency Strength v4.9.mq4 |
//|                                                           Author: Jay_P |
//|                                                               25-Jan-2017 |
//|                                     Modded by AG2012 03/10/19|
//+------------------------------------------------------------------+
#property copyright "Currency Strength EA by Jay_P, modified by AG2012"



//--- input parameters
extern double TradingLots = 0.01;
extern int  TakeProfit= 150; // Take Profit (in Pips)
extern int  StopLoss = 400; // Stop Loss (in pips)
extern int Slippage = 3;
//extern bool TF = PERIOD_H4;
//extern bool UseTrailing = true;
//extern int  TrailingStop = 20; // Trailing Stop (in pips)
//extern int  MinPipsToTrail = 5; // Trailing Distance (in pips)
extern bool UseOrderClose = true;
extern bool TradeOnce = true; // Trade Once (per Day)
extern string prefix="";
extern string postfix="";
extern double diff_val = 0.65; // Difference Between Two Currencies Percentage
string calc_per = PERIOD_D1;
int Magic=1284; // Magic Number
int Magic2=1294;
double signal;
//string rsi;
//double rsi = iRSI(Symbol(),PERIOD_H1, 2, PRICE_CLOSE, 0);
//double Magic;
//string sym;
//bool ok2Trade;
//bool symbol;

/*void TrailingStop() {
string sym=OrderSymbol();
   for (int l_pos_0 = 0; l_pos_0 <= OrdersTotal(); l_pos_0++) {
      OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber() == Magic) {
         if (OrderType() == OP_BUY)
            if ((MarketInfo(sym, MODE_BID) - OrderOpenPrice()) / MarketInfo(sym, MODE_POINT) >= MinPipsToTrail && OrderStopLoss() < MarketInfo(sym, MODE_BID) - TrailingStop * MarketInfo(sym, MODE_POINT)) OrderModify(OrderTicket(), OrderOpenPrice(), MarketInfo(sym, MODE_BID) - TrailingStop * MarketInfo(sym, MODE_POINT), OrderTakeProfit(), 0, Blue);
         else if (OrderMagicNumber() == Magic2)
         if (OrderType() == OP_SELL) {
         if ((OrderOpenPrice() - MarketInfo(sym, MODE_ASK)) / MarketInfo(sym, MODE_POINT) >= MinPipsToTrail && OrderStopLoss() > MarketInfo(sym, MODE_ASK) +
               TrailingStop * MarketInfo(sym, MODE_POINT)) OrderModify(OrderTicket(), OrderOpenPrice(), MarketInfo(sym, MODE_ASK) + TrailingStop * MarketInfo(sym, MODE_POINT), OrderTakeProfit(), 0, Red);
         }
      }
   }
}*/


//+------------------------------------------------------------------+
//|                                                                                   |
//+------------------------------------------------------------------+
int start()
  {
   
   


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

//---------------------------------------------------------
   
    Comment (
     "\n"
     "-----------------------------------------------------\n"
     "ACCOUNT INFORMATION:\n"
     "This Broker Is : " + AccountCompany()+ "\n"
     "Account Name:     " + AccountName()+ "\n"
     "Account Leverage:     " + DoubleToStr(AccountLeverage(), 0)+ "\n"
     "Account Balance:     " + DoubleToStr(AccountBalance(), 2)+ "\n"
     "Account Equity:     " + DoubleToStr(AccountEquity(), 2)+ "\n"
     "Free Margin:     " + DoubleToStr(AccountFreeMargin(), 2)+ "\n"
     "Used Margin:     " + DoubleToStr(AccountMargin(), 2)+ "\n"
     "Account Profit:     " + DoubleToStr(AccountProfit(), 2)+ "\n"
     "-----------------------------------------------------\n"
     "\n"
     "\n"
     "\n\n\n\n\n\n\n\n\n\n\nEUR: "+eur+"\nUSD: "+usd+"\nJPY: "+jpy+"\nCAD: "+cad+"\nAUD: "+aud+"\nNZD: "+nzd+"\nGBP: "+gbp+"\nCHF: "+chf);
     
     //if (TradeActive=true)
//double MA1  = iMA(NULL, NULL, 3, 0, MODE_EMA, PRICE_TYPICAL, 0);   
//double MA2  = iMA(NULL, NULL, 5, 0, MODE_EMA, PRICE_TYPICAL, 0);
//double Mickey_D  = iMACD(NULL, NULL, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
//double l_istoch_400 = iStochastic(NULL, NULL,5,3,3, MODE_EMA, 0, MODE_MAIN, 0);
//double l_istoch_401 = iStochastic(NULL, NULL,14,3,3, MODE_EMA, 0, MODE_MAIN, 0);
//double rsi = iRSI(NULL,PERIOD_D1, 2, PRICE_CLOSE, 0);
//double rsi;
//double Gann = iCustom(NULL, NULL, "Gann_SQ9_A6",22.5,22.5,0,2,32,Tomato,DodgerBlue,LightSteelBlue,true,1,0);
//double l_istoch_400;
//double l_istoch_401;
//double l_istoch_400 = iStochastic(perch(Symbol()), NULL,5,3,3, MODE_EMA, 0, MODE_MAIN, 0);
//double l_istoch_401 = iStochastic(perch(Symbol()), NULL,14,3,3, MODE_EMA, 0, MODE_MAIN, 0); 
//double op;
//double hi;
//double lo;
//double MA1;   
//double MA2;
    
     
     if(MathAbs(usd-jpy) > diff_val)
     {
      if (usd > 0 && jpy < 0)
      //if (usd > 0)
      
        {
         Trade("Buy",prefix+"USDJPY"+postfix);
        }
      else if (usd < 0 && jpy > 0)
      //else if (usd < 0)
      
        {
         Trade("Sell",prefix+"USDJPY"+postfix);
        }
     }

   if(MathAbs(usd-cad) > diff_val)
     {
      if (usd > 0 && cad < 0)
      //if (usd > 0)
      
        {
         Trade("Buy",prefix+"USDCAD"+postfix);
        }
      else if (usd < 0 && cad > 0)
      //else if (usd < 0)
      
        {
         Trade("Sell",prefix+"USDCAD"+postfix);
        }
     }

   if(MathAbs(aud-usd)> diff_val)
     {
      if (aud > 0 && usd < 0)
      //if (aud > 0)
      
        {
         Trade("Buy",prefix+"AUDUSD"+postfix);
        }
      else if (aud < 0 && usd > 0)
      //else if (aud < 0)
        {
         Trade("Sell",prefix+"AUDUSD"+postfix);
        }
     }

   if(MathAbs(usd-chf)>diff_val)
     {
      if (usd > 0 && chf < 0)
      //if (usd > 0)
      
        {
         Trade("Buy",prefix+"USDCHF"+postfix);
        }
      else if (usd < 0 && chf > 0)
      //else if (usd < 0)
      
        {
         Trade("Sell",prefix+"USDCHF"+postfix);
        }
     }

   if(MathAbs(gbp-usd)>diff_val)
     {
      if (gbp > 0 && usd < 0)
      //if (gbp > 0)
      
        {
         Trade("Buy",prefix+"GBPUSD"+postfix);
        }
      else if (gbp < 0 && usd > 0)
      //else if (gbp < 0)
      
        {
         Trade("Sell",prefix+"GBPUSD"+postfix);
        }
     }

   if(MathAbs(eur-usd)>diff_val)
     {
      if (eur > 0 && usd < 0)
      //if (eur > 0)
      
        {
         Trade("Buy",prefix+"EURUSD"+postfix);
        }
      else if (eur < 0 && usd > 0)
      //else if (eur < 0)
      
        {
         Trade("Sell",prefix+"EURUSD"+postfix);
        }
     }

   if(MathAbs(nzd-usd)>diff_val)
     {
      if (nzd > 0 && usd < 0)
      //if (nzd > 0)
      
        {
         Trade("Buy",prefix+"NZDUSD"+postfix);
        }
      else if (nzd < 0 && usd > 0)
      //else if (nzd < 0)
      
        {
         Trade("Sell",prefix+"NZDUSD"+postfix);
        }
     }

   if(MathAbs(eur-jpy)>diff_val)
     {
      if (eur > 0 && jpy < 0)
      //if (eur > 0)
      
        {
         Trade("Buy",prefix+"EURJPY"+postfix);
        }
      else if (eur < 0 && jpy > 0)
      //else if (eur < 0)
      
        {
         Trade("Sell",prefix+"EURJPY"+postfix);
        }
     }

   if(MathAbs(eur-cad)>diff_val)
     {
      if (eur > 0 && cad < 0)
      //if (eur > 0)
      
        {
         Trade("Buy",prefix+"EURCAD"+postfix);
        }
      else if (eur < 0 && cad > 0)
      //else if (eur < 0)
      
        {
         Trade("Sell",prefix+"EURCAD"+postfix);
        }
     }

   if(MathAbs(eur-gbp)>diff_val)
     {
      if (eur > 0 && gbp < 0)
      //if (eur > 0)
      
        {
         Trade("Buy",prefix+"EURGBP"+postfix);
        }
      else if (eur < 0 && gbp > 0)
      //else if (eur < 0)
      
        {
         Trade("Sell",prefix+"EURGBP"+postfix);
        }
     }

   if(MathAbs(eur-chf)>diff_val)
     {
      if (eur > 0 && chf < 0)
      //if (eur > 0)
      
        {
         Trade("Buy",prefix+"EURCHF"+postfix);
        }
      else if (eur < 0 && chf > 0)
      //else if (eur < 0)
      
        {
         Trade("Sell",prefix+"EURCHF"+postfix);
        }
     }

   if(MathAbs(eur-aud)>diff_val)
     {
      if (eur > 0 && aud < 0)
      //if (eur > 0)
      
        {
         Trade("Buy",prefix+"EURAUD"+postfix);
        }
      else if (eur < 0 && aud > 0)
      //else if (eur < 0)
      
        {
         Trade("Sell",prefix+"EURAUD"+postfix);
        }
     }

   if(MathAbs(eur-nzd)>diff_val)
     {
      if (eur > 0 && nzd < 0)
      //if (eur > 0)
      
        {
         Trade("Buy",prefix+"EURNZD"+postfix);
        }
      else if (eur < 0 && nzd > 0)
      //else if (eur < 0) 
      
        {
         Trade("Sell",prefix+"EURNZD"+postfix);
        }
     }

   if(MathAbs(aud-nzd)>diff_val)
     {
      if (aud > 0 && nzd < 0)
      //if (aud > 0)
     
        {
         Trade("Buy",prefix+"AUDNZD"+postfix);
        }
      else if (aud < 0 && nzd > 0)
      //else if (aud < 0)
     
        {
         Trade("Sell",prefix+"AUDNZD"+postfix);
        }
     }

   if(MathAbs(aud-cad)>diff_val)
     {
      if (aud > 0 && cad < 0)
      //if (aud > 0)
      
        {
         Trade("Buy",prefix+"AUDCAD"+postfix);
        }
      else if (aud < 0 && cad > 0)
      //else if (aud < 0)
     
        {
         Trade("Sell",prefix+"AUDCAD"+postfix);
        }
     }

   if(MathAbs(aud-chf)>diff_val)
     {
      if (aud > 0 && chf < 0)
      //if (aud > 0)
      
        {
         Trade("Buy",prefix+"AUDCHF"+postfix);
        }
      else if (aud < 0 && chf > 0)
      //else if (aud < 0)
      
        {
         Trade("Sell",prefix+"AUDCHF"+postfix);
        }
     }

   if(MathAbs(aud-jpy)>diff_val)
     {
      if (aud > 0 && jpy < 0)
      //if (aud > 0)
      
        {
         Trade("Buy",prefix+"AUDJPY"+postfix);
        }
      else if (aud < 0 && jpy > 0)
      //else if (aud < 0)
      
        {
         Trade("Sell",prefix+"AUDJPY"+postfix);
        }
     }

   if(MathAbs(chf-jpy)>diff_val)
     {
      if (chf > 0 && jpy < 0)
      //if (chf > 0)
     
        {
         Trade("Buy",prefix+"CHFJPY"+postfix);
        }
      else if (chf < 0 && jpy > 0)
      //else if (chf < 0)
      
        {
         Trade("Sell",prefix+"CHFJPY"+postfix);
        }
     }

   if(MathAbs(gbp-chf)>diff_val)
     {
      if (gbp > 0 && chf < 0)
      //if (gbp > 0)
      
        {
         Trade("Buy",prefix+"GBPCHF"+postfix);
        }
      else if (gbp < 0 && chf > 0)
      //else if (gbp < 0)
      
        {
         Trade("Sell",prefix+"GBPCHF"+postfix);
        }
     }

   if(MathAbs(gbp-aud)>diff_val)
     {
      if (gbp > 0 && aud < 0)
      //if (gbp > 0)
      
        {
         Trade("Buy",prefix+"GBPAUD"+postfix);
        }
      else if (gbp < 0 && aud > 0)
      //else if (gbp < 0)
      
        {
         Trade("Sell",prefix+"GBPAUD"+postfix);
        }
     }

   if(MathAbs(gbp-cad)>diff_val)
     {
      if (gbp > 0 && cad < 0)
      //if (gbp > 0)
      
        {
         Trade("Buy",prefix+"GBPCAD"+postfix);
        }
      else if (gbp < 0 && cad > 0)
      //else if (gbp < 0)
      
        {
         Trade("Sell",prefix+"GBPCAD"+postfix);
        }
     }

   if(MathAbs(gbp-jpy)>diff_val)
     {
      if (gbp > 0 && jpy < 0)
      //if (gbp > 0)
      
        {
         Trade("Buy",prefix+"GBPJPY"+postfix);
        }
      else if (gbp < 0 && jpy > 0)
      //else if (gbp < 0)
      
        {
         Trade("Sell",prefix+"GBPJPY"+postfix);
        }
     }

   if(MathAbs(cad-jpy)>diff_val)
     {
      if (cad > 0 && jpy < 0)
      //if (cad > 0)
      
        {
         Trade("Buy",prefix+"CADJPY"+postfix);
        }
      else if (cad < 0 && jpy > 0)
      //else if (cad < 0)
      
        {
         Trade("Sell",prefix+"CADJPY"+postfix);
        }
     }

   if(MathAbs(nzd-jpy)>diff_val)
     {
      if (nzd > 0 && jpy < 0)
      //if (nzd > 0)
        {
         Trade("Buy",prefix+"NZDJPY"+postfix);
        }
      else if (nzd < 0 && jpy > 0)
      //else if (nzd < 0)
      
        {
         Trade("Sell",prefix+"NZDJPY"+postfix);
        }
     }

   if(MathAbs(gbp-nzd)>diff_val)
     {
      //if(MathAbs(gbp<nzd))
      if (gbp > 0 && nzd < 0)
      //if (gbp > 0)
      
        {
         Trade("Buy",prefix+"GBPNZD"+postfix);
        }
      else if (gbp < 0 && nzd > 0)
      //else if (gbp < 0)
        {
         Trade("Sell",prefix+"GBPNZD"+postfix);
        }
     }

   if(MathAbs(cad-chf)>diff_val)
     {
      if (cad > 0 && chf < 0)
      //if (cad > 0)
      
        {
         Trade("Buy",prefix+"CADCHF"+postfix);
        }
      else if (cad < 0 && chf > 0)
      //else if (cad < 0)  
      
        {
         Trade("Sell",prefix+"CADCHF"+postfix);
        }
     }
   return(0);
   
  }
  
//+------------------------------------------------------------------+
//|            CALCULATING PERCENTAGE Of SYMBOLS        |
//+------------------------------------------------------------------+

/*double MA1  = iMA(Symbol(), NULL, 3, 0, MODE_EMA, PRICE_TYPICAL, 0);   
double MA2  = iMA(Symbol(), NULL, 5, 0, MODE_EMA, PRICE_TYPICAL, 0);
double Mickey_D  = iMACD(Symbol(), 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);*/
//double l_istoch_400;
//double l_istoch_401; 


double perch(string sym)

  { 
   //double per = (MarketInfo(sym, MODE_HIGH) - MarketInfo(sym, MODE_LOW)) * MarketInfo(sym, MODE_POINT);
   //double per = 100.0 * ((MarketInfo(sym, MODE_BID) - MarketInfo(sym, MODE_ASK)) / per * MarketInfo(sym, MODE_POINT));
   double op = iOpen(sym,calc_per,0);
   double cl = iClose(sym,calc_per,0);
   //double l_istoch_400 = iStochastic(sym, NULL,5,3,3, MODE_EMA, 0, MODE_MAIN, 0);
   //double l_istoch_401 = iStochastic(sym, NULL,14,3,3, MODE_EMA, 0, MODE_MAIN, 0);
   //double rsi = iRSI(sym,PERIOD_H1, 2, PRICE_CLOSE, 0);
   //double op = iOpen(sym,PERIOD_D1,0); 
   //double hi = iHigh(sym,PERIOD_D1,0);
   //double lo = iLow(sym,PERIOD_D1,0);
   //double MA1  = iMA(NULL, NULL, 3, 0, MODE_EMA, PRICE_TYPICAL, 0);   
   //double MA2  = iMA(NULL, NULL, 5, 0, MODE_EMA, PRICE_TYPICAL, 0);
   //per = 100.0 * ((MarketInfo(sym, MODE_BID) - MarketInfo(sym, MODE_LOW)) * MarketInfo(sym, MODE_POINT));
   double per=(cl-op)/op*1000;
   if (per == 0) return(0);
   if (per !=0)
   //per = 100.0 * ((MarketInfo(sym, MODE_BID) - MarketInfo(sym, MODE_ASK)) / per * MarketInfo(sym, MODE_POINT));
   //per = 100.0 * ((MarketInfo(sym, MODE_BID) - MarketInfo(sym, MODE_LOW)) / per * MarketInfo(sym, MODE_POINT));
   per=NormalizeDouble(per,2);
   return(per);
   //double Sym = sym;
   //return(Sym);
      
}


  
//+------------------------------------------------------------------+
//|                                                                                   |
//|               TRADE EXECUTION FUNCTION                      |
//+------------------------------------------------------------------+

double Sym;
double sym = Sym;
//double perch = Sym;
double rsi = iRSI(Sym,calc_per, 2, PRICE_CLOSE, 0);
//int Trade(string signal,string sym);
void ClosePositions() {

   for (int l_pos_0 = 0; l_pos_0 <= OrdersTotal(); l_pos_0++) {
      OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES);
      if (UseOrderClose)  
      if (signal=="Sell" && OrderMagicNumber() == Magic) {
         if (OrderType() == OP_BUY) SafeOrderClose(OrderTicket(), OrderLots(), MarketInfo(Sym, MODE_BID), Slippage, Green);
         //if (Obos > OBThreshold && OrderType() == OP_BUY) SafeOrderClose(OrderTicket(), OrderLots(), MarketInfo(g_str_concat_212, MODE_BID), Slippage, Green); 
         else if (signal=="Buy" && OrderMagicNumber() == Magic2)
         if (OrderType() == OP_SELL) SafeOrderClose(OrderTicket(), OrderLots(), MarketInfo(Sym, MODE_ASK), Slippage, Orange);
         //if (Obos < OSThreshold && OrderType() == OP_SELL) SafeOrderClose(OrderTicket(), OrderLots(), MarketInfo(g_str_concat_212, MODE_ASK), Slippage, Salmon);
      }
   }
}

int SafeOrderClose(int a_ticket_0, double a_lots_4, double a_price_12, int a_slippage_20, color a_color_24 = -1) {
   int l_error_28 = 146;
   bool l_ord_close_32 = FALSE;
   for (int l_count_36 = 0; l_count_36 < 2 && l_ord_close_32 == 0; l_count_36++) {
      while (l_error_28 == 146/* TRADE_CONTEXT_BUSY */ && l_ord_close_32 == 0) {
         WaitForContext();
         if (OrderType() == OP_BUY) l_ord_close_32 = OrderClose(a_ticket_0, a_lots_4, a_price_12, a_slippage_20, a_color_24);
         l_error_28 = GetLastError();
         if (OrderType() == OP_SELL) l_ord_close_32 = OrderClose(a_ticket_0, a_lots_4, a_price_12, a_slippage_20, a_color_24);
         l_error_28 = GetLastError();
      }
   }
   return (l_ord_close_32);
}

void WaitForContext() {
   while (IsTradeContextBusy() == TRUE) {
      Sleep(1);
      RefreshRates();
   }
   RefreshRates();
}

int Trade(string signal,string sym)
   
  {
   int count,count2=0;
   //int count=0;
   for(int pos=0; pos<=OrdersTotal(); pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)
         && OrderMagicNumber()==Magic       //When Magic number is correct      
         && OrderSymbol()==sym) // Only When Its of Chart Symbol
        {              // and my pair.
         count++; // Count the number of Positions in Order List Of Chart Symbol
        } //if ended

      else if(OrderSelect(pos,SELECT_BY_POS)
         && OrderMagicNumber()==Magic2
         && OrderSymbol()==sym)
        {              // and my pair.
         count2++; // Count the number of Positions in Order List Of Chart Symbol
         //if ended
     }//for ended
}


   double bid = MarketInfo(sym,MODE_BID);
   double ask = MarketInfo(sym,MODE_ASK);
   double point=MarketInfo(sym,MODE_POINT);
   double digits=MarketInfo(sym,MODE_DIGITS);
   
   //double per= (MarketInfo(sym, MODE_HIGH) - MarketInfo(sym, MODE_LOW)) * MarketInfo(sym, MODE_POINT);

   double op = iOpen(sym,PERIOD_H1,0);
   double cl = iClose(sym,PERIOD_H1,0);
   //double rsi = iRSI(sym,PERIOD_H1, 2, PRICE_CLOSE, 0);
   double sto1 = iStochastic(sym, PERIOD_H1,5,3,3, MODE_EMA, 0, MODE_MAIN, 0);
   double sto2 = iStochastic(sym, PERIOD_H1,14,3,3, MODE_EMA, 0, MODE_MAIN, 0);

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
            if(OrderCloseTime()>YesterdayEnd && OrderSymbol()==sym && OrderMagicNumber()==Magic)
              {
               signal="NoTrade";
              }

            else if(OrderCloseTime()>YesterdayEnd && OrderSymbol()==sym && OrderMagicNumber()==Magic2)
              {
               signal="NoTrade";
              }
           }
        }
     }
   
   if(!count && TradeTime)
   
     {
      if(signal=="Buy" /*&& rsi>71 && sto1>80 && sto2>80*/)
        {
         /*OrderSend(symbol,OP_BUY,TradingLots,ask,0,0,0,"Buy",Magic,0,Green);*/
         OrderSend(sym, OP_BUY, TradingLots, MarketInfo(sym, MODE_ASK), Slippage, MarketInfo(sym, MODE_ASK) - StopLoss * MarketInfo(sym, MODE_POINT), MarketInfo(sym, MODE_ASK) +
         TakeProfit * MarketInfo(sym, MODE_POINT), "Buy", Magic, 0, Blue);
        }
     }

   else if(!count2 && TradeTime)
   //else if(!count && TradeTime)
   
     {
      if(signal=="Sell" /*&& rsi<29 && sto1<20 && sto2<20*/)
        {
         /*OrderSend(symbol,OP_SELL,TradingLots,bid,0,0,0,"Sell",Magic2,0,Red);*/
         OrderSend(sym, OP_SELL, TradingLots, MarketInfo(sym, MODE_BID), 0, MarketInfo(sym, MODE_BID) + StopLoss * MarketInfo(sym, MODE_POINT), MarketInfo(sym, MODE_BID) - TakeProfit * MarketInfo(sym, MODE_POINT), "Sell", Magic2, 0, Red);
         //OrderSend(sym, OP_SELL, TradingLots, MarketInfo(sym, MODE_BID), 0, MarketInfo(sym, MODE_BID) + StopLoss * MarketInfo(sym, MODE_POINT), MarketInfo(sym, MODE_BID) - TakeProfit * MarketInfo(sym, MODE_POINT), "Sell", Magic, 0, Red);
        }
        
     }// If Ended
      
   if(OrdersTotal()>0)
     {
      for(int i=1; i<=OrdersTotal(); i++) // Cycle searching in orders
        {
         if(OrderSelect(i-1,SELECT_BY_POS)==true && OrderSymbol()==sym)
           {
            double tpb=NormalizeDouble(OrderOpenPrice()+TakeProfit*point*10,digits);
            double slb=NormalizeDouble(OrderOpenPrice()-StopLoss*point*10,digits);
            double tps=NormalizeDouble(OrderOpenPrice()-TakeProfit*point*10,digits);
            double sls=NormalizeDouble(OrderOpenPrice()+StopLoss*point*10,digits);

            if(OrderMagicNumber()==Magic && OrderType()==OP_BUY && OrderTakeProfit()==0 && OrderSymbol()==sym)
              {
               OrderModify(OrderTicket(),0,0,tpb,0,CLR_NONE);
               OrderModify(OrderTicket(),0,0,slb,0,CLR_NONE);
               Alert(sym+" TP-Buy: "+tpb, sym+" SL-Buy: "+slb);
              }

            else if(OrderMagicNumber()==Magic2 && OrderType()==OP_SELL && OrderTakeProfit()==0 && OrderSymbol()==sym)
            //else if(OrderMagicNumber()==Magic && OrderType()==OP_SELL && OrderTakeProfit()==0 && OrderSymbol()==sym)
              {
               OrderModify(OrderTicket(),0,0,tps,0,CLR_NONE);
               OrderModify(OrderTicket(),0,0,sls,0,CLR_NONE);
               Alert(sym+" TP-Sell: "+tps, sym+" SL-Sell: "+sls);
              }
             return(0);
            
           }//Nested-if Ended
        }//for loop ended
     }//if Ended
  }

