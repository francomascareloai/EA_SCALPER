// �������� (����): Ilan turbo beta 4.5.1 from Geret
// �����������: Mear (������� ����, ���� ������, �������������)

#property copyright "Copyright � 2011, Mear"
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
  // ��������� ������ ��� ����� ������  
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
  ObjectSetText("label_balance", "������ �����: " + DoubleToStr(AccountBalance(), 2), 14, "Aria", Yellow);
  ObjectSet("label_balance", OBJPROP_CORNER, 1);
  ObjectSet("label_balance", OBJPROP_XDISTANCE, 10);
  ObjectSet("label_balance", OBJPROP_YDISTANCE, 50);
  
  ObjectCreate("label_equity", OBJ_LABEL, 0, 0, 0);
  ObjectSetText("label_equity", "��������� ��������: " + DoubleToStr(AccountEquity(), 2), 14, "Aria", Yellow);
  ObjectSet("label_equity", OBJPROP_CORNER, 1);
  ObjectSet("label_equity", OBJPROP_XDISTANCE, 10);
  ObjectSet("label_equity", OBJPROP_YDISTANCE, 70);
  
  ObjectCreate("label_countA", OBJ_LABEL, 0, 0, 0);
  ObjectSetText("label_countA", "����� �: " + CountTrades(SIDE_A) + " (" + DoubleToStr(ProfitTrades(SIDE_A), 2) + ")", 14, "Aria", Yellow);
  ObjectSet("label_countA", OBJPROP_CORNER, 1);
  ObjectSet("label_countA", OBJPROP_XDISTANCE, 10);
  ObjectSet("label_countA", OBJPROP_YDISTANCE, 90);
  
  ObjectCreate("label_countB", OBJ_LABEL, 0, 0, 0);
  ObjectSetText("label_countB", "����� B: " + CountTrades(SIDE_B) + " (" + DoubleToStr(ProfitTrades(SIDE_B), 2) + ")", 14, "Aria", Yellow);
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
  // �� ����� ���� �������!
  ObjectsDeleteAll(0);
  
  return (0);
}

int start()
{
  // ��������� �����
  ObjectSetText("label_balance", "������ �����: " + DoubleToStr(AccountBalance(), 2), 14, "Aria", Yellow);
  ObjectSetText("label_equity", "��������� ��������: " + DoubleToStr(AccountEquity(), 2), 14, "Aria", Yellow);
  ObjectSetText("label_countA", "����� �: " + CountTrades(SIDE_A) + " (" + DoubleToStr(ProfitTrades(SIDE_A), 2) + ")", 14, "Aria", Yellow);
  ObjectSetText("label_countB", "����� B: " + CountTrades(SIDE_B) + " (" + DoubleToStr(ProfitTrades(SIDE_B), 2) + ")", 14, "Aria", Yellow);
  
  // ����������, ���� ��� �� ��������
  if (lastTime == Time[0]) return;
  lastTime = Time[0];
  
  // ���������� ������ ���� ������
  if (DynamicPips)
  {
    double dpHigh = High[iHighest(NULL, 0, MODE_HIGH, 36, 1)];
    double dpLow  = Low[iLowest(NULL, 0, MODE_LOW, 36, 1)];
   
    pipPos = NormalizeDouble((dpHigh - dpLow) / 3.0 / Point, 2);

    // ��� ������ �� ����� ���� ������, ��� ������� ������ ���������� ����
    if (pipPos < DefaultPips / 2) pipPos = DefaultPips / 2;
    if (pipPos > 2 * DefaultPips) pipPos = DefaultPips * 2;
  }
  else
  {
    pipPos = DefaultPips;
  }
  
  // ������������ �������
  processSide(SIDE_A);
  processSide(SIDE_B);
 
  return (0);
}

