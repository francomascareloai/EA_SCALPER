// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68723

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#define REVERSABLE_LOGIC_FEATURE extern

#define STOP_LOSS_FEATURE 
#define NET_STOP_LOSS_FEATURE extern

#define TAKE_PROFIT_FEATURE 
#define NET_TAKE_PROFIT_FEATURE extern

#define MARTINGALE_FEATURE extern

#define WEEKLY_TRADING_TIME_FEATURE extern
#define TRADING_TIME_FEATURE extern

#define POSITION_CAP_FEATURE extern

enum ExitMode
{
   ExitOnCenter, // On center
   ExitOnUpBottom // Up/bottom
};

input int Length = 20;
input int Mode = 1;    // 0 - Close
                      // 1 - High/Low
input ExitMode exit_mode = ExitOnCenter; // Exit on center

enum TradingMode
{
   TradingModeLive, // Live
   TradingModeOnBarClose // On bar close
};

input string GeneralSection = ""; // == General ==
input TradingMode trade_live = TradingModeLive; // Trade live?
enum PositionSizeType
{
   PositionSizeAmount, // $
   PositionSizeContract, // In contracts
   PositionSizeEquity, // % of equity
   PositionSizeRisk // Risk in % of equity
};
enum LogicDirection
{
   DirectLogic, // Direct
   ReversalLogic // Reversal
};
enum TradingSide
{
   LongSideOnly, // Long
   ShortSideOnly, // Short
   BothSides // Both
};
extern double lots_value = 0.1; // Position size
extern PositionSizeType lots_type = PositionSizeContract; // Position size type
extern double leverage_override = 0; // Leverage override (for bad brokers, use 0 to disable)
extern int slippage_points = 3; // Slippage, points
extern TradingSide trading_side = BothSides; // What trades should be taken
REVERSABLE_LOGIC_FEATURE LogicDirection logic_direction = DirectLogic; // Logic type
extern bool close_on_opposite = true; // Close on opposite signal

POSITION_CAP_FEATURE string CapSection = ""; // == Position cap ==
POSITION_CAP_FEATURE bool position_cap = false; // Position Cap
POSITION_CAP_FEATURE int no_of_positions = 1; // Max # of buy+sell positions
POSITION_CAP_FEATURE int no_of_buy_position = 1; // Max # of buy positions
POSITION_CAP_FEATURE int no_of_sell_position = 1; // Max # of sell positions

MARTINGALE_FEATURE string MartingaleSection = ""; // == Martingale type ==
enum MartingaleType
{
   MartingaleDoNotUse, // Do not use
   MartingaleOnLoss // Open another position on loss
};
enum MartingaleLotSizingType
{
   MartingaleLotSizingNo, // No lot sizing
   MartingaleLotSizingMultiplicator, // Using miltiplicator
   MartingaleLotSizingAdd // Addition
};
enum MartingaleStepSizeType
{
   MartingaleStepSizePips, // Pips
   MartingaleStepSizePercent, // %
};
MARTINGALE_FEATURE MartingaleType martingale_type = MartingaleDoNotUse; // Martingale type
MARTINGALE_FEATURE MartingaleLotSizingType martingale_lot_sizing_type = MartingaleLotSizingNo; // Martingale lot sizing type
MARTINGALE_FEATURE double martingale_lot_value = 1.5; // Matringale lot sizing value
MARTINGALE_FEATURE MartingaleStepSizeType martingale_step_type = MartingaleStepSizePercent; // Step unit
MARTINGALE_FEATURE double martingale_step = 5; // Open matringale position step

STOP_LOSS_FEATURE string StopLossSection            = ""; // == Stop loss ==
enum TrailingType
{
   TrailingDontUse, // No trailing
   TrailingPips, // Use trailing in pips
   TrailingPercent // Use trailing in % of stop
};
enum StopLimitType
{
   StopLimitDoNotUse, // Do not use
   StopLimitPercent, // Set in %
   StopLimitPips, // Set in Pips
   StopLimitDollar, // Set in $,
   StopLimitRiskReward, // Set in % of stop loss
   StopLimitAbsolute // Set in absolite value (rate)
};
STOP_LOSS_FEATURE StopLimitType stop_loss_type = StopLimitDoNotUse; // Stop loss type
STOP_LOSS_FEATURE double stop_loss_value            = 10; // Stop loss value
STOP_LOSS_FEATURE TrailingType trailing_type = TrailingDontUse; // Trailing type
STOP_LOSS_FEATURE double trailing_step = 10; // Trailing step
STOP_LOSS_FEATURE double trailing_start = 0; // Min distance to order to activate the trailing
STOP_LOSS_FEATURE StopLimitType breakeven_type = StopLimitDoNotUse; // Trigger type for the breakeven
STOP_LOSS_FEATURE double breakeven_value = 10; // Trigger for the breakeven
STOP_LOSS_FEATURE double breakeven_level = 0; // Breakeven target
NET_STOP_LOSS_FEATURE StopLimitType net_stop_loss_type = StopLimitDoNotUse; // Net stop loss type
NET_STOP_LOSS_FEATURE double net_stop_loss_value = 10; // Net stop loss value

TAKE_PROFIT_FEATURE string TakeProfitSection            = ""; // == Take Profit ==
TAKE_PROFIT_FEATURE StopLimitType take_profit_type = StopLimitDoNotUse; // Take profit type
TAKE_PROFIT_FEATURE double take_profit_value           = 10; // Take profit value
NET_TAKE_PROFIT_FEATURE StopLimitType net_take_profit_type = StopLimitDoNotUse; // Net take profit type
NET_TAKE_PROFIT_FEATURE double net_take_profit_value = 10; // Net take profit value

enum DayOfWeek
{
   DayOfWeekSunday = 0, // Sunday
   DayOfWeekMonday = 1, // Monday
   DayOfWeekTuesday = 2, // Tuesday
   DayOfWeekWednesday = 3, // Wednesday
   DayOfWeekThursday = 4, // Thursday
   DayOfWeekFriday = 5, // Friday
   DayOfWeekSaturday = 6 // Saturday
};

TRADING_TIME_FEATURE string OtherSection            = ""; // == Other ==
TRADING_TIME_FEATURE int magic_number        = 42; // Magic number
TRADING_TIME_FEATURE string start_time = "000000"; // Start time in hhmmss format
TRADING_TIME_FEATURE string stop_time = "000000"; // Stop time in hhmmss format
WEEKLY_TRADING_TIME_FEATURE bool use_weekly_timing = false; // Weekly time
WEEKLY_TRADING_TIME_FEATURE DayOfWeek week_start_day = DayOfWeekSunday; // Start day
WEEKLY_TRADING_TIME_FEATURE string week_start_time = "000000"; // Start time in hhmmss format
WEEKLY_TRADING_TIME_FEATURE DayOfWeek week_stop_day = DayOfWeekSaturday; // Stop day
WEEKLY_TRADING_TIME_FEATURE string week_stop_time = "235959"; // Stop time in hhmmss format
WEEKLY_TRADING_TIME_FEATURE bool mandatory_closing = false; // Mandatory closing for non-trading time

bool ecn_broker = false;

//Signaler v 1.7
// More templates and snippets on https://github.com/sibvic/mq4-templates
extern string   AlertsSection            = ""; // == Alerts ==
extern bool     popup_alert              = true; // Popup message
extern bool     notification_alert       = false; // Push notification
extern bool     email_alert              = false; // Email
extern bool     play_sound               = false; // Play sound on alert
extern string   sound_file               = ""; // Sound file
extern bool     start_program            = false; // Start external program
extern string   program_path             = ""; // Path to the external program executable
extern bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
extern string   advanced_key             = ""; // Advanced alert key
extern string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
extern string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
extern string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastDatetime;
   string _prefix;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   string GetSymbol()
   {
      return _symbol;
   }

   ENUM_TIMEFRAMES GetTimeframe()
   {
      return _timeframe;
   }

   string GetTimeframeStr()
   {
      switch (_timeframe)
      {
         case PERIOD_M1: return "M1";
         case PERIOD_M5: return "M5";
         case PERIOD_D1: return "D1";
         case PERIOD_H1: return "H1";
         case PERIOD_H4: return "H4";
         case PERIOD_M15: return "M15";
         case PERIOD_M30: return "M30";
         case PERIOD_MN1: return "MN1";
         case PERIOD_W1: return "W1";
      }
      return "M1";
   }

   void SendNotifications(const string subject, string message = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframeStr();

      if (start_program)
         ShellExecuteW(0, "open", program_path, "", "", 1);
      if (popup_alert)
         Alert(message);
      if (email_alert)
         SendMail(subject, message);
      if (play_sound)
         PlaySound(sound_file);
      if (notification_alert)
         SendNotification(message);
      if (advanced_alert && advanced_key != "" && !IsTesting())
         AdvancedAlert(advanced_key, message, symbol, timeframe);
   }
};

// Instrument info v.1.4
// More templates and snippets on https://github.com/sibvic/mq4-templates

class InstrumentInfo
{
   string _symbol;
   double _mult;
   double _point;
   double _pipSize;
   int _digits;
   double _tickSize;
public:
   InstrumentInfo(const string symbol)
   {
      _symbol = symbol;
      _point = MarketInfo(symbol, MODE_POINT);
      _digits = (int)MarketInfo(symbol, MODE_DIGITS); 
      _mult = _digits == 3 || _digits == 5 ? 10 : 1;
      _pipSize = _point * _mult;
      _tickSize = MarketInfo(_symbol, MODE_TICKSIZE);
   }
   
   static double GetBid(const string symbol) { return MarketInfo(symbol, MODE_BID); }
   double GetBid() { return GetBid(_symbol); }
   static double GetAsk(const string symbol) { return MarketInfo(symbol, MODE_ASK); }
   double GetAsk() { return GetAsk(_symbol); }
   static double GetPipSize(const string symbol)
   { 
      double point = MarketInfo(symbol, MODE_POINT);
      double digits = (int)MarketInfo(symbol, MODE_DIGITS); 
      double mult = digits == 3 || digits == 5 ? 10 : 1;
      return point * mult;
   }
   double GetPipSize() { return _pipSize; }
   double GetPointSize() { return _point; }
   string GetSymbol() { return _symbol; }
   double GetSpread() { return (GetAsk() - GetBid()) / GetPipSize(); }
   int GetDigits() { return _digits; }
   double GetTickSize() { return _tickSize; }
   double GetMinLots() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); };

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathFloor(rate / _tickSize + 0.5) * _tickSize, _digits);
   }
};

// ICondition v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface ICondition
{
public:
   virtual bool IsPass(const int period) = 0;
};

// ABaseCondition v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

class ABaseCondition : public ICondition
{
protected:
   ENUM_TIMEFRAMES _timeframe;
   InstrumentInfo *_instrument;
   string _symbol;
public:
   ABaseCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _instrument = new InstrumentInfo(symbol);
      _timeframe = timeframe;
      _symbol = symbol;
   }
   ~ABaseCondition()
   {
      delete _instrument;
   }
};

// Condition v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IConditionFactory
{
public:
   virtual ICondition *CreateCondition(const int order) = 0;
};

class CrossOverTopCondition : public ABaseCondition
{
public:
   CrossOverTopCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period)
   {
      double value0 = iCustom(_symbol, _timeframe, "Dochian_Channel", Length, Mode, 4, period);
      double value1 = iCustom(_symbol, _timeframe, "Dochian_Channel", Length, Mode, 4, period + 1);
      double close0 = iClose(_symbol, _timeframe, period);
      double close1 = iClose(_symbol, _timeframe, period + 1);
      return value0 >= close0 && value1 <= close1;
   }
};

class CrossUnderBottomCondition : public ABaseCondition
{
public:
   CrossUnderBottomCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period)
   {
      double value0 = iCustom(_symbol, _timeframe, "Dochian_Channel", Length, Mode, 0, period);
      double value1 = iCustom(_symbol, _timeframe, "Dochian_Channel", Length, Mode, 0, period + 1);
      double close0 = iClose(_symbol, _timeframe, period);
      double close1 = iClose(_symbol, _timeframe, period + 1);
      return value0 <= close0 && value1 >= close1;
   }
};

