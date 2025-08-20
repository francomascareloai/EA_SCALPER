// Goblin BiPolar Edition v.1.0
// by bluto @ www.forex-tsd.com
// 12/20/2006
//
// Here's a roughly cobbled version of Goblin that supports two EA routines in one - a buy side and a sell side running concurrently.
// Although effective, the code isn't the most modular at this point.  If the concept proves to be viable, I'll continue further
// development to optimize shared subroutines between the two sub-EA routines.  For now...play, test & be bodaceous! 

extern string    SystemWideParms = "** Goblin Systemwide Parameters **";

extern double    LotSize = 0.1;                          // First order will be for this lot size
extern double    LotsIncreaseBy = 2.0;            //New orders will be the previous size times this amount
extern bool      UseMoneyMgmt=false;                      // if true, the lots size will increase based on account size 
extern double    EquityProtectionLevel=0.0;              // Min. equity to preserve in the event things go bad; all orders for Symbol/Magic will be closed.
extern double    MaxLossPerOrder=0.0;                    // Max. loss tolerance per order; once reached, order will be closed.
extern int       RiskPercent=0.75;                        // risk to calculate the lots size (only if mm is enabled)
extern bool      UseFiboLotSizeProgression=false;
extern bool      VolatilityBasedPipSpacing= false;
extern bool      VolatilityBasedProfitTarget=false;
extern double    ProfitTargetFactor       = 0.80;
extern double    ATRIncreaseDecreaseFactor= 1;
extern int       ATR_Period               = 20;
extern int       ATR_Timeframe            = 240;
int              last_bar= 1;

extern string    LongTradeParms = "** Goblin Buy Side Parameters **";
extern double    LongTakeProfit = 10;           // Profit Goal for the latest order opened
extern double    LongInitialStop = 0;           // StopLoss
extern double    LongTrailingStop = 0;         // Pips to trail the StopLoss
extern int       LongMaxTrades=4;               // Maximum number of orders to open
extern int       LongPips=5;                    // Distance in Pips from one order to another
extern double    LongSecureProfit=0;           // If profit made is bigger than SecureProfit we close the orders
extern bool      LongAccountProtection=false;   // If one the account protection will be enabled, 0 is disabled
extern int       LongOrderstoProtect=2;         // This number subtracted from LongMaxTrades is the number of open orders to enable the account protection.
                                                // Example: (LongMaxTrades=10) minus (OrderstoProtect=3)=7 orders need to be open before account protection is enabled.
                                                
extern string    ShortTradeParms = "** Goblin Sell Side Parameters **";

extern double    ShortTakeProfit = 10;          // Profit Goal for the latest order opened
extern double    ShortInitialStop = 0;          // StopLoss
extern double    ShortTrailingStop = 0;        // Pips to trail the StopLoss
extern int       ShortMaxTrades=4;              // Maximum number of orders to open
extern int       ShortPips=5;                   // Distance in Pips from one order to another
extern double    ShortSecureProfit=0;          // If profit made is bigger than SecureProfit we close the orders
extern bool      ShortAccountProtection=false;  // If one the account protection will be enabled, 0 is disabled
extern int       ShortOrderstoProtect=2;        // This number subtracted from LongMaxTrades is the number of open orders to enable the account protection.
                                                // Example: (LongMaxTrades=10) minus (OrderstoProtect=3)=7 orders need to be open before account protection is enabled. 
extern bool    CloseOnEquityTarget = false;
extern bool    AutoRestartAfterEqTarget = false;
extern double  EquityTargetPercentage = 5.0;
extern bool    CloseOnFloatPL = true;
extern double  MaxFloatPL = 100.00;    //Max floating profit/loss allowed when closing EA
extern double  MinFloatPL = -100.00;




                                                 
                                                 
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
double           HL_sl=0;
double           HL_tp=0;
double StartBalance, EquityTarget;
bool LastCloseOnEquityTarget = false;

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
double           HS_sl=0;
double           HS_tp=0;

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
int              G_TargetEquity=0;



int S_OrderTypeTmp=0,L_OrderTypeTmp=0;
bool ExitWithOpenOrdersBasedON=true;
int OpenOrdersBasedOn=1;
bool Halt = false;

