//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

extern double Lots         = 0.1;   // Величина лота
extern int    MinProfit    = 10;    // Прибыль в пунктах 
extern int    Step         = 0;   

int magic=3485632;
double step;

//+------------------------------------------------------------------+
int start(){

 int oo=0;
 double lp=99999,hp=0;
 int profit=0;
 int j=OrdersTotal()-1;
 for(int i=j;i>=0;i--){
  OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
  if(Symbol()==OrderSymbol() && magic==OrderMagicNumber()){
   oo++;
   if(OrderOpenPrice()<lp) lp=OrderOpenPrice();
   if(OrderOpenPrice()>hp) hp=OrderOpenPrice();
   profit=profit+MathRound((OrderProfit()+OrderSwap())/MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_MINLOT));
  }
 }
 
 Comment("Профит=", profit,"\nlp=",lp," hp=",hp,"\nlp-step=",lp-step," hp+step=",hp+step);
 
 if(oo==0){
  RefreshRates();
  OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"pio_pir",magic,0,Blue);
  OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"pio_pir",magic,0,Red);
 }
 
 if(profit>=MinProfit){
  j=OrdersTotal()-1;
  for(i=j;i>=0;i--){
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   RefreshRates();
   if(Symbol()==OrderSymbol() && magic==OrderMagicNumber() && OrderType()==OP_BUY)
    OrderClose(OrderTicket(),OrderLots(),Bid,3,Blue);
   if(Symbol()==OrderSymbol() && magic==OrderMagicNumber() && OrderType()==OP_SELL)
    OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
  }
 }

 RefreshRates();
 if (Step==0) {step=(Ask-Bid)*2;} else {step=Step*Point;}
 RefreshRates();
 if(lp-step>=Ask)
  OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"pio_pir2",magic,0,Red); 
 if(hp+step<=Bid)
  OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"pio_pir2",magic,0,Blue); 
  
 return(0);
}
//+------------------------------------------------------------------+