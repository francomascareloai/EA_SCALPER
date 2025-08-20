
//+-----------------------------------------------------------------+
//|                                                   FXCORE1_V1.mq4 |
//|                                      rodolfo.leonardo@gmail.com. |
//+------------------------------------------------------------------+
#property copyright "FXCORE1_V1 BETA DEVELOPER"
#property link      "http://goo.gl/9FoC8c"
#property version   "1.00"
#property description "FXCORE1_V1 BETA DEVELOPER "
#property description "This EA is 100% FREE "
#property description "Coder: rodolfo.leonardo@gmail.com "

#property description "Donation Link : http://goo.gl/9FoC8c"
#property strict

enum ENUM_SINALMODE {
    IMA = 0,// IMA
    BB_RSI_STOCH = 1,// BB RSI STOCH
};


string vg_versao = " FXCORE1_V1 BETA DEVELOPER  2018-03-03 ";

extern int InpMagicNumberFxCore = 988827;


extern int InpStopLevelFxCore = 20;
extern int InpMaxOrderFxCore = 15;
extern bool InpHabilitaFatorFxCore = true;
extern double InpFatorFxCore = 2.0;
extern bool InpHabilitaSomaFxCore = FALSE;
extern double InpLoteSomaFxCore = 1.0;

 int InpModoFxCore = 2;
extern ENUM_SINALMODE InpSinalModeFxCore = IMA;

extern string SINALIMA=                              "------------------------- SINAL IMA-------------------------";
input ENUM_TIMEFRAMES        InpIMAFrame= PERIOD_CURRENT;   
extern int InpPeriodoIMAFxCore = 5;
extern int InpPeriodoLongIMAFxCore = 20;

extern string SINALBB=                              "------------------------- SINAL BB-------------------------";
extern bool InpSinalBBFxCore = TRUE;
input ENUM_TIMEFRAMES        InpBBFrame= PERIOD_CURRENT;                                // Bands B TimeFrame
extern int InpBBPeriodFxCore = 20;
extern int vBandsBordFxCore = 2;


extern string SINALST=                              "------------------------- SINAL Stochastic-------------------------";
extern bool InpSinalStochasticFxCore = TRUE;
input ENUM_TIMEFRAMES        InpStochasticFrame= PERIOD_CURRENT;                                // Stochastic TimeFrame
extern int InpPeriodStochastcFxCore = 5;
extern int InpPeriodStochastcCFxCore = 3;
extern int InpSlowingStochastcFxCore = 3;

extern string SINALRSI=                              "------------------------- SINAL RSI-------------------------";
extern bool InpSinalRSIFxCore = TRUE;
input ENUM_TIMEFRAMES        InpRSIFrame= PERIOD_CURRENT;
extern int InpPeriodRSIFxCore = 9;
extern int InpRSIMaxFxCore = 70;
extern int InpRSIMinFxCore = 30;


int vg_CountOrdersFxCore = 0;
int vg_OrderTotalFxCore;
int vg_HistTotalFxCore;
int vg_PosFxCore;
//int vg_CountOrdersFxCore;
int vg_QtdDigitsFxCore;
int vg_TipoOrderFxCore;
int vg_TicketFxCore;
double vg_MinLotOpenOrderFxCore;
double vg_CloseProfitFxCore;
double vg_PointFxCore;
double vg_MinLotFxCore;
double vg_MaxLotFxCore;
double vg_StopLevelFxCore;
double vg_LastOrdemLotsFxCore;
double vg_LastOrdemOpenPriceFxCore;
double vg_ProfitCloseFxCore;
double vg_ProfitTotalFxCore;
double vg_ProfitOpenFxCore;
string vg_PriceFxCore;
string vg_AlertFxCore = "";
string vg_MensagemFxCore;


