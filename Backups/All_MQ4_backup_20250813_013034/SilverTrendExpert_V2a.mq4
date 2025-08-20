//+------------------------------------------------------------------+
//|                                  SilverTrendExpert_v2.mq4        |
//|                                              Copyright © 2005    |
//|    Thanks to Starter, Maloma, Amir, Fukinagashi, Forex_trader,   |
//|    kmrunner, and all other strategybuilderFx members that        |
//|    contributed to the success of this expert.                    |
//|    From MrPip                                                    |
//|    My contibution is clean up of code and using LSMA             |
//|    10/13/05 Added code for EMAAngle check                        |
//|             Removed Stop code - use TakeProfit instead           |
//|             Rearranged some code for possible include file       |
//|    10/15/05 Corrected EMAAngleZero for handling USDJPY           |
//|             addded code for multiple tries for open trade        |
//|    10/18/05 Added Slippage as parameter to expert                |
//|     10/19/05 Modified code to determine number of trades         |
//|              Possible bug from TradesInThisSymbol                |
//|              Only allows 1 trade per symbol                      |
//|              Changed variable names                              |
//|              est_b and est_s to OK2Buy and OK2Sell               |
//|              Remove CheckBuySellPosition now done with           |
//|                 CheckOpenPositions                               |
//|              Removed MaximumLosses logic                         |
//|              Modified Close logic to wait for red or green       |
//|                Was using yellow as exit also                     |
//|   10/19/05   Removed references to Globals and passed as params  |
//|   10/20/05   New expert using SilverTrend_Signal                 |
//|   10/20/05   Fixed bug and clean code in LotsOptimized           |
//|   10/24/05   Final bug fix of LotsOptimized                      |
//|   11/4/05    Modofied to use Juice filter                        |
//|              Modified to match starter_LSMA_v14 framework        |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Strategybuilderfx members"
#property link      "http:/strategybuilderfx.com/"
#include <stdlib.mqh>

extern int Debug = 0;               // Change to 1 to allow print

//+---------------------------------------------------+
//|Account functions                                  |
//+---------------------------------------------------+
extern int AccountIsMini = 0;       // Change to 1 if trading mini account
extern int LiveTrading = 0;         // Change to 1 if trading live.
//+---------------------------------------------------+
//|Money Management                                   |
//+---------------------------------------------------+
extern int mm = 1;                  // Change to 0 if you want to shutdown money management controls. Lots = 1 will be in effect and only 1 lot will be open regardless of equity.
extern double Riskpercent = 5;      // Change to whatever percent of equity you wish to risk.
extern double DecreaseFactor = 3;   // Used to decrease lot size after a loss is experienced to protect equity.  Recommended not to change.
extern double StopLoss = 45;        // Maximum pips willing to lose per position.
extern double TrailingStop = 0;     // Change to whatever number of pips you wish to trail your position with.
extern double Margincutoff = 800;   // Expert will stop trading if equity level decreases to that level.
extern double Maxtrades = 10;       // Total number of positions on all currency pairs. You can change this number as you wish.
//+---------------------------------------------------+
//|Profit controls                                    |
//+---------------------------------------------------+
extern int TakeProfit = 0;          // Maximum profit level achieved.
extern int Slippage = 10;           // Possible fix for not getting filled or closed    
//+---------------------------------------------------+
//|Indicator Variables                                |
//| Change these to try your own system               |
//| or add more if you like                           |
//+---------------------------------------------------+
extern int SSP=9;
extern int RISK=3;                  // Is this the same as RiskPercent??

// Input Parameters for Juice
extern bool UseJuice=true;
//---- indicator parameters
extern int JuicePeriod= 7;
extern int JuiceLevel= 4;

