// _advanced expert advisor v9 build 1231.mq4
// Copyright © 2009, TradingSystemForex.Com
// http://www.tradingsystemforex.com/

#property copyright "Copyright © 2009, TradingSystemForex.Com"
#property link "http://www.tradingsystemforex.com/"

extern string comment="EA";              // comment to display in the order
extern int magic=1234;                   // magic number required if you use different settings on a same pair, same timeframe

extern string moneymanagement="Money Management";

extern double lots=0.1;                  // lots size
extern bool mm=false;                    // enable risk management
extern double risk=1;                    // risk in percentage of the account
extern double minlot=0.01;               // minimum lots size
extern double maxlot=50;                 // maximum lots size
extern int lotdigits=2;
//extern bool martingale=false;            // enable the martingale
//extern double multiplier=2.0;            // multiplier used for the martingale
//extern bool basketpercent=false;         // enable the basket percent
//extern double profit=10;                 // close all orders if a profit of 10 percents has been reached
//extern double loss=30;                   // close all orders if a loss of 30 percents has been reached

extern string admoneymanagement="Advanced Money Management";

extern bool dynamiclot=true;
extern double dynamicfactor=1;

extern string ordersmanagement="Order Management";

extern bool ecn=false;                   // make the expert compatible with ecn brokers
extern bool oppositeclose=true;          // close the orders on an opposite signal
extern bool reversesignals=false;        // reverse the signals, long if short, short if long
extern int maxtrades=100;                // maximum trades allowed by the traders
extern int tradesperbar=1;               // maximum trades per bar allowed by the expert
extern bool hidesl=false;                // hide stop loss
extern bool hidetp=false;                // hide take profit
extern double stoploss=0;                // stop loss
extern double takeprofit=0;              // take profit
extern double trailingstart=0;           // profit in pips required to enable the trailing stop
extern double trailingstop=0;            // trailing stop
//extern double trailingprofit=0;          // trailing profit
extern double trailingstep=1;            // margin allowed to the market to enable the trailing stop
extern double breakevengain=0;           // gain in pips required to enable the break even
extern double breakeven=0;               // break even
int expiration=0;                 // expiration in minutes for pending orders
double slippage=0;                // maximum difference in pips between signal and order
extern double maxspread=100;             // maximum spread allowed by the expert

extern string adordermanagement="Advanced Order Management";

extern int closemode=1;                  // 0=standard close, 1=close when global profit is positive on new close, 2=close on pipstarget
extern int pipstarget=20;

extern string entrylogics="Entry Logics";

//extern bool changedirection=false;
extern bool signal1=true;
extern bool signal2=false;
extern bool signal3=false;
extern int macdfast=12;
extern int macdslow=26;
extern int macdsma=9;
extern bool mafilter=false;
extern int maperiod=105;
extern int mamethod=0;
extern int maprice=0;
extern int shift=1;                      // bar in the past to take in consideration for the signal
/*
extern string timeout="Time Outs and Targets Settings";

extern bool usetimeout=true;
extern int timeout1=30;
extern int target1=7;
extern int timeout2=70;
extern int target2=5;
extern int timeout3=95;
extern int target3=4;
extern int timeout4=120;
extern int target4=2;
extern int timeout5=150;
extern int target5=-5;
extern int timeout6=180;
extern int target6=-8;
extern int timeout7=210;
extern int target7=-15;
*/

extern string timefilter="Time Filter";

extern int summergmtshift=2;             // gmt offset of the broker
extern int wintergmtshift=1;             // gmt offset of the broker
extern bool mondayfilter=false;          // enable special time filter on friday
extern int mondayhour=12;                // start to trade after this hour
extern int mondayminute=0;               // minutes of the friday hour
extern bool weekfilter=false;            // enable time filter
extern int starthour=7;                  // start hour to trade after this hour
extern int startminute=0;                // minutes of the start hour
extern int endhour=21;                   // stop to trade after this hour
extern int endminute=0;                  // minutes of the start hour
extern bool tradesunday=true;            // trade on sunday
extern bool fridayfilter=false;          // enable special time filter on friday
extern int fridayhour=12;                // stop to trade after this hour
extern int fridayminute=0;               // minutes of the friday hour

