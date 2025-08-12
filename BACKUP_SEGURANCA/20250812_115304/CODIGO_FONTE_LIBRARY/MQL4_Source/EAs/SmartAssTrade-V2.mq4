//+------------------------------------------------------------------+
//|                                             SmartAssTrade-V2.mq4 |
//|                 Copyright 2014,  Roy Philips Jacobs ~ 03/09/2014 |
//|                            http://www.gol2you.com ~ Forex Videos |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014,  Roy Philips Jacobs ~ Created 03/09/2014"
#property link      "http://www.gol2you.com ~ Forex Videos"
#property version   "2.00"
//--
#property description "The SmartAssTrade-V2 Forex Expert Advisor is SmartAssTrade EA Version 2 in Code Base MQL4"
#property description "SmartAssTrade-V2 EA Only working on M30 Timeframes or PERIOD_M30"
#property description "If you trade use SmartAssTrade-V2 EA on others Timeframes, may you will always loss."
//--
#property description "In any case the author is not liable for any damage or loss whatsoever."
#property description "Sometimes high profits can be disrupted by a row of losses."
#property description "In the Forex online trading, it is impossible to always profit."
//--
#property description "-------Use this Expert Advisor at your own risk.-------"
//---
#include <stderror.mqh>
#include <stdlib.mqh>
//--- User Input
input string     SmartAssTradeV2 = "Copyright © 2014 3RJ ~ Roy Philips-Jacobs";
input string   SmartAssTradeV2TF = "SmartAssTrade-V2 EA's Only Use on M30 Timeframes";
input int  SmartAssTradeV2Period = PERIOD_M30;
extern bool          FridayTrade = True; // If True, EA still trading at Friday
input string    OptimizationLots = "Set LotsOptimization=True";
extern bool     LotsOptimization = True; // If True, Lots wil calculation by EA, default Lots size = 0.01"
extern double               Lots = 0.01; // If LotsOptimization=False, Lots adjusted by user
extern int          MaxOpenOrder = 12; // Maximum Allowed for Open Order (Maximum Pairs to Trade = 12 pairs)
// PAIRS: EURAUD,AUDUSD,EURUSD,NZDUSD,GBPUSD,GBPCHF,USDCHF,USDCAD,USDJPY,GBPJPY,EURJPY,EURGBP //
input string   AutomaticSystemTP = "Set AutomaticTakeProfit=True or False";
extern bool  AutomaticTakeProfit = True; // TP will calculation by EA and Automatic TP by EA
extern bool  NoMinimumTakeProfit = False; // True or False -> If Set True, 100% TP by EA not use minimum TP.
input string     MinimumSystemTP = "If Set NoMinimumTakeProfit=False"; // TP by EA on minimum TP values
extern double          MinimumTP = 27; // Minimum TP by EA on the AutomaticTakeProfit=True function, default value 27
input string      ManualSystemTP = "If Set AutomaticTakeProfit=False"; // TP by Terminal MT4 (same as manual trading)
extern double         TakeProfit = 35; // TP by System, values can adjust by user, default value 35
input string   AutomaticSystemSL = "Set AutomaticStopLoss=True";
extern bool    AutomaticStopLoss = True; // SL will calculation by EA
input string      ManualSystemSL = "If Set AutomaticStopLoss=False"; // SL values can adjusted by user
extern double           StopLoss = 62; // SL adjusted by user, default value 62
extern bool      UseTrailingStop = False; // Use Trailing Stop, True (Yes) or False (Not)
extern double       TrailingStop = 30.0; // If Use Trailing Stop True, input Trailing Stop Value, default value 30
extern double   TrailingStopStep = 1.0; // Input Trailing Stop Step Value (default 1.0)
//---
//--- Global scope
double digit,lot,pp;
double AcEq,sl,tp,minlot;
double tsstv,tstpv,trstart;
double slA,slB,tpA,tpB,tpAB;
double lastAsk,lastBid,dev,Mnt;
double difB,difS,pBo,pSo,pdifB,pdifS;
//---
bool nomintp;
bool NoOrder,TrlStp;
bool lotopt,opttp,autsl;
bool mdHC,mdLC,mdUp,mdDn;
bool SignalBuy,SignalSell;
//---
//-- MqlTick variables
double ask; // Current Bid price
double bid; // Current Ask price
datetime time; // Time of the last prices update
double last; // Price of the last deal (Last)
ulong volume; // Volume for the current Last price
//---
int trx;
int OpOrd;
int copied;
int satmagic=3699; // magic number
int totfr,codB,codS;
int hb,hs,ob,os,s,ip,ox;
int totalord,totalpft,totalhst;
//---
string comB;
string comS;
string CopyR;
string symbol;
//---
void EventSetTimer();
//----
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//----
   symbol=Symbol(); 
   CopyR="Copyright © 2014 3RJ ~ Roy Philips-Jacobs";
   if(SmartAssTradeV2!=CopyR) {return(0);}
