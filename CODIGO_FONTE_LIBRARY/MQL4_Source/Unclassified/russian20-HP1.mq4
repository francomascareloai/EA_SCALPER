//+------------------------------------------------------------------+
//|                           Copyright 2005, Gordago Software Corp. |
//|                                          http://www.gordago.com/ |
//+------------------------------------------------------------------+

#property copyright "Copyright 2005, Gordago Software Corp."
#property link      "http://www.gordago.com"



extern double lTakeProfit = 20;
extern double sTakeProfit = 20;
extern color clOpenBuy = Blue;
extern color clCloseBuy = Aqua;
extern color clOpenSell = Red;
extern color clCloseSell = Violet;
extern color clModiBuy = Blue;
extern color clModiSell = Red;
extern string Name_Expert = "Generate from Gordago";
extern int Slippage = 1;
extern bool UseHourTrade = false;
extern int FromHourTrade = 14; //14
extern int ToHourTrade = 16;   //16
extern bool UseSound = True;
extern string NameFileSound = "alert.wav";
extern double Lots = 1;


void deinit() {
   Comment(" ");
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start(){
Comment("Started");
   if (UseHourTrade){
      if (!(Hour()>=FromHourTrade && Hour()<=ToHourTrade)) {
         Comment("Wait for the trade. Be patient, and you will make some money!");
         return(0);
      } else Comment("");
   }else Comment("");
   if(Bars<100){
      Print("bars less than 100");
      return(0);
   }
   if(lTakeProfit<10){
      Print("TakeProfit less than 10");
      return(0);
   }
   if(sTakeProfit<10){
      Print("TakeProfit less than 10");
      return(0);
   }

   double diClose0=iClose(NULL,30,0);
   double diMA1=iMA(NULL,30,20,0,MODE_SMA,PRICE_CLOSE,0);
   double diClose2=iClose(NULL,30,0);
   double diMomentum3=iMomentum(NULL,30,5,PRICE_CLOSE,0);
   double diClose4=iClose(NULL,30,0);
   double diClose5=iClose(NULL,30,1);
   double diClose6=iClose(NULL,30,0);
   double diMA7=iMA(NULL,30,20,0,MODE_SMA,PRICE_CLOSE,0);
   double diClose8=iClose(NULL,30,0);
   double diMomentum9=iMomentum(NULL,30,5,PRICE_CLOSE,0);
   double diClose10=iClose(NULL,30,0);
   double diClose11=iClose(NULL,30,1);
   double diClose12=iClose(NULL,30,0);
   double diMomentum13=iMomentum(NULL,30,5,PRICE_CLOSE,0);
   double diClose14=iClose(NULL,30,0);
   double diMomentum15=iMomentum(NULL,30,5,PRICE_CLOSE,0);


   if(AccountFreeMargin()<(1000*Lots)){
      Print("We have no money. Free Margin = ", AccountFreeMargin());
      return(0);
   }
   if (!ExistPositions()){

      if ((diClose0>diMA1 && diMomentum3 >100 && diClose4>diClose5)){
         OpenBuy();
         return(0);
      }

      if ((diClose6<diMA7 && diMomentum9 <100 && diClose10<diClose11)){
         OpenSell();
         return(0);
      }
   }
   if (ExistPositions()){
      if(OrderType()==OP_BUY){

         if ((diMomentum13<100)){
            CloseBuy();
            return(0);
         }
      }
      if(OrderType()==OP_SELL){

         if ((diMomentum15>100)){
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
   ldStop = 0; 
   ldTake = GetTakeProfitBuy(); 
   lsComm = GetCommentForOrder(); 
   OrderSend(Symbol(),OP_BUY,ldLot,Ask,Slippage,ldStop,ldTake,lsComm,0,0,clOpenBuy); 
   if (UseSound) PlaySound(NameFileSound); 
} 
void OpenSell() { 
   double ldLot, ldStop, ldTake; 
   string lsComm; 

   ldLot = GetSizeLot(); 
   ldStop = 0; 
   ldTake = GetTakeProfitSell(); 
   lsComm = GetCommentForOrder(); 
   OrderSend(Symbol(),OP_SELL,ldLot,Bid,Slippage,ldStop,ldTake,lsComm,0,0,clOpenSell); 
   if (UseSound) PlaySound(NameFileSound); 
} 
string GetCommentForOrder() { 	return(Name_Expert); } 
double GetSizeLot() { 	return(Lots); } 
double GetTakeProfitBuy() { 	return(Ask+lTakeProfit*Point); } 
double GetTakeProfitSell() { 	return(Bid-sTakeProfit*Point); } 

