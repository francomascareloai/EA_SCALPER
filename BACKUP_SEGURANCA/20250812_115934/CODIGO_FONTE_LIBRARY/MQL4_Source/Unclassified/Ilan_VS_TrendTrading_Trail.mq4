//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
#property copyright "" 
#property link      ""
#include <stderror.mqh>
#include <stdlib.mqh>

//ннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
double Stoploss = 500.0;            // уровень безубытка
double TrailStart = 10.0;
double TrailStop = 10.0;
//ннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
string w1 = "Тип Exponent 0-арифметика/1-арифметика/2-геометрия";
int    TypeLotExponent = 0;  //Тип экспоненты:
                                       //0-арифметика (1-й способ)с каждым коленом увеличиваем Exponent на Lots
                                       //1-арифметика (2-й способ)с каждым коленом увеличиваем Exponent на LotExponent
                                       //2-геометрия с каждым коленом увеличиваем Exponent в LotExponent-раз
double LotExponent = 1.4;              // на сколько умножать лот при выставлении следующего колена. пример: первый лот 0.1, серия: 0.16, 0.26, 0.43 ...
extern double  PipStepExponent = 1;     //Коэффициент увеличения пипстепа
extern int     DefaultPips     = 50;    //Первоначальная величина PipStep
extern int     MaxPips         = 100;   //Максимольная величина PipStep
double         slip            = 4.0;   // на сколько может отличаться цена в случае если ДЦ запросит реквоты (в последний момент немного поменяет цену)
extern double  Lots            = 0.1;   // размер лота для начала торгов
extern int     lotdecimal      = 2;     // сколько знаков после запятой в лоте рассчитывать 0 - нормальные лоты (1), 1 - минилоты (0.1), 2 - микро (0.01)
extern int     Trail_TimeFrame    = 3;     // тайм фрейм Трала
                                          // 0 - текущий график
                                          // 1 - 1 мин
                                          // 2 - 5 мин
                                          // 3 - 15 мин
                                          // 4 - 30 мин
                                          // 5 - 1 час
                                          // 6 - 4 часа
                                          // 7 - 1 день
// extern int     TakeProfitFirstOrder      = 20.0;  // по достижении скольких пунктов прибыли закрывать сделку
// extern int     TakeProfitSeria      = 20.0;  // по достижении скольких пунктов прибыли закрывать серию
extern int     MA_TimeFrame    = 7;     // тайм фрейм МА
                                          // 0 - текущий график
                                          // 1 - 1 мин
                                          // 2 - 5 мин
                                          // 3 - 15 мин
                                          // 4 - 30 мин
                                          // 5 - 1 час
                                          // 6 - 4 часа
                                          // 7 - 1 день
extern int     MA_Period       = 6;     // Период МА
extern int     MA_Delta        = 3;     // На сколько должна измениться МА на соседних барах, чтобы сигнал сработал
extern int     CCIlevel = 160;          // отсечка по уровню CCI на дневках, если уровень превышен, то серия не будет открываться
extern int     MagicNumber = 2222;      // волшебное число (помогает советнику отличить свои ставки от чужих)
int PipStep=0;
//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
extern int MaxTrades = 10;                 // максимально количество одновременно открытых ордеров
//extern bool UseLastTradeTP = FALSE;     //Использовать ли режим отдельного выставления ТП на последний ордер
//extern int LastTradeNumber = 5;        //С какого колена использовать выставление отдельны ТП на последний ордер         
//-----------------------------------------------------------------------------------------------------------+BosSLtd
extern bool    MM             = false;
extern double  risk           = 1;    // ММ 0.01 - итд.
extern int     balans         = 1000; // баланс реинвестирования, на каждую 1000 депо будет умножатся лот на риск
//-----------------------------------------------------------------------------------------------------------+BosSLtd
extern bool ManualFirstOrder = false;      // открываем первый ордер вручную
extern bool debug = false; 
//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
double  TakeProfit;
double AveragePrice,buf;
double LastBuyPrice, LastSellPrice, Spread, LastTP;
string EAName="Ilan_VS_TrendTrading_Trail";
int timeprev = 0;
int NumOfTrades = 0;
double iLots;
int cnt = 0, total, prev_total, i1, ma_tf, trail_tf;
bool LongTrade = FALSE, ShortTrade = FALSE;
int ticket, Error;
double Exponent, TP_Shift, LastTP_Lot, LastTP_Price_shift, TrailPrice;
//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
int init() {
   switch(MA_TimeFrame)                                  // Заголовок switch
     {                                            // Начало тела switch
      case 0 : ma_tf = 0;     break;               // 1 текущий график
      case 1 : ma_tf = 1;     break;               // 1 мин
      case 2 : ma_tf = 5;     break;               // 5 мин
      case 3 : ma_tf = 15;    break;               // 15 мин
      case 4 : ma_tf = 30;    break;               // 30 мин
      case 5 : ma_tf = 60;    break;               // 1 час
      case 6 : ma_tf = 240;   break;               // 4 часа
      case 7 : ma_tf = 1440;  break;               // 1 день
      default: ma_tf = 0;                          // Если с case не совпало то текущий график
     }                                            // Конец тела switch   

   switch(Trail_TimeFrame)                                  // Заголовок switch
     {                                            // Начало тела switch
      case 0 : trail_tf = 0;     break;               // 1 текущий график
      case 1 : trail_tf = 1;     break;               // 1 мин
      case 2 : trail_tf = 5;     break;               // 5 мин
      case 3 : trail_tf = 15;    break;               // 15 мин
      case 4 : trail_tf = 30;    break;               // 30 мин
      case 5 : trail_tf = 60;    break;               // 1 час
      case 6 : trail_tf = 240;   break;               // 4 часа
      case 7 : trail_tf = 1440;  break;               // 1 день
      default: trail_tf = 0;                          // Если с case не совпало то текущий график
     }                                            // Конец тела switch   

  Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;
  timeprev = Time[0];
  return (0);
}

