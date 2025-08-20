//+------------------------------------------------------------------+
//|                              CurrencySlopeStrength - RSI mod.mq4 |
//|                      Copyright 2012, Deltabron - Paul Geirnaerdt |
//|                                          http://www.deltabron.nl |
//+------------------------------------------------------------------+
//
// Parts based on CCFp.mq4, downloaded from mql4.com
// A mashup indi that is based on Currency Slope Strength from Stevehopwoodforex.com.  
// SMA was put in by Gary, such as the Button module. edited by Wicha
// v1.3 Higher TF RSI line added, Autotimeframe mode added 


#property copyright "Copyright 2012, Deltabron - Paul Geirnaerdt"
#property link      "http://www.deltabron.nl"
//----
#property indicator_separate_window
#property indicator_buffers 24

#property indicator_minimum 0
#property indicator_maximum 100

#define version            "v1.0.0 - STO_mod"

//+------------------------------------------------------------------+
//| Release Notes                                                    |
//+------------------------------------------------------------------+

//
// 

#define EPSILON            0.00000001

#define CURRENCYCOUNT      8

//---- parameters

extern string  gen               = "----General inputs----";
extern bool    autoSymbols       = false;
extern bool    autoTimeFrame     = TRUE;

extern string	symbolsToWeigh    = "GBPNZD,EURNZD,GBPAUD,GBPCAD,GBPJPY,GBPCHF,CADJPY,EURCAD,EURAUD,USDCHF,GBPUSD,EURJPY,NZDJPY,AUDCHF,AUDJPY,USDJPY,EURUSD,NZDCHF,CADCHF,AUDNZD,NZDUSD,CHFJPY,AUDCAD,USDCAD,NZDCAD,AUDUSD,EURCHF,EURGBP";
extern int     maxBars           = 100;
extern string  nonPropFont       = "Lucida Console";
extern bool    showOnlySymbolOnChart = true;
extern string  str4356           = "----"; //----
extern bool    ShowButtons       = false;
extern bool    showiRSILines     = true;
extern bool    showiMALines      = true;
extern bool    showHi_TF_RSI     = FALSE;
extern int     MAPeriod          = 3;
extern ENUM_MA_METHOD MAMethod   = MODE_SMA;
extern string  RSI_Style         = 0;
extern string  RSI_Width         = 1;
extern string  SMA_Style         = 2;
extern string  SMA_Width         = 1;
extern string  Hi_RSI_Style      = 0;
extern string  Hi_RSI_Width      = 2;
extern string  Lower_level_value = 40;
extern string  Higher_level_value= 60;
extern int     PERIOD            =14; 
extern int     D                 =3;
extern int     S                 =3;
extern string  ind               = "----Indicator inputs----";
extern string  ind_tf            = "timeFrame 'D1'/'H4'/'H1'/'M30'/'M15'";
extern string  timeFrame         = "M30";
extern string  Higher_TF         = "H1";

extern string  cur               = "----Currency inputs----";
extern bool    USD               = true;
extern bool    EUR               = true;
extern bool    GBP               = true;
extern bool    CHF               = true;
extern bool    JPY               = true;
extern bool    AUD               = true;
extern bool    CAD               = true;
extern bool    NZD               = true;


extern string  col               = "----Colo(u)r inputs----";
extern color   Color_USD         = White;
extern color   Color_EUR         = HotPink;
extern color   Color_GBP         = Red;
extern color   Color_CHF         = Yellow;
extern color   Color_JPY         = Magenta;
extern color   Color_AUD         = Lime;
extern color   Color_CAD         = Goldenrod;
extern color   Color_NZD         = DodgerBlue;
extern color   Color_USD_Hi      = White;
extern color   Color_EUR_Hi      = HotPink;
extern color   Color_GBP_Hi      = Red;
extern color   Color_CHF_Hi      = Yellow;
extern color   Color_JPY_Hi      =  Magenta;
extern color   Color_AUD_Hi      = Lime;
extern color   Color_CAD_Hi      = Goldenrod;
extern color   Color_NZD_Hi      = DodgerBlue;


// global indicator variables
string   indicatorName = "CSS - STO mod";
string   shortName;
int      userTimeFrame;
int      higherTimeFrame;
string   almostUniqueIndex;

// indicator buffers
double   arrUSD[];
double   arrEUR[];
double   arrGBP[];
double   arrCHF[];
double   arrJPY[];
double   arrAUD[];
double   arrCAD[];
double   arrNZD[];

//iMAOnArray
double   arrUSD2[];
double   arrEUR2[];
double   arrGBP2[];
double   arrCHF2[];
double   arrJPY2[];
double   arrAUD2[];
double   arrCAD2[];
double   arrNZD2[];

//HigherTF_RSI
double   arrUSD3[];
double   arrEUR3[];
double   arrGBP3[];
double   arrCHF3[];
double   arrJPY3[];
double   arrAUD3[];
double   arrCAD3[];
double   arrNZD3[];