extern double Lots = 1;             // standard lot size. 
extern int Turnon = 1;              // Turns expert on, change to 0 and no trades will take place even if expert is enabled.
//+---------------------------------------------------+
//|General controls                                   |
//+---------------------------------------------------+
string OrderText = "";
double lotMM;
int TradesInThisSymbol;
datetime LastTime;
double Sl;
double Tr;
int ticket;
bool OK2Buy, OK2Sell;              // determines if buy or sell trades are allowed
bool FlatMarket;
int NumBuys, NumSells;             // Number of buy and sell trades in this symbol
bool first_time = true;


//+---------------------------------------------------+
//|  Indicator values for entry or exit conditions    |
//|  Add or Change to test your system                |
//+---------------------------------------------------+
int SilverTrendVal;

//+---------------------------------------------------+
//|  Indicator values for filters                     |
//|  Add or Change to test your system                |
//+---------------------------------------------------+

double CurrentJuice;   // From Juice

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   int handle, err;
   
    string filename=Symbol()+TimeToStr(CurTime(),TIME_DATE) + ".txt";
    
    JuiceLevel = DetermineJuiceLevel();
    
//---- 
    if (Debug == 1)
    {
      GlobalVariableSet("MyHandle",0);
      handle = FileOpen(filename,FILE_CSV|FILE_WRITE,"\t");
//    if (Debug == 1) Print ("Handle: ",handle);
      if (!GlobalVariableCheck("MyHandle"))
      {
         err = GetLastError();
         Print("Error creating Global Variable MyHandle: (" + err + ") " + ErrorDescription(err)); 
      }
      GlobalVariableSet("MyHandle",handle); 
    }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
     int handle;
 
    if (Debug == 1)
    {
      handle = GlobalVariableGet("MyHandle");
      FileFlush(handle);
      FileClose(handle);
      GlobalVariableDel("MyHandle");  
    }
   return(0);
  }

//+------------------------------------------------------------------+
//| Write - writes string to debug file                              |
//+------------------------------------------------------------------+
int Write(string str)
{
   int handle;
   
   handle = GlobalVariableGet("MyHandle");
//   if (Debug == 1) Print ("Handle in Write: ",handle);
   FileWrite(handle,str,"\r\n"); 
}

//+------------------------------------------------------------------+
//| The functions from this point to the start function are where    |
//| changes are made to test other systems or strategies.            |
//|+-----------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom Indicators                                                |
//+------------------------------------------------------------------+
  
//+------------------------------------------------------------------------+
//| SilverTrend from fukinagashi                                           |
//| returns 1 for uptrend, -1 for new downtrend                            |
//| First time called when expert is attached to chart could place a trade |
//| in current trend direction.                                            |
//+------------------------------------------------------------------------+

int SilverTrend(int SSPval, double Risk, int shift)
{
   int i,K;
   double Range,AvgRange,smin,smax,SsMax,SsMin,price;

   int trend;

   K=33-Risk; 
  	Range=0;
   AvgRange=0;
   for (i=0; i<=SSPval; i++)
	{
	  AvgRange=AvgRange+MathAbs(High[i+shift]-Low[i+shift]);
   }
   Range=AvgRange/(SSPval+1);

   SsMax=High[shift]; SsMin=Low[shift]; 
   for (i=0;i<=SSPval-1;i++)
   {
      price=High[i+shift];
      if(SsMax<price) SsMax=price;
      price=Low[i+shift];
      if(SsMin>=price)  SsMin=price;
   }
 
   smin = SsMin+(SsMax-SsMin)*K/100; 
   smax = SsMax-(SsMax-SsMin)*K/100; 
   if (Close[shift]<smin)
   {
     trend = -1;
   }
   if (Close[shift]>smax)
   {
     trend = 1;
   }
   return(trend);
}
 

//+------------------------------------------------------------------+
//| DetermineJuiceLevel                                              |
//| Optimize JuiceLevel for each currency for 15 minute chart        |
//+------------------------------------------------------------------+
int DetermineJuiceLevel()
{
  if (Symbol() == "GBPUSD") return (8);
  return (JuiceLevel);
}

