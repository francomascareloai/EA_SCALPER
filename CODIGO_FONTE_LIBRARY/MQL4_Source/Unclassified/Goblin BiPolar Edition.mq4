// Goblin BiPolar Edition v.1.0
// by bluto @ www.forex-tsd.com
// 12/20/2006
//
// Here's a roughly cobbled version of Goblin that supports two EA routines in one - a buy side and a sell side running concurrently.
// Although effective, the code isn't the most modular at this point.  If the concept proves to be viable, I'll continue further
// development to optimize shared subroutines between the two sub-EA routines.  For now...play, test & be bodaceous! 
// Settings & idea by xxDavidxSxx

extern string    SystemWideParms = "** Goblin Systemwide Parameters **";

extern double    LotSize = 0.1;                          // First order will be for this lot size
extern bool      UseMoneyMgmt=true;                      // if true, the lots size will increase based on account size 
extern double    EquityProtectionLevel=0.0;              // Min. equity to preserve in the event things go bad; all orders for Symbol/Magic will be closed.
extern double    MaxLossPerOrder=0.0;                    // Max. loss tolerance per order; once reached, order will be closed.
extern double    TargetEquityToCloseAndReset=1; 
extern double       RiskPercent=1.0;                        // risk to calculate the lots size (only if mm is enabled)
extern bool      UseFiboLotSizeProgression=false;
extern bool      UseConservativeRSX_Signals=false;        // If true, we use tighter RSX 70/30 rules
extern int       RSX_Period=3;
extern int       RSX_Timeframe=15;
extern bool      UseSMATrendFilter=false;
extern int       TrendFilterSMATimeFrame=60;
extern int       TrendFilterFastSMAPeriod=65;
extern int       TrendFilterMediumSMAPeriod=20;
extern int       TrendFilterSlowSMAPeriod=7;

extern string    LongTradeParms = "** Goblin Buy Side Parameters **";
extern double    LongTakeProfit = 15;           // Profit Goal for the latest order opened
extern double    LongInitialStop = 0;           // StopLoss
extern double    LongTrailingStop = 0;         // Pips to trail the StopLoss
extern int       LongMaxTrades=6;               // Maximum number of orders to open
extern int       LongPips=23;                    // Distance in Pips from one order to another
extern int       LongSecureProfit=10000;           // If profit made is bigger than SecureProfit we close the orders
extern bool      LongAccountProtection=false;   // If one the account protection will be enabled, 0 is disabled
extern int       LongOrderstoProtect=0;         // This number subtracted from LongMaxTrades is the number of open orders to enable the account protection.
                                                // Example: (LongMaxTrades=10) minus (OrderstoProtect=3)=7 orders need to be open before account protection is enabled.
                                                
extern string    ShortTradeParms = "** Goblin Sell Side Parameters **";

extern double    ShortTakeProfit = 18;          // Profit Goal for the latest order opened
extern double    ShortInitialStop = 0;          // StopLoss
extern double    ShortTrailingStop = 0;        // Pips to trail the StopLoss
extern int       ShortMaxTrades=4;              // Maximum number of orders to open
extern int       ShortPips=21;                   // Distance in Pips from one order to another
extern int       ShortSecureProfit=10000;          // If profit made is bigger than SecureProfit we close the orders
extern bool      ShortAccountProtection=false;  // If one the account protection will be enabled, 0 is disabled
extern int       ShortOrderstoProtect=0;        // This number subtracted from LongMaxTrades is the number of open orders to enable the account protection.
                                                // Example: (LongMaxTrades=10) minus (OrderstoProtect=3)=7 orders need to be open before account protection is enabled. 
                                                 
                                                 
// Global internal parameters used by LongGoblin() buy order module:   
                        
