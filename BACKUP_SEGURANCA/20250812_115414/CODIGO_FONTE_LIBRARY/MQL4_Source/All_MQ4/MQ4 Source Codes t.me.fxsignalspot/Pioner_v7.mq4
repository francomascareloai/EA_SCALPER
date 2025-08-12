//+------------------------------------------------------------------+
//|                                                       Pioner.mq4 |
//+------------------------------------------------------------------+

#property copyright "RickD"
#property link      "http://onix-trade.net/e2e"

#include <stdlib.mqh>
#include <WinUser32.mqh>

string vers = "6.0";

extern double Lots = 0.3;
extern int Grid = 9;
extern int StopLoss = 200;
extern bool FixedLot = true;
extern int Slippage = 3;
extern int Magic = 110705;
extern bool StopOnRoll = false;
extern bool StopAll = false;
extern int MySleep = 3000;

int BuyCnt = 0;
int SellCnt = 0;
int BuyLimitCnt = 0;
int SellLimitCnt = 0;
int BuyStopCnt = 0;
int SellStopCnt = 0;
int Step = 0;
double lotseq[5] = {1,1,3.5,8.3,20.7};

#define DIRECT      1
#define REVERSE     2

#define STATE_0     0
#define STEP_1      1
#define STEP_UP     2
#define STEP_DOWN   3
#define ROLL_UP     4
#define ROLL_DOWN   5

string gPrefix = "Pioner_";
int PrevState = STATE_0;


int init() {
  if (IsTesting()) {
    PrevState = STATE_0;
    return(0);
  }
  
  int ret = MessageBox("Установить глобальные переменные в начальное состояние?", "Question", MB_YESNO|MB_ICONQUESTION|MB_TOPMOST);
  if (ret == IDYES) {
    PrevState = STATE_0;
    SetGlobals();
  } else {
    GetGlobals();
  }

  return(0);
}

int deinit() {
  return(0);
}

int start() {
  if (StopAll) {
    CloseAll();
    PrevState = STATE_0;
    SetGlobals();
    return(0);
  }

  BuyCnt = 0;
  SellCnt = 0;
  BuyLimitCnt = 0;
  SellLimitCnt = 0;
  BuyStopCnt = 0;
  SellStopCnt = 0;
  
  int cnt = OrdersTotal();
  for (int i=0; i < cnt; i++) {
    OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    
    if (OrderSymbol() != Symbol()) continue;
    if (OrderMagicNumber() != Magic) continue;
    
    int type = OrderType();
    switch (type) {
      case OP_BUY: BuyCnt++; break;
      case OP_SELL: SellCnt++; break;
      case OP_BUYLIMIT: BuyLimitCnt++; break;
      case OP_SELLLIMIT: SellLimitCnt++; break;
      case OP_BUYSTOP: BuyStopCnt++; break;
      case OP_SELLSTOP: SellStopCnt++; break;
      
      default:
        continue;
    }
  }

  bool Step1, StepUp, StepDown, RollUp, RollDown;
  
  Step1 = (!StopOnRoll && PrevState == STATE_0 && 
    BuyCnt == 0 && SellCnt == 0 && BuyStopCnt == 0 && SellLimitCnt == 0 && 
    BuyLimitCnt == 0 && SellStopCnt == 0);
     
  StepUp = ((PrevState == STEP_1 || PrevState == STEP_UP || PrevState == ROLL_UP) &&
    BuyCnt == 1 && SellCnt > 0 && BuyStopCnt == 0 && SellLimitCnt == 0 && 
    BuyLimitCnt == 1 && SellStopCnt == 1);

  StepDown = ((PrevState == STEP_1 || PrevState == STEP_DOWN || PrevState == ROLL_DOWN) &&
    SellCnt == 1 && BuyCnt > 0 && BuyStopCnt == 1 && SellLimitCnt == 1 && 
    SellStopCnt == 0 && BuyLimitCnt == 0);
       
  RollDown = ((PrevState == STEP_UP /*|| PrevState == ROLL_UP*/) &&
    BuyCnt == 2 && SellCnt == 1  && BuyStopCnt == 1 && SellLimitCnt == 1 && 
    SellStopCnt == 0 && BuyLimitCnt == 0);
  
  RollUp = ((PrevState == STEP_DOWN /*|| PrevState == ROLL_DOWN*/) &&
    BuyCnt == 1 && SellCnt == 2 && BuyStopCnt == 0 && SellLimitCnt == 0 && 
    BuyLimitCnt == 1 && SellStopCnt == 1);
    

  if (Step1) Step = 1;        
  else if (StepUp) Step = SellCnt;
  else if (StepDown) Step = -BuyCnt;
  else if (RollUp) Step = 2;
  else if (RollDown) Step = -2;
  
  if (!IsTesting()) 
    Comment("Version: ", vers,
      "\nBuyCnt: ", BuyCnt, "    SellCnt: ", SellCnt,
      "\nBuyStopCnt: ", BuyStopCnt, "    SellLimitCnt: ", SellLimitCnt,
      "\nSellStopCnt: ", SellStopCnt, "    BuyLimitCnt: ", BuyLimitCnt,
      "\nStep: ", Step, "    PrevState: ", State2Str(PrevState));

  if (Step1) {
    OnStep1();
    return(0);
  }  
    
  if (StepUp) {
    OnStepUp();
    return(0);
  }
  
  if (StepDown) {
    OnStepDown();
    return(0);
  }

  if (RollUp) {
    OnRollUp();
    return(0);
  }

  if (RollDown) {
    OnRollDown();
    return(0);
  }

  return(0);
}

