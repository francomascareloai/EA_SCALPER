//+------------------------------------------------------------------+
//|                            MY MILLIONS EA                        |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+

#include <stdlib.mqh>
#include <stderror.mqh>
#define  NL    "\n"

extern string  _Account_Settings_      = "Set your Account info";
extern int     InitialAccount          = 50; 
extern int     GMTOffset               = 0;    //0=Broker GMT.
extern string  TradeComment            = "";
extern string  MoneyManagementset      = "Set your trading tolerance";
extern double  Portion                 = 1;      // Portion of account you want to trade on this pair
extern bool    UseEquityProtection     = false;   // Close all orders when negative Float is excessive.
extern double  FloatPercent            = 100;     // Percent of portion for max Float level.
extern bool    UsePowerOutSL           = true;   // Set to protect from internet loss
extern bool    MoneyMangement          = false;   // will autocalculate lot size, lot increment and profit target
extern double  MaximumRisk             = 5;    // equals 4% or .04 of account balance for base lot
extern double  LotSize                 = 0.1;
extern double  LotIncrement            = 0;   // must be set to .01 or greater
extern int     Slippage                = 5;      // Tolerance for opening and closing of orders
extern string  _Piplite_EA_Set_        = "Set trade parameters";
extern double  ProfitTarget            = 1;      // All orders closed when this profit target amount (in dollars) is reached
extern double  ProfitSkew              = 50;      // Increase/decrease ProfitTarget when MoneyMangement=true
extern int     ProfitMode              = 1;      // 1= mixed mode, 2= global mode, 3= split mode, 1 is best
extern bool    ProfitTrailing          = true;   // Will try to allow profit grow beyond ProfitTarget
extern double  MaxRetrace              = 2;      // Maximum percent of MaxProfit allowed to decrease before close all orders
extern bool    ReverseDirection        = false;   // true = will trade long when price is low and short and price is high. false = will trade long when price is high and short when price is low
extern bool    UseARSI                 = false;   // Adaptive RSI For Trade Entry
extern int     RSI_period              = 30;     // TF for ARSI
extern int     ima_bars                = 10;     // length of ARSI
extern double  ARSI_trigger            = 0.008;  // level to trigger trade.  Set to 0 for ATR to trigger entry
extern bool    Use_MARSI_Cross         = true;  // Helps to prevent multiple trades in Trending Market
extern double  RSIMA_MA_Period         = 10;     // Best Period
extern double  RSIMA_RSI_Period        = 14;     // Best Period
extern bool    TrendProtect            = false;
extern double  Window                  = 40.0;   // Window to define ranging market  
extern bool    Use_Entry_Delay         = true;  // Helps reduce draw down by stopping new entries if number of seconds not passed
extern double  Minimum_Entry_Delay     = 300;   // Number of seconds to wait before re-entries
extern bool    AutoSpacing             = true;   // Spacing will be calculated using StDev
extern int     StDevTF                 = 60;     // TF for StDev
extern int     StDevPer                = 12;     // lenght of StDev
extern int     StDevMode               = 3;      // mode of StDev - 0=SMA, 1=EMA, 2=SMMA, 3=LWMA 
extern int     Spacing                 = 60;     // Minimum distance of orders placed against the trend of the initial order, In effect only if AutoSpacing=false
extern int     TrendSpacing            = 1;   // Minimum distance of orders placed with the trend of the initial order (set to 1000 to disable )
extern string  _Day_Time_Set_          = "Set days and time to trade";
extern bool    UseTradeTime            = false;
extern int     TradeHourStart          = 0;
extern int     TradeHourEnd            = 24;
extern bool    Sunday                  = true;
extern bool    Monday                  = true;
extern bool    Tuesday                 = true;
extern bool    Wednesday               = true;
extern bool    Thursday                = true;
extern bool    Friday                  = true;
extern bool    NFP_Friday              = false;
extern double  DayPeriod               = 5;
extern double  hedgecarpan             =1.5;
extern double  StopLoss                =20;
extern double Baccount                 =100000000;
//+------------------------------------------------------------------+
//| Internal Parameters Set                                          |
//+------------------------------------------------------------------+ 

int            Accounttype             = 0;
int            TradeStart;
int            TradeEnd;
double         stoploss                = 0;
int            slip                    = 0;
int            Error                   = 0;
int            Order                   = 0;
int            Reference               = 0;
double         TickPrice               = 0;
bool           TradeShort              = true;           //Allow placing of sell ordes
bool           TradeLong               = true;           //Allow placing of buy orders
int            OpenOnTick              = 0;
int            MaxBuys                 = 0;
int            MaxSells                = 0;
double         MaxProfit               = 0;
int            lotPrecision;
double         POSL;
int            count;
bool           TradeAllowed            = true;
double         PortionBalance, PortionEquity;
int            BrokerDecimal           = 1;
string         POSL_On                 = "No";
double         buysl, sellsl;      
int            MaximumBuyOrders        = 3;
int            MaximumSellOrders       = 3;
double         SL                      = 20;     // Performs better with no initial stoploss. 
double GECAL=1;
double GECSAT;
double LastProfit=0,LastProfit1=0;
double LotFactor=1;
double LProfitTarget =50;
//+------------------------------------------------------------------+
//| Internal Initialization                                          |
//+------------------------------------------------------------------+ 

