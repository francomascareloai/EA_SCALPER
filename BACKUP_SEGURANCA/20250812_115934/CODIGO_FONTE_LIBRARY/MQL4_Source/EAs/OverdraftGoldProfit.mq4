//+------------------------------------------------------------------+
//|                                Overdraft_Gold_Profit V 4.2 mql4  |
//|          Copyright © 2014 Сергей Королевский ambrela0071@mail.ru |
//|   programming & support - Сергей Королевский ambrela0071@mail.ru |
//| 10.12.2014                                                       |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014  Сергей Королевский"
#property link      "ambrela0071@mail.ru"
#property version     "4.2"
//Эксперт предоставлен для ознакомления работы на форекс рынке, код открытый, что позволит вам модернизировать стратегию, и
//сделать под себя, оптимизировать под рынок и зарабатывать.
//Предлагаю доверительное управление вашими средствами на Forex:

//Минимальный депозит 20k - кредитное плечо лучше всего 1/300 и выше.
//Центовый счёт на InstaForex 1000$ - кредитное плечо 1/300 и выше.
//RoboForex центовые счета Pro.
//Желательно брокеры с пятизначным котированием. 
//Пример котировки: (1.24135) - т.е. пять знаков после точки.
//Можно использовать и на других брокерах:
//Alpari; FXOpen; AdmiralMarkets, Roboforex и другие.....
//Ниже предоставлена информация о счёте брокерской компании RVD.
//Счёт ECN, (плавающий спред).


//________________________________________
 
//Информация о счёте, для просмотра в режиме реального времени:
//Номер счёта: 50767
//Инвесторский пароль: Investor2015
//IP: 5.9.113.233:443
//________________________________________
//Внимание! Такие суммы взяты не с потолка, а с агрессивного графика 2008г. Где были супер тренды. 

//Условия распределения прибыльности:

//________________________________________
//Долларовые счета:
//Для долларовых депозитов приём в доверительное управление от 20k кредитное плечо 1/300 и выше.
//Прибыль делится 50/50
//Если же сумма депозита 40k и более:
//Прибыль делится 35% от заработка трейдеру управляющему, а 65% в пользу инвестора.
//Если же сумма депозита 100k и более:
//Прибыль делится 30% от заработка трейдеру управляющему, а 70% в пользу инвестора.

//________________________________________



//Центовые счета:

//Для всех центовых счетов от 1000$ кредитное плечо 1/300 и выше.
//Прибыль всегда делится 50/50.
//Есть исключение:
//Если у Вас центовых счетов более 5-ти, тогда прибыль делится так:
//40% управляющему трейдеру, а 60% в пользу инвестора.
//Также можно взять в управление и 500$ центового счёта, если Вы при необходимости сможете долиться в депозит.


//________________________________________
//Уведомление о рисках:
//Сколько нужно денег, чтобы начать инвестировать?
//Многих новичков интересует вопрос о том, каковы в доверительном управлении счетом Forex минимальные вложения?
//Прелесть ПАММ-инвестирования в том, что суммы инвестиций могут быть намного меньше, чем в банке или, например, на рынке акций. Разные брокеры предлагают разные условия, но можно найти таких, которые попросят вложить на Forex в доверительное управление от 10 долларов - такая сумма найдется у любого человека.
//Другое дело - если инвестор изначально рассчитывает на постоянную ощутимую прибыль. Естественно, в этом случае ставки должны быть выше. Доход будет пропорционален сумме, вложенной в доверительные ПАММ счета на форекс. И риски тоже.
//Сколько можно заработать?
//При инвестировании и использовании услуги доверительного управления деньгами на рынке Forex доходность за год может составлять 100% и более.
//Основные факторы, от которых будет зависеть уровень доходов:
//1	вложенная сумма;
//2	тактика работы управляющего: консервативная или агрессивная;
//3	успешность торговли в конкретном месяце.
//При понимании основных правил инвестирования доверительное управление на форекс 100% может приносить без проблем.
//Доверительное управление на форекс без рисков: возможно ли?
//Если Вы решили заниматься инвестированием, то Вам стоит знать о том, что инвестиций без рисков в принципе не существует. В сторону доверительного управления на Форекс критика от тех, кто вкладывал и разорился, всегда была, есть и будет. Да, инвестор всегда рискует. Основные риски связаны с тремя моментами:
//1	возможность того, что управляющий уйдет в затяжную сильную просадку, потеряв все деньги, свои и инвестора;
//2	брокерская компания может оказаться хорошо организованным хайпом, который уже очень скоро "лопнет";
//3	брокер может оказаться не совсем добросовестным, либо у него возникнут проблемы, в результате которых он окажется банкротом и лишит денег инвесторов. К сожалению, доверительное управление все еще никак не регулируется российским законодательством.
//Не все отзывы о доверительном управлении на Форекс положительны. Но в целом можно говорить о том, что ПАММ-инвестирование - хороший источник пассивного дохода.
//В то же время, в Форекс при доверительном управлении гарантированный доход Вам, конечно же, никто обещать не станет. Это не регулярная зарплата, которую работодатель исправно выплачивает до 15 числа.
//Поэтому, перед тем как принимать решение "дам денег в доверительное управление Форекс", нужно понимать, готовы ли Вы брать на себя определенные риски.
//Надеемся, что теперь, когда Вам понятно, что такое доверительное управление на Forex, Вы сможете принять для себя осознанное решение, стоит ли этим заниматься.


