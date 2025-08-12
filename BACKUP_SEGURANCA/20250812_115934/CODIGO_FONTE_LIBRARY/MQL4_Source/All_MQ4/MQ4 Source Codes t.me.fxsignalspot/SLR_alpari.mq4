
double a, b; 
bool first=true; 
int Shift = 7;//9; 
double Lot=0.1;
int Limit = 21;//17;
int Take = 10;//6;
int NumOrd=4;
bool Reinvest=true;
 
int z;
//---------------------------------------------------------------------------- 
int start(){ 
  RefreshRates();
  if (first) {a=Ask; b=Bid; first=false; return(0);} 
  z=MarketInfo(Symbol(),MODE_STOPLEVEL);
  if (OrdersTotal()<NumOrd)
  {
  if (Ask-a>=Shift*Point) 
    {OrderSend(Symbol(),OP_SELL,GetLots(),Bid,1,0,0,"LC",0,0,Red);} 
  if (b-Bid>=Shift*Point) 
    {OrderSend(Symbol(),OP_BUY,GetLots(),Ask,1,0,0,"LC",0,0,Blue);} 
   }
  a=Ask;  
  b=Bid; 
  CloseAll(); 
return(0);} 
//----------------------------------------------------------------------------- 
void CloseAll() { 
  int j=OrdersTotal()-1;
  for (int cnt = j; cnt >= 0; cnt--) { 
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES); 
    RefreshRates();
    if (OrderSymbol() == Symbol()) { 
      if(OrderType()==OP_BUY && Bid-OrderOpenPrice()>=Take*Point)  OrderClose(OrderTicket(),OrderLots(),Bid,2,CLR_NONE); 
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