int init()
{
   if (Symbol() == "AUDCADm" || Symbol() == "AUDCAD") Reference = 801001;
   if (Symbol() == "AUDJPYm" || Symbol() == "AUDJPY") Reference = 801002;
   if (Symbol() == "AUDNZDm" || Symbol() == "AUDNZD") Reference = 801003;
   if (Symbol() == "AUDUSDm" || Symbol() == "AUDUSD") Reference = 801004;
   if (Symbol() == "CHFJPYm" || Symbol() == "CHFJPY") Reference = 801005;
   if (Symbol() == "EURAUDm" || Symbol() == "EURAUD") Reference = 801006;
   if (Symbol() == "EURCADm" || Symbol() == "EURCAD") Reference = 801007;
   if (Symbol() == "EURCHFm" || Symbol() == "EURCHF") Reference = 801008;
   if (Symbol() == "EURGBPm" || Symbol() == "EURGBP") Reference = 801009;
   if (Symbol() == "EURJPYm" || Symbol() == "EURJPY") Reference = 801010;
   if (Symbol() == "EURUSDm" || Symbol() == "EURUSD") Reference = 801011;
   if (Symbol() == "GBPCHFm" || Symbol() == "GBPCHF") Reference = 801012;
   if (Symbol() == "GBPJPYm" || Symbol() == "GBPJPY") Reference = 801013;
   if (Symbol() == "GBPUSDm" || Symbol() == "GBPUSD") Reference = 801014;
   if (Symbol() == "NZDJPYm" || Symbol() == "NZDJPY") Reference = 801015;
   if (Symbol() == "NZDUSDm" || Symbol() == "NZDUSD") Reference = 801016;
   if (Symbol() == "USDCHFm" || Symbol() == "USDCHF") Reference = 801017;
   if (Symbol() == "USDJPYm" || Symbol() == "USDJPY") Reference = 801018;
   if (Symbol() == "USDCADm" || Symbol() == "USDCAD") Reference = 801019;
   if (Reference == 0) Reference = 801999;
   
   
   if(Digits==3 || Digits==5){ 
          Slippage *= 10;
          BrokerDecimal = 10;}
   
   TradeStart = TradeHourStart + GMTOffset;
   TradeEnd   = TradeHourEnd   + GMTOffset; 
   
   CalculateLotPrecision();
   return(0);
}

int deinit(){
   Comment("Waiting for data tick.......................... ");
   ObjectsDeleteAll(0, OBJ_LABEL);   
   return (0);
}

void CalculateLotPrecision(){
   double lotstep=MarketInfo(Symbol(),MODE_LOTSTEP);
   if(lotstep==1) lotPrecision=0;
   if(lotstep==0.1) lotPrecision=1;
   if(lotstep==0.01) lotPrecision=2;
   if(lotstep==0.001) lotPrecision=3;
}

//+------------------------------------------------------------------+
//| Money Management and Lot size coding                             |
//+------------------------------------------------------------------+

double AutoLot()
  {
   double lot;
   
   lot=NormalizeDouble(Accounttype*((AccountBalance()/10000)*(MaximumRisk/100))/Portion,lotPrecision);
   
//Determine Lot size boundries from minimum to maximum   
//Number based on max lots at the 16 total order Point
//This allows for continued trading with large amounts
//Will keep from getting ordersend error 131 on large accounts
//Standard 100/17 = 5.88
//Micro 50/17 = 2.94
   
   if(lot<0.01) lot=0.01;
   if(lot < MarketInfo(Symbol(),MODE_MINLOT)) lot = MarketInfo(Symbol(),MODE_MINLOT);
   if(lot>5.88 && Accounttype == 1) lot=5.88;
   if(lot>2.94 && Accounttype == 10) lot=2.94;
  
   return(lot);
  }


void PlaceBuyOrder()
{
   double BuyOrders, Lots;
   double LowestBuy = 1000, HighestBuy;
     
   TickPrice = 0;

   RefreshRates();
   
   for (Order = OrdersTotal() - 1; Order >= 0; Order--)
   {
      if (OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Reference && OrderType() == OP_BUY)
         {
            if (OrderOpenPrice() < LowestBuy) LowestBuy = OrderOpenPrice();
            if (OrderOpenPrice() > HighestBuy) HighestBuy = OrderOpenPrice();
            BuyOrders++;
         }
      }
   }

   Lots = NormalizeDouble(LotSize + (LotIncrement * BuyOrders * LotFactor), lotPrecision);
  
   if(BuyOrders==0) Lots = NormalizeDouble(LotSize, lotPrecision);

   if (Lots == 0) Lots = NormalizeDouble(LotSize, lotPrecision);
     
   if(IsTradeAllowed()==true  && (BuyOrders < MaximumBuyOrders))
   {
      if (SL == 0) stoploss = 0; 
      else stoploss = Ask - ((SL*BrokerDecimal) * Point);
      
			if(-1 == OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, stoploss, 0, TradeComment, Reference, 0, Green))
				Print("Error opening BUY order: " + ErrorDescription(GetLastError()) + " (C" + GetLastError() + ")  Ask:" + Ask + "  Slippage:" + Slippage);
			else TickPrice = Close[0];
   }
