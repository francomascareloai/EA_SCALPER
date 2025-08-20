//+------------------------------------------------------------------+                                                         |
//|  I can decompile any EA - Email : lpelanjie@gmail.com                                                
//|  Test it and Good luck and happy trading   EURUSD 1M                                 
//+------------------------------------------------------------------+

#property description "EA uses Price action, Hedging, Correlations to predict the future price in forex market and due to many factors that affect the forex market all the time, The parameters values need to be updated once in a year or two so that the EA can adapt to the market new condtions or environment."
#property description "Manual trading requires the trader spend a lot of time in front of the computer screen to monitor the market and all of his or her trades at the same time."
#property description "Also, human manual trading is always affected by emotions like greed and fear. Using an auto trading software will eliminate the chances of the trader's emotions affecting his or her decisions."
#property strict


extern bool Display = TRUE; // Display Parameters
extern bool Hedging = TRUE;
extern int MaxTrades = 10; //MaxOrders
extern bool AutoLots = FALSE; //Auto Lots
extern double Lots = 0.01;
extern bool CheckFreeMargin = TRUE; //Check Free Margin
extern double TakeProfit = 19.0;
extern double Stoploss = 800.0;
extern double PositionsGap = 75.0; //Distance Btwn Orders
extern bool TrailSL = TRUE; //Trailing StopLoss
extern int  TrailPips = 12;  //Trailing Pips
extern int        MagicNumber    = 82379;
extern int        Slippage       = 3;
extern int        SpreadOp       = 55.0;  //Spread Max allowed

int MagicNumber2=MagicNumber-10000;
int MagicNumber3=MagicNumber-20000;

string descriptionM;
bool once = true;

double RangeInPoint=8500;

double OneOverPoint=10000.0;

string ActivationKey=739;

double gd_140;
double gd_148;
double gd_156;
bool gi_164 = TRUE;
bool gi_168 = FALSE;
double gd_172;
double g_ima_180;
double g_ienvelopes_188;
double g_ienvelopes_196;
double g_ienvelopes_204;
double g_ienvelopes_212;
double g_ichimoku_220;
int gi_228 = 1;
bool gi_232 = FALSE;
bool gi_236 = TRUE;
double gd_240 = 1.667;
int g_magic_248;
double g_price_252;
double gd_260;
double gd_unused_268;
double gd_unused_276;
bool gi_unused_284 = FALSE;
double gd_unused_288 = 20.0;
double g_price_296;
double g_bid_304;
double g_ask_312;
double gd_320;
double gd_328;
double gd_344;
double gd_352 = 3.0;
double gd_360;
int gi_368 = 0;
int gi_372 = 0;
bool gi_380;
string gs_384 = "EURUSD M1 Scalper";
int gi_392 = 0;
bool gi_396 = FALSE;
bool gi_400 = FALSE;
bool gi_404 = FALSE;
int gi_unused_408;
int gi_412;
double gd_416;
int g_pos_424 = 0;
int gi_428;
double gd_432 = 0.0;
bool gi_440 = FALSE;
int g_datetime_444 = 0;
int g_datetime_448 = 0;
double point;

int init() {
   gd_344 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   int numDigits=3;
   int DigitsEuro=5;
    
   
   OneOverPoint=(1/Point)/10;
   DigitsEuro=MarketInfo("EURUSD",MODE_DIGITS);
   if(DigitsEuro<=4)     {OneOverPoint=OneOverPoint/10;point=Point/10.0;}
   else                  {OneOverPoint=OneOverPoint;point=Point;}  
      
   return (0);
}

int deinit() {
   return (0);
}

