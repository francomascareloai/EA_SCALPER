//+------------------------------------------------------------------+
//|                                                  RUBBERBANDS.mq4 |
//|                                                      Version 1.6 |
//|                                Copyright © 2009, SummerSoft Labs |
//|                                   http://www.summersoftlabs.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, SummerSoft Labs"
#property link      "http://www.summersoftlabs.com/"
//////////////////////////////////////
extern double Lots = 0.05;
extern double dollar_profit = 1000; // dollars per lot
//////////////////////////////////////
extern bool quiesce_now = false;
extern bool do_now = false;
extern bool stop_now = false;
extern bool close_now = false;
//////////////////////////////////////
extern bool use_sessionTP = true;
extern double sessionTP = 1300; // dollars per lot
extern bool use_sessionSL = false;
extern double sessionSL = 300; // dollars per lot
//////////////////////////////////////
// these are for restart
extern bool use_in_values = false; // set to true on restart
extern int in_profit_sofar = 0; // set profit so far if not zero
extern int in_safety_mode = false; // set to true if already in safety mode
extern int in_safety_to_buy = false; // set "safety_to_buy" or sell
extern int in_used_safety_count = 0; // set "used safety count"
//////////////////////////////////////
//--SAFETY NET--//
extern bool use_safety_mode = true;
extern double safety_start = 2000; // dollars per lot
extern double safety_lots = 0.05;
//-extern int safety_step = 100; // !!pips!!
extern double safety_step = 3000; // =(1500*2) -- dollars per lot
extern double safety_profit = 1300; // dollars per lot
extern double safety_modeTP = 500; // dollars per lot
//////////////////////////////////////
//global var's
double GLBprofit;
bool GLBclose_all;
bool GLBbuy_now;
bool GLBsell_now;
bool GLBuse_in_values;
bool GLBsafety_mode;
bool GLBsafety_to_buy;
int GLBused_safety_count;
//double GLBsafety_start_price;
bool GLBsafety_buy_now;
bool GLBsafety_sell_now;
//////////////////////////////////////
//-double uPoint; //to fix the 6 Digit Forex Quotes issue for MetaTrader Expert Advisors
int Magic_Number_Buy = 1111;
int Magic_Number_Sell = 2222;
int Magic_Number_Safety_Buy = 3333;
int Magic_Number_Safety_Sell = 4444;
//+------------------------------------------------------------------+
//|  subroutines                                                     |
//+------------------------------------------------------------------+
int Is_Trade_Allowed(int MaxWaiting_sec = 30)
{
  if(!IsTradeAllowed())
  {
    int StartWaitingTime = GetTickCount();
    Print("Trade context is busy! Wait until it is free...");
    while(true)
    {
      if(IsStopped()) 
      { 
        Print("The expert was terminated by the user!"); 
        return(-1); 
      }
      if(GetTickCount() - StartWaitingTime > MaxWaiting_sec * 1000)
      {
        Print("The waiting limit exceeded (" + MaxWaiting_sec + " seconds.)!");
        return(-2);
      }
      if(IsTradeAllowed())
      {
        Print("Trade context has become free!");
        return(0);
      }
    }
  }
  else
  {
    return(1);
  }
}
//////////////////////////////////////
double Calculate_Profit()
{
double myprofit=0;
int total=OrdersTotal();

   for(int cnt=0;cnt<total;cnt++)
   {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderType()<=OP_SELL && OrderSymbol()==Symbol())
     {
       myprofit+=OrderProfit();
     } //-if
    }  //-for
    return(myprofit);
}
//////////////////////////////////////
int Count_All()
{
int cnt, total, xcnt;
    
   total=OrdersTotal();

  if (total==0)
  {
    return(0);
  }

   xcnt=0;
   
   for(cnt=0;cnt<total;cnt++)
   {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderSymbol()==Symbol())
     {
       xcnt++;
     }
  } // for
       return(xcnt);
}
//////////////////////////////////////
bool Close_Single_Order()
{
int cnt, total, xcnt;
bool result;
    
  total=OrdersTotal();

  if (total==0)
  {
    return(false);
  }

  for(cnt=0;cnt<total;cnt++)
  {
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
    if(OrderType()<=OP_SELL && OrderSymbol()==Symbol())
    {
      if(OrderType()==OP_BUY)
      {
        result=OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet);
        return(result);
      }
      else /*OP_SELL*/
      {
        result=OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet);
        return(result);
      }
    } // if ordertype
  } // for
  return(false);
}
//////////////////////////////////////
bool Open_Buy(string magicnumber, double lots)
{
int ticket;
  ticket=OrderSend(Symbol(),OP_BUY,lots,Ask,3,0,0,"RUBBERBANDS",magicnumber,0,Green);
  if(ticket>0)
  {
    if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) 
    {
      Print("BUY order opened : ",OrderOpenPrice());
      return(true); 
    }
  }
  else
  {
    Print("Error opening BUY order : ",GetLastError()); 
    return(false);
  }
}
//////////////////////////////////////
bool Open_Sell(string magicnumber, double lots)
{
int ticket;
  ticket=OrderSend(Symbol(),OP_SELL,lots,Bid,3,0,0,"RUBBERBANDS",magicnumber,0,Red);
  if(ticket>0)
  {
    if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
    {
      Print("SELL order opened : ",OrderOpenPrice());
      return(true); 
    }
  }
  else
  {
    Print("Error opening SELL order : ",GetLastError()); 
    return(false);
  }
}
//////////////////////////////////////
void Comment_Stopped()
{
Comment(
"SummerSoft Labs","\n",
"Lots = "+DoubleToStr(Lots,2),"\n",
"dollar_profit = "+DoubleToStr(dollar_profit,0),"\n",
"sessionTP = "+DoubleToStr(sessionTP,0),"\n",
"sessionSL = "+DoubleToStr(sessionSL,0)+" ("+use_sessionSL+")","\n",
"use safety mode = "+use_safety_mode,"\n",
"safety mode = "+GLBsafety_mode,"\n",
"safety to buy = "+GLBsafety_to_buy,"\n",
"used safety count = "+GLBused_safety_count,"\n",
"Profit So Far = "+DoubleToStr(GLBprofit,2),"\n","\n",
"STOPPED BY USER"
);
}
//////////////////////////////////////
void Comment_Quiesced()
{
Comment(
"SummerSoft Labs","\n",
"Lots = "+DoubleToStr(Lots,2),"\n",
"dollar_profit = "+DoubleToStr(dollar_profit,0),"\n",
"sessionTP = "+DoubleToStr(sessionTP,0),"\n",
"sessionSL = "+DoubleToStr(sessionSL,0)+" ("+use_sessionSL+")","\n",
"use safety mode = "+use_safety_mode,"\n",
"safety mode = "+GLBsafety_mode,"\n",
"safety to buy = "+GLBsafety_to_buy,"\n",
"used safety count = "+GLBused_safety_count,"\n",
"Profit So Far = "+DoubleToStr(GLBprofit,2),"\n","\n",
"QUIESCED BY USER"
);
}
//////////////////////////////////////
void Comment_Idle()
{
Comment(
"SummerSoft Labs","\n",
"Lots = "+DoubleToStr(Lots,2),"\n",
"dollar_profit = "+DoubleToStr(dollar_profit,0),"\n",
"sessionTP = "+DoubleToStr(sessionTP,0),"\n",
"sessionSL = "+DoubleToStr(sessionSL,0)+" ("+use_sessionSL+")","\n",
"use safety mode = "+use_safety_mode,"\n",
"safety mode = "+GLBsafety_mode,"\n",
"safety to buy = "+GLBsafety_to_buy,"\n",
"used safety count = "+GLBused_safety_count,"\n",
"Profit So Far = "+DoubleToStr(GLBprofit,2),"\n","\n",
"RUNNING - NO ORDERS YET"
);
}
//////////////////////////////////////
void Comment_PL(string bs, double pl, int total)
{
Comment(
"SummerSoft Labs","\n",
"Lots = "+DoubleToStr(Lots,2),"\n",
"dollar_profit = "+DoubleToStr(dollar_profit,0),"\n",
"sessionTP = "+DoubleToStr(sessionTP,0),"\n",
"sessionSL = "+DoubleToStr(sessionSL,0)+" ("+use_sessionSL+")","\n",
"use safety mode = "+use_safety_mode,"\n",
"safety mode = "+GLBsafety_mode,"\n",
"safety to buy = "+GLBsafety_to_buy,"\n",
"used safety count = "+GLBused_safety_count,"\n",
"Profit So Far = "+DoubleToStr(GLBprofit,2),"\n","\n",
bs+" = "+DoubleToStr(pl,2),"\n","\n",
"== RUNNING =="
);
}
///////////////////////////////////////////////////////////////
int init()
{

  if (use_in_values==true)
  {
    GLBprofit=in_profit_sofar;
    GLBsafety_mode=in_safety_mode;
    GLBsafety_to_buy=in_safety_to_buy;
    GLBused_safety_count=in_used_safety_count;
    GLBuse_in_values=true;
  }
  else
  {
    GLBprofit=0;
    GLBsafety_mode=false;
    GLBused_safety_count=0;
    GLBuse_in_values=false;
  }

  GLBclose_all=close_now;
  GLBbuy_now=do_now;
  GLBsell_now=do_now;
  GLBsafety_buy_now=false;
  GLBsafety_sell_now=false;

//  if (Point == 0.00001) uPoint = 0.0001; //6 digits
//  else if (Point == 0.001) uPoint = 0.01; //3 digits (for Yen based pairs)
//  else uPoint = Point; //Normal for 5 & 3 Digit Forex Quotes

  return(0);
}
/////////////////////////////////////////////////////////////////////////
int start()
{
int cnt, ticket, total;
bool result;

// check trade contexts
int TradeAllow = Is_Trade_Allowed();
  if(TradeAllow < 0) 
  { 
    return(-1); 
 }

  if(TradeAllow == 0)
  {
    RefreshRates();
  }
/////////////////////////////////////////////////////////////////////////
// STOP NOW?
  if (stop_now==true)
  {
    Comment_Stopped();
    return(0);
  }

  Comment_Idle();

  total=Count_All();
   
// CLOSE NOW?
// if true, close one by one
  if (GLBclose_all==true && total>0)
  {
    Close_Single_Order();
    return(0);
  }

  if (GLBclose_all==true && total==0)
  {
    GLBprofit=0;
    GLBused_safety_count=0;
    GLBclose_all=false;
    GLBsafety_mode=false;
    GLBsafety_buy_now=false;
    GLBsafety_sell_now=false;
  }

// QUIESCE NOW?
  if(total==0 && quiesce_now==true) 
  {
    Comment_Quiesced();
    return(0);  
  }

// Use entered valuess?
  if (GLBuse_in_values==true)
  {
    GLBprofit=in_profit_sofar;
    GLBsafety_mode=in_safety_mode;
    GLBsafety_to_buy=in_safety_to_buy;
    GLBused_safety_count=in_used_safety_count;
    GLBuse_in_values=false;
  }
///////////////////////////////////////////////////////////////////////////////////
// BUY NOW?
  if (GLBbuy_now==true)
  {
    result=Open_Buy(Magic_Number_Buy, Lots);
    if(result)
    {
      GLBbuy_now=false;
    }
    return(0); 
  }

  if (GLBsafety_buy_now==true)
  {
    result=Open_Buy(Magic_Number_Safety_Buy, safety_lots);
    if(result)
    {
      GLBsafety_buy_now=false;
      GLBused_safety_count++;
    }
    return(0); 
  }
///////////////////////////////////////////////////////////////////////////////////////
// SELL NOW?
  if (GLBsell_now==true)
  {
    result=Open_Sell(Magic_Number_Sell, Lots);
    if(result)
    {
      GLBsell_now=false;
    }
    return(0); 
  }

  if (GLBsafety_sell_now==true)
  {
    result=Open_Sell(Magic_Number_Safety_Sell, safety_lots);
    if(result)
    {
      GLBsafety_sell_now=false;
      GLBused_safety_count++;
    }
    return(0); 
  }
///////////////////////////////////////////////////////////////////////////////////////
// New order from 0 orders
  if (total==0 && Seconds()==0)
  {
    GLBbuy_now=true;
    GLBsell_now=true;
    return(0); 
  }
///////////////////////////////////////////////////////////////////////////////////////
// Orders already placed
  if (total>0)
  {
double myprofit=Calculate_Profit();
  Comment_PL("Apx. Profit",myprofit+GLBprofit,total);
///////////////////////////////////////////////////////////////////////////////////////
int xtotal=OrdersTotal();
  if (GLBsafety_mode==false)
  {
   for(cnt=0;cnt<xtotal;cnt++)
   {
  OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
  if (OrderType()<=OP_SELL
      && OrderSymbol()==Symbol()
      )
  {
    if (OrderProfit()>=dollar_profit*Lots)
    {
      GLBprofit+=OrderProfit();

      if(OrderType()==OP_BUY)
      {
        result=OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet);
        if (result) {
          GLBsell_now=true;
          GLBsafety_to_buy=true;
        }
        return(0); 
      }
      else /*OP_SELL*/
      {
        result=OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet);
        if (result) {
          GLBbuy_now=true;
          GLBsafety_to_buy=false;
        }
        return(0); 
      }

    } // if OrderProfit
  } // if ordertype

  } // for

///////////////////////////////////////////////////////////////////////////////////////
// if profit made, close everything
    myprofit=Calculate_Profit();

// close all trades to reserve profit?
   if (use_sessionTP==true
       && myprofit-GLBprofit>=sessionTP*Lots)
   {
     GLBclose_all=true;
     return(0);
   }

// close all trades for loss cut?
   if (use_sessionSL==true
       && use_safety_mode==false
       && myprofit-GLBprofit<=(-1)*sessionSL*Lots)
   {
     GLBclose_all=true;
     return(0);
   }

///////////////////////////////////////////////////////////////////////////////////////
// use safety mode?
   if (use_safety_mode==true
       && myprofit<=(-1)*safety_start*Lots)
   {
     GLBsafety_mode=true;
     if (GLBsafety_to_buy==true)
     {
       GLBsafety_buy_now=true;
       return(0);
     }
     if (GLBsafety_to_buy==false)
     {
       GLBsafety_sell_now=true;
       return(0);
     }
   }

  }
