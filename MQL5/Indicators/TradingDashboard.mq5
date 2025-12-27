//+------------------------------------------------------------------+
//|                                              TradingDashboard.mq5 |
//|                         FORGE v4.0 - Full-Screen Trading Dashboard|
//|                     Apex Risk Monitor + Trade Statistics         |
//+------------------------------------------------------------------+
#property copyright "FORGE v4.0 - EA_SCALPER_XAUUSD"
#property link      "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property description "Full-Screen Trading Dashboard for Investor Demos"
#property description "Features: Account Info, Risk Monitor, Time Gates, Trade Statistics"
#property description "Professional dark theme, smooth updates, Arabic-friendly"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//+------------------------------------------------------------------+
//| Input Parameters                                                  |
//+------------------------------------------------------------------+
input group "=== DISPLAY SETTINGS ==="
input bool     InpShowDashboard    = true;           // Show Dashboard
input int      InpCorner           = 1;              // Corner (0=TL, 1=TR, 2=BL, 3=BR)
input int      InpOffsetX          = 10;             // X Offset from corner
input int      InpOffsetY          = 30;             // Y Offset from corner
input bool     InpCompactMode      = false;          // Compact Mode (smaller)

input group "=== DEMO MODE ==="
input bool     InpDemoMode         = false;          // Demo Mode (for presentations)
input int      InpDemoSpeed        = 800;            // Demo Animation Speed (ms)

input group "=== COLOR THEME ==="
input color    InpBgColor          = C'20,22,28';    // Background Color
input color    InpBorderColor      = C'45,50,60';    // Border Color
input color    InpTextColor        = clrWhite;       // Primary Text Color
input color    InpLabelColor       = clrSilver;      // Label Color
input color    InpAccentColor      = C'0,150,255';   // Accent Color (blue)

//+------------------------------------------------------------------+
//| Dashboard Constants                                               |
//+------------------------------------------------------------------+
#define DASH_WIDTH         380
#define DASH_HEIGHT        520
#define DASH_COMPACT_W     280
#define DASH_COMPACT_H     360
#define DASH_PADDING       12
#define DASH_SECTION_GAP   8
#define DASH_ROW_HEIGHT    20

//--- Thermometer dimensions
#define THERMO_WIDTH       280
#define THERMO_HEIGHT      20
#define THERMO_COMPACT_W   180

//--- Gate icon dimensions
#define GATE_SIZE          28
#define GATE_SPACING       6

//--- Colors for risk states
#define CLR_SAFE           clrLimeGreen
#define CLR_WARN           clrYellow
#define CLR_CAUTION        clrOrange
#define CLR_CRITICAL       clrOrangeRed
#define CLR_HALT           clrRed
#define CLR_PROFIT         clrLimeGreen
#define CLR_LOSS           clrRed
#define CLR_NEUTRAL        clrGray

//+------------------------------------------------------------------+
//| Demo State Structure                                              |
//+------------------------------------------------------------------+
struct SDashDemoState
{
    // Account
    double equity;
    double balance;
    double margin;
    double hwm;
    double session_start;
    double daily_pnl;

    // Risk
    double trailing_dd_pct;
    double daily_dd_pct;
    double dd_direction;
    double size_factor;
    bool   gates[6];  // Time, DD, Spread, Virtual, Gap, Session

    // Time
    int    time_state;  // 0=Normal, 1=Block, 2=Emergency, 3=Halted
    int    minutes_to_block;
    int    minutes_to_close;

    // Trades
    int    open_positions;
    int    today_trades;
    int    today_wins;
    double today_winrate;

    // Animation
    int    cycle_counter;
    uint   last_update;
};

//+------------------------------------------------------------------+
//| Global Variables                                                  |
//+------------------------------------------------------------------+
string g_prefix = "DASH_";
SDashDemoState g_demo;
int g_width;
int g_height;
int g_thermo_width;

//+------------------------------------------------------------------+
//| Custom indicator initialization                                    |
//+------------------------------------------------------------------+
int OnInit()
{
    // Set dimensions based on mode
    if(InpCompactMode)
    {
        g_width = DASH_COMPACT_W;
        g_height = DASH_COMPACT_H;
        g_thermo_width = THERMO_COMPACT_W;
    }
    else
    {
        g_width = DASH_WIDTH;
        g_height = DASH_HEIGHT;
        g_thermo_width = THERMO_WIDTH;
    }

    // Initialize demo state
    InitDemoState();

    // Delete any existing objects
    DeleteDashboard();

    // Create dashboard
    if(InpShowDashboard)
        CreateDashboard();

    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    DeleteDashboard();
}

