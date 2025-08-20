#property copyright   "Copyright 2019, Pelanjie Mafuta // 2020 Dominic Poirier"
#property link        "https://www.mql5.com/en/users/lpelanjie"
#property description "This utility allows you to automatically enable or disable the automated trading button ."
#property description "For assistance Email : info@forexlimerence.com Telegram : https://t.me/forexlimerence"
#property version     "2.02"
#property strict

#include <WinUser32.mqh>
#import "user32.dll"
 
int GetAncestor(int, int);
#define MT4_WMCMD_EXPERTS  33020 

#import
//extern bool Run=true;

input int            Start_Time                 = 12;   //Start AutoTrade Time      
input int            Start_Min                  = 5;    //Start AutoTrade Minute      
input int            Finish_Time                = 2;    //Stop AutoTrade Time 
input int            Finish_Min                 = 50;   //Stop AutoTrade Time 
input bool           WaitForOrdersToBeClosed    = true; //Wait for orders to be closed before disabling Autotrading
input bool           TradeOnFriday              = false;//true to start AutoTrade on friday at Start_Time

int            start_Time;          
int            finish_Time;
int            start_Min;
int            finish_Min;
int            AbsoluteStartTime;
int            AbsoluteStopTime;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   start_Time     = Start_Time;          
   finish_Time    = Finish_Time;
   start_Min      = Start_Min;          
   finish_Min     = Finish_Min;
   
   AbsoluteStartTime = (start_Time*100)+Start_Min;
   AbsoluteStopTime  = (Finish_Time*100)+Finish_Min;
   
   PrintFormat("Auto Trading (local time)::::: Starting at: %02d:%02d  --- Stopping at: %02d:%02d", Start_Time, Start_Min, Finish_Time, Finish_Min);
   
   //--- create timer
   EventSetTimer(1);
     
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

}

//+------------------------------------------------------------------+
//| Expert Timer function                                             |
//+------------------------------------------------------------------+
void OnTimer()
{
   #define  Friday   5
   int main = GetAncestor(WindowHandle(Symbol(), Period()), 2/*GA_ROOT*/);

   int Current_Time = TimeHour(TimeLocal());
   int Current_Min = TimeMinute(TimeLocal());
   int Current_Day = TimeDay(TimeLocal());
   int AbsoluteTime = (Current_Time*100)+Current_Min;

   //PrintFormat("AbsoluteTime: %04d, AbsoluteStartTime: %04d, AbsoluteStopTime: %04d", AbsoluteTime, AbsoluteStartTime, AbsoluteStopTime);        
   // sarting autotrading autodrading if required
   if (Current_Day != Friday || (Current_Day == Friday && TradeOnFriday)){
      if (AbsoluteStartTime >  AbsoluteStopTime) {
         if (AbsoluteTime >= AbsoluteStartTime || AbsoluteTime < AbsoluteStopTime){
            if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){
               PrintFormat("Auto Trading::::: Triggered (local time) -- Starting Time: %02d:%02d", Start_Time, Start_Min);
               Print("Auto Trading::::: Starting AutoTrading for all terminal charts");      
               PostMessageA(main, WM_COMMAND,  MT4_WMCMD_EXPERTS, 0 ) ;
            }
         }
      }
      else{
         if (AbsoluteTime >= AbsoluteStartTime && AbsoluteTime < AbsoluteStopTime){
            if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){
               PrintFormat("Auto Trading::::: Triggered (local time) -- Starting Time: %02d:%02d", Start_Time, Start_Min);
               Print("Auto Trading::::: Starting AutoTrading for all terminal charts");      
               PostMessageA(main, WM_COMMAND,  MT4_WMCMD_EXPERTS, 0 ) ;
            }
         }   
      }
   }
   
   // Will wait to have no orders in terminal before stopping autodrading if WaitForOrdersToBeClosed==true else don't wait 
   if (AbsoluteStartTime >  AbsoluteStopTime) {
      if (AbsoluteTime >= AbsoluteStopTime && AbsoluteTime < AbsoluteStartTime){
         if(!WaitForOrdersToBeClosed || OrdersTotal()<1){
            if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){
               PrintFormat("Auto Trading::::: Triggered (local time)-- Sopping Time: %02d:%02d", finish_Time, finish_Min);
               Print("Auto Trading::::: Stopping AutoTrading for all terminal charts");            
               PostMessageA(main, WM_COMMAND,  MT4_WMCMD_EXPERTS, 0 ) ;
            }
         }                 
      }
   }
   else {
      if (AbsoluteTime >= AbsoluteStopTime || AbsoluteTime < AbsoluteStartTime){
         if(OrdersTotal()<1){
            if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){
               PrintFormat("Auto Trading::::: Triggered (local time)-- Sopping Time: %02d:%02d", finish_Time, finish_Min);
               Print("Auto Trading::::: Stopping AutoTrading for all terminal charts");                        
               PostMessageA(main, WM_COMMAND,  MT4_WMCMD_EXPERTS, 0 ) ;
            }
         }
      }                    
   }               
}
//+------------------------------------------------------------------+


   
 

 