///////////////////////////////////////////////////////////////////////////////////////
  else // GLBsafety_mode==true
  {
// if already in safety mode
   for(cnt=0;cnt<xtotal;cnt++)
   {
  OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
  if(OrderType()<=OP_SELL
    && OrderSymbol()==Symbol()
    )
  {
    if (OrderProfit()>=safety_profit*safety_lots)
    {
      GLBprofit+=OrderProfit();

      if(OrderType()==OP_BUY)
      {
        OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet);
        return(0); 
      }
      else /*OP_SELL*/
      {
        OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet);
        return(0); 
      }

    } // if OrderProfit
  } // if ordertype

  } // for

     if (GLBsafety_to_buy==true && myprofit<=(-1)*(safety_start+GLBused_safety_count*safety_step)*safety_lots)
     {
       GLBsafety_buy_now=true;
       return(0);
     }
     if (in_safety_to_buy==false && myprofit<=(-1)*(safety_start+GLBused_safety_count*safety_step)*safety_lots)
     {
       GLBsafety_sell_now=true;
       return(0);
     }

double myprofit2=Calculate_Profit();

// if TP  reached in safety mode, close all orders
   if (myprofit2+GLBprofit>=safety_modeTP*Lots)
   {
     GLBclose_all=true;
     return(0);
   }

// NO SESSION SL in safety mode

  } // GLBsafety_mode
///////////////////////////////////////////////////////////////////////////////////////
  } // if total
   return(0);
} //-start
///////////////////////////////////////////////////////////////////////////////////////
int deinit()
{
  return(0);
}
///////////////////////////////////////////////////////////////////////////////////////
// the end.