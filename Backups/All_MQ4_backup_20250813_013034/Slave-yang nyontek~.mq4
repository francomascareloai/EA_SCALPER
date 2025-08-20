/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website: H ttP:// www . M etAqu O tE s.n Et
   E-mail :  S u P P O rt@mE t a qU OT es. N et
*/
#property copyright "Copyright © 2011, http://ecandlestick.com"
#property link      "http://ecandlestick.com"
#property show_inputs

//#include <stdlib.mqh>
#import "stdlib.ex4"
   string ErrorDescription(int a0); // DA69CBAFF4D38B87377667EEC549DE5A
#import "copier.dll"
   int GV_GetNamedInt(string a0, int a1);
   double GV_GetNamedDouble(string a0, double a1);
#import

extern bool Ngikut_Lot_Master = TRUE;
extern double Pengali_Lot_Master = 1.0;
extern double Lots_Sendiri = 0.1;
extern bool TP_SL_Manual = FALSE;
extern int TakeProfit = 0;
extern int StopLoss = 0;
extern int Trailing_Stop = 0;
string Gs_copier_112 = "copier";
string Gs_120 = "AUDCAD,AUDCHF,EURAUD,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURCAD,EURCHF,EURDKK,EURGBP,EURJPY,EURNOK,EURNZD,EURSEK,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPNZD,GBPUSD,GBPJPY,NZDCAD,NZDCHF,NZDJPY,NZDUSD,SGDJPY,USDCAD,USDCHF,USDHKD,USDJPY,USDSGD";
string Gs_128 = "AUDCADm,AUDCHFm,EURAUDm,AUDJPYm,AUDNZDm,AUDUSDm,CADCHFm,CADJPYm,CHFJPYm,EURCADm,EURCHFm,EURDKKm,EURGBPm,EURJPYm,EURNOKm,EURNZDm,EURSEKm,EURUSDm";
string Gs_136 = "GBPAUDm,GBPCADm,GBPCHFm,GBPNZDm,GBPUSDm,GBPJPYm,NZDCADm,NZDCHFm,NZDJPYm,NZDUSDm,SGDJPYm,USDCADm,USDCHFm,USDHKDm,USDJPYm,USDSGDm";
string Gs_144 = "AUDCAD.,AUDCHF.,EURAUD.,AUDJPY.,AUDNZD.,AUDUSD.,CADCHF.,CADJPY.,CHFJPY.,EURCAD.,EURCHF.,EURDKK.,EURGBP.,EURJPY.,EURNOK.,EURNZD.,EURSEK.,EURUSD.";
string Gs_152 = "GBPAUD.,GBPCAD.,GBPCHF.,GBPNZD.,GBPUSD.,GBPJPY.,NZDCAD.,NZDCHF.,NZDJPY.,NZDUSD.,SGDJPY.,USDCAD.,USDCHF.,USDHKD.,USDJPY.,USDSGD.";
string Gs_160;
bool Gi_168 = TRUE;
bool Gi_172 = FALSE;
int G_slippage_176 = 10;
int Gi_180 = 100;
int Gi_184 = 450;
int Gi_188 = 50;
bool Gi_192 = TRUE;
int Gi_196 = 200;
bool Gi_200 = FALSE;
bool Gi_204 = FALSE;
int G_count_208;
string G_name_212 = "map.dat";
double Gda_220[][11];
double Gda_224[][11];
int Gia_228[][2];
double Gda_unused_232[1][2];
string Gsa_236[];
string Gsa_240[];
string Gsa_244[];
string Gs_248;
int G_datetime_256;
int G_datetime_260;
int Gi_264;
int Gia_268[];
int Gi_272;
int Gi_276;
int Gi_280;

