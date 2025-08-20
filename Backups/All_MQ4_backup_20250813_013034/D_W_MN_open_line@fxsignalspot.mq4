 
//*
#property copyright "(c) 2014 by Mop"
#property link      "http://www.stevehopwoodforex.com/phpBB3/index.php"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Teal
#property indicator_color2 Crimson
#property indicator_color3 DodgerBlue
#property indicator_style1 1
#property indicator_style2 1
#property indicator_style3 1
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2

extern double Button_Size =1.0;
extern int X_Coordinate = 10;
extern int Y_Coordinate = 25;


double MonthOpenBuffer[];
double WeekOpenBuffer[];
double DayOpenBuffer[];

double Shft = 0; // 0 = for present daily / week / month open

bool ButtonStateD = false;
bool ButtonStateW = false;
bool ButtonStateM = false;
string ButtonNameD = "Button D";
string ButtonNameW = "Button W";
string ButtonNameM = "Button M"; 

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
	SetIndexStyle(0,DRAW_LINE);
	SetIndexBuffer(0,MonthOpenBuffer);
	SetIndexLabel(0,"MonthOpen");
	SetIndexStyle(1,DRAW_LINE);
	SetIndexBuffer(1,WeekOpenBuffer);
	SetIndexLabel(1,"WeekOpen");
	SetIndexStyle(2,DRAW_LINE);
	SetIndexBuffer(2,DayOpenBuffer);
	SetIndexLabel(2,"DayOpen");
	
	PressButtonD();
	PressButtonW();
	PressButtonM();
		
	return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   ObjectDelete(ButtonNameD);
   ObjectDelete(ButtonNameW);
   ObjectDelete(ButtonNameM);
	return(0);
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

    if(sparam==ButtonNameD) PressButtonD();
    if(sparam==ButtonNameW) PressButtonW();
    if(sparam==ButtonNameM) PressButtonM();
    
   
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int i=0;
   datetime TimeArray2[];
   datetime TimeArray3[];
   datetime TimeArray4[];
   
   int    limit,y2=0,y3=0,y4=0,y5=0;

// Plot defined timeframe on to current timeframe   
   ArrayCopySeries(TimeArray2,MODE_TIME,Symbol(),PERIOD_MN1);
   ArrayCopySeries(TimeArray3,MODE_TIME,Symbol(),PERIOD_W1);
   ArrayCopySeries(TimeArray4,MODE_TIME,Symbol(),PERIOD_D1);

   
   limit=100+PERIOD_MN1/Period();
if (NewBar(Period()))
{
   for(i=0,y2=0,y3=0,y4=0;i<limit;i++)

     {
      if(Time[i]<TimeArray2[y2]) y2++;
       MonthOpenBuffer[i]=iOpen(Symbol(),43200,y2+Shft);
       if(Time[i]<TimeArray3[y3]) y3++;
       WeekOpenBuffer[i]=iOpen(Symbol(),10080,y3+Shft);
       if(Time[i]<TimeArray4[y4]) y4++;
       DayOpenBuffer[i]=iOpen(Symbol(),1440,y4+Shft);
       }
       }
   return (0);
}
bool NewBar(int TimeFrame)
  {
   static datetime LastTime=0;
   if(iTime(NULL,TimeFrame,0)!=LastTime)
     {
      LastTime=iTime(NULL,TimeFrame,0);
      return (true);
     }
   else
      return (false);
  }

void PressButtonD(){

    ButtonStateD = !ButtonStateD;

    color cColor = clrWhite;
    color BgColor = clrGreen;
    string textoboton = " ON";

    if(ButtonStateD == false)
    {
        BgColor = clrRed;
        textoboton = " OFF";
    SetIndexStyle(2, DRAW_NONE); 

      WindowRedraw();
    }
    
    if(ButtonStateD == true)
    { 
    SetIndexStyle(2, DRAW_LINE); 

      WindowRedraw();
    }

    CreateButtonD(ButtonNameD,cColor,BgColor,"Arial",textoboton);
   
}

void CreateButtonD(string sName, color cColor, color BgColor,string sFont = "Arial", string sText = "") {

   if(ObjectFind(sName)< 0){
      ObjectCreate(0,sName,OBJ_BUTTON,0,0,0);
   }
   ObjectSetInteger(0,sName,OBJPROP_XDISTANCE,X_Coordinate);
   ObjectSetInteger(0,sName,OBJPROP_YDISTANCE,int(Button_Size*Y_Coordinate));
   ObjectSetInteger(0,sName,OBJPROP_XSIZE,int(Button_Size*120));
   ObjectSetInteger(0,sName,OBJPROP_YSIZE,int(Button_Size*19));
   ObjectSetInteger(0,sName,OBJPROP_CORNER,CORNER_LEFT_LOWER);  
   ObjectSetString(0,sName,OBJPROP_TEXT,"D open line"+sText);
   ObjectSetInteger(0,sName,OBJPROP_COLOR, cColor);
   ObjectSetInteger(0,sName,OBJPROP_BGCOLOR, BgColor);
   ObjectSetInteger(0,sName,OBJPROP_BORDER_COLOR,clrWhite);
   ObjectSetInteger(0,sName,OBJPROP_HIDDEN, false);
   ObjectSetString(0,sName,OBJPROP_FONT,sFont);
   ObjectSetInteger(0,sName,OBJPROP_FONTSIZE,int(Button_Size*9));
   ObjectSetInteger(0,sName,OBJPROP_ZORDER,999999);
   
}

