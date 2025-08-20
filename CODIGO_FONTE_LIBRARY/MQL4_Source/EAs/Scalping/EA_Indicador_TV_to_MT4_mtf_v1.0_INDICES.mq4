// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73431

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  |
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

#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrWhite
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrWhite
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_type2 DRAW_NONE
//--- indicator buffers


// ------------------------------------------------------------------
extern ENUM_TIMEFRAMES TimeFrame   = PERIOD_CURRENT;    // Time frame
input double m                     = 2;      // Key value:
input double atrPeriods            = 14;     // ATR periods:
input bool   h                     = false;  // Signals From Heinken Ashi Candles
input string T1                    = "== Notifications ==";  // ————————————
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
input string T2                    = "== Set Arrows ==";     // ————————————
input bool   ArrowsOn              = true;                   // Arrows On?
input bool   inpArrowsOnFirst      = false;                  // Arrows on first mtf bar
input color  ArrowUpClr            = clrWhite;                // Arrow Up Color:
input color  ArrowDnClr            = clrWhite;                 // Arrow Down Color:

double ArrowUp[];
double ArrowDn[];
double xATRTrailingStop[],count[];

//--- variables
double nLoss, xATR;
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,m,atrPeriods,h,T1,notifications,desktop_notifications,email_notifications,push_notifications,T2,ArrowsOn,inpArrowsOnFirst,ArrowUpClr,ArrowDnClr,_buff,_ind)
// ------------------------------------------------------------------
class CCandle
{
  int    _timeFrame;
  string _symbol;
  double _open;
  double _high;
  double _low;
  double _close;
  float  _size;
  string _type;
  string _direction;
  float  _bodySize;
  float  _shadowSup;
  float  _shadowInf;

 public:
  CCandle() { ; }
  CCandle(string sym, int tf) : _symbol(sym), _timeFrame(tf) {}
  ~CCandle() { ; }

  // Getters
  float  Size(void) { return _size; }
  string Type(void) { return _type; }
  double Open(void) { return _open; }
  double High(void) { return _high; }
  double Low(void) { return _low; }
  double Close(void) { return _close; }
  string Direction(void) { return _direction; }
  float  BodySize(void) { return _bodySize; }
  float  ShadowSup(void) { return _shadowSup; }
  float  ShadowInf(void) { return _shadowInf; }

  void setCandle(int shift = 1)
  {
    _open  = iOpen(_symbol, _timeFrame, shift);
    _high  = iHigh(_symbol, _timeFrame, shift);
    _low   = iLow(_symbol, _timeFrame, shift);
    _close = iClose(_symbol, _timeFrame, shift);

    setDirection();
    setSize();
    setBodySize();
    setShadows();
  }
  void setSize()
  {
    _size = 1;
    if (Distance(_high, _low, _symbol) > 0)
    {
      _size = Distance(_high, _low, _symbol);
    }
  }
  void setBodySize()
  {
    _bodySize = 1;
    if (Distance(_open, _close, _symbol) > 0)
    {
      _bodySize = Distance(_open, _close, _symbol);
    }
  }
  void setDirection()
  {
    if (_open < _close)
    {
      _direction = "up";
    }
    if (_open > _close)
    {
      _direction = "down";
    }
    if (_open == _close)
    {
      _direction = "null";
    }
  }
  void PrintCandle()
  {
    Print(__FUNCTION__, " ", "symbol", " ", _symbol);
    Print(__FUNCTION__, " ", "open", " ", _open);
    Print(__FUNCTION__, " ", "high", " ", _high);
    Print(__FUNCTION__, " ", "low", " ", _low);
    Print(__FUNCTION__, " ", "close", " ", _close);
    Print(__FUNCTION__, " ", "_size;", " ", _size);
    Print(__FUNCTION__, " ", "_type;", " ", _type);
    Print(__FUNCTION__, " ", "_direction;", " ", _direction);
    Print(__FUNCTION__, " ", "_bodySize;", " ", _bodySize);
    Print(__FUNCTION__, " ", "_shadowSup;", " ", _shadowSup);
    Print(__FUNCTION__, " ", "_shadowInf;", " ", _shadowInf);
  }
  void setShadows()
  {
    if (Direction() == "up")
    {
      _shadowInf = Distance(_open, _low, _symbol);
      _shadowSup = Distance(_close, _high, _symbol);
    }
    if (Direction() == "down")
    {
      _shadowInf = Distance(_close, _low, _symbol);
      _shadowSup = Distance(_open, _high, _symbol);
    }
    if (Direction() == "null")
    {
      _shadowInf = Distance(_close, _low, _symbol);
      _shadowSup = Distance(_open, _high, _symbol);
    }
  }
  float Distance(double precioA, double precioB, string par)
  {
    double mPoint     = MarketInfo(par, MODE_POINT);
    double dist       = fabs(precioA - precioB);
    double distReturn = 0;
    if (mPoint > 0) distReturn = dist / mPoint;
    return distReturn;
  }
};
CCandle candle1();
CCandle candle2();

class CNewCandle
{
 private:
  int    _initialCandles;
  string _symbol;
  int    _tf;

 public:
  CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
  CNewCandle()
  {
    // toma los valores del chart actual
    _initialCandles = iBars(Symbol(), Period());
    _symbol         = Symbol();
    _tf             = Period();
  }
  ~CNewCandle() { ; }

