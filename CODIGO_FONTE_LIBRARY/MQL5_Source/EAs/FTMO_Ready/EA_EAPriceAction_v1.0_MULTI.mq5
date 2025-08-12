// More information about this indicator can be found at:
// // http://fxcodebase.com/code/viewtopic.php?f=38&t=70958

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
 
// Based on Ngapak Boyz, https://www.facebook.com/djong.liongfoi

input string EA_Name = "EA HOKKYDJONG";
input string Use_TradeAgain = "If => true,EA will trade again,If => false => EA will Off";
input bool TradeAgain = true;
input string Use_Loop = "Example = 10,EA will trader for 10 Laps";
input int Loop = 10000;
int trade_number;
input int StartTrade = 0;
input int EndTrade = 24;
input string Use_DbLots = "If = 1-> Use Multiplier Lot, If = 2-> Use Fixed Lot";
input int DbLots = 1;
input double Lots = 0.01;
input double SL = 0.0;
input double TP = 4.0;
input double Distance = 3.0;
input double Multiplier = 1.6;
input int MaxLevel = 20;
double Gd_176 = 3.0;
input double LotsDecimal = 2.0;
input int MagicNumber = 163991;
input string EA_Comment = "ea_hokkydjong";
double net_take_profit;
double average_open_price;
double last_buy_price;
double last_sell_price;
datetime G_time_264 = 0;
int last_trades_count = 0;
double lot_size;
int i = 0;
int trades_count;
bool open_new = false;
bool open_buy = false;
bool open_sell = false;
ulong order_ticket;
bool move_net_take_profit = false;
int Gi_324 = 65535;
int Gi_328 = 65535;
int Gi_332 = 16776960;
double Gd_336;
input double MoneyPerLot = 1.7;

