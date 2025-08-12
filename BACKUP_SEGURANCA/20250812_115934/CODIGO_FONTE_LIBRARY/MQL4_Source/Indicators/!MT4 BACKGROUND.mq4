//+------------------------------------------------------------------+
//|                                                      !MT4 BACKGROUND.mq4 |
//|               Minimal placeholder indicator - does nothing       |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 clrNONE

double DummyBuffer[]; // Unused buffer to satisfy MT4 requirement

int OnInit()
{
   // Bind buffer to index 0
   SetIndexBuffer(0, DummyBuffer);
   // Initialization complete - nothing to initialize
   return(INIT_SUCCEEDED);
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
   // Do absolutely nothing
   return(rates_total);
}