//=============================================================================================================|
//                                    ���� ����� !!!                                 |    ZzLiSzZ ����� ��5    |
//                        � �������������� ���� ���������� ��5                       | Ilan_TrendRacing_3.51ME |
//              ������� ��� ��� ����� ������ �� ��� ������ � �������� ��������       |      Light Edition      |
//                ����� ��������� ��� ������ ��������� ��������� ����������          |                         |
//=============================================================================================================|

// -----------  ... ����� ������ � ��������������� ������ ��� ���� ������ ���� ������� �������� �������� ��������� 
// ������....  ���� ��� �� ����� - ��������� ))   

// � ������ ���� ����� :

//                   ============== �������� �������������� ===================
// �������� �������� �� ����� ������ ������������ ��.
// ������������� - ��������������,      � ��������� �������� ����� ���������� ������ ( ����� ���������).
// ������� ���������� - ��������������, � ��������� �������� ����� ���������� ������ ( ����� ���������).
// ������� ����������� �������������� �������� � ��������� �������� ����� ���������� ������ ( ����� ���������).
// ����������� ���������� ���������� ����������� ( ����� ������� ���������� ������ �� ������������� ��������� ). 
// ���������� ������� � ��������� ���������� ����������� �� ���������� ������.
// ������ �������������  ����  �����������������  �����,  ������� ������ ������� ������ ������������, � �����������
// ���� ��������� �������.
// ������������� ���������� ����������� MA, CCI, ADX, AC � ����������� ���� ����������, � ������� �������� ��������
// �� ������� ���������� ( ��������� ��������� ����� �������� � ���� ).
// ������������� �����������������  ���������� MAonRCI �  ������� �������� �������� �� ������� ���������� ( ������ -
// ��� ��������� � ���� ).

//                   ===================  ��������   ===========================
// ��������� ������������� � ������ ����� �� �����, ��� �������, ����  �� ������� ��������� ������ ���� ( �������� -
// ������ �������� ������� �������� � ���������� ������� ( �� �����, ����� �� ��������� )).
// �������������� �������� ������� �������� �������, ���� ������� ����� ������� �� ���� ( �� �����, �� ��������� ).
// ������� ����������� ������ ��������� �� ���� ������� �� �����������.
// �������������� ���������� ����������� ��� ������ ����������� ������ ����� �������.
// ���������� ������������, ���������� � ��������� ������, ���������� ������ �� �� ����������� � ������������� ��  -
// ����� ������������ �� � �� ( �� �� ������������, ������� ��� ���������� ������� ).
// ������������ �� ��������, ��������� ���� ���������� ������ �� ��� � ���� �����.
// ����������� ������� ��� ��������������� ��������� ( �� ������ - ��������� �� �����).
// ��������� ��������� � ������������ ������������ � ���� ����������� ���� � ������� ������������ �������� � � ��� -
// ��� ���������� �������� ���� �������. 
// ����������� ����������� ���������� ����� ������� ��� ������������ ������������� ������ �������� � % �� ��������.

//                   ================= ����� � ������ ===========================
// �������������� ���� ������ ��������� ��� ��������� ������ � �������� ���������.
// ���������� ��������� �������� ������� �� ���������� ������������ ����� ��������� ������ ��� ��������.
// ���������� ��������� ���������� ������� � ���� ��������� ������ ��� ��������.
// �������� ���� �� ���������� MAonRSI, � ����������� ���� ��������� ����������� ����� ��.
// �������� ���� ��������� ����� �� �������� � ������� ������ ( �� ���������� ��������� ). ( ��� ��������� ��������� ).

//                  ================ ��� ���������������� ========================
// �� ���� ���������� �������� � ���������� ������� ���� for ������� �� ���� while, ������� �������, �� ����� ��������
// ��� ��� ������� � ����� ������ � �������� ����������  )))...

#property copyright "ZzLiSzZ, MT5 Forum"
#property link      "oookompas2010@rambler.ru"
#include <stderror.mqh>
#include <stdlib.mqh>
#include <WinUser32.mqh>
//==============================================================================================================
extern string  Set1           = "======  ����� ���������  =====";
extern double  Lots           = 0.01;                         // �������� ������� ����
extern double  LotExponent    = 1.4;                          // ����������� �������������� ���������� ����� ������ ����
extern double  TakeProfit     = 8.0;                          // ������ � �������
double         StopLoss       = 0;                            // ���� � �������
extern double  slip           = 5;                            // ��������������� ���� ( ������ � �������� ) ))
extern int     MaxTrades      = 30;                           // ���������� ����������� ����������� ������� ( ���� �� "0" )
extern int     MagicNumberB   = 777;                          // �������������, ����������� �������� "����" ������ �� ����� ���
extern int     MagicNumberS   = 555;                          // �������������, ����������� �������� "����" ������ �� ����� ����
extern string  Set2           = "===== ���������  �������� =====";
extern string  Set3           = " �� �������� ������� ��������� ";
extern double  FirstPipStep   = 6.0;                          // ��������� �������
extern double  LongPipStep    = 100;                          // �������, ������������ ��� ������� ����������, ��� ���������� EconomProfil ������� �� FirstEconomOrd
extern double  PipStepExponent= 1.8;                          // �� ������� ������������� ��� � ����������� �� ������ ������
extern string  Set4           = "== �������������� ���������  ==";
extern bool    info           = True;                         // ����������� ����������
extern bool    Zero           = True;                         // ����������� ������ ��������� ���� ������� �� �����������
extern bool    BarControl     = True;                         // ���������� ��������� ��������
extern bool    debug          = False;                        // �������
extern bool    EconomProfil   = False;                        // ����� ��� ���������� ���������� 
extern int     FirstEconomOrd = 4;                            // �����, � �������� ���������� ����������� �����. ��������, ���� 4, �� 4, 5, 6 ... ������ ����� 1 � ��� �� ���.
extern bool    Overlapping    = True;                         // ��������� ������ ���������� ��������� ������� ���������� ������
extern int     LeadingOrder   = 4;                            // � ������ ������ �������� ����������.
extern int     FLPersent      = 7;                            // ������� ���������� 

//            Tral
extern bool   UseTrailingStop = true;
extern double TrailTP = 5;          // ��, ������� ����� ����������     
extern double TrailDist = 5;        // ���������� �� ����, �� ������� �������� ��
extern int    AutoTakeProfit = 50;  // �� ��� TrailingStop

//**********************
extern string v1 = "����� LastTP";
extern bool   SeparateLastTP = true;
extern int    LastTP  = 5;         //�� ���������� ������. ���� "0", �� LastTP = TakeProfit
extern int    LastTPNo = 3;         //� ������, � �������� �������� �������� LastTP
int ExcludeTicketB=0;
int ExcludeTicketS=0;

extern string  MASet          = "======== ���������  �� ========";   
int            MATimeFrame    = 0;                            // 0 (����)- ������ �������� �������; 1 - PERIOD_M1; 5 - PERIOD_M5; 15 - PERIOD_M15; 30 - PERIOD_M30;  
                                                              // 60 - PERIOD_H1; 240 - PERIOD_H4; 1440 - PERIOD_D1; 10080 - PERIOD_W1; 43200 - PERIOD_MN1 