//-------------------------------------------------------------------------//
int init() {
   if (Digits == 3 || Digits == 5) vg_PointFxCore = 10.0 * Point;
   else vg_PointFxCore = Point;
   vg_MinLotFxCore = MarketInfo(Symbol(), MODE_MINLOT);
   if (vg_MinLotFxCore == 0.01) vg_QtdDigitsFxCore = 2;
   else {
      if (vg_MinLotFxCore == 0.1) vg_QtdDigitsFxCore = 1;
      else vg_QtdDigitsFxCore = 0;
   }
   if (vg_MinLotOpenOrderFxCore <= vg_MinLotFxCore) vg_MinLotOpenOrderFxCore = vg_MinLotFxCore;
   vg_StopLevelFxCore = MarketInfo(Symbol(), MODE_STOPLEVEL);
   if (InpStopLevelFxCore <= vg_StopLevelFxCore) InpStopLevelFxCore = vg_StopLevelFxCore;
   double leverage_0 = AccountLeverage();
   if (AccountLeverage() <= 200) vg_MinLotOpenOrderFxCore = NormalizeDouble(AccountBalance() / 10000.0 * (leverage_0 / 200.0), 2);
   else vg_MinLotOpenOrderFxCore = NormalizeDouble(AccountBalance() / 10000.0, 2);
   vg_CloseProfitFxCore = 150.0 * vg_MinLotOpenOrderFxCore;
   vg_MaxLotFxCore = 4.0 * vg_MinLotOpenOrderFxCore;
   return (0);
}

//-------------------------------------------------------------------------//
int deinit() {
   Comment("");
   return (0);
}

//-------------------------------------------------------------------------//
int start() {
Painel2("A");
   string ls_0;
   if (AccountBalance() < 50.0) vg_AlertFxCore = "ERROR: Fundo Insuficiente \nMinimo 50";
   
   if (IsDemo() == TRUE) ls_0 = "Conta: Demo";
   else ls_0 = "Conta: Real";
   if (vg_AlertFxCore != "") {
      Alert(vg_AlertFxCore);
      Comment(vg_MensagemFxCore);
      vg_AlertFxCore = "";
   } else {
      switch (InpModoFxCore) {
      case 0:
         AnalizandoMercadoFxCore();
         Comment("\nAnalizando o Mercado");
         break;
      case 1:
         ProcessaFechamentoOrdemFxCore();
         Comment("\n Verificando Fechamento de Ordens");
         break;
      case 2:
         VerificandoAberturaOrdemFxCore();
         Comment(vg_MensagemFxCore, 
            "\nAnalizando o Mercado . . .\n", ls_0, 
         "\nAlavancamento: ", AccountLeverage());
      }
      return (0);
   }
   return (0);
}
//-------------------------------------------------------------------------//
int CountOrdersFxCore() {
   vg_OrderTotalFxCore = OrdersTotal();
   vg_CountOrdersFxCore = 0;
   for (vg_PosFxCore = 0; vg_PosFxCore < vg_OrderTotalFxCore; vg_PosFxCore++) {
      OrderSelect(vg_PosFxCore, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != InpMagicNumberFxCore) continue;
      vg_CountOrdersFxCore++;
   }
   return (vg_CountOrdersFxCore);
}

//-------------------------------------------------------------------------//
int OpenOrdersFxCore(int a_cmd_0, double a_lots_4, double a_price_12, color a_color_20) {
    return (OrderSend(Symbol(), a_cmd_0, a_lots_4, a_price_12, 3, 0, 0, "", InpMagicNumberFxCore, 0, a_color_20));
   return (0);
}

//-------------------------------------------------------------------------//
int CloseOrdersFxCore() {
   vg_OrderTotalFxCore = OrdersTotal();
   for (vg_PosFxCore = vg_OrderTotalFxCore - 1; vg_PosFxCore >= 0; vg_PosFxCore--) {
      OrderSelect(vg_PosFxCore, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != InpMagicNumberFxCore) continue;
      switch (OrderType()) {
      case OP_BUY:
         OrderClose(OrderTicket(), OrderLots(), Bid, 1, CLR_NONE);
         vg_PriceFxCore = Bid;
         
         break;
      case OP_SELL:
         OrderClose(OrderTicket(), OrderLots(), Ask, 1, CLR_NONE);
         vg_PriceFxCore = Ask;
        
         break;
      case OP_BUYLIMIT:
         OrderDelete(OrderTicket());
         break;
      case OP_SELLLIMIT:
         OrderDelete(OrderTicket());
      }
   }
   return (0);
}

//-------------------------------------------------------------------------//
double GetLastLotFxCore() {
   vg_OrderTotalFxCore = OrdersTotal();
   vg_LastOrdemLotsFxCore = 0;
   for (vg_PosFxCore = 0; vg_PosFxCore < vg_OrderTotalFxCore; vg_PosFxCore++) {
      OrderSelect(vg_PosFxCore, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != InpMagicNumberFxCore) continue;
      vg_LastOrdemLotsFxCore = OrderLots();
   }


   return (vg_LastOrdemLotsFxCore);
}