//+------------------------------------------------------------------+
//| Juice (std deviation limit) indicator                            |
//| by Shimodax, based on  "Juice.mq4 by Perky"                      |
//| original link "http://fxovereasy.atspace.com/index"              |
//| Modified by MrPip to only calculate current value                |
//+------------------------------------------------------------------+
double Juice(int shift, int period, int level)
{
   double osma= 0;

   osma= iStdDev(NULL,0, period, MODE_EMA, 0, PRICE_CLOSE,shift) - level*Point;
      
//   if (Debug==1)
//   {
//      Print("FXOE-Juice is ", osma);
//      Write(" FXOE-Juice is " + DoubleToStr(osma,6));
//   }

   return (osma); // return last computed value
}

//+--------------------------------------------------------+
//|  GetSTExit                                             |
//|  Exit condition based on Silver Trend                  |
//|  Return false if Exit Condition not met                |
//|  Return true if exit condition met                     |
//+--------------------------------------------------------+
bool GetSTExit(string type,int exitall, int SilverTr)
{
  bool ExitCondition;
//  int SilverTr;
  
   ExitCondition = false;
  
//   First check if indicators cause exit

//   SilverTr=SilverTrend(SSP, RISK, 1);

   if (type == "BUY")
   {
   // Check for new downtrend
     if (SilverTr == -1)
     {
      if (Debug == 1)
      {
         Print ("Exit Condition met for Buy");
         Write ("Exit Condition met for Buy");
      }
      ExitCondition = true;
     }
   }
   if (type == "SELL")
   {
   // Check for new Uptrend
     if (SilverTr == 1)
     {
      if (Debug == 1)
      {
         Print ("Exit Condition met for Sell");
         Write ("Exit Condition met for Sell");
      }
      ExitCondition = true;
     }
   }
    
// Then check if Friday

   if(exitall==1) ExitCondition = true;
   return(ExitCondition);
}

//+------------------------------------------+
//| CheckBuyCondition                        |
//|                                          |
//| Check if new trend is up                 |
//| return false for buy condition not met   |
//| return true for buy condition met        |
//+------------------------------------------+

bool CheckBuyCondition(int STrend)
{
   if (STrend > 0)
   {
    if (Debug == 1) Print ("Buy Condition met");

    return(true);
    }
   return (false);
}

//+------------------------------------------+
//| CheckSellCondition                       |
//|                                          |
//| Check if new trend is down               |
//| return false for sell condiotion not met |
//| return true for sell condition met       |
//+------------------------------------------+

bool CheckSellCondition(int STrend)
{
 
   if (STrend < 0)
   {
       if (Debug == 1) Print ("Sell Condition met");
       return(true);
    }
   return (false);

}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//---- 
   int donttrade, allexit;
   static bool FirstFlatMarket=false;
   
	int MagicNumber = 3000 + func_Symbol2Val(Symbol())*100 + func_TimeFrame_Const2Val(Period()); 

   string setup="stv2" + Symbol() + "_" + func_TimeFrame_Val2String(func_TimeFrame_Const2Val(Period()));

   if (UseJuice && Period()!=15)
   {   
     Alert ("Juice Is Recommended for 15 Min Chart only!!");
     return(0);
   }
//+------------------------------------------------------------------+
//| Condition statements                                             |
//| Change or add for your strategy                                  |
//+------------------------------------------------------------------+

   SilverTrendVal = SilverTrend(SSP, RISK, 1);

   donttrade = 0;
   allexit = 0;
   
//+------------------------------------------------------------------+
//| Friday Exits                                                     |
//+------------------------------------------------------------------+

   if(DayOfWeek()==5 && Hour()>=18) donttrade=1;
   if(DayOfWeek()==5 && Hour()>=20) allexit=1;
   
//+------------------------------------------------------------------+
//| Check for Open Position                                          |
//+------------------------------------------------------------------+

     NumBuys = CheckOpenBuyPositions(MagicNumber);
     if (NumBuys > 0)
     {
          if(GetSTExit("BUY",allexit,SilverTrendVal)) ClosePositions("BUY");
     }     
     NumSells = CheckOpenSellPositions(MagicNumber);
     if (NumSells > 0)
     {
         if(GetSTExit("SELL",allexit,SilverTrendVal)) ClosePositions("SELL");
     }     
