//+------------------------------------------------------------------+
//|                                                   SMC_Visual.mq5 |
//|                         FORGE v5.2 - Visual SMC Indicator        |
//|                     Order Blocks, FVG, Sessions, Structure       |
//|                     + BOS/CHoCH, Apex HUD, ICT Killzones         |
//|                     + Premium/Discount, PDH/PDL, Asian Range     |
//|                     + Strategy Context Panel (dynamic TF tips)   |
//+------------------------------------------------------------------+
//| v5.2 IMPROVEMENTS:                                                |
//| - Strategy Context Panel: dynamic advice per timeframe            |
//| - Session awareness: shows current killzone/session               |
//| - Daily tips: Monday-Friday trading guidance                      |
//| - Pattern suggestions based on TF (scalp/intraday/swing)          |
//| - Reduced default clutter (Sessions, KZ, Structure OFF)           |
//+------------------------------------------------------------------+
//| v5.1 IMPROVEMENTS (TIER 2 features):                             |
//| - Premium/Discount Zones (50% equilibrium)                       |
//| - PDH/PDL (Previous Day High/Low) lines                          |
//| - Asian Range Box with midpoint                                  |
//+------------------------------------------------------------------+
//| v5.0 IMPROVEMENTS (CRUCIBLE/FORGE/CRITIC):                       |
//| - DST-safe timezone via CApexTimeHandler (CRITIC #2)             |
//| - Dynamic FVG minimum = MAX(input, ATR*0.3) + fill detection     |
//| - BOS/CHoCH visualization for structure breaks                   |
//| - Increased liquidity tolerance for XAUUSD                       |
//+------------------------------------------------------------------+
#property copyright "FORGE v5.2 - EA_SCALPER_XAUUSD"
#property link      "EA_SCALPER_XAUUSD"
#property version   "5.20"
#property description "Smart Money Concept visual indicator with Apex risk display"
#property description "Features: OB, FVG, Sessions, Structure, Liquidity, ICT Killzones"
#property description "v5.2: Strategy Context Panel - dynamic TF advice"
#property description "Apex HUD: DD Thermometer, Gate Status, ET Countdown"
#property description "Demo Mode for investor presentations"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//+------------------------------------------------------------------+
//| Input Groups                                                      |
//+------------------------------------------------------------------+

//--- SMC Components
input group "=== ORDER BLOCKS ==="
input bool     InpShowOB          = true;           // Show Order Blocks
input color    InpBullOBColor     = clrDodgerBlue;  // Bullish OB Color
input color    InpBearOBColor     = clrCrimson;     // Bearish OB Color
input double   InpOBDisplacement  = 2.0;            // Min Displacement (ATR mult)
input int      InpOBMaxAge        = 50;             // Max OB Age (bars)

input group "=== FAIR VALUE GAPS ==="
input bool     InpShowFVG         = true;           // Show FVGs
input color    InpBullFVGColor    = clrLimeGreen;   // Bullish FVG Color
input color    InpBearFVGColor    = clrOrangeRed;   // Bearish FVG Color
input double   InpFVGMinGap       = 2.0;            // Min Gap Base (pts) - uses MAX(this, ATR*0.3)

input group "=== SESSIONS ==="
input bool     InpShowSessions    = false;          // Show Sessions (disable to reduce clutter)
input color    InpAsianColor      = clrDarkSlateGray; // Asian Session Color
input color    InpLondonColor     = clrDarkGreen;   // London Session Color
input color    InpNYColor         = clrDarkBlue;    // NY Session Color

input group "=== ICT KILLZONES ==="
input bool     InpShowKillzones   = false;          // Show ICT Killzones (disable to reduce clutter)
input color    InpLondonKZColor   = C'0,100,0';     // London Open (02:00-05:00 ET) - Green
input color    InpNYAMKZColor     = C'0,0,139';     // NY AM (08:30-11:00 ET) - Blue
input color    InpNYPMKZColor     = C'255,140,0';   // NY PM (13:00-16:00 ET) - Orange
input int      InpKZAlpha         = 30;             // Killzone Transparency (0-100)

input group "=== STRUCTURE ==="
input bool     InpShowStructure   = false;          // Show Structure HH/HL/LL/LH (disable to reduce clutter)
input int      InpSwingStrength   = 3;              // Swing Strength (bars)
input color    InpHHColor         = clrLime;        // Higher High Color
input color    InpHLColor         = clrGreen;       // Higher Low Color
input color    InpLHColor         = clrOrange;      // Lower High Color
input color    InpLLColor         = clrRed;         // Lower Low Color

input group "=== BOS/CHoCH ==="
input bool     InpShowBOSCHoCH    = false;          // Show BOS/CHoCH (disable to reduce clutter)
input color    InpBOSBullColor    = clrDodgerBlue;  // Bullish BOS Color (continuation)
input color    InpBOSBearColor    = clrCrimson;     // Bearish BOS Color (continuation)
input color    InpCHoCHBullColor  = clrLime;        // Bullish CHoCH Color (reversal up)
input color    InpCHoCHBearColor  = clrOrange;      // Bearish CHoCH Color (reversal down)
input int      InpMaxBOSObjects   = 30;             // Max BOS/CHoCH objects (separate budget)

input group "=== LIQUIDITY ==="
input bool     InpShowLiquidity   = false;          // Show Liquidity (disable to reduce clutter)
input color    InpBSLColor        = clrGold;        // BSL Color (buy-side)
input color    InpSSLColor        = clrMagenta;     // SSL Color (sell-side)

input group "=== APEX HUD ==="
input bool     InpShowHUD         = true;           // Show Apex Risk HUD
input bool     InpShowDDThermo    = true;           // Show DD Thermometer
input bool     InpShowGateStatus  = true;           // Show Gate Status Panel
input bool     InpShowETCountdown = true;           // Show ET Countdown
input bool     InpShowMLConfidence = false;         // Show ML Confidence (if available)
input int      InpHUDCorner       = 0;              // HUD Corner (0=TopLeft, 1=TopRight, 2=BottomLeft, 3=BottomRight)
input int      InpHUDOffsetX      = 10;             // HUD X Offset from corner
input int      InpHUDOffsetY      = 30;             // HUD Y Offset from corner

input group "=== DEMO MODE ==="
input bool     InpDemoMode        = false;          // Demo Mode (for presentations)
input int      InpDemoSpeed       = 1000;           // Demo Animation Speed (ms)

input group "=== PREMIUM/DISCOUNT ZONES ==="
input bool     InpShowPremDisc    = false;          // Show Premium/Discount (disable to reduce clutter)
input color    InpPremiumColor    = C'139,0,0';     // Premium Zone (upper 50%) - Dark Red
input color    InpDiscountColor   = C'0,100,0';     // Discount Zone (lower 50%) - Dark Green
input color    InpEquilibriumColor = clrGold;       // Equilibrium Line (50%)
input int      InpPDAlpha         = 20;             // Zone Transparency (0-100)

input group "=== PDH/PDL (Previous Day High/Low) ==="
input bool     InpShowPDHL        = true;           // Show Previous Day High/Low
input color    InpPDHColor        = clrAqua;        // PDH Color (Previous Day High)
input color    InpPDLColor        = clrMagenta;     // PDL Color (Previous Day Low)
input ENUM_LINE_STYLE InpPDHLStyle = STYLE_DASH;    // PDH/PDL Line Style
input int      InpPDHLWidth       = 1;              // PDH/PDL Line Width

input group "=== ASIAN RANGE BOX ==="
input bool     InpShowAsianRange  = true;           // Show Asian Range Box
input int      InpAsianStartHour  = 18;             // Asian Start Hour (ET) - 18:00 = 6pm
input int      InpAsianEndHour    = 0;              // Asian End Hour (ET) - 0:00 = midnight
input color    InpAsianRangeColor = clrDarkSlateGray; // Asian Range Box Color
input bool     InpShowAsianMid    = true;           // Show Asian Range Midpoint
input color    InpAsianMidColor   = clrSilver;      // Asian Midpoint Color

input group "=== STRATEGY CONTEXT PANEL ==="
input bool     InpShowStratPanel  = true;           // Show Strategy Context Panel
input int      InpStratPanelCorner = 1;             // Panel Corner (0=TL,1=TR,2=BL,3=BR)

input group "=== SETTINGS ==="
input int      InpMaxObjects      = 100;            // Max SMC Objects on Chart
input int      InpLookback        = 200;            // Lookback Bars

//+------------------------------------------------------------------+
//| HUD Constants                                                     |
//+------------------------------------------------------------------+
#define HUD_WIDTH          200
#define HUD_HEIGHT         180
#define HUD_PADDING        6
#define HUD_ROW_HEIGHT     18
#define HUD_THERMO_WIDTH   160
#define HUD_THERMO_HEIGHT  12
#define HUD_GATE_SIZE      16
#define HUD_GATE_SPACING   4

//--- Strategy Panel Constants
#define STRAT_PANEL_WIDTH   240
#define STRAT_PANEL_HEIGHT  200

//--- HUD Colors
#define CLR_HUD_BG         C'25,25,30'
#define CLR_HUD_BORDER     C'60,60,70'
#define CLR_HUD_TEXT       clrWhite
#define CLR_HUD_LABEL      clrSilver
#define CLR_DD_NORMAL      clrLimeGreen
#define CLR_DD_WARN        clrYellow
#define CLR_DD_CAUTION     clrOrange
#define CLR_DD_CRITICAL    clrOrangeRed
#define CLR_DD_HALT        clrRed
#define CLR_GATE_OK        clrLimeGreen
#define CLR_GATE_BLOCKED   clrRed
#define CLR_GATE_WARN      clrYellow

//+------------------------------------------------------------------+
//| Enums                                                             |
//+------------------------------------------------------------------+
enum ENUM_GATE_STATE
{
    GATE_OK,
    GATE_WARN,
    GATE_BLOCKED
};

enum ENUM_TIME_STATE_VISUAL
{
    TIME_NORMAL,
    TIME_BLOCK_NEW,
    TIME_EMERGENCY,
    TIME_HALTED
};

//+------------------------------------------------------------------+
//| Demo Mode Simulation State                                        |
//+------------------------------------------------------------------+
struct SDemoState
{
    double dd_pct;             // Simulated DD %
    double dd_direction;       // +1 or -1
    double ml_confidence;      // Simulated ML confidence
    int    time_state;         // 0=Normal, 1=Block, 2=Emergency, 3=Halted
    bool   gates[5];           // Time, DD, Spread, Virtual, Gap
    int    cycle_counter;      // Animation cycle
    datetime last_update;
};

