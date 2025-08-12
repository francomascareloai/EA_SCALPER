//+------------------------------------------------------------------+
//|                                   MQL5 NEWS CALENDAR PART 10.mq5 |
//|      Copyright 2025, ALLAN MUNENE MUTIIRIA. #@Forex Algo-Trader. |
//|                                     https://forexalgo-trader.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, ALLAN MUNENE MUTIIRIA. #@Forex Algo-Trader"
#property link      "https://forexalgo-trader.com"
#property description "MQL5 NEWS CALENDAR PART 10 - Strategy Tester CSV Trading Support with Draggable Panel and Hover Effects"
#property version   "1.00"

//---- Include trading library
#include <Trade\Trade.mqh>
CTrade trade;

//---- Define resource for CSV
#resource "\\Files\\Database\\EconomicCalendar.csv" as string EconomicCalendarData

//---- UI element definitions
#define MAIN_REC "MAIN_REC"
#define SUB_REC1 "SUB_REC1"
#define SUB_REC2 "SUB_REC2"
#define HEADER_LABEL "HEADER_LABEL"
#define ARRAY_CALENDAR "ARRAY_CALENDAR"
#define ARRAY_NEWS "ARRAY_NEWS"
#define DATA_HOLDERS "DATA_HOLDERS"
#define TIME_LABEL "TIME_LABEL"
#define IMPACT_LABEL "IMPACT_LABEL"
#define FILTER_LABEL "FILTER_LABEL"
#define FILTER_CURR_BTN "FILTER_CURR_BTN"
#define FILTER_IMP_BTN "FILTER_IMP_BTN"
#define FILTER_TIME_BTN "FILTER_TIME_BTN"
#define CANCEL_BTN "CANCEL_BTN"
#define CURRENCY_BTNS "CURRENCY_BTNS"
// Scrollbar UI elements
#define SCROLL_UP_REC "SCROLL_UP_REC"
#define SCROLL_UP_LABEL "SCROLL_UP_LABEL"
#define SCROLL_DOWN_REC "SCROLL_DOWN_REC"
#define SCROLL_DOWN_LABEL "SCROLL_DOWN_LABEL"
#define SCROLL_LEADER "SCROLL_LEADER"
#define SCROLL_SLIDER "SCROLL_SLIDER"

//---- Calendar columns and button sizes
string array_calendar[] = {"Date","Time","Cur.","Imp.","Event","Actual","Forecast","Previous"};
int buttons[] = {80,50,50,40,281,60,70,70};

//---- Scrollbar layout constants
#define LIST_X_OFFSET 12 // Relative to panel_x (original LIST_X=62, adjusted for panel_x=50)
#define LIST_Y_OFFSET 112 // Relative to panel_y (original LIST_Y=162, adjusted for panel_y=50)
#define LIST_WIDTH 716
#define LIST_HEIGHT 286
#define VISIBLE_ITEMS 11
#define ITEM_HEIGHT 26
#define SCROLLBAR_X_OFFSET (LIST_X_OFFSET + LIST_WIDTH + 2) // 730 relative to panel_x
#define SCROLLBAR_Y_OFFSET LIST_Y_OFFSET // Same as LIST_Y_OFFSET
#define SCROLLBAR_WIDTH 20
#define SCROLLBAR_HEIGHT LIST_HEIGHT // 286
#define BUTTON_SIZE 15
#define BUTTON_WIDTH (SCROLLBAR_WIDTH - 2)
#define BUTTON_OFFSET_X 1
#define SCROLL_AREA_HEIGHT (SCROLLBAR_HEIGHT - 2 * BUTTON_SIZE)
#define SLIDER_MIN_HEIGHT 20
#define SLIDER_WIDTH 18
#define SLIDER_OFFSET_X 1

//---- Filter arrays
string curr_filter[] = {"AUD","CAD","CHF","EUR","GBP","JPY","NZD","USD"};
string curr_filter_selected[];
string impact_labels[] = {"None","Low","Medium","High"};
string impact_filter_selected[];
ENUM_CALENDAR_EVENT_IMPORTANCE allowed_importance_levels[] = {
   CALENDAR_IMPORTANCE_NONE, CALENDAR_IMPORTANCE_LOW, CALENDAR_IMPORTANCE_MODERATE, CALENDAR_IMPORTANCE_HIGH
};
ENUM_CALENDAR_EVENT_IMPORTANCE imp_filter_selected[];

//---- Event name tracking
string current_eventNames_data[];
string previous_eventNames_data[];
string last_dashboard_eventNames[];
string previous_displayable_eventNames[];
string current_displayable_eventNames[];
datetime last_dashboard_update = 0;

//---- Filter flags
bool enableCurrencyFilter = true;
bool enableImportanceFilter = true;
bool enableTimeFilter = true;
bool isDashboardUpdate = true;
bool filters_changed = true;

//---- Scrollbar flags and variables
bool scroll_visible = false;
bool moving_state_slider = false;
int scroll_pos = 0;
int prev_scroll_pos = -1; // Track previous scroll position
int mlb_down_x = 0;
int mlb_down_y = 0;
int mlb_down_yd_slider = 0;
int prev_mouse_state = 0;
int slider_height = SLIDER_MIN_HEIGHT;

//---- Event counters
int totalEvents_Considered = 0;
int totalEvents_Filtered = 0;
int totalEvents_Displayable = 0;

//---- Input parameters
sinput group "General Calendar Settings"
input ENUM_TIMEFRAMES start_time = PERIOD_H12;
input ENUM_TIMEFRAMES end_time = PERIOD_H12;
input ENUM_TIMEFRAMES range_time = PERIOD_H8;
input bool updateServerTime = true;
input bool debugLogging = true; // Enabled for debugging

sinput group "Strategy Tester CSV Settings"
input datetime StartDate = D'2025.03.01';
input datetime EndDate = D'2025.03.21';

//---- Structure for CSV events
struct EconomicEvent {
   string eventDate;
   string eventTime;
   string currency;
   string event;
   string importance;
   double actual;
   double forecast;
   double previous;
   datetime eventDateTime;
};

//---- Global arrays for events
EconomicEvent allEvents[];
EconomicEvent filteredEvents[];
EconomicEvent displayableEvents[];

//---- Trade settings
enum ETradeMode {
   TRADE_BEFORE,
   TRADE_AFTER,
   NO_TRADE,
   PAUSE_TRADING
};
input ETradeMode tradeMode = TRADE_BEFORE;
input int tradeOffsetHours = 12;
input int tradeOffsetMinutes = 5;
input int tradeOffsetSeconds = 0;
input double tradeLotSize = 0.01;

//---- Trade control
bool tradeExecuted = false;
datetime tradedNewsTime = 0;
int triggeredNewsEvents[];

//---- Panel dragging variables
bool panel_dragging = false;
int panel_drag_x = 0, panel_drag_y = 0;
int panel_start_x = 0, panel_start_y = 0;
bool header_hovered = false;
int panel_x = 50, panel_y = 50; // Initial panel position

//---- Hover state variables for buttons
bool filter_curr_hovered = false;
bool filter_imp_hovered = false;
bool filter_time_hovered = false;
bool cancel_hovered = false;
bool currency_btns_hovered[];
bool impact_btns_hovered[];

//+------------------------------------------------------------------+
//| Filter events for tester mode                                     |
//+------------------------------------------------------------------+
void FilterEventsForTester() {
   ArrayResize(filteredEvents, 0);
   int eventIndex = 0;
   for (int i = 0; i < ArraySize(allEvents); i++) {
      datetime eventDateTime = allEvents[i].eventDateTime;
      if (eventDateTime < StartDate || eventDateTime > EndDate) {
         if (debugLogging) Print("Event ", allEvents[i].event, " skipped in filter due to date range: ", TimeToString(eventDateTime));
         continue;
      }
      ArrayResize(filteredEvents, eventIndex + 1);
      filteredEvents[eventIndex] = allEvents[i];
      eventIndex++;
   }
   if (debugLogging) Print("Tester mode: Filtered ", eventIndex, " events.");
   filters_changed = false;
}

//+------------------------------------------------------------------+
//| Expert initialization function                                    |
//+------------------------------------------------------------------+
int OnInit() {
   // Enable mouse move events for scrollbar and dragging
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);

   // Initialize hover state arrays
   ArrayResize(currency_btns_hovered, ArraySize(curr_filter));
   ArrayFill(currency_btns_hovered, 0, ArraySize(curr_filter), false);
   ArrayResize(impact_btns_hovered, ArraySize(impact_labels));
   ArrayFill(impact_btns_hovered, 0, ArraySize(impact_labels), false);

   // Create dashboard UI with original coordinates
   createRecLabel(MAIN_REC, panel_x, panel_y, 740+13, 410, clrSeaGreen, 1);
   createRecLabel(SUB_REC1, panel_x+3, panel_y+30, 740-3-3+13, 410-30-3, clrWhite, 1);
   createRecLabel(SUB_REC2, panel_x+3+5, panel_y+30+50+27, 740-3-3-5-5, 410-30-3-50-27-10+5, clrGreen, 1);
   createLabel(HEADER_LABEL, panel_x+3+5, panel_y+5, "MQL5 Economic Calendar", clrWhite, 15);

   // Create calendar buttons
   int startX = panel_x + 9; // Original startX=59, adjusted for panel_x=50
   for (int i = 0; i < ArraySize(array_calendar); i++) {
      createButton(ARRAY_CALENDAR+IntegerToString(i), startX, panel_y+82, buttons[i], 25,
                   array_calendar[i], clrWhite, 13, clrGreen, clrNONE, "Calibri Bold");
      startX += buttons[i]+3;
   }

   // Initialize for live mode
   int totalNews = 0;
   bool isNews = false;
   MqlCalendarValue values[];
   datetime startTime = TimeTradeServer() - PeriodSeconds(start_time);
   datetime endTime = TimeTradeServer() + PeriodSeconds(end_time);
   string country_code = "US";
   string currency_base = SymbolInfoString(_Symbol, SYMBOL_CURRENCY_BASE);
   int allValues = CalendarValueHistory(values, startTime, endTime, NULL, NULL);

   // Load CSV events for tester mode
   if (MQLInfoInteger(MQL_TESTER)) {
      if (!LoadEventsFromResource()) {
         Print("Failed to load events from CSV resource.");
         return(INIT_FAILED);
      }
      Print("Tester mode: Loaded ", ArraySize(allEvents), " events from CSV.");
      FilterEventsForTester();
   }

   // Create UI elements
   createLabel(TIME_LABEL, panel_x+20, panel_y+35, "Server Time: "+TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)+
               "   |||   Total News: "+IntegerToString(allValues), clrBlack, 14, "Times new roman bold");
   createLabel(IMPACT_LABEL, panel_x+20, panel_y+55, "Impact: ", clrBlack, 14, "Times new roman bold");
   createLabel(FILTER_LABEL, panel_x+320, panel_y+5, "Filters:", clrYellow, 16, "Impact");

   // Create filter buttons
   string filter_curr_text = enableCurrencyFilter ? ShortToString(0x2714)+"Currency" : ShortToString(0x274C)+"Currency";
   color filter_curr_txt_color = enableCurrencyFilter ? clrLime : clrRed;
   bool filter_curr_state = enableCurrencyFilter;
   createButton(FILTER_CURR_BTN, panel_x+380, panel_y+5, 110, 26, filter_curr_text, filter_curr_txt_color, 12, clrBlack);
   ObjectSetInteger(0, FILTER_CURR_BTN, OBJPROP_STATE, filter_curr_state);

   string filter_imp_text = enableImportanceFilter ? ShortToString(0x2714)+"Importance" : ShortToString(0x274C)+"Importance";
   color filter_imp_txt_color = enableImportanceFilter ? clrLime : clrRed;
   bool filter_imp_state = enableImportanceFilter;
   createButton(FILTER_IMP_BTN, panel_x+490, panel_y+5, 120, 26, filter_imp_text, filter_imp_txt_color, 12, clrBlack);
   ObjectSetInteger(0, FILTER_IMP_BTN, OBJPROP_STATE, filter_imp_state);

   string filter_time_text = enableTimeFilter ? ShortToString(0x2714)+"Time" : ShortToString(0x274C)+"Time";
   color filter_time_txt_color = enableTimeFilter ? clrLime : clrRed;
   bool filter_time_state = enableTimeFilter;
   createButton(FILTER_TIME_BTN, panel_x+610, panel_y+5, 70, 26, filter_time_text, filter_time_txt_color, 12, clrBlack);
   ObjectSetInteger(0, FILTER_TIME_BTN, OBJPROP_STATE, filter_time_state);

   // Restore original CANCEL_BTN Y-distance (51)
   createButton(CANCEL_BTN, panel_x+692+10, panel_y+1, 50, 30, "X", clrWhite, 17, clrRed, clrNONE);

   // Create impact buttons
   int impact_size = 100;
   for (int i = 0; i < ArraySize(impact_labels); i++) {
      color impact_color = clrBlack, label_color = clrBlack;
      if (impact_labels[i] == "None") label_color = clrWhite;
      else if (impact_labels[i] == "Low") impact_color = clrYellow;
      else if (impact_labels[i] == "Medium") impact_color = clrOrange;
      else if (impact_labels[i] == "High") impact_color = clrRed;
      createButton(IMPACT_LABEL+string(i), panel_x+90+impact_size*i, panel_y+55, impact_size, 25,
                   impact_labels[i], label_color, 12, impact_color, clrBlack);
   }

   // Create currency buttons
   int curr_size = 51, button_height = 22, spacing_x = 0, spacing_y = 3, max_columns = 4;
   for (int i = 0; i < ArraySize(curr_filter); i++) {
      int row = i / max_columns;
      int col = i % max_columns;
      int x_pos = panel_x + 525 + col * (curr_size + spacing_x);
      int y_pos = panel_y + 33 + row * (button_height + spacing_y);
      createButton(CURRENCY_BTNS+IntegerToString(i), x_pos, y_pos, curr_size, button_height, curr_filter[i], clrBlack);
   }

   // Initialize filters
   if (enableCurrencyFilter) {
      ArrayFree(curr_filter_selected);
      ArrayCopy(curr_filter_selected, curr_filter);
      Print("CURRENCY FILTER ENABLED");
      ArrayPrint(curr_filter_selected);
      for (int i = 0; i < ArraySize(curr_filter_selected); i++) {
         ObjectSetInteger(0, CURRENCY_BTNS+IntegerToString(i), OBJPROP_STATE, true);
      }
   }

   if (enableImportanceFilter) {
      ArrayFree(imp_filter_selected);
      ArrayCopy(imp_filter_selected, allowed_importance_levels);
      ArrayFree(impact_filter_selected);
      ArrayCopy(impact_filter_selected, impact_labels);
      Print("IMPORTANCE FILTER ENABLED");
      ArrayPrint(imp_filter_selected);
      ArrayPrint(impact_filter_selected);
      for (int i = 0; i < ArraySize(imp_filter_selected); i++) {
         string btn_name = IMPACT_LABEL+string(i);
         ObjectSetInteger(0, btn_name, OBJPROP_STATE, true);
         ObjectSetInteger(0, btn_name, OBJPROP_BORDER_COLOR, clrNONE);
      }
   }

   // Update dashboard
   update_dashboard_values(curr_filter_selected, imp_filter_selected);
   ChartRedraw(0);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   destroy_Dashboard();
   deleteTradeObjects();
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick() {
   UpdateFilterInfo();
   CheckForNewsTrade();
   if (isDashboardUpdate) {
      if (MQLInfoInteger(MQL_TESTER)) {
         datetime currentTime = TimeTradeServer();
         datetime timeRange = PeriodSeconds(range_time);
         datetime timeAfter = currentTime + timeRange;
         if (filters_changed || last_dashboard_update < timeAfter) {
            update_dashboard_values(curr_filter_selected, imp_filter_selected);
            ArrayFree(last_dashboard_eventNames);
            ArrayCopy(last_dashboard_eventNames, current_eventNames_data);
            last_dashboard_update = currentTime;
         }
      } else {
         update_dashboard_values(curr_filter_selected, imp_filter_selected);
      }
   }
}