class CrossOverCenterCondition : public ABaseCondition
{
public:
   CrossOverCenterCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period)
   {
      double value0 = iCustom(_symbol, _timeframe, "Dochian_Channel", Length, Mode, 2, period);
      double value1 = iCustom(_symbol, _timeframe, "Dochian_Channel", Length, Mode, 2, period + 1);
      double close0 = iClose(_symbol, _timeframe, period);
      double close1 = iClose(_symbol, _timeframe, period + 1);
      return value0 >= close0 && value1 <= close1;
   }
};

class CrossUnderCenterCondition : public ABaseCondition
{
public:
   CrossUnderCenterCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period)
   {
      double value0 = iCustom(_symbol, _timeframe, "Dochian_Channel", Length, Mode, 2, period);
      double value1 = iCustom(_symbol, _timeframe, "Dochian_Channel", Length, Mode, 2, period + 1);
      double close0 = iClose(_symbol, _timeframe, period);
      double close1 = iClose(_symbol, _timeframe, period + 1);
      return value0 <= close0 && value1 >= close1;
   }
};

class DisabledCondition : public ICondition
{
public:
   bool IsPass(const int period) { return false; }
};

class OrCondition : public ICondition
{
   ICondition *_conditions[];
public:
   ~OrCondition()
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         delete _conditions[i];
      }
   }

   void Add(ICondition *condition)
   {
      int size = ArraySize(_conditions);
      ArrayResize(_conditions, size + 1);
      _conditions[size] = condition;
   }

   virtual bool IsPass(const int period)
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         if (_conditions[i].IsPass(period))
            return true;
      }
      return false;
   }
};

enum OrderSide
{
   BuySide,
   SellSide
};

// Orders iterator v 1.9
// More templates and snippets on https://github.com/sibvic/mq4-templates
enum CompareType
{
   CompareLessThan
};

class OrdersIterator
{
   bool _useMagicNumber;
   int _magicNumber;
   bool _useOrderType;
   int _orderType;
   bool _trades;
   bool _useSide;
   bool _isBuySide;
   int _lastIndex;
   bool _useSymbol;
   string _symbol;
   bool _useProfit;
   double _profit;
   bool _useComment;
   string _comment;
   CompareType _profitCompare;
   bool _orders;
public:
   OrdersIterator()
   {
      _useOrderType = false;
      _useMagicNumber = false;
      _useSide = false;
      _lastIndex = INT_MIN;
      _trades = false;
      _useSymbol = false;
      _useProfit = false;
      _orders = false;
      _useComment = false;
   }

   OrdersIterator *WhenSymbol(const string symbol)
   {
      _useSymbol = true;
      _symbol = symbol;
      return &this;
   }

   OrdersIterator *WhenProfit(const double profit, const CompareType compare)
   {
      _useProfit = true;
      _profit = profit;
      _profitCompare = compare;
      return &this;
   }

   OrdersIterator *WhenTrade()
   {
      _trades = true;
      return &this;
   }

   OrdersIterator *WhenOrder()
   {
      _orders = true;
      return &this;
   }

   OrdersIterator *WhenSide(const OrderSide side)
   {
      _useSide = true;
      _isBuySide = side == BuySide;
      return &this;
   }

   OrdersIterator *WhenOrderType(const int orderType)
   {
      _useOrderType = true;
      _orderType = orderType;
      return &this;
   }

   OrdersIterator *WhenMagicNumber(const int magicNumber)
   {
      _useMagicNumber = true;
      _magicNumber = magicNumber;
      return &this;
   }

   OrdersIterator *WhenComment(const string comment)
   {
      _useComment = true;
      _comment = comment;
      return &this;
   }

   int GetOrderType() { return OrderType(); }
   double GetProfit() { return OrderProfit(); }
   double IsBuy() { return OrderType() == OP_BUY; }
   double IsSell() { return OrderType() == OP_SELL; }
   int GetTicket() { return OrderTicket(); }

   int Count()
   {
      int count = 0;
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && PassFilter())
            count++;
      }
      return count;
   }

   bool Next()
   {
      if (_lastIndex == INT_MIN)
         _lastIndex = OrdersTotal() - 1;
      else
         _lastIndex = _lastIndex - 1;
      while (_lastIndex >= 0)
      {
         if (OrderSelect(_lastIndex, SELECT_BY_POS, MODE_TRADES) && PassFilter())
            return true;
         _lastIndex = _lastIndex - 1;
      }
      return false;
   }

   bool Any()
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && PassFilter())
            return true;
      }
      return false;
   }

   int First()
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && PassFilter())
            return OrderTicket();
      }
      return -1;
   }

   void Reset()
   {
      _lastIndex = INT_MIN;
   }

private:
   bool PassFilter()
   {
      if (_useMagicNumber && OrderMagicNumber() != _magicNumber)
         return false;
      if (_useOrderType && OrderType() != _orderType)
         return false;
      if (_trades && !IsTrade())
         return false;
      if (_orders && IsTrade())
         return false;
      if (_useSymbol && OrderSymbol() != _symbol)
         return false;
      if (_useProfit)
      {
         switch (_profitCompare)
         {
            case CompareLessThan:
               if (OrderProfit() >= _profit)
                  return false;
               break;
         }
      }
      if (_useSide)
      {
         if (_trades)
         {
            if (_isBuySide && !IsBuy())
               return false;
            if (!_isBuySide && !IsSell())
               return false;
         }
         else
         {
            //TODO: IMPLEMENT!!!!
         }
      }
      if (_useComment && OrderComment() != _comment)
         return false;
      return true;
   }

   bool IsTrade()
   {
      return (OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderCloseTime() == 0.0;
   }
};

// Trade calculator v.1.16
// More templates and snippets on https://github.com/sibvic/mq4-templates

class TradingCalculator
{
   InstrumentInfo *_symbol;

   TradingCalculator(const string symbol)
   {
      _symbol = new InstrumentInfo(symbol);
   }
public:
   static TradingCalculator *Create(const string symbol)
   {
      ResetLastError();
      double temp = MarketInfo(symbol, MODE_POINT); 
      if (GetLastError() != 0)
         return NULL;

      return new TradingCalculator(symbol);
   }

   ~TradingCalculator()
   {
      delete _symbol;
   }

   double GetPipSize() { return _symbol.GetPipSize(); }
   string GetSymbol() { return _symbol.GetSymbol(); }
   double GetBid() { return _symbol.GetBid(); }
   double GetAsk() { return _symbol.GetAsk(); }
   int GetDigits() { return _symbol.GetDigits(); }
   double GetSpread() { return _symbol.GetSpread(); }

   static bool IsBuyOrder()
   {
      switch (OrderType())
      {
         case OP_BUY:
         case OP_BUYLIMIT:
         case OP_BUYSTOP:
            return true;
      }
      return false;
   }

   double GetBreakevenPrice(OrdersIterator &it1, const OrderSide side, double &totalAmount)
   {
      totalAmount = 0.0;
      double lotStep = SymbolInfoDouble(_symbol.GetSymbol(), SYMBOL_VOLUME_STEP);
      double price = side == BuySide ? _symbol.GetBid() : _symbol.GetAsk();
      double totalPL = 0;
      while (it1.Next())
      {
         double orderLots = OrderLots();
         totalAmount += orderLots / lotStep;
         if (side == BuySide)
            totalPL += (price - OrderOpenPrice()) * (OrderLots() / lotStep);
         else
            totalPL += (OrderOpenPrice() - price) * (OrderLots() / lotStep);
      }
      if (totalAmount == 0.0)
         return 0.0;
      double shift = -(totalPL / totalAmount);
      return side == BuySide ? price + shift : price - shift;
   }

   double GetBreakevenPrice(const int side, const int magicNumber, double &totalAmount)
   {
      totalAmount = 0.0;
      OrdersIterator it1();
      it1.WhenMagicNumber(magicNumber);
      it1.WhenSymbol(_symbol.GetSymbol());
      it1.WhenOrderType(side);
      return GetBreakevenPrice(it1, side == OP_BUY ? BuySide : SellSide, totalAmount);
   }
   
   double CalculateTakeProfit(const bool isBuy, const double takeProfit, const StopLimitType takeProfitType, const double amount, double basePrice)
   {
      int direction = isBuy ? 1 : -1;
      switch (takeProfitType)
      {
         case StopLimitPercent:
            return RoundRate(basePrice + basePrice * takeProfit / 100.0 * direction);
         case StopLimitPips:
            return RoundRate(basePrice + takeProfit * _symbol.GetPipSize() * direction);
         case StopLimitDollar:
            return RoundRate(basePrice + CalculateSLShift(amount, takeProfit) * direction);
         case StopLimitAbsolute:
            return takeProfit;
      }
      return 0.0;
   }
   
   double CalculateStopLoss(const bool isBuy, const double stopLoss, const StopLimitType stopLossType, const double amount, double basePrice)
   {
      int direction = isBuy ? 1 : -1;
      switch (stopLossType)
      {
         case StopLimitPercent:
            return RoundRate(basePrice - basePrice * stopLoss / 100.0 * direction);
         case StopLimitPips:
            return RoundRate(basePrice - stopLoss * _symbol.GetPipSize() * direction);
         case StopLimitDollar:
            return RoundRate(basePrice - CalculateSLShift(amount, stopLoss) * direction);
         case StopLimitAbsolute:
            return stopLoss;
      }
      return 0.0;
   }

   double GetLots(const PositionSizeType lotsType, const double lotsValue, const double stopDistance, const double leverageOverride = 0)
   {
      switch (lotsType)
      {
         case PositionSizeAmount:
            return GetLotsForMoney(lotsValue, leverageOverride);
         case PositionSizeContract:
            return LimitLots(RoundLots(lotsValue));
         case PositionSizeEquity:
            return GetLotsForMoney(AccountEquity() * lotsValue / 100.0, leverageOverride);
         case PositionSizeRisk:
         {
            double affordableLoss = AccountEquity() * lotsValue / 100.0;
            double unitCost = MarketInfo(_symbol.GetSymbol(), MODE_TICKVALUE);
            double tickSize = _symbol.GetTickSize();
            double possibleLoss = unitCost * stopDistance / tickSize;
            if (possibleLoss <= 0.01)
               return 0;
            return LimitLots(RoundLots(affordableLoss / possibleLoss));
         }
      }
      return lotsValue;
   }

   bool IsLotsValid(const double lots, PositionSizeType lotsType, string &error)
   {
      switch (lotsType)
      {
         case PositionSizeContract:
            return IsContractLotsValid(lots, error);
      }
      return true;
   }

   double NormalizeLots(const double lots)
   {
      return LimitLots(RoundLots(lots));
   }