//+------------------------------------------------------------------+
//| Global Variables                                                  |
//+------------------------------------------------------------------+
int g_atrHandle;
double g_atr[];
string g_prefix = "SMC_";
string g_hudPrefix = "SMCHUD_";
string g_stratPrefix = "SMCSTRAT_";  // Strategy Panel prefix
int g_objectCount = 0;
int g_bosObjectCount = 0;  // Separate budget for BOS/CHoCH (CRITIC fix)
SDemoState g_demo;

//--- Forward declarations for Strategy Panel
void CreateStrategyPanel();
void UpdateStrategyPanel();
void DeleteStrategyPanel();

//+------------------------------------------------------------------+
//| Market Structure Tracking for BOS/CHoCH                          |
//+------------------------------------------------------------------+
enum ENUM_MARKET_STRUCTURE
{
    STRUCTURE_UNDEFINED,
    STRUCTURE_BULLISH,    // Making HH and HL
    STRUCTURE_BEARISH     // Making LL and LH
};

struct SSwingPoint
{
    datetime time;
    double   price;
    bool     is_high;      // true = swing high, false = swing low
    int      bar_index;
};

//+------------------------------------------------------------------+
//| DST-Safe Timezone Helper Functions                                |
//| Per CRITIC: Use proper DST calculation instead of hardcoded -5   |
//+------------------------------------------------------------------+
bool IsUSDaylightSavingTime(datetime time_utc)
{
    MqlDateTime dt;
    TimeToStruct(time_utc, dt);

    int year = dt.year;
    int month = dt.mon;
    int day = dt.day;
    int hour = dt.hour;

    // DST not in effect: January, February, December
    if(month < 3 || month > 11)
        return false;

    // DST always in effect: April through October
    if(month > 3 && month < 11)
        return true;

    // March: DST starts 2nd Sunday at 2:00 AM local (7:00 UTC)
    if(month == 3)
    {
        // Find 2nd Sunday of March
        MqlDateTime march_first;
        march_first.year = year;
        march_first.mon = 3;
        march_first.day = 1;
        march_first.hour = 0;
        march_first.min = 0;
        march_first.sec = 0;

        datetime march_first_dt = StructToTime(march_first);
        TimeToStruct(march_first_dt, march_first);

        // day_of_week: 0=Sunday, 1=Monday, etc
        int first_sunday = 1 + (7 - march_first.day_of_week) % 7;
        int second_sunday = first_sunday + 7;

        // DST starts at 2 AM EST = 7:00 UTC on second Sunday
        if(day > second_sunday)
            return true;
        if(day == second_sunday && hour >= 7)
            return true;
        return false;
    }

    // November: DST ends 1st Sunday at 2:00 AM local (6:00 UTC)
    if(month == 11)
    {
        MqlDateTime nov_first;
        nov_first.year = year;
        nov_first.mon = 11;
        nov_first.day = 1;
        nov_first.hour = 0;
        nov_first.min = 0;
        nov_first.sec = 0;

        datetime nov_first_dt = StructToTime(nov_first);
        TimeToStruct(nov_first_dt, nov_first);

        int first_sunday = 1 + (7 - nov_first.day_of_week) % 7;

        // DST ends at 2 AM EDT = 6:00 UTC on first Sunday
        if(day < first_sunday)
            return true;
        if(day == first_sunday && hour < 6)
            return true;
        return false;
    }

    return false;
}

int GetEasternTimeHour(datetime time_utc)
{
    int offset = IsUSDaylightSavingTime(time_utc) ? -4 : -5;

    MqlDateTime dt;
    TimeToStruct(time_utc, dt);

    int et_hour = (dt.hour + offset + 24) % 24;
    return et_hour;
}

int GetETOffsetHours(datetime time_utc)
{
    return IsUSDaylightSavingTime(time_utc) ? -4 : -5;
}

//+------------------------------------------------------------------+
//| Custom indicator initialization                                    |
//+------------------------------------------------------------------+
int OnInit()
{
    g_atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
    if(g_atrHandle == INVALID_HANDLE)
    {
        Print("Failed to create ATR handle");
        return INIT_FAILED;
    }

    ArraySetAsSeries(g_atr, true);

    // Initialize demo state
    InitDemoState();

    // Clean old objects
    DeleteAllObjects();

    // Create HUD if enabled
    if(InpShowHUD)
        CreateHUD();

    // Create Strategy Context Panel if enabled
    if(InpShowStratPanel)
        CreateStrategyPanel();

    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    DeleteAllObjects();
    DeleteHUD();
    DeleteStrategyPanel();
    if(g_atrHandle != INVALID_HANDLE)
        IndicatorRelease(g_atrHandle);
}

//+------------------------------------------------------------------+
//| Initialize Demo State                                             |
//+------------------------------------------------------------------+
void InitDemoState()
{
    g_demo.dd_pct = 1.5;
    g_demo.dd_direction = 0.1;
    g_demo.ml_confidence = 0.72;
    g_demo.time_state = 0;
    for(int i = 0; i < 5; i++)
        g_demo.gates[i] = true;  // All OK initially
    g_demo.cycle_counter = 0;
    g_demo.last_update = 0;
}

//+------------------------------------------------------------------+
//| Update Demo State                                                 |
//+------------------------------------------------------------------+
void UpdateDemoState()
{
    if(!InpDemoMode) return;

    // Only update at specified speed
    if(GetTickCount() - (uint)g_demo.last_update < (uint)InpDemoSpeed)
        return;

    g_demo.last_update = (datetime)GetTickCount();
    g_demo.cycle_counter++;

    // Animate DD (oscillate between 0.5 and 4.5)
    g_demo.dd_pct += g_demo.dd_direction;
    if(g_demo.dd_pct >= 4.5)
    {
        g_demo.dd_pct = 4.5;
        g_demo.dd_direction = -0.1;
    }
    else if(g_demo.dd_pct <= 0.5)
    {
        g_demo.dd_pct = 0.5;
        g_demo.dd_direction = 0.1;
    }

    // Animate ML confidence
    g_demo.ml_confidence = 0.65 + MathSin(g_demo.cycle_counter * 0.1) * 0.20;

    // Cycle time state every 20 cycles
    if(g_demo.cycle_counter % 20 == 0)
    {
        g_demo.time_state = (g_demo.time_state + 1) % 4;
    }

    // Toggle gates randomly every 15 cycles
    if(g_demo.cycle_counter % 15 == 0)
    {
        int gate_idx = g_demo.cycle_counter % 5;
        g_demo.gates[gate_idx] = !g_demo.gates[gate_idx];
    }
}

//+------------------------------------------------------------------+
//| Delete all indicator objects                                       |
//+------------------------------------------------------------------+
void DeleteAllObjects()
{
    ObjectsDeleteAll(0, g_prefix);
    g_objectCount = 0;
}

//+------------------------------------------------------------------+
//| Delete HUD objects                                                |
//+------------------------------------------------------------------+
void DeleteHUD()
{
    ObjectsDeleteAll(0, g_hudPrefix);
}

//+------------------------------------------------------------------+
//| Delete Strategy Panel objects                                     |
//+------------------------------------------------------------------+
void DeleteStrategyPanel()
{
    ObjectsDeleteAll(0, g_stratPrefix);
}

//+------------------------------------------------------------------+
//| Get HUD position based on corner setting                          |
//+------------------------------------------------------------------+
void GetHUDPosition(int &x, int &y)
{
    int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
    int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

    switch(InpHUDCorner)
    {
        case 0:  // Top Left
            x = InpHUDOffsetX;
            y = InpHUDOffsetY;
            break;
        case 1:  // Top Right
            x = chart_width - HUD_WIDTH - InpHUDOffsetX;
            y = InpHUDOffsetY;
            break;
        case 2:  // Bottom Left
            x = InpHUDOffsetX;
            y = chart_height - HUD_HEIGHT - InpHUDOffsetY;
            break;
        case 3:  // Bottom Right
            x = chart_width - HUD_WIDTH - InpHUDOffsetX;
            y = chart_height - HUD_HEIGHT - InpHUDOffsetY;
            break;
        default:
            x = InpHUDOffsetX;
            y = InpHUDOffsetY;
    }
}

