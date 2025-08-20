//+------------------------------------------------------------------+
//|                                           Ichimoku Chinkou Cross Version 1.4.2 adds .5 profit take |
//|                                  Copyright © 2013, EarnForex.com |
//|                                        http://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, EarnForex"
#property link      "http://www.earnforex.com"

/*

Trades using Ichimoku Kinko Hyo indicator.

Implements Chinkou/Price cross strategy.

Chinkou crossing price (close) from below is a bullish signal.

Chinkou crossing price (close) from above is a bearish signal.

No SL/TP. Positions remain open from signal to signal.

Entry confirmed by current price above/below Kumo, latest Chinkou outside Kumo.

*/
//+------------------------------------------------------------------+
//|Mickers Mod:: anywhere I have modified the code I added my name in 
//|the comments, hopefully I didnt leave anything out.
//|First I have added an RSI filter to the order setups. Buy only if rsi > 70
//|and sell if rsi < 30. I have found that the overbought area is where longer term
//|up trends happen and likewise oversold for down trends.
//|------
//|For closing orders I have added two more styles. A position is closed if
//|a hard stop loss is hit. The stop loss is input in the input settings
//|as a percentage value in decimal format. Example for a 2% risk the input
//|is .02 and the calculation for the stop loss is:
//| NormalizeDouble((AccountBalance() * orderStopLossRisk) / LotsOptimized(), 0)
//|or more simply put: accountBalance * risk / lots 
//|The second way of closing is when the closing price closes below the Kijun-Sen for long
//|and price close above the Kijun-Sen for short positions                                                               
//+------------------------------------------------------------------+

// Main extern parameters

//+------------------------------------------------------------------+
//|Micker's Mod RSI filter inputs                                                                  
//+------------------------------------------------------------------+
input int kumoThreshold=300;//minimum size of kumo to open an order
input int failSafe=0;//0 is off, >0 sets the break even n pips above the entry price
input double failSafeCloserMultiplier=.1;//the amount of lots that are closed if failsafe is on
extern double orderStopLossRisk=.02;//stop loss %risk of account balance entered in decimal format
//---end micker's mod

// Money management
extern double Lots=0.1;       // Basic lot size
extern bool MM=true;     // If true - ATR-based position sizing
extern int ATR_Period=14;
extern double ATR_Multiplier=1;
extern double Risk=2; // Risk tolerance in percentage points
extern double FixedBalance=0; // If greater than 0, position size calculator will use it instead of actual account balance.
extern double MoneyRisk=0; // Risk tolerance in base currency
extern bool UseMoneyInsteadOfPercentage=false;
extern bool UseEquityInsteadOfBalance=false;
extern int LotDigits=2; // How many digits after dot supported in lot size. For example, 2 for 0.01, 1 for 0.1, 3 for 0.001, etc.

// Miscellaneous
extern int Slippage=100;    // Tolerated slippage in brokers' pips

// Common// Global variable
int Magic=2130512104;    // Order magic number
string OrderCommentary="Ichimoku-Chinkou-Hyo";
int Tenkan = 9; // Tenkan line period. The fast "moving average".
int Kijun = 26; // Kijun line period. The slow "moving average".
int Senkou= 52; // Senkou period. Used for Kumo (Cloud) spans.
int LastBars=0;
bool HaveLongPosition;
bool HaveShortPosition;
double StopLoss; // Not actual stop-loss - just a potential loss of MM estimation.

                 // Entry signals