/*
   Error = GetLastError();
   if (Error != 0)
      Print("Error opening BUY order: " + ErrorDescription(Error) + " (C" + Error + ")  Ask:" + Ask + "  Slippage:" + Slippage);
   else
   {
      TickPrice = Close[0];
   }
*/
}

void PlaceSellOrder()
{
   double SellOrders, Lots;
   double HighestSell, LowestSell = 1000;
   
   TickPrice = 0;

   RefreshRates();
   
   for (Order = OrdersTotal() - 1; Order >= 0; Order--)
   {
      if (OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Reference && OrderType() == OP_SELL)
         {
            if (OrderOpenPrice() > HighestSell) HighestSell = OrderOpenPrice();
            if (OrderOpenPrice() < LowestSell) LowestSell = OrderOpenPrice();
            SellOrders++;
         }
      }
   }
   
   Lots = NormalizeDouble(LotSize + (LotIncrement * SellOrders*LotFactor), lotPrecision);
   
   if(SellOrders==0) Lots = NormalizeDouble(LotSize, lotPrecision);

   if (Lots == 0) Lots = NormalizeDouble(LotSize, lotPrecision);
   
   if(IsTradeAllowed()==true && (SellOrders < MaximumSellOrders))
   {  
      if (SL == 0) stoploss = 0; 
      else stoploss = Bid + ((SL*BrokerDecimal) * Point); 
      
			if(-1 == OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, stoploss, 0, TradeComment, Reference, 0, Red))
				Print("Error opening SELL order: " + ErrorDescription(GetLastError()) + " (D" + GetLastError() + ")  Bid:" + Bid + "  Slippage:" + Slippage);
			else TickPrice = Close[0];
   }
/*  
   Error = GetLastError();
   if (Error != 0)
      Print("Error opening SELL order: " + ErrorDescription(Error) + " (D" + Error + ")  Bid:" + Bid + "  Slippage:" + Slippage);
   else
   {
      TickPrice = Close[0];
   }
*/
}

void CloseAllBuyProfit()
{
int spread=MarketInfo(Symbol(),MODE_SPREAD);
   for(int i = OrdersTotal()-1; i >=0; i--)
       {
       OrderSelect(i, SELECT_BY_POS);
       bool result = false;
       if (OrderSymbol()==Symbol() && OrderMagicNumber() == Reference && OrderType() == OP_BUY)  
         {
           
           if (TimeCurrent()-OrderOpenTime() >=20) result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), Slippage, Aqua );
         }
       }
     
  return; 
}

void CloseAllSellProfit()
{
int spread=MarketInfo(Symbol(),MODE_SPREAD);
   for(int i = OrdersTotal()-1; i >=0; i--)
      {
      OrderSelect(i, SELECT_BY_POS);
      bool result = false;
      if (OrderSymbol()==Symbol() && OrderMagicNumber() == Reference && OrderType() == OP_SELL) 
       {
         
         if (TimeCurrent()-OrderOpenTime() >=20) result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), Slippage, Lime );
       }
     }
 
  return; 
}

//+------------------------------------------------------------------+
//| Start Expert Code                                                |
//+------------------------------------------------------------------+ 

