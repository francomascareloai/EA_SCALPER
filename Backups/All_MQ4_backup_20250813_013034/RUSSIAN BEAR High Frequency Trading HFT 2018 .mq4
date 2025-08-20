 
#include <WinUser32.mqh>
#include <stderror.mqh>
#include <stdlib.mqh>
 
extern int    Magic=3331;

extern double MaxSpread=1.0;//0.6;
extern double Lot=0.1;
extern double SL=7.0;//3.5;//3.5;//5;
extern double TP=0.7;//0.4;
extern double jumpStepBuy =0.5;
extern double jumpStepSell=0.5;
extern double jumpTimeSec=0.5;//1.0;//max time to change in price in sec
extern bool   invertJump=true;//false;
extern bool   invertBuySell=true;//false;
extern int    SlippageOpen=0;
extern int    SlippageClose=0;
extern bool   TradeBuy=true;
extern bool   TradeSell=true;
extern bool   UseMM=true;
extern double MM=5;//9.5;//9.5;



extern bool   useMoving=false;
extern int    MovingPeriod=10;//if price under moving so can buy only

extern bool   noMoreTrades=false;

double pAsk=0;
double pBid=0;
double point;

bool canBuy=true;
bool canSell=true;

bool imaBuy=true;
bool imaSell=true;

double ArrPrice[10000];
int    ArrTimer[10000];

int t=0;
double l=0;
int nd;
int check;

void deinit()
{
}
 
void init()
{
  Comment("");
  if(MarketInfo(Symbol(),MODE_MINLOT)<0.1)
  {
    nd=2;
  }
  else if(MarketInfo(Symbol(),MODE_MINLOT)>0.1)
  {
    nd=0;
  }
  else
  {
    nd=1;
  }
 
   
   if(Digits==2 || Digits==3)point=0.01;
   if(Digits==4 || Digits==5)point=0.0001;
   
   ArrayInitialize(ArrPrice,0);
   ArrayInitialize(ArrTimer,0);
   
  pAsk=MarketInfo(Symbol(),MODE_ASK);
  pBid=MarketInfo(Symbol(),MODE_BID);
}
 
int start()
{
    int x;
    pAsk=MarketInfo(Symbol(),MODE_ASK);
    pBid=MarketInfo(Symbol(),MODE_BID);
    
    for(x=0;x<30;x++){if(TryClose())break;Sleep(100);}
    CalcLot();
    
    checkMoving();
    checkJump();
    for(x=0;x<30;x++){if(TryTrade())break;Sleep(100);}

        

}





void CalcLot()
{
  if(UseMM==true)
  {
    l=NormalizeDouble(AccountEquity()*MM/10000,nd);
    if(l<MarketInfo(Symbol(),MODE_MINLOT)) l=MarketInfo(Symbol(),MODE_MINLOT);
    if(l>MarketInfo(Symbol(),MODE_MAXLOT)) l=MarketInfo(Symbol(),MODE_MAXLOT);
  }
  else
  {
    l=Lot;
  }
}


 
bool TryTrade(){
   int total=OrdersTotal();

  //if(canBuy)Alert("buy"+(pAsk-pBid)/point);
  //if(canSell)Alert("Sell"+(pAsk-pBid)/point);
  
  if(TradeBuy==true && canBuy==true && imaBuy && !noMoreTrades && (pAsk-pBid)/point<=MaxSpread){
      if(!invertBuySell && MyOrdersBuyTotal (Magic)<1){OrderSend(Symbol(),OP_BUY,l,MarketInfo(Symbol(),MODE_ASK),SlippageOpen,0,0,"",Magic,0,Green);total++;}
      if( invertBuySell && MyOrdersSellTotal(Magic)<1){OrderSend(Symbol(),OP_SELL,l,MarketInfo(Symbol(),MODE_BID),SlippageOpen,0,0,"",Magic,0,Red);total++;}//inv
      check=GetLastError();if(check!=ERR_NO_ERROR) Print("error: ",ErrorDescription(check));
  }
  
  if(TradeSell==true && canSell==true && imaSell && !noMoreTrades && (pAsk-pBid)/point<=MaxSpread){
      if(!invertBuySell && MyOrdersSellTotal(Magic)<1){OrderSend(Symbol(),OP_SELL,l,MarketInfo(Symbol(),MODE_BID),SlippageOpen,0,0,"",Magic,0,Red);total++;}
      if( invertBuySell && MyOrdersBuyTotal (Magic)<1){OrderSend(Symbol(),OP_BUY,l,MarketInfo(Symbol(),MODE_ASK),SlippageOpen,0,0,"",Magic,0,Green);total++;}//inv
      check=GetLastError();if(check!=ERR_NO_ERROR) Print("error: ",ErrorDescription(check));
  }

   if(total==OrdersTotal()){return(true);}else{return(false);}
}




 
bool TryClose(){
   double p,moneyProfit,minProfit,maxLose;
   int total=OrdersTotal();
   
   for(int i=0;i<OrdersTotal();i++){
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      
      //close profit
      if(OrderMagicNumber()==Magic && OrderSymbol()==Symbol() && OrderType()==OP_SELL){
         p=OrderOpenPrice()-MarketInfo(Symbol(),MODE_ASK);
         moneyProfit=pipsProfit(OrderLots(),p);
         minProfit  =pipsProfit(OrderLots(),TP*point);
         maxLose    =pipsProfit(OrderLots(),-SL*point);
         if(moneyProfit+OrderCommission()>=minProfit){OrderClose(OrderTicket(),OrderLots(),MarketInfo(Symbol(),MODE_ASK),SlippageClose,Blue);total--;}
         if(moneyProfit+OrderCommission()<=maxLose  ){OrderClose(OrderTicket(),OrderLots(),MarketInfo(Symbol(),MODE_ASK),SlippageClose,Blue);total--;}
      }
    
      //close profit
      if(OrderMagicNumber()==Magic && OrderSymbol()==Symbol() && OrderType()==OP_BUY){
         p=MarketInfo(Symbol(),MODE_BID)-OrderOpenPrice();
         moneyProfit=pipsProfit(OrderLots(),p);
         minProfit  =pipsProfit(OrderLots(),TP*point);
         maxLose    =pipsProfit(OrderLots(),-SL*point);
         if(moneyProfit+OrderCommission()>=minProfit){OrderClose(OrderTicket(),OrderLots(),MarketInfo(Symbol(),MODE_BID),SlippageClose,Red);total--;}
         if(moneyProfit+OrderCommission()<=maxLose  ){OrderClose(OrderTicket(),OrderLots(),MarketInfo(Symbol(),MODE_ASK),SlippageClose,Blue);total--;}
      }
   }
   
   //return (true);
   if(total==OrdersTotal()){return(true);}else{return(false);}
}
 
