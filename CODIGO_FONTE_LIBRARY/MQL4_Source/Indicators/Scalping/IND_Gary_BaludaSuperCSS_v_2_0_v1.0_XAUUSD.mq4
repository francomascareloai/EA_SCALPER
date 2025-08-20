//+------------------------------------------------------------------+
//|                                        CurrencySlopeStrength.mq4 |
//|                   Copyright 2012-16, Deltabron - Paul Geirnaerdt |
//|                                          http://www.deltabron.nl |
//+------------------------------------------------------------------+
//
// Parts based on CCFp.mq4, downloaded from mql4.com
// TMA Calculations © 2012 by ZZNBRM
// adaptions for the latest MT4 builds by milanese and again bug fixes
//some corrections, total adaption to property strict by milanese
// again added CHF as requested by milanese
//23 may,2014 modified for use without CHF milanese
//14 may,2014 modified milanese
//12/04/2014 added alerts by milanese
//09/04/2014 6xx build version by milanese
//09/05/2016 numbers changed by nanningbob SHF for Baluda Super CSS
//09/05/2016 updates to signals by gprince66 SHF
//09/05/2016 arrows and mtf currency table by gprince66 SHF
//09/18/2016 Comabined Baluda's and Gary's work into one project. Colors updated by Nanningbob
#property copyright "Copyright 2012-2016, Deltabron - Paul Geirnaerdt"
#property link      "http://www.deltabron.nl"
//----
#property indicator_separate_window
#property indicator_buffers 8

#define version        "v3.8"
#property strict

#define CURRENCYCOUNT  8


//---- parameters
extern string  gen               = "----General inputs----"; //----
extern bool    autoSymbols       = false;
extern string  symbolsToWeigh    = "AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADJPY,CHFJPY,EURAUD,EURCAD,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,GBPUSD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY"; //symbolsToWeigh: CADCHF,NZDCAD,EURCHF,EURGBP,
extern int     maxBars           = 200;
extern bool    weighOnlySymbolOnChart = true;
extern string  nonPropFont       = "Lucida Console";
extern bool    addSundayToMonday = true;
extern bool    showOnlySymbolOnChart = true;

extern string  ind               = "----Indicator inputs----"; //----
extern bool    autoTimeFrame     = true;
extern string  ind_tf            = "timeFrame M1,M5,M15,M30,H1,H4,D1,W1,MN"; //----
extern string  timeFrame         = "H4"; //timeFrame: CSS & left column 
extern string  extraTimeFrame    = "D1"; //extraTimeFrame: center column
extern string  extraTimeFrame2   = "H1"; //extraTimeFrame2: right column 
extern int     NoOfTimeFrames    = 3;    //NoOfTimeFrames: num of TF to display
extern bool    ignoreFuture      = true;
extern bool    showCrossAlerts   = true;
extern double  differenceThreshold = 0.0; 
extern bool    showLevelCross    = true;
extern double  levelCrossValue   = 2.0; 
extern int     SlopeMAPeriod     = 7; //SlopeMAPeriod: CSSv3.8=21 ~ CSSSuper=7
extern int     SlopeATRPeriod    = 50; //SlopeATRPeriod: CSSv3.8=100 ~ CSSSuper=50
extern bool    PopupAlert        = true; 
extern bool    EmailAlert        = true;
extern bool    PushAlert         = true;

extern string  cur               = "----Currency inputs----"; //----
extern bool    USD               = true;   
extern bool    EUR               = true;   
extern bool    GBP               = true;
extern bool    CHF               = true;
extern bool    JPY               = true;
extern bool    AUD               = true;
extern bool    CAD               = true;
extern bool    NZD               = true;

extern string  colour="----Colo(u)r inputs----"; //----
extern color   Color_USD         = clrRed;
extern color   Color_EUR         = clrDeepSkyBlue;
extern color   Color_GBP         = clrRoyalBlue;
extern color   Color_CHF         = clrPaleTurquoise;
extern color   Color_JPY         = clrGold;
extern color   Color_AUD         = clrDarkOrange;
extern color   Color_CAD         = clrPink;
extern color   Color_NZD         = clrTan;
extern int     line_width_USD    = 3;
extern int     line_style_USD    = 0;
extern int     line_width_EUR    = 3;
extern int     line_style_EUR    = 0;
extern int     line_width_GBP    = 3;
extern int     line_style_GBP    = 0;
extern int     line_width_JPY    = 3;
extern int     line_style_JPY    = 0;
extern int     line_width_AUD    = 3;
extern int     line_style_AUD    = 0;
extern int     line_width_CAD    = 3;
extern int     line_style_CAD    = 0;
extern int     line_width_NZD    = 3;
extern int     line_style_NZD    = 0;
extern int     line_width_CHF    = 3;
extern int     line_style_CHF    = 0;
extern color   colorWeakCross    = clrGold;
extern color   colorNormalCross  = clrGold;
extern color   colorStrongCross  = clrGold;
extern color   colorDifferenceUp = 0x303000;
extern color   colorDifferenceDn = 0x000030;
extern color   colorDifferenceLo = 0x005454;
extern color   colorTimeframe    = clrWhite;
extern color   colorLevelHigh    = clrLimeGreen;
extern color   colorLevelLow     = clrCrimson;

extern string  disp              = "----Display Inputs----"; //----
extern int     displayTextSize   = 11;
extern int     horizontalOffset  = 10;  
extern int     verticalOffset    = 10; 
extern int     tableVertOffset   = 170; //tableVertOffset: 3rd table  
extern int     horizontalShift   = 20; //horizontalShift: columns
extern int     verticalShift     = 15; //verticalShift: rows
//////////////////////////////////////////////////////////////////////////////////////////////////

extern string  gen2              = "----Arrow Display----"; //----
extern bool    showArrows        = true; //showArrows: set showOnlySymbolOnChart to true
extern color   BuyArrowColor     = clrDarkGreen;
extern int     BuyArrowFontSize  = 22;               
extern color   SellArrowColor    = clrMaroon;
extern int     SellArrowFontSize = 22;
////////////////////////////////////////////////////////////////////////////////////////////////////
int      ATRPeriodArrows=20; 
double   ATRMultiplierArrows=1.0;
bool     OnlyDrawArrowsOnNewBar=true;
datetime drawArrowTime=0; 
bool     BuyArrowActive=false, SellArrowActive=false;
int      leftBarPrev=0, rightBarPrev=0;
////////////////////////////////////////////////////////////////////////////////////////////////////

extern string  rede              = "----Read Delay----"; //----
extern bool    EveryTickMode     = true; //EveryTickMode: set to false if viewing full css tables w/3 TFs
extern bool    ReadEveryNewBar   = true; //ReadEveryNewBar: reads every new bar even if ReadEveryXSeconds hasn't expired
extern int     ReadEveryXSeconds = 10; //ReadEveryXSeconds: set EveryTickMode to false
/////////////////////////////////////////////////////////////////////////////////////////////////////
datetime NextReadTime=0, lastBarTime=0;
/////////////////////////////////////////////////////////////////////////////////////////////////////

//global indicator variables
string   indicatorName="CurrencySlopeStrength";
string   shortName;
int      userTimeFrame;
int      userExtraTimeFrame;
int      userExtraTimeFrame2;
string   almostUniqueIndex;
bool     sundayCandlesDetected;
string   objectName;
int      windex;
int      size;
int      digits=0;
string   ObjectSuffix="_SCSS";
string   ObjectSuffix2="_objdel";
bool     IsInit;

//indicator buffers
double   arrUSD[];
double   arrEUR[];
double   arrGBP[];
double   arrJPY[];
double   arrAUD[];
double   arrCAD[];
double   arrNZD[];
double   arrCHF[];

//symbol & currency variables
int      symbolCount;
string   symbolNames[];
string   currencyNames[CURRENCYCOUNT]={ "USD","EUR","GBP","JPY","AUD","CAD","NZD","CHF" };
double   currencyValues[CURRENCYCOUNT];      // Currency slope strength
double   currencyValuesPrior[CURRENCYCOUNT]; // Currency slope strength prior bar
double   currencyOccurrences[CURRENCYCOUNT]; // Holds the number of occurrences of each currency in symbols
int      line_width[CURRENCYCOUNT];
int      line_style[CURRENCYCOUNT];
color    currencyColors[CURRENCYCOUNT];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   int i=0;
   
   initSymbols();

   string now=string(TimeCurrent());
   almostUniqueIndex=StringSubstrOld(now,StringLen(now)-3)+IntegerToString(WindowsTotal());

//---- indicators
   shortName=indicatorName+" - "+version+" - id"+IntegerToString(WindowsTotal())+StringSubstrOld(now,StringLen(now)-1);
   IndicatorShortName(shortName);
   windex=WindowFind(shortName);