// ��������� ��������� �������
void processSide(int aSide)
{
  int    i;
  
  // ��������, ��� �� �� ����� (��� �� ����� � ���) ������ �� SELL � BUY
  bool   haveBuy     = False;
  bool   haveSell    = False;

  // ������������ ���������� ������ �� ����� �������
  int    countTrades = CountTrades(aSide);
  
  // ������������ ������ ������ ����
  double newLots     = Lots * MathPow(LotExponent, countTrades);
  
  if (countTrades == 0)
  {
    // ���������� ������ ����� ����, ������ �������� ����� �����
    
    // ���������� ������� ��������
    if (iClose(Symbol(), 0, 2) < iClose(Symbol(), 0, 1))
    {
      // ���� ��������������� ������� �� ��������� � �������������� �� RSI ������������� ����������, �� ��������� ������
      if ((FindLastBuyPrice(OtherSide(aSide)) == 0) && (iRSI(Symbol(), PERIOD_H1, 14, PRICE_CLOSE, 1) < RsiMaximum))
      {
        // ��������� ����� �� BUY �� ������� �������
        OpenOrder(aSide, OP_BUY, newLots, countTrades);
        
        // ��������, ��� ������ ����� ����� BUY (�.�. ������ ����� - ��� ����� BUY)
        haveBuy = True;
        
        // ����������� ���������� ������
        countTrades++;
      }
    }
    else
    {
      // ���� ��������������� ������� �� ��������� � �������������� �� RSI ������������� ����������, �� ��������� ������
      if ((FindLastSellPrice(OtherSide(aSide)) == 0) && (iRSI(Symbol(), PERIOD_H1, 14, PRICE_CLOSE, 1) > RsiMinimum))
      {
        // ��������� ����� �� SELL �� ������� �������
        OpenOrder(aSide, OP_SELL, newLots, countTrades);
        
        // ��������, ��� ������ ����� ����� SELL (�.�. ������ ����� - ��� ����� SELL)
        haveSell    = True;
        
        // ����������� ���������� ������
        countTrades++;
      }
    }
  }
  else if (countTrades <= MaxTrades)
  {
    // ���� ���������� ������ �� ��������� ��������, �� ����� ����� ��������� ����� ������ ��� �������
    
    // �������� �� ������ ������� ��� ����������� ������� ������� �����
    for (i = OrdersTotal() - 1; i >= 0; i--)
    {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
    
      // ���������� ������ �� ����������� � ����� ������ � � ����� �����
      if ((OrderSymbol() != Symbol()) || (OrderMagicNumber() != magicNumber[aSide])) continue;
    
      if (OrderType() == OP_BUY)
      {
        // ��������� ����� BUY, ������ � ���� ����� - BUY. � ���������� ������ ��� �����
        haveBuy  = True;
      
        break;
      }
      else if (OrderType() == OP_SELL)
      {
        // ��������� ����� SELL, ������ � ���� ����� - SELL. � ���������� ������ ��� �����
        haveSell = True;
      
        break;
      }
    }

    //���� ���������� �� ��������� ������ ������ ������������, �� ��������� ����� ������
    if (haveBuy && (FindLastBuyPrice(aSide) - Ask >= pipPos * Point))
    {
      // ��������� ����� �� BUY �� ������� �������
      OpenOrder(aSide, OP_BUY, newLots, countTrades);

      // ����������� ���������� ������
      countTrades++;
    }
    else if (haveSell && (Bid - FindLastSellPrice(aSide) >= pipPos * Point))
    {
      // ��������� ����� �� SELL �� ������� �������
      OpenOrder(aSide, OP_SELL, newLots, countTrades);

      // ����������� ���������� ������
      countTrades++;
    }
  }

  // ���� ���������� ������ ����� 0 � � ����������� ���� �� ���������� ����������, �� ������ ���� ������ �����
  if ((countTrades > 0) && (countTrades != cntTradesPrev[aSide]))
  {
    // ���������� ������� ���������� ������
    cntTradesPrev[aSide] = countTrades;
    
    double summPrice = 0;
    double summLots  = 0;
  
    // �������� �� ������ ������� ��� �������� ���� ���������
    for (i = OrdersTotal() - 1; i >= 0; i--)
    {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
    
      // ���������� ������ �� ����������� � ����� ������ � � ����� �����
      if ((OrderSymbol() != Symbol()) || (OrderMagicNumber() != magicNumber[aSide])) continue;
    
      // � �������� ������� �� ����� �� �����, ����� ������ �� ������, ��� ��� �� ����������� ������� ���
      if (OrderType() == OP_BUY)  haveBuy  = True;
      if (OrderType() == OP_SELL) haveSell = True;
    
      // ������������ ������ ������ � �����
      summPrice += OrderOpenPrice() * OrderLots();
      summLots  += OrderLots();  
    }

    // ������������ ���� �������������� (�� ����, � ������� ������ �� ���������� ������������ � ����������)
    summPrice = NormalizeDouble(summPrice / summLots, Digits);

    double newTakeProfit = 0;
    
    // ���������� ����� ���������� � ����������� �� ���� ����� (BUY ��� SELL)  
    if (haveBuy)
    {
      newTakeProfit = summPrice + TakeProfit * Point;
    }
    else if (haveSell)
    {
      newTakeProfit = summPrice - TakeProfit * Point;
    }

    // �������� �� ������ ������� ����� ���������� � ���� ����� ����������
    for (i = OrdersTotal() - 2; i >= 0; i--)
    {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
  
      // ���������� ������ �� ����������� � ����� ������ � � ����� �����
      if ((OrderSymbol() != Symbol()) || (OrderMagicNumber() != magicNumber[aSide])) continue;
  
      // ���������� �����, ���� ��� ���������� � ��� ������������� �������
      if (NormalizeDouble(OrderTakeProfit() - newTakeProfit, Digits) == 0) continue;

      // �������� ����������
      OrderModify(OrderTicket(), NormalizeDouble(OrderOpenPrice(), Digits), NormalizeDouble(OrderStopLoss(), Digits), NormalizeDouble(newTakeProfit, Digits), 0, Yellow);
    }
  }
}

