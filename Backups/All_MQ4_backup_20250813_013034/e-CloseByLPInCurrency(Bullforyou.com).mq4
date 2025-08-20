//+----------------------------------------------------------------------------+
//|                                                 e-CloseByLPInCurrency.mq4  |
//|                                                                            |
//|  ����������������: ��� ����� �. aka KimIV  [http://www.kimiv.ru]           |
//|                                                                            |
//|  03.07.2013  �������� ��������� ��� ������� ��� ���������� ���������       |
//|              ������ ������ ������ ��� ������� � ������ ��������.           |
//|              ������� ����� ����������� �� �������, ���� � ������.          |
//+----------------------------------------------------------------------------+
#property copyright "��� ����� �. aka KimIV"
#property link      "http://www.kimiv.ru"

//------- ������� ��������� ��������� ------------------------------------------
extern string _P_Expert = "---------- ��������� ���������";
extern int    NumberAccount = 0;            // ����� ��������� �����
extern string symbol        = "";           // �������� ����������
                                            //   ""  - �����
                                            //   "0" - �������
extern int    Operation     = -1;           // �������� ��������:
                                            //   -1 - �����
                                            //    0 - OP_BUY
                                            //    1 - OP_SELL
extern int    MagicNumber   = -1;           // MagicNumber
extern double TargetLoss    = 30;           // ������� ������ � ������ ��������
extern double TargetProfit  = 60;           // ������� ������� � ������ ��������
extern bool   DeleteOrders  = True;         // ������� ���������� ������
extern bool   CloseTerminal = False;        // ������� ��������
extern bool   ShowComment   = True;         // ���������� �����������

extern string _P_Performance = "---------- ��������� ����������";
extern bool   UseSound      = False;             // ������������ �������� ������
extern string SoundSuccess  = "ok.wav";          // ���� ������
extern string SoundError    = "timeout.wav";     // ���� ������
extern int    Slippage      = 2;                 // ��������������� ����
extern int    NumberOfTry   = 3;                 // ���������� �������

//------- ���������� ���������� ��������� --------------------------------------
bool  gbDisabled  = False;             // ���� ���������� ���������
bool  gbNoInit    = False;             // ���� ��������� �������������
color clCloseBuy  = Blue;              // ���� ������ �������� �������
color clCloseSell = Red;               // ���� ������ �������� �������
color clDelete    = Yellow;            // ���� ������ �������� ������

//------- ���������� ������� ������� -------------------------------------------
#include <stdlib.mqh>
#import "user32.dll"
   int GetParent(int hWnd);
   int PostMessageA(int hWnd, int Msg, int wParam, int lParam);
#import
#define WM_CLOSE 0x0010


//+----------------------------------------------------------------------------+
//|                                                                            |
//|  ����������˨���� �������                                                  |
//|                                                                            |
//+----------------------------------------------------------------------------+
//|  expert initialization function                                            |
//+----------------------------------------------------------------------------+
void init() {
  gbNoInit=False;
  if (!IsTradeAllowed()) {
    Message("��� ���������� ������ ��������� ����������\n"+
            "��������� ��������� ���������");
    gbNoInit=True; return;
  }
  if (!IsLibrariesAllowed()) {
    Message("��� ���������� ������ ��������� ����������\n"+
            "��������� ������ �� ������� ���������");
    gbNoInit=True; return;
  }
  if (Operation<-1 || Operation>1) {
    Message("������������ �������� �������� ��������� Operation");
    gbNoInit=True; return;
  }
  if (symbol!="0" && symbol!="") {
    symbol=StringUpper(symbol);
    if (MarketInfo(StringUpper(symbol), MODE_BID)==0) {
      Message("� ������ ����� ����������� ������ "+symbol);
      gbNoInit=True; return;
    }
  }
  if (!IsTesting()) {
    if (IsExpertEnabled()) start();
    else Message("������ ������ \"��������� ������ ����������\"");
  }
}

//+----------------------------------------------------------------------------+
//|  expert deinitialization function                                          |
//+----------------------------------------------------------------------------+
void deinit() { if (!IsTesting()) Comment(""); }