int OnStep1() {
  Print("Func: Step1");
  Print("Step: ", Step);
  Print("PrevState: ", State2Str(PrevState));

  double spr = MarketInfo(Symbol(), MODE_SPREAD)*Point;
  
  int ticket = Buy(LotsRisk(Lots), Ask, Ask-StopLoss*Point, Bid+Grid*Point, "*");
  OrderSelect(ticket, SELECT_BY_TICKET);
  double AskB = OrderOpenPrice();
  double BidB = AskB - spr;
  
  ticket = Sell(LotsRisk(Lots), Bid, Bid+StopLoss*Point, Ask-Grid*Point, "*");
  OrderSelect(ticket, SELECT_BY_TICKET);
  double BidS = OrderOpenPrice();
  double AskS = BidS + spr;
    
  SetBuyStop(LotsRisk(Lots), AskB+Grid*Point, AskB+Grid*Point-StopLoss*Point, BidB+2*Grid*Point, "");
  SetSellLimit(LotsRisk(Lots), BidB+Grid*Point, BidB+Grid*Point+StopLoss*Point, AskB, "");
  SetSellStop(LotsRisk(Lots), BidS-Grid*Point, BidS-Grid*Point+StopLoss*Point, AskS-2*Grid*Point, "");
  SetBuyLimit(LotsRisk(Lots), AskS-Grid*Point, AskS-Grid*Point-StopLoss*Point, BidS, "");
  
  PrevState = STEP_1;
  SetGlobals();
  return(0);
}