//Контакты:
//E-mail: Ambrela0071@yandex.ru
//Skype: OverdraftScalpSystem
//QIP: 444048899
#property strict
#include <stderror.mqh>            
#include <stdlib.mqh>    
#define miz 0.00000001
          
extern double            MaxRisk = 2; //The risk per trade %
extern double               Lots = 0.01; //Lot trading if risk = 0
extern int            BarHistory = 72; //Number of bars for the analysis
extern int              PeriodBH = PERIOD_H1; //The timeframe for analysis of trade names
extern int             TimeFrame = PERIOD_M30;  //The timeframe for the analysis of the second tralia
extern int              BarCount = 2; //The number of bars for the analysis of the second trailing  
extern int                 RBHID = 8; //The offset from the min/max bars for the second trailing
extern int                 RBHTP = 2; //Calculate take profit
extern int                 RBHSL = 4; //The calculation of stop loss
extern int                  RBHT = 4; //Calculate take profit of the second trailing
extern int                 RBHTS = 6; //The distance calculation for the price movement of the trailing
extern int                RBHTSP = 4; //The calculation of guaranteed profits by trailing
extern int                 RBHTM = 9; //The modification time of the price channel
extern int                 RBHSM = 7; //The offset from the Ask/Bid for price channel
extern int                 RBHPS = 2; //The offset from the Ask/Bid for pending orders
extern bool             ShowInfo = true; //Show/Hide information
extern bool        TrailingInBar = true; //Enable/disable trailing
extern bool          TrailingBar = true; //Enable/disable trailing on bars
extern bool      BreakEvenDeals  = true; //Enable/disable breakeven
extern bool          CloseOrders = true; //Close all market/pending orders on Friday
extern int            TimeFriday = 23; //Time on Friday to close market orders
extern bool   ClosePendingOrders = true; // To delete pending orders at active positions
extern int                 Magic = 12345; //The magic number
extern color               UpCol = clrLawnGreen; //Color the higer line of the price channel
extern color               DnCol = clrOrangeRed; //Color the lower line of the price channel
extern string                Com = " Kurochka Ryaba"; //Comment for market orders

bool                     Testing = (!IsDemo() && !IsTesting());
int                       Number = 123435;
int                    AccNumber;
int                       Indent;  
int                   PriceSteep;
int                  SteepModify;
int                   TimeModify;
int                TrailingStart;
int                 TrailingStep;
double             TakeProfitBar;
double                TakeProfit;
double                  StopLoss;
string                   Symboll = Symbol();
datetime                    time;
bool opnovis,testing=false,Signal[2];

int OnInit()
  {
   AccNumber   = AccountNumber();
  
   TakeProfit    = BHTP();
   TakeProfitBar = BHT();
   TrailingStart = BHTS();
   TrailingStep  = BHTSP();
   TimeModify    = BHTM();
   SteepModify   = BHSM();
   PriceSteep    = BHPS();
   StopLoss      = BHSL();
   Indent        = BHID();
   
   opnovis=true;
   if(!IsOptimization() && !IsTesting())EventSetTimer(1);else testing=true;
   DelBP(Com);
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
   if(IsTesting() || IsOptimization())return;
   EventKillTimer();
   Comment("");
   int ur=UninitializeReason();
   if(ur==1 || ur==6)DelBP(Com);
  }