datetime t0,t1,tstart,tend,tfriday,tmonday,lastbuyopentime,lastsellopentime,time;
int i,bc=-1,cnt,tpb,tps,tries=100,lastorder,buyorderprofit,sellorderprofit,lotsize;
int nstarthour,nendhour,nfridayhour,nmondayhour,number,ticket,gmtshift,tradetime;
string istarthour,istartminute,iendhour,iendminute,ifridayhour,ifridayminute,imondayhour,imondayminute;
double cb,sl,tp,ilots,lastbuylot,lastselllot,lastlot,lastprofit,mlots,win[14],sum[14],globalprofit;
double lastbuyopenprice,lastsellopenprice,lastbuyprofit,lastsellprofit,tradeprofit;

bool closebasket=false;

//bool continuebuy=true;
//bool continuesell=true;

double pt,mt;
int dg;

int init(){
   t0=Time[0];
   t1=Time[0];

   sum[2012-1999]=D'2012.03.28 02:00:00';win[2012-1999]=D'2012.10.31 03:00:00';
   sum[2011-1999]=D'2011.03.29 02:00:00';win[2011-1999]=D'2011.10.25 03:00:00';
   sum[2010-1999]=D'2010.03.30 02:00:00';win[2010-1999]=D'2010.10.26 03:00:00';
   sum[2009-1999]=D'2009.03.29 02:00:00';win[2009-1999]=D'2009.10.25 03:00:00';
   sum[2008-1999]=D'2008.03.30 02:00:00';win[2008-1999]=D'2008.10.26 03:00:00';
   sum[2007-1999]=D'2007.03.25 02:00:00';win[2007-1999]=D'2007.10.28 03:00:00';
   sum[2006-1999]=D'2006.03.26 02:00:00';win[2006-1999]=D'2006.10.29 03:00:00';
   sum[2005-1999]=D'2005.03.27 02:00:00';win[2005-1999]=D'2005.10.30 03:00:00';
   sum[2004-1999]=D'2004.03.28 02:00:00';win[2004-1999]=D'2004.10.31 03:00:00';
   sum[2003-1999]=D'2003.03.30 02:00:00';win[2003-1999]=D'2003.10.26 03:00:00';
   sum[2002-1999]=D'2002.03.31 02:00:00';win[2002-1999]=D'2002.10.27 03:00:00';
   sum[2001-1999]=D'2001.03.25 02:00:00';win[2001-1999]=D'2001.10.28 03:00:00';
   sum[2000-1999]=D'2000.03.26 02:00:00';win[2000-1999]=D'2000.10.29 03:00:00';
   sum[1999-1999]=D'1999.03.28 02:00:00';win[1999-1999]=D'1999.10.31 03:00:00';

   dg=Digits;
   if(dg==3 || dg==5){pt=Point*10;mt=10;}else{pt=Point;mt=1;}
   if(minlot>=1){lotsize=100000;}
   if(minlot<1){lotsize=10000;}
   if(minlot<0.1){lotsize=1000;}
   return(0);
}

