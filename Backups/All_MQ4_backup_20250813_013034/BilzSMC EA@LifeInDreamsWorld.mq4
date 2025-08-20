#property copyright "Copyright2023 BlizSMC PREMIUM"
#property link ""
#property description "Coder init: hashemibilal5@gmail.com"
#property description "Mail us @ hashemibilal5@gmail.com"
#property strict
//---
enum ENUM_LOT_MODE
{
  LOT_MODE_FIXED = 1,   // Fixed Lot
  LOT_MODE_PERCENT = 2, // Percent Lot
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_TYPE_GRID_LOT
{
  fix_lot = 0,    // Fixed Start Lot 0.01 / 0.01 / 0.01 / 0.01 / 0.01 /.............
  Summ_lot = 1,   // Summ Sart Lot   0.01 / 0.02 / 0.03 / 0.04 / 0.05 /.............
  Martingale = 2, // Martingale Lot  0.01 / 0.02 / 0.04 / 0.08 / 0.16 /.............
  Step_lot = 3    // Step Lot        0.01 / 0.01 / 0.01 / 0.02 / 0.02 / 0.02 / 0.03 / 0.03 / 0.03 / 0.04 / 0.04 / 0.04 /............
};

//--- input parameters
extern string Version__ = "----------------------------------------------------------------";
extern string Version1__ = "-----------------xBest   Rv3.47 --------------------------------";
extern string Version2__ = "----------------------------------------------------------------";

extern string InpChartDisplay__ = "------------------------Display Info--------------------";
extern bool InpChartDisplay = true;              // Display Info
extern bool InpDisplayInpBackgroundColor = TRUE; // Display background color
extern color InpBackgroundColor = Black;          // background color

extern string Switches = "--------------------------- Switches --------------------------- ";
extern bool InpManualInitGrid = FALSE; // Start MANUAL Order  Grid  (Only if A / B Enable)
extern bool InpOpenNewOrders = TRUE;  // Open New Orders ?
extern bool OpenNewOrdersGrid = TRUE; // Enable Grid ?
extern bool InpCloseAllNow = false;   // closes all orders now
extern string Magic = "--------Magic Number Engine---------";
extern string Magic_ = "--------If all the engines are disabled runs a motor in buy and sell ---------";
input bool InpEnableEngineA = TRUE; // Enable Engine A   [BUY]
input int InpMagic = 7799;           // Magic Number  A
input bool InpEnableEngineB = TRUE; // Enable Engine B   [SELL]
input int InpMagic2 = 9977;          // Magic Number  B
extern string ConfigLOTE__ = "---------------------------Config Lot INIT--------------------------------------";
input ENUM_LOT_MODE InpLotMode = LOT_MODE_PERCENT; // Lot Mode
input double InpFixedLot = 0.01;                   // Fixed Lot
input double InpPercentLot = 0.03;                 // Percent Lot
input int InpTakeProfit = 30;                    // Take Profit in Pips

extern string XBEST_ConfigGrid__ = "---------------------------Config Grid--------------------------------------";
input ENUM_TYPE_GRID_LOT TypeGridLot = Martingale; // Type Grid Lot
input int InpGridSize = 3;                         // Step Size in Pips
input double InpGridFactor = 1.3;                  // Grid Increment Factor (If Martingale)
input int InpGridStepLot = 4;                      // STEP LOT (If  Step Lot)
input double InpMaxLot = 99;                      // Max Lot
input int InpHedgex =6;                           // After Level Change Lot A to B (Necessari all Engine Enable)
input bool GridAllDirect = false;                  // Enable Grid Dual Side

extern string FilterOpenOneCandle__ = "--------------------Filter One Order by Candle--------------";
input bool InpOpenOneCandle = true;                         // Open one order by candle
input ENUM_TIMEFRAMES InpTimeframeBarOpen = PERIOD_CURRENT; // Timeframe OpenOneCandle

extern string MinimalProfitClose__ = "--------------------Minimal Profit Close/ Protect Grid --------------";
input bool InpEnableMinProfit = true;  // Enable  Minimal Profit Close
input bool  MinimalProfitProtectGrid  = true; // Enable Protect Grid from Profit Orders MinProfit
input double MinProfit = 3;        // Minimal Profit Close /Protect Grid
input int QtdTradesMinProfit = 3;      // Qtd Trades to Minimal Profit Close/ Protect Grid
extern string Config__ = "---------------------------Config--------------------------------------";
input int InpHedge = 0;        // Hedge After Level
input int InpDailyTarget = 50; // Daily Target in Money

extern string MovingAverageConfig__ = "-----------------------------Moving Average-----------------------";
input ENUM_TIMEFRAMES InpMaFrame = PERIOD_CURRENT; // Moving Average TimeFrame
input bool InpMAFilterInverter = true;            // If True Sinal Moving Average Filter
input int InpMaPeriod = 34;                         // Moving Average Period
input ENUM_MA_METHOD InpMaMethod = MODE_EMA;       // Moving Average Method
input ENUM_APPLIED_PRICE InpMaPrice = PRICE_OPEN;  // Moving Average Price
input int InpMaShift = 0;                          // Moving Average Shift

extern string HILOConfig__ = "-----------------------------HILO--------------------";
input bool EnableSinalHILO = true;                   //Enable Sinal  HILO
input bool InpHILOFilterInverter = false;            // If True Invert Filter
input ENUM_TIMEFRAMES InpHILOFrame = PERIOD_CURRENT; // HILO TimeFrame
input int InpHILOPeriod = 3;                         // HILO Period
input ENUM_MA_METHOD InpHILOMethod = MODE_EMA;       // HILO Method
input int InpHILOShift = 0;                          // HILO Shift

double indicator_low;
double indicator_high;
double diff_highlow;
bool isbidgreaterthanima;

extern string TrailingStop__ = "--------------------Trailling Stop--------------";
extern bool InpUseTrailingStop = false; // Use Trailling Stop´?
extern int InpTrailStart = 20;          //   TraillingStart
extern int InpTrailStop = 20;           // Size Trailling stop

extern string BreakEven = "--------------------Break Even--------------";
extern bool InpUseBreakEven = true; // Use Break Even ?
extern int InpBreakEvenStart = 15;   //   Break Even Start
extern int InpBreakEvenStep = 3;    //  Break Even Step

extern string TakeEquitySTOP__ = "------------------------Take  Equity STOP ---------------";
extern bool InpUseTakeEquityStop = true;   // Usar Take EquityStop?
extern double InpProfitCloseandSTOP = 50.0; // Closes all orders once Float hits this $ amount

extern string FilterSpread__ = "----------------------------Filter Max Spread--------------------";
input int InpMaxSpread = 24; // Max Spread in Pips

extern string EquityCaution__ = "------------------------Filter Caution of Equity ---------------";
extern bool InpUseEquityCaution = TRUE;                       //  EquityCaution?
extern double InpTotalEquityRiskCaution = 20;                 // Total % Risk to EquityCaution
extern ENUM_TIMEFRAMES InpTimeframeEquityCaution = PERIOD_D1; // Timeframe as EquityCaution

extern string EquitySTOP__ = "------------------------Filter  Equity STOP ---------------";
extern bool InpUseEquityStop = true;        // Usar EquityStop?
extern double InpTotalEquityRisk = 60.0;    // Total % Risk to EquityStop
extern bool InpAlertPushEquityLoss = false; //Send Alert to Celular
extern bool InpCloseAllEquityLoss = false;  // Close all orders in TotalEquityRisk

/////////////////////////////////////////////////////
extern string FFCall__ = "----------------------------Filter News FFCall------------------------";

extern int InpMinsBeforeNews = 60; // mins before an event to stay out of trading
extern int InpMinsAfterNews = 20;  // mins after  an event to stay out of trading
extern bool InpUseFFCall = true;
extern bool InpIncludeHigh = true;

///////////////////////////////////////////////
extern string TimeFilter__ = "-------------------------Filter DateTime---------------------------";
extern bool InpUtilizeTimeFilter = true;
extern bool InpTrade_in_Monday = true;
extern bool InpTrade_in_Tuesday = true;
extern bool InpTrade_in_Wednesday = true;
extern bool InpTrade_in_Thursday = true;
extern bool InpTrade_in_Friday = true;

extern string InpStartHour = "00:00";
extern string InpEndHour = "23:59";

extern string _Visor1_ = "-----------------------------Visor 1 --------------------";
extern bool Visor1_Show_the_Time = True;
extern bool Visor1_Show_the_Price = True;

extern color Visor1_Price_Up_Color = LawnGreen;
extern color Visor1_Price_Down_Color = Tomato;
extern int Visor1_Price_X_Position = 10;
extern int Visor1_Price_Y_Position = 10;
extern int Visor1_Price_Size = 20;
double Visor1_Old_Price;

extern int Visor1_Porcent_X_Position = 10;
extern int Visor1_Porcent_Y_Position = 70;
extern int Visor1_Porcent_Size = 20;

extern int Visor1_Symbol_X_Position = 10;
extern int Visor1_Symbol_Y_Position = 40;
extern int Visor1_Symbol_Size = 20;

extern int Visor1_Chart_Timezone = -5;
extern color Visor1_Time_Color = Yellow;
extern int Visor1_Time_Size = 17;
extern int Visor1_Time_X_Position = 10;
extern int Visor1_Time_Y_Position = 10;

extern int Visor1_Spread_Size = 10;
extern int Visor1_Spread_X_Position = 10;
extern int Visor1_Spread_Y_Position = 100;

color Visor1_FontColor = Black;

int Visor1_Sinal = 0;

//LOT_MODE_FIXED
//---
int SlipPage = 3;
bool GridAll = false;

//---

bool m_hedging1, m_target_filter1;
int m_direction1, m_current_day1, m_previous_day1;
double m_level1, m_buyer1, m_seller1, m_target1, m_profit1;
double m_pip1, m_size1, m_take1;
datetime m_datetime_ultcandleopen1;
datetime m_time_equityrisk1;
double m_mediaprice1, profit1;
int m_orders_count1;
double m_lastlot1;

bool m_hedging2, m_target_filter2;
int m_direction2, m_current_day2, m_previous_day2;
double m_level2, m_buyer2, m_seller2, m_target2, m_profit2;
double m_pip2, m_size2, m_take2;
datetime m_datetime_ultcandleopen2;
datetime m_time_equityrisk2;
double m_mediaprice2;
int m_orders_count2;
double m_lastlot2, profit2;

string m_symbol;
bool m_news_time;
double m_spreadX;
double Spread;
bool m_initpainel;
string m_filters_on;
double m_profit_all;
datetime m_time_equityriskstopall;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
 if (!IsTradeAllowed())
        Alert("Not TradeAllowed");
        
