//+------------------------------------------------------------------+
//|                                    !xMeter_MultiPairs_Trader.mq4 |
//|                                        Copyright © 2007, FerruFx |
//|                                                                  |
//|                   Price Meter System™ ©GPL by Rlinac (TSD-forum) |
//|           2007/05/16 Modified by Robert Hill (IBFX mini Account) |
//|                                                                  |
//+------------------------------------------------------------------+

//---- Only for IBFX mini account
extern string    IBFX_mini_account   = "=== Is your account an IBFX mini? ===";
extern bool AccountIsIBFXmini        = false;

//---- Trade parameters
extern string    Trade_parameters    = "=== Trade parameters ===";
extern double    Lot                 =            1.0;  // Lot size
extern int       Slippage            =            2;  // Slippage

//---- Lot size management
extern string    Lot_size_management = "=== Lot size management ===";
extern bool      ManagedLotSize      =         false;  // If true, lot size based on the free margin
extern double    Risk                =          2.0;  // Risk to protect the equity
extern int       MaxLot              =         10.0;  // Maximum lot size

//---- Number of pairs to trade
extern string    Pairs_To_Trade      = "=== How many pairs to trade? ===";
extern double    PairsToTrade        =          12.0;

//---- Pairs Selection
extern string    Trade_EUR_USD       = "=== Do you want to trade EURUSD? ===";
extern bool      EUR_USD             =         true;
extern double    HighLevel_EURUSD    =          7.0;  // Level to reach for 1st condition become true
extern double    LowLevel_EURUSD     =          2.0;  // Level to not exceed for 2nd condition become true
extern double    TakeProfit_EURUSD   =         10.0;  // Profit for the order opened
extern double    StopLoss_EURUSD     =         10.0;  // StopLoss
extern int       MaxSpread_EURUSD    =         10.0;

extern string    Trade_GBP_USD       = "=== Do you want to trade GBPUSD? ===";
extern bool      GBP_USD             =         true;
extern double    HighLevel_GBPUSD    =          7.0;  // Level to reach for 1st condition become true
extern double    LowLevel_GBPUSD     =          2.0;  // Level to not exceed for 2nd condition become true
extern double    TakeProfit_GBPUSD   =         10.0;  // Profit for the order opened
extern double    StopLoss_GBPUSD     =         10.0;  // StopLoss
extern int       MaxSpread_GBPUSD    =         10.0;

extern string    Trade_AUD_USD       = "=== Do you want to trade AUDUSD? ===";
extern bool      AUD_USD             =         true;
extern double    HighLevel_AUDUSD    =          7.0;  // Level to reach for 1st condition become true
extern double    LowLevel_AUDUSD     =          2.0;  // Level to not exceed for 2nd condition become true
extern double    TakeProfit_AUDUSD   =         10.0;  // Profit for the order opened
extern double    StopLoss_AUDUSD     =         10.0;  // StopLoss
extern int       MaxSpread_AUDUSD    =         10.0;

extern string    Trade_USD_JPY       = "=== Do you want to trade USDJPY? ===";
extern bool      USD_JPY             =         true;
extern double    HighLevel_USDJPY    =          7.0;  // Level to reach for 1st condition become true
extern double    LowLevel_USDJPY     =          2.0;  // Level to not exceed for 2nd condition become true
extern double    TakeProfit_USDJPY   =         10.0;  // Profit for the order opened
extern double    StopLoss_USDJPY     =         10.0;  // StopLoss
extern int       MaxSpread_USDJPY    =         10.0;

extern string    Trade_USD_CHF       = "=== Do you want to trade USDCHF? ===";
extern bool      USD_CHF             =          true;
extern double    HighLevel_USDCHF    =          7.0;  // Level to reach for 1st condition become true
extern double    LowLevel_USDCHF     =          2.0;  // Level to not exceed for 2nd condition become true
extern double    TakeProfit_USDCHF   =         10.0;  // Profit for the order opened
extern double    StopLoss_USDCHF     =         10.0;  // StopLoss
extern int       MaxSpread_USDCHF    =         10.0;

extern string    Trade_USD_CAD       = "=== Do you want to trade USDCAD? ===";
extern bool      USD_CAD             =          true;
extern double    HighLevel_USDCAD    =          7.0;  // Level to reach for 1st condition become true
extern double    LowLevel_USDCAD     =          2.0;  // Level to not exceed for 2nd condition become true
extern double    TakeProfit_USDCAD   =         10.0;  // Profit for the order opened
extern double    StopLoss_USDCAD     =         10.0;  // StopLoss
extern int       MaxSpread_USDCAD    =         10.0;

extern string    Trade_EUR_JPY       = "=== Do you want to trade EURJPY? ===";
extern bool      EUR_JPY             =         true;
extern double    HighLevel_EURJPY    =          7.0;  // Level to reach for 1st condition become true
extern double    LowLevel_EURJPY     =          2.0;  // Level to not exceed for 2nd condition become true
extern double    TakeProfit_EURJPY   =         10.0;  // Profit for the order opened
extern double    StopLoss_EURJPY     =         10.0;  // StopLoss
extern int       MaxSpread_EURJPY    =         10.0;

extern string    Trade_EUR_GBP       = "=== Do you want to trade EURGBP? ===";
extern bool      EUR_GBP             =         true;
extern double    HighLevel_EURGBP    =          7.0;  // Level to reach for 1st condition become true
extern double    LowLevel_EURGBP     =          2.0;  // Level to not exceed for 2nd condition become true
extern double    TakeProfit_EURGBP   =         10.0;  // Profit for the order opened
extern double    StopLoss_EURGBP     =         10.0;  // StopLoss
extern int       MaxSpread_EURGBP    =         10.0;

