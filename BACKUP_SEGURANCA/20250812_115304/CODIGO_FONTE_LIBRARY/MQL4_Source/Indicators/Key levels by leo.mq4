//+------------------------------------------------------------------+
//|                                              KeyLevelsByLeo.mq4  |
//|                                      Translated from Pine Script |
//+------------------------------------------------------------------+
#property indicator_chart_window

//--- input parameters
input int desplazamiento_barras = 50; // Bar displacement

double high_primera_vela = 0;  // High of the first candle of the day
double low_primera_vela = 0;   // Low of the first candle of the day
double promedio_primera_vela = 0;      // Average of high and low
double promedio_mas_ajuste = 0;        // Upper adjustment level
double promedio_menos_ajuste = 0;      // Lower adjustment level
double bl1, bh1, bl2, bh2, bl3, bh3, bl4, bh4, bl5, bh5, bl6, bh6; // Buy Low/High levels
double sh1, sl1, sh2, sl2, sh3, sl3, sh4, sl4, sh5, sl5, sh6, sl6; // Sell Low/High levels

datetime last_daily_candle = 0; // Time of the last daily candle

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
   // No buffers needed, only drawing lines on the chart
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {

    // Check if we have a new day by comparing the current daily candle time
    datetime current_daily_time = iTime(NULL, PERIOD_D1, 0);
    if (current_daily_time != last_daily_candle) {
        // Store the new daily candle time
        last_daily_candle = current_daily_time;

        // Set the high and low of the first M15 candle of the new day
        high_primera_vela = high[0];
        low_primera_vela = low[0];
        
        // Reset the daily levels calculation
        CalculateDailyLevels();
    }
    
    // Plot the levels on the chart
    PlotAllLevels();
    
    return(rates_total);
}

//+------------------------------------------------------------------+
//| Calculate daily levels based on the first M15 candle             |
//+------------------------------------------------------------------+
void CalculateDailyLevels() {
    if (high_primera_vela != 0 && low_primera_vela != 0) {
        // Calculate the midpoint of the first M15 candle
        promedio_primera_vela = (high_primera_vela + low_primera_vela) / 2;
        promedio_mas_ajuste = promedio_primera_vela + 0.864;
        promedio_menos_ajuste = promedio_primera_vela - 0.864;

        // Calculate Buy Low and Buy High levels
        bl1 = promedio_mas_ajuste + 4.331;
        bh1 = bl1 + 1.737;
        bl2 = bh1 + 4.352;
        bh2 = bl2 + 1.745;
        bl3 = bh2 + 4.374;
        bh3 = bl3 + 1.754;
        bl4 = bh3 + 4.395;
        bh4 = bl4 + 1.762;
        bl5 = bh4 + 4.417;
        bh5 = bl5 + 1.771;
        bl6 = bh5 + 4.438;
        bh6 = bl6 + 1.779;

        // Calculate Sell High and Sell Low levels
        sh1 = promedio_menos_ajuste - 4.313;
        sl1 = sh1 - 1.721;
        sh2 = sl1 - 4.291;
        sl2 = sh2 - 1.713;
        sh3 = sl2 - 4.270;
        sl3 = sh3 - 1.704;
        sh4 = sl3 - 4.248;
        sl4 = sh4 - 1.696;
        sh5 = sl4 - 4.227;
        sl5 = sh5 - 1.687;
        sh6 = sl5 - 4.205;
        sl6 = sh6 - 1.679;
    }
}

//+------------------------------------------------------------------+
//| Plot all calculated levels                                       |
//+------------------------------------------------------------------+
void PlotAllLevels() {
    PlotLevel(promedio_mas_ajuste, clrGreen, "Promedio_Mas");
    PlotLevel(promedio_menos_ajuste, clrRed, "Promedio_Menos");
    
    PlotLevel(bl1, clrRed, "BL1"); PlotLevel(bh1, clrGreen, "BH1");
    PlotLevel(bl2, clrRed, "BL2"); PlotLevel(bh2, clrGreen, "BH2");
    PlotLevel(bl3, clrRed, "BL3"); PlotLevel(bh3, clrGreen, "BH3");
    PlotLevel(bl4, clrRed, "BL4"); PlotLevel(bh4, clrGreen, "BH4");
    PlotLevel(bl5, clrRed, "BL5"); PlotLevel(bh5, clrGreen, "BH5");
    PlotLevel(bl6, clrRed, "BL6"); PlotLevel(bh6, clrGreen, "BH6");
    
    PlotLevel(sh1, clrGreen, "SH1"); PlotLevel(sl1, clrRed, "SL1");
    PlotLevel(sh2, clrGreen, "SH2"); PlotLevel(sl2, clrRed, "SL2");
    PlotLevel(sh3, clrGreen, "SH3"); PlotLevel(sl3, clrRed, "SL3");
    PlotLevel(sh4, clrGreen, "SH4"); PlotLevel(sl4, clrRed, "SL4");
    PlotLevel(sh5, clrGreen, "SH5"); PlotLevel(sl5, clrRed, "SL5");
    PlotLevel(sh6, clrGreen, "SH6"); PlotLevel(sl6, clrRed, "SL6");
}

//+------------------------------------------------------------------+
//| Function to plot horizontal levels                               |
//+------------------------------------------------------------------+
void PlotLevel(double level, color lineColor, string levelName) {
    // Check if the object already exists
    if (ObjectFind(0, levelName) == -1) {
        ObjectCreate(0, levelName, OBJ_HLINE, 0, Time[0], level);   // Create horizontal line
        ObjectSetInteger(0, levelName, OBJPROP_COLOR, lineColor);   // Set color
        ObjectSetInteger(0, levelName, OBJPROP_WIDTH, 2);           // Set line width
        ObjectSetInteger(0, levelName, OBJPROP_RAY, true);          // Extend line indefinitely
    } else {
        ObjectSetDouble(0, levelName, OBJPROP_PRICE1, level);  // Update level position
    }
}
