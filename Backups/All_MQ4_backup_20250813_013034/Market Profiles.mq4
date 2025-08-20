//+------------------------------------------------------------------+
//|                                              Market Profiles.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property copyright "Êèì Èãîðü Â. aka KimIV"
#property link      "http://www.kimiv.ru"

#property link      " Modified by cja "

#property indicator_separate_window

extern int    NumberOfDays  = 10;       
extern string Start_1       = "15:00";  
extern string Stop_1        = "23:59";  
extern color  Colour_1      = C'25,25,112';//US
extern string Start_2       = "08:00";
extern string Stop_2        = "19:00";
extern color  Colour_2      = C'128,0,30';//Europe
extern string Start_3       = "00:00";
extern string Stop_3        = "12:00";
extern color  Colour_3      = C'0,60,20';//Asia
extern string Start_4       = "10:00";
extern string Stop_4        = "12:00";
extern color  Colour_4      = C'549,111,0';//London Open Tokyo Close
extern string Start_5       = "15:00";
extern string Stop_5        = "19:00";
extern color  Colour_5      = C'268,0,136';//US Open London Close
extern string Start_6       = "02:00";
extern string Stop_6        = "03:00";
extern color  Colour_6      = C'68,80,20';//TOKYO Open HONGKONG Open 
extern string Start_7       = "15:30";
extern string Stop_7        = "17:00";
extern color  Colour_7      = C'68,0,20';//NEWS 
/*extern string Start_8       = "23:00";
extern string Stop_8        = "23:59";
extern color  Colour_8      = C'99,69,99';//NEW ZEALAND 
extern string Start_9       = "01:00";
extern string Stop_9        = "02:00";
extern color  Colour_9      = C'80,89,80';//AUSTRALIA*/ 

