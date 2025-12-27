//+------------------------------------------------------------------+
//|                                                     CRiskHUD.mqh |
//|                     EA_SCALPER_XAUUSD - Apex Compliant Trading   |
//|                     Risk HUD Panel (Task 4.2)                    |
//+------------------------------------------------------------------+
//| VISUAL RISK HUD FOR INVESTOR DISPLAY                             |
//|                                                                  |
//| Components:                                                      |
//| 1. DD Thermometer (0-5%) - Visual bar with color coding          |
//| 2. Time State + Countdown - Current ET time and state            |
//| 3. Gate Status Icons - Row of OK/Blocked indicators              |
//| 4. HWM Display - Current equity, HWM, distance to HWM            |
//|                                                                  |
//| Color Legend (DD Thermometer):                                   |
//| - Green (clrLimeGreen):  0-3%   NORMAL                          |
//| - Yellow (clrYellow):    3-3.5% WARNING                         |
//| - Orange (clrOrange):    3.5-4% CAUTION                         |
//| - Red (clrRed):          4-5%   CRITICAL/HALT                   |
//+------------------------------------------------------------------+
#ifndef CRISKHUD_MQH
#define CRISKHUD_MQH

#property copyright "EA_SCALPER_XAUUSD - Apex Compliant Trading System"
#property strict

#include "../Core/Definitions.mqh"
#include "../Risk/CApexDDTracker.mqh"
#include "../Risk/CApexTimeHandler.mqh"
#include "../Risk/CUnifiedRiskPolicy.mqh"

// === HUD COLOR DEFINITIONS ===
#define CLR_DD_NORMAL      clrLimeGreen    // 0-3% DD
#define CLR_DD_WARN        clrYellow       // 3-3.5% DD
#define CLR_DD_CAUTION     clrOrange       // 3.5-4% DD
#define CLR_DD_CRITICAL    clrOrangeRed    // 4-4.5% DD
#define CLR_DD_HALT        clrRed          // 4.5-5% DD

#define CLR_GATE_OK        clrLimeGreen    // Gate OK - trading allowed
#define CLR_GATE_BLOCKED   clrRed          // Gate blocked - trading denied
#define CLR_GATE_WARN      clrYellow       // Gate warning

#define CLR_TIME_NORMAL    clrLimeGreen    // Normal trading
#define CLR_TIME_BLOCK     clrYellow       // Block new trades
#define CLR_TIME_EMERGENCY clrOrangeRed    // Emergency close
#define CLR_TIME_HALTED    clrRed          // Market halted

#define CLR_HUD_BG         C'32,32,32'     // Dark background
#define CLR_HUD_BORDER     clrGray         // Border color
#define CLR_HUD_TEXT       clrWhite        // Text color
#define CLR_HUD_LABEL      clrSilver       // Label color

// === HUD DIMENSIONS ===
#define HUD_WIDTH          280             // Panel width
#define HUD_HEIGHT         220             // Panel height
#define HUD_PADDING        8               // Inner padding
#define HUD_ROW_HEIGHT     24              // Row height
#define HUD_THERMO_WIDTH   200             // Thermometer bar width
#define HUD_THERMO_HEIGHT  16              // Thermometer bar height
#define HUD_GATE_ICON_SIZE 20              // Gate icon size
#define HUD_GATE_SPACING   8               // Space between gate icons

// === FONT SIZES ===
#define FONT_SIZE_TITLE    10
#define FONT_SIZE_VALUE    9
#define FONT_SIZE_LABEL    8
#define FONT_SIZE_ICON     12

//+------------------------------------------------------------------+
//| CRiskHUD Class                                                   |
//| Visual HUD panel for displaying risk information                 |
//+------------------------------------------------------------------+
class CRiskHUD
{
private:
    //--- Object naming
    string            m_prefix;              // Object name prefix
    long              m_chart_id;            // Chart ID
    int               m_subwindow;           // Subwindow (0 = main chart)

    //--- Position
    int               m_x;                   // X coordinate
    int               m_y;                   // Y coordinate

    //--- State
    bool              m_visible;             // Is HUD visible?
    bool              m_initialized;         // Is HUD initialized?
    datetime          m_last_update;         // Last update time