int start()
{
   if(MoneyMangement){LotSize=AutoLot();
      if(LotIncrement>0) LotIncrement=LotSize;}
   int            Session = 1;
   double         TotalProfit=0; 
   double         TotalOrders=0;
   double         TotalLots=0; 
   double         MarginPercent;
   static double  LowMarginPercent = 10000000, LowEquity = 10000000;
   double         BuyPipTarget, SellPipTarget;
   int            SellOrders, BuyOrders;
   double         BuyPips, SellPips, BuyLots, SellLots;
   double         LowestBuy = 999, HighestBuy = 0.0001, LowestSell = 999, HighestSell = 0.0001, HighPoint, MidPoint, LowPoint;
   double         Profit = 0, BuyProfit = 0, SellProfit = 0, PosBuyProfit = 0, PosSellProfit = 0;
   int            HighestBuyTicket, LowestBuyTicket, HighestSellTicket, LowestSellTicket;
   double         HighestBuyProfit, LowestBuyProfit, HighestSellProfit, LowestSellProfit;
   bool           SELLme = false;
   bool           BUYme = false;
   double         Margin = MarketInfo(Symbol(), MODE_MARGINREQUIRED);
   string         Message;
   bool           ProfitTargetReached = false; 
   datetime       LastOrderDateTime = 0;
   bool           EntryAllowed = true;  // can be used anywhere in start code to disable new entries for any reason
   int timehr,timemin;      
//+------------------------------------------------------------------+
//| Profit Count Code                                                |
//+------------------------------------------------------------------+


  
   

   for (Order = OrdersTotal() - 1; Order >= 0; Order--)
   {
      if (OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Reference)
         {
            // get the lastest date/time
            if (OrderOpenTime() > LastOrderDateTime)
               LastOrderDateTime= OrderOpenTime();
            
            Profit = OrderProfit() + OrderSwap() + OrderCommission();
            
            if (OrderType() == OP_BUY)
            {
               if (OrderOpenPrice() >= HighestBuy)
               {
                  HighestBuy = OrderOpenPrice();
                  HighestBuyTicket = OrderTicket();
                  HighestBuyProfit = Profit;
               }

               if (OrderOpenPrice() <= LowestBuy)
               {
                  LowestBuy = OrderOpenPrice();
                  LowestBuyTicket = OrderTicket();
                  LowestBuyProfit = Profit;
               }

               BuyOrders++;
               if (BuyOrders > MaxBuys) MaxBuys = BuyOrders;
               BuyLots += OrderLots();

               BuyProfit += Profit;
               if (Profit > 0) PosBuyProfit += Profit; 
               
            }

            if (OrderType() == OP_SELL)
            {
               if (OrderOpenPrice() <= LowestSell)
               {
                  LowestSell = OrderOpenPrice();
                  LowestSellTicket = OrderTicket();
                  LowestSellProfit = Profit;
               }

               if (OrderOpenPrice() >= HighestSell)
               {
                  HighestSell = OrderOpenPrice();
                  HighestSellTicket = OrderTicket();
                  HighestSellProfit = Profit;
               }

               SellOrders++;
               if (SellOrders > MaxSells) MaxSells = SellOrders;
               SellLots += OrderLots();

               SellProfit += Profit;
               if (Profit > 0) PosSellProfit += Profit; 
            }
         }
      }
   }

   if (HighestBuy >= HighestSell)
      HighPoint = HighestBuy;
   else
      HighPoint = HighestSell;

   if (LowestBuy <= LowestSell)
      LowPoint = LowestBuy;
   else
      LowPoint = LowestSell;

   MidPoint = (HighPoint + LowPoint) / 2;

   RefreshRates();

//+------------------------------------------------------------------+
//| Total Profit, Max Profit, Total Lots and Portion Set Code        |
//+------------------------------------------------------------------+
   
if(TotalProfit<-500)GECAL=0; 
else GECAL=1;

  TotalProfit = NormalizeDouble((BuyProfit + SellProfit),2);
  TotalOrders = NormalizeDouble((BuyOrders + SellOrders),0);
  TotalLots   = NormalizeDouble((BuyLots + SellLots),2);
  PortionBalance = NormalizeDouble(AccountBalance()/Portion,2);
  PortionEquity  = NormalizeDouble(PortionBalance + TotalProfit,2); 
  if(TotalProfit > MaxProfit) MaxProfit = TotalProfit;
  if(TotalOrders == 0 || TotalProfit <= 0)  MaxProfit = 0;
      LotSize=0.01;
if(TotalProfit<-40)LotSize=0.08;
else LotSize=0.02; 
  timehr  =TimeHour(TimeCurrent());
  timemin =TimeMinute (TimeCurrent());

  if(timehr >= 0 && timehr < 23)
  {
  timehr=timehr;
  }
  
  else
   {

    if(TotalProfit >= 1)
    { 
      ExitAllTrades(Red,"Max P/L Reached");
      LastProfit=0;LastProfit1=0;LotFactor=1;  
       
      return;
     } 
   }


//if(BuyOrders+SellOrders>10 && LotSize==0.01)LotSize=0.03;
//+------------------------------------------------------------------+
//| Account Protection                                               |
//+------------------------------------------------------------------+ 
    

//+------------------------------------------------------------------+
//| Trading with EA Criteria                                         |
//+------------------------------------------------------------------+

double PortionBalancetrade, InitialAccountMultiPortion;
 
      PortionBalancetrade = NormalizeDouble(AccountBalance()/Portion,0);
      InitialAccountMultiPortion = InitialAccount/Portion;

      if (PortionBalancetrade < InitialAccountMultiPortion){ 
              PlaySound("alert.wav"); 
              MessageBox( "Account Balance is less than Hard Line Balance Setting on " + Symbol()+ Period(), "Piplite: Warning", 48 );
  return(0);}

//+------------------------------------------------------------------+
//| Profit Target if Money Management is Utilized                    |
//+------------------------------------------------------------------+

  double diClose3=iClose(NULL,5,0);
 double diMAW=iMA(NULL,PERIOD_M5,140,0,MODE_LWMA,PRICE_OPEN,0);

double dspacing = iStdDev(Symbol(),StDevTF,StDevPer,0,StDevMode,PRICE_OPEN,0)/Point;
ProfitTarget=dspacing;

//if(LastProfit>0 && BuyLots+SellLots >1 && TotalProfit>-20)
 //   ExitAllTrades(Lime,"STOPLOSS");
 //if(LastProfit<0)LProfitTarget=2;
 
 //if(GECAL==0  && (BuyLots+ SellLots>1)&& diClose3>lowboll1 && BuyProfit>10)CloseAllBuyProfit(); 
 // if(GECAL==0  && (BuyLots+ SellLots>1)&& diClose3<highboll1 && SellProfit>10)CloseAllSellProfit();