extern int     MA1_Period     = 7;                            // ������ ������� ��
int            MA1_Shift      = 0;                            // �����  ������� ��
extern int     MA2_Period     = 21;                           // ������ ��������� ��
int            MA2_Shift      = 0;                            // �����  ��������� ��
extern string  DeltaSet       = "== ���� ������������ ������� ==";
extern string  Comm1          = " �������� ����� � ������, 0 - 5";
extern double  DelFX          = 2;                            // ������� ������� �� "�� ���������"
int            MA_sf          = 1;                            // ����� "����-����" ��� ����� ����������� ������
extern string  Comm5          = "=== ������� �������� �� CCI ===";
extern bool    CCI_kontr      = True;                         // ��������� �������� CCI
extern double  CCI_Lim        = 170.0;                        // ������� �� ������� CCI
int            CCI_tf         = 0;                            // ���� ����� CCI 0 - �������
int            CCI_Per        = 14;                           // ������ CCI
int            CCI_sf         = 1;                            // ����� "����-����" ��� ����� ��������� CCI
extern string  Comm6          = "= ��������� ������������� ������ =";
extern string  Comm7          = "===========   �� ADX    ==========";
extern bool    ADX_kontr      = False;  
int            TF_ADX         = 0;                            // ��������� ADX, 0 - �������
int            Per_ADX        = 7;                            // ������ ADX
extern double  ADX_Trend      = 25;                           // ���������� �������� ����� ADX 
int            PriceADX       = 0;                            // 0 - ���� ��������, 1 - ���� ��������
int            Sh_ADX         = 1;                            // ����� "����-����" ��� ����� ��������� ADX ( �� ����� ���� 0! )
extern string  Comm8          = "=== ��������� ����� �� MAonRSI ===";
extern string  Comm9          = " (��������� ���������� ����������)";
extern bool    MAonRSI        = False;
int            MAonRSI_TimeFr = 0;                            // �� ���������� MAonRSI ( �� ��������� - ������� )
extern int     RSI_Period     = 8;                            // ������ ���������� RSI
int            RSI_Metod      = 6;                            // ����� ������� ���� RSI
extern int     MA_Period      = 21;                           // ������ �� ���������� MAonRSI
int            MA_Metod       = 1;                            // ����� ������� ���� ��
double         Delta_MAonRSI  = 2.0;                          // ���� ������������������ ���������� ( 0 - 5 )
extern int     RSI_max        = 70;                           // ������� ������� RSI
extern int     RSI_min        = 30;                           // ������  ������� RSI
extern string  Comm10         = "= ��������� ������� ����� �� ��=";
extern double  AClim          = 0.0001;                       // ������ �� �� ���� �� ����� ��� ���������� �������� �� �������� ������� ������
extern string  Comm11         = "== ������, ��������, �������� ==";
extern bool    CloseAll       = False;                        // ������� ����������� �������� ���� "�����" �������
extern double  TradeStop      = 0.0;                          // ������ �������� ����� ������, ���� ��������� ��������/������ ������ ���������� (0.1 - 10% � ��� �����.. )
extern bool    LL             = False;                        // ��������� �������� ������  �� �������� 
extern int     LossLevel      = 10;                           // ������� ������ � ������� ������

int MA1_Price   = 0;             //0 - ���� ��������;  1 - ���� ��������; 2 - ������������ ����; 3 - ����������� ����;
                                 //4 - ������� ����; 5 - �������� ����; 6 ���������� ���� ��������.
                                          
int MA1_Method  = 0;             //0 - ������� ���������� �������; 1 - ���������������� ���������� �������; 
                                 //2 - ���������� ���������� �������; 3 - �������-���������� ���������� �������.
int MA2_Price   = 0;
int MA2_Method  = 0;
//==============================================================================================================
double StopperB    = 0.0, StopperS = 0.0;
double CCI_Del, ADX_Del, STOP_L, Lprofit, Profit_B, Profit_S, Cprofit;
double LastBuyPrice, LastSellPrice, PipStepB, PipStepS, iLotsB, iLotsS, SL,TP, PrevEquity, CCI_min, CCI_max, ACmax, ACmin, Dig;
double CProfit = 0, CProfit2 = 0, LProfit = 0, PrcCL1 = 0, PrcCL = 0;

bool flagB, flagS;
bool LongTrade = False, ShortTrade = False, NewOrdersPlacedB = True, NewOrdersPlacedS = True;

