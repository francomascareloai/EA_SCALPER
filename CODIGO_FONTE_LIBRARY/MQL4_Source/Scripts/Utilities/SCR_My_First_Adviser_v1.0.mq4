#property copyright "Copyright © 2007, Kiba Vladimir"
#property link      "vKiba@mail.ru"
#include <stderror.mqh>
#include <stdlib.mqh>
#define MAGICMA  20070722

extern int RSI_Per = 16;           //Период усреднения для RSI
extern int MA_Per = 6;             //Период усреднения для MA
extern int Bands_Per = 60;         //Период усреднения для Bollinger Bands
extern int Band_Range = 33;        //Порог перекупленности/перепроданности 
extern int SmoothType = 2;         //Тип сглаживания 0..3
extern double MaximumRisk =0.777;  //Уровень риска 0..1


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {

   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }

//+------------------------------------------------------------------+
//| ВЫВОД ОШИБКИ В ЖУРНАЛ                                            |
//+------------------------------------------------------------------+
int GetErrorDescription()
   {
      int err=GetLastError();
      Print("error(",err,"): ",ErrorDescription(err));
      return(0);
   }
//+------------------------------------------------------------------+
//|ПОДСЧЕТ КОЛИЧЕСТВА ОТКРЫТЫХ ОРДЕРОВ                               |
//+------------------------------------------------------------------+
int CalculateCurrentOrders()
  {
   int buys=0,sells=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
   return (buys-sells);
}
      
//+------------------------------------------------------------------+
//| ОПРЕДЕЛЕНИЕ ВЕЛИЧИНЫ ЛОТА                                        |
//|Параметры:                                                        |
//|   Price - Цена ордера                                            |
//+------------------------------------------------------------------+
double LotsOptimized(double Price)
{
 double LotValue = MarketInfo(Symbol(),MODE_LOTSIZE);   //Стоимость 1-го лота
 double FreeMargin = AccountFreeMargin();               //Свободные средства на счете
 double Leverage = AccountLeverage();                   //Плечо
 double MinLot = MarketInfo(Symbol(),MODE_MINLOT);      //Минимальный размер лота
 double MaxLot = MarketInfo(Symbol(),MODE_MAXLOT);      //Максимальный размер лота
 double Res = (FreeMargin*Leverage*MaximumRisk)/(Price*LotValue);
 if (NormalizeDouble(MinLot,1) > NormalizeDouble(Res,1)) Res=0;
 if (NormalizeDouble(MaxLot,1) < NormalizeDouble(Res,1)) Res=MaxLot;
 return (NormalizeDouble(Res,1));
}

//+--------------------------------------------------------------+
//| РАСЧЕТ ЗНАЧЕНИЯ STOPLOPSS                                    |
//|Параметры:                                                    |
//|   Type  - Тип ордера (-1 продажа, 1 покупка)                 |
//|   Price - Цена ордера                                        |
//|   Delta - Растояние межу нижней и верхней границ Bollinger'a |
///+-------------------------------------------------------------+
double Culculate_SL(int Type, double Price, double Delta)
{
double StopLevel = MarketInfo(Symbol(),MODE_STOPLEVEL);      //Минимально допустимый уровень
double Spred = MarketInfo(Symbol(),MODE_SPREAD);             //Разница между ценой покупки и продажи  
double StopLossMin = Price - Type*(Spred+StopLevel)*Point;   //Миниальное отклонение стоп-лоса от цены 
double StopLossCur = Price*(1-Type*Delta/2000);
StopLossMin = NormalizeDouble(StopLossMin,Digits);
StopLossCur = NormalizeDouble(StopLossCur,Digits);
if (StopLossMin<StopLossCur && Type==1)
   StopLossCur = StopLossMin;
if (StopLossMin>StopLossCur && Type==-1)
   StopLossCur=StopLossMin;         
return (StopLossCur);
}