//+------------------------------------------------------------------+
//| Update hover states for header and buttons                        |
//+------------------------------------------------------------------+
void updateHoverStates(int mouse_x, int mouse_y) {
   // Header hover
   int header_x = (int)ObjectGetInteger(0, HEADER_LABEL, OBJPROP_XDISTANCE);
   int header_y = (int)ObjectGetInteger(0, HEADER_LABEL, OBJPROP_YDISTANCE);
   int header_width = 740;
   int header_height = 30;

   bool is_header_hovered = (mouse_x >= header_x && mouse_x <= header_x + header_width &&
                             mouse_y >= header_y && mouse_y <= header_y + header_height);

   if (is_header_hovered && !header_hovered) {
      ObjectSetInteger(0, MAIN_REC, OBJPROP_BGCOLOR, clrDarkGreen);
      header_hovered = true;
   } else if (!is_header_hovered && header_hovered) {
      ObjectSetInteger(0, MAIN_REC, OBJPROP_BGCOLOR, clrSeaGreen);
      header_hovered = false;
   }

   // FILTER_CURR_BTN hover
   int curr_btn_x = (int)ObjectGetInteger(0, FILTER_CURR_BTN, OBJPROP_XDISTANCE);
   int curr_btn_y = (int)ObjectGetInteger(0, FILTER_CURR_BTN, OBJPROP_YDISTANCE);
   int curr_btn_width = 110;
   int curr_btn_height = 26;

   bool is_curr_btn_hovered = (mouse_x >= curr_btn_x && mouse_x <= curr_btn_x + curr_btn_width &&
                               mouse_y >= curr_btn_y && mouse_y <= curr_btn_y + curr_btn_height);

   if (is_curr_btn_hovered && !filter_curr_hovered) {
      ObjectSetInteger(0, FILTER_CURR_BTN, OBJPROP_BGCOLOR, clrDarkGray);
      filter_curr_hovered = true;
   } else if (!is_curr_btn_hovered && filter_curr_hovered) {
      ObjectSetInteger(0, FILTER_CURR_BTN, OBJPROP_BGCOLOR, clrBlack);
      filter_curr_hovered = false;
   }

   // FILTER_IMP_BTN hover
   int imp_btn_x = (int)ObjectGetInteger(0, FILTER_IMP_BTN, OBJPROP_XDISTANCE);
   int imp_btn_y = (int)ObjectGetInteger(0, FILTER_IMP_BTN, OBJPROP_YDISTANCE);
   int imp_btn_width = 120;
   int imp_btn_height = 26;

   bool is_imp_btn_hovered = (mouse_x >= imp_btn_x && mouse_x <= imp_btn_x + imp_btn_width &&
                              mouse_y >= imp_btn_y && mouse_y <= imp_btn_y + imp_btn_height);

   if (is_imp_btn_hovered && !filter_imp_hovered) {
      ObjectSetInteger(0, FILTER_IMP_BTN, OBJPROP_BGCOLOR, clrDarkGray);
      filter_imp_hovered = true;
   } else if (!is_imp_btn_hovered && filter_imp_hovered) {
      ObjectSetInteger(0, FILTER_IMP_BTN, OBJPROP_BGCOLOR, clrBlack);
      filter_imp_hovered = false;
   }

   // FILTER_TIME_BTN hover
   int time_btn_x = (int)ObjectGetInteger(0, FILTER_TIME_BTN, OBJPROP_XDISTANCE);
   int time_btn_y = (int)ObjectGetInteger(0, FILTER_TIME_BTN, OBJPROP_YDISTANCE);
   int time_btn_width = 70;
   int time_btn_height = 26;

   bool is_time_btn_hovered = (mouse_x >= time_btn_x && mouse_x <= time_btn_x + time_btn_width &&
                               mouse_y >= time_btn_y && mouse_y <= time_btn_y + time_btn_height);

   if (is_time_btn_hovered && !filter_time_hovered) {
      ObjectSetInteger(0, FILTER_TIME_BTN, OBJPROP_BGCOLOR, clrDarkGray);
      filter_time_hovered = true;
   } else if (!is_time_btn_hovered && filter_time_hovered) {
      ObjectSetInteger(0, FILTER_TIME_BTN, OBJPROP_BGCOLOR, clrBlack);
      filter_time_hovered = false;
   }

   // CANCEL_BTN hover
   int cancel_btn_x = (int)ObjectGetInteger(0, CANCEL_BTN, OBJPROP_XDISTANCE);
   int cancel_btn_y = (int)ObjectGetInteger(0, CANCEL_BTN, OBJPROP_YDISTANCE);
   int cancel_btn_width = 50;
   int cancel_btn_height = 30;

   bool is_cancel_btn_hovered = (mouse_x >= cancel_btn_x && mouse_x <= cancel_btn_x + cancel_btn_width &&
                                 mouse_y >= cancel_btn_y && mouse_y <= cancel_btn_y + cancel_btn_height);

   if (is_cancel_btn_hovered && !cancel_hovered) {
      ObjectSetInteger(0, CANCEL_BTN, OBJPROP_BGCOLOR, clrDarkRed);
      cancel_hovered = true;
   } else if (!is_cancel_btn_hovered && cancel_hovered) {
      ObjectSetInteger(0, CANCEL_BTN, OBJPROP_BGCOLOR, clrRed);
      cancel_hovered = false;
   }

   // CURRENCY_BTNS hover
   int curr_size = 51, button_height = 22, spacing_x = 0, spacing_y = 3, max_columns = 4;
   for (int i = 0; i < ArraySize(curr_filter); i++) {
      int row = i / max_columns;
      int col = i % max_columns;
      int x_pos = panel_x + 525 + col * (curr_size + spacing_x);
      int y_pos = panel_y + 33 + row * (button_height + spacing_y);
      bool is_curr_hovered = (mouse_x >= x_pos && mouse_x <= x_pos + curr_size &&
                              mouse_y >= y_pos && mouse_y <= y_pos + button_height);
      string btn_name = CURRENCY_BTNS+IntegerToString(i);
      if (is_curr_hovered && !currency_btns_hovered[i]) {
         ObjectSetInteger(0, btn_name, OBJPROP_BGCOLOR, clrLightGray);
         currency_btns_hovered[i] = true;
      } else if (!is_curr_hovered && currency_btns_hovered[i]) {
         ObjectSetInteger(0, btn_name, OBJPROP_BGCOLOR, clrNONE);
         currency_btns_hovered[i] = false;
      }
   }

   // IMPACT_LABEL buttons hover
   int impact_size = 100;
   for (int i = 0; i < ArraySize(impact_labels); i++) {
      int x_pos = panel_x + 90 + impact_size * i;
      int y_pos = panel_y + 55;
      bool is_impact_hovered = (mouse_x >= x_pos && mouse_x <= x_pos + impact_size &&
                                mouse_y >= y_pos && mouse_y <= y_pos + 25);
      string btn_name = IMPACT_LABEL+string(i);
      color normal_color = clrBlack;
      if (impact_labels[i] == "None") normal_color = clrBlack;
      else if (impact_labels[i] == "Low") normal_color = clrYellow;
      else if (impact_labels[i] == "Medium") normal_color = clrOrange;
      else if (impact_labels[i] == "High") normal_color = clrRed;
      color hover_color = normal_color == clrBlack ? clrDarkGray : ColorToDarken(normal_color);
      if (is_impact_hovered && !impact_btns_hovered[i]) {
         ObjectSetInteger(0, btn_name, OBJPROP_BGCOLOR, hover_color);
         impact_btns_hovered[i] = true;
      } else if (!is_impact_hovered && impact_btns_hovered[i]) {
         ObjectSetInteger(0, btn_name, OBJPROP_BGCOLOR, normal_color);
         impact_btns_hovered[i] = false;
      }
   }
}

//+------------------------------------------------------------------+
//| Helper function to darken a color for hover effect                |
//+------------------------------------------------------------------+
color ColorToDarken(color clr) {
   int r = (clr & 0xFF);
   int g = ((clr >> 8) & 0xFF);
   int b = ((clr >> 16) & 0xFF);
   r = MathMax(0, r - 50);
   g = MathMax(0, g - 50);
   b = MathMax(0, b - 50);
   return (color)((b << 16) | (g << 8) | r);
}

