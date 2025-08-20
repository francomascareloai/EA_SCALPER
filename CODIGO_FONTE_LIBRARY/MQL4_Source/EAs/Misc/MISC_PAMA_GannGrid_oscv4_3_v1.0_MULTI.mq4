//+------------------------------------------------------------------+
//|                                        PAMA GannGrid_oscv4.3.mq4 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010.01.24, SwingMan"
#property link      ""
/*+------------------------------------------------------------------+
   v 4.1  draw trading lines
   v 4.3  text shift for values
//+-----------------------------------------------------------------*/
string sIndicatorName = "PAMA GannGrid_oscv4.3";

//---- window
bool Draw_InMainWindow = false;
#property indicator_separate_window
//#property indicator_chart_window

#property indicator_buffers 8

#property indicator_color1 DodgerBlue //price line
#property indicator_color2 DodgerBlue //price dots
#property indicator_color3 Silver     //max,min; identical with MainGrid_Color
#property indicator_color4 Silver
#property indicator_color5 Green  //up arrow
#property indicator_color6 Green  //up line
#property indicator_color7 Red   //dn arrow
#property indicator_color8 Red   //dn line

#property indicator_width1 2 //price line
#property indicator_width2 1 //price dots
#property indicator_width3 1 //max,min; identical with MainGrid_Color
#property indicator_width4 1 //
#property indicator_width5 2 //up arrow
#property indicator_width6 2 //up line
#property indicator_width7 2 //dn arrow
#property indicator_width8 2 //dn line

#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_SOLID

//---- extern inputs
//+------------------------------------------------------------------+
extern string ____GridBegin____ = "";
extern bool UseBeginDate = false;
//extern string BeginDate = "2010.01.21";
//extern string BeginDate = "2009.11.01";
extern string BeginDate = "2010.01.01 00:00";
extern int nBarsBack = 120;//250;
extern string prices = "0=close, 4=median, 5=typical";
extern int Price_Mode = 5;
//-- oscillator
extern bool Show_GridMatrix = true;
extern bool Show_GannGrid = true;
//-- indicator
//extern bool Show_GridMatrix = false;
//extern bool Show_GannGrid = false;
extern bool Show_HiloArrows = true;
extern bool Show_PriceArrows = true;
extern bool Show_Comments = false;
extern string ____MainGrid____ = "";
extern color MainGrid_Color = Silver;//Green;//Sienna;
extern int MainGrid_Style = STYLE_DOT;
extern int MinMaxGrid_Style = STYLE_SOLID;
extern int MainGrid_Width = 1;
extern int fontSize = 8;
extern bool Draw_AllGrids = false;
extern bool Draw_AdditionalGrids = false;
extern string ____GannGrid____ = "";
extern color GannGrid_Color = Silver;//Gray;
//---- if (Draw_InMainWindow == true) 
extern int GannGrid_Style = STYLE_DOT;
//---- if (Draw_InMainWindow == false) 
//extern int GannGrid_Style = STYLE_SOLID;
extern int GannGrid_Width = 1;
extern string ____Default_GridParameters____ = "Recomanded GridInterval 35 or 36";
extern int MainGrid_Intervals = 36;   //default=35(!)
extern double GannGrid_Interval = 8.0;//with default 8.5 is the time interval not OK; and 9 is too large
extern int Text_Shift = 50;
//+------------------------------------------------------------------+

//---- default input parameters
//string ____DefaultGridInterval____ = "";
//int MainGrid_Intervals = 36;   //default=35(!)
//double GannGrid_Interval = 8.0;//with default 8.5 is the time interval not OK; and 9 is too large

//---- buffers
double price[], dotPrice[];
double MaxPriceLine[], MinPriceLine[];
double upArrow[], upLine[], dnArrow[], dnLine[];

//---- variables
int iWindow;
string sWindowName;
datetime firstTime, thisTime, oldTime;
bool bGridOK = false;
int nMainGrid_Intervals;
int iGannGrid_Interval, iHalfInterval;
datetime maxPriceTime, minPriceTime;
double maxPrice, minPrice, gridStep;
bool UseBeginDateOriginal;
int nDigits;

