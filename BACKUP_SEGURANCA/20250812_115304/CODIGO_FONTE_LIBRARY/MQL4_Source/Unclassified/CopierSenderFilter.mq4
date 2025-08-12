/* *************************************************************************************
Library which allows bespoke modifications to the copier's trading.
Only used if the UseExternalFilters setting is turned on in the copier.
************************************************************************************* */

#property library
#property strict


/* *************************************************************************************
Order definition used by the copier
************************************************************************************* */

#ifdef __MQL5__
   #define TICKET    long
#else
   #define TICKET    int
#endif

struct OrderDef {
   TICKET   ticket;
   int      type;             // type of order/position, using the MT4 values: 0=buy, 1=sell, 2=buy-limit, 3=sell-limit, 4=buy-stop, 5=sell-stop. In MT5, can also be #100 and #101 for working buy and sell market orders
   string   symbol;           
   double   lots;
   double   openprice;
   double   closeprice;       // As in MT4&5: current/close price. Opposite side of spread for market orders; same side of spread for pending orders
   datetime opentime;
   double   sl;
   double   tp;
   double   profit;
   double   swap;
   double   commission;
   string   comment;
   int      magic;
};



/* *************************************************************************************
Called when the sender EA is about to issue a new message to the receiver(s), for 
the order identified by senderOrder. This function can return one of the following 
values:

   0 = Allow order to be sent to receivers
   1 = Permanently suppress the order. Receivers will not know about and copy this trade.
   2 = Temporarily suppress the order.

If this function returns 2, then the sender EA will keep calling it periodically until 
it finally returns 0 or 1 (or until the order is closed). The purpose of return value #2
is to let this code implement a time-based or profit-based condition before 
a trade is copied.

This function is called before applying restrictions such as IncludeSymbols and 
IncludeOrderComments. If this function receives a notification and returns 0, the trade
is not necessarily copied.

(Note: trades can also be suppressed using FilterModifyOrders.)
************************************************************************************* */

int FilterNewOrder(string Channel, OrderDef& senderOrder)
{
   // For example:
   
      // Don't broadcast sell positions on GBPUSD, only buys
      // if (senderOrder.symbol == "GBPUSD" && senderOrder.type == 1) return 1;
   
   return 0;
}


/* *************************************************************************************
Receives the list of orders currently open on the account, and can make *any* changes 
to what the copier sees and subsequently processes. If the array is modified in any way 
then the function must return true, or else it will have no effect.

For example, the function can do the following:
  * Change the s/l, t/p, volume, or even symbol name on an order
  * Remove an order from the array, preventing it being copied (temporarily or permanently).
    Orders can also be suppressed by setting their symbol to "", or their ticket or volume to <= 0
  * Add "virtual" orders which do not actually exist on the account. All such orders
    need to be given unique ticket numbers.
************************************************************************************* */

bool FilterModifyOrders(string Channel, OrderDef& currentOrders[])
{
   // For example:
   
      // Change the lot size on all orders to 0.25
      // Turn USDJPY into EURJPY
      // Prevent USDCAD trades 
      /*
      for (int i = 0; i < ArraySize(currentOrders); i++) {
         currentOrders[i].lots = 0.25;
         
         if (currentOrders[i].symbol == "USDJPY") {
            currentOrders[i].symbol = "EURJPY";
         } else if (currentOrders[i].symbol == "USDCAD") {
            currentOrders[i].symbol = ""; // ... one way of making the copier ignore an order
         }
      }
      return true; // Tell the copier that the array has been modified
      */
      
   return false;
}



/* *************************************************************************************
DO NOT ALTER THE FOLLOWING!
Internal wiring of the library, which has to convert to and from strings because 
MQL does not allow structs to be passed directly in and out of a library 
************************************************************************************* */

// Wrapper which receives/returns string data from the receiver EA, converting 
// it into OrderDef records for easier processing by the wrapped function above
int FilterNewOrder_Wrapper(string Channel, string strSenderOrder) export
{
   // Convert inbound string data into OrderDef structures
   OrderDef senderOrder;
   ConvertStringToOrderDef(strSenderOrder, senderOrder);
   
   return FilterNewOrder(Channel, senderOrder);
}

