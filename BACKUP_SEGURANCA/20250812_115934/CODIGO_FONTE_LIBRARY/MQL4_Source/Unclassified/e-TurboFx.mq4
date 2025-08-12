
#property copyright "© 2007 RickD"
#property link      "www.e2e-fx.net"

#define major   1
#define minor   0

extern string _tmp1_ = " --- Параметры эксперта ---";
extern int N = 3;
extern double Lots = 0.1;
extern int StopLoss = 70;
extern int TakeProfit = 120;
extern int Slippage = 3;
extern int Magic = 50607;

extern string _tmp2_ = " --- Цвет стрелок на чарте  ---";
extern color clBuy = DodgerBlue;
extern color clSell = Crimson;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#include <stdlib.mqh>
#include <stderror.mqh>

void init () 
{
}

void deinit() 
{
}

void start() 
{ 
  int BuyCnt = 0;
  int SellCnt = 0;
  
  int cnt = OrdersTotal();
  for (int i=0; i < cnt; i++) 
  {
    if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
    if (OrderSymbol() != Symbol()) continue;
    if (OrderMagicNumber() != Magic) continue;
    
    int type = OrderType();
    if (type == OP_BUY) BuyCnt++;
    if (type == OP_SELL) SellCnt++;
  }
  
  if (BuyCnt > 0 || SellCnt > 0) return;

  //-----

  int up_1 = 0;
  int up_2 = 0;
  int dw_1 = 0;
  int dw_2 = 0;

  for (i = 1; i <= N; i++)
  {
    if (Close[i] < Open[i]) up_1++;
    if (Close[i] > Open[i]) dw_1++;
    
    if (i < N)
    {
      if (MathAbs(Close[i]-Open[i]) > MathAbs(Close[i+1]-Open[i+1]))
      {
        up_2++;
        dw_2++;
      }
    }
  }

  //-----
  
  double price, sl, tp;
  
  if (up_1 == N && up_2 == N-1)
  {
    price = Ask;
  
    sl = If(StopLoss > 0, price - StopLoss*Point, 0);
    tp = If(TakeProfit > 0, price + TakeProfit*Point, 0);

    Buy(Symbol(), GetLots(), price, sl, tp, Magic);
    return;
  }

  if (dw_1 == N && dw_2 == N-1)
  {
    price = Bid;
    
    sl = If(StopLoss > 0, price + StopLoss*Point, 0);
    tp = If(TakeProfit > 0, price - TakeProfit*Point, 0);

    Sell(Symbol(), GetLots(), price, sl, tp, Magic);
    return;
  } 
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

double GetLots() 
{
  return (Lots);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

double If(bool cond, double if_true, double if_false)
{
  if (cond) return (if_true);
  return (if_false);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int SleepOk = 2000;
int SleepErr = 6000;

int Buy(string symbol, double lot, double price, double sl, double tp, int magic, string comment="") 
{
  int dig = MarketInfo(symbol, MODE_DIGITS);

  price = NormalizeDouble(price, dig);
  sl = NormalizeDouble(sl, dig);
  tp = NormalizeDouble(tp, dig);
    
  string _lot = DoubleToStr(lot, 1);
  string _price = DoubleToStr(price, dig);
  string _sl = DoubleToStr(sl, dig);
  string _tp = DoubleToStr(tp, dig);

  Print("Buy \"", symbol, "\", ", _lot, ", ", _price, ", ", Slippage, ", ", _sl, ", ", _tp, ", ", magic, ", \"", comment, "\"");

  int res = OrderSend(symbol, OP_BUY, lot, price, Slippage, sl, tp, comment, magic, 0, clBuy);
  if (res >= 0) {
    Sleep(SleepOk);
    return (res);
  } 	
   	
  int code = GetLastError();
  Print("Error opening BUY order: ", ErrorDescription(code), " (", code, ")");
  Sleep(SleepErr);
	
  return (-1);
}

int Sell(string symbol, double lot, double price, double sl, double tp, int magic, string comment="") 
{
  int dig = MarketInfo(symbol, MODE_DIGITS);

  price = NormalizeDouble(price, dig);
  sl = NormalizeDouble(sl, dig);
  tp = NormalizeDouble(tp, dig);
  
  string _lot = DoubleToStr(lot, 1);
  string _price = DoubleToStr(price, dig);
  string _sl = DoubleToStr(sl, dig);
  string _tp = DoubleToStr(tp, dig);

  Print("Sell \"", symbol, "\", ", _lot, ", ", _price, ", ", Slippage, ", ", _sl, ", ", _tp, ", ", magic, ", \"", comment, "\"");
  
  int res = OrderSend(symbol, OP_SELL, lot, price, Slippage, sl, tp, comment, magic, 0, clSell);
  if (res >= 0) {
    Sleep(SleepOk);
    return (res);
  } 	
   	
  int code = GetLastError();
  Print("Error opening SELL order: ", ErrorDescription(code), " (", code, ")");
  Sleep(SleepErr);
	
  return (-1);
}