//####################################################################
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{  
//---- indicators
   SetIndexBuffer(0,price);    SetIndexStyle(0,DRAW_LINE); 
      SetIndexLabel(0,"PAMA Price");
   SetIndexBuffer(1,dotPrice); SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,159); 
      SetIndexLabel(1,NULL);
   SetIndexBuffer(2,MaxPriceLine);   SetIndexStyle(2,DRAW_LINE,MinMaxGrid_Style,MainGrid_Width,MainGrid_Color); 
      SetIndexLabel(2,"maxPrice");
   SetIndexBuffer(3,MinPriceLine);   SetIndexStyle(3,DRAW_LINE,MinMaxGrid_Style,MainGrid_Width,MainGrid_Color); 
      SetIndexLabel(3,"minPrice");      
   SetIndexBuffer(4,upArrow); SetIndexStyle(4,DRAW_ARROW); SetIndexArrow(4,241); 
      SetIndexLabel(4,NULL);      
   SetIndexBuffer(5,upLine);  SetIndexStyle(5,DRAW_LINE); 
      SetIndexLabel(5,"upLine");      
   SetIndexBuffer(6,dnArrow); SetIndexStyle(6,DRAW_ARROW); SetIndexArrow(6,242); 
      SetIndexLabel(6,NULL);
   SetIndexBuffer(7,dnLine);  SetIndexStyle(7,DRAW_LINE); 
      SetIndexLabel(7,"dnLine");
//----
   SetIndexEmptyValue(7,EMPTY_VALUE);
//----
   string sName = sIndicatorName + "  ";
   if (Price_Mode == 0) string sPrice = "(ClosePrices) "; else
   if (Price_Mode == 4) sPrice = "(MedianPrices) "; else
   if (Price_Mode == 5) sPrice = "(TypicalPrices) "; 
   sWindowName = sName+sPrice;
   IndicatorShortName(sWindowName);
   IndicatorDigits(Digits);
//---- initialisations
   if (UseBeginDate == true)
   {
      firstTime = StrToTime(BeginDate + " 00:00");
      nBarsBack = 0;
   }
   else
      firstTime = 0;
   nMainGrid_Intervals = MainGrid_Intervals;
   iGannGrid_Interval  = GannGrid_Interval;
   iHalfInterval       = iGannGrid_Interval / 2;   
   UseBeginDateOriginal = UseBeginDate;
   nDigits = MarketInfo(Symbol(),MODE_DIGITS);
   if (nDigits == 5 || nDigits == 3) nDigits--;
   //---- window
   if (Draw_InMainWindow)   
        iWindow = 0;   
   else iWindow = WindowFind(sWindowName);
//----
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{  
   Delete_GannObjects();
   if (Show_Comments) Comment("");
   for (int i=0; i<nBarsBack+20; i++)
   {
      upArrow[i] = EMPTY_VALUE;
      dnArrow[i] = EMPTY_VALUE;
      upLine[i]  = EMPTY_VALUE;
      dnLine[i]  = EMPTY_VALUE;
   }
//----
   return(0);
}


//####################################################################
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
double dPrice;
   if (Draw_InMainWindow==false)
      if (iWindow < 1) iWindow = WindowFind(sWindowName);

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;   
   int limit = Bars-counted_bars;      

   //---- check newBar
   thisTime = Time[0]; 
   if (thisTime != oldTime) 
   {
      oldTime = thisTime;
      Delete_GannObjects();
      if ( (UseBeginDate == false && firstTime != 0) || //-- nBarsBack after first calculation
           (UseBeginDate == true  && limit < 4) )       //-- Date after first calculation
      {
         nBarsBack = 0;
         bGridOK = false;
         UseBeginDate = true; //firstTime is now allowable for nBarsBack
         int thisBarShift = iBarShift(Symbol(),Period(),firstTime,false);
         limit = thisBarShift;         
      }
   }
   
   //---- first min,max prices   
   if (bGridOK == false)
   {   
      dPrice = CurrentPrice(Price_Mode, 0);      
      maxPrice = dPrice; maxPriceTime = Time[0];
      minPrice = dPrice; minPriceTime = Time[0];
   }

   
   //---- draw prices, caculate min,max prices
   //================================================================
   for(int i=0; i<limit; i++)   
   {
      dPrice = CurrentPrice(Price_Mode, i);
      price[i] = dPrice;
      dotPrice[i]  = dPrice;

      if (bGridOK == false)
      {
         //---- use fix date as begin
         if (UseBeginDate == true)
         {
            if (Time[i] > firstTime)
            {
               if (dPrice > maxPrice) {maxPrice = dPrice; maxPriceTime = Time[i];}
               if (dPrice < minPrice) {minPrice = dPrice; minPriceTime = Time[i];}
               nBarsBack++;
            }
         }
         else
         //---- use nBarsBack as begin
         if (UseBeginDate == false)
         {
            if (i < nBarsBack)
            {
               if (dPrice > maxPrice) {maxPrice = dPrice; maxPriceTime = Time[i];}
               if (dPrice < minPrice) {minPrice = dPrice; minPriceTime = Time[i];}
               firstTime = Time[i];
            }         
         }         
      }
   }
   
   //---- calculate data for MainGrid
   if (bGridOK == false)
   {
      double diffMinMax = maxPrice - minPrice;
      gridStep = NormalizeDouble(diffMinMax / nMainGrid_Intervals,Digits);
   }
   
   //---- dummy lines for uper and lower prices
   for(i=0; i<limit; i++)   
   {
      MaxPriceLine[i] = maxPrice;// + iHalfInterval *gridStep;
      MinPriceLine[i] = minPrice;// - iHalfInterval *gridStep;
      Write_PriceValue(maxPrice);
      Write_PriceValue(minPrice);
   }

   //-- adjust nBarsBack
   if (UseBeginDate == true)
      nBarsBack++;
      