string IndicatorObjPrefix;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NamesCollision(const string name)
  {
   for(int k = ObjectsTotal(0); k >= 0; k--)
     {
      if(StringFind(ObjectName(0, k), name) == 0)
        {
         return true;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GenerateIndicatorPrefix(const string target)
  {
   for(int i = 0; i < 1000; ++i)
     {
      string prefix = target + "_" + IntegerToString(i);
      if(!NamesCollision(prefix))
        {
         return prefix;
        }
     }
   return target;
  }

// Market order builder v1.6
// Order side v1.1

#ifndef OrderSide_IMP
#define OrderSide_IMP

enum OrderSide
  {
   BuySide,
   SellSide
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
OrderSide GetOppositeSide(OrderSide side)
  {
   return side == BuySide ? SellSide : BuySide;
  }

#endif
// Action on condition logic v2.0

// Action on condition v3.0

// ICondition v3.0

#ifndef ICondition_IMP
#define ICondition_IMP
interface ICondition
  {
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
   virtual string GetLogMessage(const int period, const datetime date) = 0;
  };
#endif
// Action v2.0

#ifndef IAction_IMP

interface IAction
  {
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool DoAction(const int period, const datetime date) = 0;
  };
#define IAction_IMP
#endif

#ifndef ActionOnConditionController_IMP
#define ActionOnConditionController_IMP

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ActionOnConditionController
  {
   bool              _finished;
   ICondition        *_condition;
   IAction*          _action;
public:
                     ActionOnConditionController()
     {
      _action = NULL;
      _condition = NULL;
      _finished = true;
     }

                    ~ActionOnConditionController()
     {
      if(_action != NULL)
         _action.Release();
      if(_condition != NULL)
         _condition.Release();
     }

   bool              Set(IAction* action, ICondition *condition)
     {
      if(!_finished || action == NULL)
         return false;
      if(_action != NULL)
         _action.Release();
      _action = action;
      _action.AddRef();
      _finished = false;
      if(_condition != NULL)
         _condition.Release();
      _condition = condition;
      _condition.AddRef();
      return true;
     }

   void              DoLogic(const int period, const datetime date)
     {
      if(_finished)
         return;
      if(_condition.IsPass(period, date))
        {
         if(_action.DoAction(period, date))
            _finished = true;
        }
     }
  };

#endif

#ifndef ActionOnConditionLogic_IMP
#define ActionOnConditionLogic_IMP

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ActionOnConditionLogic
  {
   ActionOnConditionController* _controllers[];
public:
                    ~ActionOnConditionLogic()
     {
      int count = ArraySize(_controllers);
      for(int i = 0; i < count; ++i)
        {
         delete _controllers[i];
        }
     }

   void              DoLogic(const int period, const datetime date)
     {
      int count = ArraySize(_controllers);
      for(int i = 0; i < count; ++i)
        {
         _controllers[i].DoLogic(period, date);
        }
     }

   bool              AddActionOnCondition(IAction* action, ICondition* condition)
     {
      int count = ArraySize(_controllers);
      for(int i = 0; i < count; ++i)
        {
         if(_controllers[i].Set(action, condition))
            return true;
        }
      ArrayResize(_controllers, count + 1);
      _controllers[count] = new ActionOnConditionController();
      return _controllers[count].Set(action, condition);
     }
  };

#endif

#ifndef MarketOrderBuilder_IMP
#define MarketOrderBuilder_IMP
class MarketOrderBuilder
  {
   OrderSide         _orderSide;
   string            _instrument;
   double            _amount;
   double            _rate;
   int               _slippage;
   double            _stop;
   double            _limit;
   int               _magicNumber;
   string            _comment;
   bool              _ecnBroker;
   ActionOnConditionLogic* _actions;
public:
                     MarketOrderBuilder(ActionOnConditionLogic* actions)
     {
      _ecnBroker = false;
      _actions = actions;
      _amount = 0;
      _rate = 0;
      _slippage = 0;
      _stop = 0;
      _limit = 0;
      _magicNumber = 0;
     }

   // Sets ECN broker flag
   MarketOrderBuilder* SetECNBroker(bool isEcn) { _ecnBroker = isEcn; return &this; }
   MarketOrderBuilder* SetComment(const string comment) { _comment = comment; return &this; }
   MarketOrderBuilder* SetSide(const OrderSide orderSide) { _orderSide = orderSide; return &this; }
   MarketOrderBuilder* SetInstrument(const string instrument) { _instrument = instrument; return &this; }
   MarketOrderBuilder* SetAmount(const double amount) { _amount = amount; return &this; }
   MarketOrderBuilder* SetSlippage(const int slippage) { _slippage = slippage; return &this; }
   MarketOrderBuilder* SetStopLoss(const double stop) { _stop = stop; return &this; }
   MarketOrderBuilder* SetTakeProfit(const double limit) { _limit = limit; return &this; }
   MarketOrderBuilder* SetMagicNumber(const int magicNumber) { _magicNumber = magicNumber; return &this; }

   ulong             Execute(string &error)
     {
      int tradeMode = (int)SymbolInfoInteger(_instrument, SYMBOL_TRADE_MODE);
      switch(tradeMode)
        {
         case SYMBOL_TRADE_MODE_DISABLED:
            error = "Trading is disbled";
            return 0;
         case SYMBOL_TRADE_MODE_CLOSEONLY:
            error = "Only close is allowed";
            return 0;
         case SYMBOL_TRADE_MODE_SHORTONLY:
            if(_orderSide == BuySide)
              {
               error = "Only short are allowed";
               return 0;
              }
            break;
         case SYMBOL_TRADE_MODE_LONGONLY:
            if(_orderSide == SellSide)
              {
               error = "Only long are allowed";
               return 0;
              }
            break;
        }
      ENUM_ORDER_TYPE orderType = _orderSide == BuySide ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
      int digits = (int)SymbolInfoInteger(_instrument, SYMBOL_DIGITS);
      double rate = _orderSide == BuySide ? SymbolInfoDouble(_instrument, SYMBOL_ASK) : SymbolInfoDouble(_instrument, SYMBOL_BID);
      double ticksize = SymbolInfoDouble(_instrument, SYMBOL_TRADE_TICK_SIZE);
      MqlTradeRequest request;
      ZeroMemory(request);
      request.action = TRADE_ACTION_DEAL;
      request.symbol = _instrument;
      request.type = orderType;
      request.volume = _amount;
      request.price = MathRound(rate / ticksize) * ticksize;
      request.deviation = _slippage;
      request.sl = MathRound(_stop / ticksize) * ticksize;
      request.tp = MathRound(_limit / ticksize) * ticksize;
      request.magic = _magicNumber;
      if(_comment != "")
         request.comment = _comment;
      request.type_filling = 0;
      MqlTradeResult result;
      ZeroMemory(result);
      bool res = OrderSend(request, result);
      switch(result.retcode)
        {
         case TRADE_RETCODE_INVALID_FILL:
            error = "Invalid order filling type";
            return 0;
         case TRADE_RETCODE_LONG_ONLY:
            error = "Only long trades are allowed for " + _instrument;
            return 0;
         case TRADE_RETCODE_INVALID_VOLUME:
           {
            double minVolume = SymbolInfoDouble(_instrument, SYMBOL_VOLUME_MIN);
            error = "Invalid volume in the request. Min volume is: " + DoubleToString(minVolume);
           }
         return 0;
         case TRADE_RETCODE_INVALID_PRICE:
            error = "Invalid price in the request";
            return 0;
         case TRADE_RETCODE_INVALID_STOPS:
           {
            int filling = (int)SymbolInfoInteger(_instrument, SYMBOL_ORDER_MODE);
            if((filling & SYMBOL_ORDER_SL) != SYMBOL_ORDER_SL)
              {
               error = "Stop loss in now allowed for " + _instrument;
               return 0;
              }
            int minStopDistancePoints = (int)SymbolInfoInteger(_instrument, SYMBOL_TRADE_STOPS_LEVEL);
            double point = SymbolInfoDouble(_instrument, SYMBOL_POINT);
            double price = request.stoplimit > 0.0 ? request.stoplimit : request.price;
            if(MathRound(MathAbs(price - request.sl) / point) < minStopDistancePoints)
              {
               error = "Your stop level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
              }
            else
              {
               error = "Invalid stops in the request";
              }
           }
         return 0;
         case TRADE_RETCODE_DONE:
            break;
         default:
            error = "Unknown error: " + IntegerToString(result.retcode);
            return 0;
        }
      return result.order;
     }
  };
#endif
// Trading calculator v.1.3

// Position size type

#ifndef PositionSizeType_IMP
#define PositionSizeType_IMP

enum PositionSizeType
  {
   PositionSizeAmount, // $
   PositionSizeContract, // In contracts
   PositionSizeEquity, // % of equity
   PositionSizeRisk, // Risk in % of equity
   PositionSizeMoneyPerPip, // $ per pip
   PositionSizeRiskCurrency // Risk in $
  };

#endif
// Stop/limit type v1.0

#ifndef StopLimitType_IMP
#define StopLimitType_IMP

enum StopLimitType
  {
   StopLimitDoNotUse, // Do not use
   StopLimitPercent, // Set in %
   StopLimitPips, // Set in Pips
   StopLimitDollar, // Set in $,
   StopLimitRiskReward, // Set in % of stop loss (take profit only)
   StopLimitAbsolute // Set in absolite value (rate)
  };

#endif

// Symbol info v1.3

#ifndef InstrumentInfo_IMP
#define InstrumentInfo_IMP

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class InstrumentInfo
  {
   string            _symbol;
   double            _mult;
   double            _point;
   double            _pipSize;
   int               _digit;
   double            _ticksize;
public:
                     InstrumentInfo(const string symbol)
     {
      _symbol = symbol;
      _point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      _digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      _mult = _digit == 3 || _digit == 5 ? 10 : 1;
      _pipSize = _point * _mult;
      _ticksize = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE), _digit);
     }

   // Return < 0 when lot1 < lot2, > 0 when lot1 > lot2 and 0 owtherwise
   int               CompareLots(double lot1, double lot2)
     {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if(lotStep == 0)
        {
         return lot1 < lot2 ? -1 : (lot1 > lot2 ? 1 : 0);
        }
      int lotSteps1 = (int)floor(lot1 / lotStep + 0.5);
      int lotSteps2 = (int)floor(lot2 / lotStep + 0.5);
      int res = lotSteps1 - lotSteps2;
      return res;
     }

   static double     GetPipSize(const string symbol)
     {
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      double digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      double mult = digit == 3 || digit == 5 ? 10 : 1;
      return point * mult;
     }
   double            GetPointSize() { return _point; }
   double            GetPipSize() { return _pipSize; }
   int               GetDigits() { return _digit; }
   string            GetSymbol() { return _symbol; }
   static double     GetBid(const string symbol) { return SymbolInfoDouble(symbol, SYMBOL_BID); }
   static double     GetAsk(const string symbol) { return SymbolInfoDouble(symbol, SYMBOL_ASK); }
   double            GetBid() { return SymbolInfoDouble(_symbol, SYMBOL_BID); }
   double            GetAsk() { return SymbolInfoDouble(_symbol, SYMBOL_ASK); }
   double            GetMinLots() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); };

   double            RoundRate(const double rate)
     {
      return NormalizeDouble(MathRound(rate / _ticksize) * _ticksize, _digit);
     }

   double            RoundLots(const double lots)
     {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if(lotStep == 0)
        {
         return 0.0;
        }
      return floor(lots / lotStep) * lotStep;
     }

   double            LimitLots(const double lots)
     {
      double minVolume = GetMinLots();
      if(minVolume > lots)
        {
         return 0.0;
        }
      double maxVolume = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MAX);
      if(maxVolume < lots)
        {
         return maxVolume;
        }
      return lots;
     }

   double            NormalizeLots(const double lots)
     {
      return LimitLots(RoundLots(lots));
     }
  };