int              LongMagicNumber = 0;            // Magic number for the long orders placed                              
int              L_OpenOrders=0;
int              L_Count=0;
int              L_Slippage=5;
double           L_sl=0;
double           L_tp=0;
double           BuyPrice=0;
double           L_OrderLotSize=0;
int              L_Mode=0;
int              L_OrderType=0;
bool             L_ContinueOpening=true;
double           L_LastPrice=0;
int              L_PreviousOpenOrders=0;
double           L_Profit=0;
int              L_LastTicket=0;
int              L_LastType=0;
double           L_LastClosePrice=0;
double           L_LastLots=0;
double           L_PipValue=0;

// Global internal parameters used by ShortGoblin() sell order module:
   
int              ShortMagicNumber = 0;           // Magic number for the short orders placed                            
int              S_OpenOrders=0;
int              S_Count=0;
int              S_Slippage=5;
double           S_sl=0;
double           S_tp=0;
double           SellPrice=0;
double           S_OrderLotSize=0;
int              S_Mode=0;
int              S_OrderType=0;
bool             S_ContinueOpening=true;
double           S_LastPrice=0;
int              S_PreviousOpenOrders=0;
double           S_Profit=0;
int              S_LastTicket=0;
int              S_LastType=0;
double           S_LastClosePrice=0;
double           S_LastLots=0;
double           S_PipValue=0;


// Global internal shared parameters

string           text="", text2="";
double           DnTrendVal=0,UpTrendVal=0,TrendVal=0;
string           TrendTxt="analyzing...";
int              trendtype=0;
bool             AllowTrading=true;
double           G_MinLotSize=0;
double           G_MaxLotSize=0;
double           G_LotStep=0;
double           G_Decimals=0;
int              G_AcctLeverage=0;
int              G_CurrencyLotSize=0;
double           G_OrderLotSize=0;
int              G_Count=0;
int              G_Slippage=5;


int init()
  {

// For those of us tired of messing around assigning annoying but essential magic numbers.
   
   if (Symbol()=="AUDCADm" || Symbol()=="AUDCAD") {LongMagicNumber=100001;ShortMagicNumber=200001;}
   if (Symbol()=="AUDJPYm" || Symbol()=="AUDJPY") {LongMagicNumber=100002;ShortMagicNumber=200002;}
   if (Symbol()=="AUDNZDm" || Symbol()=="AUDNZD") {LongMagicNumber=100003;ShortMagicNumber=200003;}
   if (Symbol()=="AUDUSDm" || Symbol()=="AUDUSD") {LongMagicNumber=100004;ShortMagicNumber=200004;}
   if (Symbol()=="CHFJPYm" || Symbol()=="CHFJPY") {LongMagicNumber=100005;ShortMagicNumber=200005;}
   if (Symbol()=="EURAUDm" || Symbol()=="EURAUD") {LongMagicNumber=100006;ShortMagicNumber=200006;}
   if (Symbol()=="EURCADm" || Symbol()=="EURCAD") {LongMagicNumber=100007;ShortMagicNumber=200007;}
   if (Symbol()=="EURCHFm" || Symbol()=="EURCHF") {LongMagicNumber=100008;ShortMagicNumber=200008;}
   if (Symbol()=="EURGBPm" || Symbol()=="EURGBP") {LongMagicNumber=100009;ShortMagicNumber=200009;}
   if (Symbol()=="EURJPYm" || Symbol()=="EURJPY") {LongMagicNumber=100010;ShortMagicNumber=200010;}
   if (Symbol()=="EURUSDm" || Symbol()=="EURUSD") {LongMagicNumber=100011;ShortMagicNumber=200011;}
   if (Symbol()=="GBPCHFm" || Symbol()=="GBPCHF") {LongMagicNumber=100012;ShortMagicNumber=200012;}   
   if (Symbol()=="GBPJPYm" || Symbol()=="GBPJPY") {LongMagicNumber=100013;ShortMagicNumber=200013;}
   if (Symbol()=="GBPUSDm" || Symbol()=="GBPUSD") {LongMagicNumber=100014;ShortMagicNumber=200014;}
   if (Symbol()=="NZDJPYm" || Symbol()=="NZDJPY") {LongMagicNumber=100015;ShortMagicNumber=200015;}
   if (Symbol()=="NZDUSDm" || Symbol()=="NZDUSD") {LongMagicNumber=100016;ShortMagicNumber=200016;}
   if (Symbol()=="USDCHFm" || Symbol()=="USDCHF") {LongMagicNumber=100017;ShortMagicNumber=200017;}
   if (Symbol()=="USDJPYm" || Symbol()=="USDJPY") {LongMagicNumber=100018;ShortMagicNumber=200018;}
   if (Symbol()=="USDCADm" || Symbol()=="USDCAD") {LongMagicNumber=100019;ShortMagicNumber=200019;}
   if (LongMagicNumber==0) {LongMagicNumber = 100999;}   
   if (ShortMagicNumber==0) {ShortMagicNumber = 200999;}   
   return(0);
   
  }


