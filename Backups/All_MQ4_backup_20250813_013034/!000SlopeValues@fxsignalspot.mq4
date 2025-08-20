//+------------------------------------------------------------------+
//|                                                  SlopeValues.mq4 |
//|                      Copyright 2012, Deltabron - Paul Geirnaerdt |
//|                                          http://www.deltabron.nl |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Deltabron - Paul Geirnaerdt"
#property link      "http://www.deltabron.nl"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_minimum 0.0
#property indicator_maximum 0.1

#define version            "v1.0.6"

//+------------------------------------------------------------------+
//| Release Notes                                                    |
//+------------------------------------------------------------------+
// v1.0.0, 6/28/12
// * Initial release
// v1.0.1, 7/6/12
// * Inserted ArrayIntialize before ArrayCopy, maybe corrects 'incorrect start...' errors
// v1.0.2, 7/13/12
// * Corrected for IBFX' Sunday candles
// v1.0.3, 7/16/12
// * Added option to display pivot order
// v1.0.4, 7/17/12
// * Split ranging column into two columns
// * Implemented caching mechanism for pivots
// v1.0.5, 7/23/12
// * Fixed Sunday candles bug
// v1.0.6, 10/25/12
// * Fixed bug if number of symbols < 10
// * Optimized code

#define EPSILON            0.00000001
#define CURRENCYCOUNT      8
#define COLUMNCOUNT        6

extern string  gen               = "----General inputs----";
extern bool    autoSymbols       = false;
extern string  symbolsToWeigh    = "GBPNZD,EURNZD,GBPAUD,GBPCAD,GBPJPY,GBPCHF,CADJPY,EURCAD,EURAUD,USDCHF,GBPUSD,EURJPY,NZDJPY,AUDCHF,AUDJPY,USDJPY,EURUSD,NZDCHF,CADCHF,AUDNZD,NZDUSD,CHFJPY,AUDCAD,USDCAD,NZDCAD,AUDUSD,EURCHF,EURGBP";

extern string  nonPropFont       = "Lucida Console";
extern int     fontSize          = 9;

extern string  ind               = "----Indicator inputs----";
extern bool    autoTimeFrame     = true;
extern string  ind_tf            = "timeFrame M1,M5,M15,M30,H1,H4,D1,W1,MN";
extern string  timeFrame         = "D1";
extern string  dir               = "Pivot direction: 0=follow order, 1=ascending, 2=descending";
extern bool    showPivotOrder    = true;
extern int     pivotDirection    = 2;
extern bool    showTrendIcon     = true;
extern bool    showLowerTimeFrame= true;
extern double  slopeLevel1       = 0.4;
extern double  slopeLevel2       = 0.8;
extern bool    addSundayToMonday = true;

extern string  col                     = "----Colo(u)rs----";
extern color   headerColor             = Yellow;
extern color   bodyColor               = Gold;
extern color   slopeOverLevel2Color    = Lime;
extern color   slopeOverLevel1Color    = Green;
extern color   slopeOver0Color         = Teal;
extern color   slopeUnder0Color        = HotPink;
extern color   slopeUnderLevel1Color   = DeepPink;
extern color   slopeUnderLevel2Color   = Red;
extern color   slopeLowerTFOver4Color  = 0x006000; // Very dark green
extern color   slopeLowerTFUnder4Color = 0x000060; // Very dark green

// global indicator variables
string indicatorName = "SlopeValues";
double mapBuffer[];
string shortName;
int userTimeFrame;
string almostUniqueIndex;
bool  sundayCandlesDetected;                          
double candleTime;

// symbol & currency variables
int symbolCount;
string symbolNames[];
double symbolValues[][7];                    // 0: Slope, 1: Index counter currency, 2: Index base currency, 3: Original index
double symbolValuesTemp[][7];                // 4: daily pivot, 5: weekly pivot, 6: monthly pivot
string pivotNames[4] = { "p", "D", "W", "M" };
double pivotValues[4][2];                          