#endif
// Trades iterator v 1.3

// Compare type v1.0

#ifndef CompareType_IMP
#define CompareType_IMP

enum CompareType
  {
   CompareLessThan
  };

#endif

#ifndef TradesIterator_IMP

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TradesIterator
  {
   bool              _useMagicNumber;
   int               _magicNumber;
   int               _orderType;
   bool              _useSide;
   bool              _isBuySide;
   int               _lastIndex;
   bool              _useSymbol;
   string            _symbol;
   bool              _useProfit;
   double            _profit;
   CompareType       _profitCompare;
   string            _comment;
public:
                     TradesIterator()
     {
      _comment = NULL;
      _useMagicNumber = false;
      _useSide = false;
      _lastIndex = INT_MIN;
      _useSymbol = false;
      _useProfit = false;
     }

   TradesIterator*   WhenComment(string comment)
     {
      _comment = comment;
      return &this;
     }

   void              WhenSymbol(const string symbol)
     {
      _useSymbol = true;
      _symbol = symbol;
     }

   void              WhenProfit(const double profit, const CompareType compare)
     {
      _useProfit = true;
      _profit = profit;
      _profitCompare = compare;
     }

   void              WhenSide(const bool isBuy)
     {
      _useSide = true;
      _isBuySide = isBuy;
     }

   void              WhenMagicNumber(const int magicNumber)
     {
      _useMagicNumber = true;
      _magicNumber = magicNumber;
     }

   ulong             GetTicket() { return PositionGetTicket(_lastIndex); }
   double            GetLots() { return PositionGetDouble(POSITION_VOLUME); }
   double            GetSwap() { return PositionGetDouble(POSITION_SWAP); }
   double            GetProfit() { return PositionGetDouble(POSITION_PROFIT); }
   double            GetOpenPrice() { return PositionGetDouble(POSITION_PRICE_OPEN); }
   double            GetStopLoss() { return PositionGetDouble(POSITION_SL); }
   double            GetTakeProfit() { return PositionGetDouble(POSITION_TP); }
   ENUM_POSITION_TYPE GetPositionType() { return (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); }
   bool              IsBuyOrder() { return GetPositionType() == POSITION_TYPE_BUY; }
   string            GetSymbol() { return PositionGetSymbol(_lastIndex); }

   int               Count()
     {
      int count = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket) && PassFilter(i))
           {
            count++;
           }
        }
      return count;
     }

   bool              Next()
     {
      if(_lastIndex == INT_MIN)
        {
         _lastIndex = PositionsTotal() - 1;
        }
      else
         _lastIndex = _lastIndex - 1;
      while(_lastIndex >= 0)
        {
         ulong ticket = PositionGetTicket(_lastIndex);
         if(PositionSelectByTicket(ticket) && PassFilter(_lastIndex))
            return true;
         _lastIndex = _lastIndex - 1;
        }
      return false;
     }

   bool              Any()
     {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket) && PassFilter(i))
           {
            return true;
           }
        }
      return false;
     }

   ulong             First()
     {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket) && PassFilter(i))
           {
            return ticket;
           }
        }
      return 0;
     }