int deinit() 
{
   return (0);
}
//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
int start()
{
  /************************************************************/
  /* Здесь часть кода, которая работает при каждом новом тике */ 
  /************************************************************/
  double PrevCl;
  double CurrCl;

  if (timeprev == Time[0]) return(0);   //Проверяем появление нового бара

  /*****************************************************************************/
  /* Дальше идет часть кода, которая работает только при появлении нового бара */ 
  /*****************************************************************************/
  timeprev = Time[0];
total = CountOfOrders();

//-----------------------------------------------------------------------------------------------------------+BosSLtd
 if(MM) Lots = GetLots();
 
//-----------------------------------------------------------------------------------------------------------+BosSLtd
  switch(TypeLotExponent)
   {
    case 0://арифметический метод расчёта лотэкспоненты
      Exponent = Lots * (1 + total);//с каждым коленом увеличиваем Exponent на Lots
      break;
    case 1://арифметический метод расчёта лотэкспоненты
      Exponent = Lots + (LotExponent*total);//с каждым коленом увеличиваем Exponent на LotExponent
      break;
    case 2://геометрический метод расчёта лотэкспоненты
      Exponent = Lots * MathPow(LotExponent, total);
      break;
   }
  //===============================================================================
  // Тут вычисляется пипстеп. 
  //===============================================================================
  PipStep = MathRound(DefaultPips * MathPow(PipStepExponent, (total-1)));
  if (PipStep>MaxPips)
   PipStep=MaxPips;
  if (total > 0)  //выполняем все это только если есть ордера в рынке, иначе нет смысла.
  {
    for (int i = 0; i < OrdersTotal(); i++) 
      if(OrderSelect( i, SELECT_BY_POS, MODE_TRADES))
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
          switch(OrderType())
          {
            case OP_BUY:
              LongTrade = TRUE;
              ShortTrade = FALSE;
              break;
            case OP_SELL:
              LongTrade = FALSE;
              ShortTrade = TRUE;
              break;//выходим из группы switch
          }
          break;//выходим из цикла for
        }
  //===============================================================================
  // Здесь проверяется нужно ли открывать следующее колено серии ордеров
  //===============================================================================
    LastBuyPrice = FindLastBuyPrice();
    LastSellPrice = FindLastSellPrice();
  }
   
  //===============================================================================
  // Здесь выставляются ордера, когда в рынке уже есть открытые ордера.
  //===============================================================================
   if((total > 0) && !(total > MaxTrades))
   { 
    if((LongTrade && LastBuyPrice - Ask >= PipStep * Point) || (ShortTrade && Bid - LastSellPrice >= PipStep * Point))
     {
      iLots = NormalizeDouble(Exponent, lotdecimal);
      if (ShortTrade) 
      {
        if((iMA(NULL,ma_tf,MA_Period,0,0,0,1)-iMA(NULL,ma_tf,MA_Period,0,0,0,0)) > (MA_Delta*Point))
        ticket = SendMarketOrder(OP_SELL, iLots, 0, 0, MagicNumber, EAName + "-" + NumOfTrades + "-" + PipStep, Error);
      }
      if (LongTrade) 
      {
        if((iMA(NULL,ma_tf,MA_Period,0,0,0,0)-iMA(NULL,ma_tf,MA_Period,0,0,0,1)) > (MA_Delta*Point))
        ticket = SendMarketOrder(OP_BUY, iLots, 0, 0, MagicNumber, EAName + "-" + NumOfTrades + "-" + PipStep, Error);
      }
     } 
    }  
  //===============================================================================
  // Здесь выставляются ордера, когда в рынке нет открытых ордеров.
  //===============================================================================
 if (total < 1)
  {
    if (!ManualFirstOrder)
    {
     Print("Проверяем условия для открытия первого ордера");
     ticket = 0;
     PrevCl = iClose(Symbol(), 0, 2);
     CurrCl = iClose(Symbol(), 0, 1);
     if ((PrevCl > CurrCl) 
     && iMA(NULL,ma_tf,MA_Period,0,0,0,1)-iMA(NULL,ma_tf,MA_Period,0,0,0,0) > MA_Delta*Point
     && iCCI(Symbol(),1440,14,PRICE_TYPICAL,0)>CCIlevel*(-1)) 
     {
       if (debug) Print("Выполнено условие SELL");
       ticket = SendMarketOrder(OP_SELL, Lots, 0, 0, MagicNumber, EAName + "-" + total , Error);
     }
     else Print ("Нет условий для открытия ордера SELL"); 
     if (PrevCl < CurrCl 
     && iMA(NULL,ma_tf,MA_Period,0,0,0,0)-iMA(NULL,ma_tf,MA_Period,0,0,0,1) > MA_Delta*Point
     && iCCI(Symbol(),1440,14,PRICE_TYPICAL,0)<CCIlevel) 
     {
       if (debug) Print("Выполнено условие BUY");
       ticket = SendMarketOrder(OP_BUY, Lots, 0, 0, MagicNumber, EAName + "-" + total , Error);
     }
     else Print ("Нет условий для открытия ордера BUY"); 
   }  
  }