int start() 
{
          
       
          
   int li_0;
   int li_4;
   int li_8;
   bool li_12;
   int l_timeframe_24;
   double l_str2dbl_28;
   double ld_36;
   double ld_44;
   double l_str2dbl_52;
   double l_str2dbl_60;
   double l_str2dbl_68;
   string ls_76;
   string ls_84;
   double ld_unused_92;
   double ld_unused_100;
   int li_unused_108;
   int li_112;
   int li_unused_116;
   double ld_120;
   double l_ord_lots_128;
   double l_ord_lots_136;
   double l_iclose_144;
   double l_iclose_152;
   double ld_160;
   int li_168;
   int li_172;
   
      if(Display)
      {
          ls_84 =   "Hedging            : " + Hedging                      
                  + "\nMax Trades       : " + MaxTrades
                  + "\nAutoLots         : " + AutoLots
                  + "\nLots             : " + Lots
                  + "\nCheckFreeMargin  : " + CheckFreeMargin
                  + "\nTakeProfit       : " + TakeProfit
                  + "\nStoploss         : " + Stoploss
                  + "\nPositionsGap     : " + PositionsGap
                  + "\nTrail StopLoss   : " + TrailSL
                  + "\nTrailPips        : " + TrailPips
                  + "\nMagic Number     : " + MagicNumber
                  + "\nSlippage         : " + Slippage
                  + "\nSpread Operation : " + SpreadOp;        

          Comment(ls_84);
      }
   
      if (MarketInfo(Symbol(), MODE_LOTSTEP) == 0.1) gd_360 = 1;
      else gd_360 = 2;
      li_12 = FALSE;
      li_0 = 7;
      li_4 = 12;
      li_8 = 2009;
     // if (Year() < li_8) li_12 = TRUE;
     // if (Year() == li_8 && Month() < li_4) li_12 = TRUE;
     // if (Year() == li_8 && Month() == li_4 && Day() <= li_0) li_12 = TRUE;
     // if (TRUE) {
     //    if (TRUE) {
            gd_172 = PositionsGap;
            for (int l_pos_16 = 0; l_pos_16 <= OrdersTotal() - 1; l_pos_16++) {
               OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES);
               if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber || OrderMagicNumber() == MagicNumber2) {
                  if (OrderType() == OP_BUY)
                     if (OrderOpenPrice() - Bid > Stoploss / OneOverPoint) OrderClose(OrderTicket(), OrderLots(), Bid, 2, CLR_NONE);
                  if (OrderType() == OP_SELL)
                     if (Ask - OrderOpenPrice() > Stoploss / OneOverPoint) OrderClose(OrderTicket(), OrderLots(), Ask, 2, CLR_NONE);
               }
            }
            if (TrailSL == TRUE) {
               if (CountTradesB() == 1) {
                  for (int l_pos_20 = 0; l_pos_20 <= OrdersTotal() - 1; l_pos_20++) {
                     OrderSelect(l_pos_20, SELECT_BY_POS, MODE_TRADES);
                     if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber || OrderMagicNumber() == MagicNumber3) {
                        if (OrderType() == OP_BUY)
                           if (Bid - OrderOpenPrice() >= TrailPips / OneOverPoint && OrderStopLoss() < Bid - TrailPips / OneOverPoint - 0.0002)
                           if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),Bid - TrailPips / OneOverPoint + 0.0002,Bid - TrailPips / OneOverPoint + 0.0002 + 0.002)) 
                           {
                           if(CheckStopLoss_Takeprofit(OP_BUY,Bid - TrailPips / OneOverPoint + 0.0002,Bid - TrailPips / OneOverPoint + 0.0002 + 0.002))
                           OrderModify(OrderTicket(), OrderOpenPrice(), Bid - TrailPips / OneOverPoint + 0.0002, Bid - TrailPips / OneOverPoint + 0.0002 + 0.002, 0, Yellow);
                           }
                     }
                  }
               }
               if (CountTradesS() == 1) {
                  for (int l_pos_20 = 0; l_pos_20 <= OrdersTotal() - 1; l_pos_20++) {
                     OrderSelect(l_pos_20, SELECT_BY_POS, MODE_TRADES);
                     if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber2 || OrderMagicNumber() == MagicNumber3) {
                        if (OrderType() == OP_SELL)
                           if (OrderOpenPrice() - Ask >= TrailPips / OneOverPoint && OrderStopLoss() > Ask + TrailPips / OneOverPoint - 0.0002)
                           if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),Ask + TrailPips / OneOverPoint - 0.0002,Ask + TrailPips / OneOverPoint - 0.0002 - 0.002))
                           {
                           if(CheckStopLoss_Takeprofit(OP_SELL,Ask + TrailPips / OneOverPoint - 0.0002,Ask + TrailPips / OneOverPoint - 0.0002 - 0.002))
                           OrderModify(OrderTicket(), OrderOpenPrice(), Ask + TrailPips / OneOverPoint - 0.0002, Ask + TrailPips / OneOverPoint - 0.0002 - 0.002, 0, Yellow);
                           }
                     }
                  }
               }
            }
            l_timeframe_24 = Period();
            if (Hedging == TRUE) {
               if (gi_164 == TRUE) g_magic_248 = MagicNumber;
               else g_magic_248 = 12378;
           //  if (l_timeframe_24 == PERIOD_M1 && (StringSubstr(Symbol(), 0, 6) == "EURUSD" || StringSubstr(Symbol(), 0, 6) == "USDJPY")) 
               if(true){
                  if (IsDemo() == TRUE) {
                     l_str2dbl_28 = StrToDouble(ActivationKey);
                     ls_76 = AccountNumber();
                     ld_44 = StringLen(ls_76);
                     l_str2dbl_52 = StrToDouble(StringSubstr(ls_76, 0, 1));
                     l_str2dbl_60 = StrToDouble(StringSubstr(ls_76, 1, 1));
                     l_str2dbl_68 = StrToDouble(StringSubstr(ls_76, ld_44 - 1.0, 1));
                     //ld_36 = AccountNumber() + 739;
                     //ld_36 = ld_36 + 189.0 * l_str2dbl_52 + 204.0 * l_str2dbl_60 + 118.0 * l_str2dbl_68;
                     ld_36=739;
                  } else {
                     l_str2dbl_28 = StrToDouble(ActivationKey);
                     ls_76 = AccountNumber();
                     ld_44 = StringLen(ls_76);
                     l_str2dbl_52 = StrToDouble(StringSubstr(ls_76, 0, 1));
                     l_str2dbl_60 = StrToDouble(StringSubstr(ls_76, 1, 1));
                     l_str2dbl_68 = StrToDouble(StringSubstr(ls_76, ld_44 - 1.0, 1));
                     //ld_36 = AccountNumber() + 839;
                     //ld_36 = ld_36 + 106.0 * l_str2dbl_52 + 278.0 * l_str2dbl_60 + 28.0 * l_str2dbl_68;
                     ld_36=739;
                  }
                  if (True) {
                     ls_84 = "";
                     ls_84 = ls_84 
                     + "\nBroker: " + AccountCompany();
                     if (TRUE) {
                        ls_84 = ls_84 
                        + "\nAccount: " + AccountNumber();
                     } else {
                        ls_84 = ls_84 
                        + "\nAccount: " + AccountNumber();
                     }
                     gi_unused_408 = 0;
                     if (gi_164 == TRUE) {
                        gi_440 = FALSE;
                        if (AccountLeverage() <= 1000) {
                           gd_140 = AccountFreeMargin() / 100.0;
                           gd_148 = MarketInfo(Symbol(), MODE_MARGINREQUIRED) * MarketInfo(Symbol(), MODE_MINLOT);
                           if (AutoLots == TRUE) {
                              Lots = 0;
                              gd_156 = MathFloor(AccountFreeMargin() / (100.0 * gd_148)) * MarketInfo(Symbol(), MODE_MINLOT);
                              if (gd_156 < MarketInfo(Symbol(), MODE_MINLOT)) Lots = MarketInfo(Symbol(), MODE_MINLOT);
                              else Lots = gd_156;
                           }
                           if (gd_148 <= gd_140) gi_unused_408 = 1;
                           else {
                              li_112 = 100.0 * gd_148;
                              ls_84 = ls_84 
                              + "\nFree Margin should be around: " + li_112 + " [atleast]";
                           }
                        } else {
                           Lots = 0;
                           Alert("Account Leverage should be 100 or LESS\nYour Account Leverage is: ", AccountLeverage());
                        }
                     }
                     
                     li_unused_116 = TakeProfit;
                     //Comment(ls_84);
                     if (gi_368 == Time[0]) return (0);
                     gi_368 = Time[0];
                     ld_120 = CalculateProfit();
                     gi_428 = CountTrades();
                     if (gi_428 == 0) gi_380 = FALSE;
                     for (g_pos_424 = OrdersTotal() - 1; g_pos_424 >= 0; g_pos_424--) {
                        OrderSelect(g_pos_424, SELECT_BY_POS, MODE_TRADES);
                        if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_248) continue;
                        if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
                           if (OrderType() == OP_BUY) {
                              gi_400 = TRUE;
                              gi_404 = FALSE;
                              l_ord_lots_128 = OrderLots();
                              break;
                           }
                        }
                        if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
                           if (OrderType() == OP_SELL) {
                              gi_400 = FALSE;
                              gi_404 = TRUE;
                              l_ord_lots_136 = OrderLots();
                              break;
                           }
                        }
                     }
                     if (gi_428 > 0 && gi_428 <= MaxTrades) {
                        RefreshRates();
                        gd_320 = LastBuyPrice();
                        gd_328 = LastSellPrice();
                        if (gi_168 != FALSE) gd_172 = 2.5 * (75 * gi_428);
                        if (gi_400 && gd_320 - Ask >= gd_172 / OneOverPoint) gi_396 = TRUE;
                        if (gi_404 && Bid - gd_328 >= gd_172 / OneOverPoint) gi_396 = TRUE;
                     }
                     if (gi_428 < 1) {
                        gi_404 = FALSE;
                        gi_400 = FALSE;
                        gi_396 = TRUE;
                        gd_260 = AccountEquity();
                     }
                     if (gi_396) {
                        gd_320 = LastBuyPrice();
                        gd_328 = LastSellPrice();
                        if (gi_404) {
                           if (gi_232) {
                              fOrderCloseMarket(0, 1);
                              gd_416 = NormalizeDouble(gd_240 * l_ord_lots_136, gd_360);
                           } else gd_416 = fGetLots(OP_SELL);
                           if (gi_236) {
                              gi_392 = gi_428;
                              if (gd_416 > 0.0) {
                                 RefreshRates();
                                 if (gi_412 < 0) {
                                    Print("Error: ", GetLastError());
                                    return (0);
                                 }
                                 gd_328 = LastSellPrice();
                                 gi_396 = FALSE;
                                 gi_440 = TRUE;
                              }
                           }
                        } else {
                           if (gi_400) {
                              if (gi_232) {
                                 fOrderCloseMarket(1, 0);
                                 gd_416 = NormalizeDouble(gd_240 * l_ord_lots_128, gd_360);
                              } else gd_416 = fGetLots(OP_BUY);
                              if (gi_236) {
                                 gi_392 = gi_428;
                                 if (gd_416 > 0.0) {
                                    gi_412 = OpenPendingOrder(0, gd_416, Ask, gd_352, Bid, 0, 0, gs_384 + "-" + gi_392, g_magic_248, 0, Lime);
                                    if (gi_412 < 0) {
                                       Print("Error: ", GetLastError());
                                       return (0);
                                    }
                                    gd_320 = LastBuyPrice();
                                    gi_396 = FALSE;
                                    gi_440 = TRUE;
                                 }
                              }
                           }
                        }
                     }
                     if (gi_396 && gi_428 < 1) {
                        l_iclose_144 = iClose(Symbol(), 0, 2);
                        l_iclose_152 = iClose(Symbol(), 0, 1);
                        g_bid_304 = Bid;
                        g_ask_312 = Ask;
                        if (!gi_404 && !gi_400) {
                           gi_392 = gi_428;
                           if (l_iclose_144 > l_iclose_152) {
                              gd_416 = fGetLots(OP_SELL);
                              if (gd_416 > 0.0) {
                                 if (gi_412 < 0) {
                                    Print(gd_416, "Error: ", GetLastError());
                                    return (0);
                                 }
                                 gd_320 = LastBuyPrice();
                                 gi_440 = TRUE;
                              }
                           } else {
                              gd_416 = fGetLots(OP_BUY);
                              if (gd_416 > 0.0) {
                                 gi_412 = OpenPendingOrder(0, gd_416, g_ask_312, gd_352, g_ask_312, 0, 0, gs_384 + "-" + gi_392, g_magic_248, 0, Lime);
                                 if (gi_412 < 0) {
                                    Print(gd_416, "Error: ", GetLastError());
                                    return (0);
                                 }
                                 gd_328 = LastSellPrice();
                                 gi_440 = TRUE;
                              }
                           }
                        }
                        gi_396 = FALSE;
                     }
                     gi_428 = CountTrades();
                     g_price_296 = 0;
                     ld_160 = 0;
                     for (g_pos_424 = OrdersTotal() - 1; g_pos_424 >= 0; g_pos_424--) {
                        OrderSelect(g_pos_424, SELECT_BY_POS, MODE_TRADES);
                        if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_248) continue;
                        if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
                           if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
                              g_price_296 += OrderOpenPrice() * OrderLots();
                              ld_160 += OrderLots();
                           }
                        }
                     }
                     if (gi_428 > 0) g_price_296 = NormalizeDouble(g_price_296 / ld_160, Digits);
                     if (gi_440) {
                        for (g_pos_424 = OrdersTotal() - 1; g_pos_424 >= 0; g_pos_424--) {
                           OrderSelect(g_pos_424, SELECT_BY_POS, MODE_TRADES);
                           if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_248) continue;
                           if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
                              if (OrderType() == OP_BUY) {
                                 g_price_252 = g_price_296 + TakeProfit / OneOverPoint;
                                 gd_unused_268 = g_price_252;
                                 gd_432 = g_price_296 - Stoploss * Point;
                                 gi_380 = TRUE;
                              }
                           }
                           if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
                              if (OrderType() == OP_SELL) {
                                 g_price_252 = g_price_296 - TakeProfit / OneOverPoint;
                                 gd_unused_276 = g_price_252;
                                 gd_432 = g_price_296 + Stoploss * Point;
                                 gi_380 = TRUE;
                              }
                           }
                        }
                     }
                     if (gi_440) {
                        if (gi_380 == TRUE) {
                           for (g_pos_424 = OrdersTotal() - 1; g_pos_424 >= 0; g_pos_424--) {
                              OrderSelect(g_pos_424, SELECT_BY_POS, MODE_TRADES);
                              if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_248) continue;
                              if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
                                 if (OrderStopLoss() > 0.0){
                                 //
                                 if(OrderModifyCheck(OrderTicket(),g_price_296,OrderStopLoss(),g_price_252))
                                   {
                                    //Print(" Error 1 From 30");
                                    OrderModify(OrderTicket(), g_price_296, 0, g_price_252, 0, Yellow);
                                    OrderModify(OrderTicket(), g_price_296, OrderStopLoss(), g_price_252, 0, Yellow);
                                    }
                                 }
                                 else 
                               //  
                                 {if(OrderModifyCheck(OrderTicket(),g_price_296,OrderOpenPrice() - Stoploss / OneOverPoint,g_price_252))
                                 {
                                 //Print(" Error 1 From 40");
                                    if(CheckStopLoss_Takeprofit(OP_BUY,OrderOpenPrice() - Stoploss / OneOverPoint,g_price_252))
                                    if(CheckRange(OrderOpenPrice() - Stoploss / OneOverPoint,g_price_252))
                                    OrderModify(OrderTicket(), g_price_296, OrderOpenPrice() - Stoploss / OneOverPoint, g_price_252, 0, Yellow);                             
                                 }
                                 }
                              }
                              gi_440 = FALSE;
                           }
                        }
                     }
                  } else Alert("Please Activate your copy\nof Nemesis Scalper");
               } else {
                  ls_84="Works only on EURUSD 1 Minute Chart but You are trying to use it on "+ Symbol()+ " "+ Period();
                  /*Alert("Works only on EURUSD 1 Minute Chart", 
                  " but You are trying to use it on ", Symbol(), " ", Period()); */
                  if(once){
                  Alert("Works only on EURUSD 1 Minute Chart but You are trying to use it on "+ Symbol()+ " "+ Period()); once =false; }
               }
               if (gi_164 == TRUE) {
                  gi_396 = FALSE;
                  g_magic_248 = MagicNumber2;
               } else g_magic_248 = 12378;
               //if (l_timeframe_24 == PERIOD_M1 && (StringSubstr(Symbol(), 0, 6) == "EURUSD")||(StringSubstr(Symbol(), 0, 6) == "USDJPY")) 
               
               if(true){
                  l_str2dbl_28 = 0;
                  ld_36 = 0;
                  ld_44 = 0;
                  l_str2dbl_52 = 0;
                  l_str2dbl_60 = 0;
                  l_str2dbl_68 = 0;
                  if (IsDemo() == TRUE) {
                     l_str2dbl_28 = StrToDouble(ActivationKey);
                     ls_76 = AccountNumber();
                     ld_44 = StringLen(ls_76);
                     l_str2dbl_52 = StrToDouble(StringSubstr(ls_76, 0, 1));
                     l_str2dbl_60 = StrToDouble(StringSubstr(ls_76, 1, 1));
                     l_str2dbl_68 = StrToDouble(StringSubstr(ls_76, ld_44 - 1.0, 1));
                     //ld_36 = AccountNumber() + 739;
                     //ld_36 = ld_36 + 189.0 * l_str2dbl_52 + 204.0 * l_str2dbl_60 + 118.0 * l_str2dbl_68;
                     ld_36=739;
                  } else {
                     l_str2dbl_28 = StrToDouble(ActivationKey);
                     ls_76 = AccountNumber();
                     ld_44 = StringLen(ls_76);
                     l_str2dbl_52 = StrToDouble(StringSubstr(ls_76, 0, 1));
                     l_str2dbl_60 = StrToDouble(StringSubstr(ls_76, 1, 1));
                     l_str2dbl_68 = StrToDouble(StringSubstr(ls_76, ld_44 - 1.0, 1));
                     //ld_36 = AccountNumber() + 839;
                     //ld_36 = ld_36 + 176.0 * l_str2dbl_52 + 298.0 * l_str2dbl_60 + 328.0 * l_str2dbl_68;
                     ld_36=739;
                  }
                  if (l_str2dbl_28 == ld_36) {
                     ls_84 = "USE ONLY EURUSD M1";
                     ls_84 = ls_84 
                     + "\nBroker: " + AccountCompany();
                     if (IsDemo() == TRUE) {
                        ls_84 = ls_84 
                        + "\nDemo Account: " + AccountNumber();
                     } else {
                        ls_84 = ls_84 
                        + "\nReal Account: " + AccountNumber();
                     }
                     gi_unused_408 = 0;
                     ld_unused_92 = 0;
                     ld_unused_100 = 0;
                     li_unused_108 = 0;
                     if (gi_164 == TRUE) {
                        gi_440 = FALSE;
                        if (AccountLeverage() <= 1000) {
                           gd_140 = AccountFreeMargin() / 100.0;
                           gd_148 = MarketInfo(Symbol(), MODE_MARGINREQUIRED) * MarketInfo(Symbol(), MODE_MINLOT);
                           if (AutoLots == TRUE) {
                              Lots = 0;
                              gd_156 = MathFloor(AccountFreeMargin() / (100.0 * gd_148)) * MarketInfo(Symbol(), MODE_MINLOT);
                              if (gd_156 < MarketInfo(Symbol(), MODE_MINLOT)) Lots = MarketInfo(Symbol(), MODE_MINLOT);
                              else Lots = gd_156;
                           }
                           if (gd_148 <= gd_140) gi_unused_408 = 1;
                           else {
                              li_168 = 100.0 * gd_148;
                              ls_84 = ls_84 
                              + "\nFree Margin should be around: " + li_168 + " [atleast]";
                           }
                        } else {
                           Lots = 0;
                           Alert("Account Leverage should be 100 or LESS\nYour Account Leverage is: ", AccountLeverage());
                        }
                     }
                     li_unused_116 = TakeProfit;
                     Comment(ls_84);
                     if (gi_372 == Time[0]) return (0);
                     gi_372 = Time[0];
                     ld_120 = CalculateProfit();
                     gi_428 = CountTrades();
                     if (gi_428 == 0) gi_380 = FALSE;
                     l_ord_lots_128 = 0;
                     l_ord_lots_136 = 0;
                     for (g_pos_424 = OrdersTotal() - 1; g_pos_424 >= 0; g_pos_424--) {
                        OrderSelect(g_pos_424, SELECT_BY_POS, MODE_TRADES);
                        if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_248) continue;
                        if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
                           if (OrderType() == OP_BUY) {
                              gi_400 = TRUE;
                              gi_404 = FALSE;
                              l_ord_lots_128 = OrderLots();
                              break;
                           }
                        }
                        if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
                           if (OrderType() == OP_SELL) {
                              gi_400 = FALSE;
                              gi_404 = TRUE;
                              l_ord_lots_136 = OrderLots();
                              break;
                           }
                        }
                     }
                     if (gi_428 > 0 && gi_428 <= MaxTrades) {
                        RefreshRates();
                        gd_320 = LastBuyPrice();
                        gd_328 = LastSellPrice();
                        if (gi_168 != FALSE) gd_172 = 2.5 * (75 * gi_428);
                        if (gi_400 && gd_320 - Ask >= gd_172 / OneOverPoint) gi_396 = TRUE;
                        if (gi_404 && Bid - gd_328 >= gd_172 / OneOverPoint) gi_396 = TRUE;
                     }
                     if (gi_428 < 1) {
                        gi_404 = FALSE;
                        gi_400 = FALSE;
                        gi_396 = TRUE;
                        gd_260 = AccountEquity();
                     }
                     if (gi_396) {
                        gd_320 = LastBuyPrice();
                        gd_328 = LastSellPrice();
                        if (gi_404) {
                           if (gi_232) {
                              fOrderCloseMarket(0, 1);
                              gd_416 = NormalizeDouble(gd_240 * l_ord_lots_136, gd_360);
                           } else gd_416 = fGetLots(OP_SELL);
                           if (gi_236) {
                              gi_392 = gi_428;
                              if (gd_416 > 0.0) {
                                 RefreshRates();
                                 gi_412 = OpenPendingOrder(1, gd_416, Bid, gd_352, Ask, 0, 0, gs_384 + "-" + gi_392, g_magic_248, 0, HotPink);
                                 if (gi_412 < 0) {
                                    Print("Error: ", GetLastError());
                                    return (0);
                                 }
                                 gd_328 = LastSellPrice();
                                 gi_396 = FALSE;
                                 gi_440 = TRUE;
                              }
                           }
                        } else {
                           if (gi_400) {
                              if (gi_232) {
                                 fOrderCloseMarket(1, 0);
                                 gd_416 = NormalizeDouble(gd_240 * l_ord_lots_128, gd_360);
                              } else gd_416 = fGetLots(OP_BUY);
                              if (gi_236) {
                                 gi_392 = gi_428;
                                 if (gd_416 > 0.0) {
                                    if (gi_412 < 0) {
                                       Print("Error: ", GetLastError());
                                       return (0);
                                    }
                                    gd_320 = LastBuyPrice();
                                    gi_396 = FALSE;
                                    gi_440 = TRUE;
                                 }
                              }
                           }
                        }
                     }
                     if (gi_396 && gi_428 < 1) {
                        l_iclose_144 = iClose(Symbol(), 0, 2);
                        l_iclose_152 = iClose(Symbol(), 0, 1);
                        g_bid_304 = Bid;
                        g_ask_312 = Ask;
                        if (!gi_404 && !gi_400) {
                           gi_392 = gi_428;
                           if (l_iclose_144 > l_iclose_152) {
                              gd_416 = fGetLots(OP_SELL);
                              if (gd_416 > 0.0) {
                                 gi_412 = OpenPendingOrder(1, gd_416, g_bid_304, gd_352, g_bid_304, 0, 0, gs_384 + "-" + gi_392, g_magic_248, 0, HotPink);
                                 if (gi_412 < 0) {
                                    Print(gd_416, "Error: ", GetLastError());
                                    return (0);
                                 }
                                 gd_320 = LastBuyPrice();
                                 gi_440 = TRUE;
                              }
                           } else {
                              gd_416 = fGetLots(OP_BUY);
                              if (gd_416 > 0.0) {
                                 if (gi_412 < 0) {
                                    Print(gd_416, "Error: ", GetLastError());
                                    return (0);
                                 }
                                 gd_328 = LastSellPrice();
                                 gi_440 = TRUE;
                              }
                           }
                        }
                        gi_396 = FALSE;
                     }
                     gi_428 = CountTrades();
                     g_price_296 = 0;
                     ld_160 = 0;
                     for (g_pos_424 = OrdersTotal() - 1; g_pos_424 >= 0; g_pos_424--) {
                        OrderSelect(g_pos_424, SELECT_BY_POS, MODE_TRADES);
                        if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_248) continue;
                        if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
                           if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
                              g_price_296 += OrderOpenPrice() * OrderLots();
                              ld_160 += OrderLots();
                           }
                        }
                     }
                     if (gi_428 > 0) g_price_296 = NormalizeDouble(g_price_296 / ld_160, Digits);
                     if (gi_440) {
                        for (g_pos_424 = OrdersTotal() - 1; g_pos_424 >= 0; g_pos_424--) {
                           OrderSelect(g_pos_424, SELECT_BY_POS, MODE_TRADES);
                           if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_248) continue;
                           if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
                              if (OrderType() == OP_BUY) {
                                 g_price_252 = g_price_296 + TakeProfit / OneOverPoint;
                                 gd_unused_268 = g_price_252;
                                 gd_432 = g_price_296 - Stoploss * Point;
                                 gi_380 = TRUE;
                              }
                           }
                           if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
                              if (OrderType() == OP_SELL) {
                                 g_price_252 = g_price_296 - TakeProfit / OneOverPoint;
                                 gd_unused_276 = g_price_252;
                                 gd_432 = g_price_296 + Stoploss * Point;
                                 gi_380 = TRUE;
                              }
                           }
                        }
                     }
                     if (gi_440) {
                        if (gi_380 == TRUE) {
                           for (g_pos_424 = OrdersTotal() - 1; g_pos_424 >= 0; g_pos_424--) {
                              OrderSelect(g_pos_424, SELECT_BY_POS, MODE_TRADES);
                              if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_248) continue;
                              if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
                                 if (OrderStopLoss() > 0.0)
                                 {
                            //    
                                       if(OrderModifyCheck(OrderTicket(),g_price_296,OrderStopLoss(),g_price_252)) 
                                       {
                                         OrderModify(OrderTicket(), g_price_296,0, g_price_252, 0, Yellow);
                                         OrderModify(OrderTicket(), g_price_296, OrderStopLoss(), g_price_252, 0, Yellow);
                                       }
                                     //  else
                                 }
                                 else
                                 {
                                 if(OrderModifyCheck(OrderTicket(),g_price_296,OrderOpenPrice() + Stoploss / OneOverPoint,g_price_252)) 
                                 {
                                    if(CheckStopLoss_Takeprofit(OP_SELL,OrderOpenPrice() + Stoploss / OneOverPoint,g_price_252))
                                    if(CheckRange(OrderOpenPrice() + Stoploss / OneOverPoint,g_price_252))
                                    OrderModify(OrderTicket(), g_price_296, OrderOpenPrice() + Stoploss / OneOverPoint, g_price_252, 0, Yellow);
                             
                                 }
                                 }
                              }
                              gi_440 = FALSE;
                           }
                        }
                     }
                  } else Alert("Please Activate your copy\nof Nemesis Scalper");
               } else {
                  ls_84="Works only on EURUSD 1 Minute Chart but You are trying to use it on "+ Symbol()+ " "+ Period();
                  if(once){
                  Alert("Works only on EURUSD 1 Minute Chart"," but You are trying to use it on ", Symbol(), " ", Period()); once=false; }
                  /*Alert("Works only on EURUSD 1 Minute Chart", 
                  " but You are trying to use it on ", Symbol(), " ", Period()); */
               }
            } else {
               if (gi_164 == TRUE) {
                  gi_396 = FALSE;
                  g_magic_248 = MagicNumber3;
               } else g_magic_248 = 12378;
               //if (l_timeframe_24 == PERIOD_M1 && (StringSubstr(Symbol(), 0, 6) == "EURUSD" || StringSubstr(Symbol(), 0, 6) == "USDJPY")) 
               if(true){
                  l_str2dbl_28 = 0;
                  ld_36 = 0;
                  ld_44 = 0;
                  l_str2dbl_52 = 0;
                  l_str2dbl_60 = 0;
                  l_str2dbl_68 = 0;
                  if (IsDemo() == TRUE) {
                     l_str2dbl_28 = StrToDouble(ActivationKey);
                     ls_76 = AccountNumber();
                     ld_44 = StringLen(ls_76);
                     l_str2dbl_52 = StrToDouble(StringSubstr(ls_76, 0, 1));
                     l_str2dbl_60 = StrToDouble(StringSubstr(ls_76, 1, 1));
                     l_str2dbl_68 = StrToDouble(StringSubstr(ls_76, ld_44 - 1.0, 1));
                     //ld_36 = AccountNumber() + 739;
                     //ld_36 = ld_36 + 189.0 * l_str2dbl_52 + 204.0 * l_str2dbl_60 + 118.0 * l_str2dbl_68;
                     ld_36=739;
                  } else {
                     l_str2dbl_28 = StrToDouble(ActivationKey);
                     ls_76 = AccountNumber();
                     ld_44 = StringLen(ls_76);
                     l_str2dbl_52 = StrToDouble(StringSubstr(ls_76, 0, 1));
                     l_str2dbl_60 = StrToDouble(StringSubstr(ls_76, 1, 1));
                     l_str2dbl_68 = StrToDouble(StringSubstr(ls_76, ld_44 - 1.0, 1));
                     //ld_36 = AccountNumber() + 839;
                     //ld_36 = ld_36 + 176.0 * l_str2dbl_52 + 298.0 * l_str2dbl_60 + 328.0 * l_str2dbl_68;
                     ld_36=739;
                  }
                  if (l_str2dbl_28 == ld_36) {
                     ls_84 = "USE ONLY EURUSD M1";
                     ls_84 = ls_84 
                     + "\nBroker: " + AccountCompany();
                     if (IsDemo() == TRUE) {
                        ls_84 = ls_84 
                        + "\nDemo Account: " + AccountNumber();
                     } else {
                        ls_84 = ls_84 
                        + "\nReal Account: " + AccountNumber();
                     }
                     gi_unused_408 = 0;
                     ld_unused_92 = 0;
                     ld_unused_100 = 0;
                     li_unused_108 = 0;
                     if (gi_164 == TRUE) {
                        gi_440 = FALSE;
                        if (AccountLeverage() <= 1000) {
                           gd_140 = AccountFreeMargin() / 100.0;
                           gd_148 = MarketInfo(Symbol(), MODE_MARGINREQUIRED) * MarketInfo(Symbol(), MODE_MINLOT);
                           if (AutoLots == TRUE) {
                              Lots = 0;
                              gd_156 = MathFloor(AccountFreeMargin() / (100.0 * gd_148)) * MarketInfo(Symbol(), MODE_MINLOT);
                              if (gd_156 < MarketInfo(Symbol(), MODE_MINLOT)) Lots = MarketInfo(Symbol(), MODE_MINLOT);
                              else Lots = gd_156;
                           }
                           if (gd_148 <= gd_140) gi_unused_408 = 1;
                           else {
                              li_172 = 100.0 * gd_148;
                              ls_84 = ls_84 
                              + "\nFree Margin should be around: " + li_172 + " [atleast]";
                           }
                        } else {
                           Lots = 0;
                           Alert("Account Leverage should be 100 or LESS\nYour Account Leverage is: ", AccountLeverage());
                        }
                     }
                     li_unused_116 = TakeProfit;
                     Comment(ls_84);
                     if (gi_372 == Time[0]) return (0);
                     gi_372 = Time[0];
                     ld_120 = CalculateProfit();
                     gi_428 = CountTrades();
                     if (gi_428 == 0) gi_380 = FALSE;
                     l_ord_lots_128 = 0;
                     l_ord_lots_136 = 0;
                     for (g_pos_424 = OrdersTotal() - 1; g_pos_424 >= 0; g_pos_424--) {
                        OrderSelect(g_pos_424, SELECT_BY_POS, MODE_TRADES);
                        if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_248) continue;
                        if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
                           if (OrderType() == OP_BUY) {
                              gi_400 = TRUE;
                              gi_404 = FALSE;
                              l_ord_lots_128 = OrderLots();
                              break;
                           }
                        }
                        if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
                           if (OrderType() == OP_SELL) {
                              gi_400 = FALSE;
                              gi_404 = TRUE;
                              l_ord_lots_136 = OrderLots();
                              break;
                           }
                        }
                     }
                     if (gi_428 > 0 && gi_428 <= MaxTrades) {
                        RefreshRates();
                        gd_320 = LastBuyPrice();
                        gd_328 = LastSellPrice();
                        if (gi_168 != FALSE) gd_172 = 2.5 * (75 * gi_428);
                        if (gi_400 && gd_320 - Ask >= gd_172 / OneOverPoint) gi_396 = TRUE;
                        if (gi_404 && Bid - gd_328 >= gd_172 / OneOverPoint) gi_396 = TRUE;
                     }
                     if (gi_428 < 1) {
                        gi_404 = FALSE;
                        gi_400 = FALSE;
                        gi_396 = TRUE;
                        gd_260 = AccountEquity();
                     }
                     if (gi_396) {
                        gd_320 = LastBuyPrice();
                        gd_328 = LastSellPrice();
                        if (gi_404) {
                           if (gi_232) {
                              fOrderCloseMarket(0, 1);
                              gd_416 = NormalizeDouble(gd_240 * l_ord_lots_136, gd_360);
                           } else gd_416 = fGetLots(OP_SELL);
                           if (gi_236) {
                              gi_392 = gi_428;
                              if (gd_416 > 0.0) {
                                 RefreshRates();
                                 gi_412 = OpenPendingOrder(1, gd_416, Bid, gd_352, Ask, 0, 0, gs_384 + "-" + gi_392, g_magic_248, 0, HotPink);
                                 if (gi_412 < 0) {
                                    Print("Error: ", GetLastError());
                                    return (0);
                                 }
                                 gd_328 = LastSellPrice();
                                 gi_396 = FALSE;
                                 gi_440 = TRUE;
                              }
                           }
                        } else {
                           if (gi_400) {
                              if (gi_232) {
                                 fOrderCloseMarket(1, 0);
                                 gd_416 = NormalizeDouble(gd_240 * l_ord_lots_128, gd_360);
                              } else gd_416 = fGetLots(OP_BUY);
                              if (gi_236) {
                                 gi_392 = gi_428;
                                 if (gd_416 > 0.0) {
                                    gi_412 = OpenPendingOrder(0, gd_416, Ask, gd_352, Bid, 0, 0, gs_384 + "-" + gi_392, g_magic_248, 0, Lime);
                                    if (gi_412 < 0) {
                                       Print("Error: ", GetLastError());
                                       return (0);
                                    }
                                    gd_320 = LastBuyPrice();
                                    gi_396 = FALSE;
                                    gi_440 = TRUE;
                                 }
                              }
                           }
                        }
                     }
                     if (gi_396 && gi_428 < 1) {
                        l_iclose_144 = iClose(Symbol(), 0, 2);
                        l_iclose_152 = iClose(Symbol(), 0, 1);
                        g_bid_304 = Bid;
                        g_ask_312 = Ask;
                        if (!gi_404 && !gi_400) {
                           gi_392 = gi_428;
                           if (l_iclose_144 > l_iclose_152) {
                              gd_416 = fGetLots(OP_SELL);
                              if (gd_416 > 0.0) {
                                 gi_412 = OpenPendingOrder(1, gd_416, g_bid_304, gd_352, g_bid_304, 0, 0, gs_384 + "-" + gi_392, g_magic_248, 0, HotPink);
                                 if (gi_412 < 0) {
                                    Print(gd_416, "Error: ", GetLastError());
                                    return (0);
                                 }
                                 gd_320 = LastBuyPrice();
                                 gi_440 = TRUE;
                              }
                           } else {
                              gd_416 = fGetLots(OP_BUY);
                              if (gd_416 > 0.0) {
                                 gi_412 = OpenPendingOrder(0, gd_416, g_ask_312, gd_352, g_ask_312, 0, 0, gs_384 + "-" + gi_392, g_magic_248, 0, Lime);
                                 if (gi_412 < 0) {
                                    Print(gd_416, "Error: ", GetLastError());
                                    return (0);
                                 }
                                 gd_328 = LastSellPrice();
                                 gi_440 = TRUE;
                              }
                           }
                        }
                        gi_396 = FALSE;
                     }
                     gi_428 = CountTrades();
                     g_price_296 = 0;
                     ld_160 = 0;
                     for (g_pos_424 = OrdersTotal() - 1; g_pos_424 >= 0; g_pos_424--) {
                        OrderSelect(g_pos_424, SELECT_BY_POS, MODE_TRADES);
                        if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_248) continue;
                        if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
                           if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
                              g_price_296 += OrderOpenPrice() * OrderLots();
                              ld_160 += OrderLots();
                           }
                        }
                     }
                     if (gi_428 > 0) g_price_296 = NormalizeDouble(g_price_296 / ld_160, Digits);
                     if (gi_440) {
                        for (g_pos_424 = OrdersTotal() - 1; g_pos_424 >= 0; g_pos_424--) {
                           OrderSelect(g_pos_424, SELECT_BY_POS, MODE_TRADES);
                           if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_248) continue;
                           if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
                              if (OrderType() == OP_BUY) {
                                 g_price_252 = g_price_296 + TakeProfit / OneOverPoint;
                                 gd_unused_268 = g_price_252;
                                 gd_432 = g_price_296 - Stoploss * Point;
                                 gi_380 = TRUE;
                              }
                           }
                           if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
                              if (OrderType() == OP_SELL) {
                                 g_price_252 = g_price_296 - TakeProfit / OneOverPoint;
                                 gd_unused_276 = g_price_252;
                                 gd_432 = g_price_296 + Stoploss * Point;
                                 gi_380 = TRUE;
                              }
                           }
                        }
                     }
                     if (gi_440) {
                        if (gi_380 == TRUE) {
                           for (g_pos_424 = OrdersTotal() - 1; g_pos_424 >= 0; g_pos_424--) {
                              OrderSelect(g_pos_424, SELECT_BY_POS, MODE_TRADES);
                              if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_248) continue;
                              if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
                                 if (OrderStopLoss() > 0.0)
                                 if(OrderModifyCheck(OP_BUY,g_price_296,OrderStopLoss(),g_price_252)) 
                                 {//Print(" Error 1 From C");
                                 if(CheckStopLoss_Takeprofit(OP_BUY,OrderStopLoss(),g_price_252))
                                 OrderModify(OrderTicket(), g_price_296, OrderStopLoss(), g_price_252, 0, Yellow);
                                 }
                                 else {
                                    if (OrderType() == OP_SELL)
                                    if(OrderModifyCheck(OrderTicket(),g_price_296,OrderOpenPrice() + Stoploss / OneOverPoint,g_price_252)) 
                                    {//Print(" Error 1 From D");
                                    if(CheckStopLoss_Takeprofit(OP_SELL,OrderOpenPrice() + Stoploss / OneOverPoint,g_price_252))
                                    OrderModify(OrderTicket(), g_price_296, OrderOpenPrice() + Stoploss / OneOverPoint, g_price_252, 0, Yellow);
                                    }
                                    else
                                       if (OrderType() == OP_BUY)
                                       if(OrderModifyCheck(OrderTicket(),g_price_296,OrderOpenPrice() - Stoploss / OneOverPoint,g_price_252)) 
                                      {//Print(" Error 1 From E"); 
                                      OrderModify(OrderTicket(), g_price_296, OrderOpenPrice() - Stoploss / OneOverPoint, g_price_252, 0, Yellow);}
                                 }
                              }
                              gi_440 = FALSE;
                           }
                        }
                     }
                  } else Alert("Please Activate your copy\nof Nemesis Scalper");
               } else {
                  ls_84="Works only on EURUSD 1 Minute Chart but You are trying to use it on "+ Symbol()+ " "+ Period();
                  if(once){
                  Alert("Works only on EURUSD 1 Minute Chart", 
                  " but You are trying to use it on ", Symbol(), " ", Period()); once =false; 
                  }
               }
            }
   //      }
   //   } else Alert("License Expired");
   return (0);
}