  Spread = 2.0;
  if (InpManualInitGrid)
  {

    DrawRects(250, 15, Gray, 80, 50, "SELL");
    DrawRects(420, 15, Gray, 80, 50, "BUY");
    DrawRects(600, 15, Gray, 80, 50, "CLOSE ALL BUY");
    DrawRects(770, 15, Gray, 80, 50, "CLOSE ALL SELL");
  }

  //---
  m_symbol = Symbol();

  if (Digits == 3 || Digits == 5)
    m_pip1 = 10.0 * Point;
  else
    m_pip1 = Point;
  m_size1 = InpGridSize * m_pip1;
  m_take1 = InpTakeProfit * m_pip1;
  m_hedging1 = false;
  m_target_filter1 = false;
  m_direction1 = 0;

  m_datetime_ultcandleopen1 = -1;
  m_time_equityrisk1 = -1;
  m_orders_count1 = 0;
  m_lastlot1 = 0;

  if (Digits == 3 || Digits == 5)
    m_pip2 = 10.0 * Point;
  else
    m_pip2 = Point;
  m_size2 = InpGridSize * m_pip2;
  m_take2 = InpTakeProfit * m_pip2;
  m_hedging2 = false;
  m_target_filter2 = false;
  m_direction2 = 0;

  m_datetime_ultcandleopen2 = -1;
  m_time_equityrisk2 = -1;
  m_orders_count2 = 0;
  m_lastlot2 = 0;

  m_filters_on = "";
  m_initpainel = true;