//---
   //-- Checking the digit Point
   digit=Digits;
   if (digit==3 || digit==5)
      {pp=Point*10; dev=0.00;}
   else {pp=Point; dev=0.00;}
//---
   difB=0.8;
   difS=0.8;
   totfr=1;
   ox=1;
   hb=0;
   hs=0;
   ob=0;
   os=0;
   trx=0;
//---
   NoOrder=true;
   lotopt=LotsOptimization;
   opttp=AutomaticTakeProfit;
   autsl=AutomaticStopLoss;
   TrlStp=UseTrailingStop;
   nomintp=NoMinimumTakeProfit;
   OpOrd=MaxOpenOrder/(MaxOpenOrder*0.5); // safety Lots for trade
   //--
   tstpv=NormalizeDouble(TrailingStop*pp,digit);
   tsstv=NormalizeDouble(TrailingStopStep*pp,digit);
   trstart=NormalizeDouble((TrailingStop*0.50)*pp,digit);  
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//----
//+------------------------------------------------------------------+
//| expert proccess working function                                 |
//+------------------------------------------------------------------+
//----
void LotOpt() //-- function: calculation Optimization Lots
   {
//----
      if(lotopt)
        {
          //--
          AcEq=AccountEquity();
          minlot=MarketInfo(symbol,MODE_MINLOT);
          if(AcEq<=1000.00) {lot=NormalizeDouble(MarketInfo(symbol,MODE_MINLOT),2);}
          else {lot=NormalizeDouble((MathFloor(AcEq/100)*0.001)/OpOrd,2);}
          //--
          if(lot<minlot) {lot=NormalizeDouble(MarketInfo(symbol,MODE_MINLOT),2);}
          //--
        }
      //--
      else lot=Lots;
      //---
      return;
//----
   } //-end LotOpt()
//---------//

void OptSL() //-- function: calculation Stop Loss 
   {   
//----
      if(!autsl) {sl=StopLoss*pp;}
      //--
      else {sl=62*pp;}
      //--
      return;
//----
   } //-end OptSL()
//---------//

void CalcTP() //-- function: for calculation Automatic Take Profit.
   { 
//----
      RefreshRates();
      //--
      double dvab=Ask-Bid;
      //--
      if(opttp && nomintp)
        {      
          //--
          tp=(35*pp)-dvab;
          //--
          if(dvab<=5*pp) {tpAB=tp-(7*pp);}
          else {tpAB=tp-(11*pp);}
          //--
        }
      if(opttp && !nomintp) 
        {
          //--
          tp=(35*pp)-dvab;     
          tpAB=pp*MinimumTP;
          //--
        }
      //--
      if(!opttp) {tp=TakeProfit*pp;}
      //--
      RefreshRates();
      pBo=High[0]-Close[0];
      pSo=Close[0]-Low[0];
      //--
      pdifB=pp*difB;
      pdifS=pp*difS;
      mdHC=(pBo>pdifB);
      mdLC=(pSo>pdifS);
      mdUp=(Close[0]<(lastBid-pdifB));
      mdDn=(Close[0]>(lastAsk+pdifS));
      //--
      return;
//----
   } //-end CalcTP()