bool ChinkouPriceBull = false;
bool ChinkouPriceBear = false;
bool KumoBullConfirmation = false;
bool KumoBearConfirmation = false;
bool KumoChinkouBullConfirmation = false;
bool KumoChinkouBearConfirmation = false;
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int init()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Each tick                                                        |
//+------------------------------------------------------------------+
int start()
  {
   if((!IsTradeAllowed()) || (IsTradeContextBusy()) || (!IsConnected()) || ((!MarketInfo(Symbol(), MODE_TRADEALLOWED)) && (!IsTesting()))) return(0);

// Trade only if new bar has arrived
   if(LastBars!=Bars) LastBars=Bars;
   else return(0);

   if(MM)
     {
      // Getting the potential loss value based on current ATR.
      StopLoss=iATR(NULL,0,ATR_Period,1)*ATR_Multiplier;
     }

// Chinkou/Price Cross

   double ChinkouSpanLatest=iIchimoku(NULL,0,Tenkan,Kijun,Senkou,MODE_CHINKOUSPAN,Kijun+1); // Latest closed bar with Chinkou.
   double ChinkouSpanPreLatest=iIchimoku(NULL,0,Tenkan,Kijun,Senkou,MODE_CHINKOUSPAN,Kijun+2); // Bar older than latest closed bar with Chinkou.

                                                                                               // Bullish entry condition
   if((ChinkouSpanLatest>Close[Kijun+1]) && (ChinkouSpanPreLatest<=Close[Kijun+2]))
     {
      ChinkouPriceBull = true;
      ChinkouPriceBear = false;
     }
// Bearish entry condition
   else if((ChinkouSpanLatest<Close[Kijun+1]) && (ChinkouSpanPreLatest>=Close[Kijun+2]))
     {
      ChinkouPriceBull = false;
      ChinkouPriceBear = true;
     }
   else if(ChinkouSpanLatest==Close[Kijun+1]) // Voiding entry conditions if cross is ongoing.
     {
      ChinkouPriceBull = false;
      ChinkouPriceBear = false;
     }
//+------------------------------------------------------------------+
//|Micker's Mods indicator setups                                    |                 
//+------------------------------------------------------------------+
   double tenkanSen= iIchimoku(NULL,PERIOD_CURRENT,Tenkan,Kijun,Senkou,MODE_TENKANSEN,0);
   double kijunSen = iIchimoku(NULL,PERIOD_CURRENT,Tenkan,Kijun,Senkou,MODE_KIJUNSEN,0);
   double tenkanSenHist= iIchimoku(NULL,PERIOD_CURRENT,Tenkan,Kijun,Senkou,MODE_TENKANSEN,1);
   double kijunSenHist = iIchimoku(NULL,PERIOD_CURRENT,Tenkan,Kijun,Senkou,MODE_KIJUNSEN,1);
   double stopLoss1=0;
   if(orderStopLossRisk>0) stopLoss1=NormalizeDouble((AccountBalance()*orderStopLossRisk)/LotsOptimized(),0);
   double tenkanSen5=iIchimoku(NULL,PERIOD_CURRENT,Tenkan,Kijun,Senkou,MODE_TENKANSEN,1);
   double slope=(tenkanSen-tenkanSen5)*1000;

   int cnt;
   int totally;
//---Labels
   setLabel("Next lot size: "+LotsOptimized(),"Max Lot ",20,20,10,Black);
   setLabel("Stop loss: "+stopLoss1,"stl ",20,40,10,Black);
   setLabel("Risk: "+(orderStopLossRisk)*100+"% ","risk ",20,60,10,Black);
   setLabel("Tenkan-Sen slope: "+slope,"tenkandigff ",20,120,10,Black);
   setLabel("Chinkou Bull signal: "+ChinkouPriceBull,"chinkou bull sig ",200,20,10,Black);
   setLabel("Chinkou Bear signal: "+ChinkouPriceBear,"chinkou bear sig ",200,40,10,Black);
   setLabel("Kumo Bull Confirmation: "+KumoBullConfirmation,"kumo bull conf ",200,60,10,Black);
   setLabel("Kumo Bear Confirmation: "+KumoBearConfirmation,"kumo bear conf ",200,80,10,Black);
   setLabel("Kumo Chinkou Bull Confirmation: "+KumoChinkouBullConfirmation,"kumo chinkou bull conf ",200,100,10,Black);
   setLabel("Kumo Chinkou Bear Confirmation: "+KumoChinkouBearConfirmation,"kumo chinkou bear conf ",200,120,10,Black);
   if(failSafe>0) setLabel("Failsafe is ON ","failsafe ",20,80,10,Black);
   else setLabel("Failsafe is OFF ","failsafe ",20,80,10,Black);
//+------------------------------------------------------------------+
//|End Micker's Mods  setups                                         |       
//+------------------------------------------------------------------+

// Kumo confirmation. When cross is happening current price (latest close) should be above/below both Senkou Spans, or price should close above/below both Senkou Spans after a cross.
   double SenkouSpanALatestByPrice = iIchimoku(NULL, 0, Tenkan, Kijun, Senkou, MODE_SENKOUSPANA, 1); // Senkou Span A at time of latest closed price bar.
   double SenkouSpanBLatestByPrice = iIchimoku(NULL, 0, Tenkan, Kijun, Senkou, MODE_SENKOUSPANB, 1); // Senkou Span B at time of latest closed price bar.
   if((Close[1]>SenkouSpanALatestByPrice) && (Close[1]>SenkouSpanBLatestByPrice)) KumoBullConfirmation=true;
   else KumoBullConfirmation=false;
   if((Close[1]<SenkouSpanALatestByPrice) && (Close[1]<SenkouSpanBLatestByPrice)) KumoBearConfirmation=true;
   else KumoBearConfirmation=false;

// Kumo/Chinkou confirmation. When cross is happening Chinkou at its latest close should be above/below both Senkou Spans at that time, or it should close above/below both Senkou Spans after a cross.
   double SenkouSpanALatestByChinkou = iIchimoku(NULL, 0, Tenkan, Kijun, Senkou, MODE_SENKOUSPANA, Kijun + 1); // Senkou Span A at time of latest closed bar of Chinkou span.
   double SenkouSpanBLatestByChinkou = iIchimoku(NULL, 0, Tenkan, Kijun, Senkou, MODE_SENKOUSPANB, Kijun + 1); // Senkou Span B at time of latest closed bar of Chinkou span.
   if((ChinkouSpanLatest>SenkouSpanALatestByChinkou) && (ChinkouSpanLatest>SenkouSpanBLatestByChinkou)) KumoChinkouBullConfirmation=true;
   else KumoChinkouBullConfirmation=false;
   if((ChinkouSpanLatest<SenkouSpanALatestByChinkou) && (ChinkouSpanLatest<SenkouSpanBLatestByChinkou)) KumoChinkouBearConfirmation=true;
   else KumoChinkouBearConfirmation=false;

   GetPositionStates();

//Micker's Mod close kijunSen closer and Kumo
   double SenkouSpanALatestByPriceF = iIchimoku(NULL, 0, Tenkan, Kijun, Senkou, MODE_SENKOUSPANA, -25);
   double SenkouSpanBLatestByPriceF = iIchimoku(NULL, 0, Tenkan, Kijun, Senkou, MODE_SENKOUSPANB, -25);
   double kumo=(SenkouSpanALatestByPriceF-SenkouSpanBLatestByPriceF)*1000;
   setLabel("Kumo: "+kumo,"kumo label ",20,100,10,Black);
//+------------------------------------------------------------------+
//|This closes an open position if the closing price is below the    |
//|Kijun-sen for long and above the Kijun-sen for short              |
//+------------------------------------------------------------------+

   if(HaveLongPosition)
     {
      if(Close[1]<kijunSenHist)
        {
         ClosePrevious();
        }
      else
      if(Bid<tenkanSen && failSafe>0)
        {

         totally=OrdersTotal();

         for(cnt=0;cnt<totally;cnt++)
           {
            if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
              {
               if(OrderType()==0 && OrderSymbol()==Symbol())
                 {
                  if(OrderStopLoss()<OrderOpenPrice())
                    {
                     if(!OrderClose(OrderTicket(),(OrderLots()*failSafeCloserMultiplier),Bid,Slippage,clrYellow))
                       {
                        Print("Order close error ",GetLastError());
                       }

                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),failSafe*Point+OrderOpenPrice(),OrderTakeProfit(),0,clrRed))//failSafe*Point + OrderOpenPrice()
                       {
                        Print("OrderModify error ",GetLastError());
                       }
                    }
                 }
              }
           }
        }
     }
   if(HaveShortPosition)
     {
      if(Close[1]>kijunSenHist)
        {
         ClosePrevious();
        }
      else
      if(Bid>tenkanSen && failSafe>0)
        {
         totally=OrdersTotal();

         for(cnt=0;cnt<totally;cnt++)
           {
            if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
              {
               if(OrderType()==1 && OrderSymbol()==Symbol())
                 {
                  if(OrderStopLoss()>OrderOpenPrice())
                    {
                     if(!OrderClose(OrderTicket(),(OrderLots()*failSafeCloserMultiplier),Bid,Slippage,clrYellow))
                       {
                        Print("Order Close Error ",GetLastError());
                       }

                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-failSafe*Point,OrderTakeProfit(),0,clrRed))
                       {
                        Print("OrderModify error ",GetLastError());
                       }
                    }

                 }
              }
           }
        }
     }
