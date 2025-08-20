#property copyright "Copyright 2020, Elise-3011"
#property link      "https://t.me/free_fx_pro"
#property version   "5.2"
#property description   "= Minimum Deposit 1000$ ="
#property description   "----------Contact me-----------"
#property description   "Join our Telegram Group : https://t.me/free_fx_pro"
#property description   "Telegram: https://t.me/free_fx_pro"
#property description   "https://t.me/free_fx_pro"
#property strict
#include <stdlib.mqh>
#include <WinUser32.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>

#define BullColor Lime
#define BearColor Red

enum dbu {Constant=0,OneMinute=1,FiveMinutes=5};

sinput   string   t_trade    = "************ ELISE EA LICENSE ************"; // ============ Expert Name ============
sinput bool                      UseDefaultPairs            = true;              // Use the default 28 pairs
sinput string                    OwnPairs                   = "";                // Comma seperated own pair list (EURUSD,GBPUSD,....)
 dbu                       DashUpdate                 = 1;                 
sinput int                       Magic_Number               = 785279;
sinput bool                      autotrade                  = false;             // Autotrade

   string   t_trigger = "TRIGGER MANAGEMENT"; // =================================
   bool                    trigger_use_Pips           = false;              // Use Pips
   double                  trade_MIN_pips             = 20;                // Minimum pips to open position
   bool                    trigger_UseHeatMap1        = false;             // Use Heat Map
   ENUM_TIMEFRAMES         trigger_TF_HM1             = 1440;              // TimeFrame for Heat Map 
   double                  trade_MIN_HeatMap1         = 0.5;               // Minimum % HeatMap to open position
   bool                    trigger_use_bidratio       = true;              // Use BidRatio filtering
   double                  trigger_buy_bidratio       = 80;                // % Level to open Buy
   double                  trigger_sell_bidratio      = 7;                // % Level to open Sell
   bool                    trigger_use_relstrength    = true;              // Use Relative Strength filtering (Base)
   double                  trigger_buy_relstrength    = 4.0;               // Strenth to open Buy
   double                  trigger_sell_relstrength   =-4.0;               // Strength to open Sell
   bool                    trigger_use_buysellratio   = true;              // Use Buy/Sell Ratio filtering
   double                  trigger_buy_buysellratio   = 4.0;               // Level to open Buy
   double                  trigger_sell_buysellratio  = -4.0;              // level to open Sell
   bool                    trigger_use_gap            = false;              // Use Gap filtering
   double                  trigger_gap_buy            = 2.25;               // Gap level to open Buy
   double                  trigger_gap_sell           = -2.25;              // Gap level to open Sell

sinput   string   t_basket = "MONEY MANAGEMENT"; // =================================
sinput double                    lot                        = 0.01;
sinput int                       MaxTrades                  = 1;                  // Max trades per pair
sinput int                       MaxTotalTrades             = 0;                  // Max total trades overall
sinput double                    MaxSpread                  = 50.0;                // Max Spread Allowe
 int                       Basket_Target              = 0;                  // Basket Take Profit in $
 int                       Basket_StopLoss            = 0;                  // Basket Stop Lloss in $
sinput int                       Piptp                      = 0;                  // Takeprofit in pips 
sinput int                       Pipsl                      = 0;                  // Stoploss in pips 
sinput double                    BasketP1                   = 100.0;                // Profit
sinput double                    BasketL1                   = 80.0;                // Lock
 double                    BasketP2                   = 0.0;                // At profit 2
 double                    BasketL2                   = 0.0;                // Lock 2
 double                    BasketP3                   = 0.0;                // At profit 3
 double                    BasketL3                   = 0.0;                // Lock 3
 double                    BasketP4                   = 0.0;                // At profit 4
 double                    BasketL4                   = 0.0;                // Lock 4
 double                    BasketP5                   = 0.0;                // At profit 5
 double                    BasketL5                   = 0.0;                // Lock 5
 double                    BasketP6                   = 0.0;                // At profit 6
 double                    BasketL6                   = 0.0;                // Lock 6
 bool                      TrailLastLock              = true;               // Trail the last set lock
 double                    TrailDistance              = 0.0;                // Trail distance 0 means last lock
 int                       StopProfit                 = 0;                  // Stop after this many profitable baskets
 double                    Adr1tp                     = 0;                 // Takeprofit percent adr(10) 0=None
 double                    Adr1sl                     = 0;                 // Stoploss adr percent adr(10) 0 = None
 int                       StopLoss                   = 0;                  // Stop after this many losing baskets baskets
 bool                      OnlyAddProfit              = true;               // Only adds trades in profit 
 bool                      CloseAllSession            = false;              // Close all trades after session(s)

sinput   string   t_time = "TIME MANAGEMENT"; // =================================
sinput bool                      UseSession1                = true;  // Trading Time Session 1
sinput string                    sess1start                 = "00:00";  // Start
sinput string                    sess1end                   = "23:59";  // Stop
 string                    sess1comment               = "[https://t.me/EliseRenard]";
sinput bool                      UseSession2                = false; // Trading Time Session 2
sinput string                    sess2start                 = "00:00";  // Start
sinput string                    sess2end                   = "23:59";  // Stop
 string                    sess2comment               = "[https://t.me/EliseRenard]";
sinput bool                      UseSession3                = false; // Trading Time Session 3
sinput string                    sess3start                 = "00:00";  // Start
sinput string                    sess3end                   = "23:59";  // Stop
 string                    sess3comment               = "[https://t.me/EliseRenard]";

   string   t_chart = "CHART MANAGEMENT"; // =================================
 ENUM_TIMEFRAMES           TimeFrame                  = 1440;                //TimeFrame to open chart
 string                    usertemplate               = "default";
 int                       x_axis                     =0;
 int                       y_axis                     =70;

int BeforeMin = 15;
int FontSize = 10;
string FontName = "Arial";
int ShiftX = 250;
int ShiftY = 70;
int Corner = 0;

string button_close_basket_All = "btn_Close ALL"; 
string button_close_basket_Prof = "btn_Close Prof";
string button_close_basket_Loss = "btn_Close Loss";

string button_reset_ea = "RESET EA";
 
string button_EUR_basket = "EUR_BASKET"; 
string button_EUR_basket_buy = "EUR_BASKET_BUY";
string button_EUR_basket_sell = "EUR_BASKET_SELL";
string button_EUR_basket_close = "EUR_BASKET_CLOSE";

string button_GBP_basket = "GBP_BASKET"; 
string button_GBP_basket_buy = "GBP_BASKET_BUY";
string button_GBP_basket_sell = "GBP_BASKET_SELL";
string button_GBP_basket_close = "GBP_BASKET_CLOSE";

string button_CHF_basket = "CHF_BASKET"; 
string button_CHF_basket_buy = "CHF_BASKET_BUY";
string button_CHF_basket_sell = "CHF_BASKET_SELL";
string button_CHF_basket_close = "CHF_BASKET_CLOSE";

string button_USD_basket = "USD_BASKET"; 
string button_USD_basket_buy = "USD_BASKET_BUY";
string button_USD_basket_sell = "USD_BASKET_SELL";
string button_USD_basket_close = "USD_BASKET_CLOSE";

string button_CAD_basket = "CAD_BASKET"; 
string button_CAD_basket_buy = "CAD_BASKET_BUY";
string button_CAD_basket_sell = "CAD_BASKET_SELL";
string button_CAD_basket_close = "CAD_BASKET_CLOSE";

string button_NZD_basket = "NZD_BASKET"; 
string button_NZD_basket_buy = "NZD_BASKET_BUY";
string button_NZD_basket_sell = "NZD_BASKET_SELL";
string button_NZD_basket_close = "NZD_BASKET_CLOSE";

string button_AUD_basket = "AUD_BASKET"; 
string button_AUD_basket_buy = "AUD_BASKET_BUY";
string button_AUD_basket_sell = "AUD_BASKET_SELL";
string button_AUD_basket_close = "AUD_BASKET_CLOSE";

string button_JPY_basket = "JPY_BASKET"; 
string button_JPY_basket_buy = "JPY_BASKET_BUY";
string button_JPY_basket_sell = "JPY_BASKET_SELL";
string button_JPY_basket_close = "JPY_BASKET_CLOSE";
 
string DefaultPairs[] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY"};
string TradePairs[];
string curr[8] = {"USD","EUR","GBP","JPY","AUD","NZD","CAD","CHF"};
string EUR[7] = {"EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD"};
string GBP[6] = {"GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD"};
string GBP_R[1] = {"EURGBP"};
string CHF[1] = {"CHFJPY"};
string CHF_R[6] = {"AUDCHF","CADCHF","EURCHF","GBPCHF","NZDCHF","USDCHF"};
string USD[3] = {"USDCAD","USDCHF","USDJPY"};
string USD_R[4] = {"AUDUSD","EURUSD","GBPUSD","NZDUSD"};
string CAD[2] = {"CADCHF","CADJPY"};
string CAD_R[5] = {"AUDCAD","EURCAD","GBPCAD","NZDCAD","USDCAD"};
string NZD[4] = {"NZDCAD","NZDCHF","NZDJPY","NZDUSD"};
string NZD_R[3] = {"AUDNZD","EURNZD","GBPNZD"};
string AUD[5] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD"};
string AUD_R[2] = {"EURAUD","GBPAUD"};
string JPY_R[7] = {"AUDJPY","CADJPY","CHFJPY","EURJPY","GBPJPY","NZDJPY","USDJPY"};

string   _font="Consolas";

struct pairinf {
   double PairPip;
   int pipsfactor;
   double Pips;
   double PipsSig;
   double Pipsprev;
   double Spread;
   double point;
   int lastSignal;
   int    base;
   int    quote;   
}; pairinf pairinfo[];

