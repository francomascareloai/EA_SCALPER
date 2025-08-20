 //+------------------------------------------------------------------+
 //|                                                                  |
 //|                                                                  |
 //|                                      www.arabictrader.com/vb     |
 //|                                                                  |
 //|                                          mrdollar.cs@gmail.com   |
 //+------------------------------------------------------------------+
 
#property copyright "MR.dollarEA"
#property link      "mrdollar.cs@gmail.com"

          
 extern bool  UseHourTrade = false;        
 extern int  FromHourTrade = 7;            
 extern int  ToHourTrade = 17; 
 extern bool OpenHedgeFirstTime=false;
 extern double HedgeLots=0.1;
 extern int HedgeTP=0;
 extern int HedgeSL=0;
 extern bool AddOrdersAfterClose=true;
 extern bool ReverseClosedOrders=false;
 extern bool CloseIfLastOrderProfit=false;
 extern string S1="BuyStop Orders Settings ";
 extern bool OpenBuyStopOrders=true;
 extern int NumberOfBuyStopOrders=50;
 extern double BuyStopFirstLot=0.1;
  extern int DistanceFromCurrentPriceBS=0;
 extern int DistanceBetweenBuyS=20;
 extern int Distance_AddBuyS=0;
 extern int BuyStopTakeProfit=0;
 extern int BuyStopSL=0;
 extern string S2="BuyLimit Orders Settings";
 extern bool OpenBuyLimitOrders=true;
 extern int NumberOfBuyLimitOrders=50;
 extern double BuyLimitFirstLot=0.1;
  extern int DistanceFromCurrentPriceBL=0;
extern int DistanceBetweenBuyL=20;
 extern int Distance_AddBuyL=0;
 extern int BuyLimitTakeProfit=0;
 extern int BuyLimitSL=0;
 extern string S3="SellStop Orders Settings";
 extern bool OpenSellStopOrders=true;
 extern int NumberOfSellStopOrders=50;
 extern double SellStopFirstLot=0.1;
  extern int DistanceFromCurrentPriceSS=0;
 extern int DistanceBetweenSellS=20;
  extern int Distance_AddSellS=0;
 extern int SellStopTakeProfit=0;
 extern int SellStopSL=0;
 extern string S4="SellLimit Orders Settings";
 extern bool OpenSellLimitOrders=true;
 extern int NumberOfSellLimitOrders=50;
 extern double SellLimitFirstLot=0.1;
  extern int DistanceFromCurrentPriceSL=0;
 extern int DistanceBetweenSellL=20;
  extern int Distance_AddSellL=0;
 extern int SellLimitTakeProfit=0;
 extern int SellLimitSL=0;
extern string S5=" Lots Multiplier ";
 extern bool UseMultiplier=true;
 extern bool X_Multiplier=true;
 extern double Multiplier=2;

 
 extern string S6=" Order Open Time/Price Settings ";
  extern bool HighLowCandle=false;
 extern bool OpenAtChoosenHour=false;
 extern int Hour_=12;
 extern double StartPrice=0;
 extern int Gap=3;

 extern bool OnlyOnce=false;
 extern string S7=" Close and Delete Orders ";
 extern bool FridayOpenOrdersFilter=true;
 extern bool FridayDeleteOrders=false;
 extern bool FridayCloseOrders=false;
 extern int _Hour=20;
 extern bool CloseAfterPassMinutes=false;
 extern int MinutesPass=100;
 extern bool CloseOrdersAfterProfit=true;
 extern bool DeleteOrdersAfterProfit=true;
 extern int Profit=200;
  extern bool CloseOrdersAfterLoss=false;
 extern double Loss=-200;
extern string S8=" Order Management";

extern int TrailingStop=0;
extern int TrailingProfit=0;
extern int TrailingStep=0;

