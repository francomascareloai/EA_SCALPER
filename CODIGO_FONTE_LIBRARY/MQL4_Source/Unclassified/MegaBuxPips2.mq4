//+------------------------------------------------------------------+
//|                                                 MegaBuxPips2.mq4 |
//|                                                    Ksardas Tower |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Ksardas Tower"
#property link      "http://www.mql5.com"
//Очередной HFT. Торгует на длинных свечах на возврат к МАшке внутри свечи потиково. 
//Нужен близкий к ДЦ VPS с исполнением 1мс
//EURUSD и GBPUSD, тф М1
//stroka 300//
#include <stdlib.mqh>
extern double Lots = 0.01; //постоянный лот при доле депа =0 и мин лот при доле депа отличной от 0
extern double Ddep = 0.2;//
extern double Dmargin =1;
extern string Configuration = "================ Configuration";
extern bool Mode_HighSpeed = TRUE;
extern double Mode_Safe = 0.002;
extern string Username = "Traders-Shop";
extern int Pma=39;
extern string OrderCmt = "X";
extern double TakeProfit = 50.0;
extern double StopLoss = 60.0;
extern double distance = 30.0;
double gd_136 = 0.1;
//"---------------- Scalping Factors";
double gd_196 = 40.0;
double gd_228 = 0.3333333333;
double gd_236 = 0.0;
extern string SL_TP_Trailing = "---------------- SL / TP / Trailing";
extern double Trailing_Resolution = 0.0;
double gd_260 = 0.0;
double gd_268 = 20.0;
extern bool Trailing_Stop = TRUE;
extern int Magic = 7777;
bool gi_280 = TRUE;
int gi_312 = 0;
double gd_316 = 0.0;
int g_slippage_324 = 3;
double gda_328;
double gda_332;
int gia_336;
double gd_340 = 1.0;
double gd_348;
bool gi_356;
double gd_360;
bool gi_368 = FALSE;
double gd_372 = 1.0;
double gd_380 = 0.0;
int gi_388 = 0;
int g_time_392 = 0;
int g_count_396 = 0;
double gda_400;
int gi_404 = 0;
bool gi_408 = TRUE;
double gd_412 = 5.0;
double gd_420 = 10.0;
double gd_428 = 40.0;
bool gi_436 = FALSE;
double gd_440 = 5.0;
double gd_448 = 10.0;
double gd_456 = 40.0;
bool gi_464 = FALSE;
bool gi_unused_468 = FALSE;
int gia_492 = 0;

int init() {
   
   gi_312 = 5;
   gd_316 = 0.00001;
   if (Digits < 5) g_slippage_324 = 0;
   else gi_388 = -1;
   gia_492=1;
   start();
   return (0);
}

int start() {
   if (gi_312 == 0) {
      init();
      return(0);
   }
   if (gia_492 == 1) {
         f0_2(gda_328, gda_332, gia_336, gd_340);
         f0_0(Period());
   }
   return (0);
}