#define NONE 0
#define DOWN -1
#define UP 1

#define NOTHING 0
#define BUY 1
#define SELL 2

struct signal { 
   string symbol;
   double range;
   double range1;
   double ratio;
   double ratio1;
   double bidratio;
   double fact;
   double strength;
   double strength_old;
   double strength1;
   double strength2;
   double calc;
   double strength3;
   double strength4;
   double strength5;
   double strength6;
   double strength7;
   double strength8;
   double strength_Gap;
   double hi;
   double lo;
   double prevratio;   
   double prevbid;   
   int    shift;
   double open;
   double close;
   double bid;
   double point;   
   double Signalperc;   
   double SigRatio;
   double SigRelStr;
   double SigBSRatio;    
   double SigCRS;
   double SigGap;
   double SigGapPrev;
   double SigRatioPrev;
}; signal signals[];

struct currency 
  {
   string            curr;
   double            strength;
   double            prevstrength;
   double            crs;
   int               sync;
   datetime          lastbar;
  }
; currency currencies[8];

double totalbuystrength,totalsellstrength;

color ProfitColor,ProfitColor1,ProfitColor2,ProfitColor3,PipsColor,LotColor,LotColor1,OrdColor,OrdColor1;
color BackGrnCol =C'20,20,20';
color LineColor=clrBlack;
color TextColor=clrBlack;

struct adrval {
   double adr;
   double adr1;
   double adr5;
   double adr10;
   double adr20;
}; adrval adrvalues[];

double totalprofit,totallots;

datetime s1start,s2start,s3start;
datetime s1end,s2end,s3end;

string comment;
int strper = PERIOD_W1;
int profitbaskets = 0;
int lossbaskets = 0;
int ticket;
int    orders  = 0;
double blots[28],slots[28],bprofit[28],sprofit[28],tprofit[28],bpos[28],spos[28];
bool CloseAll;
string postfix=StringSubstr(Symbol(),6,10);
int   symb_cnt=0;
int period1[]= {240,1440,10080};
double factor;
int labelcolor; 
double GetBalanceSymbol,SymbolMaxDD,SymbolMaxHi;
double PercentFloatingSymbol=0;
double PercentMaxDDSymbol=0;
datetime newday=0;
datetime newm1=0; 
bool   Accending=true;
int localday = 99;
bool s1active = false;
bool s2active = false;
bool s3active = false;
MqlDateTime sess;
string strspl[];
double currentlock = 0.0;
bool trailstarted = false;
double lockdistance = 0.0;
int totaltrades = 0;
int maxtotaltrades=0;
double stoploss;
double takeprofit;
double currstrength[8];
double prevstrength[8];
//+------------------------------------------------------------------+s
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   string batas="2024.12.30"; //Year, Month, Date, Expiration
   int tt=StrToTime(batas);   
   if(TimeCurrent()>tt)
   {
      Alert(" Licence Ended Please Contact https://t.me/free_fx_pro");
      ExpertRemove();
      return(0);
   }  
   string NEA = "Elise-EA-ZUP"; 
      if (NEA != WindowExpertName()) 
      {
         Alert(" \nEXPERT NAME WAS RENAMED/CHANGED! \nTRADE IS STOPED/NOT ALLOWED!");
         Comment(" \nEXPERT NAME WAS RENAMED/CHANGED! \nTRADE IS STOPED/NOT ALLOWED!");
         Print("Trade STOPED! RENAMED NAME EA, WITHOUT PERMIT! update your license to owner...");
         ExpertRemove();
         return (0);
      }
   /*if(!IsDemo()) 
   {
      MessageBox("Only DEMO Acc, For full version contact at Telegram https://t.me/free_fx_pro");
      Comment("Only DEMO Acc, For full version contact at Telegram https://t.me/free_fx_pro");
      Print("Only DEMO Acc, For full version contact at Telegram https://t.me/free_fx_pro");
      ExpertRemove();
      return (0);
   }*/
   comments();
                 
    if (UseDefaultPairs == true)
      ArrayCopy(TradePairs,DefaultPairs);
    else
      StringSplit(OwnPairs,',',TradePairs);
   
  for (int i=0;i<8;i++)
      currencies[i].curr = curr[i]; 
   
   if (ArraySize(TradePairs) <= 0) {
      Print("No pairs to trade");
      return(INIT_FAILED);
   }
   
   ArrayResize(adrvalues,ArraySize(TradePairs));
   ArrayResize(signals,ArraySize(TradePairs));
   ArrayResize(pairinfo,ArraySize(TradePairs));
          
   
   int basket_x = x_axis + 3;
   int basket_y = y_axis + 150;
   Create_Button(button_close_basket_All,"Close All",70 ,18,250 ,20,C'231,247,14',clrBlack);
   Create_Button(button_close_basket_Prof,"Close Profit",70 ,18,330 ,20,C'1,173,18',clrBlack);
   Create_Button(button_close_basket_Loss,"Close Loss",70 ,18,410 ,20,C'234,0,35',clrWhite);
   
  

   newday = 0;
   newm1=0;

/*  HP  */
   localday = 99;
   s1active = false;
   s2active = false;
   s3active = false;
   trailstarted = false;

   if (MaxTotalTrades == 0)
      maxtotaltrades = ArraySize(TradePairs) * MaxTrades;
   else
      maxtotaltrades = MaxTotalTrades;
      
   EventSetTimer(1);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll();
      
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {

   Trades();

   TradeManager();

   PlotTrades();

   PlotSpreadPips();

   GetSignals();  
            
   displayMeter();
   
   if (newday != iTime("EURUSD"+postfix,PERIOD_D1,0)) {
      GetAdrValues();
      PlotAdrValues();
      newday = iTime("EURUSD"+postfix,PERIOD_D1,0);
   }
          
   if (DashUpdate == 0 || (DashUpdate == 1 && newm1 != iTime("EURUSD"+postfix,PERIOD_M1,0)) || (DashUpdate == 5 && newm1 != iTime("EURUSD"+postfix,PERIOD_M5,0))) {

      
   for(int i=0;i<ArraySize(TradePairs);i++) 
   for(int a=0;a<5;a++){
     
      ChngBoxCol((signals[i].Signalperc * 100), i);      
      if (((pairinfo[i].PipsSig==UP && pairinfo[i].Pips > trade_MIN_pips) || trigger_use_Pips==false)
      && ((signals[i].SigRatioPrev==UP && signals[i].ratio>=trigger_buy_bidratio) || trigger_use_bidratio==false)
      &&  (signals[i].calc>=trigger_buy_relstrength || trigger_use_relstrength==false)
      &&  (signals[i].strength5>=trigger_buy_buysellratio || trigger_use_buysellratio==false)
      && ((signals[i].SigGapPrev==UP && signals[i].strength_Gap>=trigger_gap_buy) || trigger_use_gap==false) 
      &&(signals[i].Signalperc >trade_MIN_HeatMap1 || trigger_UseHeatMap1==false))      
       {
         labelcolor = clrGreen;
         if ((bpos[i]+spos[i]) < MaxTrades && pairinfo[i].lastSignal != BUY && autotrade == true && (OnlyAddProfit == false || bprofit[i] >= 0.0) && pairinfo[i].Spread <= MaxSpread && inSession() == true && totaltrades <= maxtotaltrades) {
            pairinfo[i].lastSignal = BUY;
            
            while (IsTradeContextBusy()) Sleep(100);
            ticket=OrderSend(TradePairs[i],OP_BUY,lot,MarketInfo(TradePairs[i],MODE_ASK),100,0,0,StringConcatenate("@EliseTrendEA-", TradePairs[i], "-", Period()),Magic_Number,0,Blue);
            if (OrderSelect(ticket,SELECT_BY_TICKET) == true) {
                if (Pipsl != 0.0)
                           stoploss=OrderOpenPrice() - Pipsl * pairinfo[i].PairPip;
                        else
                           if (Adr1sl != 0.0)
                              stoploss=OrderOpenPrice() - ((adrvalues[i].adr10/100)*Adr1sl) * pairinfo[i].PairPip;
                           else
                              stoploss = 0.0;

                        if (Piptp != 0.0)
                              takeprofit=OrderOpenPrice() + Piptp * pairinfo[i].PairPip;
                        else
                           if (Adr1tp != 0.0)
                              takeprofit=OrderOpenPrice() + ((adrvalues[i].adr10/100)*Adr1tp) * pairinfo[i].PairPip;
                           else
                              takeprofit = 0.0;
               
               while (IsTradeContextBusy()) Sleep(100);
               OrderModify(ticket,OrderOpenPrice(),NormalizeDouble(stoploss,MarketInfo(TradePairs[i],MODE_DIGITS)),NormalizeDouble(takeprofit,MarketInfo(TradePairs[i],MODE_DIGITS)),0,clrBlue);
            }
         }
      } else {
         if (((pairinfo[i].PipsSig==DOWN && pairinfo[i].Pips < -trade_MIN_pips) || trigger_use_Pips==false) 
         && ((signals[i].SigRatioPrev==DOWN && signals[i].ratio<=trigger_sell_bidratio) || trigger_use_bidratio==false)
         &&  (signals[i].calc<=trigger_sell_relstrength || trigger_use_relstrength==false)
         &&  (signals[i].strength5<=trigger_sell_buysellratio || trigger_use_buysellratio==false)
         && ((signals[i].SigGapPrev==DOWN && signals[i].strength_Gap<=trigger_gap_sell) || trigger_use_gap==false)         
         &&(signals[i].Signalperc <-trade_MIN_HeatMap1 || trigger_UseHeatMap1==false))        
         {
            labelcolor = clrTomato;           
            if ((bpos[i]+spos[i]) < MaxTrades && pairinfo[i].lastSignal != SELL && autotrade == true && (OnlyAddProfit == false || sprofit[i] >= 0.0) && pairinfo[i].Spread <= MaxSpread && inSession() == true && totaltrades <= maxtotaltrades) {
               pairinfo[i].lastSignal = SELL;
               
               while (IsTradeContextBusy()) Sleep(100);
               ticket=OrderSend(TradePairs[i],OP_SELL,lot,MarketInfo(TradePairs[i],MODE_BID),100,0,0,StringConcatenate("@EliseTrendEA-", TradePairs[i], "-", Period()),Magic_Number,0,Red);
               if (OrderSelect(ticket,SELECT_BY_TICKET) == true) {
                  if (Pipsl != 0.0)
                              stoploss=OrderOpenPrice() + Pipsl * pairinfo[i].PairPip;
                           else
                              if (Adr1sl != 0.0)
                                 stoploss=OrderOpenPrice()+((adrvalues[i].adr10/100)*Adr1sl)  *pairinfo[i].PairPip;
                              else
                                 stoploss = 0.0;
                                 
                                 
                           if (Piptp != 0.0)
                              takeprofit=OrderOpenPrice() - Piptp * pairinfo[i].PairPip;
                           else 
                              if (Adr1tp != 0.0)
                                 takeprofit=OrderOpenPrice() - ((adrvalues[i].adr10/100)*Adr1tp) * pairinfo[i].PairPip;
                              else
                                 takeprofit = 0.0;
                                 
                  while (IsTradeContextBusy()) Sleep(100);
                  OrderModify(ticket,OrderOpenPrice(),NormalizeDouble(stoploss,MarketInfo(TradePairs[i],MODE_DIGITS)),NormalizeDouble(takeprofit,MarketInfo(TradePairs[i],MODE_DIGITS)),0,clrBlue);
               }
            }
         } else {
            labelcolor = BackGrnCol;
            pairinfo[i].lastSignal = NOTHING;
         }  
      }
      /*string HM0 = iCustom(NULL, 0, "Zup_Universal",5, 10, "Arial", 585 , 250, 0 , 0,i);
      string HM1 = iCustom(NULL, 0, "Zup_Universal",15, 10, "Arial", 620 , 250, 0 , 0,i);
      string HM2 = iCustom(NULL, 0, "Zup_Universal",60, 10, "Arial", 655 , 250, 0 , 0,i);
      string HM3 = iCustom(NULL, 0, "Zup_Universal",240, 10, "Arial", 690 , 250, 0 , 0,i);
      string HM4 = iCustom(NULL, 0, "Zup_Universal",1440, 10, "Arial", 725 , 250, 0 , 0,i);
      */
              
         ColorPanel("Spread"+IntegerToString(i),labelcolor,C'61,61,61');        
         ColorPanel("Pips"+IntegerToString(i),labelcolor,C'61,61,61');
         ColorPanel("Adr"+IntegerToString(i),labelcolor,C'61,61,61');         
         ColorPanel("TP",Black,White);
         ColorPanel("TP1",Black,White);
         ColorPanel("TP2",Black,White);
         ColorPanel("TP3",Black,White);
         ColorPanel("TP4",Black,White);
         ColorPanel("TP5",Black,White);         
      }
      if (DashUpdate == 1)
         newm1 = iTime("EURUSD"+postfix,PERIOD_M1,0);
      else if (DashUpdate == 5)
         newm1 = iTime("EURUSD"+postfix,PERIOD_M5,0);
   }
   WindowRedraw();    
}
  