void OnTick()
{ 
 
  
  
   
  double ProfCount = Profit(0); 
  
  if (ShowInfo == true)
  {
  Comment ("" "\n"
           "   Account information:" "\n"
           "   Guaranteed profit on the open transaction: ", (DoubleToString(ProfitIFStopInCurrency(Symbol(), OrderType(), OrderMagicNumber()), 2)), " ", AccountCurrency(), "\n"
           "   Profit/Loss of the previous deal: ", (DoubleToString(profhistory(Symbol(), OrderType(), OrderMagicNumber()), 2)), " ", AccountCurrency(), "\n"
           "   Profit/Loss for today: ", DoubleToStr(Profit(0), 2), " ", AccountCurrency(), "\n"
           "   Profit/Loss yesterday: ", DoubleToStr(Profit(1), 2), " ", AccountCurrency(), "\n"
           "   Profit/Loss in the current month: ", DoubleToStr(ProfitMons(0), 2), " " + AccountCurrency(), "\n"
           "   Profit/Loss in the previous month: ", DoubleToStr(ProfitMons(1), 2), " ", AccountCurrency(), "\n"
           "   Your current balance: ", DoubleToStr(AccountBalance(), 2), " ", AccountCurrency(), "\n"
           "   ""\n"
           "   Information on trade:" "\n"
           "   Number of bars for the analysis: ", BarHistory, " on ", PeriodBH," minute chart" "\n"
           "   Number of bars for the analysis of the second trailing: ", BarCount, " on ", TimeFrame," minute chart" "\n"
           "   Take profit: ", BHTP(), " point" "\n"
           "   Stop loss: ", BHSL(), " point" "\n"
           "   Profit on the second trailing: ", BHT(), " point" "\n"
           "   Distance to the price movement of the trailing: ", BHTS(), " point" "\n"
           "   Guaranteed profit on the trailing: ", BHTSP(), " point" "\n"
           "   The offset from the min/max bars for the second trailing: ", BHID(), " point" "\n"
           "   Modification of pending orders: ", BHTM(), " second" "\n"
           "   Step price channel: ", BHSM(), " point" "\n"
           "   Step for pending orders: ", BHPS(), " point" "\n"
          
          );
   }
          
  
  
  
  if(TrailingInBar == true) MoveTrailingStop();
  if(BreakEvenDeals == true) breakeven();
  if(TrailingBar == true)Trailing();
  ModifyPendingOrders(Signal);
  if(CloseOrders == true)CloseAllOrders();
  if(ClosePendingOrders == true)ClosePendingOrder();
  
  if(CloseOrders = true && DayOfWeek() == 5 && Hour() >= TimeFriday)
  {
     return;
     Print ("Trading on Friday after: ", TimeFriday, " hours prohibited in the parameters of the expert Advisor");
  }
  
  if (GetLastError()!=134)
  {
  if (CountBuy() + CountSell() == 0)
     {
        if (CountBuyStop() == 0)
        {
        int ticket=OrderSend(Symbol(),OP_BUYSTOP, LotByRisk(), NormalizeDouble(Ask + PriceSteep*Point, Digits), 0, NormalizeDouble(Ask + PriceSteep*Point -StopLoss*Point, Digits), NormalizeDouble(Ask+ PriceSteep*Point + TakeProfit*Point, Digits), Com, Magic, 0,clrNONE);
        }
     }   
     if (CountBuy() + CountSell() == 0)
     {
        if (CountSellStop() == 0)
        {
        int ticket=OrderSend(Symbol(),OP_SELLSTOP, LotByRisk(),NormalizeDouble(Bid - PriceSteep*Point, Digits), 0, NormalizeDouble(Bid - PriceSteep*Point + StopLoss*Point, Digits), NormalizeDouble(Bid - PriceSteep*Point -TakeProfit*Point, Digits), Com, Magic, 0,clrNONE);
        }
     }   
  }
  
  if (CountBuy() + CountSell() == 0)
     {
        if (CountBuyStop() == 0)
        {
        if(AccountFreeMarginCheck(Symbol(),OP_BUY,LotByRisk())<=0 || GetLastError()==134) 
        int ticket=OrderSend(Symbol(),OP_BUYSTOP, Lots, NormalizeDouble(Ask + PriceSteep*Point, Digits), 0, NormalizeDouble(Ask + PriceSteep*Point -StopLoss*Point, Digits), NormalizeDouble(Ask+ PriceSteep*Point + TakeProfit*Point, Digits), Com, Magic, 0,clrNONE);
        }
     }   
     if (CountBuy() + CountSell() == 0)
     {
        if (CountSellStop() == 0)
        {
        if(AccountFreeMarginCheck(Symbol(),OP_SELL,LotByRisk())<=0 || GetLastError()==134) 
        int ticket=OrderSend(Symbol(),OP_SELLSTOP, Lots,NormalizeDouble(Bid - PriceSteep*Point, Digits), 0, NormalizeDouble(Bid - PriceSteep*Point + StopLoss*Point, Digits), NormalizeDouble(Bid - PriceSteep*Point -TakeProfit*Point, Digits), Com, Magic, 0,clrNONE);
        }
     }   
  } 



int CountBuy()
{
   int count = 0;
   for (int i = OrdersTotal() - 1; i >= 0; i --)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_BUY)
         count ++;
      }
   }
   return (count);
}

int CountSell()
{
   int count = 0;
   for (int i = OrdersTotal() - 1; i >= 0; i --)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_SELL)
         count ++;
      }
   }
   return (count);
 }
 
int MinStopLoss1()
{
   double ask        = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   double bid        = SymbolInfoDouble(Symbol(),SYMBOL_BID);
   double spread     = ask - bid;
   int spread_points = (int)MathRound(spread/SymbolInfoDouble(Symbol(),SYMBOL_POINT));
   return (spread_points);

}

int comis()
{  
   double prpoint = LotByRisk() * MarketInfo(Symbol(),MODE_TICKVALUE) / ( MarketInfo(Symbol(),MODE_TICKSIZE) / MarketInfo(Symbol(),MODE_POINT) );
   double Commissions = OrderCommission();
   int res = (int)MathRound(Commissions/prpoint);
   return(res);
}
 
int swap()
{
   double prpoint = LotByRisk() * MarketInfo(Symbol(),MODE_TICKVALUE) / ( MarketInfo(Symbol(),MODE_TICKSIZE) / MarketInfo(Symbol(),MODE_POINT) );
   double swaps = OrderSwap();
   int res = (int)MathRound(swaps/prpoint);
   return(res);
}
 
double OrdersBuyMinSL1()
{
   double stoploss = 0;
   
   double minstoplevel = MinStopLoss1();
   stoploss            = NormalizeDouble(Bid - minstoplevel*Point,Digits);

   return (stoploss);
}

double OrdersSellMinSL1()
{
   double stoploss = 0;
   
   double minstoplevel = MinStopLoss1();
   stoploss            = NormalizeDouble(Ask + minstoplevel*Point,Digits);

   return (stoploss);
} 
 