//+------------------------------------------------------------------+
//| Chart event handler                                               |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam) {
   int mouse_x = (int)lparam;
   int mouse_y = (int)dparam;
   int mouse_state = (int)sparam;

   // Update hover states
   if (id == CHARTEVENT_MOUSE_MOVE) {
      updateHoverStates(mouse_x, mouse_y);
   }

   if (id == CHARTEVENT_OBJECT_CLICK) {
      UpdateFilterInfo();
      CheckForNewsTrade();
      if (sparam == CANCEL_BTN) {
         isDashboardUpdate = false;
         destroy_Dashboard();
      }
      if (sparam == FILTER_CURR_BTN) {
         bool btn_state = ObjectGetInteger(0,sparam,OBJPROP_STATE);
         enableCurrencyFilter = btn_state;
         if (debugLogging) Print(sparam+" STATE = "+(string)btn_state+", FLAG = "+(string)enableCurrencyFilter);
         string filter_curr_text = enableCurrencyFilter ? ShortToString(0x2714)+"Currency" : ShortToString(0x274C)+"Currency";
         color filter_curr_txt_color = enableCurrencyFilter ? clrLime : clrRed;
         ObjectSetString(0,FILTER_CURR_BTN,OBJPROP_TEXT,filter_curr_text);
         ObjectSetInteger(0,FILTER_CURR_BTN,OBJPROP_COLOR,filter_curr_txt_color);
         if (MQLInfoInteger(MQL_TESTER)) filters_changed = true;
         update_dashboard_values(curr_filter_selected,imp_filter_selected);
         // Recalculate scrollbar
         ObjectDelete(0, SCROLL_LEADER);
         ObjectDelete(0, SCROLL_UP_REC);
         ObjectDelete(0, SCROLL_UP_LABEL);
         ObjectDelete(0, SCROLL_DOWN_REC);
         ObjectDelete(0, SCROLL_DOWN_LABEL);
         ObjectDelete(0, SCROLL_SLIDER);
         scroll_visible = totalEvents_Filtered > VISIBLE_ITEMS;
         if (debugLogging) Print("Scrollbar visibility: ", scroll_visible ? "Visible" : "Hidden");
         if (scroll_visible) {
            createRecLabel(SCROLL_LEADER, panel_x + SCROLLBAR_X_OFFSET, panel_y + SCROLLBAR_Y_OFFSET, SCROLLBAR_WIDTH, SCROLLBAR_HEIGHT, clrSilver, 1, clrNONE);
            int max_scroll = MathMax(0, ArraySize(displayableEvents) - VISIBLE_ITEMS);
            color up_color = (scroll_pos == 0) ? clrLightGray : clrBlack;
            color down_color = (scroll_pos >= max_scroll) ? clrLightGray : clrBlack;
            createRecLabel(SCROLL_UP_REC, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, panel_y + SCROLLBAR_Y_OFFSET, BUTTON_WIDTH, BUTTON_SIZE, clrDarkGray, 1, clrDarkGray);
            createLabel(SCROLL_UP_LABEL, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, panel_y + SCROLLBAR_Y_OFFSET-5, CharToString(0x35), up_color, 15, "Webdings");
            int down_y = panel_y + SCROLLBAR_Y_OFFSET + SCROLLBAR_HEIGHT - BUTTON_SIZE;
            createRecLabel(SCROLL_DOWN_REC, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, down_y, BUTTON_WIDTH, BUTTON_SIZE, clrDarkGray, 1, clrDarkGray);
            createLabel(SCROLL_DOWN_LABEL, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, down_y-5, CharToString(0x36), down_color, 15, "Webdings");
            slider_height = calculateSliderHeight();
            int slider_y = panel_y + SCROLLBAR_Y_OFFSET + BUTTON_SIZE;
            createButton(SCROLL_SLIDER, panel_x + SCROLLBAR_X_OFFSET + SLIDER_OFFSET_X, slider_y, SLIDER_WIDTH, slider_height, "", clrWhite, 12, clrLightSlateGray, clrDarkGray, "Arial Bold");
            ObjectSetInteger(0, SCROLL_SLIDER, OBJPROP_WIDTH, 2);
            if (debugLogging) Print("Scrollbar created: totalEvents_Filtered=", totalEvents_Filtered, ", slider_height=", slider_height);
            updateSliderPosition();
            updateButtonColors();
         }
         if (debugLogging) Print("Success. Changes updated! State: "+(string)enableCurrencyFilter);
         ChartRedraw(0);
      }
      if (sparam == FILTER_IMP_BTN) {
         bool btn_state = ObjectGetInteger(0,sparam,OBJPROP_STATE);
         enableImportanceFilter = btn_state;
         if (debugLogging) Print(sparam+" STATE = "+(string)btn_state+", FLAG = "+(string)enableImportanceFilter);
         string filter_imp_text = enableImportanceFilter ? ShortToString(0x2714)+"Importance" : ShortToString(0x274C)+"Importance";
         color filter_imp_txt_color = enableImportanceFilter ? clrLime : clrRed;
         ObjectSetString(0,FILTER_IMP_BTN,OBJPROP_TEXT,filter_imp_text);
         ObjectSetInteger(0,FILTER_IMP_BTN,OBJPROP_COLOR,filter_imp_txt_color);
         if (MQLInfoInteger(MQL_TESTER)) filters_changed = true;
         update_dashboard_values(curr_filter_selected,imp_filter_selected);
         // Recalculate scrollbar
         ObjectDelete(0, SCROLL_LEADER);
         ObjectDelete(0, SCROLL_UP_REC);
         ObjectDelete(0, SCROLL_UP_LABEL);
         ObjectDelete(0, SCROLL_DOWN_REC);
         ObjectDelete(0, SCROLL_DOWN_LABEL);
         ObjectDelete(0, SCROLL_SLIDER);
         scroll_visible = totalEvents_Filtered > VISIBLE_ITEMS;
         if (debugLogging) Print("Scrollbar visibility: ", scroll_visible ? "Visible" : "Hidden");
         if (scroll_visible) {
            createRecLabel(SCROLL_LEADER, panel_x + SCROLLBAR_X_OFFSET, panel_y + SCROLLBAR_Y_OFFSET, SCROLLBAR_WIDTH, SCROLLBAR_HEIGHT, clrSilver, 1, clrNONE);
            int max_scroll = MathMax(0, ArraySize(displayableEvents) - VISIBLE_ITEMS);
            color up_color = (scroll_pos == 0) ? clrLightGray : clrBlack;
            color down_color = (scroll_pos >= max_scroll) ? clrLightGray : clrBlack;
            createRecLabel(SCROLL_UP_REC, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, panel_y + SCROLLBAR_Y_OFFSET, BUTTON_WIDTH, BUTTON_SIZE, clrDarkGray, 1, clrDarkGray);
            createLabel(SCROLL_UP_LABEL, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, panel_y + SCROLLBAR_Y_OFFSET-5, CharToString(0x35), up_color, 15, "Webdings");
            int down_y = panel_y + SCROLLBAR_Y_OFFSET + SCROLLBAR_HEIGHT - BUTTON_SIZE;
            createRecLabel(SCROLL_DOWN_REC, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, down_y, BUTTON_WIDTH, BUTTON_SIZE, clrDarkGray, 1, clrDarkGray);
            createLabel(SCROLL_DOWN_LABEL, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, down_y-5, CharToString(0x36), down_color, 15, "Webdings");
            slider_height = calculateSliderHeight();
            int slider_y = panel_y + SCROLLBAR_Y_OFFSET + BUTTON_SIZE;
            createButton(SCROLL_SLIDER, panel_x + SCROLLBAR_X_OFFSET + SLIDER_OFFSET_X, slider_y, SLIDER_WIDTH, slider_height, "", clrWhite, 12, clrLightSlateGray, clrDarkGray, "Arial Bold");
            ObjectSetInteger(0, SCROLL_SLIDER, OBJPROP_WIDTH, 2);
            if (debugLogging) Print("Scrollbar created: totalEvents_Filtered=", totalEvents_Filtered, ", slider_height=", slider_height);
            updateSliderPosition();
            updateButtonColors();
         }
         if (debugLogging) Print("Success. Changes updated! State: "+(string)enableImportanceFilter);
         ChartRedraw(0);
      }
      if (sparam == FILTER_TIME_BTN) {
         bool btn_state = ObjectGetInteger(0,sparam,OBJPROP_STATE);
         enableTimeFilter = btn_state;
         if (debugLogging) Print(sparam+" STATE = "+(string)btn_state+", FLAG = "+(string)enableTimeFilter);
         string filter_time_text = enableTimeFilter ? ShortToString(0x2714)+"Time" : ShortToString(0x274C)+"Time";
         color filter_time_txt_color = enableTimeFilter ? clrLime : clrRed;
         ObjectSetString(0,FILTER_TIME_BTN,OBJPROP_TEXT,filter_time_text);
         ObjectSetInteger(0,FILTER_TIME_BTN,OBJPROP_COLOR,filter_time_txt_color);
         if (MQLInfoInteger(MQL_TESTER)) filters_changed = true;
         update_dashboard_values(curr_filter_selected,imp_filter_selected);
         // Recalculate scrollbar
         ObjectDelete(0, SCROLL_LEADER);
         ObjectDelete(0, SCROLL_UP_REC);
         ObjectDelete(0, SCROLL_UP_LABEL);
         ObjectDelete(0, SCROLL_DOWN_REC);
         ObjectDelete(0, SCROLL_DOWN_LABEL);
         ObjectDelete(0, SCROLL_SLIDER);
         scroll_visible = totalEvents_Filtered > VISIBLE_ITEMS;
         if (debugLogging) Print("Scrollbar visibility: ", scroll_visible ? "Visible" : "Hidden");
         if (scroll_visible) {
            createRecLabel(SCROLL_LEADER, panel_x + SCROLLBAR_X_OFFSET, panel_y + SCROLLBAR_Y_OFFSET, SCROLLBAR_WIDTH, SCROLLBAR_HEIGHT, clrSilver, 1, clrNONE);
            int max_scroll = MathMax(0, ArraySize(displayableEvents) - VISIBLE_ITEMS);
            color up_color = (scroll_pos == 0) ? clrLightGray : clrBlack;
            color down_color = (scroll_pos >= max_scroll) ? clrLightGray : clrBlack;
            createRecLabel(SCROLL_UP_REC, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, panel_y + SCROLLBAR_Y_OFFSET, BUTTON_WIDTH, BUTTON_SIZE, clrDarkGray, 1, clrDarkGray);
            createLabel(SCROLL_UP_LABEL, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, panel_y + SCROLLBAR_Y_OFFSET-5, CharToString(0x35), up_color, 15, "Webdings");
            int down_y = panel_y + SCROLLBAR_Y_OFFSET + SCROLLBAR_HEIGHT - BUTTON_SIZE;
            createRecLabel(SCROLL_DOWN_REC, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, down_y, BUTTON_WIDTH, BUTTON_SIZE, clrDarkGray, 1, clrDarkGray);
            createLabel(SCROLL_DOWN_LABEL, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, down_y-5, CharToString(0x36), down_color, 15, "Webdings");
            slider_height = calculateSliderHeight();
            int slider_y = panel_y + SCROLLBAR_Y_OFFSET + BUTTON_SIZE;
            createButton(SCROLL_SLIDER, panel_x + SCROLLBAR_X_OFFSET + SLIDER_OFFSET_X, slider_y, SLIDER_WIDTH, slider_height, "", clrWhite, 12, clrLightSlateGray, clrDarkGray, "Arial Bold");
            ObjectSetInteger(0, SCROLL_SLIDER, OBJPROP_WIDTH, 2);
            if (debugLogging) Print("Scrollbar created: totalEvents_Filtered=", totalEvents_Filtered, ", slider_height=", slider_height);
            updateSliderPosition();
            updateButtonColors();
         }
         if (debugLogging) Print("Success. Changes updated! State: "+(string)enableTimeFilter);
         ChartRedraw(0);
      }
      if (StringFind(sparam,CURRENCY_BTNS) >= 0) {
         string selected_curr = ObjectGetString(0,sparam,OBJPROP_TEXT);
         if (debugLogging) Print("BTN NAME = ",sparam,", CURRENCY = ",selected_curr);
         bool btn_state = ObjectGetInteger(0,sparam,OBJPROP_STATE);
         if (btn_state == false) {
            if (debugLogging) Print("BUTTON IS IN UN-SELECTED MODE.");
            for (int i = 0; i < ArraySize(curr_filter_selected); i++) {
               if (curr_filter_selected[i] == selected_curr) {
                  for (int j = i; j < ArraySize(curr_filter_selected) - 1; j++) {
                     curr_filter_selected[j] = curr_filter_selected[j + 1];
                  }
                  ArrayResize(curr_filter_selected, ArraySize(curr_filter_selected) - 1);
                  if (debugLogging) Print("Removed from selected filters: ", selected_curr);
                  break;
               }
            }
         } else {
            if (debugLogging) Print("BUTTON IS IN SELECTED MODE. TAKE ACTION");
            bool already_selected = false;
            for (int j = 0; j < ArraySize(curr_filter_selected); j++) {
               if (curr_filter_selected[j] == selected_curr) {
                  already_selected = true;
                  break;
               }
            }
            if (!already_selected) {
               ArrayResize(curr_filter_selected, ArraySize(curr_filter_selected) + 1);
               curr_filter_selected[ArraySize(curr_filter_selected) - 1] = selected_curr;
               if (debugLogging) Print("Added to selected filters: ", selected_curr);
            } else {
               if (debugLogging) Print("Currency already selected: ", selected_curr);
            }
         }
         if (debugLogging) Print("SELECTED ARRAY SIZE = ",ArraySize(curr_filter_selected));
         if (debugLogging) ArrayPrint(curr_filter_selected);
         if (MQLInfoInteger(MQL_TESTER)) filters_changed = true;
         update_dashboard_values(curr_filter_selected,imp_filter_selected);
         // Recalculate scrollbar
         ObjectDelete(0, SCROLL_LEADER);
         ObjectDelete(0, SCROLL_UP_REC);
         ObjectDelete(0, SCROLL_UP_LABEL);
         ObjectDelete(0, SCROLL_DOWN_REC);
         ObjectDelete(0, SCROLL_DOWN_LABEL);
         ObjectDelete(0, SCROLL_SLIDER);
         scroll_visible = totalEvents_Filtered > VISIBLE_ITEMS;
         if (debugLogging) Print("Scrollbar visibility: ", scroll_visible ? "Visible" : "Hidden");
         if (scroll_visible) {
            createRecLabel(SCROLL_LEADER, panel_x + SCROLLBAR_X_OFFSET, panel_y + SCROLLBAR_Y_OFFSET, SCROLLBAR_WIDTH, SCROLLBAR_HEIGHT, clrSilver, 1, clrNONE);
            int max_scroll = MathMax(0, ArraySize(displayableEvents) - VISIBLE_ITEMS);
            color up_color = (scroll_pos == 0) ? clrLightGray : clrBlack;
            color down_color = (scroll_pos >= max_scroll) ? clrLightGray : clrBlack;
            createRecLabel(SCROLL_UP_REC, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, panel_y + SCROLLBAR_Y_OFFSET, BUTTON_WIDTH, BUTTON_SIZE, clrDarkGray, 1, clrDarkGray);
            createLabel(SCROLL_UP_LABEL, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, panel_y + SCROLLBAR_Y_OFFSET-5, CharToString(0x35), up_color, 15, "Webdings");
            int down_y = panel_y + SCROLLBAR_Y_OFFSET + SCROLLBAR_HEIGHT - BUTTON_SIZE;
            createRecLabel(SCROLL_DOWN_REC, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, down_y, BUTTON_WIDTH, BUTTON_SIZE, clrDarkGray, 1, clrDarkGray);
            createLabel(SCROLL_DOWN_LABEL, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, down_y-5, CharToString(0x36), down_color, 15, "Webdings");
            slider_height = calculateSliderHeight();
            int slider_y = panel_y + SCROLLBAR_Y_OFFSET + BUTTON_SIZE;
            createButton(SCROLL_SLIDER, panel_x + SCROLLBAR_X_OFFSET + SLIDER_OFFSET_X, slider_y, SLIDER_WIDTH, slider_height, "", clrWhite, 12, clrLightSlateGray, clrDarkGray, "Arial Bold");
            ObjectSetInteger(0, SCROLL_SLIDER, OBJPROP_WIDTH, 2);
            if (debugLogging) Print("Scrollbar created: totalEvents_Filtered=", totalEvents_Filtered, ", slider_height=", slider_height);
            updateSliderPosition();
            updateButtonColors();
         }
         if (debugLogging) Print("SUCCESS. DASHBOARD UPDATED");
         ChartRedraw(0);
      }
      if (StringFind(sparam, IMPACT_LABEL) >= 0) {
         string selected_imp = ObjectGetString(0, sparam, OBJPROP_TEXT);
         ENUM_CALENDAR_EVENT_IMPORTANCE selected_importance_lvl = get_importance_level(impact_labels,allowed_importance_levels,selected_imp);
         if (debugLogging) Print("BTN NAME = ", sparam, ", IMPORTANCE LEVEL = ", selected_imp,"(",selected_importance_lvl,")");
         bool btn_state = ObjectGetInteger(0, sparam, OBJPROP_STATE);
         color color_border = btn_state ? clrNONE : clrBlack;
         if (btn_state == false) {
            if (debugLogging) Print("BUTTON IS IN UN-SELECTED MODE.");
            for (int i = 0; i < ArraySize(imp_filter_selected); i++) {
               if (impact_filter_selected[i] == selected_imp) {
                  for (int j = i; j < ArraySize(imp_filter_selected) - 1; j++) {
                     imp_filter_selected[j] = imp_filter_selected[j + 1];
                     impact_filter_selected[j] = impact_filter_selected[j + 1];
                  }
                  ArrayResize(imp_filter_selected, ArraySize(imp_filter_selected) - 1);
                  ArrayResize(impact_filter_selected, ArraySize(impact_filter_selected) - 1);
                  if (debugLogging) Print("Removed from selected importance filters: ", selected_imp,"(",selected_importance_lvl,")");
                  break;
               }
            }
         } else {
            if (debugLogging) Print("BUTTON IS IN SELECTED MODE. TAKE ACTION");
            bool already_selected = false;
            for (int j = 0; j < ArraySize(imp_filter_selected); j++) {
               if (impact_filter_selected[j] == selected_imp) {
                  already_selected = true;
                  break;
               }
            }
            if (!already_selected) {
               ArrayResize(imp_filter_selected, ArraySize(imp_filter_selected) + 1);
               ArrayResize(impact_filter_selected, ArraySize(impact_filter_selected) + 1);
               imp_filter_selected[ArraySize(imp_filter_selected) - 1] = selected_importance_lvl;
               impact_filter_selected[ArraySize(impact_filter_selected) - 1] = selected_imp;
               if (debugLogging) Print("Added to selected importance filters: ", selected_imp,"(",selected_importance_lvl,")");
            } else {
               if (debugLogging) Print("Importance level already selected: ", selected_imp,"(",selected_importance_lvl,")");
            }
         }
         if (debugLogging) Print("SELECTED ARRAY SIZE = ", ArraySize(imp_filter_selected)," >< ",ArraySize(impact_filter_selected));
         if (debugLogging) ArrayPrint(imp_filter_selected);
         if (debugLogging) ArrayPrint(impact_filter_selected);
         if (MQLInfoInteger(MQL_TESTER)) filters_changed = true;
         update_dashboard_values(curr_filter_selected,imp_filter_selected);
         ObjectSetInteger(0,sparam,OBJPROP_BORDER_COLOR,color_border);
         // Recalculate scrollbar
         ObjectDelete(0, SCROLL_LEADER);
         ObjectDelete(0, SCROLL_UP_REC);
         ObjectDelete(0, SCROLL_UP_LABEL);
         ObjectDelete(0, SCROLL_DOWN_REC);
         ObjectDelete(0, SCROLL_DOWN_LABEL);
         ObjectDelete(0, SCROLL_SLIDER);
         scroll_visible = totalEvents_Filtered > VISIBLE_ITEMS;
         if (debugLogging) Print("Scrollbar visibility: ", scroll_visible ? "Visible" : "Hidden");
         if (scroll_visible) {
            createRecLabel(SCROLL_LEADER, panel_x + SCROLLBAR_X_OFFSET, panel_y + SCROLLBAR_Y_OFFSET, SCROLLBAR_WIDTH, SCROLLBAR_HEIGHT, clrSilver, 1, clrNONE);
            int max_scroll = MathMax(0, ArraySize(displayableEvents) - VISIBLE_ITEMS);
            color up_color = (scroll_pos == 0) ? clrLightGray : clrBlack;
            color down_color = (scroll_pos >= max_scroll) ? clrLightGray : clrBlack;
            createRecLabel(SCROLL_UP_REC, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, panel_y + SCROLLBAR_Y_OFFSET, BUTTON_WIDTH, BUTTON_SIZE, clrDarkGray, 1, clrDarkGray);
            createLabel(SCROLL_UP_LABEL, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, panel_y + SCROLLBAR_Y_OFFSET-5, CharToString(0x35), up_color, 15, "Webdings");
            int down_y = panel_y + SCROLLBAR_Y_OFFSET + SCROLLBAR_HEIGHT - BUTTON_SIZE;
            createRecLabel(SCROLL_DOWN_REC, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, down_y, BUTTON_WIDTH, BUTTON_SIZE, clrDarkGray, 1, clrDarkGray);
            createLabel(SCROLL_DOWN_LABEL, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, down_y-5, CharToString(0x36), down_color, 15, "Webdings");
            slider_height = calculateSliderHeight();
            int slider_y = panel_y + SCROLLBAR_Y_OFFSET + BUTTON_SIZE;
            createButton(SCROLL_SLIDER, panel_x + SCROLLBAR_X_OFFSET + SLIDER_OFFSET_X, slider_y, SLIDER_WIDTH, slider_height, "", clrWhite, 12, clrLightSlateGray, clrDarkGray, "Arial Bold");
            ObjectSetInteger(0, SCROLL_SLIDER, OBJPROP_WIDTH, 2);
            if (debugLogging) Print("Scrollbar created: totalEvents_Filtered=", totalEvents_Filtered, ", slider_height=", slider_height);
            updateSliderPosition();
            updateButtonColors();
         }
         if (debugLogging) Print("SUCCESS. DASHBOARD UPDATED");
         ChartRedraw(0);
      }
      // Scrollbar button clicks
      if (scroll_visible && (sparam == SCROLL_UP_REC || sparam == SCROLL_UP_LABEL)) {
         scrollUp();
         updateButtonColors();
         if (debugLogging) Print("Up button clicked (", sparam, "). CurrPos: ", scroll_pos);
         ChartRedraw(0);
      }
      if (scroll_visible && (sparam == SCROLL_DOWN_REC || sparam == SCROLL_DOWN_LABEL)) {
         scrollDown();
         updateButtonColors();
         if (debugLogging) Print("Down button clicked (", sparam, "). CurrPos: ", scroll_pos);
         ChartRedraw(0);
      }
   }
   else if (id == CHARTEVENT_MOUSE_MOVE && isDashboardUpdate) {
      // Handle panel dragging
      int header_x = (int)ObjectGetInteger(0, HEADER_LABEL, OBJPROP_XDISTANCE);
      int header_y = (int)ObjectGetInteger(0, HEADER_LABEL, OBJPROP_YDISTANCE);
      int header_width = 740;
      int header_height = 30;

      if (prev_mouse_state == 0 && mouse_state == 1) { // Mouse button down
         if (mouse_x >= header_x && mouse_x <= header_x + header_width &&
             mouse_y >= header_y && mouse_y <= header_y + header_height) {
            panel_dragging = true;
            panel_drag_x = mouse_x;
            panel_drag_y = mouse_y;
            panel_start_x = panel_x;
            panel_start_y = panel_y;
            ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
            if (debugLogging) Print("Panel drag started at x=", mouse_x, ", y=", mouse_y);
         }
      }

      if (panel_dragging && mouse_state == 1) { // Dragging panel
         int dx = mouse_x - panel_drag_x;
         int dy = mouse_y - panel_drag_y;
         panel_x = panel_start_x + dx;
         panel_y = panel_start_y + dy;

         // Ensure panel stays within chart boundaries
         int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
         int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
         panel_x = MathMax(0, MathMin(panel_x, chart_width - 753)); // 753 = panel width
         panel_y = MathMax(0, MathMin(panel_y, chart_height - 410)); // 410 = panel height

         // Update positions of all panel objects
         ObjectSetInteger(0, MAIN_REC, OBJPROP_XDISTANCE, panel_x);
         ObjectSetInteger(0, MAIN_REC, OBJPROP_YDISTANCE, panel_y);
         ObjectSetInteger(0, SUB_REC1, OBJPROP_XDISTANCE, panel_x + 3);
         ObjectSetInteger(0, SUB_REC1, OBJPROP_YDISTANCE, panel_y + 30);
         ObjectSetInteger(0, SUB_REC2, OBJPROP_XDISTANCE, panel_x + 3 + 5);
         ObjectSetInteger(0, SUB_REC2, OBJPROP_YDISTANCE, panel_y + 30 + 50 + 27);
         ObjectSetInteger(0, HEADER_LABEL, OBJPROP_XDISTANCE, panel_x + 3 + 5);
         ObjectSetInteger(0, HEADER_LABEL, OBJPROP_YDISTANCE, panel_y + 5);
         ObjectSetInteger(0, TIME_LABEL, OBJPROP_XDISTANCE, panel_x + 20);
         ObjectSetInteger(0, TIME_LABEL, OBJPROP_YDISTANCE, panel_y + 35);
         ObjectSetInteger(0, IMPACT_LABEL, OBJPROP_XDISTANCE, panel_x + 20);
         ObjectSetInteger(0, IMPACT_LABEL, OBJPROP_YDISTANCE, panel_y + 55);
         ObjectSetInteger(0, FILTER_LABEL, OBJPROP_XDISTANCE, panel_x + 320);
         ObjectSetInteger(0, FILTER_LABEL, OBJPROP_YDISTANCE, panel_y + 5);
         ObjectSetInteger(0, FILTER_CURR_BTN, OBJPROP_XDISTANCE, panel_x + 380);
         ObjectSetInteger(0, FILTER_CURR_BTN, OBJPROP_YDISTANCE, panel_y + 5);
         ObjectSetInteger(0, FILTER_IMP_BTN, OBJPROP_XDISTANCE, panel_x + 490);
         ObjectSetInteger(0, FILTER_IMP_BTN, OBJPROP_YDISTANCE, panel_y + 5);
         ObjectSetInteger(0, FILTER_TIME_BTN, OBJPROP_XDISTANCE, panel_x + 610);
         ObjectSetInteger(0, FILTER_TIME_BTN, OBJPROP_YDISTANCE, panel_y + 5);
         ObjectSetInteger(0, CANCEL_BTN, OBJPROP_XDISTANCE, panel_x + 692+10);
         ObjectSetInteger(0, CANCEL_BTN, OBJPROP_YDISTANCE, panel_y + 1);

         // Update calendar buttons
         int startX = panel_x + 9;
         for (int i = 0; i < ArraySize(array_calendar); i++) {
            ObjectSetInteger(0, ARRAY_CALENDAR+IntegerToString(i), OBJPROP_XDISTANCE, startX);
            ObjectSetInteger(0, ARRAY_CALENDAR+IntegerToString(i), OBJPROP_YDISTANCE, panel_y + 82);
            startX += buttons[i] + 3;
         }

         // Update impact buttons
         for (int i = 0; i < ArraySize(impact_labels); i++) {
            ObjectSetInteger(0, IMPACT_LABEL+string(i), OBJPROP_XDISTANCE, panel_x + 90 + 100 * i);
            ObjectSetInteger(0, IMPACT_LABEL+string(i), OBJPROP_YDISTANCE, panel_y + 55);
         }

         // Update currency buttons
         int curr_size = 51, button_height = 22, spacing_x = 0, spacing_y = 3, max_columns = 4;
         for (int i = 0; i < ArraySize(curr_filter); i++) {
            int row = i / max_columns;
            int col = i % max_columns;
            int x_pos = panel_x + 525 + col * (curr_size + spacing_x);
            int y_pos = panel_y + 33 + row * (button_height + spacing_y);
            ObjectSetInteger(0, CURRENCY_BTNS+IntegerToString(i), OBJPROP_XDISTANCE, x_pos);
            ObjectSetInteger(0, CURRENCY_BTNS+IntegerToString(i), OBJPROP_YDISTANCE, y_pos);
         }

         // Update scrollbar
         if (scroll_visible) {
            ObjectSetInteger(0, SCROLL_LEADER, OBJPROP_XDISTANCE, panel_x + SCROLLBAR_X_OFFSET);
            ObjectSetInteger(0, SCROLL_LEADER, OBJPROP_YDISTANCE, panel_y + SCROLLBAR_Y_OFFSET);
            ObjectSetInteger(0, SCROLL_UP_REC, OBJPROP_XDISTANCE, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X);
            ObjectSetInteger(0, SCROLL_UP_REC, OBJPROP_YDISTANCE, panel_y + SCROLLBAR_Y_OFFSET);
            ObjectSetInteger(0, SCROLL_UP_LABEL, OBJPROP_XDISTANCE, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X);
            ObjectSetInteger(0, SCROLL_UP_LABEL, OBJPROP_YDISTANCE, panel_y + SCROLLBAR_Y_OFFSET - 5);
            ObjectSetInteger(0, SCROLL_DOWN_REC, OBJPROP_XDISTANCE, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X);
            ObjectSetInteger(0, SCROLL_DOWN_REC, OBJPROP_YDISTANCE, panel_y + SCROLLBAR_Y_OFFSET + SCROLLBAR_HEIGHT - BUTTON_SIZE);
            ObjectSetInteger(0, SCROLL_DOWN_LABEL, OBJPROP_XDISTANCE, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X);
            ObjectSetInteger(0, SCROLL_DOWN_LABEL, OBJPROP_YDISTANCE, panel_y + SCROLLBAR_Y_OFFSET + SCROLLBAR_HEIGHT - BUTTON_SIZE - 5);
            ObjectSetInteger(0, SCROLL_SLIDER, OBJPROP_XDISTANCE, panel_x + SCROLLBAR_X_OFFSET + SLIDER_OFFSET_X);
            // Y-position of slider is managed by updateSliderPosition()
         }

         // Update event display
         update_dashboard_values(curr_filter_selected, imp_filter_selected);

         // Update trade labels if they exist
         if (ObjectFind(0, "NewsCountdown") >= 0) {
            ObjectSetInteger(0, "NewsCountdown", OBJPROP_XDISTANCE, panel_x);
            ObjectSetInteger(0, "NewsCountdown", OBJPROP_YDISTANCE, panel_y - 33);
         }
         if (ObjectFind(0, "NewsTradeInfo") >= 0) {
            ObjectSetInteger(0, "NewsTradeInfo", OBJPROP_XDISTANCE, panel_x + 305);
            ObjectSetInteger(0, "NewsTradeInfo", OBJPROP_YDISTANCE, panel_y - 28);
         }

         ChartRedraw(0);
         if (debugLogging) Print("Panel moved to x=", panel_x, ", y=", panel_y);
      }

      if (mouse_state == 0) { // Mouse button released
         if (panel_dragging) {
            panel_dragging = false;
            ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
            if (debugLogging) Print("Panel drag stopped.");
            ChartRedraw(0);
         }
      }

      // Scrollbar handling (only if not dragging panel)
      if (scroll_visible && !panel_dragging) {
         if (prev_mouse_state == 0 && mouse_state == 1) {
            int xd = (int)ObjectGetInteger(0, SCROLL_SLIDER, OBJPROP_XDISTANCE);
            int yd = (int)ObjectGetInteger(0, SCROLL_SLIDER, OBJPROP_YDISTANCE);
            int xs = (int)ObjectGetInteger(0, SCROLL_SLIDER, OBJPROP_XSIZE);
            int ys = (int)ObjectGetInteger(0, SCROLL_SLIDER, OBJPROP_YSIZE);
            // Skip if mouse is over header to prioritize panel dragging
            if (mouse_x >= (panel_x + 3 + 5) && mouse_x <= (panel_x + 3 + 5 + 740) &&
                mouse_y >= (panel_y + 5) && mouse_y <= (panel_y + 5 + 30)) {
                return;
            }
            if (mouse_x >= xd && mouse_x <= xd + xs && mouse_y >= yd && mouse_y <= yd + ys) {
               moving_state_slider = true;
               mlb_down_x = mouse_x;
               mlb_down_y = mouse_y;
               mlb_down_yd_slider = yd;
               ObjectSetInteger(0, SCROLL_SLIDER, OBJPROP_BGCOLOR, clrDodgerBlue);
               ObjectSetInteger(0, SCROLL_SLIDER, OBJPROP_YSIZE, slider_height + 2);
               ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
               if (debugLogging) Print("Slider drag started at y=", mouse_y);
            }
         }
         if (moving_state_slider && mouse_state == 1) {
            int delta_y = mouse_y - mlb_down_y;
            int new_y = mlb_down_yd_slider + delta_y;
            int scroll_area_y_min = panel_y + SCROLLBAR_Y_OFFSET + BUTTON_SIZE;
            int scroll_area_y_max = scroll_area_y_min + SCROLL_AREA_HEIGHT - slider_height;
            new_y = MathMax(scroll_area_y_min, MathMin(new_y, scroll_area_y_max));
            ObjectSetInteger(0, SCROLL_SLIDER, OBJPROP_YDISTANCE, new_y);
            int max_scroll = MathMax(0, ArraySize(displayableEvents) - VISIBLE_ITEMS);
            double scroll_ratio = (double)(new_y - scroll_area_y_min) / (scroll_area_y_max - scroll_area_y_min);
            int new_scroll_pos = (int)MathRound(scroll_ratio * max_scroll);
            if (new_scroll_pos != scroll_pos) {
               scroll_pos = new_scroll_pos;
               update_dashboard_values(curr_filter_selected, imp_filter_selected);
               updateButtonColors();
               if (debugLogging) Print("Slider dragged. CurrPos: ", scroll_pos, ", Total steps: ", max_scroll, ", Slider y=", new_y);
            }
            ChartRedraw(0);
         }
         if (mouse_state == 0) {
            if (moving_state_slider) {
               moving_state_slider = false;
               ObjectSetInteger(0, SCROLL_SLIDER, OBJPROP_BGCOLOR, clrLightSlateGray);
               ObjectSetInteger(0, SCROLL_SLIDER, OBJPROP_YSIZE, slider_height);
               ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
               if (debugLogging) Print("Slider drag stopped.");
               ChartRedraw(0);
            }
         }
      }
      prev_mouse_state = mouse_state;
   }
}