void init() {
   int Li_0;
   int Li_4;
   int Li_8;
   string Ls_12;
   Gs_160 = Gs_120 + Gs_128 + Gs_136 + Gs_144 + Gs_152;
   G_datetime_260 = TimeCurrent();
   while (true) {
      Li_4 = StringFind(Gs_160, ",", Li_0);
      if (Li_4 <= 0) break;
      Ls_12 = StringSubstr(Gs_160, Li_0, Li_4 - Li_0);
      Li_0 = Li_4 + 1;
      Li_8++;
      ArrayResize(Gsa_236, Li_8);
      Gsa_236[Li_8 - 1] = Ls_12;
   }
   Ls_12 = StringSubstr(Gs_160, Li_0);
   Li_8++;
   ArrayResize(Gsa_236, Li_8);
   Gsa_236[Li_8 - 1] = Ls_12;
   Li_8 = 0;
   Li_0 = 0;
   Li_4 = 0;
   while (true) {
      Li_4 = StringFind(Gs_copier_112, ",", Li_0);
      if (Li_4 <= 0) break;
      Ls_12 = StringSubstr(Gs_copier_112, Li_0, Li_4 - Li_0);
      Li_0 = Li_4 + 1;
      Li_8++;
      ArrayResize(Gsa_240, Li_8);
      Gsa_240[Li_8 - 1] = Ls_12;
   }
   Ls_12 = StringSubstr(Gs_copier_112, Li_0);
   Li_8++;
   ArrayResize(Gsa_240, Li_8);
   Gsa_240[Li_8 - 1] = Ls_12;
   Print(ArraySize(Gsa_236), " SymbolNames:");
   Ls_12 = "";
   for (Li_0 = 0; Li_0 < ArraySize(Gsa_236); Li_0++) Ls_12 = Ls_12 + Gsa_236[Li_0] + ", ";
   Print(Ls_12);
   Print(ArraySize(Gsa_240), " systems:");
   Ls_12 = "";
   for (Li_0 = 0; Li_0 < ArraySize(Gsa_240); Li_0++) Ls_12 = Ls_12 + Gsa_240[Li_0] + ", ";
   Print(Ls_12);
}

int start() {
   int Li_0;
   string Ls_4;
   Gi_276 = NormalizeDouble(MarketInfo(Symbol(), MODE_STOPLEVEL), 2);
   Gi_280 = NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD), 2);
   if (Digits == 5 || Digits == 3 || Symbol() == "GOLD" || Symbol() == "GOLD." || Symbol() == "GOLDm") Gi_272 = 10;
   else Gi_272 = 1;
   if (Trailing_Stop * Gi_272 < Gi_276 + Gi_280 && Trailing_Stop != 0) Trailing_Stop = (Gi_276 + Gi_280) / Gi_272;
   Sleep(5000);
   while (IsStopped() == FALSE) {
      getOpenOrders(Trailing_Stop);
      Sleep(Gi_196);
      Gs_248 = "jam komputer adalah : " + TimeToStr(TimeLocal(), TIME_SECONDS);
      Comment(Gs_248);
      if (!(IsConnected())) continue;
      if (!(IsTradeAllowed())) continue;
      if (Gi_200) CloseAll();
      Li_0 = FindTrades();
      Ls_4 = " ";
      Ls_4 = GetSlaveTrades();
      Gs_248 = "jam komputer adalah : " + TimeToStr(TimeLocal(), TIME_SECONDS) + " tunggu sinyal dari ( " + Ls_4 + " ) Master EA";
      Comment(Gs_248);
      if (CountNZ(Gda_220, 9) == 0 && TimeCurrent() - G_datetime_260 > 120 && OrdersTotal() == 0) FileDelete(G_name_212);
      Li_0 = ReadMap();
      Li_0 = MakeMap();
      if (TimeCurrent() - G_datetime_256 > 180) {
         Print("MAimp total mytrades:", CountNZ(Gda_224, 11));
         Print("MAimp total slave trades:", CountNZ(Gda_220, 11));
         Print("MAimp total map:", CountNZi(Gia_228, 2));
         G_datetime_256 = TimeCurrent();
      }
      Li_0 = CloseOrders();
      Li_0 = SaveArrayIToFile(Gia_228, G_name_212);
      if (Li_0 <= 0) Print("Error saving Map!");
      Li_0 = ModifyOrderPrices();
      Comment(Gs_248);
   }
   return (0);
}

int FindTrades() {
   int order_total_0 = OrdersTotal();
   ArrayResize(Gda_224, 0);
   for (int pos_4 = order_total_0 - 1; pos_4 >= 0; pos_4--)
      if (OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES)) AddTrade(OrderTicket());
   return (1);
}