// symbol & currency variables
int      symbolCount;
string   symbolNames[];
string   currencyNames[CURRENCYCOUNT]        = { "USD", "EUR", "GBP", "CHF", "JPY", "AUD", "CAD", "NZD" };
double   currencyValues[CURRENCYCOUNT];      // RSI
double   currencyValues2[CURRENCYCOUNT];     // Hi_TF_RSI
double   currencyOccurrences[CURRENCYCOUNT]; // Holds the number of occurrences of each currency in symbols

color    currencyColors[CURRENCYCOUNT+16];

// object parameters
int      verticalShift = 14;
int      verticalOffset = 30;
int      horizontalShift = 100;
int      horizontalOffset = 10;

extern string  sep11b="================================================================";
extern string  cmdb="---- Command buttons ----";
extern int     ButtonHeight=15;
extern int     ButtonWidth=40;
extern ENUM_BASE_CORNER ButtonCorner=CORNER_RIGHT_LOWER; // Chart corner for anchoring
extern string           ButtonFont="Arial";             // Font
extern int              ButtonFontSize=7;              // Font size
extern color            ButtonColor=clrBlack;           // Text color
extern color            ButtonBackColor=clrGainsboro;  // Background color
extern color            ButtonBorderColor=clrSilver;  // Border color
extern int              Button_X=60;                   //X axis
extern int              Button_Y=30;                    //Y axis

////////////////////////////////////////////////////////////////////////////////////////
bool           ButtonBack=false;               // Background object
bool           ButtonSelection=false;          // Highlight to move
bool           ButtonHidden=false;             // Hidden in the object list
long           ButtonZOrder=0;                 // Priority for mouse click
bool           ButtonState=false;              // Pressed/Released
////////////////////////////////////////////////////////////////////////////////////////
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{   
   initSymbols();
 
   SetLevelValue (1, Lower_level_value);
   SetLevelStyle( STYLE_DASHDOTDOT, 1,DimGray);
   
   SetLevelValue (2, 50);
   SetLevelStyle( STYLE_DASHDOTDOT, 1,DimGray);
   
   SetLevelValue (3, Higher_level_value);
   SetLevelStyle( STYLE_DASHDOTDOT, 1,DimGray);
   
   
   //---- indicators
   shortName = indicatorName + " - " + version + " - Timeframe: " + timeFrame;
   IndicatorShortName(shortName);

   
   //----
   currencyColors[0] = Color_USD;
   SetIndexBuffer(0, arrUSD);
   SetIndexLabel(0, "USD"); 
   
   currencyColors[1] = Color_EUR;
   SetIndexBuffer(1, arrEUR);
   SetIndexLabel(1, "EUR"); 
   
   currencyColors[2] = Color_GBP;
   SetIndexBuffer(2, arrGBP);
   SetIndexLabel(2, "GBP"); 

   currencyColors[3] = Color_CHF;
   SetIndexBuffer(3, arrCHF);
   SetIndexLabel(3, "CHF"); 

   currencyColors[4] = Color_JPY;
   SetIndexBuffer(4, arrJPY);
   SetIndexLabel(4, "JPY"); 

   currencyColors[5] = Color_AUD;
   SetIndexBuffer(5, arrAUD);
   SetIndexLabel(5, "AUD"); 

   currencyColors[6] = Color_CAD;
   SetIndexBuffer(6, arrCAD);
   SetIndexLabel(6, "CAD"); 

   currencyColors[7] = Color_NZD;
   SetIndexBuffer(7, arrNZD);
   SetIndexLabel(7, "NZD"); 
   
   //----
   
   currencyColors[8] = Color_USD;
   SetIndexBuffer(8, arrUSD2);
   SetIndexLabel(8, "USD"); 
   
   currencyColors[9] = Color_EUR;
   SetIndexBuffer(9, arrEUR2);
   SetIndexLabel(9, "EUR"); 
   
   currencyColors[10] = Color_GBP;
   SetIndexBuffer(10, arrGBP2);
   SetIndexLabel(10, "GBP"); 

   currencyColors[11] = Color_CHF;
   SetIndexBuffer(11, arrCHF2);
   SetIndexLabel(11, "CHF"); 

   currencyColors[12] = Color_JPY;
   SetIndexBuffer(12, arrJPY2);
   SetIndexLabel(12, "JPY"); 

   currencyColors[13] = Color_AUD;
   SetIndexBuffer(13, arrAUD2);
   SetIndexLabel(13, "AUD"); 

   currencyColors[14] = Color_CAD;
   SetIndexBuffer(14, arrCAD2);
   SetIndexLabel(14, "CAD"); 

   currencyColors[15] = Color_NZD;
   SetIndexBuffer(15, arrNZD2);
   SetIndexLabel(15, "NZD"); 
   
   //----
   
   currencyColors[16] = Color_USD_Hi;
   SetIndexBuffer(16, arrUSD3);
   SetIndexLabel(16, "USD"); 
   
   currencyColors[17] = Color_EUR_Hi;
   SetIndexBuffer(17, arrEUR3);
   SetIndexLabel(17, "EUR"); 
   
   currencyColors[18] = Color_GBP_Hi;
   SetIndexBuffer(18, arrGBP3);
   SetIndexLabel(18, "GBP"); 

   currencyColors[19] = Color_CHF_Hi;
   SetIndexBuffer(19, arrCHF3);
   SetIndexLabel(19, "CHF"); 

   currencyColors[20] = Color_JPY_Hi;
   SetIndexBuffer(20, arrJPY3);
   SetIndexLabel(20, "JPY"); 

   currencyColors[21] = Color_AUD_Hi;
   SetIndexBuffer(21, arrAUD3);
   SetIndexLabel(21, "AUD"); 

   currencyColors[22] = Color_CAD_Hi;
   SetIndexBuffer(22, arrCAD3);
   SetIndexLabel(22, "CAD"); 

   currencyColors[23] = Color_NZD_Hi;
   SetIndexBuffer(23, arrNZD3);
   SetIndexLabel(23, "NZD"); 
   
//----
    
   int i=0;
   
   
   //iRSI
   for ( i = 0; i < CURRENCYCOUNT; i++ )
   {
      if(showiRSILines==true && ShowButtons==false)
         SetIndexStyle( i, DRAW_LINE, RSI_Style, RSI_Width, currencyColors[i] );
      else
         SetIndexStyle(i,DRAW_NONE);
   } 
   
   //iMAonArray
   for ( i = 8; i < CURRENCYCOUNT + 8; i++ )
   {
      if(showiMALines==true && ShowButtons==false)
         SetIndexStyle( i, DRAW_LINE, SMA_Style, SMA_Width, currencyColors[i] );
      else
         SetIndexStyle(i,DRAW_NONE);
   } 
   //HiTF_iRSI
   for ( i = 16; i < CURRENCYCOUNT+16 ; i++ )
   {
      if(showHi_TF_RSI==true && ShowButtons==false)
         SetIndexStyle( i, DRAW_LINE, Hi_RSI_Style, Hi_RSI_Width, currencyColors[i] );
      else
         SetIndexStyle(i,DRAW_NONE);
   } 
 
//----
 
   string now = TimeCurrent();
   almostUniqueIndex = StringSubstr(now, StringLen(now) - 3);

   //this is a band aid -- figure out how to disable subwindow 'on chart events'
   if(ShowButtons && !showOnlySymbolOnChart)
   {
      DrawButtons();  
      ObjectSetInteger(0,"All",OBJPROP_STATE,true);
   }   
   if(!ShowButtons || showOnlySymbolOnChart)
   {
      Button_Y = -100; 
      DrawButtons();  
      ObjectSetInteger(0,"All",OBJPROP_STATE,true);           
   }
   return(0);
}