//+------------------------------------------------------------------+
//| Load events from CSV resource                                    |
//+------------------------------------------------------------------+
bool LoadEventsFromResource() {
   string fileData = EconomicCalendarData;
   if (StringLen(fileData) == 0) {
      Print("Error: EconomicCalendar.csv is empty!");
      return false;
   }
   if (debugLogging) Print("Raw resource content (size: ", StringLen(fileData), " bytes):\n", StringSubstr(fileData, 0, 100), "...");
   string lines[];
   int lineCount = StringSplit(fileData, '\n', lines);
   if (lineCount <= 1) {
      Print("Error: No data lines found in resource! Raw data: ", StringSubstr(fileData, 0, 100));
      return false;
   }
   ArrayResize(allEvents, 0);
   int eventIndex = 0;
   for (int i = 1; i < lineCount; i++) {
      if (StringLen(lines[i]) == 0) {
         if (debugLogging) Print("Skipping empty line ", i);
         continue;
      }
      string fields[];
      int fieldCount = StringSplit(lines[i], ',', fields);
      if (debugLogging) Print("Line ", i, ": ", lines[i], " (field count: ", fieldCount, ")");
      if (fieldCount < 8) {
         Print("Malformed line ", i, ": ", lines[i], " (field count: ", fieldCount, ")");
         continue;
      }
      string dateStr = fields[0];
      string timeStr = fields[1];
      string currency = fields[2];
      string event = fields[3];
      for (int j = 4; j < fieldCount - 4; j++) {
         event += "," + fields[j];
      }
      string importance = fields[fieldCount - 4];
      string actualStr = fields[fieldCount - 3];
      string forecastStr = fields[fieldCount - 2];
      string previousStr = fields[fieldCount - 1];
      datetime eventDateTime = StringToTime(dateStr + " " + timeStr);
      if (eventDateTime == 0) {
         StringReplace(dateStr, "/", "-");
         eventDateTime = StringToTime(dateStr + " " + timeStr);
         if (eventDateTime == 0) {
            Print("Error: Invalid datetime conversion for line ", i, ": ", dateStr, " ", timeStr);
            continue;
         }
      }
      ArrayResize(allEvents, eventIndex + 1);
      allEvents[eventIndex].eventDate = dateStr;
      allEvents[eventIndex].eventTime = timeStr;
      allEvents[eventIndex].currency = currency;
      allEvents[eventIndex].event = event;
      allEvents[eventIndex].importance = importance;
      allEvents[eventIndex].actual = StringToDouble(actualStr);
      allEvents[eventIndex].forecast = StringToDouble(forecastStr);
      allEvents[eventIndex].previous = StringToDouble(previousStr);
      allEvents[eventIndex].eventDateTime = eventDateTime;
      if (debugLogging) Print("Loaded event ", eventIndex, ": ", dateStr, " ", timeStr, ", ", currency, ", ", event);
      eventIndex++;
   }
   Print("Loaded ", eventIndex, " events from resource into array.");
   return eventIndex > 0;
}