int AddTrade(int A_ticket_0) {
   string Ls_4;
   int str2int_12;
   int Li_16;
   int Li_20 = ArraySize(Gda_224) / 11 + 1;
   int Li_24 = -1;
   if (OrderSelect(A_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) {
      for (int index_28 = 0; index_28 < ArraySize(Gsa_236); index_28++) {
         if (Gsa_236[index_28] == OrderSymbol()) {
            Li_24 = index_28;
            break;
         }
      }
      if (Li_24 < 0) return (0);
      Ls_4 = OrderComment();
      str2int_12 = 0;
      if (StringFind(Ls_4, "from #", 0) >= 0) {
         Li_16 = StringFind(Ls_4, "#", 0);
         str2int_12 = StrToInteger(StringSubstr(Ls_4, Li_16 + 1, StringLen(Ls_4) - Li_16 - 1));
      }
      ArrayResize(Gda_224, Li_20);
      Gda_224[Li_20 - 1][0] = A_ticket_0;
      Gda_224[Li_20 - 1][1] = OrderType();
      Gda_224[Li_20 - 1][2] = OrderOpenPrice();
      Gda_224[Li_20 - 1][3] = OrderStopLoss();
      Gda_224[Li_20 - 1][4] = OrderTakeProfit();
      Gda_224[Li_20 - 1][5] = OrderOpenTime();
      Gda_224[Li_20 - 1][6] = Li_24;
      Gda_224[Li_20 - 1][7] = OrderLots();
      Gda_224[Li_20 - 1][8] = 0;
      Gda_224[Li_20 - 1][9] = OrderClosePrice();
      Gda_224[Li_20 - 1][10] = str2int_12;
   }
   return (0);
}

string GetSlaveTrades() {
   int Li_0;
   int count_4;
   double Ld_8;
   string Ls_ret_16;
   ArrayResize(Gda_220, 0);
   ArrayResize(Gsa_244, 0);
   int Li_24 = 0;
   for (int index_28 = 0; index_28 < ArraySize(Gsa_240); index_28++) {
      count_4 = 0;
      Li_0 = GV_GetNamedInt(Gsa_240[index_28] + "lines", -1);
      if (Li_0 > 0) {
         Ls_ret_16 = Ls_ret_16 + " " + Gsa_240[index_28] + " ";
         for (int count_32 = 0; count_32 < Li_0; count_32++) {
            Li_24++;
            ArrayResize(Gda_220, Li_24);
            ArrayResize(Gsa_244, Li_24);
            Gsa_244[Li_24 - 1] = Gsa_240[index_28];
            for (int count_36 = 0; count_36 < 11; count_36++) {
               count_4++;
               Ld_8 = GV_GetNamedDouble(Gsa_240[index_28] + "_mt_" + count_4, -1);
               if (Ld_8 >= 0.0) Gda_220[Li_24 - 1][count_36] = Ld_8;
               else Gda_220[Li_24 - 1][count_36] = 0;
            }
         }
      }
   }
   return (Ls_ret_16);
}

int ReadMap() {
   int Li_0;
   int file_4 = FileOpen(G_name_212, FILE_CSV|FILE_READ);
   if (file_4 < 1) return (0);
   ArrayResize(Gia_228, 0);
   while (!FileIsEnding(file_4)) {
      Li_0++;
      ArrayResize(Gia_228, Li_0);
      Gia_228[Li_0 - 1][0] = FileReadNumber(file_4);
      Gia_228[Li_0 - 1][1] = FileReadNumber(file_4);
   }
   ArrayResize(Gia_228, Li_0 - 1);
   FileClose(file_4);
   return (1);
}

int MakeMap() {
   int Li_0;
   int Li_4;
   int Li_8;
   int Li_12;
   int Li_16;
   bool Li_20;
   for (int index_24 = 0; index_24 < ArraySize(Gda_220) / 11; index_24++) {
      if (Gda_220[index_24][8] <= 0.9) {
         if (Gda_220[index_24][10] <= 0.9) {
            Li_20 = FALSE;
            Li_0 = Gda_220[index_24][0];
            for (int index_28 = 0; index_28 < ArraySize(Gia_228) / 2; index_28++) {
               Li_4 = Gia_228[index_28][0];
               if (Li_0 == Li_4) {
                  Li_8 = Gia_228[index_28][1];
                  for (int index_32 = 0; index_32 < ArraySize(Gda_224) / 11; index_32++) {
                     Li_12 = Gda_224[index_32][0];
                     if (Li_8 == Li_12) {
                        Li_20 = TRUE;
                        index_32 = 99999;
                        index_28 = 99999;
                     }
                  }
               }
            }
            if ((!Li_20) && Li_0 > 0) {
               Li_16 = MakeOrder(index_24);
               if (Li_16 > 0) AddMap(Li_0, Li_16);
            }
         }
      }
   }
   return (0);
}

int AddMap(int Ai_0, int Ai_4) {
   int Li_8;
   if (Ai_4 > 0) {
      Li_8 = ArraySize(Gia_228) / 2 + 1;
      ArrayResize(Gia_228, Li_8);
      Gia_228[Li_8 - 1][0] = Ai_0;
      Gia_228[Li_8 - 1][1] = Ai_4;
   }
   return (0);
}

int MakeOrder(int Ai_0) {
   int count_4;
   int ticket_8;
   double price_12;
   double Ld_20;
   double bid_28;
   double ask_36;
   int Li_44;
   int cmd_48 = Gda_220[Ai_0][1];
   int magic_52 = Gda_220[Ai_0][0];
   if (IsNoTrade(magic_52)) return (0);
   if (!Gi_192)
      if (cmd_48 != OP_BUY && cmd_48 != OP_SELL) return;
   int Li_56 = 1;
   if (cmd_48 == OP_SELL || cmd_48 == OP_SELLSTOP || cmd_48 == OP_SELLLIMIT) Li_56 = -1;
   double price_60 = Gda_220[Ai_0][3];
   double price_68 = Gda_220[Ai_0][4];
   double price_76 = price_60;
   double price_84 = price_68;
   string symbol_92 = GetSymbol(Gda_220[Ai_0][6]);
   double Ld_100 = MarketInfo(symbol_92, MODE_MINLOT);
   if (Ld_100 < 1.0) Gi_264 = 1;
   if (Ld_100 < 0.1) Gi_264 = 2;
   if (Ld_100 < 0.01) Gi_264 = 3;
   double lots_108 = Lots_Sendiri;
   if (Ngikut_Lot_Master) lots_108 = NormalizeDouble(Pengali_Lot_Master * Gda_220[Ai_0][7], Gi_264);
   double point_116 = MarketInfo(symbol_92, MODE_POINT);
   int digits_124 = MarketInfo(symbol_92, MODE_DIGITS);
   int stoplevel_128 = MarketInfo(symbol_92, MODE_STOPLEVEL);
   if (lots_108 < Ld_100) lots_108 = Ld_100;
   for (G_count_208 = 0; ticket_8 <= 0 && G_count_208 < Gi_188; G_count_208++) {
      count_4 = 0;
      while (count_4 < 7 && !IsTradeAllowed()) {
         count_4++;
         Sleep(3000);
      }
      RefreshRates();
      if (cmd_48 != OP_BUY && cmd_48 != OP_SELL) price_12 = Gda_220[Ai_0][2];
      if (cmd_48 == OP_BUY) price_12 = MarketInfo(symbol_92, MODE_ASK);
      if (cmd_48 == OP_SELL) price_12 = MarketInfo(symbol_92, MODE_BID);
      Ld_20 = Gda_220[Ai_0][2];
      if (Gi_172) {
         if (NormalizeDouble(price_76, 1) >= 0.1) price_76 = NormalizeDouble(price_12 - Li_56 * MathAbs(Ld_20 - price_60), digits_124);
         if (NormalizeDouble(price_84, 1) >= 0.1) price_84 = NormalizeDouble(price_12 + Li_56 * MathAbs(price_68 - Ld_20), digits_124);
      }
      if (TP_SL_Manual) {
         price_76 = 0;
         price_84 = 0;
         if (StopLoss > 0) price_76 = NormalizeDouble(price_12 - Li_56 * StopLoss * point_116, digits_124);
         if (TakeProfit > 0) price_84 = NormalizeDouble(price_12 + Li_56 * TakeProfit * point_116, digits_124);
      }
      bid_28 = MarketInfo(symbol_92, MODE_BID);
      ask_36 = MarketInfo(symbol_92, MODE_ASK);
      Print("stoplev=", stoplevel_128, ", bid=", bid_28, ", ask=", ask_36, " , ticket=", magic_52, " order : ", symbol_92, ", type=", cmd_48, ", lots=", lots_108, ", entry=",
         price_12, ", slip=", G_slippage_176, ", sl=", price_76, ", tp=", price_84, ", cmt=", Gsa_244[Ai_0], " fr # ", Gda_220[Ai_0][10]);
      if (Gi_184 > 0 && TimeCurrent() - Gda_220[Ai_0][5] > 60 * Gi_184) {
         Print(magic_52 + " No trade - ExpireMinutes limitation" + TimeToStr(Gda_220[Ai_0][5], TIME_DATE|TIME_MINUTES));
         Alert(magic_52 + " No trade - ExpireMinutes limitation" + TimeToStr(Gda_220[Ai_0][5], TIME_DATE|TIME_MINUTES));
         AddNoTrade(magic_52);
         return (-1);
      }
      if (MathAbs(Ld_20 - price_12) > Gi_180 * point_116) {
         Print(magic_52 + " No trade - MaxMarketDiff limitation, order=", Ld_20, "  local=", price_12, " pnt=", point_116, " ", Gi_180 * point_116);
         Alert(magic_52 + " No trade - MaxMarketDiff limitation, order=" + Ld_20 + "  local=" + price_12 + " pnt=" + point_116 + " " + (Gi_180 * point_116));
         AddNoTrade(magic_52);
         return (-1);
      }
      if ((cmd_48 == OP_BUYLIMIT || cmd_48 == OP_SELLSTOP && price_12 > bid_28 - stoplevel_128 * point_116) || (cmd_48 == OP_BUYSTOP || cmd_48 == OP_SELLLIMIT && price_12 < ask_36 +
         stoplevel_128 * point_116)) {
         Gs_248 = Gs_248 
            + "\n" 
         + "ticket - import - wrong entry price (stoplevel)!";
         return (0);
      }
      if (Li_56 > 0 && NormalizeDouble(price_76, 1) >= 0.1 && price_76 > price_12 - stoplevel_128 * point_116) {
         Gs_248 = Gs_248 
            + "\n" 
         + "ticket - import - wrong SL for buy!";
         return (0);
      }
      if (Li_56 > 0 && NormalizeDouble(price_84, 1) >= 0.1 && price_84 < price_12 + stoplevel_128 * point_116) {
         Gs_248 = Gs_248 
            + "\n" 
         + "ticket - import - wrong TP for buy!";
         return (0);
      }
      if (Li_56 < 0 && NormalizeDouble(price_84, 1) >= 0.1 && price_84 > price_12 - stoplevel_128 * point_116) {
         Gs_248 = Gs_248 
            + "\n" 
         + "ticket - import - wrong TP for sell!";
         return (0);
      }
      if (Li_56 < 0 && NormalizeDouble(price_76, 1) >= 0.1 && price_76 < price_12 + stoplevel_128 * point_116) {
         Gs_248 = Gs_248 
            + "\n" 
         + "ticket - import - wrong SL for sell!";
         return (0);
      }
      if (cmd_48 != OP_BUY && cmd_48 != OP_SELL) ticket_8 = OrderSend(symbol_92, cmd_48, lots_108, price_12, G_slippage_176, price_76, price_84, Gsa_244[Ai_0] + "_" + magic_52, magic_52, 0, White);
      else {
         if (!Gi_204) ticket_8 = OrderSend(symbol_92, cmd_48, lots_108, price_12, G_slippage_176, price_76, price_84, Gsa_244[Ai_0] + "_" + magic_52, magic_52, 0, White);
         else {
            ticket_8 = OrderSend(symbol_92, cmd_48, lots_108, price_12, G_slippage_176, 0, 0, Gsa_244[Ai_0] + "_" + magic_52, magic_52, 0, White);
            if (ticket_8 > 0) {
               while (Li_44 < 20) {
                  Li_44++;
                  if (OrderSelect(ticket_8, SELECT_BY_TICKET)) {
                     if (OrderModify(ticket_8, OrderOpenPrice(), price_76, price_84, OrderExpiration(), White)) break;
                     Sleep(1000);
                  } else Sleep(1000);
               }
            }
         }
      }
   }
   if (ticket_8 <= 0) Print("Error opening order : ", ErrorDescription(GetLastError()));
   return (ticket_8);
}

string GetSymbol(int Ai_0) {
   return (Gsa_236[Ai_0]);
}

void CloseAll() {
   int cmd_0;
   int count_4;
   bool Li_8;
   if (Gi_200) {
      for (int pos_12 = OrdersTotal() - 1; pos_12 >= 0; pos_12--) {
         OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
         cmd_0 = OrderType();
         if (cmd_0 == OP_BUY) {
            Li_8 = FALSE;
            for (G_count_208 = 0; !Li_8 && G_count_208 < Gi_188; G_count_208++) {
               count_4 = 0;
               while (count_4 < 6 && !IsTradeAllowed()) {
                  count_4++;
                  Sleep(5000);
               }
               RefreshRates();
               Li_8 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), G_slippage_176, White);
               Sleep(3000);
            }
            if (!Li_8) Print("Error closing order BUY : ", MarketInfo(OrderSymbol(), MODE_BID), " ", OrderTicket(), " ", ErrorDescription(GetLastError()));
         }
         if (cmd_0 == OP_SELL) {
            Li_8 = FALSE;
            for (G_count_208 = 0; !Li_8 && G_count_208 < Gi_188; G_count_208++) {
               count_4 = 0;
               while (count_4 < 6 && !IsTradeAllowed()) {
                  count_4++;
                  Sleep(5000);
               }
               RefreshRates();
               Li_8 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), G_slippage_176, White);
               Sleep(3000);
            }
            if (!Li_8) Print("Error closing order SELL: ", MarketInfo(OrderSymbol(), MODE_ASK), " ", OrderTicket(), " ", ErrorDescription(GetLastError()));
         }
         if (cmd_0 == OP_BUYSTOP || cmd_0 == OP_BUYLIMIT || cmd_0 == OP_SELLSTOP || cmd_0 == OP_SELLLIMIT) {
            Li_8 = FALSE;
            for (G_count_208 = 0; !Li_8 && G_count_208 < Gi_188; G_count_208++) {
               count_4 = 0;
               while (count_4 < 6 && !IsTradeAllowed()) {
                  count_4++;
                  Sleep(5000);
               }
               RefreshRates();
               Li_8 = OrderDelete(OrderTicket());
               Sleep(3000);
            }
            if (!Li_8) Print("Error deleting order : ", MarketInfo(OrderSymbol(), MODE_BID), " ", OrderTicket(), " ", ErrorDescription(GetLastError()));
         }
      }
   }
}