//---------//

void CkOpen() //-- function: CheckOpenTrade.
   {
//----
      totalord=OrdersTotal();
      ob=0; 
      os=0;
      //--
      for (s=0; s<totalord; s++)
          {
             if (OrderSelect(s,SELECT_BY_POS,MODE_TRADES)==True)
                {
                   if (OrderSymbol()==symbol && OrderMagicNumber()==satmagic)
                      {
                        //--
                        if (OrderType()==OP_BUY) {ob++; hb++;}
                        if (OrderType()==OP_SELL) {os++; hs++;}
                        //--
                      }
                }
          }
     //--
     return;
//----
   } //-end CkOpen()
//---------//

void CkClose() //-- function: CheckOrderClose.
   {
//----
      CkOpen();
      datetime octm;
      totalhst=OrdersHistoryTotal();
      //--
      for (s=0; s<totalhst; s++)   
          {
            //--
            if(OrderSelect(s,SELECT_BY_POS,MODE_HISTORY)==True)
              {
                if(OrderSymbol()==symbol && OrderMagicNumber()==satmagic)
                  {
                    //--
                    if(OrderType()==OP_BUY)
                      {
                        RefreshRates();
                        octm=OrderCloseTime();
                        if(hb>0 && ob==0 && octm>0)
                          {
                            Print("-----CLOSED BUY ORDER ",symbol," - Instant Close By System..OK!");
                            PlaySound("ping.wav");
                            hb=0;
                            ox=1;
                            totfr=1;
                            trx=0;
                            break;
                          }                             
                      }
                    //--
                    if(OrderType()==OP_SELL)
                      {
                        RefreshRates();
                        octm=OrderCloseTime();
                        if(hs>0 && os==0 && octm>0)
                          {
                            Print("-----CLOSED SELL ORDER ",symbol," - Instant Close By System..OK!");
                            PlaySound("ping.wav");
                            hs=0;
                            ox=1;
                            totfr=1;
                            trx=0;
                            break;
                          }                                
                      }
                    //--                        
                  }
              }
            //--
          }
     //---
     return;
//----
   } //-end CkClose()
//---------//

void SmartAss() //-- function: Check trend and calculation order every 30 minutes (TF M30)
   {
//----
     //--
     ResetLastError();
     RefreshRates();
     //--
     SignalBuy=false;
     SignalSell=false;
     bool Upward;
     bool Dnward;
     int upm,dnm;
     int osb,oss,x;
     //--
     codB=0;
     codS=0;
     int TFX[]={1,5,15,30,60};
     //--
     for(x=0;x<5;x++)
       {
          if (iOsMA(symbol,TFX[x],12,26,9,0,0)>iOsMA(symbol,TFX[x],12,26,9,0,1))
             {osb++;}
          if (iOsMA(symbol,TFX[x],12,26,9,0,0)<iOsMA(symbol,TFX[x],12,26,9,0,1))
             {oss++;}
          //--
          if(iMA(symbol,TFX[x],20,0,0,0,0)>iMA(symbol,TFX[x],20,0,0,1,0))
             {upm++;}
          if(iMA(symbol,TFX[x],20,0,0,0,0)<iMA(symbol,TFX[x],20,0,0,1,0)) 
             {dnm++;}                       
       }
     //--
     if (osb>=4 && upm>=4) {Upward=true; codB=1;}
     if (oss>=4 && dnm>=4) {Dnward=true; codS=1;}
     //-
     if (osb==5 && upm==5) {Upward=true; codB=2;}
     if (oss==5 && dnm==5) {Dnward=true; codS=2;}
     //--
     RefreshRates();
     double wpr0=100-MathAbs(iWPR(symbol,30,26,0));
     double wpr1=100-MathAbs(iWPR(symbol,30,26,1));
     double rsi0=iRSI(symbol,30,14,0,0);
     double rsi1=iRSI(symbol,30,14,0,1);
     bool wprmb=((wpr0<90.0)&&(wpr0>wpr1))&&((rsi0<77.0)&&(rsi0>rsi1));
     bool wprms=((wpr0>10.0)&&(wpr0<wpr1))&&((rsi0>23.0)&&(rsi0<rsi1));
     //----
     //--
     CkOpen();
     Mnt=(double)Minute();
     //--
     if((ob+os==0)&&(ox+totfr==0)&&(NoOrder==false)&&(MathMod(Mnt,30.0)>2.0))
       {
         //--
         if((Upward==true)&&(codB!=0)&&(wprmb)) {SignalBuy=true;}
         //---
         if((Dnward==true)&&(codS!=0)&&(wprms)) {SignalSell=true;}
         //--
        }
     //--
     if(SignalBuy) {OrdBuy();} // New Order BUY
     //--
     if(SignalSell) {OrdSell();} // New Order SELL
     //--
     return;
//----
   } //--end SmartAss()