//+------------------------------------------------------------------+
//| Update dashboard values                                           |
//+------------------------------------------------------------------+
void update_dashboard_values(string &curr_filter_array[], ENUM_CALENDAR_EVENT_IMPORTANCE &imp_filter_array[]) {
   totalEvents_Considered = 0;
   totalEvents_Filtered = 0;
   totalEvents_Displayable = 0;
   ArrayFree(current_eventNames_data);
   ArrayFree(current_displayable_eventNames);

   datetime timeRange = PeriodSeconds(range_time);
   datetime timeBefore = TimeTradeServer() - timeRange;
   datetime timeAfter = TimeTradeServer() + timeRange;

   // Populate displayableEvents
   if (MQLInfoInteger(MQL_TESTER)) {
      if (filters_changed) {
         FilterEventsForTester();
         ArrayFree(displayableEvents);
      }
      int eventIndex = 0;
      for (int i = 0; i < ArraySize(filteredEvents); i++) {
         totalEvents_Considered++;
         datetime eventDateTime = filteredEvents[i].eventDateTime;
         if (eventDateTime < StartDate || eventDateTime > EndDate) {
            if (debugLogging) Print("Event ", filteredEvents[i].event, " skipped due to date range.");
            continue;
         }

         bool timeMatch = !enableTimeFilter;
         if (enableTimeFilter) {
            if (eventDateTime <= TimeTradeServer() && eventDateTime >= timeBefore) timeMatch = true;
            else if (eventDateTime >= TimeTradeServer() && eventDateTime <= timeAfter) timeMatch = true;
         }
         if (!timeMatch) {
            if (debugLogging) Print("Event ", filteredEvents[i].event, " skipped due to time filter.");
            continue;
         }

         bool currencyMatch = !enableCurrencyFilter;
         if (enableCurrencyFilter) {
            for (int j = 0; j < ArraySize(curr_filter_array); j++) {
               if (filteredEvents[i].currency == curr_filter_array[j]) {
                  currencyMatch = true;
                  break;
               }
            }
         }
         if (!currencyMatch) {
            if (debugLogging) Print("Event ", filteredEvents[i].event, " skipped due to currency filter.");
            continue;
         }

         bool importanceMatch = !enableImportanceFilter;
         if (enableImportanceFilter) {
            string imp_str = filteredEvents[i].importance;
            ENUM_CALENDAR_EVENT_IMPORTANCE event_imp = (imp_str == "None") ? CALENDAR_IMPORTANCE_NONE :
                                                      (imp_str == "Low") ? CALENDAR_IMPORTANCE_LOW :
                                                      (imp_str == "Medium") ? CALENDAR_IMPORTANCE_MODERATE :
                                                      CALENDAR_IMPORTANCE_HIGH;
            for (int k = 0; k < ArraySize(imp_filter_array); k++) {
               if (event_imp == imp_filter_array[k]) {
                  importanceMatch = true;
                  break;
               }
            }
         }
         if (!importanceMatch) {
            if (debugLogging) Print("Event ", filteredEvents[i].event, " skipped due to importance filter.");
            continue;
         }

         ArrayResize(displayableEvents, eventIndex + 1);
         displayableEvents[eventIndex] = filteredEvents[i];
         ArrayResize(current_displayable_eventNames, eventIndex + 1);
         current_displayable_eventNames[eventIndex] = filteredEvents[i].event;
         eventIndex++;
      }
      totalEvents_Filtered = ArraySize(displayableEvents);
      if (debugLogging) Print("Tester mode: Stored ", totalEvents_Filtered, " displayable events.");
   } else {
      MqlCalendarValue values[];
      datetime startTime = TimeTradeServer() - PeriodSeconds(start_time);
      datetime endTime = TimeTradeServer() + PeriodSeconds(end_time);
      int allValues = CalendarValueHistory(values, startTime, endTime, NULL, NULL);
      int eventIndex = 0;
      if (filters_changed) ArrayFree(displayableEvents);
      for (int i = 0; i < allValues; i++) {
         MqlCalendarEvent event;
         CalendarEventById(values[i].event_id, event);
         MqlCalendarCountry country;
         CalendarCountryById(event.country_id, country);
         MqlCalendarValue value;
         CalendarValueById(values[i].id, value);
         totalEvents_Considered++;

         bool currencyMatch = false;
         if (enableCurrencyFilter) {
            for (int j = 0; j < ArraySize(curr_filter_array); j++) {
               if (country.currency == curr_filter_array[j]) {
                  currencyMatch = true;
                  break;
               }
            }
            if (!currencyMatch) continue;
         }

         bool importanceMatch = false;
         if (enableImportanceFilter) {
            for (int k = 0; k < ArraySize(imp_filter_array); k++) {
               if (event.importance == imp_filter_array[k]) {
                  importanceMatch = true;
                  break;
               }
            }
            if (!importanceMatch) continue;
         }

         bool timeMatch = false;
         if (enableTimeFilter) {
            datetime eventTime = values[i].time;
            if (eventTime <= TimeTradeServer() && eventTime >= timeBefore) timeMatch = true;
            else if (eventTime >= TimeTradeServer() && eventTime <= timeAfter) timeMatch = true;
            if (!timeMatch) continue;
         }

         ArrayResize(displayableEvents, eventIndex + 1);
         displayableEvents[eventIndex].eventDate = TimeToString(values[i].time, TIME_DATE);
         displayableEvents[eventIndex].eventTime = TimeToString(values[i].time, TIME_MINUTES);
         displayableEvents[eventIndex].currency = country.currency;
         displayableEvents[eventIndex].event = event.name;
         displayableEvents[eventIndex].importance = (event.importance == CALENDAR_IMPORTANCE_NONE) ? "None" :
                                                   (event.importance == CALENDAR_IMPORTANCE_LOW) ? "Low" :
                                                   (event.importance == CALENDAR_IMPORTANCE_MODERATE) ? "Medium" : "High";
         displayableEvents[eventIndex].actual = value.GetActualValue();
         displayableEvents[eventIndex].forecast = value.GetForecastValue();
         displayableEvents[eventIndex].previous = value.GetPreviousValue();
         displayableEvents[eventIndex].eventDateTime = values[i].time;
         ArrayResize(current_displayable_eventNames, eventIndex + 1);
         current_displayable_eventNames[eventIndex] = event.name;
         eventIndex++;
      }
      totalEvents_Filtered = ArraySize(displayableEvents);
      if (debugLogging) Print("Live mode: Stored ", totalEvents_Filtered, " displayable events.");
   }

   bool events_changed = isChangeInStringArrays(previous_displayable_eventNames, current_displayable_eventNames);
   bool scroll_changed = (scroll_pos != prev_scroll_pos);
   if (events_changed || filters_changed || scroll_changed) {
      if (debugLogging) {
         if (events_changed) Print("Changes detected in displayable events.");
         if (filters_changed) Print("Filter changes detected.");
         if (scroll_changed) Print("Scroll position changed: ", prev_scroll_pos, " -> ", scroll_pos);
      }
      ArrayFree(previous_displayable_eventNames);
      ArrayCopy(previous_displayable_eventNames, current_displayable_eventNames);
      prev_scroll_pos = scroll_pos;

      ObjectsDeleteAll(0, DATA_HOLDERS);
      ObjectsDeleteAll(0, ARRAY_NEWS);

      int startY = panel_y + LIST_Y_OFFSET;
      int start_idx = scroll_visible ? scroll_pos : 0;
      int end_idx = MathMin(start_idx + VISIBLE_ITEMS, ArraySize(displayableEvents));
      for (int i = start_idx; i < end_idx; i++) {
         totalEvents_Displayable++;
         color holder_color = (totalEvents_Displayable % 2 == 0) ? C'213,227,207' : clrWhite;
         createRecLabel(DATA_HOLDERS+string(totalEvents_Displayable), panel_x + LIST_X_OFFSET, startY-1, LIST_WIDTH, ITEM_HEIGHT+1, holder_color, 1, clrNONE);

         int startX = panel_x + LIST_X_OFFSET + 3;
         string news_data[ArraySize(array_calendar)];
         news_data[0] = displayableEvents[i].eventDate;
         news_data[1] = displayableEvents[i].eventTime;
         news_data[2] = displayableEvents[i].currency;
         color importance_color = clrBlack;
         if (displayableEvents[i].importance == "Low") importance_color = clrYellow;
         else if (displayableEvents[i].importance == "Medium") importance_color = clrOrange;
         else if (displayableEvents[i].importance == "High") importance_color = clrRed;
         news_data[3] = ShortToString(0x25CF);
         news_data[4] = displayableEvents[i].event;
         news_data[5] = DoubleToString(displayableEvents[i].actual, 3);         news_data[6] = DoubleToString(displayableEvents[i].forecast, 3);
         news_data[7] = DoubleToString(displayableEvents[i].previous, 3);

         for (int k = 0; k < ArraySize(array_calendar); k++) {
            if (k == 3) {
               createLabel(ARRAY_NEWS+IntegerToString(i)+" "+array_calendar[k], startX, startY-(22-12), news_data[k], importance_color, 22, "Calibri");
            } else {
               createLabel(ARRAY_NEWS+IntegerToString(i)+" "+array_calendar[k], startX, startY, news_data[k], clrBlack, 12, "Calibri");
            }
            startX += buttons[k]+3;
         }

         ArrayResize(current_eventNames_data, ArraySize(current_eventNames_data)+1);
         current_eventNames_data[ArraySize(current_eventNames_data)-1] = displayableEvents[i].event;
         startY += ITEM_HEIGHT;
      }

      if (debugLogging) Print("Displayed ", totalEvents_Displayable, " events, start_idx=", start_idx, ", end_idx=", end_idx);
   } else {
      if (debugLogging) Print("No changes detected. Skipping redraw.");
   }

   // Update TIME_LABEL
   string timeText = updateServerTime ? "Server Time: "+TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS) : "Server Time: Static";
   updateLabel(TIME_LABEL, timeText+"   |||   Total News: "+IntegerToString(totalEvents_Filtered)+"/"+IntegerToString(totalEvents_Considered));

   // Update scrollbar visibility
   bool new_scroll_visible = totalEvents_Filtered > VISIBLE_ITEMS;
   if (new_scroll_visible != scroll_visible || events_changed || filters_changed) {
      scroll_visible = new_scroll_visible;
      if (debugLogging) Print("Scrollbar visibility: ", scroll_visible ? "Visible" : "Hidden");
      if (scroll_visible) {
         if (ObjectFind(0, SCROLL_LEADER) < 0) {
            createRecLabel(SCROLL_LEADER, panel_x + SCROLLBAR_X_OFFSET, panel_y + SCROLLBAR_Y_OFFSET, SCROLLBAR_WIDTH, SCROLLBAR_HEIGHT, clrSilver, 1, clrNONE);
            int max_scroll = MathMax(0, ArraySize(displayableEvents) - VISIBLE_ITEMS);
            color up_color = (scroll_pos == 0) ? clrLightGray : clrBlack;
            color down_color = (scroll_pos >= max_scroll) ? clrLightGray : clrBlack;
            createRecLabel(SCROLL_UP_REC, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, panel_y + SCROLLBAR_Y_OFFSET, BUTTON_WIDTH, BUTTON_SIZE, clrDarkGray, 1, clrDarkGray);
            createLabel(SCROLL_UP_LABEL, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, panel_y + SCROLLBAR_Y_OFFSET-5, CharToString(0x35), up_color, 15, "Webdings");
            int down_y = panel_y + SCROLLBAR_Y_OFFSET + SCROLLBAR_HEIGHT - BUTTON_SIZE;
            createRecLabel(SCROLL_DOWN_REC, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, down_y, BUTTON_WIDTH, BUTTON_SIZE, clrDarkGray, 1, clrDarkGray);
            createLabel(SCROLL_DOWN_LABEL, panel_x + SCROLLBAR_X_OFFSET + BUTTON_OFFSET_X, down_y-5, CharToString(0x36), down_color, 15, "Webdings");
            slider_height = calculateSliderHeight();
            int slider_y = panel_y + SCROLLBAR_Y_OFFSET + BUTTON_SIZE;
            createButton(SCROLL_SLIDER, panel_x + SCROLLBAR_X_OFFSET + SLIDER_OFFSET_X, slider_y, SLIDER_WIDTH, slider_height, "", clrWhite, 12, clrLightSlateGray, clrDarkGray, "Arial Bold");
            ObjectSetInteger(0, SCROLL_SLIDER, OBJPROP_WIDTH, 2);
            if (debugLogging) Print("Scrollbar created: totalEvents_Filtered=", totalEvents_Filtered, ", slider_height=", slider_height);
         }
         updateSliderPosition();
         updateButtonColors();
      } else {
         ObjectDelete(0, SCROLL_LEADER);
         ObjectDelete(0, SCROLL_UP_REC);
         ObjectDelete(0, SCROLL_UP_LABEL);
         ObjectDelete(0, SCROLL_DOWN_REC);
         ObjectDelete(0, SCROLL_DOWN_LABEL);
         ObjectDelete(0, SCROLL_SLIDER);
         if (debugLogging) Print("Scrollbar removed: totalEvents_Filtered=", totalEvents_Filtered);
      }
   }

   if (isChangeInStringArrays(previous_eventNames_data, current_eventNames_data)) {
      if (debugLogging) Print("CHANGES IN EVENT NAMES DETECTED.");
      ArrayFree(previous_eventNames_data);
      ArrayCopy(previous_eventNames_data, current_eventNames_data);
   }
}