//----
   currencyColors[0]=Color_USD;
   line_width[0]=line_width_USD;
   line_style[0]=line_style_USD;
   SetIndexBuffer(0,arrUSD);
   SetIndexLabel(0,"USD");

   currencyColors[1]=Color_EUR;
   line_width[1]=line_width_EUR;
   line_style[1]=line_style_EUR;
   SetIndexBuffer(1,arrEUR);
   SetIndexLabel(1,"EUR");

   currencyColors[2]=Color_GBP;
   line_width[2]=line_width_GBP;
   line_style[2]=line_style_GBP;
   SetIndexBuffer(2,arrGBP);
   SetIndexLabel(2,"GBP");

   currencyColors[3]=Color_JPY;
   line_width[3]=line_width_JPY;
   line_style[3]=line_style_JPY;
   SetIndexBuffer(3,arrJPY);
   SetIndexLabel(3,"JPY");

   currencyColors[4]=Color_AUD;
   line_width[4]=line_width_AUD;
   line_style[4]=line_style_AUD;
   SetIndexBuffer(4,arrAUD);
   SetIndexLabel(4,"AUD");

   currencyColors[5]=Color_CAD;
   line_width[5]=line_width_CAD;
   line_style[5]=line_style_CAD;
   SetIndexBuffer(5,arrCAD);
   SetIndexLabel(5,"CAD");

   currencyColors[6]=Color_NZD;
   line_width[6]=line_width_NZD;
   line_style[6]=line_style_NZD;
   SetIndexBuffer(6,arrNZD);
   SetIndexLabel(6,"NZD");
   currencyColors[7]=Color_CHF;
   line_width[7]=line_width_CHF;
   line_style[7]=line_style_CHF;
   SetIndexBuffer(7,arrCHF);
   SetIndexLabel(7,"CHF");
   
   for(i=0; i<CURRENCYCOUNT; i++)
     {
      SetIndexStyle(i,DRAW_LINE,line_style[i],line_width[i],currencyColors[i]);
     }

   sundayCandlesDetected=false;
   for(i=0; i<8; i++)
     {
      if(TimeDayOfWeek(iTime(NULL,PERIOD_D1,i))==0)
        {
         sundayCandlesDetected=true;
         break;
        }
     }

   if(weighOnlySymbolOnChart) showOnlySymbolOnChart=true;
   
   if(NoOfTimeFrames > 3) NoOfTimeFrames = 3;
   if(NoOfTimeFrames < 1) NoOfTimeFrames = 1;
   
   if(showArrows && !showOnlySymbolOnChart) showArrows=false;
   
   //reset globals
   NextReadTime=0;
   lastBarTime=0;
   drawArrowTime=0;
   BuyArrowActive=false; 
   SellArrowActive=false;
   IsInit=true;
   leftBarPrev=0;
   rightBarPrev=0;

   return( INIT_SUCCEEDED );
  }
  
//+------------------------------------------------------------------+
//| Initialize Symbols Array                                         |
//+------------------------------------------------------------------+
void initSymbols()
  {
   int i;

// Get extra characters on this crimmal's symbol names
   string symbolExtraChars=StringSubstrOld(Symbol(),6,4);

   if(weighOnlySymbolOnChart)
     {
      symbolsToWeigh=StringSubstrOld(Symbol(),0,6);
     }

// Trim user input
   symbolsToWeigh = StringTrimLeft(symbolsToWeigh);
   symbolsToWeigh = StringTrimRight(symbolsToWeigh);

// Add extra comma
   if(StringSubstrOld(symbolsToWeigh,StringLen(symbolsToWeigh)-1)!=",")
     {
      symbolsToWeigh=StringConcatenate(symbolsToWeigh,",");
     }

// Build symbolNames array as the user likes it
   if(autoSymbols)
     {
      createSymbolNamesArray();
      
      if(weighOnlySymbolOnChart)
        {
         ArrayResize(symbolNames,1);
         symbolNames[0]=Symbol();
        }
     }
   else
     {
      // Split user input
      i=StringFind(symbolsToWeigh,",");
      while(i!=-1)
        {
         size=ArraySize(symbolNames);
         string newSymbol=StringConcatenate(StringSubstrOld(symbolsToWeigh,0,i),symbolExtraChars);

         ArrayResize(symbolNames,size+1);
         // Set array
         symbolNames[size]=newSymbol;

         // Trim symbols
         symbolsToWeigh=StringSubstrOld(symbolsToWeigh,i+1);
         i=StringFind(symbolsToWeigh,",");
        }
     }

// Kill unwanted symbols from array
   if(showOnlySymbolOnChart)
     {
      symbolCount=ArraySize(symbolNames);
      string tempNames[];
      for(i=0; i<symbolCount; i++)
        {
         for(int j=0; j<CURRENCYCOUNT; j++)
           {
            if(StringFind(Symbol(),currencyNames[j])==-1)
              {
               continue;
              }
            if(StringFind(symbolNames[i],currencyNames[j])!=-1)
              {
               size=ArraySize(tempNames);
               ArrayResize(tempNames,size+1);
               tempNames[size]=symbolNames[i];
               break;
              }
           }
        }
      for(i=0; i<ArraySize(tempNames); i++)
        {
         ArrayResize(symbolNames,i+1);
         symbolNames[i]=tempNames[i];
        }
     }
   else
     {
      //kill unwanted symbols from market watch
      //if market watch has symbols not in the list of 28... remove them from symbolNames[]
      string symbols = "AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,GBPUSD,NZDCAD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY";
      string tempSymbols[];
      int    count=0;
        
      //Check symbol names
      for(i=0;i<ArraySize(symbolNames);i++)  
        {
         if(StringFind(symbols, StringSubstrOld(symbolNames[i],0,6)) != -1)
           {
            ArrayResize(tempSymbols,count+1);
            tempSymbols[count] = symbolNames[i];
            count++; 
           }
        }
                
      ArrayResize(symbolNames, ArraySize(tempSymbols));
      ArrayCopy(symbolNames,tempSymbols,0,0,WHOLE_ARRAY);
      
     }

   symbolCount=ArraySize(symbolNames);
// Print("symbolCount: ", symbolCount);

   for(i=0; i<symbolCount; i++)
     {
      // Increase currency occurrence
      int currencyIndex=getCurrencyIndex(StringSubstrOld(symbolNames[i],0,3));
      currencyOccurrences[currencyIndex]++;
      currencyIndex=getCurrencyIndex(StringSubstrOld(symbolNames[i],3,3));
      currencyOccurrences[currencyIndex]++;
     }
     
   /////////////////////////////////////////////////////////////////
   
 
   if(!autoTimeFrame)
     {
      userTimeFrame = StrToTF(timeFrame); //css & left column
      userExtraTimeFrame = StrToTF(extraTimeFrame); //center column
      userExtraTimeFrame2 = StrToTF(extraTimeFrame2); //right column
     }
   else
     {
      //Auto Time Frame
      
      //userTimeFrame = css & left column = chart tf
      //userExtraTimeFrame = center column = higher tf
      //userExtraTimeFrame2 = right column = lower tf
      
      //----
      
      //Chart TF ~ css & left column
      userTimeFrame=Period(); 
      
      //Higher TF ~ center column
      if( userTimeFrame == PERIOD_M1 ) userExtraTimeFrame = PERIOD_M5; 
      else if( userTimeFrame == PERIOD_M5 )  userExtraTimeFrame = PERIOD_M15;
      else if( userTimeFrame == PERIOD_M15 ) userExtraTimeFrame = PERIOD_M30;
      else if( userTimeFrame == PERIOD_M30 ) userExtraTimeFrame = PERIOD_H1;
      else if( userTimeFrame == PERIOD_H1 )  userExtraTimeFrame = PERIOD_H4;
      else if( userTimeFrame == PERIOD_H4 )  userExtraTimeFrame = PERIOD_D1;
      else if( userTimeFrame == PERIOD_D1 )  userExtraTimeFrame = PERIOD_W1;
      else if( userTimeFrame == PERIOD_W1 )  userExtraTimeFrame = PERIOD_MN1;
      else if( userTimeFrame == PERIOD_MN1 )  userExtraTimeFrame = PERIOD_MN1;
      
      //Lower TF ~ right column
      if( userTimeFrame == PERIOD_M1 ) userExtraTimeFrame2 = PERIOD_M1; 
      else if( userTimeFrame == PERIOD_M5 )  userExtraTimeFrame2 = PERIOD_M1;
      else if( userTimeFrame == PERIOD_M15 ) userExtraTimeFrame2 = PERIOD_M5;
      else if( userTimeFrame == PERIOD_M30 ) userExtraTimeFrame2 = PERIOD_M15;
      else if( userTimeFrame == PERIOD_H1 )  userExtraTimeFrame2 = PERIOD_M30;
      else if( userTimeFrame == PERIOD_H4 )  userExtraTimeFrame2 = PERIOD_H1;
      else if( userTimeFrame == PERIOD_D1 )  userExtraTimeFrame2 = PERIOD_H4;
      else if( userTimeFrame == PERIOD_W1 )  userExtraTimeFrame2 = PERIOD_D1;
      else if( userTimeFrame == PERIOD_MN1 )  userExtraTimeFrame2 = PERIOD_W1;      
     }
  }
  
//+------------------------------------------------------------------+
//| getCurrencyIndex(string currency)                                |
//+------------------------------------------------------------------+
int getCurrencyIndex(string currency)
  {
   for(int i=0; i<CURRENCYCOUNT; i++)
     {
      if(currencyNames[i]==currency)
        {
         return(i);
        }
     }
   return (-1);
  }
  
//+------------------------------------------------------------------+
//| createSymbolNamesArray()                                         |
//+------------------------------------------------------------------+
void createSymbolNamesArray()
  {
   int hFileName=FileOpenHistory("symbols.raw",FILE_BIN|FILE_READ);
   int recordCount=int(FileSize(hFileName)/1936);
   int counter=0;
   for(int i=0; i<recordCount; i++)
     {
      string tempSymbol=StringTrimLeft(StringTrimRight(FileReadString(hFileName,12)));
      if(MarketInfo(tempSymbol,MODE_BID)>0 && MarketInfo(tempSymbol,MODE_TRADEALLOWED))
        {
         ArrayResize(symbolNames,counter+1);
         symbolNames[counter]=tempSymbol;
         counter++;
        }
      FileSeek(hFileName,1924,SEEK_CUR);
     }
   FileClose(hFileName);

  }
  