extern string S9="Time Filter";
extern bool FridayCloseEA=false;
extern int Friday_CloseHour=20;


     
 bool enter;
  double point;double Price;
 int digits;int i,Q,Qq;
 extern int MagicNumber=2533;
                         
 int init()
{
  if(OpenBuyStopOrders&&OpenBuyLimitOrders){Q=NumberOfBuyLimitOrders+NumberOfBuyStopOrders;}
  else if((OpenBuyStopOrders==false&&OpenBuyLimitOrders)){Q=NumberOfBuyLimitOrders;}
  else if((OpenBuyStopOrders&&OpenBuyLimitOrders==false)){Q=NumberOfBuyStopOrders;}
  else{Q=0;}
  if(OpenSellStopOrders&&OpenSellLimitOrders){Qq=NumberOfSellLimitOrders+NumberOfSellStopOrders;}
  else if((OpenSellStopOrders&&OpenSellLimitOrders==false)){Qq=NumberOfSellStopOrders;}
    else if((OpenSellStopOrders==false&&OpenSellLimitOrders)){Qq=NumberOfSellLimitOrders;}
     else{Qq=0;}
  enter=true;
    if(Digits<4)
   {
      point=0.01;
      digits=2;
   }
   else
   {
      point=0.0001;
      digits=4;
   }
return(0);
}

 //+------------------------------------------------------------------+
 //| FUNCTION DEFINITIONS    deinitialization function                |
 //+------------------------------------------------------------------+

 void deinit() {
    Comment("");
  }
 
 int orderscnt(){
 int cnt=0;
   for(int i =0;i<OrdersTotal();i++){
     if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
       if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber){
         cnt++;
       }
     }
   }
    return(cnt);
  }