   double RoundRate(const double rate)
   {
      return _symbol.RoundRate(rate);
   }

private:
   bool IsContractLotsValid(const double lots, string &error)
   {
      double minVolume = _symbol.GetMinLots();
      if (minVolume > lots)
      {
         error = "Min. allowed lot size is " + DoubleToString(minVolume);
         return false;
      }
      double maxVolume = SymbolInfoDouble(_symbol.GetSymbol(), SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
      {
         error = "Max. allowed lot size is " + DoubleToString(maxVolume);
         return false;
      }
      return true;
   }

   double GetLotsForMoney(const double money, const double leverageOverride = 0)
   {
      if (leverageOverride != 0)
      {
         double lotSize = MarketInfo(_symbol.GetSymbol(), MODE_LOTSIZE);
         double lots = RoundLots(money * leverageOverride / lotSize);
         return LimitLots(lots);
      }
      double marginRequired = MarketInfo(_symbol.GetSymbol(), MODE_MARGINREQUIRED);
      if (marginRequired <= 0.0)
      {
         Print("Margin is 0. Server misconfiguration?");
         return 0.0;
      }
      double lots = RoundLots(money / marginRequired);
      return LimitLots(lots);
   }

   double RoundLots(const double lots)
   {
      double lotStep = SymbolInfoDouble(_symbol.GetSymbol(), SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
         return 0.0;
      return floor(lots / lotStep) * lotStep;
   }

   double LimitLots(const double lots)
   {
      double minVolume = _symbol.GetMinLots();
      if (minVolume > lots)
         return 0.0;
      double maxVolume = SymbolInfoDouble(_symbol.GetSymbol(), SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
         return maxVolume;
      return lots;
   }

   double CalculateSLShift(const double amount, const double money)
   {
      double unitCost = MarketInfo(_symbol.GetSymbol(), MODE_TICKVALUE);
      double tickSize = _symbol.GetTickSize();
      return (money / (unitCost / tickSize)) / amount;
   }
};

// Order v1.0

interface IOrder
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool Select() = 0;
};

class OrderByMagicNumber : public IOrder
{
   int _magicMumber;
   int _references;
public:
   OrderByMagicNumber(int magicNumber)
   {
      _magicMumber = magicNumber;
      _references = 1;
   }

   void AddRef()
   {
      ++_references;
   }

   void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }

   virtual bool Select()
   {
      OrdersIterator it();
      it.WhenMagicNumber(_magicMumber);
      int ticketId = it.First();
      return OrderSelect(ticketId, SELECT_BY_TICKET, MODE_TRADES);
   }
};

class OrderByTicketId : public IOrder
{
   int _ticket;
   int _references;
public:
   OrderByTicketId(int ticket)
   {
      _ticket = ticket;
      _references = 1;
   }

   void AddRef()
   {
      ++_references;
   }

   void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }

   virtual bool Select()
   {
      return OrderSelect(_ticket, SELECT_BY_TICKET, MODE_TRADES);
   }
};

// Action v1.0
interface IAction
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool DoAction() = 0;
};

// AAction v1.0

#ifndef AAction_IMP

class AAction : public IAction
{
protected:
   int _references;
   AAction()
   {
      _references = 1;
   }
public:
   void AddRef()
   {
      ++_references;
   }

   void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }
};

#define AAction_IMP

#endif

class MoveToBreakevenAction : public AAction
{
   Signaler* _signaler;
   double _trigger;
   double _target;
   InstrumentInfo *_instrument;
   IOrder* _order;
   string _name;
public:
   MoveToBreakevenAction(double trigger, double target, string name, IOrder* order, Signaler *signaler)
   {
      _signaler = signaler;
      _trigger = trigger;
      _target = target;
      _name = name;

      _order = order;
      _order.AddRef();
      _order.Select();
      string symbol = OrderSymbol();
      if (_instrument == NULL || symbol != _instrument.GetSymbol())
      {
         delete _instrument;
         _instrument = new InstrumentInfo(symbol);
      }
   }

   ~MoveToBreakevenAction()
   {
      delete _instrument;
      _order.Release();
   }

   virtual bool DoAction()
   {
      if (!_order.Select())
         return false;
      int ticket = OrderTicket();
      string error;
      if (!TradingCommands::MoveSL(ticket, _target, error))
      {
         Print(error);
         return false;
      }
      if (_signaler != NULL)
      {
         _signaler.SendNotifications(GetNamePrefix() + "Trade " + IntegerToString(ticket) + " has reached " 
            + DoubleToString(_trigger, _instrument.GetDigits()) + ". Stop loss moved to " 
            + DoubleToString(_target, _instrument.GetDigits()));
      }
      return true;
   }
private:
   string GetNamePrefix()
   {
      if (_name == "")
         return "";
      return _name + ". ";
   }
};

class ActionOnConditionController
{
   bool _finished;
   ICondition *_condition;
   IAction* _action;
public:
   ActionOnConditionController()
   {
      _action = NULL;
      _condition = NULL;
      _finished = true;
   }

   ~ActionOnConditionController()
   {
      delete _action;
      delete _condition;
   }
   
   bool SetOrder(IAction* action, ICondition *condition)
   {
      if (!_finished || action == NULL)
         return false;

      if (_action != NULL)
         _action.Release();
      _action = action;
      _action.AddRef();
      _finished = false;
      delete _condition;
      _condition = condition;
      return true;
   }

   void DoLogic(const int period)
   {
      if (_finished)
         return;

      if ( _condition.IsPass(period))
      {
         if (_action.DoAction())
            _finished = true;
      }
   }
};

class ActionOnConditionLogic
{
   ActionOnConditionController* _controllers[];
public:
   ~ActionOnConditionLogic()
   {
      int count = ArraySize(_controllers);
      for (int i = 0; i < count; ++i)
      {
         delete _controllers[i];
      }
   }

   void DoLogic(const int period)
   {
      int count = ArraySize(_controllers);
      for (int i = 0; i < count; ++i)
      {
         _controllers[i].DoLogic(period);
      }
   }

   bool AddActionOnCondition(IAction* action, ICondition* condition)
   {
      int count = ArraySize(_controllers);
      for (int i = 0; i < count; ++i)
      {
         if (_controllers[i].SetOrder(action, condition))
            return true;
      }

      ArrayResize(_controllers, count + 1);
      _controllers[count] = new ActionOnConditionController();
      return _controllers[count].SetOrder(action, condition);
   }
};

class HitProfitCondition : public ICondition
{
   IOrder* _order;
   double _trigger;
   InstrumentInfo *_instrument;
public:
   HitProfitCondition()
   {
      _order = NULL;
      _instrument = NULL;
   }

   ~HitProfitCondition()
   {
      delete _instrument;
      if (_order != NULL)
         _order.Release();
   }

   void Set(IOrder* order, double trigger)
   {
      if (!order.Select())
         return;

      _order = order;
      _order.AddRef();
      _trigger = trigger;
      string symbol = OrderSymbol();
      if (_instrument == NULL || symbol != _instrument.GetSymbol())
      {
         delete _instrument;
         _instrument = new InstrumentInfo(symbol);
      }
   }

   virtual bool IsPass(const int period)
   {
      if (_order == NULL || !_order.Select())
         return false;

      int type = OrderType();
      if (type == OP_BUY)
         return _instrument.GetAsk() >= _trigger;
      else if (type == OP_SELL)
         return _instrument.GetBid() <= _trigger;
      return false;
   }
};

// Breakeven logic v. 2.0
interface IBreakevenLogic
{
public:
   virtual void CreateBreakeven(const int order, const int period) = 0;
};

class DisabledBreakevenLogic : public IBreakevenLogic
{
public:
   void CreateBreakeven(const int order, const int period) {}
};

class BreakevenLogic : public IBreakevenLogic
{
   StopLimitType _triggerType;
   double _trigger;
   double _target;
   TradingCalculator *_calculator;
   Signaler *_signaler;
   ActionOnConditionLogic* _actions;
public:
   BreakevenLogic(const StopLimitType triggerType, const double trigger,
      const double target, Signaler *signaler, ActionOnConditionLogic* actions)
   {
      Init();
      _signaler = signaler;
      _triggerType = triggerType;
      _trigger = trigger;
      _target = target;
      _actions = actions;
   }

   BreakevenLogic()
   {
      Init();
   }

   ~BreakevenLogic()
   {
      delete _calculator;
   }

   void CreateBreakeven(const int order, const int period, const StopLimitType triggerType, 
      const double trigger, const double target)
   {
      if (triggerType == StopLimitDoNotUse)
         return;
      
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
         return;

      string symbol = OrderSymbol();
      if (_calculator == NULL || symbol != _calculator.GetSymbol())
      {
         delete _calculator;
         _calculator = TradingCalculator::Create(symbol);
         if (_calculator == NULL)
            return;
      }
      int isBuy = TradingCalculator::IsBuyOrder();
      double basePrice = OrderOpenPrice();
      double targetValue = _calculator.CalculateTakeProfit(isBuy, target, StopLimitPips, OrderLots(), basePrice);
      double triggerValue = _calculator.CalculateTakeProfit(isBuy, trigger, triggerType, OrderLots(), basePrice);
      CreateBreakeven(order, triggerValue, targetValue, "");
   }

   void CreateBreakeven(const int orderId, const int period)
   {
      CreateBreakeven(orderId, period, _triggerType, _trigger, _target);
   }
private:
   void Init()
   {
      _calculator = NULL;
      _signaler = NULL;
      _triggerType = StopLimitDoNotUse;
      _trigger = 0;
      _target = 0;
   }

   void CreateBreakeven(const int ticketId, const double trigger, const double target, const string name)
   {
      if (!OrderSelect(ticketId, SELECT_BY_TICKET, MODE_TRADES))
         return;
      IOrder *order = new OrderByMagicNumber(OrderMagicNumber());
      HitProfitCondition* condition = new HitProfitCondition();
      condition.Set(order, trigger);
      IAction* action = new MoveToBreakevenAction(trigger, target, name, order, _signaler);
      if (!_actions.AddActionOnCondition(action, condition))
      {
         delete action;
         delete condition;
      }
   }
};

class NetBreakevenController
{
   int _order;
   bool _finished;
   double _trigger;
   double _target;
   StopLimitType _triggerType;
   Signaler *_signaler;
   TradingCalculator *_calculator;
public:
   NetBreakevenController(TradingCalculator *calculator, Signaler *signaler)
   {
      _calculator = calculator;
      _signaler = signaler;
      _finished = true;
   }

   ~NetBreakevenController()
   {
   }
   
   bool SetOrder(const int order, const double trigger, const StopLimitType triggerType, const double target)
   {
      if (!_finished)
      {
         return false;
      }
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES))
         return false;

      string symbol = OrderSymbol();
      if (symbol != _calculator.GetSymbol())
         return false;
      _finished = false;
      _trigger = trigger;
      _target = target;
      _order = order;
      _triggerType = triggerType;
      return true;
   }

   void DoLogic(const int period)
   {
      if (_finished || !OrderSelect(_order, SELECT_BY_TICKET, MODE_TRADES))
      {
         _finished = true;
         return;
      }

      int type = OrderType();
      double totalAmount;
      int magicNumber = OrderMagicNumber();
      double orderLots = OrderLots();
      int ticket = OrderTicket();
      double orderOpenPrice = OrderOpenPrice();
      double orderTakeProfit = OrderTakeProfit();
      double averagePrice = _calculator.GetBreakevenPrice(type, magicNumber, totalAmount);
      double trigger = _calculator.CalculateTakeProfit(type == OP_BUY, _trigger, _triggerType, orderLots, averagePrice);
      if (type == OP_BUY)
      {
         if (_calculator.GetAsk() >= trigger)
         {
            double target = averagePrice + _target * _calculator.GetPipSize();
            _signaler.SendNotifications("Trade " + IntegerToString(ticket) + " has reached " 
               + DoubleToString(_trigger, 1) + ". Stop loss moved to " 
               + DoubleToString(target, _calculator.GetDigits()));
            int res = OrderModify(ticket, orderOpenPrice, target, orderTakeProfit, 0, CLR_NONE);
            _finished = true;
         }
      } 
      else if (type == OP_SELL)
      {
         if (_calculator.GetBid() < trigger) 
         {
            double target = averagePrice - _target * _calculator.GetPipSize();
            _signaler.SendNotifications("Trade " + IntegerToString(ticket) + " has reached " 
               + DoubleToString(_trigger, 1) + ". Stop loss moved to " 
               + DoubleToString(target, _calculator.GetDigits()));
            int res = OrderModify(ticket, orderOpenPrice, target, orderTakeProfit, 0, CLR_NONE);
            _finished = true;
         }
      } 
   }
};

class NetBreakevenLogic : public IBreakevenLogic
{
   NetBreakevenController *_breakeven[];
   StopLimitType _triggerType;
   double _trigger;
   double _target;
   TradingCalculator *_calculator;
   Signaler *_signaler;
public:
   NetBreakevenLogic(TradingCalculator *calculator, const StopLimitType triggerType, const double trigger,
      const double target, Signaler *signaler)
   {
      _signaler = signaler;
      _calculator = calculator;
      _triggerType = triggerType;
      _trigger = trigger;
      _target = target;
   }

