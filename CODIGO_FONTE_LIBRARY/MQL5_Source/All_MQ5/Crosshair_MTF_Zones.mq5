
#property indicator_chart_window
#property strict

// === Crosshair Settings ===
input color CrosshairColor = clrRed;
input int   CrosshairWidth = 1;
input ENUM_LINE_STYLE CrosshairStyle = STYLE_DOT;

// === General Zone Settings ===
input int   ZoneTransparency = 30;
input bool  ShowZoneHistory = false;
input bool  EnableAlerts = true;
input bool  EnablePush     = false;
input bool  EnableEmail    = false;
input bool  EnableTelegram = false;
input bool  EnableWhatsApp = false;

// === Per-Timeframe Settings ===
input bool Show_MN1 = true;   input color Color_MN1 = clrMaroon;
input bool Show_W1  = true;   input color Color_W1  = clrTeal;
input bool Show_D1  = true;   input color Color_D1  = clrGreen;
input bool Show_H4  = true;   input color Color_H4  = clrBlue;
input bool Show_H2  = true;   input color Color_H2  = clrIndigo;
input bool Show_H1  = true;   input color Color_H1  = clrOrange;
input bool Show_M30 = true;   input color Color_M30 = clrDarkViolet;
input bool Show_M15 = true;   input color Color_M15 = clrBrown;
input bool Show_M5  = true;   input color Color_M5  = clrFireBrick;
input bool Show_M1  = true;   input color Color_M1  = clrDarkSlateGray;

struct TFZone {
   string name;
   ENUM_TIMEFRAMES tf;
   color zone_color;
   bool enabled;
};

TFZone tfList[];

string hLineName = "CrossH";
string vLineName = "CrossV";

struct ZoneState {
   double high;
   double low;
   bool inside;
};
ZoneState zoneStates[10];

int OnInit()
{
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);

   ArrayResize(tfList, 10);
   tfList[0] = {"MN1", PERIOD_MN1, Color_MN1, Show_MN1};
   tfList[1] = {"W1",  PERIOD_W1,  Color_W1,  Show_W1};
   tfList[2] = {"D1",  PERIOD_D1,  Color_D1,  Show_D1};
   tfList[3] = {"H4",  PERIOD_H4,  Color_H4,  Show_H4};
   tfList[4] = {"H2",  PERIOD_H2,  Color_H2,  Show_H2};
   tfList[5] = {"H1",  PERIOD_H1,  Color_H1,  Show_H1};
   tfList[6] = {"M30", PERIOD_M30, Color_M30, Show_M30};
   tfList[7] = {"M15", PERIOD_M15, Color_M15, Show_M15};
   tfList[8] = {"M5",  PERIOD_M5,  Color_M5,  Show_M5};
   tfList[9] = {"M1",  PERIOD_M1,  Color_M1,  Show_M1};

   DrawCrosshair();
   DrawTimeframeZones();
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   ObjectDelete(0, hLineName);
   ObjectDelete(0, vLineName);
   for(int i = 0; i < ArraySize(tfList); i++) {
      ObjectDelete(0, tfList[i].name + "_zone");
      ObjectDelete(0, tfList[i].name + "_label");
   }
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_MOUSE_MOVE)
   {
      int x = (int)lparam;
      int y = (int)dparam;
      datetime time;
      double price;
      if(ChartXYToTimePrice(0, x, y, time, price))
      {
         ObjectMove(0, hLineName, 0, 0, price);
         ObjectMove(0, vLineName, 0, time, 0);
      }
   }
}

void OnTick()
{
   if(!EnableAlerts) return;
   double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   for(int i = 0; i < ArraySize(tfList); i++)
   {
      if(!tfList[i].enabled) continue;
      if(zoneStates[i].high == 0) continue;

      bool inZone = (current_price <= zoneStates[i].high && current_price >= zoneStates[i].low);

      if(inZone && !zoneStates[i].inside)
      {
         string msg = "Price entered " + tfList[i].name + " zone!";
         Alert(msg);
         Print(msg);
         if (EnablePush)     SendNotification(msg);
         if (EnableEmail)    SendMail("MT5 Zone Alert", msg);
         if (EnableTelegram) SendTelegram(msg);
         if (EnableWhatsApp) SendWhatsApp(msg);

         zoneStates[i].inside = true;
      }
      else if(!inZone)
      {
         zoneStates[i].inside = false;
      }
   }
}

void DrawCrosshair()
{
   ObjectCreate(0, hLineName, OBJ_HLINE, 0, 0, 0);
   ObjectSetInteger(0, hLineName, OBJPROP_COLOR, CrosshairColor);
   ObjectSetInteger(0, hLineName, OBJPROP_STYLE, CrosshairStyle);
   ObjectSetInteger(0, hLineName, OBJPROP_WIDTH, CrosshairWidth);

   ObjectCreate(0, vLineName, OBJ_VLINE, 0, 0, 0);
   ObjectSetInteger(0, vLineName, OBJPROP_COLOR, CrosshairColor);
   ObjectSetInteger(0, vLineName, OBJPROP_STYLE, CrosshairStyle);
   ObjectSetInteger(0, vLineName, OBJPROP_WIDTH, CrosshairWidth);
}

void DrawTimeframeZones()
{
   for(int i = 0; i < ArraySize(tfList); i++)
   {
      if(!tfList[i].enabled) continue;

      datetime time1, time2;
      double high, low;
      string objName = tfList[i].name + "_zone";
      string labelName = tfList[i].name + "_label";

      if(GetTFHighLow(tfList[i].tf, time1, time2, high, low))
      {
         zoneStates[i].high = high;
         zoneStates[i].low  = low;
         zoneStates[i].inside = false;

         ObjectCreate(0, objName, OBJ_RECTANGLE, 0, time1, high, time2, low);
         ObjectSetInteger(0, objName, OBJPROP_COLOR, tfList[i].zone_color);
         ObjectSetInteger(0, objName, OBJPROP_TRANSPARENCY, ZoneTransparency);
         ObjectSetInteger(0, objName, OBJPROP_BACK, true);

         if(ShowZoneHistory)
            ObjectSetInteger(0, objName, OBJPROP_RAY_RIGHT, true);

         ObjectCreate(0, labelName, OBJ_TEXT, 0, time2, high);
         ObjectSetInteger(0, labelName, OBJPROP_COLOR, tfList[i].zone_color);
         ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
         ObjectSetString(0, labelName, OBJPROP_TEXT, tfList[i].name + " H/L");
      }
   }
}

bool GetTFHighLow(ENUM_TIMEFRAMES tf, datetime &start, datetime &end, double &high, double &low)
{
   if(iBars(_Symbol, tf) < 2) return false;

   datetime time[];
   double highs[], lows[];

   if(CopyTime(_Symbol, tf, 0, 2, time) < 2) return false;
   if(CopyHigh(_Symbol, tf, 0, 1, highs) < 1) return false;
   if(CopyLow(_Symbol, tf, 0, 1, lows) < 1) return false;

   start = time[1];
   end = time[0];
   high = highs[0];
   low  = lows[0];
   return true;
}

void SendTelegram(string text)
{
   // Implement WebRequest bridge here
}

void SendWhatsApp(string text)
{
   // Implement WebRequest bridge here
}