//---- draw matrix and GannGrid
//===================================================================
   if (bGridOK == false)
   {
   
//---- write matrix data
string st;   
st = st + "** " + sIndicatorName + " ** " + "\n";
if (UseBeginDateOriginal) string sBegin = "  (Date)"; else sBegin = "  (nBars)";
st = st + "GridBegin: " + TimeToStr(firstTime,TIME_DATE|TIME_MINUTES) + sBegin + "\n";
st = st + "nBarsBack= " + nBarsBack + "\n";
string sMaxPriceTime = "  (" + TimeToStr(maxPriceTime) + ")";
string sMinPriceTime = "  (" + TimeToStr(minPriceTime) + ")";
st = st + "maxPrice= " + DoubleToStr(maxPrice,Digits) + sMaxPriceTime + "\n";
st = st + "minPrice= " + DoubleToStr(minPrice,Digits) + sMinPriceTime + "\n";
double percent = 100.0 *( maxPrice - minPrice) / minPrice;
double gridPerc= percent / nMainGrid_Intervals;
string sGridPercent = " ( " + DoubleToStr(gridPerc,2) + " % )";
st = st + "Percent= " + DoubleToStr(percent,2) + " %\n";
st = st + "GridStep= " + DoubleToStr(gridStep,Digits) + sGridPercent + "\n";
string sGridStep = " (" + iHalfInterval + " GridSteps)";
st = st + "mainStep= " + DoubleToStr(gridStep*iHalfInterval,Digits) + sGridStep + "\n";
if (Show_Comments)
   Comment(st);   

//---- draw horizontal lines  (35+1=36 HLines) ----------------------
      if (MainGrid_Intervals == 36) 
           int nMainGrids = nMainGrid_Intervals;      
      else nMainGrids = nMainGrid_Intervals+1; //nMainGrid_Intervals+1 for 35
      
      if (Show_GridMatrix == true)
      for (i=1; i<nMainGrids; i++) 
      {  
         if (Draw_AllGrids == true)
            Draw_HorizontalLine(maxPrice - i*gridStep);
         else 
         {           
            if (MathMod(i,iHalfInterval) == 0)
               Draw_HorizontalLine(maxPrice - i*gridStep);
         }
         //---- write price values
         if (MathMod(i,iHalfInterval) == 0)
            Write_PriceValue(maxPrice - i*gridStep);
      }

      //-- additional grids
      if (Show_GridMatrix == true)
      if (Draw_AdditionalGrids)
      {
         for (int k=1; k<=iHalfInterval; k++)
            Draw_HorizontalLine(maxPrice+k*gridStep);         
         for (k=1; k<=iHalfInterval; k++) //k=2 for 35
            Draw_HorizontalLine(minPrice-k*gridStep);      
      }
      
//---- draw vertical lines ------------------------------------------
      if (Show_GridMatrix == true)
      for (i=0; i<nBarsBack; i++)
      {
         if (Draw_AllGrids == true)
            int j = i;
         else   
            j = (nBarsBack-1) - i * iHalfInterval;         
               
         if (j>0)
            datetime dTime = Time[j];
         else
            dTime = Time[0];   
         Draw_VerticalLine(dTime,minPrice,maxPrice);//minPrice-gridStep for 35
      }
      
//---- draw trading lines -------------------------------------------
      Draw_TradingLines();
            
//==== draw GannGrid lines (angle 45°) ==============================
      if (Show_GannGrid)
      {
         datetime time1 = Time[nBarsBack-1];
         datetime time2 = Time[nBarsBack-iHalfInterval-1];
         double price1 = maxPrice;      
         double price2 = maxPrice - iHalfInterval*gridStep;
         Draw_GannGrid(time1,time2, price1,price2);
      }
   }   
