#property link          "https://www.earnforex.com/metatrader-indicators/moving-average-crossover-alert/"
#property version       "1.05"
#property strict
#property copyright     "EarnForex.com - 2020-2023"
#property description   "Moving average crossover alert. Supports simple, exponential, smoothed, and linear weighted."
#property description   " "
#property description   " "
#property description   "Find More on www.EarnForex.com"
#property icon          "\\Files\\EF-Icon-64x64px.ico"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrRed
#property indicator_color2 clrGreen
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_label1 "Fast MA"
#property indicator_label2 "Slow MA"

enum ENUM_TRADE_SIGNAL
{
    SIGNAL_BUY = 1,    // Buy
    SIGNAL_SELL = -1,  // Sell
    SIGNAL_NEUTRAL = 0 // Neutral
};

enum ENUM_CANDLE_TO_CHECK
{
    CURRENT_CANDLE = 0,  // Current candle
    CLOSED_CANDLE = 1    // Previous candle
};

input string Comment1 = "========================";   // MQLTA Moving Average Crossover Alert
input string IndicatorName = "MQLTA-MACA";            // Indicator short name

input string Comment2 = "========================";        // Indicator parameters
input int MAFastPeriod = 25;                               // Fast moving average period
input int MAFastShift = 0;                                 // Fast moving average shift
input ENUM_MA_METHOD MAFastMethod = MODE_SMA;              // Fast moving average method
input ENUM_APPLIED_PRICE MAFastAppliedPrice = PRICE_CLOSE; // Fast moving average applied price
input int MASlowPeriod = 50;                               // Slow moving average period
input int MASlowShift = 0;                                 // Slow moving average shift
input ENUM_MA_METHOD MASlowMethod = MODE_SMA;              // Slow moving average method
input ENUM_APPLIED_PRICE MASlowAppliedPrice = PRICE_CLOSE; // Slow moving average applied price
input ENUM_CANDLE_TO_CHECK CandleToCheck = CURRENT_CANDLE; // Candle to use for analysis
input int BarsToScan = 500;                                // Number of candles to analyze

input string Comment_3 = "====================";   // Notification options
input bool EnableNotify = false;                   // Enable notifications feature
input bool SendAlert = false;                      // Send alert notification
input bool SendApp = false;                        // Send notification to mobile
input bool SendEmail = false;                      // Send notification via email

input string Comment_4 = "====================";   // Drawing options
input bool EnableDrawArrows = true;                // Draw signal arrows
input int ArrowBuy = 241;                          // Buy arrow code
input int ArrowSell = 242;                         // Sell arrow code
input int ArrowSize = 3;                           // Arrow size (1-5)
input color ArrowBuyColor = clrGreen;              // Buy arrow color
input color ArrowSellColor = clrRed;               // Sell arrow color

double BufferMASlow[];
double BufferMAFast[];

datetime LastNotificationTime;
ENUM_TRADE_SIGNAL LastNotificationDirection;
int Shift = 0;

int OnInit(void)
{

    IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);

    OnInitInitialization();
    if (!OnInitPreChecksPass())
    {
        return INIT_FAILED;
    }

    InitialiseBuffers();

    return INIT_SUCCEEDED;
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    if (rates_total < MASlowPeriod + MASlowShift)
    {
        Print("Not enough candles on the chart.");
        return 0;
    }

    bool IsNewCandle = CheckIfNewCandle();

    int counted_bars = 0;
    if (prev_calculated > 0) counted_bars = prev_calculated - 1;

    if (counted_bars < 0) return -1;
    if (counted_bars > 0) counted_bars--;
    int limit = rates_total - counted_bars;
    if (limit > BarsToScan)
    {
        limit = BarsToScan;
        if (rates_total < BarsToScan + MASlowPeriod + MASlowShift) limit = rates_total - (MASlowPeriod + MASlowShift);
    }
    if (limit > rates_total - (MASlowPeriod + MASlowShift)) limit = rates_total - (MASlowPeriod + MASlowShift);

    for (int i = limit; (i >= 0) && (!IsStopped()); i--)
    {
        BufferMASlow[i] = iMA(Symbol(), PERIOD_CURRENT, MASlowPeriod, MASlowShift, MASlowMethod, MASlowAppliedPrice, i);
        BufferMAFast[i] = iMA(Symbol(), PERIOD_CURRENT, MAFastPeriod, MAFastShift, MAFastMethod, MAFastAppliedPrice, i);
    }

    if ((IsNewCandle) || (prev_calculated == 0))
    {
        if (EnableDrawArrows) DrawArrows(limit);
    }

    if (EnableDrawArrows) DrawArrow(0);

    if (EnableNotify) NotifyHit();

    return rates_total;
}

void OnDeinit(const int reason)
{
    CleanChart();
}

void OnInitInitialization()
{
    LastNotificationTime = TimeCurrent();
    LastNotificationDirection = SIGNAL_NEUTRAL;
    Shift = CandleToCheck;
}

bool OnInitPreChecksPass()
{
    if ((MASlowPeriod <= 0) || (MAFastPeriod <= 0) || (MAFastPeriod >= MASlowPeriod))
    {
        Print("Wrong input parameter");
        return false;
    }
    return true;
}

void CleanChart()
{
    ObjectsDeleteAll(ChartID(), IndicatorName);
}

