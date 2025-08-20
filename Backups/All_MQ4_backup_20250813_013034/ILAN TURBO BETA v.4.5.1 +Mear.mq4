// Оригинал (идея): Ilan turbo beta 4.5.1 from Geret
// Модификация: Mear (очистка кода, фикс ошибок, реорганизация)

#property copyright "Copyright © 2011, Mear"
#property link      "http://mear.me"

extern double LotExponent       = 1.59;
extern bool   DynamicPips       = True;
extern int    DefaultPips       = 22;
extern double Slip              = 3.0;
extern double Lots              = 0.1;
extern double TakeProfit        = 20.0;
extern double RsiMinimum        = 30.0;
extern double RsiMaximum        = 70.0;
extern int    MagicNumber       = 1111;
extern int    MaxTrades         = 12;

int           lastTime          = 0;
double        pipPos;

int           magicNumber[2]    = {0, 0};
int           cntTradesPrev[2]  = {0, 0};

#define       SIDE_A              0
#define       SIDE_B              1

int init()
{
  // Формируем меджик для обоих сторон  
  magicNumber[SIDE_A] = MagicNumber * 2 + SIDE_A;
  magicNumber[SIDE_B] = MagicNumber * 2 + SIDE_B;
  
  ObjectCreate("label_str1", OBJ_LABEL, 0, 0, 0);
  ObjectSetText("label_str1", "Ilan turbo beta v4.5.1 by Geret (+Mear)", 14, "Aria", LawnGreen);
  ObjectSet("label_str1", OBJPROP_CORNER, 1);
  ObjectSet("label_str1", OBJPROP_XDISTANCE, 10);
  ObjectSet("label_str1", OBJPROP_YDISTANCE, 20);

  ObjectCreate("label_str2", OBJ_LABEL, 0, 0, 0);
  ObjectSetText("label_str2", "____________________________________________", 14, "Aria", Red);
  ObjectSet("label_str2", OBJPROP_CORNER, 1);
  ObjectSet("label_str2", OBJPROP_XDISTANCE, 1);
  ObjectSet("label_str2", OBJPROP_YDISTANCE, 25);
  
  ObjectCreate("label_balance", OBJ_LABEL, 0, 0, 0);
  ObjectSetText("label_balance", "Баланс счета: " + DoubleToStr(AccountBalance(), 2), 14, "Aria", Yellow);
  ObjectSet("label_balance", OBJPROP_CORNER, 1);
  ObjectSet("label_balance", OBJPROP_XDISTANCE, 10);
  ObjectSet("label_balance", OBJPROP_YDISTANCE, 50);
  
  ObjectCreate("label_equity", OBJ_LABEL, 0, 0, 0);
  ObjectSetText("label_equity", "Свободные средства: " + DoubleToStr(AccountEquity(), 2), 14, "Aria", Yellow);
  ObjectSet("label_equity", OBJPROP_CORNER, 1);
  ObjectSet("label_equity", OBJPROP_XDISTANCE, 10);
  ObjectSet("label_equity", OBJPROP_YDISTANCE, 70);
  
  ObjectCreate("label_countA", OBJ_LABEL, 0, 0, 0);
  ObjectSetText("label_countA", "Серия А: " + CountTrades(SIDE_A) + " (" + DoubleToStr(ProfitTrades(SIDE_A), 2) + ")", 14, "Aria", Yellow);
  ObjectSet("label_countA", OBJPROP_CORNER, 1);
  ObjectSet("label_countA", OBJPROP_XDISTANCE, 10);
  ObjectSet("label_countA", OBJPROP_YDISTANCE, 90);
  
  ObjectCreate("label_countB", OBJ_LABEL, 0, 0, 0);
  ObjectSetText("label_countB", "Серия B: " + CountTrades(SIDE_B) + " (" + DoubleToStr(ProfitTrades(SIDE_B), 2) + ")", 14, "Aria", Yellow);
  ObjectSet("label_countB", OBJPROP_CORNER, 1);
  ObjectSet("label_countB", OBJPROP_XDISTANCE, 10);
  ObjectSet("label_countB", OBJPROP_YDISTANCE, 110);
  
  ObjectCreate("label_str3", OBJ_LABEL, 0, 0, 0);
  ObjectSetText("label_str3", "____________________________________________", 14, "Aria", Red);
  ObjectSet("label_str3", OBJPROP_CORNER, 1);
  ObjectSet("label_str3", OBJPROP_XDISTANCE, 1);
  ObjectSet("label_str3", OBJPROP_YDISTANCE, 115);
  
  return (0);
}