  //---
  printf("xBest v3.47 - Grid Hedging Expert Advisor ");
  return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  ObjectDelete("Market_Price_Label");
  ObjectDelete("Time_Label");
  ObjectDelete("Porcent_Price_Label");
  ObjectDelete("Spread_Price_Label");
  ObjectDelete("Simbol_Price_Label");
  //---
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Informacoes()
{

  string Ls_64;

  int Li_84;

  if (!IsOptimization())
  {
    Visor1Handling();
    Ls_64 = "\n\n  ";
    Ls_64 = Ls_64 + "==========================\n";
    Ls_64 = Ls_64 + " " + " xBest FULL Hedge v3.47 2018-03-26 " + "\n";
    Ls_64 = Ls_64 + "==========================\n";
    // Ls_64 = Ls_64 + "  Broker:  " + AccountCompany() + "\n";
    Ls_64 = Ls_64 + "  Time of Broker:" + TimeToStr(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\n";
    // Ls_64 = Ls_64 + "  Currenci: " + AccountCurrency() + "\n";
    //Ls_64 = Ls_64 + "  Spread: " + m_spreadX + " pips\n";
    //Ls_64 = Ls_64 + "==========================\n";
    Ls_64 = Ls_64 + "  Grid Size : " + (string)InpGridSize + " Pips \n";
    Ls_64 = Ls_64 + "  TakeProfit: " + (string)InpTakeProfit + " Pips \n";
    Ls_64 = Ls_64 + "  Lot Mode : " + (string)InpLotMode + "  \n";
    Ls_64 = Ls_64 + "  Exponent Factor: " + (string)InpGridFactor + " pips\n";
    Ls_64 = Ls_64 + "  Daily Target: " + (string)InpDailyTarget + "\n";
    // Ls_64 = Ls_64 + "  Hedge After Level: " + (string)InpHedge + " \n";
    Ls_64 = Ls_64 + "  InpMaxSpread: " + (string)InpMaxSpread + " pips\n";
    Ls_64 = Ls_64 + "==========================\n";
    // Ls_64 = Ls_64 + "  Spread: " + (string)MarketInfo(Symbol(), MODE_SPREAD) + " \n";
    Ls_64 = Ls_64 + "  Equity:      " + DoubleToStr(AccountEquity(), 2) + " \n";
    Ls_64 = Ls_64 + "  Last Lot : | A : " + DoubleToStr(m_lastlot1, 2) + " | B : " + DoubleToStr(m_lastlot2, 2) + " \n";
    Ls_64 = Ls_64 + "  Orders Opens :   " + string(CountTrades()) + " | A : " + (string)m_orders_count1 + " | B : " + (string)m_orders_count2 + " \n";
    Ls_64 = Ls_64 + "  Profit/Loss: " + DoubleToStr(m_profit_all, 2) + " | A : " + DoubleToStr(CalculateProfit(InpMagic), 2) + " | B : " + DoubleToStr(CalculateProfit(InpMagic2), 2) + " \n";
    Ls_64 = Ls_64 + " ==========================\n";
    Ls_64 = Ls_64 + " EquityCautionFilter : " + (string)InpUseEquityCaution + " \n";
    Ls_64 = Ls_64 + " TotalEquityRiskCaution : " + DoubleToStr(InpTotalEquityRiskCaution, 2) + " % \n";
    Ls_64 = Ls_64 + " EquityStopFilter : " + (string)InpUseEquityStop + " \n";
    Ls_64 = Ls_64 + " TotalEquityRiskStop : " + DoubleToStr(InpTotalEquityRisk, 2) + " % \n";
    Ls_64 = Ls_64 + " NewsFilter : " + (string)InpUseFFCall + " \n";
    Ls_64 = Ls_64 + " TimeFilter : " + (string)InpUtilizeTimeFilter + " \n";
    Ls_64 = Ls_64 + " ==========================\n";
    Ls_64 = Ls_64 + m_filters_on;

    Comment(Ls_64);

    Li_84 = 16;
    if (InpDisplayInpBackgroundColor)
    {
      if (m_initpainel || Seconds() % 5 == 0)
      {
        m_initpainel = FALSE;
        for (int count_88 = 0; count_88 < 12; count_88++)
        {
          for (int count_92 = 1; count_92 < Li_84; count_92++)
          {
            ObjectDelete("background" + (string)count_88 + (string)count_92);
            ObjectDelete("background" + (string)count_88 + ((string)(count_92 + 1)));
            ObjectDelete("background" + (string)count_88 + ((string)(count_92 + 2)));
            ObjectCreate("background" + (string)count_88 + (string)count_92, OBJ_LABEL, 0, 0, 0);
            ObjectSetText("background" + (string)count_88 + (string)count_92, "n", 30, "Wingdings", InpBackgroundColor);
            ObjectSet("background" + (string)count_88 + (string)count_92, OBJPROP_XDISTANCE, 20 * count_88);
            ObjectSet("background" + (string)count_88 + (string)count_92, OBJPROP_YDISTANCE, 23 * count_92 + 9);
          }
        }
      }
    }
    else
    {
      if (m_initpainel || Seconds() % 5 == 0)
      {
        m_initpainel = FALSE;
        for (int count_88 = 0; count_88 < 9; count_88++)
        {
          for (int count_92 = 0; count_92 < Li_84; count_92++)
          {
            ObjectDelete("background" + (string)count_88 + (string)count_92);
            ObjectDelete("background" + (string)count_88 + ((string)(count_92 + 1)));
            ObjectDelete("background" + (string)count_88 + ((string)(count_92 + 2)));
          }
        }
      }
    }
  }
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  

  bool TradeNow = true;
  if (m_orders_count1 == 0)
    ObjectDelete("AvgA");

  if (m_orders_count2 == 0)
    ObjectDelete("AvgB");

  m_profit_all = CalculateProfit();

  if (InpCloseAllNow)
  {
    CloseThisSymbolAll(InpMagic);
    CloseThisSymbolAll(InpMagic2);
    InpManualInitGrid = true;
  }

  if (InpUseTakeEquityStop == true && m_profit_all >= InpProfitCloseandSTOP)
  {
    CloseThisSymbolAll(InpMagic);
    CloseThisSymbolAll(InpMagic2);
  }

  m_lastlot2 = FindLastSellLot(InpMagic2);
  m_lastlot1 = FindLastBuyLot(InpMagic);

  if (InpManualInitGrid)
  {
    if (m_lastlot1 > 0 || !InpEnableEngineA)
    {
      ObjectSetInteger(0, "_lBUY", OBJPROP_BGCOLOR, Gray);
      ObjectSetInteger(0, "_lCLOSE ALL BUY", OBJPROP_BGCOLOR, Green);
    }
    else
    {
      ObjectSetInteger(0, "_lBUY", OBJPROP_BGCOLOR, Blue);
      ObjectSetInteger(0, "_lCLOSE ALL BUY", OBJPROP_BGCOLOR, Gray);
    }

    if (m_lastlot2 > 0 || !InpEnableEngineB)
    {
      ObjectSetInteger(0, "_lSELL", OBJPROP_BGCOLOR, Gray);
      ObjectSetInteger(0, "_lCLOSE ALL SELL", OBJPROP_BGCOLOR, Green);
    }
    else
    {
      ObjectSetInteger(0, "_lSELL", OBJPROP_BGCOLOR, Red);
      ObjectSetInteger(0, "_lCLOSE ALL SELL", OBJPROP_BGCOLOR, Gray);
    }

    if (ObjectGetInteger(0, "_lBUY", OBJPROP_STATE) && !(m_orders_count1 > 0 || !InpEnableEngineA))
    {
      xBest("A", 1, 0, true, InpMagic, m_orders_count1, m_mediaprice1, m_hedging1, m_target_filter1,
            m_direction1, m_current_day1, m_previous_day1, m_level1, m_buyer1, m_seller1,
            m_target1, m_profit1, m_pip1, m_size1, m_take1, m_datetime_ultcandleopen1,
            m_time_equityrisk1, profit1);
      //  Alert("BUY");
      ObjectSetInteger(0, "_lBUY", OBJPROP_STATE, false);
    }

    if (ObjectGetInteger(0, "_lSELL", OBJPROP_STATE) && !(m_orders_count2 > 0 || !InpEnableEngineA))
    {
      xBest("B", -1, 0, true, InpMagic2, m_orders_count2, m_mediaprice2, m_hedging2,
            m_target_filter2, m_direction2, m_current_day2, m_previous_day2,
            m_level2, m_buyer2, m_seller2, m_target2, m_profit2, m_pip2,
            m_size2, m_take2, m_datetime_ultcandleopen2,
            m_time_equityrisk2, profit2);
      // Alert("SELL");
      ObjectSetInteger(0, "_lSELL", OBJPROP_STATE, false);
    }

    if (ObjectGetInteger(0, "_lCLOSE ALL SELL", OBJPROP_STATE))
    {
      // Alert("CLOSE ALL SELL");
      CloseThisSymbolAll(InpMagic2);
      ObjectSetInteger(0, "_lCLOSE ALL SELL", OBJPROP_STATE, false);
    }

    if (ObjectGetInteger(0, "_lCLOSE ALL BUY", OBJPROP_STATE))
    {
      //  Alert("CLOSE ALL BUY");
      CloseThisSymbolAll(InpMagic);
      ObjectSetInteger(0, "_lCLOSE ALL BUY", OBJPROP_STATE, false);
    }
  }

  if (InpUseEquityStop)
  {
    if (m_profit_all < 0.0 && MathAbs(m_profit_all) > InpTotalEquityRisk / 100.0 * AccountEquity())
    {
      if (InpCloseAllEquityLoss)
      {
        CloseThisSymbolAll(InpMagic);
        CloseThisSymbolAll(InpMagic2);
        Print("Closed All to Stop Out");
      }
      if (InpAlertPushEquityLoss)
        SendNotification("EquityLoss Alert " + (string)m_profit_all);

      m_time_equityriskstopall = iTime(NULL, PERIOD_MN1, 0);
      // m_filters_on += "Filter UseEquityStop ON \n";
      return;
    }
    else
    {
      m_time_equityriskstopall = -1;
    }
  }
  if (InpChartDisplay)
    Informacoes();

  RefreshRates();

  m_filters_on = "";

  if (m_time_equityriskstopall == iTime(NULL, PERIOD_MN1, 0) && (m_profit_all < 0.0 && MathAbs(m_profit_all) > InpTotalEquityRisk / 100.0 * AccountEquity()))
  {
    m_filters_on += "Filter EquitySTOP  ON \n";
    TradeNow = false;
  }

  //FILTER SPREAD
  m_spreadX = (double)MarketInfo(Symbol(), MODE_SPREAD) * m_pip2;
  if ((int)MarketInfo(Symbol(), MODE_SPREAD) > InpMaxSpread)
  {
    m_filters_on += "Filter InpMaxSpread ON \n";
    TradeNow = false;
  }

  //FILTER NEWS
  if (InpUseFFCall)
    NewsHandling();

  if (m_news_time && InpUseFFCall)
  {
    m_filters_on += "Filter News ON \n";
    TradeNow = false;
  }

  //FILTER DATETIME
  if (InpUtilizeTimeFilter && !TimeFilter())
  {
    m_filters_on += "Filter TimeFilter ON \n";
    TradeNow = false;
  }

  int Sinal = 0;

  int SinalMA = 0;
  int SinalHilo = 0;

  if (iClose(NULL, 0, 0) > iMA(NULL, InpMaFrame, InpMaPeriod, 0, InpMaMethod, InpMaPrice, InpMaShift))
    SinalMA = 1;
  if (iClose(NULL, 0, 0) < iMA(NULL, InpMaFrame, InpMaPeriod, 0, InpMaMethod, InpMaPrice, InpMaShift))
    SinalMA = -1;

  if(InpMAFilterInverter)SinalMA*-1;

  SinalHilo = GetSinalHILO();

  Sinal = (SinalHilo + SinalMA) / (1 + DivSinalHILO());

  double LotsHedge = 0;

  //FILTER EquityCaution
  if (m_orders_count1 == 0)
    m_time_equityrisk1 = -1;

  //Se todos Motores estiverem desabilitados
  if (!InpEnableEngineB && !InpEnableEngineA)
  {
    if (m_time_equityrisk1 == iTime(NULL, InpTimeframeEquityCaution, 0))
    {
      m_filters_on += "Filter EquityCaution S ON \n";
      TradeNow = false;
    }

    xBest("S", Sinal, TradeNow, LotsHedge, InpMagic, m_orders_count1, m_mediaprice1, m_hedging1, m_target_filter1,
          m_direction1, m_current_day1, m_previous_day1, m_level1, m_buyer1, m_seller1,
          m_target1, m_profit1, m_pip1, m_size1, m_take1, m_datetime_ultcandleopen1,
          m_time_equityrisk1, profit1);
  }
  else
  {

    if (m_profit_all >= 1.0 && (m_orders_count2 > 12 || m_orders_count1 > 12))
    {
      CloseThisSymbolAll(InpMagic);
      CloseThisSymbolAll(InpMagic2);
      Print(" KillAll true because protect DD: ");
    }

    if (!InpManualInitGrid)
    {
      if (m_time_equityrisk1 == iTime(NULL, InpTimeframeEquityCaution, 0) && m_time_equityrisk2 != iTime(NULL, InpTimeframeEquityCaution, 0))
      {
        m_filters_on += "Filter EquityCaution A ON \n";
        TradeNow = false;
      }

      // if(m_time_equityrisk2 == iTime(NULL, InpTimeframeEquityCaution, 0)) {
      if (m_orders_count2 > InpHedgex && InpHedgex != 0)
      {
        LotsHedge = m_lastlot2 / InpGridFactor;
      }

      if (Sinal == 1 && InpEnableEngineA)
        xBest("A", 1, TradeNow, LotsHedge, InpMagic, m_orders_count1, m_mediaprice1, m_hedging1, m_target_filter1,
              m_direction1, m_current_day1, m_previous_day1, m_level1, m_buyer1, m_seller1,
              m_target1, m_profit1, m_pip1, m_size1, m_take1, m_datetime_ultcandleopen1,
              m_time_equityrisk1, profit1);

      if (m_orders_count2 == 0)
        m_time_equityrisk2 = -1;

      if (m_time_equityrisk2 == iTime(NULL, InpTimeframeEquityCaution, 0) && m_time_equityrisk1 != iTime(NULL, InpTimeframeEquityCaution, 0))
      {
        m_filters_on += "Filter EquityCaution B ON \n";
        TradeNow = false;
      }

      // if(m_time_equityrisk1 == iTime(NULL, InpTimeframeEquityCaution, 0)) {
      if (m_orders_count1 > InpHedgex && InpHedgex != 0)
      {
        LotsHedge = m_lastlot1 / InpGridFactor;
      }

      if (Sinal == -1 && InpEnableEngineB)
        xBest("B", -1, TradeNow, LotsHedge, InpMagic2, m_orders_count2, m_mediaprice2, m_hedging2,
              m_target_filter2, m_direction2, m_current_day2, m_previous_day2,
              m_level2, m_buyer2, m_seller2, m_target2, m_profit2, m_pip2,
              m_size2, m_take2, m_datetime_ultcandleopen2,
              m_time_equityrisk2, profit2);
    }
    else
    {

      xBest("A", 0, TradeNow, LotsHedge, InpMagic, m_orders_count1, m_mediaprice1, m_hedging1, m_target_filter1,
            m_direction1, m_current_day1, m_previous_day1, m_level1, m_buyer1, m_seller1,
            m_target1, m_profit1, m_pip1, m_size1, m_take1, m_datetime_ultcandleopen1,
            m_time_equityrisk1, profit1);

      xBest("B", 0, TradeNow, LotsHedge, InpMagic2, m_orders_count2, m_mediaprice2, m_hedging2,
            m_target_filter2, m_direction2, m_current_day2, m_previous_day2,
            m_level2, m_buyer2, m_seller2, m_target2, m_profit2, m_pip2,
            m_size2, m_take2, m_datetime_ultcandleopen2,
            m_time_equityrisk2, profit2);
    }
  }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void xBest(string Id, int Sinal, bool TradeNow, double LotsHedge, int vInpMagic, int &m_orders_count, double &m_mediaprice, bool &m_hedging, bool &m_target_filter,
           int &m_direction, int &m_current_day, int &m_previous_day,
           double &m_level, double &m_buyer, double &m_seller, double &m_target, double &m_profit,
           double &m_pip, double &m_size, double &m_take, datetime &vDatetimeUltCandleOpen,
           datetime &m_time_equityrisk, double &profit)
{

  //--- Variable Declaration
  int index, orders_total, order_ticket, order_type, ticket, hour;
  double volume_min, volume_max, volume_step, lots;
  double account_balance, margin_required, risk_balance;
  double order_open_price, order_lots;

  //--- Variable Initialization
  int buy_ticket = 0, sell_ticket = 0, orders_count = 0, buy_ticket2 = 0, sell_ticket2 = 0;
  int buyer_counter = 0, seller_counter = 0;
  bool was_trade = false, close_filter = false;
  bool long_condition = false, short_condition = false;
  double orders_profit = 0.0, level = 0.0;
  double buyer_lots = 0.0, seller_lots = 0.0;
  double buyer_sum = 0.0, seller_sum = 0.0, sell_lot = 0, buy_lot = 0;
  ;
  double buy_price = 0.0, sell_price = 0.0;
  double bid_price = Bid, ask_price = Ask;
  double close_price = iClose(NULL, 0, 0);
  double open_price = iOpen(NULL, 0, 0);
  datetime time_current = TimeCurrent();
  bool res = false;
  m_spreadX = 2.0 * m_pip;

  //--- Base Lot Size
  account_balance = AccountBalance();
  volume_min = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
  volume_max = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MAX);
  volume_step = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);
  lots = volume_min;

  if (InpLotMode == LOT_MODE_FIXED)
    lots = InpFixedLot;
  else if (InpLotMode == LOT_MODE_PERCENT)
  {
    risk_balance = InpPercentLot * AccountBalance() / 100.0;
    margin_required = MarketInfo(m_symbol, MODE_MARGINREQUIRED);
    lots = MathRound(risk_balance / margin_required, volume_step);
    if (lots < volume_min)
      lots = volume_min;
    if (lots > volume_max)
      lots = volume_max;
  }

  //--- Daily Calc
  m_current_day = TimeDayOfWeek(time_current);
  if (m_current_day != m_previous_day)
  {
    m_target_filter = false;
    m_target = 0.0;
  }
  m_previous_day = m_current_day;

  //--- Calculation Loop
  orders_total = OrdersTotal();
  m_mediaprice = 0;
  double BuyProfit = 0;
  double SellProfit = 0;
  int countFirts = 0;
  double Firts2SellProfit = 0;
  double Firts2BuyProfit = 0;
  int Firtsticket[50];
  double LastSellProfit = 0;
  double LastBuyProfit = 0;
  int Lastticket = 0;

  int
      BuyPriceMaxTic = 0, BuyPriceMinTic = 0,
      SelPriceMaxTic = 0, SelPriceMinTic = 0;

  double
      BuyPriceMax = 0, BuyPriceMin = 0, BuyPriceMaxLot = 0, BuyPriceMinLot = 0,
      SelPriceMin = 0, SelPriceMax = 0, SelPriceMinLot = 0, SelPriceMaxLot = 0;

string Grid = Id;

  for (index = orders_total - 1; index >= 0; index--)
  {
    if (!OrderSelect(index, SELECT_BY_POS, MODE_TRADES))
      continue;
    if (OrderMagicNumber() != vInpMagic || OrderSymbol() != m_symbol)
      continue;
    order_open_price = OrderOpenPrice();
    order_ticket = OrderTicket();
    order_type = OrderType();
    order_lots = OrderLots();
    // = OrderComment();

    //---
    if (order_type == OP_BUY)
    {
   
      //--- Set Last Buy Order
      if (order_ticket > buy_ticket)
      {

        buy_price = order_open_price;
        buy_ticket = order_ticket;
        LastBuyProfit = OrderProfit() + OrderCommission() + OrderSwap();
        Lastticket = order_ticket;
        buy_lot = order_lots;
      
      }

     if (order_open_price > BuyPriceMax || BuyPriceMax == 0)
            {
              BuyPriceMax = order_open_price;
              BuyPriceMaxLot = order_lots;
              BuyPriceMaxTic = order_ticket;
                Grid = order_ticket;
            }

    if (order_open_price < BuyPriceMin || BuyPriceMin == 0)
            {
              BuyPriceMin = order_open_price;
              BuyPriceMinLot = order_lots;
              BuyPriceMinTic = order_ticket;
              
            }


      buyer_sum += (order_open_price - m_spreadX) * order_lots;

      buyer_lots += order_lots;
      buyer_counter++;
      orders_count++;
      m_mediaprice += order_open_price * order_lots;
      if (OrderProfit() > 0)
        BuyProfit += OrderProfit() + OrderCommission() + OrderSwap();
    }

    //---
    if (order_type == OP_SELL)
    {


      //--- Set Last Sell Order
      if (order_ticket > sell_ticket)
      {

        sell_price = order_open_price;
        sell_ticket = order_ticket;
        LastSellProfit = OrderProfit() + OrderCommission() + OrderSwap();
        Lastticket = order_ticket;
        sell_lot = order_lots;
       
      }

          if (order_open_price > SelPriceMax || SelPriceMax == 0)
            {
              SelPriceMax = order_open_price;
              SelPriceMaxLot = order_lots;
              SelPriceMaxTic = order_ticket;
              
            }
            if (order_open_price < SelPriceMin || SelPriceMin == 0)
            {
               Grid = order_ticket;
              SelPriceMin = order_open_price;
              SelPriceMinLot = order_lots;
              SelPriceMinTic = order_ticket;
            }


      seller_sum += (order_open_price + m_spreadX) * order_lots;

      seller_lots += order_lots;
      seller_counter++;
      orders_count++;
      m_mediaprice += order_open_price * order_lots;
      if (OrderProfit() > 0)
        SellProfit += OrderProfit() + OrderCommission() + OrderSwap();
    }

    //---
    orders_profit += OrderProfit() + OrderCommission() + OrderSwap();
  }

  int l_hist_total_4 = OrdersHistoryTotal();
  
    double profitHist= 0;
    
    for (int l_pos_24 = 0; l_pos_24 < l_hist_total_4; l_pos_24++)
    {
        OrderSelect(l_pos_24, SELECT_BY_POS, MODE_HISTORY);
          if (OrderSymbol() != Symbol() || OrderMagicNumber() != vInpMagic)
            continue;

       //Lucro do grid
       if(OrderComment() == Grid){
           profitHist += OrderProfit() + OrderCommission() + OrderSwap();
       }

    }

    //Caso Grid Esteja no lucro e grid está grande Fecha todos do grid para evitar DD
    if(MinimalProfitProtectGrid && (orders_profit + profitHist ) > MinProfit   && orders_count > QtdTradesMinProfit) 
       CloseThisSymbolAll(vInpMagic);


  m_orders_count = orders_count;
  m_profit = orders_profit;
  if ((seller_counter + buyer_counter) > 0)
    m_mediaprice = NormalizeDouble(m_mediaprice / (buyer_lots + seller_lots), Digits);

  color avgLine = Blue;
  if (seller_lots > 0)
    avgLine = Red;

  if (buyer_lots > 0 || seller_lots > 0)
    SetHLine(avgLine, "Avg" + Id, m_mediaprice, 0, 3);
  else
    ObjectDelete("Avg" + Id);

  if (InpUseTrailingStop)
    TrailingAlls(InpTrailStart, InpTrailStop, m_mediaprice, vInpMagic);

  if (InpUseBreakEven)
    BreakEvenAlls(InpBreakEvenStart, InpBreakEvenStep, m_mediaprice, vInpMagic);

  //--- Calc
  if (orders_count == 0)
  {
    m_target += m_profit;
    m_hedging = false;
  }
  profit = m_target + orders_profit;

  //--- Close Conditions
  if (InpDailyTarget > 0 && m_target + orders_profit >= InpDailyTarget)
    m_target_filter = true;
  //--- This ensure that buy and sell positions close at the same time when hedging is enabled
  if (m_hedging && ((m_direction > 0 && bid_price >= m_level) || (m_direction < 0 && ask_price <= m_level)))
    close_filter = true;

  //--- Close All Orders on Conditions
  if (m_target_filter || close_filter)
  {

    CloseThisSymbolAll(vInpMagic);

    // m_spread=0.0;
    return;
  }

  //--- Open Trade Conditions
  if (!m_hedging)
  {
    if (orders_count > 0 && !GridAll)
    {
      if (OpenNewOrdersGrid == true && TradeNow)
      {
        if (m_time_equityrisk1 != iTime(NULL, InpTimeframeEquityCaution, 0))
        {
          if (GridAllDirect)
          {
            if (buyer_counter > 0 && ask_price - buy_price >= m_size)
              long_condition = true;
            if (seller_counter > 0 && sell_price - bid_price >= m_size)
              short_condition = true;
          }
          if (buyer_counter > 0 && buy_price - ask_price >= m_size)
            long_condition = true;
          if (seller_counter > 0 && bid_price - sell_price >= m_size)
            short_condition = true;
        }
      }
    }
    else
    {

      if (InpOpenNewOrders && TradeNow)
      {
        hour = TimeHour(time_current);
        if (InpManualInitGrid || (!InpUtilizeTimeFilter || (InpUtilizeTimeFilter && TimeFilter())))
        {

          if (Sinal == 1)
            long_condition = true;
          if (Sinal == -1)
            short_condition = true;
        }
      }
    }
  }
  else
  {
    if (m_direction > 0 && bid_price <= m_seller)
      short_condition = true;
    if (m_direction < 0 && ask_price >= m_buyer)
      long_condition = true;
  }

  // CONTROL DRAWDOWN
  double vProfit = CalculateProfit(vInpMagic);

  if (vProfit < 0.0 && MathAbs(vProfit) > InpTotalEquityRiskCaution / 100.0 * AccountEquity())
  {
    m_time_equityrisk = iTime(NULL, InpTimeframeEquityCaution, 0);
  }
  else
  {
    m_time_equityrisk = -1;
  }

  //--- Hedging
  if (InpHedge > 0 && !m_hedging)
  {
    if (long_condition && buyer_counter == InpHedge)
    {
      // m_spread = Spread * m_pip;
      m_seller = bid_price;
      m_hedging = true;
      return;
    }
    if (short_condition && seller_counter == InpHedge)
    {
      // m_spread= Spread * m_pip;
      m_buyer = ask_price;
      m_hedging = true;
      return;
    }
  }

  //--- Lot Size
  if (LotsHedge != 0 && orders_count == 0)
  {
    lots = LotsHedge;
  }
  else
  {
    //lots = MathRound(lots * MathPow(InpGridFactor, orders_count), volume_step);

    double qtdLots = (sell_lot + buy_lot);
    if (long_condition)

      lots = MathRound(CalcLot(TypeGridLot, OP_BUY, orders_count, qtdLots, lots, InpGridFactor, InpGridStepLot), volume_step);
    if (short_condition)

      lots = MathRound(CalcLot(TypeGridLot, OP_SELL, orders_count, qtdLots, lots, InpGridFactor, InpGridStepLot), volume_step);

    if (m_hedging)
    {
      if (long_condition)
        lots = MathRound(seller_lots * 3, volume_step) - buyer_lots;
      if (short_condition)
        lots = MathRound(buyer_lots * 3, volume_step) - seller_lots;
    }
  }
  if (lots < volume_min)
    lots = volume_min;
  if (lots > volume_max)
    lots = volume_max;
  if (lots > InpMaxLot)
    lots = InpMaxLot;

  //--- Open Trades Based on Conditions
  if ((InpManualInitGrid && orders_count == 0) || (!InpOpenOneCandle || (InpOpenOneCandle && vDatetimeUltCandleOpen != iTime(NULL, InpTimeframeBarOpen, 0))))
  {
    vDatetimeUltCandleOpen = iTime(NULL, InpTimeframeBarOpen, 0);
    if (long_condition)
    {
      if (buyer_lots + lots == seller_lots)
        lots = seller_lots + volume_min;
      ticket = OpenTrade(OP_BUY, lots, ask_price, vInpMagic, Grid);
      if (ticket > 0)
      {
        res = OrderSelect(ticket, SELECT_BY_TICKET);
        order_open_price = OrderOpenPrice();
        buyer_sum += order_open_price * lots;
        buyer_lots += lots;
        m_level = NormalizeDouble((buyer_sum - seller_sum) / (buyer_lots - seller_lots), Digits) + m_take;
        if (!m_hedging)
          level = m_level;
        else
          level = m_level + m_take;
        if (buyer_counter == 0)
          m_buyer = order_open_price;
        m_direction = 1;
        was_trade = true;
      }
    }

    if (short_condition)
    {
      if (seller_lots + lots == buyer_lots)
        lots = buyer_lots + volume_min;
      ticket = OpenTrade(OP_SELL, lots, bid_price, vInpMagic, Grid);
      if (ticket > 0)
      {
        res = OrderSelect(ticket, SELECT_BY_TICKET);
        order_open_price = OrderOpenPrice();
        seller_sum += order_open_price * lots;
        seller_lots += lots;
        m_level = NormalizeDouble((seller_sum - buyer_sum) / (seller_lots - buyer_lots), Digits) - m_take;
        if (!m_hedging)
          level = m_level;
        else
          level = m_level - m_take;
        if (seller_counter == 0)
          m_seller = order_open_price;
        m_direction = -1;
        was_trade = true;
      }
    }
  }
  if (InpEnableMinProfit  )
  {
    if (BuyProfit >= MinProfit && buyer_counter >= QtdTradesMinProfit)
      CloseAllTicket(OP_BUY, buy_ticket, vInpMagic);

    if (SellProfit >= MinProfit && seller_counter >= QtdTradesMinProfit)
      CloseAllTicket(OP_SELL, sell_ticket, vInpMagic);
  }

  //--- Setup Global Take Profit
  if (was_trade)
  {
    orders_total = OrdersTotal();
    for (index = orders_total - 1; index >= 0; index--)
    {
      if (!OrderSelect(index, SELECT_BY_POS, MODE_TRADES))
        continue;
      if (OrderMagicNumber() != vInpMagic || OrderSymbol() != m_symbol)
        continue;
      order_type = OrderType();
      if (m_direction > 0)
      {
        if (order_type == OP_BUY)
          res = OrderModify(OrderTicket(), OrderOpenPrice(), 0.0, level, 0);
        if (order_type == OP_SELL)
          res = OrderModify(OrderTicket(), OrderOpenPrice(), level, 0.0, 0);
      }
      if (m_direction < 0)
      {
        if (order_type == OP_BUY)
          res = OrderModify(OrderTicket(), OrderOpenPrice(), level, 0.0, 0);
        if (order_type == OP_SELL)
          res = OrderModify(OrderTicket(), OrderOpenPrice(), 0.0, level, 0);
      }
    }
  }
}
//+------------------------------------------------------------------+
int OpenTrade(int cmd, double volume, double price, int vInpMagic, string coment, double stop = 0.0, double take = 0.0)
{
  return OrderSend(m_symbol, cmd, volume, price, SlipPage, stop, take, coment, vInpMagic, 0);
}
double MathRound(double x, double m) { return m * MathRound(x / m); }
double MathFloor(double x, double m) { return m * MathFloor(x / m); }
double MathCeil(double x, double m) { return m * MathCeil(x / m); }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades()
{
  int l_count_0 = 0;
  for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--)
  {
    if (!OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES))
    {
      continue;
    }
    if (OrderSymbol() != Symbol() || (OrderMagicNumber() != InpMagic && OrderMagicNumber() != InpMagic2))
      continue;
    if (OrderSymbol() == Symbol() && (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2))
      if (OrderType() == OP_SELL || OrderType() == OP_BUY)
        l_count_0++;
  }
  return (l_count_0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades(int vInpMagic)
{
  int l_count_0 = 0;
  for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--)
  {
    if (!OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES))
    {
      continue;
    }
    if (OrderSymbol() != Symbol() || (OrderMagicNumber() != vInpMagic))
      continue;
    if (OrderSymbol() == Symbol() && (OrderMagicNumber() == vInpMagic))
      if (OrderType() == OP_SELL || OrderType() == OP_BUY)
        l_count_0++;
  }
  return (l_count_0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTradesSell(int vInpMagic)
{
  int l_count_0 = 0;
  for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--)
  {
    if (!OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES))
    {
      continue;
    }
    if (OrderSymbol() != Symbol() || (OrderMagicNumber() != vInpMagic))
      continue;
    if (OrderSymbol() == Symbol() && (OrderMagicNumber() == vInpMagic))
      if (OrderType() == OP_SELL)
        l_count_0++;
  }
  return (l_count_0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTradesBuy(int vInpMagic)
{
  int l_count_0 = 0;
  for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--)
  {
    if (!OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES))
    {
      continue;
    }
    if (OrderSymbol() != Symbol() || (OrderMagicNumber() != vInpMagic))
      continue;
    if (OrderSymbol() == Symbol() && (OrderMagicNumber() == vInpMagic))
      if (OrderType() == OP_BUY)
        l_count_0++;
  }
  return (l_count_0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateProfit()
{
  double ld_ret_0 = 0;
  for (int g_pos_344 = OrdersTotal() - 1; g_pos_344 >= 0; g_pos_344--)
  {
    if (!OrderSelect(g_pos_344, SELECT_BY_POS, MODE_TRADES))
    {
      continue;
    }
    if (OrderSymbol() != Symbol() || (OrderMagicNumber() != InpMagic && OrderMagicNumber() != InpMagic2))
      continue;
    if (OrderSymbol() == Symbol() && (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2))
      if (OrderType() == OP_BUY || OrderType() == OP_SELL)
        ld_ret_0 += OrderProfit();
  }
  return (ld_ret_0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateProfit(int vInpMagic)
{
  double ld_ret_0 = 0;
  for (int g_pos_344 = OrdersTotal() - 1; g_pos_344 >= 0; g_pos_344--)
  {
    if (!OrderSelect(g_pos_344, SELECT_BY_POS, MODE_TRADES))
    {
      continue;
    }
    if (OrderSymbol() != Symbol() || (OrderMagicNumber() != vInpMagic))
      continue;
    if (OrderSymbol() == Symbol() && (OrderMagicNumber() == vInpMagic))
      if (OrderType() == OP_BUY || OrderType() == OP_SELL)
        ld_ret_0 += OrderProfit();
  }
  return (ld_ret_0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TimeFilter()
{

  bool _res = false;
  datetime _time_curent = TimeCurrent();
  datetime _time_start = StrToTime(DoubleToStr(Year(), 0) + "." + DoubleToStr(Month(), 0) + "." + DoubleToStr(Day(), 0) + " " + InpStartHour);
  datetime _time_stop = StrToTime(DoubleToStr(Year(), 0) + "." + DoubleToStr(Month(), 0) + "." + DoubleToStr(Day(), 0) + " " + InpEndHour);
  if (((InpTrade_in_Monday == true) && (TimeDayOfWeek(Time[0]) == 1)) ||
      ((InpTrade_in_Tuesday == true) && (TimeDayOfWeek(Time[0]) == 2)) ||
      ((InpTrade_in_Wednesday == true) && (TimeDayOfWeek(Time[0]) == 3)) ||
      ((InpTrade_in_Thursday == true) && (TimeDayOfWeek(Time[0]) == 4)) ||
      ((InpTrade_in_Friday == true) && (TimeDayOfWeek(Time[0]) == 5)))

    if (_time_start > _time_stop)
    {
      if (_time_curent >= _time_start || _time_curent <= _time_stop)
        _res = true;
    }
    else if (_time_curent >= _time_start && _time_curent <= _time_stop)
      _res = true;

  return (_res);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isCloseLastOrderNotProfit(int MagicNumber)
{
  datetime t = 0;
  double ocp, osl, otp;
  int i, j = -1, k = OrdersHistoryTotal();
  for (i = 0; i < k; i++)
  {
    if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
    {
      if (OrderType() == OP_BUY || OrderType() == OP_SELL)
      {
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
          if (t < OrderCloseTime())
          {
            t = OrderCloseTime();
            j = i;
          }
        }
      }
    }
  }
  if (OrderSelect(j, SELECT_BY_POS, MODE_HISTORY))
  {
    ocp = NormalizeDouble(OrderClosePrice(), Digits);
    osl = NormalizeDouble(OrderStopLoss(), Digits);
    otp = NormalizeDouble(OrderTakeProfit(), Digits);
    if (OrderProfit() < 0)
      return (True);
  }
  return (False);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastSellLot(int MagicNumber)
{
  double l_lastLote = 0;
  int l_ticket_8;
  //double ld_unused_12 = 0;
  int l_ticket_20 = 0;
  for (int l_pos_24 = OrdersTotal() - 1; l_pos_24 >= 0; l_pos_24--)
  {
    if (!OrderSelect(l_pos_24, SELECT_BY_POS, MODE_TRADES))
    {
      continue;
    }
    if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
      continue;
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL)
    {
      l_ticket_8 = OrderTicket();
      if (l_ticket_8 > l_ticket_20)
      {
        l_lastLote += OrderLots();
        //ld_unused_12 = l_ord_open_price_0;
        l_ticket_20 = l_ticket_8;
      }
    }
  }
  return (l_lastLote);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastBuyLot(int MagicNumber)
{
  double l_lastorder = 0;
  int l_ticket_8;
  //double ld_unused_12 = 0;
  int l_ticket_20 = 0;
  for (int l_pos_24 = OrdersTotal() - 1; l_pos_24 >= 0; l_pos_24--)
  {
    if (!OrderSelect(l_pos_24, SELECT_BY_POS, MODE_TRADES))
    {
      continue;
    }
    if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
      continue;
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY)
    {
      l_ticket_8 = OrderTicket();
      if (l_ticket_8 > l_ticket_20)
      {
        l_lastorder += OrderLots();
        //ld_unused_12 = l_ord_open_price_0;
        l_ticket_20 = l_ticket_8;
      }
    }
  }
  return (l_lastorder);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowError(int error, string complement)
{

  if (error == 1 || error == 130)
  {
    return;
  }

  //string ErrorText=ErrorDescription(error);
  // StringToUpper(ErrorText);
  Print(complement, ": Ordem: ", OrderTicket(), ". Falha ao tentar alterar ordem: ", error, " ");
  ResetLastError();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingAlls(int ai_0, int ai_4, double a_price_8, int MagicNumber)
{
  int li_16;

  double m_pip = 1.0 / MathPow(10, Digits - 1);
  if (Digits == 3 || Digits == 5)
    m_pip = 1.0 / MathPow(10, Digits - 1);
  else
    m_pip = Point;

  double l_ord_stoploss_20;
  double l_price_28;
  bool foo = false;
  if (ai_4 != 0)
  {
    for (int l_pos_36 = OrdersTotal() - 1; l_pos_36 >= 0; l_pos_36--)
    {
      if (OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES))
      {
        if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
          continue;
        if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber)
        {
          if (OrderType() == OP_BUY)
          {
            li_16 = (int)NormalizeDouble((Bid - a_price_8) / Point, 0);
            if (li_16 < (ai_0 * m_pip))
              continue;
            l_ord_stoploss_20 = OrderStopLoss();
            l_price_28 = Bid - (ai_4 * m_pip);
            l_price_28 = ValidStopLoss(OP_BUY, Bid, l_price_28);
            if (l_ord_stoploss_20 == 0.0 || (l_ord_stoploss_20 != 0.0 && l_price_28 > l_ord_stoploss_20))
            {
              // Somente ajustar a ordem se ela estiver aberta
              if (CanModify(OrderTicket()) && a_price_8 < l_price_28)
              {
                ResetLastError();
                foo = OrderModify(OrderTicket(), a_price_8, l_price_28, OrderTakeProfit(), 0, Aqua);
                if (!foo)
                {
                  ShowError(GetLastError(), "Normal");
                }
              }
            }
          }
          if (OrderType() == OP_SELL)
          {
            li_16 = (int)NormalizeDouble((a_price_8 - Ask) / Point, 0);
            if (li_16 < (ai_0 * m_pip))
              continue;
            l_ord_stoploss_20 = OrderStopLoss();
            l_price_28 = Ask + (ai_4 * m_pip);
            l_price_28 = ValidStopLoss(OP_SELL, Ask, l_price_28);
            if (l_ord_stoploss_20 == 0.0 || (l_ord_stoploss_20 != 0.0 && l_price_28 < l_ord_stoploss_20))
            {
              // Somente ajustar a ordem se ela estiver aberta
              if (CanModify(OrderTicket()) && a_price_8 > l_price_28)
              {
                ResetLastError();
                foo = OrderModify(OrderTicket(), a_price_8, l_price_28, OrderTakeProfit(), 0, Red);
                if (!foo)
                {
                  ShowError(GetLastError(), "Normal");
                }
              }
            }
          }
        }
        Sleep(1000);
      }
    }
  }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseThisSymbolAll(int vInpMagic)
{
  bool foo = false;
  for (int l_pos_0 = OrdersTotal() - 1; l_pos_0 >= 0; l_pos_0--)
  {
    if (!OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES))
    {
      continue;
    }
    if (OrderSymbol() == Symbol())
    {
      if (OrderSymbol() == Symbol() && (OrderMagicNumber() == vInpMagic))
      {
        if (OrderType() == OP_BUY)
          foo = OrderClose(OrderTicket(), OrderLots(), Bid, SlipPage, Blue);

        if (OrderType() == OP_SELL)
          foo = OrderClose(OrderTicket(), OrderLots(), Ask, SlipPage, Red);
      }
      Sleep(1000);
    }
  }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseThisSymbolAll()
{
  bool foo = false;
  for (int l_pos_0 = OrdersTotal() - 1; l_pos_0 >= 0; l_pos_0--)
  {
    if (!OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES))
    {
      continue;
    }
    if (OrderSymbol() == Symbol())
    {
      if (OrderSymbol() == Symbol() && (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2))
      {
        if (OrderType() == OP_BUY)
          foo = OrderClose(OrderTicket(), OrderLots(), Bid, SlipPage, Blue);

        if (OrderType() == OP_SELL)
          foo = OrderClose(OrderTicket(), OrderLots(), Ask, SlipPage, Red);
      }
      Sleep(1000);
    }
  }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CanModify(int ticket)
{

  return OrdersTotal() > 0;
  /*
    if( OrderType() == OP_BUY || OrderType() == OP_SELL)
       return OrderCloseTime() == 0;
       
    return false;
 
    /*
    bool result = false;
    
    OrderSelect(ticket, SELECT_BY_TICKET
    for(int i=OrdersHistoryTotal()-1;i>=0;i--){
       if( !OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) ){ continue; }
       if(OrderTicket()==ticket){
          result=true;
          break;
       }
    }
    
    return result;
    */
}
// Function to check if it is news time
void NewsHandling()
{
  static int PrevMinute = -1;

  if (Minute() != PrevMinute)
  {
    PrevMinute = Minute();

    // Use this call to get ONLY impact of previous event
    int impactOfPrevEvent =
        (int)iCustom(NULL, 0, "FFCal", true, true, false, true, true, 2, 0);

    // Use this call to get ONLY impact of nexy event
    int impactOfNextEvent =
        (int)iCustom(NULL, 0, "FFCal", true, true, false, true, true, 2, 1);

    int minutesSincePrevEvent =
        (int)iCustom(NULL, 0, "FFCal", true, true, false, true, false, 1, 0);

    int minutesUntilNextEvent =
        (int)iCustom(NULL, 0, "FFCal", true, true, false, true, false, 1, 1);

    m_news_time = false;
    if ((minutesUntilNextEvent <= InpMinsBeforeNews) ||
        (minutesSincePrevEvent <= InpMinsAfterNews))
    {
      m_news_time = true;
    }
  }
} //newshandling

void CloseAllTicket(int aType, int ticket, int MagicN)
{
  for (int i = OrdersTotal() - 1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS))
      if (OrderSymbol() == Symbol())
        if (OrderMagicNumber() == MagicN)
        {
          if (OrderType() == aType && OrderType() == OP_BUY)
            if (OrderProfit() > 0 || OrderTicket() == ticket)
              if (!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits()), SlipPage, clrRed))
                Print(" OrderClose OP_BUY Error N", GetLastError());

          if (OrderType() == aType && OrderType() == OP_SELL)
            if (OrderProfit() > 0 || OrderTicket() == ticket)
              if (!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits()), SlipPage, clrRed))
                Print(" OrderClose OP_SELL Error N", GetLastError());
        }
}

void DrawRects(int xPos, int yPos, color clr, int width = 150, int height = 17, string Texto = "")
{

  string id = "_l" + Texto;

  ObjectDelete(0, id);

  ObjectCreate(0, id, OBJ_BUTTON, 0, 100, 100);
  ObjectSetInteger(0, id, OBJPROP_XDISTANCE, xPos);
  ObjectSetInteger(0, id, OBJPROP_YDISTANCE, yPos);
  ObjectSetInteger(0, id, OBJPROP_BGCOLOR, clr);
  ObjectSetInteger(0, id, OBJPROP_COLOR, clrWhite);
  ObjectSetInteger(0, id, OBJPROP_XSIZE, 150);
  ObjectSetInteger(0, id, OBJPROP_YSIZE, 35);

  ObjectSetInteger(0, id, OBJPROP_WIDTH, 0);
  ObjectSetString(0, id, OBJPROP_FONT, "Arial");
  ObjectSetString(0, id, OBJPROP_TEXT, Texto);
  ObjectSetInteger(0, id, OBJPROP_SELECTABLE, 0);

  ObjectSetInteger(0, id, OBJPROP_BACK, 0);
  ObjectSetInteger(0, id, OBJPROP_SELECTED, 0);
  ObjectSetInteger(0, id, OBJPROP_HIDDEN, 1);
  ObjectSetInteger(0, id, OBJPROP_ZORDER, 1);

  ObjectSetInteger(0, id, OBJPROP_STATE, false);
}
void SetHLine(color vColorSetHLine, string vNomeSetHLine = "", double vBidSetHLine = 0.0, int vStyleSetHLine = 0, int vTamanhoSetHLine = 1)
{
  if (vNomeSetHLine == "")
    vNomeSetHLine = DoubleToStr(Time[0], 0);
  if (vBidSetHLine <= 0.0)
    vBidSetHLine = Bid;
  if (ObjectFind(vNomeSetHLine) < 0)
    ObjectCreate(vNomeSetHLine, OBJ_HLINE, 0, 0, 0);
  ObjectSet(vNomeSetHLine, OBJPROP_PRICE1, vBidSetHLine);
  ObjectSet(vNomeSetHLine, OBJPROP_COLOR, vColorSetHLine);
  ObjectSet(vNomeSetHLine, OBJPROP_STYLE, vStyleSetHLine);
  ObjectSet(vNomeSetHLine, OBJPROP_WIDTH, vTamanhoSetHLine);
}

double ValidStopLoss(int type, double price, double SL)
{

  double mySL;
  double minstop;

  minstop = MarketInfo(Symbol(), MODE_STOPLEVEL);
  if (Digits == 3 || Digits == 5)
    minstop = minstop / 10;

  mySL = SL;
  if (type == OP_BUY)
  {
    if ((price - mySL) < minstop * Point)
      // mySL = price - minstop * Point;
      mySL = 0;
  }
  if (type == OP_SELL)
  {
    if ((mySL - price) < minstop * Point)
      //mySL = price + minstop * Point;
      mySL = 0;
  }

  return (NormalizeDouble(mySL, MarketInfo(Symbol(), MODE_DIGITS)));
}
/* 
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{

  //sparam: Name of the graphical object, on which the event occurred

  // did user click on the chart ?
  if (id == CHARTEVENT_OBJECT_CLICK)
  {
    // and did he click on on of our objects
    if (StringSubstr(sparam, 0, 2) == "_l")
    {

      // did user click on the name of a pair ?
      int len = StringLen(sparam);
      // Alert(sparam);
      //
      if (StringSubstr(sparam, len - 3, 3) == "BUY" || StringSubstr(sparam, len - 3, 3) == "ELL")
      {
        if (InpManualInitGrid)
        {

          //Aciona 1ª Ordem do Grid
          if (StringSubstr(sparam, len - 3, 3) == "sBUY" && !(m_orders_count1 > 0 || !InpEnableEngineA))
          {
            //BUY
            xBest("A", 1, 0, InpMagic, m_orders_count1, m_mediaprice1, m_hedging1, m_target_filter1,
                  m_direction1, m_current_day1, m_previous_day1, m_level1, m_buyer1, m_seller1,
                  m_target1, m_profit1, m_pip1, m_size1, m_take1, m_datetime_ultcandleopen1,
                  m_time_equityrisk1);
            //  Alert("BUY");
          }
          if (StringSubstr(sparam, len - 3, 3) == "sELL" && !(m_orders_count2 > 0 || !InpEnableEngineA))
          {
            //SELL
            xBest("B", -1, 0, InpMagic2, m_orders_count2, m_mediaprice2, m_hedging2,
                  m_target_filter2, m_direction2, m_current_day2, m_previous_day2,
                  m_level2, m_buyer2, m_seller2, m_target2, m_profit2, m_pip2,
                  m_size2, m_take2, m_datetime_ultcandleopen2,
                  m_time_equityrisk2);
            //  Alert("SELL");
          }
        }
      }
    }
  }
} */
//-----------------------------------------------
int DivSinalHILO()
{
  if (!EnableSinalHILO)
    return (0);
  else
    return (1);
}

int GetSinalHILO()
{
  int vRet = 0;

  if (!EnableSinalHILO)
    vRet;

  indicator_low = iMA(NULL, InpHILOFrame, InpHILOPeriod, 0, InpHILOMethod, PRICE_LOW, InpHILOShift);
  indicator_high = iMA(NULL, InpHILOFrame, InpHILOPeriod, 0, InpHILOMethod, PRICE_HIGH, InpHILOShift);

  diff_highlow = indicator_high - indicator_low;
  isbidgreaterthanima = Bid >= indicator_low + diff_highlow / 2.0;

  if (Bid < indicator_low)
    vRet = -1;
  else if (Bid > indicator_high)
    vRet = 1;

  if (InpHILOFilterInverter)
    vRet = vRet * -1;

  return vRet;
}

string ToStr(double ad_0, int ai_8)
{
  return (DoubleToStr(ad_0, ai_8));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BreakEvenAlls(int ai_0, int ai_4, double MediaPrice, int MagicNumber)
{
  int PipsDiffMedia;

  double m_pip = 1.0 / MathPow(10, Digits - 1);
  if (Digits == 3 || Digits == 5)
    m_pip = 1.0 / MathPow(10, Digits - 1);
  else
    m_pip = Point;

  double l_ord_stoploss_20;
  double l_price_28;
  bool foo = false;
  if (ai_0 != 0)
  {
    for (int l_pos_36 = OrdersTotal() - 1; l_pos_36 >= 0; l_pos_36--)
    {
      if (OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES))
      {
        if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
          continue;
        if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber)
        {
          if (OrderType() == OP_BUY)
          {
            PipsDiffMedia = (int)NormalizeDouble((Bid - MediaPrice) / Point, 0);
           // Comment(PipsDiffMedia);
            if (PipsDiffMedia <= (ai_0 * m_pip))
              continue;
            l_ord_stoploss_20 = OrderStopLoss();
            l_price_28 = MediaPrice + (ai_4 * m_pip);
            l_price_28 = ValidStopLoss(OP_BUY, Bid, l_price_28);
            if (Bid >= (MediaPrice + (ai_4 * m_pip)) && (l_ord_stoploss_20 == 0.0 || (l_ord_stoploss_20 != 0.0 && l_price_28 > l_ord_stoploss_20)))
            {
              // Somente ajustar a ordem se ela estiver aberta
              if (CanModify(OrderTicket()))
              {
                ResetLastError();
                foo = OrderModify(OrderTicket(), MediaPrice, l_price_28, OrderTakeProfit(), 0, Aqua);
                if (!foo)
                {
                  ShowError(GetLastError(), "Normal");
                }
              }
            }
          }
          if (OrderType() == OP_SELL)
          {
            PipsDiffMedia = (int)NormalizeDouble((MediaPrice - Ask) / Point, 0);
            if (PipsDiffMedia <= (ai_0 * m_pip))
              continue;
            l_ord_stoploss_20 = OrderStopLoss();
            l_price_28 = MediaPrice - (ai_4 * m_pip);
            l_price_28 = ValidStopLoss(OP_SELL, Ask, l_price_28);
            if (Ask <= (MediaPrice - (ai_4 * m_pip)) && (l_ord_stoploss_20 == 0.0 || (l_ord_stoploss_20 != 0.0 && l_price_28 < l_ord_stoploss_20)))
            {
              // Somente ajustar a ordem se ela estiver aberta
              if (CanModify(OrderTicket()))
              {
                ResetLastError();
                foo = OrderModify(OrderTicket(), MediaPrice, l_price_28, OrderTakeProfit(), 0, Red);
                if (!foo)
                {
                  ShowError(GetLastError(), "Normal");
                }
              }
            }
          }
        }
        Sleep(1000);
      }
    }
  }
}

