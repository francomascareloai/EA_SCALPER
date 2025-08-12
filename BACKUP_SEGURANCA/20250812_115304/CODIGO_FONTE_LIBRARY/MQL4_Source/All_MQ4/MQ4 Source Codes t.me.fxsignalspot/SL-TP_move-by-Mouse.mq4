//+----------------------------------------------------------------------------+
//|                                                     e-MoveSLTPbyMouse.mq4  |
//|                                                                            |
//|                                                    Ким Игорь В. aka KimIV  |
//|                                                       http://www.kimiv.ru  |
//|                                                                            |
//|  31.03.2008  Советник для перемещения уровней SL и TP с помощью мыши.      |
//|  08.04.2008  Нормирование уровней SL и TP под размер тика.                 |
//+----------------------------------------------------------------------------+
#property copyright "Ким Игорь В. aka KimIV"
#property link      "http://www.kimiv.ru"

//------- Внешние параметры советника -----------------------------------------+
extern string _P_Expert = "---------- Parameters of e-MoveSL&TPbyMouse";
extern int    Language    = 1;         // Язык: 0-English, 1-Русский
extern double IntUpdate   = 0.371;     // Интервал обновления в секундах
extern bool   PrintEnable = True;      // Разрешить печать в журнал

extern string _P_Graphics = "---------- Parameters of Graphic Objects";
extern color StopColor = Red;          // Цвет линии уровня StopLoss
extern int   StopStyle = 3;            // Стиль линии уровня StopLoss
extern int   StopWidth = 0;            // Толщина линии уровня StopLoss
extern color TakeColor = Red;          // Цвет линии уровня TakeProfit
extern int   TakeStyle = 3;            // Стиль линии уровня TakeProfit
extern int   TakeWidth = 0;            // Толщина линии уровня TakeProfit

//------- Глобальные переменные советника -------------------------------------+
color  clModifyBuy  = Aqua;            // Цвет значка модификации покупки
color  clModifySell = Tomato;          // Цвет значка модификации продажи
string msg[4][2];

//------- Подключение внешних модулей -----------------------------------------+
#include <stdlib.mqh>                  // Стандартная библиотека


//+----------------------------------------------------------------------------+
//|                                                                            |
//|  ПРЕДОПРЕДЕЛЁННЫЕ ФУНКЦИИ                                                  |
//|                                                                            |
//+----------------------------------------------------------------------------+
//|  expert initialization function                                            |
//+----------------------------------------------------------------------------+
void init() {
  msg[0][0]="Adviser will is started by next tick";
  msg[0][1]="Советник будет запущен следующим тиком";
  msg[1][0]="Button is not pressed \"Enable experts for running\"";
  msg[1][1]="Отжата кнопка \"Разрешить запуск советников\"";
  msg[2][0]="IS ABSENT relationship with trade server\n"+
            "Adviser is STOPPED";
  msg[2][1]="ОТСУТСТВУЕТ связь с торговым сервером\n"+
            "Советник ОСТАНОВЛЕН";
  msg[3][0]="Button is not pressed \"Enable experts for running\"\n"+
            "Expert Adviser is STOPPED";
  msg[3][1]="Отжата кнопка \"Разрешить запуск советников\"\n"+
            "Советник ОСТАНОВЛЕН";

  if (Language<0 || Language>1) Message("Language is invalid");
  if (IsExpertEnabled()) {
    if (IntUpdate>0) start();
    else Message(msg[0][Language]);
  } else Message(msg[1][Language]);
Print("init");
}

//+----------------------------------------------------------------------------+
//|  expert deinitialization function                                          |
//+----------------------------------------------------------------------------+
void deinit() {
  int    i, k=ObjectsTotal();
  string on;

  // удаление линий
  for (i=0; i<k; i++) {
    on=ObjectName(i);
    if (StringSubstr(on, 0, 2)=="sl") ObjectDelete(on);
    if (StringSubstr(on, 0, 2)=="tp") ObjectDelete(on);
  }
  Comment("");
}

//+----------------------------------------------------------------------------+
//|  expert start function                                                     |
//+----------------------------------------------------------------------------+
void start() {
  if (IntUpdate<=0) ManageLines();
  else {
    while (IsExpertEnabled() && !IsStopped()) {
      if (IsConnected()) ManageLines();
      else { Comment(msg[2][Language]); return; }
      Sleep(1000*IntUpdate);
    }
    Message(msg[3][Language]);
  }
}


//+----------------------------------------------------------------------------+
//|                                                                            |
//|  ПОЛЬЗОВАТЕЛЬСКИЕ ФУНКЦИИ                                                  |
//|                                                                            |
//+----------------------------------------------------------------------------+
//|  Автор    : Ким Игорь В. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  Версия   : 01.09.2005                                                     |
//|  Описание : Выполняет поиск элемента массива по значению                   |
//|             и возвращает индекс найденного элемента или -1.                |
//+----------------------------------------------------------------------------+
//|  Параметры:                                                                |
//|    m - массив элементов                                                    |
//|    e - значение элемента                                                   |
//+----------------------------------------------------------------------------+
int ArraySearchInt(int& m[], int e) {
  for (int i=0; i<ArraySize(m); i++) {
    if (m[i]==e) return(i);
  }
  return(-1);
}