//---------//

void OrdBuy() //-- function: Open order if price was up
   {
//----
      CkOpen();
      LotOpt();
      OptSL();
      CalcTP();
      comB=StringConcatenate(WindowExpertName()," #BUY#ins",(string)codB); // buy orders comments
      //--
      if(ob+os==0)
         {
           //-- Error checking
           if((AccountFreeMarginCheck(symbol,OP_BUY,lot)<=0) || (GetLastError()==134))
             {Print("-----OPEN NEW BUY ORDER ",symbol," - NOT ENOUGH MONEY..!"); ResetLastError(); return;}
           //--
           else  
             {  
               //--
               ResetLastError();
               int error;
               bool result;
               RefreshRates();
               ask=MarketInfo(symbol,MODE_ASK);
               lastBid=ask;
               slA=NormalizeDouble(ask-sl,digit);
               tpA=NormalizeDouble(ask+tp,digit);
               //--
               result=OrderSend(symbol,OP_BUY,lot,ask,dev,slA,tpA,comB,satmagic,0,clrGreen);
               //--
               if(result!=TRUE) {error=GetLastError();}
               if(error>0||result!=true)
                 {
                   //--
                   ResetLastError();
                   Sleep(2000);
                   RefreshRates(); 
                   ask=MarketInfo(symbol,MODE_ASK);
                   lastBid=ask;
                   slA=NormalizeDouble(ask-sl,digit);
                   tpA=NormalizeDouble(ask+tp,digit);
                   result=OrderSend(symbol,OP_BUY,lot,ask,dev,slA,tpA,comB,satmagic,0,clrGreen);
                   error=GetLastError();
                   if(error>0)
                     {
                       Print("Failed to Open New BUY ORDER ",symbol,"! Error code = ",
                       GetLastError(), ", ",ErrorDescription(error));
                       ResetLastError();
                       return;
                     }                            
                 }
               //--
               if(error==0 && result==true)
                 {    
                   Print("-----SmartAssTrade-V2 EA ~ has Opened New BUY ORDER ",symbol,", Buy Instruction: ",codB," - OK!");
                   PlaySound("gun.wav");
                   hb=1;
                   trx=0;
                   ox++;
                   totfr++;
                 }
             }
         }
      //--
      return;
//----
   } //-end OrdBuy() 
//---------//

