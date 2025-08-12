//-------------------------------------------------------------
// Indo Run EA 1.5
//-------------------------------------------------------------
// by expat1967 ;) Cheers

#property copyright "expat&&Indo Investasi Members"
#property link      "expat&&Indo Investasi Forum"

#include <stdlib.mqh>
#include <WinUser32.mqh>

// exported variables
extern string Menu = "Indo Run Setup";
extern string EAName = "";            //Comment for your orders, you might better leave it empty ;) 
extern bool IndoRunLabelOn = true;   //Switches Chart Label on/off
extern string MagicNumber = "Random Magic will overide manual set Magic Number";
extern int Magic = 128738;            //Order Magic Number
extern bool UseRandomMagic = false;   //Switches the Random Magic Number on/off
extern int RandomMagicLower = 100000; //Sets the lower Magic Number boundry
extern int RandomMagicUpper = 200000; //Sets the upper Magic Number boundry
extern string DayFilter = "Select the days for Indo Run to trade";
extern bool Monday = true;              // Selecting a day true/false will hold the EA off trading that day if no trades are open
extern bool Tuesday = true;             // Overides day filter if trades are open (Basket)
extern bool Wednesday = true;
extern bool Thursday = true;
extern bool Friday = true; 
extern bool Saturday = true; 
extern bool Sunday = true;
extern bool TradeMonthEnd = true;
extern int MonthEndOffset = 3;   //Offset to define the last trading day of a month (31 - Offset)
extern bool TradeFirstDayOffMonth = true; 
extern int DayOffset = 0;     //Per default the Offset is 0 thus the 1st of a month is filtered
extern double GMTOffset = 0;
extern bool TradeNFP = true;  //Trade Day of Non Farm Employment
extern bool TradeMondayAfterNFP = true;  //Trade Monday till US Session after Non Farm Employment / TradeNFP must be set to true
extern bool TradeADP = true;  //Trade Day of ADP Non Farm Employment
extern string HourFilter = "Select the Trading Hours or set to 24h";
extern bool Trading24h = true;      
extern int HoursFrom = 10;          //Start Trading Hour Broker Time (Standad Settings GMT), the EA overides time if trades are open (Basket)
extern int HoursTo = 6;            //Stop Trading Hour Broker Time Standard Setting GMT), the EA overides time if trades are open (Basket)
extern string Session_Filter = "Only in 24 Mode: Use both Session Filter together only!";
extern string Session_Filter1 = "Filters per default London Session (GMT)!";
extern bool SessionFilter1 = false;   //Session Filter Settings in GMT / Use only in combination with SessionFilter 2
extern double SF1Hour_On = 5;
extern double SF1MinuteOn =45;
extern double SF1Hour_Off = 9;
extern double SF1MinuteOff = 0;
extern string Session_Filter2 = "Filters per default NY Session (GMT)!";
extern bool SessionFilter2 = false;   //Session Filter Settings in GMT / Use only in combination with SessionFilter 1
extern double SF2Hour_On = 11;
extern double SF2MinuteOn =45;
extern double SF2Hour_Off = 17;
extern double SF2MinuteOff = 30;
extern string Info9 = "News Filter Setup";
extern bool AvoidNews = true; //Switches News Filter on/off
extern bool High_Impact=true;
extern int MinsUntilNextHighNews=90;
extern int MinsSincePrevHighNews=90;
extern bool Medium_Impact=true;
extern int MinsUntilNextMediumNews=90;
extern int MinsSincePrevMediumNews=90;
extern bool Low_Impact=false;
extern int MinsUntilNextLowNews=60;
extern int MinsSincePrevLowNews=60;
extern string Info10 = "News Currency Filter";  //Select the Currency which News should be filtered
extern bool USD = true;
extern bool EUR = false;
extern bool GBP = true;
extern bool JPY = false;
extern bool AUD = false;
extern bool CAD = false;
extern bool CHF = false;
extern bool NZD = false;
extern int TSD_CalendarID = 4;  //  TSD News Calendar ID reference on the TSD Homepage
extern string TSD_Calendar_URL = "http://calendar.forex-tsd.com/calendar.php?csv=1&date=";
extern string Info5 = "Main Order Setup";
extern string PAO = " ProfitAllOrder will calculate automatically while the Lotssize is changed!";
extern double ProfitAllOrder = 15; //Cumulated Sell Order Take Profit in Account Currency based on 0.1 Lotsize!!! 
extern bool FixedProfitAO = false; // If true, ProfitAllOrder amount set will be used only/Have to be set to tru while using Martingale!!!
extern bool ADVProfitMode = false; //Advanced Profit Modue which reduces the Profit Target on increasing opened Orders in the Basket
extern bool ATRProfitMode = false; //This Mode will take the Profit (>=ATR Profit) while the ATR is Filtering on open trades
extern double ATRProfit = 4;        //This value does not adjusts automatically while the Lotsize is changed.
extern bool ADVATRProfit = false;   //Overrides ATRProfit set and will apply ProfitAllOrders/ADVATRProfitx
extern double ADVATRProfitx = 3;      //ProfitAllOrders/ADVATRProfitx
extern bool DynamicProfit = false;  //If true, when ProfitAllOrder limit is reached the profit will trail by the defined step
extern double DynamicProfitStep = 1;  //Inc of the ProfitAllOrder value
extern bool Trailing = false; //If true, Profit will be trailed while if Drawdown as set in TrailingStop and BE
extern int OrderTreshold = 20; //Number of open trades for the trailing to start
extern bool Breakeven = false; //Breakeven Profit upon Order Treshold. Requires Trailing to be set to true
extern double BE = 0; //Breakeven in Account Currency
extern bool OrderTrailing = false; //If true Order Profits will be trailed downwards while in DD after Breakeven
extern double TrailingStop = 15; //Profit of Account Currency on which the Profit is reduced/trailed per open Order after Breakeven.
int OpenOrdersLimit = 0;            //Limits the number of open orders
extern bool DeletePOMode = true;           // Bug: if false Sell Open Orders are not registered and counted
extern bool ReverseOrder = false;   //Reverse/Hedging Trades from a defined Treshold of trades onwards
extern int OpenOrderTreshold = 10;   //Reverse/Hedging Trade Treshold
extern double ReverseOrderLotDiv = 2;   //Lot divider for Reverse/Hedging Trades (Lot/ReverseOrderLotDiv)
extern bool ReversalContBasket = true;  //Continue Basket while Orders are reversed in addition
extern int SingleOrderSL = 0;       //Stop Loss of each individual Order in Pips
extern int SingleOrderTP = 0;       //Take Profit of each individual Order in Pips
extern bool ADVOffsetMode = false;  //If false Pending Orders are placed on the current ASK/Bid Price
extern bool ATRStepOn = false;    //If true the step value/price offset is linked to the current ATRPips value
extern bool ATRPipsToStep = false; //If true the ATRPips value will be used as Step/Price Offset
extern int PriceOffset = -16;     //Step/Gap in Pips where Pending Order is placed to current price basic
extern bool StepFactorOn = false; //Factor which increases the Step per Order
extern int StepFactor = 10;       //ProfitOffset*(OrderCounter/StepFactor+1)
extern int PriceOffset1 = 0;       ////Step/PriceOffset added in Low Range ATR while ATRStepOn is set to true
extern int PriceOffset2 = -1;      //Step/PriceOffset added in Mid Range ATR while ATRStepOn is set to true
extern int PriceOffset3 = -2;      //Step/PriceOffset added in High Range ATR while ATRStepOn is set to true
extern double Lot = 0.1;      //Single Order Lotsize / If FixedProfitAO = false Profit Target will be calculated automatically to the Profit Target set on 0.1 base (0.1 Lot = 15$ standard setting)
extern int  Slippage=4;       //Price Change in Pips allowed during Order Processing
extern string AutomaticLots1 = "Automatic Lotsize based on Account Balance!";
extern string AutomaticLots2 = "ProfitAllOrder gets adjusted automatically!";
extern bool AutoLotSize = false;  //Automatic Lotsize based on Account Balance (Account Balance/300*MinLots)
extern double Risk = 2;           //"Risk Factor on which the Lotsize increases
extern double MinLots = 0.01;      //minimum Lotsize only used when Autolotsize is activated
extern bool KLotSize = false;      // if true Lot Size will double every 10K+
extern bool DoubleLots = false;   //Doubles the Lotsize in the Asian Session
extern bool Martingale = false;   //Need to set FixedProfitAO=true!!!!
extern double LotFactor = 1.4;    //Increasing Factor of Martingale Lotsize  
extern double MartingaleMaxLot = 0.5;  //Limit of Losize of Martingale!!!
extern bool DoubleBasket = false;  //if true the EA will trade with two Order Baskets (First Basket opens Trade second Basket comes online in addition)
extern bool TripleBasket = false;  //if true the EA will trade with three Order Baskets (Second Basket opens Trade third Basket comes online in addition)
extern string Timed_Stop = "Stops Trading and closes all trades at selected time of a day!";
extern bool TimedStop = false;        //Switches Time to close all open orders once a day on/off
extern int StopHour = 14;             //Timed Stop Hour GMT
extern int StopMinute = 0;            //Timed Stop Minute 
extern string ATR_Filter = "ATR Filter selection and setup!";
extern bool ATROn = true;             //Switches ATR Filter on/off
extern bool FilterMod = false;
extern int ATR_Period1 = 7;
extern int ATR_Period2 = 7;
extern int ATR_Period3 = 7;
extern double ATRShift1 = 0.0;
extern double ATRShift2 = 3.0;
extern double ATRShift3 = 5.0;
extern double ATRUpLimit1 = 13.0;
extern double ATRDnLimit1 = 7.0;
extern double ATRUpLimit2 = 21.0; 
extern double ATRDnLimit2 = 16.0;
extern double ATRUpLimit3 = 26.0;
extern double ATRDnLimit3 = 24.0;
extern string Info15 = "CCI Filter Settings";
extern bool CCIFilterOn = false;
extern double CCIPeriod1 = 14;
extern double CCIPeriod2 = 14;
extern double CCIShift1 = 0;
extern double CCIShift2 = 5;
extern double CCICurrentUp = 65;
extern double CCICurrentDown = -65;
extern double CCIPreviousUp = 75;
extern double CCIPreviousDown = -75;
extern string Info16 = "Momentum Filter Settings";
extern bool MomentumFilterOn = false;
extern double MomentumPeriod1 = 3;
extern double MomentumPeriod2 = 3;
extern double MomentumShift1 = 0;
extern double MomentumShift2 = 3;
extern double MomentumCurrentUp = 100.1;
extern double MomentumCurrentDown = 99.9;
extern double MomentumPreviousUp = 100.2;
extern double MomentumPreviousDown = 99.8;
extern string Info17 = "RSI Filter Settings";
extern bool RSIFilterOn = false;
extern double RSIPeriod1 = 3;
extern double RSIPeriod2 = 3;
extern double RSIShift1 = 0;
extern double RSIShift2 = 3;
extern double RSICurrentUp = 51;
extern double RSICurrentDown = 49;
extern double RSIPreviousUp = 53;
extern double RSIPreviousDown = 47;
extern string Info18 = "MA Filter Settings";
extern bool MAFilterOn = false;  
extern double MAPeriod1 = 3;
extern double MAPeriod2 = 3;
extern double MAIShift1 = 0;
extern double MAIShift2 = 0;
extern double MAMethod = 0;
extern double MAShift1 = 0;
extern double MAShift2 = 3;
extern double MACurrentUp = 0.00025;
extern double MACurrentDown = 0.00025;
extern double MAPreviousUp = 0.0005;
extern double MAPreviousDown = 0.0005;
extern string Info19 = "Envelopes Filter Settings";
extern bool EnvelopesFilterOn = false;
extern int EnvelopesTimeFrame = 0;  //Indicator timeframe in minutes (0 = current chart timeframe)
extern int EnvelopesMAPeriod1 = 14;
extern int EnvelopesMAPeriod2 = 14;
extern int EnvelopesMAMethod = 0;
extern int EnvelopesMAShift1 = 0;
extern int EnvelopesMAShift2 = 0;
extern int EnvelopesAppliedPrice = 0;
extern double EnvelopesDeviation = 0.1;  //Sets the distance/deviation of the upper and lower indicator line
extern int EnvelopesShift1 = 0;
extern int EnvelopesShift2 = 0;
extern string Info20 = "Specific Order and Emergency Functions";
extern bool DeletePOATR = true;      // Switch to delete all pending orders while ATR is active
extern bool DeleteOrderATR = false;  // Switch to close all open orders while ATR is active (disabled due to current strategy set
extern string Stop_Out = "Closes all trades in basket on cummulated Profit/Loss!";
extern bool LossStopOutOn = false;  //Switches Cumulated Loss Stop Out On on/off
extern int LossStopOut = -5000;     // Cumulated Loss in Account Currency which will close all open orders
extern string CAT = "!!!Closes all trades in basket when true!!!";
extern bool CloseAllTrades = false; // Closes all open orders


