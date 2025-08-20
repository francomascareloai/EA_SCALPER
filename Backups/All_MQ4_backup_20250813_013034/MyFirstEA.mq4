//+------------------------------------------------------------------+
//|                                                    MyFirstEA.mq4 |
//|                                      Copyright 2020, SignalForex |
//|                                           https://SignalForex.id |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, SignalForex"
#property link      "https://SignalForex.id"
#property version   "1.00"
#property strict


input int IN_PeriodMAFast = 5;   //MA Fast
input int IN_PeriodMASlow = 20;  //MA Slow

input double IN_Vol  = 0.01;  //Lot Size (awal)
input double IN_LotX = 1.5;   //Multiplier

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   if (IN_PeriodMAFast >= IN_PeriodMASlow){
      Alert ("Salah periode");
      return (INIT_FAILED);
   }
   
//---
   return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
}


int getSignalMACross(){
   int signal = -1;
   
   double maFast2 = iMA(NULL, 0, IN_PeriodMAFast, 0, MODE_EMA, PRICE_CLOSE, 2 );
   double maFast1 = iMA(NULL, 0, IN_PeriodMAFast, 0, MODE_EMA, PRICE_CLOSE, 1 );
   
   double maSlow2 = iMA(NULL, 0, IN_PeriodMASlow, 0, MODE_EMA, PRICE_CLOSE, 2 );
   double maSlow1 = iMA(NULL, 0, IN_PeriodMASlow, 0, MODE_EMA, PRICE_CLOSE, 1 );
   
   if (maSlow2 < maFast2 && maSlow1 >= maFast1){
      signal = OP_BUY;
   }else if (maSlow2 > maFast2 && maSlow1 <= maFast1){
      signal = OP_SELL;
   }
   
   return (signal);
   
}

void OpenOrder(int orderType){
   //vol 
   //OrderSend();
   //Print ("Sedang Open possi baru ");
   
   if (orderType == OP_BUY || orderType == OP_SELL){
      
   }
}

bool IsNewCandle(){
   bool isNewCS  = false;
   static datetime prevTime   = TimeCurrent();
   string pair = Symbol();
   if (prevTime < iTime(pair, 0, 0)){
      isNewCS  = true;
      prevTime = iTime(pair, 0, 0);
   }
   return isNewCS;
}


double getVolume(int tOrderType){
   double vol = 0.0;
   vol   = IN_Vol * MathPow(IN_LotX, tOrderType);
   vol = NormalizeDouble(vol, 2);
   return (vol);
}


void UpdateTPSL(){
   int MN = 123;
   double hargaBTB = 99999.0, hargaSTA = 0.0;
   int tOrderBuy = 0, tOrderSell = 0;
   
   int tOrders = OrdersTotal();
   for (int i=tOrders-1; i>=0; i--){
      bool hsl = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber() == MN  && OrderSymbol() == Symbol()){
         if (OrderType() == OP_BUY){
            tOrderBuy++;
            if (hargaBTB > OrderOpenPrice()){
               hargaBTB = OrderOpenPrice();
            }
         }
         
         if (OrderType() == OP_SELL){
            tOrderSell++;
            if (hargaSTA < OrderOpenPrice()){
               hargaSTA = OrderOpenPrice();
            }
         }
      }
   }
   
   double myPoint = 0.0;
   myPoint = MarketInfo(Symbol(), MODE_POINT);
   
   double TPBuy = 0.0;
   double TPSell = 0.0;
   if (tOrderBuy > 0){
      TPBuy = hargaBTB + (500 * myPoint);
   }
   if (tOrderSell > 0){
      TPSell = hargaSTA - (500 * myPoint);
   }
   
   
   tOrders = OrdersTotal();
   for (int i=tOrders-1; i>=0; i--){
      bool hsl = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber() == MN  && OrderSymbol() == Symbol()){
         if (OrderType() == OP_BUY){
            if (OrderTakeProfit() != TPBuy  && TPBuy > 0){
               hsl = OrderModify (OrderTicket(), OrderOpenPrice(), OrderStopLoss(), TPBuy, 0);
            }
         }
         if (OrderType() == OP_SELL){
            if (OrderTakeProfit() != TPSell && TPSell > 0){
               hsl = OrderModify (OrderTicket(), OrderOpenPrice(), OrderStopLoss(), TPSell, 0);
            }
         }
      }
   }
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{

   int signal = -1;
   
   bool newCandle = IsNewCandle();
   if (newCandle == true){
      signal = getSignalMACross();
      OpenOrder(signal);
   }
   
   //Open Martingale / averaging
   int MN = 123;
   double hargaBTB = 99999.0, hargaSTA = 0.0;
   int tOrderBuy = 0, tOrderSell = 0;
   
   int tOrders = OrdersTotal();
   for (int i=tOrders-1; i>=0; i--){
      bool hsl = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber() == MN  && OrderSymbol() == Symbol()){
         if (OrderType() == OP_BUY){
            tOrderBuy++;
            if (hargaBTB > OrderOpenPrice()){
               hargaBTB = OrderOpenPrice();
            }
         }
         
         if (OrderType() == OP_SELL){
            tOrderSell++;
            if (hargaSTA < OrderOpenPrice()){
               hargaSTA = OrderOpenPrice();
            }
         }
      }
   }
   
   double myPoint = 0.0;
   myPoint = MarketInfo(Symbol(), MODE_POINT);
   //int digit = (int) MarketInfo(Symbol(), MODE_DIGITS);
   //if (digit % 2 == 1){
   //   myPoint *= 10;
   //}
   
   int MaxOrders = 10;
   if (tOrderBuy > 0 && tOrderBuy < MaxOrders){
      double jarakOP = (hargaBTB - Ask) / myPoint;
      if (jarakOP >= 100){
         double vol = getVolume(tOrderBuy);
         bool hsl = OrderSend(Symbol(), OP_BUY, vol, Ask, 3, 0, 0, "", MN, 0);
      }
   }
   
   if (tOrderSell > 0 && tOrderSell < MaxOrders){
      double jarakOP = (Bid - hargaSTA) / myPoint;
      if (jarakOP >= 100){
         double vol = getVolume(tOrderSell);
         bool hsl = OrderSend(Symbol(), OP_SELL, vol, Bid, 3, 0, 0, "", MN, 0);
      }
   }
   
   
   UpdateTPSL();
   
}
//+------------------------------------------------------------------+