// Check if any open positions were not closed
     TradesInThisSymbol = CheckOpenPositions(MagicNumber);
     
//+------------------------------------------------------------------+
//| Check if OK to make new trades                                   |
//+------------------------------------------------------------------+


   if(AccountFreeMargin() < Margincutoff) {
     return(0);}
   if(TradesInThisSymbol > 0) {
     return(0);}
   if(CurTime() < LastTime) {
     return(0);}

// Money Management
// Moved after open positions are closed for more available margin
     
   if(mm == 1)
   {
     lotMM = LotsOptimized(MagicNumber);
// Not sure if this is needed but placing here from LotsOptimized()
     if(LiveTrading == 1)
     {
        if (AccountIsMini == 0 && lotMM < 1.0) lotMM = 1.0;
     }
   }
   else {
     lotMM = Lots; // Change mm to 0 if you want the Lots parameter to be in effect
   }
   
   OrderText = ""; //Must be blank before going into the main section

// Checkif filters allow trades

   FlatMarket = false;   // assume market is not flat
   OK2Buy = true;
   OK2Sell = true;

   if (UseJuice)
   {
// Check Juice filter for flat market

      CurrentJuice = Juice(1, JuicePeriod, JuiceLevel);
     
      // is juice ok for trading?          
      if (CurrentJuice<=0)
      { 
       OK2Buy = false;
       OK2Sell = false;
       FlatMarket = true;
       FirstFlatMarket = false;
      }
   }
   
   if (FlatMarket && !FirstFlatMarket)
   {
       FirstFlatMarket = true;
       if (Debug == 1)
       {
          Print ("Filter says Market is flat");
          Write ("Filter says Market is flat");
       }
   }
   if (FlatMarket) return (0);

	if(CheckBuyCondition(SilverTrendVal) && (Turnon == 1) && (donttrade == 0) && OK2Buy)
	{
		OrderText = "BUY";
		if (Debug == 1)
		{
         Print ("Filter says OK to BUY");
         Write ("Filter says OK to BUY");
         Print ("Buy  at ", TimeToStr(CurTime()), " for ", DoubleToStr(Ask,4) );
         Write ("Buy at " + TimeToStr(CurTime())+ " for " + DoubleToStr(Ask,4));
      }
		if (StopLoss>0) {
		 Sl = Ask-StopLoss*Point;
		} else {
		 Sl=0;
		}
		if (TakeProfit == 0) 
		    Tr = 0;
		else
		    Tr = Ask+TakeProfit*Point;
	}

	if(CheckSellCondition(SilverTrendVal) && (Turnon == 1) && (donttrade == 0) && OK2Sell)
	{
		OrderText = "SELL";
		if (Debug == 1)
		{
         Print ("Filter says OK to Sell");
         Write ("Filter says OK to Sell");
         Print ("Sell at ", TimeToStr(CurTime()), " for ", DoubleToStr(Bid,4) );
         Write ("Sell at " + TimeToStr(CurTime())+ " for " + DoubleToStr(Bid,4));
      }
		if (StopLoss>0) {
		 Sl = Bid+StopLoss*Point;
		} else {
		 Sl = 0;
		}
		if (TakeProfit == 0) 
		    Tr = 0;
		else
		    Tr = Bid-TakeProfit*Point;
	}
   if(OrderText != "" && TradesInThisSymbol == 0) 
   {

	   LastTime = DoTrades(OrderText,setup,MagicNumber, lotMM,Sl,Tr,CurTime());
      return(0);
   }
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Functions beyond this point should not need to be modified       |
//| Eventually will be placed in include file                        |
//+------------------------------------------------------------------+

