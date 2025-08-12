#property copyright "CLICK HERE"
#property link      "https://t.me/Paidforexrobot"
#property version   "2.00"

#property description "We crack MT4 n MT5 Indicators/Robots."
#property description "We convert MT4/MT5 Indicators to Robots."
#property description "."
#property description "CRACKED BY @Subzero_911"
#property description "."
#property description "Instagram = @Subzero_911_"
#property description "."
#property description "Telegram = @Subzero_911"



#property indicator_chart_window
#property indicator_buffers 2
extern int forced_tf = 0;
extern bool use_narrow_bands = false;
extern bool kill_retouch = true;
extern color TopColor = Yellow;
extern color BotColor = Aqua;
extern color Price_mark = Black;
extern int Price_Width = 1;

extern string             button_note1 = "------------------------------";
extern ENUM_BASE_CORNER   btn_corner = CORNER_LEFT_UPPER; // chart btn_corner for anchoring
extern string             btn_text = "SupDem Z";
extern string             btn_Font = "Arial";
extern int                btn_FontSize = 8;                             //btn__font size
extern color              btn_text_color = clrWhite;
extern color              btn_background_color = clrDimGray;
extern color              btn_border_color = clrBlack;
extern int                button_x = 20;                                 //btn__x
extern int                button_y = 13;                                 //btn__y
extern int                btn_Width = 60;                                 //btn__width
extern int                btn_Height = 20;                                //btn__height
extern string             button_note2 = "------------------------------";
input string T_ = "== Events Notifications ==";  // ————————————
input bool alertPriceIntoZone = true; // Price Into Zone
input bool alertNewZone = true; // New Zone:
input bool alertDeleteZone = true; // Delete Zone:
input string T1 = "== Notifications ==";  // ————————————
input bool   notifications = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications = false;                  // Email Notifications
input bool   push_notifications = false;                  // Push Mobile Notifications


int lastCount;
double supportPrice; double lastSupport;
double resistencePrice; double lastResistence;

// ------------------------------------------------------------------
bool                      show_data = true;
string IndicatorName, IndicatorObjPrefix;
//template code end1
double BuferUp [];
double BuferDn [];
double iPeriod = 13;
int Dev = 8;
int Step = 5;
datetime t1, t2;
double p1, p2;
string pair;
double point;
int digits;
int tf;
string TAG;

double up_cur, dn_cur;
//+------------------------------------------------------------------+
string GenerateIndicatorName(const string target) //don't change anything here
{
    string name = target;
    int try = 2;
    while(WindowFind(name) != -1)
    {
        name = target + " #" + IntegerToString(try++);
    }
    return name;
}
//+------------------------------------------------------------------+
string buttonId;

