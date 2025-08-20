//+----------------------------------------------------------------------+
//| GainzAlgoPro.mq4                                                     |
//| Converted from GainzAlgo Pro Pine Script by GainzAlgo                 |
//| Description: EA that trades based on bullish/bearish engulfing, RSI,  |
//| candle stability, and price delta conditions.                        |
//+----------------------------------------------------------------------+

#property copyright "Converted from GainzAlgo Pro"
#property link      "https://x.ai"
#property version   "1.00"
#property strict

//--- Input Parameters
// Technical Inputs
input double CandleStabilityIndex = 0.5; // Candle Stability Index (0 to 1)
input int RSIIndex = 50;                 // RSI Index (0 to 100)
input int CandleDeltaLength = 5;         // Candle Delta Length (min 3)
input bool DisableRepeatingSignals = false; // Disable Repeating Signals

// Trade Inputs
input double LotSize = 0.1;              // Lot Size
input int StopLoss = 50;                 // Stop Loss (pips)
input int TakeProfit = 100;              // Take Profit (pips)
input int Slippage = 3;                  // Slippage (pips)
input int MagicNumber = 123456;          // Magic Number for trades

// Cosmetic Inputs (for alerts/comments)
input string BuySignalComment = "BUY Signal";  // Buy Signal Comment
input string SellSignalComment = "SELL Signal"; // Sell Signal Comment

//--- Global Variables
string lastSignal = ""; // Tracks last signal to prevent repeats
double point;           // Point value adjusted for 3/5-digit brokers

//+----------------------------------------------------------------------+
//| Expert initialization function                                        |
//+----------------------------------------------------------------------+
int OnInit()
{
   // Adjust point value for 3/5-digit brokers
   point = Point;
   if(Digits == 3 || Digits == 5)
      point *= 10;
      
   // Validate inputs
   if(CandleStabilityIndex < 0 || CandleStabilityIndex > 1)
   {
      Alert("CandleStabilityIndex must be between 0 and 1");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if(RSIIndex < 0 || RSIIndex > 100)
   {
      Alert("RSIIndex must be between 0 and 100");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if(CandleDeltaLength < 3)
   {
      Alert("CandleDeltaLength must be at least 3");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   return(INIT_SUCCEEDED);
}

//+----------------------------------------------------------------------+
//| Expert deinitialization function                                      |
//+----------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Clean up if needed
}

//+----------------------------------------------------------------------+
//| Expert tick function                                                 |
//+----------------------------------------------------------------------+
void OnTick()
{
   // Only process on new bar
   static datetime lastBar;
   datetime currentBar = Time[0];
   if(lastBar != currentBar)
   {
      lastBar = currentBar;
      CheckForSignals();
   }
}

//+----------------------------------------------------------------------+
//| Check for buy/sell signals and place trades                          |
//+----------------------------------------------------------------------+
void CheckForSignals()
{
   // Check if there are enough bars
   if(Bars < CandleDeltaLength + 2) // +2 for Close[1] and Close[2]
   {
      Alert("Not enough bars for calculation. Need at least ", CandleDeltaLength + 2, " bars.");
      Comment("Not enough bars for calculation.");
      return;
   }

   //--- Calculate Indicators
   // Candle Stability: (abs(close - open) / true range) > CandleStabilityIndex
   double body = MathAbs(Close[1] - Open[1]);
   double trueRange = MathMax(High[1] - Low[1], 
                              MathMax(High[1] - Close[2], Close[2] - Low[1]));
   bool stableCandle = (trueRange > 0) ? (body / trueRange > CandleStabilityIndex) : false;
   
   // RSI (14-period)
   double rsi = iRSI(NULL, 0, 14, PRICE_CLOSE, 1);
   
   //--- Buy Signal Conditions
   bool bullishEngulfing = (Close[2] < Open[2]) && // Previous candle bearish
                           (Close[1] > Open[1]) && // Current candle bullish
                           (Close[1] > Open[2]);   // Engulfs previous open
   bool rsiBelow = rsi < RSIIndex;
   bool decreaseOver = Close[1] < Close[CandleDeltaLength];
   bool bull = bullishEngulfing && stableCandle && rsiBelow && decreaseOver;
   
   //--- Sell Signal Conditions
   bool bearishEngulfing = (Close[2] > Open[2]) && // Previous candle bullish
                           (Close[1] < Open[1]) && // Current candle bearish
                           (Close[1] < Open[2]);   // Engulfs previous open
   bool rsiAbove = rsi > (100 - RSIIndex);
   bool increaseOver = Close[1] > Close[CandleDeltaLength];
   bool bear = bearishEngulfing && stableCandle && rsiAbove && increaseOver;
   
   //--- Handle Signals
   int ticket = -1; // Declare ticket once
   if(bull && (!DisableRepeatingSignals || lastSignal != "buy"))
   {
      double sl = StopLoss > 0 ? Bid - StopLoss * point : 0;
      double tp = TakeProfit > 0 ? Bid + TakeProfit * point : 0;
      ticket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, Slippage, sl, tp, 
                         BuySignalComment, MagicNumber, 0, clrGreen);
      if(ticket > 0)
      {
         Alert(BuySignalComment + " at " + DoubleToStr(Ask, Digits));
         lastSignal = "buy";
      }
      else
      {
         Alert("Buy order failed, error: ", GetLastError());
      }
   }
   
   if(bear && (!DisableRepeatingSignals || lastSignal != "sell"))
   {
      double sl = StopLoss > 0 ? Ask + StopLoss * point : 0;
      double tp = TakeProfit > 0 ? Ask - TakeProfit * point : 0;
      ticket = OrderSend(Symbol(), OP_SELL, LotSize, Bid, Slippage, sl, tp, 
                         SellSignalComment, MagicNumber, 0, clrRed);
      if(ticket > 0)
      {
         Alert(SellSignalComment + " at " + DoubleToStr(Bid, Digits));
         lastSignal = "sell";
      }
      else
      {
         Alert("Sell order failed, error: ", GetLastError());
      }
   }
   
   // Update chart comment
   string comment = "GainzAlgoPro\n";
   comment += "Last Signal: " + lastSignal + "\n";
   comment += "RSI: " + DoubleToStr(rsi, 2) + "\n";
   comment += "Stable Candle: " + (stableCandle ? "Yes" : "No");
   Comment(comment);
}