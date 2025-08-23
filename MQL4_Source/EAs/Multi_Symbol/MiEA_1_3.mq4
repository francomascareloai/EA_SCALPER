//+------------------------------------------------------------------+
//|                                                         MiEA.mq4 |
//|                                                       MFOREX.PRO |
//|                                           https://www.mforex.pro |
//+------------------------------------------------------------------+
#property copyright "MFOREX.PRO"
#property link      "https://www.mforex.pro"
#property version   "1.30"
#property strict
//+------------------------------------------------------------------+
//|   Выбор языка                                                   
//+------------------------------------------------------------------+
enum Lang{
     r=0,  //RU
     e=1,  //EN
     };
//+------------------------------------------------------------------+
//|   Переменные                                                   
//+------------------------------------------------------------------+
input Lang   Languale          =1;
input bool   UseLotManual      =false;
input double ManualLot         =0.01;
input double Risk              =1;
input double StopLossProcent   =0;
input int    ProfitPips        =30;
input bool   UseUPlot          =false;
input int    TimeFrame         =5;
input string pEURUSD           ="EURUSD";
input int    pEURUSD_StepM     =50;
input int    pEURUSD_StepP     =20;
input string pGBPUSD           ="GBPUSD";
input int    pGBPUSD_StepM     =50;
input int    pGBPUSD_StepP     =20;
input string pAUDUSD           ="AUDUSD";
input int    pAUDUSD_StepM     =50;
input int    pAUDUSD_StepP     =20;
input string pNZDUSD           ="NZDUSD";
input int    pNZDUSD_StepM     =50;
input int    pNZDUSD_StepP     =20;
input string pUSDJPY           ="USDJPY";
input int    pUSDJPY_StepM     =50;
input int    pUSDJPY_StepP     =20;
input string pUSDCAD           ="USDCAD";
input int    pUSDCAD_StepM     =50;
input int    pUSDCAD_StepP     =20;
input string pUSDCHF           ="USDCHF";
input int    pUSDCHF_StepM     =50;
input int    pUSDCHF_StepP     =20;
input string pEURJPY           ="EURJPY";
input int    pEURJPY_StepM     =50;
input int    pEURJPY_StepP     =20;
input string pGBPJPY           ="GBPJPY";
input int    pGBPJPY_StepM     =50;
input int    pGBPJPY_StepP     =20;
input int    MaxOrders         =100;
input double TimeStart         =2;  
input double TimeEnd           =22; 
input string MobClosPair       ="EURAUD"; 
input color  FonColor          =Black;
input int    FontSize          =7;
input int    FontSizeInfo      =7;
input int    SpeedEA           =50;
input color  TXTButton         =Red;     
input color  ClickButton       =Black;
input color  FonButtonInfo     =White;
input color  FonButtonBuy      =Blue;  
input color  FonButtonSell     =Red;
input color  TextButtonBS      =White;
input color  FonButton         =White;
input color  TextColor         =White;  
input color  ButtonBorder      =Blue;
input color  InfoDataColor     =Red;  
input color  InfoDataColorText =Red;  
input color  EditColor         =Black;   
input int    Magic             =1234; 
input int    Id19               =0; 
//+------------------------------------------------------------------+
//|   Дополнительные переменные                                                    
//+------------------------------------------------------------------+
string comment = "www.mforex.pro";
int BWidth   = 60;
int BHeigh   = 20; 
int o;
double Lot_1          =0;
double Lot_2          =0;
double Lot_3          =0;
double Lot_4          =0;
double Lot_5          =0;
double Lot_6          =0;
double Lot_7          =0;
double Lot_8          =0;
double Lot_9          =0;
int D_1,D_2,D_3,D_4,D_5,D_6,D_7,D_8,D_9;
int dig_1,dig_2,dig_3,dig_4,dig_5,dig_6,dig_7,dig_8,dig_9;
static double price_1 =0;
static double price_2 =0;
static double price_3 =0;
static double price_4 =0;
static double price_5 =0;
static double price_6 =0;
static double price_7 =0;
static double price_8 =0;
static double price_9 =0;
string Pair_1,Pair_2,Pair_3,Pair_4,Pair_5,Pair_6,Pair_7,Pair_8,Pair_9;
string Pair[10];
int StepM[10];
int StepP[10];
double Lot[10];
int D[10];
int dig[10];
static double price[10];
bool TradeAllowed = true;
datetime LastTradeTime = 0;
int MinTradeInterval = 60; // seconds

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   EventSetMillisecondTimer(SpeedEA);
   
   // Initialize pairs array
   Pair[1] = pEURUSD; StepM[1] = pEURUSD_StepM; StepP[1] = pEURUSD_StepP;
   Pair[2] = pGBPUSD; StepM[2] = pGBPUSD_StepM; StepP[2] = pGBPUSD_StepP;
   Pair[3] = pAUDUSD; StepM[3] = pAUDUSD_StepM; StepP[3] = pAUDUSD_StepP;
   Pair[4] = pNZDUSD; StepM[4] = pNZDUSD_StepM; StepP[4] = pNZDUSD_StepP;
   Pair[5] = pUSDJPY; StepM[5] = pUSDJPY_StepM; StepP[5] = pUSDJPY_StepP;
   Pair[6] = pUSDCAD; StepM[6] = pUSDCAD_StepM; StepP[6] = pUSDCAD_StepP;
   Pair[7] = pUSDCHF; StepM[7] = pUSDCHF_StepM; StepP[7] = pUSDCHF_StepP;
   Pair[8] = pEURJPY; StepM[8] = pEURJPY_StepM; StepP[8] = pEURJPY_StepP;
   Pair[9] = pGBPJPY; StepM[9] = pGBPJPY_StepM; StepP[9] = pGBPJPY_StepP;
   
   // Initialize digits and multipliers for each pair
   for(int i=1; i<=9; i++)
   {
      int digits = (int)MarketInfo(Pair[i], MODE_DIGITS);
      if(digits == 5 || digits == 3) D[i] = 10;
      else D[i] = 1;
      dig[i] = digits;
   }
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectsDeleteAll(0, OBJ_LABEL);
   ObjectsDeleteAll(0, OBJ_RECTANGLE_LABEL);
   ObjectsDeleteAll(0, OBJ_BUTTON);
   ObjectsDeleteAll(0, OBJ_EDIT);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Check if trading is allowed
   if(!IsTradeAllowed()) return;
   
   // Time filter
   int currentHour = TimeHour(TimeCurrent());
   if(currentHour < TimeStart || currentHour >= TimeEnd) return;
   
   // Process each currency pair
   for(int i=1; i<=9; i++)
   {
      ProcessPair(i);
   }
   
   // Update info panel
   UpdateInfoPanel();
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   OnTick();
}

