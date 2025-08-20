//+------------------------------------------------------------------+
//| 110521 1745 ForexGump Forexgain SDL                              |
//| ForexGump                                                        |
//| http://68.71.137.177                                             |
//+------------------------------------------------------------------+

#property copyright "ForexGump"
#property link      "http://68.71.137.177"
#property show_inputs

//---- input parameters
extern string help_lots           = "numero di lotti ordine base";
extern double      lots           =   0.50;
extern string help_spreadLimit    = "limite pip di spread per evitare ordini se troppo alto";
       double      spreadLimit    =   5.00;
extern string help_fixStopLoss    = "pip stop loss FISSO in macchina (0 = nessuno)";
extern double      fixStopLoss    =   0.00;
extern string help_fixTakeProfit  = "pip take profit FISSO in macchina (0 = nessuno)";
extern double      fixTakeProfit  =   0.00;
extern string help_partialTake_1  = "pip take profit parziali e quanti lotti chiudere";
extern string help_partialTake_2  = "false = NON applica take parziali";
extern bool        partialTake    =  true;
extern double      partialTake1   =   7.00;
extern double      partialLots1   =   0.10;
extern double      partialTake2   =  15.00;
extern double      partialLots2   =   0.10;
extern double      partialTake3   =  20.00;
extern double      partialLots3   =   0.10;
extern double      partialTake4   =  25.00;
extern double      partialLots4   =   0.10;
extern double      partialTake5   =  00.00;
extern double      partialLots5   =   0.00;
extern string help_startPips      = "dopo quanti pip di guadagno scatta trailing stop (0 = subito)";
extern double      startPips      =   10.0;
extern string help_trailPips      = "trailing stop in pip (0 = no trailing stop)";
extern double      trailPips      =   20.0;
extern string help_signal         = "--------------------------------------------------";
extern string help_reverse        = "true per aprire gli ordini CONTRARI al TrendSignal";
extern bool        reverse        =  false;
extern string help_closeOther     = "true per chiudere altro ordine quando apre il nuovo";
extern bool        closeOther     =  true;
extern string help_timeframe      = "timeframe da usare, fissarlo oppure 0 = chart aperta";
extern int         timeframe      =   0;
extern string help_signalName     = "nome indicatore nella cartella EXPERTS\INDICATORS";
extern string      signalName     = "Trendsignal (1)";
extern int         RISK           =   3;
extern int         CountBars      = 300;
extern string help_backDays_1     = "quanti giorni disegnare indietro";
extern string help_backDays_2     = "solo per controllare, NON influenza ordini";
extern int         backDays       =  20;
extern color       colorUpTrend   =  Lime;
extern color       colorDnTrend   =  Red;
extern string help_money          = "--------------------------------------------------";
extern string help_ordersTP_1     = "take profit IN SOLDI PER GLI ORDINI APERTI (0 = disattivato)";
extern string help_ordersTP_2     = "quando viene raggiunto CHIUDE TUTTI ORDINI e riparte";
extern double      ordersTP       =   0.00;
extern string help_dailyProfit    = "obiettivo IN SOLDI PER LA GIORNATA (0 = disattivato)";
extern double      dailyProfit    =   0.00;
extern string help_targetMoney_1  = "obiettivo IN SOLDI SUL CONTO (0 = disattivato)";
extern string help_targetMoney_2  = "se EQUITY raggiunge obiettivo chiude TUTTI GLI ORDINI";
extern double      targetMoney    =   0.00;
extern string help_saveMoney_1    = "soldi MINIMI da SALVARE SUL CONTO (0 = disattivato)";
extern string help_saveMoney_2    = "se EQUITY va sotto chiude TUTTI GLI ORDINI";
extern double      saveMoney      =   0.00;
extern string help_moneyTrail     = "trailing stop IN SOLDI SUL CONTO (0 = disattivato)";
extern double      moneyTrail     =   0.00;
extern string help_closePending   = "true = oltre ORDINI APERTI cancella ANCHE PENDENTI";
extern bool        closePending   =  true;

datetime firstStart = 0;
datetime lastOrder  = 0;
double   pip, iBid, iAsk, spread;