// object parameters
int verticalShift = 14;
int verticalOffset = 30;
int verticalOffsetHeader = -8;
int verticalOffsetPivot = 10;
int horizontalShift = 100;
int horizontalOffset = 10;
int horizontalOffsetTrend = 85;
int horizontalOffsetHeader = 32;

// grid variables
int row[CURRENCYCOUNT];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   // Global indicator settings
   shortName = indicatorName + " - " + version;
   IndicatorShortName ( shortName );
   SetIndexBuffer ( 0, mapBuffer );
   SetIndexStyle ( 0, DRAW_NONE );
   IndicatorDigits ( 0 );
   SetIndexEmptyValue ( 0, 0.0 );
   
   // Get the symbols to use
   initSymbols();
   
   // Set almostUniqueIndex to use in object names, not crucial
   string now = TimeCurrent();
   almostUniqueIndex = StringSubstr(now, StringLen(now) - 3) + WindowsTotal();
   
   // Font & object scaling & shifting
   switch (fontSize)
   {
      case 8:
         horizontalShift = 106;
         horizontalOffsetHeader = 40;
         horizontalOffsetTrend = 84;
         if ( showPivotOrder )
         {
            verticalShift = 20;
            verticalOffset = 24;
            verticalOffsetHeader = -2;
            verticalOffsetPivot = 10;
         }
         break;
      case 9:    
         horizontalShift = 110;
         horizontalOffsetHeader = 36;
         horizontalOffsetTrend = 85;
         if ( showPivotOrder )
         {
            verticalShift = 20;
            verticalOffset = 24;
            verticalOffsetHeader = -2;
            verticalOffsetPivot = 10;
         }
         break;
      case 10:    
         horizontalShift = 120;
         horizontalOffsetHeader = 46;
         horizontalOffsetTrend = 96;
         if ( showPivotOrder )
         {
            verticalShift = 21;
            verticalOffset = 24;
            verticalOffsetHeader = -2;
            verticalOffsetPivot = 11;
         }
         break;
      case 11:    
         horizontalShift = 132;
         horizontalOffsetHeader = 54;
         horizontalOffsetTrend = 109;
         if ( showPivotOrder )
         {
            verticalShift = 26;
            verticalOffset = 24;
            verticalOffsetHeader = -2;
            verticalOffsetPivot = 13;
         }
         break;
      case 12:    
         horizontalShift = 146;
         horizontalOffsetHeader = 60;
         horizontalOffsetTrend = 122;
         if ( showPivotOrder )
         {
            verticalShift = 26;
            verticalOffset = 24;
            verticalOffsetHeader = -2;
            verticalOffsetPivot = 14;
         }
         break;
      default: 
         horizontalShift = 100 + (10 * (fontSize - 9));
         horizontalOffsetHeader = 60;
         horizontalOffsetTrend = 85 + (12 * (fontSize - 9));
         break;
   }      
   
   sundayCandlesDetected = false;
   for ( int i = 0; i < 8; i++ )
   {
      if ( TimeDayOfWeek( iTime( NULL, PERIOD_D1, i ) ) == 0 )
      {
         sundayCandlesDetected = true;
         break;
      }
   }
   
   candleTime = 0;

   return(0);
}