//-------------------------------------------------------------------------//
double GetTotalProfitFxCore() {
   vg_OrderTotalFxCore = OrdersTotal();
   vg_ProfitCloseFxCore = 0;
   for (vg_PosFxCore = 0; vg_PosFxCore < vg_OrderTotalFxCore; vg_PosFxCore++) {
      OrderSelect(vg_PosFxCore, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != InpMagicNumberFxCore) continue;
      vg_ProfitCloseFxCore += OrderProfit();
   }
   return (vg_ProfitCloseFxCore);
}

//-------------------------------------------------------------------------//
int GetSinalFxCore() {
   double ima_0;
   double ima_8;
   double ima_16;
   double ibands_24;
   double ibands_32;
   double istochastic_40;
   double irsi_48;
   if (InpSinalModeFxCore == 0) {
      ima_0 = iMA(Symbol(), InpIMAFrame, InpPeriodoIMAFxCore, 0, MODE_SMA, PRICE_CLOSE, 0);
      ima_8 = iMA(Symbol(), InpIMAFrame, InpPeriodoIMAFxCore, 0, MODE_SMA, PRICE_CLOSE, 1);
      ima_16 = iMA(Symbol(), InpIMAFrame, InpPeriodoLongIMAFxCore, 0, MODE_SMA, PRICE_CLOSE, 1);
      if (ima_0 > ima_8 && ima_8 > ima_16) return (-15);
      if (!(ima_0 < ima_8 && ima_8 < ima_16)) return (0);
      return (15);
   }
   if (InpSinalModeFxCore == 1) {
      ibands_24 = iBands(Symbol(), InpBBFrame, InpBBPeriodFxCore, vBandsBordFxCore, 0, PRICE_CLOSE, MODE_UPPER, 0);
      ibands_32 = iBands(Symbol(), InpBBFrame, InpBBPeriodFxCore, vBandsBordFxCore, 0, PRICE_CLOSE, MODE_LOWER, 0);
      istochastic_40 = iStochastic(Symbol(), InpStochasticFrame, InpPeriodStochastcFxCore, InpPeriodStochastcCFxCore, InpSlowingStochastcFxCore, MODE_SMA, 0, MODE_SIGNAL, 0);
      irsi_48 = iRSI(Symbol(), InpRSIFrame, InpPeriodRSIFxCore, PRICE_CLOSE, 0);
      if (InpSinalBBFxCore && (!InpSinalStochasticFxCore) && (!InpSinalRSIFxCore)) {
         if (Close[0] > ibands_24) return (15);
         if (Close[0] >= ibands_32) return (0);
         return (-15);
      }
      if ((!InpSinalBBFxCore) && InpSinalStochasticFxCore && (!InpSinalRSIFxCore)) {
         if (istochastic_40 > InpRSIMaxFxCore) return (15);
         if (istochastic_40 >= InpRSIMinFxCore) return (0);
         return (-15);
      }
      if ((!InpSinalBBFxCore) && !InpSinalStochasticFxCore && InpSinalRSIFxCore) {
         if (irsi_48 > InpRSIMaxFxCore) return (15);
         if (irsi_48 >= InpRSIMinFxCore) return (0);
         return (-15);
      }
      if (InpSinalBBFxCore && InpSinalStochasticFxCore && (!InpSinalRSIFxCore)) {
         if (Close[0] > ibands_24 && istochastic_40 > InpRSIMaxFxCore) return (15);
         if (!(Close[0] < ibands_32 && istochastic_40 < InpRSIMinFxCore)) return (0);
         return (-15);
      }
      if (InpSinalBBFxCore && (!InpSinalStochasticFxCore) && InpSinalRSIFxCore) {
         if (Close[0] > ibands_24 && irsi_48 > InpRSIMaxFxCore) return (15);
         if (!(Close[0] < ibands_32 && irsi_48 < InpRSIMinFxCore)) return (0);
         return (-15);
      }
      if ((!InpSinalBBFxCore) && InpSinalStochasticFxCore && InpSinalRSIFxCore) {
         if (istochastic_40 > InpRSIMaxFxCore && irsi_48 > InpRSIMaxFxCore) return (15);
         if (!(istochastic_40 < InpRSIMinFxCore && irsi_48 < InpRSIMinFxCore)) return (0);
         return (-15);
      }
      if (InpSinalBBFxCore && InpSinalStochasticFxCore && InpSinalRSIFxCore) {
         if (Close[0] > ibands_24 && istochastic_40 > InpRSIMaxFxCore && irsi_48 > InpRSIMaxFxCore) return (15);
         if (!(Close[0] < ibands_32 && istochastic_40 < InpRSIMinFxCore && irsi_48 < InpRSIMinFxCore)) return (0);
         return (-15);
      }
   }
   return (0);
}

