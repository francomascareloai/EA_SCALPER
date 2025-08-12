//+------------------------------------------------------------------+
//|                                           MurreyMath Channel.mq5 |
//|                              Copyright 2009-2024, MetaQuotes Ltd |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009-2024, MetaQuotes Ltd"
#property link        "http://www.mql5.com"
#property description "Murrey Math Channels based on https://www.mql5.com/ru/code/8157"
#property description "Author of calculations is Vladyslav Goshkov (https://www.mql5.com/en/users/vladislavvg)"

//--- input parameters
input int  InpCalculationPeriod=64;    // calculation period
input bool InpShowExtraLevels  =false; // show all levels
input bool InpShowLabel        =true;  // show price of level

//--- properties
#property indicator_chart_window
#property indicator_buffers 13
#property indicator_plots   13
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkBlue

#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkViolet

#property indicator_type3   DRAW_LINE
#property indicator_color3  clrMediumSlateBlue
#property indicator_width3  2

#property indicator_type4   DRAW_LINE
#property indicator_color4  clrFireBrick

#property indicator_type5   DRAW_LINE
#property indicator_color5  clrRed
#property indicator_width5  2

#property indicator_type6   DRAW_LINE
#property indicator_color6  clrGreen

#property indicator_type7   DRAW_LINE
#property indicator_color7  clrDarkGray
#property indicator_width7  2

#property indicator_type8   DRAW_LINE
#property indicator_color8  clrGreen

#property indicator_type9   DRAW_LINE
#property indicator_color9  clrRed
#property indicator_width9  2

#property indicator_type10  DRAW_LINE
#property indicator_color10 clrFireBrick

#property indicator_type11  DRAW_LINE
#property indicator_color11 clrMediumSlateBlue
#property indicator_width11 2

#property indicator_type12  DRAW_LINE
#property indicator_color12 clrDarkViolet

#property indicator_type13  DRAW_LINE
#property indicator_color13 clrDarkBlue

//---labels
#property indicator_label1  "[+2/8]"
#property indicator_label2  "[+1/8]"
#property indicator_label3  "[8/8]"
#property indicator_label4  "[7/8]"
#property indicator_label5  "[6/8]"
#property indicator_label6  "[5/8]"
#property indicator_label7  "[4/8]"
#property indicator_label8  "[3/8]"
#property indicator_label9  "[2/8]"
#property indicator_label10 "[1/8]"
#property indicator_label11 "[0/8]"
#property indicator_label12 "[-1/8]"
#property indicator_label13 "[-2/8]"

//--- indicator buffers
double Ext1Buffer[];
double Ext2Buffer[];
double Ext3Buffer[];
double Ext4Buffer[];
double Ext5Buffer[];
double Ext6Buffer[];
double Ext7Buffer[];
double Ext8Buffer[];
double Ext9Buffer[];
double Ext10Buffer[];
double Ext11Buffer[];
double Ext12Buffer[];
double Ext13Buffer[];

//--- unique prefix to identify indicator objects
string ExtPrefixUniq;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- check current timeframe
   if(PeriodSeconds()>PeriodSeconds(PERIOD_D1))
     {
      Alert("Timeframe of chart must be D1 or lower. Exit");
      return(INIT_FAILED);
     }

