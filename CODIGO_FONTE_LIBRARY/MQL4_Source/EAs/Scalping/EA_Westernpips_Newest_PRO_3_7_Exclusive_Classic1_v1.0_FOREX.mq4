//+------------------------------------------------------------------+
//|             $$$ Westernpips Newest PRO 3.7 Exclusive Classic.mq4 |
//|                           Copyright 2016, http://westernpips.com |
//|                                           http://westernpips.com |
//+------------------------------------------------------------------+
#property copyright "http://westernpips.com"
#property link      "http://westernpips.com"
#property strict

string g_expert_ver = "Newest PRO 3.7 Exclusive Classic";

#property description  "Professional Forex Expert Advisor  Newest PRO 3.7 Exclusive Classic"
#property description  "Newest PRO 3.7 Exclusive Classic Author and developer:"
#property description   "SERGEY & WESTERNPIPS GROUP"
#property description   "Mail to:  westernpips@gmail.com"
#property description   "Skype to: westernpips.com"
#property description   "All Rights Reserved by http://westernpips.com"

#import "Newest_PRO_3.7_Exclusive.dll"
void  getRatesSaxo(uchar & _rateCode[], double&, double&);
void  getRatesLmax(uchar & _rateCode[], double&, double&);
void  getRatesRithmic(uchar & _rateCode[], double&, double&);
void  getRatesCQG(uchar & _rateCode[], double&, double&);
#import

#define OF_READWRITE          2

#import "kernel32.dll"
   int _lcreat (uchar& [], int );
   int _lwrite (int handle, uchar& [], int bytes);
   int _lclose (int handle);
   int CreateDirectoryA(uchar& [], int& []);
#import

extern string WesternpipsSet1="<<< FAST DATA FEED OPTIONS >>>";
extern string WesternpipsSet1_1="0-Saxo; 1-Lmax; 2-CQG; 3-Rithmic;";
extern int    ModeOfQuotes=3;
extern bool   UseSymbCode = false;
extern string SymbCode="FDAX0616";
extern bool   SymbReturn = false;
extern bool   AvtoShiftBid = true;
extern double ShiftAsk = 0;
extern double ShiftBid = 0;

extern string WesternpipsSet2="<<< OPEN ORDERS SETTINGS >>>";
extern double MinimumLevel = 1;
extern double MinGapForOpen = 0;
extern bool   UseDynamicMinimumLevel = false;         
extern double DynamicMinimumLevelSpreadCoefficient = 0.7;
extern int    SignalMode=1; 
extern bool   AvtoSettings = true;
extern bool   AvarageSpreadUse = true;
extern bool   TradeByPendingOrders = true;
extern double DistanceForPendingOrdersInPips=0;
extern int    PendingOrdersLifeTime=5;
extern int    OrdersOpenIntervalMs = 0;
extern int    MaxAttemptsForOpenOrder = 3;
extern int    NTrades = 3;
extern int    Magic=0;
extern bool   ShowCommentsInOrder=true;
extern string EAComment="";
extern string TradeSideSet="0-Both;1-Buy;2-Sell";
extern int    TradeSide=0;

extern string WesternpipsSet3="<<< CLOSE ORDERS SETTINGS >>>";
extern double FixTP =0.1;
extern double FixSL = 1;
extern bool   RealFixTP = false;
extern bool   RealFixSL = false;
extern bool   UseFixedStopLossAndTakeProfit = true;
extern double StopLoss = 10;
extern double TakeProfit = 100;
input  bool   ShirtStopLoss = false;
input  double ShirtStopLossK = 2;
extern bool   CloseWhenPriceEqual = false;
extern int    CloseOrderDelay = 0;
extern int    CloseTimer = 0;
extern bool   DisableFixTP=false;
extern bool   DisableFixSL=false;
extern int    MaxAttemptsForCloseOrder = 3;

extern string WesternpipsSet4="<<< RISK MANAGMENT >>>";
extern double RiskPercent = 0;
extern double Lots=0.01;
extern double max_Lots=9;
extern string LotsCountSet="Lots Count: 0-Balanse; 1-Equity";
extern int    LotsCount = 0;
extern bool   LotsSignalPower = false;
extern double MaxLossOnDepositInPersent=10;
extern double MaxProfitOnDepositInPersent=0;
extern double MaxLossOnDepositInUsd = 0;
extern bool   StopTradingIfUnprofitableOrders = false; 
extern int    MaxUnprofitableOrders = 3;

extern string WesternpipsSet5="<<< CONTROL SLIPPAGE PLUG-IN >>>";
input  int    OrderOpenSlippage = 0;
input  int    OrderCloseSlippage = 0;
extern bool   StopTradingSlippage=false;
extern bool   StopTradingIfMaxSlippage=false;
extern int    MaxSlippage=100;
extern bool   UseDynamicSlippage = false;                                                                                           
extern double DynamicSlippageCoefficient = 1.2;

extern string WesternpipsSet6="<<< CONTROL EXECUTION PLUG-IN >>>";
extern bool   UseMaxOpenOrderExecutionTime=false;
extern int    MaxOpenOrderExecutionTime=1000;
extern bool   UseMaxCloseOrderExecutionTime=false;
extern int    MaxCloseOrderExecutionTime=1000;

extern string WesternpipsSet7="<<< SPREAD CONTROL TOOLS >>>";
extern bool   MinSpreadOpenUse = false;
extern double MinSpreadOpen=1;
extern bool   MaxSpreadOpenUse = false;
extern double MaxSpreadOpen=50;
extern bool   MinSpreadCloseUse = false;
extern double MinSpreadClose=1;
extern bool   MaxSpreadCloseUse = false;
extern double MaxSpreadClose=50;

extern string WesternpipsSet8="<<< COMMISSION SETTINGS >>>";
extern bool   OrderCommissionCheck=false;
extern bool   ManualComission=false;
extern double ComissionInPips=1;

extern string WesternpipsSet9="<<< TRAILING STOP SETTINGS >>>";
extern bool   UseTrailingStop = false;
extern double TrailingStop = 1;
extern double TrailingStep = 1;
extern bool   UseVirtualTrailingStop = false;
extern double VirtualTrailingStop = 1;
extern double VirtualTrailingStep = 1;

extern string WesternpipsSet10="<<< ADDITIONAL SETTINGS >>>";            
extern bool   ShowGraf=true;
extern bool   ShowPriceLabel = false;
extern bool   ShowAsk = false;
extern bool   ShowLog=true;
extern bool   SoundSignal = false;
extern bool   UseTerminalSleepInMilliseconds=true;
extern int    TerminalSleepInMilliseconds=20;

extern string WesternpipsSet11="<<< TIME OF TRADING SETTINGS >>>";
extern string TimeSet="0-Mt4ServerTime;1-LocalPCTime;2-GMT";
extern int    TimeCount = 1;
extern bool   UseTimer = false;
extern int    StartHour = 10;
extern int    StartMinutes = 41;
extern int    StartSeconds = 00;
extern int    StopHour = 10;
extern int    StopMinutes = 42;
extern int    StopSeconds = 00;

string lmaxtexta="";
int    traltime=0;
int    traltime2=0;
double BuyClosePrice=0;
double SellClosePrice=0;
color  ColorQuotes;
string QText="";
double LastCloseSlippage=0;
double LastGap=0;
double LastOpenSlippage=0;
int    LastCloseTime=0;
int    LastOpenTime=0;
double PriceCloseSell=0;	
int    CloseTicketSell=0;
double CloseSellPr=0;
double CloseSellSlippage=0;
double PriceCloseBuy=0;	
int    CloseTicket=0;
double CloseBuyPr=0;
double CloseBuySlippage=0;
int    TimeEnd=0;
int    MagicTest=0;
int    cnt=0;
double SymbolComissionInPips=0;
double averageAskSum = 0;
double averageBidSum = 0;
double averageAskCount = 0;
double averageBidCount = 0;
double averageSpreadSum = 0;
double averageSpreadCount = 0;
double LmaxAsk=0;
double LmaxBid=0;
double LmaxGapAsk=0;
double LmaxGapBid=0;
bool   NewLmaxAsk=0;
bool   NewLmaxBid=0;
double LmaxAskOld=0;
double LmaxBidOld=0;
double Mt4Ask=0;
double Mt4Bid=0;
double Mt4GapAsk=0;
double Mt4GapBid=0;
bool   NewMt4Ask=0;
bool   NewMt4Bid=0;
double Mt4AskOld=0;
double Mt4BidOld=0;
double GapBuy=0;
double GapSell=0;
bool   tradeLmax=true;
double SaxoAsk=0;
double SaxoBid=0;
double pp=0;
double margin=0;
double spread=0;
double spread2=0;
double dLot=0;
double LOTSTEP=0;
double MINLOT=0;
double MAXLOT=0;
double bid_pr=0;
double ask_pr=0;
double fx=0;
double StopLoss2=0;
double TakeProfit2=0;
double StepTP2=0;
double FixSL2=0;
double FixTP2=0;
double minshag=0;
int    rez=0;
int    sig=0;
int    sig_raz=0;
int    ticket=0;
double MinLev=0;
double DepositStop=0;
double DepositStopIfProfit=0;
double TradeLot=0;
double SpreadK=1;
string comm="";
double ShiftBidBuy=0;
double ShiftBidSell=0;
string LastErrorText="";
bool   SignalBuy=false;
bool   SignalSell=false;
string OrderCommBuy="";
string OrderCommSell="";
double OpenBuyPrice=0;
double SlippageBuy=0;
double OpenSellPrice=0;
double SlippageSell=0;
int    Bar=0;
int    BarsCount=0;
int    x=0;
bool   StopTrading = false;
double DistancePending=0;
string text1 ="......";
string text2 ="......";
string text3 ="......";
string text4 ="......";
color  col1 = White;
color  col2 = White;
color  col3 = White;
color  col4 = White;
datetime LastOrderTime = 0;
double PriceCloseSellTral=0;
double PriceCloseBuyTral=0;
bool StopTradindSlip = false;
double PrCloseBuy =0 ;   
double PrCloseSell=0 ;
bool buy111=0;
bool sell111=0;
int step1=0;
int step2=0;
int step1old=0;
int step2old=0;
int ReadCodeStep=0;
int ReadCodeTime=0;
int ReadCodeTimeEnd=0;
int ReadCodeTimeSumm=0; 
int AvReadCodeTime =0;
bool NewTickDel = true;
double Eq = 0;
string Instrument="";
int att=0;
int LastLmaxTickTime=0;
int LmaxTickTime=0;
int LastMt4TickTime=0;
int Mt4TickTime=0;
double LmaxBidCount =0;
bool ShowPanel=false;
string comm11="";
int LactCheckTime=0;
int StepCheck=0;
int CheckNextTime=0;
int OldTickCount=0;
bool ShowErrorPanel=false; 
int t2=0;

double OrdOpenSlippage=0;                   
string Commento="";                  	   
int ticketSell=0;
int ticketBuy=0;
int t1=0;
int t3=0;
double PendingOrderOpenPriseBuy=0;
double PendingOrderOpenPriseSell=0;
bool SignalFromMt4 = false;