//+------------------------------------------------------------------+
//| GetTimeframeString( int tf )                                     |
//+------------------------------------------------------------------+
string GetTimeframeString(int tf)
  {
   string result;
   switch(tf)
     {
      case PERIOD_M1:   result = "M1";    break;
      case PERIOD_M5:   result = "M5";    break;
      case PERIOD_M15:  result = "M15";   break;
      case PERIOD_M30:  result = "M30";   break;
      case PERIOD_H1:   result = "H1";    break;
      case PERIOD_H4:   result = "H4";    break;
      case PERIOD_D1:   result = "D1";    break;
      case PERIOD_W1:   result = "W1";    break;
      case PERIOD_MN1:  result = "MN1";   break;
      default: result="SRITSOD";
     }
   return ( result );
  }
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //Remove objects that belong to this indicator
   //Add suffix "_xxx" to object name
   
   for(int i=ObjectsTotal()-1;i>=0;i--)
   {
      if(StringFind(ObjectName(i),ObjectSuffix,0)>0)
      {
         ObjectDelete(ObjectName(i));
      }
   }
   
}//OnDeinit(const int reason)

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
   //Variables
   int i=0, j=0, leftBar=0, rightBar=0;
   
   //Read Delay
   if(IsItNewReadTime())
   {    
      //loop only what's visible on chart 
      leftBar = WindowFirstVisibleBar();
      rightBar = leftBar - WindowBarsPerChart();
      if(rightBar < 0) rightBar = 0;
      
      //use for visual backtesting only
      if(maxBars >= 300 && maxBars <= 3000 && showOnlySymbolOnChart)
      {
         //turn off WindowFirstVisibleBar()         
         leftBar=MathMin(maxBars,Bars-10);
         rightBar = 0;
         
         //prevent mt4 crash
         EveryTickMode = false;
         ReadEveryXSeconds = 3600;
      }
            
      
      //Main loop
      for(i=leftBar; i>=rightBar; i--)
      { 
         if ( i > rates_total - 50 ) continue;
         
         ArrayInitialize(currencyValues,0.0);
          
         double diff=0.0;
         int    bar=iBarShift(NULL,userTimeFrame,time[i]);
         
         //Calc Slope into currencyValues[]  
         calcCSS(userTimeFrame,bar);
   
         if(( showOnlySymbolOnChart && (StringFind(Symbol(),"USD")!=-1)) || (!showOnlySymbolOnChart && USD))
           {
            arrUSD[i]=currencyValues[0];
            if(diff==0) diff+=currencyValues[0]; else diff-=currencyValues[0];
           }
         if(( showOnlySymbolOnChart && (StringFind(Symbol(),"EUR")!=-1)) || (!showOnlySymbolOnChart && EUR))
           {
            arrEUR[i]=currencyValues[1];
            if(diff==0) diff+=currencyValues[1]; else diff-=currencyValues[1];
           }
         if(( showOnlySymbolOnChart && (StringFind(Symbol(),"GBP")!=-1)) || (!showOnlySymbolOnChart && GBP))
           {
            arrGBP[i]=currencyValues[2];
            if(diff==0) diff+=currencyValues[2]; else diff-=currencyValues[2];
           }
   
         if(( showOnlySymbolOnChart && (StringFind(Symbol(),"JPY")!=-1)) || (!showOnlySymbolOnChart && JPY))
           {
            arrJPY[i]=currencyValues[3];
            if(diff==0) diff+=currencyValues[3]; else diff-=currencyValues[3];
           }
         if(( showOnlySymbolOnChart && (StringFind(Symbol(),"AUD")!=-1)) || (!showOnlySymbolOnChart && AUD))
           {
            arrAUD[i]=currencyValues[4];
            if(diff==0) diff+=currencyValues[4]; else diff-=currencyValues[4];
           }
         if(( showOnlySymbolOnChart && (StringFind(Symbol(),"CAD")!=-1)) || (!showOnlySymbolOnChart && CAD))
           {
            arrCAD[i]=currencyValues[5];
            if(diff==0) diff+=currencyValues[5]; else diff-=currencyValues[5];
           }
         if(( showOnlySymbolOnChart && (StringFind(Symbol(),"NZD")!=-1)) || (!showOnlySymbolOnChart && NZD))
           {
            arrNZD[i]=currencyValues[6];
            if(diff==0) diff+=currencyValues[6]; else diff-=currencyValues[6];
           }
         if(( showOnlySymbolOnChart && (StringFind(Symbol(),"CHF")!=-1)) || (!showOnlySymbolOnChart && CHF))
           {
            arrCHF[i]=currencyValues[7];
            if(diff==0) diff+=currencyValues[7]; else diff-=currencyValues[7];
           }   
         if(i==rightBar+1)
           {
            ArrayCopy(currencyValuesPrior,currencyValues);
           }           
         if(i==rightBar)
           {
            //Show ordered tables            
            if(NoOfTimeFrames == 1)
              {
               ShowCurrencyTable(userTimeFrame, 1, rightBar); //css & left column
              }
            else if(NoOfTimeFrames == 2)
              {
               ShowCurrencyTable(userTimeFrame, 1, rightBar); 
               ShowCurrencyTable(userExtraTimeFrame, 2, rightBar); //center column
              }
            else if(NoOfTimeFrames == 3)
              {
               ShowCurrencyTable(userTimeFrame, 1, rightBar); 
               ShowCurrencyTable(userExtraTimeFrame, 2, rightBar); 
               ShowCurrencyTable(userExtraTimeFrame2, 3, rightBar); //right column
              }
                        
           }//if(i==rightBar)
   
         //Only two currencies, show background
         if(showOnlySymbolOnChart)
         {
            //Create background object
            objectName=almostUniqueIndex+"_diff_"+TimeToString(Time[i])+ObjectSuffix+ObjectSuffix2;
            if(ObjectFind(objectName)==-1)
            {
               if(ObjectCreate(objectName,OBJ_VLINE,windex,Time[i],0))
               {
                  ObjectSet(objectName,OBJPROP_BACK,true);
                  ObjectSet(objectName,OBJPROP_HIDDEN,true);
                  ObjectSet(objectName,OBJPROP_WIDTH,8);
               }
            } 
            
            //avoid trivial crosses 
            bool drawArrows = false;              
            if(OnlyDrawArrowsOnNewBar)
               if(Time[0]>drawArrowTime)
                  drawArrows=true;
            else
               drawArrows=true;
               
            //delete arrows, bkgd and css lines if leftBar changes or viewable bars change
            if(showArrows && !IsInit && i==leftBar)
            {
               if(leftBar != leftBarPrev || leftBar-rightBar != leftBarPrev-rightBarPrev)
               {
                  //Remove objects
                  for(j=ObjectsTotal()-1;j>=0;j--)
                  {
                     if(StringFind(ObjectName(j),ObjectSuffix2,0)>0)
                     {
                        ObjectDelete(ObjectName(j));
                     }
                  }
                  
                  //css buffers
                  if(StringFind(Symbol(),"AUD")!=-1)
                  {
                     ArrayInitialize(arrAUD,EMPTY_VALUE);
                     arrAUD[0]=currencyValues[4];
                  }
                  if(StringFind(Symbol(),"CAD")!=-1)
                  {
                     ArrayInitialize(arrCAD,EMPTY_VALUE);
                     arrCAD[0]=currencyValues[5];
                  }
                  if(StringFind(Symbol(),"CHF")!=-1)
                  {
                     ArrayInitialize(arrCHF,EMPTY_VALUE);
                     arrCHF[0]=currencyValues[7];
                  }
                  if(StringFind(Symbol(),"EUR")!=-1)
                  {
                     ArrayInitialize(arrEUR,EMPTY_VALUE);
                     arrEUR[0]=currencyValues[1];
                  }
                  if(StringFind(Symbol(),"GBP")!=-1)
                  {
                     ArrayInitialize(arrGBP,EMPTY_VALUE);
                     arrGBP[0]=currencyValues[2];
                  }
                  if(StringFind(Symbol(),"JPY")!=-1)
                  {
                     ArrayInitialize(arrJPY,EMPTY_VALUE);
                     arrJPY[0]=currencyValues[3];
                  }
                  if(StringFind(Symbol(),"NZD")!=-1)
                  {
                     ArrayInitialize(arrNZD,EMPTY_VALUE);
                     arrNZD[0]=currencyValues[6];
                  }
                  if(StringFind(Symbol(),"USD")!=-1)
                  {
                     ArrayInitialize(arrUSD,EMPTY_VALUE);
                     arrUSD[0]=currencyValues[0];  
                  }              
                  
               }//if(leftBar != leftBarPrev || leftBar-rightBar != leftBarPrev-rightBarPrev)
               
            }//if(showArrows && !IsInit && i==leftBar)
            
            //Draw background color & arrows
            if(MathAbs(diff)>differenceThreshold)
            {
               //arrow spacing
               double ATR = iATR(Symbol(),Period(),ATRPeriodArrows,i);
               double ArrowHigh = iHigh(Symbol(),Period(),i) + ATR*ATRMultiplierArrows;
               double ArrowLow = iLow(Symbol(),Period(),i) - ATR*ATRMultiplierArrows;
               
               //check diff sign
               double cssLong=currencyValues[getCurrencyIndex(StringSubstrOld(Symbol(),0,3))];
               double cssShort=currencyValues[getCurrencyIndex(StringSubstrOld(Symbol(),3,3))];
               
               if(cssLong>cssShort)
               {
                  ObjectSet(objectName,OBJPROP_COLOR,colorDifferenceUp);
                  
                  if(showArrows && drawArrows && !BuyArrowActive)
                  {
                     objectName = "Buy Arrow "+IntegerToString((int)time[i])+ObjectSuffix+ObjectSuffix2;
                     if(ObjectFind(objectName)==-1)
                     {
                        TextCreate(objectName, time[i], ArrowLow, CharToString(225), BuyArrowColor, ANCHOR_LOWER, "wingdings", BuyArrowFontSize);
                     }
                     BuyArrowActive=true;
                     SellArrowActive=false;
                  }
               }
               else
               {
                  ObjectSet(objectName,OBJPROP_COLOR,colorDifferenceDn);
                  
                  if(showArrows && drawArrows && !SellArrowActive)
                  {
                     objectName = "Sell Arrow "+IntegerToString((int)time[i])+ObjectSuffix+ObjectSuffix2;
                     if(ObjectFind(objectName)==-1)
                     {
                        TextCreate(objectName, time[i], ArrowHigh, CharToString(226), SellArrowColor, ANCHOR_UPPER, "wingdings", SellArrowFontSize);
                     }                     
                     BuyArrowActive=false;
                     SellArrowActive=true;
                  }
               }
            }
            else
            {
               //Below threshold
               ObjectSet(objectName,OBJPROP_COLOR,colorDifferenceLo);
               
               if(showArrows && drawArrows)
               {
                  BuyArrowActive=false;
                  SellArrowActive=false;
               }
            }
            
            drawArrowTime=Time[0];
              
         }//if(showOnlySymbolOnChart)
           
      }//for(i=leftBar; i>=rightBar; i--)
   
      //Draw 0.2 & -0.2 green/red lines
      if(showLevelCross)
        {
         objectName=almostUniqueIndex+"_high"+ObjectSuffix;
         ObjectDelete(objectName);
         if(ObjectFind(objectName)==-1)
           {
            if(ObjectCreate(objectName,OBJ_TREND,windex,Time[leftBar],levelCrossValue,Time[rightBar],levelCrossValue))
              {
               ObjectSet(objectName,OBJPROP_BACK,true);
               ObjectSet(objectName,OBJPROP_WIDTH,2);
               ObjectSet(objectName,OBJPROP_COLOR,colorLevelHigh);
               ObjectSet(objectName,OBJPROP_RAY,false);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
              }
           }
         objectName=almostUniqueIndex+"_low"+ObjectSuffix;
         ObjectDelete(objectName);
         if(ObjectFind(objectName)==-1)
           {
            if(ObjectCreate(objectName,OBJ_TREND,windex,Time[leftBar],-levelCrossValue,Time[rightBar],-levelCrossValue))
              {
               ObjectSet(objectName,OBJPROP_BACK,true);
               ObjectSet(objectName,OBJPROP_WIDTH,2);
               ObjectSet(objectName,OBJPROP_COLOR,colorLevelLow);
               ObjectSet(objectName,OBJPROP_RAY,false);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
              }
           }
        }
                
   }//if(IsItNewReadTime())
   
   //no alerts on initialization
   IsInit=false;
   
   //delete arrows if new leftBar
   if(showArrows) 
   {
      leftBarPrev=leftBar;
      rightBarPrev=rightBar;
   }
   