int timeprev = 0, NumOfTradesB = 0, NumOfTradesS = 0, cnt = 0, DCCoef = 10000;
int ticket, expiration, totalB, totalS, total, CheckTotalS, CheckTotalB, lotdecimal, Error, Lpos, StopSet, Cpos;
string title="�������� ����������", msg="";
string EAName = "Ilan_TrendRacing_3.51ME";
string txt1, txt2, txt3, txt4, txt5, txt6;
//==============================================================================================================
int init() {
   StopSet = 0;
   NewOrdersPlacedB = True;              // ������������� �� ��������� �� ���� ������� �������� ������� ���������
   NewOrdersPlacedS = True;
   ACmax = AClim;
   ACmin = (-AClim);
   CCI_max = CCI_Lim;
   CCI_min = (-CCI_Lim);
   Dig = MarketInfo(Symbol(), MODE_DIGITS);
   lotdecimal = MathLog(1/MarketInfo(Symbol(),MODE_LOTSTEP))/MathLog(10);
   if (debug) Print ("�������� �� ", Dig);
   if (info) {
      ObjectCreate ("Lable1",OBJ_LABEL,0,0,1.0);
      ObjectSet    ("Lable1", OBJPROP_CORNER, 2);
      ObjectSet    ("Lable1", OBJPROP_XDISTANCE, 23);
      ObjectSet    ("Lable1", OBJPROP_YDISTANCE, 11);
      txt1="Trend Racing 3.51ME";
      ObjectSetText("Lable1",txt1,20,"Bauhaus 93",FireBrick);
   
      ObjectCreate ("Lable4",OBJ_LABEL,0,0,1.0);
      ObjectSet    ("Lable4", OBJPROP_CORNER, 2);
      ObjectSet    ("Lable4", OBJPROP_XDISTANCE, 250);
      ObjectSet    ("Lable4", OBJPROP_YDISTANCE, 8);
      txt4="    LiS";
      ObjectSetText("Lable4",txt4,20,"Vladimir Script",AliceBlue);
   }
    
    if ((DelFX < 1)||(DelFX > 5))   StopSet = 1;
    if ((MA_sf > 5)||(MA_sf <= 0))  StopSet = 2;
    if (MA1_Period >= MA2_Period)   StopSet = 3;
    
    int DcD = 1;
    if((Digits==5)||(Digits==3)) DcD = 10;   
       FirstPipStep  = FirstPipStep  * DcD;
       LongPipStep   = LongPipStep   * DcD;
       TakeProfit    = TakeProfit    * DcD;
       StopLoss      = StopLoss      * DcD;
       slip          = slip          * DcD;
      AutoTakeProfit *= DcD;
      TrailTP    *= DcD;              
      TrailDist  *= DcD;
      LastTP *= DcD;
//*****************���������� �� ��� ��������� ������
   if (UseTrailingStop) TakeProfit = AutoTakeProfit;
   //*****************����� �� ��� ���������� ������
   if (SeparateLastTP && LastTP == 0) LastTP=TakeProfit;
      
    if(Digits==3)DCCoef = 500;
    if(Digits==2)DCCoef = 50;
    return (0);
}
int deinit() {
    ObjectDelete("Lable1");
    ObjectDelete("Lable2");
    ObjectDelete("Lable3");
    ObjectDelete("Lable4");
    ObjectDelete("Lable5");
    ObjectDelete("Zero");
    ObjectDelete("LableB");
    ObjectDelete("LableS");
   return (0);
}
//================================================================================================================
//============================================= S T A R T ========================================================
int start()
{  
   if (UseTrailingStop) 
   {
      Trailing (TrailDist, TrailTP, MagicNumberB);
      Trailing (TrailDist, TrailTP, MagicNumberS);
   }   

   STOP_L = NormalizeDouble(MarketInfo(Symbol(),MODE_STOPLEVEL),Dig);
   if (debug) Print ("������� ������� ������ �� �� ������� ����������� ", STOP_L);
   if (TakeProfit < STOP_L)                    StopSet = 4; 
   if ((StopLoss !=0) && (StopLoss < STOP_L )) StopSet = 5; 

//============================================   ������  ==========================================================   
   double Balans   = NormalizeDouble(AccountBalance(),Dig);
   double Sredstva = NormalizeDouble(AccountEquity() ,Dig); 
   double KontrSr  = NormalizeDouble(Sredstva/Balans,1);
   if (KontrSr <= TradeStop) StopSet = 6;

//========================================= ���� !!! ������� ���  !!!  ===========================================   
   if (CloseAll) StopSet = CloseThisSymbolAll();
//================================= �������� ������ �� �������� � ������� ������ =================================
   if (LL) {                                  
      double LB = ProfitB(); 
      double LS = ProfitS();
      double L  = (- LossLevel);
      if (LB < L) CloseThisSymbolBUY ();
      if (LS < L) CloseThisSymbolSELL();
   }   
//====================================  �������� �������� ������� ================================================
   total  = CountTrades();
   totalB = CountTradesB();
   totalS = CountTradesS();
   if (CheckTotalB != totalB) NewOrdersPlacedB = True;
   if (CheckTotalS != totalS) NewOrdersPlacedS = True;
   if (NewOrdersPlacedB) RecalculationB();
   if (NewOrdersPlacedS) RecalculationS();
   PipStepB = NormalizeDouble(FirstPipStep * MathPow(PipStepExponent, totalB), 0);
   PipStepS = NormalizeDouble(FirstPipStep * MathPow(PipStepExponent, totalS), 0);
   if (debug) {
      Print("������� ������� ��� ",  PipStepB);
      Print("������� ������� ���� ", PipStepS);
   }   
   iLotsB = NormalizeDouble(Lots, lotdecimal); 
   iLotsS = NormalizeDouble(Lots, lotdecimal); 
   NumOfTradesB = totalB;
   NumOfTradesS = totalS;
// ============================== �������� �������� ������� ��� ������ ������ ==================================
   if (EconomProfil) {
      if (totalB >= FirstEconomOrd) {
         PipStepB = LongPipStep;
         NumOfTradesB = FirstEconomOrd-1;
      }
      if (totalS >= FirstEconomOrd) {
         PipStepS = LongPipStep;
         NumOfTradesS = FirstEconomOrd-1;
      }   
   }   
//===================================  ����� �� ��������� ������  ==============================================
   if (total > 0 && total <= MaxTrades) {
      LastBuyPrice  = FindLastBuyPrice();
      LastSellPrice = FindLastSellPrice();
   }
   if ((totalB + totalS) >= MaxTrades)  { 
      Print ("���������� ����������� ����������� ����� ������, "); 
      Print ("����� ������ ����������� �� �����, ������������� ����� ������������."); 
   }   
   if (totalB < 1) LongTrade = FALSE;
   if (totalS < 1) ShortTrade = FALSE;

//========================================== ������ ��������� ��������� ========================================== 

   if ((StopSet==1)||(StopSet==2)||(StopSet==3)||(StopSet==4)||(StopSet==5)||(StopSet==6)||(StopSet==7)) {
      if (StopSet == 1) msg=" �������� ������ �������� DelFX,DelFX   "+"\n"+" ����� ���� ����� �� 1 �� 5.   ";
      if (StopSet == 2) msg=" ������� ������ �������� ���� ���       "+"\n"+" ������� �������� ������ �� �� "+"\n"+
                            " ������� �������� MA_sf �� 0 �� 5.";
      if (StopSet == 3) msg=" ������� ������ ��������� ��, ��_1Period"+"\n"+" �� ����� ���� ������ ���� ����� MA2_Period.";
      if (StopSet == 4) msg=" ���������� �� ����� ���� ���������     "+"\n"+" ������ ���� ������� ��.";  
      if (StopSet == 5) msg=" �������� �� ����� ���� ���������       "+"\n"+" ������ ���� ������� ��.";  
      if (StopSet == 6) msg=" �������� ���������� ������� ��������   "+"\n"+" �������. ";  
      if (StopSet == 7) msg=" �������� ����������, ��� ������ �������"+"\n"+" �� ���������� ������������. "; 
      int ret = MessageBox(msg,title,MB_OK|MB_ICONSTOP); 
      if (ret == IDOK) {
      Print ("�������� ���������� ������������� ��� �������������"); 
      return (0); 
      }   
   }

//========================================== ����������� ������� ������ ==========================================    
   int TPControlS = OrderTake_ProfitS();
   int TPControlB = OrderTake_ProfitB();
   if (TPControlS == 1 ) NewOrdersPlacedS = True;
   if (TPControlB == 1 ) NewOrdersPlacedB = True;
   int SignalMA  = 0;
   int SignalCCI = 0;
   int SignalADX = 0; 
   int SignalRSI = 0;
   int SignalAC  = 0;
   int Signal = 0;
//============================================= ������ ����� ======================================================  
   if (MAonRSI) { 
      CCI_kontr = False; ADX_kontr = False; 
      SignalRSI = MAonRSI();  SignalAC  = AC();                                   // ��������� ���, ����� MAonRSI � ��
      if ((SignalRSI == 1) && (SignalAC ==1)) Signal =  1;                        // ��������� ���
      if ((SignalRSI ==-1) && (SignalAC ==1)) Signal = -1;                        // ��������� ����
   }   
   if ((!CCI_kontr) && (!ADX_kontr)&& (!MAonRSI)) {                               // CCI �������� ��������, ADX �������� ��������
      SignalMA  = MA(); SignalAC  = AC();
      if ((SignalMA == 1) && (SignalAC ==1)) Signal =  1;                         // ��������� ���
      if ((SignalMA ==-1) && (SignalAC ==1)) Signal = -1;                         // ��������� ����
   } 
   if ((CCI_kontr) && (!ADX_kontr))  {                                            // CCI �������� ������� ADX �������� ��������
      SignalMA  = MA(); SignalCCI = CCI(); SignalAC  = AC();
      if ((SignalMA == 1) && (SignalCCI == 1) && (SignalAC ==1)) Signal =  1;     // ��������� ���
      if ((SignalMA ==-1) && (SignalCCI ==-1) && (SignalAC ==1)) Signal = -1;     // ��������� ����
   }
   if ((!CCI_kontr) && (ADX_kontr))  {                                            // CCI �������� ��������, ADX �������� �������
      SignalMA  = MA(); SignalAC  = AC(); SignalADX = ADX();
      if ((SignalMA == 1) && (SignalAC ==1) && (SignalADX ==1))  Signal =  1;     // ��������� ���
      if ((SignalMA ==-1) && (SignalAC ==1) && (SignalADX ==1))  Signal = -1;     // ��������� ����
   }   
   if ((CCI_kontr) && (ADX_kontr))   {
      SignalMA  = MA(); SignalCCI = CCI(); SignalAC  = AC(); SignalADX = ADX();
      if ((SignalMA == 1) && (SignalCCI == 1) && (SignalAC ==1) && (SignalADX ==1)) Signal =  1;     // ��������� ���
      if ((SignalMA ==-1) && (SignalCCI ==-1) && (SignalAC ==1) && (SignalADX ==1)) Signal = -1;     // ��������� ����
   }
   
//=============================================== ���� ============================================================
    if (info) {
    ObjectDelete("Lable2");
    ObjectCreate("Lable2",OBJ_LABEL,0,0,1.0);
    ObjectSet   ("Lable2", OBJPROP_CORNER, 3);
    ObjectSet   ("Lable2", OBJPROP_XDISTANCE, 33);
    ObjectSet   ("Lable2", OBJPROP_YDISTANCE, 11);
      if (Signal ==  1)txt2="Maneuver  BUY";
      if (Signal == -1)txt2="Maneuver SELL";
      if (Signal ==  0)txt2="Pit stop...";
    ObjectSetText("Lable2",txt2,14,"Fixedsys",FireBrick);
    ObjectDelete ("Lable3");
    ObjectCreate ("Lable3",OBJ_LABEL,0,0,1.0);
    ObjectSet    ("Lable3", OBJPROP_CORNER, 0);
    ObjectSet    ("Lable3", OBJPROP_XDISTANCE, 23);
    ObjectSet    ("Lable3", OBJPROP_YDISTANCE, 20);
    txt3= DoubleToStr (MarketInfo(Symbol(), MODE_SPREAD),0);
    ObjectSetText("Lable3","������� ����� "+txt3+"",14,"Fixedsys",FireBrick);
    }
//=========================================== ���� ������� ======================================================
   if (info) {
      txt5 = DoubleToStr ((LastBuyPrice  - PipStepB * Point), Dig);
      txt6 = DoubleToStr ((LastSellPrice + PipStepS * Point), Dig);
      if (!LongTrade)  txt5 = "--"; 
      if (!ShortTrade) txt6 = "--"; 
      ObjectDelete ("LableB");
      ObjectCreate ("LableB",OBJ_LABEL,0,0,1.0);
      ObjectSet    ("LableB", OBJPROP_CORNER, 0);
      ObjectSet    ("LableB", OBJPROP_XDISTANCE, 23);
      ObjectSet    ("LableB", OBJPROP_YDISTANCE, 40);
      ObjectSetText("LableB","����. ������ Buy  "+txt5+"",14,"Fixedsys",Blue);  
         
//                         --------------------------------------------

      ObjectDelete ("LableS");
      ObjectCreate ("LableS",OBJ_LABEL,0,0,1.0);
      ObjectSet    ("LableS", OBJPROP_CORNER, 0);
      ObjectSet    ("LableS", OBJPROP_XDISTANCE, 23);
      ObjectSet    ("LableS", OBJPROP_YDISTANCE, 60);
      ObjectSetText("LableS","����. ������ Sell "+txt6+"",14,"Fixedsys",FireBrick);  
   }   
//========================================== ���� ���� =========================================================
   if (Zero) {
      double ZeroLevel = Zerro();
      ObjectDelete("Zero");
      ObjectCreate("Zero", OBJ_HLINE, 0, 0,ZeroLevel);
      ObjectSet   ("Zero", OBJPROP_COLOR, DodgerBlue);
      ObjectSet   ("Zero", OBJPROP_WIDTH, 1);
      ObjectSet   ("Zero", OBJPROP_RAY, False);
      }    
//====================================    ����������� ������    ================================================
  if ((totalB >= LeadingOrder) || (totalS >= LeadingOrder)) {
     if(Overlapping) {
       Lpos = 0; Cpos = 0; Lprofit = 0; Cprofit = 0;
       Lpos = LidingProfitOrder();
       Cpos = CloseProfitOrder();
       if (debug) {
          Print ("���������� ������ ", Lprofit,"  ", Lpos);
          Print ("���������� ������ ", Cprofit,"  ", Cpos);
       }    
       Cprofit  = MathAbs(Cprofit);
       PrcCL1 =  (Cprofit + Cprofit * FLPersent/100);
       if(Lprofit > PrcCL1) {
          CloseSelectOrder(); 
          
        }
     }  
  }  
//===================================  ���������� ����������� �����  =============================================   
   if  (total == 0) {
       flagB = False;
       flagS = False;
   }    
   for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
       if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) {
          if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberB) {
          if (OrderType() == OP_BUY) {
             LongTrade = TRUE;
             break;
          }
       }
       if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberS) {
          if (OrderType() == OP_SELL) {
             ShortTrade = TRUE;
             break;
          }
       }
     } 
   }

