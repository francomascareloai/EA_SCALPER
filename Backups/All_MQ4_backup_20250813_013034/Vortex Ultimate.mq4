//+------------------------------------------------------------------+
//|                                                  Vortex Ultimate |
//|                                      Copyright © 2024, EarnForex |
//|                                        https://www.earnforex.com |
//+------------------------------------------------------------------+
#property copyright "www.EarnForex.com, 2024"
#property link      "https://www.earnforex.com/metatrader-indicators/Vortex-Ultimate/"
#property version   "1.00"
#property icon      "\\Files\\EF-Icon-64x64px.ico"
#property strict

#property description "A classic Vortex indicator with extra features:"
#property description " * MTF support (higher timeframe data on a lower timeframe)"
#property description " * Smoothing (simple, exponential, TEMA)"
#property description " * Alert system (cross, reversal)"

#property indicator_separate_window
#property indicator_buffers 11 // Two actual output buffers, two buffers for smoothing, six additional buffers for TEMA smoothing, one buffer for MTF optimization.
#property indicator_color1 clrBlue
#property indicator_type1 DRAW_LINE
#property indicator_width1 2
#property indicator_label1 "VI+"
#property indicator_color2 clrRed
#property indicator_type2 DRAW_LINE
#property indicator_width2 2
#property indicator_label2 "VI-"
#property indicator_type3 DRAW_NONE
#property indicator_type4 DRAW_NONE
#property indicator_type5 DRAW_NONE
#property indicator_type6 DRAW_NONE
#property indicator_type7 DRAW_NONE
#property indicator_type8 DRAW_NONE
#property indicator_type9 DRAW_NONE
#property indicator_type10 DRAW_NONE
#property indicator_type11 DRAW_NONE

// Enumeration for alert candle:
enum ENUM_ALERT_CANDLE
{
    ALERT_PREVIOUS_CANDLE, // Previous
    ALERT_CURRENT_CANDLE // Current
};

// Enumeration for smoothing types:
enum ENUM_SMOOTHING_TYPE
{
    SMOOTHING_SIMPLE, // Simple
    SMOOTHING_EXPONENTIAL, // Exponential
    SMOOTHING_TEMA // Triple exponential (slowest)
};

// Enumeration for alert types:
enum ENUM_ALERT_TYPE
{
    ALERT_TYPE_CROSS, // Alert when VI+ crosses VI-
    ALERT_TYPE_REVERSAL, // Alert when VI+ and VI- reverse
    ALERT_TYPE_BOTH // Alert on both signals
};

// For reversal alerts. Can be either widening, neutral, or tightening.
enum ENUM_REVERSAL_STATE
{
    REVERSAL_STATE_NEUTRAL, // Neutral
    REVERSAL_STATE_WIDENING, // Widening
    REVERSAL_STATE_TIGHTENING // Tightening
};

input int IndPeriod = 14; // Period
input int Smoothing = 0;
input ENUM_SMOOTHING_TYPE TypeSmoothing = SMOOTHING_SIMPLE;
input ENUM_TIMEFRAMES InpTimeframe = PERIOD_CURRENT; // Timeframe
input ENUM_ALERT_TYPE AlertType = ALERT_TYPE_BOTH; // Alert Type
input ENUM_ALERT_CANDLE AlertCandle = ALERT_PREVIOUS_CANDLE; // Alert Candle
input bool IsShowAlert = false; // Show Alert
input bool IsSendEmail = false; // Send Email
input bool IsSendNotification = false; // Send Notification

// Buffers:
double PlusVI[];         // VI+: Vortex Indicator+
double MinusVI[];        // VI-: Vortex Indicator-
double prePlusVI[];      // Pre-Smoothed Vortex Indicator+ when smoothing is enabled.
double preMinusVI[];     // Pre-Smoothed Vortex Indicator- when smoothing is enabled.
double TEMA_1_PlusVI[];  // First pass of exponentiation for TEMA smoothing for VI+.
double TEMA_1_MinusVI[]; // First pass of exponentiation for TEMA smoothing for VI-.
double TEMA_2_PlusVI[];  // Second pass of exponentiation for TEMA smoothing for VI+.
double TEMA_2_MinusVI[]; // Second pass of exponentiation for TEMA smoothing for VI-.
double TEMA_3_PlusVI[];  // Third pass of exponentiation for TEMA smoothing for VI+.
double TEMA_3_MinusVI[]; // Third pass of exponentiation for TEMA smoothing for VI-.
double UpperTFShift[];   // Buffer to store upper timeframe bar numbers for quick access.

