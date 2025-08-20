//+------------------------------------------------------------------+
//|                                       AutoFibPivotIndicator.mq4  |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+

#property indicator_chart_window

//
//
//
//
//  

#import "kernel32.dll"
int  GetTimeZoneInformation(int& TZInfoArray[]);
#import

//
//
//
//
//

#define TIME_ZONE_ID_UNKNOWN   0
#define TIME_ZONE_ID_STANDARD  1
#define TIME_ZONE_ID_DAYLIGHT  2

//
//
//
//
//      

extern int    DaysBack           = 1;
extern bool   Use_Sunday_Data    = false;
extern bool   Daily              = false;
extern bool   Daily_SR_Levels    = false;
extern bool   Daily_Mid_Levels   = false;
extern bool   Weekly             = false;
extern bool   Weekly_SR_Levels   = false;
extern bool   Weekly_Mid_Levels  = false;
extern bool   Monthly            = true;
extern bool   Monthly_SR_Levels  = true;
extern bool   Monthly_Mid_Levels = true;
   
extern color  Daily_Pivot        = Gold;
extern color  Daily_S_Levels     = LimeGreen;
extern color  Daily_R_Levels     = Red;
extern color  Daily_Mid_Level    = Teal;
   
extern color  Weekly_Pivot       = Goldenrod;
extern color  Weekly_S_Levels    = SteelBlue;
extern color  Weekly_R_Levels    = Crimson;
extern color  Weekly_Mid_Level   = DarkSlateGray;
   
extern color  Monthly_Pivot      = DarkGoldenrod;
extern color  Monthly_S_Levels   = DodgerBlue;
extern color  Monthly_R_Levels   = DeepPink;
extern color  Monthly_Mid_Level  = LightSalmon;   
   
extern string comments           = "Comments on true or false"; 
extern bool   CommentsOn         = false;   
extern string rangecomments      = "Range Comments";               
extern int    ShortRange         = 5;
extern int    InterRange         = 10;
extern int    LongRange          = 20;  
   
//
//
//
//
//

int    TZInfoArray[43];
   
double YesterdayHigh;
double YesterdayLow;
double YesterdayClose;
double Day_Price[][6];
double DailyRange;
double D_day_high = 0;
double D_day_low  = 0;
double D_nQ = 0;
double D_nD = 0;
double D_D  = 0;
double D_Q  = 0;
double Pivot,S1,S2,S3,R1,R2,R3;
double DM1,DM2,DM3,DM4,DM5,DM6;  //daily mid-pivots
      
double WeekHigh;
double WeekLow;
double WeekClose;
double Weekly_Price[][6];
double WeekRange;
double W_day_high = 0;
double W_day_low  = 0;
double W_nQ = 0;
double W_nD = 0;
double W_D  = 0;
double W_Q  = 0;
double WeekPivot,WS1,WS2,WS3,WR1,WR2,WR3;
double WM1,WM2,WM3,WM4,WM5,WM6;  //weekly mid-pivots
   
double MonthHigh;
double MonthLow;
double MonthClose;
double Month_Price[][6];
double MonthRange;
double M_day_high = 0;
double M_day_low  = 0;
double M_nQ = 0;
double M_nD = 0;
double M_D  = 0;
double M_Q  = 0;
double MonthPivot,MS1,MS2,MS3,MR1,MR2,MR3;
double MM1,MM2,MM3,MM4,MM5,MM6;  //monthly mid-pivots

//
//
//
//
//
  
int init()
{
return(0);
}
  
//-------------------------------------------------------- 
//
//
//
//
  
int deinit()
  {
ObjectDelete("PivotLine");

ObjectDelete("R1_Line");
ObjectDelete("R2_Line");
ObjectDelete("R3_Line");

ObjectDelete("S1_Line");
ObjectDelete("S2_Line");
ObjectDelete("S3_Line");  

ObjectDelete("DM1_Line");
ObjectDelete("DM2_Line");
ObjectDelete("DM3_Line");
ObjectDelete("DM4_Line");
ObjectDelete("DM5_Line");
ObjectDelete("DM6_Line"); 

//--------------------------------

ObjectDelete("PivotLabel");

ObjectDelete("R1_Label");
ObjectDelete("R2_Label");
ObjectDelete("R3_Label");

ObjectDelete("S1_Label");
ObjectDelete("S2_Label");
ObjectDelete("S3_Label"); 

ObjectDelete("DM1_Label");
ObjectDelete("DM2_Label");
ObjectDelete("DM3_Label");
ObjectDelete("DM4_Label");
ObjectDelete("DM5_Label");
ObjectDelete("DM6_Label");

//--------------------------------------------------------

ObjectDelete("WeekPivotLine");

ObjectDelete("WR1_Line");
ObjectDelete("WR2_Line");
ObjectDelete("WR3_Line");

ObjectDelete("WS1_Line");
ObjectDelete("WS2_Line");
ObjectDelete("WS3_Line");  

ObjectDelete("WM1_Line");
ObjectDelete("WM2_Line");
ObjectDelete("WM3_Line");
ObjectDelete("WM4_Line");
ObjectDelete("WM5_Line");
ObjectDelete("WM6_Line");

//--------------------------------

ObjectDelete("WeekPivotLabel");

ObjectDelete("WR1_Label");
ObjectDelete("WR2_Label");
ObjectDelete("WR3_Label");

ObjectDelete("WS1_Label");
ObjectDelete("WS2_Label");
ObjectDelete("WS3_Label");  

ObjectDelete("WM1_Label");
ObjectDelete("WM2_Label");
ObjectDelete("WM3_Label");
ObjectDelete("WM4_Label");
ObjectDelete("WM5_Label");
ObjectDelete("WM6_Label");

//--------------------------------------------------------

ObjectDelete("MonthPivotLine");

ObjectDelete("MR1_Line");
ObjectDelete("MR2_Line");
ObjectDelete("MR3_Line");

ObjectDelete("MS1_Line");
ObjectDelete("MS2_Line");
ObjectDelete("MS3_Line");  

ObjectDelete("MM1_Line");
ObjectDelete("MM2_Line");
ObjectDelete("MM3_Line");
ObjectDelete("MM4_Line");
ObjectDelete("MM5_Line");
ObjectDelete("MM6_Line");

//--------------------------------

ObjectDelete("MonthPivotLabel");

ObjectDelete("MR1_Label");
ObjectDelete("MR2_Label");
ObjectDelete("MR3_Label");

ObjectDelete("MS1_Label");
ObjectDelete("MS2_Label");
ObjectDelete("MS3_Label");

ObjectDelete("MM1_Label");
ObjectDelete("MM2_Label");
ObjectDelete("MM3_Label");
ObjectDelete("MM4_Label");
ObjectDelete("MM5_Label");
ObjectDelete("MM6_Label");

Comment(" ");

return(0);
}

//--------------------------------------------------------- 
//
//
//
//