double S_Lots=0,L_Lots=0;
double ShortHTakeProfit=0,LongHTakeProfit=0;
int HL_OpenOrders=0,HS_OpenOrders=0;
bool HL_ContinueOpening=true,HS_ContinueOpening=true;
extern double    HedgeFactor = 2;
extern double HLsl=1000,HSsl=1000;
extern double HLtp=1000,HStp=1000;
extern int LongHedgeSpacing=1000;
extern int ShortHedgeSpacing=1000;


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
  
  double value = iATR(NULL,ATR_Timeframe,ATR_Period,0);
   if(Point == 0.01)   value = ATRIncreaseDecreaseFactor*(value*100);
   if(Point == 0.0001) value = ATRIncreaseDecreaseFactor*(value*10000);
  
    
  if (VolatilityBasedProfitTarget)
  {  
  LongTakeProfit  = NormalizeDouble((value*ProfitTargetFactor),0);
  ShortTakeProfit = NormalizeDouble((value*ProfitTargetFactor),0);
  }
  
  // End Set the ProfitTarget
  
 { // Set the AutoPipSpacing
  if (VolatilityBasedPipSpacing)
  {  
  LongPips  = NormalizeDouble(value,0);
  ShortPips = NormalizeDouble(value,0);
  }
 } 
  
        
        
        
     

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
           
	
           
   if (AllowTrading==true) {LongGoblin();ShortGoblin();ManageClose();}
   
   Comment("\nBUY CYCLE : Orders Open = ",L_OpenOrders," Profit = ",DoubleToStr(L_Profit,2)," +/-","\nSELL CYCLE: Orders Open = ",S_OpenOrders," Profit = ",DoubleToStr(S_Profit,2)," +/-");
  

   return(0);
  }  
   
//====================================================== End Of Top Level Command Module ============================================================<<





//====================================================== Begin Buy Order Processing SubRoutine ======================================================<<

void CloseAllTrades()
{
   int  total = OrdersTotal();
   for (int y=OrdersTotal()-1; y>=0; y--)  
   {
      OrderSelect(y, SELECT_BY_POS, MODE_TRADES);
       
      {
         int type = OrderType();
         bool result = false;
         int  TriesNum = 5;
         int tries=0;
         while (!result && tries < TriesNum) 
         {
            RefreshRates();
            switch(type)
            {
               case OP_BUY : 
                  result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),L_Slippage,Pink);
                  break;
               case OP_SELL: 
                  result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),S_Slippage,Pink);             
            }            
            tries++;
         }
         if (!result) Print("Error closing order : ");  
      }
   }
}


void ManageClose()
{
   
   
   if (CloseOnEquityTarget && !LastCloseOnEquityTarget) { 
      StartBalance = AccountBalance();
   }
   LastCloseOnEquityTarget = CloseOnEquityTarget;
      
   
   if (CloseOnFloatPL && (AccountProfit()>=MaxFloatPL || AccountProfit()<=MinFloatPL) )
   {
      CloseAllTrades();
      Halt = true;
   }
   if (CloseOnEquityTarget && !Halt)
   {
      EquityTarget = StartBalance*(1.0 + EquityTargetPercentage/100.0);
      if (AccountEquity()>=EquityTarget )
      {
         CloseAllTrades();
         StartBalance = AccountBalance();
         if (!AutoRestartAfterEqTarget) Halt = true;
      }
   }
   if (!CloseOnFloatPL && !CloseOnEquityTarget)
   {
      if (Halt) StartBalance = AccountBalance();
      Halt = false;
   }
     
}








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
   L_Lots=0; 
   L_Profit=0;
   L_OpenOrders=0;
   for(L_Count=0;L_Count<OrdersTotal();L_Count++)   
   {
    OrderSelect(L_Count, SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol()==Symbol() && OrderMagicNumber() == LongMagicNumber /*&& OrderType() == OP_BUY*/)
     {L_OpenOrders++;L_Profit=L_Profit+OrderProfit();L_Lots=L_Lots+OrderLots();}
   }     
   
   HL_OpenOrders=0;
   for(L_Count=0;L_Count<OrdersTotal();L_Count++)   
   {
    OrderSelect(L_Count, SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol()==Symbol() && OrderMagicNumber() == LongMagicNumber && OrderType() == OP_SELL)
     {HL_OpenOrders++;/*L_Profit=L_Profit+OrderProfit();L_Lots=L_Lots+OrderLots();*/}
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
	 
	 if (HL_OpenOrders>0) 
    {
	  HL_ContinueOpening=false;
    } else {
	  HL_ContinueOpening=True;
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



   
   if (ExitWithOpenOrdersBasedON && L_OrderTypeTmp==4)
           {
             L_PreviousOpenOrders=L_OpenOrders+1;
             L_ContinueOpening=False;
             //S_PreviousOpenOrders=S_OpenOrders+1;
             //S_ContinueOpening=False;
             text = text +"\nClosing all orders because Indicator triggered another signal.";
             Print("Closing all orders because Indicator triggered another signal."); 
             return(0);
           }
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
    if (OrderSymbol()==Symbol() && OrderMagicNumber() == LongMagicNumber /*&& OrderType()==OP_BUY*/) 
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
         if (UseFiboLotSizeProgression==true) {L_OrderLotSize = MathRound(MathPow(1.6180339,L_Count+1)/MathSqrt(5))* G_OrderLotSize;}
         if (UseFiboLotSizeProgression==false && LongMaxTrades>12) {L_OrderLotSize=NormalizeDouble(L_OrderLotSize*LotsIncreaseBy,2);}
         if (UseFiboLotSizeProgression==false && LongMaxTrades<12) {L_OrderLotSize=NormalizeDouble(L_OrderLotSize*LotsIncreaseBy,2);}		      
        }  
      } else { L_OrderLotSize=G_OrderLotSize; } 
	   OrderSend(Symbol(),OP_BUY,L_OrderLotSize,BuyPrice,L_Slippage,L_sl,L_tp,"Goblin BiPolar Buy",LongMagicNumber,0,Blue);		    
	   return(0);   
    }   