ENUM_TIMEFRAMES Timeframe; // Timeframe of operation.
int deltaHighTF; // Difference in candles count from the higher timeframe.

// Global variables:
int RatesTotal;
int PrevCalculated;
int UpperTimeframeCalculated;
bool IsBullishCrossing;
bool IsBearishCrossing;
bool IsBullishReversal;
bool IsBearishReversal;
string BullishCrossingAlertMessage;
string BearishCrossingAlertMessage;
string BullishReversalAlertMessage;
string BearishReversalAlertMessage;
string AlertPrefix;
double alpha;
ENUM_REVERSAL_STATE CurrentState = REVERSAL_STATE_NEUTRAL; // 'Neutral' is used for initialization only. Normally 'Neutral' state isn't stored.

void OnInit()
{
    IndicatorSetInteger(INDICATOR_DIGITS, 6);
    string name = "Vortex Ultimate (" + IntegerToString(IndPeriod) + ") ";
    if (Smoothing > 0)
    {
        string s_type = "";
        if (TypeSmoothing  == SMOOTHING_SIMPLE)
        {
            s_type = "Simple";
        }
        else 
        {
            if  (TypeSmoothing == SMOOTHING_EXPONENTIAL) s_type = "Exponential";
            else if  (TypeSmoothing == SMOOTHING_TEMA) s_type = "TEMA";
            alpha = 2.0 / (Smoothing + 1.0);
        }
        name += "Smoothed (" + s_type + ", " + IntegerToString(Smoothing) + ") ";
    }
    SetIndexBuffer(0, PlusVI, INDICATOR_DATA);
    SetIndexBuffer(1, MinusVI, INDICATOR_DATA);
    SetIndexBuffer(2, prePlusVI, INDICATOR_DATA);
    SetIndexBuffer(3, preMinusVI, INDICATOR_DATA);
    SetIndexBuffer(4, TEMA_1_PlusVI, INDICATOR_DATA);
    SetIndexBuffer(5, TEMA_1_MinusVI, INDICATOR_DATA);
    SetIndexBuffer(6, TEMA_2_PlusVI, INDICATOR_DATA);
    SetIndexBuffer(7, TEMA_2_MinusVI, INDICATOR_DATA);
    SetIndexBuffer(8, TEMA_3_PlusVI, INDICATOR_DATA);
    SetIndexBuffer(9, TEMA_3_MinusVI, INDICATOR_DATA);
    SetIndexBuffer(10, UpperTFShift, INDICATOR_DATA);
    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, IndPeriod + Smoothing);
    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, IndPeriod + Smoothing);
    PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);

    ArraySetAsSeries(PlusVI, false);
    ArraySetAsSeries(MinusVI, false);
    ArraySetAsSeries(prePlusVI, false);
    ArraySetAsSeries(preMinusVI, false);
    ArraySetAsSeries(TEMA_1_PlusVI, false);
    ArraySetAsSeries(TEMA_1_MinusVI, false);
    ArraySetAsSeries(TEMA_2_PlusVI, false);
    ArraySetAsSeries(TEMA_2_MinusVI, false);
    ArraySetAsSeries(TEMA_3_PlusVI, false);
    ArraySetAsSeries(TEMA_3_MinusVI, false);
    ArraySetAsSeries(UpperTFShift, false);

    // Initializing global variables:
    IsBullishCrossing = false;
    IsBearishCrossing = false;
    IsBearishReversal = false;
    IsBearishCrossing = false;
    BullishCrossingAlertMessage = " Bullish Crossing";
    BearishCrossingAlertMessage = " Bearish Crossing";
    BullishReversalAlertMessage = " Bullish Reversal";
    BearishReversalAlertMessage = " Bearish Reversal";
    RatesTotal = 0;
    PrevCalculated = 0;
    UpperTimeframeCalculated = 0;

    // Setting values for the higher timeframe:
    Timeframe = InpTimeframe;
    if (InpTimeframe < Period())
    {
        Timeframe = (ENUM_TIMEFRAMES)Period();
    }
    else if (InpTimeframe > Period())
    {
        name += " @ " + EnumToString(Timeframe);
        StringReplace(name, "PERIOD_", "");
    }
    IndicatorSetString(INDICATOR_SHORTNAME, name);

    AlertPrefix = _Symbol + " @ " + EnumToString((ENUM_TIMEFRAMES)_Period);
    if (Timeframe != Period()) AlertPrefix += " (" + EnumToString(Timeframe) + ") ";
    StringReplace(AlertPrefix, "PERIOD_", "");
    
    deltaHighTF = 0;
    if (Timeframe > Period())
    {
        deltaHighTF = Timeframe / Period();
    }
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
    if ((iBars(_Symbol, Timeframe) < IndPeriod) || ((Smoothing > 0) && (iBars(_Symbol, Timeframe) < IndPeriod + Smoothing))) return 0;

    RatesTotal = rates_total;
    PrevCalculated = prev_calculated;
    int Upper_RT = iBars(_Symbol, Timeframe);

    // Starting position for calculations.
    int pos = prev_calculated - 1 - deltaHighTF;
    if (pos < IndPeriod - 1) // Pre-fill upper timeframe buffer.
    {
        if (pos < 0) pos = 0;
        if (Timeframe != Period())
        {
            for (int i = pos; i < IndPeriod - 1 && !IsStopped(); i++)
            {
                int index = rates_total - 1 - i;
                int shift = index;
                if (Timeframe != Period()) shift = iBarShift(_Symbol, Timeframe, iTime(_Symbol, PERIOD_CURRENT, index));
                UpperTFShift[i] = Upper_RT - 1 - shift;
            }
        }
        pos = IndPeriod - 1;
    }
    for (int i = pos; i < rates_total && !IsStopped(); i++)
    {
        int index = rates_total - 1 - i;
        int shift = index;
        if (Timeframe != Period())
        {
            shift = iBarShift(_Symbol, Timeframe, iTime(_Symbol, PERIOD_CURRENT, index));
            if (Upper_RT - 1 - shift == UpperTFShift[i - 1]) // If previous upper timeframe shift equals current, then current indicator values should be the same as previous. No need to re-calculate them.
            {
                if (Smoothing > 0) // Use different arrays to store raw values when smoothing is used.
                {
                    prePlusVI[i] = prePlusVI[i - 1];
                    preMinusVI[i] = preMinusVI[i - 1];
                }
                else
                {
                    PlusVI[i] = PlusVI[i - 1];
                    MinusVI[i] = MinusVI[i - 1];
                }
                UpperTFShift[i] = Upper_RT - 1 - shift;
                continue;
            }
        }
        double SumPlusVM = 0;
        double SumMinusVM = 0;
        double SumTR = 0;
        for (int j = 0; j < IndPeriod; j++)
        {
            double H = iHigh(_Symbol, Timeframe, shift + j); // Current High.
            double L = iLow(_Symbol, Timeframe, shift + j); // Current Low.
            double C_P = iClose(_Symbol, Timeframe, shift + j + 1); // Previous Close.
            SumPlusVM += MathAbs(H - iLow(_Symbol, Timeframe, shift + j + 1));
            SumMinusVM += MathAbs(L - iHigh(_Symbol, Timeframe, shift + j + 1));
            SumTR += MathMax(H, C_P) - MathMin(L, C_P); // True range.
        }
        if (SumTR == 0) continue; // Avoid division by zero.
        
        if (Smoothing > 0) // Use different arrays to store raw values when smoothing is used.
        {
            prePlusVI[i] = SumPlusVM / SumTR;
            preMinusVI[i] = SumMinusVM / SumTR;
        }
        else
        {
            PlusVI[i] = SumPlusVM / SumTR;
            MinusVI[i] = SumMinusVM / SumTR;
        }
        UpperTFShift[i] = Upper_RT - 1 - shift;
    }

    if (Smoothing > 0)
    {
        for (int i = pos; i < rates_total && !IsStopped(); i++)
        {
            if (TypeSmoothing == SMOOTHING_SIMPLE)
            {
                if (i < IndPeriod + Smoothing) continue;
                if ((Timeframe != Period()) && ((UpperTFShift[i] == EMPTY_VALUE) || (UpperTFShift[i] - UpperTFShift[0] < IndPeriod + Smoothing) || (UpperTFShift[i - Smoothing] == EMPTY_VALUE))) continue;
            }
            else // Exponential or TEMA.
            {
                if (i < IndPeriod - 1) continue;
                if ((Timeframe != Period()) && ((UpperTFShift[i] == EMPTY_VALUE) || (UpperTFShift[i] - UpperTFShift[0] < IndPeriod - 1))) continue;
            }
            DoSmoothing(i);
        }
    }

    HandleAlerts();
    
    UpperTimeframeCalculated = Upper_RT;

    return rates_total;
}