//+------------------------------------------------------------------+
//| Initialize Symbols Array                                         |
//+------------------------------------------------------------------+
int initSymbols()
{
   int i;
   
   // Get extra characters on this crimmal's symbol names
   string symbolExtraChars = StringSubstr(Symbol(), 6, 4);

   // Trim user input
   symbolsToWeigh = StringTrimLeft(symbolsToWeigh);
   symbolsToWeigh = StringTrimRight(symbolsToWeigh);

   // Add extra comma
   if (StringSubstr(symbolsToWeigh, StringLen(symbolsToWeigh) - 1) != ",")
   {
      symbolsToWeigh = StringConcatenate(symbolsToWeigh, ",");   
   }   

   // Build symbolNames array as the user likes it
   if ( autoSymbols )
   {
      createSymbolNamesArray();
   }
   else
   {
      // Split user input
      i = StringFind(symbolsToWeigh, ","); 
      while (i != -1)
      {
         int size = ArraySize(symbolNames);
         // Resize array
         ArrayResize(symbolNames, size + 1);
         // Set array
         symbolNames[size] = StringConcatenate(StringSubstr(symbolsToWeigh, 0, i), symbolExtraChars);
         // Trim symbols
         symbolsToWeigh = StringSubstr(symbolsToWeigh, i + 1);
         i = StringFind(symbolsToWeigh, ","); 
      }
   }   
   
   symbolCount = ArraySize(symbolNames);

   for ( i = 0; i < symbolCount; i++ )
   {
      // Increase currency occurrence
      int currencyIndex = GetCurrencyIndex(StringSubstr(symbolNames[i], 0, 3));
      currencyOccurrences[currencyIndex]++;
      currencyIndex = GetCurrencyIndex(StringSubstr(symbolNames[i], 3, 3));
      currencyOccurrences[currencyIndex]++;
   }   

  if(autoTimeFrame)
  userTimeFrame = Period();
  else
  {
   if ( timeFrame == "H4" )
   userTimeFrame = PERIOD_H4;
   
   if ( timeFrame == "H1" )
   {
      userTimeFrame = PERIOD_H1;
   }
    if ( timeFrame == "D1" )
   {
      userTimeFrame = PERIOD_D1;
   }
   if ( timeFrame == "M30" )
   {
      userTimeFrame = PERIOD_M30; 
   }
    if ( timeFrame == "M15" )
   {
      userTimeFrame = PERIOD_M15; 
   }
   if ( timeFrame == "M5" )
   {
      userTimeFrame = PERIOD_M5;
   }
   if ( timeFrame == "M1" )
   {
      userTimeFrame = PERIOD_M1;
   }
   if ( userTimeFrame < Period() )
        {
      userTimeFrame = Period();
        }
  } 
   

//Higher TF

      higherTimeFrame = PERIOD_D1;
   if ( Higher_TF == "W1" )
   {
      higherTimeFrame = PERIOD_W1;
   }
    if ( Higher_TF == "H4" )
   {
      higherTimeFrame = PERIOD_H4;
   }
    if ( Higher_TF == "H1" ) 
    
   {
      higherTimeFrame = PERIOD_H1; 
   }
   if ( Higher_TF == "M30" )
   {
      higherTimeFrame = PERIOD_M30;
   }
   
   if ( Higher_TF == "M15" )
   {
      higherTimeFrame = PERIOD_M15;
   }
   if ( Higher_TF == "M5" )
   {
      higherTimeFrame = PERIOD_M5;
   }
   return(0);
}