void OrdSell() //-- function: Open order if price was down
   {
//----
      CkOpen();
      LotOpt();
      OptSL();
      CalcTP();
      comS=StringConcatenate(WindowExpertName()," #SELL#ins",(string)codS); // sell orders comments
      //--
      if(os+ob==0)
        {
          //-- Error checking
          if ((AccountFreeMarginCheck(symbol,OP_SELL,lot)<=0) || (GetLastError()==134))
             {Print("-----OPEN NEW SELL ORDER ",symbol," - NOT ENOUGH MONEY..!"); ResetLastError(); return;}
          else
             {
               //--
               ResetLastError();
               int error;
               bool result;
               RefreshRates();
               bid=MarketInfo(symbol,MODE_BID);
               lastAsk=bid;             
               slB=NormalizeDouble(bid+sl,digit);
               tpB=NormalizeDouble(bid-tp,digit);
               //--
               result=OrderSend(symbol,OP_SELL,lot,bid,dev,slB,tpB,comS,satmagic,0,clrRed);
               //--
               if(result!=true) {error=GetLastError();}
               if(error>0||result!=true)
                 {
                   //--
                   ResetLastError();
                   Sleep(2000);
                   RefreshRates(); 
                   bid=MarketInfo(symbol,MODE_BID);
                   lastAsk=bid;
                   slB=NormalizeDouble(bid+sl,digit);
                   tpB=NormalizeDouble(bid-tp,digit);
                   result=OrderSend(symbol,OP_SELL,lot,bid,dev,slB,tpB,comS,satmagic,0,clrRed);
                   error=GetLastError();
                   if(error>0)
                     {
                       Print("Failed to Open New SELL ORDER ",symbol,"! Error code = ",
                       GetLastError(), ", ",ErrorDescription(error));
                       ResetLastError();
                       return;
                     }                            
                 }
               //--
               if(error==0 && result==true)
                 {    
                   Print("-----SmartAssTrade-V2 EA ~ has Opened New SELL ORDER ",symbol,", Sell Instruction: ",codS," - OK!");
                   PlaySound("gun.wav");
                   hs=1;
                   trx=0;
                   ox++;
                   totfr++;
                 }
             }
        }
      //--
      return;
//----
   } //-end OrdSell()
//---------//