void HandleAlerts()
{
    if ((!IsShowAlert) && (!IsSendEmail) && (!IsSendNotification)) return; // No alerts are needed

    if (!PrevCalculated)
    {
        RefreshGlobalVariables(); // Refresh alert global variables after attaching indicator.
    }
    else if (PrevCalculated != RatesTotal)
    {
        if ((Timeframe == Period()) || (UpperTimeframeCalculated != iBars(_Symbol, Timeframe)))
        {
            ResetGlobalVariables(); // Reset alert global variables after new candle forming.
        }
    }

    string IsBullishCrossingMessage = NULL;
    string IsBearishCrossingMessage = NULL;
    string IsBullishReversalMessage = NULL;
    string IsBearishReversalMessage = NULL;

    // Checking for alerts and saving info about it
    if ((AlertType == ALERT_TYPE_CROSS) || (AlertType == ALERT_TYPE_BOTH))
    {
        if ((!IsBearishCrossing) &&
            (HasBearishCrossing()))
        {
            IsBearishCrossingMessage = BearishCrossingAlertMessage;
            IsBearishCrossing = true;
        }
        if ((!IsBullishCrossing) &&
            (HasBullishCrossing()))
        {
            IsBullishCrossingMessage = BullishCrossingAlertMessage;
            IsBullishCrossing = true;
        }
        IssueAlerts(IsBearishCrossingMessage);
        IssueAlerts(IsBullishCrossingMessage);
    }
    
    if ((AlertType == ALERT_TYPE_REVERSAL) || (AlertType == ALERT_TYPE_BOTH))
    {
        if ((!IsBearishReversal) &&
            (HasBearishReversal()))
        {
            IsBearishReversalMessage = BearishReversalAlertMessage;
            IsBearishReversal = true;
        }
        if ((!IsBullishReversal) &&
            (HasBullishReversal()))
        {
            IsBullishReversalMessage = BullishReversalAlertMessage;
            IsBullishReversal = true;
        }
        IssueAlerts(IsBearishReversalMessage);
        IssueAlerts(IsBullishReversalMessage);
    }
}