int CloseOrders() {
   int Li_0;
   int ticket_4;
   int Li_8;
   int ticket_12;
   int Li_16;
   int Li_20;
   int Li_24;
   int ticket_28;
   int Li_32;
   int Li_36;
   bool Li_40;
   int Li_44;
   int count_48;
   double lots_52;
   double order_lots_60;
   bool Li_68;
   bool Li_72;
   bool Li_76;
   double point_80 = 0.00001;
   for (int index_88 = 0; index_88 < ArraySize(Gda_220) / 11; index_88++) {
      Li_8 = -1;
      if (Gda_220[index_88][8] > 0.8) {
         Li_8 = Gda_220[index_88][0];
         ticket_12 = Gda_220[index_88][10];
         lots_52 = Pengali_Lot_Master * Gda_220[index_88][7];
         if (!Ngikut_Lot_Master) lots_52 = Lots_Sendiri;
         Li_0 = Gda_220[index_88][6];
         point_80 = MarketInfo(GetSymbol(Li_0), MODE_POINT);
         Li_24 = Gda_220[index_88][1];
         if (Gi_168 && Li_24 == 0 || Li_24 == 1 && MathAbs(Gda_220[index_88][9] - Gda_220[index_88][3]) < point_80 || MathAbs(Gda_220[index_88][9] - Gda_220[index_88][4]) < point_80) continue;
         ticket_4 = -1;
         for (int index_92 = 0; index_92 < ArraySize(Gia_228) / 2; index_92++) {
            Li_16 = Gia_228[index_92][0];
            if (Li_8 == Li_16) {
               ticket_4 = Gia_228[index_92][1];
               Li_24 = -1;
               Li_68 = FALSE;
               for (int index_96 = 0; index_96 < ArraySize(Gda_224) / 11; index_96++) {
                  Li_20 = Gda_224[index_96][0];
                  if (ticket_4 == Li_20) {
                     Li_24 = Gda_224[index_96][1];
                     Li_68 = TRUE;
                     break;
                  }
               }
               if (Li_68) {
                  Li_76 = FALSE;
                  for (G_count_208 = 0; !Li_76 && G_count_208 < Gi_188; G_count_208++) {
                     if (!(OrderSelect(ticket_4, SELECT_BY_TICKET, MODE_TRADES))) break;
                     order_lots_60 = OrderLots();
                     ticket_28 = ticket_4;
                     RefreshRates();
                     if (equal(lots_52, order_lots_60)) {
                        if (Li_24 == 0 || Li_24 == 1) {
                           Li_76 = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), G_slippage_176, White);
                           continue;
                        }
                        Li_76 = OrderDelete(OrderTicket());
                     } else {
                        if (Li_24 == 0 || Li_24 == 1) Li_76 = OrderClose(OrderTicket(), lots_52, OrderClosePrice(), G_slippage_176, White);
                        if (Li_76) {
                           Li_44 = Li_8;
                           ticket_28 = ticket_12;
                           Li_40 = FALSE;
                           for (index_88 = 0; index_88 < ArraySize(Gia_228) / 2; index_88++) {
                              Li_32 = Gia_228[index_88][0];
                              if (Li_44 == Li_32) {
                                 Gia_228[index_88][0] = ticket_28;
                                 Li_36 = Gia_228[index_88][1];
                                 count_48 = 0;
                                 Li_72 = FALSE;
                                 while ((!Li_72) && Li_36 != Li_40 && count_48 < 100) {
                                    count_48++;
                                    Sleep(50);
                                    FindTrades();
                                    for (int index_100 = 0; index_100 < ArraySize(Gda_224) / 11; index_100++) {
                                       if (Gda_224[index_100][10] >= 0.9) {
                                          Li_40 = Gda_224[index_100][10];
                                          if (Li_36 == Li_40) {
                                             Gia_228[index_88][1] = Gda_224[index_100][0];
                                             break;
                                          }
                                       }
                                    }
                                 }
                                 break;
                              }
                           }
                        }
                     }
                  }
                  if (!Li_76) Print("Error closing or deleting order : ", MarketInfo(OrderSymbol(), MODE_BID), " ", OrderTicket(), " ", ErrorDescription(GetLastError()));
               }
            }
         }
      }
   }
   return (0);
}

