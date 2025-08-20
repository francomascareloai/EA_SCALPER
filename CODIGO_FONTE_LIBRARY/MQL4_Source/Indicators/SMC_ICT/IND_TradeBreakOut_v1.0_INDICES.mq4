//+------------------------------------------------------------------+
//|                                                TradeBreakOut.mq4 |
//|                             Copyright © 2013-2022, EarnForex.com |
//|                                       https://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013-2022, www.EarnForex.com"
#property link      "https://www.earnforex.com/metatrader-indicators/TradeBreakOut/"
#property version   "1.01"
#property strict

#property description "Red line crossing 0 from above is a support breakout signal."
#property description "Green line crossing 0 from below is a resistance breakout signal."

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_level1 0
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT
#property indicator_levelcolor clrDarkGray
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrGreen
#property indicator_label1 "Resistance Breakout"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrRed
#property indicator_label2 "Support Breakout"

enum enum_applied_price
{
    PriceClose, // Close
    PriceHighLow, // High/Low
};

enum enum_candle_to_check
{
    Current,
    Previous
};

input int L = 50; // Period
input enum_applied_price PriceType = PriceHighLow;
input bool EnableNativeAlerts  = false;
input bool EnableEmailAlerts   = false;
input bool EnablePushAlerts    = false;
input enum_candle_to_check TriggerCandle = Previous;

// Buffers
double TBR_R[], TBR_S[];

datetime LastAlertTime = D'01.01.1970';

void OnInit()
{
    SetIndexBuffer(0, TBR_R);
    SetIndexBuffer(1, TBR_S);

    SetIndexDrawBegin(0, L);
    SetIndexDrawBegin(1, L);

    SetIndexEmptyValue(0, EMPTY_VALUE);
    SetIndexEmptyValue(1, EMPTY_VALUE);

    IndicatorDigits(Digits);

    IndicatorShortName("TBR (" + IntegerToString(L) + ")");
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[]
)
{    
    if (Bars <= L) return 0;

    int counted_bars = IndicatorCounted();
    if (counted_bars > 0) counted_bars--;

    // Skip calculated bars.
    int end = Bars - counted_bars;
    
    // Cannot calculate bars that are too close to the end. There won't be enough bars to calculate ArrayMin/Max.
    if (Bars - end <= L) end = Bars - L - 1;

    for (int i = 0; i < end; i++)
    {
        if (PriceType == PriceClose)
        {
            TBR_R[i] = (Close[i] - Close[ArrayMaximum(Close, L, i + 1)]) / Close[ArrayMaximum(Close, L, i + 1)];
            TBR_S[i] = (Close[i] - Close[ArrayMinimum(Close, L, i + 1)]) / Close[ArrayMinimum(Close, L, i + 1)];
        }
        else if (PriceType == PriceHighLow)
        {
            TBR_R[i] = (High[i] - High[ArrayMaximum(High, L, i + 1)]) / High[ArrayMaximum(High, L, i + 1)];
            TBR_S[i] = (Low[i] - Low[ArrayMinimum(Low, L, i + 1)]) / Low[ArrayMinimum(Low, L, i + 1)];
        }
    }
    
    // Alerts
    if (((TriggerCandle > 0) && (Time[0] > LastAlertTime)) || (TriggerCandle == 0))
    {
        string Text;
        // Buy signal.
        if ((TBR_R[TriggerCandle] > 0) && (TBR_R[TriggerCandle + 1] <= 0))
        {
            Text = "TBR: " + Symbol() + " - " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)Period()), 7) + " - Crossed 0 from below.";
            if (EnableNativeAlerts) Alert(Text);
            if (EnableEmailAlerts) SendMail("TBR Alert", Text);
            if (EnablePushAlerts) SendNotification(Text);
            LastAlertTime = Time[0];
        }
        // Sell signal.
        if ((TBR_S[TriggerCandle] < 0) && (TBR_S[TriggerCandle + 1] >= 0))
        {
            Text = "TBR: " + Symbol() + " - " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)Period()), 7) + " - Crossed 0 from above.";
            if (EnableNativeAlerts) Alert(Text);
            if (EnableEmailAlerts) SendMail("TBR Alert", Text);
            if (EnablePushAlerts) SendNotification(Text);
            LastAlertTime = Time[0];
        }
    }

    return rates_total;
}
//+------------------------------------------------------------------+