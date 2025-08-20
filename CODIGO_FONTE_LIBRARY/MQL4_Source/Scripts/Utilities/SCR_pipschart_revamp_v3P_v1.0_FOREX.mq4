//+------------------------------------------------------------------+
//|                                                        Feb10.mq4 |
//|                                             Komgrit Sungkhaphong |
//|                               http://iamforextrader.blogspot.com |
//+------------------------------------------------------------------+

//version50
// -allow user to run multiple instance of bot for the same pair, by specifying the MAGIC number

//version60
// -reduce chan

//v66ba
//-make it compatible to mt4 build 6XX
//-4-digit broker compatible

#property copyright "Komgrit Sungkhaphong"
#property link      "http://iamforextrader.blogspot.com"
/*
#include "libraries\Trade.mq4"
#include "libraries\OAmq4"
#include "libraries\Lib.mq4"
*/
#include <Trade.mq4>
#include <OA.mq4>
#include <Lib.mq4>
#include <SmallFunc.mqh>

#include <MQL4OBJ.mqh>
#include <LastOrder.mqh>

//#define currentversion "66ba"

#define state_idle         0
#define state_await_buy    500
#define state_await_sell    600
#define state_buy1          1000
#define state_sell1         2000
#define state_buy2          1800
#define state_sell2         2800
#define state_pending_deploy      200
#define state_pending_deploy2      222
#define state_pending_wait     201
#define state_buy2_hold     1900
#define state_sell2_hold    2900

#define state_revbuy_tradesell  1500
#define state_revsell_tradebuy  2500

#define state_revbuy_tradesell_trail  1599
#define state_revsell_tradebuy_trail  2599

#define state_hbuy   301
#define state_hsell   302
#define state_hbuy2  303
#define state_hsell2 304
//+------------------------------------------------------------------+
//| User Define variables                                   |
//+-----------------------------------------------------------------+
input bool UseAutoID=true;
input int User_define_Bot_ID=1000;
input int UserDefine_SpreadTooHigh=60;   //Points
input double init_lot_size=0.1;
input double exponent=1.44;
input double squeeze_factor=0.3;

input int atr_range=24;
input int candles_range=12;
input int Calm_candles=8;
input string Calm_range_info="unit in point";
input int Calm_range=200;

//input int D1_Candles=5;
input int D1_atr_range=10;

input int HoldMinutes=60;
input int  High_Or_Low_Diff=40;

input double neg_percentile=0;
input int barpercentile=36;

input int bar1=3;
input int bar2=20;
input int bar3=40;
input int TrendValue=30;

input int MoveLarge=500;
input int MoveRecent=250;

int atr_period=60;

int pendingbuyticket;
int pendingsellticket;
//+------------------------------------------------------------------+
//| Order Issue Interlocking                                                 |
//+------------------------------------------------------------------+

datetime timestamp_buy;
datetime timestamp_sell;
datetime timestamp_close;
datetime MinutesToUnlock_buy;
datetime MinutesToUnlock_sell;
//+------------------------------------------------------------------+
//| Multiple Orders Control                                                 |
//+------------------------------------------------------------------+
//    [0][]=ticket number
//    [1][]=lots
//    [2][]=price
double OrderAcc_buy[25][3];
double OrderAcc_sell[25][3];
int lastticket;
double pl;              //pips
double cummpl;
double thisBreakEven;   //price
double distance_Loss;   //pips
double distance_Gain;   //pips
double lots;
double propose_new_stoploss;
double expect_stoploss;
double target_gain;
double new_target_price;
double new_stop_loss;
bool calbreak_flag;
bool TP_is_too_low=false;

double max_gain;
double max_loss;
double estimate_max_loss;
double RRR;
int bbb; //bar count in Isnewbar
datetime laststamp;
datetime BlockBuyUntilTime;
datetime BlockSellUntilTime;
datetime MultiOrderStateTimeStamp;
datetime MultiOrderStateTimeStamp_buy;
datetime MultiOrderStateTimeStamp_sell;
datetime      MultiOrderState_Age;
double ThisOpenPrice;
double PercentileSafetyLevel;
int CMD;
double newMark;
//+------------------------------------------------------------------+
//| State machine variables                                                  |
//+------------------------------------------------------------------+
int state;
string now;
double tickcount,_tickcount;
//+------------------------------------------------------------------+
//| General variables                                                  |
//+------------------------------------------------------------------+
static int MAGIC;
string comment_string;
string comments;
int RetError;
double SPREAD;
double X45;
string units;
double DECPIP;
string BROKER45;
//+------------------------------------------------------------------+
//| Indicators                                                 |
//+------------------------------------------------------------------+
double ATR;
double fastATR;
double ATR_Slope;
double dailyATR;
double lowerbound;
double upperbound;

double ge; //gain efficiency
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   if(UseAutoID==true)
     {
      //MAGIC=MAGIC_LIST_BY_SYMBOL();
      MAGIC=AutomaticIDGenerate();
     }
   else
     {
      MAGIC=User_define_Bot_ID;
     }
//MAGIC=MAGIC_LIST_BY_SYMBOL();

   if(Symbol()=="GBPUSD")  ge=1.0;
   if(Symbol()=="EURUSD")  ge=1.0;
   if(Symbol()=="GBPAUD")  ge=1.8;
   if(Symbol()=="GBPNZD")  ge=1.8;
   if(Symbol()=="GBPCAD")  ge=1.8;
   if(Symbol()=="EURAUD")  ge=1.8;
   if(Symbol()=="EURNZD")  ge=2.0;
   if(Symbol()=="EURCAD")  ge=2.0;
   else ge=1.0;

//v66ba 
//create one point to pip for 4 digit broker
   switch(Digits)
     {
      case  5:
        {
         BROKER45="5-digits";
         X45=1;
         units="Point";
         DECPIP=MathPow(10,Digits);
         Print("v66ba: You are running with 5 digit broker server.");
         break;
        }
      case  4:
        {
         BROKER45="4-digits";
         X45=0.1;
         units="Pip";
         DECPIP=MathPow(10,Digits);
         Print("v66ba: You are running with 4 digit broker server.");
         break;
        }
      case  3:
        {
         BROKER45="3-digits";
         X45=0.01;
         units="10Pip";
         DECPIP=MathPow(10,Digits);
         Print("v66ba: You are running with 3 digit broker server.");
         break;
        }
      default:
        {
         BROKER45="5-digits";
         X45=1;
         units="Point";
         DECPIP=MathPow(10,Digits);
         break;
        }
     }

   if(IsDemo()) comment_string="DEMO"+"\n";
   else comment_string="LIVE"+"\n";
   comment_string=comment_string+"Magic Number="+IntegerToString(MAGIC)+"\n";
//----  Account detail
   string _account_string;
   _account_string="Broker:"+AccountCompany()+"\n";
   _account_string=_account_string+"ID:"+IntegerToString(AccountNumber())+"\n";
   _account_string=_account_string+"Name:"+AccountName()+"\n";

   comment_string=comment_string+_account_string;
   Comment(comment_string);

   BlockBuyUntilTime=TimeCurrent()-1*60*60;
   BlockSellUntilTime=TimeCurrent()-1*60*60;

//---- init the state
   state=state_idle;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   RefreshRates();
   OrderAccounting();
//v66ba
   SPREAD=Ask-Bid;
//SPREAD=SymbolInfoInteger(Symbol(),SYMBOL_SPREAD);
   status("You are running "+BROKER45);

   int power;

//----Info
   comments="";
   tickcount=GetTickCount();

//----Graphics

//----Time Control
//   MinutesToUnlock_buy=timestamp_buy+HoldMinutes*60-TimeCurrent();
//   MinutesToUnlock_buy=MinutesToUnlock_buy/60;
//   if(MinutesToUnlock_buy<0) MinutesToUnlock_buy=0;
//
//   MinutesToUnlock_sell=timestamp_sell+HoldMinutes*60-TimeCurrent();
//   MinutesToUnlock_sell=MinutesToUnlock_sell/60;
//   if(MinutesToUnlock_sell<0) MinutesToUnlock_sell=0;
//----name of State Machine   
//    This will be shown on the trading comment view