//+------------------------------------------------------------------+
//| Initialize Symbols Array                                         |
//+------------------------------------------------------------------+
int initSymbols()
{
   int i;
   string symbolExtraChars = StringSubstr(Symbol(), 6, 4);

   symbolsToWeigh = StringTrimLeft(symbolsToWeigh);
   symbolsToWeigh = StringTrimRight(symbolsToWeigh);

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
      i = StringFind(symbolsToWeigh, ","); 
      while (i != -1)
      {
         // Resize array
         int size = ArraySize(symbolNames);
         ArrayResize(symbolNames, size + 1);
         // Set array
         symbolNames[size] = StringConcatenate(StringSubstr(symbolsToWeigh, 0, i), symbolExtraChars);
         // Trim symbols
         symbolsToWeigh = StringSubstr(symbolsToWeigh, i + 1);
         i = StringFind(symbolsToWeigh, ","); 
      }
   }
   
   symbolCount = ArraySize(symbolNames);
   ArrayResize(symbolValues, symbolCount);
   ArrayResize(symbolValuesTemp, symbolCount);
   
   // Build symbolValues and currencyOccurrences arrays
   for ( i = 0; i < symbolCount; i++ )   
   {
      symbolValues[i][3] = i;
   }
   
   userTimeFrame = PERIOD_D1;
   if ( autoTimeFrame )
   {
      userTimeFrame = Period();
   }
   else
   {   
		if ( timeFrame == "M1" )       userTimeFrame = PERIOD_M1;
		else if ( timeFrame == "M5" )  userTimeFrame = PERIOD_M5;
		else if ( timeFrame == "M15" ) userTimeFrame = PERIOD_M15;
		else if ( timeFrame == "M30" ) userTimeFrame = PERIOD_M30;
		else if ( timeFrame == "H1" )  userTimeFrame = PERIOD_H1;
		else if ( timeFrame == "H4" )  userTimeFrame = PERIOD_H4;
		else if ( timeFrame == "D1" )  userTimeFrame = PERIOD_D1;
		else if ( timeFrame == "W1" )  userTimeFrame = PERIOD_W1;
		else if ( timeFrame == "MN" )  userTimeFrame = PERIOD_MN1;
	}
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
   return ( 0 );
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   int windex = WindowFind ( shortName );
   if ( windex > 0 )
   {
      ObjectsDeleteAll ( windex );
   }   

   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   // initialize variables for this tick
   int i;
   int index;
   int windex = WindowFind ( shortName );
   string objectName;
   string showText;

   for ( i = 0; i < CURRENCYCOUNT; i++ )
   {
      // Array row is a helper to store last used row for all columns
      row[i] = 0;
   }
   
   // Here we go!
   // Copy symbolValues to symbolValuesTemp
   ArrayInitialize(symbolValuesTemp, 0.0);
   ArrayCopy(symbolValuesTemp, symbolValues);

   // Get Slope for all symbols and totalize for all currencies   
   for ( i = 0; i < symbolCount; i++)
   {
      // Get Slope for original index
      index = symbolValuesTemp[i][3];
      symbolValuesTemp[i][0] = GetSlope(symbolNames[index], userTimeFrame, 0);
   }
   // Sort symbols to Slope
   ArraySort(symbolValuesTemp, WHOLE_ARRAY, 0, MODE_DESCEND);
   
   //
   // COLUMN HEADERS
   //
   // Loop currency values and header output objects, creating them if necessary 
   for ( i = 0; i < COLUMNCOUNT; i++ )
   {
      objectName = "SV_" + almostUniqueIndex + "_obj_header_" + i;
      if ( ObjectFind ( objectName ) == -1 )
      {
         if ( ObjectCreate ( objectName, OBJ_LABEL, windex, 0, 0 ) )
         {
            ObjectSet ( objectName, OBJPROP_XDISTANCE, horizontalShift * i + horizontalOffset );
            ObjectSet ( objectName, OBJPROP_YDISTANCE, verticalOffset + verticalOffsetHeader );
         }
      }
      switch ( i )
      {
         case 0: showText = "> " + DoubleToStr(slopeLevel2, 1); break;
         case 1: showText = "> " + DoubleToStr(slopeLevel1, 1); break;
         case 2: showText = "Ranging"; break;
         case 3: showText = ""; break;
         case 4: showText = "< " + DoubleToStr(-slopeLevel1, 1); break;
         case 5: showText = "< " + DoubleToStr(-slopeLevel2, 1); break;
      }   
      ObjectSetText ( objectName, showText, fontSize + 3, nonPropFont, headerColor );
   }
   
   //
   // GRID SYMBOL OBJECTS
   //
   // Loop Slope values and set output objects, creating them if necessary 
   for ( i = 0; i < symbolCount; i++ )
   {
      // Get original index
      index = symbolValuesTemp[i][3];
      // Determine column
      int col = 0;
      if ( symbolValuesTemp[i][0] > slopeLevel2 ) col = 0;
      else if ( symbolValuesTemp[i][0] > slopeLevel1 ) col = 1;
      else if ( symbolValuesTemp[i][0] > 0 ) col = 2;
      else if ( symbolValuesTemp[i][0] > -slopeLevel1 ) col = 3;
      else if ( symbolValuesTemp[i][0] > -slopeLevel2 ) col = 4;
      else col = 5;
      // Build object name and create if necessary
      objectName = "SV_" + almostUniqueIndex + "_obj_" + row[col] + "_" + col;
      if ( ObjectFind ( objectName ) == -1 )
      {
         if ( ObjectCreate ( objectName, OBJ_LABEL, windex, 0, 0 ) )
         {
            ObjectSet ( objectName, OBJPROP_XDISTANCE, horizontalShift * col + horizontalOffset );
            ObjectSet ( objectName, OBJPROP_YDISTANCE, verticalShift * (row[col] + 1) + verticalOffset );
         }
      }
      // Build text to show
      showText = StringSubstr(symbolNames[index], 0, 6);
      showText = showText + RightAlign(DoubleToStr(symbolValuesTemp[i][0], 2), 6);

      // Determine color to show
      color showColor = slopeUnderLevel2Color;
      if ( symbolValuesTemp[i][0] > -slopeLevel2 ) showColor = slopeUnderLevel1Color;
      if ( symbolValuesTemp[i][0] > -slopeLevel1 ) showColor = slopeUnder0Color;
      if ( symbolValuesTemp[i][0] > 0.0 ) showColor = slopeOver0Color;
      if ( symbolValuesTemp[i][0] > slopeLevel1 ) showColor = slopeOverLevel1Color;
      if ( symbolValuesTemp[i][0] > slopeLevel2 ) showColor = slopeOverLevel2Color;

      // Show object      
      ObjectSetText ( objectName, showText, fontSize, nonPropFont, showColor );

      // Show pivot order
      if ( showPivotOrder )
      {
         objectName = "SV_" + almostUniqueIndex + "_obj_" + row[col] + "_" + col + "_pivots";
         if ( ObjectFind ( objectName ) == -1 )
         {
            if ( ObjectCreate ( objectName, OBJ_LABEL, windex, 0, 0 ) )
            {
               ObjectSet ( objectName, OBJPROP_XDISTANCE, horizontalShift * col + horizontalOffset );
               ObjectSet ( objectName, OBJPROP_YDISTANCE, verticalShift * (row[col] + 1) + verticalOffset + verticalOffsetPivot );
            }
         }
         showText = GetPivotOrder(symbolNames[index], symbolValuesTemp[i][0], index);
         // Show object      
         ObjectSetText ( objectName, showText, fontSize - 3, nonPropFont, showColor );
      }

      // Show trend arrow if user wants it.
      if ( showTrendIcon )
      {
         objectName = "SV_" + almostUniqueIndex + "_obj_" + row[col] + "_" + col + "_delta";
         if ( ObjectFind ( objectName ) == -1 )
         {
            if ( ObjectCreate ( objectName, OBJ_LABEL, windex, 0, 0 ) )
            {
               ObjectSet ( objectName, OBJPROP_XDISTANCE, horizontalShift * col + horizontalOffset + horizontalOffsetTrend );
               ObjectSet ( objectName, OBJPROP_YDISTANCE, verticalShift * (row[col] + 1) + verticalOffset );
            }
         }
         // Get past slope values for symbols
         double Slope[3];
         Slope[0] = GetSlope ( symbolNames[index], userTimeFrame, 5 );
         Slope[1] = GetSlope ( symbolNames[index], userTimeFrame, 2 );
         Slope[2] = symbolValuesTemp[i][0];
         // Define which arrow to use
         showText = CharToStr ( 224 );
         if ( Slope[0] < Slope[1] && Slope[1] < Slope[2] ) showText = CharToStr ( 225 );
         else if ( Slope[0] > Slope[1] && Slope[0] < Slope[2] ) showText = CharToStr ( 228 );
         else if ( Slope[0] < Slope[1] && Slope[0] > Slope[2] ) showText = CharToStr ( 230 );
         else if ( Slope[0] > Slope[1] && Slope[1] > Slope[2] ) showText = CharToStr ( 226 );
         // Show object      
         ObjectSetText ( objectName, showText, 6, "Wingdings", showColor );
      }
      
      // Show lower timeframe as bullet
      if ( showLowerTimeFrame && userTimeFrame != PERIOD_M1 )
      {
         // Get slope for immediate lower time frame
         int lowerTimeFrame = 0;
		   if ( userTimeFrame == PERIOD_M5 ) lowerTimeFrame = PERIOD_M1;
		   else if ( userTimeFrame == PERIOD_M15 ) lowerTimeFrame = PERIOD_M5;
		   else if ( userTimeFrame == PERIOD_M30 ) lowerTimeFrame = PERIOD_M15;
		   else if ( userTimeFrame == PERIOD_H1 ) lowerTimeFrame = PERIOD_M30;
		   else if ( userTimeFrame == PERIOD_H4 ) lowerTimeFrame = PERIOD_H1;
		   else if ( userTimeFrame == PERIOD_D1 ) lowerTimeFrame = PERIOD_H4;
		   else if ( userTimeFrame == PERIOD_W1 ) lowerTimeFrame = PERIOD_D1;
		   else if ( userTimeFrame == PERIOD_MN1 ) lowerTimeFrame = PERIOD_W1;

         double slopeLowerTimeframe = GetSlope ( symbolNames[index], lowerTimeFrame, 0 );
         // Set color for bullet
         showColor = CLR_NONE;
         if ( slopeLowerTimeframe > slopeLevel1 )
         {
            showColor = slopeLowerTFOver4Color;
         }
         else if ( slopeLowerTimeframe < -slopeLevel1 )
         {
            showColor = slopeLowerTFUnder4Color;
         }
         // Show bullet
         if ( showColor != CLR_NONE )
         {
            objectName = "SV_" + almostUniqueIndex + "_obj_" + row[col] + "_" + col + "_background";
            DrawBullet(windex, objectName, horizontalShift * col + horizontalOffset + horizontalOffsetTrend + 8, verticalShift * (row[col] + 1) + verticalOffset - 2, showColor);
         }   
      }
      
      //---- remove lines
      int nextRow = row[col] + 1;
      while ( ObjectFind( "SV_" + almostUniqueIndex + "_obj_" + nextRow + "_" + col ) > -1 )
      {
         ObjectDelete ( "SV_" + almostUniqueIndex + "_obj_" + nextRow + "_" + col );
         ObjectDelete ( "SV_" + almostUniqueIndex + "_obj_" + nextRow + "_" + col + "_pivots" );
         ObjectDelete ( "SV_" + almostUniqueIndex + "_obj_" + nextRow + "_" + col + "_delta" );
         ObjectDelete ( "SV_" + almostUniqueIndex + "_obj_" + nextRow + "_" + col + "_background" );
         nextRow++;
      }

      // Increase row for this column
      row[col]++;
   }

   return(0);
}