//+------------------------------------------------------------------+

void SetText(string name,string text,int x,int y,color colour,int fontsize=12)
  {
   if (ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);

    ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
    ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
    ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
    ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
    ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
    ObjectSetString(0,name,OBJPROP_TEXT,text);
  }
//+------------------------------------------------------------------+

void SetObjText(string name,string CharToStr,int x,int y,color colour,int fontsize=12)
  {
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);

   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,name,OBJPROP_TEXT,CharToStr);
   ObjectSetString(0,name,OBJPROP_FONT,"Wingdings");
  }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetPanel(string name,int sub_window,int x,int y,int width,int height,color bg_color,color border_clr,int border_width)
  {
   if(ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(0,name,OBJPROP_COLOR,border_clr);
      ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,name,OBJPROP_WIDTH,border_width);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,0);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
     }
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg_color);
  }
void ColorPanel(string name,color bg_color,color border_clr)
  {
   ObjectSetInteger(0,name,OBJPROP_COLOR,border_clr);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg_color);
  }
//+------------------------------------------------------------------+
void Create_Button(string but_name,string label,int xsize,int ysize,int xdist,int ydist,int bcolor,int fcolor)
{
    
   if(ObjectFind(0,but_name)<0)
   {
      if(!ObjectCreate(0,but_name,OBJ_BUTTON,0,0,0))
        {
         Print(__FUNCTION__,
               ": failed to create the button! Error code = ",GetLastError());
         return;
        }
      ObjectSetString(0,but_name,OBJPROP_TEXT,label);
      ObjectSetInteger(0,but_name,OBJPROP_XSIZE,xsize);
      ObjectSetInteger(0,but_name,OBJPROP_YSIZE,ysize);
      ObjectSetInteger(0,but_name,OBJPROP_CORNER,CORNER_LEFT_UPPER);     
      ObjectSetInteger(0,but_name,OBJPROP_XDISTANCE,xdist);      
      ObjectSetInteger(0,but_name,OBJPROP_YDISTANCE,ydist);         
      ObjectSetInteger(0,but_name,OBJPROP_BGCOLOR,bcolor);
      ObjectSetInteger(0,but_name,OBJPROP_COLOR,fcolor);
      ObjectSetInteger(0,but_name,OBJPROP_FONTSIZE,8);
      ObjectSetInteger(0,but_name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,but_name,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      
      ChartRedraw();      
   }

}
void OnChartEvent(const int id,  const long &lparam, const double &dparam,  const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
  
      {
       if (sparam==button_AUD_basket_buy)
        {          
               buy_basket(AUD);
               sell_basket(AUD_R);
               ObjectSetInteger(0,button_AUD_basket_buy,OBJPROP_STATE,0);
               return;
        }
//-----------------------------------------------------------------------------------------------------------------  
      if (sparam==button_AUD_basket_sell)
        {          
               sell_basket(AUD);
               buy_basket(AUD_R);
               ObjectSetInteger(0,button_AUD_basket_sell,OBJPROP_STATE,0);
               return;
        }
//-----------------------------------------------------------------------------------------------------------------  
      if (sparam==button_CAD_basket_buy)
        {          
               buy_basket(CAD);
               sell_basket(CAD_R);
               ObjectSetInteger(0,button_CAD_basket_buy,OBJPROP_STATE,0);
               return;
        }
//-----------------------------------------------------------------------------------------------------------------  
      if (sparam==button_CAD_basket_sell)
        {          
               sell_basket(CAD);
               buy_basket(CAD_R);
               ObjectSetInteger(0,button_CAD_basket_sell,OBJPROP_STATE,0);
               return;
        }
//-----------------------------------------------------------------------------------------------------------------
      if (sparam==button_CHF_basket_buy)
        {          
               buy_basket(CHF);
               sell_basket(CHF_R);
               ObjectSetInteger(0,button_CHF_basket_buy,OBJPROP_STATE,0);
               return;
        }
//-----------------------------------------------------------------------------------------------------------------  
      if (sparam==button_CHF_basket_sell)
        {          
               sell_basket(CHF);
               buy_basket(CHF_R);
               ObjectSetInteger(0,button_CHF_basket_sell,OBJPROP_STATE,0);
               return;
        }
//-----------------------------------------------------------------------------------------------------------------
      if (sparam==button_EUR_basket_buy)
        {          
               buy_basket(EUR);
               ObjectSetInteger(0,button_EUR_basket_buy,OBJPROP_STATE,0);
               return;
        }
//-----------------------------------------------------------------------------------------------------------------  
      if (sparam==button_EUR_basket_sell)
        {          
               sell_basket(EUR);
               ObjectSetInteger(0,button_EUR_basket_sell,OBJPROP_STATE,0);
               return;
        }
//-----------------------------------------------------------------------------------------------------------------
      if (sparam==button_GBP_basket_buy)
        {          
               buy_basket(GBP);
               sell_basket(GBP_R);
               ObjectSetInteger(0,button_GBP_basket_buy,OBJPROP_STATE,0);
               return;
        }
//-----------------------------------------------------------------------------------------------------------------  
      if (sparam==button_GBP_basket_sell)
        {          
               sell_basket(GBP);
               buy_basket(GBP_R);
               ObjectSetInteger(0,button_GBP_basket_sell,OBJPROP_STATE,0);
               return;
        }
//-----------------------------------------------------------------------------------------------------------------
      if (sparam==button_JPY_basket_buy)
        {          
               sell_basket(JPY_R);
               ObjectSetInteger(0,button_JPY_basket_buy,OBJPROP_STATE,0);
               return;
        }
//-----------------------------------------------------------------------------------------------------------------  
      if (sparam==button_JPY_basket_sell)
        {          
               buy_basket(JPY_R);
               ObjectSetInteger(0,button_JPY_basket_sell,OBJPROP_STATE,0);
               return;
        }
//-----------------------------------------------------------------------------------------------------------------
      if (sparam==button_NZD_basket_buy)
        {          
               buy_basket(NZD);
               sell_basket(NZD_R);
               ObjectSetInteger(0,button_NZD_basket_buy,OBJPROP_STATE,0);
               return;
        }
//-----------------------------------------------------------------------------------------------------------------  
      if (sparam==button_NZD_basket_sell)
        {          
               sell_basket(NZD);
               buy_basket(NZD_R);
               ObjectSetInteger(0,button_NZD_basket_sell,OBJPROP_STATE,0);
               return;
        }
//-----------------------------------------------------------------------------------------------------------------
      if (sparam==button_USD_basket_buy)
        {          
               buy_basket(USD);
               sell_basket(USD_R);
               ObjectSetInteger(0,button_USD_basket_buy,OBJPROP_STATE,0);
               return;
        }
//-----------------------------------------------------------------------------------------------------------------  
      if (sparam==button_USD_basket_sell)
        {          
               sell_basket(USD);
               buy_basket(USD_R);
               ObjectSetInteger(0,button_USD_basket_sell,OBJPROP_STATE,0);
               return;
        }
//-----------------------------------------------------------------------------------------------------------------
      if (sparam==button_AUD_basket_close)
        {          
               close_cur_basket(AUD);
               close_cur_basket(AUD_R);
               ObjectSetInteger(0,button_AUD_basket_close,OBJPROP_STATE,0);
               return;
        }
//----------------------------------------------------------------------------------------------------------------- 
      if (sparam==button_CAD_basket_close)
        {          
               close_cur_basket(CAD);
               close_cur_basket(CAD_R);
               ObjectSetInteger(0,button_CAD_basket_close,OBJPROP_STATE,0);
               return;
        }
//----------------------------------------------------------------------------------------------------------------- 
      if (sparam==button_CHF_basket_close)
        {          
               close_cur_basket(CHF);
               close_cur_basket(CHF_R);
               ObjectSetInteger(0,button_CHF_basket_close,OBJPROP_STATE,0);
               return;
        }
//----------------------------------------------------------------------------------------------------------------- 
      if (sparam==button_EUR_basket_close)
        {          
               close_cur_basket(EUR);
               ObjectSetInteger(0,button_EUR_basket_close,OBJPROP_STATE,0);
               return;
        }
//----------------------------------------------------------------------------------------------------------------- 
      if (sparam==button_GBP_basket_close)
        {          
               close_cur_basket(GBP);
               close_cur_basket(GBP_R);
               ObjectSetInteger(0,button_GBP_basket_close,OBJPROP_STATE,0);
               return;
        }
//----------------------------------------------------------------------------------------------------------------- 
      if (sparam==button_JPY_basket_close)
        {          
               close_cur_basket(JPY_R);
               ObjectSetInteger(0,button_JPY_basket_close,OBJPROP_STATE,0);
               return;
        }
//----------------------------------------------------------------------------------------------------------------- 
      if (sparam==button_NZD_basket_close)
        {          
               close_cur_basket(NZD);
               close_cur_basket(NZD_R);
               ObjectSetInteger(0,button_NZD_basket_close,OBJPROP_STATE,0);
               return;
        }
//----------------------------------------------------------------------------------------------------------------- 
      if (sparam==button_USD_basket_close)
        {          
               close_cur_basket(USD);
               close_cur_basket(USD_R);
               ObjectSetInteger(0,button_USD_basket_close,OBJPROP_STATE,0);
               return;
        }
//----------------------------------------------------------------------------------------------------------------- 
      if (sparam==button_reset_ea)
        {          
               Reset_EA();
               ObjectSetInteger(0,button_reset_ea,OBJPROP_STATE,0);
               return;
        }

//-----------------------------------------------------------------------------------------------------------------
      if (sparam==button_close_basket_All)
        {
               ObjectSetString(0,button_close_basket_All,OBJPROP_TEXT,"Closing...");               
               close_basket(Magic_Number);
               ObjectSetInteger(0,button_close_basket_All,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_All,OBJPROP_TEXT,"Close All"); 
               return;
        }
//-----------------------------------------------------------------------------------------------------------------     
      if (sparam==button_close_basket_Prof)
        {
               ObjectSetString(0,button_close_basket_Prof,OBJPROP_TEXT,"Closing...");               
               close_profit();
               ObjectSetInteger(0,button_close_basket_Prof,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_Prof,OBJPROP_TEXT,"Close Profit"); 
               return;
        }
//----------------------------------------------------------------------------------------------------------------- 
      if (sparam==button_close_basket_Loss)
        {
               ObjectSetString(0,button_close_basket_Loss,OBJPROP_TEXT,"Closing...");               
               close_loss();
               ObjectSetInteger(0,button_close_basket_Loss,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_Loss,OBJPROP_TEXT,"Close Loss"); 
               return;
        }
//-----------------------------------------------------------------------------------------------------------------
     if (StringFind(sparam,"BUY") >= 0)
        {
               int ind = StringToInteger(sparam);
               ticket=OrderSend(TradePairs[ind],OP_BUY,lot,MarketInfo(TradePairs[ind],MODE_ASK),100,0,0,"Elise Trend ZUP",Magic_Number,0,Blue);
               if (OrderSelect(ticket,SELECT_BY_TICKET) == true) {
                  if (Pipsl != 0.0)
                           stoploss=OrderOpenPrice() - Pipsl * pairinfo[ind].PairPip;
                        else
                           if (Adr1sl != 0.0)
                              stoploss=OrderOpenPrice() - ((adrvalues[ind].adr10/100)*Adr1sl) * pairinfo[ind].PairPip;
                           else
                              stoploss = 0.0;

                        if (Piptp != 0.0)
                              takeprofit=OrderOpenPrice() + Piptp * pairinfo[ind].PairPip;
                        else
                           if (Adr1tp != 0.0)
                              takeprofit=OrderOpenPrice() + ((adrvalues[ind].adr10/100)*Adr1tp) * pairinfo[ind].PairPip;
                           else
                              takeprofit = 0.0;
                  OrderModify(ticket,OrderOpenPrice(),NormalizeDouble(stoploss,MarketInfo(TradePairs[ind],MODE_DIGITS)),NormalizeDouble(takeprofit,MarketInfo(TradePairs[ind],MODE_DIGITS)),0,clrBlue);
               }
               ObjectSetInteger(0,ind+"BUY",OBJPROP_STATE,0);
               ObjectSetString(0,ind+"BUY",OBJPROP_TEXT,"BUY"); 
               return;
        }
     if (StringFind(sparam,"SELL") >= 0)
        {
               int ind = StringToInteger(sparam);
               ticket=OrderSend(TradePairs[ind],OP_SELL,lot,MarketInfo(TradePairs[ind],MODE_BID),100,0,0,"Elise Trend ZUP",Magic_Number,0,Red);
               if (OrderSelect(ticket,SELECT_BY_TICKET) == true) {
                   if (Pipsl != 0.0)
                              stoploss=OrderOpenPrice() + Pipsl * pairinfo[ind].PairPip;
                           else
                              if (Adr1sl != 0.0)
                                 stoploss=OrderOpenPrice()+((adrvalues[ind].adr10/100)*Adr1sl)  *pairinfo[ind].PairPip;
                              else
                                 stoploss = 0.0;
                                 
                                 
                           if (Piptp != 0.0)
                              takeprofit=OrderOpenPrice() - Piptp * pairinfo[ind].PairPip;
                           else 
                              if (Adr1tp != 0.0)
                                 takeprofit=OrderOpenPrice() - ((adrvalues[ind].adr10/100)*Adr1tp) * pairinfo[ind].PairPip;
                              else
                                 takeprofit = 0.0;
                  OrderModify(ticket,OrderOpenPrice(),NormalizeDouble(stoploss,MarketInfo(TradePairs[ind],MODE_DIGITS)),NormalizeDouble(takeprofit,MarketInfo(TradePairs[ind],MODE_DIGITS)),0,clrBlue);
               }
               ObjectSetInteger(0,ind+"SELL",OBJPROP_STATE,0);
               ObjectSetString(0,ind+"SELL",OBJPROP_TEXT,"SELL");
               return;
        }
     if (StringFind(sparam,"CLOSE") >= 0)
        {
               int ind = StringToInteger(sparam);
               closeOpenOrders(TradePairs[ind]);               
               ObjectSetInteger(0,ind+"CLOSE",OBJPROP_STATE,0);
               ObjectSetString(0,ind+"CLOSE",OBJPROP_TEXT,"CLOSE");
               return;
        }
         
      if (StringFind(sparam,"Pair") >= 0) {
         int ind = StringToInteger(sparam);
         ObjectSetInteger(0,sparam,OBJPROP_STATE,0);
         OpenChart(ind);
         return;         
      }   
     }
}
void buy_basket(string &pairs[])
{
   int i;
   int ticket;
   
   for(i=0;i<ArraySize(pairs);i++)
   {
      ticket=OrderSend(pairs[i],OP_BUY,lot,MarketInfo(pairs[i],MODE_ASK),100,0,0,NULL,Magic_Number,0,clrNONE);
      if (OrderSelect(ticket,SELECT_BY_TICKET) == true) {
                  if (Pipsl != 0.0)
                           stoploss=OrderOpenPrice() - Pipsl * pairinfo[i].PairPip;
                        else
                           if (Adr1sl != 0.0)
                              stoploss=OrderOpenPrice() - ((adrvalues[i].adr10/100)*Adr1sl) * pairinfo[i].PairPip;
                           else
                              stoploss = 0.0;

                        if (Piptp != 0.0)
                              takeprofit=OrderOpenPrice() + Piptp * pairinfo[i].PairPip;
                        else
                           if (Adr1tp != 0.0)
                              takeprofit=OrderOpenPrice() + ((adrvalues[i].adr10/100)*Adr1tp) * pairinfo[i].PairPip;
                           else
                              takeprofit = 0.0;
                  OrderModify(ticket,OrderOpenPrice(),NormalizeDouble(stoploss,MarketInfo(pairs[i],MODE_DIGITS)),NormalizeDouble(takeprofit,MarketInfo(pairs[i],MODE_DIGITS)),0,clrBlue);
   }
  }
}

void sell_basket(string &pairs[])
{
   int i;
   int ticket;
   
   for(i=0;i<ArraySize(pairs);i++)
   {
      ticket=OrderSend(pairs[i],OP_SELL,lot,MarketInfo(pairs[i],MODE_BID),100,0,0,NULL,Magic_Number,0,clrNONE);
      if (OrderSelect(ticket,SELECT_BY_TICKET) == true) {
                   if (Pipsl != 0.0)
                              stoploss=OrderOpenPrice() + Pipsl * pairinfo[i].PairPip;
                           else
                              if (Adr1sl != 0.0)
                                 stoploss=OrderOpenPrice()+((adrvalues[i].adr10/100)*Adr1sl)  *pairinfo[i].PairPip;
                              else
                                 stoploss = 0.0;
                                 
                                 
                           if (Piptp != 0.0)
                              takeprofit=OrderOpenPrice() - Piptp * pairinfo[i].PairPip;
                           else 
                              if (Adr1tp != 0.0)
                                 takeprofit=OrderOpenPrice() - ((adrvalues[i].adr10/100)*Adr1tp) * pairinfo[i].PairPip;
                              else
                                 takeprofit = 0.0;
                  OrderModify(ticket,OrderOpenPrice(),NormalizeDouble(stoploss,MarketInfo(pairs[i],MODE_DIGITS)),NormalizeDouble(takeprofit,MarketInfo(pairs[i],MODE_DIGITS)),0,clrBlue);
   }
  }
}

void close_cur_basket(string &pairs[])
{ 
  
   if (OrdersTotal() <= 0)
   return;

   int TradeList[][2];
   int ctTrade = 0;

   for (int i=0; i<OrdersTotal(); i++) 
   {
	   OrderSelect(i, SELECT_BY_POS);
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true &&
         (OrderType()==0 || OrderType()==1) && 
         OrderMagicNumber()==Magic_Number &&
         InArray(pairs, OrderSymbol())) 
      {
	      ctTrade++;
		   ArrayResize(TradeList, ctTrade);
		   TradeList[ctTrade-1][0] = OrderOpenTime();
		   TradeList[ctTrade-1][1] = OrderTicket();
	   }
   }
   ArraySort(TradeList,WHOLE_ARRAY,0,MODE_ASCEND);

   for (int i=0;i<ctTrade;i++) 
   {
       if (OrderSelect(TradeList[i][1], SELECT_BY_TICKET)==true) 
       {
            if (OrderType()==0)
               {
               ticket=OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_BID), 100, clrNONE);
               if (ticket==-1) Print ("Error: ",  GetLastError());
               
               }
            if (OrderType()==1)
               {
               ticket=OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_ASK), 100, clrNONE);
               if (ticket==-1) Print ("Error: ",  GetLastError());
               
               }  
         }
         Sleep(500);
   }
      
}
//+------------------------------------------------------------------+
//| closeOpenOrders                                                  |
//+------------------------------------------------------------------+
void closeOpenOrders(string closecurr ) {
   int cnt = 0;

   for (cnt = OrdersTotal()-1 ; cnt >= 0 ; cnt--) {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true) {
         if(OrderType()==OP_BUY && OrderSymbol() == closecurr && OrderMagicNumber()==Magic_Number)
            ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Violet);
         else if(OrderType()==OP_SELL && OrderSymbol() == closecurr && OrderMagicNumber()==Magic_Number) 
            ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Violet);
         else if(OrderType()>OP_SELL) //pending orders
            ticket=OrderDelete(OrderTicket());
                   
      }
   }
}
void close_basket(int magic_number)
{ 
  
if (OrdersTotal() <= 0)
   return;

int TradeList[][2];
int ctTrade = 0;

for (int i=0; i<OrdersTotal(); i++) {
	OrderSelect(i, SELECT_BY_POS);
   if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true && (OrderType()==0 || OrderType()==1) && OrderMagicNumber()==Magic_Number) {
	   ctTrade++;
		ArrayResize(TradeList, ctTrade);
		TradeList[ctTrade-1][0] = OrderOpenTime();
		TradeList[ctTrade-1][1] = OrderTicket();
	}
}
ArraySort(TradeList,WHOLE_ARRAY,0,MODE_ASCEND);