void ProfitNor() //-- function: Check if order is profit.
   {
//----
      int error;
      bool result,trest;
      totalpft=OrdersTotal()-1;
      for(ip=totalpft; ip>=0; ip--)
         {
           if(OrderSelect(ip,SELECT_BY_POS,MODE_TRADES)==True)
             {
               if(OrderSymbol()==symbol && OrderMagicNumber()==satmagic)
                 {
                   if(OrderType()==OP_BUY)
                     {
                       //---
                       CalcTP();
                       //--
                       RefreshRates();
                       bid=MarketInfo(symbol,MODE_BID);
                       if(((OrderOpenPrice()<(bid-tpAB)) && mdHC)) //-check if order buy is profit 
                         {
                           RefreshRates();
                           bid=MarketInfo(symbol,MODE_BID);
                           result=OrderClose(OrderTicket(),OrderLots(),bid,dev,clrAqua);
                           if(result!=true) {error=GetLastError();}
                           if(error>0)
                             {
                               ResetLastError();
                               RefreshRates();
                               bid=MarketInfo(symbol,MODE_BID);
                               result=OrderClose(OrderTicket(),OrderLots(),bid,dev,clrAqua);
                             }
                           //--
                           if(error==0 && result==true)
                             {
                               Print("-----SmartAssTrade-V2 has CLOSED BUY ORDER ",symbol," - Automatic Take profit..OK!");
                               PlaySound("ping.wav");
                               ox=1;
                               totfr=1;
                               break;
                             }
                         } //-end BUY Order Profit.
                       //-- Trailing Stop & Step
                       ResetLastError();
                       RefreshRates();
                       bid=MarketInfo(symbol,MODE_BID);
                       if(TrlStp && (trx==0) && (bid>(OrderOpenPrice()+trstart)))
                         {
                           trest=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+trstart,OrderTakeProfit(),0);
                           trx++;
                           break;
                         }
                       //--
                       if(TrlStp && (trx>0) && (bid>(OrderStopLoss()+trstart)))
                         {
                           trx++;
                           trest=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+(trx*tsstv),OrderTakeProfit(),0);
                           break;
                         } // end BUY Order Trailing Stop.
                     //---
                     }
                   //----
                   if(OrderType()==OP_SELL)
                     {
                       //---
                       CalcTP();
                       //--
                       RefreshRates();
                       ask=MarketInfo(symbol,MODE_ASK);
                       if(((OrderOpenPrice()>(ask+tpAB)) && mdLC)) //-check if order sell is profit
                         {
                           RefreshRates();
                           ask=MarketInfo(symbol,MODE_ASK);
                           result=OrderClose(OrderTicket(),OrderLots(),ask,dev,clrYellow);
                           if(result!=true) {error=GetLastError();}
                           if(error>0)
                             {
                               ResetLastError();
                               RefreshRates();
                               ask=MarketInfo(symbol,MODE_ASK);
                               result=OrderClose(OrderTicket(),OrderLots(),ask,dev,clrYellow);
                             }
                           //--
                           if(error==0 && result==true)
                             {
                               Print("-----SmartAssTrade-V2 has CLOSED SELL ORDER ",symbol," - Automatic Take profit..OK!");
                               PlaySound("ping.wav");
                               ox=1;
                               totfr=1;
                               break;
                             }
                         } //-end SELL Order Profit.
                       //-- Trailing Stop & Step
                       ResetLastError();
                       RefreshRates();
                       ask=MarketInfo(symbol,MODE_ASK);
                       if(TrlStp && (trx==0) && (ask<(OrderOpenPrice()-trstart)))
                         {
                           trest=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-trstart,OrderTakeProfit(),0);
                           trx++;
                           break;
                         }
                       //--
                       if(TrlStp && (trx>0) && (ask<(OrderStopLoss()-trstart)))
                         {
                           trx++;
                           trest=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-(trx*tsstv),OrderTakeProfit(),0);
                           break;
                         } // end SELL Order Trailing Stop.                   
                     //----
                     }
                 }
             }
         }
       //---
       return;
//----
   } //-end ProfitNor()
//---------//