void f0_0(int a_timeframe_0) {
   int ticket_16;
   int li_24;
   double ld_28;
   double ld_30;
   bool bool_28;
   //double ld_92;
   bool li_116;
   double ld_120;
   double ld_136;
   double ld_220;
   int datetime_236;
   //int li_240;
   //double ld_244;
   double order_stoploss_260;
   double order_takeprofit_268;
   double ld_276;
   int li_292;
   int li_296;
   //string ls_300;
   //bool li_308;
   if (g_time_392 < Time[0]) {
      g_time_392 = Time[0];
      g_count_396 = 0;
   } else g_count_396++;
   double ihigh_64 = iHigh(Symbol(), a_timeframe_0, 0);
   double ilow_72 = iLow(Symbol(), a_timeframe_0, 0);
   double icustom_32 =  iMA(NULL, a_timeframe_0, Pma, 0, MODE_LWMA, PRICE_LOW, 0);
   double icustom_40 =  iMA(NULL, a_timeframe_0, Pma, 0, MODE_LWMA, PRICE_HIGH, 0);
   double ld_80 = icustom_32 - icustom_40;
   bool li_88 = Bid >= icustom_40 + ld_80 / 2.0;


   double ld_100 = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
   double ld_108 = Ask - Bid;
   double ld_128 = 0.5;
   if (ld_128 < ld_100 - 5.0 * gd_316) {
      li_116 = gi_436;
      ld_120 = gd_428 * gd_316;
      ld_128 = gd_420 * gd_316;
      ld_136 = gd_412 * gd_316;
   } else {
      if (!Mode_HighSpeed) {
         li_116 = gi_464;
         ld_120 = gd_456 * gd_316;
         ld_128 = gd_448 * gd_316;
         ld_136 = gd_440 * gd_316;
      } else {
         li_116 = gi_280;
         ld_120 = gd_268 * gd_316;
         ld_128 = gd_260 * gd_316;
         ld_136 = Trailing_Resolution * gd_316;
      }
   }

   double ld_unused_144 = gda_400;
   if (gi_404 < 30) gi_404++;
   double ld_152 = 0;
 

   double ld_160 = ld_152 / gi_404;
   if (!gi_368 && ld_160 < 15.0 * gd_316) gd_380 = 15.0 * gd_316 - ld_160;
   double ld_168 = f0_5(Ask + gd_380);
   double ld_176 = f0_5(Bid - gd_380);
   double ld_184 = ld_160 + gd_380;
   
   
   double ld_200;
   double ld_208 = ihigh_64 - ilow_72;

   double limitTe = Mode_Safe ;
  

   ld_200=0.0022;
   if(ld_208>limitTe) { 
   if (Bid < icustom_40)   int li_216=-1; 
   else if (Bid > icustom_32) li_216=1;
    }    
   if (gd_236 == 0.0) ld_220 = gd_228 * ld_200;
   else ld_220 = gd_236 * gd_316;
   if (Bid == 0.0 || MarketInfo(Symbol(), MODE_LOTSIZE) == 0.0) ld_220 = 0;
   double ld_228 = ld_220 + ld_160 + gd_380;
   if (gi_408) datetime_236 = TimeCurrent() + 660.0 ;//* MathMax(10 * a_timeframe_0, 60);
   else datetime_236 = 0;

    //........................................................................................
        int m;
        double MG;
        
        if(AccountFreeMargin()>Dmargin*AccountMargin()&&Lots>0)
        {
        MG=AccountFreeMargin();
        double Min = MarketInfo(Symbol(), MODE_LOTSTEP);
              
        if(Ddep>0)
        {
        m=MG/MarketInfo (Symbol(), MODE_MARGINREQUIRED)*Ddep/Min;
        gd_136 = m*Min;
        if(gd_136 > MarketInfo (Symbol(), MODE_MAXLOT))
        gd_136 = MarketInfo (Symbol(), MODE_MAXLOT);             
        if(gd_136 < Lots)
        gd_136 = Lots; 
        if(gd_136< MarketInfo(Symbol(), MODE_MINLOT)) 
        gd_136 =  MarketInfo(Symbol(), MODE_MINLOT);    
        }
        }
        if(Ddep==0)gd_136 = Lots;

 //......................................................................................, 
  
   int count_252 = 0;
   int count_256 = 0;
   for (int pos_4 = 0; pos_4 < OrdersTotal(); pos_4++) {
      bool sel=OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber() == Magic && OrderCloseTime() == 0) {
         if (OrderSymbol() != Symbol()) {
            count_256++;
            continue;
         }
         switch (OrderType()) {
         case OP_BUY:
            while (Trailing_Stop) {
               order_stoploss_260 = OrderStopLoss();
               order_takeprofit_268 = OrderTakeProfit();
               if (!(order_takeprofit_268 < f0_5(ld_168 + ld_120) && ld_168 + ld_120 - order_takeprofit_268 > ld_136)) break;
               order_stoploss_260 = f0_5(Bid - ld_120);
               order_takeprofit_268 = f0_5(ld_168 + ld_120);
               bool_28 = OrderModify(OrderTicket(), 0, order_stoploss_260, order_takeprofit_268, datetime_236, Lime);
               if (bool_28) break;
               li_24 = f0_1();
               if (!(li_24)) break;
            }
            count_252++;
            break;
         case OP_SELL:
            while (Trailing_Stop) {
               order_stoploss_260 = OrderStopLoss();
               order_takeprofit_268 = OrderTakeProfit();
               if (!(order_takeprofit_268 > f0_5(ld_176 - ld_120) && order_takeprofit_268 - ld_176 + ld_120 > ld_136)) break;
               order_stoploss_260 = f0_5(Ask + ld_120);
               order_takeprofit_268 = f0_5(ld_176 - ld_120);
               bool_28 = OrderModify(OrderTicket(), 0, order_stoploss_260, order_takeprofit_268, datetime_236, Orange);
               if (bool_28) break;
               li_24 = f0_1();
               if (!(li_24)) break;
            }
            count_252++;
            break;
         case OP_BUYSTOP:
            if (!li_88) {
               ld_276 = OrderTakeProfit() - OrderOpenPrice() - gd_380;
               while (true) {
                  if (!(f0_5(Ask + ld_128) < OrderOpenPrice() && OrderOpenPrice() - Ask - ld_128 > ld_136)) break;
                  bool_28 = OrderModify(OrderTicket(), f0_5(Ask + ld_128), f0_5(Bid + ld_128 - ld_276), f0_5(ld_168 + ld_128 + ld_276), 0, Lime);
                  if (bool_28) break;
                  li_24 = f0_1();
                  if (!(li_24)) break;
               }
               count_252++;
            } else sel =OrderDelete(OrderTicket());
            break;
         case OP_SELLSTOP:
            if (li_88) {
               ld_276 = OrderOpenPrice() - OrderTakeProfit() - gd_380;
               while (true) {
                  if (!(f0_5(Bid - ld_128) > OrderOpenPrice() && Bid - ld_128 - OrderOpenPrice() > ld_136)) break;
                  bool_28 = OrderModify(OrderTicket(), f0_5(Bid - ld_128), f0_5(Ask - ld_128 + ld_276), f0_5(ld_176 - ld_128 - ld_276), 0, Orange);
                  if (bool_28) break;
                  li_24 = f0_1();
                  if (!(li_24)) break;
               }
               count_252++;
            } else bool del=OrderDelete(OrderTicket());
         }
      }
   }
   bool li_288 = FALSE;
   if (gi_388 >= 0 || gi_388 == -2) {
      li_292 = NormalizeDouble(Bid / gd_316, 0);
      li_296 = NormalizeDouble(Ask / gd_316, 0);
      if (li_292 % 10 != 0 || li_296 % 10 != 0) gi_388 = -1;
      else {
         if (gi_388 >= 0 && gi_388 < 10) gi_388++;
         else gi_388 = -2;
      }
   }
   if (ld_220 != 0.0 && count_252 == 0 && li_216 != 0 && f0_5(ld_184) <= f0_5(gd_196 * gd_316) && gi_388 == -1) {
      if (li_216 < 0) 
      {
         if (li_116)
          {
         ld_28 = Ask + distance * Point;
            ticket_16 = OrderSend(Symbol(), OP_BUYSTOP, gd_136, ld_28, g_slippage_324, ld_28 - StopLoss * Point, ld_28 + TakeProfit * Point, OrderCmt, Magic, datetime_236, Lime);
            if (ticket_16 < 0)
               {
               li_288 = TRUE;
               } else {
               PlaySound("news.wav");
               }
         } 
         else 
         {
            if (Bid - ilow_72 > 0.0 && gd_348 > 0.0) 
             {
               ticket_16 = OrderSend(Symbol(), OP_BUY, gd_136, Ask, g_slippage_324, 0, 0, OrderCmt, Magic, datetime_236, Lime);
               if (ticket_16 < 0) 
                 {
                  li_288 = TRUE;
                 }
                  else 
                  {
                  while (true)
                   {
                     bool_28 = OrderModify(ticket_16, 0, f0_5(Bid - ld_220), f0_5(ld_168 + ld_220), datetime_236, Lime);
                     if (bool_28) break;
                     li_24 = f0_1();
                     if (!(li_24)) break;
                   }
                   PlaySound("news.wav");
                   }
            }
         }
      } 
      else 
      {
         if (li_216 > 0) 
         {
            if (li_116) 
            {
            ld_30 =Bid - distance * Point;
               ticket_16 = OrderSend(Symbol(), OP_SELLSTOP, gd_136, ld_30, g_slippage_324, ld_30 + StopLoss * Point, ld_30 - TakeProfit * Point, OrderCmt, Magic, datetime_236, Orange);
               if (ticket_16 < 0)
                {
                  li_288 = TRUE;
                  } else {
                  PlaySound("news.wav");
                  }
            } 
            else 
            {
               if (ihigh_64 - Bid < 0.0  && gd_348 < 0.0) 
               {
                  ticket_16 = OrderSend(Symbol(), OP_SELL, gd_136, Bid, g_slippage_324, 0, 0, OrderCmt, Magic, datetime_236, Orange);
                  if (ticket_16 < 0) 
                  {
                     li_288 = TRUE;
                     } 
                     else 
                     {
                     while (true) 
                     {
                        bool_28 = OrderModify(ticket_16, 0, f0_5(Ask + ld_220), f0_5(ld_176 - ld_220), datetime_236, Orange);
                        if (bool_28) break;
                        li_24 = f0_1();
                        if (!(li_24)) break;
                     }
                     PlaySound("news.wav");
                     }
               }
            }
         }
      }
   }

}