//+------------------------------------------------------------------+
//| Process individual currency pair                                 |
//+------------------------------------------------------------------+
void ProcessPair(int pairIndex)
{
   string symbol = Pair[pairIndex];
   if(symbol == "") return;
   
   // Calculate lot size
   CalculateLotSize(pairIndex);
   
   // Check for trading signals
   int signal = GetTradingSignal(symbol, pairIndex);
   
   // Execute trades based on signals
   if(signal == 1) // Buy signal
   {
      if(CountOrders(symbol, OP_BUY) == 0 && CountTotalOrders() < MaxOrders)
      {
         double ask = MarketInfo(symbol, MODE_ASK);
         double sl = 0;
         double tp = 0;
         
         if(ProfitPips > 0)
            tp = ask + ProfitPips * MarketInfo(symbol, MODE_POINT) * D[pairIndex];
            
         int ticket = OrderSend(symbol, OP_BUY, Lot[pairIndex], ask, 3, sl, tp, comment, Magic, 0, Blue);
         if(ticket > 0)
         {
            LastTradeTime = TimeCurrent();
            price[pairIndex] = ask;
         }
      }
   }
   else if(signal == -1) // Sell signal
   {
      if(CountOrders(symbol, OP_SELL) == 0 && CountTotalOrders() < MaxOrders)
      {
         double bid = MarketInfo(symbol, MODE_BID);
         double sl = 0;
         double tp = 0;
         
         if(ProfitPips > 0)
            tp = bid - ProfitPips * MarketInfo(symbol, MODE_POINT) * D[pairIndex];
            
         int ticket = OrderSend(symbol, OP_SELL, Lot[pairIndex], bid, 3, sl, tp, comment, Magic, 0, Red);
         if(ticket > 0)
         {
            LastTradeTime = TimeCurrent();
            price[pairIndex] = bid;
         }
      }
   }
   
   // Check for stop loss by percentage
   if(StopLossProcent > 0)
   {
      double lossLimit = AccountBalance() * StopLossProcent / 100 * (-1);
      if(GetTotalProfit() < lossLimit)
      {
         CloseAllOrders();
      }
   }
}

//+------------------------------------------------------------------+
//| Calculate lot size for pair                                      |
//+------------------------------------------------------------------+
void CalculateLotSize(int pairIndex)
{
   if(UseLotManual)
   {
      Lot[pairIndex] = ManualLot;
   }
   else
   {
      double tickValue = MarketInfo(Pair[pairIndex], MODE_TICKVALUE);
      if(tickValue > 0)
      {
         Lot[pairIndex] = NormalizeDouble(AccountBalance() * Risk / 100 / (tickValue * 100 * D[pairIndex]), 2);
      }
      else
      {
         Lot[pairIndex] = 0.01;
      }
   }
   
   // Normalize lot size
   double minLot = MarketInfo(Pair[pairIndex], MODE_MINLOT);
   double maxLot = MarketInfo(Pair[pairIndex], MODE_MAXLOT);
   
   if(Lot[pairIndex] < minLot) Lot[pairIndex] = minLot;
   if(Lot[pairIndex] > maxLot) Lot[pairIndex] = maxLot;
}