//+------------------------------------------------------------------+
//| GetSlope()                                                       |
//+------------------------------------------------------------------+
double GetSlope(string symbol, int tf, int shift)
{
   int shiftWithoutSunday = shift;
   if ( addSundayToMonday && sundayCandlesDetected && tf == PERIOD_D1 )
   {
      if ( TimeDayOfWeek( iTime( symbol, PERIOD_D1, shift ) ) == 0  ) shiftWithoutSunday++;
   }   
   double atr = iATR(symbol, tf, 100, shiftWithoutSunday + 10) / 10;
   double gadblSlope = 0.0;
   if ( atr != 0 )
   {
      double dblTma = calcTmaTrue( symbol, tf, shiftWithoutSunday );
      double dblPrev = calcPrevTrue( symbol, tf, shiftWithoutSunday );
      gadblSlope = ( dblTma - dblPrev ) / atr;
   }
   
   return ( gadblSlope );

}//End double GetSlope(int tf, int shift)

//+------------------------------------------------------------------+
//| calcTmaTrue()                                                    |
//+------------------------------------------------------------------+
double calcTmaTrue( string symbol, int tf, int inx )
{
   // return ( iMA( symbol, tf, 21, 0, MODE_LWMA, PRICE_CLOSE, inx ) );

   double dblSum  = 0;
   double dblSumw = 0;
   int jnx, knx;
   int sundayCandles = 0;

   for ( jnx = 0, knx = 21; jnx < 21; jnx++, knx-- )
   {
      if ( addSundayToMonday && sundayCandlesDetected && tf == PERIOD_D1 )
      {
         if ( TimeDayOfWeek( iTime( symbol, PERIOD_D1, inx + jnx + sundayCandles ) ) == 0 ) sundayCandles++;
      }   
      dblSum  += iClose( symbol, tf, inx + jnx + sundayCandles ) * knx;
      dblSumw += knx;
   }
   
   return ( dblSum / dblSumw );
}