int    magic       = 100; string comment     = "";
double openPrice   = 0.0; double minPips     = 0.0;
double stopLoss    = 0.0; double lossPrice   = 0.0;
double takeProfit  = 0.0; double profitPrice = 0.0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
   //----
   print(WindowExpertName() + " starts...");

   // general cleaning to avoid overlaping
   ObjectsDeleteAll();
   HideTestIndicators(true);

   checkPoint(  Symbol ());  // if need pip value

   // draw back days
   if  (timeframe    == 0) timeframe = Period();
   int  shift,  back = MathMin(iBars(NULL, timeframe), backDays*24*60/timeframe);
   // draw past boxes and top trend from older candle to newer because every time need previous values
   for (shift = back; shift >= 0; shift--) trendSignal(shift);

   // do a previous loop to visualize graphics
   // also if market is closed and there aren't ticks
   if (firstStart == 0)
   {
      firstStart = TimeCurrent();
      Alert(WindowExpertName() + " starts at " + TimeToStr(firstStart));
   }
   
   start();

   //----
   return(0);
}

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
   //----
   // to close all opened orders
   //closeAll();

   // better not to print so let last significative message
   //print("...ForexGump stop");
   
   // no delete so user can see graphics
   // also after EA closure
   //ObjectsDeleteAll();

   //----
   return(0);
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
   // START IS EXECUTED EVERY TICK
   Comment("Original strategy by Forexgain DS Trading");

   // money management block control
   // moneyManagement alredy calls checkPoint
   bool                       toTrade;
   if (moneyManagement() < 0) toTrade = false;
   else                       toTrade = true;

   // check also the spread to trade
   if (spreadLimit > 0 && spread > spreadLimit) {toTrade = false; print("Spread too high... orders suspended");}

   // count orders
   double   stopPrice = 0.0;
   int  pos; int totBuys = 0; int totSells = 0;
   for (pos = 0; pos < OrdersTotal(); pos++)
   {
      OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
      if      (OrderSymbol()      != Symbol()) continue;
      else if (OrderMagicNumber() == 110523)
      {
         totBuys  += 1;
         // in the meantime check partial take profit
         if      (!partialTake)                                                                                continue;
         else if ( partialTake5 > 0 && Bid > (OrderOpenPrice()  + partialTake5*pip) &&
                  OrderLots ()  >= (partialLots5))                                                             close(OrderTicket(), partialLots5);
         else if ( partialTake4 > 0 && Bid > (OrderOpenPrice()  + partialTake4*pip) &&
                  OrderLots ()  >= (partialLots5 + partialLots4))                                              close(OrderTicket(), partialLots4);
         else if ( partialTake3 > 0 && Bid > (OrderOpenPrice()  + partialTake3*pip) &&
                  OrderLots ()  >= (partialLots5 + partialLots4 + partialLots3))                               close(OrderTicket(), partialLots3);
         else if ( partialTake2 > 0 && Bid > (OrderOpenPrice()  + partialTake2*pip) &&
                  OrderLots ()  >= (partialLots5 + partialLots4 + partialLots3 + partialLots2))                close(OrderTicket(), partialLots2);
         else if ( partialTake1 > 0 && Bid > (OrderOpenPrice()  + partialTake1*pip) &&
                  OrderLots ()  >= (partialLots5 + partialLots4 + partialLots3 + partialLots2 + partialLots1)) close(OrderTicket(), partialLots1);

         if (trailPips != 0 && Bid > (OrderOpenPrice() + startPips*pip))
         {
            // trail the stop         
            if      (OrderStopLoss() != 0)      stopPrice  = MathMax(Bid - trailPips*pip, OrderStopLoss());
            else                                stopPrice  = MathMax(Bid - trailPips*pip, OrderOpenPrice());
            if      (OrderStopLoss() == 0    && stopPrice  < OrderOpenPrice()) {/* wait to set trailing sl */}
            else if (MathAbs(OrderStopLoss()  - stopPrice) > 1*pip)
                     OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(stopPrice, Digits), 0, 0, Blue);
         }
      }
      else if (OrderMagicNumber() == 110524)   
      {
         totSells += 1;
         if      (!partialTake)                                                                                continue;
         else if ( partialTake5 > 0 && Ask < (OrderOpenPrice()  - partialTake5*pip) &&
                  OrderLots ()  >= (partialLots5))                                                             close(OrderTicket(), partialLots5);
         else if ( partialTake4 > 0 && Ask < (OrderOpenPrice()  - partialTake4*pip) &&
                  OrderLots ()  >= (partialLots5 + partialLots4))                                              close(OrderTicket(), partialLots4);
         else if ( partialTake3 > 0 && Ask < (OrderOpenPrice()  - partialTake3*pip) &&
                  OrderLots ()  >= (partialLots5 + partialLots4 + partialLots3))                               close(OrderTicket(), partialLots3);
         else if ( partialTake2 > 0 && Ask < (OrderOpenPrice()  - partialTake2*pip) &&
                  OrderLots ()  >= (partialLots5 + partialLots4 + partialLots3 + partialLots2))                close(OrderTicket(), partialLots2);
         else if ( partialTake1 > 0 && Ask < (OrderOpenPrice()  - partialTake1*pip) &&
                  OrderLots ()  >= (partialLots5 + partialLots4 + partialLots3 + partialLots2 + partialLots1)) close(OrderTicket(), partialLots1);

         if (trailPips != 0 && Ask < (OrderOpenPrice() - startPips*pip))
         {
            if      (OrderStopLoss() != 0)      stopPrice  = MathMin(Ask + trailPips*pip, OrderStopLoss());
            else                                stopPrice  = MathMin(Ask + trailPips*pip, OrderOpenPrice());
            if      (OrderStopLoss() == 0    && stopPrice  > OrderOpenPrice()) {/* wait... */}
            else if (MathAbs(OrderStopLoss()  - stopPrice) > 1*pip)
                     OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(stopPrice, Digits), 0, 0, Blue);
         }
      }
   }

   int signal = trendSignal(0);
   if (reverse) signal = -signal;

   if      (!toTrade) // || lastOrder == iTime(NULL, timeframe, 0))
   {
      /* not time to trade */
   }
   else if (totBuys == 0 && signal == +1)
   {
      if (closeOther) closeAll();
      magic    = 110523;      comment    = "Forexgain SDL BUY";
      stopLoss = fixStopLoss; takeProfit = fixTakeProfit;
      if (buy(Symbol())  > 0) lastOrder  = iTime(NULL, timeframe, 0);
   }
   else if (totSells == 0 && signal == -1)
   {
      if (closeOther) closeAll();
      magic    = 110524;      comment    = "Forexgain SDL SELL";
      stopLoss = fixStopLoss; takeProfit = fixTakeProfit;
      if (sell(Symbol()) > 0) lastOrder  = iTime(NULL, timeframe, 0);
   }

   //----
   return(0);
}