//if(TotalProfit<-400 )  ExitAllTrades(Lime,"STOPLOSS");

 // if(BuyOrders+SellOrders>50 && TotalProfit>-70) ExitAllTrades(Lime,"STOPLOSS"); 
  
  
  if(GECAL==0)ProfitTarget=-LastProfit;
   
//if(LastProfit1>0 && LastProfit<0 && BuyLots+SellLots >0.5 && TotalProfit>-100)
//     ExitAllTrades(Lime,"STOPLOSS");
//if(LastProfit1<0 && LastProfit<0 && BuyLots+SellLots >1.5&& TotalProfit>-150)
 //     ExitAllTrades(Lime,"STOPLOSS");
//if(LastProfit<0 &&LastProfit1>0 )ProfitTarget=-LastProfit;
  //if(LastProfit<0 &&LastProfit1<0 )ProfitTarget=-(LastProfit+LastProfit1);    
//if( TotalProfit<-10)  ExitAllTrades(Lime,"En YUKSEK PROFÝT");


if(BuyProfit>-TotalProfit/2 && SellOrders>0 && SellOrders<4)CloseAllBuyProfit(); 
if(SellProfit>-TotalProfit/2&& BuyOrders>0 && BuyOrders<4)CloseAllSellProfit(); 
 
//if(diMAW>diClose3)CloseAllBuyProfit(); 
//if(diMAW<diClose3 )CloseAllSellProfit(); 

//+-----------------------------------------
//-------------------------+
//| Trailing Profit and Additional Take Profit Code                  |
//+------------------------------------------------------------------+

  if(ProfitTrailing){
   ProfitMode=0;
   if(TotalProfit >=ProfitTarget  && TotalProfit <= (MaxProfit-(MaxProfit*MaxRetrace)/100))
      ExitAllTrades(Lime,"Max profit reached");}

//+------------------------------------------------------------------+
//| Profit Taking Mode Code                                          |
//+------------------------------------------------------------------+

 if (ProfitMode==1 || ProfitMode==2 && BuyProfit + SellProfit >= ProfitTarget) 
 {
   for (Order = OrdersTotal() - 1; Order >= 0; Order--)
   {
    if (OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
    {
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Reference)            
      {
         OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage, Green);
      }   
    Error = GetLastError();
    if (Error != 0) Print("Error closing order " + OrderTicket() + ": " + ErrorDescription(Error) + " (F" + Error + ")  Lots:" + OrderLots() + "  Ask:" + MarketInfo(OrderSymbol(), MODE_ASK));    
    }
   }
 }

 


//+------------------------------------------------------------------+
//| Power Out Stop Loss Protection                                   |
//+------------------------------------------------------------------+ 

  if(UsePowerOutSL) {
     int correct = 1;
     double pipvalue=MarketInfo(Symbol(),MODE_TICKVALUE);
     if(Accounttype == 1 && pipvalue < 5) correct = 10;
     POSL_On = "Yes";
     if(TotalLots > 0){
       POSL =  NormalizeDouble((PortionBalance * (FloatPercent + 1)/100)/(pipvalue * TotalLots * correct),0);
       if(POSL > 600) POSL = 600;}
     if(Digits==3 || Digits==5) POSL *= 10;
     buysl = Ask - POSL * Point;
     sellsl= Bid + POSL * Point;
     if(TotalOrders == 0) count = 0;
     if(TotalOrders > 0 && TotalOrders > count){
     
     for (int q = 0; q < OrdersTotal(); q++) {
        OrderSelect (q, SELECT_BY_POS, MODE_TRADES);
        if ((OrderMagicNumber()==Reference) && (OrderSymbol()==Symbol()) && (OrderType()==OP_BUY)) {
            OrderModify(OrderTicket(), OrderOpenPrice(), buysl, 0, 0, Purple);
        }
        if ((OrderMagicNumber()==Reference) && (OrderSymbol()==Symbol()) && (OrderType()==OP_SELL)) {
            OrderModify(OrderTicket(), OrderOpenPrice(), sellsl, 0, 0, Purple);} } } 
        count = TotalOrders;
        }

//+------------------------------------------------------------------+
//| Reverse Direction Decision                                       |
//+------------------------------------------------------------------+

   int Direction= Direction();
   if(ReverseDirection)  Direction = -Direction;


 


  double diClose0=iClose(NULL,5,0);
   double diMA1=iMA(NULL,5,5,0,MODE_LWMA,PRICE_OPEN,0);
   double diClose2=iClose(NULL,5,0);
   double diMA3=iMA(NULL,5,5,0,MODE_LWMA,PRICE_OPEN,0);
   
   
   

 double   Now=iHigh(NULL,PERIOD_H4,0);
 double   NowL=iLow(NULL,PERIOD_H4,0);
    
   double val=iBearsPower(NULL, 0, 50,PRICE_CLOSE,0);
 double val1=iBearsPower(NULL, 0, 50,PRICE_CLOSE,1);
 
 double dspacingW = iStdDev(Symbol(),PERIOD_H1,StDevPer,0,StDevMode,PRICE_OPEN,0)/Point;
      if (diMAW<diClose0  && val>0 && val1<val )Direction = 1 ;
      if (diMAW>diClose0  && val<0 &&val1>val) Direction = -1;
      if(BuyOrders<4 && TotalProfit<-20&& SellOrders>4)Direction=1;
      if(SellOrders<4 && TotalProfit<-20 && BuyOrders>4)Direction=-1;
   if((Now-NowL)>0.005)Direction=0;
   if(dspacingW>25)LotSize=0.01;
  // if(BuyOrders>0&& val<-0.001)CloseAllBuyProfit(); 
