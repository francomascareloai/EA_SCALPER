
//+------------------------------------------------------------------+
//|                           Copyright 2005, Gordago Software Corp. |
//|                                          http://www.gordago.com/ |
//+------------------------------------------------------------------+

#property copyright "Copyright 2005, Gordago Software Corp."
#property link      "http://www.gordago.com"



extern double lStopLoss = 12;
extern double sStopLoss = 12;
extern double lTakeProfit = 500;
extern double sTakeProfit = 500;           
extern color clOpenBuy = Blue;
extern color clCloseBuy = Aqua;
extern color clOpenSell = Red;
extern color clCloseSell = Violet;
extern color clModiBuy = Blue;
extern color clModiSell = Red;
extern string Name_Expert = "Generate from Gordago";
extern int Slippage = 1;
extern bool UseSound = False;
extern string NameFileSound = "alert.wav";
extern double Lots = 25;
extern int OpenOrderPeriod = 5;


void deinit() {
   Comment("");
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start(){
   if(Bars<100){
      Print("bars less than 100");
      return(0);
   }
   if(lStopLoss<10){
      Print("StopLoss less than 10");
      return(0);
   }
   if(lTakeProfit<10){
      Print("TakeProfit less than 10");
      return(0);
   }
   if(sStopLoss<10){
      Print("StopLoss less than 10");
      return(0);
   }
   if(sTakeProfit<10){
      Print("TakeProfit less than 10");
      return(0);
   }

   double diRSI0=iRSI(NULL,1440,14,PRICE_CLOSE,0);
   double diRSI1=iRSI(NULL,1440,14,PRICE_CLOSE,1);
   double diRSI2=iRSI(NULL,1440,14,PRICE_CLOSE,0);
   double diRSI3=iRSI(NULL,1440,14,PRICE_CLOSE,1);
   double diRSI4=iRSI(NULL,1440,14,PRICE_CLOSE,0);
   double diRSI5=iRSI(NULL,1440,14,PRICE_CLOSE,1);
   double diRSI6=iRSI(NULL,1440,14,PRICE_CLOSE,0);
   double diRSI7=iRSI(NULL,1440,14,PRICE_CLOSE,1);
   double diRSI8=iRSI(NULL,1440,14,PRICE_CLOSE,0);
   double diRSI9=iRSI(NULL,1440,14,PRICE_CLOSE,1);
   double diRSI10=iRSI(NULL,1440,14,PRICE_CLOSE,0);
   double diRSI11=iRSI(NULL,1440,14,PRICE_CLOSE,1);
   double diRSI12=iRSI(NULL,1440,14,PRICE_CLOSE,0);
   double diRSI13=iRSI(NULL,1440,14,PRICE_CLOSE,1);
   double diRSI14=iRSI(NULL,1440,14,PRICE_CLOSE,0);
   double diRSI15=iRSI(NULL,1440,14,PRICE_CLOSE,1);
   double diRSI16=iRSI(NULL,1440,14,PRICE_CLOSE,0);
   double diRSI17=iRSI(NULL,1440,14,PRICE_CLOSE,1);
   double diRSI18=iRSI(NULL,1440,14,PRICE_CLOSE,0);
   double diRSI19=iRSI(NULL,1440,14,PRICE_CLOSE,1);
   double diRSI20=iRSI(NULL,1440,14,PRICE_CLOSE,0);
   double diRSI21=iRSI(NULL,1440,14,PRICE_CLOSE,1);
   double diRSI22=iRSI(NULL,1440,14,PRICE_CLOSE,0);
   double diRSI23=iRSI(NULL,1440,14,PRICE_CLOSE,1);

   if(AccountFreeMargin()<(1000*Lots)){
      Print("We have no money. Free Margin = ", AccountFreeMargin());
      return(0);
   }
   if (!ExistPositions()){

      if (((diRSI0>30 && diRSI1<30) || (diRSI2>50 && diRSI3<50) || (diRSI4>70 && diRSI5<70)) && CanOpen()){
         OpenBuy();
         return(0);
      }

      if (((diRSI6<70 && diRSI7>70) || (diRSI8<50 && diRSI9>50) || (diRSI10<30 && diRSI11>30)) && CanOpen()){
         OpenSell();
         return(0);
      }
   }
   if (ExistPositions()){
      if(OrderType()==OP_BUY){

         if ((diRSI12<30 && diRSI13>30) || (diRSI14<50 && diRSI15>50) || (diRSI16<70 && diRSI17>70)){
            CloseBuy();
            return(0);
         }
      }
      if(OrderType()==OP_SELL){

         if ((diRSI18>70 && diRSI19<70) || (diRSI20>50 && diRSI21<50) || (diRSI22>30 && diRSI23<30)){
            CloseSell();
            return(0);
         }
      }
   }
   return (0);
}

bool ExistPositions() {
for (int i=0; i<OrdersTotal(); i++) {
if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
if (OrderSymbol()==Symbol()) {
return(True);
}
} 
} 
return(false);
}
void ModifyStopLoss(double ldStopLoss) { 
   bool fm;
   fm = OrderModify(OrderTicket(),OrderOpenPrice(),ldStopLoss,OrderTakeProfit(),0,CLR_NONE); 
   if (fm && UseSound) PlaySound(NameFileSound); 
} 

void CloseBuy() { 
   bool fc; 
   fc=OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, clCloseBuy); 
   if (fc && UseSound) PlaySound(NameFileSound); 
} 
void CloseSell() { 
   bool fc; 
   fc=OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, clCloseSell); 
   if (fc && UseSound) PlaySound(NameFileSound); 
} 
void OpenBuy() { 
   double ldLot, ldStop, ldTake; 
   string lsComm; 
   ldLot = GetSizeLot(); 
   ldStop = GetStopLossBuy(); 
   ldTake = GetTakeProfitBuy(); 
   lsComm = GetCommentForOrder(); 
   OrderSend(Symbol(),OP_BUY,ldLot,Ask,Slippage,ldStop,ldTake,lsComm,0,0,clOpenBuy); 
   if (UseSound) PlaySound(NameFileSound); 
} 
void OpenSell() { 
   double ldLot, ldStop, ldTake; 
   string lsComm; 

   ldLot = GetSizeLot(); 
   ldStop = GetStopLossSell(); 
   ldTake = GetTakeProfitSell(); 
   lsComm = GetCommentForOrder(); 
   OrderSend(Symbol(),OP_SELL,ldLot,Bid,Slippage,ldStop,ldTake,lsComm,0,0,clOpenSell); 
   if (UseSound) PlaySound(NameFileSound); 
} 
string GetCommentForOrder() { return(Name_Expert); } 
double GetSizeLot() { return(Lots); } 
double GetStopLossBuy() { return (Bid-lStopLoss*Point);} 
double GetStopLossSell() { return(Ask+sStopLoss*Point); } 
double GetTakeProfitBuy() { return(Ask+lTakeProfit*Point); } 
double GetTakeProfitSell() { return(Bid-sTakeProfit*Point); } 

bool CanOpen(){
  int LastCloseTime = 0;
  for (int cnt = HistoryTotal()-1; cnt >= 0; cnt--)
      {
       OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY);
       if ((OrderSymbol() == Symbol()) && (OrderType() <= 1))
          {
           if (OrderCloseTime() > LastCloseTime) {LastCloseTime = OrderCloseTime();}
          }
      }
  if ((CurTime() - LastCloseTime) < (OpenOrderPeriod * 60)) {return(false);}
  else {return(true);}
}