//+------------------------------------------------------------------+
//| GetCurrencyIndex(string currency)                                |
//+------------------------------------------------------------------+
int GetCurrencyIndex(string currency)
{
   for (int i = 0; i < CURRENCYCOUNT; i++)
   {
      if (currencyNames[i] == currency)
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
   int hFileName = FileOpenHistory ("symbols.raw", FILE_BIN|FILE_READ );
   int recordCount = FileSize ( hFileName ) / 1936;
   int counter = 0;
   for ( int i = 0; i < recordCount; i++ )
   {
      string tempSymbol = StringTrimLeft ( StringTrimRight ( FileReadString ( hFileName, 12 ) ) );
      if ( MarketInfo ( tempSymbol, MODE_BID ) > 0 && MarketInfo ( tempSymbol, MODE_TRADEALLOWED ) )
      {
         ArrayResize( symbolNames, counter + 1 );
         symbolNames[counter] = tempSymbol;
         counter++;
      }
      FileSeek( hFileName, 1924, SEEK_CUR );
   }
   FileClose( hFileName );
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   int windex = WindowFind ( shortName );
   if ( windex > 0 )
   {
      ObjectsDeleteAll ( windex );
   }   
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int limit;
   int counted_bars = IndicatorCounted();

   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)  counted_bars -= 10;

   limit = Bars - counted_bars;

   if ( maxBars > 0 )
   {
      limit = MathMin (maxBars, limit);   
   }   

   int i, bar;
   datetime myTime;
   
   //set as series
   ArraySetAsSeries(arrAUD2, true);  
   ArraySetAsSeries(arrCAD2, true);
   ArraySetAsSeries(arrGBP2, true);
   ArraySetAsSeries(arrEUR2, true);
   ArraySetAsSeries(arrJPY2, true);
   ArraySetAsSeries(arrNZD2, true);
   ArraySetAsSeries(arrJPY2, true);
   ArraySetAsSeries(arrCHF2, true);
   

   RefreshRates();  
   
   
   for ( i = 0; i < limit; i++ )
      {      
      ArrayInitialize(currencyValues, 0.0);
      
      //get bar
      myTime=iTime(_Symbol, _Period, i);
      bar=iBarShift(_Symbol, userTimeFrame, myTime); 
      if(bar<0) bar=0;

      // Calc Slope into currencyValues[]  
      CalculateCurrencySlopeStrength(userTimeFrame, bar);

      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "USD" ) != -1 ) ) || ( !showOnlySymbolOnChart && USD ) )        
      {
         arrUSD[i] = currencyValues[0];
         
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "EUR" ) != -1 ) ) || ( !showOnlySymbolOnChart && EUR ) )        
      {
         arrEUR[i] = currencyValues[1];
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "GBP" ) != -1 ) ) || ( !showOnlySymbolOnChart && GBP ) )        
      {
         arrGBP[i] = currencyValues[2];
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "CHF" ) != -1 ) ) || ( !showOnlySymbolOnChart && CHF ) )        
      {
         arrCHF[i] = currencyValues[3];
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "JPY" ) != -1 ) ) || ( !showOnlySymbolOnChart && JPY ) )        
      {
         arrJPY[i] = currencyValues[4];
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "AUD" ) != -1 ) ) || ( !showOnlySymbolOnChart && AUD ) )        
      {
         arrAUD[i] = currencyValues[5];
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "CAD" ) != -1 ) ) || ( !showOnlySymbolOnChart && CAD ) )        
      {
         arrCAD[i] = currencyValues[6];
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "NZD" ) != -1 ) ) || ( !showOnlySymbolOnChart && NZD ) )        
      {
         arrNZD[i] = currencyValues[7];
      }

      if ( i == 0 )
      {
         // Show ordered table
         ShowCurrencyTable();
      }   
   }    
   for ( i = 0; i < limit; i++ )
      {      
      ArrayInitialize(currencyValues2, 0.0);
      
      //get bar
      myTime=iTime(_Symbol, _Period, i);
      bar=iBarShift(_Symbol, higherTimeFrame, myTime); 
      if(bar<0) bar=0;     

      // Calc Slope into currencyValues[]  
      CalculateCurrencySlopeStrength2(higherTimeFrame, bar);

      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "USD" ) != -1 ) ) || ( !showOnlySymbolOnChart && USD ) )        
      {
         arrUSD3[i] = currencyValues2[0];
         
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "EUR" ) != -1 ) ) || ( !showOnlySymbolOnChart && EUR ) )        
      {
         arrEUR3[i] = currencyValues2[1];
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "GBP" ) != -1 ) ) || ( !showOnlySymbolOnChart && GBP ) )        
      {
         arrGBP3[i] = currencyValues2[2];
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "CHF" ) != -1 ) ) || ( !showOnlySymbolOnChart && CHF ) )        
      {
         arrCHF3[i] = currencyValues2[3];
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "JPY" ) != -1 ) ) || ( !showOnlySymbolOnChart && JPY ) )        
      {
         arrJPY3[i] = currencyValues2[4];
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "AUD" ) != -1 ) ) || ( !showOnlySymbolOnChart && AUD ) )        
      {
         arrAUD3[i] = currencyValues2[5];
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "CAD" ) != -1 ) ) || ( !showOnlySymbolOnChart && CAD ) )        
      {
         arrCAD3[i] = currencyValues2[6];
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "NZD" ) != -1 ) ) || ( !showOnlySymbolOnChart && NZD ) )        
      {
         arrNZD3[i] = currencyValues2[7];
      }

      if ( i == 0 )
      {
         // Show ordered table
         //ShowCurrencyTable();
      }   
   }
   //end block for(int i=0; i<limit; i++)
   
   //iMAOnArray
   for(i = 0; i < limit; i++)
   {
      arrUSD2[i] = iMAOnArray(arrUSD, 0, MAPeriod, 0, MAMethod, i);
      arrEUR2[i] = iMAOnArray(arrEUR, 0, MAPeriod, 0, MAMethod, i);
      arrGBP2[i] = iMAOnArray(arrGBP, 0, MAPeriod, 0, MAMethod, i);
      arrCHF2[i] = iMAOnArray(arrCHF, 0, MAPeriod, 0, MAMethod, i);
      arrJPY2[i] = iMAOnArray(arrJPY, 0, MAPeriod, 0, MAMethod, i);
      arrAUD2[i] = iMAOnArray(arrAUD, 0, MAPeriod, 0, MAMethod, i);
      arrCAD2[i] = iMAOnArray(arrCAD, 0, MAPeriod, 0, MAMethod, i);
      arrNZD2[i] = iMAOnArray(arrNZD, 0, MAPeriod, 0, MAMethod, i);
   }
   
  
   return(0);
}