//----
   bGridOK = true;
   return(0);
}
//+------------------------------------------------------------------+

//___________________________________________________________________
void Draw_TradingLines()
{
//int xStep=0;
//      xStep++;
int iTrend;
double lineValue;

   int iFirstBar = nBarsBack-1;
   double firstPriceValue = price[iFirstBar];
   double diffBegin = price[iFirstBar] - price[iFirstBar+1];
   
   //---- first value -----------------------------------------------
   //---- high at begin
   if (diffBegin >= 0)
   {
      iTrend =  1;
      lineValue = firstPriceValue - iGannGrid_Interval*gridStep;
      Set_UpLineValue(iFirstBar, lineValue);
   }  
   else 
   //---- low at begin
   {
      iTrend = -1;
      lineValue = firstPriceValue + iGannGrid_Interval*gridStep;
      Set_DnLineValue(iFirstBar, lineValue);
   }
   
   //---- main loop
   //================================================================
   for (int i=nBarsBack-2; i>=0; i--)
   {
      //---- up trend (blue line) -----------------------------------
      if (iTrend == 1)
      {
         //---- translate up linie
         if (price[i] - iGannGrid_Interval*gridStep > lineValue + gridStep)
              lineValue = price[i] - iGannGrid_Interval*gridStep;
         else lineValue = lineValue + gridStep;
         Set_UpLineValue(i, lineValue);
         //---- reverse from up-trend / down-trend
         if (price[i] < lineValue)
         {
            iTrend = -1;
            lineValue = price[i] + iGannGrid_Interval*gridStep;
            Set_DnLineValue(i, lineValue);
            if (Show_PriceArrows)
               dnArrow[i] = price[i];            
            if (Show_HiloArrows)
               Show_SignalArrows(i, iTrend);
         }
      }
      else
      
      //---- down trend (red line) ----------------------------------
      if (iTrend == -1)
      {
         //---- translate down linie
         if (price[i] + iGannGrid_Interval*gridStep < lineValue - gridStep)
              lineValue = price[i] + iGannGrid_Interval*gridStep;
         else lineValue = lineValue - gridStep;
         Set_DnLineValue(i, lineValue);
         //---- reverse from down-trend / up-trend
         if (price[i] > lineValue)
         {
            iTrend = 1;
            lineValue = price[i] - iGannGrid_Interval*gridStep;
            Set_UpLineValue(i, lineValue);            
            if (Show_PriceArrows)
               upArrow[i] = price[i];
            if (Show_HiloArrows)
               Show_SignalArrows(i, iTrend);
         }
      }
   }
   return;
}

//___________________________________________________________________
void Set_UpLineValue(int iBar, double dValue)
{
   if (dValue >= MinPriceLine[iBar]-gridStep && 
       dValue <= MaxPriceLine[iBar]+gridStep) 
   {    
      upLine[iBar] = dValue;
   }
   else 
      upLine[iBar] = EMPTY_VALUE;
   return;
}

//___________________________________________________________________
void Set_DnLineValue(int iBar, double dValue)
{
   if (dValue >= MinPriceLine[iBar]-gridStep && 
       dValue <= MaxPriceLine[iBar]+gridStep) 
   {    
      dnLine[iBar] = dValue;
   }     
   else 
      dnLine[iBar] = EMPTY_VALUE;
   return;
}

//___________________________________________________________________
void Show_SignalArrows(int i, int iTrend)
{
int iArrow;
color dColor;
double dATR, dHighOffset, dLowOffset, dPrice;
double dFactorOffset  = 0.40;
int iHeight = 2;

   string sName = "Signal_" + TimeToStr(Time[i]);
   
   dATR = iATR(Symbol(),Period(),34,i);
   double dHiloOffset = dATR * dFactorOffset;
   
//I use a value based on the current height of the window...?
   double dHeightWindow = WindowPriceMax(0) - WindowPriceMin(0);
   dLowOffset  = dHeightWindow / 100;
   dHighOffset = dLowOffset + 2*dHiloOffset;   

   //---- long signal
   if (iTrend == 1)
   {
      iArrow = 233;   
      dColor = Blue;
      dPrice = Low[i] - dLowOffset;
   }
   else
   //---- short signal
   if (iTrend == -1)
   {
      iArrow = 234;
      dColor = Red;
      dPrice = High[i] + dHighOffset;
   }
   dPrice = NormalizeDouble(dPrice,Digits);

   ObjectCreate(sName,OBJ_ARROW,0,Time[i],dPrice);
      ObjectSet(sName,OBJPROP_COLOR,dColor);
      ObjectSet(sName,OBJPROP_ARROWCODE,iArrow);
   return;
}