void Visor1Handling()
{
  if (Visor1_Show_the_Price == true)
  {
    string Market_Price = DoubleToStr(Bid, Digits);

    ObjectCreate("Market_Price_Label", OBJ_LABEL, 0, 0, 0);

    if (Bid > Visor1_Old_Price)
      ObjectSetText("Market_Price_Label", Market_Price, Visor1_Price_Size, "Comic Sans MS", Visor1_Price_Up_Color);
    if (Bid < Visor1_Old_Price)
      ObjectSetText("Market_Price_Label", Market_Price, Visor1_Price_Size, "Comic Sans MS", Visor1_Price_Down_Color);
    Visor1_Old_Price = Bid;

    ObjectSet("Market_Price_Label", OBJPROP_XDISTANCE, Visor1_Price_X_Position);
    ObjectSet("Market_Price_Label", OBJPROP_YDISTANCE, Visor1_Price_Y_Position);
    ObjectSet("Market_Price_Label", OBJPROP_CORNER, 1);
  }

  if (Bid > iClose(0, 1440, 1))
  {
    Visor1_FontColor = LawnGreen;
    Visor1_Sinal = 1;
  }

  if (Bid < iClose(0, 1440, 1))
  {
    Visor1_FontColor = Tomato;
    Visor1_Sinal = -1;
  }
   string Porcent_Price = "";
  double vclose =  iClose(0, 1440, 1);

  if(vclose > 0 )
         Porcent_Price = DoubleToStr(((iClose(0, 1440, 0) /vclose) - 1) * 100, 3) + " %";
  //----
  ObjectCreate("Porcent_Price_Label", OBJ_LABEL, 0, 0, 0);
  ObjectSetText("Porcent_Price_Label", Porcent_Price, Visor1_Porcent_Size, "Arial", Visor1_FontColor);
  ObjectSet("Porcent_Price_Label", OBJPROP_CORNER, 1);
  ObjectSet("Porcent_Price_Label", OBJPROP_XDISTANCE, Visor1_Porcent_X_Position);
  ObjectSet("Porcent_Price_Label", OBJPROP_YDISTANCE, Visor1_Porcent_Y_Position);

  string Symbol_Price = Symbol();

  ObjectCreate("Simbol_Price_Label", OBJ_LABEL, 0, 0, 0);
  ObjectSetText("Simbol_Price_Label", Symbol_Price, Visor1_Symbol_Size, "Arial", DeepSkyBlue);
  ObjectSet("Simbol_Price_Label", OBJPROP_CORNER, 1);
  ObjectSet("Simbol_Price_Label", OBJPROP_XDISTANCE, Visor1_Symbol_X_Position);
  ObjectSet("Simbol_Price_Label", OBJPROP_YDISTANCE, Visor1_Symbol_Y_Position);

  string Spreead = "Spread : " + (MarketInfo(Symbol(), MODE_SPREAD)) + " pips";
  ObjectCreate("Spread_Price_Label", OBJ_LABEL, 0, 0, 0);
  ObjectSetText("Spread_Price_Label", Spreead, Visor1_Spread_Size, "Arial", White);
  ObjectSet("Spread_Price_Label", OBJPROP_CORNER, 1);
  ObjectSet("Spread_Price_Label", OBJPROP_XDISTANCE, Visor1_Spread_X_Position);
  ObjectSet("Spread_Price_Label", OBJPROP_YDISTANCE, Visor1_Spread_Y_Position);
  //----------------------------------

  if (Visor1_Show_the_Time == true)
  {
    int MyHour = TimeHour(TimeCurrent());
    int MyMinute = TimeMinute(TimeCurrent());
    int MyDay = TimeDay(TimeCurrent());
    int MyMonth = TimeMonth(TimeCurrent());
    int MyYear = TimeYear(TimeCurrent());
    string MySemana = TimeDayOfWeek(TimeCurrent());
    string NewMinute = "";

    if (MyMinute < 10)
    {
      NewMinute = ("0" + MyMinute);
    }
    else
    {
      NewMinute = DoubleToStr(TimeMinute(TimeCurrent()), 0);
    }

    string NewHour = DoubleToStr(MyHour + Visor1_Chart_Timezone, 0);

    ObjectCreate("Time_Label", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("Time_Label", MyDay + "-" + MyMonth + "-" + MyYear + " " + NewHour + ":" + NewMinute, Visor1_Time_Size, "Comic Sans MS", Visor1_Time_Color);

    ObjectSet("Time_Label", OBJPROP_XDISTANCE, Visor1_Time_X_Position);
    ObjectSet("Time_Label", OBJPROP_YDISTANCE, Visor1_Time_Y_Position);
  }
}

double CalcLot(int TypeLot, int TypeOrder, int vQtdTrades, double LastLot, double StartLot, double GridFactor, int GridStepLot)
{
  double rezult = 0;
  switch (TypeLot)
  {
  case 0: // Standart lot
    if (TypeOrder == OP_BUY || TypeOrder == OP_SELL)
      rezult = StartLot;
    break;

  case 1: // Summ lot
    rezult = StartLot * vQtdTrades;

    break;

  case 2: // Martingale lot
          // rezult = StartLot * MathPow(GridFactor, vQtdTrades);
    rezult = MathRound(StartLot * MathPow(InpGridFactor, vQtdTrades), SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP));
    break;

  case 3: // Step lot
    if (vQtdTrades == 0)
      rezult = StartLot;
    if (vQtdTrades % GridStepLot == 0)
      rezult = LastLot + StartLot;
    else
      rezult = LastLot;

    break;
  }
  return rezult;
}