//Alert(leftBarPrev,"  ",leftBar);

//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
   
}//OnCalculate()

//+------------------------------------------------------------------+
//| getSlope()                                                       |
//+------------------------------------------------------------------+
double getSlope(string symbol,int tf,int shift)
  {
   double dblTma,dblPrev;
   int shiftWithoutSunday=shift;
   if(addSundayToMonday && sundayCandlesDetected && tf==PERIOD_D1)
     {
      if(TimeDayOfWeek(iTime(symbol,PERIOD_D1,shift))==0) shiftWithoutSunday++;
     }
   double atr=iATR(symbol,tf,SlopeATRPeriod,shiftWithoutSunday+10)/10;
   double gadblSlope=0.0;
   if(atr!=0)
     {
      if(ignoreFuture)
        {
         // int barSymbol = iBarShift( symbol, tf, iTime( Symbol(), tf, shiftWithoutSunday ), true );
         dblTma=iMA(symbol,tf,SlopeMAPeriod,0,MODE_LWMA,PRICE_CLOSE,shiftWithoutSunday);
         dblPrev=(iMA(symbol,tf,SlopeMAPeriod,0,MODE_LWMA,PRICE_CLOSE,shiftWithoutSunday+1)*231+iClose(symbol,tf,shiftWithoutSunday)*20)/251;
        }
      else
        {
         dblTma=calcTma(symbol,tf,shiftWithoutSunday);
         dblPrev=calcTma(symbol,tf,shiftWithoutSunday+1);
        }
      gadblSlope=(dblTma-dblPrev)/atr;
     }

   return ( gadblSlope );

  }
  
//+------------------------------------------------------------------+
//| calcTma()                                                        |
//+------------------------------------------------------------------+
double calcTma(string symbol,int tf,int shift)
  {
   double dblSum  = iClose( symbol, tf, shift ) * 21;
   double dblSumw = 21;
   int jnx,knx;

   for(jnx=1,knx=20; jnx<=20; jnx++,knx--)
     {
      dblSum  += iClose(symbol, tf, shift + jnx) * knx;
      dblSumw += knx;

      if(jnx<=shift)
        {
         dblSum  += iClose(symbol, tf, shift - jnx) * knx;
         dblSumw += knx;
        }
     }

   return ( dblSum / dblSumw );
  }
  
//+------------------------------------------------------------------+
//| calcCSS(int tf, int shift                 |
//+------------------------------------------------------------------+
void calcCSS(int tf,int shift)
  {
   int i;
// Get Slope for all symbols and totalize for all currencies   
   for(i=0; i<symbolCount; i++)
     {
      double slope=getSlope(symbolNames[i],tf,shift);
      currencyValues[getCurrencyIndex(StringSubstrOld(symbolNames[i], 0, 3))] += slope;
      currencyValues[getCurrencyIndex(StringSubstrOld(symbolNames[i], 3, 3))] -= slope;
     }
   for(i=0; i<CURRENCYCOUNT; i++)
     {
      // average
      if(currencyOccurrences[i]>0) currencyValues[i]/=currencyOccurrences[i]; else currencyValues[i]=0;
     }
  }

