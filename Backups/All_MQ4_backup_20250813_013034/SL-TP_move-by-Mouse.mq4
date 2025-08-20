//+----------------------------------------------------------------------------+
//|                                                     e-MoveSLTPbyMouse.mq4  |
//|                                                                            |
//|                                                    ��� ����� �. aka KimIV  |
//|                                                       http://www.kimiv.ru  |
//|                                                                            |
//|  31.03.2008  �������� ��� ����������� ������� SL � TP � ������� ����.      |
//|  08.04.2008  ������������ ������� SL � TP ��� ������ ����.                 |
//+----------------------------------------------------------------------------+
#property copyright "��� ����� �. aka KimIV"
#property link      "http://www.kimiv.ru"

//------- ������� ��������� ��������� -----------------------------------------+
extern string _P_Expert = "---------- Parameters of e-MoveSL&TPbyMouse";
extern int    Language    = 1;         // ����: 0-English, 1-�������
extern double IntUpdate   = 0.371;     // �������� ���������� � ��������
extern bool   PrintEnable = True;      // ��������� ������ � ������

extern string _P_Graphics = "---------- Parameters of Graphic Objects";
extern color StopColor = Red;          // ���� ����� ������ StopLoss
extern int   StopStyle = 3;            // ����� ����� ������ StopLoss
extern int   StopWidth = 0;            // ������� ����� ������ StopLoss
extern color TakeColor = Red;          // ���� ����� ������ TakeProfit
extern int   TakeStyle = 3;            // ����� ����� ������ TakeProfit
extern int   TakeWidth = 0;            // ������� ����� ������ TakeProfit

//------- ���������� ���������� ��������� -------------------------------------+
color  clModifyBuy  = Aqua;            // ���� ������ ����������� �������
color  clModifySell = Tomato;          // ���� ������ ����������� �������
string msg[4][2];

//------- ����������� ������� ������� -----------------------------------------+
#include <stdlib.mqh>                  // ����������� ����������


//+----------------------------------------------------------------------------+
//|                                                                            |
//|  ����������˨���� �������                                                  |
//|                                                                            |
//+----------------------------------------------------------------------------+
//|  expert initialization function                                            |
//+----------------------------------------------------------------------------+
void init() {
  msg[0][0]="Adviser will is started by next tick";
  msg[0][1]="�������� ����� ������� ��������� �����";
  msg[1][0]="Button is not pressed \"Enable experts for running\"";
  msg[1][1]="������ ������ \"��������� ������ ����������\"";
  msg[2][0]="IS ABSENT relationship with trade server\n"+
            "Adviser is STOPPED";
  msg[2][1]="����������� ����� � �������� ��������\n"+
            "�������� ����������";
  msg[3][0]="Button is not pressed \"Enable experts for running\"\n"+
            "Expert Adviser is STOPPED";
  msg[3][1]="������ ������ \"��������� ������ ����������\"\n"+
            "�������� ����������";

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

  // �������� �����
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
//|  ���������������� �������                                                  |
//|                                                                            |
//+----------------------------------------------------------------------------+
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 01.09.2005                                                     |
//|  �������� : ��������� ����� �������� ������� �� ��������                   |
//|             � ���������� ������ ���������� �������� ��� -1.                |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    m - ������ ���������                                                    |
//|    e - �������� ��������                                                   |
//+----------------------------------------------------------------------------+
int ArraySearchInt(int& m[], int e) {
  for (int i=0; i<ArraySize(m); i++) {
    if (m[i]==e) return(i);
  }
  return(-1);
}

//+----------------------------------------------------------------------------+
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 30.03.2008                                                     |
//|  �������� : ���������� �������������� �����                                |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    cl - ���� �����                                                         |
//|    nm - ������������               ("" - ����� �������� �������� ����)     |
//|    p1 - ������� �������            (0  - Bid)                              |
//|    st - ����� �����                (0  - ������� �����)                    |
//|    wd - ������ �����               (0  - �� ���������)                     |
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
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 01.09.2005                                                     |
//|  �������� : ���������� ������������ �������� ��������                      |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    op - ������������� �������� ��������                                    |
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
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 01.02.2008                                                     |
//|  �������� : ���������� ���� �� ���� �������� ������������ �� �������.      |
//+----------------------------------------------------------------------------+
string IIFs(bool condition, string ifTrue, string ifFalse) {
  if (condition) return(ifTrue); else return(ifFalse);
}

//+----------------------------------------------------------------------------+
//|  ���������� �������                                                        |
//+----------------------------------------------------------------------------+
void ManageLines() {
  double ms=MarketInfo(Symbol(), MODE_STOPLEVEL);
  double ts=MarketInfo(Symbol(), MODE_TICKSIZE);
  double pp;                 // ������� ������� StopLoss/TakeProfit
  double np;                 // ��������������� ������� ������� StopLoss/TakeProfit
  int    i, k;               // ������� � ���������� ��������/�������
  int    r;                  // ����� ������� �������
  int    t[];                // ������ ������� ������������ �������
  string on;                 // ������������ �������
  string st;                 // ������ �����������

  // ���������� ������� ������� ������������ �������
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

  // �������� ������ (��������) �����, ����������� �������
  k=ObjectsTotal();
  for (i=0; i<k; i++) {
    on=ObjectName(i);
    if (StringSubstr(on, 0, 2)=="sl") {
      // ����� �������
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
      // ����� �������
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

  // ��������� ����������� �����
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

  st="Language="+IIFs(Language==0, "English", "�������")
    +"  IntUpdate="+DoubleToStr(IntUpdate, 4)
    +"  "+IIFs(PrintEnable, "PrintEnable", "");
  Comment(st);
}

//+----------------------------------------------------------------------------+
//|  ����� ��������� � ������� � � ������                                      |
//|  ���������:                                                                |
//|    m - ����� ���������                                                     |
//+----------------------------------------------------------------------------+
void Message(string m) {
  Comment(m);
  if (StringLen(m)>0 && PrintEnable) Print(m);
}

//+----------------------------------------------------------------------------+
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 08.04.2008                                                     |
//|  �������� : ����������� �������� ������ �������������� �����               |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    nm - ������������               ("" - ����� �������� �������� ����)     |
//|    p1 - ������� �������            (0  - Bid)                              |
//+----------------------------------------------------------------------------+
void ModifyHLine(string nm="", double p1=0) {
  if (p1==0) p1=Bid;
  if (ObjectFind(nm)>=0) ObjectSet(nm, OBJPROP_PRICE1, p1);
}

//+----------------------------------------------------------------------------+
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 28.03.2008                                                     |
//|  �������� : ����������� ������. ������ ������� ��� ������ �� �������.      |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    pp - ���� �������� �������, ��������� ������                            |
//|    sl - ������� ������� �����                                              |
//|    tp - ������� ������� �����                                              |
//|    ex - ���� ���������                                                     |
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

