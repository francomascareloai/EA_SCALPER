#include <stdlib.mqh>
#include <stderror.mqh>

extern double grid             = 20;
       double gridstep         = 6;
       double multk[25]        = {1,1,1,1.5,2.5,6,7};
       int    limit            = 4;
       double lotseq[25]       = {1,1,2.8,6,10.2,21,39.4};
       double stepseq[25];
       double gridseqbuy[25];
       double gridseqsell[25];
       double spred;
       int    lastlock, step;
       int    stateold, statecur;
       int    sleeppage        = 3;
       int    magic            = 120976;
       double currentprice, oldprice;
       bool   setall;
       int    lastbuy, lastsell, profitorder;
       double bsp, bstp, slp, sltp, ssp, sstp, blp, bltp;

// Initialization --------------------------------------------------------------------------------------
int Initialization() { 

    statecur = 0;
    stateold=statecur;
    spred=MarketInfo(Symbol(), MODE_SPREAD)*Point;
    RefreshRates();
    currentprice = Bid;
    OpenOrder (OP_SELL, LotSize(0), Bid, Bid+400*Point, Ask-grid*Point, "", magic, Red);
    OpenOrder (OP_BUY, LotSize(0), Ask, Ask-400*Point, Bid+grid*Point, "", magic, Green);
    step = 0;
    for(int i=0;i<=gridstep;i++)
      {
       stepseq[i]=multk[i]*grid*Point;
      }
    setall = SetOrders (LotSize(1), LotSize(1), LotSize(1), LotSize(1));
    SearchLastSellBuy();
    lastlock=0;
  return(0);
}
// end Initialization ----------------------------------------------------------------------------------

// First? ----------------------------------------------------------------------------------------------
bool First(){
 
  int ordcnt=0;
  for (int cnt=OrdersTotal()-1;cnt>=0;cnt--)
      {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if ((OrderSymbol() == Symbol()) && (OrderTicket() > lastlock) && ((OrderType() == OP_BUY) || (OrderType() == OP_SELL))) {ordcnt++;}
      }
  if (ordcnt>0) {return(false);}
  else {return(true);}
}
// end First? ------------------------------------------------------------------------------------------

// Lot Size --------------------------------------------------------------------------------------------
double LotSize(int tstep) {

  for (int i=0;i<=limit;i++)
    double alots=lotseq[i]+alots;
  alots++;
//  Print ("aLots=", aLots);
  double rez = NormalizeDouble((AccountBalance()/alots/1000)*lotseq[tstep],1);
//  double rez = 1*lotseq[tstep];
  if (rez < 0.1) {rez = 0.1;}
//  Print ("rez lots=", rez);
  return(rez);
}
// end Lot Size ----------------------------------------------------------------------------------------

// All Present -----------------------------------------------------------------------------------------
bool AllPresent() {

     int buycnt = 0;
     int sellcnt = 0;
     int buystopcnt = 0;
     int buylimitcnt = 0;
     int sellstopcnt = 0;
     int selllimitcnt = 0;
     for (int cnt=OrdersTotal()-1;cnt>=0;cnt--)
         {
          OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
          if ((OrderSymbol() == Symbol()) && (OrderTicket() > lastlock))
             {
//              Print ("Ticket=", OrderTicket(),"  OrderType=", OrderType(), "  OrderOpenPrice=", OrderOpenPrice(), "  OrderTakeProfit=", OrderTakeProfit()," Lots=",OrderLots());
              switch (OrderType())
                  {
                   case 0: buycnt++;
                           break;
                   case 1: sellcnt++;
                           break;
                   case 2: buylimitcnt++;
                           break;
                   case 3: selllimitcnt++;
                           break;
                   case 4: buystopcnt++;
                           break;
                   case 5: sellstopcnt++;
                           break;
                  }
             }
         }
     if (buycnt > sellcnt) {step = buycnt-1;} else {step = sellcnt-1;}
     Print ("Step=",step," Buy=",buycnt," Sell=",sellcnt," BuyStopCnt==",buystopcnt," BuyLimitCnt==",buylimitcnt," SellStopCnt==",sellstopcnt," SellLimitCnt==",selllimitcnt," Bid=",Bid);
     if ((buystopcnt==0) || (buylimitcnt==0) || (sellstopcnt==0) || (selllimitcnt==0)) {return(false);}
     else {return(true);}
} 
// end All Present -------------------------------------------------------------------------------------

// Search Last Sell & Buy ------------------------------------------------------------------------------
int SearchLastSellBuy(){
  
  lastbuy=0;
  lastsell=0;
  for (int cnt=OrdersTotal()-1;cnt>=0;cnt--)
      {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if ((OrderSymbol() == Symbol()) && (OrderTicket() > lastlock) && (OrderType() == OP_BUY))
          {
           if (OrderTicket()>lastbuy) {lastbuy=OrderTicket();}
          }
       if ((OrderSymbol() == Symbol()) && (OrderTicket() > lastlock) && (OrderType() == OP_SELL))
          {
           if (OrderTicket()>lastsell) {lastsell=OrderTicket();}
          }   
      }
//  Print ("Last Buy=",lastbuy," Last Sell=",lastsell);
  return(0);
}
// end Search Last Sell & Buy --------------------------------------------------------------------------