//+--------------------------------------------------------+
//|  ClosePositions module cut from CheckOpenPositions     |
//|  Try to close positions 3 times                        |
//+--------------------------------------------------------+

int ClosePositions(string type)
{
  int err,cnt;
  
   // try to close 3 Times
      
   err = 1;
   cnt = 0;
   while (err>0 && cnt < 3)
   {
      if (type == "BUY")  err = HandleBuys(true);
      if (type == "SELL") err = HandleSells(true);
      if (err > 0) cnt++;
   }
   return (0);
}

//+--------------------------------------------------------+
//|  HandleBuys uses exit condition to determine close     |
//+--------------------------------------------------------+
int HandleBuys(int ExitConditions)
{
   int err = 0;
   
   if (ExitConditions == 1)   
   {
      if (!OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Violet)) err = GetLastError();
      return(err); // exit
   }
    if(TrailingStop>0) 
    {                
      if(Bid-OrderOpenPrice()>Point*TrailingStop)
      {
         if(OrderStopLoss()<Bid-Point*TrailingStop)
         {
            if (!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Aqua))
            {
               err = GetLastError();
            }
            return(err);
          }
      }
   }
   return(err);
}

//+--------------------------------------------------------+
//|  HandleSells uses exit condition to determine close    |
//+--------------------------------------------------------+

int HandleSells(int ExitConditions)
{
            
   int err = 0;
            
  if (ExitConditions == 1)
  {
     if (!OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Violet)) err=GetLastError();
     return(err); // exit
  }
   if(TrailingStop>0)  
   {                
      if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
      {
         if(OrderStopLoss()==0.0 || OrderStopLoss()>(Ask+Point*TrailingStop))
         {
           if (!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Aqua))
           {
              err=GetLastError();
           }
           return(err); // exit
         }
      }
   }
   return(err);
}
//+-------------------------------------------+
//| DoTrades module cut from start            |
//|  No real changes                          |
//+-------------------------------------------+
datetime DoTrades(string OrdText, string SetupStr,int MagicNum,double lotM, double SSl, double TTr, datetime LstTime)
{
   double Min_OrderPrice;
   int err,tries;
   double dtries;
   int ticket;
   datetime lsttim;

   lsttim = LstTime;

   if(OrderText == "BUY")
   {
       Min_OrderPrice=MinOrderPrice(OP_BUY, MagicNum);
       if (Min_OrderPrice>0 && Min_OrderPrice<=Ask*1.05) {
          Print("Buy too expensive => MinOrderPrice= " + Min_OrderPrice + "  Ask=" + Ask);
       } else {
           tries = 0;
           while (tries < 3)
           {
              ticket = OrderSend(Symbol(),OP_BUY,lotM,Ask,Slippage,SSl,TTr,SetupStr,MagicNum,0,Green);
              if (Debug == 1)
              {
                 dtries = tries;
                 Print ("Buy at ",TimeToStr(CurTime())," for ",Ask, " try:",tries);
                 Write ("Buy at " + TimeToStr(CurTime()) + " for " + DoubleToStr(Ask,4) + " try:" + DoubleToStr(dtries,0));
              }
              lsttim += 12;
              if (ticket <= 0) {
                tries++;
              } else tries = 3;
           }
           if(ticket<=0) {
              err = GetLastError();
              Alert("Error opening BUY order [" + SetupStr + "]: (" + err + ") " + ErrorDescription(err)); 
              if (Debug == 1) Write("Error opening BUY order [" + SetupStr + "]: (" + err + ") " + ErrorDescription(err)); 
                
           }
           return(lsttim);
       }
   }
   else if(OrderText == "SELL")
   {
       Min_OrderPrice=MinOrderPrice(OP_SELL, MagicNum);
       if (Min_OrderPrice>0 && Min_OrderPrice<=Bid) {
          Print("Buy too expensive MinOrderPrice= " + Min_OrderPrice + "  Bid=" + Bid);
       } else {
          tries = 0;
          while (tries < 3)
          {
            ticket = OrderSend(Symbol(),OP_SELL,lotM,Bid,Slippage,SSl,TTr,SetupStr,MagicNum,0,Red);
            if (Debug == 1)
            {
               dtries = tries;
               Print ("Sell at ",TimeToStr(CurTime())," for ",Bid, " try:",tries);
               Write ("Sell at " + TimeToStr(CurTime()) + " for " + DoubleToStr(Bid,4) + " try:" + DoubleToStr(dtries,0));
             }
            lsttim += 12;
            if (ticket <= 0)
            {
              tries++;
             }else tries = 3;
           }
              
            
          if(ticket<=0) {
             err = GetLastError();
             Alert("Error opening Sell order [" + SetupStr + "]: (" + err + ") " + ErrorDescription(err)); 
             if (Debug == 1) Write("Error opening Sell order [" + SetupStr + "]: (" + err + ") " + ErrorDescription(err)); 
           }
           return(lsttim);
        }
    }
    return(lsttim);
}