extern string    Trade_EUR_CHF       = "=== Do you want to trade EURCHF? ===";
extern bool      EUR_CHF             =         true;
extern double    HighLevel_EURCHF    =          7.0;  // Level to reach for 1st condition become true
extern double    LowLevel_EURCHF     =          2.0;  // Level to not exceed for 2nd condition become true
extern double    TakeProfit_EURCHF   =         10.0;  // Profit for the order opened
extern double    StopLoss_EURCHF     =         10.0;  // StopLoss
extern int       MaxSpread_EURCHF    =         10.0;

extern string    Trade_EUR_AUD       = "=== Do you want to trade EURAUD? ===";
extern bool      EUR_AUD             =         true;
extern double    HighLevel_EURAUD    =          7.0;  // Level to reach for 1st condition become true
extern double    LowLevel_EURAUD     =          2.0;  // Level to not exceed for 2nd condition become true
extern double    TakeProfit_EURAUD   =         10.0;  // Profit for the order opened
extern double    StopLoss_EURAUD     =         10.0;  // StopLoss
extern int       MaxSpread_EURAUD    =         10.0;

extern string    Trade_GBP_JPY       = "=== Do you want to trade GBPJPY? ===";
extern bool      GBP_JPY             =         true;
extern double    HighLevel_GBPJPY    =          7.0;  // Level to reach for 1st condition become true
extern double    LowLevel_GBPJPY     =          2.0;  // Level to not exceed for 2nd condition become true
extern double    TakeProfit_GBPJPY   =         10.0;  // Profit for the order opened
extern double    StopLoss_GBPJPY     =         10.0;  // StopLoss
extern int       MaxSpread_GBPJPY    =         10.0;

extern string    Trade_GBP_CHF       = "=== Do you want to trade GBPCHF? ===";
extern bool      GBP_CHF             =         true;
extern double    HighLevel_GBPCHF    =          7.0;  // Level to reach for 1st condition become true
extern double    LowLevel_GBPCHF     =          2.0;  // Level to not exceed for 2nd condition become true
extern double    TakeProfit_GBPCHF   =         10.0;  // Profit for the order opened
extern double    StopLoss_GBPCHF     =         10.0;  // StopLoss
extern int       MaxSpread_GBPCHF    =         10.0;

//---- !xMeter indicator settings
#define ARRSIZE  12                     // number of pairs !!!DON'T CHANGE THIS NUMBER!!!
#define PAIRSIZE 7                      // number of currencies !!!DON'T CHANGE THIS NUMBER!!!
#define TABSIZE  10                     // scale of currency's power !!!DON'T CHANGE THIS NUMBER!!!
#define ORDER    2                      // available type of order !!!DON'T CHANGE THIS NUMBER!!!
// Currency pair
#define EURUSD 0
#define GBPUSD 1
#define AUDUSD 2
#define USDJPY 3
#define USDCHF 4
#define USDCAD 5
#define EURJPY 6
#define EURGBP 7
#define EURCHF 8
#define EURAUD 9
#define GBPJPY 10
#define GBPCHF 11
// Currency
#define USD 0
#define EUR 1
#define GBP 2
#define CHF 3
#define CAD 4
#define AUD 5
#define JPY 6

string aPair[ARRSIZE]   = {"EURUSDm","GBPUSDm","AUDUSDm","USDJPYm","USDCHFm","USDCADm",
                           "EURJPYm","EURGBPm","EURCHFm","EURAUDm","GBPJPYm","GBPCHFm"};
string aMajor[PAIRSIZE] = {"USD","EUR","GBP","CHF","CAD","AUD","JPY"};
string aOrder[ORDER]    = {"BUY ","SELL "};

double aMeter[PAIRSIZE];
double aHigh[ARRSIZE];
double aLow[ARRSIZE];
double aBid[ARRSIZE];
double aAsk[ARRSIZE];
double aRatio[ARRSIZE];
double aRange[ARRSIZE];
double aLookup[ARRSIZE];
double aStrength[ARRSIZE];
double point;
int    index;
string mySymbol;