int trendSignal(int shift = 0)
{
   // call trendSignal (inverted: 1 is up e 2 is down)
   double tSigUp = iCustom(NULL, 0, signalName, RISK, CountBars, 1, shift);
   double tSigDn = iCustom(NULL, 0, signalName, RISK, CountBars, 0, shift);
 
   if (tSigUp != 0)
   {
      string          tSigUpName  = "TrendSignal Up " + TimeToStr(iTime(NULL, 0, shift));
      if (ObjectFind( tSigUpName) < 0)
      {
         ObjectCreate(tSigUpName, OBJ_ARROW, 0, 0, 0);
         ObjectSet(   tSigUpName, OBJPROP_BACK, false);
      }
      ObjectSet(      tSigUpName, OBJPROP_ARROWCODE, 233);
      ObjectSet(      tSigUpName, OBJPROP_COLOR,     DeepSkyBlue);
      ObjectMove(     tSigUpName, 0, iTime(NULL, Period(), shift), tSigUp);

      return(+1);
   }

   if (tSigDn != 0)
   {
      string          tSigDnName  = "TrendSignal Dn " + TimeToStr(iTime(NULL, 0, shift));
      if (ObjectFind( tSigDnName) < 0)
      {
         ObjectCreate(tSigDnName, OBJ_ARROW, 0, 0, 0);
         ObjectSet(   tSigDnName, OBJPROP_BACK, false);
      }
      ObjectSet(      tSigDnName, OBJPROP_ARROWCODE, 234);
      ObjectSet(      tSigDnName, OBJPROP_COLOR,     DeepPink);
      ObjectMove(     tSigDnName, 0, iTime(NULL, Period(), shift), tSigDn + 5*pip);

      return (-1);
   }
   
   return(0);
}

//+------------------------------------------------------------------+
//| general management                                               |
//+------------------------------------------------------------------+
int print(string text, bool flashing = false)
{
   if (ObjectFind( "Check text") < 0)
   {
      ObjectCreate("Check text", OBJ_LABEL,         0, 0, 0);
      // back means it paitns the background
      ObjectSet(   "Check text", OBJPROP_COLOR,     White);
      ObjectSet(   "Check text", OBJPROP_BACK,      false);
      ObjectSet(   "Check text", OBJPROP_CORNER,    0);
      ObjectSet(   "Check text", OBJPROP_XDISTANCE, 300);
      ObjectSet(   "Check text", OBJPROP_YDISTANCE, 50);
   }
   ObjectSetText(  "Check text", TimeToStr(iTime(NULL, PERIOD_M1, 0), TIME_MINUTES) + " " + text, 12, "Tahoma");

   // flashing effect
   if      (flashing && ObjectGet("Check text", OBJPROP_COLOR) == White) ObjectSet("Check text", OBJPROP_COLOR, Red);
   else if (flashing && ObjectGet("Check text", OBJPROP_COLOR) == Red)   ObjectSet("Check text", OBJPROP_COLOR, White);
   else                                                                  ObjectSet("Check text", OBJPROP_COLOR, White);

   // for debugging porpouses uncomment the print
   // to log journal and mt4 file
   //Print(text);

   return(0);
}

int checkPoint(string symbol)
{
   RefreshRates();

   // since working with different currency in same EA
   // pip value could change (eg: JPY Digits)
   double   iPoint =  MarketInfo(symbol, MODE_POINT);
   if      (iPoint == 0.01)    pip = 0.01;
   else if (iPoint == 0.001)   pip = 0.01;
   else if (iPoint == 0.0001)  pip = 0.0001;
   else if (iPoint == 0.00001) pip = 0.0001;

   iBid = MarketInfo(symbol, MODE_BID);
   iAsk = MarketInfo(symbol, MODE_ASK);

   // also in spread compute must considere symbol ask and bid
   spread = NormalizeDouble((iAsk - iBid)/pip, Digits);

   // minPips is the minimum stop/take allowed by broker
   double iDigits =  MarketInfo(symbol, MODE_DIGITS);
   if (   iDigits == 3 || iDigits == 5) minPips = MarketInfo(symbol, MODE_STOPLEVEL)/10;
   else                                 minPips = MarketInfo(symbol, MODE_STOPLEVEL);

   // update spread on che chart only if it's the current Symbol
   if (symbol == Symbol())
   {
      if (ObjectFind( "Spread") < 0)
      {
         ObjectCreate("Spread", OBJ_LABEL, 0, 0, 0);
         ObjectSet(   "Spread", OBJPROP_BACK, false);
         ObjectSet(   "Spread", OBJPROP_CORNER, 3);
         ObjectSet(   "Spread", OBJPROP_XDISTANCE, 10);
         ObjectSet(   "Spread", OBJPROP_YDISTANCE, 10);
      }
      ObjectSetText(  "Spread", Symbol() + " spread " + DoubleToStr(spread, 1) + " pips", 12, "Tahoma", Red);
   }

   return(0);
}

double   moneyStop        = 0.0;
double   yesterTot        = 0.0; int yesterOrd     = 0;
double   yesterTake       = 0.0; int yesterOrdTake = 0;
double   yesterLoss       = 0.0; int yesterOrdLoss = 0;
datetime lastMoneyUpdate  =   0;