//+------------------------------------------------------------------+
//| Check Open Position Controls                                     |
//+------------------------------------------------------------------+
  
int CheckOpenPositions(int MagicNumbers)
{
   int cnt, total, NumPositions;
   int NumBuyTrades, NumSellTrades;   // Number of buy and sell trades in this symbol
   
   total=OrdersTotal();
   NumBuyTrades = 0;
   NumSellTrades = 0;
   for(cnt=0;cnt<total;cnt++)
     {
      if ( OrderSelect (cnt, SELECT_BY_POS) == false )  continue;
      if ( OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumbers)  continue;
      
      if((OrderType() == OP_BUY || OrderType() == OP_BUYSTOP) && (OrderSymbol()==Symbol()))
          {
             NumBuyTrades++;
             
          }
      if((OrderType() == OP_SELL || OrderType() == OP_SELLSTOP) && (OrderSymbol()==Symbol()))
          {
             NumSellTrades++;
             
          }
     }
     NumPositions = NumBuyTrades + NumSellTrades;
     return (NumPositions);
  }
  
int CheckOpenBuyPositions(int MagicNumbers)
{
   int cnt, total, NumPositions;
   int NumBuyTrades;   // Number of buy trades in this symbol
   
   total=OrdersTotal();
   NumBuyTrades = 0;
   for(cnt=0;cnt<total;cnt++)
     {
      if ( OrderSelect (cnt, SELECT_BY_POS) == false )  continue;
      if ( OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumbers)  continue;
      
      if((OrderType() == OP_BUY || OrderType() == OP_BUYSTOP) && (OrderSymbol()==Symbol()))
          {
             NumBuyTrades++;
          }
     }
     return (NumBuyTrades);
  }

int CheckOpenSellPositions(int MagicNumbers)
{
   int cnt, total, NumPositions;
   int NumSellTrades;   // Number of sell trades in this symbol
   
   total=OrdersTotal();
   NumSellTrades = 0;
   for(cnt=0;cnt<total;cnt++)
     {
      if ( OrderSelect (cnt, SELECT_BY_POS) == false )  continue;
      if ( OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumbers)  continue;
      
      if((OrderType() == OP_SELL || OrderType() == OP_SELLSTOP) && (OrderSymbol()==Symbol()))
          {
             NumSellTrades++;
          }
             
     }
     return (NumSellTrades);
  }
       
//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+

