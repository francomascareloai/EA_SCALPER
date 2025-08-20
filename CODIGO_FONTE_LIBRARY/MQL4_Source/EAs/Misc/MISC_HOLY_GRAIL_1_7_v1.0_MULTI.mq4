/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website: hTtP: // wW W. m etaq uo TES. nE T
   E-mail : S Up p oRT @m et AQuO T E s. N Et
*/

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Crimson
#property indicator_color2 Lime

extern int MAIN_PERIOD = 10;
extern int ADX_PERIOD = 7;
extern int MINBARS = 10000;
extern bool GRAPHICAL_USER_INTERFACE = TRUE;
extern bool SOUND_ALERT = TRUE;
extern bool EMAIL_NOTIFICATION = FALSE;
extern bool SMS_NOTIFICATION = FALSE;
extern double  ArrowDisplacement = 1;
double G_ibuf_104[];
double G_ibuf_108[];
double G_ibuf_112[];
double G_ibuf_116[];
string Gs_120;
string Gs_128;
datetime G_time_136;
int Gi_140 = 0;

// E37F0136AA3FFAF149B351F6A4C948E9
void init() {
   IndicatorBuffers(4);
   SetIndexBuffer(0, G_ibuf_108);
   SetIndexBuffer(1, G_ibuf_104);
   SetIndexBuffer(2, G_ibuf_112);
   SetIndexBuffer(3, G_ibuf_116);
   SetIndexLabel(0, "SELL SIGN");
   SetIndexLabel(1, "BUY SIGN");
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexEmptyValue(2, EMPTY_VALUE);
   SetIndexEmptyValue(3, EMPTY_VALUE);
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, 5);
   SetIndexArrow(0, 218);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 5);
   SetIndexArrow(1, 217);
   G_time_136 = Time[0];
   Gs_120 = "";
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   Gs_120 = "";
   ObjectsDeleteAll();
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
void start() {
   double isar_0;
   double isar_8;
   double Ld_16;
   double iadx_24;
   int Li_32;
   if (Bars > 10)
   {
      Gi_140 = IndicatorCounted();
      if (Gi_140 >= 0)
      {
         if (Gi_140 > 0) Gi_140--;
         Li_32 = MathMin(Bars - Gi_140 - 1, MINBARS);
         if (GRAPHICAL_USER_INTERFACE == FALSE) Gs_120 = "\n\nHOLY GRAIL INDICATOR V1.6\n" + "Copyright \t© 2013 Proximus";
         if (GRAPHICAL_USER_INTERFACE == TRUE)
         {
            Ld_16 = MathAbs(Bid - Ask);
            if (IsDemo() == TRUE) Gs_128 = "DEMO";
            if (IsDemo() == FALSE) Gs_128 = "REAL";
            if (MarketInfo(Symbol(), MODE_DIGITS) == 4.0 || MarketInfo(Symbol(), MODE_DIGITS) == 2.0)
            {
               Gs_120 = "\n\n" + "HOLY GRAIL INDICATOR V1.6\n" + "Copyright \t© 2013 Proximus" 
                  + "\n " 
                  + "\n LEVERAGE:   " + "1:" + AccountLeverage() 
                  + "\n ACCOUNT CURRENCY:   " + AccountCurrency() 
                  + "\n ACCOUNT TYPE:   " + Gs_128 
                  + "\n ------------------------------------------------------ " 
                  + "\n BROKER TIME:   " + TimeToStr(TimeCurrent(), TIME_SECONDS) 
                  + "\n LOCAL TIME:   " + TimeToStr(TimeLocal(), TIME_SECONDS) 
                  + "\n TIME DIFFERENCE:   " + TimeToStr(MathAbs(TimeLocal() - TimeCurrent()), TIME_SECONDS) 
                  + "\n ------------------------------------------------------ " 
                  + "\n ASK:   " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) 
                  + "\n BID:   " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) 
                  + "\n SPREAD:   " + DoubleToStr(Ld_16 / Point, 0) + " pips" 
                  + "\n ------------------------------------------------------ " 
                  + "\n SWAP LONG:   " + DoubleToStr(MarketInfo(Symbol(), MODE_SWAPLONG), MarketInfo(Symbol(), MODE_DIGITS)) 
                  + "\n SWAP SHORT:   " + DoubleToStr(MarketInfo(Symbol(), MODE_SWAPSHORT), MarketInfo(Symbol(), MODE_DIGITS)) 
                  + "\n ------------------------------------------------------ " 
                  + "\n NR. OF ACTIVE ORDERS:   " + OrdersTotal() 
                  + "\n ACCOUNT BALANCE:   " + DoubleToStr(AccountBalance(), 2) 
                  + "\n ACCOUNT EQUITY:   " + DoubleToStr(AccountEquity(), 2) 
                  + "\n FREE MARGIN:   " + DoubleToStr(AccountFreeMargin(), 2) 
                  + "\n USED MARGIN:   " + DoubleToStr(AccountBalance() - AccountFreeMargin(), 2) 
                  + "\n PENDING PROFIT/LOSS:   " + DoubleToStr(AccountProfit(), 2) 
               + "\n ------------------------------------------------------ ";
            }
            if (MarketInfo(Symbol(), MODE_DIGITS) == 5.0 || MarketInfo(Symbol(), MODE_DIGITS) == 3.0) {
               Gs_120 = "\n\n" + "HOLY GRAIL INDICATOR V1.6\n" + "Copyright \t© 2013 Proximus" 
                  + "\n " 
                  + "\n LEVERAGE:   " + "1:" + AccountLeverage() 
                  + "\n ACCOUNT CURRENCY:   " + AccountCurrency() 
                  + "\n ACCOUNT TYPE:   " + Gs_128 
                  + "\n ------------------------------------------------------ " 
                  + "\n BROKER TIME:   " + TimeToStr(TimeCurrent(), TIME_SECONDS) 
                  + "\n LOCAL TIME:   " + TimeToStr(TimeLocal(), TIME_SECONDS) 
                  + "\n TIME DIFFERENCE:   " + TimeToStr(MathAbs(TimeLocal() - TimeCurrent()), TIME_SECONDS) 
                  + "\n ------------------------------------------------------ " 
                  + "\n ASK:   " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) 
                  + "\n BID:   " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) 
                  + "\n SPREAD:   " + DoubleToStr(Ld_16 / Point / 10.0, 1) + " pips" 
                  + "\n ------------------------------------------------------ " 
                  + "\n SWAP LONG:   " + DoubleToStr(MarketInfo(Symbol(), MODE_SWAPLONG), MarketInfo(Symbol(), MODE_DIGITS)) 
                  + "\n SWAP SHORT:   " + DoubleToStr(MarketInfo(Symbol(), MODE_SWAPSHORT), MarketInfo(Symbol(), MODE_DIGITS)) 
                  + "\n ------------------------------------------------------ " 
                  + "\n NR. OF ACTIVE ORDERS:   " + OrdersTotal() 
                  + "\n ACCOUNT BALANCE:   " + DoubleToStr(AccountBalance(), 2) 
                  + "\n ACCOUNT EQUITY:   " + DoubleToStr(AccountEquity(), 2) 
                  + "\n FREE MARGIN:   " + DoubleToStr(AccountFreeMargin(), 2) 
                  + "\n USED MARGIN:   " + DoubleToStr(AccountBalance() - AccountFreeMargin(), 2) 
                  + "\n PENDING PROFIT/LOSS:   " + DoubleToStr(AccountProfit(), 2) 
               + "\n ------------------------------------------------------ ";
            }
         }
         Comment(Gs_120);
         while (Li_32 >= 0)
         {
            isar_8 = iSAR(Symbol(),0,NormalizeDouble(1/(10*MAIN_PERIOD+0.00001),3),0.5,Li_32+1);
            isar_0 = iSAR(Symbol(),0,NormalizeDouble(1/(10*MAIN_PERIOD+0.00001),3),0.5,Li_32);
            iadx_24 = iADX(Symbol(),0,ADX_PERIOD, PRICE_CLOSE, MODE_MAIN, Li_32);
            if (isar_0 > Close[Li_32] && isar_8 < Close[Li_32 + 1] && iadx_24 > 20.0)
            {
               G_ibuf_108[Li_32] = High[Li_32] + iATR(NULL,0,20,Li_32)*ArrowDisplacement;
               ObjectDelete("BUY");
               ObjectCreate("SELL", OBJ_LABEL, 0, 0, 0);
               ObjectSet("SELL", OBJPROP_CORNER, 1);
               ObjectSet("SELL", OBJPROP_XDISTANCE, 1);
               ObjectSet("SELL", OBJPROP_YDISTANCE, 0);
               ObjectSetText("SELL", "SELL", 32, "Arial Black", Crimson);
               if (Li_32 == 0 && Time[0] > G_time_136)
               {
                  if (Period() < PERIOD_H1)   Alert("SELL SIGN: " + Symbol() + "  |  TIMEFRAME: M" + Period() + "  |  PRICE(BID): " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                  if (Period() == PERIOD_H1)  Alert("SELL SIGN: " + Symbol() + "  |  TIMEFRAME: H1  |  PRICE(BID): " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                  if (Period() == PERIOD_H4)  Alert("SELL SIGN: " + Symbol() + "  |  TIMEFRAME: H4  |  PRICE(BID): " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                  if (Period() == PERIOD_D1)  Alert("SELL SIGN: " + Symbol() + "  |  TIMEFRAME: D1  |  PRICE(BID): " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                  if (Period() == PERIOD_W1)  Alert("SELL SIGN: " + Symbol() + "  |  TIMEFRAME: W1  |  PRICE(BID): " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                  if (Period() == PERIOD_MN1) Alert("SELL SIGN: " + Symbol() + "  |  TIMEFRAME: MN  |  PRICE(BID): " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                  if (EMAIL_NOTIFICATION == TRUE)
                  {
                     if (Period() < PERIOD_H1)
                     {
                        SendMail("MT4 SELL TRADE SIGN!", "SELL SIGN: " + Symbol() + "  |  TIMEFRAME: M" + Period() + "  |  PRICE(BID): " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) +
                           " ");
                     }
                     if (Period() == PERIOD_H1) SendMail("MT4 SELL TRADE SIGN!", "SELL SIGN: " + Symbol() + "  |  TIMEFRAME: H1  |  PRICE(BID): " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                     if (Period() == PERIOD_H4) SendMail("MT4 SELL TRADE SIGN!", "SELL SIGN: " + Symbol() + "  |  TIMEFRAME: H4  |  PRICE(BID): " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                     if (Period() == PERIOD_D1) SendMail("MT4 SELL TRADE SIGN!", "SELL SIGN: " + Symbol() + "  |  TIMEFRAME: D1  |  PRICE(BID): " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                     if (Period() == PERIOD_W1) SendMail("MT4 SELL TRADE SIGN!", "SELL SIGN: " + Symbol() + "  |  TIMEFRAME: W1  |  PRICE(BID): " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                     if (Period() == PERIOD_MN1) SendMail("MT4 SELL TRADE SIGN!", "SELL SIGN: " + Symbol() + "  |  TIMEFRAME: MN  |  PRICE(BID): " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                  }
                  if (SMS_NOTIFICATION == TRUE) {
                     if (Period() < PERIOD_H1) SendNotification("SELL SIGN: " + Symbol() + "  |  TIMEFRAME: M" + Period() + "  |  PRICE(BID): " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                     if (Period() == PERIOD_H1) SendNotification("SELL SIGN: " + Symbol() + "  |  TIMEFRAME: H1  |  PRICE(BID): " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                     if (Period() == PERIOD_H4) SendNotification("SELL SIGN: " + Symbol() + "  |  TIMEFRAME: H4  |  PRICE(BID): " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                     if (Period() == PERIOD_D1) SendNotification("SELL SIGN: " + Symbol() + "  |  TIMEFRAME: D1  |  PRICE(BID): " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                     if (Period() == PERIOD_W1) SendNotification("SELL SIGN: " + Symbol() + "  |  TIMEFRAME: W1  |  PRICE(BID): " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                     if (Period() == PERIOD_MN1) SendNotification("SELL SIGN: " + Symbol() + "  |  TIMEFRAME: MN  |  PRICE(BID): " + DoubleToStr(Bid, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                  }
                  if (SOUND_ALERT == TRUE) PlaySound("alert.wav");
               }
               G_time_136 = Time[0];
            }
            if (isar_0 < Close[Li_32] && isar_8 > Close[Li_32 + 1] && iadx_24 > 20.0) {
               G_ibuf_104[Li_32] = Low[Li_32] - iATR(NULL,0,20,Li_32)*ArrowDisplacement;
               ObjectDelete("SELL");
               ObjectCreate("BUY", OBJ_LABEL, 0, 0, 0);
               ObjectSet("BUY", OBJPROP_CORNER, 1);
               ObjectSet("BUY", OBJPROP_XDISTANCE, 1);
               ObjectSet("BUY", OBJPROP_YDISTANCE, 0);
               ObjectSetText("BUY", "BUY", 32, "Arial Black", Lime);
               if (Li_32 == 0 && Time[0] > G_time_136) {
                  if (Period() < PERIOD_H1) Alert("BUY SIGN: " + Symbol() + "  |  TIMEFRAME: M" + Period() + "  |  PRICE(ASK): " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                  if (Period() == PERIOD_H1) Alert("BUY SIGN: " + Symbol() + "  |  TIMEFRAME: H1  |  PRICE(ASK): " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                  if (Period() == PERIOD_H4) Alert("BUY SIGN: " + Symbol() + "  |  TIMEFRAME: H4  |  PRICE(ASK): " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                  if (Period() == PERIOD_D1) Alert("BUY SIGN: " + Symbol() + "  |  TIMEFRAME: D1  |  PRICE(ASK): " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                  if (Period() == PERIOD_W1) Alert("BUY SIGN: " + Symbol() + "  |  TIMEFRAME: W1  |  PRICE(ASK): " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                  if (Period() == PERIOD_MN1) Alert("BUY SIGN: " + Symbol() + "  |  TIMEFRAME: MN  |  PRICE(ASK): " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                  if (EMAIL_NOTIFICATION == TRUE) {
                     if (Period() < PERIOD_H1) {
                        SendMail("MT4 BUY TRADE SIGN!", "BUY SIGN: " + Symbol() + "  |  TIMEFRAME: M" + Period() + "  |  PRICE(ASK): " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) +
                           " ");
                     }
                     if (Period() == PERIOD_H1) SendMail("MT4 BUY TRADE SIGN!", "BUY SIGN: " + Symbol() + "  |  TIMEFRAME: H1  |  PRICE(ASK): " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                     if (Period() == PERIOD_H4) SendMail("MT4 BUY TRADE SIGN!", "BUY SIGN: " + Symbol() + "  |  TIMEFRAME: H4  |  PRICE(ASK): " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                     if (Period() == PERIOD_D1) SendMail("MT4 BUY TRADE SIGN!", "BUY SIGN: " + Symbol() + "  |  TIMEFRAME: D1  |  PRICE(ASK): " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                     if (Period() == PERIOD_W1) SendMail("MT4 BUY TRADE SIGN!", "BUY SIGN: " + Symbol() + "  |  TIMEFRAME: W1  |  PRICE(ASK): " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                     if (Period() == PERIOD_MN1) SendMail("MT4 BUY TRADE SIGN!", "BUY SIGN: " + Symbol() + "  |  TIMEFRAME: MN  |  PRICE(ASK): " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                  }
                  if (SMS_NOTIFICATION == TRUE) {
                     if (Period() < PERIOD_H1) SendNotification("BUY SIGN: " + Symbol() + "  |  TIMEFRAME: M" + Period() + "  |  PRICE(ASK): " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                     if (Period() == PERIOD_H1) SendNotification("BUY SIGN: " + Symbol() + "  |  TIMEFRAME: H1  |  PRICE(ASK): " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                     if (Period() == PERIOD_H4) SendNotification("BUY SIGN: " + Symbol() + "  |  TIMEFRAME: H4  |  PRICE(ASK): " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                     if (Period() == PERIOD_D1) SendNotification("BUY SIGN: " + Symbol() + "  |  TIMEFRAME: D1  |  PRICE(ASK): " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                     if (Period() == PERIOD_W1) SendNotification("BUY SIGN: " + Symbol() + "  |  TIMEFRAME: W1  |  PRICE(ASK): " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                     if (Period() == PERIOD_MN1) SendNotification("BUY SIGN: " + Symbol() + "  |  TIMEFRAME: MN  |  PRICE(ASK): " + DoubleToStr(Ask, MarketInfo(Symbol(), MODE_DIGITS)) + " ");
                  }
                  if (SOUND_ALERT == TRUE) PlaySound("alert.wav");
               }
               G_time_136 = Time[0];
            }
            Li_32--;
         }
      }
   }
}