int ModifyOrderPrices() {
   int Li_0;
   int Li_4;
   int Li_8;
   int Li_12;
   for (int index_16 = 0; index_16 < ArraySize(Gia_228) / 2; index_16++) {
      Li_4 = Gia_228[index_16][0];
      Li_0 = Gia_228[index_16][1];
      Li_8 = -1;
      for (int index_20 = 0; index_20 <= ArraySize(Gda_224) / 11; index_20++)
         if (Gda_224[index_20][0] == Li_0) Li_8 = index_20;
      Li_12 = -1;
      for (int index_24 = 0; index_24 <= ArraySize(Gda_220) / 11; index_24++)
         if (Gda_220[index_24][0] == Li_4) Li_12 = index_24;
      if (Li_12 < 0 || Li_8 < 0) continue;
      if (!equal(Gda_224[Li_8][3], Gda_220[Li_12][3])) ModifyOrder(Li_8, 2, Gda_220[Li_12][3]);
      if (!equal(Gda_224[Li_8][4], Gda_220[Li_12][4])) ModifyOrder(Li_8, 3, Gda_220[Li_12][4]);
      if (Gda_220[Li_12][1] != 1.0 && Gda_220[Li_12][1] != 0.0)
         if (!equal(Gda_224[Li_8][2], Gda_220[Li_12][2])) ModifyOrder(Li_8, 1, Gda_220[Li_12][2]);
   }
   return (0);
}