void Trailing()
{
   double ST_Buy, ST_Sell, NoLoss;
   
   for(int i=0; i<OrdersTotal(); i++)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
         {
            if (OrderType() == OP_BUY)
            {   
               ST_Buy  = NormalizeDouble(GetLowestPrice() - Indent*Point, Digits); 
               NoLoss  = OrderOpenPrice();
               
                  if(NormalizeDouble(OrderStopLoss(),Digits) > NormalizeDouble(NoLoss,Digits) || NormalizeDouble(OrderStopLoss(),Digits) == NormalizeDouble(NoLoss,Digits))
                  {
                  if(NormalizeDouble(ST_Buy, Digits) != NormalizeDouble(OrderStopLoss(),Digits) && NormalizeDouble(ST_Buy, Digits) > NormalizeDouble(OrderStopLoss(),Digits) && NormalizeDouble(ST_Buy, Digits) <= NormalizeDouble(OrdersBuyMinSL1(), Digits))
                  {
                     bool Ans = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(ST_Buy,Digits), NormalizeDouble(Ask + PriceSteep*Point + TakeProfitBar*Point, Digits), 0, clrNONE); 
                  }
                  }
            }   
            
           if (OrderType() == OP_SELL)
           {
               ST_Sell = NormalizeDouble(GetHighestPrice() + Indent * Point, Digits);
               NoLoss  = OrderOpenPrice();
                  
                  if (NormalizeDouble(OrderStopLoss(),Digits) < NormalizeDouble(NoLoss,Digits) || NormalizeDouble(OrderStopLoss(),Digits) == NormalizeDouble(NoLoss,Digits))
                  { 
                  if (NormalizeDouble(ST_Sell, Digits) != NormalizeDouble(OrderStopLoss(),Digits) && NormalizeDouble(ST_Sell, Digits) <  NormalizeDouble(OrderStopLoss(),Digits) && NormalizeDouble(ST_Sell, Digits) >= NormalizeDouble(OrdersSellMinSL1(), Digits))
                  {                  
                     bool Ans = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(ST_Sell, Digits), NormalizeDouble(Bid - PriceSteep*Point - TakeProfitBar*Point, Digits), 0, clrNONE); 
                  }
                  }
              }
           }
       }
   }
}

double GetLowestPrice()
{
   double price, lowest = 1000000;
   
   for (int i = 1; i <= BarCount; i++)
   {
      price = iLow(Symbol(), TimeFrame, i);
      if (price < lowest)
         lowest = price;
   }
   return (lowest);
}

double GetHighestPrice()
{
   double price, highest = 0;
   
   for (int i = 1; i <= BarCount; i++)
   {
      price = iHigh(Symbol(), TimeFrame, i);
      if (price > highest)
         highest = price;
   }
   return (highest);
} 
 
 void MoveTrailingStop()
{
   int cnt,total=OrdersTotal();
   double NoLoss;
   for(cnt=0;cnt<total;cnt++)
   {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
      {
      NoLoss  = OrderOpenPrice();
      if(OrderMagicNumber() == Magic && OrderSymbol()== Symbol() && TrailingStart > 0)
      {
      if(TrailingBar == true)
      {
      if(OrderOpenTime() >= iTime(Symbol(), PERIOD_CURRENT, 0))
         {
            if(OrderType() == OP_BUY && OrderSymbol()== Symbol())
            {
               if(NormalizeDouble(OrderStopLoss(),Digits) < NormalizeDouble(Bid-Point*(TrailingStart+TrailingStep),Digits) && NormalizeDouble(Bid-Point*(TrailingStart+TrailingStep),Digits) <= NormalizeDouble(OrdersBuyMinSL1(), Digits) && NormalizeDouble(Bid-Point*TrailingStep,Digits) > OrderStopLoss())
               {
                  if (NormalizeDouble(OrderStopLoss(),Digits) >= NormalizeDouble(NoLoss,Digits))
                  {
                     bool res = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-Point*TrailingStep,Digits),NormalizeDouble(OrderTakeProfit(),Digits),0,clrNONE);
                  }
               }
            }
            if(OrderType() == OP_SELL && OrderSymbol()== Symbol()) 
            {                 
               if(NormalizeDouble(OrderStopLoss(),Digits)>NormalizeDouble(Ask+Point*(TrailingStart+TrailingStep),Digits) && NormalizeDouble(Ask+Point*(TrailingStart+TrailingStep),Digits) >= NormalizeDouble(OrdersSellMinSL1(),Digits) && NormalizeDouble(Ask+Point*TrailingStep,Digits) < OrderStopLoss())
               {
                  if (NormalizeDouble(OrderStopLoss(),Digits) <= NormalizeDouble(NoLoss,Digits))
                  {
                     bool res = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+Point*TrailingStep,Digits),NormalizeDouble(OrderTakeProfit(),Digits),0,clrNONE);
                  }
               }
            }
         }
      if(OrderOpenTime() < iTime(Symbol(), PERIOD_CURRENT, 0))
         {
            if(OrderType() == OP_BUY && OrderSymbol()== Symbol())
            {
               if (NormalizeDouble(OrderStopLoss(),Digits) >= NormalizeDouble(NoLoss,Digits))
                  {
                     bool res = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderStopLoss(),Digits),NormalizeDouble(Ask + PriceSteep*Point + TakeProfitBar*Point, Digits),0,clrNONE);
                  }
            }
            if(OrderType() == OP_SELL && OrderSymbol()== Symbol()) 
            {                 
               if (NormalizeDouble(OrderStopLoss(),Digits) <= NormalizeDouble(NoLoss,Digits))
                  {
                     bool res = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderStopLoss(),Digits),NormalizeDouble(Bid - PriceSteep*Point - TakeProfitBar*Point, Digits),0,clrNONE);
                  }
            } 
         }     
      }
      if(TrailingBar == false)
      {
      if(OrderType() == OP_BUY && OrderSymbol()== Symbol())
            {
               if(NormalizeDouble(OrderStopLoss(),Digits) < NormalizeDouble(Bid-Point*(TrailingStart+TrailingStep),Digits) && NormalizeDouble(Bid-Point*(TrailingStart+TrailingStep),Digits) <= NormalizeDouble(OrdersBuyMinSL1(), Digits) && NormalizeDouble(Bid-Point*TrailingStep,Digits) > OrderStopLoss())
               {
                  if (NormalizeDouble(OrderStopLoss(),Digits) >= NormalizeDouble(NoLoss,Digits))
                  {
                     bool res = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-Point*TrailingStep,Digits),OrderTakeProfit(),0,clrNONE);
                  }
               }
            }
            if(OrderType() == OP_SELL && OrderSymbol()== Symbol()) 
            {                 
               if(NormalizeDouble(OrderStopLoss(),Digits)>NormalizeDouble(Ask+Point*(TrailingStart+TrailingStep),Digits) && NormalizeDouble(Ask+Point*(TrailingStart+TrailingStep),Digits) >= NormalizeDouble(OrdersSellMinSL1(),Digits) && NormalizeDouble(Ask+Point*TrailingStep,Digits) < OrderStopLoss())
               {
                  if (NormalizeDouble(OrderStopLoss(),Digits) <= NormalizeDouble(NoLoss,Digits))
                  {
                     bool res = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+Point*TrailingStep,Digits),OrderTakeProfit(),0,clrNONE);
                  }
               }
            }
         }
      }
      }
   }         
}