double ND(double ad_0) {
   return (NormalizeDouble(ad_0, Digits));
}

int fOrderCloseMarket(bool ai_0 = TRUE, bool ai_4 = TRUE) {
   int li_ret_8 = 0;
   for (int l_pos_12 = OrdersTotal() - 1; l_pos_12 >= 0; l_pos_12--) {
      if (OrderSelect(l_pos_12, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
            if (OrderType() == OP_BUY && ai_0) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), ND(Bid), 5, CLR_NONE)) {
                     Print("Error close BUY " + OrderTicket());
                     li_ret_8 = -1;
                  }
               } else {
                  if (g_datetime_444 != iTime(NULL, 0, 0)) {
                     g_datetime_444 = iTime(NULL, 0, 0);
                     Print("Need close BUY " + OrderTicket() + ". Trade Context Busy");
                  }
                  return (-2);
               }
            }
            if (OrderType() == OP_SELL && ai_4) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), ND(Ask), 5, CLR_NONE)) {
                     Print("Error close SELL " + OrderTicket());
                     li_ret_8 = -1;
                  }
               } else {
                  if (g_datetime_448 != iTime(NULL, 0, 0)) {
                     g_datetime_448 = iTime(NULL, 0, 0);
                     Print("Need close SELL " + OrderTicket() + ". Trade Context Busy");
                  }
                  return (-2);
               }
            }
         }
      }
   }
   return (li_ret_8);
}