// local variables
double PipValue=1;    // this variable is here to support 5-digit brokers
bool Terminated = false;
string LF = "\n";  // use this in custom or utility blocks where you need line feeds
int NDigits = 4;   // used mostly for NormalizeDouble in Flex type blocks
int ObjCount = 0;  // count of all objects created on the chart, allows creation of objects with unique names
bool FirstTime33 = false;
bool FirstTime35 = false;
int Today6 = -1;
int Count32 = 0;
double dblProfit=0;
string ATR = "";
string Trading = "";
int OrderCounter =0;  //counts open orders including pending orders
bool Overide = false;
int Hour1 = 1;
int Minute1 = 2;
string MagicChange = "Waiting...";
string RMStatus = "Waiting...";
bool Buffer = true;
double ProfitAllOrders = 0;
double TrailingStops =0;
string SessionFilter = "Waiting...";
double ATRPips;
double ATRPrePips1;
double ATRPrePips2;
string Zone1;
string Zone2;
string Zone3;
string Zone4;
string Zone5;
string AutoLot;
string FilterMods;
bool AsianSession = false;
double Lots;
string Double_Lot;
double TotalTradeLots;
double BuyLots;
double SellLots;
bool NewsFilter;
string Filter;
string NewsF;
string CCIStatus;
string MomentumStatus;
string RSIStatus;
string MAStatus;
string EnvelopeStatus;
bool ATRProfitTrigger=false;
double MagicBuffer;
double DDBuffer=0;
string Basket="1";
double TrailingProfit[4];
int BasketTrailing=1;
bool BuyBasket;
bool SellBasket;
datetime NewsTimes[1000];
int NewsRatings[1000];
int NewsTotal;
bool EnableFileErrorLogging = false;
int logHandle=-1;

//*******************************************************************************************************

int init()
{
    NDigits = Digits;
    
    ObjectsDeleteAll();      // clear the chart
    
 //   GlobalVariableSet("OldBalance", AccountBalance());
    
    
    Comment("");    // clear the chart
    if ((Buffer == true)&&(!IsTesting()))
    {
      ReadMagic();
      Buffer=false;
    }
    MagicBuffer=Magic;
}