int moneyManagement()
{
   checkPoint(Symbol());

   // adjust money stop trailing here so can update the site report
   if (moneyTrail == 0) moneyStop = 0;
   else                 moneyStop = MathMax(moneyStop, AccountEquity() - moneyTrail);
   // printStop to show in report file and on the screen
   double               printStop = MathMax(moneyStop, saveMoney);

   // if case update IIS7 data file
   if (iTime(NULL, PERIOD_M1, 0) != lastMoneyUpdate)
   {
      lastMoneyUpdate = iTime(NULL, PERIOD_M1, 0);

      int handle;
      handle = FileOpen("ForexGump " + AccountNumber() + ".htm", FILE_BIN|FILE_WRITE);

      if(handle < 1)
      {
         Alert(Symbol(), " Error updating account data log file");
      }
      else
      {
         FileWrite(handle, "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">");
         FileWrite(handle, "<html xmlns=\"http://www.w3.org/1999/xhtml\"><head>ForexGump<title></title></head><body>");
         FileWrite(handle, TimeToStr(iTime(NULL, PERIOD_M1, 0), TIME_DATE|TIME_SECONDS), "<br/>");
         FileWrite(handle, "Account ", AccountNumber(), "<br/>");
         FileWrite(handle, AccountName(), "<br/><br/>");

         FileWrite(handle, "Balance ", AccountBalance(), " €<br/>");
         FileWrite(handle, "Equity ", AccountEquity(), " €<br/>");
         FileWrite(handle, "Free margin ", DoubleToStr(AccountFreeMargin(), 2), " €<br/>");
         FileWrite(handle, "Money stop at ", printStop, " €<br/>");

         int pos; double orderTot = 0.0;
         FileWrite(handle, "<br/>Running orders<br/>");
         for (pos = 0; pos < OrdersTotal(); pos++)
         {
            OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
            if (OrderType() == OP_BUY || OrderType() == OP_SELL)
            {
               FileWrite(handle, OrderSymbol(), " ", OrderLots(), " ", OrderComment(), " ", OrderProfit(), " €<br/>");
               orderTot += OrderProfit();
            }
         }
         FileWrite(handle, "<br/>Running tot ", orderTot, " €<br/>");

         FileWrite(handle, "<br/>Waiting orders<br/>");
         for (pos = 0; pos < OrdersTotal(); pos++)
         {
            OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
            if (OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP)
            {
               FileWrite(handle, TimeToStr(OrderOpenTime(), TIME_DATE|TIME_MINUTES), " ", OrderSymbol(), " ", 
                                 OrderLots(), " ", OrderComment(), "<br/>");
            }
         }

         orderTot  = 0.0;           int    orderOrd     = 0;
         int    orderOrdTake = 0;   int    orderOrdLoss = 0;
         double orderTake    = 0.0; double orderLoss    = 0.0;
         FileWrite(handle, "<br/>Today closed<br/>");
         for (pos = 0; pos < OrdersHistoryTotal(); pos++)
         {
            OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY);
            if ((OrderType() == OP_BUY || OrderType() == OP_SELL) &&
                TimeDayOfWeek(OrderCloseTime()) == TimeDayOfWeek(iTime(NULL, PERIOD_M5, 0)))
            {
               FileWrite(handle, OrderSymbol(), " ", OrderLots(), " ", OrderComment(), " ", OrderProfit(), " €<br/>");
               orderTot += OrderProfit(); orderOrd += 1;
               if (OrderProfit() > 0) {orderTake += OrderProfit(); orderOrdTake += 1;}
               if (OrderProfit() < 0) {orderLoss -= OrderProfit(); orderOrdLoss += 1;}
            }
         }
         FileWrite(handle, "<br/>Today tot ", orderOrdTake, " x ", orderTake, " € - ", 
                           orderOrdLoss, " x ", orderLoss, " € = ", orderOrd, " x ", orderTot, " €<br/>");

         // calculate yesterday total only the first time
         // since then it can't change till the next day
         if (yesterTot == 0 || TimeDayOfWeek(iTime(NULL, PERIOD_M5, 0)) != TimeDayOfWeek(iTime(NULL, PERIOD_M5, 1)))
         {
            yesterTot  = 0; yesterOrd     = 0;
            yesterTake = 0; yesterOrdTake = 0;
            yesterLoss = 0; yesterOrdLoss = 0;
            
            for (pos = 0; pos < OrdersHistoryTotal(); pos++)
            {
               OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY);
               if ((OrderType() == OP_BUY || OrderType() == OP_SELL) &&
                   TimeDayOfWeek(OrderCloseTime()) == TimeDayOfWeek(iTime(NULL, PERIOD_M5, 0) - 24*60*60))
               {
                  yesterTot += OrderProfit(); yesterOrd +=1;
                  if (OrderProfit() > 0) {yesterTake += OrderProfit(); yesterOrdTake += 1;}
                  if (OrderProfit() < 0) {yesterLoss -= OrderProfit(); yesterOrdLoss += 1;}
               }
            }
         }
         FileWrite(handle, "Yestd tot ", yesterOrdTake, " x ", yesterTake, " € - ", 
                           yesterOrdLoss, " x ", yesterLoss, " € = ", yesterOrd, " x ", yesterTot, " €<br/>");

         FileWrite(handle, "</body></html>");
         FileClose(handle);
      }
   }

   if (ObjectFind("Account Alarm") < 0)
   {
      ObjectCreate("Account Alarm", OBJ_LABEL, 0, 0, 0);
      ObjectSet(   "Account Alarm", OBJPROP_BACK, false);
      ObjectSet(   "Account Alarm", OBJPROP_CORNER, 2);
      ObjectSet(   "Account Alarm", OBJPROP_XDISTANCE, 10);
      ObjectSet(   "Account Alarm", OBJPROP_YDISTANCE, 10);
   }

   ObjectSetText(  "Account Alarm", "Equity "     + DoubleToStr(AccountEquity(), 2) + 
                                    " € stop at " + DoubleToStr(printStop, 2) + " €", 12, "Tahoma", White);

   if      (printStop/AccountEquity() > 0.95) ObjectSet("Account Alarm", OBJPROP_COLOR, Red);
   else if (printStop/AccountEquity() > 0.80) ObjectSet("Account Alarm", OBJPROP_COLOR, Yellow);
   else                                       ObjectSet("Account Alarm", OBJPROP_COLOR, Lime);

   // check OPEN orders take profit
   if (ordersTP  != 0)
   {
      double openProfit = 0.0;
      for(pos = 0; pos < OrdersTotal(); pos++)
      {
         OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
         openProfit += OrderProfit();
      }

      if (openProfit >= ordersTP)
      {      
         // here must count closing orders because if it closes only some order
         // then next loop the openProfit will be less than take and others will stay open
         int     closingOrders = 1;
         while ( closingOrders > 0)
         {
                 closingOrders = 0;
            for (pos = 0; pos < OrdersTotal(); pos++)
            {
               OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
               // ignore errors because this saveMoney check is repeted every start() round
               if      (OrderType() == OP_BUY)       {closingOrders += 1; OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 0, Red);}
               else if (OrderType() == OP_SELL)      {closingOrders += 1; OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 0, Red);}
               else if (!closePending)               {continue;} // if pending isn't set then stop here and leave pending orders 
               else if (OrderType() == OP_BUYSTOP)   {OrderDelete(OrderTicket());}
               else if (OrderType() == OP_SELLSTOP)  {OrderDelete(OrderTicket());}
               else if (OrderType() == OP_BUYSTOP)   {OrderDelete(OrderTicket());}
               else if (OrderType() == OP_SELLSTOP)  {OrderDelete(OrderTicket());}
               else if (OrderType() == OP_BUYLIMIT)  {OrderDelete(OrderTicket());}
               else if (OrderType() == OP_SELLLIMIT) {OrderDelete(OrderTicket());}
            }
         }

         print("OK !!! ORDERS TAKE PROFIT HIT !!!", true);
         // but here not to block trading must restart after orders closure
         // no return at all to continue the money management testing
      }
   }

   // check daily orders take profit
   if (dailyProfit != 0)
   {
      string today = TimeToStr(TimeCurrent(), TIME_DATE);
      double totProfit = 0.0;
      for(pos = 0; pos < OrdersHistoryTotal(); pos++)
      {
         OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY);
         if (TimeToStr(OrderOpenTime(), TIME_DATE) == today) totProfit += OrderProfit();
      }

      if (totProfit >= dailyProfit)
      {      
         for (pos = 0; pos < OrdersTotal(); pos++)
         {
            OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
            // ignore errors because this saveMoney check is repeted every start() round
            if      (OrderType() == OP_BUY)       OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 0, Red);
            else if (OrderType() == OP_SELL)      OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 0, Red);
            else if (!closePending)               continue; // if pending isn't set then stop here and leave pending orders
            else if (OrderType() == OP_BUYSTOP)   OrderDelete(OrderTicket());
            else if (OrderType() == OP_SELLSTOP)  OrderDelete(OrderTicket());
            else if (OrderType() == OP_BUYSTOP)   OrderDelete(OrderTicket());
            else if (OrderType() == OP_SELLSTOP)  OrderDelete(OrderTicket());
            else if (OrderType() == OP_BUYLIMIT)  OrderDelete(OrderTicket());
            else if (OrderType() == OP_SELLLIMIT) OrderDelete(OrderTicket());
         }

         print("OK !!! DAILY TARGET HIT !!!", true);
         return(-1); 
      }
   }

   // check if parameter errors
   if (targetMoney != 0 && targetMoney <= AccountBalance())
   {
      print("ERROR: targetMoney parameters IS LESS THAN account!!!", true);
      Alert("ERROR: targetMoney parameters IS LESS THAN account!!!");
      return(-1);
   }

   if (targetMoney != 0 && AccountEquity() >= targetMoney)
   {
      for (pos = 0; pos < OrdersTotal(); pos++)
      {
         OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
         // ignore errors because this saveMoney check is repeted every start() round
         if      (OrderType() == OP_BUY)       OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 0, Red);
         else if (OrderType() == OP_SELL)      OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 0, Red);
         else if (!closePending)               continue; // if pending isn't set then stop here and leave pending orders
         else if (OrderType() == OP_BUYSTOP)   OrderDelete(OrderTicket());
         else if (OrderType() == OP_SELLSTOP)  OrderDelete(OrderTicket());
         else if (OrderType() == OP_BUYSTOP)   OrderDelete(OrderTicket());
         else if (OrderType() == OP_SELLSTOP)  OrderDelete(OrderTicket());
         else if (OrderType() == OP_BUYLIMIT)  OrderDelete(OrderTicket());
         else if (OrderType() == OP_SELLLIMIT) OrderDelete(OrderTicket());
      }

      print("OK !!! ACCOUNT TARGET HIT !!!", true);
      return(-1); 
   }

   // above all save money if fixed
   if (saveMoney != 0 && AccountEquity() <= saveMoney)
   {
      // immediatly close ALL orders
      for (pos = 0; pos < OrdersTotal(); pos++)
      {
         OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
         if      (OrderType() == OP_BUY)       OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 0, Red);
         else if (OrderType() == OP_SELL)      OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 0, Red);
         else if (!closePending)               continue; // if pending isn't set then stop here and leave pending orders
         else if (OrderType() == OP_BUYSTOP)   OrderDelete(OrderTicket());
         else if (OrderType() == OP_SELLSTOP)  OrderDelete(OrderTicket());
         else if (OrderType() == OP_BUYSTOP)   OrderDelete(OrderTicket());
         else if (OrderType() == OP_SELLSTOP)  OrderDelete(OrderTicket());
         else if (OrderType() == OP_BUYLIMIT)  OrderDelete(OrderTicket());
         else if (OrderType() == OP_SELLLIMIT) OrderDelete(OrderTicket());
      }

      print("SAVE MONEY STOP: GAME OVER !!!", true);
      return(-1); 
   }

   // check money trailing stop
   if (moneyStop != 0 && AccountEquity() <= moneyStop)
   {
      // find and close all orders to preserve equity
      // included the pending or they could start and be immediatly closed
      for (pos = 0; pos < OrdersTotal(); pos++)
      {
         OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
         // ignore errors because this saveMoney check is repeted every start() round
         if      (OrderType() == OP_BUYSTOP)   OrderDelete(OrderTicket());
         else if (OrderType() == OP_SELLSTOP)  OrderDelete(OrderTicket());
         else if (!closePending)               continue;
         else if (OrderType() == OP_BUYSTOP)   OrderDelete(OrderTicket());
         else if (OrderType() == OP_SELLSTOP)  OrderDelete(OrderTicket());
         else if (OrderType() == OP_BUYSTOP)   OrderDelete(OrderTicket());
         else if (OrderType() == OP_SELLSTOP)  OrderDelete(OrderTicket());
         else if (OrderType() == OP_BUYLIMIT)  OrderDelete(OrderTicket());
         else if (OrderType() == OP_SELLLIMIT) OrderDelete(OrderTicket());
      }

      print("TRAILING MONEY STOP: GAME OVER !!!", true);
      // block any further trading
      return(-1);
   }

   // if too close to moneyStop then suspend new orders
   if (moneyStop != 0 && AccountEquity() <= moneyStop*1.10)
   {
      print("Trading temporarily suspended, too little money...", true);
      return(-1);
   }

   // eventually avoid also to send orders if no enought free margin
   if (MarketInfo(Symbol(), MODE_MARGINREQUIRED)*lots > AccountFreeMargin())
   {
      print("TRADING SUSPENDED: NOT ENOUGHT FREE MARGIN...", true);
      return(-1);
   }

   // in case nothing "happened" before return 0 to allow normal trading
   return(0);
}