//+----------------------------------------------------------------------------+
//|  expert start function                                                     |
//+----------------------------------------------------------------------------+
void start() {
  double pr=0;
  string st="";

  if (gbDisabled) {
    Message("����������� ������! �������� ����������!"); return;
  }
  if (gbNoInit) {
    Message("�� ������� ���������������� ��������!"); return;
  }
  if (!IsTesting()) {
    if (NumberAccount>0 && NumberAccount!=AccountNumber()) {
      Message("��������� �������� �� ����� "+AccountNumber());
      return;
    } else Comment("");
  }

  pr=GetProfitOpenPosInCurrency(symbol, Operation, MagicNumber);
  if (pr<-TargetLoss || pr>TargetProfit) {
    ClosePosFirstProfit(symbol, Operation, MagicNumber);
    ClosePositions(symbol, Operation, MagicNumber);
    if (DeleteOrders) DeleteOrders(symbol, Operation, MagicNumber);
    if (CloseTerminal) CloseTerminal();
  }
  if (ShowComment) {
    st="NumberAccount="+IIFs(NumberAccount<=0, "All", DoubleToStr(NumberAccount, 0))
      +"  Symbol="+IIFs(symbol=="", "All", IIFs(symbol=="0", Symbol(), StringUpper(symbol)))
      +"  Operation="+IIFs(Operation<0, "All", GetNameOP(Operation))
      +"  MagicNumber="+IIFs(MagicNumber<0, "All", DoubleToStr(MagicNumber, 0));
    st=st+"\n";
    st=st+"������� ������="+DoubleToStr(-TargetLoss,2)+" "+AccountCurrency()+"  �����";
    if (pr<0) st=st+"�� ������=";
    else st=st+"�� �������=";
    st=st+DoubleToStr(pr,2)+" "+AccountCurrency()+"  ������� �������="+DoubleToStr(TargetProfit,2)+" "+AccountCurrency();
    Comment(st);
  }
}


//+----------------------------------------------------------------------------+
//|                                                                            |
//|  ���������������� �������                                                  |
//|                                                                            |
//+----------------------------------------------------------------------------+
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������  : 26.03.2013                                                      |
//|  ��������: �������� ����� �������������� ��������� �������                 |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    ll - ������ ����.                                                       |
//+----------------------------------------------------------------------------+
void ClosePosBySelect(double ll=0) {
  bool   fc;
  color  clClose;
  double pa, pb, pp;
  int    dg=MarketInfo(OrderSymbol(), MODE_DIGITS), err, it;

  if (OrderType()==OP_BUY || OrderType()==OP_SELL) {
    for (it=1; it<=NumberOfTry; it++) {
      if (!IsTesting() && (!IsExpertEnabled() || IsStopped())) {
        Message("ClosePosBySelect(): ��������� ������ �������");
        break;
      }
      while (!IsTradeAllowed()) Sleep(5000);
      RefreshRates();
      pa=MarketInfo(OrderSymbol(), MODE_ASK);
      pb=MarketInfo(OrderSymbol(), MODE_BID);
      if (OrderType()==OP_BUY) {
        pp=pb; clClose=clCloseBuy;
      } else {
        pp=pa; clClose=clCloseSell;
      }
      if (ll<=0) ll=OrderLots();
      pp=NormalizeDouble(pp, dg);
      fc=OrderClose(OrderTicket(), ll, pp, Slippage, clClose);
      if (fc) {
        if (UseSound) PlaySound(SoundSuccess); break;
      } else {
        err=GetLastError();
        if (UseSound) PlaySound(SoundError);
        if (err==146) while (IsTradeContextBusy()) Sleep(1000*11);
        Message("Error("+err+") Close "+GetNameOP(OrderType())+" "
               +ErrorDescription(err)+", try "+it+"\n"
               +OrderTicket()+"  Ask="+DoubleToStr(pa,dg)
               +"  Bid="+DoubleToStr(pb,dg)+"  pp="+DoubleToStr(pp,dg)+"\n"
               +"sy="+OrderSymbol()+"  ll="+DoubleToStr(ll,2)
               +"  sl="+DoubleToStr(OrderStopLoss(),dg)
               +"  tp="+DoubleToStr(OrderTakeProfit(),dg)+"  mn="+OrderMagicNumber());
        Sleep(1000*5);
      }
    }
  } else Message("������������ �������� ��������. Close "+GetNameOP(OrderType()));
}

