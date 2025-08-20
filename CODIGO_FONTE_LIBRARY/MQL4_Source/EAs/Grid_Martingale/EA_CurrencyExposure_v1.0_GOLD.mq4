//+------------------------------------------------------------------+
//|                                             CurrencyExposure.mq4 |
//|                                                         renexxxx |
//|                                http://www.flashwebdesign.com.au/ |
//| This indicator was developed by renexxxx from the                |
//|    http://www.stevehopwoodforex.com/ forum.                      |
//|                                                                  |
//| version 0.1   initial release (RZ)                               |
//|------------------------------------------------------------------+
#property copyright "renexxxx"
#property link      "http://www.flashwebdesign.com.au/"
#property version   "1.00"
#property strict
#property indicator_chart_window
#define screenFont   "tahoma"
#define objectPrefix "CE_"

//--- input parameters
input int           MagicNumber          = -1;
input int           RefreshSeconds       = 60;

struct CURRINFO {
   string currency;
   double buyLots;
   double sellLots;
};

int sorted[];         // To sort the indices in currencyInfo

CURRINFO currencyInfo[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   // Initialize Seed for Random Generator
   MathSrand( (uint)TimeLocal() );

   // Move the candles to the background   
   ChartSetInteger(ChartID(),CHART_FOREGROUND,false);
   
//---
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

   deleteAllObjects();

   ArrayFree(sorted);
   ArrayResize(sorted,0);
   
   ArrayFree(currencyInfo);
   ArrayResize(currencyInfo,0);
   
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
                const int &spread[]) {
//---
   static datetime timeForUpdate = -1;
   
   if ( timeForUpdate < TimeLocal() && isBasketOpen( MagicNumber ) ) {
   
      // Work out the exposure for each currency
      currencyExposure( MagicNumber, currencyInfo );
      
      // Print the exposure
      //for (int iInfo=0; iInfo < ArraySize(currencyInfo); iInfo++) {
      //   PrintFormat("[%s]: BUY Lots = %5.2f, SELL Lots = %5.2f", currencyInfo[iInfo].currency, currencyInfo[iInfo].buyLots, currencyInfo[iInfo].sellLots );
      //}
      
      // Sort the exposure in descending order of (buyLots-sellLots)
      sortExposure( currencyInfo, sorted );
            
      // Print the sorted exposure
      //for (int iInfo=0; iInfo < ArraySize(currencyInfo); iInfo++) {
      //   PrintFormat("[%s]: BUY Lots = %5.2f, SELL Lots = %5.2f", currencyInfo[sorted[iInfo]].currency, currencyInfo[sorted[iInfo]].buyLots, currencyInfo[sorted[iInfo]].sellLots );
      //}
      
      // Draw the exposure on the screen (right top corner)
      drawExposure( currencyInfo, sorted );

      // Do this again in RefreshSeconds-secs
      timeForUpdate = TimeLocal() + RefreshSeconds;
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+
//| isBasketOpen( int magic)                                         |
//|    -- returns true if there is trade open with given magic number|
//+------------------------------------------------------------------+
bool isBasketOpen( int magic ) {

   bool exists = false;
   int allOrders = OrdersTotal();
   
   for (int i = 0; i < allOrders; i++) {
      if (OrderSelect(i, SELECT_BY_POS)) {
         if ( ( (magic == -1) || ( OrderMagicNumber() == magic ) ) && ( (OrderType() == OP_BUY) || (OrderType() == OP_SELL) ) ) {
            exists = true;
            break;
         }
      }
   } // for
   return(exists);
}

//+------------------------------------------------------------------+
//| currencyExposure()                                               |
//|    -- finds open trades and fills the info array                 |
//+------------------------------------------------------------------+
void currencyExposure( int magic, CURRINFO &info[] ) {

   double lots;
   string baseCUR, quoteCUR;
   int allOrders = OrdersTotal();
   
   ArrayFree(info);
   ArrayResize(info,0);
   
   for (int i = 0; i < allOrders; i++) {
      if (OrderSelect(i, SELECT_BY_POS)) {
         if ( ( (magic == -1) || ( OrderMagicNumber() == magic ) ) && ( (OrderType() == OP_BUY) || (OrderType() == OP_SELL) ) ) {
            lots = OrderLots();
            baseCUR = StringSubstr(OrderSymbol(),0,3);
            quoteCUR = StringSubstr(OrderSymbol(),3,3);
            if (OrderType() == OP_BUY) {
               addExposure( info, baseCUR, lots, 0.0 );
               addExposure( info, quoteCUR, 0.0, lots );
            }
            else if ( OrderType() == OP_SELL) {
               addExposure( info, baseCUR, 0.0, lots );
               addExposure( info, quoteCUR, lots, 0.0 );
            }
         }
      }
   } // for
}

//+-------------------------------------------------------------------------------+
//| addExposure( CURRINFO &info[], string cur, double buyLots, double sellLots )  |
//|    -- add a new point to the info[] array                                     |
//+-------------------------------------------------------------------------------+
void addExposure( CURRINFO &info[], string cur, double buyLots, double sellLots ) {

   int index = findCurrency(info, cur);
   
   if ( index == -1 ) {                // Can't find cur::create a new element in info
      index = ArraySize(info);
      ArrayResize(info, index+1);
      info[index].currency = cur;
      info[index].buyLots = buyLots;
      info[index].sellLots = sellLots;
   }
   else {
      info[index].buyLots += buyLots;
      info[index].sellLots += sellLots;
   }
   
}

int findCurrency( CURRINFO &info[], string cur ) {

   int index = -1;
   
   for(int iInfo=0; iInfo < ArraySize(info); iInfo++) {
      if ( info[iInfo].currency == cur ) {
         index = iInfo;
         break;
      }
   }
   return(index);
}

void sortExposure(CURRINFO &info[], int &sort[] ) {

   int count = ArraySize(info);
   if ( count == 0) return;    // Nothing to do

   int tempID;

   ArrayFree(sort);
   ArrayResize(sort, count);
   for (int id=0; id < count; id++) sort[id] = id;

   for (int id1=0; id1 < count-1; id1++ ) {
      for ( int id2=id1+1; id2 < count; id2++ ) {
         if ( (info[sort[id1]].buyLots - info[sort[id1]].sellLots)  < (info[sort[id2]].buyLots - info[sort[id2]].sellLots) ) {
            tempID = sort[id1];
            sort[id1] = sort[id2];
            sort[id2] = tempID;
         } // if
      } // for
   } // for
}

void drawExposure(CURRINFO &info[], int &sort[] ) {

   int count = ArraySize(info);
   if ( count == 0) return;    // Nothing to do

   deleteAllObjects();

   int xPos = 80, yPos = 25;
   
   double highest = info[sort[0]].buyLots - info[sort[0]].sellLots;
   double lowest  = info[sort[count-1]].buyLots - info[sort[count-1]].sellLots;
   string cur;
   double exposure;
   color  boxColor, textColor;
   
   for (int iInfo=0; iInfo < count; iInfo++) {
   
      cur = info[sort[iInfo]].currency;
      exposure = info[sort[iInfo]].buyLots - info[sort[iInfo]].sellLots;
      
      boxColor = clrBlack;
      textColor = clrWhite;
      if ( exposure > 0.0 && highest > 0.0 ) {
         boxColor = valueToColor( exposure / highest );
         textColor = ( (exposure / highest) > 0.5 ) ? clrBlack : clrWhite;
      }
      else if ( exposure < 0.0 && lowest < 0.0 ) {
         boxColor = valueToColor( exposure / MathAbs(lowest) );
         textColor = ( (exposure / MathAbs(lowest) ) < -0.5 ) ? clrBlack : clrWhite;
      }
      
      RectLabelCreate( 0, objectPrefix + RandomString(5, 10), 0, xPos, yPos, 80,20,boxColor,BORDER_FLAT,CORNER_RIGHT_UPPER, boxColor );
      DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%s: %+5.2f", cur, exposure), xPos-72, yPos+2, textColor );
      
      yPos += 25;
   }
}

color valueToColor( double value ) {

   // Expect a value between -1.0 and +1.0
   color result = clrBlack;
   if ( value > 0.0 ) {
      if ( value > 1.0 ) {
         result = StringToColor( "0,255,0" );
      }
      else {
         result = StringToColor( StringFormat( "0,%d,0", (int)(value*255) ) );
      }
   }
   else {
      if ( value < -1.0 ) {
         result = StringToColor( "255,0,0" );
      }
      else {
         result = StringToColor( StringFormat( "%d,0,0", (int)MathAbs(value*255) ) );
      }
   }
   //PrintFormat("Value = %5.5f, Color = %s", value, ColorToString( result ) );
   return(result);
}

void deleteAllObjects() {

   for (int iObject=ObjectsTotal()-1; iObject >= 0; iObject--) {
      if ( StringFind( ObjectName(iObject), objectPrefix ) == 0 ) {
         ObjectDelete( ObjectName(iObject) );
      }
   }
}

//+------------------------------------------------------------------+
//| Create rectangle label                                           |
//+------------------------------------------------------------------+
bool RectLabelCreate(const long             chart_ID=0,               // chart's ID
                     const string           name="RectLabel",         // label name
                     const int              sub_window=0,             // subwindow index
                     const int              x=0,                      // X coordinate
                     const int              y=0,                      // Y coordinate
                     const int              width=50,                 // width
                     const int              height=18,                // height
                     const color            back_clr=C'0xA7,0xC9,0x42',  // background color
                     const ENUM_BORDER_TYPE border=BORDER_RAISED,     // border type
                     const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                     const color            clr=C'0x98,0xBF,0x21',    // flat border color (Flat)
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,        // flat border style
                     const int              line_width=1,             // flat border width
                     const bool             back=false,               // in the background
                     const bool             selection=false,          // highlight to move
                     const bool             hidden=true,              // hidden in the object list
                     const long             z_order=0)                // priority for mouse click
{
//--- reset the error value
   ResetLastError();
//--- create a rectangle label
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set label size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border type
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set flat border color (in Flat mode)
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set flat border line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set flat border width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
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
//| Create text object                                               |
//+------------------------------------------------------------------+
void DrawText( int nWindow, string nCellName, string nText, double nX, double nY, color nColor, int fontSize = 9, string font = screenFont ) {

   ObjectCreate( nCellName, OBJ_LABEL, nWindow, 0, 0);
   ObjectSetText( nCellName, nText, fontSize, font, nColor);
   ObjectSet( nCellName, OBJPROP_CORNER, CORNER_RIGHT_UPPER );
   ObjectSet( nCellName, OBJPROP_XDISTANCE, nX );
   ObjectSet( nCellName, OBJPROP_YDISTANCE, nY );
   ObjectSet( nCellName, OBJPROP_BACK, false);
}

//+------------------------------------------------------------------+
//| Generate a random  string                                        |
//+------------------------------------------------------------------+
string RandomString(int minLength, int maxLength) {

   if ((minLength > maxLength) || (minLength <= 0)) return("");
   
   string rstring = "";
   int strLen = RandomNumber( minLength, maxLength );
   
   for (int i=0; i<strLen; i++) {
      rstring = rstring + CharToStr( (uchar)RandomNumber( 97, 122 ) );
   }
   return(rstring);
}   

//+------------------------------------------------------------------+
//| Generate a random  number                                        |
//+------------------------------------------------------------------+
int RandomNumber(int low, int high) {

   if (low > high) return(-1);

   int number = low + (int)MathFloor(((MathRand() * (high-low)) / 32767));
   return(number);
}