   ~NetBreakevenLogic()
   {
      int i_count = ArraySize(_breakeven);
      for (int i = 0; i < i_count; ++i)
      {
         delete _breakeven[i];
      }
   }

   void DoLogic(const int period)
   {
      int i_count = ArraySize(_breakeven);
      for (int i = 0; i < i_count; ++i)
      {
         _breakeven[i].DoLogic(period);
      }
   }

   void CreateBreakeven(const int order, const int period)
   {
      if (_triggerType == StopLimitDoNotUse)
         return;
      
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
         return;

      string symbol = OrderSymbol();
      if (symbol != _calculator.GetSymbol())
      {
         Print("Error in breakeven logic usage");
         return;
      }
      int i_count = ArraySize(_breakeven);
      for (int i = 0; i < i_count; ++i)
      {
         if (_breakeven[i].SetOrder(order, _trigger, _triggerType, _target))
         {
            return;
         }
      }

      ArrayResize(_breakeven, i_count + 1);
      _breakeven[i_count] = new NetBreakevenController(_calculator, _signaler);
      _breakeven[i_count].SetOrder(order, _trigger, _triggerType, _target);
   }
};

// Trailing controller v.2.6
interface ITrailingLogic
{
public:
   virtual void DoLogic() = 0;
   virtual void Create(const int order, const double stop) = 0;
};

class DisabledTrailingLogic : public ITrailingLogic
{
public:
   void DoLogic() {};
   void Create(const int order, const double stop) {};
};

enum TrailingControllerType
{
   TrailingControllerTypeStandard
   ,TrailingControllerTypeStream
};

interface ITrailingController
{
public:
   virtual bool IsFinished() = 0;
   virtual void UpdateStop() = 0;
   virtual TrailingControllerType GetType() = 0;
};

class TrailingController : public ITrailingController
{
   Signaler *_signaler;
   int _order;
   bool _finished;
   double _distance;
   double _trailingStep;
   double _trailingStart;
   InstrumentInfo *_instrument;
public:
   TrailingController(Signaler *signaler = NULL)
   {
      _finished = true;
      _order = -1;
      _signaler = signaler;
      _instrument = NULL;
   }

   ~TrailingController()
   {
      delete _instrument;
   }
   
   bool IsFinished()
   {
      return _finished;
   }

   bool SetOrder(const int order, const double distance, const double trailingStep, const double trailingStart = 0)
   {
      if (!_finished)
      {
         return false;
      }
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
      {
         return false;
      }
      string symbol = OrderSymbol();
      if (_instrument == NULL || _instrument.GetSymbol() != symbol)
      {
         delete _instrument;
         _instrument = new InstrumentInfo(symbol);
      }
      _trailingStep = _instrument.RoundRate(trailingStep);
      if (_trailingStep == 0)
         return false;

      _trailingStart = trailingStart;

      _finished = false;
      _order = order;
      _distance = distance;
      
      return true;
   }

   void UpdateStop()
   {
      if (_finished || !OrderSelect(_order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
      {
         _finished = true;
         return;
      }
      int type = OrderType();
      if (type == OP_BUY)
      {
         UpdateStopForLong();
      } 
      else if (type == OP_SELL) 
      {
         UpdateStopForShort();
      } 
   }

   TrailingControllerType GetType()
   {
      return TrailingControllerTypeStandard;
   }
private:
   void UpdateStopForLong()
   {
      double initialStop = OrderStopLoss();
      if (initialStop == 0.0)
         return;
      double ask = _instrument.GetAsk();
      double openPrice = OrderOpenPrice();
      if (openPrice > ask + _trailingStart * _instrument.GetPipSize())
         return;
      double newStop = initialStop;
      int digits = _instrument.GetDigits();
      while (NormalizeDouble(newStop + _trailingStep, digits) < NormalizeDouble(ask - _distance, digits))
      {
         newStop = NormalizeDouble(newStop + _trailingStep, digits);
      }
      if (newStop == initialStop) 
         return;
      if (_signaler != NULL)
      {
         string message = "Trailing stop for " + IntegerToString(_order) + " to " + DoubleToString(newStop, digits);
         _signaler.SendNotifications(message);
      }
      int res = OrderModify(OrderTicket(), openPrice, newStop, OrderTakeProfit(), 0, CLR_NONE);
      if (res == 0)
      {
         int error = GetLastError();
         switch (error)
         {
            case ERR_INVALID_TICKET:
               _finished = true;
               break;
         }
      }
   }

   void UpdateStopForShort()
   {
      double initialStop = OrderStopLoss();
      if (initialStop == 0.0)
         return;
      double bid = _instrument.GetBid();
      double openPrice = OrderOpenPrice();
      if (openPrice < bid - _trailingStart * _instrument.GetPipSize())
         return;
      double newStop = initialStop;
      int digits = _instrument.GetDigits();
      while (NormalizeDouble(newStop - _trailingStep, digits) > NormalizeDouble(bid + _distance, digits))
      {
         newStop = NormalizeDouble(newStop - _trailingStep, digits);
      }
      if (newStop == initialStop) 
         return;
         
      if (_signaler != NULL)
      {
         string message = "Trailing stop for " + IntegerToString(_order) + " to " + DoubleToString(newStop, digits);
         _signaler.SendNotifications(message);
      }
      int res = OrderModify(OrderTicket(), openPrice, newStop, OrderTakeProfit(), 0, CLR_NONE);
      if (res == 0)
      {
         int error = GetLastError();
         switch (error)
         {
            case ERR_INVALID_TICKET:
               _finished = true;
               break;
         }
      }
   }
};

class TrailingLogic : public ITrailingLogic
{
   ITrailingController *_trailing[];
   TrailingType _trailingType;
   double _trailingStep;
   double _atrTrailingMultiplier;
   double _trailingStart;
   ENUM_TIMEFRAMES _timeframe;
   InstrumentInfo *_instrument;
   Signaler *_signaler;
public:
   TrailingLogic(TrailingType trailing, double trailingStep, double atrTrailingMultiplier
      , double trailingStart, ENUM_TIMEFRAMES timeframe, Signaler *signaler)
   {
      _signaler = signaler;
      _instrument = NULL;
      _trailingStart = trailingStart;
      _trailingType = trailing;
      _trailingStep = trailingStep;
      _atrTrailingMultiplier = atrTrailingMultiplier;
      _timeframe = timeframe;
   }

   ~TrailingLogic()
   {
      delete _instrument;
      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         delete _trailing[i];
      }
   }

   void DoLogic()
   {
      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         _trailing[i].UpdateStop();
      }
   }

   void Create(const int order, const double distancePips, const TrailingType trailingType, const double trailingStep
      , const double trailingStart)
   {
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
         return;

      string symbol = OrderSymbol();
      if (_instrument == NULL || symbol != _instrument.GetSymbol())
      {
         delete _instrument;
         _instrument = new InstrumentInfo(symbol);
      }
      double distance = distancePips * _instrument.GetPipSize();
      switch (trailingType)
      {
         case TrailingPips:
            CreateTrailing(order, distance, trailingStep * _instrument.GetPipSize(), trailingStart);
            break;
         case TrailingPercent:
            CreateTrailing(order, distance, distance * trailingStep / 100.0, trailingStart);
            break;
      }
   }

   void Create(const int order, const double distancePips)
   {
      Create(order, distancePips, _trailingType, _trailingStep, _trailingStart);
   }
private:
   void CreateTrailing(const int order, const double distance, const double trailingStep, const double trailingStart)
   {
      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         if (_trailing[i].GetType() != TrailingControllerTypeStandard)
            continue;
         TrailingController *trailingController = (TrailingController *)_trailing[i];
         if (trailingController.SetOrder(order, distance, trailingStep, trailingStart))
         {
            return;
         }
      }

      TrailingController *trailingController = new TrailingController(_signaler);
      trailingController.SetOrder(order, distance, trailingStep, trailingStart);
      
      ArrayResize(_trailing, i_count + 1);
      _trailing[i_count] = trailingController;
   }
};

// Move net stop loss action v 1.0

#ifndef MoveNetStopLossAction_IMP

class MoveNetStopLossAction : public AAction
{
   TradingCalculator *_calculator;
   int _magicNumber;
   double _stopLoss;
   StopLimitType _type;
   Signaler *_signaler;
public:
   MoveNetStopLossAction(TradingCalculator *calculator, StopLimitType type, const double stopLoss, Signaler *signaler, const int magicNumber)
   {
      _type = type;
      _calculator = calculator;
      _stopLoss = stopLoss;
      _signaler = signaler;
      _magicNumber = magicNumber;
   }

   virtual bool DoAction()
   {
      MoveStopLoss(OP_BUY);
      MoveStopLoss(OP_SELL);
      return true;
   }
private:
   void MoveStopLoss(const int side)
   {
      OrdersIterator it();
      it.WhenMagicNumber(_magicNumber);
      it.WhenOrderType(side);
      it.WhenTrade();
      if (it.Count() <= 1)
         return;
      double totalAmount;
      double averagePrice = _calculator.GetBreakevenPrice(side, _magicNumber, totalAmount);
      if (averagePrice == 0.0)
         return;
         
      double stopLoss = _calculator.CalculateStopLoss(side == OP_BUY, _stopLoss, _type, totalAmount, averagePrice);
      
      OrdersIterator it1();
      it1.WhenMagicNumber(_magicNumber);
      it1.WhenSymbol(_calculator.GetSymbol());
      it1.WhenOrderType(side);
      it1.WhenTrade();
      int count = 0;
      while (it1.Next())
      {
         if (OrderStopLoss() != stopLoss)
         {
            int res = OrderModify(OrderTicket(), OrderOpenPrice(), stopLoss, OrderTakeProfit(), 0, CLR_NONE);
            if (res == 0)
            {
               int error = GetLastError();
               switch (error)
               {
                  case ERR_NO_RESULT:
                     break;
                  case ERR_INVALID_TICKET:
                     break;
               }
            }
            else
               ++count;
         }
      }
      if (_signaler != NULL && count > 0)
         _signaler.SendNotifications("Moving net stop loss to " + DoubleToStr(stopLoss));
   }
};

#define MoveNetStopLossAction_IMP

#endif
// Move net take profit action v 1.0

#ifndef MoveNetTakeProfitAction_IMP

class MoveNetTakeProfitAction : public AAction
{
   TradingCalculator *_calculator;
   int _magicNumber;
   double _takeProfit;
   StopLimitType _type;
   Signaler *_signaler;
public:
   MoveNetTakeProfitAction(TradingCalculator *calculator, StopLimitType type, const double takeProfit, Signaler *signaler, const int magicNumber)
   {
      _type = type;
      _calculator = calculator;
      _takeProfit = takeProfit;
      _signaler = signaler;
      _magicNumber = magicNumber;
   }

   virtual bool DoAction()
   {
      MoveTakeProfit(OP_BUY);
      MoveTakeProfit(OP_SELL);
      return true;
   }
private:
   void MoveTakeProfit(const int side)
   {
      OrdersIterator it();
      it.WhenMagicNumber(_magicNumber);
      it.WhenOrderType(side);
      it.WhenTrade();
      if (it.Count() <= 1)
         return;
      double totalAmount;
      double averagePrice = _calculator.GetBreakevenPrice(side, _magicNumber, totalAmount);
      if (averagePrice == 0.0)
         return;
         
      double takeProfit = _calculator.CalculateTakeProfit(side == OP_BUY, _takeProfit, _type, totalAmount, averagePrice);
      
      OrdersIterator it1();
      it1.WhenMagicNumber(_magicNumber);
      it1.WhenSymbol(_calculator.GetSymbol());
      it1.WhenOrderType(side);
      it1.WhenTrade();
      int count = 0;
      while (it1.Next())
      {
         if (OrderTakeProfit() != takeProfit)
         {
            int res = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), takeProfit, 0, CLR_NONE);
            if (res == 0)
            {
               int error = GetLastError();
               switch (error)
               {
                  case ERR_NO_RESULT:
                     break;
                  case ERR_INVALID_TICKET:
                     break;
               }
            }
            else
               ++count;
         }
      }
      if (_signaler != NULL && count > 0)
         _signaler.SendNotifications("Moving net take profit to " + DoubleToStr(takeProfit));
   }
};