int start(){
/*
   GlobalVariableSet("vGrafBalance",AccountBalance());
   GlobalVariableSet("vGrafEquity",AccountEquity());
*/

   if(breakevengain>0)movebreakeven(breakevengain,breakeven);
   if(trailingstop>0)movetrailingstop(trailingstart,trailingstop);
   //if(trailingprofit>0)movetrailingprofit(trailingstart,trailingprofit);
/*
   if(basketpercent){
      if(closebasket==false)closebasket=closebasketpercent(profit,loss);
      if(closebasket){closebuy();closesell();delete(OP_BUYSTOP);delete(OP_SELLSTOP);delete(OP_BUYLIMIT);delete(OP_SELLLIMIT);}
      if(closebasket && count(OP_BUY)+count(OP_SELL)+count(OP_BUYLIMIT)+count(OP_SELLLIMIT)+count(OP_BUYSTOP)+count(OP_SELLSTOP)==0)closebasket=false;
   }
*/
   globalprofit=0;
   if(OrdersTotal()>0){
      for(i=0;i<=OrdersTotal();i++){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderCloseTime()==0){
            if(OrderType()==OP_BUY){
               lastbuyopentime=OrderOpenTime();
               //lastbuyopenprice=OrderOpenPrice();
               //buyorderprofit=OrderProfit();
            }
            if(OrderType()==OP_SELL){
               lastsellopentime=OrderOpenTime();
               //lastsellopenprice=OrderOpenPrice();
               //sellorderprofit=OrderProfit();
            }
            globalprofit=globalprofit+OrderProfit()/(OrderLots()*10);
         }
      }
   }
   if(tradesperbar==1){
      if(lastbuyopentime<Time[0])tpb=0;else tpb=1;
      if(lastsellopentime<Time[0])tps=0;else tps=1;
   }
   if(tradesperbar!=1 && bc!=Bars){tpb=0;tps=0;bc=Bars;}

   if(time!=Time[0] || shift==0){
      double macd=iMACD(NULL,0,macdfast,macdslow,macdsma,PRICE_CLOSE,MODE_MAIN,shift);
      double macda=iMACD(NULL,0,macdfast,macdslow,macdsma,PRICE_CLOSE,MODE_MAIN,shift+1);
      double macdb=iMACD(NULL,0,macdfast,macdslow,macdsma,PRICE_CLOSE,MODE_MAIN,shift+2);
      double macdc=iMACD(NULL,0,macdfast,macdslow,macdsma,PRICE_CLOSE,MODE_MAIN,shift+3);
      double macdd=iMACD(NULL,0,macdfast,macdslow,macdsma,PRICE_CLOSE,MODE_MAIN,shift+4);
      double macde=iMACD(NULL,0,macdfast,macdslow,macdsma,PRICE_CLOSE,MODE_MAIN,shift+5);
      
      double ma=iMA(NULL,0,maperiod,0,mamethod,maprice,shift);
      double maa=iMA(NULL,0,maperiod,0,mamethod,maprice,shift+1);
      time=Time[0];
   }
   bool buy=false;
   bool sell=false;

   if(
   (signal1 && macdc<0 && macdb<0 && macda<0 && macd>0)
   || (signal2 && macdd<0 && macdc<0 && macdb<0 && macda>0 && macd>0)
   || (signal3 && macde<0 && macdd<0 && macdc<0 && macdb>0 && macda>0 && macd>0)
   && (mafilter==false || (mafilter && ma>maa))
   //&& (changedirection==false || (changedirection && continuebuy))
   ){
      if(reversesignals)sell=true;else buy=true;
      //continuebuy=false;
      //continuesell=true;
   }
   
   if(
   (signal1 && macdc>0 && macdb>0 && macda>0 && macd<0)
   || (signal2 && macdd>0 && macdc>0 && macdb>0 && macda<0 && macd<0)
   || (signal3 && macde>0 && macdd>0 && macdc>0 && macdb<0 && macda<0 && macd<0)
   && (mafilter==false || (mafilter && ma<maa))
   //&& (changedirection==false || (changedirection && continuesell))
   ){
      if(reversesignals)buy=true;else sell=true;
      //continuebuy=true;
      //continuesell=false;
   }

   //Comment("\nhau = "+DoubleToStr(hau,5),"\nhad = "+DoubleToStr(had,5));

   if((oppositeclose && sell && closemode==0))closebuy();
   if((oppositeclose && buy && closemode==0))closesell();
   
   if(closemode==1 && sell || buy && (count(OP_BUY)+count(OP_SELL))>1 && globalprofit>0){closebuy();closesell();}
   if(closemode==2 && (count(OP_BUY)+count(OP_SELL))>1 && globalprofit>pipstarget){closebuy();closesell();}

   if(hidetp || hidesl){hideclosesell();hideclosebuy();}
   
   //if(usetimeout){closebuytime();closeselltime();}
   
