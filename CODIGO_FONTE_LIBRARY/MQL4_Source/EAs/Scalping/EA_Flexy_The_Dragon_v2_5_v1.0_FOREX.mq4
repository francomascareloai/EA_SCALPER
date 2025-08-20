// ------------------------------------------------------------------------------------------------
// Original by http://www.lifesdream.org
// Modified by MaPi, fxtrue, SmoothNoodle, livenFX, ksen, giampi9800, romiek, xxl205, TeChaoLiang, arcenciel, Farzad666, DanielChan
//
// High risk grid trading EA, use it on demo only until you know how to handle and are willing to accept the involved risks!
// Original idea and code: https://www.forexfactory.com/thread/1070898-free-grid-ea-ikarus-from-zero-to
// ------------------------------------------------------------------------------------------------

//#define DEMO 1                    // to make it a demo account only version, uncomment this line
//#define DEBUG 1                   // to switch off debug info off, uncomment this line

#define max_open_positions 100      // maximum number of open positions
#define max_auto_open_positions 90  // maximum number of automatic open positions (10 positions for hedge trading)
#define EMPTY_VALUE 2147483647

#include <stdlib.mqh>
#include <stderror.mqh>

#define versionNo "2.5"
#define versionBMI "Flexy The Dragon v" + versionNo
#define versionOld "based on Super Money and Ikarus Grid EAs"

#property version versionNo
#property strict

#property copyright     "Flexy The Dragon EA"
#property description   "based on Super Money and Ikarus Grid EAs"

string key = "Flexy The Dragon";
string key_hedging = "Reverse";

enum BB_options {ASK_BID, HIGH_LOW};
enum STO_options {LOW_HIGH, CLOSE_CLOSE};
enum weekdays {SUN, MON, TUE, WED, THU, FRI, SAT};

enum ENUM_INDICATOR_TYPE {
    Empty_Indicator = 1,
    Value_Indicator,
    Price_Indicator,
    Cross_Indicator};

// ------------------------------------------------------------------------------------------------
// EXTERN VARS
// ------------------------------------------------------------------------------------------------

// ------------------------------------------------------------------------------------------------
int user_slippage = 2;

extern int magic = 0;                              // Magic Number (0 = automatic)
sinput string gap00; // .
input bool show_profit = true;                     // Show Profit/Loss Info?
input bool show_forecast = true;                   // Show Trading Info?
input bool show_settings = false;                  // Show Settings Info?
input bool show_indicators = false;                // Show Indicators Info?
sinput string show_info;                           // (set all to "false" for fastest backtest)
sinput string gap10; // .
sinput string Order_Settings;                      // ======>  O R D E R   S E T T I N G S  <======
sinput string gap11; // .
extern double min_lots          = 0.01;            // Base Lot Size (for first order)
extern int progression          = 2;               // Lot Progression (0=fixed 1=sum 2=marti 3=fibo)
extern double lot_multiplicator = 1.5;             // Lot Multiplier (only for martingale)
input bool use_autolot          = false;           // Use Auto Lot Size? (calculated by auto lot Balance)
extern int AutoLotBalance       = 5000;            // Auto Lot Balance (multiplied by base lot size)
sinput string gap13; // .
extern int max_spread           = 100;             // Max. Spread (to open orders, in pts)
sinput string gap14; // .
sinput string Grid_Settings;                       // ======>  G R I D   S E T T I N G S  <======
sinput string gap20; // .
extern int max_positions       = 10;               // Max. Positions (per grid cycle)
extern int gs_progression      = 2;                // Grid Progression (0=fixed 1=sum 2=marti 3=fibo)
extern double gs_multiplicator = 1.0;              // Grid Multiplier (only for 2=martingale)
sinput string gap21; // .
extern double grid_size        = 40.0;             // Fixed Grid Step (in pips)
extern double take_profit      = 20.0;             // Fixed Take Profit (in pips)
sinput string gap22; // .
extern bool Use_ATR            = false;            // Use Dynamic Grid? (based on ATR)
extern ENUM_TIMEFRAMES ATR_tf  = PERIOD_CURRENT;   // ATR Time Frame
extern int ATR_Period          = 20;               // ATR Period
extern double ATR_Multiplier   = 2.0;              // Dynamic Grid Step (ATR ratio)
extern double TP_Multiplier    = 1.0;              // Dynamic Take Proft (ATR ratio)
sinput string gap23; // .
sinput string Risk_Settings;                       // ======>  R I S K   S E T T I N G S  <======
sinput string gap30; // .
extern double profit_lock        = 1.0;            // #1 Profit Lock / Trail Stop
sinput string profit_info;                         // (must be used!, locks in profit, 1.0 = 100%)
extern int profit_chasing        = 0;              // #2 Profit Chasing
sinput string profit_chasing2;                     // (number of orders to chase maximum profit)
sinput string gap31; // .
extern double equity_warning     = 0.7;            // #3 Equity Warning / Yoga Mode 
sinput string equity_info;                         // (stop open orders on low equity, 0.7 = 70%)
extern double cycleEquityRisk    = 0.0;            // #4 Cycle Risk / Stop Loss
sinput string cycleEquityRisk_info;                // (close orders of one grid cycle, 0.01 = 1%)
extern double account_risk       = 0.9;            // #5 Shut Down / Account Risk
sinput string account_risk2;                       // (close all orders and turn off, 0.9 = 90%)
sinput string gap32; // .
sinput string Recovery_Settings;                   // ======>  R E C O V E R Y   S E T T I N G S  <======
sinput string gap40; // .
extern int partial_closing       = 0;              // 1# Partial Closing
sinput string partial_closing_info;                // (number of orders to start closing last + 1st trade of grid)
extern double reduce_tp          = 0.0;            // 2# Profit Reducing
sinput string reduce_tp_info;                      // (reduces take profit per grid order in pips, min. 1pip)
extern bool hedging_active       = false;          // 3# Cycle Hedging
sinput string hedging_active_info;                 // (hedge entire grid cycle, if maximum positions are reached)
sinput string gap41; // .
sinput string Indicators_Settings;                 // ======>  B A S I C   I N D I C A T O R S  <======
sinput string gap50; // .
extern bool Conjunct_Idx         = true;           // Combine Signals (use all indicators together)
extern bool both_cycle           = false;          // Open Both Cycles (buy+sell in both directions)
extern bool strict_signals       = false;          // Strict Signals (open next grid orders only on signal)
extern bool one_candle_limit     = true;           // One Candle Limit (only one grid order per candle)
sinput string gap51; // .
sinput string Bollinger_Bands;                     // ************  Bollinger Bands (BB)  ************
extern bool Use_BB               = false;          // Use BB signals?
extern bool BB_invert            = false;          // Invert trigger (follow trend)?
extern ENUM_TIMEFRAMES BB_tf     = PERIOD_CURRENT; // Time frame
extern int BB_Period     = 20;                     // Period
extern double BB_Dev     = 2.0;                    // Deviation (set to "0.01" for moving average)
extern BB_options BB_Mod = ASK_BID;                // Price method (ask/bid, high/low)
extern int BB_Shift      = 0;                      // Shift
sinput string gap52; // .
sinput string Stochastic_Oscillator;               // ************  Stochastic Oscillator (STO)  ************
extern bool Use_Stoch    = false;                  // Use STO signals?
extern bool STO_invert   = false;                  // Invert trigger (follow trend)?
extern ENUM_TIMEFRAMES Stoch_tf = PERIOD_CURRENT;  // Time frame
extern int Stoch_K       = 14;                     // Period %K line
extern int Stoch_D       = 1;                      // Period %D line
extern int Stoch_Slowing = 3;                      // Slowing value
extern ENUM_MA_METHOD Stoch_Method = MODE_SMA;     // MA method
extern ENUM_STO_PRICE Stoch_Price = STO_LOWHIGH;   // Price method (low/high, close/close)
extern double Stoch_Upper = 80;                    // Upper level
extern double Stoch_Lower = 20;                    // Lower level
extern int Stoch_Shift    = 0;                     // Shift
sinput string gap53; // .
sinput string Relative_Strength_Index;             // ************  Relative Strength Index (RSI)  ************
extern bool Use_RSI      = false;                  // Use RSI signals?
extern bool RSI_invert   = false;                  // Invert trigger (follow trend)?
extern ENUM_TIMEFRAMES RSI_tf = PERIOD_CURRENT;    // Time trame
extern int RSI_Period    = 14;                     // Period
extern double RSI_Upper  = 80;                     // Upper level
extern double RSI_Lower  = 20;                     // Lower level
extern int RSI_Shift     = 0;                      // Shift
sinput string gap54; // .
sinput string Commodity_Channel_Index;             // ************  Commodity Channel Index (CCI)  ************
extern bool Use_CCI      = false;                  // Use CCI signals?
extern bool CCI_invert   = false;                  // Invert trigger (follow trend)?
extern ENUM_TIMEFRAMES CCI_tf = PERIOD_CURRENT;    // Time frame
extern int CCI_Period    = 14;                     // Period
extern double CCI_Upper  = 200;                    // Upper level
extern double CCI_Lower  = -200;                   // Lower level
extern int CCI_Shift     = 0;                      // Shift
sinput string gap55; // .
sinput string Custom_Indicators;                        // ======>  C U S T O M   I N D I C A T O R S  <======
sinput string gap60; // .
sinput string C1;                                       // ************  Custom Indicator 1  ************
extern bool Use_C1           = false;                   // Use Custom Indicator?
input string C1_Name         = "";                      // Indicator Name (in indicator folder)
input ENUM_INDICATOR_TYPE C1_Type = Empty_Indicator;    // Indicator Type (see below info) 
input int C1_BuyBuffer       = 0;                       // Buy buffer number (usually "0")
input int C1_SellBuffer      = 1;                       // Sell buffer number (usually "1")
input double C1_BuyValue     = 1.0;                     // Buy value* (only for value type)
input double C1_SellValue    = 1.0;                     // Sell value* (only for value type)
extern bool C1_Invert        = true;                    // Follow signal? (inverts trigger)
extern bool C1_Wait          = true;                    // Wait for closed bar? (use previous bar)
extern bool C1_Exit          = false;                   // Exit other open orders? (experimental)
sinput string gap61; // .
sinput string C2;                                       // ************  Custom Indicator 2  ************
extern bool Use_C2           = false;                   // Use Custom Indicator?
input string C2_Name         = "";                      // Indicator Name (in indicator folder)
input ENUM_INDICATOR_TYPE C2_Type = Empty_Indicator;    // Indicator Type (see below info) 
input int C2_BuyBuffer       = 0;                       // Buy buffer number (usually "0")
input int C2_SellBuffer      = 1;                       // Sell buffer number (usually "1")
input double C2_BuyValue     = 1.0;                     // Buy value* (only for value type)
input double C2_SellValue    = 1.0;                     // Sell value* (only for value type)
extern bool C2_Invert        = true;                    // Follow signal? (inverts trigger)
extern bool C2_Wait          = true;                    // Wait for closed bar? (use previous bar)
extern bool C2_Exit          = false;                   // Exit other open orders? (experimental)
sinput string gap62; // .
sinput string C3;                                       // ************  Custom Indicator 3  ************
extern bool Use_C3           = false;                   // Use Custom Indicator?
input string C3_Name         = "";                      // Indicator Name (in indicator folder)
input ENUM_INDICATOR_TYPE C3_Type = Empty_Indicator;    // Indicator Type (see below info) 
input int C3_BuyBuffer       = 0;                       // Buy buffer number (usually "0")
input int C3_SellBuffer      = 1;                       // Sell buffer number (usually "1")
input double C3_BuyValue     = 1.0;                     // Buy value* (only for value type)
input double C3_SellValue    = 1.0;                     // Sell value* (only for value type)
extern bool C3_Invert        = true;                    // Follow signal? (inverts trigger)
extern bool C3_Wait          = true;                    // Wait for closed bar? (use previous bar)
extern bool C3_Exit          = false;                   // Exit other open orders? (experimental)
sinput string Type_Info0; // .
sinput string Type_Info1;                               // 1. Type in indicator name "folder/ExampleRSI" without ".ex4" 
sinput string Type_Info2;                               // 2. Find and type in the number of the buffer from the colors 
sinput string Type_Info3;                               //    tab of the indi or by pressing CTRL+D to show the values
sinput string Type_Info4;                               // 3. Select the Indicator Type:
sinput string Type_Info5;                               // a) Empty Type: triggers signal if [buffer] is "not empty"
sinput string Type_Info6;                               // b) Value Type: if [buffer] is </> than [buy/sell value]*
sinput string Type_Info7;                               // c) Price Type: if [price] is </> than [buffer]
sinput string Type_Info8;                               // d) Cross Type: if [price] crosses [buffer] up/down
sinput string gap63; // .
sinput string Time_Settings;                       // ======>  W O R K I N G   T I M E S  <======
sinput string gap70; // .
extern bool Restricted_Working_Time = false;       // Use Working Times?
extern weekdays StartDay = MON;                    // Weekday Start (select)
extern weekdays StopDay = FRI;                     // Weekday Stop (select)
extern int StartHour = 8;                          // Hour Start (0-24)
extern int StartMin = 0;                           // Minute Start (0-59)
extern int StartSec = 0;                           // Second Start (0-59)
extern int StopHour = 16;                          // Hour Stop (0-24)
extern int StopMin  = 0;                           // Minute Stop (0-59)
extern int StopSec  = 0;                           // Second Stop (0-59)
sinput string gap71; // .
sinput string Visual_Settings;                     // ======>  V I S U A L   S E T T I N G S  <======
sinput string gap80; // .
sinput string buy_sell_lines;                      // ************  Display Next Buy/Sell Lines  ************
extern color Color_NXT_Buy    = clrDodgerBlue;     // Next buy line color
extern color Color_NXT_Sell   = clrCrimson;        // Next sell line color
extern int Style_NX           = 3;                 // Next line type (0,1,2,3,4)
extern int Width_NX           = 0;                 // Next line width (0,1,2,3,4)
sinput string gap81; // .
sinput string delimeter_01;                        // ************  Display Take Profit Lines  ************
extern color Color_TP_Buy     = clrDodgerBlue;     // Buy TP line color
extern color Color_TP_Sell    = clrCrimson;        // Sell TP line color
extern int Style_TP           = 0;                 // TP lines type (0,1,2,3,4)
extern int Width_TP           = 2;                 // TP lines width (0,1,2,3,4)
sinput string gap82; // .
sinput string profit_lock_lines;                   // ************  Display Profit Lock Lines  ************
extern bool displayPLL          = true;            // Display profit lock lines?
extern color Color_PL_Buy       = clrGold;         // Lock line buy color
extern color Color_PL_Sell      = clrGold;         // Lock line sell color
extern int Style_PL             = 1;               // Lock line type (0,1,2,3,4)
extern int Width_PL             = 0;               // Lock line width (0,1,2,3,4)
sinput string gap83; // .
sinput string closed_profits;                      // ************  Display Profit Labels  ************
input bool display_CP         = true;              // Display profit labels?
input string Font_Fam_CP = "Roboto Condensed Bold";// Font family (install on PC)
input int Font_Size_CP        = 10;                // Font size
input int move_CP             = -100;              // Position (in pts, from closed price)
input color Color_CP_Pos      = clrSpringGreen;    // Positive color
input color Color_CP_Neg      = clrOrangeRed;      // Negative color
sinput string gap84; // .
sinput string breakeven_boxes;                     // ************  Display Breakeven Prices  ************
extern bool displayBE         = false;             // Display single BE price box?
extern color Color_BE         = clrOrchid;         // BE price box color
extern bool displayBES        = true;              // Display separate BE price boxes? 
extern color Color_BE_Buy     = clrDodgerBlue;     // BE price box buy color
extern color Color_BE_Sell    = clrCrimson;        // BE price box sell color
sinput string gap85; // .
extern int loginfo = 1;                            // Send Log Information


// ------------------------------------------------------------------------------------------------
// GLOBAL VARS
// ------------------------------------------------------------------------------------------------
// Ticket

// ONE CANDLE LIMIT
int lastCandleIndex =  0;

// #007: be able to deal with variable number of open positions

bool buy_chased = false, sell_chased = false;
int buy_tickets[max_open_positions];
int sell_tickets[max_open_positions];
// Lots
double buy_lots[max_open_positions];
double sell_lots[max_open_positions];
// Current Profit
double buy_profit[max_open_positions];
double sell_profit[max_open_positions];
// Open Price
double buy_price[max_open_positions];
double sell_price[max_open_positions];

// hedge correction orders
int hedge_buy_tickets[max_open_positions];
int hedge_sell_tickets[max_open_positions];

double hedge_buy_lots[max_open_positions];
double hedge_sell_lots[max_open_positions];

double hedge_buy_profit[max_open_positions];
double hedge_sell_profit[max_open_positions];

double hedge_buy_price[max_open_positions];
double hedge_sell_price[max_open_positions];

// Hedging indicators
int hedge_magic = 0;
bool is_sell_hedging_active = false, is_buy_hedging_active = false;
bool is_sell_hedging_order_active = false, is_buy_hedging_order_active = false;

// Number of orders
int buys = 0, sells = 0, hedge_buys = 0, hedge_sells = 0;

// #020: show line, where the next line_buy /line_sell would be, if it would be opened
// value of lines:
double line_buy = 0, line_sell = 0, line_buy_tmp = 0, line_sell_tmp = 0, line_buy_next = 0;
double line_sell_next = 0, line_buy_ts = 0, line_sell_ts = 0, line_margincall = 0;

// profits:
double total_buy_profit = 0, total_sell_profit = 0, total_buy_swap = 0, total_sell_swap = 0;
double total_hedge_buy_profit = 0, total_hedge_sell_profit = 0, total_hedge_buy_swap = 0, total_hedge_sell_swap = 0;
double buy_max_profit = 0, buy_close_profit = 0;
double buy_max_hedge_profit = 0, buy_close_hedge_profit = 0;
double sell_max_profit = 0, sell_close_profit = 0;
double sell_max_hedge_profit = 0, sell_close_hedge_profit = 0;
double total_buy_lots = 0, total_sell_lots = 0;
double total_hedge_buy_lots = 0, total_hedge_sell_lots = 0;
double relativeVolume = 0;
double buy_close_profit_trail_orders = 0, sell_close_profit_trail_orders = 0;
bool buy_max_order_lot_open = false, sell_max_order_lot_open = false;

double dLots = 0; // разность объемов ордеров Buy и Sell
double dlots = 0; //убираем погрешность в расчете разности объема ордеров

// Colors:
//color c=Black;
int colInPlus  = clrSpringGreen;
int colInMinus = clrOrangeRed;
int colNeutral = clrSlateGray;
int colBlue    = clrBlue;
int colBuy     = C'34,81,221';
int colSell    = C'234,21,64';
int colCodeGreen  = C'74,85,96';
int colCodeYellow = clrGold;
int colCodeRed    = clrRed;
int colPauseButtonPassive = C'74,85,96';

int colFontLight  = clrWhite;
int colFontDark   = clrSlateGray;  
int colFontGray   = clrSlateGray;
int colFontWhite  = clrWhite;
int colFontYellow = clrYellow;

int panelCol = colNeutral;         // fore color of neutral panel text
int instrumentCol = colNeutral;    // panel color that changes depending on its value

// OrderReliable:
int slippage = 0;                  // is fix; depending on chart: 2 or 20
int retry_attempts = 10;
double sleep_time = 4.0;           // in seconds
int sleep_maximum = 25;            // in seconds
string OrderReliable_Fname = "OrderReliable fname unset";
static int _OR_err = 0;
string OrderReliableVersion = "V1_1_1";

// #023: implement account state by 3 colored button
enum ACCOUNT_STATE {as_green, as_yellow, as_red};
int accountState = as_green;
// #025: use equity percentage instead of unpayable position
double max_equity = 0;             // maximum of equity ever reached, saved in global vars
double max_float = 0;              // minimum of equity ever reached, saved in global vars

// global flags:
// #019: new button: Stop Next Cyle, which trades normally, until cycle is closed
int stopNextCycle = 0;          // flag, if trading will be terminated after next successful cycle, trades normally until cyle is closed
int restAndRealize = 0;         // flag, if trading will be terminated after next successful cycle, does not open new positions
int stopAll = 0;                // flag, if stopAll must close all and stop trading or continue with trading

// #044: Add button to hide comment
int showComment = 1;            // flag for comment at left side
bool isFirstStartLoop = true;   // flag, to do some things only one time after program start

// button coordinates:
int btnLeftAxis = 220;                          // distance of 1st button from left
int btnTopAxis = 1;                             // distance of all buttons from top
int btnHeight = 23;                             // height of buttons
int btnGap = 2;                                 // gap between buttons
int btnWidth =97;                               // width of small buttons
int btnNextLeft = btnWidth + btnGap;            // distance to next small button
int btnNextTop = btnHeight + btnGap;            // distance of next buttons from top

// debugging:
string debugCommentDyn = "\n";        // will be added to regular Comment txt and updated each program loop
string debugCommentStat = "";         // will be added only - no updates
string debugCommentCloseBuys = "";    // show condition, when cycle will be closed
string debugCommentCloseSells = "";
string codeRedMsg = "";               // tell user, why account state is yellow or red
string codeYellowMsg = "";
double ter_IkarusChannel = 0;         // line_buy - line_sell
string globalVarsID = Symbol() + "_" + (string)magic + "_"; //ID to specify the global vars from other charts

// values read from terminal:
int ter_digits = 0;
double ter_priceBuy = 0;
double ter_priceSell = 0;
double ter_point = 0;
double ter_tick_value = 0;
double ter_tick_size = 0;
double ter_spread = 0;
datetime ter_timeNow = 0;             // date and time while actual loop

// calculate by values from terminal:
double ter_ticksPerGrid = 0;          // ticks of 1 min_lot per 1 grid size
int ter_chartMultiplier = 1;          // if digits = 3 or 5: chart multiplier = 10
string ter_currencySymbol = "$";      // € if account is in Euro, $ for all other

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ter_MODE_MARGINHEDGED = MarketInfo(Symbol(), MODE_MARGINHEDGED);
double ter_MODE_MARGININIT = MarketInfo(Symbol(), MODE_MARGININIT);
double ter_MODE_MARGINMAINTENANCE = MarketInfo(Symbol(), MODE_MARGINMAINTENANCE);
double ter_MODE_MARGINREQUIRED = MarketInfo(Symbol(), MODE_MARGINREQUIRED);

// Available Margin
double freemargin = AccountFreeMargin();

//+------------------------------------------------------------------+
// Breakeven Levels
double Ur_total_BE = 0;
double Ur_BE_buy = 0;
double Ur_BE_sell = 0;

//+------------------------------------------------------------------+
// Output Comments
double ATR_Buy = 0;
double ATR_Sell = 0;

// check candle time for "Once Candle Limit" function
datetime current_candle_open;
int current_tick;

//+------------------------------------------------------------------+
//| Init Function                                                    |
//+------------------------------------------------------------------+
int OnInit()
{

// #047: add panel right upper corner
   ObjectDelete("panel_1_01");
   ObjectDelete("panel_1_02");
   ObjectDelete("panel_1_03");
   ObjectDelete("panel_1_04");
   ObjectDelete("panel_1_05");
   ObjectDelete("panel_1_06");
   ObjectDelete("panel_1_07");
   ObjectDelete("panel_1_08");
   ObjectDelete("panel_1_09");
   ObjectDelete("panel_1_10");
   ObjectDelete("panel_1_11");

// draw the buttons
   DrawButton("btnhedgeBuy", "> Open Buy >", btnLeftAxis, btnTopAxis, btnWidth, btnHeight, false, colBuy, clrBlack);
   DrawButton("btnCloseLastBuy", "Close Last Buy", btnLeftAxis + 1 * btnNextLeft, btnTopAxis, btnWidth, btnHeight, false, colBuy, clrBlack);
   DrawButton("btnCloseAllBuys", "Close All Buys", btnLeftAxis + 2 * btnNextLeft, btnTopAxis, btnWidth, btnHeight, false, colBuy, clrBlack);
   
   DrawButton("btnhedgeSell", "> Open Sell >", btnLeftAxis + 3 * btnNextLeft + 5, btnTopAxis, btnWidth, btnHeight, false, colSell, clrBlack);
   DrawButton("btnCloseLastSell", "Close Last Sell", btnLeftAxis + 4 * btnNextLeft + 5, btnTopAxis, btnWidth, btnHeight, false, colSell, clrBlack);
   DrawButton("btnCloseAllSells", "Close All Sells", btnLeftAxis + 5 * btnNextLeft + 5, btnTopAxis, btnWidth, btnHeight, false, colSell, clrBlack);
   
   DrawButton("btnstopNextCycle", "Stop Next Cycle", btnLeftAxis + 6 * btnNextLeft + 10, btnTopAxis, btnWidth, btnHeight, false, colNeutral, clrBlack);
   DrawButton("btnrestAndRealize", "Rest & Realize", btnLeftAxis + 7 * btnNextLeft + 10, btnTopAxis, btnWidth, btnHeight, false, colNeutral, clrBlack);
   DrawButton("btnStopAll", "Stop & Close", btnLeftAxis + 8 * btnNextLeft + 10, btnTopAxis, btnWidth, btnHeight, false, colNeutral, clrBlack);  
   // DrawButton("btnShowComment", "Show/Hide Comment", 600, btnTopAxis, btnWidth * 1.3, btnHeight, false, colNeutral, colCodeYellow); // comments not used
 
   magic = getMagicNumber();  //Get magic number 
   hedge_magic = magic +1;
   string versionStr = DoubleToString(versionBMI, 2);
   string magicStr = IntegerToString(magic);
   string message = " - START.....";
   string logMessage = versionStr + " - " + magicStr + message;
   Print(logMessage);
   
   return(0);
}

//+------------------------------------------------------------------+
//| Deinit function                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    
   DeleteButton("btnStopAll");
   DeleteButton("btnrestAndRealize");
   DeleteButton("btnstopNextCycle");

   DeleteButton("btnhedgeBuy");
   DeleteButton("btnhedgeSell");
   DeleteButton("btnCloseLastBuy");
   DeleteButton("btnCloseLastSell");
   DeleteButton("btnCloseAllBuys");
   DeleteButton("btnCloseAllSells");

   if(ObjectFind("BE_buy") != -1)
      ObjectDelete("BE_buy");
   if(ObjectFind("BE_sell") != -1)
      ObjectDelete("BE_sell");
   if(ObjectFind("BE_total") != -1)
      ObjectDelete("BE_total");
}


