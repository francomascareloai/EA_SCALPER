//+------------------------------------------------------------------+
//|                                            MFT TRADING ROBOT. |
//|                        Copyright 2020, mft robot Software . |
//|                                             https://www.mftrobot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MFT TRADING ROBOT."
#property link      "https://www.mftrobot.com"
#property version   "12.01"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\SignalEnvelopes.mqh>
#include <Expert\Signal\SignalMACD.mqh>
#include <Expert\Signal\SignalTRIX.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingParabolicSAR.mqh>
//--- available money management
#include <Expert\Money\MoneyNone.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title                 ="MFT TRADING ROBOT"; // Document name
ulong                    Expert_MagicNumber           =11752;               //
bool                     Expert_EveryTick             =false;               //
//--- inputs for main signal
input int                Signal_ThresholdOpen         =10;                  // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose        =10;                  // Signal threshold value to close [0...100]
input double             Signal_PriceLevel            =0.0;                 // Price level to execute a deal
input double             Signal_StopLevel             =50.0;                // Stop Loss level (in points)
input double             Signal_TakeLevel             =50.0;                // Take Profit level (in points)
input int                Signal_Expiration            =4;                   // Expiration of pending orders (in bars)
input int                Signal_Envelopes_PeriodMA    =45;                  // Envelopes(45,0,MODE_SMA,...) Period of averaging
input int                Signal_Envelopes_Shift       =0;                   // Envelopes(45,0,MODE_SMA,...) Time shift
input ENUM_MA_METHOD     Signal_Envelopes_Method      =MODE_SMA;            // Envelopes(45,0,MODE_SMA,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_Envelopes_Applied     =PRICE_CLOSE;         // Envelopes(45,0,MODE_SMA,...) Prices series
input double             Signal_Envelopes_Deviation   =0.15;                // Envelopes(45,0,MODE_SMA,...) Deviation
input double             Signal_Envelopes_Weight      =0.8;                 // Envelopes(45,0,MODE_SMA,...) Weight [0...1.0]
input int                Signal_MACD_PeriodFast       =12;                  // MACD(12,24,9,PRICE_CLOSE) Period of fast EMA
input int                Signal_MACD_PeriodSlow       =24;                  // MACD(12,24,9,PRICE_CLOSE) Period of slow EMA
input int                Signal_MACD_PeriodSignal     =9;                   // MACD(12,24,9,PRICE_CLOSE) Period of averaging of difference
input ENUM_APPLIED_PRICE Signal_MACD_Applied          =PRICE_CLOSE;         // MACD(12,24,9,PRICE_CLOSE) Prices series
input double             Signal_MACD_Weight           =0.5;                 // MACD(12,24,9,PRICE_CLOSE) Weight [0...1.0]
input int                Signal_TriX_PeriodTriX       =14;                  // Triple Exponential Average Period of calculation
input ENUM_APPLIED_PRICE Signal_TriX_Applied          =PRICE_CLOSE;         // Triple Exponential Average Prices series
input double             Signal_TriX_Weight           =0.3;                 // Triple Exponential Average Weight [0...1.0]
//--- inputs for trailing
input double             Trailing_ParabolicSAR_Step   =0.02;                // Speed increment
input double             Trailing_ParabolicSAR_Maximum=0.2;                 // Maximum rate
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Creating signal
   CExpertSignal *signal=new CExpertSignal;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
//--- Creating filter CSignalEnvelopes
   CSignalEnvelopes *filter0=new CSignalEnvelopes;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodMA(Signal_Envelopes_PeriodMA);
   filter0.Shift(Signal_Envelopes_Shift);
   filter0.Method(Signal_Envelopes_Method);
   filter0.Applied(Signal_Envelopes_Applied);
   filter0.Deviation(Signal_Envelopes_Deviation);
   filter0.Weight(Signal_Envelopes_Weight);
//--- Creating filter CSignalMACD
   CSignalMACD *filter1=new CSignalMACD;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.PeriodFast(Signal_MACD_PeriodFast);
   filter1.PeriodSlow(Signal_MACD_PeriodSlow);
   filter1.PeriodSignal(Signal_MACD_PeriodSignal);
   filter1.Applied(Signal_MACD_Applied);
   filter1.Weight(Signal_MACD_Weight);
//--- Creating filter CSignalTriX
   CSignalTriX *filter2=new CSignalTriX;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.PeriodTriX(Signal_TriX_PeriodTriX);
   filter2.Applied(Signal_TriX_Applied);
   filter2.Weight(Signal_TriX_Weight);
//--- Creation of trailing object
   CTrailingPSAR *trailing=new CTrailingPSAR;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set trailing parameters
   trailing.Step(Trailing_ParabolicSAR_Step);
   trailing.Maximum(Trailing_ParabolicSAR_Maximum);
//--- Creation of money object
   CMoneyNone *money=new CMoneyNone;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set money parameters
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