int MinStopLoss()
{
   double ask        = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   double bid        = SymbolInfoDouble(Symbol(),SYMBOL_BID);
   double spread     = ask - bid;
   int spread_points = (int)MathRound(spread/SymbolInfoDouble(Symbol(),SYMBOL_POINT))*2;
   return (spread_points);

}


double OrdersBuyMinSL()
{
   double stoploss = 0;
   
   double minstoplevel = MinStopLoss();
   stoploss            = NormalizeDouble(Bid - minstoplevel*Point,Digits);

   return (stoploss);
}

double OrdersSellMinSL()
{
   double stoploss = 0;
   
   double minstoplevel = MinStopLoss();
   stoploss            = NormalizeDouble(Ask + minstoplevel*Point,Digits);

   return (stoploss);
}


void breakeven()
{  
   if(BreakEvenDeals = true)
   {
   
   for(int i=0; i<OrdersTotal(); i++)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         double NoLoss, Commission, Profit, Swap;
         Commission = NormalizeDouble(OrderCommission(), Digits);
         Profit = NormalizeDouble(OrderProfit(), Digits);
         Swap = NormalizeDouble(OrderSwap(), Digits);
   
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic  && Profit - (Swap + Commission) >= NormalizeDouble(0, Digits) && (Ask > OrderOpenPrice() + NormalizeDouble(MinStopLoss1()*Point, Digits) + NormalizeDouble(comis()*Point, Digits) + NormalizeDouble(swap()*Point, Digits) || Bid < OrderOpenPrice() - NormalizeDouble(MinStopLoss1()*Point, Digits) + NormalizeDouble(comis()*Point, Digits) + NormalizeDouble(swap()*Point, Digits)))
         {
            if (OrderType() == OP_BUY)
            {   
               NoLoss  = OrderOpenPrice() + NormalizeDouble(MinStopLoss1()*Point, Digits) + NormalizeDouble(comis()*Point, Digits) + NormalizeDouble(swap()*Point, Digits);
               if (NormalizeDouble(OrderStopLoss(),Digits) < NormalizeDouble(NoLoss,Digits) && NormalizeDouble(NoLoss,Digits) != NormalizeDouble(OrderStopLoss(),Digits) && NormalizeDouble(NoLoss, Digits) <= NormalizeDouble(OrdersBuyMinSL(), Digits))
               bool modify = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(NoLoss,Digits), OrderTakeProfit(), 0, clrNONE);
            }
            if (OrderType() == OP_SELL) 
            {
               NoLoss  = OrderOpenPrice() - NormalizeDouble(MinStopLoss1()*Point, Digits) + NormalizeDouble(comis()*Point, Digits) + NormalizeDouble(swap()*Point, Digits);
               if (NormalizeDouble(OrderStopLoss(),Digits) > NormalizeDouble(NoLoss,Digits) && NormalizeDouble(NoLoss,Digits) != NormalizeDouble(OrderStopLoss(),Digits) && NormalizeDouble(NoLoss, Digits) >= NormalizeDouble(OrdersSellMinSL(), Digits))
               bool modify = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(NoLoss,Digits), OrderTakeProfit(), 0, clrNONE);
            }
         }
      }
   }
}
}
   