    //--- Object counts for cleanup
    int               m_object_count;        // Number of objects created

    //--- Internal methods - Object Creation
    void              CreateBackground();
    void              CreateTitle();
    void              CreateDDThermometer();
    void              CreateTimeDisplay();
    void              CreateGateIcons();
    void              CreateHWMDisplay();

    //--- Internal methods - Object Updates
    void              UpdateDDThermometer(double trailing_dd_pct, ENUM_DD_SEVERITY severity);
    void              UpdateTimeDisplay(ENUM_TIME_STATE state, int minutes_to_close, datetime et_time);
    void              UpdateGateIcons(RiskDecision& decision);
    void              UpdateHWMDisplay(double equity, double hwm, double session_start);

    //--- Helper methods
    string            GetObjectName(string suffix);
    color             GetDDColor(double dd_pct);
    color             GetTimeStateColor(ENUM_TIME_STATE state);
    string            FormatTimeRemaining(int minutes);
    string            FormatMoney(double value);
    void              CreateLabel(string name, int x, int y, string text, color clr, int font_size);
    void              CreateRectangle(string name, int x, int y, int width, int height, color clr);
    void              CreateRectLabel(string name, int x, int y, int width, int height, color bg_clr, color border_clr);

public:
                      CRiskHUD();
                     ~CRiskHUD();

    //--- Initialization
    bool              Init(int x = 10, int y = 30, string prefix = "RiskHUD_");
    void              Delete();

    //--- Core update method
    void              Update(CApexDDTracker* dd, CApexTimeHandler* time_handler, RiskDecision& decision);

    //--- Visibility control
    void              Show();
    void              Hide();
    bool              IsVisible() { return m_visible; }

    //--- Position control
    void              SetPosition(int x, int y);
    int               GetX() { return m_x; }
    int               GetY() { return m_y; }

    //--- State
    bool              IsInitialized() { return m_initialized; }
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CRiskHUD::CRiskHUD()
{
    m_prefix = "RiskHUD_";
    m_chart_id = 0;
    m_subwindow = 0;
    m_x = 10;
    m_y = 30;
    m_visible = false;
    m_initialized = false;
    m_last_update = 0;
    m_object_count = 0;
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CRiskHUD::~CRiskHUD()
{
    Delete();
}

//+------------------------------------------------------------------+
//| Initialize HUD                                                    |
//+------------------------------------------------------------------+
bool CRiskHUD::Init(int x = 10, int y = 30, string prefix = "RiskHUD_")
{
    m_x = x;
    m_y = y;
    m_prefix = prefix;
    m_chart_id = ChartID();
    m_subwindow = 0;

    //--- Delete any existing objects with this prefix
    Delete();

    //--- Create all HUD elements
    CreateBackground();
    CreateTitle();
    CreateDDThermometer();
    CreateTimeDisplay();
    CreateGateIcons();
    CreateHWMDisplay();

    //--- Force chart redraw
    ChartRedraw(m_chart_id);

    m_visible = true;
    m_initialized = true;

    Print("CRiskHUD: Initialized at (", m_x, ", ", m_y, ")");

    return true;
}

//+------------------------------------------------------------------+
//| Delete all HUD objects                                            |
//+------------------------------------------------------------------+
void CRiskHUD::Delete()
{
    //--- Delete all objects with our prefix
    int total = ObjectsTotal(m_chart_id, m_subwindow, -1);

    for(int i = total - 1; i >= 0; i--)
    {
        string name = ObjectName(m_chart_id, i, m_subwindow, -1);
        if(StringFind(name, m_prefix) == 0)
        {
            ObjectDelete(m_chart_id, name);
        }
    }

    m_object_count = 0;
    m_visible = false;
    m_initialized = false;

    ChartRedraw(m_chart_id);
}

//+------------------------------------------------------------------+
//| Get object name with prefix                                       |
//+------------------------------------------------------------------+
string CRiskHUD::GetObjectName(string suffix)
{
    return m_prefix + suffix;
}

//+------------------------------------------------------------------+
//| Create a label object                                             |
//+------------------------------------------------------------------+
void CRiskHUD::CreateLabel(string name, int x, int y, string text, color clr, int font_size)
{
    string obj_name = GetObjectName(name);

    if(ObjectCreate(m_chart_id, obj_name, OBJ_LABEL, m_subwindow, 0, 0))
    {
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_YDISTANCE, y);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_COLOR, clr);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_FONTSIZE, font_size);
        ObjectSetString(m_chart_id, obj_name, OBJPROP_FONT, "Consolas");
        ObjectSetString(m_chart_id, obj_name, OBJPROP_TEXT, text);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_HIDDEN, true);
        m_object_count++;
    }
}