//=========================================== �������� ������� =================================================
   CheckTotalB = totalB;  
   CheckTotalS = totalS;
//===================================  �������� ��������  ======================================================
   if ((BarControl)&&(timeprev == Time[0])) return (0);
   timeprev = Time[0];
//=========================================== �������� ������ ==================================================
   if (total > 0 && total <= MaxTrades) {
      if (LongTrade) {
         if ((NormalizeDouble((LastBuyPrice - Ask)/Point, 0)) >= PipStepB) {
            iLotsB = NormalizeDouble(Lots * MathPow(LotExponent, NumOfTradesB), lotdecimal);
         
            ticket = OPENORDER ("Buy");
            if (ticket < 0) {
               BarControl  = False;
               return (0);
            }
            NewOrdersPlacedB = True;
            BarControl  = True;
         }
      }
   }   
//========================================== ������� ������ ===================================================
      
   if (total > 0 && total <= MaxTrades) {   
      if (ShortTrade) {
         if ((NormalizeDouble((Bid - LastSellPrice) / Point, 0))>=PipStepS ) {
            iLotsS = NormalizeDouble(Lots * MathPow(LotExponent, NumOfTradesS), lotdecimal);
         
            ticket = OPENORDER ("Sell");
            if (ticket < 0) {
               BarControl  = False;
               return (0);
            }
            NewOrdersPlacedS = True;
            BarControl = True;
         }
      }
   }     