//---end micker mod close kijunSen close-- 

   if(ChinkouPriceBull)
     {
      if(HaveShortPosition) ClosePrevious();
      if((KumoBullConfirmation) && (KumoChinkouBullConfirmation) && kumo>kumoThreshold)//Micker's Mod added RSI filter
        {
         ChinkouPriceBull=false;
         fBuy(stopLoss1);
         SendMail("Ichimoku Kinko Hyo Trade System", "A long position has been placed by the Ichimoku System on the " + Symbol() + " chart. ");
        }
     }
   else if(ChinkouPriceBear)
     {
      if(HaveLongPosition) ClosePrevious();
      if((KumoBearConfirmation) && (KumoChinkouBearConfirmation) && kumo<-kumoThreshold)//Micker's Mod added RSI filter
        {
         fSell(stopLoss1);
         ChinkouPriceBear=false;
         SendMail("Ichimoku Kinko Hyo Trade System", "A short position has been placed by the Ichimoku System on the " + Symbol() + " chart. ");
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Check what position is currently open										|
//+------------------------------------------------------------------+
void GetPositionStates()
  {
   int total=OrdersTotal();
   for(int cnt=0; cnt<total; cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==false) continue;
      if(OrderMagicNumber()!=Magic) continue;
      if(OrderSymbol()!=Symbol()) continue;

      if(OrderType()==OP_BUY)
        {
         HaveLongPosition=true;
         HaveShortPosition=false;
         return;
        }
      else if(OrderType()==OP_SELL)
        {
         HaveLongPosition=false;
         HaveShortPosition=true;
         return;
        }
     }
   HaveLongPosition=false;
   HaveShortPosition=false;
  }
//+------------------------------------------------------------------+
//| Buy                                                              |
//+------------------------------------------------------------------+
void fBuy(double stpL)//mickers mods added stpL to pass a stop loss value
  {
   RefreshRates();
   double stop=0;
   if(stpL>0) stop=Bid-stpL*Point;//mickersmod stop loss
   int result= OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,Slippage,stop,0,OrderCommentary,Magic);
   if(result == -1)
     {
      int e=GetLastError();
      Print("OrderSend Error: ",e);
     }
  }