double   sl, tp, lot;
int      cnt, ticket, total;
int      MagicAUDCAD, MagicAUDJPY, MagicAUDNZD, MagicAUDUSD, MagicCHFJPY, MagicEURAUD, MagicEURCAD;
int      MagicEURCHF, MagicEURGBP, MagicEURJPY, MagicEURUSD, MagicGBPCHF, MagicGBPJPY, MagicGBPUSD;
int      MagicNZDJPY, MagicNZDUSD, MagicUSDCHF, MagicUSDJPY, MagicUSDCAD;
bool firstStart = true;         

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   if (Symbol() == "AUDCADm" || Symbol() == "AUDCAD") { MagicAUDCAD = 426801; }
   if (Symbol() == "AUDJPYm" || Symbol() == "AUDJPY") { MagicAUDJPY = 426802; }
   if (Symbol() == "AUDNZDm" || Symbol() == "AUDNZD") { MagicAUDNZD = 426803; }
   if (Symbol() == "AUDUSDm" || Symbol() == "AUDUSD") { MagicAUDUSD = 426804; }
   if (Symbol() == "CHFJPYm" || Symbol() == "CHFJPY") { MagicCHFJPY = 426805; }
   if (Symbol() == "EURAUDm" || Symbol() == "EURAUD") { MagicEURAUD = 426806; }
   if (Symbol() == "EURCADm" || Symbol() == "EURCAD") { MagicEURCAD = 426807; }
   if (Symbol() == "EURCHFm" || Symbol() == "EURCHF") { MagicEURCHF = 426808; }
   if (Symbol() == "EURGBPm" || Symbol() == "EURGBP") { MagicEURGBP = 426809; }
   if (Symbol() == "EURJPYm" || Symbol() == "EURJPY") { MagicEURJPY = 426810; }
   if (Symbol() == "EURUSDm" || Symbol() == "EURUSD") { MagicEURUSD = 426811; }
   if (Symbol() == "GBPCHFm" || Symbol() == "GBPCHF") { MagicGBPCHF = 426812; }
   if (Symbol() == "GBPJPYm" || Symbol() == "GBPJPY") { MagicGBPJPY = 426813; }
   if (Symbol() == "GBPUSDm" || Symbol() == "GBPUSD") { MagicGBPUSD = 426814; }
   if (Symbol() == "NZDJPYm" || Symbol() == "NZDJPY") { MagicNZDJPY = 426815; }
   if (Symbol() == "NZDUSDm" || Symbol() == "NZDUSD") { MagicNZDUSD = 426816; }
   if (Symbol() == "USDCHFm" || Symbol() == "USDCHF") { MagicUSDCHF = 426817; }
   if (Symbol() == "USDJPYm" || Symbol() == "USDJPY") { MagicUSDJPY = 426818; }
   if (Symbol() == "USDCADm" || Symbol() == "USDCAD") { MagicUSDCAD = 426819; }
   //if (MagicNumber == 0) { MagicNumber = 426899; }
   
   int   err,lastError;
   initGraph();
   
   while (true)                                                             // infinite loop for main program
      {
      if (IsConnected()) start();
      if (!IsConnected()) objectBlank();
      WindowRedraw();
      Sleep(1000);                                                          // give your PC a breath
      }
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(0,OBJ_LABEL);
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()

  {
//---- !xMeter calculation
     
   for (index = 0; index < ARRSIZE; index++)    // initialize all pairs required value 
      {
      RefreshRates();   // refresh all currency's
      if (AccountIsIBFXmini) mySymbol = aPair[index];
      else mySymbol = StringSubstr(aPair[index],0,6);
      //--- point calculation
      if (mySymbol == "USDJPY" || mySymbol == "EURJPY" || mySymbol == "GBPJPY") { point = 0.01; }
      else { point = 0.0001; }
      
      //--- grade table for currency's power
      int aTable[TABSIZE]  = {0,3,10,25,40,50,60,75,90,97};
      if      (aRatio[index]*100 <= aTable[0]) aLookup[index]   = 0;
      else if (aRatio[index]*100 < aTable[1])  aLookup[index]   = 0;
      else if (aRatio[index]*100 < aTable[2])  aLookup[index]   = 1;
      else if (aRatio[index]*100 < aTable[3])  aLookup[index]   = 2;
      else if (aRatio[index]*100 < aTable[4])  aLookup[index]   = 3;
      else if (aRatio[index]*100 < aTable[5])  aLookup[index]   = 4;
      else if (aRatio[index]*100 < aTable[6])  aLookup[index]   = 5;
      else if (aRatio[index]*100 < aTable[7])  aLookup[index]   = 6;
      else if (aRatio[index]*100 < aTable[8])  aLookup[index]   = 7;
      else if (aRatio[index]*100 < aTable[9])  aLookup[index]   = 8;
      else                                     aLookup[index]   = 9;
      //---
      
      aHigh[index]     = MarketInfo(mySymbol,MODE_HIGH);                    // set a high today
      aLow[index]      = MarketInfo(mySymbol,MODE_LOW);                     // set a low today
      aBid[index]      = MarketInfo(mySymbol,MODE_BID);                     // set a last bid
      aAsk[index]      = MarketInfo(mySymbol,MODE_ASK);                     // set a last ask
      aRange[index]    = MathMax((aHigh[index]-aLow[index])/point,1);       // calculate range today
      aRatio[index]    = (aBid[index]-aLow[index])/aRange[index]/point;     // calculate pair ratio
      aStrength[index] = 9-aLookup[index];                                  // set a pair strengh
      }   //---- for

   //---- calculate all currencies meter         
   aMeter[USD] = NormalizeDouble((aLookup[USDJPY]+aLookup[USDCHF]+aLookup[USDCAD]+aStrength[EURUSD]+aStrength[GBPUSD]+aStrength[AUDUSD])/6,1);
   aMeter[EUR] = NormalizeDouble((aLookup[EURUSD]+aLookup[EURJPY]+aLookup[EURGBP]+aLookup[EURCHF]+aLookup[EURAUD])/5,1);
   aMeter[GBP] = NormalizeDouble((aLookup[GBPUSD]+aLookup[GBPJPY]+aLookup[GBPCHF]+aStrength[EURGBP])/4,1);
   aMeter[CHF] = NormalizeDouble((aStrength[USDCHF]+aStrength[EURCHF]+aStrength[GBPCHF])/3,1);
   aMeter[CAD] = NormalizeDouble((aStrength[USDCAD]),1);
   aMeter[AUD] = NormalizeDouble((aLookup[AUDUSD]+aStrength[EURAUD])/2,1);
   aMeter[JPY] = NormalizeDouble((aStrength[USDJPY]+aStrength[EURJPY]+aStrength[GBPJPY])/3,1);
        
   //---- display the results     
   objectBlank();   
   paintUSD(aMeter[USD]);
   paintEUR(aMeter[EUR]);
   paintGBP(aMeter[GBP]);
   paintCHF(aMeter[CHF]);
   paintCAD(aMeter[CAD]);
   paintAUD(aMeter[AUD]);
   paintJPY(aMeter[JPY]);
   paintLine();
   

//---- Lot size calculation
 
    if ( ManagedLotSize )
    {
     lot = (( AccountBalance() * Risk ) / 1000) / PairsToTrade;
     if ( lot > MaxLot ) { lot = MaxLot; }
    }
    else { lot = Lot; }
    
//---- GO TRADING

   double eur = aMeter[EUR];
   double usd = aMeter[USD];
   double gbp = aMeter[GBP];
   double chf = aMeter[CHF];
   double cad = aMeter[CAD];
   double aud = aMeter[AUD];
   double jpy = aMeter[JPY]; 
   
   if ( AccountIsIBFXmini == true )
   {
    if ( EUR_USD == true && eur >= HighLevel_EURUSD && usd <= LowLevel_EURUSD && eur > 0 && usd > 0) { ManageBuy("EURUSDm",lot,TakeProfit_EURUSD,StopLoss_EURUSD,Slippage,MaxSpread_EURUSD,426811,"!xMeter EURvsUSD"); }
    if ( EUR_USD == true && usd >= HighLevel_EURUSD && eur <= LowLevel_EURUSD && eur > 0 && usd > 0) { ManageSell("EURUSDm",lot,TakeProfit_EURUSD,StopLoss_EURUSD,Slippage,MaxSpread_EURUSD,426811,"!xMeter EURvsUSD"); }
      
    if ( GBP_USD == true && gbp >= HighLevel_GBPUSD && usd <= LowLevel_GBPUSD && gbp > 0 && usd > 0) { ManageBuy("GBPUSDm",lot,TakeProfit_GBPUSD,StopLoss_GBPUSD,Slippage,MaxSpread_GBPUSD,426814,"!xMeter GBPvsUSD"); }
    if ( GBP_USD == true && usd >= HighLevel_GBPUSD && gbp <= LowLevel_GBPUSD && gbp > 0 && usd > 0) { ManageSell("GBPUSDm",lot,TakeProfit_GBPUSD,StopLoss_GBPUSD,Slippage,MaxSpread_GBPUSD,426814,"!xMeter GBPvsUSD"); }
   
    if ( AUD_USD == true && aud >= HighLevel_AUDUSD && usd <= LowLevel_AUDUSD && aud > 0 && usd > 0) { ManageBuy("AUDUSDm",lot,TakeProfit_AUDUSD,StopLoss_AUDUSD,Slippage,MaxSpread_AUDUSD,426804,"!xMeter AUDvsUSD"); }
    if ( AUD_USD == true && usd >= HighLevel_AUDUSD && aud <= LowLevel_AUDUSD && aud > 0 && usd > 0) { ManageSell("AUDUSDm",lot,TakeProfit_AUDUSD,StopLoss_AUDUSD,Slippage,MaxSpread_AUDUSD,426804,"!xMeter AUDvsUSD"); }
   
    if ( USD_JPY == true && usd >= HighLevel_USDJPY && jpy <= LowLevel_USDJPY && usd > 0 && jpy > 0) { ManageBuy("USDJPYm",lot,TakeProfit_USDJPY,StopLoss_USDJPY,Slippage,MaxSpread_USDJPY,426818,"!xMeter USDvsJPY"); }
    if ( USD_JPY == true && jpy >= HighLevel_USDJPY && usd <= LowLevel_USDJPY && usd > 0 && jpy > 0) { ManageSell("USDJPYm",lot,TakeProfit_USDJPY,StopLoss_USDJPY,Slippage,MaxSpread_USDJPY,426818,"!xMeter USDvsJPY"); }
   
    if ( USD_CHF == true && usd >= HighLevel_USDCHF && chf <= LowLevel_USDCHF && usd > 0 && chf > 0) { ManageBuy("USDCHFm",lot,TakeProfit_USDCHF,StopLoss_USDCHF,Slippage,MaxSpread_USDCHF,426817,"!xMeter USDvsCHF"); }
    if ( USD_CHF == true && chf >= HighLevel_USDCHF && usd <= LowLevel_USDCHF && usd > 0 && chf > 0) { ManageSell("USDCHFm",lot,TakeProfit_USDCHF,StopLoss_USDCHF,Slippage,MaxSpread_USDCHF,426817,"!xMeter USDvsCHF"); }
   
    if ( USD_CAD == true && usd >= HighLevel_USDCAD && cad <= LowLevel_USDCAD && usd > 0 && cad > 0) { ManageBuy("USDCADm",lot,TakeProfit_USDCAD,StopLoss_USDCAD,Slippage,MaxSpread_USDCAD,426819,"!xMeter USDvsCAD"); }
    if ( USD_CAD == true && cad >= HighLevel_USDCAD && usd <= LowLevel_USDCAD && usd > 0 && cad > 0) { ManageSell("USDCADm",lot,TakeProfit_USDCAD,StopLoss_USDCAD,Slippage,MaxSpread_USDCAD,426819,"!xMeter USDvsCAD"); }
   
    if ( EUR_JPY == true && eur >= HighLevel_EURJPY && jpy <= LowLevel_EURJPY && eur > 0 && jpy > 0) { ManageBuy("EURJPYm",lot,TakeProfit_EURJPY,StopLoss_EURJPY,Slippage,MaxSpread_EURJPY,426810,"!xMeter EURvsJPY"); }
    if ( EUR_JPY == true && jpy >= HighLevel_EURJPY && eur <= LowLevel_EURJPY && eur > 0 && jpy > 0) { ManageSell("EURJPYm",lot,TakeProfit_EURJPY,StopLoss_EURJPY,Slippage,MaxSpread_EURJPY,426810,"!xMeter EURvsJPY"); }
   
    if ( EUR_GBP == true && eur >= HighLevel_EURGBP && gbp <= LowLevel_EURGBP && eur > 0 && gbp > 0) { ManageBuy("EURGBPm",lot,TakeProfit_EURGBP,StopLoss_EURGBP,Slippage,MaxSpread_EURGBP,426809,"!xMeter EURvsGBP"); }
    if ( EUR_GBP == true && gbp >= HighLevel_EURGBP && eur <= LowLevel_EURGBP && eur > 0 && gbp > 0) { ManageSell("EURGBPm",lot,TakeProfit_EURGBP,StopLoss_EURGBP,Slippage,MaxSpread_EURGBP,426809,"!xMeter EURvsGBP"); }
   
    if ( EUR_CHF == true && eur >= HighLevel_EURCHF && chf <= LowLevel_EURCHF && eur > 0 && chf > 0) { ManageBuy("EURCHFm",lot,TakeProfit_EURCHF,StopLoss_EURCHF,Slippage,MaxSpread_EURCHF,426808,"!xMeter EURvsCHF"); }
    if ( EUR_CHF == true && chf >= HighLevel_EURCHF && eur <= LowLevel_EURCHF && eur > 0 && chf > 0) { ManageSell("EURCHFm",lot,TakeProfit_EURCHF,StopLoss_EURCHF,Slippage,MaxSpread_EURCHF,426808,"!xMeter EURvsCHF"); }
   
    if ( EUR_AUD == true && eur >= HighLevel_EURAUD && aud <= LowLevel_EURAUD && eur > 0 && aud > 0) { ManageBuy("EURAUDm",lot,TakeProfit_EURAUD,StopLoss_EURAUD,Slippage,MaxSpread_EURAUD,426806,"!xMeter EURvsAUD"); }
    if ( EUR_AUD == true && aud >= HighLevel_EURAUD && eur <= LowLevel_EURAUD && eur > 0 && aud > 0) { ManageSell("EURAUDm",lot,TakeProfit_EURAUD,StopLoss_EURAUD,Slippage,MaxSpread_EURAUD,426806,"!xMeter EURvsAUD"); }
      
    if ( GBP_JPY == true && gbp >= HighLevel_GBPJPY && jpy <= LowLevel_GBPJPY && gbp > 0 && jpy > 0) { ManageBuy("GBPJPYm",lot,TakeProfit_GBPJPY,StopLoss_GBPJPY,Slippage,MaxSpread_GBPJPY,426813,"!xMeter GBPvsJPY"); }
    if ( GBP_JPY == true && jpy >= HighLevel_GBPJPY && gbp <= LowLevel_GBPJPY && gbp > 0 && jpy > 0) { ManageSell("GBPJPYm",lot,TakeProfit_GBPJPY,StopLoss_GBPJPY,Slippage,MaxSpread_GBPJPY,426813,"!xMeter GBPvsJPY"); }
   
    if ( GBP_CHF == true && gbp >= HighLevel_GBPCHF && chf <= LowLevel_GBPCHF && gbp > 0 && chf > 0) { ManageBuy("GBPCHFm",lot,TakeProfit_GBPCHF,StopLoss_GBPCHF,Slippage,MaxSpread_GBPCHF,426812,"!xMeter GBPvsCHF"); }
    if ( GBP_CHF == true && chf >= HighLevel_GBPCHF && gbp <= LowLevel_GBPCHF && gbp > 0 && chf > 0) { ManageSell("GBPCHFm",lot,TakeProfit_GBPCHF,StopLoss_GBPCHF,Slippage,MaxSpread_GBPCHF,426812,"!xMeter GBPvsCHF"); }
   }
   else
   {
    if ( EUR_USD == true && eur >= HighLevel_EURUSD && usd <= LowLevel_EURUSD && eur > 0 && usd > 0) { ManageBuy("EURUSD",lot,TakeProfit_EURUSD,StopLoss_EURUSD,Slippage,MaxSpread_EURUSD,426811,"!xMeter EURvsUSD"); }
    if ( EUR_USD == true && usd >= HighLevel_EURUSD && eur <= LowLevel_EURUSD && eur > 0 && usd > 0) { ManageSell("EURUSD",lot,TakeProfit_EURUSD,StopLoss_EURUSD,Slippage,MaxSpread_EURUSD,426811,"!xMeter EURvsUSD"); }
      
    if ( GBP_USD == true && gbp >= HighLevel_GBPUSD && usd <= LowLevel_GBPUSD && gbp > 0 && usd > 0) { ManageBuy("GBPUSD",lot,TakeProfit_GBPUSD,StopLoss_GBPUSD,Slippage,MaxSpread_GBPUSD,426814,"!xMeter GBPvsUSD"); }
    if ( GBP_USD == true && usd >= HighLevel_GBPUSD && gbp <= LowLevel_GBPUSD && gbp > 0 && usd > 0) { ManageSell("GBPUSD",lot,TakeProfit_GBPUSD,StopLoss_GBPUSD,Slippage,MaxSpread_GBPUSD,426814,"!xMeter GBPvsUSD"); }
   
    if ( AUD_USD == true && aud >= HighLevel_AUDUSD && usd <= LowLevel_AUDUSD && aud > 0 && usd > 0) { ManageBuy("AUDUSD",lot,TakeProfit_AUDUSD,StopLoss_AUDUSD,Slippage,MaxSpread_AUDUSD,426804,"!xMeter AUDvsUSD"); }
    if ( AUD_USD == true && usd >= HighLevel_AUDUSD && aud <= LowLevel_AUDUSD && aud > 0 && usd > 0) { ManageSell("AUDUSD",lot,TakeProfit_AUDUSD,StopLoss_AUDUSD,Slippage,MaxSpread_AUDUSD,426804,"!xMeter AUDvsUSD"); }
   
    if ( USD_JPY == true && usd >= HighLevel_USDJPY && jpy <= LowLevel_USDJPY && usd > 0 && jpy > 0) { ManageBuy("USDJPY",lot,TakeProfit_USDJPY,StopLoss_USDJPY,Slippage,MaxSpread_USDJPY,426818,"!xMeter USDvsJPY"); }
    if ( USD_JPY == true && jpy >= HighLevel_USDJPY && usd <= LowLevel_USDJPY && usd > 0 && jpy > 0) { ManageSell("USDJPY",lot,TakeProfit_USDJPY,StopLoss_USDJPY,Slippage,MaxSpread_USDJPY,426818,"!xMeter USDvsJPY"); }
   
    if ( USD_CHF == true && usd >= HighLevel_USDCHF && chf <= LowLevel_USDCHF && usd > 0 && chf > 0) { ManageBuy("USDCHF",lot,TakeProfit_USDCHF,StopLoss_USDCHF,Slippage,MaxSpread_USDCHF,426817,"!xMeter USDvsCHF"); }
    if ( USD_CHF == true && chf >= HighLevel_USDCHF && usd <= LowLevel_USDCHF && usd > 0 && chf > 0) { ManageSell("USDCHF",lot,TakeProfit_USDCHF,StopLoss_USDCHF,Slippage,MaxSpread_USDCHF,426817,"!xMeter USDvsCHF"); }
   
    if ( USD_CAD == true && usd >= HighLevel_USDCAD && cad <= LowLevel_USDCAD && usd > 0 && cad > 0) { ManageBuy("USDCAD",lot,TakeProfit_USDCAD,StopLoss_USDCAD,Slippage,MaxSpread_USDCAD,426819,"!xMeter USDvsCAD"); }
    if ( USD_CAD == true && cad >= HighLevel_USDCAD && usd <= LowLevel_USDCAD && usd > 0 && cad > 0) { ManageSell("USDCAD",lot,TakeProfit_USDCAD,StopLoss_USDCAD,Slippage,MaxSpread_USDCAD,426819,"!xMeter USDvsCAD"); }
   
    if ( EUR_JPY == true && eur >= HighLevel_EURJPY && jpy <= LowLevel_EURJPY && eur > 0 && jpy > 0) { ManageBuy("EURJPY",lot,TakeProfit_EURJPY,StopLoss_EURJPY,Slippage,MaxSpread_EURJPY,426810,"!xMeter EURvsJPY"); }
    if ( EUR_JPY == true && jpy >= HighLevel_EURJPY && eur <= LowLevel_EURJPY && eur > 0 && jpy > 0) { ManageSell("EURJPY",lot,TakeProfit_EURJPY,StopLoss_EURJPY,Slippage,MaxSpread_EURJPY,426810,"!xMeter EURvsJPY"); }
   
    if ( EUR_GBP == true && eur >= HighLevel_EURGBP && gbp <= LowLevel_EURGBP && eur > 0 && gbp > 0) { ManageBuy("EURGBP",lot,TakeProfit_EURGBP,StopLoss_EURGBP,Slippage,MaxSpread_EURGBP,426809,"!xMeter EURvsGBP"); }
    if ( EUR_GBP == true && gbp >= HighLevel_EURGBP && eur <= LowLevel_EURGBP && eur > 0 && gbp > 0) { ManageSell("EURGBP",lot,TakeProfit_EURGBP,StopLoss_EURGBP,Slippage,MaxSpread_EURGBP,426809,"!xMeter EURvsGBP"); }
   
    if ( EUR_CHF == true && eur >= HighLevel_EURCHF && chf <= LowLevel_EURCHF && eur > 0 && chf > 0) { ManageBuy("EURCHF",lot,TakeProfit_EURCHF,StopLoss_EURCHF,Slippage,MaxSpread_EURCHF,426808,"!xMeter EURvsCHF"); }
    if ( EUR_CHF == true && chf >= HighLevel_EURCHF && eur <= LowLevel_EURCHF && eur > 0 && chf > 0) { ManageSell("EURCHF",lot,TakeProfit_EURCHF,StopLoss_EURCHF,Slippage,MaxSpread_EURCHF,426808,"!xMeter EURvsCHF"); }
   
    if ( EUR_AUD == true && eur >= HighLevel_EURAUD && aud <= LowLevel_EURAUD && eur > 0 && aud > 0) { ManageBuy("EURAUD",lot,TakeProfit_EURAUD,StopLoss_EURAUD,Slippage,MaxSpread_EURAUD,426806,"!xMeter EURvsAUD"); }
    if ( EUR_AUD == true && aud >= HighLevel_EURAUD && eur <= LowLevel_EURAUD && eur > 0 && aud > 0) { ManageSell("EURAUD",lot,TakeProfit_EURAUD,StopLoss_EURAUD,Slippage,MaxSpread_EURAUD,426806,"!xMeter EURvsAUD"); }
      
    if ( GBP_JPY == true && gbp >= HighLevel_GBPJPY && jpy <= LowLevel_GBPJPY && gbp > 0 && jpy > 0) { ManageBuy("GBPJPY",lot,TakeProfit_GBPJPY,StopLoss_GBPJPY,Slippage,MaxSpread_GBPJPY,426813,"!xMeter GBPvsJPY"); }
    if ( GBP_JPY == true && jpy >= HighLevel_GBPJPY && gbp <= LowLevel_GBPJPY && gbp > 0 && jpy > 0) { ManageSell("GBPJPY",lot,TakeProfit_GBPJPY,StopLoss_GBPJPY,Slippage,MaxSpread_GBPJPY,426813,"!xMeter GBPvsJPY"); }
   
    if ( GBP_CHF == true && gbp >= HighLevel_GBPCHF && chf <= LowLevel_GBPCHF && gbp > 0 && chf > 0) { ManageBuy("GBPCHF",lot,TakeProfit_GBPCHF,StopLoss_GBPCHF,Slippage,MaxSpread_GBPCHF,426812,"!xMeter GBPvsCHF"); }
    if ( GBP_CHF == true && chf >= HighLevel_GBPCHF && gbp <= LowLevel_GBPCHF && gbp > 0 && chf > 0) { ManageSell("GBPCHF",lot,TakeProfit_GBPCHF,StopLoss_GBPCHF,Slippage,MaxSpread_GBPCHF,426812,"!xMeter GBPvsCHF"); }
   }

  }         //---- int start()