private:
   bool              PassFilter(const int index)
     {
      if(_useMagicNumber && PositionGetInteger(POSITION_MAGIC) != _magicNumber)
         return false;
      if(_useSymbol && PositionGetSymbol(index) != _symbol)
         return false;
      if(_useProfit)
        {
         switch(_profitCompare)
           {
            case CompareLessThan:
               if(PositionGetDouble(POSITION_PROFIT) >= _profit)
                  return false;
               break;
           }
        }
      if(_useSide)
        {
         ENUM_POSITION_TYPE positionType = GetPositionType();
         if(_isBuySide && positionType != POSITION_TYPE_BUY)
            return false;
         if(!_isBuySide && positionType != POSITION_TYPE_SELL)
            return false;
        }
      if(_comment != NULL)
        {
         if(_comment != PositionGetString(POSITION_COMMENT))
            return false;
        }
      return true;
     }
  };
#define TradesIterator_IMP
#endif

#ifndef TradingCalculator_IMP
#define TradingCalculator_IMP

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TradingCalculator
  {
   InstrumentInfo    *_symbolInfo;
public:
   static TradingCalculator* Create(string symbol)
     {
      return new TradingCalculator(symbol);
     }

                     TradingCalculator(const string symbol)
     {
      _symbolInfo = new InstrumentInfo(symbol);
     }

                    ~TradingCalculator()
     {
      delete _symbolInfo;
     }

   InstrumentInfo    *GetSymbolInfo()
     {
      return _symbolInfo;
     }

   double            GetBreakevenPrice(const bool isBuy, const int magicNumber)
     {
      string symbol = _symbolInfo.GetSymbol();
      double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
      double price = isBuy ? _symbolInfo.GetBid() : _symbolInfo.GetAsk();
      double totalPL = 0;
      double totalAmount = 0;
      TradesIterator it1();
      it1.WhenMagicNumber(magicNumber);
      it1.WhenSymbol(symbol);
      it1.WhenSide(isBuy);
      while(it1.Next())
        {
         double orderLots = PositionGetDouble(POSITION_VOLUME);
         totalAmount += orderLots / lotStep;
         double openPrice = it1.GetOpenPrice();
         if(isBuy)
            totalPL += (price - openPrice) * (orderLots / lotStep);
         else
            totalPL += (openPrice - price) * (orderLots / lotStep);
        }
      if(totalAmount == 0.0)
         return 0.0;
      double shift = -(totalPL / totalAmount);
      return isBuy ? price + shift : price - shift;
     }

   double            CalculateTakeProfit(const bool isBuy, const double takeProfit, const StopLimitType takeProfitType, const double amount, double basePrice)
     {
      int direction = isBuy ? 1 : -1;
      switch(takeProfitType)
        {
         case StopLimitPercent:
            return basePrice + basePrice * takeProfit / 100.0 * direction;
         case StopLimitPips:
            return basePrice + takeProfit * _symbolInfo.GetPipSize() * direction;
         case StopLimitDollar:
            return basePrice + CalculateSLShift(amount, takeProfit) * direction;
        }
      return 0.0;
     }

   double            CalculateStopLoss(const bool isBuy, const double stopLoss, const StopLimitType stopLossType, const double amount, double basePrice)
     {
      int direction = isBuy ? 1 : -1;
      switch(stopLossType)
        {
         case StopLimitPercent:
            return basePrice - basePrice * stopLoss / 100.0 * direction;
         case StopLimitPips:
            return basePrice - stopLoss * _symbolInfo.GetPipSize() * direction;
         case StopLimitDollar:
            return basePrice - CalculateSLShift(amount, stopLoss) * direction;
        }
      return 0.0;
     }

   double            GetLots(PositionSizeType lotsType, double lotsValue, const OrderSide orderSide, const double price, double stopDistance)
     {
      switch(lotsType)
        {
         case PositionSizeMoneyPerPip:
           {
            double unitCost = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_VALUE);
            double mult = _symbolInfo.GetPipSize() / _symbolInfo.GetPointSize();
            double lots = RoundLots(lotsValue / (unitCost * mult));
            return LimitLots(lots);
           }
         case PositionSizeAmount:
            return GetLotsForMoney(orderSide, price, lotsValue);
         case PositionSizeContract:
            return LimitLots(RoundLots(lotsValue));
         case PositionSizeEquity:
            return GetLotsForMoney(orderSide, price, AccountInfoDouble(ACCOUNT_EQUITY) * lotsValue / 100.0);
         case PositionSizeRisk:
           {
            double affordableLoss = AccountInfoDouble(ACCOUNT_EQUITY) * lotsValue / 100.0;
            double unitCost = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_VALUE);
            double tickSize = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_SIZE);
            double possibleLoss = unitCost * stopDistance / tickSize;
            if(possibleLoss <= 0.01)
               return 0;
            return LimitLots(RoundLots(affordableLoss / possibleLoss));
           }
        }
      return lotsValue;
     }

   bool              IsLotsValid(const double lots, PositionSizeType lotsType, string &error)
     {
      switch(lotsType)
        {
         case PositionSizeContract:
            return IsContractLotsValid(lots, error);
        }
      return true;
     }

   double            NormilizeLots(double lots)
     {
      return LimitLots(RoundLots(lots));
     }

private:
   bool              IsContractLotsValid(const double lots, string &error)
     {
      double minVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MIN);
      if(minVolume > lots)
        {
         error = "Min. allowed lot size is " + DoubleToString(minVolume);
         return false;
        }
      double maxVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MAX);
      if(maxVolume < lots)
        {
         error = "Max. allowed lot size is " + DoubleToString(maxVolume);
         return false;
        }
      return true;
     }

   double            GetLotsForMoney(const OrderSide orderSide, const double price, const double money)
     {
      ENUM_ORDER_TYPE orderType = orderSide != BuySide ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
      string symbol = _symbolInfo.GetSymbol();
      double minVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double marginRequired;
      if(!OrderCalcMargin(orderType, symbol, minVolume, price, marginRequired))
        {
         return 0.0;
        }
      if(marginRequired <= 0.0)
        {
         Print("Margin is 0. Server misconfiguration?");
         return 0.0;
        }
      double lots = RoundLots(money / marginRequired);
      return LimitLots(lots);
     }

   double            RoundLots(const double lots)
     {
      double lotStep = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_STEP);
      if(lotStep == 0)
         return 0.0;
      return floor(lots / lotStep) * lotStep;
     }

   double            LimitLots(const double lots)
     {
      double minVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MIN);
      if(minVolume > lots)
         return 0.0;
      double maxVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MAX);
      if(maxVolume < lots)
         return maxVolume;
      return lots;
     }

   double            CalculateSLShift(const double amount, const double money)
     {
      double unitCost = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_SIZE);
      return (money / (unitCost / tickSize)) / amount;
     }
  };

