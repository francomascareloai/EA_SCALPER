//+--------------------------------------------------------------------+
//|  
//| NO LIABILITY FOR CONSEQUENTIAL DAMAGES                             |
//|                                                                    |
//| In no event shall the author be liable for any damages whatsoever  |
//| (including, without limitation, incidental, direct, indirect and   |
//| consequential damages, damages for loss of business profits,       |
//| business interruption, loss of business information, or other      |
//| pecuniary loss) arising out of the use or inability to use this    |
//| product, even if advised of the possibility of such damages.       |
//+--------------------------------------------------------------------+



#property version   "48.0"
#property strict



// -----------------------    External variables   ----------------------- //

static input string StrategyProperties__ = "------------"; // ------ Strategy Properties ------

static input double Entry_Amount    = 1; // Amount for a new position [lot]
static input double Maximum_Amount  = 20; // Maximum position amount [lot]
static input double Adding_Amount   = 1; // Amount to add on addition [lot]
static input double Reducing_Amount = 1; // Amount to close on reduction [lot]
input int Stop_Loss   = 820; // Stop Loss [point]
input int Take_Profit = 3000; // Take Profit [point]
input int Break_Even  = 600; // Break Even [point]
static input double Martingale_Multiplier = 0; // Martingale Multiplier

static input string IndicatorName0 = "Keltner Channel"; // ------ Indicator parameters ------
input int Slot0IndParam0 = 131; // MA period
input int Slot0IndParam1 = 18; // ATR period
input int Slot0IndParam3 = 5; // ATR multiplier
static input string IndicatorName1 = "Moving Averages Crossover"; // ------ Indicator parameters ------
input int Slot1IndParam0 = 134; // Fast MA period
input int Slot1IndParam1 = 118; // Slow MA period
input int Slot1IndParam2 = 44; // Fast MA shift
input int Slot1IndParam3 = 87; // Slow MA shift
static input string IndicatorName2 = "Vidya Moving Average"; // ------ Indicator parameters ------
input int Slot2IndParam0 = 20; // Period
input int Slot2IndParam1 = 2; // Smooth
static input string IndicatorName3 = "Vidya Moving Average"; // ------ Indicator parameters ------
input int Slot3IndParam0 = 21; // Period
input int Slot3IndParam1 = 6; // Smooth
static input string IndicatorName4 = "Fractal"; // ------ Indicator parameters ------
input int Slot4IndParam0 = 302; // Vertical shift


static input string ExpertSettings__ = "------------"; // ------ Expert Settings ------

// A unique number of the expert's orders.
static input int Expert_Magic = 1023713; // Expert Magic Number

// If account equity drops below this value, the expert will close out all positions and stop automatic trade.
// The value must be set in account currency. Example:
// Protection_Min_Account = 700 will close positions if the equity drops below 700 USD (EUR if you account is in EUR).
static input int Protection_Min_Account = 0; // Stop trading at min account

// The expert checks the open positions at every tick and if found no SL or SL lower (higher for short) than selected,
// It sets SL to the defined value. The value is in points. Example:
// Protection_Max_StopLoss = 200 means 200 pips for 4 digit broker and 20 pips for 5 digit broker.
static input int Protection_Max_StopLoss = 0; // Ensure maximum Stop Loss [point]

// How many seconds before the expected bar closing to rise a Bar Closing event.
static input int Bar_Close_Advance = 15; // Bar closing advance [sec]

// Expert writes a log file when Write_Log_File = true.
static input bool Write_Log_File = false; // Write a log file

// Custom comment. It can be used for setting a binnary option epxiration perod
static input string Order_Comment = ""; // Custom order comment

// ----------------------------    Options   ---------------------------- //

// Data bars for calculating the indicator values with the necessary precission.
// If set to 0, the expert calculates them automatically.
int Min_Data_Bars=0;

// Separate SL and TP orders
// It has to be set to true for STP brokers that cannot set SL and TP together with the position (with OrderSend()).
// When Separate_SL_TP = true, the expert first opens the position and after that sets StopLoss and TakeProfit.
bool Separate_SL_TP = false; // Separate SL and TP orders 

// TrailingStop_Moving_Step determines the step of changing the Trailing Stop.
// 0 <= TrailingStop_Moving_Step <= 2000
// If TrailingStop_Moving_Step = 0, the Trailing Stop trails at every new extreme price in the position's direction.
// If TrailingStop_Moving_Step > 0, the Trailing Stop moves at steps equal to the number of pips chosen.
// This prevents sending multiple order modifications.
int TrailingStop_Moving_Step = 10;

// FIFO (First In First Out) forces the expert to close positions starting from
// the oldest one. This rule complies with the new NFA regulations.
// If you want to close the positions from the newest one (FILO), change the variable to "false".
// This doesn't change the normal work of Forex Strategy Builder.
bool FIFO_order = true;

// When the log file reaches the preset number of lines,
// the expert starts a new log file.
int Max_Log_Lines_in_File = 2000;

// Used to detect a chart change
string __symbol = "";
int    __period = -1;

