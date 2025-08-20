//+------------------------------------------------------------------+
//|                                                  TradeReport.mq4 |
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
#define objectPrefix "TR_"
#define UP 1
#define FLAT 0
#define DOWN -1
#define INF     0x6FFFFFFF

enum REPORT_TYPE {
   OPEN ,             // List only OPEN orders
   CLOSED,            // List only CLOSED orders
   BOTH               // List both OPEN and CLOSED orders
};

enum GROUP_BY {
   SYMBOL,            // Collate results by Symbol
   MAGIC,             // Collate results by Magic Number
   COMMENT            // Collate results by Comment
};

struct COLOR_SCHEME {
   color  tableBorderColor     ;
   color  tableHeadBackColor   ;
   color  tableHeadTextColor   ;
   color  tableRowBackColor    ;
   color  tableAltRowBackColor ;
   color  tableRowTextColor    ;
};

static COLOR_SCHEME myColorScheme[]   = { { clrWhite, C'62,62,62', clrWhite, clrIvory, clrLemonChiffon, clrBlack },
                                           { C'0xEE,0xE8,0xD5', C'0x00,0x2B,0x36', clrWhite, C'0xFD,0xF6,0xE3', C'0xEE,0xE8,0xD5', C'0x00,0x2B,0x36' },
                                           { C'0x19,0x8A,0x8A', C'0x00,0x4A,0x4A', clrWhite, C'0x47,0xB8,0xB8', C'0x19,0x8A,0x8A',clrWhite },
                                           { C'0xCC,0x33,0x99', C'0x95,0x23,0x71', clrWhite, C'0x33,0x33,0x33', C'0x66,0x66,0x66',clrWhite },
                                           { C'0x3A,0x3A,0x3A', clrBlack, clrWhite, C'0xDD,0xDD,0xDD', C'0xCC,0xCC,0xCC',clrBlack } };

enum SCHEME_CHOICE {
   BEIGE           ,
   SOLARIZED       ,
   TURQUOISE       ,
   MAGENTA         ,
   BLACKNWHITE
};

enum DATE_CHOICE {
   TODAY,           // Just Today's Trades
   THIS_WEEK,       // Just This Week's Trades
   THIS_MONTH,      // Just This Month's Trades
   CUSTOM           // Custom Dates
};

datetime startDate;
datetime endDate;
   
//--- input parameters
input int           MagicNumber          = -1;
input string        CommentFilter        = "";
input string        SymbolFilter         = "";     // CSV list of symbols to include
input string        CurrencyFilter       = "";     // CSV list of currencies to include
input DATE_CHOICE   DateChoice           = CUSTOM;
input datetime      StartDate            = D'2017.01.01 00:00';
input datetime      EndDate              = D'2019.12.31 23:59';
input int           RefreshMinutes       = 5;
input REPORT_TYPE   reportType           = CLOSED;
input GROUP_BY      groupBy              = SYMBOL;
input SCHEME_CHOICE colorScheme          = TURQUOISE;
input int           xOffset              = 10;
input int           yOffset              = 5;

// To hold the columns of the table
struct COLUMN {
   string name;
   int    width;
   int    sortDir;
};

// To hold the OrderInfo
struct ORDERINFO {
   string symbol;
   int    magic;
   string comment;
   int    nrOfTrades;
   int    nrOfBuyTrades;
   int    nrOfSellTrades;
   double totalLots;
   double buyLots;
   double sellLots;
   double profit;
   double loss;
   double nettPL;
   double nettPIPs;
};

COLUMN    columns[];
ORDERINFO orderInfo[];
ORDERINFO orderTotal;

int sorted[];           // Contains indices of orderInfo in sorted order

int sortedCol   = -1;
int sortedDir   = -1;

string IncludeCurrencies[];
string IncludeSymbols[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   // Initialize Columns
   InitColumns( columns );

   // Initialize Seed for Random Generator
   MathSrand( (uint)TimeLocal() );

   // Move the candles to the background   
   ChartSetInteger(ChartID(),CHART_FOREGROUND,false);

   // Set the startDate and endDate
   startDate = StartDate;
   endDate   = EndDate;
   if ( DateChoice == TODAY ) {
      startDate = iTime( Symbol(), PERIOD_D1, 0 );
      endDate   = startDate + PERIOD_D1*60;
   }
   else if ( DateChoice == THIS_WEEK ) {
      startDate = iTime( Symbol(), PERIOD_W1, 0 );
      endDate   = startDate + PERIOD_W1*60;
   }
   else if ( DateChoice == THIS_MONTH ) {
      startDate = iTime( Symbol(), PERIOD_MN1, 0 );
      MqlDateTime nextMonth;
      TimeToStruct( startDate, nextMonth );
      if ( nextMonth.mon == 12 ) { 
         nextMonth.mon = 1;
         nextMonth.year++;
      }
      else {
         nextMonth.mon++;
      }
      endDate = StructToTime( nextMonth );
   }
   
   // Get the SymbolFilter into an array
   ArrayResize(IncludeSymbols,0);
   convertCSV(SymbolFilter,IncludeSymbols);
   //PrintFormat( "Symbols Included: %s", convertArray(IncludeSymbols,";") );
   
   
   // Get the CurrencyFilter into an array
   ArrayResize(IncludeCurrencies,0);
   convertCSV(CurrencyFilter,IncludeCurrencies);
   //PrintFormat( "Currencies Included: %s", convertArray(IncludeCurrencies,";") );

   EventSetTimer(RefreshMinutes*60);               // Do this every RefreshMinutes-mins
   OnTimer();
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

   deleteAllObjects();

   ArrayFree(sorted);
   ArrayResize(sorted,0);
   
   ArrayFree(columns);
   ArrayResize(columns,0);
   
   ArrayFree(orderInfo);
   ArrayResize(orderInfo,0);
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
   //--- return value of prev_calculated for next call
   return(rates_total);
}