//================================================================================================================
     if ((Signal == 0 ) && (total ==0 )) {
        if (debug)      {
           Print ("��� ������� �� �������� ������� ");
           return (0);                                    // ���� �� ��������... ����..
        }
     }      
//============================================== �������� 1 ����� ==============================================
     if ((Signal == 1) && (totalB == 0)) {  
                       
          ticket = OPENORDER ("Buy");
          if (ticket < 0) {
          BarControl  = False;
          return (0);
          }
          BarControl = True;
     }
//=============================================== ������� 1 ����� ================================================     
     if ((Signal == -1)&&(totalS == 0)) {                       
                                 
        ticket = OPENORDER ("Sell");
        if (ticket < 0) {
           BarControl  = False;
           return (0);
        }
        BarControl = True;
     }    

  return (0);
}
//===================================  ������������� ��  ��� �������  =========================================

void RecalculationB() {
 double AveragePriceB = 0;
 double PriceTargetB  = 0;
 double CountB  = 0;
   for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
       if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))  {
          if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberB) {
             if (OrderType() == OP_BUY ) {
                AveragePriceB += OrderOpenPrice() * OrderLots();
                CountB += OrderLots();
             }
          }
       }  
   }
   if (totalB > 0) AveragePriceB = NormalizeDouble(AveragePriceB / CountB, Dig);
   if (NewOrdersPlacedB) {
      for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
          if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) {
             if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberB) {
                if (OrderType() == OP_BUY) {
                   PriceTargetB = AveragePriceB + TakeProfit * Point;
                   StopperB = AveragePriceB - StopLoss * Point;
                   flagB = TRUE;
                }
             }
          }
      }
   }  
   if (NewOrdersPlacedB) {
      if (flagB == TRUE) {
         for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
             if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) {        
                if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberB) {
                   if (OrderType() == OP_BUY ) {
                      bool res;
                      if(SeparateLastTP && totalB >= LastTPNo && OrderTakeProfit() == 0.0)
                        res = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble( OrderOpenPrice() + LastTP * Point, Dig), 0, Blue);
                      else
                        res = OrderModify(OrderTicket(), AveragePriceB, OrderStopLoss(), PriceTargetB, 0, Blue);
                      if(res)
                        NewOrdersPlacedB = FALSE;
                   }
                }
             }  
         }
      }
   }
 }

//===================================  ������������� ��  ���� �������  ========================================
void RecalculationS() {
   double AveragePriceS = 0;
   double PriceTargetS  = 0;
   double CountS  = 0;
   for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
     if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))  {
       if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberS) {
          if (OrderType() == OP_SELL ) {
             AveragePriceS += OrderOpenPrice() * OrderLots();
             CountS += OrderLots();
           }
        }
      }  
    }
   if (totalS > 0) AveragePriceS = NormalizeDouble(AveragePriceS / CountS, Dig);
   if (NewOrdersPlacedS) {
      for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
          if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) {
             if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberS) {
                if (OrderType() == OP_SELL) {
                   PriceTargetS = AveragePriceS - TakeProfit * Point;
                   StopperS = AveragePriceS + StopLoss * Point;
                   flagS = TRUE; 
                }
             }
          }
      }
   }  
   if (NewOrdersPlacedS) {
      if (flagS == TRUE) {
         for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
            if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) {        
               if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberS) {
                  if (OrderType() == OP_SELL) {
                     bool res;
                     if(SeparateLastTP && totalS >= LastTPNo && OrderTakeProfit() == 0.0)
                        res = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(),  NormalizeDouble( OrderOpenPrice() - LastTP * Point, Dig), 0, Red);
                     else
                        res = OrderModify(OrderTicket(), AveragePriceS, OrderStopLoss(), PriceTargetS, 0, Red);
                     if(res)
                        NewOrdersPlacedS = FALSE;
                 }
               }
            }  
         }
      }
   }
 }
//============================   ������������ ��� ������   ====================================================
int CountTrades() {
   int count = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
       if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
         if ((OrderSymbol() == Symbol()) && ((OrderMagicNumber() == MagicNumberB) || (OrderMagicNumber() == MagicNumberS))){
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) { count++;} }
        }
     }
   return (count);
}

//============================   ������������ ��� ������   ====================================================
int CountTradesB() {
   int count = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
       if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberB){
         if (OrderType() == OP_BUY) { count++;} }
        }
     }
   return (count);
}   
//============================   ������������ ���� ������   ====================================================
int CountTradesS() {
   int count = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
       if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberS){
         if (OrderType() == OP_SELL ) { count++;} }
        }
     }
   return (count);
}   


//========================================   �������� ����  ������ �������  ====================================
int CloseThisSymbolAll() {
   
   int Result = 0;
   int error  = 0;
   int trade  = 0;
       while (OrdersTotal() > 0) {
             RefreshRates();
             trade = OrdersTotal()-1;
             OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);   
             if (OrderSymbol() == Symbol()) {
                if (OrderType() == OP_SELL) { 
                   error = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Dig), slip, Red );
                   if (error == -1) ShowERROR(error,0,0);
                }   
                Sleep(500);
                if (OrderType() == OP_BUY)  {
                   error =  OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Dig), slip, Blue);
                   if (error == -1) ShowERROR(error,0,0);
                }   
                Sleep(500);
             }   
       }
   if (OrdersTotal() == 0) Result = 7;
   if (debug) Print ("������ �� ����������� ������� �������.");
   return (Result);
}
//========================================   �������� ��� �����   ============================================
int CloseThisSymbolBUY() {
   
   int Result = 0;
   int error  = 0;
   int trade  = OrdersTotal()-1;
   int i = CountTradesB();
       while (i > 0) {
             RefreshRates();
             OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);   
             if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == MagicNumberB)) {
                if (OrderType() == OP_BUY)  {
                   error =  OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Dig), slip, Blue);
                   if (error == -1) ShowERROR(error,0,0);
                }   
                Sleep(500);
             }
             trade --;  
             i = CountTradesB(); 
       }
   if (i == 0) Result = 1;
   Print ("����� ��� ������� �� ���������� ������������.");
   return (Result);
}

//========================================   �������� ���� �����   ============================================
int CloseThisSymbolSELL() {
   
   int Result = 0;
   int error  = 0;
   int trade  = OrdersTotal()-1;
   int i = CountTradesS();
       while (i > 0) {
             RefreshRates();
             OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);   
             if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == MagicNumberS))  {
                if (OrderType() == OP_SELL)  {
                   error =  OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Dig), slip, Red);
                   if (error == -1) ShowERROR(error,0,0);
                }   
                Sleep(500);
             }
             trade --;
             i = CountTradesS();   
       }
   if (i == 0) Result = 1;
   Print ("����� ���� ������� �� ���������� ������������.");
   return (Result);
}