//+------------------------------------------------------------------+
//| Initialize Demo State                                             |
//+------------------------------------------------------------------+
void InitDemoState()
{
    // Account
    g_demo.equity = 52500.00;
    g_demo.balance = 52000.00;
    g_demo.margin = 1250.00;
    g_demo.hwm = 53200.00;
    g_demo.session_start = 51000.00;
    g_demo.daily_pnl = 1500.00;

    // Risk
    g_demo.trailing_dd_pct = 1.32;
    g_demo.daily_dd_pct = 0.0;
    g_demo.dd_direction = 0.05;
    g_demo.size_factor = 1.0;
    for(int i = 0; i < 6; i++)
        g_demo.gates[i] = true;

    // Time
    g_demo.time_state = 0;
    g_demo.minutes_to_block = 245;
    g_demo.minutes_to_close = 274;

    // Trades
    g_demo.open_positions = 1;
    g_demo.today_trades = 7;
    g_demo.today_wins = 5;
    g_demo.today_winrate = 71.4;

    // Animation
    g_demo.cycle_counter = 0;
    g_demo.last_update = 0;
}

//+------------------------------------------------------------------+
//| Update Demo State with animations                                 |
//+------------------------------------------------------------------+
void UpdateDemoState()
{
    if(!InpDemoMode) return;

    uint now = GetTickCount();
    if(now - g_demo.last_update < (uint)InpDemoSpeed)
        return;

    g_demo.last_update = now;
    g_demo.cycle_counter++;

    // Animate DD (oscillate)
    g_demo.trailing_dd_pct += g_demo.dd_direction;
    if(g_demo.trailing_dd_pct >= 4.2)
    {
        g_demo.trailing_dd_pct = 4.2;
        g_demo.dd_direction = -0.08;
    }
    else if(g_demo.trailing_dd_pct <= 0.5)
    {
        g_demo.trailing_dd_pct = 0.5;
        g_demo.dd_direction = 0.08;
    }

    // Animate equity/PnL
    double pnl_change = MathSin(g_demo.cycle_counter * 0.15) * 50;
    g_demo.equity = 52500 + pnl_change;
    g_demo.daily_pnl = g_demo.equity - g_demo.session_start;

    // Update HWM if equity exceeds it
    if(g_demo.equity > g_demo.hwm)
        g_demo.hwm = g_demo.equity;

    // Calculate DD from HWM
    g_demo.trailing_dd_pct = (g_demo.hwm - g_demo.equity) / g_demo.hwm * 100.0;

    // Size factor based on DD
    if(g_demo.trailing_dd_pct >= 4.0)
        g_demo.size_factor = 0.0;
    else if(g_demo.trailing_dd_pct >= 3.5)
        g_demo.size_factor = 0.25;
    else if(g_demo.trailing_dd_pct >= 3.0)
        g_demo.size_factor = 0.5;
    else
        g_demo.size_factor = 1.0;

    // Cycle time states every 25 cycles
    if(g_demo.cycle_counter % 25 == 0)
    {
        g_demo.time_state = (g_demo.time_state + 1) % 4;
    }

    // Countdown simulation
    g_demo.minutes_to_block = 245 - (g_demo.cycle_counter % 245);
    g_demo.minutes_to_close = g_demo.minutes_to_block + 29;

    // Toggle gates every 20 cycles
    if(g_demo.cycle_counter % 20 == 0)
    {
        int gate_idx = (g_demo.cycle_counter / 20) % 6;
        g_demo.gates[gate_idx] = !g_demo.gates[gate_idx];
    }

    // Simulate trades
    if(g_demo.cycle_counter % 30 == 0)
    {
        g_demo.today_trades++;
        if(MathRand() % 100 < 70)  // 70% win rate
            g_demo.today_wins++;
        g_demo.today_winrate = g_demo.today_trades > 0 ?
            (double)g_demo.today_wins / g_demo.today_trades * 100.0 : 0;
    }

    // Toggle open positions
    if(g_demo.cycle_counter % 15 == 0)
    {
        g_demo.open_positions = (g_demo.cycle_counter % 45 == 0) ? 2 :
                               (g_demo.cycle_counter % 30 == 0) ? 0 : 1;
    }
}

//+------------------------------------------------------------------+
//| Delete Dashboard objects                                          |
//+------------------------------------------------------------------+
void DeleteDashboard()
{
    ObjectsDeleteAll(0, g_prefix);
}