//+----------------------------------------------------------------------------+
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 19.02.2008                                                     |
//|  �������� : �������� ������� �� �������� ���� ������� ����������           |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    sy - ������������ �����������   (""   - ����� ������,                   |
//|                                     NULL - ������� ������)                 |
//|    op - ��������                   (-1   - ����� �������)                  |
//|    mn - MagicNumber                (-1   - ����� �����)                    |
//+----------------------------------------------------------------------------+
void ClosePosFirstProfit(string sy="", int op=-1, int mn=-1) {
  int i, k=OrdersTotal();
  if (sy=="0") sy=Symbol();

  // ������� ��������� ���������� �������
  for (i=k-1; i>=0; i--) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if ((OrderSymbol()==sy || sy=="") && (op<0 || OrderType()==op)) {
        if (OrderType()==OP_BUY || OrderType()==OP_SELL) {
          if (mn<0 || OrderMagicNumber()==mn) {
            if (OrderProfit()+OrderCommission()+OrderSwap()>0) ClosePosBySelect();
          }
        }
      }
    }
  }
  // ����� ��� ���������
  k=OrdersTotal();
  for (i=k-1; i>=0; i--) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if ((OrderSymbol()==sy || sy=="") && (op<0 || OrderType()==op)) {
        if (OrderType()==OP_BUY || OrderType()==OP_SELL) {
          if (mn<0 || OrderMagicNumber()==mn) ClosePosBySelect();
        }
      }
    }
  }
}

//+----------------------------------------------------------------------------+
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 19.03.2013                                                     |
//|  �������� : �������� ������� �� �������� ����                              |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    sy - ������������ �����������   (""   - ����� ������,                   |
//|                                     NULL - ������� ������)                 |
//|    op - ��������                   (-1   - ����� �������)                  |
//|    mn - MagicNumber                (-1   - ����� �����)                    |
//|    ll - ������ ����.                                                       |
//+----------------------------------------------------------------------------+
void ClosePositions(string sy="", int op=-1, int mn=-1, double ll=0) {
  int i, k=OrdersTotal();

  if (sy=="0") sy=Symbol();
  for (i=k-1; i>=0; i--) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if ((OrderSymbol()==sy || sy=="") && (op<0 || OrderType()==op)) {
        if (OrderType()==OP_BUY || OrderType()==OP_SELL) {
          if (mn<0 || OrderMagicNumber()==mn) {
            if (ll<=0) ll=OrderLots();
            if (ll>OrderLots()) {
              ClosePosBySelect(OrderLots());
              ll-=OrderLots();
            } else ClosePosBySelect(ll);
          }
        }
      }
    }
  }
}

//+----------------------------------------------------------------------------+
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 18.04.2013                                                     |
//|  �������� : ��������� �������� ��������.                                   |
//+----------------------------------------------------------------------------+
void CloseTerminal() {
  Print("��������� ������� CloseTerminal()");
  int hwnd=WindowHandle(Symbol(), Period());
  int hwnd_parent=0;

  while (hwnd==0) {
    hwnd=WindowHandle(Symbol(), Period());
    if (IsStopped()) break;
    Sleep(5);
  }
  while(!IsStopped()) {
    hwnd=GetParent(hwnd);
    if (hwnd==0) break;
    hwnd_parent=hwnd;
  }
  if (hwnd_parent!=0) PostMessageA(hwnd_parent, WM_CLOSE, 0, 0);
}

//+----------------------------------------------------------------------------+
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 08.03.2013                                                     |
//|  �������� : �������� ������ �������������� ���������� ������.              |
//+----------------------------------------------------------------------------+
void DeleteOrderBySelect() {
  bool fd;
  int  err, it;

  for (it=1; it<=NumberOfTry; it++) {
    if (!IsTesting() && (!IsExpertEnabled() || IsStopped())) break;
    while (!IsTradeAllowed()) Sleep(5000);
    fd=OrderDelete(OrderTicket(), clDelete);
    if (fd) {
      if (UseSound) PlaySound(SoundSuccess); break;
    } else {
      err=GetLastError();
      if (UseSound) PlaySound(SoundError);
      Message("Error("+err+") delete order "+GetNameOP(OrderType())
        +": "+ErrorDescription(err)+", try "+it);
      Sleep(1000*5);
    }
  }
}

//+----------------------------------------------------------------------------+
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 08.03.2013                                                     |
//|  �������� : �������� �������                                               |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    sy - ������������ �����������   (""   - ����� ������,                   |
//|                                     NULL - ������� ������)                 |
//|    op - ��������                   (-1   - ����� �����)                    |
//|    mn - MagicNumber                (-1   - ����� �����)                    |
//+----------------------------------------------------------------------------+
void DeleteOrders(string sy="", int op=-1, int mn=-1) {
  int i, k=OrdersTotal(), ot;

  if (sy=="0") sy=Symbol();
  for (i=k-1; i>=0; i--) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      ot=OrderType();
      if (ot>1 && ot<6) {
        if ((OrderSymbol()==sy || sy=="") && (op<0 || ot==op)) {
          if (mn<0 || OrderMagicNumber()==mn) DeleteOrderBySelect();
        }
      }
    }
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
    case OP_BUYLIMIT : return("BuyLimit");
    case OP_SELLLIMIT: return("SellLimit");
    case OP_BUYSTOP  : return("BuyStop");
    case OP_SELLSTOP : return("SellStop");
    default          : return("Unknown Operation");
  }
}

