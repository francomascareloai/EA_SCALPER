//+------------------------------------------------------------------+
//|                                                       Pioner.mq4 |
//+------------------------------------------------------------------+

#property copyright "RickD"
#property link      "http://onix-trade.net/e2e"

#include <stdlib.mqh>
#include <WinUser32.mqh>

extern double Lots = 0.1;
extern int Grid = 15;
extern int StopLoss = 200;
extern bool FixedLot = true;
extern int Slippage = 3;
extern int Magic = 110705;
extern bool StopOnRoll = false;
extern bool StopAll = false;

int BuyCnt = 0;
int SellCnt = 0;
int BuyLimitCnt = 0;
int SellLimitCnt = 0;
int BuyStopCnt = 0;
int SellStopCnt = 0;
int Step = 0;

#define FIRST_ORDER   1
#define LAST_ORDER    2

#define STATE_0     0
#define STEP_1      1
#define STEP_UP     2
#define STEP_DOWN   3
#define ROLL_UP     4
#define ROLL_DOWN   5

string gVarName = "Pioner_PrevState";
int PrevState = STATE_0;


int init() {
  int ret = MessageBox("Установить PrevState в начальное состояние?", "Question", MB_YESNO|MB_ICONQUESTION|MB_TOPMOST);
  if (ret == IDYES) {
    PrevState = STATE_0;
    SetPrevState(PrevState);
  }
  else {
    PrevState = GetPrevState();
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
    SetPrevState(PrevState);
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
  
  Step1 = (PrevState == STATE_0 && 
    BuyCnt == 0 && SellCnt == 0 && BuyStopCnt == 0 && SellLimitCnt == 0 && 
    BuyLimitCnt == 0 && SellStopCnt == 0);
     
  StepUp = ((PrevState == STEP_1 || PrevState == STEP_UP || PrevState == ROLL_UP) &&
    BuyCnt == 1 && SellCnt > 0 && BuyStopCnt == 0 && SellLimitCnt == 0 && 
    BuyLimitCnt == 1 && SellStopCnt == 1);

  StepDown = ((PrevState == STEP_1 || PrevState == STEP_DOWN || PrevState == ROLL_DOWN) &&
    SellCnt == 1 && BuyCnt > 0 && BuyStopCnt == 1 && SellLimitCnt == 1 && 
    SellStopCnt == 0 && BuyLimitCnt == 0);
       
  RollDown = ((PrevState == STEP_UP || PrevState == ROLL_UP) &&
    BuyCnt == 2 && SellCnt >= 2  && BuyStopCnt == 1 && SellLimitCnt == 1 && 
    SellStopCnt == 0 && BuyLimitCnt == 0);
  
  RollUp = ((PrevState == STEP_DOWN || PrevState == ROLL_DOWN) &&
    BuyCnt >= 2 && SellCnt == 2 && BuyStopCnt == 0 && SellLimitCnt == 0 && 
    BuyLimitCnt == 1 && SellStopCnt == 1);
    

  if (Step1) Step = 1;        
  else if (StepUp) Step = SellCnt;
  else if (StepDown) Step = -BuyCnt;
  else if (RollUp) Step = 2;
  else if (RollDown) Step = -2;
  
  if (!IsTesting()) 
    Comment("BuyCnt= ", BuyCnt, "    SellCnt= ", SellCnt,
      "\nBuyStopCnt= ", BuyStopCnt, "    SellLimitCnt= ", SellLimitCnt,
      "\nSellStopCnt= ", SellStopCnt, "    BuyLimitCnt= ", BuyLimitCnt,
      "\nStep= ", Step, "    PrevState= ", State2Str(PrevState),
      "\nStep1= ", Bool2Str(Step1),
      "\nStepUp= ", Bool2Str(StepUp), "    RollDown= ", Bool2Str(RollDown),
      "\nStepDown= ", Bool2Str(StepDown), "    RollUp= ", Bool2Str(RollUp));

  if (Step1) {
    Print("Func: Step1");
    Print("Step: ", Step);
    Print("PrevState: ", State2Str(PrevState));
    OnStep1();
    return(0);
  }  
    
  if (StepUp) {
    Print("Func: StepUp");
    Print("Step: ", Step);
    Print("PrevState: ", State2Str(PrevState));
    OnStepUp();
    return(0);
  }
  
  if (StepDown) {
    Print("Func: StepDown");
    Print("Step: ", Step);    
    Print("PrevState: ", State2Str(PrevState));
    OnStepDown();
    return(0);
  }

  if (RollUp) {
    Print("Func: RollUp");
    Print("Step: ", Step);    
    Print("PrevState: ", State2Str(PrevState));    
    OnRollUp();
    return(0);
  }

  if (RollDown) {
    Print("Func: RollDown");
    Print("Step: ", Step);    
    Print("PrevState: ", State2Str(PrevState));    
    OnRollDown();
    return(0);
  }

  return(0);
}

int OnStep1() {
  double spread = MarketInfo(Symbol(), MODE_SPREAD)*Point;
  
  int ticket = Buy(LotsRisk(Lots), Ask, Ask-StopLoss*Point, Bid+Grid*Point, "*");
  OrderSelect(ticket, SELECT_BY_TICKET);
  double AskB = OrderOpenPrice();
  double BidB = AskB - spread;
  
  ticket = Sell(LotsRisk(Lots), Bid, Bid+StopLoss*Point, Ask-Grid*Point, "*");
  OrderSelect(ticket, SELECT_BY_TICKET);
  double BidS = OrderOpenPrice();
  double AskS = BidS + spread;
    
  SetBuyStop(LotsRisk(Lots), AskB+Grid*Point, AskB+Grid*Point-StopLoss*Point, BidB+2*Grid*Point, "");
  SetSellLimit(LotsRisk(Lots), BidB+Grid*Point, BidB+Grid*Point+StopLoss*Point, AskB, "");
  SetSellStop(LotsRisk(Lots), BidS-Grid*Point, BidS-Grid*Point+StopLoss*Point, AskS-2*Grid*Point, "");
  SetBuyLimit(LotsRisk(Lots), AskS-Grid*Point, AskS-Grid*Point-StopLoss*Point, BidS, "");
  
  PrevState = STEP_1;
  SetPrevState(PrevState);
  return(0);
}

int OnStepUp() {
  if (SellStopCnt == 1) {
    int ticket = GetOrderT(OP_SELLSTOP);
    DeleteOrder(ticket);
    SellStopCnt--;
  }

  if (BuyLimitCnt == 1) {
    ticket = GetOrderT(OP_BUYLIMIT);
    DeleteOrder(ticket);
    BuyLimitCnt--;
  }
  
  GetOrderT(OP_SELL, LAST_ORDER, MODE_TRADES);
  double Bid0 = OrderOpenPrice(); 
  double Ask0 = Bid0 + MarketInfo(Symbol(), MODE_SPREAD)*Point;


  if (BuyStopCnt == 0) {
    SetBuyStop(LotsRisk(Lots), Ask0+Grid*Point, Ask0+Grid*Point-StopLoss*Point, Bid0+2*Grid*Point, "");
  }
    	
  if (SellLimitCnt == 0) {
    SetSellLimit(MathPow(2, Abs(Step)-1)*LotsRisk(Lots), Bid0+Grid*Point, Bid0+Grid*Point+StopLoss*Point, Ask0, "");
  }
	
  if (SellStopCnt == 0) {
    SetSellStop(LotsRisk(Lots), Bid0-Grid*Point, Bid0-Grid*Point+StopLoss*Point, Ask0-2*Grid*Point, "");
  }
	
  if (BuyLimitCnt == 0) {
    SetBuyLimit(LotsRisk(Lots), Ask0-Grid*Point, Ask0-Grid*Point-StopLoss*Point, Bid0, "");
  }

  PrevState = STEP_UP;
  SetPrevState(PrevState);
  return(0);
}

int OnStepDown() {
  if (BuyStopCnt == 1) {
    int ticket = GetOrderT(OP_BUYSTOP); 
    DeleteOrder(ticket);
    BuyStopCnt--;
  }

  if (SellLimitCnt == 1) {
    ticket = GetOrderT(OP_SELLLIMIT); 
    DeleteOrder(ticket);
    SellLimitCnt--;
  }

  ticket = GetOrderT(OP_SELL, LAST_ORDER, MODE_TRADES);
  double Bid0 = OrderOpenPrice(); 
  double Ask0 = Bid0 + MarketInfo(Symbol(), MODE_SPREAD)*Point;

  if (BuyStopCnt == 0) {
    SetBuyStop(LotsRisk(Lots), Ask0+Grid*Point, Ask0+Grid*Point-StopLoss*Point, Bid0+2*Grid*Point, "");
  }

  if (SellLimitCnt == 0) {
    SetSellLimit(LotsRisk(Lots), Bid0+Grid*Point, Bid0+Grid*Point+StopLoss*Point, Ask0, "");
  }
  
  if (SellStopCnt == 0) {
    SetSellStop(LotsRisk(Lots), Bid0-Grid*Point, Bid0-Grid*Point+StopLoss*Point, Ask0-2*Grid*Point, "");
  }	
  
  if (BuyLimitCnt == 0) {
    SetBuyLimit(MathPow(2, Abs(Step)-1)*LotsRisk(Lots), Ask0-Grid*Point, Ask0-Grid*Point-StopLoss*Point, Bid0, "");
  }

  PrevState = STEP_DOWN;
  SetPrevState(PrevState);
  return(0);
}

int OnRollUp() {
  if (StopOnRoll) {
    CloseAll();
    PrevState = STATE_0;
    SetPrevState(PrevState);
    return(0);
  }
  
  if (SellStopCnt == 1) {
    int ticket = GetOrderT(OP_SELLSTOP); 
    DeleteOrder(ticket);
    SellStopCnt--;
  }

  if (BuyLimitCnt == 1) {
    ticket = GetOrderT(OP_BUYLIMIT); 
    DeleteOrder(ticket);
    BuyLimitCnt--;
  }

  ticket = GetOrderT(OP_BUY, LAST_ORDER, MODE_TRADES);
  int cnt = OrdersTotal();
  for (int i=cnt-1; i >= 0; i--) {
    OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    
    if (OrderSymbol() != Symbol()) continue;
    if (OrderMagicNumber() != Magic) continue;
    if (OrderType() != OP_BUY) continue;
    
    if (ticket != OrderTicket()) CloseOrder(OrderTicket(), OrderLots(), Bid);
  }

  GetOrderT(OP_SELL, LAST_ORDER, MODE_TRADES);
  double Bid0 = OrderOpenPrice() ; 
  double Ask0 = Bid0 + MarketInfo(Symbol(), MODE_SPREAD)*Point;

  if (BuyStopCnt == 0) {
    SetBuyStop(LotsRisk(Lots), Ask0+Grid*Point, Ask0+Grid*Point-StopLoss*Point, Bid0+2*Grid*Point, "");
  }
  
  if (SellLimitCnt == 0) {
    SetSellLimit(MathPow(2, Abs(Step)-1)*LotsRisk(Lots), Bid0+Grid*Point, Bid0+Grid*Point+StopLoss*Point, Ask0, "");
  }

  if (SellStopCnt == 0) {
    SetSellStop(LotsRisk(Lots), Bid0-Grid*Point, Bid0-Grid*Point+StopLoss*Point, Ask0-2*Grid*Point, "");
  }	
    
  if (BuyLimitCnt == 0) {
    SetBuyLimit(LotsRisk(Lots), Ask0-Grid*Point, Ask0-Grid*Point-StopLoss*Point, Bid0, "");
  }

  PrevState = ROLL_UP;
  SetPrevState(PrevState);
  return(0);
}

int OnRollDown() {
  if (StopOnRoll) {
    CloseAll();
    PrevState = STATE_0;
    SetPrevState(PrevState);
    return(0);
  }

  if (BuyStopCnt == 1) {
    int ticket = GetOrderT(OP_BUYSTOP); 
    DeleteOrder(ticket);
    BuyStopCnt--;
  }

  if (SellLimitCnt == 1) {
    ticket = GetOrderT(OP_SELLLIMIT); 
    DeleteOrder(ticket);
    SellLimitCnt--;
  }

  ticket = GetOrderT(OP_SELL, LAST_ORDER, MODE_TRADES);
  int cnt = OrdersTotal();
  for (int i=cnt-1; i >= 0; i--) {
    OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    
    if (OrderSymbol() != Symbol()) continue;
    if (OrderMagicNumber() != Magic) continue;
    if (OrderType() != OP_SELL) continue;
    
    if (ticket != OrderTicket()) CloseOrder(OrderTicket(), OrderLots(), Ask);
  }

  GetOrderT(OP_BUY, LAST_ORDER, MODE_TRADES);
  double Ask0 = OrderOpenPrice(); 
  double Bid0 = Ask0 - MarketInfo(Symbol(), MODE_SPREAD)*Point;

  if (BuyStopCnt == 0) {
    SetBuyStop(LotsRisk(Lots), Ask0+Grid*Point, Ask0+Grid*Point-StopLoss*Point, Bid0+2*Grid*Point, "");
  }

  if (SellLimitCnt == 0) {
    SetSellLimit(LotsRisk(Lots), Bid0+Grid*Point, Bid0+Grid*Point+StopLoss*Point, Ask0, "");
  }

  if (SellStopCnt == 0) {
    SetSellStop(LotsRisk(Lots), Bid0-Grid*Point, Bid0-Grid*Point+StopLoss*Point, Ask0-2*Grid*Point, "");
  }	
  
  if (BuyLimitCnt == 0) {
    SetBuyLimit(MathPow(2, Abs(Step)-1)*LotsRisk(Lots), Ask0-Grid*Point, Ask0-Grid*Point-StopLoss*Point, Bid0, "");
  }

  PrevState = ROLL_DOWN;
  SetPrevState(PrevState);
  return(0);
}

int GetOrder(int type, int order=FIRST_ORDER, int mode=MODE_TRADES) {
  int cnt = 0;

  switch (order) {
    case FIRST_ORDER:
    case LAST_ORDER:
      break;
      
    default: 
      return(-1);
  }

  switch (mode) {
    case MODE_TRADES:
      cnt = OrdersTotal();
      break;
    case MODE_HISTORY:
      cnt = HistoryTotal();
      break;
      
    default: 
      return(-1);
  }
    
  if (order == FIRST_ORDER) {
    for (int i=0; i < cnt; i++) {
      OrderSelect(i, SELECT_BY_POS, mode);
    
      if (OrderSymbol() != Symbol()) continue;
      if (OrderMagicNumber() != Magic) continue;
      if (OrderType() != type) continue;
    
      return(OrderTicket());
    }
  
    return(-1);  
  }
  
  if (order == LAST_ORDER) {
    for (i=cnt-1; i >= 0; i--) {
      OrderSelect(i, SELECT_BY_POS, mode);
    
      if (OrderSymbol() != Symbol()) continue;
      if (OrderMagicNumber() != Magic) continue;    
      if (OrderType() != type) continue;
    
      return(OrderTicket());
    }
  
    return(-1);  
  }
  
  return(-1);
}

int GetOrderT(int type, int order=FIRST_ORDER, int mode=MODE_TRADES) {
  int cnt = 0;

  switch (order) {
    case FIRST_ORDER:
    case LAST_ORDER:
      break;
      
    default: 
      return(-1);
  }

  switch (mode) {
    case MODE_TRADES:
      cnt = OrdersTotal();
      break;
    case MODE_HISTORY:
      cnt = HistoryTotal();
      break;
      
    default: 
      return(-1);
  }
    
  if (order == FIRST_ORDER) {
    int ticket = -1;
    datetime dt = CurTime();
  
    for (int i=0; i < cnt; i++) {
      OrderSelect(i, SELECT_BY_POS, mode);
    
      if (OrderSymbol() != Symbol()) continue;
      if (OrderMagicNumber() != Magic) continue;
      if (OrderType() != type) continue;
    
      if (OrderOpenTime() < dt) {
        dt = OrderOpenTime();
        ticket = OrderTicket();
      }
    }
  
    if (ticket != -1) OrderSelect(ticket, SELECT_BY_TICKET, mode);
    return(ticket);  
  }
  
  if (order == LAST_ORDER) {
    ticket = -1;
    dt = 0;
  
    for (i=cnt-1; i >= 0; i--) {
      OrderSelect(i, SELECT_BY_POS, mode);
    
      if (OrderSymbol() != Symbol()) continue;
      if (OrderMagicNumber() != Magic) continue;    
      if (OrderType() != type) continue;
    
      if (OrderOpenTime() > dt) {
        dt = OrderOpenTime();
        ticket = OrderTicket();
      }
    }
  
    if (ticket != -1) OrderSelect(ticket, SELECT_BY_TICKET, mode);
    return(ticket);  
  }
  
  return(-1);
}

int Buy(double lot, double price, double SL, double TP, string comment) {
  int res = -1;
  while (res < 0) {
    RefreshRates();
    res = OrderSend(Symbol(), OP_BUY, lot, price, Slippage, SL, TP, comment, Magic);
   	if (res < 0) {
   	  Print("Error opening BUY order: ", ErrorDescription(GetLastError()));
			Sleep(6000);
		}
	}
	
	Sleep(2000);
	return(res);
}

int Sell(double lot, double price, double SL, double TP, string comment) {
  int res = -1;
  while (res < 0) {
    RefreshRates();
    res = OrderSend(Symbol(), OP_SELL, lot, price, Slippage, SL, TP, comment, Magic);
   	if (res < 0) {
   	  Print("Error opening SELL order: ", ErrorDescription(GetLastError()));
			Sleep(6000);
		}
	}
	
	Sleep(2000);
	return(res);
}

int SetBuyStop(double lot, double price, double SL, double TP, string comment) {
  int res = -1;
  while (res < 0) {
    RefreshRates();
    res = OrderSend(Symbol(), OP_BUYSTOP, lot, price, Slippage, SL, TP, comment, Magic);
   	if (res < 0) {
   	  Print("Error setting BUYSTOP order: ", ErrorDescription(GetLastError()));
			Sleep(6000);
		}
	}
	
	Sleep(2000);
	return(res);
}

int SetSellStop(double lot, double price, double SL, double TP, string comment) {
  int res = -1;
  while (res < 0) {
    RefreshRates();
    res = OrderSend(Symbol(), OP_SELLSTOP, lot, price, Slippage, SL, TP, comment, Magic);
   	if (res < 0) {
   	  Print("Error setting SELLSTOP order: ", ErrorDescription(GetLastError()));
			Sleep(6000);
		}
	}
	
	Sleep(2000);
	return(res);
}

int SetBuyLimit(double lot, double price, double SL, double TP, string comment) {
  int res = -1;
  while (res < 0) {
    RefreshRates();
    res = OrderSend(Symbol(), OP_BUYLIMIT, lot, price, Slippage, SL, TP, comment, Magic);
    if (res < 0) {
      Print("Error setting BUYLIMIT order: ", ErrorDescription(GetLastError()));
      Sleep(6000);
    }
  }
	
  Sleep(2000);
  return(res);
}

int SetSellLimit(double lot, double price, double SL, double TP, string comment) {
  int res = -1;
  while (res < 0) {
    RefreshRates();
    res = OrderSend(Symbol(), OP_SELLLIMIT, lot, price, Slippage, SL, TP, comment, Magic);
    if (res < 0) {
      Print("Error setting SELLLIMIT order: ", ErrorDescription(GetLastError()));
      Sleep(6000);
    }
  }
	
  Sleep(2000);
  return(res);
}

int CloseOrder(int ticket, double lot, double price) {
  bool res = false;
  while (!res) {
    RefreshRates();
    res = OrderClose(ticket, lot, price, Slippage);
    if (!res) {
      Print("Error closing order: ", ErrorDescription(GetLastError()));
      Sleep(6000);
    }
  }

  Sleep(2000);
  return(0);
}

int DeleteOrder(int ticket) {
  bool res = false;
  while (!res) {
    RefreshRates();
    res = OrderDelete(ticket);
    if (!res) {
      Print("Error deleting order: ", ErrorDescription(GetLastError()));
		Sleep(6000);
	 }
  }

  Sleep(2000);
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

int Abs(int val) {
  if (val < 0) return (-val);
  return(val);
}

int GetPrevState() {
  if (!GlobalVariableCheck(gVarName)) return(STATE_0);
  return(GlobalVariableGet(gVarName));
}

void SetPrevState(int state) {
  GlobalVariableSet(gVarName, state);
}

string State2Str(int state) {
  switch(state) {
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

string OT2Str(int type) {
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
  for (int i=0; i < OrdersTotal(); i++) {
    OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    Print(
     "  ticket= ", OrderTicket(), 
     "  type= ", OT2Str(OrderType()),
     "  lot= ", DoubleToStr(OrderLots(), 1),
     "  Open= ", OrderOpenPrice(),
     "  SL= ", OrderStopLoss(),
     "  TP= ", OrderTakeProfit());
  }
}