//---- Display the !xMeter's values

void initGraph()
  {
   ObjectsDeleteAll(0,OBJ_LABEL);

   objectCreate("usd_1",130,43);
   objectCreate("usd_2",130,35);
   objectCreate("usd_3",130,27);
   objectCreate("usd_4",130,19);
   objectCreate("usd_5",130,11);
   objectCreate("usd",132,12,"USD",7,"Arial Narrow",SkyBlue);
   objectCreate("usdp",134,21,DoubleToStr(9,1),8,"Arial Narrow",Silver);
   
   objectCreate("eur_1",110,43);
   objectCreate("eur_2",110,35);
   objectCreate("eur_3",110,27);
   objectCreate("eur_4",110,19);
   objectCreate("eur_5",110,11);
   objectCreate("eur",112,12,"EUR",7,"Arial Narrow",SkyBlue);
   objectCreate("eurp",114,21,DoubleToStr(9,1),8,"Arial Narrow",Silver);
   
   objectCreate("gbp_1",90,43);
   objectCreate("gbp_2",90,35);
   objectCreate("gbp_3",90,27);
   objectCreate("gbp_4",90,19);
   objectCreate("gbp_5",90,11);
   objectCreate("gbp",92,12,"GBP",7,"Arial Narrow",SkyBlue);
   objectCreate("gbpp",94,21,DoubleToStr(9,1),8,"Arial Narrow",Silver);
   
   objectCreate("chf_1",70,43);
   objectCreate("chf_2",70,35);
   objectCreate("chf_3",70,27);
   objectCreate("chf_4",70,19);
   objectCreate("chf_5",70,11);
   objectCreate("chf",72,12,"CHF",7,"Arial Narrow",SkyBlue);
   objectCreate("chfp",74,21,DoubleToStr(9,1),8,"Arial Narrow",Silver);

   objectCreate("cad_1",50,43);
   objectCreate("cad_2",50,35);   
   objectCreate("cad_3",50,27);
   objectCreate("cad_4",50,19);
   objectCreate("cad_5",50,11);
   objectCreate("cad",52,12,"CAD",7,"Arial Narrow",SkyBlue);
   objectCreate("cadp",54,21,DoubleToStr(9,1),8,"Arial Narrow",Silver);
   
   objectCreate("aud_1",30,43);
   objectCreate("aud_2",30,35);
   objectCreate("aud_3",30,27);
   objectCreate("aud_4",30,19);
   objectCreate("aud_5",30,11);
   objectCreate("aud",32,12,"AUD",7,"Arial Narrow",SkyBlue);
   objectCreate("audp",34,21,DoubleToStr(9,1),8,"Arial Narrow",Silver);

   objectCreate("jpy_1",10,43);
   objectCreate("jpy_2",10,35);
   objectCreate("jpy_3",10,27);
   objectCreate("jpy_4",10,19);
   objectCreate("jpy_5",10,11);
   objectCreate("jpy",13,12,"JPY",7,"Arial Narrow",SkyBlue);
   objectCreate("jpyp",14,21,DoubleToStr(9,1),8,"Arial Narrow",Silver);
   
   objectCreate("line",10,6,"-----------------------------------",10,"Arial",DimGray);  
   objectCreate("line1",10,27,"-----------------------------------",10,"Arial",DimGray);  
   objectCreate("line2",10,69,"-----------------------------------",10,"Arial",DimGray);
   objectCreate("sign",11,1,"»»» Price Meter System™ ©GPL «««",8,"Arial Narrow",DimGray);
   WindowRedraw();
  }