int ordersPen(){
 int cnt=0;
   for(int i =0;i<OrdersTotal();i++){
     if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
       if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber&&OrderType()>OP_SELL){
         cnt++;
       }
     }
   }
    return(cnt);
  }
  int orders(){
 int cnt=0;
   for(int i =0;i<OrdersTotal();i++){
     if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
       if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber&&OrderType()<=OP_SELL){
         cnt++;
       }
     }
   }
    return(cnt);
  }
 //+------------------------------------------------------------------+
 //| FUNCTION DEFINITIONS   Start function                            |
 //+------------------------------------------------------------------+
 int start()
   {
    Comment("Programmed by MR.dollar"+"\n"+"ãäÊÏì ÇáãÊÏÇæá ÇáÚÑÈí"+"\n"+"www.arabictrader.com/vb"+"\n"+
    "Number Of Pending Orders = "+ordersPen()+"\n"+"Number Of Market Orders = "+orders()+"\n"+
    "Account Free Margin = "+DoubleToStr(AccountFreeMargin(),2)+"\n"+"Profit Value = "+DoubleToStr(AccountProfit(),2));
       bool ss=true;
        if(Qq+Q==orderscnt()&&!((FromHourTrade < ToHourTrade && TimeHour(TimeCurrent()) >= FromHourTrade && TimeHour(TimeCurrent()) < ToHourTrade) || (FromHourTrade > ToHourTrade && TimeHour(TimeCurrent()) >= FromHourTrade ||
               TimeHour(TimeCurrent()) < ToHourTrade))&&UseHourTrade){
       DeletePendingOrders();
       }
       if (UseHourTrade){
        if(!((FromHourTrade < ToHourTrade && TimeHour(TimeCurrent()) >= FromHourTrade && TimeHour(TimeCurrent()) < ToHourTrade) || (FromHourTrade > ToHourTrade && TimeHour(TimeCurrent()) >= FromHourTrade ||
               TimeHour(TimeCurrent()) < ToHourTrade))){
           Comment("Non-Trading Hours!");
           ss=false;
         }
       }
       
        if(TrailingStop>0)MoveTrailingStop();
         if(FridayCloseEA&&Hour()>=Friday_CloseHour&&DayOfWeek()==5)
           return;
        /////////////////////////add orders again//////////////////
        if(AddOrdersAfterClose&&orderscnt()>0){
         OpenClosedOrders(OP_BUY);
         OpenClosedOrders(OP_SELL); 
        }
        int totalNumber=0;
        //////////////////////////////////////////////////
        if(ss==true&&orderscnt()<1&&(OnlyOnce==false||enter==true)&&(FridayOpenOrdersFilter==false||DayOfWeek()!=5||Hour()<_Hour)&&(Hour()==Hour_||OpenAtChoosenHour==false)){
       double lastlot;double newlot;double TP,SL;
       lastlot=0;
        if(OpenHedgeFirstTime)
         {
          if(HedgeSL==0){SL=0;}else{SL=Ask-HedgeSL*point;}
          if(HedgeTP==0){TP=0;}else{TP=Ask+HedgeTP*point;}
          OrderSend(Symbol(),OP_BUY,HedgeLots,NormalizeDouble(Ask,Digits),3*Q,NormalizeDouble(SL,Digits),NormalizeDouble(TP,Digits),"MR.dollar EA",MagicNumber,0,Blue);
          if(HedgeSL==0){SL=0;}else{SL=Bid+HedgeSL*point;}
          if(HedgeTP==0){TP=0;}else{TP=Bid-HedgeTP*point;}
          OrderSend(Symbol(),OP_SELL,HedgeLots,NormalizeDouble(Bid,Digits),3*Q,NormalizeDouble(SL,Digits),NormalizeDouble(TP,Digits),"MR.dollar EA",MagicNumber,0,Red); 
         }
       if(OpenSellLimitOrders){
        for(i=1;i<=NumberOfSellLimitOrders;i++)
        {
         if(UseMultiplier){
          if(X_Multiplier){
           newlot=Multiplier*lastlot;
          }
          else{newlot=lastlot+SellLimitFirstLot;}
          }
         else{newlot=SellLimitFirstLot;}
        if(newlot==0){newlot=SellLimitFirstLot;}
         lastlot=newlot;
       
         if(StartPrice==0){Price=Bid+(DistanceFromCurrentPriceSL*point)+(i*DistanceBetweenSellL*point+i*Distance_AddSellL*point);}
         else{Price=StartPrice+(DistanceFromCurrentPriceSL*point)+(i*DistanceBetweenSellL*point);}
         if(HighLowCandle){Price=High[1]+(DistanceFromCurrentPriceSL*point)+(i*DistanceBetweenSellL*point);}
         if(SellLimitTakeProfit==0){TP=0;}else{TP=Price-SellLimitTakeProfit*point;}
         if(SellLimitSL==0){SL=0;}else{SL=Price+SellLimitSL*point;}
         
         if((StartPrice==0&&HighLowCandle==false)||(HighLowCandle==true&&Hour()==Hour_+1)||(Close[0]>=StartPrice-Gap*point&&Close[0]<=StartPrice+Gap*point)){  
            OrderSend(Symbol(),OP_SELLLIMIT,newlot,Price,3,SL,TP,"MR.dollar EA"+totalNumber,MagicNumber,0,Red);
             totalNumber++;
          }
         }
        }
       
       lastlot=0;
       if(OpenBuyLimitOrders){
        for(i=1;i<=NumberOfBuyLimitOrders;i++)
        {
         if(UseMultiplier){
        if(X_Multiplier){
         newlot=Multiplier*lastlot;
        }
        else{newlot=lastlot+BuyLimitFirstLot;}
       }
       else{newlot=BuyLimitFirstLot;}
         if(newlot==0){newlot=BuyLimitFirstLot;}
         lastlot=newlot;
     
         if(StartPrice==0){Price=Ask-(DistanceFromCurrentPriceBL*point)-(i*DistanceBetweenBuyL*point+i*Distance_AddBuyL*point);} 
         else{Price=StartPrice-(DistanceFromCurrentPriceBL*point)-(i*DistanceBetweenBuyL*point);}
         if(HighLowCandle){Price=Low[1]-(DistanceFromCurrentPriceBL*point)-(i*DistanceBetweenBuyL*point);}
          if(BuyLimitTakeProfit==0){TP=0;}else{TP=Price+BuyLimitTakeProfit*point;}
          if(BuyLimitSL==0){SL=0;}else{SL=Price-BuyLimitSL*point;}
          if((StartPrice==0&&HighLowCandle==false)||(HighLowCandle==true&&Hour()==Hour_+1)||(Close[0]>=StartPrice-Gap*point&&Close[0]<=StartPrice+Gap*point)){ 
            OrderSend(Symbol(),OP_BUYLIMIT,newlot,Price,3,SL,TP,"MR.dollar EA"+totalNumber,MagicNumber,0,Green);
           totalNumber++;
          }  
         }
       }
        lastlot=0;
       if(OpenSellStopOrders){ 
        for(i=1;i<=NumberOfSellStopOrders;i++)
        {
       if(UseMultiplier){
        if(X_Multiplier){
        newlot=Multiplier*lastlot;
        }else{newlot=lastlot+SellStopFirstLot;}
        }else{newlot=SellStopFirstLot;}
         if(newlot==0){newlot=SellStopFirstLot;}
         lastlot=newlot;
        if(StartPrice==0){Price=Bid-(DistanceFromCurrentPriceSS*point)-(i*DistanceBetweenSellS*point+i*Distance_AddSellS*point);}
        else{Price=StartPrice-(DistanceFromCurrentPriceSS*point)-(i*DistanceBetweenSellS*point);}
        if(HighLowCandle){Price=Low[1]-(DistanceFromCurrentPriceSS*point)-(i*DistanceBetweenSellS*point);}
         if(SellStopTakeProfit==0){TP=0;}else{TP=Price-SellStopTakeProfit*point;}
         if(SellStopSL==0){SL=0;}else{SL=Price+SellStopSL*point;}
         if((StartPrice==0&&HighLowCandle==false)||(HighLowCandle==true&&Hour()==Hour_+1)||(Close[0]>=StartPrice-Gap*point&&Close[0]<=StartPrice+Gap*point)){ 
          OrderSend(Symbol(),OP_SELLSTOP,newlot,Price,3,SL,TP,"MR.dollar EA"+totalNumber,MagicNumber,0,Red);
           totalNumber++;
          } 
         }
        }
         lastlot=0;
        if(OpenBuyStopOrders){
        for(i=1;i<=NumberOfBuyStopOrders;i++)
        {
      if(UseMultiplier){
        if(X_Multiplier){
        newlot=Multiplier*lastlot;
        }else{newlot=lastlot+BuyStopFirstLot;}
        }else{newlot=BuyStopFirstLot;}
         if(newlot==0){newlot=BuyStopFirstLot;}
         lastlot=newlot;
     //     if(i>1){DistanceFromCurrentPriceBS=0;}
         if(StartPrice==0){Price=Ask+(DistanceFromCurrentPriceBS*point)+(i*DistanceBetweenBuyS*point+i*Distance_AddBuyS*point);} 
         else{Price=StartPrice+(DistanceFromCurrentPriceBS*point)+(i*DistanceBetweenBuyS*point);}
         if(HighLowCandle){Price=High[1]+(DistanceFromCurrentPriceBS*point)+(i*DistanceBetweenBuyS*point);}
         if(BuyStopTakeProfit==0){TP=0;}else{TP=Price+BuyStopTakeProfit*point;}
         if(BuyStopSL==0){SL=0;}else{SL=Price-BuyStopSL*point;}
         if((StartPrice==0&&HighLowCandle==false)||(HighLowCandle==true&&Hour()==Hour_+1)||(Close[0]>=StartPrice-Gap*point&&Close[0]<=StartPrice+Gap*point)){ 
          OrderSend(Symbol(),OP_BUYSTOP,newlot,Price,3,SL,TP,"MR.dollar EA"+totalNumber,MagicNumber,0,Green);
          totalNumber++;
          } 
         }
        }
       } 
   ////////////////////////////////////////////////////
      int m1;
    
     if(Q+Qq>orderscnt()&&CloseIfLastOrderProfit){
     DeletePendingOrders();
     while(orders()>=1){CloseAllOrders();}
     }
     if (profit()>=Profit)
        {
        if(CloseOrdersAfterProfit){
        while(orders()>=1){CloseAllOrders();
        }
        if(DeleteOrdersAfterProfit){DeletePendingOrders();}
        
         }
          }
        if((profit()<Loss&&CloseOrdersAfterLoss)||(CloseAfterPassMinutes&&TimePassed())){
       while(orders()>=1&&m1<20){
       CloseAllOrders();
       DeletePendingOrders();
       m1++;
       }
      }
     if(DayOfWeek()==5&&Hour()>=_Hour){
     if(FridayDeleteOrders==true){  
        DeletePendingOrders();}
     if(FridayCloseOrders==true){
       CloseAllOrders();}
       } 
     }
   
  