// ������� ���������� ������ �� ��������� �������
int CountTrades(int aSide)
{
  int count = 0;

  // �������� �� ������ �������..
  for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
   
    // ���������� ������ �� ����������� � ����� ������ � � ����� �����
    if ((OrderSymbol() != Symbol()) || (OrderMagicNumber() != magicNumber[aSide])) continue;

    count++;
  }
  
  return (count);
}

// ������� ������� ������������ �����
double ProfitTrades(int aSide)
{
  double profit = 0;

  // �������� �� ������ �������..
  for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
   
    // ���������� ������ �� ����������� � ����� ������ � � ����� �����
    if ((OrderSymbol() != Symbol()) || (OrderMagicNumber() != magicNumber[aSide])) continue;

    profit += OrderProfit() + OrderCommission() + OrderSwap();
  }
  
  return (profit);
}

// ���������� ��������� ���� �������
double FindLastBuyPrice(int aSide)
{
  // �������� �� ������ ������� � �����, ��� ��� ������ ��������� ���� ����� � ����� �����
  for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
    
    // ���������� ������ �� ����������� � ����� ������, ����� ��� ���� ������� ������
    if ((OrderSymbol() != Symbol()) || (OrderMagicNumber() != magicNumber[aSide]) || (OrderType() != OP_BUY)) continue;
    
    // ���������� ��������� ����
    return (OrderOpenPrice());
  }
  
  return (0);
}

// ���������� ��������� ���� �������
double FindLastSellPrice(int aSide)
{
  // �������� �� ������ ������� � �����, ��� ��� ������ ��������� ���� ����� � ����� �����
  for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
    
    // ���������� ������ �� ����������� � ����� ������, ����� ��� ���� ������� ������
    if ((OrderSymbol() != Symbol()) || (OrderMagicNumber() != magicNumber[aSide]) || (OrderType() != OP_SELL)) continue;
    
    return (OrderOpenPrice());
  }
  
  return (0);
}

