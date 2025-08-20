
extern string comment="";
extern int magic=1234;

extern string moneymanagement="Money Management";

extern double lots1=0.1;
extern double lots2=0.2;
extern double lots3=0.3;
extern bool lotsoptimized=false;
extern double risk1=1;
extern double risk2=2;
extern double risk3=3;
extern bool martingale=false;
extern double multiplier=2.0;
extern double minlot=0.01;
extern double maxlot=10;
extern double lotdigits=2;
extern bool basketpercent=false;
extern double profit=10;
extern double loss=30;

extern string ordersmanagement="Order Management";

extern bool oppositeclose=true;
extern bool reversesignals=false;
extern int maxtrades=100;
extern int tradesperbar=1;
extern bool hidestop=false;
extern bool hidetarget=false;
extern int buystop=0;
extern int buytarget=0;
extern int sellstop=0;
extern int selltarget=0;
extern int trailingstart=0;
extern int trailingstop=0;
extern int trailingstep=1;
extern int breakevengain=0;
extern int breakeven=0;
int expiration=225;
extern int slippage=5;
extern double maxspread=20;

extern string entrylogics="Entry Logics";

extern int tenkansen=9;
extern int kijunsen=26;
extern int senkospan=52;
extern int shift=1;

extern string timefilter="Time Filter";

extern int gmtshift=2;
extern bool filter=false;
extern int start=7;
extern int end=21;
extern bool tradesunday=true;
extern bool fridayfilter=false;
extern int fridayend=24;

int dsf;
int xtn;
int dys; 

datetime t0,t1,lastbuyopentime,lastsellopentime;
double cb=0,lastbuyopenprice=0,lastsellopenprice=0;
double sl,tp,pt,mt,min,max,lastprofit;
int i,j,k,l,dg,bc=-1,tpb=0,total,ticket;
int buyopenposition=0,sellopenposition=0;
int totalopenposition=0,buyorderprofit=0;
int sellorderprofit=0,cnt=0;
double lotsfactor=1,ilots;
double initiallotsfactor=1;
int istart,iend;
double lots=0.1,risk=1;

int init(){

   t0=Time[0];t1=Time[0];dg=Digits;
   if(dg==3 || dg==5){pt=Point*10;mt=10;}else{pt=Point;mt=1;}
   
   //|---------martingale initialization
   int tempfactor,total=OrdersTotal();
   if(tempfactor==0 && total>0)
   {
      for(int cnt=0;cnt<total;cnt++)
      {
         if(OrderSelect(cnt,SELECT_BY_POS))
         {
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
            {
               tempfactor=NormalizeDouble(OrderLots()/lots,1+(MarketInfo(Symbol(),MODE_MINLOT)==0.01));
               break;
            }
         }
      }
   }
   int histotal=OrdersHistoryTotal();
   if(tempfactor==0&&histotal>0)
   {
      for(cnt=0;cnt<histotal;cnt++)
      {
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_HISTORY))
         {
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
            {
               tempfactor=NormalizeDouble(OrderLots()/lots,1+(MarketInfo(Symbol(),MODE_MINLOT)==0.01));
               break;
            }
         }
      }
   }
   if(tempfactor>0)
   lotsfactor=tempfactor;

   return(0);
}

