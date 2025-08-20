//+------------------------------------------------------------------+
//|                                                pipsnja           |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

//---- input parameters
extern int       Profit=120;
extern int       Loss=60;
extern int       Shift1=100;
extern int       Move1=60;
extern int       Shift2=10;
extern int       Move2=30;
extern int       Decr=14;

extern double       Lots=1;
extern int Trailing=0;
extern bool  Autolot=true;
extern int   AutoMrgDiv=7;

int Magic=1915;
int spr;
int tp,sl,d;
bool isOrder,buy,sell;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   spr=MarketInfo(Symbol(),MODE_SPREAD);
   if (Loss==0) sl=0; else sl=1;
   if (Profit==0) tp=0; else tp=1;
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
//   if (CurTime()-Time[0]<=10) {

     int i;
    if (IsTradeAllowed()) isOrder=true;
     for(i=0; i<=OrdersTotal();i++) {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if (OrderMagicNumber()==Magic && OrderSymbol()==Symbol() ) isOrder=false;
     }
     buy=false;
     sell=false;
     if (Bid-Close[Shift1]<-Move1*Point && Close[Shift1]-Close[Shift1+Shift2]>Move2*Point) buy=true;
     if (Bid-Close[Shift1]>Move1*Point && Close[Shift1]-Close[Shift1+Shift2]<-Move2*Point) sell=true;
 
     if (AccountFreeMargin()<GetLots()*2000) isOrder=false;
     if (isOrder && buy) {OrderSend(Symbol(),OP_BUY,GetLots(),Ask,3,(Bid-(Loss)*Point)*sl,(Ask+(Profit+spr)*Point)*tp,"",Magic,0,FireBrick); d=Day();}
     if (isOrder && sell) {OrderSend(Symbol(),OP_SELL,GetLots(),Bid,3,(Ask+(Loss)*Point)*sl,(Bid-(Profit+spr)*Point)*tp,"",Magic,0,DarkViolet); d=Day();}
     
 
     if (Trailing>0) for(i=0; i<=OrdersTotal();i++) {
     OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
     if (OrderMagicNumber()==Magic && OrderSymbol()==Symbol()) {
       if (OrderType()==OP_BUY && Bid-OrderOpenPrice()>Trailing*Point && Bid-OrderStopLoss()>Trailing*Point ) OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Trailing*Point,OrderTakeProfit(),0,CLR_NONE);
       if (OrderType()==OP_SELL && OrderOpenPrice()-Ask>Trailing*Point && OrderStopLoss()-Ask>Trailing*Point ) OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Trailing*Point,OrderTakeProfit(),0,CLR_NONE);
       }
     }      
         
     

//----
   return(0);
  }
//+------------------------------------------------------------------+
double GetLots()
{
 double res;
 if (Autolot) {
  res=NormalizeDouble(AccountFreeMargin()/(AutoMrgDiv*1000),0);
 if (Decr>0) { 
  int losses=0;
  for(int j=HistoryTotal()-1;j>=0;j--)
        {
         if(OrderSelect(j,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Error in history!"); break; }
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=Magic ) continue;
         //----
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
        }
   if(losses>1) res=NormalizeDouble(res-res*losses/Decr,0);
  }    
  if (res<Lots) res=Lots;
  if (res>99) res=99;
  return(res);
 } else return(Lots);
}