//+------------------------------------------------------------------+
//| ОТКРЫТИЕ ПОЗИЦИИ                                                 |
//+------------------------------------------------------------------+
void OpenOrders(int Type, double Price, color ArrowColor, double Delta)
{
   if (CalculateCurrentOrders()!=0) return;
   double StopLoss = Culculate_SL(Type,Price,Delta);
   int TypeOrder;
   if (Type==1) TypeOrder = OP_BUY; else TypeOrder = OP_SELL;
   double Lots = LotsOptimized(Price);
   if (Lots>0)
      {
         int res = OrderSend(Symbol(),TypeOrder,Lots,Price,3,StopLoss,0,"",MAGICMA,0,ArrowColor);
         if (res==-1) GetErrorDescription();
      }
   else
      Print("Как не печально, но деньги закончились.");
}

//+------------------------------------------------------------------+
//| ИЗМЕНЕНИЕ ПОЗИЦИИ                                                |
//+------------------------------------------------------------------+  
void ModifyOrder(double Delta)
{
   int res;
   double NewStopLoss, OldStopLoss, PriceCur;
   for(int cnt=0;cnt<OrdersTotal();cnt++)
    {
     if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==false) break;
     OldStopLoss=NormalizeDouble(OrderStopLoss(),Digits);
     if (OrderType()==OP_BUY) PriceCur = Ask; else PriceCur = Bid;
     if (OrderType()==OP_BUY)
         NewStopLoss = Culculate_SL(1,Ask,Delta);
     if (OrderType()==OP_SELL)
         NewStopLoss = Culculate_SL(-1,Bid,Delta);
     if (OrderType()==OP_BUY && NewStopLoss<OldStopLoss)
         NewStopLoss=OldStopLoss;
     if (OrderType()==OP_SELL &&  NewStopLoss>OldStopLoss)
         NewStopLoss=OldStopLoss;
      if (NewStopLoss!=OldStopLoss)
         {
            res = OrderModify(OrderTicket(),OrderOpenPrice(),NewStopLoss,OrderTakeProfit(),OrderExpiration(),LightGreen);
            if (!res) GetErrorDescription();

         }
     }     
     
}
//+------------------------------------------------------------------+
//| ЗАКРЫТИЕ ПОЗИЦИИ                                                 |
//+------------------------------------------------------------------+  
void CloseOrders(int Type, double Price)
{
int OrdersCount,num,cnt;
OrdersCount=OrdersTotal(); num=0;
for(cnt=0;cnt<OrdersCount;cnt++)
   {
      if(OrderSelect(cnt-num,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      if (OrderType()==Type)
         {
            OrderClose(OrderTicket(),OrderLots(),Price,3,White);
            num++;
         }
         
   }
}

//+------------------------------------------------------------------+
//| СТАРТ - поехали                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double RSI[100];
   int limit = MathMax(MA_Per,Bands_Per)+RSI_Per-1;
   for(int i=limit;i>=0;i--) 
      RSI[i] = iRSI(NULL,0,RSI_Per,PRICE_CLOSE,i);
   double MA_Price = iMA(NULL,0,MA_Per,0,SmoothType,PRICE_CLOSE,0);
   double MA = iMAOnArray(RSI,MA_Per,MA_Per,0,SmoothType,0);
   double Bands_Low = iBandsOnArray(RSI,Bands_Per,Bands_Per,1,0,MODE_LOWER,0);
   double Bands_Up = iBandsOnArray(RSI,Bands_Per,Bands_Per,1,0,MODE_UPPER,0);
   double Delta = Bands_Up-Bands_Low; 
   if (RSI[0]<Band_Range && RSI[0]<MA && RSI[0]>RSI[1] && RSI[1]>RSI[2] && Close[0]<=MA_Price)
      {     
         CloseOrders(OP_SELL,Bid);                    // Закрыть короткие позиции
         OpenOrders(1, Ask, Blue, Delta);             // Открыть длинную позицию   
      }
   if (RSI[0]>100-Band_Range && RSI[0]>MA  && RSI[0]<RSI[1] && RSI[1]<RSI[2]&& Close[0]>=MA_Price)
      {
          CloseOrders(OP_BUY, Ask);                     // Закрыть длинные позиции 
          OpenOrders(-1, Bid, Red, Delta);              // Открыть короткую позицию
      }   
    ModifyOrder(Delta);                                 // Передвинуть StopLoss
  }  
//+------------------------------------------------------------------+