//====================================== ����������� ������� ===================================================
int OPENORDER(string ord)
{
   int error;
 
   if (ord=="Buy"   ) error=OrderSend(Symbol(),OP_BUY,  iLotsB, NormalizeDouble (Ask,Dig), slip, 0, 0, "Ilan_TrendRacing_3.51ME",MagicNumberB,5,Blue);
   if (ord=="Sell"  ) error=OrderSend(Symbol(),OP_SELL, iLotsS, NormalizeDouble (Bid,Dig), slip, 0, 0, "Ilan_TrendRacing_3.51ME",MagicNumberS,5,DeepPink);
   if (error==-1)   ShowERROR(error,0,0);
return (error);
}                  
//====================================== ������ ��� �������� ������� ===========================================
void ShowERROR(int Ticket,double SL,double TP)
{
   int err=GetLastError();
   switch ( err )
   {                  
      case 1:                                            return;
      case 2:    Print("��� ����� � �������� �������� ",                           Ticket," ",Symbol());return;
      case 3:    Print("������������ �� ����� ���������� ������� ",                Ticket," ",Symbol());return;
      case 129:  Print("������������ ���� ",                                       Ticket," ",Symbol());return;
      case 130:  Print("������� ����� Ticket ",                                    Ticket," ",Symbol());return;
      case 131:  Print("������������ ����� ",                                      Ticket," ",Symbol());return;
      case 134:  Print("������������ ����� ",                                      Ticket," ",Symbol());return;
      case 136:  Print("��� ��� ... ",                                             Ticket," ",Symbol());return;
      case 138:  Print("���� �������� ",                                           Ticket," ",Symbol());return;
      case 146:  Print("���������� �������� ������ ",                              Ticket," ",Symbol());return;
      case 148:  Print("�������� ����� ���������� �������",                        Ticket," ",Symbol());return;
      case 147:  Print("������������� ���� ��������� ������ ��������� ��������",   Ticket," ",Symbol());return;
      case 4107: Print("������������ �������� ���� ��� �������� �������",          Ticket," ",Symbol());return;
      case 4109: Print("��������� ��������� ���������",                            Ticket," ",Symbol());return;
      default:   Print("������  " ,err,"   Ticket ",        Ticket," ",Symbol());return;
   }
}

//==================================  ������ ���� ������� ========================================================
double FindLastBuyPrice() {
   double oldorderopenprice;
   int oldticketnumber;
   double unused = 0;
   int ticketnumber = 0;
   for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberB && OrderType() == OP_BUY) {
         oldticketnumber = OrderTicket();
         if (oldticketnumber > ticketnumber) {
            oldorderopenprice = OrderOpenPrice();
            unused = oldorderopenprice;
            ticketnumber = oldticketnumber;
         }
       }
     } 
   }
   return (oldorderopenprice);
}

//==================================  ������ ���� ������� ======================================================
double FindLastSellPrice() {
   double oldorderopenprice;
   int oldticketnumber;
   double unused = 0;
   int ticketnumber = 0;
   for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
     if ( OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) {
       if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberS && OrderType() == OP_SELL) {
          oldticketnumber = OrderTicket();
          if (oldticketnumber > ticketnumber) {
            oldorderopenprice = OrderOpenPrice();
            unused = oldorderopenprice;
            ticketnumber = oldticketnumber;
          }
        }
      } 
    }
   return (oldorderopenprice);
}

//======================================== ����� � ���������� ��������  =======================================
int LidingProfitOrder() {
   double profit  = 0;
   int    Pos     = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
       if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
          if ((OrderSymbol() == Symbol()) && ((OrderMagicNumber() == MagicNumberB) || (OrderMagicNumber() == MagicNumberS))){
             if (OrderType() == OP_SELL || OrderType() == OP_BUY) { 
                profit = OrderProfit();
                Pos    = OrderTicket();
                if (profit > 0 && profit > Lprofit) {
                   Lprofit = profit;
                   Lpos    = Pos;
                }
             }
          }
       }   
   }    
   return (Lpos);
}
//======================================== ����� � ���������� ��������  =======================================
int CloseProfitOrder() {
   double profit  = 0;
   int    Pos     = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
       if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
          if ((OrderSymbol() == Symbol()) && ((OrderMagicNumber() == MagicNumberB) || (OrderMagicNumber() == MagicNumberS))){
             if (OrderType() == OP_SELL || OrderType() == OP_BUY) { 
                profit = OrderProfit();
                Pos    = OrderTicket();
                if (profit < 0 && profit < Cprofit) {
                   Cprofit = profit;
                   Cpos    = Pos;
                }
             }
          }
       }   
   }    
   return (Cpos);
}
//========================================= �������� ����������� �� ������� SELL ===================================

int OrderTake_ProfitS() 
{
   int TPResult = 0;
   int count = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
       if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
          if ((OrderSymbol() == Symbol()) && ((OrderMagicNumber() == MagicNumberB) || (OrderMagicNumber() == MagicNumberS))){
             if (OrderType() == OP_SELL)  { 
                if (OrderTakeProfit() == 0) TPResult  = 1;
                count++;
             }
          }
       }
   }    
   return (TPResult);
}
//====================================== �������� ����������� �� ������� BUY =========================================
int OrderTake_ProfitB() 
{
   int TPResult = 0;
   int count = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
       if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
          if ((OrderSymbol() == Symbol()) && ((OrderMagicNumber() == MagicNumberB) || (OrderMagicNumber() == MagicNumberS))){
             if (OrderType() == OP_BUY)  { 
                if (OrderTakeProfit() == 0) TPResult  = 1;
                count++;
             }
          }
       }
   }    
   return (TPResult);
}

//======================================== ��������� ����� ������ ��� �����  ======================================
double ProfitB() {
   Profit_B  = 0;
   double p  = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
       if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
          if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == MagicNumberB)) {
             if (OrderType() == OP_BUY) { 
                p = OrderProfit();
                Profit_B = (Profit_B + p);
             }
          }
       }   
   }    
   if (debug) Print ("������� ������ ��� ����� = ", Profit_B);
   return (Profit_B);
}
//======================================== ��������� ����� ������ ���� �����  ======================================
double ProfitS() {
   Profit_S  = 0;
   double p  = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
       if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
          if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == MagicNumberS)) {
             if (OrderType() == OP_SELL) { 
                p = OrderProfit();
                Profit_S = (Profit_S + p);
             }
          }
       }   
   }    
   if (debug) Print ("������� ������ ���� ����� = ", Profit_S);
   return (Profit_S);
}
//==================================== ���������� ������� ===================================================
int CloseSelectOrder()
{
//                       ----------- ��������� (������ ������ )------------
  int error =  0;
  int error1 = 0;
  int Result = 0;
      while (error == 0) {
            RefreshRates();
            int i = OrderSelect(Cpos, SELECT_BY_TICKET, MODE_TRADES);
            if  (i != 1 ) {
                Print ("������! ���������� ������� ����� � ���������� ��������. ���������� ���������� ��������.");
                return (0);
            }    
            if ((OrderSymbol() == Symbol()) && ((OrderMagicNumber() == MagicNumberB) || (OrderMagicNumber() == MagicNumberS))) {
               if (OrderType() == OP_BUY) {
                  error = (OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Dig), slip, Blue)); 
                  if (error == 1 ) {
                     Print ("������������� ����� ������ �������."); 
                     Sleep (500);   
                  } else {
                     Print ("������ �������� �������������� ������, ��������� ��������. ");
                     ShowERROR(error,0,0);
                  } 
               }        
//                             -------------------------------------                
               if (OrderType() == OP_SELL) {
                  error = (OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Dig), slip, Red));
                  if (error == 1) {
                     Print ("������������� ����� ������ �������."); 
                     Sleep (500);   
                  } else {
                     Print ("������ �������� �������������� ������, ��������� ��������. ");
                     ShowERROR(error,0,0);
                  }
               }
            }
      }     
       