/*
   lastbuylot=0;
   lastselllot=0;
   lastorder=0;

   if(OrdersHistoryTotal()>0){
      for(i=0;i<=OrdersHistoryTotal();i++){
         OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic){
            lastprofit=OrderProfit();
            lastlot=OrderLots();
            if(OrderType()==OP_BUY){
               lastbuyprofit=OrderProfit();
               lastbuylot=OrderLots();
               lastorder=1;
            }
            if(OrderType()==OP_SELL){
               lastsellprofit=OrderProfit();
               lastselllot=OrderLots();
               lastorder=2;
            }
         }
      }
   }
   mlots=0;
   if(martingale && lastprofit<0)mlots=lastlot*multiplier;else mlots=lots;
*/

   if((Ask-Bid)>maxspread*mt*pt)return(0);
   if((count(OP_BUY)+count(OP_SELL))>=maxtrades)return(0);

   if(mm /*&& (martingale==false || (martingale && lastprofit>=0))*/)lots=lotsoptimized();

   int expire=0;
   if(expiration>0)expire=TimeCurrent()+(expiration*60)-5;

   ticket=0;
   number=0;
   if(buy && tpb<tradesperbar){
      /*if(martingale)ilots=mlots;else*/ ilots=lots;
      if(dynamiclot)ilots=lots*dynamicfactor*(count(OP_BUY)+count(OP_SELL)+1);
      if(ecn==false){
         while(ticket<=0 && number<tries && checktime()){
            while(!IsTradeAllowed())Sleep(5000);
            RefreshRates();
            ticket=open(OP_BUY,ilots,Ask,stoploss,takeprofit,expire,Blue);
            if(ticket<0){
               //Print("Error opening BUY order! ",errordescription(GetLastError()));
               number++;
            }
         }
      }
      if(ecn){
         while(ticket<=0 && number<tries && checktime()){
            while(!IsTradeAllowed())Sleep(5000);
            RefreshRates();
            ticket=open(OP_BUY,ilots,Ask,0,0,expire,Blue);
            if(ticket<0){
               //Print("Error opening BUY order! ",errordescription(GetLastError()));
               number++;
            }
         }
         createlstoploss(stoploss);
         createltakeprofit(takeprofit);
      }
      if(ticket<=0){/*Print("Error Occured : "+errordescription(GetLastError()));*/}else tpb++;
   }
   ticket=0;
   if(sell && tps<tradesperbar){
      /*if(martingale)ilots=mlots;else*/ ilots=lots;
      if(dynamiclot)ilots=lots*dynamicfactor*(count(OP_BUY)+count(OP_SELL)+1);
      if(ecn==false){
         while(ticket<=0 && number<tries && checktime()){
            while(!IsTradeAllowed())Sleep(5000);
            RefreshRates();
            ticket=open(OP_SELL,ilots,Bid,stoploss,takeprofit,expire,Red);
            if(ticket<0){
               //Print("Error opening BUY order! ",errordescription(GetLastError()));
               number++;
            }
         }
      }
      if(ecn){
         while(ticket<=0 && number<tries && checktime()){
            while(!IsTradeAllowed())Sleep(5000);
            RefreshRates();
            ticket=open(OP_SELL,ilots,Bid,0,0,expire,Red);
            if(ticket<0){
               //Print("Error opening BUY order! ",errordescription(GetLastError()));
               number++;
            }
         }
         createsstoploss(stoploss);
         createstakeprofit(takeprofit);
      }
      if(ticket<=0){/*Print("Error Occured : "+errordescription(GetLastError()));*/}else tps++;
   }
   if(ecn){
      createlstoploss(stoploss);
      createltakeprofit(takeprofit);
      createsstoploss(stoploss);
      createstakeprofit(takeprofit);
   }
   return(0);
}

//|---------open

int open(int type,double lots,double price,double stoploss,double takeprofit,int expire,color clr){
   int ticket=0;
   if(lots<minlot)lots=minlot;
   if(lots>maxlot)lots=maxlot;
   if(type==OP_BUY || type==OP_BUYSTOP || type==OP_BUYLIMIT){
      if(hidesl==false && stoploss>0){sl=price-stoploss*pt;}else{sl=0;}
      if(hidetp==false && takeprofit>0){tp=price+takeprofit*pt;}else{tp=0;}
   }
   if(type==OP_SELL || type==OP_SELLSTOP || type==OP_SELLLIMIT){
      if(hidesl==false && stoploss>0){sl=price+stoploss*pt;}else{sl=0;}
      if(hidetp==false && takeprofit>0){tp=price-takeprofit*pt;}else{tp=0;}
   }
   ticket=OrderSend(Symbol(),type,NormalizeDouble(lots,lotdigits),NormalizeDouble(price,dg),slippage*mt,sl,tp,comment+". Magic: "+DoubleToStr(magic,0),magic,expire,clr);
   return(ticket);
}

//|---------lots optimized

double lotsoptimized(){
   double lot;
   if(stoploss>0)lot=AccountBalance()*(risk/100)/(stoploss*pt/MarketInfo(Symbol(),MODE_TICKSIZE)*MarketInfo(Symbol(),MODE_TICKVALUE));
   else lot=NormalizeDouble((AccountBalance()/lotsize)*minlot*risk,lotdigits);
   //lot=AccountFreeMargin()/(100.0*(NormalizeDouble(MarketInfo(Symbol(),MODE_MARGINREQUIRED),4)+5.0)/risk)-0.05;
   return(lot);
}