//+------------------------------------------------------------------+

void ManageBuy(string symb,double lt,double TP,double SL,int slp,int spd,int magic,string com)
   {
    double ask   =MarketInfo(symb,MODE_ASK);
    double point =MarketInfo(symb,MODE_POINT);
    double sprd  =MarketInfo(symb,MODE_SPREAD);
    if( sprd <= spd )
    {
     total = OrdersTotal();
     int j, orders;
     for(j=0;j<total;j++)
     {
      OrderSelect(j, SELECT_BY_POS, MODE_TRADES);
      if(OrderMagicNumber() == magic) orders++; //---- an order is opened with
     }                                          //---- same symbol, same magic number
   
     if ( orders < 1 )    //---- we can go trading
     {
      if (TP==0) { tp=0; }
      else { tp=ask+TP*point; }
      if (SL==0) { sl=0; }
      else { sl=ask-SL*point; }
      //Print("ticket=OrderSend(",symb,",",OP_BUY,",",lt,",",ask,",",slp,",",sl,",",tp,",",com,",",magic,",",0,",",Lime);
      ticket=OrderSend(symb,OP_BUY,lt,ask,slp,sl,tp,com,magic,0,Lime);
      if( ticket > 0 )
      {
       if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
       {
        Print("BUY order opened : ",OrderOpenPrice());
       }
      }
      else
      {
       Print("Error opening BUY order : ",GetLastError());
      }
     }    //---- if ( orders < 1 )
    }    //---- if( sprd <= spd )
   }     //---- void
   