//+------------------------------------------------------------------+
//| function to buy                                                  |
//+------------------------------------------------------------------+
string lastBuySymbol = "";
datetime lastBuyTime = 0;
double lastBuyPrice = 0.0;
int lastBuyMagic = 0;

int buy(string symbol, bool force = false)
{
   // with an Ask order we use Bid and in the stop loss the contrary for Bid orders "Bid - stopLoss*pip"
   // but using moving average cross the stop loss is in the code check itself
   checkPoint(symbol);
   double iDigits = MarketInfo(symbol, MODE_DIGITS);
   
   double stop = 0.0;
   if (stopLoss > 0) stop = NormalizeDouble(iBid - stopLoss*pip, iDigits);
   if (lossPrice > 0) stop = NormalizeDouble(lossPrice, iDigits);
   
   double take = 0.0;
   if (takeProfit > 0) take = NormalizeDouble(iAsk + takeProfit*pip, iDigits);
   if (profitPrice > 0) take = NormalizeDouble(profitPrice, iDigits);
   
   double price = NormalizeDouble(iAsk, iDigits);
   if (comment == "") comment = "Buy order by ForexGump";

   // filter to avoid 146 multiple orders error on real account!!
   if (symbol == lastBuySymbol && magic == lastBuyMagic &&
       (TimeCurrent() - lastBuyTime) < 5 && MathAbs(price - lastBuyPrice) < 5*pip)
   {
      print("Blocked " + symbol + " " + comment + " multiple orders");
      lastBuyTime = TimeCurrent();
      return(-1);
   }

   // before check whether identical order is already placed
   int total = OrdersTotal();
   for (int pos = 0; pos < total; pos++)
   {
      if (OrderSelect(pos, SELECT_BY_POS, MODE_TRADES) == false)
      {
         print("OrderSelect error in BUY " + symbol + " #" + GetLastError());
         continue;
      }

      // without magic check we block every other order on the same price
      // or use the parameter "force" to block orders only with same magic
      if (OrderSymbol() == symbol && (!force || OrderMagicNumber() == magic) &&
          (OrderType() == OP_BUY || OrderType() == OP_BUYSTOP) && MathAbs(OrderOpenPrice() - price) < 5*pip)
      {
         print("Blocked " + symbol + " " + comment + " same price orders");
         return(-1);
      }
   }

   int ticket = OrderSend(symbol, OP_BUY, lots, price, 0, stop, take, comment, magic, 0, Green);
   if (ticket < 0) {print("BUY " + symbol + " " + comment + " error #" + GetLastError()); return(-1);}
   else print("BUY " + ticket + " " + symbol + " " + comment + " sent ok");

   // set last sent order params here after positive opening   
   lastBuySymbol = symbol;
   lastBuyTime = TimeCurrent();
   lastBuyPrice = price; lastBuyMagic = magic;
   
   // in every case wait a bit to allow elaborations and avoid overlaping
   // ever if an error occured to avoid to immediatrly resend the order
   Sleep(5000);
   // set orderState in checkPosition because orders could
   // be closed or changed outside of buy() sell() or closeAll()
   return(ticket);
}

