//+------------------------------------------------------------------+
//|                                                    SHE_Lucky.mq4 |
//|                              Copyright © 2006, strategy.alfamoon |
//|                                     http://expertmillionaire.ru/ |
//+------------------------------------------------------------------+

double a, b; 
bool first=true; 
extern int Shift = 3; 
extern double Lot=0.1;
extern int Limit = 10;
extern int Take = 3;
extern int NumOrd=1;
extern int TP = 10;
extern int SL=15;
 
int z;
//---------------------------------------------------------------------------- 
int start(){ 
  if (first) {a=Ask; b=Bid; first=false; return(0);} 
  z=MarketInfo(Symbol(),MODE_STOPLEVEL);
  if (OrdersTotal()<NumOrd)
  {
  if (Ask-a>=Shift*Point) 
    {OrderSend(Symbol(),OP_SELL,GetLots(),Bid,1,Bid+SL*Point,Bid-TP*Point,"",0,0,Red);} 
  if (b-Bid>=Shift*Point) 
    {OrderSend(Symbol(),OP_BUY,GetLots(),Ask,1,Ask-SL*Point,Ask+TP*Point,"",0,0,Blue);} 
   }
  a=Ask;  
  b=Bid; 
  ModifyAll();
  CloseAll(); 
return(0);} 
//----------------------------------------------------------------------------- 
void CloseAll() { 
  for (int cnt = OrdersTotal()-1 ; cnt >= 0; cnt--) { 
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES); 
    if (OrderSymbol() == Symbol()) { 
   /*   if ((OrderProfit()>Take)) {
        if(OrderType()==OP_BUY)  OrderClose(OrderTicket(),OrderLots(),Bid,2,CLR_NONE); 
        if(OrderType()==OP_SELL) OrderClose(OrderTicket(),OrderLots(),Ask,2,CLR_NONE); 
      } 
      else */
      { 
        if((OrderType()==OP_BUY)  && (((OrderOpenPrice()-Ask)/Point) > Limit)) 
          OrderClose(OrderTicket(),OrderLots(),Bid,3,Green); 
        if((OrderType()==OP_SELL) && (((Bid-OrderOpenPrice())/Point) > Limit)) 
          OrderClose(OrderTicket(),OrderLots(),Ask,3,Green); 
      } 
    } 
  } 
} 
//----------------------------------------------------------------------------- 
void ModifyAll() { 
  for (int cnt = OrdersTotal()-1 ; cnt >= 0; cnt--) { 
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES); 
    if (OrderSymbol() == Symbol() && OrderTakeProfit()==0) { 
      { 
        if((OrderType()==OP_BUY)  && (((OrderOpenPrice()-Ask)/Point) >= z-Take)) 
          OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderOpenPrice()+Take*Point,0,Gold); 
        if((OrderType()==OP_SELL) && (((Bid-OrderOpenPrice())/Point) >= z-Take)) 
          OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderOpenPrice()-Take*Point,0,Gold); 
      } 
    } 
  } 
} 
//-------------------------------------------------------------------------- 
double GetLots() { 
//  return (NormalizeDouble(AccountFreeMargin()/3000,1)); 
  return (Lot); 
} 
//------------------------------------------------------------------------- 


