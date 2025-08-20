//+----------------------------------------------------------------+
//|OCO_EA.mq4                                                      |
//|Copyright 2018, Speed Technology                                |
//|Copyright 2011, Trade Pro Company  Code By Raymond (HongKong)   |
//|                                                                |
//|OCO Order on MetaTrader4 Platform                               |
//|One pip Limit Order                                             |
//|One Pip Stop Order                                              |
//|                                                                |
//|++++++++++++++++++++++ Global Variables ++++++++++++++++++++++++|
//| OCO_BUY_LIMIT      : Buy Limit Price                           |
//| OCO_BUY_STOP       : Buy Stop Price                            |
//| OCO_SELL_LIMIT     : Sell Limit Price                          | 
//| OCO_SELL_STOP      : Sell Stop Price                           | 
//| OCO_confirmation   : After input Buy Limit Price,              |
//|                      Buy Stop Price, Sell Limit Price          |
//|                      or Sell Stop Price                        |
//|                      Input OCO_confirmation = "1"              |
//| OCO_lots           : Lots                                      |
//| OCO_oCO            : if OCO_oCO = "1", One Canel Others        | 
//| OCO_sL_Pips        : Stop Loss Pips                            | 
//| OCO_tP_Pips        : Take Profit Pips                          |
//+----------------------------------------------------------------+

#property strict
#include <stdlib.mqh>
#include <WinUser32.mqh>
//+-----------------------------------------------------------------------+
//| Return the local time, \n, Bid Ask High Low                           |
//+-----------------------------------------------------------------------+
string dtbahl()
  {
   string dt="Local Time : "+TimeToStr(LocalTime(),TIME_DATE|TIME_SECONDS)+
             "        raymondyeung.htc@gmail.coom"+"\n"+
             "Bid :"+DoubleToStr(Bid,Digits)+" Ask :"+DoubleToStr(Ask,Digits)+
             " High :"+DoubleToStr(High[0],Digits)+" Low :"+DoubleToStr(Low[0],Digits);
   return (dt);
  }

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+

bool res;

bool GlobalVar_init()
  {
   bool InitGlobalVar=false;
   if(!GlobalVariableCheck("OCO_lots"))
     {
      GlobalVariableSet("OCO_lots",0.1);
      InitGlobalVar=(InitGlobalVar || true);
     }

   if(!GlobalVariableCheck("OCO_tP_Pips"))
     {
      GlobalVariableSet("OCO_tP_Pips",300);
      InitGlobalVar=(InitGlobalVar || true);
     }

   if(!GlobalVariableCheck("OCO_sL_Pips"))
     {
      GlobalVariableSet("OCO_sL_Pips",300);
      InitGlobalVar=(InitGlobalVar || true);
     }

   if(!GlobalVariableCheck("OCO_oCO"))
     {
      GlobalVariableSet("OCO_oCO",1);
      InitGlobalVar=(InitGlobalVar || true);
     }

   if(!GlobalVariableCheck("OCO_BUY_LIMIT"))
     {
      GlobalVariableSet("OCO_BUY_LIMIT",0);
      InitGlobalVar=(InitGlobalVar || true);
     }

   if(!GlobalVariableCheck("OCO_SELL_LIMIT"))
     {
      GlobalVariableSet("OCO_SELL_LIMIT",0);
      InitGlobalVar=(InitGlobalVar || true);
     }

   if(!GlobalVariableCheck("OCO_BUY_STOP"))
     {
      GlobalVariableSet("OCO_BUY_STOP",0);
      InitGlobalVar=(InitGlobalVar || true);
     }

   if(!GlobalVariableCheck("OCO_SELL_STOP"))
     {
      GlobalVariableSet("OCO_SELL_STOP",0);
      InitGlobalVar=(InitGlobalVar || true);
     }

   if(!GlobalVariableCheck("OCO_confirmation"))
     {
      GlobalVariableSet("OCO_confirmation",0);
      InitGlobalVar=(InitGlobalVar || true);
     }

   return(InitGlobalVar);
  }  