//+------------------------------------------------------------------+
//| Sell                                                             |
//+------------------------------------------------------------------+
void fSell(double stpL)//mickers mods added stpL to pass a stop loss value
  {
   RefreshRates();
   double stop=0;
   if(stpL>0) stop=Ask+stpL*Point;//mickersmod stop loss
   int result= OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,Slippage,stop,0,OrderCommentary,Magic);
   if(result == -1)
     {
      int e=GetLastError();
      Print("OrderSend Error: ",e);
     }
  }
//+------------------------------------------------------------------+
//| Calculate position size depending on money management parameters.|
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   if(!MM) return (Lots);

   double Size,RiskMoney,PositionSize=0;

   if(AccountCurrency() == "") return(0);

   if(FixedBalance>0)
     {
      Size=FixedBalance;
     }
   else if(UseEquityInsteadOfBalance)
     {
      Size=AccountEquity();
     }
   else
     {
      Size=AccountBalance();
     }

   if(!UseMoneyInsteadOfPercentage) RiskMoney=Size*Risk/100;
   else RiskMoney=MoneyRisk;

   double UnitCost = MarketInfo(Symbol(), MODE_TICKVALUE);
   double TickSize = MarketInfo(Symbol(), MODE_TICKSIZE);

   if((StopLoss!=0) && (UnitCost!=0) && (TickSize!=0)) PositionSize=NormalizeDouble(RiskMoney/(StopLoss*UnitCost/TickSize),LotDigits);

   if(PositionSize<MarketInfo(Symbol(),MODE_MINLOT)) PositionSize=MarketInfo(Symbol(),MODE_MINLOT);
   else if(PositionSize>MarketInfo(Symbol(),MODE_MAXLOT)) PositionSize=MarketInfo(Symbol(),MODE_MAXLOT);

   return(PositionSize);
  }
//+------------------------------------------------------------------+
//| Close previous position                                          |
//+------------------------------------------------------------------+
void ClosePrevious()
  {
   int total = OrdersTotal();
   for(int i = 0; i < total; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS)==false) continue;
      if((OrderSymbol()==Symbol()) && (OrderMagicNumber()==Magic))
        {
         if(OrderType()==OP_BUY)
           {
            RefreshRates();
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,Slippage))
               {
                Print("Order close error ", GetLastError());
               }
           }
         else if(OrderType()==OP_SELL)
           {
            RefreshRates();
            if(!OrderClose(OrderTicket(),OrderLots(),Ask,Slippage))
               {
                Print("Order close error ", GetLastError());
               }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|Micker's Mod custom functions                                                                  |
//+------------------------------------------------------------------+
//+-----------For writing stuff on the screen-------------------------------------------------------+

string setLabel(string labelText,string name,int xdist,int ydist,int fontSize,color Color)
  {

   if(ObjectFind(name)!=-1) ObjectDelete(name);
   ObjectCreate(name,OBJ_LABEL,0,0,0,0,0);
   ObjectSetText(name,labelText,fontSize,"Arial",clrWhiteSmoke);
   ObjectSet(name,OBJPROP_COLOR,Color);
   ObjectSet(name,OBJPROP_CORNER,0);
   ObjectSet(name,OBJPROP_XDISTANCE,xdist);
   ObjectSet(name,OBJPROP_YDISTANCE,ydist);
   return (true);
  }
//+------------------------------------------------------------------+