int OnStepUp() {
  Print("Func: StepUp");
  Print("Step: ", Step);
  Print("PrevState: ", State2Str(PrevState));

  int ticket = GetOrder(OP_SELL, 1, REVERSE, MODE_TRADES);
  double Bid0 = OrderOpenPrice(); 
  double Ask0 = Bid0 + MarketInfo(Symbol(), MODE_SPREAD)*Point;
  double TP = OrderTakeProfit();

  //Выставляем ордера по ходу движения
  SetBuyStop(LotsRisk(Lots), Ask0+Grid*Point, Ask0+Grid*Point-StopLoss*Point, Bid0+2*Grid*Point, "");
  SetSellLimit(lotseq[Step]*LotsRisk(Lots), Bid0+Grid*Point, Bid0+Grid*Point+StopLoss*Point, Ask0, "");

  //Выставляем противоположенные ордера
  SetSellStop(LotsRisk(Lots), Bid0-Grid*Point, Bid0-Grid*Point+StopLoss*Point, Ask0-2*Grid*Point, "");
  SetBuyLimit(LotsRisk(Lots), Ask0-Grid*Point, Ask0-Grid*Point-StopLoss*Point, Bid0, "");

  //Подтягиваем стопы предыдущих SELL ордеров до уровня последнего
  int cnt = OrdersTotal();
  for (int i=0; i < cnt; i++) {
    OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    
    if (OrderSymbol() != Symbol()) continue;
    if (OrderMagicNumber() != Magic) continue;
    if (OrderType() != OP_SELL) continue;
    if (OrderTicket() == ticket) continue;
    
    ModifyOrder(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), TP);
  }
  
  //Удаляем устаревшие
  ticket = GetOrder(OP_SELLSTOP, 1, DIRECT, MODE_TRADES);
  if (ticket != -1) DeleteOrder(ticket);
  
  ticket = GetOrder(OP_BUYLIMIT, 1, DIRECT, MODE_TRADES);
  if (ticket != -1) DeleteOrder(ticket);
  
  PrevState = STEP_UP;
  SetGlobals();
  return(0);
}

int OnStepDown() {
  Print("Func: StepDown");
  Print("Step: ", Step);    
  Print("PrevState: ", State2Str(PrevState));

  int ticket = GetOrder(OP_BUY, 1, REVERSE, MODE_TRADES);
  double Ask0 = OrderOpenPrice(); 
  double Bid0 = Ask0 - MarketInfo(Symbol(), MODE_SPREAD)*Point;
  double TP = OrderTakeProfit();

  //Выставляем ордера по ходу движения
  SetSellStop(LotsRisk(Lots), Bid0-Grid*Point, Bid0-Grid*Point+StopLoss*Point, Ask0-2*Grid*Point, "");
  SetBuyLimit(lotseq[-Step]*LotsRisk(Lots), Ask0-Grid*Point, Ask0-Grid*Point-StopLoss*Point, Bid0, "");

  //Выставляем противоположенные ордера
  SetBuyStop(LotsRisk(Lots), Ask0+Grid*Point, Ask0+Grid*Point-StopLoss*Point, Bid0+2*Grid*Point, "");
  SetSellLimit(LotsRisk(Lots), Bid0+Grid*Point, Bid0+Grid*Point+StopLoss*Point, Ask0, "");

  //Подтягиваем стопы предыдущих BUY ордеров до уровня последнего
  int cnt = OrdersTotal();
  for (int i=0; i < cnt; i++) {
    OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    
    if (OrderSymbol() != Symbol()) continue;
    if (OrderMagicNumber() != Magic) continue;
    if (OrderType() != OP_BUY) continue;
    if (OrderTicket() == ticket) continue;
    
    ModifyOrder(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), TP);
  }
  
  //Удаляем устаревшие
  ticket = GetOrder(OP_BUYSTOP, 1, DIRECT, MODE_TRADES);
  if (ticket != -1) DeleteOrder(ticket);
  
  ticket = GetOrder(OP_SELLLIMIT, 1, DIRECT, MODE_TRADES);
  if (ticket != -1) DeleteOrder(ticket);
  
  PrevState = STEP_DOWN;
  SetGlobals();
  return(0);
}

int OnRollUp() {
  Print("Func: RollUp");
  Print("Step: ", Step);    
  Print("PrevState: ", State2Str(PrevState));    

  if (StopOnRoll) {
    CloseAll();
    PrevState = STATE_0;
    SetGlobals();
    return(0);
  }
  
  PrevState = ROLL_UP;
  SetGlobals();

  OnStepUp();
  return(0);
}