int OnInit()
  {  
   
   if(UseVirtualTrailingStop && DisableFixTP ==false )
   { 
   Alert(">>> You use settings, where UseVirtualTrailingStop = true. Need put DisableFixTP = true, DisableFixSL = false for this settings");
   }
   if(UseTrailingStop && DisableFixTP ==false )
   { 
   Alert(">>> You use settings, where UseTrailingStop = true. Need put DisableFixTP = true, DisableFixSL = false for this settings");
   }
   if(UseTrailingStop && UseVirtualTrailingStop)
   { 
   Alert(">>> You use settings, where UseTrailingStop = true, and UseVirtualTrailingStop = true. Choose only one.");
   }
   
   if(CloseWhenPriceEqual && DisableFixTP ==false )
   { 
   Alert(">>> You use settings, where CloseWhenPriceEqual = true. Need put DisableFixTP = true, DisableFixSL = false  for this settings");
   }
  
   
   
    lmaxtexta="";
    traltime=0;
    traltime2=0;
    BuyClosePrice=0;
    SellClosePrice=0;
    ColorQuotes;
    QText="";
    LastCloseSlippage=0;
    LastGap=0;
    LastOpenSlippage=0;
    LastCloseTime=0;
    LastOpenTime=0;
 PriceCloseSell=0;	
    CloseTicketSell=0;
 CloseSellPr=0;
 CloseSellSlippage=0;
 PriceCloseBuy=0;	
    CloseTicket=0;
 CloseBuyPr=0;
 CloseBuySlippage=0;
    TimeEnd=0;
    MagicTest=0;
    cnt=0;
 SymbolComissionInPips=0;
 averageAskSum = 0;
 averageBidSum = 0;
 averageAskCount = 0;
 averageBidCount = 0;
 averageSpreadSum = 0;
 averageSpreadCount = 0;
 LmaxAsk=0;
 LmaxBid=0;
 LmaxGapAsk=0;
 LmaxGapBid=0;
   NewLmaxAsk=0;
   NewLmaxBid=0;
 LmaxAskOld=0;
 LmaxBidOld=0;
 Mt4Ask=0;
 Mt4Bid=0;
 Mt4GapAsk=0;
 Mt4GapBid=0;
   NewMt4Ask=0;
   NewMt4Bid=0;
 Mt4AskOld=0;
 Mt4BidOld=0;
 GapBuy=0;
 GapSell=0;
   tradeLmax=true;
 SaxoAsk=0;
 SaxoBid=0;
 pp=0;
 margin=0;
 spread=0;
 spread2=0;
 dLot=0;
 LOTSTEP=0;
 MINLOT=0;
 MAXLOT=0;
 bid_pr=0;
 ask_pr=0;
 fx=0;
 StopLoss2=0;
 TakeProfit2=0;
 StepTP2=0;
 FixSL2=0;
 FixTP2=0;
 minshag=0;
    rez=0;
    sig=0;
    sig_raz=0;
    ticket=0;
 MinLev=0;
 DepositStop=0;
 DepositStopIfProfit=0;
 TradeLot=0;
 SpreadK=1;
 comm="";
 ShiftBidBuy=0;
 ShiftBidSell=0;
 LastErrorText="";
   SignalBuy=false;
   SignalSell=false;
 OrderCommBuy="";
 OrderCommSell="";
 OpenBuyPrice=0;
 SlippageBuy=0;
 OpenSellPrice=0;
 SlippageSell=0;
    Bar=0;
    BarsCount=0;
    x=0;
   StopTrading = false;
 DistancePending=0;
 text1 ="......";
 text2 ="......";
 text3 ="......";
 text4 ="......";
  col1 = White;
  col2 = White;
 col3 = White;
 col4 = White;
 LastOrderTime = 0;
 PriceCloseSellTral=0;
 PriceCloseBuyTral=0;
 StopTradindSlip = false;
 PrCloseBuy =0 ;   
 PrCloseSell=0 ;
 buy111=0;
 sell111=0;
 step1=0;
 step2=0;
 step1old=0;
 step2old=0;
 ReadCodeStep=0;
 ReadCodeTime=0;
 ReadCodeTimeEnd=0;
 ReadCodeTimeSumm=0; 
 AvReadCodeTime =0;
 NewTickDel = true;
 Eq = 0;
 Instrument="";
 att=0;
 LastLmaxTickTime=0;
 LmaxTickTime=0;
 LastMt4TickTime=0;
 Mt4TickTime=0;
 LmaxBidCount =0;
 ShowPanel=false;
 comm11="";
 LactCheckTime=0;
 StepCheck=0;
 CheckNextTime=0;
 OldTickCount=0;
 ShowErrorPanel=false; 
 t2=0;
 
 OrdOpenSlippage=0;                   
 Commento="";                  	   
 ticketSell=0;
 ticketBuy=0;
 t1=0;
 t3=0;
 PendingOrderOpenPriseBuy=0;
 PendingOrderOpenPriseSell=0;
 SignalFromMt4 = false;
   
   //-------------------------------
   NewTickDel=true;
   OldTickCount=0;
   ObjectsDeleteAll();  
   Comment("");
   ShowPanel=false;
   
   double profit2=0;
   for(int g22=0;g22<OrdersHistoryTotal();g22++) 
                  {
                   if (OrderSelect(g22, SELECT_BY_POS,MODE_HISTORY))
                      {
                      if(OrderType()==OP_BUY||OrderType()==OP_SELL)
                      {profit2=profit2+OrderProfit()+OrderCommission();}
                      }
                      }
   string txt1="";
   if(profit2>0) {txt1="$$$ ";}
   int han;
   int empty[];
   string FileName="";
   FileName="C:\\ProgramData\\Westernpips";//+AccountCompany()+"_AccNumber_"+AccountNumber()+".txt";  
   uchar buf[2048];   
   StringToCharArray( FileName,buf);
   CreateDirectoryA(buf,empty);
   string result;
   FileName += "\\"+txt1+AccountCompany()+AccountNumber()+AccountServer()+".dat";
   StringToCharArray( FileName,buf);
   result = CharArrayToString(buf); 
   han=_lcreat(buf, OF_READWRITE );  
   
   if(han>0)
   {                         
   string text="";
   double profit=0;
   
    for(int g2=0;g2<OrdersHistoryTotal();g2++) 
                  {
                   if (OrderSelect(g2, SELECT_BY_POS,MODE_HISTORY))
                      {
                      string tpe="";
                      double pips=-1; 
                      int tm=-1;
                      if(OrderLots()>0)
                      {
                      if (OrderType()==OP_BUY)  {tpe="Buy       "; tm=OrderCloseTime()-OrderOpenTime(); if(MarketInfo(OrderSymbol(),MODE_POINT)>0) pips = (OrderClosePrice()- OrderOpenPrice())/MarketInfo(OrderSymbol(),MODE_POINT);}  
                      if (OrderType()==OP_SELL) {tpe="Sell      ";tm=OrderCloseTime()-OrderOpenTime();  if(MarketInfo(OrderSymbol(),MODE_POINT)>0)pips = (OrderOpenPrice() -OrderClosePrice())/MarketInfo(OrderSymbol(),MODE_POINT);}  
                      if (OrderType()==OP_BUYSTOP)  {tpe="BuyStop   "; tm=OrderCloseTime()-OrderOpenTime(); if(MarketInfo(OrderSymbol(),MODE_POINT)>0)pips = (OrderClosePrice()- OrderOpenPrice())/MarketInfo(OrderSymbol(),MODE_POINT);}  
                      if (OrderType()==OP_SELLSTOP) {tpe="SellStop  ";tm=OrderCloseTime()-OrderOpenTime();  if(MarketInfo(OrderSymbol(),MODE_POINT)>0)pips = (OrderOpenPrice() -OrderClosePrice())/MarketInfo(OrderSymbol(),MODE_POINT);}  
                      if (OrderType()==OP_BUYLIMIT)  {tpe="BuyLimit   "; tm=OrderCloseTime()-OrderOpenTime(); if(MarketInfo(OrderSymbol(),MODE_POINT)>0)pips = (OrderClosePrice()- OrderOpenPrice())/MarketInfo(OrderSymbol(),MODE_POINT);}  
                      if (OrderType()==OP_SELLLIMIT) {tpe="SellLimit  ";tm=OrderCloseTime()-OrderOpenTime();  if(MarketInfo(OrderSymbol(),MODE_POINT)>0)pips = (OrderOpenPrice() -OrderClosePrice())/MarketInfo(OrderSymbol(),MODE_POINT);}  
                      }
                      string pipstext;
                      if (pips>0) {pipstext="+";}
                      else {pipstext="";}             
                      text = text+
                      DoubleToString(OrderTicket(),0)+ "     " 
                      +OrderOpenTime()+ "     " 
                      +tpe+ "     " 
                      +DoubleToString(OrderLots(),2)+ "     " 
                      +OrderSymbol()+ "     " 
                      +DoubleToString(OrderOpenPrice(),5)+ "     " 
                      +DoubleToString(OrderStopLoss(),5)+ "     " 
                      +DoubleToString(OrderTakeProfit(),5)+ "     " 
                      +OrderCloseTime()+ "     " 
                      +DoubleToString(OrderClosePrice(),5)+ "     " 
                      +DoubleToString(OrderCommission(),2)+ "     " 
                      +pipstext+DoubleToString(OrderProfit(),2)+ "     " 
                      +OrderComment()+ "     " 
                      +OrderMagicNumber()+ "     " 
                      +tm+ "     " 
                      +pipstext+DoubleToString(pips,2)+ "     " 
                      + "\n";
                      if(OrderType()==OP_BUY||OrderType()==OP_SELL)
                      {profit=profit+OrderProfit()+OrderCommission();}
                      }
                  }               

   
        text = "TotalProfit = "+profit + "\n"   
              +"AccountCompany: "+ AccountCompany() + "\n" 
              +"AccountServer: "+  AccountServer()+ "\n" 
              +"AccountNumber: "+  AccountNumber()+ "\n" 
              +"AccountName: "+    AccountName()+ "\n" 
              +"AccountBalance: "+ AccountBalance()+ "\n"  
              +"AccountProfit: "+   AccountInfoDouble(ACCOUNT_PROFIT)+ "\n" 
              +"AccountEquity: "+  AccountEquity()+ "\n"            
              +"AccountCurrency: "+AccountCurrency()+ "\n" 
              +"AccountCredit: "+  AccountCredit()+ "\n"              
              +"AccountLeverage: "+AccountLeverage()+ "\n" 
              +"AccountMargin: "+  AccountMargin()+ "\n" 
              + "\n"   
              +"Ticket "
              +"        Open Time " 
              +"              Type "
              +"           Lots "
              +"    Symbol "
              +"  Open Price "
              +" Stop Loss "
              +" Take Profit "
              +"   Close Time "
              +"          Close Price "
              +" Commission "
              +" Profit "
              +" Comment "
              +"      Magic "
              +" OrderTime "
              +" PipsProfit/Loss "
              + "\n" +text+ "\n"+
              
              "$$$ Westernpips Newest PRO 3.7 Exclusive Classic"+"\n"+"\n"+
   
  
   
   
      "WesternpipsSet1=<<< FAST DATA FEED OPTIONS >>>"+ "\n"+
      "WesternpipsSet1_1=0-Saxo; 1-Lmax; 2-CQG; 3-Rithmic;"+ "\n"+
      "ModeOfQuotes="+ModeOfQuotes+ "\n"+
      "UseSymbCode="+UseSymbCode+ "\n"+
      "SymbCode="+SymbCode+ "\n"+
      "SymbReturn="+SymbReturn+ "\n"+
      "AvtoShiftBid="+AvtoShiftBid+ "\n"+
      "ShiftAsk="+ShiftAsk+ "\n"+
      "ShiftBid="+ShiftBid+ "\n"+
      "WesternpipsSet2=<<< OPEN ORDERS SETTINGS >>>"+ "\n"+
      "MinimumLevel="+MinimumLevel+ "\n"+
      "MinGapForOpen="+MinGapForOpen+ "\n"+
      "UseDynamicMinimumLevel="+UseDynamicMinimumLevel+ "\n"+
      "DynamicMinimumLevelSpreadCoefficient="+ "\n"+
      "SignalMode="+SignalMode+ "\n"+
      "AvtoSettings="+AvtoSettings+ "\n"+
      "AvarageSpreadUse="+AvarageSpreadUse+ "\n"+
      "TradeByPendingOrders="+TradeByPendingOrders+ "\n"+
      "DistanceForPendingOrdersInPips="+DistanceForPendingOrdersInPips+ "\n"+
      "PendingOrdersLifeTime="+PendingOrdersLifeTime+ "\n"+
      "OrdersOpenIntervalMs="+OrdersOpenIntervalMs+ "\n"+
      "MaxAttemptsForOpenOrder="+MaxAttemptsForOpenOrder+ "\n"+
      "NTrades="+NTrades+ "\n"+
      "Magic="+Magic+ "\n"+
      "EAComment="+EAComment+ "\n"+
      "TradeSideSet=0-Both;1-Buy;2-Sell"+ "\n"+
      "TradeSide="+TradeSide+ "\n"+
      "WesternpipsSet3=<<< CLOSE ORDERS SETTINGS >>>"+ "\n"+
      "FixTP="+FixTP+ "\n"+
      "FixTP="+FixTP+ "\n"+
      "RealFixTP="+RealFixTP+ "\n"+
      "RealFixSL="+RealFixSL+ "\n"+
      "UseFixedStopLossAndTakeProfit="+UseFixedStopLossAndTakeProfit+ "\n"+
      "StopLoss="+StopLoss+ "\n"+
      "TakeProfit="+TakeProfit+ "\n"+
      "ShirtStopLoss="+ShirtStopLoss+ "\n"+
      "ShirtStopLossK="+ShirtStopLossK+ "\n"+
      "CloseWhenPriceEqual="+CloseWhenPriceEqual+ "\n"+
      "CloseOrderDelay="+CloseOrderDelay+ "\n"+
      "CloseTimer="+CloseTimer+ "\n"+
      "DisableFixTP="+DisableFixTP+ "\n"+
      "DisableFixSL="+DisableFixSL+ "\n"+
      "MaxAttemptsForCloseOrder="+MaxAttemptsForCloseOrder+ "\n"+
      "WesternpipsSet4=<<< RISK MANAGMENT >>>"+ "\n"+
      "RiskPercent="+RiskPercent+ "\n"+
      "Lots="+Lots+ "\n"+
      "max_Lots="+max_Lots+ "\n"+
      "LotsCountSet=Lots Count: 0-Balanse; 1-Equity"+ "\n"+
      "LotsCount="+LotsCount+ "\n"+
      "LotsSignalPower="+LotsSignalPower+ "\n"+
      "MaxLossOnDepositInPersent="+MaxLossOnDepositInPersent+ "\n"+
      "MaxProfitOnDepositInPersent="+MaxProfitOnDepositInPersent+ "\n"+
      "MaxLossOnDepositInUsd="+MaxLossOnDepositInUsd+ "\n"+
      "StopTradingIfUnprofitableOrders="+StopTradingIfUnprofitableOrders+ "\n"+
      "MaxUnprofitableOrders="+MaxUnprofitableOrders+ "\n"+
      "WesternpipsSet5=<<< CONTROL SLIPPAGE PLUG-IN >>>"+ "\n"+
      "StopTradingSlippage="+StopTradingSlippage+ "\n"+
      "OrderOpenSlippage="+OrderOpenSlippage+ "\n"+
      "OrderCloseSlippage="+OrderCloseSlippage+ "\n"+
      "StopTradingIfMaxSlippage="+StopTradingIfMaxSlippage+ "\n"+
      "MaxSlippage="+MaxSlippage+ "\n"+
      "UseDynamicSlippage="+UseDynamicSlippage+ "\n"+
      "DynamicSlippageCoefficient="+DynamicSlippageCoefficient+ "\n"+
      "WesternpipsSet6=<<< CONTROL EXECUTION PLUG-IN >>>"+ "\n"+
      "UseMaxOpenOrderExecutionTime="+UseMaxOpenOrderExecutionTime+ "\n"+
      "MaxOpenOrderExecutionTime="+MaxOpenOrderExecutionTime+ "\n"+
      "UseMaxCloseOrderExecutionTime="+UseMaxCloseOrderExecutionTime+ "\n"+
      "MaxCloseOrderExecutionTime="+MaxCloseOrderExecutionTime+ "\n"+
      "WesternpipsSet7=<<< SPREAD CONTROL TOOLS >>>"+ "\n"+
      "MinSpreadOpenUse="+MinSpreadOpenUse+ "\n"+
      "MinSpreadOpen="+MinSpreadOpen+ "\n"+
      "MaxSpreadOpenUse="+MaxSpreadOpenUse+ "\n"+
      "MaxSpreadOpen="+MaxSpreadOpen+ "\n"+
      "MinSpreadCloseUse="+MinSpreadCloseUse+ "\n"+
      "MinSpreadClose="+MinSpreadClose+ "\n"+
      "MaxSpreadCloseUse="+MaxSpreadCloseUse+ "\n"+
      "MaxSpreadClose="+MaxSpreadClose+ "\n"+
      "WesternpipsSet8=<<< COMMISSION SETTINGS >>>"+ "\n"+
      "OrderCommissionCheck="+OrderCommissionCheck+ "\n"+
      "ManualComission="+ManualComission+ "\n"+
      "ComissionInPips="+ComissionInPips+ "\n"+
      "WesternpipsSet9=<<< TRAILING STOP SETTINGS >>>"+ "\n"+
      "UseTrailingStop="+UseTrailingStop+ "\n"+
      "TrailingStop="+TrailingStop+ "\n"+
      "TrailingStep="+TrailingStep+ "\n"+
      "UseVirtualTrailingStop="+UseVirtualTrailingStop+ "\n"+
      "VirtualTrailingStop="+VirtualTrailingStop+ "\n"+
      "VirtualTrailingStep="+VirtualTrailingStep+ "\n"+
      "WesternpipsSet10=<<< ADDITIONAL SETTINGS >>>"+ "\n"+
      "ShowGraf="+ShowGraf+ "\n"+
      "ShowPriceLabel="+ShowPriceLabel+ "\n"+
      "ShowAsk="+ShowAsk+ "\n"+
      "ShowLog="+ShowLog+ "\n"+
      "ShowCommentsInOrder="+ShowCommentsInOrder+ "\n"+
      "SoundSignal="+SoundSignal+ "\n"+
      "UseTerminalSleepInMilliseconds="+UseTerminalSleepInMilliseconds+ "\n"+
      "TerminalSleepInMilliseconds="+TerminalSleepInMilliseconds+ "\n"+
      "WesternpipsSet11=<<< TIME OF TRADING SETTINGS >>>"+ "\n"+
      "UseTimer="+UseTimer+ "\n"+
      "StartHour="+StartHour+ "\n"+
      "StartMinutes="+StartMinutes+ "\n"+
      "StartSeconds="+StartSeconds+ "\n"+
      "StopHour="+StopHour+ "\n"+
      "StopMinutes="+StopMinutes+ "\n"+
      "StopSeconds="+StopSeconds+ "\n";
   
   
   
            
   
   
   
   
   StringToCharArray( text,buf);               
   _lwrite(han,buf, StringLen(text));
   _lclose(han);
   han=0;                         
   }
    else 
      {
      //PrintFormat("Failed to open %s file, Error code = %d", FileName, GetLastError());
      //ExpertRemove();
      }
      
         if(!IsTradeAllowed() && !IsTradeContextBusy())
           {
            Alert("Automated trading is disabled!",
            " Check tab Tools-Options-Expert Advisors");
            LastErrorText="Automated trading is disabled!Check tab Tools-Options-Expert Advisors"+ "\n";
           }
   
         if(IsDllsAllowed()==false)
          {
           Alert("Calling from libraries (DLL) is impossible.",
                 " Check tab Tools-Options-Expert Advisors");
           LastErrorText="Calling from libraries (DLL) is impossible. Check tab Tools-Options-Expert Advisors"+ "\n"; 
          }
         
         
         
         LmaxAsk = 0;
         LmaxBid = 0;
         
         LmaxGapAsk=0;
         LmaxGapBid=0;
         
         LmaxAskOld = 0;
         LmaxBidOld = 0;
         
         NewLmaxAsk=false;
         NewLmaxBid=false; 
           
         Mt4Ask=0;
         Mt4Bid=0;
            
         Mt4GapAsk=0;
         Mt4GapBid=0;
         
         Mt4AskOld=0;
         Mt4BidOld=0;
       
         NewMt4Ask=false;
         NewMt4Bid=false;  
         
         GapBuy=0;
         GapSell=0; 
         
         SignalBuy=false;
         SignalSell=false;
         
         comm11="";
          
         DepositStop=AccountInfoDouble(ACCOUNT_BALANCE)-AccountInfoDouble(ACCOUNT_BALANCE)*MaxLossOnDepositInPersent/100; 
         DepositStopIfProfit=AccountInfoDouble(ACCOUNT_BALANCE)+AccountInfoDouble(ACCOUNT_BALANCE)*MaxProfitOnDepositInPersent/100; 

         
         
         if(ModeOfQuotes==0)
         {
         ColorQuotes=Yellow;
         QText="Saxo Bank"; 
         OrderCommBuy="S";
         OrderCommSell="S";
         lmaxtexta="Saxo";
         
         }
         if(ModeOfQuotes==1)
         {
         ColorQuotes=C'73,138,243';  
         QText="Lmax Exchange"; 
         OrderCommBuy="L";
         OrderCommSell="L"; 
         lmaxtexta="Lmax"; 
         Magic=Magic+1; 
         }
         
         if(ModeOfQuotes==2)
         {
         ColorQuotes=C'176,26,64';    
         QText="CQG FX";
         OrderCommBuy="C";
         OrderCommSell="C"; 
         lmaxtexta="CQG"; 
         Magic=Magic+2;           
         }
         
         if(ModeOfQuotes==3)
         {
         ColorQuotes=C'0,159,0';   
         QText="Rithmic"; 
         OrderCommBuy="R";
         OrderCommSell="R";
         lmaxtexta="Rithmic";   
         Magic=Magic+3;        
         }
         
         
         
         
            //получение котировок            
            LmaxAsk = 0;
            LmaxBid = 0;
            char curr01[1000];
            LastErrorText="";
            Instrument = StringSubstr(Symbol(),0,6);
            StopTrading = false;
           
            if(ModeOfQuotes==0)
            {
               if(UseSymbCode==true)
                  {
                     StringToCharArray(SymbCode,curr01);
                     getRatesSaxo(curr01,LmaxAsk,LmaxBid);
                  }
                  else
                     {
                        StringToCharArray(Instrument,curr01);
                        getRatesSaxo(curr01,LmaxAsk,LmaxBid);
                     }
            }
                 
            if(ModeOfQuotes==1)
            {
               if(UseSymbCode==true)
                  {
                     StringToCharArray(SymbCode,curr01);
                     getRatesLmax(curr01,LmaxAsk,LmaxBid);
                  }
                  else
                     {
                        StringToCharArray(Instrument,curr01);
                        getRatesLmax(curr01,LmaxAsk,LmaxBid);
                     }
            }
            
            if(ModeOfQuotes==2)
            {
               if(UseSymbCode==true)
                  {
                     StringToCharArray(SymbCode,curr01);
                     getRatesCQG(curr01,LmaxAsk,LmaxBid);
                  }
                  else
                     {
                        StringToCharArray(Instrument,curr01);
                        getRatesCQG(curr01,LmaxAsk,LmaxBid);
                     }
            }
            
            if(ModeOfQuotes==3)
            {
               if(UseSymbCode==true)
                  {
                     StringToCharArray(SymbCode,curr01);
                     getRatesRithmic(curr01,LmaxAsk,LmaxBid);
                  }
                  else
                     {
                        StringToCharArray(Instrument,curr01);
                        getRatesRithmic(curr01,LmaxAsk,LmaxBid);
                     }
            }
                           
           if(SymbReturn==true)
              {
                 LmaxAsk=1/LmaxAsk;
                 LmaxBid=1/LmaxBid;
              }
               
            
            if(SymbCode==""&&UseSymbCode==true)
            {
            tradeLmax=false;
            LmaxAsk = 0;
            LmaxBid = 0;
            LastErrorText=LastErrorText+"Trade Was Stopped, SymbCode Error! Can change SymbCode to "+Symbol()+" in EA settings and start EA again!"+ "\n";
            StopTrading = true;
            }
            
            //проверка котировок №1
            if(LmaxBid==-1||LmaxBid<=0)  {tradeLmax=false; StopTrading = true; GapBuy=0;GapSell=0; LastErrorText=LastErrorText+ "Trade is disabled, error of "+QText+" data feed connection! Please check TradeMonitor programm! Please check DLL import!   Install vc_redist.x64 and vc_redist.x86 files!";}
      		if(LmaxAsk==-1||LmaxAsk<=0)  {tradeLmax=false; StopTrading = true; GapBuy=0;GapSell=0;}
            
            
            pp = MarketInfo(Symbol(),MODE_POINT);
            if(AvtoSettings == false)
               {
               	if (pp == 0.001)   {pp=0.01;}
               	if (pp == 0.00001) {pp=0.0001;} 
            	}  	
            
            
         	Mt4Ask=MarketInfo(Symbol(),MODE_ASK);
            Mt4Bid=MarketInfo(Symbol(),MODE_BID);          
            spread2 = (NormalizeDouble(MarketInfo(Symbol(),MODE_ASK),_Digits)-NormalizeDouble(MarketInfo(Symbol(),MODE_BID),_Digits))/pp;
            
            if(StopTrading == true ) 
            {
            if(ShowLog)Print("!!! " +LastErrorText);
               Comment("");
               ObjectsDeleteAll(); 
               ShowErrorsPanel(); 
            
            }
            else
            {
            if(ShowGraf==false)
            {           
            ObjectCreate("ConnectionStatus", OBJ_LABEL, 0, 0,0);
            ObjectSetText("ConnectionStatus", "n", 10, "Webdings");          
            ObjectSet("ConnectionStatus", OBJPROP_CORNER, 4);
      
            ObjectSet("ConnectionStatus", OBJPROP_XDISTANCE, 5);      
            ObjectSet("ConnectionStatus", OBJPROP_YDISTANCE, 15);       
            ObjectSet("ConnectionStatus", OBJPROP_COLOR, Lime);
            ObjectSet("ConnectionStatus", OBJPROP_BACK, False); 
            
            ObjectCreate("ConnectionStatusText", OBJ_LABEL, 0, 0, 0);
            ObjectSet("ConnectionStatusText", OBJPROP_CORNER, 4);
            ObjectSet("ConnectionStatusText", OBJPROP_XDISTANCE, 25);
            ObjectSet("ConnectionStatusText", OBJPROP_YDISTANCE, 18);
            ObjectSetText("ConnectionStatusText", QText +" is connected successfully!", 8, "Arial", White); 
            }
            else {Comment("Wait tick from Meta Trader 4 " +" .....");}       
            }
         
         
         
         
   return(INIT_SUCCEEDED);
  }
  
  
void OnDeinit(const int reason)
  {
  Comment("");
  ObjectsDeleteAll();  
  }
  
  