int f0_1() {
   return (0);
}

void f0_2(double ada_0, double &ada_4, int &aia_8, double ad_12) {
   double ld_52;
   if (aia_8 == 0 || MathAbs(Bid - ada_0) >= ad_12 * gd_316) {
      for (int li_20 = 29; li_20 > 0; li_20--) {

      }
      ada_0 = Bid;
      ada_4 = Ask;
   }
   gd_348 = 0;
   gi_356 = FALSE;
   double ld_24 = 0;
   int li_32 = 0;
   double ld_36 = 0;
   int li_44 = 0;
   int li_unused_48 = 0;
   for (li_20 = 1; li_20 < 30; li_20++) {

      if (ld_52 < ld_24) {
         ld_24 = ld_52;
      }
      if (ld_52 > ld_36) {
         ld_36 = ld_52;
      }
      if (ld_24 < 0.0 && ld_36 > 0.0 && (ld_24 < 3.0 * ((-ad_12) * gd_316) || ld_36 > 3.0 * (ad_12 * gd_316))) {
         if ((-ld_24) / ld_36 < 0.5) {
            gd_348 = ld_36;
            gi_356 = li_44;
            break;
         }
         if ((-ld_36) / ld_24 < 0.5) {
            gd_348 = ld_24;
            gi_356 = li_32;
         }
      } else {
         if (ld_36 > 5.0 * (ad_12 * gd_316)) {
            gd_348 = ld_36;
            gi_356 = li_44;
         } else {
            if (ld_24 < 5.0 * ((-ad_12) * gd_316)) {
               gd_348 = ld_24;
               gi_356 = li_32;
               break;
            }
         }
      }
   }
   if (gi_356 == FALSE) {
      gd_360 = 0;
      return;
   }
   gd_360 = 1000.0 * gd_348 / gi_356;
}


double f0_5(double ad_0) {
   return (NormalizeDouble(ad_0, gi_312));
}


