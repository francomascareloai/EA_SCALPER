//+-----------------------------------------------------------------------------+
//|                                                            RSI trader v0.15 |
//+-----------------------------------------------------------------------------+
#property copyright "Copyright © 2005, TraderSeven"
#property link      "TraderSeven@gmx.net"
 
//            \\|//             +-+-+-+-+-+-+-+-+-+-+-+             \\|// 
//           ( o o )            |T|r|a|d|e|r|S|e|v|e|n|            ( o o )
//    ~~~~oOOo~(_)~oOOo~~~~     +-+-+-+-+-+-+-+-+-+-+-+     ~~~~oOOo~(_)~oOOo~~~~
// Run on EUR/USD H1 
// At a certain time a small breakout often occurs.
//
//----------------------- HISTORY
// v0.10 Initial release.
//----------------------- TODO
// Test other pairs and timeframes.
// Trailing stop
 
extern int RSIPeriod=14;
extern int Short_price_MA_periods = 9;
extern int Long_price_MA_periods = 45;
extern int Short_RSI_MA_periods = 9;
extern int Long_RSI_MA_periods = 45;
extern double Lots = 1;
extern int Slippage=3;


//----------------------- MAIN PROGRAM LOOP

//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
int start()
  {
  
  int arraysize=200;
   double RSI[];
   double RSI_SMA[];
   ArrayResize(RSI,arraysize);
   ArrayResize(RSI_SMA,arraysize);
   ArraySetAsSeries(RSI,true);
   
   for(int i3=arraysize-1;i3>=0;i3--)
      RSI[i3]=iRSI(NULL,0,RSIPeriod,PRICE_CLOSE,i3);
   for(i3=arraysize-1;i3>=0;i3--)
      RSI_SMA[i3]=iMAOnArray(RSI,0,Short_RSI_MA_periods,0,MODE_SMA,i3);
double RSI9 =RSI_SMA[1];

   for(i3=arraysize-1;i3>=0;i3--)
      RSI[i3]=iRSI(NULL,0,RSIPeriod,PRICE_CLOSE,i3);
   for(i3=arraysize-1;i3>=0;i3--)
      RSI_SMA[i3]=iMAOnArray(RSI,0,Long_RSI_MA_periods,0,MODE_SMA,i3);
double RSI45 =RSI_SMA[1];


double Price45=iMA(NULL,0, Long_price_MA_periods ,0,MODE_LWMA,PRICE_CLOSE,1);
double Price9 =iMA(NULL,0, Short_price_MA_periods,0,MODE_SMA,PRICE_CLOSE,1);


bool Long=false;
bool Short=false;
bool Sideways=false;
if(Price9>Price45 && RSI9>RSI45) Long=true;
if(Price9<Price45 && RSI9<RSI45) Short=true; 
if(Price9>Price45 && RSI9<RSI45) Sideways=true;
if(Price9<Price45 && RSI9>RSI45) Sideways=true;  

if(Long==true  && OrdersTotal()==0)
  {
  OrderSend(Symbol(),OP_BUY ,Lots,Ask,Slippage,Ask/3,Ask*3,0,0,Blue);
  }
  
if(Short==true && OrdersTotal()==0)
  {
  OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,Bid*3,Bid/3,0,0,Red);
  }  
  
if(Sideways==true  && OrdersTotal()!=0) 
  { 
  OrderSelect(0, SELECT_BY_POS, MODE_TRADES);
  Comment("Sideways detected");
  if(OrderType()==OP_BUY) OrderClose(OrderTicket(),1,Ask,3,Red); 
  if(OrderType()==OP_SELL) OrderClose(OrderTicket(),1,Bid,3,Red);
  }
}