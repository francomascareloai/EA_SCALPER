//+------------------------------------------------------------------+
//|                                        Quantum London Trading EA |
//|                                      Copyright 2012, CompanyName |
//|              http://www.forexfactory.com/showthread.php?t=552185 |
//+------------------------------------------------------------------+ 
#import "user32.dll"
int MessageBoxA(int Ignore,string Caption,string Title,int Icon);
#import
#property strict
#property link "http://www.forexfactory.com/showthread.php?t=551382"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum enum_QT
  {
   Quantum=1,
   QuantumStochasticOB_OS=2,
  };

input int mn=2015; //Magic Number
input string comm="Quantum London Trading EA";//Order Comment
input enum_QT QT=1;//Quantum Indicator
input string q="-----------";//If using QuantumStochasticOB_OS -
input int K = 5;
input int D = 3;
input int S = 3;
input int OS = 20;
input int OB = 80;
input string o="-----------";//-----------
input int ema=0;// Daily EMA Filter Period
input bool had=false;//Weekly Heiken Ashi Filter
input bool fulltime=true; //Trade 24/5
input bool manual=false;//Manually Close Trades
input double mm=0;//Money Management (multiply lots every $ x)
input string a="-----------"; //If Trade 24/5 = false then:
input string open1="07:00"; // Trading Window Start Time 1 (Broker)
input string close1="13:00"; // Trading Window End Time 1 (Broker)
input int max1=0;//Max Trades per Trading Slot 1
input int cyc1=0;//Max Cycles per Trading Slot 1
input string open2="07:00"; // Trading Window Start Time 2 (Broker)
input string close2="13:00"; // Trading Window End Time 2 (Broker)
input int max2=0;//Max Trades per Trading Slot 2
input int cyc2=0;//Max Cycles per Trading Slot 2
input string open3="07:00"; // Trading Window Start Time 3 (Broker)
input string close3="13:00"; // Trading Window End Time 3 (Broker)
input int max3=0;//Max Trades per Trading Slot 3
input int cyc3=0;//Max Cycles per Trading Slot 3
input bool closeend=false;//Close all trades at End Time
input int wait=0;//Wait X boxes before opening trades
input bool onlylowerhigher=false;//Only open higher (sells) or lower (buys) than previous order
input int xdist=0;//Minimum distance between entries
input int numcycles=0;//Number of Daily Cycles to run
input bool stop=false;//Stop after each cycle
input int tf=1;//Time Frame (minutes)
input bool fifo=false;//Use FIFO Rule
input bool mon=true;//Trade on Monday
input bool tue=true;//Trade on Tuesday
input bool wed=true;//Trade on Wednesday
input bool thurs=true;//Trade on Thursday
input bool fri=true;//Trade on Friday
input int xcandles=0;//Only trade every X candles
input int qde=325;//Quantum eintDepth3 for Entry
input int qdc=325;//Quantum eintDepth3 for Close
input bool reverse=false;//Reverse Trading (Buy on Red, Sell on Blue)
input string l="-----------"; // Set up lots and/or grid for trades
input double T1=0.01; //Trades 1-12
input double T2=0.02; //Trades 13-21
input double T3=0.05; //Trades 22-29
input double T4=0.13; //Trades 30-36
input double T5=0.34; //Trades 37-39
input double T6=0.89; //Trade 40 & >
input bool grid=false;//Use Grid
input bool drawgrid=false;//Draw Grid Lines
input int grid1size=0; //Grid 1 Size (Eg. 100)
input int grid1inc=0; //Grid 1 Increment (Space between entries)
input int grid1maxtrades=0; //Max Trades For Grid 1
input double grid1lots=0; //Grid 1 Lots
input int grid2size=0; //Grid 2 Size (Eg. 100)
input int grid2inc=0; //Grid 2 Increment (Space between entries)
input int grid2maxtrades=0; //Max Trades For Grid 2
input double grid2lots=0; //Grid 2 Lots
input int grid3size=0; //Grid 3 Size (Eg. 100)
input int grid3inc=0; //Grid 3 Increment (Space between entries)
input int grid3maxtrades=0; //Max Trades For Grid 3
input double grid3lots=0; //Grid 3 Lots
input bool ber=false;//Use Break Even Recovery
input double percbedd=0;//% Equity Draw Down to Activate Break Even Recovery
bool beractive=false;
input int pointstp=0;//Points Take Profit (Eg. 100)
input double dollartp=0;//$ Take Profit (Eg. 100)
input double percequitytp=0;//% Equity Take Profit (Eg. 10)
input int pointssl=0;//Points Stop Loss (Eg. -100)
input double dollarsl=0;//$ Stop Loss (Eg. -50)
input double percequitysl=0;//% Equity Stop Loss (Eg. -10)
input double indivtp=0;//Individual Trade TP
input double indivsl=0;//Individual Trade SL
input int closex=0;//Close after X trades
input bool debug=false;//Debug Mode

double lots,prevorderprice;
datetime curtime,prevtime,curday,prevday;
bool donefortheday,buys,buyclosed,sellclosed;
double initialstartbuy,initialstartsell;
double digits;
int openorders,mt1,mt2,mt3,thewait,cycles,c1,c2,c3;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   DeleteLines();
   if(stop==true)
      CreateButton();
   if(manual==true)
      CreateManualButton();
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   DeleteLines();
   ObjectDelete(0,"start");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   digits=1;