// Expert start
//*******************************************************************************************************
int start()
{
    if (Bars < 10)
    {
        Comment("Not enough bars!");
        return (0);
    }
    if (Terminated == true)
    {
        Comment("EA Terminated!");
        return (0);
    }
    OnEveryTick24();
}
//*******************************************************************************************************
void OnEveryTick24()
{
    if (true == false && true) PipValue = 10;
    if (true && (NDigits == 3 || NDigits == 5)) PipValue = 10;
    
    if(TripleBasket||DoubleBasket)
    {
      TripleBasket();
    }
    else
    {
      Sequence();
    }
}
//******************************************************************************************************
void Sequence()
{
    ReadATR();
    News();
    CCI();
    Momentum();
    RSI();
    MA();
    Envelopes();
    Filter();
    if (CloseAllTrades == false)
    {
      LotSize();
      OnceAnHour1(); 
      WeekdayFilter23();
      AtCertainTime6();      
    }
    PrintInfoToChart32();
    CloseOrderIf21();
}
//******************************************************************************************************    
bool MonthEnd(string symb, int year1, int month1, int day1, int ofs)
{   
   if (!TradeMonthEnd)
   {
      if (day1 > (31 - ofs)) return(false);
      if (month1 == 2 && day1 > (29 - ofs)) return(false);
   }
   return(true);
}
//******************************************************************************************************
bool MonthFirst(string symb, int year1, int month1, int day1, int ofs)
{   
   if (!TradeFirstDayOffMonth)
   {
      if (day1 == 1 - ofs) return(false);
   }
   return(true);
}
//*******************************************************************************************************
bool NFP(string symb, int year1, int month1, int day1, int ofs)
{
   if(!TradeNFP)
   {
      if(!TradeMondayAfterNFP)
      {
         if(DayOfWeek()==0&&day1>3&&day1<11)return(false);
         if(DayOfWeek()==1&&day1>4&&day1<12)return(false);   
      }
      if(DayOfWeek()==5&&day1>1&&day1<9)return(false);
   }
   return(true);
}
//*******************************************************************************************************
bool ADP(string symb, int year1, int month1, int day1, int ofs)
{
   if(!TradeADP)
   {
      if((DayOfWeek()==3&&day1>=1&&day1<=8)||(DayOfWeek()==3&&day1==30))return(false);
   }
   return(true);
}
//*******************************************************************************************************
void WeekdayFilter23()
{
    double GMT_Hour;
    int servertime = TimeCurrent();
    int GMT_time = servertime - 3600.0 * GMTOffset;
    
    if (((Monday && DayOfWeek() == 1) || (Tuesday && DayOfWeek() == 2) || (Wednesday && DayOfWeek() == 3) ||
    (Thursday && DayOfWeek() == 4) || (Friday && DayOfWeek() == 5) || (Saturday && DayOfWeek() == 6) || (Sunday && DayOfWeek() == 0))
    &&(MonthEnd(Symbol(), TimeYear(GMT_time), TimeMonth(GMT_time), TimeDay(GMT_time), MonthEndOffset))
    &&(MonthFirst(Symbol(), TimeYear(GMT_time), TimeMonth(GMT_time), TimeDay(GMT_time), DayOffset))
    &&(NFP(Symbol(), TimeYear(GMT_time), TimeMonth(GMT_time), TimeDay(GMT_time), 0))
    &&(ADP(Symbol(), TimeYear(GMT_time), TimeMonth(GMT_time), TimeDay(GMT_time), 0)))
    {
        Overide = false;
        HoursFilter22();       
    }
    else
    {       
        if ((!IfOrderDoesNotExist(1))&&(!IfOrderDoesNotExist(0)))
        {
           Trading = "Not Trading!";
           DeletePendingOrder(2);
           DeletePendingOrder(3);
               if(!MonthEnd(Symbol(), TimeYear(GMT_time), TimeMonth(GMT_time), TimeDay(GMT_time), MonthEndOffset))
               {
                  Trading = "Not Trading Months End!";
               }
               if(!MonthFirst(Symbol(), TimeYear(GMT_time), TimeMonth(GMT_time), TimeDay(GMT_time), DayOffset))
               {
                  Trading = "Not Trading 1st Day/Month!";
               }
               if(!NFP(Symbol(), TimeYear(GMT_time), TimeMonth(GMT_time), TimeDay(GMT_time), 0))
               {
                  Trading = "Not Trading NFP!";
               }
               if(!NFP(Symbol(), TimeYear(GMT_time), TimeMonth(GMT_time), TimeDay(GMT_time), 0))
               {
                  Trading = "Not Trading ADP!";
               }               
        }
        else
        {
           Overide = true;
           HoursFilter22();
        }
    }
}
//*******************************************************************************************************
void HoursFilter22()
{
    int datetime800 = TimeCurrent();
    int hour0 = TimeHour(datetime800);
    datetime currTime = TimeCurrent();
    double SF1HourOn = SF1Hour_On + GMTOffset;
    double SF1HourOff = SF1Hour_Off + GMTOffset;
    double SF2HourOn = SF2Hour_On + GMTOffset;
    double SF2HourOff = SF2Hour_Off + GMTOffset;
    datetime fromTime1 = StrToTime(DoubleToStr(SF1HourOn,0)+":"+DoubleToStr(SF1MinuteOn,0));
    datetime toTime1 = StrToTime(DoubleToStr(SF1HourOff,0)+":"+DoubleToStr(SF1MinuteOff,0));
    datetime fromTime2 = StrToTime(DoubleToStr(SF2HourOn,0)+":"+DoubleToStr(SF2MinuteOn,0));
    datetime toTime2 = StrToTime(DoubleToStr(SF2HourOff,0)+":"+DoubleToStr(SF2MinuteOff,0));
    int Hours_To = HoursTo + GMTOffset;
    int Hours_From = HoursFrom + GMTOffset;
    
  
    if (toTime2 > fromTime1 && (currTime < fromTime1 || currTime >= toTime2))
    {
      AsianSession = true;
    }
    else
    {
      AsianSession = false;
    }
    
    if (((Hours_From < Hours_To && hour0 >= Hours_From && hour0 < Hours_To) ||
    (Hours_From > Hours_To && (hour0 < Hours_To || hour0 >= Hours_From)))&& (Trading24h == false))
    {
        Trading = "Trading";
        CheckLastOrderType33();
        LimitOpenOrders28();
        CheckLastOrderType35();
    }
    else
    {
        if ((Trading24h == false)&&((!IfOrderDoesNotExist(1))&&(!IfOrderDoesNotExist(0))))
        {
            Trading = "Not Trading!";
            DeletePendingOrder(2);
            DeletePendingOrder(3);
        }
        else
        {
            if (Trading24h == false)
            {
               Trading = "Overide Hour/Day Filter";
               CheckLastOrderType33();
               LimitOpenOrders28();
               CheckLastOrderType35();
            }
        }
    }
    if (Trading24h == true)
    {
        if (Overide == true)
        {
            Trading = "Overide Hour/Day Filter";
        }
        else
        {
            Trading = "Trading 24h";
        }
        if (((SessionFilter1 == true) && (fromTime1 < toTime1 && (currTime < fromTime1 || currTime >= toTime1)))
           && ((SessionFilter2 == true) && (fromTime2 < toTime2 && (currTime < fromTime2 || currTime >= toTime2))))
           //change && to || to use Filters seperate!
        {
               SessionFilter = "Session opened for trading!";
               CheckLastOrderType33();
               LimitOpenOrders28();
               CheckLastOrderType35();   
        }
        else
        {
            if (((SessionFilter1 == true)||(SessionFilter2 == true))&&((!IfOrderDoesNotExist(1)) && (!IfOrderDoesNotExist(0))))
            {
               SessionFilter = "Session filtered!";
               DeletePendingOrder(2);
               DeletePendingOrder(3);
            }
            else
            {
               if ((SessionFilter1 == true)||(SessionFilter2 == true))
               {
                  SessionFilter = "Session Overide!";
                  CheckLastOrderType33();
                  LimitOpenOrders28();
                  CheckLastOrderType35();
               } 
            }    
        }
        if ((SessionFilter1 == false)&&(SessionFilter2 == false))
        {
            SessionFilter = "Sessions not filtered!";
            CheckLastOrderType33();
            LimitOpenOrders28();
            CheckLastOrderType35();
        }        
    }
}