double fGetLots(int a_cmd_0) {
   double l_lots_4;
   int l_datetime_16;
   switch (gi_228) {
   case 0:
      l_lots_4 = Lots;
      break;
   case 1:
      l_lots_4 = NormalizeDouble(Lots * MathPow(gd_240, CountTrades()), gd_360);
      break;
   case 2:
      l_datetime_16 = 0;
      l_lots_4 = Lots;
      for (int l_pos_20 = OrdersHistoryTotal() - 1; l_pos_20 >= 0; l_pos_20--) {
         if (OrderSelect(l_pos_20, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248) {
               if (l_datetime_16 < OrderCloseTime()) {
                  l_datetime_16 = OrderCloseTime();
                  if (OrderProfit() < 0.0) l_lots_4 = NormalizeDouble(OrderLots() * gd_240, gd_360);
                  else l_lots_4 = Lots;
               }
            }
         } else return (-3);
      }
   }
   if (AccountFreeMarginCheck(Symbol(), a_cmd_0, l_lots_4) <= 0.0) return (-1);
   if (GetLastError() == 134/* NOT_ENOUGH_MONEY */) return (-2);
   return (l_lots_4);
}

int CountTrades() {
   int l_count_0 = 0;
   for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
      OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_248) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0++;
   }
   return (l_count_0);
}