void InitialiseBuffers()
{
    SetIndexBuffer(0, BufferMAFast);
    SetIndexShift(0, MAFastShift);
    SetIndexDrawBegin(0, MAFastPeriod + MAFastShift);
    SetIndexBuffer(1, BufferMASlow);
    SetIndexShift(1, MASlowShift);
    SetIndexDrawBegin(1, MASlowPeriod + MASlowShift);
}

datetime NewCandleTime = TimeCurrent();
bool CheckIfNewCandle()
{
    if (NewCandleTime == iTime(Symbol(), 0, 0)) return false;
    else
    {
        NewCandleTime = iTime(Symbol(), 0, 0);
        return true;
    }
}

//Check if it is a trade Signla 0 - Neutral, 1 - Buy, -1 - Sell
ENUM_TRADE_SIGNAL IsSignal(int i)
{
    int j = i + Shift;
    if(BufferMAFast[j + 1] < BufferMASlow[j + 1] && BufferMAFast[j] > BufferMASlow[j]) return SIGNAL_BUY;
    if(BufferMAFast[j + 1] > BufferMASlow[j + 1] && BufferMAFast[j] < BufferMASlow[j]) return SIGNAL_SELL;

    return SIGNAL_NEUTRAL;
}

void NotifyHit()
{
    if (!EnableNotify) return;
    if ((!SendAlert) && (!SendApp) && (!SendEmail)) return;
    if ((CandleToCheck == CLOSED_CANDLE) && (Time[0] <= LastNotificationTime)) return;
    ENUM_TRADE_SIGNAL Signal = IsSignal(0);
    if (Signal == SIGNAL_NEUTRAL)
    {
        LastNotificationDirection = Signal;
        return;
    }
    if (Signal == LastNotificationDirection) return;
    string EmailSubject = IndicatorName + " " + Symbol() + " Notification ";
    string EmailBody = AccountCompany() + " - " + AccountName() + " - " + IntegerToString(AccountNumber()) + "\r\n\r\n" + IndicatorName + " Notification for " + Symbol() + " @ " + EnumToString((ENUM_TIMEFRAMES)Period()) + "\r\n\r\n";
    string AlertText = IndicatorName + " - " + Symbol() + " @ " + EnumToString((ENUM_TIMEFRAMES)Period()) + " ";
    string AppText = AccountCompany() + " - " + AccountName() + " - " + IntegerToString(AccountNumber()) + " - " + IndicatorName + " - " + Symbol() + " @ " + EnumToString((ENUM_TIMEFRAMES)Period()) + " - ";
    string Text = "";

    Text += "Slow and Fast Moving Average Crossed - " + ((Signal == SIGNAL_SELL) ? "Sell" : "Buy");

    EmailBody += Text;
    AlertText += Text;
    AppText += Text;
    if (SendAlert) Alert(AlertText);
    if (SendEmail)
    {
        if (!SendMail(EmailSubject, EmailBody)) Print("Error sending email " + IntegerToString(GetLastError()));
    }
    if (SendApp)
    {
        if (!SendNotification(AppText)) Print("Error sending notification " + IntegerToString(GetLastError()));
    }
    LastNotificationTime = Time[0];
    LastNotificationDirection = Signal;
}

void DrawArrows(int limit)
{
    for (int i = limit - 1; i >= 1; i--)
    {
        DrawArrow(i);
    }
}

void RemoveArrows()
{
    ObjectsDeleteAll(ChartID(), IndicatorName + "-ARWS-");
}

void DrawArrow(int i)
{
    RemoveArrowCurr();
    ENUM_TRADE_SIGNAL Signal = IsSignal(i);
    if (Signal == SIGNAL_NEUTRAL) return;
    datetime ArrowDate = iTime(Symbol(), 0, i);
    string ArrowName = IndicatorName + "-ARWS-" + IntegerToString(ArrowDate);
    double ArrowPrice = 0;
    int ArrowType = 0;
    color ArrowColor = 0;
    int ArrowAnchor = 0;
    string ArrowDesc = "";
    if (Signal == SIGNAL_BUY)
    {
        ArrowPrice = Low[i];
        ArrowType = ArrowBuy;
        ArrowColor = ArrowBuyColor;
        ArrowAnchor = ANCHOR_TOP;
        ArrowDesc = "BUY";
    }
    if(Signal == SIGNAL_SELL)
    {
        ArrowPrice = High[i];
        ArrowType = ArrowSell;
        ArrowColor = ArrowSellColor;
        ArrowAnchor = ANCHOR_BOTTOM;
        ArrowDesc = "SELL";
    }
    ObjectCreate(0, ArrowName, OBJ_ARROW, 0, ArrowDate, ArrowPrice);
    ObjectSetInteger(0, ArrowName, OBJPROP_COLOR, ArrowColor);
    ObjectSetInteger(0, ArrowName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, ArrowName, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, ArrowName, OBJPROP_ANCHOR, ArrowAnchor);
    ObjectSetInteger(0, ArrowName, OBJPROP_ARROWCODE, ArrowType);
    ObjectSetInteger(0, ArrowName, OBJPROP_WIDTH, ArrowSize);
    ObjectSetInteger(0, ArrowName, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, ArrowName, OBJPROP_BGCOLOR, ArrowColor);
    ObjectSetString(0, ArrowName, OBJPROP_TEXT, ArrowDesc);
}

void RemoveArrowCurr()
{
    datetime ArrowDate = iTime(Symbol(), 0, 0);
    string ArrowName = IndicatorName + "-ARWS-" + IntegerToString(ArrowDate);
    ObjectDelete(0, ArrowName);
}
//+------------------------------------------------------------------+