//*******************************************************************************************************
void CloseOrderIf21()
{
    int POS=0;
    bool boolTerm=false;
    
    dblProfit=0;
    RefreshRates();
    while(boolTerm==false)
      {
       if(OrderSelect(POS,SELECT_BY_POS))
         {
         if(OrderMagicNumber()==Magic) dblProfit=dblProfit+OrderProfit();
         POS++;
         }
        else
        boolTerm=true;
      }
   if ((!DynamicProfit&&dblProfit>= Profit())||(dblProfit<=LossStopOut&&LossStopOutOn==true)||CloseAllTrades==true)
      {
         CloseOrder(1);
         CloseOrder(0);
      }
   if (DynamicProfit)
      {
            while(dblProfit-Profit()>DynamicProfitStep&&dblProfit-TrailingProfit[BasketTrailing]>DynamicProfitStep)TrailingProfit[BasketTrailing]=TrailingProfit[BasketTrailing]+DynamicProfitStep;
            if(dblProfit<TrailingProfit[BasketTrailing]&&dblProfit>=Profit())
            {
               CloseOrder(1);
               CloseOrder(0);
               TrailingProfit[BasketTrailing]=0;
            }
            if(ATRProfitMode&&ATRProfitTrigger&&dblProfit>=Profit())
            {
               CloseOrder(1);
               CloseOrder(0);
               TrailingProfit[BasketTrailing]=0;
            }
      }
  return(0);
}
//*******************************************************************************************************
void LimitOpenOrders28()
{
    int count = 0;
    int z = 0;
    for (int i=OrdersTotal()-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderSymbol() == Symbol())
        if (OrderMagicNumber() == Magic)
        {
            count++;
        }
    }
    else
    {
        Print("OrderSend() error - ", ErrorDescription(GetLastError()));
    }
       
    if ((count < OpenOrdersLimit)||(OpenOrdersLimit==0))
    {
          SendOrder();     
    }    
    if ((!IfOrderDoesNotExist(1))&&(!IfOrderDoesNotExist(0)))
    {
         count = 0;
         OrderCounter = count;
    }
    else
    {
         if (DeletePOMode == false)
         {
            z = 2;
         }
         else
         {
            z = 1;
         }
         count = count - z;
         OrderCounter = count;
    }
}
//*******************************************************************************************************
bool ReadATR()
{
    Zone1 = "Closed!";
    Zone2 = "Closed!";
    Zone3 = "Closed!";
    Zone4 = "Closed!";
    Zone5 = "Closed!";    

   double point=Point;
   if (point==0.00001) point=0.0001;
   else if (point==0.001) point=0.01;
   
   ATRPips =MathRound(iATR(Symbol(),PERIOD_M15,ATR_Period1,ATRShift1) / point);
   ATRPrePips1 =MathRound(iATR(Symbol(),PERIOD_M15,ATR_Period2,ATRShift2) / point);
   ATRPrePips2 =MathRound(iATR(Symbol(),PERIOD_M15,ATR_Period3,ATRShift3) / point);
    
   if(ATROn)
   {
      if (FilterMod == true)
      {
         FilterMods = "Modified!";
      
         if (ATRPrePips1 >= ATRDnLimit1 && ATRPrePips1 <= ATRUpLimit1
         && ATRPrePips2 >= ATRDnLimit1 && ATRPrePips2 <= ATRUpLimit1
         && ATRPips >= ATRDnLimit1 && ATRPips <= ATRUpLimit1) 
         {
            ATR = "ATR not filtering!";
            Zone1 = "Open!";
            return(1);
         }

         if (ATRPrePips1 >= ATRDnLimit2 && ATRPrePips1 <= ATRUpLimit2
         && ATRPrePips2 >= ATRDnLimit2 && ATRPrePips2 <= ATRUpLimit2
         && ATRPips >= ATRDnLimit2 && ATRPips <= ATRUpLimit2) 
         {
            ATR = "ATR not filtering!";
            Zone2 = "Open!";
            return(1);
         }

         if (ATRPrePips1 >= ATRDnLimit3 && ATRPrePips1 <= ATRUpLimit3
         && ATRPrePips2 >= ATRDnLimit3 && ATRPrePips2 <= ATRUpLimit3
         && ATRPips >= ATRDnLimit3 && ATRPips <= ATRUpLimit3) 
         {
            ATR = "ATR not filtering!";
            Zone3 = "Open!";
            return(1);
         } 

         if (ATRPrePips1 >= ATRDnLimit2 && ATRPrePips1 <= ATRUpLimit2
         && ATRPrePips2 >= ATRDnLimit2 && ATRPrePips2 <= ATRUpLimit2
         && ATRPips >= ATRDnLimit1 && ATRPips <= ATRUpLimit1) 
         {
            ATR = "ATR not filtering!";
            Zone4 = "Open!";
            return(1);
         } 

         if (ATRPrePips1 >= ATRDnLimit1 && ATRPrePips1 <= ATRUpLimit1
         && ATRPrePips2 >= ATRDnLimit2 && ATRPrePips2 <= ATRUpLimit2
         && ATRPips >= ATRDnLimit1 && ATRPips <= ATRUpLimit1) 
         {
            ATR = "ATR not filtering!";
            Zone5 = "Open!";
            return(1);
         } 
       }
       else
       {  
          FilterMods = "Standard!";
       
          if (ATRPrePips1 >= ATRDnLimit1 && ATRPrePips1 <= ATRUpLimit1 && ATRPrePips2 >= ATRDnLimit1 && ATRPrePips2 <= ATRUpLimit1 && ATRPips >= ATRDnLimit1 && ATRPips <= ATRUpLimit1 )
           {
            ATR = "ATR not filtering!";
            Zone1 = "Open!";
            return(1);
          }      
          if (ATRPrePips1 >= ATRDnLimit2 && ATRPrePips1 <= ATRUpLimit2 && ATRPrePips2 >= ATRDnLimit2 && ATRPrePips2 <= ATRUpLimit2 && ATRPips >= ATRDnLimit2 && ATRPips <= ATRUpLimit2 )  
          {
            ATR = "ATR not filtering!";
            Zone2 = "Open!";
            return(1);
          }       
          if (ATRPrePips1 >= ATRDnLimit3 && ATRPrePips1 <= ATRUpLimit3 && ATRPrePips2 >= ATRDnLimit3 && ATRPrePips2 <= ATRUpLimit3 && ATRPips >= ATRDnLimit3 && ATRPips <= ATRUpLimit3 )
          {
            ATR = "ATR not filtering!";
            Zone3 = "Open!";
            return(1);
          }
       }
       ATR = "ATR filtering!";
       return(0);
    }
    if (!ATROn)
    {
        ATR = "ATR Filter off!";
        FilterMods = "ATR Filter off!";
        return(1);
    }    
}
//*******************************************************************************************************
bool Filter()
{
    ATRProfitTrigger=false;
    if ((ReadATR()&&News()&&CCI()&&Momentum()&&RSI()&&MA()&&Envelopes())
    ||(IfOrderDoesNotExist(1))||(IfOrderDoesNotExist(0)))
    {
        Filter = "Not Filtering!";
        if (!ReadATR()&&((IfOrderDoesNotExist(1))||(IfOrderDoesNotExist(0))))
        {
           Filter = "Filter Overide!";
           ATRProfitTrigger=true;
        }
        if ((!News()||!CCI()||!Momentum()||!RSI()||!MA()||!Envelopes())&&(IfOrderDoesNotExist(1)||IfOrderDoesNotExist(0)))
        {
           Filter = "Filter Overide!";
           ATRProfitTrigger=true;
        }
        return(1);
    }
    else
    {
           Filter = "Filtering!";
           if (DeletePOATR)
           {
               DeletePendingOrder(2);
               DeletePendingOrder(3);
           }
           if (DeleteOrderATR)
           {
               CloseOrder(1);
               CloseOrder(0);
           }
           return(0);
    }
}
//*******************************************************************************************************
void SendOrder()
{
   if(!ReverseOrder)
   {
      if(IfOrderDoesNotExist(2)&&IfOrderDoesNotExist(1)&&DeletePOMode)DeletePendingOrder(2);
      if(IfOrderDoesNotExist(3)&&IfOrderDoesNotExist(0)&&DeletePOMode)DeletePendingOrder(3);
      if(!IfOrderDoesNotExist(2)&&!IfOrderDoesNotExist(1)&&Filter())PendingOrder(2);
      if(!IfOrderDoesNotExist(3)&&!IfOrderDoesNotExist(0)&&Filter())PendingOrder(3);
   }
   else
   {            
      if(IfOrderDoesNotExist(2)&&IfOrderDoesNotExist(1)&&DeletePOMode&&OrderCounter<OpenOrderTreshold)DeletePendingOrder(2);
      if(IfOrderDoesNotExist(3)&&IfOrderDoesNotExist(0)&&DeletePOMode&&OrderCounter<OpenOrderTreshold)DeletePendingOrder(3);
      if(!IfOrderDoesNotExist(2)&&!IfOrderDoesNotExist(1)&&Filter()&&OrderCounter<OpenOrderTreshold)PendingOrder(2);
      if(!IfOrderDoesNotExist(3)&&!IfOrderDoesNotExist(0)&&Filter()&&OrderCounter<OpenOrderTreshold)PendingOrder(3);
      
      if(IfOrderDoesNotExist(0)&&OrderCounter<OpenOrderTreshold)
      {
         BuyBasket=true;
         SellBasket=false;
      }
      if(IfOrderDoesNotExist(1)&&OrderCounter<OpenOrderTreshold)
      {
         SellBasket=true;
         BuyBasket=false;
      }
      
      if(!IfOrderDoesNotExist(2)&&BuyBasket&&!SellBasket)
      {
         if(ReversalContBasket)
            if(OrderCounter>=OpenOrderTreshold)PendingOrder(2);
         if(OrderCounter>=OpenOrderTreshold)MarketOrder(1);
      }
      if(!IfOrderDoesNotExist(3)&&!BuyBasket&&SellBasket)
      {
         if(ReversalContBasket)
            if(OrderCounter>=OpenOrderTreshold)PendingOrder(3);
         if(OrderCounter>=OpenOrderTreshold)MarketOrder(0);
      }
   }      
}
//*******************************************************************************************************
void MarketOrder(int Mode)
{
    double price;
    color ColorSet;
    double SL;
    double TP;
    double MarketLot=(LotSize()/ReverseOrderLotDiv);
    int SlippageOrder=Slippage*PipValue;
    
    if(Mode==1)
    {
      price = NormalizeDouble(Bid, NDigits);
      SL = price + SingleOrderSL*PipValue*Point;
      TP = price - SingleOrderTP*PipValue*Point;
      ColorSet=Red;
    }
    if(Mode==0)
    {
      price = NormalizeDouble(Ask, NDigits);
      SL = price - SingleOrderSL*PipValue*Point;
      TP = price + SingleOrderTP*PipValue*Point;
      ColorSet=Blue;
    }
    if (SingleOrderSL == 0) SL = 0;
    if (SingleOrderTP == 0) TP = 0;
    while (!IsTradeAllowed()) Sleep(100);
    int ticket = OrderSend(Symbol(), Mode, MarketLot, price, SlippageOrder, SL, TP, EAName, Magic, 0, ColorSet);
    Print("MarketLot: "+MarketLot);
    if (ticket == -1)
    {
        Print("OrderSend() error - ", ErrorDescription(GetLastError()));
    }
}
//*******************************************************************************************************
bool IfOrderDoesNotExist(int Type)
{
    for (int i=OrdersTotal()-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderType() == Type && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
        {
            return(1);
        }
    }
    else
    {
        Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
    }
}
//*******************************************************************************************************
void PendingOrder(int Mode)
{
    int expire = TimeCurrent() + 60 * 0;
    double price;
    color ColorSet;
    double PriceType;
    int CallLastOrder;
    double SL;
    double TP;
    int SlippageOrder=Slippage*PipValue;
    
    if(Mode==2)
    {
      ColorSet=Blue;
      PriceType=Ask;
      CallLastOrder=0;
    }
    if(Mode==3)
    {
      ColorSet=Red;
      PriceType=Bid;
      CallLastOrder=1;
    }
    if(Mode==3)
    {
      if(!ADVOffsetMode)price = NormalizeDouble(PriceType, NDigits) - Step()*PipValue*Point;
      if(ADVOffsetMode&&!IfOrderDoesNotExist(CallLastOrder))price = NormalizeDouble(PriceType, NDigits) - Step()*PipValue*Point;
      if(ADVOffsetMode&&IfOrderDoesNotExist(CallLastOrder))price = NormalizeDouble(GetLastOrderPrice(CallLastOrder), NDigits) - Step()*PipValue*Point;
      SL = price + SingleOrderSL*PipValue*Point;
      TP = price - SingleOrderTP*PipValue*Point;
    }
    if(Mode==2)
    {
      if(!ADVOffsetMode)price = NormalizeDouble(PriceType, NDigits) + Step()*PipValue*Point;
      if(ADVOffsetMode&&!IfOrderDoesNotExist(CallLastOrder))price = NormalizeDouble(Ask, NDigits) + Step()*PipValue*Point;
      if(ADVOffsetMode&&IfOrderDoesNotExist(CallLastOrder))price = NormalizeDouble(GetLastOrderPrice(CallLastOrder), NDigits) + Step()*PipValue*Point;
      SL = price - SingleOrderSL*PipValue*Point;
      TP = price + SingleOrderTP*PipValue*Point;
    }
    if (SingleOrderSL == 0) SL = 0;
    if (SingleOrderTP == 0) TP = 0;
    if (0 == 0) expire = 0;
    while (!IsTradeAllowed()) Sleep(100);
    int ticket = OrderSend(Symbol(), Mode, LotSize(), price, SlippageOrder, SL, TP, EAName, Magic, expire, ColorSet);
    if (ticket == -1)
    {
        Print("OrderSend() error - ", ErrorDescription(GetLastError()));
    }   
}
//*******************************************************************************************************
void CheckLastOrderType33()
{
    int orderType = -1;
    datetime lastCloseTime = 0;
    int cnt = OrdersHistoryTotal();
    for (int i=0; i < cnt; i++)
    {
        if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && lastCloseTime < OrderCloseTime())
        {
            lastCloseTime = OrderCloseTime();
            orderType = OrderType();
        }
    }
    if (orderType == OP_SELL || FirstTime33)
    {
        FirstTime33 = false;
        DeletePendingOrder(3);
        
    }
}
//*******************************************************************************************************
void DeletePendingOrder(int Mode)
{ 
    while (!IsTradeAllowed()) Sleep(100);
    for (int i=OrdersTotal()-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderType() == Mode && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
        {
            bool ret = OrderDelete(OrderTicket(), CLR_NONE);
            
            if (ret == false)
            {
                Print("OrderDelete() error - ", ErrorDescription(GetLastError()));
            }
        }
    }   
}
//*******************************************************************************************************
void CheckLastOrderType35()
{
    int orderType = -1;
    datetime lastCloseTime = 0;
    int cnt = OrdersHistoryTotal();
    for (int i=0; i < cnt; i++)
    {
        if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && lastCloseTime < OrderCloseTime())
        {
            lastCloseTime = OrderCloseTime();
            orderType = OrderType();
        }
    }
    if (orderType == OP_BUY || FirstTime35)
    {
        FirstTime35 = false;
        DeletePendingOrder(2);
        
    }
}
//*******************************************************************************************************
void AtCertainTime6()
{
    int datetime800 = TimeLocal();
    int hour0 = TimeHour(datetime800);
    int minute0 = TimeMinute(datetime800);
    int Stop_Hour = StopHour + GMTOffset;
    if ((DayOfWeek() != Today6 && hour0 == Stop_Hour && minute0 == StopMinute)&&(TimedStop == true))
    {
        Today6 = DayOfWeek();
        CloseOrder(1);
        CloseOrder(1);        
    }
}
//*******************************************************************************************************
void CloseOrder(int Mode)
{
    int orderstotal = OrdersTotal();
    int orders = 0;
    int ordticket[30][2];
    color ColorSet;
    int SlippageOrder=Slippage*PipValue;
    if(Mode==0)DeletePendingOrder(2);
    if(Mode==1)DeletePendingOrder(3);
    if(Mode==0)ColorSet=Blue;
    if(Mode==1)ColorSet=Red;
    while (!IsTradeAllowed()) Sleep(100);
    for (int i = 0; i < orderstotal; i++)
    {
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderType() != Mode || OrderSymbol() != Symbol() || OrderMagicNumber() != Magic)
        {
            continue;
        }
        ordticket[orders][0] = OrderOpenTime();
        ordticket[orders][1] = OrderTicket();
        orders++;
    }
    if (orders > 1)
    {
        ArrayResize(ordticket,orders);
        ArraySort(ordticket);
    }
    for (i = 0; i < orders; i++)
    {
        if (OrderSelect(ordticket[i][1], SELECT_BY_TICKET) == true)
        {
            bool ret = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), SlippageOrder, ColorSet);
            if (ret == false)
            Print("OrderClose() error - ", ErrorDescription(GetLastError()));
        }
    }    
}
//*******************************************************************************************************
void OnceAnHour1()
{
    int datetime800 = TimeLocal();
    int hour0 = TimeHour(datetime800);
    int minute0 = TimeMinute(datetime800);
    if (hour0 != Hour1 && minute0 == Minute1)
    {
        Hour1 = hour0;
        RandomMagicNumber();            
    }
}
//*******************************************************************************************************
void RandomMagicNumber()
{
   if((!IfOrderDoesNotExist(1))&&(!IfOrderDoesNotExist(0))&&(!IfOrderDoesNotExist(2))&&(!IfOrderDoesNotExist(3))&&(UseRandomMagic==true)&&(!IsTesting()))
   {
      MathSrand(TimeCurrent());
      double random = RandomMagicLower + (RandomMagicUpper - RandomMagicLower) * MathRand()/32768.0;
      Magic = MathRound(random);
      MagicChange = TimeToStr(TimeCurrent());
      Print("Indo Run Magic Number changed: " + Magic);
      WriteMagic();
   }
   if (UseRandomMagic == false)
   {
       RMStatus = "Inactive!";
   }
   else
   {
       RMStatus = "Active!";
   }
}
//*******************************************************************************************************
void ReadMagic()
{
   string str;
   int handle=FileOpen("IndoRun_Magic.dat", FILE_CSV | FILE_READ); //or .txt
   if((handle>0)&&(UseRandomMagic == true)&&(!IsTesting()))
   {
      str = FileReadString(handle);
      Magic = StrToInteger(str);
      FileClose(handle);
      Print("Indo Run Magic Number loaded: " + Magic);
   }
}
//*******************************************************************************************************
void WriteMagic()
{
   int handle=FileOpen("IndoRun_Magic.dat", FILE_CSV | FILE_WRITE);
   if((handle>0)&&(!IsTesting()))
   {
      FileWrite(handle, Magic);
      FileClose(handle);
      Print("Indo Run Magic Number writen to file: " + Magic);
   }
}
//*******************************************************************************************************
double LastOrderLotSize(int Type)
{
    for (int i=OrdersTotal()-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderType() == Type && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
        {
            return(OrderLots());
        }
    }
    else
    {
        Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
    }
}
//*******************************************************************************************************
double LotSize()
{
   if(KLotSize)
   {
      Lots=(MathFloor(AccountBalance()/10000))*Lot;
      if(Lots<Lot)Lots=Lot;
      AutoLot= "10K Lotsize active!";
   }
   
   if ((AutoLotSize)&&(Risk>0)&&(!KLotSize))
   {
      Lots=(AccountBalance()*Risk*MinLots)/1000;
      AutoLot = "Auto Lotsize!";
      if(DoubleLots)
      {
         Double_Lot = "Sleeping!";
         if(AsianSession)
         {
            Lots = (AccountBalance()*Risk*MinLots*2)/1000;
            Double_Lot = "Active!";
         }
         if((!AsianSession&&IfOrderDoesNotExist(0)&&LastOrderLotSize(0)>Lots)
         ||(!AsianSession&&IfOrderDoesNotExist(1)&&LastOrderLotSize(1)>Lots))
         {
            Lots = (AccountBalance()*Risk*MinLots*2)/1000;
            Double_Lot = "Override!";
         }
      }
   }
   else
   {
      if(!KLotSize)AutoLot = "Manual Lotsize!";
      if(DoubleLots)
      {
         if(AsianSession)
         {
            if(KLotSize)
            {
               Double_Lot = "Active!";
               Lots=Lots*2;
            }
            else
            {
               Double_Lot = "Active!";
               Lots = Lot * 2;
            }
         }
         else
         {
            if((IfOrderDoesNotExist(0)&&LastOrderLotSize(0)>Lots)
            ||(IfOrderDoesNotExist(1)&&LastOrderLotSize(1)>Lots))
            {
               if(KLotSize)
               {
                  Lots=Lots*2;
                  Double_Lot = "Override!";
               }
               else
               {
                  Lots = Lot * 2;
                  Double_Lot = "Override!";
               }
            }
            else
            {
               if(KLotSize)
               {
                  Double_Lot = "Sleeping!";
                  Lots=Lots;
               }
               else
               {
                  Double_Lot = "Sleeping!";
                  Lots = Lot;
               }
            }
         }
      }
      if(!DoubleLots)
      {
         if(KLotSize)
         {
            Double_Lot = "Inactive!";
            Lots=Lots;
         }
         else
         {
            Double_Lot = "Inactive!";
            Lots = Lot;
         }
      }
   }
   
   if (Lots<=MinLots)
   {
      Lots=MinLots;
   }
   
   BuyLots=Lots;
   SellLots=Lots;   

   if (Martingale==true)
   {
      int OrderCount=0;
      AutoLot= "Martingale!";
      if(IfOrderDoesNotExist(0))
      {    
         if(OrderCounter<=0)OrderCount=1;
         if(OrderCounter>=1)OrderCount=OrderCounter+1;
         BuyLots=BuyLots*LotFactor*OrderCount;
            if (BuyLots>=MartingaleMaxLot)
            {
               BuyLots=MartingaleMaxLot;
            }
         Lots=BuyLots;
      }
      if(IfOrderDoesNotExist(1)) 
      {    
         if(OrderCounter<=0)OrderCount=1;
         if(OrderCounter>=1)OrderCount=OrderCounter+1;
         SellLots=SellLots*LotFactor*OrderCount;
            if (SellLots>=MartingaleMaxLot)
            {
               SellLots=MartingaleMaxLot;
            }
          Lots=SellLots;  
      }
   }
   
   if (Lots<=MinLots)
   {
      Lots=MinLots;
   }
   return(Lots);
}   
//*******************************************************************************************************
double Profit()
{   
      double TotalLots[1000];
      TotalTradeLots  = 0;
 
      ProfitAllOrders = MathFloor(ProfitAllOrder*10*Lots);
      TrailingStops= MathFloor(TrailingStop*10*Lots);

      double n[1000];
      int s = 0;
      int m = 1;   
      for (int i=OrdersTotal()-1; i >= 0; i--)
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            if (OrderType() == (OP_BUY) && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
            { 
                 TotalLots[i] = OrderLots();
                 TotalTradeLots=TotalTradeLots+TotalLots[i];
                 if (ADVProfitMode == true)
                 {
                     m = m+i;
                     if (FixedProfitAO==false)
                     {
                     ProfitAllOrders=ProfitAllOrder*10*TotalTradeLots/m;
                     TrailingStops=TrailingStop*10*TotalTradeLots/m;
                     }
                 }
                 else
                 {
                     n[i] = 1;
                     s = s + n[i];
                     if (FixedProfitAO==false)
                     {
                     ProfitAllOrders=ProfitAllOrder*10*TotalTradeLots/s;
                     TrailingStops=TrailingStop*10*TotalTradeLots/s;
                     }
                 }
            }
         }

      double p[1000];
      int r = 0;
      int o = 1;
      for (int k=OrdersTotal()-1; k >= 0; k--)
         if (OrderSelect(k, SELECT_BY_POS, MODE_TRADES))
         {
            if (OrderType() == (OP_SELL) && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
            { 
                 TotalLots[k] = OrderLots();
                 TotalTradeLots=TotalTradeLots+TotalLots[k];
                 if (ADVProfitMode == true)
                 {
                     o = o+1;
                     if (FixedProfitAO==false)
                     {
                     ProfitAllOrders = ProfitAllOrder*10*TotalTradeLots/o;
                     TrailingStops = TrailingStop*10*TotalTradeLots/o;
                     } 
                 }
                 else
                 {
                     p[k] = 1;
                     r = r + p[k];
                     if (FixedProfitAO==false)
                     {
                     ProfitAllOrders = ProfitAllOrder*10*TotalTradeLots/r;
                     TrailingStops = TrailingStop*10*TotalTradeLots/r;
                     }
                 }
            }
         }
  if (FixedProfitAO==true)ProfitAllOrders = ProfitAllOrder;
  if (ATRProfitMode&&ATRProfitTrigger&&!ADVATRProfit)ProfitAllOrders=ATRProfit;
  if (ATRProfitMode&&ATRProfitTrigger&&ADVATRProfit)ProfitAllOrders=ProfitAllOrders/ADVATRProfitx;
  
  if (Trailing)
  {
      if (Breakeven)
      {
         if (OrderCounter>OrderTreshold)ProfitAllOrders=BE;
      }
      if (OrderTrailing)
      {
         if (OrderCounter>OrderTreshold+1)ProfitAllOrders=ProfitAllOrders-((OrderCounter-(OrderTreshold+1))*TrailingStops);
      }
  }
  
  return(ProfitAllOrders);
}
//*******************************************************************************************************
bool News() 
{
   if (AvoidNews && !IsTesting() && !IsOptimization())
   {   
       Check_News_Calendar();     
       for (int i=0; i<=NewsTotal; i++) 
       {
         if (NewsRatings[i] == 3) 
         {
           datetime BeforeNews = NewsTimes[i] - MinsUntilNextHighNews*60;
           datetime AfterNews = NewsTimes[i] + MinsSincePrevHighNews*60; 
         } 
         else if (NewsRatings[i] == 2) 
         {
           BeforeNews = NewsTimes[i] - MinsUntilNextMediumNews*60;
           AfterNews = NewsTimes[i] + MinsSincePrevMediumNews*60; 
         } 
         else if (NewsRatings[i] == 1) {
           BeforeNews = NewsTimes[i] - MinsUntilNextLowNews*60;
           AfterNews = NewsTimes[i] + MinsSincePrevLowNews*60;
         }        
         if ((TimeCurrent() >= BeforeNews && TimeCurrent() <= AfterNews)) 
         {   
           if (High_Impact && NewsRatings[i] == 3) 
           {          
             NewsF = "Avoiding High Impact News!";
             return(0);
           }          
           if (Medium_Impact && NewsRatings[i] == 2) 
           {                       
             NewsF = "Avoiding Medium Impact News!";
             return(0);
           }          
           if (Low_Impact && NewsRatings[i] == 1) 
           {          
             NewsF = "Avoiding Low Impact News!";
             return(0);
           }
         }            
         NewsF = "No News to filter!";
         return(1);
       }           
   }
   if (!AvoidNews) 
   {
     NewsF = "News Filter off!";
     return(1);
   }
   return(1);
}
//*******************************************************************************************************
bool CCI()
{   
   if (CCIFilterOn == true)
   {
      double CCICurrent = iCCI(Symbol(),0,CCIPeriod1,PRICE_TYPICAL,CCIShift1);
      double CCIPrevious = iCCI(Symbol(),0,CCIPeriod2,PRICE_TYPICAL,CCIShift2);
      CCIStatus = "CCI Current/Shift: "+DoubleToStr(CCICurrent, 2)+" / "+DoubleToStr(CCIPrevious, 2);
      
          if (CCICurrent>CCICurrentUp||CCICurrent<CCICurrentDown||CCIPrevious>CCIPreviousUp||CCIPrevious<CCIPreviousDown)
          {
               return(0);
          }
          else
          {
               return(1);
          }   
   }
   else
   {
      CCIStatus = "CCI Filter off!";
      return(1);
   }
}
//*******************************************************************************************************
bool Momentum()
{   
   if (MomentumFilterOn == true)
   {
      double MomentumCurrent = iMomentum(Symbol(),0,MomentumPeriod1,PRICE_TYPICAL,MomentumShift1);
      double MomentumPrevious = iMomentum(Symbol(),0,MomentumPeriod2,PRICE_TYPICAL,MomentumShift2);
      MomentumStatus = "Momentum Current/Shift: "+DoubleToStr(MomentumCurrent, 2)+" / "+DoubleToStr(MomentumPrevious, 2);
      
          if (MomentumCurrent>MomentumCurrentUp||MomentumCurrent<MomentumCurrentDown||MomentumPrevious>MomentumPreviousUp||MomentumPrevious<MomentumPreviousDown)
          {
               return(0);
          }
          else
          {
               return(1);
          }   
   }
   else
   {
      MomentumStatus = "Momentum Filter off!";
      return(1);
   }
}
//*******************************************************************************************************
bool RSI()
{   
   if (RSIFilterOn == true)
   {
      double RSICurrent = iRSI(Symbol(),0,RSIPeriod1,PRICE_TYPICAL,RSIShift1);
      double RSIPrevious = iRSI(Symbol(),0,RSIPeriod2,PRICE_TYPICAL,RSIShift2);
      RSIStatus = "RSI Current/Shift: "+DoubleToStr(RSICurrent, 2)+" / "+DoubleToStr(RSIPrevious, 2);
      
          if (RSICurrent>RSICurrentUp||RSICurrent<RSICurrentDown&&RSIPrevious>RSIPreviousUp||RSIPrevious<RSIPreviousDown)
          {
               return(0);
          }
          else
          {
               return(1);
          }               
   }
   else
   {
      RSIStatus = "RSI Filter off!";
      return(1);
   }
}
//*******************************************************************************************************
bool MA()
{   
   if (MAFilterOn == true)
   {
      double MACurrent = iMA(Symbol(),0,MAPeriod1,MAIShift1,MAMethod,PRICE_TYPICAL,MAShift1);
      double MAPrevious = iMA(Symbol(),0,MAPeriod2,MAIShift2,MAMethod,PRICE_TYPICAL,MAShift2); 
      MAStatus = "MA Current/Shift: "+DoubleToStr(MACurrent, 5)+" / "+DoubleToStr(MAPrevious, 5);
      
          if (MACurrent>(MACurrentUp+MAPrevious)||MACurrent<(MAPrevious-MACurrentDown)
             ||MAPrevious>(MAPreviousUp+MACurrent)||MAPrevious<(MACurrent-MAPreviousDown))
             //ToDo: change MA Filter to Crossover Fast/Slow MA
          {
               return(0);
          }
          else
          {
               return(1);
          }
   }
   else
   {
      MAStatus = "MA Filter off!"; 
      return(1);     
   }
}
//*******************************************************************************************************
bool Envelopes()
{   
   if (EnvelopesFilterOn == true)
   {
      double EnvelopesUpper = iEnvelopes(Symbol(),EnvelopesTimeFrame,EnvelopesMAPeriod1,EnvelopesMAMethod,EnvelopesMAShift1,EnvelopesAppliedPrice,EnvelopesDeviation,1,EnvelopesShift1);
      double EnvelopesLower = iEnvelopes(Symbol(),EnvelopesTimeFrame,EnvelopesMAPeriod2,EnvelopesMAMethod,EnvelopesMAShift2,EnvelopesAppliedPrice,EnvelopesDeviation,2,EnvelopesShift2); 
      EnvelopeStatus = "Envelopes Current/Shift: "+DoubleToStr(EnvelopesUpper, 5)+" / "+DoubleToStr(EnvelopesLower, 5);
      
      RefreshRates();
      if (MarketInfo(Symbol(),MODE_ASK)>EnvelopesUpper||MarketInfo(Symbol(),MODE_BID)<EnvelopesLower)
      {
          return(0);
      }
      else
      {
          return(1);
      }
   }
   else
   {
      EnvelopeStatus = "Envelopes Filter off!"; 
      return(1);     
   }
}
//*******************************************************************************************************
double GetLastOrderPrice(int Type) 
{
      for (int i =OrdersTotal() - 1 ; i >= 0; i--) 
      {
         OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == Type) 
         {
            return (OrderOpenPrice());
         }
      }
   return (0);
}
//*******************************************************************************************************
double Step()
{
   if(ATRStepOn&&!ATRPipsToStep)
   {
      if(ATRPips<ATRDnLimit2)return(PriceOffset+PriceOffset1);
      if(ATRPips>=ATRDnLimit2&&ATRPips<ATRDnLimit3)return(PriceOffset-PriceOffset2);
      if(ATRPips>=ATRDnLimit3)return(PriceOffset-PriceOffset3);
   }
   if(ATRPipsToStep&&!ATRStepOn)
   {
      return(ATRPips*(-1));
   }
   if(StepFactorOn)
      if(OrderCounter>0)return(PriceOffset*(OrderCounter/StepFactor+1));
   return(PriceOffset);
}
//*******************************************************************************************************
void TripleBasket()
{
   if ((TripleBasket||DoubleBasket)&&!UseRandomMagic)
      {
         double MultiMagic1=MagicBuffer;
         double MultiMagic2=MagicBuffer+1;
         double MultiMagic3=MagicBuffer+2;
         
         Magic=MultiMagic1;
         Basket= "1";
         BasketTrailing=1;
         Sequence();
 
         for (int i=OrdersTotal()-1; i >= 0; i--)
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
             if ((OrderType() == 0||1||2||3) && OrderSymbol() == Symbol() && (OrderMagicNumber() == MultiMagic1||MultiMagic2))
             {
               if((OrderMagicNumber()==MultiMagic1&&(IfOrderDoesNotExist(1)||IfOrderDoesNotExist(0)))||OrderMagicNumber()==MultiMagic2)
               {   
                  Magic=MultiMagic2;
                  Basket= "2";
                  BasketTrailing=2;
                  Sequence();
               }
             }
         }
         if(TripleBasket)
         {
            for (int k=OrdersTotal()-1; k >= 0; k--)
            if (OrderSelect(k, SELECT_BY_POS, MODE_TRADES))
            {
                if ((OrderType() == 0||1||2||3) && OrderSymbol() == Symbol() && (OrderMagicNumber() == MultiMagic2||MultiMagic3))
                {
                  if((OrderMagicNumber()==MultiMagic2&&IfOrderDoesNotExist(1)||IfOrderDoesNotExist(0))||OrderMagicNumber()==MultiMagic3)
                  {   
                     Magic=MultiMagic3;
                     Basket= "3";
                     BasketTrailing=3;
                     Sequence();
                  }
                }
            }
         }
      }
   else
   {
      Sequence();
   }
}