//if(Digits==5 || Digits==3)
//  {
//   digits=1;
//  }

   if(debug)
     {
      if(IsTradeAllowed()==false)
         Alert("Broker does not allow EA to trade");
     }

   curday=iTime(Symbol(),PERIOD_D1,0);

   if(curday>prevday)// && 
      //iTime(Symbol(),PERIOD_D1,0)>GlobalVariableGet(Symbol()+"DailyOpenTime"))
     {
      //GlobalVariableSet(Symbol()+"DailyOpenTime",iTime(Symbol(),PERIOD_D1,0));
      //GlobalVariableSet(Symbol()+"DailyCycles",0);
      cycles=0;
      prevday=iTime(Symbol(),PERIOD_D1,0);
     }

   CheckCloseTrades();

   if(grid==true &&
      (grid1size==0 || grid2size==0 || grid3size==0))
     {
      Alert("Please set ALL grid sizes");
      return(0);
     }

   openorders=0;
   for(int j=OrdersTotal()-1;j>=0;j--)
     {
      if(!OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn)
        {
         openorders+=1;
        }
     }

   double g1s=grid1size*Point*digits;
   double g2s=grid2size*Point*digits;
   double g3s=grid3size*Point*digits;

//Open trades after Trading Window Start Time and before Trading Window End Time
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn)
        {
         prevorderprice=OrderOpenPrice();
         break;
        }
     }

   bool buttonstarted=ObjectGetInteger(0,"start",OBJPROP_STATE);

   if(QT==1)
     {
      if(iCustom(Symbol(),tf,"Quantum",qde,0,1)>0 && buys==false)
        {
         buys=true;
         thewait=0;
        }
      if(iCustom(Symbol(),tf,"Quantum",qde,1,1)>0 && buys==true)
        {
         buys=false;
         thewait=0;
        }
     }
   if(QT==2)
     {
      if(iCustom(Symbol(),tf,"Quantum - Stochastic OB_OS",qde,K,D,S,OS,OB,0,1)>0 && buys==false)
        {
         buys=true;
         thewait=0;
        }
      if(iCustom(Symbol(),tf,"Quantum - Stochastic OB_OS",qde,K,D,S,OS,OB,1,1)>0 && buys==true)
        {
         buys=false;
         thewait=0;
        }
     }