int deinit()
{
  // За собой надо убирать!
  ObjectsDeleteAll(0);
  
  return (0);
}

int start()
{
  // Обновляем текст
  ObjectSetText("label_balance", "Баланс счета: " + DoubleToStr(AccountBalance(), 2), 14, "Aria", Yellow);
  ObjectSetText("label_equity", "Свободные средства: " + DoubleToStr(AccountEquity(), 2), 14, "Aria", Yellow);
  ObjectSetText("label_countA", "Серия А: " + CountTrades(SIDE_A) + " (" + DoubleToStr(ProfitTrades(SIDE_A), 2) + ")", 14, "Aria", Yellow);
  ObjectSetText("label_countB", "Серия B: " + CountTrades(SIDE_B) + " (" + DoubleToStr(ProfitTrades(SIDE_B), 2) + ")", 14, "Aria", Yellow);
  
  // Пропускаем, если бар не сменился
  if (lastTime == Time[0]) return;
  lastTime = Time[0];
  
  // Определяем размер шага колена
  if (DynamicPips)
  {
    double dpHigh = High[iHighest(NULL, 0, MODE_HIGH, 36, 1)];
    double dpLow  = Low[iLowest(NULL, 0, MODE_LOW, 36, 1)];
   
    pipPos = NormalizeDouble((dpHigh - dpLow) / 3.0 / Point, 2);

    // Шаг колена не может быть больше, чем двойной размер указанного шага
    if (pipPos < DefaultPips / 2) pipPos = DefaultPips / 2;
    if (pipPos > 2 * DefaultPips) pipPos = DefaultPips * 2;
  }
  else
  {
    pipPos = DefaultPips;
  }
  
  // Обрабатываем стороны
  processSide(SIDE_A);
  processSide(SIDE_B);
 
  return (0);
}