int start()

  {
  
//====================================================== Begin Top Level Command Module ============================================================  
 
// Global equity/risk based lot sizer

G_AcctLeverage = AccountLeverage();
G_MinLotSize = MarketInfo(Symbol(),MODE_MINLOT);
G_MaxLotSize = MarketInfo(Symbol(),MODE_MAXLOT);
G_LotStep = MarketInfo(Symbol(),MODE_LOTSTEP);
G_CurrencyLotSize = MarketInfo(Symbol(),MODE_LOTSIZE);

if(G_LotStep == 0.01) {G_Decimals = 2;}
if(G_LotStep == 0.1) {G_Decimals = 1;}

if (UseMoneyMgmt == true)
 {
  G_OrderLotSize = AccountEquity() * (RiskPercent * 0.01) / (G_CurrencyLotSize / G_AcctLeverage);
  G_OrderLotSize = StrToDouble(DoubleToStr(G_OrderLotSize,G_Decimals));
 }
  else
 {
  G_OrderLotSize = LotSize;
 }

if (G_OrderLotSize < G_MinLotSize) {G_OrderLotSize = G_MinLotSize;}
if (G_OrderLotSize > G_MaxLotSize) {G_OrderLotSize = G_MaxLotSize;}
 
    
// Added Minimum Equity Level to protect to protect from being wiped out in the event things really get wicked...more elegant risk control stuff.
      
   if(EquityProtectionLevel > 0 && AccountEquity() <= EquityProtectionLevel)
     {
      AllowTrading = false;
      Print("Min. Equity Level Reached - Trading Halted & Orders Closed");
      Alert("Min. Equity Level Reached - Trading Halted & Orders Closed");
      for(G_Count=OrdersTotal();G_Count>=0;G_Count--)
       {
	     OrderSelect(G_Count, SELECT_BY_POS, MODE_TRADES);	  	  
		  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),G_Slippage,Blue); 
		 }	 
		 return(0);		   
	  }
	  
	if (TargetEquityToCloseAndReset > 0 && AccountEquity() >= (AccountBalance() * ( 1 + (TargetEquityToCloseAndReset * 0.01))))
	  {
      Print("TargetEquity Level Reached - All Orders Closed");
      Alert("TargetEquity Level Reached - All Orders Closed");
      for(G_Count=OrdersTotal();G_Count>=0;G_Count--)
       {
	     OrderSelect(G_Count, SELECT_BY_POS, MODE_TRADES);	  	  
		  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),G_Slippage,Blue); 
		 }	 
		 return(0);		   
	  }
           
   if (AllowTrading==true) {LongGoblin();ShortGoblin();}
   
   
   
   Comment("\nBUY CYCLE : Orders Open = ",L_OpenOrders," Profit = ",DoubleToStr(L_Profit,2)," +/-","\nSELL CYCLE: Orders Open = ",S_OpenOrders," Profit = ",DoubleToStr(S_Profit,2)," +/-");
  

   return(0);
  }  
   
//====================================================== End Of Top Level Command Module ============================================================<<





//====================================================== Begin Buy Order Processing SubRoutine ======================================================<<

