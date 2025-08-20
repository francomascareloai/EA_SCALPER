//+-------------------------------------------------------------------------------------------------------------------------+
//|                                                                             Copyright 2014, William Kreider (Madhatt30) |
//|                                                                                                                         |
//| Broker_Time_Offset fix b2, enhancements and Alert mods by file45 - https://login.mql5.com/en/users/file45/publications  |
//+-------------------------------------------------------------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property strict
#property indicator_chart_window

enum FontSelect 
{
   Arial=0,
   Times_New_Roman=1,
   Courier=2
};
enum ChartWindow
{
   Main_Chart_Window = 0, // Main chart window
   First_Separate_Window = 1, // 1st Separate window
   Second_Seperate_Window = 2, // 2nd Separate window
   Third_Separate_Window = 3, // 3rd Separate window
   Fourth_Separate_Window = 4, // 4th Separate window
   Fith_Separate_Window = 5, // 5th Separate window
   Sixth_Separate_Window = 6 // 6th Separate window
};   

enum AlertMode_z 
{
   NoAlert_z = 0, // Off
   PopUpAlert_z = 1, // On
   SoundAlert_z = 2 // Sound only 
};   
  
//--- input parameter
input int Broker_Time_Offset = 1; // Broker Time adjustment (0 = GMT, 1 = GMT + 1 etc)
input AlertMode_z Alert_Modez = 0; // Select Alert Mode 
//input color fntcolor = Teal;  // Font Color
input color Al_Off = DodgerBlue; // Alert Off Color
input color Al_On = Red; // Alert On Color
input color Snd_Only = DarkOrange; // Sound Only Color
input FontSelect selectedFont = 0; // Font Select
input bool bold = false;  // Font Bold
input int textSize = 14;  // Font Size
input int XDistance = 20;  // Left - Right
input int YDistance = 40;  // Up - Down
input ENUM_BASE_CORNER corner = 1;  // Corner 
input ChartWindow  windexx = 0;  // Display Window

