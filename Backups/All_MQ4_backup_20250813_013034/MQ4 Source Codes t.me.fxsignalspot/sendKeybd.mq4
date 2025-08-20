//+------------------------------------------------------------------+
//|                                                    sendKeybd.mq4 |
//|                                          Copyright 2021, Robotop |
//|                                               https://robotop.id |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Robotop"
#property link      "https://robotop.id"
#property version   "1.00"
#property strict


#import "user32.dll"
    void keybd_event(int bVk, int bScan, int dwFlags,int dwExtraInfo);
#import
#define  REL   0x0002
//#define  ALT   0x12  
//#define  VK_O  0x4F
#define  VK_F9	   0x78


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Alert ("Tekan tombol O utk open windows New Order ");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
  
  

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

   if (lparam == 79){ //tekan O utk open window/form entry order
      keybd_event(VK_F9, 0, 0, 0);
      keybd_event(VK_F9, 0, REL, 0);
   }

  }
//+------------------------------------------------------------------+