//+------------------------------------------------------------------+
//| Create a rectangle label (filled rectangle)                       |
//+------------------------------------------------------------------+
void CRiskHUD::CreateRectLabel(string name, int x, int y, int width, int height, color bg_clr, color border_clr)
{
    string obj_name = GetObjectName(name);

    if(ObjectCreate(m_chart_id, obj_name, OBJ_RECTANGLE_LABEL, m_subwindow, 0, 0))
    {
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_YDISTANCE, y);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_XSIZE, width);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_YSIZE, height);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_BGCOLOR, bg_clr);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_BORDER_COLOR, border_clr);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_WIDTH, 1);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_HIDDEN, true);
        m_object_count++;
    }
}

//+------------------------------------------------------------------+
//| Create background panel                                           |
//+------------------------------------------------------------------+
void CRiskHUD::CreateBackground()
{
    //--- Main background
    CreateRectLabel("Background", m_x, m_y, HUD_WIDTH, HUD_HEIGHT, CLR_HUD_BG, CLR_HUD_BORDER);
}

//+------------------------------------------------------------------+
//| Create title                                                      |
//+------------------------------------------------------------------+
void CRiskHUD::CreateTitle()
{
    int title_x = m_x + HUD_PADDING;
    int title_y = m_y + HUD_PADDING;

    CreateLabel("Title", title_x, title_y, "APEX RISK MONITOR", CLR_HUD_TEXT, FONT_SIZE_TITLE);

    //--- Separator line
    CreateRectLabel("TitleSep", m_x + HUD_PADDING, title_y + HUD_ROW_HEIGHT - 2,
                   HUD_WIDTH - 2 * HUD_PADDING, 1, CLR_HUD_BORDER, CLR_HUD_BORDER);
}

//+------------------------------------------------------------------+
//| Create DD Thermometer section                                     |
//+------------------------------------------------------------------+
void CRiskHUD::CreateDDThermometer()
{
    int section_y = m_y + HUD_PADDING + HUD_ROW_HEIGHT + 4;
    int label_x = m_x + HUD_PADDING;

    //--- Section label
    CreateLabel("DDLabel", label_x, section_y, "Trailing DD:", CLR_HUD_LABEL, FONT_SIZE_LABEL);

    //--- DD value (right-aligned)
    CreateLabel("DDValue", label_x + HUD_THERMO_WIDTH - 10, section_y, "0.00%", CLR_DD_NORMAL, FONT_SIZE_VALUE);

    //--- Thermometer background (full bar - represents 5%)
    int bar_y = section_y + 14;
    CreateRectLabel("DDBarBG", label_x, bar_y, HUD_THERMO_WIDTH, HUD_THERMO_HEIGHT,
                   C'64,64,64', CLR_HUD_BORDER);

    //--- Thermometer fill (actual DD level)
    CreateRectLabel("DDBarFill", label_x + 1, bar_y + 1, 1, HUD_THERMO_HEIGHT - 2,
                   CLR_DD_NORMAL, CLR_DD_NORMAL);

    //--- Threshold markers (3%, 3.5%, 4%, 4.5%)
    int marker_3 = (int)(HUD_THERMO_WIDTH * 0.60);    // 3% of 5%
    int marker_35 = (int)(HUD_THERMO_WIDTH * 0.70);   // 3.5% of 5%
    int marker_4 = (int)(HUD_THERMO_WIDTH * 0.80);    // 4% of 5%
    int marker_45 = (int)(HUD_THERMO_WIDTH * 0.90);   // 4.5% of 5%

    //--- Threshold tick marks
    CreateRectLabel("DDMark3", label_x + marker_3, bar_y - 3, 1, 3, CLR_DD_WARN, CLR_DD_WARN);
    CreateRectLabel("DDMark35", label_x + marker_35, bar_y - 3, 1, 3, CLR_DD_CAUTION, CLR_DD_CAUTION);
    CreateRectLabel("DDMark4", label_x + marker_4, bar_y - 3, 1, 3, CLR_DD_CRITICAL, CLR_DD_CRITICAL);
    CreateRectLabel("DDMark45", label_x + marker_45, bar_y - 3, 1, 3, CLR_DD_HALT, CLR_DD_HALT);

    //--- DD Status text
    CreateLabel("DDStatus", label_x, bar_y + HUD_THERMO_HEIGHT + 2, "NORMAL", CLR_DD_NORMAL, FONT_SIZE_LABEL);
}