//-------------------------------
if (L_OrderType==2 && HL_ContinueOpening && L_Profit<0 && L_OpenOrders==LongMaxTrades && ((L_LastPrice-Ask)>=LongHedgeSpacing*Point) /*|| (HL_OpenOrders<1 && L_OpenOrders>=1))
     || L_Profit<0 && L_OpenOrders==1 && HL_OpenOrders<1 && ((L_LastPrice-Bid)>=(LongPips-5)*Point)*/
     )      
     {		
      SellPrice=Bid;	
    /*  HL_LastPrice=0;*/Print("l open orders : ",L_Lots);
      if (LongHTakeProfit==0) { S_tp=0; }
       else { S_tp=SellPrice-LongHTakeProfit*Point; }	
      if (ShortInitialStop==0) { S_sl=0; }
       else { S_sl=NormalizeDouble(SellPrice+ShortInitialStop*Point + (ShortMaxTrades-L_OpenOrders)* ShortPips*Point, Digits);  }
      if (HSsl==0) { HS_sl=0;}
       else { HS_sl=NormalizeDouble(SellPrice+HSsl*Point, Digits);}
      if (HStp==0) { HS_tp=0;}
       else { HS_tp=NormalizeDouble(SellPrice-HStp*Point, Digits);} 
       
      /*if (L_OpenOrders!=0) 
       {
        L_OrderLotSize=G_OrderLotSize;			
        for(L_Count=1;L_Count<=L_OpenOrders;L_Count++)
         {
          if (UseFiboLotSizeProgression==true) {S_OrderLotSize = MathRound(MathPow(1.6180339,S_Count+1)/MathSqrt(5))* G_OrderLotSize;}
          if (UseFiboLotSizeProgression==false && ShortMaxTrades>12) {S_OrderLotSize=NormalizeDouble(S_OrderLotSize*LotsIncreaseBy,2);}
          if (UseFiboLotSizeProgression==false && LongMaxTrades<12) {L_OrderLotSize=NormalizeDouble(L_OrderLotSize*LotsIncreaseBy,2);}		      
            
         }  
       } else { L_OrderLotSize=G_OrderLotSize; } */
       if((L_Lots)>0){L_OrderLotSize=NormalizeDouble((L_Lots)*HedgeFactor,2);}else { L_OrderLotSize=NormalizeDouble(L_OrderLotSize*HedgeFactor,2);} 
	        OrderSend(Symbol(),OP_SELL,L_OrderLotSize,SellPrice,S_Slippage,HS_sl,HS_tp,"Goblin Bipolar CoverBuy",LongMagicNumber,0,Red);		    		    
	       
   
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
   S_Lots=0;  
   S_Profit=0;  
   S_OpenOrders=0;
   for(S_Count=0;S_Count<OrdersTotal();S_Count++)   
    {
     OrderSelect(S_Count, SELECT_BY_POS, MODE_TRADES);
	  if (OrderSymbol()==Symbol() && OrderMagicNumber() == ShortMagicNumber /*&& OrderType() == OP_SELL*/)
	   {S_OpenOrders++;S_Profit=S_Profit+OrderProfit();S_Lots=S_Lots+OrderLots();}
    }     
   
   HS_OpenOrders=0;
   for(S_Count=0;S_Count<OrdersTotal();S_Count++)   
   {
    OrderSelect(S_Count, SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol()==Symbol() && OrderMagicNumber() == ShortMagicNumber && OrderType() == OP_BUY)
     {HS_OpenOrders++;/*L_Profit=L_Profit+OrderProfit();L_Lots=L_Lots+OrderLots();*/}
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
   if (S_OpenOrders>=ShortMaxTrades || HS_OpenOrders>0) 
    {
	  S_ContinueOpening=False;
	  HS_ContinueOpening=false;
    } else {
	  S_ContinueOpening=True;
	  HS_ContinueOpening=True;
    }

   if (HS_OpenOrders>0) 
    {
	  HS_ContinueOpening=false;
    } else {
	  HS_ContinueOpening=True;
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

   
   
   if (ExitWithOpenOrdersBasedON && S_OrderTypeTmp==4)
           {
             S_PreviousOpenOrders=S_OpenOrders+1;
             S_ContinueOpening=False;
             //S_PreviousOpenOrders=S_OpenOrders+1;
             //S_ContinueOpening=False;
             text = text +"\nClosing all orders because Indicator triggered another signal.";
             Print("Closing all orders because Indicator triggered another signal."); 
             return(0);
           }      

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
	  if (OrderSymbol()==Symbol() && OrderMagicNumber() == ShortMagicNumber /*&& OrderType()==OP_SELL*/) 
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
          if (UseFiboLotSizeProgression==true) {S_OrderLotSize = MathRound(MathPow(1.6180339,S_Count+1)/MathSqrt(5))* G_OrderLotSize;}
          if (UseFiboLotSizeProgression==false && ShortMaxTrades>12) {S_OrderLotSize=NormalizeDouble(S_OrderLotSize*LotsIncreaseBy,2);}
          if (UseFiboLotSizeProgression==false && ShortMaxTrades<12) {S_OrderLotSize=NormalizeDouble(S_OrderLotSize*LotsIncreaseBy,2);}		      
         }  
       } else { S_OrderLotSize=G_OrderLotSize; } 
	    OrderSend(Symbol(),OP_SELL,S_OrderLotSize,SellPrice,S_Slippage,S_sl,S_tp,"Goblin Bipolar Sell",ShortMagicNumber,0,Red);		    		    
	    return(0);    
     }
       