string lastBuyStopSymbol = "";
datetime lastBuyStopTime = 0;
double lastBuyStopPrice = 0.0;
int lastBuyStopMagic = 0;

int buyStop(double stopPrice, bool force = false)
{
   checkPoint(Symbol());
   
   double stop = 0.0;
   if (stopLoss > 0) stop = NormalizeDouble(stopPrice - stopLoss*pip, Digits);
   if (lossPrice > 0) stop = NormalizeDouble(lossPrice, Digits);
   
   double take = 0.0;
   if (takeProfit > 0) take = NormalizeDouble(stopPrice + takeProfit*pip, Digits);
   if (profitPrice > 0) take = NormalizeDouble(profitPrice, Digits);

   double price = NormalizeDouble(stopPrice, Digits);
   if (comment == "") comment = "Buy stop order by ForexGump";

   if (Symbol() == lastBuyStopSymbol && magic == lastBuyStopMagic &&
       (TimeCurrent() - lastBuyStopTime) < 5 && MathAbs(price - lastBuyStopPrice) < 5*pip)
   {
      print("Blocked " + Symbol() + " " + comment + " multiple orders");
      lastBuyStopTime = TimeCurrent();
      return(-1);
   }

   // before check whether order is already placed
   int total = OrdersTotal();
   for (int pos = 0; pos < total; pos++)
   {
      if (OrderSelect(pos, SELECT_BY_POS, MODE_TRADES) == false)
      {
         print("OrderSelect error in buyStop #" + GetLastError());
         continue;
      }

      if (OrderSymbol() == Symbol() && (!force || OrderMagicNumber() == magic) &&
          (OrderType() == OP_BUY || OrderType() == OP_BUYSTOP) && MathAbs(OrderOpenPrice() - price) < 10*pip)
      {
         print("Blocked " + Symbol() + " " + comment + " same price orders");
         return(-1);
      }
   }

   int ticket = OrderSend(Symbol(), OP_BUYSTOP, lots, price, 0, stop, take, comment, magic, 0, Green);
   if (ticket < 0) {print("BUY STOP " + Symbol() + " " + comment + " error #" + GetLastError()); return(-1);}
   else print("BUY STOP " + ticket + " " + Symbol() + " " + comment + " sent ok");
   
   lastBuyStopSymbol = Symbol();
   lastBuyStopTime = TimeCurrent();
   lastBuyStopPrice = price; lastBuyStopMagic = magic;

   Sleep(5000);
   return(ticket);
}

