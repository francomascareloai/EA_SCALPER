//+------------------------------------------------------------------+
//|        AutoPivotIndicator.mq4              by Habeeb             |
//|                                                                  |
//+------------------------------------------------------------------+

#property indicator_chart_window

   extern bool Daily   = True;
   extern bool Weekly  = False;
   extern bool Monthly = False;

   double YesterdayHigh;
   double YesterdayLow;
   double YesterdayClose;
   double Day_Price[][6];
   double Pivot,S1,S2,S3,R1,R2,R3;
   
   double WeekHigh;
   double WeekLow;
   double WeekClose;
   double Weekly_Price[][6];
   double WeekPivot,WS1,WS2,WS3,WR1,WR2,WR3;
   
   double MonthHigh;
   double MonthLow;
   double MonthClose;
   double Month_Price[][6];
   double MonthPivot,MS1,MS2,MS3,MR1,MR2,MR3;

int init()
  {
   return(0);
  }
  
//-------------------------------------------------------- 
  
int deinit()
  {
ObjectDelete("PivotLine");

ObjectDelete("R1_Line");
ObjectDelete("R2_Line");
ObjectDelete("R3_Line");

ObjectDelete("S1_Line");
ObjectDelete("S2_Line");
ObjectDelete("S3_Line");  

//--------------------------------

ObjectDelete("PivotLabel");

ObjectDelete("R1_Label");
ObjectDelete("R2_Label");
ObjectDelete("R3_Label");

ObjectDelete("S1_Label");
ObjectDelete("S2_Label");
ObjectDelete("S3_Label"); 

//--------------------------------------------------------

ObjectDelete("WeekPivotLine");

ObjectDelete("WR1_Line");
ObjectDelete("WR2_Line");
ObjectDelete("WR3_Line");

ObjectDelete("WS1_Line");
ObjectDelete("WS2_Line");
ObjectDelete("WS3_Line");  

//--------------------------------

ObjectDelete("WeekPivotLabel");

ObjectDelete("WR1_Label");
ObjectDelete("WR2_Label");
ObjectDelete("WR3_Label");

ObjectDelete("WS1_Label");
ObjectDelete("WS2_Label");
ObjectDelete("WS3_Label");  

//--------------------------------------------------------

ObjectDelete("MonthPivotLine");

ObjectDelete("MR1_Line");
ObjectDelete("MR2_Line");
ObjectDelete("MR3_Line");

ObjectDelete("MS1_Line");
ObjectDelete("MS2_Line");
ObjectDelete("MS3_Line");  

//--------------------------------

ObjectDelete("MonthPivotLabel");

ObjectDelete("MR1_Label");
ObjectDelete("MR2_Label");
ObjectDelete("MR3_Label");

ObjectDelete("MS1_Label");
ObjectDelete("MS2_Label");
ObjectDelete("MS3_Label");

return(0);
}
//--------------------------------------------------------- 