void LongGoblin()
  {
   
   if (MathAbs(MaxLossPerOrder) > 0)
    {
     for(L_Count=OrdersTotal();L_Count>=0;L_Count--) 
      {
       RefreshRates();
       OrderSelect(L_Count,SELECT_BY_POS,MODE_TRADES);
       if (OrderSymbol() == Symbol())
        {
         if (OrderType() == OP_BUY && OrderMagicNumber() == LongMagicNumber && OrderProfit() <=  MathAbs(MaxLossPerOrder) * (-1)) { OrderClose(OrderTicket(),OrderLots(),Bid,L_Slippage,White); }
         if (OrderType() == OP_SELL && OrderMagicNumber() == LongMagicNumber && OrderProfit() <= MathAbs(MaxLossPerOrder) * (-1)) { OrderClose(OrderTicket(),OrderLots(),Ask,L_Slippage,White); }
        }
      }
    }
    
   L_Profit=0;
   L_OpenOrders=0;
   for(L_Count=0;L_Count<OrdersTotal();L_Count++)   
   {
    OrderSelect(L_Count, SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol()==Symbol() && OrderMagicNumber() == LongMagicNumber) {L_OpenOrders++;L_Profit=L_Profit+OrderProfit();}
   }     
   
   L_PipValue = MarketInfo(Symbol(),MODE_TICKVALUE);
   if (L_PipValue==0) { L_PipValue=5; }
   
   if (L_PreviousOpenOrders>L_OpenOrders) 
   {	  
	 for(L_Count=OrdersTotal();L_Count>=0;L_Count--)
	  {     
      OrderSelect(L_Count, SELECT_BY_POS, MODE_TRADES);
	   if (OrderSymbol()==Symbol() && OrderMagicNumber() == LongMagicNumber && OrderType() == OP_BUY) 
	    {
        int m_Ticket = OrderTicket();
	     OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),L_Slippage,Blue);
		  Print("Closing Buy Order ",m_Ticket);
		  return(0);
		 }
	  }
   }

   L_PreviousOpenOrders=L_OpenOrders;
   if (L_OpenOrders>=LongMaxTrades) 
    {
	  L_ContinueOpening=False;
    } else {
	  L_ContinueOpening=True;
    }

   if (L_LastPrice==0) 
    {
	  for(L_Count=0;L_Count<OrdersTotal();L_Count++)
	   {	
       OrderSelect(L_Count, SELECT_BY_POS, MODE_TRADES);
	    if (OrderSymbol()==Symbol() && OrderMagicNumber() == LongMagicNumber && OrderType() == OP_BUY) 
		  {
			L_LastPrice=OrderOpenPrice();
		   L_OrderType=2;
		  }
	   }
    }

   if (L_OpenOrders<1) {L_OrderType=OpenOrdersBasedOnTrendRSX();}
 
