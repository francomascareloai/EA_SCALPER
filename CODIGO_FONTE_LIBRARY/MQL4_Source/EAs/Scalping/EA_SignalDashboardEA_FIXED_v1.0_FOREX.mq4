
// === EA Signal Dashboard dengan Panel, Tombol, Arrows, SL/TP, MultiTF ===
#property strict
#include <ChartObjects\ChartObjectsTxtControls.mqh>

input double LotSize = 0.01;
input int Slippage = 3;
input double TakeProfit = 50;
input double StopLoss = 30;
input bool EnableAutoTrade = true;
input bool ShowVisualTP_SL = true;
input bool ShowSignalArrow = true;

input string Symbols = "XAUUSD,EURUSD,GBPUSD,USDJPY";
input string Timeframes = "M5,M15,M30,H1,H4";
input int DashboardX = 400;
input int DashboardY = 20;

double bb_middle, sar_value, ema_current, ema_previous, macd_current, macd_signal;
bool hasTrade = false;

int OnInit() {
    CreatePanel();
    CreateButtons();
    CreateDashboard();
    EventSetTimer(10);
    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
    EventKillTimer();
}

void OnTimer() {
    UpdateDashboard();
}

void OnTick() {
    if (Symbol() != "XAUUSD" || Period() != PERIOD_M1) return;
    GetIndicatorValues();
    if (CheckBuySignal()) {
        Alert("XAUUSD.sSignal UP :: SAR + EMA + BB");
        if (EnableAutoTrade && !hasTrade) OpenBuyOrder();
        if (ShowSignalArrow) DrawBuyArrow();
    }
    CheckButtonClick();
    UpdatePanel();
}

void GetIndicatorValues() {
    bb_middle = iBands(NULL, 0, 20, 2.5, 0, PRICE_CLOSE, MODE_MAIN, 0);
    sar_value = iSAR(NULL, 0, 0.02, 0.2, 0);
    ema_current = iMA(NULL, 0, 14, 0, MODE_EMA, PRICE_CLOSE, 0);
    ema_previous = iMA(NULL, 0, 14, 0, MODE_EMA, PRICE_CLOSE, 1);
    macd_current = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
    macd_signal = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
}

bool CheckBuySignal() {
    return (sar_value < Close[0]) && (ema_current > ema_previous) &&
           (Close[0] > bb_middle) && (macd_current > macd_signal);
}

void OpenBuyOrder() {
    double sl = Bid - StopLoss * Point;
    double tp = Bid + TakeProfit * Point;
    int ticket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, Slippage, sl, tp, "AutoBuy", 0, 0, clrBlue);
    if (ticket > 0) {
        hasTrade = true;
        if (ShowVisualTP_SL) DrawSLTPLevels(tp, sl);
    } else Print("OrderSend failed: ", GetLastError());
}

void CreatePanel() {
    string base = "SignalPanel";
    ObjectCreate(0, base, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, base, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, base, OBJPROP_XDISTANCE, 10);
    ObjectSetInteger(0, base, OBJPROP_YDISTANCE, 20);
    ObjectSetInteger(0, base, OBJPROP_FONTSIZE, 10);
    ObjectSetString(0, base, OBJPROP_TEXT, "Loading signal panel...");
    ObjectSetInteger(0, base, OBJPROP_COLOR, clrLime);

    string tf[] = {"M5", "M15", "M30", "H1", "H4"};
    for (int i = 0; i < ArraySize(tf); i++) {
        string label = "MTF_" + tf[i];
        ObjectCreate(0, label, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, label, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, label, OBJPROP_XDISTANCE, 150);
        ObjectSetInteger(0, label, OBJPROP_YDISTANCE, 40 + (i * 15));
        ObjectSetInteger(0, label, OBJPROP_FONTSIZE, 10);
        ObjectSetString(0, label, OBJPROP_TEXT, tf[i] + ": CHECK");
        ObjectSetInteger(0, label, OBJPROP_COLOR, clrWhite);
    }
}

void UpdatePanel() {
    string text = "SAR: " + DoubleToString(sar_value, 2) +
                  " | EMA: " + DoubleToString(ema_current, 2) +
                  " | BB Mid: " + DoubleToString(bb_middle, 2) +
                  " | MACD: " + DoubleToString(macd_current, 2);
    ObjectSetString(0, "SignalPanel", OBJPROP_TEXT, text);
}

void CreateButtons() {
    string btns[] = {"HISTORY", "TrendLine", "RECTANGLE"};
    for (int i = 0; i < ArraySize(btns); i++) {
        string bname = "btn_" + btns[i];
        ObjectCreate(0, bname, OBJ_BUTTON, 0, 0, 0);
        ObjectSetInteger(0, bname, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, bname, OBJPROP_XDISTANCE, 10);
        ObjectSetInteger(0, bname, OBJPROP_YDISTANCE, 100 + (i * 20));
        ObjectSetInteger(0, bname, OBJPROP_FONTSIZE, 10);
        ObjectSetString(0, bname, OBJPROP_TEXT, btns[i]);
        ObjectSetInteger(0, bname, OBJPROP_COLOR, clrGreen);
    }
}