//+------------------------------------------------------------------+
//| GetSlope()                                                       |
//+------------------------------------------------------------------+
double GetSlope(string symbol, int tf, int shift)

{

   double gadblSlope = iStochastic( symbol, tf, PERIOD,D,S, 0,0,0, shift );
  
  
   return ( gadblSlope );
}   
double GetSlope2(string symbol, int tf, int shift)

{

   double gadblSlope2 = iStochastic( symbol, higherTimeFrame, PERIOD,D,S,0,0, 0, shift );
  
  
   return ( gadblSlope2 );
}
//End double GetSlope(int tf, int shift)

//+------------------------------------------------------------------+
//| CalculateCurrencySlopeStrength(int tf, int shift                 |
//+------------------------------------------------------------------+
void CalculateCurrencySlopeStrength(int tf, int shift)

{
   int i;
   // Get Slope for all symbols and totalize for all currencies   
   for ( i = 0; i < symbolCount; i++)
   {
      double slope = GetSlope(symbolNames[i], tf, shift);
      currencyValues[GetCurrencyIndex(StringSubstr(symbolNames[i], 0, 3))] += slope;
      currencyValues[GetCurrencyIndex(StringSubstr(symbolNames[i], 3, 3))] += 100 - slope;
      
   
   } 
   
   for ( i = 0; i < CURRENCYCOUNT; i++ )
   {
      // average
      currencyValues[i] /= currencyOccurrences[i];
   }
}


//+------------------------------------------------------------------+
//| CalculateCurrencySlopeStrength(int tf, int shift                 |
//+------------------------------------------------------------------+
void CalculateCurrencySlopeStrength2(int tf, int shift)

{
   int i;
   // Get Slope for all symbols and totalize for all currencies   
   for ( i = 0; i < symbolCount; i++)
   {
      double slope = GetSlope(symbolNames[i], tf, shift);
      currencyValues2[GetCurrencyIndex(StringSubstr(symbolNames[i], 0, 3))] += slope;
      currencyValues2[GetCurrencyIndex(StringSubstr(symbolNames[i], 3, 3))] += 100 - slope;
      
   
   } 
   
   for ( i = 0; i < CURRENCYCOUNT; i++ )
   {
      // average
      currencyValues2[i] /= currencyOccurrences[i];
   }
}