void InitColumns( COLUMN &cols[] ) {

   ArrayFree(cols);
   ArrayResize(cols, 11);
   
   cols[0].name    = ( groupBy == SYMBOL ) ? "Symbol" : ( groupBy == MAGIC ) ? "Magic" : ( groupBy == COMMENT ) ? "Comment" : "";
   cols[0].width   =  70;
   cols[0].sortDir =  FLAT;
   
   cols[1].name    = "Trades";
   cols[1].width   =  50;
   cols[1].sortDir =  FLAT;

   cols[2].name    = "Buys";
   cols[2].width   =  50;
   cols[2].sortDir =  FLAT;

   cols[3].name    = "Sells";
   cols[3].width   =  50;
   cols[3].sortDir =  FLAT;

   cols[4].name    = "Lots";
   cols[4].width   =  50;
   cols[4].sortDir =  FLAT;

   cols[5].name    = "Buy Lots";
   cols[5].width   =  70;
   cols[5].sortDir =  FLAT;

   cols[6].name    = "Sell Lots";
   cols[6].width   =  70;
   cols[6].sortDir =  FLAT;

   cols[7].name    = "Profit";
   cols[7].width   =  70;
   cols[7].sortDir =  FLAT;

   cols[8].name    = "Loss";
   cols[8].width   =  70;
   cols[8].sortDir =  FLAT;
   
   cols[9].name    = "Nett P/L";
   cols[9].width   =  70;
   cols[9].sortDir =  FLAT;

   cols[10].name    = "Nett PIPs";
   cols[10].width   =  70;
   cols[10].sortDir =  FLAT;
   
}

void AutoSizeFirstColumn( COLUMN &cols[], ORDERINFO &info[] ) {

   int colSize = cols[0].width;       // Default width
   
   int maxSize = -1;
   string elem = "";
   for ( int iRow=0; iRow < ArraySize(info); iRow++ ) {
      switch(groupBy) {
         case SYMBOL  : elem = info[iRow].symbol;break;
         case MAGIC   : elem = StringFormat("%d", info[iRow].magic );break;
         case COMMENT : elem = info[iRow].comment;break;
      }
      maxSize = ( StringLen(elem) > maxSize ) ? StringLen(elem) : maxSize;
   }
   cols[0].width = ( maxSize * 8 > colSize ) ? maxSize * 8 : colSize;
}

void GetOrderInfo( ORDERINFO &info[] ) {

   double pipFactor;
   double lastPrice, profit;
   string mysymbol;
   int myMagic;
   string myComment;
   int index;
   
   int totalOrders;
   int selectMode;

   // Reset info array
   ArrayFree(info);
   ArrayResize(info,0);
   
   // Reset totals
   orderTotal.nrOfTrades      = 0;
   orderTotal.nrOfBuyTrades   = 0;
   orderTotal.nrOfSellTrades  = 0;
   orderTotal.totalLots       = 0.0;
   orderTotal.buyLots         = 0.0;
   orderTotal.sellLots        = 0.0;
   orderTotal.profit          = 0.0;
   orderTotal.loss            = 0.0;
   orderTotal.nettPL          = 0.0;
   orderTotal.nettPIPs        = 0.0;

   for ( REPORT_TYPE myReportType=OPEN; myReportType <= CLOSED; myReportType++ ) {
   
      if ( ( (reportType == OPEN) || (reportType == BOTH) ) && ( myReportType == OPEN ) ) {
         totalOrders = OrdersTotal();
         selectMode  = MODE_TRADES;
      }
      else if ( ( (reportType == CLOSED) || (reportType == BOTH) ) && ( myReportType == CLOSED ) ) {
         totalOrders = OrdersHistoryTotal();
         selectMode  = MODE_HISTORY;
      }
      else {
         continue;
      }
   
      for (int iOrder=totalOrders-1; iOrder >= 0; iOrder-- ) {
   
         //---- check selection result
         if ( !OrderSelect(iOrder, SELECT_BY_POS, selectMode) ) {
            Print("Access to order cursor failed with error (",GetLastError(),")");
            break;
         }
         //---- Don't include orders, if their magic number does not match the requested magic number
         if ( (MagicNumber != -1) && ( OrderMagicNumber() != MagicNumber ) ) continue;
         
         //---- Don't include orders, if there is an CommentFilter and the OrderComment() does not match the filter
         if ( (CommentFilter != "") && ( StringFind( OrderComment(), CommentFilter ) == -1 ) ) continue;
         
         //---- Don't include orders, if IncludeSymbols is a non-empty array and the OrderSymbol() is not included
         if ( (ArraySize(IncludeSymbols) > 0) && ( findInStringArray(IncludeSymbols, StringSubstr(OrderSymbol(),0,6)) < 0 ) ) continue;
         
         //---- Don't include orders, if IncludeCurrencies is a non-empty array, neither base nor quote currency of OrderSymbol() is included
         if ( (ArraySize(IncludeCurrencies) > 0) && ( findInStringArray(IncludeCurrencies, StringSubstr(OrderSymbol(),0,3)) < 0 ) && ( findInStringArray(IncludeCurrencies, StringSubstr(OrderSymbol(),3,3)) < 0 ) ) continue;

         //---- Don't include orders, other than BUYs and SELLs
         if ( (OrderType() != OP_BUY) && (OrderType() != OP_SELL) ) continue;
         
         //---- For the CLOSED reportType, only include orders if they were closed inside the requested data range
         if ( (myReportType == CLOSED) && ( (OrderCloseTime() < startDate) || (OrderCloseTime() > endDate) ) ) continue;
   
         mysymbol = OrderSymbol();
         pipFactor = GetPipFactor(mysymbol);
         
         myMagic = OrderMagicNumber();
         myComment = OrderComment();
         
         //--- Chop off the [tp] or [sl] if present
         if ( StringFind(myComment,"[sl]",0) > 0 ) myComment = StringSubstr( myComment,0,StringFind(myComment,"[sl]",0) );
         if ( StringFind(myComment,"[tp]",0) > 0 ) myComment = StringSubstr( myComment,0,StringFind(myComment,"[tp]",0) );
         
         index = -1;
         if ( groupBy == SYMBOL ) {
            index = findSymbolInOrderInfo( info, mysymbol );
            if ( index == -1 ) {
               index = addSymbolToOrderInfo( info, mysymbol );
            }
         }
         else if ( groupBy == MAGIC ) {
            index = findMagicInOrderInfo( info, myMagic );
            if ( index == -1 ) {
               index = addMagicToOrderInfo( info, myMagic );
            }
         }
         else if ( groupBy == COMMENT ) {
            index = findCommentInOrderInfo( info, myComment );
            if ( index == -1 ) {
               index = addCommentToOrderInfo( info, myComment );
            }
         }
   
         // If this is a new symbol, add a new record to info
      
         info[index].nrOfTrades += 1;
         info[index].totalLots  += OrderLots();
      
         profit = OrderProfit() + OrderSwap() + OrderCommission();
         info[index].nettPL += profit;
         if ( profit > 0.0 ) {
            info[index].profit += profit;
         }
         else {
            info[index].loss += profit;
         }
        
         lastPrice = 0.0;
         if ( OrderType() == OP_BUY ) {
            info[index].buyLots        += OrderLots();
            info[index].nrOfBuyTrades  += 1;
            lastPrice = ( myReportType == CLOSED ) ? OrderClosePrice() : MarketInfo( mysymbol, MODE_BID );
            info[index].nettPIPs       += ( lastPrice - OrderOpenPrice() ) * pipFactor;
         }
         else if ( OrderType() == OP_SELL ) {
            info[index].sellLots       += OrderLots();
            info[index].nrOfSellTrades += 1;
            lastPrice = ( myReportType == CLOSED ) ? OrderClosePrice() : MarketInfo( mysymbol, MODE_ASK );
            info[index].nettPIPs       += ( OrderOpenPrice() - lastPrice ) * pipFactor;
         }
         
      } // for

   } // for
   
   // Set totals
   for(int iOrder=0; iOrder < ArraySize(info); iOrder++) {
      orderTotal.nrOfTrades      += info[iOrder].nrOfTrades;
      orderTotal.nrOfBuyTrades   += info[iOrder].nrOfBuyTrades;
      orderTotal.nrOfSellTrades  += info[iOrder].nrOfSellTrades;
      orderTotal.totalLots       += info[iOrder].totalLots;
      orderTotal.buyLots         += info[iOrder].buyLots;
      orderTotal.sellLots        += info[iOrder].sellLots;
      orderTotal.profit          += info[iOrder].profit;
      orderTotal.loss            += info[iOrder].loss;
      orderTotal.nettPL          += info[iOrder].nettPL;
      orderTotal.nettPIPs        += info[iOrder].nettPIPs;
   }
   
}   