int OnRollDown() {
  Print("Func: RollDown");
  Print("Step: ", Step);    
  Print("PrevState: ", State2Str(PrevState));    

  if (StopOnRoll) {
    CloseAll();
    PrevState = STATE_0;
    SetGlobals();
    return(0);
  }

  PrevState = ROLL_DOWN;
  SetGlobals();
  
  OnStepDown();
  return(0);
}

//-------------------------------------------------------------------------

int GetOrder(int type, int pos=1, int order=DIRECT, int mode=MODE_TRADES) {
  return (GetOrderEx(type, 0, pos, order, mode));
}

int GetOrderEx(int type, double lot, int pos=1, int order=DIRECT, int mode=MODE_TRADES) {
  return (GetOrderExT(type, lot, pos, order, mode));
  
  switch (order) {
    case DIRECT:
    case REVERSE:
      break;
      
    default: 
      return(-1);
  }

  switch (mode) {
    case MODE_TRADES:
      int cnt = OrdersTotal();
      break;
    case MODE_HISTORY:
      cnt = HistoryTotal();
      break;
      
    default: 
      return(-1);
  }

  int ind = 1;
  if (order == DIRECT) {
    for (int i=0; i < cnt; i++) {
      OrderSelect(i, SELECT_BY_POS, mode);
    
      if (OrderSymbol() != Symbol()) continue;
      if (OrderMagicNumber() != Magic) continue;
      if (OrderType() != type) continue;
      if (lot > 0 && DoubleToStr(OrderLots(), 1) != DoubleToStr(lot, 1)) continue;
    
      if (ind == pos) return(OrderTicket());
      ind++;
    }
  }

  if (order == REVERSE) {
    for (i=cnt-1; i >= 0; i--) {
      OrderSelect(i, SELECT_BY_POS, mode);
    
      if (OrderSymbol() != Symbol()) continue;
      if (OrderMagicNumber() != Magic) continue;
      if (OrderType() != type) continue;
      if (lot > 0 && DoubleToStr(OrderLots(), 1) != DoubleToStr(lot, 1)) continue;
    
      if (ind == pos) return(OrderTicket());
      ind++;
    }
  }

  return(-1);
}

int GetOrderExT(int type, double lot, int pos=1, int order=DIRECT, int mode=MODE_TRADES) {
  switch (order) {
    case DIRECT:
    case REVERSE:
      break;
      
    default: 
      return(-1);
  }

  switch (mode) {
    case MODE_TRADES:
      int cnt = OrdersTotal();
      break;
    case MODE_HISTORY:
      cnt = HistoryTotal();
      break;
      
    default: 
      return(-1);
  }

  int Tickets[];
  ArrayResize(Tickets, cnt);
  for (int i=0; i < cnt; i++) {
    OrderSelect(i, SELECT_BY_POS, mode);
    Tickets[i] = OrderTicket();
  }
  
  for (i=0; i < cnt; i++) {
    for (int j=i+1; j < cnt; j++) {
      OrderSelect(Tickets[i], SELECT_BY_TICKET, mode);
      int dt1 = OrderCloseTime();
      OrderSelect(Tickets[j], SELECT_BY_TICKET, mode);
      int dt2 = OrderCloseTime();
      
      if (mode == MODE_TRADES) {
        if (Tickets[i] > Tickets[j]) {
          int tmp = Tickets[i];
          Tickets[i] = Tickets[j];
          Tickets[j] = tmp;
        }
      }
      
      if (mode == MODE_HISTORY) {
        if (dt1 > dt2) {
          tmp = Tickets[i];
          Tickets[i] = Tickets[j];
          Tickets[j] = tmp;
        }
      }
    }
  }
  
  int ind = 1;
  if (order == DIRECT) {
    for (i=0; i < cnt; i++) {
      OrderSelect(Tickets[i], SELECT_BY_TICKET, mode);
    
      if (OrderSymbol() != Symbol()) continue;
      if (OrderMagicNumber() != Magic) continue;
      if (OrderType() != type) continue;
      if (lot > 0 && DoubleToStr(OrderLots(), 1) != DoubleToStr(lot, 1)) continue;
    
      if (ind == pos) return(OrderTicket());
      ind++;
    }
  }

  if (order == REVERSE) {
    for (i=cnt-1; i >= 0; i--) {
      OrderSelect(Tickets[i], SELECT_BY_TICKET, mode);
    
      if (OrderSymbol() != Symbol()) continue;
      if (OrderMagicNumber() != Magic) continue;
      if (OrderType() != type) continue;
      if (lot > 0 && DoubleToStr(OrderLots(), 1) != DoubleToStr(lot, 1)) continue;
    
      if (ind == pos) return(OrderTicket());
      ind++;
    }
  }

  return(-1);
}

