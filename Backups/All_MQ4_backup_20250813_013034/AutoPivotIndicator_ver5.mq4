//+------------------------------------------------------------------+
//|   AutoPivotIndicator.mq4          ver 5              by Habeeb   |
//|                                                                  |
//|          This version solves the Sunday Bar problem.             |
//| Ver4 calculated daily pivots incorrectly when Use_Sunday_Data    |
//|        was set to "False".  Fixed in this version.               |
//|            Mid_Pivot Levels added in ver 4.77.                   |
//|         User customizable colours added in ver 5.                |
//+------------------------------------------------------------------+

#property indicator_chart_window

   extern bool Use_Sunday_Data   = True;
   extern bool Daily             = True;
   extern bool Daily_SR_Levels   = True;
   extern bool Daily_Mid_Levels  = False;
   extern bool Weekly            = True;
   extern bool Weekly_SR_Levels  = False;
   extern bool Weekly_Mid_Levels = False;
   extern bool Monthly           = True;
   extern bool Monthly_SR_Levels = False;
   extern bool Monthly_Mid_Levels= False;
   
   extern color Daily_Pivot      = Blue;
   extern color Daily_S_Levels   = LimeGreen;
   extern color Daily_R_Levels   = Red;
   extern color Daily_Mid_Level  = LightSalmon;
   
   extern color Weekly_Pivot      = Magenta;
   extern color Weekly_S_Levels   = SteelBlue;
   extern color Weekly_R_Levels   = Peru;
   extern color Weekly_Mid_Level  = LightPink;
   
   extern color Monthly_Pivot      = Gray;
   extern color Monthly_S_Levels   = Orange;
   extern color Monthly_R_Levels   = Blue;
   extern color Monthly_Mid_Level  = LightSalmon;   

   double YesterdayHigh;
   double YesterdayLow;
   double YesterdayClose;
   double Day_Price[][6];
   double Pivot,S1,S2,S3,R1,R2,R3;
   double DM1,DM2,DM3,DM4,DM5,DM6;  //daily mid-pivots
      
   double WeekHigh;
   double WeekLow;
   double WeekClose;
   double Weekly_Price[][6];
   double WeekPivot,WS1,WS2,WS3,WR1,WR2,WR3;
   double WM1,WM2,WM3,WM4,WM5,WM6;  //weekly mid-pivots
   
   double MonthHigh;
   double MonthLow;
   double MonthClose;
   double Month_Price[][6];
   double MonthPivot,MS1,MS2,MS3,MR1,MR2,MR3;
   double MM1,MM2,MM3,MM4,MM5,MM6;  //monthly mid-pivots
   
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

return(0);
}
//--------------------------------------------------------- 