void PressButtonW(){

    ButtonStateW = !ButtonStateW;

    color cColor = clrWhite;
    color BgColor = clrGreen;
    string textoboton = " ON";

    if(ButtonStateW == false)
    {
        BgColor = clrRed;
        textoboton = " OFF";
    SetIndexStyle(1, DRAW_NONE); 

      WindowRedraw();
    }
    
    if(ButtonStateW == true)
    { 
    SetIndexStyle(1, DRAW_LINE); 

      WindowRedraw();
    }

    CreateButtonW(ButtonNameW,cColor,BgColor,"Arial",textoboton);
   
}

void CreateButtonW(string sName, color cColor, color BgColor,string sFont = "Arial", string sText = "") {

   if(ObjectFind(sName)< 0){
      ObjectCreate(0,sName,OBJ_BUTTON,0,0,0);
   }
   ObjectSetInteger(0,sName,OBJPROP_XDISTANCE,X_Coordinate);
   ObjectSetInteger(0,sName,OBJPROP_YDISTANCE,int(Button_Size*Y_Coordinate+25));
   ObjectSetInteger(0,sName,OBJPROP_XSIZE,int(Button_Size*120));
   ObjectSetInteger(0,sName,OBJPROP_YSIZE,int(Button_Size*19));
   ObjectSetInteger(0,sName,OBJPROP_CORNER,CORNER_LEFT_LOWER);  
   ObjectSetString(0,sName,OBJPROP_TEXT,"W open line"+sText);
   ObjectSetInteger(0,sName,OBJPROP_COLOR, cColor);
   ObjectSetInteger(0,sName,OBJPROP_BGCOLOR, BgColor);
   ObjectSetInteger(0,sName,OBJPROP_BORDER_COLOR,clrWhite);
   ObjectSetInteger(0,sName,OBJPROP_HIDDEN, false);
   ObjectSetString(0,sName,OBJPROP_FONT,sFont);
   ObjectSetInteger(0,sName,OBJPROP_FONTSIZE,int(Button_Size*9));
   ObjectSetInteger(0,sName,OBJPROP_ZORDER,999999);
   
}

void PressButtonM(){

    ButtonStateM = !ButtonStateM;

    color cColor = clrWhite;
    color BgColor = clrGreen;
    string textoboton = " ON";

    if(ButtonStateM == false)
    {
        BgColor = clrRed;
        textoboton = " OFF";
    SetIndexStyle(0, DRAW_NONE); 

      WindowRedraw();
    }
    
    if(ButtonStateM == true)
    { 
    SetIndexStyle(0, DRAW_LINE); 

      WindowRedraw();
    }

    CreateButtonM(ButtonNameM,cColor,BgColor,"Arial",textoboton);
   
}

void CreateButtonM(string sName, color cColor, color BgColor,string sFont = "Arial", string sText = "") {

   if(ObjectFind(sName)< 0){
      ObjectCreate(0,sName,OBJ_BUTTON,0,0,0);
   }
   ObjectSetInteger(0,sName,OBJPROP_XDISTANCE,X_Coordinate);
   ObjectSetInteger(0,sName,OBJPROP_YDISTANCE,int(Button_Size*Y_Coordinate+50));
   ObjectSetInteger(0,sName,OBJPROP_XSIZE,int(Button_Size*120));
   ObjectSetInteger(0,sName,OBJPROP_YSIZE,int(Button_Size*19));
   ObjectSetInteger(0,sName,OBJPROP_CORNER,CORNER_LEFT_LOWER);  
   ObjectSetString(0,sName,OBJPROP_TEXT,"M open line"+sText);
   ObjectSetInteger(0,sName,OBJPROP_COLOR, cColor);
   ObjectSetInteger(0,sName,OBJPROP_BGCOLOR, BgColor);
   ObjectSetInteger(0,sName,OBJPROP_BORDER_COLOR,clrWhite);
   ObjectSetInteger(0,sName,OBJPROP_HIDDEN, false);
   ObjectSetString(0,sName,OBJPROP_FONT,sFont);
   ObjectSetInteger(0,sName,OBJPROP_FONTSIZE,int(Button_Size*9));
   ObjectSetInteger(0,sName,OBJPROP_ZORDER,999999);
   
}