// ------------------------------------------------------------------------------------------------
// START Function
// ------------------------------------------------------------------------------------------------
void OnTick()
{

// DISPLAY CLOSED PROFITS (ON CHART):

if (display_CP)
{
    double totalProfit = 0.0;
    double roundedProfit = NormalizeDouble(totalProfit, 2);
    int totalOrders = 0;
    datetime lastCloseTime = 0;
    double lastClosePrice = 0.0;

    for (int i = OrdersHistoryTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
            {
                double orderProfit = OrderProfit() + OrderSwap() + OrderCommission();

                if (OrderCloseTime() != lastCloseTime)
                {
                    if (totalOrders > 0) // if there are more orders
                    {
                        string totalProfitObjectName = "TotalProfitText:" + DoubleToString(lastCloseTime);
                        ObjectCreate(0, totalProfitObjectName, OBJ_TEXT, 0, 0, 0);

                        color profitColor = (totalProfit >= 0) ? Color_CP_Pos : Color_CP_Neg; // Determines the color based on profit

                        roundedProfit = NormalizeDouble(totalProfit, 2); // Rounds the total profit to 2 decimal places

                        string orderCount = (totalOrders == 1) ? "" : " (" + IntegerToString(totalOrders) + ")";

                        ObjectSetText(totalProfitObjectName, DoubleToStr(roundedProfit, 2) + ter_currencySymbol +
                            orderCount, Font_Size_CP, Font_Fam_CP, profitColor);
                        ObjectSet(totalProfitObjectName, OBJPROP_TIME1, lastCloseTime);

                        // Adjust the vertical position of the object
                        double priceLevel = lastClosePrice - Point * move_CP; // Calculate the new price level
                        ObjectSet(totalProfitObjectName, OBJPROP_PRICE1, priceLevel);

                        ObjectSet(totalProfitObjectName, OBJPROP_CORNER, 1);
                    }

                    totalProfit = 0.0;
                    totalOrders = 0;
                }

                totalProfit += orderProfit;
                totalOrders++;
                lastCloseTime = OrderCloseTime();
                lastClosePrice = OrderClosePrice();
            }
        }
    }

    if (totalOrders > 0) // if there is only one order
    {
        string totalProfitObjectName = "TotalProfitText:" + DoubleToString(lastCloseTime);
        ObjectCreate(0, totalProfitObjectName, OBJ_TEXT, 0, 0, 0);

        color profitColor = (totalProfit >= 0) ? Color_CP_Pos : Color_CP_Neg; // Determines the color based on profit

        roundedProfit = MathFloor(totalProfit * 100) / 100; // Rounds the total profit down to 2 decimal places

        ObjectSetText(totalProfitObjectName, DoubleToStr(roundedProfit, 2) + ter_currencySymbol,
            Font_Size_CP, Font_Fam_CP, profitColor);
        ObjectSet(totalProfitObjectName, OBJPROP_TIME1, lastCloseTime);

        // Adjust the vertical position of the object
        double priceLevel = lastClosePrice - Point * move_CP; // Calculate the new price level
        ObjectSet(totalProfitObjectName, OBJPROP_PRICE1, priceLevel);

        ObjectSet(totalProfitObjectName, OBJPROP_CORNER, 1);
    }
}

// CALCULATE CLOSED PROFIT (SIDE PANEL):

double totalProfitInAccountCurrency = 0.0;
double totalCommission = 0.0;
for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
totalProfitInAccountCurrency += OrderProfit() + OrderSwap() + OrderCommission();
totalCommission += OrderCommission();
}}}

// DISPLAY CLOSED PROFIT (SIDE PANEL):
if(show_profit) {
string profitDisplay = "Closed Profit: " + DoubleToString(totalProfitInAccountCurrency, 2) + " " + ter_currencySymbol;
if (totalProfitInAccountCurrency < 0) {
Write("panel_1_00", profitDisplay, 5, 165, "Roboto Condensed", 14, colInMinus);}
else if (totalProfitInAccountCurrency > 0) {Write("panel_1_00", profitDisplay, 5, 165, "Roboto Condensed", 14, colInPlus);}
else {Write("panel_1_00", profitDisplay, 5, 165, "Roboto Condensed", 14, colNeutral);}
}

#ifdef DEMO
// #049: add option to work with demo account only
   if(!IsDemo())
     {
      stopAll = 0;         // force a dived by zero error, to stop this EA
      MessageBox("Only on  D E M O  account please!", "C A U T I O N  !", MB_OK);
      stopAll = 1 / stopAll; // divide by zero stops it all
      return(0);           //just in case ;o)
     }
#endif

   max_float = MathMin(max_float, AccountProfit());

// do this only one time after starting the program
   if(isFirstStartLoop)
     {
      if(AccountCurrency() == "EUR")
         ter_currencySymbol = "€";
      if(MarketInfo(Symbol(), MODE_DIGITS) == 4 || MarketInfo(Symbol(), MODE_DIGITS) == 2)
        {
         slippage = user_slippage;
         ter_chartMultiplier = 1;
        }
      else
         if(MarketInfo(Symbol(), MODE_DIGITS) == 5 || MarketInfo(Symbol(), MODE_DIGITS) == 3)
           {
            ter_chartMultiplier = 10;
            slippage = ter_chartMultiplier * user_slippage;
           }

      // do we have any data from previous session?
      ReadIniData();

      debugCommentStat += "\nNew program start at " + TimeToStr(TimeCurrent());
      isFirstStartLoop = false;
     }

   if(IsTradeAllowed() == false)
     {
      Comment(versionBMI + "\n\nTrade not allowed.");
      return;
     }

   ter_priceBuy   = MarketInfo(Symbol(), MODE_ASK);
   ter_priceSell  = MarketInfo(Symbol(), MODE_BID);
   ter_tick_value = MarketInfo(Symbol(), MODE_TICKVALUE);
   ter_spread     = MarketInfo(Symbol(), MODE_SPREAD);
   ter_digits     = (int) MarketInfo(Symbol(), MODE_DIGITS);
   ter_tick_size  = MarketInfo(Symbol(), MODE_TICKSIZE);
   ter_point      = MarketInfo(Symbol(), MODE_POINT);

   if(slippage > user_slippage)
     {
      ter_point = ter_point * 10;
     }

   ter_timeNow = TimeCurrent();
   ter_ticksPerGrid = - calculateTicksByPrice(min_lots, CalculateSL(min_lots, 1)) - ter_spread * ter_tick_size;

// #025: use equity percentage instead of unpayable position
   if(AccountEquity() > max_equity)
     {
      max_equity = AccountEquity();
     }

// Updating current status:
   InitVars();
   UpdateVars();
   SortByLots();
   showData();
// Breakeven Calculation
   BreakEven();
// Equal Lock Line Calculation
   EqualLockLevel();
//***************************************************************
// #014: start new dynamic debug output here; will be shown at the end of comment string; will be updated each program loop
   debugCommentDyn = "\n";

   showLines();

// #023: implement account state by 3 colored button
   checkAccountState();

// #010: implement button: Stop & Close
   if(stopAll)
     {
      // Closing all open orders
      SetButtonText("btnStopAll", "Continue");
      SetButtonColor("btnStopAll", colCodeRed, colFontLight);
      closeAllBuys();
      closeAllSells();
     }
   else
     {
      handleCycleRisk();
      robot();
      handleHedging();

      if(partial_closing > 0)
        {
         thinOutTheGrid();
        }
     }

   return;
  }


// ------------------------------------------------------------------------------------------------
// Main auto trading method
// ------------------------------------------------------------------------------------------------
void robot()
  {
   int ticket = - 1;
   bool closed = FALSE;

   double local_total_buy_profit = 0, local_total_sell_profit = 0;

// *************************
// ACCOUNT RISK CONTROL
// *************************
   if(((100 - (100 * account_risk)) / 100)*AccountBalance() > AccountEquity())
     {
      // #012: make account risk save: all positions will be cleared and trading will be paused by stop&close button
      stopAll = 1;
      // Closing buy orders
      //for(i=0; i<=buys-1; i++)
      //  {
      //   closed=OrderCloseReliable(buy_tickets[i],buy_lots[i],MarketInfo(Symbol(),MODE_BID),slippage,Blue);
      //  }
      //// Closing sell orders
      //for(i=0; i<=sells-1; i++)
      //  {
      //   closed=OrderCloseReliable(sell_tickets[i],sell_lots[i],MarketInfo(Symbol(),MODE_ASK),slippage,Red);
      //  }
      //BuyResetAfterClose();
      //SellResetAfterClose();
     }

   local_total_buy_profit = total_buy_profit;
   local_total_sell_profit = total_sell_profit;

// check if there is a hedge trade open
// if the hedge trade is buy and it is max trade lot
// then calculate new local_total_sell_profit with the hedge buy order
   if(hedge_buys > 0)
     {
      // max hedge lot means this is a correction lot
      local_total_sell_profit = total_sell_profit + total_hedge_buy_profit;
     }

// if the hedge trade is sell and it is max trade lot
// then calculate new local_total_buy_profit with the hedge sell order
   if(hedge_sells > 0)
     {
      // max hedge lot means this is a correction lot
      local_total_buy_profit = total_buy_profit + total_hedge_sell_profit;
     }

// **************************************************
// BUYS==0
// **************************************************
// there are not buys check the indicators and open new buy order
   if(buys == 0 && Time_to_Trade())
     {

      if(Use_ATR)
        {
         grid_size = ATR_Grid_Size();
         take_profit = TP_Multiplier * ATR_Grid_Size() / ATR_Multiplier; // maybe fixed take profit better?
        }
      // #019: new button: Stop Next Cyle, which trades normally, until cycle is closed
      if(Use_BB || Use_Stoch || Use_RSI || Use_CCI || Use_C1 || Use_C2 || Use_C3)
        {
         if(!stopNextCycle && !restAndRealize && Indicators_Buy())
           {
            ticket = OrderSendReliable(Symbol(), OP_BUY, CalculateStartingVolume(), MarketInfo(Symbol(), MODE_ASK), slippage, 0, 0, key + "-" + (string)buys, magic, 0, Blue);
            if(sells == 0 && both_cycle)
              {
               ticket = OrderSendReliable(Symbol(), OP_SELL, CalculateStartingVolume(), MarketInfo(Symbol(), MODE_BID), slippage, 0, 0, key + "-" + (string)sells, magic, 0, Red);
              }
           }
        }
      else
        {
         if(!stopNextCycle && !restAndRealize)
           {
            ticket = OrderSendReliable(Symbol(), OP_BUY, CalculateStartingVolume(), MarketInfo(Symbol(), MODE_ASK), slippage, 0, 0, key + "-" + (string)buys, magic, 0, Blue);
           }
        }
     }

// **************************************************
// BUYS == 1
// **************************************************
   if(buys == 1)
     {
      if(Use_ATR)
        {
         grid_size = ATR_Grid_Size();
         take_profit = TP_Multiplier * ATR_Grid_Size() / ATR_Multiplier; // maybe fixed take profit better?
        }


      if(!stopNextCycle && !restAndRealize && max_positions > 1)
        {
         // CASE 1 >>> We reach Stop Loss (grid size)
         if(buy_profit[buys - 1] <= CalculateSL(buy_lots[buys - 1], 1))
           {
            // We are going to open a new order. Volume depends on chosen progression.
            NewGridOrder(OP_BUY, false);
           }
        }

      // CASE 2.1 >>> We reach Take Profit so we activate profit lock
      if(buy_max_profit == 0 && local_total_buy_profit > CalculateTP(buy_lots[0]))
        {
         buy_max_profit = local_total_buy_profit;
         buy_close_profit = profit_lock * buy_max_profit;
        }

      // CASE 2.2 >>> Profit locked is updated in real time
      if(buy_max_profit > 0 && local_total_buy_profit > buy_max_profit)
        {
         buy_max_profit = local_total_buy_profit;
         buy_close_profit = profit_lock * local_total_buy_profit;
        }

      // CASE 2.3 >>> If profit falls below profit locked we close all orders
      if(buy_max_profit > 0 && buy_close_profit > 0
         && buy_max_profit >= buy_close_profit && local_total_buy_profit < buy_close_profit)
        {
         // At this point all order are closed.
         // Global vars will be updated thanks to UpdateVars() on next start() execution
         closeAllBuys();
        }
     } // if (buys==1)

// **************************************************
// BUYS > 1
// **************************************************
   if(buys > 1)
     {
      if(Use_ATR)
        {
         grid_size = ATR_Grid_Size();
         take_profit = TP_Multiplier * ATR_Grid_Size() / ATR_Multiplier; // maybe fixed take profit better?
        }


      // CASE 1 >>> We reach Stop Loss (grid size)
      if(buy_profit[buys - 1] <= CalculateSL(buy_lots[buys - 1], buys))
        {
         // We are going to open a new order if we have less than 90 orders opened.
         // Volume depends on chosen progression.
         if(buys < max_auto_open_positions)
           {
            if(buys < max_positions && !buy_max_order_lot_open)
              {
               NewGridOrder(OP_BUY, false);
              }
           }
        }

      // CASE 2.1 >>> We reach Take Profit so we activate profit lock
      if(buy_max_profit == 0 && progression == 0 && local_total_buy_profit > CalculateTP(buy_lots[0]))
        {
         buy_max_profit = local_total_buy_profit;
         buy_close_profit = profit_lock * buy_max_profit;
         if(!buy_chased && profit_chasing > 0)
           {
            if(buys < max_auto_open_positions && buys < max_positions)
              {
               ticket = OrderSendReliable(Symbol(), OP_BUY, profit_chasing * CalculateStartingVolume(), MarketInfo(Symbol(), MODE_ASK), slippage, 0, 0, key + "-" + (string)buys, magic, 0, Blue);
              }
            buy_chased = true;
           }
        }
      if(buy_max_profit == 0 && progression == 1 && local_total_buy_profit > buys * CalculateTP(buy_lots[0]))
        {
         buy_max_profit = local_total_buy_profit;
         buy_close_profit = profit_lock * buy_max_profit;
         if(!buy_chased && profit_chasing > 0)
           {
            if(buys < max_auto_open_positions && buys < max_positions)
               ticket = OrderSendReliable(Symbol(), OP_BUY, profit_chasing * CalculateStartingVolume(), MarketInfo(Symbol(), MODE_ASK), slippage, 0, 0, key + "-" + (string)buys, magic, 0, Blue);
            buy_chased = true;
           }
        }
      if(buy_max_profit == 0 && progression == 2 && local_total_buy_profit > CalculateTP(buy_lots[buys - 1]))
        {
         buy_max_profit = local_total_buy_profit;
         buy_close_profit = profit_lock * buy_max_profit;
         if(!buy_chased && profit_chasing > 0)
           {
            if(buys < max_auto_open_positions && buys < max_positions)
              {
               ticket = OrderSendReliable(Symbol(), OP_BUY, profit_chasing * CalculateStartingVolume(), MarketInfo(Symbol(), MODE_ASK), slippage, 0, 0, key + "-" + (string)buys, magic, 0, Blue);
              }
            buy_chased = true;
           }
        }
      if(buy_max_profit == 0 && progression == 3 && local_total_buy_profit > CalculateTP(buy_lots[buys - 1]))
        {
         buy_max_profit = local_total_buy_profit;
         buy_close_profit = profit_lock * buy_max_profit;
         if(!buy_chased && profit_chasing > 0)
           {
            if(buys < max_auto_open_positions && buys < max_positions)
              {
               ticket = OrderSendReliable(Symbol(), OP_BUY, profit_chasing * CalculateStartingVolume(), MarketInfo(Symbol(), MODE_ASK), slippage, 0, 0, key + "-" + (string)buys, magic, 0, Blue);
              }
            buy_chased = true;
           }
        }

      // CASE 2.2 >>> Profit locked is updated in real time
      if(buy_max_profit > 0 && local_total_buy_profit > buy_max_profit)
        {
         buy_max_profit = local_total_buy_profit;
         buy_close_profit = profit_lock * local_total_buy_profit;
        }

      // CASE 2.3 >>> If profit falls below profit locked we close all orders
      if(buy_max_profit > 0 && buy_close_profit > 0 && buy_max_profit >= buy_close_profit
         && local_total_buy_profit < buy_close_profit)
        {
         // At this point all order are closed.
         // Global vars will be updated thanks to UpdateVars() on next start() execution
         closeAllBuys();
        }
     } // if (buys>1)

   debugCommentCloseBuys
      = "\nbuys will be closed if:\n" +
        "    - buy max profit: " + DoubleToString(buy_max_profit, 2) + " > buy close profit: " + DoubleToString(buy_close_profit, 2) + "     AND \n" +
        "    - total buy profit: " + DoubleToString(local_total_buy_profit, 2) + " < buy close profit: " + DoubleToString(buy_close_profit, 2) + "\n";

// **************************************************
// SELLS==0
// **************************************************
// there are not sells check the indicators and open new buy order
   if(sells == 0 && Time_to_Trade())
     {

      if(Use_ATR)
        {
         grid_size = ATR_Grid_Size();
         take_profit = TP_Multiplier * ATR_Grid_Size() / ATR_Multiplier;
        }
      // #019: new button: Stop Next Cyle, which trades normally, until cycle is closed
      if(Use_BB || Use_Stoch || Use_RSI || Use_CCI || Use_C1 || Use_C2 || Use_C3)
        {
         if(!stopNextCycle && !restAndRealize && Indicators_Sell())
           {
            ticket = OrderSendReliable(Symbol(), OP_SELL, CalculateStartingVolume(), MarketInfo(Symbol(), MODE_BID), slippage, 0, 0, key + "-" + (string)sells, magic, 0, Red);
            if(buys == 0 && both_cycle)
              {
               ticket = OrderSendReliable(Symbol(), OP_BUY, CalculateStartingVolume(), MarketInfo(Symbol(), MODE_ASK), slippage, 0, 0, key + "-" + (string)buys, magic, 0, Blue);
              }
           }
        }
      else
        {
         if(!stopNextCycle && !restAndRealize)
           {
            ticket = OrderSendReliable(Symbol(), OP_SELL, CalculateStartingVolume(), MarketInfo(Symbol(), MODE_BID), slippage, 0, 0, key + "-" + (string)sells, magic, 0, Red);
           }
        }
     }

// **************************************************
// SELLS == 1
// **************************************************
   if(sells == 1)
     {
      if(Use_ATR)
        {
         grid_size = ATR_Grid_Size();
         take_profit = TP_Multiplier * ATR_Grid_Size() / ATR_Multiplier; // maybe fixed take profit better?
        }


      // CASE 1 >>> We reach Stop Loss (grid size)
      if(!stopNextCycle && !restAndRealize && max_positions > 1)
        {
         if(sell_profit[sells - 1] <= CalculateSL(sell_lots[sells - 1], 1))
           {
            // We are going to open a new order. Volume depends on chosen progression.
            NewGridOrder(OP_SELL, false);
           }
        }

      // CASE 2.1 >>> We reach Take Profit so we activate profit lock
      if(sell_max_profit == 0 && local_total_sell_profit > CalculateTP(sell_lots[0]))
        {
         sell_max_profit = local_total_sell_profit;
         sell_close_profit = profit_lock * sell_max_profit;
        }

      // CASE 2.2 >>> Profit locked is updated in real time
      if(sell_max_profit > 0 && local_total_sell_profit > sell_max_profit)
        {
         sell_max_profit = local_total_sell_profit;
         sell_close_profit = profit_lock * local_total_sell_profit;
        }

      // CASE 2.3 >>> If profit falls below profit locked we close all orders
      if(sell_max_profit > 0 && sell_close_profit > 0
         && sell_max_profit >= sell_close_profit && local_total_sell_profit < sell_close_profit)
        {
         // At this point all order are closed.
         // Global vars will be updated thanks to UpdateVars() on next start() execution
         closeAllSells();
        }
     } // if (sells==1)

// **************************************************
// SELLS>1
// **************************************************
   if(sells > 1)
     {
      if(Use_ATR)
        {
         grid_size = ATR_Grid_Size();
         take_profit = TP_Multiplier * ATR_Grid_Size() / ATR_Multiplier; // maybe fixed take profit better?
        }


      // CASE 1 >>> We reach Stop Loss (grid size)
      if(sell_profit[sells - 1] <= CalculateSL(sell_lots[sells - 1], sells))
        {
         // We are going to open a new order if we have less than 90 orders opened.
         // Volume depends on chosen progression.
         if(sells < max_auto_open_positions)
           {
            if(sells < max_positions && !sell_max_order_lot_open)
              {
               NewGridOrder(OP_SELL, false);
              }
           }
        }

      // CASE 2.1 >>> We reach Take Profit so we activate profit lock
      if(sell_max_profit == 0 && progression == 0 && local_total_sell_profit > CalculateTP(sell_lots[0]))
        {
         sell_max_profit = local_total_sell_profit;
         sell_close_profit = profit_lock * sell_max_profit;
         if(!sell_chased && profit_chasing > 0)
           {
            if(buys < max_auto_open_positions && buys < max_positions)
              {
               ticket = OrderSendReliable(Symbol(), OP_SELL, profit_chasing * CalculateStartingVolume(), MarketInfo(Symbol(), MODE_BID), slippage, 0, 0, key + "-" + (string)sells, magic, 0, Red);
              }
            sell_chased = true;
           }
        }
      if(sell_max_profit == 0 && progression == 1 && local_total_sell_profit > sells * CalculateTP(sell_lots[0]))
        {
         sell_max_profit = local_total_sell_profit;
         sell_close_profit = profit_lock * sell_max_profit;
         if(!sell_chased && profit_chasing > 0)
           {
            if(buys < max_auto_open_positions && buys < max_positions)
              {
               ticket = OrderSendReliable(Symbol(), OP_SELL, profit_chasing * CalculateStartingVolume(), MarketInfo(Symbol(), MODE_BID), slippage, 0, 0, key + "-" + (string)sells, magic, 0, Red);
              }
            sell_chased = true;
           }
        }
      if(sell_max_profit == 0 && progression == 2 && local_total_sell_profit > CalculateTP(sell_lots[sells - 1]))
        {
         sell_max_profit = local_total_sell_profit;
         sell_close_profit = profit_lock * sell_max_profit;
         if(!sell_chased && profit_chasing > 0)
           {
            if(buys < max_auto_open_positions && buys < max_positions)
              {
               ticket = OrderSendReliable(Symbol(), OP_SELL, profit_chasing * CalculateStartingVolume(), MarketInfo(Symbol(), MODE_BID), slippage, 0, 0, key + "-" + (string)sells, magic, 0, Red);
              }
            sell_chased = true;
           }
        }
      if(sell_max_profit == 0 && progression == 3 && local_total_sell_profit > CalculateTP(sell_lots[sells - 1]))
        {
         sell_max_profit = local_total_sell_profit;
         sell_close_profit = profit_lock * sell_max_profit;
         if(!sell_chased && profit_chasing > 0)
           {
            if(buys < max_auto_open_positions && buys < max_positions)
              {
               ticket = OrderSendReliable(Symbol(), OP_SELL, profit_chasing * CalculateStartingVolume(), MarketInfo(Symbol(), MODE_BID), slippage, 0, 0, key + "-" + (string)sells, magic, 0, Red);
              }
            sell_chased = true;
           }
        }

      // CASE 2.2 >>> Profit locked is updated in real time
      if(sell_max_profit > 0 && local_total_sell_profit > sell_max_profit)
        {
         sell_max_profit = local_total_sell_profit;
         sell_close_profit = profit_lock * sell_max_profit;
        }

      // CASE 2.3 >>> If profit falls below profit locked we close all orders
      if(sell_max_profit > 0 && sell_close_profit > 0
         && sell_max_profit >= sell_close_profit && local_total_sell_profit < sell_close_profit)
        {
         // At this point all order are closed.
         // Global vars will be updated thanks to UpdateVars() on next start() execution
         closeAllSells();
        }
     } // if (sells>1)

   debugCommentCloseSells = "\nsells will be closed if:\n" +
                            "    - sell max profit: " + DoubleToString(sell_max_profit, 2) + " > sell close profit: " + DoubleToString(sell_close_profit, 2) + " AND \n" +
                            "    - total sell profit: " + DoubleToString(local_total_sell_profit, 2) + " < sell close profit: " + DoubleToString(sell_close_profit, 2);

// #017: deal with global vars to save and restore data, while chart is closed or must be restarted by other reason
   WriteIniData();
  }

//+------------------------------------------------------------------+
//| CheckAccountState
//+------------------------------------------------------------------+
void checkAccountState()
  {
   accountState = as_green;   // init state
   codeYellowMsg = "";        // #038: give user info, why account state is yellow or red
   codeRedMsg = "";
   double myPercentage = 0;

// check if max_positions is reached:
   if(buys >= max_positions)
      accountState = as_yellow;
   if(sells >= max_positions)
      accountState = as_yellow;
   if(accountState == as_yellow)
      codeYellowMsg = "Code YELLOW: Max positions reached";

// #024: calculate, if margin of next position can be paid
   if(CalculateNextMargin() > AccountFreeMargin())
     {
      accountState = as_red;
      codeRedMsg = "Code RED: Next M. " + DoubleToString(CalculateNextMargin(), 2) + " > Free M. " + DoubleToString(AccountFreeMargin(), 2);
     }

// #025: use equity percentage instead of unpayable position
   if((100 - (100 * equity_warning)) / 100 * max_equity > AccountEquity())
     {
      accountState = as_red;
      if(codeRedMsg == "")
        {
         codeRedMsg = "Code RED: Equ. " + DoubleToStr(AccountEquity(), 2) + " < " + DoubleToStr((100 * equity_warning), 0) + "% of max. equ. " + DoubleToStr(max_equity, 2);
        }
      else
        {
         codeRedMsg += "\nand\nEqu. " + DoubleToStr(AccountEquity(), 2) + " < " + DoubleToStr((100 * equity_warning), 0) + "% of max. equ. " + DoubleToStr(max_equity, 2);
        }
     }

// #026: implement hedge trades, if account state is not green
// #053: paint comment button in status color
   switch(accountState)
     {
      case as_yellow:
         SetButtonColor("btnhedgeBuy", colCodeYellow, colFontDark);
         SetButtonColor("btnhedgeSell", colCodeYellow, colFontDark);
         SetButtonColor("btnCloseLastBuy", colCodeYellow, colFontDark);
         SetButtonColor("btnCloseLastSell", colCodeYellow, colFontDark);
         SetButtonColor("btnCloseAllBuys", colCodeYellow, colFontDark);
         SetButtonColor("btnCloseAllSells", colCodeYellow, colFontDark);
         SetButtonColor("btnShowComment", colCodeYellow, colFontDark);
         break;
      case as_red:
         SetButtonColor("btnhedgeBuy", colCodeRed, colFontLight);
         SetButtonColor("btnhedgeSell", colCodeRed, colFontLight);
         SetButtonColor("btnCloseLastBuy", colCodeRed, colFontLight);
         SetButtonColor("btnCloseLastSell", colCodeRed, colFontLight);
         SetButtonColor("btnCloseAllBuys", colCodeRed, colFontLight);
         SetButtonColor("btnCloseAllSells", colCodeRed, colFontLight);
         SetButtonColor("btnShowComment", colCodeRed, colFontLight);
         break;
      default:
         SetButtonColor("btnhedgeBuy", colBuy, colFontLight);
         SetButtonColor("btnhedgeSell", colSell, colFontLight);
         SetButtonColor("btnCloseLastBuy", colBuy, colFontLight);
         SetButtonColor("btnCloseLastSell", colSell, colFontLight);
         SetButtonColor("btnCloseAllBuys", colBuy, colFontLight);
         SetButtonColor("btnCloseAllSells", colSell, colFontLight);
         SetButtonColor("btnShowComment", colNeutral, colFontLight);
         break;
     }

   return;
  }