int start()
{

ArrayInitialize(Day_Price,0);
ArrayCopyRates(Day_Price,(Symbol()), 1440);


YesterdayHigh  = Day_Price[1][3];
YesterdayLow   = Day_Price[1][2];
YesterdayClose = Day_Price[1][4];

Pivot = ((YesterdayHigh + YesterdayLow + YesterdayClose)/3);

   R1 = (2*Pivot)-YesterdayLow;
   S1 = (2*Pivot)-YesterdayHigh;

   R2 = Pivot+(R1-S1);
   S2 = Pivot-(R1-S1);

   S3 = (YesterdayLow - (2*(YesterdayHigh-Pivot)));
   R3 = (YesterdayHigh + (2*(Pivot-YesterdayLow)));

//--------------------------------------------------------
//--------------------------------------------------------

ArrayInitialize(Weekly_Price, 0);
ArrayCopyRates(Weekly_Price, Symbol(), 10080);

WeekHigh  = Weekly_Price[1][3];
WeekLow   = Weekly_Price[1][2];
WeekClose = Weekly_Price[1][4];

WeekPivot = ((WeekHigh + WeekLow + WeekClose)/3);

      WR1 = (2*WeekPivot)-WeekLow;
      WS1 = (2*WeekPivot)-WeekHigh;

      WR2 = WeekPivot+(WR1-WS1);
      WS2 = WeekPivot-(WR1-WS1);

      WS3 = (WeekLow - (2*(WeekHigh-WeekPivot)));
      WR3 = (WeekHigh + (2*(WeekPivot-WeekLow)));

//--------------------------------------------------------
//--------------------------------------------------------

ArrayInitialize(Month_Price, 0);
ArrayCopyRates(Month_Price, Symbol(), 43200);

MonthHigh  = Month_Price[1][3];
MonthLow   = Month_Price[1][2];
MonthClose = Month_Price[1][4];

MonthPivot = ((MonthHigh + MonthLow + MonthClose)/3);

      MR1 = (2*MonthPivot)-MonthLow;
      MS1 = (2*MonthPivot)-MonthHigh;

      MR2 = MonthPivot+(MR1-MS1);
      MS2 = MonthPivot-(MR1-MS1);

      MS3 = (MonthLow - (2*(MonthHigh-MonthPivot)));
      MR3 = (MonthHigh + (2*(MonthPivot-MonthLow)));

//--------------------------------------------------------

if (Daily==true)
{

ObjectCreate("PivotLine", OBJ_HLINE,0, CurTime(),Pivot);
ObjectSet("PivotLine", OBJPROP_COLOR, Magenta);
ObjectSet("PivotLine", OBJPROP_STYLE, STYLE_DASH);

if(ObjectFind("PivotLabel") != 0)
{
ObjectCreate("PivotLabel", OBJ_TEXT, 0, Time[20], Pivot);
ObjectSetText("PivotLabel", "Daily Pivot", 8, "Arial", Magenta);
}
else
{
ObjectMove("PivotLabel", 0, Time[20], Pivot);
}

//--------------------------------------------------------

ObjectCreate("R1_Line", OBJ_HLINE,0, CurTime(),R1);
ObjectSet("R1_Line", OBJPROP_COLOR, Red);
ObjectSet("R1_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);

if(ObjectFind("R1_Label") != 0)
{
ObjectCreate("R1_Label", OBJ_TEXT, 0, Time[20], R1);
ObjectSetText("R1_Label", "Daily R1", 8, "Arial", Red);
}
else
{
ObjectMove("R1_Label", 0, Time[20], R1);
}

//--------------------------------------------------------

ObjectCreate("R2_Line", OBJ_HLINE,0, CurTime(),R2);
ObjectSet("R2_Line", OBJPROP_COLOR, Red);
ObjectSet("R2_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);

if(ObjectFind("R2_Label") != 0)
{
ObjectCreate("R2_Label", OBJ_TEXT, 0, Time[20], R2);
ObjectSetText("R2_Label", "Daily R2", 8, "Arial", Red);
}
else
{
ObjectMove("R2_Label", 0, Time[20], R2);
}

//---------------------------------------------------------

ObjectCreate("R3_Line", OBJ_HLINE,0, CurTime(),R3);
ObjectSet("R3_Line", OBJPROP_COLOR, Red);
ObjectSet("R3_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);

if(ObjectFind("R3_Label") != 0)
{
ObjectCreate("R3_Label", OBJ_TEXT, 0, Time[20], R3);
ObjectSetText("R3_Label", "Daily R3", 8, "Arial", Red);
}
else
{
ObjectMove("R3_Label", 0, Time[20], R3);
}

//---------------------------------------------------------

ObjectCreate("S1_Line", OBJ_HLINE,0, CurTime(),S1);
ObjectSet("S1_Line", OBJPROP_COLOR, LimeGreen);
ObjectSet("S1_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);

if(ObjectFind("S1_Label") != 0)
{
ObjectCreate("S1_Label", OBJ_TEXT, 0, Time[20], S1);
ObjectSetText("S1_Label", "Daily S1", 8, "Arial", LimeGreen);
}
else
{
ObjectMove("S1_Label", 0, Time[20], S1);
}

//---------------------------------------------------------

ObjectCreate("S2_Line", OBJ_HLINE,0, CurTime(),S2);
ObjectSet("S2_Line", OBJPROP_COLOR, LimeGreen);
ObjectSet("S2_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);

if(ObjectFind("S2_Label") != 0)
{
ObjectCreate("S2_Label", OBJ_TEXT, 0, Time[20], S2);
ObjectSetText("S2_Label", "Daily S2", 8, "Arial", LimeGreen);
}
else
{
ObjectMove("S2_Label", 0, Time[20], S2);
}
//---------------------------------------------------------

ObjectCreate("S3_Line", OBJ_HLINE,0, CurTime(),S3);
ObjectSet("S3_Line", OBJPROP_COLOR, LimeGreen);
ObjectSet("S3_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);

if(ObjectFind("S3_Label") != 0)
{
ObjectCreate("S3_Label", OBJ_TEXT, 0, Time[20], S3);
ObjectSetText("S3_Label", "Daily S3", 8, "Arial", LimeGreen);
}
else
{
ObjectMove("S3_Label", 0, Time[20], S3);
}
}
ObjectsRedraw();

//---------------------------------------------------------
//---------------------------------------------------------
//---------------------------------------------------------

if (Weekly==true)
{
ObjectCreate("WeekPivotLine", OBJ_HLINE,0, CurTime(),WeekPivot);
ObjectSet("WeekPivotLine", OBJPROP_COLOR, Aqua);
ObjectSet("WeekPivotLine", OBJPROP_STYLE, STYLE_DASH);

if(ObjectFind("WeekPivotLabel") != 0)
{
ObjectCreate("WeekPivotLabel", OBJ_TEXT, 0, Time[30], WeekPivot);
ObjectSetText("WeekPivotLabel", "WeeklyPivot", 8, "Arial", Aqua);
}
else
{
ObjectMove("WeekPivotLabel", 0, Time[30], WeekPivot);
}

//--------------------------------------------------------

ObjectCreate("WR1_Line", OBJ_HLINE,0, CurTime(),WR1);
ObjectSet("WR1_Line", OBJPROP_COLOR, Yellow);
ObjectSet("WR1_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);

if(ObjectFind("WR1_Label") != 0)
{
ObjectCreate("WR1_Label", OBJ_TEXT, 0, Time[30], WR1);
ObjectSetText("WR1_Label", " Weekly R1", 8, "Arial", Yellow);
}
else
{
ObjectMove("WR1_Label", 0, Time[30], WR1);
}

//--------------------------------------------------------

ObjectCreate("WR2_Line", OBJ_HLINE,0, CurTime(),WR2);
ObjectSet("WR2_Line", OBJPROP_COLOR, Yellow);
ObjectSet("WR2_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);

if(ObjectFind("WR2_Label") != 0)
{
ObjectCreate("WR2_Label", OBJ_TEXT, 0, Time[30], WR2);
ObjectSetText("WR2_Label", " Weekly R2", 8, "Arial", Yellow);
}
else
{
ObjectMove("WR2_Label", 0, Time[30], WR2);
}

//---------------------------------------------------------

ObjectCreate("WR3_Line", OBJ_HLINE,0, CurTime(),WR3);
ObjectSet("WR3_Line", OBJPROP_COLOR, Yellow);
ObjectSet("WR3_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);

if(ObjectFind("WR3_Label") != 0)
{
ObjectCreate("WR3_Label", OBJ_TEXT, 0, Time[30], WR3);
ObjectSetText("WR3_Label", " Weekly R3", 8, "Arial", Yellow);
}
else
{
ObjectMove("WR3_Label", 0, Time[30], WR3);
}

//---------------------------------------------------------

ObjectCreate("WS1_Line", OBJ_HLINE,0, CurTime(),WS1);
ObjectSet("WS1_Line", OBJPROP_COLOR, SteelBlue);
ObjectSet("WS1_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);

if(ObjectFind("WS1_Label") != 0)
{
ObjectCreate("WS1_Label", OBJ_TEXT, 0, Time[30], WS1);
ObjectSetText("WS1_Label", "Weekly S1", 8, "Arial", SteelBlue);
}
else
{
ObjectMove("WS1_Label", 0, Time[30], WS1);
}

//---------------------------------------------------------

ObjectCreate("WS2_Line", OBJ_HLINE,0, CurTime(),WS2);
ObjectSet("WS2_Line", OBJPROP_COLOR, SteelBlue);
ObjectSet("WS2_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);

if(ObjectFind("WS2_Label") != 0)
{
ObjectCreate("WS2_Label", OBJ_TEXT, 0, Time[30], WS2);
ObjectSetText("WS2_Label", "Weekly S2", 8, "Arial", SteelBlue);
}
else
{
ObjectMove("WS2_Label", 0, Time[30], WS2);
}

//---------------------------------------------------------

ObjectCreate("WS3_Line", OBJ_HLINE,0, CurTime(),WS3);
ObjectSet("WS3_Line", OBJPROP_COLOR, SteelBlue);
ObjectSet("WS3_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);

if(ObjectFind("WS3_Label") != 0)
{
ObjectCreate("WS3_Label", OBJ_TEXT, 0, Time[30], WS3);
ObjectSetText("WS3_Label", "Weekly S3", 8, "Arial", SteelBlue);
}
else
{
ObjectMove("WS3_Label", 0, Time[30], WS3);
}
}
//---------------------------------------------------------
//---------------------------------------------------------
//---------------------------------------------------------

if (Monthly==true)
{
ObjectCreate("MonthPivotLine", OBJ_HLINE,0, CurTime(),MonthPivot);
ObjectSet("MonthPivotLine", OBJPROP_COLOR, Brown);
ObjectSet("MonthPivotLine", OBJPROP_STYLE, STYLE_DASH);

if(ObjectFind("MonthPivotLabel") != 0)
{
ObjectCreate("MonthPivotLabel", OBJ_TEXT, 0, Time[40], MonthPivot);
ObjectSetText("MonthPivotLabel", "MonthlyPivot", 8, "Arial", Brown);
}
else
{
ObjectMove("MonthPivotLabel", 0, Time[40], MonthPivot);
}

//--------------------------------------------------------

ObjectCreate("MR1_Line", OBJ_HLINE,0, CurTime(),MR1);
ObjectSet("MR1_Line", OBJPROP_COLOR, Blue);
ObjectSet("MR1_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);

if(ObjectFind("MR1_Label") != 0)
{
ObjectCreate("MR1_Label", OBJ_TEXT, 0, Time[40], MR1);
ObjectSetText("MR1_Label", " Monthly R1", 8, "Arial", Blue);
}
else
{
ObjectMove("MR1_Label", 0, Time[40], MR1);
}

//--------------------------------------------------------

ObjectCreate("MR2_Line", OBJ_HLINE,0, CurTime(),MR2);
ObjectSet("MR2_Line", OBJPROP_COLOR, Blue);
ObjectSet("MR2_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);

if(ObjectFind("MR2_Label") != 0)
{
ObjectCreate("MR2_Label", OBJ_TEXT, 0, Time[40], MR2);
ObjectSetText("MR2_Label", " Monthly R2", 8, "Arial", Blue);
}
else
{
ObjectMove("MR2_Label", 0, Time[40], MR2);
}

//---------------------------------------------------------

ObjectCreate("MR3_Line", OBJ_HLINE,0, CurTime(),MR3);
ObjectSet("MR3_Line", OBJPROP_COLOR, Blue);
ObjectSet("MR3_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);

if(ObjectFind("MR3_Label") != 0)
{
ObjectCreate("MR3_Label", OBJ_TEXT, 0, Time[40], MR3);
ObjectSetText("MR3_Label", " Monthly R3", 8, "Arial", Blue);
}
else
{
ObjectMove("MR3_Label", 0, Time[40], MR3);
}

//---------------------------------------------------------

ObjectCreate("MS1_Line", OBJ_HLINE,0, CurTime(),MS1);
ObjectSet("MS1_Line", OBJPROP_COLOR, Silver);
ObjectSet("MS1_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);

if(ObjectFind("MS1_Label") != 0)
{
ObjectCreate("MS1_Label", OBJ_TEXT, 0, Time[40], MS1);
ObjectSetText("MS1_Label", "Monthly S1", 8, "Arial", Silver);
}
else
{
ObjectMove("MS1_Label", 0, Time[40], MS1);
}

//---------------------------------------------------------

ObjectCreate("MS2_Line", OBJ_HLINE,0, CurTime(),MS2);
ObjectSet("MS2_Line", OBJPROP_COLOR, Silver);
ObjectSet("MS2_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);

if(ObjectFind("MS2_Label") != 0)
{
ObjectCreate("MS2_Label", OBJ_TEXT, 0, Time[40], MS2);
ObjectSetText("MS2_Label", "Monthly S2", 8, "Arial", Silver);
}
else
{
ObjectMove("MS2_Label", 0, Time[40], MS2);
}

//---------------------------------------------------------

ObjectCreate("MS3_Line", OBJ_HLINE,0, CurTime(),MS3);
ObjectSet("MS3_Line", OBJPROP_COLOR, Silver);
ObjectSet("MS3_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);

if(ObjectFind("MS3_Label") != 0)
{
ObjectCreate("MS3_Label", OBJ_TEXT, 0, Time[40], MS3);
ObjectSetText("MS3_Label", "Monthly S3", 8, "Arial", Silver);
}
else
{
ObjectMove("MS3_Label", 0, Time[40], MS3);
}
}
//---------------------------------------------------------

ObjectsRedraw();

   return(0);
}