//+----------------------------------------------------------------------------+
//|  Автор    : Ким Игорь В. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  Версия   : 30.03.2008                                                     |
//|  Описание : Прорисовка горизонтальной линии                                |
//+----------------------------------------------------------------------------+
//|  Параметры:                                                                |
//|    cl - цвет линии                                                         |
//|    nm - наименование               ("" - время открытия текущего бара)     |
//|    p1 - ценовой уровень            (0  - Bid)                              |
//|    st - стиль линии                (0  - простая линия)                    |
//|    wd - ширина линии               (0  - по умолчанию)                     |
//+----------------------------------------------------------------------------+
void DrawHLine(color cl, string nm="", double p1=0, int st=0, int wd=0) {
  if (p1==0) p1=Bid;
  if (ObjectFind(nm)<0) {
    ObjectCreate(nm, OBJ_HLINE, 0, 0,0);
    ObjectSet(nm, OBJPROP_PRICE1, p1);
    ObjectSet(nm, OBJPROP_COLOR , cl);
    ObjectSet(nm, OBJPROP_STYLE , st);
    ObjectSet(nm, OBJPROP_WIDTH , wd);
  }
}

//+----------------------------------------------------------------------------+
//|  Автор    : Ким Игорь В. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  Версия   : 01.09.2005                                                     |
//|  Описание : Возвращает наименование торговой операции                      |
//+----------------------------------------------------------------------------+
//|  Параметры:                                                                |
//|    op - идентификатор торговой операции                                    |
//+----------------------------------------------------------------------------+
string GetNameOP(int op) {
  switch (op) {
    case OP_BUY      : return("Buy");
    case OP_SELL     : return("Sell");
    case OP_BUYLIMIT : return("Buy Limit");
    case OP_SELLLIMIT: return("Sell Limit");
    case OP_BUYSTOP  : return("Buy Stop");
    case OP_SELLSTOP : return("Sell Stop");
    default          : return("Unknown Operation");
  }
}

//+----------------------------------------------------------------------------+
//|  Автор    : Ким Игорь В. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  Версия   : 01.02.2008                                                     |
//|  Описание : Возвращает одно из двух значений взависимости от условия.      |
//+----------------------------------------------------------------------------+
string IIFs(bool condition, string ifTrue, string ifFalse) {
  if (condition) return(ifTrue); else return(ifFalse);
}

//+----------------------------------------------------------------------------+
//|  Управление линиями                                                        |
//+----------------------------------------------------------------------------+
void ManageLines() {
  double ms=MarketInfo(Symbol(), MODE_STOPLEVEL);
  double ts=MarketInfo(Symbol(), MODE_TICKSIZE);
  double pp;                 // ценовой уровень StopLoss/TakeProfit
  double np;                 // ненормированный ценовой уровень StopLoss/TakeProfit
  int    i, k;               // счётчик и количество объектов/ордеров
  int    r;                  // тикет искомой позиции
  int    t[];                // массив тикетов существующих позиций
  string on;                 // наименование объекта
  string st;                 // строка комментария

  // заполнение массива тикетов существующих позиций
  ArrayResize(t, 0);
  k=OrdersTotal();
  for (i=0; i<k; i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderSymbol()==Symbol()) {
        if (OrderType()==OP_BUY || OrderType()==OP_SELL) {
          if (OrderStopLoss()>0 || OrderTakeProfit()>0) {
            r=ArraySize(t);
            ArrayResize(t, r+1);
            t[r]=OrderTicket();
          }
        }
      }
    }
  }

  // удаление лишних (ненужных) линий, модификация уровней
  k=ObjectsTotal();
  for (i=0; i<k; i++) {
    on=ObjectName(i);
    if (StringSubstr(on, 0, 2)=="sl") {
      // тикет позиции
      r=StrToInteger(StringSubstr(on, 2));
      if (ArraySearchInt(t, r)<0) ObjectDelete(on);
      else {
        if (OrderSelect(r, SELECT_BY_TICKET)) {
          if (OrderStopLoss()>0) {
            np=NormalizeDouble(ObjectGet(on, OBJPROP_PRICE1), Digits);
            if (ts>0) pp=NormalizeDouble(np/ts, 0)*ts; else pp=np;
            if (pp!=np) ModifyHLine(on, pp);
            if (OrderType()==OP_BUY && pp>Bid-(ms+1)*Point) pp=Bid-(ms+1)*Point;
            if (OrderType()==OP_SELL && pp<Ask+(ms+1)*Point) pp=Ask+(ms+1)*Point;
            ModifyOrder(-1, NormalizeDouble(pp, Digits), -1);
          } else ObjectDelete(on);
        }
      }
    }
    if (StringSubstr(on, 0, 2)=="tp") {
      // тикет позиции
      r=StrToInteger(StringSubstr(on, 2));
      if (ArraySearchInt(t, r)<0) ObjectDelete(on);
      else {
        if (OrderSelect(r, SELECT_BY_TICKET)) {
          if (OrderTakeProfit()>0) {
            np=NormalizeDouble(ObjectGet(on, OBJPROP_PRICE1), Digits);
            if (ts>0) pp=NormalizeDouble(np/ts, 0)*ts; else pp=np;
            if (pp!=np) ModifyHLine(on, pp);
            if (OrderType()==OP_BUY && pp<Bid+(ms+1)*Point) pp=Bid+(ms+1)*Point;
            if (OrderType()==OP_SELL && pp>Ask-(ms+1)*Point) pp=Ask-(ms+1)*Point;
            ModifyOrder(-1, -1, NormalizeDouble(pp, Digits));
          } else ObjectDelete(on);
        }
      }
    }
  }

  // установка недостающих линий
  k=OrdersTotal();
  for (i=0; i<k; i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderSymbol()==Symbol()) {
        if (OrderType()==OP_BUY || OrderType()==OP_SELL) {
          if (OrderStopLoss()>0) {
            DrawHLine(StopColor, "sl"+OrderTicket(), OrderStopLoss(),
                      StopStyle, StopWidth);
          }
          if (OrderTakeProfit()>0) {
            DrawHLine(TakeColor, "tp"+OrderTicket(), OrderTakeProfit(),
                      TakeStyle, TakeWidth);
          }
        }
      }
    }
  }

  st="Language="+IIFs(Language==0, "English", "Русский")
    +"  IntUpdate="+DoubleToStr(IntUpdate, 4)
    +"  "+IIFs(PrintEnable, "PrintEnable", "");
  Comment(st);
}

