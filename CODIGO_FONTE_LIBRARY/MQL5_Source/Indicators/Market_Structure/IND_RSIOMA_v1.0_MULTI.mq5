//+------------------------------------------------------------------+
//|                                                       RSIOMA.mq5 |
//|                             Copyright © 2004-2022, EarnForex.com |
//|                                        https://www.earnforex.com |
//|       Based on indicator by Kalenzo (bartlomiej.gorski@gmail.com |
//|                                         http://www.fxservice.eu) |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004-2022, EarnForex.com"
#property link      "https://www.earnforex.com/metatrader-indicators/RSIOMA/"
#property version   "1.01"

#property description "RSIOMA displays a Relative Strenfth Index built based on relative MA strength, instead of the normal Close values."
#property description "The thin line is the MA of RSIOMA."
#property description "Main signal: RSIOMA crosses 20 from below or 80 from above."
#property description "Auxiliary signal: RSIOMA starts rising below 20 or starts falling above 80."

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots 3
#property indicator_color1 clrBlue
#property indicator_type1  DRAW_LINE
#property indicator_width1 3
#property indicator_label1 "RSIOMA"
#property indicator_color2 clrRed, clrGreen, clrMagenta, clrDodgerBlue
#property indicator_type2  DRAW_COLOR_HISTOGRAM
#property indicator_label2 "Trend Down", "Trend Up", "Reversal from Above", "Reversal from Below"
#property indicator_color3 clrBlueViolet
#property indicator_type3  DRAW_LINE
#property indicator_label3 "MA of RSIOMA"

#property indicator_minimum -10
#property indicator_maximum 100

enum enum_candle_to_check
{
    Current,
    Previous
};

input int                  RSIOMA              = 14; // RSIOMA Period
input ENUM_MA_METHOD       RSIOMA_MODE         = MODE_EMA; // RSIOMA Mode
input ENUM_APPLIED_PRICE   RSIOMA_PRICE        = PRICE_CLOSE; // RSIOMA Price
input int                  Ma_RSIOMA           = 21; // MA of RSIOMA Period
input ENUM_MA_METHOD       Ma_RSIOMA_MODE      = MODE_EMA; // MA of RSIOMA Mode
input int                  BuyTrigger          = 20;
input int                  SellTrigger         = 80;
input color                BuyTriggerColor     = clrMagenta;
input color                SellTriggerColor    = clrDodgerBlue;
input int                  MainTrendLong       = 50;
input int                  MainTrendShort      = 50;
input color                MainTrendLongColor  = clrRed;
input color                MainTrendShortColor = clrGreen;
input bool                 MainAlerts          = false;
input bool                 AuxiliaryAlerts     = false;
input bool                 EnableNativeAlerts  = false;
input bool                 EnableEmailAlerts   = false;
input bool                 EnablePushAlerts    = false;
input enum_candle_to_check TriggerCandle       = Previous;

// Indicator buffers:
double RSIBuffer[];
double PosBuffer[];
double NegBuffer[];
double Histogram[];
double Histogram_Color[];
double marsioma[];
double MA_Buffer[];

// Global variables:
string short_name;
datetime LastAlertTime = D'01.01.1970';
int MA_Handle;