//+------------------------------------------------------------------+
//| ShowCurrencyTable()                                              |
//+------------------------------------------------------------------+
void ShowCurrencyTable()
{
   int i;
   int tempValue;
   string objectName;
   string showText;
   int windex = WindowFind ( shortName );
   double tempCurrencyValues[CURRENCYCOUNT][2];
   
   for ( i = 0; i < CURRENCYCOUNT; i++ )
   {
      tempCurrencyValues[i][0] = currencyValues[i];
      tempCurrencyValues[i][1] = i;
   }
   
   // Sort currency to values
   ArraySort(tempCurrencyValues, WHOLE_ARRAY, 0, MODE_DESCEND);

   // Loop currency values and header output objects, creating them if necessary 
   for ( i = 0; i < CURRENCYCOUNT; i++ )
   {
      objectName = almostUniqueIndex + "_css_obj_column_currency_" + i;
      if ( ObjectFind ( objectName ) == -1 )
      {
         if ( ObjectCreate ( objectName, OBJ_LABEL, windex, 0, 0 ) )
         {
            ObjectSet ( objectName, OBJPROP_CORNER, 1 );
            ObjectSet ( objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset + 150 );
            ObjectSet ( objectName, OBJPROP_YDISTANCE, (verticalShift + 2) * i + verticalOffset - 18 );
         }
      }
      tempValue = tempCurrencyValues[i][1];
      showText = currencyNames[tempValue];
      ObjectSetText ( objectName, showText, 12, nonPropFont, currencyColors[tempValue] );

      objectName = almostUniqueIndex + "_css_obj_column_value_" + i;
      if ( ObjectFind ( objectName ) == -1 )
      {
         if ( ObjectCreate ( objectName, OBJ_LABEL, windex, 0, 0 ) )
         {
            ObjectSet ( objectName, OBJPROP_CORNER, 1 );
            ObjectSet ( objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset - 55 + 150 );
            ObjectSet ( objectName, OBJPROP_YDISTANCE, (verticalShift + 2) * i + verticalOffset - 18 );
         }
      }
      showText = RightAlign(DoubleToStr(tempCurrencyValues[i][0], 2), 5);
      ObjectSetText ( objectName, showText, 12, nonPropFont, currencyColors[tempValue] );
   }
}