int ModifyOrder(int Ai_0, int Ai_4, double Ad_8) {
   double order_open_price_16;
   double price_24;
   double price_32;
   bool bool_40 = FALSE;
   G_count_208 = 0;
   if (OrderSelect(Gda_224[Ai_0][0], SELECT_BY_TICKET, MODE_TRADES)) {
      order_open_price_16 = OrderOpenPrice();
      price_24 = OrderStopLoss();
      price_32 = OrderTakeProfit();
      if (Ai_4 == 1) order_open_price_16 = Ad_8;
      if (Ai_4 == 2) price_24 = Ad_8;
      if (Ai_4 == 3) price_32 = Ad_8;
      Print("OrderModify " + Ai_4 + " :: ", OrderTicket(), ", ", order_open_price_16, ", ", price_24, ", ", price_32);
      while (!bool_40 && G_count_208 < Gi_188) {
         RefreshRates();
         bool_40 = OrderModify(OrderTicket(), order_open_price_16, price_24, price_32, 0, White);
         Sleep(5000);
         G_count_208++;
      }
      if (!bool_40) Print("Error modifying order at : ", MarketInfo(OrderSymbol(), MODE_BID), " ", OrderTicket(), " ", ErrorDescription(GetLastError()));
   }
   return (0);
}

int equal(double Ad_0, double Ad_8) {
   if (MathAbs(NormalizeDouble(Ad_0, 6) - NormalizeDouble(Ad_8, 6)) > 0.0000001) return (0);
   return (1);
}