//+------------------------------------------------------------------+
//| CalculateVolume                                                   |
//+------------------------------------------------------------------+
double calculateVolume(int positions)
{
   double factor = 0.0;  // Modified to allow for decimal precision
   int i = 0;

   if(positions == 0)
      return(min_lots);

   switch(gs_progression)
   {
      case 0:
         factor = 1.0;  // Modified to include decimal places
         break;
      case 1:
         factor = positions;
         break;
      case 2:
         for(i = 1, factor = 1.0; i < positions; i++)
            factor = factor * gs_multiplicator;
         break;
      case 3:
         factor = CalculateFibonacci(positions);
         break;
   }

   return(factor * min_lots);
}


//+------------------------------------------------------------------+
//| CalculateNextVolume                                                                 |
//+------------------------------------------------------------------+
double CalculateNextVolume(int orderType)
  {
   if(orderType == OP_BUY && buys == 0)
      return(min_lots);
   if(orderType == OP_SELL && sells == 0)
      return(min_lots);

// next volume must be calulated by actual positions + 1
   switch(progression)
     {
      case 0:
         return(min_lots);
         break;
      case 1:
         if(orderType == OP_BUY)
           {
            return(buy_lots[buys - 1] + buy_lots[0]);
           }
         else
           {
            return(sell_lots[sells - 1] + sell_lots[0]);
           }
         break;
      case 2:
         if(orderType == OP_BUY)
           {
            return (NormalizeDouble(min_lots * MathPow(lot_multiplicator, buys),2));            //(lot_multiplicator * buy_lots[buys - 1]);
           }
         else
           {
            return (NormalizeDouble(min_lots * MathPow(lot_multiplicator, sells),2));           //(lot_multiplicator * sell_lots[sells - 1]);
           }
         break;
      case 3:
         if(orderType == OP_BUY)
           {
            return(CalculateFibonacci(buys + 1) * buy_lots[0]);
           }
         else
           {
            return(CalculateFibonacci(sells + 1) * sell_lots[0]);
           }
         break;
     }

   return(min_lots);
  }

//+------------------------------------------------------------------+
//| CalculateMargin                                                  |
//+------------------------------------------------------------------+
double CalculateNextMargin()
  {
   double leverage = 100 / AccountLeverage();

   if(buys + sells == 0)
      return(min_lots * leverage * ter_MODE_MARGINREQUIRED);
   if(buys > sells)
     {
      return(CalculateNextVolume(OP_BUY) * leverage  * ter_MODE_MARGINREQUIRED);
     }
   else
     {
      return(CalculateNextVolume(OP_SELL) * leverage * ter_MODE_MARGINREQUIRED);
     }
  }

//+------------------------------------------------------------------+
//| CALCULATE STARTING VOLUME                                        |
//+------------------------------------------------------------------+
double CalculateStartingVolume()
{
   double volume;
   if(use_autolot)
   {
      // Calculate volume based on AutoLotBalance
      volume = AccountBalance() * min_lots / AutoLotBalance;
   }
   else
   {
      // Use the fixed min_lots
      volume = min_lots;
   }
   return (volume);

   if(volume > MarketInfo(Symbol(), MODE_MAXLOT))
     {
      volume = MarketInfo(Symbol(), MODE_MAXLOT);
     }

   if(volume < MarketInfo(Symbol(), MODE_MINLOT))
     {
      volume = MarketInfo(Symbol(), MODE_MINLOT);
     }
   return(volume);
  }

// ------------------------------------------------------------------------------------------------
// CALCULATE TICKS by PRICE
// ------------------------------------------------------------------------------------------------
double calculateTicksByPrice(double volume, double price)
  {
   if(volume == 0)
      return(0);
   return(price * ter_tick_size / ter_tick_value / volume);
  }

// ------------------------------------------------------------------------------------------------
// CALCULATE PRICE by TICK DIFFERENCE
// ------------------------------------------------------------------------------------------------
double CalculatePriceByTickDiff(double volume, double diff)
  {
   return(ter_tick_value * volume * diff / ter_tick_size);
  }

// ------------------------------------------------------------------------------------------------
// CALCULATE PIP VALUE
// ------------------------------------------------------------------------------------------------
double CalculatePipValue(double volume)
  {
   double aux_mm_value = 0;

   double aux_mm_tick_value = ter_tick_value;
   double aux_mm_tick_size = ter_tick_size;
   int aux_mm_digits = ter_digits;
   double aux_mm_veces_lots;

   if(volume != 0)
     {
      aux_mm_veces_lots = 1 / volume;
      if(aux_mm_digits == 5 || aux_mm_digits == 3)
        {
         aux_mm_value = aux_mm_tick_value * 10;
        }
      else
         if(aux_mm_digits == 4 || aux_mm_digits == 2)
           {
            aux_mm_value = aux_mm_tick_value;
           }
      aux_mm_value = aux_mm_value / aux_mm_veces_lots;
     }

   return(aux_mm_value);
  }

// ------------------------------------------------------------------------------------------------
// CALCULATE TAKE PROFIT
// ------------------------------------------------------------------------------------------------
double CalculateTP(double volume)
  {
   double aux_take_profit;

   // Calculate the reduced take profit based on the number of orders for each grid
   double reducedTakeProfitBuys = take_profit - buys * reduce_tp;
   double reducedTakeProfitSells = take_profit - sells * reduce_tp;

   // Calculate the take profit for each grid separately
   double aux_tp_buy = reducedTakeProfitBuys * CalculatePipValue(volume);
   double aux_tp_sell = reducedTakeProfitSells * CalculatePipValue(volume);

   // Choose the smaller take profit value as the final take profit
   aux_take_profit = MathMin(aux_tp_buy, aux_tp_sell);
   
   // Limit the take profit to a minimum value of 1 pip
   aux_take_profit = MathMax(1, aux_take_profit);

   return(aux_take_profit);
  }

// ------------------------------------------------------------------------------------------------
// CALCULATE STOP LOSS
// ------------------------------------------------------------------------------------------------
double CalculateSL(double volume, int positions)
  {
// volume = volume of last position only
   double aux_stop_loss;

// #008: use progression for grid size as well as volume
   double myVal = calculateVolume(positions) / min_lots;

   aux_stop_loss = - (myVal * grid_size * CalculatePipValue(volume));

// the stop loss line is calculated in ShowLines and the value to clear a position does also not use this value
   return(aux_stop_loss);
  }

//+------------------------------------------------------------------+
//|  CalulateFibonacci                                                                |
//+------------------------------------------------------------------+
int CalculateFibonacci(int index)
  {
   int val1 = 0;
   int val2 = 1;
   int val3 = 0;

   for(int i = 1; i < index; i++)   // use this for: 1, 1, 2, 3, 5, 8, 13, 21, ...
     {
      val3 = val2;
      val2 = val1 + val2;
      val1 = val3;
     }

   return val2;
  }

//+------------------------------------------------------------------+
// closeAllSells
//+------------------------------------------------------------------+
void closeAllSells()
  {
   sell_max_profit = 0;
   sell_close_profit = 0;

   if(sells > 0)
     {
      closeAllhedgeBuys();
      for(int i = 0; i <= sells - 1; i++)
        {
         bool retVal = OrderCloseReliable(sell_tickets[i], sell_lots[i], MarketInfo(Symbol(), MODE_ASK), slippage, Red);
        }
      ObjectDelete("TakeProfit_sell");
      ObjectDelete("ProfitLock_sell");
      ObjectDelete("Next_sell");
      ObjectDelete("NewTakeProfit_sell");
      line_sell = 0;
      line_sell_tmp = 0;
      line_sell_next = 0;
      line_sell_ts = 0;
     }
  }

//+------------------------------------------------------------------+
// CloseAllBuys
//+------------------------------------------------------------------+
void closeAllBuys()
  {
   buy_max_profit = 0;
   buy_close_profit = 0;

   if(buys > 0)
     {
      closeAllhedgeSells();
      for(int i = 0; i <= buys - 1; i++)
        {
         bool retVal = OrderCloseReliable(buy_tickets[i], buy_lots[i], MarketInfo(Symbol(), MODE_BID), slippage, Blue);
        }
      ObjectDelete("TakeProfit_buy");
      ObjectDelete("ProfitLock_buy");
      ObjectDelete("Next_buy");
      ObjectDelete("NewTakeProfit_buy");
      line_buy = 0;
      line_buy_tmp = 0;
      line_buy_next = 0;
      line_buy_ts = 0;
     }
  }

//+------------------------------------------------------------------+
// closeAllhedgeSells
//+------------------------------------------------------------------+
void closeAllhedgeSells()
  {
   if(hedge_sells > 0)
     {
      for(int i = 0; i <= hedge_sells - 1; i++)
        {
         bool retVal = OrderCloseReliable(hedge_sell_tickets[i], hedge_sell_lots[i], MarketInfo(Symbol(), MODE_ASK), slippage, Red);
        }
     }
  }

//+------------------------------------------------------------------+
// closeAllhedgeBuys
//+------------------------------------------------------------------+
void closeAllhedgeBuys()
  {
   if(hedge_buys > 0)
     {
      for(int i = 0; i <= hedge_buys - 1; i++)
        {
         bool retVal = OrderCloseReliable(hedge_buy_tickets[i], hedge_buy_lots[i], MarketInfo(Symbol(), MODE_BID), slippage, Blue);
        }
     }
  }

//+------------------------------------------------------------------+
// CloseBuyHedgeAndFirstSellOrder
//+------------------------------------------------------------------+
void closeBuyHedgeAndFirstSellOrder()
  {
   buy_max_hedge_profit = 0;
   buy_close_hedge_profit = 0;

   bool retVal = OrderCloseReliable(sell_tickets[0], sell_lots[0], MarketInfo(Symbol(), MODE_ASK), slippage, Red);
   closeAllhedgeBuys();
  }

//+------------------------------------------------------------------+
// closeBuyHedgeAndFirstSellOrder
//+------------------------------------------------------------------+
void closeBuyHedgeAndLastAndSecondLastSellOrder()
  {

   closeAllhedgeBuys();
   bool retVal = OrderCloseReliable(sell_tickets[sells - 1], sell_lots[sells - 1], MarketInfo(Symbol(), MODE_ASK), slippage, Red);
   bool retVal2 = OrderCloseReliable(sell_tickets[sells - 2], sell_lots[sells - 2], MarketInfo(Symbol(), MODE_ASK), slippage, Red);
  }

//+------------------------------------------------------------------+
// closeSellHedgeAndFirstBuyOrder
//+------------------------------------------------------------------+
void closeSellHedgeAndFirstBuyOrder()
  {
   sell_max_hedge_profit = 0;
   sell_close_hedge_profit = 0;

   bool retVal = OrderCloseReliable(buy_tickets[0], buy_lots[0], MarketInfo(Symbol(), MODE_BID), slippage, Blue);
   closeAllhedgeSells();
  }

//+------------------------------------------------------------------+
// closeBuyHedgeAndLastAndSecondLastBuyOrder
//+------------------------------------------------------------------+
void closeSellHedgeAndLastAndSecondLastBuyOrder()
  {

   closeAllhedgeSells();
   bool retVal = OrderCloseReliable(buy_tickets[buys - 1], buy_lots[buys - 1], MarketInfo(Symbol(), MODE_BID), slippage, Blue);
   bool retVal2 = OrderCloseReliable(buy_tickets[buys - 2], buy_lots[buys - 2], MarketInfo(Symbol(), MODE_BID), slippage, Blue);
  }

//+------------------------------------------------------------------+
// closeLastAndFirstBuyOrder
//+------------------------------------------------------------------+
void closeLastAndFirstBuyOrder()
  {

   bool retVal = OrderCloseReliable(buy_tickets[0], buy_lots[0], MarketInfo(Symbol(), MODE_BID), slippage, Blue);
   bool retVal2 = OrderCloseReliable(buy_tickets[buys - 1], buy_lots[buys - 1], MarketInfo(Symbol(), MODE_BID), slippage, Blue);
  }

//+------------------------------------------------------------------+
// CloseLastAndFirstSellOrder
//+------------------------------------------------------------------+
void closeLastAndFirstSellOrder()
  {

   bool retVal = OrderCloseReliable(sell_tickets[0], sell_lots[0], MarketInfo(Symbol(), MODE_ASK), slippage, Red);
   bool retVal2 = OrderCloseReliable(sell_tickets[sells - 1], sell_lots[sells - 1], MarketInfo(Symbol(), MODE_ASK), slippage, Red);
  }

//+------------------------------------------------------------------+
//| NewGridOrder                                                     |
//+------------------------------------------------------------------+
void NewGridOrder(int orderType, bool ishedgely)
  {
  
// ONE CANDLE LIMIT - Check if one_candle_limit is enabled and if enough candles have passed since the last order
    if (one_candle_limit && (Bars(_Symbol, _Period) - lastCandleIndex) <  1)
    {
        Print("One candle limit is enabled. Not opening a new order.");
        return;
    }
// ONCE CANDLE LIMIT - END

// STRICT SIGNALS - limits opening of new grid orders only on valid signal
   if (strict_signals) {
   if (orderType == OP_BUY && !Indicators_Buy()) {
   return;  // No valid buy signal, do not open new buy order
   }
   if (orderType == OP_SELL && !Indicators_Sell()) {
   return;  // No valid sell signal, do not open new sell order
   }}
// STRICT SIGNALS [END]
 
   int ticket;
   double next_lot = min_lots;

// #018: rename button: stop next cyle to rest and realize; does not open new positions until cycle is closed
// #019: Button: Stop On Next Cycle is still at Robot()
   if(restAndRealize && !ishedgely)
      return;
   if(orderType == OP_BUY)
     {
      // new buy:
      if(progression == 0)
         next_lot = min_lots;
      if(progression == 1)
         next_lot = buy_lots[buys - 1] + buy_lots[0];
      if(progression == 2)
         next_lot = (NormalizeDouble(min_lots * MathPow(lot_multiplicator, buys),2));
      //lot_multiplicator * buy_lots[buys - 1];
      if(progression == 3)
         next_lot = CalculateFibonacci(buys + 1) * min_lots;

      ticket = OrderSendReliable(Symbol(), OP_BUY, next_lot, MarketInfo(Symbol(), MODE_ASK), slippage, 0, 0, key + "-" + (string)buys, magic, 0, Blue);
     }
   else
     {
      // new sell:
      if(progression == 0)
         next_lot = min_lots;
      if(progression == 1)
         next_lot = sell_lots[sells - 1] + sell_lots[0];
      if(progression == 2)
         next_lot = (NormalizeDouble(min_lots * MathPow(lot_multiplicator, sells),2));
      //lot_multiplicator * sell_lots[sells - 1];
      if(progression == 3)
         next_lot = CalculateFibonacci(sells + 1) * min_lots;

      ticket = OrderSendReliable(Symbol(), OP_SELL, next_lot, MarketInfo(Symbol(), MODE_BID), slippage, 0, 0, key + "-" + (string)sells, magic, 0, Red);
     }
     
// ONE CANDLE LIMIT - Update lastCandleIndex after successfully opening a new order
    lastCandleIndex = Bars(_Symbol, _Period);
// ONE CANDLE LIMIT - END
     
  }

//+------------------------------------------------------------------+
//| NewGridOrder MaxPositions                                        |
//+------------------------------------------------------------------+
void NewGridOrderMaxPos(int orderType)
  {
   int ticket;

// TODO test the order progressions
   if(restAndRealize)
      return;
   if(orderType == OP_BUY)
     {
      // new hedging buy order
      if(progression == 0)
         ticket = OrderSendReliable(Symbol(), OP_BUY, min_lots, MarketInfo(Symbol(), MODE_ASK), slippage, 0, 0, key + "-" + (string)hedge_buys, magic, 0, Blue);
      if(progression == 1)
         ticket = OrderSendReliable(Symbol(), OP_BUY, max_positions * min_lots, MarketInfo(Symbol(), MODE_ASK), slippage, 0, 0, key + "-" + (string)hedge_buys, magic, 0, Blue);
      if(progression == 2)
         ticket = OrderSendReliable(Symbol(), OP_BUY, (lot_multiplicator * max_positions) * min_lots, MarketInfo(Symbol(), MODE_ASK), slippage, 0, 0, key + "-" + (string)hedge_buys, magic, 0, Blue);
      if(progression == 3)
         ticket = OrderSendReliable(Symbol(), OP_BUY, CalculateFibonacci(max_positions) * min_lots, MarketInfo(Symbol(), MODE_ASK), slippage, 0, 0, key + "-" + (string)hedge_buys, magic, 0, Blue);
     }
   else
     {
      // new hedging sell order
      if(progression == 0)
         ticket = OrderSendReliable(Symbol(), OP_SELL, buy_lots[0], MarketInfo(Symbol(), MODE_BID), slippage, 0, 0, key + "-" + (string)hedge_sells, magic, 0, Red);
      if(progression == 1)
         ticket = OrderSendReliable(Symbol(), OP_SELL, max_positions * min_lots, MarketInfo(Symbol(), MODE_BID), slippage, 0, 0, key + "-" + (string)hedge_sells, magic, 0, Red);
      if(progression == 2)
         ticket = OrderSendReliable(Symbol(), OP_SELL, (lot_multiplicator * max_positions) * min_lots, MarketInfo(Symbol(), MODE_BID), slippage, 0, 0, key + "-" + (string)hedge_sells, magic, 0, Red);
      if(progression == 3)
         ticket = OrderSendReliable(Symbol(), OP_SELL, CalculateFibonacci(max_positions) * min_lots, MarketInfo(Symbol(), MODE_BID), slippage, 0, 0, key + "-" + (string)hedge_sells, magic, 0, Red);
     }
  }

//+------------------------------------------------------------------+
//| NewHedgingOrder                                                     |
//+------------------------------------------------------------------+
void NewHedgingOrder(int orderType)
  {
   int ticket;

// TODO test the order progressions
   if(restAndRealize)
      return;
   if(orderType == OP_BUY)
     {
      // new hedging buy order
      if(progression == 0)
         ticket = OrderSendReliable(Symbol(), OP_BUY, min_lots, MarketInfo(Symbol(), MODE_ASK), slippage, 0, 0, key_hedging + "-" + (string)hedge_buys, hedge_magic, 0, Blue);
      if(progression == 1)
         ticket = OrderSendReliable(Symbol(), OP_BUY, max_positions * min_lots, MarketInfo(Symbol(), MODE_ASK), slippage, 0, 0, key_hedging + "-" + (string)hedge_buys, hedge_magic, 0, Blue);
      if(progression == 2)
         ticket = OrderSendReliable(Symbol(), OP_BUY, (lot_multiplicator * max_positions) * min_lots, MarketInfo(Symbol(), MODE_ASK), slippage, 0, 0, key_hedging + "-" + (string)hedge_buys, hedge_magic, 0, Blue);
      if(progression == 3)
         ticket = OrderSendReliable(Symbol(), OP_BUY, CalculateFibonacci(max_positions) * min_lots, MarketInfo(Symbol(), MODE_ASK), slippage, 0, 0, key_hedging + "-" + (string)hedge_buys, hedge_magic, 0, Blue);
     }
   else
     {
      // new hedging sell order
      if(progression == 0)
         ticket = OrderSendReliable(Symbol(), OP_SELL, min_lots, MarketInfo(Symbol(), MODE_BID), slippage, 0, 0, key_hedging + "-" + (string)hedge_sells, hedge_magic, 0, Red);
      if(progression == 1)
         ticket = OrderSendReliable(Symbol(), OP_SELL, max_positions * min_lots, MarketInfo(Symbol(), MODE_BID), slippage, 0, 0, key_hedging + "-" + (string)hedge_sells, hedge_magic, 0, Red);
      if(progression == 2)
         ticket = OrderSendReliable(Symbol(), OP_SELL, (lot_multiplicator * max_positions) * min_lots, MarketInfo(Symbol(), MODE_BID), slippage, 0, 0, key_hedging + "-" + (string)hedge_sells, hedge_magic, 0, Red);
      if(progression == 3)
         ticket = OrderSendReliable(Symbol(), OP_SELL, CalculateFibonacci(max_positions) * min_lots, MarketInfo(Symbol(), MODE_BID), slippage, 0, 0, key_hedging + "-" + (string)hedge_sells, hedge_magic, 0, Red);
     }
  }

//+------------------------------------------------------------------+
//|  handle Hedging order profit                                     |
//+------------------------------------------------------------------+
void handleCycleRisk()
  {

   if(cycleEquityRisk > 0)
     {

      double local_total_buy_profit = 0, local_total_sell_profit = 0;

      local_total_buy_profit = total_buy_profit;
      local_total_sell_profit = total_sell_profit;

      if(hedge_buys > 0)
        {
         // max hedge lot means this is a correction lot
         local_total_sell_profit = total_sell_profit + total_hedge_buy_profit;
        }

      // if the hedge trade is sell and it is max trade lot
      // then calculate new local_total_buy_profit with the hedge sell order
      if(hedge_sells > 0)
        {
         local_total_buy_profit = total_buy_profit + total_hedge_sell_profit;
        }

      if((cycleEquityRisk * AccountBalance()) * -1 > local_total_sell_profit)
        {
         closeAllSells();
        }

      if((cycleEquityRisk * AccountBalance()) * -1 > local_total_buy_profit)
        {
         closeAllBuys();
        }
     }
  }

//+------------------------------------------------------------------+
//|  handle Hedging order profit                                     |
//+------------------------------------------------------------------+
void handleHedging()
  {

   if(hedging_active)   // hedging is active but not open
     {
      // double hedgeAmountStart = (hedgingEquityStart * AccountBalance()) * -1;
      if(!isHedgingSellActive() && buys >= max_positions)
        {
         if(buy_profit[buys - 1] <= CalculateSL(buy_lots[buys - 1], buys))
           {
            NewHedgingOrder(OP_SELL);
            NewGridOrderMaxPos(OP_BUY);
           }
        }
      if(!isHedgingBuyActive() && sells >= max_positions)
        {
         if(sell_profit[sells - 1] <= CalculateSL(sell_lots[sells - 1], sells))
           {
            NewHedgingOrder(OP_BUY);
            NewGridOrderMaxPos(OP_SELL);
           }
        }
     }

   if(isHedgingBuyActive())
     {
      if(total_hedge_buy_profit > 0)
        {
         double sum_buy_profit = total_hedge_buy_profit + sell_profit[0]; // hedge - first order
         if(buy_max_hedge_profit == 0 && sum_buy_profit > CalculateTP(min_lots))   // fixed 10%
           {
            buy_max_hedge_profit = sum_buy_profit;
            buy_close_hedge_profit = profit_lock * sum_buy_profit;
           }

         if(buy_max_hedge_profit > 0 && sum_buy_profit > buy_max_hedge_profit)
           {
            buy_max_hedge_profit = sum_buy_profit;
            buy_close_hedge_profit = profit_lock * buy_max_hedge_profit;
           }

         if(buy_max_hedge_profit > 0 && buy_close_hedge_profit > 0
            && buy_max_hedge_profit >= buy_close_hedge_profit && sum_buy_profit < buy_close_hedge_profit)
           {
            // At this point all order are closed.
            // Global vars will be updated thanks to UpdateVars() on next start() execution
            closeBuyHedgeAndFirstSellOrder();
           }
        }
      // close heding order faster by reverse trend
if (sells >= 2) {
    if ((sell_profit[sells - 1] + sell_profit[sells - 2]) > 0) {
        double sum_buy_profit = total_hedge_buy_profit + (sell_profit[sells - 1] + sell_profit[sells - 2]);
        if (sum_buy_profit > CalculateTP(min_lots)) {
            closeBuyHedgeAndLastAndSecondLastSellOrder();
        }
    }
}

     }

   if(isHedgingSellActive())
     {
      if(total_hedge_sell_profit > 0)
        {
         double sum_sell_profit = total_hedge_sell_profit + buy_profit[0]; // hedge - first order
         if(sell_max_hedge_profit == 0 && sum_sell_profit > CalculateTP(min_lots))   // fixed 10%
           {
            sell_max_hedge_profit = sum_sell_profit;
            sell_close_hedge_profit = profit_lock * sum_sell_profit;
           }

         if(sell_max_hedge_profit > 0 && sum_sell_profit > sell_max_hedge_profit)
           {
            sell_max_hedge_profit = sum_sell_profit;
            sell_close_hedge_profit = profit_lock * sell_max_hedge_profit;
           }

         if(sell_max_hedge_profit > 0 && sell_close_hedge_profit > 0
            && sell_max_hedge_profit >= sell_close_hedge_profit && sum_sell_profit < sell_close_hedge_profit)
           {
            // At this point all order are closed.
            // Global vars will be updated thanks to UpdateVars() on next start() execution
            closeSellHedgeAndFirstBuyOrder();
           }
        }
if (buys >= 2) {
    if ((buy_profit[buys - 1] + buy_profit[buys - 2]) > 0) {
        double sum_sell_profit = total_hedge_sell_profit + buy_profit[buys - 1] + buy_profit[buys - 2];
        if (sum_sell_profit > CalculateTP(min_lots)) {
            closeSellHedgeAndLastAndSecondLastBuyOrder();
        }
    }
}

     }
  }