//+------------------------------------------------------------------+
//| function to sell                                                 |
//+------------------------------------------------------------------+
string lastSellSymbol = "";
datetime lastSellTime = 0;
double lastSellPrice = 0.0;
int lastSellMagic = 0;

int sell(string symbol, bool force = false)
{
   checkPoint(symbol);
   double iDigits = MarketInfo(symbol, MODE_DIGITS);

   double stop = 0.0;
   if (stopLoss > 0) stop = NormalizeDouble(iAsk + stopLoss*pip, iDigits);
   if (lossPrice > 0) stop = NormalizeDouble(lossPrice, iDigits);
   
   double take = 0.0;
   if (takeProfit > 0) take = NormalizeDouble(iBid - takeProfit*pip, iDigits);
   if (profitPrice > 0) take = NormalizeDouble(profitPrice, iDigits);
   
   double price = NormalizeDouble(iBid, iDigits);
   if (comment == "") comment = "Sell order by ForexGump";

   // filter to avoid multiple orders error on real account!!
   if (symbol == lastSellSymbol && magic == lastSellMagic &&
       (TimeCurrent() - lastSellTime) < 5 && MathAbs(price - lastSellPrice) < 5*pip)
   {
      print("Blocked " + symbol + " " + comment + " multiple orders");
      lastSellTime = TimeCurrent();
      return(-1);
   }
    
   int total = OrdersTotal();
   for (int pos = 0; pos < total; pos++)
   {
      if (OrderSelect(pos, SELECT_BY_POS, MODE_TRADES) == false)
      {
         print("OrderSelect error in SELL " + symbol + " #" + GetLastError());
         continue;
      }

      if (OrderSymbol() == symbol && (!force || OrderMagicNumber() == magic) &&
          (OrderType() == OP_SELL || OrderType() == OP_SELLSTOP) && MathAbs(OrderOpenPrice() - price) < 5*pip)
      {
         print("Blocked " + symbol + " " + comment + " same price orders");
         return(-1);
      }
   }

   int ticket = OrderSend(symbol, OP_SELL, lots, price, 0, stop, take, comment, magic, 0, Red);
   if (ticket < 0) {print("SELL " + symbol + " " + comment + " error #" + GetLastError()); return(-1);}
   else print("SELL " + ticket + " " + symbol + " " + comment + " sent ok");
   
   lastSellSymbol = symbol;
   lastSellTime = TimeCurrent();
   lastSellPrice = price; lastSellMagic = magic;

   Sleep(5000);
   return(ticket);
}