void OnInit()
{
    SetIndexBuffer(0, RSIBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, Histogram, INDICATOR_DATA);
    SetIndexBuffer(2, Histogram_Color, INDICATOR_COLOR_INDEX);
    SetIndexBuffer(3, marsioma, INDICATOR_DATA);
    SetIndexBuffer(4, PosBuffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(5, NegBuffer, INDICATOR_CALCULATIONS);

    PlotIndexGetInteger(0, PLOT_DRAW_BEGIN, RSIOMA);
    PlotIndexGetInteger(1, PLOT_DRAW_BEGIN, RSIOMA);
    PlotIndexGetInteger(2, PLOT_DRAW_BEGIN, RSIOMA);

    short_name = "RSIOMA(" + IntegerToString(RSIOMA) + ")";
    IndicatorSetString(INDICATOR_SHORTNAME, short_name);
    IndicatorSetInteger(INDICATOR_DIGITS, 2);

    drawLine(MainTrendLong, "MainTrendLong", MainTrendLongColor);
    drawLine(MainTrendShort, "MainTrendShort", MainTrendShortColor);
    drawLine(BuyTrigger, "BuyTrigger", BuyTriggerColor);
    drawLine(SellTrigger, "SellTrigger", SellTriggerColor );
    
    MA_Handle = iMA(Symbol(), Period(), RSIOMA, 0, RSIOMA_MODE, RSIOMA_PRICE);
    
    ArraySetAsSeries(RSIBuffer, true);
    ArraySetAsSeries(Histogram, true);
    ArraySetAsSeries(Histogram_Color, true);
    ArraySetAsSeries(marsioma, true);
    ArraySetAsSeries(PosBuffer, true);
    ArraySetAsSeries(NegBuffer, true);
    ArraySetAsSeries(MA_Buffer, true);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    int    i, counted_bars = prev_calculated;

    if (rates_total <= RSIOMA) return 0;
    
    if (counted_bars < 1)
        for (i = 1; i <= RSIOMA; i++) RSIBuffer[rates_total - i] = 0.0;

    i = rates_total - RSIOMA - 1;
    int ma = i;
    if (counted_bars >= RSIOMA) i = rates_total - (counted_bars - 1);

    if (i == rates_total - RSIOMA - 1)
    {
        if (CopyBuffer(MA_Handle, 0, 0, rates_total, MA_Buffer) != rates_total) return 0; // Indicator data not ready yet.
    }
    else
    {
        // "+ 2" to accommodate further calculations.
        if (CopyBuffer(MA_Handle, 0, 0, i + 2, MA_Buffer) != i + 2) return 0; // Indicator data not ready yet.
    }
   
    ArraySetAsSeries(Time, true);
    
    while (i >= 0)
    {
        double sumn = 0.0, sump = 0.0;
        double rel, negative, positive;
        if (i == rates_total - RSIOMA - 1)
        {
            int k = rates_total - 2;
            // Initial accumulation.
            while (k >= i)
            {
                double cma = MA_Buffer[k];
                double pma = MA_Buffer[k + 1];

                rel = cma - pma;

                if (rel > 0) sump += rel;
                else         sumn -= rel;
                k--;
            }
            positive = sump / RSIOMA;
            negative = sumn / RSIOMA;
        }
        else
        {
            // Smoothed moving average.
            double ccma = MA_Buffer[i];
            double ppma = MA_Buffer[i + 1];

            rel = ccma - ppma;

            if (rel > 0) sump = rel;
            else         sumn = -rel;
            positive = (PosBuffer[i + 1] * (RSIOMA - 1) + sump) / RSIOMA;
            negative = (NegBuffer[i + 1] * (RSIOMA - 1) + sumn) / RSIOMA;
        }
        PosBuffer[i] = positive;
        NegBuffer[i] = negative;
        if (negative == 0.0) RSIBuffer[i] = 0.0;
        else
        {
            RSIBuffer[i] = 100.0 - 100.0 / (1 + positive / negative);

            if (RSIBuffer[i] > MainTrendLong)
            {
                Histogram[i] = -10;
                Histogram_Color[i] = 1;
            }
            if (RSIBuffer[i] < MainTrendShort)
            {
                Histogram[i] = -10;
                Histogram_Color[i] = 0;
            }
            if ((RSIBuffer[i] < BuyTrigger) && (RSIBuffer[i] > RSIBuffer[i + 1]))
            {
                Histogram[i] = -10;
                Histogram_Color[i] = 3;
            }
            if ((RSIBuffer[i] > SellTrigger) && (RSIBuffer[i] < RSIBuffer[i + 1]))
            {
                Histogram[i] = -10;
                Histogram_Color[i] = 2;
            }
        }
        i--;
    }
    iMAOnArray(RSIBuffer, Ma_RSIOMA, Ma_RSIOMA_MODE); // Calculates iMAOnArray and puts the result into marsioma[].

    // Alerts
    if (((TriggerCandle > 0) && (Time[0] > LastAlertTime)) || (TriggerCandle == 0))
    {
        string Text;
        if (MainAlerts) // RSIOMA line crosses 80 or 20 lines from above or below.
        {
            // Main Sell signal.
            if ((RSIBuffer[TriggerCandle] < SellTrigger) && (RSIBuffer[TriggerCandle + 1] >= SellTrigger))
            {
                Text = "RSIOMA: " + Symbol() + " - " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)Period()), 7) + " - Crossed " + IntegerToString(SellTrigger) + " from above.";
                if (EnableNativeAlerts) Alert(Text);
                if (EnableEmailAlerts) SendMail("RSIOMA Alert", Text);
                if (EnablePushAlerts) SendNotification(Text);
                LastAlertTime = Time[0];
            }
            // Main Buy signal.
            if ((RSIBuffer[TriggerCandle] > BuyTrigger) && (RSIBuffer[TriggerCandle + 1] <= BuyTrigger))
            {
                Text = "RSIOMA: " + Symbol() + " - " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)Period()), 7) + " - Crossed " + IntegerToString(BuyTrigger) + " from below.";
                if (EnableNativeAlerts) Alert(Text);
                if (EnableEmailAlerts) SendMail("RSIOMA Alert", Text);
                if (EnablePushAlerts) SendNotification(Text);
                LastAlertTime = Time[0];
            }
        }
        if (AuxiliaryAlerts) // Histogram shows blue or pink color - reversal of RSIOMA below 20 or above 80 - trend change imminent.
        {
            // Auxiliary Sell signal.
            if ((Histogram_Color[TriggerCandle] == 2) && (Histogram_Color[TriggerCandle + 1] != 2))
            {
                Text = "RSIOMA: " + Symbol() + " - " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)Period()), 7) + " - Bearish reversal imminent.";
                if (EnableNativeAlerts) Alert(Text);
                if (EnableEmailAlerts) SendMail("RSIOMA Alert", Text);
                if (EnablePushAlerts) SendNotification(Text);
                LastAlertTime = Time[0];
            }
            // Auxiliary Buy signal.
            if ((Histogram_Color[TriggerCandle] == 3) && (Histogram_Color[TriggerCandle + 1] != 3))
            {
                Text = "RSIOMA: " + Symbol() + " - " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)Period()), 7) + " - Bullish reversal imminent.";
                if (EnableNativeAlerts) Alert(Text);
                if (EnableEmailAlerts) SendMail("RSIOMA Alert", Text);
                if (EnablePushAlerts) SendNotification(Text);
                LastAlertTime = Time[0];
            }
        }
    }

    return rates_total;
}