#endif
// Trading commands v.2.0





// Orders iterator v1.9

#ifndef OrdersIterator_IMP
#define OrdersIterator_IMP

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OrdersIterator
  {
   bool              _useMagicNumber;
   int               _magicNumber;
   bool              _useOrderType;
   ENUM_ORDER_TYPE   _orderType;
   bool              _useSide;
   bool              _isBuySide;
   int               _lastIndex;
   bool              _useSymbol;
   string            _symbol;
   bool              _usePendingOrder;
   bool              _pendingOrder;
   bool              _useComment;
   string            _comment;
   CompareType       _profitCompare;
public:
                     OrdersIterator()
     {
      _useOrderType = false;
      _useMagicNumber = false;
      _usePendingOrder = false;
      _pendingOrder = false;
      _useSide = false;
      _lastIndex = INT_MIN;
      _useSymbol = false;
      _useComment = false;
     }

   OrdersIterator    *WhenPendingOrder()
     {
      _usePendingOrder = true;
      _pendingOrder = true;
      return &this;
     }

   OrdersIterator    *WhenSymbol(const string symbol)
     {
      _useSymbol = true;
      _symbol = symbol;
      return &this;
     }

   OrdersIterator    *WhenSide(const OrderSide side)
     {
      _useSide = true;
      _isBuySide = side == BuySide;
      return &this;
     }

   OrdersIterator    *WhenOrderType(const ENUM_ORDER_TYPE orderType)
     {
      _useOrderType = true;
      _orderType = orderType;
      return &this;
     }

   OrdersIterator    *WhenMagicNumber(const int magicNumber)
     {
      _useMagicNumber = true;
      _magicNumber = magicNumber;
      return &this;
     }

   OrdersIterator    *WhenComment(const string comment)
     {
      _useComment = true;
      _comment = comment;
      return &this;
     }

   long              GetMagicNumger() { return OrderGetInteger(ORDER_MAGIC); }
   ENUM_ORDER_TYPE   GetType() { return (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE); }
   string            GetSymbol() { return OrderGetString(ORDER_SYMBOL); }
   string            GetComment() { return OrderGetString(ORDER_COMMENT); }
   ulong             GetTicket() { return OrderGetTicket(_lastIndex); }
   double            GetOpenPrice() { return OrderGetDouble(ORDER_PRICE_OPEN); }
   double            GetStopLoss() { return OrderGetDouble(ORDER_SL); }
   double            GetTakeProfit() { return OrderGetDouble(ORDER_TP); }

   int               Count()
     {
      int count = 0;
      for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
         ulong ticket = OrderGetTicket(i);
         if(OrderSelect(ticket) && PassFilter())
            count++;
        }
      return count;
     }

   bool              Next()
     {
      if(_lastIndex == INT_MIN)
         _lastIndex = OrdersTotal() - 1;
      else
         _lastIndex = _lastIndex - 1;
      while(_lastIndex >= 0)
        {
         ulong ticket = OrderGetTicket(_lastIndex);
         if(OrderSelect(ticket) && PassFilter())
            return true;
         _lastIndex = _lastIndex - 1;
        }
      return false;
     }

   bool              Any()
     {
      for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
         ulong ticket = OrderGetTicket(i);
         if(OrderSelect(ticket) && PassFilter())
            return true;
        }
      return false;
     }

   ulong             First()
     {
      for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
         ulong ticket = OrderGetTicket(i);
         if(OrderSelect(ticket) && PassFilter())
            return ticket;
        }
      return -1;
     }

private:
   bool              PassFilter()
     {
      if(_useMagicNumber && GetMagicNumger() != _magicNumber)
         return false;
      if(_useOrderType && GetType() != _orderType)
         return false;
      if(_useSymbol && OrderGetString(ORDER_SYMBOL) != _symbol)
         return false;
      if(_usePendingOrder && !IsPendingOrder())
         return false;
      if(_useComment && OrderGetString(ORDER_COMMENT) != _comment)
         return false;
      return true;
     }

   bool              IsPendingOrder()
     {
      switch(GetType())
        {
         case ORDER_TYPE_BUY_LIMIT:
         case ORDER_TYPE_BUY_STOP:
         case ORDER_TYPE_BUY_STOP_LIMIT:
         case ORDER_TYPE_SELL_LIMIT:
         case ORDER_TYPE_SELL_STOP:
         case ORDER_TYPE_SELL_STOP_LIMIT:
            return true;
        }
      return false;
     }
  };
#endif

#ifndef tradeManager_INSTANCE
#define tradeManager_INSTANCE
#include <Trade\Trade.mqh>
CTrade tradeManager;
#endif