//+------------------------------------------------------------------+
int init()
{
    lastCount = 0;

    IndicatorName = GenerateIndicatorName(btn_text);
    IndicatorObjPrefix = "__" + IndicatorName + "__";
    IndicatorShortName(IndicatorName);
    IndicatorDigits(Digits);

    double val;
    if(GlobalVariableGet(IndicatorName + "_visibility", val))
        show_data = val != 0;

    // put init() here
    SetIndexBuffer(1, BuferUp);
    SetIndexEmptyValue(1, 0.0);
    SetIndexStyle(1, DRAW_NONE);
    SetIndexBuffer(0, BuferDn);
    SetIndexEmptyValue(0, 0.0);
    SetIndexStyle(0, DRAW_NONE);
    if(forced_tf != 0) tf = forced_tf;
    else tf = Period();
    point = Point;
    digits = Digits;
    if(digits == 3 || digits == 5) point *= 10;
    TAG = "II_SupDem" + tf;

    ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
    buttonId = IndicatorObjPrefix + "CloseButton";
    createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_color);
    ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
    ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);




    ObjectCreate("UPboxinfo", OBJ_LABEL, 0, 0, 0);
    ObjectSet("UPboxinfo", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSet("UPboxinfo", OBJPROP_XDISTANCE, 10);
    ObjectSet("UPboxinfo", OBJPROP_YDISTANCE, 30);
    ObjectSet("UPboxinfo", OBJPROP_COLOR, clrBlack);
    ObjectSet("UPboxinfo", OBJPROP_ZORDER, 100);
    ObjectSet("UPboxinfo", OBJPROP_BACK, False);
    ObjectSetText("UPboxinfo", "Upper box info :", 10, "Arial", Yellow);



    ObjectCreate("DNboxinfo", OBJ_LABEL, 0, 0, 0);
    ObjectSet("DNboxinfo", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSet("DNboxinfo", OBJPROP_XDISTANCE, 10);
    ObjectSet("DNboxinfo", OBJPROP_YDISTANCE, 90);
    ObjectSet("DNboxinfo", OBJPROP_COLOR, clrBlack);
    ObjectSet("DNboxinfo", OBJPROP_ZORDER, 100);
    ObjectSet("DNboxinfo", OBJPROP_BACK, false);
    ObjectSetText("DNboxinfo", "Lower box info :", 10, "Arial", Blue);

    ObjectCreate("UPboxup", OBJ_LABEL, 0, 0, 0);
    ObjectSet("UPboxup", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSet("UPboxup", OBJPROP_XDISTANCE, 10);
    ObjectSet("UPboxup", OBJPROP_YDISTANCE, 50);
    ObjectSet("UPboxup", OBJPROP_COLOR, clrBlack);
    ObjectSet("UPboxup", OBJPROP_ZORDER, 100);
    ObjectSet("UPboxup", OBJPROP_BACK, false);

    ObjectCreate("UPboxdn", OBJ_LABEL, 0, 0, 0);
    ObjectSet("UPboxdn", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSet("UPboxdn", OBJPROP_XDISTANCE, 10);
    ObjectSet("UPboxdn", OBJPROP_YDISTANCE, 70);
    ObjectSet("UPboxdn", OBJPROP_COLOR, clrBlack);
    ObjectSet("UPboxdn", OBJPROP_ZORDER, 100);
    ObjectSet("UPboxdn", OBJPROP_BACK, false);

    ObjectCreate("DNboxup", OBJ_LABEL, 0, 0, 0);
    ObjectSet("DNboxup", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSet("DNboxup", OBJPROP_XDISTANCE, 10);
    ObjectSet("DNboxup", OBJPROP_YDISTANCE, 110);
    ObjectSet("DNboxup", OBJPROP_COLOR, clrBlack);
    ObjectSet("DNboxup", OBJPROP_ZORDER, 100);
    ObjectSet("DNboxup", OBJPROP_BACK, false);

    ObjectCreate("DNboxdn", OBJ_LABEL, 0, 0, 0);
    ObjectSet("DNboxdn", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSet("DNboxdn", OBJPROP_XDISTANCE, 10);
    ObjectSet("DNboxdn", OBJPROP_YDISTANCE, 130);
    ObjectSet("DNboxdn", OBJPROP_COLOR, clrBlack);
    ObjectSet("DNboxdn", OBJPROP_ZORDER, 100);
    ObjectSet("DNboxdn", OBJPROP_BACK, false);

    ObjectCreate("distance1", OBJ_LABEL, 0, 0, 0);
    ObjectSet("distance1", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSet("distance1", OBJPROP_XDISTANCE, 10);
    ObjectSet("distance1", OBJPROP_YDISTANCE, 150);
    ObjectSet("distance1", OBJPROP_COLOR, clrBlack);
    ObjectSet("distance1", OBJPROP_ZORDER, 100);
    ObjectSet("distance1", OBJPROP_BACK, false);

    ObjectCreate("UPboxWidth", OBJ_LABEL, 0, 0, 0);
    ObjectSet("UPboxWidth", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSet("UPboxWidth", OBJPROP_XDISTANCE, 10);
    ObjectSet("UPboxWidth", OBJPROP_YDISTANCE, 170);
    ObjectSet("UPboxWidth", OBJPROP_COLOR, clrBlack);
    ObjectSet("UPboxWidth", OBJPROP_ZORDER, 100);
    ObjectSet("UPboxWidth", OBJPROP_BACK, False);

    ObjectCreate("DNboxWidth", OBJ_LABEL, 0, 0, 0);
    ObjectSet("DNboxWidth", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSet("DNboxWidth", OBJPROP_XDISTANCE, 10);
    ObjectSet("DNboxWidth", OBJPROP_YDISTANCE, 190);
    ObjectSet("DNboxWidth", OBJPROP_COLOR, clrBlack);
    ObjectSet("DNboxWidth", OBJPROP_ZORDER, 100);
    ObjectSet("DNboxWidth", OBJPROP_BACK, False);

    return 0;
}
//+------------------------------------------------------------------+
//don't change anything here
void createButton(string buttonID, string buttonText, int width, int height, string font, int fontSize, color bgColor, color borderColor, color txtColor)
{
    ObjectDelete(0, buttonID);
    ObjectCreate(0, buttonID, OBJ_BUTTON, 0, 0, 0);
    ObjectSetInteger(0, buttonID, OBJPROP_COLOR, txtColor);
    ObjectSetInteger(0, buttonID, OBJPROP_BGCOLOR, bgColor);
    ObjectSetInteger(0, buttonID, OBJPROP_BORDER_COLOR, borderColor);
    ObjectSetInteger(0, buttonID, OBJPROP_BORDER_TYPE, BORDER_RAISED);
    ObjectSetInteger(0, buttonID, OBJPROP_XSIZE, width);
    ObjectSetInteger(0, buttonID, OBJPROP_YSIZE, height);
    ObjectSetString(0, buttonID, OBJPROP_FONT, font);
    ObjectSetString(0, buttonID, OBJPROP_TEXT, buttonText);
    ObjectSetInteger(0, buttonID, OBJPROP_FONTSIZE, fontSize);
    ObjectSetInteger(0, buttonID, OBJPROP_SELECTABLE, 0);
    ObjectSetInteger(0, buttonID, OBJPROP_CORNER, btn_corner);
    ObjectSetInteger(0, buttonID, OBJPROP_HIDDEN, 1);
    ObjectSetInteger(0, buttonID, OBJPROP_XDISTANCE, 9999);
    ObjectSetInteger(0, buttonID, OBJPROP_YDISTANCE, 9999);
}
//+------------------------------------------------------------------+
int deinit()
{
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);

    //put deinit() here
    ObDeleteObjectsByPrefix(TAG);
      ObjectDelete(0, "loboxupl");
        ObjectDelete(0, "loboxdnl");
        ObjectDelete(0, "upboxupl");
        ObjectDelete(0, "upboxdnl");
        ObjectDelete(0, "upboxmidl");
        ObjectDelete(0, "dnboxmidl");
        ObjectDelete(0, "UPar1");
        ObjectDelete(0, "DNar1");
    Comment("");

    return 0;
}
//+------------------------------------------------------------------+
//don't change anything here
bool recalc = true;

void handleButtonClicks()
{
    if(ObjectGetInteger(0, buttonId, OBJPROP_STATE))
    {
        ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
        show_data = !show_data;
        GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
        recalc = true;
        start();
    }
}
//+------------------------------------------------------------------+
void OnChartEvent(const int id, //don't change anything here
                  const long& lparam,
                  const double& dparam,
                  const string& sparam)
{
    handleButtonClicks();
}
//+------------------------------------------------------------------+
int start()
{
    AlertZones();
    handleButtonClicks();
    recalc = false;
    if(NewBar() == true)
    {

        CountZZ(BuferUp, BuferDn, iPeriod, Dev, Step);
        // Print(__FUNCTION__, " CountZZ: ", CountZZ);
        GetValid();
        Draw();



    }

    if(show_data)
    {
        CountZZ(BuferUp, BuferDn, iPeriod, Dev, Step);
        GetValid();
        Draw();

    }
    else
    {
        ObDeleteAll();

        Comment("");
    }
    return 0;
}
//+------------------------------------------------------------------+
void Draw()
{
    int i;
    string s;
    double UPboxup;
    double UPboxdn;
    double DNboxup;
    double DNboxdn;
    double UPboxwidth;
    double DNboxwidth;
    double UPboxmid;
    double DNboxmid;

    ObDeleteAll(); //this function replaces the line below
    //       ObDeleteObjectsByPrefix(TAG);
    for(i = 0;i < iBars(pair, tf);i++)
    {
        if(BuferDn[i] > 0.0)
        {
            t1 = iTime(pair, tf, i);
            t2 = Time[0];
            if(use_narrow_bands) p2 = MathMax(iClose(pair, tf, i), iOpen(pair, tf, i));
            else p2 = MathMin(iClose(pair, tf, i), iOpen(pair, tf, i));
            p2 = MathMax(p2, MathMax(iLow(pair, tf, i - 1), iLow(pair, tf, i + 1)));


            s = TAG + "UPAR" + tf + i;
            ObjectCreate(s, OBJ_ARROW, 0, 0, 0);
            ObjectSet(s, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
            ObjectSet(s, OBJPROP_TIME1, t2);
            ObjectSet(s, OBJPROP_PRICE1, p2);
            ObjectSet(s, OBJPROP_COLOR, Price_mark);
            ObjectSet(s, OBJPROP_WIDTH, Price_Width);

            s = TAG + "UPFILL" + tf + i;
            ObjectCreate(s, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
            ObjectSet(s, OBJPROP_TIME1, t1);
            ObjectSet(s, OBJPROP_PRICE1, BuferDn[i]);
            ObjectSet(s, OBJPROP_TIME2, t2);
            ObjectSet(s, OBJPROP_PRICE2, p2);
            ObjectSet(s, OBJPROP_COLOR, TopColor);

            //             ObjectCreate("upboxupl", OBJ_HLINE, 0, 0, BuferDn[i] + 0.05 , 0, 0);
            //             ObjectCreate("upboxdnl", OBJ_HLINE, 0, 0, p2 , 0, 0);

            ObjectCreate("upboxupl", OBJ_TREND, 0, t1, BuferDn[i] + 0.05, t2, BuferDn[i] + 0.05);
            ObjectCreate("upboxdnl", OBJ_TREND, 0, t1, p2, t2, p2);

            ObjectSetInteger(0, "upboxupl", OBJPROP_RAY, false);
            ObjectSetInteger(0, "upboxdnl", OBJPROP_RAY, false);

            ObjectSet("upboxupl", OBJPROP_COLOR, Red);
            ObjectSet("upboxdnl", OBJPROP_COLOR, Red);
            ObjectSet("upboxdnl", OBJPROP_WIDTH, 10);

            UPboxup = ObjectGet("upboxupl", OBJPROP_PRICE1);
            UPboxdn = ObjectGet("upboxdnl", OBJPROP_PRICE1);

            ObjectCreate("DNar1", OBJ_ARROW, 0, t2, UPboxdn);
            ObjectSet("DNar1", OBJPROP_CORNER, 0);
            ObjectSet("DNar1", OBJPROP_ARROWCODE, 218);


            ObjectSetText("UPboxup", "UpPrUP is :" + UPboxup, 10, "Arial", Black);
            ObjectSetText("UPboxdn", "UpPrDn is :" + UPboxdn, 10, "Arial", Black);

            UPboxwidth = ((UPboxup - UPboxdn)) * 100;
            ObjectSetText("UPboxWidth", "UPboxWidth is : " + UPboxwidth, 10, "Arial", Blue);


            UPboxmid = UPboxup - (((UPboxwidth / 100) / 2));

            ObjectCreate("UPboxmid", OBJ_LABEL, 0, 0, 0);
            ObjectSet("UPboxmid", OBJPROP_CORNER, CORNER_LEFT_UPPER);
            ObjectSet("UPboxmid", OBJPROP_XDISTANCE, 10);
            ObjectSet("UPboxmid", OBJPROP_YDISTANCE, 210);
            ObjectSet("UPboxmid", OBJPROP_ZORDER, 100);
            ObjectSet("UPboxmid", OBJPROP_COLOR, clrBlack);
            ObjectSet("UPboxmid", OBJPROP_BACK, False);
            ObjectSetText("UPboxmid", "UpBXmid is :" + UPboxmid, 10, "Arial", Black);




            ObjectCreate("upboxmidl", OBJ_TREND, 0, t1, UPboxmid, t2, UPboxmid);
            ObjectSet("upboxmidl", OBJPROP_COLOR, Blue);
            ObjectSet("upboxmidl", OBJPROP_STYLE, STYLE_DOT);
            ObjectSetInteger(0, "upboxmidl", OBJPROP_RAY, false);



        }

        if(BuferUp[i] > 0.0)
        {
            t1 = iTime(pair, tf, i);
            t2 = Time[0];
            if(use_narrow_bands) p2 = MathMin(iClose(pair, tf, i), iOpen(pair, tf, i));
            else p2 = MathMax(iClose(pair, tf, i), iOpen(pair, tf, i));
            if(i > 0) p2 = MathMin(p2, MathMin(iHigh(pair, tf, i + 1), iHigh(pair, tf, i - 1)));
            s = TAG + "DNAR" + tf + i;
            ObjectCreate(s, OBJ_ARROW, 0, 0, 0);
            ObjectSet(s, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
            ObjectSet(s, OBJPROP_TIME1, t2);
            ObjectSet(s, OBJPROP_PRICE1, p2);
            ObjectSet(s, OBJPROP_COLOR, Price_mark);
            ObjectSet(s, OBJPROP_WIDTH, Price_Width);

            s = TAG + "DNFILL" + tf + i;
            ObjectCreate(s, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
            ObjectSet(s, OBJPROP_TIME1, t1);
            ObjectSet(s, OBJPROP_PRICE1, p2);
            ObjectSet(s, OBJPROP_TIME2, t2);
            ObjectSet(s, OBJPROP_PRICE2, BuferUp[i]);
            ObjectSet(s, OBJPROP_COLOR, BotColor);

            //           ObjectCreate("loboxupl", OBJ_HLINE, 0, Time[0], p2, 0, 0);
           //             ObjectCreate("loboxdnl", OBJ_HLINE, 0, Time[0], BuferUp[i] - 0.05  , 0, 0);

            ObjectCreate("loboxupl", OBJ_TREND, 0, t1, BuferUp[i] - 0.05, t2, BuferUp[i] - 0.05);
            ObjectCreate("loboxdnl", OBJ_TREND, 0, t1, p2, t2, p2);


            ObjectSet("loboxupl", OBJPROP_COLOR, Red);
            ObjectSet("loboxdnl", OBJPROP_COLOR, Red);
            ObjectSet("loboxdnl", OBJPROP_WIDTH, 10);   
            
            
            ObjectSetInteger(0, "loboxupl", OBJPROP_RAY, false);
            ObjectSetInteger(0, "loboxdnl", OBJPROP_RAY, false);


            ObjectSet("loboxupl", OBJPROP_COLOR, Red);
            ObjectSet("loboxdnl", OBJPROP_COLOR, Red);
            ObjectSet("loboxdnl", OBJPROP_WIDTH, 10); 
            
            

            DNboxup = ObjectGet("loboxupl", OBJPROP_PRICE1);
            DNboxdn = ObjectGet("loboxdnl", OBJPROP_PRICE1);

            ObjectSetText("DNboxup", "DnPrUP is :" + DNboxup, 10, "Arial", Black);
            ObjectSetText("DNboxdn", "DnPrDn is :" + DNboxdn, 10, "Arial", Black);

            DNboxwidth = ((DNboxup - DNboxdn) - 0.05) * 100;
            ObjectSetText("DNboxWidth", "DNboxWidth is : " + DNboxwidth * -1, 10, "Arial", Blue);

            DNboxmid = DNboxup - (((DNboxwidth / 100) / 2));


            ObjectCreate("DNboxmid", OBJ_LABEL, 0, 0, 0);
            ObjectSet("DNboxmid", OBJPROP_CORNER, CORNER_LEFT_UPPER);
            ObjectSet("DNboxmid", OBJPROP_XDISTANCE, 10);
            ObjectSet("DNboxmid", OBJPROP_YDISTANCE, 230);
            ObjectSet("DNboxmid", OBJPROP_COLOR, clrBlack);
            ObjectSet("DNboxmid", OBJPROP_ZORDER, 100);
            ObjectSet("DNboxmid", OBJPROP_BACK, False);
            ObjectSetText("DNboxmid", "DnBXmid is :" + DNboxmid, 10, "Arial", Black);




            ObjectCreate("dnboxmidl", OBJ_TREND, 0, t1, DNboxmid, t2, DNboxmid);
            ObjectSet("dnboxmidl", OBJPROP_COLOR, Blue);
            ObjectSet("dnboxmidl", OBJPROP_STYLE, STYLE_DOT);
            ObjectSetInteger(0, "dnboxmidl", OBJPROP_RAY, false);

            ObjectCreate("UPar1", OBJ_ARROW, 0, t2, DNboxdn);
            ObjectSet("UPar1", OBJPROP_CORNER, 0);
            ObjectSet("UPar1", OBJPROP_ARROWCODE, 217);
            ObjectSet("UPar1", OBJPROP_COLOR, Green);
            ObjectSet("UPar1", OBJPROP_WIDTH, 1);

        }
    }
    ObjectSetText("distance1", "Distence = " + ((UPboxdn - DNboxup) * 100), 10, "Arial", Green);


}
//+------------------------------------------------------------------+
bool NewBar()
{

    static datetime LastTime = 0;

    if(iTime(pair, tf, 0) != LastTime) {
        LastTime = iTime(pair, tf, 0);
        return (true);



    }
    else

        return (false);
}
//+------------------------------------------------------------------+
void ObDeleteAll()
{
    //       int L = StringLen(Prefix);
    int i = 0;
    while(i < ObjectsTotal())
    {
        string ObjName = ObjectName(i);
        if(StringSubstr(ObjName, 0, 9) != "II_SupDem")
        {

            i++;
            continue;
        }
        ObjectDelete(ObjName);

        ObjectDelete(0, "loboxupl");
        ObjectDelete(0, "loboxdnl");
        ObjectDelete(0, "upboxupl");
        ObjectDelete(0, "upboxdnl");
        ObjectDelete(0, "upboxmidl");
        ObjectDelete(0, "dnboxmidl");
        ObjectDelete(0, "UPar1");
        ObjectDelete(0, "DNar1");



    }
}
//+------------------------------------------------------------------+
void ObDeleteObjectsByPrefix(string Prefix)
{
    int L = StringLen(Prefix);
    int i = 0;
    while(i < ObjectsTotal())
    {
        string ObjName = ObjectName(i);
        if(StringSubstr(ObjName, 0, L) != Prefix)
        {
            i++;
            continue;
        }
        ObjectDelete(ObjName);

        ObjectDelete(0, "loboxupl");
        ObjectDelete(0, "loboxdnl");
        ObjectDelete(0, "upboxupl");
        ObjectDelete(0, "upboxdnl");
        ObjectDelete(0, "upboxmidl");
        ObjectDelete(0, "dnboxmidl");
        ObjectDelete(0, "UPar1");
        ObjectDelete(0, "DNar1");


    }
}
//+------------------------------------------------------------------+
int CountZZ(double& ExtMapBuffer [], double& ExtMapBuffer2 [], int ExtDepth, int ExtDeviation, int ExtBackstep)
{
    int    shift, back, lasthighpos, lastlowpos;
    double val, res;
    double curlow, curhigh, lasthigh, lastlow;
    int count = iBars(pair, tf) - ExtDepth;

    for(shift = count; shift >= 0; shift--)
    {
        val = iLow(pair, tf, iLowest(pair, tf, MODE_LOW, ExtDepth, shift));
        if(val == lastlow) val = 0.0;
        else
        {
            lastlow = val;
            if((iLow(pair, tf, shift) - val) > (ExtDeviation * Point)) val = 0.0;
            else
            {
                for(back = 1; back <= ExtBackstep; back++)
                {
                    res = ExtMapBuffer[shift + back];
                    if((res != 0) && (res > val)) ExtMapBuffer[shift + back] = 0.0;
                }
            }
        }

        ExtMapBuffer[shift] = val;
        //--- high
        val = iHigh(pair, tf, iHighest(pair, tf, MODE_HIGH, ExtDepth, shift));

        if(val == lasthigh) val = 0.0;
        else
        {
            lasthigh = val;
            if((val - iHigh(pair, tf, shift)) > (ExtDeviation * Point)) val = 0.0;
            else
            {
                for(back = 1; back <= ExtBackstep; back++)
                {
                    res = ExtMapBuffer2[shift + back];
                    if((res != 0) && (res < val)) ExtMapBuffer2[shift + back] = 0.0;
                }
            }
        }
        ExtMapBuffer2[shift] = val;
    }
    // final cutting
    lasthigh = -1; lasthighpos = -1;
    lastlow = -1;  lastlowpos = -1;

    for(shift = count; shift >= 0; shift--)
    {
        curlow = ExtMapBuffer[shift];
        curhigh = ExtMapBuffer2[shift];
        if((curlow == 0) && (curhigh == 0)) continue;
        //---
        if(curhigh != 0)
        {
            if(lasthigh > 0)
            {
                if(lasthigh < curhigh) ExtMapBuffer2[lasthighpos] = 0;
                else ExtMapBuffer2[shift] = 0;
            }
            //---
            if(lasthigh < curhigh || lasthigh < 0)
            {
                lasthigh = curhigh;
                lasthighpos = shift;
            }
            lastlow = -1;
        }
        //----
        if(curlow != 0)
        {
            if(lastlow > 0)
            {
                if(lastlow > curlow) ExtMapBuffer[lastlowpos] = 0;
                else ExtMapBuffer[shift] = 0;
            }
            //---
            if((curlow < lastlow) || (lastlow < 0))
            {
                lastlow = curlow;
                lastlowpos = shift;
            }
            lasthigh = -1;
        }
    }

    for(shift = iBars(pair, tf) - 1; shift >= 0; shift--)
    {
        if(shift >= count) ExtMapBuffer[shift] = 0.0;
        else
        {
            res = ExtMapBuffer2[shift];
            if(res != 0.0) ExtMapBuffer2[shift] = res;
        }
    }

    return(0);
}
//+------------------------------------------------------------------+
void GetValid()
{
    up_cur = 0;
    int upbar = 0;
    dn_cur = 0;
    int dnbar = 0;
    double cur_hi = 0;
    double cur_lo = 0;
    double last_up = 0;
    double last_dn = 0;
    double low_dn = 0;
    double hi_up = 0;
    int i;
    for(i = 0;i < iBars(pair, tf);i++)
    {
        if(BuferUp[i] > 0)
        {
            up_cur = BuferUp[i];
            cur_lo = BuferUp[i];
            last_up = cur_lo;
            break;
        }
    }
    for(i = 0;i < iBars(pair, tf);i++)
    {
        if(BuferDn[i] > 0)
        {
            dn_cur = BuferDn[i];
            cur_hi = BuferDn[i];
            last_dn = cur_hi;
            break;
        }
    }
    for(i = 0;i < iBars(pair, tf);i++) // remove higher lows and lower high=0s
    {
        if(BuferDn[i] >= last_dn)
        {
            last_dn = BuferDn[i];
            dnbar = i;
        }
        else BuferDn[i] = 0.0;

        if(BuferDn[i] <= dn_cur && BuferUp[i] > 0.0) BuferDn[i] = 0.0;

        if(BuferUp[i] <= last_up && BuferUp[i] > 0)
        {
            last_up = BuferUp[i];
            upbar = i;
        }
        else BuferUp[i] = 0.0;

        if(BuferUp[i] > up_cur) BuferUp[i] = 0.0;

    }


    if(kill_retouch)
    {
        if(use_narrow_bands)
        {
            low_dn = MathMax(iOpen(pair, tf, dnbar), iClose(pair, tf, dnbar));
            hi_up = MathMin(iOpen(pair, tf, upbar), iClose(pair, tf, upbar));
        }
        else
        {
            low_dn = MathMin(iOpen(pair, tf, dnbar), iClose(pair, tf, dnbar));
            hi_up = MathMax(iOpen(pair, tf, upbar), iClose(pair, tf, upbar));
        }

        for(i = MathMax(upbar, dnbar);i >= 0;i--) // work back to zero and remove reentries into s/d
        {
            if(BuferDn[i] > low_dn && BuferDn[i] != last_dn) BuferDn[i] = 0.0;
            else if(use_narrow_bands && BuferDn[i] > 0)
            {
                low_dn = MathMax(iOpen(pair, tf, i), iClose(pair, tf, i));
                last_dn = BuferDn[i];
            }
            else if(BuferDn[i] > 0)
            {
                low_dn = MathMin(iOpen(pair, tf, i), iClose(pair, tf, i));
                last_dn = BuferDn[i];
            }

            if(BuferUp[i] <= hi_up && BuferUp[i] > 0 && BuferUp[i] != last_up) BuferUp[i] = 0.0;
            else if(use_narrow_bands && BuferUp[i] > 0)
            {
                hi_up = MathMin(iOpen(pair, tf, i), iClose(pair, tf, i));
                last_up = BuferUp[i];
            }
            else if(BuferUp[i] > 0)
            {
                hi_up = MathMax(iOpen(pair, tf, i), iClose(pair, tf, i));
                last_up = BuferUp[i];
            }
        }
    }

}
//+------------------------------------------------------------------+
void Notifications(int type)
{
    if(!notifications) return;

    string text = "";
//    if(type == 0) text += _Symbol + " " + GetTimeFrame(_Period) + " New Zone Was Created ";
//    if(type == 1) text += _Symbol + " " + GetTimeFrame(_Period) + " New Zone Was Deleted ";
//    if(type == 3) text += _Symbol + " " + GetTimeFrame(_Period) + " Price into a Zone ";
    if(type == 0) Alert(" New Zone Was Created ");
    if(type == 1) Alert(" New Zone Was Deleted ");
    if(type == 3)  Alert(" Price into a Zone ");

    if(desktop_notifications) Alert(text);
    if(push_notifications)    SendNotification(text);
    if(email_notifications)   SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
    switch(lPeriod)
    {
        case PERIOD_M1:
            return ("M1");
        case PERIOD_M5:
            return ("M5");
        case PERIOD_M15:
            return ("M15");
        case PERIOD_M30:
            return ("M30");
        case PERIOD_H1:
            return ("H1");
        case PERIOD_H4:
            return ("H4");
        case PERIOD_D1:
            return ("D1");
        case PERIOD_W1:
            return ("W1");
        case PERIOD_MN1:
            return ("MN1");
    }
    return IntegerToString(lPeriod);
}



// ------------------------------------------------------------------
void AlertZones()
{
    // recorrer los rctangulos y contarlos
    int count = ObjectsTotal(OBJ_RECTANGLE);

    if(lastCount == 0)
    {
        lastCount = count;
        return;
    }

if(alertNewZone)
    if(count > lastCount && lastCount != 0)
    {
        if(lastCount != 0)Notifications(0);
        lastCount = count;
    }
if(alertDeleteZone)
    if(count < lastCount && lastCount != 0)
    {
        if(lastCount != 1)Notifications(1);
        lastCount = count;
    }

if(alertPriceIntoZone)
    if(PriceIntoZone())
    {
        Notifications(3);
    }
}

double lastZone = 0;
bool PriceIntoZone()
{
    for(int i = 0; i < ObjectsTotal(); i++)
    {
        string n = ObjectName(i);
        if(ObjectGetInteger(0, n, OBJPROP_TYPE) != OBJ_RECTANGLE)continue;

        double prSup = ObjectGetDouble(0, n, OBJPROP_PRICE1);
        // Print(__FUNCTION__, " prSup: ", prSup);
        double prInf = ObjectGetDouble(0, n, OBJPROP_PRICE2);
        // Print(__FUNCTION__," prInf: ",prInf);

        if(Bid > prInf && Bid < prSup && prSup != lastZone) { lastZone = prSup; return true; }
        if(Ask > prInf && Ask < prSup && prSup != lastZone) { lastZone = prSup; return true; }

    }
    return false;

}

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 