//-------------------------------------------------------------------------//
int AnalizandoMercadoFxCore() {
   if (GetTotalProfitFxCore() >= vg_CloseProfitFxCore) CloseOrdersFxCore();
   if (CountOrdersFxCore() == 0 && GetLastLotFxCore() == 0.0) {
      if (GetSinalFxCore() == -15)
         if (OpenOrdersFxCore(OP_BUY, vg_MinLotOpenOrderFxCore, Ask, Blue) > 0) return (0);
      if (GetSinalFxCore() == 15)
         if (OpenOrdersFxCore(OP_SELL, vg_MinLotOpenOrderFxCore, Bid, Red) > 0) return (0);
   }
   if (CountOrdersFxCore() > 0 && CountOrdersFxCore() < InpMaxOrderFxCore) {
      vg_TipoOrderFxCore = -1;
      vg_LastOrdemOpenPriceFxCore = 0;
      vg_OrderTotalFxCore = OrdersTotal();
      for (vg_PosFxCore = 0; vg_PosFxCore < vg_OrderTotalFxCore; vg_PosFxCore++) {
         OrderSelect(vg_PosFxCore, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != InpMagicNumberFxCore) continue;
         vg_TipoOrderFxCore = OrderType();
         vg_LastOrdemOpenPriceFxCore = OrderOpenPrice();
      }
      if (vg_TipoOrderFxCore == OP_BUY) {
         if (Ask > vg_LastOrdemOpenPriceFxCore - InpStopLevelFxCore * vg_PointFxCore) return (0);
         if (InpHabilitaFatorFxCore) {
            if (NormalizeDouble(vg_MinLotOpenOrderFxCore * MathPow(InpFatorFxCore, CountOrdersFxCore()), vg_QtdDigitsFxCore) > vg_MaxLotFxCore) return (0);
            if (OpenOrdersFxCore(OP_BUY, NormalizeDouble(vg_MinLotOpenOrderFxCore * MathPow(InpFatorFxCore, CountOrdersFxCore()), vg_QtdDigitsFxCore), Ask, Blue) > 0) return (0);
         }
         if (InpHabilitaSomaFxCore) {
            if (NormalizeDouble(vg_MinLotOpenOrderFxCore + (GetLastLotFxCore() + InpLoteSomaFxCore), vg_QtdDigitsFxCore) > vg_MaxLotFxCore) return (0);
            vg_TicketFxCore = OpenOrdersFxCore(OP_BUY, NormalizeDouble(GetLastLotFxCore() + InpLoteSomaFxCore, vg_QtdDigitsFxCore), Ask, Blue);
         }
      }
      if (vg_TipoOrderFxCore == OP_SELL) {
         if (Bid < vg_LastOrdemOpenPriceFxCore + InpStopLevelFxCore * vg_PointFxCore) return (0);
         if (InpHabilitaFatorFxCore) {
            if (NormalizeDouble(vg_MinLotOpenOrderFxCore * MathPow(InpFatorFxCore, CountOrdersFxCore()), vg_QtdDigitsFxCore) > vg_MaxLotFxCore) return (0);
            if (OpenOrdersFxCore(OP_SELL, NormalizeDouble(vg_MinLotOpenOrderFxCore * MathPow(InpFatorFxCore, CountOrdersFxCore()), vg_QtdDigitsFxCore), Bid, Red) > 0) return (0);
         }
         if (InpHabilitaSomaFxCore) {
            if (NormalizeDouble(vg_MinLotOpenOrderFxCore + (GetLastLotFxCore() + InpLoteSomaFxCore), vg_QtdDigitsFxCore) > vg_MaxLotFxCore) return (0);
            if (OpenOrdersFxCore(OP_SELL, NormalizeDouble(vg_MinLotOpenOrderFxCore + InpLoteSomaFxCore * vg_PosFxCore, vg_QtdDigitsFxCore), Bid, Blue) > 0) return (0);
         }
      }
   }
   return (0);
}