void IssueAlerts(string message)
{
    if (message == NULL) return;

    message = "[VU] " + AlertPrefix + message;

    if (IsShowAlert)
    {
        Alert(message);
    }

    if (IsSendEmail)
    {
        SendMail("Vortex Ultimate Indicator", message);
    }

    if (IsSendNotification)
    {
        SendNotification(message);
    }
}

//+------------------------------------------------------------------+
//| Checking if there is a bearish crossing.                         |
//+------------------------------------------------------------------+
bool HasBearishCrossing()
{
    int shift = AlertCandle == ALERT_PREVIOUS_CANDLE ? RatesTotal - 2 : RatesTotal - 1;
    
    // For upper timeframe, have to find the right completed bar.
    if ((Timeframe != Period()) && (AlertCandle == ALERT_PREVIOUS_CANDLE))
    {
        // Start: shift = pre-latest bar on current timeframe, shift + 1 = latest bar.
        while (UpperTFShift[shift] == UpperTFShift[shift + 1]) shift--;
        // End: shift = the first bar where the upper timeframe shift value is different from the latest bar's value.
    }

    // Find the current timeframe bar that corresponds to the upper timeframe's previous bar by checking the UpperTFShift index array.
    for (int i = shift - 1; i >= 0; i--)
    {
        if (UpperTFShift[i] != UpperTFShift[shift]) // Found.
        {
            if ((PlusVI[shift] < MinusVI[shift]) && (PlusVI[i] >= MinusVI[i])) return true;
            return false;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Checking if there is a bullish crossing.                         |
//+------------------------------------------------------------------+
bool HasBullishCrossing()
{
    int shift = AlertCandle == ALERT_PREVIOUS_CANDLE ? RatesTotal - 2 : RatesTotal - 1;
    
    // For upper timeframe, have to find the right completed bar.
    if ((Timeframe != Period()) && (AlertCandle == ALERT_PREVIOUS_CANDLE))
    {
        // Start: shift = pre-latest bar on current timeframe, shift + 1 = latest bar.
        while (UpperTFShift[shift] == UpperTFShift[shift + 1]) shift--;
        // End: shift = the first bar where the upper timeframe shift value is different from the latest bar's value.
    }

    // Find the current timeframe bar that corresponds to the upper timeframe's previous bar by finding the first different indicator value.
    for (int i = shift - 1; i >= 0; i--)
    {
        if (UpperTFShift[i] != UpperTFShift[shift]) // Found.
        {
            if ((PlusVI[shift] > MinusVI[shift]) && (PlusVI[i] <= MinusVI[i])) return true;
            return false;
        }
    }

    return false;
}

//+------------------------------------------------------------------+
//| Checking if there is a bearish reversal.                         |
//+------------------------------------------------------------------+
bool HasBearishReversal()
{
    int shift = AlertCandle == ALERT_PREVIOUS_CANDLE ? RatesTotal - 2 : RatesTotal - 1;

    // For upper timeframe, have to find the right completed bar.
    if ((Timeframe != Period()) && (AlertCandle == ALERT_PREVIOUS_CANDLE))
    {
        // Start: shift = pre-latest bar on current timeframe, shift + 1 = latest bar.
        while (UpperTFShift[shift] == UpperTFShift[shift + 1]) shift--;
        // End: shift = the first bar where the upper timeframe shift value is different from the latest bar's value.
    }

    // Find the current timeframe bar that corresponds to the upper timeframe's previous bar by checking the UpperTFShift index array.
    int i = shift - 1;
    while (UpperTFShift[i] == UpperTFShift[shift]) i--;

    if (CurrentState == REVERSAL_STATE_NEUTRAL) // First time.
    {
        if (PlusVI[shift] - MinusVI[shift] > PlusVI[i] - MinusVI[i]) CurrentState = REVERSAL_STATE_TIGHTENING; // Tightened.
        else if (PlusVI[shift] - MinusVI[shift] < PlusVI[i] - MinusVI[i]) CurrentState = REVERSAL_STATE_WIDENING; // Widened.
        return false;
    }
    if (CurrentState == REVERSAL_STATE_TIGHTENING)
    {
        if (PlusVI[shift] - MinusVI[shift] < PlusVI[i] - MinusVI[i])
        {
            CurrentState = REVERSAL_STATE_WIDENING; // Widened.
            return true;
        }
    }

    return false;
}

//+------------------------------------------------------------------+
//| Checking if there is a bullish reversal.                         |
//+------------------------------------------------------------------+
bool HasBullishReversal()
{
    int shift = AlertCandle == ALERT_PREVIOUS_CANDLE ? RatesTotal - 2 : RatesTotal - 1;

    // For upper timeframe, have to find the right completed bar.
    if ((Timeframe != Period()) && (AlertCandle == ALERT_PREVIOUS_CANDLE))
    {
        // Start: shift = pre-latest bar on current timeframe, shift + 1 = latest bar.
        while (UpperTFShift[shift] == UpperTFShift[shift + 1]) shift--;
        // End: shift = the first bar where the upper timeframe shift value is different from the latest bar's value.
    }

    // Find the current timeframe bar that corresponds to the upper timeframe's previous bar by checking the UpperTFShift index array.
    int i = shift - 1;
    while (UpperTFShift[i] == UpperTFShift[shift]) i--;

    if (CurrentState == REVERSAL_STATE_NEUTRAL) // First time.
    {
        if (PlusVI[shift] - MinusVI[shift] > PlusVI[i] - MinusVI[i]) CurrentState = REVERSAL_STATE_TIGHTENING; // Tightened.
        else if (PlusVI[shift] - MinusVI[shift] < PlusVI[i] - MinusVI[i]) CurrentState = REVERSAL_STATE_WIDENING; // Widened.
        return false;
    }
    if (CurrentState == REVERSAL_STATE_WIDENING)
    {
        if (PlusVI[shift] - MinusVI[shift] > PlusVI[i] - MinusVI[i])
        {
            CurrentState = REVERSAL_STATE_TIGHTENING; // Tightened.
            return true;
        }
    }

    return false;
}

void ResetGlobalVariables()
{
    IsBearishCrossing = false;
    IsBullishCrossing = false;
    IsBearishReversal = false;
    IsBullishReversal = false;
}

void RefreshGlobalVariables()
{
    if ((AlertType == ALERT_TYPE_CROSS) || (AlertType == ALERT_TYPE_BOTH))
    {
        IsBearishCrossing = HasBearishCrossing();
        IsBullishCrossing = HasBullishCrossing();
    }
    if ((AlertType == ALERT_TYPE_REVERSAL) || (AlertType == ALERT_TYPE_BOTH))
    {
        IsBullishReversal = HasBullishReversal();
        IsBearishReversal = HasBearishReversal();
    }
}

void DoSmoothing(int i)
{
    double SumPlusVI = 0;
    double SumMinusVI = 0;
    if (Timeframe > Period()) // MTF
    {
        if (UpperTFShift[i] == UpperTFShift[i - 1]) // If previous upper timeframe shift equals current, then current indicator values should be the same as previous. No need to re-calculate them.
        {
            PlusVI[i] = PlusVI[i - 1];
            MinusVI[i] = MinusVI[i - 1];
            TEMA_1_PlusVI[i] = TEMA_1_PlusVI[i - 1];
            TEMA_1_MinusVI[i] = TEMA_1_MinusVI[i - 1];
            TEMA_2_PlusVI[i] = TEMA_2_PlusVI[i - 1];
            TEMA_2_MinusVI[i] = TEMA_2_MinusVI[i - 1];
            TEMA_3_PlusVI[i] = TEMA_3_PlusVI[i - 1];
            TEMA_3_MinusVI[i] = TEMA_3_MinusVI[i - 1];
            return;
        }
        if (TypeSmoothing == SMOOTHING_SIMPLE)
        {
            static bool First = true;
            if ((First) && (UpperTFShift[i] - UpperTFShift[0] >= IndPeriod + Smoothing)) // First smoothed element.
            {
                for (int j = 0, k = 0; k < Smoothing; k++, j++)
                {
                    SumPlusVI += prePlusVI[i - j];
                    SumMinusVI += preMinusVI[i - j];
                    while (UpperTFShift[i - j - 1] == UpperTFShift[i - j])
                    {
                        j++;
                    }
                }
                PlusVI[i] = SumPlusVI / Smoothing;
                MinusVI[i] = SumMinusVI / Smoothing;
                First = false;
            }
            else // Next smoothed elements can be calculated using the previous ones.
            {
                int j = 1;
                // Find previous upper timeframe PlusVI.
                while (UpperTFShift[i - j] == UpperTFShift[i])
                {
                    j++;
                }

                int prev_j = j;
                // Find last upper timeframe prePlusVI (the one that's out of the moving average calculation at this point).
                // Do it by finding N changes in the upper timeframe bar numbers. This helps to avoid issues when there is a hole in lower timeframe history.
                int count = 0;
                while (count < Smoothing)
                {
                    if (UpperTFShift[i - j + 1] != UpperTFShift[i - j]) count++;
                    j++;
                }

                PlusVI[i] = PlusVI[i - prev_j] + (prePlusVI[i] - prePlusVI[i - j]) / Smoothing;
                MinusVI[i] = MinusVI[i - prev_j] + (preMinusVI[i] - preMinusVI[i - j]) / Smoothing;
            }
        }
        else if (TypeSmoothing == SMOOTHING_EXPONENTIAL)
        {
            static bool First = true;
            if ((First) && (UpperTFShift[i] - UpperTFShift[0] >= IndPeriod - 1)) // First smoothed element.
            {
                PlusVI[i] = prePlusVI[i];
                MinusVI[i] = preMinusVI[i];
                First = false;
            }
            else // Next smoothed elements can be calculated using the previous ones.
            {
                int j = 1;
                // Find previous upper timeframe PlusVI.
                while (UpperTFShift[i - j] == UpperTFShift[i])
                {
                    j++;
                }
                PlusVI[i] = alpha * prePlusVI[i] + (1 - alpha) * PlusVI[i - j];
                MinusVI[i] = alpha * preMinusVI[i] + (1 - alpha) * MinusVI[i - j];
            }
        }
        else if (TypeSmoothing == SMOOTHING_TEMA)
        {
            static bool First = true;
            if ((First) && (UpperTFShift[i] - UpperTFShift[0] >= IndPeriod - 1)) // First element.
            {
                TEMA_1_PlusVI[i] = prePlusVI[i];
                TEMA_1_MinusVI[i] = preMinusVI[i];
                TEMA_2_PlusVI[i] = prePlusVI[i];
                TEMA_2_MinusVI[i] = preMinusVI[i];
                TEMA_3_PlusVI[i] = prePlusVI[i];
                TEMA_3_MinusVI[i] = preMinusVI[i];
                PlusVI[i] = prePlusVI[i];
                MinusVI[i] = preMinusVI[i];
                First = false;
            }
            int j = 1;
            // Find previous upper timeframe PlusVI.
            while (UpperTFShift[i - j] == UpperTFShift[i])
            {
                j++;
            }
            if (UpperTFShift[i] - UpperTFShift[0] > IndPeriod - 1)
            {
                TEMA_1_PlusVI[i] = alpha * prePlusVI[i] + (1 - alpha) * TEMA_1_PlusVI[i - j];
                TEMA_1_MinusVI[i] = alpha * preMinusVI[i] + (1 - alpha) * TEMA_1_MinusVI[i - j];
                static bool Second = true;
                if ((Second) && (UpperTFShift[i] - UpperTFShift[0] >= IndPeriod)) // Second element.
                {
                    TEMA_2_PlusVI[i] = TEMA_1_PlusVI[i];
                    TEMA_2_MinusVI[i] = TEMA_1_MinusVI[i];
                    TEMA_3_PlusVI[i] = TEMA_1_PlusVI[i];
                    TEMA_3_MinusVI[i] = TEMA_1_MinusVI[i];
                    PlusVI[i] = TEMA_1_PlusVI[i];
                    MinusVI[i] = TEMA_1_MinusVI[i];
                    Second = false;
                }
            }
            if (UpperTFShift[i] - UpperTFShift[0] > IndPeriod)
            {
                TEMA_2_PlusVI[i] = alpha * TEMA_1_PlusVI[i] + (1 - alpha) * TEMA_2_PlusVI[i - j];
                TEMA_2_MinusVI[i] = alpha * TEMA_1_MinusVI[i] + (1 - alpha) * TEMA_2_MinusVI[i - j];
                static bool Third = true;
                if ((Third) && (UpperTFShift[i] - UpperTFShift[0] >= IndPeriod + 1)) // Third element.
                {
                    TEMA_3_PlusVI[i] = TEMA_2_PlusVI[i];
                    TEMA_3_MinusVI[i] = TEMA_2_MinusVI[i];
                    PlusVI[i] = TEMA_2_PlusVI[i];
                    MinusVI[i] = TEMA_2_MinusVI[i];
                    Third = false;
                }
            }
            if (UpperTFShift[i] - UpperTFShift[0] > IndPeriod + 1)
            {
                TEMA_3_PlusVI[i] = alpha * TEMA_2_PlusVI[i] + (1 - alpha) * TEMA_3_PlusVI[i - j];
                TEMA_3_MinusVI[i] = alpha * TEMA_2_MinusVI[i] + (1 - alpha) * TEMA_3_MinusVI[i - j];
                static int Fourth = true;
                if ((Fourth) && (UpperTFShift[i] - UpperTFShift[0] >= IndPeriod + 2)) // Fourth element.
                {
                    PlusVI[i] = TEMA_3_PlusVI[i];
                    MinusVI[i] = TEMA_3_MinusVI[i];
                    Fourth = false;
                }
            }
            if (UpperTFShift[i] - UpperTFShift[0] > IndPeriod + 2)
            {
                PlusVI[i] = 3 * TEMA_1_PlusVI[i] - 3 * TEMA_2_PlusVI[i] + TEMA_3_PlusVI[i];
                MinusVI[i] = 3 * TEMA_1_MinusVI[i] - 3 * TEMA_2_MinusVI[i] + TEMA_3_MinusVI[i];
            }
        }
    }
    else // Non-MTF.
    {
        if (TypeSmoothing == SMOOTHING_SIMPLE)
        {
            if (i == IndPeriod + Smoothing) // First smoothed element.
            {
                for (int j = 0; j < Smoothing; j++)
                {
                    SumPlusVI += prePlusVI[i - j];
                    SumMinusVI += preMinusVI[i - j];
                }
                PlusVI[i] = SumPlusVI / Smoothing;
                MinusVI[i] = SumMinusVI / Smoothing;
            }
            else // Next smoothed elements can be calculated using the previous ones.
            {
                PlusVI[i] = PlusVI[i - 1] + (prePlusVI[i] - prePlusVI[i - Smoothing]) / Smoothing;
                MinusVI[i] = MinusVI[i - 1] + (preMinusVI[i] - preMinusVI[i - Smoothing]) / Smoothing;
            }
        }
        else if (TypeSmoothing == SMOOTHING_EXPONENTIAL)
        {
            if (i == IndPeriod - 1) // First element.
            {
                PlusVI[i] = prePlusVI[i];
                MinusVI[i] = preMinusVI[i];
            }
            else
            {
                PlusVI[i] = alpha * prePlusVI[i] + (1 - alpha) * PlusVI[i - 1];
                MinusVI[i] = alpha * preMinusVI[i] + (1 - alpha) * MinusVI[i - 1];
            }
        }
        else if (TypeSmoothing == SMOOTHING_TEMA)
        {
            if (i == IndPeriod - 1) // First element.
            {
                TEMA_1_PlusVI[i] = prePlusVI[i];
                TEMA_1_MinusVI[i] = preMinusVI[i];
                TEMA_2_PlusVI[i] = prePlusVI[i];
                TEMA_2_MinusVI[i] = preMinusVI[i];
                TEMA_3_PlusVI[i] = prePlusVI[i];
                TEMA_3_MinusVI[i] = preMinusVI[i];
                PlusVI[i] = prePlusVI[i];
                MinusVI[i] = preMinusVI[i];
            }
            if (i > IndPeriod - 1)
            {
                TEMA_1_PlusVI[i] = alpha * prePlusVI[i] + (1 - alpha) * TEMA_1_PlusVI[i - 1];
                TEMA_1_MinusVI[i] = alpha * preMinusVI[i] + (1 - alpha) * TEMA_1_MinusVI[i - 1];
                if (i == IndPeriod) // Second element.
                {
                    TEMA_2_PlusVI[i] = TEMA_1_PlusVI[i];
                    TEMA_2_MinusVI[i] = TEMA_1_MinusVI[i];
                    TEMA_3_PlusVI[i] = TEMA_1_PlusVI[i];
                    TEMA_3_MinusVI[i] = TEMA_1_MinusVI[i];
                    PlusVI[i] = TEMA_1_PlusVI[i];
                    MinusVI[i] = TEMA_1_MinusVI[i];
                }
            }
            if (i > IndPeriod)
            {
                TEMA_2_PlusVI[i] = alpha * TEMA_1_PlusVI[i] + (1 - alpha) * TEMA_2_PlusVI[i - 1];
                TEMA_2_MinusVI[i] = alpha * TEMA_1_MinusVI[i] + (1 - alpha) * TEMA_2_MinusVI[i - 1];
                if (i == IndPeriod + 1) // Third element.
                {
                    TEMA_3_PlusVI[i] = TEMA_2_PlusVI[i];
                    TEMA_3_MinusVI[i] = TEMA_2_MinusVI[i];
                    PlusVI[i] = TEMA_2_PlusVI[i];
                    MinusVI[i] = TEMA_2_MinusVI[i];
                }
            }
            if (i > IndPeriod + 1)
            {
                TEMA_3_PlusVI[i] = alpha * TEMA_2_PlusVI[i] + (1 - alpha) * TEMA_3_PlusVI[i - 1];
                TEMA_3_MinusVI[i] = alpha * TEMA_2_MinusVI[i] + (1 - alpha) * TEMA_3_MinusVI[i - 1];
                if (i == IndPeriod + 2) // Fourth element.
                {
                    PlusVI[i] = TEMA_3_PlusVI[i];
                    MinusVI[i] = TEMA_3_MinusVI[i];
                }
            }
            if (i > IndPeriod + 2)
            {
                PlusVI[i] = 3 * TEMA_1_PlusVI[i] - 3 * TEMA_2_PlusVI[i] + TEMA_3_PlusVI[i];
                MinusVI[i] = 3 * TEMA_1_MinusVI[i] - 3 * TEMA_2_MinusVI[i] + TEMA_3_MinusVI[i];
            }
        }
    }
}
//+------------------------------------------------------------------+