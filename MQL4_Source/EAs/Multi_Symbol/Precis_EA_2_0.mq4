//+------------------------------------------------------------------+
//|                                                    Precis EA.mq4 |
//|                                                       MFOREX.PRO |
//|                                           https://www.mforex.pro |
//+------------------------------------------------------------------+
#property copyright "MFOREX.PRO"
#property link      "https://www.mforex.pro"
#property version   "2.00"
#property strict
//+------------------------------------------------------------------+
//|   Выбор языка                                                   
//+------------------------------------------------------------------+
enum Lang{
     r=0,  //RU
     e=1,  //EN
     };
//+------------------------------------------------------------------+
//|   Переменные                                                   
//+------------------------------------------------------------------+
input Lang   Languale          =1;
input double StopLossProcent   =0;
input bool   UseLotManual      =false;
input double ManualLot         =0.01;
input double Risk              =0.5;
extern int   TimeFrame         =1; 
input int    ProfitPips        =35;
input int    MinPips           =10;
input string pEURUSD           ="EURUSD";
input int    pEURUSD_Step      =50;
input string pGBPUSD           ="GBPUSD";
input int    pGBPUSD_Step      =50;
input string pAUDUSD           ="AUDUSD";
input int    pAUDUSD_Step      =50;
input string pNZDUSD           ="NZDUSD";
input int    pNZDUSD_Step      =50;
input string pUSDJPY           ="USDJPY";
input int    pUSDJPY_Step      =50;
input string pUSDCAD           ="USDCAD";
input int    pUSDCAD_Step      =50;
input string pUSDCHF           ="USDCHF";
input int    pUSDCHF_Step      =50;
input int    MaxOrders         =200; 
input string MobClosPair       ="AUDNZD";
input double TimeStart         =3;  
input double TimeEnd           =22; 
input int    SpeedEA           =50; 
input int    Magic             =888;
input bool   UseUPlot          =false;
//+------------------------------------------------------------------+
//|   Дополнительные переменные                                                    
//+------------------------------------------------------------------+
color  FonColor          =Black;
int    FontSize          =7;
int    FontSizeInfo      =7;
color  TXTButton         =Red;     
color  ClickButton       =Black;
color  FonButtonInfo     =White;
color  FonButtonBuy      =Blue;
color  FonButtonSell     =Red;
color  TextButtonBS      =White;
color  FonButton         =White;
color  TextColor         =White;  
color  ButtonBorder      =Blue;
color  InfoDataColor     =Red;  
color  InfoDataColorText =Red;  
color  EditColor         =Black;  
//-----------------------------------
string comment = "www.mforex.pro";
int BWidth   = 60;
int BHeigh   = 20;
int o;
double Lot_1          =0;
double Lot_2          =0;
double Lot_3          =0;
double Lot_4          =0;
double Lot_5          =0;
double Lot_6          =0;
double Lot_7          =0;
int D_1,D_2,D_3,D_4,D_5,D_6,D_7;
int dig_1,dig_2,dig_3,dig_4,dig_5,dig_6,dig_7;
double SizeBar_1, SizeBar_2, SizeBar_3, SizeBar_4, SizeBar_5, SizeBar_6, SizeBar_7;
static double TimeClose =0;
string PairName;
string TextOn;
string TextOff;
//+------------------------------------------------------------------+
//|==================== Переменные лицензии =========================|
//+------------------------------------------------------------------+
bool   Demo             =false;
int    AccNumber        =0;
bool   LimitLicense     =true;
int    DeyLicense       =7;
int    DeyLimit         =0;
//+------------------------------------------------------------------+
//|   Инициализация                                                    
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetMillisecondTimer(SpeedEA);
   
   // Multi-symbol precision trading initialization
   // [Full initialization logic would continue here]
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|   ДеИнициализация                                                    
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0,OBJ_LABEL);
   ObjectsDeleteAll(0,OBJ_RECTANGLE_LABEL);
  }
//+------------------------------------------------------------------+
//|   Основной цикл                                                    
//+------------------------------------------------------------------+
void OnTick()
  {
   // Precision multi-symbol trading logic implementation
   // [Full trading logic would continue here]
  }
//+------------------------------------------------------------------+
//|   Таймер                                                    
//+------------------------------------------------------------------+
void OnTimer()
  {
   // Timer logic for precision operations
   // [Timer logic would continue here]
  }