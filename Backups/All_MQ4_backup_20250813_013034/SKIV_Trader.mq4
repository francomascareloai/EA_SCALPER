


extern string aaa = "Параметры ордера";
extern int TakeProfit = 0;
extern int StopLoss = 0;
extern int Trailing = 0;
extern int ProcOfDeposit = 10;

datetime last;

int start()
{
   double AC1,AC2,AC3;

if(Trailing>0 && OrdersTotal()>0) TrailingControl();

if((Time[0]-last)>=Period()*60)
{
   AC1=iAC(Symbol(),0,1);
   AC2=iAC(Symbol(),0,2);
   AC3=iAC(Symbol(),0,3);
      
   if(AC1<AC2 && AC2>AC3) { OrderCl(OP_BUY); OrderOp(OP_SELL); }
   if(AC1>AC2 && AC2<AC3) { OrderCl(OP_SELL); OrderOp(OP_BUY); }
   
   
last=Time[0];
}
   return(0);
}


int OrderOp(int ord)
{
   double TP,SL,ticket;
   string objname=TimeToStr(CurTime());
   if(ord==OP_BUY)
   {
      TP=Bid+TakeProfit*Point; if(TakeProfit==0) TP=0;
      SL=Ask-StopLoss*Point;   if(StopLoss==0) SL=0;
      OrderSend(Symbol(),OP_BUY,GetLot(),Ask,3,SL,TP,"Покупаем",16384,0,White);
   }
   if(ord==OP_SELL)
   {
      TP=Ask-TakeProfit*Point; if(TakeProfit==0) TP=0;
      SL=Bid+StopLoss*Point;   if(StopLoss==0) SL=0;
      OrderSend(Symbol(),OP_SELL,GetLot(),Bid,3,SL,TP,"Продаем",16384,0,Yellow);
   }
}

int OrderCl(int ord)
{
   int cnt;
   for(cnt=OrdersTotal();cnt>0;cnt--)
   {
      OrderSelect(cnt-1, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()==OP_BUY  && ord==OP_BUY)  OrderClose(OrderTicket(),OrderLots(),Bid,3,White);
      if(OrderType()==OP_SELL && ord==OP_SELL) OrderClose(OrderTicket(),OrderLots(),Ask,3,Yellow);
   }
}


int TrailingControl()
{
   int total=OrdersTotal(),cnt;
   for(cnt=0;cnt<total;cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()<=OP_SELL && OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)
           {
            if(Trailing>0)  
              {                 
               if(Bid-OrderOpenPrice()>Point*Trailing)
                 {
                  if(OrderStopLoss()<Bid-Point*Trailing)
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*Trailing,OrderTakeProfit(),0);
                     return(0);
                    }
                 }
              }
           }
         else
           {
            if(Trailing>0)  
              {                 
               if((OrderOpenPrice()-Ask)>(Point*Trailing))
                 {
                  if(OrderStopLoss()>(Ask+Point*Trailing))
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*Trailing,OrderTakeProfit(),0);
                     return(0);
                    }
                 }
              }
           }
        }
     }
}

double GetLot()
{
   double ltt;
   if(ProcOfDeposit==0) return(0.1);
   if(AccountBalance()>1000) { ltt=MathRound(AccountBalance()/100*ProcOfDeposit/100)/10; }
   else { ltt=0.1; }
   return(ltt);
}
//*************************************************************************************