//+------------------------------------------------------------------+
//| Create Time Display section                                       |
//+------------------------------------------------------------------+
void CRiskHUD::CreateTimeDisplay()
{
    int section_y = m_y + HUD_PADDING + HUD_ROW_HEIGHT * 3 + 10;
    int label_x = m_x + HUD_PADDING;

    //--- Separator
    CreateRectLabel("TimeSep", label_x, section_y - 4,
                   HUD_WIDTH - 2 * HUD_PADDING, 1, CLR_HUD_BORDER, CLR_HUD_BORDER);

    //--- Time label and value
    CreateLabel("TimeLabel", label_x, section_y, "ET Time:", CLR_HUD_LABEL, FONT_SIZE_LABEL);
    CreateLabel("TimeValue", label_x + 60, section_y, "00:00:00", CLR_HUD_TEXT, FONT_SIZE_VALUE);

    //--- Time state
    CreateLabel("TimeStateLabel", label_x, section_y + 14, "State:", CLR_HUD_LABEL, FONT_SIZE_LABEL);
    CreateLabel("TimeStateValue", label_x + 60, section_y + 14, "NORMAL", CLR_TIME_NORMAL, FONT_SIZE_VALUE);

    //--- Countdown
    CreateLabel("CountdownLabel", label_x, section_y + 28, "Close in:", CLR_HUD_LABEL, FONT_SIZE_LABEL);
    CreateLabel("CountdownValue", label_x + 60, section_y + 28, "--:--", CLR_HUD_TEXT, FONT_SIZE_VALUE);
}

//+------------------------------------------------------------------+
//| Create Gate Status Icons                                          |
//+------------------------------------------------------------------+
void CRiskHUD::CreateGateIcons()
{
    int section_y = m_y + HUD_PADDING + HUD_ROW_HEIGHT * 5 + 14;
    int label_x = m_x + HUD_PADDING;

    //--- Separator
    CreateRectLabel("GateSep", label_x, section_y - 4,
                   HUD_WIDTH - 2 * HUD_PADDING, 1, CLR_HUD_BORDER, CLR_HUD_BORDER);

    //--- Section label
    CreateLabel("GateLabel", label_x, section_y, "Gates:", CLR_HUD_LABEL, FONT_SIZE_LABEL);

    //--- Gate icons row (Time, DD, Spread, Virtual, Gap)
    int icon_y = section_y + 14;
    int icon_x = label_x;

    //--- Time Gate
    CreateRectLabel("GateTimeIcon", icon_x, icon_y, HUD_GATE_ICON_SIZE, HUD_GATE_ICON_SIZE,
                   CLR_GATE_OK, CLR_HUD_BORDER);
    CreateLabel("GateTimeText", icon_x + 2, icon_y + 3, "T", CLR_HUD_BG, FONT_SIZE_ICON);
    icon_x += HUD_GATE_ICON_SIZE + HUD_GATE_SPACING;

    //--- DD Gate
    CreateRectLabel("GateDDIcon", icon_x, icon_y, HUD_GATE_ICON_SIZE, HUD_GATE_ICON_SIZE,
                   CLR_GATE_OK, CLR_HUD_BORDER);
    CreateLabel("GateDDText", icon_x + 2, icon_y + 3, "D", CLR_HUD_BG, FONT_SIZE_ICON);
    icon_x += HUD_GATE_ICON_SIZE + HUD_GATE_SPACING;

    //--- Spread Gate
    CreateRectLabel("GateSpreadIcon", icon_x, icon_y, HUD_GATE_ICON_SIZE, HUD_GATE_ICON_SIZE,
                   CLR_GATE_OK, CLR_HUD_BORDER);
    CreateLabel("GateSpreadText", icon_x + 2, icon_y + 3, "S", CLR_HUD_BG, FONT_SIZE_ICON);
    icon_x += HUD_GATE_ICON_SIZE + HUD_GATE_SPACING;

    //--- Virtual Gate
    CreateRectLabel("GateVirtualIcon", icon_x, icon_y, HUD_GATE_ICON_SIZE, HUD_GATE_ICON_SIZE,
                   CLR_GATE_OK, CLR_HUD_BORDER);
    CreateLabel("GateVirtualText", icon_x + 2, icon_y + 3, "V", CLR_HUD_BG, FONT_SIZE_ICON);
    icon_x += HUD_GATE_ICON_SIZE + HUD_GATE_SPACING;

    //--- Gap Gate
    CreateRectLabel("GateGapIcon", icon_x, icon_y, HUD_GATE_ICON_SIZE, HUD_GATE_ICON_SIZE,
                   CLR_GATE_OK, CLR_HUD_BORDER);
    CreateLabel("GateGapText", icon_x + 2, icon_y + 3, "G", CLR_HUD_BG, FONT_SIZE_ICON);

    //--- Legend
    CreateLabel("GateLegend", label_x, icon_y + HUD_GATE_ICON_SIZE + 2,
               "T=Time D=DD S=Spread V=Virtual G=Gap", CLR_HUD_LABEL, 7);
}