void ManageSell(string symb,double lt,double TP,double SL,int slp,int spd,int magic,string com)
   {
    double bid   =MarketInfo(symb,MODE_BID);
    double point =MarketInfo(symb,MODE_POINT);
    double sprd  =MarketInfo(symb,MODE_SPREAD);
    if( sprd <= spd )
    {
     total = OrdersTotal();
     int j, orders;
     for(j=0;j<total;j++)
     {
      OrderSelect(j, SELECT_BY_POS, MODE_TRADES);
      if(OrderMagicNumber() == magic) orders++; //---- an order is opened with
     }                                          //---- same symbol, same magic number
   
     if ( orders < 1 )    //---- we can go trading
     {
      if (TP==0) { tp=0; }
      else { tp=bid-TP*point; }
      if (SL==0) { sl=0; }
      else { sl=bid+SL*point; }
      //Print("ticket=OrderSend(",symb,",",OP_SELL,",",lt,",",bid,",",slp,",",sl,",",tp,",",com,",",magic,",",0,",",Red);
      ticket=OrderSend(symb,OP_SELL,lt,bid,slp,sl,tp,com,magic,0,Red);
      if( ticket > 0 )
      {
       if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
       {
        Print("SELL order opened : ",OrderOpenPrice());
       }
      }
      else
      {
       Print("Error opening SELL order : ",GetLastError()); 
      }
     }    //---- if ( orders < 1 )
    }    //---- if( sprd <= spd )
   }     //---- void