//+------------------------------------------------------------------+
//| getPipFactor()                                                   |
//+------------------------------------------------------------------+
/*
int GetPipFactor(string symbol) {

  static string factor100[]         = {"JPY","XAG","SILVER","BRENT","WTI"};
  static string factor10[]          = {"XAU","GOLD","SP500"};
  static string factor1[]           = {"UK100","WS30","DAX30","NAS100","CAC400"};
   
  int factor = 10000;       // correct factor for most pairs
  for ( int j = 0; j < ArraySize( factor100 ); j++ ) {
     if ( StringFind( symbol, factor100[j] ) != -1 ) factor = 100;
  }   
  for ( int j = 0; j < ArraySize( factor10 ); j++ ) {
     if ( StringFind( symbol, factor10[j] ) != -1 ) factor = 10;
  }   
  for ( int j = 0; j < ArraySize( factor1 ); j++ ) {
     if ( StringFind( symbol, factor1[j] ) != -1 ) factor = 1;
  }
  
  return (factor);
}*/

double GetPipFactor( string symbol ) {

   static int pointCorrection = ( is5DigitBroker() ) ? 10 : 1;

   double factor = ( 1.0 / SymbolInfoDouble( symbol, SYMBOL_POINT ) ) / pointCorrection;
   
   return(factor);
}

