#property copyright "Copyright © 2012, Murad Ismayilov"
#property link      "http://www.mql4.com/ru/users/wmlab"
 
#property indicator_chart_window
#property indicator_buffers 8

#property indicator_style1 STYLE_DOT
#property indicator_width1 1
#property indicator_color1 Sienna
 
#property indicator_style2 STYLE_DOT
#property indicator_width2 1
#property indicator_color2 Sienna

#property indicator_style3 STYLE_SOLID
#property indicator_width3 2
#property indicator_color3 Sienna

#property indicator_style4 STYLE_SOLID
#property indicator_width4 2
#property indicator_color4 DarkKhaki

#property indicator_style5 STYLE_SOLID
#property indicator_width5 3
#property indicator_color5 DodgerBlue
 
#property indicator_style6 STYLE_SOLID
#property indicator_width6 3
#property indicator_color6 DodgerBlue
 
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_color7 DodgerBlue
 
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_color8 DodgerBlue
 
#include <stdlib.mqh>
#include <stderror.mqh>
 
// Внешние переменные
 
extern bool IsTopCorner = true; // Информационный блок в верхнем углу?
extern int OffsetInBars = 1; // Смещение исходного образца в барах (для проверки надежности прогноза) [1..]
extern bool IsOffsetStartFixed = false; // Фиксировано ли начало образца
extern bool IsOffsetEndFixed = false; // Фиксирован ли конец образца
extern int PastInBars = 12; // Размер образца в барах, который ищется на истории [3..]
extern int VarShiftInBars = 4; // Смещение паттерна в барах плюс-минус [0..]
extern int ForecastInBars = 4; // На сколько баров вперед делать прогноз [1..]
extern int MaxAgeInDays = 365; // Минимальный возраст паттерна в днях [1..]
extern double MaxVarInPercents = 95; // Максимальное расхождение с лучшим вариантом в процентах [0..100]
extern int MaxAlts = 10; // Максимальное число найденных паттернов [1..]
extern bool ShowPastAverage = true; // Показывать ли среднюю истории
extern bool ShowForecastAverage = true; // Показывать ли прогноз средней
extern bool ShowBestPattern = true; // Показывать ли максимально близкий образец (вместо средней)
extern bool ShowTip = true; // Показывать ли торговый совет
extern color IndicatorPastAverageColor = White; // Цвет прошлой средней
extern color IndicatorCloudColor = White; // Цвет облака похожих вариантов
extern color IndicatorBestPatternColor = White; // Цвет самого похожего образца
extern color IndicatorVLinesColor = Aqua; // Цвет вертикальных линий-границ образца
extern color IndicatorTextColor = White; // Цвет текста инф.блока
extern color IndicatorTakeProfitColor = Aqua; // Цвет TakeProfit
extern int XCorner = 5; // Отступ инф.блока индикатора от правой границы графика
extern int YCorner = 15; // Отступ инф.блока индикатора от верхней границы графика
 
// Глобальные переменные
 
string IndicatorName = "WmiFor";
string IndicatorVersion = "3.0";
string IndicatorAuthor = "(wmlab@hotmail.com)";
bool Debug = true;
datetime OffsetStart, OffsetEnd;
bool IsRedraw;
datetime LastRedraw;
double PastAverage[];
double ForecastCloudHigh[];
double ForecastCloudLow[];
double ForecastCloudAverage[];
double ForecastBestPatternOpen[];
double ForecastBestPatternClose[];
double ForecastBestPatternHigh[];
double ForecastBestPatternLow[];
 
//+------------------------------------------------------------------+
//| Инициализация                                                    |
//+------------------------------------------------------------------+
 