  bool IsNewCandle()
  {
    int _currentCandles = iBars(_symbol, _tf);
    if (_currentCandles > _initialCandles)
    {
      _initialCandles = _currentCandles;
      return true;
    }

    return false;
  }
};
CNewCandle newCandle();

// ------------------------------------------------------------------
int OnInit()
{
  IndicatorBuffers(4);
  SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
  SetIndexArrow(0, 233);
  SetIndexStyle(0, DRAW_ARROW, EMPTY, 3, ArrowUpClr);
  SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
  SetIndexArrow(1, 234);
  SetIndexStyle(1, DRAW_ARROW, EMPTY, 3, ArrowDnClr);
  SetIndexBuffer(2, xATRTrailingStop);
  //SetIndexStyle(2, DRAW_NONE);
  SetIndexBuffer(3, count);

  if (!ArrowsOn)
  {
    SetIndexStyle(0, DRAW_NONE);
    SetIndexStyle(1, DRAW_NONE);
  }
  
  indicatorFileName = WindowExpertName();
  TimeFrame         = fmax(TimeFrame,_Period); 
  return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {}
// ------------------------------------------------------------------

int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
   int i=rates_total-prev_calculated+1; if (i>=rates_total) i=rates_total-1; count[0]=i;
      if (TimeFrame!=_Period)
      {
         i = (int)fmax(i,fmin(rates_total-1,_mtfCall(3,0)*TimeFrame/_Period));
         for (; i>=0 && !_StopFlag; i--)
         {
             int y = iBarShift(_Symbol,TimeFrame,time[i]);
             int x = y;
             if (inpArrowsOnFirst)
                   {  if (i<rates_total-1) x = iBarShift(_Symbol,TimeFrame,time[i+1]);               }
             else  {  if (i>0)             x = iBarShift(_Symbol,TimeFrame,time[i-1]); else x = -1;  }
                  ArrowUp[i] = ArrowDn[i] = EMPTY_VALUE;
                  if (x!=y)
                  {
                    ArrowUp[i] = _mtfCall(0,y);
                    ArrowDn[i] = _mtfCall(1,y);
                  }
          }           
   return(rates_total);
   }
   
   //
   //
   //
   
   for (; i>=0 && !_StopFlag; i--)
   {
     xATR  = iATR(NULL, 0, (int)atrPeriods, i);
     nLoss = m * xATR;

     double cl  = close[i];
     double cl1 = (i<rates_total-1) ? close[i+1] : close[i];
	
		// clang-format off
    xATRTrailingStop[i] = (i<rates_total-1) ? cl > xATRTrailingStop[i + 1] && cl1 > xATRTrailingStop[i + 1] ? fmax(xATRTrailingStop[i + 1], cl - nLoss) : 
		   					                      cl < xATRTrailingStop[i + 1] && cl1 < xATRTrailingStop[i + 1] ? fmin(xATRTrailingStop[i + 1], cl + nLoss) : 
													       cl > xATRTrailingStop[i + 1] ? cl - nLoss : cl + nLoss : 0;
    
		
		
		bool crossUp = (i<rates_total-1) ? cl > xATRTrailingStop[i] && cl1 < xATRTrailingStop[i+1] : 0;
		bool crossDn = (i<rates_total-1) ? cl < xATRTrailingStop[i] && cl1 > xATRTrailingStop[i+1] : 0;
      ArrowUp[i] = ArrowDn[i] = EMPTY_VALUE;
		if (cl > xATRTrailingStop[i] && crossUp==true)
    {
      ArrowUp[i] = low[i] - xATR/2;

      if (newCandle.IsNewCandle()) { Notifications(0); }
    }

    if (cl < xATRTrailingStop[i] && crossDn == true)
    {
      ArrowDn[i] = high[i] + xATR/2;

      if (newCandle.IsNewCandle()) { Notifications(1); }
    }
  }

  return (rates_total);
}

// ------------------------------------------------------------------
void setCandles(int i, int shift)
{
  candle1.setCandle(i + shift);
  candle2.setCandle(i);
}

// clang-format off
bool haveSignalUp(int i) 
{
  // TODO: signal up
	
	// double cl =  iClose(NULL,0,i);
	
	// if(cl > xATRTrailingStop[i] )
  // {
  //   return true;
  // }

  return false;
}

bool haveSignalDown(int i)
{
  // TODO: signal down
  
	// double cl =  iClose(NULL,0,i);

	// if(cl  < xATRTrailingStop[i] )
  // {
  //   return true;
  // }

  return false;
}

void Notifications(int type)
{
  string text = "";
  if (type == 0)
    text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
  else
    text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

  text += " ";

  if (!notifications)
    return;
  if (desktop_notifications)
    Alert(text);
  if (push_notifications)
    SendNotification(text);
  if (email_notifications)
    SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
  switch (lPeriod)
  {
    case PERIOD_M1:
      return ("M1");
    case PERIOD_M5:
      return ("M5");
    case PERIOD_M15:
      return ("M15");
    case PERIOD_M30:
      return ("M30");
    case PERIOD_H1:
      return ("H1");
    case PERIOD_H4:
      return ("H4");
    case PERIOD_D1:
      return ("D1");
    case PERIOD_W1:
      return ("W1");
    case PERIOD_MN1:
      return ("MN1");
  }
  return IntegerToString(lPeriod);
}

//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

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