void CheckButtonClick() {
    if (ObjectGetInteger(0, "btn_HISTORY", OBJPROP_STATE)) {
        Print("HISTORY button clicked");
        ObjectSetInteger(0, "btn_HISTORY", OBJPROP_STATE, false);
        ShowLastOrders();
    }
    if (ObjectGetInteger(0, "btn_TrendLine", OBJPROP_STATE)) {
        Print("TrendLine button clicked");
        ObjectSetInteger(0, "btn_TrendLine", OBJPROP_STATE, false);
        DrawAutoTrendline();
    }
    if (ObjectGetInteger(0, "btn_RECTANGLE", OBJPROP_STATE)) {
        Print("RECTANGLE button clicked");
        ObjectSetInteger(0, "btn_RECTANGLE", OBJPROP_STATE, false);
        DrawRectangle();
    }
}

void ShowLastOrders() {
    for (int i = OrdersHistoryTotal() - 1; i >= 0 && i > OrdersHistoryTotal() - 6; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
            Print("[HISTORY] ", OrderType(), " | Lot: ", OrderLots(), " | Price: ", OrderOpenPrice());
        }
    }
}

void DrawAutoTrendline() {
    if (Bars < 10) return;
    double p1 = Low[iLowest(NULL, 0, MODE_LOW, 10, 1)];
    double p2 = Low[1];
    ObjectCreate(0, "auto_trend", OBJ_TREND, 0, Time[10], p1, Time[1], p2);
    ObjectSetInteger(0, "auto_trend", OBJPROP_COLOR, clrYellow);
}

void DrawRectangle() {
    datetime t1 = Time[20];
    datetime t2 = Time[1];
    double h = High[iHighest(NULL, 0, MODE_HIGH, 20, 1)];
    double l = Low[iLowest(NULL, 0, MODE_LOW, 20, 1)];
    ObjectCreate(0, "zone_box", OBJ_RECTANGLE, 0, t1, h, t2, l);
    ObjectSetInteger(0, "zone_box", OBJPROP_COLOR, clrRed);
    ObjectSetInteger(0, "zone_box", OBJPROP_STYLE, STYLE_DASH);
}

void DrawSLTPLevels(double tp, double sl) {
    ObjectCreate(0, "TP_LINE", OBJ_HLINE, 0, 0, tp);
    ObjectSetInteger(0, "TP_LINE", OBJPROP_COLOR, clrGreen);
    ObjectCreate(0, "SL_LINE", OBJ_HLINE, 0, 0, sl);
    ObjectSetInteger(0, "SL_LINE", OBJPROP_COLOR, clrRed);
}

void DrawBuyArrow() {
    string arrowName = "buy_arrow_" + TimeToString(TimeCurrent(), TIME_SECONDS);
    ObjectCreate(0, arrowName, OBJ_ARROW, 0, Time[0], Low[0] - 10 * Point);
    ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
    ObjectSetInteger(0, arrowName, OBJPROP_COLOR, clrLimeGreen);
    ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 2);
}

ENUM_TIMEFRAMES TFTextToEnum(string tf) {
    if (tf == "M1") return PERIOD_M1;
    if (tf == "M5") return PERIOD_M5;
    if (tf == "M15") return PERIOD_M15;
    if (tf == "M30") return PERIOD_M30;
    if (tf == "H1") return PERIOD_H1;
    if (tf == "H4") return PERIOD_H4;
    if (tf == "D1") return PERIOD_D1;
    return PERIOD_M1;
}

string GetSignalStatus(string sym, ENUM_TIMEFRAMES tf) {
    double bb = iBands(sym, tf, 20, 2.5, 0, PRICE_CLOSE, MODE_MAIN, 0);
    double sar = iSAR(sym, tf, 0.02, 0.2, 0);
    double ema0 = iMA(sym, tf, 14, 0, MODE_EMA, PRICE_CLOSE, 0);
    double ema1 = iMA(sym, tf, 14, 0, MODE_EMA, PRICE_CLOSE, 1);
    double macd = iMACD(sym, tf, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
    double macd_signal = iMACD(sym, tf, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
    double price = iClose(sym, tf, 0);

    if ((sar < price) && (ema0 > ema1) && (price > bb) && (macd > macd_signal)) return "BUY";
    if ((sar > price) && (ema0 < ema1) && (price < bb) && (macd < macd_signal)) return "SELL";
    return "WAIT";
}


ENUM_TIMEFRAMES TFTextToEnum(string tf) {
    if(tf == "M1") return PERIOD_M1;
    if(tf == "M5") return PERIOD_M5;
    if(tf == "M15") return PERIOD_M15;
    if(tf == "M30") return PERIOD_M30;
    if(tf == "H1") return PERIOD_H1;
    if(tf == "H4") return PERIOD_H4;
    if(tf == "D1") return PERIOD_D1;
    return PERIOD_CURRENT;
}


void CreatePanel() {}
void CreateButtons() {}
void CreateDashboard() {}
void UpdateDashboard() {}
void GetIndicatorValues() {
    // Dummy values
    bb_middle = iBands(Symbol(), 0, 20, 2, 0, PRICE_CLOSE, MODE_MAIN, 0);
    sar_value = iSAR(Symbol(), 0, 0.02, 0.2, 0);
    ema_current = iMA(Symbol(), 0, 10, 0, MODE_EMA, PRICE_CLOSE, 0);
    ema_previous = iMA(Symbol(), 0, 10, 0, MODE_EMA, PRICE_CLOSE, 1);
    macd_current = iMACD(Symbol(), 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
    macd_signal = iMACD(Symbol(), 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
}
bool CheckBuySignal() {
    return (ema_current > ema_previous && macd_current > macd_signal);
}
bool CheckSellSignal() {
    return (ema_current < ema_previous && macd_current < macd_signal);
}
