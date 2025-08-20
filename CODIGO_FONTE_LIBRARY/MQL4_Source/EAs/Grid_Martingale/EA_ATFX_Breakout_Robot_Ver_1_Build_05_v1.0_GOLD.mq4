//+------------------------------------------------------------------+
//|                         ATFX_Breakout_Robot___Ver_1_Build_05.mq4 |
//|                                           Copyright © 2009, atfx |
//|                                     http://www.autotradingfx.org |
//|                                          email: atfx01@gmail.com |
//|                                                                  |
//|  This Expert uses an External DLL file. It does not work without |
//|  its DLL. The DLL file have a built in security Engine that      |
//|  disable itself in case of Expiration Date or Wrong Password.    |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, atfx"
#property link      "http://www.autotradingfx.org"
//+-----------------------------------------------
//  external include section
//+-----------------------------------------------
#include <stdlib.mqh>
#include <stderror.mqh>
//+-----------------------------------------------
//  external DLL library section
//+-----------------------------------------------
#import "ATFX_Breakout_Robot.dll"
#import
//+-----------------------------------------------
//  user customizable parameters
//+-----------------------------------------------
extern   string   ___BKOUT_SETTINGS_______   = "-----------------------------------------";
extern   bool     Bkout_EnableTrading        = true;
extern   bool     Bkout_LongTrades           = true;
extern   bool     Bkout_ShortTrades          = true;
extern   bool     Bkout_EnableAutoStopLoss   = true;
//extern   bool     Bkout_GhostMode            = false;
extern   int      Bkout_MagicNumber          = 439878;
extern   string   Bkout_Password             = "YourPasswordHere";
extern   string   ___BKOUT_MM_____________   = "-----------------------------------------";
extern   double   Bkout_FixedLotSize         = 0.1;
extern   bool     Bkout_EnableAutoLot        = false;
extern   double   Bkout_MaxAccountRisk       = 5;
extern   double   Bkout_MinLotSize           = 0.01;
extern   double   Bkout_MaxLotSize           = 1000000.00;
extern   int      Bkout_Slippage             = 30;
extern   string   ___BKOUT_OTHERS_________   = "-----------------------------------------";
extern   color    Bkout_OpenBuyColor         = Lime;
extern   color    Bkout_OpenSellColor        = Red;
extern   color    Bkout_CloseBuyColor        = Blue;
extern   color    Bkout_CloseSellColor       = Blue;
extern   bool     Bkout_DelPendingsOnExit    = true;
extern   string   ___ROBOT_COMMON_________   = "-----------------------------------------";
extern   string   RobotName                  = "ATFX Breakout Robot";
extern   string   RobotVersion               = "1";
extern   string   RobotBuild                 = "05";
extern   string   RobotCopyright             = "Copyright © 2009";
extern   string   RobotOwner                 = "atfx";
extern   string   RobotWebSite               = "http://www.autotradingfx.org";
extern   string   RobotContact               = "atfx01@gmail.com";
extern   bool     ShowRobotComment           = true;
//+-----------------------------------------------
//  global variables declaration
//+-----------------------------------------------
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
void init() {
   //+-----------------------------------------------
   //  end special init function
   //+-----------------------------------------------
   return;
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
void start() {
   //+-----------------------------------------------
   //  end special start function
   //+-----------------------------------------------
   return;
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
void deinit() {
   //+-----------------------------------------------
   //  end special deinit function
   //+-----------------------------------------------
   return;
}