int CountTradesB() {
   int l_count_0 = 0;
   for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
      OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber || OrderMagicNumber() == MagicNumber3)
         if (OrderType() == OP_BUY) l_count_0++;
   }
   return (l_count_0);
}

int CountTradesS() {
   int l_count_0 = 0;
   for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
      OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber2 || OrderMagicNumber() == MagicNumber3)
         if (OrderType() == OP_SELL) l_count_0++;
   }
   return (l_count_0);
}

int OpenPendingOrder(int ai_0, double a_lots_4, double ad_unused_12, int a_slippage_20, double ad_unused_24, int ai_32, int ai_36, string a_comment_40, int a_magic_48, int a_datetime_52, color a_color_56) {
   a_comment_40="EURUSD M1 Scalper";
   int l_ticket_60 = 0;
   int l_error_64 = 0;
   int l_count_68 = 0;
   int li_72 = 100;
   switch (ai_0) {
   case 0:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         RefreshRates();
         g_ichimoku_220 = iIchimoku(Symbol(), 0, 9, 26, 52, MODE_TENKANSEN, 0);
         g_ima_180 = iMA(Symbol(), 0, 1, 0, MODE_SMA, PRICE_CLOSE, 0);
         g_ienvelopes_196 = iEnvelopes(Symbol(), 0, 99, MODE_EMA, 0, PRICE_CLOSE, 0.08, MODE_LOWER, 1);
         if (Ask < g_ienvelopes_196) {
            if (CountTrades() == 1) {
               g_ienvelopes_212 = iEnvelopes(Symbol(), 0, 99, MODE_EMA, 0, PRICE_CLOSE, 0.15, MODE_LOWER, 1);
               

               
               if (Ask < g_ienvelopes_212) {
               
                      if(CheckMoneyForTrade(Symbol(),a_lots_4,OP_BUY))    
                      if(CheckVolumeValue(a_lots_4,descriptionM))             
                      if(IsNewOrderAllowed())
                 //     if(CheckStopLoss_Takeprofit(OP_BUY,StopLong(Bid, ai_32), TakeLong(Ask, ai_36)))
                  l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, StopLong(Bid, ai_32), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
                  break;
               }
            } else {
                      if(CheckMoneyForTrade(Symbol(),a_lots_4,OP_BUY))    
                      if(CheckVolumeValue(a_lots_4,descriptionM))             
                      if(IsNewOrderAllowed())
                  //    if(CheckStopLoss_Takeprofit(OP_BUY,StopLong(Bid, ai_32), TakeLong(Ask, ai_36)))
               l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, StopLong(Bid, ai_32), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
               break;
            }
            if (CountTrades() == 2) {
               g_ienvelopes_212 = iEnvelopes(Symbol(), 0, 99, MODE_EMA, 0, PRICE_CLOSE, 0.2, MODE_LOWER, 1);
               if (Ask < g_ienvelopes_212) {
                      if(CheckMoneyForTrade(Symbol(),a_lots_4,OP_BUY))    
                      if(CheckVolumeValue(a_lots_4,descriptionM))             
                      if(IsNewOrderAllowed())
                    //  if(CheckStopLoss_Takeprofit(OP_BUY,StopLong(Bid, ai_32), TakeLong(Ask, ai_36)))
                  l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, StopLong(Bid, ai_32), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
                  break;
               }
            } else {
                      if(CheckMoneyForTrade(Symbol(),a_lots_4,OP_BUY))    
                      if(CheckVolumeValue(a_lots_4,descriptionM))             
                      if(IsNewOrderAllowed())
                   //   if(CheckStopLoss_Takeprofit(OP_BUY,StopLong(Bid, ai_32), TakeLong(Ask, ai_36)))
               l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, StopLong(Bid, ai_32), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
               break;
            }
            if (CountTrades() > 2) {
               g_ienvelopes_212 = iEnvelopes(Symbol(), 0, 99, MODE_EMA, 0, PRICE_CLOSE, 0.2, MODE_LOWER, 1);
               if (Ask < g_ienvelopes_212) {
                      if(CheckMoneyForTrade(Symbol(),a_lots_4,OP_BUY))    
                      if(CheckVolumeValue(a_lots_4,descriptionM))             
                      if(IsNewOrderAllowed())
               //       if(CheckStopLoss_Takeprofit(OP_BUY,StopLong(Bid, ai_32), TakeLong(Ask, ai_36)))
                  l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, StopLong(Bid, ai_32), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
                  break;
               }
            } else {
                      if(CheckMoneyForTrade(Symbol(),a_lots_4,OP_BUY))    
                      if(CheckVolumeValue(a_lots_4,descriptionM))             
                      if(IsNewOrderAllowed())
                //      if(CheckStopLoss_Takeprofit(OP_BUY,StopLong(Bid, ai_32), TakeLong(Ask, ai_36)))
               l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, StopLong(Bid, ai_32), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
               break;
            }
         }
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         RefreshRates();
         g_ichimoku_220 = iIchimoku(Symbol(), 0, 9, 26, 52, MODE_TENKANSEN, 0);
         g_ima_180 = iMA(Symbol(), 0, 1, 0, MODE_SMA, PRICE_CLOSE, 0);
         g_ienvelopes_188 = iEnvelopes(Symbol(), 0, 99, MODE_EMA, 0, PRICE_CLOSE, 0.08, MODE_UPPER, 1);
         if (Bid > g_ienvelopes_188) {
            if (CountTrades() == 1) {
               g_ienvelopes_204 = iEnvelopes(Symbol(), 0, 99, MODE_EMA, 0, PRICE_CLOSE, 0.2, MODE_UPPER, 1);
               if (Bid > g_ienvelopes_204) {
                  if (High[0] < High[1] && High[1] < High[2] && High[2] < High[3] && Open[0] < Open[1] && Open[1] < Open[2] && Open[2] < Open[3]) {
                      if(CheckMoneyForTrade(Symbol(),a_lots_4,OP_SELL))    
                      if(CheckVolumeValue(a_lots_4,descriptionM))             
                      if(IsNewOrderAllowed())
                 //     if(CheckStopLoss_Takeprofit(OP_SELL,StopShort(Ask, ai_32), TakeShort(Bid, ai_36)))
                     l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, StopShort(Ask, ai_32), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
                     break;
                  }
               }
            } else {
                      if(CheckMoneyForTrade(Symbol(),a_lots_4,OP_SELL))    
                      if(CheckVolumeValue(a_lots_4,descriptionM))             
                      if(IsNewOrderAllowed())
                //      if(CheckStopLoss_Takeprofit(OP_SELL,StopShort(Ask, ai_32), TakeShort(Bid, ai_36)))
               l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, StopShort(Ask, ai_32), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
               break;
            }
            if (CountTrades() == 2) {
               g_ienvelopes_204 = iEnvelopes(Symbol(), 0, 99, MODE_EMA, 0, PRICE_CLOSE, 0.2, MODE_UPPER, 1);
               if (Bid > g_ienvelopes_204) {
                  if (High[0] < High[1] && High[1] < High[2] && High[2] < High[3] && Open[0] < Open[1] && Open[1] < Open[2] && Open[2] < Open[3]) {
                      if(CheckMoneyForTrade(Symbol(),a_lots_4,OP_SELL))    
                      if(CheckVolumeValue(a_lots_4,descriptionM))             
                      if(IsNewOrderAllowed())
                //      if(CheckStopLoss_Takeprofit(OP_SELL,StopShort(Ask, ai_32), TakeShort(Bid, ai_36)))
                     l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, StopShort(Ask, ai_32), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
                     break;
                  }
               }
            } else {
                      if(CheckMoneyForTrade(Symbol(),a_lots_4,OP_SELL))    
                      if(CheckVolumeValue(a_lots_4,descriptionM))             
                      if(IsNewOrderAllowed())
               //       if(CheckStopLoss_Takeprofit(OP_SELL,StopShort(Ask, ai_32), TakeShort(Bid, ai_36)))
               l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, StopShort(Ask, ai_32), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
               break;
            }
            if (CountTrades() > 2) {
               g_ienvelopes_204 = iEnvelopes(Symbol(), 0, 99, MODE_EMA, 0, PRICE_CLOSE, 0.2, MODE_UPPER, 1);
               if (Bid > g_ienvelopes_204) {
                  if (High[0] < High[1] && High[1] < High[2] && High[2] < High[3] && Open[0] < Open[1] && Open[1] < Open[2] && Open[2] < Open[3]) {
                      if(CheckMoneyForTrade(Symbol(),a_lots_4,OP_SELL))    
                      if(CheckVolumeValue(a_lots_4,descriptionM))             
                      if(IsNewOrderAllowed())
            //          if(CheckStopLoss_Takeprofit(OP_SELL,StopShort(Ask, ai_32), TakeShort(Bid, ai_36)))
                     l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, StopShort(Ask, ai_32), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
                     break;
                  }
               }
            } else {
                      if(CheckMoneyForTrade(Symbol(),a_lots_4,OP_SELL))    
                      if(CheckVolumeValue(a_lots_4,descriptionM))             
                      if(IsNewOrderAllowed())
          //            if(CheckStopLoss_Takeprofit(OP_SELL,StopShort(Ask, ai_32), TakeShort(Bid, ai_36)))
               l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, StopShort(Ask, ai_32), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
               break;
            }
         }
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
   }
   return (l_ticket_60);
}