//                       ---------------   ���������  ----------------                            
       
      while (error1 == 0) {
            RefreshRates();
            i = OrderSelect(Lpos, SELECT_BY_TICKET, MODE_TRADES);
            if  (i != 1 ) {
                Print ("������! ���������� ������� ����� � ���������� ��������. ���������� ���������� ��������.");
                return (0);
            }  
            if ((OrderSymbol() == Symbol()) && ((OrderMagicNumber() == MagicNumberB) || (OrderMagicNumber() == MagicNumberS))) {
               if (OrderType() == OP_BUY) {
                  error1 =  (OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Dig), slip, Blue));
                  if (error1 == 1) {
                     Print ("���������� ����� ������ �������."); 
                     Sleep (500);   
                  } else {
                     Print ("������ �������� ����������� ������, ��������� ��������. ");
                     ShowERROR(error1,0,0);
                  }      
               } 
//                      ---------------------------------------------               
               if (OrderType() == OP_SELL) {
                  error1 = (OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Dig), slip, Red));
                  if (error1 == 1) {
                     Print ("���������� ����� ������ �������"); 
                     Sleep (500);   
                  } else {
                     Print ("������ �������� ����������� ������, ��������� ��������. ");
                     ShowERROR(error1,0,0);
                  }
               }
            } 
      }
  Result = 1;
  return (Result);    
}  
//=================================   ������ �������� ������    =========================================
double Zerro()
{
 double BuyLots    = 0;
 double SellLots   = 0;
 double BuyProfit  = 0;
 double SellProfit = 0;
 double BuyLevel   = 0;
 double SellLevel  = 0;
 double Price      = 0;
 double ZeroLevel  = 0;
 double TickValue  = MarketInfo(Symbol(),MODE_TICKVALUE);
 double spread = NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD),Dig)*Point;
  
  for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
      if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
         if (OrderSymbol() == Symbol()) {
            if (OrderType()==OP_BUY)    {
               BuyLots   = BuyLots   + OrderLots();
               BuyProfit = BuyProfit + OrderProfit() + OrderCommission() + OrderSwap();
            }
            if (OrderType()==OP_SELL) {
               SellLots   = SellLots   + OrderLots();
               SellProfit = SellProfit + OrderProfit() + OrderCommission() + OrderSwap();
            }
         }
      }
  }
 
 if (BuyLots>0)  BuyLevel  = NormalizeDouble(Bid - (BuyProfit/(TickValue*BuyLots)*Point),Digits); 
 if (SellLots>0) SellLevel = NormalizeDouble(Ask + (SellProfit/(TickValue*SellLots)*Point),Digits); 
 if ((BuyLots-SellLots)>0) Price = NormalizeDouble(Bid + spread - ((BuyProfit+SellProfit)/(TickValue*(BuyLots-SellLots))*Point),Digits);
 if ((SellLots-BuyLots)>0) Price = NormalizeDouble(Ask - spread + ((BuyProfit+SellProfit)/(TickValue*(SellLots-BuyLots))*Point),Digits);
 if (Price >  0) ZeroLevel = Price;
 if (Price <= 0) ZeroLevel = 0;
 if (debug) Print ("������� ��������� ��� ���� ������� ��������� �� ������� = ", ZeroLevel); 
 return (ZeroLevel);
}

//============================== ������ �� ������� ��� ���������� 1 ������  =================================
int MA()
{
  int ResultMA = 0;                                                           // 0 - ��������� ������
  
  double MA1       = iMA(Symbol(), MATimeFrame, MA1_Period, MA1_Shift, MA1_Method, MA1_Price, 0); 
  double MA1_Pred  = iMA(Symbol(), MATimeFrame, MA1_Period, MA1_Shift, MA1_Method, MA1_Price, MA_sf);  
  double MA2       = iMA(Symbol(), MATimeFrame, MA2_Period, MA2_Shift, MA2_Method, MA2_Price, 0);
  double MARes     = MathAbs(MA1-MA2);
  double Del       = DelFX/DCCoef;       
        
      if ((MA1_Pred < MA1) && (MA1 > MA2) && (MARes > Del)) ResultMA =  1;    //�������� �� ���
      if ((MA1_Pred > MA1) && (MA1 < MA2) && (MARes > Del)) ResultMA = -1;    //�������� ����
 
  return (ResultMA);
} 
//==============================   ����������� ��� ��� ���������� 1 ������   ================================
   
int CCI()
{  
  int ResultCCI = 0;                                                          // ���� 0 ��������� ������
  double LevelCCI_0 = iCCI(Symbol(),CCI_tf,CCI_Per,0,0);                      // �������� ��� �� ������� ����
  double LevelCCI_1 = iCCI(Symbol(),CCI_tf,CCI_Per,4,CCI_sf);                 // �������� ��� �� ���������� ����
  CCI_Del = (LevelCCI_0 - LevelCCI_1);   
  if (debug) Print ("�������� �������� CCI ", CCI_Del);
      if ((LevelCCI_0 < CCI_min) || (LevelCCI_0 > CCI_max)) {
         ResultCCI = 0;
         return (ResultCCI);                                                  // ������� �� �������
      }   
      if (CCI_Del > 0) ResultCCI =  1;                                        // ��������� ��� 
      if (CCI_Del < 0) ResultCCI = -1;                                        // ��������� ����     
                   
  return (ResultCCI);
}  
//=================================== ������������� ������ �� ADX ===========================================
int ADX()
{
    int ResultADX  = 0;                                                        // ��������� ������
    double ADX0    = NormalizeDouble (iADX (Symbol(), TF_ADX, Per_ADX, PriceADX, 0,      0), 0);
    double ADX1    = NormalizeDouble (iADX (Symbol(), TF_ADX, Per_ADX, PriceADX, 0, Sh_ADX), 0);
    ADX_Del        = (ADX0 - ADX1);
    if (ADX_Del <= 0) {
       ResultADX = 0; 
       return (ResultADX);                                                     // ����� �� ��������� ��� ������, ��������� ������
    }
    
       if ((ADX_Del > 0) && (ADX0 > ADX_Trend)) {
       ResultADX = 1;                                                          // ����� ����, ��������� ������
       return (ResultADX);
    }  else { 
       ResultADX = 0;                                                          // ��, ����� - �� �����... ���������..
       return (ResultADX);
    }
}       

//======================================= ������ ������� �� MAonRSI =========================================