int start()
{
ArrayCopyRates(Day_Price,(Symbol()), 1440);

   //Comment("Kostas");
  
   YesterdayHigh  = Day_Price[1][3];
   YesterdayLow   = Day_Price[1][2];
   YesterdayClose = Day_Price[1][4];
   
   Pivot = ((YesterdayHigh + YesterdayLow + YesterdayClose)/3);

   R1 = (2*Pivot)-YesterdayLow;
   S1 = (2*Pivot)-YesterdayHigh;

   R2 = Pivot+(R1-S1);
   S2 = Pivot-(R1-S1);
   
   R3 = (YesterdayHigh + (2*(Pivot-YesterdayLow)));
   S3 = (YesterdayLow - (2*(YesterdayHigh-Pivot)));  
   
   DM1 = S3 + ((S2-S3) / 2);
   DM2 = S2 + ((S1-S2) / 2);
   DM3 = S1 + ((Pivot-S1) / 2);
   DM4 = Pivot + ((R1-Pivot) / 2);
   DM5 = R1 + ((R2-R1) / 2);
   DM6 = R2 + ((R3-R2) / 2);
  
  
if (Use_Sunday_Data == false)
 {   
  Comment("Sunday Bar ignored","");
    while (DayOfWeek() == 1)
      {
       Comment("Not using Sunday Data for Daily Pivots. ",
       " Today is Monday");
              
       YesterdayHigh  = Day_Price[2][3];
       YesterdayLow   = Day_Price[2][2];
       YesterdayClose = Day_Price[2][4];
   
       Pivot = ((YesterdayHigh + YesterdayLow + YesterdayClose)/3);

       R1 = (2*Pivot)-YesterdayLow;
       S1 = (2*Pivot)-YesterdayHigh;

       R2 = Pivot+(R1-S1);
       S2 = Pivot-(R1-S1);
   
       R3 = (YesterdayHigh + (2*(Pivot-YesterdayLow)));
       S3 = (YesterdayLow - (2*(YesterdayHigh-Pivot)));
       
       DM1 = S3 + ((S2-S3) / 2);
       DM2 = S2 + ((S1-S2) / 2);
       DM3 = S1 + ((Pivot-S1) / 2);
       DM4 = Pivot + ((R1-Pivot) / 2);
       DM5 = R1 + ((R2-R1) / 2);
       DM6 = R2 + ((R3-R2) / 2);    
       break;
      }
 }
  
//--------------------------------------------------------
//--------------------------------------------------------

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
      
      WM1 = WS3 + ((WS2-WS3) / 2);
      WM2 = WS2 + ((WS1-WS2) / 2);
      WM3 = WS1 + ((WeekPivot-WS1) / 2);
      WM4 = WeekPivot + ((WR1-WeekPivot) / 2);
      WM5 = WR1 + ((WR2-WR1) / 2);
      WM6 = WR2 + ((WR3-WR2) / 2);

//--------------------------------------------------------
//--------------------------------------------------------

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
      
      MM1 = MS3 + ((MS2-MS3) / 2);
      MM2 = MS2 + ((MS1-MS2) / 2);
      MM3 = MS1 + ((MonthPivot-MS1) / 2);
      MM4 = MonthPivot + ((MR1-MonthPivot) / 2);
      MM5 = MR1 + ((MR2-MR1) / 2);
      MM6 = MR2 + ((MR3-MR2) / 2);

//--------------------------------------------------------

if (Daily==true)
 {
  TimeToStr(CurTime());
  
 if(ObjectFind("PivotLine") != 0)
  {
   ObjectCreate("PivotLine", OBJ_HLINE,0, CurTime(),Pivot);
   ObjectSet("PivotLine", OBJPROP_COLOR, Daily_Pivot);
   ObjectSet("PivotLine", OBJPROP_STYLE, STYLE_DASH);
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
ObjectsRedraw();

//--------------------------------------------------------

if (Daily_SR_Levels==true)
 {
  if(ObjectFind("R1_Line") != 0)
   { 
    ObjectCreate("R1_Line", OBJ_HLINE,0, CurTime(),R1);
    ObjectSet("R1_Line", OBJPROP_COLOR, Daily_R_Levels);
    ObjectSet("R1_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
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
    ObjectCreate("R2_Line", OBJ_HLINE,0, CurTime(),R2);
    ObjectSet("R2_Line", OBJPROP_COLOR, Daily_R_Levels);
    ObjectSet("R2_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
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
    ObjectCreate("R3_Line", OBJ_HLINE,0, CurTime(),R3);
    ObjectSet("R3_Line", OBJPROP_COLOR, Daily_R_Levels);
    ObjectSet("R3_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
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
    ObjectCreate("S1_Line", OBJ_HLINE,0, CurTime(),S1);
    ObjectSet("S1_Line", OBJPROP_COLOR, Daily_S_Levels);
    ObjectSet("S1_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
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
    ObjectCreate("S2_Line", OBJ_HLINE,0, CurTime(),S2);
    ObjectSet("S2_Line", OBJPROP_COLOR, Daily_S_Levels);
    ObjectSet("S2_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
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
    ObjectCreate("S3_Line", OBJ_HLINE,0, CurTime(),S3);
    ObjectSet("S3_Line", OBJPROP_COLOR, Daily_S_Levels);
    ObjectSet("S3_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
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
ObjectsRedraw();
}

//-------------------------------------------------

if (Daily_Mid_Levels==True)
 {
  if(ObjectFind("DM1_Line") != 0)
   { 
    ObjectCreate("DM1_Line", OBJ_HLINE,0, CurTime(),DM1);
    ObjectSet("DM1_Line", OBJPROP_COLOR, Daily_Mid_Level);
    ObjectSet("DM1_Line", OBJPROP_STYLE, STYLE_DOT);
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
    ObjectCreate("DM2_Line", OBJ_HLINE,0, CurTime(),DM2);
    ObjectSet("DM2_Line", OBJPROP_COLOR, Daily_Mid_Level);
    ObjectSet("DM2_Line", OBJPROP_STYLE, STYLE_DOT);
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
    ObjectCreate("DM3_Line", OBJ_HLINE,0, CurTime(),DM3);
    ObjectSet("DM3_Line", OBJPROP_COLOR, Daily_Mid_Level);
    ObjectSet("DM3_Line", OBJPROP_STYLE, STYLE_DOT);
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
    ObjectCreate("DM4_Line", OBJ_HLINE,0, CurTime(),DM4);
    ObjectSet("DM4_Line", OBJPROP_COLOR, Daily_Mid_Level);
    ObjectSet("DM4_Line", OBJPROP_STYLE, STYLE_DOT);
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
    ObjectCreate("DM5_Line", OBJ_HLINE,0, CurTime(),DM5);
    ObjectSet("DM5_Line", OBJPROP_COLOR, Daily_Mid_Level);
    ObjectSet("DM5_Line", OBJPROP_STYLE, STYLE_DOT);
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
    ObjectCreate("DM6_Line", OBJ_HLINE,0, CurTime(),DM6);
    ObjectSet("DM6_Line", OBJPROP_COLOR, Daily_Mid_Level);
    ObjectSet("DM6_Line", OBJPROP_STYLE, STYLE_DOT);
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
 
  ObjectsRedraw();
 }

//---------------------------------------------------------
//---------------------------------------------------------
//---------------------------------------------------------

if (Weekly==true)
 {
 if(ObjectFind("WeekPivotLine") != 0)
  { 
   ObjectCreate("WeekPivotLine", OBJ_HLINE,0, CurTime(),WeekPivot);
   ObjectSet("WeekPivotLine", OBJPROP_COLOR, Weekly_Pivot);
   ObjectSet("WeekPivotLine", OBJPROP_STYLE, STYLE_DASH);
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
  if(ObjectFind("WR1_Line") != 0)
   {
    ObjectCreate("WR1_Line", OBJ_HLINE,0, CurTime(),WR1);
    ObjectSet("WR1_Line", OBJPROP_COLOR, Weekly_R_Levels);
    ObjectSet("WR1_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
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
    ObjectCreate("WR2_Line", OBJ_HLINE,0, CurTime(),WR2);
    ObjectSet("WR2_Line", OBJPROP_COLOR, Weekly_R_Levels);
    ObjectSet("WR2_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
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
    ObjectCreate("WR3_Line", OBJ_HLINE,0, CurTime(),WR3);
    ObjectSet("WR3_Line", OBJPROP_COLOR, Weekly_R_Levels);
    ObjectSet("WR3_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
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
    ObjectCreate("WS1_Line", OBJ_HLINE,0, CurTime(),WS1);
    ObjectSet("WS1_Line", OBJPROP_COLOR, Weekly_S_Levels);
    ObjectSet("WS1_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
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
    ObjectCreate("WS2_Line", OBJ_HLINE,0, CurTime(),WS2);
    ObjectSet("WS2_Line", OBJPROP_COLOR, Weekly_S_Levels);
    ObjectSet("WS2_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
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
    ObjectCreate("WS3_Line", OBJ_HLINE,0, CurTime(),WS3);
    ObjectSet("WS3_Line", OBJPROP_COLOR, Weekly_S_Levels);
    ObjectSet("WS3_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
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

if (Weekly_Mid_Levels==True)
 {
  if(ObjectFind("WM1_Line") != 0)
   { 
    ObjectCreate("WM1_Line", OBJ_HLINE,0, CurTime(),WM1);
    ObjectSet("WM1_Line", OBJPROP_COLOR, Weekly_Mid_Level);
    ObjectSet("WM1_Line", OBJPROP_STYLE, STYLE_DOT);
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
    ObjectCreate("WM2_Line", OBJ_HLINE,0, CurTime(),WM2);
    ObjectSet("WM2_Line", OBJPROP_COLOR, Weekly_Mid_Level);
    ObjectSet("WM2_Line", OBJPROP_STYLE, STYLE_DOT);
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
    ObjectCreate("WM3_Line", OBJ_HLINE,0, CurTime(),WM3);
    ObjectSet("WM3_Line", OBJPROP_COLOR, Weekly_Mid_Level);
    ObjectSet("WM3_Line", OBJPROP_STYLE, STYLE_DOT);
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
    ObjectCreate("WM4_Line", OBJ_HLINE,0, CurTime(),WM4);
    ObjectSet("WM4_Line", OBJPROP_COLOR, Weekly_Mid_Level);
    ObjectSet("WM4_Line", OBJPROP_STYLE, STYLE_DOT);
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
    ObjectCreate("WM5_Line", OBJ_HLINE,0, CurTime(),WM5);
    ObjectSet("WM5_Line", OBJPROP_COLOR, Weekly_Mid_Level);
    ObjectSet("WM5_Line", OBJPROP_STYLE, STYLE_DOT);
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
    ObjectCreate("WM6_Line", OBJ_HLINE,0, CurTime(),WM6);
    ObjectSet("WM6_Line", OBJPROP_COLOR, Weekly_Mid_Level);
    ObjectSet("WM6_Line", OBJPROP_STYLE, STYLE_DOT);
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
 
  ObjectsRedraw();
 }


//---------------------------------------------------------
//---------------------------------------------------------
//---------------------------------------------------------

if (Monthly==true)
 {
 if(ObjectFind("MonthPivotLine") != 0)
  {
   ObjectCreate("MonthPivotLine", OBJ_HLINE,0, CurTime(),MonthPivot);
   ObjectSet("MonthPivotLine", OBJPROP_COLOR, Monthly_Pivot);
   ObjectSet("MonthPivotLine", OBJPROP_STYLE, STYLE_DASH);
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
 if(ObjectFind("MR1_Line") != 0)
   { 
    ObjectCreate("MR1_Line", OBJ_HLINE,0, CurTime(),MR1);
    ObjectSet("MR1_Line", OBJPROP_COLOR, Monthly_R_Levels);
    ObjectSet("MR1_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
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
    ObjectCreate("MR2_Line", OBJ_HLINE,0, CurTime(),MR2);
    ObjectSet("MR2_Line", OBJPROP_COLOR, Monthly_R_Levels);
    ObjectSet("MR2_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
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
    ObjectCreate("MR3_Line", OBJ_HLINE,0, CurTime(),MR3);
    ObjectSet("MR3_Line", OBJPROP_COLOR, Monthly_R_Levels);
    ObjectSet("MR3_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
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
    ObjectCreate("MS1_Line", OBJ_HLINE,0, CurTime(),MS1);
    ObjectSet("MS1_Line", OBJPROP_COLOR, Monthly_S_Levels);
    ObjectSet("MS1_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
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
    ObjectCreate("MS2_Line", OBJ_HLINE,0, CurTime(),MS2);
    ObjectSet("MS2_Line", OBJPROP_COLOR, Monthly_S_Levels);
    ObjectSet("MS2_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
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
    ObjectCreate("MS3_Line", OBJ_HLINE,0, CurTime(),MS3);
    ObjectSet("MS3_Line", OBJPROP_COLOR, Monthly_S_Levels);
    ObjectSet("MS3_Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
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
  if(ObjectFind("MM1_Line") != 0)
   { 
    ObjectCreate("MM1_Line", OBJ_HLINE,0, CurTime(),MM1);
    ObjectSet("MM1_Line", OBJPROP_COLOR, Monthly_Mid_Level);
    ObjectSet("MM1_Line", OBJPROP_STYLE, STYLE_DOT);
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
    ObjectCreate("MM2_Line", OBJ_HLINE,0, CurTime(),MM2);
    ObjectSet("MM2_Line", OBJPROP_COLOR, Monthly_Mid_Level);
    ObjectSet("MM2_Line", OBJPROP_STYLE, STYLE_DOT);
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
    ObjectCreate("MM3_Line", OBJ_HLINE,0, CurTime(),MM3);
    ObjectSet("MM3_Line", OBJPROP_COLOR, Monthly_Mid_Level);
    ObjectSet("MM3_Line", OBJPROP_STYLE, STYLE_DOT);
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
    ObjectCreate("MM4_Line", OBJ_HLINE,0, CurTime(),MM4);
    ObjectSet("MM4_Line", OBJPROP_COLOR, Monthly_Mid_Level);
    ObjectSet("MM4_Line", OBJPROP_STYLE, STYLE_DOT);
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
    ObjectCreate("MM5_Line", OBJ_HLINE,0, CurTime(),MM5);
    ObjectSet("MM5_Line", OBJPROP_COLOR, Monthly_Mid_Level);
    ObjectSet("MM5_Line", OBJPROP_STYLE, STYLE_DOT);
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
    ObjectCreate("MM6_Line", OBJ_HLINE,0, CurTime(),MM6);
    ObjectSet("MM6_Line", OBJPROP_COLOR, Monthly_Mid_Level);
    ObjectSet("MM6_Line", OBJPROP_STYLE, STYLE_DOT);
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
 
  ObjectsRedraw();
 }


//--------------------------------------------------------------

ObjectsRedraw();

   return(0);
}