double StopLong(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}

double StopShort(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}

double TakeLong(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}

double TakeShort(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}

double CalculateProfit() {
   double ld_ret_0 = 0;
   for (g_pos_424 = OrdersTotal() - 1; g_pos_424 >= 0; g_pos_424--) {
      OrderSelect(g_pos_424, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_248) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0 += OrderProfit();
   }
   return (ld_ret_0);
}

double LastBuyPrice() {
   double l_ord_open_price_8;
   int l_ticket_24;
   double ld_unused_0 = 0;
   int l_ticket_20 = 0;
   for (int l_pos_16 = OrdersTotal() - 1; l_pos_16 >= 0; l_pos_16--) {
      OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_248) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248 && OrderType() == OP_BUY) {
         l_ticket_24 = OrderTicket();
         if (l_ticket_24 > l_ticket_20) {
            l_ord_open_price_8 = OrderOpenPrice();
            ld_unused_0 = l_ord_open_price_8;
            l_ticket_20 = l_ticket_24;
         }
      }
   }
   return (l_ord_open_price_8);
}

double LastSellPrice() {
   double l_ord_open_price_8;
   int l_ticket_24;
   double ld_unused_0 = 0;
   int l_ticket_20 = 0;
   for (int l_pos_16 = OrdersTotal() - 1; l_pos_16 >= 0; l_pos_16--) {
      OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_248) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_248 && OrderType() == OP_SELL) {
         l_ticket_24 = OrderTicket();
         if (l_ticket_24 > l_ticket_20) {
            l_ord_open_price_8 = OrderOpenPrice();
            ld_unused_0 = l_ord_open_price_8;
            l_ticket_20 = l_ticket_24;
         }
      }
   }
   return (l_ord_open_price_8);
}