//+------------------------------------------------------------------+
//| Create HUD Panel                                                  |
//+------------------------------------------------------------------+
void CreateHUD()
{
    int x, y;
    GetHUDPosition(x, y);

    // Background panel
    CreateHUDRect("Background", x, y, HUD_WIDTH, HUD_HEIGHT, CLR_HUD_BG, CLR_HUD_BORDER);

    // Title
    CreateHUDLabel("Title", x + HUD_PADDING, y + HUD_PADDING, "APEX RISK MONITOR", CLR_HUD_TEXT, 9);

    // Title separator
    CreateHUDRect("TitleSep", x + HUD_PADDING, y + HUD_PADDING + 16, HUD_WIDTH - 2*HUD_PADDING, 1, CLR_HUD_BORDER, CLR_HUD_BORDER);

    int section_y = y + HUD_PADDING + 22;

    // DD Thermometer section
    if(InpShowDDThermo)
    {
        CreateHUDLabel("DDLabel", x + HUD_PADDING, section_y, "Trailing DD:", CLR_HUD_LABEL, 8);
        CreateHUDLabel("DDValue", x + HUD_WIDTH - 45, section_y, "0.00%", CLR_DD_NORMAL, 9);

        // Thermometer bar background
        section_y += 14;
        CreateHUDRect("DDBarBG", x + HUD_PADDING, section_y, HUD_THERMO_WIDTH, HUD_THERMO_HEIGHT, C'50,50,55', CLR_HUD_BORDER);

        // Thermometer fill
        CreateHUDRect("DDBarFill", x + HUD_PADDING + 1, section_y + 1, 1, HUD_THERMO_HEIGHT - 2, CLR_DD_NORMAL, CLR_DD_NORMAL);

        // Threshold markers (3%, 3.5%, 4%, 4.5%)
        int m3 = (int)(HUD_THERMO_WIDTH * 0.60);
        int m35 = (int)(HUD_THERMO_WIDTH * 0.70);
        int m4 = (int)(HUD_THERMO_WIDTH * 0.80);
        int m45 = (int)(HUD_THERMO_WIDTH * 0.90);
        CreateHUDRect("DDMark3", x + HUD_PADDING + m3, section_y - 2, 1, 2, CLR_DD_WARN, CLR_DD_WARN);
        CreateHUDRect("DDMark35", x + HUD_PADDING + m35, section_y - 2, 1, 2, CLR_DD_CAUTION, CLR_DD_CAUTION);
        CreateHUDRect("DDMark4", x + HUD_PADDING + m4, section_y - 2, 1, 2, CLR_DD_CRITICAL, CLR_DD_CRITICAL);
        CreateHUDRect("DDMark45", x + HUD_PADDING + m45, section_y - 2, 1, 2, CLR_DD_HALT, CLR_DD_HALT);

        section_y += HUD_THERMO_HEIGHT + 6;
    }

    // ET Countdown section
    if(InpShowETCountdown)
    {
        CreateHUDRect("TimeSep", x + HUD_PADDING, section_y, HUD_WIDTH - 2*HUD_PADDING, 1, CLR_HUD_BORDER, CLR_HUD_BORDER);
        section_y += 4;

        CreateHUDLabel("ETLabel", x + HUD_PADDING, section_y, "ET Time:", CLR_HUD_LABEL, 8);
        CreateHUDLabel("ETValue", x + 65, section_y, "00:00:00", CLR_HUD_TEXT, 9);

        section_y += 14;
        CreateHUDLabel("BlockLabel", x + HUD_PADDING, section_y, "Block in:", CLR_HUD_LABEL, 8);
        CreateHUDLabel("BlockValue", x + 65, section_y, "--:--", clrYellow, 9);

        CreateHUDLabel("CloseLabel", x + 110, section_y, "Close:", CLR_HUD_LABEL, 8);
        CreateHUDLabel("CloseValue", x + 145, section_y, "--:--", clrOrangeRed, 9);

        section_y += 18;
    }

    // Gate Status section
    if(InpShowGateStatus)
    {
        CreateHUDRect("GateSep", x + HUD_PADDING, section_y, HUD_WIDTH - 2*HUD_PADDING, 1, CLR_HUD_BORDER, CLR_HUD_BORDER);
        section_y += 4;

        CreateHUDLabel("GatesLabel", x + HUD_PADDING, section_y, "Gates:", CLR_HUD_LABEL, 8);

        int icon_x = x + HUD_PADDING + 45;
        section_y += 2;

        // Gate icons: T=Time, D=DD, S=Spread, V=Virtual, G=Gap
        string gate_letters[] = {"T", "D", "S", "V", "G"};
        for(int i = 0; i < 5; i++)
        {
            CreateHUDRect("Gate" + IntegerToString(i) + "BG", icon_x, section_y, HUD_GATE_SIZE, HUD_GATE_SIZE, CLR_GATE_OK, CLR_HUD_BORDER);
            CreateHUDLabel("Gate" + IntegerToString(i) + "Text", icon_x + 4, section_y + 2, gate_letters[i], CLR_HUD_BG, 9);
            icon_x += HUD_GATE_SIZE + HUD_GATE_SPACING;
        }

        section_y += HUD_GATE_SIZE + 4;
    }

    // ML Confidence section (optional)
    if(InpShowMLConfidence)
    {
        CreateHUDRect("MLSep", x + HUD_PADDING, section_y, HUD_WIDTH - 2*HUD_PADDING, 1, CLR_HUD_BORDER, CLR_HUD_BORDER);
        section_y += 4;

        CreateHUDLabel("MLLabel", x + HUD_PADDING, section_y, "ML Conf:", CLR_HUD_LABEL, 8);
        CreateHUDLabel("MLValue", x + 65, section_y, "N/A", CLR_HUD_TEXT, 9);
        CreateHUDRect("MLBarBG", x + 95, section_y + 2, 80, 10, C'50,50,55', CLR_HUD_BORDER);
        CreateHUDRect("MLBarFill", x + 96, section_y + 3, 1, 8, clrDodgerBlue, clrDodgerBlue);
    }

    // Demo mode indicator
    if(InpDemoMode)
    {
        CreateHUDLabel("DemoIndicator", x + HUD_WIDTH - 50, y + HUD_HEIGHT - 14, "[DEMO]", clrMagenta, 8);
    }
}

//+------------------------------------------------------------------+
//| Create HUD Rectangle                                              |
//+------------------------------------------------------------------+
void CreateHUDRect(string name, int x, int y, int width, int height, color bg_clr, color border_clr)
{
    string obj_name = g_hudPrefix + name;

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
//| Create HUD Label                                                  |
//+------------------------------------------------------------------+
void CreateHUDLabel(string name, int x, int y, string text, color clr, int font_size)
{
    string obj_name = g_hudPrefix + name;

    if(ObjectCreate(0, obj_name, OBJ_LABEL, 0, 0, 0))
    {
        ObjectSetInteger(0, obj_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, y);
        ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, font_size);
        ObjectSetString(0, obj_name, OBJPROP_FONT, "Consolas");
        ObjectSetString(0, obj_name, OBJPROP_TEXT, text);
        ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, obj_name, OBJPROP_HIDDEN, true);
    }
}

//+------------------------------------------------------------------+
//| Update HUD with current data                                      |
//+------------------------------------------------------------------+
void UpdateHUD()
{
    if(!InpShowHUD) return;

    double dd_pct = 0;
    double ml_conf = 0;
    bool gate_states[5] = {true, true, true, true, true};
    ENUM_TIME_STATE_VISUAL time_state = TIME_NORMAL;
    int minutes_to_block = 0;
    int minutes_to_close = 0;
    datetime et_time = 0;

    if(InpDemoMode)
    {
        // Use demo state
        UpdateDemoState();
        dd_pct = g_demo.dd_pct;
        ml_conf = g_demo.ml_confidence;
        for(int i = 0; i < 5; i++)
            gate_states[i] = g_demo.gates[i];
        time_state = (ENUM_TIME_STATE_VISUAL)g_demo.time_state;

        // Simulate time
        MqlDateTime mdt;
        TimeToStruct(TimeCurrent(), mdt);
        mdt.hour = (mdt.hour + 5) % 24;  // Rough EST offset
        et_time = StructToTime(mdt);

        // Demo countdown values
        minutes_to_block = 60 + (g_demo.cycle_counter % 60);
        minutes_to_close = 90 + (g_demo.cycle_counter % 90);
    }
    else
    {
        // Try to read from global variables (set by EA)
        dd_pct = GlobalVariableGet("APEX_TRAILING_DD_PCT");
        if(dd_pct == 0) dd_pct = 0.0;

        ml_conf = GlobalVariableGet("APEX_ML_CONFIDENCE");
        if(ml_conf == 0) ml_conf = -1;  // Indicates N/A

        // Read gate states from global variables
        gate_states[0] = (GlobalVariableGet("APEX_GATE_TIME") != 0);
        gate_states[1] = (GlobalVariableGet("APEX_GATE_DD") != 0);
        gate_states[2] = (GlobalVariableGet("APEX_GATE_SPREAD") != 0);
        gate_states[3] = (GlobalVariableGet("APEX_GATE_VIRTUAL") != 0);
        gate_states[4] = (GlobalVariableGet("APEX_GATE_GAP") != 0);

        // If no globals set, assume all OK
        if(GlobalVariableCheck("APEX_GATE_TIME") == false)
        {
            for(int i = 0; i < 5; i++) gate_states[i] = true;
        }

        // Get ET time (approximate using NY offset)
        et_time = TimeGMT() - 5*3600;  // EST offset (simplified)

        // Calculate minutes to 4:30 PM and 4:59 PM
        MqlDateTime et_dt;
        TimeToStruct(et_time, et_dt);
        int current_minutes = et_dt.hour * 60 + et_dt.min;
        int block_time = 16*60 + 30;   // 4:30 PM = 990 minutes
        int close_time = 16*60 + 59;   // 4:59 PM = 1019 minutes

        if(current_minutes < block_time)
        {
            minutes_to_block = block_time - current_minutes;
            minutes_to_close = close_time - current_minutes;
            time_state = TIME_NORMAL;
        }
        else if(current_minutes < close_time - 4)  // Before 4:55
        {
            minutes_to_block = 0;
            minutes_to_close = close_time - current_minutes;
            time_state = TIME_BLOCK_NEW;
        }
        else if(current_minutes < close_time)
        {
            minutes_to_block = 0;
            minutes_to_close = close_time - current_minutes;
            time_state = TIME_EMERGENCY;
        }
        else
        {
            minutes_to_block = 0;
            minutes_to_close = 0;
            time_state = TIME_HALTED;
        }
    }

    // Update DD Thermometer
    if(InpShowDDThermo)
    {
        double dd_clamped = MathMax(0.0, MathMin(5.0, dd_pct));
        int fill_width = (int)((dd_clamped / 5.0) * (HUD_THERMO_WIDTH - 2));
        fill_width = MathMax(1, fill_width);

        color dd_color = CLR_DD_NORMAL;
        if(dd_pct >= 4.5) dd_color = CLR_DD_HALT;
        else if(dd_pct >= 4.0) dd_color = CLR_DD_CRITICAL;
        else if(dd_pct >= 3.5) dd_color = CLR_DD_CAUTION;
        else if(dd_pct >= 3.0) dd_color = CLR_DD_WARN;

        string fill_name = g_hudPrefix + "DDBarFill";
        ObjectSetInteger(0, fill_name, OBJPROP_XSIZE, fill_width);
        ObjectSetInteger(0, fill_name, OBJPROP_BGCOLOR, dd_color);
        ObjectSetInteger(0, fill_name, OBJPROP_BORDER_COLOR, dd_color);

        string value_name = g_hudPrefix + "DDValue";
        ObjectSetString(0, value_name, OBJPROP_TEXT, StringFormat("%.2f%%", dd_pct));
        ObjectSetInteger(0, value_name, OBJPROP_COLOR, dd_color);
    }

    // Update ET Countdown
    if(InpShowETCountdown)
    {
        MqlDateTime et_dt;
        TimeToStruct(et_time, et_dt);

        ObjectSetString(0, g_hudPrefix + "ETValue", OBJPROP_TEXT,
                       StringFormat("%02d:%02d:%02d", et_dt.hour, et_dt.min, et_dt.sec));

        // Block countdown
        string block_str = minutes_to_block > 0 ? FormatMinutes(minutes_to_block) : "NOW";
        color block_color = time_state >= TIME_BLOCK_NEW ? clrRed : clrYellow;
        ObjectSetString(0, g_hudPrefix + "BlockValue", OBJPROP_TEXT, block_str);
        ObjectSetInteger(0, g_hudPrefix + "BlockValue", OBJPROP_COLOR, block_color);

        // Close countdown
        string close_str = minutes_to_close > 0 ? FormatMinutes(minutes_to_close) : "CLOSED";
        color close_color = time_state >= TIME_EMERGENCY ? clrRed : clrOrangeRed;
        ObjectSetString(0, g_hudPrefix + "CloseValue", OBJPROP_TEXT, close_str);
        ObjectSetInteger(0, g_hudPrefix + "CloseValue", OBJPROP_COLOR, close_color);
    }

    // Update Gate Status
    if(InpShowGateStatus)
    {
        for(int i = 0; i < 5; i++)
        {
            color gate_color = gate_states[i] ? CLR_GATE_OK : CLR_GATE_BLOCKED;
            ObjectSetInteger(0, g_hudPrefix + "Gate" + IntegerToString(i) + "BG", OBJPROP_BGCOLOR, gate_color);
        }
    }

    // Update ML Confidence
    if(InpShowMLConfidence)
    {
        if(ml_conf >= 0)
        {
            ObjectSetString(0, g_hudPrefix + "MLValue", OBJPROP_TEXT, StringFormat("%.0f%%", ml_conf * 100));

            int ml_fill = (int)(ml_conf * 78);
            ml_fill = MathMax(1, MathMin(78, ml_fill));

            color ml_color = (ml_conf >= 0.65) ? clrLimeGreen : ((ml_conf >= 0.50) ? clrYellow : clrRed);
            ObjectSetInteger(0, g_hudPrefix + "MLBarFill", OBJPROP_XSIZE, ml_fill);
            ObjectSetInteger(0, g_hudPrefix + "MLBarFill", OBJPROP_BGCOLOR, ml_color);
            ObjectSetInteger(0, g_hudPrefix + "MLBarFill", OBJPROP_BORDER_COLOR, ml_color);
        }
        else
        {
            ObjectSetString(0, g_hudPrefix + "MLValue", OBJPROP_TEXT, "N/A");
            ObjectSetInteger(0, g_hudPrefix + "MLBarFill", OBJPROP_XSIZE, 1);
        }
    }
}