int start(){

   total=OrdersTotal();
   
   if(breakevengain>0)
   {
      for(int b=0;b<total;b++){
         dsf=OrderSelect(b,SELECT_BY_POS,MODE_TRADES);
         if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==magic){
            if(OrderType()==OP_BUY){
               if(NormalizeDouble((Bid-OrderOpenPrice()),dg)>=NormalizeDouble(breakevengain*pt,dg)){
                  if(NormalizeDouble((OrderStopLoss()-OrderOpenPrice()),dg)<NormalizeDouble(breakeven*pt,dg)){
                     dys=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()+breakeven*pt,dg),OrderTakeProfit(),0,Blue);
                     return(0);
                  }
               }
            }
            else{
               if(NormalizeDouble((OrderOpenPrice()-Ask),dg)>=NormalizeDouble(breakevengain*pt,dg)){
                  if(NormalizeDouble((OrderOpenPrice()-OrderStopLoss()),dg)<NormalizeDouble(breakeven*pt,dg)){
                     dys=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()-breakeven*pt,dg),OrderTakeProfit(),0,Red);
                     return(0);
                  }
               }
            }
         }
      }
   }
   if(trailingstop>0)
   {
      for(int a=0;a<total;a++){
         dsf=OrderSelect(a,SELECT_BY_POS,MODE_TRADES);
         if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==magic){
            if(OrderType()==OP_BUY){
               if(NormalizeDouble(Ask,dg)>NormalizeDouble(OrderOpenPrice()+trailingstart*pt,dg)
               && (NormalizeDouble(OrderStopLoss(),dg)<NormalizeDouble(Bid-(trailingstop+trailingstep)*pt,dg))||(OrderStopLoss()==0)){
                  dys=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-trailingstop*pt,dg),OrderTakeProfit(),0,Blue);
                  return(0);
               }
            }
            else{
               if(NormalizeDouble(Bid,dg)<NormalizeDouble(OrderOpenPrice()-trailingstart*pt,dg)
               && (NormalizeDouble(OrderStopLoss(),dg)>(NormalizeDouble(Ask+(trailingstop+trailingstep)*pt,dg)))||(OrderStopLoss()==0)){                 
                  dys=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+trailingstop*pt,dg),OrderTakeProfit(),0,Red);
                  return(0);
               }
            }
         }
      }
   }
   if(basketpercent){
      double ipf=profit*(0.01*AccountBalance());double ilo=loss*(0.01*AccountBalance());
      cb=AccountEquity()-AccountBalance();
      if(cb>=ipf||cb<=(ilo*(-1))){
         for(i=total-1;i>=0;i--){
            dsf=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_BUY){
               xtn=OrderClose(OrderTicket(),OrderLots(),Bid,slippage*pt);
            }
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_SELL){
               xtn=OrderClose(OrderTicket(),OrderLots(),Ask,slippage*pt);
            }
         }
         return(0);
      }
   }
   
   for(cnt=0;cnt<OrdersTotal();cnt++){
      dsf=OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic&&OrderCloseTime()==0){
         totalopenposition++;
         lastprofit=OrderProfit();
         if(OrderType()==OP_BUY){
            buyopenposition++;lastbuyopenprice=OrderOpenPrice();buyorderprofit=OrderProfit();lastbuyopentime=OrderOpenTime();
         }
         if(OrderType()==OP_SELL){
            sellopenposition++;lastsellopenprice=OrderOpenPrice();sellorderprofit=OrderProfit();lastsellopentime=OrderOpenTime();
         }
      }
   }
   
   bool ichibuy=false;
   bool ichisell=false;
   
   double Tenkan=iIchimoku(NULL,0,tenkansen,kijunsen,senkospan,MODE_TENKANSEN,shift);
   double Kijun=iIchimoku(NULL,0,tenkansen,kijunsen,senkospan,MODE_KIJUNSEN,shift);
   double Tenkana=iIchimoku(NULL,0,tenkansen,kijunsen,senkospan,MODE_TENKANSEN,shift+1);
   double Kijuna=iIchimoku(NULL,0,tenkansen,kijunsen,senkospan,MODE_KIJUNSEN,shift+1);
   
   double Senkoua=iIchimoku(NULL,0,tenkansen,kijunsen,senkospan,MODE_SENKOUSPANA,shift);
   double Senkoub=iIchimoku(NULL,0,tenkansen,kijunsen,senkospan,MODE_SENKOUSPANB,shift);
   
   if(Tenkan>Kijun && Tenkana<Kijuna){
      if(Kijun<Senkoub && Kijun<Senkoua){ichibuy=true;lots=lots1;risk=risk1;}
      if((Kijun>Senkoub && Kijun<Senkoua)||(Kijun<Senkoub && Kijun>Senkoua)){ichibuy=true;lots=lots2;risk=risk2;}
      if(Kijun>Senkoua && Kijun>Senkoub){ichibuy=true;lots=lots3;risk=risk3;}
   }
   if(Tenkan<Kijun && Tenkana>Kijuna){
      if(Kijun>Senkoub && Kijun>Senkoua){ichisell=true;lots=lots1;risk=risk1;}
      if((Kijun>Senkoub && Kijun<Senkoua)||(Kijun<Senkoub && Kijun>Senkoua)){ichisell=true;lots=lots2;risk=risk2;}
      if(Kijun<Senkoua && Kijun<Senkoub){ichisell=true;lots=lots3;risk=risk3;}
   }

   bool openbuy=true;bool opensell=true;
   bool closebuy=false;bool closesell=false;

   //if()
   //{openbuy=false;opensell=false;}
   
   if(lotsoptimized && (martingale==false || (martingale && lastprofit>=0)))lots=NormalizeDouble((AccountBalance()/1000)*minlot*risk,lotdigits);
   if(lots<minlot)lots=minlot;if(lots>maxlot)lots=maxlot;
   
   if(tradesperbar==1 && (((TimeCurrent()-lastbuyopentime)<Period()) || ((TimeCurrent()-lastsellopentime)<Period())))tpb=1;
   
   bool buy=false;bool sell=false;

   if(ichibuy==true
   && openbuy)if(reversesignals)sell=true;else buy=true;
   
   if(ichisell==true
   && opensell)if(reversesignals)buy=true;else sell=true;

   if(bc!=Bars){tpb=0;bc=Bars;}
   /*Comment("\nSEFCU1  =  " + DoubleToStr(SEFCU1,4),"\nSEFCD1  =  " + DoubleToStr(SEFCD1,4));*/

   if((oppositeclose && sell)||(closebuy)){
      for(i=total-1;i>=0;i--){
         dsf=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_BUY){
            xtn=OrderClose(OrderTicket(),OrderLots(),Bid,slippage*pt);
         }
      }
   }
   if((oppositeclose && buy)||(closesell)){
      for(j=total-1;j>=0;j--){
         dsf=OrderSelect(j,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_SELL){
            xtn=OrderClose(OrderTicket(),OrderLots(),Ask,slippage*pt);
         }
      }
   }
   if(hidestop){
      for(k=total-1;k>=0;k--){
         dsf=OrderSelect(k,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_BUY && buystop>0 && Bid<(OrderOpenPrice()-buystop*pt)){
            xtn=OrderClose(OrderTicket(),OrderLots(),Bid,slippage*pt);
         }
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_SELL && sellstop>0 && Ask>(OrderOpenPrice()+sellstop*pt)){
            xtn=OrderClose(OrderTicket(),OrderLots(),Ask,slippage*pt);
         }
      }
   }
   if(hidetarget){
      for(l=total-1;l>=0;l--){
         dsf=OrderSelect(l,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_BUY && buytarget>0 && Bid>(OrderOpenPrice()+buytarget*pt)){
            xtn=OrderClose(OrderTicket(),OrderLots(),Bid,slippage*pt);
         }
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_SELL && selltarget>0 && Ask<(OrderOpenPrice()-selltarget*pt)){
           xtn=OrderClose(OrderTicket(),OrderLots(),Ask,slippage*pt);
         }
      }
   }

   istart=start+(gmtshift);if(istart>23)istart=istart-24;
   iend=end+(gmtshift);if(iend>23)iend=iend-24;
   
   if((tradesunday==false&&DayOfWeek()==0)
   ||(filter&&DayOfWeek()>0&&
   (
   (istart<iend && !(Hour()>=(istart)&&Hour()<=(iend)))||
   (istart>iend && !((Hour()>=(istart)&&Hour()<=23)||(Hour()>=0&&Hour()<=(iend))))))
   ||(fridayfilter&&DayOfWeek()==5&&!(Hour()<(fridayend+(gmtshift))))){
      return(0);
   }
   if((Ask-Bid)>=maxspread*pt)return(0);
   
   int expire=0;
   /*if(expiration>0)expire=TimeCurrent()+(expiration*60)-5;*/
   
   if((count(OP_BUY,magic)+count(OP_SELL,magic))<maxtrades){  
      if(buy && tpb<tradesperbar && IsTradeAllowed()){
         while(IsTradeContextBusy())Sleep(3000);
         if(hidestop==false&&buystop>0){sl=Ask-buystop*pt;}else{sl=0;}
         if(hidetarget==false&&buytarget>0){tp=Ask+buytarget*pt;}else{tp=0;}
         if(martingale)ilots=NormalizeDouble(lots*martingalefactor(),2);else ilots=lots;
         if(ilots<minlot)ilots=minlot;if(ilots>maxlot)ilots=maxlot;
         RefreshRates();ticket=OrderSend(Symbol(),OP_BUY,ilots,Ask,slippage*mt,sl,tp,comment+". Magic: "+DoubleToStr(magic,0),magic,expire,Blue);
         if(ticket<=0){Print("Error Occured : "+errordescription(GetLastError()));}
         else{tpb++;Print("Order opened : "+Symbol()+" Buy @ "+Ask+" SL @ "+sl+" TP @"+tp+" ticket ="+ticket);}
      }
      if(sell && tpb<tradesperbar && IsTradeAllowed()){
         while(IsTradeContextBusy())Sleep(3000);
         if(hidestop==false&&sellstop>0){sl=Bid+sellstop*pt;}else{sl=0;}
         if(hidetarget==false&&selltarget>0){tp=Bid-selltarget*pt;}else{tp=0;}
         if(martingale)ilots=NormalizeDouble(lots*martingalefactor(),2);else ilots=lots;
         if(ilots<minlot)ilots=minlot;if(ilots>maxlot)ilots=maxlot;
         RefreshRates();ticket=OrderSend(Symbol(),OP_SELL,ilots,Bid,slippage*mt,sl,tp,comment+". Magic: "+DoubleToStr(magic,0),magic,expire,Red);
         if(ticket<=0){Print("Error Occured : "+errordescription(GetLastError()));}
         else{tpb++;Print("Order opened : "+Symbol()+" Sell @ "+Bid+" SL @ "+sl+" TP @"+tp+" ticket ="+ticket);}
      }
   }
   return(0);
}