#define MoveNetTakeProfitAction_IMP

#endif

// Trading time v.1.5

class TradingTime
{
   int _startTime;
   int _endTime;
   bool _useWeekTime;
   int _weekStartTime;
   int _weekStartDay;
   int _weekStopTime;
   int _weekStopDay;
public:
   TradingTime()
   {
      _startTime = 0;
      _endTime = 0;
      _useWeekTime = false;
   }

   bool SetWeekTradingTime(const DayOfWeek startDay, const string startTime, const DayOfWeek stopDay, 
      const string stopTime, string &error)
   {
      _useWeekTime = true;
      _weekStartTime = ParseTime(startTime, error);
      if (_weekStartTime == -1)
         return false;
      _weekStopTime = ParseTime(stopTime, error);
      if (_weekStopTime == -1)
         return false;
      
      _weekStartDay = (int)startDay;
      _weekStopDay = (int)stopDay;
      return true;
   }

   bool Init(const string startTime, const string endTime, string &error)
   {
      _startTime = ParseTime(startTime, error);
      if (_startTime == -1)
         return false;
      _endTime = ParseTime(endTime, error);
      if (_endTime == -1)
         return false;

      return true;
   }

   bool IsTradingTime(datetime dt)
   {
      if (_startTime == _endTime && !_useWeekTime)
         return true;
      MqlDateTime current_time;
      if (!TimeToStruct(dt, current_time))
         return false;
      if (!IsIntradayTradingTime(current_time))
         return false;
      return IsWeeklyTradingTime(current_time);
   }

   void GetStartEndTime(const datetime date, datetime &start, datetime &end)
   {
      MqlDateTime current_time;
      if (!TimeToStruct(date, current_time))
         return;

      current_time.hour = 0;
      current_time.min = 0;
      current_time.sec = 0;
      datetime referece = StructToTime(current_time);

      start = referece + _startTime;
      end = referece + _endTime;
      if (_startTime > _endTime)
      {
         start -= 86400;
      }
   }
private:
   bool IsIntradayTradingTime(const MqlDateTime &current_time)
   {
      if (_startTime == _endTime)
         return true;
      int current_t = TimeToInt(current_time);
      if (_startTime > _endTime)
         return current_t >= _startTime || current_t <= _endTime;
      return current_t >= _startTime && current_t <= _endTime;
   }

   int TimeToInt(const MqlDateTime &current_time)
   {
      return (current_time.hour * 60 + current_time.min) * 60 + current_time.sec;
   }

   bool IsWeeklyTradingTime(const MqlDateTime &current_time)
   {
      if (!_useWeekTime)
         return true;
      if (current_time.day_of_week < _weekStartDay || current_time.day_of_week > _weekStopDay)
         return false;

      if (current_time.day_of_week == _weekStartDay)
      {
         int current_t = TimeToInt(current_time);
         return current_t >= _weekStartTime;
      }
      if (current_time.day_of_week == _weekStopDay)
      {
         int current_t = TimeToInt(current_time);
         return current_t < _weekStopTime;
      }

      return true;
   }

   int ParseTime(const string time, string &error)
   {
      int hours;
      int minutes;
      int seconds;
      if (StringFind(time, ":") == -1)
      {
         //hh:mm:ss
         int time_parsed = (int)StringToInteger(time);
         seconds = time_parsed % 100;
         time_parsed /= 100;
         minutes = time_parsed % 100;
         time_parsed /= 100;
         hours = time_parsed % 100;
      }
      else
      {
         //hhmmss
         int time_parsed = (int)StringToInteger(time);
         hours = time_parsed % 100;
         
         time_parsed /= 100;
         minutes = time_parsed % 100;
         time_parsed /= 100;
         seconds = time_parsed % 100;
      }
      if (hours > 24)
      {
         error = "Incorrect number of hours in " + time;
         return -1;
      }
      if (minutes > 59)
      {
         error = "Incorrect number of minutes in " + time;
         return -1;
      }
      if (seconds > 59)
      {
         error = "Incorrect number of seconds in " + time;
         return -1;
      }
      if (hours == 24 && (minutes != 0 || seconds != 0))
      {
         error = "Incorrect date";
         return -1;
      }
      return (hours * 60 + minutes) * 60 + seconds;
   }
};

// Money management strategy v.2.0
interface IMoneyManagementStrategy
{
public:
   virtual void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit) = 0;
};

class AMoneyManagementStrategy : public IMoneyManagementStrategy
{
protected:
   TradingCalculator *_calculator;
   PositionSizeType _lotsType;
   double _lots;
   StopLimitType _stopLossType;
   double _stopLoss;
   StopLimitType _takeProfitType;
   double _takeProfit;
   double _leverageOverride;

   AMoneyManagementStrategy(TradingCalculator *calculator, PositionSizeType lotsType, double lots
      , StopLimitType stopLossType, double stopLoss, StopLimitType takeProfitType, double takeProfit
      , const double leverageOverride)
   {
      _calculator = calculator;
      _lotsType = lotsType;
      _lots = lots;
      _stopLossType = stopLossType;
      _stopLoss = stopLoss;
      _takeProfitType = takeProfitType;
      _takeProfit = takeProfit;
      _leverageOverride = leverageOverride;
   }
};

class LongMoneyManagementStrategy : public AMoneyManagementStrategy
{
public:
   LongMoneyManagementStrategy(TradingCalculator *calculator, PositionSizeType lotsType, double lots
      , StopLimitType stopLossType, double stopLoss, StopLimitType takeProfitType, double takeProfit
      , const double leverageOverride = 0)
      : AMoneyManagementStrategy(calculator, lotsType, lots, stopLossType, stopLoss, takeProfitType, takeProfit, leverageOverride)
   {
   }

   void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit)
   {
      if (_lotsType == PositionSizeRisk)
      {
         stopLoss = _calculator.CalculateStopLoss(true, _stopLoss, _stopLossType, 0.0, entryPrice);
         amount = _calculator.GetLots(_lotsType, _lots, entryPrice - stopLoss, _leverageOverride);
      }
      else
      {
         amount = _calculator.GetLots(_lotsType, _lots, 0.0, _leverageOverride);
         stopLoss = _calculator.CalculateStopLoss(true, _stopLoss, _stopLossType, amount, entryPrice);
      }
      if (_takeProfitType == StopLimitRiskReward)
         takeProfit = entryPrice + (entryPrice - stopLoss) * _takeProfit / 100;
      else
         takeProfit = _calculator.CalculateTakeProfit(true, _takeProfit, _takeProfitType, amount, entryPrice);
   }
};

class ShortMoneyManagementStrategy : public AMoneyManagementStrategy
{
public:
   ShortMoneyManagementStrategy(TradingCalculator *calculator, PositionSizeType lotsType, double lots
      , StopLimitType stopLossType, double stopLoss, StopLimitType takeProfitType, double takeProfit
      , const double leverageOverride = 0)
      : AMoneyManagementStrategy(calculator, lotsType, lots, stopLossType, stopLoss, takeProfitType, takeProfit, leverageOverride)
   {
   }

   void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit)
   {
      if (_lotsType == PositionSizeRisk)
      {
         stopLoss = _calculator.CalculateStopLoss(false, _stopLoss, _stopLossType, 0.0, entryPrice);
         amount = _calculator.GetLots(_lotsType, _lots, stopLoss - entryPrice, _leverageOverride);
      }
      else
      {
         amount = _calculator.GetLots(_lotsType, _lots, 0.0, _leverageOverride);
         stopLoss = _calculator.CalculateStopLoss(false, _stopLoss, _stopLossType, amount, entryPrice);
      }
      if (_takeProfitType == StopLimitRiskReward)
         takeProfit = entryPrice - (entryPrice - stopLoss) * _takeProfit / 100;
      else
         takeProfit = _calculator.CalculateTakeProfit(false, _takeProfit, _takeProfitType, amount, entryPrice);
   }
};

// Martingale strategy v.1.5

interface IMartingaleStrategy
{
public:
   virtual void OnOrder(const int order) = 0;
   virtual bool NeedAnotherPosition(OrderSide &side) = 0;
   virtual IMoneyManagementStrategy *GetMoneyManagement() = 0;
};

class NoMartingaleStrategy : public IMartingaleStrategy
{
public:
   void OnOrder(const int order) { }
   bool NeedAnotherPosition(OrderSide &side) { return false; }
   IMoneyManagementStrategy *GetMoneyManagement() { return NULL; }
};

class ACustomAmountMoneyManagementStrategy : public IMoneyManagementStrategy
{
protected:
   TradingCalculator *_calculator;
   double _amount;
public:
   ACustomAmountMoneyManagementStrategy(TradingCalculator *calculator)
   {
      _calculator = calculator;
      _amount = 0.0;
   }

   void SetAmount(const double amount)
   {
      _amount = amount;
   }
};

class CustomAmountLongMoneyManagementStrategy : public ACustomAmountMoneyManagementStrategy
{
public:
   CustomAmountLongMoneyManagementStrategy(TradingCalculator *calculator)
      :ACustomAmountMoneyManagementStrategy(calculator)
   {
   }

   void Get(const int period, const double rate, double &amount, double &stopLoss, double &takeProfit)
   {
      double ask = rate;
      amount = _amount;
      stopLoss = _calculator.CalculateStopLoss(true, stop_loss_value, stop_loss_type, amount, ask);
      takeProfit = _calculator.CalculateTakeProfit(true, take_profit_value, take_profit_type, amount, ask);
   }
};

class CustomAmountShortMoneyManagementStrategy : public ACustomAmountMoneyManagementStrategy
{
public:
   CustomAmountShortMoneyManagementStrategy(TradingCalculator *calculator)
      :ACustomAmountMoneyManagementStrategy(calculator)
   {
   }

   void Get(const int period, const double rate, double &amount, double &stopLoss, double &takeProfit)
   {
      double bid = rate;
      amount = _amount;
      stopLoss = _calculator.CalculateStopLoss(false, stop_loss_value, stop_loss_type, amount, bid);
      takeProfit = _calculator.CalculateTakeProfit(false, take_profit_value, take_profit_type, amount, bid);
   }
};

class ActiveMartingaleStrategy : public IMartingaleStrategy
{
   int _order;
   TradingCalculator *_calculator;
   CustomAmountLongMoneyManagementStrategy *_longMoneyManagement;
   CustomAmountShortMoneyManagementStrategy *_shortMoneyManagement;
   double _lotValue;
   double _step;
   MartingaleStepSizeType _stepUnit;
   MartingaleLotSizingType _martingaleLotSizingType;
public:
   ActiveMartingaleStrategy(TradingCalculator *calculator, MartingaleLotSizingType martingaleLotSizingType, MartingaleStepSizeType stepUnit, const double step, const double lotValue)
   {
      _martingaleLotSizingType = martingaleLotSizingType;
      _step = step;
      _stepUnit = stepUnit;
      _lotValue = lotValue;
      _order = -1;
      _calculator = calculator;
      _longMoneyManagement = new CustomAmountLongMoneyManagementStrategy(_calculator);
      _shortMoneyManagement = new CustomAmountShortMoneyManagementStrategy(_calculator);
   }

   ~ActiveMartingaleStrategy()
   {
      delete _longMoneyManagement;
      delete _shortMoneyManagement;
   }

   void OnOrder(const int order)
   {
      _order = order;
   }