//+------------------------------------------------------------------+
int TimePassed(){
for(int i=0;i<=OrdersTotal();i++){
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber){
if((TimeCurrent()-OrderOpenTime())/60>=MinutesPass){
return(true);
  }
 }
}
return(false);
}
int CloseAllOrders()
{ 
int total=OrdersTotal();

  for (int cnt = 0 ; cnt < total ; cnt++)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if (OrderMagicNumber() == MagicNumber && OrderSymbol()==Symbol())
    {
      if (OrderType()==OP_BUY)
      {
        if(OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,digits),3)==false){
        cnt=0;total=OrdersTotal();}
      }
      if (OrderType()==OP_SELL)
      {
       if(OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,digits),3)==false){
       cnt=0;total=OrdersTotal();}
      }
    }
  }
  return(0);
}  

 //+------------------------------------------------------------------+
 //| FUNCTION DEFINITIONS   TrailingStop                              |
 //+------------------------------------------------------------------+
    
    //|---------trailing stop

void MoveTrailingStop()
{
   int cnt,total=OrdersTotal();
   for(cnt=0;cnt<total;cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL&&OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber)
      {
         if(OrderType()==OP_BUY)
         {
            if(TrailingStop>0&&NormalizeDouble(Ask-TrailingStep*point,digits)>NormalizeDouble(OrderOpenPrice()+TrailingProfit*point,digits))  
            {                 
               if((NormalizeDouble(OrderStopLoss(),digits)<NormalizeDouble(Bid-TrailingStop*point,digits))||(OrderStopLoss()==0))
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-TrailingStop*point,digits),OrderTakeProfit(),0,Blue);
                }
            }
         }
         else 
         {
            if(TrailingStop>0&&NormalizeDouble(Bid+TrailingStep*point,digits)<NormalizeDouble(OrderOpenPrice()-TrailingProfit*point,digits))  
            {                 
               if((NormalizeDouble(OrderStopLoss(),digits)>(NormalizeDouble(Ask+TrailingStop*point,digits)))||(OrderStopLoss()==0))
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+TrailingStop*point,digits),OrderTakeProfit(),0,Red);
               }
            }
         }
      }
   }
}
int DeletePendingOrders()
{
  int total  = OrdersTotal();
  
  for (int cnt = total-1 ; cnt >= 0 ; cnt--)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if (OrderMagicNumber() == MagicNumber && OrderSymbol()==Symbol() && (OrderType()>OP_SELL))
    {
      OrderDelete(OrderTicket());
    }
  }
  return(0);
}
 //+---------------------------------------------------------------------------------+
  
 bool CheckOpenedOrders(string comment){
  for(int i=0;i<OrdersTotal();i++){
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   string com=OrderComment();
   if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber){
    if(com==comment)return(true);
   }
  }
 return(false);
}