//+------------------------------------------------------------------+
//| Get Dashboard Position                                            |
//+------------------------------------------------------------------+
void GetDashPosition(int &x, int &y)
{
    int chart_w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
    int chart_h = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

    switch(InpCorner)
    {
        case 0:  // Top Left
            x = InpOffsetX;
            y = InpOffsetY;
            break;
        case 1:  // Top Right
            x = chart_w - g_width - InpOffsetX;
            y = InpOffsetY;
            break;
        case 2:  // Bottom Left
            x = InpOffsetX;
            y = chart_h - g_height - InpOffsetY;
            break;
        case 3:  // Bottom Right
            x = chart_w - g_width - InpOffsetX;
            y = chart_h - g_height - InpOffsetY;
            break;
        default:
            x = InpOffsetX;
            y = InpOffsetY;
    }
}

//+------------------------------------------------------------------+
//| Create Dashboard                                                  |
//+------------------------------------------------------------------+
void CreateDashboard()
{
    int x, y;
    GetDashPosition(x, y);

    int curr_y = y;

    // === MAIN BACKGROUND ===
    CreateRect("MainBG", x, y, g_width, g_height, InpBgColor, InpBorderColor);

    // === HEADER ===
    curr_y += DASH_PADDING;
    CreateLabel("Title", x + DASH_PADDING, curr_y, "APEX TRADING DASHBOARD", InpTextColor, 11, true);

    if(InpDemoMode)
        CreateLabel("DemoTag", x + g_width - 60, curr_y, "[DEMO]", clrMagenta, 9, false);

    curr_y += 18;
    CreateRect("HeaderSep", x + DASH_PADDING, curr_y, g_width - 2*DASH_PADDING, 2, InpAccentColor, InpAccentColor);
    curr_y += DASH_SECTION_GAP;

    // === ACCOUNT SECTION ===
    curr_y += 4;
    CreateLabel("AccHeader", x + DASH_PADDING, curr_y, "ACCOUNT", InpAccentColor, 9, true);
    curr_y += 16;

    int col1 = x + DASH_PADDING;
    int col2 = x + DASH_PADDING + 80;
    int col3 = x + DASH_PADDING + 190;
    int col4 = x + DASH_PADDING + 270;

    // Row 1: Equity, Balance
    CreateLabel("EquityLbl", col1, curr_y, "Equity:", InpLabelColor, 8, false);
    CreateLabel("EquityVal", col2, curr_y, "$0.00", CLR_SAFE, 9, false);
    CreateLabel("BalanceLbl", col3, curr_y, "Balance:", InpLabelColor, 8, false);
    CreateLabel("BalanceVal", col4, curr_y, "$0.00", InpTextColor, 9, false);
    curr_y += DASH_ROW_HEIGHT;

    // Row 2: HWM, Margin
    CreateLabel("HWMLbl", col1, curr_y, "HWM:", InpLabelColor, 8, false);
    CreateLabel("HWMVal", col2, curr_y, "$0.00", clrGold, 9, false);
    CreateLabel("MarginLbl", col3, curr_y, "Margin:", InpLabelColor, 8, false);
    CreateLabel("MarginVal", col4, curr_y, "$0.00", InpTextColor, 9, false);
    curr_y += DASH_ROW_HEIGHT;

    // Row 3: Daily P/L (centered, prominent)
    CreateLabel("PnLLbl", col1, curr_y, "Daily P/L:", InpLabelColor, 8, false);
    CreateLabel("PnLVal", col2, curr_y, "+$0.00", CLR_PROFIT, 10, true);
    curr_y += DASH_ROW_HEIGHT + 4;

    // Separator
    CreateRect("AccSep", x + DASH_PADDING, curr_y, g_width - 2*DASH_PADDING, 1, InpBorderColor, InpBorderColor);
    curr_y += DASH_SECTION_GAP;

    // === RISK SECTION ===
    CreateLabel("RiskHeader", x + DASH_PADDING, curr_y, "RISK MONITOR", InpAccentColor, 9, true);
    curr_y += 18;

    // DD Thermometer (Large)
    CreateLabel("DDLbl", col1, curr_y, "Trailing DD:", InpLabelColor, 8, false);
    CreateLabel("DDVal", col1 + g_thermo_width - 40, curr_y, "0.00%", CLR_SAFE, 10, true);
    curr_y += 14;

    // Thermometer background
    CreateRect("DDBarBG", col1, curr_y, g_thermo_width, THERMO_HEIGHT, C'40,42,48', InpBorderColor);
    CreateRect("DDBarFill", col1 + 2, curr_y + 2, 1, THERMO_HEIGHT - 4, CLR_SAFE, CLR_SAFE);

    // Threshold markers on thermometer
    int mark_y = curr_y - 3;
    int mark_h = 4;
    CreateRect("DDM3", col1 + (int)(g_thermo_width * 0.60), mark_y, 2, mark_h, CLR_WARN, CLR_WARN);
    CreateRect("DDM35", col1 + (int)(g_thermo_width * 0.70), mark_y, 2, mark_h, CLR_CAUTION, CLR_CAUTION);
    CreateRect("DDM4", col1 + (int)(g_thermo_width * 0.80), mark_y, 2, mark_h, CLR_CRITICAL, CLR_CRITICAL);
    CreateRect("DDM45", col1 + (int)(g_thermo_width * 0.90), mark_y, 2, mark_h, CLR_HALT, CLR_HALT);

    curr_y += THERMO_HEIGHT + 8;

    // DD Status and Size Factor
    CreateLabel("DDStatusLbl", col1, curr_y, "Status:", InpLabelColor, 8, false);
    CreateLabel("DDStatusVal", col1 + 50, curr_y, "NORMAL", CLR_SAFE, 9, true);
    CreateLabel("SizeFactorLbl", col1 + 150, curr_y, "Size:", InpLabelColor, 8, false);
    CreateLabel("SizeFactorVal", col1 + 185, curr_y, "100%", CLR_SAFE, 9, true);
    curr_y += DASH_ROW_HEIGHT + 4;

    // Gate Status Section
    CreateLabel("GatesLbl", col1, curr_y, "Gates:", InpLabelColor, 8, false);
    curr_y += 14;

    // Gate icons row
    int gate_x = col1;
    string gate_labels[] = {"T", "D", "S", "V", "G", "N"};
    string gate_tooltips[] = {"Time", "DD", "Spread", "Virtual", "Gap", "News"};

    for(int i = 0; i < 6; i++)
    {
        CreateRect("Gate" + IntegerToString(i) + "BG", gate_x, curr_y, GATE_SIZE, GATE_SIZE, CLR_SAFE, InpBorderColor);
        CreateLabel("Gate" + IntegerToString(i) + "Txt", gate_x + 8, curr_y + 6, gate_labels[i], InpBgColor, 11, true);
        gate_x += GATE_SIZE + GATE_SPACING;
    }
    curr_y += GATE_SIZE + 4;

    // Gate legend
    CreateLabel("GateLegend", col1, curr_y, "T=Time D=DD S=Spread V=Virtual G=Gap N=News", InpLabelColor, 7, false);
    curr_y += DASH_ROW_HEIGHT;

    // Separator
    CreateRect("RiskSep", x + DASH_PADDING, curr_y, g_width - 2*DASH_PADDING, 1, InpBorderColor, InpBorderColor);
    curr_y += DASH_SECTION_GAP;

    // === TIME SECTION ===
    CreateLabel("TimeHeader", x + DASH_PADDING, curr_y, "TIME GATES", InpAccentColor, 9, true);
    curr_y += 18;

    // Current ET Time (large)
    CreateLabel("ETLbl", col1, curr_y, "ET Time:", InpLabelColor, 9, false);
    CreateLabel("ETVal", col1 + 70, curr_y, "00:00:00", InpTextColor, 14, true);
    curr_y += 24;

    // Session Status
    CreateLabel("SessionLbl", col1, curr_y, "Session:", InpLabelColor, 8, false);
    CreateLabel("SessionVal", col1 + 60, curr_y, "NY PM", CLR_SAFE, 9, true);
    curr_y += DASH_ROW_HEIGHT;

    // Countdowns
    CreateLabel("BlockLbl", col1, curr_y, "Block New:", InpLabelColor, 8, false);
    CreateLabel("BlockVal", col1 + 75, curr_y, "--:--", CLR_WARN, 9, true);
    CreateLabel("CloseLbl", col1 + 150, curr_y, "Force Close:", InpLabelColor, 8, false);
    CreateLabel("CloseVal", col1 + 235, curr_y, "--:--", CLR_CRITICAL, 9, true);
    curr_y += DASH_ROW_HEIGHT + 4;

    // Separator
    CreateRect("TimeSep", x + DASH_PADDING, curr_y, g_width - 2*DASH_PADDING, 1, InpBorderColor, InpBorderColor);
    curr_y += DASH_SECTION_GAP;

    // === TRADE SECTION ===
    CreateLabel("TradeHeader", x + DASH_PADDING, curr_y, "TODAY'S TRADES", InpAccentColor, 9, true);
    curr_y += 18;

    // Open positions
    CreateLabel("OpenPosLbl", col1, curr_y, "Open Positions:", InpLabelColor, 8, false);
    CreateLabel("OpenPosVal", col1 + 105, curr_y, "0", InpTextColor, 10, true);
    curr_y += DASH_ROW_HEIGHT;

    // Today's trades and wins
    CreateLabel("TodayTradesLbl", col1, curr_y, "Trades:", InpLabelColor, 8, false);
    CreateLabel("TodayTradesVal", col1 + 50, curr_y, "0", InpTextColor, 9, true);
    CreateLabel("TodayWinsLbl", col1 + 100, curr_y, "Wins:", InpLabelColor, 8, false);
    CreateLabel("TodayWinsVal", col1 + 140, curr_y, "0", CLR_PROFIT, 9, true);
    curr_y += DASH_ROW_HEIGHT;

    // Win rate with progress bar
    CreateLabel("WinRateLbl", col1, curr_y, "Win Rate:", InpLabelColor, 8, false);
    CreateLabel("WinRateVal", col1 + 65, curr_y, "0%", InpTextColor, 10, true);
    curr_y += 14;

    // Win rate bar
    CreateRect("WinRateBarBG", col1, curr_y, 200, 8, C'40,42,48', InpBorderColor);
    CreateRect("WinRateBarFill", col1 + 1, curr_y + 1, 1, 6, CLR_SAFE, CLR_SAFE);
    curr_y += 16;

    // === FOOTER ===
    CreateRect("FooterSep", x + DASH_PADDING, g_height + y - 25, g_width - 2*DASH_PADDING, 1, InpBorderColor, InpBorderColor);
    CreateLabel("Footer", x + DASH_PADDING, g_height + y - 18, "EA_SCALPER_XAUUSD v2.2 - Apex Compliant", InpLabelColor, 7, false);

    ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Create Rectangle Label                                            |
//+------------------------------------------------------------------+
void CreateRect(string name, int x, int y, int width, int height, color bg_clr, color border_clr)
{
    string obj_name = g_prefix + name;

    if(ObjectCreate(0, obj_name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
    {
        ObjectSetInteger(0, obj_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, y);
        ObjectSetInteger(0, obj_name, OBJPROP_XSIZE, width);
        ObjectSetInteger(0, obj_name, OBJPROP_YSIZE, height);
        ObjectSetInteger(0, obj_name, OBJPROP_BGCOLOR, bg_clr);
        ObjectSetInteger(0, obj_name, OBJPROP_BORDER_COLOR, border_clr);
        ObjectSetInteger(0, obj_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, obj_name, OBJPROP_HIDDEN, true);
    }
}

//+------------------------------------------------------------------+
//| Create Label                                                      |
//+------------------------------------------------------------------+
void CreateLabel(string name, int x, int y, string text, color clr, int font_size, bool bold)
{
    string obj_name = g_prefix + name;

    if(ObjectCreate(0, obj_name, OBJ_LABEL, 0, 0, 0))
    {
        ObjectSetInteger(0, obj_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, y);
        ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, font_size);
        ObjectSetString(0, obj_name, OBJPROP_FONT, bold ? "Consolas Bold" : "Consolas");
        ObjectSetString(0, obj_name, OBJPROP_TEXT, text);
        ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, obj_name, OBJPROP_HIDDEN, true);
    }
}

//+------------------------------------------------------------------+
//| Format money value                                                |
//+------------------------------------------------------------------+
string FormatMoney(double value)
{
    if(MathAbs(value) >= 1000000)
        return StringFormat("$%.2fM", value / 1000000);
    if(MathAbs(value) >= 1000)
        return StringFormat("$%.1fK", value / 1000);
    return StringFormat("$%.2f", value);
}

//+------------------------------------------------------------------+
//| Format money with sign                                            |
//+------------------------------------------------------------------+
string FormatMoneySign(double value)
{
    string sign = value >= 0 ? "+" : "";
    if(MathAbs(value) >= 1000000)
        return sign + StringFormat("$%.2fM", MathAbs(value) / 1000000);
    if(MathAbs(value) >= 1000)
        return sign + StringFormat("$%.1fK", MathAbs(value) / 1000);
    return sign + StringFormat("$%.2f", value);
}

//+------------------------------------------------------------------+
//| Format time remaining                                             |
//+------------------------------------------------------------------+
string FormatMinutes(int minutes)
{
    if(minutes <= 0)
        return "NOW";

    int hours = minutes / 60;
    int mins = minutes % 60;

    if(hours > 0)
        return StringFormat("%d:%02d", hours, mins);
    else
        return StringFormat("%dm", mins);
}

//+------------------------------------------------------------------+
//| Get DD color based on percentage                                  |
//+------------------------------------------------------------------+
color GetDDColor(double dd_pct)
{
    if(dd_pct >= 4.5) return CLR_HALT;
    if(dd_pct >= 4.0) return CLR_CRITICAL;
    if(dd_pct >= 3.5) return CLR_CAUTION;
    if(dd_pct >= 3.0) return CLR_WARN;
    return CLR_SAFE;
}

//+------------------------------------------------------------------+
//| Get DD status text                                                |
//+------------------------------------------------------------------+
string GetDDStatus(double dd_pct)
{
    if(dd_pct >= 4.5) return "HALT";
    if(dd_pct >= 4.0) return "CRITICAL";
    if(dd_pct >= 3.5) return "CAUTION";
    if(dd_pct >= 3.0) return "WARNING";
    return "NORMAL";
}

//+------------------------------------------------------------------+
//| Get current session name                                          |
//+------------------------------------------------------------------+
string GetSessionName(int et_hour)
{
    if(et_hour >= 2 && et_hour < 5) return "London Open";
    if(et_hour >= 5 && et_hour < 8) return "London";
    if(et_hour >= 8 && et_hour < 11) return "NY AM";
    if(et_hour >= 11 && et_hour < 13) return "NY Lunch";
    if(et_hour >= 13 && et_hour < 16) return "NY PM";
    if(et_hour >= 16 && et_hour < 17) return "Closing";
    return "Off-Hours";
}

//+------------------------------------------------------------------+
//| Update Dashboard with current data                                |
//+------------------------------------------------------------------+
void UpdateDashboard()
{
    if(!InpShowDashboard) return;

    // Get data (from demo or real)
    double equity, balance, margin, hwm, daily_pnl, session_start;
    double trailing_dd_pct, daily_dd_pct, size_factor;
    bool gates[6];
    int time_state, minutes_to_block, minutes_to_close;
    int open_positions, today_trades, today_wins;
    double today_winrate;
    datetime et_time;

    if(InpDemoMode)
    {
        UpdateDemoState();

        equity = g_demo.equity;
        balance = g_demo.balance;
        margin = g_demo.margin;
        hwm = g_demo.hwm;
        daily_pnl = g_demo.daily_pnl;
        session_start = g_demo.session_start;

        trailing_dd_pct = g_demo.trailing_dd_pct;
        daily_dd_pct = g_demo.daily_dd_pct;
        size_factor = g_demo.size_factor;

        for(int i = 0; i < 6; i++)
            gates[i] = g_demo.gates[i];

        time_state = g_demo.time_state;
        minutes_to_block = g_demo.minutes_to_block;
        minutes_to_close = g_demo.minutes_to_close;

        open_positions = g_demo.open_positions;
        today_trades = g_demo.today_trades;
        today_wins = g_demo.today_wins;
        today_winrate = g_demo.today_winrate;

        // Simulated ET time
        MqlDateTime mdt;
        TimeToStruct(TimeCurrent(), mdt);
        mdt.hour = (mdt.hour - 5 + 24) % 24;  // Convert to ET
        et_time = StructToTime(mdt);
    }
    else
    {
        // Read from account/globals
        equity = AccountInfoDouble(ACCOUNT_EQUITY);
        balance = AccountInfoDouble(ACCOUNT_BALANCE);
        margin = AccountInfoDouble(ACCOUNT_MARGIN);

        // Read from global variables (set by EA)
        hwm = GlobalVariableGet("APEX_HWM");
        if(hwm == 0) hwm = equity;

        session_start = GlobalVariableGet("APEX_SESSION_START");
        if(session_start == 0) session_start = balance;

        daily_pnl = equity - session_start;

        // DD calculation
        trailing_dd_pct = (hwm - equity) / hwm * 100.0;
        if(trailing_dd_pct < 0) trailing_dd_pct = 0;

        daily_dd_pct = GlobalVariableGet("APEX_DAILY_DD_PCT");
        size_factor = GlobalVariableGet("APEX_SIZE_FACTOR");
        if(size_factor == 0) size_factor = 1.0;

        // Gate states from globals
        gates[0] = (GlobalVariableGet("APEX_GATE_TIME") != 0);
        gates[1] = (GlobalVariableGet("APEX_GATE_DD") != 0);
        gates[2] = (GlobalVariableGet("APEX_GATE_SPREAD") != 0);
        gates[3] = (GlobalVariableGet("APEX_GATE_VIRTUAL") != 0);
        gates[4] = (GlobalVariableGet("APEX_GATE_GAP") != 0);
        gates[5] = (GlobalVariableGet("APEX_GATE_NEWS") != 0);

        // If no globals, assume all OK
        if(!GlobalVariableCheck("APEX_GATE_TIME"))
            for(int i = 0; i < 6; i++) gates[i] = true;

        // ET time calculation
        et_time = TimeGMT() - 5*3600;  // Simplified EST

        MqlDateTime et_dt;
        TimeToStruct(et_time, et_dt);
        int current_minutes = et_dt.hour * 60 + et_dt.min;
        int block_time = 16*60 + 30;
        int close_time = 16*60 + 59;

        if(current_minutes < block_time)
        {
            minutes_to_block = block_time - current_minutes;
            minutes_to_close = close_time - current_minutes;
            time_state = 0;
        }
        else if(current_minutes < close_time - 4)
        {
            minutes_to_block = 0;
            minutes_to_close = close_time - current_minutes;
            time_state = 1;
        }
        else if(current_minutes < close_time)
        {
            minutes_to_block = 0;
            minutes_to_close = close_time - current_minutes;
            time_state = 2;
        }
        else
        {
            minutes_to_block = 0;
            minutes_to_close = 0;
            time_state = 3;
        }

        // Trade stats from globals
        open_positions = (int)GlobalVariableGet("APEX_OPEN_POSITIONS");
        today_trades = (int)GlobalVariableGet("APEX_TODAY_TRADES");
        today_wins = (int)GlobalVariableGet("APEX_TODAY_WINS");
        today_winrate = today_trades > 0 ? (double)today_wins / today_trades * 100.0 : 0;
    }

    // === UPDATE ACCOUNT SECTION ===
    color equity_color = daily_pnl >= 0 ? CLR_PROFIT : CLR_LOSS;
    ObjectSetString(0, g_prefix + "EquityVal", OBJPROP_TEXT, FormatMoney(equity));
    ObjectSetInteger(0, g_prefix + "EquityVal", OBJPROP_COLOR, equity_color);
    ObjectSetString(0, g_prefix + "BalanceVal", OBJPROP_TEXT, FormatMoney(balance));
    ObjectSetString(0, g_prefix + "HWMVal", OBJPROP_TEXT, FormatMoney(hwm));
    ObjectSetString(0, g_prefix + "MarginVal", OBJPROP_TEXT, FormatMoney(margin));

    color pnl_color = daily_pnl >= 0 ? CLR_PROFIT : CLR_LOSS;
    ObjectSetString(0, g_prefix + "PnLVal", OBJPROP_TEXT, FormatMoneySign(daily_pnl));
    ObjectSetInteger(0, g_prefix + "PnLVal", OBJPROP_COLOR, pnl_color);

    // === UPDATE RISK SECTION ===
    color dd_color = GetDDColor(trailing_dd_pct);
    string dd_status = GetDDStatus(trailing_dd_pct);

    ObjectSetString(0, g_prefix + "DDVal", OBJPROP_TEXT, StringFormat("%.2f%%", trailing_dd_pct));
    ObjectSetInteger(0, g_prefix + "DDVal", OBJPROP_COLOR, dd_color);

    // Thermometer fill
    double dd_clamped = MathMax(0.0, MathMin(5.0, trailing_dd_pct));
    int fill_width = (int)((dd_clamped / 5.0) * (g_thermo_width - 4));
    fill_width = MathMax(1, fill_width);

    ObjectSetInteger(0, g_prefix + "DDBarFill", OBJPROP_XSIZE, fill_width);
    ObjectSetInteger(0, g_prefix + "DDBarFill", OBJPROP_BGCOLOR, dd_color);
    ObjectSetInteger(0, g_prefix + "DDBarFill", OBJPROP_BORDER_COLOR, dd_color);

    ObjectSetString(0, g_prefix + "DDStatusVal", OBJPROP_TEXT, dd_status);
    ObjectSetInteger(0, g_prefix + "DDStatusVal", OBJPROP_COLOR, dd_color);

    // Size factor
    color size_color = size_factor >= 1.0 ? CLR_SAFE : (size_factor >= 0.5 ? CLR_WARN : CLR_HALT);
    ObjectSetString(0, g_prefix + "SizeFactorVal", OBJPROP_TEXT, StringFormat("%.0f%%", size_factor * 100));
    ObjectSetInteger(0, g_prefix + "SizeFactorVal", OBJPROP_COLOR, size_color);

    // Gate icons
    for(int i = 0; i < 6; i++)
    {
        color gate_color = gates[i] ? CLR_SAFE : CLR_HALT;
        ObjectSetInteger(0, g_prefix + "Gate" + IntegerToString(i) + "BG", OBJPROP_BGCOLOR, gate_color);
    }

    // === UPDATE TIME SECTION ===
    MqlDateTime et_dt;
    TimeToStruct(et_time, et_dt);

    ObjectSetString(0, g_prefix + "ETVal", OBJPROP_TEXT,
                   StringFormat("%02d:%02d:%02d", et_dt.hour, et_dt.min, et_dt.sec));

    // Session name
    string session_name = GetSessionName(et_dt.hour);
    color session_color = (et_dt.hour >= 8 && et_dt.hour < 16) ? CLR_SAFE : CLR_WARN;
    ObjectSetString(0, g_prefix + "SessionVal", OBJPROP_TEXT, session_name);
    ObjectSetInteger(0, g_prefix + "SessionVal", OBJPROP_COLOR, session_color);

    // Countdowns
    color block_color = time_state >= 1 ? CLR_HALT : CLR_WARN;
    color close_color = time_state >= 2 ? CLR_HALT : CLR_CRITICAL;

    ObjectSetString(0, g_prefix + "BlockVal", OBJPROP_TEXT, FormatMinutes(minutes_to_block));
    ObjectSetInteger(0, g_prefix + "BlockVal", OBJPROP_COLOR, block_color);

    ObjectSetString(0, g_prefix + "CloseVal", OBJPROP_TEXT, FormatMinutes(minutes_to_close));
    ObjectSetInteger(0, g_prefix + "CloseVal", OBJPROP_COLOR, close_color);

    // === UPDATE TRADE SECTION ===
    color pos_color = open_positions > 0 ? InpAccentColor : InpTextColor;
    ObjectSetString(0, g_prefix + "OpenPosVal", OBJPROP_TEXT, IntegerToString(open_positions));
    ObjectSetInteger(0, g_prefix + "OpenPosVal", OBJPROP_COLOR, pos_color);

    ObjectSetString(0, g_prefix + "TodayTradesVal", OBJPROP_TEXT, IntegerToString(today_trades));
    ObjectSetString(0, g_prefix + "TodayWinsVal", OBJPROP_TEXT, IntegerToString(today_wins));

    // Win rate
    color wr_color = today_winrate >= 60 ? CLR_SAFE : (today_winrate >= 50 ? CLR_WARN : CLR_LOSS);
    ObjectSetString(0, g_prefix + "WinRateVal", OBJPROP_TEXT, StringFormat("%.1f%%", today_winrate));
    ObjectSetInteger(0, g_prefix + "WinRateVal", OBJPROP_COLOR, wr_color);

    // Win rate bar
    int wr_fill = (int)(today_winrate / 100.0 * 198);
    wr_fill = MathMax(1, MathMin(198, wr_fill));
    ObjectSetInteger(0, g_prefix + "WinRateBarFill", OBJPROP_XSIZE, wr_fill);
    ObjectSetInteger(0, g_prefix + "WinRateBarFill", OBJPROP_BGCOLOR, wr_color);
    ObjectSetInteger(0, g_prefix + "WinRateBarFill", OBJPROP_BORDER_COLOR, wr_color);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                                |
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
                const int &spread[])
{
    // Update frequency
    int update_ms = InpDemoMode ? 100 : 1000;

    static uint last_update = 0;
    uint now = GetTickCount();

    if(now - last_update < (uint)update_ms)
        return rates_total;

    last_update = now;

    // Update dashboard
    UpdateDashboard();

    ChartRedraw(0);

    return rates_total;
}

//+------------------------------------------------------------------+
//| Timer function for smooth updates                                 |
//+------------------------------------------------------------------+
void OnTimer()
{
    UpdateDashboard();
    ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Chart event handler                                               |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    // Handle chart resize
    if(id == CHARTEVENT_CHART_CHANGE)
    {
        DeleteDashboard();
        CreateDashboard();
    }
}
//+------------------------------------------------------------------+