void drawLine(const double lvl, const string name, const color Col)
{
    ObjectDelete(ChartID(), name);
    ObjectCreate(ChartID(), name, OBJ_HLINE, ChartWindowFind(ChartID(), short_name), 0, lvl, 0, lvl);
    ObjectSetInteger(ChartID(), name, OBJPROP_STYLE, STYLE_DOT);
    ObjectSetInteger(ChartID(), name, OBJPROP_COLOR, Col);
    ObjectSetInteger(ChartID(), name, OBJPROP_WIDTH, 1);
    ObjectSetInteger(ChartID(), name, OBJPROP_SELECTABLE, false);
}

// Run once to calculate and populate the entire buffer.
double iMAOnArray(double& array[], const int period, const ENUM_MA_METHOD ma_method)
{
    int total = ArraySize(array);
    if (total <= period) return 0;
    switch(ma_method)
    {
    case MODE_SMA:
    {
        double sum = 0;
        int pos = total - 1;
        for (int i = 1; i < period; i++, pos--)
            sum += array[pos];
        while (pos >= 0)
        {
            sum += array[pos];
            marsioma[pos] = sum / period;
            sum -= array[pos + period - 1];
            pos--;
        }
        break;
    }
    case MODE_EMA:
    {
        double pr = 2.0 / (period + 1);
        int pos = total - 2;
        while (pos >= 0)
        {
            if (pos == total - 2)
                marsioma[pos + 1] = array[pos + 1];
            marsioma[pos] = array[pos] * pr + marsioma[pos + 1] * (1 - pr);
            pos--;
        }
        break;
    }
    case MODE_SMMA:
    {
        double sum = 0;
        int pos = total - period;
        while (pos >= 0)
        {
            if (pos == total - period)
            {
                for (int i = 0, k = pos; i < period; i++, k++)
                {
                    sum += array[k];
                    marsioma[k] = 0;
                }
            }
            else
                sum = marsioma[pos + 1] * (period - 1) + array[pos];
            marsioma[pos] = sum / period;
            pos--;
        }
        break;
    }
    case MODE_LWMA:
    {
        double sum = 0.0, lsum = 0.0;
        double price;
        int i, weight = 0, pos = total - 1;
        for (i = 1; i <= period; i++, pos--)
        {
            price = array[pos];
            sum += price * i;
            lsum += price;
            weight += i;
        }
        pos++;
        i = pos + period;
        while (pos >= 0)
        {
            marsioma[pos] = sum / weight;
            if (pos == 0)
                break;
            pos--;
            i--;
            price = array[pos];
            sum = sum - lsum + price * period;
            lsum -= array[i];
            lsum += price;
        }
        break;
    }
    }
    return 0;
}
//+------------------------------------------------------------------+