// Open Order ------------------------------------------------------------------------------------------
bool OpenOrder(int cmd, double vol, double prc, double stl, double tpt, string com, int mag, color clr) {
  int err, max;
  
  prc=NormalizeDouble(prc,Digits);
  stl=NormalizeDouble(stl,Digits);
  tpt=NormalizeDouble(tpt,Digits);
  vol=NormalizeDouble(vol,1);
  int ticket = -1;
  max = 100;
  while ((ticket < 0) && (max != 0)) 
    {
     RefreshRates();
     ticket=OrderSend(Symbol(), cmd, vol, prc, sleeppage, stl, tpt, com, mag, 0, clr);
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

// Take Profit -----------------------------------------------------------------------------------------
int TakeProfit(){
   
   profitorder=0;
   for (int cnt=HistoryTotal()-1;cnt>=0;cnt--)
       {
        OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY);
        if ((OrderType() == OP_SELL) || (OrderType() == OP_BUY))
           if (OrderTicket() > profitorder)
              if (OrderClosePrice() == OrderTakeProfit()) {profitorder = OrderTicket();}
       }
//   Print ("Profit Order=",profitorder);
   return(profitorder);
}
// end Take Profit -------------------------------------------------------------------------------------

// end Lock Search -------------------------------------------------------------------------------------
int LockSearch(){
   
  lastlock = 0;
  for (int cnt=OrdersTotal()-1;cnt>=0;cnt--)
      {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == 1001001) && (OrderType() == OP_BUY))
          {
           if (OrderTicket()>lastlock) {lastlock=OrderTicket();}
          }
       if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == 1001001) && (OrderType() == OP_SELL))
          {
           if (OrderTicket()>lastlock) {lastlock=OrderTicket();}
          }   
      }
  return(0);
}
// end Lock Search -------------------------------------------------------------------------------------

// Set Orders ------------------------------------------------------------------------------------------
bool SetOrders(double bs, double sl, double ss, double bl){

  bool rez, temp;
  rez = true;
  if (statecur==0)
    {
     bsp=currentprice+stepseq[0]+spred;
     bstp=currentprice+stepseq[0]+stepseq[0];
     slp=currentprice+stepseq[0];
     sltp=currentprice+spred;
     ssp=currentprice-stepseq[0];
     sstp=currentprice-stepseq[0]-stepseq[0]+spred;
     blp=currentprice-stepseq[0]+spred;
     bltp=currentprice;
//     Print (0);
    }
  if (statecur==-1)
    {
     bsp=currentprice+stepseq[step-1]+spred;
     bstp=currentprice+stepseq[step-1]+stepseq[0];
     slp=currentprice+stepseq[step-1];
     sltp=currentprice+stepseq[step-1]-stepseq[0]+spred;
     ssp=currentprice-stepseq[step];
     if (step == limit) {sstp=currentprice-stepseq[step]-stepseq[0]+spred;}
     else {sstp=currentprice-stepseq[step]-stepseq[step+1]+spred;}
     blp=currentprice-stepseq[step]+spred;
     if (step == limit) {bltp=currentprice-stepseq[step]+stepseq[0];}
     else {bltp=currentprice;}
     
//     Print (-1);
    }
  if (statecur==1)
    {
     bsp=currentprice+stepseq[step]+spred;
     if (step == limit) {bstp=currentprice+stepseq[step]+stepseq[0];}
     else {bstp=currentprice+stepseq[step]+stepseq[step+1];}
     slp=currentprice+stepseq[step];
     if (step == limit) {sltp=currentprice+stepseq[step]-stepseq[0]+spred;}
     else {sltp=currentprice+spred;}
     ssp=currentprice-stepseq[step-1];
     sstp=currentprice-stepseq[step-1]-stepseq[0]+spred;
     blp=currentprice-stepseq[step-1]+spred;
     bltp=currentprice-stepseq[step-1]+stepseq[0];
//     Print (1);
    }
  Print ("currentprice=",currentprice," bsp=",bsp," ","bstp=",bstp," ","slp=",slp," ","sltp=",sltp," ","ssp=",ssp," ","sstp=",sstp," ","blp=",blp," ","bltp=",bltp);
  if (sl != 0)
    {
     temp = OpenOrder (OP_SELLLIMIT, sl, slp, slp+400*Point, sltp, "", magic, Red);
     if (!temp) {rez = false;}
    }
  if (bs != 0)
    {
     temp = OpenOrder (OP_BUYSTOP, bs, bsp, bsp-400*Point, bstp, "", magic, Green);
     if (!temp) {rez = false;}
    }
  if (ss != 0)
    {
     temp = OpenOrder (OP_SELLSTOP, ss, ssp, ssp+400*Point, sstp, "", magic, Red);
     if (!temp) {rez = false;}
    }
  if (ss != 0)
    {
     temp = OpenOrder (OP_BUYLIMIT, bl, blp, blp-400*Point, bltp, "", magic, Green);
     if (!temp) {rez = false;}
    }
  return(rez);
}
// end Set Orders --------------------------------------------------------------------------------------