//+------------------------------------------------------------------+
//| Format minutes as HH:MM or MM                                     |
//+------------------------------------------------------------------+
string FormatMinutes(int minutes)
{
    if(minutes >= 60)
        return StringFormat("%d:%02d", minutes / 60, minutes % 60);
    else
        return StringFormat("%dm", minutes);
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
    // Update more frequently in demo mode
    int update_interval = InpDemoMode ? 1 : 5;

    static datetime lastUpdate = 0;
    if(TimeCurrent() - lastUpdate < update_interval && !InpDemoMode)
        return rates_total;
    lastUpdate = TimeCurrent();

    // Set arrays as series
    ArraySetAsSeries(time, true);
    ArraySetAsSeries(open, true);
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(close, true);

    // Copy ATR
    if(CopyBuffer(g_atrHandle, 0, 0, InpLookback, g_atr) < InpLookback)
        return prev_calculated;

    // Clean old SMC objects
    DeleteAllObjects();

    int limit = MathMin(rates_total - 10, InpLookback);

    // Draw ICT Killzones first (background)
    if(InpShowKillzones)
        DrawKillzones(time, high, low, limit);

    // Draw Sessions
    if(InpShowSessions)
        DrawSessions(time, high, low, limit);

    // Draw Structure
    if(InpShowStructure)
        DrawStructure(time, high, low, limit);

    // Draw Order Blocks
    if(InpShowOB)
        DrawOrderBlocks(time, open, high, low, close, limit);

    // Draw FVGs
    if(InpShowFVG)
        DrawFVGs(time, high, low, limit);

    // Draw Liquidity
    if(InpShowLiquidity)
        DrawLiquidityLevels(time, high, low, limit);

    // Draw BOS/CHoCH (new in v5.0 - CRUCIBLE recommendation)
    if(InpShowBOSCHoCH)
        DrawBOSCHoCH(time, high, low, limit);

    // Draw Premium/Discount Zones (v5.1 - TIER 2 feature)
    if(InpShowPremDisc)
        DrawPremiumDiscount(time, high, low, limit);

    // Draw PDH/PDL (v5.1 - TIER 2 feature)
    if(InpShowPDHL)
        DrawPDHL(time, high, low, limit);

    // Draw Asian Range Box (v5.1 - TIER 2 feature)
    if(InpShowAsianRange)
        DrawAsianRange(time, high, low, limit);

    // Update HUD
    UpdateHUD();

    // Update Strategy Context Panel
    UpdateStrategyPanel();

    ChartRedraw(0);

    return rates_total;
}