//----------------
     if (S_OrderType==1 && HS_ContinueOpening && S_Profit<0 && S_OpenOrders==ShortMaxTrades && ((Ask-S_LastPrice)>=ShortHedgeSpacing*Point) /*|| (HS_OpenOrders<1 && S_OpenOrders>=1))
     || S_Profit<0 && S_OpenOrders==1 && HS_OpenOrders<1 && ((Bid-S_LastPrice)>=(ShortPips-5)*Point)*/
     )      
     {		
      BuyPrice=Ask;	
   //   HS_LastPrice=0;Print("sono qui");
      if (ShortHTakeProfit==0) { L_tp=0; }
       else { L_tp=BuyPrice-ShortHTakeProfit*Point; }	
       
      if (LongInitialStop==0) { L_sl=0; }
       else { L_sl=NormalizeDouble(BuyPrice-LongInitialStop*Point - (ShortMaxTrades-L_OpenOrders)* LongPips*Point, Digits);  }
      if (HLsl==0) { HL_sl=0;}
       else { HL_sl=NormalizeDouble(BuyPrice-HLsl*Point, Digits);}
      if (HLtp==0) { HL_tp=0;}
       else { HL_tp=NormalizeDouble(BuyPrice+HLtp*Point, Digits);} 
       
     /* if (S_OpenOrders!=0) 
       {
        S_OrderLotSize=G_OrderLotSize;			
        for(S_Count=1;S_Count<=S_OpenOrders;S_Count++)
         {
          if (UseFiboLotSizeProgression==true) {S_OrderLotSize = MathRound(MathPow(1.6180339,S_Count+1)/MathSqrt(5))* G_OrderLotSize;}
          if (UseFiboLotSizeProgression==false && ShortMaxTrades>12) {S_OrderLotSize=NormalizeDouble(S_OrderLotSize*LotsIncreaseBy,2);}
          if (UseFiboLotSizeProgression==false && ShortMaxTrades<12) {S_OrderLotSize=NormalizeDouble(S_OrderLotSize*LotsIncreaseBy,2);}		      
            
         }  
       } else { S_OrderLotSize=G_OrderLotSize; } */
       if((S_Lots)>0){S_OrderLotSize=NormalizeDouble((S_Lots)*HedgeFactor,2);}else { S_OrderLotSize=NormalizeDouble(S_OrderLotSize*HedgeFactor,2);} 
	        OrderSend(Symbol(),OP_BUY,S_OrderLotSize,BuyPrice,L_Slippage,HL_sl,HL_tp,"Goblin Bipolar CoverSell",ShortMagicNumber,0,Red);		    		    
	       
   
	    return(0);    
     }