//+------------------------------------------------------------------+
//| Create HWM Display section                                        |
//+------------------------------------------------------------------+
void CRiskHUD::CreateHWMDisplay()
{
    int section_y = m_y + HUD_PADDING + HUD_ROW_HEIGHT * 7 + 20;
    int label_x = m_x + HUD_PADDING;
    int value_x = label_x + 90;

    //--- Separator
    CreateRectLabel("HWMSep", label_x, section_y - 4,
                   HUD_WIDTH - 2 * HUD_PADDING, 1, CLR_HUD_BORDER, CLR_HUD_BORDER);

    //--- Current Equity
    CreateLabel("EquityLabel", label_x, section_y, "Equity:", CLR_HUD_LABEL, FONT_SIZE_LABEL);
    CreateLabel("EquityValue", value_x, section_y, "$0.00", CLR_HUD_TEXT, FONT_SIZE_VALUE);

    //--- Session HWM
    CreateLabel("HWMLabel", label_x, section_y + 12, "Session HWM:", CLR_HUD_LABEL, FONT_SIZE_LABEL);
    CreateLabel("HWMValue", value_x, section_y + 12, "$0.00", CLR_HUD_TEXT, FONT_SIZE_VALUE);

    //--- Distance to HWM
    CreateLabel("DistLabel", label_x, section_y + 24, "Dist to HWM:", CLR_HUD_LABEL, FONT_SIZE_LABEL);
    CreateLabel("DistValue", value_x, section_y + 24, "$0.00", CLR_HUD_TEXT, FONT_SIZE_VALUE);
}

//+------------------------------------------------------------------+
//| Get color for DD percentage                                       |
//+------------------------------------------------------------------+
color CRiskHUD::GetDDColor(double dd_pct)
{
    //--- Color coding based on CLAUDE.md thresholds:
    //--- 0-3%:   Green (NORMAL)
    //--- 3-3.5%: Yellow (WARN)
    //--- 3.5-4%: Orange (CAUTION)
    //--- 4-4.5%: OrangeRed (CRITICAL)
    //--- 4.5-5%: Red (HALT)

    if(dd_pct >= 4.5)
        return CLR_DD_HALT;
    if(dd_pct >= 4.0)
        return CLR_DD_CRITICAL;
    if(dd_pct >= 3.5)
        return CLR_DD_CAUTION;
    if(dd_pct >= 3.0)
        return CLR_DD_WARN;

    return CLR_DD_NORMAL;
}

