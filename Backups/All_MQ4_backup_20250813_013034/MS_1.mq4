#include <stdlib.mqh>
#include <stderror.mqh>

extern double grid             = 20;
       double gridstep         = 6;
       double multk[25]        = {-5,-4,-3,-2,-1,-1,-1,0,1,1,1,2,3,4,5};
       int    limit            = 5;
       double lotseq[25]       = {1,1,2.8,6,6,12,28.8};
       double stepseq[25];
       double gridseqbuy[25];
       double gridseqsell[25];
       double spred;
       int    LastLock, step;
       int    StateOld, StateCur;
       int    sleeppage        = 3;
       int    Magic            = 120976;
       double CurrentPrice;
       bool   SetAll, AP;
       int    LastBuy, LastSell, ProfitOrder;

// Initialization --------------------------------------------------------------------------------------
int initialization() { 

    StateCur = 0;
    StateOld=StateCur;
    spred=MarketInfo(Symbol(), MODE_SPREAD)*Point;
    RefreshRates();
    CurrentPrice = Bid;
    OpenOrder (OP_SELL, LotSize(0), Bid, Bid+400*Point, Ask-grid*Point, "", Magic, Red);
    OpenOrder (OP_BUY, LotSize(0), Ask, Ask-400*Point, Bid+grid*Point, "", Magic, Green);
    step = 1;
    setgrid (CurrentPrice);
    SetAll = SetOrders (LotSize(1), LotSize(1), LotSize(1), LotSize(1));
    SearchLastSellBuy();
    LastLock=0;
}
// end Initialization ----------------------------------------------------------------------------------

// First? ----------------------------------------------------------------------------------------------
bool first(){
 
  int ordcnt=0;
  for (int cnt=OrdersTotal()-1;cnt>=0;cnt--)
      {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if ((OrderSymbol() == Symbol()) && (OrderTicket() > LastLock) && ((OrderType() == OP_BUY) || (OrderType() == OP_SELL))) {ordcnt++;}
      }
  if (ordcnt>0) {return(false);}
  else {return(true);}
}
// end First? ------------------------------------------------------------------------------------------

// Lot Size --------------------------------------------------------------------------------------------
double LotSize(int tStep) {

  for (int i=0;i<=limit;i++)
    double aLots=lotseq[i]+aLots;
  aLots++;
//  Print ("aLots=", aLots);
  double rez = NormalizeDouble((AccountBalance()/aLots/1000)*lotseq[tStep]/4,1);
  if (rez < 0.1) {rez = 0.1;}
//  Print ("rez lots=", rez);
  return(rez);
}
// end Lot Size ----------------------------------------------------------------------------------------

// Set Grid --------------------------------------------------------------------------------------------
bool setgrid(double startprice){
 
  for(int i=0;i<=((gridstep+1)*2);i++)
    {
     stepseq[i]=multk[i]*grid;
     gridseqsell[i]=startprice+stepseq[i]*Point;
     gridseqbuy[i]=startprice+spred+stepseq[i]*Point;
    }
  return(0);
}
// end Set Grid ----------------------------------------------------------------------------------------

// All Present -----------------------------------------------------------------------------------------
bool allpresent() {

     int BuyCnt = 0;
     int SellCnt = 0;
     int BuyStopCnt = 0;
     int BuyLimitCnt = 0;
     int SellStopCnt = 0;
     int SellLimitCnt = 0;
     for (int cnt=OrdersTotal()-1;cnt>=0;cnt--)
         {
          OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
          if ((OrderSymbol() == Symbol()) && (OrderTicket() > LastLock))
             {
//              Print ("Ticket=", OrderTicket(),"  OrderType=", OrderType(), "  OrderOpenPrice=", OrderOpenPrice(), "  OrderTakeProfit=", OrderTakeProfit()," Lots=",OrderLots());
              switch (OrderType())
                  {
                   case 0: BuyCnt++;
                           break;
                   case 1: SellCnt++;
                           break;
                   case 2: BuyLimitCnt++;
                           break;
                   case 3: SellLimitCnt++;
                           break;
                   case 4: BuyStopCnt++;
                           break;
                   case 5: SellStopCnt++;
                           break;
                  }
             }
         }
//     Print ("Buy=",BuyCnt," Sell=",SellCnt," BuyStopCnt==",BuyStopCnt," BuyLimitCnt==",BuyLimitCnt," SellStopCnt==",SellStopCnt," SellLimitCnt==",SellLimitCnt," Bid=",Bid);
     if (BuyCnt > SellCnt) {step = BuyCnt;} else {step = SellCnt;}
     if ((BuyStopCnt==0) || (BuyLimitCnt==0) || (SellStopCnt==0) || (SellLimitCnt==0)) {return(false);}
     else {return(true);}
} 
// end All Present -------------------------------------------------------------------------------------

// Search Last Sell & Buy ------------------------------------------------------------------------------
int SearchLastSellBuy(){
  
  LastBuy=0;
  LastSell=0;
  for (int cnt=OrdersTotal()-1;cnt>=0;cnt--)
      {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if ((OrderSymbol() == Symbol()) && (OrderTicket() > LastLock) && (OrderType() == OP_BUY))
          {
           if (OrderTicket()>LastBuy) {LastBuy=OrderTicket();}
          }
       if ((OrderSymbol() == Symbol()) && (OrderTicket() > LastLock) && (OrderType() == OP_SELL))
          {
           if (OrderTicket()>LastSell) {LastSell=OrderTicket();}
          }   
      }
  return(0);
}
// end Search Last Sell & Buy --------------------------------------------------------------------------

// Open Order ------------------------------------------------------------------------------------------
bool OpenOrder(int Cmd, double Vol, double Prc, double Stl, double Tpt, string Com, int Mag, color Clr) {
  int err, max;
  
  int ticket = -1;
  max = 100;
  while ((ticket < 0) && (max != 0)) 
    {
     RefreshRates();
     ticket=OrderSend(Symbol(), Cmd, Vol, Prc, sleeppage, Stl, Tpt, Com, Mag, 0, Clr);
//     Print ("Sym=",Sym," Cmd=",Cmd," Vol=",Vol," Prc=",Prc," Stl=",Stl," Tpt=",Tpt," Com=",Com," Mag=",Mag);
     err=GetLastError();
     if (ticket == -1) 
        {
         Comment("Error=", err, "   ", ErrorDescription(err));
         Sleep(6000);
        }
     else
        {Comment("                                             ");}
     max--;
    }
  Sleep(1000);
  if (max != 0) {return(true);}
  else {return(false);}
}
// end Open Order --------------------------------------------------------------------------------------

// Set Orders ------------------------------------------------------------------------------------------
bool SetOrders(double bs, double sl, double ss, double bl){

return(0);
}
// end Set Orders --------------------------------------------------------------------------------------
 
int start(){

  if (first()) initialization();

return(0);
}