//+------------------------------------------------------------------+
//|                                                   SMC_Visual.mq5 |
//|                         FORGE v4.0 - Visual SMC Indicator        |
//|                     Order Blocks, FVG, Sessions, Structure       |
//|                     + Apex HUD, ICT Killzones, Demo Mode         |
//+------------------------------------------------------------------+
#property copyright "FORGE v4.0 - EA_SCALPER_XAUUSD"
#property link      "EA_SCALPER_XAUUSD"
#property version   "4.00"
#property description "Smart Money Concept visual indicator with Apex risk display"
#property description "Features: OB, FVG, Sessions, Structure, Liquidity, ICT Killzones"
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
input double   InpFVGMinGap       = 0.5;            // Min Gap (points)

input group "=== SESSIONS ==="
input bool     InpShowSessions    = true;           // Show Sessions
input color    InpAsianColor      = clrDarkSlateGray; // Asian Session Color
input color    InpLondonColor     = clrDarkGreen;   // London Session Color
input color    InpNYColor         = clrDarkBlue;    // NY Session Color

input group "=== ICT KILLZONES ==="
input bool     InpShowKillzones   = true;           // Show ICT Killzones
input color    InpLondonKZColor   = C'0,100,0';     // London Open (02:00-05:00 ET) - Green
input color    InpNYAMKZColor     = C'0,0,139';     // NY AM (08:30-11:00 ET) - Blue
input color    InpNYPMKZColor     = C'255,140,0';   // NY PM (13:00-16:00 ET) - Orange
input int      InpKZAlpha         = 30;             // Killzone Transparency (0-100)

input group "=== STRUCTURE ==="
input bool     InpShowStructure   = true;           // Show Structure (HH/HL/LL/LH)
input int      InpSwingStrength   = 3;              // Swing Strength (bars)
input color    InpHHColor         = clrLime;        // Higher High Color
input color    InpHLColor         = clrGreen;       // Higher Low Color
input color    InpLHColor         = clrOrange;      // Lower High Color
input color    InpLLColor         = clrRed;         // Lower Low Color

input group "=== LIQUIDITY ==="
input bool     InpShowLiquidity   = true;           // Show Liquidity Levels
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
int g_objectCount = 0;
SDemoState g_demo;

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

    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    DeleteAllObjects();
    DeleteHUD();
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

            color ml_color = ml_conf >= 0.65 ? clrLimeGreen : (ml_conf >= 0.50 ? clrYellow : clrRed);
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

    // Update HUD
    UpdateHUD();

    ChartRedraw(0);

    return rates_total;
}

//+------------------------------------------------------------------+
//| Draw ICT Killzones                                                |
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

        // Convert to ET (simplified: assume UTC-5)
        int et_hour = (dt.hour - 5 + 24) % 24;
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
        if(et_hour >= 8 && et_hour < 11 || (et_hour == 8 && et_min >= 30))
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
//| Draw Fair Value Gaps                                               |
//+------------------------------------------------------------------+
void DrawFVGs(const datetime &time[], const double &high[],
              const double &low[], int limit)
{
    for(int i = 2; i < limit && g_objectCount < InpMaxObjects; i++)
    {
        // Bullish FVG: gap up
        double gap_bull = low[i-2] - high[i];
        if(gap_bull >= InpFVGMinGap)
        {
            CreateFVGRectangle("FVG_BULL_" + IntegerToString(i),
                              time[i-1], low[i-2],
                              time[0], high[i],
                              InpBullFVGColor, "BULL FVG");
        }

        // Bearish FVG: gap down
        double gap_bear = low[i] - high[i-2];
        if(gap_bear >= InpFVGMinGap)
        {
            CreateFVGRectangle("FVG_BEAR_" + IntegerToString(i),
                              time[i-1], low[i],
                              time[0], high[i-2],
                              InpBearFVGColor, "BEAR FVG");
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
//| Draw Liquidity Levels                                              |
//+------------------------------------------------------------------+
void DrawLiquidityLevels(const datetime &time[], const double &high[],
                         const double &low[], int limit)
{
    // Find equal highs (BSL) and equal lows (SSL)
    double tolerance = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 50;  // 5 pips

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