//+------------------------------------------------------------------+
//|  isHedgingBuyActive                                              |
//+------------------------------------------------------------------+
bool isHedgingBuyActive()
  {

   if(is_buy_hedging_order_active)
     {
      return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//|  isHedgingSellActive                                             |
//+------------------------------------------------------------------+
bool isHedgingSellActive()
  {

   if(is_sell_hedging_order_active)
     {
      return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//|  thinOutTheGrid                                                  |
//+------------------------------------------------------------------+
void thinOutTheGrid()
  {

// TODO lockProfit
// double buy_close_profit_trail_orders = 0, sell_close_profit_trail_orders = 0;
// check if max_positions is reached:
   if(buys >= partial_closing && !isHedgingSellActive())
     {
      // calculate profit of the first and last buy order
      // trail the profit of the last and first buy order
      // close the first and the last buy order at trailed profit

      if(buy_profit[buys - 1] > 0)
        {
         double buy_profit_first_and_last = buy_profit[buys - 1] + buy_profit[0];
         if(buy_profit_first_and_last > CalculateTP(buy_lots[0]))
           {
            closeLastAndFirstBuyOrder();
           }
        }
     }

   if(sells >= partial_closing && !isHedgingBuyActive())
     {
      // calculate profit of the first and last sell order
      // trail the profit of the last and first sell order
      // close the first and the last sell order at trailed profit

      if(sell_profit[sells - 1] > 0)
        {
         double sell_profit_first_and_last = sell_profit[sells - 1] + sell_profit[0];
         if(sell_profit_first_and_last > CalculateTP(sell_lots[0]))
           {
            closeLastAndFirstSellOrder();
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum enObjectOperation
  {
   LODraw = 0,
   LODelete = 1
  };

//+---------------------------------------------------------------------------+
//  Buy and Sell methods
//+---------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//  Bollinger Bands trigger                                          |
//+------------------------------------------------------------------+
bool BB_Buy()
  {
   double BBL = iBands(Symbol(), BB_tf, BB_Period, BB_Dev, 0, PRICE_CLOSE, MODE_LOWER, BB_Shift);
   double BBU = iBands(Symbol(), BB_tf, BB_Period, BB_Dev, 0, PRICE_CLOSE, MODE_UPPER, BB_Shift);
   if(!BB_invert)
     {
      if(BB_Mod == ASK_BID && Ask < BBL)
         return(true);
      if(BB_Mod == HIGH_LOW && Low[0] < BBL)
         return(true);
      return(false);
     }
   else
     {
      if(BB_Mod == ASK_BID && Ask > BBU)
         return(true);
      if(BB_Mod == HIGH_LOW && Low[0] > BBU)
         return(true);
      return(false);
     }
  }

//+------------------------------------------------------------------+
//|  Bollinger Bands                                                 |
//+------------------------------------------------------------------+
bool BB_Sell()
  {
  // Bollinger Bands
   double BBL = iBands(Symbol(), BB_tf, BB_Period, BB_Dev, 0, PRICE_CLOSE, MODE_LOWER, BB_Shift);
   double BBU = iBands(Symbol(), BB_tf, BB_Period, BB_Dev, 0, PRICE_CLOSE, MODE_UPPER, BB_Shift);
   if(!BB_invert)
     {
      if(BB_Mod == ASK_BID && Bid > BBU)
         return(true);
      if(BB_Mod == HIGH_LOW && High[0] > BBU)
         return(true);
      return(false);
     }
   else
     {
      if(BB_Mod == ASK_BID && Bid < BBL)
         return(true);
      if(BB_Mod == HIGH_LOW && High[0] < BBL)
         return(true);
      return(false);
     }
  }

//+------------------------------------------------------------------+
//  Stochastic trigger
//+------------------------------------------------------------------+
bool STO_Buy()
  {
   double Sto_Value = iStochastic(Symbol(), Stoch_tf, Stoch_K, Stoch_D, Stoch_Slowing, Stoch_Method, Stoch_Price, MODE_SIGNAL, Stoch_Shift);
   if(!STO_invert)
     {
      if(Sto_Value < Stoch_Lower)
         return(true);
      return(false);
     }
   else
     {
      if(Sto_Value > Stoch_Lower && Sto_Value < Stoch_Upper)
         return(true);
      return(false);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool STO_Sell()
  {
   double Sto_Value = iStochastic(Symbol(), Stoch_tf, Stoch_K, Stoch_D, Stoch_Slowing, Stoch_Method, Stoch_Price, MODE_SIGNAL, Stoch_Shift);
   if(!STO_invert)
     {
      if(Sto_Value > Stoch_Upper)
         return(true);
      return(false);
     }
   else
     {
      if(Sto_Value > Stoch_Lower && Sto_Value < Stoch_Upper)
         return(true);
      return(false);
     }
  }

//+------------------------------------------------------------------+
//  RSI trigger
//+------------------------------------------------------------------+
bool RSI_Buy()
  {
   double RSI_Value = iRSI(Symbol(), RSI_tf, RSI_Period, PRICE_CLOSE, RSI_Shift);
   if(!RSI_invert)
     {
      if(RSI_Value < RSI_Lower)
         return(true);
      return(false);
     }
   else
     {
      if(RSI_Value > RSI_Lower && RSI_Value < RSI_Upper)
         return(true);
      return(false);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RSI_Sell()
  {
   double RSI_Value = iRSI(Symbol(), RSI_tf, RSI_Period, PRICE_CLOSE, RSI_Shift);
   if(!RSI_invert)
     {
      if(RSI_Value > RSI_Upper)
         return(true);
      return(false);
     }
   else
     {
      if(RSI_Value > RSI_Lower && RSI_Value < RSI_Upper)
         return(true);
      return(false);
     }
  }

//+------------------------------------------------------------------+
//  CCI - Commodity Channel Index trigger                            |
//+------------------------------------------------------------------+
bool CCI_Buy()
  {
   double CCI_Value = iCCI(Symbol(), CCI_tf, CCI_Period, PRICE_CLOSE, CCI_Shift);
   if(!CCI_invert)
     {
      if(CCI_Value < CCI_Lower)
         return(true);
      return(false);
     }
   else
     {
      if(CCI_Value > CCI_Lower && CCI_Value < CCI_Upper)
         return(true);
      return(false);
     }
  }
  
//+------------------------------------------------------------------+
//  CCI - Commodity Channel Index trigger                            |
//+------------------------------------------------------------------+
bool CCI_Sell()
  {
   double CCI_Value = iCCI(Symbol(), CCI_tf, CCI_Period, PRICE_CLOSE, CCI_Shift);
   if(!CCI_invert)
     {
      if(CCI_Value > CCI_Upper)
         return(true);
      return(false);
     }
   else
     {
      if(CCI_Value > CCI_Lower && CCI_Value < CCI_Upper)
         return(true);
      return(false);
     }
  }
  

//+------------------------------------------------------------------+
//  C1 - Custom Indicator 1 trigger
//+------------------------------------------------------------------+
bool C1_Buy()
{
if (Use_C1) {
    double customIndicator1BuyValue = iCustom(NULL, 0, C1_Name, C1_BuyBuffer, 0);
    double customIndicator1SellValue = iCustom(NULL, 0, C1_Name, C1_SellBuffer, 0);
}
   double buySignal;
   if (C1_Wait) {buySignal = iCustom(NULL, 0, C1_Name, C1_BuyBuffer, 1);} 
   else         {buySignal = iCustom(NULL, 0, C1_Name, C1_BuyBuffer, 0);}
   
if (C1_Type == Empty_Indicator) {
    if (C1_Invert) {
        if (buySignal != EMPTY_VALUE) {
        if (C1_Exit) {closeAllSells();}
            return true;
        } else {
            return false;
        }
    } else {
        if (buySignal == EMPTY_VALUE) {
        if (C1_Exit) {closeAllSells();}
            return true;
        } else {
            return false;
        }
    }
    } else if (C1_Type == Value_Indicator) {
        if(!C1_Invert){
            if (buySignal > C1_BuyValue) {
            if (C1_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        } else {
            if (buySignal < C1_BuyValue) {
            if (C1_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        }
    } else if (C1_Type == Price_Indicator) {
        if(!C1_Invert){
            if (Close[0] < buySignal) {
            if (C1_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        } else {
            if (Close[0] > buySignal) {
            if (C1_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        }
    } else if (C1_Type == Cross_Indicator) {
    double bufferValue;
    if (C1_Wait) {
        bufferValue = iCustom(NULL, 0, C1_Name, C1_BuyBuffer, 0);
        if(!C1_Invert){
            if (Close[2] < bufferValue && Close[1] > bufferValue) {
            if (C1_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        } else {
            if (Close[2] > bufferValue || Close[1] < bufferValue) {
            if (C1_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        }
    } else {
        bufferValue = iCustom(NULL, 0, C1_Name, C1_BuyBuffer, 0);
        if(!C1_Invert){
            if (Open[0] < bufferValue && Close[0] > bufferValue) {
            if (C1_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        } else {
            if (Open[0] > bufferValue || Close[0] < bufferValue) {
            if (C1_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        }
    }
}
    return false;
}

bool C1_Sell()
{

   double sellSignal;
   if (C1_Wait) {sellSignal = iCustom(NULL, 0, C1_Name, C1_SellBuffer, 1);} 
   else         {sellSignal = iCustom(NULL, 0, C1_Name, C1_SellBuffer, 0);}
   
if (C1_Type == Empty_Indicator) {
    if (C1_Invert) {
        if (sellSignal != EMPTY_VALUE) {
        if (C1_Exit) {closeAllBuys();}
            return true;
        } else {
            return false;
        }
    } else {
        if (sellSignal == EMPTY_VALUE) {
        if (C1_Exit) {closeAllBuys();}
            return true;
        } else {
            return false;
        }
    }
    } else if (C1_Type == Value_Indicator) {
        if(!C1_Invert){
            if (sellSignal > C1_SellValue) {
            if (C1_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        } else {
            if (sellSignal < C1_SellValue) {
            if (C1_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        }
    } else if (C1_Type == Price_Indicator) {
        if(!C1_Invert){
            if (Close[0] > sellSignal) {
            if (C1_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        } else {
            if (Close[0] < sellSignal) {
            if (C1_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        }
    } else if (C1_Type == Cross_Indicator) {
    double bufferValue;
    if (C1_Wait) {
        bufferValue = iCustom(NULL, 0, C1_Name, C1_SellBuffer, 0);
        if(!C1_Invert){
            if (Close[2] > bufferValue && Close[1] < bufferValue) {
            if (C1_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        } else {
            if (Close[2] < bufferValue || Close[1] > bufferValue) {
            if (C1_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        }
    } else {
        bufferValue = iCustom(NULL, 0, C1_Name, C1_SellBuffer, 0);
        if(!C1_Invert){
            if (Open[0] > bufferValue && Close[0] < bufferValue) {
            if (C1_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        } else {
            if (Open[0] < bufferValue || Close[0] > bufferValue) {
            if (C1_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        }
    }
}
    return false;
}


//+------------------------------------------------------------------+
//  C2 - Custom Indicator 2 trigger
//+------------------------------------------------------------------+
bool C2_Buy()
{
if (Use_C2) {
    double customIndicator1BuyValue = iCustom(NULL, 0, C2_Name, C2_BuyBuffer, 0);
    double customIndicator1SellValue = iCustom(NULL, 0, C2_Name, C2_SellBuffer, 0);
}
   double buySignal;
   if (C2_Wait) {buySignal = iCustom(NULL, 0, C2_Name, C2_BuyBuffer, 1);} 
   else         {buySignal = iCustom(NULL, 0, C2_Name, C2_BuyBuffer, 0);}
   
if (C2_Type == Empty_Indicator) {
    if (C2_Invert) {
        if (buySignal != EMPTY_VALUE) {
        if (C2_Exit) {closeAllSells();}
            return true;
        } else {
            return false;
        }
    } else {
        if (buySignal == EMPTY_VALUE) {
        if (C2_Exit) {closeAllSells();}
            return true;
        } else {
            return false;
        }
    }
    } else if (C2_Type == Value_Indicator) {
        if(!C2_Invert){
            if (buySignal > C2_BuyValue) {
            if (C2_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        } else {
            if (buySignal < C2_BuyValue) {
            if (C2_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        }
    } else if (C2_Type == Price_Indicator) {
        if(!C2_Invert){
            if (Close[0] < buySignal) {
            if (C2_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        } else {
            if (Close[0] > buySignal) {
            if (C2_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        }
    } else if (C2_Type == Cross_Indicator) {
    double bufferValue;
    if (C2_Wait) {
        bufferValue = iCustom(NULL, 0, C2_Name, C2_BuyBuffer, 0);
        if(!C2_Invert){
            if (Close[2] < bufferValue && Close[1] > bufferValue) {
            if (C2_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        } else {
            if (Close[2] > bufferValue || Close[1] < bufferValue) {
            if (C2_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        }
    } else {
        bufferValue = iCustom(NULL, 0, C2_Name, C2_BuyBuffer, 0);
        if(!C2_Invert){
            if (Open[0] < bufferValue && Close[0] > bufferValue) {
            if (C2_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        } else {
            if (Open[0] > bufferValue || Close[0] < bufferValue) {
            if (C2_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        }
    }
}
    return false;
}

bool C2_Sell()
{

   double sellSignal;
   if (C2_Wait) {sellSignal = iCustom(NULL, 0, C2_Name, C2_SellBuffer, 1);} 
   else         {sellSignal = iCustom(NULL, 0, C2_Name, C2_SellBuffer, 0);}
   
if (C2_Type == Empty_Indicator) {
    if (C2_Invert) {
        if (sellSignal != EMPTY_VALUE) {
        if (C2_Exit) {closeAllBuys();}
            return true;
        } else {
            return false;
        }
    } else {
        if (sellSignal == EMPTY_VALUE) {
        if (C2_Exit) {closeAllBuys();}
            return true;
        } else {
            return false;
        }
    }
    } else if (C2_Type == Value_Indicator) {
        if(!C2_Invert){
            if (sellSignal > C2_SellValue) {
            if (C2_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        } else {
            if (sellSignal < C2_SellValue) {
            if (C2_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        }
    } else if (C2_Type == Price_Indicator) {
        if(!C2_Invert){
            if (Close[0] > sellSignal) {
            if (C2_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        } else {
            if (Close[0] < sellSignal) {
            if (C2_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        }
    } else if (C2_Type == Cross_Indicator) {
    double bufferValue;
    if (C2_Wait) {
        bufferValue = iCustom(NULL, 0, C2_Name, C2_SellBuffer, 0);
        if(!C2_Invert){
            if (Close[2] > bufferValue && Close[1] < bufferValue) {
            if (C2_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        } else {
            if (Close[2] < bufferValue || Close[1] > bufferValue) {
            if (C2_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        }
    } else {
        bufferValue = iCustom(NULL, 0, C2_Name, C2_SellBuffer, 0);
        if(!C2_Invert){
            if (Open[0] > bufferValue && Close[0] < bufferValue) {
            if (C2_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        } else {
            if (Open[0] < bufferValue || Close[0] > bufferValue) {
            if (C2_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        }
    }
}
    return false;
}

//+------------------------------------------------------------------+
//  C3 - Custom Indicator 3 trigger
//+------------------------------------------------------------------+
bool C3_Buy()
{
if (Use_C3) {
    double customIndicator1BuyValue = iCustom(NULL, 0, C3_Name, C3_BuyBuffer, 0);
    double customIndicator1SellValue = iCustom(NULL, 0, C3_Name, C3_SellBuffer, 0);
}
   double buySignal;
   if (C3_Wait) {buySignal = iCustom(NULL, 0, C3_Name, C3_BuyBuffer, 1);} 
   else         {buySignal = iCustom(NULL, 0, C3_Name, C3_BuyBuffer, 0);}
   
if (C3_Type == Empty_Indicator) {
    if (C3_Invert) {
        if (buySignal != EMPTY_VALUE) {
        if (C3_Exit) {closeAllSells();}
            return true;
        } else {
            return false;
        }
    } else {
        if (buySignal == EMPTY_VALUE) {
        if (C3_Exit) {closeAllSells();}
            return true;
        } else {
            return false;
        }
    }
    } else if (C3_Type == Value_Indicator) {
        if(!C3_Invert){
            if (buySignal > C3_BuyValue) {
            if (C3_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        } else {
            if (buySignal < C3_BuyValue) {
            if (C3_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        }
    } else if (C3_Type == Price_Indicator) {
        if(!C3_Invert){
            if (Close[0] < buySignal) {
            if (C3_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        } else {
            if (Close[0] > buySignal) {
            if (C3_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        }
    } else if (C3_Type == Cross_Indicator) {
    double bufferValue;
    if (C3_Wait) {
        bufferValue = iCustom(NULL, 0, C3_Name, C3_BuyBuffer, 0);
        if(!C3_Invert){
            if (Close[2] < bufferValue && Close[1] > bufferValue) {
            if (C3_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        } else {
            if (Close[2] > bufferValue || Close[1] < bufferValue) {
            if (C3_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        }
    } else {
        bufferValue = iCustom(NULL, 0, C3_Name, C3_BuyBuffer, 0);
        if(!C3_Invert){
            if (Open[0] < bufferValue && Close[0] > bufferValue) {
            if (C3_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        } else {
            if (Open[0] > bufferValue || Close[0] < bufferValue) {
            if (C3_Exit) {closeAllSells();}
                return true;
            } else {
                return false;
            }
        }
    }
}
    return false;
}

bool C3_Sell()
{

   double sellSignal;
   if (C3_Wait) {sellSignal = iCustom(NULL, 0, C3_Name, C3_SellBuffer, 1);} 
   else         {sellSignal = iCustom(NULL, 0, C3_Name, C3_SellBuffer, 0);}
   
if (C3_Type == Empty_Indicator) {
    if (C3_Invert) {
        if (sellSignal != EMPTY_VALUE) {
        if (C3_Exit) {closeAllBuys();}
            return true;
        } else {
            return false;
        }
    } else {
        if (sellSignal == EMPTY_VALUE) {
        if (C3_Exit) {closeAllBuys();}
            return true;
        } else {
            return false;
        }
    }
    } else if (C3_Type == Value_Indicator) {
        if(!C3_Invert){
            if (sellSignal > C3_SellValue) {
            if (C3_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        } else {
            if (sellSignal < C3_SellValue) {
            if (C3_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        }
    } else if (C3_Type == Price_Indicator) {
        if(!C3_Invert){
            if (Close[0] > sellSignal) {
            if (C3_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        } else {
            if (Close[0] < sellSignal) {
            if (C3_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        }
    } else if (C3_Type == Cross_Indicator) {
    double bufferValue;
    if (C3_Wait) {
        bufferValue = iCustom(NULL, 0, C3_Name, C3_SellBuffer, 0);
        if(!C3_Invert){
            if (Close[2] > bufferValue && Close[1] < bufferValue) {
            if (C3_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        } else {
            if (Close[2] < bufferValue || Close[1] > bufferValue) {
            if (C3_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        }
    } else {
        bufferValue = iCustom(NULL, 0, C3_Name, C3_SellBuffer, 0);
        if(!C3_Invert){
            if (Open[0] > bufferValue && Close[0] < bufferValue) {
            if (C3_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        } else {
            if (Open[0] < bufferValue || Close[0] > bufferValue) {
            if (C3_Exit) {closeAllBuys();}
                return true;
            } else {
                return false;
            }
        }
    }
}
    return false;
}


//+------------------------------------------------------------------+
//  ATR Grid Size
//+------------------------------------------------------------------+
double ATR_Grid_Size()
  {
   int digits, scale = 10000;
   digits = (int)MarketInfo(Symbol(), MODE_DIGITS);

   if(digits == 3 || digits == 2)
      scale = 100;
   if(Use_ATR &&  NewBarTF(ATR_tf))
     {
      return ((int)round(ATR_Multiplier * scale * iATR(Symbol(), ATR_tf, ATR_Period, 0)));
     }
   else
     {
      return grid_size;
     }
  }


//+--------------------------------------------------+
//  Indicators Triggered
//+--------------------------------------------------+
bool Indicators_Buy()
{
   bool BB_ret, STO_ret, RSI_ret, CCI_ret, C1_ret, C2_ret, C3_ret;
   if(Conjunct_Idx)
   {
      BB_ret = true;
      STO_ret = true;
      RSI_ret = true;
      CCI_ret = true;
      C1_ret = true;
      C2_ret = true;
      C3_ret = true;
      if(Use_BB)
         BB_ret = BB_Buy();
      if(Use_Stoch)
         STO_ret = STO_Buy();
      if(Use_RSI)
         RSI_ret = RSI_Buy();
      if(Use_CCI)
         CCI_ret = CCI_Buy();
      if(Use_C1)
         C1_ret = C1_Buy();
      if(Use_C2)
         C2_ret = C2_Buy();
      if(Use_C3)
         C3_ret = C3_Buy();
      if(BB_ret && STO_ret && RSI_ret && CCI_ret && C1_ret && C2_ret && C3_ret)
         return (true);
      return(false);
   }
   else
   {
      if(Use_BB)
         BB_ret = BB_Buy();
      else
         BB_ret = false;
      if(Use_Stoch)
         STO_ret = STO_Buy();
      else
         STO_ret = false;
      if(Use_RSI)
         RSI_ret = RSI_Buy();
      else
         RSI_ret = false;
      if(Use_CCI)
         CCI_ret = CCI_Buy();
      else
         CCI_ret = false;
      if(Use_C1)
         C1_ret = C1_Buy();
      else
         C1_ret = false;
      if(Use_C2)
         C2_ret = C2_Buy();
      else
         C2_ret = false;
      if(Use_C3)
         C3_ret = C3_Buy();
      else
         C3_ret = false;
      if(BB_ret || STO_ret || RSI_ret || CCI_ret || C1_ret || C2_ret || C3_ret)
         return (true);
      return(false);
   }
   return (false);
}

//+--------------------------------------------------+
//|                                                                  |
//+--------------------------------------------------+
bool Indicators_Sell()
{
   bool BB_ret, STO_ret, RSI_ret, CCI_ret, C1_ret, C2_ret, C3_ret;
   if(Conjunct_Idx)
   {
      BB_ret = true;
      STO_ret = true;
      RSI_ret = true;
      CCI_ret = true;
      C1_ret = true;
      C2_ret = true;
      C3_ret = true;
      if(Use_BB)
         BB_ret = BB_Sell();
      if(Use_Stoch)
         STO_ret = STO_Sell();
      if(Use_RSI)
         RSI_ret = RSI_Sell();
      if(Use_CCI)
         CCI_ret = CCI_Sell();
      if(Use_C1)
         C1_ret = C1_Sell();
      if(Use_C2)
         C2_ret = C2_Sell();
      if(Use_C3)
         C3_ret = C3_Sell();
      if(BB_ret && STO_ret && RSI_ret && CCI_ret && C1_ret && C2_ret && C3_ret)
         return (true);
      return(false);
   }
   else
   {
      if(Use_BB)
         BB_ret = BB_Sell();
      else
         BB_ret = false;
      if(Use_Stoch)
         STO_ret = STO_Sell();
      else
         STO_ret = false;
      if(Use_RSI)
         RSI_ret = RSI_Sell();
      else
         RSI_ret = false;
      if(Use_CCI)
         CCI_ret = CCI_Sell();
      else
         CCI_ret = false;
      if(Use_C1)
         C1_ret = C1_Sell();
      else
         C1_ret = false;
      if(Use_C2)
         C2_ret = C2_Sell();
      else
         C2_ret = false;
      if(Use_C3)
         C3_ret = C3_Sell();
      else
         C3_ret = false;
      if(BB_ret || STO_ret || RSI_ret || CCI_ret || C1_ret || C2_ret || C3_ret)
         return (true);
      return(false);
   }
   return (false);
}



//+---------------------------------------------------------------------------+
//  Show Data on screen
//+---------------------------------------------------------------------------+

// ------------------------------------------------------------------------------------------------
// SHOW DATA
// ------------------------------------------------------------------------------------------------
void showData()
  {

   string txt;
   string cycleRisktext = "";
   double aux_tp_buy = 0, aux_tp_sell = 0;
// #002: correct message of fibo progression
   string info_money_management[4];
   string info_activation[2];

   info_money_management[0] = "min_lots";
   info_money_management[1] = "D´Alembert";
   info_money_management[2] = "Martingale";
   info_money_management[3] = "Fibonacci";
   info_activation[0] = "Disabled";
   info_activation[1] = "Enabled";

   if(buys <= 1)
      aux_tp_buy = CalculateTP(buy_lots[0]);
   else
      if(progression == 0)
         aux_tp_buy = CalculateTP(buy_lots[0]);
      else
         if(progression == 1)
            aux_tp_buy = buys * CalculateTP(buy_lots[0]);
         else
            if(progression == 2)
               aux_tp_buy = CalculateTP(buy_lots[buys - 1]);
            else
               if(progression == 3)
                  aux_tp_buy = CalculateTP(buy_lots[buys - 1]);

   if(sells <= 1)
      aux_tp_sell = CalculateTP(sell_lots[0]);
   else
      if(progression == 0)
         aux_tp_sell = CalculateTP(sell_lots[0]);
      else
         if(progression == 1)
            aux_tp_sell = sells * CalculateTP(sell_lots[0]);
         else
            if(progression == 2)
               aux_tp_sell = CalculateTP(sell_lots[sells - 1]);
            else
               if(progression == 3)
                  aux_tp_sell = CalculateTP(sell_lots[sells - 1]);

// #008: use progression for grid size as well as volume
   string info_gs_progression;
   if(gs_progression == 0)
     {
      info_gs_progression = "Grid Prog.: Disabled";
     }
   else
     {
      info_gs_progression = "Grid Prog.: " + info_money_management[gs_progression];
     }

   if(cycleEquityRisk > 0)
     {
      cycleRisktext =  "Cycle Risk: " + DoubleToStr(100 * cycleEquityRisk, 2) + "%";
     }
   else
     {
      cycleRisktext =  "Cycle Risk: Off";
     }

// #051: change info of panel and comment
//   txt = "\n" + versionBMI +
//         "\nServer Time: " + TimeToStr(ter_timeNow, TIME_DATE | TIME_SECONDS) +
//         "\n" +
//         "\nBUY ORDERS" +
//         "\nNumber of orders: " + (string)buys +
//         "\nTotal lots: " + DoubleToStr(total_buy_lots, 2) +
//         "\nProfit goal: " + ter_currencySymbol + DoubleToStr(aux_tp_buy, 2) +
//         "\nMaximum profit reached: " + ter_currencySymbol + DoubleToStr(buy_max_profit, 2) +
//         "\nProfit locked: " + ter_currencySymbol + DoubleToStr(buy_close_profit, 2) +
//         "\nSellHedging: " + ter_currencySymbol + DoubleToStr(total_hedge_sell_profit, 2) +
//         "\n" +
//         "\nSELL ORDERS" +
//         "\nNumber of orders: " + (string)sells +
//         "\nTotal lots: " + DoubleToStr(total_sell_lots, 2) +
//         "\nProfit goal: " + ter_currencySymbol + DoubleToStr(aux_tp_sell, 2) +
//         "\nMaximum profit reached: " + ter_currencySymbol + DoubleToStr(sell_max_profit, 2) +
//         "\nProfit locked: " + ter_currencySymbol + DoubleToStr(sell_close_profit, 2) +
//         "\nBuyHedging: " + ter_currencySymbol + DoubleToStr(total_hedge_buy_profit, 2)
//         + "\n";
//
//   if(line_margincall > 0)
//      txt += "\nLine: \"margin call\": " + DoubleToString(line_margincall, 3);
//
//// #038: give user info, why account state is yellow or red
//   if(codeYellowMsg != "")
//      txt += "\n" + codeYellowMsg;
//   if(codeRedMsg != "")
//      txt += "\n" + codeRedMsg;
//
//   txt +=
//      "\nCurrent drawdown: " + DoubleToString((max_equity - AccountEquity()), 2) + " " + ter_currencySymbol + " (" + DoubleToString((max_equity - AccountEquity()) / max_equity * 100, 2) + " %)" +
//      "\nMax. drawdown: " + DoubleToString(max_float, 2) + " " + ter_currencySymbol +
//      "\n\nSETTINGS: " +
//      "\nGrid size: " + (string)grid_size +
//      info_gs_progression +
//      "\nTake profit: " + (string)take_profit +
//      "\nProfit locked: " + DoubleToStr(100 * profit_lock, 2) + "%" +
//      "\nMinimum lots: " + DoubleToStr(min_lots, 2) +
//      "\nEquity warning: " + DoubleToStr(100 * equity_warning, 2) + "%" +
//      "\nAccount risk: " + DoubleToStr(100 * account_risk, 2) + "%" +
//      cycleRisktext +
//      "\nProgression: " + info_money_management[progression] +
//      "\nMax Positions: " + (string)max_positions +
//      "\nTradeTime: " + (string)Time_to_Trade() +
//// #004 new setting: max_spread; trades only, if spread <= max spread:
//      "\nMax Spread: " +(string)max_spread + " pts; actual spread: " + (string)MarketInfo(Symbol(), MODE_SPREAD) + " pts";
//---
//---

   ObjectSetInteger(0, "btnShowComment", OBJPROP_STATE, 0);   // switch color back to not selected
   if(showComment)
     {
      // #050: show/hide buttons together with comment
      if(ObjectFind(0, "btnhedgeBuy") == -1)
        {
         DrawButton("btnhedgeBuy", "Open Buy", btnLeftAxis, btnTopAxis, btnWidth, btnHeight, false, colNeutral, clrBlack);
         DrawButton("btnhedgeSell", "Open Sell", btnLeftAxis + btnNextLeft, btnTopAxis, btnWidth, btnHeight, false, colNeutral, clrBlack);
         DrawButton("btnCloseLastBuy", "Close Last Buy", btnLeftAxis, btnTopAxis + btnNextTop, btnWidth, btnHeight, false, colNeutral, clrBlack);
         DrawButton("btnCloseLastSell", "Close Last Sell", btnLeftAxis + btnNextLeft, btnTopAxis + btnNextTop, btnWidth, btnHeight, false, colNeutral, clrBlack);
         DrawButton("btnCloseAllBuys", "Close All Buys", btnLeftAxis, btnTopAxis + 2 * btnNextTop, btnWidth, btnHeight, false, colNeutral, clrBlack);
         DrawButton("btnCloseAllSells", "Close All Sells", btnLeftAxis + btnNextLeft, btnTopAxis + 2 * btnNextTop, btnWidth, btnHeight, false, colNeutral, clrBlack);
         DrawButton("btnShowComment", "Show/Hide Comment", 5, btnTopAxis, btnWidth * 2, btnHeight, false, colNeutral, colCodeYellow);

         DrawButton("btnstopNextCycle", "Stop Next Cycle", btnLeftAxis + 2 * btnNextLeft, btnTopAxis, (int)(btnWidth * 1.5), btnHeight, false, colNeutral, clrBlack);
         DrawButton("btnrestAndRealize", "Rest & Realize", btnLeftAxis + 2 * btnNextLeft, btnTopAxis + btnNextTop, (int)(btnWidth * 1.5), btnHeight, false, colNeutral, clrBlack);
         DrawButton("btnStopAll", "Stop & Close", btnLeftAxis + 2 * btnNextLeft, btnTopAxis + 2 * btnNextTop, (int)(btnWidth * 1.5), btnHeight, false, colNeutral, clrBlack);
        }

      // set state off all buttons to: Not Selected
      ObjectSetInteger(0, "btnhedgeBuy", OBJPROP_STATE, 0);   // switch color back to not selected
      ObjectSetInteger(0, "btnhedgeSell", OBJPROP_STATE, 0);   // switch color back to not selected
      ObjectSetInteger(0, "btnCloseLastBuy", OBJPROP_STATE, 0);   // switch color back to not selected
      ObjectSetInteger(0, "btnCloseLastSell", OBJPROP_STATE, 0);   // switch color back to not selected
      ObjectSetInteger(0, "btnCloseAllBuys", OBJPROP_STATE, 0);   // switch color back to not selected
      ObjectSetInteger(0, "btnCloseAllSells", OBJPROP_STATE, 0);   // switch color back to not selected

      ObjectSetInteger(0, "btnstopNextCycle", OBJPROP_STATE, 0);   // switch color back to not selected
      ObjectSetInteger(0, "btnrestAndRealize", OBJPROP_STATE, 0);   // switch color back to not selected
      ObjectSetInteger(0, "btnStopAll", OBJPROP_STATE, 0);   // switch color back to not selected
      //
      // #019: implement button: Stop On Next Cycle
      if(stopNextCycle)
        {
         SetButtonText("btnstopNextCycle", "Continue");
         // set color to red, if everything is closed
         if(sells + buys == 0)
           {
            SetButtonColor("btnstopNextCycle", colCodeRed, colFontLight);
           }
         else
           {
            SetButtonColor("btnstopNextCycle", colCodeYellow, colFontDark);
           }
        }
      else
        {
         SetButtonText("btnstopNextCycle", "Stop Next Cycle");
         SetButtonColor("btnstopNextCycle", colPauseButtonPassive, colFontLight);
        }

      // #011 #018: implement button: Stop On Next Cycle
      if(restAndRealize)
        {
         SetButtonText("btnrestAndRealize", "Continue");
         if(sells + buys == 0)
           {
            SetButtonColor("btnrestAndRealize", colCodeRed, colFontLight);
           }
         else
           {
            SetButtonColor("btnrestAndRealize", colCodeYellow, colFontDark);
           }
        }
      else
        {
         SetButtonText("btnrestAndRealize", "Rest & Realize");
         SetButtonColor("btnrestAndRealize", colPauseButtonPassive, colFontLight);
        }

      // #010: implement button: Stop & Close
      if(stopAll)
        {
         SetButtonText("btnStopAll", "Continue");
         SetButtonColor("btnStopAll", colCodeRed, colFontLight);
        }
      else
        {
         SetButtonText("btnStopAll", "Stop & Close");
         SetButtonColor("btnStopAll", colPauseButtonPassive, colFontLight);
        }

     }
   else
     {
      DeleteButton("btnStopAll");
      DeleteButton("btnrestAndRealize");
      DeleteButton("btnstopNextCycle");

      DeleteButton("btnhedgeBuy");
      DeleteButton("btnhedgeSell");
      DeleteButton("btnCloseLastBuy");
      DeleteButton("btnCloseLastSell");
      DeleteButton("btnCloseAllBuys");
      DeleteButton("btnCloseAllSells");
     }

#ifdef DEBUG
// #014: debug out at the end of comment string; will be updated each program loop
   debugCommentDyn +=
      "Ikarus Channel: " + DoubleToStr(ter_IkarusChannel, 0) +
      "\n" +
//"\nPrice Buy: "+DoubleToStr(ter_priceBuy,ter_digits)+
//"\nPrice Sell: "+DoubleToStr(ter_priceSell,ter_digits)+
      "\nTick Value: " +DoubleToStr(ter_tick_value, ter_digits) +
      "\nTick Size: " + DoubleToStr(ter_tick_size, ter_digits) +
      "\nPoint: " + DoubleToStr(ter_point, ter_digits) +
      "\nDigits: " + ter_digits +
      "\n" +
      "\nTicks/Grid Size: " + DoubleToStr(ter_ticksPerGrid, ter_digits) +
      "\nRelative Volume: " + DoubleToString(relativeVolume, 2) + " Lot" +
      "\nAct. Price/Tick: " + DoubleToString(CalculatePriceByTickDiff(relativeVolume, ter_tick_size), ter_digits) + ter_currencySymbol +
      "\nAct. Ticks/1,- " + ter_currencySymbol + ": " + DoubleToString(CalculateTicksByPrice(relativeVolume, 1), ter_digits) +
      "\n" +
      debugCommentCloseBuys +
      debugCommentCloseSells +
//"\n"+
//"\n\nMargins for 1 Lot:"
//"\nMODE_MARGINHEDGED: "+DoubleToString(MarketInfo(Symbol(),MODE_MARGINHEDGED)/AccountLeverage(),2)+
//"\nMODE_MARGININIT: "+DoubleToString(MarketInfo(Symbol(),MODE_MARGININIT)/AccountLeverage(),2)+
//"\nMODE_MARGINMAINTENANCE: "+DoubleToString(MarketInfo(Symbol(),MODE_MARGINMAINTENANCE)/AccountLeverage(),2)+
//"\nMODE_MARGINREQUIRED: "+DoubleToString(MarketInfo(Symbol(),MODE_MARGINREQUIRED),2)+
//"\nAccountLeverage: "+DoubleToString(AccountLeverage(),2)+
//"\nBalance: "+DoubleToString(AccountBalance(),2)+
//"\nEquity: "+DoubleToString(AccountEquity(),2)+
//"\nMargin: "+DoubleToString(AccountMargin(),5)+
//"\nFree Margin: "+DoubleToString(AccountFreeMargin(),2)+
//"\nNext Margin: "+DoubleToString(CalculateNextMargin(),2)+
//"\n"+
//"\nLineBuyTmp: "+DoubleToString(line_buy_tmp,ter_digits)+
//"\nLineSellTmp: "+DoubleToString(line_sell_tmp,ter_digits)+
//"\nLineBuyNext: "+DoubleToString(line_buy_next,ter_digits)+
//"\nLineSellNext: "+DoubleToString(line_sell_next,ter_digits)+
//"\nLineBuyTS: "+DoubleToString(line_buy_ts,ter_digits)+
//"\nLineSellTS: "+DoubleToString(line_sell_ts,ter_digits)+
      "";
//"\n: "++
//"\n: "+DoubleToString(,2)+

   if(showComment)
      Comment("\n\n" + txt + "\n\nDebug info (switch of in code):" + debugCommentStat + debugCommentDyn);
   else
      Comment("");
#else
   if(showComment)
      Comment("\n\n" + txt);
   else
      Comment("");
#endif

// #047: trade info panel (right upper corner)

      string chartSymbol = Symbol();
      string chartTimeFrame = TimeFrameToString(Period());
      string chartInfo = chartSymbol + ":" + chartTimeFrame;
      Write("panel_1_01", chartInfo, 5, 5, "Roboto Black", 25, clrWhite);

if(show_profit) {

      double CurrencyMultiplier; // Initialize variable according to base currency of trading platform
      if (StringFind(Symbol(), "JPY") >= 0) { CurrencyMultiplier = 100; } // Adjustment for JPY
      else if (StringFind(Symbol(), "XAU") >= 0) { CurrencyMultiplier = 10; } // Adjustment for XAU
      else {CurrencyMultiplier = 10000; } // Default setting for non-JPY/XAU currencies
      double ATR_D1 = iATR(Symbol(), PERIOD_D1, 10, 0); // calculate ATR on D1 for the last 10 days
      string ATR_Value = StringFormat("%.1f", ATR_D1 * CurrencyMultiplier); // format ATR with 1 decimal place, multiplied by appropriate factor
      Write("panel_1_02", "ADR: " + ATR_Value + " - ", 139, 42, "Roboto Condensed", 10, colFontGray);
      
      Write("panel_1_03", " - " + DoubleToString(CalculatePriceByTickDiff(relativeVolume, ter_tick_size * 10), 2) + ter_currencySymbol + "/pip -", 75, 42, "Roboto Condensed", 10, colFontGray);
      
      if(ter_spread > max_spread) Write("panel_1_04", "- Spread: " + DoubleToString(ter_spread / 10, 1), 5, 42, "Roboto Condensed", 10, colCodeRed);
      else Write("panel_1_04", "- Spread: " + DoubleToString(ter_spread / 10, 1), 5, 42, "Roboto Condensed", 10, panelCol);
      
      Write("panel_1_05", "Balance: " + DoubleToString(AccountBalance(), 2) + " " + ter_currencySymbol, 5, 60, "Roboto Condensed", 14, clrCornflowerBlue);
      Write("panel_1_06", "Equity: " + DoubleToString(AccountEquity(), 2) + " " + ter_currencySymbol, 5, 80, "Roboto Condensed", 14, clrGold);
      Write("panel_1_07", "FMargin: " + DoubleToString(AccountFreeMargin(), 2) + " " + ter_currencySymbol, 5, 100, "Roboto Condensed", 14, clrOrchid);
      
      double accountPL = AccountProfit();
      double totalProfit = total_buy_profit + total_hedge_buy_profit + total_sell_profit + total_hedge_sell_profit;
      if(accountPL < 0) {Write("panel_1_08", "Global Profit: " + DoubleToString(accountPL, 2) + " " + ter_currencySymbol, 5, 125, "Roboto Condensed", 14, colInMinus);} 
      else if(accountPL > 0) {Write("panel_1_08", "Global Profit: " + DoubleToString(accountPL, 2) + " " + ter_currencySymbol, 5, 125, "Roboto Condensed", 14, colInPlus);} 
      else {Write("panel_1_08", "Global Profit: " + DoubleToString(accountPL, 2) + " " + ter_currencySymbol, 5, 125, "Roboto Condensed", 14, colFontGray); }
      
      if(totalProfit < 0) {Write("panel_1_09", "Local Profit: " + DoubleToString(totalProfit, 2) + " " + ter_currencySymbol, 5, 145, "Roboto Condensed", 14, colInMinus);} 
      else if(totalProfit > 0) { Write("panel_1_09", "Local Profit: " + DoubleToString(totalProfit, 2) + " " + ter_currencySymbol, 5, 145, "Roboto Condensed", 14, colInPlus);} 
      else {Write("panel_1_09", "Local Profit: " + DoubleToString(totalProfit, 2) + " " + ter_currencySymbol, 5, 145, "Roboto Condensed", 14, colFontGray);}
      
      // Closed Profit (see ontick function, works only there)
      
      double equityDifference = max_equity - AccountEquity();
      if (max_equity != 0) {
      double equityPercentage = equityDifference / max_equity * 100;
      string panelText1 = "DD: -" + DoubleToString(equityDifference, 2) + " " + ter_currencySymbol + " (-" + DoubleToString(equityPercentage, 2) + " %)";
      Write("panel_1_10", panelText1, 5, 190, "Roboto Condensed", 14, clrGold);
      string panelText2 = "Max: " + DoubleToString(max_float, 2) + " " + ter_currencySymbol + " (" + DoubleToString(max_float / max_equity * 100, 2) + " %)";
      Write("panel_1_11", panelText2, 5, 213, "Roboto Condensed", 11, clrDarkGoldenrod);
      } else {
      string panelText1 = "DD: -" + DoubleToString(equityDifference, 2) + " " + ter_currencySymbol + " (-100.00 %)";
      Write("panel_1_10", panelText1, 5, 190, "Roboto Condensed", 14, clrGold);
      string panelText2 = "Max: " + DoubleToString(max_float, 2) + " " + ter_currencySymbol + " (100.00 %)";
      Write("panel_1_11", panelText2, 5, 213, "Roboto Condensed", 11, clrDarkGoldenrod);} 
}

// #047B: extended trade info panel (detailed information)

if(show_forecast) {

      if(total_buy_profit != 0) Write("panel_1_12", ">> BUY ORDERS:", 5, 240, "Roboto Condensed Bold", 12, clrDodgerBlue);
      else Write("panel_1_12", "BUY ORDERS:", 5, 240, "Roboto Condensed Bold", 12, clrLightSlateGray);
      
      if(total_buy_profit != 0) Write("panel_1_13", "Total orders: " + (string)buys, 5, 260, "Roboto Condensed", 10, colFontWhite);
      else Write("panel_1_13", "Total Orders: " + (string)buys, 5, 260, "Roboto Condensed", 10, colFontGray);
      
      if(total_buy_profit != 0) Write("panel_1_14", "Total Lots: " + DoubleToStr(total_buy_lots, 2), 5, 275, "Roboto Condensed", 10, colFontWhite);
      else Write("panel_1_14", "Total Lots: " + DoubleToStr(total_buy_lots, 2), 5, 275, "Roboto Condensed", 10, colFontGray);
      
      if(total_buy_profit < 0) {Write("panel_1_15", "Profit/Loss: " + DoubleToStr(total_buy_profit+total_hedge_buy_profit, 2) + " " + ter_currencySymbol, 5, 290, "Roboto Condensed", 10, colInMinus);} 
      else if(total_buy_profit > 0) {Write("panel_1_15", "Profit/Loss: " + DoubleToStr(total_buy_profit+total_hedge_buy_profit, 2) + " " + ter_currencySymbol, 5, 290, "Roboto Condensed", 10, colInPlus);} 
      else {Write("panel_1_15", "Profit/Loss: " + DoubleToStr(total_buy_profit+total_hedge_buy_profit, 2) + " " + ter_currencySymbol, 5, 290, "Roboto Condensed", 10, colFontGray);}   
      
      if(total_buy_profit != 0) Write("panel_1_16", "Profit Goal: " + DoubleToStr(aux_tp_buy, 2) + " " + ter_currencySymbol, 5, 305, "Roboto Condensed", 10, colFontWhite);
      else Write("panel_1_16", "Profit Goal: 0.00 " + ter_currencySymbol, 5, 305, "Roboto Condensed", 10, colFontGray); 
      
      double pips2go_Buys = MathAbs(line_buy / ter_tick_size - ter_priceSell / ter_tick_size) / 10;
      if(total_buy_profit != 0) Write("panel_1_17", "Distance: " + DoubleToString(pips2go_Buys, 0) + " pips", 5, 320, "Roboto Condensed", 10, colFontWhite); 
      else Write("panel_1_17", "Distance: 0 pips", 5, 320, "Roboto Condensed", 10, colFontGray);
      
      if(buy_close_profit != 0) Write("panel_1_18", "Locked Profit: " + ter_currencySymbol + DoubleToStr(buy_close_profit, 2), 5, 335, "Roboto Condensed", 10, colFontWhite);
      else Write("panel_1_18", "Locked Profit: " + DoubleToStr(buy_close_profit, 2) + " " + ter_currencySymbol, 5, 335, "Roboto Condensed", 10, colFontGray);
      
      if(buy_max_profit != 0) Write("panel_1_19", "Max. Profit: " + DoubleToStr(buy_max_profit, 2) + " " + ter_currencySymbol, 5, 350, "Roboto Condensed", 10, colFontWhite);
      else Write("panel_1_19", "Max. Profit: " + DoubleToStr(buy_max_profit, 2) + " " + ter_currencySymbol, 5, 350, "Roboto Condensed", 10, colFontGray);
      
      if(total_hedge_sell_profit < 0) {Write("panel_1_20", "Hedge Profit: " + DoubleToStr(total_hedge_sell_profit, 2) + " " + ter_currencySymbol, 5, 365, "Roboto Condensed", 10, colInMinus);} 
      else if(total_hedge_sell_profit > 0) {Write("panel_1_20", "Hedge Profit: " + DoubleToStr(total_hedge_sell_profit, 2) + " " + ter_currencySymbol, 5, 365, "Roboto Condensed", 10, colInPlus);} 
      else {Write("panel_1_20", "Hedge Profit: " + DoubleToStr(total_hedge_sell_profit, 2) + " " + ter_currencySymbol, 5, 365, "Roboto Condensed", 10, colFontGray);}
      
      if(hedge_sells != 0) Write("panel_1_21", "Hedge Orders: " + (string)hedge_sells, 5, 380, "Roboto Condensed", 10, colFontWhite);
      else Write("panel_1_21", "Hedge Orders: " + (string)hedge_sells, 5, 380, "Roboto Condensed", 10, colFontGray);
      if(total_hedge_sell_lots != 0) Write("panel_1_22", "Hedge Lots: " + DoubleToStr(total_hedge_sell_lots, 2), 5, 395, "Roboto Condensed", 10, colFontWhite);
      else Write("panel_1_22", "Hedge Lots: " + DoubleToStr(total_hedge_sell_lots, 2), 5, 395, "Roboto Condensed", 10, colFontGray);

      
      if(total_sell_profit != 0) Write("panel_1_23", ">> SELL ORDERS:", 5, 420, "Roboto Condensed Bold", 12, clrCrimson);
      else Write("panel_1_23", "SELL ORDERS:", 5, 420, "Roboto Condensed Bold", 12, clrLightSlateGray);
      
      if(total_sell_profit != 0) Write("panel_1_24", "Total Orders: " + (string)sells, 5, 440, "Roboto Condensed", 10, colFontWhite);
      else Write("panel_1_24", "Total Orders: " + (string)sells, 5, 440, "Roboto Condensed", 10, colFontGray);
      
      if(total_sell_profit != 0) Write("panel_1_25", "Total Lots: " + DoubleToStr(total_sell_lots, 2), 5, 455, "Roboto Condensed", 10, colFontWhite);
      else Write("panel_1_25", "Total Lots: " + DoubleToStr(total_sell_lots, 2), 5, 455, "Roboto Condensed", 10, colFontGray);
      
      if(total_sell_profit < 0) { Write("panel_1_26", "Profit/Loss: " + DoubleToStr(total_sell_profit+total_hedge_sell_profit, 2) + " " + ter_currencySymbol, 5, 470, "Roboto Condensed", 10, colInMinus);} 
      else if(total_sell_profit > 0) { Write("panel_1_26", "Profit/Loss: " + DoubleToStr(total_sell_profit+total_hedge_sell_profit, 2) + " " + ter_currencySymbol, 5, 470, "Roboto Condensed", 10, colInPlus);} 
      else { Write("panel_1_26", "Profit/Loss: " + DoubleToStr(total_sell_profit+total_hedge_sell_profit, 2) + " " + ter_currencySymbol, 5, 470, "Roboto Condensed", 10, colFontGray);}
      
      if(total_sell_profit != 0) Write("panel_1_27", "Profit Goal: " + DoubleToStr(aux_tp_sell, 2) + " " + ter_currencySymbol, 5, 485, "Roboto Condensed", 10, colFontWhite);
      else Write("panel_1_27", "Profit Goal: 0.00 " + ter_currencySymbol, 5, 485, "Roboto Condensed", 10, colFontGray);
      
      double pips2go_Sells = MathAbs(line_sell / ter_tick_size - ter_priceBuy / ter_tick_size) / 10;
      if(total_sell_profit != 0) Write("panel_1_28", "Distance: " + DoubleToString(pips2go_Sells, 0) + " pips", 5, 500, "Roboto Condensed", 10, colFontWhite);
      else Write("panel_1_28", "Distance: 0 pips", 5, 500, "Roboto Condensed", 10, colFontGray);
      
      if(sell_close_profit != 0) Write("panel_1_29", "Locked Profit: " + DoubleToStr(sell_close_profit, 2) + " " + ter_currencySymbol, 5, 515, "Roboto Condensed", 10, colFontWhite);
      else Write("panel_1_29", "Locked Profit: " + DoubleToStr(sell_close_profit, 2) + " " + ter_currencySymbol, 5, 515, "Roboto Condensed", 10, colFontGray);
      
      if(sell_max_profit != 0) Write("panel_1_30", "Max. Profit: " + DoubleToStr(sell_max_profit, 2) + " " + ter_currencySymbol, 5, 530, "Roboto Condensed", 10, colFontWhite);
      else Write("panel_1_30", "Max. Profit: " + DoubleToStr(sell_max_profit, 2) + " " + ter_currencySymbol, 5, 530, "Roboto Condensed", 10, colFontGray);
      
      if(total_hedge_buy_profit < 0) {Write("panel_1_31", "Hedge Profit: " + DoubleToStr(total_hedge_buy_profit, 2) + " " + ter_currencySymbol, 5, 545, "Roboto Condensed", 10, colInMinus);} 
      else if(total_hedge_buy_profit > 0) {Write("panel_1_31", "Hedge Profit: " + DoubleToStr(total_hedge_buy_profit, 2) + " " + ter_currencySymbol, 5, 545, "Roboto Condensed", 10, colInPlus);} 
      else {Write("panel_1_31", "Hedge Profit: " + DoubleToStr(total_hedge_buy_profit, 2) + " " + ter_currencySymbol, 5, 545, "Roboto Condensed", 10, colFontGray);}
      
      if(hedge_buys != 0) Write("panel_1_32", "Hedge Orders: " + (string)hedge_buys, 5, 560, "Roboto Condensed", 10, colFontWhite);
      else Write("panel_1_32", "Hedge Orders: " + (string)hedge_buys, 5, 560, "Roboto Condensed", 10, colFontGray);
      
      if(total_hedge_buy_lots != 0) Write("panel_1_33", "Hedge Lots: " + DoubleToStr(total_hedge_buy_lots, 2), 5, 575, "Roboto Condensed", 10, colFontWhite);
      else Write("panel_1_33", "Hedge Lots: " + DoubleToStr(total_hedge_buy_lots, 2), 5, 575, "Roboto Condensed", 10, colFontGray);
}

if(show_settings) {

      Write("panel_1_34", "SETTINGS:", 5, 605, "Roboto Condensed Bold", 12, clrLightSlateGray);
      Write("panel_1_35", "Base Lot: " + DoubleToStr(min_lots, 2), 5, 625, "Roboto Condensed", 10, colFontGray);
      Write("panel_1_36", "Lot Prog.: " + info_money_management[progression], 5, 640, "Roboto Condensed", 10, colFontGray);
      Write("panel_1_37", "Lot Multiplier: " + (string)lot_multiplicator, 5, 655, "Roboto Condensed", 10, colFontGray);
      Write("panel_1_38", ". . . . . . . . . . . . . . . .", 5, 661, "Roboto Condensed", 10, colFontGray);
      Write("panel_1_39", "Max. Positions: " + (string)max_positions, 5, 675, "Roboto Condensed", 10, colFontGray);
      Write("panel_1_40", "Grid Step: " + (string)grid_size, 5, 690, "Roboto Condensed", 10, colFontGray);
      Write("panel_1_41", info_gs_progression, 5, 705, "Roboto Condensed", 10, colFontGray);
      Write("panel_1_42", "Grid Multiplier: " + (string)gs_multiplicator, 5, 720, "Roboto Condensed", 10, colFontGray);
      Write("panel_1_43", ". . . . . . . . . . . . . . . .", 5, 726, "Roboto Condensed", 10, colFontGray);
      Write("panel_1_44", "Take Profit: " + take_profit, 5, 740, "Roboto Condensed", 10, colFontGray);
      Write("panel_1_45", "Profit Lock: " + DoubleToStr(100 * profit_lock, 2) + "%", 5, 755, "Roboto Condensed", 10, colFontGray);
      Write("panel_1_46", cycleRisktext, 5, 770, "Roboto Condensed", 10, colFontGray);
      Write("panel_1_47", "Yoga Mode: " + DoubleToStr(100 * equity_warning, 2) + "%", 5, 785, "Roboto Condensed", 10, colFontGray);
      Write("panel_1_48", "Shut Down: " + DoubleToStr(100 * account_risk, 2) + "%", 5, 800, "Roboto Condensed", 10, colFontGray);
      Write("panel_1_49", ". . . . . . . . . . . . . . . .", 5, 806, "Roboto Condensed", 10, colFontGray);
      if(partial_closing != 0) 
      Write("panel_1_50", "Partial Closing: " + (string)partial_closing, 5, 820, "Roboto Condensed", 10, colFontGray); else 
      Write("panel_1_50", "Partial Closing: Off", 5, 820, "Roboto Condensed", 10, colFontGray);
      if(hedging_active != 0) 
      Write("panel_1_51", "Cycle Hedging: " + (string)max_positions, 5, 835, "Roboto Condensed", 10, colFontGray); else 
      Write("panel_1_51", "Cycle Hedging: Off", 5, 835, "Roboto Condensed", 10, colFontGray);
      if(profit_chasing != 0)
      Write("panel_1_52", "Profit Chasing: " + (string)profit_chasing, 5, 850, "Roboto Condensed", 10, colFontGray); else
      Write("panel_1_52", "Profit Chasing: Off", 5, 850, "Roboto Condensed", 10, colFontGray);
      Write("panel_1_53", ". . . . . . . . . . . . . . . .", 5, 856, "Roboto Condensed", 10, colFontGray);
      Write("panel_1_54", "Magic No: " + IntegerToString(magic, 0), 5, 870, "Roboto Condensed", 10, colFontGray);
}
      
if(show_indicators) {

      // TOP PANNEL INDICATOR VALUES
      // gray = disabled, white = used together, yellow = used separate, red/blue = signal trigger
      
      double BBL = iBands(Symbol(), BB_tf, BB_Period, BB_Dev, 0, PRICE_CLOSE, MODE_LOWER, BB_Shift);
      double BBU = iBands(Symbol(), BB_tf, BB_Period, BB_Dev, 0, PRICE_CLOSE, MODE_UPPER, BB_Shift);
      double price = Bid; // Assuming Bid is the current price
      double averagePrice = (BBU + BBL) / 2; // Average price between upper and lower bands
      double standardDeviation = (BBU - BBL) / (BB_Dev * 2); // Standard deviation
      double deviation = (price - averagePrice) / standardDeviation;
      Write("panel_1_47a", DoubleToString(deviation, 2) + " ~ BB("+ (string)BB_Period + "," + DoubleToString(BB_Dev,1) +")", 635, 3, "Roboto Condensed", 9, colFontGray);
      if (Use_BB == true) 
      Write("panel_1_47a", DoubleToString(deviation, 2) + " ~ BB("+ (string)BB_Period + "," + DoubleToString(BB_Dev,1) +")", 635, 3, "Roboto Condensed", 9, clrWhite);
      if (Use_BB == true && Conjunct_Idx == false) 
      Write("panel_1_47a", DoubleToString(deviation, 2) + " ~ BB("+ (string)BB_Period + "," + DoubleToString(BB_Dev,1) +")", 635, 3, "Roboto Condensed", 9, clrYellow);
      if (Use_BB == true && price > BBU) 
      Write("panel_1_47a", DoubleToString(deviation, 2) + " > BB("+ (string)BB_Period + "," + DoubleToString(BB_Dev,1) +")", 635, 3, "Roboto Condensed", 9, clrDodgerBlue);
      else if (Use_BB == true && price < BBL) 
      Write("panel_1_47a", DoubleToString(deviation, 2) + " < BB("+ (string)BB_Period + "," + DoubleToString(BB_Dev,1) +")", 635, 3, "Roboto Condensed", 9, clrCrimson);
      
      double stochK = iStochastic(NULL, 0, Stoch_K, Stoch_D, Stoch_Slowing, Stoch_Method, Stoch_Price, MODE_SIGNAL, Stoch_Shift);
      Write("panel_1_47b", DoubleToString(stochK, 1) + " ~ STO("+ (string)Stoch_K + "," + (string)Stoch_Upper + "/" + (string)Stoch_Lower +")", 500, 3, "Roboto Condensed", 9, colFontGray);
      if (Use_Stoch == true) 
      Write("panel_1_47b", DoubleToString(stochK, 1) + " ~ STO("+ (string)Stoch_K + ")" + (string)Stoch_Upper + "/" + (string)Stoch_Lower +")", 500, 3, "Roboto Condensed", 9, clrWhite);
      if (Use_Stoch == true && Conjunct_Idx == false) 
      Write("panel_1_47b", DoubleToString(stochK, 1) + " ~ STO("+ (string)Stoch_K + ")" + (string)Stoch_Upper + "/" + (string)Stoch_Lower +")", 500, 3, "Roboto Condensed", 9, clrYellow);
      if (Use_Stoch == true && stochK >= Stoch_Upper) 
      Write("panel_1_47b", DoubleToString(stochK, 1) + " > STO("+ (string)Stoch_K + ")" + (string)Stoch_Upper + "/" + (string)Stoch_Lower +")", 500, 3, "Roboto Condensed", 9, clrDodgerBlue);
      else if (Use_Stoch == true && stochK <= Stoch_Lower) 
      Write("panel_1_47b", DoubleToString(stochK, 1) + " < STO("+ (string)Stoch_K + ")" + (string)Stoch_Upper + "/" + (string)Stoch_Lower +")", 500, 3, "Roboto Condensed", 9, clrCrimson);
            
      double rsiValue = iRSI(NULL, 0, RSI_Period, PRICE_CLOSE, RSI_Shift);
      Write("panel_1_47c", DoubleToString(rsiValue, 1) + " ~ RSI("+ (string)RSI_Period + ")" + (string)RSI_Upper + "/" + (string)RSI_Lower +")", 370, 3, "Roboto Condensed", 9, colFontGray);
      if (Use_RSI) 
      Write("panel_1_47c", DoubleToString(rsiValue, 1) + " ~ RSI("+ (string)RSI_Period + ")" + (string)RSI_Upper + "/" + (string)RSI_Lower +")", 370, 3, "Roboto Condensed", 9, clrWhite);
      if (Use_RSI && Conjunct_Idx == false) 
      Write("panel_1_47c", DoubleToString(rsiValue, 1) + " ~ RSI("+ (string)RSI_Period + ")" + (string)RSI_Upper + "/" + (string)RSI_Lower +")", 370, 3, "Roboto Condensed", 9, clrYellow);
      if (Use_RSI == true && rsiValue >= RSI_Upper) 
      Write("panel_1_47c", DoubleToString(rsiValue, 1) + " > RSI("+ (string)RSI_Period + ")" + (string)RSI_Upper + "/" + (string)RSI_Lower +")", 370, 3, "Roboto Condensed", 9, clrDodgerBlue);
      else if (Use_RSI == true && rsiValue <= RSI_Lower) 
      Write("panel_1_47c", DoubleToString(rsiValue, 1) + " < RSI("+ (string)RSI_Period + ")" + (string)RSI_Upper + "/" + (string)RSI_Lower +")", 370, 3, "Roboto Condensed", 9, clrCrimson);
      
      double cciValue = iCCI(NULL, 0, CCI_Period, PRICE_CLOSE, CCI_Shift);
      Write("panel_1_47d", DoubleToString(cciValue, 1) + " ~ CCI("+ (string)CCI_Period + ")" + (string)CCI_Upper + "/" + (string)CCI_Lower +")", 225, 3, "Roboto Condensed", 9, colFontGray);
      if (Use_CCI == true) 
      Write("panel_1_47d", DoubleToString(cciValue, 1) + " ~ CCI("+ (string)CCI_Period + ")" + (string)CCI_Upper + "/" + (string)CCI_Lower +")", 225, 3, "Roboto Condensed", 9, clrWhite);
      if (Use_CCI == true && Conjunct_Idx == false) 
      Write("panel_1_47d", DoubleToString(cciValue, 1) + " ~ CCI("+ (string)CCI_Period + ")" + (string)CCI_Upper + "/" + (string)CCI_Lower +")", 225, 3, "Roboto Condensed", 9, clrYellow);
      if (Use_CCI == true && cciValue >= CCI_Upper) 
      Write("panel_1_47d", DoubleToString(cciValue, 1) + " > CCI("+ (string)CCI_Period + ")" + (string)CCI_Upper + "/" + (string)CCI_Lower +")", 225, 3, "Roboto Condensed", 9, clrDodgerBlue);
      else if (Use_CCI == true && cciValue <= CCI_Lower) 
      Write("panel_1_47d", DoubleToString(cciValue, 1) + " < CCI("+ (string)CCI_Period + ")" + (string)CCI_Upper + "/" + (string)CCI_Lower +")", 225, 3, "Roboto Condensed", 9, clrCrimson);
      
}
}

//+---------------------------------------------------------------------------+
//  Local variable methods
//+---------------------------------------------------------------------------+

// ------------------------------------------------------------------------------------------------
// INIT VARS
// ------------------------------------------------------------------------------------------------
void InitVars()
  {
// Reset number of buy/sell orders
   buys = 0;
   sells = 0;
   hedge_buys = 0;
   hedge_sells = 0;

// Reset hegding indicators
   is_buy_hedging_active = false;
   is_sell_hedging_active = false;
   is_buy_hedging_order_active = false;
   is_sell_hedging_order_active = false;
   buy_max_order_lot_open = false;
   sell_max_order_lot_open = false;

// Reset arrays
   for(int i = 0; i < max_open_positions; i++)
     {
      buy_tickets[i] = 0;
      buy_lots[i] = 0;
      buy_profit[i] = 0;
      buy_price[i] = 0;
      sell_tickets[i] = 0;
      sell_lots[i] = 0;
      sell_profit[i] = 0;
      sell_price[i] = 0;
      hedge_buy_tickets[i] = 0;
      hedge_sell_tickets[i] = 0;
      hedge_buy_lots[i] = 0;
      hedge_sell_lots[i] = 0;
      hedge_buy_profit[i] = 0;
      hedge_sell_profit[i] = 0;
      hedge_buy_price[i] = 0;
      hedge_sell_price[i] = 0;
     }

// #021: new setting: max_open_positions
// if not used, set it to maximum => no restriction
   if(max_positions == 0)
      max_positions = max_auto_open_positions;

// #030: disable equity and account risk by setting them to 0
// #025: use equity percentage instead of unpayable position
   if(equity_warning == 0)
      equity_warning = 1.0;
   if(account_risk == 0)
      account_risk = 1.0;
  }

// ------------------------------------------------------------------------------------------------
// UPDATE VARS
// ------------------------------------------------------------------------------------------------
void UpdateVars()
  {
   double max_lot = 0;
   int aux_buys = 0, aux_sells = 0;
   int aux_hedge_buys = 0, aux_hedge_sells = 0;
   double aux_total_buy_profit = 0, aux_total_sell_profit = 0;
   double aux_hedge_total_buy_profit = 0, aux_hedge_total_sell_profit = 0;
   double aux_total_buy_swap = 0, aux_total_sell_swap = 0, aux_hedge_total_buy_swap = 0, aux_hedge_total_sell_swap = 0;
   double aux_total_buy_lots = 0, aux_total_sell_lots = 0;
   double aux_hedge_total_buy_lots = 0, aux_hedge_total_sell_lots = 0;

   if(progression == 0)
      max_lot = min_lots;
   if(progression == 1)
      max_lot = max_positions * min_lots;
   if(progression == 2)
      max_lot = lot_multiplicator * max_positions * min_lots;
   if(progression == 3)
      max_lot = CalculateFibonacci(max_positions) * min_lots;

// We are going to introduce data from opened orders in arrays
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
        {
         if(OrderSymbol() == Symbol())
           {
            if(OrderMagicNumber() == magic && OrderType() == OP_BUY)
              {
               buy_tickets[aux_buys] = OrderTicket();
               buy_lots[aux_buys] = OrderLots();
               if(buy_lots[aux_buys] == max_lot)
                 {
                  buy_max_order_lot_open = true;
                 }

               buy_profit[aux_buys] = OrderProfit() + OrderCommission() + OrderSwap();
               buy_price[aux_buys] = OrderOpenPrice();
               aux_total_buy_profit = aux_total_buy_profit + buy_profit[aux_buys];
               aux_total_buy_lots = aux_total_buy_lots + buy_lots[aux_buys];
               aux_total_buy_swap += OrderSwap();
               aux_buys++;
              }
            // hedge opened buy orders - this is used for corrections
            if(OrderMagicNumber() == hedge_magic && OrderType() == OP_BUY)
              {
               hedge_buy_tickets[aux_hedge_buys] = OrderTicket();
               hedge_buy_lots[aux_hedge_buys] = OrderLots();
               hedge_buy_profit[aux_hedge_buys] = OrderProfit() + OrderCommission() + OrderSwap();
               hedge_buy_price[aux_hedge_buys] = OrderOpenPrice();
               aux_hedge_total_buy_profit = aux_hedge_total_buy_profit + hedge_buy_profit[aux_hedge_buys];
               aux_hedge_total_buy_lots = aux_hedge_total_buy_lots + hedge_buy_lots[aux_hedge_buys];
               aux_hedge_total_buy_swap += OrderSwap();
               aux_hedge_buys++;
              }
            if(OrderMagicNumber() == magic && OrderType() == OP_SELL)
              {
               sell_tickets[aux_sells] = OrderTicket();
               sell_lots[aux_sells] = OrderLots();
               if(sell_lots[aux_sells] == max_lot)
                 {
                  sell_max_order_lot_open = true;
                 }

               sell_profit[aux_sells] = OrderProfit() + OrderCommission() + OrderSwap();
               sell_price[aux_sells] = OrderOpenPrice();
               aux_total_sell_profit = aux_total_sell_profit + sell_profit[aux_sells];
               aux_total_sell_lots = aux_total_sell_lots + sell_lots[aux_sells];
               aux_total_sell_swap += OrderSwap();
               aux_sells++;
              }
            // manuel opened sell orders - this is used for corrections
            if(OrderMagicNumber() == hedge_magic && OrderType() == OP_SELL)
              {
               hedge_sell_tickets[aux_hedge_sells] = OrderTicket();
               hedge_sell_lots[aux_hedge_sells] = OrderLots();
               hedge_sell_profit[aux_hedge_sells] = OrderProfit() + OrderCommission() + OrderSwap();
               hedge_sell_price[aux_hedge_sells] = OrderOpenPrice();
               aux_hedge_total_sell_profit = aux_hedge_total_sell_profit + hedge_sell_profit[aux_hedge_sells];
               aux_hedge_total_sell_lots = aux_hedge_total_sell_lots + hedge_sell_lots[aux_hedge_sells];
               aux_hedge_total_sell_swap += OrderSwap();
               aux_hedge_sells++;
              }
           }
        }
     }

// Update global vars
   buys                    = aux_buys;
   sells                   = aux_sells;
   hedge_buys             = aux_hedge_buys;
   hedge_sells            = aux_hedge_sells;
   total_buy_profit        = aux_total_buy_profit;
   total_sell_profit       = aux_total_sell_profit;
   total_hedge_buy_profit = aux_hedge_total_buy_profit;
   total_hedge_sell_profit = aux_hedge_total_sell_profit;
   total_buy_lots          = aux_total_buy_lots;
   total_sell_lots         = aux_total_sell_lots;
   total_hedge_buy_lots   = aux_hedge_total_buy_lots;
   total_hedge_sell_lots  = aux_hedge_total_sell_lots;

   if(total_hedge_buy_lots > 0)
     {
      is_buy_hedging_order_active = true;
     }

   if(total_hedge_sell_lots > 0)
     {
      is_sell_hedging_order_active = true;
     }

   total_buy_swap          = aux_total_buy_swap;
   total_sell_swap         = aux_total_sell_swap;
   total_hedge_buy_swap   = aux_hedge_total_buy_swap;
   total_hedge_sell_swap  = aux_hedge_total_sell_swap;

   dLots = (buys + hedge_buys) - (sells + hedge_sells);     // разность объема ордеров
   dlots = NormalizeDouble(dLots, Digits);                   //убираем погрешность в расчете разности объема ордеров


   relativeVolume = MathAbs(total_buy_lots - total_sell_lots);
  }

// ------------------------------------------------------------------------------------------------
// SORT BY LOTS
// ------------------------------------------------------------------------------------------------
void SortByLots()
  {
   int aux_tickets;
   double aux_lots, aux_profit, aux_price;

// We are going to sort orders by volume
// m[0] smallest volume m[size-1] largest volume

// BUY ORDERS
   for(int i = 0; i < buys - 1; i++)
     {
      for(int j = i + 1; j < buys; j++)
        {
         if(buy_lots[i] > 0 && buy_lots[j] > 0)
           {
            // at least 2 orders
            if(buy_lots[j] < buy_lots[i])
              {
               // sorting
               // ...lots...
               aux_lots = buy_lots[i];
               buy_lots[i] = buy_lots[j];
               buy_lots[j] = aux_lots;
               // ...tickets...
               aux_tickets = buy_tickets[i];
               buy_tickets[i] = buy_tickets[j];
               buy_tickets[j] = aux_tickets;
               // ...profits...
               aux_profit = buy_profit[i];
               buy_profit[i] = buy_profit[j];
               buy_profit[j] = aux_profit;
               // ...and open price
               aux_price = buy_price[i];
               buy_price[i] = buy_price[j];
               buy_price[j] = aux_price;
              }
           }
        }
     }

// SELL ORDERS
   for(int i = 0; i < sells - 1; i++)
     {
      for(int j = i + 1; j < sells; j++)
        {
         if(sell_lots[i] > 0 && sell_lots[j] > 0)
           {
            // at least 2 orders
            if(sell_lots[j] < sell_lots[i])
              {
               // sorting...
               // ...lots...
               aux_lots = sell_lots[i];
               sell_lots[i] = sell_lots[j];
               sell_lots[j] = aux_lots;
               // ...tickets...
               aux_tickets = sell_tickets[i];
               sell_tickets[i] = sell_tickets[j];
               sell_tickets[j] = aux_tickets;
               // ...profits...
               aux_profit = sell_profit[i];
               sell_profit[i] = sell_profit[j];
               sell_profit[j] = aux_profit;
               // ...and open price
               aux_price = sell_price[i];
               sell_price[i] = sell_price[j];
               sell_price[j] = aux_price;
              }
           }
        }
     }
  }

//+---------------------------------------------------------------------------+
//  Global variable methods
//+---------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| WrtieIniData()                                                                 |
// #017: deal with global vars to save and restore data, while chart is closed or must be restarted by other reason
//+------------------------------------------------------------------+
void WriteIniData()
  {
// #016: Save status of buttons in global vars
   if(!IsTesting())
     {
      // implement button: Stop & Close
      // implement button: Stop On Next Cycle
      GlobalVariableSet(globalVarsID + "stopNextCycle", stopNextCycle);
      GlobalVariableSet(globalVarsID + "restAndRealize", restAndRealize);
      GlobalVariableSet(globalVarsID + "stopAll", stopAll);
      // button to show or hide comment
      GlobalVariableSet(globalVarsID + "showComment", showComment);
      // save max equity at global vars
      GlobalVariableSet(globalVarsID + "max_equity", NormalizeDouble(max_equity, 2));
     }
  }

//+------------------------------------------------------------------+
//| ReadIniData()                                                                 |
// #017: deal with global vars to save and restore data,
// while chart is closed or must be restarted by other reason
//+------------------------------------------------------------------+
void ReadIniData()
  {
// #016: read status of buttons from global vars
   if(!IsTesting())
     {
      int count = GlobalVariablesTotal();
      if(count > 0)
        {
         // #011 #018 #019: implement button: Stop On Next Cycle
         if(GlobalVariableCheck(globalVarsID + "stopNextCycle"))
            stopNextCycle = (int)GlobalVariableGet(globalVarsID + "stopNextCycle");

         if(GlobalVariableCheck(globalVarsID + "restAndRealize"))
            restAndRealize = (int)GlobalVariableGet(globalVarsID + "restAndRealize");

         // #010: implement button: Stop & Close
         if(GlobalVariableCheck(globalVarsID + "stopAll"))
            stopAll = (int)GlobalVariableGet(globalVarsID + "stopAll");

         // #044: Add button to show or hide comment
         if(GlobalVariableCheck(globalVarsID + "showComment"))
            showComment = (int)GlobalVariableGet(globalVarsID + "showComment");

         // #037: save max equity at global vars
         if(GlobalVariableCheck(globalVarsID + "max_equity"))
            max_equity = NormalizeDouble(GlobalVariableGet(globalVarsID + "max_equity"), 2);
        }
     }
  }

//+---------------------------------------------------------------------------+
//  BUTTON methods
//+---------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| DeleteButton                                                     |
//+------------------------------------------------------------------+
void DeleteButton(string ctlName)
  {
   ObjectButton(ctlName, LODelete);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetButtonText(string ctlName, string Text)
  {
   if((ObjectFind(ChartID(), ctlName) > -1))
     {
      ObjectSetString(ChartID(), ctlName, OBJPROP_TEXT, Text);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetButtonColor(string ctlName, color buttonColor = clrNONE, color textColor = clrNONE)
  {
   if((ObjectFind(ChartID(), ctlName) > -1))
     {
      if(buttonColor != clrNONE)
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_BGCOLOR, buttonColor);
      if(textColor != clrNONE)
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_COLOR, textColor);
     }
  }

//+------------------------------------------------------------------+
//|PressButton                                                       |
//+------------------------------------------------------------------+
void PressButton(string ctlName)
  {
   bool selected = ObjectGetInteger(ChartID(), ctlName, OBJPROP_STATE);
   if(selected)
     {
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_STATE, false);
     }
   else
     {
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_STATE, true);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawButton(string ctlName, string Text = "", int X = -1, int Y = -1, int Width = -1,
                int Height = -1, bool Selected = false,
                color BgColor = clrNONE, color TextColor = clrNONE)
  {
   ObjectButton(ctlName, LODraw, Text, X, Y, Width, Height, Selected, BgColor, TextColor);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjectButton(string ctlName, enObjectOperation Operation, string Text = "",
                  int X = -1, int Y = -1, int Width = -1, int Height = -1, bool Selected = false,
                  color BgColor = clrNONE, color TextColor = clrNONE)
  {
   int DefaultX = btnLeftAxis;
   int DefaultY = btnTopAxis;
   int DefaultWidth = 90;
   int DefaultHeight = 20;
   if((ObjectFind(ChartID(), ctlName) > -1))
     {
      if(Operation == LODraw)
        {
         if(TextColor == clrNONE)
            TextColor = clrWhite;
         if(BgColor == clrNONE)
            BgColor = clrBlueViolet;
         if(X == -1)
            X = DefaultX;
         if(Y == -1)
            Y = DefaultY;
         if(Width == -1)
            Width = DefaultWidth;
         if(Height == -1)
            Height = DefaultHeight;

         ObjectSetInteger(ChartID(), ctlName, OBJPROP_COLOR, TextColor);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_BGCOLOR, BgColor);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_XDISTANCE, X);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_YDISTANCE, Y);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_XSIZE, Width);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_YSIZE, Height);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_STATE, Selected);
         ObjectSetString(ChartID(), ctlName, OBJPROP_FONT, "Roboto Condensed");
         ObjectSetString(ChartID(), ctlName, OBJPROP_TEXT, Text);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_FONTSIZE, 9);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_SELECTABLE, 0);

        }
      else
         if(Operation == LODelete)
           {
            ObjectDelete(ChartID(), ctlName);
           }
     }
   else
      if(Operation == LODraw)
        {
         if(TextColor == clrNONE)
            TextColor = clrWhite;
         if(BgColor == clrNONE)
            BgColor = clrBlueViolet;
         if(X == -1)
            X = DefaultX;
         if(Y == -1)
            Y = DefaultY;
         if(Width == -1)
            Width = DefaultWidth;
         if(Height == -1)
            Height = DefaultHeight;

         ObjectCreate(ChartID(), ctlName, OBJ_BUTTON, 0, 0, 0);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_COLOR, TextColor);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_BGCOLOR, BgColor);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_XDISTANCE, X);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_YDISTANCE, Y);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_XSIZE, Width);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_YSIZE, Height);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_STATE, Selected);
         ObjectSetString(ChartID(), ctlName, OBJPROP_FONT, "Roboto Condensed");
         ObjectSetString(ChartID(), ctlName, OBJPROP_TEXT, Text);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_FONTSIZE, 9);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_SELECTABLE, 0);
        }
  }

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam,
                  const string &sparam)
  {
   int retVal = 0;
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      string clickedObject = sparam;

      // #019: implement button: Stop On Next Cycle
      if(clickedObject == "btnstopNextCycle")   //stop on Next Cycle
        {
         if(stopNextCycle)
            stopNextCycle = 0;
         else
           {
            retVal = MessageBox("Trading as normal, until a cycle is successfully closed?", "   S T O P  N E X T  C Y C L E :", MB_YESNO);
            if(retVal == IDYES)
               stopNextCycle = 1;
           }
        }
      // #011 #018: implement button: Stop On Next Cycle
      if(clickedObject == "btnrestAndRealize")   //stop on Next Cycle
        {
         if(restAndRealize)
            restAndRealize = 0;
         else
           {
            retVal = MessageBox("Do not open any new position. Close cycle successfully, if possible.", "   R E S T  &  R E A L I Z E :", MB_YESNO);
            if(retVal == IDYES)
               restAndRealize = 1;
           }
        }
      // #010: implement button: Stop & Close All
      if(clickedObject == "btnStopAll")   //stop trading and close all positions
        {
         if(stopAll)
            stopAll = 0;
         else
           {
            retVal = MessageBox("Close all positons and stop trading?", "   S T O P  &  C L O S E :", MB_YESNO);
            if(retVal == IDYES)
               stopAll = 1;
           }
        }
      // #044: Add button to show or hide comment
      if(clickedObject == "btnShowComment")   //stop on Next Cycle
        {
         if(showComment)
            showComment = 0;
         else
            showComment = 1;
        }
      // #026: implement hedge trades, if account state is not green
      if(clickedObject == "btnhedgeBuy")
        {
         if(true/*accountState==as_yellow || accountState==as_red*/)   // execute this button only, if account state is not green
           {

            retVal = MessageBox("Buy " + (string)CalculateNextVolume(OP_BUY) + " Lot of " + Symbol() + " ?", "   M A N U A L   O R D E R :", MB_YESNO);
            if(retVal == IDYES)
               OrderSendReliable(Symbol(), OP_BUY, CalculateNextVolume(OP_BUY), MarketInfo(Symbol(), MODE_ASK), slippage, 0, 0, key, magic, 0, Blue);
           }
        }
      if(clickedObject == "btnhedgeSell")
        {
         if(true/*accountState==as_yellow || accountState==as_red*/)   // execute this button only, if account state is not green
           {
            retVal = MessageBox("Sell " + (string)CalculateNextVolume(OP_SELL) + " Lot of " + Symbol() + " ?", "   M A N U A L   O R D E R :", MB_YESNO);
            if(retVal == IDYES)
               OrderSendReliable(Symbol(), OP_SELL, CalculateNextVolume(OP_SELL), MarketInfo(Symbol(), MODE_BID), slippage, 0, 0, key, magic, 0, Blue);
           }
        }
      // #034: implement hedge closing trades, if account state is not green
      if(clickedObject == "btnCloseLastBuy")
        {
         if(total_buy_lots > 0)
           {
            if(true/*accountState==as_yellow || accountState==as_red*/)   // execute this button only, if account state is not green
              {
               retVal = MessageBox("Close last buy " + (string)buy_lots[buys - 1] + "Lot of " + Symbol() + " ?", "   M A N U A L   O R D E R :", MB_YESNO);
               if(retVal == IDYES)
                 {
                  retVal = OrderCloseReliable(buy_tickets[buys - 1], buy_lots[buys - 1], MarketInfo(Symbol(), MODE_BID), slippage, Blue);
                  restAndRealize = 1; // set status, that not a new position will be opened directly after closing all
                 }
              }
           }
        }
      if(clickedObject == "btnCloseLastSell")
        {
         if(total_sell_lots > 0)
           {
            if(true/*accountState==as_yellow || accountState==as_red*/)   // execute this button only, if account state is not green
              {
               retVal = MessageBox("Close last sell " + (string)sell_lots[sells - 1] + "Lot of " + Symbol() + " ?", "   M A N U A L   O R D E R :", MB_YESNO);
               if(retVal == IDYES)
                 {
                  retVal = OrderCloseReliable(sell_tickets[sells - 1], sell_lots[sells - 1], MarketInfo(Symbol(), MODE_ASK), slippage, Blue);
                  restAndRealize = 1; // set status, that not a new position will be opened directly after closing all
                 }
              }
           }
        }
      // #035: implement hedge closing trades, if account state is not green
      if(clickedObject == "btnCloseAllBuys")
        {
         if(total_buy_lots > 0)
           {
            if(true/*accountState==as_yellow || accountState==as_red*/)   // execute this button only, if account state is not green
              {
               retVal = MessageBox("Close all " + (string)total_buy_lots + "buy Lot of " + Symbol() + " ?", "   M A N U A L   O R D E R :", MB_YESNO);
               if(retVal == IDYES)
                 {
                  closeAllBuys();
                  // set status, that not a new position will be opened directly after alosing all
                  if(restAndRealize == 0) // if not already choosen by use, set the other pause option
                     stopNextCycle = 1;
                 }
              }
           }
        }
      if(clickedObject == "btnCloseAllSells")
        {
         if(total_sell_lots > 0)
           {
            if(true/*accountState==as_yellow || accountState==as_red*/)   // execute this button only, if account state is not green
              {
               retVal = MessageBox("Close all " + (string)total_sell_lots + "sell Lot of " + Symbol() + " ?", "   M A N U A L   O R D E R :", MB_YESNO);
               if(retVal == IDYES)
                 {
                  closeAllSells();
                  // set status, that not a new position will be opened directly after alosing all
                  if(restAndRealize == 0) // if not already choosen by use, set the other pause option
                     stopNextCycle = 1;
                 }
              }
           }
        }
      WriteIniData();
     }
  }

//+---------------------------------------------------------------------------+
//  LINE methods and Chart Events
//+---------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//  ShowLines
//+------------------------------------------------------------------+
void showLines()
  {

   double aux_tp_buy = 0, aux_tp_sell = 0; // CalculateTP(next positions) = take_profit * pipvalue
   double buy_tar = 0, sell_tar = 0;   // local results
   double buy_a = 0, sell_a = 0;       // sum: # of total opened min_lots
   double buy_b = 0, sell_b = 0;       // sum: price payed for all positions
   double buy_pip = 0, sell_pip = 0;   // terminal value: tick_value / min_lots
   double buy_v[max_open_positions],   // array: # of min_lots of this index; if progression = 0, it is always 1; if prog. = 2 then: 1, 2, 4, 8, ...
          sell_v[max_open_positions];

   ArrayInitialize(buy_v, 0);
   ArrayInitialize(sell_v, 0);
   double swapDiff = 0;                // swap accumulated until actual date
   double hedgeSellDiff = 0;
   double hedgeBuyDiff = 0;

   int i;
   double myVal = 1, offset = 0, spreadPart = 0, gridSizePart = 0;

// init all lines to 0 to make sure they will be removed, if not more active

   line_buy = 0;
   line_buy_tmp = 0;
   line_buy_next = 0;
   line_buy_ts = 0;
   line_sell = 0;
   line_sell_tmp = 0;
   line_sell_next = 0;
   line_sell_ts = 0;
   line_margincall = 0;

   if(buys <= 1)
     {
      aux_tp_buy = CalculateTP(buy_lots[0]);
     }
   else
      if(progression == 0)
        {
         aux_tp_buy = CalculateTP(buy_lots[0]);
        }
      else
         if(progression == 1)
           {
            aux_tp_buy = buys * CalculateTP(buy_lots[0]);
           }
         else
            if(progression == 2)
              {
               aux_tp_buy = CalculateTP(buy_lots[buys - 1]);
              }
            else
               if(progression == 3)
                 {
                  aux_tp_buy = CalculateTP(buy_lots[buys - 1]);
                 }

   if(sells <= 1)
     {
      aux_tp_sell = CalculateTP(sell_lots[0]);
     }
   else
      if(progression == 0)
        {
         aux_tp_sell = CalculateTP(sell_lots[0]);
        }
      else
         if(progression == 1)
           {
            aux_tp_sell = sells * CalculateTP(sell_lots[0]);
           }
         else
            if(progression == 2)
              {
               aux_tp_sell = CalculateTP(sell_lots[sells - 1]);
              }
            else
               if(progression == 3)
                 {
                  aux_tp_sell = CalculateTP(sell_lots[sells - 1]);
                 }

   double tp_buy = aux_tp_buy;
   double tp_sell = aux_tp_sell;

   if(buys >= 1)
     {

      buy_pip = CalculatePipValue(buy_lots[0]);
      for(i = 0; i < max_open_positions; i++)
         buy_v[i] = 0;

      for(i = 0; i < buys; i++)
        {
         buy_v[i] = MathRound(buy_lots[i] / buy_lots[0]);
         //Print(StringConcatenate("buy_v[",i,"] = ",buy_v[i]));
        }

      for(i = 0; i < buys; i++)
        {
         buy_a = buy_a + buy_v[i];
         buy_b = buy_b + buy_price[i] * buy_v[i];
        }

      buy_tar = aux_tp_buy / (buy_pip / ter_point);
      //Print(StringConcatenate("buy_tar 1: ",buy_tar));
      buy_tar = buy_tar + buy_b;
      //Print(StringConcatenate("buy_tar 2: ",buy_tar));
      buy_tar = buy_tar / buy_a;
      //Print(StringConcatenate("RESULT BUY: ",buy_tar));

      swapDiff = MathAbs(calculateTicksByPrice(total_buy_lots, total_buy_swap));
      line_buy = buy_tar + swapDiff;

      // TODO show the correct takeprofit buy line
      // calculate new line if there are hedge sell lots
      if(total_hedge_sell_lots > 0)
        {
         hedgeSellDiff = MathAbs(calculateTicksByPrice(total_hedge_sell_lots, total_hedge_sell_profit));
         line_buy = line_buy + hedgeSellDiff;
        }

      HorizontalLine(line_buy, "TakeProfit_buy", Color_TP_Buy, Style_TP, Width_TP);
      //debugCommentDyn+="\nline_buy: "+DoubleToString(line_buy,3);

      ter_IkarusChannel = buy_tar / ter_tick_size;    // ter_IkarusChannel=line_buy - line_sell

      // calculate trailing stop line
      if(buy_close_profit > 0 && displayPLL)
        {
         buy_tar = buy_close_profit / (buy_pip / ter_point);
         buy_tar = buy_tar + buy_b;
         line_buy_ts = buy_tar / buy_a;
         HorizontalLine(line_buy_ts, "ProfitLock_buy", Color_PL_Buy, Style_PL, Width_PL);
        }

      // #027: extern option to hide forecast lines
      // #029: hide forecast lines, if trailing stop is active
      if(show_forecast && line_buy_ts == 0)
        {
         // #022: show next line_buy/line_sell
         // #045: Fine tuning lines buy/sell next based on profit instead of grid_size
         if(gs_progression == 0)
            line_buy_next = buy_price[buys - 1] - ter_ticksPerGrid;
         else
            if(gs_progression == 1)
               line_buy_next = buy_price[buys - 1] - buys * ter_ticksPerGrid;
            else
               if(gs_progression == 2)
                  line_buy_next = buy_price[buys - 1] + calculateTicksByPrice(buy_lots[buys - 1], CalculateSL(buy_lots[buys - 1], buys));
               else
                  if(gs_progression == 3)
                     line_buy_next = buy_price[buys - 1] + calculateTicksByPrice(buy_lots[buys - 1], CalculateSL(buy_lots[buys - 1], buys));

         HorizontalLine(line_buy_next, "Next_buy", Color_NXT_Buy, Style_NX, Width_NX);
         
         // #020: show line, where the next line_buy / line_sell would be, if it would be opened right now
         if(accountState != as_green && total_buy_profit < 0)
           {
            myVal = MathRound(buy_lots[buys - 1] / buy_lots[0]);
            buy_a += myVal;
            buy_b = (buy_b + ter_priceSell * myVal);
            buy_tar = aux_tp_buy / (buy_pip / ter_point);
            line_buy_tmp = (buy_tar + buy_b) / buy_a + swapDiff;
            if(line_buy_tmp > 0)
               HorizontalLine(line_buy_tmp, "NewTakeProfit_buy", Color_TP_Buy, Style_TP, Width_TP);
           }
        }
     }

   if(sells >= 1)
     {

      sell_pip = CalculatePipValue(sell_lots[0]);
      for(i = 0; i < max_open_positions; i++)
         sell_v[i] = 0;

      for(i = 0; i < sells; i++)
        {
         sell_v[i] = MathRound(sell_lots[i] / sell_lots[0]);
        }
      // in one loop?
      for(i = 0; i < sells; i++)
        {
         sell_a = sell_a + sell_v[i];
         sell_b = sell_b + sell_price[i] * sell_v[i];
        }

      sell_tar = -1 * (aux_tp_sell / (sell_pip / ter_point));
      sell_tar = sell_tar + sell_b;
      sell_tar = sell_tar / sell_a;

      swapDiff = MathAbs(calculateTicksByPrice(total_sell_lots, total_sell_swap));
      line_sell = sell_tar - swapDiff;

      // TODO show the correct takeprofit sell line
      // calculate new line if there are hedge buy lots
      if(total_hedge_buy_lots > 0)
        {
         hedgeSellDiff = MathAbs(calculateTicksByPrice(total_hedge_buy_lots, total_hedge_buy_profit));
         line_sell = line_sell - hedgeSellDiff;
        }

      HorizontalLine(line_sell, "TakeProfit_sell", Color_TP_Sell, Style_TP, Width_TP);

      ter_IkarusChannel -= sell_tar / ter_tick_size;     // ter_IkarusChannel=line_buy - line_sell
      if(buys > 0 && sells > 0)                          // only valid, if both direction have positions
        {
         ter_IkarusChannel = MathAbs(ter_IkarusChannel);
        }
      else
        {
         ter_IkarusChannel = 0;
        }

      // calculate trailing stop line
      if(sell_close_profit > 0 && displayPLL)
        {
         sell_tar = -1 * (sell_close_profit / (sell_pip / ter_point));
         sell_tar = sell_tar + sell_b;
         line_sell_ts = sell_tar / sell_a;
         HorizontalLine(line_sell_ts, "ProfitLock_sell", Color_PL_Sell, Style_PL, Width_PL);
        }

      // #027: extern option to hide forecast lines
      // #029: hide forecast lines, if trailing stop is active
      if(show_forecast && line_sell_ts == 0)
        {
         // #022: show next line_buy/line_sell
         // line_sell_next=sell_price[sells-1]+CalculateVolume(sells)/min_lots*ter_ticksPerGrid;
         // #045: Fine tuning lines buy/sell next based on profit instead of grid_size
         if(gs_progression == 0)
            line_sell_next = sell_price[sells - 1] + ter_ticksPerGrid;
         else
            if(gs_progression == 1)
               line_sell_next = sell_price[sells - 1] + sells * ter_ticksPerGrid;
            else
               if(gs_progression == 2)
                  line_sell_next = sell_price[sells - 1] - calculateTicksByPrice(sell_lots[sells - 1], CalculateSL(sell_lots[sells - 1], sells));
               else
                  if(gs_progression == 3)
                     line_sell_next = sell_price[sells - 1] - calculateTicksByPrice(sell_lots[sells - 1], CalculateSL(sell_lots[sells - 1], sells));
         HorizontalLine(line_sell_next, "Next_sell", Color_NXT_Sell, Style_NX, Width_NX);

         // #020: show line, where the next line_buy / line_sell would be, if it would be opened at the actual price
         if(accountState != as_green && total_sell_profit < 0)
           {
            myVal = MathRound(sell_lots[sells - 1] / sell_lots[0]);
            sell_a += myVal;
            sell_b = (sell_b + ter_priceBuy * myVal);
            sell_tar = -1 * (aux_tp_sell / (sell_pip / ter_point));
            line_sell_tmp = (sell_b - (aux_tp_sell / (sell_pip / ter_point))) / sell_a - swapDiff;

            if(line_sell_tmp > 0)
               HorizontalLine(line_sell_tmp, "NewTakeProfit_sell", Color_TP_Sell, Style_TP, Width_TP);
           }
        }
     }

// #036: new line: margin call (free margin = 0)
// #039: fixing bug that Stop&Close buttons works only once: divide by zero, if total_buy/sell_lots = 0
   line_margincall = 0;
   if(show_forecast && (accountState == as_yellow || accountState == as_red))
     {
      double freeMargin = AccountFreeMargin();
      double maxLoss = freeMargin / ter_tick_value * ter_tick_size;
      //debugCommentDyn+="\nmaxLoss: "+DoubleToString(maxLoss,3);
      if(total_buy_profit < total_sell_profit)   // calculate line_margincall for worse profit
        {
         // formular to transfer an account price to chart diff:
         // profit (€) = tick_value * lot_size * chart diff (in ticks)
         // 30€ = 0,76 * 0.08 Lot * 500 (0,500) for USDJPY
         if(total_buy_lots > 0)
            line_margincall = ter_priceBuy - maxLoss / total_buy_lots;
         //debugCommentDyn+="\nline_margincall buys: "+DoubleToString(line_margincall,3);
         if(line_margincall > 0)
            HorizontalLine(line_margincall, "MarginCall", clrSilver, STYLE_SOLID, 5);
        }
      else
        {
         if(total_sell_lots > 0)
            line_margincall = ter_priceSell + maxLoss / total_sell_lots;
         //debugCommentDyn+="\nline_margincall sells: "+DoubleToString(line_margincall,3);
         if(maxLoss < ter_priceSell)
            HorizontalLine(line_margincall, "MarginCall", clrSilver, STYLE_SOLID, 5);
        }
     }

// make sure, all unused lines (value=0) will be hidden
// buy lines
   if(line_buy == 0)
      ObjectDelete("TakeProfit_buy");
   if(line_buy_next == 0)
      ObjectDelete("Next_buy");
   if(line_buy_tmp == 0)
      ObjectDelete("NewTakeProfit_buy");
   if(line_buy_ts == 0)
      ObjectDelete("ProfitLock_buy");

// sell lines
   if(line_sell == 0)
      ObjectDelete("TakeProfit_sell");
   if(line_sell_next == 0)
      ObjectDelete("Next_sell");
   if(line_sell_tmp == 0)
      ObjectDelete("NewTakeProfit_sell");
   if(line_sell_ts == 0)
      ObjectDelete("ProfitLock_sell");

   if(line_margincall == 0)
      ObjectDelete("MarginCall");
  }

//+---------------------------------------------------------------------------+
//  UTIL methods
//+---------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//  Trading Time
//+------------------------------------------------------------------+
bool Time_to_Trade()
  {

   datetime current_time = TimeCurrent();
   int      weekday, hour, minute, second;
   weekday = DayOfWeek();
   hour = TimeHour(current_time);
   minute = TimeMinute(current_time);
   second = TimeSeconds(current_time);
   if(Restricted_Working_Time)
     {
      if(weekday * 86400 + hour * 3600 + minute * 60 + second >= StartDay * 86400 + StartHour * 3600 + StartMin * 60 + StartSec
         && weekday * 86400 + hour * 3600 + minute * 60 + second <= StopDay * 86400 + StopHour * 3600 + StopMin * 60 + StopSec)
         return(true);
      else
         return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
// WRITE labels on screen
//+------------------------------------------------------------------+
void Write(string name, string s, int x, int y, string font, int size, color c)
  {
   if(ObjectFind(name) == -1)
     {
      ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name, OBJPROP_CORNER, 1);
     }
   ObjectSetText(name, s, size, font, c);
   ObjectSet(name, OBJPROP_XDISTANCE, x);
   ObjectSet(name, OBJPROP_YDISTANCE, y);
  }

//+------------------------------------------------------------------+
// HORIZONTAL LINE
//+------------------------------------------------------------------+
void HorizontalLine(double value, string name, color c, int style, int thickness)
  {
   if(ObjectFind(name) == -1)
     {
      ObjectCreate(name, OBJ_HLINE, 0, Time[0], value);
     }
   ObjectSet(name, OBJPROP_PRICE1, value);
   ObjectSet(name, OBJPROP_STYLE, style);
   ObjectSet(name, OBJPROP_COLOR, c);
   ObjectSet(name, OBJPROP_WIDTH, thickness);
  }

//=============================================================================
//                    OrderSendReliable()
//
// This is intended to be a drop-in replacement for OrderSend() which,
// one hopes, is more resistant to various forms of errors prevalent
// with MetaTrader.
//
// RETURN VALUE:
//
// Ticket number or -1 under some error conditions.  Check
// final error returned by Metatrader with OrderReliableLastErr().
// This will reset the value from GetLastError(), so in that sense it cannot
// be a total drop-in replacement due to Metatrader flaw.
//
// FEATURES:
//
//     * Re-trying under some error conditions, sleeping a random
//       time defined by an exponential probability distribution.
//
//     * Automatic normalization of Digits
//
//     * Automatically makes sure that stop levels are more than
//       the minimum stop distance, as given by the server. If they
//       are too close, they are adjusted.
//
//     * Automatically converts stop orders to market orders
//       when the stop orders are rejected by the server for
//       being to close to market.  NOTE: This intentionally
//       applies only to OP_BUYSTOP and OP_SELLSTOP,
//       OP_BUYLIMIT and OP_SELLLIMIT are not converted to market
//       orders and so for prices which are too close to current
//       this function is likely to loop a few times and return
//       with the "invalid stops" error message.
//       Note, the commentary in previous versions erroneously said
//       that limit orders would be converted.  Note also
//       that entering a BUYSTOP or SELLSTOP new order is distinct
//       from setting a stoploss on an outstanding order; use
//       OrderModifyReliable() for that.
//
//     * Displays various error messages on the log for debugging.
//
//
// Matt Kennel, 2006-05-28 and following
//
//=============================================================================
// #001: eliminate all warnings:
//    change internal declaration of slippage to mySlippage in all OrderSendReliable stuff
//    change internal declaration of magic to myMagic
int OrderSendReliable(string symbol, int cmd, double volume, double price,
                      int mySlippage, double stoploss, double takeprofit,
                      string comment, int myMagic, datetime expiration = 0,
                      color arrow_color = CLR_NONE)
  {

// ------------------------------------------------
// Check basic conditions see if trade is possible.
// ------------------------------------------------
   OrderReliable_Fname = "OrderSendReliable";
   OrderReliablePrint(" attempted " + OrderReliable_CommandString(cmd) + " " + (string)volume +
                      " lots @" + (string)price + " sl:" + (string)stoploss + " tp:" + (string)takeprofit);

   if(IsStopped())
     {
      OrderReliablePrint("error: IsStopped() == true");
      _OR_err = ERR_COMMON_ERROR;
      return(-1);
     }

   int cnt = 0;
   while(!IsTradeAllowed() && cnt < retry_attempts)
     {
      OrderReliable_SleepRandomTime(sleep_time, sleep_maximum);
      cnt++;
     }

   if(!IsTradeAllowed())
     {
      OrderReliablePrint("error: no operation possible because IsTradeAllowed()==false, even after retries.");
      _OR_err = ERR_TRADE_CONTEXT_BUSY;

      return(-1);
     }

//#004 new setting: max_spread; trades only, if spread <= max spread:
   int spread = 0;
   cnt = 0;
// wait a bit if spread is too high
   while(cnt < retry_attempts)
     {
      spread = (int)MarketInfo(symbol, MODE_SPREAD);
      if(spread > max_spread)
         OrderReliable_SleepRandomTime(sleep_time, sleep_maximum);
      else
         cnt = retry_attempts; // spread is ok; go on trading
      cnt++;
     }
   if(spread > max_spread)
     {
      OrderReliablePrint(" no operation because spread: " + (string)spread + " > max_spread: " + (string)max_spread);
      return(-1);
     }
//#004 end

// Normalize all price / stoploss / takeprofit to the proper # of digits.
   int digits = (int)MarketInfo(symbol, MODE_DIGITS);
   if(digits > 0)
     {
      price = NormalizeDouble(price, digits);
      stoploss = NormalizeDouble(stoploss, digits);
      takeprofit = NormalizeDouble(takeprofit, digits);
     }

   if(stoploss != 0)
      OrderReliable_EnsureValidStop(symbol, price, stoploss);

   int err = GetLastError(); // clear the global variable.
   err = 0;
   _OR_err = 0;
   bool exit_loop = false;
   bool limit_to_market = false;
   bool retVal = false;
// limit/stop order.
   int ticket = -1;

   if((cmd == OP_BUYSTOP) || (cmd == OP_SELLSTOP) || (cmd == OP_BUYLIMIT) || (cmd == OP_SELLLIMIT))
     {
      cnt = 0;
      while(!exit_loop)
        {
         if(IsTradeAllowed())
           {
            ticket = OrderSend(symbol, cmd, volume, price, mySlippage, stoploss,
                               takeprofit, comment, myMagic, expiration, arrow_color);
            err = GetLastError();
            _OR_err = err;
           }
         else
           {
            cnt++;
           }

         switch(err)
           {
            case ERR_NO_ERROR:
               exit_loop = true;
               break;

            // retryable errors
            case ERR_SERVER_BUSY:
            case ERR_NO_CONNECTION:
            case ERR_INVALID_PRICE:
            case ERR_OFF_QUOTES:
            case ERR_BROKER_BUSY:
            case ERR_TRADE_CONTEXT_BUSY:
               cnt++;
               break;

            case ERR_PRICE_CHANGED:
            case ERR_REQUOTE:
               RefreshRates();
               continue;   // we can apparently retry immediately according to MT docs.

            case ERR_INVALID_STOPS:
              {
               double servers_min_stop = MarketInfo(symbol, MODE_STOPLEVEL) * MarketInfo(symbol, MODE_POINT);
               if(cmd == OP_BUYSTOP)
                 {
                  // If we are too close to put in a limit/stop order so go to market.
                  if(MathAbs(MarketInfo(symbol, MODE_ASK) - price) <= servers_min_stop)
                     limit_to_market = true;

                 }
               else
                  if(cmd == OP_SELLSTOP)
                    {
                     // If we are too close to put in a limit/stop order so go to market.
                     if(MathAbs(MarketInfo(symbol, MODE_BID) - price) <= servers_min_stop)
                        limit_to_market = true;
                    }
               exit_loop = true;
               break;
              }
            default:
               // an apparently serious error.
               exit_loop = true;
               break;

           }  // end switch

         if(cnt > retry_attempts)
            exit_loop = true;

         if(exit_loop)
           {
            if(err != ERR_NO_ERROR)
              {
               OrderReliablePrint("non-retryable error: " + OrderReliableErrTxt(err));
              }
            if(cnt > retry_attempts)
              {
               OrderReliablePrint("retry attempts maxed at " + (string)retry_attempts);
              }
           }

         if(!exit_loop)
           {
            OrderReliablePrint("retryable error (" + (string)cnt + "/" + (string)retry_attempts +
                               "): " + OrderReliableErrTxt(err));
            OrderReliable_SleepRandomTime(sleep_time, sleep_maximum);
            RefreshRates();
           }
        }

      // We have now exited from loop.
      if(err == ERR_NO_ERROR)
        {
         OrderReliablePrint("apparently successful OP_BUYSTOP or OP_SELLSTOP order placed, details follow.");
         // #001: eliminate all warnings:
         retVal = OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
         OrderPrint();
         return(ticket); // SUCCESS!
        }
      if(!limit_to_market)
        {
         OrderReliablePrint("failed to execute stop or limit order after " + (string)cnt + " retries");
         OrderReliablePrint("failed trade: " + OrderReliable_CommandString(cmd) + " " + symbol +
                            "@" + (string)price + " tp@" + (string)takeprofit + " sl@" + (string)stoploss);
         OrderReliablePrint("last error: " + OrderReliableErrTxt(err));
         return(-1);
        }
     }  // end

   if(limit_to_market)
     {
      OrderReliablePrint("going from limit order to market order because market is too close.");
      if((cmd == OP_BUYSTOP) || (cmd == OP_BUYLIMIT))
        {
         cmd = OP_BUY;
         price = MarketInfo(symbol, MODE_ASK);
        }
      else
         if((cmd == OP_SELLSTOP) || (cmd == OP_SELLLIMIT))
           {
            cmd = OP_SELL;
            price = MarketInfo(symbol, MODE_BID);
           }
     }

// we now have a market order.
   err = GetLastError(); // so we clear the global variable.
   err = 0;
   _OR_err = 0;
   ticket = -1;

   if((cmd == OP_BUY) || (cmd == OP_SELL))
     {
      cnt = 0;
      while(!exit_loop)
        {
         if(IsTradeAllowed())
           {
            ticket = OrderSend(symbol, cmd, volume, price, mySlippage,
                               stoploss, takeprofit, comment, myMagic,
                               expiration, arrow_color);
            err = GetLastError();
            _OR_err = err;
           }
         else
           {
            cnt++;
           }
         switch(err)
           {
            case ERR_NO_ERROR:
               exit_loop = true;
               break;

            case ERR_SERVER_BUSY:
            case ERR_NO_CONNECTION:
            case ERR_INVALID_PRICE:
            case ERR_OFF_QUOTES:
            case ERR_BROKER_BUSY:
            case ERR_TRADE_CONTEXT_BUSY:
               cnt++; // a retryable error
               break;

            case ERR_PRICE_CHANGED:
            case ERR_REQUOTE:
               RefreshRates();
               continue; // we can apparently retry immediately according to MT docs.

            default:
               // an apparently serious, unretryable error.
               exit_loop = true;
               break;

           }  // end switch

         if(cnt > retry_attempts)
            exit_loop = true;

         if(!exit_loop)
           {
            OrderReliablePrint("retryable error (" + (string)cnt + "/" +
                               (string)retry_attempts + "): " + OrderReliableErrTxt(err));
            OrderReliable_SleepRandomTime(sleep_time, sleep_maximum);
            RefreshRates();
           }

         if(exit_loop)
           {
            if(err != ERR_NO_ERROR)
              {
               OrderReliablePrint("non-retryable error: " + OrderReliableErrTxt(err));
              }
            if(cnt > retry_attempts)
              {
               OrderReliablePrint("retry attempts maxed at " + (string)retry_attempts);
              }
           }
        }

      // we have now exited from loop.
      if(err == ERR_NO_ERROR)
        {
         //#004 new setting: max_spread; add spread info for this position
         OrderReliablePrint("apparently successful OP_BUY or OP_SELL order placed(spread: " + (string)spread + "), details follow.");
         // #001: eliminate all warnings:
         retVal = OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
         OrderPrint();
         return(ticket); // SUCCESS!
        }
      OrderReliablePrint("failed to execute OP_BUY/OP_SELL, after " + (string)cnt + " retries");
      OrderReliablePrint("failed trade: " + OrderReliable_CommandString(cmd) + " " + symbol +
                         "@" + (string)price + " tp@" + (string)takeprofit + " sl@" + (string)stoploss);
      OrderReliablePrint("last error: " + OrderReliableErrTxt(err));
      return(-1);
     }
// #001: eliminate all warnings:
   return(-1);
  }

//=============================================================================
//                    OrderCloseReliable()
//
// This is intended to be a drop-in replacement for OrderClose() which,
// one hopes, is more resistant to various forms of errors prevalent
// with MetaTrader.
//
// RETURN VALUE:
//
//    TRUE if successful, FALSE otherwise
//
//
// FEATURES:
//
//     * Re-trying under some error conditions, sleeping a random
//       time defined by an exponential probability distribution.
//
//     * Displays various error messages on the log for debugging.
//
//
// Derk Wehler, ashwoods155@yahoo.com     2006-07-19
//
//=============================================================================
bool OrderCloseReliable(int ticket, double lots, double price,
                        int mySlippage, color arrow_color = CLR_NONE)
  {
   int nOrderType;
   string strSymbol;
   OrderReliable_Fname = "OrderCloseReliable";

   OrderReliablePrint(" attempted close of #" + (string)ticket + " price:" + (string)price +
                      " lots:" + (string)lots + " slippage:" + (string)mySlippage);

// collect details of order so that we can use GetMarketInfo later if needed
   if(!OrderSelect(ticket, SELECT_BY_TICKET))
     {
      _OR_err = GetLastError();
      OrderReliablePrint("error: " + ErrorDescription(_OR_err));
      return(false);
     }
   else
     {
      nOrderType = OrderType();
      strSymbol = OrderSymbol();
     }

   if(nOrderType != OP_BUY && nOrderType != OP_SELL)
     {
      _OR_err = ERR_INVALID_TICKET;
      OrderReliablePrint("error: trying to close ticket #" + (string)ticket + ", which is " + OrderReliable_CommandString(nOrderType) + ", not OP_BUY or OP_SELL");
      return(false);
     }

   if(IsStopped())
     {
      OrderReliablePrint("error: IsStopped() == true");
      return(false);
     }

   int cnt = 0;
   int err = GetLastError(); // so we clear the global variable.
   err = 0;
   _OR_err = 0;
   bool exit_loop = false;
   cnt = 0;
   bool result = false;

   while(!exit_loop)
     {
      if(IsTradeAllowed())
        {
         result = OrderClose(ticket, lots, price, mySlippage, arrow_color);
         err = GetLastError();
         _OR_err = err;
        }
      else
        {
         cnt++;
        }

      if(result == true)
         exit_loop = true;

      switch(err)
        {
         case ERR_NO_ERROR:
            exit_loop = true;
            break;

         case ERR_SERVER_BUSY:
         case ERR_NO_CONNECTION:
         case ERR_INVALID_PRICE:
         case ERR_OFF_QUOTES:
         case ERR_BROKER_BUSY:
         case ERR_TRADE_CONTEXT_BUSY:
         case ERR_TRADE_TIMEOUT:      // for modify this is a retryable error, I hope.
            cnt++;    // a retryable error
            break;

         case ERR_PRICE_CHANGED:
         case ERR_REQUOTE:
            continue;    // we can apparently retry immediately according to MT docs.

         default:
            // an apparently serious, unretryable error.
            exit_loop = true;
            break;

        }  // end switch

      if(cnt > retry_attempts)
         exit_loop = true;

      if(!exit_loop)
        {
         OrderReliablePrint("retryable error (" + (string)cnt + "/" + (string)retry_attempts +
                            "): " + OrderReliableErrTxt(err));
         OrderReliable_SleepRandomTime(sleep_time, sleep_maximum);
         // Added by Paul Hampton-Smith to ensure that price is updated for each retry
         if(nOrderType == OP_BUY)
            price = NormalizeDouble(MarketInfo(strSymbol, MODE_BID), (int)MarketInfo(strSymbol, MODE_DIGITS));
         if(nOrderType == OP_SELL)
            price = NormalizeDouble(MarketInfo(strSymbol, MODE_ASK), (int)MarketInfo(strSymbol, MODE_DIGITS));
        }

      if(exit_loop)
        {
         if((err != ERR_NO_ERROR) && (err != ERR_NO_RESULT))
            OrderReliablePrint("non-retryable error: " + OrderReliableErrTxt(err));

         if(cnt > retry_attempts)
            OrderReliablePrint("retry attempts maxed at " + (string)retry_attempts);
        }
     }

// we have now exited from loop.
   if((result == true) || (err == ERR_NO_ERROR))
     {
      OrderReliablePrint("apparently successful close order, updated trade details follow.");
      // #001: eliminate all warnings:
      bool retVal = OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
      OrderPrint();
      return(true); // SUCCESS!
     }

   OrderReliablePrint("failed to execute close after " + (string)cnt + " retries");
   OrderReliablePrint("failed close: Ticket #" + (string)ticket + ", Price: " +
                      (string)price + ", Slippage: " + (string)mySlippage);
   OrderReliablePrint("last error: " + OrderReliableErrTxt(err));

   return(false);
  }

//=============================================================================
//                    OrderSendReliableMKT()
//
// This is intended to be an alternative for OrderSendReliable() which
// will update market-orders in the retry loop with the current Bid or Ask.
// Hence with market orders there is a greater likelihood that the trade will
// be executed versus OrderSendReliable(), and a greater likelihood it will
// be executed at a price worse than the entry price due to price movement.
//
// RETURN VALUE:
//
// Ticket number or -1 under some error conditions.  Check
// final error returned by Metatrader with OrderReliableLastErr().
// This will reset the value from GetLastError(), so in that sense it cannot
// be a total drop-in replacement due to Metatrader flaw.
//
// FEATURES:
//
//     * Most features of OrderSendReliable() but for market orders only.
//       Command must be OP_BUY or OP_SELL, and specify Bid or Ask at
//       the time of the call.
//
//     * If price moves in an unfavorable direction during the loop,
//       e.g. from requotes, then the slippage variable it uses in
//       the real attempt to the server will be decremented from the passed
//       value by that amount, down to a minimum of zero.   If the current
//       price is too far from the entry value minus slippage then it
//       will not attempt an order, and it will signal, hedgely,
//       an ERR_INVALID_PRICE (displayed to log as usual) and will continue
//       to loop the usual number of times.
//
//     * Displays various error messages on the log for debugging.
//
//
// Matt Kennel, 2006-08-16
//
//=============================================================================
int OrderSendReliableMKT(string symbol, int cmd, double volume, double price,
                         int mySlippage, double stoploss, double takeprofit,
                         string comment, int myMagic, datetime expiration = 0,
                         color arrow_color = CLR_NONE)
  {

// ------------------------------------------------
// Check basic conditions see if trade is possible.
// ------------------------------------------------
   OrderReliable_Fname = "OrderSendReliableMKT";
   OrderReliablePrint(" attempted " + OrderReliable_CommandString(cmd) + " " + (string)volume +
                      " lots @" + (string)price + " sl:" + (string)stoploss + " tp:" + (string)takeprofit);

   if((cmd != OP_BUY) && (cmd != OP_SELL))
     {
      OrderReliablePrint("Improper non market-order command passed.  Nothing done.");
      _OR_err = ERR_MALFUNCTIONAL_TRADE;
      return(-1);
     }

//if (!IsConnected())
//{
// OrderReliablePrint("error: IsConnected() == false");
// _OR_err = ERR_NO_CONNECTION;
// return(-1);
//}

   if(IsStopped())
     {
      OrderReliablePrint("error: IsStopped() == true");
      _OR_err = ERR_COMMON_ERROR;
      return(-1);
     }

   int cnt = 0;
   while(!IsTradeAllowed() && cnt < retry_attempts)
     {
      OrderReliable_SleepRandomTime(sleep_time, sleep_maximum);
      cnt++;
     }

   if(!IsTradeAllowed())
     {
      OrderReliablePrint("error: no operation possible because IsTradeAllowed()==false, even after retries.");
      _OR_err = ERR_TRADE_CONTEXT_BUSY;

      return(-1);
     }

// Normalize all price / stoploss / takeprofit to the proper # of digits.
   int digits = (int)MarketInfo(symbol, MODE_DIGITS);
   if(digits > 0)
     {
      price = NormalizeDouble(price, digits);
      stoploss = NormalizeDouble(stoploss, digits);
      takeprofit = NormalizeDouble(takeprofit, digits);
     }

   if(stoploss != 0)
      OrderReliable_EnsureValidStop(symbol, price, stoploss);

   int err = GetLastError(); // clear the global variable.
   err = 0;
   _OR_err = 0;
   bool exit_loop = false;

// limit/stop order.
   int ticket = -1;

// we now have a market order.
   err = GetLastError(); // so we clear the global variable.
   err = 0;
   _OR_err = 0;
   ticket = -1;

   if((cmd == OP_BUY) || (cmd == OP_SELL))
     {
      cnt = 0;
      while(!exit_loop)
        {
         if(IsTradeAllowed())
           {
            double pnow = price;
            int slippagenow = mySlippage;
            if(cmd == OP_BUY)
              {
               // modification by Paul Hampton-Smith to replace RefreshRates()
               pnow = NormalizeDouble(MarketInfo(symbol, MODE_ASK), (int)MarketInfo(symbol, MODE_DIGITS)); // we are buying at Ask
               if(pnow > price)
                 {
                  slippagenow = mySlippage - (int)((pnow - price) / MarketInfo(symbol, MODE_POINT));
                 }
              }
            else
               if(cmd == OP_SELL)
                 {
                  // modification by Paul Hampton-Smith to replace RefreshRates()
                  pnow = NormalizeDouble(MarketInfo(symbol, MODE_BID), (int)MarketInfo(symbol, MODE_DIGITS)); // we are buying at Ask
                  if(pnow < price)
                    {
                     // moved in an unfavorable direction
                     slippagenow = mySlippage - (int)((price - pnow) / MarketInfo(symbol, MODE_POINT));
                    }
                 }
            if(slippagenow > mySlippage)
               slippagenow = mySlippage;
            if(slippagenow >= 0)
              {

               ticket = OrderSend(symbol, cmd, volume, pnow, slippagenow,
                                  stoploss, takeprofit, comment, myMagic,
                                  expiration, arrow_color);
               err = GetLastError();
               _OR_err = err;
              }
            else
              {
               // too far away, hedgely signal ERR_INVALID_PRICE, which
               // will result in a sleep and a retry.
               err = ERR_INVALID_PRICE;
               _OR_err = err;
              }
           }
         else
           {
            cnt++;
           }
         switch(err)
           {
            case ERR_NO_ERROR:
               exit_loop = true;
               break;

            case ERR_SERVER_BUSY:
            case ERR_NO_CONNECTION:
            case ERR_INVALID_PRICE:
            case ERR_OFF_QUOTES:
            case ERR_BROKER_BUSY:
            case ERR_TRADE_CONTEXT_BUSY:
               cnt++; // a retryable error
               break;

            case ERR_PRICE_CHANGED:
            case ERR_REQUOTE:
               // Paul Hampton-Smith removed RefreshRates() here and used MarketInfo() above instead
               continue; // we can apparently retry immediately according to MT docs.

            default:
               // an apparently serious, unretryable error.
               exit_loop = true;
               break;

           }  // end switch

         if(cnt > retry_attempts)
            exit_loop = true;

         if(!exit_loop)
           {
            OrderReliablePrint("retryable error (" + (string)cnt + "/" +
                               (string)retry_attempts + "): " + OrderReliableErrTxt(err));
            OrderReliable_SleepRandomTime(sleep_time, sleep_maximum);
           }

         if(exit_loop)
           {
            if(err != ERR_NO_ERROR)
              {
               OrderReliablePrint("non-retryable error: " + OrderReliableErrTxt(err));
              }
            if(cnt > retry_attempts)
              {
               OrderReliablePrint("retry attempts maxed at " + (string)retry_attempts);
              }
           }
        }

      // we have now exited from loop.
      if(err == ERR_NO_ERROR)
        {
         OrderReliablePrint("apparently successful OP_BUY or OP_SELL order placed, details follow.");
         // #001: eliminate all warnings:
         bool retVal = OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
         OrderPrint();
         return(ticket); // SUCCESS!
        }
      OrderReliablePrint("failed to execute OP_BUY/OP_SELL, after " + (string)cnt + " retries");
      OrderReliablePrint("failed trade: " + OrderReliable_CommandString(cmd) + " " + symbol +
                         "@" + (string)price + " tp@" + (string)takeprofit + " sl@" + (string)stoploss);
      OrderReliablePrint("last error: " + OrderReliableErrTxt(err));
      return(-1);
     }
// #001: eliminate all warnings:
   return(-1);
  }

//+------------------------------------------------------------------+
//| OrderReliable_CommandString                                      |
//+------------------------------------------------------------------+
string OrderReliable_CommandString(int cmd)
  {
   if(cmd == OP_BUY)
      return("OP_BUY");

   if(cmd == OP_SELL)
      return("OP_SELL");

   if(cmd == OP_BUYSTOP)
      return("OP_BUYSTOP");

   if(cmd == OP_SELLSTOP)
      return("OP_SELLSTOP");

   if(cmd == OP_BUYLIMIT)
      return("OP_BUYLIMIT");

   if(cmd == OP_SELLLIMIT)
      return("OP_SELLLIMIT");

   return("(CMD==" + (string)cmd + ")");
  }

//=============================================================================
//
//                 OrderReliable_SleepRandomTime()
//
// This sleeps a random amount of time defined by an exponential
// probability distribution. The mean time, in Seconds is given
// in 'mean_time'.
//
// This is the back-off strategy used by Ethernet.  This will
// quantize in tenths of seconds, so don't call this with a too
// small a number.  This returns immediately if we are backtesting
// and does not sleep.
//
// Matt Kennel mbkennelfx@gmail.com.
//
//=============================================================================
void OrderReliable_SleepRandomTime(double mean_time, int max_time)
  {
   if(IsTesting())
      return;    // return immediately if backtesting.

   double tenths = MathCeil(mean_time / 0.1);
   if(tenths <= 0)
      return;

   int maxtenths = max_time * 10;
   double p = 1.0 - 1.0 / tenths;

   Sleep(100);    // one tenth of a second PREVIOUS VERSIONS WERE STUPID HERE.

   for(int i = 0; i < maxtenths; i++)
     {
      if(MathRand() > p * 32768)
         break;

      // MathRand() returns in 0..32767
      Sleep(100);
     }
  }

//=============================================================================
//
//                 OrderReliable_EnsureValidStop()
//
//    Adjust stop loss so that it is legal.
//
//
//=============================================================================
void OrderReliable_EnsureValidStop(string symbol, double price, double &sl)
  {
// Return if no S/L
   if(sl == 0)
      return;

   double servers_min_stop = MarketInfo(symbol, MODE_STOPLEVEL) * MarketInfo(symbol, MODE_POINT);
   if(MathAbs(price - sl) <= servers_min_stop)
     {
      // we have to adjust the stop.
      if(price > sl)
         sl = price - servers_min_stop; // we are long

      else
         if(price < sl)
            sl = price + servers_min_stop; // we are short

         else
            OrderReliablePrint("EnsureValidStop: error, passed in price == sl, cannot adjust");

      sl = NormalizeDouble(sl, (int)MarketInfo(symbol, MODE_DIGITS));
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderReliableLastErr()
  {
   return (_OR_err);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OrderReliableErrTxt(int err)
  {
   return ("" + (string)err + ":" + ErrorDescription(err));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderReliablePrint(string s)
  {
  string msg;
// Print to log prepended with stuff;
   if(!(IsTesting() || IsOptimization()))
      msg = OrderReliable_Fname + " " + OrderReliableVersion + ":" + s;
      Print(msg);
      if(loginfo) {
            Log(msg);
      }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                    BREAK-EVEN CALCULATION                             |
//+------------------------------------------------------------------+
void BreakEven()
  {
   static bool first = true;
   static int pre_OrdersTotal = 0;
   int _OrdersTotal = (buys + hedge_buys + sells + hedge_sells);

   double local_total_buy_profit = 0, local_total_sell_profit = 0;
   local_total_buy_profit = total_buy_profit + total_hedge_buy_profit;
   local_total_sell_profit = total_sell_profit + total_hedge_sell_profit;
   double local_total_buy_lots = 0, local_total_sell_lots = 0;
   local_total_buy_lots = total_buy_lots + total_hedge_buy_lots;
   local_total_sell_lots = total_sell_lots + total_hedge_sell_lots;

// If this is the first run of the Expert Advisor, we do not know the number of orders on the previous tick.
// Therefore, we simply remember it, make a note that the first launch has already taken place, and exit.
   if(first)
     {
      pre_OrdersTotal = _OrdersTotal;
      first = false;
      return;
     }

// Compare the number of positions on the previous tick with the current number
// If it has changed, count the levels
   if(_OrdersTotal > pre_OrdersTotal ||  _OrdersTotal < pre_OrdersTotal)

      // Remember the number of positions
      pre_OrdersTotal = _OrdersTotal;

// Calculations of breakeven levels (расчитано в Updeit Vars)_?????????????????????????
   dLots = (local_total_buy_lots) - (local_total_sell_lots); // difference between the volumes of BUY and SELL orders
   dlots = NormalizeDouble(dLots, Digits);           //remove the error in the calculation of the difference in the volume of orders
   double aux_Ur_total_BE = 0, aux_Ur_BE_buy = 0, aux_Ur_BE_sell = 0;

   if(dlots != 0)
     {
      if(dlots > 0)
         aux_Ur_total_BE = Bid - ((local_total_buy_profit + local_total_sell_profit) / (ter_tick_value * (dlots)) * Point);   //total breakeven level for ALL open orders
      if(dlots < 0)
         aux_Ur_total_BE = Ask - ((local_total_buy_profit + local_total_sell_profit) / (ter_tick_value * (dlots)) * Point);   //total breakeven level for ALL open orders
     }

   if(total_buy_lots > 0)
      aux_Ur_BE_buy = Bid - (local_total_buy_profit / (ter_tick_value * local_total_buy_lots) * Point);     //breakeven level for BUY orders
   if(total_sell_lots > 0)
      aux_Ur_BE_sell = Ask + (local_total_sell_profit / (ter_tick_value * local_total_sell_lots) * Point);   //breakeven level for SELL orders

   if(local_total_buy_lots != 0 && local_total_sell_lots == 0)
      aux_Ur_total_BE = aux_Ur_BE_buy;
   if(local_total_sell_lots != 0 && local_total_buy_lots == 0)
      aux_Ur_total_BE = aux_Ur_BE_sell;

   Ur_total_BE = aux_Ur_total_BE;
   Ur_BE_buy = aux_Ur_BE_buy;
   Ur_BE_sell = aux_Ur_BE_sell;

//+------------------------------------------------------------------+
//drawing breakeven labels

   datetime time;
   time = iTime(Symbol(), Period(), 0);
   double price_BE_buy = Ur_BE_buy,
          price_BE_sell = Ur_BE_sell,
          price_BE_total = Ur_total_BE;

   if(displayBES)
     {
      if(ObjectFind("BE_buy") != -1)
         ObjectMove("BE_buy", 0, time, price_BE_buy);
      else
        {
         ObjectCreate("BE_buy", OBJ_ARROW, 0, time, price_BE_buy);
         ObjectSet("BE_buy", OBJPROP_ARROWCODE, 6);
         ObjectSet("BE_buy", OBJPROP_WIDTH, 1);
         ObjectSet("BE_buy", OBJPROP_COLOR, Color_BE_Buy);
        }

      if(ObjectFind("BE_sell") != -1)
         ObjectMove("BE_sell", 0, time, price_BE_sell);
      else
        {
         ObjectCreate("BE_sell", OBJ_ARROW, 0, time, price_BE_sell);
         ObjectSet("BE_sell", OBJPROP_ARROWCODE, 6);
         ObjectSet("BE_sell", OBJPROP_WIDTH, 1);
         ObjectSet("BE_sell", OBJPROP_COLOR, Color_BE_Sell);
        }
     }

   if(displayBE)
     {
      if(ObjectFind("BE_total") != -1)
         ObjectMove("BE_total", 0, time, price_BE_total);
      else
        {
         ObjectCreate("BE_total", OBJ_ARROW, 0, time, price_BE_total);
         ObjectSet("BE_total", OBJPROP_ARROWCODE, 6);
         ObjectSet("BE_total", OBJPROP_WIDTH, 1);
         ObjectSet("BE_total", OBJPROP_COLOR, Color_BE);
        }
     }

  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                    CALCULATION of equal lock level                     |
//+------------------------------------------------------------------+
void EqualLockLevel()
  {

//level calculations:
//---------------------------------------------------------------------------------------------//
   double UrRL = 0, dUrRL = 0;

   if(dlots != 0)
     {
      if(dlots > 0)
         dUrRL = (dlots * ter_MODE_MARGINREQUIRED - freemargin) / (ter_tick_value * dlots);              //distance to Equal Lock level
      if(dlots < 0)
         dUrRL = (dlots * ter_MODE_MARGINREQUIRED + freemargin) / (ter_tick_value * dlots);              //distance to Equal Lock level
      if(dlots > 0)
         UrRL = Bid + dUrRL * Point;    //equal lock level
      if(dlots < 0)
         UrRL = Ask - dUrRL * Point;    //equal lock level
     }

  }
//---------------------------------------------------------------------------------------------//
//444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444//
//функция отрисовки линий - уровней:
//---------------------------------------------------------------------------------------------//
void driveline(string Text, double Znach, color Color, int Style, int Width)
  {
   ObjectDelete(Text);
   ObjectCreate(Text, OBJ_HLINE, 0, 0, Znach);
   ObjectSet(Text, OBJPROP_COLOR, Color);
   ObjectSet(Text, OBJPROP_STYLE, Style);
   ObjectSet(Text, OBJPROP_WIDTH, Width);
  }
//---------------------------------------------------------------------------------------------//
//+------------------------------------------------------------------+
//|                        NewBarTF                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBarTF(int period)
  {
   static datetime old_time=NULL;
   datetime        new_time=iTime(Symbol(),period,0);

   if(new_time!=old_time)
     {
      old_time=new_time;
      return true;
     }

   return false;
  }
//+------------------------------------------------------------------+

// ---------------------------------------------------------
// function getMagicNumber
// Calculate MagicNumber in automatic mode 
// ---------------------------------------------------------
int getMagicNumber() {
   int Magic=magic;
   if(Magic < 1) Magic=1000;
   if(Symbol()=="AUDCADm" || Symbol()=="AUDCAD")      Magic=Magic+1;
   if(Symbol()=="AUDCHFm" || Symbol()=="AUDCHF")      Magic=Magic+2;
   if(Symbol()=="AUDJPYm" || Symbol()=="AUDJPY")      Magic=Magic+3;
   if(Symbol()=="AUDNZDm" || Symbol()=="AUDNZD")      Magic=Magic+4;
   if(Symbol()=="AUDUSDm" || Symbol()=="AUDUSD")      Magic=Magic+5;
   if(Symbol()=="CADCHFm" || Symbol()=="CADCHF")      Magic=Magic+6;
   if(Symbol()=="CADJPYm" || Symbol()=="CADJPY")      Magic=Magic+7;
   if(Symbol()=="CHFJPYm" || Symbol()=="CHFJPY")      Magic=Magic+8;
   if(Symbol()=="EURAUDm" || Symbol()=="EURAUD")      Magic=Magic+9;
   if(Symbol()=="EURCADm" || Symbol()=="EURCAD")      Magic=Magic+10;
   if(Symbol()=="EURCHFm" || Symbol()=="EURCHF")      Magic=Magic+11;
   if(Symbol()=="EURGBPm" || Symbol()=="EURGBP")      Magic=Magic+12;
   if(Symbol()=="EURJPYm" || Symbol()=="EURJPY")      Magic=Magic+13;
   if(Symbol()=="EURNZDm" || Symbol()=="EURNZD")      Magic=Magic+14;
   if(Symbol()=="EURUSDm" || Symbol()=="EURUSD")      Magic=Magic+16;
   if(Symbol()=="GBPAUDm" || Symbol()=="GBPAUD")      Magic=Magic+17;
   if(Symbol()=="GBPCADm" || Symbol()=="GBPCAD")      Magic=Magic+18;
   if(Symbol()=="GBPCHFm" || Symbol()=="GBPCHF")      Magic=Magic+19;
   if(Symbol()=="GBPJPYm" || Symbol()=="GBPJPY")      Magic=Magic+20;
   if(Symbol()=="GBPNZDm" || Symbol()=="GBPNZD")      Magic=Magic+21;
   if(Symbol()=="GBPUSDm" || Symbol()=="GBPUSD")      Magic=Magic+22;
   if(Symbol()=="NZDCADm" || Symbol()=="NZDCAD")      Magic=Magic+23;
   if(Symbol()=="NZDCHFm" || Symbol()=="NZDCHF")      Magic=Magic+24;
   if(Symbol()=="NZDJPYm" || Symbol()=="NZDJPY")      Magic=Magic+26;
   if(Symbol()=="NZDUSDm" || Symbol()=="NZDUSD")      Magic=Magic+27;
   if(Symbol()=="USDCADm" || Symbol()=="USDCAD")      Magic=Magic+28;
   if(Symbol()=="USDCHFm" || Symbol()=="USDCHF")      Magic=Magic+29;
   if(Symbol()=="USDJPYm" || Symbol()=="USDJPY")      Magic=Magic+30;
   if(Symbol()=="USDSGDm" || Symbol()=="USDSGD")      Magic=Magic+31;
   if(Symbol()=="SGDJPYm" || Symbol()=="SGDJPY")      Magic=Magic+32;
   if(Symbol()=="BTCUSD" || Symbol()=="BTCUSD")       Magic=Magic+50;
   if(Symbol()=="XAUUSD" || Symbol()=="XAUUSD")       Magic=Magic+51;
   
   return Magic;
}


//+------------------------------------------------------------------+
//| START Function Log                                               |
//+------------------------------------------------------------------+
void Log(string mymsg) {
   if(loginfo==1)
     {
      string nome_file = DoubleToString(versionBMI, 0) + "_" + Symbol() + "_" + IntegerToString(magic) + "_log.txt";
      //nome del file su cui scrivere
      string fileName = StringConcatenate(versionBMI, Symbol(), "_", Month(), "_", Day(), ".log");
      int handleFile=FileOpen(nome_file, FILE_CSV|FILE_READ|FILE_WRITE, ','); //routine di apertura
      if(handleFile>0)
        {
         FileSeek(handleFile, 0, SEEK_END);
         FileWrite(handleFile, IntegerToString(Day()) + "-" + IntegerToString(Month()) + "-" + IntegerToString(Year()) + " " + IntegerToString(Hour()) + ":" + IntegerToString(Minute()) + ":" + IntegerToString(Seconds()) + " - " + Symbol() + "|" + IntegerToString(magic) + "| ---> " + mymsg);
         //messaggio da scrivere
         FileClose(handleFile);//qui chiudiamo il file
        }
     }
}

string TimeFrameToString(int timeframe) {
    string strTimeFrame;
    switch (timeframe) {
        case PERIOD_M1:  strTimeFrame = "M1";  break;
        case PERIOD_M5:  strTimeFrame = "M5";  break;
        case PERIOD_M15: strTimeFrame = "M15"; break;
        case PERIOD_M30: strTimeFrame = "M30"; break;
        case PERIOD_H1:  strTimeFrame = "H1";  break;
        case PERIOD_H4:  strTimeFrame = "H4";  break;
        case PERIOD_D1:  strTimeFrame = "D1";  break;
        case PERIOD_W1:  strTimeFrame = "W1";  break;
        case PERIOD_MN1: strTimeFrame = "MN1"; break;
        default:         strTimeFrame = "Unknown"; break;
    }
    return strTimeFrame;
}