void OnTick()
  {
   
   if(IsWorkingHours()==false&&UseTimer){LastErrorText=""; tradeLmax=false; LastErrorText=LastErrorText+"Trade Was Stopped, Not working hours! Can change UseTimer in EA settings and start EA again!"; StopTrading = true;}
   if(IsWorkingHours()==true&&UseTimer){tradeLmax=true; StopTrading = false;}
   
   if (StopTrading == true)
   {  
   Comment("");
   ObjectsDeleteAll();
   ShowErrorsPanel(); 
   }
   
   
   
   while(IsStopped()==false && StopTrading == false)
      {   
            LastErrorText="";
            ReadCodeTime=GetTickCount();
            comm=""; 
           
            if (StopTrading == false) {tradeLmax=true;}                   
            SignalBuy=false;
            SignalSell=false;

            //проверка условий
            
            if(AccountInfoDouble(ACCOUNT_BALANCE)<=DepositStop&&MaxLossOnDepositInPersent>0) {tradeLmax=false; LastErrorText=LastErrorText+"Trade Was Stopped, Big Drawdown > " +MaxLossOnDepositInPersent+" %!" +" Can change RiskDeposit in EA settings and start EA again!" ; StopTrading = true;}
            if(AccountInfoDouble(ACCOUNT_BALANCE)>=DepositStopIfProfit&&MaxProfitOnDepositInPersent>0){tradeLmax=false;LastErrorText=LastErrorText+"Trade Was Stopped, Big Profit > "+MaxProfitOnDepositInPersent+" %!"+" Can change ProfitInDay in EA settings and start EA again!"; StopTrading = true;}              
            if (MarketInfo(Symbol(),MODE_SPREAD)<MinSpreadOpen&&MinSpreadOpenUse==true) {tradeLmax=false; LastErrorText=LastErrorText+"Trade is disabled, Spread = "+DoubleToString(NormalizeDouble(MarketInfo(Symbol(),MODE_SPREAD),2),2)+" pips is low than MinSpreadOpen = " +DoubleToString(MinSpreadOpen,2)+" pips!"+" Can change MinSpreadOpen in EA settings and start EA again!";}
            if (MarketInfo(Symbol(),MODE_SPREAD)>MaxSpreadOpen&&MaxSpreadOpenUse==true) {tradeLmax=false; LastErrorText=LastErrorText+"Trade is disabled, Spread = "+DoubleToString(NormalizeDouble(MarketInfo(Symbol(),MODE_SPREAD),2),2)+" pips is big than MaxSpreadOpen = " +DoubleToString(MaxSpreadOpen,2)+" pips!"+" Can change MaxSpreadOpen in EA settings and start EA again!";}
            
            if(UseMaxOpenOrderExecutionTime){if (LastOpenTime>MaxOpenOrderExecutionTime) {tradeLmax =false;LastErrorText=LastErrorText+"Trade Was Stopped, Big Open Order Execution = "+DoubleToString(LastOpenTime,0)+" ms!" +" Can change MaxOpenOrderExecutionTime in EA settings and start EA again!";  StopTrading = true; }}
            if(UseMaxCloseOrderExecutionTime){if (LastCloseTime>MaxCloseOrderExecutionTime) {tradeLmax =false; LastErrorText=LastErrorText+"Trade Was Stopped, Big Close Order Execution = "+DoubleToString(LastCloseTime,0)+" ms!" +" Can change MaxCloseOrderExecutionTime in EA settings and start EA again!"; StopTrading = true;}}     
                                  
            if(StopTradingIfMaxSlippage){if(LastOpenSlippage <  -MaxSlippage){tradeLmax = false;LastErrorText=LastErrorText+"Trade Was Stopped, Big Order Open Slippage = "+DoubleToString(LastOpenSlippage,0)+" pips!" +" Can change StopTradingIfMaxSlippage in EA settings and start EA again!";  StopTrading = true;}}
            if(StopTradingIfMaxSlippage){if(LastCloseSlippage < -MaxSlippage){tradeLmax = false;LastErrorText=LastErrorText+"Trade Was Stopped, Big Order Close Slippage = "+DoubleToString(LastCloseSlippage,0)+" pips!" +" Can change StopTradingIfMaxSlippage in EA settings and start EA again!";  StopTrading = true;}}
            
            if (StopTradindSlip==true) {tradeLmax = false;LastErrorText=LastErrorText+"Trade Was Stopped, Big Order Open Slippage = "+DoubleToString(LastOpenSlippage,0)+" pips!" +" Can change StopTradingSlippage in EA settings and start EA again!";  StopTrading = true;}
            //проверка времени торговли
            
            if(IsWorkingHours()==false&&UseTimer){tradeLmax=false; LastErrorText=LastErrorText+"Trade Was Stopped, Not working hours! Can change UseTimer in EA settings and start EA again!"; StopTrading = true;}
            
            //защита от слива депозита
            bool selh;
            double historyprofitsell;
            double historyprofitbuy;
            double historyprofit=0;
            int totalloss=0;
            if (OrdersHistoryTotal() > 0) 
                  {
      		      for (int yh = 0; yh < OrdersHistoryTotal(); yh++) 
      		         {
      		         
      			      selh=OrderSelect (yh, SELECT_BY_POS, MODE_HISTORY);      			      
      			      if(OrderMagicNumber()==Magic||OrderMagicNumber()==MagicTest)
      			      {		
      			         if(OrderType()==OP_BUY||OrderType()==OP_SELL)
                           {    
            			      historyprofit=historyprofit+OrderProfit()+OrderCommission();
            			      
         			         }		      
      			      }     			      
      			      }
      			   }            
            if(historyprofit < - MaxLossOnDepositInUsd && MaxLossOnDepositInUsd>0) {tradeLmax=false; GapSell=0;GapBuy=0; LastErrorText=LastErrorText+"Trade Was Stopped, Big Drawdown = "+DoubleToString(historyprofit,2)+" "+AccountCurrency()+", more than MaxLossOnDepositInUsd = "+MaxLossOnDepositInUsd+" "+AccountCurrency()+" ! Can change MaxLossOnDepositInUsd in EA settings and start EA again!"; StopTrading = true;}            
            //конец
                       
            if (StopTradingIfUnprofitableOrders && IsLastOrdersUnprofitable(Magic, MaxUnprofitableOrders)){tradeLmax=false; GapSell=0;GapBuy=0; LastErrorText=LastErrorText+" Trade Was Stopped, "+MaxUnprofitableOrders +" unprofitable orders in a row! Can change MaxUnprofitableOrders in EA settings and start EA again!"; StopTrading = true;}
            
            //получение котировок            
            LmaxAsk = 0;
            LmaxBid = 0;
            LmaxBidCount = 0;
            char curr[1000];
            
            string Instrument = StringSubstr(Symbol(),0,6);
           
            if(ModeOfQuotes==0)
            {
               if(UseSymbCode==true)
                  {
                     StringToCharArray(SymbCode,curr);
                     getRatesSaxo(curr,LmaxAsk,LmaxBid);
                  }
                  else
                     {
                        StringToCharArray(Instrument,curr);
                        getRatesSaxo(curr,LmaxAsk,LmaxBid);
                     }
            }
                 
            if(ModeOfQuotes==1)
            {
               if(UseSymbCode==true)
                  {
                     StringToCharArray(SymbCode,curr);
                     getRatesLmax(curr,LmaxAsk,LmaxBid);
                  }
                  else
                     {
                        StringToCharArray(Instrument,curr);
                        getRatesLmax(curr,LmaxAsk,LmaxBid);
                     }
            }
            
            if(ModeOfQuotes==2)
            {
               if(UseSymbCode==true)
                  {
                     StringToCharArray(SymbCode,curr);
                     getRatesCQG(curr,LmaxAsk,LmaxBid);
                  }
                  else
                     {
                        StringToCharArray(Instrument,curr);
                        getRatesCQG(curr,LmaxAsk,LmaxBid);
                     }
            }
            
            if(ModeOfQuotes==3)
            {
               if(UseSymbCode==true)
                  {
                     StringToCharArray(SymbCode,curr);
                     getRatesRithmic(curr,LmaxAsk,LmaxBid);
                  }
                  else
                     {
                        StringToCharArray(Instrument,curr);
                        getRatesRithmic(curr,LmaxAsk,LmaxBid);
                     }
            }
                           
           if(SymbReturn==true)
              {
                 LmaxAsk=1/LmaxAsk;
                 LmaxBid=1/LmaxBid;
              }
               
            
            if(SymbCode==""&&UseSymbCode==true)
            {
            tradeLmax=false;
            LmaxAsk = 0;
            LmaxBid = 0;
            LastErrorText=LastErrorText+"Trade Was Stopped, SymbCode Error! Can change SymbCode to "+Symbol()+" in EA settings and start EA again!"+ "\n";
            StopTrading = true;
            }
            
            //проверка котировок №1
            if(LmaxBid==-1||LmaxBid<=0)  
            {
            tradeLmax=false; GapBuy=0;GapSell=0; LastErrorText=LastErrorText+ "Trade is disabled, error of "+QText+" data feed connection!Please check TradeMonitor programm!";
            ObjectDelete("QBid");   
            ObjectDelete("QText");
            ObjectDelete("QAsk");
            ObjectDelete("QAText");
            
            ObjectSetText("dfsymb", "Spread: 0 ", 9, "Arial", White);
            ObjectSetText("lmaxask", "Disconnected ", 9, "Arial", Red);
            ObjectSetText("lmaxbid", "Disconnected ", 9, "Arial", Red);
            
            ObjectSetString(0,"GapSell", OBJPROP_TEXT,DoubleToString(GapSell, 1));
            ObjectSetString(0,"GapBuy", OBJPROP_TEXT,DoubleToString(GapBuy, 1));
            
            }
      		if(LmaxAsk==-1||LmaxAsk<=0)  
      		{
      		tradeLmax=false; GapBuy=0;GapSell=0;
      		}
            
           
            
            pp = MarketInfo(Symbol(),MODE_POINT);
            if(AvtoSettings == false)
               {
               	if (pp == 0.001)   {pp=0.01;}
               	if (pp == 0.00001) {pp=0.0001;} 
            	}  	
            
            
         	Mt4Ask=MarketInfo(Symbol(),MODE_ASK);
            Mt4Bid=MarketInfo(Symbol(),MODE_BID);          
            spread2 = (NormalizeDouble(MarketInfo(Symbol(),MODE_ASK),_Digits)-NormalizeDouble(MarketInfo(Symbol(),MODE_BID),_Digits))/pp;
            //успеднение спреда
                  if (AvarageSpreadUse==true)
                     {
                        averageSpreadSum += spread2;
                        averageSpreadCount ++;
                        spread=NormalizeDouble((averageSpreadSum /averageSpreadCount),2);     
                     }
                     else {spread=spread2;}
                       
            LmaxBid=NormalizeDouble(LmaxBid,Digits);
            LmaxBidCount=LmaxBid;
            
            if(tradeLmax==true && LmaxBidOld > 0)
            {      
                  if(LmaxAskOld!=LmaxAsk)
                     {
                        if(LmaxAskOld!=0){LmaxGapAsk=(LmaxAsk-LmaxAskOld)/pp;}
                        LmaxAskOld=LmaxAsk;
                        NewLmaxAsk=true;
                     }
                                  
                  if(LmaxBidOld!=LmaxBid)
                     {
                        if(LmaxBidOld!=0){LmaxGapBid=(LmaxBid-LmaxBidOld)/pp;} 
                        if(LastLmaxTickTime>0) {LmaxTickTime = GetTickCount() - LastLmaxTickTime;}                      
                        LastLmaxTickTime = GetTickCount();                       
                        LmaxBidOld=LmaxBid;
                        NewLmaxBid=true;
                     } 
                     
                  if(Mt4AskOld!=Mt4Ask)
                     {
                        if(Mt4AskOld!=0){Mt4GapAsk=(Mt4Ask-Mt4AskOld)/pp;}
                        Mt4AskOld=Mt4Ask;
                        NewMt4Ask=true;
                     }
                     
                  if(Mt4BidOld!=Mt4Bid)
                     {
                        if(Mt4BidOld!=0){Mt4GapBid=(Mt4Bid-Mt4BidOld)/pp;}
                        Mt4BidOld=Mt4Bid;
                        NewMt4Bid=true;
                        if(LastMt4TickTime>0) {Mt4TickTime = GetTickCount() - LastMt4TickTime;}
                        LastMt4TickTime = GetTickCount();
                     }  
                                  
                  if(AvtoShiftBid==false)
                     {                 
                        if(SignalMode==0)
                           {
                              ShiftBidBuy=ShiftAsk;
                              ShiftBidSell=ShiftBid;
                              
                              LmaxAsk=LmaxAsk+ShiftAsk*pp;
                              LmaxBid=LmaxBid+ShiftBid*pp;
                              
                              GapBuy=(LmaxBid-Mt4Bid)/pp;                             
                              GapSell=(LmaxBid-Mt4Bid)/pp;    
                           }
                        
                        if(SignalMode==1)
                           {
                                                            
                              ShiftBidBuy=ShiftAsk;
                              ShiftBidSell=ShiftBid;
                              
                              LmaxAsk=LmaxAsk+ShiftAsk*pp;
                              LmaxBid=LmaxBid+ShiftBid*pp;
                              
                              GapBuy=(LmaxBid-Mt4Ask)/pp;                             
                              GapSell=(LmaxAsk-Mt4Bid)/pp;                                                         
                           }
                     }    
                  
                  if(AvtoShiftBid==true)
                     {
                        if(SignalMode==0)
                           {
                              averageAskSum += (LmaxBid - Mt4Bid )/pp;
                              averageAskCount ++;
                              GapBuy=(LmaxBid-Mt4Bid)/pp-(averageAskSum /averageAskCount);     
                              
                              averageBidSum += (LmaxBid-Mt4Bid)/pp;
                              averageBidCount ++;
                              GapSell=(LmaxBid-Mt4Bid)/pp-(averageBidSum /averageBidCount);
                              
                              ShiftBidBuy=averageAskSum /averageAskCount;
                              ShiftBidSell=averageBidSum /averageBidCount;
                              
                              LmaxAsk=LmaxAsk-ShiftBidBuy*pp;
                              LmaxBid=LmaxBid-ShiftBidSell*pp;                              
                           }
                        
                        if(SignalMode==1)
                           {
                              averageAskSum += (LmaxBid - Mt4Ask )/pp;
                              averageAskCount ++;
                              GapBuy=(LmaxBid-Mt4Ask)/pp-(averageAskSum /averageAskCount);     
                              
                              averageBidSum += (LmaxAsk-Mt4Bid)/pp;
                              averageBidCount ++;
                              GapSell=(LmaxAsk-Mt4Bid)/pp-(averageBidSum /averageBidCount);
                              
                              ShiftBidBuy=averageAskSum /averageAskCount;
                              ShiftBidSell=averageBidSum /averageBidCount;
                              
                              LmaxAsk=LmaxAsk-ShiftBidBuy*pp;
                              LmaxBid=LmaxBid-ShiftBidSell*pp;                           
                           }
                     }
           
                     
                     
                     if (CloseWhenPriceEqual == true)
                     {
                        if(SignalMode==0)
                              {
                              BuyClosePrice=LmaxBid;
                              SellClosePrice=LmaxBid;                                                 
                              }
                        if(SignalMode==1)
                              {
                              BuyClosePrice=LmaxBid;
                              SellClosePrice=LmaxAsk;
                              }
                     }
                  
                  
                  
                  GetLotSize();
            	              	   
            	   if(LotsSignalPower)
                  {
                  if(LmaxGapBid>=(MinLev)&&NewMt4Bid==true){TradeLot=Lots+Lots;}     
                  if(LmaxGapBid>=(MinLev)&&NewMt4Bid==false){TradeLot=Lots+Lots+Lots;}    
                  if(LmaxGapBid>=(MinLev)&&GapBuy>= (MinLev)*2&&GapBuy<= (MinLev)*3){TradeLot=Lots+Lots;}      
                  if(LmaxGapBid>=(MinLev)&&GapBuy>= (MinLev)*3){TradeLot=Lots+Lots+Lots;}
                  if(LmaxGapBid>=(MinLev)&&GapSell>= (MinLev)*2&&GapSell<= (MinLev)*3){TradeLot=Lots+Lots;}      
                  if(LmaxGapBid>=(MinLev)&&GapSell>= (MinLev)*3){TradeLot=Lots+Lots+Lots;}
                  }
                  else
                  {
                  TradeLot=Lots;
                  }
            	   
            	   }
            	   else 
            	   {
            	   GapBuy=0;
            	   GapSell=0;
            	   } 
            	   
                  //Расчет комиссии      
                  if(OrderCommissionCheck)
                    {       
                       MagicTest=180987;
                       double MinLot=MarketInfo(Symbol(),MODE_MINLOT);                  
                       if(TotalHistoryOrder()==0&&TotalOrderTest()==0)
                         {           
                            ticket=OrderSend(Symbol(),OP_BUY,MinLot,Ask,0,0,0,"OrderComissionCheck",MagicTest,0,MediumBlue);         
                            int select;
                            int close;
                            if (OrdersTotal() > 0) 
                             {
                  					for(int g=0;g<OrdersTotal();g++) 
                  					{
                  						select=OrderSelect(g, SELECT_BY_POS, MODE_TRADES);										
                  						if (OrderSymbol()==Symbol() && OrderMagicNumber() == MagicTest) 
                  						   {	                                                 
                  					         close=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),0);
                  						   }
                  					}
                  				}                                       
                         }
                       
                                 if(SymbolComissionInPips==0)
                                 {
                                   int select2;
                                   for(int g2=0;g2<OrdersHistoryTotal();g2++) 
                                    {
                     						select2=OrderSelect(g2, SELECT_BY_POS, MODE_HISTORY);										
                     						if (OrderSymbol()==Symbol() && OrderMagicNumber() == MagicTest) 
                     						   {
                     	                     SymbolComissionInPips= MathAbs(NormalizeDouble(OrderCommission() / (OrderLots()*MarketInfo(Symbol(),MODE_TICKVALUE)),0));
                     	                     SymbolComissionInPips=SymbolComissionInPips*Point/pp;                                					      
                     						   }
                  					   }
               					   }  
                    }
                    
                    if(AvtoSettings==false){SpreadK=1;}
                    else{SpreadK=spread;}
                    
                    if(ManualComission==true){SymbolComissionInPips=ComissionInPips;}
                    if(OrderCommissionCheck==false&&ManualComission==false){SymbolComissionInPips=0;}
                       
                    MinLev=NormalizeDouble((MinimumLevel*SpreadK+spread),1)+SymbolComissionInPips;
                    if (RealFixTP ==false) {FixTP2=FixTP*SpreadK+SymbolComissionInPips; }
                    if (RealFixSL ==false) {FixSL2=FixSL*SpreadK+spread;}
                    TakeProfit2=TakeProfit*SpreadK+SymbolComissionInPips;                                                   
                    StopLoss2=StopLoss*SpreadK+spread;
                   
                    
                    double LmaxSpread=(LmaxAsk-LmaxBid)/pp;
                    if (UseDynamicMinimumLevel) 
                    {
                    MinLev = MathAbs(spread - LmaxSpread)/2 + MathAbs(spread - LmaxSpread) * DynamicMinimumLevelSpreadCoefficient+SymbolComissionInPips;
                       if(AvtoSettings==true)
                       {
                          if (RealFixTP ==false) {FixTP2=(FixTP*MinLev+SymbolComissionInPips)-MinLev/3; }
                          if (RealFixSL ==false) {FixSL2=(FixSL*MinLev+spread)-MinLev/3;}
                          TakeProfit2=TakeProfit*MinLev+SymbolComissionInPips;                                                   
                          StopLoss2=StopLoss*MinLev;
                       }
                    }
                    
                  
                  if(TradeByPendingOrders)
                  {
                  if(DistanceForPendingOrdersInPips<=MarketInfo(Symbol(),MODE_STOPLEVEL)){DistancePending=MarketInfo(Symbol(),MODE_STOPLEVEL);}
                  else{DistancePending=DistanceForPendingOrdersInPips;}
                  
                  for (int z1=0; z1<OrdersTotal(); z1++) 
                      {
                  		if (OrderSelect(z1, SELECT_BY_POS, MODE_TRADES)) 
                  		   {
                     			if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
                     			{                   			
                     			int ordertime = TimeCurrent()-OrderOpenTime();
                              if(OrderType()==OP_BUYSTOP){if( ordertime > PendingOrdersLifeTime) {OrderDelete(OrderTicket(),Green); if(ShowLog) Print("!!! Pending Order BuyStop was canceled, becouse PendingOrdersLifeTime expired. " +"PendingOrdersLifeTime = " +PendingOrdersLifeTime + " seconds");}}
                              if(OrderType()==OP_SELLSTOP){if(ordertime > PendingOrdersLifeTime) {OrderDelete(OrderTicket(),Red);   if(ShowLog) Print("!!! Pending Order SellStop was canceled, becouse PendingOrdersLifeTime expired. " +"PendingOrdersLifeTime = " +PendingOrdersLifeTime + " seconds");}}
                              }
                           }
                       }
                     
                  }
                  
                  	   
                  ticketSell=0;
                  ticketBuy=0;
                  
                  //фильтр сигналов от мт4
                  SignalFromMt4 = false; 

                  //фильтр сигналов от мт4                 
                  if (NewMt4Bid==true&&MathAbs(Mt4GapBid) >= MinLev) {SignalFromMt4 == true;}
                  if (NewMt4Ask==true&&MathAbs(Mt4GapAsk) >= MinLev) {SignalFromMt4 == true;}
                  
                  Eq = AccountEquity();
                  int ordertime=0;  
                  int pendingordertime=0; 
                  int pendingorderticket=0;
                  bool stopseach=false;               
                  if(GapBuy >= (MinLev) && NewLmaxBid==true && LmaxBidOld>0 && TotalOrder(Magic)<NTrades && tradeLmax==true && GetTickCount() - LastOrderTime > OrdersOpenIntervalMs && SignalFromMt4==false)
                  {                    
                     if(GapBuy > MinGapForOpen && GapBuy > spread)
                     {
                     SignalBuy=true;
                     if (UseDynamicSlippage)
                        {
                         if(SignalMode==0) OrdOpenSlippage = MathAbs((LmaxBid - Mt4Bid - (MathAbs(spread - LmaxSpread)/2) * DynamicSlippageCoefficient - FixTP2)/pp);
                         if(SignalMode==1) OrdOpenSlippage = MathAbs((LmaxBid - Mt4Ask - (MathAbs(spread - LmaxSpread)/2) * DynamicSlippageCoefficient - FixTP2)/pp);                      
                        }
                     else { OrdOpenSlippage = OrderOpenSlippage;}
                     
                     if(ShowCommentsInOrder) 
            	      {
            	      Commento="G"+DoubleToString(GapBuy,1)+" Ma"+DoubleToString(Mt4Ask,5)+" "+OrderCommBuy+"b"+DoubleToString(LmaxBid,5);
                     Commento=StringSubstr(Commento, 0, 26);
            	      if (EAComment!="") {Commento=EAComment;}
            	      }
            	      else {Commento="";}
            	      
            	       
            	      
            	      if (CloseWhenPriceEqual) {Commento=DoubleToString(BuyClosePrice,Digits);}
            	      int Attempt = 0;
            	      while(Attempt <= MaxAttemptsForOpenOrder && !OrderSelect(ticketBuy,SELECT_BY_TICKET,MODE_TRADES) )
                                 {
                                    
                                    if(TradeSide==0||TradeSide==1)
                                       {
                                         if(TradeByPendingOrders)
                                            {
                                            PendingOrderOpenPriseBuy=MarketInfo(Symbol(),MODE_ASK)+DistancePending*pp;
                                            t1=GetTickCount(); 
                                            ticketBuy=OrderSend(Symbol(),OP_BUYSTOP,TradeLot,MarketInfo(Symbol(),MODE_ASK)+DistancePending*pp,0,0,0,Commento,Magic,0,MediumBlue);                                            
                                            }
                                            else
                                            {
                                            t1=GetTickCount();
                                            ticketBuy=OrderSend(Symbol(),OP_BUY,TradeLot,MarketInfo(Symbol(),MODE_ASK),MathAbs(OrdOpenSlippage),0,0,Commento,Magic,0,MediumBlue);
                                            }
                                             
                                       }
                                       
                                    if(!OrderSelect(ticketBuy,SELECT_BY_TICKET,MODE_TRADES))
                                       {
                                       Attempt++;
                                       if(ShowLog)Print("!!! Error Open Buy "+" Attempt = " +Attempt+" "+Symbol()+" "+GetErrorDescription(GetLastError()));
                                       }  
                                       else
                                       {                                          
                                       t2=GetTickCount()-t1;
                                       if(t1>0){LastOpenTime=t2;} else {LastOpenTime=0;}                                     
                                       LastGap=GapBuy;     
                                       LastOrderTime = GetTickCount();
                                       if(TradeByPendingOrders)
                                       {
                                       for (int z1=0; z1<OrdersTotal(); z1++) 
                                        {
                                    		if (OrderSelect(z1, SELECT_BY_POS, MODE_TRADES)) 
                                    		   {
                                       			if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
                                       			{                   			 
                                                   if(OrderType()==OP_BUYSTOP) 
                                                   {
                                                      OpenBuyPrice=DoubleToStr(OrderOpenPrice(),5);
                                                      SlippageBuy=(PendingOrderOpenPriseBuy-OpenBuyPrice)/pp;
                                                      if(ShowLog)Print("!!! Pending Order BuyStop "+ticketBuy +" Attempt = " +Attempt +", at " +DoubleToString(OrderOpenPrice(),Digits)+", Gap = "+ DoubleToStr(LastGap,2)+" pips, Pending Order Time = "+DoubleToString(LastOpenTime,0)+" ms, Slippage = "+DoubleToString(SlippageBuy,2)+" pips." +" Account Equity = "+ DoubleToString(Eq,2)+" " +AccountCurrency()); 
                                                      pendingordertime=OrderOpenTime();
                                                      pendingorderticket=OrderTicket();
                                                      
                                                      while((TimeCurrent()- pendingordertime) < PendingOrdersLifeTime && stopseach==false)
                                                      {
                                                      if(OrderSelect(pendingorderticket,SELECT_BY_TICKET,MODE_TRADES))
                                                         {
                                                         if(OrderType()==OP_BUY) 
                                                            {
                                                             OpenBuyPrice=DoubleToStr(OrderOpenPrice(),5);
                                                             SlippageBuy=(PendingOrderOpenPriseBuy-OpenBuyPrice)/pp;
                                                             if(ShowLog) Print("!!! Pending Order BuyStop "+pendingorderticket+" activated at price " +DoubleToString(OpenBuyPrice,Digits)+" PendingOrderSlippage = "+DoubleToString(SlippageBuy,2)+" pips");
                                                             stopseach=true;                                                     
                                                            }
                                                         else{stopseach=false;}                                                    
                                                         }
                                                      Sleep(100);
                                                      }                                                     
                                                   }
                                                
                                                }
                                             }
                                         }
                                         }                                
                                       if(OrderSelect(ticketBuy,SELECT_BY_TICKET,MODE_TRADES))
                                       {
                                       OpenBuyPrice=DoubleToStr(OrderOpenPrice(),5);
                                       if(TradeByPendingOrders==false){SlippageBuy=(Mt4Ask-OpenBuyPrice)/pp;}   
                                       }                                                                                                             
                                       LastOpenSlippage=SlippageBuy;                       
                                       if(RealFixTP) {FixTP2=GapBuy+LastOpenSlippage; if (FixTP2 < 0) {FixTP2=0.1;}  if(ShowLog)Print("RealFixTP = "+DoubleToString(FixTP2,2) +" pips");}
                                       if(RealFixSL) { if (LastOpenSlippage<0) {FixSL2=MathAbs(LastOpenSlippage);} if (LastOpenSlippage>=0) {FixSL2=FixSL*SpreadK+spread;}        if(ShowLog)Print("RealFixSL = "+DoubleToString(FixSL2,2) +" pips");}
                                       if(ShowLog && TradeByPendingOrders==false)Print("!!! Open Buy Order "+ticketBuy +" Attempt = " +Attempt +", at " +Symbol()+", Gap = "+ DoubleToStr(LastGap,2)+" pips, Open Time = "+DoubleToString(LastOpenTime,0)+" ms, Slippage = "+DoubleToString(LastOpenSlippage,2)+" pips." +" Account Equity = "+ DoubleToString(Eq,2)+" " +AccountCurrency());
                                       if(SoundSignal){PlaySound("ok.wav");}                                      
                                       if (StopTradingSlippage) {if((GapBuy+LastOpenSlippage) < FixTP2) {StopTradindSlip=true;}}                                     
                                       SlippageBuy=0;
                                       t2=0;
                                       t1=0;                          
                                       }                                 
                                                                      
                                 }             	      
                    }
                  }  
                   
                  if( GapSell <= -(MinLev)&&NewLmaxBid==true&&LmaxBidOld>0&&TotalOrder(Magic)<NTrades&&tradeLmax==true && GetTickCount() - LastOrderTime > OrdersOpenIntervalMs&&SignalFromMt4==false)
                  {                    
                     
                     if(MathAbs(GapSell) > MinGapForOpen && MathAbs(GapSell) > spread )
                     {
                     SignalSell=true;
                     
                     if (UseDynamicSlippage)
                        {
                         if(SignalMode==0) OrdOpenSlippage = (LmaxBid - Mt4Bid - (MathAbs(spread - LmaxSpread)/2) * DynamicSlippageCoefficient - FixTP2)/pp;
                         if(SignalMode==1) OrdOpenSlippage = (LmaxAsk - Mt4Bid - (MathAbs(spread - LmaxSpread)/2) * DynamicSlippageCoefficient - FixTP2)/pp;
                        
                        }
                     else { OrdOpenSlippage = OrderOpenSlippage;}
                     
                     if(ShowCommentsInOrder) 
            	      {
            	      Commento="G"+DoubleToString(GapSell,1)+" Mb"+DoubleToString(Mt4Bid,5)+" "+OrderCommSell+"b"+DoubleToString(LmaxBid,5);
                     Commento=StringSubstr(Commento, 0, 26);
            	      if (EAComment!="") {Commento=EAComment;}
            	      }
            	      else {Commento="";} 
            	      
            	      if (CloseWhenPriceEqual) {Commento=DoubleToString(SellClosePrice,Digits);}
            	      
            	      int Attempt2 = 0;
            	      while(Attempt2 <= MaxAttemptsForOpenOrder && !OrderSelect(ticketSell,SELECT_BY_TICKET,MODE_TRADES) )
                                 {                                                                       
                                    if(TradeSide==0||TradeSide==2)
                                       {
                                          if(TradeByPendingOrders)
                                             {
                                             PendingOrderOpenPriseSell=MarketInfo(Symbol(),MODE_BID)-DistancePending*pp;
                                             t3=GetTickCount();
                                             ticketSell=OrderSend(Symbol(),OP_SELLSTOP,TradeLot,MarketInfo(Symbol(),MODE_BID)-DistancePending*pp,0,0,0,Commento,Magic,0,Green);
                                             }
                                             else
                                             {
                                             t3=GetTickCount();
                                             ticketSell=OrderSend(Symbol(),OP_SELL,TradeLot,MarketInfo(Symbol(),MODE_BID),MathAbs(OrdOpenSlippage),0,0,Commento,Magic,0,Green);
                                             }                                         
                                       }
                                       if(!OrderSelect(ticketSell,SELECT_BY_TICKET,MODE_TRADES))
                                          {
                                          Attempt2++;                                          
                                          if(ShowLog)Print("!!! Error Open Sell Order "+" Attempt = " +Attempt2+", at " +Symbol() +" " +GetErrorDescription(GetLastError()));
                                          }
                                       else
                                          {                                        
                                          int t4=GetTickCount()-t3;
                                          if(t3>0){LastOpenTime=t4;} else {LastOpenTime=0;}
                                          LastGap=GapSell;                    
                                          LastOrderTime = GetTickCount();
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                       if(TradeByPendingOrders)
                                       {
                                       for (int z1=0; z1<OrdersTotal(); z1++) 
                                        {
                                    		if (OrderSelect(z1, SELECT_BY_POS, MODE_TRADES)) 
                                    		   {
                                       			if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
                                       			{                   			 
                                                   if(OrderType()==OP_SELLSTOP) 
                                                   {
                                                      OpenSellPrice=DoubleToStr(OrderOpenPrice(),5);
                                                      SlippageSell=(OpenSellPrice-PendingOrderOpenPriseSell)/pp;
                                                      if(ShowLog)Print("!!! Pending Order SellStop "+ticketSell +" Attempt = " +Attempt2 +", at " +DoubleToString(OrderOpenPrice(),Digits)+", Gap = "+ DoubleToStr(LastGap,2)+" pips, Pending Order Time = "+DoubleToString(LastOpenTime,0)+" ms, Slippage = "+DoubleToString(SlippageSell,2)+" pips." +" Account Equity = "+ DoubleToString(Eq,2)+" " +AccountCurrency()); 
                                                      pendingordertime=OrderOpenTime();
                                                      pendingorderticket=OrderTicket();
                                                      
                                                      while((TimeCurrent()- pendingordertime) < PendingOrdersLifeTime && stopseach==false)
                                                      {
                                                      if(OrderSelect(pendingorderticket,SELECT_BY_TICKET,MODE_TRADES))
                                                         {
                                                         if(OrderType()==OP_SELL) 
                                                            {
                                                             OpenSellPrice=DoubleToStr(OrderOpenPrice(),5);
                                                             SlippageSell=(OpenSellPrice-PendingOrderOpenPriseSell)/pp;
                                                             if(ShowLog) Print("!!! Pending Order SellStop "+pendingorderticket+" activated at price " +DoubleToString(OpenSellPrice,Digits)+" PendingOrderSlippage = "+DoubleToString(SlippageSell,2)+" pips");
                                                             stopseach=true;                                                     
                                                            }
                                                         else{stopseach=false;}                                                    
                                                         }
                                                      Sleep(100);
                                                      }                                                     
                                                   }
                                                
                                                }
                                             }
                                         }
                                         } 
                                          
                                          if(OrderSelect(ticketSell,SELECT_BY_TICKET,MODE_TRADES))
                                          {
                                          OpenSellPrice=DoubleToStr(OrderOpenPrice(),5);                                      
                                          if(TradeByPendingOrders==false){SlippageSell=(OpenSellPrice-Mt4Bid)/pp;}  
                                          }                                        
                                          LastOpenSlippage=SlippageSell;
                                          if(RealFixTP) {FixTP2=NormalizeDouble((MathAbs(GapSell)+LastOpenSlippage),2); if (FixTP2 < 0) {FixTP2=0.1;}  if(ShowLog)Print("RealFixTP = "+DoubleToString(FixTP2,2) +" pips");}
                                          if(RealFixSL) {if (LastOpenSlippage<0) {FixSL2=NormalizeDouble(LastOpenSlippage,2); } if (LastOpenSlippage>=0){FixSL2=FixSL*SpreadK+spread;}             if(ShowLog)Print("RealFixSL = "+DoubleToString(FixSL2,2) +" pips");}
                                          if(ShowLog && TradeByPendingOrders==false)Print("!!! Open Sell Order "+ticketSell+" Attempt = "+Attempt2 +", at "+Symbol()+", Gap = "+ DoubleToStr(LastGap,2)+" pips, Open Time = "+DoubleToString(LastOpenTime,0)+" ms, Slippage= "+DoubleToString(LastOpenSlippage,2)+" pips." +" Account Equity = "+ DoubleToString(Eq,2)+" " +AccountCurrency());
                                          if(SoundSignal){PlaySound("ok.wav");}
                                          
                                          if (StopTradingSlippage) {if((MathAbs(GapSell)+LastOpenSlippage) < FixTP2) {StopTradindSlip=true;}}
                                          
                                          SlippageSell=0;
                                          t3=0;
                                          t4=0;                                                                         
                                          }
                                 }  
                     
                                        
                  }
                   
             } 
           

            if (LastOpenTime>350){text1="Bad Ping"; col1 = Red;}
            if (LastOpenTime<=350){text1="Ping OK"; col1 = Lime;}
            
            if (LastOpenSlippage>=0){text2="Positive"; col2 = Lime;}
            if (LastOpenSlippage<0){text2="Negative"; col2 = Red;}  
            
            if (LastCloseTime>350){text3="Bad Ping"; col3 = Red;}
            if (LastCloseTime<=350){text3="Ping OK"; col3 = Lime;}
            
            if (LastCloseSlippage>=0){text4="Positive"; col4 = Lime;}
            if (LastCloseSlippage<0){text4="Negative"; col4 = Red;}   
            
            
            if(ShirtStopLoss)
            {
            StopLoss2=spread*ShirtStopLossK;
            }
         
            minshag = (MarketInfo(Symbol(),MODE_STOPLEVEL)*Point)/pp;
            if(StopLoss2<=minshag) {StopLoss2=minshag+spread; if(minshag==0){StopLoss2=spread*2;}}
            if(StopLoss2<=spread) {StopLoss2=spread*2; }        
                  
            if(TakeProfit2<=minshag) {TakeProfit2=minshag+spread; if(minshag==0){TakeProfit2=spread*2;}}
            if(TakeProfit2<=spread||TakeProfit2<=spread) {TakeProfit2=spread*2;}                
            
            
            bool CloseOk = true;
            
            if(MaxSpreadCloseUse==true){if(spread >= MaxSpreadClose){CloseOk==false; LastErrorText=LastErrorText+"Trade is disabled, Spread = "+DoubleToString(NormalizeDouble(MarketInfo(Symbol(),MODE_SPREAD),2),2)+" pips is big than MaxSpreadClose = " +DoubleToString(MaxSpreadClose,2)+" pips!"+" Can change MaxSpreadClose in EA settings and start EA again!";}}
            if(MinSpreadCloseUse==true){if(spread <= MinSpreadClose){CloseOk==false; LastErrorText=LastErrorText+"Trade is disabled, Spread = "+DoubleToString(NormalizeDouble(MarketInfo(Symbol(),MODE_SPREAD),2),2)+" pips is low than MinSpreadClose = " +DoubleToString(MinSpreadClose,2)+" pips!"+" Can change MinSpreadClose in EA settings and start EA again!";}}
      		  		
      		if(CloseOk)
      		{
      		if(UseFixedStopLossAndTakeProfit==true)    {EnterSLTP();}       		
            if (FixTP != 0) { if (DisableFixTP==false) {TrailingTPs();}}
      		if (FixSL != 0) { if (DisableFixSL==false) {TrailingSLs();}}
      		     		
      		if (CloseTimer>0){CloseTimerFunction();}     		
      		if (CloseWhenPriceEqual == true){CloseWhenPriceEqualFunction();}
      		
      		if(UseTrailingStop) {TrailingStopFunction();}
      		if(UseVirtualTrailingStop) {VirtualTrailingStopFunction();}
      		}
      		
      		
      		
      		
      		int stepstop=0;
      		while (TotalOrder(Magic) > 0 && StopTrading == true)
      		{ 
      		stepstop=stepstop+1;    		
      		if(UseFixedStopLossAndTakeProfit==true)    {EnterSLTP();}       		
            if (FixTP != 0) { if (DisableFixTP==false) {TrailingTPs();}}
      		if (FixSL != 0) { if (DisableFixSL==false) {TrailingSLs();}}
      		     		
      		if (CloseTimer>0){CloseTimerFunction();}     		
      		if (CloseWhenPriceEqual == true){CloseWhenPriceEqualFunction();}
      		
      		if(UseTrailingStop) {TrailingStopFunction();}
      		if(UseVirtualTrailingStop) {VirtualTrailingStopFunction();}
      		if(stepstop < 10){ObjectsDeleteAll(); Comment(""); ShowErrorsPanel(); Comment("    Wait of Closing of orders ......");}      		 
      		Sleep(100); 		
      		}
      		
      		if (TotalOrder(Magic) == 0 && StopTrading == true) 
      		{
      		if (ShowLog ) Print ("All orders was closed! Trading was stopped!"); Comment ("    All orders was closed! Trading was stopped!");
      		}
      		
      	   if(ShowGraf)
      	   {
      	    
      	   if(NewLmaxBid==true || NewMt4Bid==true)     	
      	   {
      	   if(LmaxBidOld > 0)
      	   {
      	   if(NewLmaxBid==true) {if(ShowPanel==false) {Comment("");ObjectsDeleteAll();   ShowWesternpipsInfoPanel(); ShowPanel=true; ShowErrorPanel=false;}}
      	   
            if (ShowPanel==true)
            {
            BarsCount=WindowBarsPerChart();
            Bar=WindowFirstVisibleBar();
            
            long chart_id=ChartID();
            string QTexta;
            if(ModeOfQuotes==0){QTexta="Saxo";}
            if(ModeOfQuotes==1){QTexta="Lmax";}
            if(ModeOfQuotes==2){QTexta="CQG";}
            if(ModeOfQuotes==3){QTexta="Rithmic";}
                    
           
            if(NewLmaxBid==true)
            {
            if(ObjectFind(chart_id,"QBid")==-1)
            {
            ObjectCreate(chart_id,"QBid", OBJ_HLINE,0,TimeCurrent(),LmaxBid);
            ObjectSet("QBid",OBJPROP_COLOR,ColorQuotes);
            }
      	   ObjectMove("QBid",0,TimeCurrent(),LmaxBid);
      	   
      	   }
      	   
      	   
      	   if(NewLmaxBid==true)
            {
            if(ObjectFind(chart_id,"QText")==-1)
      	   {
      	   ObjectCreate(chart_id,"QText",OBJ_TEXT,0, Time[0], High[0]+(10*Point));
      	   ObjectSetText("QText", QTexta+" Bid                                                 ", 10, "Arial", ColorQuotes);
      	   }
      	   ObjectMove(chart_id,"QText", 0, (Time[0]+(BarsCount-Bar)*60*Period()), LmaxBid-((LmaxAsk-LmaxBid)/pp)*pp);      	   
      	   }
      	   
      	   if(ShowAsk)
      	   {
      	   
      	   
            if(NewLmaxAsk==true)
            {
            if(ObjectFind(chart_id,"QAsk")==-1)
            {
            ObjectCreate(chart_id,"QAsk", OBJ_HLINE,0,TimeCurrent(),LmaxAsk);
            ObjectSet("QAsk",OBJPROP_COLOR,ColorQuotes);
      	   ObjectSet("QAsk",OBJPROP_STYLE,2);
            }
      	   ObjectMove(chart_id,"QAsk",0,TimeCurrent(),LmaxAsk);
      	   }
      	   
      	   
      	   if(NewLmaxAsk==true)
            {
            if(ObjectFind(chart_id,"QAText")==-1)
      	   {
      	   ObjectCreate(chart_id,"QAText",OBJ_TEXT,0, Time[0], High[0]+(10*Point));
      	   ObjectSetText("QAText", QTexta+" Ask                                                 ", 10, "Arial", ColorQuotes);
      	   }
      	   ObjectMove(chart_id,"QAText", 0, (Time[0]+(BarsCount-Bar)*60*Period()), LmaxAsk+(2*(LmaxAsk-LmaxBid)/pp)*pp);
      	   } 
      	   
      	   }
      	  
      	
      	   color ColorSigSellSaxo;
      	   int   SigSellSaxo = 14;
      	   int   xsell=60;
      	   int   xbuy=60;
            x=22;
            ColorSigSellSaxo = C'118,192,217';
      		if (SignalSell) 
      				{ 
      					if(tradeLmax)
                     {                    
      					SigSellSaxo = 20;
      					ColorSigSellSaxo = Yellow;
                     x=x-5;
                     xsell=75;                    
                     }
      				}
      	   if(GapSell<0) {xsell=xsell+8;}
      	   
      	  
      	   if(ObjectFind(chart_id,"GapSell")==-1)
      	   {
      	   ObjectCreate(chart_id,"GapSell",OBJ_LABEL,0, 0, 0);
      	   ObjectSetInteger(chart_id,"GapSell", OBJPROP_CORNER, 1);
      	   ObjectSetInteger(chart_id,"GapSell", OBJPROP_XDISTANCE, xsell);
      	   ObjectSetInteger(chart_id,"GapSell", OBJPROP_YDISTANCE, x+28);
      	   ObjectSetInteger(chart_id,"GapSell", OBJPROP_FONTSIZE, SigSellSaxo);
            ObjectSetString(chart_id,"GapSell", OBJPROP_FONT,"Arial");
            ObjectSetInteger(chart_id,"GapSell", OBJPROP_COLOR,ColorSigSellSaxo);
      	   }

      	   ObjectSetString(chart_id,"GapSell", OBJPROP_TEXT,DoubleToString(GapSell, 1));

            
                  	   
      	   color ColorSigBuySaxo;
      	   int   SigBuySaxo = 14;
      	   
            ColorSigBuySaxo = C'118,192,217';
      		if (SignalBuy) 
      				{
      					if(tradeLmax)
                     { 
      					SigBuySaxo = 20;
      					ColorSigBuySaxo = Yellow;
                     x=x-5;
                     xbuy=75; 
                     }
      				}
      	   if(GapBuy<0) {xbuy=xbuy+8;}
            
            if(ObjectFind(chart_id,"GapBuy")==-1)
      	   {
      	   ObjectCreate(chart_id,"GapBuy",OBJ_LABEL,0, 0, 0);
      	   ObjectSetInteger(chart_id,"GapBuy", OBJPROP_CORNER, 1);
      	   ObjectSetInteger(chart_id,"GapBuy", OBJPROP_XDISTANCE, xbuy);
      	   ObjectSetInteger(chart_id,"GapBuy", OBJPROP_YDISTANCE, x);
      	   ObjectSetInteger(chart_id,"GapBuy", OBJPROP_FONTSIZE, SigBuySaxo);
            ObjectSetString(chart_id,"GapBuy", OBJPROP_FONT,"Arial");
            ObjectSetInteger(chart_id,"GapBuy", OBJPROP_COLOR,ColorSigBuySaxo);
      	   }
            
      	   ObjectSetString(chart_id,"GapBuy", OBJPROP_TEXT,DoubleToString(GapBuy, 1));

            
            
            
      	   
      	   
      	   
      	   if(ShowPriceLabel)
               { 
      	      if( SignalBuy==true ||  SignalSell==true )
                  { 
                  long tc=TimeCurrent();							         
            		ObjectCreate(0,"LmaxBid"+DoubleToString(tc,0),OBJ_ARROW_LEFT_PRICE,0,TimeCurrent(),LmaxBid);
            		ObjectSetInteger(0,"LmaxBid"+DoubleToString(tc,0),OBJPROP_COLOR,ColorQuotes);	
           		
            		if( GapBuy >= (MinLev))
                  { 
                     ObjectCreate(0,"GapUp"+DoubleToString(tc,0),OBJ_ARROW_UP,0,TimeCurrent(),Mt4Ask-20*Point);
               		ObjectSetInteger(0,"GapUp"+DoubleToString(tc,0),OBJPROP_COLOR,LimeGreen);
               		
               		ObjectCreate(0,"Mt4Ask"+DoubleToString(tc,0),OBJ_ARROW_LEFT_PRICE,0,TimeCurrent(),Mt4Ask);
               		ObjectSetInteger(0,"Mt4Ask"+DoubleToString(tc,0),OBJPROP_COLOR,Red);
               		
               	   ObjectCreate(0,"SlippageBuy"+DoubleToString(tc,0),OBJ_TEXT,0, TimeCurrent(), Mt4Ask+LastOpenSlippage*Point);
               	   ObjectMove(0,"SlippageBuy"+DoubleToString(tc,0), 0, TimeCurrent(), Mt4Ask+LastOpenSlippage*Point);
               	   ObjectSetText("SlippageBuy"+DoubleToString(tc,0), "Slippage Buy= "+DoubleToString(LastOpenSlippage,2), 8, "Arial", Red);
            	              	   
                  }
                  
                  if(GapSell <= -(MinLev) )
                  { 
                     ObjectCreate(0,"GapDown"+DoubleToString(tc,0),OBJ_ARROW_DOWN,0,TimeCurrent(),Mt4Bid+20*Point);
               		ObjectSetInteger(0,"GapDown"+DoubleToString(tc,0),OBJPROP_COLOR,Red);
               		
               		ObjectCreate(0,"Mt4Bid"+DoubleToString(tc,0),OBJ_ARROW_LEFT_PRICE,0,TimeCurrent(),Mt4Bid);
               		ObjectSetInteger(0,"Mt4Bid"+DoubleToString(tc,0),OBJPROP_COLOR,Red);
               		
               	   ObjectCreate(0,"SlippageSell"+DoubleToString(tc,0),OBJ_TEXT,0, TimeCurrent(), Mt4Bid+LastOpenSlippage*Point);
               	   ObjectMove(0,"SlippageSell"+DoubleToString(tc,0), 0, TimeCurrent(), Mt4Bid+LastOpenSlippage*Point);
               	   ObjectSetText("SlippageSell"+DoubleToString(tc,0), "Slippage Sell= "+DoubleToString(LastOpenSlippage,2), 8, "Arial", Red);
                  }
                  }
               }
      	   
      	   
            if(ObjectFind(chart_id,"minlevel")==-1)
      	   {
            ObjectCreate("minlevel", OBJ_LABEL, 0, 0, 0);
            ObjectSet("minlevel", OBJPROP_CORNER, 4);
            ObjectSet("minlevel", OBJPROP_XDISTANCE, 8);
            ObjectSet("minlevel", OBJPROP_YDISTANCE, 65);
            }
            ObjectSetText("minlevel", "Minimum Level: " +DoubleToString(MinLev,2), 9, "Arial", Lime);
            
            if(ObjectFind(chart_id,"fixtp")==-1)
      	   {
            ObjectCreate("fixtp", OBJ_LABEL, 0, 0, 0);
            ObjectSet("fixtp", OBJPROP_CORNER, 4);
            ObjectSet("fixtp", OBJPROP_XDISTANCE, 8);
            ObjectSet("fixtp", OBJPROP_YDISTANCE, 80);
            }
            ObjectSetText("fixtp", "FixTP: "+DoubleToString(FixTP2,2), 9, "Arial", White);
            
            if(ObjectFind(chart_id,"fixsl")==-1)
      	   {
            ObjectCreate("fixsl", OBJ_LABEL, 0, 0, 0);
            ObjectSet("fixsl", OBJPROP_CORNER, 4);
            ObjectSet("fixsl", OBJPROP_XDISTANCE, 8);
            ObjectSet("fixsl", OBJPROP_YDISTANCE, 95);
            }
            ObjectSetText("fixsl", "FixSL: "+DoubleToString(FixSL2,2), 9, "Arial", White);
            
            if(ObjectFind(chart_id,"sl")==-1)
      	   {
            ObjectCreate("sl", OBJ_LABEL, 0, 0, 0);
            ObjectSet("sl", OBJPROP_CORNER, 4);
            ObjectSet("sl", OBJPROP_XDISTANCE, 8);
            ObjectSet("sl", OBJPROP_YDISTANCE, 110);
            }
            ObjectSetText("sl", "StopLoss: "+DoubleToString(StopLoss2,2), 9, "Arial", White);
            
            if(ObjectFind(chart_id,"tp")==-1)
      	   {
            ObjectCreate("tp", OBJ_LABEL, 0, 0, 0);
            ObjectSet("tp", OBJPROP_CORNER, 4);
            ObjectSet("tp", OBJPROP_XDISTANCE, 8);
            ObjectSet("tp", OBJPROP_YDISTANCE, 125);
            }
            ObjectSetText("tp", "TakeProfit: "+DoubleToString(TakeProfit2,2), 9, "Arial", White);
            
            //risk managment
            
            if(ObjectFind(chart_id,"RiskPersent")==-1)
      	   {
            ObjectCreate("RiskPersent", OBJ_LABEL, 0, 0, 0);
            ObjectSet("RiskPersent", OBJPROP_CORNER, 4);
            ObjectSet("RiskPersent", OBJPROP_XDISTANCE, 8);
            ObjectSet("RiskPersent", OBJPROP_YDISTANCE, 165);
            }
            ObjectSetText("RiskPersent","RiskPercent: " +DoubleToString(RiskPercent,0), 9, "Arial", White);
            
            if(ObjectFind(chart_id,"Lots")==-1)
      	   {
            ObjectCreate("Lots", OBJ_LABEL, 0, 0, 0);
            ObjectSet("Lots", OBJPROP_CORNER, 4);
            ObjectSet("Lots", OBJPROP_XDISTANCE, 8);
            ObjectSet("Lots", OBJPROP_YDISTANCE, 180);
            }
            ObjectSetText("Lots","Lots: " +TradeLot, 9, "Arial", Lime);
            
            if(ObjectFind(chart_id,"max_Lots")==-1)
      	   {
            ObjectCreate("max_Lots", OBJ_LABEL, 0, 0, 0);
            ObjectSet("max_Lots", OBJPROP_CORNER, 4);
            ObjectSet("max_Lots", OBJPROP_XDISTANCE, 8);
            ObjectSet("max_Lots", OBJPROP_YDISTANCE, 195);
            }
            ObjectSetText("max_Lots","Max Lots: " +DoubleToString(max_Lots,3), 9, "Arial", White);
            
            if(ObjectFind(chart_id,"RiskDeposit")==-1)
      	   {
            ObjectCreate("RiskDeposit", OBJ_LABEL, 0, 0, 0);
            ObjectSet("RiskDeposit", OBJPROP_CORNER, 4);
            ObjectSet("RiskDeposit", OBJPROP_XDISTANCE, 8);
            ObjectSet("RiskDeposit", OBJPROP_YDISTANCE, 210);
            }
            ObjectSetText("RiskDeposit","Deposit Stop if Loss: " +DoubleToString(DepositStop,0), 9, "Arial", White);
            
            if(ObjectFind(chart_id,"DepositStopIfProfit")==-1)
      	   {
            ObjectCreate("DepositStopIfProfit", OBJ_LABEL, 0, 0, 0);
            ObjectSet("DepositStopIfProfit", OBJPROP_CORNER, 4);
            ObjectSet("DepositStopIfProfit", OBJPROP_XDISTANCE, 8);
            ObjectSet("DepositStopIfProfit", OBJPROP_YDISTANCE, 225);
            }
            ObjectSetText("DepositStopIfProfit","Deposit Stop If Profit: " +DoubleToString(DepositStopIfProfit,0), 9, "Arial", White);
                   
            //fast data feed 
            if(ObjectFind(chart_id,"datafeed")==-1)
      	   {                      
            ObjectCreate("datafeed", OBJ_LABEL, 0, 0, 0);
            ObjectSet("datafeed", OBJPROP_CORNER, 4);
            ObjectSet("datafeed", OBJPROP_XDISTANCE, 210);
            ObjectSet("datafeed", OBJPROP_YDISTANCE, 100);
            }
            ObjectSetText("datafeed", QText, 9, "Arial", ColorQuotes);
            
            if(ObjectFind(chart_id,"lmaxsymb")==-1)
      	   {
            ObjectCreate("lmaxsymb", OBJ_LABEL, 0, 0, 0);
            ObjectSet("lmaxsymb", OBJPROP_CORNER, 4);
            ObjectSet("lmaxsymb", OBJPROP_XDISTANCE, 210);
            ObjectSet("lmaxsymb", OBJPROP_YDISTANCE, 115);
            }
            ObjectSetText("lmaxsymb", SymbCode, 9, "Arial", White);
            
            if(ObjectFind(chart_id,"dfsymb")==-1)
      	   {                    
            ObjectCreate("dfsymb", OBJ_LABEL, 0, 0, 0);
            ObjectSet("dfsymb", OBJPROP_CORNER, 4);
            ObjectSet("dfsymb", OBJPROP_XDISTANCE, 210);
            ObjectSet("dfsymb", OBJPROP_YDISTANCE, 130);
            }
            ObjectSetText("dfsymb", "Spread: "+DoubleToString((LmaxAsk-LmaxBid)/pp,2), 9, "Arial", White);
            
            if(ObjectFind(chart_id,"lmaxask")==-1)
      	   {
            ObjectCreate("lmaxask", OBJ_LABEL, 0, 0, 0);
            ObjectSet("lmaxask", OBJPROP_CORNER, 4);
            ObjectSet("lmaxask", OBJPROP_XDISTANCE, 210);
            ObjectSet("lmaxask", OBJPROP_YDISTANCE, 145);
            }
            ObjectSetText("lmaxask", lmaxtexta+" Ask: "+DoubleToString(LmaxAsk,Digits), 9, "Arial", White);
            
            if(ObjectFind(chart_id,"lmaxbid")==-1)
      	   {
            ObjectCreate("lmaxbid", OBJ_LABEL, 0, 0, 0);
            ObjectSet("lmaxbid", OBJPROP_CORNER, 4);
            ObjectSet("lmaxbid", OBJPROP_XDISTANCE, 210);
            ObjectSet("lmaxbid", OBJPROP_YDISTANCE, 160);
            }
            ObjectSetText("lmaxbid", lmaxtexta+" Bid: "+DoubleToString(LmaxBid,Digits), 9, "Arial", White);
            
            
            //slow data feed
            if(ObjectFind(chart_id,"broker")==-1)
      	   {
            ObjectCreate("broker", OBJ_LABEL, 0, 0, 0);
            ObjectSet("broker", OBJPROP_CORNER, 4);
            ObjectSet("broker", OBJPROP_XDISTANCE, 360);
            ObjectSet("broker", OBJPROP_YDISTANCE, 100);
            }
            ObjectSetText("broker",AccountInfoString(ACCOUNT_COMPANY), 9, "Arial", Yellow);
            
            if(ObjectFind(chart_id,"mt4symb")==-1)
      	   {
            ObjectCreate("mt4symb", OBJ_LABEL, 0, 0, 0);
            ObjectSet("mt4symb", OBJPROP_CORNER, 4);
            ObjectSet("mt4symb", OBJPROP_XDISTANCE, 360);
            ObjectSet("mt4symb", OBJPROP_YDISTANCE, 115);
            }
            ObjectSetText("mt4symb", Symbol(), 9, "Arial", White);
            
            if(ObjectFind(chart_id,"spread")==-1)
      	   {
            ObjectCreate("spread", OBJ_LABEL, 0, 0, 0);
            ObjectSet("spread", OBJPROP_CORNER, 4);
            ObjectSet("spread", OBJPROP_XDISTANCE, 360);
            ObjectSet("spread", OBJPROP_YDISTANCE, 130);
            }
            ObjectSetText("spread","Spread: " +DoubleToString(spread,2), 9, "Arial", White);
            
            if(ObjectFind(chart_id,"mt4ask")==-1)
      	   {
            ObjectCreate("mt4ask", OBJ_LABEL, 0, 0, 0);
            ObjectSet("mt4ask", OBJPROP_CORNER, 4);
            ObjectSet("mt4ask", OBJPROP_XDISTANCE, 360);
            ObjectSet("mt4ask", OBJPROP_YDISTANCE, 145);
            }
            ObjectSetText("mt4ask", "Mt4 Ask: "+DoubleToString(Mt4Ask,Digits), 9, "Arial", White);
            
            if(ObjectFind(chart_id,"mt4bid")==-1)
      	   {
            ObjectCreate("mt4bid", OBJ_LABEL, 0, 0, 0);
            ObjectSet("mt4bid", OBJPROP_CORNER, 4);
            ObjectSet("mt4bid", OBJPROP_XDISTANCE, 360);
            ObjectSet("mt4bid", OBJPROP_YDISTANCE, 160);
            }
            ObjectSetText("mt4bid", "Mt4 Bid: "+DoubleToString(Mt4Bid,Digits), 9, "Arial", White);
            
            if(ObjectFind(chart_id,"ExOpen")==-1)
      	   {
            ObjectCreate("ExOpen", OBJ_LABEL, 0, 0, 0);
            ObjectSet("ExOpen", OBJPROP_CORNER, 4);
            ObjectSet("ExOpen", OBJPROP_XDISTANCE, 210);
            ObjectSet("ExOpen", OBJPROP_YDISTANCE, 220);
            }
            ObjectSetText("ExOpen", "Open Order Execution Time: "+DoubleToString(LastOpenTime,0)+" ms", 9, "Arial", White);  
            
            if(ObjectFind(chart_id,"ExOpen1")==-1)
      	   {
            ObjectCreate("ExOpen1", OBJ_LABEL, 0, 0, 0);
            ObjectSet("ExOpen1", OBJPROP_CORNER, 4);
            ObjectSet("ExOpen1", OBJPROP_XDISTANCE, 435);
            ObjectSet("ExOpen1", OBJPROP_YDISTANCE, 220);
            }
            ObjectSetText("ExOpen1", text1, 9, "Arial", col1);    
            
            if(ObjectFind(chart_id,"ExOpen11")==-1)
      	   {
            ObjectCreate("ExOpen11", OBJ_LABEL, 0, 0, 0);
            ObjectSet("ExOpen11", OBJPROP_CORNER, 4);
            ObjectSet("ExOpen11", OBJPROP_XDISTANCE, 435);
            ObjectSet("ExOpen11", OBJPROP_YDISTANCE, 235);
            }
            ObjectSetText("ExOpen11", text2, 9, "Arial", col2);   
            
            if(ObjectFind(chart_id,"ExOpen12")==-1)
      	   {
            ObjectCreate("ExOpen12", OBJ_LABEL, 0, 0, 0);
            ObjectSet("ExOpen12", OBJPROP_CORNER, 4);
            ObjectSet("ExOpen12", OBJPROP_XDISTANCE, 435);
            ObjectSet("ExOpen12", OBJPROP_YDISTANCE, 250);
            }
            ObjectSetText("ExOpen12", text3, 9, "Arial", col3);   
            
            if(ObjectFind(chart_id,"ExOpen13")==-1)
      	   {
            ObjectCreate("ExOpen13", OBJ_LABEL, 0, 0, 0);
            ObjectSet("ExOpen13", OBJPROP_CORNER, 4);
            ObjectSet("ExOpen13", OBJPROP_XDISTANCE, 435);
            ObjectSet("ExOpen13", OBJPROP_YDISTANCE, 265);
            }
            ObjectSetText("ExOpen13", text4, 9, "Arial", col4);       
           
            if(ObjectFind(chart_id,"SlOpen")==-1)
      	   {
            ObjectCreate("SlOpen", OBJ_LABEL, 0, 0, 0);
            ObjectSet("SlOpen", OBJPROP_CORNER, 4);
            ObjectSet("SlOpen", OBJPROP_XDISTANCE, 210);
            ObjectSet("SlOpen", OBJPROP_YDISTANCE, 235);
            }
            ObjectSetText("SlOpen", "Open Order Slippage: "+DoubleToString(LastOpenSlippage,2)+" pips", 9, "Arial", White); 
            
            if(ObjectFind(chart_id,"ExClose")==-1)
      	   {
            ObjectCreate("ExClose", OBJ_LABEL, 0, 0, 0);
            ObjectSet("ExClose", OBJPROP_CORNER, 4);
            ObjectSet("ExClose", OBJPROP_XDISTANCE, 210);
            ObjectSet("ExClose", OBJPROP_YDISTANCE, 250);
            }
            ObjectSetText("ExClose", "Close Order Execution Time: "+DoubleToString(LastCloseTime,0) +" ms", 9, "Arial", White);      
           
            if(ObjectFind(chart_id,"SlClose")==-1)
      	   {
            ObjectCreate("SlClose", OBJ_LABEL, 0, 0, 0);
            ObjectSet("SlClose", OBJPROP_CORNER, 4);
            ObjectSet("SlClose", OBJPROP_XDISTANCE, 210);
            ObjectSet("SlClose", OBJPROP_YDISTANCE, 265);
            }
            ObjectSetText("SlClose", "Close Order Slippage: "+DoubleToString(LastCloseSlippage,2)+" pips", 9, "Arial", White);       
         
            
            //обработчик ошибок
            if(ObjectFind(chart_id,"er")==-1)
      	   {
      	   ObjectCreate("er", OBJ_LABEL, 0, 0, 0);
            ObjectSet("er", OBJPROP_CORNER, 2);
            ObjectSet("er", OBJPROP_XDISTANCE, 5);
            ObjectSet("er", OBJPROP_YDISTANCE, 10);
            }
            ObjectSetText("er", LastErrorText, 7, "Arial", Red);  
      	   //конец
         
         
         
         }
         }
         }
         if(NewLmaxBid==false)        
         {
         
            //if(NewTickDel==true && LmaxTickTime !=0) 
                     //{
                     //Print("2");
                     
                     //if(ShowPanel ==false) { ObjectsDeleteAll(); ShowWesternpipsInfoPanel();}
                     //NewTickDel=false;
                     //} 
            if(ShowPanel==false) {Comment("Wait tick from " +QText+" .....");}
            
            int timestop = GetTickCount() - LastLmaxTickTime;  
            if( timestop > 180000 && LmaxTickTime !=0 )
               {
               if(ShowErrorPanel==false) 
               { 
               ObjectsDeleteAll();  
               Comment("");
               }
               LastErrorText =LastErrorText +"Old ticks, Wait new tick from " +QText+"! Last tick from "+QText+" was " + timestop+" ms ago!";
               ShowErrorsPanel();
               ShowErrorPanel=true;  
               //NewTickDel=true; 
               ShowPanel=false;                  
               
               if(timestop > 600000){StopTrading=true; LastErrorText=QText+" disconnected, Old ticks"; } 
               Sleep(100); 
               }
               OldTickCount=OldTickCount+1;
               if(LastLmaxTickTime==0&&OldTickCount>2000)
               {
               if(ShowErrorPanel==false) 
               {       
               ObjectsDeleteAll(); 
               Comment("");              
               LastErrorText =LastErrorText +"Old tick, Wait new tick from " +QText+"!";
               ShowErrorsPanel();
               ShowErrorPanel=true;  
               //NewTickDel=true;
               ShowPanel=false;
               } 
               Sleep(100);               
               } 
         }
         
         }
         else
         {
         
         int timestop2 = GetTickCount() - LastLmaxTickTime;
            if(LastLmaxTickTime==0)
               {
               ObjectSetText("ConnectionStatusText", QText +" disconnected!", 8, "Arial", White);   
               ObjectSet("ConnectionStatus", OBJPROP_COLOR, Red);  
               Sleep(100);
               }
            
            if( timestop2 > 30000 && LmaxTickTime !=0 )
               {
               ObjectSetText("ConnectionStatusText", QText +" disconnected!", 8, "Arial", White);   
               ObjectSet("ConnectionStatus", OBJPROP_COLOR, Red);  
               Sleep(100);      
               }
         
         }
            
            LmaxBidOld=LmaxBidCount;          
            
            TimeEnd=GetTickCount();         
            if (UseTerminalSleepInMilliseconds) {Sleep(TerminalSleepInMilliseconds);}         
            ReadCodeTimeEnd = GetTickCount() - ReadCodeTime;            
            ReadCodeTimeSumm = ReadCodeTimeSumm + ReadCodeTimeEnd;
            if(ReadCodeStep>0)
            { 
            AvReadCodeTime = ReadCodeTimeSumm/ReadCodeStep;           
            }
            
            if(ShowPanel==true && ShowGraf)
            { 
            
            if(NewLmaxBid ==true || NewMt4Bid ==true) 
            {
            comm11="";
            comm11 = "\n"+"\n"+"\n"+"\n"+"\n"+"\n"+"\n"+"\n"+"\n"+"\n"+"\n"+"\n"+"\n"+"\n"+"\n"+"\n"+"\n"+"\n"+"\n" +comm11+" ReadCodeTime: " +AvReadCodeTime +" ms"+"\n";
            comm11=comm11+ " Tick From "+QText +" was "+LmaxTickTime+" ms ago"+"\n"
            + " " +"Tick From Mt4 was "+Mt4TickTime+" ms ago"+"\n";}
            Comment(comm11);
            }
            
            
            ReadCodeStep=ReadCodeStep+1;
            if(ReadCodeStep == 100) 
            {
             ReadCodeStep=0;
             ReadCodeTime=0;
             ReadCodeTimeEnd=0;
             ReadCodeTimeSumm=0; 
             AvReadCodeTime =0; 
            }
            
            
            

            if(LactCheckTime>0) {CheckNextTime=GetTickCount()-LactCheckTime;}
            
            if(CheckNextTime>100 || LactCheckTime==0)
            {
            if(ShowGraf==false && tradeLmax==true && NewLmaxBid ==true)
            {
            color colstep;
            if(StepCheck>1) {StepCheck=0;}
            if(StepCheck==0) {colstep=Lime; ObjectSetText("ConnectionStatus", "n", 12, "Webdings");   }
            if(StepCheck==1) {colstep=LimeGreen; ObjectSetText("ConnectionStatus", "n", 10, "Webdings");   }
            ObjectSetText("ConnectionStatusText", QText +" is connected successfully!", 8, "Arial", White);    
            ObjectSet("ConnectionStatus", OBJPROP_COLOR, colstep);            
            LactCheckTime=GetTickCount(); 
            StepCheck=StepCheck+1;
            }           
            }
            
            
            
            
            
            
            NewLmaxAsk = false;
            NewLmaxBid = false;
            NewMt4Ask  = false;
            NewMt4Bid  = false; 
                        
      } 
   
  }
  
  