//+------------------------------------------------------------------+
//| Check for news trade                                              |
//+------------------------------------------------------------------+
void CheckForNewsTrade() {
   if (debugLogging) Print("CheckForNewsTrade called at: ", TimeToString(TimeTradeServer(), TIME_SECONDS));
   if (tradeMode == NO_TRADE || tradeMode == PAUSE_TRADING) {
      if (ObjectFind(0, "NewsCountdown") >= 0) {
         ObjectDelete(0, "NewsCountdown");
         Print("Trading disabled. Countdown removed.");
      }
      return;
   }

   datetime currentTime = TimeTradeServer();
   int offsetSeconds = tradeOffsetHours * 3600 + tradeOffsetMinutes * 60 + tradeOffsetSeconds;

   if (tradeExecuted) {
      if (currentTime < tradedNewsTime) {
         int remainingSeconds = (int)(tradedNewsTime - currentTime);
         int hrs = remainingSeconds / 3600;
         int mins = (remainingSeconds % 3600) / 60;
         int secs = remainingSeconds % 60;
         string countdownText = "News in: " + IntegerToString(hrs) + "h " +
                               IntegerToString(mins) + "m " + IntegerToString(secs) + "s";
         if (ObjectFind(0, "NewsCountdown") < 0) {
            createButton1("NewsCountdown", panel_x, panel_y - 33, 300, 30, countdownText, clrWhite, 12, clrBlue, clrBlack);
            Print("Post-trade countdown created: ", countdownText);
         } else {
            updateLabel1("NewsCountdown", countdownText);
            Print("Post-trade countdown updated: ", countdownText);
         }
      } else {
         int elapsed = (int)(currentTime - tradedNewsTime);
         if (elapsed < 15) {
            int remainingDelay = 15 - elapsed;
            string countdownText = "News Released, resetting in: " + IntegerToString(remainingDelay) + "s";
            if (ObjectFind(0, "NewsCountdown") < 0) {
               createButton1("NewsCountdown", panel_x, panel_y - 33, 300, 30, countdownText, clrWhite, 12, clrRed, clrBlack);
               ObjectSetInteger(0,"NewsCountdown",OBJPROP_BGCOLOR,clrRed);
               Print("Post-trade reset countdown created: ", countdownText);
            } else {
               updateLabel1("NewsCountdown", countdownText);
               ObjectSetInteger(0,"NewsCountdown",OBJPROP_BGCOLOR,clrRed);
               Print("Post-trade reset countdown updated: ", countdownText);
            }
         } else {
            Print("News Released. Resetting trade status after 15 seconds.");
            if (ObjectFind(0, "NewsCountdown") >= 0) ObjectDelete(0, "NewsCountdown");
            tradeExecuted = false;
         }
      }
      return;
   }

   datetime lowerBound = currentTime - PeriodSeconds(start_time);
   datetime upperBound = currentTime + PeriodSeconds(end_time);
   if (debugLogging) Print("Event time range: ", TimeToString(lowerBound, TIME_SECONDS), " to ", TimeToString(upperBound, TIME_SECONDS));

   datetime candidateEventTime = 0;
   string candidateEventName = "";
   string candidateTradeSide = "";
   int candidateEventID = -1;

   if (MQLInfoInteger(MQL_TESTER)) {
      int totalValues = ArraySize(filteredEvents);
      if (debugLogging) Print("Total events found: ", totalValues);
      if (totalValues <= 0) {
         if (ObjectFind(0, "NewsCountdown") >= 0) ObjectDelete(0, "NewsCountdown");
         return;
      }

      for (int i = 0; i < totalValues; i++) {
         datetime eventTime = filteredEvents[i].eventDateTime;
         if (eventTime < lowerBound || eventTime > upperBound || eventTime < StartDate || eventTime > EndDate) {
            if (debugLogging) Print("Event ", filteredEvents[i].event, " skipped due to date range.");
            continue;
         }

         bool currencyMatch = !enableCurrencyFilter;
         if (enableCurrencyFilter) {
            for (int k = 0; k < ArraySize(curr_filter_selected); k++) {
               if (filteredEvents[i].currency == curr_filter_selected[k]) {
                  currencyMatch = true;
                  break;
               }
            }
            if (!currencyMatch) {
               if (debugLogging) Print("Event ", filteredEvents[i].event, " skipped due to currency filter.");
               continue;
            }
         }

         bool impactMatch = !enableImportanceFilter;
         if (enableImportanceFilter) {
            string imp_str = filteredEvents[i].importance;
            ENUM_CALENDAR_EVENT_IMPORTANCE event_imp = (imp_str == "None") ? CALENDAR_IMPORTANCE_NONE :
                                                      (imp_str == "Low") ? CALENDAR_IMPORTANCE_LOW :
                                                      (imp_str == "Medium") ? CALENDAR_IMPORTANCE_MODERATE :
                                                      CALENDAR_IMPORTANCE_HIGH;
            for (int k = 0; k < ArraySize(imp_filter_selected); k++) {
               if (event_imp == imp_filter_selected[k]) {
                  impactMatch = true;
                  break;
               }
            }
            if (!impactMatch) {
               if (debugLogging) Print("Event ", filteredEvents[i].event, " skipped due to impact filter.");
               continue;
            }
         }

         bool alreadyTriggered = false;
         for (int j = 0; j < ArraySize(triggeredNewsEvents); j++) {
            if (triggeredNewsEvents[j] == i) {
               alreadyTriggered = true;
               break;
            }
         }
         if (alreadyTriggered) {
            if (debugLogging) Print("Event ", filteredEvents[i].event, " already triggered a trade. Skipping.");
            continue;
         }

         if (tradeMode == TRADE_BEFORE) {
            if (currentTime >= (eventTime - offsetSeconds) && currentTime < eventTime) {
               double forecast = filteredEvents[i].forecast;
               double previous = filteredEvents[i].previous;
               if (forecast == 0.0 || previous == 0.0) {
                  if (debugLogging) Print("Skipping event ", filteredEvents[i].event, " because forecast or previous value is empty.");
                  continue;
               }
               if (forecast == previous) {
                  if (debugLogging) Print("Skipping event ", filteredEvents[i].event, " because forecast equals previous.");
                  continue;
               }
               if (candidateEventTime == 0 || eventTime < candidateEventTime) {
                  candidateEventTime = eventTime;
                  candidateEventName = filteredEvents[i].event;
                  candidateEventID = i;
                  candidateTradeSide = (forecast > previous) ? "BUY" : "SELL";
                  if (debugLogging) Print("Candidate event: ", filteredEvents[i].event, " with event time: ", TimeToString(eventTime, TIME_SECONDS), " Side: ", candidateTradeSide);
               }
            }
         }
      }
   } else {
      MqlCalendarValue values[];
      int totalValues = CalendarValueHistory(values, lowerBound, upperBound, NULL, NULL);
      Print("Total events found: ", totalValues);
      if (totalValues <= 0) {
         if (ObjectFind(0, "NewsCountdown") >= 0) ObjectDelete(0, "NewsCountdown");
         return;
      }

      for (int i = 0; i < totalValues; i++) {
         MqlCalendarEvent event;
         if (!CalendarEventById(values[i].event_id, event)) continue;
         MqlCalendarCountry country;
         CalendarCountryById(event.country_id, country);
         bool currencyMatch = false;
         if (enableCurrencyFilter) {
            for (int k = 0; k < ArraySize(curr_filter_selected); k++) {
               if (country.currency == curr_filter_selected[k]) {
                  currencyMatch = true;
                  break;
               }
            }
            if (!currencyMatch) {
               Print("Event ", event.name, " skipped due to currency filter.");
               continue;
            }
         }
         bool impactMatch = false;
         if (enableImportanceFilter) {
            for (int k = 0; k < ArraySize(imp_filter_selected); k++) {
               if (event.importance == imp_filter_selected[k]) {
                  impactMatch = true;
                  break;
               }
            }
            if (!impactMatch) {
               Print("Event ", event.name, " skipped due to impact filter.");
               continue;
            }
         }
         if (enableTimeFilter && values[i].time > upperBound) {
            Print("Event ", event.name, " skipped due to time filter.");
            continue;
         }
         bool alreadyTriggered = false;
         for (int j = 0; j < ArraySize(triggeredNewsEvents); j++) {
            if (triggeredNewsEvents[j] == values[i].event_id) {
               alreadyTriggered = true;
               break;
            }
         }
         if (alreadyTriggered) {
            Print("Event ", event.name, " already triggered a trade. Skipping.");
            continue;
         }
         if (tradeMode == TRADE_BEFORE) {
            if (currentTime >= (values[i].time - offsetSeconds) && currentTime < values[i].time) {
               MqlCalendarValue calValue;
               if (!CalendarValueById(values[i].id, calValue)) {
                  Print("Error retrieving calendar value for event: ", event.name);
                  continue;
               }
               double forecast = calValue.GetForecastValue();
               double previous = calValue.GetPreviousValue();
               if (forecast == 0.0 || previous == 0.0) {
                  Print("Skipping event ", event.name, " because forecast or previous value is empty.");
                  continue;
               }
               if (forecast == previous) {
                  Print("Skipping event ", event.name, " because forecast equals previous.");
                  continue;
               }
               if (candidateEventTime == 0 || values[i].time < candidateEventTime) {
                  candidateEventTime = values[i].time;
                  candidateEventName = event.name;
                  candidateEventID = (int)values[i].event_id;
                  candidateTradeSide = (forecast > previous) ? "BUY" : "SELL";
                  Print("Candidate event: ", event.name, " with event time: ", TimeToString(values[i].time, TIME_SECONDS), " Side: ", candidateTradeSide);
               }
            }
         }
      }
   }

   if (tradeMode == TRADE_BEFORE && candidateEventTime > 0) {
      datetime targetTime = candidateEventTime - offsetSeconds;
      if (debugLogging) Print("Candidate target time: ", TimeToString(targetTime, TIME_SECONDS));
      if (currentTime >= targetTime && currentTime < candidateEventTime) {
         if (MQLInfoInteger(MQL_TESTER)) {
            for (int i = 0; i < ArraySize(filteredEvents); i++) {
               datetime eventTime = filteredEvents[i].eventDateTime;
               if (eventTime == candidateEventTime) {
                  if (currentTime >= eventTime) {
                     if (debugLogging) Print("Skipping candidate ", filteredEvents[i].event, " because current time is past event time.");
                     continue;
                  }
                  double forecast = filteredEvents[i].forecast;
                  double previous = filteredEvents[i].previous;
                  if (forecast == 0.0 || previous == 0.0 || forecast == previous) {
                     if (debugLogging) Print("Skipping candidate ", filteredEvents[i].event, " due to invalid forecast/previous values.");
                     continue;
                  }
                  string newsInfo = "Trading on news: " + filteredEvents[i].event +
                                    " ("+TimeToString(eventTime, TIME_MINUTES)+")";
                  Print(newsInfo);
                  createLabel1("NewsTradeInfo", panel_x + 305, panel_y - 28, newsInfo, clrBlue, 11);
                  bool tradeResult = false;
                  if (candidateTradeSide == "BUY") {
                     tradeResult = trade.Buy(tradeLotSize, _Symbol, 0, 0, 0, filteredEvents[i].event);
                  } else if (candidateTradeSide == "SELL") {
                     tradeResult = trade.Sell(tradeLotSize, _Symbol, 0, 0, 0, filteredEvents[i].event);
                  }
                  if (tradeResult) {
                     Print("Trade executed for candidate event: ", filteredEvents[i].event, " Side: ", candidateTradeSide);
                     int size = ArraySize(triggeredNewsEvents);
                     ArrayResize(triggeredNewsEvents, size + 1);
                     triggeredNewsEvents[size] = i;
                     tradeExecuted = true;
                     tradedNewsTime = eventTime;
                  } else {
                     Print("Trade execution failed for candidate event: ", filteredEvents[i].event, " Error: ", GetLastError());
                  }
                  break;
               }
            }
         } else {
            MqlCalendarValue values[];
            int totalValues = CalendarValueHistory(values, lowerBound, upperBound, NULL, NULL);
            for (int i = 0; i < totalValues; i++) {
               if (values[i].time == candidateEventTime) {
                  MqlCalendarEvent event;
                  if (!CalendarEventById(values[i].event_id, event)) continue;
                  if (currentTime >= values[i].time) {
                     Print("Skipping candidate ", event.name, " because current time is past event time.");
                     continue;
                  }
                  MqlCalendarValue calValue;
                  if (!CalendarValueById(values[i].id, calValue)) {
                     Print("Error retrieving calendar value for candidate event: ", event.name);
                     continue;
                  }
                  double forecast = calValue.GetForecastValue();
                  double previous = calValue.GetPreviousValue();
                  if (forecast == 0.0 || previous == 0.0 || forecast == previous) {
                     Print("Skipping candidate ", event.name, " due to invalid forecast/previous values.");
                     continue;
                  }
                  string newsInfo = "Trading on news: " + event.name +
                                    " ("+TimeToString(values[i].time, TIME_MINUTES)+")";
                  Print(newsInfo);
                  createLabel1("NewsTradeInfo", panel_x + 305, panel_y - 28, newsInfo, clrBlue, 11);
                  bool tradeResult = false;
                  if (candidateTradeSide == "BUY") {
                     tradeResult = trade.Buy(tradeLotSize, _Symbol, 0, 0, 0, event.name);
                  } else if (candidateTradeSide == "SELL") {
                     tradeResult = trade.Sell(tradeLotSize, _Symbol, 0, 0, 0, event.name);
                  }
                  if (tradeResult) {
                     Print("Trade executed for candidate event: ", event.name, " Side: ", candidateTradeSide);
                     int size = ArraySize(triggeredNewsEvents);
                     ArrayResize(triggeredNewsEvents, size + 1);
                     triggeredNewsEvents[size] = (int)values[i].event_id;
                     tradeExecuted = true;
                     tradedNewsTime = values[i].time;
                  } else {
                     Print("Trade execution failed for candidate event: ", event.name, " Error: ", GetLastError());
                  }
                  break;
               }
            }
         }
      } else {
         int remainingSeconds = (int)(candidateEventTime - currentTime);
         int hrs = remainingSeconds / 3600;
         int mins = (remainingSeconds % 3600) / 60;
         int secs = remainingSeconds % 60;
         string countdownText = "News in: " + IntegerToString(hrs) + "h " +
                               IntegerToString(mins) + "m " + IntegerToString(secs) + "s";
         if (ObjectFind(0, "NewsCountdown") < 0) {
            createButton1("NewsCountdown", panel_x, panel_y - 33, 300, 30, countdownText, clrWhite, 12, clrBlue, clrBlack);
            Print("Pre-trade countdown created: ", countdownText);
         } else {
            updateLabel1("NewsCountdown", countdownText);
            Print("Pre-trade countdown updated: ", countdownText);
         }
      }
   } else {
      if (ObjectFind(0, "NewsCountdown") >= 0) {
         ObjectDelete(0, "NewsCountdown");
         ObjectDelete(0, "NewsTradeInfo");
         Print("Pre-trade countdown deleted.");
      }
   }
}