// Обработка указанной стороны
void processSide(int aSide)
{
  int    i;
  
  // Отмечаем, что мы не имеем (или не знаем о них) сделок по SELL и BUY
  bool   haveBuy     = False;
  bool   haveSell    = False;

  // Подсчитываем количество сделок на нашей стороне
  int    countTrades = CountTrades(aSide);
  
  // Подсчитываем размер нового лота
  double newLots     = Lots * MathPow(LotExponent, countTrades);
  
  if (countTrades == 0)
  {
    // Количество сделок равно нулю, значит начинаем новую серию
    
    // Определяем сторону движения
    if (iClose(Symbol(), 0, 2) < iClose(Symbol(), 0, 1))
    {
      // Если противоположная сторона не открылась и характеристики по RSI удовлетворяют требованию, то открываем сделки
      if ((FindLastBuyPrice(OtherSide(aSide)) == 0) && (iRSI(Symbol(), PERIOD_H1, 14, PRICE_CLOSE, 1) < RsiMaximum))
      {
        // Открываем ордер на BUY на текущей позиции
        OpenOrder(aSide, OP_BUY, newLots, countTrades);
        
        // Отмечаем, что теперь имеем ордер BUY (т.е. данная серия - это серия BUY)
        haveBuy = True;
        
        // Увеличиваем количество сделок
        countTrades++;
      }
    }
    else
    {
      // Если противоположная сторона не открылась и характеристики по RSI удовлетворяют требованию, то открываем сделки
      if ((FindLastSellPrice(OtherSide(aSide)) == 0) && (iRSI(Symbol(), PERIOD_H1, 14, PRICE_CLOSE, 1) > RsiMinimum))
      {
        // Открываем ордер на SELL на текущей позиции
        OpenOrder(aSide, OP_SELL, newLots, countTrades);
        
        // Отмечаем, что теперь имеем ордер SELL (т.е. данная серия - это серия SELL)
        haveSell    = True;
        
        // Увеличиваем количество сделок
        countTrades++;
      }
    }
  }
  else if (countTrades <= MaxTrades)
  {
    // Если количество сделок не превышает максимум, то имеет смысл открывать новые колени для мартина
    
    // Проходим по списку ордеров для определения стороны текущей серии
    for (i = OrdersTotal() - 1; i >= 0; i--)
    {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
    
      // Пропускаем ордера не относящиеся к нашей валюте и к нашей серии
      if ((OrderSymbol() != Symbol()) || (OrderMagicNumber() != magicNumber[aSide])) continue;
    
      if (OrderType() == OP_BUY)
      {
        // Встретили ордер BUY, значит и наша серия - BUY. В дальнейшем поиске нет нужды
        haveBuy  = True;
      
        break;
      }
      else if (OrderType() == OP_SELL)
      {
        // Встретили ордер SELL, значит и наша серия - SELL. В дальнейшем поиске нет нужды
        haveSell = True;
      
        break;
      }
    }

    //Если расстояние от ближайшей сделки больше необходимого, то открываем новое колено
    if (haveBuy && (FindLastBuyPrice(aSide) - Ask >= pipPos * Point))
    {
      // Открываем ордер на BUY на текущей позиции
      OpenOrder(aSide, OP_BUY, newLots, countTrades);

      // Увеличиваем количество сделок
      countTrades++;
    }
    else if (haveSell && (Bid - FindLastSellPrice(aSide) >= pipPos * Point))
    {
      // Открываем ордер на SELL на текущей позиции
      OpenOrder(aSide, OP_SELL, newLots, countTrades);

      // Увеличиваем количество сделок
      countTrades++;
    }
  }

  // Если количество сделок более 0 и с предыдущего раза их количество изменилось, то значит пора менять стопы
  if ((countTrades > 0) && (countTrades != cntTradesPrev[aSide]))
  {
    // Запоминаем текущее количество сделок
    cntTradesPrev[aSide] = countTrades;
    
    double summPrice = 0;
    double summLots  = 0;
  
    // Проходим по списку ордеров для подсчета зоны безубытка
    for (i = OrdersTotal() - 1; i >= 0; i--)
    {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
    
      // Пропускаем ордера не относящиеся к нашей валюте и к нашей серии
      if ((OrderSymbol() != Symbol()) || (OrderMagicNumber() != magicNumber[aSide])) continue;
    
      // К текущему моменту мы можем не знать, какой серией мы играем, так что по возможности отметим это
      if (OrderType() == OP_BUY)  haveBuy  = True;
      if (OrderType() == OP_SELL) haveSell = True;
    
      // Подсчитываем объемы сделок и лотов
      summPrice += OrderOpenPrice() * OrderLots();
      summLots  += OrderLots();  
    }

    // Подсчитываем зону безубыточности (та цена, в которой мартин из убыточного превратиться в прибыльный)
    summPrice = NormalizeDouble(summPrice / summLots, Digits);

    double newTakeProfit = 0;
    
    // Определяем новый тейкПрофит в зависимости от типа серии (BUY или SELL)  
    if (haveBuy)
    {
      newTakeProfit = summPrice + TakeProfit * Point;
    }
    else if (haveSell)
    {
      newTakeProfit = summPrice - TakeProfit * Point;
    }

    // Проходим по списку ордеров меняя тейкПрофит у всех кроме последнего
    for (i = OrdersTotal() - 2; i >= 0; i--)
    {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
  
      // Пропускаем ордера не относящиеся к нашей валюте и к нашей серии
      if ((OrderSymbol() != Symbol()) || (OrderMagicNumber() != magicNumber[aSide])) continue;
  
      // Пропускаем ордер, если его тейкПрофит и так соответствует нужному
      if (NormalizeDouble(OrderTakeProfit() - newTakeProfit, Digits) == 0) continue;

      // Изменяем тейкПрофит
      OrderModify(OrderTicket(), NormalizeDouble(OrderOpenPrice(), Digits), NormalizeDouble(OrderStopLoss(), Digits), NormalizeDouble(newTakeProfit, Digits), 0, Yellow);
    }
  }
}