// Here comes the fun part we all waited for where we update those trailing stops....yippeekyeah!!

   for(L_Count=OrdersTotal();L_Count>=0;L_Count--)
    {
     OrderSelect(L_Count, SELECT_BY_POS, MODE_TRADES);
     if (OrderSymbol() == Symbol() && OrderMagicNumber() == LongMagicNumber && OrderType()== OP_BUY)  
      {	
       if (LongTrailingStop > 0 && (Bid-OrderOpenPrice()>=(LongTrailingStop+LongPips)*Point) &&  (OrderStopLoss()<(Bid-Point*LongTrailingStop)) )
        {				   
	      OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*LongTrailingStop,OrderClosePrice()+LongTakeProfit*Point+LongTrailingStop*Point,800,Yellow);
         return(0);
        } 
	   }
  	 }
   
   L_Profit=0;
   L_LastTicket=0;
   L_LastType=0;
	L_LastClosePrice=0;
	L_LastLots=0;	
	for(L_Count=0;L_Count<OrdersTotal();L_Count++)
	{
    OrderSelect(L_Count, SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol()==Symbol() && OrderMagicNumber() == LongMagicNumber && OrderType()==OP_BUY) 
	  {			
  	   L_LastTicket=OrderTicket();
		L_LastType=OP_BUY; 
		L_LastClosePrice=OrderClosePrice();
		L_LastLots=OrderLots();
		L_Profit=L_Profit+OrderProfit();	
	  }
   }
	
   if (L_OpenOrders>=(LongMaxTrades-LongOrderstoProtect) && LongAccountProtection==true) 
    {	    
     if (L_Profit>=LongSecureProfit) 
      {
       OrderClose(L_LastTicket,L_LastLots,L_LastClosePrice,L_Slippage,Yellow);		 
       L_ContinueOpening=False;
       return(0);
      }
    }
      
   if (L_OrderType==2 && L_ContinueOpening && ((L_LastPrice-Ask)>=LongPips*Point || L_OpenOrders<1) ) 
    {  		
     BuyPrice=Ask;
     L_LastPrice=0;
     if (LongTakeProfit==0) { L_tp=0; }
      else { L_tp=BuyPrice+LongTakeProfit*Point; }	
     if (LongInitialStop==0)  { L_sl=0; }
      else { L_sl=NormalizeDouble(BuyPrice-LongInitialStop*Point - (LongMaxTrades-L_OpenOrders)*LongPips*Point, Digits); }
     if (L_OpenOrders!=0) 
       {
        L_OrderLotSize=G_OrderLotSize;			
        for(L_Count=1;L_Count<=L_OpenOrders;L_Count++)
         {
          if (UseFiboLotSizeProgression)
           {
            L_OrderLotSize = MathRound(MathPow(1.6180339,L_Count+1)/MathSqrt(5))* L_OrderLotSize;  // Fibonacci progression by Tross
           }
            else
           {  			      
            if (LongMaxTrades>12)
             { 
              L_OrderLotSize=NormalizeDouble(L_OrderLotSize*1.5,2); 
             } 	           
	          else 
	          {
	           L_OrderLotSize=NormalizeDouble(L_OrderLotSize*2,2);
	          } 
           }
         }  
       } else { L_OrderLotSize=G_OrderLotSize; } 
	   OrderSend(Symbol(),OP_BUY,L_OrderLotSize,BuyPrice,L_Slippage,L_sl,L_tp,"Goblin BiPolar Buy",LongMagicNumber,0,Blue);		    
	   return(0);   
    }   

   return(0);
  }


//====================================================== Begin Sell Order Processing SubRoutine =====================================================<<

void ShortGoblin()
  {   
   if (MathAbs(MaxLossPerOrder) > 0)
    {
     for(S_Count=OrdersTotal();S_Count>=0;S_Count--) 
      {
       RefreshRates();
       OrderSelect(S_Count,SELECT_BY_POS,MODE_TRADES);
       if (OrderSymbol() == Symbol())
        {         
         if (OrderType() == OP_SELL && OrderMagicNumber() == ShortMagicNumber && OrderProfit() <= MathAbs(MaxLossPerOrder) * (-1)) { OrderClose(OrderTicket(),OrderLots(),Ask,L_Slippage,White); }
        }
      }
    }
    
   S_Profit=0;  
   S_OpenOrders=0;
   for(S_Count=0;S_Count<OrdersTotal();S_Count++)   
    {
     OrderSelect(S_Count, SELECT_BY_POS, MODE_TRADES);
	  if (OrderSymbol()==Symbol() && OrderMagicNumber() == ShortMagicNumber) {S_OpenOrders++;S_Profit=S_Profit+OrderProfit();}
    }     
      
   S_PipValue = MarketInfo(Symbol(),MODE_TICKVALUE);
   if (S_PipValue==0) { S_PipValue=5; }
   
   if (S_PreviousOpenOrders>S_OpenOrders) 
   {	  
	 for(S_Count=OrdersTotal();S_Count>=0;S_Count--)
	  {	     
      OrderSelect(S_Count, SELECT_BY_POS, MODE_TRADES);
	   if (OrderSymbol()==Symbol() && OrderMagicNumber() == ShortMagicNumber && OrderType() == OP_SELL) 
	    {
        int m_Ticket = OrderTicket();
	     OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),S_Slippage,Red); 
	     Print("Closing Sell Order ",m_Ticket);
	     return(0);
		 }
	  }
   }

   S_PreviousOpenOrders=S_OpenOrders;
   if (S_OpenOrders>=ShortMaxTrades) 
    {
	  S_ContinueOpening=False;
    } else {
	  S_ContinueOpening=True;
    }

   if (S_LastPrice==0) 
    {
	  for(S_Count=0;S_Count<OrdersTotal();S_Count++)
      {	
       OrderSelect(S_Count, SELECT_BY_POS, MODE_TRADES);	
	    if (OrderSymbol()==Symbol() && OrderMagicNumber() == ShortMagicNumber && OrderType() == OP_SELL) 
		  {
	      S_LastPrice=OrderOpenPrice();
		   S_OrderType=1;
		  }
	   }
    }

   
   if (S_OpenOrders<1){S_OrderType=OpenOrdersBasedOnTrendRSX();}
      