//+------------------------------------------------------------------+
//| Get color for time state                                          |
//+------------------------------------------------------------------+
color CRiskHUD::GetTimeStateColor(ENUM_TIME_STATE state)
{
    switch(state)
    {
        case TIME_HALTED:    return CLR_TIME_HALTED;
        case TIME_EMERGENCY: return CLR_TIME_EMERGENCY;
        case TIME_BLOCK_NEW: return CLR_TIME_BLOCK;
        default:             return CLR_TIME_NORMAL;
    }
}

//+------------------------------------------------------------------+
//| Format time remaining as "Xh Ym" or "Xm"                         |
//+------------------------------------------------------------------+
string CRiskHUD::FormatTimeRemaining(int minutes)
{
    if(minutes <= 0)
        return "CLOSED";

    int hours = minutes / 60;
    int mins = minutes % 60;

    if(hours > 0)
        return StringFormat("%dh %dm", hours, mins);
    else
        return StringFormat("%dm", mins);
}

//+------------------------------------------------------------------+
//| Format money value                                                |
//+------------------------------------------------------------------+
string CRiskHUD::FormatMoney(double value)
{
    if(MathAbs(value) >= 1000000)
        return StringFormat("$%.2fM", value / 1000000);
    if(MathAbs(value) >= 1000)
        return StringFormat("$%.1fK", value / 1000);
    return StringFormat("$%.2f", value);
}

//+------------------------------------------------------------------+
//| Update DD Thermometer                                             |
//+------------------------------------------------------------------+
void CRiskHUD::UpdateDDThermometer(double trailing_dd_pct, ENUM_DD_SEVERITY severity)
{
    //--- Clamp DD to 0-5% range for display
    double dd_clamped = MathMax(0.0, MathMin(5.0, trailing_dd_pct));

    //--- Calculate fill width
    //--- Formula: fill_width = (dd_pct / 5.0) * bar_width
    //--- Example: dd=2.5% -> (2.5/5.0) * 200 = 100 pixels
    int fill_width = (int)((dd_clamped / 5.0) * (HUD_THERMO_WIDTH - 2));
    fill_width = MathMax(1, fill_width);  // Minimum 1 pixel

    //--- Get color based on DD level
    color dd_color = GetDDColor(trailing_dd_pct);

    //--- Update fill bar
    string fill_name = GetObjectName("DDBarFill");
    ObjectSetInteger(m_chart_id, fill_name, OBJPROP_XSIZE, fill_width);
    ObjectSetInteger(m_chart_id, fill_name, OBJPROP_BGCOLOR, dd_color);
    ObjectSetInteger(m_chart_id, fill_name, OBJPROP_BORDER_COLOR, dd_color);

    //--- Update DD value text
    string value_name = GetObjectName("DDValue");
    ObjectSetString(m_chart_id, value_name, OBJPROP_TEXT,
                   StringFormat("%.2f%%", trailing_dd_pct));
    ObjectSetInteger(m_chart_id, value_name, OBJPROP_COLOR, dd_color);

    //--- Update status text
    string status_name = GetObjectName("DDStatus");
    string status_text = "";

    switch(severity)
    {
        case DD_TERMINATED: status_text = "TERMINATED!"; break;
        case DD_HALT:       status_text = "HALT";        break;
        case DD_CRITICAL:   status_text = "CRITICAL";    break;
        case DD_CAUTION:    status_text = "CAUTION";     break;
        case DD_WARN:       status_text = "WARNING";     break;
        default:            status_text = "NORMAL";      break;
    }

    ObjectSetString(m_chart_id, status_name, OBJPROP_TEXT, status_text);
    ObjectSetInteger(m_chart_id, status_name, OBJPROP_COLOR, dd_color);
}