int MinSpread()
{
   double ask        = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   double bid        = SymbolInfoDouble(Symbol(),SYMBOL_BID);
   double spread     = ask - bid;
   int spread_points = (int)MathRound(spread/SymbolInfoDouble(Symbol(),SYMBOL_POINT));
   return (spread_points);
}

 int CountBuyStop()
{
   int count = 0;
   
   for (int i = OrdersTotal() - 1; i >= 0; i --)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_BUYSTOP)
            count ++;
      }
   }
   return (count);
}

int CountSellStop()
{
   int count = 0;
   
   for (int i = OrdersTotal() - 1; i >= 0; i --)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_SELLSTOP)
            count ++;
      }
   }
   return (count);
 }
 
void OnTimer()
  {
   ModifyPendingOrders(Signal);
  }

void Tline(string name,datetime tim1,double pr1,datetime tim2,double pr2,color col,bool fl=false)
  {
   if(!opnovis)return;
   if(ObjectFind(name)<0){if(!ObjectCreate(name,OBJ_TREND,0,tim1,pr1,tim2,pr2))return;}
   ObjectSetInteger(0,name,OBJPROP_COLOR,col);
   ObjectSetInteger(0,name,OBJPROP_TIME1,tim1);
   ObjectSetInteger(0,name,OBJPROP_TIME2,tim2);
   ObjectSetDouble(0,name,OBJPROP_PRICE1,pr1);
   ObjectSetDouble(0,name,OBJPROP_PRICE2,pr2);
   if(fl)ChartRedraw();
  }
double GetDou(string name,int id)
  {
   double res=0.0;
   if(opnovis && ObjectFind(name)>-1)res=ObjectGetDouble(0,name,id);
   return(res);
  }
void DelBP(string name)
{
   if(!opnovis)return;
   int obj=ObjectsTotal();
   for(int i=obj-1;i>=0;i--)
   {
      if(StringFind(ObjectName(i),name,0)==0)ObjectDelete(ObjectName(i));
   }
}

void ModifyPendingOrders(bool& ar[])
{
   static int sec;
   if(sec<0)
   {
      double up=GetDou(Com+"Up",OBJPROP_PRICE1),dn=GetDou(Com+"Dn",OBJPROP_PRICE1);
      if((up>0.0 && !(up-Ask>miz)) || (dn>0.0 && !(Bid-dn>miz))){sec=TimeModify+1;ArrayInitialize(ar,false);}
   }
   if(sec==0)
   {
      datetime tim1=Time[0],tim2=tim1+_Period*240;
      double prup=Ask+SteepModify*_Point,prdn=Bid-SteepModify*_Point;
      Tline(Com+"Up",tim1,prup,tim2,prup,UpCol);
      Tline(Com+"Dn",tim1,prdn,tim2,prdn,DnCol,true);
      ArrayInitialize(ar,true);
      bool res;
      for( int i=0; i<OrdersTotal(); i++)        
      {
         if(OrderSelect(i,SELECT_BY_POS)==true)
         { 
            if( OrderSymbol()==Symbol() && OrderMagicNumber() == Magic)
            { 
               if(OrderType() == OP_BUYSTOP && OrderStopLoss()!= NormalizeDouble(Ask + PriceSteep*Point -StopLoss*Point, Digits) && OrderTakeProfit() != NormalizeDouble(Ask+ PriceSteep*Point + TakeProfit*Point, Digits) )
               {
               res = OrderModify(OrderTicket(),NormalizeDouble(Ask+PriceSteep*Point,Digits), NormalizeDouble(Ask + PriceSteep*Point -StopLoss*Point, Digits), NormalizeDouble(Ask+ PriceSteep*Point + TakeProfit*Point, Digits),0,clrNONE);ar[0]=true;ar[1]=false;
               }
               if(OrderType() == OP_SELLSTOP && OrderStopLoss()!= NormalizeDouble(Bid - PriceSteep*Point + StopLoss*Point, Digits) && OrderTakeProfit() != NormalizeDouble(Bid - PriceSteep*Point -TakeProfit*Point, Digits) )
               {
               res = OrderModify(OrderTicket(),NormalizeDouble(Bid-PriceSteep*Point,Digits),NormalizeDouble(Bid - PriceSteep*Point + StopLoss*Point, Digits), NormalizeDouble(Bid - PriceSteep*Point -TakeProfit*Point, Digits),0,clrNONE);ar[1]=true;ar[0]=false;
               }
            }   
         }
      }
   }
   sec--;   
}

double profhistory(string t,int x, int m)
{  string sym=""; int z=0 ; double prof=0;
   if ( t=="") sym=Symbol(); else sym = t ;
   for( int i=OrdersHistoryTotal()-1; i>=0; i-- )               
   if ( OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) == true )                        
   if ( OrderSymbol() == sym && (OrderMagicNumber() == m || m==-1 ) && OrderType()<=1) 
   if ( x == -1 || OrderType() == x )
   if ( OrderCloseTime()>z)  {z =OrderCloseTime(); prof=OrderProfit();}
return(prof);}