//___________________________________________________________________
double CurrentPrice(int priceCode, int i)
{
double dPrice;

   switch (priceCode)
   {
      case PRICE_CLOSE: 
      {
         dPrice = Close[i];
         break;
      }
      case PRICE_OPEN: 
      {
         dPrice = Open[i];
         break;
      }
      case PRICE_MEDIAN: 
      {
         dPrice = (High[i] + Low[i]) / 2.0;
         dPrice = NormalizeDouble(dPrice,Digits);
         break;
      }
      case PRICE_TYPICAL: 
      {
         dPrice = (High[i] + Low[i] + Close[i]) / 3.0;
         dPrice = NormalizeDouble(dPrice,Digits);
         break;
      }
   }
   return(dPrice);
}

//___________________________________________________________________
void Draw_HorizontalLine(double dValue)
{
   dValue = NormalizeDouble(dValue,Digits);
   string sName = "HLine_" + DoubleToStr(dValue,Digits);
   ObjectCreate(sName,OBJ_TREND,iWindow, firstTime,dValue, Time[0],dValue);
      ObjectSet(sName,OBJPROP_COLOR,MainGrid_Color);
      ObjectSet(sName,OBJPROP_STYLE,MainGrid_Style);
      ObjectSet(sName,OBJPROP_WIDTH,MainGrid_Width);
      ObjectSet(sName,OBJPROP_RAY,false);
      ObjectSet(sName,OBJPROP_BACK,false); //drawn in foreground
   return;   
}

//___________________________________________________________________
void Draw_VerticalLine(datetime dTime, double minVal, double maxVal)
{
   string sName = "VLine_" + TimeToStr(dTime);
   ObjectCreate(sName,OBJ_TREND,iWindow, dTime,minVal, dTime,maxVal);
      ObjectSet(sName,OBJPROP_COLOR,MainGrid_Color);
      ObjectSet(sName,OBJPROP_STYLE,MainGrid_Style);
      ObjectSet(sName,OBJPROP_WIDTH,MainGrid_Width);
      ObjectSet(sName,OBJPROP_RAY,false);
      ObjectSet(sName,OBJPROP_BACK,false); //drawn in foreground
   return;   
}

//___________________________________________________________________
void Draw_GannGrid(datetime time1, datetime time2, double dValue1, double dValue2)
{
   string sName = "Gann_" + dValue1;
   double dScale = -gridStep * MathPow(10,Digits);
   ObjectCreate(sName,OBJ_GANNGRID,iWindow, time1,dValue1, time2,dValue2);
      ObjectSet(sName,OBJPROP_COLOR,GannGrid_Color);
      ObjectSet(sName,OBJPROP_STYLE,GannGrid_Style);
      ObjectSet(sName,OBJPROP_WIDTH,GannGrid_Width);
      ObjectSet(sName,OBJPROP_RAY,true);
      ObjectSet(sName,OBJPROP_SCALE,dScale);
      ObjectSet(sName,OBJPROP_BACK,true); //drawn in background
   return;
}

//___________________________________________________________________
void Write_PriceValue(double dValue)
{
   string sTextShift;
   for (int i=1; i<= Text_Shift; i++)
      sTextShift = sTextShift + " ";
   string sValue = DoubleToStr(dValue,Digits);
   string sName = "Price_" + sValue;
   sValue = sTextShift + sValue;
   ObjectCreate(sName,OBJ_TEXT,iWindow, Time[0],dValue);
      ObjectSetText(sName,sValue,fontSize);
   return;
}

//####################################################################
//____________________________________________________________________
void Delete_GannObjects()
{
   Delete_ObjectNames("Gann_");
   Delete_ObjectNames("HLine_");
   Delete_ObjectNames("VLine_");
   Delete_ObjectNames("Price_");
   Delete_ObjectNames("Signal_");
}
//____________________________________________________________________
void Delete_ObjectNames(string sName)
{
   int nObjects = ObjectsTotal();
   for (int i=nObjects; i>=0; i--)
   {
      string sObjectName = ObjectName(i);
      if (StringFind(sObjectName, sName, 0) != -1)
      {
         ObjectDelete(sObjectName);
      }   
   }
}