   IMoneyManagementStrategy *GetMoneyManagement()
   {
      if (_order == -1)
         return NULL;
      if (!OrderSelect(_order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
         return NULL;

      double lots = OrderLots();
      switch (_martingaleLotSizingType)
      {
         case MartingaleLotSizingNo:
            break;
         case MartingaleLotSizingMultiplicator:
            lots = _calculator.NormalizeLots(lots * _lotValue);
            break;
         case MartingaleLotSizingAdd:
            lots = _calculator.NormalizeLots(lots + _lotValue);
            break;
      }
      if (OrderType() == OP_BUY)
      {
         _longMoneyManagement.SetAmount(lots);
         return _longMoneyManagement;
      }
      _shortMoneyManagement.SetAmount(lots);
      return _shortMoneyManagement;
   }

   bool NeedAnotherPosition(OrderSide &side)
   {
      if (_order == -1)
         return false;
      if (!OrderSelect(_order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
      {
         _order = -1;
         return false;
      }
      if (OrderType() == OP_BUY)
      {
         if (NeedAnotherBuy())
         {
            side = BuySide;
            return true;
         }
      }
      else
      {
         if (NeedAnotherSell())
         {
            side = SellSide;
            return true;
         }         
      }
      return false;
   }

   bool NeedAnotherSell()
   {
      switch (_stepUnit)
      {
         case MartingaleStepSizePips:
            return (_calculator.GetBid() - OrderOpenPrice()) / _calculator.GetPipSize() > _step;
         case MartingaleStepSizePercent:
            {
               double openPrice = OrderOpenPrice();
               return (_calculator.GetBid() - openPrice) / openPrice > _step / 100.0;
            }
      }
      return false;
   }

   bool NeedAnotherBuy()
   {
      switch (_stepUnit)
      {
         case MartingaleStepSizePips:
            return (OrderOpenPrice() - _calculator.GetAsk()) / _calculator.GetPipSize() > _step;
         case MartingaleStepSizePercent:
            {
               double openPrice = OrderOpenPrice();
               return (openPrice - _calculator.GetAsk()) / openPrice > _step / 100.0;
            }
      }
      return false;
   }
};

// Trading commands v.2.8
// More templates and snippets on https://github.com/sibvic/mq4-templates

class TradingCommands
{
public:
   static bool MoveSLTP(const int ticketId, const double newStopLoss, const double newTakeProfit, string &error)
   {
      if (!OrderSelect(ticketId, SELECT_BY_TICKET, MODE_TRADES))
      {
         error = "Trade not found";
         return false;
      }

      int res = OrderModify(ticketId, OrderOpenPrice(), newStopLoss, newTakeProfit, 0, CLR_NONE);
      if (res == 0)
      {
         int errorCode = GetLastError();
         switch (errorCode)
         {
            case ERR_INVALID_TICKET:
               error = "Trade not found";
               return false;
            default:
               error = "Last error: " + IntegerToString(errorCode);
               break;
         }
      }
      return true;
   }

   static bool MoveSL(const int ticketId, const double newStopLoss, string &error)
   {
      if (!OrderSelect(ticketId, SELECT_BY_TICKET, MODE_TRADES))
      {
         error = "Trade not found";
         return false;
      }

      int res = OrderModify(ticketId, OrderOpenPrice(), newStopLoss, OrderTakeProfit(), 0, CLR_NONE);
      if (res == 0)
      {
         int errorCode = GetLastError();
         switch (errorCode)
         {
            case ERR_INVALID_TICKET:
               error = "Trade not found";
               return false;
            default:
               error = "Last error: " + IntegerToString(errorCode);
               break;
         }
      }
      return true;
   }

   static void DeleteOrders(const int magicNumber)
   {
      OrdersIterator it1();
      it1.WhenMagicNumber(magicNumber);
      it1.WhenOrder();
      while (it1.Next())
      {
         int ticket = OrderTicket();
         if (!OrderDelete(ticket))
            Print("Failed to delete the order " + IntegerToString(ticket));
      }
   }

   static bool DeleteCurrentOrder(string &error)
   {
      int ticket = OrderTicket();
      if (!OrderDelete(ticket))
      {
         error = "Failed to delete the order " + IntegerToString(ticket);
         return false;
      }
      return true;
   }

   static bool CloseCurrentOrder(const int slippage, const double amount, string &error)
   {
      int orderType = OrderType();
      if (orderType == OP_BUY)
         return CloseCurrentOrder(InstrumentInfo::GetBid(OrderSymbol()), slippage, amount, error);
      if (orderType == OP_SELL)
         return CloseCurrentOrder(InstrumentInfo::GetAsk(OrderSymbol()), slippage, amount, error);
      return false;
   }
   
   static bool CloseCurrentOrder(const int slippage, string &error)
   {
      return CloseCurrentOrder(slippage, OrderLots(), error);
   }

   static bool CloseCurrentOrder(const double price, const int slippage, string &error)
   {
      return CloseCurrentOrder(price, slippage, OrderLots(), error);
   }
   
   static bool CloseCurrentOrder(const double price, const int slippage, const double amount, string &error)
   {
      bool closed = OrderClose(OrderTicket(), amount, price, slippage);
      if (closed)
         return true;
      int lastError = GetLastError();
      switch (lastError)
      {
         case ERR_TRADE_NOT_ALLOWED:
            error = "Trading is not allowed";
            break;
         case ERR_INVALID_PRICE:
            error = "Invalid closing price: " + DoubleToStr(price);
            break;
         case ERR_INVALID_TRADE_VOLUME:
            error = "Invalid trade volume: " + DoubleToStr(amount);
            break;
         case ERR_TRADE_PROHIBITED_BY_FIFO:
            error = "Prohibited by FIFO";
            break;
         default:
            error = "Last error: " + IntegerToString(lastError);
            break;
      }
      return false;
   }

   static int CloseTrades(OrdersIterator &it, const int slippage)
   {
      int failed = 0;
      return CloseTrades(it, slippage, failed);
   }

   static int CloseTrades(OrdersIterator &it, const int slippage, int& failed)
   {
      int closedPositions = 0;
      failed = 0;
      while (it.Next())
      {
         string error;
         if (!CloseCurrentOrder(slippage, error))
         {
            ++failed;
            Print("Failed to close positoin. ", error);
         }
         else
            ++closedPositions;
      }
      return closedPositions;
   }
};

// Close on opposite v.1.1
interface ICloseOnOppositeStrategy
{
public:
   virtual void DoClose(const OrderSide side) = 0;
};

class DontCloseOnOppositeStrategy : public ICloseOnOppositeStrategy
{
public:
   void DoClose(const OrderSide side)
   {
      // do nothing
   }
};

class DoCloseOnOppositeStrategy : public ICloseOnOppositeStrategy
{
   int _magicNumber;
   int _slippage;
public:
   DoCloseOnOppositeStrategy(const int slippage, const int magicNumber)
   {
      _magicNumber = magicNumber;
      _slippage = slippage;
   }

   void DoClose(const OrderSide side)
   {
      OrdersIterator toClose();
      toClose.WhenSide(side).WhenMagicNumber(_magicNumber).WhenTrade();
      TradingCommands::CloseTrades(toClose, _slippage);
   }
};

// Position cap v.1.1
interface IPositionCapStrategy
{
public:
   virtual bool IsLimitHit() = 0;
};

class PositionCapStrategy : public IPositionCapStrategy
{
   int _magicNumber;
   int _maxSidePositions;
   int _totalPositions;
   string _symbol;
   OrderSide _side;
public:
   PositionCapStrategy(const OrderSide side, const int magicNumber, const int maxSidePositions, const int totalPositions,
      const string symbol = "")
   {
      _symbol = symbol;
      _side = side;
      _magicNumber = magicNumber;
      _maxSidePositions = maxSidePositions;
      _totalPositions = totalPositions;
   }

   bool IsLimitHit()
   {
      OrdersIterator sideSpecificIterator();
      sideSpecificIterator.WhenMagicNumber(_magicNumber).WhenTrade().WhenSide(_side);
      if (_symbol != "")
         sideSpecificIterator.WhenSymbol(_symbol);
      int side_positions = sideSpecificIterator.Count();
      if (side_positions >= _maxSidePositions)
         return true;

      OrdersIterator it();
      it.WhenMagicNumber(_magicNumber).WhenTrade();
      if (_symbol != "")
         it.WhenSymbol(_symbol);
      int positions = it.Count();
      return positions >= _totalPositions;
   }
};

class NoPositionCapStrategy : public IPositionCapStrategy
{
public:
   bool IsLimitHit()
   {
      return false;
   }
};

// Order builder v.1.3
class OrderBuilder
{
   OrderSide _orderSide;
   string _instrument;
   double _amount;
   double _rate;
   int _slippage;
   double _stop;
   double _limit;
   int _magicNumber;
   string _comment;
public:
   OrderBuilder *SetSide(const OrderSide orderSide)
   {
      _orderSide = orderSide;
      return &this;
   }
   
   OrderBuilder *SetInstrument(const string instrument)
   {
      _instrument = instrument;
      return &this;
   }
   
   OrderBuilder *SetAmount(const double amount)
   {
      _amount = amount;
      return &this;
   }
   
   OrderBuilder *SetRate(const double rate)
   {
      _rate = rate;
      return &this;
   }
   
   OrderBuilder *SetSlippage(const int slippage)
   {
      _slippage = slippage;
      return &this;
   }
   
   OrderBuilder *SetStopLoss(const double stop)
   {
      _stop = stop;
      return &this;
   }
   
   OrderBuilder *SetTakeProfit(const double limit)
   {
      _limit = limit;
      return &this;
   }
   
   OrderBuilder *SetMagicNumber(const int magicNumber)
   {
      _magicNumber = magicNumber;
      return &this;
   }

   OrderBuilder *SetComment(const string comment)
   {
      _comment = comment;
      return &this;
   }
   
   int Execute(string &errorMessage)
   {
      InstrumentInfo instrument(_instrument);
      double rate = instrument.RoundRate(_rate);
      double sl = instrument.RoundRate(_stop);
      double tp = instrument.RoundRate(_limit);
      int orderType;
      if (_orderSide == BuySide)
         orderType = rate > instrument.GetAsk() ? OP_BUYSTOP : OP_BUYLIMIT;
      else
         orderType = rate < instrument.GetBid() ? OP_SELLSTOP : OP_SELLLIMIT;
      bool ecnBroker = false;
      int order;
      if (ecn_broker)
         order = OrderSend(_instrument, orderType, _amount, rate, _slippage, 0, 0, _comment, _magicNumber);
      else
         order = OrderSend(_instrument, orderType, _amount, rate, _slippage, sl, tp, _comment, _magicNumber);
      if (order == -1)
      {
         int error = GetLastError();
         switch (error)
         {
            case ERR_OFF_QUOTES:
               errorMessage = "No quotes";
               return -1;
            case ERR_TRADE_NOT_ALLOWED:
               errorMessage = "Trading is not allowed";
               break;
            case ERR_INVALID_STOPS:
               {
                  double point = SymbolInfoDouble(_instrument, SYMBOL_POINT);
                  int minStopDistancePoints = (int)MarketInfo(_instrument, MODE_STOPLEVEL);
                  if (sl != 0.0 && MathRound(MathAbs(_rate - sl) / point) < minStopDistancePoints)
                     errorMessage = "Your stop loss level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
                  else if (tp != 0.0 && MathRound(MathAbs(_rate - tp) / point) < minStopDistancePoints)
                     errorMessage = "Your take profit level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
                  else
                  {
                     double rateDistance = _orderSide == BuySide
                        ? MathAbs(rate - instrument.GetAsk()) / instrument.GetPointSize()
                        : MathAbs(rate < instrument.GetBid()) / instrument.GetPointSize();
                     if (rateDistance < minStopDistancePoints)
                        errorMessage = "Distance to the pending order rate is too close: " + DoubleToStr(rateDistance, 1)
                           + ". Min. allowed distance: " + IntegerToString(minStopDistancePoints);
                     else
                        errorMessage = "Invalid take profit in the request";
                  }
               }
               break;
            default:
               errorMessage = "Failed to create order: " + IntegerToString(error);
               break;
         }
      }
      else if (ecnBroker)
         TradingCommands::MoveSLTP(order, sl, tp, errorMessage);
      return order;
   }
};

// Market order builder v 1.5
// More templates and snippets on https://github.com/sibvic/mq4-templates

class MarketOrderBuilder
{
   OrderSide _orderSide;
   string _instrument;
   double _amount;
   double _rate;
   int _slippage;
   double _stop;
   double _limit;
   int _magicNumber;
   string _comment;
public:
   MarketOrderBuilder *SetSide(const OrderSide orderSide)
   {
      _orderSide = orderSide;
      return &this;
   }
   
   MarketOrderBuilder *SetInstrument(const string instrument)
   {
      _instrument = instrument;
      return &this;
   }
   
   MarketOrderBuilder *SetAmount(const double amount)
   {
      _amount = amount;
      return &this;
   }
   
   MarketOrderBuilder *SetSlippage(const int slippage)
   {
      _slippage = slippage;
      return &this;
   }
   
   MarketOrderBuilder *SetStopLoss(const double stop)
   {
      _stop = NormalizeDouble(stop, Digits);
      return &this;
   }
   
   MarketOrderBuilder *SetTakeProfit(const double limit)
   {
      _limit = NormalizeDouble(limit, Digits);
      return &this;
   }
   
   MarketOrderBuilder *SetMagicNumber(const int magicNumber)
   {
      _magicNumber = magicNumber;
      return &this;
   }

   MarketOrderBuilder *SetComment(const string comment)
   {
      _comment = comment;
      return &this;
   }
   
   int Execute(string &errorMessage)
   {
      int orderType = _orderSide == BuySide ? OP_BUY : OP_SELL;
      double minstoplevel = MarketInfo(_instrument, MODE_STOPLEVEL); 
      
      double rate = _orderSide == BuySide ? MarketInfo(_instrument, MODE_ASK) : MarketInfo(_instrument, MODE_BID);
      int order = OrderSend(_instrument, orderType, _amount, rate, _slippage, _stop, _limit, _comment, _magicNumber);
      if (order == -1)
      {
         int error = GetLastError();
         switch (error)
         {
            case ERR_NOT_ENOUGH_MONEY:
               errorMessage = "Not enought money";
               return -1;
            case ERR_INVALID_TRADE_VOLUME:
               {
                  double minVolume = SymbolInfoDouble(_instrument, SYMBOL_VOLUME_MIN);
                  if (_amount < minVolume)
                  {
                     errorMessage = "Volume of the lot is too low: " + DoubleToStr(_amount) + " Min lot is: " + DoubleToStr(minVolume);
                     return -1;
                  }
                  double maxVolume = SymbolInfoDouble(_instrument, SYMBOL_VOLUME_MAX);
                  if (_amount > maxVolume)
                  {
                     errorMessage = "Volume of the lot is too high: " + DoubleToStr(_amount) + " Max lot is: " + DoubleToStr(maxVolume);
                     return -1;
                  }
                  errorMessage = "Invalid volume: " + DoubleToStr(_amount);
               }
               return -1;
            case ERR_OFF_QUOTES:
               errorMessage = "No quotes";
               return -1;
            case ERR_TRADE_NOT_ALLOWED:
               errorMessage = "Trading is not allowed";
               return -1;
            case ERR_TRADE_HEDGE_PROHIBITED:
               errorMessage = "Trade hedge prohibited";
               return -1;
            case ERR_INVALID_STOPS:
               {
                  double point = SymbolInfoDouble(_instrument, SYMBOL_POINT);
                  int minStopDistancePoints = (int)SymbolInfoInteger(_instrument, SYMBOL_TRADE_STOPS_LEVEL);
                  if (_stop != 0.0)
                  {
                     if (MathRound(MathAbs(rate - _stop) / point) < minStopDistancePoints)
                        errorMessage = "Your stop loss level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
                     else
                        errorMessage = "Invalid stop loss in the request";
                  }
                  else if (_limit != 0.0)
                  {
                     if (MathRound(MathAbs(rate - _limit) / point) < minStopDistancePoints)
                        errorMessage = "Your take profit level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
                     else
                        errorMessage = "Invalid take profit in the request";
                  }
                  else
                     errorMessage = "Invalid take profit in the request";
               }
               return -1;
            case ERR_INVALID_PRICE:
               errorMessage = "Invalid price";
               return -1;
            default:
               errorMessage = "Failed to create order: " + IntegerToString(error);
               return -1;
         }
      }
      return order;
   }
};

// Entry strategy v.1.2
interface IEntryStrategy
{
public:
   virtual int OpenPosition(const int period, OrderSide side, IMoneyManagementStrategy *moneyManagement, const string comment, double &stopLoss) = 0;

   virtual int Exit(const OrderSide side) = 0;
};

class MarketEntryStrategy : public IEntryStrategy
{
   string _symbol;
   int _magicMumber;
   int _slippagePoints;
public:
   MarketEntryStrategy(const string symbol, const int magicMumber, const int slippagePoints)
   {
      _magicMumber = magicMumber;
      _slippagePoints = slippagePoints;
      _symbol = symbol;
   }

   int OpenPosition(const int period, OrderSide side, IMoneyManagementStrategy *moneyManagement, const string comment, double &stopLoss)
   {
      double entryPrice = side == BuySide ? InstrumentInfo::GetAsk(_symbol) : InstrumentInfo::GetBid(_symbol);
      double amount;
      double takeProfit;
      moneyManagement.Get(period, entryPrice, amount, stopLoss, takeProfit);
      if (amount == 0.0)
         return -1;
      string error;
      MarketOrderBuilder *orderBuilder = new MarketOrderBuilder();
      int order = orderBuilder
         .SetSide(side)
         .SetInstrument(_symbol)
         .SetAmount(amount)
         .SetSlippage(_slippagePoints)
         .SetMagicNumber(_magicMumber)
         .SetStopLoss(stopLoss)
         .SetTakeProfit(takeProfit)
         .SetComment(comment)
         .Execute(error);
      delete orderBuilder;
      if (order == -1)
      {
         Print("Failed to open position: " + error);
      }
      return order;
   }

   int Exit(const OrderSide side)
   {
      OrdersIterator toClose();
      toClose.WhenSide(side).WhenMagicNumber(_magicMumber).WhenTrade();
      return TradingCommands::CloseTrades(toClose, _slippagePoints);
   }
};

// Mandatory closing v.2.0
interface IMandatoryClosingLogic
{
public:
   virtual void DoLogic() = 0;
};

class NoMandatoryClosing : public IMandatoryClosingLogic
{
public:
   void DoLogic()
   {

   }
};

class DoMandatoryClosing : public IMandatoryClosingLogic
{
   int _magicNumber;
   int _slippagePoints;
   Signaler *_signaler;
public:
   DoMandatoryClosing(const int magicNumber, int slippagePoints)
   {
      _slippagePoints = slippagePoints;
      _magicNumber = magicNumber;
      _signaler = NULL;
   }

   void SetSignaler(Signaler *signaler)
   {
      _signaler = signaler;
   }

   void DoLogic()
   {
      OrdersIterator toClose();
      toClose.WhenMagicNumber(_magicNumber).WhenTrade();
      int positionsClosed = TradingCommands::CloseTrades(toClose, _slippagePoints);
      TradingCommands::DeleteOrders(_magicNumber);
      if (positionsClosed > 0 && _signaler != NULL)
         _signaler.SendNotifications("Mandatory closing");
   }
};

// Trading controller v4.0
class TradingController
{
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastbartime;
   double _lastLot;
   IBreakevenLogic *_breakeven;
   ActionOnConditionLogic* actions;
   ITrailingLogic *_trailing;
   Signaler *_signaler;
   datetime _lastBarDate;
   TradingCalculator *_calculator;
   TradingTime *_tradingTime;
   ICondition *_longCondition;
   ICondition *_shortCondition;
   ICondition *_exitAllCondition;
   ICondition *_exitLongCondition;
   ICondition *_exitShortCondition;
#ifdef MARTINGALE_FEATURE
   IMartingaleStrategy *_shortMartingale;
   IMartingaleStrategy *_longMartingale;
#endif
   IMoneyManagementStrategy *_longMoneyManagement[];
   IMoneyManagementStrategy *_shortMoneyManagement[];
   ICloseOnOppositeStrategy *_closeOnOpposite;
#ifdef POSITION_CAP_FEATURE
   IPositionCapStrategy *_longPositionCap;
   IPositionCapStrategy *_shortPositionCap;
#endif
   IEntryStrategy *_entryStrategy;
   IMandatoryClosingLogic *_mandatoryClosing;
   string _algorithmId;
   ActionOnConditionLogic* _actions;
public:
   TradingController(TradingCalculator *calculator, ENUM_TIMEFRAMES timeframe, Signaler *signaler, const string algorithmId = "")
   {
      _actions = NULL;
      _algorithmId = algorithmId;
#ifdef POSITION_CAP_FEATURE
      _longPositionCap = NULL;
      _shortPositionCap = NULL;
#endif
      _closeOnOpposite = NULL;
#ifdef MARTINGALE_FEATURE
      _shortMartingale = NULL;
      _longMartingale = NULL;
#endif
      _longCondition = NULL;
      _shortCondition = NULL;
      _calculator = calculator;
      _signaler = signaler;
      _timeframe = timeframe;
      _lastLot = lots_value;
      _exitAllCondition = NULL;
      _exitLongCondition = NULL;
      _exitShortCondition = NULL;
      _tradingTime = NULL;
      _mandatoryClosing = NULL;
   }

   ~TradingController()
   {
      delete _actions;
      delete _mandatoryClosing;
      delete _entryStrategy;
#ifdef POSITION_CAP_FEATURE
      delete _longPositionCap;
      delete _shortPositionCap;
#endif
      delete _closeOnOpposite;
      for (int i = 0; i < ArraySize(_longMoneyManagement); ++i)
      {
         delete _longMoneyManagement[i];
      }
      for (int i = 0; i < ArraySize(_shortMoneyManagement); ++i)
      {
         delete _shortMoneyManagement[i];
      }
#ifdef MARTINGALE_FEATURE
      delete _shortMartingale;
      delete _longMartingale;
#endif
      delete _exitAllCondition;
      delete _exitLongCondition;
      delete _exitShortCondition;
      delete _calculator;
      delete _signaler;
      delete _breakeven;
      delete _trailing;
      delete _longCondition;
      delete _shortCondition;
      delete _tradingTime;
   }

   void SetActions(ActionOnConditionLogic* __actions) { _actions = __actions; }
   void SetTradingTime(TradingTime *tradingTime) { _tradingTime = tradingTime; }
   void SetBreakeven(IBreakevenLogic *breakeven) { _breakeven = breakeven; }
   void SetTrailing(ITrailingLogic *trailing) { _trailing = trailing; }
   void SetLongCondition(ICondition *condition) { _longCondition = condition; }
   void SetShortCondition(ICondition *condition) { _shortCondition = condition; }
   void SetExitAllCondition(ICondition *condition) { _exitAllCondition = condition; }
   void SetExitLongCondition(ICondition *condition) { _exitLongCondition = condition; }
   void SetExitShortCondition(ICondition *condition) { _exitShortCondition = condition; }
#ifdef MARTINGALE_FEATURE
   void SetShortMartingaleStrategy(IMartingaleStrategy *martingale) { _shortMartingale = martingale; }
   void SetLongMartingaleStrategy(IMartingaleStrategy *martingale) { _longMartingale = martingale; }
#endif
   void AddLongMoneyManagement(IMoneyManagementStrategy *moneyManagement)
   {
      int count = ArraySize(_longMoneyManagement);
      ArrayResize(_longMoneyManagement, count + 1);
      _longMoneyManagement[count] = moneyManagement;
   }
   void AddShortMoneyManagement(IMoneyManagementStrategy *moneyManagement)
   {
      int count = ArraySize(_shortMoneyManagement);
      ArrayResize(_shortMoneyManagement, count + 1);
      _shortMoneyManagement[count] = moneyManagement;
   }
   void SetCloseOnOpposite(ICloseOnOppositeStrategy *closeOnOpposite) { _closeOnOpposite = closeOnOpposite; }
#ifdef POSITION_CAP_FEATURE
   void SetLongPositionCap(IPositionCapStrategy *positionCap) { _longPositionCap = positionCap; }
   void SetShortPositionCap(IPositionCapStrategy *positionCap) { _shortPositionCap = positionCap; }
#endif
   void SetEntryStrategy(IEntryStrategy *entryStrategy) { _entryStrategy = entryStrategy; }
   void SetMandatoryClosing(IMandatoryClosingLogic *mandatoryClosing) { _mandatoryClosing = mandatoryClosing; }

   void DoTrading()
   {
      int tradePeriod = trade_live == TradingModeLive ? 0 : 1;
      datetime current_time = iTime(_calculator.GetSymbol(), _timeframe, tradePeriod);
      _actions.DoLogic(tradePeriod);
      _trailing.DoLogic();
      if (trade_live == TradingModeOnBarClose)
      {
         if (_lastBarDate != current_time)
            _lastBarDate = current_time;
         else
            return;
      }
#ifdef MARTINGALE_FEATURE
      DoMartingale(_shortMartingale);
      DoMartingale(_longMartingale);
#endif

      bool exitAll = _exitAllCondition.IsPass(tradePeriod);
      if (exitAll || (_exitLongCondition.IsPass(tradePeriod) && !_exitLongCondition.IsPass(tradePeriod + 1)))
      {
         if (_entryStrategy.Exit(BuySide) > 0)
            _signaler.SendNotifications("Exit Buy");
      }
      if (exitAll || (_exitShortCondition.IsPass(tradePeriod) && !_exitShortCondition.IsPass(tradePeriod + 1)))
      {
         if (_entryStrategy.Exit(SellSide) > 0)
            _signaler.SendNotifications("Exit Sell");
      }

      if (_tradingTime != NULL && !_tradingTime.IsTradingTime(TimeCurrent()))
      {
         _mandatoryClosing.DoLogic();
         return;
      }
      if (current_time == _lastbartime)
         return;

      if (_longCondition.IsPass(tradePeriod) && !_longCondition.IsPass(tradePeriod + 1))
      {
#ifdef POSITION_CAP_FEATURE
         if (_longPositionCap.IsLimitHit())
         {
            _signaler.SendNotifications("Positions limit has been reached");
            return;
         }
#endif
         _closeOnOpposite.DoClose(SellSide);
         for (int i = 0; i < ArraySize(_longMoneyManagement); ++i)
         {
            double stopLoss = 0.0;
            int order = _entryStrategy.OpenPosition(tradePeriod, BuySide, _longMoneyManagement[i], _algorithmId, stopLoss);
            if (order >= 0)
            {
               _lastbartime = current_time;
#ifdef MARTINGALE_FEATURE
               _longMartingale.OnOrder(order);
#endif
               _breakeven.CreateBreakeven(order, tradePeriod);
               _trailing.Create(order, (_calculator.GetAsk() - stopLoss) / _calculator.GetPipSize());
            }
         }
         _signaler.SendNotifications("Buy");
      }
      if (_shortCondition.IsPass(tradePeriod) && !_shortCondition.IsPass(tradePeriod + 1))
      {
#ifdef POSITION_CAP_FEATURE
         if (_shortPositionCap.IsLimitHit())
         {
            _signaler.SendNotifications("Positions limit has been reached");
            return;
         }
#endif
         _closeOnOpposite.DoClose(BuySide);

         for (int i = 0; i < ArraySize(_shortMoneyManagement); ++i)
         {
            double stopLoss = 0.0;
            int order = _entryStrategy.OpenPosition(tradePeriod, SellSide, _shortMoneyManagement[i], _algorithmId, stopLoss);
            if (order >= 0)
            {
               _lastbartime = current_time;
#ifdef MARTINGALE_FEATURE
               _shortMartingale.OnOrder(order);
#endif
               _breakeven.CreateBreakeven(order, tradePeriod);
               _trailing.Create(order, (stopLoss - _calculator.GetBid()) / _calculator.GetPipSize());
            }
         }
         _signaler.SendNotifications("Sell");
      }
   }
private:
#ifdef MARTINGALE_FEATURE
   void DoMartingale(IMartingaleStrategy *martingale)
   {
      OrderSide anotherSide;
      if (martingale.NeedAnotherPosition(anotherSide))
      {
         double stopLoss;
         int order = _entryStrategy.OpenPosition(0, anotherSide, martingale.GetMoneyManagement(), "Martingale position", stopLoss);
         if (order >= 0)
            martingale.OnOrder(order);
         if (anotherSide == BuySide)
            _signaler.SendNotifications("Opening martingale long position");
         else
            _signaler.SendNotifications("Opening martingale short position");
      }
   }
#endif
};

// No condition v1.0

#ifndef NoCondition_IMP

class NoCondition : public ICondition
{
public:
   bool IsPass(const int period) { return true; }
};

#define NoCondition_IMP

#endif

TradingController *controllers[];

ICondition* CreateLongCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   if (trading_side == ShortSideOnly)
      return (ICondition *)new DisabledCondition();

   return (ICondition *)new CrossUnderBottomCondition(symbol, timeframe);
}

ICondition* CreateShortCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   if (trading_side == ShortSideOnly)
      return (ICondition *)new DisabledCondition();

   return (ICondition *)new CrossOverTopCondition(symbol, timeframe);
}

ICondition* CreateExitLongCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   if (exit_mode == ExitOnCenter)
      return new CrossOverCenterCondition(symbol, timeframe);
   return new CrossOverTopCondition(symbol, timeframe);
}

ICondition* CreateExitShortCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   if (exit_mode == ExitOnCenter)
      return new CrossUnderCenterCondition(symbol, timeframe);
   return new CrossUnderBottomCondition(symbol, timeframe);
}