int CountNZ(double Ada_0[][11], int Ai_4) {
   int Li_ret_8;
   int Li_12 = ArraySize(Ada_0) / Ai_4;
   for (int index_16 = 0; index_16 < Li_12; index_16++)
      if (Ada_0[index_16][0] > 0.0) Li_ret_8++;
   return (Li_ret_8);
}

int CountNZi(int Aia_0[][2], int Ai_4) {
   int Li_ret_8;
   int Li_12 = ArraySize(Aia_0) / Ai_4;
   for (int index_16 = 0; index_16 < Li_12; index_16++)
      if (Aia_0[index_16][0] > 0) Li_ret_8++;
   return (Li_ret_8);
}

int AddNoTrade(int Ai_0) {
   int arr_size_4 = ArraySize(Gia_268);
   ArrayResize(Gia_268, arr_size_4 + 1);
   Gia_268[arr_size_4] = Ai_0;
   return (0);
}

int IsNoTrade(int Ai_0) {
   int arr_size_4 = ArraySize(Gia_268);
   for (int index_8 = 0; index_8 < arr_size_4; index_8++)
      if (Gia_268[index_8] == Ai_0) return (1);
   return (0);
}

int SaveArrayIToFile(int Aia_0[][2], string A_name_4) {
   int Li_12;
   int file_16 = FileOpen(A_name_4, FILE_CSV|FILE_WRITE);
   if (file_16 < 1) {
      Print("File " + A_name_4 + " not opened, the last error is ", ErrorDescription(GetLastError()));
      return (0);
   }
   for (int index_20 = 0; index_20 < ArraySize(Aia_0) / 2; index_20++) Li_12 = FileWrite(file_16, Aia_0[index_20][0], Aia_0[index_20][1]);
   if (Li_12 < 0) {
      Print("writing file error : ", ErrorDescription(GetLastError()));
      return (0);
   }
   FileFlush(file_16);
   FileClose(file_16);
   return (1);
}

