//+------------------------------------------------------------------+
//|                                                       Pioner.mq4 |
//+------------------------------------------------------------------+

#property copyright "RickD"
#property link      "http://onix-trade.net/e2e"

#include <stdlib.mqh>


extern double Lots = 0.1;
extern int Grid = 20;
extern int StopLoss = 200;
extern bool FixedLot = true;
extern double Slippage = 3;
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

#define STATE_0     0
#define STEP_UP     1
#define STEP_DOWN   2
#define ROLL_UP     3
#define ROLL_DOWN   4

string gVarName = "Pioner_PrevState";
int PrevState = STATE_0;


int init() {
  PrevState = GetPrevState();
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
     
  StepUp = (PrevState != STEP_DOWN &&
    BuyCnt == 0 && SellCnt > 0 && BuyStopCnt == 0 && SellLimitCnt == 0 && 
    BuyLimitCnt == 1 && SellStopCnt == 1);

  StepDown = (PrevState != STEP_UP &&
    SellCnt == 0 && BuyCnt > 0 && BuyStopCnt == 1 && SellLimitCnt == 1 && 
    SellStopCnt == 0 && BuyLimitCnt == 0);
       
  RollDown = (PrevState == STEP_UP &&
    BuyCnt == 2 && SellCnt > 0  && BuyStopCnt == 1 && SellLimitCnt == 1 && 
    SellStopCnt == 0 && BuyLimitCnt == 0);
  
  RollUp = (PrevState == STEP_DOWN &&
    BuyCnt > 0 && SellCnt == 2 && BuyStopCnt == 0 && SellLimitCnt == 0 && 
    BuyLimitCnt == 1 && SellStopCnt == 1);
    

  if (Step1) Step = 1;        
  else if (StepUp) Step = SellCnt;
  else if (StepDown) Step = -BuyCnt;
  else if (RollUp) Step = 2;
  else if (RollDown) Step = -2;
  
  Comment("Step= ", Step);

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

int OrderSelectByType(int type, int ind) {
  int cnt = OrdersTotal();
  int ind0 = 0;
  for (int i=0; i < cnt; i++) {
    OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    
    if (OrderSymbol() != Symbol()) continue;
    if (OrderMagicNumber() != Magic) continue;
    
    if (OrderType() == type) ind0++;
    if (ind == ind0) return (OrderTicket());
  }
  
  return(-1);
}

int Buy(double lot, double price, double SL, double TP, string comment) {
  bool res = 0;
  while (res<=0) {
    RefreshRates();
    res = OrderSend(Symbol(), OP_BUY, lot, price, Slippage, SL, TP, comment, Magic);
   	if (res < 0) {
   	  Print("Error opening BUY order: ", ErrorDescription(GetLastError()));
			Sleep(6000);
		}
	}
	
	Sleep(2000);
	return(0);
}

int Sell(double lot, double price, double SL, double TP, string comment) {
  bool res = 0;
  while (res<=0) {
    RefreshRates();
    res = OrderSend(Symbol(), OP_SELL, lot, price, Slippage, SL, TP, comment, Magic);
   	if (res < 0) {
   	  Print("Error opening SELL order: ", ErrorDescription(GetLastError()));
			Sleep(6000);
		}
	}
	
	Sleep(2000);
	return(0);
}

int SetBuyStop(double lot, double price, double SL, double TP, string comment) {
  bool res = 0;
  while (res<=0) {
    RefreshRates();
    res = OrderSend(Symbol(), OP_BUYSTOP, lot, price, Slippage, SL, TP, comment, Magic);
   	if (res < 0) {
   	  Print("Error setting BUYSTOP order: ", ErrorDescription(GetLastError()));
			Sleep(6000);
		}
	}
	
	Sleep(2000);
	return(0);
}

int SetSellStop(double lot, double price, double SL, double TP, string comment) {
  bool res = 0;
  while (res<=0) {
    RefreshRates();
    res = OrderSend(Symbol(), OP_SELLSTOP, lot, price, Slippage, SL, TP, comment, Magic);
   	if (res < 0) {
   	  Print("Error setting SELLSTOP order: ", ErrorDescription(GetLastError()));
			Sleep(6000);
		}
	}
	
	Sleep(2000);
	return(0);
}

int SetBuyLimit(double lot, double price, double SL, double TP, string comment) {
  bool res = 0;
  while (res<=0) {
    RefreshRates();
    res = OrderSend(Symbol(), OP_BUYLIMIT, lot, price, Slippage, SL, TP, comment, Magic);
   	if (res < 0) {
   	  Print("Error setting BUYLIMIT order: ", ErrorDescription(GetLastError()));
			Sleep(6000);
		}
	}
	
	Sleep(2000);
	return(0);
}

int SetSellLimit(double lot, double price, double SL, double TP, string comment) {
  bool res = 0;
  while (res<=0) {
    RefreshRates();
    res = OrderSend(Symbol(), OP_SELLLIMIT, lot, price, Slippage, SL, TP, comment, Magic);
   	if (res < 0) {
   	  Print("Error setting SELLLIMIT order: ", ErrorDescription(GetLastError()));
			Sleep(6000);
		}
	}
	
	Sleep(2000);
	return(0);
}

int CloseOrder(int ticket, double lot, double price) {
  bool res = 0;
  while (res<=0) {
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
  bool res = 0;
  while (res<=0) {
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
  for (int i=0; i < cnt; i++) {
    OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    
    if (OrderSymbol() != Symbol()) continue;
    if (OrderMagicNumber() != Magic) continue;
      
    if (OrderType() == OP_BUY) CloseOrder(OrderTicket(), OrderLots(), Bid);
    else if (OrderType() == OP_SELL) CloseOrder(OrderTicket(), OrderLots(), Ask);
    else if (OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT ||
      OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP()) DeleteOrder(OrderTicket());
  }
  
  return(0);
}

int OnStep1() {
  Buy(LotsRisk(Lots), Ask, Ask-StopLoss*Point, Bid+Grid*Point, NULL);
  Sell(LotsRisk(Lots), Bid, Bid+StopLoss*Point, Ask-Grid*Point, NULL);
  SetBuyStop(LotsRisk(Lots), Ask+Grid*Point, Ask-StopLoss*Point, Bid+2*Grid*Point, NULL);
  SetSellLimit(LotsRisk(Lots), Bid+Grid*Point, Bid+StopLoss*Point, Ask, NULL);
  SetSellStop(LotsRisk(Lots), Bid-Grid*Point, Bid+StopLoss*Point, Ask-2*Grid*Point, NULL);
  SetBuyLimit(LotsRisk(Lots), Ask-Grid*Point, Ask-StopLoss*Point, Bid, NULL);
  
  PrevState = STEP_UP;
  SetPrevState(PrevState);
  return(0);
}

int OnStepUp() {
  if (SellStopCnt == 1) {
    int ticket = OrderSelectByType(OP_SELLSTOP, 1); 
    DeleteOrder(ticket);
    SellStopCnt--;
  }

  if (BuyLimitCnt == 1) {
    ticket = OrderSelectByType(OP_BUYLIMIT, 1); 
    DeleteOrder(ticket);
    BuyLimitCnt--;
  }
    
  if (BuyStopCnt == 0) {
    SetBuyStop(LotsRisk(Lots), Ask+Grid*Point, Ask-StopLoss*Point, Bid+2*Grid*Point, NULL);
  }
    	
	if (SellLimitCnt == 0) {
	  SetSellLimit(Abs(Step)*LotsRisk(Lots), Bid+Grid*Point, Bid+StopLoss*Point, Ask, NULL);
	}
	
	if (SellStopCnt == 0) {
	  SetSellStop(LotsRisk(Lots), Bid-Grid*Point, Bid+StopLoss*Point, Ask-2*Grid*Point, NULL);
	}
	
	if (BuyLimitCnt == 0) {
	  SetBuyLimit(LotsRisk(Lots), Ask-Grid*Point, Ask-StopLoss*Point, Bid, NULL);
	}

  PrevState = STEP_UP;
  SetPrevState(PrevState);
  return(0);
}

int OnStepDown() {
  if (BuyStopCnt == 1) {
    int ticket = OrderSelectByType(OP_BUYSTOP, 1); 
    DeleteOrder(ticket);
    BuyStopCnt--;
  }

  if (SellLimitCnt == 1) {
    ticket = OrderSelectByType(OP_SELLLIMIT, 1); 
    DeleteOrder(ticket);
    SellLimitCnt--;
  }
  
  if (BuyStopCnt == 0) {
    SetBuyStop(LotsRisk(Lots), Ask+Grid*Point, Ask-StopLoss*Point, Bid+2*Grid*Point, NULL);
  }

	if (SellLimitCnt == 0) {
	  SetSellLimit(LotsRisk(Lots), Bid+Grid*Point, Bid+StopLoss*Point, Ask, NULL);
	}
  
  if (SellStopCnt == 0) {
    SetSellStop(LotsRisk(Lots), Bid-Grid*Point, Bid+StopLoss*Point, Ask-2*Grid*Point, NULL);
  }	
  
	if (BuyLimitCnt == 0) {
		SetBuyLimit(Abs(Step)*LotsRisk(Lots), Ask-Grid*Point, Ask-StopLoss*Point, Bid, NULL);
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
    int ticket = OrderSelectByType(OP_SELLSTOP, 1); 
    DeleteOrder(ticket);
    SellStopCnt--;
  }

  if (BuyLimitCnt == 1) {
    ticket = OrderSelectByType(OP_BUYLIMIT, 1); 
    DeleteOrder(ticket);
    BuyLimitCnt--;
  }

  if (BuyCnt > 1) {
    int ind = 0;
    int cnt = OrdersTotal();
    for (int i=0; i < cnt; i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    
      if (OrderSymbol() != Symbol()) continue;
      if (OrderMagicNumber() != Magic) continue;
      if (OrderType() != OP_BUY) continue;
    
      ind++;
      if (ind < BuyCnt) CloseOrder(OrderTicket(), OrderLots(), Bid);
    }
  }

	if (BuyStopCnt == 0) {
	  SetBuyStop(LotsRisk(Lots), Ask+Grid*Point, Ask-StopLoss*Point, Bid+2*Grid*Point, NULL);
	}
  
	if (SellLimitCnt == 0) {
	  SetSellLimit(LotsRisk(Lots), Bid+Grid*Point, Bid+StopLoss*Point, Ask, NULL);
	}

  if (SellStopCnt == 0) {
    SetSellStop(LotsRisk(Lots), Bid-Grid*Point, Bid+StopLoss*Point, Ask-2*Grid*Point, NULL);
  }	
    
	if (BuyLimitCnt == 0) {
		SetBuyLimit(Abs(Step)*LotsRisk(Lots), Ask-Grid*Point, Ask-StopLoss*Point, Bid, NULL);
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
    int ticket = OrderSelectByType(OP_BUYSTOP, 1); 
    DeleteOrder(ticket);
    BuyStopCnt--;
  }

  if (SellLimitCnt == 1) {
    ticket = OrderSelectByType(OP_SELLLIMIT, 1); 
    DeleteOrder(ticket);
    SellLimitCnt--;
  }

  if (SellCnt > 1) {
    int ind = 0;
    int cnt = OrdersTotal();
    for (int i=0; i < cnt; i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    
      if (OrderSymbol() != Symbol()) continue;
      if (OrderMagicNumber() != Magic) continue;
      if (OrderType() != OP_SELL) continue;
    
      ind++;
      if (ind < SellCnt) CloseOrder(OrderTicket(), OrderLots(), Ask);
    }
  }

	if (BuyStopCnt == 0) {
	  SetBuyStop(LotsRisk(Lots), Ask+Grid*Point, Ask-StopLoss*Point, Bid+2*Grid*Point, NULL);
	}

	if (SellLimitCnt == 0) {
	  SetSellLimit(LotsRisk(Lots), Bid+Grid*Point, Bid+StopLoss*Point, Ask, NULL);
	}

  if (SellStopCnt == 0) {
    SetSellStop(LotsRisk(Lots), Bid-Grid*Point, Bid+StopLoss*Point, Ask-2*Grid*Point, NULL);
  }	
  
	if (BuyLimitCnt == 0) {
		SetBuyLimit(Abs(Step)*LotsRisk(Lots), Ask-Grid*Point, Ask-StopLoss*Point, Bid, NULL);
	}

  PrevState = ROLL_DOWN;
  SetPrevState(PrevState);
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