int init()
{
   if (OffsetInBars < 1)
   {
      OffsetInBars = 1;
   }
   
   if (PastInBars < 3)
   {
      PastInBars = 3;
   }   
   
   if (ForecastInBars < 1)
   {
      ForecastInBars = 1;
   }
   
   if (VarShiftInBars < 0)
   {
      VarShiftInBars = 0;
   }
   
   SetIndexBuffer(0, ForecastCloudHigh);
   SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, EMPTY, IndicatorCloudColor);
   SetIndexShift(0, ForecastInBars - OffsetInBars);
   
   SetIndexBuffer(1, ForecastCloudLow);
   SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, EMPTY, IndicatorCloudColor);
   SetIndexShift(1, ForecastInBars - OffsetInBars);
   
   SetIndexBuffer(2, ForecastCloudAverage);
   SetIndexStyle(2, DRAW_LINE, EMPTY, EMPTY, IndicatorCloudColor);
   SetIndexShift(2, ForecastInBars - OffsetInBars);          
         
   SetIndexBuffer(3, PastAverage);
   SetIndexStyle(3, DRAW_LINE, EMPTY, EMPTY, IndicatorPastAverageColor);
   SetIndexShift(3, ForecastInBars - OffsetInBars);
   
   SetIndexBuffer(4, ForecastBestPatternOpen);
   SetIndexStyle(4, DRAW_HISTOGRAM, STYLE_SOLID, EMPTY, IndicatorBestPatternColor);
   SetIndexShift(4, ForecastInBars - OffsetInBars);
 
   SetIndexBuffer(5, ForecastBestPatternClose);
   SetIndexStyle(5, DRAW_HISTOGRAM, STYLE_SOLID, EMPTY, IndicatorBestPatternColor);
   SetIndexShift(5, ForecastInBars - OffsetInBars);
 
   SetIndexBuffer(6, ForecastBestPatternHigh);
   SetIndexStyle(6, DRAW_HISTOGRAM, STYLE_SOLID, EMPTY, IndicatorBestPatternColor);
   SetIndexShift(6, ForecastInBars - OffsetInBars);
   
   SetIndexBuffer(7, ForecastBestPatternLow);
   SetIndexStyle(7, DRAW_HISTOGRAM, STYLE_SOLID, EMPTY, IndicatorBestPatternColor);
   SetIndexShift(7, ForecastInBars - OffsetInBars);   
      
         
   RemoveOurObjects();
   
   IsRedraw = true;
   
   return (0);
}
 
//+------------------------------------------------------------------+
//| Деинициализация                                                  |
//+------------------------------------------------------------------+
 
int deinit()
{
   RemoveOurObjects();
 
   return (0);
}
 
//+------------------------------------------------------------------+
//| Работа индикатора                                                |
//+------------------------------------------------------------------+
 
