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
   TICKET   ticket;           // for existing orders/positions, the local ticket number of the order/position
   string   positionId;       // the external position ID, from the sender
   int      type;             // type of order/position, using the MT4 values: 0=buy, 1=sell, 2=buy-limit, 3=sell-limit, 4=buy-stop, 5=sell-stop
   string   symbol;           
   double   volume;           // For the sender's order, the *NOTIONAL VOLUME*: lots x contract size. For receiver orders, the local lot size.
   double   openprice;
   double   closeprice;		   // As in MT4&5: current/close price. Opposite side of spread for market orders; same side of spread for pending orders
   datetime opentime;
   double   sl;
   double   tp;
   double   profit;
   double   swap;
   double   commission;
   string   comment;          // DO NOT ALTER unless you also turn on UseOriginalOrderComments or UseCustomOrderComment (and then override the comment here). This can orphan positions, and make the copier close them because they cannot be reconciled against the sender's heartbeat
   int      magic;            // DO NOT ALTER. This will orphan positions. The copier will ignore and not manage any trades which don't have its specified magic number.
};


/* *************************************************************************************
Function which filters new order requests into the copier, after all internal 
checks and conversions have taken place. Returns true to allow the order to be 
placed on the receiver, or false to block it. If the function returns true, 
then it is allowed to modify the values in newOrder to change the new order which 
the receiver will then place. Parameters for the function are the new order 
from the sender (note: where the volume is a cash/unit amount such as 20000, not a lots 
value such 0.20); an array of local tickets currently being managed by the copier;
and the new order which the copier is about to place, having already done all 
its standard checks and conversions.

Note: you can use this function (or any other) to place additional new orders of
your own onto the account. However, if you want to associate these orders with 
sender positions, so that they are automatically closed if the sender's trade 
is closed, then you need to do at least two things:

  * Use the same magic number as the copier, which will be newOrder.magic 
  * Link this order of yours to the sender position. You can do this 
    either by using the same order comment, newOrder.comment, which the 
    copier would use itself, or by using MapTicketNumberToBroadcasterPositionId below.
    
If your additional order is for a different symbol, then you also need to prevent 
the copier trying to copy any s/l or t/p - because the prices won't be applicable 
to your order on a different market. You need to use FilterOrderModify, below,
to stop the mirroring of the s/l and t/p onto your own orders.
************************************************************************************* */

bool FilterCheckNewOrder(string Channel, OrderDef& senderOrder, OrderDef& existingOrders[], OrderDef& newOrder)
{
   // For example...
   
      // Block all GBPUSD trades
      //   if (newOrder.symbol == "GBPUSD") return false;
   
      // Use a fixed lot size of 0.20 on USDCAD
      //   if (newOrder.symbol == "USDCAD") newOrder.volume = 0.2;
   
   
   // Return false to prevent the new order, or true to allow it. 
   // If true, then you are allowed to modify the definition in newOrder,
   // changing the order before the receiver EA places it.
   return true;
}


/* *************************************************************************************
Called when the copier is about to close/delete a position/order. This function can
then return false to prevent the order being closed. The reason parameter explains why 
the copier is closing the order:

   0 = normal close instruction from sender
   1 = ticket is no longer on sender's heartbeat
   2 = sender position is partially closed, and PreventPartialExits is turned on
   3 = sender position is partially closed, and receiver's order is still pending
   4 = sender position is partially closed, and rounded/converted lot size on receiver leads to a full close 
   5 = receiver has a filled position; sender's order is still pending; time since fill exceeds RequireSenderFillWithinMinutes
  10 = order being closed because of drawdown-shutdown
  11 = order profit has breached MaxCashRisk 
  12 = new position has failed post-trade check on slippage (ImmediateCloseOnSlippagePips) 
  13 = close button in UI (for MT5 netting accounts)
  
Note: if you suppress a close for reason #0, the copier will then make repeated
requests to close the order with reason=#1 because the order will not be on the
sender's heartbeat.  
************************************************************************************* */

bool FilterCloseOrder(string Channel, OrderDef& receiverOrder, int reason)
{
   return true;
}