//if(SellOrders>0&& val>0.002 )CloseAllSellProfit();
   //--------------------------------------------------------------------//
   
   
   
   
   
   
   
       
double MarginCall; 
if (AccountMargin()>0) MarginCall=(AccountEquity()/(AccountMargin())*100);
else MarginCall = 100;


//if(RSI_11>RSI_22 && RSI_11>80  )OrderSend(Symbol(), OP_BUY, NormalizeDouble(0.01, 2), Ask, Slippage, stoploss, 0, TradeComment, Reference, 0, Green);
//if(RSI_11<RSI_22 && RSI_11<20  )OrderSend(Symbol(), OP_SELL, NormalizeDouble( 0.01,2), Bid, Slippage, stoploss, 0, TradeComment, Reference, 0, Green);


//double  lowbollH = iBands(NULL,PERIOD_D1,14,1,0,PRICE_HIGH,MODE_LOWER,0);
//double highbollH = iBands(NULL,PERIOD_D1,14,1,0,PRICE_LOW,MODE_UPPER,0);
// double ima2   =iMA(NULL,PERIOD_D1,5,0,MODE_LWMA,PRICE_OPEN,0);
// double diClose0=iClose(NULL,PERIOD_M15,0);
//if (diClose0<lowbollH && MarginCall < 120 &&  ima2 < diClose0 ) CloseAllSellProfit();
//if ( diClose0>highbollH && MarginCall < 120 &&  ima2 > diClose0  ) CloseAllBuyProfit();

//+------------------------------------------------------------------+
//| Variable Spacing Code                                            |
//+------------------------------------------------------------------+

   if (AutoSpacing == 1){

//double stddev = iStdDev(Symbol(),PERIOD_M15,StDevPer,0,StDevMode,PRICE_OPEN,0);

     //double diMA1=iMA(NULL,PERIOD_H1,5,0,MODE_LWMA,PRICE_OPEN,0);
     //double diClose3=iClose(NULL,PERIOD_M5,0);
    //GECAL=0;
    //GECSAT=0;
    //if(stddev>0.002)stddev=0.002;
   //if(diClose3> diMA1  )GECAL=1;
   // if(diClose3< diMA1)GECSAT=1; 
     
    
      Spacing = 1;
 
 if(GECAL==0) Spacing = 3;
 if(TotalProfit<-100)Spacing = 2;
  //  if(TotalProfit<-150)Spacing = 8;
  //   if(TotalProfit<-400)Spacing = 15;  
  //     if(stddev2>40)Spacing = 40;      
      if(TrendSpacing != 1000)  TrendSpacing=1;
      else TrendSpacing = 1000;}
         if(GECAL==0)TrendSpacing=3;  
  //   if(BuyOrders+SellOrders>15)TrendSpacing=7;
    if(TotalProfit<-200)TrendSpacing=3;
   //   if(stddev2>40)TrendSpacing=10; 


//if(GECAL==0&& LastProfit1>0&&TotalProfit<-100)LotSize=LotSize*2;
//if(GECAL==0&& LastProfit1>0&&TotalProfit<-150)LotSize=LotSize*4;
//if(LastProfit<0&& LastProfit1>0 && TotalProfit<-100 )LotSize=0.06;
//if(LastProfit<0&& LastProfit1<0)LotSize=0.06;
//if(LastProfit<0&& LastProfit1<0 && TotalProfit<-300 )LotSize=0.12;



//+------------------------------------------------------------------+
//| Trending Protection Code                                         |
//+------------------------------------------------------------------+

if(TrendProtect){
      double rsivalue, high, low;
      rsivalue = NormalizeDouble(iRSI(NULL,0,14,PRICE_CLOSE,0),0);
      high     = NormalizeDouble((50 + Window/2),0);
      low      = NormalizeDouble((50 - Window/2),0);}

//+------------------------------------------------------------------+
//| Entry Delay Code                                                 |
//+------------------------------------------------------------------+

  if (Use_Entry_Delay == true && LastOrderDateTime != 0){
    if (CurTime() - LastOrderDateTime < Minimum_Entry_Delay)
      EntryAllowed= false;}

//+------------------------------------------------------------------+
//| Open Trading Code                                                |
//+------------------------------------------------------------------+

