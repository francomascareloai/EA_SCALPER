#property copyright "Ex4toMq4Decompiler MT4 Expert Advisors and Indicators Base of Source Codes"
#property link      "https://ex4tomq4decompiler.com/"
//----

extern int Strategy = 0;
extern string Strategy_Controlled_Settings = "==================================================================";
extern int RealTakeProfit = 29;
extern int RealStopLoss = 0;
extern int PipStep = 21;
extern int VirtualTrades = 5;
extern int VirtualTakeProfit = 34;
extern double LotMultiplier = 1.7;
extern int MaxBuyTrades = 5;
extern int MaxSellTrades = 5;
extern string End_Of_Strategy_Settings = "=============================================================";
extern int MM = 0;
extern string Risk_Info = "0.1-3 =Low, 4-7 =Medium, 8+ =High";
extern double Risk_ = 0.5;
extern double ManualLot = 0.01;
extern int Accuracy = 100;
extern string DD_StoplossPct_Info = "Closes all trades when DD reaches this Percent";
extern double DD_StoplossPct = 50.0;
extern string FloatingTP_Pct_Info = "Closes all trades when Floating trades reach this Pct";
extern double FloatingTP_Pct = 5.0;
extern bool ECN = TRUE;
extern int Slippage = 6;
extern int StartingTradeDay = 0;
extern int EndingTradeDay = 6;
extern int RestartSlippage = 10;
extern int RestartHours = 10;
extern int MagicNumber = 29988;
extern string EA_Name = "Flex EA";
extern bool ChartDisplay = TRUE;
extern string Font = "Calibri";
extern int Color = 16760576;
extern int Size = 10;
extern int TrailingMode = 1;
extern int TrailingStep = 2;
extern int TrailTP = 3;
extern int TrailSL = 3;
extern int newMode = 1;



 string comment="Forex-Flex-EA";                
 double lots=0.1;                
 bool lotsoptimized=false;        
 bool martingale=false;           
 double multiplier=2.0;            
 double minlot=0.01;              
 double maxlot=10;               
 double lotdigits=2;              
 bool basketpercent=false;      
 double profit=10;              
 double loss=30;                 
 bool oppositeclose=false;         
 bool reversesignals=false;        
 int tradesperbar=1;             
 bool hidestop=true;              
 bool hidetarget=true;           
 int trailingstart=0;              
 int trailingstop=0;               
 int breakevengain=0;             
 int breakeven=0;                
int expiration=0;                     
 double maxspread=100;            
 bool onlycross=false;             
 int MaMetod1=1;
 int MaPeriod1=3;
 int shift=1;                     
 int gmtshift=2;                   
 bool filter=false;                
 int start=7;                      
 int end=21;                       
 bool tradesunday=true;            
 bool fridayfilter=false;         
 int fridayend=24;                

int mod;
int sel;
int clo;

datetime t0,t1,lastbuyopentime,lastsellopentime;
double cb=0,lastbuyopenprice=0,lastsellopenprice=0;
double sl,tp,pt,mt,min,max,lastprofit;
int i,j,k,l,dg,bc=-1,tpb=0,tps=0,total,ticket;
int buyopenposition=0,sellopenposition=0;
int totalopenposition=0,buyorderprofit=0;
int sellorderprofit=0,cnt=0;
double lotsfactor=1,ilots;
double initiallotsfactor=1;
int istart,iend;