double Profit(int Bar) 
{
   double OProfit = 0;
   for (int i = 0; i < OrdersHistoryTotal(); i ++) 
   {
      if (!(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))) break;
      if ((OrderSymbol() == Symbol() && OrderMagicNumber() == Magic ) || ( Magic < 0 && Symboll == "-1" ) || (Symboll == OrderSymbol()) || (Symboll == "0" && OrderSymbol() == Symbol()))
      if (OrderCloseTime() >= iTime(Symbol(), PERIOD_D1, Bar) && OrderCloseTime() < iTime(Symbol(), PERIOD_D1, Bar) + 86400) OProfit += OrderProfit();
   }
   return (OProfit);
}

double ProfitMons(int Bar) 
{
   double OProfit = 0;
   for (int i = 0; i < OrdersHistoryTotal(); i ++) 
   {
      if (!(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))) break;
      if ((OrderSymbol() == Symbol() && OrderMagicNumber() == Magic ) || ( Magic < 0 && Symboll == "-1" ) || (Symboll == OrderSymbol()) || (Symboll == "0" && OrderSymbol() == Symbol()))
      if (OrderCloseTime() >= iTime(Symbol(), PERIOD_MN1, Bar) && OrderCloseTime() < iTime(Symbol(), PERIOD_MN1, Bar) + 2592000) OProfit += OrderProfit();
   }
   return (OProfit);
}


double lotshistory(string t,int x, int m) 
{  string sym=""; int z=0 ; double lot=0; 
   if ( t=="") sym=Symbol(); else sym = t ; 
   int d=OrdersHistoryTotal(),i;for( i=0;i<=d;i++)                
   if ( OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) == true )                         
   if ( OrderSymbol() == sym && (OrderMagicNumber() == m || m==-1 ) && OrderType()<=1)  
   if ( x == -1 || OrderType() == x ) 
   if ( OrderCloseTime()>z)  {z  =OrderCloseTime(); lot=OrderLots();} 
return(lot);}   

double ProfitIFStopInCurrency(string sy="", int op=-1, int mn=-1) 
{
  if (sy=="0") sy=Symbol();  
  int    i, k = OrdersTotal(); 
  int    m = 0;                  
  double l;                  
  double p;                  
  double t;                  
  double v;                  
  double s = 0;                

  for (i=0; i<k; i++) 
  {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
    {
      if ((OrderSymbol()==sy || sy=="") && (mn<0 || OrderMagicNumber()==mn)) 
      {
        if ((OrderType()==OP_BUY || OrderType()==OP_SELL) && (op<0 || OrderType()==op)) 
        {
          l=MarketInfo(OrderSymbol(), MODE_LOTSIZE);
          p=MarketInfo(OrderSymbol(), MODE_POINT);
          t=MarketInfo(OrderSymbol(), MODE_TICKSIZE);
          v=MarketInfo(OrderSymbol(), MODE_TICKVALUE);
          if (OrderType()==OP_BUY) {
            if (m==0) s-=(OrderOpenPrice()-OrderStopLoss())/p*v*OrderLots();
            if (m==1) s-=(OrderOpenPrice()-OrderStopLoss())/p*v/t/l*OrderLots();
            if (m==2) s-=(OrderOpenPrice()-OrderStopLoss())/p*v*OrderLots();
            s+=OrderCommission()+OrderSwap();
          }
          if (OrderType()==OP_SELL) 
          {
            if (OrderStopLoss()>0) 
            {
              if (m==0) s-=(OrderStopLoss()-OrderOpenPrice())/p*v*OrderLots();
              if (m==1) s-=(OrderStopLoss()-OrderOpenPrice())/p*v/t/l*OrderLots();
              if (m==2) s-=(OrderStopLoss()-OrderOpenPrice())/p*v*OrderLots();
              s+=OrderCommission()+OrderSwap();
            } else s=-AccountBalance();
          }
        }
      }
    }
  }
  if (AccountBalance()+s<0) s=-AccountBalance(); 
  return(s);
}

int BHTP()
{
   int tf=PeriodBH;
   int res=0,i=0;
   BarHistory=int(MathMin(iBars(_Symbol,tf),BarHistory));
   for(i=0;i<BarHistory;i++)
   res+=int(MathAbs(iHigh(_Symbol,tf,i)-iLow(_Symbol,tf,i))/_Point);
   res=int((res/BarHistory)*RBHTP);
   return(res);
}

int BHSL()
{
   int tf=PeriodBH;
   int res=0,i=0;
   BarHistory=int(MathMin(iBars(_Symbol,tf),BarHistory));
   for(i=0;i<BarHistory;i++)
   res+=int(MathAbs(iHigh(_Symbol,tf,i)-iLow(_Symbol,tf,i))/_Point);
   res=int((res/BarHistory)/RBHSL);
   return(res);
}

int BHT()
{
   int tf=PeriodBH;
   int res=0,i=0;
   BarHistory=int(MathMin(iBars(_Symbol,tf),BarHistory));
   for(i=0;i<BarHistory;i++)
   res+=int(MathAbs(iHigh(_Symbol,tf,i)-iLow(_Symbol,tf,i))/_Point);
   res=int((res/BarHistory)*RBHT);
   return(res);
}