//|---------time filter

int checktime(){
   if(TimeCurrent()<win[TimeYear(TimeCurrent())-1999] && TimeCurrent()>sum[TimeYear(TimeCurrent())-1999])gmtshift=summergmtshift;
   else gmtshift=wintergmtshift;
   
   string time="";
   string svrdate = Year()+"."+Month()+"."+Day();

   if(mondayfilter){
      nmondayhour=mondayhour+(gmtshift);if(nmondayhour>23)nmondayhour=nmondayhour-24;
      if(nmondayhour<10)imondayhour="0"+nmondayhour;
      if(nmondayhour>9)imondayhour=nmondayhour;
      if(mondayminute<10)imondayminute="0"+mondayminute;
      if(mondayminute>9)imondayminute=mondayminute;
      tmonday=StrToTime(svrdate+" "+imondayhour+":"+imondayminute);
   }
   if(weekfilter){
      nstarthour=starthour+(gmtshift);if(nstarthour>23)nstarthour=nstarthour-24;
      if(nstarthour<10)istarthour="0"+nstarthour;
      if(nstarthour>9)istarthour=nstarthour;
      if(startminute<10)istartminute="0"+startminute;
      if(startminute>9)istartminute=startminute;
      tstart=StrToTime(svrdate+" "+istarthour+":"+istartminute);

      nendhour=endhour+(gmtshift);if(nendhour>23)nendhour=nendhour-24;
      if(endhour<10)iendhour="0"+nendhour;
      if(endhour>9)iendhour=nendhour;
      if(endminute<10)iendminute="0"+endminute;
      if(endminute>9)iendminute=endminute;
      tend=StrToTime(svrdate+" "+iendhour+":"+iendminute);
   }
   if(fridayfilter){
      nfridayhour=fridayhour+(gmtshift);if(nfridayhour>23)nfridayhour=nfridayhour-24;
      if(nfridayhour<10)ifridayhour="0"+nfridayhour;
      if(nfridayhour>9)ifridayhour=nfridayhour;
      if(fridayminute<10)ifridayminute="0"+fridayminute;
      if(fridayminute>9)ifridayminute=fridayminute;
      tfriday=StrToTime(svrdate+" "+ifridayhour+":"+ifridayminute);
   }
   //if(nstarthour>nendhour && TimeCurrent()<tstart && TimeCurrent()>tend)time="DONT TRADE";else time="TRADE";
   //Comment("\nCurrentTime = "+TimeCurrent(),"\ntstart = "+tstart,"\ntend = "+tend,"\nTimeFilter = "+time);
   if((weekfilter && (nstarthour<=nendhour && TimeCurrent()<tstart || TimeCurrent()>tend) || (nstarthour>nendhour && TimeCurrent()<tstart && TimeCurrent()>tend))
   || (tradesunday==false && DayOfWeek()==0) || (fridayfilter && DayOfWeek()==5 && TimeCurrent()>tfriday) || (mondayfilter && DayOfWeek()==1 && TimeCurrent()<tmonday))return(0);
   return(1);
}

//|---------counter

int count(int type){
   cnt=0;
   if(OrdersTotal()>0){
      for(i=OrdersTotal();i>=0;i--){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderType()==type && OrderMagicNumber()==magic)cnt++;
      }
      return(cnt);
   }
}

//|---------close

void closebuy(){
   RefreshRates();
   if(OrdersTotal()>0){
      for(i=OrdersTotal();i>=0;i--){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_BUY){
            OrderClose(OrderTicket(),OrderLots(),Bid,slippage*mt);
         }
      }
   }
}

void closesell(){
   RefreshRates();
   if(OrdersTotal()>0){
      for(i=OrdersTotal();i>=0;i--){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_SELL){
            OrderClose(OrderTicket(),OrderLots(),Ask,slippage*mt);
         }
      }
   }
}

void hideclosebuy(){
   RefreshRates();
   if(OrdersTotal()>0){
      for(i=OrdersTotal();i>=0;i--){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_BUY
         && (hidesl && stoploss>0 && OrderProfit()<=(-1)*stoploss*OrderLots()*10-MarketInfo(Symbol(),MODE_SPREAD)*OrderLots()*10/mt)
         || (hidetp && takeprofit>0 && OrderProfit()>=takeprofit*OrderLots()*10)){
            OrderClose(OrderTicket(),OrderLots(),Bid,slippage*mt);
         }
      }
   }
}