#ifndef TradingCommands_IMP
#define TradingCommands_IMP

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TradingCommands
  {
public:
   static bool       MoveSLTP(const ulong ticket, const double stopLoss, double takeProfit, string &error)
     {
      if(!PositionSelectByTicket(ticket))
        {
         error = "Invalid ticket";
         return false;
        }
      return tradeManager.PositionModify(ticket, stopLoss, takeProfit);
     }

   static bool       MoveSL(const ulong ticket, const double stopLoss, string &error)
     {
      if(!PositionSelectByTicket(ticket))
        {
         error = "Invalid ticket";
         return false;
        }
      return tradeManager.PositionModify(ticket, stopLoss, PositionGetDouble(POSITION_TP));
     }

   static bool       MoveTP(const ulong ticket, const double takeProfit, string &error)
     {
      if(!PositionSelectByTicket(ticket))
        {
         error = "Invalid ticket";
         return false;
        }
      return tradeManager.PositionModify(ticket, PositionGetDouble(POSITION_SL), takeProfit);
     }

   static void       DeleteOrders(const int magicNumber, const string symbol)
     {
      OrdersIterator it();
      it.WhenMagicNumber(magicNumber);
      it.WhenSymbol(symbol);
      while(it.Next())
        {
         tradeManager.OrderDelete(it.GetTicket());
        }
     }

   static bool       CloseTrade(ulong ticket, string error)
     {
      if(!tradeManager.PositionClose(ticket))
        {
         error = IntegerToString(GetLastError());
         return false;
        }
      return true;
     }

   static int        CloseTrades(TradesIterator &it)
     {
      int close = 0;
      while(it.Next())
        {
         string error;
         if(!CloseTrade(it.GetTicket(), error))
            Print("LastError = ", error);
         else
            ++close;
        }
      return close;
     }
  };

#endif
// Closed trades iterator v 1.2
#ifndef ClosedTradesIterator_IMP
class ClosedTradesIterator
  {
   int               _lastIndex;
   int               _total;
   ulong             _currentTicket;
   string            _symbol;
   int               _magicNumber;
public:
                     ClosedTradesIterator()
     {
      _lastIndex = INT_MIN;
      _magicNumber = 0;
     }

   void              WhenSymbol(string symbol)
     {
      _symbol = symbol;
     }

   void              WhenMagicNumber(int magicNumber)
     {
      _magicNumber = magicNumber;
     }

   ulong             GetTicket() { return _currentTicket; }
   ENUM_DEAL_TYPE    GetPositionType() { return (ENUM_DEAL_TYPE)HistoryDealGetInteger(_currentTicket, DEAL_TYPE); }
   string            GetSymbol() { return HistoryDealGetString(_currentTicket, DEAL_SYMBOL); }
   datetime          GetCloseTime() { return (datetime)HistoryDealGetInteger(_currentTicket, DEAL_TIME); }
   int               GetMagicNumber() { return HistoryDealGetInteger(_currentTicket, DEAL_MAGIC); }
   double            GetProfit() { return HistoryDealGetDouble(_currentTicket, DEAL_PROFIT); }
   double            GetLots() { return HistoryDealGetDouble(_currentTicket, DEAL_VOLUME); }

   int               Count()
     {
      int count = 0;
      for(int i = 0; i < Total(); i--)
        {
         _currentTicket = HistoryDealGetTicket(i);
         if(PassFilter(i))
           {
            count++;
           }
        }
      return count;
     }

   bool              Next()
     {
      _total = Total();
      if(_lastIndex == INT_MIN)
         _lastIndex = 0;
      else
         ++_lastIndex;
      while(_lastIndex != _total)
        {
         _total = Total();
         _currentTicket = HistoryDealGetTicket(_lastIndex);
         if(PassFilter(_lastIndex))
            return true;
         ++_lastIndex;
        }
      return false;
     }

   bool              Any()
     {
      for(int i = 0; i < Total(); i++)
        {
         _currentTicket = HistoryDealGetTicket(i);
         if(PassFilter(i))
           {
            return true;
           }
        }
      return false;
     }

private:
   int               Total()
     {
      bool res = HistorySelect(0, TimeCurrent());
      return HistoryDealsTotal();
     }

   bool              PassFilter(const int index)
     {
      long entry = HistoryDealGetInteger(_currentTicket, DEAL_ENTRY);
      if(entry != DEAL_ENTRY_OUT)
        {
         return false;
        }
      if(_symbol != NULL && GetSymbol() != _symbol)
        {
         return false;
        }
      if(_magicNumber != 0 && GetMagicNumber() != _magicNumber)
        {
         return false;
        }
      return true;
     }
  };
#define ClosedTradesIterator_IMP
#endif


