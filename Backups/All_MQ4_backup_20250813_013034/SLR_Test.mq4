//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double a0, b0, a1, b1; 
bool first=true; 
extern int Shift = 3;//9; 
extern double Lot=0.1;
extern int Limit = 6;//17;
extern int Take = 1;//6;
extern int NumOrd=1;
extern bool Reinvest=false;
 
int z, cbar=0;
//---------------------------------------------------------------------------- 
int start(){ 
  if(cbar==Bars){return(0);}
  RefreshRates();
  a0=Open[0]+Ask-Bid; b0=Open[1]; 
  a1=Close[1]+Ask-Bid; b1=Close[1]; 
  if (OrdersTotal()<NumOrd)
  {
  if (a0-a1>=Shift*Point) 
    {OrderSend(Symbol(),OP_SELL,GetLots(),Bid,1,0,0,"LC",0,0,Red);} 
  if (b1-b0>=Shift*Point) 
    {OrderSend(Symbol(),OP_BUY,GetLots(),Ask,1,0,0,"LC",0,0,Blue);} 
   }
  CloseAll(); 
  cbar=Bars;
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