int Buy(double lot, double price, double SL, double TP, string comment) {
Print(
"Buy", 
" lot= ", DoubleToStr(lot, 2), 
" price= ", DoubleToStr(price, 4),
" SL= ", DoubleToStr(SL, 4),
" TP= ", DoubleToStr(TP, 4),
" Ask= ", DoubleToStr(Ask, 4),
" Bid= ", DoubleToStr(Bid, 4)
);

  double lev = MarketInfo(Symbol(), MODE_STOPLEVEL)*Point;
  
  if (SL >= price-lev) {
    Alert("Buy: Invalid SL");
    return(-1);
  }

  if (TP <= price+lev) {
    Alert("Buy: Invalid TP");
    return(-1);
  }

  int res = -1;
  while (res < 0) {
    RefreshRates();
    res = OrderSend(Symbol(), OP_BUY, NormalizeDouble(lot,1), price, Slippage, SL, TP, comment, Magic);
   	if (res < 0) {
   	  Print("Error opening BUY order: ", ErrorDescription(GetLastError()));
			Sleep(6000);
		}
	}
	
	Sleep(MySleep);
	return(res);
}

int Sell(double lot, double price, double SL, double TP, string comment) {
Print(
"Sell", 
" lot= ", DoubleToStr(lot, 2), 
" price= ", DoubleToStr(price, 4),
" SL= ", DoubleToStr(SL, 4),
" TP= ", DoubleToStr(TP, 4),
" Ask= ", DoubleToStr(Ask, 4),
" Bid= ", DoubleToStr(Bid, 4)
);

  double lev = MarketInfo(Symbol(), MODE_STOPLEVEL)*Point;

  if (SL <= price+lev) {
    Alert("Sell: Invalid SL");
    return(-1);
  }

  if (TP >= price-lev) {
    Alert("Sell: Invalid TP");
    return(-1);
  }

  int res = -1;
  while (res < 0) {
    RefreshRates();
    res = OrderSend(Symbol(), OP_SELL, NormalizeDouble(lot,1), price, Slippage, SL, TP, comment, Magic);
   	if (res < 0) {
   	  Print("Error opening SELL order: ", ErrorDescription(GetLastError()));
			Sleep(6000);
		}
	}
	
	Sleep(MySleep);
	return(res);
}