int BHTS()
{
   int tf=PeriodBH;
   int res=0,i=0;
   BarHistory=int(MathMin(iBars(_Symbol,tf),BarHistory));
   for(i=0;i<BarHistory;i++)
   res+=int(MathAbs(iHigh(_Symbol,tf,i)-iLow(_Symbol,tf,i))/_Point);
   res=int((res/BarHistory)/RBHTS);
   return(res);
}
int BHTSP()
{
   int tf=PeriodBH;
   int res=0,i=0;
   BarHistory=int(MathMin(iBars(_Symbol,tf),BarHistory));
   for(i=0;i<BarHistory;i++)
   res+=int(MathAbs(iHigh(_Symbol,tf,i)-iLow(_Symbol,tf,i))/_Point);
   res=int((res/BarHistory)/RBHTSP);
   return(res);
}

int BHTM()
{
   if (Digits == 3)
   {
   int tf=PeriodBH;
   int res=0,i=0;
   BarHistory=int(MathMin(iBars(_Symbol,tf),BarHistory));
   for(i=0;i<BarHistory;i++)
   res+=int(MathAbs(iHigh(_Symbol,tf,i)-iLow(_Symbol,tf,i))/_Point);
   res=int(((res/BarHistory)/RBHTM)/10);
   return(res);
   }
   
   int tf=PeriodBH;
   int res=0,i=0;
   BarHistory=int(MathMin(iBars(_Symbol,tf),BarHistory));
   for(i=0;i<BarHistory;i++)
   res+=int(MathAbs(iHigh(_Symbol,tf,i)-iLow(_Symbol,tf,i))/_Point);
   res=int((res/BarHistory)/RBHTM);
   return(res);
}

int BHSM()
{
   int tf=PeriodBH;
   int res=0,i=0;
   BarHistory=int(MathMin(iBars(_Symbol,tf),BarHistory));
   for(i=0;i<BarHistory;i++)
   res+=int(MathAbs(iHigh(_Symbol,tf,i)-iLow(_Symbol,tf,i))/_Point);
   res=int((res/BarHistory)/RBHSM);
   return(res);
}

int BHPS()
{
   int tf=PeriodBH;
   int res=0,i=0;
   BarHistory=int(MathMin(iBars(_Symbol,tf),BarHistory));
   for(i=0;i<BarHistory;i++)
   res+=int(MathAbs(iHigh(_Symbol,tf,i)-iLow(_Symbol,tf,i))/_Point);
   res=int((res/BarHistory)/RBHPS);
   return(res);
}

int BHID()
{
   int tf=PeriodBH;
   int res=0,i=0;
   BarHistory=int(MathMin(iBars(_Symbol,tf),BarHistory));
   for(i=0;i<BarHistory;i++)
   res+=int(MathAbs(iHigh(_Symbol,tf,i)-iLow(_Symbol,tf,i))/_Point);
   res=int((res/BarHistory)/RBHID);
   return(res);
}
double LotByRisk()
{
   double Free =AccountFreeMargin();
   double LotVal =MarketInfo(Symbol(),MODE_TICKVALUE);
   double Min_Lot =MarketInfo(Symbol(),MODE_MINLOT);
   double Max_Lot =MarketInfo(Symbol(),MODE_MAXLOT);
   double Step1 =MarketInfo(Symbol(),MODE_LOTSTEP);
   double Lot = MathFloor((Free*MaxRisk/100)/(BHSL()*LotVal)/Step1)*Step1;
   if(Lot<Min_Lot) Lot=Min_Lot;
   if(Lot>Max_Lot) Lot=Max_Lot;
   if(MaxRisk ==0) Lot=Lots;
   if(GetLastError()==134) Lot=Lots;
   return(Lot);
} 

void CloseAllOrders()
{ 
if(DayOfWeek() == 5 && Hour() >= TimeFriday)
{
   for( int i=0; i < OrdersTotal(); i++)        
      {
         if(OrderSelect(i,SELECT_BY_POS) == true)
         { 
            if(OrderSymbol()== Symbol() && OrderMagicNumber() == Magic)
            {  
               if(CountBuy() + CountSell() > 0)
               {
                  if(OrderType() == OP_SELL)
                  {
                     bool CloseSellOrders = OrderClose(OrderTicket(), OrderLots(), Ask, 0, clrNONE);
                  }
                  if(OrderType() == OP_BUY)
                  {
                     bool CloseBuyOrders = OrderClose(OrderTicket(), OrderLots(), Bid, 0, clrNONE);
                  }
               }
               
               if(CountBuyStop() + CountSellStop() > 0)
               {
                  if(OrderType() == OP_SELLSTOP)
                  {
                     bool CloseSellOrders = OrderDelete(OrderTicket(), clrNONE);
                  }
                  if(OrderType() == OP_BUYSTOP)
                  {
                     bool CloseBuyOrders = OrderDelete(OrderTicket(), clrNONE);
                  }
               }
            }   
         }  
      }
   }
}

void ClosePendingOrder()
{  
   if (CountBuy() + CountSell() > 0) 
   {
      for( int i=0; i < OrdersTotal(); i++)        
      {
         if(OrderSelect(i,SELECT_BY_POS) == true)
         { 
            if(OrderSymbol()== Symbol() && OrderMagicNumber() == Magic)
            {  
               if(OrderType() == OP_SELLSTOP)
               {
                  bool CloseSellOrders = OrderDelete(OrderTicket(), clrNONE);
               }
               if(OrderType() == OP_BUYSTOP)
               {
                  bool CloseBuyOrders = OrderDelete(OrderTicket(), clrNONE);
               }
            }
         }  
      }
   } 
}  