double GetLotSize () 
{
	double eq,ll,kol;
	double koli;
	
	   margin = MarketInfo(Symbol(),MODE_MARGINREQUIRED);
	   LOTSTEP = MarketInfo(Symbol(),MODE_LOTSTEP);
	   MINLOT = MarketInfo(Symbol(),MODE_MINLOT);
	   MAXLOT = MarketInfo(Symbol(),MODE_MAXLOT); 
	
	if (RiskPercent>0) 
	 {
	  if(margin!=0)
   	  {
      	  if(LotsCount==0)
      	  {
      	  eq = NormalizeDouble((NormalizeDouble(AccountBalance()/margin,2) * RiskPercent)/100,2);
      	  }
      	  if(LotsCount==1)
      	  {
      	  eq = NormalizeDouble((NormalizeDouble(AccountEquity()/margin,2) * RiskPercent)/100,2);
      	  }
      		if(LOTSTEP!=0)
      		{
         		ll = eq;
         		koli = eq/LOTSTEP;
         		kol = koli*LOTSTEP;
         		dLot = kol;
         		if (dLot<MINLOT) dLot=MINLOT;
         		if (dLot>MAXLOT) dLot=MAXLOT;
         		Lots = dLot;
      	   }
      	   else {Lots=MarketInfo(Symbol(),MODE_MINLOT);}
   	   }
   	   else {Lots=MarketInfo(Symbol(),MODE_MINLOT);}
	}
	
	
	if(LOTSTEP!=0)
         	{
         	Lots = MathRound(Lots/LOTSTEP)*LOTSTEP;
         	}
         	else {Lots=MarketInfo(Symbol(),MODE_MINLOT);}
	
	if (Lots>max_Lots) Lots=max_Lots;
	if (Lots<MarketInfo(Symbol(),MODE_MINLOT)) Lots=MarketInfo(Symbol(),MODE_MINLOT);
	if (Lots>MarketInfo(Symbol(),MODE_MAXLOT)) Lots=MarketInfo(Symbol(),MODE_MAXLOT);
	
	return(Lots);
	
}