//+------------------------------------------------------------------+
//| Update Time Display                                               |
//+------------------------------------------------------------------+
void CRiskHUD::UpdateTimeDisplay(ENUM_TIME_STATE state, int minutes_to_close, datetime et_time)
{
    //--- Update ET time
    MqlDateTime mdt;
    TimeToStruct(et_time, mdt);

    string time_name = GetObjectName("TimeValue");
    ObjectSetString(m_chart_id, time_name, OBJPROP_TEXT,
                   StringFormat("%02d:%02d:%02d", mdt.hour, mdt.min, mdt.sec));

    //--- Update time state
    color state_color = GetTimeStateColor(state);
    string state_text = "";

    switch(state)
    {
        case TIME_HALTED:    state_text = "HALTED";    break;
        case TIME_EMERGENCY: state_text = "EMERGENCY"; break;
        case TIME_BLOCK_NEW: state_text = "BLOCK NEW"; break;
        default:             state_text = "NORMAL";    break;
    }

    string state_name = GetObjectName("TimeStateValue");
    ObjectSetString(m_chart_id, state_name, OBJPROP_TEXT, state_text);
    ObjectSetInteger(m_chart_id, state_name, OBJPROP_COLOR, state_color);

    //--- Update countdown
    string countdown_name = GetObjectName("CountdownValue");
    ObjectSetString(m_chart_id, countdown_name, OBJPROP_TEXT,
                   FormatTimeRemaining(minutes_to_close));
    ObjectSetInteger(m_chart_id, countdown_name, OBJPROP_COLOR,
                    minutes_to_close <= 30 ? state_color : CLR_HUD_TEXT);
}

//+------------------------------------------------------------------+
//| Update Gate Status Icons                                          |
//+------------------------------------------------------------------+
void CRiskHUD::UpdateGateIcons(RiskDecision& decision)
{
    //--- Time Gate
    bool time_blocked = decision.HasReason(GATE_TIME);
    color time_color = time_blocked ? CLR_GATE_BLOCKED : CLR_GATE_OK;
    ObjectSetInteger(m_chart_id, GetObjectName("GateTimeIcon"), OBJPROP_BGCOLOR, time_color);

    //--- DD Gate (trailing or daily)
    bool dd_blocked = decision.HasReason(GATE_DD_TRAILING) || decision.HasReason(GATE_DD_DAILY);
    color dd_color = dd_blocked ? CLR_GATE_BLOCKED : CLR_GATE_OK;
    ObjectSetInteger(m_chart_id, GetObjectName("GateDDIcon"), OBJPROP_BGCOLOR, dd_color);

    //--- Spread Gate
    bool spread_blocked = decision.HasReason(GATE_SPREAD);
    color spread_color = spread_blocked ? CLR_GATE_BLOCKED : CLR_GATE_OK;
    ObjectSetInteger(m_chart_id, GetObjectName("GateSpreadIcon"), OBJPROP_BGCOLOR, spread_color);

    //--- Virtual Gate
    bool virtual_blocked = decision.HasReason(GATE_VIRTUAL);
    color virtual_color = virtual_blocked ? CLR_GATE_BLOCKED : CLR_GATE_OK;
    ObjectSetInteger(m_chart_id, GetObjectName("GateVirtualIcon"), OBJPROP_BGCOLOR, virtual_color);

    //--- Gap Gate
    bool gap_blocked = decision.HasReason(GATE_GAP_COOLDOWN);
    color gap_color = gap_blocked ? CLR_GATE_BLOCKED : CLR_GATE_OK;
    ObjectSetInteger(m_chart_id, GetObjectName("GateGapIcon"), OBJPROP_BGCOLOR, gap_color);
}

//+------------------------------------------------------------------+
//| Update HWM Display                                                |
//+------------------------------------------------------------------+
void CRiskHUD::UpdateHWMDisplay(double equity, double hwm, double session_start)
{
    //--- Calculate distance to HWM
    //--- Formula: distance = hwm - equity
    //--- Example: hwm=52000, equity=50000 -> distance = $2000
    double distance = hwm - equity;

    //--- Update Equity
    string equity_name = GetObjectName("EquityValue");
    ObjectSetString(m_chart_id, equity_name, OBJPROP_TEXT, FormatMoney(equity));

    //--- Color equity based on profit/loss from session start
    double pnl = equity - session_start;
    color equity_color = pnl >= 0 ? CLR_DD_NORMAL : CLR_DD_HALT;
    ObjectSetInteger(m_chart_id, equity_name, OBJPROP_COLOR, equity_color);

    //--- Update HWM
    string hwm_name = GetObjectName("HWMValue");
    ObjectSetString(m_chart_id, hwm_name, OBJPROP_TEXT, FormatMoney(hwm));

    //--- Update Distance
    string dist_name = GetObjectName("DistValue");
    ObjectSetString(m_chart_id, dist_name, OBJPROP_TEXT,
                   StringFormat("%s%.2f", distance > 0 ? "-" : "", MathAbs(distance)));

    //--- Color distance (red if below HWM)
    color dist_color = distance > 0 ? CLR_DD_WARN : CLR_DD_NORMAL;
    ObjectSetInteger(m_chart_id, dist_name, OBJPROP_COLOR, dist_color);
}