double FindFirstOrderTicket(int magic, string Symb, int Type, int QtdProfit, int &tickets[])
{
  int Ticket = 0;
  double profit = 0;
  datetime EarliestOrder = D'2099/12/31';
  int c = 0;
  double ordprofit[100];
  double ordprofitf[100];
  int ticketsf[100];
  for (int i = 0; i < OrdersTotal(); i++)
  {
    if (OrderSelect(i, SELECT_BY_POS))
    {
      if (OrderType() == Type && OrderSymbol() == Symb && OrderMagicNumber() == magic)
      {
        if (EarliestOrder > OrderOpenTime())
        {
          EarliestOrder = OrderOpenTime();
          Ticket = OrderTicket();
          profit = OrderProfit() + OrderCommission() + OrderSwap();
          if(profit < 0 && (i >  OrdersTotal() - QtdProfit)  ){
          tickets[c] = Ticket;
          ordprofit[c] =  OrderProfit() + OrderCommission() + OrderSwap();;
          profit += OrderProfit() + OrderCommission() + OrderSwap();
          c++;}
        }
      }
    }
  }
// int v = 0;
//    for (int i = c; i >= 0; i--)
//     {
     
//       ticketsf[v]=ordprofit[i];
//       ordprofitf[v]=tickets[i] ;
//       v++;
//     }

//      for (int i = 0; i < QtdProfit; i++)
//     {
//       profit += ordprofitf[i];
//       tickets[i] = ticketsf[i];
//       ordprofit[i]= ordprofitf[i] ;
//     }

  return profit; // Returns 0 if no matching orders
}