// Here comes the fun part we all waited for where we update those trailing stops....woohoo!!

   for(S_Count=OrdersTotal();S_Count>=0;S_Count--)
   {
    OrderSelect(S_Count, SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == ShortMagicNumber && OrderType()==OP_SELL) 
	  {	
      if (ShortTrailingStop > 0 && (OrderOpenPrice()-Ask>=(ShortTrailingStop+ShortPips)*Point) && (OrderStopLoss()>(Ask+Point*ShortTrailingStop)) ) 
	    {					
	     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*ShortTrailingStop,OrderClosePrice()-ShortTakeProfit*Point-ShortTrailingStop*Point,800,Purple);
	     return(0);	  					
		 }
     }
   }
   
   S_Profit=0;
   S_LastTicket=0;
   S_LastType=0;
	S_LastClosePrice=0;
	S_LastLots=0;	
   for(S_Count=0;S_Count<OrdersTotal();S_Count++)
    {
	  OrderSelect(S_Count, SELECT_BY_POS, MODE_TRADES);
	  if (OrderSymbol()==Symbol() && OrderMagicNumber() == ShortMagicNumber && OrderType()==OP_SELL) 
  	   {			
       S_LastTicket=OrderTicket();
	    S_LastType=OP_SELL;
 	    S_LastClosePrice=OrderClosePrice();
	    S_LastLots=OrderLots();
       S_Profit=S_Profit+OrderProfit();			 	   
      }
    }
    
   if (S_OpenOrders>=(ShortMaxTrades-ShortOrderstoProtect) && ShortAccountProtection==true) 
    {	    
     if (S_Profit>=ShortSecureProfit) 
      {
       OrderClose(S_LastTicket,S_LastLots,S_LastClosePrice,S_Slippage,Yellow);		 
       S_ContinueOpening=False;
       return(0);
      }
    }
       
    if (S_OrderType==1 && S_ContinueOpening && ((Bid-S_LastPrice)>=ShortPips*Point || S_OpenOrders<1)) 
     {		
      SellPrice=Bid;				
      S_LastPrice=0;
      if (ShortTakeProfit==0) { S_tp=0; }
       else { S_tp=SellPrice-ShortTakeProfit*Point; }	
      if (ShortInitialStop==0) { S_sl=0; }
       else { S_sl=NormalizeDouble(SellPrice+ShortInitialStop*Point + (ShortMaxTrades-S_OpenOrders)* ShortPips*Point, Digits);  }
      if (S_OpenOrders!=0) 
       {
        S_OrderLotSize=G_OrderLotSize;			
        for(S_Count=1;S_Count<=S_OpenOrders;S_Count++)
         {
          if (UseFiboLotSizeProgression)
           {
            S_OrderLotSize = MathRound(MathPow(1.6180339,S_Count+1)/MathSqrt(5))* S_OrderLotSize;  // Fibonacci progression by Tross
           }
            else
           {  			      
            if (ShortMaxTrades>12)
             { 
              S_OrderLotSize=NormalizeDouble(S_OrderLotSize*1.5,2); 
             } 	           
	          else 
	          {
	           S_OrderLotSize=NormalizeDouble(S_OrderLotSize*2,2);
	          } 
           }
         }  
       } else { S_OrderLotSize=G_OrderLotSize; }   
	    OrderSend(Symbol(),OP_SELL,S_OrderLotSize,SellPrice,S_Slippage,S_sl,S_tp,"Goblin Bipolar Sell",ShortMagicNumber,0,Red);		    		    
	    return(0);    
     }
       
    return(0);
  }  
  