// Подсчет количества сделок на указанной стороне
int CountTrades(int aSide)
{
  int count = 0;

  // Проходим по списку ордеров..
  for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
   
    // Пропускаем ордера не относящиеся к нашей валюте и к нашей серии
    if ((OrderSymbol() != Symbol()) || (OrderMagicNumber() != magicNumber[aSide])) continue;

    count++;
  }
  
  return (count);
}

// Подсчет текущей прибыльности серии
double ProfitTrades(int aSide)
{
  double profit = 0;

  // Проходим по списку ордеров..
  for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
   
    // Пропускаем ордера не относящиеся к нашей валюте и к нашей серии
    if ((OrderSymbol() != Symbol()) || (OrderMagicNumber() != magicNumber[aSide])) continue;

    profit += OrderProfit() + OrderCommission() + OrderSwap();
  }
  
  return (profit);
}

// Нахождение последней цены покупки
double FindLastBuyPrice(int aSide)
{
  // Проходим по списку ордеров с конца, так как именно последняя цена будет в самом конце
  for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
    
    // Пропускаем ордера не относящиеся к нашей валюте, серии или типу искомой сделки
    if ((OrderSymbol() != Symbol()) || (OrderMagicNumber() != magicNumber[aSide]) || (OrderType() != OP_BUY)) continue;
    
    // Возвращаем найденную цену
    return (OrderOpenPrice());
  }
  
  return (0);
}

// Нахождение последней цены продажи
double FindLastSellPrice(int aSide)
{
  // Проходим по списку ордеров с конца, так как именно последняя цена будет в самом конце
  for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
    
    // Пропускаем ордера не относящиеся к нашей валюте, серии или типу искомой сделки
    if ((OrderSymbol() != Symbol()) || (OrderMagicNumber() != magicNumber[aSide]) || (OrderType() != OP_SELL)) continue;
    
    return (OrderOpenPrice());
  }
  
  return (0);
}