double getPipValue(double Ad_0, int Ai_8) {
   double Ld_ret_12;
   RefreshRates();
   if (Ai_8 == 1) Ld_ret_12 = NormalizeDouble(Ad_0, Digits) - NormalizeDouble(Ask, Digits);
   else Ld_ret_12 = NormalizeDouble(Bid, Digits) - NormalizeDouble(Ad_0, Digits);
   Ld_ret_12 /= Point;
   return (Ld_ret_12);
}

void getOpenOrders(double Ad_0) {
   double Ld_16;
   int order_total_8 = OrdersTotal();
   for (int pos_12 = 0; pos_12 < order_total_8; pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() == OP_BUY || OrderType() == OP_SELL && StringFind(OrderComment(), "_", 0) >= 0) {
         Ld_16 = getPipValue(OrderOpenPrice(), OrderType());
         if (Ad_0 != 0.0) TrailingPositions(Ad_0, 1, OrderTicket());
      }
   }
}

void TrailingPositions(double Ad_0, double Ad_8, int A_ticket_16) {
   if (OrderType() == OP_BUY) {
      if (Bid - OrderOpenPrice() > Ad_0 * Gi_272 * Point) {
         if (OrderStopLoss() < Bid - (Ad_0 + Ad_8 - 1.0) * Gi_272 * Point || OrderStopLoss() == 0.0) {
            OrderModify(A_ticket_16, OrderOpenPrice(), Bid - Ad_0 * Gi_272 * Point, OrderTakeProfit(), 0, CLR_NONE);
            return;
         }
      }
   }
   if (OrderType() == OP_SELL) {
      if (OrderOpenPrice() - Ask > Ad_0 * Gi_272 * Point) {
         if (OrderStopLoss() > Ask + (Ad_0 + Ad_8 - 1.0) * Gi_272 * Point || OrderStopLoss() == 0.0) {
            OrderModify(A_ticket_16, OrderOpenPrice(), Ask + Ad_0 * Gi_272 * Point, OrderTakeProfit(), 0, CLR_NONE);
            return;
         }
      }
   }
}