int start()
{

   if (!IsDllsAllowed()) 
   {
     Alert("DLLs are disabled.  To enable  check the box in the tools/options/expert advisors on your chart");
     return(0);
   }
     RefreshRates();
     ArrayCopyRates(Day_Price,(Symbol()), 1440);
  
     YesterdayHigh  = Day_Price[DaysBack][3];
     YesterdayLow   = Day_Price[DaysBack][2];
     YesterdayClose = Day_Price[DaysBack][4];
     DailyRange     =  (YesterdayHigh - YesterdayLow);
     Pivot          = ((YesterdayHigh + YesterdayLow + YesterdayClose)/3);

     R1 = Pivot + (DailyRange * 0.382);
     S1 = Pivot - (DailyRange * 0.382);
     R2 = Pivot + (DailyRange * 0.618);
     S2 = Pivot - (DailyRange * 0.618); 
     R3 = Pivot + (DailyRange * 1.000);
     S3 = Pivot - (DailyRange * 1.000);
   
     DM1 = (S2 + S3)    * 0.5;
     DM2 = (S1 + S2)    * 0.5;
     DM3 = (Pivot + S1) * 0.5;
     DM4 = (Pivot + R1) * 0.5;
     DM5 = (R1 + R2)    * 0.5;
     DM6 = (R2 + R3)    * 0.5;
  
  
     if (Use_Sunday_Data == false)
     {   
  
       while (DayOfWeek() == 1 && DaysBack == 1)
       {        
         YesterdayHigh  = Day_Price[2][3];
         YesterdayLow   = Day_Price[2][2];
         YesterdayClose = Day_Price[2][4];
         DailyRange     =  (YesterdayHigh - YesterdayLow);
         Pivot          = ((YesterdayHigh + YesterdayLow + YesterdayClose)/3);

         R1  = Pivot + (DailyRange * 0.382);
         S1  = Pivot - (DailyRange * 0.382);
         R2  = Pivot + (DailyRange * 0.618);
         S2  = Pivot - (DailyRange * 0.618); 
         R3  = Pivot + (DailyRange * 1.000);
         S3  = Pivot - (DailyRange * 1.000);
   
         DM1 = (S2 + S3)   * 0.5;
         DM2 = (S1 + S2)   * 0.5;
         DM3 = (Pivot + S1)* 0.5;
         DM4 = (Pivot + R1)* 0.5;
         DM5 = (R1 + R2)   * 0.5;
         DM6 = (R2 + R3)   * 0.5;
       
         D_day_high  = Day_Price[0][3];
         D_day_low   = Day_Price[0][2];
         D_D         = (D_day_high - D_day_low);
         D_Q         = (YesterdayHigh - YesterdayLow);
       
         if (D_Q > 5) { D_nQ = D_Q;       }
         else         { D_nQ = D_Q*10000; }

         if (D_D > 5) { D_nD = D_D;       }
         else         { D_nD = D_D*10000; }
       
         if (StringSubstr(Symbol(),3,3)=="JPY") { D_nQ=D_nQ/100; D_nD=D_nD/100; }
  
         break;
      }
 }
  
//--------------------------------------------------------
//--------------------------------------------------------
//
//

      RefreshRates();
      ArrayCopyRates(Weekly_Price, Symbol(), 10080);

      WeekHigh  = Weekly_Price[1][3];
      WeekLow   = Weekly_Price[1][2];
      WeekClose = Weekly_Price[1][4];
      WeekRange = WeekHigh - WeekLow;
      WeekPivot = ((WeekHigh + WeekLow + WeekClose)/3);

      WR1 = WeekPivot + (WeekRange * 0.382);
      WS1 = WeekPivot - (WeekRange * 0.382);
      WR2 = WeekPivot + (WeekRange * 0.618);
      WS2 = WeekPivot - (WeekRange * 0.618);
      WR3 = WeekPivot + (WeekRange * 1.000);
      WS3 = WeekPivot - (WeekRange * 1.000);
      
      WM1 = (WS2 + WS3)      * 0.5;
      WM2 = (WS1 + WS2)      * 0.5;
      WM3 = (WeekPivot + WS1)* 0.5;
      WM4 = (WeekPivot + WR1)* 0.5;
      WM5 = (WR1 + WR2)      * 0.5;
      WM6 = (WR2 + WR3)      * 0.5;
      
      W_day_high = Weekly_Price[0][3];
      W_day_low  = Weekly_Price[0][2];
      W_D        = (W_day_high - W_day_low);
      W_Q        = (WeekHigh   - WeekLow);
      
      if (W_Q > 5) {  W_nQ = W_Q;       }
      else         {  W_nQ = W_Q*10000; }

      if (W_D > 5) {  W_nD = W_D;       }
      else         {  W_nD = W_D*10000; }
      
      if (StringSubstr(Symbol(),3,3)=="JPY") { W_nQ=W_nQ/100; W_nD=W_nD/100;  }

//--------------------------------------------------------
//--------------------------------------------------------
//
//
//

      RefreshRates();
      ArrayCopyRates(Month_Price, Symbol(), 43200);

      MonthHigh  = Month_Price[1][3];
      MonthLow   = Month_Price[1][2];
      MonthClose = Month_Price[1][4];
      MonthRange =  (MonthHigh - MonthLow); 
      MonthPivot = ((MonthHigh + MonthLow + MonthClose)/3);

      MR1  = MonthPivot + (MonthRange * 0.382);
      MS1  = MonthPivot - (MonthRange * 0.382);
      MR2  = MonthPivot + (MonthRange * 0.618);
      MS2  = MonthPivot - (MonthRange * 0.618);
      MR3  = MonthPivot + (MonthRange * 1.000);
      MS3  = MonthPivot - (MonthRange * 1.000);
      
      MM1 = (MS2 + MS3)       * 0.5;
      MM2 = (MS1 + MS2)       * 0.5;
      MM3 = (MonthPivot + MS1)* 0.5;
      MM4 = (MonthPivot + MR1)* 0.5;
      MM5 = (MR1 + MR2)       * 0.5;
      MM6 = (MR2 + MR3)       * 0.5;
      
      M_day_high = Month_Price[0][3];
      M_day_low  = Month_Price[0][2];
      M_D        = (M_day_high - M_day_low);
      M_Q        = (MonthHigh - MonthLow);
      
      if (M_Q > 5) { M_nQ = M_Q;       }
      else         { M_nQ = M_Q*10000; }

      if (M_D > 5) { M_nD = M_D;       }
      else         { M_nD = M_D*10000; }
      
      if (StringSubstr(Symbol(),3,3)=="JPY") { M_nQ=M_nQ/100; M_nD=M_nD/100; }
   

//--------------------------------------------------------
//
//
//
//

RefreshRates();

if (Daily==true)
 {
  TimeToStr(iTimeGMT());
  
  if(ObjectFind("PivotLine") != 0)
  {
   ObjectCreate("PivotLine", OBJ_HLINE,0, iTimeGMT(),Pivot);
      ObjectSet("PivotLine", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("PivotLine", OBJPROP_WIDTH, 1);
      ObjectSet("PivotLine", OBJPROP_COLOR, Daily_Pivot);
  }
  else
  {
     ObjectMove("PivotLine", 0, Time[20], Pivot);   
  }

  if(ObjectFind("PivotLabel") != 0)
  {
   ObjectCreate("PivotLabel", OBJ_TEXT, 0, Time[20], Pivot);
   ObjectSetText("PivotLabel", ("Daily Pivot"), 8, "Arial", Daily_Pivot);
  }
  else
  {
   ObjectMove("PivotLabel", 0, Time[20], Pivot);
  }

//--------------------------------------------------------
//
//
//
//

if (Daily_SR_Levels==true)
 {
  if(ObjectFind("R1_Line") != 0)
  { 
    ObjectCreate("R1_Line", OBJ_HLINE,0, iTimeGMT(),R1);
       ObjectSet("R1_Line", OBJPROP_STYLE, STYLE_SOLID);
       ObjectSet("R1_Line", OBJPROP_WIDTH, 1);
       ObjectSet("R1_Line", OBJPROP_COLOR, Daily_R_Levels);
  }
  else
  {
    ObjectMove("R1_Line", 0, Time[20], R1);
  }

 if(ObjectFind("R1_Label") != 0)
 {
   ObjectCreate("R1_Label", OBJ_TEXT, 0, Time[20], R1);
   ObjectSetText("R1_Label", "Daily R1", 8, "Arial", Daily_R_Levels);
 }
 else
 {
   ObjectMove("R1_Label", 0, Time[20], R1);
 }

//--------------------------------------------------------

 if(ObjectFind("R2_Line") != 0)
 {
    ObjectCreate("R2_Line", OBJ_HLINE,0, iTimeGMT(),R2);
       ObjectSet("R2_Line", OBJPROP_STYLE, STYLE_SOLID);
       ObjectSet("R2_Line", OBJPROP_WIDTH, 1);
       ObjectSet("R2_Line", OBJPROP_COLOR, Daily_R_Levels);
 }
 else
 {
    ObjectMove("R2_Line", 0, Time[20], R2);
 }
  
 if(ObjectFind("R2_Label") != 0)
 {
   ObjectCreate("R2_Label", OBJ_TEXT, 0, Time[20], R2);
   ObjectSetText("R2_Label", "Daily R2", 8, "Arial", Daily_R_Levels);
  }
 else
  {
   ObjectMove("R2_Label", 0, Time[20], R2);
  }

//---------------------------------------------------------

 if(ObjectFind("R3_Line") != 0)
   {
    ObjectCreate("R3_Line", OBJ_HLINE,0, iTimeGMT(),R3);
    ObjectSet("R3_Line", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet("R3_Line", OBJPROP_WIDTH, 1);
    ObjectSet("R3_Line", OBJPROP_COLOR, Daily_R_Levels);
   }
  else
   {
    ObjectMove("R3_Line", 0, Time[20], R3);
   }
   
 if(ObjectFind("R3_Label") != 0)
  {
   ObjectCreate("R3_Label", OBJ_TEXT, 0, Time[20], R3);
   ObjectSetText("R3_Label", "Daily R3", 8, "Arial", Daily_R_Levels);
  }
 else
  {
   ObjectMove("R3_Label", 0, Time[20], R3);
  }

//---------------------------------------------------------

 if(ObjectFind("S1_Line") != 0)
   {
    ObjectCreate("S1_Line", OBJ_HLINE,0, iTimeGMT(),S1);
    ObjectSet("S1_Line", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet("S1_Line", OBJPROP_WIDTH, 1);
    ObjectSet("S1_Line", OBJPROP_COLOR, Daily_S_Levels);
   }
  else
   {
    ObjectMove("S1_Line", 0, Time[20], S1);
   }
   
 if(ObjectFind("S1_Label") != 0)
  {
   ObjectCreate("S1_Label", OBJ_TEXT, 0, Time[20], S1);
   ObjectSetText("S1_Label", "Daily S1", 8, "Arial", Daily_S_Levels);
  }
 else
  {
   ObjectMove("S1_Label", 0, Time[20], S1);
  }

//---------------------------------------------------------

 if(ObjectFind("S2_Line") != 0)
   {
    ObjectCreate("S2_Line", OBJ_HLINE,0, iTimeGMT(),S2);
    ObjectSet("S2_Line", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet("S2_Line", OBJPROP_WIDTH, 1);
    ObjectSet("S2_Line", OBJPROP_COLOR, Daily_S_Levels);
   }
  else
   {
    ObjectMove("S2_Line", 0, Time[20], S2);
   }
   
 if(ObjectFind("S2_Label") != 0)
  {
   ObjectCreate("S2_Label", OBJ_TEXT, 0, Time[20], S2);
   ObjectSetText("S2_Label", "Daily S2", 8, "Arial", Daily_S_Levels);
  }
 else
  {
   ObjectMove("S2_Label", 0, Time[20], S2);
  }

//---------------------------------------------------------

 if(ObjectFind("S3_Line") != 0)
   {
    ObjectCreate("S3_Line", OBJ_HLINE,0, iTimeGMT(),S3);
    ObjectSet("S3_Line", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet("S3_Line", OBJPROP_WIDTH, 1);
    ObjectSet("S3_Line", OBJPROP_COLOR, Daily_S_Levels);
   }
  else
   {
    ObjectMove("S3_Line", 0, Time[20], S3);
   }
   
 if(ObjectFind("S3_Label") != 0)
  {
   ObjectCreate("S3_Label", OBJ_TEXT, 0, Time[20], S3);
   ObjectSetText("S3_Label", "Daily S3", 8, "Arial", Daily_S_Levels);
  }
 else
  {
   ObjectMove("S3_Label", 0, Time[20], S3);
  }
  
 }

//-------------------------------------------------
//
//
//
//

RefreshRates();

if (Daily_Mid_Levels==True)
 {
  TimeToStr(iTimeGMT());
  if(ObjectFind("DM1_Line") != 0)
   { 
    ObjectCreate("DM1_Line", OBJ_HLINE,0, iTimeGMT(),DM1);
    ObjectSet("DM1_Line", OBJPROP_COLOR, Daily_Mid_Level);
    ObjectSet("DM1_Line", OBJPROP_STYLE, STYLE_DASH);
   }
  else
   {
   ObjectMove("DM1_Line", 0, Time[15], DM1);
   }

 if(ObjectFind("DM1_Label") != 0)
  {
   ObjectCreate("DM1_Label", OBJ_TEXT, 0, Time[15], DM1);
   ObjectSetText("DM1_Label", "DM1", 8, "Arial", Daily_Mid_Level);
  }
 else
  {
   ObjectMove("DM1_Label", 0, Time[15], DM1);
  }
//-------------------------------------
   
  if(ObjectFind("DM2_Line") != 0)
   { 
    ObjectCreate("DM2_Line", OBJ_HLINE,0, iTimeGMT(),DM2);
    ObjectSet("DM2_Line", OBJPROP_COLOR, Daily_Mid_Level);
    ObjectSet("DM2_Line", OBJPROP_STYLE, STYLE_DASH);
   }
  else
   {
   ObjectMove("DM2_Line", 0, Time[15], DM2);
   }

 if(ObjectFind("DM2_Label") != 0)
  {
   ObjectCreate("DM2_Label", OBJ_TEXT, 0, Time[15], DM2);
   ObjectSetText("DM2_Label", "DM2", 8, "Arial", Daily_Mid_Level);
  }
 else
  {
   ObjectMove("DM2_Label", 0, Time[15], DM2);
  }
//------------------------------------
   
  if(ObjectFind("DM3_Line") != 0)
   { 
    ObjectCreate("DM3_Line", OBJ_HLINE,0, iTimeGMT(),DM3);
    ObjectSet("DM3_Line", OBJPROP_COLOR, Daily_Mid_Level);
    ObjectSet("DM3_Line", OBJPROP_STYLE, STYLE_DASH);
   }
  else
   {
   ObjectMove("DM3_Line", 0, Time[15], DM3);
   }

 if(ObjectFind("DM3_Label") != 0)
  {
   ObjectCreate("DM3_Label", OBJ_TEXT, 0, Time[15], DM3);
   ObjectSetText("DM3_Label", "DM3", 8, "Arial", Daily_Mid_Level);
  }
 else
  {
   ObjectMove("DM3_Label", 0, Time[15], DM3);
  }  
//-------------------------------------
   
  if(ObjectFind("DM4_Line") != 0)
   { 
    ObjectCreate("DM4_Line", OBJ_HLINE,0, iTimeGMT(),DM4);
    ObjectSet("DM4_Line", OBJPROP_COLOR, Daily_Mid_Level);
    ObjectSet("DM4_Line", OBJPROP_STYLE, STYLE_DASH);
   }
  else
   {
   ObjectMove("DM4_Line", 0, Time[15], DM4);
   }

 if(ObjectFind("DM4_Label") != 0)
  {
   ObjectCreate("DM4_Label", OBJ_TEXT, 0, Time[15], DM4);
   ObjectSetText("DM4_Label", "DM4", 8, "Arial", Daily_Mid_Level);
  }
 else
  {
   ObjectMove("DM4_Label", 0, Time[15], DM4);
  }   
//--------------------------------------
   
  if(ObjectFind("DM5_Line") != 0)
   { 
    ObjectCreate("DM5_Line", OBJ_HLINE,0, iTimeGMT(),DM5);
    ObjectSet("DM5_Line", OBJPROP_COLOR, Daily_Mid_Level);
    ObjectSet("DM5_Line", OBJPROP_STYLE, STYLE_DASH);
   }
  else
   {
   ObjectMove("DM5_Line", 0, Time[15], DM5);
   }

 if(ObjectFind("DM5_Label") != 0)
  {
   ObjectCreate("DM5_Label", OBJ_TEXT, 0, Time[15], DM5);
   ObjectSetText("DM5_Label", "DM5", 8, "Arial", Daily_Mid_Level);
  }
 else
  {
   ObjectMove("DM5_Label", 0, Time[15], DM5);
  }
//---------------------------------------
   
  if(ObjectFind("DM6_Line") != 0)
   { 
    ObjectCreate("DM6_Line", OBJ_HLINE,0, iTimeGMT(),DM6);
    ObjectSet("DM6_Line", OBJPROP_COLOR, Daily_Mid_Level);
    ObjectSet("DM6_Line", OBJPROP_STYLE, STYLE_DASH);
   }
  else
   {
   ObjectMove("DM6_Line", 0, Time[15], DM6);
   }

 if(ObjectFind("DM6_Label") != 0)
  {
   ObjectCreate("DM6_Label", OBJ_TEXT, 0, Time[15], DM6);
   ObjectSetText("DM6_Label", "DM6", 8, "Arial", Daily_Mid_Level);
  }
 else
  {
   ObjectMove("DM6_Label", 0, Time[15], DM6);
  } 
 
 }
}
//---------------------------------------------------------
//---------------------------------------------------------
//---------------------------------------------------------
//
//

RefreshRates();

if (Weekly==true)
 {
 TimeToStr(iTimeGMT());
 if(ObjectFind("WeekPivotLine") != 0)
  { 
   ObjectCreate("WeekPivotLine", OBJ_HLINE,0, iTimeGMT(),WeekPivot);
   ObjectSet("WeekPivotLine", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("WeekPivotLine", OBJPROP_WIDTH, 1);
   ObjectSet("WeekPivotLine", OBJPROP_COLOR, Weekly_Pivot);
  }
 else
  {
   ObjectMove("WeekPivotLine", 0, Time[30], WeekPivot);
  }
  
 if(ObjectFind("WeekPivotLabel") != 0)
  {
   ObjectCreate("WeekPivotLabel", OBJ_TEXT, 0, Time[30], WeekPivot);
   ObjectSetText("WeekPivotLabel", "WeeklyPivot", 8, "Arial", Weekly_Pivot);
  }
 else
  {
   ObjectMove("WeekPivotLabel", 0, Time[30], WeekPivot);
  }

//--------------------------------------------------------

if (Weekly_SR_Levels==true)
 {
  TimeToStr(iTimeGMT());
  if(ObjectFind("WR1_Line") != 0)
   {
    ObjectCreate("WR1_Line", OBJ_HLINE,0, iTimeGMT(),WR1);
    ObjectSet("WR1_Line", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet("WR1_Line", OBJPROP_WIDTH, 1);
    ObjectSet("WR1_Line", OBJPROP_COLOR, Weekly_R_Levels);
   }
  else
   {
    ObjectMove("WR1_Line", 0, Time[30], WR1);
   }  
  
 if(ObjectFind("WR1_Label") != 0)
  {
   ObjectCreate("WR1_Label", OBJ_TEXT, 0, Time[30], WR1);
   ObjectSetText("WR1_Label", " Weekly R1", 8, "Arial", Weekly_R_Levels);
  }
 else
  {
   ObjectMove("WR1_Label", 0, Time[30], WR1);
  }

//--------------------------------------------------------

 if(ObjectFind("WR2_Line") != 0)
   {
    ObjectCreate("WR2_Line", OBJ_HLINE,0, iTimeGMT(),WR2);
    ObjectSet("WR2_Line", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet("WR2_Line", OBJPROP_WIDTH, 1);
    ObjectSet("WR2_Line", OBJPROP_COLOR, Weekly_R_Levels);
   }
  else
   {
    ObjectMove("WR2_Line", 0, Time[30], WR2);
   }
   
 if(ObjectFind("WR2_Label") != 0)
  {
   ObjectCreate("WR2_Label", OBJ_TEXT, 0, Time[30], WR2);
   ObjectSetText("WR2_Label", " Weekly R2", 8, "Arial", Weekly_R_Levels);
  }
 else
  {
   ObjectMove("WR2_Label", 0, Time[30], WR2);
  }

//---------------------------------------------------------

 if(ObjectFind("WR3_Line") != 0)
   {
    ObjectCreate("WR3_Line", OBJ_HLINE,0, iTimeGMT(),WR3);
    ObjectSet("WR3_Line", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet("WR3_Line", OBJPROP_WIDTH, 1);
    ObjectSet("WR3_Line", OBJPROP_COLOR, Weekly_R_Levels);
   }
  else
   {
   ObjectMove("WR3_Line", 0, Time[30], WR3);
   }
   
 if(ObjectFind("WR3_Label") != 0)
  {
   ObjectCreate("WR3_Label", OBJ_TEXT, 0, Time[30], WR3);
   ObjectSetText("WR3_Label", " Weekly R3", 8, "Arial", Weekly_R_Levels);
  }
 else
  {
   ObjectMove("WR3_Label", 0, Time[30], WR3);
  }

//---------------------------------------------------------

 if(ObjectFind("WS1_Line") != 0)
   {
    ObjectCreate("WS1_Line", OBJ_HLINE,0, iTimeGMT(),WS1);
    ObjectSet("WS1_Line", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet("WS1_Line", OBJPROP_WIDTH, 1);
    ObjectSet("WS1_Line", OBJPROP_COLOR, Weekly_S_Levels);
   }
  else
   {
   ObjectMove("WS1_Line", 0, Time[30], WS1);
   }
   
 if(ObjectFind("WS1_Label") != 0)
  {
   ObjectCreate("WS1_Label", OBJ_TEXT, 0, Time[30], WS1);
   ObjectSetText("WS1_Label", "Weekly S1", 8, "Arial", Weekly_S_Levels);
  }
 else
  {
   ObjectMove("WS1_Label", 0, Time[30], WS1);
  }

//---------------------------------------------------------

 if(ObjectFind("WS2_Line") != 0)
   {
    ObjectCreate("WS2_Line", OBJ_HLINE,0, iTimeGMT(),WS2);
    ObjectSet("WS2_Line", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet("WS2_Line", OBJPROP_WIDTH, 1);
    ObjectSet("WS2_Line", OBJPROP_COLOR, Weekly_S_Levels);
   }
  else
   {
   ObjectMove("WS2_Line", 0, Time[30], WS2);
   }
   
 if(ObjectFind("WS2_Label") != 0)
  {
   ObjectCreate("WS2_Label", OBJ_TEXT, 0, Time[30], WS2);
   ObjectSetText("WS2_Label", "Weekly S2", 8, "Arial", Weekly_S_Levels);
  }
 else
  {
   ObjectMove("WS2_Label", 0, Time[30], WS2);
  }

//---------------------------------------------------------

 if(ObjectFind("WS3_Line") != 0)
   {
    ObjectCreate("WS3_Line", OBJ_HLINE,0, iTimeGMT(),WS3);
    ObjectSet("WS3_Line", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet("WS3_Line", OBJPROP_WIDTH, 1);
    ObjectSet("WS3_Line", OBJPROP_COLOR, Weekly_S_Levels);
   }
  else
   {
    ObjectMove("WS3_Line", 0, Time[30], WS3);
   }
      
 if(ObjectFind("WS3_Label") != 0)
  {
   ObjectCreate("WS3_Label", OBJ_TEXT, 0, Time[30], WS3);
   ObjectSetText("WS3_Label", "Weekly S3", 8, "Arial", Weekly_S_Levels);
  }
 else
  {
   ObjectMove("WS3_Label", 0, Time[30], WS3);
  }
 }
}

//-----------------------------------------------
//
//
//
//

RefreshRates();

if (Weekly_Mid_Levels==True)
 {
  TimeToStr(iTimeGMT());
  if(ObjectFind("WM1_Line") != 0)
   { 
    ObjectCreate("WM1_Line", OBJ_HLINE,0, iTimeGMT(),WM1);
    ObjectSet("WM1_Line", OBJPROP_COLOR, Weekly_Mid_Level);
    ObjectSet("WM1_Line", OBJPROP_STYLE, STYLE_DASH);
   }
  else
   {
   ObjectMove("WM1_Line", 0, Time[25], WM1);
   }

 if(ObjectFind("WM1_Label") != 0)
  {
   ObjectCreate("WM1_Label", OBJ_TEXT, 0, Time[25], WM1);
   ObjectSetText("WM1_Label", "WM1", 8, "Arial", Weekly_Mid_Level);
  }
 else
  {
   ObjectMove("WM1_Label", 0, Time[25], WM1);
  }
//-------------------------------------
   
  if(ObjectFind("WM2_Line") != 0)
   { 
    ObjectCreate("WM2_Line", OBJ_HLINE,0, iTimeGMT(),WM2);
    ObjectSet("WM2_Line", OBJPROP_COLOR, Weekly_Mid_Level);
    ObjectSet("WM2_Line", OBJPROP_STYLE, STYLE_DASH);
   }
  else
   {
   ObjectMove("WM2_Line", 0, Time[25], WM2);
   }

 if(ObjectFind("WM2_Label") != 0)
  {
   ObjectCreate("WM2_Label", OBJ_TEXT, 0, Time[25], WM2);
   ObjectSetText("WM2_Label", "WM2", 8, "Arial", Weekly_Mid_Level);
  }
 else
  {
   ObjectMove("WM2_Label", 0, Time[25], WM2);
  }
//------------------------------------
   
  if(ObjectFind("WM3_Line") != 0)
   { 
    ObjectCreate("WM3_Line", OBJ_HLINE,0, iTimeGMT(),WM3);
    ObjectSet("WM3_Line", OBJPROP_COLOR, Weekly_Mid_Level);
    ObjectSet("WM3_Line", OBJPROP_STYLE, STYLE_DASH);
   }
  else
   {
   ObjectMove("WM3_Line", 0, Time[25], WM3);
   }

 if(ObjectFind("WM3_Label") != 0)
  {
   ObjectCreate("WM3_Label", OBJ_TEXT, 0, Time[25], WM3);
   ObjectSetText("WM3_Label", "WM3", 8, "Arial", Weekly_Mid_Level);
  }
 else
  {
   ObjectMove("WM3_Label", 0, Time[25], WM3);
  }  
//-------------------------------------
   
  if(ObjectFind("WM4_Line") != 0)
   { 
    ObjectCreate("WM4_Line", OBJ_HLINE,0, iTimeGMT(),WM4);
    ObjectSet("WM4_Line", OBJPROP_COLOR, Weekly_Mid_Level);
    ObjectSet("WM4_Line", OBJPROP_STYLE, STYLE_DASH);
   }
  else
   {
   ObjectMove("WM4_Line", 0, Time[25], WM4);
   }

 if(ObjectFind("WM4_Label") != 0)
  {
   ObjectCreate("WM4_Label", OBJ_TEXT, 0, Time[25], WM4);
   ObjectSetText("WM4_Label", "WM4", 8, "Arial", Weekly_Mid_Level);
  }
 else
  {
   ObjectMove("WM4_Label", 0, Time[25], WM4);
  }   
//--------------------------------------
   
  if(ObjectFind("WM5_Line") != 0)
   { 
    ObjectCreate("WM5_Line", OBJ_HLINE,0, iTimeGMT(),WM5);
    ObjectSet("WM5_Line", OBJPROP_COLOR, Weekly_Mid_Level);
    ObjectSet("WM5_Line", OBJPROP_STYLE, STYLE_DASH);
   }
  else
   {
   ObjectMove("WM5_Line", 0, Time[25], WM5);
   }

 if(ObjectFind("WM5_Label") != 0)
  {
   ObjectCreate("WM5_Label", OBJ_TEXT, 0, Time[25], WM5);
   ObjectSetText("WM5_Label", "WM5", 8, "Arial", Weekly_Mid_Level);
  }
 else
  {
   ObjectMove("WM5_Label", 0, Time[25], WM5);
  }
//---------------------------------------
   
  if(ObjectFind("WM6_Line") != 0)
   { 
    ObjectCreate("WM6_Line", OBJ_HLINE,0, iTimeGMT(),WM6);
    ObjectSet("WM6_Line", OBJPROP_COLOR, Weekly_Mid_Level);
    ObjectSet("WM6_Line", OBJPROP_STYLE, STYLE_DASH);
   }
  else
   {
   ObjectMove("WM6_Line", 0, Time[25], WM6);
   }

 if(ObjectFind("WM6_Label") != 0)
  {
   ObjectCreate("WM6_Label", OBJ_TEXT, 0, Time[25], WM6);
   ObjectSetText("WM6_Label", "WM6", 8, "Arial", Weekly_Mid_Level);
  }
 else
  {
   ObjectMove("WM6_Label", 0, Time[25], WM6);
  } 
 
 }


//---------------------------------------------------------
//---------------------------------------------------------
//---------------------------------------------------------
//
//

RefreshRates();

if (Monthly==true)
 {
 TimeToStr(iTimeGMT());
 if(ObjectFind("MonthPivotLine") != 0)
  {
   ObjectCreate("MonthPivotLine", OBJ_HLINE,0, iTimeGMT(),MonthPivot);
   ObjectSet("MonthPivotLine", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("MonthPivotLine", OBJPROP_WIDTH, 1);
   ObjectSet("MonthPivotLine", OBJPROP_COLOR, Monthly_Pivot);
  }
 else
  {
   ObjectMove("MonthPivotLine", 0, Time[40], MonthPivot);
  }
  
 if(ObjectFind("MonthPivotLabel") != 0)
  {
   ObjectCreate("MonthPivotLabel", OBJ_TEXT, 0, Time[40], MonthPivot);
   ObjectSetText("MonthPivotLabel", "MonthlyPivot", 8, "Arial", Monthly_Pivot);
  }
 else
  {
   ObjectMove("MonthPivotLabel", 0, Time[40], MonthPivot);
  }

//--------------------------------------------------------

if (Monthly_SR_Levels==true)
 {
 TimeToStr(iTimeGMT());
 if(ObjectFind("MR1_Line") != 0)
   { 
    ObjectCreate("MR1_Line", OBJ_HLINE,0, iTimeGMT(),MR1);
    ObjectSet("MR1_Line", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet("MR1_Line", OBJPROP_WIDTH, 1);
    ObjectSet("MR1_Line", OBJPROP_COLOR, Monthly_R_Levels);
   }
  else
   {
    ObjectMove("MR1_Line", 0, Time[40], MR1);
   }
  
 if(ObjectFind("MR1_Label") != 0)
  {
   ObjectCreate("MR1_Label", OBJ_TEXT, 0, Time[40], MR1);
   ObjectSetText("MR1_Label", " Monthly R1", 8, "Arial", Monthly_R_Levels);
  }
 else
  {
   ObjectMove("MR1_Label", 0, Time[40], MR1);
  }

//--------------------------------------------------------

 if(ObjectFind("MR2_Line") != 0)
   {
    ObjectCreate("MR2_Line", OBJ_HLINE,0, iTimeGMT(),MR2);
    ObjectSet("MR2_Line", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet("MR2_Line", OBJPROP_WIDTH, 1);
    ObjectSet("MR2_Line", OBJPROP_COLOR, Monthly_R_Levels);
   }
  else
   {
    ObjectMove("MR2_Line", 0, Time[40], MR2);
   }
   
 if(ObjectFind("MR2_Label") != 0)
  {
   ObjectCreate("MR2_Label", OBJ_TEXT, 0, Time[40], MR2);
   ObjectSetText("MR2_Label", " Monthly R2", 8, "Arial", Monthly_R_Levels);
  }
 else
  {
   ObjectMove("MR2_Label", 0, Time[40], MR2);
  }

//---------------------------------------------------------

 if(ObjectFind("MR3_Line") != 0)
   {
    ObjectCreate("MR3_Line", OBJ_HLINE,0, iTimeGMT(),MR3);
    ObjectSet("MR3_Line", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet("MR3_Line", OBJPROP_WIDTH, 1);
    ObjectSet("MR3_Line", OBJPROP_COLOR, Monthly_R_Levels);
   }
  else
   {
    ObjectMove("MR3_Line", 0, Time[40], MR3);
   }   
   
 if(ObjectFind("MR3_Label") != 0)
  {
   ObjectCreate("MR3_Label", OBJ_TEXT, 0, Time[40], MR3);
   ObjectSetText("MR3_Label", " Monthly R3", 8, "Arial", Monthly_R_Levels);
  }
 else
  {
   ObjectMove("MR3_Label", 0, Time[40], MR3);
  }

//---------------------------------------------------------

 if(ObjectFind("MS1_Line") != 0)
   {
    ObjectCreate("MS1_Line", OBJ_HLINE,0, iTimeGMT(),MS1);
    ObjectSet("MS1_Line", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet("MS1_Line", OBJPROP_WIDTH, 1);
    ObjectSet("MS1_Line", OBJPROP_COLOR, Monthly_S_Levels);
   }
  else
   {
    ObjectMove("MS1_Line", 0, Time[40], MS1);
   }

 if(ObjectFind("MS1_Label") != 0)
  {
   ObjectCreate("MS1_Label", OBJ_TEXT, 0, Time[40], MS1);
   ObjectSetText("MS1_Label", "Monthly S1", 8, "Arial", Monthly_S_Levels);
  }
 else
  {
   ObjectMove("MS1_Label", 0, Time[40], MS1);
  }

//---------------------------------------------------------

 if(ObjectFind("MS2_Line") != 0)
   {
    ObjectCreate("MS2_Line", OBJ_HLINE,0, iTimeGMT(),MS2);
    ObjectSet("MS2_Line", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet("MS2_Line", OBJPROP_WIDTH, 1);
    ObjectSet("MS2_Line", OBJPROP_COLOR, Monthly_S_Levels);
   }
  else
   {
    ObjectMove("MS2_Line", 0, Time[40], MS2);
   }

 if(ObjectFind("MS2_Label") != 0)
  {
   ObjectCreate("MS2_Label", OBJ_TEXT, 0, Time[40], MS2);
   ObjectSetText("MS2_Label", "Monthly S2", 8, "Arial", Monthly_S_Levels);
  }
 else
  {
   ObjectMove("MS2_Label", 0, Time[40], MS2);
  }

//---------------------------------------------------------

 if(ObjectFind("MS3_Line") != 0)
   {
    ObjectCreate("MS3_Line", OBJ_HLINE,0, iTimeGMT(),MS3);
    ObjectSet("MS3_Line", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet("MS3_Line", OBJPROP_WIDTH, 1);
    ObjectSet("MS3_Line", OBJPROP_COLOR, Monthly_S_Levels);
   }
  else
   {
    ObjectMove("MS3_Line", 0, Time[40], MS3);
   }   
   
 if(ObjectFind("MS3_Label") != 0)
  {
   ObjectCreate("MS3_Label", OBJ_TEXT, 0, Time[40], MS3);
   ObjectSetText("MS3_Label", "Monthly S3", 8, "Arial", Monthly_S_Levels);
  }
 else
  {
   ObjectMove("MS3_Label", 0, Time[40], MS3);
  }
 }
}
//---------------------------------------------------------

if (Monthly_Mid_Levels==True)
 {
  TimeToStr(iTimeGMT());
  if(ObjectFind("MM1_Line") != 0)
   { 
    ObjectCreate("MM1_Line", OBJ_HLINE,0, iTimeGMT(),MM1);
    ObjectSet("MM1_Line", OBJPROP_COLOR, Monthly_Mid_Level);
    ObjectSet("MM1_Line", OBJPROP_STYLE, STYLE_DASH);
   }
  else
   {
   ObjectMove("MM1_Line", 0, Time[35], MM1);
   }

 if(ObjectFind("MM1_Label") != 0)
  {
   ObjectCreate("MM1_Label", OBJ_TEXT, 0, Time[35], MM1);
   ObjectSetText("MM1_Label", "MM1", 8, "Arial", Monthly_Mid_Level);
  }
 else
  {
   ObjectMove("MM1_Label", 0, Time[35], MM1);
  }
//-------------------------------------
   
  if(ObjectFind("MM2_Line") != 0)
   { 
    ObjectCreate("MM2_Line", OBJ_HLINE,0, iTimeGMT(),MM2);
    ObjectSet("MM2_Line", OBJPROP_COLOR, Monthly_Mid_Level);
    ObjectSet("MM2_Line", OBJPROP_STYLE, STYLE_DASH);
   }
  else
   {
   ObjectMove("MM2_Line", 0, Time[35], MM2);
   }

 if(ObjectFind("MM2_Label") != 0)
  {
   ObjectCreate("MM2_Label", OBJ_TEXT, 0, Time[35], MM2);
   ObjectSetText("MM2_Label", "MM2", 8, "Arial", Monthly_Mid_Level);
  }
 else
  {
   ObjectMove("MM2_Label", 0, Time[35], MM2);
  }
//------------------------------------
   
  if(ObjectFind("MM3_Line") != 0)
   { 
    ObjectCreate("MM3_Line", OBJ_HLINE,0, iTimeGMT(),MM3);
    ObjectSet("MM3_Line", OBJPROP_COLOR, Monthly_Mid_Level);
    ObjectSet("MM3_Line", OBJPROP_STYLE, STYLE_DASH);
   }
  else
   {
   ObjectMove("MM3_Line", 0, Time[35], MM3);
   }

 if(ObjectFind("MM3_Label") != 0)
  {
   ObjectCreate("MM3_Label", OBJ_TEXT, 0, Time[35], MM3);
   ObjectSetText("MM3_Label", "MM3", 8, "Arial", Monthly_Mid_Level);
  }
 else
  {
   ObjectMove("MM3_Label", 0, Time[35], MM3);
  }  
//-------------------------------------
   
  if(ObjectFind("MM4_Line") != 0)
   { 
    ObjectCreate("MM4_Line", OBJ_HLINE,0, iTimeGMT(),MM4);
    ObjectSet("MM4_Line", OBJPROP_COLOR, Monthly_Mid_Level);
    ObjectSet("MM4_Line", OBJPROP_STYLE, STYLE_DASH);
   }
  else
   {
   ObjectMove("MM4_Line", 0, Time[35], MM4);
   }

 if(ObjectFind("MM4_Label") != 0)
  {
   ObjectCreate("MM4_Label", OBJ_TEXT, 0, Time[35], MM4);
   ObjectSetText("MM4_Label", "MM4", 8, "Arial", Monthly_Mid_Level);
  }
 else
  {
   ObjectMove("MM4_Label", 0, Time[35], MM4);
  }   
//--------------------------------------
   
  if(ObjectFind("MM5_Line") != 0)
   { 
    ObjectCreate("MM5_Line", OBJ_HLINE,0, iTimeGMT(),MM5);
    ObjectSet("MM5_Line", OBJPROP_COLOR, Monthly_Mid_Level);
    ObjectSet("MM5_Line", OBJPROP_STYLE, STYLE_DASH);
   }
  else
   {
   ObjectMove("MM5_Line", 0, Time[25], MM5);
   }

 if(ObjectFind("MM5_Label") != 0)
  {
   ObjectCreate("MM5_Label", OBJ_TEXT, 0, Time[35], MM5);
   ObjectSetText("MM5_Label", "MM5", 8, "Arial", Monthly_Mid_Level);
  }
 else
  {
   ObjectMove("MM5_Label", 0, Time[35], MM5);
  }
//---------------------------------------
   
  if(ObjectFind("MM6_Line") != 0)
   { 
    ObjectCreate("MM6_Line", OBJ_HLINE,0, iTimeGMT(),MM6);
    ObjectSet("MM6_Line", OBJPROP_COLOR, Monthly_Mid_Level);
    ObjectSet("MM6_Line", OBJPROP_STYLE, STYLE_DASH);
   }
  else
   {
   ObjectMove("MM6_Line", 0, Time[35], MM6);
   }

 if(ObjectFind("MM6_Label") != 0)
  {
   ObjectCreate("MM6_Label", OBJ_TEXT, 0, Time[35], MM6);
   ObjectSetText("MM6_Label", "MM6", 8, "Arial", Monthly_Mid_Level);
  }
 else
  {
   ObjectMove("MM6_Label", 0, Time[35], MM6);
  } 
 
 }

if (CommentsOn) ShowComments();
return(0);
}

//
//
//
//
//

double TimeZoneLocal()
{
	if(GetTimeZoneInformation(TZInfoArray)==TIME_ZONE_ID_DAYLIGHT)
		  return((TZInfoArray[0]+TZInfoArray[42])/(-60.0));
	else return(TZInfoArray[0]/(-60.0)); //TIME_ZONE_ID_STANDARD or TIME_ZONE_ID_UNKNOWN
}

// 
//
//
//
//

double TimeZoneServer()
{
	int ServerToLocalDiffMinutes = (TimeCurrent()-TimeLocal())/60;
	int nHalfHourDiff            = MathRound(ServerToLocalDiffMinutes/30.0);
	
	//
	//
	//
	//
	//
	
	ServerToLocalDiffMinutes = nHalfHourDiff*30;
	
return(TimeZoneLocal() + ServerToLocalDiffMinutes/60.0);
}

// 
//
//
//
//

datetime iTimeGMT()
{

	    datetime dtGmtFromLocal = TimeLocal() - TimeZoneLocal()*3600;
	    datetime dtGmtFromServer = TimeCurrent() - TimeZoneServer()*3600;

       if (dtGmtFromLocal > dtGmtFromServer + 300)
	    {
		   return(dtGmtFromLocal);
	    }
	    else
	    {
		  return(dtGmtFromServer);
	}	
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void ShowComments()
{ 
   string SunText="";
   string symbol   = Symbol(); if (StringSubstr(symbol,0,2)=="_t") symbol = StringSubstr(symbol,2);
  	double modifier = 1;
  	int    digits   = MarketInfo(symbol,MODE_DIGITS);
   if (digits==3 || digits==5) modifier = 10.0;
   
   if (Use_Sunday_Data == false)          { SunText = "Sunday Bar ignored"; }
   if (DayOfWeek() == 1 && DaysBack == 1) { SunText = "Sunday Bar ignored, not using Sunday Data for Daily Pivots. Today is Monday"; }
  	
   //
   //
   //
   //
   //
   
   int R    =        (iHigh(symbol,PERIOD_D1,0) - iLow(symbol,PERIOD_D1,0))/(MarketInfo(symbol,MODE_POINT)*modifier);
   
   int R0   =        (iHigh(symbol,PERIOD_D1,1) - iLow(symbol,PERIOD_D1,1))/(MarketInfo(symbol,MODE_POINT)*modifier);
   
   int R5  = 0;
   for(int i=1;i<=5;i++)
       R5  = R5  +  (iHigh(symbol,PERIOD_D1,i) - iLow(symbol,PERIOD_D1,i))/(MarketInfo(symbol,MODE_POINT)*modifier);
   
   int R10 = 0;
   for(i=1;i<=10;i++)
       R10 = R10 +  (iHigh(symbol,PERIOD_D1,i) - iLow(symbol,PERIOD_D1,i))/(MarketInfo(symbol,MODE_POINT)*modifier);
   
   int R20 = 0;
   for(i=1;i<=20;i++)
       R20 = R20 +  (iHigh(symbol,PERIOD_D1,i) - iLow(symbol,PERIOD_D1,i))/(MarketInfo(symbol,MODE_POINT)*modifier);

       R5   =  R5 / ShortRange;
       R10  =  R10/ InterRange;
       R20  =  R20/ LongRange;
   int RAvg = (R0 + R5 + R10 + R20)/4; 
      
   double lo   =  iLow(symbol, PERIOD_D1,0);
   double hi   =  iHigh(symbol,PERIOD_D1,0);
   int    RmUp =  RAvg - (Bid - lo)/(MarketInfo(symbol,MODE_POINT)*modifier);
   int    RmDn =  RAvg - (hi - Bid)/(MarketInfo(symbol,MODE_POINT)*modifier);
   
   //
   //
   //
   //
   //
   
   string strLocal  = TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES|TIME_SECONDS);
	string strServer = TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS);
	string strGMT    = TimeToStr(iTimeGMT(),TIME_DATE|TIME_MINUTES|TIME_SECONDS);
	
	string strLocalTimeZone;
	if (TimeZoneLocal() > 0)   strLocalTimeZone  = StringConcatenate("Local timezone: GMT plus ",TimeZoneLocal()," hours");
	if (TimeZoneLocal() == 0)  strLocalTimeZone  = "Local timezone: GMT";
	if (TimeZoneLocal() < 0)   strLocalTimeZone  = StringConcatenate("Local timezone: GMT minus ",-TimeZoneLocal()," hours");
	
	string strServerTimeZone;
	if (TimeZoneServer() > 0)  strServerTimeZone = StringConcatenate("Server timezone: GMT plus ",TimeZoneServer()," hours");
	if (TimeZoneServer() == 0) strServerTimeZone = "Server timezone: GMT";
  	if (TimeZoneServer() < 0)  strServerTimeZone = StringConcatenate("Server timezone: GMT minus ",-TimeZoneServer()," hours");
  	
  	//
  	//
  	//
  	//
  	//
  
   if(MarketInfo(Symbol(),MODE_SWAPLONG) > 0)                                  string    swap="longs,";
                                                                               else      swap="shorts.";
   if(MarketInfo(Symbol(),MODE_SWAPLONG) < 0 && MarketInfo(Symbol(),MODE_SWAPSHORT) < 0) swap="your broker. ";
   
   //
   //
   //
   //
   //  
   
   string sComment   = "";
   string sp         = "---------------------------------------------------\n";
   string NL         = "\n";
   
   sComment = sComment + "Auto Fibonacci" + NL; 
   sComment = sComment + sp;
   sComment = sComment + SunText + NL;
   sComment = sComment + sp;
   sComment = sComment + "Range Analysis" + NL;
   sComment = sComment + "Avg Daily Range = " + RAvg + NL; 
   sComment = sComment + "Prev Day Range = " + R0   + NL;
   sComment = sComment + "Short Term Range = " + R5   + NL;
   sComment = sComment + "Intermediate Range = " + R10  + NL;
   sComment = sComment + "Long Term Range = " + R20  + NL;
   sComment = sComment + "Todays Range = " + R + NL;
   sComment = sComment + "Room Dn = " + RmDn + NL;
   sComment = sComment + "Room Up = " + RmUp + NL;
   sComment = sComment + sp;
   sComment = sComment + "Market Analysis" + NL;
   sComment = sComment + "Swap favors " + swap + NL; 
   sComment = sComment + "Swap Long      = " + DoubleToStr(MarketInfo(symbol,MODE_SWAPLONG),2) + NL; 
   sComment = sComment + "Swap Short     = " + DoubleToStr(MarketInfo(symbol,MODE_SWAPSHORT),2) + NL; 
   sComment = sComment + "Current Spread = " + DoubleToStr(MarketInfo(symbol,MODE_SPREAD)/ modifier,2) + NL;  
   sComment = sComment + sp;
   sComment = sComment + "Time Information" + NL;
   sComment = sComment + strLocalTimeZone  + NL;
   sComment = sComment + strServerTimeZone + NL;
   sComment = sComment + "Local time from PC clock = " +strLocal+ NL;
   sComment = sComment + "Broker server time         =  " +strServer+ NL;
   sComment = sComment + "GMT time                    =  " +strGMT+ NL;
   sComment = sComment + sp + NL;
   sComment = sComment + "Have a great trading day" + NL;
   sComment = sComment + sp; 
   
   Comment(sComment);  
}