int TotalOrder(int OrderMagic)
{
int total=0;
bool sel2;
				if (OrdersTotal() > 0) {
					for(int cnt2=0;cnt2<OrdersTotal();cnt2++) {
						sel2=OrderSelect(cnt2, SELECT_BY_POS, MODE_TRADES);										
						if (OrderSymbol()==Symbol() && OrderMagicNumber() == OrderMagic) {total++;}
					}
				}
				return (total);
}

int TrailingTPs() {  
double   PriceClose=0;
int      t5;  
bool     cl=0; 
int      Attempt3 = 0;
double   EqFinish = 0;
	for (int i2=0; i2<OrdersTotal(); i2++) {
		if (OrderSelect(i2, SELECT_BY_POS, MODE_TRADES)) {
			if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) {		
			if((TimeCurrent()-OrderOpenTime())>=CloseOrderDelay)
			{	
					if (OrderType()==OP_BUY) {											   									
						bid_pr = (MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice());
						fx = FixTP2*pp;
						fx = NormalizeDouble(fx,_Digits);

						if (bid_pr>=fx) 
						{						
							 PriceCloseBuy=MarketInfo(OrderSymbol(),MODE_BID);
							 CloseTicket=OrderTicket();						 

      							 while(Attempt3 <= MaxAttemptsForCloseOrder && cl ==false )
                                 { 
                                 
                                 for (int a1=0; a1<OrdersTotal(); a1++) 
							            {
                                    if (OrderSelect(a1, SELECT_BY_POS, MODE_TRADES)) 
                                    { 
                                       if (OrderTicket()==CloseTicket) 
                                         {
                                 t5=GetTickCount();
                                 cl=OrderClose(CloseTicket,OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),OrderCloseSlippage,Green);                                     
                                 if(cl==false)
                                    {                                  
                                    if(ShowLog)Print("!!! FixTP Error Close Buy Order "+OrderTicket()+" Attempt = " +Attempt3+" "+Symbol()+" "+GetErrorDescription(GetLastError()));
                                    } 
                                 if(cl==true) {break;}                                                                                              
                                 }
                                 }
                                 }
                                 Attempt3++;
                                 }		 
							 if (cl==true)
							 {
							 					 						 
							   for (int i21=0; i21<OrdersHistoryTotal(); i21++) 
							      {
   		                     if (OrderSelect(i21, SELECT_BY_POS, MODE_HISTORY)) 
   		                       {
   			                        if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
   			                        {
      			                        if(OrderTicket()==CloseTicket)
      			                          {     			                          
      			                          //Tic3 = StringSubstr(DoubleToString(CloseTicket),StringLen(CloseTicket) - 3,3);
      			                          //EqFinish=AccountEquity()-EqTicket[Tic3];
      			                          LastCloseTime=GetTickCount()-t5;	
      			                          CloseBuyPr=DoubleToStr(OrderClosePrice(),5);
                                         CloseBuySlippage=(CloseBuyPr - PriceCloseBuy)/pp;
                                         if(ShowLog)Print("!!! FixTP Buy Order " +CloseTicket+", Slippage = " +DoubleToStr(CloseBuySlippage,2)+" pips, Close Time = " +LastCloseTime + " ms, Profit = " +NormalizeDouble(bid_pr/pp,2)+" pips." +" Account Equity= " +NormalizeDouble(AccountEquity(),2) +" " +AccountCurrency());
                  							  if(SoundSignal){PlaySound("ok.wav");}
                  							  LastCloseSlippage=CloseBuySlippage;
                  							  PriceCloseBuy=0;	
                  							  CloseTicket=0;
                  							  CloseBuyPr=0;
                  							  CloseBuySlippage=0;	
                  							  t5=0;	
      			                          }
   			                        }
   			                    }
			                  }		
							
							}								
					   }
					}
					if (OrderType()==OP_SELL) {
						ask_pr = OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK);
						fx = FixTP2*pp;
						fx = NormalizeDouble(fx,_Digits);
						
										
						if (ask_pr>=fx) 
						{							
							 PriceCloseSell=MarketInfo(OrderSymbol(),MODE_ASK);	
							 CloseTicketSell=OrderTicket();					 
							 
   							 while(Attempt3 <= MaxAttemptsForCloseOrder && cl ==false )
                                 {
                                 
                                 for (int a1=0; a1<OrdersTotal(); a1++) 
							            {
                                    if (OrderSelect(a1, SELECT_BY_POS, MODE_TRADES)) 
                                    { 
                                       if (OrderTicket()==CloseTicketSell) 
                                         {
                                          t5=GetTickCount(); 
                                          cl=OrderClose(CloseTicketSell,OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),OrderCloseSlippage,Red);                                   
                                          if(cl==false)
                                            {                                  
                                            if(ShowLog)Print("!!! FixTP Error Close Sell Order "+OrderTicket()+" Attempt = " +Attempt3+" "+Symbol()+" "+GetErrorDescription(GetLastError()));
                                            }
                                            if(cl==true) {break;}                                                                                                                                        
                                          }
                                    }
                                 }
                                 Attempt3++;
                                 }
							 if (cl==true)
							 {
							 						
							 for (int i211=0; i211<OrdersHistoryTotal(); i211++) 
							    {
		                     if (OrderSelect(i211, SELECT_BY_POS, MODE_HISTORY)) 
		                       {
			                        if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
			                          {
   			                        if(OrderTicket()==CloseTicketSell)
   			                          {	
   			                          //Tic3 = StringSubstr(DoubleToString(CloseTicketSell),StringLen(CloseTicketSell) - 3,3);
      			                       //EqFinish=AccountEquity()-EqTicket[Tic3];
      			                       LastCloseTime=GetTickCount()-t5;  
   			                          CloseSellPr=DoubleToStr(OrderClosePrice(),5);
                                      CloseSellSlippage=(PriceCloseSell-CloseSellPr)/pp;
                                      if(ShowLog)Print("!!! FixTP Sell Order " +CloseTicketSell+", Slippage =  " +DoubleToStr(CloseSellSlippage,2)+" pips, Close Time = " +LastCloseTime + " ms, Profit = " +NormalizeDouble(ask_pr/pp,2)+" pips." +" Account Equity= " +NormalizeDouble(AccountEquity(),2) +" " +AccountCurrency());	
               							  if(SoundSignal){PlaySound("ok.wav");}
               							  LastCloseSlippage=CloseSellSlippage;
               							  PriceCloseSell=0;	
               							  CloseTicketSell=0;
               							  CloseSellPr=0;
               							  CloseSellSlippage=0;
               							  t5=0;
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
	   }
	return(rez);
}

void TrailingSLs() {

	 double PriceClose=0;
	 int cl,t6,Attempt =0;
	 cl=false;
	 double   EqStart  = 0;
    double   EqFinish = 0;
	 for (int i2=0; i2<OrdersTotal(); i2++) {
		if (OrderSelect(i2, SELECT_BY_POS, MODE_TRADES)) {
			if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) {
			if((TimeCurrent()-OrderOpenTime())>=CloseOrderDelay)
			{	
					if (OrderType()==OP_BUY) {
						bid_pr = (OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_BID));
						bid_pr = NormalizeDouble(bid_pr,_Digits);
						fx = FixSL2*pp;
						fx = NormalizeDouble(fx,_Digits);
						if (bid_pr>=fx) {
							{
							PriceCloseBuy=MarketInfo(OrderSymbol(),MODE_BID);
							CloseTicket=OrderTicket();
							while(Attempt <= MaxAttemptsForCloseOrder && cl ==false )
                                 {              
                                 
                                 for (int a1=0; a1<OrdersTotal(); a1++) 
							            {
                                    if (OrderSelect(a1, SELECT_BY_POS, MODE_TRADES)) 
                                    { 
                                       if (OrderTicket()==CloseTicket) 
                                         {
                                 t6=GetTickCount(); 
                                 cl=OrderClose(CloseTicket,OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),OrderCloseSlippage,Green);                                   
                                 if(cl==false)
                                    {                                   
                                    if(ShowLog)Print("!!! FixSL Error Close Buy Order "+OrderTicket()+" Attempt = " +Attempt+" "+Symbol()+" "+GetErrorDescription(GetLastError()));
                                    } 
                                 if(cl==true) {break;}                                                                                           
                                 }
                                 }
                                 }
                                 Attempt++;
                                 } 
							
							if(cl==true)
   							 {
      							
      							
      							   for (int i21=0; i21<OrdersHistoryTotal(); i21++) 
      							   {
      		                     if (OrderSelect(i21, SELECT_BY_POS, MODE_HISTORY)) 
      		                        {
      			                        if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
      			                          {
         			                        if(OrderTicket()==CloseTicket)
            			                        {	
            			                          //Tic3 = StringSubstr(DoubleToString(CloseTicket),StringLen(CloseTicket) - 3,3);
      			                                //EqFinish=AccountEquity()-EqTicket[Tic3];
      			                                LastCloseTime=GetTickCount()-t6;	
            			                          CloseBuyPr=DoubleToStr(OrderClosePrice(),5);
                                               CloseBuySlippage=(CloseBuyPr - PriceCloseBuy)/pp;
                                               if(ShowLog)Print("!!! FixSL Buy Order  " +CloseTicket+", Slippage =   " +DoubleToStr(CloseBuySlippage,2)+" pips, Close Time = " +LastCloseTime + " ms, Loss = " +DoubleToStr(bid_pr/pp,2)+" pips." +" Account Equity= " +DoubleToStr(AccountEquity(),2) +" " +AccountCurrency());
                        							  if(SoundSignal){PlaySound("ok.wav");}
                        							  LastCloseSlippage=CloseBuySlippage;	
                        							  PriceCloseBuy=0;	
                        							  CloseTicket=0;
                        							  CloseBuyPr=0;
                        							  CloseBuySlippage=0;
                        							  t6=0;		
            			                        }
      			                          }
      			                     }
      			               }
      							
      							
								}				 						
							}
						}
					}
					if (OrderType()==OP_SELL) {
						ask_pr = MarketInfo(OrderSymbol(),MODE_ASK)-OrderOpenPrice();
						ask_pr = NormalizeDouble(ask_pr,_Digits);
						fx = FixSL2*pp;
						fx = NormalizeDouble(fx,_Digits);
						if (ask_pr>=fx)
							{
							 PriceCloseSell=MarketInfo(OrderSymbol(),MODE_ASK);	
							 CloseTicketSell=OrderTicket();						 
							 while(Attempt <= MaxAttemptsForCloseOrder && cl ==false )
                                 {
                                 
                                 for (int a1=0; a1<OrdersTotal(); a1++) 
							            {
                                    if (OrderSelect(a1, SELECT_BY_POS, MODE_TRADES)) 
                                    { 
                                       if (OrderTicket()==CloseTicketSell) 
                                         {
                                          t6=GetTickCount(); 
                                          cl=OrderClose(CloseTicketSell,OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),OrderCloseSlippage,Red);    	                              
                                          if(cl==false)
                                             {                                   
                                             if(ShowLog)Print("!!! FixSL Error Close Sell Order "+OrderTicket()+" Attempt = " +Attempt+" "+Symbol()+" "+GetErrorDescription(GetLastError()));
                                             }
                                          if(cl==true) {break;}                                                                                               
                                         } 
                                    }
                                 }
                                 Attempt++;
                                 }
							 if(cl==true)
   							 {
   							 
   							 
   							 for (int i211=0; i211<OrdersHistoryTotal(); i211++) 
   							    {
   		                     if (OrderSelect(i211, SELECT_BY_POS, MODE_HISTORY)) 
      		                     {
      			                        if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
         			                        {
            			                        if(OrderTicket()==CloseTicketSell)
               			                        {	
               			                          //Tic3 = StringSubstr(DoubleToString(CloseTicketSell),StringLen(CloseTicketSell) - 3,3);
      			                                   //EqFinish=AccountEquity()-EqTicket[Tic3];
      			                                   LastCloseTime=GetTickCount()-t6;	
               			                          CloseSellPr=DoubleToStr(OrderClosePrice(),5);
                                                  CloseSellSlippage=(PriceCloseSell-CloseSellPr)/pp;
                                                  if(ShowLog)Print("!!! FixSL Sell Order  " +CloseTicketSell+", Slippage = " +DoubleToStr(CloseSellSlippage,2)+" pips, Close Time = " +LastCloseTime + " ms, Loss = " +DoubleToStr(ask_pr/pp,2)+" pips." +" Account Equity= " +DoubleToStr(AccountEquity(),2) +" " +AccountCurrency());	
                              						  if(SoundSignal){PlaySound("ok.wav");}
                              						  LastCloseSlippage=CloseSellSlippage;
                              						  PriceCloseSell=0;	
                              						  CloseTicketSell=0;
                              						  CloseSellPr=0;
                              						  CloseSellSlippage=0;
                              						  t6=0;	
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
	   }
   }
   
   
int CloseWhenPriceEqualFunction() {  
double   PriceClose=0;
int t5;  
bool cl=0; 
int Attempt3 = 0;
	for (int i2=0; i2<OrdersTotal(); i2++) {
		if (OrderSelect(i2, SELECT_BY_POS, MODE_TRADES)) {
			if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) {		
			if((TimeCurrent()-OrderOpenTime())>=CloseOrderDelay)
			{	
					if (OrderType()==OP_BUY) {											   									
						bid_pr = (MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice());
						fx = FixTP2*pp;
						fx = NormalizeDouble(fx,_Digits);
						
						bool clok=false;					
						if (CloseWhenPriceEqual){if(MarketInfo(OrderSymbol(),MODE_BID)>=StringToDouble(OrderComment())){clok=true; if (ShowLog) Print("CloseWhenPriceEqual by Price " +MarketInfo(OrderSymbol(),MODE_BID));}}
						
						if (clok==true) 
						{						
							 PriceCloseBuy=MarketInfo(OrderSymbol(),MODE_BID);
							 CloseTicket=OrderTicket();						  							   							 
            	          while(Attempt3 <= MaxAttemptsForCloseOrder && cl ==false )
                                 { 
                                 t5=GetTickCount();
                                 for (int a1=0; a1<OrdersTotal(); a1++) 
							            {
                                    if (OrderSelect(a1, SELECT_BY_POS, MODE_TRADES)) 
                                    { 
                                       if (OrderTicket()==CloseTicket) 
                                         {
                                 cl=OrderClose(CloseTicket,OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),OrderCloseSlippage,Green);                                 
                                 if(cl==false)
                                    {                                   
                                    if(ShowLog) Print("!!! CloseWhenPriceEqual Error Close Buy Order "+OrderTicket()+" Attempt = " +Attempt3+" "+Symbol()+" "+GetErrorDescription(GetLastError()));
                                    }   
                                 if(cl==true) {break;}                                                                                            
                                 }
                                 }
                                 } 
                                 Attempt3++;
                                 }                   	 			 
							 if (cl==true)
							 {
							 LastCloseTime=GetTickCount()-t5;						 						 
							   for (int i21=0; i21<OrdersHistoryTotal(); i21++) 
							      {
   		                     if (OrderSelect(i21, SELECT_BY_POS, MODE_HISTORY)) 
   		                       {
   			                        if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
   			                        {
      			                        if(OrderTicket()==CloseTicket)
      			                          {	
      			                          CloseBuyPr=DoubleToStr(OrderClosePrice(),5);
                                         CloseBuySlippage=(CloseBuyPr - PriceCloseBuy)/pp;
      			                          }
   			                        }
   			                    }
			                  }		
							if(ShowLog)Print("!!! CloseWhenPriceEqual Work, Buy Order " +CloseTicket+" was closed, Slippage = " +DoubleToStr(CloseBuySlippage,2)+" pips, Close Time = " +LastCloseTime + " ms, Profit = " +NormalizeDouble(bid_pr/pp,2)+" pips");
							if(SoundSignal){PlaySound("ok.wav");}
							LastCloseSlippage=CloseBuySlippage;
							PriceCloseBuy=0;	
							CloseTicket=0;
							CloseBuyPr=0;
							CloseBuySlippage=0;	
							t5=0;	
							}								
					   }
					}
					if (OrderType()==OP_SELL) {
						ask_pr = OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK);
						fx = FixTP2*pp;
						fx = NormalizeDouble(fx,_Digits);
						
						bool clok2=false;					
						if (CloseWhenPriceEqual){if(MarketInfo(OrderSymbol(),MODE_ASK)<=StringToDouble(OrderComment())){clok2=true;if (ShowLog) Print("CloseWhenPriceEqual by Price " +MarketInfo(OrderSymbol(),MODE_ASK));}}
											
						if (clok2==true) 
						{							
							 PriceCloseSell=MarketInfo(OrderSymbol(),MODE_ASK);	
							 CloseTicketSell=OrderTicket();					 
 							 
   							 while(Attempt3 <= MaxAttemptsForCloseOrder && cl ==false )
                                 {
                                 t5=GetTickCount(); 
                                 for (int a1=0; a1<OrdersTotal(); a1++) 
							            {
                                    if (OrderSelect(a1, SELECT_BY_POS, MODE_TRADES)) 
                                    { 
                                       if (OrderTicket()==CloseTicketSell) 
                                         {
                                 cl=OrderClose(CloseTicketSell,OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),OrderCloseSlippage,Red);                                   
                                 if(cl==false)
                                    {                                   
                                    if(ShowLog)Print("!!! CloseWhenPriceEqual Error Close Sell Order "+OrderTicket()+" Attempt = " +Attempt3+" "+Symbol()+" "+GetErrorDescription(GetLastError()));
                                    }  
                                 if(cl==true) {break;}                                                                                             
                                 }
                                 }
                                 }
                                 Attempt3++;
                                 }     

							 if (cl==true)
							 {
							 LastCloseTime=GetTickCount()-t5;							
							 for (int i211=0; i211<OrdersHistoryTotal(); i211++) 
							    {
		                     if (OrderSelect(i211, SELECT_BY_POS, MODE_HISTORY)) 
		                       {
			                        if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
			                          {
   			                        if(OrderTicket()==CloseTicketSell)
   			                          {	
   			                          CloseSellPr=DoubleToStr(OrderClosePrice(),5);
                                      CloseSellSlippage=(PriceCloseSell-CloseSellPr)/pp;
   			                          }
			                          }
			                    }
			               }
							if(ShowLog)Print("!!! CloseWhenPriceEqual Work, Sell Order " +CloseTicketSell+" was closed, Slippage =  " +DoubleToStr(CloseSellSlippage,2)+" pips, Close Time = " +LastCloseTime + " ms, Profit = " +NormalizeDouble(ask_pr/pp,2)+" pips");	
							if(SoundSignal){PlaySound("ok.wav");}
							LastCloseSlippage=CloseSellSlippage;
							PriceCloseSell=0;	
							CloseTicketSell=0;
							CloseSellPr=0;
							CloseSellSlippage=0;
							t5=0;
							}																													  									
						}
					}
		      }
		     }
	      }
	   }
	return(rez);
}  
   
   
int CloseTimerFunction() {
double   PriceClose=0;
int t5;  
bool cl=0; 
int Attempt3 = 0;
	for (int i2=0; i2<OrdersTotal(); i2++) {
		if (OrderSelect(i2, SELECT_BY_POS, MODE_TRADES)) {
			if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) {		
			if((TimeCurrent()-OrderOpenTime())>=CloseTimer)
			{	
					if (OrderType()==OP_BUY) {											   																			
							 PriceCloseBuy=MarketInfo(OrderSymbol(),MODE_BID);
							 CloseTicket=OrderTicket();						 
      							 while(Attempt3 <= MaxAttemptsForCloseOrder && cl ==false )
                                 { 
                                 t5=GetTickCount();
                                 for (int a1=0; a1<OrdersTotal(); a1++) 
							            {
                                    if (OrderSelect(a1, SELECT_BY_POS, MODE_TRADES)) 
                                    { 
                                       if (OrderTicket()==CloseTicket) 
                                         {
                                 cl=OrderClose(CloseTicket,OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),OrderCloseSlippage,Green);                                     
                                 if(cl==false)
                                    {                                  
                                    if(ShowLog)Print("!!! Close Timer Error Close Buy Order "+OrderTicket()+" Attempt = " +Attempt3+" "+Symbol()+" "+GetErrorDescription(GetLastError()));
                                    } 
                                 if(cl==true) {break;}                                                                                              
                                 }
                                 }
                                 }
                                 Attempt3++;
                                 }
      						 			 
							 if (cl==true)
							 {
							 LastCloseTime=GetTickCount()-t5;						 						 
							   for (int i21=0; i21<OrdersHistoryTotal(); i21++) 
							      {
   		                     if (OrderSelect(i21, SELECT_BY_POS, MODE_HISTORY)) 
   		                       {
   			                        if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
   			                        {
      			                        if(OrderTicket()==CloseTicket)
      			                          {	
      			                          CloseBuyPr=DoubleToStr(OrderClosePrice(),5);
                                         CloseBuySlippage=(CloseBuyPr - PriceCloseBuy)/pp;
      			                          }
   			                        }
   			                    }
			                  }		
							if(ShowLog)Print("!!! Close Timer Work, Buy Order " +CloseTicket+" was closed after " +CloseTimer+ " sec. Slippage =  " +DoubleToStr(CloseBuySlippage,2)+" pips, Close Time = " +LastCloseTime + " ms, Profit = " +NormalizeDouble(bid_pr/pp,2)+" pips");
							if(SoundSignal){PlaySound("ok.wav");}
							LastCloseSlippage=CloseBuySlippage;
							PriceCloseBuy=0;	
							CloseTicket=0;
							CloseBuyPr=0;
							CloseBuySlippage=0;	
							t5=0;	
							}								
					   
					}
					if (OrderType()==OP_SELL) {						
							 PriceCloseSell=MarketInfo(OrderSymbol(),MODE_ASK);	
							 CloseTicketSell=OrderTicket(); 						 
							 if(ask_pr>=fx&&CloseWhenPriceEqual==false&&DisableFixTP==false)
   							 {
   							 while(Attempt3 <= MaxAttemptsForCloseOrder && cl ==false )
                                 {
                                 t5=GetTickCount();
                                 for (int a1=0; a1<OrdersTotal(); a1++) 
							            {
                                    if (OrderSelect(a1, SELECT_BY_POS, MODE_TRADES)) 
                                    { 
                                       if (OrderTicket()==CloseTicketSell) 
                                         {
                                          cl=OrderClose(CloseTicketSell,OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),OrderCloseSlippage,Red);                                   
                                          if(cl==false)
                                            {                                  
                                            if(ShowLog)Print("!!! Close Timer Error Close Sell Order "+OrderTicket()+" Attempt = " +Attempt3+" "+Symbol()+" "+GetErrorDescription(GetLastError()));
                                            }
                                            if(cl==true) {break;}                                                                                                                                        
                                          }
                                    }
                                 }
                                 Attempt3++;
                                 }                                
   							 }   							  							 
							 if (cl==true)
							 {
							 LastCloseTime=GetTickCount()-t5;							
							 for (int i211=0; i211<OrdersHistoryTotal(); i211++) 
							    {
		                     if (OrderSelect(i211, SELECT_BY_POS, MODE_HISTORY)) 
		                       {
			                        if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
			                          {
   			                        if(OrderTicket()==CloseTicketSell)
   			                          {	
   			                          CloseSellPr=DoubleToStr(OrderClosePrice(),5);
                                      CloseSellSlippage=(PriceCloseSell-CloseSellPr)/pp;
   			                          }
			                          }
			                    }
			               }
							if(ShowLog)Print("!!! Close Timer Work, Sell Order " +CloseTicketSell+" was closed after " +CloseTimer+ " sec. Slippage =  " +DoubleToStr(CloseSellSlippage,2)+" pips, Close Time = " +LastCloseTime + " ms, Profit = " +NormalizeDouble(ask_pr/pp,2)+" pips");	
							if(SoundSignal){PlaySound("ok.wav");}
							LastCloseSlippage=CloseSellSlippage;
							PriceCloseSell=0;	
							CloseTicketSell=0;
							CloseSellPr=0;
							CloseSellSlippage=0;
							t5=0;
							}																													  															
					}
		      }
		     }
	      }
	   }
	return(rez);
}
   
   
   
   
   
void EnterSLTP()
{
for (int i2=0; i2<OrdersTotal(); i2++) 
      {
		if (OrderSelect(i2, SELECT_BY_POS, MODE_TRADES)) 
		   {
			if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
			   {
             bool sel;
             bool mody;
             bool modyTP = true;
             bool modySL = true;
             double tppBuy;
             double sllBuy;
             double tppSell;
             double sllSell;
							
             if (TakeProfit == 0) {tppBuy=0; modyTP=false;}
             else {tppBuy = NormalizeDouble(OrderOpenPrice(),_Digits)+TakeProfit2*pp;}  
             if (TakeProfit == 0) {tppSell=0; modyTP=false;}
             else {tppSell = NormalizeDouble(OrderOpenPrice(),_Digits)-TakeProfit2*pp;}	  
              		            
		       if (StopLoss == 0) {sllBuy=0; modySL=false;}
   			     else 
      			   {
         			  sllBuy = NormalizeDouble(OrderOpenPrice(),_Digits)-StopLoss2*pp;
         			  if(NormalizeDouble((MarketInfo(Symbol(),MODE_BID)-sllBuy),_Digits)<minshag*pp)
            			{
            			 sllBuy=MarketInfo(Symbol(),MODE_BID)-minshag*pp-spread*pp;
            			}
   			      }
      
         	 if (StopLoss == 0) {sllSell=0; modySL=false;}
         			else
         			  {
            			 sllSell = NormalizeDouble(OrderOpenPrice(),_Digits)+StopLoss2*pp;
            			 if(NormalizeDouble((sllSell-MarketInfo(Symbol(),MODE_ASK)),_Digits)<minshag*pp)
               			{
               			  sllSell=MarketInfo(Symbol(),MODE_ASK)+minshag*pp+spread*pp;
               		   }
         			  }
            
	      		      
                 
			         if (modyTP == true && OrderTakeProfit() != 0 )   {modyTP=false;}
			         if (modySL == true && OrderStopLoss()   != 0 )   {modySL=false;}
			         
			         if(modyTP||modySL)
   			         {
   			         
   			         if (OrderType()==OP_BUY&&OrderSymbol()==Symbol()&&OrderMagicNumber() == Magic) 
   			            { 		            
   			            mody=OrderModify(OrderTicket(),OrderOpenPrice(),sllBuy,tppBuy,0,Green);			            		            	
   		               }
   		            if (OrderType()==OP_SELL&&OrderSymbol()==Symbol()&&OrderMagicNumber() == Magic) 
   			            { 
   			            mody=OrderModify(OrderTicket(),OrderOpenPrice(),sllSell,tppSell,0,Green);	            			            
   		               }		            		            	            
   		            } 
   		            
		       }    
		  }
	}
}


int TotalOrderTest()
{
int total=0;
bool sel2;
				if (OrdersTotal() > 0) {
					for(cnt=0;cnt<OrdersTotal();cnt++) {
						sel2=OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);										
						if (OrderSymbol()==Symbol() && OrderMagicNumber() == MagicTest) {total++;}
					}
				}
				return (total);
}

int TotalHistoryOrder()
{
int total=0;
bool sel2;
				
					for(cnt=0;cnt<OrdersHistoryTotal();cnt++) {
						sel2=OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY);										
						if (OrderSymbol()==Symbol() && OrderMagicNumber() == MagicTest) {total++;}
					}
				
				return (total);
}


string GetErrorDescription(int ErrorCode)
{
   string Description = "";
   switch(ErrorCode)   { 
      case 0:   Description = "No error returned";                                               break;
      case 1:   Description = "No error returned, but the result is unknown";                      break;
      case 2:   Description = "Common error";                                             break;
      case 3:   Description = "Invalid trade parameters";                                   break;
      case 4:   Description = "Trade server is busy";                                    break;
      case 5:   Description = "Old version of the client terminal";                      break;
      case 6:   Description = "No connection with trade server";                            break;
      case 7:   Description = "Not enough rights";                                        break;
      case 8:   Description = "Too frequent requests";                                   break;
      case 9:   Description = "Malfunctional trade operation";             break;
      case 64:  Description = "Account disabled";                                        break;
      case 65:  Description = "Invalid account";                                 break;
      case 128: Description = "Trade timeout";                    break;
      case 129: Description = "Invalid price";                                        break;
      case 130: Description = "Invalid stops";                                       break;
      case 131: Description = "Invalid trade volume";                                       break;
      case 132: Description = "Market is closed";                                             break;
      case 133: Description = "Trade is disabled";                                       break;  
      case 134: Description = "Not enough money";               break;
      case 135: Description = "Price changed";                                          break;
      case 136: Description = "Off quotes";                                                 break;
      case 137: Description = "Broker is busy";                                             break;
      case 138: Description = "Requote";                                     break;
      case 139: Description = "Order is locked";                  break;
      case 140: Description = "Buy orders only allowed";                                 break;
      case 141: Description = "Too many requests";                                   break;
      case 145: Description = "Modification denied because order is too close to market";      break;
      case 146: Description = "Trade context is busy";                               break;
      case 147: Description = "Expirations are denied by broker";   break;
      case 148: Description = "The amount of open and pending orders has reached the limit set by the broker";                     break;
      case 149: Description = "An attempt to open an order opposite to the existing one when hedging is disabled";                     break;
      case 150: Description = "An attempt to close an order contravening the FIFO rule";                     break;
      case 4000: Description = "No error returned";                                              break;
      case 4001: Description = "Wrong function pointer";                          break;
      case 4002: Description = "Array index is out of range";                          break;
      case 4003: Description = "No memory for function call stack";                            break;
      case 4004: Description = "Recursive stack overflow";            break;
      case 4005: Description = "Not enough stack for parameter";             break;
      case 4006: Description = "No memory for parameter string";                     break;
      case 4007: Description = "No memory for temp string";                         break;
      case 4008: Description = "Not initialized string";                             break;
      case 4009: Description = "Not initialized string in array";                   break;
      case 4010: Description = "No memory for array string";                       break;
      case 4011: Description = "Too long string";                                  break;
      case 4012: Description = "Remainder from zero divide";                              break;
      case 4013: Description = "Zero divide";                                         break;
      case 4014: Description = "Unknown command";                                     break;
      case 4015: Description = "Wrong jump (never generated error)";                                    break;
      case 4016: Description = "Not initialized array";                             break;
      case 4017: Description = "DLL calls are not allowed";                                 break;
      case 4018: Description = "Cannot load library";                         break;
      case 4019: Description = "Cannot call function";                              break;
      case 4020: Description = "Expert function calls are not allowed";        break; 
      case 4021: Description = "Not enough memory for temp string returned from function"; break;
      case 4022: Description = "System is busy (never generated error)";                                          break;
      case 4023: Description = "DLL-function call critical error";                  break;
      case 4024: Description = "Internal error";                  break;
      case 4025: Description = "Out of memory";                  break;
      case 4026: Description = "Invalid pointer";                  break;
      case 4027: Description = "Too many formatters in the format function";                  break;
      case 4028: Description = "Parameters count exceeds formatters count";                  break;
      case 4029: Description = "Invalid array";                  break;
      case 4030: Description = "No reply from chart";                  break;
      case 4050: Description = "Invalid function parameters count";              break;
      case 4051: Description = "Invalid function parameter value";                 break;
      case 4052: Description = "String function internal error";                     break;
      case 4053: Description = "Some array error";                                          break;
      case 4054: Description = "Incorrect series array using";            break;
      case 4055: Description = "Custom indicator error";                     break;
      case 4056: Description = "Arrays are incompatible";                                    break;
      case 4057: Description = "Global variables processing error";                 break;
      case 4058: Description = "Global variable not found";                     break;
      case 4059: Description = "Function is not allowed in testing mode";                  break;
      case 4060: Description = "Function is not allowed for call";                                    break;
      case 4061: Description = "Send mail error";                                                                               break;
      case 4062: Description = "String parameter expected";   break;
      case 4063: Description = "Integer parameter expected";                         break;
      case 4064: Description = "Double parameter expected";                          break;
      case 4065: Description = "Array as parameter expected";                   break;
      case 4066: Description = "Requested history data is in updating state";  break;
      case 4067: Description = "Internal trade error";                 break;
      case 4068: Description = "Resource not found";                 break;
      case 4069: Description = "Resource not supported";                 break;
      case 4070: Description = "Duplicate resource";                 break;
      case 4071: Description = "Custom indicator cannot initialize";                 break;
      case 4072: Description = "Cannot load custom indicator";                 break;
      case 4073: Description = "No history data";                 break;
      case 4074: Description = "No memory for history data";                 break;
      case 4075: Description = "Not enough memory for indicator calculation";                 break;
          
      case 4099: Description = "End of file";                                             break;
      case 4100: Description = "Some file error";                              break;
      case 4101: Description = "Wrong file name";                                  break;
      case 4102: Description = "Too many opened files";                           break;
      case 4103: Description = "Cannot open file";                                 break;
      case 4104: Description = "Incompatible access to a file";                     break;
      case 4105: Description = "No order selected";                                 break;
      case 4106: Description = "Unknown symbol";                                      break;
      case 4107: Description = "Invalid price";         break;
      case 4108: Description = "Invalid ticket";                                   break;
      case 4109: Description = "Trade is not allowed. Enable checkbox Allow live trading in the Expert Advisor properties";      break;
      case 4110: Description = "Longs are not allowed. Check the Expert Advisor properties";  break;
      case 4111: Description = "Shorts are not allowed. Check the Expert Advisor properties"; break;
      case 4112: Description = "Automated trading by Expert Advisors/Scripts disabled by trade server"; break;
      case 4200: Description = "Object already exists";                                   break;
      case 4201: Description = "Unknown object property";                  break;
      case 4202: Description = "Object does not exist";                                    break;
      case 4203: Description = "Unknown object type";                                 break;
      case 4204: Description = "No object name";                                       break;
      case 4205: Description = "Object coordinates error";                                break;
      case 4206: Description = "No specified subwindow";                            break;
      case 4207: Description = "Graphical object error";                            break;
      case 4210: Description = "Unknown chart property";                            break;
      case 4211: Description = "Chart not found";                            break;
      case 4212: Description = "Chart subwindow not found";                            break;
      case 4213: Description = "Chart indicator not found";                            break;
      case 4220: Description = "Symbol select error";                            break;
      case 4250: Description = "Notification error";                            break;
      case 4251: Description = "Notification parameter error";                            break;
      case 4252: Description = "Notifications disabled";                            break;
      case 4253: Description = "Notification send too frequent";                            break;
      case 4260: Description = "FTP server is not specified";                            break;
      case 4261: Description = "FTP login is not specified";                            break;
      case 4262: Description = "FTP connection failed";                            break;
      case 4263: Description = "FTP connection closed";                            break;
      case 4264: Description = "FTP path not found on server";                            break;
      case 4265: Description = "File not found in the MQL4,Files directory to send on FTP server";                            break;
      case 4266: Description = "Common error during FTP data transmission";                            break;
      case 5001: Description = "Too many opened files";                            break;
      case 5002: Description = "Wrong file name";                            break;
      case 5003: Description = "Too long file name";                            break;
      case 5004: Description = "Cannot open file";                            break;
      case 5005: Description = "Text file buffer allocation error";                            break;
      case 5006: Description = "Cannot delete file";                            break;
      case 5007: Description = "Invalid file handle (file closed or was not opened)";                            break;
      case 5008: Description = "Wrong file handle (handle index is out of handle table)";                            break;
      case 5009: Description = "File must be opened with FILE_WRITE flag";                            break;
      case 5010: Description = "File must be opened with FILE_READ flag";                            break;
      case 5011: Description = "File must be opened with FILE_BIN flag";                            break;
      case 5012: Description = "File must be opened with FILE_TXT flag";                            break;
      case 5013: Description = "File must be opened with FILE_TXT or FILE_CSV flag";                            break;
      case 5014: Description = "File must be opened with FILE_CSV flag";                            break;
      case 5015: Description = "File read error";                            break;
      case 5016: Description = "File write error";                            break;
      case 5017: Description = "String size must be specified for binary file";                            break;
      case 5018: Description = "Incompatible file (for string arrays-TXT, for others-BIN)";                            break;
      case 5019: Description = "File is directory not file";                            break;
      case 5020: Description = "File does not exist";                            break;
      case 5021: Description = "File cannot be rewritten";                            break;
      case 5022: Description = "Wrong directory name";                            break;
      case 5023: Description = "Directory does not exist";                            break;
      case 5024: Description = "Specified file is not directory";                            break;
      case 5025: Description = "Cannot delete directory";                            break;
      case 5026: Description = "Cannot clean directory";                            break;
      case 5027: Description = "Array resize error";                            break;
      case 5028: Description = "String resize error";                            break;
      case 5029: Description = "Structure contains strings or dynamic arrays";                            break;
      case 5200: Description = "Invalid URL";                            break;
      case 5201: Description = "Failed to connect to specified URL";                            break;
      case 5202: Description = "Timeout exceeded";                            break;
      case 5203: Description = "HTTP request failed";                            break;
      case 65536: Description = "User defined errors start with this code";                            break;
     
      
      
      
      
      default:   Description = "Неизвестная ошибка";
   }
//-----------------
  return(Description);
}
//+------------------------------------------------------------------+

bool IsLastOrdersUnprofitable(int magic, int max_unprofitable_count = 3)
{
   int i, j = OrdersHistoryTotal(), count = 0;

   for (i = j-1; i >= j - max_unprofitable_count; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderMagicNumber() == magic)
      {
         if (OrderProfit() + OrderCommission() < 0)
         {
            count++;
            if (count >= max_unprofitable_count) return (true);
         }
      }
   }

   return (false);
}


void ShowWesternpipsInfoPanel()
{                
         
         ObjectCreate("boxwp01", OBJ_LABEL, 0, 0,0);
         ObjectSetText("boxwp01", "gg", 190, "Webdings");          
         ObjectSet("boxwp01", OBJPROP_CORNER, 4);
   
         ObjectSet("boxwp01", OBJPROP_XDISTANCE, 5);    
         ObjectSet("boxwp01", OBJPROP_YDISTANCE, 15);       
         ObjectSet("boxwp01", OBJPROP_COLOR, C'0,43,73');
         ObjectSet("boxwp01", OBJPROP_BACK, false);
         
         ObjectCreate("boxwp011", OBJ_LABEL, 0, 0,0);
         ObjectSetText("boxwp011", "gg", 190, "Webdings");          
         ObjectSet("boxwp011", OBJPROP_CORNER, 4);
   
         ObjectSet("boxwp011", OBJPROP_XDISTANCE, 5);    
         ObjectSet("boxwp011", OBJPROP_YDISTANCE, 35);       
         ObjectSet("boxwp011", OBJPROP_COLOR, C'0,43,73');
         ObjectSet("boxwp011", OBJPROP_BACK, false);
         
         
          ObjectCreate("EAver0", OBJ_LABEL, 0, 0, 0);
          ObjectSet("EAver0", OBJPROP_CORNER, 4);
          ObjectSet("EAver0", OBJPROP_XDISTANCE, 214);
          ObjectSet("EAver0", OBJPROP_YDISTANCE, 25);
          ObjectSetText("EAver0","Newest", 12, "Arial", C'73,138,243');
         
          ObjectCreate("EAver", OBJ_LABEL, 0, 0, 0);
          ObjectSet("EAver", OBJPROP_CORNER, 4);
          ObjectSet("EAver", OBJPROP_XDISTANCE, 269);
          ObjectSet("EAver", OBJPROP_YDISTANCE, 25);
          ObjectSetText("EAver","PRO 3.7", 12, "Arial", White);
          
          ObjectCreate("EAver11", OBJ_LABEL, 0, 0, 0);
          ObjectSet("EAver11", OBJPROP_CORNER, 4);
          ObjectSet("EAver11", OBJPROP_XDISTANCE, 444);
          ObjectSet("EAver11", OBJPROP_YDISTANCE, 25);
          ObjectSetText("EAver11","Classic", 12, "Arial", C'73,138,243');
            
          ObjectCreate("EAver1", OBJ_LABEL, 0, 0, 0);
          ObjectSet("EAver1", OBJPROP_CORNER, 4);
          ObjectSet("EAver1", OBJPROP_XDISTANCE, 334);
          ObjectSet("EAver1", OBJPROP_YDISTANCE, 26);
          ObjectSetText("EAver1","E X C L U S I V E", 10, "Arial", Gold);
          
          ObjectCreate("Line1", OBJ_LABEL, 0, 0, 0);
          ObjectSet("Line1", OBJPROP_CORNER, 4);
          ObjectSet("Line1", OBJPROP_XDISTANCE, 210);
          ObjectSet("Line1", OBJPROP_YDISTANCE, 31);
          ObjectSetText("Line1","__________________________________________", 10, "Arial", Gold);
          
          ObjectCreate("Line2", OBJ_LABEL, 0, 0, 0);
          ObjectSet("Line2", OBJPROP_CORNER, 4);
          ObjectSet("Line2", OBJPROP_XDISTANCE, 210);
          ObjectSet("Line2", OBJPROP_YDISTANCE, 7);
          ObjectSetText("Line2","__________________________________________", 10, "Arial", Gold);
         
         ObjectCreate("box1a", OBJ_LABEL, 0, 0,0);
         ObjectSetText("box1a", "|", 11, "Webdings");          
         ObjectSet("box1a", OBJPROP_CORNER, 4);
   
         ObjectSet("box1a", OBJPROP_XDISTANCE, 203);      
         ObjectSet("box1a", OBJPROP_YDISTANCE, 19);       
         ObjectSet("box1a", OBJPROP_COLOR, Gold);;
         ObjectSet("box1a", OBJPROP_BACK, False);
         
         ObjectCreate("box1aa", OBJ_LABEL, 0, 0,0);
         ObjectSetText("box1aa", "|", 11, "Webdings");          
         ObjectSet("box1aa", OBJPROP_CORNER, 4);
   
         ObjectSet("box1aa", OBJPROP_XDISTANCE, 203);      
         ObjectSet("box1aa", OBJPROP_YDISTANCE, 29);       
         ObjectSet("box1aa", OBJPROP_COLOR, Gold);;
         ObjectSet("box1aa", OBJPROP_BACK, False);
         
         
         ObjectCreate("box1a1", OBJ_LABEL, 0, 0,0);
         ObjectSetText("box1a1", "|", 11, "Webdings");          
         ObjectSet("box1a1", OBJPROP_CORNER, 4);
   
         ObjectSet("box1a1", OBJPROP_XDISTANCE, 497);      
         ObjectSet("box1a1", OBJPROP_YDISTANCE, 19);       
         ObjectSet("box1a1", OBJPROP_COLOR, Gold);;
         ObjectSet("box1a1", OBJPROP_BACK, False);
         
         ObjectCreate("box1aa1", OBJ_LABEL, 0, 0,0);
         ObjectSetText("box1aa1", "|", 11, "Webdings");          
         ObjectSet("box1aa1", OBJPROP_CORNER, 4);
   
         ObjectSet("box1aa1", OBJPROP_XDISTANCE, 497);      
         ObjectSet("box1aa1", OBJPROP_YDISTANCE, 29);       
         ObjectSet("box1aa1", OBJPROP_COLOR, Gold);;
         ObjectSet("box1aa1", OBJPROP_BACK, False);
         
      
         ObjectCreate("box1", OBJ_LABEL, 0, 0,0);
         ObjectSetText("box1", "ggggg", 20, "Webdings");          
         ObjectSet("box1", OBJPROP_CORNER, 4);
   
         ObjectSet("box1", OBJPROP_XDISTANCE, 210);      
         ObjectSet("box1", OBJPROP_YDISTANCE, 62);       
         ObjectSet("box1", OBJPROP_COLOR, Green);;
         ObjectSet("box1", OBJPROP_BACK, False);
         
         ObjectCreate("df", OBJ_LABEL, 0, 0, 0);
         ObjectSet("df", OBJPROP_CORNER, 4);
         ObjectSet("df", OBJPROP_XDISTANCE, 217);
         ObjectSet("df", OBJPROP_YDISTANCE, 68);
         ObjectSetText("df", "FAST DATA FEED", 11, "Arial", White);
         
         
         //
         
         ObjectCreate("box12", OBJ_LABEL, 0, 0,0);
         ObjectSetText("box12", "ggggg", 20, "Webdings");          
         ObjectSet("box12", OBJPROP_CORNER, 4);
   
         ObjectSet("box12", OBJPROP_XDISTANCE, 355);      
         ObjectSet("box12", OBJPROP_YDISTANCE, 62);       
         ObjectSet("box12", OBJPROP_COLOR, C'73,138,243');
         ObjectSet("box12", OBJPROP_BACK, False);
         
         ObjectCreate("df2", OBJ_LABEL, 0, 0, 0);
         ObjectSet("df2", OBJPROP_CORNER, 4);
         ObjectSet("df2", OBJPROP_XDISTANCE, 357);
         ObjectSet("df2", OBJPROP_YDISTANCE, 68);
         ObjectSetText("df2", "SLOW DATA FEED", 11, "Arial", White);              
         
         ObjectCreate("box123", OBJ_LABEL, 0, 0,0);
         ObjectSetText("box123", "gggggggggggg", 17, "Webdings");          
         ObjectSet("box123", OBJPROP_CORNER, 4);
         
         ObjectSet("box123", OBJPROP_XDISTANCE, 210);      
         ObjectSet("box123", OBJPROP_YDISTANCE, 190);       
         ObjectSet("box123", OBJPROP_COLOR, Red);
         ObjectSet("box123", OBJPROP_BACK, False);
         
         
         
         ObjectCreate("SigSells", OBJ_LABEL, 0, 0,0);
         ObjectSetText("SigSells", "gggggg", 20, "Webdings");          
         ObjectSet("SigSells", OBJPROP_CORNER, 1);
         
         ObjectSet("SigSells", OBJPROP_XDISTANCE, 25);      
         ObjectSet("SigSells", OBJPROP_YDISTANCE, 47);       
         ObjectSet("SigSells", OBJPROP_COLOR, Red);
         ObjectSet("SigSells", OBJPROP_BACK, true);
         
         ObjectCreate("SigSells2", OBJ_LABEL, 0, 0,0);
         ObjectSetText("SigSells2", "ggg", 20, "Webdings");          
         ObjectSet("SigSells2", OBJPROP_CORNER, 1);
         
         ObjectSet("SigSells2", OBJPROP_XDISTANCE, 4);      
         ObjectSet("SigSells2", OBJPROP_YDISTANCE, 47);       
         ObjectSet("SigSells2", OBJPROP_COLOR, C'0,43,73');
         ObjectSet("SigSells2", OBJPROP_BACK, true);
         
         
         if(ObjectFind(0,"GapSell2")==-1)
      	   {ObjectCreate(0,"GapSell2",OBJ_LABEL,0, 0, 0);}
            ObjectSetInteger(0,"GapSell2", OBJPROP_CORNER, 1);
      	   ObjectSetInteger(0,"GapSell2", OBJPROP_XDISTANCE, 168);
      	   ObjectSetInteger(0,"GapSell2", OBJPROP_YDISTANCE, 53);
      	   ObjectSetString(0,"GapSell2", OBJPROP_TEXT,"Signal Sell ");
            ObjectSetInteger(0,"GapSell2", OBJPROP_FONTSIZE, 10);
            ObjectSetString(0,"GapSell2", OBJPROP_FONT,"Arial");
            ObjectSetInteger(0,"GapSell2", OBJPROP_COLOR,White);
         
         
         ObjectCreate("SigBuys", OBJ_LABEL, 0, 0,0);
         ObjectSetText("SigBuys", "gggggg", 20, "Webdings");          
         ObjectSet("SigBuys", OBJPROP_CORNER, 1);
         
         ObjectSet("SigBuys", OBJPROP_XDISTANCE, 25);      
         ObjectSet("SigBuys", OBJPROP_YDISTANCE, 19);       
         ObjectSet("SigBuys", OBJPROP_COLOR, Green);
         ObjectSet("SigBuys", OBJPROP_BACK, true);
         
         ObjectCreate("SigBuys2", OBJ_LABEL, 0, 0,0);
         ObjectSetText("SigBuys2", "ggg", 20, "Webdings");          
         ObjectSet("SigBuys2", OBJPROP_CORNER, 1);
         
         ObjectSet("SigBuys2", OBJPROP_XDISTANCE, 4);      
         ObjectSet("SigBuys2", OBJPROP_YDISTANCE, 19);       
         ObjectSet("SigBuys2", OBJPROP_COLOR, C'0,43,73');
         ObjectSet("SigBuys2", OBJPROP_BACK, true);
         
         
         if(ObjectFind(0,"GapBuy2")==-1)
      	   {ObjectCreate(0,"GapBuy2",OBJ_LABEL,0, 0, 0);}
            ObjectSetInteger(0,"GapBuy2", OBJPROP_CORNER, 1);
      	   ObjectSetInteger(0,"GapBuy2", OBJPROP_XDISTANCE, 168);
      	   ObjectSetInteger(0,"GapBuy2", OBJPROP_YDISTANCE, 24);
      	   ObjectSetString(0,"GapBuy2", OBJPROP_TEXT,"Signal Buy ");
            ObjectSetInteger(0,"GapBuy2", OBJPROP_FONTSIZE, 10);
            ObjectSetString(0,"GapBuy2", OBJPROP_FONT,"Arial");
            ObjectSetInteger(0,"GapBuy2", OBJPROP_COLOR,White);
            
         
         
         ObjectCreate("df23", OBJ_LABEL, 0, 0, 0);
         ObjectSet("df23", OBJPROP_CORNER, 4);
         ObjectSet("df23", OBJPROP_XDISTANCE, 8);
         ObjectSet("df23", OBJPROP_YDISTANCE, 145);
         ObjectSetText("df23", "RISK MANAGMENT", 11, "Arial", Yellow);
         
         ObjectCreate("Plagins", OBJ_LABEL, 0, 0, 0);
         ObjectSet("Plagins", OBJPROP_CORNER, 4);
         ObjectSet("Plagins", OBJPROP_XDISTANCE, 200);
         ObjectSet("Plagins", OBJPROP_YDISTANCE, 194);
         ObjectSetText("Plagins", "    P L A G I N  C O N T R O L  T O O L S", 11, "Arial", White);
         
         ObjectCreate("wp", OBJ_LABEL, 0, 0, 0);
         ObjectSet("wp", OBJPROP_CORNER, 4);
         ObjectSet("wp", OBJPROP_XDISTANCE, 41);
         ObjectSet("wp", OBJPROP_YDISTANCE, 25);
         ObjectSetText("wp", "WESTERNPIPS.COM", 12, "Arial", White);
                       
         ObjectCreate("wp1", OBJ_LABEL, 0, 0, 0);
         ObjectSet("wp1", OBJPROP_CORNER, 4);
         ObjectSet("wp1", OBJPROP_XDISTANCE, 62);
         ObjectSet("wp1", OBJPROP_YDISTANCE, 42);
         ObjectSetText("wp1", "Real accounts, real money, real peoples", 6, "Arial", C'73,138,243');
                  
         ObjectCreate("logo", OBJ_LABEL, 0, 0,0);
         ObjectSetText("logo", "n", 1, "Webdings");          
         ObjectSet("logo", OBJPROP_CORNER, 4);
   
         ObjectSet("logo", OBJPROP_XDISTANCE, 10);      
         ObjectSet("logo", OBJPROP_YDISTANCE, 48);       
         ObjectSet("logo", OBJPROP_COLOR, C'248,243,238');
         ObjectSet("logo", OBJPROP_BACK, False);
         
         ObjectCreate("logo2", OBJ_LABEL, 0, 0,0);
         ObjectSetText("logo2", "n", 5, "Webdings");          
         ObjectSet("logo2", OBJPROP_CORNER, 4);
   
         ObjectSet("logo2", OBJPROP_XDISTANCE, 17);      
         ObjectSet("logo2", OBJPROP_YDISTANCE, 39);       
         ObjectSet("logo2", OBJPROP_COLOR, C'248,243,238');
         ObjectSet("logo2", OBJPROP_BACK, False);
         
         ObjectCreate("logo3", OBJ_LABEL, 0, 0,0);
         ObjectSetText("logo3", "n", 7, "Webdings");          
         ObjectSet("logo3", OBJPROP_CORNER, 4);
   
         ObjectSet("logo3", OBJPROP_XDISTANCE, 21);      
         ObjectSet("logo3", OBJPROP_YDISTANCE, 22);       
         ObjectSet("logo3", OBJPROP_COLOR, C'248,243,238');
         ObjectSet("logo3", OBJPROP_BACK, False);
}

void DeleteWesternpipsInfoPanel()
{
 ObjectsDeleteAll(); 
}


void ShowErrorsPanel() 
{

               if(ObjectFind(0,"ErrorBox")==-1)
               {
               ObjectCreate("ErrorBox", OBJ_LABEL, 0, 0,0);
               ObjectSetText("ErrorBox", "gggggg", 50, "Webdings");          
               ObjectSet("ErrorBox", OBJPROP_CORNER, 2);
         
               ObjectSet("ErrorBox", OBJPROP_XDISTANCE, 5);    
               ObjectSet("ErrorBox", OBJPROP_YDISTANCE, 5);       
               ObjectSet("ErrorBox", OBJPROP_COLOR, C'255,0,0');
               ObjectSet("ErrorBox", OBJPROP_BACK, false);
               
               ObjectCreate("ErrorBox0", OBJ_LABEL, 0, 0,0);
               ObjectSetText("ErrorBox0", "g", 50, "Webdings");          
               ObjectSet("ErrorBox0", OBJPROP_CORNER, 2);
         
               ObjectSet("ErrorBox0", OBJPROP_XDISTANCE, 359);    
               ObjectSet("ErrorBox0", OBJPROP_YDISTANCE, 5);       
               ObjectSet("ErrorBox0", OBJPROP_COLOR, C'255,0,0');
               ObjectSet("ErrorBox0", OBJPROP_BACK, false);
               
               ObjectCreate("ErrorBox2", OBJ_LABEL, 0, 0,0);
               ObjectSetText("ErrorBox2", "gggggg", 49, "Webdings");          
               ObjectSet("ErrorBox2", OBJPROP_CORNER, 2);
         
               ObjectSet("ErrorBox2", OBJPROP_XDISTANCE, 35);    
               ObjectSet("ErrorBox2", OBJPROP_YDISTANCE, 7);       
               ObjectSet("ErrorBox2", OBJPROP_COLOR, C'0,43,73');
               ObjectSet("ErrorBox2", OBJPROP_BACK, false);
               
               ObjectCreate("iiiiii", OBJ_LABEL, 0, 0,0);
               ObjectSetText("iiiiii", "!", 49, "Arial",Yellow);          
               ObjectSet("iiiiii", OBJPROP_CORNER, 2);
         
               ObjectSet("iiiiii", OBJPROP_XDISTANCE, 8);    
               ObjectSet("iiiiii", OBJPROP_YDISTANCE, 0);       
               ObjectSet("iiiiii", OBJPROP_COLOR, Yellow);
               ObjectSet("iiiiii", OBJPROP_BACK, false);
               }
               
               
               string LastErrorText1="";
               string LastErrorText2="";
               string LastErrorText3="";
               string LastErrorText4="";
               string LastErrorText5="";
               
               if(StringLen(LastErrorText>63))
               {
               LastErrorText1=StringSubstr(LastErrorText,0,63);
               LastErrorText2=StringSubstr(LastErrorText,63,63);
               LastErrorText3=StringSubstr(LastErrorText,126,63);
               LastErrorText4=StringSubstr(LastErrorText,189,63);
               LastErrorText5=StringSubstr(LastErrorText,252,63);
               }
               
               else
               {
               LastErrorText1=LastErrorText;
               }
               
               ObjectCreate("errortext", OBJ_LABEL, 0, 0, 0);
               ObjectSet("errortext", OBJPROP_CORNER, 2);
               ObjectSet("errortext", OBJPROP_XDISTANCE, 45);
               ObjectSet("errortext", OBJPROP_YDISTANCE, 56);
               ObjectSetText("errortext", LastErrorText1, 8, "Arial", C'118,192,217'); 

               if(LastErrorText2!="")
               {
               ObjectCreate("errortext2", OBJ_LABEL, 0, 0, 0);
               ObjectSet("errortext2", OBJPROP_CORNER, 2);
               ObjectSet("errortext2", OBJPROP_XDISTANCE, 45);
               ObjectSet("errortext2", OBJPROP_YDISTANCE, 44);
               ObjectSetText("errortext2", LastErrorText2, 8, "Arial", C'118,192,217'); 
               }
               if(LastErrorText3!="")
               {
               ObjectCreate("errortext3", OBJ_LABEL, 0, 0, 0);
               ObjectSet("errortext3", OBJPROP_CORNER, 2);
               ObjectSet("errortext3", OBJPROP_XDISTANCE, 45);
               ObjectSet("errortext3", OBJPROP_YDISTANCE, 32);
               ObjectSetText("errortext3", LastErrorText3, 8, "Arial", C'118,192,217');
               }
               if(LastErrorText4!="")
               {
               ObjectCreate("errortext4", OBJ_LABEL, 0, 0, 0);
               ObjectSet("errortext4", OBJPROP_CORNER, 2);
               ObjectSet("errortext4", OBJPROP_XDISTANCE, 45);
               ObjectSet("errortext4", OBJPROP_YDISTANCE, 20);
               ObjectSetText("errortext4", LastErrorText4, 8, "Arial", C'118,192,217');
               } 
               
               if(LastErrorText5!="")
               {
               ObjectCreate("errortext5", OBJ_LABEL, 0, 0, 0);
               ObjectSet("errortext5", OBJPROP_CORNER, 2);
               ObjectSet("errortext5", OBJPROP_XDISTANCE, 45);
               ObjectSet("errortext5", OBJPROP_YDISTANCE, 8);
               ObjectSetText("errortext5", LastErrorText5, 8, "Arial", C'118,192,217');
               } 

}


bool IsWorkingHours()
{
   MqlDateTime dstr1;
   
   if(TimeCount==0){TimeCurrent(dstr1);}
   if(TimeCount==1){TimeLocal(dstr1);}
   if(TimeCount==2){TimeGMT(dstr1);}
   
   int Start, Stop, Current;

   Start = StartHour * 3600 + StartMinutes * 60 + StartSeconds;
   Stop = StopHour * 3600 + StopMinutes * 60 + StopSeconds;
   Current = dstr1.hour * 3600 + dstr1.min * 60 + dstr1.sec;
   
   if (StopHour >= StartHour && Current >= Start && Current < Stop) return (true);
   if (StopHour < StartHour && ((Current >= Start && Current > Stop) || (Current < Start && Current < Stop))) return (true);

   return (false);
}


void  TrailingStopFunction()
{
   bool err;
   int i;
   double trailingstop;
   double trailingstep;
   
   if(TrailingStop<=MarketInfo(Symbol(),MODE_STOPLEVEL)) {trailingstop = MarketInfo(Symbol(),MODE_STOPLEVEL);}
   else {trailingstop=TrailingStop;}
   
   trailingstep=TrailingStep;
   
   
   if(OrdersTotal() >0)
   {
   for (i = 0; i < OrdersTotal(); i++)
   {
    if (OrderSelect(i, SELECT_BY_POS,MODE_TRADES))
    {
    if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
    {		 
      if(trailingstop > 0)
      {               
         if(OrderType() == OP_BUY)
         {                      
            if( MarketInfo(Symbol(),MODE_BID) - OrderOpenPrice() >= trailingstop * pp )
              {
              if(OrderStopLoss() >0)
               { 
                 if((MarketInfo(Symbol(),MODE_BID) - pp * trailingstop) > OrderStopLoss())
                   {
                       if(((MarketInfo(Symbol(),MODE_BID) - pp * trailingstop)-OrderStopLoss())>= trailingstep * pp)
                       {             
                        err = OrderModify(OrderTicket(), OrderOpenPrice(), MarketInfo(Symbol(),MODE_BID) - pp * trailingstop, OrderTakeProfit(), 0, Green);
                        if(err == true) { if (ShowLog) Print("!!! TrailingStop Work, Modify Stop Loss Buy Order " +ticket+" To price " +DoubleToString((MarketInfo(Symbol(),MODE_BID) - pp * trailingstop),Digits));}
                        //if(err == false) { if (ShowLog) {Print("!!! Error in TrailingStop Modify Stop Loss Buy Order " +ticket+" To price " +DoubleToString((MarketInfo(Symbol(),MODE_BID) - pp * trailingstop),Digits)+" " +GetLastError());}} 
                       }
                   }
                }
                else
                      {
                      err = OrderModify(OrderTicket(), OrderOpenPrice(), MarketInfo(Symbol(),MODE_BID) - pp * trailingstop, OrderTakeProfit(), 0, Green);
                      if(err == true) { if (ShowLog) Print("!!! TrailingStop Work, Modify Stop Loss Buy Order " +ticket+" To price " +DoubleToString((MarketInfo(Symbol(),MODE_BID) - pp * trailingstop),Digits));}
                      //if(err == false) { if (ShowLog) {Print("!!! Error in TrailingStop Modify Stop Loss Buy Order " +ticket+" To price " +DoubleToString((MarketInfo(Symbol(),MODE_BID) - pp * trailingstop),Digits)+" " +GetLastError());}} 
                      }
              }
         }
         if(OrderType() == OP_SELL)
         {  
            if(OrderOpenPrice()- MarketInfo(Symbol(),MODE_ASK) >= trailingstop * pp)
            {
              if(OrderStopLoss() >0)
               { 
                 if(OrderStopLoss() >0 && OrderStopLoss() > ( MarketInfo(Symbol(),MODE_ASK) + trailingstop * pp))
                  { 
                     if((OrderStopLoss()-( MarketInfo(Symbol(),MODE_ASK) + trailingstop * pp))>trailingstep*pp)
                     {                 
                        err=OrderModify(OrderTicket(), OrderOpenPrice(),  MarketInfo(Symbol(),MODE_ASK) + trailingstop * pp, OrderTakeProfit(), 0, Green);
                        if(err == true) {if (ShowLog) Print("!!! TrailingStop Work, Modify Stop Loss Sell Order " +ticket+" To price "+DoubleToString(( MarketInfo(Symbol(),MODE_ASK) + trailingstop * pp),Digits));}
                        //if(err == false) {if (ShowLog) {Print("!!! Error in TrailingStop Modify Stop Loss Sell Order " +ticket+" To price "+DoubleToString(( MarketInfo(Symbol(),MODE_ASK) + trailingstop * pp),Digits)+" " +GetLastError());}}
                     }
                  }
               }
               else
                     {
                     err=OrderModify(OrderTicket(), OrderOpenPrice(),  MarketInfo(Symbol(),MODE_ASK) + trailingstop * pp, OrderTakeProfit(), 0, Green);
                     if(err == true) {if (ShowLog) Print("!!! TrailingStop Work, Modify Stop Loss Sell Order " +ticket+" To price "+DoubleToString(( MarketInfo(Symbol(),MODE_ASK) + trailingstop * pp),Digits));}
                     //if(err == false) {if (ShowLog) {Print("!!! Error in TrailingStop Modify Stop Loss Sell Order " +ticket+" To price "+DoubleToString(( MarketInfo(Symbol(),MODE_ASK) + trailingstop * pp),Digits)+" " +GetLastError());}}
                     }
             }
           }
         }
       }
      }
    }
   }
}




void  VirtualTrailingStopFunction()
{
   bool err;
   int i;
   double trailingstop;
   double trailingstep;

   trailingstop=VirtualTrailingStop;
   trailingstep=VirtualTrailingStep;
   
   double   PriceClose=0;
   int t5;  
   bool cl02=0; 
   int Attempt4 = 0;
   
   double profit;
   
   if(OrdersTotal() > 0)
   {
   for (i = 0; i < OrdersTotal(); i++)
   {
    if (OrderSelect(i, SELECT_BY_POS,MODE_TRADES))
    {
    if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
    {		 
      if(trailingstop > 0)
      {               
         if(OrderType() == OP_BUY)
         {                      
            if( MarketInfo(Symbol(),MODE_BID) - OrderOpenPrice() >= trailingstop * pp )
              {
              if(PrCloseBuy > 0)
               {   
               
               step1=step1 +1;
               
               if( buy111 == false&&step1!=step1old)
               {
               if(step1==20)
               {
               ObjectSet("PrCloseBuy"+OrderTicket(),OBJPROP_COLOR,Red); 
               ObjectSet("PrCloseBuy"+OrderTicket(),OBJPROP_STYLE,0);
               ObjectSet("PrCloseBuy"+OrderTicket(),OBJPROP_WIDTH,2);
               buy111=true;
               step1old=step1;
               }                        
               }
               
               if( buy111 == true &&step1!=step1old)
               {
               if(step1==30)
               {
               ObjectSet("PrCloseBuy"+OrderTicket(),OBJPROP_COLOR,Lime);
               ObjectSet("PrCloseBuy"+OrderTicket(),OBJPROP_STYLE,0);
               ObjectSet("PrCloseBuy"+OrderTicket(),OBJPROP_WIDTH,2);
               buy111=false; 
               step1old=step1;
               step1=0;
               }         
               }
              
               
                 if((MarketInfo(Symbol(),MODE_BID) - pp * trailingstop) > PrCloseBuy)
                   {
                       if(((MarketInfo(Symbol(),MODE_BID) - pp * trailingstop)-PrCloseBuy)>= trailingstep * pp)
                       {             
                        //err = OrderModify(OrderTicket(), OrderOpenPrice(), MarketInfo(Symbol(),MODE_BID) - pp * trailingstop, OrderTakeProfit(), 0, Green);
                        PrCloseBuy = MarketInfo(Symbol(),MODE_BID) - pp * trailingstop;
                        ObjectMove(0,"PrCloseBuy"+OrderTicket(),0,TimeCurrent(),PrCloseBuy);
                        if (ShowLog) Print("!!! VirtualTrailingStop Work, Virtual Stop Loss Buy Order " +ticket+" move to price " +DoubleToString((MarketInfo(Symbol(),MODE_BID) - pp * trailingstop),Digits));
                        //if(err == false) { if (ShowLog) {Print("!!! Error in TrailingStop Modify Stop Loss Buy Order " +ticket+" To price " +DoubleToString((MarketInfo(Symbol(),MODE_BID) - pp * trailingstop),Digits)+" " +GetLastError());}} 
                       }
                   }
                }
                else
                      {
                      //err = OrderModify(OrderTicket(), OrderOpenPrice(), MarketInfo(Symbol(),MODE_BID) - pp * trailingstop, OrderTakeProfit(), 0, Green);
                      PrCloseBuy = MarketInfo(Symbol(),MODE_BID) - pp * trailingstop;
                      if(ObjectFind(0,"PrCloseBuy"+OrderTicket())==-1)
                      {
                      ObjectCreate(0,"PrCloseBuy" +OrderTicket(), OBJ_HLINE,0,TimeCurrent(),PrCloseBuy);                     
                      }
                      ObjectSet("PrCloseBuy" +OrderTicket(),OBJPROP_COLOR,Lime);
               	    ObjectSet("PrCloseBuy" +OrderTicket(),OBJPROP_STYLE,0);
               	    ObjectSet("PrCloseBuy" +OrderTicket(),OBJPROP_WIDTH,2);
               	    ObjectMove(0,"PrCloseBuy" +OrderTicket(),0,TimeCurrent(),PrCloseBuy);
                      if (ShowLog) Print("!!! VirtualTrailingStop Work, Virtual Stop Loss Buy Order " +ticket+" move to price " +DoubleToString((MarketInfo(Symbol(),MODE_BID) - pp * trailingstop),Digits));
                      //if(err == false) { if (ShowLog) {Print("!!! Error in TrailingStop Modify Stop Loss Buy Order " +ticket+" To price " +DoubleToString((MarketInfo(Symbol(),MODE_BID) - pp * trailingstop),Digits)+" " +GetLastError());}} 
                      }
              }
         
         

         if(MarketInfo(Symbol(),MODE_BID)<=PrCloseBuy && PrCloseBuy>0)
         {
         CloseTicket=OrderTicket();
         while(Attempt4 <= MaxAttemptsForCloseOrder && cl02 ==false )
                                 { 
                                 
                                 for (int a1=0; a1<OrdersTotal(); a1++) 
							            {
                                    if (OrderSelect(a1, SELECT_BY_POS, MODE_TRADES)) 
                                    { 
                                       if (OrderTicket()==CloseTicket) 
                                         {
                                 t5=GetTickCount(); 
                                 cl02=OrderClose(CloseTicket,OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),OrderCloseSlippage,Green);
                                 if(cl02==false)
                                    {                                   
                                    if(ShowLog)Print("!!! VirtualTrailingStop Error Close Buy Order "+OrderTicket()+" Attempt = " +Attempt4+" "+Symbol()+" "+GetErrorDescription(GetLastError()));
                                    }
                                  if(cl02==true) {break;}   
                                 } 
                                 }
                                 } 
                                 Attempt4++;                                                                                                                                                          
                                 }  
          if (cl02==true)
							 {
							 			 						
							   for (int i21=0; i21<OrdersHistoryTotal(); i21++) 
							      {
   		                     if (OrderSelect(i21, SELECT_BY_POS, MODE_HISTORY)) 
   		                       {
   			                        if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
   			                        {
      			                        if(OrderTicket()==CloseTicket)
      			                          {	
      			                          LastCloseTime=GetTickCount()-t5;			
      			                          CloseBuyPr=DoubleToStr(OrderClosePrice(),5);
                                         CloseBuySlippage=(CloseBuyPr - PriceCloseBuy)/pp;
                                         profit=(OrderClosePrice()-OrderOpenPrice()/pp);
                                         if(ShowLog)Print("!!! VirtualTrailingStop Work, Buy Order " +CloseTicket+" was closed, Slippage = " +DoubleToStr(CloseBuySlippage,2)+" pips, Close Time = " +LastCloseTime + " ms, Profit = " +NormalizeDouble(profit,2)+" pips");
                  							  if(SoundSignal){PlaySound("ok.wav");}
                  							  LastCloseSlippage=CloseBuySlippage;
                  							  PriceCloseBuy=0;							
                  							  CloseBuyPr=0;
                  							  CloseBuySlippage=0;	
                  							  t5=0;	
                  							  PrCloseBuy=0;
                  							  bool del2;
                  							  del2 = ObjectDelete("PrCloseBuy"+CloseTicket);
                  							  if(del2==0) {Print(GetLastError());}
                  							  else {if(ShowLog)Print("Delete Line Ok");}
                  							  CloseTicket=0;
      			                          }
   			                        }
   			                    }
			                  }		
							
							}	                       
                                     
         }
         
         
         }
         if(OrderType() == OP_SELL)
         {  
            if(OrderOpenPrice()- MarketInfo(Symbol(),MODE_ASK) >= trailingstop * pp)
            {
              if(PrCloseSell > 0)
               { 
      	       
      	      step2=step2 +1;
               
               if( sell111 == false&&step2!=step2old)
               {
               if(step2==20)
               {
               ObjectSet("PrCloseSell" +OrderTicket(),OBJPROP_COLOR,Red);
               ObjectSet("PrCloseSell"+OrderTicket(),OBJPROP_STYLE,0);
            	ObjectSet("PrCloseSell"+OrderTicket(),OBJPROP_WIDTH,2); 
               sell111=true;
               step2old=step2;                        
               }
               }

               if( sell111 == true &&step2!=step2old)
               {
               if(step2==30)
               {
               ObjectSet("PrCloseSell"+OrderTicket(),OBJPROP_COLOR,Lime);
               ObjectSet("PrCloseSell"+OrderTicket(),OBJPROP_STYLE,0);
            	ObjectSet("PrCloseSell"+OrderTicket(),OBJPROP_WIDTH,2);
               sell111=false; 
               step2old=step2; 
               step2=0;        
               }
               }
      	      
                 if(PrCloseSell > ( MarketInfo(Symbol(),MODE_ASK) + trailingstop * pp))
                  { 
                     if((PrCloseSell -( MarketInfo(Symbol(),MODE_ASK) + trailingstop * pp))>trailingstep*pp)
                     {                 
                        //err=OrderModify(OrderTicket(), OrderOpenPrice(),  MarketInfo(Symbol(),MODE_ASK) + trailingstop * pp, OrderTakeProfit(), 0, Green);
                        PrCloseSell= MarketInfo(Symbol(),MODE_ASK) + trailingstop * pp;
                        ObjectMove(0,"PrCloseSell"+OrderTicket(),0,TimeCurrent(),PrCloseSell);
                        if (ShowLog) Print("!!! VirtualTrailingStop Work, Virtual Stop Loss Sell Order " +ticket+" move to price "+DoubleToString(( MarketInfo(Symbol(),MODE_ASK) + trailingstop * pp),Digits));
                        //if(err == false) {if (ShowLog) {Print("!!! Error in TrailingStop Modify Stop Loss Sell Order " +ticket+" To price "+DoubleToString(( MarketInfo(Symbol(),MODE_ASK) + trailingstop * pp),Digits)+" " +GetLastError());}}
                     }
                  }
               }
               else
                     {
                     //err=OrderModify(OrderTicket(), OrderOpenPrice(),  MarketInfo(Symbol(),MODE_ASK) + trailingstop * pp, OrderTakeProfit(), 0, Green);
                     PrCloseSell= MarketInfo(Symbol(),MODE_ASK) + trailingstop * pp;
                     if(ObjectFind(0,"PrCloseSell"+OrderTicket())==-1)
                     {
                     ObjectCreate(0,"PrCloseSell" +OrderTicket(), OBJ_HLINE,0,TimeCurrent(),PrCloseSell);                     
                     }
                     ObjectSet("PrCloseSell"+OrderTicket(),OBJPROP_COLOR,Lime);
            	      ObjectSet("PrCloseSell"+OrderTicket(),OBJPROP_STYLE,0);
            	      ObjectSet("PrCloseSell"+OrderTicket(),OBJPROP_WIDTH,2);
            	      ObjectMove(0,"PrCloseSell"+OrderTicket(),0,TimeCurrent(),PrCloseSell);
                     if (ShowLog) Print("!!! VirtualTrailingStop Work, Virtual Stop Loss Sell Order " +ticket+" move to price "+DoubleToString(( MarketInfo(Symbol(),MODE_ASK) + trailingstop * pp),Digits));
                     //if(err == false) {if (ShowLog) {Print("!!! Error in TrailingStop Modify Stop Loss Sell Order " +ticket+" To price "+DoubleToString(( MarketInfo(Symbol(),MODE_ASK) + trailingstop * pp),Digits)+" " +GetLastError());}}
                     }
             }
           
         if(MarketInfo(Symbol(),MODE_ASK)>=PrCloseSell && PrCloseSell>0 )
         {
         CloseTicketSell=OrderTicket();
         while(Attempt4 <= MaxAttemptsForCloseOrder && cl02 ==false )
                                 {
                                 
                                 for (int a1=0; a1<OrdersTotal(); a1++) 
							            {
                                    if (OrderSelect(a1, SELECT_BY_POS, MODE_TRADES)) 
                                    { 
                                       if (OrderTicket()==CloseTicketSell) 
                                         {
                                 t5=GetTickCount(); 
                                 cl02=OrderClose(CloseTicketSell,OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),OrderCloseSlippage,Red);                                
                                 if(cl02==false)
                                    {                                   
                                    if(ShowLog)Print("!!! VirtualTrailingStop Error Close Sell Order "+OrderTicket()+" Attempt = " +Attempt4+" "+Symbol()+" "+GetErrorDescription(GetLastError()));
                                    } 
                                  if(cl02==true) {break;}                                                                                               
                                 }
                                 }
                                 }
                                 Attempt4++; 
                                 }   
         
         if (cl02==true)
							 {
							 						 
							 for (int i211=0; i211<OrdersHistoryTotal(); i211++) 
							    {
		                     if (OrderSelect(i211, SELECT_BY_POS, MODE_HISTORY)) 
		                       {
			                        if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
			                          {
   			                        if(OrderTicket()==CloseTicketSell)
   			                          {	
   			                          LastCloseTime=GetTickCount()-t5;	
   			                          CloseSellPr=DoubleToStr(OrderClosePrice(),5);
                                      CloseSellSlippage=(PriceCloseSell-CloseSellPr)/pp;
                                      profit=(OrderOpenPrice() - OrderClosePrice()/pp);
                                      if(ShowLog)Print("!!! VirtualTrailingStop Work, Sell Order " +CloseTicketSell+" was closed, Slippage =  " +DoubleToStr(CloseSellSlippage,2)+" pips, Close Time = " +LastCloseTime + " ms, Profit = " +NormalizeDouble(profit,2)+" pips");	
               							  if(SoundSignal){PlaySound("ok.wav");}
               							  LastCloseSlippage=CloseSellSlippage;
               							  PriceCloseSell=0;							
               							  CloseSellPr=0;
               							  CloseSellSlippage=0;
               							  t5=0;
               							  PrCloseSell=0;
               							  bool del;
               							  del = ObjectDelete("PrCloseSell"+CloseTicketSell);
               							  if(del==0) {Print(GetLastError());}
               							  else {if(ShowLog)Print("Delete Line Ok");}
               							  CloseTicketSell=0;
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
      }
   }
}