void hideclosesell(){
   RefreshRates();
   if(OrdersTotal()>0){
      for(i=OrdersTotal();i>=0;i--){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_SELL
         && (hidesl && stoploss>0 && OrderProfit()<=(-1)*stoploss*OrderLots()*10-MarketInfo(Symbol(),MODE_SPREAD)*OrderLots()*10/mt)
         || (hidetp && takeprofit>0 && OrderProfit()>=takeprofit*OrderLots()*10)){
            OrderClose(OrderTicket(),OrderLots(),Ask,slippage*mt);
         }
      }
   }
}

/*
void closebuytime(){
   tradeprofit=0;
   tradetime=0;
   RefreshRates();
   if(OrdersTotal()>0){
      for(i=OrdersTotal();i>=0;i--){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_BUY){ 
            tradeprofit=NormalizeDouble(OrderClosePrice()-OrderOpenPrice(),dg);
            tradetime=TimeCurrent()-OrderOpenTime();
            if((tradeprofit>=target1*pt &&  tradetime>timeout1*60 && tradetime<timeout2*60) || (tradeprofit>=target2*pt &&  tradetime>timeout2*60 && tradetime<timeout3*60)
            || (tradeprofit>=target3*pt &&  tradetime>timeout3*60 && tradetime<timeout4*60) || (tradeprofit>=target4*pt &&  tradetime>timeout4*60 && tradetime<timeout5*60)
            || (tradeprofit>=target5*pt &&  tradetime>timeout5*60 && tradetime<timeout6*60) || (tradeprofit>=target6*pt &&  tradetime>timeout6*60 && tradetime<timeout7*60)
            || (tradeprofit>=target7*pt &&  tradetime>timeout7*60)){
               OrderClose(OrderTicket(),OrderLots(),Bid,slippage*mt);
            }
         }
      }
   }
}

void closeselltime(){
   tradeprofit=0;
   tradetime=0;
   RefreshRates();
   if(OrdersTotal()>0){
      for(i=OrdersTotal();i>=0;i--){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_SELL){ 
            tradeprofit=NormalizeDouble(OrderClosePrice()-OrderOpenPrice(),dg);
            tradetime=TimeCurrent()-OrderOpenTime();
            if((tradeprofit>=target1*pt &&  tradetime>timeout1*60 && tradetime<timeout2*60) || (tradeprofit>=target2*pt &&  tradetime>timeout2*60 && tradetime<timeout3*60)
            || (tradeprofit>=target3*pt &&  tradetime>timeout3*60 && tradetime<timeout4*60) || (tradeprofit>=target4*pt &&  tradetime>timeout4*60 && tradetime<timeout5*60)
            || (tradeprofit>=target5*pt &&  tradetime>timeout5*60 && tradetime<timeout6*60) || (tradeprofit>=target6*pt &&  tradetime>timeout6*60 && tradetime<timeout7*60)
            || (tradeprofit>=target7*pt &&  tradetime>timeout7*60)){
               OrderClose(OrderTicket(),OrderLots(),Ask,slippage*mt);
            }
         }
      }
   }
}*/

//|---------breakeven

void movebreakeven(double breakevengain,double breakeven){
   RefreshRates();
   if(OrdersTotal()>0){
      for(i=OrdersTotal();i>=0;i--){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==magic){
            if(OrderType()==OP_BUY){
               if(NormalizeDouble((Bid-OrderOpenPrice()),dg)>=NormalizeDouble(breakevengain*pt,dg)){
                  if((NormalizeDouble((OrderStopLoss()-OrderOpenPrice()),dg)<NormalizeDouble(breakeven*pt,dg)) || OrderStopLoss()==0){
                     OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()+breakeven*pt,dg),OrderTakeProfit(),0,Blue);
                     return(0);
                  }
               }
            }
            else{
               if(NormalizeDouble((OrderOpenPrice()-Ask),dg)>=NormalizeDouble(breakevengain*pt,dg)){
                  if((NormalizeDouble((OrderOpenPrice()-OrderStopLoss()),dg)<NormalizeDouble(breakeven*pt,dg)) || OrderStopLoss()==0){
                     OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()-breakeven*pt,dg),OrderTakeProfit(),0,Red);
                     return(0);
                  }
               }
            }
         }
      }
   }
}

//|---------trailingstop