for (int i=0;i<ctTrade;i++) {
      
       if (OrderSelect(TradeList[i][1], SELECT_BY_TICKET)==true) {
            if (OrderType()==0)
               {
               ticket=OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_BID), 3,Red);
               if (ticket==-1) Print ("Error: ",  GetLastError());
               
               }
            if (OrderType()==1)
               {
               ticket=OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_ASK), 3,Red);
               if (ticket==-1) Print ("Error: ",  GetLastError());
               
               }  
            }
      }
  
   for (int i=0;i<ArraySize(TradePairs);i++)
      pairinfo[i].lastSignal = NOTHING; 
       
   currentlock = 0.0;
   trailstarted = false;   
   lockdistance = 0.0;    
   SymbolMaxDD = 0;
   SymbolMaxHi = 0;
   PercentFloatingSymbol=0;
   PercentMaxDDSymbol=0;    
}
void close_profit()
{
 int cnt = 0; 
 for (cnt = OrdersTotal()-1 ; cnt >= 0 ; cnt--)
            {
               if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
               if (OrderProfit() > 0)
               {
                  if(OrderType()==OP_BUY && OrderMagicNumber()==Magic_Number)
                     ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Violet);
                  if(OrderType()==OP_SELL && OrderMagicNumber()==Magic_Number) 
                     ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Violet);
                  if(OrderType()>OP_SELL)
                     ticket=OrderDelete(OrderTicket());
               }
            } 
    }