// Wrapper which receives/returns string data from the receiver EA, converting 
// it into OrderDef records for easier processing by the wrapped function above
bool FilterModifyOrders_Wrapper(string Channel, string& arrOrderStrings[]) export
{
	// Need to serialize all the order defs into strings 
   OrderDef currentOrders[];
   ArrayResize(currentOrders, ArraySize(arrOrderStrings));
   for (int i = 0; i < ArraySize(arrOrderStrings); i++) {
      ConvertStringToOrderDef(arrOrderStrings[i], currentOrders[i]);
   }

	if (FilterModifyOrders(Channel, currentOrders)) {
		// Need to serialize all the order defs into strings 
	   ArrayResize(arrOrderStrings, ArraySize(currentOrders));
	   for (int i = 0; i < ArraySize(currentOrders); i++) {
	      arrOrderStrings[i] = ConvertOrderDefToString(currentOrders[i]);
	   }

      return true;	
	} else {
		// Function says that it has made no changes to the array 
		return false;
	}
}


// Serialize an order definition into a string 
string ConvertOrderDefToString(OrderDef& order)
{
   string strOrder = "";
   StringAdd(strOrder, "TICKET\02" + IntegerToString(order.ticket));
   StringAdd(strOrder, "\01SYMBOL\02" + order.symbol);
   StringAdd(strOrder, "\01TYPE\02" + IntegerToString(order.type));
   StringAdd(strOrder, "\01VOLUME\02" + DoubleToString(order.lots, 2));
   StringAdd(strOrder, "\01OPENPRICE\02" + DoubleToString(order.openprice, 8));
   StringAdd(strOrder, "\01SL\02" + DoubleToString(order.sl, 8));
   StringAdd(strOrder, "\01TP\02" + DoubleToString(order.tp, 8));
   StringAdd(strOrder, "\01CLOSEPRICE\02" + DoubleToString(order.closeprice, 8));
   StringAdd(strOrder, "\01OPENTIME\02" + IntegerToString(order.opentime));
   StringAdd(strOrder, "\01COMMENT\02" + order.comment);
   StringAdd(strOrder, "\01MAGIC\02" + IntegerToString(order.magic));
   StringAdd(strOrder, "\01PROFIT\02" + DoubleToString(order.profit, 2));
   StringAdd(strOrder, "\01SWAP\02" + DoubleToString(order.swap, 2));
   StringAdd(strOrder, "\01COMMISSION\02" + DoubleToString(order.commission, 2));

   return strOrder;
}

// Deserialize a string into an order definition 
void ConvertStringToOrderDef(string strDef, OrderDef& order)
{
   string parts[];
   StringSplit(strDef, '\01', parts);
   int ctParts = ArraySize(parts);
   for (int i = 0; i < ctParts; i++) {
      string kp[];
      StringSplit(parts[i], '\02', kp);
      if (ArraySize(kp) == 2) {
         if (kp[0] == "TICKET") {
            order.ticket = (TICKET)StringToInteger(kp[1]);
         } else if (kp[0] == "SYMBOL") {
            order.symbol = kp[1];
         } else if (kp[0] == "TYPE") {
            order.type = (int)StringToInteger(kp[1]);
         } else if (kp[0] == "VOLUME") {
            order.lots = StringToDouble(kp[1]);
         } else if (kp[0] == "OPENPRICE") {
            order.openprice = StringToDouble(kp[1]);
         } else if (kp[0] == "SL") {
            order.sl = StringToDouble(kp[1]);
         } else if (kp[0] == "TP") {
            order.tp = StringToDouble(kp[1]);
         } else if (kp[0] == "CLOSEPRICE") {
            order.closeprice = StringToDouble(kp[1]);
         } else if (kp[0] == "OPENTIME") {
            order.opentime = (datetime)StringToInteger(kp[1]);
         } else if (kp[0] == "COMMENT") {
            order.comment = kp[1];
         } else if (kp[0] == "MAGIC") {
            order.magic = (int)StringToInteger(kp[1]);
         } else if (kp[0] == "PROFIT") {
            order.profit = StringToDouble(kp[1]);
         } else if (kp[0] == "SWAP") {
            order.swap = StringToDouble(kp[1]);
         } else if (kp[0] == "COMMISSION") {
            order.commission = StringToDouble(kp[1]);
         }      
      }
   }
}