enum DataPeriod
  {
   DataPeriod_M1  = 1,
   DataPeriod_M5  = 5,
   DataPeriod_M15 = 15,
   DataPeriod_M30 = 30,
   DataPeriod_H1  = 60,
   DataPeriod_H4  = 240,
   DataPeriod_D1  = 1440,
   DataPeriod_W1  = 10080,
   DataPeriod_MN1 = 43200
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum PosDirection
  {
   PosDirection_None,
   PosDirection_Long,
   PosDirection_Short,
   PosDirection_Closed
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum OrderDirection
  {
   OrderDirection_None,
   OrderDirection_Buy,
   OrderDirection_Sell
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum StrategyPriceType
  {
   StrategyPriceType_Open,
   StrategyPriceType_Close,
   StrategyPriceType_Indicator,
   StrategyPriceType_CloseAndReverse,
   StrategyPriceType_Unknown
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ExecutionTime
  {
   ExecutionTime_DuringTheBar,
   ExecutionTime_AtBarOpening,
   ExecutionTime_AtBarClosing,
   ExecutionTime_CloseAndReverse
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TraderOrderType
  {
   TraderOrderType_Buy       = 0,
   TraderOrderType_Sell      = 1,
   TraderOrderType_BuyLimit  = 2,
   TraderOrderType_SellLimit = 3,
   TraderOrderType_BuyStop   = 4,
   TraderOrderType_SellStop  = 5
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TradeDirection
  {
   TradeDirection_None,
   TradeDirection_Long,
   TradeDirection_Short,
   TradeDirection_Both
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum LongTradeEntryPrice
  {
   LongTradeEntryPrice_Bid,
   LongTradeEntryPrice_Ask,
   LongTradeEntryPrice_Chart
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum OperationType
  {
   OperationType_Buy,
   OperationType_Sell,
   OperationType_Close,
   OperationType_Modify
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TickType
  {
   TickType_Open       = 0,
   TickType_OpenClose  = 1,
   TickType_Regular    = 2,
   TickType_Close      = 3,
   TickType_AfterClose = 4
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum InstrumentType
  {
   InstrumentType_Forex,
   InstrumentType_CFD,
   InstrumentType_Index
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum SlotTypes
  {
   SlotTypes_NotDefined  = 0,
   SlotTypes_Open        = 1,
   SlotTypes_OpenFilter  = 2,
   SlotTypes_Close       = 4,
   SlotTypes_CloseFilter = 8
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum IndComponentType
  {
   IndComponentType_NotDefined,
   IndComponentType_OpenLongPrice,
   IndComponentType_OpenShortPrice,
   IndComponentType_OpenPrice,
   IndComponentType_CloseLongPrice,
   IndComponentType_CloseShortPrice,
   IndComponentType_ClosePrice,
   IndComponentType_OpenClosePrice,
   IndComponentType_IndicatorValue,
   IndComponentType_AllowOpenLong,
   IndComponentType_AllowOpenShort,
   IndComponentType_ForceCloseLong,
   IndComponentType_ForceCloseShort,
   IndComponentType_ForceClose,
   IndComponentType_Other
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum PositionPriceDependence
  {
   PositionPriceDependence_None,
   PositionPriceDependence_PriceBuyHigher,
   PositionPriceDependence_PriceBuyLower,
   PositionPriceDependence_PriceSellHigher,
   PositionPriceDependence_PriceSellLower,
   PositionPriceDependence_BuyHigherSellLower,
   PositionPriceDependence_BuyLowerSelHigher,// Deprecated
   PositionPriceDependence_BuyLowerSellHigher
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum BasePrice
  {
   BasePrice_Open     = 0,
   BasePrice_High     = 1,
   BasePrice_Low      = 2,
   BasePrice_Close    = 3,
   BasePrice_Median   = 4, // Price[bar] = (Low[bar] + High[bar]) / 2;
   BasePrice_Typical  = 5, // Price[bar] = (Low[bar] + High[bar] + Close[bar]) / 3;
   BasePrice_Weighted = 6  // Price[bar] = (Low[bar] + High[bar] + 2 * Close[bar]) / 4;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum MAMethod
  {
   MAMethod_Simple      = 0,
   MAMethod_Weighted    = 1,
   MAMethod_Exponential = 2,
   MAMethod_Smoothed    = 3
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum SameDirSignalAction
  {
   SameDirSignalAction_Nothing,
   SameDirSignalAction_Add,
   SameDirSignalAction_Winner,
   SameDirSignalAction_Loser,
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum OppositeDirSignalAction
  {
   OppositeDirSignalAction_Nothing,
   OppositeDirSignalAction_Reduce,
   OppositeDirSignalAction_Close,
   OppositeDirSignalAction_Reverse
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum PermanentProtectionType
  {
   PermanentProtectionType_Relative,
   PermanentProtectionType_Absolute
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TrailingStopMode
  {
   TrailingStopMode_Bar,
   TrailingStopMode_Tick
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum IndicatorLogic
  {
   IndicatorLogic_The_indicator_rises,
   IndicatorLogic_The_indicator_falls,
   IndicatorLogic_The_indicator_is_higher_than_the_level_line,
   IndicatorLogic_The_indicator_is_lower_than_the_level_line,
   IndicatorLogic_The_indicator_crosses_the_level_line_upward,
   IndicatorLogic_The_indicator_crosses_the_level_line_downward,
   IndicatorLogic_The_indicator_changes_its_direction_upward,
   IndicatorLogic_The_indicator_changes_its_direction_downward,
   IndicatorLogic_The_price_buy_is_higher_than_the_ind_value,
   IndicatorLogic_The_price_buy_is_lower_than_the_ind_value,
   IndicatorLogic_The_price_open_is_higher_than_the_ind_value,
   IndicatorLogic_The_price_open_is_lower_than_the_ind_value,
   IndicatorLogic_It_does_not_act_as_a_filter,
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum BandIndLogic
  {
   BandIndLogic_The_bar_opens_below_the_Upper_Band,
   BandIndLogic_The_bar_opens_above_the_Upper_Band,
   BandIndLogic_The_bar_opens_below_the_Lower_Band,
   BandIndLogic_The_bar_opens_above_the_Lower_Band,
   BandIndLogic_The_position_opens_below_the_Upper_Band,
   BandIndLogic_The_position_opens_above_the_Upper_Band,
   BandIndLogic_The_position_opens_below_the_Lower_Band,
   BandIndLogic_The_position_opens_above_the_Lower_Band,
   BandIndLogic_The_bar_opens_below_Upper_Band_after_above,
   BandIndLogic_The_bar_opens_above_Upper_Band_after_below,
   BandIndLogic_The_bar_opens_below_Lower_Band_after_above,
   BandIndLogic_The_bar_opens_above_Lower_Band_after_below,
   BandIndLogic_The_bar_closes_below_the_Upper_Band,
   BandIndLogic_The_bar_closes_above_the_Upper_Band,
   BandIndLogic_The_bar_closes_below_the_Lower_Band,
   BandIndLogic_The_bar_closes_above_the_Lower_Band,
   BandIndLogic_It_does_not_act_as_a_filter
  };
//+------------------------------------------------------------------+

bool LabelCreate(const long chart_ID = 0,              // chart's ID
                 const string name = "Label",          // label name
                 const int sub_window = 0,             // subwindow index
                 const int x = 0,                      // X coordinate
                 const int y = 0,                      // Y coordinate
                 const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER,// chart corner for anchoring
                 const string text = "Label",          // text
                 const string font = "Arial",          // font
                 const int font_size = 8,              // font size
                 const color clr = clrWhite,           // color
                 const double angle = 0.0,             // text slope
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER,// anchor type
                 const bool back = false,               // in the background
                 const bool selection = false,          // highlight to move
                 const bool hidden = true,              // hidden in the object list
                 const string tooltip = "\n",           // sets the tooltip
                 const long z_order = 0)                // priority for mouse click
  {
   ResetLastError();

   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,": failed to create text label! Error code = ",GetLastError());
      return (false);
     }

   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);

   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LabelTextChange(const long chart_ID,const string name,const string text)
  {
   ResetLastError();
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,": failed to change the text! Error code = ",GetLastError());
      return (false);
     }
   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LabelDelete(const long chart_ID=0,const string name="Label")
  {
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,": failed to delete a text label! Error code = ",GetLastError());
      return (false);
     }
   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color GetChartForeColor(const long chartId=0)
  {
   long foreColor=clrWhite;
   ChartGetInteger(chartId,CHART_COLOR_FOREGROUND,0,foreColor);
   return ((color) foreColor);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color GetChartBackColor(const long chartId=0)
  {
   long backColor=clrBlack;
   ChartGetInteger(chartId,CHART_COLOR_BACKGROUND,0,backColor);
   return ((color) backColor);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string LoadStringFromFile(string filename)
  {
   string text;
   int intSize;

   int handle= FileOpen(filename,FILE_TXT|FILE_READ|FILE_ANSI);
   if(handle == INVALID_HANDLE)
      return "";

   while(!FileIsEnding(handle))
     {
      intSize=FileReadInteger(handle,INT_VALUE);
      text+=FileReadString(handle,intSize);
     }

   FileClose(handle);
   return text;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SaveStringToFile(string filename,string text)
  {
   int handle= FileOpen(filename,FILE_TXT|FILE_WRITE|FILE_ANSI);
   if(handle == INVALID_HANDLE)
      return;

   FileWriteString(handle,text);
   FileClose(handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ArrayContainsString(const string &array[],string text)
  {
   for(int i=0; i<ArraySize(array); i++)
     {
      if(array[i]==text)
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrayAppendString(string &array[],string text)
  {
   int size=ArraySize(array);
   ArrayResize(array,size+1);
   array[size]=text;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string DataPeriodToString(DataPeriod period)
  {
   switch(period)
     {
      case DataPeriod_M1:  return ("M1");
      case DataPeriod_M5:  return ("M5");
      case DataPeriod_M15: return ("M15");
      case DataPeriod_M30: return ("M30");
      case DataPeriod_H1:  return ("H1");
      case DataPeriod_H4:  return ("H4");
      case DataPeriod_D1:  return ("D1");
      case DataPeriod_W1:  return ("W1");
      case DataPeriod_MN1: return ("MN1");
     }

   return ("D1");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
DataPeriod StringToDataPeriod(string period)
  {
   if(period == "M1")  return (DataPeriod_M1);
   if(period == "M5")  return (DataPeriod_M5);
   if(period == "M15") return (DataPeriod_M15);
   if(period == "M30") return (DataPeriod_M30);
   if(period == "H1")  return (DataPeriod_H1);
   if(period == "H4")  return (DataPeriod_H4);
   if(period == "D1")  return (DataPeriod_D1);
   if(period == "W1")  return (DataPeriod_W1);
   if(period == "MN1") return (DataPeriod_MN1);
   return (DataPeriod_D1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
DataPeriod EnumTimeFramesToPeriod(int period)
  {
   switch(period)
     {
      case PERIOD_M1:  return (DataPeriod_M1);
      case PERIOD_M5:  return (DataPeriod_M5);
      case PERIOD_M15: return (DataPeriod_M15);
      case PERIOD_M30: return (DataPeriod_M30);
      case PERIOD_H1:  return (DataPeriod_H1);
      case PERIOD_H4:  return (DataPeriod_H4);
      case PERIOD_D1:  return (DataPeriod_D1);
      case PERIOD_W1:  return (DataPeriod_W1);
      case PERIOD_MN1: return (DataPeriod_MN1);
     }
   return (DataPeriod_D1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetMAMethodsText(string &list[])
  {
   ArrayResize(list,4);
   list[0] = "Simple";
   list[1] = "Weighted";
   list[2] = "Exponential";
   list[3] = "Smoothed";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetBasePricesText(string &list[])
  {
   ArrayResize(list,8);
   list[0] = "Open";
   list[1] = "High";
   list[2] = "Low";
   list[3] = "Close";
   list[4] = "Median";
   list[5] = "Typical";
   list[6] = "Low";
   list[7] = "Weighted";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SameDirSignalActionToString(SameDirSignalAction action)
  {
   switch(action)
     {
      case SameDirSignalAction_Add:
         return ("Add");
      case SameDirSignalAction_Winner:
         return ("Winner");
      case SameDirSignalAction_Loser:
         return ("Loser");
      case SameDirSignalAction_Nothing:
         return ("Nothing");
     }
   return ("");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OppositeDirSignalActionToString(OppositeDirSignalAction action)
  {
   switch(action)
     {
      case OppositeDirSignalAction_Close:
         return ("Close");
      case OppositeDirSignalAction_Nothing:
         return ("Nothing");
      case OppositeDirSignalAction_Reduce:
         return ("Reduce");
      case OppositeDirSignalAction_Reverse:
         return ("Reverse");
     }
   return ("");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SlotTypeToString(SlotTypes slotType)
  {
   string stringCaptionText="Not Defined";
   switch(slotType)
     {
      case SlotTypes_Open:
         stringCaptionText="Opening Point of the Position";
         break;
      case SlotTypes_OpenFilter:
         stringCaptionText="Opening Logic Condition";
         break;
      case SlotTypes_Close:
         stringCaptionText="Closing Point of the Position";
         break;
      case SlotTypes_CloseFilter:
         stringCaptionText="Closing Logic Condition";
         break;
     }

   return (stringCaptionText);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SlotTypes SlotTypeFromShortString(string shortString)
  {
   if(shortString=="Open")
      return (SlotTypes_Open);
   if(shortString=="OpenFilter")
      return (SlotTypes_OpenFilter);
   if(shortString=="Close")
      return (SlotTypes_Close);
   if(shortString=="CloseFilter")
      return (SlotTypes_CloseFilter);

   return (SlotTypes_NotDefined);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool StringBoolToBool(string flag)
  {
   return (flag == "True" || flag == "true");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string StringRemoveWhite(string instring)
  {
   if(instring=="" || instring==NULL)
      return ("");
   string out=instring;
   string white[4]={" ","\r","\n","\t"};
   for(int i=0; i<ArraySize(white); i++)
     {
      StringReplace(out,white[i],"");
     }
   return (out);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ListString
  {
   int               m_count;
   string            m_data[];
public:
   void              Add(string element);
   bool              Contains(string element);
   int               Count();
   string            Get(int index);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ListString::Add(string element)
  {
   ArrayResize(m_data,m_count+1);
   m_data[m_count]=element;
   m_count++;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ListString::Contains(string element)
  {
   for(int i=0; i<m_count; i++)
     {
      if(m_data[i]==element)
         return (true);
     }
   return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ListString::Count()
  {
   return(m_count);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ListString::Get(int index)
  {
   return(m_data[index]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class DictStringBool
  {
   int               m_count;
   string            m_key[];
   bool              m_val[];
public:
   void              Add(string key,bool value);
   int               Count();
   bool              ContainsKey(string key);
   void              Set(string key,bool value);
   string            Key(int index);
   bool              Value(string key);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DictStringBool::Add(string key,bool value)
  {
   ArrayResize(m_key,m_count+1);
   ArrayResize(m_val,m_count+1);
   m_key[m_count] = key;
   m_val[m_count] = value;
   m_count++;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DictStringBool::Count()
  {
   return (m_count);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DictStringBool::ContainsKey(string key)
  {
   if(m_count==0)
      return (false);
   for(int i=0; i<m_count; i++)
     {
      if(m_key[i]==key)
         return (true);
     }
   return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DictStringBool::Set(string key,bool value)
  {
   for(int i=0; i<m_count; i++)
     {
      if(m_key[i]==key)
        {
         m_val[i]=value;
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string DictStringBool::Key(int index)
  {
   return(m_key[index]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DictStringBool::Value(string key)
  {
   for(int i=0; i<m_count; i++)
     {
      if(m_key[i]==key)
         return (m_val[i]);
     }

   Print("ERROR DictStringBool::Value: Geven key does not exist.");
   return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetFridayCloseHour(void)
  {
   datetime time[];
   int bars=CopyTime(_Symbol,PERIOD_H1,0,7*24,time);
   int fridayCloseHour=-1;

   for(int i=0;i<bars-1;i++)
     {
      MqlDateTime time0; TimeToStruct(time[i+0],time0);
      MqlDateTime time1; TimeToStruct(time[i+1],time1);
      if(time0.day_of_week==5 && time1.day_of_week!=5)
        {
         fridayCloseHour=time0.hour+1;
         PrintFormat("Detected Friday closing time: %d:00",fridayCloseHour);
         break;
        }
     }

   return (fridayCloseHour);
  }
//+------------------------------------------------------------------+

string GetErrorDescription(int errorCode)
  {
   string message;

   switch(errorCode)
     {
      //--- codes returned from trade server
      case 0:    message = "No error"; break;
      case 1:    message = "No error, trade conditions not changed"; break;
      case 2:    message = "Common error"; break;
      case 3:    message = "Invalid trade parameters"; break;
      case 4:    message = "Trade server is busy"; break;
      case 5:    message = "Old version of the client terminal"; break;
      case 6:    message = "No connection with trade server"; break;
      case 7:    message = "Not enough rights"; break;
      case 8:    message = "Too frequent requests"; break;
      case 9:    message = "Malfunctional trade operation (never returned error)"; break;
      case 64:   message = "Account disabled"; break;
      case 65:   message = "Invalid account"; break;
      case 128:  message = "Trade timeout"; break;
      case 129:  message = "Invalid price"; break;
      case 130:  message = "Invalid stops"; break;
      case 131:  message = "Invalid trade volume"; break;
      case 132:  message = "Market is closed"; break;
      case 133:  message = "Trade is disabled"; break;
      case 134:  message = "Not enough money"; break;
      case 135:  message = "Price changed"; break;
      case 136:  message = "Off quotes"; break;
      case 137:  message = "Broker is busy (never returned error)"; break;
      case 138:  message = "Requote"; break;
      case 139:  message = "Order is locked"; break;
      case 140:  message = "Long positions only allowed"; break;
      case 141:  message = "Too many requests"; break;
      case 145:  message = "Modification denied because order is too close to market"; break;
      case 146:  message = "Trade context is busy"; break;
      case 147:  message = "Expirations are denied by broker"; break;
      case 148:  message = "Amount of open and pending orders has reached the limit"; break;
      case 149:  message = "Hedging is prohibited"; break;
      case 150:  message = "Prohibited by FIFO rules"; break;
      //--- mql4 errors case 4000: message = "No error (never generated code)";
      case 4001: message = "Wrong function pointer"; break;
      case 4002: message = "Array index is out of range"; break;
      case 4003: message = "No memory for function call stack"; break;
      case 4004: message = "Recursive stack overflow"; break;
      case 4005: message = "Not enough stack for parameter"; break;
      case 4006: message = "No memory for parameter string"; break;
      case 4007: message = "No memory for temp string"; break;
      case 4008: message = "Non-initialized string"; break;
      case 4009: message = "Non-initialized string in array"; break;
      case 4010: message = "No memory for array string"; break;
      case 4011: message = "Too long string"; break;
      case 4012: message = "Remainder from zero divide"; break;
      case 4013: message = "Zero divide"; break;
      case 4014: message = "Unknown command"; break;
      case 4015: message = "Wrong jump (never generated error)"; break;
      case 4016: message = "Non-initialized array"; break;
      case 4017: message = "Dll calls are not allowed"; break;
      case 4018: message = "Cannot load library"; break;
      case 4019: message = "Cannot call function"; break;
      case 4020: message = "Expert function calls are not allowed"; break;
      case 4021: message = "Not enough memory for temp string returned from function"; break;
      case 4022: message = "System is busy (never generated error)"; break;
      case 4023: message = "Dll-function call critical error"; break;
      case 4024: message = "Internal error"; break;
      case 4025: message = "Out of memory"; break;
      case 4026: message = "Invalid pointer"; break;
      case 4027: message = "Too many formatters in the format function"; break;
      case 4028: message = "Parameters count is more than formatters count"; break;
      case 4029: message = "Invalid array"; break;
      case 4030: message = "No reply from chart"; break;
      case 4050: message = "Invalid function parameters count"; break;
      case 4051: message = "Invalid function parameter value"; break;
      case 4052: message = "String function internal error"; break;
      case 4053: message = "Some array error"; break;
      case 4054: message = "Incorrect series array usage"; break;
      case 4055: message = "Custom indicator error"; break;
      case 4056: message = "Arrays are incompatible"; break;
      case 4057: message = "Global variables processing error"; break;
      case 4058: message = "Global variable not found"; break;
      case 4059: message = "Function is not allowed in testing mode"; break;
      case 4060: message = "Function is not confirmed"; break;
      case 4061: message = "Send mail error"; break;
      case 4062: message = "String parameter expected"; break;
      case 4063: message = "Integer parameter expected"; break;
      case 4064: message = "Double parameter expected"; break;
      case 4065: message = "Array as parameter expected"; break;
      case 4066: message = "Requested history data is in update state"; break;
      case 4067: message = "Internal trade error"; break;
      case 4068: message = "Resource not found"; break;
      case 4069: message = "Resource not supported"; break;
      case 4070: message = "Duplicate resource"; break;
      case 4071: message = "Cannot initialize custom indicator"; break;
      case 4072: message = "Cannot load custom indicator"; break;
      case 4073: message = "No history data"; break;
      case 4074: message = "No memory for history data"; break;
      case 4099: message = "End of file"; break;
      case 4100: message = "Some file error"; break;
      case 4101: message = "Wrong file name"; break;
      case 4102: message = "Too many opened files"; break;
      case 4103: message = "Cannot open file"; break;
      case 4104: message = "Incompatible access to a file"; break;
      case 4105: message = "No order selected"; break;
      case 4106: message = "Unknown symbol"; break;
      case 4107: message = "Invalid price parameter for trade function"; break;
      case 4108: message = "Invalid ticket"; break;
      case 4109: message = "Trade is not allowed in the expert properties"; break;
      case 4110: message = "Longs are not allowed in the expert properties"; break;
      case 4111: message = "Shorts are not allowed in the expert properties"; break;
      case 4200: message = "Object already exists"; break;
      case 4201: message = "Unknown object property"; break;
      case 4202: message = "Object does not exist"; break;
      case 4203: message = "Unknown object type"; break;
      case 4204: message = "No object name"; break;
      case 4205: message = "Object coordinates error"; break;
      case 4206: message = "No specified subwindow"; break;
      case 4207: message = "Graphical object error"; break;
      case 4210: message = "Unknown chart property"; break;
      case 4211: message = "Chart not found"; break;
      case 4212: message = "Chart subwindow not found"; break;
      case 4213: message = "Chart indicator not found"; break;
      case 4220: message = "Symbol select error"; break;
      case 4250: message = "Notification error"; break;
      case 4251: message = "Notification parameter error"; break;
      case 4252: message = "Notifications disabled"; break;
      case 4253: message = "Notification send too frequent"; break;
      case 5001: message = "Too many opened files"; break;
      case 5002: message = "Wrong file name"; break;
      case 5003: message = "Too long file name"; break;
      case 5004: message = "Cannot open file"; break;
      case 5005: message = "Text file buffer allocation error"; break;
      case 5006: message = "Cannot delete file"; break;
      case 5007: message = "Invalid file handle (file closed or was not opened)"; break;
      case 5008: message = "Wrong file handle (handle index is out of handle table)"; break;
      case 5009: message = "File must be opened with FILE_WRITE flag"; break;
      case 5010: message = "File must be opened with FILE_READ flag"; break;
      case 5011: message = "File must be opened with FILE_BIN flag"; break;
      case 5012: message = "File must be opened with FILE_TXT flag"; break;
      case 5013: message = "File must be opened with FILE_TXT or FILE_CSV flag"; break;
      case 5014: message = "File must be opened with FILE_CSV flag"; break;
      case 5015: message = "File read error"; break;
      case 5016: message = "File write error"; break;
      case 5017: message = "String size must be specified for binary file"; break;
      case 5018: message = "Incompatible file (for string arrays-TXT, for others-BIN)"; break;
      case 5019: message = "File is directory, not file"; break;
      case 5020: message = "File does not exist"; break;
      case 5021: message = "File cannot be rewritten"; break;
      case 5022: message = "Wrong directory name"; break;
      case 5023: message = "Directory does not exist"; break;
      case 5024: message = "Specified file is not directory"; break;
      case 5025: message = "Cannot delete directory"; break;
      case 5026: message = "Cannot clean directory"; break;
      case 5027: message = "Array resize error"; break;
      case 5028: message = "String resize error"; break;
      case 5029: message = "Structure contains strings or dynamic arrays"; break;
      default:   message = "Unknown error"; break;
     }

   return (message);
  }
//+------------------------------------------------------------------+

class DataSet
  {
public:
   // Constructor
                     DataSet(string chart);

   // Properties
   string            Chart;
   string            Symbol;
   DataPeriod        Period;

   int               LotSize;
   double            Spread;
   int               Digits;
   double            Point;
   double            Pip;
   bool              IsFiveDigits;
   int               StopLevel;
   double            TickValue;
   double            MinLot;
   double            MaxLot;
   double            LotStep;
   double            MarginRequired;

   int               Bars;

   datetime          ServerTime;
   double            Bid;
   double            Ask;

   datetime          Time[];
   double            Open[];
   double            High[];
   double            Low[];
   double            Close[];
   long              Volume[];

   // Methods
   void              SetPrecision(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DataSet::DataSet(string chart)
  {
   Chart=chart;
   string parts[];
   StringSplit(chart,',',parts);
   Symbol = parts[0];
   Period = StringToDataPeriod(parts[1]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DataSet::SetPrecision(void)
  {
   IsFiveDigits=(Digits==3 || Digits==5);
   Point=1/MathPow(10,Digits);
   Pip=IsFiveDigits ? (10*Point) : Point;
  }
//+------------------------------------------------------------------+

class DataMarket
  {
public:
   string            Symbol;
   DataPeriod        Period;

   bool              IsNewBid;

   double            OldBid;
   double            OldAsk;
   double            OldClose;
   double            Bid;
   double            Ask;
   double            Close;
   long              Volume;

   datetime          TickLocalTime;
   datetime          TickServerTime;
   datetime          BarTime;

   double            AccountBalance;
   double            AccountEquity;
   double            AccountFreeMargin;

   double            PositionLots;
   double            PositionOpenPrice;
   datetime          PositionOpenTime;
   double            PositionStopLoss;
   double            PositionTakeProfit;
   double            PositionProfit;
   PosDirection      PositionDirection;

   int               ConsecutiveLosses;
   int               WrongStopLoss;
   int               WrongTakeProf;
   int               WrongStopsRetry;
   bool              IsFailedCloseOrder;
   int               CloseOrderTickCounter;
   bool              IsSentCloseOrder;

   int               LotSize;
   double            Spread;
   double            Point;
   int               StopLevel;
   double            TickValue;
   double            MinLot;
   double            MaxLot;
   double            LotStep;
   double            MarginRequired;
  };
//+------------------------------------------------------------------+

class IndicatorComp
  {
public:
   // Constructors
                     IndicatorComp();

   // Properties
   string            CompName;
   int               FirstBar;
   int               UsePreviousBar; // Deprecated
   IndComponentType  DataType;
   PositionPriceDependence PosPriceDependence;
   bool              ShowInDynInfo;
   double            Value[];

   // Methods
   double            GetLastValue(int indexFromEnd);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IndicatorComp::IndicatorComp()
  {
   CompName           = "Not defined";
   DataType           = IndComponentType_NotDefined;
   FirstBar           = 0;
   UsePreviousBar     = 0;
   ShowInDynInfo      = true;
   PosPriceDependence = PositionPriceDependence_None;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double IndicatorComp::GetLastValue(int indexFromEnd=0)
  {
   int bars=ArraySize(Value);
   double lastValue=(bars>indexFromEnd) ? Value[bars-indexFromEnd-1]: 0;
   return (lastValue);
  }
//+------------------------------------------------------------------+

class ListParameter
  {
public:
   // Constructors
   ListParameter()
     {
      Caption = "";
      Text    = "";
      Index   = -1;
      Enabled = false;
     }

   // Properties
   string            Caption;
   string            Text;
   int               Index;
   bool              Enabled;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class NumericParameter
  {
public:
   // Constructor
   NumericParameter()
     {
      Caption = "";
      Value   = 0;
      Enabled = false;
     }

   // Properties
   string            Caption;
   double            Value;
   bool              Enabled;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CheckParameter
  {
public:
   // Constructor
   CheckParameter()
     {
      Caption = "";
      Checked = false;
      Enabled = false;
     }

   // Properties
   string            Caption;
   bool              Checked;
   bool              Enabled;
  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Indicator
  {
protected:
   double            Sigma(void);

   double            Epsilon(void);

   void              NormalizeComponentValue(const double &componentValue[],const datetime &strategyTime[],
                                             int ltfShift,bool isCloseFilterShift,double &output[]);

   int               NormalizeComponentFirstBar(int componentFirstBar,datetime &strategyTime[]);

   bool              IsSignalComponent(IndComponentType componentType);

   void              Price(BasePrice priceType,double &price[]);

   void              MovingAverage(int period,int shift,MAMethod maMethod,const double &source[],double &movingAverage[]);

   void              OscillatorLogic(int firstBar,int previous,const double &adIndValue[],double levelLong,double levelShort,
                                     IndicatorComp &indCompLong,IndicatorComp &indCompShort,IndicatorLogic indLogic);

   void              NoDirectionOscillatorLogic(int firstBar,int previous,const double &adIndValue[],double dLevel,
                                                IndicatorComp &indComp,IndicatorLogic indLogic);

   void              BandIndicatorLogic(int firstBar,int previous,const double &adUpperBand[],const double &adLowerBand[],
                                        IndicatorComp &indCompLong,IndicatorComp &indCompShort,BandIndLogic indLogic);

   void              IndicatorRisesLogic(int firstBar,int previous,const double &adIndValue[],IndicatorComp &indCompLong,
                                         IndicatorComp &indCompShort);

   void              IndicatorFallsLogic(int firstBar,int previous,const double &adIndValue[],IndicatorComp &indCompLong,
                                         IndicatorComp &indCompShort);

   void              IndicatorChangesItsDirectionUpward(int firstBar,int previous,double &adIndValue[],
                                                        IndicatorComp &indCompLong,IndicatorComp &indCompShort);

   void              IndicatorChangesItsDirectionDownward(int firstBar,int previous,double &adIndValue[],
                                                          IndicatorComp &indCompLong,IndicatorComp &indCompShort);

   void              IndicatorIsHigherThanAnotherIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                                                double &adAnotherIndValue[],IndicatorComp &indCompLong,
                                                                IndicatorComp &indCompShort);

   void              IndicatorIsLowerThanAnotherIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                                               double &adAnotherIndValue[],IndicatorComp &indCompLong,
                                                               IndicatorComp &indCompShort);

   void              IndicatorCrossesAnotherIndicatorUpwardLogic(int firstBar,int previous,const double &adIndValue[],
                                                                 double &adAnotherIndValue[],IndicatorComp &indCompLong,
                                                                 IndicatorComp &indCompShort);

   void              IndicatorCrossesAnotherIndicatorDownwardLogic(int firstBar,int previous,const double &adIndValue[],
                                                                   double &adAnotherIndValue[],IndicatorComp &indCompLong,
                                                                   IndicatorComp &indCompShort);

   void              BarOpensAboveIndicatorLogic(int firstBar,int previous,const double &adIndValue[],IndicatorComp &indCompLong,
                                                 IndicatorComp &indCompShort);

   void              BarOpensBelowIndicatorLogic(int firstBar,int previous,const double &adIndValue[],IndicatorComp &indCompLong,
                                                 IndicatorComp &indCompShort);

   void              BarOpensAboveIndicatorAfterOpeningBelowLogic(int firstBar,int previous,const double &adIndValue[],
                                                                  IndicatorComp &indCompLong,IndicatorComp &indCompShort);

   void              BarOpensBelowIndicatorAfterOpeningAboveLogic(int firstBar,int previous,const double &adIndValue[],
                                                                  IndicatorComp &indCompLong,IndicatorComp &indCompShort);

   void              BarClosesAboveIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                                  IndicatorComp &indCompLong,IndicatorComp &indCompShort);

   void              BarClosesBelowIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                                  IndicatorComp &indCompLong,IndicatorComp &indCompShort);

public:
   // Constructors
                     Indicator(void);

                    ~Indicator(void);

   // Properties
   string            IndicatorName;
   string            WarningMessage;
   bool              IsDiscreteValues;
   bool              UsePreviousBarValue; // Important! Otdated Do not use.
   bool              IsSeparateChart;
   bool              IsBacktester;
   bool              IsDeafultGroupAll; // Important! Outdated. Do not use.
   bool              IsDefaultGroupAll;
   bool              IsAllowLTF;

   SlotTypes         SlotType;
   ExecutionTime     ExecTime;

   ListParameter    *ListParam[5];
   NumericParameter *NumParam[6];
   CheckParameter   *CheckParam[2];

   IndicatorComp    *Component[10];
   DataSet          *Data;

   // Methods
   virtual void      Calculate(DataSet &dataSet);
   void              NormalizeComponents(DataSet &strategyDataSet,int ltfShift,bool isCloseFilterShift);
   void              ShiftSignal(int shift);
   void              RepeatSignal(int repeat);
   int               Components(void);
   string            IndicatorParamToString(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Indicator::Indicator(void)
  {
   IndicatorName="";

   IsBacktester      = false;
   IsDiscreteValues  = false;
   IsSeparateChart   = false;
   IsDeafultGroupAll = false;
   IsDefaultGroupAll = false;
   IsAllowLTF        = true;

   SlotType = SlotTypes_NotDefined;
   ExecTime = ExecutionTime_DuringTheBar;

   for(int i=0; i<5; i++)
      ListParam[i]=new ListParameter();

   for(int i=0; i<6; i++)
      NumParam[i]=new NumericParameter();

   for(int i=0; i<2; i++)
      CheckParam[i]=new CheckParameter();

   for(int i=0; i<10; i++)
      Component[i]=new IndicatorComp();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Indicator::~Indicator(void)
  {
   for(int i=0; i<5; i++)
      delete ListParam[i];

   for(int i=0; i<6; i++)
      delete NumParam[i];

   for(int i=0; i<2; i++)
      delete CheckParam[i];

   for(int i=0; i<10; i++)
      delete Component[i];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::Calculate(DataSet &dataSet)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::NormalizeComponents(DataSet &strategyDataSet,int ltfShift,bool isCloseFilterShift)
  {
   for(int i=0; i<Components(); i++)
     {
      if(Component[i].PosPriceDependence!=PositionPriceDependence_None)
         ltfShift=1;

      double value[];
      NormalizeComponentValue(Component[i].Value,strategyDataSet.Time,ltfShift,isCloseFilterShift,value);
      ArrayCopy(Component[i].Value,value);
      Component[i].FirstBar=NormalizeComponentFirstBar(Component[i].FirstBar,strategyDataSet.Time);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::ShiftSignal(int shift)
  {
   for(int i=0; i<Components(); i++)
     {
      if(!IsSignalComponent(Component[i].DataType))
         continue;
      int bars=ArraySize(Component[i].Value);
      double value[];
      ArrayResize(value,bars);
      ArrayInitialize(value,0);
      ArrayCopy(value,Component[i].Value,shift,0,WHOLE_ARRAY);
      for(int bar=0; bar<bars; bar++)
         Component[i].Value[bar]=value[bar];
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::RepeatSignal(int repeat)
  {
   for(int i=0; i<Components(); i++)
     {
      if(!IsSignalComponent(Component[i].DataType))
         continue;
      int bars=ArraySize(Component[i].Value);
      for(int bar=0; bar<bars; bar++)
        {
         if(Component[i].Value[bar]<0.5)
            continue;
         for(int r=1; r<=repeat; r++)
            if(++bar<bars)
               Component[i].Value[bar]=1;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Indicator::NormalizeComponentValue(const double &componentValue[],const datetime &strategyTime[],
                                   int ltfShift,bool isCloseFilterShift,double &output[])
  {
   int strategyBars=ArraySize(strategyTime);
   ArrayResize(output,strategyBars); ArrayInitialize(output,0);
   int reachedBar=0;
   datetime strategyPeriodMinutes=strategyTime[1]-strategyTime[0];

   for(int ltfBar=ltfShift; ltfBar<Data.Bars; ltfBar++)
     {
      datetime ltfOpenTime=Data.Time[ltfBar];
      datetime ltfCloseTime=ltfOpenTime+((int) Data.Period)*60;

      for(int bar=reachedBar; bar<strategyBars; bar++)
        {
         reachedBar=bar;
         datetime time=strategyTime[bar];
         datetime barCloseTime=time+strategyPeriodMinutes;

         if(isCloseFilterShift && barCloseTime==ltfCloseTime)
           {
            output[bar]=componentValue[ltfBar];
           }
         else
           {
            if(time>=ltfOpenTime && time<ltfCloseTime)
               output[bar]=componentValue[ltfBar-ltfShift];
            else if(time>=ltfCloseTime)
                          break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Indicator::NormalizeComponentFirstBar(int componentFirstBar,datetime &strategyTime[])
  {
   datetime firstBarTime=Data.Time[componentFirstBar];
   for(int bar=0; bar<ArraySize(strategyTime); bar++)
      if(strategyTime[bar]>=firstBarTime)
         return bar;
   return componentFirstBar;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Indicator::IsSignalComponent(IndComponentType componentType)
  {
   return
   componentType == IndComponentType_AllowOpenLong   ||
   componentType == IndComponentType_AllowOpenShort  ||
   componentType == IndComponentType_CloseLongPrice  ||
   componentType == IndComponentType_ClosePrice      ||
   componentType == IndComponentType_CloseShortPrice ||
   componentType == IndComponentType_ForceClose      ||
   componentType == IndComponentType_ForceCloseLong  ||
   componentType == IndComponentType_ForceCloseShort ||
   componentType == IndComponentType_OpenClosePrice  ||
   componentType == IndComponentType_OpenLongPrice   ||
   componentType == IndComponentType_OpenPrice       ||
   componentType == IndComponentType_OpenShortPrice;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Indicator::Components(void)
  {
   for(int i=0; i<10; i++)
      if(Component[i].DataType==IndComponentType_NotDefined)
         return (i);
   return (10);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Indicator::IndicatorParamToString(void)
  {
   string text;

   for(int i=0; i<5; i++)
      if(ListParam[i].Enabled)
         text+=StringFormat("%s: %s\n",ListParam[i].Caption,ListParam[i].Text);

   for(int i=0; i<6; i++)
      if(NumParam[i].Enabled)
         text+=StringFormat("%s: %g\n",NumParam[i].Caption,NumParam[i].Value);

   for(int i=0; i<2; i++)
      if(CheckParam[i].Enabled)
         text+=StringFormat("%s: %s\n",CheckParam[i].Caption,(CheckParam[i].Checked ? "Yes" : "No"));

   return (text);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::Price(BasePrice priceType,double &price[])
  {
   ArrayResize(price,Data.Bars);
   ArrayInitialize(price,0);

   switch(priceType)
     {
      case BasePrice_Open:
         ArrayCopy(price,Data.Open);
         break;
      case BasePrice_High:
         ArrayCopy(price,Data.High);
         break;
      case BasePrice_Low:
         ArrayCopy(price,Data.Low);
         break;
      case BasePrice_Close:
         ArrayCopy(price,Data.Close);
         break;
      case BasePrice_Median:
         for(int bar=0; bar<Data.Bars; bar++)
         price[bar]=(Data.Low[bar]+Data.High[bar])/2;
         break;
      case BasePrice_Typical:
         for(int bar=0; bar<Data.Bars; bar++)
         price[bar]=(Data.Low[bar]+Data.High[bar]+Data.Close[bar])/3;
         break;
      case BasePrice_Weighted:
         for(int bar=0; bar<Data.Bars; bar++)
         price[bar]=(Data.Low[bar]+Data.High[bar]+2*Data.Close[bar])/4;
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::MovingAverage(int period,int shift,MAMethod maMethod,const double &source[],double &movingAverage[])
  {
   int bars=ArraySize(source);
   ArrayResize(movingAverage,bars);
   ArrayInitialize(movingAverage,0);

   if(period<=1 && shift==0)
     {
      // There is no smoothing
      ArrayCopy(movingAverage,source);
      return;
     }

   if(period>bars || period+shift<=0 || period+shift>bars)
     {
      // Error in the parameters
      string message=IndicatorName+" "+Data.Symbol+" "+DataPeriodToString(Data.Period)+
                     "Wrong MovingAverage parameters(Period: "+IntegerToString(period)+
                     ", Shift: "+IntegerToString(shift)+
                     ", Source bars: "+IntegerToString(bars)+")";
      Print(message);
      ArrayCopy(movingAverage,source);
      return;
     }

   for(int bar=0; bar<period+shift-1; bar++)
      movingAverage[bar]=0;

   double sum=0;
   for(int bar=0; bar<period; bar++)
      sum+=source[bar];

   movingAverage[period+shift-1]=sum/period;
   int lastBar=MathMin(bars,bars-shift);

   switch(maMethod)
     {
      case MAMethod_Simple:
        {
         for(int bar=period; bar<lastBar; bar++)
            movingAverage[bar+shift]=movingAverage[bar+shift-1]+source[bar]/period -
                                     source[bar-period]/period;
        }
      break;
      case MAMethod_Exponential:
        {
         double pr=2.0/(period+1);
         for(int bar=period; bar<lastBar; bar++)
            movingAverage[bar+shift]=source[bar] *pr+movingAverage[bar+shift-1]*(1-pr);
        }
      break;
      case MAMethod_Weighted:
        {
         double weight=period *(period+1)/2.0;
         for(int bar=period; bar<lastBar; bar++)
           {
            sum=0;
            for(int i=0; i<period; i++)
               sum+=source[bar-i]*(period-i);
            movingAverage[bar+shift]=sum/weight;
           }
        }
      break;
      case MAMethod_Smoothed:
        {
         for(int bar=period; bar<lastBar; bar++)
            movingAverage[bar+shift]=(movingAverage[bar+shift-1]*(period-1)+
                                      source[bar])/period;
        }
      break;
      default:
         break;
     }

   for(int bar=bars+shift; bar<bars; bar++)
      movingAverage[bar]=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Indicator::Sigma(void)
  {
   return (IsSeparateChart ? 0.000005 : Data.Point * 0.5);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Indicator::Epsilon(void)
  {
   return (0.0000001);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::OscillatorLogic(int firstBar,int previous,const double &adIndValue[],double levelLong,
                                double levelShort,IndicatorComp &indCompLong,IndicatorComp &indCompShort,
                                IndicatorLogic indLogic)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]=0;
      indCompShort.Value[bar]=0;
     }

   switch(indLogic)
     {
      case IndicatorLogic_The_indicator_rises:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int currentBar=bar-previous;
            int baseBar=currentBar-1;
            bool isHigher=adIndValue[currentBar]>adIndValue[baseBar];

            if(!IsDiscreteValues) // Aroon oscillator uses IsDiscreteValues = true
              {
               bool isNoChange=true;
               while(MathAbs(adIndValue[currentBar]-adIndValue[baseBar])<sigma && 
                     isNoChange && baseBar>firstBar)
                 {
                  isNoChange=(isHigher==(adIndValue[baseBar+1]>adIndValue[baseBar]));
                  baseBar--;
                 }
              }

            indCompLong.Value[bar]  = adIndValue[baseBar] < adIndValue[currentBar] - sigma ? 1 : 0;
            indCompShort.Value[bar] = adIndValue[baseBar] > adIndValue[currentBar] + sigma ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_falls:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int  currentBar = bar - previous;
            int  baseBar    = currentBar - 1;
            bool isHigher   = adIndValue[currentBar] > adIndValue[baseBar];

            if(!IsDiscreteValues) // Aroon oscillator uses IsDiscreteValues = true
              {
               bool isNoChange=true;
               while(MathAbs(adIndValue[currentBar]-adIndValue[baseBar])<sigma && isNoChange && 
                     baseBar>firstBar)
                 {
                  isNoChange=(isHigher==(adIndValue[baseBar+1]>adIndValue[baseBar]));
                  baseBar--;
                 }
              }

            indCompLong.Value[bar]  = adIndValue[baseBar] > adIndValue[currentBar] + sigma ? 1 : 0;
            indCompShort.Value[bar] = adIndValue[baseBar] < adIndValue[currentBar] - sigma ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_is_higher_than_the_level_line:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = adIndValue[bar - previous] > levelLong + sigma  ? 1 : 0;
            indCompShort.Value[bar] = adIndValue[bar - previous] < levelShort - sigma ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_is_lower_than_the_level_line:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = adIndValue[bar - previous] < levelLong - sigma  ? 1 : 0;
            indCompShort.Value[bar] = adIndValue[bar - previous] > levelShort + sigma ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_crosses_the_level_line_upward:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int baseBar=bar-previous-1;
            while(MathAbs(adIndValue[baseBar]-levelLong)<sigma && baseBar>firstBar)
               baseBar--;

            indCompLong.Value[bar]=(adIndValue[baseBar]<levelLong-sigma && 
                                    adIndValue[bar-previous]>levelLong+sigma) ? 1 : 0;
            indCompShort.Value[bar]=(adIndValue[baseBar]>levelShort+sigma && 
                                     adIndValue[bar-previous]<levelShort-sigma) ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_crosses_the_level_line_downward:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int baseBar=bar-previous-1;
            while(MathAbs(adIndValue[baseBar]-levelLong)<sigma && baseBar>firstBar)
               baseBar--;

            indCompLong.Value[bar]=(adIndValue[baseBar]>levelLong+sigma && 
                                    adIndValue[bar-previous]<levelLong-sigma) ? 1 : 0;
            indCompShort.Value[bar]=(adIndValue[baseBar]<levelShort-sigma && 
                                     adIndValue[bar-previous]>levelShort+sigma) ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_changes_its_direction_upward:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int bar0 = bar - previous;
            int bar1 = bar0 - 1;
            while(MathAbs(adIndValue[bar0]-adIndValue[bar1])<sigma && bar1>firstBar)
               bar1--;

            int iBar2=bar1-1>firstBar ? bar1-1 : firstBar;
            while(MathAbs(adIndValue[bar1]-adIndValue[iBar2])<sigma && iBar2>firstBar)
               iBar2--;

            indCompLong.Value[bar]=(adIndValue[iBar2]>adIndValue[bar1] && adIndValue[bar1]<adIndValue[bar0] && 
                                    bar1==bar0-1) ? 1 : 0;
            indCompShort.Value[bar]=(adIndValue[iBar2]<adIndValue[bar1] && 
                                     adIndValue[bar1]>adIndValue[bar0] && bar1==bar0-1) ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_changes_its_direction_downward:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int bar0 = bar - previous;
            int bar1 = bar0 - 1;
            while(MathAbs(adIndValue[bar0]-adIndValue[bar1])<sigma && bar1>firstBar)
               bar1--;

            int iBar2=bar1-1>firstBar ? bar1-1 : firstBar;
            while(MathAbs(adIndValue[bar1]-adIndValue[iBar2])<sigma && iBar2>firstBar)
               iBar2--;

            indCompLong.Value[bar]=(adIndValue[iBar2]<adIndValue[bar1] && adIndValue[bar1]>adIndValue[bar0] && 
                                    bar1==bar0-1) ? 1 : 0;
            indCompShort.Value[bar]=(adIndValue[iBar2]>adIndValue[bar1] && 
                                     adIndValue[bar1]<adIndValue[bar0] && bar1==bar0-1) ? 1 : 0;
           }
         break;

      default:
         return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::NoDirectionOscillatorLogic(int firstBar,int previous,const double &adIndValue[],double dLevel,
                                           IndicatorComp &indComp,IndicatorLogic indLogic)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
      indComp.Value[bar]=0;

   switch(indLogic)
     {
      case IndicatorLogic_The_indicator_rises:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int  currentBar = bar - previous;
            int  baseBar    = currentBar - 1;
            bool isHigher   = adIndValue[currentBar] > adIndValue[baseBar];
            bool isNoChange = true;

            while(MathAbs(adIndValue[currentBar]-adIndValue[baseBar])<sigma && isNoChange && baseBar>firstBar)
              {
               isNoChange=(isHigher==(adIndValue[baseBar+1]>adIndValue[baseBar]));
               baseBar--;
              }

            indComp.Value[bar]=adIndValue[baseBar]<adIndValue[currentBar]-sigma ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_falls:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int  currentBar = bar - previous;
            int  baseBar    = currentBar - 1;
            bool isHigher   = adIndValue[currentBar] > adIndValue[baseBar];
            bool isNoChange = true;

            while(MathAbs(adIndValue[currentBar]-adIndValue[baseBar])<sigma && isNoChange && baseBar>firstBar)
              {
               isNoChange=(isHigher==(adIndValue[baseBar+1]>adIndValue[baseBar]));
               baseBar--;
              }

            indComp.Value[bar]=adIndValue[baseBar]>adIndValue[currentBar]+sigma ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_is_higher_than_the_level_line:
         for(int bar=firstBar; bar<Data.Bars; bar++)
         indComp.Value[bar]=adIndValue[bar-previous]>dLevel+sigma ? 1 : 0;
         break;

      case IndicatorLogic_The_indicator_is_lower_than_the_level_line:
         for(int bar=firstBar; bar<Data.Bars; bar++)
         indComp.Value[bar]=adIndValue[bar-previous]<dLevel-sigma ? 1 : 0;
         break;

      case IndicatorLogic_The_indicator_crosses_the_level_line_upward:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int baseBar=bar-previous-1;
            while(MathAbs(adIndValue[baseBar]-dLevel)<sigma && baseBar>firstBar)
               baseBar--;

            indComp.Value[bar]=(adIndValue[baseBar]<dLevel-sigma && 
                                adIndValue[bar-previous]>dLevel+sigma)
            ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_crosses_the_level_line_downward:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int baseBar=bar-previous-1;
            while(MathAbs(adIndValue[baseBar]-dLevel)<sigma && baseBar>firstBar)
               baseBar--;

            indComp.Value[bar]=(adIndValue[baseBar]>dLevel+sigma && 
                                adIndValue[bar-previous]<dLevel-sigma) ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_changes_its_direction_upward:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int bar0 = bar - previous;
            int bar1 = bar0 - 1;
            while(MathAbs(adIndValue[bar0]-adIndValue[bar1])<sigma && bar1>firstBar)
               bar1--;

            int bar2=bar1-1>firstBar ? bar1-1 : firstBar;
            while(MathAbs(adIndValue[bar1]-adIndValue[bar2])<sigma && bar2>firstBar)
               bar2--;

            indComp.Value[bar]=(adIndValue[bar2]>adIndValue[bar1] && adIndValue[bar1]<adIndValue[bar0] && 
                                bar1==bar0-1) ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_changes_its_direction_downward:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int bar0 = bar - previous;
            int bar1 = bar0 - 1;
            while(MathAbs(adIndValue[bar0]-adIndValue[bar1])<sigma && bar1>firstBar)
               bar1--;

            int bar2=bar1-1>firstBar ? bar1-1 : firstBar;
            while(MathAbs(adIndValue[bar1]-adIndValue[bar2])<sigma && bar2>firstBar)
               bar2--;

            indComp.Value[bar]=(adIndValue[bar2]<adIndValue[bar1] && adIndValue[bar1]>adIndValue[bar0] && 
                                bar1==bar0-1) ? 1 : 0;
           }
         break;

      default:
         return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::BandIndicatorLogic(int firstBar,int previous,const double &adUpperBand[],const double &adLowerBand[],
                                   IndicatorComp &indCompLong,IndicatorComp &indCompShort,BandIndLogic indLogic)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]  = 0;
      indCompShort.Value[bar] = 0;
     }

   switch(indLogic)
     {
      case BandIndLogic_The_bar_opens_below_the_Upper_Band:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = Data.Open[bar] < adUpperBand[bar - previous] - sigma ? 1 : 0;
            indCompShort.Value[bar] = Data.Open[bar] > adLowerBand[bar - previous] + sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_opens_above_the_Upper_Band:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = Data.Open[bar] > adUpperBand[bar - previous] + sigma ? 1 : 0;
            indCompShort.Value[bar] = Data.Open[bar] < adLowerBand[bar - previous] - sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_opens_below_the_Lower_Band:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = Data.Open[bar] < adLowerBand[bar - previous] - sigma ? 1 : 0;
            indCompShort.Value[bar] = Data.Open[bar] > adUpperBand[bar - previous] + sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_opens_above_the_Lower_Band:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = Data.Open[bar] > adLowerBand[bar - previous] + sigma ? 1 : 0;
            indCompShort.Value[bar] = Data.Open[bar] < adUpperBand[bar - previous] - sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_opens_below_Upper_Band_after_above:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int baseBar=bar-1;
            while(MathAbs(Data.Open[baseBar]-adUpperBand[baseBar-previous])<sigma && baseBar>firstBar)
               baseBar--;

            indCompLong.Value[bar]=Data.Open[bar]<adUpperBand[bar-previous]-sigma && 
                                   Data.Open[baseBar]>adUpperBand[baseBar-previous]+sigma ? 1 : 0;

            baseBar=bar-1;
            while(MathAbs(Data.Open[baseBar]-adLowerBand[baseBar-previous])<sigma && baseBar>firstBar)
               baseBar--;

            indCompShort.Value[bar]=Data.Open[bar]>adLowerBand[bar-previous]+sigma && 
                                    Data.Open[baseBar]<adLowerBand[baseBar-previous]-sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_opens_above_Upper_Band_after_below:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int baseBar=bar-1;
            while(MathAbs(Data.Open[baseBar]-adUpperBand[baseBar-previous])<sigma && baseBar>firstBar)
               baseBar--;

            indCompLong.Value[bar]=Data.Open[bar]>adUpperBand[bar-previous]+sigma && 
                                   Data.Open[baseBar]<adUpperBand[baseBar-previous]-sigma ? 1 : 0;

            baseBar=bar-1;
            while(MathAbs(Data.Open[baseBar]-adLowerBand[baseBar-previous])<sigma && baseBar>firstBar)
               baseBar--;

            indCompShort.Value[bar]=Data.Open[bar]<adLowerBand[bar-previous]-sigma && 
                                    Data.Open[baseBar]>adLowerBand[baseBar-previous]+sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_opens_below_Lower_Band_after_above:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int baseBar=bar-1;
            while(MathAbs(Data.Open[baseBar]-adLowerBand[baseBar-previous])<sigma && baseBar>firstBar)
               baseBar--;

            indCompLong.Value[bar]=Data.Open[bar]<adLowerBand[bar-previous]-sigma && 
                                   Data.Open[baseBar]>adLowerBand[baseBar-previous]+sigma ? 1 : 0;

            baseBar=bar-1;
            while(MathAbs(Data.Open[baseBar]-adUpperBand[baseBar-previous])<sigma && baseBar>firstBar)
               baseBar--;

            indCompShort.Value[bar]=Data.Open[bar]>adUpperBand[bar-previous]+sigma && 
                                    Data.Open[baseBar]<adUpperBand[baseBar-previous]-sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_opens_above_Lower_Band_after_below:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int baseBar=bar-1;
            while(MathAbs(Data.Open[baseBar]-adLowerBand[baseBar-previous])<sigma && baseBar>firstBar)
               baseBar--;

            indCompLong.Value[bar]=Data.Open[bar]>adLowerBand[bar-previous]+sigma && 
                                   Data.Open[baseBar]<adLowerBand[baseBar-previous]-sigma ? 1 : 0;

            baseBar=bar-1;
            while(MathAbs(Data.Open[baseBar]-adUpperBand[baseBar-previous])<sigma && baseBar>firstBar)
               baseBar--;

            indCompShort.Value[bar]=Data.Open[bar]<adUpperBand[bar-previous]-sigma && 
                                    Data.Open[baseBar]>adUpperBand[baseBar-previous]+sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_closes_below_the_Upper_Band:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = Data.Close[bar] < adUpperBand[bar - previous] - sigma ? 1 : 0;
            indCompShort.Value[bar] = Data.Close[bar] > adLowerBand[bar - previous] + sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_closes_above_the_Upper_Band:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = Data.Close[bar] > adUpperBand[bar - previous] + sigma ? 1 : 0;
            indCompShort.Value[bar] = Data.Close[bar] < adLowerBand[bar - previous] - sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_closes_below_the_Lower_Band:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = Data.Close[bar] < adLowerBand[bar - previous] - sigma ? 1 : 0;
            indCompShort.Value[bar] = Data.Close[bar] > adUpperBand[bar - previous] + sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_closes_above_the_Lower_Band:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = Data.Close[bar] > adLowerBand[bar - previous] + sigma ? 1 : 0;
            indCompShort.Value[bar] = Data.Close[bar] < adUpperBand[bar - previous] - sigma ? 1 : 0;
           }
         break;

      default:
         return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::IndicatorRisesLogic(int firstBar,int previous,const double &adIndValue[],IndicatorComp &indCompLong,
                                    IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]  = 0;
      indCompShort.Value[bar] = 0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      int  currentBar = bar - previous;
      int  baseBar    = currentBar - 1;
      bool isNoChange = true;
      bool isHigher   = adIndValue[currentBar] > adIndValue[baseBar];

      while(MathAbs(adIndValue[currentBar]-adIndValue[baseBar])<sigma && isNoChange && 
            baseBar>firstBar)
        {
         isNoChange=(isHigher==(adIndValue[baseBar+1]>adIndValue[baseBar]));
         baseBar--;
        }

      indCompLong.Value[bar]  = adIndValue[currentBar] > adIndValue[baseBar] + sigma ? 1 : 0;
      indCompShort.Value[bar] = adIndValue[currentBar] < adIndValue[baseBar] - sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::IndicatorFallsLogic(int firstBar,int previous,const double &adIndValue[],IndicatorComp &indCompLong,
                                    IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]=0;
      indCompShort.Value[bar]=0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      int currentBar=bar-previous;
      int baseBar=currentBar-1;
      bool isNoChange=true;
      bool isLower=adIndValue[currentBar]<adIndValue[baseBar];

      while(MathAbs(adIndValue[currentBar]-adIndValue[baseBar])<sigma && isNoChange && 
            baseBar>firstBar)
        {
         isNoChange=(isLower==(adIndValue[baseBar+1]<adIndValue[baseBar]));
         baseBar--;
        }

      indCompLong.Value[bar]  = adIndValue[currentBar] < adIndValue[baseBar] - sigma ? 1 : 0;
      indCompShort.Value[bar] = adIndValue[currentBar] > adIndValue[baseBar] + sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::IndicatorIsHigherThanAnotherIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                                           double &adAnotherIndValue[],IndicatorComp &indCompLong,
                                                           IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]=0;
      indCompShort.Value[bar]=0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      int currentBar=bar-previous;
      indCompLong.Value[bar]  = adIndValue[currentBar] > adAnotherIndValue[currentBar] + sigma ? 1 : 0;
      indCompShort.Value[bar] = adIndValue[currentBar] < adAnotherIndValue[currentBar] - sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::IndicatorIsLowerThanAnotherIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                                          double &adAnotherIndValue[],IndicatorComp &indCompLong,
                                                          IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]  = 0;
      indCompShort.Value[bar] = 0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      int currentBar=bar-previous;
      indCompLong.Value[bar]  = adIndValue[currentBar] < adAnotherIndValue[currentBar] - sigma ? 1 : 0;
      indCompShort.Value[bar] = adIndValue[currentBar] > adAnotherIndValue[currentBar] + sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::IndicatorChangesItsDirectionUpward(int firstBar,int previous,double &adIndValue[],
                                                   IndicatorComp &indCompLong,IndicatorComp &indCompShort)
  {
   double sigma= Sigma();
   for(int bar = firstBar; bar<Data.Bars; bar++)
     {
      int bar0 = bar - previous;
      int bar1 = bar0 - 1;
      while(MathAbs(adIndValue[bar0]-adIndValue[bar1])<sigma && bar1>firstBar)
         bar1--;

      int bar2=bar1-1>firstBar ? bar1-1 : firstBar;
      while(MathAbs(adIndValue[bar1]-adIndValue[bar2])<sigma && bar2>firstBar)
         bar2--;

      indCompLong.Value[bar]=(adIndValue[bar2]>adIndValue[bar1] && adIndValue[bar1]<adIndValue[bar0] && 
                              bar1==bar0-1) ? 1 : 0;
      indCompShort.Value[bar]=(adIndValue[bar2]<adIndValue[bar1] && adIndValue[bar1]>adIndValue[bar0] && 
                               bar1==bar0-1) ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::IndicatorChangesItsDirectionDownward(int firstBar,int previous,double &adIndValue[],
                                                     IndicatorComp &indCompLong,IndicatorComp &indCompShort)
  {
   double sigma= Sigma();
   for(int bar = firstBar; bar<Data.Bars; bar++)
     {
      int bar0 = bar - previous;
      int bar1 = bar0 - 1;
      while(MathAbs(adIndValue[bar0]-adIndValue[bar1])<sigma && bar1>firstBar)
         bar1--;

      int bar2=bar1-1>firstBar ? bar1-1 : firstBar;
      while(MathAbs(adIndValue[bar1]-adIndValue[bar2])<sigma && bar2>firstBar)
         bar2--;

      indCompLong.Value[bar]=(adIndValue[bar2]<adIndValue[bar1] && adIndValue[bar1]>adIndValue[bar0] && 
                              bar1==bar0-1) ? 1 : 0;
      indCompShort.Value[bar]=(adIndValue[bar2]>adIndValue[bar1] && adIndValue[bar1]<adIndValue[bar0] && 
                               bar1==bar0-1) ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::IndicatorCrossesAnotherIndicatorUpwardLogic(int firstBar,int previous,const double &adIndValue[],
                                                            double &adAnotherIndValue[],IndicatorComp &indCompLong,
                                                            IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]=0;
      indCompShort.Value[bar]=0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      int currentBar=bar-previous;
      int baseBar=currentBar-1;
      while(MathAbs(adIndValue[baseBar]-adAnotherIndValue[baseBar])<sigma && baseBar>firstBar)
         baseBar--;

      indCompLong.Value[bar]=adIndValue[currentBar]>adAnotherIndValue[currentBar]+sigma && 
                             adIndValue[baseBar]<adAnotherIndValue[baseBar]-sigma ? 1 : 0;
      indCompShort.Value[bar]=adIndValue[currentBar]<adAnotherIndValue[currentBar]-sigma && 
                              adIndValue[baseBar]>adAnotherIndValue[baseBar]+sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::IndicatorCrossesAnotherIndicatorDownwardLogic(int firstBar,int previous,const double &adIndValue[],
                                                              double &adAnotherIndValue[],IndicatorComp &indCompLong,
                                                              IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]=0;
      indCompShort.Value[bar]=0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      int currentBar=bar-previous;
      int baseBar=currentBar-1;
      while(MathAbs(adIndValue[baseBar]-adAnotherIndValue[baseBar])<sigma && baseBar>firstBar)
        {
         baseBar--;
        }

      indCompLong.Value[bar]=adIndValue[currentBar]<adAnotherIndValue[currentBar]-sigma && 
                             adIndValue[baseBar]>adAnotherIndValue[baseBar]+sigma ? 1 : 0;
      indCompShort.Value[bar]=adIndValue[currentBar]>adAnotherIndValue[currentBar]+sigma && 
                              adIndValue[baseBar]<adAnotherIndValue[baseBar]-sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::BarOpensAboveIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                            IndicatorComp &indCompLong,IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]  = 0;
      indCompShort.Value[bar] = 0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      indCompLong.Value[bar]  = Data.Open[bar] > adIndValue[bar - previous] + sigma ? 1 : 0;
      indCompShort.Value[bar] = Data.Open[bar] < adIndValue[bar - previous] - sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::BarOpensBelowIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                            IndicatorComp &indCompLong,IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]=0;
      indCompShort.Value[bar]=0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      indCompLong.Value[bar]  = Data.Open[bar] < adIndValue[bar - previous] - sigma ? 1 : 0;
      indCompShort.Value[bar] = Data.Open[bar] > adIndValue[bar - previous] + sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::BarOpensAboveIndicatorAfterOpeningBelowLogic(int firstBar,int previous,const double &adIndValue[],
                                                             IndicatorComp &indCompLong,IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]=0;
      indCompShort.Value[bar]=0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      int baseBar=bar-1;
      while(MathAbs(Data.Open[baseBar]-adIndValue[baseBar-previous])<sigma && baseBar>firstBar)
         baseBar--;

      indCompLong.Value[bar]=Data.Open[bar]>adIndValue[bar-previous]+sigma && 
                             Data.Open[baseBar]<adIndValue[baseBar-previous]-sigma ? 1 : 0;
      indCompShort.Value[bar]=Data.Open[bar]<adIndValue[bar-previous]-sigma && 
                              Data.Open[baseBar]>adIndValue[baseBar-previous]+sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::BarOpensBelowIndicatorAfterOpeningAboveLogic(int firstBar,int previous,const double &adIndValue[],
                                                             IndicatorComp &indCompLong,IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]=0;
      indCompShort.Value[bar]=0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      int baseBar=bar-1;
      while(MathAbs(Data.Open[baseBar]-adIndValue[baseBar-previous])<sigma && baseBar>firstBar)
         baseBar--;

      indCompLong.Value[bar]=Data.Open[bar]<adIndValue[bar-previous]-sigma && 
                             Data.Open[baseBar]>adIndValue[baseBar-previous]+sigma ? 1 : 0;
      indCompShort.Value[bar]=Data.Open[bar]>adIndValue[bar-previous]+sigma && 
                              Data.Open[baseBar]<adIndValue[baseBar-previous]-sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::BarClosesAboveIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                             IndicatorComp &indCompLong,IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]  = 0;
      indCompShort.Value[bar] = 0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      indCompLong.Value[bar]  = Data.Close[bar] > adIndValue[bar - previous] + sigma ? 1 : 0;
      indCompShort.Value[bar] = Data.Close[bar] < adIndValue[bar - previous] - sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::BarClosesBelowIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                             IndicatorComp &indCompLong,IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]  = 0;
      indCompShort.Value[bar] = 0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      indCompLong.Value[bar]  = Data.Close[bar] < adIndValue[bar - previous] - sigma ? 1 : 0;
      indCompShort.Value[bar] = Data.Close[bar] > adIndValue[bar - previous] + sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+


class Fractal : public Indicator
  {
public:
                     Fractal(SlotTypes slotType);
   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Fractal::Fractal(SlotTypes slotType)
  {
   SlotType          = slotType;
   IndicatorName     = "Fractal";
   WarningMessage    = "";
   IsAllowLTF        = true;
   ExecTime          = ExecutionTime_DuringTheBar;
   IsSeparateChart   = false;
   IsDiscreteValues  = false;
   IsDefaultGroupAll = false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Fractal::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);
   double epsiolon=Epsilon();

   bool isVisible=ListParam[1].Text=="Visible";
   double shift=NumParam[0].Value*Data.Point;
   const int firstBar=8;

   double upFractals[];    ArrayResize(upFractals,Data.Bars);   ArrayInitialize(upFractals,0);
   double downFractals[];  ArrayResize(downFractals,Data.Bars); ArrayInitialize(downFractals,0);

   for(int bar=8; bar<Data.Bars-1; bar++)
     {
      if(Data.High[bar-1]<Data.High[bar-2] && Data.High[bar]<Data.High[bar-2])
        {
         // Fractal type 1
         if(Data.High[bar-4]<Data.High[bar-2] &&
            Data.High[bar-3]<Data.High[bar-2])
            upFractals[bar+1]=Data.High[bar-2];

         // Fractal type 2
         if(Data.High[bar-5]<Data.High[bar-2] &&
            Data.High[bar-4]<Data.High[bar-2] &&
            MathAbs(Data.High[bar-3]-Data.High[bar-2])<epsiolon)
            upFractals[bar+1]=Data.High[bar-2];

         // Fractal type 3, 4
         if(Data.High[bar-6]<Data.High[bar-2] &&
            Data.High[bar-5]<Data.High[bar-2] &&
            MathAbs(Data.High[bar-4]-Data.High[bar-2])<epsiolon && 
            Data.High[bar-3]<= Data.High[bar-2])
            upFractals[bar+1]= Data.High[bar-2];

         // Fractal type 5
         if(Data.High[bar-7]<Data.High[bar-2] &&
            Data.High[bar-6]<Data.High[bar-2] &&
            MathAbs(Data.High[bar-5]-Data.High[bar-2])<epsiolon && 
            Data.High[bar-4]<Data.High[bar-2] && 
            MathAbs(Data.High[bar-3]-Data.High[bar-2])<epsiolon)
            upFractals[bar+1]=Data.High[bar-2];

         // Fractal type 6
         if(Data.High[bar-7]<Data.High[bar-2] &&
            Data.High[bar-6]<Data.High[bar-2] &&
            MathAbs(Data.High[bar-5]-Data.High[bar-2])<epsiolon &&
            MathAbs(Data.High[bar-4]-Data.High[bar-2])<epsiolon &&
            Data.High[bar-3]<Data.High[bar-2])
            upFractals[bar+1]=Data.High[bar-2];

         // Fractal type 7
         if(Data.High[bar-8]<Data.High[bar-2] &&
            Data.High[bar-7]<Data.High[bar-2] &&
            MathAbs(Data.High[bar-6]-Data.High[bar-2])<epsiolon && 
            Data.High[bar-5]<Data.High[bar-2] && 
            MathAbs(Data.High[bar-6]-Data.High[bar-2])<epsiolon && 
            Data.High[bar-3]<Data.High[bar-2])
            upFractals[bar+1]=Data.High[bar-2];
        }

      if(Data.Low[bar-1]>Data.Low[bar-2] && Data.Low[bar]>Data.Low[bar-2])
        {
         // Fractal type 1
         if(Data.Low[bar-4]>Data.Low[bar-2] &&
            Data.Low[bar-3]>Data.Low[bar-2])
            downFractals[bar+1]=Data.Low[bar-2];

         // Fractal type 2
         if(Data.Low[bar-5]>Data.Low[bar-2] &&
            Data.Low[bar-4]>Data.Low[bar-2] &&
            MathAbs(Data.Low[bar-3]-Data.Low[bar-2])<epsiolon)
            downFractals[bar+1]=Data.Low[bar-2];

         // Fractal type 3, 4
         if(Data.Low[bar-6]>Data.Low[bar-2] &&
            Data.Low[bar-5] > Data.Low[bar-2] &&
            MathAbs(Data.Low[bar-4]-Data.Low[bar-2])<epsiolon && 
            Data.Low[bar-3]>=Data.Low[bar-2])
            downFractals[bar+1]=Data.Low[bar-2];

         // Fractal type 5
         if(Data.Low[bar-7]>Data.Low[bar-2] &&
            Data.Low[bar-6]>Data.Low[bar-2] &&
            MathAbs(Data.Low[bar-5]-Data.Low[bar-2])<epsiolon && 
            Data.Low[bar-4]>Data.Low[bar-2] && 
            MathAbs(Data.Low[bar-3]-Data.Low[bar-2])<epsiolon)
            downFractals[bar+1]=Data.Low[bar-2];

         // Fractal type 6
         if(Data.Low[bar-7]>Data.Low[bar-2] &&
            Data.Low[bar-6]>Data.Low[bar-2] &&
            MathAbs(Data.Low[bar-5]-Data.Low[bar-2])<epsiolon &&
            MathAbs(Data.Low[bar-4]-Data.Low[bar-2])<epsiolon &&
            Data.Low[bar-3]>Data.Low[bar-2])
            downFractals[bar+1]=Data.Low[bar-2];

         // Fractal type 7
         if(Data.Low[bar-8]>Data.Low[bar-2] &&
            Data.Low[bar-7]>Data.Low[bar-2] &&
            MathAbs(Data.Low[bar-6]-Data.Low[bar-2])<epsiolon && 
            Data.Low[bar-5]>Data.Low[bar-2] && 
            MathAbs(Data.Low[bar-4]-Data.Low[bar-2])<epsiolon && 
            Data.Low[bar-3]>Data.Low[bar-2])
            downFractals[bar+1]=Data.Low[bar-2];
        }
     }

   if(isVisible)
     {
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         if(upFractals[bar]<epsiolon && upFractals[bar-1]>Data.High[bar-1])
            upFractals[bar]=upFractals[bar-1];
         if(downFractals[bar]<epsiolon && downFractals[bar-1]<Data.Low[bar-1])
            downFractals[bar]=downFractals[bar-1];
        }
     }
   else
     {
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         if(upFractals[bar]<epsiolon)
            upFractals[bar]=upFractals[bar-1];
         if(downFractals[bar]<epsiolon)
            downFractals[bar]=downFractals[bar-1];
        }
     }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Up Fractal";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,upFractals);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Down Fractal";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,downFractals);

   ArrayResize(Component[2].Value,Data.Bars);
   ArrayInitialize(Component[2].Value,0);
   Component[2].FirstBar=firstBar;

   ArrayResize(Component[3].Value,Data.Bars);
   ArrayInitialize(Component[3].Value,0);
   Component[3].FirstBar=firstBar;

   if(SlotType==SlotTypes_Open)
     {
      Component[2].CompName = "Long position entry price";
      Component[2].DataType = IndComponentType_OpenLongPrice;
      Component[3].CompName = "Short position entry price";
      Component[3].DataType = IndComponentType_OpenShortPrice;
     }
   else if(SlotType==SlotTypes_Close)
     {
      Component[2].CompName = "Long position closing price";
      Component[2].DataType = IndComponentType_CloseLongPrice;
      Component[3].CompName = "Short position closing price";
      Component[3].DataType = IndComponentType_CloseShortPrice;
     }

   if(ListParam[0].Text=="Enter long at Up Fractal" ||
      ListParam[0].Text=="Exit long at Up Fractal")
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         if(upFractals[bar]>epsiolon)
            Component[2].Value[bar]=upFractals[bar]+shift;
         if(downFractals[bar]>epsiolon)
            Component[3].Value[bar]=downFractals[bar]-shift;
        }
   if(ListParam[0].Text=="Enter long at Down Fractal" ||
      ListParam[0].Text=="Exit long at Down Fractal")
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         if(downFractals[bar]>epsiolon)
            Component[2].Value[bar]=downFractals[bar]-shift;
         if(upFractals[bar]>epsiolon)
            Component[3].Value[bar]=upFractals[bar]+shift;
        }
  }
//+------------------------------------------------------------------+

class KeltnerChannel : public Indicator
  {
public:
    KeltnerChannel(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Keltner Channel";

      WarningMessage    = "";
      IsAllowLTF        = true;
      ExecTime          = ExecutionTime_DuringTheBar;
      IsSeparateChart   = false;
      IsDiscreteValues  = false;
      IsDefaultGroupAll = false;
     }

   virtual void Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void KeltnerChannel::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   MAMethod maMethod=(MAMethod) ListParam[1].Index;
   const BasePrice basePrice=BasePrice_Close;
   int period=(int) NumParam[0].Value;
   int atrPeriod=(int) NumParam[1].Value;
   int atrMultiplier=(int) NumParam[3].Value;
   int previous=CheckParam[0].Checked ? 1 : 0;

   double price[];    Price(basePrice,price);
   double ma[];     MovingAverage(period,0,maMethod,price,ma);
   double adAtr[];    ArrayResize(adAtr,Data.Bars);    ArrayInitialize(adAtr,0);
   double upperBand[]; ArrayResize(upperBand,Data.Bars); ArrayInitialize(upperBand,0);
   double lowerBand[]; ArrayResize(lowerBand,Data.Bars); ArrayInitialize(lowerBand,0);

   int firstBar=MathMax(period,atrPeriod)+previous+2;

   for(int bar=1; bar<Data.Bars; bar++)
     {
      adAtr[bar] = MathMax(MathAbs(Data.High[bar] - Data.Close[bar - 1]), MathAbs(Data.Close[bar - 1] - Data.Low[bar]));
      adAtr[bar] = MathMax(MathAbs(Data.High[bar] - Data.Low[bar]), adAtr[bar]);
     }

   double maAtr[]; ArrayResize(maAtr,Data.Bars); ArrayInitialize(maAtr,0);
   MovingAverage(atrPeriod,0,maMethod,adAtr,maAtr);

   for(int bar=period; bar<Data.Bars; bar++)
     {
      upperBand[bar] = ma[bar] + maAtr[bar]*atrMultiplier;
      lowerBand[bar] = ma[bar] - maAtr[bar]*atrMultiplier;
     }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Upper Band";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,upperBand);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Moving Average";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,ma);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].CompName = "Lower Band";
   Component[2].DataType = IndComponentType_IndicatorValue;
   Component[2].FirstBar = firstBar;
   ArrayCopy(Component[2].Value,lowerBand);

   ArrayResize(Component[3].Value,Data.Bars);
   ArrayInitialize(Component[3].Value,0);
   Component[3].FirstBar=firstBar;

   ArrayResize(Component[4].Value,Data.Bars);
   ArrayInitialize(Component[4].Value,0);
   Component[4].FirstBar=firstBar;

   if(SlotType==SlotTypes_Open)
     {
      Component[3].DataType = IndComponentType_OpenLongPrice;
      Component[3].CompName = "Long position entry price";
      Component[4].DataType = IndComponentType_OpenShortPrice;
      Component[4].CompName = "Short position entry price";
     }
   else if(SlotType==SlotTypes_OpenFilter)
     {
      Component[3].DataType = IndComponentType_AllowOpenLong;
      Component[3].CompName = "Is long entry allowed";
      Component[4].DataType = IndComponentType_AllowOpenShort;
      Component[4].CompName = "Is short entry allowed";
     }
   else if(SlotType==SlotTypes_Close)
     {
      Component[3].DataType = IndComponentType_CloseLongPrice;
      Component[3].CompName = "Long position closing price";
      Component[4].DataType = IndComponentType_CloseShortPrice;
      Component[4].CompName = "Short position closing price";
     }
   else if(SlotType==SlotTypes_CloseFilter)
     {
      Component[3].DataType = IndComponentType_ForceCloseLong;
      Component[3].CompName = "Close out long position";
      Component[4].DataType = IndComponentType_ForceCloseShort;
      Component[4].CompName = "Close out short position";
     }

   if(SlotType==SlotTypes_Open || SlotType==SlotTypes_Close)
     {
      if(period>1)
        {
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            // Covers the cases when the price can pass through the band without a signal.
            double dOpen=Data.Open[bar]; // Current open price

            // Upper band
            double dValueUp=upperBand[bar-previous]; // Current value
            double dValueUp1=upperBand[bar-previous-1]; // Previous value
            double dTempValUp=dValueUp;

            if((dValueUp1>Data.High[bar-1] && dValueUp<dOpen) || // The Data.Open price jumps above the indicator
               (dValueUp1<Data.Low[bar-1]  && dValueUp>dOpen) || // The Data.Open price jumps below the indicator
               (Data.Close[bar-1]<dValueUp && dValueUp<dOpen) || // The Data.Open price is in a positive gap
               (Data.Close[bar-1]>dValueUp &&  dValueUp>dOpen))  // The Data.Open price is in a negative gap
               dTempValUp=dOpen; // The entry/exit level is moved to Data.Open price

            // Lower band
            double dValueDown=lowerBand[bar-previous];    // Current value
            double dValueDown1=lowerBand[bar-previous-1]; // Previous value
            double dTempValDown=dValueDown;

            if((dValueDown1>Data.High[bar-1] && dValueDown<dOpen) || // The Data.Open price jumps above the indicator
               (dValueDown1<Data.Low[bar-1]  && dValueDown>dOpen) || // The Data.Open price jumps below the indicator
               (Data.Close[bar-1]<dValueDown && dValueDown<dOpen) || // The Data.Open price is in a positive gap
               (Data.Close[bar-1]>dValueDown && dValueDown>dOpen))   // The Data.Open price is in a negative gap
               dTempValDown=dOpen; // The entry/exit level is moved to Data.Open price

            if(ListParam[0].Text=="Enter long at Upper Band" || ListParam[0].Text=="Exit long at Upper Band")
              {
               Component[3].Value[bar] = dTempValUp;
               Component[4].Value[bar] = dTempValDown;
              }
            else
              {
               Component[3].Value[bar] = dTempValDown;
               Component[4].Value[bar] = dTempValUp;
              }
           }
        }
      else
        {
         for(int bar=2; bar<Data.Bars; bar++)
           {
            if(ListParam[0].Text=="Enter long at Upper Band" || ListParam[0].Text=="Exit long at Upper Band")
              {
               Component[3].Value[bar] = upperBand[bar - previous];
               Component[4].Value[bar] = lowerBand[bar - previous];
              }
            else
              {
               Component[3].Value[bar] = lowerBand[bar - previous];
               Component[4].Value[bar] = upperBand[bar - previous];
              }
           }
        }
     }
   else
     {
      if(ListParam[0].Text=="The bar opens below Upper Band")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[3],Component[4],BandIndLogic_The_bar_opens_below_the_Upper_Band);
      else if(ListParam[0].Text=="The bar opens above Upper Band")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[3],Component[4],BandIndLogic_The_bar_opens_above_the_Upper_Band);
      else if(ListParam[0].Text=="The bar opens below Lower Band")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[3],Component[4],BandIndLogic_The_bar_opens_below_the_Lower_Band);
      else if(ListParam[0].Text=="The bar opens above Lower Band")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[3],Component[4],BandIndLogic_The_bar_opens_above_the_Lower_Band);
      else if(ListParam[0].Text=="The bar opens below Upper Band after opening above it")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[3],Component[4],BandIndLogic_The_bar_opens_below_Upper_Band_after_above);
      else if(ListParam[0].Text=="The bar opens above Upper Band after opening below it")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[3],Component[4],BandIndLogic_The_bar_opens_above_Upper_Band_after_below);
      else if(ListParam[0].Text=="The bar opens below Lower Band after opening above it")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[3],Component[4],BandIndLogic_The_bar_opens_below_Lower_Band_after_above);
      else if(ListParam[0].Text=="The bar opens above Lower Band after opening below it")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[3],Component[4],BandIndLogic_The_bar_opens_above_Lower_Band_after_below);
      else if(ListParam[0].Text=="The position opens above Upper Band")
        {
         Component[0].PosPriceDependence = PositionPriceDependence_PriceBuyHigher;
         Component[2].PosPriceDependence = PositionPriceDependence_PriceSellLower;
         Component[3].DataType = IndComponentType_Other;
         Component[4].DataType = IndComponentType_Other;
         Component[3].ShowInDynInfo = false;
         Component[4].ShowInDynInfo = false;
        }
      else if(ListParam[0].Text=="The position opens below Upper Band")
        {
         Component[0].PosPriceDependence = PositionPriceDependence_PriceBuyLower;
         Component[2].PosPriceDependence = PositionPriceDependence_PriceSellHigher;
         Component[3].DataType = IndComponentType_Other;
         Component[4].DataType = IndComponentType_Other;
         Component[3].ShowInDynInfo = false;
         Component[4].ShowInDynInfo = false;
        }
      else if(ListParam[0].Text=="The position opens above Lower Band")
        {
         Component[0].PosPriceDependence = PositionPriceDependence_PriceSellLower;
         Component[2].PosPriceDependence = PositionPriceDependence_PriceBuyHigher;
         Component[3].DataType = IndComponentType_Other;
         Component[4].DataType = IndComponentType_Other;
         Component[3].ShowInDynInfo = false;
         Component[4].ShowInDynInfo = false;
        }
      else if(ListParam[0].Text=="The position opens below Lower Band")
        {
         Component[0].PosPriceDependence = PositionPriceDependence_PriceSellHigher;
         Component[2].PosPriceDependence = PositionPriceDependence_PriceBuyLower;
         Component[3].DataType = IndComponentType_Other;
         Component[4].DataType = IndComponentType_Other;
         Component[3].ShowInDynInfo = false;
         Component[4].ShowInDynInfo = false;
        }
      else if(ListParam[0].Text=="The bar closes below Upper Band")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[3],Component[4],BandIndLogic_The_bar_closes_below_the_Upper_Band);
      else if(ListParam[0].Text=="The bar closes above Upper Band")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[3],Component[4],BandIndLogic_The_bar_closes_above_the_Upper_Band);
      else if(ListParam[0].Text=="The bar closes below Lower Band")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[3],Component[4],BandIndLogic_The_bar_closes_below_the_Lower_Band);
      else if(ListParam[0].Text=="The bar closes above Lower Band")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[3],Component[4],BandIndLogic_The_bar_closes_above_the_Lower_Band);
     }
  }
//+------------------------------------------------------------------+

class MovingAveragesCrossover : public Indicator
  {
public:
                     MovingAveragesCrossover(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Moving Averages Crossover";

      WarningMessage    = "";
      IsAllowLTF        = true;
      ExecTime          = ExecutionTime_DuringTheBar;
      IsSeparateChart   = false;
      IsDiscreteValues  = false;
      IsDefaultGroupAll = false;
     }

   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MovingAveragesCrossover::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   BasePrice basePrice=(BasePrice) ListParam[1].Index;
   MAMethod fastMAMethod = (MAMethod) ListParam[3].Index;
   MAMethod slowMAMethod = (MAMethod) ListParam[4].Index;
   int iNFastMA = (int) NumParam[0].Value;
   int iNSlowMA = (int) NumParam[1].Value;
   int iSFastMA = (int) NumParam[2].Value;
   int iSSlowMA = (int) NumParam[3].Value;
   int previous=CheckParam[0].Checked ? 1 : 0;

   int firstBar=MathMax(iNFastMA+iSFastMA,iNSlowMA+iSSlowMA)+previous+2;
   double price[];  Price(basePrice,price);
   double maFast[]; MovingAverage(iNFastMA,iSFastMA,fastMAMethod,price,maFast);
   double maSlow[]; MovingAverage(iNSlowMA,iSSlowMA,slowMAMethod,price,maSlow);
   double oscillator[]; ArrayResize(oscillator,Data.Bars); ArrayInitialize(oscillator,0);

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      oscillator[bar]=maFast[bar]-maSlow[bar];
     }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Fast Moving Average";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,maFast);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Slow Moving Average";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,maSlow);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].FirstBar=firstBar;

   ArrayResize(Component[3].Value,Data.Bars);
   Component[3].FirstBar=firstBar;

   if(SlotType==SlotTypes_OpenFilter)
     {
      Component[2].DataType = IndComponentType_AllowOpenLong;
      Component[2].CompName = "Is long entry allowed";
      Component[3].DataType = IndComponentType_AllowOpenShort;
      Component[3].CompName = "Is short entry allowed";
     }
   else if(SlotType==SlotTypes_CloseFilter)
     {
      Component[2].DataType = IndComponentType_ForceCloseLong;
      Component[2].CompName = "Close out long position";
      Component[3].DataType = IndComponentType_ForceCloseShort;
      Component[3].CompName = "Close out short position";
     }

   IndicatorLogic indLogic=IndicatorLogic_It_does_not_act_as_a_filter;

   if(ListParam[0].Text=="Fast MA crosses Slow MA upward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_upward;
   else if(ListParam[0].Text=="Fast MA crosses Slow MA downward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_downward;
   else if(ListParam[0].Text=="Fast MA is higher than Slow MA")
      indLogic=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
   else if(ListParam[0].Text=="Fast MA is lower than Slow MA")
      indLogic=IndicatorLogic_The_indicator_is_lower_than_the_level_line;

   OscillatorLogic(firstBar,previous,oscillator,0,0,Component[2],Component[3],indLogic);
  }
//+------------------------------------------------------------------+


class VidyaMovingAverage : public Indicator
  {
public:
                     VidyaMovingAverage(SlotTypes slotType);
   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void VidyaMovingAverage::VidyaMovingAverage(SlotTypes slotType)
  {
   SlotType          = slotType;
   IndicatorName     = "Vidya Moving Average";
   WarningMessage    = "";
   IsAllowLTF        = true;
   ExecTime          = ExecutionTime_DuringTheBar;
   IsSeparateChart   = false;
   IsDiscreteValues  = false;
   IsDefaultGroupAll = false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void VidyaMovingAverage::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   BasePrice basePrice=(BasePrice)ListParam[2].Index;
   int period    = (int)NumParam[0].Value;
   int smoothing = (int)NumParam[1].Value;
   int previous  = CheckParam[0].Checked ? 1 : 0;

   int firstBar=period+smoothing+previous+2;

   double adBasePrice[];
   Price(basePrice,adBasePrice);

   double adCMO1[]; ArrayResize(adCMO1,Data.Bars); ArrayInitialize(adCMO1,0);
   double adCMO2[]; ArrayResize(adCMO2,Data.Bars); ArrayInitialize(adCMO2,0);

   for(int bar=1; bar<Data.Bars; bar++)
     {
      adCMO1[bar] = 0;
      adCMO1[bar] = 0;
      if(adBasePrice[bar]>adBasePrice[bar-1])
         adCMO1[bar]=adBasePrice[bar]-adBasePrice[bar-1];
      if(adBasePrice[bar]<adBasePrice[bar-1])
         adCMO2[bar]=adBasePrice[bar-1]-adBasePrice[bar];
     }

   double adCMO1Sum[]; ArrayResize(adCMO1Sum,Data.Bars); ArrayInitialize(adCMO1Sum,0);
   double adCMO2Sum[]; ArrayResize(adCMO2Sum,Data.Bars); ArrayInitialize(adCMO2Sum,0);

   for(int bar=0; bar<period; bar++)
     {
      adCMO1Sum[period - 1] += adCMO1[bar];
      adCMO2Sum[period - 1] += adCMO2[bar];
     }

   double adCMO[]; ArrayResize(adCMO,Data.Bars); ArrayInitialize(adCMO,0);

   for(int bar=period; bar<Data.Bars; bar++)
     {
      adCMO1Sum[bar] = adCMO1Sum[bar - 1] + adCMO1[bar] - adCMO1[bar - period];
      adCMO2Sum[bar] = adCMO2Sum[bar - 1] + adCMO2[bar] - adCMO2[bar - period];

      if(adCMO1Sum[bar]+adCMO2Sum[bar]==0)
         adCMO[bar]=100;
      else
         adCMO[bar]=100 *(adCMO1Sum[bar]-adCMO2Sum[bar])/(adCMO1Sum[bar]+adCMO2Sum[bar]);
     }

   double adMA[]; ArrayResize(adMA,Data.Bars); ArrayInitialize(adMA,0);
   double SC=2.0/(smoothing+1);

   for(int bar=0; bar<period; bar++)
      adMA[bar]=adBasePrice[bar];

   for(int bar=period; bar<Data.Bars; bar++)
     {
      double dAbsCMO=MathAbs(adCMO[bar])/100;
      adMA[bar]=SC*dAbsCMO*adBasePrice[bar]+(1-SC*dAbsCMO)*adMA[bar-1];
     }

   if(SlotType==SlotTypes_Open || SlotType==SlotTypes_Close)
     {
      ArrayResize(Component[1].Value,Data.Bars);

      for(int bar=2; bar<Data.Bars; bar++)
        {   // Covers the cases when the price can pass through the MA without a signal
         double dValue   = adMA[bar - previous];     // Current value
         double dValue1  = adMA[bar - previous - 1]; // Previous value
         double dTempVal = dValue;
         if((dValue1>Data.High[bar-1] && dValue<Data.Open[bar]) || // It jumps below the current bar
            (dValue1<Data.Low[bar-1] && dValue>Data.Open[bar]) || // It jumps above the current bar
            (Data.Close[bar - 1] < dValue && dValue < Data.Open[bar]) || // Positive gap
            (Data.Close[bar - 1] > dValue && dValue > Data.Open[bar]))   // Negative gap
            dTempVal=Data.Open[bar];
         Component[1].Value[bar]=dTempVal;
        }
     }
   else
     {
      ArrayResize(Component[1].Value,Data.Bars);
      Component[1].FirstBar=firstBar;

      ArrayResize(Component[2].Value,Data.Bars);
      Component[2].FirstBar=firstBar;
     }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName   = "MA Value";
   Component[0].DataType   = IndComponentType_IndicatorValue;
   Component[0].FirstBar   = firstBar;
   ArrayCopy(Component[0].Value,adMA);

   if(SlotType==SlotTypes_Open)
     {
      Component[1].CompName = "Position opening price";
      Component[1].DataType = IndComponentType_OpenPrice;
     }
   else if(SlotType==SlotTypes_OpenFilter)
     {
      Component[1].DataType = IndComponentType_AllowOpenLong;
      Component[1].CompName = "Is long entry allowed";
      Component[2].DataType = IndComponentType_AllowOpenShort;
      Component[2].CompName = "Is short entry allowed";
     }
   else if(SlotType==SlotTypes_Close)
     {
      Component[1].CompName = "Position closing price";
      Component[1].DataType = IndComponentType_ClosePrice;
     }
   else if(SlotType==SlotTypes_CloseFilter)
     {
      Component[1].DataType = IndComponentType_ForceCloseLong;
      Component[1].CompName = "Close out long position";
      Component[2].DataType = IndComponentType_ForceCloseShort;
      Component[2].CompName = "Close out short position";
     }

   if(SlotType==SlotTypes_OpenFilter || SlotType==SlotTypes_CloseFilter)
     {
      if(ListParam[0].Text=="The Vidya Moving Average rises")
         IndicatorRisesLogic(firstBar,previous,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The Vidya Moving Average falls")
         IndicatorFallsLogic(firstBar,previous,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar opens above the Vidya Moving Average")
         BarOpensAboveIndicatorLogic(firstBar,previous,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar opens below the Vidya Moving Average")
         BarOpensBelowIndicatorLogic(firstBar,previous,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar opens above the Vidya Moving Average after opening below it")
         BarOpensAboveIndicatorAfterOpeningBelowLogic(firstBar,previous,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar opens below the Vidya Moving Average after opening above it")
         BarOpensBelowIndicatorAfterOpeningAboveLogic(firstBar,previous,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The position opens above the Vidya Moving Average")
        {
         Component[0].PosPriceDependence=PositionPriceDependence_BuyHigherSellLower;
         Component[0].UsePreviousBar=previous;
         Component[1].DataType=IndComponentType_Other;
         Component[1].ShowInDynInfo=false;
         Component[2].DataType=IndComponentType_Other;
         Component[2].ShowInDynInfo=false;
        }
      else if(ListParam[0].Text=="The position opens below the Vidya Moving Average")
        {
         Component[0].PosPriceDependence=PositionPriceDependence_BuyLowerSelHigher;
         Component[0].UsePreviousBar=previous;
         Component[1].DataType=IndComponentType_Other;
         Component[1].ShowInDynInfo=false;
         Component[2].DataType=IndComponentType_Other;
         Component[2].ShowInDynInfo=false;
        }
      else if(ListParam[0].Text=="The bar closes below the Vidya Moving Average")
         BarClosesBelowIndicatorLogic(firstBar,previous,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar closes above the Vidya Moving Average")
         BarClosesAboveIndicatorLogic(firstBar,previous,adMA,Component[1],Component[2]);
     }
  }
//+------------------------------------------------------------------+


class IndicatorManager
  {
public:
   Indicator        *CreateIndicator(string indicatorName,SlotTypes slotType);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Indicator *IndicatorManager::CreateIndicator(string indicatorName,SlotTypes slotType)
  {
   if(indicatorName == "Fractal")                   return new Fractal(slotType);
   if(indicatorName == "Keltner Channel")           return new KeltnerChannel(slotType);
   if(indicatorName == "Moving Averages Crossover") return new MovingAveragesCrossover(slotType);
   if (indicatorName == "Vidya Moving Average") return new VidyaMovingAverage(slotType);

   return NULL;
  }
//+------------------------------------------------------------------+


class IndicatorSlot
  {
public:
   // Constructors
                     IndicatorSlot();
                    ~IndicatorSlot();

   // Properties
   int               SlotNumber;
   SlotTypes         SlotType;
   string            IndicatorName;
   string            LogicalGroup;
   int               SignalShift;
   int               SignalRepeat;
   string            IndicatorSymbol;
   DataPeriod        IndicatorPeriod;

   Indicator        *IndicatorPointer;

   // Methods
   bool              GetUsePreviousBarValue(void);
   string            LogicalGroupToString(void);
   string            AdvancedParamsToString(void);
   string            GetIndicatorSymbol(string baseSymbol);
   DataPeriod        GetIndicatorPeriod(DataPeriod basePeriod);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IndicatorSlot::IndicatorSlot(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IndicatorSlot::~IndicatorSlot(void)
  {
   if(CheckPointer(IndicatorPointer)==POINTER_DYNAMIC)
      delete IndicatorPointer;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IndicatorSlot::GetUsePreviousBarValue(void)
  {
   for(int i=0; i<ArraySize(IndicatorPointer.CheckParam); i++)
     {
      if(IndicatorPointer.CheckParam[i].Caption=="Use previous bar value")
         return (IndicatorPointer.CheckParam[i].Checked);
     }
   return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string IndicatorSlot::LogicalGroupToString(void)
  {
   return ("Logical group: " + LogicalGroup);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string IndicatorSlot::AdvancedParamsToString(void)
  {
   string text = "Signal shift: " + IntegerToString(SignalShift) + "\n";
   if(SlotType == SlotTypes_OpenFilter || SlotType==SlotTypes_CloseFilter)
      text+="Signal repeat: "+IntegerToString(SignalRepeat)+"\n";

   string symbol=(IndicatorSymbol=="") ? "Default" : IndicatorSymbol;
   string period=(IndicatorPeriod==DataPeriod_M1)
                 ? "Default"
                 : DataPeriodToString(IndicatorPeriod);
   text += "Symbol: " + symbol + "\n";
   text += "Period: " + period + "\n";

   return (text);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string IndicatorSlot::GetIndicatorSymbol(string baseSymbol)
  {
   string symbol=(IndicatorSymbol=="") ? baseSymbol : IndicatorSymbol;
   return (symbol);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
DataPeriod IndicatorSlot::GetIndicatorPeriod(DataPeriod basePeriod)
  {
   DataPeriod period=(IndicatorPeriod<basePeriod) ? basePeriod : IndicatorPeriod;
   return (period);
  }
//+------------------------------------------------------------------+

class Strategy
  {
private:
   // Fields
   string            strategySymbol;
   DataPeriod        strategyPeriod;
   bool              isInTester;
   int               openSlotsCount;
   int               closeSlotsCount;

   // Methods
   string            GetSlotChart(int slotNumber);

public:
   // Constructor, deconstructor
                     Strategy(int openSlots,int closeSlots);
                    ~Strategy(void);

   // Properties
   string            StrategyName;
   string            Description;
   double            AddingLots;
   double            ReducingLots;
   double            EntryLots;
   double            MaxOpenLots;
   bool              UseAccountPercentEntry;
   bool              UsePermanentSL;
   int               PermanentSL;
   bool              UsePermanentTP;
   int               PermanentTP;
   bool              UseBreakEven;
   int               BreakEven;
   bool              UseMartingale;
   double            MartingaleMultiplier;
   int               FirstBar;
   int               MinBarsRequired;
   int               RecommendedBars;

   PermanentProtectionType PermanentTPType;
   PermanentProtectionType PermanentSLType;
   OppositeDirSignalAction OppSignalAction;
   SameDirSignalAction SameSignalAction;

   IndicatorSlot    *Slot[];

   // Methods
   void        SetSymbol(string symbol)    { strategySymbol = symbol; }
   void        SetPeriod(int period)       { strategyPeriod = EnumTimeFramesToPeriod(period); }
   void        SetIsTester(bool isTester)  { isInTester = isTester; }
   string      GetSymbol(void)             { return (strategySymbol); }
   DataPeriod  GetPeriod(void)             { return (strategyPeriod); }
   bool        IsTester(void)              { return (isInTester); }
   int         OpenSlots(void)             { return (openSlotsCount); };
   int         CloseSlots(void)            { return (closeSlotsCount); };
   int         Slots(void)                 { return (openSlotsCount + closeSlotsCount + 2); }
   int         CloseSlotNumber(void)       { return (openSlotsCount + 1); }
   SlotTypes         GetSlotType(int slotNumber);
   void              GetRequiredCharts(string &charts[]);
   bool              IsUsingLogicalGroups(void);
   bool              IsLogicalGroupSpecial(int slotNumber);
   string            GetDefaultGroup(int slotNumber);
   bool              IsLongerTimeFrame(int slotNumber);
   void              CalculateStrategy(DataSet *&dataSet[]);
   string            DynamicInfoText(void);
   void              DynamicInfoInitArrays(string &params[],string &values[]);
   void              DynamicInfoSetValues(string &values[]);
   string            ToString(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Strategy::Strategy(int openSlots,int closeSlots)
  {
   openSlotsCount=openSlots;
   closeSlotsCount=closeSlots;

   ArrayResize(Slot,Slots());

   for(int i=0; i<Slots(); i++)
     {
      Slot[i]=new IndicatorSlot();
      Slot[i].SlotNumber=i;
      Slot[i].SlotType=GetSlotType(i);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Strategy::~Strategy(void)
  {
   for(int slot=0; slot<ArraySize(Slot); slot++)
     {
      delete Slot[slot];
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SlotTypes Strategy::GetSlotType(int slotNumber)
  {
   if(slotNumber==0)
      return (SlotTypes_Open);
   else if(slotNumber<CloseSlotNumber())
      return (SlotTypes_OpenFilter);
   else if(slotNumber==CloseSlotNumber())
      return (SlotTypes_Close);
   else
      return (SlotTypes_CloseFilter);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Strategy::IsLongerTimeFrame(int slotNumber)
  {
   return !(Slot[slotNumber].IndicatorSymbol == "" &&
            Slot[slotNumber].IndicatorPeriod == DataPeriod_M1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Strategy::GetSlotChart(int slotNumber)
  {
   string symbol=Slot[slotNumber].GetIndicatorSymbol(GetSymbol());
   DataPeriod period=Slot[slotNumber].GetIndicatorPeriod(GetPeriod());
   string chart=symbol+","+DataPeriodToString(period);
   return (chart);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Strategy::GetRequiredCharts(string &charts[])
  {
   ArrayResize(charts,1);
   charts[0]=GetSymbol()+","+DataPeriodToString(GetPeriod());

   for(int i=0; i<Slots(); i++)
     {
      if(!Slot[i].IndicatorPointer.IsAllowLTF)
         continue;
      if(!IsLongerTimeFrame(i))
         continue;
      string chart=GetSlotChart(i);
      if(!ArrayContainsString(charts,chart))
         ArrayAppendString(charts,chart);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Strategy::CalculateStrategy(DataSet *&dataSet[])
  {
   for(int i=0; i<Slots(); i++)
     {
      string chart=GetSlotChart(i);
      for(int j=0; j<ArraySize(dataSet); j++)
        {
         if(dataSet[j].Chart!=chart)
            continue;

         Slot[i].IndicatorPointer.Calculate(dataSet[j]);

         if(IsLongerTimeFrame(i))
           {
            int ltfShift;
            bool isBasePriceOpen=false;
            bool isCloseFilterShift=false;

            for(int p=1; p<5; p++)
              {
               string listParamCaption=Slot[i].IndicatorPointer.ListParam[p].Caption;
               string listParamText=Slot[i].IndicatorPointer.ListParam[p].Text;
               if(listParamCaption=="Base price" && listParamText=="Open")
                 {
                  isBasePriceOpen=true;
                  break;
                 }
              }

            if(isBasePriceOpen)
              {
               ltfShift=0;
              }
            else
              {
               int prevBarCorrection=(!Slot[i].GetUsePreviousBarValue()) ? 1 : 0;
               ltfShift=Slot[i].IndicatorPeriod!=DataPeriod_M1 && prevBarCorrection;
               isCloseFilterShift=Slot[i].SlotType==SlotTypes_CloseFilter;
              }

            Slot[i].IndicatorPointer.NormalizeComponents(dataSet[0],ltfShift,isCloseFilterShift);
           }

         if(Slot[i].SignalShift>0)
            Slot[i].IndicatorPointer.ShiftSignal(Slot[i].SignalShift);

         if(Slot[i].SignalRepeat>0)
            Slot[i].IndicatorPointer.RepeatSignal(Slot[i].SignalRepeat);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Strategy::IsUsingLogicalGroups()
  {
   bool isUsingGroups=false;
   for(int slot=0; slot<ArraySize(Slot); slot++)
     {
      SlotTypes slotType=Slot[slot].SlotType;
      if(slotType==SlotTypes_OpenFilter)
        {
         string defaultGroup = GetDefaultGroup(slot);
         string logicalGroup = Slot[slot].LogicalGroup;
         if(defaultGroup!=logicalGroup && logicalGroup!="All")
           {
            isUsingGroups=true;
            break;
           }
        }
      else if(slotType==SlotTypes_CloseFilter)
        {
         string defaultGroup = GetDefaultGroup(slot);
         string logicalGroup = Slot[slot].LogicalGroup;
         if(defaultGroup!=logicalGroup)
           {
            isUsingGroups=true;
            break;
           }
        }
     }
   return (isUsingGroups);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Strategy::IsLogicalGroupSpecial(int slotNumber)
  {
   SlotTypes slotType=Slot[slotNumber].SlotType;
   string group= Slot[slotNumber].LogicalGroup;
   if(slotType == SlotTypes_Open|| slotType == SlotTypes_Close)
      return (false);
   if(slotType==SlotTypes_OpenFilter && group!=GetDefaultGroup(slotNumber) && group!="[All]")
      return (true);
   if(slotType==SlotTypes_CloseFilter && group!=GetDefaultGroup(slotNumber))
      return (true);
   if(slotType==SlotTypes_CloseFilter)
     {
      int count = 0;
      for(int i = OpenSlots() + 2; i < Slots(); i++)
         if(Slot[i].LogicalGroup==group)
            count++;
      if(count>1)
         return (true);
     }
   return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Strategy::GetDefaultGroup(int slotNumber)
  {
   string group="";
   SlotTypes slotType=GetSlotType(slotNumber);
   if(slotType==SlotTypes_OpenFilter)
     {
      bool isDefault=Slot[slotNumber].IndicatorPointer.IsDeafultGroupAll || 
                     Slot[slotNumber].IndicatorPointer.IsDefaultGroupAll;
      group=isDefault ? "All" : "A";
     }
   else if(slotType==SlotTypes_CloseFilter)
     {
      int index=slotNumber-CloseSlotNumber()-1;
      group=IntegerToString('a'+index);
     }
   return (group);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Strategy::DynamicInfoInitArrays(string &params[],string &values[])
  {
   ArrayResize(params,200);
   ArrayResize(values,200);
   for(int i=0; i<200; i++)
     {
      params[i] = "";
      values[i] = "";
     }

   int index=-2;
   for(int slot=0; slot<Slots(); slot++)
     {
      index++;
      index++;
      params[index]=Slot[slot].IndicatorName;
      for(int i=0; i<Slot[slot].IndicatorPointer.Components(); i++)
        {
         IndComponentType type=Slot[slot].IndicatorPointer.Component[i].DataType;
         if(type==IndComponentType_NotDefined)
            continue;
         if(Slot[slot].IndicatorPointer.Component[i].ShowInDynInfo)
           {
            index++;
            params[index]=Slot[slot].IndicatorPointer.Component[i].CompName;
           }
        }
     }
   ArrayResize(params,index+1);
   ArrayResize(values,index+1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Strategy::DynamicInfoSetValues(string &values[])
  {
   int index=-1;
   for(int slot=0; slot<Slots(); slot++)
     {
      index++;
      index++;
      for(int i=0; i<Slot[slot].IndicatorPointer.Components(); i++)
        {
         IndicatorComp *component=Slot[slot].IndicatorPointer.Component[i];
         IndComponentType type=component.DataType;
         if(type==IndComponentType_NotDefined)
           {
            component=NULL;
            continue;
           }
         int bars=ArraySize(component.Value);
         if(bars<3)
           {
            component=NULL;
            continue;
           }

         string name   = component.CompName;
         double value0 = component.Value[bars - 1];
         double value1 = component.Value[bars - 2];
         double dl0    = MathAbs(value0);
         double dl1    = MathAbs(value0);
         string sFr0   = dl0 < 10 ? "%10.5f" : dl0 < 100 ? "%10.5f" : dl0 < 1000 ? "%10.3f" :
                         dl0<10000 ? "%10.3f" : dl0<100000 ? "%10.2f" : "%10.1f";
         string sFr1=dl1<10 ? "%10.5f" : dl1<100 ? "%10.5f" : dl1<1000 ? "%10.3f" :
                     dl1<10000 ? "%10.3f" : dl1<100000 ? "%10.2f" : "%10.1f";
         string format=sFr1+"    "+sFr0;
         if(component.ShowInDynInfo)
           {
            if(type == IndComponentType_AllowOpenLong  || 
               type == IndComponentType_AllowOpenShort ||
               type == IndComponentType_ForceClose     ||
               type == IndComponentType_ForceCloseLong ||
               type == IndComponentType_ForceCloseShort)
               values[index]=StringFormat("%13s    %13s",(value1<1 ? "No" : "Yes"),(value0<1 ? "No" : "Yes"));
            else
               values[index]=StringFormat(format,value1,value0);
            index++;
           }
         component=NULL;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Strategy::DynamicInfoText()
  {
   string info;
   for(int slot=0; slot<Slots(); slot++)
     {
      info+="\n\n"+Slot[slot].IndicatorName;
      for(int i=0; i<Slot[slot].IndicatorPointer.Components(); i++)
        {
         IndicatorComp *component=Slot[slot].IndicatorPointer.Component[i];
         IndComponentType type=component.DataType;
         if(type==IndComponentType_NotDefined) continue;
         int bars=ArraySize(component.Value);
         if(bars<4) continue;

         string name   = component.CompName;
         double value0 = component.Value[bars - 1];
         double value1 = component.Value[bars - 2];
         double value2 = component.Value[bars - 3];
         double dl     = MathAbs(value0);
         string sFr    = dl < 10 ? "%10.6f" : dl < 100 ? "%10.5f" : dl < 1000 ? "%10.4" :
                         dl<10000 ? "%10.3f" : dl<100000 ? "%10.2f" : "%10.1f";
         string format="\n%-40s "+sFr+"    "+sFr+"    "+sFr;
         if(component.ShowInDynInfo)
           {
            if(type == IndComponentType_AllowOpenLong || 
               type == IndComponentType_AllowOpenShort ||
               type == IndComponentType_ForceClose     ||
               type == IndComponentType_ForceCloseLong ||
               type == IndComponentType_ForceCloseShort)
              {
               info+=StringFormat("\n%-42s %-10s    %-10s    %-10s",name,
                                  (value2 < 1 ? "No" : "Yes"),
                                  (value1 < 1 ? "No" : "Yes"),
                                  (value0 < 1 ? "No" : "Yes"));
              }
            else
              {
               info+=StringFormat(format,name,value2,value1,value0);
              }
           }
         component=NULL;
        }
     }
   return (info);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Strategy::ToString()
  {
   string stopLoss   = UsePermanentSL ? IntegerToString(PermanentSL)            : "None";
   string takeProfit = UsePermanentTP ? IntegerToString(PermanentTP)            : "None";
   string breakEven  = UseBreakEven   ? IntegerToString(BreakEven)              : "None";
   string martingale = UseMartingale  ? DoubleToString(MartingaleMultiplier, 2) : "None";

   string text="Name: "            + StrategyName+"\n"+
               "Symbol: "          + GetSymbol()+"\n"+
               "Period: "          + DataPeriodToString(GetPeriod())+"\n\n"+
               "Trade unit: "      + (UseAccountPercentEntry ? "Percent" : "Lot")+"\n"+
               "Entry amount: "    + DoubleToString(EntryLots,2)+"\n"+
               "Max open lots: "   + DoubleToString(MaxOpenLots,2)+"\n\n"+
               "Same signal: "     + SameDirSignalActionToString(SameSignalAction)+"\n"+
               "Adding amount: "   + DoubleToString(AddingLots,2)+"\n"+
               "Opposite signal: " + OppositeDirSignalActionToString(OppSignalAction)+"\n"+
               "Reducing amount: " + DoubleToString(ReducingLots,2)+"\n\n"+
               "Stop Loss: "       + stopLoss+"\n"+
               "Take Profit: "     + takeProfit+"\n"+
               "Break Even: "      + breakEven+"\n\n"+
               "Martingale: "      + martingale+"\n\n"+
               "Description: "     + Description+"\n\n";

   for(int slot=0; slot<ArraySize(Slot); slot++)
     {
      text+=SlotTypeToString(Slot[slot].SlotType)                + "\n" +
            Slot[slot].IndicatorName                             + "\n" +
            Slot[slot].IndicatorPointer.IndicatorParamToString() + "\n";

      if(Slot[slot].SlotType==SlotTypes_OpenFilter || Slot[slot].SlotType==SlotTypes_CloseFilter)
         text+=Slot[slot].LogicalGroupToString();
      if(Slot[slot].IndicatorPointer.IsAllowLTF)
         text+=Slot[slot].AdvancedParamsToString()+"\n";
     }
   return (text);
  }
//+------------------------------------------------------------------+

class StrategyManager
  {
public:
   Strategy         *GetStrategy(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Strategy *StrategyManager::GetStrategy(void)
  {
    IndicatorManager *indicatorManager=new IndicatorManager();

   Strategy *strategy = new Strategy(3, 0);

   strategy.StrategyName           = "EURUSD_1MIN DD35 10-95K 1mnth PF18.24 DD38";
   strategy.SameSignalAction       = SameDirSignalAction_Add;
   strategy.OppSignalAction        = OppositeDirSignalAction_Reduce;
   strategy.MaxOpenLots            = 20;
   strategy.UseAccountPercentEntry = false;
   strategy.EntryLots              = 1;
   strategy.AddingLots             = 1;
   strategy.ReducingLots           = 1;
   strategy.MartingaleMultiplier   = Martingale_Multiplier;
   strategy.UseMartingale          = Martingale_Multiplier > 0;
   strategy.Description            = "Exported on 12/1/2018 from Forex Strategy Builder Professional, v3.8.8";
   strategy.RecommendedBars        = 1000;
   strategy.FirstBar               = 208;
   strategy.MinBarsRequired        = 209;
   strategy.PermanentSL            = Stop_Loss;
   strategy.UsePermanentSL         = Stop_Loss > 0;
   strategy.PermanentSLType        = PermanentProtectionType_Relative;
   strategy.PermanentTP            = Take_Profit;
   strategy.UsePermanentTP         = Take_Profit > 0;
   strategy.PermanentTPType        = PermanentProtectionType_Relative;
   strategy.BreakEven              = Break_Even;
   strategy.UseBreakEven           = Break_Even > 0;

   strategy.Slot[0].IndicatorName    = "Keltner Channel";
   strategy.Slot[0].SlotType         = SlotTypes_Open;
   strategy.Slot[0].SignalShift      = 0;
   strategy.Slot[0].SignalRepeat     = 0;
   strategy.Slot[0].IndicatorPeriod  = DataPeriod_M1;
   strategy.Slot[0].IndicatorSymbol  = "";
   strategy.Slot[0].LogicalGroup     = "";
   strategy.Slot[0].IndicatorPointer = indicatorManager.CreateIndicator("Keltner Channel", SlotTypes_Open);

   strategy.Slot[0].IndicatorPointer.ListParam[0].Enabled = true;
   strategy.Slot[0].IndicatorPointer.ListParam[0].Caption = "Logic";
   strategy.Slot[0].IndicatorPointer.ListParam[0].Index   = 0;
   strategy.Slot[0].IndicatorPointer.ListParam[0].Text    = "Enter long at Upper Band";
   strategy.Slot[0].IndicatorPointer.ListParam[1].Enabled = true;
   strategy.Slot[0].IndicatorPointer.ListParam[1].Caption = "Smoothing method";
   strategy.Slot[0].IndicatorPointer.ListParam[1].Index   = 2;
   strategy.Slot[0].IndicatorPointer.ListParam[1].Text    = "Exponential";
   strategy.Slot[0].IndicatorPointer.ListParam[2].Enabled = true;
   strategy.Slot[0].IndicatorPointer.ListParam[2].Caption = "Base price";
   strategy.Slot[0].IndicatorPointer.ListParam[2].Index   = 0;
   strategy.Slot[0].IndicatorPointer.ListParam[2].Text    = "Close";

   strategy.Slot[0].IndicatorPointer.NumParam[0].Enabled = true;
   strategy.Slot[0].IndicatorPointer.NumParam[0].Caption = "MA period";
   strategy.Slot[0].IndicatorPointer.NumParam[0].Value   = Slot0IndParam0;
   strategy.Slot[0].IndicatorPointer.NumParam[1].Enabled = true;
   strategy.Slot[0].IndicatorPointer.NumParam[1].Caption = "ATR period";
   strategy.Slot[0].IndicatorPointer.NumParam[1].Value   = Slot0IndParam1;
   strategy.Slot[0].IndicatorPointer.NumParam[3].Enabled = true;
   strategy.Slot[0].IndicatorPointer.NumParam[3].Caption = "ATR multiplier";
   strategy.Slot[0].IndicatorPointer.NumParam[3].Value   = Slot0IndParam3;

   strategy.Slot[0].IndicatorPointer.CheckParam[0].Enabled = true;
   strategy.Slot[0].IndicatorPointer.CheckParam[0].Caption = "Use previous bar value";
   strategy.Slot[0].IndicatorPointer.CheckParam[0].Checked = true;

   strategy.Slot[1].IndicatorName    = "Moving Averages Crossover";
   strategy.Slot[1].SlotType         = SlotTypes_OpenFilter;
   strategy.Slot[1].SignalShift      = 0;
   strategy.Slot[1].SignalRepeat     = 0;
   strategy.Slot[1].IndicatorPeriod  = DataPeriod_M1;
   strategy.Slot[1].IndicatorSymbol  = "";
   strategy.Slot[1].LogicalGroup     = "A";
   strategy.Slot[1].IndicatorPointer = indicatorManager.CreateIndicator("Moving Averages Crossover", SlotTypes_OpenFilter);

   strategy.Slot[1].IndicatorPointer.ListParam[0].Enabled = true;
   strategy.Slot[1].IndicatorPointer.ListParam[0].Caption = "Logic";
   strategy.Slot[1].IndicatorPointer.ListParam[0].Index   = 3;
   strategy.Slot[1].IndicatorPointer.ListParam[0].Text    = "Fast MA is lower than Slow MA";
   strategy.Slot[1].IndicatorPointer.ListParam[1].Enabled = true;
   strategy.Slot[1].IndicatorPointer.ListParam[1].Caption = "Base price";
   strategy.Slot[1].IndicatorPointer.ListParam[1].Index   = 6;
   strategy.Slot[1].IndicatorPointer.ListParam[1].Text    = "Weighted";
   strategy.Slot[1].IndicatorPointer.ListParam[3].Enabled = true;
   strategy.Slot[1].IndicatorPointer.ListParam[3].Caption = "Fast MA method";
   strategy.Slot[1].IndicatorPointer.ListParam[3].Index   = 2;
   strategy.Slot[1].IndicatorPointer.ListParam[3].Text    = "Exponential";
   strategy.Slot[1].IndicatorPointer.ListParam[4].Enabled = true;
   strategy.Slot[1].IndicatorPointer.ListParam[4].Caption = "Slow MA method";
   strategy.Slot[1].IndicatorPointer.ListParam[4].Index   = 1;
   strategy.Slot[1].IndicatorPointer.ListParam[4].Text    = "Weighted";

   strategy.Slot[1].IndicatorPointer.NumParam[0].Enabled = true;
   strategy.Slot[1].IndicatorPointer.NumParam[0].Caption = "Fast MA period";
   strategy.Slot[1].IndicatorPointer.NumParam[0].Value   = Slot1IndParam0;
   strategy.Slot[1].IndicatorPointer.NumParam[1].Enabled = true;
   strategy.Slot[1].IndicatorPointer.NumParam[1].Caption = "Slow MA period";
   strategy.Slot[1].IndicatorPointer.NumParam[1].Value   = Slot1IndParam1;
   strategy.Slot[1].IndicatorPointer.NumParam[2].Enabled = true;
   strategy.Slot[1].IndicatorPointer.NumParam[2].Caption = "Fast MA shift";
   strategy.Slot[1].IndicatorPointer.NumParam[2].Value   = Slot1IndParam2;
   strategy.Slot[1].IndicatorPointer.NumParam[3].Enabled = true;
   strategy.Slot[1].IndicatorPointer.NumParam[3].Caption = "Slow MA shift";
   strategy.Slot[1].IndicatorPointer.NumParam[3].Value   = Slot1IndParam3;

   strategy.Slot[1].IndicatorPointer.CheckParam[0].Enabled = true;
   strategy.Slot[1].IndicatorPointer.CheckParam[0].Caption = "Use previous bar value";
   strategy.Slot[1].IndicatorPointer.CheckParam[0].Checked = true;

   strategy.Slot[2].IndicatorName    = "Vidya Moving Average";
   strategy.Slot[2].SlotType         = SlotTypes_OpenFilter;
   strategy.Slot[2].SignalShift      = 0;
   strategy.Slot[2].SignalRepeat     = 0;
   strategy.Slot[2].IndicatorPeriod  = DataPeriod_M15;
   strategy.Slot[2].IndicatorSymbol  = "";
   strategy.Slot[2].LogicalGroup     = "A";
   strategy.Slot[2].IndicatorPointer = indicatorManager.CreateIndicator("Vidya Moving Average", SlotTypes_OpenFilter);

   strategy.Slot[2].IndicatorPointer.ListParam[0].Enabled = true;
   strategy.Slot[2].IndicatorPointer.ListParam[0].Caption = "Logic";
   strategy.Slot[2].IndicatorPointer.ListParam[0].Index   = 0;
   strategy.Slot[2].IndicatorPointer.ListParam[0].Text    = "The Vidya Moving Average rises";
   strategy.Slot[2].IndicatorPointer.ListParam[2].Enabled = true;
   strategy.Slot[2].IndicatorPointer.ListParam[2].Caption = "Base price";
   strategy.Slot[2].IndicatorPointer.ListParam[2].Index   = 3;
   strategy.Slot[2].IndicatorPointer.ListParam[2].Text    = "Close";

   strategy.Slot[2].IndicatorPointer.NumParam[0].Enabled = true;
   strategy.Slot[2].IndicatorPointer.NumParam[0].Caption = "Period";
   strategy.Slot[2].IndicatorPointer.NumParam[0].Value   = Slot2IndParam0;
   strategy.Slot[2].IndicatorPointer.NumParam[1].Enabled = true;
   strategy.Slot[2].IndicatorPointer.NumParam[1].Caption = "Smooth";
   strategy.Slot[2].IndicatorPointer.NumParam[1].Value   = Slot2IndParam1;

   strategy.Slot[2].IndicatorPointer.CheckParam[0].Enabled = true;
   strategy.Slot[2].IndicatorPointer.CheckParam[0].Caption = "Use previous bar value";
   strategy.Slot[2].IndicatorPointer.CheckParam[0].Checked = true;

   strategy.Slot[3].IndicatorName    = "Vidya Moving Average";
   strategy.Slot[3].SlotType         = SlotTypes_OpenFilter;
   strategy.Slot[3].SignalShift      = 0;
   strategy.Slot[3].SignalRepeat     = 0;
   strategy.Slot[3].IndicatorPeriod  = DataPeriod_M15;
   strategy.Slot[3].IndicatorSymbol  = "";
   strategy.Slot[3].LogicalGroup     = "A";
   strategy.Slot[3].IndicatorPointer = indicatorManager.CreateIndicator("Vidya Moving Average", SlotTypes_OpenFilter);

   strategy.Slot[3].IndicatorPointer.ListParam[0].Enabled = true;
   strategy.Slot[3].IndicatorPointer.ListParam[0].Caption = "Logic";
   strategy.Slot[3].IndicatorPointer.ListParam[0].Index   = 0;
   strategy.Slot[3].IndicatorPointer.ListParam[0].Text    = "The Vidya Moving Average rises";
   strategy.Slot[3].IndicatorPointer.ListParam[2].Enabled = true;
   strategy.Slot[3].IndicatorPointer.ListParam[2].Caption = "Base price";
   strategy.Slot[3].IndicatorPointer.ListParam[2].Index   = 3;
   strategy.Slot[3].IndicatorPointer.ListParam[2].Text    = "Close";

   strategy.Slot[3].IndicatorPointer.NumParam[0].Enabled = true;
   strategy.Slot[3].IndicatorPointer.NumParam[0].Caption = "Period";
   strategy.Slot[3].IndicatorPointer.NumParam[0].Value   = Slot3IndParam0;
   strategy.Slot[3].IndicatorPointer.NumParam[1].Enabled = true;
   strategy.Slot[3].IndicatorPointer.NumParam[1].Caption = "Smooth";
   strategy.Slot[3].IndicatorPointer.NumParam[1].Value   = Slot3IndParam1;

   strategy.Slot[3].IndicatorPointer.CheckParam[0].Enabled = true;
   strategy.Slot[3].IndicatorPointer.CheckParam[0].Caption = "Use previous bar value";
   strategy.Slot[3].IndicatorPointer.CheckParam[0].Checked = true;

   strategy.Slot[4].IndicatorName    = "Fractal";
   strategy.Slot[4].SlotType         = SlotTypes_Close;
   strategy.Slot[4].SignalShift      = 0;
   strategy.Slot[4].SignalRepeat     = 0;
   strategy.Slot[4].IndicatorPeriod  = DataPeriod_M1;
   strategy.Slot[4].IndicatorSymbol  = "";
   strategy.Slot[4].LogicalGroup     = "";
   strategy.Slot[4].IndicatorPointer = indicatorManager.CreateIndicator("Fractal", SlotTypes_Close);

   strategy.Slot[4].IndicatorPointer.ListParam[0].Enabled = true;
   strategy.Slot[4].IndicatorPointer.ListParam[0].Caption = "Logic";
   strategy.Slot[4].IndicatorPointer.ListParam[0].Index   = 1;
   strategy.Slot[4].IndicatorPointer.ListParam[0].Text    = "Exit long at Down Fractal";
   strategy.Slot[4].IndicatorPointer.ListParam[1].Enabled = true;
   strategy.Slot[4].IndicatorPointer.ListParam[1].Caption = "Visibility";
   strategy.Slot[4].IndicatorPointer.ListParam[1].Index   = 1;
   strategy.Slot[4].IndicatorPointer.ListParam[1].Text    = "Visible or shadowed";

   strategy.Slot[4].IndicatorPointer.NumParam[0].Enabled = true;
   strategy.Slot[4].IndicatorPointer.NumParam[0].Caption = "Vertical shift";
   strategy.Slot[4].IndicatorPointer.NumParam[0].Value   = Slot4IndParam0;



    delete indicatorManager;

    return strategy;
  }
//+------------------------------------------------------------------+

#define OP_FLAT          -1
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Position
  {
public:
   // Constructors
                     Position(void);

   // Properties
   int               PosType;
   PosDirection      Direction;
   double            Lots;
   datetime          OpenTime;
   double            OpenPrice;
   double            StopLossPrice;
   double            TakeProfitPrice;
   double            Profit;
   double            Commission;
   long              Ticket;
   string            PosComment;

   // Methods
   string            ToString();

   void              SetPositionInfo(string &positionInfo[]);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Position::Position(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Position::ToString()
  {
   if(PosType==OP_FLAT)
      return ("Position: Flat");

   string text =  "Position: "  +
                  "Time="       + TimeToString(OpenTime,TIME_SECONDS)     +", "+
                  "Type="       + (PosType==OP_BUY ? "Long" : "Short")    +", "+
                  "Lots="       + DoubleToString(Lots,2)                  +", "+
                  "Price="      + DoubleToString(OpenPrice,_Digits)       +", "+
                  "StopLoss="   + DoubleToString(StopLossPrice,_Digits)   +", "+
                  "TakeProfit=" + DoubleToString(TakeProfitPrice,_Digits) +", "+
                  "Commission=" + DoubleToString(Commission,2)            +", "+
                  "Profit="     + DoubleToString(Profit,2);

   if(PosComment!="")
      text+=", \""+PosComment+"\"";

   return (text);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Position::SetPositionInfo(string &positionInfo[])
  {
   if(PosType==OP_FLAT)
     {
      positionInfo[0] = "Position: Flat";
      positionInfo[1] = ".";
     }
   else
     {
      positionInfo[0]=StringFormat("Position: %s %.2f at %s, Profit %.2f",
                                   (PosType==OP_BUY) ? "Long" : "Short",
                                   Lots,
                                   DoubleToString(OpenPrice,_Digits),
                                   Profit);
      positionInfo[1]=StringFormat("Stop Loss: %s, Take Profit: %s",
                                   DoubleToString(StopLossPrice,_Digits),
                                   DoubleToString(TakeProfitPrice,_Digits));
     }
  }
//+------------------------------------------------------------------+

class Logger
  {
   int               logLines;
   int               fileHandle;

public:
   string            GetLogFileName(string symbol,int dataPeriod,int expertMagic);
   int               CreateLogFile(string fileName);
   void              WriteLogLine(string text);
   void              WriteNewLogLine(string text);
   void              WriteLogRequest(string text,string request);
   bool              IsLogLinesLimitReached(int maxLines);
   void              FlushLogFile(void);
   void              CloseLogFile(void);
   int               CloseExpert(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Logger::GetLogFileName(string symbol,int dataPeriod,int expertMagic)
  {
   string time=TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS);
   StringReplace(time,":","");
   StringReplace(time," ","_");
   string rnd=IntegerToString(MathRand());
   string fileName=symbol+"_"+IntegerToString(dataPeriod)+"_"+
                   IntegerToString(expertMagic)+"_"+time+"_"+rnd+".log";
   return (fileName);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Logger::CreateLogFile(string fileName)
  {
   logLines=0;
   int handle=FileOpen(fileName,FILE_CSV|FILE_WRITE,",");
   if(handle>0)
      fileHandle=handle;
   else
      Print("CreateFile: Error while creating log file!");
   return (handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Logger::WriteLogLine(string text)
  {
   if(fileHandle <= 0) return;
   FileWrite(fileHandle,TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),text);
   logLines++;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Logger::WriteNewLogLine(string text)
  {
   if(fileHandle <= 0) return;
   FileWrite(fileHandle,"");
   FileWrite(fileHandle,TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),text);
   logLines+=2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Logger::WriteLogRequest(string text,string request)
  {
   if(fileHandle <= 0) return;
   FileWrite(fileHandle,"\n"+text);
   FileWrite(fileHandle,TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),request);
   logLines+=3;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Logger::FlushLogFile()
  {
   if(fileHandle <= 0) return;
   FileFlush(fileHandle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Logger::CloseLogFile()
  {
   if(fileHandle <= 0) return;
   WriteNewLogLine(StringFormat("%s Closed.",MQLInfoString(MQL_PROGRAM_NAME)));
   FileClose(fileHandle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Logger::IsLogLinesLimitReached(int maxLines)
  {
   return (logLines > maxLines);
  }
//+------------------------------------------------------------------+

class ActionTrade;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class StrategyTrader
  {
private:
   ActionTrade      *actionTrade;
   Strategy         *strategy;
   DataMarket       *market;

   double            epsilon;
   bool              isEnteredLong;
   bool              isEnteredShort;
   datetime          timeLastEntryBar;
   datetime          barOpenTimeForLastCloseTick;

   StrategyPriceType openStrPriceType;
   StrategyPriceType closeStrPriceType;
   int               nBarExit;

   ExecutionTime     openTimeExec;
   ExecutionTime     closeTimeExec;
   bool              useLogicalGroups;
   DictStringBool   *groupsAllowLong;
   DictStringBool   *groupsAllowShort;
   ListString       *openingLogicGroups;
   ListString       *closingLogicGroups;

   PosDirection      GetNewPositionDirection(OrderDirection ordDir,double ordLots,PosDirection posDir,double posLots);
   TradeDirection    AnalyzeEntryPrice(void);
   TradeDirection    AnalyzeEntryDirection(void);
   void              AnalyzeEntryLogicConditions(string group,double buyPrice,double sellPrice,bool &canOpenLong,bool &canOpenShort);
   double            AnalyzeEntrySize(OrderDirection ordDir,PosDirection &newPosDir);
   TradeDirection    AnalyzeExitPrice(void);
   double            TradingSize(double size);
   int               AccountPercentStopPoint(double percent,double lots);
   TradeDirection    AnalyzeExitDirection(void);
   TradeDirection    ReduceDirectionStatus(TradeDirection baseDirection,TradeDirection direction);
   TradeDirection    IncreaseDirectionStatus(TradeDirection baseDirection,TradeDirection direction);
   TradeDirection    GetClosingDirection(TradeDirection baseDirection,IndComponentType compDataType);
   int               GetStopLossPoints(double lots);
   int               GetTakeProfitPoints(void);
   void              DoEntryTrade(TradeDirection tradeDir);
   bool              DoExitTrade(void);

public:
   // Constructor, deconstructor
                     StrategyTrader(ActionTrade *actTrade);
                    ~StrategyTrader(void);

   // Methods
   void              OnInit(Strategy *strat,DataMarket *dataMarket);
   void              OnDeinit();
   void              InitTrade(void);
   TickType          GetTickType(bool isNewBar,int closeAdvance);
   void              CalculateTrade(TickType ticktype);

   bool              IsWrongStopsExecution(void);
   void              ResendWrongStops(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StrategyTrader::StrategyTrader(ActionTrade *actTrade)
  {
   actionTrade=actTrade;
   epsilon=0.000001;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StrategyTrader::~StrategyTrader(void)
  {
   actionTrade = NULL;
   strategy    = NULL;
   market      = NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StrategyTrader::OnInit(Strategy *strat,DataMarket *dataMarket)
  {
   strategy = strat;
   market   = dataMarket;

   groupsAllowLong    = new DictStringBool();
   groupsAllowShort   = new DictStringBool();
   openingLogicGroups = new ListString();
   closingLogicGroups = new ListString();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StrategyTrader::OnDeinit(void)
  {
   delete groupsAllowLong;
   delete groupsAllowShort;
   delete openingLogicGroups;
   delete closingLogicGroups;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TickType StrategyTrader::GetTickType(bool isNewBar,int closeAdvance)
  {
   TickType tickType     = TickType_Regular;
   datetime barCloseTime = market.BarTime + market.Period*60;

   if(isNewBar)
     {
      barOpenTimeForLastCloseTick=-1;
      tickType=TickType_Open;
     }

   if(market.TickServerTime>barCloseTime-closeAdvance)
     {
      if(barOpenTimeForLastCloseTick==market.BarTime)
        {
         tickType=TickType_AfterClose;
        }
      else
        {
         barOpenTimeForLastCloseTick=market.BarTime;
         tickType=isNewBar ? TickType_OpenClose : TickType_Close;
        }
     }

   return (tickType);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StrategyTrader::CalculateTrade(TickType ticktype)
  {
// Exift
   bool closeOk=false;

   if(closeStrPriceType!=StrategyPriceType_CloseAndReverse && 
      (market.PositionDirection==PosDirection_Short || market.PositionDirection==PosDirection_Long))
     {
      if(ticktype==TickType_Open && closeStrPriceType==StrategyPriceType_Close && openStrPriceType!=StrategyPriceType_Close)
        {  // We have missed close at the previous Bar Close
         TradeDirection direction=AnalyzeExitDirection();
         if(direction==TradeDirection_Both || 
            (direction == TradeDirection_Long  && market.PositionDirection == PosDirection_Short) ||
            (direction == TradeDirection_Short && market.PositionDirection == PosDirection_Long))
           {  // we have a missed close Order
            if(DoExitTrade())
               actionTrade.UpdateDataMarket(market);
           }
        }
      else if(((closeStrPriceType==StrategyPriceType_Open)  && (ticktype==TickType_Open  || ticktype==TickType_OpenClose)) || 
              ((closeStrPriceType==StrategyPriceType_Close) && (ticktype==TickType_Close || ticktype==TickType_OpenClose)))
        {  // Exit at Bar Open or Bar Close.
         TradeDirection direction=AnalyzeExitDirection();
         if(direction==TradeDirection_Both || 
            (direction == TradeDirection_Long  && market.PositionDirection == PosDirection_Short) ||
            (direction == TradeDirection_Short && market.PositionDirection == PosDirection_Long))
           { // Close the current position.
            closeOk=DoExitTrade();
            if(closeOk)
               actionTrade.UpdateDataMarket(market);
           }
        }
      else if(closeStrPriceType==StrategyPriceType_Close && openStrPriceType!=StrategyPriceType_Close && ticktype==TickType_AfterClose)
        {  // Exit at after close tick.
         TradeDirection direction=AnalyzeExitDirection();
         if(direction==TradeDirection_Both || 
            (direction == TradeDirection_Long  && market.PositionDirection == PosDirection_Short) ||
            (direction == TradeDirection_Short && market.PositionDirection == PosDirection_Long))
            closeOk=DoExitTrade(); // Close the current position.
        }
      else if(closeStrPriceType==StrategyPriceType_Indicator)
        { // Exit at an indicator value.
         TradeDirection priceReached=AnalyzeExitPrice();
         if(priceReached==TradeDirection_Long)
           {
            TradeDirection direction=AnalyzeExitDirection();
            if(direction==TradeDirection_Long || direction==TradeDirection_Both)
              {
               if(market.PositionDirection==PosDirection_Short)
                  closeOk=DoExitTrade(); // Close a short position.
              }
           }
         else if(priceReached==TradeDirection_Short)
           {
            TradeDirection direction=AnalyzeExitDirection();
            if(direction==TradeDirection_Short || direction==TradeDirection_Both)
              {
               if(market.PositionDirection==PosDirection_Long)
                 closeOk=DoExitTrade(); // Close a long position.
              }   
           }
         else if(priceReached==TradeDirection_Both)
           {
            TradeDirection direction=AnalyzeExitDirection();
            if(direction==TradeDirection_Long || direction==TradeDirection_Short || direction==TradeDirection_Both)
               closeOk=DoExitTrade(); // Close the current position.
           }
        }
     }

// Checks if we closed a position successfully.
   if(closeOk && !(openStrPriceType==StrategyPriceType_Close && ticktype==TickType_Close))
      return;

// This is to prevent new entry after Bar Closing has been executed.
   if(closeStrPriceType==StrategyPriceType_Close && ticktype==TickType_AfterClose)
      return;

   if(((openStrPriceType==StrategyPriceType_Open) && (ticktype==TickType_Open || ticktype==TickType_OpenClose)) ||
      ((openStrPriceType==StrategyPriceType_Close) && (ticktype==TickType_Close || ticktype==TickType_OpenClose)))
     { // Entry at Bar Open or Bar Close.
      TradeDirection direction=AnalyzeEntryDirection();
      if(direction==TradeDirection_Long || direction==TradeDirection_Short)
         DoEntryTrade(direction);
     }
   else if(openStrPriceType==StrategyPriceType_Indicator)
     { // Entry at an indicator value.
      TradeDirection priceReached=AnalyzeEntryPrice();
      if(priceReached==TradeDirection_Long)
        {
         TradeDirection direction=AnalyzeEntryDirection();
         if(direction==TradeDirection_Long || direction==TradeDirection_Both)
            DoEntryTrade(TradeDirection_Long);
        }
      else if(priceReached==TradeDirection_Short)
        {
         TradeDirection direction=AnalyzeEntryDirection();
         if(direction==TradeDirection_Short || direction==TradeDirection_Both)
            DoEntryTrade(TradeDirection_Short);
        }
      else if(priceReached==TradeDirection_Both)
        {
         TradeDirection direction=AnalyzeEntryDirection();
         if(direction==TradeDirection_Long || direction==TradeDirection_Short)
            DoEntryTrade(direction);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PosDirection StrategyTrader::GetNewPositionDirection(OrderDirection ordDir,double ordLots,
                                                     PosDirection posDir,double posLots)
  {
   if(ordDir!=OrderDirection_Buy && ordDir!=OrderDirection_Sell)
      return (PosDirection_None);

   PosDirection currentDir=posDir;
   double currentLots=posLots;

   switch(currentDir)
     {
      case PosDirection_Long:
         if(ordDir==OrderDirection_Buy)
            return (PosDirection_Long);
         if(currentLots>ordLots+epsilon)
            return (PosDirection_Long);
         return (currentLots < ordLots - epsilon ? PosDirection_Short : PosDirection_None);
      case PosDirection_Short:
         if(ordDir==OrderDirection_Sell)
            return (PosDirection_Short);
         if(currentLots>ordLots+epsilon)
            return (PosDirection_Short);
         return (currentLots < ordLots - epsilon ? PosDirection_Long : PosDirection_None);
     }

   return (ordDir == OrderDirection_Buy ? PosDirection_Long : PosDirection_Short);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StrategyTrader::InitTrade()
  {
   openTimeExec=strategy.Slot[0].IndicatorPointer.ExecTime;
   openStrPriceType=StrategyPriceType_Unknown;
   if(openTimeExec==ExecutionTime_AtBarOpening)
      openStrPriceType=StrategyPriceType_Open;
   else if(openTimeExec==ExecutionTime_AtBarClosing)
      openStrPriceType=StrategyPriceType_Close;
   else
      openStrPriceType=StrategyPriceType_Indicator;

   closeTimeExec=strategy.Slot[strategy.CloseSlotNumber()].IndicatorPointer.ExecTime;
   closeStrPriceType=StrategyPriceType_Unknown;
   if(closeTimeExec==ExecutionTime_AtBarOpening)
      closeStrPriceType=StrategyPriceType_Open;
   else if(closeTimeExec==ExecutionTime_AtBarClosing)
      closeStrPriceType=StrategyPriceType_Close;
   else if(closeTimeExec==ExecutionTime_CloseAndReverse)
      closeStrPriceType=StrategyPriceType_CloseAndReverse;
   else
      closeStrPriceType=StrategyPriceType_Indicator;

   useLogicalGroups=strategy.IsUsingLogicalGroups();

   if(useLogicalGroups)
     {
      strategy.Slot[0].LogicalGroup="All";
      strategy.Slot[strategy.CloseSlotNumber()].LogicalGroup="All";

      for(int slot=0; slot<strategy.CloseSlotNumber(); slot++)
        {
         if(!groupsAllowLong.ContainsKey(strategy.Slot[slot].LogicalGroup))
            groupsAllowLong.Add(strategy.Slot[slot].LogicalGroup, false);
         if(!groupsAllowShort.ContainsKey(strategy.Slot[slot].LogicalGroup))
            groupsAllowShort.Add(strategy.Slot[slot].LogicalGroup, false);
        }

      // List of logical groups
      int longCount=groupsAllowLong.Count();
      for(int i=0; i<longCount; i++)
        {
         openingLogicGroups.Add(groupsAllowLong.Key(i));
        }

      // Logical groups of the closing conditions.
      for(int slot=strategy.CloseSlotNumber()+1; slot<strategy.Slots(); slot++)
        {
         string group=strategy.Slot[slot].LogicalGroup;
         if(!closingLogicGroups.Contains(group) && group!="all")
            closingLogicGroups.Add(group); // Adds all groups except "all"
        }

      if(closingLogicGroups.Count()==0)
         closingLogicGroups.Add("all");
     }

// Search if N Bars Exit is present as CloseFilter,
// could be any slot after first closing slot.
   nBarExit=0;
   for(int slot=strategy.CloseSlotNumber(); slot<strategy.Slots(); slot++)
     {
      if(strategy.Slot[slot].IndicatorName!="N Bars Exit")
         continue;
      nBarExit=(int) strategy.Slot[slot].IndicatorPointer.NumParam[0].Value;
      break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TradeDirection StrategyTrader::AnalyzeEntryPrice(void)
  {
   double buyPrice  = 0;
   double sellPrice = 0;
   for(int i=0; i<strategy.Slot[0].IndicatorPointer.Components(); i++)
     {
      IndicatorComp *component=strategy.Slot[0].IndicatorPointer.Component[i];
      IndComponentType compType=component.DataType;
      if(compType==IndComponentType_OpenLongPrice)
         buyPrice=component.GetLastValue();
      else if(compType==IndComponentType_OpenShortPrice)
         sellPrice=component.GetLastValue();
      else if(compType==IndComponentType_OpenPrice || compType==IndComponentType_OpenClosePrice)
         buyPrice=sellPrice=component.GetLastValue();
      component=NULL;
     }

   double basePrice = market.Close;
   double oldPrice  = market.OldClose;
   bool canOpenLong  = false;
   bool canOpenShort = false;

   if(oldPrice<epsilon)
     {  // OldClose==0 for the first tick.
      canOpenLong  = MathAbs(buyPrice - basePrice) < epsilon;
      canOpenShort = MathAbs(sellPrice - basePrice) < epsilon;
     }
   else
     {
      canOpenLong=(buyPrice>oldPrice+epsilon && buyPrice<basePrice+epsilon) || 
                  (buyPrice>basePrice-epsilon && buyPrice<oldPrice-epsilon);
      canOpenShort=(sellPrice>oldPrice+epsilon && sellPrice<basePrice+epsilon) || 
                   (sellPrice>basePrice-epsilon && sellPrice<oldPrice-epsilon);
     }

   TradeDirection direction=TradeDirection_None;

   if(canOpenLong && canOpenShort)
      direction=TradeDirection_Both;
   else if(canOpenLong)
      direction=TradeDirection_Long;
   else if(canOpenShort)
      direction=TradeDirection_Short;

   return (direction);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TradeDirection StrategyTrader::AnalyzeEntryDirection()
  {
// Do not send entry order when we are not on time
   if(openTimeExec==ExecutionTime_AtBarOpening)
      for(int i=0; i<strategy.Slot[0].IndicatorPointer.Components(); i++)
        {
         IndicatorComp *component=strategy.Slot[0].IndicatorPointer.Component[i];
         if(component.DataType != IndComponentType_OpenLongPrice && 
            component.DataType != IndComponentType_OpenShortPrice &&
            component.DataType != IndComponentType_OpenPrice)
            continue;
         if(component.GetLastValue()<epsilon)
            return (TradeDirection_None);
         component=NULL;
        }

   for(int i=0; i<strategy.Slots(); i++)
     {
      if(strategy.Slot[i].IndicatorName=="Enter Once")
        {
         string logicText=strategy.Slot[i].IndicatorPointer.ListParam[0].Text;
         if(logicText=="Enter no more than once a bar")
           {
            if(market.BarTime==timeLastEntryBar)
               return (TradeDirection_None);
           }
         else if(logicText=="Enter no more than once a day")
           {
            if(TimeDayOfYear(market.BarTime)==TimeDayOfYear(timeLastEntryBar))
               return (TradeDirection_None);
           }
         else if(logicText=="Enter no more than once a week")
           {
            if(TimeDayOfWeek(market.BarTime)>=TimeDayOfWeek(timeLastEntryBar) && 
               market.BarTime<timeLastEntryBar+7*24*60*60)
               return (TradeDirection_None);
           }
         else if(logicText=="Enter no more than once a month")
           {
            if(TimeMonth(market.BarTime)==TimeMonth(timeLastEntryBar))
               return (TradeDirection_None);
           }
        }
     }

// Determining of the buy/sell entry prices.
   double buyPrice=0;
   double sellPrice=0;
   for(int i=0; i<strategy.Slot[0].IndicatorPointer.Components(); i++)
     {
      IndicatorComp *component=strategy.Slot[0].IndicatorPointer.Component[i];
      IndComponentType compType=component.DataType;
      if(compType==IndComponentType_OpenLongPrice)
         buyPrice=component.GetLastValue();
      else if(compType==IndComponentType_OpenShortPrice)
         sellPrice=component.GetLastValue();
      else if(compType==IndComponentType_OpenPrice || compType==IndComponentType_OpenClosePrice)
         buyPrice=sellPrice=component.GetLastValue();
      component=NULL;
     }

// Decide whether to open
   bool canOpenLong=buyPrice>epsilon;
   bool canOpenShort=sellPrice>epsilon;

   if(useLogicalGroups)
     {
      for(int i=0; i<openingLogicGroups.Count(); i++)
        {
         string group=openingLogicGroups.Get(i);

         bool groupOpenLong=canOpenLong;
         bool groupOpenShort=canOpenShort;

         AnalyzeEntryLogicConditions(group,buyPrice,sellPrice,groupOpenLong,groupOpenShort);

         groupsAllowLong.Set(group,groupOpenLong);
         groupsAllowShort.Set(group,groupOpenShort);
        }

      bool groupLongEntry=false;
      for(int i=0; i<groupsAllowLong.Count(); i++)
        {
         string key = groupsAllowLong.Key(i);
         bool value = groupsAllowLong.Value(key);
         if((groupsAllowLong.Count()>1 && key!="All") || groupsAllowLong.Count()==1)
            groupLongEntry=groupLongEntry || value;
        }

      bool groupShortEntry=false;
      for(int i=0; i<groupsAllowShort.Count(); i++)
        {
         string key = groupsAllowShort.Key(i);
         bool value = groupsAllowShort.Value(key);
         if((groupsAllowShort.Count()>1 && key!="All") || groupsAllowShort.Count()==1)
            groupShortEntry=groupShortEntry || value;
        }

      canOpenLong=canOpenLong && groupLongEntry && groupsAllowLong.Value("All");
      canOpenShort=canOpenShort && groupShortEntry && groupsAllowShort.Value("All");
     }
   else
     {
      AnalyzeEntryLogicConditions("A",buyPrice,sellPrice,canOpenLong,canOpenShort);
     }

   TradeDirection direction=TradeDirection_None;
   if(canOpenLong && canOpenShort)
      direction=TradeDirection_Both;
   else if(canOpenLong)
      direction=TradeDirection_Long;
   else if(canOpenShort)
      direction=TradeDirection_Short;

   return (direction);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StrategyTrader::AnalyzeEntryLogicConditions(string group,double buyPrice,double sellPrice,
                                                 bool &canOpenLong,bool &canOpenShort)
  {
   for(int slotIndex=0; slotIndex<=strategy.CloseSlotNumber(); slotIndex++)
     {
      if(useLogicalGroups && 
         strategy.Slot[slotIndex].LogicalGroup != group &&
         strategy.Slot[slotIndex].LogicalGroup != "All")
         continue;

      for(int i=0; i<strategy.Slot[slotIndex].IndicatorPointer.Components(); i++)
        {
         IndicatorComp *component=strategy.Slot[slotIndex].IndicatorPointer.Component[i];
         if(component.PosPriceDependence==PositionPriceDependence_None)
           {
            if(component.DataType==IndComponentType_AllowOpenLong && 
               component.GetLastValue()<0.5)
               canOpenLong=false;

            if(component.DataType==IndComponentType_AllowOpenShort && 
               component.GetLastValue()<0.5)
               canOpenShort=false;
           }
         else
           {
            int previous=strategy.Slot[slotIndex].GetUsePreviousBarValue() ? 1 : 0;
            if(strategy.IsLongerTimeFrame(slotIndex))
               previous=0;

            double indicatorValue=component.GetLastValue(previous);

            if (indicatorValue > epsilon)
              {
                switch(component.PosPriceDependence)
                  {
                   case PositionPriceDependence_PriceBuyHigher:
                      canOpenLong=canOpenLong && buyPrice>indicatorValue+epsilon;
                      break;
                   case PositionPriceDependence_PriceBuyLower:
                      canOpenLong=canOpenLong && buyPrice<indicatorValue-epsilon;
                      break;
                   case PositionPriceDependence_PriceSellHigher:
                      canOpenShort=canOpenShort && sellPrice>indicatorValue+epsilon;
                      break;
                   case PositionPriceDependence_PriceSellLower:
                      canOpenShort=canOpenShort && sellPrice<indicatorValue-epsilon;
                      break;
                   case PositionPriceDependence_BuyHigherSellLower:
                      canOpenLong  = canOpenLong  && buyPrice  > indicatorValue + epsilon;
                      canOpenShort = canOpenShort && sellPrice < indicatorValue - epsilon;
                      break;
                   case PositionPriceDependence_BuyLowerSelHigher: // Deprecated
                   case PositionPriceDependence_BuyLowerSellHigher:
                      canOpenLong  = canOpenLong  && buyPrice  < indicatorValue - epsilon;
                      canOpenShort = canOpenShort && sellPrice > indicatorValue + epsilon;
                      break;
                  }
               }
            else
              {
                canOpenLong  = false;
                canOpenShort = false;
              }
           }
         component=NULL;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StrategyTrader::AnalyzeEntrySize(OrderDirection ordDir,PosDirection &newPosDir)
  {
   double size=0;
   PosDirection posDir=market.PositionDirection;
// Orders modification on a fly
// Checks whether we are on the market
   if(posDir==PosDirection_Long || posDir==PosDirection_Short)
     {
      // We are on the market and have Same Dir Signal
      if((ordDir==OrderDirection_Buy && posDir==PosDirection_Long) || 
         (ordDir==OrderDirection_Sell && posDir==PosDirection_Short))
        {
         size=0;
         newPosDir=posDir;
         if(market.PositionLots+TradingSize(strategy.AddingLots)<
            strategy.MaxOpenLots+market.LotStep/2)
           {
            switch(strategy.SameSignalAction)
              {
               case SameDirSignalAction_Add:
                  size=TradingSize(strategy.AddingLots);
                  break;
               case SameDirSignalAction_Winner:
                  if(market.PositionProfit>epsilon)
                  size=TradingSize(strategy.AddingLots);
                  break;
               case SameDirSignalAction_Loser:
                  if(market.PositionProfit<-epsilon)
                  size=TradingSize(strategy.AddingLots);
                  break;
              }
           }
        }
      else if((ordDir==OrderDirection_Buy && posDir==PosDirection_Short) || 
         (ordDir==OrderDirection_Sell && posDir==PosDirection_Long))
           {
            // In case of an Opposite Dir Signal
            switch(strategy.OppSignalAction)
              {
               case OppositeDirSignalAction_Reduce:
                  if(market.PositionLots>TradingSize(strategy.ReducingLots))
                    { // Reducing
                     size=TradingSize(strategy.ReducingLots);
                     newPosDir=posDir;
                    }
                  else
                    { // Closing
                     size=market.PositionLots;
                     newPosDir=PosDirection_Closed;
                    }
                  break;
               case OppositeDirSignalAction_Close:
                  size=market.PositionLots;
                  newPosDir=PosDirection_Closed;
                  break;
               case OppositeDirSignalAction_Reverse:
                  size=market.PositionLots+TradingSize(strategy.EntryLots);
                  newPosDir=(posDir==PosDirection_Long) ? PosDirection_Short : PosDirection_Long;
                  break;
               case OppositeDirSignalAction_Nothing:
                  size=0;
                  newPosDir=posDir;
                  break;
              }
           }
        }
      else
        {
         // We are square on the market
         size=TradingSize(strategy.EntryLots);
         if(strategy.UseMartingale && market.ConsecutiveLosses>0)
           {
            double correctedAmount=size*MathPow(strategy.MartingaleMultiplier,market.ConsecutiveLosses);
            double normalizedAmount=actionTrade.NormalizeEntrySize(correctedAmount);
            size=MathMax(normalizedAmount,market.MinLot);
           }
         size=MathMin(size,strategy.MaxOpenLots);

         newPosDir=(ordDir==OrderDirection_Buy) ? PosDirection_Long : PosDirection_Short;
        }
      return (size);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   TradeDirection StrategyTrader::AnalyzeExitPrice()
     {
      IndicatorSlot *slot=strategy.Slot[strategy.CloseSlotNumber()];

      // Searching the exit price in the exit indicator slot.
      double buyPrice=0;
      double sellPrice=0;
      for(int i=0; i<slot.IndicatorPointer.Components(); i++)
        {
         IndicatorComp *comp=slot.IndicatorPointer.Component[i];
         IndComponentType compType=comp.DataType;

         if(compType==IndComponentType_CloseLongPrice)
            sellPrice=comp.GetLastValue();
         else if(compType==IndComponentType_CloseShortPrice)
            buyPrice=comp.GetLastValue();
         else if(compType==IndComponentType_ClosePrice || 
            compType==IndComponentType_OpenClosePrice)
            buyPrice=sellPrice=comp.GetLastValue();

         comp=NULL;
        }

      // We can close if the closing price is higher than zero.
      bool canCloseLong=sellPrice>epsilon;
      bool canCloseShort=buyPrice>epsilon;

      // Check if the closing price was reached.
      if(canCloseLong)
        {
         canCloseLong=(sellPrice>market.OldBid+epsilon && sellPrice<market.Bid+epsilon) || 
                      (sellPrice<market.OldBid-epsilon && sellPrice>market.Bid-epsilon);
        }
      if(canCloseShort)
        {
         canCloseShort=(buyPrice>market.OldBid+epsilon && buyPrice<market.Bid+epsilon) || 
                       (buyPrice<market.OldBid-epsilon && buyPrice>market.Bid-epsilon);
        }                 

      // Determine the trading direction.
      TradeDirection direction=TradeDirection_None;

      if(canCloseLong && canCloseShort)
         direction=TradeDirection_Both;
      else if(canCloseLong)
         direction=TradeDirection_Short;
      else if(canCloseShort)
         direction=TradeDirection_Long;

      slot=NULL;
      return (direction);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   TradeDirection StrategyTrader::AnalyzeExitDirection()
     {
      int closeSlot=strategy.CloseSlotNumber();

      if(closeTimeExec==ExecutionTime_AtBarClosing)
         for(int i=0; i<strategy.Slot[closeSlot].IndicatorPointer.Components(); i++)
           {
            IndComponentType dataType=strategy.Slot[closeSlot].IndicatorPointer.Component[i].DataType;
            double value = strategy.Slot[closeSlot].IndicatorPointer.Component[i].GetLastValue();
            if(dataType != IndComponentType_CloseLongPrice &&
               dataType != IndComponentType_CloseShortPrice &&
               dataType != IndComponentType_ClosePrice)
               continue;
            if(value<epsilon)
               return (TradeDirection_None);
           }

      if(strategy.CloseSlots()==0)
         return (TradeDirection_Both);

      if(nBarExit>0 && 
         (market.PositionOpenTime+(nBarExit *((int) market.Period*60))<market.TickServerTime))
         return (TradeDirection_Both);

      TradeDirection direction=TradeDirection_None;

      if(useLogicalGroups)
        {
         for(int i=0; i<closingLogicGroups.Count(); i++)
           {
            string group=closingLogicGroups.Get(i);
            TradeDirection groupDirection=TradeDirection_Both;

            // Determining of the slot direction
            for(int slot=strategy.CloseSlotNumber()+1; slot<strategy.Slots(); slot++)
              {
               TradeDirection slotDirection=TradeDirection_None;
               if(strategy.Slot[slot].LogicalGroup==group || strategy.Slot[slot].LogicalGroup=="all")
                 {
                  for(int c=0; c<strategy.Slot[slot].IndicatorPointer.Components(); c++)
                    {
                     if(strategy.Slot[slot].IndicatorPointer.Component[c].GetLastValue()>0)
                        slotDirection=GetClosingDirection(slotDirection,strategy.Slot[slot].IndicatorPointer.Component[c].DataType);
                    }      

                  groupDirection=ReduceDirectionStatus(groupDirection,slotDirection);
                 }
              }

            direction=IncreaseDirectionStatus(direction,groupDirection);
           }
        }
      else
        {   // Search close filters for a closing signal.
         for(int slot=strategy.CloseSlotNumber()+1; slot<strategy.Slots(); slot++)
           {
            for(int c=0; c<strategy.Slot[slot].IndicatorPointer.Components(); c++)
              {
               if(strategy.Slot[slot].IndicatorPointer.Component[c].GetLastValue()>epsilon)
                  direction=GetClosingDirection(direction,strategy.Slot[slot].IndicatorPointer.Component[c].DataType);
              }
           }     
        }

      return (direction);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   TradeDirection StrategyTrader::ReduceDirectionStatus(TradeDirection baseDirection,TradeDirection direction)
     {
      if(baseDirection==direction || direction==TradeDirection_Both)
         return (baseDirection);

      if(baseDirection==TradeDirection_Both)
         return (direction);

      return (TradeDirection_None);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   TradeDirection StrategyTrader::IncreaseDirectionStatus(TradeDirection baseDirection,TradeDirection direction)
     {
      if(baseDirection==direction || direction==TradeDirection_None)
         return (baseDirection);

      if(baseDirection==TradeDirection_None)
         return (direction);

      return (TradeDirection_Both);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   TradeDirection StrategyTrader::GetClosingDirection(TradeDirection baseDirection,IndComponentType compDataType)
     {
      TradeDirection newDirection=baseDirection;

      if(compDataType==IndComponentType_ForceClose)
        {
         newDirection=TradeDirection_Both;
        }
      else if(compDataType==IndComponentType_ForceCloseShort)
        {
         if(baseDirection == TradeDirection_None)
            newDirection = TradeDirection_Long;
         else if(baseDirection==TradeDirection_Short)
            newDirection=TradeDirection_Both;
        }
      else if(compDataType==IndComponentType_ForceCloseLong)
        {
         if(baseDirection == TradeDirection_None)
            newDirection = TradeDirection_Short;
         else if(baseDirection==TradeDirection_Long)
            newDirection=TradeDirection_Both;
        }

      return (newDirection);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int StrategyTrader::GetStopLossPoints(double lots)
     {
      int  indStop   = INT_MAX;
      bool isIndStop = true;
      int  closeSlot = strategy.CloseSlotNumber();
      string name=strategy.Slot[closeSlot].IndicatorName;

      if(name=="Account Percent Stop")
         indStop=AccountPercentStopPoint(strategy.Slot[closeSlot].IndicatorPointer.NumParam[0].Value,lots);
      else if(name== "ATR Stop")
         indStop =(int) MathRound(strategy.Slot[closeSlot].IndicatorPointer.Component[0].GetLastValue()/market.Point);
      else if(name== "Stop Loss"|| name == "Stop Limit")
         indStop =(int) strategy.Slot[closeSlot].IndicatorPointer.NumParam[0].Value;
      else if(name== "Trailing Stop"|| name == "Trailing Stop Limit")
         indStop =(int) strategy.Slot[closeSlot].IndicatorPointer.NumParam[0].Value;
      else
         isIndStop=false;

      int permStop = strategy.UsePermanentSL ? strategy.PermanentSL : INT_MAX;
      int stopLoss = 0;

      if(isIndStop || strategy.UsePermanentSL)
        {
         stopLoss=MathMin(indStop,permStop);
         if(stopLoss<market.StopLevel)
            stopLoss=market.StopLevel;
        }

      return (stopLoss);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int StrategyTrader::GetTakeProfitPoints()
     {
      int    takeprofit = 0;
      int    permLimit  = strategy.UsePermanentTP ? strategy.PermanentTP : INT_MAX;
      int    indLimit   = INT_MAX;
      bool   isIndLimit = true;
      int    closeSlot  = strategy.CloseSlotNumber();
      string name       = strategy.Slot[closeSlot].IndicatorName;

      if(name=="Take Profit")
         indLimit = (int) strategy.Slot[closeSlot].IndicatorPointer.NumParam[0].Value;
      else if(name == "Stop Limit" || name == "Trailing Stop Limit")
         indLimit = (int) strategy.Slot[closeSlot].IndicatorPointer.NumParam[1].Value;
      else
         isIndLimit=false;

      if(isIndLimit || strategy.UsePermanentTP)
        {
         takeprofit=MathMin(indLimit,permLimit);
         if(takeprofit<market.StopLevel)
            takeprofit=market.StopLevel;
        }

      return (takeprofit);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void StrategyTrader::DoEntryTrade(TradeDirection tradeDir)
     {
      OrderDirection  ordDir;
      OperationType   opType;
      TraderOrderType type;

      if(timeLastEntryBar!=market.BarTime)
         isEnteredLong=isEnteredShort=false;

      switch(tradeDir)
        {
         case TradeDirection_Long: // Buy
            if(isEnteredLong)
               return;
            ordDir = OrderDirection_Buy;
            opType = OperationType_Buy;
            type   = TraderOrderType_Buy;
            break;
         case TradeDirection_Short: // Sell
            if(isEnteredShort)
               return;
            ordDir = OrderDirection_Sell;
            opType = OperationType_Sell;
            type   = TraderOrderType_Sell;
            break;
         default: // Wrong direction of trade.
            return;
        }

      PosDirection newPosDir=PosDirection_None;
      double size=AnalyzeEntrySize(ordDir,newPosDir);

      if(size<market.MinLot-epsilon)
         return;  // The entry trade is cancelled.

      TrailingStopMode trlMode=TrailingStopMode_Bar;
      int    trlStop   = 0;
      int    closeSlot = strategy.CloseSlotNumber();
      string name      = strategy.Slot[closeSlot].IndicatorName;

      if(name=="Trailing Stop" || name=="Trailing Stop Limit")
        {
         trlStop=(int) strategy.Slot[closeSlot].IndicatorPointer.NumParam[0].Value;
         string mode=strategy.Slot[closeSlot].IndicatorPointer.ListParam[1].Text;
         if(mode!="New bar")
            trlMode=TrailingStopMode_Tick;
        }

      int stopLoss   = GetStopLossPoints(size);
      int takeProfit = GetTakeProfitPoints();
      int breakEven  = strategy.UseBreakEven ? strategy.BreakEven : 0;

      bool response=actionTrade.ManageOrderSend(type,size,stopLoss,takeProfit,trlMode,trlStop,breakEven);

      if(response)
        { // The order was executed successfully.
         timeLastEntryBar=market.BarTime;
         if(type==TraderOrderType_Buy)
            isEnteredLong=true;
         else
            isEnteredShort=true;

         market.WrongStopLoss   = 0;
         market.WrongTakeProf   = 0;
         market.WrongStopsRetry = 0;
        }
      else
        {  // Error in operation execution.
         market.WrongStopLoss = stopLoss;
         market.WrongTakeProf = takeProfit;
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool StrategyTrader::DoExitTrade()
     {
      if(!market.IsFailedCloseOrder)
         market.IsSentCloseOrder=true;
      market.CloseOrderTickCounter=0;

      bool orderResponse=actionTrade.CloseCurrentPosition();

      market.WrongStopLoss   = 0;
      market.WrongTakeProf   = 0;
      market.WrongStopsRetry = 0;

      return (orderResponse);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool StrategyTrader::IsWrongStopsExecution()
     {
      const int maxRetry=4;

      if(market.PositionDirection==PosDirection_Closed || 
         market.PositionLots < epsilon ||
         market.WrongStopsRetry>=maxRetry)
        {
         market.WrongStopLoss   = 0;
         market.WrongTakeProf   = 0;
         market.WrongStopsRetry = 0;
         return (false);
        }

      bool isWrongStop=(market.WrongStopLoss>0 && market.PositionStopLoss<epsilon) || 
                       (market.WrongTakeProf>0 && market.PositionTakeProfit<epsilon);

      return (isWrongStop);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void StrategyTrader::ResendWrongStops()
     {
      double stopLossPrice=0;
      int stopLoss=market.WrongStopLoss;
      if(stopLoss>0)
        {
         if(market.PositionDirection==PosDirection_Long)
            stopLossPrice=market.Bid-stopLoss*market.Point;
         else if(market.PositionDirection==PosDirection_Short)
            stopLossPrice=market.Ask+stopLoss*market.Point;
        }

      double takeProfitPrice=0;
      int takeProfit=market.WrongTakeProf;
      if(takeProfit>0)
        {
         if(market.PositionDirection==PosDirection_Long)
            takeProfitPrice=market.Bid+takeProfit*market.Point;
         else if(market.PositionDirection==PosDirection_Short)
            takeProfitPrice=market.Ask-takeProfit*market.Point;
        }

      bool isSucess=actionTrade.ModifyPosition(stopLossPrice,takeProfitPrice);

      if(isSucess)
        {
         market.WrongStopLoss   = 0;
         market.WrongTakeProf   = 0;
         market.WrongStopsRetry = 0;
        }
      else
        {
         market.WrongStopsRetry++;
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double StrategyTrader::TradingSize(double size)
     {
      if(strategy.UseAccountPercentEntry)
         size=(size/100)*market.AccountEquity/market.MarginRequired;
      if(size>strategy.MaxOpenLots)
         size=strategy.MaxOpenLots;
      return (actionTrade.NormalizeEntrySize(size));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int StrategyTrader::AccountPercentStopPoint(double percent,double lots)
     {
      double balance   = market.AccountBalance;
      double moneyrisk = balance * percent / 100;
      double spread    = market.Spread;
      double tickvalue = market.TickValue;
      double stoploss  = moneyrisk / (lots * tickvalue) - spread;
      return ((int) MathRound(stoploss));
     }
//+------------------------------------------------------------------+

#define TRADE_RETRY_COUNT 4
#define TRADE_RETRY_WAIT  100
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ActionTrade
  {
private:
   double            epsilon;

   // Fields
   Strategy         *strategy;
   DataSet          *dataSet[];
   DataMarket       *dataMarket;
   Position         *position;
   Logger           *logger;
   StrategyTrader   *strategyTrader;

   // Properties
   int               lastError;
   double            pipsValue;
   int               pipsPoint;
   int               stopLevel;
   datetime          barTime;
   datetime          barHighTime;
   datetime          barLowTime;
   double            barHighPrice;
   double            barLowPrice;
   int               trailingStop;
   TrailingStopMode  trailingMode;
   int               breakEven;
   int               consecutiveLosses;

   string            dynamicInfoParams[];
   string            dynamicInfoValues[];

   // Methods
   bool              CheckEnvironment(int minDataBars);
   bool              CheckChartBarsCount(int minDataBars);
   int               FindBarsCountNeeded(int minDataBars);
   int               SetAggregatePosition(Position *pos);
   void              UpdateDataSet(DataSet *data,int maxBars);
   bool              IsTradeContextFree(void);
   void              ActivateProtectionMinAccount(void);
   void              CloseExpert(void);

   // Trading methods
   double            GetTakeProfitPrice(int type,int takeProfit);
   double            GetStopLossPrice(int type,int stopLoss);
   double            CorrectTakeProfitPrice(int type,double takeProfitPrice);
   double            CorrectStopLossPrice(int type,double stopLossPrice);
   double            NormalizeEntryPrice(double price);
   void              SetMaxStopLoss(void);
   void              SetBreakEvenStop(void);
   void              SetTrailingStop(bool isNewBar);
   void              SetTrailingStopBarMode(void);
   void              SetTrailingStopTickMode(void);
   void              DetectPositionClosing(void);

   // Specific MQ4 trading methods
   bool              OpenNewPosition(int type,double lots,int stopLoss,int takeProfit);
   bool              AddToCurrentPosition(int type,double lots,int stopLoss,int takeProfit);
   bool              ReduceCurrentPosition(double lots,int stopLoss,int takeProfit);
   bool              ReverseCurrentPosition(int type,double lots,int stopLoss,int takeProfit);
   bool              CloseOrder(int orderTicket,double lots);
   bool              SelectOrder(int orderTicket);
   bool              SendOrder(int type,double lots,int stopLoss,int takeProfit);
   bool              ModifyOrder(int orderTicket,double stopLossPrice,double takeProfitPrice);

public:
   // Constructors
                     ActionTrade(void);
                    ~ActionTrade(void);

   // Properties
   double            EntryAmount;
   double            MaximumAmount;
   double            AddingAmount;
   double            ReducingAmount;
   string            OrderComment;
   int               MinDataBars;
   int               ProtectionMinAccount;
   int               ProtectionMaxStopLoss;
   int               ExpertMagic;
   bool              SeparateSLTP;
   bool              WriteLogFile;
   bool              FIFOorder;
   int               TrailingStopMovingStep;
   int               MaxLogLinesInFile;
   int               BarCloseAdvance;

   // Methods
   int               OnInit(void);
   void              OnTick(void);
   void              OnDeinit(const int reason);
   void              UpdateDataMarket(DataMarket *market);
   double            NormalizeEntrySize(double size);
   bool              ManageOrderSend(int type,double lots,int stopLoss,int takeProfit,
                                     TrailingStopMode trlMode,int trlStop,int brkEven);
   bool              ModifyPosition(double stopLossPrice,double takeProfitPrice);
   bool              CloseCurrentPosition(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade::ActionTrade(void)
  {
   epsilon  = 0.000001;
   position = new Position();
   logger   = new Logger();
   strategyTrader=new StrategyTrader(GetPointer(this));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade::~ActionTrade(void)
  {
   if(CheckPointer(position)==POINTER_DYNAMIC)
      delete position;
   if(CheckPointer(logger)==POINTER_DYNAMIC)
      delete logger;
   if(CheckPointer(strategyTrader)==POINTER_DYNAMIC)
      delete strategyTrader;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ActionTrade::OnInit()
  {
   dataMarket     = new DataMarket();
   barHighTime    = 0;
   barLowTime     = 0;
   barHighPrice = 0;
   barLowPrice  = 1000000;

   string message=StringFormat("%s loaded.",MQLInfoString(MQL_PROGRAM_NAME));
   Comment(message);
   Print(message);

   if(WriteLogFile)
     {
      logger.CreateLogFile(logger.GetLogFileName(_Symbol, _Period, ExpertMagic));
      logger.WriteLogLine(message);
      logger.WriteLogLine("Entry Amount: "    + DoubleToString(EntryAmount, 2)   + ", " +
                          "Maximum Amount: "+DoubleToString(MaximumAmount,2)+", "+
                          "Adding Amount: "+DoubleToString(AddingAmount,2)+", "+
                          "Reducing Amount: "+DoubleToString(ReducingAmount,2));
      logger.WriteLogLine("Protection Min Account: "+IntegerToString(ProtectionMinAccount)+", "+
                          "Protection Max StopLoss: "+IntegerToString(ProtectionMaxStopLoss));
      logger.WriteLogLine("Expert Magic: "+IntegerToString(ExpertMagic)+", "+
                          "Bar Close Advance: "+IntegerToString(BarCloseAdvance));
      logger.FlushLogFile();
     }

   if(_Digits==2 || _Digits==3)
      pipsValue=0.01;
   else if(_Digits==4 || _Digits==5)
      pipsValue=0.0001;
   else
      pipsValue=_Digits;

   if(_Digits==3 || _Digits==5)
      pipsPoint=10;
   else
      pipsPoint=1;

   stopLevel=(int) MarketInfo(_Symbol,MODE_STOPLEVEL)+pipsPoint;
   if(stopLevel<3*pipsPoint)
      stopLevel=3*pipsPoint;

   if(ProtectionMaxStopLoss>0 && ProtectionMaxStopLoss<stopLevel)
      ProtectionMaxStopLoss=stopLevel;

   if(TrailingStopMovingStep<pipsPoint)
      TrailingStopMovingStep=pipsPoint;

   StrategyManager *strategyManager=new StrategyManager();

// Strategy initialization
   strategy=strategyManager.GetStrategy();
   strategy.SetSymbol(_Symbol);
   strategy.SetPeriod((DataPeriod) _Period);
   strategy.SetIsTester(MQLInfoInteger(MQL_TESTER));
   strategy.EntryLots    = EntryAmount;
   strategy.MaxOpenLots  = MaximumAmount;
   strategy.AddingLots   = AddingAmount;
   strategy.ReducingLots = ReducingAmount;

   delete strategyManager;

// Checks the requirements.
   bool isEnvironmentGood=CheckEnvironment(strategy.MinBarsRequired);
   if(!isEnvironmentGood)
     {   // There is a non fulfilled condition, therefore we must exit.
      Sleep(20*1000);
      ExpertRemove();
      return (INIT_FAILED);
     }

// Market initialization
   string charts[];
   strategy.GetRequiredCharts(charts);

   string chartsNote="Loading data: ";
   for(int i=0; i<ArraySize(charts); i++)
      chartsNote+=charts[i]+", ";
   chartsNote+="Minumum bars: "+IntegerToString(strategy.MinBarsRequired)+"...";
   Comment(chartsNote);
   Print(chartsNote);

// Initial data loading
   ArrayResize(dataSet,ArraySize(charts));
   for(int i=0; i<ArraySize(charts); i++)
      dataSet[i]=new DataSet(charts[i]);

   SetAggregatePosition(position);

// Checks the necessary bars.
   MinDataBars=FindBarsCountNeeded(MinDataBars);

// Initial strategy calculation
   for(int i=0; i<ArraySize(dataSet); i++)
      UpdateDataSet(dataSet[i],MinDataBars);
   strategy.CalculateStrategy(dataSet);

// Initialize StrategyTrader
   strategyTrader.OnInit(strategy, dataMarket);
   strategyTrader.InitTrade();

// Initialize the chart's info label.
   strategy.DynamicInfoInitArrays(dynamicInfoParams,dynamicInfoValues);
   int paramsX   = 0;
   int valuesX   = 140;
   int locationY = 40;
   color foreColor=GetChartForeColor(0);
   int count = ArraySize(dynamicInfoParams);
   for(int i = 0; i < count; i++)
     {
      string namep = "Lbl_prm_" + IntegerToString(i);
      string namev = "Lbl_val_" + IntegerToString(i);
      string param = dynamicInfoParams[i] == "" ? "." : dynamicInfoParams[i];
      LabelCreate(0,namep,0,paramsX,locationY,CORNER_LEFT_UPPER,param,"Ariel",8,foreColor);
      LabelCreate(0,namev,0,valuesX,locationY,CORNER_LEFT_UPPER,".","Ariel",8,foreColor);
      locationY+=12;
     }

   LabelCreate(0,"Lbl_pos_0",0,350,0,CORNER_LEFT_UPPER,".","Ariel",10,foreColor);
   LabelCreate(0,"Lbl_pos_1",0,350,15,CORNER_LEFT_UPPER,".","Ariel",10,foreColor);
   LabelCreate(0,"Lbl_pos_2",0,350,29,CORNER_LEFT_UPPER,".","Ariel",10,foreColor);

   Comment("");

   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade::OnTick()
  {
   RefreshRates();

   for(int i=0; i<ArraySize(dataSet); i++)
      UpdateDataSet(dataSet[i],MinDataBars);
   UpdateDataMarket(dataMarket);

   bool isNewBar=(barTime<dataMarket.BarTime && dataMarket.Volume<5);
   barTime   = dataMarket.BarTime;
   lastError = 0;

// Checks if minimum account was reached.
   if(ProtectionMinAccount>0 && AccountEquity()<ProtectionMinAccount)
      ActivateProtectionMinAccount();

// Checks and sets Max SL protection.
   if(ProtectionMaxStopLoss>0)
      SetMaxStopLoss();

// Checks if position was closed.
   DetectPositionClosing();

   if(breakEven>0)
      SetBreakEvenStop();

   if(trailingStop>0)
      SetTrailingStop(isNewBar);

   SetAggregatePosition(position);

   if(isNewBar && WriteLogFile)
      logger.WriteNewLogLine(position.ToString());

   if(dataSet[0].Bars>=strategy.MinBarsRequired)
     {
      strategy.CalculateStrategy(dataSet);
      TickType tickType=strategyTrader.GetTickType(isNewBar,BarCloseAdvance);
      strategyTrader.CalculateTrade(tickType);
     }

// Sends OrderModify on SL/TP errors
   if(strategyTrader.IsWrongStopsExecution())
      strategyTrader.ResendWrongStops();

   string accountInfo=StringFormat("%s Balance: %.2f, Equity: %.2f",
                                   TimeToString(dataMarket.TickServerTime,TIME_SECONDS),
                                   AccountInfoDouble(ACCOUNT_BALANCE),
                                   AccountInfoDouble(ACCOUNT_EQUITY));
   LabelTextChange(0,"Lbl_pos_0",accountInfo);
   string positionInfo[2];
   position.SetPositionInfo(positionInfo);
   for(int i=0; i<2; i++)
      LabelTextChange(0,"Lbl_pos_"+IntegerToString(i+1),positionInfo[i]);

   strategy.DynamicInfoSetValues(dynamicInfoValues);
   int count = ArraySize(dynamicInfoValues);
   for(int i = 0; i < count; i++)
     {
      string namev="Lbl_val_"+IntegerToString(i);
      string val=dynamicInfoValues[i]=="" ? "." : dynamicInfoValues[i];
      LabelTextChange(0,namev,val);
     }

   if(WriteLogFile)
     {
      if(logger.IsLogLinesLimitReached(MaxLogLinesInFile))
        {
         logger.CloseLogFile();
         logger.CreateLogFile(logger.GetLogFileName(_Symbol, _Period, ExpertMagic));
        }
      logger.FlushLogFile();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade::OnDeinit(const int reason)
  {
   strategyTrader.OnDeinit();

   if(WriteLogFile)
      logger.CloseLogFile();

   if(CheckPointer(strategy)==POINTER_DYNAMIC)
      delete strategy;

   for(int i=0; i<ArraySize(dataSet); i++)
      if(CheckPointer(dataSet[i])==POINTER_DYNAMIC)
         delete dataSet[i];
   ArrayFree(dataSet);

   if(CheckPointer(dataMarket)==POINTER_DYNAMIC)
      delete dataMarket;

   int count = ArraySize(dynamicInfoParams);
   for(int i = 0; i < count; i++)
     {
      LabelDelete(0,"Lbl_val_"+IntegerToString(i));
      LabelDelete(0,"Lbl_prm_"+IntegerToString(i));
     }

   for(int i=0; i<3; i++)
      LabelDelete(0,"Lbl_pos_"+IntegerToString(i));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ActionTrade::CheckEnvironment(int minDataBars)
  {
   if(!CheckChartBarsCount(minDataBars))
      return (false);

   if(MQLInfoInteger(MQL_TESTER))
     {
      SetAggregatePosition(position);
      return (true);
     }

   if(AccountNumber()==0)
     {
      Comment("\n You are not logged in. Please login first.");
      for(int attempt=0; attempt<200; attempt++)
        {
         if(AccountNumber()==0)
            Sleep(300);
         else
            break;
        }
      if(AccountNumber()==0)
         return (false);
     }

   if(SetAggregatePosition(position)==-1)
      return (false);

   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ActionTrade::FindBarsCountNeeded(int minDataBars)
  {
   int barStep = 50;
   int minBars = MathMax(minDataBars, 50);
   int maxBars = MathMax(minBars, 3000);

// Initial state
   int initialBars=MathMax(strategy.MinBarsRequired,minBars);
   initialBars=MathMax(strategy.FirstBar,initialBars);
   for(int i=0; i<ArraySize(dataSet); i++)
      UpdateDataSet(dataSet[i],initialBars);
   UpdateDataMarket(dataMarket);
   double initialBid=dataMarket.Bid;
   strategy.CalculateStrategy(dataSet);
   string dynamicInfo= strategy.DynamicInfoText();
   int necessaryBars = initialBars;
   int roundedInitialBars=(int)(barStep*MathCeil(((double) initialBars)/barStep));
   int firstTestBars=roundedInitialBars>=initialBars+barStep/2
                     ? roundedInitialBars
                     : roundedInitialBars+barStep;

   for(int bars=firstTestBars; bars<=maxBars; bars+=barStep)
     {
      for(int i=0; i<ArraySize(dataSet); i++)
         UpdateDataSet(dataSet[i],bars);
      UpdateDataMarket(dataMarket);
      strategy.CalculateStrategy(dataSet);
      string currentInfo=strategy.DynamicInfoText();

      if(dynamicInfo==currentInfo)
         break;

      dynamicInfo=currentInfo;
      necessaryBars=bars;

      if(MathAbs(initialBid-dataMarket.Bid)>epsilon)
        {  // Reset the test if new tick has arrived.
         for(int i=0; i<ArraySize(dataSet); i++)
            UpdateDataSet(dataSet[i],initialBars);
         UpdateDataMarket(dataMarket);
         initialBid=dataMarket.Bid;
         strategy.CalculateStrategy(dataSet);
         dynamicInfo=strategy.DynamicInfoText();
         bars=firstTestBars-barStep;
        }
     }

   string barsMessage="The expert uses "+IntegerToString(necessaryBars)+" bars.";
   if(WriteLogFile)
     {
      logger.WriteLogLine(barsMessage);
      string timeLastBar=TimeToString(dataMarket.TickServerTime,TIME_DATE|TIME_MINUTES);
      logger.WriteLogLine("Indicator values: " + dataSet[0].Chart + ", Time last bar: " + timeLastBar);
      logger.WriteLogLine(dynamicInfo);
     }
   Print(barsMessage);

   return (necessaryBars);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade::UpdateDataSet(DataSet *data,int maxBars)
  {
   string symbol = data.Symbol;
   int    period = (int) data.Period;
   int    bars   = MathMin(Bars(symbol, period), maxBars);

   data.LotSize        = (int) MarketInfo(symbol, MODE_LOTSIZE);
   data.Digits         = (int) MarketInfo(symbol, MODE_DIGITS);
   data.StopLevel      = (int) MarketInfo(symbol, MODE_STOPLEVEL);
   data.Point          = MarketInfo(symbol, MODE_POINT);
   data.TickValue      = MarketInfo(symbol, MODE_TICKVALUE);
   data.MinLot         = MarketInfo(symbol, MODE_MINLOT);
   data.MaxLot         = MarketInfo(symbol, MODE_MAXLOT);
   data.LotStep        = MarketInfo(symbol, MODE_LOTSTEP);
   data.MarginRequired = MarketInfo(symbol, MODE_MARGINREQUIRED);
   data.Bars           = bars;
   data.ServerTime     = TimeCurrent();
   data.Bid            = MarketInfo(symbol, MODE_BID);
   data.Ask            = MarketInfo(symbol, MODE_ASK);
   data.Spread         = (data.Ask - data.Bid) / data.Point;

   if(data.MarginRequired<epsilon)
      data.MarginRequired=data.Bid*data.LotSize/100;

   data.SetPrecision();

   MqlRates rates[];
   RefreshRates();
   ArraySetAsSeries(rates,false);
   int copied=CopyRates(symbol,period,0,bars,rates);

   ArrayResize(data.Time,   bars);
   ArrayResize(data.Open,   bars);
   ArrayResize(data.High,   bars);
   ArrayResize(data.Low,    bars);
   ArrayResize(data.Close,  bars);
   ArrayResize(data.Volume, bars);

   for(int i=0; i<bars; i++)
     {
      data.Time[i]   = rates[i].time;
      data.Open[i]   = rates[i].open;
      data.High[i]   = rates[i].high;
      data.Low[i]    = rates[i].low;
      data.Close[i]  = rates[i].close;
      data.Volume[i] = (int) rates[i].tick_volume;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade::UpdateDataMarket(DataMarket *market)
  {
   market.Symbol = _Symbol;
   market.Period = (DataPeriod) _Period;

   market.TickLocalTime  = TimeLocal();
   market.TickServerTime = TimeCurrent();
   market.BarTime        = Time[0];

   market.PositionLots       = position.Lots;
   market.PositionOpenPrice  = position.OpenPrice;
   market.PositionOpenTime   = position.OpenTime;
   market.PositionStopLoss   = position.StopLossPrice;
   market.PositionTakeProfit = position.TakeProfitPrice;
   market.PositionProfit     = position.Profit;
   market.PositionDirection  = position.Direction;

   market.AccountBalance    = AccountBalance();
   market.AccountEquity     = AccountEquity();
   market.AccountFreeMargin = AccountFreeMargin();
   market.ConsecutiveLosses = consecutiveLosses;

   market.OldAsk    = market.Ask;
   market.OldBid    = market.Bid;
   market.OldClose  = market.Close;
   market.Ask       = MarketInfo(_Symbol, MODE_ASK);
   market.Bid       = MarketInfo(_Symbol, MODE_BID);
   market.Close     = Close[0];
   market.Volume    = Volume[0];
   market.IsNewBid  = MathAbs(market.OldBid - market.Bid) > epsilon;

   market.LotSize        = (int) MarketInfo(_Symbol, MODE_LOTSIZE);
   market.StopLevel      = (int) MarketInfo(_Symbol, MODE_STOPLEVEL);
   market.Point          = MarketInfo(_Symbol, MODE_POINT);
   market.TickValue      = MarketInfo(_Symbol, MODE_TICKVALUE);
   market.MinLot         = MarketInfo(_Symbol, MODE_MINLOT);
   market.MaxLot         = MarketInfo(_Symbol, MODE_MAXLOT);
   market.LotStep        = MarketInfo(_Symbol, MODE_LOTSTEP);
   market.MarginRequired = MarketInfo(_Symbol, MODE_MARGINREQUIRED);
   market.Spread         = (market.Ask - market.Bid) / market.Point;

   if(market.MarginRequired<epsilon)
      market.MarginRequired=market.Bid*market.LotSize/100;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ActionTrade::CheckChartBarsCount(int minDataBars)
  {
   if(MQLInfoInteger(MQL_TESTER))
     {
      if(Bars(_Symbol,_Period)>=minDataBars)
         return (true);

      string message=
                     "\n Cannot load enough bars! The expert needs minimum "+
                     IntegerToString(minDataBars)+" bars."+
                     "\n Please check the \"Use date\" option"+
                     " and set the \"From:\" and \"To:\" dates properly.";
      Comment(message);
      Print(message);
      return (false);
     }

   int bars=0;
   double rates[][6];

   for(int attempt=0; attempt<10; attempt++)
     {
      RefreshRates();
      bars=ArrayCopyRates(rates,_Symbol,_Period);
      if(bars<minDataBars && GetLastError()==4066)
        {
         Comment("Loading...");
         Sleep(500);
        }
      else
         break;

      if(IsStopped())
         break;
     }

   bool isEnoughBars=(bars>=minDataBars);
   if(!isEnoughBars)
     {
      string message="There isn\'t enough bars. The expert needs minimum "+
                     IntegerToString(minDataBars)+" bars. "+
                     "Currently "+IntegerToString(bars)+" bars are loaded."+
                     "\n Press and hold the Home key to force MetaTrader loading more bars.";
      Comment(message);
      Print(message);
     }

   return (isEnoughBars);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ActionTrade::SetAggregatePosition(Position *pos)
  {
   pos.PosType          = OP_FLAT;
   pos.Direction        = PosDirection_None;
   pos.OpenTime         = D'2050.01.01 00:00';
   pos.Lots             = 0;
   pos.OpenPrice        = 0;
   pos.StopLossPrice    = 0;
   pos.TakeProfitPrice  = 0;
   pos.Profit           = 0;
   pos.Commission       = 0;
   pos.PosComment       = "";

   int positions=0;

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         Print("Error with OrderSelect: ",GetErrorDescription(GetLastError()));
         Comment("Cannot check current position!");
         continue;
        }

      if(OrderMagicNumber()!=ExpertMagic || OrderSymbol()!=_Symbol)
         continue; // An order not sent by Forex Strategy Builder.

      if(OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT || 
         OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP)
         continue; // A pending order.

      if(pos.PosType>=0 && pos.PosType!=OrderType())
        {
         string message="There are open positions in different directions!";
         Comment(message);
         Print(message);
         return (-1);
        }

      pos.PosType     = OrderType();
      pos.Direction   = position.PosType == OP_FLAT ? PosDirection_None :
                       position.PosType==OP_BUY ? PosDirection_Long : PosDirection_Short;
      pos.OpenTime    = (OrderOpenTime() < pos.OpenTime) ? OrderOpenTime() : pos.OpenTime;
      pos.OpenPrice   = (pos.Lots * pos.OpenPrice + OrderLots() * OrderOpenPrice()) / (pos.Lots + OrderLots());
      pos.Lots       += OrderLots();
      pos.Commission += OrderCommission();
      pos.Profit     += OrderProfit() + pos.Commission;
      pos.StopLossPrice   = OrderStopLoss();
      pos.TakeProfitPrice = OrderTakeProfit();
      pos.PosComment      = OrderComment();

      positions+=1;
     }

   if(pos.OpenPrice>0)
      pos.OpenPrice=NormalizeDouble(pos.OpenPrice,_Digits);

   if(pos.Lots==0)
      pos.OpenTime=D'2050.01.01 00:00';

   return (positions);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ActionTrade::ManageOrderSend(int type,double lots,int stopLoss,int takeProfit,
                                  TrailingStopMode trlMode,int trlStop,int brkEven)
  {
   trailingMode = trlMode;
   trailingStop = trlStop;
   breakEven    = brkEven;

   bool orderResponse=false;
   int positions=SetAggregatePosition(position);

   if(positions<0)
      return (false);

   if(positions==0)
     {   // Open a new position.
      orderResponse=OpenNewPosition(type,lots,stopLoss,takeProfit);
     }
   else if(positions>0)
     {   // There is an open position.
      if((position.PosType==OP_BUY && type==OP_BUY) || 
         (position.PosType==OP_SELL && type==OP_SELL))
        {
         orderResponse=AddToCurrentPosition(type,lots,stopLoss,takeProfit);
        }
      else if((position.PosType==OP_BUY && type==OP_SELL) || 
         (position.PosType==OP_SELL && type==OP_BUY))
           {
            if(MathAbs(position.Lots-lots)<epsilon)
               orderResponse=CloseCurrentPosition();
            else if(position.Lots>lots)
               orderResponse=ReduceCurrentPosition(lots,stopLoss,takeProfit);
            else if(position.Lots<lots)
               orderResponse=ReverseCurrentPosition(type,lots,stopLoss,takeProfit);
           }
        }

      return (orderResponse);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool ActionTrade::OpenNewPosition(int type,double lots,int stopLoss,int takeProfit)
     {
      bool orderResponse=false;

      if(type!=OP_BUY && type!=OP_SELL)
        {   // Error. Wrong order type!
         Print("Wrong 'Open new position' request - Wrong order type!");
         return (false);
        }

      double orderLots=NormalizeEntrySize(lots);

      if(AccountFreeMarginCheck(_Symbol,type,orderLots)>0)
        {
         if(SeparateSLTP)
           {
            if(WriteLogFile)
               logger.WriteLogLine("OpenNewPosition => SendOrder");

            orderResponse=SendOrder(type,orderLots,0,0);

            if(orderResponse)
              {
               if(WriteLogFile)
                  logger.WriteLogLine("OpenNewPosition => ModifyPosition");
               double stopLossPrice=GetStopLossPrice(type,stopLoss);
               double takeProfitPrice=GetTakeProfitPrice(type,takeProfit);

               orderResponse=ModifyOrder(orderResponse,stopLossPrice,takeProfitPrice);
              }
           }
         else
           {
            orderResponse=SendOrder(type,orderLots,stopLoss,takeProfit);

            if(WriteLogFile)
               logger.WriteLogLine("OpenNewPosition: SendOrder Response = "+
                                   (orderResponse ? "Ok" : "Failed"));

            if(!orderResponse && lastError==130)
              {   // Invalid Stops. We'll check for forbidden direct set of SL and TP
               if(WriteLogFile)
                  logger.WriteLogLine("OpenNewPosition: SendOrder");

               orderResponse=SendOrder(type,lots,0,0);

               if(orderResponse)
                 {
                  if(WriteLogFile)
                     logger.WriteLogLine("OpenNewPosition: ModifyPosition");
                  double stopLossPrice=GetStopLossPrice(type,stopLoss);
                  double takeProfitPrice=GetTakeProfitPrice(type,takeProfit);

                  orderResponse=ModifyOrder(orderResponse,stopLossPrice,takeProfitPrice);

                  if(orderResponse)
                    {
                     SeparateSLTP=true;
                     Print(AccountCompany()," marked with separate stops setting.");
                    }
                 }
              }
           }
        }

      SetAggregatePosition(position);
      if(WriteLogFile)
         logger.WriteLogLine(position.ToString());

      return (orderResponse);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool ActionTrade::CloseCurrentPosition()
     {
      bool orderResponse = false;
      int  totalOrders   = OrdersTotal();
      int  orders        = 0;
      datetime openPos[][2];

      for(int i=0; i<totalOrders; i++)
        {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            lastError=GetLastError();
            Print("Error in OrderSelect: ",GetErrorDescription(lastError));
            continue;
           }

         if(OrderMagicNumber()!=ExpertMagic || OrderSymbol()!=_Symbol)
            continue;

         int orderType = OrderType();
         if(orderType != OP_BUY && orderType != OP_SELL)
            continue;

         orders++;
         ArrayResize(openPos,orders);
         openPos[orders - 1][0] = OrderOpenTime();
         openPos[orders - 1][1] = OrderTicket();
        }

      if(FIFOorder)
         ArraySort(openPos,WHOLE_ARRAY,0,MODE_ASCEND);
      else
         ArraySort(openPos,WHOLE_ARRAY,0,MODE_DESCEND);

      for(int i=0; i<orders; i++)
        {
         if(!OrderSelect((int) openPos[i][1],SELECT_BY_TICKET))
           {
            lastError=GetLastError();
            Print("Error in OrderSelect: ",GetErrorDescription(lastError));
            continue;
           }

         orderResponse=CloseOrder(OrderTicket(),OrderLots());
        }

      consecutiveLosses=(position.Profit<0) ? consecutiveLosses+1 : 0;
      SetAggregatePosition(position);
      Print("ConsecutiveLosses=",consecutiveLosses);

      return (orderResponse);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool ActionTrade::AddToCurrentPosition(int type,double lots,int stopLoss,int takeProfit)
     {
      if(AccountFreeMarginCheck(_Symbol,type,lots)<=0)
         return (false);

      if(WriteLogFile)
         logger.WriteLogLine("AddToCurrentPosition: OpenNewPosition");

      bool orderResponse=OpenNewPosition(type,lots,stopLoss,takeProfit);

      if(!orderResponse)
         return (false);

      double stopLossPrice=GetStopLossPrice(type,stopLoss);
      double takeProfitPrice=GetTakeProfitPrice(type,takeProfit);

      orderResponse=ModifyPosition(stopLossPrice,takeProfitPrice);

      SetAggregatePosition(position);

      return (orderResponse);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool ActionTrade::ReduceCurrentPosition(double lots,int stopLoss,int takeProfit)
     {
      int totalOrders=OrdersTotal();
      int orders=0;
      datetime openPos[][2];

      for(int i=0; i<totalOrders; i++)
        {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            lastError=GetLastError();
            Print("Error in OrderSelect: ",GetErrorDescription(lastError));
            continue;
           }

         if(OrderMagicNumber()!=ExpertMagic || 
            OrderSymbol()!=_Symbol)
            continue;

         int orderType = OrderType();
         if(orderType != OP_BUY && orderType != OP_SELL)
            continue;

         orders++;
         ArrayResize(openPos,orders);
         openPos[orders - 1][0] = OrderOpenTime();
         openPos[orders - 1][1] = OrderTicket();
        }

      if(FIFOorder)
         ArraySort(openPos,WHOLE_ARRAY,0,MODE_ASCEND);
      else
         ArraySort(openPos,WHOLE_ARRAY,0,MODE_DESCEND);

      for(int i=0; i<orders; i++)
        {
         if(!OrderSelect((int) openPos[i][1],SELECT_BY_TICKET))
           {
            lastError=GetLastError();
            Print("Error in OrderSelect: ",GetErrorDescription(lastError));
            continue;
           }

         double orderLots=(lots>=OrderLots()) ? OrderLots() : lots;
         CloseOrder(OrderTicket(),orderLots);
         lots-=orderLots;

         if(lots<=0)
            break;
        }

      double stopLossPrice=GetStopLossPrice(position.PosType,stopLoss);
      double takeProfitPrice=GetTakeProfitPrice(position.PosType,takeProfit);

      bool orderResponse=ModifyPosition(stopLossPrice,takeProfitPrice);

      SetAggregatePosition(position);
      consecutiveLosses=0;

      return (orderResponse);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool ActionTrade::ReverseCurrentPosition(int type,double lots,int stopLoss,int takeProfit)
     {
      lots-=position.Lots;

      bool orderResponse=CloseCurrentPosition();

      if(!orderResponse)
         return (false);

      orderResponse=OpenNewPosition(type,lots,stopLoss,takeProfit);

      SetAggregatePosition(position);
      consecutiveLosses=0;

      return (orderResponse);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool ActionTrade::SendOrder(int type,double lots,int stopLoss,int takeProfit)
     {
      bool orderResponse = false;
      int  response      = -1;

      for(int attempt=0; attempt<TRADE_RETRY_COUNT; attempt++)
        {
         if(IsTradeContextFree())
           {
            double orderLots       = NormalizeEntrySize(lots);
            double orderPrice      = type == OP_BUY
                                    ? MarketInfo(_Symbol,MODE_ASK)
                                    : MarketInfo(_Symbol,MODE_BID);
            double stopLossPrice   = GetStopLossPrice(type, stopLoss);
            double takeProfitPrice = GetTakeProfitPrice(type, takeProfit);
            color  colorDeal       = type == OP_BUY ? Lime : Red;
            string comment         = (OrderComment == "")
                                    ? "Magic="+IntegerToString(ExpertMagic)
                                    : OrderComment;

            response=OrderSend(_Symbol,type,orderLots,orderPrice,100,
                               stopLossPrice,takeProfitPrice,comment,
                               ExpertMagic,0,colorDeal);

            lastError=GetLastError();

            if(WriteLogFile)
               logger.WriteLogLine(
                                   "SendOrder: "+_Symbol+
                                   ", Type="+(type==OP_BUY ? "Buy" : "Sell")+
                                   ", Lots="+DoubleToString(orderLots,2)+
                                   ", Price="+DoubleToString(orderPrice,_Digits)+
                                   ", StopLoss="+DoubleToString(stopLossPrice,_Digits)+
                                   ", TakeProfit="+DoubleToString(takeProfitPrice,_Digits)+
                                   ", Magic="+IntegerToString(ExpertMagic)+
                                   ", Response="+IntegerToString(response)+
                                   ", LastError="+IntegerToString(lastError));
           }

         orderResponse=response>0;

         if(orderResponse)
            break;

         if(lastError!=135 && lastError!=136 && 
            lastError!=137 && lastError!=138)
            break;

         Print("Error with SendOrder: ",GetErrorDescription(lastError));

         Sleep(TRADE_RETRY_WAIT);
        }

      return (orderResponse);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool ActionTrade::CloseOrder(int orderTicket,double orderLots)
     {
      if(!OrderSelect(orderTicket,SELECT_BY_TICKET))
        {
         lastError=GetLastError();
         Print("Error with OrderSelect: ",GetErrorDescription(lastError));
         return (false);
        }

      int orderType=OrderType();

      for(int attempt=0; attempt<TRADE_RETRY_COUNT; attempt++)
        {
         bool orderResponse=false;
         if(IsTradeContextFree())
           {
            double orderPrice=(orderType==OP_BUY)
                              ? MarketInfo(_Symbol,MODE_BID)
                              : MarketInfo(_Symbol,MODE_ASK);
            orderPrice=NormalizeDouble(orderPrice,Digits);

            orderResponse=OrderClose(orderTicket,orderLots,orderPrice,100,Gold);

            lastError=GetLastError();
            if(WriteLogFile)
               logger.WriteLogLine("OrderClose: "+_Symbol+
                                   ", Ticket="+IntegerToString(orderTicket)+
                                   ", Lots="+DoubleToString(orderLots,2)+
                                   ", Price="+DoubleToString(orderPrice,_Digits)+
                                   ", Response="+(orderResponse ? "True" : "False")+
                                   ", LastError="+IntegerToString(lastError));
           }

         if(orderResponse)
            return (true);

         if(lastError==4108)
            return(false); // Invalid ticket error.

         Print("Error with CloseOrder: ",GetErrorDescription(lastError),
               ". Attempt No: ",(attempt+1));

         Sleep(TRADE_RETRY_WAIT);
        }

      return (false);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool ActionTrade::ModifyPosition(double stopLossPrice,double takeProfitPrice)
     {
      bool orderResponse=true;

      for(int i=0; i<OrdersTotal(); i++)
        {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            lastError=GetLastError();
            Print("Error with OrderSelect: ",GetErrorDescription(lastError));
            continue;
           }

         if(OrderMagicNumber()!=ExpertMagic || OrderSymbol()!=_Symbol)
            continue;

         int type = OrderType();
         if(type != OP_BUY && type != OP_SELL)
            continue;

         orderResponse=ModifyOrder(OrderTicket(),stopLossPrice,takeProfitPrice);
        }

      return (orderResponse);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool ActionTrade::ModifyOrder(int orderTicket,double stopLossPrice,double takeProfitPrice)
     {
      if(!SelectOrder(orderTicket))
         return (false);

      stopLossPrice=NormalizeEntryPrice(stopLossPrice);
      takeProfitPrice=NormalizeEntryPrice(takeProfitPrice);
      double oldStopLoss=NormalizeEntryPrice(OrderStopLoss());
      double oldTakeProfit=NormalizeEntryPrice(OrderTakeProfit());

      for(int attempt=0; attempt<TRADE_RETRY_COUNT; attempt++)
        {
         if(attempt>0)
           {
            stopLossPrice=CorrectStopLossPrice(OrderType(),stopLossPrice);
            takeProfitPrice=CorrectTakeProfitPrice(OrderType(),takeProfitPrice);
           }

         if(MathAbs(stopLossPrice-oldStopLoss)<pipsValue && 
            MathAbs(takeProfitPrice-oldTakeProfit)<pipsValue)
            return(true); // There isn't anything to change.

         bool isSuccess = false;
         string logline = "";
         double orderOpenPrice=0;
         if(IsTradeContextFree())
           {
            orderOpenPrice=NormalizeDouble(OrderOpenPrice(),_Digits);

            isSuccess=OrderModify(orderTicket,orderOpenPrice,stopLossPrice,takeProfitPrice,0);

            lastError=GetLastError();
            if(WriteLogFile)
               logline=
                       "ModifyOrder: "+_Symbol+
                       ", Ticket="+IntegerToString(orderTicket)+
                       ", Price="+DoubleToString(orderOpenPrice,_Digits)+
                       ", StopLoss="+DoubleToString(stopLossPrice,_Digits)+
                       ", TakeProfit="+DoubleToString(takeProfitPrice,_Digits)+")"+
                       "  Magic="+IntegerToString(ExpertMagic)+
                       ", Response="+IntegerToString(isSuccess)+
                       ", LastError="+IntegerToString(lastError);
           }

         if(isSuccess)
           {   // Modification was successful.
            if(WriteLogFile)
               logger.WriteLogLine(logline);
            return (true);
           }
         else if(lastError==1)
           {
            if(!SelectOrder(orderTicket))
               return (false);

            if(MathAbs(stopLossPrice-OrderStopLoss())<pipsValue && 
               MathAbs(takeProfitPrice-OrderTakeProfit())<pipsValue)
              {
               if(WriteLogFile)
                  logger.WriteLogLine(logline+", Checked OK");
               lastError=0;
               return(true); // We assume that there is no error.
              }
           }

         Print("Error with ModifyOrder(",
               orderTicket,", ",
               orderOpenPrice,", ",
               stopLossPrice,", ",
               takeProfitPrice,") ",
               GetErrorDescription(lastError),".");
         Sleep(TRADE_RETRY_WAIT);
         RefreshRates();

         if(lastError==4108)
            return(false);  // Invalid ticket error.
        }

      return (false);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool ActionTrade::SelectOrder(int orderTicket)
     {
      bool orderResponse=OrderSelect(orderTicket,SELECT_BY_TICKET);

      if(!orderResponse)
        {
         lastError=GetLastError();
         string message="Error with OrderSelect("+
                        IntegerToString(orderTicket)+")"+
                        ", LastError="+IntegerToString(lastError)+", "+
                        GetErrorDescription(lastError);
         Print(message);
         if(WriteLogFile)
            logger.WriteLogLine(message);
        }

      return (orderResponse);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double ActionTrade::GetTakeProfitPrice(int type,int takeProfit)
     {
      if(takeProfit<epsilon)
         return (0);

      if(takeProfit<stopLevel)
         takeProfit=stopLevel;

      double takeProfitPrice=(type==OP_BUY)
                             ? MarketInfo(_Symbol,MODE_BID)+takeProfit*_Point
                             : MarketInfo(_Symbol,MODE_ASK)-takeProfit*_Point;

      return (NormalizeEntryPrice(takeProfitPrice));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double ActionTrade::GetStopLossPrice(int type,int stopLoss)
     {
      if(stopLoss<epsilon)
         return (0);

      if(stopLoss<stopLevel)
         stopLoss=stopLevel;

      double stopLossPrice=(type==OP_BUY)
                           ? MarketInfo(_Symbol,MODE_BID)-stopLoss*_Point
                           : MarketInfo(_Symbol,MODE_ASK)+stopLoss*_Point;

      return (NormalizeEntryPrice(stopLossPrice));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double ActionTrade::CorrectTakeProfitPrice(int type,double takeProfitPrice)
     {
      if(takeProfitPrice<epsilon)
         return (0);

      double bid = MarketInfo(_Symbol, MODE_BID);
      double ask = MarketInfo(_Symbol, MODE_ASK);

      if(type==OP_BUY)
        {
         double minTPPrice=bid+stopLevel*_Point;
         if(takeProfitPrice<minTPPrice)
            takeProfitPrice=minTPPrice;
        }
      else if(type==OP_SELL)
        {
         double maxTPPrice=ask-stopLevel*_Point;
         if(takeProfitPrice>maxTPPrice)
            takeProfitPrice=maxTPPrice;
        }

      return (NormalizeEntryPrice(takeProfitPrice));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double ActionTrade::CorrectStopLossPrice(int type,double stopLossPrice)
     {
      if(stopLossPrice==epsilon)
         return (0);

      double bid = MarketInfo(_Symbol, MODE_BID);
      double ask = MarketInfo(_Symbol, MODE_ASK);

      if(type==OP_BUY)
        {
         double minSLPrice=bid-stopLevel*_Point;
         if(stopLossPrice>minSLPrice)
            stopLossPrice=minSLPrice;
        }
      else if(type==OP_SELL)
        {
         double maxSLPrice=ask+stopLevel*_Point;
         if(stopLossPrice<maxSLPrice)
            stopLossPrice=maxSLPrice;
        }

      return (NormalizeEntryPrice(stopLossPrice));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double ActionTrade::NormalizeEntryPrice(double price)
     {
      double tickSize=MarketInfo(_Symbol,MODE_TICKSIZE);
      if(tickSize!=0)
         return (NormalizeDouble(MathRound(price / tickSize) * tickSize, _Digits));
      return (NormalizeDouble(price, _Digits));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double ActionTrade::NormalizeEntrySize(double size)
     {
      double minlot  = MarketInfo(_Symbol, MODE_MINLOT);
      double maxlot  = MarketInfo(_Symbol, MODE_MAXLOT);
      double lotstep = MarketInfo(_Symbol, MODE_LOTSTEP);

      if(size<minlot-epsilon)
         return (0);

      if(MathAbs(size-minlot)<epsilon)
         return (minlot);

      int steps=(int) MathRound((size-minlot)/lotstep);
      size=minlot+steps*lotstep;

      if(size >= maxlot)
         size = maxlot;

      return (size);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void ActionTrade::SetMaxStopLoss()
     {
      double bid = MarketInfo(_Symbol, MODE_BID);
      double ask = MarketInfo(_Symbol, MODE_ASK);
      double spread=(ask-bid)/_Point;

      for(int i=0; i<OrdersTotal(); i++)
        {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            lastError=GetLastError();
            Print("Error with OrderSelect: ",GetErrorDescription(lastError));
            continue;
           }

         if(OrderMagicNumber()!=ExpertMagic || 
            OrderSymbol()!=_Symbol)
            continue;

         int type = OrderType();
         if(type != OP_BUY && type != OP_SELL)
            continue;

         int orderTicket=OrderTicket();
         double posOpenPrice=OrderOpenPrice();
         double stopLossPrice=OrderStopLoss();
         double takeProfitPrice=OrderTakeProfit();
         int stopLossPoints=(int)
                            MathRound(MathAbs(posOpenPrice-stopLossPrice)/_Point);

         if(stopLossPrice<epsilon || 
            stopLossPoints>ProtectionMaxStopLoss+spread)
           {
            stopLossPrice=(type==OP_BUY)
                          ? posOpenPrice-_Point *(ProtectionMaxStopLoss+spread)
                          : posOpenPrice+_Point *(ProtectionMaxStopLoss+spread);
            stopLossPrice=CorrectStopLossPrice(type,stopLossPrice);

            if(WriteLogFile)
               logger.WriteLogRequest("SetMaxStopLoss","StopLoss="+
                                      DoubleToString(stopLossPrice,_Digits));

            bool isSuccess=ModifyOrder(orderTicket,stopLossPrice,takeProfitPrice);

            if(isSuccess)
               Print("MaxStopLoss(",ProtectionMaxStopLoss,") set StopLoss to ",
                     DoubleToString(stopLossPrice,_Digits));
           }
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void ActionTrade::SetBreakEvenStop()
     {
      if(SetAggregatePosition(position)<=0)
         return;

      double breakeven=stopLevel;
      if(breakeven<breakEven)
         breakeven=breakEven;

      double breakprice = 0; // Break Even price including commission.
      double commission = 0; // Commission in points.
      if(position.Commission!=0)
         commission=MathAbs(position.Commission)/MarketInfo(_Symbol,MODE_TICKVALUE);

      double bid = MarketInfo(_Symbol, MODE_BID);
      double ask = MarketInfo(_Symbol, MODE_ASK);

      if(position.PosType==OP_BUY)
        {
         breakprice=NormalizeEntryPrice(position.OpenPrice+
                                        _Point*commission/position.Lots);
         if(bid-breakprice>=_Point*breakeven)
           {
            if(position.StopLossPrice<breakprice)
              {
               if(WriteLogFile)
                  logger.WriteLogRequest("SetBreakEvenStop",
                                         "BreakPrice="+DoubleToString(breakprice,_Digits));

               ModifyPosition(breakprice,position.TakeProfitPrice);

               Print("SetBreakEvenStop(",breakEven,
                     ") set StopLoss to ",DoubleToString(breakprice,_Digits),
                     ", Bid=",DoubleToString(bid,_Digits));
              }
           }
        }
      else if(position.PosType==OP_SELL)
        {
         breakprice=NormalizeEntryPrice(position.OpenPrice -
                                        _Point*commission/position.Lots);
         if(breakprice-ask>=_Point*breakeven)
           {
            if(position.StopLossPrice==0 || position.StopLossPrice>breakprice)
              {
               if(WriteLogFile)
                  logger.WriteLogRequest("SetBreakEvenStop","BreakPrice="+
                                         DoubleToString(breakprice,_Digits));

               ModifyPosition(breakprice,position.TakeProfitPrice);

               Print("SetBreakEvenStop(",breakEven,") set StopLoss to ",
                     DoubleToString(breakprice,_Digits),
                     ", Ask=",DoubleToString(ask,_Digits));
              }
           }
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void ActionTrade::SetTrailingStop(bool isNewBar)
     {
      bool isCheckTS=true;

      if(isNewBar)
        {
         if(position.PosType==OP_BUY && position.OpenTime>barHighTime)
            isCheckTS=false;

         if(position.PosType==OP_SELL && position.OpenTime>barLowTime)
            isCheckTS=false;

         barHighTime  = Time[0];
         barLowTime   = Time[0];
         barHighPrice = High[0];
         barLowPrice  = Low[0];
        }
      else
        {
         if(High[0]>barHighPrice)
           {
            barHighPrice = High[0];
            barHighTime  = Time[0];
           }
         if(Low[0]<barLowPrice)
           {
            barLowPrice = Low[0];
            barLowTime  = Time[0];
           }
        }

      if(SetAggregatePosition(position)<=0)
         return;

      if(trailingMode==TrailingStopMode_Tick)
         SetTrailingStopTickMode();
      else if(trailingMode==TrailingStopMode_Bar && isNewBar && isCheckTS)
         SetTrailingStopBarMode();
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void ActionTrade::SetTrailingStopBarMode()
     {
      double bid = MarketInfo(_Symbol, MODE_BID);
      double ask = MarketInfo(_Symbol, MODE_ASK);

      if(position.PosType==OP_BUY)
        {   // Long position
         double stopLossPrice=High[1]-_Point*trailingStop;
         if(position.StopLossPrice<stopLossPrice-pipsValue)
           {
            if(stopLossPrice<bid)
              {
               if(stopLossPrice>bid-_Point*stopLevel)
                  stopLossPrice=bid-_Point*stopLevel;

               if(WriteLogFile)
                  logger.WriteLogRequest("SetTrailingStopBarMode",
                                         "StopLoss="+
                                         DoubleToString(stopLossPrice,_Digits));

               ModifyPosition(stopLossPrice,position.TakeProfitPrice);

               Print("Trailing Stop (",trailingStop,") moved to: ",
                     DoubleToString(stopLossPrice,_Digits),
                     ", Bid=",DoubleToString(bid,_Digits));
              }
            else
              {
               if(WriteLogFile)
                  logger.WriteLogRequest("SetTrailingStopBarMode",
                                         "StopLoss="+
                                         DoubleToString(stopLossPrice,_Digits));

               bool orderResponse=CloseCurrentPosition();

               int lastErrorOrdClose=GetLastError();
               lastErrorOrdClose=(lastErrorOrdClose>0)
                                 ? lastErrorOrdClose
                                 : lastError;
               if(!orderResponse)
                  Print("Error in OrderClose: ",
                        GetErrorDescription(lastErrorOrdClose));
              }
           }
        }
      else if(position.PosType==OP_SELL)
        {   // Short position
         double stopLossPrice=Low[1]+_Point*trailingStop;
         if(position.StopLossPrice>stopLossPrice+pipsValue)
           {
            if(stopLossPrice>ask)
              {
               if(stopLossPrice<ask+_Point*stopLevel)
                  stopLossPrice=ask+_Point*stopLevel;

               if(WriteLogFile)
                  logger.WriteLogRequest("SetTrailingStopBarMode",
                                         "StopLoss="+DoubleToString(stopLossPrice,_Digits));

               ModifyPosition(stopLossPrice,position.TakeProfitPrice);

               Print("Trailing Stop (",trailingStop,") moved to: ",
                     DoubleToString(stopLossPrice,_Digits),
                     ", Ask=",DoubleToString(ask,_Digits));
              }
            else
              {
               if(WriteLogFile)
                  logger.WriteLogRequest("SetTrailingStopBarMode",
                                         "StopLoss="+DoubleToString(stopLossPrice,_Digits));

               bool orderResponse=CloseCurrentPosition();

               int lastErrorOrdClose=GetLastError();
               lastErrorOrdClose=(lastErrorOrdClose>0) ? lastErrorOrdClose : lastError;
               if(!orderResponse)
                  Print("Error in OrderClose: ",
                        GetErrorDescription(lastErrorOrdClose));
              }
           }
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void ActionTrade::SetTrailingStopTickMode()
     {
      if(position.PosType==OP_BUY)
        {   // Long position
         double bid=MarketInfo(_Symbol,MODE_BID);
         if(bid>=position.OpenPrice+_Point*trailingStop)
           {
            if(position.StopLossPrice<bid-_Point *(trailingStop+TrailingStopMovingStep))
              {
               double stopLossPrice=bid-_Point*trailingStop;
               if(WriteLogFile)
                  logger.WriteLogRequest("SetTrailingStopTickMode",
                                         "StopLoss="+DoubleToString(stopLossPrice,_Digits));

               ModifyPosition(stopLossPrice,position.TakeProfitPrice);

               Print("Trailing Stop (",trailingStop,") moved to: ",
                     DoubleToString(stopLossPrice,_Digits),
                     ", Bid=",DoubleToString(bid,_Digits));
              }
           }
        }
      else if(position.PosType==OP_SELL)
        {   // Short position
         double ask=MarketInfo(_Symbol,MODE_ASK);
         if(position.OpenPrice-ask>=_Point*trailingStop)
           {
            if(position.StopLossPrice>ask+_Point *(trailingStop+TrailingStopMovingStep))
              {
               double stopLossPrice=ask+_Point*trailingStop;
               if(WriteLogFile)
                  logger.WriteLogRequest("SetTrailingStopTickMode",
                                         "StopLoss="+DoubleToString(stopLossPrice,_Digits));

               ModifyPosition(stopLossPrice,position.TakeProfitPrice);

               Print("Trailing Stop (",trailingStop,") moved to: ",
                     DoubleToString(stopLossPrice,_Digits),
                     ", Ask=",DoubleToString(ask,_Digits));
              }
           }
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void ActionTrade::DetectPositionClosing()
     {
      double oldStopLoss   = position.StopLossPrice;
      double oldTakeProfit = position.TakeProfitPrice;
      double oldProfit     = position.Profit;
      int    oldType       = position.PosType;
      double oldLots       = position.Lots;

      SetAggregatePosition(position);

      if(oldType==OP_FLAT || position.PosType!=OP_FLAT)
         return;

      double closePrice     = (oldType == OP_BUY) ? dataMarket.Bid : dataMarket.Ask;
      string stopMessage    = "Position was closed";
      string closePriceText = DoubleToString(closePrice, _Digits);

      if(MathAbs(oldStopLoss-closePrice)<2*pipsValue)
         stopMessage="Activated StopLoss="+closePriceText;
      else if(MathAbs(oldTakeProfit-closePrice)<2*pipsValue)
         stopMessage="Activated TakeProfit="+closePriceText;

      consecutiveLosses=(oldProfit<0) ? consecutiveLosses+1 : 0;

      string message=stopMessage+
                     ", ClosePrice="+closePriceText+
                     ", ClosedLots= "+DoubleToString(oldLots,2)+
                     ", Profit="+DoubleToString(oldProfit,2)+
                     ", ConsecutiveLosses="+IntegerToString(consecutiveLosses);

      if(WriteLogFile)
         logger.WriteNewLogLine(message);
      Print(message);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool ActionTrade::IsTradeContextFree()
     {
      if(IsTradeAllowed())
         return (true);

      uint startWait=GetTickCount();
      Print("Trade context is busy! Waiting...");

      while(true)
        {
         if(IsStopped())
            return (false);

         uint diff=GetTickCount()-startWait;
         if(diff>30*1000)
           {
            Print("The waiting limit exceeded!");
            return (false);
           }

         if(IsTradeAllowed())
           {
            RefreshRates();
            return (true);
           }
         Sleep(100);
        }

      return (true);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void ActionTrade::ActivateProtectionMinAccount()
     {
      CloseCurrentPosition();

      string account = DoubleToString(AccountEquity(), 2);
      string message = "\n" + "The account equity (" + account +
                      ") dropped below the minimum allowed ("+
                      IntegerToString(ProtectionMinAccount)+").";
      Comment(message);
      Print(message);

      if(WriteLogFile)
         logger.WriteLogLine(message);

      Sleep(20*1000);
      CloseExpert();
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void ActionTrade::CloseExpert(void)
     {
      ExpertRemove();
      OnDeinit(0);
     }
//+------------------------------------------------------------------+


ActionTrade *actionTrade;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   actionTrade=new ActionTrade();

   actionTrade.EntryAmount            = Entry_Amount    > 77700 ? 0.1 : Entry_Amount;
   actionTrade.MaximumAmount          = Maximum_Amount  > 77700 ? 0.1 : Maximum_Amount;
   actionTrade.AddingAmount           = Adding_Amount   > 77700 ? 0.1 : Adding_Amount;
   actionTrade.ReducingAmount         = Reducing_Amount > 77700 ? 0.1 : Reducing_Amount;
   actionTrade.OrderComment           = Order_Comment;
   actionTrade.MinDataBars            = Min_Data_Bars;
   actionTrade.ProtectionMinAccount   = Protection_Min_Account;
   actionTrade.ProtectionMaxStopLoss  = Protection_Max_StopLoss;
   actionTrade.ExpertMagic            = Expert_Magic;
   actionTrade.SeparateSLTP           = Separate_SL_TP;
   actionTrade.WriteLogFile           = Write_Log_File;
   actionTrade.TrailingStopMovingStep = TrailingStop_Moving_Step;
   actionTrade.FIFOorder              = FIFO_order;
   actionTrade.MaxLogLinesInFile      = Max_Log_Lines_in_File;
   actionTrade.BarCloseAdvance        = Bar_Close_Advance;

   int result=actionTrade.OnInit();

   if(result==INIT_SUCCEEDED)
      actionTrade.OnTick();

   return (result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(__symbol!=_Symbol || __period!=_Period)
     {
      if(__period>0)
        {
         actionTrade.OnDeinit(-1);
         actionTrade.OnInit();
        }
      __symbol = _Symbol;
      __period = _Period;
     }

   actionTrade.OnTick();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   actionTrade.OnDeinit(reason);

   if(CheckPointer(actionTrade)==POINTER_DYNAMIC)
      delete actionTrade;
  }

/*STRATEGY CODE <?xml version=\"1.0\"?><strategy><programName>Forex Strategy Builder Professional</programName><programVersion>v3.8.8</programVersion><strategyName>EURUSD_1MIN DD35 10-95K 1mnth PF18.24 DD38</strategyName><profileName>Default profile</profileName><dataSourceName>FSB Demo data</dataSourceName><instrumentSymbol>EURUSD</instrumentSymbol><instrumentPeriod>1</instrumentPeriod><sameDirSignalAction>Add</sameDirSignalAction><oppDirSignalAction>Reduce</oppDirSignalAction><maxOpenLots>20</maxOpenLots><useAccountPercentEntry>False</useAccountPercentEntry><entryLots>1</entryLots><addingLots>1</addingLots><reducingLots>1</reducingLots><useMartingale>False</useMartingale><martingaleMultiplier>2</martingaleMultiplier><description>Exported on 12/1/2018 from Forex Strategy Builder Professional, v3.8.8</description><recommendedBars>1000</recommendedBars><openFilters>3</openFilters><closeFilters>0</closeFilters><firstBar>208</firstBar><minBarsRequired>209</minBarsRequired><permanentStopLoss usePermanentSL=\"True\" permanentSLType=\"Relative\">820</permanentStopLoss><permanentTakeProfit usePermanentTP=\"True\" permanentTPType=\"Relative\">3000</permanentTakeProfit><breakEven useBreakEven=\"True\">600</breakEven><slot slotNumber=\"0\" slotType=\"Open\"><indicatorName>Keltner Channel</indicatorName><listParam paramNumber=\"0\"><caption>Logic</caption><index>0</index><value>Enter long at Upper Band</value></listParam><listParam paramNumber=\"1\"><caption>Smoothing method</caption><index>2</index><value>Exponential</value></listParam><listParam paramNumber=\"2\"><caption>Base price</caption><index>0</index><value>Close</value></listParam><numParam paramNumber=\"0\"><caption>MA period</caption><value>131</value></numParam><numParam paramNumber=\"1\"><caption>ATR period</caption><value>18</value></numParam><numParam paramNumber=\"3\"><caption>ATR multiplier</caption><value>5</value></numParam><checkParam paramNumber=\"0\"><caption>Use previous bar value</caption><value>True</value></checkParam><signalShift>0</signalShift><signalRepeat>0</signalRepeat><indicatorSymbol></indicatorSymbol><indicatorPeriod>M1</indicatorPeriod></slot><slot slotNumber=\"1\" slotType=\"OpenFilter\" logicalGroup=\"A\"><indicatorName>Moving Averages Crossover</indicatorName><listParam paramNumber=\"0\"><caption>Logic</caption><index>3</index><value>Fast MA is lower than Slow MA</value></listParam><listParam paramNumber=\"1\"><caption>Base price</caption><index>6</index><value>Weighted</value></listParam><listParam paramNumber=\"3\"><caption>Fast MA method</caption><index>2</index><value>Exponential</value></listParam><listParam paramNumber=\"4\"><caption>Slow MA method</caption><index>1</index><value>Weighted</value></listParam><numParam paramNumber=\"0\"><caption>Fast MA period</caption><value>134</value></numParam><numParam paramNumber=\"1\"><caption>Slow MA period</caption><value>118</value></numParam><numParam paramNumber=\"2\"><caption>Fast MA shift</caption><value>44</value></numParam><numParam paramNumber=\"3\"><caption>Slow MA shift</caption><value>87</value></numParam><checkParam paramNumber=\"0\"><caption>Use previous bar value</caption><value>True</value></checkParam><signalShift>0</signalShift><signalRepeat>0</signalRepeat><indicatorSymbol></indicatorSymbol><indicatorPeriod>M1</indicatorPeriod></slot><slot slotNumber=\"2\" slotType=\"OpenFilter\" logicalGroup=\"A\"><indicatorName>Vidya Moving Average</indicatorName><listParam paramNumber=\"0\"><caption>Logic</caption><index>0</index><value>The Vidya Moving Average rises</value></listParam><listParam paramNumber=\"2\"><caption>Base price</caption><index>3</index><value>Close</value></listParam><numParam paramNumber=\"0\"><caption>Period</caption><value>20</value></numParam><numParam paramNumber=\"1\"><caption>Smooth</caption><value>2</value></numParam><checkParam paramNumber=\"0\"><caption>Use previous bar value</caption><value>True</value></checkParam><signalShift>0</signalShift><signalRepeat>0</signalRepeat><indicatorSymbol></indicatorSymbol><indicatorPeriod>M15</indicatorPeriod></slot><slot slotNumber=\"3\" slotType=\"OpenFilter\" logicalGroup=\"A\"><indicatorName>Vidya Moving Average</indicatorName><listParam paramNumber=\"0\"><caption>Logic</caption><index>0</index><value>The Vidya Moving Average rises</value></listParam><listParam paramNumber=\"2\"><caption>Base price</caption><index>3</index><value>Close</value></listParam><numParam paramNumber=\"0\"><caption>Period</caption><value>21</value></numParam><numParam paramNumber=\"1\"><caption>Smooth</caption><value>6</value></numParam><checkParam paramNumber=\"0\"><caption>Use previous bar value</caption><value>True</value></checkParam><signalShift>0</signalShift><signalRepeat>0</signalRepeat><indicatorSymbol></indicatorSymbol><indicatorPeriod>M15</indicatorPeriod></slot><slot slotNumber=\"4\" slotType=\"Close\"><indicatorName>Fractal</indicatorName><listParam paramNumber=\"0\"><caption>Logic</caption><index>1</index><value>Exit long at Down Fractal</value></listParam><listParam paramNumber=\"1\"><caption>Visibility</caption><index>1</index><value>Visible or shadowed</value></listParam><numParam paramNumber=\"0\"><caption>Vertical shift</caption><value>302</value></numParam><signalShift>0</signalShift><signalRepeat>0</signalRepeat><indicatorSymbol></indicatorSymbol><indicatorPeriod>M1</indicatorPeriod></slot></strategy> */
//+------------------------------------------------------------------+