// Открытие ордера
int OpenOrder(int aSide, int aType, double aLots, string aComment)
{
  int ticket    = 0;
  int lastError = 0;
  int i;
  int maxTry    = 100;
  
  switch (aType)
  {
    case OP_BUY:
    {
      // Цикл попыток открытия ордера
      for (i = 0; i < maxTry; i++)
      {
        // Открываем ордер
        ticket = OrderSend(Symbol(), OP_BUY, NormalizeLots(aLots), NormalizeDouble(Ask, Digits), Slip, 0, NormalizeDouble(Bid + TakeProfit * Point, Digits), aComment, magicNumber[aSide], 0, Lime);
        
        lastError = GetLastError();
        
        // Если не получили ошибки, то выходим из цикла
        if (lastError == 0/* NO_ERROR */) break;
        
        // Если ошибка фатальная, то выходим из цикла (нет смысла ждать)
        if (!((lastError == 4/* SERVER_BUSY */ || lastError == 137/* BROKER_BUSY */ || lastError == 146/* TRADE_CONTEXT_BUSY */ || lastError == 136/* OFF_QUOTES */))) break;
        
        Sleep(1000);
        
        RefreshRates();
      }
      
      // Если противоположная серия пуста, то пытаемся открыть обратную сделку
      if (CountTrades(OtherSide(aSide)) == 0)
      {
        // Цикл попыток открытия ордера
        for (i = 0; i < maxTry; i++)
        {
          // Открываем ордер
          OrderSend(Symbol(), OP_SELL, NormalizeLots(aLots), NormalizeDouble(Bid, Digits), Slip, 0, NormalizeDouble(Ask - TakeProfit * Point, Digits), aComment, magicNumber[OtherSide(aSide)], 0, HotPink);
       
          lastError = GetLastError();
          
          // Если не получили ошибки, то выходим из цикла
          if (lastError == 0/* NO_ERROR */) break;
          
          // Если ошибка фатальная, то выходим из цикла (нет смысла ждать)
          if (!(((lastError == 4/* SERVER_BUSY */) || (lastError == 137/* BROKER_BUSY */) || (lastError == 146/* TRADE_CONTEXT_BUSY */) || (lastError == 136/* OFF_QUOTES */)))) break;
        
          Sleep(1000);
        
          RefreshRates();
        }
      }
    } break;
    case OP_SELL:
    {
      // Цикл попыток открытия ордера
      for (i = 0; i < maxTry; i++)
      {
         // Открываем ордер
         ticket = OrderSend(Symbol(), OP_SELL, NormalizeLots(aLots), NormalizeDouble(Bid, Digits), Slip, 0, NormalizeDouble(Ask - TakeProfit * Point, Digits), aComment, magicNumber[aSide], 0, HotPink);
         
         lastError = GetLastError();
         
         // Если не получили ошибки, то выходим из цикла
         if (lastError == 0/* NO_ERROR */) break;
         
         // Если ошибка фатальная, то выходим из цикла (нет смысла ждать)
         if (!(((lastError == 4/* SERVER_BUSY */) || (lastError == 137/* BROKER_BUSY */) || (lastError == 146/* TRADE_CONTEXT_BUSY */) || (lastError == 136/* OFF_QUOTES */)))) break;
         
         Sleep(1000);
         
         RefreshRates();
      }
      
      // Если противоположная серия пуста, то пытаемся открыть обратную сделку
      if (CountTrades(OtherSide(aSide)) == 0)
      {
        // Цикл попыток открытия ордера
        for (i = 0; i < maxTry; i++)
        {
          // Открываем ордер
          OrderSend(Symbol(), OP_BUY, NormalizeLots(aLots), NormalizeDouble(Ask, Digits), Slip, 0, NormalizeDouble(Bid + TakeProfit * Point, Digits), aComment, magicNumber[OtherSide(aSide)], 0, Lime);
        
          lastError = GetLastError();
          
          // Если не получили ошибки, то выходим из цикла
          if (lastError == 0/* NO_ERROR */) break;
          
          // Если ошибка фатальная, то выходим из цикла (нет смысла ждать)
          if (!(((lastError == 4/* SERVER_BUSY */) || (lastError == 137/* BROKER_BUSY */) || (lastError == 146/* TRADE_CONTEXT_BUSY */) || (lastError == 136/* OFF_QUOTES */)))) break;
        
          Sleep(1000);
        
          RefreshRates();
        }
      }
    } break;
  }
  
  return (ticket);
}

// Получение другой стороны
int OtherSide(int aSide)
{
  switch (aSide)
  {
    case SIDE_A: return (SIDE_B); break;
    case SIDE_B: return (SIDE_A); break;
  }
}

// Нормализация лота согласна условиям торговли
double NormalizeLots(double aLots)
{
  double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
  double minLot  = MarketInfo(Symbol(), MODE_MINLOT);
  double maxLot  = MarketInfo(Symbol(), MODE_MAXLOT);
  
  // Лот должен соответствовать кратности LOTSTEP
  aLots = MathRound(aLots / lotStep) * lotStep;
  
  // Лот должен быть не меньше MINLOT
  if (aLots < minLot) return (minLot);
  
  // Лот должен быть не больше MAXLOT
  if (aLots > maxLot) return (maxLot);
  
  return (aLots);
}