void ProfitRev() //-- function: Check if order is profit.
   {
//----
      int error;
      bool result,trest;
      totalpft=OrdersTotal()-1;
      for(ip=totalpft; ip>=0; ip--)
         {
           if(OrderSelect(ip,SELECT_BY_POS,MODE_TRADES)==True)
             {
               if(OrderSymbol()==symbol && OrderMagicNumber()==satmagic)
                 {
                   if(OrderType()==OP_BUY)
                     {
                       //---
                       CalcTP();
                       //--
                       RefreshRates();
                       bid=MarketInfo(symbol,MODE_BID);
                       if(((OrderOpenPrice()<(bid-tpAB)) && mdUp)) //-check if order is profit
                         {
                           RefreshRates();
                           bid=MarketInfo(symbol,MODE_BID);
                           result=OrderClose(OrderTicket(),OrderLots(),bid,dev,clrAqua);
                           if(result!=true) {error=GetLastError();}
                           if(error>0)
                             {
                               ResetLastError();
                               RefreshRates();
                               bid=MarketInfo(symbol,MODE_BID);
                               result=OrderClose(OrderTicket(),OrderLots(),bid,dev,clrAqua);
                             }
                           //--
                           if(error==0 && result==true)
                             {
                               Print("-----SmartAssTrade-V2 has CLOSED BUY ORDER ",symbol," - Automatic Take profit..OK!");
                               PlaySound("ping.wav");
                               ox=1;
                               totfr=1;
                               break;
                             }
                         } //-end BUY Order Profit.
                       //-- Trailing Stop & Step
                       ResetLastError();
                       RefreshRates();
                       bid=MarketInfo(symbol,MODE_BID);
                       if(TrlStp && (trx==0) && (bid>(OrderOpenPrice()+trstart)))
                         {
                           trest=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+trstart,OrderTakeProfit(),0);
                           trx++;
                           break;
                         }
                       //--
                       if(TrlStp && (trx>0) && (bid>(OrderStopLoss()+trstart)))
                         {
                           trx++;
                           trest=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+(trx*tsstv),OrderTakeProfit(),0);
                           break;
                         } // end BUY Order Trailing Stop.
                     //---
                     }
                   //----
                   if(OrderType()==OP_SELL)
                     {
                       //---
                       CalcTP();
                       //--
                       RefreshRates();
                       ask=MarketInfo(symbol,MODE_ASK);
                       if(((OrderOpenPrice()>(ask+tpAB)) && mdDn)) //-check if order is profit
                         {
                           RefreshRates();
                           ask=MarketInfo(symbol,MODE_ASK);
                           result=OrderClose(OrderTicket(),OrderLots(),ask,dev,clrYellow);
                           if(result!=true) {error=GetLastError();}
                           if(error>0)
                             {
                               ResetLastError();
                               RefreshRates();
                               ask=MarketInfo(symbol,MODE_ASK);
                               result=OrderClose(OrderTicket(),OrderLots(),ask,dev,clrYellow);
                             }
                           //--
                           if(error==0 && result==true)
                             {
                               Print("-----SmartAssTrade-V2 has CLOSED SELL ORDER ",symbol," - Automatic Take profit..OK!");
                               PlaySound("ping.wav");
                               ox=1;
                               totfr=1;
                               break;
                             }
                         } //-end SELL Order Profit.
                       //-- Trailing Stop & Step
                       ResetLastError();
                       RefreshRates();
                       ask=MarketInfo(symbol,MODE_ASK);
                       if(TrlStp && (trx==0) && (ask<(OrderOpenPrice()-trstart)))
                         {
                           trest=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-trstart,OrderTakeProfit(),0);
                           trx++;
                           break;
                         }
                       //--
                       if(TrlStp && (trx>0) && (ask<(OrderStopLoss()-trstart)))
                         {
                           trx++;
                           trest=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-(trx*tsstv),OrderTakeProfit(),0);
                           break;
                         } // end SELL Order Trailing Stop.
                     //----
                     }
                 }
             }
         }
       //---
       return;
//----
   } //-end ProfitRev()
//---------//

void StartTrading() //-- function: start trading for calculation order
   {
//----
     CkOpen();
     if ((ob>0||os>0) && opttp) {ProfitNor(); ProfitRev();}
     RefreshRates();
     Mnt=(int)Minute();
     //--
     if(Mnt==0)
       {
          ox=0;
          totfr=0;
          SmartAss();
       }
     //--
     RefreshRates();
     CkClose();
     CkOpen();
     if(ob+os==0) {SmartAss();}
     //----
     return;
//---- 
   } //-end StartTrading()
//---------//

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   EventKillTimer();
   GlobalVariablesDeleteAll();
   //--
   return;
//----
  } //-end OnDeinit()
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//----
   //--
   RefreshRates();
   MqlTick last_tick;
   time=last_tick.time;
   ask=last_tick.ask;
   bid=last_tick.bid;
   volume=last_tick.volume;
   //--
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   copied=CopyRates(symbol,30,0,100,rates);
   if(copied==0) return;
//----
   RefreshRates();
   if (IsTradeAllowed()==false) {return;}
   if (DayOfWeek()==0 || DayOfWeek()==6) {return;}
   if(FridayTrade==false && DayOfWeek()==5) {return;}
   if (DayOfWeek()==1 && Hour()==0 && Minute()<30) {NoOrder=true; StartTrading();}
   if (Hour()==0 && Minute()<30) {NoOrder=true; StartTrading();}
   else {NoOrder=false; StartTrading();}
   //--
   return;
//----
  } //-end OnTick()
//---------//
//+------------------------------------------------------------------+