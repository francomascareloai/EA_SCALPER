//+------------------------------------------------------------------+
//|                                            1ClickCloseAllv01.mq4 |
//|                                Copyright 2016, Ozan Buyuksemerci |
//|                                             https://www.ozan.org |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Ozan Buyuksemerci (grandaevus)"
#property link      "https://ozan.org"
#property version   "1.00"
#property strict

//--- input parameters
input int MaxSlippage = 5;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- 
   
   ObjectCreate(0,"CloseButton",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"CloseButton",OBJPROP_XDISTANCE,25);
   ObjectSetInteger(0,"CloseButton",OBJPROP_YDISTANCE,100);
   ObjectSetInteger(0,"CloseButton",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"CloseButton",OBJPROP_YSIZE,50);

   ObjectSetString(0,"CloseButton",OBJPROP_TEXT,"Close All");
      
   
   ObjectSetInteger(0,"CloseButton",OBJPROP_COLOR, White);
   ObjectSetInteger(0,"CloseButton",OBJPROP_BGCOLOR, Red);
   ObjectSetInteger(0,"CloseButton",OBJPROP_BORDER_COLOR,Red);
   ObjectSetInteger(0,"CloseButton",OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,"CloseButton",OBJPROP_BACK,false);
   ObjectSetInteger(0,"CloseButton",OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,"CloseButton",OBJPROP_STATE,false);
   ObjectSetInteger(0,"CloseButton",OBJPROP_FONTSIZE,12);

//---
   return(INIT_SUCCEEDED);
  }
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

   ObjectDelete(0,"CloseButton");
   
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
            
   if(sparam== "CloseButton")
      {
      CloseAllOpenPositions(MaxSlippage); 
      ObjectSetInteger(0,"CloseButton",OBJPROP_STATE,false);    
      }
         
//---      
  }
//+------------------------------------------------------------------+


void CloseAllOpenPositions(int intMaxSlippage)
  {
   bool checkOrderClose = true;        
   int index = OrdersTotal()-1;
   
   while (index >=0 && OrderSelect (index,SELECT_BY_POS,MODE_TRADES)==true)
      {
      if (OrderType()==OP_BUY || OrderType()==OP_SELL)
         {         
         checkOrderClose = OrderClose (OrderTicket(), OrderLots(), OrderClosePrice(), intMaxSlippage, CLR_NONE); 
         
         if(checkOrderClose == false)
            {
            int errorCode = GetLastError();
            
            if (errorCode == 1 || errorCode == 2 || errorCode == 5 || errorCode == 6 || errorCode == 64 || errorCode == 65 || errorCode == 132 || errorCode == 133 || errorCode == 139) break;
            else continue;        
            }          
         }     
      
      index--;
      }   
   
   
  }