//#statenamecode #stateshort #abbr
   Run_CurrentStateShortCode();
//set tate order command for new order either OP_BUY or OP_SELL
//#ordercommand
   Run_OrderCommand();
//#statetransition #transition
   Run_State_Transition();
//#timestampcontrol
   Run_TimeStampControl();
//Comment message generating sections
//#commentary #commentmessage
   Run_Comment();
//----Actions State Machine
   switch(state)
     {
      case state_idle:
        {
         //----State's action
         //create range upper and lower bounds
         max_gain=0;
         max_loss=0;

         //#spreadlock
         //if spread is more than 60, this bot would do nothing. 
         if(SPREAD>UserDefine_SpreadTooHigh*Point)
           {
            //v66ba

            Comment("Point="+DoubleToStr(Point,Digits)+" Spread is too high ="+DoubleToString(SPREAD)+" (limit="+DoubleToStr(UserDefine_SpreadTooHigh*Point,Digits)+")");
            return(0);
           }
         //#entry #entries
         if(IsNoPosition() && TimeCurrent()>timestamp_close+HoldMinutes*60)
           {
            //-----trigger trade buy
            if(CandleRange(5)>Calm_range*Point*ge && CandleRange(5)>ATR*ge)
              {
               expect_stoploss=0;
               if(TimeCurrent()>BlockBuyUntilTime)
                 {
                  PercentileSafetyLevel=PercentileSafetyLevel(OP_BUY,barpercentile);
                  if(PercentileSafetyLevel<neg_percentile)
                     //if(true)
                    {
                     //if(iClose(Symbol(),PERIOD_M1,1)>HP(3))

                     if(Bid<LP(bar1) && Bid>LP(bar2))
                       {
                        lastticket=Trade_Market(OP_BUY,timestamp_buy,init_lot_size,expect_stoploss,0,"b1");
                       }
                     else if(trend()<-TrendValue*Point && Bid<LP(bar2))
                       {
                        if(HP(bar3)-Bid<MoveLarge*Point*ge)
                          {

                           //lastticket=Trade_Market(OP_SELL,timestamp_sell,init_lot_size,expect_stoploss,0,"br1");
                           state=state_pending_deploy;
                          }
                        else
                          {
                           if(Close[2]-Bid>MoveRecent*Point*ge)
                             {
                              //lastticket=Trade_Market(OP_SELL,timestamp_sell,init_lot_size,expect_stoploss,0,"br2");
                              state=state_pending_deploy;
                             }

                          }
                       }
                    }
                 }
              }
            //-----trigger trade sell
            if(CandleRange(5)>Calm_range*Point*ge && CandleRange(5)>ATR*ge)
              {
               expect_stoploss=0;
               if(TimeCurrent()>BlockSellUntilTime)
                 {
                  PercentileSafetyLevel=PercentileSafetyLevel(OP_SELL,barpercentile);
                  if(PercentileSafetyLevel<neg_percentile)
                     //if(true)
                    {
                     //if(iClose(Symbol(),PERIOD_M1,1)<LP(3))

                     if(Ask>HP(bar1) && Ask<HP(bar2))
                       {
                        lastticket=Trade_Market(OP_SELL,timestamp_sell,init_lot_size,expect_stoploss,0,"s1");
                       }
                     else if(trend()>TrendValue*Point && Ask>HP(bar2))
                       {
                        if(Ask-LP(bar3)<MoveLarge*Point*ge)
                          {

                           //lastticket=Trade_Market(OP_BUY,timestamp_buy,init_lot_size,expect_stoploss,0,"sr1");
                           state=state_pending_deploy2;

                          }
                        else
                          {
                           if(Bid-Close[2]>MoveRecent*Point*ge)
                             {
                              //lastticket=Trade_Market(OP_BUY,timestamp_buy,init_lot_size,expect_stoploss,0,"sr2");
                              state=state_pending_deploy2;

                             }

                          }
                       }

                    }
                 }
              }
           }

         //----transition
         if(IsBuy()) state=state_buy1;
         if(IsSell()) state=state_sell1;
         break;
        }

      case state_pending_deploy:
        {
         OpenTwoPending(init_lot_size,"r",150,150,90);
         while(IsTradeContextBusy())
           {
            Sleep(300);
           }
         state=state_pending_wait;
         break;
        }
      case state_pending_deploy2:
        {
         OpenTwoPending(init_lot_size,"r",150,150,90);
         while(IsTradeContextBusy())
           {
            Sleep(300);
           }
         state=state_pending_wait;
         break;
        }
      case state_pending_wait:
        {
         if(IsBuy())
           {
            if(OrderDelete(pendingsellticket,clrGray)) state=state_buy1;
           }

         if(IsSell())
           {
            if(OrderDelete(pendingbuyticket,clrGray)) state=state_sell1;
           }
         datetime pbclosetime,psclosetime;
         pbclosetime=order_close_time(pendingbuyticket);
         psclosetime=order_close_time(pendingsellticket);
         if(pbclosetime!=0 && psclosetime!=0)
           {
            state=state_idle;
           }
         break;
        }
      case state_await_buy:
        {
         lastticket=get_last_order(MAGIC,OP_BUY);
         int lastticket2=get_last_order(MAGIC,OP_SELL);

         double profit1,profit2;
         profit1=order_profit(lastticket);
         profit2=order_profit(lastticket2);
         //if first original position was profit, correct
         //then the second position is false trigger
         //
         if(profit2<0 && profit1>0)
           {
            close_order_immediate(lastticket2);
            //close_order_immediate(lastticket);
            state=state_hbuy2;

           }
         if(profit2+profit1>0)
           {
            close_order_immediate(lastticket);
            close_order_immediate(lastticket2);
           }
         if(IsNoPosition())
           {
            state=state_idle;
           }
         if(IsBuy() && IsNoSell())
           {
            state=state_buy1;
           }
         if(IsSell() && IsNoBuy())
           {
            state=state_sell1;
           }
         break;
        }
      case state_await_sell:
        {
         lastticket=get_last_order(MAGIC,OP_SELL);
         int lastticket2=get_last_order(MAGIC,OP_BUY);

         double profit1,profit2;
         profit1=order_profit(lastticket);
         profit2=order_profit(lastticket2);

         //if first original position was profit, correct
         //then the second position is false trigger
         //
         if(profit2<0 && profit1>0)
           {
            close_order_immediate(lastticket2);
            //close_order_immediate(lastticket);
            state=state_hsell2;

           }

         if(profit2+profit1>0)
           {
            close_order_immediate(lastticket);
            close_order_immediate(lastticket2);
           }
         if(IsNoPosition())
           {
            state=state_idle;
           }
         if(IsBuy() && IsNoSell())
           {
            state=state_buy1;
           }
         if(IsSell() && IsNoBuy())
           {
            state=state_sell1;
           }
         break;
        }
      case state_hbuy:
        {
         lastticket=get_last_order(MAGIC,OP_BUY);
         int t=OrderSend(Symbol(),OP_SELL,order_lots(lastticket)*2,Bid,2,0,0,"h",MAGIC);
         state=state_await_buy;
         break;
        }
      case state_hsell:
        {
         lastticket=get_last_order(MAGIC,OP_SELL);
         int t=OrderSend(Symbol(),OP_BUY,order_lots(lastticket)*2,Ask,2,0,0,"h",MAGIC);
         state=state_await_buy;

         break;
        }

      case state_hbuy2:
        {
         int t=OrderSend(Symbol(),OP_BUY,init_lot_size*2,Ask,2,0,0,"rr",MAGIC);
         state=state_buy2;
         break;
        }
      case state_hsell2:
        {
         int t=OrderSend(Symbol(),OP_SELL,init_lot_size*2,Bid,2,0,0,"rr",MAGIC);
         state=state_sell2;
         break;
        }
      case state_buy1:
        {
         lastticket=get_last_order(MAGIC,OP_BUY);
         status("LOSS="+DoubleToString(order_loss_point(lastticket)));
         //if(order_loss_point(lastticket)>150
         //   && order_period_seconds(lastticket)>10*60
         //   )
         //  {
         //   //if(Bid<lp(3))
         //     {
         //      state=state_hbuy;
         //     }
         //  }

         //----state's action
         if(order_period_seconds(lastticket)>60*60 ||Bid<lp(3) ||trend()<0 || (order_stoploss(lastticket)==0 && order_profit_points(lastticket)>200))
           {
            CommonSingleOrderState();

           }
         //---
         //---

         if(order_period_seconds(lastticket)>60*60 && order_profit_points(lastticket)>50)
           {
            //stoplosswheelbarrel(lastticket,35,10);
            close_order_immediate(lastticket);
           }

         //---

         if(pl<=-xpips(100*Point+SPREAD) && TimeCurrent()-laststamp<60*60)
           {
            close_order_immediate(lastticket);
            state=state_revbuy_tradesell;
           }
         if(pl<=-xpips(1000*Point+SPREAD) && TimeCurrent()-laststamp<24*60*60)
           {
            close_order_immediate(lastticket);

           }
         //---

         if(order_loss_point(lastticket)>100 && order_period_seconds(lastticket)>4*60*60)
            //else if(pl<=-20)
           {

            //if(HP(Calm_candles)-LP(Calm_candles)<Calm_range*Point || (MathAbs(Low[2]-Low[1])<High_Or_Low_Diff*Point))
            //if(HP(Calm_candles)-LP(Calm_candles)>Calm_range*Point || (MathAbs(Low[2]-Low[1])<High_Or_Low_Diff*Point))
            if(Bid<lp(3))
              {
               //Remove_StopLoss(lastticket);
               lastticket=Trade_Market(OP_BUY,timestamp_buy,init_lot_size,0,0,"Recovery");
              }
           }
         //----transition
         if(IsNoPosition())
           {
            state=state_idle;
            timestamp_close=TimeCurrent();
           }

         if(IsBuys()){   state=state_buy2;   calbreak_flag=true;  MultiOrderStateTimeStamp_buy=TimeCurrent();}
         break;
        }
      case state_sell1:
        {
         lastticket=get_last_order(MAGIC,OP_SELL);
         status("LOSS="+DoubleToString(order_loss_point(lastticket)));
         //if(order_loss_point(lastticket)>150
         //   && order_period_seconds(lastticket)>15*60
         //   )
         //  {
         //   //if(Ask>hp(3))
         //     {
         //      state=state_hsell;
         //     }
         //  }
         //----state's action
         if(order_period_seconds(lastticket)>60*60 ||Ask>hp(3) || trend()>0 || (order_stoploss(lastticket)==0 && order_profit_points(lastticket)>200))
           {
            CommonSingleOrderState();

           }
         if(pl<=-xpips(100*Point+SPREAD) && TimeCurrent()-laststamp<60*60)
           {
            close_order_immediate(lastticket);
            state=state_revsell_tradebuy;
           }
         if(pl<=-xpips(1000*Point+SPREAD) && TimeCurrent()-laststamp<24*60*60)
           {
            close_order_immediate(lastticket);

           }

         if(order_period_seconds(lastticket)>60*60 && order_profit_points(lastticket)>50)
           {
            //stoplosswheelbarrel(lastticket,35,10);
            close_order_immediate(lastticket);
           }
         if(order_loss_point(lastticket)>100 && order_period_seconds(lastticket)>4*60*60)
            //else if(pl<=-20)
           {

            //if(HP(Calm_candles)-LP(Calm_candles)<Calm_range*Point || (MathAbs(High[2]-High[1])<High_Or_Low_Diff*Point))
            //if(HP(Calm_candles)-LP(Calm_candles)>Calm_range*Point || (MathAbs(High[2]-High[1])<High_Or_Low_Diff*Point))
            if(Ask>hp(3))
              {
               //Remove_StopLoss(lastticket);
               lastticket=Trade_Market(OP_SELL,timestamp_sell,init_lot_size,0,0,"Recovery");
              }

           }
         //----transition
         if(IsNoPosition())
           {
            state=state_idle;
            timestamp_close=TimeCurrent();
           }
         if(IsSells()){   state=state_sell2; calbreak_flag=true; MultiOrderStateTimeStamp_sell=TimeCurrent();}
         break;
        }
      case state_buy2:
        {
         power=OACount(MAGIC,OP_BUY,Symbol());
         //---
         double tp=0;

         double sumLots=0;
         double sumLotPrice=0;

         for(int i=0;i<OrdersTotal();i++)
           {
            if(OrderSelect(i,SELECT_BY_POS))
              {
               if(OrderMagicNumber()==MAGIC && OrderSymbol()==Symbol())
                 {
                  sumLotPrice=sumLotPrice+(OrderOpenPrice()*OrderLots());
                  sumLots=sumLots+OrderLots();
                 }
              }
           }

         double beprice=0;
         if(sumLots>0)
           {
            beprice=sumLotPrice/sumLots;

            switch(order_type(lastticket))
              {
               case OP_BUY :
                  beprice=beprice+30*Point;
                  break;
               case OP_SELL :
                  beprice=beprice-30*Point;
                  break;

              }
           }
         beprice=NormalizeDouble(beprice,Digits);
         for(int i=0;i<OrdersTotal();i++)
           {
            if(OrderSelect(i,SELECT_BY_POS))
              {
               if(OrderMagicNumber()==MAGIC && OrderSymbol()==Symbol())
                 {
                  if(OrderTakeProfit()!=beprice)
                    {
                     bool ok=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),beprice,0,clrGray);
                     if(GetLastError()>0)
                       {
                        Print(" loop multiple magic1");
                       }
                    }
                 }
              }
           }

         //---

         //if(trend()<-60*Point)
         //  {
         //   order_close_ALL(MAGIC);
         //  }

         if(calbreak_flag==true)
           {
            lots=init_lot_size*MathPow(exponent,power);
            lots=NormalizeLotSize(lots);
            status("Next Lot Size="+DoubleToStr(lots,2));
            //target_gain=squeeze_factor*ATR;
            //if(target_gain<30*Point) target_gain=30*Point;
            //new_target_price=thisBreakEven+target_gain;

            //enforce if recovery orders are more than xx number, just got all of them close ASAP
            //if(power>=4 && power<8) new_target_price=thisBreakEven+0.5*target_gain;
            //if(power>=8 ) new_target_price=thisBreakEven+0.1*target_gain;

            //ModifyTakeProfit(OP_BUY,new_target_price);
            calbreak_flag=false;

           }

         if(pl<=-xpips(1*ATR) && pl<=-xpips(0.2*dailyATR) && TimeCurrent()-laststamp>hr_sec(10))
            //if(pl<=-20)
           {
            if(IsTimeUnlocked_buy())
              {
               //if(CandleRange(Calm_candles)<Calm_range*Point || Close[2]-Close[1]>0.3*ATR)
               //if(CandleRange(Calm_candles)>Calm_range*Point || Close[2]-Close[1]>0.3*ATR)
               if(Bid>hp(3))
                 {
                  lastticket=Trade_Market(OP_BUY,timestamp_buy,lots,0,0,"Recovery");
                  if(OrderSelect(lastticket,SELECT_BY_TICKET)) calbreak_flag=true;
                 }
              }
           }

         //the state is more than 7 hours old
         if(MultiOrderState_Age>hr_sec(24))
           {
            if(cummpl>=8)
              {
               //ModifyStopLoss(OP_BUY,thisBreakEven+10*Point);
               OrderCloseAll(OP_BUY);
              }
           }

         //----transition
         if(IsNoPosition())
           {
            timestamp_close=TimeCurrent();
            state=state_idle;
           }

         break;
        }

      case state_sell2:
        {

         power=OACount(MAGIC,OP_SELL,Symbol());
         //---
         double tp=0;

         double sumLots=0;
         double sumLotPrice=0;
         //if(trend()>60*Point)
         //  {
         //   order_close_ALL(MAGIC);
         //  }
         for(int i=0;i<OrdersTotal();i++)
           {
            if(OrderSelect(i,SELECT_BY_POS))
              {
               if(OrderMagicNumber()==MAGIC && OrderSymbol()==Symbol())
                 {
                  sumLotPrice=sumLotPrice+(OrderOpenPrice()*OrderLots());
                  sumLots=sumLots+OrderLots();
                 }
              }
           }

         double beprice=0;
         if(sumLots>0)
           {
            beprice=sumLotPrice/sumLots;

            switch(order_type(lastticket))
              {
               case OP_BUY :
                  beprice=beprice+30*Point;
                  break;
               case OP_SELL :
                  beprice=beprice-30*Point;
                  break;

              }
           }
         beprice=NormalizeDouble(beprice,Digits);
         for(int i=0;i<OrdersTotal();i++)
           {
            if(OrderSelect(i,SELECT_BY_POS))
              {
               if(OrderMagicNumber()==MAGIC && OrderSymbol()==Symbol())
                 {
                  if(OrderTakeProfit()!=beprice)
                    {
                     bool ok=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),beprice,0,clrGray);
                     if(GetLastError()>0)
                       {
                        Print(" loop multiple magic1");
                       }
                    }
                 }
              }
           }

         //---

         if(calbreak_flag==true)
           {
            lots=init_lot_size*MathPow(exponent,power);
            lots=NormalizeLotSize(lots);
            status("Next Lot Size="+DoubleToStr(lots,2));
            //            target_gain=squeeze_factor*ATR;
            //            if(target_gain<30*Point) target_gain=30*Point;
            //            new_target_price=thisBreakEven-target_gain;
            //            //enforce if recovery orders are more than xx number, just got all of them close ASAP
            //            if(power>=4 && power<8) new_target_price=thisBreakEven-0.5*target_gain;
            //            if(power>=8) new_target_price=thisBreakEven-0.1*target_gain;
            //
            //
            //            ModifyTakeProfit(OP_SELL,new_target_price);
            calbreak_flag=false;
            //TP_is_too_low=false;
           }

         if(pl<=-xpips(1*ATR) && pl<=-xpips(0.2*dailyATR) && TimeCurrent()-laststamp>hr_sec(10))
            //if(pl<=-20)
           {
            if(IsTimeUnlocked_sell())
              {
               //if(CandleRange(Calm_candles)<Calm_range*Point || Close[1]-Close[2]>0.3*ATR)
               //if(CandleRange(Calm_candles)>Calm_range*Point || Close[1]-Close[2]>0.3*ATR)
               if(Bid<lp(3))
                 {
                  lastticket=Trade_Market(OP_SELL,timestamp_sell,lots,0,0,"Recovery");
                  if(OrderSelect(lastticket,SELECT_BY_TICKET)) calbreak_flag=true;
                 }
              }

           }

         if(MultiOrderState_Age>hr_sec(24))
           {
            if(cummpl>=8)
              {
               //ModifyStopLoss(OP_BUY,thisBreakEven-10*Point);
               OrderCloseAll(OP_SELL);
              }
           }

         //----transition
         if(IsNoPosition())
           {
            timestamp_close=TimeCurrent();
            state=state_idle;
           }

         break;
        }
      case state_buy2_hold:
        {
         newMark=LP(2);
         if(iBars(Symbol(),Period())>bbb)
           {
            if(newMark>thisBreakEven)
              {
               ModifyStopLoss(CMD,newMark);
               ModifyTakeProfit(CMD,High[1]+100*Point);
              }
            bbb=iBars(Symbol(),Period());
           }
         if(IsNoPosition())
           {
            timestamp_close=TimeCurrent();
            state=state_idle;
           }
         break;
        }
      case state_sell2_hold:
        {
         newMark=HP(2);
         if(IsNoPosition())
           {
            if(newMark<thisBreakEven)
              {
               ModifyStopLoss(CMD,newMark);
               ModifyTakeProfit(CMD,Low[1]-100*Point);
              }
            timestamp_close=TimeCurrent();
            state=state_idle;
           }
         break;
        }
      case state_revbuy_tradesell:
        {
         //lastticket=Trade_Market(OP_SELL,timestamp_sell,2*init_lot_size,lowerbound,0,"Reverse_buy");
         lastticket=Trade_Market(OP_SELL,timestamp_sell,2*init_lot_size,Ask+0.4*ATR,0,"Reverse_buy");
         Print(IntegerToString(state)+":Reverse Order has been placed, SELL ticket #"+IntegerToString(lastticket));

         //---- transition
         if(IsSell() && IsNoBuy()) state=state_revsell_tradebuy_trail;
         if(IsNoPosition())
           {
            timestamp_close=TimeCurrent();
            state=state_idle;
           }
         break;
        }
      case state_revsell_tradebuy:
        {
         //lastticket=Trade_Market(OP_BUY,timestamp_buy,2*init_lot_size,upperbound,0,"Reverse_trail");
         lastticket=Trade_Market(OP_BUY,timestamp_buy,2*init_lot_size,Bid-0.4*ATR,0,"Reverse_trail");
         Print(IntegerToString(state)+":Reverse Order has been placed, BUY ticket #"+IntegerToString(lastticket));

         //---- transition
         if(IsBuy() && IsNoSell()) state=state_revsell_tradebuy_trail;
         if(IsNoPosition())
           {
            timestamp_close=TimeCurrent();
            state=state_idle;
           }
         break;
        }

      case  state_revbuy_tradesell_trail:
        {

         stoplosswheelbarrel(lastticket,60*Point,20*Point);

         //---- transition
         if(IsNoPosition())
           {
            timestamp_close=TimeCurrent();
            state=state_idle;
           }
         break;
        }
      case  state_revsell_tradebuy_trail:
        {

         stoplosswheelbarrel(lastticket,60*Point,20*Point);

         //---- transition
         if(IsNoPosition())
           {
            timestamp_close=TimeCurrent();
            state=state_idle;
           }
         break;
        }
     }
   _tickcount=GetTickCount()-tickcount;
   status("processing time="+DoubleToStr(_tickcount,2)+"ms");
   Comment(comment_string+comments);