int SetBuyStop(double lot, double price, double SL, double TP, string comment) {
Print(
"SetBuyStop", 
" lot= ", DoubleToStr(lot, 2), 
" price= ", DoubleToStr(price, 4),
" SL= ", DoubleToStr(SL, 4),
" TP= ", DoubleToStr(TP, 4),
" Ask= ", DoubleToStr(Ask, 4),
" Bid= ", DoubleToStr(Bid, 4)
);

  double lev = MarketInfo(Symbol(), MODE_STOPLEVEL)*Point;

  if (price <= Ask+lev) {
    Alert("SetBuyStop: Invalid Price");
    return(-1);
  }

  if (SL >= price-lev) {
    Alert("SetBuyStop: Invalid SL");
    return(-1);
  }

  if (TP <= price+lev) {
    Alert("SetBuyStop: Invalid TP");
    return(-1);
  }

  int res = -1;
  while (res < 0) {
    RefreshRates();
    res = OrderSend(Symbol(), OP_BUYSTOP, NormalizeDouble(lot,1), price, Slippage, SL, TP, comment, Magic);
   	if (res < 0) {
   	  Print("Error setting BUYSTOP order: ", ErrorDescription(GetLastError()));
			Sleep(6000);
		}
	}
	
	Sleep(MySleep);
	return(res);
}

int SetSellStop(double lot, double price, double SL, double TP, string comment) {
Print(
"SetSellStop", 
" lot= ", DoubleToStr(lot, 2), 
" price= ", DoubleToStr(price, 4),
" SL= ", DoubleToStr(SL, 4),
" TP= ", DoubleToStr(TP, 4),
" Ask= ", DoubleToStr(Ask, 4),
" Bid= ", DoubleToStr(Bid, 4)
);

  double lev = MarketInfo(Symbol(), MODE_STOPLEVEL)*Point;

  if (price >= Bid-lev) {
    Alert("SetSellStop: Invalid Price");
    return(-1);
  }

  if (SL <= price+lev) {
    Alert("SetSellStop: Invalid SL");
    return(-1);
  }

  if (TP >= price-lev) {
    Alert("SetSellStop: Invalid TP");
    return(-1);
  }
  
  int res = -1;
  while (res < 0) {
    RefreshRates();
    res = OrderSend(Symbol(), OP_SELLSTOP, NormalizeDouble(lot,1), price, Slippage, SL, TP, comment, Magic);
   	if (res < 0) {
   	  Print("Error setting SELLSTOP order: ", ErrorDescription(GetLastError()));
			Sleep(6000);
		}
	}
	
	Sleep(MySleep);
	return(res);
}

int SetBuyLimit(double lot, double price, double SL, double TP, string comment) {
Print(
"SetBuyLimit", 
" lot= ", DoubleToStr(lot, 2), 
" price= ", DoubleToStr(price, 4),
" SL= ", DoubleToStr(SL, 4),
" TP= ", DoubleToStr(TP, 4),
" Ask= ", DoubleToStr(Ask, 4),
" Bid= ", DoubleToStr(Bid, 4)
);

  double lev = MarketInfo(Symbol(), MODE_STOPLEVEL)*Point;

  if (price >= Ask-lev) {
    Alert("SetBuyLimit: Invalid Price");
    return(-1);
  }

  if (SL >= price-lev) {
    Alert("SetBuyLimit: Invalid SL");
    return(-1);
  }

  if (TP <= price+lev) {
    Alert("SetBuyLimit: Invalid TP");
    return(-1);
  }

  int res = -1;
  while (res < 0) {
    RefreshRates();
    res = OrderSend(Symbol(), OP_BUYLIMIT, NormalizeDouble(lot,1), price, Slippage, SL, TP, comment, Magic);
    if (res < 0) {
      Print("Error setting BUYLIMIT order: ", ErrorDescription(GetLastError()));
      Sleep(6000);
    }
  }
	
  Sleep(MySleep);
  return(res);
}