//+------------------------------------------------------------------+
//| ShowCurrencyTable()                                              |
//+------------------------------------------------------------------+
void ShowCurrencyTable(int tf, int column, int rightBar2)
{
   int    i=0;
   int    tempValue, tempValue_2;
   string showText, showText_2;
   double slope=0, slope_2=0;
   color  showColor; 
   
   //full table
   static datetime tLastAlert[8];
   static datetime tLastAlert_1[8];
   static datetime tLastAlert_2[8];
   static datetime tLastAlert_3[8];
   static datetime tLastAlert_4[8];
   
   //showOnlySymbolOnChart
   static datetime tLastAlert_3a, tLastAlert_3b;
   static datetime tLastAlert_3c, tLastAlert_3d;
   static datetime tLastAlert_3e, tLastAlert_3f;
   static datetime tLastAlert_3g, tLastAlert_3h; 
   static datetime tLastAlert_3i, tLastAlert_3j;
   static datetime tLastAlert_3k, tLastAlert_3l;
   
   //no alerts on initialization or visual backtests
   bool OkToSendAlerts = (!IsInit && rightBar2 == 0);  
   
   //CSS temp arrays   
   double Currency_Values[CURRENCYCOUNT][3]; //first time frame
   double tempCurrencyValues[CURRENCYCOUNT][3]; //second time frame
   double tempCurrencyValues2[CURRENCYCOUNT][3]; //third time frame
   ArrayInitialize(Currency_Values,0.0);
   ArrayInitialize(tempCurrencyValues,0.0);
   ArrayInitialize(tempCurrencyValues2,0.0);
   
   //First time frame  
   if(column == 1)
   {
      for(i=0; i<CURRENCYCOUNT; i++)
      {
         Currency_Values[i][0] = currencyValues[i];
         Currency_Values[i][1] = NormalizeDouble(currencyValuesPrior[i], 2);
         Currency_Values[i][2] = i;
      }
      
   }//if(column == 1)
   
   //Second time frame
   if(column == 2)
   {
      for(i=0; i<symbolCount; i++)
      {
         slope=getSlope(symbolNames[i],tf,rightBar2);
         slope_2=getSlope(symbolNames[i],tf,rightBar2+1);
         
         tempCurrencyValues[getCurrencyIndex(StringSubstrOld(symbolNames[i], 0, 3))][0] += slope;
         tempCurrencyValues[getCurrencyIndex(StringSubstrOld(symbolNames[i], 0, 3))][1] += slope_2;
         tempCurrencyValues[getCurrencyIndex(StringSubstrOld(symbolNames[i], 3, 3))][0] -= slope;
         tempCurrencyValues[getCurrencyIndex(StringSubstrOld(symbolNames[i], 3, 3))][1] -= slope_2;
      }
      for(i=0; i<CURRENCYCOUNT; i++)
      {         
         tempCurrencyValues[i][2]=i;
         //average
         if(currencyOccurrences[i]>0) tempCurrencyValues[i][0]/=currencyOccurrences[i]; else tempCurrencyValues[i][0]=0;
         if(currencyOccurrences[i]>0) tempCurrencyValues[i][1]/=currencyOccurrences[i]; else tempCurrencyValues[i][1]=0;
      }
      
   }//if(column == 2)
   
   //Third time frame
   if(column == 3)
   {
      for(i=0; i<symbolCount; i++)
      {
         slope=getSlope(symbolNames[i],userExtraTimeFrame2,rightBar2);
         slope_2=getSlope(symbolNames[i],userExtraTimeFrame2,rightBar2+1);
         
         tempCurrencyValues2[getCurrencyIndex(StringSubstrOld(symbolNames[i], 0, 3))][0] += slope;
         tempCurrencyValues2[getCurrencyIndex(StringSubstrOld(symbolNames[i], 0, 3))][1] += slope_2;
         tempCurrencyValues2[getCurrencyIndex(StringSubstrOld(symbolNames[i], 3, 3))][0] -= slope;
         tempCurrencyValues2[getCurrencyIndex(StringSubstrOld(symbolNames[i], 3, 3))][1] -= slope_2;
      }
      for(i=0; i<CURRENCYCOUNT; i++)
      {
         tempCurrencyValues2[i][2]=i;
         //average
         if(currencyOccurrences[i]>0) tempCurrencyValues2[i][0]/=currencyOccurrences[i]; else tempCurrencyValues2[i][0]=0;
         if(currencyOccurrences[i]>0) tempCurrencyValues2[i][1]/=currencyOccurrences[i]; else tempCurrencyValues2[i][1]=0;
      }
   
   }//if(column == 3)
   
   ///////////////////////////////////////////////////////////////////////////////////
   
   
   if(showOnlySymbolOnChart)
   {
      //first time frame
      if(column == 1)
      {
         objectName=almostUniqueIndex+"_css_obj_column1_tf"+ObjectSuffix;
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
            {
               ObjectSet(objectName,OBJPROP_CORNER,1);
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+10+horizontalShift*6);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
         ObjectSetText(objectName,TFToString(userTimeFrame),displayTextSize,nonPropFont,colorTimeframe);
      
      }//if(column == 1)
      
      //second time frame
      if(column ==2)
      {
         objectName=almostUniqueIndex+"_css_obj_column2_tf"+ObjectSuffix;
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
            {
               ObjectSet(objectName,OBJPROP_CORNER,1);
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+10+horizontalShift*3);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
         ObjectSetText(objectName,TFToString(userExtraTimeFrame),displayTextSize,nonPropFont,colorTimeframe);
      
      }//if(column == 2)      
         
      //third time frame
      if(column == 3)
      {
         objectName=almostUniqueIndex+"_css_obj_column3_tf"+ObjectSuffix;
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
            {
               ObjectSet(objectName,OBJPROP_CORNER,1);
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+10);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
         ObjectSetText(objectName,TFToString(userExtraTimeFrame2),displayTextSize,nonPropFont,colorTimeframe);
      
      }//if(column == 3)  
      
      ///////////////////////////////////////////////////////////////////////////
      

      //CSS values
      double Curr1Val=0, Curr1ValPrior=0, Curr2Val=0, Curr2ValPrior=0;
      string Curr1, Curr2;
      
      int index=getCurrencyIndex(StringSubstrOld(Symbol(),0,3));
      int index2=getCurrencyIndex(StringSubstrOld(Symbol(),3,3));
      
      Curr1=currencyNames[index];
      Curr1Val=currencyValues[index];
      Curr1ValPrior=currencyValuesPrior[index];
      
      Curr2=currencyNames[index2];
      Curr2Val=currencyValues[index2];
      Curr2ValPrior=currencyValuesPrior[index2];
      
      digits = GetDigits(Curr1+Curr2);
      
      //----
      
      //left column
      if(column == 1)
      {
         objectName=almostUniqueIndex+"_css_obj_column1_value1"+ObjectSuffix;
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
            {
               ObjectSet(objectName,OBJPROP_CORNER,1);
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+horizontalShift*6);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset+verticalShift*1.5);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
         showText=RightAlign(DoubleToStr(Currency_Values[index][0],2),5);
         ObjectSetText(objectName,showText,displayTextSize,nonPropFont,currencyColors[index]);
         
         //////////////////////////////////////////////////////////////////////////////////////////////
         
         
         //display second css row
         if(showOnlySymbolOnChart && !weighOnlySymbolOnChart)
         {
            objectName=almostUniqueIndex+"_css_obj_column1_value2"+ObjectSuffix;
            if(ObjectFind(objectName)==-1)
            {
               if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
               {
                  ObjectSet(objectName,OBJPROP_CORNER,1);
                  ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+horizontalShift*6);
                  ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset+verticalShift*3);
                  ObjectSet(objectName,OBJPROP_HIDDEN,true);
               }
            }
            showText=RightAlign(DoubleToStr(Currency_Values[index2][0],2),5);
            ObjectSetText(objectName,showText,displayTextSize,nonPropFont,currencyColors[index2]);
         }
         
      }//if(column == 1)

      //center column
      if(column == 2)
      {
         objectName=almostUniqueIndex+"_css_obj_column2_value1"+ObjectSuffix;
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
            {
               ObjectSet(objectName,OBJPROP_CORNER,1);
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+horizontalShift*3);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset+verticalShift*1.5);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
         showText=RightAlign(DoubleToStr(tempCurrencyValues[index][0],2),5);
         ObjectSetText(objectName,showText,displayTextSize,nonPropFont,currencyColors[index]);
         
         //////////////////////////////////////////////////////////////////////////////////////////////
         
         
         //display second css row
         if(showOnlySymbolOnChart && !weighOnlySymbolOnChart)
         {
            objectName=almostUniqueIndex+"_css_obj_column2_value2"+ObjectSuffix;
            if(ObjectFind(objectName)==-1)
            {
               if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
               {
                  ObjectSet(objectName,OBJPROP_CORNER,1);
                  ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+horizontalShift*3);
                  ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset+verticalShift*3);
                  ObjectSet(objectName,OBJPROP_HIDDEN,true);
               }
            }
            showText=RightAlign(DoubleToStr(tempCurrencyValues[index2][0],2),5);
            ObjectSetText(objectName,showText,displayTextSize,nonPropFont,currencyColors[index2]);
         }
         
      }//if(column == 2)
      
      //right column
      if(column == 3)
      {
         objectName=almostUniqueIndex+"_css_obj_column3_value1"+ObjectSuffix;
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
            {
               ObjectSet(objectName,OBJPROP_CORNER,1);
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset+verticalShift*1.5);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
         showText=RightAlign(DoubleToStr(tempCurrencyValues2[index][0],2),5);
         ObjectSetText(objectName,showText,displayTextSize,nonPropFont,currencyColors[index]);
         
         //////////////////////////////////////////////////////////////////////////////////////////////
         
         
         //display second css row
         if(showOnlySymbolOnChart && !weighOnlySymbolOnChart)
         {
            objectName=almostUniqueIndex+"_css_obj_column3_value2"+ObjectSuffix;
            if(ObjectFind(objectName)==-1)
            {
               if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
               {
                  ObjectSet(objectName,OBJPROP_CORNER,1);
                  ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset);
                  ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset+verticalShift*3);
                  ObjectSet(objectName,OBJPROP_HIDDEN,true);
               }
            }
            showText=RightAlign(DoubleToStr(tempCurrencyValues2[index2][0],2),5);
            ObjectSetText(objectName,showText,displayTextSize,nonPropFont,currencyColors[index2]);
         }
         
      }//if(column == 3)
      
      //----
         
      //threshold
      objectName=almostUniqueIndex+"_css_obj_diff"+ObjectSuffix;
      if(ObjectFind(objectName)==-1)
      {
         if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
         {
            ObjectSet(objectName,OBJPROP_CORNER,1);
            if(showOnlySymbolOnChart && !weighOnlySymbolOnChart)
            {
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+horizontalShift*0.25);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset+verticalShift*5);
            }
            else
            {
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+horizontalShift*0.25);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset+verticalShift*3.75);
            }
            ObjectSet(objectName,OBJPROP_HIDDEN,true);
         }
      }         
      if(showOnlySymbolOnChart && !weighOnlySymbolOnChart)
      {
         showText=Curr1+"/"+Curr2+" thresh = "+DoubleToStr(differenceThreshold,1);
         ObjectSetText(objectName,showText,8,nonPropFont,clrYellow);
      }
      else
      {
         showText=Curr1+" threshold = "+DoubleToStr(differenceThreshold,1);
         ObjectSetText(objectName,showText,8,nonPropFont,clrYellow);
      }
      
      ////////////////////////////////////////////////////////////////////////// 
 
      
      //PopUp alert Stuff
      
      //if CSS values mirror
      if(weighOnlySymbolOnChart)
      {                   
         //curr1 crosses up curr2 (buy)
         if(Curr1ValPrior < Curr2ValPrior && Curr1Val > Curr2Val)
         {
            if(tLastAlert_3a<Time[0] && OkToSendAlerts)
            {
               fireAlerts(Curr1+Curr2+" did a cross up  "+TFToString(tf)+" @"+DoubleToStr(Bid,digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));
               tLastAlert_3a=Time[0];
            }
         }
           
         //curr1 crosses down curr2 (sell)
         if(Curr1ValPrior > Curr2ValPrior && Curr1Val < Curr2Val)
         {
            if(tLastAlert_3b<Time[0] && OkToSendAlerts)
            {
               fireAlerts(Curr1+Curr2+" did a cross down  "+TFToString(tf)+" @"+DoubleToStr(Bid,digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));
               tLastAlert_3b=Time[0];
            }
         }
           
         //----        
           
         //curr1 crosses up levelCrossValue +20
         if(Curr1ValPrior < levelCrossValue && Curr1Val > levelCrossValue)
         {
            if(tLastAlert_3c<Time[0] && OkToSendAlerts)
            {
               fireAlerts(Curr1+Curr2+" did a cross up "+DoubleToStr(levelCrossValue,2)+"  "+TFToString(tf)+" @"+DoubleToStr(Bid,digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));
               tLastAlert_3c=Time[0];
            }        
         }
           
         //curr1 crosses down levelCrossValue -20
         if(Curr1ValPrior > -levelCrossValue && Curr1Val < -levelCrossValue)
         {
            if(tLastAlert_3d<Time[0] && OkToSendAlerts)
            {
               fireAlerts(Curr1+Curr2+" did a cross down "+DoubleToStr(-levelCrossValue,2)+"  "+TFToString(tf)+" @"+DoubleToStr(Bid,digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));
               tLastAlert_3d=Time[0];
            } 
         }
      }//if(weighOnlySymbolOnChart)
      else 
      {
         //if !weighOnlySymbolOnChart --> CSS values don't mirror 
         
         //curr1 crosses up levelCrossValue +20
         if(Curr1ValPrior < levelCrossValue && Curr1Val > levelCrossValue)
         {
            if(tLastAlert_3e<Time[0] && OkToSendAlerts)
            {
               fireAlerts(Curr1+" did a cross up "+DoubleToStr(levelCrossValue,2)+"  "+Curr1+Curr2+" "+TFToString(tf)+" @"+DoubleToStr(Bid,digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));
               tLastAlert_3e=Time[0];
            } 
         }
           
         //curr1 crosses down levelCrossValue -20
         if(Curr1ValPrior > -levelCrossValue && Curr1Val < -levelCrossValue)
         {
            if(tLastAlert_3f<Time[0] && OkToSendAlerts)
            {
               fireAlerts(Curr1+" did a cross down "+DoubleToStr(-levelCrossValue,2)+"  "+Curr1+Curr2+" "+TFToString(tf)+" @"+DoubleToStr(Bid,digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));
               tLastAlert_3f=Time[0];
            } 
         }
         
         //curr2 crosses up levelCrossValue +20
         if(Curr2ValPrior < levelCrossValue && Curr2Val > levelCrossValue)
         {
            if(tLastAlert_3g<Time[0] && OkToSendAlerts)
            {
               fireAlerts(Curr2+" did a cross up "+DoubleToStr(levelCrossValue,2)+"  "+Curr1+Curr2+" "+TFToString(tf)+" @"+DoubleToStr(Bid,digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));
               tLastAlert_3g=Time[0];
            } 
         }
           
         //curr2 crosses down levelCrossValue -20
         if(Curr2ValPrior > -levelCrossValue && Curr2Val < -levelCrossValue)
         {
            if(tLastAlert_3h<Time[0] && OkToSendAlerts)
            {
               fireAlerts(Curr2+" did a cross down "+DoubleToStr(-levelCrossValue,2)+"  "+Curr1+Curr2+" "+TFToString(tf)+" @"+DoubleToStr(Bid,digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));
               tLastAlert_3h=Time[0];
            } 
         }
        
         //curr1 crosses up 0.0
         if(Curr1ValPrior < 0.0 && Curr1Val > 0.0)
         {
            if(tLastAlert_3i<Time[0] && OkToSendAlerts)
            {
               fireAlerts(Curr1+" did a cross up "+DoubleToStr(0.0,2)+"  "+Curr1+Curr2+" "+TFToString(tf)+" @"+DoubleToStr(Bid,digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));
               tLastAlert_3i=Time[0];
            }        
         } 
           
         //curr1 crosses down 0.0
         if(Curr1ValPrior > 0.0 && Curr1Val < 0.0)
         {
            if(tLastAlert_3j<Time[0] && OkToSendAlerts)
            {
               fireAlerts(Curr1+" did a cross down "+DoubleToStr(0.0,2)+"  "+Curr1+Curr2+" "+TFToString(tf)+" @"+DoubleToStr(Bid,digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));
               tLastAlert_3j=Time[0];
            }        
         }
           
         //curr2 crosses up 0.0
         if(Curr2ValPrior < 0.0 && Curr2Val > 0.0)
         {
            if(tLastAlert_3k<Time[0] && OkToSendAlerts)
            {
               fireAlerts(Curr2+" did a cross up "+DoubleToStr(0.0,2)+"  "+Curr1+Curr2+" "+TFToString(tf)+" @"+DoubleToStr(Bid,digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));
               tLastAlert_3k=Time[0];
            }        
         } 
           
         //curr2 crosses down 0.0
         if(Curr2ValPrior > 0.0 && Curr2Val < 0.0)
         {
            if(tLastAlert_3l<Time[0] && OkToSendAlerts)
            {
               fireAlerts(Curr2+" did a cross down "+DoubleToStr(0.0,2)+"  "+Curr1+Curr2+" "+TFToString(tf)+" @"+DoubleToStr(Bid,digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));
               tLastAlert_3l=Time[0];
            }        
         }
           
      }//else ~ if(weighOnlySymbolOnChart)
        
   }//if(showOnlySymbolOnChart)
   else
   {
      //Show full table
         
      //first column
      if(column == 1)
      {
         //TF Label
         objectName=almostUniqueIndex+"_css_obj_table1_column1_tf"+ObjectSuffix;
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
            {
               ObjectSet(objectName,OBJPROP_CORNER,1);
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+10+horizontalShift*8.75);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
         showText="TF ";
         ObjectSetText(objectName,showText,displayTextSize,nonPropFont,colorTimeframe);

         //CSS Value
         objectName=almostUniqueIndex+"_css_obj_table1_column2_tf"+ObjectSuffix;
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
            {
               ObjectSet(objectName,OBJPROP_CORNER,1);
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+10+horizontalShift*6);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
         ObjectSetText(objectName,GetTimeframeString(tf),displayTextSize,nonPropFont,colorTimeframe);
      
      }//if(column == 1)
      
      //----
      
      //second column
      if(column == 2)
      {
         //TF Label
         objectName=almostUniqueIndex+"_css_obj_table2_column1_tf"+ObjectSuffix;
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
            {
               ObjectSet(objectName,OBJPROP_CORNER,1);
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+10+horizontalShift*2.5);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
         showText="TF ";
         ObjectSetText(objectName,showText,displayTextSize,nonPropFont,colorTimeframe);

         //CSS Value
         objectName=almostUniqueIndex+"_css_obj_table2_column2_tf"+ObjectSuffix;
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
            {
               ObjectSet(objectName,OBJPROP_CORNER,1);
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+10);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
         ObjectSetText(objectName,GetTimeframeString(tf),displayTextSize,nonPropFont,colorTimeframe);
      
      }//if(column == 2)
      
      //----
      
      //third column
      if(column == 3)
      {
         //TF Label
         objectName=almostUniqueIndex+"_css_obj_table3_column1_tf"+ObjectSuffix;
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
            {
               ObjectSet(objectName,OBJPROP_CORNER,1);
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+10+horizontalShift*2.5);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset+tableVertOffset);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
         showText="TF ";
         ObjectSetText(objectName,showText,displayTextSize,nonPropFont,colorTimeframe);

         //extraTimeFrame
         objectName=almostUniqueIndex+"_css_obj_table3_column2_tf"+ObjectSuffix;
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
            {
               ObjectSet(objectName,OBJPROP_CORNER,1);
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+10);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset+tableVertOffset);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
         ObjectSetText(objectName,GetTimeframeString(tf),displayTextSize,nonPropFont,colorTimeframe);
         
      }//if(column == 3)
      
      ////////////////////////////////////////////////////////////////
      
      
      //Sort currency arrays
      ArraySort(Currency_Values,WHOLE_ARRAY,0,MODE_DESCEND);
      ArraySort(tempCurrencyValues,WHOLE_ARRAY,0,MODE_DESCEND);
      ArraySort(tempCurrencyValues2,WHOLE_ARRAY,0,MODE_DESCEND);

      int horizontalOffsetCross=0;
      
     
      //Loop currency values and header output objects, creating them if necessary 
      for(i=0; i<CURRENCYCOUNT; i++)
      {
         if(column == 1)
         {
            //Create symbol for cross alerts
            string CurrCreate, Curr_1, Curr_2;
            double MyBid=0;
            
            if(i<CURRENCYCOUNT-1)
            {
               //currency index
               tempValue=int(Currency_Values[i][2]);
               tempValue_2=int(Currency_Values[i+1][2]);
               
               //currency name
               showText=currencyNames[tempValue];
               showText_2=currencyNames[tempValue_2];
               
               //build symbol
               CurrCreate = CreateSymbol(showText,showText_2);
               Curr_1 = StringSubstrOld(CurrCreate,0,3);
               Curr_2 = StringSubstrOld(CurrCreate,3,3);
               
               MyBid = MarketInfo(Curr_1+Curr_2,MODE_BID);
            }
            
            objectName=almostUniqueIndex+"_css_obj_table1_column1_curr_"+IntegerToString(i)+ObjectSuffix;
            if(ObjectFind(objectName)==-1)
            {
               if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
               {
                  ObjectSet(objectName,OBJPROP_CORNER,1);
                  ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+horizontalShift*9.25);
                  ObjectSet(objectName,OBJPROP_YDISTANCE,(verticalShift+2) *(i+1)+verticalOffset);
                  ObjectSet(objectName,OBJPROP_HIDDEN,true);
               }
            }
            tempValue= int(Currency_Values[i][2]);
            showText = currencyNames[tempValue];
            ObjectSetText(objectName,showText,displayTextSize,nonPropFont,currencyColors[tempValue]);
   
            //----
            
            objectName=almostUniqueIndex+"_css_obj_table1_column2_val_"+IntegerToString(i)+ObjectSuffix;
            if(ObjectFind(objectName)==-1)
            {
               if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
               {
                  ObjectSet(objectName,OBJPROP_CORNER,1);
                  ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+horizontalShift*6.25);
                  ObjectSet(objectName,OBJPROP_YDISTANCE,(verticalShift+2) *(i+1)+verticalOffset);
                  ObjectSet(objectName,OBJPROP_HIDDEN,true);
               }
            }
            showText=RightAlign(DoubleToStr(Currency_Values[i][0],2),5);
            ObjectSetText(objectName,showText,displayTextSize,nonPropFont,currencyColors[tempValue]);
            
            //----
            
            //PopUp alert Stuff
            if(showCrossAlerts
               && i<CURRENCYCOUNT-1
               && NormalizeDouble(Currency_Values[i][0],2)>NormalizeDouble(Currency_Values[i+1][0],2)
               && Currency_Values[i][1]<Currency_Values[i+1][1]
              )
            {
               if(tLastAlert[i]<Time[0] && OkToSendAlerts)
               {
                  //currency index
                  tempValue=int(Currency_Values[i][2]);
                  tempValue_2=int(Currency_Values[i+1][2]);                  
                  
                  //currency name
                  showText=currencyNames[tempValue];
                  showText_2=currencyNames[tempValue_2];
                  
                  if(showText == Curr_1)
                  {
                     digits = GetDigits(showText+showText_2);
                     fireAlerts(showText+showText_2+" did a cross up "+TFToString(tf)+" @"+DoubleToStr(MyBid,digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));
                  }
                  if(showText == Curr_2)
                  {
                     digits = GetDigits(showText_2+showText);
                     fireAlerts(showText_2+showText+" did a cross down "+TFToString(tf)+" @"+DoubleToStr(MyBid,digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));
                  }
                  tLastAlert[i]=Time[0];
               }
            }
            
            //----
            
            //Detect and show crosses if users want to
            //Test for normalized values to filter trivial crosses
            objectName=almostUniqueIndex+"_css_obj_cross_"+IntegerToString(i)+ObjectSuffix;
            if(showCrossAlerts
               && i<CURRENCYCOUNT-1
               && NormalizeDouble(Currency_Values[i][0],2)>NormalizeDouble(Currency_Values[i+1][0],2)
               && Currency_Values[i][1]<Currency_Values[i+1][1]
              )
            {   
               showColor=colorStrongCross;
               if(Currency_Values[i][0]>0.8 || Currency_Values[i+1][0]<-0.8)
               {
                  showColor=colorWeakCross;
               }
               else if(Currency_Values[i][0]>0.4 || Currency_Values[i+1][0]<-0.4)
               {
                  showColor=colorNormalCross;
               } 
   
               //Prior values of this currency is lower than next currency, this is a cross.
               DrawCell(windex,objectName,horizontalOffset+horizontalShift*6+horizontalOffsetCross,(verticalShift+2) *(i+1)+verticalOffset,1,27,showColor);
   
               //Move cross location to next column if necessary
               if(horizontalOffsetCross==0)
               {
                  horizontalOffsetCross=-4;
               }
               else
               {
                  horizontalOffsetCross=0;
               }
            }
            else
            {
               DeleteCell(objectName);
               horizontalOffsetCross=0;
               
            }//else ~ if(showCrossAlerts... )
            
            //----
   
            if(showLevelCross)
            {
               //Show level cross
               double currentValue=Currency_Values[i][0];
               double priorValue=Currency_Values[i][1];
               
               //cross 0 +20 up and 0 -20 down
               objectName=almostUniqueIndex+"_css_obj_bullet_"+IntegerToString(i)+ObjectSuffix;
               if(priorValue<0 && currentValue>0)
               {
                  DrawBullet(windex,objectName,horizontalOffset-5+horizontalShift*6,(verticalShift+2) *(i+1)+verticalOffset-1,colorLevelHigh);
                  if(tLastAlert_1[i]<Time[0] && OkToSendAlerts)
                  {
                     showText=currencyNames[tempValue];
                     fireAlerts(showText+" did a cross up "+DoubleToStr(0.0,2)+" "+TFToString(tf)+" @__"+TimeToStr(TimeCurrent(), TIME_MINUTES));
                     tLastAlert_1[i]=Time[0];
                  }
               }
               if(priorValue<levelCrossValue && currentValue>levelCrossValue)// change from - to none
               {
                  DrawBullet(windex,objectName,horizontalOffset-5+horizontalShift*6,(verticalShift+2) *(i+1)+verticalOffset-1,colorLevelHigh);
                  if(tLastAlert_2[i]<Time[0] && OkToSendAlerts)
                  {
                     showText=currencyNames[tempValue];
                     fireAlerts(showText+" did a cross up "+DoubleToStr(levelCrossValue,2)+" "+TFToString(tf)+" @__"+TimeToStr(TimeCurrent(), TIME_MINUTES));
                     tLastAlert_2[i]=Time[0];
                  }
               }
               if(priorValue>0 && currentValue<0)
               {
                  DrawBullet(windex,objectName,horizontalOffset-5+horizontalShift*6,(verticalShift+2) *(i+1)+verticalOffset-1,colorLevelLow);
                  if(tLastAlert_3[i]<Time[0] && OkToSendAlerts)
                  {
                     showText=currencyNames[tempValue];
                     fireAlerts(showText+" did a cross down "+DoubleToStr(0.0,2)+" "+TFToString(tf)+" @__"+TimeToStr(TimeCurrent(), TIME_MINUTES));
                     tLastAlert_3[i]=Time[0];
                  }
               }
               if(priorValue>-levelCrossValue && currentValue<-levelCrossValue)//change from none to -
               {
                  DrawBullet(windex,objectName,horizontalOffset-5+horizontalShift*6,(verticalShift+2) *(i+1)+verticalOffset-1,colorLevelLow);
                  if(tLastAlert_4[i]<Time[0] && OkToSendAlerts)
                  {
                     showText=currencyNames[tempValue];
                     fireAlerts(showText+" did a cross down "+DoubleToStr(-levelCrossValue,2)+" "+TFToString(tf)+" @__"+TimeToStr(TimeCurrent(), TIME_MINUTES));
                     tLastAlert_4[i]=Time[0];
                  }
               }
               else
               {
                  ObjectDelete(objectName);
               }
                 
            }//if(showLevelCross)
         
         }//if(column == 1)
         
         //----
         
         if(column == 2)
         {
            //currency name
            objectName=almostUniqueIndex+"_css_obj_table2_column1_curr_"+IntegerToString(i)+ObjectSuffix;
            if(ObjectFind(objectName)==-1)
            {
               if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
               {
                  ObjectSet(objectName,OBJPROP_CORNER,1);
                  ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+horizontalShift*3);
                  ObjectSet(objectName,OBJPROP_YDISTANCE,(verticalShift+2)*(i+1)+verticalOffset);
                  ObjectSet(objectName,OBJPROP_HIDDEN,true);
               }
            }
            tempValue= int(tempCurrencyValues[i][2]);
            showText = currencyNames[tempValue];
            ObjectSetText(objectName,showText,displayTextSize,nonPropFont,currencyColors[tempValue]);
   
            //----
            
            //currency value
            objectName=almostUniqueIndex+"_css_obj_table2_column2_val_"+IntegerToString(i)+ObjectSuffix;
            if(ObjectFind(objectName)==-1)
            {
               if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
               {
                  ObjectSet(objectName,OBJPROP_CORNER,1);
                  ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset);
                  ObjectSet(objectName,OBJPROP_YDISTANCE,(verticalShift+2)*(i+1)+verticalOffset);
                  ObjectSet(objectName,OBJPROP_HIDDEN,true);
               }
            }
            showText=RightAlign(DoubleToStr(tempCurrencyValues[i][0],2),5);
            ObjectSetText(objectName,showText,displayTextSize,nonPropFont,currencyColors[tempValue]);
         
         }//if(column == 2)
         
         //----
         
         if(column == 3)
         {
            objectName=almostUniqueIndex+"_css_obj_table3_column1_curr_"+IntegerToString(i)+ObjectSuffix;
            if(ObjectFind(objectName)==-1)
            {
               if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
               {
                  ObjectSet(objectName,OBJPROP_CORNER,1);
                  ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+horizontalShift*3);
                  ObjectSet(objectName,OBJPROP_YDISTANCE,(verticalShift+2)*(i+1)+verticalOffset+tableVertOffset);
                  ObjectSet(objectName,OBJPROP_HIDDEN,true);
               }
            }
            tempValue= int(tempCurrencyValues2[i][2]);
            showText = currencyNames[tempValue];
            ObjectSetText(objectName,showText,displayTextSize,nonPropFont,currencyColors[tempValue]);
   
            //----
            
            objectName=almostUniqueIndex+"_css_obj_table3_column2_val_"+IntegerToString(i)+ObjectSuffix;
            if(ObjectFind(objectName)==-1)
            {
               if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
               {
                  ObjectSet(objectName,OBJPROP_CORNER,1);
                  ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset);
                  ObjectSet(objectName,OBJPROP_YDISTANCE,(verticalShift+2)*(i+1)+verticalOffset+tableVertOffset);
                  ObjectSet(objectName,OBJPROP_HIDDEN,true);
               }
            }
            showText=RightAlign(DoubleToStr(tempCurrencyValues2[i][0],2),5);
            ObjectSetText(objectName,showText,displayTextSize,nonPropFont,currencyColors[tempValue]);
         
         }//if(column == 3)
           
      }//for(i=0; i<CURRENCYCOUNT; i++)
        
   }//else ~ if(showOnlySymbolOnChart)
     
}//showCurrencyTable()
  