//-------------------------------------------------------------------------//
int ProcessaFechamentoOrdemFxCore() {
   if (CountOrdersFxCore() == 0) vg_CountOrdersFxCore = 0;
   vg_HistTotalFxCore = OrdersHistoryTotal();
   vg_OrderTotalFxCore = OrdersTotal();
   vg_ProfitCloseFxCore = 0;
   for (vg_PosFxCore = vg_HistTotalFxCore - vg_CountOrdersFxCore; vg_PosFxCore < vg_HistTotalFxCore; vg_PosFxCore++) {
      OrderSelect(vg_PosFxCore, SELECT_BY_POS, MODE_HISTORY);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != InpMagicNumberFxCore) continue;
      vg_ProfitCloseFxCore += OrderProfit();
   }
   vg_ProfitOpenFxCore = 0;
   for (vg_PosFxCore = 0; vg_PosFxCore < vg_OrderTotalFxCore; vg_PosFxCore++) {
      OrderSelect(vg_PosFxCore, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != InpMagicNumberFxCore) continue;
      vg_ProfitOpenFxCore += OrderProfit();
   }
   vg_ProfitTotalFxCore = vg_ProfitCloseFxCore + vg_ProfitOpenFxCore;
   if (vg_ProfitTotalFxCore >= vg_CloseProfitFxCore) CloseOrdersFxCore();
   if (CountOrdersFxCore() == 0 && GetLastLotFxCore() == 0.0 && vg_CountOrdersFxCore == 0) {
      if (GetSinalFxCore() == -15) {
         
         vg_TicketFxCore = OpenOrdersFxCore(OP_BUY, vg_MinLotOpenOrderFxCore, Ask, Blue);
         if (vg_TicketFxCore > 0) {
            vg_CountOrdersFxCore++;
            return (0);
         }
      }
      if (GetSinalFxCore() == 15) {
         
         vg_TicketFxCore = OpenOrdersFxCore(OP_SELL, vg_MinLotOpenOrderFxCore, Bid, Red);
         if (vg_TicketFxCore > 0) {
            vg_CountOrdersFxCore++;
            return (0);
         }
      }
   }
   if (CountOrdersFxCore() > 0 && CountOrdersFxCore() < InpMaxOrderFxCore) {
      vg_TipoOrderFxCore = -1;
      vg_LastOrdemOpenPriceFxCore = 0;
      vg_OrderTotalFxCore = OrdersTotal();
      for (vg_PosFxCore = 0; vg_PosFxCore < vg_OrderTotalFxCore; vg_PosFxCore++) {
         OrderSelect(vg_PosFxCore, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != InpMagicNumberFxCore) continue;
         vg_TipoOrderFxCore = OrderType();
         vg_LastOrdemOpenPriceFxCore = OrderOpenPrice();
      }
      if (vg_TipoOrderFxCore == OP_BUY) {
         if (Ask > vg_LastOrdemOpenPriceFxCore - InpStopLevelFxCore * vg_PointFxCore) return (0);
         if (InpHabilitaFatorFxCore) {
            if (NormalizeDouble(vg_MinLotOpenOrderFxCore * MathPow(InpFatorFxCore, vg_CountOrdersFxCore), vg_QtdDigitsFxCore) > vg_MaxLotFxCore) return (0);
            vg_TicketFxCore = OpenOrdersFxCore(OP_BUY, NormalizeDouble(vg_MinLotOpenOrderFxCore * MathPow(InpFatorFxCore, vg_CountOrdersFxCore), vg_QtdDigitsFxCore), Ask, Blue);
            if (vg_TicketFxCore > 0) {
               vg_CountOrdersFxCore++;
               vg_OrderTotalFxCore = OrdersTotal();
               for (vg_PosFxCore = 0; vg_PosFxCore < vg_OrderTotalFxCore; vg_PosFxCore++) {
                  OrderSelect(vg_PosFxCore, SELECT_BY_POS, MODE_TRADES);
                  if (OrderSymbol() != Symbol() || OrderMagicNumber() != InpMagicNumberFxCore) continue;
                  if (OrderTicket() != vg_TicketFxCore) OrderClose(OrderTicket(), OrderLots(), Bid, 3, CLR_NONE);
               }
            }
         }
         if (InpHabilitaSomaFxCore) {
            if (NormalizeDouble(vg_MinLotOpenOrderFxCore + (GetLastLotFxCore() + InpLoteSomaFxCore), vg_QtdDigitsFxCore) > vg_MaxLotFxCore) return (0);
            vg_TicketFxCore = OpenOrdersFxCore(OP_BUY, NormalizeDouble(GetLastLotFxCore() + InpLoteSomaFxCore, vg_QtdDigitsFxCore), Ask, Blue);
            if (vg_TicketFxCore > 0) {
               vg_CountOrdersFxCore++;
               vg_OrderTotalFxCore = OrdersTotal();
               for (vg_PosFxCore = 0; vg_PosFxCore < vg_OrderTotalFxCore; vg_PosFxCore++) {
                  OrderSelect(vg_PosFxCore, SELECT_BY_POS, MODE_TRADES);
                  if (OrderSymbol() != Symbol() || OrderMagicNumber() != InpMagicNumberFxCore) continue;
                  if (OrderTicket() != vg_TicketFxCore) OrderClose(OrderTicket(), OrderLots(), Bid, 3, CLR_NONE);
               }
            }
         }
      }
      if (vg_TipoOrderFxCore == OP_SELL) {
         if (Bid < vg_LastOrdemOpenPriceFxCore + InpStopLevelFxCore * vg_PointFxCore) return (0);
         if (InpHabilitaFatorFxCore) {
            if (NormalizeDouble(vg_MinLotOpenOrderFxCore * MathPow(InpFatorFxCore, vg_CountOrdersFxCore), vg_QtdDigitsFxCore) > vg_MaxLotFxCore) return (0);
            vg_TicketFxCore = OpenOrdersFxCore(OP_SELL, NormalizeDouble(vg_MinLotOpenOrderFxCore * MathPow(InpFatorFxCore, vg_CountOrdersFxCore), vg_QtdDigitsFxCore), Bid, Red);
            if (vg_TicketFxCore > 0) {
               vg_CountOrdersFxCore++;
               vg_OrderTotalFxCore = OrdersTotal();
               for (vg_PosFxCore = 0; vg_PosFxCore < vg_OrderTotalFxCore; vg_PosFxCore++) {
                  OrderSelect(vg_PosFxCore, SELECT_BY_POS, MODE_TRADES);
                  if (OrderSymbol() != Symbol() || OrderMagicNumber() != InpMagicNumberFxCore) continue;
                  if (OrderTicket() != vg_TicketFxCore) OrderClose(OrderTicket(), OrderLots(), Ask, 3, CLR_NONE);
               }
            }
         }
         if (InpHabilitaSomaFxCore) {
            if (NormalizeDouble(vg_MinLotOpenOrderFxCore + (GetLastLotFxCore() + InpLoteSomaFxCore), vg_QtdDigitsFxCore) > vg_MaxLotFxCore) return (0);
            vg_TicketFxCore = OpenOrdersFxCore(OP_SELL, NormalizeDouble(vg_MinLotOpenOrderFxCore + InpLoteSomaFxCore * vg_CountOrdersFxCore, vg_QtdDigitsFxCore), Bid, Blue);
            if (vg_TicketFxCore > 0) {
               vg_CountOrdersFxCore++;
               vg_OrderTotalFxCore = OrdersTotal();
               for (vg_PosFxCore = 0; vg_PosFxCore < vg_OrderTotalFxCore; vg_PosFxCore++) {
                  OrderSelect(vg_PosFxCore, SELECT_BY_POS, MODE_TRADES);
                  if (OrderSymbol() != Symbol() || OrderMagicNumber() != InpMagicNumberFxCore) continue;
                  if (OrderTicket() != vg_TicketFxCore) OrderClose(OrderTicket(), OrderLots(), Ask, 3, CLR_NONE);
               }
            }
         }
      }
   }
   return (0);
}