int MyOrdersBuyTotal(int Magic)
{
  int c=0;
  int total  = OrdersTotal();

  for (int cnt = 0 ; cnt < total ; cnt++)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if (OrderMagicNumber() == Magic && OrderSymbol()==Symbol() && OrderType()==OP_BUY)
    {
      c++;
    }
  }
  return(c);
}
 
int MyOrdersSellTotal(int Magic)
{
  int c=0;
  int total  = OrdersTotal();
  for (int cnt = 0 ; cnt < total ; cnt++)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if (OrderMagicNumber() == Magic && OrderSymbol()==Symbol() && OrderType()==OP_SELL)
    {
      c++;
    }
  }
  return(c);
}


//////////////////REMON//////////////////////////////
double calc_iMA(int iPeriod){
   double d=0;
   for(int i=0;i<iPeriod;i++){
      d+=Close[i];
   }
   d/=iPeriod;
   return(d);
}
/////////////////////////////////////////
double pipsProfit(double lots,double pips){
   //Alert(MarketInfo(Symbol(),MODE_TICKVALUE));
   //return(lots*pips/point*10);
   return(MarketInfo(Symbol(),MODE_TICKVALUE)*lots*pips/point*10);
}
//////////////////////////////////////////
void checkJump(){
    //move all step to down
    for(int i=ArraySize(ArrPrice)-1;i>0;i--){
        ArrPrice[i]=ArrPrice[i-1];
        ArrTimer[i]=ArrTimer[i-1];
    }
    
    ArrPrice[0]=Bid;
    ArrTimer[0]=GetTickCount();
    
    int max=ArraySize(ArrTimer)-1;
    
    for(i=0;i<ArraySize(ArrTimer);i++){
        if(ArrTimer[0]-ArrTimer[i]>jumpTimeSec*1000 && ArrPrice[i]!=0){max=i;break;}
    }

    for(i=0;i<max;i++){
        double p=(Bid-ArrPrice[i])/point;
        //Alert(p + " , " +(pAsk-pBid)/point);
        if(!invertJump){
            if(p>= jumpStepSell){canSell=true;}else{canSell=false;}//jump up go sell
            if(p<=-jumpStepBuy ){canBuy =true;}else{canBuy =false;}//jump down go buy
        }else{
            if(p>= jumpStepSell){canBuy =true;}else{canBuy =false;}//jump up go buy
            if(p<=-jumpStepBuy ){canSell=true;}else{canSell=false;}//jump down go sell
        }
    }

}

void checkMoving(){
    double v=calc_iMA(MovingPeriod);
    if(Close[0]>v){imaBuy =true;}else{imaBuy =false;}
    if(Close[0]<v){imaSell=true;}else{imaSell=false;}
}