int deinit()
  {
   return(0);
  }  
  

//==================================================== And here's the lovely Buy/Sell Signal Generator  ============================================<<

int OpenOrdersBasedOnTrendRSX()

{
     int SignalOrderType=3;
     double rsxcurr=0,rsxprev1=0,rsxprev2=0,jma1=0,jma2=0,slowsma=0,mediumsma=0,fastsma=0;
        
     fastsma = iCustom(Symbol(),TrendFilterSMATimeFrame,"Turbo_JMA",TrendFilterFastSMAPeriod,-100,0,1);
     mediumsma = iCustom(Symbol(),TrendFilterSMATimeFrame,"Turbo_JMA",TrendFilterMediumSMAPeriod,-100,0,1);
     slowsma = iCustom(Symbol(),TrendFilterSMATimeFrame,"Turbo_JMA",TrendFilterSlowSMAPeriod,-100,0,1);
                
     rsxcurr = iCustom(Symbol(),RSX_Timeframe,"Turbo_JRSX",RSX_Period,0,1);
     rsxprev1 = iCustom(Symbol(),RSX_Timeframe,"Turbo_JRSX",RSX_Period,0,2);
     rsxprev2 = iCustom(Symbol(),RSX_Timeframe,"Turbo_JRSX",RSX_Period,0,3);
 
     jma1=iCustom(Symbol(),PERIOD_M15,"Turbo_JMA",28,-100,0,2);
     jma2=iCustom(Symbol(),PERIOD_M15,"Turbo_JMA",28,-100,0,3);
     
     UpTrendVal = iCustom(Symbol(),Period(), "Turbo_JVEL",17,-100,0,1);
     DnTrendVal = iCustom(Symbol(),Period(), "Turbo_JVEL",17,-100,1,1);
     TrendVal = (UpTrendVal + DnTrendVal);
     

// Let's check our very reliable super secret mega-signal...
 
     if (MathAbs(jma1 - jma2) / Point > 2.0)
      {
       if (jma1 < jma2) {SignalOrderType=1;}
       if (jma1 > jma2) {SignalOrderType=2;}
      }
  
// Welp, our mega-signal says no cigar...let's see what trusty 'ol RSX has to say...  
 
     if (SignalOrderType==3)
      {
       if (UseConservativeRSX_Signals==true)
        {            
         if (rsxcurr < rsxprev1 &&  rsxcurr < 70 && rsxprev1 > 70 && TrendVal < (-0.01)) {SignalOrderType=1;}    // we only go short on RSX downturns
         if (rsxcurr > rsxprev1 &&  rsxcurr > 30 && rsxprev1 < 30 && TrendVal > (0.01)) {SignalOrderType=2;}       // we only go long on RSX upturns
        }
       if (UseConservativeRSX_Signals==false)
        {            
         if (rsxcurr < rsxprev1 && TrendVal < (-0.01)) {SignalOrderType=1;}    // we only go short on RSX downturns
         if (rsxcurr > rsxprev1 && TrendVal > (0.01)) {SignalOrderType=2;}       // we only go long on RSX upturns
        }
      } 
      
     if (SignalOrderType == 1 &&  UseSMATrendFilter == true)
       {
        if (slowsma > mediumsma && mediumsma > fastsma)
          {
           SignalOrderType = 1;
          } else {
           SignalOrderType = 3;
          } 
        }
      if (SignalOrderType == 2 &&  UseSMATrendFilter == true)
       {
        if (slowsma < mediumsma && mediumsma < fastsma)
          {
           SignalOrderType = 2;
          } else {
           SignalOrderType = 3;
          } 
        }  
        
     return(SignalOrderType);
}