bool CheckMoneyForTrade(string symb, double lots,int type)
  {string descriptionM; double free_margin=0.0;
   if(CheckVolumeValue(lots,descriptionM))
      free_margin=AccountFreeMarginCheck(symb,type, lots);
   else{Print(descriptionM);}
   //-- if there is not enough money
   if(free_margin<2)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("Not enough money for ", oper," ",lots, " ", symb, " Error code=",GetLastError());
      return(false);
     }
   //--- checking successful
   return(true);
  }
  
  //+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio;
   if(volume_step!=0)
   ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                               volume_step,ratio*volume_step);
      return(false);
     }
   description="Correct volume value";
   return(true);
  }
  
 //+------------------------------------------------------------------+
//| Checking the new values of levels before order modification      |
//+------------------------------------------------------------------+
bool OrderModifyCheck(int ticket,double price,double sl,double tp)
  {
//--- select order by ticket
   if(OrderSelect(ticket,SELECT_BY_TICKET))
     {
      //--- point size and name of the symbol, for which a pending order was placed
      string symbol=OrderSymbol();
      double pointO=SymbolInfoDouble(symbol,SYMBOL_POINT);
      //--- check if there are changes in the Open price
      bool PriceOpenChanged=true;
      int type=OrderType();
      if(!(type==OP_BUY || type==OP_SELL))
        {
         PriceOpenChanged=(MathAbs(OrderOpenPrice()-price)>pointO);
        }
      //--- check if there are changes in the StopLoss level
      bool StopLossChanged=(MathAbs(OrderStopLoss()-sl)>pointO);
      //--- check if there are changes in the Takeprofit level
      bool TakeProfitChanged=(MathAbs(OrderTakeProfit()-sl)>tp);
      //--- if there are any changes in levels
      if(PriceOpenChanged || StopLossChanged || TakeProfitChanged)
         return(true);  // order can be modified      
      //--- there are no changes in the Open, StopLoss and Takeprofit levels
      else
      //--- notify about the error
         PrintFormat("Order #%d already has levels of Open=%.5f SL=%.5f TP=%.5f",
                     ticket,OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit());
     }
//--- came to the end, no changes for the order
   return(false);       // no point in modifying 
  } 
  
  //+------------------------------------------------------------------+