if(TradeAllowed && EntryAllowed){
   // BUY Trade Criteria
   if (HighestBuy > 0 && LowestBuy < 1000)
   {
      if (Ask <= LowestBuy - (Spacing * Point) || Ask >= HighestBuy + (TrendSpacing * Point))
      {
         BUYme = true;
         if (OpenOnTick == 1 && TickPrice > 0 && Close[0] < TickPrice) BUYme = true;
      }
      
      if(TrendProtect){
          if (rsivalue >=high || rsivalue <=low) BUYme = false;
          }
      if (Direction != 1) BUYme = false;
      if (UseTradeTime && !isTimetoTrade(TradeStart, TradeEnd)){
           BUYme = false;
           Session = 1;}
      else Session = 2;
      if (BUYme && TradeLong==true) PlaceBuyOrder();
   }

   // SELL Trade Criteria
   if (HighestSell > 0 && LowestSell < 1000)
   {
      if (Bid >= HighestSell + (Spacing * Point) || Bid <= LowestSell - (TrendSpacing * Point))
      {
         SELLme = true;
         if (OpenOnTick == 1 && TickPrice > 0 && Close[0] > TickPrice) SELLme = true;
      }
      
      if(TrendProtect){
          if (rsivalue >=high || rsivalue <=low) SELLme = false;
          }
      if (Direction != -1)SELLme = false;
      if (UseTradeTime && !isTimetoTrade(TradeStart, TradeEnd)){
           SELLme = false;
           Session = 1;}
      else Session = 2;
      if (SELLme && TradeShort==true) PlaceSellOrder();
   }
 }  

//+------------------------------------------------------------------+
//| External Script Code                                             |
//+------------------------------------------------------------------+

   Message = "                            " + NL + NL +                          
             
             "                            Trade Start Time         " + DoubleToStr(TradeStart, 0) + NL +
             "                            Trade Ending Time           " + DoubleToStr(TradeEnd, 0) + NL +
             "                            Current Time      " +  TimeToStr(TimeCurrent(), TIME_SECONDS) + NL +
             "                            ======================" + NL + 
             
             "                            Account Setting              " + DoubleToStr(InitialAccount, 0) + NL +
             "                            Account Protection Percentage      " + DoubleToStr(dspacingW, 6) + NL + 
             "                            Margin Call         " + DoubleToStr(MarginCall, 0) + NL + 
             "                            Target Profit  " + DoubleToStr(ProfitTarget, 2) + "   MaxProfit   " + DoubleToStr(MaxProfit, 2) + NL + NL +
             
             "                            Start Size      " + DoubleToStr(LotSize, 2) + NL + 
             "                            Recall Strategy       " + DoubleToStr(GECAL, 0) + NL + NL +             
             "                            Retrieval   " + BuyLots + "  Sell   " + SellLots + NL + NL +
             "                            Last Profit  " + DoubleToStr(LastProfit, 4) + "   LASTPROFIT  " + DoubleToStr(LastProfit, 4) + NL +  
             "                            Leverage                  " + AccountLeverage() + NL +              
             "                            Part Status      " + DoubleToStr(PortionBalancetrade, 2)+ NL +
             "                            Time      " + TimeHour(TimeCurrent()) +":"+ TimeMinute (TimeCurrent())+ NL +
             "";
            
            
   Comment(Message);
 
//+------------------------------------------------------------------+
//| Chart Overlay Information Section 2                              |
//+------------------------------------------------------------------+
   
   
   ObjectSet("ObjLabel6",OBJPROP_XDISTANCE,5);
   ObjectSet("ObjLabel6",OBJPROP_YDISTANCE,3);
   
   ObjectCreate("ObjLabe23",OBJ_LABEL,0,0,0);
   ObjectSetText("ObjLabe23","PROFIT/LOSS   = ",9,"Arial Bold",Red);
   ObjectSet("ObjLabe23",OBJPROP_CORNER,0);
   ObjectSet("ObjLabe23",OBJPROP_XDISTANCE,88);
   ObjectSet("ObjLabe23",OBJPROP_YDISTANCE,130);
if(TotalProfit >= 0){   
   ObjectCreate("ObjLabel24",OBJ_LABEL,0,0,0);
   ObjectSetText("ObjLabel24",DoubleToStr(TotalProfit, 2),9,"Arial Bold",LimeGreen);
   ObjectSet("ObjLabel24",OBJPROP_CORNER,0);
   ObjectSet("ObjLabel24",OBJPROP_XDISTANCE,200);
   ObjectSet("ObjLabel24",OBJPROP_YDISTANCE,130);}
if(TotalProfit < 0){   
   ObjectCreate("ObjLabel24",OBJ_LABEL,0,0,0);
   ObjectSetText("ObjLabel24",DoubleToStr(TotalProfit, 2),9,"Arial Bold",Red);
   ObjectSet("ObjLabel24",OBJPROP_CORNER,0);
   ObjectSet("ObjLabel24",OBJPROP_XDISTANCE,200);
   ObjectSet("ObjLabel24",OBJPROP_YDISTANCE,130);}
   
if(Session == 1){
   ObjectCreate("ObjLabel15",OBJ_LABEL,0,0,0);
   ObjectSetText("ObjLabel15","TRADE BEGAN",9,"Arial Bold",LimeGreen);
   ObjectSet("ObjLabel15",OBJPROP_CORNER,0);
   ObjectSet("ObjLabel15",OBJPROP_XDISTANCE,88);
   ObjectSet("ObjLabel15",OBJPROP_YDISTANCE,18);}
   