//---------------       
       
       
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

 double hma4_1, hma4_2;
   double hma6_1, hma6_2;
   double hma8_1, hma8_2;
   double hma10_1, hma10_2;
   double hma20_1, hma20_2;
   double hma40_1, hma40_2;
   double hma80_1, hma80_2;
   double hma200_1, hma200_2;
   double hma420_1, hma420_2;
   
   if (last_bar < 0) {
      last_bar = 1;
   }

   hma4_1 = iCustom(Symbol(), 0, "HMA_v07.1", 4, 200, 1, last_bar);
      hma4_2 = iCustom(Symbol(), 0, "HMA_v07.1", 4, 200, 1, last_bar + 1);
      hma6_1 = iCustom(Symbol(), 0, "HMA_v07.1", 6, 200, 1, last_bar);
      hma6_2 = iCustom(Symbol(), 0, "HMA_v07.1", 6, 200, 1, last_bar + 1);
      hma8_1 = iCustom(Symbol(), 0, "HMA_v07.1", 8, 200, 1, last_bar);
      hma8_2 = iCustom(Symbol(), 0, "HMA_v07.1", 8, 200, 1, last_bar + 1);
      hma10_1 = iCustom(Symbol(), 0, "HMA_v07.1", 10, 500, 1, last_bar);
      hma10_2 = iCustom(Symbol(), 0, "HMA_v07.1", 10, 500, 1, last_bar + 1);
      hma20_1 = iCustom(Symbol(), 0, "HMA_v07.1", 20, 500, 1, last_bar);
      hma20_2 = iCustom(Symbol(), 0, "HMA_v07.1", 20, 500, 1, last_bar + 1);
      hma40_1 = iCustom(Symbol(), 0, "HMA_v07.1", 40, 800, 1, last_bar);
      hma40_2 = iCustom(Symbol(), 0, "HMA_v07.1", 40, 800, 1, last_bar + 1);
      hma80_1 = iCustom(Symbol(), 0, "HMA_v07.1", 80, 800, 1, last_bar);
      hma80_2 = iCustom(Symbol(), 0, "HMA_v07.1", 80, 800, 1, last_bar + 1);
      hma200_1 = iCustom(Symbol(), 0, "HMA_v07.1", 200, 1000, 1, last_bar);
      hma200_2 = iCustom(Symbol(), 0, "HMA_v07.1", 200, 1000, 1, last_bar + 1);
      hma420_1 = iCustom(Symbol(), 0, "HMA_v07.1", 420, 2000, 1, last_bar);
      hma420_2 = iCustom(Symbol(), 0, "HMA_v07.1", 420, 2000, 1, last_bar + 1);

         if (
         hma4_1 > hma4_2 &&
         hma6_1 > hma6_2 &&
         hma8_1 > hma8_2 &&
         hma10_1 > hma10_2 &&
         hma20_1 > hma20_2 &&
         hma40_1 > hma40_2 &&
         hma80_1 > hma80_2 &&
         hma200_1 > hma200_2 &&
         hma420_1 > hma420_2
         )
 {
  SignalOrderType=1;
 }
  
//buy order
  if (
         hma4_1 < hma4_2 &&
         hma6_1 < hma6_2 &&
         hma8_1 < hma8_2 &&
         hma10_1 < hma10_2 &&
         hma20_1 < hma20_2 &&
         hma40_1 < hma40_2 &&
         hma80_1 < hma80_2 &&
         hma200_1 < hma200_2 &&
         hma420_1 < hma420_2
         )
 {
  SignalOrderType=2;
 }

 return(SignalOrderType);
}

