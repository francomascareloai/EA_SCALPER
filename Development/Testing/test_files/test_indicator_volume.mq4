
//+------------------------------------------------------------------+
//| Test Volume Indicator                                            |
//+------------------------------------------------------------------+
#property copyright "Test"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1

double VolumeBuffer[];

int OnInit()
{
    SetIndexBuffer(0, VolumeBuffer);
    SetIndexStyle(0, DRAW_HISTOGRAM);
    return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &volume[])
{
    for(int i = prev_calculated; i < rates_total; i++)
    {
        VolumeBuffer[i] = volume[i];
    }
    return(rates_total);
}