//*******************************************************************************************************
double DrawDown()
{
   double DD=AccountBalance()-AccountEquity();
   if(DD>DDBuffer)DDBuffer=DD;
   return(DDBuffer);
}
//*******************************************************************************************************
void PrintInfoToChart32()
{
    string temp = "\n"
    + "------------------------------------------------\n"
    + CCIStatus + "\n"
    + MomentumStatus + "\n"
    + RSIStatus + "\n"
    + MAStatus + "\n"
    + EnvelopeStatus +"\n"
    + "------------------------------------------------\n";
    Comment(temp);

    string text[40];
    text[1]= "Indo Run 1.5";
    text[2]= "Executed Ticks: " + Count32 + "  Spread: " + DoubleToStr(MarketInfo(Symbol(), MODE_SPREAD)/PipValue, 2);
    text[3]= "--------------------------------------------------------------";
    text[4]= "Account Name: " + AccountName();
    text[5]= "Account Leverage: " + DoubleToStr(AccountLeverage(), 0);
    text[6]= "Account Balance: " + DoubleToStr(AccountBalance(), 2);
    text[7]= "Account Equity: " + DoubleToStr(AccountEquity(), 2);
    text[8]= "Free Margin: " + DoubleToStr(AccountFreeMargin(), 2);
    text[9]= "Used Margin: " + DoubleToStr(AccountMargin(), 2);
    text[10]= "Max. Draw Down: " + DoubleToStr(DrawDown(), 2);
    text[11]= "--------------------------------------------------------------";
    text[12]= "Lot Mode: " + AutoLot ;
    text[13]= "Double Lot: " + Double_Lot ;
    text[14]= "Order Baskets: " + Basket;
    if(!DoubleBasket&&!TripleBasket)
    {
      text[15]= "Current Step: " + DoubleToStr(Step(),1);
      text[16]= "Next Lotsize: " + DoubleToStr(LotSize(), 2) ;
      text[17]= "Open Orders: " + OrderCounter ;
      text[18]= "Open Trade Lots: " + DoubleToStr(TotalTradeLots, 2) ;
      text[19]= "Profit Target in ACC Currency: " + DoubleToStr(Profit(), 2) ;
      text[20]= "Profit of open Trades: " + DoubleToStr(dblProfit, 2) ;
      text[21]= "--------------------------------------------------------------";
      text[22]= "Overall Filter Status: " + Filter ;
    }
    else
    {
      text[15]= "Current Step: " + DoubleToStr(Step(),0);
      text[16]= "Next Lotsize: Multi Basket Mode!" ;
      text[17]= "Open Orders: Multi Basket Mode!" ;
      text[18]= "Open Trade Lots: Multi Basket Mode!" ;
      text[19]= "Profit Target in ACC Currency: Multi Basket Mode!" ;
      text[20]= "Profit of open Trades: Multi Basket Mode!" ;
      text[21]= "--------------------------------------------------------------";
      text[22]= "Overall Filter Status: Multi Basket Mode!" ;
    }
    text[23]= "News Filter Status: " + NewsF ;   
    text[24]= "ATR Filter Status: " + ATR ;
    text[25]= "ATR Filter Mod: " + FilterMods ;
    text[26]= "ATR Filter Zone A: " + Zone1 ;
    text[27]= "ATR Filter Zone B: " + Zone2 ;
    text[28]= "ATR Filter Zone C: " + Zone3 ;
    text[29]= "ATR Filter Zone D: " + Zone4 ;
    text[30]= "ATR Filter Zone E: " + Zone5 ;
    text[31]= "ATR Pips (Up/Down/Current):" ;
    text[32]= "Low: " + DoubleToStr(ATRUpLimit1, 0) 
            + "/" + DoubleToStr(ATRDnLimit1, 0) 
            + "/" + DoubleToStr(ATRPips, 0) 
            + " Mid: " + DoubleToStr(ATRUpLimit2, 0) 
            + "/" + DoubleToStr(ATRDnLimit2, 0) 
            + "/" + DoubleToStr(ATRPrePips1, 0) 
            + " High: " + DoubleToStr(ATRUpLimit3, 0) 
            + "/" + DoubleToStr(ATRDnLimit3, 0) 
            + "/" + DoubleToStr(ATRPrePips2, 0);
    text[33]= "--------------------------------------------------------------";
    text[34]= "Trading Status: " + Trading ;
    text[35]= "Session Status: " + SessionFilter ;
    text[36]= "--------------------------------------------------------------";
    text[37]= "Random Magic Number: " + RMStatus ;
    text[38]= "Magic Number changed: " + MagicChange ;
    text[39]= "Magic Number: " + Magic ;    
    text[40]= "--------------------------------------------------------------";
    Count32++;
    
    int i=1;
    int k=25;
    while (i<=40)
    {
       string ChartInfo = DoubleToStr(i, 0);
       ObjectCreate(ChartInfo, OBJ_LABEL, 0, 0, 0);
       ObjectSetText(ChartInfo, text[i], 9, "Arial", Goldenrod);
       ObjectSet(ChartInfo, OBJPROP_CORNER, 1);   
       ObjectSet(ChartInfo, OBJPROP_XDISTANCE, 8);  
       ObjectSet(ChartInfo, OBJPROP_YDISTANCE, k);
       i++;
       k=k+13;
    }
    if(IndoRunLabelOn)
    {
       ObjectCreate("IndoRun", OBJ_LABEL, 0, 0, 0);
       ObjectSetText("IndoRun", "Support my efforts: expatfx@yahoo.com via paypal $$$/Cheers ;)", 24, "Arial", Goldenrod);
       ObjectSet("IndoRun", OBJPROP_CORNER, 2);   
       ObjectSet("IndoRun", OBJPROP_XDISTANCE, 10);   
       ObjectSet("IndoRun", OBJPROP_YDISTANCE, 15);
    }
}