//--- define buffers
   if(InpShowExtraLevels)
     {
      SetIndexBuffer(0, Ext1Buffer);
      SetIndexBuffer(1, Ext2Buffer);
      SetIndexBuffer(2, Ext3Buffer);
      SetIndexBuffer(3, Ext4Buffer);
      SetIndexBuffer(4, Ext5Buffer);
      SetIndexBuffer(5, Ext6Buffer);
      SetIndexBuffer(6, Ext7Buffer);
      SetIndexBuffer(7, Ext8Buffer);
      SetIndexBuffer(8, Ext9Buffer);
      SetIndexBuffer(9, Ext10Buffer);
      SetIndexBuffer(10, Ext11Buffer);
      SetIndexBuffer(11, Ext12Buffer);
      SetIndexBuffer(12, Ext13Buffer);
     }
   else
     {
      SetIndexBuffer(0, Ext1Buffer, INDICATOR_CALCULATIONS);
      SetIndexBuffer(1, Ext2Buffer, INDICATOR_CALCULATIONS);
      SetIndexBuffer(2, Ext3Buffer);
      SetIndexBuffer(3, Ext4Buffer);
      SetIndexBuffer(4, Ext5Buffer);
      SetIndexBuffer(5, Ext6Buffer);
      SetIndexBuffer(6, Ext7Buffer);
      SetIndexBuffer(7, Ext8Buffer);
      SetIndexBuffer(8, Ext9Buffer);
      SetIndexBuffer(9, Ext10Buffer);
      SetIndexBuffer(10, Ext11Buffer);
      SetIndexBuffer(11, Ext12Buffer, INDICATOR_CALCULATIONS);
      SetIndexBuffer(12, Ext13Buffer, INDICATOR_CALCULATIONS);
     }

//--- indicator name
   IndicatorSetString(INDICATOR_SHORTNAME, "Murrey Math Channels");
//--- number of digits of indicator value
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

//--- prepare prefix for objects
   string number=StringFormat("%I64d", GetTickCount64());
   ExtPrefixUniq=StringSubstr(number, StringLen(number)-4);
   ExtPrefixUniq=ExtPrefixUniq+"_MM";
   Print("Indicator \"Murrey Math Channels\" started, prefix=", ExtPrefixUniq);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int start;
//--- if this is the first calculation of the indicator, fill buffers with empty initial values
   if(prev_calculated==0)
     {
      FillBuffers(EMPTY_VALUE);
      //--- shift from the beginning by the required number of bars
      start=InpCalculationPeriod+1;
     }
   else
     {
      //--- if the indicator has previously been calculated, calculate values for the last 2 bars
      start=prev_calculated-2;
     }