total = CountOfOrders();
Trail();
  
  return (0);
}
//ннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
int CountOfOrders()
{
  int count = 0;
  for (int i = 0; i < OrdersTotal(); i++) 
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == MagicNumber)) 
        if ((OrderType() == OP_SELL) || (OrderType() == OP_BUY)) 
          count++;
  return(count);
}

//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн


//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
//=========================================================================
int SendMarketOrder(int Type, double Lots, int TP, int SL, int Magic, string Cmnt, int& Error)
{
  double Price, Take, Stop;
  int Ticket, Slippage, Color, Err; 
  bool Delay = False;
  if (debug) Print("Функция SendMarketOrder");
  while(!IsStopped())
  {
    if(!IsExpertEnabled())
    {
      Error = ERR_TRADE_DISABLED;
      Print("Эксперту запрещено торговать! Кнопка \"Эксперты\" отжата.");
      return(-1);
    }
    if (debug) Print("Эксперту разрешено торговать");
    if(!IsConnected())
    {
      Error = ERR_NO_CONNECTION;
      Print("Связь отсутствует!");
      return(-1);
    }
    Print("Связь с сервером установлена");
    if(IsTradeContextBusy())
    {
      Print("Торговый поток занят!");
      Print("Ожидаем 3 сек...");
      Sleep(3000);
      Delay = True;
      continue;
    }
    if (debug) Print("Торговый поток свободен");
    if(Delay) 
    {
      Print("Обновляем котировки");
      RefreshRates();
      Delay = False;
    }
    else
    {
      if (debug) Print("Задержек не было");
    }
    switch(Type)
    {
      case OP_BUY:
        if (debug) Print("Инициализируем параметры для BUY-ордера");
        Price = NormalizeDouble( Ask, Digits);
        Take = IIFd(TP == 0, 0, NormalizeDouble( Ask + TP * Point, Digits));
        Stop = IIFd(SL == 0, 0, NormalizeDouble( Ask - SL * Point, Digits));
        Color = Blue;
        break;
      case OP_SELL:
        if (debug) Print("Инициализируем параметры для SELL-ордера");
        Price = NormalizeDouble( Bid, Digits);
        Take = IIFd(TP == 0, 0, NormalizeDouble( Bid - TP * Point, Digits));
        Stop = IIFd(SL == 0, 0, NormalizeDouble( Bid + SL * Point, Digits));
        Color = Red;
        break;
      default:
        Print("Тип ордера не соответствует требованиям.");
        return(-1);
    }
    Slippage = MarketInfo(Symbol(), MODE_SPREAD);
    Print("Slippage = ",Slippage);
    if(IsTradeAllowed())
    {
      if (debug) Print("Торговля разрешена, отправляем ордер...");
      Ticket = OrderSend(Symbol(), Type, Lots, Price, Slippage, Stop, Take, Cmnt, Magic, 0, Color);
      if(Ticket < 0)
      {
        Err = GetLastError();
        if (Err == 4   || /* SERVER_BUSY */
            Err == 129 || /* INVALID_PRICE */ 
            Err == 135 || /* PRICE_CHANGED */ 
            Err == 137 || /* BROKER_BUSY */ 
            Err == 138 || /* REQUOTE */ 
            Err == 146 || /* TRADE_CONTEXT_BUSY */
            Err == 136 )  /* OFF_QUOTES */
        {
          Print("Ошибка(OrderSend - ", Err, "): ", ErrorDescription(Err));
          Print("Ожидаем 3 сек...");
          Sleep(3000);
          Delay = True;
          continue;
        }
        else
        {
          Print("Критическая ошибка(OrderSend - ", Err, "): ", ErrorDescription(Err));
          Error = Err;
          break;
        }
      }
      break;
    }
    else
    {
      Print("Эксперту запрещено торговать! Снята галка в свойствах эксперта.");
      //Print("Ожидаем 3 сек...");
      //Sleep(3000);
      //Delay = True;
      //continue;
      Ticket = -1;
      break;
    }
  }
  if(Ticket > 0)
    Print("Ордер отправлен успешно. Тикет = ",Ticket);
  else
    Print("Ошибка! Ордер не отправлен. (ErrorCode = ", Error, ": ", ErrorDescription(Error), ")");
  return(Ticket);
}
//==================================================================
double IIFd(bool condition, double ifTrue, double ifFalse) 
{
  if (condition) return(ifTrue); else return(ifFalse);
}