void close_loss()
{
 int cnt = 0; 
 for (cnt = OrdersTotal()-1 ; cnt >= 0 ; cnt--)
            {
               if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
               if (OrderProfit() < 0)
               {
                  if(OrderType()==OP_BUY && OrderMagicNumber()==Magic_Number)
                     ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Violet);
                  if(OrderType()==OP_SELL && OrderMagicNumber()==Magic_Number) 
                     ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Violet);
                  if(OrderType()>OP_SELL)
                     ticket=OrderDelete(OrderTicket());
               }
            } 
    } 

void Reset_EA()
{
   currentlock = 0.0;
   trailstarted = false;   
   lockdistance = 0.0;    
   SymbolMaxDD = 0;
   SymbolMaxHi = 0;
   PercentFloatingSymbol=0;
   PercentMaxDDSymbol=0;
  
   OnInit();
}
                               
//+------------------------------------------------------------------+
void Trades()
{
   int i, j;
   totallots=0;
   totalprofit=0;
   totaltrades = 0;

   for(i=0;i<ArraySize(TradePairs);i++)
   {
      
      bpos[i]=0;
      spos[i]=0;       
      blots[i]=0;
      slots[i]=0;     
      bprofit[i]=0;
      sprofit[i]=0;
      tprofit[i]=0;
   }
	for(i=0;i<OrdersTotal();i++)
	{
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;

      for(j=0;j<ArraySize(TradePairs);j++)
      {	  
         if((TradePairs[j]==OrderSymbol() || TradePairs[j]=="") && OrderMagicNumber()==Magic_Number)
         {
            TradePairs[j]=OrderSymbol();                       
            tprofit[j]=tprofit[j]+OrderProfit()+OrderSwap()+OrderCommission();
           if(OrderType()==0){ bprofit[j]+=OrderProfit()+OrderSwap()+OrderCommission(); } 
           if(OrderType()==1){ sprofit[j]+=OrderProfit()+OrderSwap()+OrderCommission(); } 
           if(OrderType()==0){ blots[j]+=OrderLots(); } 
           if(OrderType()==1){ slots[j]+=OrderLots(); }
           if(OrderType()==0){ bpos[j]+=+1; } 
           if(OrderType()==1){ spos[j]+=+1; } 
                                
            totallots=totallots+OrderLots();
            totaltrades++;
            totalprofit = totalprofit+OrderProfit()+OrderSwap()+OrderCommission();
            break;
	     }
	  }
   }
   if (inSession() == true)
      SetText("CTPT","Trading",x_axis+200,y_axis-48,Green,9);
   else
      SetText("CTPT","Closed",x_axis+200,y_axis-48,Red,9);

   }
//+------------------------------------------------------------------+ 

void OpenChart(int ind) {
long nextchart = ChartFirst();
   do {
      string sym = ChartSymbol(nextchart);
      if (StringFind(sym,TradePairs[ind]) >= 0) {
            ChartSetInteger(nextchart,CHART_BRING_TO_TOP,true);
            ChartSetSymbolPeriod(nextchart,TradePairs[ind],TimeFrame);
            ChartApplyTemplate(nextchart,usertemplate);
            return;
         }
   } while ((nextchart = ChartNext(nextchart)) != -1);
   long newchartid = ChartOpen(TradePairs[ind],TimeFrame);
   ChartApplyTemplate(newchartid,usertemplate);
 }
//+------------------------------------------------------------------+  