/* *************************************************************************************
Called when the copier is about to do a partial close. The SenderCloseFactor is the 
amount of the sender's position which has been closed (e.g. 0.5, for 50%). The LotsToClose 
is the amount which the copier intends to close of its local order. This filter 
can return false to prevent the partial close entirely. If it returns true, then it can
change the amount of the partial close by modifying the by-reference LotsToClose value.
(This function can also prevent a partial close by setting LotsToClose=0 as well as 
by returning false. But that route creates extra entries in the logs.)
************************************************************************************* */

bool FilterPartialClose(string Channel, OrderDef& receiverOrder, double SenderCloseFactor, double & LotsToClose)
{
   return true;
}


/* *************************************************************************************
Called when the copier is about to change an order's s/l or t/p as a result of 
a modification received in the sender's heartbeat. This function can return false 
to prevent the modification. If it returns true then it can override the new levels 
by changing the by-reference values such as NewSL.
************************************************************************************* */

bool FilterOrderModify(string Channel, OrderDef& receiverOrder, double & NewEntryPrice, double & NewSL, double & NewTP)
{
   /*
      For example, if a position has an existing s/l, then the following code prevents a change to 
      the s/l which widens it and increases the risk on the trade:
      
      switch (receiverOrder.type) {
         case 0:  // Buy order
            if (receiverOrder.sl && NewSL < receiverOrder.sl) {
               Print("Preventing stop being widened on #", receiverOrder.ticket , " from " , receiverOrder.sl , " to ", NewSL);
               NewSL = receiverOrder.sl;   // Can also return false to prevent the change entirely
            }
            break;
         
         case 1:  // Sell order
            if (receiverOrder.sl && NewSL > receiverOrder.sl) {
               Print("Preventing stop being widened on #", receiverOrder.ticket , " from " , receiverOrder.sl , " to ", NewSL);
               NewSL = receiverOrder.sl;   // Can also return false to prevent the change entirely
            }
            break;
      }
   */
   
   return true;
}


/* *************************************************************************************
Called periodically with a list of the copier's current orders in the existingOrders[]
array, letting you do any monitoring you want. You can use this as an opportunity to 
modify orders, close orders, or even open new orders. (If you want to link an order 
of your own to a sender position, so that it is closed if the sender's trade is closed,
then see MapTicketNumberToBroadcasterPositionId below.)

This function is called at least as often as OnTick(). It is similar to a combination 
of MQL's OnTick and OnTimer.

You can also change the copier's orders by running an EA of your own on another chart.
This route simply avoids the need for a second chart and second EA.
************************************************************************************* */

void FilterManageOrders(string Channel, OrderDef& existingOrders[])
{
}


/* *************************************************************************************
Function which returns the broadcaster position ID corresponding to a local ticket number 
on the receiver account. Can return one of three things:

* a blank string. The copier will then use its own normal mapping, e.g. identifying 
  the sender position via the order's comment
* An ID for a broadcaster position to associate with the ticket, e.g. "12345678"
* The special value "X". This tells the copier that the order should not be associated 
  with any sender position (overriding any order comment etc). This will cause 
  the order to be closed because the ticket will not correspond to anything 
  on the sender's heartbeat.
  
This function is mainly intended for placing your own trades and then associating 
them with sender positions so that they are closed if the sender position is closed.
You need to do two things when placing such trades of your own: (a) use the same 
magic number as the copier, and also (b) either set the same order comment which 
the copier would set, or use this function to link the ticket number to the
sender's position.  
************************************************************************************* */

string MapTicketNumberToBroadcasterPositionId(TICKET ticket) export
{
   return ""; // Blank string means "don't override the copier's default mapping"
}



/* *************************************************************************************
Function which does symbol name conversion; can be used as an alternative 
to the copier's CustomSymbolMappings setting.
Called with the symbol name provided by the sender, and with the copier's default 
mapping in strLocalSymbolName. This function can change the contents of strLocalSymbolName 
in order to change the mapping. 
************************************************************************************* */

void MapSymbolName(string Channel, string strSenderName, string& strLocalSymbolName) export
{
   // No default action; leave the strLocalSymbolName untouched.
   
   // It's also possible to do the following here (which can also be 
   // achieved using FilterCheckNewOrder)...
   
   //    Change all EURUSD trades into GBPUSD trades
   //       if (strLocalSymbolName == "EURUSD") strLocalSymbolName = "GBPUSD";
}