//+------------------------------------------------------------------+
//| Main Update Method                                                |
//+------------------------------------------------------------------+
void CRiskHUD::Update(CApexDDTracker* dd, CApexTimeHandler* time_handler, RiskDecision& decision)
{
    if(!m_initialized || !m_visible)
        return;

    //--- Update DD Thermometer
    if(dd != NULL)
    {
        SApexDDAnalysis dd_analysis = dd.GetAnalysis();
        UpdateDDThermometer(dd_analysis.trailing_dd_pct, dd_analysis.trailing_severity);
        UpdateHWMDisplay(dd_analysis.current_equity, dd_analysis.high_water_mark,
                        dd_analysis.session_start_equity);
    }

    //--- Update Time Display
    if(time_handler != NULL)
    {
        ENUM_TIME_STATE time_state = time_handler.GetTimeState();
        int minutes_to_close = time_handler.GetMinutesToClose();
        datetime et_time = time_handler.GetCurrentET();
        UpdateTimeDisplay(time_state, minutes_to_close, et_time);
    }

    //--- Update Gate Icons
    UpdateGateIcons(decision);

    //--- Force chart redraw
    ChartRedraw(m_chart_id);

    m_last_update = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Show HUD                                                          |
//+------------------------------------------------------------------+
void CRiskHUD::Show()
{
    if(!m_initialized)
        return;

    //--- Make all objects visible
    int total = ObjectsTotal(m_chart_id, m_subwindow, -1);

    for(int i = 0; i < total; i++)
    {
        string name = ObjectName(m_chart_id, i, m_subwindow, -1);
        if(StringFind(name, m_prefix) == 0)
        {
            ObjectSetInteger(m_chart_id, name, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
        }
    }

    m_visible = true;
    ChartRedraw(m_chart_id);
}

//+------------------------------------------------------------------+
//| Hide HUD                                                          |
//+------------------------------------------------------------------+
void CRiskHUD::Hide()
{
    if(!m_initialized)
        return;

    //--- Make all objects invisible
    int total = ObjectsTotal(m_chart_id, m_subwindow, -1);

    for(int i = 0; i < total; i++)
    {
        string name = ObjectName(m_chart_id, i, m_subwindow, -1);
        if(StringFind(name, m_prefix) == 0)
        {
            ObjectSetInteger(m_chart_id, name, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
        }
    }

    m_visible = false;
    ChartRedraw(m_chart_id);
}

//+------------------------------------------------------------------+
//| Set HUD position                                                  |
//+------------------------------------------------------------------+
void CRiskHUD::SetPosition(int x, int y)
{
    if(!m_initialized)
        return;

    //--- Calculate offset from current position
    int dx = x - m_x;
    int dy = y - m_y;

    //--- Update all objects
    int total = ObjectsTotal(m_chart_id, m_subwindow, -1);

    for(int i = 0; i < total; i++)
    {
        string name = ObjectName(m_chart_id, i, m_subwindow, -1);
        if(StringFind(name, m_prefix) == 0)
        {
            int curr_x = (int)ObjectGetInteger(m_chart_id, name, OBJPROP_XDISTANCE);
            int curr_y = (int)ObjectGetInteger(m_chart_id, name, OBJPROP_YDISTANCE);
            ObjectSetInteger(m_chart_id, name, OBJPROP_XDISTANCE, curr_x + dx);
            ObjectSetInteger(m_chart_id, name, OBJPROP_YDISTANCE, curr_y + dy);
        }
    }

    m_x = x;
    m_y = y;

    ChartRedraw(m_chart_id);
}

#endif // CRISKHUD_MQH
//+------------------------------------------------------------------+