void TradeManager() {

   double AccBalance=AccountBalance();
         
      //- Target
      if(Basket_Target>0 && totalprofit>=Basket_Target) {
         profitbaskets++;
         close_basket(Magic_Number);
         return;
      }
      
      //- StopLoss
      if(Basket_StopLoss>0 && totalprofit<(0-Basket_StopLoss)) {
         lossbaskets++;
         close_basket(Magic_Number);
         return;
      }

      //- Out off session
      if(inSession() == false && totallots > 0.0 && CloseAllSession == true) {
         close_basket(Magic_Number);
         return;
      }

      //- Profit lock stoploss
      if (currentlock != 0.0 && totalprofit < currentlock) {
         profitbaskets++;
         close_basket(Magic_Number);
         return;
      }

      //- Profit lock trail
      if (trailstarted == true && totalprofit > currentlock + lockdistance)
         currentlock = totalprofit - lockdistance;

      //- Lock in profit 1
      if (BasketP1 != 0.0 && BasketL1 != 0.0 && currentlock < BasketL1) {
         if (totalprofit > BasketP1)
            currentlock = BasketL1;
         if (BasketP2 == 0.0 && TrailLastLock == true) {
            trailstarted = true;
            if (TrailDistance != 0.0)
               lockdistance = BasketP1 - TrailDistance;
            else
               lockdistance = BasketL1;
         }
      }
      //- Lock in profit 2
      if (BasketP2 != 0.0 && BasketL2 != 0.0 && currentlock < BasketL2) {
         if (totalprofit > BasketP2)
            currentlock = BasketL2;
         if (BasketP3 == 0.0 && TrailLastLock == true) {
            trailstarted = true;
            if (TrailDistance != 0.0)
               lockdistance = BasketP2 - TrailDistance;
            else
               lockdistance = BasketL2;
         }
      }
      //- Lock in profit 3
      if (BasketP3 != 0.0 && BasketL3 != 0.0 && currentlock < BasketL3) {
         if (totalprofit > BasketP3)
            currentlock = BasketL3;
         if (BasketP4 == 0.0 && TrailLastLock == true) {
            trailstarted = true;
            if (TrailDistance != 0.0)
               lockdistance = BasketP3 - TrailDistance;
            else
               lockdistance = BasketL3;
         }
      }
      //- Lock in profit 4
      if (BasketP4 != 0.0 && BasketL4 != 0.0 && currentlock < BasketL4) {
         if (totalprofit > BasketP4)
            currentlock = BasketL4;
         if (BasketP5 == 0.0 && TrailLastLock == true) {
            trailstarted = true;
            if (TrailDistance != 0.0)
               lockdistance = BasketP4 - TrailDistance;
            else
               lockdistance = BasketL4;
         }
      }
      //- Lock in profit 5
      if (BasketP5 != 0.0 && BasketL5 != 0.0 && currentlock < BasketL5) {
         if (totalprofit > BasketP5)
            currentlock = BasketL5;
         if (BasketP6 == 0.0 && TrailLastLock == true) {
            trailstarted = true;
            if (TrailDistance != 0.0)
               lockdistance = BasketP5 - TrailDistance;
            else
               lockdistance = BasketL5;
         }
      }
      //- Lock in profit 6
      if (BasketP6 != 0.0 && BasketL6 != 0.0 && currentlock < BasketL6) {
         if (totalprofit > BasketP6)
            currentlock = BasketL6;
         if (TrailLastLock == true) {
            trailstarted = true;
            if (TrailDistance != 0.0)
               lockdistance = BasketP6 - TrailDistance;
            else
               lockdistance = BasketL6;
         }
      }


     if(totalprofit<=SymbolMaxDD) {
        SymbolMaxDD=totalprofit;
        GetBalanceSymbol=AccBalance;
     }

     if(GetBalanceSymbol != 0)
      PercentMaxDDSymbol=(SymbolMaxDD*100)/GetBalanceSymbol;
     
     if(totalprofit>=SymbolMaxHi) {
        SymbolMaxHi=totalprofit;
        GetBalanceSymbol=AccBalance;
     }
     
     if(GetBalanceSymbol != 0)
      PercentFloatingSymbol=(SymbolMaxHi*100)/GetBalanceSymbol;

     ObjectSetText("Lowest","Lowest= "+DoubleToStr(SymbolMaxDD,2)+" ("+DoubleToStr(PercentMaxDDSymbol,2)+"%)",8,NULL,BearColor);
     ObjectSetText("Highest","Highest= "+DoubleToStr(SymbolMaxHi,2)+" ("+DoubleToStr(PercentFloatingSymbol,2)+"%)",8,NULL,BullColor);
     ObjectSetText("Lock","Lock= "+DoubleToStr(currentlock,2),8,NULL,BullColor);
     ObjectSetText("Won",IntegerToString(profitbaskets,2),8,NULL,BullColor);
     ObjectSetText("Lost",IntegerToString(lossbaskets,2),8,NULL,BearColor);

}     
void PlotTrades() {

   for (int i=0; i<ArraySize(TradePairs);i++) {

     if(blots[i]>0){LotColor =Orange;}        
     if(blots[i]==0){LotColor =C'61,61,61';}
     if(slots[i]>0){LotColor1 =Orange;}        
     if(slots[i]==0){LotColor1 =C'61,61,61';}
     if(bpos[i]>0){OrdColor =DodgerBlue;}        
     if(bpos[i]==0){OrdColor =C'61,61,61';}
     if(spos[i]>0){OrdColor1 =DodgerBlue;}        
     if(spos[i]==0){OrdColor1 =C'61,61,61';}
     if(bprofit[i]>0){ProfitColor =BullColor;}
     if(bprofit[i]<0){ProfitColor =BearColor;}
     if(bprofit[i]==0){ProfitColor =C'61,61,61';}
     if(sprofit[i]>0){ProfitColor2 =BullColor;}
     if(sprofit[i]<0){ProfitColor2 =BearColor;}
     if(sprofit[i]==0){ProfitColor2 =C'61,61,61';}
     if(tprofit[i]>0){ProfitColor3 =BullColor;}
     if(tprofit[i]<0){ProfitColor3 =BearColor;}
     if(tprofit[i]==0){ProfitColor3 =C'61,61,61';}

     if(totalprofit>0){ProfitColor1 =BullColor;}
     if(totalprofit<0){ProfitColor1 =BearColor;}
     if(totalprofit==0){ProfitColor1 =clrWhite;}         

     ObjectSetText("bLots"+IntegerToString(i),DoubleToStr(blots[i],2),8,NULL,LotColor);
     ObjectSetText("sLots"+IntegerToString(i),DoubleToStr(slots[i],2),8,NULL,LotColor1);
     ObjectSetText("bPos"+IntegerToString(i),DoubleToStr(bpos[i],0),8,NULL,OrdColor);
     ObjectSetText("sPos"+IntegerToString(i),DoubleToStr(spos[i],0),8,NULL,OrdColor1);
     ObjectSetText("TProf"+IntegerToString(i),DoubleToStr(MathAbs(bprofit[i]),2),8,NULL,ProfitColor);
     ObjectSetText("SProf"+IntegerToString(i),DoubleToStr(MathAbs(sprofit[i]),2),8,NULL,ProfitColor2);
     ObjectSetText("TtlProf"+IntegerToString(i),DoubleToStr(MathAbs(tprofit[i]),2),8,NULL,ProfitColor3);
     ObjectSetText("TotProf",DoubleToStr(MathAbs(totalprofit),2),8,NULL,ProfitColor1);
   }
}
void PlotAdrValues() {

   for (int i=0;i<ArraySize(TradePairs);i++)
     ObjectSetText("S1"+IntegerToString(i),DoubleToStr(adrvalues[i].adr,0),8,NULL,Yellow);
}
bool inSession() {
 
   if ((localday != TimeDayOfWeek(TimeLocal()) && s1active == false && s2active == false && s3active == false) || localday == 99) {
      TimeToStruct(TimeLocal(),sess);
      StringSplit(sess1start,':',strspl);sess.hour=(int)strspl[0];sess.min=(int)strspl[1];sess.sec=0;
      s1start = StructToTime(sess);
      StringSplit(sess1end,':',strspl);sess.hour=(int)strspl[0];sess.min=(int)strspl[1];sess.sec=0;
      s1end = StructToTime(sess);
      StringSplit(sess2start,':',strspl);sess.hour=(int)strspl[0];sess.min=(int)strspl[1];sess.sec=0;
      s2start = StructToTime(sess);
      StringSplit(sess2end,':',strspl);sess.hour=(int)strspl[0];sess.min=(int)strspl[1];sess.sec=0;
      s2end = StructToTime(sess);
      StringSplit(sess3start,':',strspl);sess.hour=(int)strspl[0];sess.min=(int)strspl[1];sess.sec=0;
      s3start = StructToTime(sess);
      StringSplit(sess3end,':',strspl);sess.hour=(int)strspl[0];sess.min=(int)strspl[1];sess.sec=0;
      s3end = StructToTime(sess);
      if (s1end < s1start)
         s1end += 24*60*60;
      if (s2end < s2start)
         s2end += 24*60*60;
      if (s3end < s3start)
         s3end += 24*60*60;
      newSession();
      localday = TimeDayOfWeek(TimeLocal());
      Print("Sessions for today");
      if (UseSession1 == true)
         Print("Session 1 From:"+s1start+" until "+s1end);
      if (UseSession2 == true)
         Print("Session 2 From:"+s2start+" until "+s2end);
      if (UseSession3 == true)
         Print("Session 3 From:"+s3start+" until "+s3end);
   }


   if (UseSession1 && TimeLocal() >= s1start && TimeLocal() <= s1end) {
      comment = sess1comment;
      if (s1active == false)
         newSession();         
      else if ((StopProfit != 0 && profitbaskets >= StopProfit) || (StopLoss != 0 && lossbaskets >= StopLoss))
         return(false);
      s1active = true;
      return(true);
   } else {
      s1active = false;
   }   
   if (UseSession2 && TimeLocal() >= s2start && TimeLocal() <= s2end) {
      comment = sess2comment;
      if (s2active == false)
         newSession();
      else if ((StopProfit != 0 && profitbaskets >= StopProfit) || (StopLoss != 0 && lossbaskets >= StopLoss))
         return(false);
      s2active = true;
      return(true);
   } else {
      s2active = false;
   }
   if (UseSession3 && TimeLocal() >= s3start && TimeLocal() <= s3end) {
      comment = sess3comment;
      if (s3active == false)
         newSession();
      else if ((StopProfit != 0 && profitbaskets >= StopProfit) || (StopLoss != 0 && lossbaskets >= StopLoss))
         return(false);
      s3active = true;
      return(true);
   } else {
      s3active = false;
   }
   
   return(false);
}
void newSession() {
   
   profitbaskets = 0;
   lossbaskets = 0;
   SymbolMaxDD = 0.0;
   PercentMaxDDSymbol = 0.0;
   SymbolMaxHi=0.0;
   PercentFloatingSymbol = 0.0;
   currentlock = 0.0;
   trailstarted = false;   
   lockdistance = 0.0;
}