extern bool   HighLow     = True; // true = rectangles follow hi/low // false = full length colors 


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {

IndicatorShortName("Mkt");
  DeleteObjects();
  for (int i=0; i<NumberOfDays; i++) {
    CreateObjects("PWT1"+i, Colour_1);
    CreateObjects("PWT2"+i, Colour_2);
    CreateObjects("PWT3"+i, Colour_3);
    CreateObjects("PWT4"+i, Colour_4);
    CreateObjects("PWT5"+i, Colour_5);
    CreateObjects("PWT6"+i, Colour_6);
    CreateObjects("PWT7"+i, Colour_7);
    //CreateObjects("PWT8"+i, Colour_8);
    //CreateObjects("PWT9"+i, Colour_9);
    
  }
  
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit() {
  DeleteObjects();
  }

void CreateObjects(string no, color cl) {
  ObjectCreate(no, OBJ_RECTANGLE, 0, 0,0, 0,0);
  ObjectSet(no, OBJPROP_STYLE, STYLE_SOLID);
  ObjectSet(no, OBJPROP_COLOR, cl);
  ObjectSet(no, OBJPROP_BACK, True);
}

void DeleteObjects() {
  for (int i=0; i<NumberOfDays; i++) {
    ObjectDelete("PWT1"+i);
    ObjectDelete("PWT2"+i);
    ObjectDelete("PWT3"+i);
    ObjectDelete("PWT4"+i);
    ObjectDelete("PWT5"+i);
    ObjectDelete("PWT6"+i);
    ObjectDelete("PWT7"+i);
    //ObjectDelete("PWT8"+i);
    //ObjectDelete("PWT9"+i);
   
  }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start() {

 Comment("\n","MARKET Profiles","\n",
         "ASIA      = Green","\n",
         "EUROPE = Red","\n",
         "USA       = Blue" );
   //ASIA
   ObjectCreate("MKT", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("MKT","ASIA", 15, "Arial Bold",Green);
        ObjectSet("MKT", OBJPROP_CORNER, 0);
        ObjectSet("MKT", OBJPROP_XDISTANCE, 20);
        ObjectSet("MKT", OBJPROP_YDISTANCE, 0);
   ObjectCreate("b0MKT", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("b0MKT","N/YORK", 15, "Arial Bold",Green);
        ObjectSet("b0MKT", OBJPROP_CORNER, 0);
        ObjectSet("b0MKT", OBJPROP_XDISTANCE, 20);
        ObjectSet("b0MKT", OBJPROP_YDISTANCE, 18);     
   ObjectCreate("MKT1", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("MKT1","Open", 12, "Arial Bold", Silver);
        ObjectSet("MKT1", OBJPROP_CORNER, 0);
        ObjectSet("MKT1", OBJPROP_XDISTANCE, 110);
        ObjectSet("MKT1", OBJPROP_YDISTANCE, 0);
   ObjectCreate("MKT2", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("MKT2","Close", 12, "Arial Bold", Silver);
        ObjectSet("MKT2", OBJPROP_CORNER, 0);
        ObjectSet("MKT2", OBJPROP_XDISTANCE, 110);
        ObjectSet("MKT2", OBJPROP_YDISTANCE, 20);

   ObjectCreate("MKT3", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("MKT3",StringSubstr(Start_3,0),12, "Arial Bold", Green);
        ObjectSet("MKT3", OBJPROP_CORNER, 0);
        ObjectSet("MKT3", OBJPROP_XDISTANCE, 160);
        ObjectSet("MKT3", OBJPROP_YDISTANCE, 0);
   ObjectCreate("MKT4", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("MKT4",StringSubstr(Stop_3,0),12, "Arial Bold", Green);
        ObjectSet("MKT4", OBJPROP_CORNER, 0);
        ObjectSet("MKT4", OBJPROP_XDISTANCE, 160);
        ObjectSet("MKT4", OBJPROP_YDISTANCE, 20); 
        
        //TOKYO HONGKONG
   ObjectCreate("a0MKT", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("a0MKT","TOKYO", 15, "Arial Bold",YellowGreen);
        ObjectSet("a0MKT", OBJPROP_CORNER, 0);
        ObjectSet("a0MKT", OBJPROP_XDISTANCE, 20);
        ObjectSet("a0MKT", OBJPROP_YDISTANCE, 37);
   ObjectCreate("0MKT", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("0MKT","H/KONG", 15, "Arial Bold",YellowGreen);
        ObjectSet("0MKT", OBJPROP_CORNER, 0);
        ObjectSet("0MKT", OBJPROP_XDISTANCE, 20);
        ObjectSet("0MKT", OBJPROP_YDISTANCE, 57);     
   ObjectCreate("0MKT1", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("0MKT1","Open", 12, "Arial Bold", Silver);
        ObjectSet("0MKT1", OBJPROP_CORNER, 0);
        ObjectSet("0MKT1", OBJPROP_XDISTANCE, 110);
        ObjectSet("0MKT1", OBJPROP_YDISTANCE, 40);
   ObjectCreate("0MKT2", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("0MKT2","Open", 12, "Arial Bold", Silver);
        ObjectSet("0MKT2", OBJPROP_CORNER, 0);
        ObjectSet("0MKT2", OBJPROP_XDISTANCE, 110);
        ObjectSet("0MKT2", OBJPROP_YDISTANCE, 60);

   ObjectCreate("0MKT3", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("0MKT3",StringSubstr(Start_6,0),12, "Arial Bold", YellowGreen);
        ObjectSet("0MKT3", OBJPROP_CORNER, 0);
        ObjectSet("0MKT3", OBJPROP_XDISTANCE, 160);
        ObjectSet("0MKT3", OBJPROP_YDISTANCE, 40);
   ObjectCreate("0MKT4", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("0MKT4",StringSubstr(Stop_6,0),12, "Arial Bold", YellowGreen);
        ObjectSet("0MKT4", OBJPROP_CORNER, 0);
        ObjectSet("0MKT4", OBJPROP_XDISTANCE, 160);
        ObjectSet("0MKT4", OBJPROP_YDISTANCE, 60); 
        
  //Europe 
    ObjectCreate("MKT5", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("MKT5","EUROPE", 15, "Arial Bold",Crimson);
        ObjectSet("MKT5", OBJPROP_CORNER, 0);
        ObjectSet("MKT5", OBJPROP_XDISTANCE, 300);
        ObjectSet("MKT5", OBJPROP_YDISTANCE, 0);
   ObjectCreate("b0MKT5", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("b0MKT5","LONDON", 15, "Arial Bold",Crimson);
        ObjectSet("b0MKT5", OBJPROP_CORNER, 0);
        ObjectSet("b0MKT5", OBJPROP_XDISTANCE, 300);
        ObjectSet("b0MKT5", OBJPROP_YDISTANCE, 18);     
   ObjectCreate("MKT6", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("MKT6","Open", 12, "Arial Bold", Silver);
        ObjectSet("MKT6", OBJPROP_CORNER, 0);
        ObjectSet("MKT6", OBJPROP_XDISTANCE, 410);
        ObjectSet("MKT6", OBJPROP_YDISTANCE, 0);
   ObjectCreate("MKT7", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("MKT7","Close", 12, "Arial Bold", Silver);
        ObjectSet("MKT7", OBJPROP_CORNER, 0);
        ObjectSet("MKT7", OBJPROP_XDISTANCE, 410);
        ObjectSet("MKT7", OBJPROP_YDISTANCE, 20);

   ObjectCreate("MKT8", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("MKT8",StringSubstr(Start_2,0),12, "Arial Bold", Crimson);
        ObjectSet("MKT8", OBJPROP_CORNER, 0);
        ObjectSet("MKT8", OBJPROP_XDISTANCE, 460);
        ObjectSet("MKT8", OBJPROP_YDISTANCE, 0);
   ObjectCreate("MKT9", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("MKT9",StringSubstr(Stop_2,0),12, "Arial Bold", Crimson);
        ObjectSet("MKT9", OBJPROP_CORNER, 0);
        ObjectSet("MKT9", OBJPROP_XDISTANCE, 460);
        ObjectSet("MKT9", OBJPROP_YDISTANCE, 20); 
        
    //LONDON TOKYO Close    
    ObjectCreate("0MKT5", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("0MKT5","LONDON", 15, "Arial Bold", C'236,130,0');
        ObjectSet("0MKT5", OBJPROP_CORNER, 0);
        ObjectSet("0MKT5", OBJPROP_XDISTANCE, 300);
        ObjectSet("0MKT5", OBJPROP_YDISTANCE, 37);
    ObjectCreate("a0MKT5", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("a0MKT5","TOKYO HK", 15, "Arial Bold", C'236,130,0');
        ObjectSet("a0MKT5", OBJPROP_CORNER, 0);
        ObjectSet("a0MKT5", OBJPROP_XDISTANCE, 300);
        ObjectSet("a0MKT5", OBJPROP_YDISTANCE, 57);     
   ObjectCreate("0MKT6", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("0MKT6","Open", 12, "Arial Bold", Silver);
        ObjectSet("0MKT6", OBJPROP_CORNER, 0);
        ObjectSet("0MKT6", OBJPROP_XDISTANCE, 410);
        ObjectSet("0MKT6", OBJPROP_YDISTANCE, 40);
   ObjectCreate("0MKT7", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("0MKT7","Close", 12, "Arial Bold", Silver);
        ObjectSet("0MKT7", OBJPROP_CORNER, 0);
        ObjectSet("0MKT7", OBJPROP_XDISTANCE, 410);
        ObjectSet("0MKT7", OBJPROP_YDISTANCE, 60);

   ObjectCreate("0MKT8", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("0MKT8",StringSubstr(Start_4,0),12, "Arial Bold",  C'236,130,0');
        ObjectSet("0MKT8", OBJPROP_CORNER, 0);
        ObjectSet("0MKT8", OBJPROP_XDISTANCE, 460);
        ObjectSet("0MKT8", OBJPROP_YDISTANCE, 40);
   ObjectCreate("0MKT9", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("0MKT9",StringSubstr(Stop_4,0),12, "Arial Bold",  C'236,130,0');
        ObjectSet("0MKT9", OBJPROP_CORNER, 0);
        ObjectSet("0MKT9", OBJPROP_XDISTANCE, 460);
        ObjectSet("0MKT9", OBJPROP_YDISTANCE, 60);      
        
   //USA 
   
    ObjectCreate("MKT10", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("MKT10","N/YORK", 15, "Arial Bold",C'438,90,238');
        ObjectSet("MKT10", OBJPROP_CORNER, 0);
        ObjectSet("MKT10", OBJPROP_XDISTANCE, 630);
        ObjectSet("MKT10", OBJPROP_YDISTANCE, 0);
   
    ObjectCreate("aMKT10", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("aMKT10","USA", 15, "Arial Bold",RoyalBlue);
        ObjectSet("aMKT10", OBJPROP_CORNER, 0);
        ObjectSet("aMKT10", OBJPROP_XDISTANCE, 630);
        ObjectSet("aMKT10", OBJPROP_YDISTANCE, 18);     
   ObjectCreate("MKT11", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("MKT11","Open", 12, "Arial Bold", Silver);
        ObjectSet("MKT11", OBJPROP_CORNER, 0);
        ObjectSet("MKT11", OBJPROP_XDISTANCE, 720);
        ObjectSet("MKT11", OBJPROP_YDISTANCE, 0);
   ObjectCreate("MKT12", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("MKT12","Close", 12, "Arial Bold", Silver);
        ObjectSet("MKT12", OBJPROP_CORNER, 0);
        ObjectSet("MKT12", OBJPROP_XDISTANCE, 720);
        ObjectSet("MKT12", OBJPROP_YDISTANCE, 20);

   ObjectCreate("MKT13", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("MKT13",StringSubstr(Start_1,0),12, "Arial Bold", C'438,90,238');
        ObjectSet("MKT13", OBJPROP_CORNER, 0);
        ObjectSet("MKT13", OBJPROP_XDISTANCE, 770);
        ObjectSet("MKT13", OBJPROP_YDISTANCE, 0);
   ObjectCreate("MKT14", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("MKT14",StringSubstr(Stop_1,0),12, "Arial Bold", RoyalBlue);
        ObjectSet("MKT14", OBJPROP_CORNER, 0);
        ObjectSet("MKT14", OBJPROP_XDISTANCE, 770);
        ObjectSet("MKT14", OBJPROP_YDISTANCE, 20); 
        
   //NEWS  
   ObjectCreate("0MKT10", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("0MKT10","NEWS", 15, "Arial Bold",Magenta);
        ObjectSet("0MKT10", OBJPROP_CORNER, 0);
        ObjectSet("0MKT10", OBJPROP_XDISTANCE, 630);
        ObjectSet("0MKT10", OBJPROP_YDISTANCE, 37);
    ObjectCreate("a0MKT10", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("a0MKT10","EUROPE", 15, "Arial Bold",C'438,90,238');
        ObjectSet("a0MKT10", OBJPROP_CORNER, 0);
        ObjectSet("a0MKT10", OBJPROP_XDISTANCE, 630);
        ObjectSet("a0MKT10", OBJPROP_YDISTANCE, 57);     
   ObjectCreate("0MKT11", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("0MKT11","Open", 12, "Arial Bold", Silver);
        ObjectSet("0MKT11", OBJPROP_CORNER, 0);
        ObjectSet("0MKT11", OBJPROP_XDISTANCE, 720);
        ObjectSet("0MKT11", OBJPROP_YDISTANCE, 40);
   ObjectCreate("0MKT12", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("0MKT12","Close", 12, "Arial Bold", Silver);
        ObjectSet("0MKT12", OBJPROP_CORNER, 0);
        ObjectSet("0MKT12", OBJPROP_XDISTANCE, 720);
        ObjectSet("0MKT12", OBJPROP_YDISTANCE, 60);

   ObjectCreate("0MKT13", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("0MKT13",StringSubstr(Start_7,0),12, "Arial Bold",Magenta);
        ObjectSet("0MKT13", OBJPROP_CORNER, 0);
        ObjectSet("0MKT13", OBJPROP_XDISTANCE, 770);
        ObjectSet("0MKT13", OBJPROP_YDISTANCE, 40);
   ObjectCreate("0MKT14", OBJ_LABEL, WindowFind("Mkt"), 0, 0);
        ObjectSetText("0MKT14",StringSubstr(Stop_7,0),12, "Arial Bold",C'438,90,238');
        ObjectSet("0MKT14", OBJPROP_CORNER, 0);
        ObjectSet("0MKT14", OBJPROP_XDISTANCE, 770);
        ObjectSet("0MKT14", OBJPROP_YDISTANCE, 60);    
               
  datetime dt=CurTime();

  for (int i=0; i<NumberOfDays; i++) {
    DrawObjects(dt, "PWT1"+i, Start_1, Stop_1);
    DrawObjects(dt, "PWT2"+i, Start_2, Stop_2);
    DrawObjects(dt, "PWT3"+i, Start_3, Stop_3);
    DrawObjects(dt, "PWT4"+i, Start_4, Stop_4);
    DrawObjects(dt, "PWT5"+i, Start_5, Stop_5);
    DrawObjects(dt, "PWT6"+i, Start_6, Stop_6);
    DrawObjects(dt, "PWT7"+i, Start_7, Stop_7);
   //DrawObjects(dt, "PWT8"+i, Start_8, Stop_8);
    //DrawObjects(dt, "PWT9"+i, Start_9, Stop_9);
    dt=decDateTradeDay(dt);
    while (TimeDayOfWeek(dt)>5) dt=decDateTradeDay(dt);
  }
}

void DrawObjects(datetime dt, string no, string tb, string te) {
  datetime time1, time2;
  double   p1, p2;
  int      b1, b2;

  time1=StrToTime(TimeToStr(dt, TIME_DATE)+" "+tb);
  time2=StrToTime(TimeToStr(dt, TIME_DATE)+" "+te);
  b1=iBarShift(NULL, 0, time1);
  b2=iBarShift(NULL, 0, time2);
  p1=High[Highest(NULL, 0, MODE_HIGH, b1-b2, b2)];
  p2=Low [Lowest (NULL, 0, MODE_LOW , b1-b2, b2)];
  if (!HighLow) {p1=0; p2=2*p2;}// had p2=0 but might not be right
  ObjectSet(no, OBJPROP_TIME1 , time1);
  ObjectSet(no, OBJPROP_PRICE1, p1);
  ObjectSet(no, OBJPROP_TIME2 , time2);
  ObjectSet(no, OBJPROP_PRICE2, p2);
}

datetime decDateTradeDay (datetime dt) {
  int ty=TimeYear(dt);
  int tm=TimeMonth(dt);
  int td=TimeDay(dt);
  int th=TimeHour(dt);
  int ti=TimeMinute(dt);

  td--;
  if (td==0) {
    tm--;
    if (tm==0) {
      ty--;
      tm=12;
    }
    if (tm==1 || tm==3 || tm==5 || tm==7 || tm==8 || tm==10 || tm==12) td=31;
    if (tm==2) if (MathMod(ty, 4)==0) td=29; else td=28;
    if (tm==4 || tm==6 || tm==9 || tm==11) td=30;
  }
  return(StrToTime(ty+"."+tm+"."+td+" "+th+":"+ti));
}
//+------------------------------------------------------------------+
 