int SetSellLimit(double lot, double price, double SL, double TP, string comment) {
Print(
"SetSellLimit", 
" lot= ", DoubleToStr(lot, 2), 
" price= ", DoubleToStr(price, 4),
" SL= ", DoubleToStr(SL, 4),
" TP= ", DoubleToStr(TP, 4),
" Ask= ", DoubleToStr(Ask, 4),
" Bid= ", DoubleToStr(Bid, 4)
);

  double lev = MarketInfo(Symbol(), MODE_STOPLEVEL)*Point;

  if (price <= Bid+lev) {
    Alert("SetSellLimit: Invalid Price");
    return(-1);
  }

  if (SL <= price+lev) {
    Alert("SetSellLimit: Invalid SL");
    return(-1);
  }

  if (TP >= price-lev) {
    Alert("SetSellLimit: Invalid TP");
    return(-1);
  }

  int res = -1;
  while (res < 0) {
    RefreshRates();
    res = OrderSend(Symbol(), OP_SELLLIMIT, NormalizeDouble(lot,1), price, Slippage, SL, TP, comment, Magic);
    if (res < 0) {
      Print("Error setting SELLLIMIT order: ", ErrorDescription(GetLastError()));
      Sleep(6000);
    }
  }
	
  Sleep(MySleep);
  return(res);
}

int ModifyOrder(int ticket, double price, double SL, double TP) {
Print(
"ModifyOrder", 
" ticket= ", ticket, 
" price= ", DoubleToStr(price, 4),
" SL= ", DoubleToStr(SL, 4),
" TP= ", DoubleToStr(TP, 4),
" Ask= ", DoubleToStr(Ask, 4),
" Bid= ", DoubleToStr(Bid, 4)
);

  double lev = MarketInfo(Symbol(), MODE_STOPLEVEL)*Point;
  
  OrderSelect(ticket, SELECT_BY_TICKET);
  int type = OrderType();

  if (type == OP_BUY) {
    if (SL >= Bid-lev) {
      Alert("ModifyOrder: Invalid SL");
      return(-1);
    }

    if (TP <= Bid+lev) {
      Alert("ModifyOrder: Invalid TP");
      return(-1);
    }
  }
  
  if (type == OP_BUYLIMIT) {
    if (price >= Ask-lev) {
      Alert("ModifyOrder: Invalid Price");
      return(-1);
    }
    
    if (SL >= price-lev) {
      Alert("ModifyOrder: Invalid SL");
      return(-1);
    }

    if (TP <= price+lev) {
      Alert("ModifyOrder: Invalid TP");
      return(-1);
    }
  }

  if (type == OP_BUYSTOP) {
    if (price <= Ask+lev) {
      Alert("ModifyOrder: Invalid Price");
      return(-1);
    }
    
    if (SL >= price-lev) {
      Alert("ModifyOrder: Invalid SL");
      return(-1);
    }

    if (TP <= price+lev) {
      Alert("ModifyOrder: Invalid TP");
      return(-1);
    }
  }

  if (type == OP_SELL) {
    if (SL <= Ask+lev) {
      Alert("ModifyOrder: Invalid SL");
      return(-1);
    }

    if (TP >= Ask-lev) {
      Alert("ModifyOrder: Invalid TP");
      return(-1);
    }
  }
    
  if (type == OP_SELLLIMIT) {
    if (price <= Bid+lev) {
      Alert("ModifyOrder: Invalid Price");
      return(-1);
    }
    
    if (SL <= price+lev) {
      Alert("ModifyOrder: Invalid SL");
      return(-1);
    }

    if (TP >= price-lev) {
      Alert("ModifyOrder: Invalid TP");
      return(-1);
    }
  }

  if (type == OP_SELLSTOP) {
    if (price >= Bid-lev) {
      Alert("ModifyOrder: Invalid Price");
      return(-1);
    }
    
    if (SL <= price+lev) {
      Alert("ModifyOrder: Invalid SL");
      return(-1);
    }

    if (TP >= price-lev) {
      Alert("ModifyOrder: Invalid TP");
      return(-1);
    }
  }


  bool res = false;
  while (!res) {
    RefreshRates();
    res = OrderModify(ticket, price, SL, TP, 0);
    if (!res) {
      Print("OrderModify failed: ", ErrorDescription(GetLastError()));
      Sleep(6000);
    }
  }

  Sleep(MySleep);
  return(0);
}