if(Session == 2){
   ObjectCreate("ObjLabel15",OBJ_LABEL,0,0,0);
   ObjectSetText("ObjLabel15","TRADE BEGAN",9,"Arial Bold",LimeGreen);
   ObjectSet("ObjLabel15",OBJPROP_CORNER,0);
   ObjectSet("ObjLabel15",OBJPROP_XDISTANCE,88);
   ObjectSet("ObjLabel15",OBJPROP_YDISTANCE,18);}
   
if (ObjectFind("MidPoint") != 0){
   ObjectCreate("MidPoint", OBJ_HLINE, 0, Time[0], MidPoint);
   ObjectSet("MidPoint", OBJPROP_COLOR, Gold);
   ObjectSet("MidPoint", OBJPROP_WIDTH, 2);}
else{
   ObjectMove("MidPoint", 0, Time[0], MidPoint);}
         
return (0);
}

//+------------------------------------------------------------------+
//| Trade Direction Determination, 1 = long, -1 = short              |
//+------------------------------------------------------------------+

int Direction(){
  int tradeDirection;
  if (((UseARSI && ARSIDecision()  == 1) || !UseARSI) && 
      ((Use_MARSI_Cross && MARSI_Cross_Decision() == 1) || !Use_MARSI_Cross))
  {
      tradeDirection=1;
  }
  
  if (((UseARSI && ARSIDecision() == -1) || !UseARSI) && 
      ((Use_MARSI_Cross && MARSI_Cross_Decision() == -1) || !Use_MARSI_Cross))
   
  {
   tradeDirection=-1;
  }
  if ((ARSIDecision()==0 && MARSI_Cross_Decision()==0) || (!UseARSI && !Use_MARSI_Cross)) tradeDirection=0;
 
  return (tradeDirection);}

//+------------------------------------------------------------------+
//| Calculate the MA of RSI to use for MARSI cross                   |
//+------------------------------------------------------------------+

double Latest_MA_of_RSI(){
   // calculation variables for MA of RSI
   double RSI_Sum = 0;
   // get the RSI values
   for(int bar= 0; bar< RSIMA_MA_Period; bar++)
      RSI_Sum += iRSI(NULL, 0, RSIMA_RSI_Period, PRICE_CLOSE, bar);
     
   return (RSI_Sum / RSIMA_MA_Period);}

//+------------------------------------------------------------------+
//| MARSI Cross for Trade Decision                                   |
//+------------------------------------------------------------------+ 

int MARSI_Cross_Decision(){
   int tradeDirection;
   if (Use_MARSI_Cross==true){
        if (Latest_MA_of_RSI() < iRSI(NULL, 0, RSIMA_RSI_Period, PRICE_CLOSE, 0))
          tradeDirection = 1;
        else
          tradeDirection = -1;}      
      
   return(tradeDirection);}

//+------------------------------------------------------------------+
//| Adaptive RSI Indicator Decision                                  |
//+------------------------------------------------------------------+ 

int ARSIDecision(){
 int tradeDirection;

   if(UseARSI==true){

   
      if (  GECAL==1) {tradeDirection=1;}
      if (  GECAL==1) {tradeDirection=-1;}
      if (  GECAL==0) {tradeDirection=1;}
      if (  GECAL==0) {tradeDirection=-1;} }
   else
   tradeDirection = 0;

   return(tradeDirection);}



//+------------------------------------------------------------------+
//| Trade Timing Function                                            |
//+------------------------------------------------------------------+

bool isTimetoTrade(int OpenHour, int CloseHour){
   if (!isDaytoTrade()) return(false);
   bool check = false;
   if (OpenHour > 23 || OpenHour < 0 ) OpenHour = 0;
   if (CloseHour > 23 || CloseHour < 0 ) CloseHour = 0;
   if (OpenHour<CloseHour && (Hour()>=OpenHour && Hour()<CloseHour)) check=true;
   if (OpenHour>CloseHour && (Hour()>=OpenHour || Hour()<CloseHour)) check=true;
   
return(check);}

//+------------------------------------------------------------------+
//| Trade Day Function                                               |
//+------------------------------------------------------------------+

bool isDaytoTrade(){
   bool daytotrade = false;
   
        if(DayOfWeek() == 0 && Sunday)                    daytotrade = true;
        if(DayOfWeek() == 1 && Monday)                    daytotrade = true;
        if(DayOfWeek() == 2 && Tuesday)                   daytotrade = true;
        if(DayOfWeek() == 3 && Wednesday)                 daytotrade = true;
        if(DayOfWeek() == 4 && Thursday)                  daytotrade = true;
        if(DayOfWeek() == 5 && Friday)                    daytotrade = true;
        if(DayOfWeek() == 5 && Day() < 8 && !NFP_Friday ) daytotrade = false;

return(daytotrade);}

//+------------------------------------------------------------------+
//| Exit Trade Function                                              |
//+------------------------------------------------------------------+ 

void ExitAllTrades(color Color, string reason){
   bool success;
   LastProfit1=LastProfit;
   LastProfit=0;
   for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt --){
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Reference){
      LastProfit+=OrderProfit();
         success=OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage, Color);
         if(success==true){
            Print("Closed all positions because ",reason);} } } 
            if(LastProfit<0)LotFactor=1;
            else LotFactor=LotFactor+0.1;
            
            }   