//+------------------------------------------------------------------+
//| calcPrevTrue()                                                   |
//+------------------------------------------------------------------+
double calcPrevTrue( string symbol, int tf, int inx )
{
   double dblSum  = iClose( symbol, tf, inx ) * 20;
   double dblSumw = 20;
   int jnx, knx;
   int sundayCandles = 0;
   
   for ( jnx = 1, knx = 21; jnx < 22; jnx++, knx-- )
   {
      if ( addSundayToMonday && sundayCandlesDetected && tf == PERIOD_D1 )
      {
         if ( TimeDayOfWeek( iTime( symbol, PERIOD_D1, inx + jnx + sundayCandles ) ) == 0 ) sundayCandles++;
      }   
      dblSum  += iClose( symbol, tf, inx + jnx + sundayCandles ) * knx;
      dblSumw += knx;
   }
   
   return ( dblSum / dblSumw );
}

//+------------------------------------------------------------------+
//| GetPivotOrder                                                    |
//+------------------------------------------------------------------+
string GetPivotOrder(string symbol, double slope, int symbolIndex)
{
   int i, index;
   int pivotBar;
   double lastHigh, lastLow, lastClose;
   string pivotOrder;
   
   ArrayInitialize( pivotValues, 0.0 );
   for ( i = 0; i < 4; i++ ) pivotValues[i][1] = i;
   
   pivotValues[0][0] = MarketInfo( symbol, MODE_BID );
   pivotValues[1][0] = symbolValues[symbolIndex][4];
   pivotValues[2][0] = symbolValues[symbolIndex][5];
   pivotValues[3][0] = symbolValues[symbolIndex][6];
   
   datetime currentTime = iTime( symbol, PERIOD_D1, 0 ); 
   
   // Calculate pivots once a day only
   if ( currentTime != candleTime )
   {
      // Daily
      pivotBar = iBarShift ( symbol, PERIOD_D1, currentTime ) + 1;

      if ( addSundayToMonday && sundayCandlesDetected )
      {
         if ( TimeDayOfWeek( iTime( symbol, PERIOD_D1, pivotBar ) ) == 0 )
         {
            // Sunday, shift to friday
            pivotBar++;
         }
      }   

      // Weekday
      lastLow = iLow ( symbol, PERIOD_D1, pivotBar );
      lastHigh = iHigh ( symbol, PERIOD_D1, pivotBar );
      lastClose = iClose ( symbol, PERIOD_D1, pivotBar );

      if ( addSundayToMonday && sundayCandlesDetected )
      {
         if ( TimeDayOfWeek( iTime( symbol, PERIOD_D1, pivotBar ) ) == 1 )
         {
            // Monday, add Sunday
            lastLow = MathMin( iLow ( symbol, PERIOD_D1, pivotBar ), iLow ( symbol, PERIOD_D1, pivotBar + 1 ) );
            lastHigh = MathMax( iHigh ( symbol, PERIOD_D1, pivotBar ), iHigh ( symbol, PERIOD_D1, pivotBar + 1 ) );
         }
      }

      pivotValues[1][0] = ( lastHigh + lastLow + lastClose ) / 3;
      symbolValues[symbolIndex][4] = pivotValues[1][0];

      // Weekly
      pivotBar = iBarShift ( symbol, PERIOD_W1, currentTime );
      lastLow = iLow ( symbol, PERIOD_W1, pivotBar + 1 );
      lastHigh = iHigh ( symbol, PERIOD_W1, pivotBar + 1 );
      lastClose = iClose ( symbol, PERIOD_W1, pivotBar + 1 );

      pivotValues[2][0] = ( lastHigh + lastLow + lastClose ) / 3;
      symbolValues[symbolIndex][5] = pivotValues[2][0];

      // Monthly
      pivotBar = iBarShift ( symbol, PERIOD_MN1, currentTime );
      lastLow = iLow ( symbol, PERIOD_MN1, pivotBar + 1 );
      lastHigh = iHigh ( symbol, PERIOD_MN1, pivotBar + 1 );
      lastClose = iClose ( symbol, PERIOD_MN1, pivotBar + 1 );
   
      pivotValues[3][0] = ( lastHigh + lastLow + lastClose ) / 3;
      symbolValues[symbolIndex][5] = pivotValues[3][0];
   }

   switch ( pivotDirection )
   {
      case 0:
         if ( slope > 0 )
            ArraySort(pivotValues, WHOLE_ARRAY, 0, MODE_ASCEND);
         else   
            ArraySort(pivotValues, WHOLE_ARRAY, 0, MODE_DESCEND);
         break;
      case 1:
         ArraySort(pivotValues, WHOLE_ARRAY, 0, MODE_ASCEND);
         break;
      case 2:
         ArraySort(pivotValues, WHOLE_ARRAY, 0, MODE_DESCEND);
         break;
      default:
         ArraySort(pivotValues, WHOLE_ARRAY, 0, MODE_DESCEND);
         break;
   }

   // Build pivot order string   
   for ( i = 0; i < 4; i++ )
   {
      index = pivotValues[i][1];
      // Print(symbol, " ", i, " ", index);
      pivotOrder = StringConcatenate( pivotOrder, pivotNames[index] );
   }
   
   // Check quality
   if ( slope > 0 )
      ArraySort(pivotValues, WHOLE_ARRAY, 0, MODE_ASCEND);
   else   
      ArraySort(pivotValues, WHOLE_ARRAY, 0, MODE_DESCEND);

   string pivotQuality;
   for ( i = 0; i < 4; i++ )
   {
      index = pivotValues[i][1];
      if ( index == 0 ) continue;
      pivotQuality = StringConcatenate( pivotQuality, pivotNames[index] );
   }
   
   if ( pivotQuality == "MWD" ) pivotOrder = StringConcatenate( pivotOrder, " ++" );
   if ( pivotQuality == "MDW" ) pivotOrder = StringConcatenate( pivotOrder, " +" );
   
   return ( pivotOrder );
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

//+------------------------------------------------------------------+
//| DrawBullet()                                                     |
//+------------------------------------------------------------------+
void DrawBullet(int window, string cellName, int col, int row, color bulletColor )
{
   ObjectCreate   ( cellName, OBJ_LABEL, window, 0, 0 );
   ObjectSetText  ( cellName, CharToStr ( 108 ), 9, "Wingdings", bulletColor );
   ObjectSet      ( cellName, OBJPROP_XDISTANCE, col );
   ObjectSet      ( cellName, OBJPROP_YDISTANCE, row );
   ObjectSet      ( cellName, OBJPROP_BACK, true );
}

//+------------------------------------------------------------------+