//-----------------------------------------------------------------------------
void ChngBoxCol(int mVal, int mBx)
 {
   if(mVal >= 0 && mVal < 10)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, White);
   if(mVal > 10 && mVal < 20)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, LightCyan);
   if(mVal > 20 && mVal < 30)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, PowderBlue);
   if(mVal > 30 && mVal < 40)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, PaleTurquoise);
   if(mVal > 40 && mVal < 50)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, LightBlue);
   if(mVal > 50 && mVal < 60)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, SkyBlue);
   if(mVal > 60 && mVal < 70)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, Turquoise);
   if(mVal > 70 && mVal < 80)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, DeepSkyBlue);
   if(mVal > 80 && mVal < 90)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, SteelBlue);
   if(mVal > 90 && mVal < 100)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, Blue);
   if(mVal > 100)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, MediumBlue);

   if(mVal < 0 && mVal > -10)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, White);
   if(mVal < -10 && mVal > -20)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, Seashell);
   if(mVal < -20 && mVal > -30)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, MistyRose);
   if(mVal < -30 && mVal > -40)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, Pink);
   if(mVal < -40 && mVal > -50)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, LightPink);
   if(mVal < -50 && mVal > -60)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, Plum);
   if(mVal < -60 && mVal >-70)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, Violet);
   if(mVal < -70 && mVal > -80)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, Orchid);
   if(mVal < -80 && mVal > -90)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, DeepPink);
   if(mVal < -90)
         ObjectSet("HM1"+mBx, OBJPROP_BGCOLOR, Red);
   return;
 }
//-----------------------------------------------------------------------------

bool InArray(string &pairs[], string symbol)
{
   int arraysize = ArraySize(pairs);
   if(arraysize <= 0) return(false);
   if(symbol == NULL) return(false);
   
   int i;
   
   for(i=0;i<arraysize;i++)
      if(pairs[i] == symbol) return(true);

   return(false);
}
//-------------------------------------------------------------------+ 
void PlotSpreadPips() {
             
   for (int i=0;i<ArraySize(TradePairs);i++) {
      if(MarketInfo(TradePairs[i],MODE_POINT) != 0 && pairinfo[i].pipsfactor != 0) {
       pairinfo[i].Pips = (iClose(TradePairs[i],PERIOD_D1,0)-iOpen(TradePairs[i], PERIOD_D1,0))/MarketInfo(TradePairs[i],MODE_POINT)/pairinfo[i].pipsfactor; 
       pairinfo[i].Pipsprev = (iClose(TradePairs[i],PERIOD_D1,signals[i].shift+900)-iOpen(TradePairs[i], PERIOD_D1,0))/MarketInfo(TradePairs[i],MODE_POINT)/pairinfo[i].pipsfactor;    
       pairinfo[i].Spread=MarketInfo(TradePairs[i],MODE_SPREAD)/pairinfo[i].pipsfactor;
       if(iClose(TradePairs[i], trigger_TF_HM1, 1)!=0){
       signals[i].Signalperc = (iClose(TradePairs[i], 1, 0) - iClose(TradePairs[i], trigger_TF_HM1, 1)) / iClose(TradePairs[i], trigger_TF_HM1, 1) * 100;
       }    
      }  
     if(pairinfo[i].Pips>0){PipsColor =BullColor;}
     if(pairinfo[i].Pips<0){PipsColor =BearColor;} 
     if(pairinfo[i].Pips==0){PipsColor =clrWhite;}       
     if(pairinfo[i].Spread > MaxSpread)
     
     ObjectSetText("Spr1"+IntegerToString(i),DoubleToStr(pairinfo[i].Spread,1),8,NULL,Red);
     else
      ObjectSetText("Spr1"+IntegerToString(i),DoubleToStr(pairinfo[i].Spread,1),8,NULL,Orange);
     ObjectSetText("Pp1"+IntegerToString(i),DoubleToStr(MathAbs(pairinfo[i].Pips),0),8,NULL,PipsColor);
     
     if(pairinfo[i].Pips > pairinfo[i].Pipsprev){
         pairinfo[i].PipsSig=UP;
        } else{
     if(pairinfo[i].Pips < pairinfo[i].Pipsprev)
         pairinfo[i].PipsSig=DOWN;
        }  
      

   }
}
//----------------------------------------------------------------------+
 void GetAdrValues() {

   double s=0.0;

   for (int i=0;i<ArraySize(TradePairs);i++) {

      for(int a=1;a<=20;a++) {
         if(pairinfo[i].PairPip != 0)
            s=s+(iHigh(TradePairs[i],PERIOD_D1,a)-iLow(TradePairs[i],PERIOD_D1,a))/pairinfo[i].PairPip;
         if(a==1)
            adrvalues[i].adr1=MathRound(s);
         if(a==5)
            adrvalues[i].adr5=MathRound(s/5);
         if(a==10)
            adrvalues[i].adr10=MathRound(s/10);
         if(a==20)
            adrvalues[i].adr20=MathRound(s/20);
      }
      adrvalues[i].adr=MathRound((adrvalues[i].adr1+adrvalues[i].adr5+adrvalues[i].adr10+adrvalues[i].adr20)/4.0);
      s=0.0;
   }
 }
//-----------------------------------------------------------------------------------------------+ 
void GetSignals() {
   int cnt = 0;
   ArrayResize(signals,ArraySize(TradePairs));
   for (int i=0;i<ArraySize(signals);i++) {
      signals[i].symbol=TradePairs[i]; 
      signals[i].point=MarketInfo(signals[i].symbol,MODE_POINT);
      signals[i].open=iOpen(signals[i].symbol,PERIOD_D1,0);      
      signals[i].close=iClose(signals[i].symbol,PERIOD_D1,0);
      signals[i].hi=MarketInfo(signals[i].symbol,MODE_HIGH);
      signals[i].lo=MarketInfo(signals[i].symbol,MODE_LOW);
      signals[i].bid=MarketInfo(signals[i].symbol,MODE_BID);
      signals[i].range=(signals[i].hi-signals[i].lo);
      signals[i].shift = iBarShift(signals[i].symbol,PERIOD_M1,TimeCurrent()-1800);
      signals[i].prevbid = iClose(signals[i].symbol,PERIOD_M1,signals[i].shift);
                 
     if(signals[i].range!=0) {            
      signals[i].ratio=MathMin(((signals[i].bid-signals[i].lo)/signals[i].range*100 ),100);
      signals[i].prevratio=MathMin(((signals[i].prevbid-signals[i].lo)/signals[i].range*100 ),100);     
           
      for (int j = 0; j < 8; j++){
            
      if(signals[i].ratio <= 3.0) signals[i].fact = 0;
      if(signals[i].ratio > 3.0)  signals[i].fact = 1;
      if(signals[i].ratio > 10.0) signals[i].fact = 2;
      if(signals[i].ratio > 25.0) signals[i].fact = 3;
      if(signals[i].ratio > 40.0) signals[i].fact = 4;
      if(signals[i].ratio > 50.0) signals[i].fact = 5;
      if(signals[i].ratio > 60.0) signals[i].fact = 6;
      if(signals[i].ratio > 75.0) signals[i].fact = 7;
      if(signals[i].ratio > 90.0) signals[i].fact = 8;
      if(signals[i].ratio > 97.0) signals[i].fact = 9;
       cnt++;
      
      if(curr[j]==StringSubstr(signals[i].symbol,3,3))
               signals[i].fact=9-signals[i].fact;

      if(curr[j]==StringSubstr(signals[i].symbol,0,3)) {
               signals[i].strength1=signals[i].fact;
              }  else{
      if(curr[j]==StringSubstr(signals[i].symbol,3,3))
               signals[i].strength2=signals[i].fact;
              }

      signals[i].calc =signals[i].strength1-signals[i].strength2;
      
      signals[i].strength=currency_strength(curr[j]);

            if(curr[j]==StringSubstr(signals[i].symbol,0,3)){
               signals[i].strength3=signals[i].strength;
            } else{
            if(curr[j]==StringSubstr(signals[i].symbol,3,3))
               signals[i].strength4=signals[i].strength;
            }
            signals[i].strength5=(signals[i].strength3-signals[i].strength4);
            
       signals[i].strength_old=old_currency_strength(curr[j]);

            if(curr[j]==StringSubstr(signals[i].symbol,0,3)){
               signals[i].strength6=signals[i].strength_old;
            } else {
            if(curr[j]==StringSubstr(signals[i].symbol,3,3))
               signals[i].strength7=signals[i].strength_old;
            }
            signals[i].strength8=(signals[i].strength6-signals[i].strength7);     
            signals[i].strength_Gap=signals[i].strength5-signals[i].strength8;
        
        if(signals[i].ratio>=trigger_buy_bidratio){
               signals[i].SigRatio=UP;
           } else {
         if(signals[i].ratio<=trigger_sell_bidratio)
               signals[i].SigRatio=DOWN;
           }  
        
        if(signals[i].ratio>signals[i].prevratio){
                signals[i].SigRatioPrev=UP;
           } else {
        if(signals[i].ratio<signals[i].prevratio)
                signals[i].SigRatioPrev=DOWN;
           }      
                    
        if(signals[i].calc>=trigger_buy_relstrength){
               signals[i].SigRelStr=UP;
             } else {
        if (signals[i].calc<=trigger_sell_relstrength) 
              signals[i].SigRelStr=DOWN;
             } 
             
         if(signals[i].strength5>=trigger_buy_buysellratio){
               signals[i].SigBSRatio=UP;
             } else {
       if (signals[i].calc<=trigger_sell_buysellratio) 
              signals[i].SigBSRatio=DOWN;
             }       
        
        if(signals[i].strength_Gap>=trigger_gap_buy){
               signals[i].SigGap=UP;
             } else {
        if (signals[i].strength_Gap<=trigger_gap_sell) 
              signals[i].SigGap=DOWN;
             }
              
        if(signals[i].strength5>signals[i].strength8){
              signals[i].SigGapPrev=UP;
             } else {
        if(signals[i].strength5<signals[i].strength8)      
               signals[i].SigGapPrev=DOWN;
             }          
      
      }
     
     }
      
    }    

}
//+------------------------------------------------------------------+       