//+------------------------------------------------------------------+
//| Right Align Text                                                 |
//+------------------------------------------------------------------+
string RightAlign(string text,int length=10,int trailing_spaces=0)
  {
   string text_aligned=text;
   for(int i=0; i<length-StringLen(text)-trailing_spaces; i++)
     {
      text_aligned=" "+text_aligned;
     }
   return ( text_aligned );
  }
  
//+------------------------------------------------------------------+
//| DrawCell(), credits go to Alexandre A. B. Borela                 |
//+------------------------------------------------------------------+
void DrawCell(int nWindow,string nCellName,double nX,double nY,double nWidth,double nHeight,color nColor)
  {
   double   iHeight,iWidth,iXSpace;
   int      iSquares,i;

   if(nWidth>nHeight)
     {
      iSquares=int(MathCeil(nWidth/nHeight)); // Number of squares used.
      iHeight  = MathRound( ( nHeight * 100 ) / 77 ); // Real height size.
      iWidth   = MathRound ( ( nWidth * 100 ) / 77 ); // Real width size.
      iXSpace  = iWidth / iSquares - ( ( iHeight / ( 9 - ( nHeight / 100 ) ) ) * 2 );
      for(i=0; i<iSquares; i++)
        {
         ObjectCreate(nCellName+IntegerToString(i),OBJ_LABEL,nWindow,0,0);
         ObjectSetText(nCellName+IntegerToString(i),CharToStr(110),int(iHeight),"Wingdings",nColor);
         ObjectSet(nCellName+IntegerToString(i),OBJPROP_CORNER,1);
         ObjectSet(nCellName+IntegerToString(i),OBJPROP_XDISTANCE,nX+iXSpace*i);
         ObjectSet(nCellName+IntegerToString(i),OBJPROP_YDISTANCE,nY);
         ObjectSet(nCellName+IntegerToString(i),OBJPROP_BACK,true);
         ObjectSet(nCellName,OBJPROP_HIDDEN,true);
        }
     }
   else
     {
      iSquares=int(MathCeil(nHeight/nWidth)); // Number of squares used.
      iHeight  = MathRound( ( nHeight * 100 ) / 77 ); // Real height size.
      iWidth   = MathRound ( ( nWidth * 100 ) / 77 ); // Real width size.
      iXSpace  = iHeight / iSquares - ( ( iWidth / ( 9 - ( nWidth / 100 ) ) ) * 2 );

      for(i=0; i<iSquares; i++)
        {
         ObjectCreate(nCellName+IntegerToString(i),OBJ_LABEL,nWindow,0,0);
         ObjectSetText(nCellName+IntegerToString(i),CharToStr(110),int(iWidth),"Wingdings",nColor);
         ObjectSet(nCellName+IntegerToString(i),OBJPROP_CORNER,1);
         ObjectSet(nCellName+IntegerToString(i),OBJPROP_XDISTANCE,nX);
         ObjectSet(nCellName+IntegerToString(i),OBJPROP_YDISTANCE,nY+iXSpace*i);
         ObjectSet(nCellName+IntegerToString(i),OBJPROP_BACK,true);
         ObjectSet(nCellName,OBJPROP_HIDDEN,true);
        }
     }
  }
  