int MAonRSI() 
{
    int Result_MAonRSI = 0;
      
      double Ma0  = NormalizeDouble(iCustom(Symbol(), MAonRSI_TimeFr, "MAonRSI", RSI_Period, RSI_Metod, MA_Period, MA_Metod, 1, 0), 1);
      double Rsi0 = NormalizeDouble(iCustom(Symbol(), MAonRSI_TimeFr, "MAonRSI", RSI_Period, RSI_Metod, MA_Period, MA_Metod, 0, 0), 1);
      double Rsi1 = NormalizeDouble(iCustom(Symbol(), MAonRSI_TimeFr, "MAonRSI", RSI_Period, RSI_Metod, MA_Period, MA_Metod, 0, 1), 1);

       if ((Rsi0 > (Ma0 + Delta_MAonRSI)) && (Rsi0 > (Rsi1 + Delta_MAonRSI))) Result_MAonRSI =  1;       // �������� �� ���
       if ((Rsi0 < (Ma0 - Delta_MAonRSI)) && (Rsi0 < (Rsi1 - Delta_MAonRSI))) Result_MAonRSI = -1;       // �������� �� ����
       if ((Rsi0 > RSI_max) || (Rsi0 < RSI_min))            Result_MAonRSI =  0;       // ������ � ���������/�����������
      
   return (Result_MAonRSI);
}         

//======================================= ������� ����� �� �� ===============================================
int AC()                                 // ��������� �������� �� ������� ������� � ������� �����
{
    int ResultAC = 1;                                                         // ��������� ������
    double ACRes = NormalizeDouble (iAC (Symbol(), 0, 0),6);                  
    if ((ACRes >= ACmin) && (ACRes <= ACmax)) ResultAC = 0;                   // ��������� ������
    if (debug) Print ("�� ������ = ", ResultAC); 
    return (ResultAC);
} 

//+----------------------------------------------------------------------------+
//|  �����    : Night  http://www.instaforex-night.ru                          |
//|  �������� : �����                                                          |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|  Trail_TP -   ��, ������� ����� ����������                                 |
//|  Trail_Dist - ���������� �� ����, �� ������� �������� ��                   |
//+----------------------------------------------------------------------------+

void Trailing (int Trail_Dist, int Trail_TP, int magic)
//--------------------------------------------------------------- 1 --
{
   string Symb=Symbol();                        // ������. ����������
   double Aver = CalculateAveragePrice(magic);
//--------------------------------------------------------------- 2 --
   for(int i=1; i<=OrdersTotal(); i++)          // ���� �������� �����
     {
      if (OrderSelect(i-1,SELECT_BY_POS)==true) // ���� ���� ���������
        {                                       // ������ �������:
         int Tip=OrderType();                   // ��� ������
         if(OrderSymbol()!=Symb||Tip>1 || OrderMagicNumber()!= magic)continue;// �� ��� �����
         double SL=OrderStopLoss();             // SL ���������� ���.
         //------------------------------------------------------ 3 --
         while(true)                            // ���� �����������
           {
            double TS = Trail_Dist;                // �������� ��������
            double TD = Trail_TP;
            int Min_Dist=MarketInfo(Symb,MODE_STOPLEVEL);//�����. ����
            if (TS<Min_Dist)                    // ���� ������ ������.
               TS=Min_Dist;                     // ����� �������� TS
            //--------------------------------------------------- 4 --
            bool Modify=false;                  // �� �������� � ������
            switch(Tip)                         // �� ���� ������
              {
               case 0 :                         // ����� Buy
                if (Bid >= NormalizeDouble(Aver + (TD + TS)*Point, Digits))
                  {if (NormalizeDouble(SL,Digits)< NormalizeDouble(Bid-TS*Point,Digits)// ���� ���� ������.
                     || NormalizeDouble(SL,Digits)==0)
                    {
                     SL=Bid-TS*Point;           // �� ������������ ���
                     string Text="Buy ";        // ����� ��� Buy 
                     Modify=true;               // �������� � ������.
                    }
                  }
                  break;                        // ����� �� switch
               case 1 :                         // ����� Sell
                if (Ask <= NormalizeDouble(Aver -(TD + TS)*Point,Digits))
                  {if (NormalizeDouble(SL,Digits)>NormalizeDouble(Ask+TS*Point,Digits) // ���� ���� ������.                     
                     || NormalizeDouble(SL,Digits)==0)//��� ����� ����
                    {
                     SL=Ask+TS*Point;           // �� ������������ ���
                     Text="Sell ";              // ����� ��� Sell 
                     Modify=true;               // �������� � ������.
                    }
                  }
              }                                 // ����� switch
            if (Modify==false)                  // ���� ��� �� ������
               break;                           // ����� �� while
            //--------------------------------------------------- 5 --
            double TP    =OrderTakeProfit();    // TP ���������� ���.
            double Price =OrderOpenPrice();     // ���� �������. ���.
            int    Ticket=OrderTicket();        // ����� �������. ���.

            //Alert ("����������� ",Text,Ticket,". ��� �����..");
            bool Ans=OrderModify(Ticket,Price,SL,TP,0);//������ ���!
            //--------------------------------------------------- 6 --
            if (Ans==true)                      // ���������� :)
              {
               Alert ("����� ",Text,Ticket," �������������:)");
               break;                           // �� ����� ������.
              }
            //--------------------------------------------------- 7 --
            int Error=GetLastError();           // �� ���������� :(
            switch(Error)                       // ����������� ������
              {
               case 130:Alert("������������ �����. ������� ��� ���.");
                  RefreshRates();               // ������� ������
                  continue;                     // �� ����. ��������
               case 136:Alert("��� ���. ��� ����� ���..");
                  while(RefreshRates()==false)  // �� ������ ����
                     Sleep(1);                  // �������� � �����
                  continue;                     // �� ����. ��������
               case 146:Alert("���������� ������ ������.������� ���");
                  Sleep(500);                   // ������� �������
                  RefreshRates();               // ������� ������
                  continue;                     // �� ����. ��������
                  // ����������� ������
               case 2 : Alert("����� ������.");
                  break;                        // ����� �� switch
               case 5 : Alert("������ ������ ����������� ���������.");
                  break;                        // ����� �� switch
               case 64: Alert("���� ������������.");
                  break;                        // ����� �� switch
               case 133:Alert("�������� ���������");
                  break;                        // ����� �� switch
               default: Alert("�������� ������ ",Error);//��. ������
              }
            break;                              // �� ����� ������.
           }                                    // ����� ����� ������.
         //------------------------------------------------------ 8 --
        }                                       // ����� ������� ���.
     }                                          // ����� �������� ���.
//--------------------------------------------------------------- 9 --
   return;                                      // ����� �� start()
}

//==================================================================
//�������� ����� ��
//==================================================================
double CalculateAveragePrice(int magic)
{
  double AveragePrice = 0;
  double Count = 0;
  for (int i = 0; i < OrdersTotal(); i++)
    if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
        if (OrderType() == OP_BUY || OrderType() == OP_SELL) 
        {
           AveragePrice += OrderOpenPrice() * OrderLots();
           Count += OrderLots();
        }
  if(AveragePrice > 0 && Count > 0)
    return( NormalizeDouble(AveragePrice / Count, Digits));
  else
    return(0);
}