string lastSellStopSymbol = "";
datetime lastSellStopTime = 0;
double lastSellStopPrice = 0.0;
int lastSellStopMagic = 0;

int sellStop(double stopPrice, bool force = false)
{
   checkPoint(Symbol());

   double stop = 0.0;
   if (stopLoss > 0) stop = NormalizeDouble(stopPrice + stopLoss*pip, Digits);
   if (lossPrice > 0) stop = NormalizeDouble(lossPrice, Digits);
   
   double take = 0.0;
   if (takeProfit > 0) take = NormalizeDouble(stopPrice - takeProfit*pip, Digits);
   if (profitPrice > 0) take = NormalizeDouble(profitPrice, Digits);

   double price = NormalizeDouble(stopPrice, Digits);
   if (comment == "") comment = "Sell stop order by ForexGump";

   if (Symbol() == lastSellStopSymbol && magic == lastSellStopMagic &&
       (TimeCurrent() - lastSellStopTime) < 5 && MathAbs(price - lastSellStopPrice) < 5*pip)
   {
      print("Blocked " + Symbol() + " " + comment + " multiple orders");
      lastSellStopTime = TimeCurrent();
      return(-1);
   }

   // before check whether order is already placed
   int total = OrdersTotal();
   for (int pos = 0; pos < total; pos++)
   {
      if (OrderSelect(pos, SELECT_BY_POS, MODE_TRADES) == false)
      {
         print("OrderSelect error in sellStop #" + GetLastError());
         continue;
      }

      if (OrderSymbol() == Symbol() && (!force || OrderMagicNumber() == magic) &&
          (OrderType() == OP_SELL || OrderType() == OP_SELLSTOP) && MathAbs(OrderOpenPrice() - price) < 10*pip)
      {
         print("Blocked " + Symbol() + " " + comment + " same price orders");
         return(-1);
      }
   }
   
   int ticket = OrderSend(Symbol(), OP_SELLSTOP, lots, price, 0, stop, take, comment, magic, 0, Red);
   if (ticket < 0) {print("SELL STOP " + Symbol() + " " + comment + " error #" + GetLastError()); return(-1);}
   else print("SELL STOP " + ticket + " " + Symbol() + " " + comment + " sent ok");
   
   lastSellStopSymbol = Symbol();
   lastSellStopTime = TimeCurrent();
   lastSellStopPrice = price; lastSellStopMagic = magic;

   Sleep(5000);
   return(ticket);
}

//+------------------------------------------------------------------+
//| function to close open positions                                 |
//+------------------------------------------------------------------+

// function to close a specific order
// fast = false waits 5 seconds after the closure to allow broker elaboration
// fast = true to "accelerate" program execution
void close(int ticket, double partialLots, bool fast = false)
{
   checkPoint(Symbol());
   
   if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES) == false)
   {
      print(Symbol() + " OrderSelect error in closing " + ticket + " #" + GetLastError());
   }

   if      (partialLots == 0)           partialLots = OrderLots();
   else if (partialLots >  OrderLots()) partialLots = OrderLots();

   if (OrderType() == OP_BUY)
   {
      if (!OrderClose(OrderTicket(), partialLots, NormalizeDouble(Bid, Digits), 0, Orange))
      {
         print(Symbol() + " error closing BUY order " + ticket + " #" + GetLastError());
      }
      else if (Symbol() == lastBuySymbol) {lastBuySymbol = "";  lastBuyTime = 0;  lastBuyPrice = 0;  lastBuyMagic = 0;}
   }
   else if (OrderType() == OP_SELL)
   {
      if (!OrderClose(OrderTicket(), partialLots, NormalizeDouble(Ask, Digits), 0, Orange))
      {
         print(Symbol() + " error closing SELL order " + ticket + " #" + GetLastError());
      }
      else if (Symbol() == lastSellSymbol) {lastSellSymbol = ""; lastSellTime = 0; lastSellPrice = 0; lastSellMagic = 0;}
   }
   else // then it's a pending STOP or LIMIT order
   {
      if (!OrderDelete(OrderTicket(), Red))
      {
         print(Symbol() + " error deleting PENDNG order " + ticket + " #" + GetLastError());
      }
   }
   
   // also in closing better wait for samo second
   // to allow sending and elaboration
   print(Symbol() + " close order " + ticket + " OK!");
   if (!fast) Sleep(5000);
   return(0);
}

void closeAll()
{
   checkPoint(Symbol());

   int total = OrdersTotal();
   for (int pos = 0; pos < total; pos++)
   {
      if (OrderSelect(pos, SELECT_BY_POS, MODE_TRADES) == false)
      {
         print("OrderSelect error in closeAll #" + GetLastError());
         continue;
      }

      if (OrderSymbol() == Symbol() && OrderMagicNumber() >= 100)
      {
         if (OrderType() == OP_BUY)
         {
            if (!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 0, Orange))
            {
               print("Error closing BUY order #" + GetLastError());
            }
         }
         else if (OrderType() == OP_SELL)
         {
            if (!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 0, Orange))
            {
               print("Error closing SELL order #" + GetLastError());
            }
         }
         else
         {
            // must delete also pending orders if any
            OrderDelete(OrderTicket(), Red);
         }
      }
   }
   
   // also in closing better wait for some seconds
   Sleep(5000);
   return(0);
}

//+------------------------------------------------------------------+