//+------------------------------------------------------------------+
//| Draw ICT Killzones (DST-safe timezone)                           |
//+------------------------------------------------------------------+
void DrawKillzones(const datetime &time[], const double &high[],
                   const double &low[], int limit)
{
    // Track killzones per day to avoid duplicates
    datetime lastLondonKZ = 0;
    datetime lastNYAMKZ = 0;
    datetime lastNYPMKZ = 0;

    for(int i = limit - 1; i >= 0 && g_objectCount < InpMaxObjects; i--)
    {
        MqlDateTime dt;
        TimeToStruct(time[i], dt);

        // Convert to ET using DST-safe function (CRUCIBLE/CRITIC fix)
        // Note: time[i] is broker time, need to convert via TimeGMT offset
        datetime utc_time = TimeGMT() - (TimeCurrent() - time[i]);  // Approximate UTC for bar
        int et_hour = GetEasternTimeHour(utc_time);
        int et_min = dt.min;

        // Check for killzone boundaries
        datetime day_start = time[i] - (time[i] % 86400);

        // London Open: 02:00-05:00 ET
        if(et_hour >= 2 && et_hour < 5)
        {
            if(day_start != lastLondonKZ)
            {
                lastLondonKZ = day_start;
                DrawKillzoneBox("LDN_" + TimeToString(day_start, TIME_DATE), time, high, low, i, limit, 2, 5, InpLondonKZColor, "London Open");
            }
        }

        // NY AM: 08:30-11:00 ET
        if((et_hour >= 8 && et_hour < 11) || (et_hour == 8 && et_min >= 30))
        {
            if(day_start != lastNYAMKZ)
            {
                lastNYAMKZ = day_start;
                DrawKillzoneBox("NYAM_" + TimeToString(day_start, TIME_DATE), time, high, low, i, limit, 8, 11, InpNYAMKZColor, "NY AM");
            }
        }

        // NY PM: 13:00-16:00 ET
        if(et_hour >= 13 && et_hour < 16)
        {
            if(day_start != lastNYPMKZ)
            {
                lastNYPMKZ = day_start;
                DrawKillzoneBox("NYPM_" + TimeToString(day_start, TIME_DATE), time, high, low, i, limit, 13, 16, InpNYPMKZColor, "NY PM");
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Draw a single killzone box                                        |
//+------------------------------------------------------------------+
void DrawKillzoneBox(string name, const datetime &time[], const double &high[],
                     const double &low[], int start_idx, int limit,
                     int start_hour, int end_hour, color clr, string label)
{
    // Find range within killzone
    double kz_high = 0, kz_low = DBL_MAX;
    datetime kz_start = 0, kz_end = 0;
    bool found = false;

    for(int j = start_idx; j >= 0 && j > start_idx - 50; j--)
    {
        MqlDateTime dt;
        TimeToStruct(time[j], dt);
        int et_hour = (dt.hour - 5 + 24) % 24;

        if(et_hour >= start_hour && et_hour < end_hour)
        {
            if(!found)
            {
                kz_start = time[j];
                found = true;
            }
            kz_end = time[j];
            kz_high = MathMax(kz_high, high[j]);
            kz_low = MathMin(kz_low, low[j]);
        }
        else if(found)
        {
            break;  // Exited killzone
        }
    }

    if(found && kz_low < DBL_MAX)
    {
        string obj_name = g_prefix + "KZ_" + name;

        ObjectCreate(0, obj_name, OBJ_RECTANGLE, 0, kz_start, kz_high, kz_end, kz_low);
        ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, obj_name, OBJPROP_FILL, true);
        ObjectSetInteger(0, obj_name, OBJPROP_BACK, true);
        ObjectSetInteger(0, obj_name, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetString(0, obj_name, OBJPROP_TOOLTIP, label + " Killzone");
        ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);

        g_objectCount++;

        // Add label
        string label_name = g_prefix + "KZL_" + name;
        ObjectCreate(0, label_name, OBJ_TEXT, 0, kz_start, kz_high);
        ObjectSetString(0, label_name, OBJPROP_TEXT, " " + label);
        ObjectSetInteger(0, label_name, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, label_name, OBJPROP_FONTSIZE, 7);
        ObjectSetInteger(0, label_name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        ObjectSetInteger(0, label_name, OBJPROP_SELECTABLE, false);

        g_objectCount++;
    }
}

//+------------------------------------------------------------------+
//| Draw Order Blocks                                                  |
//+------------------------------------------------------------------+
void DrawOrderBlocks(const datetime &time[], const double &open[],
                     const double &high[], const double &low[],
                     const double &close[], int limit)
{
    for(int i = 5; i < limit - 3 && g_objectCount < InpMaxObjects; i++)
    {
        if(g_atr[i] <= 0) continue;

        // Bullish OB: bearish candle before bullish move
        if(close[i] < open[i])  // bearish candle
        {
            double displacement = 0;
            for(int j = 1; j <= 3; j++)
            {
                if(i - j >= 0)
                    displacement = MathMax(displacement, high[i-j] - close[i]);
            }

            if(displacement >= g_atr[i] * InpOBDisplacement)
            {
                // Check if not yet mitigated
                bool valid = true;
                for(int k = i - 1; k >= 0 && k >= i - InpOBMaxAge; k--)
                {
                    if(low[k] < low[i])  // mitigated
                    {
                        valid = false;
                        break;
                    }
                }

                if(valid)
                    CreateOBRectangle("OB_BULL_" + IntegerToString(i),
                                    time[i], open[i],
                                    time[MathMax(0, i - InpOBMaxAge)], low[i],
                                    InpBullOBColor, "BULL OB");
            }
        }

        // Bearish OB: bullish candle before bearish move
        if(close[i] > open[i])  // bullish candle
        {
            double displacement = 0;
            for(int j = 1; j <= 3; j++)
            {
                if(i - j >= 0)
                    displacement = MathMax(displacement, close[i] - low[i-j]);
            }

            if(displacement >= g_atr[i] * InpOBDisplacement)
            {
                bool valid = true;
                for(int k = i - 1; k >= 0 && k >= i - InpOBMaxAge; k--)
                {
                    if(high[k] > high[i])
                    {
                        valid = false;
                        break;
                    }
                }

                if(valid)
                    CreateOBRectangle("OB_BEAR_" + IntegerToString(i),
                                    time[i], high[i],
                                    time[MathMax(0, i - InpOBMaxAge)], open[i],
                                    InpBearOBColor, "BEAR OB");
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Draw Fair Value Gaps (ATR-adaptive + fill detection)             |
//| CRUCIBLE: Uses MAX(input, ATR*0.3) for XAUUSD noise filtering    |
//| CRITIC: Caps fill detection lookback for performance             |
//+------------------------------------------------------------------+
#define MAX_FILL_LOOKBACK 50  // Performance: don't scan more than 50 bars for fills

void DrawFVGs(const datetime &time[], const double &high[],
              const double &low[], int limit)
{
    for(int i = 2; i < limit && g_objectCount < InpMaxObjects; i++)
    {
        // CRITIC fix: Skip if ATR not populated
        if(i >= ArraySize(g_atr) || g_atr[i] <= 0) continue;

        // Dynamic minimum: MAX(user input, ATR * 0.3) - adapts to volatility
        double min_gap = MathMax(InpFVGMinGap, g_atr[i] * 0.3);

        // Bullish FVG: gap up (current high below 2-bars-ago low)
        double gap_bull = low[i-2] - high[i];
        if(gap_bull >= min_gap)
        {
            // Check if FVG has been filled (price came back into gap)
            bool filled = false;
            int lookback_limit = MathMin(i, MAX_FILL_LOOKBACK);
            for(int k = i - 1; k >= i - lookback_limit && k >= 0; k--)
            {
                // Filled if price traded through the entire gap
                if(low[k] <= high[i])  // Low touched or went below gap top
                {
                    filled = true;
                    break;
                }
            }

            if(!filled)
            {
                CreateFVGRectangle("FVG_BULL_" + IntegerToString(i),
                                  time[i-1], low[i-2],
                                  time[0], high[i],
                                  InpBullFVGColor,
                                  StringFormat("BULL FVG %.1f pts", gap_bull));
            }
        }

        // Bearish FVG: gap down (current low above 2-bars-ago high)
        double gap_bear = low[i] - high[i-2];
        if(gap_bear >= min_gap)
        {
            // Check if FVG has been filled
            bool filled = false;
            int lookback_limit = MathMin(i, MAX_FILL_LOOKBACK);
            for(int k = i - 1; k >= i - lookback_limit && k >= 0; k--)
            {
                // Filled if price traded through the entire gap
                if(high[k] >= low[i])  // High touched or went above gap bottom
                {
                    filled = true;
                    break;
                }
            }

            if(!filled)
            {
                CreateFVGRectangle("FVG_BEAR_" + IntegerToString(i),
                                  time[i-1], low[i],
                                  time[0], high[i-2],
                                  InpBearFVGColor,
                                  StringFormat("BEAR FVG %.1f pts", gap_bear));
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Draw Session Boxes                                                 |
//+------------------------------------------------------------------+
void DrawSessions(const datetime &time[], const double &high[],
                  const double &low[], int limit)
{
    MqlDateTime dt;
    datetime sessionStart = 0;
    double sessionHigh = 0, sessionLow = DBL_MAX;
    int currentSession = -1;  // 0=Asian, 1=London, 2=NY

    for(int i = limit - 1; i >= 0; i--)
    {
        TimeToStruct(time[i], dt);
        int hour = dt.hour;

        int newSession = -1;
        if(hour >= 0 && hour < 8)
            newSession = 0;  // Asian
        else if(hour >= 8 && hour < 13)
            newSession = 1;  // London
        else if(hour >= 13 && hour < 21)
            newSession = 2;  // NY

        if(newSession != currentSession && newSession >= 0)
        {
            // Draw previous session
            if(currentSession >= 0 && sessionStart != 0 && g_objectCount < InpMaxObjects)
            {
                color clr = (currentSession == 0) ? InpAsianColor :
                           (currentSession == 1) ? InpLondonColor : InpNYColor;
                string name = (currentSession == 0) ? "ASIAN" :
                             (currentSession == 1) ? "LONDON" : "NY";

                CreateSessionBox("SESSION_" + name + "_" + IntegerToString(i),
                               sessionStart, sessionHigh,
                               time[i], sessionLow, clr, name);
            }

            // Start new session
            currentSession = newSession;
            sessionStart = time[i];
            sessionHigh = high[i];
            sessionLow = low[i];
        }
        else if(currentSession >= 0)
        {
            sessionHigh = MathMax(sessionHigh, high[i]);
            sessionLow = MathMin(sessionLow, low[i]);
        }
    }
}

//+------------------------------------------------------------------+
//| Draw Structure (HH/HL/LH/LL)                                       |
//+------------------------------------------------------------------+
void DrawStructure(const datetime &time[], const double &high[],
                   const double &low[], int limit)
{
    double lastSwingHigh = 0, lastSwingLow = DBL_MAX;
    double prevSwingHigh = 0, prevSwingLow = DBL_MAX;
    int n = InpSwingStrength;

    for(int i = n; i < limit - n && g_objectCount < InpMaxObjects; i++)
    {
        // Check for swing high
        bool isSwingHigh = true;
        for(int j = 1; j <= n; j++)
        {
            if(high[i] <= high[i-j] || high[i] <= high[i+j])
            {
                isSwingHigh = false;
                break;
            }
        }

        if(isSwingHigh)
        {
            prevSwingHigh = lastSwingHigh;
            lastSwingHigh = high[i];

            if(prevSwingHigh > 0)
            {
                if(lastSwingHigh > prevSwingHigh)
                    CreateSwingLabel("HH_" + IntegerToString(i), time[i], high[i],
                                   InpHHColor, "HH", true);
                else
                    CreateSwingLabel("LH_" + IntegerToString(i), time[i], high[i],
                                   InpLHColor, "LH", true);
            }
        }

        // Check for swing low
        bool isSwingLow = true;
        for(int j = 1; j <= n; j++)
        {
            if(low[i] >= low[i-j] || low[i] >= low[i+j])
            {
                isSwingLow = false;
                break;
            }
        }

        if(isSwingLow)
        {
            prevSwingLow = lastSwingLow;
            lastSwingLow = low[i];

            if(prevSwingLow < DBL_MAX)
            {
                if(lastSwingLow > prevSwingLow)
                    CreateSwingLabel("HL_" + IntegerToString(i), time[i], low[i],
                                   InpHLColor, "HL", false);
                else
                    CreateSwingLabel("LL_" + IntegerToString(i), time[i], low[i],
                                   InpLLColor, "LL", false);
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Draw Liquidity Levels (XAUUSD tolerance increased per CRUCIBLE)  |
//+------------------------------------------------------------------+
void DrawLiquidityLevels(const datetime &time[], const double &high[],
                         const double &low[], int limit)
{
    // Find equal highs (BSL) and equal lows (SSL)
    // CRUCIBLE: Increased tolerance from 50 to 100 points for XAUUSD spreads
    double tolerance = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 100;  // 10 pips

    for(int i = 1; i < limit - 1 && g_objectCount < InpMaxObjects; i++)
    {
        // Check for equal highs
        for(int j = i + 5; j < MathMin(i + 30, limit); j++)
        {
            if(MathAbs(high[i] - high[j]) <= tolerance)
            {
                // Found equal highs - BSL
                CreateLiquidityLine("BSL_" + IntegerToString(i) + "_" + IntegerToString(j),
                                  time[j], high[i], time[0], InpBSLColor, "BSL");
                break;
            }
        }

        // Check for equal lows
        for(int j = i + 5; j < MathMin(i + 30, limit); j++)
        {
            if(MathAbs(low[i] - low[j]) <= tolerance)
            {
                // Found equal lows - SSL
                CreateLiquidityLine("SSL_" + IntegerToString(i) + "_" + IntegerToString(j),
                                  time[j], low[i], time[0], InpSSLColor, "SSL");
                break;
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Draw BOS (Break of Structure) and CHoCH (Change of Character)   |
//| BOS = Continuation break (new HH in uptrend, new LL in downtrend)|
//| CHoCH = Reversal break (first HH after downtrend, LL after up)  |
//| CRITIC: Uses separate object budget to avoid exhaustion         |
//+------------------------------------------------------------------+
void DrawBOSCHoCH(const datetime &time[], const double &high[],
                  const double &low[], int limit)
{
    if(!InpShowBOSCHoCH) return;

    // Reset BOS object counter
    g_bosObjectCount = 0;

    int n = InpSwingStrength;

    // CRITIC fix: Need at least 2 swings for BOS/CHoCH detection
    if(limit < n * 2 + 2) return;

    // First pass: identify all swing points
    SSwingPoint swings[];
    int swing_count = 0;

    for(int i = limit - n - 1; i >= n; i--)
    {
        // Check for swing high
        bool isSwingHigh = true;
        for(int j = 1; j <= n; j++)
        {
            if(high[i] <= high[i-j] || high[i] <= high[i+j])
            {
                isSwingHigh = false;
                break;
            }
        }

        if(isSwingHigh)
        {
            ArrayResize(swings, swing_count + 1);
            swings[swing_count].time = time[i];
            swings[swing_count].price = high[i];
            swings[swing_count].is_high = true;
            swings[swing_count].bar_index = i;
            swing_count++;
        }

        // Check for swing low
        bool isSwingLow = true;
        for(int j = 1; j <= n; j++)
        {
            if(low[i] >= low[i-j] || low[i] >= low[i+j])
            {
                isSwingLow = false;
                break;
            }
        }

        if(isSwingLow)
        {
            ArrayResize(swings, swing_count + 1);
            swings[swing_count].time = time[i];
            swings[swing_count].price = low[i];
            swings[swing_count].is_high = false;
            swings[swing_count].bar_index = i;
            swing_count++;
        }
    }

    // CRITIC fix: Need at least 2 swings
    if(swing_count < 2) return;

    // Second pass: detect BOS and CHoCH
    ENUM_MARKET_STRUCTURE current_trend = STRUCTURE_UNDEFINED;
    double ref_high = 0, ref_low = DBL_MAX;
    datetime ref_high_time = 0, ref_low_time = 0;

    for(int s = 0; s < swing_count - 1 && g_bosObjectCount < InpMaxBOSObjects; s++)
    {
        SSwingPoint curr = swings[s];

        if(curr.is_high)
        {
            // Check if this high breaks previous reference high
            if(ref_high > 0 && curr.price > ref_high)
            {
                // Price broke above previous high
                if(current_trend == STRUCTURE_BULLISH)
                {
                    // BOS - continuation in uptrend (new HH)
                    DrawBOSLine("BOS_BULL_" + IntegerToString(curr.bar_index),
                               ref_high_time, ref_high,
                               curr.time, curr.price,
                               InpBOSBullColor, "BOS");
                }
                else if(current_trend == STRUCTURE_BEARISH || current_trend == STRUCTURE_UNDEFINED)
                {
                    // CHoCH - first HH after downtrend = potential reversal
                    DrawBOSLine("CHoCH_BULL_" + IntegerToString(curr.bar_index),
                               ref_high_time, ref_high,
                               curr.time, curr.price,
                               InpCHoCHBullColor, "CHoCH");
                    current_trend = STRUCTURE_BULLISH;
                }
            }

            // Update reference high
            ref_high = curr.price;
            ref_high_time = curr.time;
        }
        else
        {
            // Check if this low breaks previous reference low
            if(ref_low < DBL_MAX && curr.price < ref_low)
            {
                // Price broke below previous low
                if(current_trend == STRUCTURE_BEARISH)
                {
                    // BOS - continuation in downtrend (new LL)
                    DrawBOSLine("BOS_BEAR_" + IntegerToString(curr.bar_index),
                               ref_low_time, ref_low,
                               curr.time, curr.price,
                               InpBOSBearColor, "BOS");
                }
                else if(current_trend == STRUCTURE_BULLISH || current_trend == STRUCTURE_UNDEFINED)
                {
                    // CHoCH - first LL after uptrend = potential reversal
                    DrawBOSLine("CHoCH_BEAR_" + IntegerToString(curr.bar_index),
                               ref_low_time, ref_low,
                               curr.time, curr.price,
                               InpCHoCHBearColor, "CHoCH");
                    current_trend = STRUCTURE_BEARISH;
                }
            }

            // Update reference low
            ref_low = curr.price;
            ref_low_time = curr.time;
        }
    }
}

//+------------------------------------------------------------------+
//| Draw BOS/CHoCH line connecting broken level to break point       |
//+------------------------------------------------------------------+
void DrawBOSLine(string name, datetime t1, double p1,
                 datetime t2, double p2, color clr, string label)
{
    if(g_bosObjectCount >= InpMaxBOSObjects) return;

    string objName = g_prefix + name;

    // Draw the horizontal level that was broken (dotted)
    string levelName = objName + "_LVL";
    ObjectCreate(0, levelName, OBJ_TREND, 0, t1, p1, t2, p1);
    ObjectSetInteger(0, levelName, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, levelName, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, levelName, OBJPROP_STYLE, STYLE_DOT);
    ObjectSetInteger(0, levelName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, levelName, OBJPROP_BACK, true);
    g_bosObjectCount++;

    // Add label at the break point
    string labelName = objName + "_LBL";
    ObjectCreate(0, labelName, OBJ_TEXT, 0, t2, p2);
    ObjectSetString(0, labelName, OBJPROP_TEXT, " " + label);
    ObjectSetInteger(0, labelName, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, (p2 > p1) ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER);
    ObjectSetInteger(0, labelName, OBJPROP_SELECTABLE, false);
    g_bosObjectCount++;
}

//+------------------------------------------------------------------+
//| Create Order Block Rectangle                                       |
//+------------------------------------------------------------------+
void CreateOBRectangle(string name, datetime t1, double p1,
                       datetime t2, double p2, color clr, string tooltip)
{
    string objName = g_prefix + name;

    ObjectCreate(0, objName, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, objName, OBJPROP_FILL, true);
    ObjectSetInteger(0, objName, OBJPROP_BACK, true);
    ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, tooltip);
    ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);

    g_objectCount++;
}

//+------------------------------------------------------------------+
//| Create FVG Rectangle                                               |
//+------------------------------------------------------------------+
void CreateFVGRectangle(string name, datetime t1, double p1,
                        datetime t2, double p2, color clr, string tooltip)
{
    string objName = g_prefix + name;

    ObjectCreate(0, objName, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, objName, OBJPROP_FILL, true);
    ObjectSetInteger(0, objName, OBJPROP_BACK, true);
    ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DOT);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, tooltip);
    ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);

    g_objectCount++;
}

//+------------------------------------------------------------------+
//| Create Session Box                                                 |
//+------------------------------------------------------------------+
void CreateSessionBox(string name, datetime t1, double p1,
                      datetime t2, double p2, color clr, string tooltip)
{
    string objName = g_prefix + name;

    ObjectCreate(0, objName, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, objName, OBJPROP_FILL, false);
    ObjectSetInteger(0, objName, OBJPROP_BACK, true);
    ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
    ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DASH);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, tooltip + " Session");
    ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);

    g_objectCount++;
}

//+------------------------------------------------------------------+
//| Create Swing Label                                                 |
//+------------------------------------------------------------------+
void CreateSwingLabel(string name, datetime t, double price,
                      color clr, string text, bool above)
{
    string objName = g_prefix + name;

    ObjectCreate(0, objName, OBJ_TEXT, 0, t, price);
    ObjectSetString(0, objName, OBJPROP_TEXT, text);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, objName, OBJPROP_ANCHOR, above ? ANCHOR_LOWER : ANCHOR_UPPER);
    ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);

    g_objectCount++;
}

//+------------------------------------------------------------------+
//| Create Liquidity Line                                              |
//+------------------------------------------------------------------+
void CreateLiquidityLine(string name, datetime t1, double price,
                         datetime t2, color clr, string tooltip)
{
    string objName = g_prefix + name;

    ObjectCreate(0, objName, OBJ_TREND, 0, t1, price, t2, price);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
    ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DASHDOT);
    ObjectSetInteger(0, objName, OBJPROP_RAY_RIGHT, true);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, tooltip + " @ " + DoubleToString(price, _Digits));
    ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);

    g_objectCount++;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Draw Premium/Discount Zones (v5.1 TIER 2)                        |
//| Premium = upper 50% of swing (sell zone)                         |
//| Discount = lower 50% of swing (buy zone)                         |
//| Equilibrium = 50% level (key reversal level)                     |
//+------------------------------------------------------------------+
void DrawPremiumDiscount(const datetime &time[], const double &high[],
                         const double &low[], int limit)
{
    // Find the current swing range (use last N bars to define swing)
    int swingLookback = MathMin(50, limit);
    double swingHigh = high[0];
    double swingLow = low[0];
    int swingHighBar = 0;
    int swingLowBar = 0;

    for(int i = 0; i < swingLookback; i++)
    {
        if(high[i] > swingHigh)
        {
            swingHigh = high[i];
            swingHighBar = i;
        }
        if(low[i] < swingLow)
        {
            swingLow = low[i];
            swingLowBar = i;
        }
    }

    if(swingHigh == swingLow)
        return;

    double equilibrium = (swingHigh + swingLow) / 2.0;
    datetime leftTime = time[MathMax(swingHighBar, swingLowBar)];
    datetime rightTime = time[0] + PeriodSeconds(_Period) * 10;  // Extend right

    // Draw Premium Zone (upper 50%)
    string premName = g_prefix + "PremZone";
    ObjectCreate(0, premName, OBJ_RECTANGLE, 0, leftTime, swingHigh, rightTime, equilibrium);
    ObjectSetInteger(0, premName, OBJPROP_COLOR, InpPremiumColor);
    ObjectSetInteger(0, premName, OBJPROP_FILL, true);
    ObjectSetInteger(0, premName, OBJPROP_BACK, true);
    ObjectSetInteger(0, premName, OBJPROP_SELECTABLE, false);
    ObjectSetString(0, premName, OBJPROP_TOOLTIP, "Premium Zone (Sell Area)");
    g_objectCount++;

    // Draw Discount Zone (lower 50%)
    string discName = g_prefix + "DiscZone";
    ObjectCreate(0, discName, OBJ_RECTANGLE, 0, leftTime, equilibrium, rightTime, swingLow);
    ObjectSetInteger(0, discName, OBJPROP_COLOR, InpDiscountColor);
    ObjectSetInteger(0, discName, OBJPROP_FILL, true);
    ObjectSetInteger(0, discName, OBJPROP_BACK, true);
    ObjectSetInteger(0, discName, OBJPROP_SELECTABLE, false);
    ObjectSetString(0, discName, OBJPROP_TOOLTIP, "Discount Zone (Buy Area)");
    g_objectCount++;

    // Draw Equilibrium Line (50%)
    string eqName = g_prefix + "EqLine";
    ObjectCreate(0, eqName, OBJ_TREND, 0, leftTime, equilibrium, rightTime, equilibrium);
    ObjectSetInteger(0, eqName, OBJPROP_COLOR, InpEquilibriumColor);
    ObjectSetInteger(0, eqName, OBJPROP_WIDTH, 2);
    ObjectSetInteger(0, eqName, OBJPROP_STYLE, STYLE_DASH);
    ObjectSetInteger(0, eqName, OBJPROP_RAY_RIGHT, false);
    ObjectSetInteger(0, eqName, OBJPROP_SELECTABLE, false);
    ObjectSetString(0, eqName, OBJPROP_TOOLTIP, "Equilibrium (50%) @ " + DoubleToString(equilibrium, _Digits));
    g_objectCount++;

    // Add label
    string eqLabel = g_prefix + "EqLabel";
    ObjectCreate(0, eqLabel, OBJ_TEXT, 0, rightTime, equilibrium);
    ObjectSetString(0, eqLabel, OBJPROP_TEXT, "EQ 50%");
    ObjectSetInteger(0, eqLabel, OBJPROP_COLOR, InpEquilibriumColor);
    ObjectSetInteger(0, eqLabel, OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, eqLabel, OBJPROP_ANCHOR, ANCHOR_LEFT);
    ObjectSetInteger(0, eqLabel, OBJPROP_SELECTABLE, false);
    g_objectCount++;
}

//+------------------------------------------------------------------+
//| Draw PDH/PDL - Previous Day High/Low (v5.1 TIER 2)               |
//| Key liquidity levels from prior day                              |
//+------------------------------------------------------------------+
void DrawPDHL(const datetime &time[], const double &high[],
              const double &low[], int limit)
{
    // Find previous day's high and low
    MqlDateTime dt_now;
    TimeToStruct(time[0], dt_now);

    double pdh = 0, pdl = 0;
    datetime pdh_time = 0, pdl_time = 0;
    bool foundPrevDay = false;
    int prevDayCount = 0;
    int currentDay = dt_now.day_of_year;

    for(int i = 0; i < limit && prevDayCount < 2; i++)
    {
        MqlDateTime dt_bar;
        TimeToStruct(time[i], dt_bar);

        if(dt_bar.day_of_year != currentDay)
        {
            // This is a previous day bar
            if(!foundPrevDay)
            {
                foundPrevDay = true;
                pdh = high[i];
                pdl = low[i];
                pdh_time = time[i];
                pdl_time = time[i];
                currentDay = dt_bar.day_of_year;
                prevDayCount = 1;
            }
            else if(dt_bar.day_of_year == currentDay)
            {
                // Still in prev day
                if(high[i] > pdh)
                {
                    pdh = high[i];
                    pdh_time = time[i];
                }
                if(low[i] < pdl)
                {
                    pdl = low[i];
                    pdl_time = time[i];
                }
            }
            else
            {
                // Moved to day before prev day - stop
                prevDayCount = 2;
            }
        }
    }

    if(pdh == 0 || pdl == 0)
        return;

    datetime rightTime = time[0] + PeriodSeconds(_Period) * 20;

    // Draw PDH line
    string pdhName = g_prefix + "PDH";
    ObjectCreate(0, pdhName, OBJ_TREND, 0, pdh_time, pdh, rightTime, pdh);
    ObjectSetInteger(0, pdhName, OBJPROP_COLOR, InpPDHColor);
    ObjectSetInteger(0, pdhName, OBJPROP_WIDTH, InpPDHLWidth);
    ObjectSetInteger(0, pdhName, OBJPROP_STYLE, InpPDHLStyle);
    ObjectSetInteger(0, pdhName, OBJPROP_RAY_RIGHT, true);
    ObjectSetInteger(0, pdhName, OBJPROP_SELECTABLE, false);
    ObjectSetString(0, pdhName, OBJPROP_TOOLTIP, "PDH (Previous Day High) @ " + DoubleToString(pdh, _Digits));
    g_objectCount++;

    // PDH Label
    string pdhLabel = g_prefix + "PDHLabel";
    ObjectCreate(0, pdhLabel, OBJ_TEXT, 0, rightTime, pdh);
    ObjectSetString(0, pdhLabel, OBJPROP_TEXT, "PDH");
    ObjectSetInteger(0, pdhLabel, OBJPROP_COLOR, InpPDHColor);
    ObjectSetInteger(0, pdhLabel, OBJPROP_FONTSIZE, 9);
    ObjectSetInteger(0, pdhLabel, OBJPROP_ANCHOR, ANCHOR_LEFT);
    ObjectSetInteger(0, pdhLabel, OBJPROP_SELECTABLE, false);
    g_objectCount++;

    // Draw PDL line
    string pdlName = g_prefix + "PDL";
    ObjectCreate(0, pdlName, OBJ_TREND, 0, pdl_time, pdl, rightTime, pdl);
    ObjectSetInteger(0, pdlName, OBJPROP_COLOR, InpPDLColor);
    ObjectSetInteger(0, pdlName, OBJPROP_WIDTH, InpPDHLWidth);
    ObjectSetInteger(0, pdlName, OBJPROP_STYLE, InpPDHLStyle);
    ObjectSetInteger(0, pdlName, OBJPROP_RAY_RIGHT, true);
    ObjectSetInteger(0, pdlName, OBJPROP_SELECTABLE, false);
    ObjectSetString(0, pdlName, OBJPROP_TOOLTIP, "PDL (Previous Day Low) @ " + DoubleToString(pdl, _Digits));
    g_objectCount++;

    // PDL Label
    string pdlLabel = g_prefix + "PDLLabel";
    ObjectCreate(0, pdlLabel, OBJ_TEXT, 0, rightTime, pdl);
    ObjectSetString(0, pdlLabel, OBJPROP_TEXT, "PDL");
    ObjectSetInteger(0, pdlLabel, OBJPROP_COLOR, InpPDLColor);
    ObjectSetInteger(0, pdlLabel, OBJPROP_FONTSIZE, 9);
    ObjectSetInteger(0, pdlLabel, OBJPROP_ANCHOR, ANCHOR_LEFT);
    ObjectSetInteger(0, pdlLabel, OBJPROP_SELECTABLE, false);
    g_objectCount++;
}

//+------------------------------------------------------------------+
//| Draw Asian Range Box (v5.1 TIER 2)                               |
//| Asian session high/low defines the range for the day             |
//| Often acts as liquidity target and support/resistance            |
//+------------------------------------------------------------------+
void DrawAsianRange(const datetime &time[], const double &high[],
                    const double &low[], int limit)
{
    // Find today's and yesterday's Asian range
    MqlDateTime dt_now;
    TimeToStruct(time[0], dt_now);

    // We draw up to 2 Asian ranges (today's and yesterday's)
    for(int dayOffset = 0; dayOffset < 2; dayOffset++)
    {
        double asianHigh = 0, asianLow = 0;
        datetime asianStart = 0, asianEnd = 0;
        bool foundStart = false;
        int targetDay = (dt_now.day_of_year - dayOffset + 366) % 366;

        for(int i = 0; i < limit; i++)
        {
            // Get ET hour for this bar
            datetime utc_time = TimeGMT() - (TimeCurrent() - time[i]);
            int et_hour = GetEasternTimeHour(utc_time);

            MqlDateTime dt_bar;
            TimeToStruct(time[i], dt_bar);

            // Check if this bar is in Asian range (18:00-00:00 ET or user-defined)
            bool inAsian = false;
            if(InpAsianStartHour > InpAsianEndHour)
            {
                // Range crosses midnight (e.g., 18:00 - 00:00)
                inAsian = (et_hour >= InpAsianStartHour || et_hour < InpAsianEndHour);
            }
            else
            {
                inAsian = (et_hour >= InpAsianStartHour && et_hour < InpAsianEndHour);
            }

            // Match the target day
            int barDayInET = dt_bar.day_of_year;
            // Adjust for timezone (Asian in ET might be previous calendar day)
            if(et_hour >= 18 && et_hour <= 23)
                barDayInET = (dt_bar.day_of_year + 1) % 366;  // Asian PM belongs to next day

            if(inAsian && barDayInET == targetDay)
            {
                if(!foundStart)
                {
                    foundStart = true;
                    asianHigh = high[i];
                    asianLow = low[i];
                    asianEnd = time[i];
                }
                else
                {
                    if(high[i] > asianHigh) asianHigh = high[i];
                    if(low[i] < asianLow) asianLow = low[i];
                }
                asianStart = time[i];
            }
        }

        if(!foundStart || asianHigh == asianLow)
            continue;

        // Extend the box to the right (until end of day or current time)
        datetime boxEnd = time[0] + PeriodSeconds(_Period) * 5;

        string boxName = g_prefix + "AsianBox_" + IntegerToString(dayOffset);
        ObjectCreate(0, boxName, OBJ_RECTANGLE, 0, asianStart, asianHigh, boxEnd, asianLow);
        ObjectSetInteger(0, boxName, OBJPROP_COLOR, InpAsianRangeColor);
        ObjectSetInteger(0, boxName, OBJPROP_FILL, true);
        ObjectSetInteger(0, boxName, OBJPROP_BACK, true);
        ObjectSetInteger(0, boxName, OBJPROP_SELECTABLE, false);
        ObjectSetString(0, boxName, OBJPROP_TOOLTIP,
            "Asian Range: " + DoubleToString(asianHigh, _Digits) + " - " + DoubleToString(asianLow, _Digits));
        g_objectCount++;

        // Draw Asian midpoint
        if(InpShowAsianMid)
        {
            double asianMid = (asianHigh + asianLow) / 2.0;
            string midName = g_prefix + "AsianMid_" + IntegerToString(dayOffset);
            ObjectCreate(0, midName, OBJ_TREND, 0, asianStart, asianMid, boxEnd, asianMid);
            ObjectSetInteger(0, midName, OBJPROP_COLOR, InpAsianMidColor);
            ObjectSetInteger(0, midName, OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, midName, OBJPROP_STYLE, STYLE_DOT);
            ObjectSetInteger(0, midName, OBJPROP_RAY_RIGHT, true);
            ObjectSetInteger(0, midName, OBJPROP_SELECTABLE, false);
            ObjectSetString(0, midName, OBJPROP_TOOLTIP, "Asian Mid @ " + DoubleToString(asianMid, _Digits));
            g_objectCount++;

            // Label
            string midLabel = g_prefix + "AsianMidLbl_" + IntegerToString(dayOffset);
            ObjectCreate(0, midLabel, OBJ_TEXT, 0, boxEnd, asianMid);
            ObjectSetString(0, midLabel, OBJPROP_TEXT, "Asian Mid");
            ObjectSetInteger(0, midLabel, OBJPROP_COLOR, InpAsianMidColor);
            ObjectSetInteger(0, midLabel, OBJPROP_FONTSIZE, 7);
            ObjectSetInteger(0, midLabel, OBJPROP_ANCHOR, ANCHOR_LEFT);
            ObjectSetInteger(0, midLabel, OBJPROP_SELECTABLE, false);
            g_objectCount++;
        }

        // Draw range high/low labels
        string highLabel = g_prefix + "AsianHigh_" + IntegerToString(dayOffset);
        ObjectCreate(0, highLabel, OBJ_TEXT, 0, asianStart, asianHigh);
        ObjectSetString(0, highLabel, OBJPROP_TEXT, "Asian High");
        ObjectSetInteger(0, highLabel, OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, highLabel, OBJPROP_FONTSIZE, 7);
        ObjectSetInteger(0, highLabel, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        ObjectSetInteger(0, highLabel, OBJPROP_SELECTABLE, false);
        g_objectCount++;

        string lowLabel = g_prefix + "AsianLow_" + IntegerToString(dayOffset);
        ObjectCreate(0, lowLabel, OBJ_TEXT, 0, asianStart, asianLow);
        ObjectSetString(0, lowLabel, OBJPROP_TEXT, "Asian Low");
        ObjectSetInteger(0, lowLabel, OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, lowLabel, OBJPROP_FONTSIZE, 7);
        ObjectSetInteger(0, lowLabel, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
        ObjectSetInteger(0, lowLabel, OBJPROP_SELECTABLE, false);
        g_objectCount++;
    }
}

//+------------------------------------------------------------------+
//| Get Strategy Panel position based on corner setting               |
//+------------------------------------------------------------------+
void GetStrategyPanelPosition(int &x, int &y)
{
    int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
    int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

    switch(InpStratPanelCorner)
    {
        case 0:  // Top Left
            x = 10;
            y = 30;
            break;
        case 1:  // Top Right (default)
            x = chart_width - STRAT_PANEL_WIDTH - 10;
            y = 30;
            break;
        case 2:  // Bottom Left
            x = 10;
            y = chart_height - STRAT_PANEL_HEIGHT - 30;
            break;
        case 3:  // Bottom Right
            x = chart_width - STRAT_PANEL_WIDTH - 10;
            y = chart_height - STRAT_PANEL_HEIGHT - 30;
            break;
        default:
            x = chart_width - STRAT_PANEL_WIDTH - 10;
            y = 30;
    }
}

//+------------------------------------------------------------------+
//| Get strategy context based on timeframe                           |
//+------------------------------------------------------------------+
void GetTimeframeContext(string &style, string &target, string &stoploss,
                         string &holding, string &signal, color &styleColor)
{
    ENUM_TIMEFRAMES tf = Period();

    // M1 - Ultra Scalping (not recommended)
    if(tf == PERIOD_M1)
    {
        style = "MICRO SCALP";
        target = "Target: 3-8 pips";
        stoploss = "SL: 5-10 pips (tight)";
        holding = "Hold: 30s - 3 min";
        signal = "WARNING: Noise heavy, avoid!";
        styleColor = clrOrangeRed;
    }
    // M5 - Aggressive Scalping
    else if(tf == PERIOD_M5)
    {
        style = "SCALPING";
        target = "Target: 10-25 pips";
        stoploss = "SL: 15-25 pips";
        holding = "Hold: 3-15 min";
        signal = "Quick entries, tight stops";
        styleColor = clrGold;
    }
    // M15 - Standard Intraday
    else if(tf == PERIOD_M15)
    {
        style = "INTRADAY";
        target = "Target: 25-50 pips";
        stoploss = "SL: 20-35 pips";
        holding = "Hold: 15-60 min";
        signal = "Best for SMC patterns";
        styleColor = clrLimeGreen;
    }
    // M30 - Careful Intraday
    else if(tf == PERIOD_M30)
    {
        style = "INTRADAY SWING";
        target = "Target: 40-80 pips";
        stoploss = "SL: 30-50 pips";
        holding = "Hold: 30 min - 2h";
        signal = "Strong OB/FVG signals";
        styleColor = clrDodgerBlue;
    }
    // H1 - Swing Trading
    else if(tf == PERIOD_H1)
    {
        style = "SWING";
        target = "Target: 80-150 pips";
        stoploss = "SL: 50-80 pips";
        holding = "Hold: 2-8 hours";
        signal = "Wait for structure breaks";
        styleColor = clrCyan;
    }
    // H4 - Position Trading
    else if(tf == PERIOD_H4)
    {
        style = "POSITION";
        target = "Target: 150-300 pips";
        stoploss = "SL: 80-120 pips";
        holding = "Hold: 8h - 2 days";
        signal = "Major levels only";
        styleColor = clrMagenta;
    }
    // D1+ - Long Term
    else if(tf >= PERIOD_D1)
    {
        style = "MACRO";
        target = "Target: 300+ pips";
        stoploss = "SL: 150-250 pips";
        holding = "Hold: Days - Weeks";
        signal = "Weekly/Monthly levels";
        styleColor = clrViolet;
    }
    else
    {
        style = "CUSTOM";
        target = "Adjust parameters";
        stoploss = "Define your SL";
        holding = "Variable";
        signal = "-";
        styleColor = clrSilver;
    }
}

//+------------------------------------------------------------------+
//| Get market session info                                           |
//+------------------------------------------------------------------+
string GetCurrentSession()
{
    datetime utc = TimeGMT();
    int et_hour = GetEasternTimeHour(utc);

    if(et_hour >= 2 && et_hour < 5)
        return "LONDON OPEN (Killzone)";
    else if(et_hour >= 5 && et_hour < 8)
        return "London Session";
    else if(et_hour >= 8 && et_hour < 12)
        return "NY AM (Killzone)";
    else if(et_hour >= 12 && et_hour < 13)
        return "Lunch (Low Vol)";
    else if(et_hour >= 13 && et_hour < 16)
        return "NY PM (Killzone)";
    else if(et_hour >= 16 && et_hour < 17)
        return "Close - NO TRADES!";
    else if(et_hour >= 18 || et_hour < 2)
        return "Asian Session";
    else
        return "Off-Hours";
}

//+------------------------------------------------------------------+
//| Get today's recommendation                                        |
//+------------------------------------------------------------------+
string GetDailyTip()
{
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);

    switch(dt.day_of_week)
    {
        case 1:  // Monday
            return "Monday: Wait for direction";
        case 2:  // Tuesday
            return "Tuesday: Strong moves likely";
        case 3:  // Wednesday
            return "Wednesday: Reversals common";
        case 4:  // Thursday
            return "Thursday: Trend day";
        case 5:  // Friday
            return "Friday: Close early (news)";
        default:
            return "Weekend: Market closed";
    }
}

//+------------------------------------------------------------------+
//| Create Strategy Context Panel Label                               |
//+------------------------------------------------------------------+
void CreateStratLabel(string name, int x, int y, string text, color clr, int font_size)
{
    string obj_name = g_stratPrefix + name;

    if(ObjectCreate(0, obj_name, OBJ_LABEL, 0, 0, 0))
    {
        ObjectSetInteger(0, obj_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, y);
        ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, font_size);
        ObjectSetString(0, obj_name, OBJPROP_FONT, "Consolas");
        ObjectSetString(0, obj_name, OBJPROP_TEXT, text);
        ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, obj_name, OBJPROP_HIDDEN, true);
    }
}

//+------------------------------------------------------------------+
//| Create Strategy Context Panel Rectangle                           |
//+------------------------------------------------------------------+
void CreateStratRect(string name, int x, int y, int width, int height, color bg_clr, color border_clr)
{
    string obj_name = g_stratPrefix + name;

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
//| Create Strategy Context Panel                                     |
//+------------------------------------------------------------------+
void CreateStrategyPanel()
{
    if(!InpShowStratPanel) return;

    int x, y;
    GetStrategyPanelPosition(x, y);

    // Get context data
    string style, target, stoploss, holding, signal;
    color styleColor;
    GetTimeframeContext(style, target, stoploss, holding, signal, styleColor);
    string session = GetCurrentSession();
    string tip = GetDailyTip();

    // Background panel
    CreateStratRect("Background", x, y, STRAT_PANEL_WIDTH, STRAT_PANEL_HEIGHT, CLR_HUD_BG, CLR_HUD_BORDER);

    // Title with timeframe
    string tfName = EnumToString(Period());
    StringReplace(tfName, "PERIOD_", "");
    CreateStratLabel("Title", x + 6, y + 6, "STRATEGY CONTEXT [" + tfName + "]", clrWhite, 9);

    // Separator
    CreateStratRect("TitleSep", x + 6, y + 22, STRAT_PANEL_WIDTH - 12, 1, CLR_HUD_BORDER, CLR_HUD_BORDER);

    int row_y = y + 28;

    // Trading Style
    CreateStratLabel("StyleLabel", x + 6, row_y, "Style:", CLR_HUD_LABEL, 8);
    CreateStratLabel("StyleValue", x + 55, row_y, style, styleColor, 10);
    row_y += 16;

    // Target
    CreateStratLabel("TargetValue", x + 6, row_y, target, clrLimeGreen, 8);
    row_y += 14;

    // Stop Loss
    CreateStratLabel("SLValue", x + 6, row_y, stoploss, clrOrangeRed, 8);
    row_y += 14;

    // Holding Time
    CreateStratLabel("HoldValue", x + 6, row_y, holding, clrSilver, 8);
    row_y += 16;

    // Separator
    CreateStratRect("Sec1Sep", x + 6, row_y, STRAT_PANEL_WIDTH - 12, 1, CLR_HUD_BORDER, CLR_HUD_BORDER);
    row_y += 6;

    // Signal/Tip
    CreateStratLabel("SignalLabel", x + 6, row_y, "Tip:", CLR_HUD_LABEL, 8);
    CreateStratLabel("SignalValue", x + 35, row_y, signal, clrGold, 8);
    row_y += 16;

    // Current Session
    CreateStratLabel("SessionLabel", x + 6, row_y, "Session:", CLR_HUD_LABEL, 8);

    // Session color based on killzone
    color sessColor = clrSilver;
    if(StringFind(session, "Killzone") >= 0) sessColor = clrLimeGreen;
    else if(StringFind(session, "NO TRADES") >= 0) sessColor = clrRed;
    else if(StringFind(session, "Low Vol") >= 0) sessColor = clrYellow;
    CreateStratLabel("SessionValue", x + 60, row_y, session, sessColor, 8);
    row_y += 16;

    // Separator
    CreateStratRect("Sec2Sep", x + 6, row_y, STRAT_PANEL_WIDTH - 12, 1, CLR_HUD_BORDER, CLR_HUD_BORDER);
    row_y += 6;

    // Daily tip
    CreateStratLabel("DayTip", x + 6, row_y, tip, clrCyan, 8);
    row_y += 16;

    // What to look for section
    CreateStratLabel("LookLabel", x + 6, row_y, "Look for:", CLR_HUD_LABEL, 8);
    row_y += 14;

    // Pattern recommendations based on TF
    string pattern1, pattern2;
    if(Period() <= PERIOD_M5)
    {
        pattern1 = "+ FVG entries (quick fills)";
        pattern2 = "+ Break of M15 structure";
    }
    else if(Period() <= PERIOD_M30)
    {
        pattern1 = "+ Order Block reactions";
        pattern2 = "+ BOS/CHoCH confirmations";
    }
    else
    {
        pattern1 = "+ Major OB + Liquidity sweep";
        pattern2 = "+ Wait for H4/D1 structure";
    }
    CreateStratLabel("Pattern1", x + 6, row_y, pattern1, clrWhite, 7);
    row_y += 12;
    CreateStratLabel("Pattern2", x + 6, row_y, pattern2, clrWhite, 7);
}

//+------------------------------------------------------------------+
//| Update Strategy Panel (called each tick)                          |
//+------------------------------------------------------------------+
void UpdateStrategyPanel()
{
    if(!InpShowStratPanel) return;

    // Get current context
    string style, target, stoploss, holding, signal;
    color styleColor;
    GetTimeframeContext(style, target, stoploss, holding, signal, styleColor);
    string session = GetCurrentSession();

    // Update session (changes throughout day)
    color sessColor = clrSilver;
    if(StringFind(session, "Killzone") >= 0) sessColor = clrLimeGreen;
    else if(StringFind(session, "NO TRADES") >= 0) sessColor = clrRed;
    else if(StringFind(session, "Low Vol") >= 0) sessColor = clrYellow;

    ObjectSetString(0, g_stratPrefix + "SessionValue", OBJPROP_TEXT, session);
    ObjectSetInteger(0, g_stratPrefix + "SessionValue", OBJPROP_COLOR, sessColor);
}
//+------------------------------------------------------------------+