//| Check if another order can be placed                             |
//+------------------------------------------------------------------+
bool IsNewOrderAllowed()
  {
//--- get the number of pending orders allowed on the account
   int max_allowed_orders=(int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);

//--- if there is no limitation, return true; you can send an order
   if(max_allowed_orders==0) return(true);

//--- if we passed to this line, then there is a limitation; find out how many orders are already placed
   int orders=OrdersTotal();

//--- return the result of comparing
   return(orders<max_allowed_orders);
  }
  
  
  
 
 bool CheckStopLoss_Takeprofit(ENUM_ORDER_TYPE type,double SL,double TP)
  {
//--- get the SYMBOL_TRADE_STOPS_LEVEL level
   int stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   if(stops_level!=0)
     {
      //PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss and TakeProfit must"+
      //            " not be nearer than %d points from the closing price",stops_level,stops_level);
     }
//---
   bool SL_check=false,TP_check=false;
//--- check only two order types
   switch(type)
     {
      //--- Buy operation
      case  ORDER_TYPE_BUY:
        {
         //--- check the StopLoss
         SL_check=(Bid-SL>stops_level*_Point);
         if(!SL_check);
            //PrintFormat("For order %s StopLoss=%.5f must be less than %.5f"+
            //            " (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)",
            //            EnumToString(type),SL,Bid-stops_level*_Point,Bid,stops_level);
         //--- check the TakeProfit
         TP_check=(TP-Bid>stops_level*_Point);
         if(!TP_check);
            //PrintFormat("For order %s TakeProfit=%.5f must be greater than %.5f"+
            //            " (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)",
            //            EnumToString(type),TP,Bid+stops_level*_Point,Bid,stops_level);
         //--- return the result of checking
         return(SL_check&&TP_check);
        }
      //--- Sell operation
      case  ORDER_TYPE_SELL:
        {
         //--- check the StopLoss
         SL_check=(SL-Ask>stops_level*_Point);
         if(!SL_check);
           // PrintFormat("For order %s StopLoss=%.5f must be greater than %.5f "+
           //             " (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)",
           //             EnumToString(type),SL,Ask+stops_level*_Point,Ask,stops_level);
         //--- check the TakeProfit
         TP_check=(Ask-TP>stops_level*_Point);
         if(!TP_check);
            //PrintFormat("For order %s TakeProfit=%.5f must be less than %.5f "+
            //          " (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)",
            //            EnumToString(type),TP,Ask-stops_level*_Point,Ask,stops_level);
         //--- return the result of checking
         return(TP_check&&SL_check);
        }
      break;
     }
//--- a slightly different function is required for pending orders
   return false;
  }
  
  
bool CheckRange(double SL,double TP)
{

bool SL_check,TP_check;
double max=Ask+RangeInPoint*point;
double min=Bid-RangeInPoint*point;
   
         if(SL==0) SL_check=true;
         if(TP==0) TP_check=true;

         //--- check the StopLoss
         SL_check= (SL<max)&&(SL>min);
         TP_check= (TP<max)&&(TP>min);     

   return (SL_check && TP_check);
}