void objectCreate(string name,int x,int y,string text="-",int size=42,
                  string font="Arial",color colour=CLR_NONE)
  {
   ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_CORNER,3);
   ObjectSet(name,OBJPROP_COLOR,colour);
   ObjectSet(name,OBJPROP_XDISTANCE,x);
   ObjectSet(name,OBJPROP_YDISTANCE,y);
   ObjectSetText(name,text,size,font,colour);
  }

void objectBlank()
  {
   ObjectSet("usd_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("usd_2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("usd_3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("usd_4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("usd_5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("usd",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("usdp",OBJPROP_COLOR,CLR_NONE);

   ObjectSet("eur_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("eur_2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("eur_3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("eur_4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("eur_5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("eur",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("eurp",OBJPROP_COLOR,CLR_NONE);

   ObjectSet("gbp_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("gbp_2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("gbp_3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("gbp_4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("gbp_5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("gbp",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("gbpp",OBJPROP_COLOR,CLR_NONE);

   ObjectSet("chf_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("chf_2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("chf_3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("chf_4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("chf_5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("chf",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("chfp",OBJPROP_COLOR,CLR_NONE);

   ObjectSet("cad_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("cad_2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("cad_3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("cad_4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("cad_5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("cad",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("cadp",OBJPROP_COLOR,CLR_NONE);

   ObjectSet("aud_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("aud_2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("aud_3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("aud_4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("aud_5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("aud",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("audp",OBJPROP_COLOR,CLR_NONE);

   ObjectSet("jpy_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("jpy_2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("jpy_3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("jpy_4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("jpy_5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("jpy",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("jpyp",OBJPROP_COLOR,CLR_NONE);
   
   ObjectSet("line1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("line2",OBJPROP_COLOR,CLR_NONE); 
  }
  
void paintUSD(double value)
  {
   if (value > 0) ObjectSet("usd_5",OBJPROP_COLOR,Red);
   if (value > 2) ObjectSet("usd_4",OBJPROP_COLOR,Orange);
   if (value > 4) ObjectSet("usd_3",OBJPROP_COLOR,Gold);   
   if (value > 6) ObjectSet("usd_2",OBJPROP_COLOR,YellowGreen);
   if (value > 7) ObjectSet("usd_1",OBJPROP_COLOR,Lime);
   ObjectSet("usd",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("usdp",DoubleToStr(value,1),8,"Arial Narrow",Silver);
  }

void paintEUR(double value)
  {
   if (value > 0) ObjectSet("eur_5",OBJPROP_COLOR,Red);
   if (value > 2) ObjectSet("eur_4",OBJPROP_COLOR,Orange);
   if (value > 4) ObjectSet("eur_3",OBJPROP_COLOR,Gold);   
   if (value > 6) ObjectSet("eur_2",OBJPROP_COLOR,YellowGreen);
   if (value > 7) ObjectSet("eur_1",OBJPROP_COLOR,Lime);
   ObjectSet("eur",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("eurp",DoubleToStr(value,1),8,"Arial Narrow",Silver);
  }

void paintGBP(double value)
  {
   if (value > 0) ObjectSet("gbp_5",OBJPROP_COLOR,Red);
   if (value > 2) ObjectSet("gbp_4",OBJPROP_COLOR,Orange);
   if (value > 4) ObjectSet("gbp_3",OBJPROP_COLOR,Gold);   
   if (value > 6) ObjectSet("gbp_2",OBJPROP_COLOR,YellowGreen);
   if (value > 7) ObjectSet("gbp_1",OBJPROP_COLOR,Lime);
   ObjectSet("gbp",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("gbpp",DoubleToStr(value,1),8,"Arial Narrow",Silver);
  }

void paintCHF(double value)
  {
   if (value > 0) ObjectSet("chf_5",OBJPROP_COLOR,Red);
   if (value > 2) ObjectSet("chf_4",OBJPROP_COLOR,Orange);
   if (value > 4) ObjectSet("chf_3",OBJPROP_COLOR,Gold);   
   if (value > 6) ObjectSet("chf_2",OBJPROP_COLOR,YellowGreen);
   if (value > 7) ObjectSet("chf_1",OBJPROP_COLOR,Lime);
   ObjectSet("chf",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("chfp",DoubleToStr(value,1),8,"Arial Narrow",Silver);
  }

void paintCAD(double value)
  {
   if (value > 0) ObjectSet("cad_5",OBJPROP_COLOR,Red);
   if (value > 2) ObjectSet("cad_4",OBJPROP_COLOR,Orange);
   if (value > 4) ObjectSet("cad_3",OBJPROP_COLOR,Gold);   
   if (value > 6) ObjectSet("cad_2",OBJPROP_COLOR,YellowGreen);
   if (value > 7) ObjectSet("cad_1",OBJPROP_COLOR,Lime);
   ObjectSet("cad",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("cadp",DoubleToStr(value,1),8,"Arial Narrow",Silver);
  }

void paintAUD(double value)
  {
   if (value > 0) ObjectSet("aud_5",OBJPROP_COLOR,Red);
   if (value > 2) ObjectSet("aud_4",OBJPROP_COLOR,Orange);
   if (value > 4) ObjectSet("aud_3",OBJPROP_COLOR,Gold);   
   if (value > 6) ObjectSet("aud_2",OBJPROP_COLOR,YellowGreen);
   if (value > 7) ObjectSet("aud_1",OBJPROP_COLOR,Lime);
   ObjectSet("aud",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("audp",DoubleToStr(value,1),8,"Arial Narrow",Silver);
  }

void paintJPY(double value)
  {
   if (value > 0) ObjectSet("jpy_5",OBJPROP_COLOR,Red);
   if (value > 2) ObjectSet("jpy_4",OBJPROP_COLOR,Orange);
   if (value > 4) ObjectSet("jpy_3",OBJPROP_COLOR,Gold);   
   if (value > 6) ObjectSet("jpy_2",OBJPROP_COLOR,YellowGreen);
   if (value > 7) ObjectSet("jpy_1",OBJPROP_COLOR,Lime);
   ObjectSet("jpy",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("jpyp",DoubleToStr(value,1),8,"Arial Narrow",Silver);
  }
  
void paintLine()
  {
   ObjectSet("line1",OBJPROP_COLOR,DimGray);
   ObjectSet("line2",OBJPROP_COLOR,DimGray);
  }
 