int start()
{
   int counted_bars = IndicatorCounted();
   
   if (IsRedraw)
   {
      ReCalculate();
   }
   
   // Проверка на наличие вертикальных линий
   
   datetime time1;
   string vlineOffsetStart = IndicatorName + "OffsetStart";
   if (ObjectFind(vlineOffsetStart) == -1)
   {
      time1 = iTime(NULL, 0, OffsetInBars + PastInBars - 1);
      ObjectCreate(vlineOffsetStart, OBJ_VLINE, 0, time1, 0);
      ObjectSetText(vlineOffsetStart, IndicatorName + ": Begin", 0);
      ObjectSet(vlineOffsetStart, OBJPROP_COLOR, IndicatorVLinesColor);
      ObjectSet(vlineOffsetStart, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(vlineOffsetStart, OBJPROP_WIDTH, 1);
   }
   
   string vlineOffsetEnd = IndicatorName + "OffsetEnd";
   if (ObjectFind(vlineOffsetEnd) == -1)
   {
      time1 = iTime(NULL, 0, OffsetInBars);
      ObjectCreate(vlineOffsetEnd, OBJ_VLINE, 0, time1, 0);
      ObjectSetText(vlineOffsetEnd, IndicatorName + ": End", 0);
      ObjectSet(vlineOffsetEnd, OBJPROP_COLOR, IndicatorVLinesColor);
      ObjectSet(vlineOffsetEnd, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(vlineOffsetEnd, OBJPROP_WIDTH, 1);
   }
   
   datetime datetimeOffsetStart = ObjectGet(vlineOffsetStart, OBJPROP_TIME1);
   int indexOffsetStart = iBarShift(Symbol(), 0, datetimeOffsetStart);
   datetime datetimeOffsetEnd = ObjectGet(vlineOffsetEnd, OBJPROP_TIME1);
   int indexOffsetEnd = iBarShift(Symbol(), 0, datetimeOffsetEnd);
   
   // Проверка на их корректную установку
   
   if (indexOffsetEnd < 1)
   {
      indexOffsetEnd  = 1;
      datetimeOffsetEnd = iTime(NULL, 0, indexOffsetEnd);
      ObjectSet(vlineOffsetEnd, OBJPROP_TIME1, datetimeOffsetEnd);
      ChangeOffset(1);
   }
      
   if ((indexOffsetStart - indexOffsetEnd + 1) < 3)
   {
      indexOffsetStart = indexOffsetEnd + 2;
      PastInBars = 3;
      datetimeOffsetStart = iTime(NULL, 0, indexOffsetStart);
      ObjectSet(vlineOffsetStart, OBJPROP_TIME1, datetimeOffsetStart);
   }
   
   if (datetimeOffsetEnd != OffsetEnd)
   {
      ChangeOffset(indexOffsetEnd);
   }
   
   if ((indexOffsetStart - indexOffsetEnd + 1) != PastInBars)
   {
      PastInBars = indexOffsetStart - indexOffsetEnd + 1;
   }
   
   if (IsNewBar())
   {
      if (!IsOffsetStartFixed && !IsOffsetEndFixed)
      {
         datetimeOffsetStart = iTime(NULL, 0, OffsetInBars + PastInBars - 1);
         ObjectSet(vlineOffsetStart, OBJPROP_TIME1, datetimeOffsetStart);
      }
      
      if (!IsOffsetEndFixed)
      {
         datetimeOffsetEnd = iTime(NULL, 0, OffsetInBars);
         ObjectSet(vlineOffsetEnd, OBJPROP_TIME1, datetimeOffsetEnd);
      }
   }         
   
   if ((datetimeOffsetStart != OffsetStart) || (datetimeOffsetEnd != OffsetEnd))
   {
      OffsetStart = datetimeOffsetStart;
      OffsetEnd = datetimeOffsetEnd;
      
      IsRedraw = true;
      LastRedraw = TimeCurrent();
   }      
      
   return (0);
}
 
//+------------------------------------------------------------------+
//| Появился новый бар?                                              |
//+------------------------------------------------------------------+
 
bool IsNewBar()
{
   static datetime prevTime = 0;
 
   datetime currentTime = iTime(NULL, 0, 0);
   if (prevTime == currentTime)
   {
      return (false);
   }
 
   prevTime = currentTime;
   return (true);
}
  
//+------------------------------------------------------------------+
//| Убираем все наши метки                                           |
//+------------------------------------------------------------------+
 
void RemoveOurObjects()
{
   for (int index = 0; index < ObjectsTotal(); index++)
   {
      if (StringFind(ObjectName(index), IndicatorName) == 0)
      {
         ObjectDelete(ObjectName(index));
         index--;
      }
   }
}
 
//+------------------------------------------------------------------+
//| Устанавливаем смещение всех линий индикатора                     |
//+------------------------------------------------------------------+
 
void ChangeOffset(int newOffset)
{
   OffsetInBars = newOffset;
   for (int indexIndicator = 0; indexIndicator < 6; indexIndicator++)
   {
      SetIndexShift(indexIndicator, ForecastInBars - OffsetInBars);
   } 
}

//+------------------------------------------------------------------+
//| DTW                                                              |
//+------------------------------------------------------------------+

double Distance(double value1, double value2)
{
   double value = MathAbs(value1 - value2);
   return (value);
}

double DTWDistance(double& s[], double& t[]) 
{
   int slenght = ArraySize(s);
   int tlenght = ArraySize(t);
   double dtw[100][100];
   int i, j;

   dtw[0, 0] = 0.0;
   for (j = 1; j <= tlenght; j++)
   {
      dtw[0, j] = 1000000.0;
   }
   
   for (i = 1; i <= slenght; i++)
   {
      dtw[i, 0] = 1000000.0;
   }

   for (i = 1; i <= slenght; i++)
   {
      for (j = 1; j <= tlenght; j++)
      {
         dtw[i, j] = Distance(s[i], t[j]) + MathMin(dtw[i - 1, j], MathMin(dtw[i, j - 1], dtw[i - 1, j - 1]));
      }
   }

   return (dtw[slenght, tlenght]);
}
 
//+------------------------------------------------------------------+
//| Пересчет                                                         |
//+------------------------------------------------------------------+
 
void ReCalculate()
{
   datetime currentTime = TimeCurrent();
   if ((currentTime - LastRedraw) < 1)
   {
      return;
   }
   
   LastRedraw = currentTime;
   IsRedraw = false;
   
   if (Bars < 100)
   {
      return;
   }
   
   int handleLog;
   if (Debug)
   {
      handleLog = FileOpen(IndicatorName + ".log", FILE_WRITE);
      if (handleLog < 1)
      {
         Print ("handleLog = ", handleLog, ", error = ", GetLastError());
      }
   }
      
   datetime xtime = iTime(NULL, 0, OffsetInBars);
   datetime minDate = xtime - (MaxAgeInDays * 60 * 60 * 24);
   int baseHour = TimeHour(xtime);
   int baseMinute = TimeMinute(xtime);
   double x[];   
   ArrayResize(x, PastInBars);
   double x0 = iClose(NULL, 0, OffsetInBars);
   
   if (Debug)
   {
      FileWrite(handleLog, "xtime", TimeToStr(xtime));
      FileWrite(handleLog, "minDate", TimeToStr(minDate));
      FileWrite(handleLog, "baseHour", baseHour);
      FileWrite(handleLog, "baseMinute", baseMinute);  
      FileWrite(handleLog, "x0", x0);
   }
   
   for (int indexBar = OffsetInBars; indexBar < (OffsetInBars + PastInBars); indexBar++)
   {
      x[indexBar - OffsetInBars] = x0 - iClose(NULL, 0, indexBar);
      if (Debug)
      {
         FileWrite(handleLog, "x", indexBar - OffsetInBars, x[indexBar - OffsetInBars]);
      }
   }
   
   int foundAlts = 0;
   int iAlt[];
   ArrayResize(iAlt, MaxAlts);
   double dAlt[];
   ArrayResize(dAlt, MaxAlts);
   
   int patternscount = 0;
   
   for (int indexShift = ForecastInBars + OffsetInBars + 1; indexShift < Bars; indexShift++)
   {
      datetime ytimebase = iTime(NULL, 0, indexShift);
      
      if (ytimebase < minDate)
      {
         break;
      }
      
      if ((indexShift + PastInBars + VarShiftInBars) >= Bars)
      {
         break;
      }
      
      int currentHour = TimeHour(ytimebase);
      if (currentHour != baseHour)
      {
         continue;
      }
 
      int currentMinute = TimeMinute(ytimebase);
      if (currentMinute != baseMinute)
      {
         continue;
      }
      
      int iAltSingle = 0;
      double dAltSingle = 1000000.0;
      double y[];
      ArrayResize(y, PastInBars);

      for (int indexVar = indexShift - VarShiftInBars; indexVar <= indexShift + VarShiftInBars; indexVar++)
      {
         patternscount++;
         datetime ytime = iTime(NULL, 0, indexVar);
         double y0 = iClose(NULL, 0, indexVar);
         for (indexBar = indexVar; indexBar < (indexVar + PastInBars); indexBar++)
         {
            y[indexBar - indexVar] = y0 - iClose(NULL, 0, indexBar);
         }
         
         double dtw = DTWDistance(x, y);
         if (dtw < dAltSingle)
         {                      
            dAltSingle = dtw;
            iAltSingle = indexVar;
         }
      }
      
      if (Debug)
      {
         FileWrite(handleLog, "");
         FileWrite(handleLog, "iAltSingle", iAltSingle);
         FileWrite(handleLog, "dAltSingle", dAltSingle);
      }
      
      bool altAdded = false;
      int j = 0;
      for (j = 0; j < foundAlts; j++)
      {
         if (dAltSingle < dAlt[j])
         {
            if (foundAlts == MaxAlts)
            {
               foundAlts = MaxAlts - 1;   
            }
         
            for (int m = foundAlts; m >= (j + 1); m--)
            {
               iAlt[m] = iAlt[m - 1];
               dAlt[m] = dAlt[m - 1];
            }
         
            iAlt[j] = iAltSingle;
            dAlt[j] = dAltSingle;
            foundAlts++;
            altAdded = true;
            break;
         }
      }
      
      if (!altAdded)
      {
         if (foundAlts < MaxAlts)
         {
            iAlt[j] = iAltSingle;
            dAlt[j] = dAltSingle;
            foundAlts++;
         }
      }
   }
   
   if (Debug)
   {
      FileWrite(handleLog, "");
      FileWrite(handleLog, "foundAlts", foundAlts);
      FileWrite(handleLog, "iAlt[0]", iAlt[0]);
      FileWrite(handleLog, "dAlt[0]", dAlt[0]);
   }
   
   if (foundAlts > 1)
   {
      for (int a = 1; a < foundAlts; a++)
      {
         double sim = 100.0 - (((dAlt[a] - dAlt[0]) * 100.0) / dAlt[a]);
         if (Debug)
         {
            FileWrite(handleLog, "a", a, "dAlt", dAlt[a], "sim", sim);
         }
         
         if (sim < MaxVarInPercents)
         {
            foundAlts = a;
            break;
         }
      }
   }   
   
   double xcbase, ycbase;
   int altindex;
   
   ArrayInitialize(PastAverage, EMPTY_VALUE);
   if (ShowPastAverage && !ShowBestPattern)
   {
      if (Debug)
      {
         FileWrite(handleLog, "");
      }
      
      for (indexBar = ForecastInBars; indexBar < (PastInBars + ForecastInBars); indexBar++)
      {
         PastAverage[indexBar] = iClose(NULL, 0, indexBar - ForecastInBars + OffsetInBars);
         if (Debug)
         {
            FileWrite(handleLog, "PastBar", indexBar - ForecastInBars, PastAverage[indexBar]);
         }
      }   
   }
   
   ArrayInitialize(ForecastCloudHigh, EMPTY_VALUE);
   ArrayInitialize(ForecastCloudLow, EMPTY_VALUE);
   ArrayInitialize(ForecastCloudAverage, EMPTY_VALUE);
   
   double forecastCloudHigh[];
   ArrayResize(forecastCloudHigh, ForecastInBars);
   ArrayInitialize(ForecastCloudHigh, -1000000.0);
   double forecastCloudLow[];
   ArrayResize(forecastCloudLow, ForecastInBars);
   ArrayInitialize(forecastCloudLow, 1000000.0);
   double forecastCloudAverage[];
   ArrayResize(forecastCloudAverage, ForecastInBars);
   ArrayInitialize(forecastCloudAverage, 0.0);
      
   xcbase = iClose(NULL, 0, OffsetInBars);
   for (indexBar = 0; indexBar < ForecastInBars; indexBar++)
   {
      for (a = 0; a < foundAlts; a++)
      {
         altindex = iAlt[a] - ForecastInBars + indexBar;
         ycbase = iClose(NULL, 0, iAlt[a]);            
         double yclose = xcbase + (iClose(NULL, 0, altindex) - ycbase);
         if (yclose > forecastCloudHigh[indexBar])
         {
            forecastCloudHigh[indexBar] = yclose;
         }
            
         if (yclose < forecastCloudLow[indexBar])
         {
            forecastCloudLow[indexBar] = yclose;
         }
            
         forecastCloudAverage[indexBar] += yclose;
      }
         
      forecastCloudAverage[indexBar] /= foundAlts;
      
      if (ShowForecastAverage && !ShowBestPattern)
      {
         if (foundAlts > 1)
         {
            ForecastCloudHigh[indexBar] = forecastCloudHigh[indexBar];
            ForecastCloudLow[indexBar] = forecastCloudLow[indexBar];
         }
         
         ForecastCloudAverage[indexBar] = forecastCloudAverage[indexBar];
      }
   }
    
   if (ShowForecastAverage && !ShowBestPattern)
   {  
      if (foundAlts > 1)
      {
         ForecastCloudHigh[indexBar] = xcbase;
         ForecastCloudLow[indexBar] = xcbase;
      }
      
      ForecastCloudAverage[indexBar] = xcbase;
   }

   ArrayInitialize(ForecastBestPatternOpen, EMPTY_VALUE);
   ArrayInitialize(ForecastBestPatternClose, EMPTY_VALUE);
   ArrayInitialize(ForecastBestPatternHigh, EMPTY_VALUE);
   ArrayInitialize(ForecastBestPatternLow, EMPTY_VALUE);
   xcbase = iClose(NULL, 0, OffsetInBars);
   if (ShowBestPattern)
   {   
      ycbase = iClose(NULL, 0, iAlt[0]);
      for (indexBar = 0; indexBar < (PastInBars + ForecastInBars - 1); indexBar++)
      {
         altindex = iAlt[0] - ForecastInBars + indexBar;
         ForecastBestPatternOpen[indexBar] = xcbase + (iOpen(NULL, 0, altindex) - ycbase);
         ForecastBestPatternClose[indexBar] = xcbase + (iClose(NULL, 0, altindex) - ycbase);
         ForecastBestPatternHigh[indexBar] = xcbase + (iHigh(NULL, 0, altindex) - ycbase);
         ForecastBestPatternLow[indexBar] = xcbase + (iLow(NULL, 0, altindex) - ycbase);
      }
   }
   
   int opsignal = 0;
   double ztp = 0.0, zsl = 0.0;
   int digits = MarketInfo(Symbol(), MODE_DIGITS);
   int spread = MarketInfo(Symbol(), MODE_SPREAD);
   double point = MarketInfo(Symbol(), MODE_POINT);
   int stoplevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
   if (stoplevel == 0.0)
   {
      // tester mode
      stoplevel = spread * 2;
   }
   
   double forecastBuy = forecastCloudLow[ArrayMaximum(forecastCloudLow)];
   double diffBuy = forecastBuy - xcbase;
   double forecastSell = forecastCloudHigh[ArrayMinimum(forecastCloudHigh)];
   double diffSell = xcbase - forecastSell;
   if ((diffBuy > 0.0) && (diffSell < 0.0))
   {
      opsignal = 1;
      ztp = forecastBuy;
      zsl = xcbase - diffBuy;
   }
   else
   {
      if ((diffBuy < 0.0) && (diffSell > 0.0))
      {
         opsignal = -1;
         ztp = forecastSell;
         zsl = xcbase + diffSell;
      }
      else
      {
         if ((diffBuy > 0.0) && (diffSell > 0.0))
         {
            if (diffBuy > diffSell)
            {
               opsignal = 1;
               ztp = forecastBuy;
               zsl = xcbase - diffBuy;
            }
            else
            {
               opsignal = -1;
               ztp = forecastSell;
               zsl = xcbase + diffSell;
            }
         }
      }
   }

   if (Debug)
   {
      FileWrite(handleLog, "");
      FileWrite(handleLog, "forecastBuy", forecastBuy);
      FileWrite(handleLog, "forecastSell", forecastSell);
      FileWrite(handleLog, "diffBuy", diffBuy);
      FileWrite(handleLog, "diffSell", diffSell);      
      FileWrite(handleLog, "opsignal", opsignal);
   }   
   
   if (ShowTip)
   {
      if (opsignal == 0)
      {
         DrawTrendTipLabel("NO TRADE SIGNAL");
      }
      else
      {
         if (opsignal > 0)
         {
            if (ztp > (xcbase + (stoplevel * point)))
            {
               DrawTrendTipLabel("BUY!  TP: " + DoubleToStr(ztp, digits));
               DrawTakeProfit(ztp, IndicatorTakeProfitColor);
               DrawStopLoss(zsl, IndicatorTakeProfitColor);
            }
            else
            {
               opsignal = 0;
               DrawTrendTipLabel("NO TRADE SIGNAL");
               DrawTakeProfit(0.0, IndicatorTakeProfitColor);
               DrawStopLoss(0.0, IndicatorTakeProfitColor);
            }
         }
         else
         {
            if (ztp < (xcbase - (stoplevel * point)))
            {
               DrawTrendTipLabel("SELL!  TP: " + DoubleToStr(ztp, digits));
               DrawTakeProfit(ztp, IndicatorTakeProfitColor);
               DrawStopLoss(zsl, IndicatorTakeProfitColor);
            }
            else
            {
               opsignal = 0;
               DrawTrendTipLabel("NO TRADE SIGNAL");
               DrawTakeProfit(0.0, IndicatorTakeProfitColor);
               DrawStopLoss(0.0, IndicatorTakeProfitColor);
            }
         }
      }
   }
   else
   {
      DrawTrendTipLabel("");
      DrawTakeProfit(0.0, IndicatorTakeProfitColor);
      DrawStopLoss(0.0, IndicatorTakeProfitColor);
   }
      
   DrawLabel("Name", IndicatorName + " " + IndicatorVersion + " " + IndicatorAuthor, 0, 0, IndicatorTextColor, "Arial", 7);
   if (Debug)
   {
      FileClose(handleLog);
   }
}
 
//+------------------------------------------------------------------+
//| Рисование текстовой метки                                        |
//+------------------------------------------------------------------+
 
void DrawLabel(string label, string text, int x, int y, color clr, string fontName, int fontSize)
{
   int typeCorner = 1;
   if (!IsTopCorner)
   {
      typeCorner = 3;
   }
 
   string labelIndicator = IndicatorName + "Label" + label;   
   if (ObjectFind(labelIndicator) == -1)
   {
      ObjectCreate(labelIndicator, OBJ_LABEL, 0, 0, 0);
   }
   
   ObjectSet(labelIndicator, OBJPROP_CORNER, typeCorner);
   ObjectSet(labelIndicator, OBJPROP_XDISTANCE, XCorner + x);
   ObjectSet(labelIndicator, OBJPROP_YDISTANCE, YCorner + y);
   ObjectSetText(labelIndicator, text, fontSize, fontName, clr);
}

//+------------------------------------------------------------------+
//| Рисование большой текстовой метки                                |
//+------------------------------------------------------------------+
 
void DrawTrendTipLabel(string text)
{
   DrawLabel("TrendTip", text, 0, 10, IndicatorTextColor, "Impact", 18);
}

//+------------------------------------------------------------------+
//| Рисование горизонтальной линии                                   |
//+------------------------------------------------------------------+

void DrawTakeProfit(double price, color clr)
{
   string labelHLine = IndicatorName + "TP"; 
   if (ObjectFind(labelHLine) == -1)
   {
      ObjectCreate(labelHLine, OBJ_HLINE, 0, 0, price);
   }
   else
   {
      ObjectSet(labelHLine, OBJPROP_PRICE1, price);
   }
   
   ObjectSet(labelHLine, OBJPROP_COLOR, clr);
   ObjectSet(labelHLine, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(labelHLine, OBJPROP_WIDTH, 1);   
   ObjectSetText(labelHLine, IndicatorName + ": T/P", 7, "Arial", clr);   
}

//+------------------------------------------------------------------+
//| Рисование горизонтальной линии                                   |
//+------------------------------------------------------------------+

void DrawStopLoss(double price, color clr)
{
   string labelHLine = IndicatorName + "SL"; 
   if (ObjectFind(labelHLine) == -1)
   {
      ObjectCreate(labelHLine, OBJ_HLINE, 0, 0, price);
   }
   else
   {
      ObjectSet(labelHLine, OBJPROP_PRICE1, price);
   }
   
   ObjectSet(labelHLine, OBJPROP_COLOR, clr);
   ObjectSet(labelHLine, OBJPROP_STYLE, STYLE_DOT);
   ObjectSet(labelHLine, OBJPROP_WIDTH, 1);   
   ObjectSetText(labelHLine, IndicatorName + ": S/L", 7, "Arial", clr);   
}

