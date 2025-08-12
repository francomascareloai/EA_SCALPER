//+------------------------------------------------------------------+


double a, b; 
bool first=true; 
extern int Shift = 2;
extern double Lot=0.1;
extern int Limit = 6;//6;
extern int Take = 1;
extern int NumOrd=4;
extern bool Reinvest=true;
 
int z;
//---------------------------------------------------------------------------- 
int start(){ 
  CloseAll(); 
  RefreshRates();
  if (first) {a=Ask; b=Bid; first=false; return(0);} 
  z=MarketInfo(Symbol(),MODE_STOPLEVEL);
  if (OrdersTotal()<NumOrd)
  {
  double gl=GetLots();
  if (Ask-a>=Shift*Point && gl>0) 
    {OrderSend(Symbol(),OP_SELL,gl,Bid,1,0,0,"LC",0,0,Red);} 
  if (b-Bid>=Shift*Point && gl>0) 
    {OrderSend(Symbol(),OP_BUY,gl,Ask,1,0,0,"LC",0,0,Blue);} 
   }
  a=Ask;  
  b=Bid; 
return(0);} 
//----------------------------------------------------------------------------- 
void CloseAll() { 
  int j=OrdersTotal()-1;
  for (int cnt = j; cnt >= 0; cnt--) { 
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES); 
    RefreshRates();
    if (OrderSymbol() == Symbol()) { 
      if(OrderType()==OP_BUY && Bid-OrderOpenPrice()>=Take*Point)  {OrderClose(OrderTicket(),OrderLots(),Bid,2,CLR_NONE);}
      if(OrderType()==OP_SELL && OrderOpenPrice()-Ask>=Take*Point) OrderClose(OrderTicket(),OrderLots(),Ask,2,CLR_NONE); 
      if((OrderType()==OP_BUY)  && (((OrderOpenPrice()-Ask)/Point) > Limit)) OrderClose(OrderTicket(),OrderLots(),Bid,3,Green); 
      if((OrderType()==OP_SELL) && (((Bid-OrderOpenPrice())/Point) > Limit)) OrderClose(OrderTicket(),OrderLots(),Ask,3,Green); 
    } 
  } 
} 
//-------------------------------------------------------------------------- 
double GetLots() { 
  if(Reinvest) return (NormalizeDouble(AccountFreeMargin()/3000,1)); else return (Lot); 
} 
//------------------------------------------------------------------------- 