double ProfitCommGrid(int a_magic_0, string Grid)
{
    int l_hist_total_4 = OrdersHistoryTotal();
    int l_datetime_8 = 0;
    int l_datetime_12 = 0;
    string ls_ret_16 = "0";
    double profit= 0;
    for (int l_pos_24 = 0; l_pos_24 < l_hist_total_4; l_pos_24++)
    {
        OrderSelect(l_pos_24, SELECT_BY_POS, MODE_HISTORY);
          if (OrderSymbol() != Symbol() || OrderMagicNumber() != a_magic_0)
            continue;

        l_datetime_8 = OrderCloseTime();


       //Lucro do grid
       if(OrderComment() == Grid){
           profit += OrderProfit() + OrderCommission() + OrderSwap();
       }

    }
    return (profit);
}


string LastComm(int a_magic_0)
{
    int l_hist_total_4 = OrdersHistoryTotal();
    int l_datetime_8 = 0;
    int l_datetime_12 = 0;
    string ls_ret_16 = "0";
    for (int l_pos_24 = 0; l_pos_24 < l_hist_total_4; l_pos_24++)
    {
        OrderSelect(l_pos_24, SELECT_BY_POS, MODE_HISTORY);
          if (OrderSymbol() != Symbol() || OrderMagicNumber() != a_magic_0)
            continue;
        l_datetime_8 = OrderCloseTime();
        if (l_datetime_8 > l_datetime_12 && OrderMagicNumber() == a_magic_0)
        {
            l_datetime_12 = l_datetime_8;
            ls_ret_16 = OrderComment();
        }
    }
    return (ls_ret_16);
}