//-------------------------------------------------------------------------//
int VerificandoAberturaOrdemFxCore() {
   if (GetTotalProfitFxCore() >= vg_CloseProfitFxCore) CloseOrdersFxCore();
   if (CountOrdersFxCore() == 0 && GetLastLotFxCore() == 0.0) {
      if (GetSinalFxCore() == -15) {
         
         if (OpenOrdersFxCore(OP_BUY, vg_MinLotOpenOrderFxCore, Ask, Blue) > 0) return (0);
      }
      if (GetSinalFxCore() == 15) {
        
         if (OpenOrdersFxCore(OP_SELL, vg_MinLotOpenOrderFxCore, Bid, Red) > 0) return (0);
      }
   }
   if (CountOrdersFxCore() == 1 && GetLastLotFxCore() == vg_MinLotOpenOrderFxCore) {
      vg_TipoOrderFxCore = -1;
      vg_LastOrdemOpenPriceFxCore = 0;
      vg_OrderTotalFxCore = OrdersTotal();
      for (vg_PosFxCore = 0; vg_PosFxCore < vg_OrderTotalFxCore; vg_PosFxCore++) {
         OrderSelect(vg_PosFxCore, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != InpMagicNumberFxCore) continue;
         vg_TipoOrderFxCore = OrderType();
         vg_LastOrdemOpenPriceFxCore = OrderOpenPrice();
      }
      if (vg_TipoOrderFxCore == OP_BUY) {
         for (vg_PosFxCore = 1; vg_PosFxCore <= InpMaxOrderFxCore; vg_PosFxCore++) {
            if (InpHabilitaFatorFxCore) {
               if (NormalizeDouble(vg_MinLotOpenOrderFxCore * MathPow(InpFatorFxCore, vg_PosFxCore), vg_QtdDigitsFxCore) > vg_MaxLotFxCore) return (0);
               OpenOrdersFxCore(OP_BUYLIMIT, NormalizeDouble(vg_MinLotOpenOrderFxCore * MathPow(InpFatorFxCore, vg_PosFxCore), vg_QtdDigitsFxCore), Ask - InpStopLevelFxCore * vg_PosFxCore * vg_PointFxCore, Blue);
            }
            if (InpHabilitaSomaFxCore) {
               if (NormalizeDouble(vg_MinLotOpenOrderFxCore + InpLoteSomaFxCore * vg_PosFxCore, vg_QtdDigitsFxCore) > vg_MaxLotFxCore) return (0);
               OpenOrdersFxCore(OP_BUYLIMIT, NormalizeDouble(vg_MinLotOpenOrderFxCore + InpLoteSomaFxCore * vg_PosFxCore, vg_QtdDigitsFxCore), Ask - InpStopLevelFxCore * vg_PosFxCore * vg_PointFxCore, Blue);
            }
         }
      }
      if (vg_TipoOrderFxCore == OP_SELL) {
         for (vg_PosFxCore = 1; vg_PosFxCore <= InpMaxOrderFxCore; vg_PosFxCore++) {
            if (InpHabilitaFatorFxCore) {
               if (NormalizeDouble(vg_MinLotOpenOrderFxCore * MathPow(InpFatorFxCore, vg_PosFxCore), vg_QtdDigitsFxCore) > vg_MaxLotFxCore) return (0);
               OpenOrdersFxCore(OP_SELLLIMIT, NormalizeDouble(vg_MinLotOpenOrderFxCore * MathPow(InpFatorFxCore, vg_PosFxCore), vg_QtdDigitsFxCore), Bid + InpStopLevelFxCore * vg_PosFxCore * vg_PointFxCore, Red);
            }
            if (InpHabilitaSomaFxCore) {
               if (NormalizeDouble(vg_MinLotOpenOrderFxCore + InpLoteSomaFxCore * vg_PosFxCore, vg_QtdDigitsFxCore) > vg_MaxLotFxCore) return (0);
               OpenOrdersFxCore(OP_SELLLIMIT, NormalizeDouble(vg_MinLotOpenOrderFxCore + InpLoteSomaFxCore * vg_PosFxCore, vg_QtdDigitsFxCore), Bid + InpStopLevelFxCore * vg_PosFxCore * vg_PointFxCore, Blue);
            }
         }
      }
   }
   return (0);
}
void Painel2( string Ygs_104)
{
    string name_0 = Ygs_104 + "L_1";
    if (ObjectFind(name_0) == -1)
    {
        ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
        ObjectSet(name_0, OBJPROP_CORNER, 0);
        ObjectSet(name_0, OBJPROP_XDISTANCE, 500);
        ObjectSet(name_0, OBJPROP_YDISTANCE, 10);
    }
    ObjectSetText(name_0, vg_versao, 12, "Arial", White);
    
}