//*******************************************************************************************************
int deinit()
{
    if (true) ObjectsDeleteAll();   
}
//*******************************************************************************************************
//*******************************************************************************************************
string Download_ForexTSD_Calendar() {

   string result = "";   
        
   datetime StartDay = iTime(NULL,PERIOD_D1,0);
   datetime OldStartDay = iTime(NULL,PERIOD_D1,1);
     
   string OldStartYear = TimeYear(OldStartDay);
   if (TimeMonth(OldStartDay)>9) string OldStartMonth = TimeMonth(OldStartDay);
   else OldStartMonth = "0" + TimeMonth(OldStartDay);
   if (TimeDay(OldStartDay)>9) string OldStart_Day = TimeDay(OldStartDay);
   else OldStart_Day = "0" + TimeDay(OldStartDay);
   
   string OldCalName = "ForexTSD_"+OldStartYear+"-"+OldStartMonth+"-"+OldStart_Day+".csv";   
   int handle = FileOpen(OldCalName,FILE_CSV|FILE_READ,';');
   if (handle > 0) { FileClose(handle); FileDelete(OldCalName); }
           
   string StartYear = TimeYear(StartDay);
   if (TimeMonth(StartDay)>9) string StartMonth = TimeMonth(StartDay);
   else StartMonth = "0" + TimeMonth(StartDay);   
   if (TimeDay(StartDay)>9) string Start_Day = TimeDay(StartDay);
   else Start_Day = "0" + TimeDay(StartDay);   
   
   string StartTime = StartYear + StartMonth + Start_Day;      
   string NewsWebAdress = TSD_Calendar_URL+StartTime+"&calendar[]="+TSD_CalendarID;
   string CalName = "ForexTSD_"+StartYear+"-"+StartMonth+"-"+Start_Day+".csv";     
   
   handle = FileOpen(CalName,FILE_CSV|FILE_READ,';');
   if (handle < 0) {
     GrabWeb(NewsWebAdress, result);      
     if (result != "") {         
       handle = FileOpen(CalName,FILE_CSV|FILE_WRITE,';');         
       if (handle > 0) {
         FileWrite(handle, result);
         FileClose(handle);
       }
     } else CalName = "";     
   } else FileClose(handle);
   return(CalName);   
}
//***********************************************************************************************
void Read_ForexTSD_Calendar(string fName) {

   string sDate[1000];          // Date   
   string sRating[1000];        // Rating
   string sActual[1000];        // Actual value
   string sForecast[1000];      // Forecast value
   string sPrevious[1000];      // Previous value
   string sTime[1000];          // Time
   string sDescription[1000];   // Description
   string sCurrency[1000];      // Currency affected     
             
   int handle = FileOpen(fName,FILE_CSV|FILE_READ,';');
   if (handle < 1) {
     Print("File not found ", GetLastError());
     return(false);
   }   
   int i=0;
   while (!FileIsEnding(handle)) {
     sDate[i]=FileReadString(handle);          
     sTime[i]=FileReadString(handle);         
     sCurrency[i]=FileReadString(handle);      
     sDescription[i]=FileReadString(handle);   
     sRating[i]=FileReadString(handle);        
     sActual[i]=FileReadString(handle);       
     sForecast[i]=FileReadString(handle);      
     sPrevious[i]=FileReadString(handle);                
   
     if ((sCurrency[i] == "USD") && (!USD)) continue;            
     if ((sCurrency[i] == "EUR") && (!EUR)) continue;            
     if ((sCurrency[i] == "GBP") && (!GBP)) continue;                      
     if ((sCurrency[i] == "JPY") && (!JPY)) continue;
     if ((sCurrency[i] == "AUD") && (!AUD)) continue;
     if ((sCurrency[i] == "CAD") && (!CAD)) continue;                     
     if ((sCurrency[i] == "CHF") && (!CHF)) continue;  
     if ((sCurrency[i] == "NZD") && (!NZD)) continue;   
     
     datetime News_Time = StrToTime(sDate[i]+" "+sTime[i])+GMTOffset*3600;      
     sTime[i] = StringSubstr(TimeToStr(News_Time), 11, 5);
     NewsTimes[i] = News_Time;
     NewsRatings[i] = StrToInteger(sRating[i]);
     
     i++;
   }
   NewsTotal = i;   
   return(0);
}
//********************************************************************************************
void Check_News_Calendar() {

   datetime cTime = iTime(NULL,PERIOD_D1,0);
   static datetime prevTime;
   
   if ((TimeCurrent() > cTime && cTime > prevTime)) {               
     string cName = Download_ForexTSD_Calendar();  
     if (cName != "") {   
       Read_ForexTSD_Calendar(cName);       
       prevTime = cTime;
     }       
   }  
   return(0);
}
//********************************************************************************************
bool bWinInetDebug = false;