//----
   return(0);
  }
//+------------------------------------------------------------------+
/*
int MAGIC_LIST_BY_SYMBOL()
{
//---
   int _magic;
   if(Symbol()=="GBPUSD")  _magic=100;
   if(Symbol()=="EURUSD")  _magic=110;
   if(Symbol()=="USDCHF")  _magic=120;
   if(Symbol()=="AUDUSD")  _magic=130;
   if(Symbol()=="NZDUSD")  _magic=140;
   if(Symbol()=="USDCAD")  _magic=150;
   if(Symbol()=="USDJPY")  _magic=160;
   
   if(Symbol()=="GBPAUD")  _magic=200;
   if(Symbol()=="GBPNZD")  _magic=210;
   if(Symbol()=="GBPCAD")  _magic=220;
   if(Symbol()=="GBPCHF")  _magic=230;
   if(Symbol()=="GBPJPY")  _magic=240;
   if(Symbol()=="EURGBP")  _magic=250;
   
   if(Symbol()=="EURAUD")  _magic=300;
   if(Symbol()=="EURNZD")  _magic=310;
   if(Symbol()=="EURCAD")  _magic=320;
   if(Symbol()=="EURCHF")  _magic=330;
   if(Symbol()=="EURJPY")  _magic=340;
   
   
//---   
   return(_magic);
}

bool IsNoPosition()
{
   if(OACount(MAGIC,OP_BUY,Symbol())==0 && OACount(MAGIC,OP_SELL,Symbol())==0) return(true);
   else return(false);
}

bool IsBuy()
{
   if(OACount(MAGIC,OP_BUY,Symbol())==1) return(true);
   else return(false);
}

bool IsBuys()
{
   if(OACount(MAGIC,OP_BUY,Symbol())>=2) return(true);
   else return(false);
}

bool IsNoBuy()
{
   if(OACount(MAGIC,OP_BUY,Symbol())==0) return(true);
   else return(false);
}

bool IsSell()
{
   if(OACount(MAGIC,OP_SELL,Symbol())==1) return(true);
   else return(false);
}

bool IsSells()
{
   if(OACount(MAGIC,OP_SELL,Symbol())>=2) return(true);
   else return(false);
}

bool IsNoSell()
{
   if(OACount(MAGIC,OP_SELL,Symbol())==0) return(true);
   else return(false);
}
*/
void status(string msg)
  {
   comments=comments+">>"+now+">>"+msg+"\n";
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderAccounting()
  {
   ArrayInitialize(OrderAcc_buy,0);
   ArrayInitialize(OrderAcc_sell,0);
   int countb=0;
   int counts=0;

   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if(OrderMagicNumber()==MAGIC)
           {
            if(OrderType()==OP_BUY)
              {
               OrderAcc_buy[countb][0]=OrderTicket();
               OrderAcc_buy[countb][1]=OrderLots();
               OrderAcc_buy[countb][2]=OrderOpenPrice();
               countb++;
              }
            if(OrderType()==OP_SELL)
              {
               OrderAcc_sell[counts][0]=OrderTicket();
               OrderAcc_sell[counts][1]=OrderLots();
               OrderAcc_sell[counts][2]=OrderOpenPrice();
               counts++;
              }
           }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BreakEvenPrice(int side)
  {
   int size;
   int i;
   double SumLots=0;
   double SumPriceLots=0;
   double breakeven=0;
   switch(side)
     {
      case OP_BUY:
        {
         size=ArraySize(OrderAcc_buy);
         for(i=0;i<size;i++)
           {
            if(OrderAcc_buy[i][0]!=0)
              {
               SumLots=SumLots+OrderAcc_buy[i][1];
               SumPriceLots=SumPriceLots+(OrderAcc_buy[i][1]*OrderAcc_buy[i][2]);
               if(SumLots>0) breakeven=SumPriceLots/SumLots;
               else Print("BreakEvenPrice:OP_BUY: error SumLots is zero!");
              }
           }
         break;
        }
      case OP_SELL:
        {
         size=ArraySize(OrderAcc_sell);
         for(i=0;i<size;i++)
           {
            if(OrderAcc_sell[i][0]!=0)
              {
               SumLots=SumLots+OrderAcc_sell[i][1];
               SumPriceLots=SumPriceLots+(OrderAcc_sell[i][1]*OrderAcc_sell[i][2]);
               if(SumLots>0) breakeven=SumPriceLots/SumLots;
               else Print("BreakEvenPrice:OP_SELL: error SumLots is zero!");
              }
           }

         break;
        }
     }
   return(breakeven);
  }
//#ft
void ftx(int ticketnumber)
  {
   double quote=0;
   double distance=0;
   double master_distance=0;
   double propose_stop=0;
   bool  price_ok=true;
   double MarkedDistance;
   double offset1,offset2;
   MarkedDistance=70*Point;
//offset1=30*Point;
   offset1=SPREAD;
   offset2=50*Point;
   if(offset2>=MarkedDistance-30*Point) offset2=30*Point;

   double minstop=MarketInfo(OrderSymbol(),MODE_STOPLEVEL)*Point;
   master_distance=150*Point;
   if(OrderSelect(ticketnumber,SELECT_BY_TICKET)==true && OrderCloseTime()==0)
     {
      if(OrderType()==OP_BUY)
        {
         quote=Bid;
         if(OrderStopLoss()==0 || OrderStopLoss()<OrderOpenPrice())
           {
            distance=Bid-OrderOpenPrice();
            if(distance>MarkedDistance)
              {
               propose_stop=OrderOpenPrice()+offset1;
              }
           }
         if(OrderStopLoss()>OrderOpenPrice())
           {
            distance=Bid-OrderStopLoss();
            if(distance>MarkedDistance)
              {
               propose_stop=Bid-offset2;
              }
           }
         propose_stop=NormalizeDouble(propose_stop,Digits);
         if(propose_stop!=0 && propose_stop<Bid && (propose_stop<OrderOpenPrice()-minstop || propose_stop>OrderOpenPrice()))
           {
            if(OrderModify(OrderTicket(),OrderOpenPrice(),propose_stop,OrderTakeProfit(),OrderExpiration(),CLR_NONE)==true)
              {
               Print("Modify order stoploss success.");
              }
           }
        }
      else if(OrderType()==OP_SELL)
        {
         quote=Ask;
         if(OrderStopLoss()==0 || OrderStopLoss()>OrderOpenPrice())
           {
            distance=OrderOpenPrice()-Ask;
            if(distance>MarkedDistance)
              {
               propose_stop=OrderOpenPrice()-offset1;
              }
           }
         if(OrderStopLoss()<OrderOpenPrice())
           {
            distance=OrderStopLoss()-Ask;
            if(distance>MarkedDistance)
              {
               propose_stop=Ask+offset2;
              }
           }
         propose_stop=NormalizeDouble(propose_stop,Digits);
         if(propose_stop!=0 && propose_stop>Ask && (propose_stop>OrderOpenPrice()+minstop || propose_stop<OrderOpenPrice()))
           {

            if(OrderModify(OrderTicket(),OrderOpenPrice(),propose_stop,OrderTakeProfit(),OrderExpiration(),CLR_NONE)==true)
              {
               Print("Modify order stoploss success.");
              }
           }
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void showmycomment_CurrentRange()
  {
   double RangeHighLow;
   lowerbound =LP(candles_range)-100*Point;
   upperbound =HP(candles_range)+100*Point;
   ATR=iATR(Symbol(),PERIOD_H1,atr_range,1);
   fastATR=iATR(Symbol(),PERIOD_H1,atr_range/2,1);
   dailyATR=iATR(Symbol(),PERIOD_D1,D1_atr_range,1);
   if(ATR<100*Point) ATR=100*Point;

   double trigger_entry_range=HP(5)-LP(5);
   trigger_entry_range=trigger_entry_range*DECPIP;
//double val=iCustom(NULL,0,"Candlestop",5,1,0);
/*
   double array_atr[4];
   array_atr[0]=iATR(Symbol(),0,atr_range,1);
   array_atr[1]=iATR(Symbol(),0,atr_range,2);
   array_atr[2]=iATR(Symbol(),0,atr_range,3);
   array_atr[3]=iATR(Symbol(),0,atr_range,4);
   ATR_Slope=GetSlope(array_atr)*100000;
   */
   RangeHighLow=xpips(HP(candles_range)-LP(candles_range));
   RangeHighLow=RangeHighLow*DECPIP;
//status("candles_range("+IntegerToString(candles_range)+")="+DoubleToStr(RangeHighLow,0)+units);
//status("TriggerRange="+DoubleToStr(trigger_entry_range,0)+units);
   status("ATR("+IntegerToString(atr_range)+")="+DoubleToStr(ATR*DECPIP,0)+units);
//status("dailyATR("+IntegerToString(D1_atr_range)+")="+DoubleToStr(dailyATR*DECPIP,0)+units);
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void showmycomment_LastTicket()
  {
   pl=OAPLPips(lastticket);
   if(OrderSelect(lastticket,SELECT_BY_TICKET)==true)
     {
      ThisOpenPrice=OrderOpenPrice();
     }
   status("Last Ticket="+IntegerToString(lastticket));
   status("Profit/Loss="+DoubleToStr(pl,1)+"pips");
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void showmycomment_timeunlocked_buy()
  {
   status("Last Time Stamp="+TimeToStr(timestamp_buy,TIME_MINUTES)+", Minutes to unlock time="+TimeToString(MinutesToUnlock_buy,TIME_MINUTES|TIME_SECONDS)+" mins");
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void showmycomment_timeunlocked_sell()
  {
   status("Last Time Stamp="+TimeToStr(timestamp_sell,TIME_MINUTES)+", Minutes to unlock time="+TimeToString(MinutesToUnlock_sell,TIME_MINUTES|TIME_SECONDS)+" mins");
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Remove_StopLoss(int ticketnumber)
  {
//Remove stop loss price first before do martingale to recovery
   status("Remove_StopLoss: Removing stoploss on ticket #"+IntegerToString(ticketnumber));
   bool selected=false;
   if(OrderSelect(ticketnumber,SELECT_BY_TICKET))
      selected=true;
   if(OrderModify(OrderTicket(),OrderOpenPrice(),0,OrderTakeProfit(),OrderExpiration(),Gray)==true && selected)
     {
      Print(IntegerToString(state)+":Remove_StopLoss: Stoploss for order #"+IntegerToString(ticketnumber)+" is now set to zero");
     }
   else
     {
      Print(IntegerToString(state)+":Error in Remove_StopLoss: Code="+IntegerToString(GetLastError()));
     }
   return;
  }
// Trade_Market(OP_BUY,0.1,"Main",0,0,timestamp_buy);
int Trade_Market(int side,datetime &_timestamp,double lot_size,double stop_price=0,double target_price=0,string comment="")
  {
   int retTicket=0;
   if(side==OP_BUY)  retTicket=Trade_Buy(Symbol(),MAGIC,lot_size,stop_price,target_price,comment);
   if(side==OP_SELL)  retTicket=Trade_Sell(Symbol(),MAGIC,lot_size,stop_price,target_price,comment);
   _timestamp=TimeCurrent();

   if(retTicket>0)
     {
      Print(IntegerToString(state)+":Trade_Market: Placed order successfully, ticket #"+IntegerToString(retTicket));
     }
   return(retTicket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void showmycomment_ListOrder_buy()
  {
   status("//------------Order List (Ticket, Lots, Price) -----------------//");
   status("// Recovery orders count="+IntegerToString(OACount(MAGIC,OP_BUY,Symbol())));
//----state's action
   OrderAccounting();
   for(int index=0;index<25;index++)
     {
      if(OrderAcc_buy[index][0]!=0)
        {
         status("//----  #"+IntegerToString(index)+" |"+DoubleToStr(OrderAcc_buy[index][0],0)+", "+DoubleToStr(OrderAcc_buy[index][1],2)+", "+DoubleToStr(OrderAcc_buy[index][2],Digits)+"  ----//");
        }
     }
//thisBreakEven=BreakEvenPrice(OP_BUY);
   if(thisBreakEven-Bid>0)
     {
      distance_Loss=MathAbs(thisBreakEven-Bid)*MathPow(10,Digits-1);
      distance_Gain=0;
     }
   else if(thisBreakEven-Bid==0)
     {
      distance_Loss=0;
      distance_Gain=0;
     }
   else
     {
      distance_Loss=0;
      distance_Gain=MathAbs(thisBreakEven-Bid)*MathPow(10,Digits-1);
     }

   status("Current breakeven price="+DoubleToStr(thisBreakEven,Digits));
   status("Distance to breakeven Loss/Gain="+DoubleToStr(distance_Loss,1)+", "+DoubleToStr(distance_Gain,1));
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void showmycomment_ListOrder_sell()
  {
   status("//------------Order List (Ticket, Lots, Price) -----------------//");
   status("// Recovery orders count="+IntegerToString(OACount(MAGIC,OP_SELL,Symbol())));
//----state's action
   OrderAccounting();
   for(int index=0;index<25;index++)
     {
      if(OrderAcc_sell[index][0]!=0)
        {
         status("//----  #"+IntegerToString(index)+" |"+DoubleToStr(OrderAcc_sell[index][0],0)+", "+DoubleToStr(OrderAcc_sell[index][1],2)+", "+DoubleToStr(OrderAcc_sell[index][2],Digits)+"  ----//");
        }
     }
//thisBreakEven=BreakEvenPrice(OP_SELL);
   if(thisBreakEven-Ask>0)
     {
      distance_Loss=0;
      distance_Gain=MathAbs(thisBreakEven-Ask)*MathPow(10,Digits-1);
     }
   else if(thisBreakEven-Ask==0)
     {
      distance_Loss=0;
      distance_Gain=0;
     }
   else
     {

      distance_Loss=MathAbs(thisBreakEven-Ask)*MathPow(10,Digits-1);
      distance_Gain=0;

     }

   status("Current breakeven price="+DoubleToStr(thisBreakEven,Digits));
   status("Distance to breakeven Loss/Gain="+DoubleToStr(distance_Loss,1)+", "+DoubleToStr(distance_Gain,1));
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Recovery_Close_All_buy()
  {
   bool close_done=false;
   Print(IntegerToString(state)+":Recovery_Close_All_buy: Commencing closing seqeunce...");
   for(int index=0;index<25;index++)
     {
      if(OrderAcc_buy[index][0]!=0)
        {
         if(OrderSelect((int)OrderAcc_buy[index][0],SELECT_BY_TICKET)==true)
           {
            status("Selected Order #"+DoubleToStr(OrderAcc_buy[index][0],0)+", OK to close");
            close_done=OrderClose(OrderTicket(),OrderLots(),Bid,5,Salmon);
            while(IsTradeContextBusy())
              {
               status("Trade context is busy... (sleeping zZz)");
               Sleep(20);
              }
            if(close_done==true) Print(IntegerToString(state)+
               ":Recovery_Close_All_buy: ._closed ticket #"+IntegerToString(OrderTicket())+
               ", CloseTime="+TimeToStr(OrderCloseTime(),TIME_MINUTES));
           }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Recovery_Close_All_sell()
  {
   bool close_done=false;
   Print(IntegerToString(state)+":Recovery_Close_All_sell: Commencing closing seqeunce...");
   for(int index=0;index<25;index++)
     {
      if(OrderAcc_sell[index][0]!=0)
        {
         if(OrderSelect((int)OrderAcc_sell[index][0],SELECT_BY_TICKET)==true)
           {
            status("Selected Order #"+DoubleToStr(OrderAcc_sell[index][0],0)+", OK to close");
            close_done=OrderClose(OrderTicket(),OrderLots(),Ask,5,PaleGreen);
            while(IsTradeContextBusy())
              {
               status("Trade context is busy... (sleeping zZz)");
               Sleep(20);
              }
            if(close_done==true) Print(IntegerToString(state)+
               ":Recovery_Close_All_sell: ._closed ticket #"+IntegerToString(OrderTicket())+
               ", CloseTime="+TimeToStr(OrderCloseTime(),TIME_MINUTES));
           }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTimeUnlocked_buy()
  {
   if(TimeCurrent()>timestamp_buy+HoldMinutes*60 && TimeCurrent()>timestamp_close+HoldMinutes*60)
      return(true);
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTimeUnlocked_sell()
  {
   if(TimeCurrent()>timestamp_sell+HoldMinutes*60 && TimeCurrent()>timestamp_close+HoldMinutes*60)
      return(true);
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTakeProfit(int typeorder,double newtakeprofit)
  {
   int ticket=0;
   bool select_ok=false;
   bool price_ok=true;
   bool mod_ok=false;
   int retError=0;
   for(int i=0;i<25;i++)
     {
      if(typeorder==OP_BUY)
        {
         ticket=(int)OrderAcc_buy[i][0];
        }
      else
      if(typeorder==OP_SELL)
        {
         ticket=(int)OrderAcc_sell[i][0];
        }

      select_ok=OrderSelect(ticket,SELECT_BY_TICKET);

      newtakeprofit=NormalizeDouble(newtakeprofit,(int)MarketInfo(OrderSymbol(),MODE_DIGITS));

      if(MathAbs(newtakeprofit-OrderTakeProfit())<10*Point) price_ok=false;
      if(MathAbs(newtakeprofit-OrderOpenPrice())<10*Point) price_ok=false;
      if(MathAbs(newtakeprofit-OrderStopLoss())<10*Point) price_ok=false;

      if(newtakeprofit==OrderTakeProfit() || newtakeprofit==OrderOpenPrice() || newtakeprofit==OrderStopLoss()) price_ok=false;

      if(ticket>0 && MathAbs(newtakeprofit-OrderTakeProfit())>10*Point && select_ok && price_ok)
        {
         mod_ok=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),newtakeprofit,OrderExpiration(),PaleGreen);
         retError=GetLastError();
         if(retError!=0)
           {
            Print(now+", ModifyTakeProfit(),"+" Fail ModifyOrder() code"+IntegerToString(retError));
           }
        }
      while(IsTradeContextBusy())
        {
         Sleep(100);
        }

     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int hr_sec(int hours)
  {
   return(hours*60*60);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyStopLoss(int typeorder,double newstoplosslevel)
  {
   int ticket=0;
   bool select_ok=false;
   bool price_ok=true;
   bool mod_ok=false;
   int retError=0;
   int STOPLEVEL;
   STOPLEVEL=(int)MarketInfo(OrderSymbol(),MODE_STOPLEVEL);
   for(int i=0;i<25;i++)
     {
      if(typeorder==OP_BUY)
        {
         ticket=(int)OrderAcc_buy[i][0];
        }
      else
      if(typeorder==OP_SELL)
        {
         ticket=(int)OrderAcc_sell[i][0];
        }

      select_ok=OrderSelect(ticket,SELECT_BY_TICKET);

      newstoplosslevel=NormalizeDouble(newstoplosslevel,(int)MarketInfo(OrderSymbol(),MODE_DIGITS));

      if(MathAbs(newstoplosslevel-OrderStopLoss())<10*Point) price_ok=false;
      if(newstoplosslevel==OrderOpenPrice())  price_ok=false;
      if(newstoplosslevel==OrderTakeProfit())  price_ok=false;

      //if(ticket>0 && MathAbs(newtakeprofit-OrderTakeProfit())>pips(1) && select_ok)
      if(
         ticket>0 && select_ok && price_ok
         )
        {
         if(OrderType()==OP_BUY && newstoplosslevel<OrderOpenPrice() && newstoplosslevel>OrderOpenPrice()-STOPLEVEL*Point)
           {
            newstoplosslevel=OrderOpenPrice()+10*Point;
           }
         if(OrderType()==OP_SELL && newstoplosslevel>OrderOpenPrice() && newstoplosslevel<OrderOpenPrice()+STOPLEVEL*Point)
           {
            newstoplosslevel=OrderOpenPrice()-10*Point;
           }

         mod_ok=OrderModify(OrderTicket(),OrderOpenPrice(),newstoplosslevel,OrderTakeProfit(),OrderExpiration(),PaleGreen);
         retError=GetLastError();
         if(retError!=0)
           {
            Print(now+", ModifyStopLoss(),"+" Fail ModifyOrder() code"+IntegerToString(retError));
           }
        }
      while(IsTradeContextBusy())
        {
         Sleep(100);
        }

     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RecordMaxGAINLOSS()
  {
   string t;

   if(pl>max_gain && pl>0) max_gain=pl;
   if(pl<max_loss && pl<0) max_loss=pl;

   if(max_loss!=0) RRR=MathAbs(max_gain/max_loss);  else RRR=-1;
   t="RRR"+DoubleToStr(RRR,2)+", MAXG"+DoubleToStr(max_gain,1)+", MAXL"+DoubleToStr(max_loss,1);

   status(t);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderOpenTooLongAndNotMove()
  {
   if(TimeCurrent()-laststamp>hr_sec(2) && TimeCurrent()-laststamp>hr_sec(8) && RRR!=0)
     {
      if(1/RRR>=1.5 && -max_loss>=10 && pl>=5)
        {
         if(OrderClose(lastticket,OrderLots(),Bid,5,DarkGray)==true)
           {
            Print("Close order#"+IntegerToString(lastticket)+", REASON:OrderOpenTooLongAndNotMove(), LOGIC1");
            if(state==state_buy1) BlockBuyUntilTime=TimeCurrent()+15*60;
            if(state==state_sell1) BlockSellUntilTime=TimeCurrent()+15*60;
           }
        }
     }

   if(TimeCurrent()-laststamp>hr_sec(3) && RRR!=0)
     {
      if(1/RRR>=5 && -max_loss>=30 && pl>=-15)
        {
         if(OrderClose(lastticket,OrderLots(),Bid,5,Goldenrod)==true)
           {
            Print("Close order#"+IntegerToString(lastticket)+", REASON:OrderOpenTooLongAndNotMove(), LOGIC2");
            if(state==state_buy1) BlockBuyUntilTime=TimeCurrent()+15*60;
            if(state==state_sell1) BlockSellUntilTime=TimeCurrent()+15*60;
           }
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BuyThenImmediateProfit()
  {
   bool stochOBOS=false;
   double piptotake;
//piptotake=xpips(fastATR);
   piptotake=10;
//if(xpips(fastATR)<=10)   piptotake=5;
   if(TimeCurrent()-laststamp<hr_sec(1))
     {
      if(pl>=piptotake)
        {
         if(OrderClose(lastticket,OrderLots(),Bid,5,Olive)==true)
           {
            Print("Close order#"+IntegerToString(lastticket)+", REASON:BuyThenImmediateProfit()");
            if(state==state_buy1)
              {
               BlockBuyUntilTime=TimeCurrent()+15*60;
               //state=state_revbuy_tradesell;
              }
            if(state==state_sell1)
              {
               BlockSellUntilTime=TimeCurrent()+15*60;
               //state=state_revsell_tradebuy;
              }
           }

        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CummPL()
  {
   string t;
   switch(state)
     {
      case state_buy2:
        {
         cummpl=Bid-thisBreakEven;
         break;
        }
      case state_sell2:
        {
         cummpl=thisBreakEven-Ask;
         break;
        }
     }
   switch(Digits)
     {
      case  5:
        {
         cummpl=cummpl*MathPow(10,Digits-1);
         break;
        }
      case  4:
        {
         cummpl=cummpl*MathPow(10,Digits);
         break;
        }

      default:
         break;
     }

   t="Cumm PL (pips)="+DoubleToStr(cummpl,2);
   status(t);
  }
//#common
void CommonSingleOrderState()
  {
//ftx(lastticket);
   stoplosswheelbarrel(lastticket,60*Point,20*Point);
   if(iBars(Symbol(),Period())>bbb)
     {

      OrderOpenTooLongAndNotMove();
      BuyThenImmediateProfit();
      //PositionLossAfterHrsthenClose();  
      bbb=iBars(Symbol(),Period());
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PercentileSafetyLevel(int side,int barnumber)
  {
   double ceiling=HP(barnumber);
   double floorx=LP(barnumber);
   double mkt=Bid;
   double percentile=0;
   double per_b;
   double per_s;
   string t="";
   per_b=(mkt-floorx)/(ceiling-floorx)*100;
   per_s=(ceiling-mkt)/(ceiling-floorx)*100;
   t="(pips)BLK"+DoubleToStr(xpips(ceiling-floorx),1);
   t=t+", PERTB"+DoubleToStr(per_b,1);
   t=t+", PERTS"+DoubleToStr(per_b,1);
   if(side==OP_BUY)
     {
      percentile=per_b;
     }
   if(side==OP_SELL)
     {
      percentile=per_s;
     }
   status(t);
   percentile=NormalizeDouble(percentile,2);
   return(percentile);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderCloseAll(int side)
  {
   int ticket=0;

   for(int i=0;i<25;i++)
     {
      if(side==OP_BUY)  ticket=(int)OrderAcc_buy[i][0];
      if(side==OP_SELL)  ticket=(int)OrderAcc_sell[i][0];
      if(OrderSelect(ticket,SELECT_BY_TICKET)==true)
        {
         if(OrderClose(OrderTicket(),OrderLots(),Bid,5,DarkGray)==true)
           {
            Print("close order, ticket#"+IntegerToString(OrderTicket())+", REASON:OrderCloseAll()");
           }
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PositionLossAfterHrsthenClose()
  {
   if(TimeCurrent()-laststamp>hr_sec(1) && TimeCurrent()-laststamp<hr_sec(3))
     {
      if(-max_loss>30 && RRR<0.1 && pl<-10)
        {
         if(OrderClose(lastticket,OrderLots(),Bid,5,DarkGray)==true)
           {
            Print("Close order#"+IntegerToString(lastticket)+", REASON:PositionLossAfterHrsthenClose()");
            if(state==state_buy1) BlockBuyUntilTime=TimeCurrent()+HoldMinutes*60;
            if(state==state_sell1) BlockSellUntilTime=TimeCurrent()+HoldMinutes*60;
           }
        }
     }
  }
//#runcomment
void Run_Comment()
  {
//----Signal Watchs & Infomartion/Comment
   switch(state)
     {
      case state_idle:
        {
         //----state info
         status("wating for signal...");
         showmycomment_CurrentRange();
         break;
        }
      case state_buy1:
        {
         status(".. trailing stop loss for buy pos");
         showmycomment_CurrentRange();
         showmycomment_timeunlocked_buy();
         showmycomment_LastTicket();
         RecordMaxGAINLOSS();

         break;
        }
      case state_sell1:
        {
         status(".. trailing stop loss for sell pos");
         showmycomment_CurrentRange();
         showmycomment_timeunlocked_sell();
         showmycomment_LastTicket();
         RecordMaxGAINLOSS();

         break;
        }
      case state_await_buy:
        {
         status(".. trailing stop loss for buy pos");
         showmycomment_CurrentRange();
         showmycomment_timeunlocked_buy();
         showmycomment_LastTicket();
         break;
        }
      case state_await_sell:
        {
         status(".. trailing stop loss for sell pos");
         showmycomment_CurrentRange();
         showmycomment_timeunlocked_sell();
         showmycomment_LastTicket();
         break;
        }
      case state_buy2:
        {
         status(".. recovery buy mode");
         showmycomment_CurrentRange();
         showmycomment_timeunlocked_buy();
         showmycomment_LastTicket();
         showmycomment_ListOrder_buy();
         CummPL();
         break;
        }
      case state_sell2:
        {
         status(".. recovery sell mode");
         showmycomment_CurrentRange();
         showmycomment_timeunlocked_sell();
         showmycomment_LastTicket();
         showmycomment_ListOrder_sell();
         CummPL();
         break;
        }
      case state_buy2_hold:
        {
         status(".. recovery buy mode");
         showmycomment_CurrentRange();
         showmycomment_timeunlocked_buy();
         showmycomment_LastTicket();
         showmycomment_ListOrder_buy();
         CummPL();
         break;
        }
      case state_sell2_hold:
        {
         status(".. recovery sell mode");
         showmycomment_CurrentRange();
         showmycomment_timeunlocked_sell();
         showmycomment_LastTicket();
         showmycomment_ListOrder_sell();
         CummPL();
         break;
        }

      case state_revbuy_tradesell:
        {
         status(".. reversing from buy to sell mode");
         showmycomment_CurrentRange();
         showmycomment_timeunlocked_sell();
         showmycomment_LastTicket();
         break;
        }
      case state_revsell_tradebuy:
        {
         status(".. reversing from sell to buy mode");
         showmycomment_CurrentRange();
         showmycomment_timeunlocked_buy();
         showmycomment_LastTicket();
         break;
        }
      case  state_revbuy_tradesell_trail:
        {
         status(".. trailing stop loss for reversed-side order, buy mode");
         showmycomment_CurrentRange();
         showmycomment_timeunlocked_buy();
         showmycomment_LastTicket();
         break;
        }
      case  state_revsell_tradebuy_trail:
        {
         status(".. trailing stop loss for reversed-side order, sell mode");
         showmycomment_CurrentRange();
         showmycomment_timeunlocked_sell();
         showmycomment_LastTicket();
         break;
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Run_State_Transition()
  {
   switch(state)
     {
      case state_idle:
        {
         break;
        }
      case state_buy1:
        {
         break;
        }
      case state_sell1:
        {
         break;
        }
      case state_await_buy:
        {
         break;
        }
      case state_await_sell:
        {
         break;
        }
      case state_buy2:
        {
         break;
        }
      case state_sell2:
        {
         break;
        }
      case state_buy2_hold:
        {
         break;
        }
      case state_sell2_hold:
        {
         break;
        }
      case state_revbuy_tradesell:
        {
         break;
        }
      case state_revsell_tradebuy:
        {
         break;
        }
      case state_revbuy_tradesell_trail:
        {
         break;
        }
      case state_revsell_tradebuy_trail:
        {
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Run_TimeStampControl()
  {
   switch(state)
     {
      case state_idle:                 laststamp=timestamp_close;    break;
      case state_buy1:                 laststamp=timestamp_buy;      break;
      case state_sell1:                laststamp=timestamp_sell;     break;
      case state_await_buy:            laststamp=timestamp_buy;      break;
      case state_await_sell:           laststamp=timestamp_sell;     break;
      case state_buy2:
        {
         laststamp=timestamp_buy;      MultiOrderStateTimeStamp=MultiOrderStateTimeStamp_buy;
         MultiOrderState_Age=TimeCurrent()-MultiOrderStateTimeStamp;
         break;
        }
      case state_sell2:
        {
         laststamp=timestamp_sell;      MultiOrderStateTimeStamp=MultiOrderStateTimeStamp_sell;
         MultiOrderState_Age=TimeCurrent()-MultiOrderStateTimeStamp;
         break;
        }
      case state_buy2_hold:
        {
         laststamp=timestamp_buy;      MultiOrderStateTimeStamp=MultiOrderStateTimeStamp_buy;
         MultiOrderState_Age=TimeCurrent()-MultiOrderStateTimeStamp;
         break;
        }
      case state_sell2_hold:
        {
         laststamp=timestamp_sell;      MultiOrderStateTimeStamp=MultiOrderStateTimeStamp_sell;
         MultiOrderState_Age=TimeCurrent()-MultiOrderStateTimeStamp;
         break;
        }
      case state_revbuy_tradesell:          laststamp=timestamp_buy;      break;
      case state_revsell_tradebuy:         laststamp=timestamp_sell;     break;
      case state_revbuy_tradesell_trail:    laststamp=timestamp_buy;      break;
      case state_revsell_tradebuy_trail:   laststamp=timestamp_sell;     break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Run_CurrentStateShortCode()
  {
   switch(state)
     {
      case state_idle:                 now="I";    break;
      case state_buy1:                 now="B1";    break;
      case state_sell1:                now="S1";    break;
      case state_await_buy:            now="B0";    break;
      case state_await_sell:            now="S0";    break;
      case state_buy2:                 now="B2";    break;
      case state_sell2:                now="S2";    break;
      case state_buy2_hold:                 now="B2H";    break;
      case state_sell2_hold:                now="S2H";    break;
      case state_revbuy_tradesell:          now="RB";      break;
      case state_revsell_tradebuy:         now="RS";      break;
      case state_revbuy_tradesell_trail:    now="RBT";   break;
      case state_revsell_tradebuy_trail:   now="RST";   break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Run_OrderCommand()
  {
   switch(state)
     {
      case state_idle:                 CMD=-1;    break;
      case state_buy1:                 CMD=OP_BUY;    break;
      case state_sell1:                CMD=OP_SELL;    break;
      case state_await_buy:            CMD=OP_BUY;    break;
      case state_await_sell:           CMD=OP_SELL;    break;
      case state_buy2:                 CMD=OP_BUY;    break;
      case state_sell2:                CMD=OP_SELL;    break;
      case state_buy2_hold:                 CMD=OP_BUY;    break;
      case state_sell2_hold:                CMD=OP_SELL;    break;
      case state_revbuy_tradesell:         CMD=OP_SELL;    break;
      case state_revsell_tradebuy:         CMD=OP_BUY;    break;
      case state_revbuy_tradesell_trail:   CMD=OP_SELL;    break;
      case state_revsell_tradebuy_trail:   CMD=OP_BUY;    break;
     }
  }
//+------------------------------------------------------------------+
void OpenTwoPending(double xlot,string ordercomment,int buyoffsetpts,int selloffsetpts,int minute_to_exp=30)
  {
//int u;
//int d;

   double nt;
   nt=trend();
   int offsetbuy=0;
   int offsetsell=0;
   double lotmultibuy=1;
   double lotmultisell=1;
   if(nt>150)
     {
      offsetbuy=0;
      offsetsell=100;
      lotmultibuy=1;
      lotmultisell=2;
     }
   if(nt<-150)
     {
      offsetbuy=100;
      offsetsell=0;
      lotmultibuy=2;
      lotmultisell=1;
     }
   pendingbuyticket=OrderSend(Symbol(),OP_BUYSTOP,xlot*lotmultibuy,
                              Ask+(buyoffsetpts+offsetbuy)*Point,
                              2,0,0,ordercomment,MAGIC,TimeCurrent()+minute_to_exp*60);
   pendingsellticket=OrderSend(Symbol(),OP_SELLSTOP,xlot*lotmultisell,
                               Bid-(selloffsetpts+offsetsell)*Point,
                               2,0,0,ordercomment,MAGIC,TimeCurrent()+minute_to_exp*60);

  }
//+------------------------------------------------------------------+