void OpenClosedOrders(int type)
 {
 for(int i=0;i<OrdersHistoryTotal();i++){
  OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
  string comment=OrderComment();double open=OrderOpenPrice();
  double lott=OrderLots();double stop=OrderStopLoss();double profit=OrderTakeProfit();
  
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber&&OrderType()==type){
   if(CheckOpenedOrders(comment)==false){
   if((type==OP_BUY&&!ReverseClosedOrders)||(type==OP_SELL&&ReverseClosedOrders)){ 
    if(Ask>open+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point){
     OrderSend(Symbol(),OP_BUYLIMIT,lott,open,3,stop,profit,comment,MagicNumber,0,Green);}
    
    if(Ask<open-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point){
     OrderSend(Symbol(),OP_BUYSTOP,lott,open,3,stop,profit,comment,MagicNumber,0,Green);}
   }
   if((type==OP_SELL&&!ReverseClosedOrders)||(type==OP_BUY&&ReverseClosedOrders)){
   if(Bid>open+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point){
     OrderSend(Symbol(),OP_SELLSTOP,lott,open,3,stop,profit,comment,MagicNumber,0,Green);}
    
    if(Bid<open-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point){
     OrderSend(Symbol(),OP_SELLLIMIT,lott,open,3,stop,profit,comment,MagicNumber,0,Green);}
     }
    }
   }
  }
 }


double profit(){
 double c;
 for(int i=0;i<=OrdersTotal();i++){
  OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()==Symbol()){
   c+=OrderProfit();
  }
 }
 return(c);
}   
           