bool is5DigitBroker() {

   bool result = false;
   
   for (int iSymbol=0; iSymbol < SymbolsTotal(false); iSymbol++) {
      if ( StringFind( SymbolName( iSymbol, false ), "EURUSD" ) >= 0 ) {
         result = ( SymbolInfoInteger( SymbolName( iSymbol, false ), SYMBOL_DIGITS ) == 5 );
         break;
      }
   }
   return(result);
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {

   // Get Order Info
   GetOrderInfo( orderInfo );
   
   // AutoSize first column
   AutoSizeFirstColumn( columns, orderInfo );

   // Initialize the sorted-array
   ArrayResize(sorted, ArraySize(orderInfo));
   for(int index=0; index < ArraySize(sorted); index++) sorted[index] = index;

   // Sort the table
   SortColumn( sortedCol );   
   
   // Display the orderInfo in a table
   DisplayOrderInfo( orderInfo );
}

//+------------------------------------------------------------------+
//| addSymbolToOrderInfo( ORDERINFO &info[], string elem )           |
//+------------------------------------------------------------------+
int addSymbolToOrderInfo( ORDERINFO &info[], string elem ) {

   int currentSize = ArraySize(info);
   ArrayResize(info, currentSize+1 );
   
   // Initialize elements
   info[currentSize].symbol            = elem;
   info[currentSize].magic             = -1;
   info[currentSize].comment           = "";
   info[currentSize].nrOfTrades        = 0;
   info[currentSize].nrOfBuyTrades     = 0;
   info[currentSize].nrOfSellTrades    = 0;
   info[currentSize].totalLots         = 0.0;
   info[currentSize].buyLots           = 0.0;
   info[currentSize].sellLots          = 0.0;
   info[currentSize].profit            = 0.0;
   info[currentSize].loss              = 0.0;
   info[currentSize].nettPL            = 0.0;
   info[currentSize].nettPIPs          = 0.0;
   
   return(currentSize);
}

//+------------------------------------------------------------------+
//| addMagicToOrderInfo( ORDERINFO &info[], int magic )              |
//+------------------------------------------------------------------+
int addMagicToOrderInfo( ORDERINFO &info[], int magic) {

   int currentSize = ArraySize(info);
   ArrayResize(info, currentSize+1 );
   
   // Initialize elements
   info[currentSize].symbol            = "";
   info[currentSize].magic             = magic;
   info[currentSize].comment           = "";
   info[currentSize].nrOfTrades        = 0;
   info[currentSize].nrOfBuyTrades     = 0;
   info[currentSize].nrOfSellTrades    = 0;
   info[currentSize].totalLots         = 0.0;
   info[currentSize].buyLots           = 0.0;
   info[currentSize].sellLots          = 0.0;
   info[currentSize].profit            = 0.0;
   info[currentSize].loss              = 0.0;
   info[currentSize].nettPL            = 0.0;
   info[currentSize].nettPIPs          = 0.0;
   
   return(currentSize);
}

//+------------------------------------------------------------------+
//| addCommentToOrderInfo( ORDERINFO &info[], string comment )       |
//+------------------------------------------------------------------+
int addCommentToOrderInfo( ORDERINFO &info[], string comment) {

   int currentSize = ArraySize(info);
   ArrayResize(info, currentSize+1 );
   
   // Initialize elements
   info[currentSize].symbol            = "";
   info[currentSize].magic             = -1;
   info[currentSize].comment           = comment;
   info[currentSize].nrOfTrades        = 0;
   info[currentSize].nrOfBuyTrades     = 0;
   info[currentSize].nrOfSellTrades    = 0;
   info[currentSize].totalLots         = 0.0;
   info[currentSize].buyLots           = 0.0;
   info[currentSize].sellLots          = 0.0;
   info[currentSize].profit            = 0.0;
   info[currentSize].loss              = 0.0;
   info[currentSize].nettPL            = 0.0;
   info[currentSize].nettPIPs          = 0.0;
   
   return(currentSize);
}

//+------------------------------------------------------------------+
//| findSymbolInOrderInfo( ORDERINFO &info[], string elem )                |
//+------------------------------------------------------------------+
int findSymbolInOrderInfo( ORDERINFO &info[], string elem ) {

   int pos = -1;
   for (int i = 0; i < ArraySize(info); i++ ) {
      if (info[i].symbol == elem) {
         pos = i;
         break;
      }
   }
   return(pos);
}

//+------------------------------------------------------------------+
//| findMagicInOrderInfo( ORDERINFO &info[], int magic )             |
//+------------------------------------------------------------------+
int findMagicInOrderInfo( ORDERINFO &info[], int magic ) {

   int pos = -1;
   for (int i = 0; i < ArraySize(info); i++ ) {
      if (info[i].magic == magic) {
         pos = i;
         break;
      }
   }
   return(pos);
}

//+------------------------------------------------------------------+
//| findCommentInOrderInfo( ORDERINFO &info[], string comment )      |
//+------------------------------------------------------------------+
int findCommentInOrderInfo( ORDERINFO &info[], string comment ) {

   int pos = -1;
   for (int i = 0; i < ArraySize(info); i++ ) {
      if (info[i].comment == comment) {
         pos = i;
         break;
      }
   }
   return(pos);
}

//+------------------------------------------------------------------+
//| findInColumns( COLUMN &cols[], string colName )                  |
//+------------------------------------------------------------------+
int findInColumns( COLUMN &cols[], string colName ) {

   int pos = -1;
   for (int i = 0; i < ArraySize(cols); i++ ) {
      if (cols[i].name == colName) {
         pos = i;
         break;
      }
   }
   return(pos);
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam ) {
//---
   if ( (id==CHARTEVENT_OBJECT_CLICK) && (StringFind( sparam, objectPrefix ) == 0) ) {
      ObjectSetInteger(0,sparam,OBJPROP_SELECTED, false );
      ObjectSetInteger(0,sparam,OBJPROP_STATE, false );
      
      string objectName = StringSubstr( sparam, StringLen(objectPrefix) );
      
      int colID = findInColumns( columns, objectName );
      if ( colID >= 0 ) {
         if ( sortedCol == colID ) {
            if ( columns[colID].sortDir == FLAT ) columns[colID].sortDir = UP;
            else if ( columns[colID].sortDir == DOWN ) columns[colID].sortDir = UP;
            else if ( columns[colID].sortDir == UP ) columns[colID].sortDir = DOWN;
         }
         else {
            sortedCol = colID;
            if ( columns[colID].sortDir == FLAT ) columns[colID].sortDir = UP;
         }
         SortColumn( colID );
         DisplayOrderInfo( orderInfo );
      }
   }
}

void SortColumn( int colID ) {

   switch( colID ) {
      case 0: if ( groupBy == SYMBOL ) SortBySymbol( columns[colID].sortDir ); else if ( groupBy == MAGIC ) SortByMagic ( columns[colID].sortDir ); else if ( groupBy == COMMENT ) SortByComment ( columns[colID].sortDir );break;
      case 1: SortByNrOfTrades( columns[colID].sortDir );break;
      case 2: SortByNrOfBuyTrades( columns[colID].sortDir );break;
      case 3: SortByNrOfSellTrades( columns[colID].sortDir );break;
      case 4: SortByTotalLots( columns[colID].sortDir );break;
      case 5: SortByBuyLots( columns[colID].sortDir );break;
      case 6: SortBySellLots( columns[colID].sortDir );break;
      case 7: SortByProfit( columns[colID].sortDir );break;
      case 8: SortByLoss( columns[colID].sortDir );break;
      case 9: SortByNettPL( columns[colID].sortDir );break;
      case 10: SortByNettPIPs( columns[colID].sortDir );break;
   }
}

void SortBySymbol(int direction = UP) {

   int count = ArraySize(orderInfo);
   int tempID;

   for (int id=0; id < count; id++) sorted[id] = id;

   for (int id1=0; id1 < count-1; id1++ ) {
      for ( int id2=id1+1; id2 < count; id2++ ) {
         if ( ( (direction == UP) && (StringCompare(orderInfo[sorted[id1]].symbol, orderInfo[sorted[id2]].symbol, false) > 0) ) ||
              ( (direction == DOWN) && (StringCompare(orderInfo[sorted[id1]].symbol, orderInfo[sorted[id2]].symbol, false) < 0) ) ) {
            tempID = sorted[id1];
            sorted[id1] = sorted[id2];
            sorted[id2] = tempID;
         } // if
      } // for
   } // for
}

void SortByMagic(int direction = UP) {

   int count = ArraySize(orderInfo);
   int tempID;

   for (int id=0; id < count; id++) sorted[id] = id;

   for (int id1=0; id1 < count-1; id1++ ) {
      for ( int id2=id1+1; id2 < count; id2++ ) {
         if ( ( (direction == UP) && ( orderInfo[sorted[id1]].magic > orderInfo[sorted[id2]].magic ) ) ||
              ( (direction == DOWN) && ( orderInfo[sorted[id1]].magic < orderInfo[sorted[id2]].magic ) ) ) {
            tempID = sorted[id1];
            sorted[id1] = sorted[id2];
            sorted[id2] = tempID;
         } // if
      } // for
   } // for
}

void SortByComment(int direction = UP) {

   int count = ArraySize(orderInfo);
   int tempID;

   for (int id=0; id < count; id++) sorted[id] = id;

   for (int id1=0; id1 < count-1; id1++ ) {
      for ( int id2=id1+1; id2 < count; id2++ ) {
         if ( ( (direction == UP) && (StringCompare(orderInfo[sorted[id1]].comment, orderInfo[sorted[id2]].comment, false) > 0) ) ||
              ( (direction == DOWN) && (StringCompare(orderInfo[sorted[id1]].comment, orderInfo[sorted[id2]].comment, false) < 0) ) ) {
            tempID = sorted[id1];
            sorted[id1] = sorted[id2];
            sorted[id2] = tempID;
         } // if
      } // for
   } // for
}

void SortByNrOfTrades(int direction = UP) {

   int count = ArraySize(orderInfo);
   int tempID;

   for (int id=0; id < count; id++) sorted[id] = id;

   for (int id1=0; id1 < count-1; id1++ ) {
      for ( int id2=id1+1; id2 < count; id2++ ) {
         if ( ( (direction == UP) && ( orderInfo[sorted[id1]].nrOfTrades > orderInfo[sorted[id2]].nrOfTrades ) ) ||
              ( (direction == DOWN) && ( orderInfo[sorted[id1]].nrOfTrades < orderInfo[sorted[id2]].nrOfTrades ) ) ) {
            tempID = sorted[id1];
            sorted[id1] = sorted[id2];
            sorted[id2] = tempID;
         } // if
      } // for
   } // for
}

void SortByNrOfBuyTrades(int direction = UP) {

   int count = ArraySize(orderInfo);
   int tempID;

   for (int id=0; id < count; id++) sorted[id] = id;

   for (int id1=0; id1 < count-1; id1++ ) {
      for ( int id2=id1+1; id2 < count; id2++ ) {
         if ( ( (direction == UP) && ( orderInfo[sorted[id1]].nrOfBuyTrades > orderInfo[sorted[id2]].nrOfBuyTrades ) ) ||
              ( (direction == DOWN) && ( orderInfo[sorted[id1]].nrOfBuyTrades < orderInfo[sorted[id2]].nrOfBuyTrades ) ) ) {
            tempID = sorted[id1];
            sorted[id1] = sorted[id2];
            sorted[id2] = tempID;
         } // if
      } // for
   } // for
}

void SortByNrOfSellTrades(int direction = UP) {

   int count = ArraySize(orderInfo);
   int tempID;

   for (int id=0; id < count; id++) sorted[id] = id;

   for (int id1=0; id1 < count-1; id1++ ) {
      for ( int id2=id1+1; id2 < count; id2++ ) {
         if ( ( (direction == UP) && ( orderInfo[sorted[id1]].nrOfSellTrades > orderInfo[sorted[id2]].nrOfSellTrades ) ) ||
              ( (direction == DOWN) && ( orderInfo[sorted[id1]].nrOfSellTrades < orderInfo[sorted[id2]].nrOfSellTrades ) ) ) {
            tempID = sorted[id1];
            sorted[id1] = sorted[id2];
            sorted[id2] = tempID;
         } // if
      } // for
   } // for
}

void SortByTotalLots(int direction = UP) {

   int count = ArraySize(orderInfo);
   int tempID;

   for (int id=0; id < count; id++) sorted[id] = id;

   for (int id1=0; id1 < count-1; id1++ ) {
      for ( int id2=id1+1; id2 < count; id2++ ) {
         if ( ( (direction == UP) && ( orderInfo[sorted[id1]].totalLots > orderInfo[sorted[id2]].totalLots ) ) ||
              ( (direction == DOWN) && ( orderInfo[sorted[id1]].totalLots < orderInfo[sorted[id2]].totalLots ) ) ) {
            tempID = sorted[id1];
            sorted[id1] = sorted[id2];
            sorted[id2] = tempID;
         } // if
      } // for
   } // for
}

void SortByBuyLots(int direction = UP) {

   int count = ArraySize(orderInfo);
   int tempID;

   for (int id=0; id < count; id++) sorted[id] = id;

   for (int id1=0; id1 < count-1; id1++ ) {
      for ( int id2=id1+1; id2 < count; id2++ ) {
         if ( ( (direction == UP) && ( orderInfo[sorted[id1]].buyLots > orderInfo[sorted[id2]].buyLots ) ) ||
              ( (direction == DOWN) && ( orderInfo[sorted[id1]].buyLots < orderInfo[sorted[id2]].buyLots ) ) ) {
            tempID = sorted[id1];
            sorted[id1] = sorted[id2];
            sorted[id2] = tempID;
         } // if
      } // for
   } // for
}

void SortBySellLots(int direction = UP) {

   int count = ArraySize(orderInfo);
   int tempID;

   for (int id=0; id < count; id++) sorted[id] = id;

   for (int id1=0; id1 < count-1; id1++ ) {
      for ( int id2=id1+1; id2 < count; id2++ ) {
         if ( ( (direction == UP) && ( orderInfo[sorted[id1]].sellLots > orderInfo[sorted[id2]].sellLots ) ) ||
              ( (direction == DOWN) && ( orderInfo[sorted[id1]].sellLots < orderInfo[sorted[id2]].sellLots ) ) ) {
            tempID = sorted[id1];
            sorted[id1] = sorted[id2];
            sorted[id2] = tempID;
         } // if
      } // for
   } // for
}

void SortByProfit(int direction = UP) {

   int count = ArraySize(orderInfo);
   int tempID;

   for (int id=0; id < count; id++) sorted[id] = id;

   for (int id1=0; id1 < count-1; id1++ ) {
      for ( int id2=id1+1; id2 < count; id2++ ) {
         if ( ( (direction == UP) && ( orderInfo[sorted[id1]].profit > orderInfo[sorted[id2]].profit ) ) ||
              ( (direction == DOWN) && ( orderInfo[sorted[id1]].profit < orderInfo[sorted[id2]].profit ) ) ) {
            tempID = sorted[id1];
            sorted[id1] = sorted[id2];
            sorted[id2] = tempID;
         } // if
      } // for
   } // for
}

void SortByLoss(int direction = UP) {

   int count = ArraySize(orderInfo);
   int tempID;

   for (int id=0; id < count; id++) sorted[id] = id;

   for (int id1=0; id1 < count-1; id1++ ) {
      for ( int id2=id1+1; id2 < count; id2++ ) {
         if ( ( (direction == UP) && ( orderInfo[sorted[id1]].loss > orderInfo[sorted[id2]].loss ) ) ||
              ( (direction == DOWN) && ( orderInfo[sorted[id1]].loss < orderInfo[sorted[id2]].loss ) ) ) {
            tempID = sorted[id1];
            sorted[id1] = sorted[id2];
            sorted[id2] = tempID;
         } // if
      } // for
   } // for
}

void SortByNettPL(int direction = UP) {

   int count = ArraySize(orderInfo);
   int tempID;

   for (int id=0; id < count; id++) sorted[id] = id;

   for (int id1=0; id1 < count-1; id1++ ) {
      for ( int id2=id1+1; id2 < count; id2++ ) {
         if ( ( (direction == UP) && ( orderInfo[sorted[id1]].nettPL > orderInfo[sorted[id2]].nettPL ) ) ||
              ( (direction == DOWN) && ( orderInfo[sorted[id1]].nettPL < orderInfo[sorted[id2]].nettPL ) ) ) {
            tempID = sorted[id1];
            sorted[id1] = sorted[id2];
            sorted[id2] = tempID;
         } // if
      } // for
   } // for
}

void SortByNettPIPs(int direction = UP) {

   int count = ArraySize(orderInfo);
   int tempID;

   for (int id=0; id < count; id++) sorted[id] = id;

   for (int id1=0; id1 < count-1; id1++ ) {
      for ( int id2=id1+1; id2 < count; id2++ ) {
         if ( ( (direction == UP) && ( orderInfo[sorted[id1]].nettPIPs > orderInfo[sorted[id2]].nettPIPs ) ) ||
              ( (direction == DOWN) && ( orderInfo[sorted[id1]].nettPIPs < orderInfo[sorted[id2]].nettPIPs ) ) ) {
            tempID = sorted[id1];
            sorted[id1] = sorted[id2];
            sorted[id2] = tempID;
         } // if
      } // for
   } // for
}

//+------------------------------------------------------------------+
//| display the orderInfo in a table                                 |
//+------------------------------------------------------------------+
void DisplayOrderInfo( ORDERINFO &info[] ) {

   static int    lineHeight = 16;
   color  tableBorderColor     = myColorScheme[colorScheme].tableBorderColor;
   color  tableHeadBackColor   = myColorScheme[colorScheme].tableHeadBackColor;
   color  tableHeadTextColor   = myColorScheme[colorScheme].tableHeadTextColor;
   color  tableRowBackColor    = myColorScheme[colorScheme].tableRowBackColor;
   color  tableAltRowBackColor = myColorScheme[colorScheme].tableAltRowBackColor;
   color  tableRowTextColor    = myColorScheme[colorScheme].tableRowTextColor;
   //static color  buttonBackColor      = clrIvory;
   //static color  buttonBorderColor    = clrLemonChiffon;
   //static color  buttonTextColor      = clrBlack;
   color backColor, textColor;
   int   xPos, yPos;

   int total = ArraySize(info);
   
   if ( total == 0 ) return;
   
   deleteAllObjects();

   // Draw Header of Table
   xPos = xOffset; yPos = yOffset;
   for (int iCol=0; iCol < ArraySize(columns); iCol++) {
      RectLabelCreate( 0, objectPrefix + RandomString(5, 10), 0, xPos, yPos, columns[iCol].width,lineHeight,tableHeadBackColor,BORDER_FLAT,CORNER_LEFT_UPPER, tableBorderColor );
      textColor = tableHeadTextColor;
      if ( iCol == sortedCol ) {
         if ( columns[iCol].sortDir == UP ) textColor = clrGreen;
         else if ( columns[iCol].sortDir == DOWN ) textColor = clrRed;
      }
      ButtonCreate(0, objectPrefix + columns[iCol].name, 0, xPos+5, yPos+1, columns[iCol].width-10,lineHeight-4, CORNER_LEFT_UPPER, columns[iCol].name, screenFont, 9, textColor, tableHeadBackColor, tableHeadBackColor );
      xPos += columns[iCol].width;
   }

   // Draw the Rows
   for (int iRow=0; iRow < total; iRow++) {

      // Set alternating background colors
      backColor = ( (int)MathMod(iRow,2.0) == 0 ) ? tableRowBackColor : tableAltRowBackColor;

      // Draw the column backgrounds
      xPos = xOffset; yPos = yOffset + (iRow+1)*lineHeight;
      for (int iCol=0; iCol < ArraySize(columns); iCol++) {
         if ( iCol >= ArraySize(columns)-2 ) {
            //backColor = clrWhite; //backColor;
            backColor = ( (int)MathMod(iRow,2.0) == 0 ) ? C'0xFC,0xFC,0xFC' : C'0xF0,0xF0,0xF0';
         }
         RectLabelCreate( 0, objectPrefix + RandomString(5, 10), 0, xPos, yPos, columns[iCol].width,lineHeight,backColor,BORDER_FLAT,CORNER_LEFT_UPPER, tableBorderColor );
         xPos += columns[iCol].width;
      }
      
      // Draw the symbol or magic or comment
      xPos = xOffset;
      if ( groupBy == SYMBOL )
         DrawText(0, objectPrefix + RandomString(5, 10), info[sorted[iRow]].symbol, xPos+7, yPos+1, tableRowTextColor, 8 );
      else if ( groupBy == MAGIC )
         DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%12d", info[sorted[iRow]].magic), xPos+10, yPos+1, tableRowTextColor, 8 );
      else if ( groupBy == COMMENT )
         DrawText(0, objectPrefix + RandomString(5, 10), info[sorted[iRow]].comment, xPos+7, yPos+1, tableRowTextColor, 8 );
      
      // Draw the number of trades
      xPos += columns[0].width;
      DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%5d",info[sorted[iRow]].nrOfTrades), xPos+10, yPos+1, tableRowTextColor, 8 );

      // Draw the number of BUY trades
      xPos += columns[1].width;
      DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%5d",info[sorted[iRow]].nrOfBuyTrades), xPos+10, yPos+1, tableRowTextColor, 8 );

      // Draw the number of SELL trades
      xPos += columns[2].width;
      DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%5d",info[sorted[iRow]].nrOfSellTrades), xPos+10, yPos+1, tableRowTextColor, 8 );

      // Draw the total LOTS size
      xPos += columns[3].width;
      DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%5.2f",info[sorted[iRow]].totalLots), xPos+10, yPos+1, tableRowTextColor, 8 );

      // Draw the total BUY LOTS size
      xPos += columns[4].width;
      DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%5.2f",info[sorted[iRow]].buyLots), xPos+20, yPos+1, tableRowTextColor, 8 );

      // Draw the total SELL LOTS size
      xPos += columns[5].width;
      DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%5.2f",info[sorted[iRow]].sellLots), xPos+20, yPos+1, tableRowTextColor, 8 );
      
      // Draw the total profit
      xPos += columns[6].width;
      DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%9.2f",info[sorted[iRow]].profit), xPos+10, yPos+1, tableRowTextColor, 8 );
      
      // Draw the total loss
      xPos += columns[7].width;
      DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%9.2f",info[sorted[iRow]].loss), xPos+10, yPos+1, tableRowTextColor, 8 );

      // Draw the nett Profit/Loss
      xPos += columns[8].width;
      textColor = ( info[sorted[iRow]].nettPL > 0.0 ) ? clrGreen : clrRed;
      DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%9.2f",info[sorted[iRow]].nettPL), xPos+10, yPos+1, textColor, 8 );
      
      // Draw the nett PIPs
      xPos += columns[9].width;
      textColor = ( info[sorted[iRow]].nettPIPs > 0.0 ) ? clrGreen : clrRed;
      DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%9.2f",info[sorted[iRow]].nettPIPs), xPos+10, yPos+1, textColor, 8 );
   }

   // Draw the totals' backgrounds
   xPos = xOffset; yPos = yOffset + (total+1)*lineHeight;

   // Set background color for grand total PIPs and grand total $ (last two columns)
   backColor = ( (int)MathMod(total,2.0) == 0 ) ? tableRowBackColor : tableAltRowBackColor;

   for (int iCol=0; iCol < ArraySize(columns); iCol++) {
      color grandTotalColor = tableHeadBackColor;
      color grandTotalBorderColor = tableBorderColor;
      //if ( iCol >= ArraySize(columns)-2 ) {
      //   grandTotalColor = clrWhite; //backColor;
      //   grandTotalBorderColor = tableBorderColor;
      //}
      if ( iCol == ArraySize(columns)-2 ) {
         grandTotalColor = ( orderTotal.nettPL > 0.0 ) ? clrGreen : clrRed;
         grandTotalBorderColor = tableBorderColor;
      }
      if ( iCol == ArraySize(columns)-1 ) {
         grandTotalColor = ( orderTotal.nettPIPs > 0.0 ) ? clrGreen : clrRed;
         grandTotalBorderColor = tableBorderColor;
      }
      RectLabelCreate( 0, objectPrefix + RandomString(5, 10), 0, xPos, yPos, columns[iCol].width,lineHeight,grandTotalColor,BORDER_FLAT,CORNER_LEFT_UPPER, grandTotalBorderColor );
      xPos += columns[iCol].width;
   }
   // Draw the total number of trades
   xPos = xOffset; 
   xPos += columns[0].width;
   DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%5d",orderTotal.nrOfTrades), xPos+10, yPos+1, tableHeadTextColor, 8 );

   // Draw the total number of BUY trades
   xPos += columns[1].width;
   DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%5d",orderTotal.nrOfBuyTrades), xPos+10, yPos+1, tableHeadTextColor, 8 );

   // Draw the total number of SELL trades
   xPos += columns[2].width;
   DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%5d",orderTotal.nrOfSellTrades), xPos+10, yPos+1, tableHeadTextColor, 8 );

   // Draw the grand total LOTS size
   xPos += columns[3].width;
   DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%5.2f",orderTotal.totalLots), xPos+10, yPos+1, tableHeadTextColor, 8 );

   // Draw the grand total BUY LOTS size
   xPos += columns[4].width;
   DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%5.2f",orderTotal.buyLots), xPos+20, yPos+1, tableHeadTextColor, 8 );

   // Draw the grand total SELL LOTS size
   xPos += columns[5].width;
   DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%5.2f",orderTotal.sellLots), xPos+20, yPos+1, tableHeadTextColor, 8 );
   
   // Draw the grand total profit
   xPos += columns[6].width;
   DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%9.2f",orderTotal.profit), xPos+10, yPos+1, tableHeadTextColor, 8 );
   
   // Draw the grand total loss
   xPos += columns[7].width;
   DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%9.2f",orderTotal.loss), xPos+10, yPos+1, tableHeadTextColor, 8 );

   // Draw the total nett Profit/Loss
   xPos += columns[8].width;
   textColor = clrWhite; //( orderTotal.nettPL > 0.0 ) ? clrGreen : clrRed;
   DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%9.2f",orderTotal.nettPL), xPos+10, yPos+1, textColor, 8 );
   
   // Draw the total nett PIPs
   xPos += columns[9].width;
   textColor = clrWhite; //( orderTotal.nettPIPs > 0.0 ) ? clrGreen : clrRed;
   DrawText(0, objectPrefix + RandomString(5, 10), StringFormat("%9.2f",orderTotal.nettPIPs), xPos+10, yPos+1, textColor, 8 );
   
   // Draw the legend ...
   int totalWidth = 0;
   for (int iCol=0; iCol < ArraySize(columns); iCol++) totalWidth += columns[iCol].width;
   xPos = xOffset; yPos = yOffset + (total+2)*lineHeight;
   RectLabelCreate( 0, objectPrefix + RandomString(5, 10), 0, xPos, yPos, totalWidth,2*lineHeight,tableHeadBackColor,BORDER_FLAT,CORNER_LEFT_UPPER, tableBorderColor );

   yPos += lineHeight/2;
   string legendText = StringFormat("Report from %s until %s", TimeToString(startDate,TIME_DATE), TimeToString(endDate,TIME_DATE) );
   if ( DateChoice == TODAY ) legendText = legendText + " (only today)";
   else if ( DateChoice == THIS_WEEK ) legendText = legendText + " (only this week)";
   else if ( DateChoice == THIS_MONTH ) legendText = legendText + " (only this month)";
   DrawText(0, objectPrefix + "Dates", legendText, xPos+10, yPos+1, tableHeadTextColor, 8 );
   legendText = ""; int legendWidth;
   if (MagicNumber >= 0) legendText = StringFormat("MagicNumber = %d",MagicNumber);
   if (CommentFilter != "") legendText = legendText + StringFormat(" Comment = %s",CommentFilter);
   if (SymbolFilter != "") legendText = legendText + StringFormat(" Symbols = %s",convertArray(IncludeSymbols,";"));
   if (CurrencyFilter != "") legendText = legendText + StringFormat(" Currencies = %s",convertArray(IncludeCurrencies,";"));
   if ( legendText != "") {
      legendWidth = StringLen(legendText)*8;
      DrawText(0, objectPrefix + "MagicNumber", legendText, xPos+90+(totalWidth-legendWidth)/2, yPos+1, tableHeadTextColor, 8 );
   }
      
   legendText = ""; legendWidth = 90;      
   if (reportType == CLOSED) legendText = StringConcatenate(legendText, "CLOSED trades");
   else if (reportType == OPEN) legendText = StringConcatenate(legendText, "OPEN trades");
   else if (reportType == BOTH) { legendText = StringConcatenate(legendText, "OPEN + CLOSED trades"); legendWidth = 130; }
   DrawText(0, objectPrefix + "Legend", legendText, xPos+5+(totalWidth-legendWidth), yPos+1, tableHeadTextColor, 8 );
   
   
   
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
                     const int              width=48,                 // width
                     const int              height=14,                // height
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

bool ButtonCreate(const long              chart_ID=0,               // chart's ID
                  const string            name="Signal0",            // button name
                  const int               sub_window=0,             // subwindow index
                  const int               x=0,                      // X coordinate
                  const int               y=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=14,                // button height
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string            text="Trade",             // text
                  const string            font="Helvetica",         // font
                  const int               font_size=9,             // font size
                  const color             clr=clrBlack,             // text color
                  const color             back_clr=clrDarkSlateGray,       // background color
                  const color             border_clr=clrBlack,      // border color
                  const ENUM_BORDER_TYPE  border=BORDER_RAISED,     // border type
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
//--- set border type
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
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
//| Create text object                                               |
//+------------------------------------------------------------------+
void DrawText( int nWindow, string nCellName, string nText, double nX, double nY, color nColor, int fontSize = 9, string font = screenFont ) {

   ObjectCreate( nCellName, OBJ_LABEL, nWindow, 0, 0);
   ObjectSetText( nCellName, nText, fontSize, font, nColor);
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

void convertCSV( string csvText, string &array[] ) {

   // First uppercase everything
   StringToUpper(csvText);
   
   // Remove rubbish from csvText -- only allow 'A'-'Z' and ','
   string cleanText;
   for (int pos=0; pos < StringLen(csvText); pos++) {
      ushort c = StringGetChar( csvText, pos );
      if ( ( c==',') || ( ( c>='A') && (c<='Z') ) ) {
         cleanText = StringConcatenate( cleanText, CharToString((uchar)c) );
      }
   }

   // Remove leading and trailing comma's
   int leftCut=0;
   while( (leftCut < StringLen(cleanText)) && StringGetChar(cleanText,leftCut) == ',' ) leftCut++;
   int rightCut = StringLen(cleanText)-1;
   while( (rightCut >= 0) && StringGetChar(cleanText,rightCut) == ',' ) rightCut--;
   cleanText = StringSubstr(cleanText, leftCut, rightCut-leftCut+1 );
   
   string tempArray[];
   const ushort comma = StringGetChar(",",0);
   // Convert cleanText to string array
   StringSplit( cleanText, comma, tempArray);
   
   // Fill array[] from elements of tempArray -- remove duplicates and empty strings
   for(int iTemp=0; iTemp < ArraySize(tempArray); iTemp++) {
      string elem = tempArray[iTemp];
      if ( ( StringLen(elem) > 0 ) && ( findInStringArray(array, elem) < 0 ) ) {
         int currentSize=ArraySize(array);
         ArrayResize(array, currentSize+1);
         array[currentSize] = elem;
      }
   }
}

int findInStringArray(string &array[], string elem) {

   int index = -1;
   for(int i=0; i < ArraySize(array); i++) {
      if ( array[i] == elem ) {
         index = i;
         break;
      }
   }
   return(index);
}

string convertArray(string &array[], string sep) {

   string output = "";
   for(int index=0; index < ArraySize(array); index++) {
      output = StringConcatenate(output,array[index],";");
   }
   return(output);
}