// Del Not Need ----------------------------------------------------------------------------------------
bool DelNotNeed(){
  bool res, tmp;
  int max, cnt;

  Sleep(2000);
  tmp = true;
  for (cnt=OrdersTotal()-1;cnt>=0;cnt--)
      {
       RefreshRates();
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if ((OrderSymbol() == Symbol()) && (OrderTicket() > lastlock))
          {
           if (OrderType() > 1)
              {
               res = false;
               max = 100;
               while ((!res) && (max != 0)) 
                  {
                   res = OrderDelete(OrderTicket());
                   max--;
                   RefreshRates();
                  }
               if (!res) tmp = false;
              }
          }
      }
  return(tmp);
}
// end Del Not Need ------------------------------------------------------------------------------------

// Move TP ---------------------------------------------------------------------------------------------
int MoveTP(bool last){

  int cnt, err, ticket, max;
  bool res;
    
  if (statecur == 1)
     {
      for (cnt=OrdersTotal()-1;cnt>=0;cnt--)
          {
           RefreshRates();
           OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
           if (OrderSymbol() == Symbol())
              {
               if (OrderType() == OP_SELL)
                  {
                   if ((last)  && (OrderTicket() < lastlock))
                      {
                       res = false;
                       max = 100;
                       while ((!res) && (max != 0)) 
                          {
                           res = OrderModify(OrderTicket(), OrderOpenPrice(), 0, 0, 0, CLR_NONE);
                           res = GetLastError();
                           Sleep(1000);
                           max--;
                          }
                      }
                   else 
                      {
                       if ((OrderTicket() != lastsell) && (OrderTicket() > lastlock))
                          {
                           res = false;
                           max = 100;
                           while ((!res) && (max != 0))  
                              {
                               res = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), blp, 0, CLR_NONE);
                               res = GetLastError();
                               Sleep(1000);
                               max--;
                              }
                          }
                      }   
                  }
              }
          }
      return(0);
     }
  if (statecur==-1)
     {
      for (cnt=OrdersTotal()-1;cnt>=0;cnt--)
          {
           RefreshRates();
           res = OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
           if (OrderSymbol() == Symbol())
              {
               if (OrderType() == OP_BUY)
                  {
                   if ((last) && (OrderTicket() < lastlock))
                      {
                       res = false;
                       max = 100;
                       while ((!res) && (max != 0))  
                          {
                           res = OrderModify(OrderTicket(), OrderOpenPrice(), 0, 0, 0, CLR_NONE);
                           res = GetLastError();
                           Sleep(1000);
                           max--;
                          }
                      }
                   else 
                      {
                       if ((OrderTicket() != lastbuy) && (OrderTicket() > lastlock))
                          {
                           res = false;
                           max = 100;
                           while ((!res) && (max != 0))  
                              {
                               res = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), slp, 0, CLR_NONE);
                               res = GetLastError();
                               Sleep(1000);
                               max--;
                              }
                          }
                      }
                  }
              }
          }
      return(0);
     }
}
// end Move TP -----------------------------------------------------------------------------------------

 
int start(){

  if (First()) Initialization();
  if (AllPresent()) {return (0);}
  int tp = TakeProfit();
  if (tp == 0) {return(0);}
  SearchLastSellBuy();
  LockSearch();
  OrderSelect(tp, SELECT_BY_TICKET);
  stateold = statecur;
  oldprice = currentprice;
  if (OrderType() == OP_BUY) 
    {
     statecur = 1;
     currentprice = OrderTakeProfit();
    }
  else if (OrderType() == OP_SELL) 
    {
     statecur = -1;
     currentprice = OrderTakeProfit()-spred;
    }
  DelNotNeed(); 
  if (step < limit)
    {
     if (statecur == 1) {setall = SetOrders (LotSize(1), LotSize(step+1), LotSize(1), LotSize(1));}
     if (statecur == -1) {setall = SetOrders (LotSize(1), LotSize(1), LotSize(1), LotSize(step+1));}
     MoveTP(false);
    }
  if (step == limit)
    {
     if (statecur == 1)
       {
        OpenOrder (OP_BUYSTOP, LotSize(step+1), currentprice+stepseq[step]+spred, 0, 0, "LOCK", 1001001, Green);
        setall = SetOrders (LotSize(1), LotSize(1), LotSize(1), LotSize(1));
       }
     if (statecur == -1)
       {
        OpenOrder (OP_SELLSTOP, LotSize(step+1), currentprice-stepseq[step], 0, 0, "LOCK", 1001001, Red);
        setall = SetOrders (LotSize(1), LotSize(1), LotSize(1), LotSize(1));
       }
     MoveTP(false);
    }
  if (step > limit)
    { 
     step=1;
     if (statecur == 1) {setall = SetOrders (LotSize(1), LotSize(step+1), LotSize(1), LotSize(1));}
     if (statecur == -1) {setall = SetOrders (LotSize(1), LotSize(1), LotSize(1), LotSize(step+1));}
     MoveTP(true);
    }
return(0);
}