//+------------------------------------------------------------------+
//| DeleteCell()                                                     |
//+------------------------------------------------------------------+
void DeleteCell(string name)
  {
   int square=0;
   while(ObjectFind(name+IntegerToString(square))>-1)
     {
      ObjectDelete(name+IntegerToString(square));
      square++;
     }
  }
  
//+------------------------------------------------------------------+
//| DrawBullet()                                                     |
//+------------------------------------------------------------------+
void DrawBullet(int window,string cellName,int col,int row,color bulletColor)
  {
   if(ObjectFind(cellName)==-1)
     {
      if(ObjectCreate(cellName,OBJ_LABEL,window,0,0))
        {
         ObjectSet(cellName,OBJPROP_CORNER,1);
         ObjectSet(cellName,OBJPROP_XDISTANCE,col);
         ObjectSet(cellName,OBJPROP_YDISTANCE,row);
         ObjectSet(cellName,OBJPROP_BACK,true);
         ObjectSet(cellName,OBJPROP_HIDDEN,true);
         ObjectSetText(cellName,CharToStr(108),12,"Wingdings",bulletColor);
        }
     }
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fireAlerts(string sMsg)
{
   if(PopupAlert)
      Alert(sMsg);   
   if(EmailAlert)
      SendMail("CSS Alert "+"",sMsg);
   if(PushAlert)
      SendNotification(sMsg);
   
}//fireAlerts()

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string StringSubstrOld(string x,int a,int b=-1) 
  {
   if(a<0) a=0; // Stop odd behaviour
   if(b<=0) b=-1; // new MQL4 EOL flag
   return StringSubstr(x,a,b);
  }
  
//+------------------------------------------------------------------+
//| TF to String                                                     |
//+------------------------------------------------------------------+
string TFToString(int tf)
{
   switch(tf) {
      case 1: return("M1"); break;
		case 5: return("M5"); break; 
		case 15: return("M15"); break;
		case 30: return("M30"); break;
		case 60: return("H1"); break;
		case 240: return("H4"); break;
		case 1440: return("D1"); break;
		case 10080: return("W1"); break;
		case 43200: return("MN"); break;
		default: return(TFToString(Period()));
	}
	
	return(TFToString(Period()));
	
}//TFToString(int tf)

//+------------------------------------------------------------------+
// StrToTF(string str)                                               |
//+------------------------------------------------------------------+
// Converts a timeframe string to its MT4-numeric value
// Usage:   int x=StrToTF("M15")   returns x=15
int StrToTF(string str)
{
  str = StringUpper(str);
  str = StringTrimLeft(str);
  str = StringTrimRight(str);
  
  if (str == "M1")   return(1);
  if (str == "M5")   return(5);
  if (str == "M15")  return(15);
  if (str == "M30")  return(30);
  if (str == "H1")   return(60);
  if (str == "H4")   return(240);
  if (str == "D1")   return(1440);
  if (str == "W1")   return(10080);
  if (str == "MN")   return(43200);
  
  return(0);
} 

//+------------------------------------------------------------------+
// StringUpper(string str)                                           |
//+------------------------------------------------------------------+
// Converts any lowercase characters in a string to uppercase
// Usage:    string x=StringUpper("The Quick Brown Fox")  returns x = "THE QUICK BROWN FOX"
string StringUpper(string str)
{
  string outstr = "";
  string lower  = "abcdefghijklmnopqrstuvwxyz";
  string upper  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  for(int i=0; i<StringLen(str); i++)  {
    int t1 = StringFind(lower,StringSubstr(str,i,1),0);
    if (t1 >=0)  
      outstr = outstr + StringSubstr(upper,t1,1);
    else
      outstr = outstr + StringSubstr(str,i,1);
  }
  return(outstr);
  
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CreateSymbol(string curr1, string curr2)
{
   //28 symbols
   string symbols = "AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,GBPUSD,NZDCAD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY";
   
   //two currencies can only make one pair
   if(StringFind(symbols, curr1+curr2) != -1) return(curr1+curr2);
   
   return(curr2+curr1);

}//CreateSymbol()

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsItNewReadTime() 
{
   bool IsNewReadTime = false;
   bool IsReadEveryNewBar = false;
   
   if(EveryTickMode)
   {
      IsNewReadTime = true;
   }
   else
   {
      if(ReadEveryNewBar)
      {
         IsReadEveryNewBar = (Time[0] != lastBarTime);
         lastBarTime = Time[0];
      }     
      
      if(TimeCurrent() >= NextReadTime || IsReadEveryNewBar)
      {
         NextReadTime = TimeCurrent() + ReadEveryXSeconds;   	  
   	   IsNewReadTime = true;    
      }
   }
   
   return(IsNewReadTime); 
   
}//IsItNewReadTime()

//+------------------------------------------------------------------+ 
//| Creating Text object                                             | 
//+------------------------------------------------------------------+ 
void TextCreate(const string            pName = "Text",             // object name 
                datetime                time = 0,                   // anchor point time 
                double                  price = 0,                  // anchor point price 
                const string            text = "Text",              // the text itself 
                const color             clr = clrRed,               // color 
                const ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER, // anchor type 
                const string            font = "Wingdings",         // font 
                const int               font_size = 14,             // font size 
                const double            angle = 0.0,                // text slope 
                const bool              back = true,                // in the background 
                const bool              selection = false,          // highlight to move 
                const bool              hidden = true,              // hidden in the object list 
                const long              z_order = 0
               )
{ 
   long chart_ID = ChartID();
   string name = pName;
   
   if ( ObjectFind( chart_ID, name ) < 0 )
   {
      if ( !ObjectCreate( chart_ID, name, OBJ_TEXT, 0, time, price ) ) 
      { 
         Print(__FUNCTION__, ": failed to create \"Text\" object! Error code = ", GetLastError() ); 
         return; 
      } 
   }  

   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle); 
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor); 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
   
}//TextCreate()

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetDigits(string symbol)
{
   string suffix, symbol2;
   int    digits2;
   bool   Is5DigitBroker=false;
   
   //if suffix was stripped from symbol
   if(StringLen(Symbol()) > 6)
   {
      suffix = StringSubstrOld(Symbol(),6,4);
      symbol2 = StringTrimRight(StringSubstrOld(symbol,0,6)+suffix);       
   }
   else
   {
      symbol2 = symbol;
   }
   
   digits2 = (int)MarketInfo(symbol2, MODE_DIGITS); 
   
   return(digits2);
   
}//GetDigits(string symbol)

//+------------------------------------------------------------------+