int init()
  {

   GlobalVar_init();
   reset_variable();

   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {

   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+


void reset_variable()
  {
   GlobalVariableSet("OCO_BUY_LIMIT",0);
   GlobalVariableSet("OCO_SELL_LIMIT",0);
   GlobalVariableSet("OCO_BUY_STOP",0);
   GlobalVariableSet("OCO_SELL_STOP",0);
   GlobalVariableSet("OCO_confirmation",0);
  }

int  ticket=0;
double takeprofit=0;
double stoploss=0;

int start()
  {

   string DisplayTime=dtbahl();
   if(GlobalVariableGet("OCO_BUY_STOP")>0)
      DisplayTime=DisplayTime+"\n"+"BUY STOP  AT "+DoubleToStr(GlobalVariableGet("OCO_BUY_STOP"),Digits);
   if(GlobalVariableGet("OCO_BUY_LIMIT")>0)
      DisplayTime=DisplayTime+"\n"+"BUY LIMIT AT "+DoubleToStr(GlobalVariableGet("OCO_BUY_LIMIT"),Digits);
   if(GlobalVariableGet("OCO_SELL_LIMIT")>0)
      DisplayTime=DisplayTime+"\n"+"SELL LIMIT AT "+DoubleToStr(GlobalVariableGet("OCO_SELL_LIMIT"),Digits);
   if(GlobalVariableGet("OCO_SELL_STOP")>0)
      DisplayTime=DisplayTime+"\n"+"SELL STOP AT "+DoubleToStr(GlobalVariableGet("OCO_SELL_STOP"),Digits);
   Comment(DisplayTime);

   if(GlobalVariableGet("OCO_confirmation")==1)
     {
      
      if(GlobalVariableGet("OCO_BUY_LIMIT")>0 && Ask<=GlobalVariableGet("OCO_BUY_LIMIT"))
        {
         ticket=OrderSend(Symbol(),OP_BUY,GlobalVariableGet("OCO_lots"),Ask,0,0,0,"OCO_LIMIT_BUY",255,0,CLR_NONE);
         if(ticket>1 && OrderSelect(ticket,SELECT_BY_TICKET)==true)
           {
            Sleep(2000);
            res=OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice()-GlobalVariableGet("OCO_sL_Pips")*Point,OrderOpenPrice()+GlobalVariableGet("OCO_tP_Pips")*Point,0,CLR_NONE);
            PlaySound("ok.wav");
            GlobalVariableSet("OCO_BUY_LIMIT",0);
            if(GlobalVariableGet("OCO_oCO")==1) reset_variable();
           }
        }

      if(GlobalVariableGet("OCO_SELL_LIMIT")>0 && Bid>=GlobalVariableGet("OCO_SELL_LIMIT"))
        {
         ticket=OrderSend(Symbol(),OP_SELL,GlobalVariableGet("OCO_lots"),Bid,0,0,0,"OCO_LIMIT_SELL",255,0,CLR_NONE);
         if(ticket>1 && OrderSelect(ticket,SELECT_BY_TICKET)==true)
           {
            Sleep(2000);
            res=OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice()+GlobalVariableGet("OCO_sL_Pips")*Point,(OrderOpenPrice()-GlobalVariableGet("OCO_tP_Pips")*Point),0,CLR_NONE);
            PlaySound("ok.wav");
            GlobalVariableSet("OCO_SELL_LIMIT",0);
            if(GlobalVariableGet("OCO_oCO")==1) reset_variable();
           }
        }

      if(GlobalVariableGet("OCO_BUY_STOP")>0 && Ask>=GlobalVariableGet("OCO_BUY_STOP"))
        {
         ticket=OrderSend(Symbol(),OP_BUY,GlobalVariableGet("OCO_lots"),Ask,0,0,0,"OCO_BUY_STOP",255,0,CLR_NONE);
         if(ticket>1 && OrderSelect(ticket,SELECT_BY_TICKET)==true)
           {
            Sleep(2000);
            res=OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice()-GlobalVariableGet("OCO_sL_Pips")*Point,OrderOpenPrice()+GlobalVariableGet("OCO_tP_Pips")*Point,0,CLR_NONE);
            PlaySound("ok.wav");
            GlobalVariableSet("OCO_BUY_STOP",0);
            if(GlobalVariableGet("OCO_oCO")==1) reset_variable();
           }
        }

      if(GlobalVariableGet("OCO_SELL_STOP")>0 && Bid<=GlobalVariableGet("OCO_SELL_STOP"))
        {
         ticket=OrderSend(Symbol(),OP_SELL,GlobalVariableGet("OCO_lots"),Bid,0,0,0,"OCO_STOP_SELL",255,0,CLR_NONE);
         if(ticket>1 && OrderSelect(ticket,SELECT_BY_TICKET)==true)
           {
            Sleep(2000);
            res=OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice()+GlobalVariableGet("OCO__sL_Pips")*Point,OrderOpenPrice()-GlobalVariableGet("OCO_tP_Pips")*Point,0,CLR_NONE);
            PlaySound("ok.wav");
            GlobalVariableSet("OCO_SELL_STOP",0);
            if(GlobalVariableGet("OCO_oCO")==1) reset_variable();
           }
        }
      if(GlobalVariableGet("OCO_BUY_STOP")== 0 && GlobalVariableGet("OCO_BUY_LIMIT") == 0 &&
         GlobalVariableGet("OCO_SELL_LIMIT") == 0 && GlobalVariableGet("OCO_SELL_LIMIT") ==0)
         GlobalVariableSet("OCO_confirmation",0);
     } 

   return(0);
  }