InstrumentInfo* instrument;
ActionOnConditionLogic* actions;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorObjPrefix = GenerateIndicatorPrefix("EA_Price_Action");
   actions = new ActionOnConditionLogic();
   instrument = new InstrumentInfo(_Symbol);
   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   delete actions;
   delete instrument;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Hour()
  {
   MqlDateTime dt;
   TimeCurrent(dt);
   return dt.hour;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Seconds()
  {
   MqlDateTime dt;
   TimeCurrent(dt);
   return dt.sec;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   double close_2;
   double close_1;
   double total_lots;
   DrawDashboard();
   if(G_time_264 == iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, 0))
      return;
   G_time_264 = iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   TradesIterator trades;
   trades.WhenSymbol(_Symbol);
   trades.WhenMagicNumber(MagicNumber);
   while(trades.Next())
     {
      if(trades.IsBuyOrder())
        {
         open_buy = true;
         open_sell = false;
         break;
        }
      else
        {
         open_buy = false;
         open_sell = true;
         break;
        }
     }
   if(trades_count > 0 && trades_count <= MaxLevel)
     {
      last_buy_price = LastBuyPrice();
      last_sell_price = LastSellPrice();
      if(open_buy && last_buy_price - instrument.GetAsk() >= Distance * instrument.GetPipSize())
         open_new = true;
      if(open_sell && instrument.GetBid() - last_sell_price >= Distance * instrument.GetPipSize())
         open_new = true;
     }
   if(trades_count < 1)
     {
      open_sell = false;
      open_buy = false;
      open_new = true;
     }
   if(open_new)
     {
      last_buy_price = LastBuyPrice();
      last_sell_price = LastSellPrice();
      if(open_sell)
        {
         lot_size = CalcLot();
         last_trades_count = trades_count;
         if(lot_size > 0.0)
           {
            order_ticket = OpenOrder(false, lot_size, Gd_176, 0, EA_Comment + "-" + last_trades_count, MagicNumber);
            if(order_ticket < 0)
              {
               return;
              }
            last_sell_price = LastSellPrice();
            open_new = false;
            move_net_take_profit = true;
           }
        }
      else
        {
         if(open_buy)
           {
            lot_size = CalcLot();
            last_trades_count = trades_count;
            if(lot_size > 0.0)
              {
               order_ticket = OpenOrder(true, lot_size, Gd_176, 0, EA_Comment + "-" + last_trades_count, MagicNumber);
               if(order_ticket < 0)
                 {
                  return;
                 }
               last_buy_price = LastBuyPrice();
               open_new = false;
               move_net_take_profit = true;
              }
           }
        }
     }
   if(Hour() >= StartTrade && Hour() < EndTrade)
     {
      if(trade_number < Loop && TradeAgain)
        {
         if(open_new && trades_count < 1)
           {
            close_2 = iClose(Symbol(), 0, 2);
            close_1 = iClose(Symbol(), 0, 1);
            if((!open_sell) && (!open_buy))
              {
               last_trades_count = trades_count;
               if(close_2 > close_1)
                 {
                  lot_size = CalcLot();
                  if(lot_size > 0.0)
                    {
                     order_ticket = OpenOrder(false, lot_size, Gd_176, 0, EA_Comment + "-" + last_trades_count, MagicNumber);
                     trade_number++;
                     if(order_ticket == 0)
                       {
                        return;
                       }
                     last_buy_price = LastBuyPrice();
                     move_net_take_profit = true;
                    }
                 }
               else
                 {
                  lot_size = CalcLot();
                  if(lot_size > 0.0)
                    {
                     order_ticket = OpenOrder(true, lot_size, Gd_176, 0, EA_Comment + "-" + last_trades_count, MagicNumber);
                     trade_number++;
                     if(order_ticket == 0)
                       {
                        return;
                       }
                     last_sell_price = LastSellPrice();
                     move_net_take_profit = true;
                    }
                 }
              }
           }
        }
     }
   if(move_net_take_profit)
     {
      average_open_price = 0;
      total_lots = 0;
      TradesIterator trades2;
      trades2.WhenSymbol(_Symbol);
      trades2.WhenMagicNumber(MagicNumber);
      while(trades2.Next())
        {
         average_open_price += trades2.GetOpenPrice() * trades2.GetLots();
         total_lots += trades2.GetLots();
         if(trades2.IsBuyOrder())
           {
            net_take_profit = average_open_price + TP * instrument.GetPipSize();
           }
         else
           {
            net_take_profit = average_open_price - TP * instrument.GetPipSize();
           }
        }
      InstrumentInfo instrument(_Symbol);
      if(total_lots > 0)
         average_open_price = instrument.RoundRate(average_open_price / total_lots);
      TradesIterator trades3;
      trades3.WhenSymbol(_Symbol);
      trades3.WhenMagicNumber(MagicNumber);
      while(trades3.Next())
        {
         string error;
         if(!TradingCommands::MoveTP(trades3.GetTicket(), net_take_profit, error))
           {
            Print(error);
           }
         move_net_take_profit = false;
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcLot()
  {
   double lots_4;
   int datetime_12;
   switch(DbLots)
     {
      case 0:
         lots_4 = Lots;
         break;
      case 1:
         lots_4 = NormalizeDouble(Lots * MathPow(Multiplier, last_trades_count), LotsDecimal);
         break;
      case 2:
        {
         datetime_12 = 0;
         lots_4 = Lots;
         ClosedTradesIterator it();
         it.WhenSymbol(_Symbol);
         it.WhenMagicNumber(MagicNumber);
         while(it.Next())
           {
            if(datetime_12 < it.GetCloseTime())
              {
               datetime_12 = it.GetCloseTime();
               if(it.GetProfit() < 0.0)
                 {
                  lots_4 = NormalizeDouble(it.GetLots() * Multiplier, LotsDecimal);
                  continue;
                 }
               lots_4 = Lots;
              }
           }
        }
     }
   return (lots_4);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades()
  {
   int count_0 = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket)
         && PositionGetString(POSITION_SYMBOL) == _Symbol
         && PositionGetInteger(POSITION_MAGIC) == MagicNumber)
        {
         count_0++;
        }
     }
   return count_0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong OpenOrder(bool isBuy, double A_lots_4, int A_slippage_20, int Ai_36, string A_comment_40, int A_magic_48)
  {
   MarketOrderBuilder* builder = new MarketOrderBuilder(actions);
   builder.SetSide(isBuy ? BuySide : SellSide);
   builder.SetInstrument(_Symbol);
   builder.SetAmount(A_lots_4);
   builder.SetSlippage(A_slippage_20);
   TradingCalculator* calc = TradingCalculator::Create(_Symbol);
   if(SL > 0)
     {
      builder.SetStopLoss(calc.CalculateStopLoss(isBuy, SL, StopLimitPips, A_lots_4, isBuy ? instrument.GetAsk() : instrument.GetBid()));
     }
   builder.SetTakeProfit(calc.CalculateTakeProfit(isBuy, Ai_36, StopLimitPips,  A_lots_4, isBuy ? instrument.GetAsk() : instrument.GetBid()));
   delete calc;
   builder.SetMagicNumber(A_magic_48);
   builder.SetComment(A_comment_40);
   string error;
   ulong ticket = builder.Execute(error);
   if(ticket == 0)
     {
      Print(error);
     }
   return ticket;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LastBuyPrice()
  {
   double order_open_price_0;
   ulong ticket_8;
   ulong ticket_20 = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket)
         && PositionGetString(POSITION_SYMBOL) == _Symbol
         && PositionGetInteger(POSITION_MAGIC) == MagicNumber
         && PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY)
        {
         if(ticket > ticket_20)
           {
            order_open_price_0 = PositionGetDouble(POSITION_PRICE_OPEN);
            ticket_20 = ticket;
           }
        }
     }
   return order_open_price_0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LastSellPrice()
  {
   double order_open_price_0;
   ulong ticket_8;
   ulong ticket_20 = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket)
         && PositionGetString(POSITION_SYMBOL) == _Symbol
         && PositionGetInteger(POSITION_MAGIC) == MagicNumber
         && PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_SELL)
        {
         if(ticket > ticket_20)
           {
            order_open_price_0 = PositionGetDouble(POSITION_PRICE_OPEN);
            ticket_20 = ticket;
           }
        }
     }
   return order_open_price_0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetCurrentProfit()
  {
   Gd_336 = 0;
   double Ld_ret_0 = 0;
   bool res = HistorySelect(0, TimeCurrent());
   for(int i = 0; i < HistoryDealsTotal(); i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_BUY)
        {
         Gd_336 += HistoryDealGetDouble(ticket, DEAL_VOLUME);
        }
     }
   Ld_ret_0 = Gd_336 * MoneyPerLot;
   return (Ld_ret_0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawDashboard()
  {
   color color_0;
   int Li_4 = 65280;
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(equity - balance < 0.0)
      Li_4 = 255;
   if(Seconds() >= 0 && Seconds() < 10)
      color_0 = Red;
   if(Seconds() >= 10 && Seconds() < 20)
      color_0 = Violet;
   if(Seconds() >= 20 && Seconds() < 30)
      color_0 = Orange;
   if(Seconds() >= 30 && Seconds() < 40)
      color_0 = Blue;
   if(Seconds() >= 40 && Seconds() < 50)
      color_0 = Yellow;
   if(Seconds() >= 50 && Seconds() <= 59)
      color_0 = Aqua;
   string Ls_8 = "-------------------------------------------";
   f0_6("L01", "Arial", 9, 10, 10, Gi_328, 1, Ls_8);
   f0_6("L02", "Verdana", 15, 10, 25, color_0, 1, "EA HOKKYDJONG");
   f0_6("L0i", "Mistral", 12, 10, 45, Gi_324, 1, "Price Action Scalping Style");
   f0_6("L03", "Arial", 9, 10, 60, Gi_328, 1, Ls_8);
   f0_6("L04", "Arial", 9, 10, 75, Gi_332, 1, ">> Account Company : " + AccountInfoString(ACCOUNT_COMPANY));
   f0_6("L05", "Arial", 9, 10, 90, Gi_332, 1, ">> Name Server  : " + AccountInfoString(ACCOUNT_SERVER));
   f0_6("L06", "Arial", 9, 10, 105, Gi_332, 1, ">> Account Name  : " + AccountInfoString(ACCOUNT_NAME));
   f0_6("L07", "Arial", 9, 10, 120, Gi_332, 1, ">> Name Number  : " + AccountInfoInteger(ACCOUNT_LOGIN));
   f0_6("L08", "Arial", 9, 10, 135, Gi_332, 1, ">> Account Leverage  : 1 " + AccountInfoInteger(ACCOUNT_LEVERAGE));
   f0_6("L09", "Arial", 9, 10, 150, Gi_332, 1, ">> Time Server  : " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS));
   f0_6("L10", "Arial", 9, 10, 165, Gi_332, 1, ">> Spread  : " + DoubleToString(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD), 0));
   f0_6("L11", "Arial", 9, 10, 180, Gi_332, 1, ">> Account Balance  : $ " + DoubleToString(balance, 2));
   f0_6("L12", "Arial", 9, 10, 195, Gi_332, 1, ">> Account Equity  : $ " + DoubleToString(equity, 2));
   f0_6("L13", "Arial", 9, 10, 210, Gi_332, 1, ">> Order Total  : " + DoubleToString(OrdersTotal(), 0));
   f0_6("L14", "Arial", 9, 10, 390, Li_4, 1, ">> Profit / Loss  : $ " + DoubleToString(equity - balance, 2));
   f0_6("L15", "Arial", 15, 10, 425, Li_4, 1, " Rebate  : $ " + DoubleToString(GetCurrentProfit(), 2));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjectSetText(string id, string text, int fontSize, string font, color clr)
  {
   ObjectSetString(0, id, OBJPROP_TEXT, text);
   ObjectSetString(0, id, OBJPROP_FONT, font);
   ObjectSetInteger(0, id, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void f0_6(string A_name_0, string A_fontname_8, int A_fontsize_16, int A_x_20, int A_y_24, color A_color_28, int A_corner_32, string A_text_36)
  {
   if(ObjectFind(0, IndicatorObjPrefix + A_name_0) < 0)
      ObjectCreate(0, IndicatorObjPrefix + A_name_0, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(IndicatorObjPrefix + A_name_0, A_text_36, A_fontsize_16, A_fontname_8, A_color_28);
   ObjectSetInteger(0, IndicatorObjPrefix + A_name_0, OBJPROP_CORNER, A_corner_32);
   ObjectSetInteger(0, IndicatorObjPrefix + A_name_0, OBJPROP_XDISTANCE, A_x_20);
   ObjectSetInteger(0, IndicatorObjPrefix + A_name_0, OBJPROP_YDISTANCE, A_y_24);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+