//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн

double FindLastBuyPrice() {
   double oldorderopenprice;
   int oldticketnumber;
   double unused = 0;
   int ticketnumber = 0;
   for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
         oldticketnumber = OrderTicket();
         if (oldticketnumber > ticketnumber) {
            oldorderopenprice = OrderOpenPrice();
            unused = oldorderopenprice;
            ticketnumber = oldticketnumber;
         }
      }
   }
   return (oldorderopenprice);
}

double FindLastSellPrice() {
   double oldorderopenprice;
   int oldticketnumber;
   double unused = 0;
   int ticketnumber = 0;
   for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
         oldticketnumber = OrderTicket();
         if (oldticketnumber > ticketnumber) {
            oldorderopenprice = OrderOpenPrice();
            unused = oldorderopenprice;
            ticketnumber = oldticketnumber;
         }
      }
   }
   return (oldorderopenprice);
}
//ннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
double CalculateAveragePrice()
{
  double AveragePrice = 0;
  double Count = 0;
  for (int i = 0; i < OrdersTotal(); i++)
    if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        if (OrderType() == OP_BUY || OrderType() == OP_SELL) 
        {
           AveragePrice += OrderOpenPrice() * OrderLots();
           Count += OrderLots();
        }
  if(AveragePrice > 0 && Count > 0)
    return( NormalizeDouble(AveragePrice / Count, Digits));
  else
    return(0);
}
//ннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн

//--------------------------------------------------------
bool ModifyOrder( double stoploss)
{
  while(!IsStopped())
  {
    Print("Функция ModifyOrder");
    if(IsTradeContextBusy())
    {
      Print("Торговый поток занят!");
      Sleep(3000);
      continue;
    }
    if (debug) Print("Торговый поток свободен");
    if(!IsTradeAllowed())
    {
      Print("Эксперту запрещено торговать!");
      //Sleep(3000);
      //continue;
      return(False);
    }
    if (debug) Print("Торговля разрешена, модифицируем ордер #",OrderTicket());
    if(stoploss != NormalizeDouble(OrderStopLoss(),Digits))
    {
      if(!OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(stoploss,Digits), 0, 0, Yellow))
      {
         Print("Не удалось модифицировать ордер");
         int Err = GetLastError();
         Print("Ошибка(",Err,"): ",ErrorDescription(Err));
         return(False);
         //break;
         //Sleep(1000);
         //continue;
      }
      else
      {
         if (debug) Print("Модификация ордера выполнена успешно");
         break;
      }
     return(True);
    }
    else
    {
    if (debug) Print("Ордер не нуждается в модификации");
    break;
    }  
  }
  return(True);
}
//--------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------+BosSLtd
double GetLots() 
{
double minlot = MarketInfo(Symbol(), MODE_MINLOT);
double maxlot = MarketInfo(Symbol(), MODE_MAXLOT);
double lot = NormalizeDouble(AccountBalance() * risk /100 / balans, 2);
if(lot < minlot) lot = minlot; if(lot > maxlot) lot = maxlot;
return(lot);
} 
//-----------------------------------------------------------------------------------------------------------+BosSLtd
//--------------------------------------------------------------------------------
double LongTrail ()
{
double firstbar, secondbar, trailprice;
firstbar = iLow(Symbol(),trail_tf,1);
secondbar = iLow(Symbol(),trail_tf,2);
if(firstbar > secondbar) trailprice = NormalizeDouble(secondbar, Digits);
    else trailprice = NormalizeDouble(firstbar, Digits);
return(trailprice);
}
//--------------------------------------------------------------------------------   
double ShortTrail ()
{
double firstbar, secondbar, trailprice;
firstbar = iHigh(Symbol(),trail_tf,1);
secondbar = iHigh(Symbol(),trail_tf,2);
if(firstbar > secondbar) trailprice = NormalizeDouble(firstbar, Digits);
    else trailprice = NormalizeDouble(secondbar, Digits);
return(trailprice);
}
//--------------------------------------------------------------------------------   
void Trail()
{
double trailprice;
double PriceTarget = 0;
      if(total>0)
      {
      //===
      for (int i = 0; i < OrdersTotal(); i++) 
         if(OrderSelect( i, SELECT_BY_POS, MODE_TRADES))
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
            {
               switch(OrderType())
               {
                  case OP_BUY:
                     LongTrade = TRUE;
                     ShortTrade = FALSE;
                     break;
                  case OP_SELL:
                     LongTrade = FALSE;
                     ShortTrade = TRUE;
                     break;//выходим из группы switch
               }
               break;//выходим из цикла for
            }
         //===
         AveragePrice = CalculateAveragePrice();
         trailprice = AveragePrice;
         if(ShortTrade) 
            {  
            if(trailprice > ShortTrail() && (Ask + MarketInfo(Symbol(), MODE_STOPLEVEL)*Point) < ShortTrail()) 
               {
               trailprice = ShortTrail();
               if (AveragePrice > trailprice) PriceTarget = trailprice;
                        if (debug) Print("Модифицируем все ордера в рынке");
               for (i1 = 0; i1 < OrdersTotal(); i1++)
                  {  
                  if(OrderSelect(i1, SELECT_BY_POS, MODE_TRADES))
                     {
                     if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
                        { 
                        if(NormalizeDouble(OrderTakeProfit(),Digits) != NormalizeDouble(PriceTarget,Digits))
                        ModifyOrder(PriceTarget);
                        }
                     }
                  }
               }
            }
         if(LongTrade) 
            {
            if(trailprice < LongTrail() && (Bid - MarketInfo(Symbol(), MODE_STOPLEVEL)*Point) > LongTrail()) 
            {
            trailprice = LongTrail();
            if (AveragePrice < trailprice) PriceTarget = trailprice;
               if (debug) Print("Модифицируем все ордера в рынке");
               for (i1 = 0; i1 < OrdersTotal(); i1++)
                  {  
                  if(OrderSelect(i1, SELECT_BY_POS, MODE_TRADES))
                     {
                     if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
                        { 
                        if(NormalizeDouble(OrderTakeProfit(),Digits) != NormalizeDouble(PriceTarget,Digits))
                        ModifyOrder(PriceTarget);
                        }
                     }
                  }
               } 
            }
       }
return;
}