//check cycles per trading slot 
   bool gocycle=true;
   if(fulltime==false)
     {
      if(iTime(Symbol(),1,0)>=open1 && iTime(Symbol(),1,0)<close1 && c1>=cyc1 && cyc1>0)
         gocycle=false;
      if(iTime(Symbol(),1,0)>=open2 && iTime(Symbol(),1,0)<close2 && c2>=cyc2 && cyc2>0)
         gocycle=false;
      if(iTime(Symbol(),1,0)>=open3 && iTime(Symbol(),1,0)<close3 && c3>=cyc3 && cyc3>0)
         gocycle=false;
     }

   curtime=iTime(Symbol(),tf,0);
   if((stop==true && buttonstarted==true && openorders<=0) || stop==false || openorders>0)
     {
      if((cycles<numcycles && numcycles>0) || numcycles<=0)
        {
         if(gocycle)
           {
            if(((iTime(Symbol(),1,0)>=StrToTime(open1) && iTime(Symbol(),1,0)<StrToTime(close1)) || (iTime(Symbol(),1,0)>=StrToTime(open2) && iTime(Symbol(),1,0)<StrToTime(close2)) || (iTime(Symbol(),1,0)>=StrToTime(open3) && iTime(Symbol(),1,0)<StrToTime(close3)) || (fulltime==true)) && curtime>prevtime)
              {
               bool cantrade=true;
               int grid1trades,grid2trades,grid3trades;

               if(((iCustom(Symbol(),tf,"Quantum",qde,0,1)>0 && reverse==false && QT==1) || (iCustom(Symbol(),tf,"Quantum - Stochastic OB_OS",qde,K,D,S,OS,OB,0,1)>0 && reverse==false && QT==2) || (iCustom(Symbol(),tf,"Quantum",qde,1,1)>0 && reverse && QT==1) || (iCustom(Symbol(),tf,"Quantum - Stochastic OB_OS",qde,K,D,S,OS,OB,1,1)>0 && reverse && QT==2)) && buyclosed==false)
                 {
                  if((Bid>iMA(Symbol(),PERIOD_D1,ema,0,MODE_EMA,PRICE_CLOSE,1) && ema>0) || ema<=0)
                    {
                     sellclosed=false;
                     if(wait>0 && thewait<wait)
                       {
                        thewait+=1;
                        //Alert("Waiting...",thewait);
                       }
                     else
                       {
                        if(debug)
                           Alert("Quantum Buy Signal detected --- checking other conditions...");
                        //Alert(prevorderprice);
                        if(grid==true && OrdersTotal()>0)
                          {
                           for(int j=OrdersTotal()-1;j>=0;j--)
                             {
                              if(!OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
                                 continue;
                              if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn)
                                {
                                 if(OrderOpenPrice()>initialstartbuy-g1s)
                                   {
                                    grid1trades+=1;
                                   }
                                 if(OrderOpenPrice()<=initialstartbuy-g1s && OrderOpenPrice()>initialstartbuy-g1s-g2s)
                                   {
                                    grid2trades+=1;
                                   }
                                 if(OrderOpenPrice()<=initialstartbuy-g1s-g2s && OrderOpenPrice()>initialstartbuy-g1s-g2s-g3s)
                                   {
                                    grid3trades+=1;
                                   }
                                }
                             }
                          }
                        if((grid==true) && Ask>initialstartbuy-g1s && ((grid1trades>=grid1maxtrades && grid1maxtrades>0) || (prevorderprice>0 && prevorderprice-(grid1inc*Point*digits)<=Ask)))
                           cantrade=false;
                        if((grid==true) && Ask<=initialstartbuy-g1s && Ask>initialstartbuy-g1s-g2s && ((grid2trades>=grid2maxtrades && grid2maxtrades>0) || (prevorderprice-(grid2inc*Point*digits)<=Ask)))
                           cantrade=false;
                        if((grid==true) && Ask<=initialstartbuy-g1s-g2s && Ask>initialstartbuy-g1s-g2s-g3s && ((grid3trades>=grid3maxtrades && grid3maxtrades>0) || (prevorderprice-(grid2inc*Point*digits)<=Ask)))
                           cantrade=false;

                        if(debug && cantrade==false)
                           Alert("Trade Cancelled because of Grid Conditions");

                        if(mon==false && DayOfWeek()==1)
                           cantrade=false;
                        if(tue==false && DayOfWeek()==2)
                           cantrade=false;
                        if(wed==false && DayOfWeek()==3)
                           cantrade=false;
                        if(thurs==false && DayOfWeek()==4)
                           cantrade=false;
                        if(fri==false && DayOfWeek()==5)
                           cantrade=false;

                        if(prevorderprice-(xdist*Point)<=Ask && xdist>0 && prevorderprice>0)
                           cantrade=false;

                        if(debug && cantrade==false)
                           Alert("Trade Cancelled because of week Conditions");

                        //Heiken Ashi Filter
                        if(iCustom(Symbol(),PERIOD_W1,"Heiken Ashi",Red,White,Red,White,2,0)>iCustom(Symbol(),0,"Heiken Ashi",Red,White,Red,White,3,0) && had)
                           cantrade=false;

                        if(xcandles>0)
                          {
                           int lastorderbar;
                           for(int i=OrdersTotal()-1;i>=0;i--)
                             {
                              if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
                                 continue;
                              if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn)
                                {
                                 lastorderbar=iBarShift(Symbol(),tf,OrderOpenTime(),false);
                                 break;
                                }
                             }

                           if(lastorderbar<xcandles && lastorderbar>0)
                             {
                              cantrade=false;
                              if(debug)
                                 Alert("Trade Cancelled because of X Candles Conditions");
                             }
                          }

                        mt1 = 0;
                        mt2 = 0;
                        mt3 = 0;
                        for(int t=OrdersHistoryTotal()-1;t>=0;t--)
                          {
                           if(!OrderSelect(t,SELECT_BY_POS,MODE_HISTORY))
                              continue;
                           if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn && OrderOpenTime()>=iTime(Symbol(),PERIOD_D1,0))
                             {
                              if(OrderOpenTime()>=StrToTime(open1) && OrderOpenTime()<StrToTime(close1))
                                 mt1+=1;
                              if(OrderOpenTime()>=StrToTime(open2) && OrderOpenTime()<StrToTime(close2))
                                 mt2+=1;
                              if(OrderOpenTime()>=StrToTime(open3) && OrderOpenTime()<StrToTime(close3))
                                 mt3+=1;
                             }
                          }
                        for(int r=OrdersTotal()-1;r>=0;r--)
                          {
                           if(!OrderSelect(r,SELECT_BY_POS,MODE_TRADES))
                              continue;
                           if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn && OrderOpenTime()>=iTime(Symbol(),PERIOD_D1,0))
                             {
                              if(OrderOpenTime()>=StrToTime(open1) && OrderOpenTime()<StrToTime(close1))
                                 mt1+=1;
                              if(OrderOpenTime()>=StrToTime(open2) && OrderOpenTime()<StrToTime(close2))
                                 mt2+=1;
                              if(OrderOpenTime()>=StrToTime(open3) && OrderOpenTime()<StrToTime(close3))
                                 mt3+=1;
                             }
                          }

                        if((iTime(Symbol(),1,0)>=StrToTime(open1) && iTime(Symbol(),1,0)<StrToTime(close1)) && mt1>=max1 && max1>0)
                           cantrade=false;
                        if((iTime(Symbol(),1,0)>=StrToTime(open2) && iTime(Symbol(),1,0)<StrToTime(close2)) && mt2>=max2 && max2>0)
                           cantrade=false;
                        if((iTime(Symbol(),1,0)>=StrToTime(open3) && iTime(Symbol(),1,0)<StrToTime(close3)) && mt3>=max3 && max3>0)
                           cantrade=false;

                        if(debug && cantrade==false)
                           Alert("Trade Cancelled due to time window factors");

                        if(Ask>prevorderprice && onlylowerhigher)
                           cantrade=false;

                        if(cantrade==true)
                          {
                           lots=GetLots(Ask,"Buy");
                           if(stop==true)
                             {
                              ObjectSetInteger(0,"start",OBJPROP_STATE,false);
                             }
                           if(lots>0)
                             {
                              int ticket;
                              RefreshRates();
                              if(indivsl>0 || indivtp>0)
                                {
                                 double newsl=0;
                                 double newtp=0;
                                 if(indivsl>0)
                                    newsl=NormalizeDouble(Ask-(indivsl*Point),Digits);
                                 if(indivtp>0)
                                    newtp=NormalizeDouble(Ask+(indivtp*Point),Digits);
                                 ticket=OrderSend(Symbol(),OP_BUY,lots,Ask,5,newsl,newtp,comm,mn,0,0);
                                }
                              else
                                {
                                 ticket=OrderSend(Symbol(),OP_BUY,lots,Ask,5,0,0,comm,mn,0,0);
                                }
                              if(ticket<=-1)
                                {
                                 RefreshRates();
                                 if(indivsl>0 || indivtp>0)
                                   {
                                    double newsl=0;
                                    double newtp=0;
                                    if(indivsl>0)
                                       newsl=NormalizeDouble(Ask-(indivsl*Point),Digits);
                                    if(indivtp>0)
                                       newtp=NormalizeDouble(Ask+(indivtp*Point),Digits);
                                    ticket=OrderSend(Symbol(),OP_BUY,lots,Ask,5,newsl,newtp,comm,mn,0,0);
                                   }
                                 else
                                   {
                                    ticket=OrderSend(Symbol(),OP_BUY,lots,Ask,5,0,0,comm,mn,0,0);
                                   }

                                }
                              if(ticket<=-1)
                                 Alert("OrderSend Error: ",GetLastError());
                              //if(ticket>-1 && (indivsl>0 || indivtp>0))
                              //  {
                              //   OrderSelect(ticket,SELECT_BY_POS,MODE_TRADES);
                              //   if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-(50*Point),OrderTakeProfit(),0,clrAliceBlue))
                              //      Alert("OrderModify Error: ",GetLastError());
                              //  }
                              if(debug)
                                 Alert("Trade should definitely have happened!");
                             }
                           int bopenorders;
                           for(int s=OrdersTotal()-1;s>=0;s--)
                             {
                              if(!OrderSelect(s,SELECT_BY_POS,MODE_TRADES))
                                 continue;
                              if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn)
                                {
                                 bopenorders+=1;
                                }
                             }
                           if(bopenorders<=1 && bopenorders>0)
                             {
                              initialstartbuy=Ask;
                              initialstartsell=0;
                              if(drawgrid==true)
                                {
                                 Alert("Grid should have been drawn");
                                 DrawGrid(initialstartbuy,"Buy");
                                }
                             }
                          }
                       }
                    }
                 }
               if(((iCustom(Symbol(),tf,"Quantum",qde,1,1)>0 && reverse==false && QT==1) || (iCustom(Symbol(),tf,"Quantum",qde,0,1)>0 && reverse && QT==1) || (iCustom(Symbol(),tf,"Quantum - Stochastic OB_OS",qde,K,D,S,OS,OB,1,1)>0 && reverse==false && QT==2) || (iCustom(Symbol(),tf,"Quantum - Stochastic OB_OS",qde,K,D,S,OS,OB,0,1)>0 && reverse && QT==2)) && sellclosed==false)
                 {
                  if((Bid<iMA(Symbol(),PERIOD_D1,ema,0,MODE_EMA,PRICE_CLOSE,1) && ema>0) || ema<=0)
                    {
                     buyclosed=false;
                     if(wait>0 && thewait<wait)
                       {
                        thewait+=1;
                        //Alert("Waiting...",thewait);
                       }
                     else
                       {
                        if(debug)
                           Alert("Quantum Sell Signal detected --- checking other conditions...");
                        cantrade=true;
                        if(grid==true && OrdersTotal()>0)
                          {
                           for(int j=OrdersTotal()-1;j>=0;j--)
                             {
                              if(!OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
                                 continue;
                              if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn)
                                {
                                 if(OrderOpenPrice()<initialstartsell+g1s)
                                   {
                                    grid1trades+=1;
                                   }
                                 if(OrderOpenPrice()>=initialstartsell+g1s && OrderOpenPrice()<initialstartsell+g1s+g2s)
                                   {
                                    grid2trades+=1;
                                   }
                                 if(OrderOpenPrice()>=initialstartsell+g1s+g2s && OrderOpenPrice()<initialstartsell+g1s+g2s+g3s)
                                   {
                                    grid3trades+=1;
                                   }
                                }
                             }
                          }
                        if((grid==true) && Bid<initialstartsell+g1s && ((grid1trades>=grid1maxtrades && grid1maxtrades>0) || (prevorderprice>0 && prevorderprice+(grid1inc*Point*digits)>=Bid)))
                           cantrade=false;
                        if((grid==true) && Bid>=initialstartsell-g1s && Bid<initialstartsell+g1s+g2s && ((grid2trades>=grid2maxtrades && grid2maxtrades>0) || (prevorderprice+(grid2inc*Point*digits)>=Bid)))
                           cantrade=false;
                        if((grid==true) && Bid>=initialstartsell-g1s-g2s && Bid<initialstartsell+g1s+g2s+g3s && ((grid3trades>=grid3maxtrades && grid3maxtrades>0) || (prevorderprice+(grid3inc*Point*digits)>=Bid)))
                           cantrade=false;

                        if(debug && cantrade==false)
                           Alert("Trade Cancelled because of Grid Conditions");

                        if(mon==false && DayOfWeek()==1)
                           cantrade=false;
                        if(tue==false && DayOfWeek()==2)
                           cantrade=false;
                        if(wed==false && DayOfWeek()==3)
                           cantrade=false;
                        if(thurs==false && DayOfWeek()==4)
                           cantrade=false;
                        if(fri==false && DayOfWeek()==5)
                           cantrade=false;

                        if(debug && cantrade==false)
                           Alert("Trade Cancelled because of week Conditions");

                        if(prevorderprice+(xdist*Point)>=Bid && xdist>0 && prevorderprice>0)
                           cantrade=false;

                        //Heiken Ashi Filter
                        if(iCustom(Symbol(),PERIOD_W1,"Heiken Ashi",Red,White,Red,White,2,0)<iCustom(Symbol(),0,"Heiken Ashi",Red,White,Red,White,3,0) && had)
                           cantrade=false;

                        if(xcandles>0)
                          {
                           OrderSelect(OrdersTotal()-1,SELECT_BY_POS,MODE_TRADES);
                           int lastorderbar;
                           if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn)
                             {
                              lastorderbar=iBarShift(Symbol(),tf,OrderOpenTime(),false);
                             }
                           if(lastorderbar<xcandles && lastorderbar>0)
                             {
                              cantrade=false;
                              if(debug)
                                 Alert("Trade Cancelled because of  X Candles Condition");
                             }
                          }

                        mt1=0;
                        mt2 = 0;
                        mt3 = 0;
                        for(int t=OrdersHistoryTotal()-1;t>=0;t--)
                          {
                           if(!OrderSelect(t,SELECT_BY_POS,MODE_HISTORY))
                              continue;
                           if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn && OrderOpenTime()>=iTime(Symbol(),PERIOD_D1,0))
                             {
                              if(OrderOpenTime()>=StrToTime(open1) && OrderOpenTime()<StrToTime(close1))
                                 mt1+=1;
                              if(OrderOpenTime()>=StrToTime(open2) && OrderOpenTime()<StrToTime(close2))
                                 mt2+=1;
                              if(OrderOpenTime()>=StrToTime(open3) && OrderOpenTime()<StrToTime(close3))
                                 mt3+=1;
                             }
                          }
                        for(int r=OrdersTotal()-1;r>=0;r--)
                          {
                           if(!OrderSelect(r,SELECT_BY_POS,MODE_TRADES))
                              continue;
                           if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn && OrderOpenTime()>=iTime(Symbol(),PERIOD_D1,0))
                             {
                              if(OrderOpenTime()>=StrToTime(open1) && OrderOpenTime()<StrToTime(close1))
                                 mt1+=1;
                              if(OrderOpenTime()>=StrToTime(open2) && OrderOpenTime()<StrToTime(close2))
                                 mt2+=1;
                              if(OrderOpenTime()>=StrToTime(open3) && OrderOpenTime()<StrToTime(close3))
                                 mt3+=1;
                             }
                          }

                        if(iTime(Symbol(),1,0)>=StrToTime(open1) && iTime(Symbol(),1,0)<StrToTime(close1) && mt1>=max1 && max1>0)
                           cantrade=false;
                        if(iTime(Symbol(),1,0)>=StrToTime(open2) && iTime(Symbol(),1,0)<StrToTime(close2) && mt2>=max2 && max2>0)
                           cantrade=false;
                        if(iTime(Symbol(),1,0)>=StrToTime(open3) && iTime(Symbol(),1,0)<StrToTime(close3) && mt3>=max3 && max3>0)
                           cantrade=false;

                        if(debug && cantrade==false)
                           Alert("Trade Cancelled due to time window factors");

                        if(Bid<prevorderprice && onlylowerhigher)
                           cantrade=false;

                        if(cantrade==true)
                          {
                           if(stop==true)
                             {
                              ObjectSetInteger(0,"start",OBJPROP_STATE,false);
                             }
                           lots=GetLots(Bid,"Sell");
                           if(lots>0)
                             {
                              int ticketn;
                              RefreshRates();
                              if(indivsl>0 || indivtp>0)
                                {
                                 double newsl=0;
                                 double newtp=0;
                                 if(indivsl>0)
                                    newsl=NormalizeDouble(Bid+(indivsl*Point),Digits);

                                 if(indivtp>0)
                                    newtp=NormalizeDouble(Bid-(indivtp*Point),Digits);

                                 ticketn=OrderSend(Symbol(),OP_SELL,lots,Bid,5,newsl,newtp,comm,mn,0,0);
                                }
                              else
                                {
                                 ticketn=OrderSend(Symbol(),OP_SELL,lots,Bid,5,0,0,comm,mn,0,0);
                                }
                              if(ticketn<=-1)
                                {
                                 RefreshRates();
                                 if(indivsl>0 || indivtp>0)
                                   {
                                    double newsl=0;
                                    double newtp=0;
                                    if(indivsl>0)
                                       newsl=NormalizeDouble(Bid+(indivsl*Point),Digits);

                                    if(indivtp>0)
                                       newtp=NormalizeDouble(Bid-(indivtp*Point),Digits);

                                    ticketn=OrderSend(Symbol(),OP_SELL,lots,Bid,5,newsl,newtp,comm,mn,0,0);
                                   }
                                 else
                                   {
                                    ticketn=OrderSend(Symbol(),OP_SELL,lots,Bid,5,0,0,comm,mn,0,0);
                                   }
                                }
                              if(ticketn<=-1)
                                 Alert("OrderSend Error: ",GetLastError());
                              //if(ticketn>-1 && (indivsl>0 || indivtp>0))
                              //  {
                              //   OrderSelect(ticketn,SELECT_BY_POS,MODE_TRADES);
                              //   if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+(50*Point),OrderTakeProfit(),0,clrAliceBlue))
                              //      Alert("OrderModify Error: ",GetLastError());
                              //  }
                              if(debug)
                                 Alert("Trade should definitely have opened now!");
                             }
                           int sopenorders;
                           for(int v=OrdersTotal()-1;v>=0;v--)
                             {
                              if(!OrderSelect(v,SELECT_BY_POS,MODE_TRADES))
                                 continue;
                              if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn)
                                {
                                 sopenorders+=1;
                                }
                             }
                           if(sopenorders<=1 && sopenorders>0)
                             {
                              initialstartsell=Bid;
                              initialstartbuy=0;
                              if(drawgrid==true)
                                {
                                 Alert("Grid should have been drawn");
                                 DrawGrid(initialstartsell,"Sell");
                                }
                             }
                          }
                       }
                    }
                 }
              }
           }
        }
     }
   prevtime=iTime(Symbol(),tf,0);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetLots(double price,string dir)
  {
   int numtrades,factor;
   double retlots;

   for(int c=OrdersTotal()-1;c>=0;c--)
     {
      if(!OrderSelect(c,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn)
        {
         numtrades+=1;
        }
     }
   if(grid==false)
     {
      if(numtrades>=0 && numtrades<12)
         retlots=T1;
      if(numtrades>=12 && numtrades<21)
         retlots=T2;
      if(numtrades>=21 && numtrades<29)
         retlots=T3;
      if(numtrades>=29 && numtrades<36)
         retlots=T4;
      if(numtrades>=36 && numtrades<39)
         retlots=T5;
      if(numtrades>=39)
         retlots=T6;
     }

   if(grid==true)
     {

      double g1s=grid1size*Point*digits;
      double g2s=grid2size*Point*digits;
      double g3s=grid3size*Point*digits;

      if(numtrades<=0)
         retlots=grid1lots;

      if(numtrades>0)
        {
         if(dir=="Buy")
           {
            if(price>initialstartbuy-g1s)
               retlots=grid1lots;
            if(price>=initialstartbuy-g1s-g2s && price<initialstartbuy-g1s)
               retlots=grid2lots;
            if(price>=initialstartbuy-g1s-g2s-g3s && price<initialstartbuy-g1s-g2s)
               retlots=grid3lots;
            if(price<initialstartbuy-g1s-g2s-g3s)
               retlots=grid3lots;
           }

         if(dir=="Sell")
           {
            if(price<initialstartsell+g1s)
               retlots=grid1lots;
            if(price<=initialstartsell+g1s+g2s && price>initialstartsell+g1s)
               retlots=grid2lots;
            if(price<=initialstartsell+g1s+g2s+g3s && price>initialstartsell+g1s+g2s)
               retlots=grid3lots;
            if(price>=initialstartsell+g1s+g2s+g3s)
               retlots=grid3lots;
           }
        }
     }
   if(mm>0)
     {
      factor=AccountBalance()/mm;
      retlots=retlots*factor;
     }

   if(retlots>0)
     {
      int min_size_digits;

      //check account type (micro / mini / normal)
      if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.001)
         min_size_digits=3;
      if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.01)
         min_size_digits=2;
      if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.05)
         min_size_digits=2;
      if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.1)
         min_size_digits=1;
      if(MarketInfo(Symbol(),MODE_LOTSTEP)==1)
         min_size_digits=0;

      //retlots=NormalizeDouble(retlots,2);
      if(retlots<MarketInfo(Symbol(),MODE_MINLOT))
         retlots=MarketInfo(Symbol(),MODE_MINLOT);
      if(retlots>MarketInfo(Symbol(),MODE_MAXLOT))
         retlots=MarketInfo(Symbol(),MODE_MAXLOT);
      retlots=MathFloor(retlots/MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP);
      if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.05)
        {
         int templots=retlots*100;
         double remainder=templots%5;
         templots=templots-remainder;
         retlots = templots;
         retlots/=100;
        }
     }
   return(retlots);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckCloseTrades()
  {
   bool closeonsell,closeonbuy;
   int runningpoints,numopen;
   double runningprofit;
   bool CloseTrades=false;
   bool CloseManual=false;

   closeonsell=false;
   closeonbuy=false;

   for(int a=OrdersTotal()-1;a>=0;a--)
     {
      if(!OrderSelect(a,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn)
        {
         if(OrderType()==OP_BUY)
           {
            runningpoints+=(Bid-OrderOpenPrice())/Point;
            runningprofit+=OrderProfit()+OrderCommission()+OrderSwap();
            closeonsell=true;
            numopen+=1;
           }
         if(OrderType()==OP_SELL)
           {
            runningpoints+=(OrderOpenPrice()-Bid)/Point;
            runningprofit+=OrderProfit()+OrderCommission()+OrderSwap();
            closeonbuy=true;
            numopen+=1;
           }
        }
     }

   if(manual==false)
     {

      if((runningprofit<=dollarsl && dollarsl<0) || (runningprofit>=dollartp && dollartp>0))// && dollarsl<0)
         CloseTrades=true;

      if((AccountEquity()<=(AccountBalance()+((AccountBalance()*percequitysl)/100)) && percequitysl<0) || (AccountEquity()>=(AccountBalance()+((AccountBalance()*percequitytp)/100)) && percequitytp>0))
         CloseTrades=true;

      if((runningpoints<=pointssl && pointssl<0) || (runningpoints>=pointstp && pointstp>0))
         CloseTrades=true;

      if(AccountEquity()<=(AccountBalance()+((AccountBalance()*percbedd)/100)) && ber==true)
         beractive=true;

      if(runningprofit>=0 && beractive==true)
         CloseTrades=true;

      if(numopen>=closex && closex>0)
         CloseTrades=true;

      if(fulltime==false && closeend)
        {
         if(
            (
            (iTime(Symbol(),1,0)>=StrToTime(close1) && iTime(Symbol(),1,0)<=StrToTime(open2) && (StrToTime(close1)-StrToTime(open1)>0)) ||
            (iTime(Symbol(),1,0)>=StrToTime(close2) && iTime(Symbol(),1,0)<=StrToTime(open3) && (StrToTime(close2)-StrToTime(open2)>0)) ||
            (iTime(Symbol(),1,0)>=StrToTime(close3) && (StrToTime(close3)-StrToTime(open3)>0))))
           {
            CloseTrades=true;
           }
        }
     }
   if(manual)
     {
      CloseManual=ObjectGetInteger(0,"manual",OBJPROP_STATE);
      ObjectSetInteger(0,"manual",OBJPROP_STATE,0);
     }

   if((iCustom(Symbol(),tf,"Quantum",qdc,1,1)>0 && closeonsell==true && reverse==false && QT==1) || (iCustom(Symbol(),tf,"Quantum - Stochastic OB_OS",qdc,K,D,S,OS,OB,1,1)>0 && closeonsell==true && reverse==false && QT==2) || (iCustom(Symbol(),tf,"Quantum",qdc,0,1)>0 && closeonsell==true && reverse && QT==1) || (iCustom(Symbol(),tf,"Quantum - Stochastic OB_OS",qdc,K,D,S,OS,OB,0,1)>0 && closeonsell==true && reverse && QT==2) || (CloseTrades==true))
     {
      if((manual && CloseManual) || manual==false)
        {
         thewait=0;
         DeleteLines();
         if(fifo==false)
           {
            if(CloseTrades)
               CloseNormal(1);
            if(CloseTrades==false)
               CloseNormal(0);
            int opens;
            for(int p=OrdersTotal()-1;p>=0;p--)
              {
               if(!OrderSelect(p,SELECT_BY_POS,MODE_TRADES))
                  continue;
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn)
                 {
                  opens+=1;
                 }
              }
            if(opens>0)
              {
               if(CloseTrades)
                  CloseNormal(1);
               if(CloseTrades==false)
                  CloseNormal(0);
              }
           }
         if(fifo==true)
           {
            if(CloseTrades)
               CloseFifo(1);
            if(CloseTrades==false)
               CloseFifo(0);
            int opens;
            for(int p=OrdersTotal()-1;p>=0;p--)
              {
               if(!OrderSelect(p,SELECT_BY_POS,MODE_TRADES))
                  continue;
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn)
                 {
                  opens+=1;
                 }
              }
            if(opens>0)
              {
               if(CloseTrades)
                  CloseFifo(1);
               if(CloseTrades==false)
                  CloseFifo(0);
              }
           }

         cycles+=1;

         if(iTime(Symbol(),1,0)>=open1 && iTime(Symbol(),1,0)<close1)
            c1+=1;
         if(iTime(Symbol(),1,0)>=open2 && iTime(Symbol(),1,0)<close2)
            c2+=1;
         if(iTime(Symbol(),1,0)>=open3 && iTime(Symbol(),1,0)<close3)
            c2+=1;
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if((iCustom(Symbol(),tf,"Quantum",qdc,0,1)>0 && closeonbuy==true && reverse==false && QT==1) || (iCustom(Symbol(),tf,"Quantum - Stochastic OB_OS",qdc,K,D,S,OS,OB,0,1)>0 && closeonbuy==true && reverse==false && QT==2) || (iCustom(Symbol(),tf,"Quantum",qdc,1,1)>0 && closeonbuy==true && reverse && QT==1) || (iCustom(Symbol(),tf,"Quantum - Stochastic OB_OS",qdc,K,D,S,OS,OB,1,1)>0 && closeonbuy==true && reverse && QT==2) || (CloseTrades==true))
     {
      if((manual && CloseManual) || manual==false)
        {
         thewait=0;
         DeleteLines();
         if(fifo==false)
           {
            if(CloseTrades)
               CloseNormal(1);
            if(CloseTrades==false)
               CloseNormal(0);
            int opens;
            for(int p=OrdersTotal()-1;p>=0;p--)
              {
               if(!OrderSelect(p,SELECT_BY_POS,MODE_TRADES))
                  continue;
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn)
                 {
                  opens+=1;
                 }
              }
            if(opens>0)
              {
               if(CloseTrades)
                  CloseNormal(1);
               if(CloseTrades==false)
                  CloseNormal(0);
              }
           }
         if(fifo==true)
           {
            if(CloseTrades)
               CloseFifo(1);
            if(CloseTrades==false)
               CloseFifo(0);
            int opens;
            for(int p=OrdersTotal()-1;p>=0;p--)
              {
               if(!OrderSelect(p,SELECT_BY_POS,MODE_TRADES))
                  continue;
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn)
                 {
                  opens+=1;
                 }
              }
            if(opens>0)
              {
               if(CloseTrades)
                  CloseFifo(1);
               if(CloseTrades==false)
                  CloseFifo(0);
              }
           }
         //int cycles=GlobalVariableGet(Symbol()+"DailyCycles");
         cycles+=1;

         if(iTime(Symbol(),1,0)>=open1 && iTime(Symbol(),1,0)<close1)
            c1+=1;
         if(iTime(Symbol(),1,0)>=open2 && iTime(Symbol(),1,0)<close2)
            c2+=1;
         if(iTime(Symbol(),1,0)>=open3 && iTime(Symbol(),1,0)<close3)
            c2+=1;
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseNormal(int A)
  {
   prevorderprice=0;
   for(int c=OrdersTotal()-1;c>=0;c--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(!OrderSelect(c,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn)
        {
         if(A>0)
           {
            if(OrderType()==OP_BUY)
               buyclosed=true;
            if(OrderType()==OP_SELL)
               sellclosed=true;
           }
         RefreshRates();
         if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,0))
            Alert("OrderClose Error: ",GetLastError());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseFifo(int B)
  {
   prevorderprice=0;
   int TradeList2[][2];
   int ctTrade2=0;
   for(int h=OrdersTotal()-1;h>=0;h--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(!OrderSelect(h,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==mn)
        {
         ctTrade2++;
         ArrayResize(TradeList2,ctTrade2);
         TradeList2[ctTrade2-1][0]=OrderOpenTime();
         TradeList2[ctTrade2-1][1]=OrderTicket();
        }
     }
   ArraySort(TradeList2,WHOLE_ARRAY,0,MODE_ASCEND);
   for(int i=0; i<ctTrade2; i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      OrderSelect(TradeList2[i][1],SELECT_BY_TICKET);
      if(B>0)
        {
         if(OrderType()==OP_BUY)
            buyclosed=true;
         if(OrderType()==OP_SELL)
            sellclosed=true;
        }
      RefreshRates();
      if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,0))
         Alert("OrderClose Error: ",GetLastError());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawGrid(double price,string dir)
  {
   Alert("Were the grid lines drawn?");
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(dir=="Buy")
     {
      ObjectCreate(0,"Initial Grid",OBJ_HLINE,0,iTime(Symbol(),1,0),price);
      ObjectCreate(0,"Grid 1",OBJ_HLINE,0,iTime(Symbol(),1,0),price-(grid1size*Point*digits));
      ObjectCreate(0,"Grid 2",OBJ_HLINE,0,iTime(Symbol(),1,0),price-((grid1size+grid2size)*Point*digits));
      ObjectCreate(0,"Grid 3",OBJ_HLINE,0,iTime(Symbol(),1,0),price-((grid1size+grid2size+grid3size)*Point*digits));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(dir=="Sell")
     {
      ObjectCreate(0,"Initial Grid",OBJ_HLINE,0,iTime(Symbol(),1,0),price);
      ObjectCreate(0,"Grid 1",OBJ_HLINE,0,iTime(Symbol(),1,0),price+(grid1size*Point*digits));
      ObjectCreate(0,"Grid 2",OBJ_HLINE,0,iTime(Symbol(),1,0),price+((grid1size+grid2size)*Point*digits));
      ObjectCreate(0,"Grid 3",OBJ_HLINE,0,iTime(Symbol(),1,0),price+((grid1size+grid2size+grid3size)*Point*digits));
     }
   MessageBoxA(0,"Got the 1000th tick!","Pause...",64);
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteLines()
  {
   ObjectDelete(0,"Initial Grid");
   ObjectDelete(0,"Grid 1");
   ObjectDelete(0,"Grid 2");
   ObjectDelete(0,"Grid 3");
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateButton()
  {
   ObjectCreate(ChartID(),"start",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(ChartID(),"start",OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(ChartID(),"start",OBJPROP_BGCOLOR,clrGreen);
   ObjectSetInteger(ChartID(),"start",OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSetInteger(ChartID(),"start",OBJPROP_XSIZE,100);
   ObjectSetInteger(ChartID(),"start",OBJPROP_YSIZE,20);
   ObjectSetInteger(ChartID(),"start",OBJPROP_STATE,false);
   ObjectSetString(ChartID(),"start",OBJPROP_FONT,"Arial");
   ObjectSetString(ChartID(),"start",OBJPROP_TEXT,"Start next cycle");
   ObjectSetInteger(ChartID(),"start",OBJPROP_FONTSIZE,8);
   ObjectSetInteger(ChartID(),"start",OBJPROP_SELECTABLE,0);
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateManualButton()
  {
   ObjectCreate(ChartID(),"manual",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(ChartID(),"manual",OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(ChartID(),"manual",OBJPROP_BGCOLOR,clrRed);
   ObjectSetInteger(ChartID(),"manual",OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(ChartID(),"manual",OBJPROP_XSIZE,100);
   ObjectSetInteger(ChartID(),"manual",OBJPROP_YSIZE,20);
   ObjectSetInteger(ChartID(),"manual",OBJPROP_STATE,false);
   ObjectSetString(ChartID(),"manual",OBJPROP_FONT,"Arial");
   ObjectSetString(ChartID(),"manual",OBJPROP_TEXT,"Close All Trades");
   ObjectSetInteger(ChartID(),"manual",OBJPROP_FONTSIZE,8);
   ObjectSetInteger(ChartID(),"manual",OBJPROP_SELECTABLE,0);
   return;
  }
//+------------------------------------------------------------------+
