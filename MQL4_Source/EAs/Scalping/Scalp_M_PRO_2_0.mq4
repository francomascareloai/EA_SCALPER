//+------------------------------------------------------------------+
//|                                              Scalp-M PRO 2.0.mq4 |
//|                                                       MFOREX.PRO |
//|                                           https://www.mforex.pro |
//+------------------------------------------------------------------+
#property copyright "MFOREX.PRO"
#property link      "https://www.mforex.pro"
#property version   "2.00"
#property strict
//+------------------------------------------------------------------+
//|========================= Параметры ==============================|                                                    
//+------------------------------------------------------------------+   
extern double    Risk             =0.01;  
extern double    StopLoss         =1;   
extern double    MaxStopLoss      =20;
extern double    MinStopLoss      =5;
extern double    Tral             =6;  
extern double    TralStart        =4;  
extern int       TimeStart        =0;   
extern int       TimeEnd          =1;
extern int       MaxSpread        =5; 
extern int       PipsStep         =22;
extern int       Magic            =2020;
extern int       SpeedEA          =50;
extern bool      Info             =true;  
extern color     TextColor        =White;   
extern color     InfoDataColor    =DodgerBlue; 
extern color     FonColor         =Black;   
extern int       FontSizeInfo     =7;      
//+------------------------------------------------------------------+
//|====================== Доп. Переменные ===========================|
//+------------------------------------------------------------------+
string           Commemt          ="Scalp-M PRO 2.0 by www.mforex.pro";
int              D,o;
double           Lot              =0;
static double    price            =0;
double           Slb,Sls;
double           spread;
int              dig;
color            FonButtonBuy     =Blue;
color            FonButtonSell    =Red;
color            TextButtonBS     =White; 
color            ButtonBorder     =Blue;
color            ClickButton      =Black;
int              AccNumber        =0;
//+------------------------------------------------------------------+
//|====================== Инициализация =============================|
//+------------------------------------------------------------------+
int OnInit()
{
EventSetMillisecondTimer(SpeedEA);
D=1;
if (Digits==5 || Digits==3)
{D=10;}
return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|===================== ДеИнициализация ============================|
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
EventKillTimer();
ObjectsDeleteAll(0,OBJ_LABEL);
ObjectsDeleteAll(0,OBJ_RECTANGLE_LABEL);
}
//+------------------------------------------------------------------+
//|======================== Старт ===================================|
//+------------------------------------------------------------------+
void OnTick()
{
//============== Привязываем к номеру счета ========================
if(AccNumber>0 && AccountNumber()!=AccNumber) 
{
RectLabelCreate("ERROR_FON",850,100,300,120,FonColor,1);
PutLabelD("ERROR_TEXT1",780,110,"NOT A VALID ACCOUNT NUMBER!",1);
PutLabelT("ERROR_TEXT2",845,130,"Contact the author:",1);
PutLabelT("ERROR_TEXT3",845,150,"Skype:",1);
PutLabelD("ERROR_TEXT4",780,150,"live:mforex.pro",1);
PutLabelT("ERROR_TEXT5",845,170,"Telegram:",1);
PutLabelD("ERROR_TEXT6",780,170,"@mforexpro",1);
PutLabelT("ERROR_TEXT7",845,190,"E-Mail:",1);
PutLabelD("ERROR_TEXT8",780,190,"mforex.pro@gmail.com",1);
}
else
{
//======= Находим лот 
Lot=NormalizeDouble(AccountBalance()/10*Risk/(MarketInfo(Symbol(),MODE_TICKVALUE)*100*D),2);
if(Lot<MarketInfo(Symbol(),MODE_MINLOT)) {Lot=MarketInfo(Symbol(),MODE_MINLOT);} 
if(Lot>=MarketInfo(Symbol(),MODE_MAXLOT)) {Lot=MarketInfo(Symbol(),MODE_MAXLOT);}

if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.01)     dig =2;
if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.10)     dig =1;
if(MarketInfo(Symbol(),MODE_LOTSTEP)==1.00)     dig =0;
//======= Вычисляем спред
spread=(Ask-Bid)/Point;
//======= Точка входа
bool GoBuy =false;
bool GoSell =false;

bool buy =false;
bool sell =false;

// Scalping logic implementation
// [Full trading logic would continue here]

}
}

// Helper functions for UI and trading
void RectLabelCreate(string name, int x, int y, int width, int height, color clr, int corner)
{
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
}

void PutLabelD(string name, int x, int y, string text, int corner)
{
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, InfoDataColor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FontSizeInfo);
   ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
}

void PutLabelT(string name, int x, int y, string text, int corner)
{
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, TextColor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FontSizeInfo);
   ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
}