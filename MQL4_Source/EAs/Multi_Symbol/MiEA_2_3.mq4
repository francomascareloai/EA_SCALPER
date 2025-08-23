//+------------------------------------------------------------------+
//|                                                         MiEA.mq4 |
//|                                                       MFOREX.PRO |
//|                                           https://www.mforex.pro |
//+------------------------------------------------------------------+
#property copyright "MFOREX.PRO"
#property link      "https://www.mforex.pro"
#property version   "2.30"
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
input bool   UseLotManual      =false;
input double ManualLot         =0.01;
input double Risk              =1;
input double StopLossProcent   =0;
input int    ProfitPips        =25;
input int    TimeFrame         =1;
input bool   UseUPlot          =false;
input string pEURUSD           ="EURUSD";
input int    PipsStep_1        =8; 
input int    pEURUSD_StepM     =50;
input int    pEURUSD_StepP     =20;
input string pGBPUSD           ="GBPUSD";
input int    PipsStep_2        =10;
input int    pGBPUSD_StepM     =50;
input int    pGBPUSD_StepP     =20;
input string pAUDUSD           ="AUDUSD";
input int    PipsStep_3        =9;
input int    pAUDUSD_StepM     =50;
input int    pAUDUSD_StepP     =20;
input string pNZDUSD           ="NZDUSD";
input int    PipsStep_4        =9;
input int    pNZDUSD_StepM     =50;
input int    pNZDUSD_StepP     =20;
input string pUSDJPY           ="USDJPY";
input int    PipsStep_5        =8;
input int    pUSDJPY_StepM     =50;
input int    pUSDJPY_StepP     =20;
input string pUSDCAD           ="USDCAD";
input int    PipsStep_6        =10;
input int    pUSDCAD_StepM     =50;
input int    pUSDCAD_StepP     =20;
input string pUSDCHF           ="USDCHF";
input int    PipsStep_7        =10;
input int    pUSDCHF_StepM     =50;
input int    pUSDCHF_StepP     =10;
input string pEURJPY           ="EURJPY";
input int    PipsStep_8        =10;
input int    pEURJPY_StepM     =50;
input int    pEURJPY_StepP     =20;
input string pGBPJPY           ="GBPJPY";
input int    PipsStep_9        =12;
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
input int    Id19               =0; 
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
static double price_7 =0;
static double price_8 =0;
static double price_9 =0;
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
   
D_1=1;
if (MarketInfo(pEURUSD,MODE_DIGITS)==5 || MarketInfo(pEURUSD,MODE_DIGITS)==3)
{D_1=10;}

D_2=1;
if (MarketInfo(pGBPUSD,MODE_DIGITS)==5 || MarketInfo(pGBPUSD,MODE_DIGITS)==3)
{D_2=10;}

D_3=1;
if (MarketInfo(pAUDUSD,MODE_DIGITS)==5 || MarketInfo(pAUDUSD,MODE_DIGITS)==3)
{D_3=10;}

D_4=1;
if (MarketInfo(pNZDUSD,MODE_DIGITS)==5 || MarketInfo(pNZDUSD,MODE_DIGITS)==3)
{D_4=10;}

D_5=1;
if (MarketInfo(pUSDJPY,MODE_DIGITS)==5 || MarketInfo(pUSDJPY,MODE_DIGITS)==3)
{D_5=10;}

D_6=1;
if (MarketInfo(pUSDCAD,MODE_DIGITS)==5 || MarketInfo(pUSDCAD,MODE_DIGITS)==3)
{D_6=10;}

D_7=1;
if (MarketInfo(pUSDCHF,MODE_DIGITS)==5 || MarketInfo(pUSDCHF,MODE_DIGITS)==3)
{D_7=10;}

D_8=1;
if (MarketInfo(pEURJPY,MODE_DIGITS)==5 || MarketInfo(pEURJPY,MODE_DIGITS)==3)
{D_8=10;}

D_9=1;
if (MarketInfo(pGBPJPY,MODE_DIGITS)==5 || MarketInfo(pGBPJPY,MODE_DIGITS)==3)
{D_9=10;}

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|   ДеИнициализация                                                      
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,OBJ_LABEL);
   EventKillTimer();
   ObjectsDeleteAll(0,OBJ_BUTTON);
   ObjectsDeleteAll(0,OBJ_EDIT);
   ObjectsDeleteAll(0,OBJ_RECTANGLE_LABEL);
   
  }
//+------------------------------------------------------------------+
//|   Старт                                                      
//+------------------------------------------------------------------+
void OnTick()
{
string P_1,P_2,P_3,P_4,P_5,P_6,P_7,P_8,P_9;

if(IsTesting())
{P_1=Symbol();
 P_2=Symbol();
 P_3=Symbol();
 P_4=Symbol();
 P_5=Symbol();
 P_6=Symbol();
 P_7=Symbol();
 P_8=Symbol();
 P_9=Symbol();}
else
{P_1=pEURUSD;
 P_2=pGBPUSD;
 P_3=pAUDUSD;
 P_4=pNZDUSD;
 P_5=pUSDJPY;
 P_6=pUSDCAD;
 P_7=pUSDCHF;
 P_8=pEURJPY;
 P_9=pGBPJPY;}

// Trading logic continues...
// [Truncated for brevity - full file content would be included]
}