//--- calculate levels for all bars in a loop
   int i=start;
   for(; i<rates_total; i++)
     {
      //--- calculate parameters
      double min=low[ArrayMinimum(low, i-InpCalculationPeriod, InpCalculationPeriod)];
      double max=high[ArrayMaximum(high, i-InpCalculationPeriod, InpCalculationPeriod)];
      double fractal=DetermineFractal(max);
      double range=max-min;
      double sum=MathFloor(MathLog(fractal/range)/MathLog(2));
      double octave=fractal*(MathPow(0.5, sum));
      double mn=MathFloor(min/octave)*octave;
      double mx=mn+(2*octave);
      if((mn+octave)>=max)
         mx=mn+octave;

      //--- calculation of Resistance level
      double x1=0, x2=0, x3=0, x4=0, x5=0, x6=0;
      if((min>=(3*(mx-mn)/16+mn)) && (max<=(9*(mx-mn)/16+mn)))
         x2=mn+(mx-mn)/2;
      if((min>=(mn-(mx-mn)/8)) && (max<=(5*(mx-mn)/8+mn)) && (x2==0))
         x1=mn+(mx-mn)/2;
      if((min>=(mn+7*(mx-mn)/16)) && (max<=(13*(mx-mn)/16+mn)))
         x4=mn+3*(mx-mn)/4;
      if((min>=(mn+3*(mx-mn)/8)) && (max<=(9*(mx-mn)/8+mn)) && (x4==0))
         x5=mx;
      if((min>=(mn+(mx-mn)/8)) && (max<=(7*(mx-mn)/8+mn)) && (x1==0) && (x2==0) && (x4==0) && (x5==0))
         x3=mn+3*(mx-mn)/4;
      if((x1+x2+x3+x4+x5)==0)
         x6=mx;
      double resistance_level=x1+x2+x3+x4+x5+x6;

      //--- calculation of Support level
      double y1=0, y2=0, y3=0, y4=0, y5=0, y6=0;
      if(x1>0)
         y1=mn;
      if(x2>0)
         y2=mn+(mx-mn)/4;
      if(x3>0)
         y3=mn+(mx-mn)/4;
      if(x4>0)
         y4=mn+(mx-mn)/2;
      if(x5>0)
         y5=mn+(mx-mn)/2;
      if((resistance_level>0) && ((y1+y2+y3+y4+y5)==0))
         y6=mn;
      double support_level=y1+y2+y3+y4+y5+y6;

      //--- divider of MM levels
      double divide_mml=(resistance_level-support_level)/8;

      //--- write values into buffers
      Ext13Buffer[i]=support_level-2*divide_mml;
      Ext12Buffer[i]=Ext13Buffer[i]+divide_mml;
      Ext11Buffer[i]=Ext12Buffer[i]+divide_mml;
      Ext10Buffer[i]=Ext11Buffer[i]+divide_mml;
      Ext9Buffer[i]=Ext10Buffer[i]+divide_mml;
      Ext8Buffer[i]=Ext9Buffer[i]+divide_mml;
      Ext7Buffer[i]=Ext8Buffer[i]+divide_mml;
      Ext6Buffer[i]=Ext7Buffer[i]+divide_mml;
      Ext5Buffer[i]=Ext6Buffer[i]+divide_mml;
      Ext4Buffer[i]=Ext5Buffer[i]+divide_mml;
      Ext3Buffer[i]=Ext4Buffer[i]+divide_mml;
      Ext2Buffer[i]=Ext3Buffer[i]+divide_mml;
      Ext1Buffer[i]=Ext2Buffer[i]+divide_mml;

      //--- remove line clutter
      if(Ext1Buffer[i]!=Ext1Buffer[i-1])
         Ext1Buffer[i-1]=EMPTY_VALUE;
      if(Ext2Buffer[i]!=Ext2Buffer[i-1])
         Ext2Buffer[i-1]=EMPTY_VALUE;
      if(Ext3Buffer[i]!=Ext3Buffer[i-1])
         Ext3Buffer[i-1]=EMPTY_VALUE;
      if(Ext4Buffer[i]!=Ext4Buffer[i-1])
         Ext4Buffer[i-1]=EMPTY_VALUE;
      if(Ext5Buffer[i]!=Ext5Buffer[i-1])
         Ext5Buffer[i-1]=EMPTY_VALUE;
      if(Ext6Buffer[i]!=Ext6Buffer[i-1])
         Ext6Buffer[i-1]=EMPTY_VALUE;
      if(Ext7Buffer[i]!=Ext7Buffer[i-1])
         Ext7Buffer[i-1]=EMPTY_VALUE;
      if(Ext8Buffer[i]!=Ext8Buffer[i-1])
         Ext8Buffer[i-1]=EMPTY_VALUE;
      if(Ext9Buffer[i]!=Ext9Buffer[i-1])
         Ext9Buffer[i-1]=EMPTY_VALUE;
      if(Ext10Buffer[i]!=Ext10Buffer[i-1])
         Ext10Buffer[i-1]=EMPTY_VALUE;
      if(Ext11Buffer[i]!=Ext11Buffer[i-1])
         Ext11Buffer[i-1]=EMPTY_VALUE;
      if(Ext12Buffer[i]!=Ext12Buffer[i-1])
         Ext12Buffer[i-1]=EMPTY_VALUE;
      if(Ext13Buffer[i]!=Ext13Buffer[i-1])
         Ext13Buffer[i-1]=EMPTY_VALUE;
     }

//--- draw labels on levels
   if(InpShowLabel)
     {
      ShowPriceLevels(time[rates_total-1], rates_total-1);
      ChartRedraw();
     }

//--- succesfully calculated
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Initialize buffers with initial values                           |
//+------------------------------------------------------------------+
void FillBuffers(double value=0)
  {
   int count=ArraySize(Ext1Buffer);
   ArrayFill(Ext1Buffer, 0, count, value);
   ArrayFill(Ext2Buffer, 0, count, value);
   ArrayFill(Ext3Buffer, 0, count, value);
   ArrayFill(Ext4Buffer, 0, count, value);
   ArrayFill(Ext5Buffer, 0, count, value);
   ArrayFill(Ext6Buffer, 0, count, value);
   ArrayFill(Ext7Buffer, 0, count, value);
   ArrayFill(Ext8Buffer, 0, count, value);
   ArrayFill(Ext9Buffer, 0, count, value);
   ArrayFill(Ext10Buffer, 0, count, value);
   ArrayFill(Ext11Buffer, 0, count, value);
   ArrayFill(Ext12Buffer, 0, count, value);
   ArrayFill(Ext13Buffer, 0, count, value);
  }