int hSession_IEType;
int hSession_Direct;
int Internet_Open_Type_Preconfig = 0;
int Internet_Open_Type_Direct = 1;
int Internet_Open_Type_Proxy = 3;
int Buffer_LEN = 80;

#import "wininet.dll"
#define INTERNET_FLAG_PRAGMA_NOCACHE    0x00000100 // Forces the request to be resolved by the origin server, even if a cached copy exists on the proxy.
#define INTERNET_FLAG_NO_CACHE_WRITE    0x04000000 // Does not add the returned entity to the cache. 
#define INTERNET_FLAG_RELOAD            0x80000000 // Forces a download of the requested file, object, or directory listing from the origin server, not from the cache.

int InternetOpenA(string sAgent,	int lAccessType, string	sProxyName="",	string sProxyBypass="",	int lFlags=0);
int InternetOpenUrlA(int hInternetSession, string sUrl, string	sHeaders="", int lHeadersLength=0, int	lFlags=0, int lContext=0);
int InternetReadFile(int hFile, string	sBuffer, int lNumBytesToRead,	int& lNumberOfBytesRead[]);
int InternetCloseHandle(int hInet);
#import
//*************************************************************************************************
int hSession(bool Direct)
{
	string InternetAgent;
	if (hSession_IEType == 0) {
		InternetAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; Q312461)";
		hSession_IEType = InternetOpenA(InternetAgent, Internet_Open_Type_Preconfig, "0", "0", 0);
		hSession_Direct = InternetOpenA(InternetAgent, Internet_Open_Type_Direct, "0", "0", 0);
	}
	if (Direct) { 
		return(hSession_Direct); 
	} else {
		return(hSession_IEType); 
	}
}
//**************************************************************************************************
bool GrabWeb(string strUrl, string& strWebPage) {

	int hInternet;
	int iResult;
	int lReturn[]	= {1};
	string sBuffer	= "                                                                                                                                                                                                                                                           ";	// 255 spaces
	int bytes;
	
	hInternet = InternetOpenUrlA(hSession(FALSE), strUrl, "0", 0,INTERNET_FLAG_NO_CACHE_WRITE | 
	                             INTERNET_FLAG_PRAGMA_NOCACHE | INTERNET_FLAG_RELOAD, 0);
								
	if (bWinInetDebug) Log("hInternet: " + hInternet);   
	if (hInternet == 0) return(false);

	Print("Reading URL: " + strUrl);	   //added by MN	
	iResult = InternetReadFile(hInternet, sBuffer, Buffer_LEN, lReturn);
	
	if (bWinInetDebug) Log("iResult: " + iResult);
	if (bWinInetDebug) Log("lReturn: " + lReturn[0]);
	if (bWinInetDebug) Log("iResult: " + iResult);
	if (bWinInetDebug) Log("sBuffer: " +  sBuffer);
	if (iResult == 0) return(false);
	bytes = lReturn[0];

	strWebPage = StringSubstr(sBuffer, 0, lReturn[0]);
	
	// If there's more data then keep reading it into the buffer
	while (lReturn[0] != 0)	{
		iResult = InternetReadFile(hInternet, sBuffer, Buffer_LEN, lReturn);
		if (lReturn[0]==0) break;
		bytes = bytes + lReturn[0];
		strWebPage = strWebPage + StringSubstr(sBuffer, 0, lReturn[0]);
	}
	Print("Closing URL web connection");   //added by MN
	iResult = InternetCloseHandle(hInternet);
	if (iResult == 0) return(false);
	return(true);
}
//********************************************************************************************
void Log(string msg) {

	if (!EnableFileErrorLogging) return;		
	if (logHandle <= 0) return;		
	msg = TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS) + " " + msg;
	FileWrite(logHandle,msg);
	return(0);
}
//*******************************************************************************************************
//Change Log

