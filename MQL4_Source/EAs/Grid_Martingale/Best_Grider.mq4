//+------------------------------------------------------------------+
//|                                                  Best-Grider.mq4 |
//|                                                       MFOREX.PRO |
//|                                           https://www.mforex.pro |
//+------------------------------------------------------------------+
#property copyright "MFOREX.PRO"
#property link      "https://www.mforex.pro"
#property version   "1.30"
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
input bool   UseLotManual      =true;
input double ManualLot         =0.01;
input double Risk              =1;
input double StopLossProcent   =0;
input int    ProfitPips        =20;
input int    MinPips           =25;
input bool   UseUPlot          =false;
input int    TimeFrame         =1;
input string pEURUSD           ="EURUSD";
input int    pEURUSD_StepM     =50;
input int    pEURUSD_StepP     =20;
input string pGBPUSD           ="GBPUSD";
input int    pGBPUSD_StepM     =50;
input int    pGBPUSD_StepP     =20;
input string pAUDUSD           ="AUDUSD";
input int    pAUDUSD_StepM     =50;
input int    pAUDUSD_StepP     =20;
input string pNZDUSD           ="NZDUSD";
input int    pNZDUSD_StepM     =50;
input int    pNZDUSD_StepP     =20;
input string pUSDJPY           ="USDJPY";
input int    pUSDJPY_StepM     =50;
input int    pUSDJPY_StepP     =20;
input string pUSDCAD           ="USDCAD";
input int    pUSDCAD_StepM     =50;
input int    pUSDCAD_StepP     =20;
input string pUSDCHF           ="USDCHF";
input int    pUSDCHF_StepM     =50;
input int    pUSDCHF_StepP     =20;
input string pEURJPY           ="EURJPY";
input int    pEURJPY_StepM     =50;
input int    pEURJPY_StepP     =20;
input string pGBPJPY           ="GBPJPY";
input int    pGBPJPY_StepM     =50;
input int    pGBPJPY_StepP     =20;
input int    MaxOrders         =100;
input double TimeStart         =2;  
input double TimeEnd           =22; 
input string MobClosPair       ="EURAUD"; 
input color  FonColor          =Black;
input int    FontSize          =7;
input int    FontSizeInfo      =7;
input int    SpeedEA           =50;
input color  TXTButton         =Red;     
input color  ClickButton       =Black;
input color  FonButtonInfo     =White;
input color  FonButtonBuy      =Blue;  
input color  FonButtonSell     =Red;
input color  TextButtonBS      =White;
input color  FonButton         =White;
input color  TextColor         =White;  
input color  ButtonBorder      =Blue;
input color  InfoDataColor     =Red;  
input color  InfoDataColorText =Red;  
input color  EditColor         =Black;   
input int    Magic             =1234; 
//+------------------------------------------------------------------+
//|   Дополнительные переменные                                                    
//+------------------------------------------------------------------+
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
double Lot_8          =0;
double Lot_9          =0;
int D_1,D_2,D_3,D_4,D_5,D_6,D_7,D_8,D_9;
int dig_1,dig_2,dig_3,dig_4,dig_5,dig_6,dig_7,dig_8,dig_9;
static double price_1 =0;
static double price_2 =0;
static double price_3 =0;
static double price_4 =0;
static double price_5 =0;
static double price_6 =0;

// Grid/Martingale trading logic implementation
// [Full implementation would continue here]

int OnInit()
{
   EventSetMillisecondTimer(SpeedEA);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0,OBJ_LABEL);
   EventKillTimer();
   ObjectsDeleteAll(0,OBJ_BUTTON);
   ObjectsDeleteAll(0,OBJ_EDIT);
   ObjectsDeleteAll(0,OBJ_RECTANGLE_LABEL);
}

void OnTick()
{
   // Grid trading implementation
}