//+------------------------------------------------------------------+
//| Determine the fractal                                            |
//+------------------------------------------------------------------+
double DetermineFractal(double value)
  {
   if(value<=250000 && value>25000)
      return(100000);

   if(value<=25000 && value>2500)
      return(10000);

   if(value<=2500 && value>250)
      return(1000);

   if(value<=250 && value>25)
      return(100);

   if(value<=25 && value>12.5)
      return(12.5);

   if(value<=12.5 && value>6.25)
      return(12.5);

   if(value<=6.25 && value>3.125)
      return(6.25);

   if(value<=3.125 && value>1.5625)
      return(3.125);

   if(value<=1.5625 && value>0.390625)
      return(1.5625);

   if(value<=0.390625 && value>0)
      return(0.1953125);

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete all our graphical objects after use
   Print("Indicator \"Murrey Math Channels\" stopped, delete all objects with prefix=", ExtPrefixUniq);
   ObjectsDeleteAll(0, ExtPrefixUniq, 0, OBJ_ARROW_RIGHT_PRICE);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//|  Show prices' levels                                             |
//+------------------------------------------------------------------+
void ShowPriceLevels(datetime time, int last_index)
  {
   ShowRightPrice(ExtPrefixUniq+" [8/8]", time, Ext3Buffer[last_index], clrMediumSlateBlue);
   ShowRightPrice(ExtPrefixUniq+" [7/8]", time, Ext4Buffer[last_index], clrFireBrick);
   ShowRightPrice(ExtPrefixUniq+" [6/8]", time, Ext5Buffer[last_index], clrRed);
   ShowRightPrice(ExtPrefixUniq+" [5/8]", time, Ext6Buffer[last_index], clrGreen);
   ShowRightPrice(ExtPrefixUniq+" [4/8]", time, Ext7Buffer[last_index], clrDarkGray);
   ShowRightPrice(ExtPrefixUniq+" [3/8]", time, Ext8Buffer[last_index], clrGreen);
   ShowRightPrice(ExtPrefixUniq+" [2/8]", time, Ext9Buffer[last_index], clrRed);
   ShowRightPrice(ExtPrefixUniq+" [1/8]", time, Ext10Buffer[last_index], clrFireBrick);
   ShowRightPrice(ExtPrefixUniq+" [0/8]", time, Ext11Buffer[last_index], clrMediumSlateBlue);

   if(InpShowLabel)
     {
      ShowRightPrice(ExtPrefixUniq+" [+2/8]", time, Ext1Buffer[last_index], clrDarkBlue);
      ShowRightPrice(ExtPrefixUniq+" [+1/8]", time, Ext2Buffer[last_index], clrDarkViolet);
      ShowRightPrice(ExtPrefixUniq+" [-1/8]", time, Ext12Buffer[last_index], clrDarkViolet);
      ShowRightPrice(ExtPrefixUniq+" [-2/8]", time, Ext13Buffer[last_index], clrDarkBlue);
     }
  }
//+------------------------------------------------------------------+
//| Create or Update "Right Price Label" object                      |
//+------------------------------------------------------------------+
bool ShowRightPrice(const string name, datetime time, double price, color clr)
  {
   if(!ObjectCreate(0, name, OBJ_ARROW_RIGHT_PRICE, 0, time, price))
     {
      ObjectMove(0, name, 0, time, price);
      return(false);
     }

//--- make the label size adaptive
   long scale=2;
   if(!ChartGetInteger(0, CHART_SCALE, 0, scale))
     {
      //--- output an error message to the Experts journal
      Print(__FUNCTION__+", ChartGetInteger(CHART_SCALE) failed, error = ", GetLastError());
     }
   int width=scale>1 ? 2:1;  // if chart scale > 1, then label size = 2

   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);

   return(true);
  }
//+------------------------------------------------------------------+