//Removed: Trade Context Alarm/Email

//Changed: "Redundant" Order Functions have been merged

//BugFix: Slippage set to 4/5 Digits Support

//Changed: ATR  Filter enhanced with MathRound(IATR....)

//Added: Trade NFP Filter Option

//Added: Trade ADP NFP Filter Option

//Added: Trade Reversal/Hedging (to be enhanced...)

//Added: February Filter for Month End Trading (29 - Offset)

//Changed: PO Order / Deleting Sequence

//Added: Breakeven and Trailing Profit (Stop to negative Profit)from a Certain Draw Down Point onwards

//Added: Envelopes Filter Option

//Removed: FFCAL based News Filter

//Added: TSD News Filter (Thanks to odrisb)

//Known Bugs**********************************************************************************************************************

//Known Bug: Random Magic Number is not loaded from file while the EA is reinitilized e.g. while settings have been changed on the chart...

//Recommendation: Leave ADVOffsetMode to false as the EA can't place pending orders if the Market starts ranging and the Order might be to close to the price
//                and therefore might return an Error not placing an Order

//ToDo****************************************************************************************************************************

//ToDo: Change MA Filter to Crossover (or Option) Fast/Slow MA / Method

//ToDo: Set other Filters and try different rules

//ToDo: Continue Basket Sequence

//ToDo: Log for Account Details/Errors

//Hedging Function

//ToDo: Link Spreadon on trade opened to adjust profit

//ToDo: Trade/Filter Timeout to avoid frequent PO placing/deleting while Filter toggles

//ToDo: High/Low Filter to be implemented

//ToDo: Enhance Trade Management Options

//Todo: Check Multi Basket Mode PO Placing

//ToDo: Option to combine Basket Profits from a certain Draw Down Point onwards

//ToDo: Failsafe codings

//Remarks*************************************************************************************************************************
    //OP_BUY 0 Buy 
    //OP_SELL 1 Sell 
    //OP_BUYLIMIT 2 Pending order BUY LIMIT 
    //OP_SELLLIMIT 3 Pending order SELL LIMIT
 