void movetrailingstop(double trailingstart,double trailingstop){
   RefreshRates();
   if(OrdersTotal()>0){
      for(i=OrdersTotal();i>=0;i--){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==magic){
            if(OrderType()==OP_BUY){
               if(NormalizeDouble(Ask,dg)>NormalizeDouble(OrderOpenPrice()+trailingstart*pt,dg)
               && NormalizeDouble(OrderStopLoss(),dg)<NormalizeDouble(Bid-(trailingstop+trailingstep)*pt,dg)){
                  OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-trailingstop*pt,dg),OrderTakeProfit(),0,Blue);
                  return(0);
               }
            }
            else{
               if(NormalizeDouble(Bid,dg)<NormalizeDouble(OrderOpenPrice()-trailingstart*pt,dg)
               && (NormalizeDouble(OrderStopLoss(),dg)>(NormalizeDouble(Ask+(trailingstop+trailingstep)*pt,dg))) || (OrderStopLoss()==0)){                 
                  OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+trailingstop*pt,dg),OrderTakeProfit(),0,Red);
                  return(0);
               }
            }
         }
      }
   }
}
/*
//|---------trailingprofit

void movetrailingprofit(double trailingstart,double trailingprofit){
   RefreshRates();
   for(i=OrdersTotal();i>=0;i--){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if(OrderSymbol()==Symbol()&& OrderMagicNumber()==magic){
            if(OrderType()==OP_BUY){
               if(NormalizeDouble(Bid-OrderOpenPrice(),dg)<=NormalizeDouble((-1)*trailingstart*pt,dg)){
                  if(NormalizeDouble(OrderTakeProfit(),dg)>NormalizeDouble(Bid+(trailingprofit+trailingstep)*pt,dg) || NormalizeDouble(OrderTakeProfit(),dg)==0){
                     OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NormalizeDouble(Bid+trailingprofit*pt,dg),0,Blue);
                  }
               }
            }
            if(OrderType()==OP_SELL){
               if(NormalizeDouble(OrderOpenPrice()-Ask,dg)<=NormalizeDouble((-1)*trailingstart*pt,dg)){
                  if(NormalizeDouble(OrderTakeProfit(),dg)<NormalizeDouble(Ask-(trailingprofit+trailingstep)*pt,dg)){
                     OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NormalizeDouble(Ask-trailingprofit*pt,dg),0,Red);
                  }
               }
            }
         }
      }
   }
}
*/
void createlstoploss(double stoploss){
   RefreshRates();
   for(i=OrdersTotal();i>=0;i--){
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==magic){
         if(OrderType()==OP_BUY){
            if(OrderStopLoss()==0){                 
               OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask-stoploss*pt,dg),OrderTakeProfit(),0,Red);
               return(0);
            }
         }
      }
   }
}

void createsstoploss(double stoploss){
   RefreshRates();
   for(i=OrdersTotal();i>=0;i--){
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==magic){
         if(OrderType()==OP_SELL){
            if(OrderStopLoss()==0){                 
               OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid+stoploss*pt,dg),OrderTakeProfit(),0,Red);
               return(0);
            }
         }
      }
   }
}

void createltakeprofit(double takeprofit){
   RefreshRates();
   for(i=OrdersTotal();i>=0;i--){
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==magic){
         if(OrderType()==OP_BUY){
            if(OrderTakeProfit()==0){                 
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NormalizeDouble(Ask+takeprofit*pt,dg),0,Red);
               return(0);
            }
         }
      }
   }
}

void createstakeprofit(double takeprofit){
   RefreshRates();
   int total=OrdersTotal();
   for(i=OrdersTotal();i>=0;i--){
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==magic){
         if(OrderType()==OP_SELL){
            if(OrderTakeProfit()==0){                 
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NormalizeDouble(Bid-takeprofit*pt,dg),0,Red);
               return(0);
            }
         }
      }
   }
}
/*
//|---------basket

bool closebasketpercent(double profit,double loss){
   double ipf,ilo;
   ipf=profit*(0.01*AccountBalance());
   ilo=loss*(0.01*AccountBalance());
   cb=AccountEquity()-AccountBalance();
   if(cb>=ipf || cb<=(ilo*(-1)))return(1);
   return(0);
}

//|---------delete

void delete(int type){
   if(OrdersTotal()>0){
      for(i=OrdersTotal();i>=0;i--){
        OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
        if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==type){
          OrderDelete(OrderTicket());
        }   
      }
   }
}*/
/*
//|---------error

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
*/