int init(){
   t0=Time[0];t1=Time[0];dg=Digits;
   if(dg==3 || dg==5){pt=Point*10;mt=10;}else{pt=Point;mt=1;}
   
   int tempfactor,total=OrdersTotal();
   if(tempfactor==0 && total>0){
      for(int cnt=0;cnt<total;cnt++){
         if(OrderSelect(cnt,SELECT_BY_POS)){
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber){
               tempfactor=NormalizeDouble(OrderLots()/lots,1+(MarketInfo(Symbol(),MODE_MINLOT)==0.01));
               break;
            }
         }
      }
   }
   int histotal=OrdersHistoryTotal();
   if(tempfactor==0&&histotal>0){
      for(cnt=0;cnt<histotal;cnt++){
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_HISTORY)){
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber){
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
   
   if(breakevengain>0){
      for(int b=0;b<total;b++){
         sel=OrderSelect(b,SELECT_BY_POS,MODE_TRADES);
         if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber){
            if(OrderType()==OP_BUY){
               if(NormalizeDouble((Bid-OrderOpenPrice()),dg)>=NormalizeDouble(breakevengain*pt,dg)){
                  if((NormalizeDouble((OrderStopLoss()-OrderOpenPrice()),dg)<NormalizeDouble(breakeven*pt,dg))||OrderStopLoss()==0){
                     mod=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()+breakeven*pt,dg),OrderTakeProfit(),0,Blue);
                     return(0);
                  }
               }
            }
            else{
               if(NormalizeDouble((OrderOpenPrice()-Ask),dg)>=NormalizeDouble(breakevengain*pt,dg)){
                  if((NormalizeDouble((OrderOpenPrice()-OrderStopLoss()),dg)<NormalizeDouble(breakeven*pt,dg))||OrderStopLoss()==0){
                     mod=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()-breakeven*pt,dg),OrderTakeProfit(),0,Red);
                     return(0);
                  }
               }
            }
         }
      }
   }
   
   if(trailingstop>0){
      for(int a=0;a<total;a++){
         sel=OrderSelect(a,SELECT_BY_POS,MODE_TRADES);
         if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber){
            if(OrderType()==OP_BUY){
               if(NormalizeDouble(Ask,dg)>NormalizeDouble(OrderOpenPrice()+trailingstart*pt,dg)
               && (NormalizeDouble(OrderStopLoss(),dg)<NormalizeDouble(Bid-(trailingstop+TrailingStep)*pt,dg))||(OrderStopLoss()==0)){
                  mod=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-trailingstop*pt,dg),OrderTakeProfit(),0,Blue);
                  return(0);
               }
            }
            else{
               if(NormalizeDouble(Bid,dg)<NormalizeDouble(OrderOpenPrice()-trailingstart*pt,dg)
               && (NormalizeDouble(OrderStopLoss(),dg)>(NormalizeDouble(Ask+(trailingstop+TrailingStep)*pt,dg)))||(OrderStopLoss()==0)){                 
                  mod=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+trailingstop*pt,dg),OrderTakeProfit(),0,Red);
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
            sel=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_BUY){
               clo=OrderClose(OrderTicket(),OrderLots(),Bid,Slippage*mt);
            }
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_SELL){
               clo=OrderClose(OrderTicket(),OrderLots(),Ask,Slippage*mt);
            }
         }
         return(0);
      }
   }

   double fru=iFractals(Symbol(),0,MODE_LOWER,shift+1);
   double frd=iFractals(Symbol(),0,MODE_UPPER,shift+1);
   
   int frsignal=0;
   if(fru>0 && fru!=EMPTY_VALUE && Close[shift]>Close[shift+1] && Close[shift]>Open[shift+1])frsignal=1;
   if(frd>0 && frd!=EMPTY_VALUE && Close[shift]<Close[shift+1] && Close[shift]<Open[shift+1])frsignal=2;
   
   if(lotsoptimized && (martingale==false || (martingale && lastprofit>=0)))lots=NormalizeDouble((AccountBalance()/1000)*minlot*Risk_,lotdigits);
   if(lots<minlot)lots=minlot;if(lots>maxlot)lots=maxlot;
   
   if(tradesperbar==1 && (((TimeCurrent()-lastbuyopentime)<Period()) || ((TimeCurrent()-lastsellopentime)<Period()))){tpb=1;tps=1;}
   
   bool buy=false;bool sell=false;

   if(frsignal==1
   )if(reversesignals)sell=true;else buy=true;
   
   if(frsignal==2
   )if(reversesignals)buy=true;else sell=true;

   if(bc!=Bars){tpb=0;tps=0;bc=Bars;}

   if((oppositeclose && sell)){
      for(i=total-1;i>=0;i--){
         sel=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_BUY){
            clo=OrderClose(OrderTicket(),OrderLots(),Bid,Slippage*mt);
         }
      }
   }
   if((oppositeclose && buy)){
      for(j=total-1;j>=0;j--){
         sel=OrderSelect(j,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_SELL){
            clo=OrderClose(OrderTicket(),OrderLots(),Ask,Slippage*mt);
         }
      }
   }
   
   if(hidestop){
      for(k=total-1;k>=0;k--){
         sel=OrderSelect(k,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_BUY && RealStopLoss>0 && Bid<(OrderOpenPrice()-RealStopLoss*pt)){
            clo=OrderClose(OrderTicket(),OrderLots(),Bid,Slippage*mt);
         }
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_SELL && RealStopLoss>0 && Ask>(OrderOpenPrice()+RealStopLoss*pt)){
            clo=OrderClose(OrderTicket(),OrderLots(),Ask,Slippage*mt);
         }
      }
   }
   if(hidetarget){
      for(l=total-1;l>=0;l--){
         sel=OrderSelect(l,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_BUY && RealTakeProfit>0 && Bid>(OrderOpenPrice()+RealTakeProfit*pt)){
            clo=OrderClose(OrderTicket(),OrderLots(),Bid,Slippage*mt);
         }
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_SELL && RealTakeProfit>0 && Ask<(OrderOpenPrice()-RealTakeProfit*pt)){
           clo=OrderClose(OrderTicket(),OrderLots(),Ask,Slippage*mt);
         }
      }
   }

   istart=start+(gmtshift);if(istart>23)istart=istart-24;
   iend=end+(gmtshift);if(iend>23)iend=iend-24;
   
   if((tradesunday==false && DayOfWeek()==0) || (filter && DayOfWeek()>0 && ((istart<=iend && !(Hour()>=(istart)&&Hour()<=(iend)))
   || (istart>iend && !((Hour()>=(istart)&&Hour()<=23) || (Hour()>=0&&Hour()<=(iend)))))) || (fridayfilter&&DayOfWeek()==5 && !(Hour()<(fridayend+(gmtshift))))){return(0);}
   
   if((Ask-Bid)>maxspread*pt)return(0);
   
   int expire=0;
   if(expiration>0)expire=TimeCurrent()+(expiration*60)-5;
   
   if((count(OP_BUY,MagicNumber)+count(OP_SELL,MagicNumber))<MaxBuyTrades){  
      if(buy && tpb<tradesperbar && IsTradeAllowed()){
         while(IsTradeContextBusy())Sleep(3000);
         if(hidestop==false&&RealStopLoss>0){sl=Ask-RealStopLoss*pt;}else{sl=0;}
         if(hidetarget==false&&RealTakeProfit>0){tp=Ask+RealTakeProfit*pt;}else{tp=0;}
         if(martingale)ilots=NormalizeDouble(lots*martingalefactor(),2);else ilots=lots;
         if(ilots<minlot)ilots=minlot;if(ilots>maxlot)ilots=maxlot;
         RefreshRates();ticket=OrderSend(Symbol(),OP_BUY,ilots,Ask,Slippage*mt,sl,tp,comment+". MagicNumber: "+DoubleToStr(MagicNumber,0),MagicNumber,expire,Blue);
         if(ticket<=0){Print("Error Occured : "+errordescription(GetLastError()));}
         else{tpb++;Print("Order opened : "+Symbol()+" Buy @ "+Ask+" SL @ "+sl+" TP @"+tp+" ticket ="+ticket);}
      }
      if(sell && tps<tradesperbar && IsTradeAllowed()){
         while(IsTradeContextBusy())Sleep(3000);
         if(hidestop==false&&RealStopLoss>0){sl=Bid+RealStopLoss*pt;}else{sl=0;}
         if(hidetarget==false&&RealTakeProfit>0){tp=Bid-RealTakeProfit*pt;}else{tp=0;}
         if(martingale)ilots=NormalizeDouble(lots*martingalefactor(),2);else ilots=lots;
         if(ilots<minlot)ilots=minlot;if(ilots>maxlot)ilots=maxlot;
         RefreshRates();ticket=OrderSend(Symbol(),OP_SELL,ilots,Bid,Slippage*mt,sl,tp,comment+". MagicNumber: "+DoubleToStr(MagicNumber,0),MagicNumber,expire,Red);
         if(ticket<=0){Print("Error Occured : "+errordescription(GetLastError()));}
         else{tps++;Print("Order opened : "+Symbol()+" Sell @ "+Bid+" SL @ "+sl+" TP @"+tp+" ticket ="+ticket);}
      }
   }
   return(0);
}



int count(int type,int MagicNumber){
   int cnt;cnt=0;
   for(int i=0;i<OrdersTotal();i++){
      sel=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderType()==type && ((OrderMagicNumber()==MagicNumber)||MagicNumber==0)){
         cnt++;
      }
   }
   return(cnt);
}


int martingalefactor(){
   int histotal=OrdersHistoryTotal();
   if (histotal>0){
      for(int cnt=histotal-1;cnt>=0;cnt--){
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_HISTORY)){
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber){
               if(OrderProfit()<0){
                  lotsfactor=lotsfactor*multiplier;
                  return(lotsfactor);
               }
               else{
                  lotsfactor=initiallotsfactor;
                  if(lotsfactor<=0){
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

string errordescription(int code){
   string error;
   switch(code){
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