//+----------------------------------------------------------------------------+
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 19.02.2008                                                     |
//|  �������� : ���������� ��������� ������ �������� ������� � ������ �������� |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    sy - ������������ �����������   (""   - ����� ������,                   |
//|                                     NULL - ������� ������)                 |
//|    op - ��������                   (-1   - ����� �������)                  |
//|    mn - MagicNumber                (-1   - ����� �����)                    |
//+----------------------------------------------------------------------------+
double GetProfitOpenPosInCurrency(string sy="", int op=-1, int mn=-1) {
  double p=0;
  int    i, k=OrdersTotal();

  if (sy=="0") sy=Symbol();
  for (i=0; i<k; i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if ((OrderSymbol()==sy || sy=="") && (op<0 || OrderType()==op)) {
        if (OrderType()==OP_BUY || OrderType()==OP_SELL) {
          if (mn<0 || OrderMagicNumber()==mn) {
            p+=OrderProfit()+OrderCommission()+OrderSwap();
          }
        }
      }
    }
  }
  return(p);
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
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 08.03.2013                                                     |
//|  �������� : ����� ���������� ���������.                                    |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    ms - ����� ���������                                                    |
//|    nv - ����� ����������� ������ ���������:   (0-����, 1-���)              |
//|           Alert, Comment, Print, SendMail, SendNotification                |
//|    am - ���� ���� ������������� ���������                                  |
//+----------------------------------------------------------------------------+
void Message(string ms, string nv="01100", bool am=False) {
  static string prevMessage="";
  string as[];
  int    i, k;

  if (StrToInteger(StringSubstr(nv, 1, 1))==1) Comment(ms);
  if ((StringLen(ms)>0) && (am || prevMessage!=ms)) {
    if (StrToInteger(StringSubstr(nv, 0, 1))==1) {
      k=StrSplit(ms, as, "\n");
      for (i=0; i<k; i++) Alert(as[i]);
    }
    if (StrToInteger(StringSubstr(nv, 2, 1))==1) {
      k=StrSplit(ms, as, "\n");
      for (i=0; i<k; i++) Print(as[i]);
    }
    if (StrToInteger(StringSubstr(nv, 3, 1))==1) SendMail(WindowExpertName(), ms);
    if (StrToInteger(StringSubstr(nv, 4, 1))==1) SendNotification(ms);
    prevMessage=ms;
  }
}

//+----------------------------------------------------------------------------+
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 01.09.2005                                                     |
//|  �������� : ���������� ������ � ������� ��������                           |
//+----------------------------------------------------------------------------+
string StringUpper(string s) {
  int c, i, k=StringLen(s), n;
  for (i=0; i<k; i++) {
    n=0;
    c=StringGetChar(s, i);
    if (c>96 && c<123) n=c-32;    // a-z -> A-Z
    if (c>223 && c<256) n=c-32;   // �-� -> �-�
    if (c==184) n=168;            //  �  ->  �
    if (n>0) s=StringSetChar(s, i, n);
  }
  return(s);
}

//+----------------------------------------------------------------------------+
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 20.01.2012                                                     |
//|  �������� : ��������� ������ �� ������ ���������                           |
//+----------------------------------------------------------------------------+
//|  �������:                                                                  |
//|    ���������� ��������� � �������                                          |
//|  ���������:                                                                |
//|    st - ������ � �������������                                             |
//|    as - ��������� ������                                                   |
//|    de - �����������                                                        |
//+----------------------------------------------------------------------------+
int StrSplit(string st, string& as[], string de=",") { 
  int    i=0, np;
  string stp;

  ArrayResize(as, 0);
  while (StringLen(st)>0) {
    np=StringFind(st, de);
    if (np<0) {
      stp=st;
      st="";
    } else {
      if (np==0) stp=""; else stp=StringSubstr(st, 0, np);
      st=StringSubstr(st, np+1);
    }
    i++;
    ArrayResize(as, i);
    as[i-1]=stp;
  }
  return(ArraySize(as));
}
//+----------------------------------------------------------------------------+