double LotsOptimized(int Mnr)
  {
   double lot=Lots;
   int    orders=HistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
   int    tolosses=0;
//---- select lot size
   lot=NormalizeDouble(MathFloor(AccountFreeMargin()*Riskpercent/10000)/10,1);
   
//---- calcuulate number of losses orders without a break
   if(DecreaseFactor>0)
     {
      for(int i=orders-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Error in history!"); break; }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL || OrderMagicNumber()!=Mnr) continue;
         //----
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
        }
      for(i=orders-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Error in history!"); break; }
         if(TimeDay(OrderCloseTime()) != TimeDay(CurTime())) continue;
         //----
         if(OrderProfit()<0) tolosses++;
        }
      if(losses>1) lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
     }
  // lot at this point is number of standard lots
  
//  if (Debug == 1) Print ("Lots in LotsOptimized : ",lot);
  
  // Check if standard Account
  
  if(AccountIsMini==1)
  {
    lot = MathFloor(lot);
    lot = lot / 10;
    
// Use at least 1 mini lot

   if(lot<0.1) lot=0.1;

  }else
  {
    if (lot < 1.0) lot = 1.0;
    if (lot > 100) lot = 100;
  }

   return(lot);
  }

//+------------------------------------------------------------------+
//| Time frame interval appropriation  function                               |
//+------------------------------------------------------------------+

int func_TimeFrame_Const2Val(int Constant ) {
   switch(Constant) {
      case 1:  // M1
         return(1);
      case 5:  // M5
         return(2);
      case 15:
         return(3);
      case 30:
         return(4);
      case 60:
         return(5);
      case 240:
         return(6);
      case 1440:
         return(7);
      case 10080:
         return(8);
      case 43200:
         return(9);
   }
}

//+------------------------------------------------------------------+
//| Time frame string appropriation  function                               |
//+------------------------------------------------------------------+

string func_TimeFrame_Val2String(int Value ) {
   switch(Value) {
      case 1:  // M1
         return("PERIOD_M1");
      case 2:  // M1
         return("PERIOD_M5");
      case 3:
         return("PERIOD_M15");
      case 4:
         return("PERIOD_M30");
      case 5:
         return("PERIOD_H1");
      case 6:
         return("PERIOD_H4");
      case 7:
         return("PERIOD_D1");
      case 8:
         return("PERIOD_W1");
      case 9:
         return("PERIOD_MN1");
   	default: 
   		return("undefined " + Value);
   }
}

int func_Symbol2Val(string symbol) {
	if(symbol=="AUDCAD") {
		return(1);
	} else if(symbol=="AUDJPY") {
		return(2);
	} else if(symbol=="AUDNZD") {
		return(3);
	} else if(symbol=="AUDUSD") {
		return(4);
	} else if(symbol=="CHFJPY") {
		return(5);
	} else if(symbol=="EURAUD") {
		return(6);
	} else if(symbol=="EURCAD") {
		return(7);
	} else if(symbol=="EURCHF") {
		return(8);
	} else if(symbol=="EURGBP") {
		return(9);
	} else if(symbol=="EURJPY") {
		return(10);
	} else if(symbol=="EURUSD") {
		return(11);
	} else if(symbol=="GBPCHF") {
		return(12);
	} else if(symbol=="GBPJPY") {
		return(13);
	} else if(symbol=="GBPUSD") {
		return(14);
	} else if(symbol=="NZDUSD") {
		return(15);
	} else if(symbol=="USDCAD") {
		return(16);
	} else if(symbol=="USDCHF") {
		return(17);
	} else if(symbol=="USDJPY") {
		return(18);
	} else {
		Comment("unexpected Symbol");
		return(0);
	}
}

//+------------------------------------------------------------------+
//| Average price efficiency  function                               |
//+------------------------------------------------------------------+

double MinOrderPrice(int OType, int OMagicNumber) {
double MinPrice;

   if (OrderType()==OP_BUY) {
      MinPrice=1000000;
   } else {
      MinPrice=0;
   }
 
   for(int cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      
      if(OrderType()==OType && OrderSymbol()==Symbol() && OrderMagicNumber()==OMagicNumber) {
         if (OrderType()==OP_BUY) {
            if (OrderOpenPrice()<MinPrice) {
               MinPrice=OrderOpenPrice();
            }
         } else {
            if (OrderOpenPrice()>MinPrice) {
               MinPrice=OrderOpenPrice();
            }
         }
      }
   }
   if (MinPrice==1000000) MinPrice=0;
   return(MinPrice);
   
}