int count(int type,int magic){
   int cnt;cnt=0;
   for(int i=0;i<OrdersTotal();i++){
      dsf=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderType()==type && ((OrderMagicNumber()==magic)||magic==0)){
         cnt++;
      }
   }
   return(cnt);
}

//|---------martingale

int martingalefactor()
{
   int histotal=OrdersHistoryTotal();
   if (histotal>0)
   {
      for(int cnt=histotal-1;cnt>=0;cnt--)
      {
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_HISTORY))
         {
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
            {
               if(OrderProfit()<0)
               {
                  lotsfactor=lotsfactor*multiplier;
                  return(lotsfactor);
               }
               else
               {
                  lotsfactor=initiallotsfactor;
                  if(lotsfactor<=0)
                  {
                     lotsfactor=1;
                  }
                  return(lotsfactor);
               }
            }
         }
      }
   }
   return(lotsfactor);
}

string errordescription(int code)
{
   string error;
   switch(code)
   {
      case 0:
      case 1:error="no error";break;
      case 2:error="common error";break;
      case 3:error="invalid trade parameters";break;
      case 4:error="trade server is busy";break;
      case 5:error="old version of the client terminal";break;
      case 6:error="no connection with trade server";break;
      case 7:error="not enough rights";break;
      case 8:error="too frequent requests";break;
      case 9:error="malfunctional trade operation";break;
      case 64:error="account disabled";break;
      case 65:error="invalid account";break;
      case 128:error="trade timeout";break;
      case 129:error="invalid price";break;
      case 130:error="invalid stops";break;
      case 131:error="invalid trade volume";break;
      case 132:error="market is closed";break;
      case 133:error="trade is disabled";break;
      case 134:error="not enough money";break;
      case 135:error="price changed";break;
      case 136:error="off quotes";break;
      case 137:error="broker is busy";break;
      case 138:error="requote";break;
      case 139:error="order is locked";break;
      case 140:error="long positions only allowed";break;
      case 141:error="too many requests";break;
      case 145:error="modification denied because order too close to market";break;
      case 146:error="trade context is busy";break;
      case 4000:error="no error";break;
      case 4001:error="wrong function pointer";break;
      case 4002:error="array index is out of range";break;
      case 4003:error="no memory for function call stack";break;
      case 4004:error="recursive stack overflow";break;
      case 4005:error="not enough stack for parameter";break;
      case 4006:error="no memory for parameter string";break;
      case 4007:error="no memory for temp string";break;
      case 4008:error="not initialized string";break;
      case 4009:error="not initialized string in array";break;
      case 4010:error="no memory for array\' string";break;
      case 4011:error="too long string";break;
      case 4012:error="remainder from zero divide";break;
      case 4013:error="zero divide";break;
      case 4014:error="unknown command";break;
      case 4015:error="wrong jump (never generated error)";break;
      case 4016:error="not initialized array";break;
      case 4017:error="dll calls are not allowed";break;
      case 4018:error="cannot load library";break;
      case 4019:error="cannot call function";break;
      case 4020:error="expert function calls are not allowed";break;
      case 4021:error="not enough memory for temp string returned from function";break;
      case 4022:error="system is busy (never generated error)";break;
      case 4050:error="invalid function parameters count";break;
      case 4051:error="invalid function parameter value";break;
      case 4052:error="string function internal error";break;
      case 4053:error="some array error";break;
      case 4054:error="incorrect series array using";break;
      case 4055:error="custom indicator error";break;
      case 4056:error="arrays are incompatible";break;
      case 4057:error="global variables processing error";break;
      case 4058:error="global variable not found";break;
      case 4059:error="function is not allowed in testing mode";break;
      case 4060:error="function is not confirmed";break;
      case 4061:error="send mail error";break;
      case 4062:error="string parameter expected";break;
      case 4063:error="integer parameter expected";break;
      case 4064:error="double parameter expected";break;
      case 4065:error="array as parameter expected";break;
      case 4066:error="requested history data in update state";break;
      case 4099:error="end of file";break;
      case 4100:error="some file error";break;
      case 4101:error="wrong file name";break;
      case 4102:error="too many opened files";break;
      case 4103:error="cannot open file";break;
      case 4104:error="incompatible access to a file";break;
      case 4105:error="no order selected";break;
      case 4106:error="unknown symbol";break;
      case 4107:error="invalid price parameter for trade function";break;
      case 4108:error="invalid ticket";break;
      case 4109:error="trade is not allowed";break;
      case 4110:error="longs are not allowed";break;
      case 4111:error="shorts are not allowed";break;
      case 4200:error="object is already exist";break;
      case 4201:error="unknown object property";break;
      case 4202:error="object is not exist";break;
      case 4203:error="unknown object type";break;
      case 4204:error="no object name";break;
      case 4205:error="object coordinates error";break;
      case 4206:error="no specified subwindow";break;
      default:error="unknown error";
   }
   return(error);
}  