//+------------------------------------------------------------------+
//| Get importance level                                              |
//+------------------------------------------------------------------+
ENUM_CALENDAR_EVENT_IMPORTANCE get_importance_level(string &impact_label[], ENUM_CALENDAR_EVENT_IMPORTANCE &importance_levels[], string selected_label) {
   for (int i = 0; i < ArraySize(impact_label); i++) {
      if (impact_label[i] == selected_label) {
         return importance_levels[i];
      }
   }
   return CALENDAR_IMPORTANCE_NONE;
}

//+------------------------------------------------------------------+
//| Destroy dashboard                                                 |
//+------------------------------------------------------------------+
void destroy_Dashboard() {
   ObjectDelete(0, "MAIN_REC");
   ObjectDelete(0, "SUB_REC1");
   ObjectDelete(0, "SUB_REC2");
   ObjectDelete(0, "HEADER_LABEL");
   ObjectDelete(0, "TIME_LABEL");
   ObjectDelete(0, "IMPACT_LABEL");
   ObjectsDeleteAll(0, "ARRAY_CALENDAR");
   ObjectsDeleteAll(0, "ARRAY_NEWS");
   ObjectsDeleteAll(0, "DATA_HOLDERS");
   ObjectsDeleteAll(0, "IMPACT_LABEL");
   ObjectDelete(0, "FILTER_LABEL");
   ObjectDelete(0, "FILTER_CURR_BTN");
   ObjectDelete(0, "FILTER_IMP_BTN");
   ObjectDelete(0, "FILTER_TIME_BTN");
   ObjectDelete(0, "CANCEL_BTN");
   ObjectsDeleteAll(0, "CURRENCY_BTNS");
   ObjectDelete(0, SCROLL_LEADER);
   ObjectDelete(0, SCROLL_UP_REC);
   ObjectDelete(0, SCROLL_UP_LABEL);
   ObjectDelete(0, SCROLL_DOWN_REC);
   ObjectDelete(0, SCROLL_DOWN_LABEL);
   ObjectDelete(0, SCROLL_SLIDER);
   ArrayFree(displayableEvents);
   ArrayFree(current_displayable_eventNames);
   ArrayFree(previous_displayable_eventNames);
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Delete trade objects                                              |
//+------------------------------------------------------------------+
void deleteTradeObjects() {
   ObjectDelete(0, "NewsCountdown");
   ObjectDelete(0, "NewsTradeInfo");
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Update filter info                                                |
//+------------------------------------------------------------------+
void UpdateFilterInfo() {
   string filterInfo = "Filters: ";
   if (enableCurrencyFilter) {
      filterInfo += "Currency: ";
      for (int i = 0; i < ArraySize(curr_filter_selected); i++) {
         filterInfo += curr_filter_selected[i];
         if (i < ArraySize(curr_filter_selected) - 1) filterInfo += ",";
      }
      filterInfo += "; ";
   } else {
      filterInfo += "Currency: Off; ";
   }
   if (enableImportanceFilter) {
      filterInfo += "Impact: ";
      for (int i = 0; i < ArraySize(imp_filter_selected); i++) {
         filterInfo += EnumToString(imp_filter_selected[i]);
         if (i < ArraySize(imp_filter_selected) - 1) filterInfo += ",";
      }
      filterInfo += "; ";
   } else {
      filterInfo += "Impact: Off; ";
   }
   if (enableTimeFilter) {
      filterInfo += "Time: Up to " + EnumToString(end_time);
   } else {
      filterInfo += "Time: Off";
   }
   if (debugLogging) Print("Filter Info: ", filterInfo);
}

//+------------------------------------------------------------------+
//| Check for news events                                             |
//+------------------------------------------------------------------+
bool isNewsEvent() {
   int totalNews = 0;
   bool isNews = false;
   MqlCalendarValue values[];
   datetime startTime = TimeTradeServer() - PeriodSeconds(PERIOD_D1);
   datetime endTime = TimeTradeServer() + PeriodSeconds(PERIOD_D1);
   int valuesTotal = CalendarValueHistory(values, startTime, endTime, NULL, NULL);
   Print("TOTAL VALUES = ", valuesTotal, " || Array size = ", ArraySize(values));
   datetime timeRange = PeriodSeconds(PERIOD_D1);
   datetime timeBefore = TimeTradeServer() - timeRange;
   datetime timeAfter = TimeTradeServer() + timeRange;
   Print("Current time = ", TimeTradeServer());
   Print("FURTHEST TIME LOOK BACK = ", timeBefore, " >>> LOOK FORE = ", timeAfter);
   for (int i = 0; i < valuesTotal; i++) {
      MqlCalendarEvent event;
      CalendarEventById(values[i].event_id, event);
      MqlCalendarCountry country;
      CalendarCountryById(event.country_id, country);
      if (StringFind(_Symbol, country.currency) >= 0) {
         if (event.importance == CALENDAR_IMPORTANCE_MODERATE) {
            if (values[i].time <= TimeTradeServer() && values[i].time >= timeBefore) {
               Print(event.name, " > ", country.currency, " > ", EnumToString(event.importance), " Time= ", values[i].time, " (ALREADY RELEASED)");
               totalNews++;
            }
            if (values[i].time >= TimeTradeServer() && values[i].time <= timeAfter) {
               Print(event.name, " > ", country.currency, " > ", EnumToString(event.importance), " Time= ", values[i].time, " (NOT YET RELEASED)");
               totalNews++;
            }
         }
      }
   }
   if (totalNews > 0) {
      isNews = true;
      Print(">>>>>>> (FOUND NEWS) TOTAL NEWS = ", totalNews, "/", ArraySize(values));
   } else {
      isNews = false;
      Print(">>>>>>> (NOT FOUND NEWS) TOTAL NEWS = ", totalNews, "/", ArraySize(values));
   }
   return isNews;
}

//+------------------------------------------------------------------+
//| Create rectangle label                                            |
//+------------------------------------------------------------------+
bool createRecLabel(string objName, int xD, int yD, int xS, int yS, color clrBg, int widthBorder,
                    color clrBorder = clrNONE, ENUM_BORDER_TYPE borderType = BORDER_FLAT,
                    ENUM_LINE_STYLE borderStyle = STYLE_SOLID) {
   ResetLastError();
   if (!ObjectCreate(0, objName, OBJ_RECTANGLE_LABEL, 0, 0, 0)) {
      Print(__FUNCTION__, ": failed to create rec label! Error code = ", _LastError);
      return false;
   }
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, xD);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, yD);
   ObjectSetInteger(0, objName, OBJPROP_XSIZE, xS);
   ObjectSetInteger(0, objName, OBJPROP_YSIZE, yS);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, clrBg);
   ObjectSetInteger(0, objName, OBJPROP_BORDER_TYPE, borderType);
   ObjectSetInteger(0, objName, OBJPROP_STYLE, borderStyle);
   ObjectSetInteger(0, objName, OBJPROP_WIDTH, widthBorder);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clrBorder);
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
   ObjectSetInteger(0, objName, OBJPROP_STATE, false);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_SELECTED, false);
   ChartRedraw(0);
   return true;
}