/* *************************************************************************************
DO NOT ALTER THE FOLLOWING!
Internal wiring of the library. This has to use wrapper functions which receive 
orders as string data, and deserializes the strings into OrderDef structures.
MQL does not allow structs to be passed directly in and out of a library. 
************************************************************************************* */

// Wrapper which receives/returns string data from the receiver EA, converting 
// it into OrderDef records for easier processing by the wrapped function above
bool FilterCheckNewOrder_Wrapper(string Channel, string strSenderOrder, string & arrOpenOrders[], string& strNewOrder) export
{
   // Convert inbound string data into OrderDef structures
   OrderDef senderOrder;
   ConvertStringToOrderDef(strSenderOrder, senderOrder);

   OrderDef newOrder;
   ConvertStringToOrderDef(strNewOrder, newOrder);
   
   OrderDef openOrders[];
   int szExisting = ArraySize(arrOpenOrders);
   ArrayResize(openOrders, szExisting);
   for (int i = 0; i < szExisting; i++) {
      ConvertStringToOrderDef(arrOpenOrders[i], openOrders[i]);
   }
   
   // Call wrapped functions 
   if (FilterCheckNewOrder(Channel, senderOrder, openOrders, newOrder)) {
      // Order permitted. Need to pass back any changes.
      strNewOrder = ConvertOrderDefToString(newOrder);
      return true;
   } else {
      // Order blocked. Don't need to convert and return the modified data 
      return false;
   }
}


// Wrapper which receives/returns string data from the receiver EA, converting 
// it into OrderDef records for easier processing by the wrapped function above
bool FilterCloseOrder_Wrapper(string Channel, string strLocalOrder, int Reason) export 
{
   OrderDef order;
   ConvertStringToOrderDef(strLocalOrder, order);
   
   return FilterCloseOrder(Channel, order, Reason);
}

// Wrapper which receives/returns string data from the receiver EA, converting 
// it into OrderDef records for easier processing by the wrapped function above
bool FilterPartialClose_Wrapper(string Channel, string strLocalOrder, double SenderCloseFactor, double & LotsToClose) export
{
   OrderDef order;
   ConvertStringToOrderDef(strLocalOrder, order);
   
   return FilterPartialClose(Channel, order, SenderCloseFactor, LotsToClose);
}

// Wrapper which receives/returns string data from the receiver EA, converting 
// it into OrderDef records for easier processing by the wrapped function above
bool FilterOrderModify_Wrapper(string Channel, string strLocalOrder, double & NewEntryPrice, double & NewSL, double & NewTP) export
{
   OrderDef order;
   ConvertStringToOrderDef(strLocalOrder, order);
   
   return FilterOrderModify(Channel, order, NewEntryPrice, NewSL, NewTP);
}


// Wrapper which receives/returns string data from the receiver EA, converting 
// it into OrderDef records for easier processing by the wrapped function above
void FilterManageOrders_Wrapper(string Channel, string & arrOpenOrders[]) export
{
   OrderDef openOrders[];
   int szExisting = ArraySize(arrOpenOrders);
   ArrayResize(openOrders, szExisting);
   for (int i = 0; i < szExisting; i++) {
      ConvertStringToOrderDef(arrOpenOrders[i], openOrders[i]);
   }

   FilterManageOrders(Channel, openOrders);
}

// Serialization of an OrderDef into a string
string ConvertOrderDefToString(OrderDef& order)
{
   string strOrder = "";
   StringAdd(strOrder, "TICKET\02" + IntegerToString(order.ticket));
   StringAdd(strOrder, "\01POSITIONID\02" + order.positionId);
   StringAdd(strOrder, "\01SYMBOL\02" + order.symbol);
   StringAdd(strOrder, "\01TYPE\02" + IntegerToString(order.type));
   StringAdd(strOrder, "\01VOLUME\02" + DoubleToString(order.volume, 2));
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

// Deserialization of a string into an OrderDef
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
         } else if (kp[0] == "POSITIONID") {
            order.positionId = kp[1];
         } else if (kp[0] == "SYMBOL") {
            order.symbol = kp[1];
         } else if (kp[0] == "TYPE") {
            order.type = (int)StringToInteger(kp[1]);
         } else if (kp[0] == "VOLUME") {
            order.volume = StringToDouble(kp[1]);
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