int CloseOrder(int ticket, double lot, double price) {
Print(
"CloseOrder", 
" ticket= ", ticket, 
" lot= ", DoubleToStr(lot, 2), 
" price= ", DoubleToStr(price, 4),
" Ask= ", DoubleToStr(Ask, 4),
" Bid= ", DoubleToStr(Bid, 4)
);

  bool res = false;
  while (!res) {
    RefreshRates();
    res = OrderClose(ticket, lot, price, Slippage);
    if (!res) {
      Print("CloseOrder failed: ", ErrorDescription(GetLastError()));
      Sleep(6000);
    }
  }

  Sleep(MySleep);
  return(0);
}

int DeleteOrder(int ticket) {
  bool res = false;
  while (!res) {
    RefreshRates();
    res = OrderDelete(ticket);
    if (!res) {
      Print("DeleteOrder failed: ", ErrorDescription(GetLastError()));
		  Sleep(6000);
    }
  }

  Sleep(MySleep);
  return(0);
}

int CloseAll() {
  int cnt = OrdersTotal();
  for (int i=cnt-1; i >= 0; i--) {
    OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    
    if (OrderSymbol() != Symbol()) continue;
    if (OrderMagicNumber() != Magic) continue;
     
    int type = OrderType();
    switch(type) {
      case OP_BUY:
        CloseOrder(OrderTicket(), OrderLots(), Bid); 
        break;
        
      case OP_SELL:
        CloseOrder(OrderTicket(), OrderLots(), Ask);
        break; 
        
      case OP_BUYLIMIT:
      case OP_SELLLIMIT:
      case OP_BUYSTOP:
      case OP_SELLSTOP:
        DeleteOrder(OrderTicket());
        break;
    }
  }
  
  return(0);
}

double LotsRisk(double lot) {
  if (FixedLot) return (lot);
  
  double res = NormalizeDouble(AccountEquity()/7838, 1);
  if (res == 0) res = 0.1;
  return(res);
}

void GetGlobals() {
  if (!GlobalVariableCheck(gPrefix+"PrevState")) 
    PrevState = STATE_0;
  else 
    PrevState = GlobalVariableGet(gPrefix+"PrevState");
}

void SetGlobals() {
  GlobalVariableSet(gPrefix+"PrevState", PrevState);
}

string State2Str(int state) {
  switch (state) {
    case STATE_0: 
      return("STATE_0"); 

    case STEP_1: 
      return("STEP_1"); 
      
    case STEP_UP: 
      return("STEP_UP");
      
    case STEP_DOWN: 
      return("STEP_DOWN");
      
    case ROLL_UP: 
      return("ROLL_UP");
      
    case ROLL_DOWN: 
      return("ROLL_DOWN");
      
    default: 
      return("UNK_STATE");
  }
}

string Bool2Str(bool val) {
  if (!val) return("false");
  return("true");
}

string OP2Str(int type) {
  switch(type) {
    case OP_BUY: 
      return("OP_BUY"); 

    case OP_SELL: 
      return("OP_SELL"); 
      
    case OP_BUYLIMIT: 
      return("OP_BUYLIMIT");
      
    case OP_SELLLIMIT: 
      return("OP_SELLLIMIT");
            
    case OP_BUYSTOP: 
      return("OP_BUYSTOP");

    case OP_SELLSTOP: 
      return("OP_SELLSTOP");
      
    default: 
      return("UNK_TYPE");
  }
}

void PrintOrders() {
  Print("Func: PrintOrders");
  for (int i=0; i < OrdersTotal(); i++) {
    OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    Print(
     "  ticket= ", OrderTicket(), 
     "  type= ", OP2Str(OrderType()),
     "  lot= ", DoubleToStr(OrderLots(), 1),
     "  Open= ", OrderOpenPrice(),
     "  SL= ", OrderStopLoss(),
     "  TP= ", OrderTakeProfit());
  }
}