// �������� ������
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
      // ���� ������� �������� ������
      for (i = 0; i < maxTry; i++)
      {
        // ��������� �����
        ticket = OrderSend(Symbol(), OP_BUY, NormalizeLots(aLots), NormalizeDouble(Ask, Digits), Slip, 0, NormalizeDouble(Bid + TakeProfit * Point, Digits), aComment, magicNumber[aSide], 0, Lime);
        
        lastError = GetLastError();
        
        // ���� �� �������� ������, �� ������� �� �����
        if (lastError == 0/* NO_ERROR */) break;
        
        // ���� ������ ���������, �� ������� �� ����� (��� ������ �����)
        if (!((lastError == 4/* SERVER_BUSY */ || lastError == 137/* BROKER_BUSY */ || lastError == 146/* TRADE_CONTEXT_BUSY */ || lastError == 136/* OFF_QUOTES */))) break;
        
        Sleep(1000);
        
        RefreshRates();
      }
      
      // ���� ��������������� ����� �����, �� �������� ������� �������� ������
      if (CountTrades(OtherSide(aSide)) == 0)
      {
        // ���� ������� �������� ������
        for (i = 0; i < maxTry; i++)
        {
          // ��������� �����
          OrderSend(Symbol(), OP_SELL, NormalizeLots(aLots), NormalizeDouble(Bid, Digits), Slip, 0, NormalizeDouble(Ask - TakeProfit * Point, Digits), aComment, magicNumber[OtherSide(aSide)], 0, HotPink);
       
          lastError = GetLastError();
          
          // ���� �� �������� ������, �� ������� �� �����
          if (lastError == 0/* NO_ERROR */) break;
          
          // ���� ������ ���������, �� ������� �� ����� (��� ������ �����)
          if (!(((lastError == 4/* SERVER_BUSY */) || (lastError == 137/* BROKER_BUSY */) || (lastError == 146/* TRADE_CONTEXT_BUSY */) || (lastError == 136/* OFF_QUOTES */)))) break;
        
          Sleep(1000);
        
          RefreshRates();
        }
      }
    } break;
    case OP_SELL:
    {
      // ���� ������� �������� ������
      for (i = 0; i < maxTry; i++)
      {
         // ��������� �����
         ticket = OrderSend(Symbol(), OP_SELL, NormalizeLots(aLots), NormalizeDouble(Bid, Digits), Slip, 0, NormalizeDouble(Ask - TakeProfit * Point, Digits), aComment, magicNumber[aSide], 0, HotPink);
         
         lastError = GetLastError();
         
         // ���� �� �������� ������, �� ������� �� �����
         if (lastError == 0/* NO_ERROR */) break;
         
         // ���� ������ ���������, �� ������� �� ����� (��� ������ �����)
         if (!(((lastError == 4/* SERVER_BUSY */) || (lastError == 137/* BROKER_BUSY */) || (lastError == 146/* TRADE_CONTEXT_BUSY */) || (lastError == 136/* OFF_QUOTES */)))) break;
         
         Sleep(1000);
         
         RefreshRates();
      }
      
      // ���� ��������������� ����� �����, �� �������� ������� �������� ������
      if (CountTrades(OtherSide(aSide)) == 0)
      {
        // ���� ������� �������� ������
        for (i = 0; i < maxTry; i++)
        {
          // ��������� �����
          OrderSend(Symbol(), OP_BUY, NormalizeLots(aLots), NormalizeDouble(Ask, Digits), Slip, 0, NormalizeDouble(Bid + TakeProfit * Point, Digits), aComment, magicNumber[OtherSide(aSide)], 0, Lime);
        
          lastError = GetLastError();
          
          // ���� �� �������� ������, �� ������� �� �����
          if (lastError == 0/* NO_ERROR */) break;
          
          // ���� ������ ���������, �� ������� �� ����� (��� ������ �����)
          if (!(((lastError == 4/* SERVER_BUSY */) || (lastError == 137/* BROKER_BUSY */) || (lastError == 146/* TRADE_CONTEXT_BUSY */) || (lastError == 136/* OFF_QUOTES */)))) break;
        
          Sleep(1000);
        
          RefreshRates();
        }
      }
    } break;
  }
  
  return (ticket);
}

// ��������� ������ �������
int OtherSide(int aSide)
{
  switch (aSide)
  {
    case SIDE_A: return (SIDE_B); break;
    case SIDE_B: return (SIDE_A); break;
  }
}

// ������������ ���� �������� �������� ��������
double NormalizeLots(double aLots)
{
  double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
  double minLot  = MarketInfo(Symbol(), MODE_MINLOT);
  double maxLot  = MarketInfo(Symbol(), MODE_MAXLOT);
  
  // ��� ������ ��������������� ��������� LOTSTEP
  aLots = MathRound(aLots / lotStep) * lotStep;
  
  // ��� ������ ���� �� ������ MINLOT
  if (aLots < minLot) return (minLot);
  
  // ��� ������ ���� �� ������ MAXLOT
  if (aLots > maxLot) return (maxLot);
  
  return (aLots);
}