//+------------------------------------------------------------------+
//| Right Align Text                                                 |
//+------------------------------------------------------------------+
string RightAlign ( string text, int length = 10, int trailing_spaces = 0 )
{
   string text_aligned = text;
   for ( int i = 0; i < length - StringLen ( text ) - trailing_spaces; i++ )
   {
      text_aligned = " " + text_aligned;
   }
   return ( text_aligned );
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
//BUTTONS MODULE

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawButtons()
{
   int x = Button_X;
   int y = Button_Y;
   bool result = true;
   
   //All
   //x+= (ButtonWidth + 10);
   result = ButtonCreate(0,"All",1,x,y,ButtonWidth,ButtonHeight,ButtonCorner,"All",ButtonFont,ButtonFontSize,
      ButtonColor,ButtonBackColor,ButtonBorderColor,ButtonState,ButtonBack,ButtonSelection,ButtonHidden,ButtonZOrder);
      
   //y+= (ButtonHeight + 10);
   
   //AUD
   x+= (ButtonWidth + 10);
   result = ButtonCreate(0,"AUD",1,x,y,ButtonWidth,ButtonHeight,ButtonCorner,"AUD",ButtonFont,ButtonFontSize,
      ButtonColor,ButtonBackColor,ButtonBorderColor,ButtonState,ButtonBack,ButtonSelection,ButtonHidden,ButtonZOrder);
      
   //y+= (ButtonHeight + 10);
   
   //CAD
   x+= (ButtonWidth + 10);
   result = ButtonCreate(0,"CAD",1,x,y,ButtonWidth,ButtonHeight,ButtonCorner,"CAD",ButtonFont,ButtonFontSize,
      ButtonColor,ButtonBackColor,ButtonBorderColor,ButtonState,ButtonBack,ButtonSelection,ButtonHidden,ButtonZOrder);
      
   //y+= (ButtonHeight + 10);
   
   //CHF
   x+= (ButtonWidth + 10);
   result = ButtonCreate(0,"CHF",1,x,y,ButtonWidth,ButtonHeight,ButtonCorner,"CHF",ButtonFont,ButtonFontSize,
      ButtonColor,ButtonBackColor,ButtonBorderColor,ButtonState,ButtonBack,ButtonSelection,ButtonHidden,ButtonZOrder);
      
   //y+= (ButtonHeight + 10);
   
   //EUR
   x+= (ButtonWidth + 10);
   result = ButtonCreate(0,"EUR",1,x,y,ButtonWidth,ButtonHeight,ButtonCorner,"EUR",ButtonFont,ButtonFontSize,
      ButtonColor,ButtonBackColor,ButtonBorderColor,ButtonState,ButtonBack,ButtonSelection,ButtonHidden,ButtonZOrder);
      
   //y+= (ButtonHeight + 10);
   
   //GBP
   x+= (ButtonWidth + 10);
   result = ButtonCreate(0,"GBP",1,x,y,ButtonWidth,ButtonHeight,ButtonCorner,"GBP",ButtonFont,ButtonFontSize,
      ButtonColor,ButtonBackColor,ButtonBorderColor,ButtonState,ButtonBack,ButtonSelection,ButtonHidden,ButtonZOrder);
      
   //y+= (ButtonHeight + 10);
   
   //JPY
   x+= (ButtonWidth + 10);
   result = ButtonCreate(0,"JPY",1,x,y,ButtonWidth,ButtonHeight,ButtonCorner,"JPY",ButtonFont,ButtonFontSize,
      ButtonColor,ButtonBackColor,ButtonBorderColor,ButtonState,ButtonBack,ButtonSelection,ButtonHidden,ButtonZOrder);
      
   //y+= (ButtonHeight + 10);
   
   //NZD
   x+= (ButtonWidth + 10);
   result = ButtonCreate(0,"NZD",1,x,y,ButtonWidth,ButtonHeight,ButtonCorner,"NZD",ButtonFont,ButtonFontSize,
      ButtonColor,ButtonBackColor,ButtonBorderColor,ButtonState,ButtonBack,ButtonSelection,ButtonHidden,ButtonZOrder);
      
   //y+= (ButtonHeight + 10);
   
   //USD
   x+= (ButtonWidth + 10);
   result = ButtonCreate(0,"USD",1,x,y,ButtonWidth,ButtonHeight,ButtonCorner,"USD",ButtonFont,ButtonFontSize,
      ButtonColor,ButtonBackColor,ButtonBorderColor,ButtonState,ButtonBack,ButtonSelection,ButtonHidden,ButtonZOrder);
      
   //y+= (ButtonHeight + 10);
   
//--- redraw the chart
   ChartRedraw();

}//End void DrawButtons()

//+------------------------------------------------------------------+
//| Create the button                                                |
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,               // chart's ID
                  const string            name="Button",            // button name
                  const int               sub_window=0,             // subwindow index
                  const int               x=0,                      // X coordinate
                  const int               y=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=18,                // button height
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string            text="Button",            // text
                  const string            font="Arial",             // font
                  const int               font_size=10,             // font size
                  const color             clr=clrBlack,             // text color
                  const color             back_clr=C'236,233,216',  // background color
                  const color             border_clr=clrNONE,       // border color
                  const bool              state=false,              // pressed/released
                  const bool              back=false,               // in the background
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=true,              // hidden in the object list
                  const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create the button
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set button size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{

   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam=="USD")
         ObjectSetInteger(0,"All",OBJPROP_STATE,false);
      if(sparam=="EUR")
         ObjectSetInteger(0,"All",OBJPROP_STATE,false);
      if(sparam=="GBP")
         ObjectSetInteger(0,"All",OBJPROP_STATE,false);
      if(sparam=="JPY")
         ObjectSetInteger(0,"All",OBJPROP_STATE,false);
      if(sparam=="AUD")
         ObjectSetInteger(0,"All",OBJPROP_STATE,false);
      if(sparam=="CAD")
         ObjectSetInteger(0,"All",OBJPROP_STATE,false);
      if(sparam=="NZD")
         ObjectSetInteger(0,"All",OBJPROP_STATE,false);
      if(sparam=="CHF")
         ObjectSetInteger(0,"All",OBJPROP_STATE,false);
         
      
      if(sparam=="All")
      {
         ObjectSetInteger(0,"USD",OBJPROP_STATE,false);
         ObjectSetInteger(0,"EUR",OBJPROP_STATE,false);
         ObjectSetInteger(0,"GBP",OBJPROP_STATE,false);
         ObjectSetInteger(0,"JPY",OBJPROP_STATE,false);
         ObjectSetInteger(0,"AUD",OBJPROP_STATE,false);
         ObjectSetInteger(0,"CAD",OBJPROP_STATE,false);
         ObjectSetInteger(0,"NZD",OBJPROP_STATE,false);
         ObjectSetInteger(0,"CHF",OBJPROP_STATE,false);
      }
      
      
      //there should be 8 if/else statements... one for each button
      if(ObjectGetInteger(0,"USD",OBJPROP_STATE)==false && ObjectGetInteger(0,"All",OBJPROP_STATE)==false) 
      {
         SetIndexStyle(0,DRAW_NONE);
      	SetIndexStyle(8,DRAW_NONE);
      	SetIndexStyle(16,DRAW_NONE);
      }
      else
      {
         if(showiRSILines)
            SetIndexStyle(0,DRAW_LINE,RSI_Style,RSI_Width,currencyColors[0]);
      	
      	if(showiMALines)
      		SetIndexStyle(8,DRAW_LINE,SMA_Style,SMA_Width,currencyColors[8]);
      	if(showHi_TF_RSI)
      		SetIndexStyle(16,DRAW_LINE,Hi_RSI_Style,Hi_RSI_Width,currencyColors[16]);	
      }
      
      if(ObjectGetInteger(0,"EUR",OBJPROP_STATE)==false && ObjectGetInteger(0,"All",OBJPROP_STATE)==false) 
      {
         SetIndexStyle(1,DRAW_NONE);
      	SetIndexStyle(9,DRAW_NONE);
      	SetIndexStyle(17,DRAW_NONE);
      }
      else
      {
         if(showiRSILines)
            SetIndexStyle(1,DRAW_LINE,RSI_Style,RSI_Width,currencyColors[1]);
      	
      	if(showiMALines)
      		SetIndexStyle(9,DRAW_LINE,SMA_Style,SMA_Width,currencyColors[9]);
      	if(showHi_TF_RSI)
      		SetIndexStyle(17,DRAW_LINE,Hi_RSI_Style,Hi_RSI_Width,currencyColors[17]);      		
      }
      
      if(ObjectGetInteger(0,"GBP",OBJPROP_STATE)==false && ObjectGetInteger(0,"All",OBJPROP_STATE)==false) 
      {
         SetIndexStyle(2,DRAW_NONE);
      	SetIndexStyle(10,DRAW_NONE);
      	SetIndexStyle(18,DRAW_NONE);
      }
      else
      {
         if(showiRSILines)
            SetIndexStyle(2,DRAW_LINE,RSI_Style,RSI_Width,currencyColors[2]);
      	
      	if(showiMALines)
      		SetIndexStyle(10,DRAW_LINE,SMA_Style,SMA_Width,currencyColors[10]);

      	if(showHi_TF_RSI)
      		SetIndexStyle(18,DRAW_LINE,Hi_RSI_Style,Hi_RSI_Width,currencyColors[18]);
      }
      
      if(ObjectGetInteger(0,"CHF",OBJPROP_STATE)==false && ObjectGetInteger(0,"All",OBJPROP_STATE)==false) 
      {
         SetIndexStyle(3,DRAW_NONE);
      	SetIndexStyle(11,DRAW_NONE);
      	SetIndexStyle(19,DRAW_NONE);
      }
      else
      {
         if(showiRSILines)
            SetIndexStyle(3,DRAW_LINE,RSI_Style,RSI_Width,currencyColors[3]);
      	
      	if(showiMALines)
      		SetIndexStyle(11,DRAW_LINE,SMA_Style,SMA_Width,currencyColors[11]);

      	if(showHi_TF_RSI)
      		SetIndexStyle(19,DRAW_LINE,Hi_RSI_Style,Hi_RSI_Width,currencyColors[19]);
      }
      
      if(ObjectGetInteger(0,"JPY",OBJPROP_STATE)==false && ObjectGetInteger(0,"All",OBJPROP_STATE)==false) 
      {
         SetIndexStyle(4,DRAW_NONE);
      	SetIndexStyle(12,DRAW_NONE);
      	SetIndexStyle(20,DRAW_NONE);
      }
      else
      {
         if(showiRSILines)
            SetIndexStyle(4,DRAW_LINE,RSI_Style,RSI_Width,currencyColors[4]);
      	
      	if(showiMALines)
      		SetIndexStyle(12,DRAW_LINE,SMA_Style,SMA_Width,currencyColors[12]);

      	if(showHi_TF_RSI)
      		SetIndexStyle(20,DRAW_LINE,Hi_RSI_Style,Hi_RSI_Width,currencyColors[20]);
      }
      
      if(ObjectGetInteger(0,"AUD",OBJPROP_STATE)==false && ObjectGetInteger(0,"All",OBJPROP_STATE)==false) 
      {
         SetIndexStyle(5,DRAW_NONE);
      	SetIndexStyle(13,DRAW_NONE);
      	SetIndexStyle(21,DRAW_NONE);
      }
      else
      {
         if(showiRSILines)
            SetIndexStyle(5,DRAW_LINE,RSI_Style,RSI_Width,currencyColors[5]);
      	
      	if(showiMALines)
      		SetIndexStyle(13,DRAW_LINE,SMA_Style,SMA_Width,currencyColors[13]);

      	if(showHi_TF_RSI)
      		SetIndexStyle(21,DRAW_LINE,Hi_RSI_Style,Hi_RSI_Width,currencyColors[21]);     
      }
      
      if(ObjectGetInteger(0,"CAD",OBJPROP_STATE)==false && ObjectGetInteger(0,"All",OBJPROP_STATE)==false) 
      {
         SetIndexStyle(6,DRAW_NONE);
      	SetIndexStyle(14,DRAW_NONE);
      	SetIndexStyle(22,DRAW_NONE);
      }
      else
      {
         if(showiRSILines)
            SetIndexStyle(6,DRAW_LINE,RSI_Style,RSI_Width,currencyColors[6]);
      	
      	if(showiMALines)
      		SetIndexStyle(14,DRAW_LINE,SMA_Style,SMA_Width,currencyColors[14]);

      	if(showHi_TF_RSI)
      		SetIndexStyle(22,DRAW_LINE,Hi_RSI_Style,Hi_RSI_Width,currencyColors[22]);
      }
      
      if(ObjectGetInteger(0,"NZD",OBJPROP_STATE)==false && ObjectGetInteger(0,"All",OBJPROP_STATE)==false) 
      {
         SetIndexStyle(7,DRAW_NONE);
      	SetIndexStyle(15,DRAW_NONE);
      	SetIndexStyle(23,DRAW_NONE);
      }
      else
      {
         if(showiRSILines)
            SetIndexStyle(7,DRAW_LINE,RSI_Style,RSI_Width,currencyColors[7]);
      	
      	if(showiMALines)
      		SetIndexStyle(15,DRAW_LINE,SMA_Style,SMA_Width,currencyColors[15]);

      	if(showHi_TF_RSI)
      		SetIndexStyle(23,DRAW_LINE,Hi_RSI_Style,Hi_RSI_Width,currencyColors[23]);
      }

   }//if(id==CHARTEVENT_OBJECT_CLICK)
   
}//OnChartEvent()

//END BUTTONS MODULE
///////////////////////////////////////////////////////////////////////////////////////////////////////////