//+------------------------------------------------------------------+
//| Get trading signal for symbol                                    |
//+------------------------------------------------------------------+
int GetTradingSignal(string symbol, int pairIndex)
{
   // Simple momentum-based strategy
   double ma_fast = iMA(symbol, TimeFrame, 10, 0, MODE_SMA, PRICE_CLOSE, 0);
   double ma_slow = iMA(symbol, TimeFrame, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
   double rsi = iRSI(symbol, TimeFrame, 14, PRICE_CLOSE, 0);
   
   double currentPrice = (MarketInfo(symbol, MODE_ASK) + MarketInfo(symbol, MODE_BID)) / 2;
   double priceChange = MathAbs(currentPrice - price[pairIndex]);
   double stepThreshold = StepM[pairIndex] * MarketInfo(symbol, MODE_POINT) * D[pairIndex];
   
   // Buy conditions
   if(ma_fast > ma_slow && rsi < 70 && priceChange > stepThreshold)
   {
      return 1; // Buy signal
   }
   
   // Sell conditions
   if(ma_fast < ma_slow && rsi > 30 && priceChange > stepThreshold)
   {
      return -1; // Sell signal
   }
   
   return 0; // No signal
}

//+------------------------------------------------------------------+
//| Count orders for specific symbol and type                        |
//+------------------------------------------------------------------+
int CountOrders(string symbol, int type)
{
   int count = 0;
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == symbol && OrderMagicNumber() == Magic && OrderType() == type)
         {
            count++;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Count total orders                                               |
//+------------------------------------------------------------------+
int CountTotalOrders()
{
   int count = 0;
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderMagicNumber() == Magic)
         {
            count++;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Get total profit                                                 |
//+------------------------------------------------------------------+
double GetTotalProfit()
{
   double profit = 0;
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderMagicNumber() == Magic)
         {
            profit += OrderProfit() + OrderSwap() + OrderCommission();
         }
      }
   }
   return profit;
}

//+------------------------------------------------------------------+
//| Close all orders                                                 |
//+------------------------------------------------------------------+
void CloseAllOrders()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderMagicNumber() == Magic)
         {
            if(OrderType() == OP_BUY)
            {
               OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 3, Blue);
            }
            else if(OrderType() == OP_SELL)
            {
               OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 3, Red);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check if trading is allowed                                      |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
{
   if(!IsTradeAllowed()) return false;
   if(TimeCurrent() - LastTradeTime < MinTradeInterval) return false;
   return true;
}

//+------------------------------------------------------------------+
//| Update information panel                                         |
//+------------------------------------------------------------------+
void UpdateInfoPanel()
{
   int x = 10, y = 20;
   int panelWidth = 250;
   int panelHeight = 200;
   
   // Background
   CreateRectangleLabel("InfoBackground", x-5, y-5, panelWidth, panelHeight, FonColor);
   
   // Title
   CreateLabel("InfoTitle", "MiEA Multi-Symbol EA v1.3", x, y, TextColor, FontSizeInfo+2);
   y += 20;
   
   // Account info
   CreateLabel("InfoBalance", "Balance: " + DoubleToStr(AccountBalance(), 2) + " " + AccountCurrency(), x, y, InfoDataColor, FontSizeInfo);
   y += 15;
   
   CreateLabel("InfoEquity", "Equity: " + DoubleToStr(AccountEquity(), 2) + " " + AccountCurrency(), x, y, InfoDataColor, FontSizeInfo);
   y += 15;
   
   CreateLabel("InfoProfit", "Total Profit: " + DoubleToStr(GetTotalProfit(), 2) + " " + AccountCurrency(), x, y, InfoDataColor, FontSizeInfo);
   y += 15;
   
   CreateLabel("InfoOrders", "Total Orders: " + IntegerToString(CountTotalOrders()), x, y, InfoDataColor, FontSizeInfo);
   y += 20;
   
   // Pair information
   for(int i=1; i<=9; i++)
   {
      if(Pair[i] != "")
      {
         string pairInfo = Pair[i] + ": Buy=" + IntegerToString(CountOrders(Pair[i], OP_BUY)) + 
                          " Sell=" + IntegerToString(CountOrders(Pair[i], OP_SELL));
         CreateLabel("InfoPair" + IntegerToString(i), pairInfo, x, y, InfoDataColorText, FontSize);
         y += 12;
      }
   }
}

//+------------------------------------------------------------------+
//| Create label                                                     |
//+------------------------------------------------------------------+
void CreateLabel(string name, string text, int x, int y, color clr, int size)
{
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

//+------------------------------------------------------------------+
//| Create rectangle label                                           |
//+------------------------------------------------------------------+
void CreateRectangleLabel(string name, int x, int y, int width, int height, color bgColor)
{
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_COLOR, ButtonBorder);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}
//+------------------------------------------------------------------+