TradingController *CreateController(const string symbol, const ENUM_TIMEFRAMES timeframe, string &error)
{
   TradingTime *tradingTime = new TradingTime();
   if (!tradingTime.Init(start_time, stop_time, error))
   {
      delete tradingTime;
      return NULL;
   }
   if (use_weekly_timing && !tradingTime.SetWeekTradingTime(week_start_day, week_start_time, week_stop_day, week_stop_time, error))
   {
      delete tradingTime;
      return NULL;
   }

   TradingCalculator *tradingCalculator = TradingCalculator::Create(symbol);
   if (!tradingCalculator.IsLotsValid(lots_value, lots_type, error))
   {
      delete tradingCalculator;
      delete tradingTime;
      return NULL;
   }
   Signaler *signaler = new Signaler(symbol, timeframe);
   signaler.SetMessagePrefix(symbol + "/" + signaler.GetTimeframeStr() + ": ");
   ActionOnConditionLogic* actions = new ActionOnConditionLogic();
   TradingController *controller = new TradingController(tradingCalculator, timeframe, signaler);
   controller.SetActions(actions);
   if (breakeven_type == StopLimitDoNotUse)
      controller.SetBreakeven(new DisabledBreakevenLogic());
   else
      controller.SetBreakeven(new BreakevenLogic(breakeven_type, breakeven_value, breakeven_level, signaler, actions));

   if (trailing_type == TrailingDontUse)
      controller.SetTrailing(new DisabledTrailingLogic());
   else
      controller.SetTrailing(new TrailingLogic(trailing_type, trailing_step, 0, trailing_start, timeframe, signaler));

   controller.SetTradingTime(tradingTime);
#ifdef MARTINGALE_FEATURE
   switch (martingale_type)
   {
      case MartingaleDoNotUse:
         controller.SetShortMartingaleStrategy(new NoMartingaleStrategy());
         controller.SetLongMartingaleStrategy(new NoMartingaleStrategy());
         break;
      case MartingaleOnLoss:
         controller.SetShortMartingaleStrategy(new ActiveMartingaleStrategy(tradingCalculator, martingale_lot_sizing_type, martingale_step_type, martingale_step, martingale_lot_value));
         controller.SetLongMartingaleStrategy(new ActiveMartingaleStrategy(tradingCalculator, martingale_lot_sizing_type, martingale_step_type, martingale_step, martingale_lot_value));
         break;
   }
#endif

   ICondition *longCondition = CreateLongCondition(symbol, timeframe);
   ICondition *shortCondition = CreateShortCondition(symbol, timeframe);
   IMoneyManagementStrategy *longMoneyManagement = new LongMoneyManagementStrategy(tradingCalculator, lots_type, lots_value, stop_loss_type, stop_loss_value, take_profit_type, take_profit_value, leverage_override);
   IMoneyManagementStrategy *shortMoneyManagement = new ShortMoneyManagementStrategy(tradingCalculator, lots_type, lots_value, stop_loss_type, stop_loss_value, take_profit_type, take_profit_value, leverage_override);
   ICondition *exitLongCondition = CreateExitLongCondition(symbol, timeframe);
   ICondition *exitShortCondition = CreateExitShortCondition(symbol, timeframe);
   switch (logic_direction)
   {
      case DirectLogic:
         controller.SetLongCondition(longCondition);
         controller.SetShortCondition(shortCondition);
         controller.SetExitLongCondition(exitLongCondition);
         controller.SetExitShortCondition(exitShortCondition);
         break;
      case ReversalLogic:
         controller.SetLongCondition(shortCondition);
         controller.SetShortCondition(longCondition);
         controller.SetExitLongCondition(exitShortCondition);
         controller.SetExitShortCondition(exitLongCondition);
         break;
   }
   controller.AddLongMoneyManagement(longMoneyManagement);
   controller.AddShortMoneyManagement(shortMoneyManagement);

   controller.SetExitAllCondition(new DisabledCondition());
   if (net_stop_loss_type != StopLimitDoNotUse)
   {
      IAction* action = new MoveNetStopLossAction(tradingCalculator, net_stop_loss_type, net_stop_loss_value, signaler, magic_number);
      actions.AddActionOnCondition(action, new NoCondition());
      action.Release();
   }
   if (net_take_profit_type != StopLimitDoNotUse)
   {
      IAction* action = new MoveNetTakeProfitAction(tradingCalculator, net_take_profit_type, net_take_profit_value, signaler, magic_number);
      actions.AddActionOnCondition(action, new NoCondition());
      action.Release();
   }

   if (close_on_opposite)
      controller.SetCloseOnOpposite(new DoCloseOnOppositeStrategy(slippage_points, magic_number));
   else
      controller.SetCloseOnOpposite(new DontCloseOnOppositeStrategy());

#ifdef POSITION_CAP_FEATURE
   if (position_cap)
   {
      controller.SetLongPositionCap(new PositionCapStrategy(BuySide, magic_number, no_of_buy_position, no_of_positions, symbol));
      controller.SetShortPositionCap(new PositionCapStrategy(SellSide, magic_number, no_of_sell_position, no_of_positions, symbol));
   }
   else
   {
      controller.SetLongPositionCap(new NoPositionCapStrategy());
      controller.SetShortPositionCap(new NoPositionCapStrategy());
   }
#endif

   controller.SetEntryStrategy(new MarketEntryStrategy(symbol, magic_number, slippage_points));
   if (mandatory_closing)
      controller.SetMandatoryClosing(new DoMandatoryClosing(magic_number, slippage_points));
   else
      controller.SetMandatoryClosing(new NoMandatoryClosing());

   return controller;
}

int OnInit()
{
   double temp = iCustom(NULL, 0, "Dochian_Channel", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'Dochian_Channel' indicator");
      return INIT_FAILED;
   }
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
#ifdef MARTINGALE_FEATURE
   if (lots_type == PositionSizeRisk && martingale_type == MartingaleOnLoss)
   {
      Print("Error: martingale_type couldn't be used with this lot type!");
      return INIT_FAILED;
   }
#endif

   string error;
   TradingController *controller = CreateController(_Symbol, (ENUM_TIMEFRAMES)_Period, error);
   if (controller == NULL)
   {
      Print(error);
      return INIT_FAILED;
   }
   int controllersCount = 0;
   ArrayResize(controllers, controllersCount + 1);
   controllers[controllersCount++] = controller;
   
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   int i_count = ArraySize(controllers);
   for (int i = 0; i < i_count; ++i)
   {
      delete controllers[i];
   }
}

void OnTick()
{
   int i_count = ArraySize(controllers);
   for (int i = 0; i < i_count; ++i)
   {
      controllers[i].DoTrading();
   }
}