//+----------------------------------------------------------------------------+
//|  Вывод сообщения в коммент и в журнал                                      |
//|  Параметры:                                                                |
//|    m - текст сообщения                                                     |
//+----------------------------------------------------------------------------+
void Message(string m) {
  Comment(m);
  if (StringLen(m)>0 && PrintEnable) Print(m);
}

//+----------------------------------------------------------------------------+
//|  Автор    : Ким Игорь В. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  Версия   : 08.04.2008                                                     |
//|  Описание : Модификация ценового уровня горизонтальной линии               |
//+----------------------------------------------------------------------------+
//|  Параметры:                                                                |
//|    nm - наименование               ("" - время открытия текущего бара)     |
//|    p1 - ценовой уровень            (0  - Bid)                              |
//+----------------------------------------------------------------------------+
void ModifyHLine(string nm="", double p1=0) {
  if (p1==0) p1=Bid;
  if (ObjectFind(nm)>=0) ObjectSet(nm, OBJPROP_PRICE1, p1);
}

//+----------------------------------------------------------------------------+
//|  Автор    : Ким Игорь В. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  Версия   : 28.03.2008                                                     |
//|  Описание : Модификация ордера. Версия функции для тестов на истории.      |
//+----------------------------------------------------------------------------+
//|  Параметры:                                                                |
//|    pp - цена открытия позиции, установки ордера                            |
//|    sl - ценовой уровень стопа                                              |
//|    tp - ценовой уровень тейка                                              |
//|    ex - дата истечения                                                     |
//+----------------------------------------------------------------------------+
void ModifyOrder(double pp=-1, double sl=0, double tp=0, datetime ex=0) {
  int    dg=MarketInfo(OrderSymbol(), MODE_DIGITS), er;
  double op=NormalizeDouble(OrderOpenPrice() , dg);
  double os=NormalizeDouble(OrderStopLoss()  , dg);
  double ot=NormalizeDouble(OrderTakeProfit(), dg);
  color  cl;

  if (pp<=0) pp=OrderOpenPrice();
  if (sl<0 ) sl=OrderStopLoss();
  if (tp<0 ) tp=OrderTakeProfit();
  
  pp=NormalizeDouble(pp, dg);
  sl=NormalizeDouble(sl, dg);
  tp=NormalizeDouble(tp, dg);

  if (pp!=op || sl!=os || tp!=ot) {
    if (MathMod(OrderType(), 2)==0) cl=clModifyBuy; else cl=clModifySell;
    if (!OrderModify(OrderTicket(), pp, sl, tp, ex, cl)) {
      er=GetLastError();
      Print("Error(",er,") modifying order: ",ErrorDescription(er));
      Print("Ask=",Ask," Bid=",Bid," sy=",OrderSymbol(),
            " op="+GetNameOP(OrderType())," pp=",pp," sl=",sl," tp=",tp);
    }
  }
}
//+----------------------------------------------------------------------------+