long           thisChart;
int            iFontType;
string         sBoldType;
string         sFontType;
int            timeOffset;
datetime       ServerLocalOffset;
datetime       prevTime,myTime,localtime;
bool           newBar = false;
datetime LastAlertTime;
ENUM_ANCHOR_POINT corner_loc;
string TMz;
color The_Font_Color;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int OnInit()
{
   switch(Alert_Modez) 
   {
      case 0: The_Font_Color = Al_Off; break;
      case 1: The_Font_Color = Al_On; break;
      case 2: The_Font_Color = Snd_Only; 
   } 
    
   switch(Period())
   {    
      case 1:     TMz = "M1";  break;
      case 2:     TMz = "M2";  break;
      case 3:     TMz = "M3";  break;
      case 4:     TMz = "M4";  break;
      case 5:     TMz = "M5";  break;
      case 6:     TMz = "M6";  break;
      case 7:     TMz = "M7";  break;
      case 8:     TMz = "M8";  break;
      case 9:     TMz = "M9";  break;
      case 10:    TMz = "M10"; break;
      case 11:    TMz = "M11"; break;
      case 12:    TMz = "M12"; break;
      case 13:    TMz = "M13"; break;
      case 14:    TMz = "M14"; break;
      case 15:    TMz = "M15"; break;
      case 20:    TMz = "M20"; break;
      case 25:    TMz = "M25"; break;
      case 30:    TMz = "M30"; break;
      case 40:    TMz = "M40"; break;
      case 45:    TMz = "M45"; break;
      case 50:    TMz = "M50"; break;
      case 60:    TMz = "H1";  break;
      case 120:   TMz = "H2";  break;
      case 180:   TMz = "H3";  break;
      case 240:   TMz = "H4";  break;
      case 300:   TMz = "H5";  break;
      case 360:   TMz = "H6";  break;
      case 420:   TMz = "H7";  break;
      case 480:   TMz = "H8";  break;
      case 540:   TMz = "H9";  break;
      case 600:   TMz = "H10"; break;
      case 660:   TMz = "H11"; break;
      case 720:   TMz = "H12"; break;
      case 1440:  TMz = "D1";  break;
      case 10080: TMz = "W1";  break;
      case 43200: TMz = "M1";  break;  
   }  
   
   switch(corner)
   {
      case 0: corner_loc = ANCHOR_LEFT_UPPER; break;
      case 1: corner_loc = ANCHOR_LEFT_LOWER; break;
      case 2: corner_loc = ANCHOR_RIGHT_LOWER; break;
      case 3: corner_loc = ANCHOR_RIGHT_UPPER;
   }    
     
   LastAlertTime = TimeCurrent();   
//--- indicator buffers mapping
   EventSetTimer(1);
   thisChart = ChartID();
   if(bold){
      sBoldType=" Bold";
   }else if(!bold){
      sBoldType="";
   }
   iFontType=selectedFont;
   Comment("");
   switch(iFontType){
      case 0: sFontType="Arial" + sBoldType; break;
      case 1: sFontType="Times New Roman" + sBoldType; break;
      case 2: sFontType="Courier" + sBoldType; break;
   }
   ObjectCreate(thisChart,"BarTimer",OBJ_LABEL,windexx,XDistance,YDistance);

   datetime srvtime,tmpOffset;
   // Use RefreshRates to get the current time from TimeCurrent
   // Otherwise you'll just get the last known time
   RefreshRates();
   
   srvtime = TimeCurrent();
   // Modified
   localtime = TimeLocal()+TimeGMTOffset();
   if(TimeHour(srvtime)>TimeHour(localtime)){
      // Server Time is still ahead of us
      int newOffset = TimeHour(srvtime)-TimeHour(localtime);
      ServerLocalOffset = (newOffset*60*60);
   }else if(TimeHour(srvtime)<TimeHour(localtime)){
      // Server Time is Behind us
      int newOffset = TimeHour(localtime)-TimeHour(srvtime);
      ServerLocalOffset = (newOffset*60*60);
   }else{
      // No modification required
      ServerLocalOffset = srvtime;
   }
   localtime = TimeLocal()-ServerLocalOffset;
   
   tmpOffset = TimeSeconds(srvtime) - TimeSeconds(localtime);
   if(tmpOffset < 30 && tmpOffset >= 0){
      timeOffset = TimeSeconds(srvtime) - TimeSeconds(localtime);
   }
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectDelete("BarTimer");
   ObjectDelete("NBz");
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   if ((Alert_Modez == 1) && (LastAlertTime < Time[0]))
   {
      Alert("New Bar  -  ", Symbol(), "  -  " + TMz + "  -  " + AccountCompany());   
      LastAlertTime = Time[0];
   }	
   else if ((Alert_Modez == 2) && (LastAlertTime < Time[0]))
   {
      PlaySound("Alert.wav");
      LastAlertTime = Time[0];
   }   
   
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   if(Period() >0 && Period() <1440)
   {
      localtime = TimeLocal()+(TimeGMTOffset()+((60*60)*Broker_Time_Offset));
      if(ObjectFind(thisChart,"BarTimer")>=0)
      {
         ObjectCreate(0,"BarTimer",OBJ_LABEL,windexx,0,0);
         ObjectSetInteger(0,"BarTimer",OBJPROP_ANCHOR,corner_loc);
         ObjectSet("BarTimer",OBJPROP_CORNER,corner);
         ObjectSet("BarTimer",OBJPROP_XDISTANCE,XDistance);
         ObjectSet("BarTimer",OBJPROP_YDISTANCE,YDistance);
         ObjectSetText("BarTimer",TimeToStr(Time[0]+Period()*60-localtime-timeOffset,TIME_SECONDS ),textSize,sFontType,The_Font_Color);
     } 
   }
}