//+------------------------------------------------------------------+
//| Create button                                                     |
//+------------------------------------------------------------------+
bool createButton(string objName, int xD, int yD, int xS, int yS, string txt = "", color clrTxt = clrBlack,
                  int fontSize = 12, color clrBg = clrNONE, color clrBorder = clrNONE, string font = "Arial Rounded MT Bold") {
   ResetLastError();
   if (!ObjectCreate(0, objName, OBJ_BUTTON, 0, 0, 0)) {
      Print(__FUNCTION__, ": failed to create the button! Error code = ", _LastError);
      return false;
   }
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, xD);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, yD);
   ObjectSetInteger(0, objName, OBJPROP_XSIZE, xS);
   ObjectSetInteger(0, objName, OBJPROP_YSIZE, yS);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, objName, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clrTxt);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, objName, OBJPROP_FONT, font);
   ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, clrBg);
   ObjectSetInteger(0, objName, OBJPROP_BORDER_COLOR, clrBorder);
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
   ObjectSetInteger(0, objName, OBJPROP_STATE, false);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_SELECTED, false);
   ChartRedraw(0);
   return true;
}

//+------------------------------------------------------------------+
//| Create label                                                      |
//+------------------------------------------------------------------+
bool createLabel(string objName, int xD, int yD, string txt, color clrTxt = clrBlack, int fontSize = 12,
                 string font = "Arial Rounded MT Bold") {
   ResetLastError();
   if (!ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0)) {
      Print(__FUNCTION__, ": failed to create the label! Error code = ", _LastError);
      return false;
   }
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, xD);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, yD);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, objName, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clrTxt);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, objName, OBJPROP_FONT, font);
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
   ObjectSetInteger(0, objName, OBJPROP_STATE, false);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_SELECTED, false);
   ChartRedraw(0);
   return true;
}

//+------------------------------------------------------------------+
//| Update label                                                      |
//+------------------------------------------------------------------+
bool updateLabel(string objName, string txt) {
   ResetLastError();
   if (!ObjectSetString(0, objName, OBJPROP_TEXT, txt)) {
      Print(__FUNCTION__, ": failed to update the label! Error code = ", _LastError);
      return false;
   }
   ChartRedraw(0);
   return true;
}

//+------------------------------------------------------------------+
//| Create button (trade UI)                                          |
//+------------------------------------------------------------------+
bool createButton1(string objName, int x, int y, int width, int height, string text, color txtColor,
                   int fontSize, color bgColor, color borderColor) {
   if (!ObjectCreate(0, objName, OBJ_BUTTON, 0, 0, 0)) {
      Print("Error creating button ", objName, " : ", GetLastError());
      return false;
   }
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, objName, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, objName, OBJPROP_YSIZE, height);
   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, txtColor);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(0, objName, OBJPROP_BORDER_COLOR, borderColor);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, objName, OBJPROP_BACK, true);
   ChartRedraw();
   return true;
}

//+------------------------------------------------------------------+
//| Create label (trade UI)                                           |
//+------------------------------------------------------------------+
bool createLabel1(string objName, int x, int y, string text, color txtColor, int fontSize) {
   if (!ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0)) {
      Print("Error creating label ", objName, " : ", GetLastError());
      return false;
   }
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, txtColor);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ChartRedraw();
   return true;
}

//+------------------------------------------------------------------+
//| Update label (trade UI)                                           |
//+------------------------------------------------------------------+
bool updateLabel1(string objName, string text) {
   if (ObjectFind(0, objName) < 0) {
      Print("updateLabel1: Object ", objName, " not found.");
      return false;
   }
   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   ChartRedraw();
   return true;
}

//+------------------------------------------------------------------+
//| Compare string arrays for changes                                 |
//+------------------------------------------------------------------+
bool isChangeInStringArrays(string &arr1[], string &arr2[]) {
   bool isChange = false;
   int size1 = ArraySize(arr1);
   int size2 = ArraySize(arr2);
   if (size1 != size2) {
      Print("Arrays have different sizes. Size of Array 1: ", size1, ", Size of Array 2: ", size2);
      return true;
   }
   for (int i = 0; i < size1; i++) {
      if (StringCompare(arr1[i], arr2[i]) != 0) {
         Print("Change detected at index ", i, ": '", arr1[i], "' vs '", arr2[i], "'");
         return true;
      }
   }
   return isChange;
}

//+------------------------------------------------------------------+
//| Calculate slider height                                           |
//+------------------------------------------------------------------+
int calculateSliderHeight() {
   if (totalEvents_Filtered <= VISIBLE_ITEMS)
      return SCROLL_AREA_HEIGHT;
   double visible_ratio = (double)VISIBLE_ITEMS / totalEvents_Filtered;
   int height = (int)::floor(SCROLL_AREA_HEIGHT * visible_ratio);
   return MathMax(SLIDER_MIN_HEIGHT, MathMin(height, SCROLL_AREA_HEIGHT));
}

//+------------------------------------------------------------------+
//| Update slider position                                            |
//+------------------------------------------------------------------+
void updateSliderPosition() {
   int max_scroll = MathMax(0, ArraySize(displayableEvents) - VISIBLE_ITEMS);
   if (max_scroll <= 0) return;
   double scroll_ratio = (double)scroll_pos / max_scroll;
   int scroll_area_y_min = panel_y + SCROLLBAR_Y_OFFSET + BUTTON_SIZE;
   int scroll_area_y_max = scroll_area_y_min + SCROLL_AREA_HEIGHT - slider_height;
   int new_y = scroll_area_y_min + (int)(scroll_ratio * (scroll_area_y_max - scroll_area_y_min));
   ObjectSetInteger(0, SCROLL_SLIDER, OBJPROP_YDISTANCE, new_y);
   if (debugLogging) Print("Slider moved to y=", new_y);
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Update button colors based on scroll position                     |
//+------------------------------------------------------------------+
void updateButtonColors() {
   int max_scroll = MathMax(0, ArraySize(displayableEvents) - VISIBLE_ITEMS);
   if (scroll_pos == 0) {
      ObjectSetInteger(0, SCROLL_UP_LABEL, OBJPROP_COLOR, clrLightGray);
   } else {
      ObjectSetInteger(0, SCROLL_UP_LABEL, OBJPROP_COLOR, clrBlack);
   }
   if (scroll_pos >= max_scroll) {
      ObjectSetInteger(0, SCROLL_DOWN_LABEL, OBJPROP_COLOR, clrLightGray);
   } else {
      ObjectSetInteger(0, SCROLL_DOWN_LABEL, OBJPROP_COLOR, clrBlack);
   }
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Scroll up                                                         |
//+------------------------------------------------------------------+
void scrollUp() {
   if (scroll_pos > 0) {
      scroll_pos--;
      update_dashboard_values(curr_filter_selected, imp_filter_selected);
      updateSliderPosition();
      if (debugLogging) Print("Scrolled up. CurrPos: ", scroll_pos);
   } else {
      if (debugLogging) Print("Cannot scroll up further. Already at top.");
   }
}

//+------------------------------------------------------------------+
//| Scroll down                                                       |
//+------------------------------------------------------------------+
void scrollDown() {
   int max_scroll = MathMax(0, ArraySize(displayableEvents) - VISIBLE_ITEMS);
   if (scroll_pos < max_scroll) {
      scroll_pos++;
      update_dashboard_values(curr_filter_selected, imp_filter_selected);
      updateSliderPosition();
      if (debugLogging) Print("Scrolled down. CurrPos: ", scroll_pos);
   } else {
      if (debugLogging) Print("Cannot scroll down further. Max scroll reached: ", max_scroll);
   }
}
//+------------------------------------------------------------------+