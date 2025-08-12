//+------------------------------------------------------------------+
//|                                                  AutoRefresh.mq4 |
//|                                                           Ttomas |
//|                                                 TradeLikeAPro.ru |
//+------------------------------------------------------------------+
#property copyright "Ttomas"
#property link      "TradeLikeAPro.ru"

#define  WM_COMMAND                    0x0111
#property indicator_chart_window
#import "user32.dll"
   int   RegisterWindowMessageA(string lpstring);
   int   PostMessageA(int  hWnd,int  Msg,int  wParam,string lParam);
#import
extern int PeriodSec=30;
static int tic=0;
int OnInit()
   {
   PeriodSec*=1000;
   return(0);
   }
void OnDeinit(const int Des)  
   {
   return;
   }
int OnCalculate(const int rates_total,const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[]  )
   {
   if (tic==0) tic=GetTickCount();
   int k=GetTickCount();
   if (MathAbs(k-tic)>PeriodSec)
      {
      PostMessageA (WindowHandle (Symbol(), Period()), WM_COMMAND, 33324, 0);
      PostMessageA (WindowHandle (Symbol(), 0), RegisterWindowMessageA ("MetaTrader4_Internal_Message"), 2, 1);
      tic=GetTickCount();
      }
   return(0);
   }
//+------------------------------------------------------------------+