color Colorstr(double tot) 
  {
   if(tot>=trigger_buy_bidratio)
      return (BullColor);
   if(tot<=trigger_sell_bidratio)
      return (BearColor);
   return (clrOrange);
  }
color ColorBSRat(double tot) 
  {
   if(tot>=trigger_buy_buysellratio)
      return (BullColor);
   if(tot<=trigger_sell_buysellratio)
      return (BearColor);
   return (clrOrange);
  } 
color ColorGap(double tot) 
  {
   if(tot>=trigger_gap_buy)
      return (BullColor);
   if(tot<=trigger_gap_sell)
      return (BearColor);
   return (clrOrange);
  }     
//-----------------------------------------------------------------------+
void comments() {
   Comment(" ---------------------------------------------", 
      "\n :: ======Elise Trend EA=====", 
      "\n :: Broker                 : ", AccountCompany(), 
      "\n :: Leverage               : 1 : ", AccountLeverage(), 
      "\n :: Equity                 : ", AccountEquity(), 
      "\n :: Time Server            :", Hour(), ":", Minute(), 
      "\n ------------------------------------------------", 
      "\n :: Trading Time", 
      "\n :: StartHour              :", sess1start, 
      "\n :: StopHour               :", sess1end, 
       
      
      "\n ------------------------------------------------", 
      "\n :: By: Elise",
      "\n :: Telegram: https://t.me/EliseRenard" 
   "\n ------------------------------------------------");
}
//+------------------------------------------------------------------+ 
void displayMeter() {
   
   double arrt[8][3];
   int arr2,arr3;
   arrt[0][0] = currency_strength(curr[0]); arrt[1][0] = currency_strength(curr[1]); arrt[2][0] = currency_strength(curr[2]);
   arrt[3][0] = currency_strength(curr[3]); arrt[4][0] = currency_strength(curr[4]); arrt[5][0] = currency_strength(curr[5]);
   arrt[6][0] = currency_strength(curr[6]); arrt[7][0] = currency_strength(curr[7]);
   arrt[0][2] = old_currency_strength(curr[0]); arrt[1][2] = old_currency_strength(curr[1]);arrt[2][2] = old_currency_strength(curr[2]);
   arrt[3][2] = old_currency_strength(curr[3]); arrt[4][2] = old_currency_strength(curr[4]);arrt[5][2] = old_currency_strength(curr[5]);
   arrt[6][2] = old_currency_strength(curr[6]);arrt[7][2] = old_currency_strength(curr[7]);
   arrt[0][1] = 0; arrt[1][1] = 1; arrt[2][1] = 2; arrt[3][1] = 3; arrt[4][1] = 4;arrt[5][1] = 5; arrt[6][1] = 6; arrt[7][1] = 7;
   ArraySort(arrt, WHOLE_ARRAY, 0, MODE_DESCEND);
     
   for (int m = 0; m < 8; m++) {
      arr2 = arrt[m][1];
      arr3=(int)arrt[m][2];
      currstrength[m] = arrt[m][0];
      prevstrength[m] = arrt[m][2]; 
         SetText(curr[arr2]+"pos",IntegerToString(m+1)+".",x_axis+595,(m*18)+y_axis+17,color_for_profit(arrt[m][0]),12);
         SetText(curr[arr2]+"curr", curr[arr2],x_axis+610,(m*18)+y_axis+17,color_for_profit(arrt[m][0]),12);
         SetText(curr[arr2]+"currdig", DoubleToStr(arrt[m][0],1),x_axis+650,(m*18)+y_axis+17,color_for_profit(arrt[m][0]),12);
        // SetText(curr[arr2]+"currdig", DoubleToStr(ratio[m][0],1),x_axis+280,(m*18)+y_axis+17,color_for_profit(arrt[m][0]),12);
        
        if(currstrength[m] > prevstrength[m]){SetObjText("Sdir"+IntegerToString(m),CharToStr(233),x_axis+680,(m*18)+y_axis+17,BullColor,12);}
         else if(currstrength[m] < prevstrength[m]){SetObjText("Sdir"+IntegerToString(m),CharToStr(234),x_axis+680,(m*18)+y_axis+17,BearColor,12);}
         else {SetObjText("Sdir"+IntegerToString(m),CharToStr(243),x_axis+680,(m*18)+y_axis+17,clrYellow,12);}
         
         
         }
 ChartRedraw(); 
}

color color_for_profit(double total) 
  {
  if(total<2.0)
      return (clrRed);
   if(total<=3.0)
      return (clrOrangeRed);
   if(total>7.0)
      return (clrLime);
   if(total>6.0)
      return (clrGreen);
   if(total>5.0)
      return (clrSandyBrown);
   if(total<=5.0)
      return (clrYellow);       
   return(clrSteelBlue);
  }

double currency_strength(string pair) {
   int fact;
   string sym;
   double range;
   double ratio;
   double strength = 0;
   int cnt1 = 0;
   
   for (int x = 0; x < ArraySize(TradePairs); x++) {
      fact = 0;
      sym = TradePairs[x];
      if (pair == StringSubstr(sym, 0, 3) || pair == StringSubstr(sym, 3, 3)) {
         range = (MarketInfo(sym, MODE_HIGH) - MarketInfo(sym, MODE_LOW)) ;
         if (range != 0.0) {
            ratio = 100.0 * ((MarketInfo(sym, MODE_BID) - MarketInfo(sym, MODE_LOW)) / range );
            if (ratio > 3.0)  fact = 1;
            if (ratio > 10.0) fact = 2;
            if (ratio > 25.0) fact = 3;
            if (ratio > 40.0) fact = 4;
            if (ratio > 50.0) fact = 5;
            if (ratio > 60.0) fact = 6;
            if (ratio > 75.0) fact = 7;
            if (ratio > 90.0) fact = 8;
            if (ratio > 97.0) fact = 9;
            cnt1++;
            if (pair == StringSubstr(sym, 3, 3)) fact = 9 - fact;
            strength += fact;
         }
      } 
           
   }
   if(cnt1!=0)strength /= cnt1;
   return (strength);
   
 }
//-----------------------------------------------------------------------------------+
double old_currency_strength(string pair) 
  {
   int fact;
   string sym;
   double range;
   double ratio;
   double strength=0;
   int cnt1=0;

   for(int x=0; x<ArraySize(TradePairs); x++) 
     {
      fact= 0;
      sym = TradePairs[x];
      int bar = iBarShift(TradePairs[x],PERIOD_M1,TimeCurrent()-1800);
      double prevbid = iClose(TradePairs[x],PERIOD_M1,bar);
      
      if(pair==StringSubstr(sym,0,3) || pair==StringSubstr(sym,3,3)) 
        {
         range=(MarketInfo(sym,MODE_HIGH)-MarketInfo(sym,MODE_LOW));
         if(range!=0.0) 
           {
            ratio=100.0 *((prevbid-MarketInfo(sym,MODE_LOW))/range);

            if(ratio > 3.0)  fact = 1;
            if(ratio > 10.0) fact = 2;
            if(ratio > 25.0) fact = 3;
            if(ratio > 40.0) fact = 4;
            if(ratio > 50.0) fact = 5;
            if(ratio > 60.0) fact = 6;
            if(ratio > 75.0) fact = 7;
            if(ratio > 90.0) fact = 8;
            if(ratio > 97.0) fact = 9;
            
            cnt1++;

            if(pair==StringSubstr(sym,3,3))
               fact=9-fact;

            strength+=fact;

           }
        }
     }
   if(cnt1!=0)
      strength/=cnt1;

   return (strength);
  
} 
//-----------------------------------------------------------------------+
color Colorsync(double tot) 
  {
   if(tot>=trigger_buy_relstrength)
      return (BullColor);
   if(tot<=trigger_sell_relstrength)
      return (BearColor);
   return (clrOrange);
  }
